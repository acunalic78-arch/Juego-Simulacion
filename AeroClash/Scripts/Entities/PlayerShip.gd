class_name PlayerShip
extends CharacterBody2D

var player_id := 1
var prefix := "p1"
var shoot_direction := Vector2.RIGHT
var speed := 400.0
var can_shoot := true
var shoot_cooldown := 0.22
var shoot_timer := 0.0
var is_dead := false
var shield_time := 0.0
var rapid_time := 0.0
var bomb_count := 1

var body_rect: ColorRect
var shield_ring: ColorRect


func setup(id: int, start_pos: Vector2, color: Color, direction: Vector2) -> void:
	player_id = id
	prefix = "p" + str(id)
	shoot_direction = direction.normalized()
	global_position = start_pos

	collision_layer = 1
	collision_mask = 2 | 8

	body_rect = ColorRect.new()
	body_rect.color = color
	body_rect.position = Vector2(-20, -12)
	body_rect.size = Vector2(40, 24)
	add_child(body_rect)

	var shape_node := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(40, 24)
	shape_node.shape = rect
	add_child(shape_node)

	shield_ring = ColorRect.new()
	shield_ring.color = Color(0.35, 0.9, 1.0, 0.35)
	shield_ring.position = Vector2(-26, -18)
	shield_ring.size = Vector2(52, 36)
	shield_ring.visible = false
	add_child(shield_ring)

	add_to_group("players")


func _physics_process(delta: float) -> void:
	if Global.game_over or is_dead:
		return

	var direction := Input.get_vector(prefix + "_left", prefix + "_right", prefix + "_up", prefix + "_down")
	velocity = direction * speed
	move_and_slide()

	global_position.x = clamp(global_position.x, 25.0, Global.SCREEN_SIZE.x - 25.0)
	global_position.y = clamp(global_position.y, 90.0, Global.SCREEN_SIZE.y - 25.0)

	if shoot_timer > 0:
		shoot_timer -= delta
	else:
		can_shoot = true

	if shield_time > 0:
		shield_time -= delta
		shield_ring.visible = true
	else:
		shield_ring.visible = false

	if rapid_time > 0:
		rapid_time -= delta
		shoot_cooldown = 0.09
	else:
		shoot_cooldown = 0.22

	if Input.is_action_pressed(prefix + "_shoot") and can_shoot:
		shoot()

	if Input.is_action_just_pressed(prefix + "_bomb"):
		use_bomb()


func shoot() -> void:
	can_shoot = false
	shoot_timer = shoot_cooldown

	var bullet := PlayerBullet.new()
	get_tree().current_scene.add_child(bullet)
	bullet.setup(player_id, global_position + shoot_direction * 30.0, shoot_direction)

	if rapid_time > 0:
		var bullet_up := PlayerBullet.new()
		get_tree().current_scene.add_child(bullet_up)
		bullet_up.setup(player_id, global_position + shoot_direction * 30.0 + Vector2(0, -9), shoot_direction)

		var bullet_down := PlayerBullet.new()
		get_tree().current_scene.add_child(bullet_down)
		bullet_down.setup(player_id, global_position + shoot_direction * 30.0 + Vector2(0, 9), shoot_direction)


func use_bomb() -> void:
	if bomb_count <= 0:
		return

	bomb_count -= 1
	var enemies := get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy.has_method("take_damage"):
			enemy.take_damage(player_id, 99)


func take_damage() -> void:
	if is_dead or Global.game_over:
		return

	if shield_time > 0:
		shield_time = 0
		return

	Global.damage_player(player_id)

	if player_id == 1:
		print("VIDAS PLAYER 1: ", Global.player1_lives)
		if Global.player1_lives <= 0:
			die()
	else:
		print("VIDAS PLAYER 2: ", Global.player2_lives)
		if Global.player2_lives <= 0:
			die()


func heal() -> void:
	if player_id == 1:
		Global.player1_lives = min(Global.player1_lives + 1, 5)
	else:
		Global.player2_lives = min(Global.player2_lives + 1, 5)


func apply_shield(duration: float) -> void:
	shield_time = duration


func apply_rapid(duration: float) -> void:
	rapid_time = duration


func add_bomb() -> void:
	bomb_count += 1


func die() -> void:
	is_dead = true
	visible = false
	set_physics_process(false)
