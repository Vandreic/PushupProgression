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
## - [method save_data]: Saves current state to a file. [br]
## - [method load_data]: Loads saved data into the application. [br]
## - [method reset_data]: Resets data based on the specified parameter. 
## Options include [code]current_day[/code], [code]current_month[/code],
## [code]current_year[/code], and [code]all[/code], which clear the respective data. [br]
##
## [br]
##
## File storage: [br]
## - Save file path is defined by [constant SAVE_FILE_PATH] and [constant SAVE_FILE]. [br]
##
## [br]
##
## Path: [code]res://src/utilities/save_system.gd[/code]


class_name SaveSystem
extends Node


## File-path for storing save file.
const SAVE_FILE_PATH: String = "user://"
## Name of save file.
const SAVE_FILE: String = "savedata.json"


## Get the current system time formatted as "HH:MM:SS".
func get_current_system_time() -> String:
	# Get the current system time formatted as "HH:MM:SS"
	var current_time_dict: Dictionary = Time.get_time_dict_from_system()
	return "%02d:%02d:%02d" % [current_time_dict["hour"], current_time_dict["minute"], current_time_dict["second"]]


## Adds a log entry to [member GlobalVariables.logs_array].
func add_log_entry(message: String) -> void:
	# Get the current system time formatted as "HH:MM:SS"
	var current_time_dict: Dictionary = Time.get_time_dict_from_system()
	var time_stamp: String = get_current_system_time()
	
	# Add the full log entry with a timestamp
	var log_entry: String = "[%s] %s" % [time_stamp, message]
	GlobalVariables.logs_array.append(log_entry)


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
func create_data_dict_for_current_day() -> Dictionary:
	var day_dict: Dictionary = {}
	day_dict["daily_pushups_goal"] = GlobalVariables.daily_pushups_goal
	day_dict["pushups_per_session"] = GlobalVariables.pushups_per_session
	day_dict["pushups_remaining_today"] = GlobalVariables.pushups_remaining_today
	day_dict["total_pushups_today"] = GlobalVariables.total_pushups_today
	day_dict["sessions"] = {}
	return day_dict


## Initializes and populates the [member GlobalVariables.user_data_dict] with 
## the current day's progress data and user-specific settings.
func initialize_user_data_dict() -> void:
	# Log the start of the dictionary creation process
	add_log_entry("Creating data dictionary.")

	# Get the current date and time from the system and store it in variables
	var current_time_dict: Dictionary = Time.get_datetime_dict_from_system()
	var current_year: int = current_time_dict["year"]
	var current_month: int = current_time_dict["month"]
	var current_day: int = current_time_dict["day"]
	
	# Initialize a nested dictionary structure to organize data by calendar date
	var calendar_dict: Dictionary = {}
	calendar_dict[current_year] = {}
	calendar_dict[current_year][current_month] = {}
	calendar_dict[current_year][current_month][current_day] = create_data_dict_for_current_day()
	
	# Update the global user data dictionary with the new calendar structure
	GlobalVariables.user_data_dict["calendar"] = calendar_dict

	# Set global settings based on current values, ensuring they are saved and can be reloaded
	GlobalVariables.user_data_dict["settings"] = {
		"daily_pushups_goal": GlobalVariables.daily_pushups_goal,
		"pushups_per_session": GlobalVariables.pushups_per_session
	}
	
	# Log successful creation of the data dictionary
	add_log_entry("Data dictionary created successfully.")


## Opens [constant SAVE_FILE] at the specified path [constant SAVE_FILE_PATH]
## [br]
##
## [br]
##
## Returns: [br]
## • [code]save_file[/code] ([FileAccess]): If opening the file succeeded, returns the file access object. [br]
## • [code]open_error_message[/code] ([String]): If opening the file failed, returns an error message.
func open_save_file(file_access: FileAccess.ModeFlags):
	# Open save file with provided access
	var save_file: FileAccess = FileAccess.open(SAVE_FILE_PATH + SAVE_FILE, file_access)
	
	# Return save file if no opening errors, else return open error message
	if save_file != null:
		return save_file
		
	# Return the error message
	var open_error_message: String = get_file_opening_error_message_as_string(FileAccess.get_open_error())
	return open_error_message


