extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var patrol_points : Node

const GRAVITY = 500
const SPEED = 50
enum State {Idle, Walk, Attack}
var current_state : State
var direction : Vector2 = Vector2.LEFT
var number_of_points : int
var point_positions : Array[Vector2]
var current_point : Vector2
var current_point_position : int

func _ready():
	if patrol_points != null:
		number_of_points = patrol_points.get_children().size()
		for point in patrol_points.get_children():
			point_positions.append(point.global_position)
		current_point = point_positions[current_point_position]
	else:
		print("no patrol point :(")
	current_state = State.Idle
	
func _physics_process(delta: float):
	enemy_gravity(delta)
	enemy_idle(delta)
	enemy_walk(delta)
	enemy_animation()
	
	move_and_slide()

func enemy_gravity(delta: float):
	velocity.y += GRAVITY * delta

func enemy_idle(delta):
	if velocity.x == 0: 
		velocity.x = move_toward(velocity.x, 0, SPEED * delta)
		current_state = State.Idle

func enemy_walk(delta):
	if abs(position.x - current_point.x) > 0.5:
		velocity.x = direction.x * SPEED * delta
		current_state = State.Walk
	else:
		current_point_position += 1
	if current_point_position >= number_of_points:
		current_point_position = 0
	#current_point = point_positions[current_point_position]
	if current_point.x > position.x:
		direction = Vector2.RIGHT
	else:
		direction = Vector2.LEFT
	animated_sprite_2d.flip_h = direction.x > 0

func enemy_animation():
	if current_state == State.Idle:
		animated_sprite_2d.play("enemy_idle")
	elif current_state == State.Walk:
		animated_sprite_2d.play("enemy_walk")
	elif current_state == State.Attack:
		animated_sprite_2d.play("enemy_attack")
