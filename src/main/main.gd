## Main Scene Script.
## 
## Path: [code]res://src/main/main.gd[/code]


class_name Main
extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	# Change window size if screen width < 1280
	change_window_size() 
	
	# Load save file if game is not running
	if GlobalVariables.app_running == false:
		get_tree().call_group("save_system", "load_data")
	
	# Update UI
	get_tree().call_group("ui_manager", "update_ui")
	

## Change window size to 480x800 if screen height is less than 1280 pixels 
## (Used for 1920x1080 monitors) [br]
## Position window in middle of screen after resizing. [br][br]
## [b]Note:[/b] Used for PC.
func change_window_size():
	var current_screen_size: Vector2i = DisplayServer.screen_get_size(0)
	var window_size_hdpi = Vector2i(480, 800)
	
	# Change resolution if necessary
	if current_screen_size.y < 1280:
		DisplayServer.window_set_size(window_size_hdpi)
		# Position window in center of screen
		var new_x_pos = (current_screen_size.x * 1.5) - (DisplayServer.window_get_size().x / 2)
		var new_y_pos = (current_screen_size.y / 2) - (DisplayServer.window_get_size().y / 2)
		DisplayServer.window_set_position(Vector2i(new_x_pos, new_y_pos))
