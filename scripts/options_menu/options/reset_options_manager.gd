## Controls the behavior of the reset options menu.
## 
## Manages the reset options menu within the options menu, handling the reset of
## progress data. It allows the user to reset current day, month, year, or all 
## progress data, and confirms their choice through a confirmation dialog. [br]
##
## [br]
##
## Path: [code]res://scripts/options_menu/options/reset_options_manager.gd[/code]

#TODO: Add reset option for current week

class_name ResetOptionsMenuManager
extends Panel


## Reset current day button.
@onready var reset_current_day_button: Button = %ResetCurrentDayButton

## Reset current month button.
@onready var reset_current_month_button: Button = %ResetCurrentMonthButton

## Reset current year button.
@onready var reset_current_year_button: Button = %ResetCurrentYearButton

## Reset all progress button.
@onready var reset_all_button: Button = %ResetAllButton


# TODO: Disable buttons if no saved progression data
## Setup button connections and disables [member reset_current_day_button] button
## if no saved progression data exists, when the node is ready.
func _ready() -> void:
	# Connect pressed button signals
	reset_current_day_button.pressed.connect(_on_reset_current_day_button_pressed)
	reset_current_month_button.pressed.connect(_on_reset_current_month_button_pressed)
	reset_current_year_button.pressed.connect(_on_reset_current_year_button_pressed)
	reset_all_button.pressed.connect(_on_reset_all_button_pressed)
	
	# Disable "reset current day" button if no sessions
	if GlobalVariables.sessions_completed_today <= 0:
		reset_current_day_button.disabled = true


## Opens a confirmation box for the user's selected reset option, [param reset_option]. [br]
##
## [br]
##
## Parameters: [br]
## • [param reset_option] ([String]): The reset option selected by the user. See
## [method SaveSystem.reset_data] for more details.
func _open_confirmation_box(reset_option: String) -> void:
	# Instantiate and add confirmation box
	var confirmation_box: CanvasLayer = load(GlobalVariables.CONFIRMATION_BOX_SCENE_PATH).instantiate()
	#get_parent().get_parent().get_parent().add_child(confirmation_box)
	get_parent().get_parent().get_parent().get_parent().get_parent().add_child(confirmation_box)
	
	# Update confirmation box info text
	var info_text: String = "Resetting %s will permanently delete all associated\
	 data and cannot be undone." % reset_option.capitalize().to_lower()
	
	if reset_option == "all":
		info_text = "Resetting all data will permanently delete all saved progression and cannot be undone."
	
	confirmation_box.update_info_text(info_text)
	# Store reset option with-in the confirmation box
	confirmation_box.selected_reset_option = reset_option


## Signal handler for when the [member reset_current_day_button] is pressed. [br]
##
## [br]
## 
## Opens confirmation box with selected reset option.
func _on_reset_current_day_button_pressed() -> void:
	# Opens a confirmation box with the chosen reset option
	_open_confirmation_box("current_day")
	# Close reset options menu
	_close_menu()


## Signal handler for when the [member reset_current_month_button] is pressed. [br]
##
## [br]
## 
## Opens confirmation box with selected reset option.
func _on_reset_current_month_button_pressed() -> void:
	# Opens a confirmation box with the chosen reset option
	_open_confirmation_box("current_month")
	# Close reset options menu
	_close_menu()


## Signal handler for when the [member reset_current_year_button] is pressed. [br]
##
## [br]
## 
## Opens confirmation box with selected reset option.
func _on_reset_current_year_button_pressed() -> void:
	# Opens a confirmation box with the chosen reset option
	_open_confirmation_box("current_year")
	# Close reset options menu
	_close_menu()


## Signal handler for when the [member reset_all_button] is pressed. [br]
##
## [br]
## 
## Opens confirmation box with selected reset option.
func _on_reset_all_button_pressed() -> void:
	# Opens a confirmation box with the chosen reset option
	_open_confirmation_box("all")
	# Close reset options menu
	_close_menu()


## Removes the menu from the scene tree.
func _close_menu() -> void:
	# Change current scene name and hide
	var current_reset_options_menu: CanvasLayer = get_parent().get_parent()
	var _name: String = "Deleted" + current_reset_options_menu.name
	current_reset_options_menu.name = _name
	current_reset_options_menu.visible = false
	
	# Remove current scene from tree
	current_reset_options_menu.get_parent().remove_child(current_reset_options_menu)
	current_reset_options_menu.queue_free()
