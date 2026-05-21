extends CanvasLayer

var lives_p1: Label
var score_p1: Label
var lives_p2: Label
var score_p2: Label
var level_label: Label
var mode_label: Label
var center_message: Label


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	var top_bg := ColorRect.new()
	top_bg.color = Color(0, 0, 0, 0.45)
	top_bg.position = Vector2(0, 0)
	top_bg.size = Vector2(Global.SCREEN_SIZE.x, 70)
	add_child(top_bg)

	lives_p1 = _make_label(Vector2(20, 12), Vector2(180, 25), 20)
	score_p1 = _make_label(Vector2(210, 12), Vector2(210, 25), 20)
	level_label = _make_label(Vector2(460, 12), Vector2(210, 25), 20)
	mode_label = _make_label(Vector2(700, 12), Vector2(430, 25), 18)

	lives_p2 = _make_label(Vector2(20, 40), Vector2(180, 25), 20)
	score_p2 = _make_label(Vector2(210, 40), Vector2(210, 25), 20)

	center_message = _make_label(Vector2(0, 260), Vector2(Global.SCREEN_SIZE.x, 120), 38)
	center_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER


func _make_label(pos: Vector2, size: Vector2, font_size: int) -> Label:
	var label := Label.new()
	label.position = pos
	label.size = size
	label.add_theme_font_size_override("font_size", font_size)
	add_child(label)
	return label


func _process(_delta: float) -> void:
	lives_p1.text = "VIDAS P1: " + str(Global.player1_lives)
	score_p1.text = "SCORE P1: " + str(Global.player1_score)
	lives_p2.text = "VIDAS P2: " + str(Global.player2_lives)
	score_p2.text = "SCORE P2: " + str(Global.player2_score)
	level_label.text = "NIVEL: " + str(Global.current_level)
	mode_label.text = "MODO: " + Global.get_mode_name()

	if Global.game_over:
		center_message.text = Global.winner_text + "\nPresiona ESC para volver al menú"
	else:
		center_message.text = ""
