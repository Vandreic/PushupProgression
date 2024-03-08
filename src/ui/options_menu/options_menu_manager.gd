## Options Menu Manager Script.
## 
## This script controls the behavior of options menu. [br]
##
## [br]
##
## Path: [code]res://src/ui/options_menu/options_menu_manager_script.gd[/code]


class_name OptionsMenuManager
extends CanvasLayer


## Settings button.
@onready var settings_button: Button = %SettingsButton

## Reset menu button.
@onready var reset_menu_button: Button = %ResetMenuButton

## Close options menu button.
@onready var close_menu_button: Button = %CloseMenuButton


## Signal: Emits when [member OptionsMenuManager.settings_button] pressed.
signal settings_button_pressed

## Signal: Emits when [member OptionsMenuManager.reset_menu_button] pressed.
signal reset_menu_button_pressed


## Close options menu (Removes scene from tree).
func close_menu() -> void:
	# Delete scene from tree
	get_parent().remove_child(self)
	queue_free()


## On [member member OptionsMenuManager.settings_button] pressed.
func _on_settings_button_pressed() -> void:
	# Emit button signal
	settings_button_pressed.emit()
	# Close options menu
	close_menu()


## On [member member OptionsMenuManager.reset_menu_button] pressed.
func _on_reset_menu_button_pressed() -> void:
	# Emit button signal
	reset_menu_button_pressed.emit()
	# Close options menu
	close_menu()


## On [member PopupConfirmBoxManager.close_menu_button] pressed.
func _on_close_menu_button_pressed() -> void:
	# Close options menu
	close_menu()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect pressed button signals
	settings_button.pressed.connect(_on_settings_button_pressed)
	reset_menu_button.pressed.connect(_on_reset_menu_button_pressed)
	close_menu_button.pressed.connect(close_menu)