## Creates a save file at the specified path [constant SAVE_FILE_PATH]. [br]
##
## [br]
##
## It initializes the [member GlobalVariables.user_data_dict] and stores it as a JSON string in the save file.
func create_save_file() -> void:
	# Log entry for creating a save file
	add_log_entry("Creating save file: " + SAVE_FILE + " at " + SAVE_FILE_PATH)
	# Initialize user data dictionary (Needed to create a new save file)
	initialize_user_data_dict()
	# Open the save file for writing
	var new_save_file = open_save_file(FileAccess.WRITE)
	
	# Log error, notify user, and exit on file open failure
	if new_save_file is String:
		add_log_entry("Error creating new save file. " + new_save_file)
		var notification_text: String = "Error creating new save file\n" + "See logs for more details."
		GlobalVariables.create_notification(notification_text, true)
		return
		
	# Convert the user data dictionary to a JSON string
	var json_string = JSON.stringify(GlobalVariables.user_data_dict, "\t")
	
	# Write the JSON string to the save file
	new_save_file.store_line(json_string)
	
	# Log and notify successful creation of the save file
	add_log_entry("New save file created and data saved successfully.")
	GlobalVariables.create_notification("New save file created successfully!", true)


## Generates a user-friendly error message [String] based on the [param file_error] code. [br]
##
## [br]
##
## Returns: [br]
## • [code]error_message_text[/code] ([String]): A descriptive error message corresponding to the error code.
func get_file_opening_error_message_as_string(file_error: Error) -> String:
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


## Save user-specific settings to [member GlobalVariables.user_data_dict]. [br]
##
## [br]
##
## Settings include: [br]
## • [member GlobalVariables.current_ui_theme] [br]
## • [member GlobalVariables.selected_theme_index] [br]
## • [member GlobalVariables.daily_pushups_goal] [br]
## • [member GlobalVariables.pushups_per_session]
func save_settings_to_user_data_dict() -> void:
	# Get name of current applied theme
	var theme_name: String = GlobalVariables.get_theme_name(GlobalVariables.current_ui_theme)
	# Save settings to user data dictionary
	GlobalVariables.user_data_dict["settings"]["ui_theme"] = theme_name
	GlobalVariables.user_data_dict["settings"]["ui_theme_index"] = GlobalVariables.selected_theme_index
	GlobalVariables.user_data_dict["settings"]["daily_pushups_goal"] = GlobalVariables.daily_pushups_goal
	GlobalVariables.user_data_dict["settings"]["pushups_per_session"] = GlobalVariables.pushups_per_session


## Save progression data for current day to [member GlobalVariables.user_data_dict]. [br]
##
## [br]
##
## Progression data include: [br]
## • [member GlobalVariables.daily_pushups_goal] [br]
## • [member GlobalVariables.pushups_per_session] [br]
## • [member GlobalVariables.pushups_remaining_today] [br]
## • [member GlobalVariables.total_pushups_today]
func save_progression_for_current_day_to_user_data_dict() -> void:
	# Get the current date and time from the system and store it in variables
	var current_datetime_dict: Dictionary = Time.get_datetime_dict_from_system()
	var current_year: int = current_datetime_dict["year"]
	var current_month: int = current_datetime_dict["month"]
	var current_day: int = current_datetime_dict["day"]
	# Save progression data to user data dictionary
	GlobalVariables.user_data_dict["calendar"][current_year][current_month][current_day]["daily_pushups_goal"] = GlobalVariables.daily_pushups_goal
	GlobalVariables.user_data_dict["calendar"][current_year][current_month][current_day]["pushups_per_session"] = GlobalVariables.pushups_per_session
	GlobalVariables.user_data_dict["calendar"][current_year][current_month][current_day]["pushups_remaining_today"] = GlobalVariables.pushups_remaining_today
	GlobalVariables.user_data_dict["calendar"][current_year][current_month][current_day]["total_pushups_today"] = GlobalVariables.total_pushups_today
	
	# Check if any sessions
	if GlobalVariables.sessions_completed_today > 0:
		# Get current session number
		var current_session_num: int = GlobalVariables.sessions_completed_today
		# Create current session name
		var current_session: String = "session_" + str(current_session_num)
		
		# Save current session
		GlobalVariables.user_data_dict["calendar"][current_year][current_month][current_day]["sessions"][current_session] = {}
		# Save pushups in session
		GlobalVariables.user_data_dict["calendar"][current_year][current_month][current_day]["sessions"][current_session]["pushups"] = GlobalVariables.pushups_per_session
		
		# Get current system time
		var time_stamp: String = get_current_system_time()
		# Save timestamp for session
		GlobalVariables.user_data_dict["calendar"][current_year][current_month][current_day]["sessions"][current_session]["time"] = time_stamp


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
	add_log_entry("Initiating data to save file.")
	
	# Open the save file for writing
	var save_file = open_save_file(FileAccess.WRITE)
	
	# Log error, notify user, and exit on file open failure
	if save_file is String:
		add_log_entry("Error opening save file. " + save_file)
		var notification_text: String = "Error opening save file\n" + "See logs for more details."
		GlobalVariables.create_notification(notification_text, true)
		return
	
	# Save settings to user data dictionary
	save_settings_to_user_data_dict()
	# Save progression for current day to user data dictionary
	save_progression_for_current_day_to_user_data_dict()
	
	add_log_entry("Converting data to JSON.")
	# Convert save data dictionary to JSON
	var json_string = JSON.stringify(GlobalVariables.user_data_dict, "\t")
	
	add_log_entry("Writing data to " + SAVE_FILE + " at " + SAVE_FILE_PATH + ".")
	# Store the save data dictionary as a new line in the save file
	save_file.store_line(json_string)
	
	# Create log
	add_log_entry("Data saved successfully.")
	# Create notification
	GlobalVariables.create_notification("Saved successfully!")


