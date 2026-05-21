class_name EnemyBullet
extends Area2D

var direction := Vector2.LEFT
var speed := 360.0


func setup(start_pos: Vector2, dir: Vector2, bullet_speed: float = 360.0) -> void:
	global_position = start_pos
	direction = dir.normalized()
	speed = bullet_speed

	collision_layer = 8
	collision_mask = 1

	var visual := ColorRect.new()
	visual.color = Color(1.0, 0.18, 0.18)
	visual.position = Vector2(-6, -4)
	visual.size = Vector2(12, 8)
	add_child(visual)

	var shape_node := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(16, 10)
	shape_node.shape = rect
	add_child(shape_node)

	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	position += direction * speed * delta

	if global_position.x < -80 or global_position.x > Global.SCREEN_SIZE.x + 80 or global_position.y < -80 or global_position.y > Global.SCREEN_SIZE.y + 80:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("players"):
		body.take_damage()
		queue_free()
