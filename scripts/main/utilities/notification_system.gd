## Manages the queue of notifications to be displayed.
##
## Uses an [AnimationPlayer] node to queue notifications and ensure they are 
## shown one at a time. [br]
##
## [br]
##
## Usage: [br]
## • [method create_notification]: Creates and shows a notification. [br]
##
## [br]
##
## Path: [code]res://scenes/main/utilities/notification_system.gd[/code]


class_name NotificationSystem
extends Node


## Preloaded scene for creating notification instances.
const NOTIFICATION_SCENE: PackedScene = preload(GlobalVariables.NOTIFICATION_SCENE_PATH)

## Queue for storing pending notifications.
var notifications_queue: Array = []

## Currently displayed notification.
var current_notification: CanvasLayer = null

## Animation player for notification animations (Used to display and hide notifications).
@onready var notification_animation_player: AnimationPlayer = %NotificationAnimationPlayer


## Creates and queues a notification with optional extended duration. [br]
##
## [br]
##
## Parameters: [br]
## • [param notification_text] ([String]): Text to display in the notification. [br]
## • [param extend_duration] ([bool]): If [code]true[/code], doubles the display duration.
## Default: [code]false[/code] [br]
##
## [br]
##
## See [method NotificationManager._ready] for more details.
func create_notification(notification_text: String, extend_duration: bool = false) -> void:
	var notification_node: CanvasLayer = NOTIFICATION_SCENE.instantiate()
	notification_node.get_node("%NotificationLabel").text = notification_text
	
	# Apply extended duration if requested
	if extend_duration == true:
		notification_node.extend_duration = true
	
	# Set and show current notification, if none
	if current_notification == null:
		current_notification = notification_node
		_show_notification()
	# Else, add notification to queue
	else:
		notifications_queue.append(notification_node)


## Displays the current notification based on [member current_notification].
func _show_notification() -> void:
	add_child(current_notification)
	# Signal for displaying next notification in queue
	current_notification.notification_removed.connect(_show_next_notification)
	current_notification.show_ui()


## Handles displaying the next notification from the queue based on [member notifications_queue].
func _show_next_notification() -> void:
	# Reset current notification
	current_notification = null
	
	# Display next notification in queue, if any	
	if notifications_queue.size() > 0:
		var next_notification: CanvasLayer = notifications_queue.pop_front()
		current_notification = next_notification
		_show_notification()
