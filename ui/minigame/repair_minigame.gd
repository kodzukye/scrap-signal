class_name RepairMinigame
extends CanvasLayer

signal repair_complete

const PUZZLES := {
	"vrac7": {
		"title": "RECONNEXION — SYSTÈME MOTEUR",
		"connections": [[0, 0], [1, 2], [3, 3]]
	},
	"iris3": {
		"title": "RECALIBRATION — CAPTEUR OPTIQUE",
		"connections": [[0, 1], [2, 3]]
	},
	"scrap09": { 
		"title": "AUTO-RÉPARATION — SCRAP-09",
		"connections": [[0, 0], [1, 2], [2, 3]]
	},
}

const GRID_SIZE := 4

var current_puzzle: Dictionary
var paths: Array = []
var active_path: int = -1
var solved_paths: Array = []

@onready var grid      := $Background/Panel/VBoxContainer/Grid
@onready var title_lbl := $Background/Panel/VBoxContainer/Title
@onready var status    := $Background/Panel/VBoxContainer/StatusLabel

# ── Lifecycle ─────────────────────────────────────────────────────────────────

func _ready() -> void:
	layer = 1000

	var panel := $Background/Panel
	panel.set_anchors_preset(Control.PRESET_CENTER)

	var vbox := $Background/Panel/VBoxContainer
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 12)

	# Centre la grid horizontalement dans le VBox
	grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	grid.size_flags_vertical   = Control.SIZE_SHRINK_CENTER

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_cancel()

# ── API publique ──────────────────────────────────────────────────────────────

func open(robot_id: String) -> void:
	current_puzzle = PUZZLES[robot_id]
	title_lbl.text = current_puzzle["title"]
	paths.clear()
	solved_paths.clear()
	for _c in current_puzzle["connections"]:
		paths.append([])
		solved_paths.append(false)
	_set_hud_visible(false)
	_set_player_enabled(false)
	_build_grid()
	_update_status()
	show()

# ── Grille ────────────────────────────────────────────────────────────────────

func _build_grid() -> void:
	for child in grid.get_children():
		child.queue_free()

	# Taille fixe de la grille : GRID_SIZE * taille bouton + séparation
	var cell_size := 25
	var separation := 4
	var grid_px := GRID_SIZE * cell_size + (GRID_SIZE - 1) * separation
	grid.custom_minimum_size = Vector2(grid_px, grid_px)
	grid.columns = GRID_SIZE

	for row in GRID_SIZE:
		for col in GRID_SIZE:
			var btn := Button.new()
			btn.custom_minimum_size = Vector2(cell_size, cell_size)
			btn.name = "Cell_%d_%d" % [row, col]
			btn.add_theme_stylebox_override("normal", _make_stylebox(Color(0.15, 0.15, 0.15), 1.0))
			btn.add_theme_stylebox_override("hover",  _make_stylebox(Color(0.25, 0.25, 0.25), 1.0))

			if col == 0:
				var path_idx = _entry_for_row(row)
				if path_idx >= 0:
					btn.text = "●"
					btn.modulate = _color_for_path(path_idx)
			elif col == 3:
				var path_idx = _exit_for_row(row)
				if path_idx >= 0:
					btn.text = "●"
					btn.modulate = _color_for_path(path_idx)

			btn.pressed.connect(_on_cell_pressed.bind(row, col))
			grid.add_child(btn)

func _on_cell_pressed(row: int, col: int) -> void:
	var entry_idx = _entry_for_row(row)
	if col == 0 and entry_idx >= 0:
		active_path = entry_idx
		paths[active_path] = [Vector2i(row, col)]
		_refresh_grid()
		return

	if active_path < 0:
		return

	var last: Vector2i = paths[active_path].back() if paths[active_path].size() > 0 else Vector2i(-1, -1)
	var cell := Vector2i(row, col)

	if not _is_adjacent(last, cell):
		return

	for i in paths.size():
		if i == active_path:
			continue
		if cell in paths[i]:
			return

	paths[active_path].append(cell)

	var exit_row = current_puzzle["connections"][active_path][1]
	if col == 3 and row == exit_row:
		solved_paths[active_path] = true
		active_path = -1
		_refresh_grid()
		_update_status()
		_check_win()
		return

	_refresh_grid()
	_update_status()

