## Save & load progression.
##
## A save system to save and load progression data. [br]
##
## [br]
##
## Progression data is stored in [member GlobalVariables.user_data_dict], 
## then converted to JSON format and saved to a file. [br] 
## Save file path: [constant SaveSystem.SAVE_GAME_PATH] [br]
##
## [br]
##
## See [method create_user_data_dict] and 
## [method save_data] for more details. [br]
##
## [br]
## 
## Path: [code]res://src/utilities/save_system.gd[/code]


class_name SaveSystem
extends Node


## File-path for storing save file.
const SAVE_GAME_PATH: String = "user://"
## Name of save file.
const SAVE_FILE: String = "savedata.save"


## Create log message.
func create_log_entry(log_message: String) -> void:
	# Get time dictionary from system
	var datetime_dict: Dictionary = Time.get_time_dict_from_system()
	# Get current time
	var hour: String = str(datetime_dict["hour"])
	var minute: String = str(datetime_dict["minute"])
	var second: String = str(datetime_dict["second"])
	
	# Convert hour to "00" format
	if hour.length() < 2:
		var _new_hour_value: String = "0" + hour
		hour = _new_hour_value
		
	# Convert minute to "00" format
	if minute.length() < 2:
		var _new_minute_value: String = "0" + minute
		minute = _new_minute_value

	# Convert second to "00" format
	if second.length() < 2:
		var _new_second_value: String = "0" + second
		second = _new_second_value

	# Create timestamp
	var timestamp: String = "[%s:%s:%s] " % [hour, minute, second]
	# Create full log message
	var full_log_message: String = timestamp + log_message
	# Add to logs array
	GlobalVariables.logs_array.append(full_log_message)


## Create [Dictionary] for the current day's data.
func create_current_day_data_dict() -> Dictionary:
	# Initialize dictionary for current day
	var day_dict: Dictionary = {}
	# Add daily goal to dictionary
	day_dict["daily_pushups_goal"] = GlobalVariables.daily_pushups_goal
	# Add pushups per session
	day_dict["pushups_per_session"] = GlobalVariables.pushups_per_session
	# Add remaining pushups
	day_dict["pushups_remaining_today"] = GlobalVariables.pushups_remaining_today
	# Add total pushups for today
	day_dict["total_pushups_today"] = GlobalVariables.total_pushups_today
	# Add sessions
	day_dict["sessions"] = {}
	# Return created dictionary
	return day_dict


## Create [Dictionary] to store current day's progression data and save it to 
## [member GlobalVariables.user_data_dict].
func create_user_data_dict() -> void:
	create_log_entry("Creating data dictionary.")
	
	# Get datetime dictionary from system
	var datetime_dict: Dictionary = Time.get_datetime_dict_from_system()
	# Get current year number
	var current_year: int = datetime_dict["year"]
	# Get current month number
	var current_month: int = datetime_dict["month"]
	# Get current day number
	var current_day: int = datetime_dict["day"]
	
	# Create dictionary for calendar
	var calendar_dict: Dictionary = {}
	# Create dictionary for current year
	calendar_dict[current_year] = {}
	# Create dictinary for current month
	calendar_dict[current_year][current_month] = {}
	# Create dictinary for current day
	calendar_dict[current_year][current_month][current_day] = {}
	# Create dictionary for the current day's data
	calendar_dict[current_year][current_month][current_day] = create_current_day_data_dict()
	
	# Save calendar dictionary to save data dictionary
	GlobalVariables.user_data_dict["calendar"] = calendar_dict
	# Save daily pushups goal
	GlobalVariables.user_data_dict["settings"]["daily_pushups_goal"] = GlobalVariables.daily_pushups_goal
	# Save pushups per session
	GlobalVariables.user_data_dict["settings"]["pushups_per_session"] = GlobalVariables.pushups_per_session
	
	create_log_entry("Data dictionary created successfully.")


