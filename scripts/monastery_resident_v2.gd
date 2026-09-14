extends "res://scripts/monastery_resident.gd"

func take_damage(_damage: float, source) -> void:
    var key := "resident_hit_%s" % resident_id
    var hits := int(GameState.world_flags.get(key, 0)) + 1
    GameState.world_flags[key] = hits

    if source is Node3D:
        var away: Vector3 = global_position - source.global_position
        away.y = 0.0
        if away.length() > 0.01:
            position += away.normalized() * 0.10

    if hits == 1:
        GameState.change_reputation("Flamen", -1)

    match resident_id:
        "archivist":
            GameState.message_requested.emit("Sel stumbles back from the table. 'If you're testing whether archivists bruise, the answer is yes.'")
        "keeper":
            GameState.message_requested.emit("Oru recoils and fixes you with both yellow eyes. 'Do not do that again.'")
        "sargasson_novice":
            GameState.message_requested.emit("Pell's respirator clicks sharply as he jerks away. 'What was that for?'")
        _:
            GameState.message_requested.emit("The resident recoils from the blow.")

func _archivist_dialogue() -> Dictionary:
    var q: Dictionary = GameState.quests.get("missing_copy", {})
    var state := str(q.get("state", "not_started"))

    if current_page == "archive_task":
        return {
            "speaker": display_name,
            "text": "One of my commentary copies walked out three days ago and hasn't walked back. If you find it, bring it here. And please don't replace it with an older copy just to make the shelf look tidy.",
            "choices": [{"text": "Do you know who took it?", "action": "archive_clue"}, {"text": "I'll keep an eye out.", "action": "close"}]
        }
    if current_page == "archive_clue":
        return {
            "speaker": display_name,
            "text": "Pell signed it out to the refectory. That narrows things down to every table he sat at and every place he stopped on the way back.",
            "choices": [{"text": "Back.", "action": "back"}]
        }
    if current_page == "archive_thanks":
        return {
            "speaker": display_name,
            "text": "There it is. Even has the cup ring. Thank you.",
            "choices": [{"text": "Goodbye.", "action": "close"}]
        }

    if state == "active" and GameState.has_item("missing_copy"):
        return {
            "speaker": display_name,
            "text": "That's it. I recognize the crease before I recognize the title.",
            "choices": [{"text": "Return the copied commentary.", "action": "archive_return"}, {"text": "Not yet.", "action": "close"}]
        }
    if state == "active":
        return {
            "speaker": display_name,
            "text": "No luck? Check the refectory before you start dismantling the library."
            ,"choices": [{"text": "What did the ledger say?", "action": "archive_clue"}, {"text": "Goodbye.", "action": "close"}]
        }
    if state == "completed":
        return {
            "speaker": display_name,
            "text": "The shelf is complete again. I give it until supper.",
            "choices": [{"text": "Goodbye.", "action": "close"}]
        }

    return {
        "speaker": display_name,
        "text": "Sel finishes a line before looking up at you.",
        "choices": [{"text": "Need help with anything?", "action": "archive_work"}, {"text": "Goodbye.", "action": "close"}]
    }

func _keeper_dialogue() -> Dictionary:
    if current_page == "keeper_colors":
        return {
            "speaker": display_name,
            "text": "That lamp and the one beside it don't match. They probably look identical to you. Gruhanian eyes are useful that way and irritating in almost every paint shop I've visited.",
            "choices": [{"text": "Back.", "action": "back"}]
        }
    if current_page == "keeper_plants":
        return {
            "speaker": display_name,
            "text": "Most of the green things here came from somewhere kinder. Iustitia keeps plants alive mostly because generations of stubborn monks refuse to let the cuttings die.",
            "choices": [{"text": "Back.", "action": "back"}]
        }
    return {
        "speaker": display_name,
        "text": "Oru scrapes a pale mineral crust from the basin and holds it to the light.",
        "choices": [
            {"text": "Something wrong with the lamps?", "action": "keeper_colors"},
            {"text": "Are the gardens native?", "action": "keeper_plants"},
            {"text": "Goodbye.", "action": "close"},
        ]
    }

