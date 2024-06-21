extends Node


signal change_scene_request(scene_name: String)


var scene_dict: Dictionary = {
	"main": 			"res://scenes/main.tscn",
	"log_console": 		"res://scenes/log_console.tscn",
	"options_menu": 	"res://scenes/options_menu/options_menu.tscn",
	"settings": 		"res://scenes/options_menu/options/settings_menu.tscn",
	"appearance": 		"res://scenes/options_menu/options/appearance_menu.tscn",
	"reset_options": 	"res://scenes/options_menu/options/reset_options_menu.tscn",
}


func _ready() -> void:
	change_scene_request.connect(_change_scene)


func _change_scene(scene_name: String) -> void:
	call_deferred("_deferred_change_scene", scene_name)


func _deferred_change_scene(scene_name: String) -> void:
	var new_scene: Node = load(scene_dict[scene_name]).instantiate()
	var root = get_tree().get_root()
	root.get_child(root.get_child_count() - 1).free()
	root.add_child(new_scene)
	# Optionally, to make it compatible with the SceneTree.change_scene_to_file() API
	get_tree().set_current_scene(new_scene)
	
