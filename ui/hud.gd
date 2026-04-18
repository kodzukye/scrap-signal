extends CanvasLayer

# Slots : dictionnaire item_id → Label du compteur
@onready var slots := {
	"engrenage": $InventoryBar/ItemRow/EngrenageSlot/Count,
	"cable":     $InventoryBar/ItemRow/CableSlot/Count,
	"circuit":   $InventoryBar/ItemRow/CircuitSlot/Count,
}

func _ready() -> void:
	GameState.inventory_changed.connect(_refresh)
	_refresh()

func _refresh() -> void:
	for item_id in slots:
		var count : int = GameState.inventory.get(item_id, 0)
		slots[item_id].text = "x%d" % count
		slots[item_id].get_parent().modulate.a = 0.4 if count == 0 else 1.0
