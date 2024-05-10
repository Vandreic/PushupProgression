## Handles the saving, loading, and resetting of user progression data and settings.
##
## This class manages all user progression data and settings, which include daily goals, 
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
## • [method save_data]: Saves current state to a file. [br]
## • [method load_data]: Loads saved data into the application. [br]
## • [method reset_data]: Resets data based on the specified parameter. 
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
## Path: [code]res://scenes/main/utilities/save_system.gd[/code]


class_name SaveSystem
extends Node


## File-path for storing save file.
const SAVE_FILE_PATH: String = "user://"
## Name of save file.
const SAVE_FILE: String = "savedata.json"


## Absolute, native OS path corresponding to the localized [code]user://[/code] ([constant SAVE_FILE_PATH]).
var native_os_save_file_path: String = ProjectSettings.globalize_path(SAVE_FILE_PATH+SAVE_FILE)


## Save user progression and settings. [br]
##
## [br]
##
## Converts [member GlobalVariables.user_data_dict] to JSON format and saves locally
## as [code]savedata.json[/code] ([constant SAVE_FILE]) at [code]user://[/code] 
## ([constant SAVE_FILE_PATH]). [br]
##
## [br]
##
## [b]Note[/b]: When converting to JSON, all data types are transformed into JSON strings.
func save_data() -> void:
	add_log_entry("Opening save file...")
	# Open the save file for writing
	var save_file = _open_save_file(FileAccess.WRITE)
	
	# Log error, notify user, and exit on file open failure
	if save_file is String:
		add_log_entry("Error opening save file. " + save_file)
		var notification_text: String = "Error opening save file\n" + "See logs for more details."
		GlobalVariables.create_notification(notification_text, true)
		return
	
	# Save data to user data dict
	_save_settings()
	_save_progression_for_current_day()
	
	# Convert the user data dictionary to a JSON string
	add_log_entry("Converting data to JSON.")
	var json_string = JSON.stringify(GlobalVariables.user_data_dict, "\t")
	
	# Write the JSON string to the save file as a new line
	add_log_entry("Writing data to \"%s\" at \"%s\"." % [SAVE_FILE, native_os_save_file_path])
	save_file.store_line(json_string)
	
	# Log and notify user
	add_log_entry("Data saved successfully.")
	GlobalVariables.create_notification("Saved successfully!")


## Load saved user progression and settings. [br]
##
## [br]
##
## Loads save data from [constant GlobalVariables.SAVE_FILE] at the specified path
## [constant GlobalVariables.SAVE_FILE_PATH], converts it from JSON string to 
## Godot data types and saves it to [member GlobalVariables.user_data_dict]. [br]
##
## [br]
##
## If no save file exsists, create a save file using [method create_save_file] and exit function.
func load_data() -> void:
	add_log_entry("Opening save file...")
	
	# Create save file, if none exists and exit
	if not FileAccess.file_exists(SAVE_FILE_PATH + SAVE_FILE):
		_create_save_file()
		return
	
	# Open the save file for reading
	var save_file = _open_save_file(FileAccess.READ)
	
	# Log error, notify user, and exit on file open failure
	if save_file is String:
		add_log_entry("Error opening save file. " + save_file)
		var notification_text: String = "Error opening save file\n" + "See logs for more details."
		GlobalVariables.create_notification(notification_text, true)
		return

	# Create JSON helper
	var json = JSON.new()
	
	# Get JSON text from save file
	add_log_entry("Receiving data from save file.")
	var json_string = save_file.get_as_text()
	
	# Convert JSON text
	add_log_entry("Converting data from save file.")
	var save_file_data = JSON.parse_string(json_string)
	
	# Log error, notify user, and exit on JSON convertion error
	if save_file_data == null:
		var error_message: String = "JSON Parse Error: %s in %s at line %s" % [json.get_error_message(), json_string, json.get_error_line()]
		add_log_entry("Error converting data from save file. " + error_message)
		var notification_text: String = "Error converting data from save file\n" + "See logs for more details."
		GlobalVariables.create_notification(notification_text, true)
		return
	
	# If save data is dictionary, load settings and convert save data
	if save_file_data is Dictionary:
		# Load settings from save file
		_load_settings(save_file_data["settings"])
		
		# Format 'calendar' dictionary key from save file from JSON to Godot data types
		var calendar_dict: Dictionary = format_progression_data(save_file_data["calendar"])
		
		# Save calendar dictionary to user data dictionary
		GlobalVariables.user_data_dict["calendar"] = calendar_dict["calendar"]
		
		# Get current date as dictionary from system
		var current_date_dict: Dictionary = Time.get_date_dict_from_system()
		var current_year: int = current_date_dict["year"]
		var current_month: int = current_date_dict["month"]
		var current_day: int = current_date_dict["day"]
		
		# Load progress data for current day, if progress exists
		if calendar_dict["calendar"].has(current_year):
			if calendar_dict["calendar"][current_year].has(current_month):
				if calendar_dict["calendar"][current_year][current_month].has(current_day):
					# Load saved progress data for current day
					_load_progression_for_current_day(calendar_dict["calendar"][current_year][current_month][current_day])
				# Else, ensure calendar structure for current day
				else:
					_ensure_calendar_structure(current_year, current_month, current_day)
		
		# Add log and notify user
		add_log_entry("Loaded data from save file successfully.")
		GlobalVariables.create_notification("Loaded successfully!")


