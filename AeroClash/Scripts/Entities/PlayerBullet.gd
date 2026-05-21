class_name PlayerBullet
extends Area2D

var owner_player := 1
var direction := Vector2.RIGHT
var speed := 720.0


func setup(player_id: int, start_pos: Vector2, dir: Vector2) -> void:
	owner_player = player_id
	direction = dir.normalized()
	global_position = start_pos

	collision_layer = 4
	collision_mask = 2 | 1

	var visual := ColorRect.new()
	visual.color = Color(1.0, 0.92, 0.12)
	visual.position = Vector2(-8, -3)
	visual.size = Vector2(16, 6)
	add_child(visual)

	var shape_node := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(22, 10)
	shape_node.shape = rect
	add_child(shape_node)

	add_to_group("player_bullets")

	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	position += direction * speed * delta

	if global_position.x < -80 or global_position.x > Global.SCREEN_SIZE.x + 80 or global_position.y < -80 or global_position.y > Global.SCREEN_SIZE.y + 80:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies") or area.is_in_group("bosses"):
		if area.has_method("take_damage"):
			area.take_damage(owner_player, 1)
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if Global.current_mode != Global.GameMode.PVP_ARENA:
		return

	if body.is_in_group("players") and body.player_id != owner_player:
		body.take_damage()
		queue_free()
