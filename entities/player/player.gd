extends CharacterBody2D

const SPEED := 120

@onready var sprite := $AnimatedSprite2D

var last_direction := Vector2.DOWN
var interactable : Node = null

func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector(
		"move_left", "move_right", "move_up", "move_down"
	)

	velocity = direction * SPEED
	move_and_slide()
	
	position.round()
	_update_animation(direction)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and interactable:
		interactable.interact()

# --- Animation ---
func _update_animation(direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		last_direction = direction
		sprite.play("walk_" + _dir_name(direction))
	else:
		sprite.play("idle_" + _dir_name(last_direction))

func _dir_name(dir: Vector2) -> String:
	if abs(dir.x) > abs(dir.y):
		return "right" if dir.x > 0 else "left"
	else:
		return "down" if dir.y > 0 else "up"