## Create save file. [br]
##
## [br]
##
## Save file path: [constant SaveSystem.SAVE_GAME_PATH]
func create_save_file() -> void:
	# Create log
	create_log_entry("No existing save file. \
	Creating new save file, " + SAVE_FILE + ", at " + SAVE_GAME_PATH)
	# Create notification with extended duration
	GlobalVariables.create_notification("No existing save file...", true)
	
	# Create new save data dictionary
	create_user_data_dict()
	
	# Create new save file
	var new_save_file = FileAccess.open(SAVE_GAME_PATH + SAVE_FILE, FileAccess.WRITE)
	
	# Check for file errors
	if new_save_file == null:
		# Get error text
		var error_text: String = get_file_error_message(FileAccess.get_open_error())
		# Create log
		create_log_entry("Error creating new save file. " + error_text)
		# Create notification text
		var notification_text: String = "Error creating new save file\n" + "See logs for more details."
		# Create notification with extended duration
		GlobalVariables.create_notification(notification_text, true)
		return
	
	create_log_entry("Converting data to JSON.")
	# Convert save data dictionary to JSON
	var json_string = JSON.stringify(GlobalVariables.user_data_dict, "\t")
	
	create_log_entry("Writing data to " + SAVE_FILE + " at " + SAVE_GAME_PATH)
	# Store the save data dictionary as a new line in the save file.
	new_save_file.store_line(json_string)
	
	# Create log
	create_log_entry("New save file created and data saved successfully.")
	# Create notification with extended duration
	GlobalVariables.create_notification("New save file created successfully!", true)


## Return an error message as [String] based on [param file_error] value.
func get_file_error_message(file_error: Error) -> String:
	# Create error info text
	var error_info_text: String
	
	match file_error:
		# File not found
		Error.ERR_FILE_NOT_FOUND:
			error_info_text = "Error %s: Save file not found." % Error.FAILED
		# File on bad drive
		Error.ERR_FILE_BAD_DRIVE:
			error_info_text = "Error %s: Save file on bad drive." % Error.ERR_FILE_BAD_DRIVE
		# File on bad path
		Error.ERR_FILE_BAD_PATH:
			error_info_text = "Error %s: Save file on bad path." % Error.ERR_FILE_BAD_PATH
		# No permission to file
		Error.ERR_FILE_NO_PERMISSION:
			error_info_text = "Error %s: No permission to write to save file." % Error.ERR_FILE_NO_PERMISSION
		# File is already in use
		Error.ERR_FILE_ALREADY_IN_USE:
			error_info_text = "Error %s: Save file is already in use." % Error.ERR_FILE_ALREADY_IN_USE
		# Could not open file
		Error.ERR_FILE_CANT_OPEN:
			error_info_text = "Error %s: Could not open save file." % Error.ERR_CANT_OPEN
		# Could not write to file
		Error.ERR_FILE_CANT_WRITE:
			error_info_text = "Error %s: Could not write to save file." % Error.ERR_FILE_CANT_WRITE
		# Could not read from file
		Error.ERR_FILE_CANT_READ:
			error_info_text = "Error %s: Could not read save file." % Error.ERR_FILE_CANT_READ
		# File is unrecognized
		Error.ERR_FILE_UNRECOGNIZED:
			error_info_text = "Error %s: Save file is unrecognized." % Error.ERR_FILE_UNRECOGNIZED
		# File is corrupt
		Error.ERR_FILE_CORRUPT:
			error_info_text = "Error %s: Save file is corrupt." % Error.ERR_FILE_CORRUPT
		# Unknown file error
		_:
			error_info_text = "Error %s: Unknown file error." % file_error
	
	# Return error message text
	return error_info_text


