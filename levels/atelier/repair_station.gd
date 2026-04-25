class_name RepairStation
extends Area2D

@export var prompt_text: String = "[E] Se réparer"

const REQUIRED_ITEMS := { "circuit": 1 }

const DIALOGUE_NO_ITEM := [
	{ "name": "SYSTÈME", "text": "Composant requis : circuit de self-repair. Non détecté." },
]

const DIALOGUE_HAS_ITEM := [
	{ "name": "SYSTÈME", "text": "Circuit compatible détecté. Lancer la séquence de réparation ?" },
]

const DIALOGUE_DONE := [
	{ "name": "SYSTÈME", "text": "Réparation complète. Systèmes moteurs restaurés à 94%." },
	{ "name": "SYSTÈME", "text": "Mémoire fragmentée restaurée. Fragment — jour de fermeture." },
]

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		get_tree().get_first_node_in_group("hud").show_prompt(prompt_text)

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		get_tree().get_first_node_in_group("hud").hide_prompt()

func interact() -> void:
	var hud: HUD = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.hide_prompt()

	var dialogue_box := get_tree().get_first_node_in_group("dialogue_box")
	if not dialogue_box:
		return

	# Déjà réparé
	if GameState.get_flag("scrap09_repaired"):
		return

	# Pas le circuit
	if not _has_required_items():
		dialogue_box.start(DIALOGUE_NO_ITEM)
		return

	# A le circuit → lancer mini-jeu
	dialogue_box.start(DIALOGUE_HAS_ITEM)
	dialogue_box.dialogue_finished.connect(_start_minigame, CONNECT_ONE_SHOT)

func _start_minigame() -> void:
	var dialogue_box := get_tree().get_first_node_in_group("dialogue_box")
	if dialogue_box:
		dialogue_box.hide()

	var minigame_node := preload("res://ui/minigame/repair_minigame.tscn").instantiate()
	get_tree().root.add_child(minigame_node)
	var minigame := minigame_node as RepairMinigame
	if minigame == null:
		return
	minigame.repair_complete.connect(_on_repair_done, CONNECT_ONE_SHOT)
	minigame.open("scrap09")

func _on_repair_done() -> void:
	GameState.remove_item("circuit", 1)
	GameState.set_flag("scrap09_repaired", true)

	var hud: HUD = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.show_log("Auto-diagnostic complet. Systèmes restaurés.")
		await get_tree().create_timer(2.5).timeout
		hud.show_log("Accès cour extérieure déverrouillé.")

	var dialogue_box := get_tree().get_first_node_in_group("dialogue_box")
	if dialogue_box:
		dialogue_box.start(DIALOGUE_DONE)

func _has_required_items() -> bool:
	for item_id in REQUIRED_ITEMS:
		if GameState.inventory.get(item_id, 0) < REQUIRED_ITEMS[item_id]:
			return false
	return true
