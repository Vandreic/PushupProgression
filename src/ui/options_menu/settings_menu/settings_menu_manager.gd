## Settings Menu Manager Script.
## 
## This script controls the behavior of settings menu. [br]
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
		print("Good daily goal!")
	elif daily_goal_input.text.is_empty():
		print("No daily goal set.")
	else:
		print("Bad daily goal...")
	
	# Search pushups per session input text for digits
	var pushups_per_session_input_text = regex.search(pushups_per_session_input.text)
	if pushups_per_session_input_text:
		GlobalVariables.pushups_per_session = int(pushups_per_session_input.text)
		print("Good pushups per session!")
	elif pushups_per_session_input.text.is_empty():
		print("No pushups per session set.")
	else:
		print("Bad pushups per session...")
	
	get_tree().call_group("save_system", "save_data")
	get_tree().call_group("ui_manager", "update_ui")
	
	# Close settings menu
	close_menu()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect pressed button signals
	close_menu_button.pressed.connect(_on_close_menu_button_pressed)
	# Compiles and assign search pattern for regex (Only digits)
	regex.compile("^[0-9]+$")
