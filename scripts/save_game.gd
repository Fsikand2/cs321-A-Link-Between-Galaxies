extends Node

const SAVE_PATH = "user://save.json"
var data_to_load: Dictionary = {}

func read_data() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {}

	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	file.close()
	if error != OK:
		return {}
	var data = json.data
	if not data is Dictionary:
		return {}

	for field in ["position_x", "position_y", "keys"]:
		if not data.has(field) or not (data[field] is float or data[field] is int):
			return {}
		if not is_finite(float(data[field])):
			return {}

	if data["keys"] < 0 or not data.get("game_over") is bool:
		return {}
	if not data.get("removed_cells") is Array:
		return {}
	for cell in data["removed_cells"]:
		if not cell is Array or cell.size() != 2:
			return {}
		for coordinate in cell:
			if not (coordinate is float or coordinate is int):
				return {}
			if not is_finite(float(coordinate)):
				return {}

	return data
