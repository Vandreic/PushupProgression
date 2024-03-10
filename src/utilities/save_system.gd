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


class_name SaveSystem
extends Node


## File-path for storing save file.
const SAVE_GAME_PATH: String = "user://"
## Name of save file.
const SAVE_FILE: String = "savedata.save"


## Create dictionary for the current day's data.
func create_day_data_dict() -> Dictionary:
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
	# Get datetime as dictionary from system
	var datetime_dict: Dictionary = Time.get_datetime_dict_from_system()
	# Get current year
	var year: int = datetime_dict["year"]
	# Get current month number
	var month: int = datetime_dict["month"]
	# Get current day number
	var day: int = datetime_dict["day"]

	# Create calendar as dictionary
	var calendar_dict: Dictionary = {"calendar" = {}}

	# Create year as dictionary
	calendar_dict["calendar"][year] = {}
	# Create month as dictionary
	calendar_dict["calendar"][year][month] = {}
	# Create day as dictionary
	calendar_dict["calendar"][year][month][day] = {}
	
	# Create dictionary for the current day's data
	calendar_dict["calendar"][year][month][day] = create_day_data_dict()
	
	# Save calendar to save data dictionary
	GlobalVariables.save_data_dict = calendar_dict


## Create [Dictionary] for saving data from existing saved data [param saved_data_dict] 
## and save it to [member GlobalVariables.save_data_dict]. [br]
##
## [br]
##
## See [method SaveSystem.load_data] for more details.
func create_save_data_dict_from_saved_data(saved_data_dict: Dictionary) -> void:
	# Get date as dictionary from system
	var datetime_dict: Dictionary = Time.get_date_dict_from_system()
	# Get current year
	var current_year: int = datetime_dict["year"]
	# Get current month
	var current_month: int = datetime_dict["month"]
	# Get current day
	var current_day: int = datetime_dict["day"]
	
	# Create calendar as dictionary
	var calendar_dict: Dictionary = {"calendar" = {}}
	# Years dictionary
	var years_dict: Dictionary = {}
	# Months dictionary
	var months_dict: Dictionary = {}
	# Days dictionary
	var days_dict: Dictionary = {}
	
	# Create new dictionary for each year.
	for year in saved_data_dict["calendar"]:
		years_dict[year] = {}
		
		# Create new dictionary for each month
		for month in saved_data_dict["calendar"][year]:
			years_dict[year][month] = {}
			
			# Create new dictionary for each day
			for day in saved_data_dict["calendar"][year][month]:
				years_dict[year][month][day] = {}
				
				# Get daily goal from saved dictionary
				var daily_goal: int = saved_data_dict["calendar"][year][month][day]["daily_pushups_goal"]
				# Save daily goal to new dictionaru
				years_dict[year][month][day]["daily_pushups_goal"] = daily_goal					
				
				# Get pushups per session
				var pushups_per_session: int = saved_data_dict["calendar"][year][month][day]["pushups_per_session"]
				# Save pushups per session
				years_dict[year][month][day]["pushups_per_session"] = pushups_per_session	
				
				# Get remaining pushups
				var remaining_pushups: int = saved_data_dict["calendar"][year][month][day]["remaining_pushups"]
				# Save remaining pushups
				years_dict[year][month][day]["remaining_pushups"] = remaining_pushups
				
				# Get total pushups
				var total_pushups_today: int = saved_data_dict["calendar"][year][month][day]["total_pushups_today"]
				# Save total pushups
				years_dict[year][month][day]["total_pushups_today"] = total_pushups_today
				
				# Create sessions dictionary
				var sessions_dict: Dictionary = {}
				# Loop trough each session
				for session in saved_data_dict["calendar"][year][month][day]["sessions"]:
					# Create single session dictionary
					sessions_dict[session] = {}
					
					# Get pushups in session
					var pushups: int = saved_data_dict["calendar"][year][month][day]["sessions"][session]["pushups"]
					# Save pushups
					sessions_dict[session]["pushups"] = pushups
					
					# Get timestamp in session
					var time: String = saved_data_dict["calendar"][year][month][day]["sessions"][session]["time"]
					sessions_dict[session]["time"] = time
				
				# Add sessions dictionary to calendar
				years_dict[year][month][day]["sessions"] = sessions_dict

	# Create dictionary if none exist for current year
	if not saved_data_dict["calendar"].has(current_year):
		# Create dictionary for current year
		years_dict[current_year] = {}
		# Create dictionary for current month
		years_dict[current_year][current_month] = {}
		# Create dictionary for current day
		years_dict[current_year][current_month][current_day] = {}
		# Create dictionary for the current day's data.
		years_dict[current_year][current_month][current_day] = create_day_data_dict()
		
	
	# Create dictionary if none exist for current month
	elif not saved_data_dict["calendar"][current_year].has(current_month):
		# Create dictionary for current month
		years_dict[current_year][current_month] = {}
		# Create dictionary for current day
		years_dict[current_year][current_month][current_day] = {}
		# Create dictionary for the current day's data.
		years_dict[current_year][current_month][current_day] = create_day_data_dict()
	
	# Create dictionary if none exist for current day	
	elif not saved_data_dict["calendar"][current_year][current_month].has(current_day):
		# Create dictionary for current day
		years_dict[current_year][current_month][current_day] = {}
		# Create dictionary for the current day's data.
		years_dict[current_year][current_month][current_day] = create_day_data_dict()
		
	# Load saved data if dictionary for current date exists
	else:
		# Load daily goal
		GlobalVariables.daily_pushups_goal = saved_data_dict["calendar"][current_year][current_month][current_day]["daily_pushups_goal"]
		# Load pushups per session
		GlobalVariables.pushups_per_session = saved_data_dict["calendar"][current_year][current_month][current_day]["pushups_per_session"]
		# Load remaining pushups
		GlobalVariables.remaining_pushups = saved_data_dict["calendar"][current_year][current_month][current_day]["remaining_pushups"]
		# Load total pushups
		GlobalVariables.total_pushups_today = saved_data_dict["calendar"][current_year][current_month][current_day]["total_pushups_today"]
		# Load total sessions
		GlobalVariables.total_pushups_sessions = int(saved_data_dict["calendar"][current_year][current_month][current_day]["sessions"].size())

	# Add dates to calendar dictionary
	calendar_dict["calendar"] = years_dict
	
	# Save calendar
	GlobalVariables.save_data_dict = calendar_dict
	
	# File loaded successfully
	print("Save file loaded successfully.")


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
## File path: [constant SaveSystem.SAVE_GAME_PATH] [br]
##
## [br]
##
## [b]Note[/b]: When converting to JSON, all data types are transformed into JSON strings.
func save_data() -> void:
	# Get save file
	var save_file = FileAccess.open(SAVE_GAME_PATH + SAVE_FILE, FileAccess.WRITE)
	
	# Check for file errors
	if save_file == null:
		# Get error text
		var error_text: String = get_file_error_message(FileAccess.get_open_error())
		print(error_text)
		return
	
	# Get datetime as dictionary from system
	var datetime_dict: Dictionary = Time.get_datetime_dict_from_system()
	# Get current year
	var year: int = datetime_dict["year"]
	# Get current month number
	var month: int = datetime_dict["month"]
	# Get current day number
	var day: int = datetime_dict["day"]
	# Get current hour
	var hour: int = datetime_dict["hour"]
	# Get current minut
	var minute: int = datetime_dict["minute"]
	# Get current second
	var second: int = datetime_dict["second"]
	
	# Save daily pushups goal
	GlobalVariables.save_data_dict["calendar"][year][month][day]["daily_pushups_goal"] = GlobalVariables.daily_pushups_goal
	# Save pushups per session
	GlobalVariables.save_data_dict["calendar"][year][month][day]["pushups_per_session"] = GlobalVariables.pushups_per_session
	# Save remaining pushups
	GlobalVariables.save_data_dict["calendar"][year][month][day]["remaining_pushups"] = GlobalVariables.remaining_pushups
	# Save total pushups
	GlobalVariables.save_data_dict["calendar"][year][month][day]["total_pushups_today"] = GlobalVariables.total_pushups_today
	
	# Check if any sessions
	if GlobalVariables.total_pushups_sessions > 0:
		# Get current session number
		var current_session_num: int = GlobalVariables.total_pushups_sessions
		# Create current session name
		var current_session: String = "session_" + str(current_session_num)
		
		# Save current session
		GlobalVariables.save_data_dict["calendar"][year][month][day]["sessions"][current_session] = {}
		# Save pushups in session
		GlobalVariables.save_data_dict["calendar"][year][month][day]["sessions"][current_session]["pushups"] = GlobalVariables.pushups_per_session
		
		# Create timestamp
		var timestamp: String = "%s:%s:%s" % [hour, minute, second]
		# Save timestamp for session
		GlobalVariables.save_data_dict["calendar"][year][month][day]["sessions"][current_session]["time"] = timestamp
	
	# Convert save data dictionary to JSON
	var json_string = JSON.stringify(GlobalVariables.save_data_dict, "\t")
	
	# Store the save data dictionary as a new line in the save file.
	save_file.store_line(json_string)
	
	# File saved successfully
	print("Save file saved successfully.")


