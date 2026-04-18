class_name HUD
extends CanvasLayer

@onready var slots := {
	"engrenage": $InventoryBar/ItemRow/EngrenageSlot/Count,
	"cable":     $InventoryBar/ItemRow/CableSlot/Count,
	"circuit":   $InventoryBar/ItemRow/CircuitSlot/Count,
}
@onready var interact_prompt := $InteractPrompt
@onready var prompt_label    := $InteractPrompt/PromptLabel

func _ready() -> void:
	GameState.inventory_changed.connect(_refresh)
	_refresh()

func show_prompt(text: String) -> void:
	prompt_label.text = text
	interact_prompt.visible = true

func hide_prompt() -> void:
	interact_prompt.visible = false

func _refresh() -> void:
	for item_id in slots:
		var count : int = GameState.inventory.get(item_id, 0)
		slots[item_id].text = "x%d" % count
		slots[item_id].get_parent().modulate.a = 0.4 if count == 0 else 1.0
