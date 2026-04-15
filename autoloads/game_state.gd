extends Node

signal inventory_changed

var inventory := {}

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
