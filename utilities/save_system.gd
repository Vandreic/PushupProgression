class_name SaveSystem
extends Node


## Handles the saving, loading, and resetting of user progression data and settings.
##
## Manages all user progression data and settings, which include daily goals, 
## session details, and customizable settings, stored in [member GlobalVariables.user_data_dict]. [br]
##
## [br]
##
## All data is converted into JSON format and saved locally as [code]savedata.json[/code]
## ([constant SAVE_FILE]) at [code]user://[/code] ([constant SAVE_FILE_PATH]). [br]
##
## [br]
##
## Usage: [br]
## • [method save_data]: Saves current data to a file. [br]
## • [method load_data]: Loads saved data into the application. [br]
## • [method reset_data]: Resets progress data based on the specified parameter. 
## Options include [code]current_day[/code], [code]current_month[/code],
## [code]current_year[/code], and [code]all[/code], which clear the respective data. [br]
## • [method add_log_entry]: Adds a log entry to [member GlobalVariables.logs_array]. [br]
##
## [br]
##
## File storage: [br]
## - Save file path is defined by [constant SAVE_FILE_PATH] and [constant SAVE_FILE]. [br]
##
## [br]
##
## Path: [code]res://scripts/utilities/save_system.gd[/code]


## File-path for storing save file.
const SAVE_FILE_PATH: String = "user://"
## Name of save file.
const SAVE_FILE: String = "savedata.json"


## Absolute, native OS path corresponding to the localized [code]user://[/code] ([constant SAVE_FILE_PATH]).
static var native_os_save_file_path: String = ProjectSettings.globalize_path(SAVE_FILE_PATH+SAVE_FILE)


## Connect to [EventBus]'s signals when node is ready.
func _ready() -> void:
	EventBus.save_data_requested.connect(_on_save_data_requested)
	EventBus.load_data_requested.connect(_on_load_data_requested)
	EventBus.reset_data_requested.connect(_on_reset_data_requested)


## Save user progression and settings. [br]
##
## [br]
##
## Converts [member GlobalVariables.user_data_dict] to JSON format and saves locally
## as [code]savedata.json[/code] ([constant SAVE_FILE]) at [code]user://[/code] 
## ([constant SAVE_FILE_PATH]). [br]
static func _on_save_data_requested() -> void:
	Data.add_log_entry("Opening save file.")
	# Open the save file for writing
	var save_file = _open_save_file(FileAccess.WRITE) # Returns  error message if file fails to open
	
	# Log error, notify user, and exit on file open failure
	if save_file is String:
		Data.add_log_entry("Error opening save file. " + save_file)
		var notification_text: String = "Error opening save file\n" + "See logs for more details."
		EventBus.create_notification_requested.emit(notification_text, true)
		return
	
	# Save data to user data dict
	_save_settings()
	_save_progression_for_current_day()
	
	# Convert the user data dictionary to a JSON string
	Data.add_log_entry("Converting data to JSON.")
	var json_string = JSON.stringify(Data.user_data_dict, "\t")
	
	# Write the JSON string to the save file as a new line
	Data.add_log_entry("Writing data to \"%s\" at \"%s\"" % [SAVE_FILE, native_os_save_file_path])
	save_file.store_line(json_string)
	
	# Log and notify user
	Data.add_log_entry("Data saved successfully!")
	EventBus.create_notification_requested.emit("Saved successfully!", false)


