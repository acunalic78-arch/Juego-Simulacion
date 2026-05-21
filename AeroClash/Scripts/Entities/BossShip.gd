class_name BossShip
extends Area2D

var health := 80
var move_dir := 1.0
var attack_timer := 1.2
var game_ref: Node


func setup(start_pos: Vector2, game_node: Node) -> void:
	global_position = start_pos
	game_ref = game_node

	collision_layer = 2
	collision_mask = 4 | 1

	var visual := ColorRect.new()
	visual.color = Color(0.6, 0.1, 0.9)
	visual.position = Vector2(-55, -75)
	visual.size = Vector2(110, 150)
	add_child(visual)

	var shape_node := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(115, 155)
	shape_node.shape = rect
	add_child(shape_node)

	add_to_group("bosses")
	add_to_group("enemies")


func _physics_process(delta: float) -> void:
	position.y += move_dir * 120.0 * delta

	if position.y < 150:
		move_dir = 1
	elif position.y > Global.SCREEN_SIZE.y - 130:
		move_dir = -1

	attack_timer -= delta
	if attack_timer <= 0:
		random_attack()
		attack_timer = randf_range(0.55, 1.25)


func random_attack() -> void:
	var roll := randi_range(1, 100)

	if roll <= 35:
		laser_burst()
	elif roll <= 65:
		spread_attack()
	else:
		summon_enemy()


func laser_burst() -> void:
	for i in range(4):
		var b := EnemyBullet.new()
		get_tree().current_scene.add_child(b)
		b.setup(global_position + Vector2(-60, -45 + i * 30), Vector2.LEFT, 520)


func spread_attack() -> void:
	for dir in [Vector2.LEFT, Vector2(-1, -0.45), Vector2(-1, 0.45), Vector2(-1, -0.2), Vector2(-1, 0.2)]:
		var b := EnemyBullet.new()
		get_tree().current_scene.add_child(b)
		b.setup(global_position + Vector2(-60, 0), dir, 420)


func summon_enemy() -> void:
	if game_ref != null and game_ref.has_method("spawn_enemy"):
		for i in range(2):
			game_ref.spawn_enemy()


func take_damage(owner_player: int, damage: int = 1) -> void:
	health -= damage

	if health <= 0:
		Global.add_score(owner_player, 2000)
		if game_ref != null and game_ref.has_method("boss_defeated"):
			game_ref.boss_defeated(owner_player)
		queue_free()
