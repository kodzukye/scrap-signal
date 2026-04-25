extends Control

# Textes selon les endings — tirés du GDD
const ENDING_A: Array[String] = [
	"SCRAP-09 s'arrête devant la sortie.",
	"Il hésite.",
	"Puis il avance.",
	"",
	"Sans savoir encore où il va.",
]

const ENDING_B: Array[String] = [
	"SCRAP-09 s'arrête devant la sortie.",
	"Il se retourne.",
	"VRAC-7. IRIS-3. L'usine.",
	"",
	"Il décide de rester.",
]

const LOG_A := "Destination non définie. Navigation autonome activée."
const LOG_B := "Protocole de continuité autonome. Statut : actif."

@onready var text_label     := $CenterContainer/VBoxContainer/TextLabel
@onready var log_label      := $CenterContainer/VBoxContainer/LogLabel
@onready var fade_rect      := $FadeRect
@onready var continue_label := $ContinueLabel

var _lines: Array[String] = []
var _current_line := 0
var _can_continue := false
var _finished := false
var _blink_tween : Tween

func _ready() -> void:
	var is_ending_b := GameState.get_flag("iris3_repaired")
	_lines = ENDING_B if is_ending_b else ENDING_A
	log_label.text = LOG_B if is_ending_b else LOG_A
	log_label.visible = false
	log_label.modulate.a = 0.0
	text_label.text = ""

	fade_rect.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, 1.2)
	tween.tween_callback(_show_next_line)

func _show_next_line() -> void:
	if _current_line >= _lines.size():
		_show_log()
		return

	_can_continue = false
	_hide_continue()

	var line := _lines[_current_line]
	_current_line += 1
	text_label.text = ""

	if line == "":
		await get_tree().create_timer(0.4).timeout
		_can_continue = true
		_show_continue()
		return

	var tween := create_tween()
	for i in line.length():
		tween.tween_callback(func(): text_label.text += line[text_label.text.length()])
		tween.tween_interval(0.04)
	tween.tween_interval(0.3)
	tween.tween_callback(func():
		_can_continue = true
		_show_continue()
	)

func _show_log() -> void:
	_can_continue = false
	_hide_continue()
	await get_tree().create_timer(0.8).timeout
	log_label.visible = true
	log_label.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(log_label, "modulate:a", 1.0, 0.8)
	tween.tween_interval(2.0)
	tween.tween_callback(_show_credits)

func _show_credits() -> void:
	_finished = true
	_can_continue = true
	_show_continue()

func _show_continue() -> void:
	continue_label.modulate.a = 0.0
	if _blink_tween:
		_blink_tween.kill()
	_blink_tween = create_tween().set_loops()
	_blink_tween.tween_property(continue_label, "modulate:a", 1.0, 0.4)
	_blink_tween.tween_interval(0.2)
	_blink_tween.tween_property(continue_label, "modulate:a", 0.0, 0.4)
	_blink_tween.tween_interval(0.2)

func _hide_continue() -> void:
	if _blink_tween:
		_blink_tween.kill()
	continue_label.modulate.a = 0.0

func _unhandled_input(event: InputEvent) -> void:
	if not _can_continue:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		_next()
	if event is InputEventJoypadButton and event.pressed:
		_next()

func _next() -> void:
	_can_continue = false
	_hide_continue()
	if _finished:
		_go_to_menu()
		return
	_show_next_line()

func _go_to_menu() -> void:
	_can_continue = false
	var tween := create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 1.0)
	tween.tween_callback(func():
		get_tree().change_scene_to_file("res://levels/credits.tscn")
	)
