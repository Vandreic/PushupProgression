
extends Node


# **********************************
# *        Scene File Paths        *
# **********************************

## Path to the main menu scene.
const MAIN_SCENE_PATH: String = "res://scenes/main.tscn"

## Path to the log console scene.
const LOG_CONSOLE_SCENE_PATH: String = "res://scenes/log_console.tscn"

## Path to the options menu scene.
const OPTIONS_MENU_SCENE_PATH: String = "res://scenes/options_menu/options_menu.tscn"

## Path to the appearance menu scene.
const APPEARANCE_MENU_SCENE_PATH: String = "res://scenes/options_menu/options/appearance_menu.tscn"

## Path to the reset options menu scene.
const RESET_OPTIONS_MENU_SCENE_PATH: String = "res://scenes/options_menu/options/reset_options_menu.tscn"

## Path to the settings menu scene.
const SETTINGS_MENU_SCENE_PATH: String = "res://scenes/options_menu/options/settings_menu.tscn"

## Path to the notification scene.
const NOTIFICATION_SCENE_PATH: String = "res://scenes/notification.tscn"

## Path to the confirmation box scene.
const CONFIRMATION_BOX_SCENE_PATH: String = "res://scenes/confirmation_box.tscn"


# **********************************
# *         Theme File Paths       *
# **********************************

## Path to the light blue theme file.
const LIGHT_BLUE_THEME_PATH: String = "res://assets/themes/light_blue_theme.tres"

## Path to the light blue material design theme file.
const LIGHT_BLUE_MATERIAL_DESIGN_THEME_PATH: String = "res://assets/themes/light_blue_material_design_theme.tres"

## Path to the dark blue material design theme file.
const DARK_BLUE_MATERIAL_DESIGN_THEME_PATH: String = "res://assets/themes/dark_blue_material_design_theme.tres"


# **********************************
# *           Save Data            *
# **********************************

## Daily goal for the number of push-ups.
static var daily_pushups_goal: int = 100

## Number of push-ups to complete per session.
static var pushups_per_session: int = 10

## Total number of push-ups completed today.
static var total_pushups_today: int = 0

## Number of push-up sessions completed today.
static var sessions_completed_today: int = 0

## Number of remaining push-ups to reach today's goal.
static var pushups_remaining_today: int = 0

## Dictionary for storing user settings and progression data.
static var user_data_dict: Dictionary = {
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


# **********************************
# *            Game Data           *
# **********************************

## Indicates whether the app is currently running.
static var is_app_running: bool = false

## Array of log messages.
static var logs_array: Array = []

## Dictionary of available UI themes and their properties.
static var available_themes: Dictionary = {
	"light_blue": {
		"theme": preload(LIGHT_BLUE_THEME_PATH),
		"instance_id": preload(LIGHT_BLUE_THEME_PATH).get_instance_id(),
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
		"theme": preload(LIGHT_BLUE_MATERIAL_DESIGN_THEME_PATH),
		"instance_id": preload(LIGHT_BLUE_MATERIAL_DESIGN_THEME_PATH).get_instance_id(),
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
		"theme": preload(DARK_BLUE_MATERIAL_DESIGN_THEME_PATH),
		"instance_id": preload(DARK_BLUE_MATERIAL_DESIGN_THEME_PATH).get_instance_id(),
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

## Currently active UI theme. Default is light_blue.
static var current_ui_theme: Theme = available_themes["light_blue"]["theme"]

## Index of the currently selected theme.
static var selected_theme_index: int


# **********************************
# *            Functions           *
# **********************************

## Initialize user data.
func _ready() -> void:
	_connect_to_global_signal_bus()


## Connect to [GlobalSignalBus].
static func _connect_to_global_signal_bus() -> void:
	GlobalSignalBus.add_log_entry.connect(add_log_entry)
	#FIXME
	#GlobalSignalBus.load_data.connect(load_data)


## Adds a log entry to [member logs_array].
static func add_log_entry(message: String) -> void:
	# Get the current system time formatted as "HH:MM:SS"
	var time_stamp: String = _get_current_system_time()
	# Add the full log entry with a timestamp
	var log_entry: String = "[%s] %s" % [time_stamp, message]
	logs_array.append(log_entry)


## Get logs array.
static func get_logs_array() -> Array:
	return logs_array
	

## Get the current system time formatted as [code]HH:MM:SS[/code]. [br]
##
## [br]
##
## Returns: [br]
## • ([String]): Current system time formatted as [code]HH:MM:SS[/code].
static func _get_current_system_time() -> String:
	var time_dict: Dictionary = Time.get_time_dict_from_system()
	return "%02d:%02d:%02d" % [time_dict["hour"], time_dict["minute"], time_dict["second"]]



## Initializes and saves the user data including settings and daily progress.
static func initialize_and_save_user_data() -> void:
	save_user_settings_to_dict()
	save_daily_progress_to_dict()


## Saves the current user-specific settings to the [member user_data_dict].
static func save_user_settings_to_dict() -> void:
	# Set global settings based on current values
	user_data_dict["settings"] = {
		"daily_pushups_goal": daily_pushups_goal,
		"pushups_per_session": pushups_per_session,
		"ui_theme": get_theme_name(current_ui_theme),
		"ui_theme_index": selected_theme_index
	}


## Saves the current day's progress data to the [member user_data_dict].
static func save_daily_progress_to_dict() -> void:
	add_log_entry("Creating data dictionary...")
	
	# Get the current date
	var date_dict: Dictionary = Time.get_date_dict_from_system()
	var year: int = date_dict["year"]
	var month: int = date_dict["month"]
	var day: int = date_dict["day"]
	
	# Ensure the calendar structure is ready for today's data
	ensure_today_calendar_entry(year, month)
	# Save today's push-up dataay
	user_data_dict["calendar"][year][month][day] = _create_daily_pushup_data_dict()
	
	
	
	add_log_entry("Data dictionary created successfully.")


## Ensures the calendar structure has an entry for today's date.
## Creates the necessary structure if it doesn't exist. [br]
##
## [br]
##
## [b]Note:[/b] The calling function handles the creation or use of the day's entry.
static func ensure_today_calendar_entry(year: int, month: int) -> void:
	if not user_data_dict["calendar"].has(year):
		user_data_dict["calendar"][year] = {}
	if not user_data_dict["calendar"][year].has(month):
		user_data_dict["calendar"][year][month] = {}
	# No need to check for the current day; the calling function handles it


#TODO: Fix docs
## Creates a [Dictionary] with the current day's push-up progress data.
## Returns the [Dictionary] for storing the day's push-up data.
static func _create_daily_pushup_data_dict() -> Dictionary:
	# Set keys to current values
	var day_dict: Dictionary = {
		"daily_pushups_goal" = daily_pushups_goal,
		"pushups_per_session" = pushups_per_session,
		"pushups_remaining_today" = pushups_remaining_today,
		"total_pushups_today" = total_pushups_today,
		"sessions" = {}
	}
	return day_dict









## Get name of UI theme from [available_themes] as [String].
static func get_theme_name(theme: Theme) -> String:
	# Iterate through the dictionary of available themes
	for theme_key in available_themes:
		# Match provided theme's instance id with theme instance id from dictionary
		if theme.get_instance_id() == available_themes[theme_key]["instance_id"]:
			# Return the name of the matched theme
			return theme_key
	
	# Return an empty string if no match is found
	return ""
