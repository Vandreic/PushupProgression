## Main Scene.
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
		GlobalVariables.load_data()
	
	# Set UI theme
	GlobalVariables.chosen_ui_theme = GlobalVariables.LIGHT_UI_THEME
	# Apply UI theme
	GlobalVariables.apply_ui_theme(GlobalVariables.chosen_ui_theme)
	
	# Update UI
	GlobalVariables.update_ui()


## Change window size to 480x800 if screen height is less than 1280 pixels 
## (Used for 1920x1080 monitors). [br]
## Position window in center of screen after resizing. [br]
##
## [br]
##
## [b]Note:[/b] Used for PC.
func change_window_size():
	# Get primary screen id/index
	var primary_monitor_id: int = DisplayServer.get_primary_screen()
	# Get primary screen size
	var screen_size: Vector2i = DisplayServer.screen_get_size(primary_monitor_id)
	# Define desired window size
	var window_size: Vector2i = Vector2i(480, 800)
	
	# Change resolution if primary screen height is less than 1280 pixels
	if screen_size.y < 1280:
		# Set desired window size
		DisplayServer.window_set_size(window_size)
		# Calculate window center position
		#var center_x: int = int((screen_size.x - window_size.x) / 2.0)
		var center_x: int = int((screen_size.x - window_size.x) * 1.833)
		var center_y: int = int((screen_size.y - window_size.y) / 2.0)
		
		# Position window in center
		DisplayServer.window_set_position(Vector2i(center_x, center_y))
