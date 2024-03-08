extends Area2D

var speed = 1000                                   # Laser speed

func _ready():
	add_to_group("lasers")
	add_to_group("friendly")
	$LaserSound.play()

func _process(delta):                              # Laser movement
	position.y -= speed * delta

func _on_VisibilityNotifier2D_screen_exited():     # When laser leaves screen...
	queue_free()                                   # Delete laser


func _on_Laser_area_entered(area):
	if area.is_in_group("enemies"):
		if area.exploding == false:
			queue_free()
