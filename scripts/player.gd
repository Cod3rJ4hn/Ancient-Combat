extends CharacterBody2D
## Grounded fighter: walk, attack, dodge (i-frames), block. No jumping.
## Controls: A/D or arrows move, left mouse attack, right mouse block, Space dodge.

enum State { FREE, ATTACK, DODGE, BLOCK }

@export var max_health := 100.0
@export var walk_speed := 140.0
@export var block_walk_mult := 0.3
@export var attack_time := 0.45
@export var attack_damage := 25.0
@export var dodge_speed := 360.0
@export var dodge_time := 0.35
@export var dodge_cooldown := 0.7

var health: float
var facing := 1
var state := State.FREE
var state_timer := 0.0
var dodge_cd := 0.0
var invulnerable := false
var hit_this_swing: Array[Node] = []

@onready var body: ColorRect = $Body
@onready var hitbox: Area2D = $Hitbox
@onready var blade: ColorRect = $Hitbox/Blade
@onready var camera: Camera2D = $Camera2D


func _ready() -> void:
	health = max_health
	_ensure_inputs()


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	state_timer = maxf(state_timer - delta, 0.0)
	dodge_cd = maxf(dodge_cd - delta, 0.0)

	var dir := Input.get_axis("move_left", "move_right")
	match state:
		State.FREE:
			_state_free(dir)
		State.ATTACK:
			_state_attack()
		State.DODGE:
			_state_dodge()
		State.BLOCK:
			_state_block(dir)

	move_and_slide()
	_update_visuals()


func _state_free(dir: float) -> void:
	if dir != 0.0:
		_set_facing(signf(dir))
	if Input.is_action_just_pressed("dodge") and dodge_cd <= 0.0:
		_start_dodge()
	elif Input.is_action_just_pressed("attack"):
		_start_attack()
	elif Input.is_action_pressed("block"):
		state = State.BLOCK
	else:
		velocity.x = dir * walk_speed


func _start_attack() -> void:
	state = State.ATTACK
	state_timer = attack_time
	hit_this_swing.clear()
	velocity.x = 0.0


func _state_attack() -> void:
	velocity.x = 0.0
	# Hits only land in the middle of the swing (wind-up, strike, recovery).
	var progress := 1.0 - state_timer / attack_time
	if progress > 0.3 and progress < 0.7:
		_check_hits()
	if state_timer <= 0.0:
		state = State.FREE


func _check_hits() -> void:
	for target in hitbox.get_overlapping_bodies():
		if target in hit_this_swing or not target.has_method("take_hit"):
			continue
		hit_this_swing.append(target)
		target.take_hit(attack_damage, global_position.x)
		GameFeel.hit_stop(0.06)
		GameFeel.shake(camera, 6.0, 0.15)


func _start_dodge() -> void:
	state = State.DODGE
	state_timer = dodge_time
	dodge_cd = dodge_cooldown
	invulnerable = true


func _state_dodge() -> void:
	# Slows down over the roll. Invulnerable for the first 70% only.
	velocity.x = facing * dodge_speed * (state_timer / dodge_time)
	invulnerable = state_timer > dodge_time * 0.3
	if state_timer <= 0.0:
		invulnerable = false
		state = State.FREE


func _state_block(dir: float) -> void:
	if Input.is_action_just_pressed("dodge") and dodge_cd <= 0.0:
		_start_dodge()
		return
	if not Input.is_action_pressed("block"):
		state = State.FREE
		return
	# Facing stays locked so you can back away while still guarding.
	velocity.x = dir * walk_speed * block_walk_mult


## Called by enemies. Returns "dodged", "blocked" or "hit".
func take_hit(damage: float, attacker_x: float) -> String:
	if invulnerable:
		return "dodged"
	var from_front := signf(attacker_x - global_position.x) == float(facing)
	if state == State.BLOCK and from_front:
		health -= damage * 0.2
		GameFeel.shake(camera, 3.0, 0.1)
		return "blocked"
	health -= damage
	GameFeel.hit_stop(0.08)
	GameFeel.shake(camera, 10.0, 0.25)
	return "hit"


func _set_facing(f: float) -> void:
	facing = int(f)
	hitbox.scale.x = f


func _update_visuals() -> void:
	blade.visible = state == State.ATTACK
	match state:
		State.DODGE:
			body.modulate = Color(1, 1, 1, 0.4 if invulnerable else 0.7)
		State.BLOCK:
			body.modulate = Color(0.6, 0.7, 1.0)
		_:
			body.modulate = Color.WHITE


func _ensure_inputs() -> void:
	_add_key("move_left", KEY_A)
	_add_key("move_left", KEY_LEFT)
	_add_key("move_right", KEY_D)
	_add_key("move_right", KEY_RIGHT)
	_add_key("dodge", KEY_SPACE)
	_add_mouse("attack", MOUSE_BUTTON_LEFT)
	_add_mouse("block", MOUSE_BUTTON_RIGHT)


func _add_key(action: StringName, key: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var ev := InputEventKey.new()
	ev.physical_keycode = key
	InputMap.action_add_event(action, ev)


func _add_mouse(action: StringName, button: MouseButton) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var ev := InputEventMouseButton.new()
	ev.button_index = button
	InputMap.action_add_event(action, ev)
