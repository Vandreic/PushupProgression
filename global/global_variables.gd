## Provides a singleton (Autoload) for storing and managing global variables used across the app. [br]
##
## [br]
##
## This script functions as a centralized repository for global data such as user settings,
## daily goals, and UI themes. It is autoloaded and persists across scenes and sessions. [br]
##
## [br]
##
## [b]Usage:[/b] Access this singleton via [code]GlobalVariables[/code] from any
## script to manipulate or read global data. [br]
##
## [br]
##
## Path: [code]res://global/global_variables.gd[/code] [br]
## 
## [br]
##
## Structure of [member user_data_dict]:
##
## [codeblock]
## user_data_dict
##
## > user settings
##   > daily pushups goal
##   > pushups per session
##   > ui theme
##   > ui theme index
##
## > calendar
##   > year number
##     > month number
##       > day number
##         > daily pushups goal today
##         > pushups per session today
##         > remaining pushups today
##         > sessions today
##           > session 1
##             > pushups in session
##             > time of session
##           > session 2
##             > pushups in session
##             > time of session
##         > total pushups today
## [/codeblock]
##
## [br]
##
## Example structure of [member user_data_dict]:
##
## [codeblock]
## user_data_dict: {
##     "settings": {
##         "daily_pushups_goal": 100,
##         "pushups_per_session": 10,
##         "ui_theme": "light_blue",
##         "ui_theme_index": 0
##
##     },
##     "calendar": {
##         # Example of progression data for a specific day
##         "2024": {
##             "03": {
##                 "24": {
##                     "daily_pushups_goal": 100,
##                     "pushups_per_session": 10,
##                     "pushups_remaining_today": 80,
##                     "sessions": {
##                         "session_1": {
##                             "pushups": 10,
##                             "time": "10:41:59"
##                         },
##                         "session_2": {
##                             "pushups": 10,
##                             "time": "12:36:08"
##                         },
##                     "total_pushups_today": 80
##                     }
##                 }
##             }
##         }
##         # Additional days follows the same structure
##     }
## }
## [/codeblock]
##
## [br]
##
## Structure of [member available_themes]:
##
## [codeblock]
## available_themes
##
## > Theme name
##   > Preload theme file
##   > Unique identifier for the theme
##   > Boolean for UI borders
##   > Theme colors (Based of Material Design 3 color schemes)
##     > Primary container color
##     > Outline color
##   > Progress bar textures (Used to match given theme) 
##     > Under texture
##     > Over texture
##     > Progress texture
## [/codeblock]
##
## [br]
##
## Example structure of [member available_themes]:
##
## [codeblock]
## available_themes: {
##     # Example theme entry
##     "light_blue": {
##         "theme": preload("res://assets/themes/light_blue_theme.tres"),
##         "instance_id": preload("res://assets/themes/light_blue_theme.tres").get_instance_id(),
##         "border": true,
##         "color": {
##             "primary_container": "#f1f0f7",
##             "outline": "#000000"
##         },
##         "progress_bar": {
##             "under": load("res://assets/progress_icon/light_blue_theme/progress_bar_under.png"),
##             "over": load("res://assets/progress_icon/light_blue_theme/progress_bar_over.png"),
##             "progress": load("res://assets/progress_icon/light_blue_theme/progress_bar_progress.png")
##         }
##     }
##     # Additional themes follow the same structure
## }
## [/codeblock]


extends Node


## Path to the main menu scene.
const MAIN_SCENE_PATH: String = "res://src/main/main.tscn"

## Path to the logging menu scene.
const LOGGING_MENU_SCENE_PATH: String = "res://src/ui/options_menu/logging_menu/logging_menu.tscn"

## Indicates whether the app is currently running.
var is_app_running: bool = false

## Daily goal for the number of push-ups.
var daily_pushups_goal: int = 100

## Number of push-ups to complete per session.
var pushups_per_session: int = 10

## Total number of push-ups completed today.
var total_pushups_today: int = 0

## Number of push-up sessions completed today.
var sessions_completed_today : int = 0

## Number of push-ups remaining to reach today's goal.
var pushups_remaining_today: int = 0

## Dictionary for storing user settings and progression data.
var user_data_dict: Dictionary = {
	# Stores user settings
	"settings": {
		"daily_pushups_goal": 0,
		"pushups_per_session": 0,
		"ui_theme": "",
		"ui_theme_index": 0
	},
	# Stores data for each day
	"calendar": {}
}

## Array of log messages.
var logs_array: Array = []

