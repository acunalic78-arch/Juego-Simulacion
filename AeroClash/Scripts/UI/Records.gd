extends Control


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.03, 0.04, 0.08)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var title := Label.new()
	title.text = "TOP 5 RÉCORDS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 42)
	title.position = Vector2(0, 40)
	title.size = Vector2(Global.SCREEN_SIZE.x, 60)
	add_child(title)

	var list := VBoxContainer.new()
	list.position = Vector2(320, 130)
	list.size = Vector2(540, 330)
	list.add_theme_constant_override("separation", 12)
	add_child(list)

	if SaveSystem.top_scores.is_empty():
		var empty := Label.new()
		empty.text = "Aún no hay records guardados."
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty.add_theme_font_size_override("font_size", 24)
		list.add_child(empty)
	else:
		for i in range(SaveSystem.top_scores.size()):
			var r: Dictionary = SaveSystem.top_scores[i]
			var row := Label.new()
			row.text = str(i + 1) + ". " + str(r.get("name", "Jugador")) + "  -  " + str(r.get("score", 0)) + " pts  (" + str(r.get("mode", "Modo")) + ")"
			row.add_theme_font_size_override("font_size", 22)
			list.add_child(row)

	var back := Button.new()
	back.text = "Volver al menú"
	back.position = Vector2(426, 520)
	back.size = Vector2(300, 50)
	back.pressed.connect(func(): get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn"))
	add_child(back)

	var clear := Button.new()
	clear.text = "Borrar récords"
	clear.position = Vector2(426, 580)
	clear.size = Vector2(300, 40)
	clear.pressed.connect(_clear_records)
	add_child(clear)


func _clear_records() -> void:
	SaveSystem.clear_records()
	get_tree().reload_current_scene()