## Load saved user progression and settings. [br]
##
## [br]
##
## Loads save data from [constant SAVE_FILE] at the specified path
## [constant SAVE_FILE_PATH], converts it from JSON string to 
## Godot data types and saves it to [member user_data_dict]. [br]
##
## [br]
##
## If no save file exsists, create a save file using [method create_save_file] and exit function.
static func _on_load_data_requested() -> void:
	Data.add_log_entry("Opening save file.")
	
	# Create save file, if none exists and exit
	if not FileAccess.file_exists(SAVE_FILE_PATH + SAVE_FILE):
		var _message: String = "No existing save file found."
		Data.add_log_entry(_message)
		EventBus.create_notification_requested.emit(_message, true)
		_create_save_file()
		return
	
	# Open the save file for reading
	var save_file = _open_save_file(FileAccess.READ) # Returns  error message if file fails to open
	
	# Log error, notify user, and exit on file open failure
	if save_file is String:
		Data.add_log_entry("Error opening save file.\n" + save_file)
		var notification_text: String = "Error opening save file\n" + "See logs for more details."
		EventBus.create_notification_requested.emit(notification_text, true)
		return

	# Create JSON helper
	var json = JSON.new()
	
	# Get JSON text from save file
	Data.add_log_entry("Receiving JSON data from save file.")
	var json_string = save_file.get_as_text()
	
	# Convert JSON text to string
	Data.add_log_entry("Converting JSON data to Godot string.")
	var save_file_data = JSON.parse_string(json_string)
	
	# Log error, notify user, and exit on JSON convertion error
	if save_file_data == null:
		var error_message: String = "JSON Parse Error: %s in %s at line %s"\
		% [json.get_error_message(), json_string, json.get_error_line()]
		Data.add_log_entry("Error converting data from save file. " + error_message)
		
		var notification_text: String = "Error converting data from save file\n" + "See logs for more details."
		EventBus.create_notification_requested.emit(notification_text, true)
		return
	
	# If save data is dictionary, load user progression and settings
	if save_file_data is Dictionary:
		# Load settings from save file
		_load_settings(save_file_data["settings"])
		
		# Convert the "calendar" key from the save file into a structured dictionary
		var calendar_dict: Dictionary = _convert_calendar_json_to_dict(save_file_data["calendar"])
		
		# Save calendar dictionary to user data dictionary
		Data.user_data_dict["calendar"] = calendar_dict["calendar"]
		
		# Get current date as dictionary from system
		var current_date_dict: Dictionary = Time.get_date_dict_from_system()
		var current_year: int = current_date_dict["year"]
		var current_month: int = current_date_dict["month"]
		var current_day: int = current_date_dict["day"]
		
		# Load progress data for current day, if progress exists
		if calendar_dict["calendar"].has(current_year):
			if calendar_dict["calendar"][current_year].has(current_month):
				if calendar_dict["calendar"][current_year][current_month].has(current_day):
					_load_progression_for_current_day(calendar_dict["calendar"][current_year][current_month][current_day])
				# Else, initialize calendar structure for current day
				else:
					_initialize_data_dict_for_current_day(current_year, current_month, current_day)
		
		# Add log and notify user
		Data.add_log_entry("Loaded data from save file successfully!")
		EventBus.create_notification_requested.emit("Loaded successfully!", false)


## Creates a save file at the specified path [constant SAVE_FILE_PATH]. [br]
##
## [br]
##
## It initializes the [member user_data_dict] and stores it as a JSON string in the save file.
static func _create_save_file() -> void:
	var _log_message: String = "Creating save file \"%s\" at \"%s\"" % [SAVE_FILE, native_os_save_file_path]
	Data.add_log_entry(_log_message)
	
	# Initialize user data dictionary (Needed to create a new save file)
	_initialize_user_data_dict()
	
	# Open the save file for writing
	var new_save_file = _open_save_file(FileAccess.WRITE) # Returns string if open failure
	
	# Log error, notify user, and exit on file open failure
	if new_save_file is String:
		Data.add_log_entry("Error creating new save file.\n%s" % new_save_file)
		var notification_text: String = "Error creating new save file\n" + "See logs for more details."
		EventBus.create_notification_requested.emit(notification_text, true)
		return
		
	# Convert the user data dictionary to a JSON string
	Data.add_log_entry("Converting data to JSON...")
	var json_string = JSON.stringify(Data.user_data_dict, "\t")
	
	# Write the JSON string to the save file as a new line
	new_save_file.store_line(json_string)
	
	# Log and notify user
	Data.add_log_entry("New save file created and data saved successfully!")
	EventBus.create_notification_requested.emit("New save file created successfully!", true)


