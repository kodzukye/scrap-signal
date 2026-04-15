extends Node

signal inventory_changed

# Pièces requises par PNJ
const REPAIR_REQUIREMENTS := {
	"vrac7": { "engrenage": 1},
	"iris3": { "circuit":   1 },
}

var repaired := {
	"vrac7": false,
	"iris3": false,
}
var inventory := {}

# Items
func add_item(id: String) -> void:
	if inventory.has(id):
		inventory[id] += 1
		inventory_changed.emit()
	else:
		inventory[id] = 1
		inventory_changed.emit()
	print("Inventaire : ", inventory)

func has_item(id: String) -> bool:
	return inventory.get(id, 0) > 0

func remove_item(id: String) -> void:
	if has_item(id):
		inventory[id] -= 1
		if inventory[id] <= 0:
			inventory.erase(id)
		inventory_changed.emit()

# Robots repairs
func can_repair(npc_id: String) -> bool:
	if repaired.get(npc_id, false):
		return false  # déjà réparé
	var required = REPAIR_REQUIREMENTS.get(npc_id, {})
	for item_id in required:
		if inventory.get(item_id, 0) < required[item_id]:
			return false
	return true

func complete_repair(npc_id: String) -> void:
	if not can_repair(npc_id):
		return
	# Consomme les pièces
	var required = REPAIR_REQUIREMENTS[npc_id]
	for item_id in required:
		remove_item(item_id)
	repaired[npc_id] = true
	print("Réparation terminée : ", npc_id)
