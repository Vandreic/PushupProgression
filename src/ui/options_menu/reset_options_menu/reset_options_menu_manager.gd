## Reset Options Menu Manager.
## 
## Controls the behavior of reset options menu. [br]
##
## [br]
##
## Path: [code]res://src/ui/reset_options_menu/reset_options_menu_manager.gd[/code]

#TODO: Add reset option for current week


class_name ResetOptionsMenuManager
extends OptionMenuComponent


## Background panel.
@onready var background_panel: Panel = %BackgroundPanel

## Reset current day button.
@onready var reset_current_day_button: Button = %ResetCurrentDayButton

## Reset current month button.
@onready var reset_current_month_button: Button = %ResetCurrentMonthButton

## Reset current year button.
@onready var reset_current_year_button: Button = %ResetCurrentYearButton

## Reset all progress button.
@onready var reset_all_button: Button = %ResetAllButton

## Close reset options menu button.
@onready var close_menu_button: Button = %CloseMenuButton


## Opens a confirmation popup box for user choices.
func open_popup_confirm_box(reset_option: String) -> void:
	# Instantiate popup confirm box scene
	var popup_box: CanvasLayer = load("res://src/ui/popup_confirm_box/popup_confirm_box.tscn").instantiate()
	# Add scene to tree (Needed before modifying)
	get_parent().add_child(popup_box)
	
	# Create info text
	var info_text: String
	# Modify info text
	if reset_option == "all":
		info_text = "Resetting all data will permanently delete all saved progression and cannot be undone."
	else:
		info_text = "Resetting %s will permanently delete all associated data and cannot be undone."\
		% reset_option.capitalize().to_lower()
	
	# Update popup box info text
	popup_box.update_info_text(info_text)
	# Store reset option
	popup_box.selected_reset_option = reset_option


## Handles [member ResetOptionsMenuManager.reset_current_day_button] button press: 
## Clears today's progression.
func _on_reset_current_day_button_pressed() -> void:
	# Opens a confirmation box with the chosen reset option
	open_popup_confirm_box("current_day")
	# Close reset options menu
	close_menu(self)


## Handles [member ResetOptionsMenuManager.reset_current_month_button] button press: 
## Clears this month's progression.
func _on_reset_current_month_button_pressed() -> void:
	# Opens a confirmation box with the chosen reset option
	open_popup_confirm_box("current_month")
	# Close reset options menu
	close_menu(self)


## Handles [member ResetOptionsMenuManager.reset_current_year_button] button press: 
## Clears this year's progression.
func _on_reset_current_year_button_pressed() -> void:
	# Opens a confirmation box with the chosen reset option
	open_popup_confirm_box("current_year")
	# Close reset options menu
	close_menu(self)


## Handles [member ResetOptionsMenuManager.reset_all_button] button press: 
## Clears all saved progression.
func _on_reset_all_button_pressed() -> void:
	# Opens a confirmation box with the chosen reset option
	open_popup_confirm_box("all")
	# Close reset options menu
	close_menu(self)


## On [member ResetOptionsMenuManager.close_menu_button] pressed.
## Closes reset options menu (Removes reset options menu scene from tree).
func _on_close_menu_button_pressed() -> void:
	# Close reset options menu
	close_menu(self)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect pressed button signals
	reset_current_day_button.pressed.connect(_on_reset_current_day_button_pressed)
	reset_current_month_button.pressed.connect(_on_reset_current_month_button_pressed)
	reset_current_year_button.pressed.connect(_on_reset_current_year_button_pressed)
	reset_all_button.pressed.connect(_on_reset_all_button_pressed)
	close_menu_button.pressed.connect(_on_close_menu_button_pressed)
	
	# Disable "reset current day" button if no sessions
	if GlobalVariables.sessions_completed_today <= 0:
		reset_current_day_button.disabled = true
	
	# Apply UI theme to background panel
	apply_current_ui_theme(background_panel)