## Initializes and populates the [member GlobalVariables.user_data_dict] with 
## the current day's progress data and user-specific settings.
static func _initialize_user_data_dict() -> void:
	Data.add_log_entry("Creating data dictionary.")
	
	# Get current date as dictionary from system
	var time_dict: Dictionary = Time.get_date_dict_from_system()
	# Initialize user data dictionary for current day
	_initialize_data_dict_for_current_day(time_dict["year"], time_dict["month"], time_dict["day"])
	

	# Set global settings based on current values
	Data.user_data_dict["settings"] = {
		"daily_pushups_goal": Data.daily_pushups_goal,
		"pushups_per_session": Data.pushups_per_session,
		"ui_theme": Data.get_theme_name(Data.current_ui_theme),
		"ui_theme_index": Data.selected_theme_index
	}
	
	Data.add_log_entry("Data dictionary created successfully.")


## Initializes a [Dictionary] to store current day's progression. [br]
##
## [br]
##
## Initializes necessary year, month, and day dictionaries within the [code]calendar[/code]
## key of [member Data.user_data_dict]. This ensures that the required date
## structure is available for saving progress for the current day.
static func _initialize_data_dict_for_current_day(year: int, month: int, day: int) -> void:
	# Create missing year and month dictionary, if needed
	if not Data.user_data_dict["calendar"].has(year):
		Data.user_data_dict["calendar"][year] = {}
	if not Data.user_data_dict["calendar"][year].has(month):
		Data.user_data_dict["calendar"][year][month] = {}
	
	# Create data dictionary for current day
	Data.user_data_dict["calendar"][year][month][day] = _create_data_dict_for_current_day()


## Creates a [Dictionary] containing all relevant data for storing the current day's push-up progress. [br]
##
## [br]
##
## Returns: [br]
## • [code]day_dict[/code] ([Dictionary]): [Dictionary] for storing the current day's push-up progress. [br]
##
## [br]
##
## The dictionary include: [br]
## • [code]daily_pushups_goal[/code] ([int]): The daily goal for push-ups. [br]
## • [code]pushups_per_session[/code] ([int]): Number of push-ups performed per session. [br]
## • [code]pushups_remaining_today[/code] ([int]): Remaining push-ups needed to meet the daily goal. [br]
## • [code]total_pushups_today[/code] ([int]): Total number of push-ups completed throughout the day. [br]
## • [code]sessions[/code] ([Dictionary]): A nested [Dictionary] that can store detailed session data. [br]
##
## [br]
##
## All keys except for the [code]sessions[/code] key are directly populated from 
## the [Data] autoload singleton script. The [code]sessions[/code] key is initialized 
## as an empty [Dictionary] intended to be filled with session-specific data.
static func _create_data_dict_for_current_day() -> Dictionary:
	# Set keys to current values
	var day_dict: Dictionary = {
		"daily_pushups_goal" = Data.daily_pushups_goal,
		"pushups_per_session" = Data.pushups_per_session,
		"pushups_remaining_today" = Data.pushups_remaining_today,
		"total_pushups_today" = Data.total_pushups_today,
		"sessions" = {}
	}
	return day_dict


## Opens save file ([constant SAVE_FILE]) with the given [enum FileAccess.ModeFlags], [param file_access]. [br]
##
## [br]
##
## Returns: [br]
## • [code]save_file[/code] ([FileAccess]): The [FileAccess] object if the file opening was successful. [br]
## • [code]open_error_message[/code] ([String]): An error message if the file opening failed.
static func _open_save_file(file_access: FileAccess.ModeFlags = FileAccess.ModeFlags.READ):
	# Open save file with provided access mode
	var save_file: FileAccess = FileAccess.open(SAVE_FILE_PATH + SAVE_FILE, file_access)
	
	# Return save file if no opening errors, else return open error message
	if save_file != null:
		return save_file
	
	var open_error_message: String = _get_file_opening_error_message_as_text(FileAccess.get_open_error())
	return open_error_message