## Save progression. [br][br]
## Converts [member GlobalVariables.user_data_dict] to JSON and saves it to a file. [br]
##
## [br]
##
## Save file path: [constant SaveSystem.SAVE_GAME_PATH] [br]
##
## [br]
##
## [b]Note[/b]: When converting to JSON, all data types are transformed into JSON strings.
func save_data() -> void:
	create_log_entry("Initiating data to save file.")
	
	# Get save file
	var save_file = FileAccess.open(SAVE_GAME_PATH + SAVE_FILE, FileAccess.WRITE)
	
	# Check for file errors
	if save_file == null:
		# Get error text
		var error_text: String = get_file_error_message(FileAccess.get_open_error())
		# Create log
		create_log_entry("Error opening save file. " + error_text)
		# Create notification text
		var notification_text: String = "Error opening save file\n" + "See logs for more details."
		# Create notification with extended duration
		GlobalVariables.create_notification(notification_text, true)
		return
	
	# Get datetime dictionary from system
	var datetime_dict: Dictionary = Time.get_datetime_dict_from_system()
	# Get current year number
	var current_year: int = datetime_dict["year"]
	# Get current month number
	var current_month: int = datetime_dict["month"]
	# Get current day number
	var current_day: int = datetime_dict["day"]
	# Get current hour
	var current_hour: int = datetime_dict["hour"]
	# Get current minut
	var current_minute: int = datetime_dict["minute"]
	# Get current second
	var current_second: int = datetime_dict["second"]
	
	#region: Save to settings dictionary	
	# Loop trough themes
	for theme in GlobalVariables.available_themes:
		# Get chosen theme (based of instance id)
		if GlobalVariables.current_ui_theme.get_instance_id() == GlobalVariables.available_themes[theme]["instance_id"]:
			# Save theme
			GlobalVariables.user_data_dict["settings"]["ui_theme"] = theme
			# Save theme index
			GlobalVariables.user_data_dict["settings"]["ui_theme_index"] = GlobalVariables.selected_theme_index
			
	# Save daily pushups goal
	GlobalVariables.user_data_dict["settings"]["daily_pushups_goal"] = GlobalVariables.daily_pushups_goal
	# Save pushups per session
	GlobalVariables.user_data_dict["settings"]["pushups_per_session"] = GlobalVariables.pushups_per_session
	#endregion
	
	#region: Save to calendar dictionary
	# Save daily pushups goal
	GlobalVariables.user_data_dict["calendar"][current_year][current_month][current_day]["daily_pushups_goal"] = GlobalVariables.daily_pushups_goal
	# Save pushups per session
	GlobalVariables.user_data_dict["calendar"][current_year][current_month][current_day]["pushups_per_session"] = GlobalVariables.pushups_per_session
	# Save remaining pushups
	GlobalVariables.user_data_dict["calendar"][current_year][current_month][current_day]["pushups_remaining_today"] = GlobalVariables.pushups_remaining_today
	# Save total pushups
	GlobalVariables.user_data_dict["calendar"][current_year][current_month][current_day]["total_pushups_today"] = GlobalVariables.total_pushups_today
	#endregion
	
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
		
		# Create timestamp
		var timestamp: String = "%s:%s:%s" % [current_hour, current_minute, current_second]
		# Save timestamp for session
		GlobalVariables.user_data_dict["calendar"][current_year][current_month][current_day]["sessions"][current_session]["time"] = timestamp
	
	create_log_entry("Converting data to JSON.")
	# Convert save data dictionary to JSON
	var json_string = JSON.stringify(GlobalVariables.user_data_dict, "\t")
	
	create_log_entry("Writing data to " + SAVE_FILE + " at " + SAVE_GAME_PATH + ".")
	# Store the save data dictionary as a new line in the save file
	save_file.store_line(json_string)
	
	# Create log
	create_log_entry("Data saved successfully.")
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
## Save file path: [constant SaveSystem.SAVE_GAME_PATH] [br]
##
## [br]
##
## [b]Note:[/b] Converts some keys from JSON strings to Godot data types.
func load_data() -> void:
	create_log_entry("Loading data from save file.")
	
	# Create save file, if none exists
	if not FileAccess.file_exists(SAVE_GAME_PATH + SAVE_FILE):
		create_save_file()
		return
	
	# Load save file
	var save_file = FileAccess.open(SAVE_GAME_PATH + SAVE_FILE, FileAccess.READ)	
	
	# Check for file errors
	if save_file == null:
		# Get error text
		var error_text: String = get_file_error_message(FileAccess.get_open_error())
		# Create log
		create_log_entry("Error opening save file. " + error_text)
		# Create notification text
		var notification_text: String = "Error opening save file.\n" + "See logs for more details."
		# Create notification with extended duration
		GlobalVariables.create_notification(notification_text, true)
		return

	# Create JSON helper
	var json = JSON.new()
	
	create_log_entry("Receiving data from save file.")
	# Get JSON text from save file
	var json_string = save_file.get_as_text()
	
	create_log_entry("Converting data from save file.")
	# Parse (convert) JSON text
	var save_file_data = JSON.parse_string(json_string)
	
	# If parse (convert) error occurs
	if save_file_data == null:
		# Create error message
		var error_message: String = "JSON Parse Error: " + str(json.get_error_message())\
		+ " in " + str(json_string) + " at line " + str(json.get_error_line())
		# Create log
		create_log_entry("Error converting data from save file. " + error_message)
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
			years_dict[current_year][current_month][current_day] = create_current_day_data_dict()
			
		# Create dictionary if none exist for current month
		elif not save_file_data["calendar"][str(current_year)].has(str(current_month)):
			# Create dictionary for current month
			years_dict[current_year][current_month] = {}
			# Create dictionary for current day
			years_dict[current_year][current_month][current_day] = {}
			# Create dictionary for the current day's data.
			years_dict[current_year][current_month][current_day] = create_current_day_data_dict()
		
		# Create dictionary if none exist for current day	
		elif not save_file_data["calendar"][str(current_year)][str(current_month)].has(str(current_day)):
			# Create dictionary for current day
			years_dict[current_year][current_month][current_day] = {}
			# Create dictionary for the current day's data.
			years_dict[current_year][current_month][current_day] = create_current_day_data_dict()
			
		# Load saved data, if dictionary for current date exists
		else:
			load_data_for_current_day(years_dict[current_year][current_month][current_day])
		
		# Save created dictionary to user_data_dict
		GlobalVariables.user_data_dict["calendar"] = years_dict
		
		# Create log
		create_log_entry("Loaded data from save file successfully.")
		# Create notification
		GlobalVariables.create_notification("Loaded successfully!")


