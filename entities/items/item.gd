extends Area2D

@export var item_id   : String = "engrenage"
@export var item_name : String = "Engrenage"
@export var prompt_text : String = "[E] Take"

func interact() -> void:
	GameState.add_item(item_id)
	var hud := get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("show_log"):
		hud.show_log("LOG  %s récupéré. Inventaire mis à jour." % item_id)
	queue_free()
