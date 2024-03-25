	## Save & load progression.
	##
	## A save system to save and load progression data. [br][br]
	## Progression data is saved to a [Dictionary] named [code]save_data_dict[/code]
	## stored within [GlobalVariables]. [br]
	## See [method SaveSystem.create_save_data_dict] and 
	## [method SaveSystem.create_save_data_dict_from_saved_data] for more details. [br]
	##
	## [br]
	##
	## [code]save_data_dict[/code] is converted to JSON and saved to file on system. [br]
	## File path: [constant SaveSystem.SAVE_GAME_PATH] [br]
	## 
	## [br]
	## 
	## Path: [code]res://src/utilities/save_system.gd[/code]

#TODO: Improve loading save data ( Remove load_save_data_dict() )


class_name SaveSystem
extends Node


## File-path for storing save file.
const SAVE_GAME_PATH: String = "user://"
## Name of save file.
const SAVE_FILE: String = "savedata.save"


## Create log message.
func create_log(log_message: String) -> void:
	# Get time from system as dictionary
	var datetime_dict: Dictionary = Time.get_datetime_dict_from_system()
	# Get current hour
	var hour: String = str(datetime_dict["hour"])
	# Get current minut
	var minute: String = str(datetime_dict["minute"])
	# Get current second
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

	# Cretae full log message
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
	day_dict["remaining_pushups"] = GlobalVariables.remaining_pushups
	# Add total pushups for today
	day_dict["total_pushups_today"] = GlobalVariables.total_pushups_today
	# Add sessions
	day_dict["sessions"] = {}
	# Return created dictionary
	return day_dict


## Create a new [Dictionary] to store progression data and save it to 
## [member GlobalVariables.save_data_dict].
func create_save_data_dict() -> void:
	create_log("Creating new save data dictionary.")
	
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
	GlobalVariables.save_data_dict["calendar"] = calendar_dict
	
	# Save daily pushups goal
	GlobalVariables.save_data_dict["settings"]["daily_pushups_goal"] = GlobalVariables.daily_pushups_goal
	# Save pushups per session
	GlobalVariables.save_data_dict["settings"]["pushups_per_session"] = GlobalVariables.pushups_per_session
	
	create_log("New save data dictionary created successfully.")


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


## Convert [member GlobalVariables.save_data_dict] to JSON and save it to a file. [br]
##
## [br]
##
## Save file path: [constant SaveSystem.SAVE_GAME_PATH] [br]
##
## [br]
##
## [b]Note[/b]: When converting to JSON, all data types are transformed into JSON strings.
func save_data() -> void:
	create_log("Saving data to save file.")
	
	# Get save file
	var save_file = FileAccess.open(SAVE_GAME_PATH + SAVE_FILE, FileAccess.WRITE)
	
	# Check for file errors
	if save_file == null:
		# Get error text
		var error_text: String = get_file_error_message(FileAccess.get_open_error())
		create_log("Error opening save file. " + error_text)
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
	# Save daily pushups goal
	GlobalVariables.save_data_dict["settings"]["daily_pushups_goal"] = GlobalVariables.daily_pushups_goal
	# Save pushups per session
	GlobalVariables.save_data_dict["settings"]["pushups_per_session"] = GlobalVariables.pushups_per_session
	#endregion
	
	#region: Save to calendar dictionary
	# Save daily pushups goal
	GlobalVariables.save_data_dict["calendar"][current_year][current_month][current_day]["daily_pushups_goal"] = GlobalVariables.daily_pushups_goal
	# Save pushups per session
	GlobalVariables.save_data_dict["calendar"][current_year][current_month][current_day]["pushups_per_session"] = GlobalVariables.pushups_per_session
	# Save remaining pushups
	GlobalVariables.save_data_dict["calendar"][current_year][current_month][current_day]["remaining_pushups"] = GlobalVariables.remaining_pushups
	# Save total pushups
	GlobalVariables.save_data_dict["calendar"][current_year][current_month][current_day]["total_pushups_today"] = GlobalVariables.total_pushups_today
	#endregion
	
	# Check if any sessions
	if GlobalVariables.total_pushups_sessions > 0:
		# Get current session number
		var current_session_num: int = GlobalVariables.total_pushups_sessions
		# Create current session name
		var current_session: String = "session_" + str(current_session_num)
		
		# Save current session
		GlobalVariables.save_data_dict["calendar"][current_year][current_month][current_day]["sessions"][current_session] = {}
		# Save pushups in session
		GlobalVariables.save_data_dict["calendar"][current_year][current_month][current_day]["sessions"][current_session]["pushups"] = GlobalVariables.pushups_per_session
		
		# Create timestamp
		var timestamp: String = "%s:%s:%s" % [current_hour, current_minute, current_second]
		# Save timestamp for session
		GlobalVariables.save_data_dict["calendar"][current_year][current_month][current_day]["sessions"][current_session]["time"] = timestamp
	
	create_log("Converting saving data to JSON.")
	# Convert save data dictionary to JSON
	var json_string = JSON.stringify(GlobalVariables.save_data_dict, "\t")
	
	create_log("Writing saving data to " + SAVE_FILE + " at " + SAVE_GAME_PATH)
	# Store the save data dictionary as a new line in the save file
	save_file.store_line(json_string)
	
	create_log("Saved data to save file successfully.")


