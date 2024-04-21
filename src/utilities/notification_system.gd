## Notification System.
## 
## Displays notifications. [br]
##
## [br]
##
## Path: [code]res://src/utilities/notification_system.gd[/code]


class_name NotificationSystem
extends Node


## Notification scene.
const NOTIFICATION_SCENE: PackedScene = preload("res://src/ui/notification/notification.tscn")

## Notification animation player.
@onready var notification_animation_player: AnimationPlayer = %NotificationAnimationPlayer

## Queue for storing pending notifications.
var notifications_queue: Array = []

## Current notification.
var current_notification: CanvasLayer = null


## Create notification. [br]
## Extends duration if [param extend_duration] is [code]true[/code].
func create_notification(notification_text: String, extend_duration: bool = false) -> void:
	# Instantiate notification scene
	var notification_node: CanvasLayer = NOTIFICATION_SCENE.instantiate()
	# Get panel container node
	var panel_container: PanelContainer = notification_node.get_node("%BackgroundPanelContainer")
	
	# Get normal state button background color from chosen UI theme
	var bg_color: Color = GlobalVariables.LIGHT_UI_THEME.get_theme_item\
	(Theme.DATA_TYPE_STYLEBOX, "normal", "Button").bg_color
	# Duplicate panel container theme stylebox
	var new_theme_stylebox: StyleBoxFlat = GlobalVariables.LIGHT_UI_THEME.get_theme_item\
	(Theme.DATA_TYPE_STYLEBOX, "panel", "PanelContainer").duplicate()
	# Change stylebox background color
	new_theme_stylebox.bg_color = bg_color
	# Apply new theme stylebox
	panel_container.add_theme_stylebox_override("panel", new_theme_stylebox)
	
	# Get font color from chosen UI theme
	var font_color: Color = GlobalVariables.LIGHT_UI_THEME.get_color("label", "Label")
	# Change label font color
	panel_container.add_theme_color_override("font_color", font_color)
	
	# Set notification text label
	notification_node.get_node("%NotificationLabel").text = notification_text
	# Apply extended duration if requested
	if extend_duration == true:
		notification_node.extend_duration = true
	
	# Set and show current notification, if none
	if current_notification == null:
		current_notification = notification_node
		show_notification()
	# Else, add notification to queue
	else:
		notifications_queue.append(notification_node)
		

## Show notification.
func show_notification() -> void:
	# Add notification to tree
	add_child(current_notification)
	# Connect to notification removed signal
	current_notification.notification_removed.connect(show_next_notification)
	# Show notification ui
	current_notification.show_ui()


## Show next notification.
func show_next_notification() -> void:
	# Reset current notification
	current_notification = null
	
	# Check if any notifications in queue	
	if notifications_queue.size() > 0:
		# Get next notification and remove from queue 
		var next_notification: CanvasLayer = notifications_queue.pop_front()
		# Set new current notification
		current_notification = next_notification
		# Show notification
		show_notification()
