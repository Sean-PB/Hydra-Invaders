extends Area2D

var speed = -400                                  # Laser speed
var hit
var x_distance
var y_distance

func _ready():
	hit = false
	add_to_group("lasers")
	$LaserSound.play()

func _process(delta):                              # Laser movement
	position.y -= speed * delta
	if hit == true:
		position.x = get_parent().get_node("Player").position.x + x_distance
		position.y = get_parent().get_node("Player").position.y + y_distance

func _on_VisibilityNotifier2D_screen_exited():     # When laser leaves screen...
	queue_free()                                   # Delete laser

func explode():
	hit = true
	$AnimatedSprite2D.frame = 1
	$AnimatedSprite2D.play()
	$LaserForceFieldSound.play()
	x_distance = position.x - get_parent().get_node("Player").position.x
	y_distance = position.y - get_parent().get_node("Player").position.y
	await $AnimatedSprite2D.animation_finished
	queue_free()

