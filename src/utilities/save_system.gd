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
	
	# Create daily goal
	calendar_dict["calendar"][year][month][day]["daily_pushups_goal"] = GlobalVariables.daily_pushups_goal
	# Create remaining pushups
	calendar_dict["calendar"][year][month][day]["remaining_pushups"] = GlobalVariables.remaining_pushups
	# Create total pushups
	calendar_dict["calendar"][year][month][day]["total_pushups_today"] = GlobalVariables.total_pushups_today
	# Create sessions
	calendar_dict["calendar"][year][month][day]["sessions"] = {}
	
	# Save calendar to save data dictionary
	GlobalVariables.save_data_dict = calendar_dict


## Create [Dictionary] from [param saved_data_dict] and save it to 
## [member GlobalVariables.save_data_dict]. [br]
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

	# Create dictionary if none exist for current date
	if not saved_data_dict["calendar"].has(current_year) or\
	not saved_data_dict["calendar"][current_year].has(current_month) or\
	not saved_data_dict["calendar"][current_year][current_month].has(current_day):
		# Create dictionary for current year
		years_dict[current_year] = {}
		# Create dictionary for current month
		years_dict[current_year][current_month] = {}
		# Create dictionary for current day
		years_dict[current_year][current_month][current_day] = {}
		
		# Create daily goal
		years_dict[current_year][current_month][current_day]["daily_pushups_goal"] = GlobalVariables.daily_pushups_goal
		# Create remaining pushups
		years_dict[current_year][current_month][current_day]["remaining_pushups"] = GlobalVariables.remaining_pushups
		# Create total pushups
		years_dict[current_year][current_month][current_day]["total_pushups_today"] = GlobalVariables.total_pushups_today
		# Create sessions
		years_dict[current_year][current_month][current_day]["sessions"] = {}
		
	# Load saved data if dictionary for current day exists
	else:
		# Load daily goal
		GlobalVariables.daily_pushups_goal = saved_data_dict["calendar"][current_year][current_month][current_day]["daily_pushups_goal"]
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
func reset_date() -> void:
	print("Deleting all game progress... This CANNOT be undone.")
	
	# Reset total pushups
	GlobalVariables.total_pushups_today = 0
	# Reset remaining pushups
	GlobalVariables.remaining_pushups = 0
	# Reset total sessions
	GlobalVariables.total_pushups_sessions = 0
	# Clear saved dictionary
	GlobalVariables.save_data_dict.clear()
	
	# Create new save dictionary
	create_save_data_dict()
	# Save data
	save_data()
	
	# Game reset successful
	print("Game reset succesful. All progress erased.")
