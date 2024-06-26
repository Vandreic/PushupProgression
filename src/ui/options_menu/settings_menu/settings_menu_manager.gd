## Settings Menu Manager.
## 
## Controls the behavior of settings menu. [br]
##
## [br]
##
## Path: [code]res://src/ui/options_menu/settings_menu/settings_menu_manager_script.gd[/code]


#TODO: Restrict input fields to only digits


class_name SettingsMenuManager
extends CanvasLayer


## Daily goal input field.
@onready var daily_goal_input: LineEdit = %DailyGoalInput

## Pushups per session input field.
@onready var pushups_per_session_input: LineEdit = %PushupsPerSessionInput

## Close settings menu button.
@onready var close_menu_button: Button = %CloseMenuButton

## RegEx / Regular Expression (Used for input fields)
@onready var regex: RegEx = RegEx.new()


## Close settings menu (Removes scene from tree).
func close_menu() -> void:
	# Delete scene from tree
	get_parent().remove_child(self)
	queue_free()


## On [member SettingsMenuManager.close_menu_button] pressed.
func _on_close_menu_button_pressed() -> void:
	#region: Daily goal input
	# Search daily goal input text for digits
	var daily_goal_input_text = regex.search(daily_goal_input.text)
	# Update daily goal, if digits
	if daily_goal_input_text:
		GlobalVariables.daily_pushups_goal = int(daily_goal_input.text)
		# Create log message
		var log_message: String = "Daily goal updated to: %s" % daily_goal_input.text
		# Create log
		GlobalVariables.create_log(log_message)
		# Create notification with extended duration
		GlobalVariables.create_notification(log_message, true)
	# If no input, pass
	elif daily_goal_input.text.is_empty():
		pass
	# Else, create notification
	else:
		# Create notification text
		var notification_text: String = "Invalid value for daily goal: %s\n\
		Only digits allowed." % str(daily_goal_input.text)
		# Create notification with extended duration
		GlobalVariables.create_notification(notification_text, true)
	#endregion
	
	#region: Pushups per session input
	# Search pushups per session input text for digits
	var pushups_per_session_input_text = regex.search(pushups_per_session_input.text)
	# Update pushups per session, if digits
	if pushups_per_session_input_text:
		GlobalVariables.pushups_per_session = int(pushups_per_session_input.text)
		# Create log message
		var log_message: String = "Pushups per session updated to: %s" % pushups_per_session_input.text
		# Create log
		GlobalVariables.create_log(log_message)
		# Create notification with extended duration
		GlobalVariables.create_notification(log_message, true)
	# If no input, pass
	elif pushups_per_session_input.text.is_empty():
		pass
	# Else, create notification
	else:
		# Create notification text
		var notification_text: String = "Invalid value for pushups per session: %s\n\
		Only digits allowed." % str(pushups_per_session_input.text)
		# Create notification with extended duration
		GlobalVariables.create_notification(notification_text, true)
	#endregion
	
	# If no input, create notification with extended duration
	if daily_goal_input.text.is_empty() and pushups_per_session_input.text.is_empty():
		GlobalVariables.create_notification("No changes to settings were made.", true)
	
	# If valid input, save data and update UI
	elif daily_goal_input_text or pushups_per_session_input_text:
		# Save data
		GlobalVariables.save_data()
		# Update UI
		GlobalVariables.update_ui()
	
	# Close settings menu
	close_menu()


## On [member SettingsMenuManager.daily_goal_input] text changed.
func _on_daily_goal_input_text_changed(input_text: String) -> void:
	# Search daily goal input text for digits
	var _input_text = regex.search(input_text)
	# Change font color if input is not digits
	if not _input_text:
		daily_goal_input.add_theme_color_override("font_color", Color.RED)
	else:
		daily_goal_input.add_theme_color_override("font_color", Color.WHITE)


## On [member SettingsMenuManager.pushups_per_session_input] text changed.
func _on_pushups_per_session_input_text_changed(input_text: String) -> void:
	# Search pushups per session input text for digits
	var _input_text = regex.search(input_text)
	# Change font color if input is not digits
	if not _input_text:
		pushups_per_session_input.add_theme_color_override("font_color", Color.RED)
	else:
		pushups_per_session_input.add_theme_color_override("font_color", Color.WHITE)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect pressed button signals
	close_menu_button.pressed.connect(_on_close_menu_button_pressed)
	# Connect signal for text changes in input fields
	daily_goal_input.text_changed.connect(_on_daily_goal_input_text_changed)
	pushups_per_session_input.text_changed.connect(_on_pushups_per_session_input_text_changed)
	# Compiles and assign search pattern for regex (Only digits)
	regex.compile("^[0-9]+$")
	
	# Placeholder text for input fields
	var _placeholder_text: String = "Current: %d"
	# Set placeholder text for input fields
	daily_goal_input.placeholder_text = _placeholder_text % GlobalVariables.daily_pushups_goal
	pushups_per_session_input.placeholder_text = _placeholder_text % GlobalVariables.pushups_per_session
