extends Area2D

const LASER = preload("res://EnemyLaser.tscn")

var hit                                # Boolean if enemy has been hit or not
var time_elapsed
var rng = RandomNumberGenerator.new()  # Random number generator
var direction                          # Direction the enemy starts in
var speed                              # The speed that the enemy moves
var screen_size                        # Screen size
var exploding                          # Boolean if enemy is exploding or not
var force_hit                          # Boolean if enemy hit force field or not
var x_distance                         # Distance from force field after contact
var y_distance                         # Distance from force field after contact


func _ready():
	# Setting variables
	hit = false
	exploding = false
	screen_size = get_viewport_rect().size   # Get size of screen
	
	# Misc
	$AnimatedSprite2D.hide()                   # Hide fire ball
	add_to_group("enemies")                  # Add to group
	
	# Position
	rng.randomize()                          # Randomize RNG
	var x = rng.randf_range(72, screen_size.x  - 72)   # Pick random number in range of screen size
	set_position(Vector2(x, -28))             # Set enemy position.x based on random number
	
	# Speed and direction
	speed = rng.randi_range(125, 175)        # Random speed within specified range
	direction = rng.randi_range(0, 2)           # Random direction
	if direction == 1:                          # If direction is 1...
		speed = -speed                          # Speed is -speed (goes left)
	$ShootTimer.start(rng.randf_range(0, 10))   # Shoots within a 10 sec range...
	$ShootTimer2.start(10)                      # Every 10 secs


func _process(delta):
	if position.y < 28:               # If the enemy is above the screen,
		position.y += abs(speed) * delta      # Lower them down to on the screen
	else:                             # Once the enemy is fully on screen, 
		position.x += speed * delta              # Move the enemy
		if position.x <= 36:                     # If enemy is on left screen border
			position.y += 68                       # Move enemy down
			speed = -(speed - 30)                  # Increase speed and change direction
		elif position.x >= screen_size.x - 36:   # Elif enemy is on right screen border
			position.y += 68                       # Move enemy down
			speed = -(speed + 30)                  # Increase speed and change direction
		position.x = clamp(position.x, 36, screen_size.x - 36)
		position.y = clamp(position.y, -60, screen_size.y - 36)    # Clamp the enemy to the bottom of the screen
	
	if force_hit:
		position.x = get_parent().get_node("Player").position.x + x_distance
		position.y = get_parent().get_node("Player").position.y + y_distance


func _on_Enemy_area_entered(area):
	hit = true                      # then enemy is hit


func get_hit():                     # Function that returns whether enemy is
	return hit                          # hit or not


func get_exploding():               # Function that returns whether enemy is
	return exploding                    # expoliding or not


func play_animation():              # Function that...
	exploding = true                    # changes exploding to true
	speed = 0                           # changes speed of enemy to 0
	$Sprite2D.hide()                      # hides the ship sprite
	$AnimatedSprite2D.show()              # shows the animated sprite (fireball)
	$AnimatedSprite2D.play()              # plays the animated sprite
	await $AnimatedSprite2D.animation_finished  # waits until animated sprite is done
	queue_free()                        # then removes enemy


func force_field_explosion():
	hit = true
	force_hit = true
	x_distance = position.x - get_parent().get_node("Player").position.x
	y_distance = position.y - get_parent().get_node("Player").position.y
	

func _on_ShootTimer_timeout():
	if exploding == false:             # Enemies can't fire if they have been hit
		var laser = LASER.instantiate()
		laser.set_position(position)
		get_parent().add_child(laser)
	

func _on_ShootTimer2_timeout():
	$ShootTimer.start(rng.randf_range(0, 10))   # Shoots within a 10 sec range every 10 seconds
