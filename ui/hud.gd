extends CanvasLayer

@onready var engrenage_count := $InventoryPanel/Engrenage/Count
@onready var cable_count     := $InventoryPanel/Cable/Count
@onready var circuit_count   := $InventoryPanel/Circuit/Count

func _ready() -> void:
	GameState.inventory_changed.connect(_on_inventory_changed)
	_refresh()

func _on_inventory_changed() -> void:
	_refresh()

func _refresh() -> void:
	engrenage_count.text = "x %d" % GameState.inventory.get("engrenage", 0)
	cable_count.text     = "x %d" % GameState.inventory.get("cable",     0)
	circuit_count.text   = "x %d" % GameState.inventory.get("circuit",   0)
