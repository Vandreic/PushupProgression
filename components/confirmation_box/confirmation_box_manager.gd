class_name ConfirmationBoxManager
extends CanvasLayer


## Manages the confirmation dialog for user confirmations.
## 
## Controls the behavior of confirmation box. [br]
##
## [br]
##
## Path: [code]res://scripts/confirmation_box_manager.gd[/code]


## String for storing selected reset option. [br]
##
## [br]
##
## Gets defined when confirmation box is created. [br]
## See [member ResetOptionsMenuManager.open_popup_confirm_box] for more details.
var selected_reset_option: String

## Background panel container.
@onready var background_panel_container: PanelContainer = %BackgroundPanelContainer

## Info label text.
@onready var info_text_label: Label = %InfoTextLabel

## Confirm button.
@onready var confirm_button: Button = %ConfirmButton

## Cancel button.
@onready var cancel_button: Button = %CancelButton


## Sets up button connections, when the node is ready.
func _ready() -> void:
	# Connect pressed button signals
	cancel_button.pressed.connect(_on_cancel_button_pressed)
	confirm_button.pressed.connect(_on_confirm_button_pressed)
	# Apply UI theme
	_apply_ui_theme()


## Updates the information text inside the confirmation box.
func update_info_text(text: String) -> void:
	info_text_label.text = text	+ "\n\n" + "Press \"Confirm\" to procced."


## Applies the UI theme based on [member Data.current_ui_theme].
func _apply_ui_theme() -> void:
	background_panel_container.theme = Data.current_ui_theme
	var new_stylebox: StyleBoxFlat = Data.create_custom_panel_stylebox()
	background_panel_container.add_theme_stylebox_override("panel", new_stylebox)


## Signal handler for when the [member cancel_button] is pressed. [br]
##
## [br]
##
## Removes the confirmation box from the tree.
func _on_cancel_button_pressed() -> void:
	_close_confirmation_box()


## Signal handler for when the [member confirm_button] is pressed. [br]
##
## [br]
##
## Saves data and closes confirmation box.
func _on_confirm_button_pressed() -> void:	
	EventBus.reset_data_requested.emit(selected_reset_option)
	
	# Reset data based of reset_option value
	get_tree().call_group("save_system", "reset_data", selected_reset_option)
	# Close confirmation box
	_close_confirmation_box()


## Close confirmation box (Removes scene from tree).
func _close_confirmation_box() -> void:
	get_parent().remove_child(self)
	queue_free()
