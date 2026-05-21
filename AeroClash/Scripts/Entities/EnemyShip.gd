class_name EnemyShip
extends Area2D

var enemy_type := "basic"
var speed := 240.0
var velocity := Vector2.LEFT
var health := 1
var points := 100
var shoot_timer := 1.0
var can_shoot := true


func setup(kind: String, start_pos: Vector2, vel: Vector2, hp: int, score_points: int, color: Color, size: Vector2) -> void:
	enemy_type = kind
	global_position = start_pos
	velocity = vel
	speed = vel.length()
	health = hp
	points = score_points

	collision_layer = 2
	collision_mask = 1 | 4

	var visual := ColorRect.new()
	visual.color = color
	visual.position = -size / 2.0
	visual.size = size
	add_child(visual)

	var shape_node := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size + Vector2(6, 6)
	shape_node.shape = rect
	add_child(shape_node)

	add_to_group("enemies")

	shoot_timer = randf_range(0.8, 2.4)

	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	position += velocity * delta

	shoot_timer -= delta
	if shoot_timer <= 0:
		random_attack()
		shoot_timer = randf_range(1.0, 2.7) / max(1.0, float(Global.current_level) * 0.55)

	if global_position.x < -120 or global_position.x > Global.SCREEN_SIZE.x + 120 or global_position.y < 60 or global_position.y > Global.SCREEN_SIZE.y + 120:
		queue_free()


func random_attack() -> void:
	var chance := randi_range(1, 100)
	if chance <= 45:
		shoot_single()
	elif chance <= 75 and Global.current_level >= 2:
		shoot_double()
	elif Global.current_level >= 3:
		shoot_spread()


func shoot_single() -> void:
	var dir := Vector2.LEFT
	if Global.current_mode == Global.GameMode.PVP_ARENA:
		dir = Vector2.DOWN

	var b := EnemyBullet.new()
	get_tree().current_scene.add_child(b)
	b.setup(global_position, dir, randf_range(240, 380))


func shoot_double() -> void:
	for offset in [-8, 8]:
		var b := EnemyBullet.new()
		get_tree().current_scene.add_child(b)
		b.setup(global_position + Vector2(0, offset), Vector2.LEFT, randf_range(260, 420))


func shoot_spread() -> void:
	for dir in [Vector2.LEFT, Vector2(-1, -0.35), Vector2(-1, 0.35)]:
		var b := EnemyBullet.new()
		get_tree().current_scene.add_child(b)
		b.setup(global_position, dir, randf_range(260, 420))


func take_damage(owner_player: int, damage: int = 1) -> void:
	health -= damage

	if health <= 0:
		Global.add_score(owner_player, points)
		drop_random_item()
		queue_free()


func drop_random_item() -> void:
	var chance := randi_range(1, 100)
	if chance <= 18:
		var item_type := "health"
		var roll := randi_range(1, 100)
		if roll <= 35:
			item_type = "health"
		elif roll <= 65:
			item_type = "shield"
		elif roll <= 90:
			item_type = "rapid"
		else:
			item_type = "bomb"

		var item := PowerItem.new()
		get_tree().current_scene.add_child(item)
		item.setup(item_type, global_position)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("players"):
		body.take_damage()
		queue_free()
