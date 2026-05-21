extends Node2D

var players: Array = []
var spawn_timer := 0.0
var level_timer := 25.0
var boss_spawned := false
var boss_alive := false
var item_timer := 3.0
var star_container: Node2D

const PVP_CENTER_LEFT := 385.0
const PVP_CENTER_RIGHT := 767.0
const PVP_CENTER_TOP := 80.0
const PVP_CENTER_BOTTOM := 615.0
const PVP_CENTER_X := 576.0


func _ready() -> void:
	_build_background()
	_create_players()
	_create_hud()
	print("MODO: ", Global.get_mode_name())


func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
		return

	if Global.game_over:
		return

	_update_stars(delta)
	_update_level(delta)
	_update_spawner(delta)
	_update_item_spawner(delta)
	_check_game_over()


func _build_background() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.06, 0.07, 0.09)
	bg.position = Vector2.ZERO
	bg.size = Global.SCREEN_SIZE
	add_child(bg)

	if Global.current_mode == Global.GameMode.PVP_ARENA:
		_build_pvp_arena_guides()

	star_container = Node2D.new()
	add_child(star_container)

	for i in range(70):
		var star := ColorRect.new()
		star.color = Color(1, 1, 1, randf_range(0.25, 0.85))
		star.position = Vector2(randf_range(0, Global.SCREEN_SIZE.x), randf_range(75, Global.SCREEN_SIZE.y))
		star.size = Vector2(randf_range(1, 3), randf_range(1, 3))
		star_container.add_child(star)


func _build_pvp_arena_guides() -> void:
	# Zona central del modo PvP: aquí aparecen enemigos e items.
	var zone := ColorRect.new()
	zone.color = Color(0.05, 0.22, 0.28, 0.22)
	zone.position = Vector2(PVP_CENTER_LEFT, PVP_CENTER_TOP)
	zone.size = Vector2(PVP_CENTER_RIGHT - PVP_CENTER_LEFT, PVP_CENTER_BOTTOM - PVP_CENTER_TOP)
	add_child(zone)

	var left_line := ColorRect.new()
	left_line.color = Color(0.2, 0.9, 1.0, 0.55)
	left_line.position = Vector2(PVP_CENTER_LEFT, PVP_CENTER_TOP)
	left_line.size = Vector2(3, PVP_CENTER_BOTTOM - PVP_CENTER_TOP)
	add_child(left_line)

	var right_line := ColorRect.new()
	right_line.color = Color(0.2, 0.9, 1.0, 0.55)
	right_line.position = Vector2(PVP_CENTER_RIGHT, PVP_CENTER_TOP)
	right_line.size = Vector2(3, PVP_CENTER_BOTTOM - PVP_CENTER_TOP)
	add_child(right_line)

	var label := Label.new()
	label.text = "ZONA CENTRAL: ENEMIGOS + ITEMS"
	label.position = Vector2(PVP_CENTER_LEFT + 45, PVP_CENTER_TOP + 10)
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(0.8, 1.0, 1.0))
	add_child(label)

func _update_stars(delta: float) -> void:
	for star in star_container.get_children():
		star.position.x -= 55.0 * delta
		if star.position.x < -10:
			star.position.x = Global.SCREEN_SIZE.x + 10
			star.position.y = randf_range(75, Global.SCREEN_SIZE.y)


func _create_players() -> void:
	var p1 := PlayerShip.new()
	add_child(p1)

	var p2 := PlayerShip.new()
	add_child(p2)

	if Global.current_mode == Global.GameMode.PVP_ARENA:
		p1.setup(1, Vector2(130, 330), Color(0.0, 0.35, 1.0), Vector2.RIGHT)
		p2.setup(2, Vector2(1020, 330), Color(1.0, 0.25, 0.1), Vector2.LEFT)
	elif Global.current_mode == Global.GameMode.STORY:
		p1.setup(1, Vector2(120, 330), Color(0.0, 0.35, 1.0), Vector2.RIGHT)
		p2.visible = false
		p2.is_dead = true
	else:
		p1.setup(1, Vector2(120, 260), Color(0.0, 0.35, 1.0), Vector2.RIGHT)
		p2.setup(2, Vector2(120, 420), Color(1.0, 0.25, 0.1), Vector2.RIGHT)

	players = [p1, p2]


