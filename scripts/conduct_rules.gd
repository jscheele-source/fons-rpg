extends RefCounted

# No scene nodes or rendering resources. All conduct data lives in world_flags,
# which the existing save/load system already serializes.
const FINE := 20
const WITNESS_RADIUS := 11.5
const NAMES := {
    "courtyard_varro": "Preceptor Varro",
    "courtyard_cael": "Brother Cael",
    "courtyard_sera": "Surveyor Nemm",
    "courtyard_novice": "Initiate Kes",
    "resident_archivist": "Archivist Sel",
    "resident_keeper": "Keeper Oru",
    "resident_sargasson_novice": "Novice Pell",
    "elder_davian": "Elder Davian",
}

static func pending() -> bool:
    return bool(GameState.world_flags.get("conduct_pending", false))

static func attitude(person_id: String) -> int:
    var opinions: Dictionary = GameState.world_flags.get("conduct_opinions", {})
    return int(opinions.get(person_id, 50))

static func hits(person_id: String) -> int:
    var records: Dictionary = GameState.world_flags.get("conduct_hits", {})
    return int(records.get(person_id, 0))

static func can_apologize(person_id: String) -> bool:
    var apologies: Dictionary = GameState.world_flags.get("conduct_apologies", {})
    return not pending() and hits(person_id) > int(apologies.get(person_id, 0))

static func _legacy_key(person_id: String) -> String:
    if person_id.begins_with("courtyard_"):
        return "npc_hit_" + person_id.trim_prefix("courtyard_")
    if person_id.begins_with("resident_"):
        return "resident_hit_" + person_id.trim_prefix("resident_")
    return "davian_hit"

static func record_assault(victim: Node3D, source: Node3D, person_id: String, reaction: String) -> void:
    var flags: Dictionary = GameState.world_flags
    var opinions: Dictionary = flags.get("conduct_opinions", {}).duplicate(true)
    var records: Dictionary = flags.get("conduct_hits", {}).duplicate(true)
    var witness_records: Dictionary = flags.get("conduct_witnesses", {}).duplicate(true)

    var old_hits: int = int(records.get(person_id, int(flags.get(_legacy_key(person_id), 0))))
    var current_hits: int = old_hits + 1
    records[person_id] = current_hits
    flags[_legacy_key(person_id)] = current_hits
    opinions[person_id] = maxi(0, int(opinions.get(person_id, 50)) - 25)

    var names: Array[String] = []
    if victim.is_inside_tree():
        for candidate in victim.get_tree().get_nodes_in_group("conduct_witnesses"):
            if candidate == victim or not candidate is Node3D or not candidate.has_method("get_conduct_id"):
                continue
            var other: Node3D = candidate
            if victim.global_position.distance_to(other.global_position) > WITNESS_RADIUS:
                continue
            var other_id: String = str(candidate.get_conduct_id())
            if other_id == "" or other_id == person_id:
                continue
            opinions[other_id] = maxi(0, int(opinions.get(other_id, 50)) - 8)
            witness_records[other_id] = int(witness_records.get(other_id, 0)) + 1
            names.append(str(candidate.get("display_name")))

    var total: int = int(flags.get("conduct_total", 0)) + 1
    var was_pending: bool = bool(flags.get("conduct_pending", false))
    flags["conduct_total"] = total
    flags["conduct_hits"] = records
    flags["conduct_opinions"] = opinions
    flags["conduct_witnesses"] = witness_records
    flags["conduct_last_victim"] = str(NAMES.get(person_id, person_id))
    if total >= 2 or person_id == "courtyard_varro" or person_id == "elder_davian":
        flags["conduct_pending"] = true

    var penalty: int = -mini(current_hits, 3)
    if bool(flags.get("conduct_probation", false)):
        penalty -= 1
    GameState.change_reputation("Flamen", penalty)

    var notice := reaction
    if pending() and not was_pending:
        notice += " Varro demands an explanation."
    elif names.size() > 0:
        notice += " %s witnessed it." % names[0]
    else:
        notice += " They will remember."
    GameState.message_requested.emit(notice)
    GameState.state_changed.emit()

static func resolve_report(method: String) -> bool:
    if not pending():
        return false
    if method == "restitution":
        if GameState.credits < FINE:
            GameState.message_requested.emit("You cannot afford the twenty-credit restitution.")
            return false
        GameState.add_credits(-FINE)
        GameState.world_flags["conduct_probation"] = false
        GameState.message_requested.emit("Varro records restitution of twenty credits. The testimony remains on file.")
    elif method == "reprimand":
        GameState.change_reputation("Flamen", -2)
        GameState.world_flags["conduct_probation"] = true
        GameState.message_requested.emit("Varro issues a formal reprimand. Another assault on probation will cost more standing.")
    else:
        return false
    GameState.world_flags["conduct_pending"] = false
    GameState.world_flags["conduct_resolutions"] = int(GameState.world_flags.get("conduct_resolutions", 0)) + 1
    GameState.state_changed.emit()
    return true

static func apologize(person_id: String) -> bool:
    if not can_apologize(person_id):
        return false
    var apologies: Dictionary = GameState.world_flags.get("conduct_apologies", {}).duplicate(true)
    var opinions: Dictionary = GameState.world_flags.get("conduct_opinions", {}).duplicate(true)
    apologies[person_id] = hits(person_id)
    opinions[person_id] = mini(50, int(opinions.get(person_id, 50)) + 12)
    GameState.world_flags["conduct_apologies"] = apologies
    GameState.world_flags["conduct_opinions"] = opinions
    GameState.message_requested.emit("Your apology is heard. Trust will take longer to recover.")
    GameState.state_changed.emit()
    return true

static func review_dialogue(speaker: String) -> Dictionary:
    var last_victim: String = str(GameState.world_flags.get("conduct_last_victim", "a resident"))
    var choices: Array = [
        {"text": "Accept a formal reprimand and probation.", "action": "conduct_reprimand"},
    ]
    if GameState.credits >= FINE:
        choices.append({"text": "Pay twenty credits in restitution.", "action": "conduct_restitution"})
    choices.append({"text": "I will return later.", "action": "close"})
    return {
        "speaker": speaker,
        "text": "An assault on %s has been entered in the register. Until we settle it, your monastery duties are suspended." % last_victim,
        "choices": choices,
    }

static func temper_text(person_id: String) -> String:
    var score: int = attitude(person_id)
    if score <= 15:
        return "They keep their distance and watch your hands. "
    if score < 45:
        return "They regard you warily. "
    return ""

static func status_text() -> String:
    if pending():
        return "Report pending — speak to Preceptor Varro."
    if bool(GameState.world_flags.get("conduct_probation", false)):
        return "On probation — further violence carries an extra penalty."
    return "No unresolved report."
