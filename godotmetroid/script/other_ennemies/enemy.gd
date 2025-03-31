extends CharacterBody2D

var enemy_death_effect = preload("res://scenes/enemy_death_effect.tscn")

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var patrol_points : Node
@export var speed : int = 1500
@export var wait_time : int = 3
@onready var timer: Timer = $Timer
var health_amount : int = 3

const GRAVITY = 500

enum State {Idle, Walk, Attack}
var current_state : State
var direction : Vector2 = Vector2.LEFT
var number_of_points : int
var point_positions : Array[Vector2]
var current_point : Vector2
var current_point_position : int
var can_walk : bool


func _ready():
	if patrol_points != null:
		number_of_points = patrol_points.get_children().size()
		for point in patrol_points.get_children():
			point_positions.append(point.global_position)
		current_point = point_positions[current_point_position]
	else:
		print("No patrol points")
	timer.wait_time = wait_time
	current_state = State.Idle
	
func _physics_process(delta: float):
	enemy_gravity(delta)
	enemy_idle(delta)
	enemy_walk(delta)
	
	move_and_slide()
	
	enemy_animation()

func enemy_gravity(delta: float):
	velocity.y += GRAVITY * delta

func enemy_idle(delta):
	if !can_walk:
		velocity.x = move_toward(velocity.x, 0, speed * delta)
		current_state = State.Idle

func enemy_walk(delta):
	if !can_walk:
		return
	if abs(position.x - current_point.x) > 0.5:
		velocity.x = direction.x * speed * delta 
		current_state = State.Walk
	else:
		current_point_position += 1

		if current_point_position >= number_of_points:
			current_point_position = 0

		current_point = point_positions[current_point_position];

		if current_point.x > position.x:
			direction = Vector2.RIGHT
		else:
			direction = Vector2.LEFT

		can_walk = false
		timer.start()
	
	# Makes the enemy flip in the direction it's going
	if direction.x > 0:
		animated_sprite_2d.flip_h = false
	elif direction.x < 0:
		animated_sprite_2d.flip_h = true

func enemy_animation():
	if current_state == State.Idle && !can_walk:
		animated_sprite_2d.play("enemy_idle")
	elif current_state == State.Walk && can_walk:
		animated_sprite_2d.play("enemy_walk")
	elif current_state == State.Attack:
		animated_sprite_2d.play("enemy_attack")

func _on_timer_timeout():
	can_walk = true
