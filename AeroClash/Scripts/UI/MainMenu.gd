extends Control

var name_p1: LineEdit
var name_p2: LineEdit


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.04, 0.07, 0.12)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var title := Label.new()
	title.text = "AEROCLASH"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 52)
	title.position = Vector2(0, 35)
	title.size = Vector2(Global.SCREEN_SIZE.x, 70)
	add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Shooter 2D competitivo con simulación aleatoria"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 18)
	subtitle.position = Vector2(0, 105)
	subtitle.size = Vector2(Global.SCREEN_SIZE.x, 30)
	add_child(subtitle)

	var panel := PanelContainer.new()
	panel.position = Vector2(356, 150)
	panel.size = Vector2(440, 430)
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var lbl1 := Label.new()
	lbl1.text = "Nombre Player 1"
	vbox.add_child(lbl1)

	name_p1 = LineEdit.new()
	name_p1.text = Global.player1_name
	vbox.add_child(name_p1)

	var lbl2 := Label.new()
	lbl2.text = "Nombre Player 2"
	vbox.add_child(lbl2)

	name_p2 = LineEdit.new()
	name_p2.text = Global.player2_name
	vbox.add_child(name_p2)

	_add_button(vbox, "Historia 1 jugador", Callable(self, "_start_story"))
	_add_button(vbox, "Score Battle 2 jugadores", Callable(self, "_start_score_battle"))
	_add_button(vbox, "PvP Arena 1 vs 1", Callable(self, "_start_pvp"))
	_add_button(vbox, "Cooperativo", Callable(self, "_start_coop"))
	_add_button(vbox, "Ver récords TOP 5", Callable(self, "_show_records"))
	_add_button(vbox, "Salir", Callable(self, "_quit_game"))

	var controls := Label.new()
	controls.text = "P1: WASD + SPACE / Gamepad 1\nP2: Flechas + ENTER / Gamepad 2"
	controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls.position = Vector2(0, 590)
	controls.size = Vector2(Global.SCREEN_SIZE.x, 40)
	add_child(controls)


func _add_button(parent: VBoxContainer, text: String, callback: Callable) -> void:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(360, 42)
	b.pressed.connect(callback)
	parent.add_child(b)


func _save_names() -> void:
	Global.player1_name = name_p1.text.strip_edges()
	Global.player2_name = name_p2.text.strip_edges()

	if Global.player1_name == "":
		Global.player1_name = "PLAYER 1"
	if Global.player2_name == "":
		Global.player2_name = "PLAYER 2"


func _start_story() -> void:
	_save_names()
	Global.reset_game(Global.GameMode.STORY)
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")


func _start_score_battle() -> void:
	_save_names()
	Global.reset_game(Global.GameMode.SCORE_BATTLE)
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")


func _start_pvp() -> void:
	_save_names()
	Global.reset_game(Global.GameMode.PVP_ARENA)
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")


func _start_coop() -> void:
	_save_names()
	Global.reset_game(Global.GameMode.COOP)
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")


func _show_records() -> void:
	get_tree().change_scene_to_file("res://Scenes/Records.tscn")


func _quit_game() -> void:
	get_tree().quit()
