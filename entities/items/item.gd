extends Area2D

@export var item_id   : String = "engrenage"
@export var item_name : String = "Engrenage"
@export var prompt_text : String = "[E] Take"

func interact() -> void:
	GameState.add_item(item_id)
	print("Ramassé : ", item_name)
	queue_free()  # supprime l'item de la scène