## Load saved user settings from save data [param saved_settings_dict].
func load_settings(saved_settings_dict: Dictionary) -> void:
	# Load daily pushups goal
	GlobalVariables.daily_pushups_goal = int(saved_settings_dict["daily_pushups_goal"])
	# Load pushups per session
	GlobalVariables.pushups_per_session = int(saved_settings_dict["pushups_per_session"])


## Load current day's data from save data [param saved_current_day_dict].
func load_data_for_current_day(saved_current_day_dict) -> void:	
	# Load remaining pushups
	GlobalVariables.remaining_pushups = saved_current_day_dict["remaining_pushups"]
	# Load total pushups
	GlobalVariables.total_pushups_today = saved_current_day_dict["total_pushups_today"]
	# Load total sessions
	GlobalVariables.total_pushups_sessions = int(saved_current_day_dict["sessions"].size())


## Load save data (calendar) dictionary [param saved_years_dict] and save it to
## [member GlobalVariables.save_data_dict]. [br]
##
## [br]
##
## See [method SaveSystem.load_data] for more details.
func load_save_data_dict(saved_years_dict: Dictionary) -> void:
	create_log("Creating save data dictionary from existing saved data.")
	
	# Get datetime dictionary from system
	var datetime_dict: Dictionary = Time.get_datetime_dict_from_system()
	# Get current year number
	var current_year: int = datetime_dict["year"]
	# Get current month number
	var current_month: int = datetime_dict["month"]
	# Get current day number
	var current_day: int = datetime_dict["day"]
	
	# Create dictionary for years
	var years_dict: Dictionary = {}
	# Create dictionary for months
	var months_dict: Dictionary = {}
	# Create dictionary for days
	var days_dict: Dictionary = {}
	
	# Create new dictionary for each year
	for year in saved_years_dict:
		years_dict[year] = {}
		
		# Create new dictionary for each month
		for month in saved_years_dict[year]:
			years_dict[year][month] = {}
			
			# Create new dictionary for each day
			for day in saved_years_dict[year][month]:
				years_dict[year][month][day] = {}
				
				# Get daily goal from saved dictionary
				var daily_goal: int = saved_years_dict[year][month][day]["daily_pushups_goal"]
				# Save daily goal to new dictionary
				years_dict[year][month][day]["daily_pushups_goal"] = daily_goal					
				
				# Get pushups per session
				var pushups_per_session: int = saved_years_dict[year][month][day]["pushups_per_session"]
				# Save pushups per session
				years_dict[year][month][day]["pushups_per_session"] = pushups_per_session	
				
				# Get remaining pushups
				var remaining_pushups: int = saved_years_dict[year][month][day]["remaining_pushups"]
				# Save remaining pushups
				years_dict[year][month][day]["remaining_pushups"] = remaining_pushups
				
				# Get total pushups
				var total_pushups_today: int = saved_years_dict[year][month][day]["total_pushups_today"]
				# Save total pushups
				years_dict[year][month][day]["total_pushups_today"] = total_pushups_today
				
				# Create sessions dictionary
				var sessions_dict: Dictionary = {}
				# Loop trough each session
				for session in saved_years_dict[year][month][day]["sessions"]:
					# Create single session dictionary
					sessions_dict[session] = {}
					
					# Get pushups in session
					var pushups: int = saved_years_dict[year][month][day]["sessions"][session]["pushups"]
					# Save pushups
					sessions_dict[session]["pushups"] = pushups
					
					# Get timestamp in session
					var time: String = saved_years_dict[year][month][day]["sessions"][session]["time"]
					# Save timestamp
					sessions_dict[session]["time"] = time
				
				# Add sessions dictionary to calendar dictionary
				years_dict[year][month][day]["sessions"] = sessions_dict
	
	# Create dictionary if none exist for current year
	if not saved_years_dict.has(current_year):
		# Create dictionary for current year
		years_dict[current_year] = {}
		# Create dictionary for current month
		years_dict[current_year][current_month] = {}
		# Create dictionary for current day
		years_dict[current_year][current_month][current_day] = {}
		# Create dictionary for the current day's data.
		years_dict[current_year][current_month][current_day] = create_current_day_data_dict()
		
	# Create dictionary if none exist for current month
	elif not saved_years_dict[current_year].has(current_month):
		# Create dictionary for current month
		years_dict[current_year][current_month] = {}
		# Create dictionary for current day
		years_dict[current_year][current_month][current_day] = {}
		# Create dictionary for the current day's data.
		years_dict[current_year][current_month][current_day] = create_current_day_data_dict()
	
	# Create dictionary if none exist for current day	
	elif not saved_years_dict[current_year][current_month].has(current_day):
		# Create dictionary for current day
		years_dict[current_year][current_month][current_day] = {}
		# Create dictionary for the current day's data.
		years_dict[current_year][current_month][current_day] = create_current_day_data_dict()
		
	# Load saved data, if dictionary for current date exists
	else:
		# Load data for current day
		load_data_for_current_day(years_dict[current_year][current_month][current_day])
	
	# Save calendar dictionary
	GlobalVariables.save_data_dict["calendar"] = years_dict
	
	create_log("Save data dictionary created from existing data successfully.")


