extends RefCounted
class_name FlameBeneathState

const KEY_STAGE := "flame_beneath_stage"
const KEY_RESOLUTION := "flame_beneath_resolution"

static func stage() -> int:
    return int(GameState.world_flags.get(KEY_STAGE, 0))

static func started() -> bool:
    return stage() > 0

static func completed() -> bool:
    return str(GameState.world_flags.get(KEY_RESOLUTION, "")) != ""

static func start() -> void:
    if stage() == 0:
        GameState.world_flags[KEY_STAGE] = 1
        GameState.message_requested.emit("Quest started: The Flame Beneath")
        GameState.state_changed.emit()

static func advance(to_stage: int) -> void:
    if completed():
        return
    if to_stage > stage():
        GameState.world_flags[KEY_STAGE] = to_stage
        GameState.state_changed.emit()

static func note_archive_clue() -> void:
    GameState.world_flags["flame_beneath_archive_clue"] = true
    advance(3)
    GameState.add_skill_xp("Lore", 1.25)
    GameState.message_requested.emit("Clue learned: old service plans mark an extinguished third lamp in the east dormitory.")

static func note_doctrine_clue() -> void:
    if bool(GameState.world_flags.get("flame_beneath_doctrine_clue", false)):
        return
    GameState.world_flags["flame_beneath_doctrine_clue"] = true
    GameState.add_skill_xp("Lore", 1.5)
    GameState.message_requested.emit("Doctrine learned: once a Vesper channel destabilizes, the donor may be unable to stop the drain.")
    GameState.state_changed.emit()

static func note_direct_clue() -> void:
    GameState.world_flags["flame_beneath_direct_clue"] = true
    advance(3)

static func reveal_chamber() -> void:
    GameState.world_flags["flame_beneath_chamber_found"] = true
    advance(4)
    if not GameState.discovered_locations.has("Hidden Vesper Chamber"):
        GameState.discovered_locations.append("Hidden Vesper Chamber")
        GameState.message_requested.emit("Location discovered: Hidden Vesper Chamber")

static func mark_evidence() -> void:
    GameState.world_flags["flame_beneath_evidence"] = true
    advance(5)
    GameState.message_requested.emit("You now have direct evidence of a forbidden Vesper rite.")

static func resolve(kind: String) -> void:
    if completed():
        return
    GameState.world_flags[KEY_RESOLUTION] = kind
    GameState.world_flags[KEY_STAGE] = 9
    match kind:
        "rescued":
            GameState.world_flags["flame_beneath_initiate_survived"] = true
            GameState.world_flags["flame_beneath_cell_broken"] = true
            GameState.world_flags["flame_beneath_aftermath_pending"] = true
            GameState.change_reputation("Flamen", 2)
            GameState.add_skill_xp("Flamecraft", 2.0)
        "reported":
            GameState.world_flags["flame_beneath_initiate_survived"] = true
            GameState.world_flags["flame_beneath_cell_expelled"] = true
            GameState.world_flags["flame_beneath_aftermath_pending"] = true
            GameState.change_reputation("Flamen", 3)
            GameState.add_skill_xp("Speechcraft", 1.5)
        "joined":
            GameState.world_flags["flame_beneath_initiate_survived"] = false
            GameState.world_flags["vesper_siphon_learned"] = true
            GameState.world_flags["flame_beneath_secret_kept"] = true
            GameState.world_flags["flame_beneath_aftermath_pending"] = true
            GameState.change_reputation("Flamen", -4)
            GameState.change_reputation("Independent", 2)
            GameState.restore_charge(GameState.max_charge)
    GameState.message_requested.emit("Quest completed: The Flame Beneath")
    GameState.state_changed.emit()

static func can_find_panel() -> bool:
    return bool(GameState.world_flags.get("flame_beneath_archive_clue", false)) or bool(GameState.world_flags.get("flame_beneath_direct_clue", false))

static func knows_channel_risk() -> bool:
    return bool(GameState.world_flags.get("flame_beneath_doctrine_clue", false))

static func objective() -> String:
    if completed():
        var resolution := str(GameState.world_flags.get(KEY_RESOLUTION, ""))
        match resolution:
            "rescued": return "The Flame Beneath — Mara survived. The broken cell still has to be reckoned with."
            "reported": return "The Flame Beneath — Varro has ordered the cell expelled and the chamber sealed."
            "joined": return "The Flame Beneath — you kept the Vespers' secret and learned what their power costs."
        return "The Flame Beneath — resolved: %s." % resolution
    match stage():
        0: return "Something feels unsettled in the novice dormitory."
        1: return "Question the nervous Flamen in the east dormitory."
        2: return "Decode his references in the archive, or press him for a more direct clue."
        3: return "Find the extinguished third lamp in the east dormitory."
        4: return "Enter the hidden chamber and learn what the Vespers intend."
        5: return "Choose: intervene, join the rite, or report the evidence to Varro."
        6: return "Defeat the hostile Vespers and free the initiate."
        _: return "Follow the evidence beneath the monastery."

static func journal_text() -> String:
    if not started() and not completed():
        return ""
    var text := "[u]The Flame Beneath[/u]\n  %s\n" % objective()
    if bool(GameState.world_flags.get("flame_beneath_archive_clue", false)):
        text += "  Archive clue: an extinguished third lamp marks a sealed service recess.\n"
    if bool(GameState.world_flags.get("flame_beneath_doctrine_clue", false)):
        text += "  Restricted doctrine: a donor may lose the ability to stop a Vesper channel once the drain destabilizes.\n"
    if bool(GameState.world_flags.get("flame_beneath_evidence", false)):
        text += "  Evidence: the initiate offered some charge, but the cell intends to drain the entire flame.\n"
    if completed():
        var resolution := str(GameState.world_flags.get(KEY_RESOLUTION, ""))
        if resolution == "rescued":
            text += "  Aftermath: Mara survived; the ritual cell was broken by force.\n"
        elif resolution == "reported":
            text += "  Aftermath: monastery authority moved against the cell.\n"
        elif resolution == "joined":
            text += "  Aftermath: you kept the rite secret and learned Vesper siphoning.\n"
    return text