## Load progression data from JSON file as [Dictionary] and pass as argument to  
## [method SaveSystem.create_save_data_dict_from_saved_data]. [br]
##
## [br]
## 
## File path: [constant SaveSystem.SAVE_GAME_PATH] [br]
##
## [br]
##
## [b]Note:[/b] Converts some keys from JSON strings to Godot data types.
func load_data() -> void:
	# Check if save file exists
	if not FileAccess.file_exists(SAVE_GAME_PATH + SAVE_FILE):
		print("No existing save file...")
		
		# Create new save data dictionary
		create_save_data_dict()
		
		# Create save file
		var save_file = FileAccess.open(SAVE_GAME_PATH + SAVE_FILE, FileAccess.WRITE)
		
		# Check for file errors
		if save_file == null:
			# Get error text
			var error_text: String = get_file_error_message(FileAccess.get_open_error())
			print(error_text)
			return
		
		# File created successfully
		print("Save file created successfully.")
		
		# Convert save data dictionary to JSON
		var json_string = JSON.stringify(GlobalVariables.save_data_dict, "\t")
		
		# Store the save data dictionary as a new line in the save file.
		save_file.store_line(json_string)
		
		# File saved successfully
		print("Save file saved successfully.")
		return
	
	# Load save file
	var save_file = FileAccess.open(SAVE_GAME_PATH + SAVE_FILE, FileAccess.READ)	
	
	# Check for file errors
	if save_file == null:
		# Get error text
		var error_text: String = get_file_error_message(FileAccess.get_open_error())
		print(error_text)
		return

	# Create JSON helper
	var json = JSON.new()
	
	# Get JSON
	var json_string = save_file.get_as_text()
	
	# Parse JSON
	var save_file_data = json.parse_string(json_string)
	
	# If parse error occurs
	if save_file_data == null:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return
	
	# Check if save data is dictionary
	if save_file_data is Dictionary:
		# Create calendar as dictionary (Some keys must be integer value)
		var calendar_dict: Dictionary = {"calendar" = {}}
		# Years dictionary
		var years_dict: Dictionary = {}
		# Months dictionary
		var months_dict: Dictionary = {}
		# Days dictionary
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
					
					# Get daily goal
					var daily_goal: int = int(save_file_data["calendar"][year][month][day]["daily_pushups_goal"])
					# Save daily goal
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
							
		# Add dates to calendar dictionary
		calendar_dict["calendar"] = years_dict
		
		# Create save dictionary from saved calendar
		create_save_data_dict_from_saved_data(calendar_dict)