## Dictionary of available UI themes and their properties.
var available_themes: Dictionary = {
	"light_blue": {
		"theme": preload("res://assets/themes/light_blue_theme.tres"),
		"instance_id": preload("res://assets/themes/light_blue_theme.tres").get_instance_id(),
		"border": true,
		"color": {
			"primary_container": "#f1f0f7",
			"outline": "#000000"
		},
		"progress_bar": {
			"under": load("res://assets/progress_icon/light_blue_theme/progress_bar_under.png"),
			"over": load("res://assets/progress_icon/light_blue_theme/progress_bar_over.png"),
			"progress": load("res://assets/progress_icon/light_blue_theme/progress_bar_progress.png")
		}
	},
	
	"light_blue_material_design": {
		"theme": preload("res://assets/themes/light_blue_material_design_theme.tres"),
		"instance_id": preload("res://assets/themes/light_blue_material_design_theme.tres").get_instance_id(),
		"border": false,
		"color": {
			"primary_container": "#dae2ff",
			"outline": "#757680"
		},
		"progress_bar": {
			"under": load("res://assets/progress_icon/light_blue_material_design_theme/progress_bar_under.png"),
			"over": load("res://assets/progress_icon/light_blue_material_design_theme/progress_bar_over.png"),
			"progress": load("res://assets/progress_icon/light_blue_material_design_theme/progress_bar_progress.png")
		}
	},
	
	"dark_blue_material_design": {
		"theme": preload("res://assets/themes/dark_blue_material_design_theme.tres"),
		"instance_id": preload("res://assets/themes/dark_blue_material_design_theme.tres").get_instance_id(),
		"border": true,
		"color": {
			"primary_container": "#121318",
			"outline": "#8f909a"
		},
		"progress_bar": {
			"under": load("res://assets/progress_icon/dark_blue_material_design_theme/progress_bar_under.png"),
			"over": load("res://assets/progress_icon/dark_blue_material_design_theme/progress_bar_over.png"),
			"progress": load("res://assets/progress_icon/dark_blue_material_design_theme/progress_bar_progress.png")
		}
	}
}

## Currently active UI theme. Default is [code]light_blue[/code].
var current_ui_theme: Theme = available_themes["light_blue"]["theme"]

## Index of the currently selected theme. [br]
## Defined in [method AppearanceMenuManager._on_themes_option_button_select].
var selected_theme_index: int


## Creates a [StyleBoxFlat] for a [Panel] based on the [member current_ui_theme]. [br]
##
## [br]
##
## This function duplicates a [Panel]'s [StyleBox] from the [member current_ui_theme] 
## and modifies its appearance according to the theme settings such as 
## background color, border width, and corner radius.
func create_custom_panel_stylebox() -> StyleBoxFlat:
	# Duplicate panel theme stylebox from chosen them	
	var stylebox: StyleBoxFlat = current_ui_theme.get_stylebox("panel", "Panel").duplicate()
	
	# Loop trough themes
	for theme in available_themes:
		# Get chosen theme (based of instance id)
		if current_ui_theme.get_instance_id() == available_themes[theme]["instance_id"]:
			# Change background color
			stylebox.bg_color = Color(available_themes[theme]["color"]["primary_container"])
			# Add corner radius
			stylebox.set_corner_radius_all(25)
			
			# Check if theme has borders
			if available_themes[theme]["border"] == true:
				# Add borders
				stylebox.set_border_width_all(6)
				# Set border color
				stylebox.border_color = Color(available_themes[theme]["color"]["outline"])
	
	# Return new stylebox
	return stylebox


## Applies the [member current_ui_theme] and optionally logs the change.
func apply_current_ui_theme(log_ui_change: bool = false) -> void:
	# Check if create log is true
	if log_ui_change == true:
		# Loop trough themes
		for theme in GlobalVariables.available_themes:
			# Get chosen theme (based of instance id)
			if GlobalVariables.current_ui_theme.get_instance_id() == GlobalVariables.available_themes[theme]["instance_id"]:
				# Create text for log message
				var _log_text: String = "UI theme changed to: " + theme.capitalize()
				# Create log message
				create_log_entry(_log_text)
			
	# Apply UI theme to UI scene
	get_tree().call_group("ui_manager", "apply_current_ui_theme")


## Logs a specific message in the system's log. [br]
##
## [br]
##
## This function triggers the creation of a log entry using the 
## [method SaveSystem.create_log_entry]. [br]
##
## [br]
##
##
## See [method SaveSystem.create_log_entry] for more details.
func create_log_entry(log_message: String) -> void:
	# Create log
	get_tree().call_group("save_system", "create_log_entry", log_message)


## Displays a notification with an optional extended duration. [br]
##
## [br]
## 
## This function triggers the creation of a notification scene ([NotificationManager])
## using the [method NotificationSystem.create_notification]. [br]
##
## [br]
##
## See [method NotificationSystem.create_notification] for more details.
func create_notification(notification_text: String, extended_duration: bool = false) -> void:
	# Create notification
	get_tree().call_group("notification_system", "create_notification", notification_text, extended_duration)


## Updates the UI elements. [br]
##
## [br]
##
## See [method UIManager.update_ui] for more details.
func update_ui() -> void:
	get_tree().call_group("ui_manager", "update_ui")


## Saves the current progression and settings. [br]
##
## [br]
##
## See [method SaveSystem.save_data] for more details.
func save_data() -> void:
	get_tree().call_group("save_system", "save_data")


## Loads saved progression and settings. [br]
##
## [br]
##
## See [method SaveSystem.load_data] for more details.
func load_data() -> void:
	get_tree().call_group("save_system", "load_data")
