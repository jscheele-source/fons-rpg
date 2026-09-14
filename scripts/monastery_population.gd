extends Node3D

const RESIDENT = preload("res://scripts/monastery_resident.gd")
const PICKUP = preload("res://scripts/pickup.gd")
const LORE = preload("res://scripts/lore_object.gd")

const INTERIOR_ORIGIN := Vector3(-108.0, 0.0, 0.0)

func _ready() -> void:
    # Main loads an existing save in its own _ready(). Defer population so
    # side-quest state and pickups are built from the restored data.
    call_deferred("_initialize_population")

func _initialize_population() -> void:
    _ensure_side_quest()
    _spawn_residents()
    _spawn_missing_copy()
    _spawn_readables()

func _ensure_side_quest() -> void:
    if GameState.quests.has("missing_copy"):
        return
    GameState.quests["missing_copy"] = {
        "name": "The Missing Copy",
        "state": "not_started",
        "stage": 0,
        "resolution": "",
        "objectives": ["Find the missing copied commentary and return it to Archivist Sel."],
    }

func _spawn_residents() -> void:
    var archivist = RESIDENT.new()
    archivist.display_name = "Archivist Sel"
    archivist.resident_id = "archivist"
    archivist.species = "Felid"
    archivist.body_color = Color(0.27, 0.20, 0.15)
    archivist.position = INTERIOR_ORIGIN + Vector3(18.3, 0.10, -24.6)
    archivist.rotation_degrees.y = -20.0
    add_child(archivist)

    var keeper = RESIDENT.new()
    keeper.display_name = "Keeper Oru"
    keeper.resident_id = "keeper"
    keeper.species = "Gruhanian"
    keeper.body_color = Color(0.24, 0.22, 0.13)
    keeper.position = INTERIOR_ORIGIN + Vector3(5.8, 0.10, -41.2)
    keeper.rotation_degrees.y = -65.0
    add_child(keeper)

    var novice = RESIDENT.new()
    novice.display_name = "Novice Pell"
    novice.resident_id = "sargasson_novice"
    novice.species = "Sargasson"
    novice.body_color = Color(0.25, 0.27, 0.30)
    novice.position = INTERIOR_ORIGIN + Vector3(13.2, 0.10, -38.0)
    novice.rotation_degrees.y = 35.0
    add_child(novice)

func _spawn_missing_copy() -> void:
    var q: Dictionary = GameState.quests.get("missing_copy", {})
    if str(q.get("state", "")) == "completed" or GameState.has_item("missing_copy"):
        return
    var copy = PICKUP.new()
    copy.item_id = "missing_copy"
    copy.display_name = "Copied Commentary"
    copy.description = "A hand-copied commentary on the early Quinconsistory. A refectory cup has left a pale ring on the cover."
    copy.item_color = Color(0.56, 0.45, 0.28)
    copy.position = INTERIOR_ORIGIN + Vector3(13.65, 0.55, -36.9)
    add_child(copy)

func _spawn_readables() -> void:
    var ledger = LORE.new()
    ledger.title = "Scriptorium Sign-out Ledger"
    ledger.prompt = "Read"
    ledger.object_color = Color(0.22, 0.17, 0.10)
    ledger.body = "Most entries are ordinary: copying tablets, doctrinal summaries, maintenance diagrams. One line near the bottom reads:\n\n[i]Early Quinconsistory, commentary copy 6 — Pell — refectory.[/i]\n\nA second hand has added beside it: [i]AGAIN?[/i]"
    ledger.position = INTERIOR_ORIGIN + Vector3(17.9, 0.0, -22.8)
    add_child(ledger)

    var notice = LORE.new()
    notice.title = "Service Wing Notice"
    notice.prompt = "Read"
    notice.object_color = Color(0.18, 0.19, 0.17)
    notice.body = "NOVICES ASSIGNED TO COPYING DUTY:\n\nInk belongs in the scriptorium. Food belongs in the refectory. If you require both at once, you require patience instead.\n\nSomeone has scratched beneath the notice: [i]Patience does not keep soup warm.[/i]"
    notice.position = INTERIOR_ORIGIN + Vector3(10.0, 0.0, -22.25)
    add_child(notice)

    var table_note = LORE.new()
    table_note.title = "Folded Meal Slate"
    table_note.prompt = "Read"
    table_note.object_color = Color(0.16, 0.18, 0.17)
    table_note.body = "Morning: grain broth, preserved fruit, bitter tea.\nMidday: root mash, flatbread, greens from the lower garden.\nEvening: broth again.\n\nA small notation at the bottom reads: [i]Off-world respiratory diets available by request. Stop asking Pell whether he can taste the gas.[/i]"
    table_note.position = INTERIOR_ORIGIN + Vector3(7.8, 0.0, -38.4)
    add_child(table_note)
