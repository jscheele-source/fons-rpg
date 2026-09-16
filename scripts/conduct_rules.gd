extends RefCounted

# All disciplinary state remains in world_flags: older saves and the M2 world
# work without migration, and this module allocates no scene/visual resources.
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
const SERVICE_TASKS := {"post": "Inspect and secure the courtyard training post", "annex": "Review the annex terminal's safety record", "drill": "Complete three controlled strikes against the training post"}

static func pending() -> bool:
    return bool(GameState.world_flags.get("conduct_pending", false))

static func tier() -> int:
    var count: int = int(GameState.world_flags.get("conduct_total", 0))
    if count >= 6:
        return 3
    if count >= 4:
        return 2
    if count >= 2:
        return 1
    return 0

static func service_active() -> bool:
    return bool(GameState.world_flags.get("conduct_service_active", false))

static func duty_blocked() -> bool:
    return pending() or service_active()

static func access_suspended() -> bool:
    # Unresolved serious violence also locks the main dwelling. A player who
    # cannot pay still has two outdoor tasks and a hearing as a way back.
    return service_active() or (pending() and tier() >= 2)

static func fine_due() -> int:
    match tier():
        3: return 120
        2: return 60
        _: return FINE

static func attitude(person_id: String) -> int:
    var opinions: Dictionary = GameState.world_flags.get("conduct_opinions", {})
    return int(opinions.get(person_id, 50))

static func hits(person_id: String) -> int:
    var records: Dictionary = GameState.world_flags.get("conduct_hits", {})
    return int(records.get(person_id, 0))

static func can_apologize(person_id: String) -> bool:
    var apologies: Dictionary = GameState.world_flags.get("conduct_apologies", {})
    return not duty_blocked() and hits(person_id) > int(apologies.get(person_id, 0))

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

    # This is an audible radius, not a line-of-sight system. Do not pretend
    # that an unrelated resident across the map witnessed the blow.
    var names: Array[String] = []
    var witness_ids: Array[String] = []
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
            witness_ids.append(other_id)

    var total: int = int(flags.get("conduct_total", 0)) + 1
    var was_pending: bool = bool(flags.get("conduct_pending", false))
    flags["conduct_total"] = total
    flags["conduct_hits"] = records
    flags["conduct_opinions"] = opinions
    flags["conduct_witnesses"] = witness_records
    flags["conduct_latest_witnesses"] = witness_ids
    flags["conduct_last_victim"] = str(NAMES.get(person_id, person_id))
    if total >= 2 or person_id == "courtyard_varro" or person_id == "elder_davian":
        flags["conduct_pending"] = true
    if total >= 6:
        flags["conduct_exclusion_review"] = true

    var penalty: int = -mini(current_hits, 3)
    if bool(flags.get("conduct_probation", false)):
        penalty -= 1
    if total >= 6:
        penalty -= 4
    elif total >= 4:
        penalty -= 2
    GameState.change_reputation("Flamen", penalty)

    var notice: String = reaction
    if tier() >= 3 and pending():
        notice += " EXCLUSION REVIEW: monastery access revoked pending Varro's decision."
        # The stable courtyard spawn is the only forced movement in this pass;
        # an indoor offender is escorted outside without generating a guard.
        if source is CharacterBody3D and source.global_position.x < -65.0:
            source.global_position = Vector3(0.0, 1.25, 13.0)
            source.velocity = Vector3.ZERO
            notice += " You are escorted to the outer courtyard."
    elif tier() >= 2 and pending():
        notice += " The dwelling seal is suspended. Report to Varro."
    elif pending() and not was_pending:
        notice += " Varro demands an explanation."
    elif names.size() > 0:
        notice += " %s heard it." % names[0]
    else:
        notice += " They will remember."
    GameState.message_requested.emit(notice)
    GameState.state_changed.emit()

static func resolve_report(method: String) -> bool:
    if not pending():
        return false
    var level: int = tier()
    if method == "service" and level >= 2:
        GameState.world_flags["conduct_pending"] = false
        GameState.world_flags["conduct_service_active"] = true
        GameState.world_flags["conduct_service_tier"] = level
        GameState.world_flags["conduct_service_steps"] = {}
        GameState.world_flags["conduct_practice_hits"] = 0
        GameState.world_flags["conduct_probation"] = true
        GameState.message_requested.emit("Varro assigns supervised restitution. Inspect the training post and review the annex terminal; check J for the full list.")
    elif method == "restitution":
        var cost: int = fine_due()
        if GameState.credits < cost:
            GameState.message_requested.emit("You cannot afford %d credits in restitution." % cost)
            return false
        GameState.add_credits(-cost)
        GameState.world_flags["conduct_pending"] = false
        GameState.world_flags["conduct_service_active"] = false
        GameState.world_flags["conduct_probation"] = level >= 2
        GameState.world_flags["conduct_exclusion_review"] = false
        GameState.message_requested.emit("Varro records %d credits in restitution. Your permanent record remains; serious offenders remain on probation." % cost)
    elif method == "reprimand" and level <= 1:
        GameState.change_reputation("Flamen", -2)
        GameState.world_flags["conduct_probation"] = true
        GameState.world_flags["conduct_pending"] = false
        GameState.message_requested.emit("Varro issues a formal reprimand. Another assault on probation will cost more standing.")
    else:
        return false
    GameState.world_flags["conduct_resolutions"] = int(GameState.world_flags.get("conduct_resolutions", 0)) + 1
    GameState.state_changed.emit()
    return true