## Load save data from save file and save as [Dictionary].
##
## [br]
## 
## Save file path: [constant SaveSystem.SAVE_GAME_PATH] [br]
##
## [br]
##
## [b]Note:[/b] Converts some keys from JSON strings to Godot data types.
func load_data() -> void:
	create_log("Loading data from save file.")
	
	# Check if save file exists
	if not FileAccess.file_exists(SAVE_GAME_PATH + SAVE_FILE):
		create_log("No existing save file. \
		Creating new save file, " + SAVE_FILE + ", at " + SAVE_GAME_PATH)
		
		# Create new save data dictionary
		create_save_data_dict()
		
		# Create new save file
		var new_save_file = FileAccess.open(SAVE_GAME_PATH + SAVE_FILE, FileAccess.WRITE)
		
		# Check for file errors
		if new_save_file == null:
			# Get error text
			var error_text: String = get_file_error_message(FileAccess.get_open_error())
			create_log("Error creating new save file. " + error_text)
			return
		
		create_log("Converting save data dictionary to JSON.")
		# Convert save data dictionary to JSON
		var json_string = JSON.stringify(GlobalVariables.save_data_dict, "\t")
		
		create_log("Writing save data dictionary to " + SAVE_FILE + " at " + SAVE_GAME_PATH)
		# Store the save data dictionary as a new line in the save file.
		new_save_file.store_line(json_string)
		
		# File saved successfully
		create_log("New save file created. Saved successfully.")
		return
	
	# Load save file
	var save_file = FileAccess.open(SAVE_GAME_PATH + SAVE_FILE, FileAccess.READ)	
	
	# Check for file errors
	if save_file == null:
		# Get error text
		var error_text: String = get_file_error_message(FileAccess.get_open_error())
		create_log("Error opening save file. " + error_text)
		return

	# Create JSON helper
	var json = JSON.new()
	
	create_log("Receiving data from save file.")
	# Get JSON text from save file
	var json_string = save_file.get_as_text()
	
	create_log("Converting data from save file.")
	# Parse (convert) JSON text
	var save_file_data = json.parse_string(json_string)
	
	# If parse (convert) error occurs
	if save_file_data == null:
		# Create error message
		var error_message: String = "JSON Parse Error: " + json.get_error_message()\
		+ " in " + json_string + " at line " + json.get_error_line()
		
		create_log("Error converting data to save file. " + error_message)
		return
	
	# If save data is dictionary, create copy 
	if save_file_data is Dictionary:
		# Get user settings dictionary
		var settings_dict: Dictionary = save_file_data["settings"]
		# Load settings
		load_settings(settings_dict)
		
		# Create new years dictionary
		var years_dict: Dictionary = {}
		# Create new months dictionary
		var months_dict: Dictionary = {}
		# Create new days dictionary
		var days_dict: Dictionary = {}
		
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
					var remaining_pushups: int = int(save_file_data["calendar"][year][month][day]["remaining_pushups"])
					# Save remaining pushups
					years_dict[int(year)][int(month)][int(day)]["remaining_pushups"] = remaining_pushups
					
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
		
		create_log("Loaded data from save file successfully.")
		# Load save data dictionary
		load_save_data_dict(years_dict)
		
		print(years_dict)