func _sargasson_dialogue() -> Dictionary:
    if current_page == "sargasson_air":
        return {
            "speaker": display_name,
            "text": "The respirator? No. I forget it's there until somebody asks. Forgetting a spare coupling is much worse. Iustitia appears to own every thread size except the one my canister uses.",
            "choices": [{"text": "Back.", "action": "back"}]
        }
    if current_page == "sargasson_food":
        return {
            "speaker": display_name,
            "text": "The broth is fine. Your spoons were designed by enemies."
            ,"choices": [{"text": "Back.", "action": "back"}]
        }
    return {
        "speaker": display_name,
        "text": "Pell moves his cup farther from the copied pages as you approach.",
        "choices": [
            {"text": "How do you manage the air here?", "action": "sargasson_air"},
            {"text": "How's the food?", "action": "sargasson_food"},
            {"text": "Goodbye.", "action": "close"},
        ]
    }

func _build_sargasson() -> void:
    var model := Node3D.new()
    model.name = "CharacterModel"
    add_child(model)
    var hide := Color(0.48, 0.42, 0.34)
    var hide_dark := Color(0.29, 0.26, 0.22)
    var eye := Color(0.72, 0.83, 0.66)

    _box_visual(model, Vector3(0, 0.96, 0), Vector3(0.42, 0.82, 0.28), body_color)
    _box_visual(model, Vector3(0, 0.63, 0), Vector3(0.48, 0.10, 0.32), body_color.darkened(0.30))

    # Three legs: two forward and one rear support.
    _limb(model, Vector3(-0.18, 0.34, -0.11), 0.07, 0.68, hide_dark, Vector3(0, 0, -4))
    _limb(model, Vector3(0.18, 0.34, -0.11), 0.07, 0.68, hide_dark, Vector3(0, 0, 4))
    _limb(model, Vector3(0, 0.34, 0.18), 0.07, 0.66, hide_dark, Vector3(5, 0, 0))

    _limb(model, Vector3(-0.31, 0.97, 0), 0.065, 0.62, hide, Vector3(0, 0, -7))
    _limb(model, Vector3(0.31, 0.97, 0), 0.065, 0.62, hide, Vector3(0, 0, 7))

    # Sargasson skulls are vertically elongated rather than long front-to-back.
    _sphere_visual(model, Vector3(0, 1.60, 0.02), Vector3(0.24, 0.50, 0.27), hide)
    _sphere_visual(model, Vector3(0, 1.45, -0.24), Vector3(0.17, 0.22, 0.22), hide)

    # Eye stalks emerge from the sides of the upper skull, not its crown.
    _limb(model, Vector3(-0.29, 1.72, -0.08), 0.033, 0.28, hide_dark, Vector3(0, 0, 78))
    _limb(model, Vector3(0.29, 1.72, -0.08), 0.033, 0.28, hide_dark, Vector3(0, 0, -78))
    _sphere_visual(model, Vector3(-0.43, 1.75, -0.10), Vector3(0.07, 0.07, 0.06), eye)
    _sphere_visual(model, Vector3(0.43, 1.75, -0.10), Vector3(0.07, 0.07, 0.06), eye)

    # Respirator mouthpiece, hip canister, and hose.
    _box_visual(model, Vector3(0, 1.38, -0.43), Vector3(0.25, 0.15, 0.10), Color(0.10, 0.13, 0.14))
    _box_visual(model, Vector3(0.31, 0.72, 0.03), Vector3(0.20, 0.42, 0.24), Color(0.12, 0.15, 0.16))
    _limb(model, Vector3(0.23, 1.02, -0.19), 0.025, 0.82, Color(0.08, 0.10, 0.10), Vector3(38, 0, -22))