func _create_hud() -> void:
	var hud_script = load("res://Scripts/UI/HUD.gd")
	var hud := CanvasLayer.new()
	hud.set_script(hud_script)
	add_child(hud)


func _update_level(delta: float) -> void:
	if Global.current_mode == Global.GameMode.SUDDEN_DEATH:
		Global.current_level = 4
		return

	if Global.current_mode == Global.GameMode.PVP_ARENA:
		Global.current_level = 4
		return

	if boss_spawned:
		return

	level_timer -= delta
	if level_timer <= 0:
		if Global.current_level < 4:
			Global.current_level += 1
			level_timer = 25.0
			print("SUBIÓ AL NIVEL: ", Global.current_level)
		else:
			spawn_boss()


func _update_spawner(delta: float) -> void:
	if boss_spawned and Global.current_mode == Global.GameMode.STORY:
		return

	spawn_timer -= delta
	if spawn_timer <= 0:
		var count := 1
		if Global.current_mode == Global.GameMode.COOP:
			count = 2
		elif Global.current_mode == Global.GameMode.SUDDEN_DEATH:
			count = 2

		for i in range(count):
			spawn_enemy()

		spawn_timer = get_spawn_time()



func _update_item_spawner(delta: float) -> void:
	if Global.current_mode != Global.GameMode.PVP_ARENA:
		return

	item_timer -= delta
	if item_timer <= 0:
		spawn_pvp_item()
		item_timer = randf_range(3.0, 6.5)


func spawn_pvp_item() -> void:
	var roll := randi_range(1, 100)
	var item_type := "health"
	if roll <= 30:
		item_type = "health"
	elif roll <= 55:
		item_type = "shield"
	elif roll <= 82:
		item_type = "rapid"
	else:
		item_type = "bomb"

	var item := PowerItem.new()
	add_child(item)

	var pos := Vector2(
		randf_range(PVP_CENTER_LEFT + 60, PVP_CENTER_RIGHT - 60),
		randf_range(PVP_CENTER_TOP + 90, PVP_CENTER_BOTTOM - 70)
	)

	# En PvP los items aparecen en medio y se mueven muy poco para que ambos compitan por ellos.
	item.setup(item_type, pos, Vector2(randf_range(-25, 25), randf_range(-15, 15)))

func get_spawn_time() -> float:
	if Global.current_mode == Global.GameMode.PVP_ARENA:
		return randf_range(0.45, 1.1)
	if Global.current_mode == Global.GameMode.SUDDEN_DEATH:
		return randf_range(0.25, 0.65)

	match Global.current_level:
		1:
			return randf_range(1.1, 2.1)
		2:
			return randf_range(0.75, 1.5)
		3:
			return randf_range(0.45, 1.0)
		4:
			return randf_range(0.25, 0.7)
	return randf_range(1.0, 2.0)