## Reset all progression data.
func reset_data(reset_option: String) -> void:
	print("Deleting saved progress... This CANNOT be undone.")
	
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
			print("Resetting saved progression for current day.")
			# Reset global values
			reset_global_values()
			# Reset progression for current day
			GlobalVariables.save_data_dict["calendar"][current_year][current_month][current_day].clear()
			# Create sessions dictionary for current date
			GlobalVariables.save_data_dict["calendar"][current_year][current_month][current_day]["sessions"] = {}
		
		#"current_week":
			#print("Resetting saved progression for current week.")
			#reset_global_values()
			## Reset progression for current week
		
		"current_month":
			print("Resetting saved progression for current month.")
			reset_global_values()
			GlobalVariables.save_data_dict["calendar"][current_year][current_month].clear()
			# Create new dictionary for current date
			GlobalVariables.save_data_dict["calendar"][current_year][current_month][current_day] = {}
			# Create sessions dictionary for current date
			GlobalVariables.save_data_dict["calendar"][current_year][current_month][current_day]["sessions"] = {}
		
		"current_year":
			print("Resetting saved progression for current year.")
			reset_global_values()
			GlobalVariables.save_data_dict["calendar"][current_year].clear()
			# Create new dictionary for current date
			GlobalVariables.save_data_dict["calendar"][current_year][current_month] = {}
			GlobalVariables.save_data_dict["calendar"][current_year][current_month][current_day] = {}
			# Create sessions dictionary for current date
			GlobalVariables.save_data_dict["calendar"][current_year][current_month][current_day]["sessions"] = {}
		
		"all":
			print("Resetting all saved progression.")
			reset_global_values()
			# Clear saved dictionary
			GlobalVariables.save_data_dict["calendar"].clear()
			# Create new dictionary for current date
			GlobalVariables.save_data_dict["calendar"][current_year] = {}
			GlobalVariables.save_data_dict["calendar"][current_year][current_month] = {}
			GlobalVariables.save_data_dict["calendar"][current_year][current_month][current_day] = {}
			# Create sessions dictionary for current date
			GlobalVariables.save_data_dict["calendar"][current_year][current_month][current_day]["sessions"] = {}
		
		_:
			print("Unsupported reset option:", reset_option)

	# Game reset successful
	print("Game reset succesful. Progress erased.")

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
