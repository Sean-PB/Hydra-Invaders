extends CanvasLayer

var score_file = "user://highscore.txt"   # To save the highscore in
var high_score = 0
var bar_value = 100
var mute = false

signal start_game
signal paused
signal resume
signal help_pressed
signal exit_help

func _ready():
	$PlayerSkinSelector.hide()
	$Pause.hide()
	$Resume.hide()
	$LaserRechargeBar.hide()
	$Help/ExitHelp.hide()
	$Help/Sprite2D.hide()
	$Score.hide()
	$Sound.hide()
	load_score()   # Loads in the highscore
	$LaserRechargeBar/RechargeTimer.start(0.04) # Times out every 0.04 seconds
	$HighScore.text = $HighScore.text.substr(0, 12) + str(high_score) # Adds high score to text


func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

func show_game_over_pt_1():
	$Score.text = "\n" + $Score.text
	show_message("Game Over")
	if int($Score.text) > int($HighScore.text.substr(12, -1)):
		$HighScore.text = $HighScore.text.substr(0, 12) + $Score.text.substr(1, -1)
		high_score = $Score.text
		save_score()
	else:
		load_score()
		$HighScore.text = $HighScore.text.substr(0, 12) + str(high_score)
	$HighScore.show()

func show_game_over_pt_2():
	# Wait until the Message Timer has counted down
	show_message("Hydra Invaders")
	$StartButton.show()
	$StartButton/SelectPlayerColor.show()
	if mute:                       # Show mute or sound button depending
		$Sound.show()
	else:
		$Mute.show()

func update_score(score):
	$Score.text = str(score)

func _on_StartButton_pressed():
	$Pause.show()
	$StartButton.hide()
	$HighScore.hide()
	$Message.hide()
	$Help.hide()
	$Mute.hide()
	$Sound.hide()
	$Score.show()
	$Score.text = "0"
	emit_signal("start_game")

func load_score():
	if FileAccess.file_exists(score_file):
		var f = FileAccess.open(score_file, FileAccess.READ)
		var content = f.get_as_text()
		high_score = int(content)
		f.close()

func save_score():
	var f = FileAccess.open(score_file, FileAccess.WRITE)
	f.store_string(str(high_score))
	f.close()

func _on_Pause_pressed():       # If the pause button is pressed
	emit_signal("paused")          # Emit pause signal to main
	$Pause.hide()                  # Hide pause button
	$Resume.show()                 # Show resume button
	show_message("Paused")         # Show "Paused" message
	if mute:                       # Show mute or sound button depending
		$Sound.show()
	else:
		$Mute.show()

func _on_Resume_pressed():       # If resume is pressed
	emit_signal("resume")            # Emit resume signal to main
	$Resume.hide()                   # Hide the resume button
	$Pause.show()                    # Show the pause button
	$Help.hide()                     # Hide help button
	$Mute.hide()                     # Hide mute
	$Sound.hide()                    # Hide sound
	$Message.hide()                  # Hide message

func _on_RechargeTimer_timeout():         # Fills progress bar
	if $LaserRechargeBar/TextureProgressBar.value >= 20:  # If its > 20 the tint is...
		$LaserRechargeBar/TextureProgressBar.tint_progress = "ffffff"   # Clear
	else:                                              # Otherwise...
		$LaserRechargeBar/TextureProgressBar.tint_progress = "ff0000"   # its red
	if $LaserRechargeBar/TextureProgressBar.value != 100: # If bar isn't full...
		$LaserRechargeBar/TextureProgressBar.value += 1           # fill it


func _on_SelectPlayerColor_pressed():
	$StartButton/SelectPlayerColor.hide()
	$PlayerSkinSelector.show()


func _on_Red_released():
	get_parent().get_node("Player/AnimatedSprite2D").animation = "Red"
	$PlayerSkinSelector.hide()
	$StartButton/SelectPlayerColor.show()


func _on_Blue_released():
	get_parent().get_node("Player/AnimatedSprite2D").animation = "Blue"
	$PlayerSkinSelector.hide()
	$StartButton/SelectPlayerColor.show()
	

func _on_Green_released():
	get_parent().get_node("Player/AnimatedSprite2D").animation = "Green"
	$PlayerSkinSelector.hide()
	$StartButton/SelectPlayerColor.show()


func _on_Yellow_released():
	get_parent().get_node("Player/AnimatedSprite2D").animation = "Yellow"
	$PlayerSkinSelector.hide()
	$StartButton/SelectPlayerColor.show()


func _on_Pink_released():
	get_parent().get_node("Player/AnimatedSprite2D").animation = "Pink"
	$PlayerSkinSelector.hide()
	$StartButton/SelectPlayerColor.show()


func _on_Black_released():
	get_parent().get_node("Player/AnimatedSprite2D").animation = "Black"
	$PlayerSkinSelector.hide()
	$StartButton/SelectPlayerColor.show()


func _on_Help_pressed():             # Help button pressed
	emit_signal("help_pressed")
	$Help/Sprite2D.show()
	$Help/ExitHelp.show()


func _on_ExitHelp_pressed():          # Exit help button pressed
	emit_signal("exit_help")
	$Help/Sprite2D.hide()
	$Help/ExitHelp.hide()


func _on_Mute_pressed():
	mute = true
	$Mute.hide()
	$Sound.show()
	AudioServer.set_bus_mute(0, true)


func _on_sound_pressed():
	mute = false
	$Mute.show()
	$Sound.hide()
	AudioServer.set_bus_mute(0, false)
	
