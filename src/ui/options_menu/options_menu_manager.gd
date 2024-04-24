## Options Menu Manager.
## 
## Controls the behavior of options menu. [br]
##
## [br]
##
## Path: [code]res://src/ui/options_menu/options_menu_manager_script.gd[/code]


class_name OptionsMenuManager
extends OptionMenuComponent


## Background panel.
@onready var background_panel: Panel = %BackgroundPanel

## Settings button.
@onready var settings_button: Button = %SettingsButton

## Appearance button.
@onready var appearance_button: Button = %AppearanceButton

## Open reset menu button.
@onready var reset_menu_button: Button = %ResetMenuButton

## Open logging menu button.
@onready var logging_menu_button: Button = %LoggingMenuButton

## Close options menu button.
@onready var close_menu_button: Button = %CloseMenuButton


## Handles [member OptionsMenuManager.settings_button] button press: 
## Opens the settings menu.
func _on_settings_button_pressed() -> void:
	# Instantiate settings menu scene
	var settings_menu: CanvasLayer = load("res://src/ui/options_menu/settings_menu/settings_menu.tscn").instantiate()	
	# Add scene to tree
	get_parent().add_child(settings_menu)
	# Close options menu
	close_menu(self)


## Handles [member OptionsMenuManager.appearance_button] button press: 
## Opens the appearance menu.
func _on_appearance_button_pressed() -> void:
	# Instantiate appearance menu scene
	var appearance_menu: CanvasLayer = load("res://src/ui/options_menu/appearance_menu/appearance_menu.tscn").instantiate()	
	# Add scene to tree
	get_parent().add_child(appearance_menu)
	# Close options menu
	close_menu(self)


## Handles [member OptionsMenuManager.reset_menu_button] button press: 
## Opens the reset options menu.
func _on_reset_menu_button_pressed() -> void:
	# Instantiate reset options menu scene
	var options_menu: CanvasLayer = load("res://src/ui/options_menu/reset_options_menu/reset_options_menu.tscn").instantiate()
	# Add scene to tree
	get_parent().add_child(options_menu)
	# Close options menu
	close_menu(self)


## Handles [member OptionsMenuManager.logging_menu_button] button press: 
## Changes scene to the logging menu scene.
func _on_logging_menu_button_pressed() -> void:
	# Change to logging menu scene
	get_tree().change_scene_to_file(GlobalVariables.LOGGING_MENU_SCENE_PATH)


## Handles [member OptionsMenuManager.close_menu_button] button press: 
## Closes options menu (Removes options menu scene from tree).
func _on_close_menu_button_pressed() -> void:
	# Close options menu
	close_menu(self)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect pressed button signals
	settings_button.pressed.connect(_on_settings_button_pressed)
	appearance_button.pressed.connect(_on_appearance_button_pressed)
	reset_menu_button.pressed.connect(_on_reset_menu_button_pressed)
	logging_menu_button.pressed.connect(_on_logging_menu_button_pressed)
	close_menu_button.pressed.connect(_on_close_menu_button_pressed)
	
	# Apply UI theme to background panel
	apply_ui_theme(background_panel)
