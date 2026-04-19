class_name PushableBox
extends CharacterBody2D

func _ready() -> void:
	add_to_group("pushable")

func try_push(direction: Vector2, tile_size: float) -> bool:
	var motion := direction * tile_size
	var collision := move_and_collide(motion)
	if collision:
		move_and_collide(-motion)
		return false
	return true
