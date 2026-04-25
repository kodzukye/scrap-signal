extends Area2D
class_name Vrac7

@export var prompt_text: String = "[E] Parler"

@onready var sprite := $AnimatedSprite2D

# ── Dialogues ────────────────────────────────────────────────────────────────

const DIALOGUE_INTRO := [
	{ "name": "VRAC-7", "text": "Toi... tu es nouveau ? Non, attends— SCRAP-09 ? Tu as dormi longtemps. Très longtemps." },
	{ "name": "VRAC-7", "text": "Je suis coincé sous cette étagère depuis... je ne sais plus. Tu peux m'aider ?" },
	{ "name": "VRAC-7", "text": "Il me faut 3 engrenages. J'en ai vu par là dans l'entrepôt." },
]

const DIALOGUE_MISSING_ITEMS := [
	{ "name": "VRAC-7", "text": "Pas encore les pièces ? L'entrepôt est grand." },
	{ "name": "VRAC-7", "text": "Les engrenages sont tombés près des étagères quelque part. Un semble ^" },
]

const DIALOGUE_HAS_ITEMS := [
	{ "name": "VRAC-7", "text": "Tu les as. Bien. Connecte les circuits — mon système moteur est encore là, quelque part." },
]

const DIALOGUE_POST_REPAIR := [
	{ "name": "VRAC-7", "text": "Ah. Voilà. Je n'avais pas oublié ce que c'était de bouger, mais... c'est différent de s'en souvenir." },
	{ "name": "VRAC-7", "text": "Je me souviens du dernier jour. Ils ont éteint les lumières en partant. Mais ils ont laissé les générateurs allumés. Je crois que c'était intentionnel." },
	{ "name": "VRAC-7", "text": "L'atelier est par là. La clé magnétique — tiens. Elle était dans ma pince depuis le début. Je la gardais pour quelqu'un." },
]

const DIALOGUE_AFTER_ATELIER := [
	{ "name": "VRAC-7", "text": "Tu as trouvé ce que tu cherchais ? Moi je reste ici." },
	{ "name": "VRAC-7", "text": "Pas par obligation. C'est juste que... cet endroit est à nous maintenant. Quelqu'un doit s'en occuper." },
]

# ── Items requis ──────────────────────────────────────────────────────────────

const REQUIRED_ITEMS := {
	"engrenage": 3,
}

# ── Lifecycle ─────────────────────────────────────────────────────────────────

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		var hud: HUD = get_tree().get_first_node_in_group("hud")
		if hud:
			hud.show_prompt(prompt_text)

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		var hud: HUD = get_tree().get_first_node_in_group("hud")
		if hud:
			hud.hide_prompt()

# ── Interaction principale ────────────────────────────────────────────────────

func interact() -> void:
	var hud: HUD = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.hide_prompt()

	var dialogue_box := get_tree().get_first_node_in_group("dialogue_box")
	if not dialogue_box:
		return

	# État 1 — Déjà réparé, joueur revient après avoir visité l'atelier
	if GameState.get_flag("vrac7_repaired") and GameState.get_flag("visited_atelier"):
		dialogue_box.start(DIALOGUE_AFTER_ATELIER)
		return

	# État 2 — Déjà réparé, dialogue post-réparation standard
	if GameState.get_flag("vrac7_repaired"):
		dialogue_box.start(DIALOGUE_POST_REPAIR)
		return

	# État 3 — Possède les items → lancer le mini-jeu
	if _has_required_items():
		dialogue_box.start(DIALOGUE_HAS_ITEMS)
		dialogue_box.dialogue_finished.connect(_start_minigame, CONNECT_ONE_SHOT)
		return

	# État 4 — Premier contact (jamais parlé)
	if not GameState.get_flag("vrac7_met"):
		GameState.set_flag("vrac7_met", true)
		dialogue_box.start(DIALOGUE_INTRO)
		return

	# État 5 — Revient sans les items
	dialogue_box.start(DIALOGUE_MISSING_ITEMS)

# ── Mini-jeu ──────────────────────────────────────────────────────────────────

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
	minigame.open("vrac7")

func _on_repair_done() -> void:
	sprite.play("repaired")
	
	# Consomme les items
	GameState.remove_item("engrenage", 3)

	# Donne la clé de l'atelier
	GameState.add_item("cle_atelier", 1)
	GameState.set_flag("vrac7_repaired", true)

	# LOG système
	var hud: HUD = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.show_log("Unité VRAC-7 : réparation complète. Statut : opérationnel.")
		await get_tree().create_timer(3).timeout
		hud.show_log("Clé magnétique obtenue. Accès atelier déverrouillé.")

	# Dialogue post-réparation
	var dialogue_box := get_tree().get_first_node_in_group("dialogue_box")
	if dialogue_box:
		dialogue_box.start(DIALOGUE_POST_REPAIR)

# ── Helpers ───────────────────────────────────────────────────────────────────

func _has_required_items() -> bool:
	for item_id in REQUIRED_ITEMS:
		if GameState.inventory.get(item_id, 0) < REQUIRED_ITEMS[item_id]:
			return false
	return true
