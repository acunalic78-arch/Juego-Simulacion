extends Node

const SAVE_PATH := "user://aeroclash_records.json"
var top_scores: Array = []


func _ready() -> void:
	load_records()


func load_records() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		top_scores = []
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		top_scores = []
		return

	var text := file.get_as_text()
	file.close()

	var data = JSON.parse_string(text)
	if typeof(data) == TYPE_ARRAY:
		top_scores = data
	else:
		top_scores = []


func save_records() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return

	file.store_string(JSON.stringify(top_scores, "\t"))
	file.close()


func add_record(player_name: String, score: int, mode_name: String) -> void:
	if score <= 0:
		return

	top_scores.append({
		"name": player_name,
		"score": score,
		"mode": mode_name,
		"date": Time.get_datetime_string_from_system(false, true)
	})

	top_scores.sort_custom(func(a, b): return int(a["score"]) > int(b["score"]))

	while top_scores.size() > 5:
		top_scores.pop_back()

	save_records()


func clear_records() -> void:
	top_scores.clear()
	save_records()
