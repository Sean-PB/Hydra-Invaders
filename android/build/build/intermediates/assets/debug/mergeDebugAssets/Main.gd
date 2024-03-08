extends Node

const ENEMY = preload("res://Enemy.tscn")       # Load in the Enemy scene
const LASER = preload("res://Laser.tscn")       # Load in the Laser scene
const NUKE = preload("res://Nuke.tscn")         # Load in the Nuke scene
const SHIELD = preload("res://ForceField.tscn") # Load in the ForecField scene

var rng = RandomNumberGenerator.new()
var screen_size
var nuke = NUKE.instantiate()
var nuke_active = false
var nuke_available
var num_of_enemies
var shields_remaining = 3


func _ready():
	$HUD.process_mode 
	$SplashScreen.connect("splash_done", Callable(self, "splash_done"))


func new_game():
	$Background/AnimatedSprite2D.stop()     # Stopss animation if there was a previous game
	$Player.playing = true                   # Enables player input
	$Music.play()                            # Starts musci loop
	$Player.set_position(Vector2(576, 600))  # Setting players starting position
	$Player.show()                           # Showing player
	
	# Showing controls
	$Controls/Buttons.show()
	$Controls/Buttons/Nuke.show()
	$Controls/Buttons/Shield.show()
	
	# Hiding things
	$HUD/PlayerSkinSelector.hide()
	
	# Player info reset and showing
	$HUD/LaserRechargeBar/TextureProgressBar.value = 100  # Fill laser recharge bar
	$HUD/LaserRechargeBar.show()             # Show laser recharge bar
	shields_remaining = 3
	$Controls.shields_remaining(shields_remaining)
	num_of_enemies = 0                       # Enemies on screen = 0
	nuke_available = true
	
	spawn_enemy()                            # Spawn 1 enemy at begining of game


func game_over():
	if nuke_active:
		remove_child(nuke)                        # Removes nuke from scene without removing instance
	$Player.playing = false                  # Disabels player input
	$Music.stop()                            # Ends music loop
	$"Game Over".play()                      # Play game over sound
	$HUD/Pause.hide()                        # Hides pause button immediatley to avoid issues
	get_tree().call_group("enemies", "queue_free")     # Removes all enemies
	get_tree().call_group("lasers", "queue_free")      # Removes all lasers
	$Controls/Buttons.hide()
	$HUD/LaserRechargeBar.hide()             # Hide laser recharge bar
	$Controls/Buttons/NukeDisabled.hide()
	$Controls/Buttons/DisabledShield.hide()                # Hide shield ad button
	$Player/AnimatedSprite2D.frame = 1         # Skips to fireball
	$Player/AnimatedSprite2D.play()            # Player blows up
	await $Player/AnimatedSprite2D.animation_finished  # Wait till done blowing up
	$Player/AnimatedSprite2D.stop()            # Stops animation for future games
	$Player/AnimatedSprite2D.frame = 0         # Sets animated sprite to ship
	$Player.hide()                           # Hides player
	$HUD.show_game_over_pt_1()               # Show the game over text part
	$Background/AnimatedSprite2D.frame = 1    # Skips to alien planting flag
	$Background/AnimatedSprite2D.play()       # Alien plants flag
	await $Background/AnimatedSprite2D.animation_finished  # Wait a sec
	$Background/AnimatedSprite2D.stop()       # Stops aniimation for furture games
	$Background/AnimatedSprite2D.frame = 0    # Resets animation to just earth
	$HUD.show_game_over_pt_2()                # Lets you start new game


func _process(delta):
	# Nuke check
	if nuke_active: # This is to prevent a null nuke from being called in the next line
		if nuke.get_explode() and $Player.playing: # If the nuke has reached detination point while game is playing
			get_tree().call_group("enemies", "queue_free")  # Removes all enemies
			get_tree().call_group("lasers", "queue_free")   # Removes all lasers
			nuke.get_node("Explosion").show()               # Show animated sprite
			nuke.get_node("Explosion").play()               # Play animation
			nuke.get_node("Nuke_sound").play()
			$HUD/LaserRechargeBar.hide()
			$Music.stop()
			nuke_active = false                             # Resets nuke_active boolean
			await nuke.get_node("Explosion").animation_finished # When done...
			$HUD/Score.text = str(int($HUD/Score.text) + num_of_enemies)
			$HUD/LaserRechargeBar.hide()
			nuke.get_node("Explosion").stop()               # Stpp animated sprite
			nuke.get_node("Explosion").hide()               # Hide animation
			remove_child(nuke)                              # Removes nuke from scene without removing instance
			$Music.play()
			$HUD/LaserRechargeBar.show()
			num_of_enemies = 0                              # Reset number of enemies
			spawn_enemy()                                   # Spawns 1 enemy
	
	# Enemy hit check
	for i in get_tree().get_nodes_in_group('enemies'):     # Loop through all enemies
		if i.get_hit() == true and i.get_exploding() == false:  # If hit and not already exploding
			i.play_animation()
			$Explosion.play()                    # Sound of enemy exploding
			num_of_enemies -= 1
			# Spawning 2 new enemies in random locations
			spawn_enemy()
			spawn_enemy()
			# Add 1 to score when hit
			$HUD/Score.text = str(int($HUD/Score.text) + 1)


func on_shoot():                      # When the player signal shoot is sent
	if $HUD/LaserRechargeBar/TextureProgressBar.value >= 20: # Only fire if recharged enough (1/5 seconds)
		var laser = LASER.instantiate()          # Make an instance of laser
		laser.set_position($Player.position)  # Set laser position to where the player is
		add_child(laser)                      # Add the laser scene to the main scene
		$HUD/LaserRechargeBar/TextureProgressBar.value -= 20


func on_nuke():
	nuke.set_position($Player.position)                # Shoot from player posiion
	add_child(nuke)                                    # Add nuke to tree
	nuke.get_node("Missile_sound").play()
	nuke_active = true                                 # Nuke is active
	nuke.explode = false
	nuke_available = false


func on_shield():
	var shield = SHIELD.instantiate()
	$Player.add_child(shield)
	shields_remaining -= 1
	$Controls.shields_remaining(shields_remaining)
	if shields_remaining <= 0:
		$Controls/Buttons/Shield.hide()
		$Controls/Buttons/DisabledShield.show()
	else:
		$Controls.disable_shield_button(true)


func spawn_enemy():                           # Spawns enemy
	var enemy = ENEMY.instantiate()
	num_of_enemies += 1                       # adds 1 to active enemy count
	add_child(enemy)


func _on_Player_area_entered(area):
	if !$Player.has_node("ForceField"):
		area.queue_free()                         # Removes whatever hit player
		game_over()                               # Calls game over function


func _on_HUD_paused():         # When the pause button is pressed,
	$Controls/Buttons.hide()        # Hide controls
	get_tree().paused = true        # Pause game
	$HUD/Score.text = "\n" + $HUD/Score.text   # Lowers score under banner


func _on_HUD_resume():         # When resume button is pressed
	$Controls/Buttons.show()        # Showing controls
	get_tree().paused = false       # Unpause game
	if "\n" in $HUD/Score.text:
		$HUD/Score.text = $HUD/Score.text.substr(1, -1)  # Raises score back to top
	if nuke_available == false:
		$Controls/Buttons/NukeDisabled.show()
	if shields_remaining == 0:
		$Controls/Buttons/DisabledShield.show()
		$Controls/Buttons/Shield.hide()

func splash_done():
	$HUD/StartButton.show()
	$HUD/Mute.show()
	$HUD/Message.show()
	$HUD/HighScore.show()