## Reset all progression data.
func reset_data(reset_option: String) -> void:
	create_log("Resetting data with option: [" + reset_option + "]. This CANNOT be undone!")
	
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
			# Reset global values
			reset_global_values()
			# Reset progression for current day
			GlobalVariables.save_data_dict["calendar"][current_year][current_month][current_day].clear()
			# Create sessions dictionary for current date
			GlobalVariables.save_data_dict["calendar"][current_year][current_month][current_day]["sessions"] = {}
			create_log("Successfully data reset for current day: %s/%s-%s." % [current_day, current_month, current_year])
		
		"current_month":
			reset_global_values()
			GlobalVariables.save_data_dict["calendar"][current_year][current_month].clear()
			# Create new dictionary for current date
			GlobalVariables.save_data_dict["calendar"][current_year][current_month][current_day] = {}
			# Create sessions dictionary for current date
			GlobalVariables.save_data_dict["calendar"][current_year][current_month][current_day]["sessions"] = {}
			create_log("Successfully data reset for current month: /%s-%s." % [current_month, current_year])
			
		"current_year":
			create_log("Resetting saved progression for current year.")
			reset_global_values()
			GlobalVariables.save_data_dict["calendar"][current_year].clear()
			# Create new dictionary for current date
			GlobalVariables.save_data_dict["calendar"][current_year][current_month] = {}
			GlobalVariables.save_data_dict["calendar"][current_year][current_month][current_day] = {}
			# Create sessions dictionary for current date
			GlobalVariables.save_data_dict["calendar"][current_year][current_month][current_day]["sessions"] = {}
			create_log("Successfully data reset for current year: %s." % current_year)
		
		"all":
			create_log("Resetting all saved progression.")
			reset_global_values()
			# Clear saved dictionary
			GlobalVariables.save_data_dict["calendar"].clear()
			# Create new dictionary for current date
			GlobalVariables.save_data_dict["calendar"][current_year] = {}
			GlobalVariables.save_data_dict["calendar"][current_year][current_month] = {}
			GlobalVariables.save_data_dict["calendar"][current_year][current_month][current_day] = {}
			# Create sessions dictionary for current date
			GlobalVariables.save_data_dict["calendar"][current_year][current_month][current_day]["sessions"] = {}
			create_log("Successfully data reset for all saved progression.")
		
		_:
			create_log("Unsupported reset option: " + reset_option)

	# Save data
	save_data()


## Reset global values.
func reset_global_values() -> void:
	# Reset total pushups
	GlobalVariables.total_pushups_today = 0
	# Reset total sessions
	GlobalVariables.total_pushups_sessions = 0
	# Reset remaining pushups
	GlobalVariables.remaining_pushups = 0
	create_log("Global values reset successfully.")
