## Reset Options Menu Manager Script.
## 
## This script controls the behavior of reset options menu. [br]
##
## [br]
##
## Path: [code]res://src/ui/reset_options_menu/reset_options_menu_manager.gd[/code]

#TODO: Add reset option for current week


class_name ResetOptionsMenuManager
extends CanvasLayer


## Reset current day button.
@onready var reset_current_day_button: Button = %ResetCurrentDayButton

# Reset current week button.
#@onready var reset_current_week_button: Button = %ResetCurrentWeekButton

## Reset current month button.
@onready var reset_current_month_button: Button = %ResetCurrentMonthButton

## Reset current year button.
@onready var reset_current_year_button: Button = %ResetCurrentYearButton

## Reset all progress button.
@onready var reset_all_button: Button = %ResetAllButton

## Close reset options menu button.
@onready var close_menu_button: Button = %CloseMenuButton


## Signal: Emits when [member ResetOptionsMenuManager.reset_current_day_button] pressed.
signal reset_current_day_button_pressed

# Signal: Emits when [member ResetOptionsMenuManager.reset_current_week_button] pressed.
#signal reset_current_week_button_pressed

## Signal: Emits when [member ResetOptionsMenuManager.reset_current_month_button] pressed.
signal reset_current_month_button_pressed

## Signal: Emits when [member ResetOptionsMenuManager.reset_current_year_button] pressed.
signal reset_current_year_button_pressed

## Signal: Emits when [member ResetOptionsMenuManager.reset_all_button] pressed.
signal reset_all_button_pressed


## Close reset menu (Removes scene from tree).
func close_menu() -> void:
	# Delete scene from tree
	get_parent().remove_child(self)
	queue_free()


## On [member ResetOptionsMenuManager.reset_current_day_button] pressed.
func _on_reset_current_day_button_pressed() -> void:
	# Emit button signal
	reset_current_day_button_pressed.emit()
	# Close reset menu
	close_menu()


# On [member ResetOptionsMenuManager.reset_current_week_button] pressed.
#func _on_reset_current_week_button_pressed() -> void:
	## Emit button signal
	#reset_current_week_button_pressed.emit()
	## Close reset menu
	#close_menu()


## On [member ResetOptionsMenuManager.reset_current_month_button] pressed.
func _on_reset_current_month_button_pressed() -> void:
	# Emit button signal
	reset_current_month_button_pressed.emit()
	# Close reset menu
	close_menu()


## On [member ResetOptionsMenuManager.reset_current_year_button] pressed.
func _on_reset_current_year_button_pressed() -> void:
	# Emit button signal
	reset_current_year_button_pressed.emit()
	# Close reset menu
	close_menu()


## On [member ResetOptionsMenuManager.reset_all_button] pressed.
func _on_reset_all_button_pressed() -> void:
	# Emit button signal
	reset_all_button_pressed.emit()
	# Close reset menu
	close_menu()


## On [member ResetOptionsMenuManager.close_menu_button] pressed.
func _on_close_menu_button_pressed() -> void:
	close_menu()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect pressed button signals
	reset_current_day_button.pressed.connect(_on_reset_current_day_button_pressed)
	#reset_current_week_button.pressed.connect(_on_reset_current_week_button_pressed)
	reset_current_month_button.pressed.connect(_on_reset_current_month_button_pressed)
	reset_current_year_button.pressed.connect(_on_reset_current_year_button_pressed)
	reset_all_button.pressed.connect(_on_reset_all_button_pressed)
	close_menu_button.pressed.connect(_on_close_menu_button_pressed)
	
	# Disable "reset current day" button if no sessions
	if GlobalVariables.total_pushups_sessions <= 0:
		reset_current_day_button.disabled = true
