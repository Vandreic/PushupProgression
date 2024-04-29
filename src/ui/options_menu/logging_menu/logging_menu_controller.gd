## Logging Menu Controller.
## 
## Creates log messages and controls the behavior of logging menu. [br]
##
## [br]
##
## Path: [code]res://src/ui/options_menu/logging_menu/logging_menu_controller.gd[/code]


class_name LoggingMenuController
extends Control


## Background panel.
@onready var background_panel: Panel = %BackgroundPanel

## Container for logs.
@onready var logs_container: VBoxContainer = %LogsContainer

## Base log label. Used to create new logs.
@onready var base_log_label: Label = %BaseLogLabel

## Close logging menu button.
@onready var close_menu_button: Button = %CloseMenuButton

## Total logs counter.
var total_logs_counter: int = 1


## Apply UI theme.
func apply_current_ui_theme() -> void:
	# Apply chosen UI theme to background panel
	background_panel.theme = GlobalVariables.current_ui_theme


## Create UI for logs messages
func create_log_entrys_ui() -> void:
	# Loop trough all logs inside logs array
	for log in GlobalVariables.logs_array:
		# Duplicate base log node
		var log_label: Label = base_log_label.duplicate()
		# Update node name
		log_label.name = "LogLabel" + str(total_logs_counter)
		# Update log text
		log_label.text = log
		# Add to container
		logs_container.add_child(log_label)
		# Update log counter
		total_logs_counter += 1
	
	# Delete base log node
	logs_container.remove_child(base_log_label)
	base_log_label.queue_free()


## On [member LoggingMenuController.close_menu_button] pressed.
func _on_close_menu_button_pressed() -> void:
	# Change to main scene
	get_tree().change_scene_to_file(GlobalVariables.MAIN_SCENE_PATH)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Apply UI theme
	apply_current_ui_theme()
	# Connect pressed button signals
	close_menu_button.pressed.connect(_on_close_menu_button_pressed)
	# Setup logs messages (UI)
	create_log_entrys_ui()
	# Apply UI theme
	apply_current_ui_theme()
	# Update app running flag
	GlobalVariables.is_app_running = true
