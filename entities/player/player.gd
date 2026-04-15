extends CharacterBody2D

const SPEED := 120

@onready var sprite := $AnimatedSprite2D
@onready var interaction_area := $InteractionArea

var last_direction := Vector2.DOWN
var interactable : Node = null

func _ready() -> void:
	interaction_area.area_entered.connect(_on_interaction_area_area_entered)
	interaction_area.area_exited.connect(_on_interaction_area_area_exited)

func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector(
		"move_left", "move_right", "move_up", "move_down"
	)
	velocity = direction * SPEED
	move_and_slide()
	position = position.round()
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

# --- Interaction ---
func _on_interaction_area_area_entered(area: Area2D) -> void:
	print("Area détectée : ", area.name)
	if area.has_method("interact"):
		interactable = area

func _on_interaction_area_area_exited(area: Area2D) -> void:
	if area == interactable:
		interactable = null
