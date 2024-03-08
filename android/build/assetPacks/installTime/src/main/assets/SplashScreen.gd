extends Sprite2D

signal splash_done

# Called when the node enters the scene tree for the first time.
func _ready():
	show()
	$Timer.start()


func _on_Timer_timeout():
	emit_signal("splash_done")
	queue_free()
