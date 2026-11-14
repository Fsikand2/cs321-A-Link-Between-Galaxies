extends Control

func _ready() -> void:
	$VBoxContainer/load.disabled = SaveGame.read_data().is_empty()

func _on_play_pressed() -> void:
	SaveGame.data_to_load = {}
	get_tree().change_scene_to_file("res://scenes/testworld.tscn")

func _on_load_pressed() -> void:
	SaveGame.data_to_load = SaveGame.read_data()
	if SaveGame.data_to_load.is_empty():
		$VBoxContainer/load.disabled = true
		return
	get_tree().change_scene_to_file("res://scenes/testworld.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
