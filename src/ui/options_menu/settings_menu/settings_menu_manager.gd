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
	# Search daily goal input text for digits
	var daily_goal_input_text = regex.search(daily_goal_input.text)
	if daily_goal_input_text:
		GlobalVariables.daily_pushups_goal = int(daily_goal_input.text)
		print("Daily goal updated to: %s" % daily_goal_input.text)
	elif daily_goal_input.text.is_empty():
		print("No changes to daily goal were made.")
	else:
		print("Invalid value for daily goal: %s. Only digits are allowed."\
		% str(daily_goal_input.text))
	
	# Search pushups per session input text for digits
	var pushups_per_session_input_text = regex.search(pushups_per_session_input.text)
	if pushups_per_session_input_text:
		GlobalVariables.pushups_per_session = int(pushups_per_session_input.text)
		print("Pushups per session updated to: %s" % pushups_per_session_input.text)
	elif pushups_per_session_input.text.is_empty():
		print("No changes to pushups per session were made.")
	else:
		print("Invalid value for pushups per session: %s. Only digits allowed."\
		% str(pushups_per_session_input.text))
	
	# Save progression data
	get_tree().call_group("save_system", "save_data")
	# Update UI
	get_tree().call_group("ui_manager", "update_ui")
	
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
