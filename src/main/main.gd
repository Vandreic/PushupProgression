## Main Scene.
## 
## Main scene that will be loaded when the application runs. [br]
##
## [br]
##
## This script is responsible for window sizing based on screen resolution,
## loading data, applying the UI theme, and updating the user interface. [br]
##
## [br]
##
## Path: [code]res://src/main/main.gd[/code]


class_name Main
extends Node


## Default window size, used when screen height is below a minimum threshold.
const WINDOW_SIZE: Vector2i = Vector2i(480, 800)

## Minimum screen height to trigger window resizing.
const MIN_SCREEN_HEIGHT: int = 1280


## Initializes the application by adjusting the window size if needed, 
## loading saved data or applying the UI theme based on the application's 
## running state, and updating the UI components.
func _ready():
	_resize_and_center_window_if_needed()
	_load_data_or_apply_theme()
	GlobalVariables.update_ui()


## Resizes and centers the application window if the screen height is less
## than the minimum screen height, defined by [constant MIN_SCREEN_HEIGHT].
func _resize_and_center_window_if_needed() -> void:
	var primary_monitor_id: int = DisplayServer.get_primary_screen()
	var screen_size = DisplayServer.screen_get_size(primary_monitor_id)
	
	if screen_size.y < MIN_SCREEN_HEIGHT:
		DisplayServer.window_set_size(WINDOW_SIZE)
		_center_window_on_screen(screen_size)


## Centers the window on the screen based on the [constant WINDOW_SIZE].
func _center_window_on_screen(screen_size: Vector2i):
	var center_x: int = int((screen_size.x - WINDOW_SIZE.x) * 1.833)
	var center_y: int = int((screen_size.y - WINDOW_SIZE.y) / 2.0)
	DisplayServer.window_set_position(Vector2i(center_x, center_y))


## Loads saved data if application is not running, or applies the UI theme if it is. [br]
##
## [br]
##
## This decision is based on the global state variable [member GlobalVariables.is_app_running].
func _load_data_or_apply_theme():
	if GlobalVariables.is_app_running == false:
		GlobalVariables.load_data()
	else:
		GlobalVariables.apply_current_ui_theme()
