## UI Manager.
##
## [br]
##
## Controls the behavior of UI elements. [br]
##
## [br]
## 
## Path: [code]res://src/ui/ui_manager.gd[/code]


class_name UIManager
extends Node


## App versiob label.
@onready var app_version: Label = %AppVersion

## Current progress container.
@onready var current_progress_container: VBoxContainer = %CurrentProgressContainer

## Previous progress container.
@onready var previous_progress_container: HBoxContainer = %PreviousProgressContainer


## Update UI elements.
func update_ui() -> void:
	# Update all UI elements in current progress container
	current_progress_container.update_ui()
	# Update all UI elements in previous progress container
	previous_progress_container.update_ui()


# Called when the node enters the scene tree for the first time.
func _ready():
	# Set app version label
	app_version.text = "version " + str(ProjectSettings.get_setting("application/config/version"))
