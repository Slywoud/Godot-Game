extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var muzzle: Marker2D = $Muzzle

@export var speed : int = 1200
@export var max_horizontal_speed: int = 300
@export var slow_down_speed: int = 1500
@export var jump = -230
const GRAVITY = 500
enum State {Idle, Run, Jump, Shoot, Attack}
var current_state
var jump_count = 0

var spell = preload("res://scenes/spell.tscn")
var muzzle_position


func _ready():
	current_state = State.Idle
	muzzle_position = muzzle.position
	add_to_group("Player")

func _physics_process(delta: float):
	player_falling(delta)
	player_idle(delta)
	player_run(delta)
	player_jump(delta)
	
	player_muzzle_position()
	player_shooting(delta)
	
	player_animation()
	
	move_and_slide()
	
	print("State: ", State.keys()[current_state])

func player_falling(delta: float):
	if !is_on_floor():
		velocity.y += GRAVITY * delta

func player_idle(delta: float):
	if is_on_floor():
		current_state = State.Idle
		jump_count = 0

func player_run(delta: float):
	var direction = Input.get_axis("Gauche", "Droite")
	if direction:
		velocity.x += direction * speed
		velocity.x = clamp(velocity.x, -max_horizontal_speed, max_horizontal_speed)
	else:
		velocity.x = move_toward(velocity.x, 0, slow_down_speed * delta)
	
	if is_on_floor() and direction != 0:
		current_state = State.Run
		animated_sprite_2d.flip_h = false if direction > 0 else true
	
func player_jump(delta: float):
	if Input.is_action_just_pressed("Jump") and jump_count < 2:
		velocity.y = jump
		jump_count += 1
		current_state = State.Jump
	if !is_on_floor() and current_state == State.Jump:
		var direction = Input.get_axis("Gauche", "Droite")
		velocity.x += direction * 100 * delta
		if direction != 0:
			animated_sprite_2d.flip_h = (direction < 0)
			
func input_movement() -> float:
	return Input.get_axis("Gauche", "Droite")

func player_shooting(delta : float):
	var direction = input_movement()
	if direction != 0 and Input.is_action_just_pressed("shoot"):
		var spell_instance = spell.instantiate() as Node2D
		spell_instance.direction = direction
		spell_instance.global_position = muzzle.global_position
		get_parent().add_child(spell_instance)
		current_state = State.Shoot
func player_muzzle_position():
	var direction = input_movement()
	if direction > 0:
		muzzle_position.x = muzzle_position.x

func player_animation():
	if current_state == State.Idle:
		animated_sprite_2d.play("player_idle")
	elif current_state == State.Run and animated_sprite_2d.animation != "player_shooting":
		animated_sprite_2d.play("player_run")
	elif current_state == State.Jump:
		animated_sprite_2d.play("player_jump")
	elif current_state == State.Shoot:
		animated_sprite_2d.play("player_shooting")
		
func _on_hurtbox_area_entered(area : Area2D):
	if area.is_in_group("Enemy"):
		print("Enemy entered ", area.damage_amount)