## Resets progression data based on the provided [param reset_option]. [br]
##
## [br]
##
## [param reset_option] parameters: [br]
## • [code]current_day[/code]: Clears today's progression. [br]
## • [code]current_month[/code]: Clears this month's progression. [br]
## • [code]current_year[/code]: Clears this year's progression. [br]
## • [code]all[/code]: Clears all saved progression.
func reset_data(reset_option: String) -> void:
	add_log_entry("Resetting data with option: [" + reset_option + "].\nThis CANNOT be undone!")
	# Reset global values
	_reset_global_values()
	
	# Get current date as dictionary from system
	var current_date_dict: Dictionary = Time.get_date_dict_from_system()
	var current_year: int = current_date_dict["year"]
	var current_month: int = current_date_dict["month"]
	var current_day: int = current_date_dict["day"]
	
	# Log message template
	var log_message: String = "Successfully data reset for current "
	
	# Check chosen reset option
	match reset_option:
		"current_day":
			# Reset progression for current day
			GlobalVariables.user_data_dict["calendar"][current_year][current_month][current_day].clear()
			add_log_entry(log_message + "day: %s/%s-%s." % [current_day, current_month, current_year])
		
		"current_month":
			GlobalVariables.user_data_dict["calendar"][current_year][current_month].clear()
			add_log_entry(log_message + "month: %s-%s." % [current_month, current_year])
			
		"current_year":
			GlobalVariables.user_data_dict["calendar"][current_year].clear()
			add_log_entry(log_message + "year: %s." % current_year)
		
		"all":
			# Clear saved dictionary
			GlobalVariables.user_data_dict["calendar"].clear()
			add_log_entry("Successfully data reset for all saved progression.")
	
	# Ensure calendar structure
	_ensure_calendar_structure(current_year, current_month, current_day)
	GlobalVariables.create_notification("Reset successfully!")
	# Save data and update UI
	save_data()
	GlobalVariables.update_ui()


## Adds a log entry to [member GlobalVariables.logs_array].
func add_log_entry(message: String) -> void:
	# Get the current system time formatted as "HH:MM:SS"
	var time_stamp: String = _get_current_system_time()
	# Add the full log entry with a timestamp
	var log_entry: String = "[%s] %s" % [time_stamp, message]
	GlobalVariables.logs_array.append(log_entry)


## Get the current system time formatted as "HH:MM:SS".
func _get_current_system_time() -> String:
	var current_time_dict: Dictionary = Time.get_time_dict_from_system()
	return "%02d:%02d:%02d" % [current_time_dict["hour"], current_time_dict["minute"], current_time_dict["second"]]


## Creates a save file at the specified path [constant SAVE_FILE_PATH]. [br]
##
## [br]
##
## It initializes the [member GlobalVariables.user_data_dict] and stores it as a JSON string in the save file.
func _create_save_file() -> void:
	add_log_entry("Creating save file \"%s\" at \"%s\"..." % [SAVE_FILE, native_os_save_file_path])
	# Initialize user data dictionary (Needed to create a new save file)
	_initialize_user_data_dict()
	# Open the save file for writing
	var new_save_file = _open_save_file(FileAccess.WRITE) # Returns string if open failure
	
	# Log error, notify user, and exit on file open failure
	if new_save_file is String:
		add_log_entry("Error creating new save file. \"%s\"." % new_save_file)
		var notification_text: String = "Error creating new save file\n" + "See logs for more details."
		GlobalVariables.create_notification(notification_text, true)
		return
		
	# Convert the user data dictionary to a JSON string
	add_log_entry("Converting data to JSON...")
	var json_string = JSON.stringify(GlobalVariables.user_data_dict, "\t")
	
	# Write the JSON string to the save file as a new line
	new_save_file.store_line(json_string)
	
	# Log and notify user
	add_log_entry("New save file created and data saved successfully.")
	GlobalVariables.create_notification("New save file created successfully!", true)


