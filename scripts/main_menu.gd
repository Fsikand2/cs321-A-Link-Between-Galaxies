extends Node

func _ready() -> void:
	$VBoxContainer/play.grab_focus()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/testworld.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