## Generates a user-friendly error message [String] based on the [param file_error] code. [br]
##
## [br]
##
## Returns: [br]
## • [code]error_message_text[/code] ([String]): A descriptive error message corresponding to the error code.
static func _get_file_opening_error_message_as_text(file_error: Error) -> String:
	# Define error message text
	var error_message_text: String = "Error %s: %s"
	
	# Match the error code to a user-friendly description
	match file_error:
		Error.ERR_FILE_NOT_FOUND:
			return error_message_text % [file_error, "File not found."]
		Error.ERR_FILE_BAD_DRIVE:
			return error_message_text % [file_error, "Invalid drive."]
		Error.ERR_FILE_BAD_PATH:
			return error_message_text % [file_error, "Invalid file path."]
		Error.ERR_FILE_NO_PERMISSION:
			return error_message_text % [file_error, "Permission denied."]
		Error.ERR_FILE_ALREADY_IN_USE:
			return error_message_text % [file_error, "File is in use."]
		Error.ERR_FILE_CANT_OPEN:
			return error_message_text % [file_error, "Unable to open file."]
		Error.ERR_FILE_CANT_WRITE:
			return error_message_text % [file_error, "Unable to write to file."]
		Error.ERR_FILE_CANT_READ:
			return error_message_text % [file_error, "Unable to read file."]
		Error.ERR_FILE_UNRECOGNIZED:
			return error_message_text % [file_error, "Unrecognized file format."]
		Error.ERR_FILE_CORRUPT:
			return error_message_text % [file_error, "Corrupted file."]
		_:
			return error_message_text % [file_error, "Unknown error."]


## Loads user-specific settings from the provided [param saved_settings_dict]. [br]
##
## [br]
##
## Settings include: [br]
## • [code]ui_theme[/code] ([String]): Name of UI theme. [br]
## • [code]ui_theme_index[/code] ([int]): Index of UI theme. [br]
## • [code]daily_pushups_goal[/code] ([int]): The daily goal for push-ups. [br]
## • [code]pushups_per_session[/code] ([int]): Number of push-ups performed per session. [br]
##
## [br]
##
## Settings are stored in the global singleton [GlobalVariables].
static func _load_settings(saved_settings_dict: Dictionary) -> void:
	# Set selected theme index
	Data.selected_theme_index = int(saved_settings_dict["ui_theme_index"])
	
	# Set and apply theme from available themes
	var theme_name: String = saved_settings_dict["ui_theme"]
	if Data.available_themes.has(theme_name):
		Data.current_ui_theme = Data.available_themes[theme_name]["theme"]
		EventBus.apply_ui_theme_requested.emit()
			
	# Load daily pushups goal
	Data.daily_pushups_goal = int(saved_settings_dict["daily_pushups_goal"])
	# Load pushups per session
	Data.pushups_per_session = int(saved_settings_dict["pushups_per_session"])