## Load settings. [br][br]
## Loads user settings from the provided [param saved_settings_dict]
func load_settings(saved_settings_dict: Dictionary) -> void:
	# Set selected theme index
	GlobalVariables.selected_theme_index = int(saved_settings_dict["ui_theme_index"])
	
	# Loop trough themes
	for theme in GlobalVariables.available_themes:
		# Set current theme to corresponding theme
		if saved_settings_dict["ui_theme"] == theme:
			GlobalVariables.current_ui_theme = GlobalVariables.available_themes[theme]["theme"]
			# Apply theme
			GlobalVariables.apply_current_ui_theme()
			
	# Load daily pushups goal
	GlobalVariables.daily_pushups_goal = int(saved_settings_dict["daily_pushups_goal"])
	# Load pushups per session
	GlobalVariables.pushups_per_session = int(saved_settings_dict["pushups_per_session"])


## Load current day's data from the provided [param saved_current_day_dict].
func load_data_for_current_day(saved_current_day_dict) -> void:	
	# Load remaining pushups
	GlobalVariables.pushups_remaining_today = saved_current_day_dict["pushups_remaining_today"]
	# Load total pushups
	GlobalVariables.total_pushups_today = saved_current_day_dict["total_pushups_today"]
	# Load total sessions
	GlobalVariables.sessions_completed_today = int(saved_current_day_dict["sessions"].size())


