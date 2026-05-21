extends Node

enum GameMode {
	STORY,
	SCORE_BATTLE,
	PVP_ARENA,
	COOP,
	SUDDEN_DEATH
}

const SCREEN_SIZE := Vector2(1152, 648)

var current_mode: int = GameMode.STORY
var player1_name := "PLAYER 1"
var player2_name := "PLAYER 2"

var player1_score := 0
var player2_score := 0
var player1_lives := 3
var player2_lives := 3

var current_level := 1
var max_level := 4

var game_over := false
var winner_text := ""
var sudden_death_active := false


func _ready() -> void:
	randomize()
	setup_default_inputs()


func reset_game(mode: int = GameMode.STORY) -> void:
	current_mode = mode
	player1_score = 0
	player2_score = 0
	current_level = 1
	game_over = false
	winner_text = ""
	sudden_death_active = false

	if current_mode == GameMode.PVP_ARENA:
		player1_lives = 4
		player2_lives = 4
	elif current_mode == GameMode.SUDDEN_DEATH:
		player1_lives = 1
		player2_lives = 1
		current_level = 4
		sudden_death_active = true
	elif current_mode == GameMode.COOP:
		player1_lives = 3
		player2_lives = 3
	else:
		player1_lives = 3
		player2_lives = 3


func get_mode_name() -> String:
	match current_mode:
		GameMode.STORY:
			return "Historia"
		GameMode.SCORE_BATTLE:
			return "Score Battle"
		GameMode.PVP_ARENA:
			return "PvP Arena"
		GameMode.COOP:
			return "Cooperativo"
		GameMode.SUDDEN_DEATH:
			return "Desempate"
	return "Desconocido"


func add_score(player_id: int, points: int) -> void:
	if player_id == 1:
		player1_score += points
	elif player_id == 2:
		player2_score += points


func get_player_score(player_id: int) -> int:
	return player1_score if player_id == 1 else player2_score


func damage_player(player_id: int) -> void:
	if player_id == 1:
		player1_lives = max(player1_lives - 1, 0)
	elif player_id == 2:
		player2_lives = max(player2_lives - 1, 0)


func setup_default_inputs() -> void:
	_add_key_action("p1_up", KEY_W)
	_add_key_action("p1_down", KEY_S)
	_add_key_action("p1_left", KEY_A)
	_add_key_action("p1_right", KEY_D)
	_add_key_action("p1_shoot", KEY_SPACE)
	_add_key_action("p1_bomb", KEY_Q)

	_add_key_action("p2_up", KEY_UP)
	_add_key_action("p2_down", KEY_DOWN)
	_add_key_action("p2_left", KEY_LEFT)
	_add_key_action("p2_right", KEY_RIGHT)
	_add_key_action("p2_shoot", KEY_ENTER)
	_add_key_action("p2_bomb", KEY_SHIFT)

	_add_joy_motion("p1_left", 0, JOY_AXIS_LEFT_X, -1.0)
	_add_joy_motion("p1_right", 0, JOY_AXIS_LEFT_X, 1.0)
	_add_joy_motion("p1_up", 0, JOY_AXIS_LEFT_Y, -1.0)
	_add_joy_motion("p1_down", 0, JOY_AXIS_LEFT_Y, 1.0)
	_add_joy_button("p1_shoot", 0, JOY_BUTTON_A)
	_add_joy_button("p1_bomb", 0, JOY_BUTTON_X)

	_add_joy_motion("p2_left", 1, JOY_AXIS_LEFT_X, -1.0)
	_add_joy_motion("p2_right", 1, JOY_AXIS_LEFT_X, 1.0)
	_add_joy_motion("p2_up", 1, JOY_AXIS_LEFT_Y, -1.0)
	_add_joy_motion("p2_down", 1, JOY_AXIS_LEFT_Y, 1.0)
	_add_joy_button("p2_shoot", 1, JOY_BUTTON_A)
	_add_joy_button("p2_bomb", 1, JOY_BUTTON_X)


func _ensure_action(action_name: String) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	InputMap.action_set_deadzone(action_name, 0.2)


func _event_exists(action_name: String, event: InputEvent) -> bool:
	for existing in InputMap.action_get_events(action_name):
		if existing.as_text() == event.as_text():
			return true
	return false


func _add_key_action(action_name: String, keycode: Key) -> void:
	_ensure_action(action_name)
	var ev := InputEventKey.new()
	ev.physical_keycode = keycode
	if not _event_exists(action_name, ev):
		InputMap.action_add_event(action_name, ev)


func _add_joy_button(action_name: String, device_id: int, button_id: JoyButton) -> void:
	_ensure_action(action_name)
	var ev := InputEventJoypadButton.new()
	ev.device = device_id
	ev.button_index = button_id
	if not _event_exists(action_name, ev):
		InputMap.action_add_event(action_name, ev)


func _add_joy_motion(action_name: String, device_id: int, axis_id: JoyAxis, axis_value: float) -> void:
	_ensure_action(action_name)
	var ev := InputEventJoypadMotion.new()
	ev.device = device_id
	ev.axis = axis_id
	ev.axis_value = axis_value
	if not _event_exists(action_name, ev):
		InputMap.action_add_event(action_name, ev)
