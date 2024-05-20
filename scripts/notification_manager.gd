## Controls the behavior of individual notifications.
##
## Uses an [AnimationPlayer] node to handle showing, hiding, and controlling the
## display duration of the notification. [br]
##
## [br]
##
## Path: [code]res://scenes/notification/notification_manager.gd[/code]


class_name NotificationManager
extends CanvasLayer

## Signal for removing notification.
signal notification_removed

## Extend notification duration.
var extend_duration: bool = false

## Background panel container.
@onready var background_panel_container: PanelContainer = %BackgroundPanelContainer

## Notification animation player.
@onready var animation_player: AnimationPlayer = %AnimationPlayer


## Applies UI theme, hides UI, and extends display duration if needed.
func _ready():
	_apply_ui_theme()
	_hide_ui()
	# Reduces animation speed to half, if extend duration is true
	if extend_duration == true:
		animation_player.speed_scale = 0.5


## Shows the notification.
func show_ui() -> void:
	# Play notification animation
	animation_player.play("show_notification")


## Applies the UI theme based on [member GlobalVariables.current_ui_theme].
func _apply_ui_theme() -> void:
	background_panel_container.theme = GlobalVariables.current_ui_theme
	
	# Create stylebox variant
	var new_stylebox: StyleBoxFlat = GlobalVariables.create_custom_panel_stylebox()
	 # Check if the current theme has borders enabled and apply them
	for theme in GlobalVariables.available_themes:
		if GlobalVariables.current_ui_theme.get_instance_id() == GlobalVariables.available_themes[theme]["instance_id"]:
			if GlobalVariables.available_themes[theme]["border"] == true:
				new_stylebox.set_border_width_all(3)
	
	# Override panel theme stylebox
	background_panel_container.add_theme_stylebox_override("panel", new_stylebox)


## Hides the notification.
func _hide_ui() -> void:
	# Change visibility
	visible = false


## Removes the notification from the scene tree and emits a signal.
func _remove_ui() -> void:
	notification_removed.emit()
	get_parent().remove_child(self)
	queue_free()
