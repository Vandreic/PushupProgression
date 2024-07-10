class_name OptionsMenuManager
extends Panel


## Controls the behavior of the options menu.
## 
## Manages the options within the options menu, handling user input to open
## corresponding option menus like settings, appearance, reset options, and logging. [br]
##
## [br]
##
## Path: [code]res://scripts/options_menu/options_menu_manager.gd[/code]


## Settings button.
@onready var settings_button: Button = %SettingsButton

## Appearance menu button.
@onready var appearance_button: Button = %AppearanceButton

## Logging menu button.
@onready var logging_menu_button: Button = %LoggingMenuButton

## Reset menu button.
@onready var reset_menu_button: Button = %ResetMenuButton


## Sets up button connections, when the node is ready.
func _ready() -> void:
	settings_button.pressed.connect(_on_settings_button_pressed)
	appearance_button.pressed.connect(_on_appearance_button_pressed)
	logging_menu_button.pressed.connect(_on_logging_menu_button_pressed)
	reset_menu_button.pressed.connect(_on_reset_menu_button_pressed)


## Signal handler for when the [member settings_button] is pressed. [br]
##
## [br]
## 
## Opens the settings menu.
func _on_settings_button_pressed() -> void:
	SceneManager.close_options_menu_requested.emit()
	SceneManager.add_scene_requested.emit("Settings")


## Signal handler for when the [member appearance_button] is pressed. [br]
##
## [br]
## 
## Opens the appearance menu.
func _on_appearance_button_pressed() -> void:
	SceneManager.close_options_menu_requested.emit()
	SceneManager.add_scene_requested.emit("Appearance")


## Signal handler for when the [member logging_menu_button] is pressed. [br]
##
## [br]
## 
## Changes the scene to the logging menu scene.ene.
func _on_logging_menu_button_pressed() -> void:
	SceneManager.change_scene_requested.emit("LogConsole")


## Signal handler for when the [member reset_menu_button] is pressed. [br]
##
## [br]
## 
## Opens the reset options menu.
func _on_reset_menu_button_pressed() -> void:	
	SceneManager.close_options_menu_requested.emit()
	SceneManager.add_scene_requested.emit("ResetOptions")