## Reset global values. [br]
##
## [br]
##
## Global values: [member GlobalVariables.total_pushups_today],
## [member GlobalVariables.sessions_completed_today], and 
## [member GlobalVariables.pushups_remaining_today]
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
## [param reset_option] Options: [br]
## • [code]current_day[/code]: Clears today's progression. [br]
## • [code]current_month[/code]: Clears this month's progression. [br]
## • [code]current_year[/code]: Clears this year's progression. [br]
## • [code]all[/code]: Clears all saved progression.
func reset_data(reset_option: String) -> void:
	create_log_entry("Resetting data with option: [" + reset_option + "].\nThis CANNOT be undone!")
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
			create_log_entry("Successfully data reset for current day: %s/%s-%s." % [current_day, current_month, current_year])
		
		"current_month":
			GlobalVariables.user_data_dict["calendar"][current_year][current_month].clear()
			# Create new dictionary for current date
			GlobalVariables.user_data_dict["calendar"][current_year][current_month][current_day] = {}
			# Create sessions dictionary for current date
			GlobalVariables.user_data_dict["calendar"][current_year][current_month][current_day]["sessions"] = {}
			create_log_entry("Successfully data reset for current month: /%s-%s." % [current_month, current_year])
			
		"current_year":
			create_log_entry("Resetting saved progression for current year.")
			GlobalVariables.user_data_dict["calendar"][current_year].clear()
			# Create new dictionary for current date
			GlobalVariables.user_data_dict["calendar"][current_year][current_month] = {}
			GlobalVariables.user_data_dict["calendar"][current_year][current_month][current_day] = {}
			# Create sessions dictionary for current date
			GlobalVariables.user_data_dict["calendar"][current_year][current_month][current_day]["sessions"] = {}
			create_log_entry("Successfully data reset for current year: %s." % current_year)
		
		"all":
			create_log_entry("Resetting all saved progression.")
			# Clear saved dictionary
			GlobalVariables.user_data_dict["calendar"].clear()
			# Create new dictionary for current date
			GlobalVariables.user_data_dict["calendar"][current_year] = {}
			GlobalVariables.user_data_dict["calendar"][current_year][current_month] = {}
			GlobalVariables.user_data_dict["calendar"][current_year][current_month][current_day] = {}
			# Create sessions dictionary for current date
			GlobalVariables.user_data_dict["calendar"][current_year][current_month][current_day]["sessions"] = {}
			create_log_entry("Successfully data reset for all saved progression.")
		
		_:
			create_log_entry("Unsupported reset option: " + reset_option)

	# Create notification
	GlobalVariables.create_notification("Reset successfully!")
	# Save data
	save_data()
	# Update UI
	GlobalVariables.update_ui()