# ── Victoire / Annulation ─────────────────────────────────────────────────────

func _check_win() -> void:
	if solved_paths.all(func(s): return s == true):
		await get_tree().create_timer(0.6).timeout
		repair_complete.emit()
		_close()

func _cancel() -> void:
	active_path = -1
	_close()

func _close() -> void:
	_set_hud_visible(true)
	_set_player_enabled(true)
	hide()

# ── Affichage ─────────────────────────────────────────────────────────────────

func _refresh_grid() -> void:
	for row in GRID_SIZE:
		for col in GRID_SIZE:
			var btn: Button = grid.get_node_or_null("Cell_%d_%d" % [row, col])
			if btn == null:
				continue
			var cell := Vector2i(row, col)
			var found := false

			for i in paths.size():
				if cell in paths[i]:
					var c := _color_for_path(i)
					var is_endpoint := (col == 0 or col == 3)
					btn.text = "●" if is_endpoint else "■"
					btn.modulate = Color.WHITE
					btn.add_theme_stylebox_override("normal", _make_stylebox(c, 0.5))
					btn.add_theme_color_override("font_color", c)
					found = true
					break

			if not found:
				btn.modulate = Color.WHITE
				btn.text = ""
				btn.add_theme_stylebox_override("normal", _make_stylebox(Color(0.15, 0.15, 0.15), 1.0))
				btn.remove_theme_color_override("font_color")
				var ei = _entry_for_row(row)
				var xi = _exit_for_row(row)
				if col == 0 and ei >= 0:
					btn.text = "●"
					btn.add_theme_color_override("font_color", _color_for_path(ei))
				elif col == 3 and xi >= 0:
					btn.text = "●"
					btn.add_theme_color_override("font_color", _color_for_path(xi))

func _update_status() -> void:
	var count := solved_paths.count(true)
	var total := solved_paths.size()
	if count == total:
		status.text = "✓ RÉPARATION COMPLÈTE"
		status.add_theme_color_override("font_color", Color("#6daa45"))
	else:
		status.text = "%d / %d connexions établies" % [count, total]
		status.remove_theme_color_override("font_color")

# ── Helpers ───────────────────────────────────────────────────────────────────

func _set_hud_visible(visible: bool) -> void:
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.visible = visible

func _make_stylebox(color: Color, alpha: float) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(color.r, color.g, color.b, alpha)
	sb.corner_radius_top_left    = 4
	sb.corner_radius_top_right   = 4
	sb.corner_radius_bottom_left = 4
	sb.corner_radius_bottom_right = 4
	return sb

func _entry_for_row(row: int) -> int:
	for i in current_puzzle["connections"].size():
		if current_puzzle["connections"][i][0] == row:
			return i
	return -1

func _exit_for_row(row: int) -> int:
	for i in current_puzzle["connections"].size():
		if current_puzzle["connections"][i][1] == row:
			return i
	return -1

func _is_adjacent(a: Vector2i, b: Vector2i) -> bool:
	return abs(a.x - b.x) + abs(a.y - b.y) == 1

func _color_for_path(idx: int) -> Color:
	var colors := [Color("#f4c430"), Color("#5bc8f5"), Color("#f47c3c")]
	return colors[idx % colors.size()]

func _set_player_enabled(enabled: bool) -> void:
	var player = get_tree().get_first_node_in_group("player")
	print("_set_player_enabled: ", enabled, " | player trouvé: ", player)
	if player:
		player.set_process(enabled)
		player.set_physics_process(enabled)
		player.set_process_unhandled_input(enabled)
		player.is_locked = false
		if not enabled and player is CharacterBody2D:
			player.velocity = Vector2.ZERO
