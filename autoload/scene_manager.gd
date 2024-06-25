## Manages scenes and handles scene switching functionality.
#FIXME


extends Node


## Signal emitted when a scene change is requested.
signal change_scene_requested(scene_name: String)

## Signal emitted when adding an UI scene is requested.
signal add_scene_requested(scene_name: String)

## Signal emitted when reloading current scene is requested.
signal reload_current_scene_requested(scene_name: String)

## Signal emitted when closing options menu is requested.
signal close_options_menu_requested

## Signal emitted when adding a pop-up confirmation box.
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


func _ready() -> void:
	change_scene_requested.connect(_on_change_scene_requested)
	add_scene_requested.connect(_on_add_scene_requested)
	reload_current_scene_requested.connect(_on_reload_current_scene_requested)
	
	close_options_menu_requested.connect(_on_close_options_menu_requested)
	open_confirmation_box_requested.connect(_on_open_confirmation_box_requested)
	

func _on_change_scene_requested(scene_name: String) -> void:
	call_deferred("_deferred_change_scene", scene_name)


func _deferred_change_scene(scene_name: String) -> void:
	# If chosen scene does not exists in scene_dict, notify user and return 
	if not scene_dict.has(scene_name):
		#FIXME
		print("No such scene registred.")
		return
	
	var new_scene: Node = load(scene_dict[scene_name]).instantiate()
	var root = get_tree().get_root()
	root.get_child(root.get_child_count() - 1).free()
	root.add_child(new_scene)
	get_tree().set_current_scene(new_scene)


func _on_add_scene_requested(scene_name: String) -> void:
	var ui_node: CanvasLayer = _get_ui_scene_as_node()
	
	# If chosen scene does not exists in scene_dict, notify user and return 
	if not scene_dict.has(scene_name):
		#FIXME
		print("No scene named \"%s\" registred." % scene_name)
		return
	
	var new_scene: Node = load(scene_dict[scene_name]).instantiate()
	new_scene.name = scene_name
	ui_node.add_child(new_scene)


func _on_reload_current_scene_requested(scene_name: String) -> void:
	var ui_node: CanvasLayer = _get_ui_scene_as_node()
	
	# If chosen scene does not exists in scene_dict, notify user and return 
	if not scene_dict.has(scene_name):
		#FIXME
		print("No scene named \"%s\" registred." % scene_name)
		return
	
	# Remove current scene
	var current_node: CanvasLayer = ui_node.get_node(scene_name)
	ui_node.remove_child(current_node)
	current_node.queue_free()
	
	# Add new scene (Reloads current scene)
	call_deferred("_on_add_scene_requested", scene_name)
	
	
func _on_close_options_menu_requested() -> void:
	var ui_node: CanvasLayer = _get_ui_scene_as_node()
	var options_menu: CanvasLayer = ui_node.get_node("OptionsMenu")
	ui_node.remove_child(options_menu)
	options_menu.queue_free()


func _on_open_confirmation_box_requested(info_text: String, reset_option: String) -> void:
	var ui_node: CanvasLayer = _get_ui_scene_as_node()
	var confirmation_box: CanvasLayer = load(scene_dict["ConfirmationBox"]).instantiate()
	
	# Update info text inside box when node is ready
	confirmation_box.ready.connect(confirmation_box.update_info_text.bind(info_text))
	confirmation_box.ready.connect(confirmation_box._apply_ui_theme)
	# Store reset option with-in the confirmation box
	confirmation_box.selected_reset_option = reset_option
	
	ui_node.add_child(confirmation_box)


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
	
