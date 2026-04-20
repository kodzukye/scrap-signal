extends Node

signal inventory_changed
signal flag_changed(key: String, value: bool)

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
var flags := {}

func get_flag(key: String) -> bool:
	return flags.get(key, false)

func set_flag(key: String, value: bool) -> void:
	flags[key] = value
	flag_changed.emit(key, value)

# Items
func add_item(id: String, amount: int = 1) -> void:
	if inventory.has(id):
		inventory[id] += amount
		inventory_changed.emit()
	else:
		inventory[id] = 1
		inventory_changed.emit()
	print("Inventaire : ", inventory)

func has_item(id: String) -> bool:
	return inventory.get(id, 0) > 0

func remove_item(item_id: String, amount: int) -> void:
	if inventory.has(item_id):
		inventory[item_id] -= amount
		if inventory[item_id] <= 0:
			inventory.erase(item_id)
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
		remove_item(item_id, required[item_id])
	repaired[npc_id] = true
	print("Réparation terminée : ", npc_id)
