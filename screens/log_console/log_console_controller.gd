class_name LogConsoleController
extends Control


## Log Console Controller.
## 
## Creates log messages and controls the behavior of the log console. [br]
##
## [br]
##
## Path: [code]res://scripts/log_console_controller.gd[/code]


## Background panel.
@onready var background_panel: Panel = %BackgroundPanel

## Container for logs.
@onready var log_container: VBoxContainer = %LogContainer

## Template for new log labels.
@onready var log_template: Label = %LogTemplate

## Close logging menu button.
@onready var close_button: Button = %CloseButton

## Total log counter.
var log_count: int = 1


## Sets up button connection, applies current UI theme, and populates log console
## when the node is ready.
func _ready() -> void:
	close_button.pressed.connect(_on_close_button_pressed)
	_apply_ui_theme()
	_populate_log_ui()
	# Update app running flag
	Data.is_app_running = true


## Signal handler for when the [member close_button] is pressed. [br]
##
## [br]
##
## Changes to main scene.
func _on_close_button_pressed() -> void:
	SceneManager.change_scene_requested.emit("Main")


## Apply the current UI theme.
func _apply_ui_theme() -> void:
	# Apply current UI theme to background panel
	background_panel.theme = Data.current_ui_theme


## Create the UI for log messages.
func _populate_log_ui() -> void:
	for log_message in Data.get_logs_array():
		var log_label: Label = log_template.duplicate()
		log_label.name = "LogLabel" + str(log_count)
		log_label.text = log_message
		log_container.add_child(log_label)
		log_count += 1

	log_container.remove_child(log_template)
	log_template.queue_free()
	
