extends Node


## Manages and stores all app data. [br]
##
## [br]
##
## This autoloaded script acts as a centralized repository for all app data,
## such as user settings, daily pushup goals, and progress. [br]
##
## [br]
## 
## It is accessed globally as [code]Data[/code]. [br]
##
## [br]
##
## [b]Path:[/b] [code]res://autoload/data.gd[/code]


# **********************************
# *         Theme File Paths       *
# **********************************

## Path to the light blue theme file.
const LIGHT_BLUE_THEME_PATH: String = "res://assets/themes/light_blue_theme.tres"

## Path to the light blue material design theme file.
const LIGHT_BLUE_MATERIAL_DESIGN_THEME_PATH: String = "res://assets/themes/light_blue_material_design_theme.tres"

## Path to the dark blue material design theme file.
const DARK_BLUE_MATERIAL_DESIGN_THEME_PATH: String = "res://assets/themes/dark_blue_material_design_theme.tres"

## Path to the folder containing assets for the progress bar.
const PROGRESS_BAR_ASSETS_PATH: String = "res://assets/progress_bar/"

# **********************************
# *           Save Data            *
# **********************************

## Daily goal for the number of push-ups.
var daily_pushups_goal: int = 100

## Number of push-ups to complete per session.
var pushups_per_session: int = 10

## Total number of push-ups completed today.
var total_pushups_today: int = 0

## Number of push-up sessions completed today.
var sessions_completed_today: int = 0

## Number of remaining push-ups to reach today's goal.
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

# **********************************
# *            Game Data           *
# **********************************

## Indicates whether the app is currently running.
var is_app_running: bool = false

## Array of log messages.
var logs_array: Array = []

## Dictionary of available UI themes and their properties.
var available_themes: Dictionary = {
	"light_blue": {
		"theme": preload(LIGHT_BLUE_THEME_PATH),
		"instance_id": preload(LIGHT_BLUE_THEME_PATH).get_instance_id(),
		"border": true,
		"color": {
			"primary_container": "#f1f0f7",
			"outline": "#000000"
		},
		"progress_bar": {}
	},
	"light_blue_material_design": {
		"theme": preload(LIGHT_BLUE_MATERIAL_DESIGN_THEME_PATH),
		"instance_id": preload(LIGHT_BLUE_MATERIAL_DESIGN_THEME_PATH).get_instance_id(),
		"border": false,
		"color": {
			"primary_container": "#dae2ff",
			"outline": "#757680"
		},
		"progress_bar": {}
	},
	"dark_blue_material_design": {
		"theme": preload(DARK_BLUE_MATERIAL_DESIGN_THEME_PATH),
		"instance_id": preload(DARK_BLUE_MATERIAL_DESIGN_THEME_PATH).get_instance_id(),
		"border": true,
		"color": {
			"primary_container": "#121318",
			"outline": "#8f909a"
		},
		"progress_bar": {}
	}
}

## Currently active UI theme. Default is light_blue.
var current_ui_theme: Theme = available_themes["light_blue"]["theme"]

## Index of the currently selected theme.
var selected_theme_index: int

# **********************************
# *            Functions           *
# **********************************

## Connects to [EventBus]'s signals and load assets for progres bar, when the node is ready.
func _ready() -> void:
	EventBus.pushups_added.connect(_on_pushups_added)
	_load_progress_bar_assets()


## Creates a [StyleBoxFlat] for a [Panel] based on the [member current_ui_theme]. [br]
##
## [br]
##
## This function duplicates a [Panel]'s [StyleBox] from the [member current_ui_theme] 
## and modifies its appearance according to the theme settings such as 
## background color, border width, and corner radius.
func create_custom_panel_stylebox() -> StyleBoxFlat:
	# Duplicate panel theme stylebox from currently applied theme
	var stylebox: StyleBoxFlat = current_ui_theme.get_stylebox("panel", "Panel").duplicate()
	
	# Update theme properties to match new applied theme
	for theme in available_themes:
		if theme == get_theme_name(current_ui_theme):
			# Add rounded corners
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
func get_theme_name(theme: Theme) -> String:
	for theme_key in available_themes:
		# Match provided theme's instance id with theme instance id from dictionary
		if theme.get_instance_id() == available_themes[theme_key]["instance_id"]:
			return theme_key
	
	# Return an empty string if no match is found
	return ""


## Get the current system time formatted as [code]HH:MM:SS[/code].
func get_current_system_time() -> String:
	var time_dict: Dictionary = Time.get_time_dict_from_system()
	return "%02d:%02d:%02d" % [time_dict["hour"], time_dict["minute"], time_dict["second"]]


## Appends a log message to [member logs_array] with a timestamp.
func add_log_entry(log_message: String) -> void:
	logs_array.append("[%s] %s" % [get_current_system_time(), log_message])


#FIXME: Change to get and set methods?
## Returns [member logs_array]. [br]
##
## [br]
##
## Returns the array of log messages.
func get_logs_array() -> Array:
	return logs_array


#FIXME: Add docs
func _load_progress_bar_assets() -> void:
	var dir: DirAccess = DirAccess.open(PROGRESS_BAR_ASSETS_PATH)
	
	# If opening the directory failed
	if dir == null:
		print("Error opening directory: %s" % dir.get_open_error())
		return
	
	# Get sub-folders
	var theme_folders: PackedStringArray = dir.get_directories()
	
	# Loop trough sub-folders
	for theme in theme_folders:
		
		#FIXME Check if theme exists 
		if available_themes.has(theme):
			var theme_folder_path: String = PROGRESS_BAR_ASSETS_PATH.path_join(theme)
			
			var assets_dict: Dictionary = {}
			
			# Loop trough assets within sub-folder
			for asset in DirAccess.get_files_at(theme_folder_path):
				
				# Only needed when testing in editor
				if asset.ends_with(".import"):
					continue
				
				var texture: String = asset.split(".png")[0]
				
				var asset_path: String = theme_folder_path.path_join(asset)
				assets_dict[texture] = load(asset_path)
			
			print(assets_dict)
			Data.available_themes[theme]["progress_bar"] = assets_dict	
				
			
		


## Handles the addition of push-ups to the total count. [br]
##
## [br]
##
## Updates the total push-ups completed today, increments the session count,
## and adjusts the remaining push-ups to reach the daily goal.
## Ensures the remaining push-ups do not go below zero.
func _on_pushups_added() -> void:
	total_pushups_today += pushups_per_session
	sessions_completed_today += 1
	
	pushups_remaining_today = daily_pushups_goal - total_pushups_today
	# Set remaining push-ups to 0, if daily goal is reached
	if pushups_remaining_today <= 0:
		pushups_remaining_today = 0
