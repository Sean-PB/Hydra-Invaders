extends Area2D

@onready var controls = get_parent().get_node("Controls")
var speed = 400
var screen_size
var playing

func _ready():
	screen_size = get_viewport_rect().size
	add_to_group("friendly")
	hide()

func _process(delta):
	if position.y > 525:              # If the player is below the screen (when spawning)
		position.y -= 200 * delta       # Raise the player up until in position
	if playing == true:
		var velocity = 0
		# Touch screen
		velocity = controls.get_value()
		
		
		position.x += velocity * speed * delta
		position.x = clamp(position.x, 36, screen_size.x - 36)
