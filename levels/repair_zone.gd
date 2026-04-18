class_name RepairZone
extends Area2D

@export var npc_id : String = "vrac7"
@export var prompt_text : String = "[E] Repair"

signal repair_requested(npc_id: String)

func interact() -> void:
	print("interact() appelé sur RepairZone")
	print("can_repair : ", GameState.can_repair(npc_id))
	print("inventaire : ", GameState.inventory)
	if GameState.can_repair(npc_id):
		repair_requested.emit(npc_id)
		print("Lancement mini-jeu pour : ", npc_id)
	else:
		print("Pièces manquantes pour réparer ", npc_id)
