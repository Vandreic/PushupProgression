class_name UIManager
extends Node


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
## Path: [code]res://scripts/ui/ui_manager.gd[/code]


## Panel background that can be themed.
@onready var background_panel: Panel = %BackgroundPanel

## Container for UI elements displaying the current progress.
@onready var current_progress_container: VBoxContainer = %CurrentProgressContainer

## Container for UI elements displaying the previous progress.
#@onready var previous_progress_container: HBoxContainer = %PreviousProgressContainer

## Application version label.
@onready var app_version: Label = %AppVersion


## Initialize application version label and connect signals, when the node is ready.
func _ready():
	# Initialize app version
	app_version.text = "version " + str(ProjectSettings.get_setting("application/config/version"))
	_connect_signals()


## Connects to [EventBus]'s signals.
func _connect_signals() -> void:
	EventBus.update_ui_requested.connect(_on_update_ui_requested)
	EventBus.apply_ui_theme_requested.connect(_on_apply_ui_theme_requested)


## Applies UI theme based of [member Data.current_ui_theme] to UI components with-in the scene. [br]
##
## [br]
##
## Connects to [signal EventBus.apply_ui_theme_requested].
func _on_apply_ui_theme_requested() -> void:
	background_panel.theme = Data.current_ui_theme
	current_progress_container.update_ui()


## Update UI elements. [br]
##
## [br]
##
## Connects to [signal EventBus.update_ui_requested].
func _on_update_ui_requested() -> void:
	# Update all UI elements in current progress container
	current_progress_container.update_ui()