## Converts the [code]calendar[/code] key from the save file JSON text to a [Dictionary]. [br]
##
## [br]
##
## Return: [br]
## - [Dictionary]: A formatted dictionary containing all saved calendar progressions, 
##   structured like the [code]calendar[/code] key in [member GlobalVariables.user_data_dict]. [br]
##
## [br]
##
## Converts the [code]calendar[/code] key from the save file, which is in JSON
## format, into a [Dictionary] with Godot data types following the same structure
## as [code]calendar[/code] key within [member GlobalVariables.user_data_dict]. [br]
static func _convert_calendar_json_to_dict(data_dict) -> Dictionary:
	# Return empty dictionary, is save data is not dictionary
	if data_dict is not Dictionary:
		Data.add_log_entry("Warning! \"%s\" is not a Dictionary. \
		Unable to convert saved progress data from save file to dictionary.")
		return {}
	
	# Create calendar dictionary
	var calendar_dict: Dictionary = {}
	
	# Create new dictionary for each year.
	for year in data_dict:
		calendar_dict[int(year)] = {}
		
		# Create new dictionary for each month
		for month in data_dict[year]:
			calendar_dict[int(year)][int(month)] = {}
			
			# Create new dictionary for each day
			for day in data_dict[year][month]:
				# Save progression data for current day to dictionary
				calendar_dict[int(year)][int(month)][int(day)] = {
					"daily_pushups_goal" = int(data_dict[year][month][day]["daily_pushups_goal"]),
					"pushups_per_session" = int(data_dict[year][month][day]["pushups_per_session"]),
					"pushups_remaining_today" = int(data_dict[year][month][day]["pushups_remaining_today"]),
					"total_pushups_today" = int(data_dict[year][month][day]["total_pushups_today"]),
					"sessions" = {}
				}
				
				# Loop trough each saved session for the given day 
				for session in data_dict[year][month][day]["sessions"]:
					# Create nested single session dictionary
					calendar_dict[int(year)][int(month)][int(day)]["sessions"][session] = {
						"pushups" = int(data_dict[year][month][day]["sessions"][session]["pushups"]),
						"time" = str(data_dict[year][month][day]["sessions"][session]["time"])
					}
	
	# Return formatted dictionary
	return {"calendar" = calendar_dict}


## Load progression data for the current day from the provided [param saved_current_day_dict]. [br]
##
## [br]
##
## [param saved_current_day_dict] include: [br]
## • [code]pushups_remaining_today[/code] ([int]): Remaining push-ups needed to meet the daily goal. [br]
## • [code]total_pushups_today[/code] ([int]): Total number of push-ups completed throughout the day. [br]
## • [code]sessions[/code] ([Dictionary]): A nested [Dictionary] storing detailed session data. [br]
##
## [br]
##
## Progression data is stored in the global singleton [Data].
static func _load_progression_for_current_day(saved_current_day_dict: Dictionary) -> void:	
	# Update global values
	Data.pushups_remaining_today = saved_current_day_dict["pushups_remaining_today"]
	Data.total_pushups_today = saved_current_day_dict["total_pushups_today"]
	Data.sessions_completed_today = int(saved_current_day_dict["sessions"].size())
	
	# Get current date as dictionary from system
	var time_dict: Dictionary = Time.get_date_dict_from_system()
	var current_year: int = time_dict["year"]
	var current_month: int = time_dict["month"]
	var current_day: int = time_dict["day"]
	
	# Update progress for current day in user data dictionary
	Data.user_data_dict["calendar"][current_year][current_month][current_day] = {
		"daily_pushups_goal" = saved_current_day_dict["daily_pushups_goal"],
		"pushups_per_session" = saved_current_day_dict["pushups_per_session"],
		"pushups_remaining_today" = saved_current_day_dict["pushups_remaining_today"],
		"total_pushups_today" = saved_current_day_dict["total_pushups_today"],
		"sessions" = saved_current_day_dict["sessions"]
	}


## Save user-specific settings to [member GlobalVariables.user_data_dict]. [br]
##
## [br]
##
## Settings include: [br]
## • [member GlobalVariables.current_ui_theme] [br]
## • [member GlobalVariables.selected_theme_index] [br]
## • [member GlobalVariables.daily_pushups_goal] [br]
## • [member GlobalVariables.pushups_per_session]
static func _save_settings() -> void:	
	# Get name of current applied theme
	var theme_name: String = Data.get_theme_name(Data.current_ui_theme)
	# Save settings to user data dictionary
	Data.user_data_dict["settings"] = {
		"ui_theme" = theme_name,
		"ui_theme_index" = Data.selected_theme_index,
		"daily_pushups_goal" = Data.daily_pushups_goal,
		"pushups_per_session" = Data.pushups_per_session
	}


