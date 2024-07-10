extends Node


## Handles scene transitions and various UI-related requests. [br]
##
## [br]
##
## This autoloaded script manages scene changes, UI additions, and scene reloading.
## It also handles special UI requests like opening confirmation boxes and closing
## the options menu, using predefined paths and signals to coordinate these changes. [br]
##
## [br]
##
## It is accessed globally as [code]SceneManager[/code]. [br]
##
## [br]
##
## [b]Path:[/b] [code]res://autoload/scene_manager.gd[/code]


## Signal to request changing the scene. [br]
##
## [br]
##
## Emitted when a scene change is requested. [br]
##
## [br]
##
## Parameters: [br]
## • [param scene_name] ([String]): The name of the scene to change to. [br]
##
## [br]
##
## See [method _on_change_scene_requested] for more details.
signal change_scene_requested(scene_name: String)

## Signal to request adding a UI scene. [br]
##
## [br]
##
## Emitted when adding a UI scene is requested. [br]
##
## [br]
##
## Parameters: [br]
## • [param scene_name] ([String]): The name of the UI scene to add. [br]
##
## [br]
##
## See [method _on_add_scene_requested] for more details.
signal add_scene_requested(scene_name: String)

## Signal to request reloading the current scene. [br]
##
## [br]
##
## Emitted when reloading the current scene is requested. [br]
##
## [br]
##
## Parameters: [br]
## • [param scene_name] ([String]): The name of the scene to reload. [br]
##
## [br]
##
## See [method _on_reload_current_scene_requested] for more details.
signal reload_current_scene_requested(scene_name: String)

## Signal to request closing the options menu. [br]
##
## [br]
##
## Emitted when closing the options menu is requested. [br]
##
## [br]
##
## See [method _on_close_options_menu_requested] for more details.
signal close_options_menu_requested

## Signal to request opening a confirmation box. [br]
##
## [br]
##
## Emitted when adding a pop-up confirmation box. [br]
##
## [br]
##
## See [method _on_open_confirmation_box_requested] for more details.
signal open_confirmation_box_requested


## The notification scene.
const NOTIFICATION_SCENE: PackedScene = preload("res://scenes/notification.tscn")

## The confirmation box scene.
const CONFIRMATION_BOX_SCENE: PackedScene = preload("res://scenes/confirmation_box.tscn")


## Dictionary mapping scene names to their file paths.
var scene_dict: Dictionary = {
	"Main": "res://scenes/main.tscn",
	"OptionsMenu": "res://scenes/options_menu/options_menu.tscn",
	"Settings": "res://scenes/options_menu/options/settings_menu.tscn",
	"Appearance": "res://scenes/options_menu/options/appearance_menu.tscn",
	"ResetOptions": "res://scenes/options_menu/options/reset_options_menu.tscn",
	"LogConsole": "res://scenes/log_console.tscn",
	"ConfirmationBox": "res://scenes/confirmation_box.tscn",
}


## Connects the signals to their respective handlers when node is ready.
func _ready() -> void:
	change_scene_requested.connect(_on_change_scene_requested)
	add_scene_requested.connect(_on_add_scene_requested)
	reload_current_scene_requested.connect(_on_reload_current_scene_requested)
	close_options_menu_requested.connect(_on_close_options_menu_requested)
	open_confirmation_box_requested.connect(_on_open_confirmation_box_requested)


## Handler for the [signal change_scene_requested] signal. [br]
##
## [br]
##
## This method is called when a scene change is requested.
## It defers the actual scene change to avoid potential issues with the current frame. [br]
##
## [br]
##
## Parameters: [br]
## • [code]scene_name[/code] ([String]): The name of the scene to change to.
func _on_change_scene_requested(scene_name: String) -> void:
	call_deferred("_deferred_change_scene", scene_name)


