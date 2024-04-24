## Global Variables Singleton (Autoload).
##
## This singleton script serves as a central repository for storing and 
## accessing global variables used throughout the application. [br][br]
## 
## Path: [code]res://global/global_variables.gd[/code] [br]
##
## [br]
##
## Structure of [member save_data_dict]:
##
## [codeblock]
## save_data_dict
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
## Example structure of [member save_data_dict]:
##
## [codeblock]
## save_data_dict: {
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
##                     "remaining_pushups": 80,
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
## Structure of [member ui_themes_dict]:
##
## [codeblock]
## ui_themes_dict
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
## Example structure of [member ui_themes_dict]:
##
## [codeblock]
## ui_themes_dict: {
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

## Flag indicating if the app is currently running.
var app_running: bool = false

## Daily goal for push-ups.
var daily_pushups_goal: int = 100

## Push-ups to complete per session.
var pushups_per_session: int = 10

## Total push-ups completed today.
var total_pushups_today: int = 0

## Number of push-up sessions completed today.
var total_pushups_sessions: int = 0

## Push-ups remaining to reach today's goal.
var remaining_pushups: int = 0

## Dictionary for storing user settings and progression data.
var save_data_dict: Dictionary = {
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

## Dictionary of UI themes and their properties.
var ui_themes_dict: Dictionary = {
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

## Currently active UI theme. [Default: Light Blue].
var chosen_ui_theme: Theme = ui_themes_dict["light_blue"]["theme"]

## Index of the currently selected theme. [Default: Light Blue]. [br][br]
## Value is defined in [method AppearanceMenuManager._on_themes_option_button_select].
var selected_theme_index: int


## Create [StyleBoxFlat] for [Panel] variant.
func create_panel_stylebox_variant() -> StyleBoxFlat:
	# Duplicate panel theme stylebox from chosen theme
	var stylebox: StyleBoxFlat = chosen_ui_theme.get_stylebox("panel", "Panel").duplicate()
	
	# Loop trough themes
	for theme in ui_themes_dict:
		# Get chosen theme (based of instance id)
		if chosen_ui_theme.get_instance_id() == ui_themes_dict[theme]["instance_id"]:
			# Change background color
			stylebox.bg_color = Color(ui_themes_dict[theme]["color"]["primary_container"])
			# Add corner radius
			stylebox.set_corner_radius_all(25)
			
			# Check if theme has borders
			if ui_themes_dict[theme]["border"] == true:
				# Add borders
				stylebox.set_border_width_all(6)
				# Set border color
				stylebox.border_color = Color(ui_themes_dict[theme]["color"]["outline"])
	
	# Return new stylebox
	return stylebox


## Applies [member chosen_ui_theme] and optionally logs the change if 
## [param log_ui_change] is [code]true[/code].
func apply_ui_theme(log_ui_change: bool = false) -> void:
	# Check if create log is true
	if log_ui_change == true:
		# Loop trough themes
		for theme in GlobalVariables.ui_themes_dict:
			# Get chosen theme (based of instance id)
			if GlobalVariables.chosen_ui_theme.get_instance_id() == GlobalVariables.ui_themes_dict[theme]["instance_id"]:
				# Create text for log message
				var _log_text: String = "UI theme changed to: " + theme.capitalize()
				# Create log message
				create_log(_log_text)
			
	# Apply UI theme to UI scene
	get_tree().call_group("ui_manager", "apply_ui_theme")


## Create log message. [br]
##
## [br]
##
## See [method SaveSystem.create_log] for more details.
func create_log(log_message: String) -> void:
	# Create log
	get_tree().call_group("save_system", "create_log", log_message)


## Create notification. [br]
##
## [br]
##
## See [method NotificationSystem.create_notification] for more details.
func create_notification(notification_text: String, extended_duration: bool = false) -> void:
	# Create notification
	get_tree().call_group("notification_system", "create_notification", notification_text, extended_duration)


## Update UI. [br]
##
## [br]
##
## See [method UIManager.update_ui] for more details.
func update_ui() -> void:
	get_tree().call_group("ui_manager", "update_ui")


## Save data. [br]
##
## [br]
##
## See [method SaveSystem.save_data] for more details.
func save_data() -> void:
	get_tree().call_group("save_system", "save_data")


## Load data. [br]
##
## [br]
##
## See [method SaveSystem.load_data] for more details.
func load_data() -> void:
	get_tree().call_group("save_system", "load_data")