static func service_required(task_id: String) -> bool:
    if not service_active():
        return false
    if task_id == "drill":
        return int(GameState.world_flags.get("conduct_service_tier", 2)) >= 3
    return task_id == "post" or task_id == "annex"

static func service_done(task_id: String) -> bool:
    var steps: Dictionary = GameState.world_flags.get("conduct_service_steps", {})
    return bool(steps.get(task_id, false))

static func complete_service_task(task_id: String) -> bool:
    if pending() or not service_required(task_id) or service_done(task_id):
        return false
    if task_id == "drill" and int(GameState.world_flags.get("conduct_practice_hits", 0)) < 3:
        return false
    var steps: Dictionary = GameState.world_flags.get("conduct_service_steps", {}).duplicate(true)
    steps[task_id] = true
    GameState.world_flags["conduct_service_steps"] = steps
    if service_ready():
        GameState.message_requested.emit("Service record complete. Return to Varro to restore your access.")
    else:
        GameState.message_requested.emit("Service recorded: %s." % str(SERVICE_TASKS.get(task_id, task_id)))
    GameState.state_changed.emit()
    return true

static func record_practice_hit() -> void:
    if not service_required("drill") or service_done("drill") or pending():
        return
    var count: int = mini(3, int(GameState.world_flags.get("conduct_practice_hits", 0)) + 1)
    GameState.world_flags["conduct_practice_hits"] = count
    if count >= 3:
        complete_service_task("drill")
    else:
        GameState.message_requested.emit("Controlled training: %d of 3 strikes completed." % count)
        GameState.state_changed.emit()

static func service_ready() -> bool:
    if not service_active():
        return false
    for task_id in ["post", "annex", "drill"]:
        if service_required(task_id) and not service_done(task_id):
            return false
    return true

static func finish_service() -> bool:
    if not service_ready() or pending():
        return false
    GameState.world_flags["conduct_service_active"] = false
    GameState.world_flags["conduct_exclusion_review"] = false
    GameState.world_flags["conduct_probation"] = false
    GameState.world_flags["conduct_service_completed"] = int(GameState.world_flags.get("conduct_service_completed", 0)) + 1
    GameState.change_reputation("Flamen", 2)
    GameState.message_requested.emit("Varro signs the service ledger. Dwelling access and ordinary duties are restored; the assaults remain on record.")
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
    var choices: Array = []
    var line: String
    if tier() >= 3:
        line = "The register now lists repeated assaults, most recently on %s. This is an exclusion review. Your dwelling access and duties are suspended. No more routine reprimands." % last_victim
    elif tier() >= 2:
        line = "Another assault on %s. This is no longer a warning. Your dwelling seal and duties are suspended until restitution is made." % last_victim
    else:
        line = "An assault on %s has been entered in the register. Until we settle it, your monastery duties are suspended." % last_victim
    if tier() >= 2:
        choices.append({"text": "Accept supervised service in the courtyard.", "action": "conduct_service"})
    else:
        choices.append({"text": "Accept a formal reprimand and probation.", "action": "conduct_reprimand"})
    if GameState.credits >= fine_due():
        choices.append({"text": "Pay %d credits in restitution." % fine_due(), "action": "conduct_restitution"})
    choices.append({"text": "I will return later.", "action": "close"})
    return {"speaker": speaker, "text": line, "choices": choices}

static func service_dialogue(speaker: String) -> Dictionary:
    if service_ready():
        return {"speaker": speaker, "text": "I've received the inspection notes. The training post and annex are accounted for. Are you ready to have your access restored?", "choices": [{"text": "Submit my completed service record.", "action": "conduct_finish_service"}, {"text": "Not yet.", "action": "close"}]}
    return {"speaker": speaker, "text": "Your duties remain suspended. Inspect the courtyard training post and read the safety record at Annex Terminal 3. For an exclusion review, also complete three controlled strikes on the post. Check your journal for progress.", "choices": [{"text": "I understand.", "action": "close"}]}

static func temper_text(person_id: String) -> String:
    var score: int = attitude(person_id)
    if score <= 15:
        return "They step away from you and keep an eye on your hands. "
    if score < 45:
        return "They regard you warily. "
    return ""

static func status_text() -> String:
    if pending() and tier() >= 3:
        return "EXCLUSION REVIEW — dwelling seal revoked. Speak to Varro."
    if pending() and tier() >= 2:
        return "RESTRICTED — dwelling seal revoked. Speak to Varro."
    if pending():
        return "Report pending — speak to Preceptor Varro."
    if service_active():
        return "SUPERVISED SERVICE — dwelling and ordinary duties suspended until Varro signs your record."
    if bool(GameState.world_flags.get("conduct_probation", false)):
        return "On probation — further violence carries an extra penalty."
    return "No unresolved report."
