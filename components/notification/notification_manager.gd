class_name NotificationManager
extends CanvasLayer


## Controls the behavior of individual notifications.
##
## Manages the display of notifications using an [AnimationPlayer] node.
## Handles showing, hiding, and adjusting the display duration of notifications.
## [br]
##
## Path: [code]res://scripts/notification_manager.gd[/code]


## Signal handler for removing a notification. [br]
##
## Emits when a notification is removed from the scene.
signal notification_removed

## Extend notification duration.
var extend_duration: bool = false

## Background panel container.
@onready var background_panel_container: PanelContainer = %BackgroundPanelContainer

## Notification animation player.
@onready var animation_player: AnimationPlayer = %AnimationPlayer


## Applies UI theme, hides UI, and extends display duration if needed, when node is ready.
func _ready():
	_apply_ui_theme()
	_hide_ui()
	# Reduces animation speed to half, if extend duration is true
	if extend_duration == true:
		animation_player.speed_scale = 0.5


## Shows the notification UI by playing the "show_notification" animation.
## Shows the notification.
func show_ui() -> void:
	# Show notification by playing "show_notification" animation
	animation_player.play("show_notification")


## Applies the UI theme based on [member GlobalVariables.current_ui_theme].
func _apply_ui_theme() -> void:
	background_panel_container.theme = Data.current_ui_theme
	
	# Create stylebox variant
	var new_stylebox: StyleBoxFlat = Data.create_custom_panel_stylebox()
	 # Check if the current theme has borders enabled, and apply them
	for theme in Data.available_themes:
		if theme == Data.get_theme_name(Data.current_ui_theme):
			if Data.available_themes[theme]["border"] == true:
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
