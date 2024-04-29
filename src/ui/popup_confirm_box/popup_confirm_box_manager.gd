## Popup Confirm Box Manager.
## 
## Controls the behavior of popup confirm box. [br]
##
## [br]
##
## Path: [code]res://src/ui/popup_confirm_box/popup_confirm_box_manager.gd[/code]


class_name PopupConfirmBoxManager
extends CanvasLayer

## Background panel container.
@onready var background_panel_container: PanelContainer = %BackgroundPanelContainer


## Info label text.
@onready var info_text_label: Label = %InfoTextLabel

## Confirm button.
@onready var confirm_button: Button = %ConfirmButton

## Cancel button.
@onready var cancel_button: Button = %CancelButton

## String for storing selected reset option. [br][br]
## Gets defined when confirmation box is created.
## See [member ResetOptionsMenuManager.open_popup_confirm_box] for more details.
var selected_reset_option: String


## Apply UI theme.
func apply_current_ui_theme() -> void:
	# Apply current theme
	background_panel_container.theme = GlobalVariables.current_ui_theme
	# Create stylebox variant
	var new_stylebox: StyleBoxFlat = GlobalVariables.create_custom_panel_stylebox()
	# Override panel theme stylebox
	background_panel_container.add_theme_stylebox_override("panel", new_stylebox)


## Update information text inside box.
func update_info_text(text: String) -> void:	
	info_text_label.text = text	+ "\n\n" + "Press \"Confirm\" to procced."


## Close popup confirm box (Removes scene from tree).
func close_popup_box() -> void:
	# Delete scene from tree
	get_parent().remove_child(self)
	queue_free()


## On [member PopupConfirmBoxManager.cancel_button] pressed.
func _on_cancel_button_pressed() -> void:
	# Close popup box
	close_popup_box()


## On [member PopupConfirmBoxManager.confirm_button] pressed.
func _on_confirm_button_pressed() -> void:	
	# Reset data based of reset_option value
	get_tree().call_group("save_system", "reset_data", selected_reset_option)
	# Close popup box
	close_popup_box()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect pressed button signals
	cancel_button.pressed.connect(_on_cancel_button_pressed)
	confirm_button.pressed.connect(_on_confirm_button_pressed)
	# Apply UI theme
	apply_current_ui_theme()
