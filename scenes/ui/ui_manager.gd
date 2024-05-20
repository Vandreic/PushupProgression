## Handles the user interface theme application and updates UI elements across the application.
##
## The manager applies UI theme and ensures all UI elements are consistently updated to reflect the 
## latest changes. [br]
##
## [br]
##
## Usage: [br]
## • [method apply_ui_theme]: Applies the current UI theme based of 
## [member GlobalVariables.current_ui_theme]. [br]
## • [method update_ui]: Refreshes  UI elements to reflect the latest changes. [br]
##
## [br]
##
## Path: [code]res://scenes/ui/ui_manager.gd[/code]


class_name UIManager
extends Node


## Panel background that can be themed.
@onready var background_panel: Panel = %BackgroundPanel

## Container for UI elements displaying the current progress.
@onready var current_progress_container: VBoxContainer = %CurrentProgressContainer

## Container for UI elements displaying the previous progress.
@onready var previous_progress_container: HBoxContainer = %PreviousProgressContainer

## Application version label.
@onready var app_version: Label = %AppVersion


## Initialize application version label.
func _ready():
	# Initialize app version
	app_version.text = "version " + str(ProjectSettings.get_setting("application/config/version"))


## Update UI elements.
func update_ui() -> void:
	# Update all UI elements in current progress container
	current_progress_container.update_ui()


## Applies the UI theme based on [member GlobalVariables.current_ui_theme].
func apply_ui_theme() -> void:
	background_panel.theme = GlobalVariables.current_ui_theme
	current_progress_container.apply_ui_theme()