## Initializes and populates the [member GlobalVariables.user_data_dict] with 
## the current day's progress data and user-specific settings.
func _initialize_user_data_dict() -> void:
	add_log_entry("Creating data dictionary...")
	
	# Get current date as dictionary from system
	var current_date_dict: Dictionary = Time.get_date_dict_from_system()
	# Ensure user data dictionary has a calendar structure for storing progress data
	_ensure_calendar_structure(current_date_dict["year"], current_date_dict["month"], current_date_dict["day"])

	# Set global settings based on current values
	GlobalVariables.user_data_dict["settings"] = {
		"daily_pushups_goal": GlobalVariables.daily_pushups_goal,
		"pushups_per_session": GlobalVariables.pushups_per_session,
		"ui_theme": GlobalVariables.get_theme_name(GlobalVariables.current_ui_theme),
		"ui_theme_index": GlobalVariables.selected_theme_index
	}
	
	add_log_entry("Data dictionary created successfully.")


## Ensures a proper hierarchical calendar structure within [member GlobalVariables.user_data_dict]. [br]
##
## [br]
##
## Initializes necessary year, month, and day dictionaries within the [code]calendar[/code]
## key of [member GlobalVariables.user_data_dict]. This ensures that the required date
## structure is available for saving progress for the current day.
func _ensure_calendar_structure(year: int, month: int, day: int) -> void:
	# Create missing year and month dictionary, if needed
	if not GlobalVariables.user_data_dict["calendar"].has(year):
		GlobalVariables.user_data_dict["calendar"][year] = {}
	if not GlobalVariables.user_data_dict["calendar"][year].has(month):
		GlobalVariables.user_data_dict["calendar"][year][month] = {}
	
	# Create data dict for current day
	GlobalVariables.user_data_dict["calendar"][year][month][day] = _create_data_dict_for_current_day()


## Creates a [Dictionary] containing all relevant data for storing the current day's push-up progress. [br]
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
## the [GlobalVariables] autoload singleton script. The [code]sessions[/code] key
## is initialized as an empty [Dictionary] intended to be filled with session-specific data.
func _create_data_dict_for_current_day() -> Dictionary:
	# Set keys to current values
	var day_dict: Dictionary = {
		"daily_pushups_goal" = GlobalVariables.daily_pushups_goal,
		"pushups_per_session" = GlobalVariables.pushups_per_session,
		"pushups_remaining_today" = GlobalVariables.pushups_remaining_today,
		"total_pushups_today" = GlobalVariables.total_pushups_today,
		"sessions" = {}
	}
	return day_dict


## Opens [constant SAVE_FILE] at the specified path [constant SAVE_FILE_PATH] [br]
##
## [br]
##
## Returns: [br]
## • [code]save_file[/code] ([FileAccess]): If opening the file succeeded, returns the file access object. [br]
## • [code]open_error_message[/code] ([String]): If opening the file failed, returns an error message.
func _open_save_file(file_access: FileAccess.ModeFlags):
	# Open save file with provided access
	var save_file: FileAccess = FileAccess.open(SAVE_FILE_PATH + SAVE_FILE, file_access)
	
	# Return save file if no opening errors, else return open error message
	if save_file != null:
		return save_file
		
	# Return the error message
	var open_error_message: String = _get_file_opening_error_message_as_text(FileAccess.get_open_error())
	return open_error_message


## Generates a user-friendly error message [String] based on the [param file_error] code. [br]
##
## [br]
##
## Returns: [br]
## • [code]error_message_text[/code] ([String]): A descriptive error message corresponding to the error code.
func _get_file_opening_error_message_as_text(file_error: Error) -> String:
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


## Formats [code]calendar[/code] [Dictionary] key from [GlobalVariables.SAVE_FILE] from JSON text to
## Godot data types in a [Dictionary] to be saved in [GlobalVariables.user_data_dict].
func format_progression_data(data_dict) -> Dictionary:
	# Return empty dictionary, is save data is not dictionary
	if data_dict is not Dictionary:
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