## Load saved progression. [br][br]
## Load data from save file, convert it to [Dictionary], and store it in 
## [member GlobalVariables.user_data_dict].
##
## [br]
## 
## Save file path: [constant SaveSystem.SAVE_FILE_PATH] [br]
##
## [br]
##
## [b]Note:[/b] Converts some keys from JSON strings to Godot data types.
func load_data() -> void:
	add_log_entry("Loading data from save file.")
	
	# Create save file, if none exists
	if not FileAccess.file_exists(SAVE_FILE_PATH + SAVE_FILE):
		create_save_file()
		return
	
	# Load save file
	var save_file = FileAccess.open(SAVE_FILE_PATH + SAVE_FILE, FileAccess.READ)	
	
	# Check for file errors
	if save_file == null:
		# Get error text
		var error_text: String = get_file_opening_error_message_as_string(FileAccess.get_open_error())
		# Create log
		add_log_entry("Error opening save file. " + error_text)
		# Create notification text
		var notification_text: String = "Error opening save file.\n" + "See logs for more details."
		# Create notification with extended duration
		GlobalVariables.create_notification(notification_text, true)
		return

	# Create JSON helper
	var json = JSON.new()
	
	add_log_entry("Receiving data from save file.")
	# Get JSON text from save file
	var json_string = save_file.get_as_text()
	
	add_log_entry("Converting data from save file.")
	# Parse (convert) JSON text
	var save_file_data = JSON.parse_string(json_string)
	
	# If parse (convert) error occurs
	if save_file_data == null:
		# Create error message
		var error_message: String = "JSON Parse Error: " + str(json.get_error_message())\
		+ " in " + str(json_string) + " at line " + str(json.get_error_line())
		# Create log
		add_log_entry("Error converting data from save file. " + error_message)
		# Create notification text
		var notification_text: String = "Error converting data from save file\n" + "See logs for more details."
		# Create notification with extended duration
		GlobalVariables.create_notification(notification_text, true)
		return
	
	# If save data is dictionary, create copy 
	if save_file_data is Dictionary:
		# Get settings dictionary
		var settings_dict: Dictionary = save_file_data["settings"]
		# Load settings
		load_settings(settings_dict)
		
		# Create years dictionary
		var years_dict: Dictionary = {}
		
		# Create new dictionary for each year.
		for year in save_file_data["calendar"]:
			years_dict[int(year)] = {}
			
			# Create new dictionary for each month
			for month in save_file_data["calendar"][year]:
				years_dict[int(year)][int(month)] = {}
				
				# Create new dictionary for each day
				for day in save_file_data["calendar"][year][month]:
					years_dict[int(year)][int(month)][int(day)] = {}
					
					# Get daily goal from saved data
					var daily_goal: int = int(save_file_data["calendar"][year][month][day]["daily_pushups_goal"])
					# Save daily goal to new calendar dictionary
					years_dict[int(year)][int(month)][int(day)]["daily_pushups_goal"] = daily_goal
					
					# Get pushups per session
					var pushups_per_session: int = int(save_file_data["calendar"][year][month][day]["pushups_per_session"])
					# Save pushups per session
					years_dict[int(year)][int(month)][int(day)]["pushups_per_session"] = pushups_per_session
					
					# Get remaining pushups
					var pushups_remaining_today: int = int(save_file_data["calendar"][year][month][day]["pushups_remaining_today"])
					# Save remaining pushups
					years_dict[int(year)][int(month)][int(day)]["pushups_remaining_today"] = pushups_remaining_today
					
					# Get total pushups
					var total_pushups_today: int = int(save_file_data["calendar"][year][month][day]["total_pushups_today"])
					# Save total pushups
					years_dict[int(year)][int(month)][int(day)]["total_pushups_today"] = total_pushups_today
					
					# Create sessions dictionary
					var sessions_dict: Dictionary = {}
					# Loop trough each session
					for session in save_file_data["calendar"][year][month][day]["sessions"]:
						# Create single session dictionary
						sessions_dict[session] = {}
						
						# Get pushups in session
						var pushups: int = int(save_file_data["calendar"][year][month][day]["sessions"][session]["pushups"])
						# Save pushups
						sessions_dict[session]["pushups"] = pushups
						
						# Get timestamp in session
						var time: String = save_file_data["calendar"][year][month][day]["sessions"][session]["time"]
						# Save timestamp
						sessions_dict[session]["time"] = time
						
					# Add sessions dictionary to calendar
					years_dict[int(year)][int(month)][int(day)]["sessions"] = sessions_dict
		
		# Get datetime dictionary from system
		var datetime_dict: Dictionary = Time.get_datetime_dict_from_system()
		# Get current year number
		var current_year: int = datetime_dict["year"]
		# Get current month number
		var current_month: int = datetime_dict["month"]
		# Get current day number
		var current_day: int = datetime_dict["day"]
		
		# Create dictionary if none exist for current year
		if not save_file_data["calendar"].has(str(current_year)):
			# Create dictionary for current year
			years_dict[current_year] = {}
			# Create dictionary for current month
			years_dict[current_year][current_month] = {}
			# Create dictionary for current day
			years_dict[current_year][current_month][current_day] = {}
			# Create dictionary for the current day's data.
			years_dict[current_year][current_month][current_day] = create_data_dict_for_current_day()
			
		# Create dictionary if none exist for current month
		elif not save_file_data["calendar"][str(current_year)].has(str(current_month)):
			# Create dictionary for current month
			years_dict[current_year][current_month] = {}
			# Create dictionary for current day
			years_dict[current_year][current_month][current_day] = {}
			# Create dictionary for the current day's data.
			years_dict[current_year][current_month][current_day] = create_data_dict_for_current_day()
		
		# Create dictionary if none exist for current day	
		elif not save_file_data["calendar"][str(current_year)][str(current_month)].has(str(current_day)):
			# Create dictionary for current day
			years_dict[current_year][current_month][current_day] = {}
			# Create dictionary for the current day's data.
			years_dict[current_year][current_month][current_day] = create_data_dict_for_current_day()
			
		# Load saved data, if dictionary for current date exists
		else:
			load_data_for_current_day(years_dict[current_year][current_month][current_day])
		
		# Save created dictionary to user_data_dict
		GlobalVariables.user_data_dict["calendar"] = years_dict
		
		# Create log
		add_log_entry("Loaded data from save file successfully.")
		# Create notification
		GlobalVariables.create_notification("Loaded successfully!")


