## Previous Progress Container Manager.
##
## [br]
##
## Controls the behavior UI elements within the previous progress container. [br]
##
## [br]
## 
## Path: [code]res://src/ui/previous_progress_container_manager.gd[/code]


class_name PreviousProgressContainerManager
extends HBoxContainer


## Base node for previous progress (Used for duplication).
@onready var base_previous_progress_container: VBoxContainer = %BasePreviousProgressContainer


## Update UI elements.
func update_ui() -> void:
	pass


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Hide base node as default
	base_previous_progress_container.visible = false
