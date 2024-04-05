## Notification Manager.
## 
## Controls the behavior of notification. [br]
##
## [br]
##
## Path: [code]res://src/ui/notification/notification_manager.gd[/code]


class_name NotificationManager
extends CanvasLayer


## Notification animation player.
@onready var animation_player: AnimationPlayer = %AnimationPlayer

## Signal for removing notification.
signal notification_removed

## Extend notificatio duration.
var extend_duration: bool = false


## Show notification.
func show_ui() -> void:
	# Play notification animation
	animation_player.play("show_notification")


## Hide notification.
func hide_ui() -> void:
	# Change visibility
	visible = false


## Remove notification. (Removes scene from tree).
func remove_ui() -> void:
	# Emit notification removed signal
	notification_removed.emit()
	# Delete scene from tree
	get_parent().remove_child(self)
	queue_free()


# Called when the node enters the scene tree for the first time.
func _ready():
	# Hide notification UI as default
	hide_ui()
	# Check if extend duration is true
	if extend_duration == true:
		# Extend animation play speed
		animation_player.speed_scale = 0.5
