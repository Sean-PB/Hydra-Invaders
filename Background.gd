extends Node

func _ready():
	$AnimatedSprite2D.frame = 0

func _on_Earth_area_entered(area):
	if area.name == "Enemy":
		emit_signal("landed")
