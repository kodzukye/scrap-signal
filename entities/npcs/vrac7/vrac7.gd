extends Area2D

class_name Vrac7

@export var prompt_text : String = "[E] Parler"

# Dialogue initial — avant réparation
const DIALOGUE_INTRO := [
	{ "name": "VRAC-7", "text": "Toi... tu es nouveau ? Non, attends — SCRAP-09 ? Tu as dormi longtemps. Très longtemps." },
	{ "name": "VRAC-7", "text": "Je suis coincé sous cette étagère depuis... je ne sais plus. Tu peux m'aider ?" },
	{ "name": "VRAC-7", "text": "Il me faut 1 engrenage et 1 câble. J'en ai vu par là dans l'entrepôt." },
]

# Dialogue après réparation
const DIALOGUE_REPAIRED := [
	{ "name": "VRAC-7", "text": "Je me souviens du dernier jour. Ils ont éteint les lumières en partant." },
	{ "name": "VRAC-7", "text": "Mais ils ont laissé les générateurs allumés. Je crois que c'était intentionnel." },
	{ "name": "VRAC-7", "text": "L'atelier est par là. Prends la clé — tu en auras besoin." },
]

func interact() -> void:
	var hud : HUD = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.hide_prompt()
	var dialogue_box : DialogueBox = get_tree().get_first_node_in_group("dialogue_box")
	if not dialogue_box:
		return
	if GameState.repaired.get("vrac7", false):
		dialogue_box.start(DIALOGUE_REPAIRED)
	else:
		dialogue_box.start(DIALOGUE_INTRO)