## Save progression data for current day to [member GlobalVariables.user_data_dict]. [br]
##
## [br]
##
## Progression data include: [br]
## • [member GlobalVariables.daily_pushups_goal] [br]
## • [member GlobalVariables.pushups_per_session] [br]
## • [member GlobalVariables.pushups_remaining_today] [br]
## • [member GlobalVariables.total_pushups_today]
static func _save_progression_for_current_day() -> void:
	# Get current date as dictionary from system
	var current_datetime_dict: Dictionary = Time.get_date_dict_from_system()
	var current_year: int = current_datetime_dict["year"]
	var current_month: int = current_datetime_dict["month"]
	var current_day: int = current_datetime_dict["day"]
	
	# Save progression data to user data dictionary
	Data.user_data_dict["calendar"][current_year][current_month][current_day]["daily_pushups_goal"] = Data.daily_pushups_goal
	Data.user_data_dict["calendar"][current_year][current_month][current_day]["pushups_per_session"] = Data.pushups_per_session
	Data.user_data_dict["calendar"][current_year][current_month][current_day]["pushups_remaining_today"] = Data.pushups_remaining_today
	Data.user_data_dict["calendar"][current_year][current_month][current_day]["total_pushups_today"] = Data.total_pushups_today
	
	# Save session details
	if Data.sessions_completed_today > 0:
		# Define current session name
		var current_session: String = "session_" + str(Data.sessions_completed_today)
		# Save push-ups and time for current session
		Data.user_data_dict["calendar"][current_year][current_month][current_day]\
		["sessions"][current_session] = {
			"pushups" = Data.pushups_per_session,
			"time" = Data.get_current_system_time()
		}

	
## Resets progression data based on the provided [param reset_option]. [br]
##
## [br]
##
## [param reset_option] parameters: [br]
## • [code]current_day[/code]: Clears today's progression. [br]
## • [code]current_month[/code]: Clears this month's progression. [br]
## • [code]current_year[/code]: Clears this year's progression. [br]
## • [code]all[/code]: Clears all saved progression.
static func _on_reset_data_requested(reset_option: String) -> void:
	Data.add_log_entry("Resetting data with option: [" + reset_option + "].\nThis CANNOT be undone!")
	# Reset global values
	_reset_global_values()
	
	# Get current date as dictionary from system
	var current_date_dict: Dictionary = Time.get_date_dict_from_system()
	var current_year: int = current_date_dict["year"]
	var current_month: int = current_date_dict["month"]
	var current_day: int = current_date_dict["day"]
	
	# Log message template
	var log_message: String = "Successfully data reset for current "
	
	# Clear progress from user data dictionary based on provided option
	match reset_option:
		"current_day":
			Data.user_data_dict["calendar"][current_year][current_month][current_day].clear()
			Data.add_log_entry(log_message + "day: %02d/%02d-%s." % [current_day, current_month, current_year])
		"current_month":
			Data.user_data_dict["calendar"][current_year][current_month].clear()
			Data.add_log_entry(log_message + "month: %02d-%s." % [current_month, current_year])
		"current_year":
			Data.user_data_dict["calendar"][current_year].clear()
			Data.add_log_entry(log_message + "year: %s." % current_year)
		"all":
			Data.user_data_dict["calendar"].clear()
			Data.add_log_entry("Successfully data reset for all saved progression!")
	
	# Initialize user data dictionary for current day
	_initialize_data_dict_for_current_day(current_year, current_month, current_day)
	EventBus.create_notification_requested.emit("Reset successfully!", false)
	# Save data and update UI
	_on_save_data_requested()
	EventBus.update_ui_requested.emit()


## Reset global values. [br]
##
## [br]
##
## Global values include: [br]
## • [member Data.total_pushups_today] [br]
## • [member Data.sessions_completed_today] [br]
## • [member Data.pushups_remaining_today]
static func _reset_global_values() -> void:
	Data.total_pushups_today = 0
	Data.sessions_completed_today = 0
	Data.pushups_remaining_today = 0