func spawn_enemy() -> void:
	var level := Global.current_level
	var roll := randi_range(1, 100)

	var kind := "basic"
	var hp := 1
	var points := 100
	var color := Color(0.95, 0.18, 0.18)
	var size := Vector2(42, 26)

	if level == 1:
		if roll <= 80:
			kind = "basic"
		else:
			kind = "fast"
	elif level == 2:
		if roll <= 55:
			kind = "basic"
		elif roll <= 90:
			kind = "fast"
		else:
			kind = "tank"
	elif level >= 3:
		if roll <= 35:
			kind = "basic"
		elif roll <= 75:
			kind = "fast"
		else:
			kind = "tank"

	match kind:
		"fast":
			hp = 1
			points = 150
			color = Color(1.0, 0.55, 0.05)
			size = Vector2(34, 20)
		"tank":
			hp = 3
			points = 300
			color = Color(0.55, 0.1, 0.1)
			size = Vector2(60, 42)

	var start_pos := Vector2(Global.SCREEN_SIZE.x + 60, randf_range(100, Global.SCREEN_SIZE.y - 40))
	var vel := Vector2.LEFT * _level_speed()

	if Global.current_mode == Global.GameMode.PVP_ARENA:
		var pattern := randi_range(1, 100)
		var x := randf_range(PVP_CENTER_LEFT + 35, PVP_CENTER_RIGHT - 35)

		if pattern <= 40:
			# Enemigos salen desde arriba hacia abajo, como en tu dibujo.
			start_pos = Vector2(x, PVP_CENTER_TOP - 55)
			vel = Vector2.DOWN * randf_range(210, 390)
		elif pattern <= 80:
			# Enemigos también salen desde abajo hacia arriba.
			start_pos = Vector2(x, PVP_CENTER_BOTTOM + 55)
			vel = Vector2.UP * randf_range(210, 390)
		else:
			# Algunos cruzan por el centro para crear caos entre ambos jugadores.
			var from_left := randf() < 0.5
			var y := randf_range(PVP_CENTER_TOP + 80, PVP_CENTER_BOTTOM - 80)
			if from_left:
				start_pos = Vector2(PVP_CENTER_LEFT - 55, y)
				vel = Vector2.RIGHT * randf_range(180, 320)
			else:
				start_pos = Vector2(PVP_CENTER_RIGHT + 55, y)
				vel = Vector2.LEFT * randf_range(180, 320)

	var enemy := EnemyShip.new()
	add_child(enemy)
	enemy.setup(kind, start_pos, vel, hp, points, color, size)

func _level_speed() -> float:
	match Global.current_level:
		1:
			return randf_range(170, 250)
		2:
			return randf_range(240, 330)
		3:
			return randf_range(320, 430)
		4:
			return randf_range(430, 560)
	return randf_range(200, 300)


func spawn_boss() -> void:
	if boss_spawned:
		return

	boss_spawned = true
	boss_alive = true
	Global.current_level = 4
	print("APARECE EL JEFE FINAL")

	var boss := BossShip.new()
	add_child(boss)
	boss.setup(Vector2(Global.SCREEN_SIZE.x - 130, Global.SCREEN_SIZE.y / 2), self)


func boss_defeated(owner_player: int) -> void:
	boss_alive = false
	finish_game("JEFE DERROTADO\nGanador: " + _winner_by_score())


func _check_game_over() -> void:
	if Global.current_mode == Global.GameMode.STORY:
		if Global.player1_lives <= 0:
			finish_game("GAME OVER")
	elif Global.current_mode == Global.GameMode.PVP_ARENA:
		if Global.player1_lives <= 0 and Global.player2_lives <= 0:
			finish_game("EMPATE")
		elif Global.player1_lives <= 0:
			finish_game("GANA " + Global.player2_name)
		elif Global.player2_lives <= 0:
			finish_game("GANA " + Global.player1_name)
	else:
		if Global.player1_lives <= 0 and Global.player2_lives <= 0:
			if Global.player1_score == Global.player2_score:
				start_sudden_death()
			else:
				finish_game("FIN\nGanador: " + _winner_by_score())
		elif Global.player1_lives <= 0:
			finish_game("GANA " + Global.player2_name)
		elif Global.player2_lives <= 0:
			finish_game("GANA " + Global.player1_name)


func start_sudden_death() -> void:
	Global.reset_game(Global.GameMode.SUDDEN_DEATH)
	get_tree().reload_current_scene()


func _winner_by_score() -> String:
	if Global.player1_score > Global.player2_score:
		return Global.player1_name
	elif Global.player2_score > Global.player1_score:
		return Global.player2_name
	else:
		return "Empate"


func finish_game(message: String) -> void:
	if Global.game_over:
		return

	Global.game_over = true
	Global.winner_text = message

	SaveSystem.add_record(Global.player1_name, Global.player1_score, Global.get_mode_name())
	if Global.current_mode != Global.GameMode.STORY:
		SaveSystem.add_record(Global.player2_name, Global.player2_score, Global.get_mode_name())
