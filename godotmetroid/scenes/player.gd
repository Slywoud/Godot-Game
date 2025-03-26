extends CharacterBody2D

@export var speed: float = 200.0  # Speed of the character
const GRAVITY = 500
enum State {Idle, Run, Jump}

var current_state

func _ready():
	current_state = State.Idle

func _physics_process(delta):
	player_falling(delta)
	player_idle(delta)
	player_run(delta)
	
	move_and_slide()

func player_falling(delta):
	if !is_on_floor():
		velocity.y += GRAVITY * delta

func player_idle(delta):
	if is_on_floor():
		current_state = State.Idle

func player_run(delta):
	var direction = Input.get_axis("Gauche", "Droite")
	if direction:
		velocity.x = direction * 300
	else:
		velocity.x = move_toward(velocity.x, 0, 300)