## Deferred handler for changing the scene. [br]
##
## [br]
##
## This method performs the actual scene change after ensuring the scene exists. [br]
##
## [br]
##
## Parameters: [br]
## • [code]scene_name[/code] ([String]): The name of the scene to change to.
func _deferred_change_scene(scene_name: String) -> void:
	# If chosen scene does not exist in scene_dict, notify user and return
	if not scene_dict.has(scene_name):
		var _message: String = "Invalid scene name! No scene \"%s\" found in scene_dict." % scene_name
		EventBus.create_notification_requested.emit(_message, false)
		print(_message)
		return
	
	var new_scene: Node = load(scene_dict[scene_name]).instantiate()
	var root = get_tree().get_root()
	root.get_child(root.get_child_count() - 1).free()
	root.add_child(new_scene)
	get_tree().set_current_scene(new_scene)


## Handler for the [signal add_scene_requested] signal. [br]
##
## [br]
##
## This method is called when a UI scene addition is requested. [br]
##
## [br]
##
## Parameters: [br]
## • [code]scene_name[/code] ([String]): The name of the UI scene to add.
func _on_add_scene_requested(scene_name: String) -> void:
	var ui_node: CanvasLayer = _get_ui_scene_as_node()
	
	# If chosen scene does not exist in scene_dict, notify user and return
	if not scene_dict.has(scene_name):
		print("No scene named \"%s\" registered." % scene_name)
		return
	
	var new_scene: Node = load(scene_dict[scene_name]).instantiate()
	new_scene.name = scene_name
	ui_node.add_child(new_scene)


## Handler for the [signal reload_current_scene_requested] signal. [br]
##
## [br]
##
## This method is called when reloading the current scene is requested. [br]
##
## [br]
##
## Parameters: [br]
## • [code]scene_name[/code] ([String]): The name of the scene to reload.
func _on_reload_current_scene_requested(scene_name: String) -> void:
	var ui_node: CanvasLayer = _get_ui_scene_as_node()
	
	# If chosen scene does not exist in scene_dict, notify user and return
	if not scene_dict.has(scene_name):
		print("No scene named \"%s\" registered." % scene_name)
		return
	
	# Remove current scene
	var current_node: CanvasLayer = ui_node.get_node(scene_name)
	ui_node.remove_child(current_node)
	current_node.queue_free()
	
	# Add new scene (Reloads current scene)
	call_deferred("_on_add_scene_requested", scene_name)


## Handler for the [signal close_options_menu_requested] signal. [br]
##
## [br]
##
## This method is called when closing the options menu is requested.
func _on_close_options_menu_requested() -> void:
	var ui_node: CanvasLayer = _get_ui_scene_as_node()
	var options_menu: CanvasLayer = ui_node.get_node("OptionsMenu")
	ui_node.remove_child(options_menu)
	options_menu.queue_free()


## Handler for the [signal open_confirmation_box_requested] signal. [br]
##
## [br]
##
## This method is called when opening a confirmation box is requested.
func _on_open_confirmation_box_requested(info_text: String, reset_option: String) -> void:
	var ui_node: CanvasLayer = _get_ui_scene_as_node()
	var confirmation_box: CanvasLayer = load(scene_dict["ConfirmationBox"]).instantiate()
	
	# Update info text inside box when node is ready
	confirmation_box.ready.connect(confirmation_box.update_info_text.bind(info_text))
	confirmation_box.ready.connect(confirmation_box._apply_ui_theme)
	# Store reset option within the confirmation box
	confirmation_box.selected_reset_option = reset_option
	
	ui_node.add_child(confirmation_box)


## Retrieves the "UI" node from the "Main" node in the scene tree. [br]
##
## [br]
##
## Returns: [br]
## • [CanvasLayer]: The [code]UI[/code] node that stores all the game UI, 
## or [code]null[/code] if not found.
func _get_ui_scene_as_node() -> CanvasLayer:
	if not get_tree().root.has_node("Main"):
		print("\"Main\" node not found in scene tree.")
		return
	
	var main_node: Node = get_tree().root.get_node("Main")
	
	if not main_node.has_node("UI"):
		print("\"UI\" node not found in scene tree.")
		return
	
	var ui_node: CanvasLayer = main_node.get_node("UI")
	return ui_node
