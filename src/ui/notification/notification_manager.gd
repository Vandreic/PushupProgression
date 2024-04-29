## Notification Manager.
## 
## Controls the behavior of notification. [br]
##
## [br]
##
## Path: [code]res://src/ui/notification/notification_manager.gd[/code]


class_name NotificationManager
extends CanvasLayer

## Background panel container.
@onready var background_panel_container: PanelContainer = %BackgroundPanelContainer

## Notification animation player.
@onready var animation_player: AnimationPlayer = %AnimationPlayer

## Extend notification duration.
var extend_duration: bool = false

## Signal for removing notification.
signal notification_removed


## Apply UI theme.
func apply_current_ui_theme() -> void:
	# Apply current theme
	background_panel_container.theme = GlobalVariables.current_ui_theme
	# Create stylebox variant
	var new_stylebox: StyleBoxFlat = GlobalVariables.create_custom_panel_stylebox()
	
	# Loop trough themes
	for theme in GlobalVariables.available_themes:
		# Get chosen theme (based of instance id)
		if GlobalVariables.current_ui_theme.get_instance_id() == GlobalVariables.available_themes[theme]["instance_id"]:
			# Check if theme has borders
			if GlobalVariables.available_themes[theme]["border"] == true:
				# Add borders
				new_stylebox.set_border_width_all(3)
	
	# Override panel theme stylebox
	background_panel_container.add_theme_stylebox_override("panel", new_stylebox)


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
	# Apply UI theme
	apply_current_ui_theme()
	# Hide notification UI as default
	hide_ui()
	# Check if extend duration is true
	if extend_duration == true:
		# Reduces animation speed to half, doubling the display duration
		animation_player.speed_scale = 0.5
