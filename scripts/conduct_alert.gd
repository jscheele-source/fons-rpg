extends RefCounted

# The immediate safety response is separate from the permanent conduct record.
# All flags are JSON-safe and survive the existing save/load workflow.
const CONDUCT = preload("res://scripts/conduct_rules.gd")

static func active() -> bool:
    return bool(GameState.world_flags.get("conduct_alert_active", false))

static func defied() -> bool:
    return bool(GameState.world_flags.get("conduct_alert_defied", false))

static func involved(person_id: String) -> bool:
    if not active():
        return false
    if str(GameState.world_flags.get("conduct_alert_victim", "")) == person_id:
        return true
    var heard: Array = GameState.world_flags.get("conduct_latest_witnesses", [])
    return heard.has(person_id)

static func report_incident(victim: Node3D, aggressor: Node3D, person_id: String) -> void:
    # Called immediately after Conduct.record_assault, which has already
    # gathered the victim's nearby witnesses and updated the permanent record.
    var flags: Dictionary = GameState.world_flags
    flags["conduct_alert_active"] = true
    flags["conduct_alert_defied"] = false
    flags["conduct_alert_victim"] = person_id
    flags["conduct_alert_sequence"] = int(flags.get("conduct_alert_sequence", 0)) + 1
    flags["conduct_alert_warning_shown"] = false

    var heard: Array = flags.get("conduct_latest_witnesses", [])
    if victim.is_inside_tree():
        for candidate in victim.get_tree().get_nodes_in_group("conduct_witnesses"):
            if not candidate.has_method("get_conduct_id"):
                continue
            if heard.has(str(candidate.get_conduct_id())) and candidate.has_method("react_to_assault"):
                candidate.react_to_assault(aggressor)

    if heard.is_empty():
        GameState.message_requested.emit("The resident calls out for help. Report to Varro and stand down.")
    else:
        var first_name: String = str(CONDUCT.NAMES.get(str(heard[0]), "A nearby resident"))
        GameState.message_requested.emit("%s calls for help. Varro is responding; do not strike again." % first_name)
    GameState.state_changed.emit()

static func stand_down() -> bool:
    if not active() or defied():
        return false
    GameState.world_flags["conduct_alert_active"] = false
    GameState.world_flags["conduct_compliances"] = int(GameState.world_flags.get("conduct_compliances", 0)) + 1
    var line := "Varro accepts your compliance. The assault remains on record."
    if CONDUCT.pending():
        line += " You still have a hearing to resolve."
    GameState.message_requested.emit(line)
    GameState.state_changed.emit()
    return true

static func refuse_order() -> bool:
    if not active() or defied():
        return false
    GameState.world_flags["conduct_alert_defied"] = true
    GameState.world_flags["conduct_pending"] = true
    GameState.world_flags["conduct_defiances"] = int(GameState.world_flags.get("conduct_defiances", 0)) + 1
    GameState.change_reputation("Flamen", -3)
    GameState.message_requested.emit("You refuse Varro's order. A formal report is filed, and your duties stop until the hearing.")
    GameState.state_changed.emit()
    return true

static func end_incident() -> void:
    # A paid/served/reprimanded hearing clears the immediate standoff, never
    # the permanent hit count, witnesses, opinions, or defiance history.
    if not active() and not defied():
        return
    GameState.world_flags["conduct_alert_active"] = false
    GameState.world_flags["conduct_alert_defied"] = false
    GameState.state_changed.emit()

static func confront_dialogue(speaker: String) -> Dictionary:
    return {
        "speaker": speaker,
        "text": "Enough. I heard the cry. Step back and lower your hands. We will deal with the harm you caused without another blow.",
        "choices": [
            {"text": "Stand down and comply.", "action": "conduct_yield"},
            {"text": "Refuse Varro's order.", "action": "conduct_defy"},
            {"text": "Walk away for now.", "action": "close"},
        ],
    }

static func add_standoff_choices(dialogue: Dictionary) -> Dictionary:
    if not active():
        return dialogue
    var result: Dictionary = dialogue.duplicate(true)
    if defied():
        result["text"] = "You refused my order. That refusal is now part of this report. " + str(result.get("text", ""))
        return result
    result["text"] = "Stop there. Lower your hands. " + str(result.get("text", ""))
    var choices: Array = result.get("choices", []).duplicate(true)
    choices.insert(0, {"text": "Stand down (the hearing will still proceed).", "action": "conduct_yield"})
    choices.insert(1, {"text": "Refuse the order and accept another charge.", "action": "conduct_defy"})
    result["choices"] = choices
    return result

static func warn_once() -> void:
    if not active() or bool(GameState.world_flags.get("conduct_alert_warning_shown", false)):
        return
    GameState.world_flags["conduct_alert_warning_shown"] = true
    GameState.message_requested.emit("Varro approaches: 'Stop. Speak to me before anyone else is hurt.'")
    GameState.state_changed.emit()
