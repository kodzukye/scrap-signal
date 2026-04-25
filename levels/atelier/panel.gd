class_name PanelJournal
extends Area2D

@export var prompt_text: String = "[E] Lire"
@export var journal_id: String = "D-891"

const DIALOGUE: Array[Dictionary] = [
	{ "name": "JOURNAL D-891", "text": "Dernier jour. J'ai vérifié les générateurs ils tiendront des années." },
	{ "name": "JOURNAL D-891", "text": "J'ai laissé les réservoirs de maintenance pleins. Je ne sais pas si c'est légal." },
	{ "name": "JOURNAL D-891", "text": "Mais ça change quelque chose pour moi.       — Matteo Corda, Directeur" },
]


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func interact() -> void:
	print("Journal interact() appelé")
	
	var hud := get_tree().get_first_node_in_group("hud")
	if hud:
		hud.hide_prompt()
	
	if journal_id != "":
		GameState.set_flag(journal_id + "_read", true)
	
	var dialogue_box := get_tree().get_first_node_in_group("dialogue_box")
	print("dialogue_box trouvé : ", dialogue_box)
	
	if dialogue_box:
		print("Lancement dialogue avec : ", DIALOGUE)
		dialogue_box.start(DIALOGUE)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		var hud: HUD = get_tree().get_first_node_in_group("hud")
		if hud: hud.show_prompt(prompt_text)

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		var hud: HUD = get_tree().get_first_node_in_group("hud")
		if hud: hud.hide_prompt()