## Reset global values. [br]
##
## [br]
##
## Global values include: [br]
## • [member GlobalVariables.total_pushups_today] [br]
## • [member GlobalVariables.sessions_completed_today] [br]
## • [member GlobalVariables.pushups_remaining_today]
func reset_global_values() -> void:
	# Reset total pushups
	GlobalVariables.total_pushups_today = 0
	# Reset total sessions
	GlobalVariables.sessions_completed_today = 0
	# Reset remaining pushups
	GlobalVariables.pushups_remaining_today = 0


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
	reset_global_values()
	
	# Get datetime as dictionary from system
	var datetime_dict: Dictionary = Time.get_datetime_dict_from_system()
	# Get current year
	var current_year: int = datetime_dict["year"]
	# Get current month number
	var current_month: int = datetime_dict["month"]
	# Get current day number
	var current_day: int = datetime_dict["day"]
	
	# Check chosen reset option
	match reset_option:
		"current_day":
			# Reset progression for current day
			GlobalVariables.user_data_dict["calendar"][current_year][current_month][current_day].clear()
			# Create sessions dictionary for current date
			GlobalVariables.user_data_dict["calendar"][current_year][current_month][current_day]["sessions"] = {}
			add_log_entry("Successfully data reset for current day: %s/%s-%s." % [current_day, current_month, current_year])
		
		"current_month":
			GlobalVariables.user_data_dict["calendar"][current_year][current_month].clear()
			# Create new dictionary for current date
			GlobalVariables.user_data_dict["calendar"][current_year][current_month][current_day] = {}
			# Create sessions dictionary for current date
			GlobalVariables.user_data_dict["calendar"][current_year][current_month][current_day]["sessions"] = {}
			add_log_entry("Successfully data reset for current month: /%s-%s." % [current_month, current_year])
			
		"current_year":
			add_log_entry("Resetting saved progression for current year.")
			GlobalVariables.user_data_dict["calendar"][current_year].clear()
			# Create new dictionary for current date
			GlobalVariables.user_data_dict["calendar"][current_year][current_month] = {}
			GlobalVariables.user_data_dict["calendar"][current_year][current_month][current_day] = {}
			# Create sessions dictionary for current date
			GlobalVariables.user_data_dict["calendar"][current_year][current_month][current_day]["sessions"] = {}
			add_log_entry("Successfully data reset for current year: %s." % current_year)
		
		"all":
			add_log_entry("Resetting all saved progression.")
			# Clear saved dictionary
			GlobalVariables.user_data_dict["calendar"].clear()
			# Create new dictionary for current date
			GlobalVariables.user_data_dict["calendar"][current_year] = {}
			GlobalVariables.user_data_dict["calendar"][current_year][current_month] = {}
			GlobalVariables.user_data_dict["calendar"][current_year][current_month][current_day] = {}
			# Create sessions dictionary for current date
			GlobalVariables.user_data_dict["calendar"][current_year][current_month][current_day]["sessions"] = {}
			add_log_entry("Successfully data reset for all saved progression.")
		
		_:
			add_log_entry("Unsupported reset option: " + reset_option)

	# Create notification
	GlobalVariables.create_notification("Reset successfully!")
	# Save data
	save_data()
	# Update UI
	GlobalVariables.update_ui()
