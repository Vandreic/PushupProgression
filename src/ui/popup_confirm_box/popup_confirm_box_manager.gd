## Popup Confirm Box Manager Script.
## 
## This script controls the behavior of a popup confirm box. [br]
##
## [br]
##
## Path: [code]res://src/ui/popup_confirm_box/popup_confirm_box_manager.gd[/code]

#TODO: Dynamically adjust box size based on info text size


class_name PopupConfirmBoxManager
extends CanvasLayer

## Info label text.
@onready var info_text_label: Label = %InfoTextLabel

## Confirm button.
@onready var confirm_button: Button = %ConfirmButton

## Cancel button.
@onready var cancel_button: Button = %CancelButton

## Signal: Emits when [member PopupConfirmBoxManager.confirm_button] pressed
signal confirm_button_pressed

## Signal: Emits when [member PopupConfirmBoxManager.cancel_button] pressed
signal cancel_button_pressed


## Update information text inside box.
func update_text(text: String) -> void:	
	info_text_label.text = text	+ "\n\n" + "Press \"Confirm\" to procced."


## Close popup confirm box (Removes scene from tree).
func close_popup_box() -> void:
	# Delete scene from tree
	get_parent().remove_child(self)
	queue_free()


## On [member PopupConfirmBoxManager.cancel_button] pressed.
func _on_cancel_button_pressed() -> void:
	# Emit button signal
	cancel_button_pressed.emit()
	# Close popup box
	close_popup_box()


## On [member PopupConfirmBoxManager.confirm_button] pressed.
func _on_confirm_button_pressed() -> void:
	# Emit button signal
	confirm_button_pressed.emit()
	# Close popup box
	close_popup_box()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect pressed button signals
	cancel_button.pressed.connect(_on_cancel_button_pressed)
	confirm_button.pressed.connect(_on_confirm_button_pressed)