## Save user-specific settings to [member GlobalVariables.user_data_dict]. [br]
##
## [br]
##
## Settings include: [br]
## • [member GlobalVariables.current_ui_theme] [br]
## • [member GlobalVariables.selected_theme_index] [br]
## • [member GlobalVariables.daily_pushups_goal] [br]
## • [member GlobalVariables.pushups_per_session]
func _save_settings() -> void:	
	# Get name of current applied theme
	var theme_name: String = GlobalVariables.get_theme_name(GlobalVariables.current_ui_theme)
	# Save settings to user data dictionary
	GlobalVariables.user_data_dict["settings"] = {
		"ui_theme" = theme_name,
		"ui_theme_index" = GlobalVariables.selected_theme_index,
		"daily_pushups_goal" = GlobalVariables.daily_pushups_goal,
		"pushups_per_session" = GlobalVariables.pushups_per_session
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
func _save_progression_for_current_day() -> void:
	# Get current date as dictionary from system
	var current_datetime_dict: Dictionary = Time.get_date_dict_from_system()
	var current_year: int = current_datetime_dict["year"]
	var current_month: int = current_datetime_dict["month"]
	var current_day: int = current_datetime_dict["day"]
	
	# Save progression data to user data dictionary
	GlobalVariables.user_data_dict["calendar"][current_year][current_month][current_day]["daily_pushups_goal"] = GlobalVariables.daily_pushups_goal
	GlobalVariables.user_data_dict["calendar"][current_year][current_month][current_day]["pushups_per_session"] = GlobalVariables.pushups_per_session
	GlobalVariables.user_data_dict["calendar"][current_year][current_month][current_day]["pushups_remaining_today"] = GlobalVariables.pushups_remaining_today
	GlobalVariables.user_data_dict["calendar"][current_year][current_month][current_day]["total_pushups_today"] = GlobalVariables.total_pushups_today
	
	# Save session details
	if GlobalVariables.sessions_completed_today > 0:
		# Define current session name
		var current_session: String = "session_" + str(GlobalVariables.sessions_completed_today)
		# Save push-ups and time for current session
		GlobalVariables.user_data_dict["calendar"][current_year][current_month][current_day]\
		["sessions"][current_session] = {
			"pushups" = GlobalVariables.pushups_per_session,
			"time" = _get_current_system_time()
		}


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
func _load_settings(saved_settings_dict: Dictionary) -> void:
	# Set selected theme index
	GlobalVariables.selected_theme_index = int(saved_settings_dict["ui_theme_index"])
	
	# Set and apply theme from available themes
	for theme in GlobalVariables.available_themes:
		if saved_settings_dict["ui_theme"] == theme:
			GlobalVariables.current_ui_theme = GlobalVariables.available_themes[theme]["theme"]
			GlobalVariables.apply_current_ui_theme()
			
	# Load daily pushups goal
	GlobalVariables.daily_pushups_goal = int(saved_settings_dict["daily_pushups_goal"])
	# Load pushups per session
	GlobalVariables.pushups_per_session = int(saved_settings_dict["pushups_per_session"])


## Load progression data for the current day from the provided [param saved_current_day_dict]. [br]
##
## [br]
##
## [param saved_current_day_dict] includes: [br]
## • [code]pushups_remaining_today[/code] ([int]): Remaining push-ups needed to meet the daily goal. [br]
## • [code]total_pushups_today[/code] ([int]): Total number of push-ups completed throughout the day. [br]
## • [code]sessions[/code] ([Dictionary]): A nested [Dictionary] storing detailed session data. [br]
##
## [br]
##
## Progression data is stored in the global singleton [GlobalVariables].
func _load_progression_for_current_day(saved_current_day_dict: Dictionary) -> void:	
	# Update global values
	GlobalVariables.pushups_remaining_today = saved_current_day_dict["pushups_remaining_today"]
	GlobalVariables.total_pushups_today = saved_current_day_dict["total_pushups_today"]
	GlobalVariables.sessions_completed_today = int(saved_current_day_dict["sessions"].size())
	
	# Get current date as dictionary from system
	var current_date_dict: Dictionary = Time.get_date_dict_from_system()
	var current_year: int = current_date_dict["year"]
	var current_month: int = current_date_dict["month"]
	var current_day: int = current_date_dict["day"]
	
	# Update progress for current day in user data dictionary
	GlobalVariables.user_data_dict["calendar"][current_year][current_month][current_day] = {
		"daily_pushups_goal" = saved_current_day_dict["daily_pushups_goal"],
		"pushups_per_session" = saved_current_day_dict["pushups_per_session"],
		"pushups_remaining_today" = saved_current_day_dict["pushups_remaining_today"],
		"total_pushups_today" = saved_current_day_dict["total_pushups_today"],
		"sessions" = saved_current_day_dict["sessions"]
	}


## Reset global values. [br]
##
## [br]
##
## Global values include: [br]
## • [member GlobalVariables.total_pushups_today] [br]
## • [member GlobalVariables.sessions_completed_today] [br]
## • [member GlobalVariables.pushups_remaining_today]
func _reset_global_values() -> void:
	GlobalVariables.total_pushups_today = 0
	GlobalVariables.sessions_completed_today = 0
	GlobalVariables.pushups_remaining_today = 0
