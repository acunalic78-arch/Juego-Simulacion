class_name PowerItem
extends Area2D

var item_type := "health"
var velocity := Vector2(-120, 0)


func setup(kind: String, start_pos: Vector2, item_velocity: Vector2 = Vector2(-120, 0)) -> void:
	item_type = kind
	global_position = start_pos
	velocity = item_velocity

	collision_layer = 16
	collision_mask = 1

	var visual := ColorRect.new()
	match item_type:
		"health":
			visual.color = Color(0.2, 1.0, 0.3)
		"shield":
			visual.color = Color(0.2, 0.85, 1.0)
		"rapid":
			visual.color = Color(1.0, 0.8, 0.1)
		"bomb":
			visual.color = Color(1.0, 0.2, 0.9)
	visual.position = Vector2(-12, -12)
	visual.size = Vector2(24, 24)
	add_child(visual)

	var shape_node := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(28, 28)
	shape_node.shape = rect
	add_child(shape_node)

	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	position += velocity * delta

	if global_position.x < -80 or global_position.x > Global.SCREEN_SIZE.x + 80 or global_position.y < 40 or global_position.y > Global.SCREEN_SIZE.y + 80:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("players"):
		return

	match item_type:
		"health":
			body.heal()
		"shield":
			body.apply_shield(5.0)
		"rapid":
			body.apply_rapid(6.0)
		"bomb":
			body.add_bomb()

	queue_free()
