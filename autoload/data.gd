
extends Node


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

## Connects to [EventBus]'s signals.
func _ready() -> void:
	EventBus.pushups_added.connect(on_pushups_added)


## Creates a [StyleBoxFlat] for a [Panel] based on the [member current_ui_theme]. [br]
##
## [br]
##
## This function duplicates a [Panel]'s [StyleBox] from the [member current_ui_theme] 
## and modifies its appearance according to the theme settings such as 
## background color, border width, and corner radius.
static func create_custom_panel_stylebox() -> StyleBoxFlat:
	# Duplicate panel theme stylebox from currently applied theme
	var stylebox: StyleBoxFlat = current_ui_theme.get_stylebox("panel", "Panel").duplicate()
	
	# Update theme properties to match new applied theme
	for theme in available_themes:
		if theme == get_theme_name(current_ui_theme):
			stylebox.bg_color = Color(available_themes[theme]["color"]["primary_container"])
			stylebox.set_corner_radius_all(25)
			
			# If theme has borders, add them
			if available_themes[theme]["border"] == true:
				stylebox.set_border_width_all(6)
				stylebox.border_color = Color(available_themes[theme]["color"]["outline"])
	
	# Return new stylebox
	return stylebox


## Get name of UI theme from [member available_themes] as [String]. [br]
##
## [br]
##
## Returns: [br]
## • [code]theme_key[/code] ([String]): The theme name. [br]
## • [code]""[/code] ([String]): Empty string if no matching theme.
static func get_theme_name(theme: Theme) -> String:
	for theme_key in available_themes:
		# Match provided theme's instance id with theme instance id from dictionary
		if theme.get_instance_id() == available_themes[theme_key]["instance_id"]:
			return theme_key
	
	# Return an empty string if no match is found
	return ""


## Get the current system time formatted as [code]HH:MM:SS[/code].
static func get_current_system_time() -> String:
	var time_dict: Dictionary = Time.get_time_dict_from_system()
	return "%02d:%02d:%02d" % [time_dict["hour"], time_dict["minute"], time_dict["second"]]


## Add log entry to [member logs_array]
static func add_log_entry(log_message: String) -> void:
	logs_array.append("[%s] %s" % [get_current_system_time(), log_message])


## Return [member logs_array].
static func get_logs_array() -> Array:
	return logs_array


static func on_pushups_added() -> void:
	total_pushups_today += pushups_per_session
	
	pushups_remaining_today = daily_pushups_goal - total_pushups_today
	# Set remaining push-ups to 0, if daily goal is reached
	if pushups_remaining_today <= 0:
		pushups_remaining_today = 0

	sessions_completed_today += 1
