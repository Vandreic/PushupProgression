## Popup Confirm Box Manager Script.
##
## [br]
## 
## This script controls the behavior of a popup confirm box. [br]
##
## [br]
##
## Path: [code]res://src/ui/popup_confirm_box/popup_confirm_box_manager.gd[/code]


class_name PopupConfirmBoxManager
extends CanvasLayer

## Info label text.
@onready var info_text_label: Label = %InfoTextLabel

## Confirm button.
@onready var confirm_button: Button = %ConfirmButton

## Cancel button.
@onready var cancel_button: Button = %CancelButton





# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
