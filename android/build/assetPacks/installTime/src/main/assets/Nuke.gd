extends Node2D

var speed = 150
var explode

func _ready():
	$Missile_sound.play()
	$Explosion.hide()
	explode = false

func _process(delta):
	position.y -= speed * delta                    # Missle movement
	if position.y < 250:                           # When missile gets to correct location,
		explode = true                                 # explode
		speed = 0
		$Missile.hide()
		$Missile_sound.stop()
		
	else:
		$Missile.show()
		explode = false
		speed = 150


func get_explode():                                # To tell whether exploded or not in main scene
	return explode
