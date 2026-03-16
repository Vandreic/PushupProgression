class_name SettingsMenuManager
extends Panel


## Controls the behavior of the settings menu.
## 
## Manages the settings menu within the options menu, handling changes for
## daily push-up goal and push-ups per session settings. [br]
##
## [br]
##
## Path: [code]res://scripts/options_menu/options/settings_menu_manager.gd[/code]

#TODO: Restrict input fields to only digits


## Daily goal input field.
@onready var daily_goal_input: LineEdit = %DailyGoalInput

## Push-ups per session input field.
@onready var pushups_per_session_input: LineEdit = %PushupsPerSessionInput

## RegEx / Regular Expression (Used for input fields)
@onready var regex: RegEx = RegEx.new()

## Close button
@onready var close_button: Button = %CloseButton


## Sets up button connections and input field configurations when the node is ready.
func _ready() -> void:
	close_button.pressed.connect(_on_close_menu_button_pressed)
	daily_goal_input.text_changed.connect(_on_daily_goal_input_text_changed)
	pushups_per_session_input.text_changed.connect(_on_pushups_per_session_input_text_changed)
	
	# Compiles and assign search pattern for regex (Only digits)
	regex.compile("^[0-9]+$")
	# Create placeholder text for input fields
	_create_placeholder_text()


## Create placeholder text for input fields.
func _create_placeholder_text() -> void:
	var _placeholder_text: String = "Current: %d"
	daily_goal_input.placeholder_text = _placeholder_text % Data.daily_pushups_goal
	pushups_per_session_input.placeholder_text = _placeholder_text % Data.pushups_per_session


## Signal handler for when the [member daily_goal_input] changes. [br]
##
## [br]
## 
## Changes the font color based on the validity of the input.
func _on_daily_goal_input_text_changed(input_text: String) -> void:
	# Search input text for digits
	var is_valid_input = regex.search(input_text)
	# Update to theme font color if valid input
	if is_valid_input:
		var font_color: Color = Data.current_ui_theme.get_color("font_color", "LineEdit")
		daily_goal_input.add_theme_color_override("font_color", font_color)
	# Change to red font color if invalid input
	else:
		daily_goal_input.add_theme_color_override("font_color", Color.RED)


## Signal handler for when the [member pushups_per_session_input] changes. [br]
##
## [br]
## 
## Changes the font color based on the validity of the input.
func _on_pushups_per_session_input_text_changed(input_text: String) -> void:
	# Search input text for digits
	var is_valid_input = regex.search(input_text)
	# Update to theme font color if valid input
	if is_valid_input:
		var font_color: Color = Data.current_ui_theme.get_color("font_color", "LineEdit")
		pushups_per_session_input.add_theme_color_override("font_color", font_color)
	# Change to red font color if invalid input
	else:
		pushups_per_session_input.add_theme_color_override("font_color", Color.RED)


## Signal handler for when the [member close_menu_button] is pressed. [br]
##
## [br]
## 
## Validates the input fields and updates the settings accordingly.
func _on_close_menu_button_pressed() -> void:
	_validate_and_update_daily_goal()
	_validate_and_update_pushups_per_session()
	
	# Save data and update UI if valid input
	if regex.search(daily_goal_input.text) or regex.search(pushups_per_session_input.text):
		EventBus.save_data_requested.emit()
		EventBus.update_ui_requested.emit()


## Validates and updates the daily goal input.
func _validate_and_update_daily_goal() -> void:
	# Search daily goal input text for digits
	var daily_goal_input_text = regex.search(daily_goal_input.text)
	# Update daily goal, if digits
	if daily_goal_input_text:
		Data.daily_pushups_goal = int(daily_goal_input.text)
		var log_message: String = "Daily goal updated to: %s" % daily_goal_input.text
		Data.add_log_entry(log_message)
		EventBus.create_notification_requested.emit(log_message, true)
	# Notify user if invalid input
	elif not daily_goal_input.text.is_empty():
		var notification_text: String = "Invalid value for daily goal: %s\n\
		Only digits allowed." % daily_goal_input.text
		EventBus.create_notification_requested.emit(notification_text, true)


## Validates and updates the push-ups per session input.
func _validate_and_update_pushups_per_session() -> void:
	# Search push-ups per session input text for digits
	var pushups_per_session_input_text = regex.search(pushups_per_session_input.text)
	# Update push-ups per session, if digits
	if pushups_per_session_input_text:
		Data.pushups_per_session = int(pushups_per_session_input.text)
		var log_message: String = "Push-ups per session updated to: %s" % pushups_per_session_input.text
		Data.add_log_entry(log_message)
		EventBus.create_notification_requested.emit(log_message, true)
	# Notify user if invalid input
	elif not pushups_per_session_input.text.is_empty():
		var notification_text: String = "Invalid value for push-ups per session: %s\n\
		Only digits allowed." % pushups_per_session_input.text
		EventBus.create_notification_requested.emit(notification_text, true)
