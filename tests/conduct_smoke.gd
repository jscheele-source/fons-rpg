extends Node3D

const MAIN = preload("res://scenes/Main.tscn")
const CONDUCT = preload("res://scripts/conduct_rules.gd")

func _ready() -> void:
    GameState.new_game({"name": "Conduct Test", "species": "Human", "background": "Pilgrim", "answers": []})
    call_deferred("_run_test")

func _run_test() -> void:
    var main = MAIN.instantiate()
    add_child(main)
    for _i in range(7):
        await get_tree().process_frame

    if str(main.get_script().resource_path) != "res://scripts/world_m2.gd":
        _fail("Conduct: stable M2 world was replaced.")
        return
    if main.get_node_or_null("WestBotanicalCloister") != null or main.get_node_or_null("M4GardenLayers") != null:
        _fail("Conduct: garden geometry was reintroduced.")
        return

    var player = main.get_node_or_null("Player")
    var varro = _find_by_name(main, "Preceptor Varro")
    var cael = _find_by_name(main, "Brother Cael")
    var sel = main.get_node_or_null("MonasteryPopulation/ArchivistSel")
    var pell = main.get_node_or_null("MonasteryPopulation/NovicePell")
    var davian = _find_by_name(main, "Elder Davian")
    if player == null or varro == null or cael == null or sel == null or pell == null or davian == null:
        _fail("Conduct: one of the stable NPCs is missing.")
        return
    for actor in [varro, cael, sel, pell, davian]:
        if not actor.is_in_group("conduct_witnesses") or not actor.has_method("take_damage"):
            _fail("Conduct: actor is missing witness/hit behavior: %s" % str(actor.name))
            return

    var original_rep: int = int(GameState.factions.get("Flamen", 0))
    cael.take_damage(7.0, player)
    if CONDUCT.hits("courtyard_cael") != 1 or int(GameState.factions["Flamen"]) != original_rep - 1:
        _fail("Conduct: first assault count or reputation penalty is incorrect.")
        return
    if CONDUCT.attitude("courtyard_cael") != 25 or CONDUCT.attitude("courtyard_varro") >= 50:
        _fail("Conduct: victim or nearby witness failed to change disposition.")
        return
    if int(GameState.world_flags.get("conduct_witnesses", {}).get("courtyard_varro", 0)) < 1:
        _fail("Conduct: nearby Varro did not witness Cael's assault.")
        return
    if CONDUCT.pending():
        _fail("Conduct: a single non-authority assault should not lock duties yet.")
        return
    if not CONDUCT.can_apologize("courtyard_cael"):
        _fail("Conduct: an apology should be available after the first assault.")
        return

    cael.take_damage(7.0, player)
    if not CONDUCT.pending() or int(GameState.factions["Flamen"]) != original_rep - 3:
        _fail("Conduct: repeated assault failed to trigger a report and escalating penalty.")
        return
    var refusal: Dictionary = sel.get_dialogue()
    if str(refusal.get("text", "")).find("Varro") < 0:
        _fail("Conduct: monastery NPCs do not suspend duties while a report is pending.")
        return
    var original_state: String = str(GameState.quests["missing_copy"]["state"])
    sel.choose("archive_work")
    if str(GameState.quests["missing_copy"]["state"]) != original_state:
        _fail("Conduct: a direct dialogue action bypassed a disciplinary lock.")
        return
    var hearing: Dictionary = varro.get_dialogue()
    if not _has_action(hearing, "conduct_reprimand") or not _has_action(hearing, "conduct_restitution"):
        _fail("Conduct: Varro does not offer a reachable hearing with both resolutions.")
        return

    var before_reprimand: int = int(GameState.factions["Flamen"])
    varro.choose("conduct_reprimand")
    if CONDUCT.pending() or not bool(GameState.world_flags.get("conduct_probation", false)):
        _fail("Conduct: reprimand did not end the report and start probation.")
        return
    if int(GameState.factions["Flamen"]) != before_reprimand - 2:
        _fail("Conduct: reprimand penalty missing.")
        return
    var attitude_before: int = CONDUCT.attitude("courtyard_cael")
    cael.choose("conduct_apologize")
    if CONDUCT.attitude("courtyard_cael") != attitude_before + 12:
        _fail("Conduct: apology did not partially restore personal trust.")
        return
    cael.choose("conduct_apologize")
    if CONDUCT.attitude("courtyard_cael") != attitude_before + 12:
        _fail("Conduct: apology could be farmed repeatedly for free trust.")
        return

    var before_probation_hit: int = int(GameState.factions["Flamen"])
    pell.take_damage(7.0, player)
    if not CONDUCT.pending() or CONDUCT.hits("resident_sargasson_novice") != 1:
        _fail("Conduct: an indoor assault on probation did not generate a new report.")
        return
    if int(GameState.factions["Flamen"]) != before_probation_hit - 2:
        _fail("Conduct: probation did not increase the next assault penalty.")
        return
    var original_credits: int = GameState.credits
    varro.choose("conduct_restitution")
    if CONDUCT.pending() or bool(GameState.world_flags.get("conduct_probation", false)) or GameState.credits != original_credits - 20:
        _fail("Conduct: restitution resolution did not charge correctly and close the report.")
        return

    var roundtrip = JSON.parse_string(JSON.stringify(GameState.world_flags))
    if typeof(roundtrip) != TYPE_DICTIONARY or int(roundtrip.get("conduct_total", 0)) != 3:
        _fail("Conduct: saved flags are not JSON round-trip compatible.")
        return
    GameState.world_flags = roundtrip
    if CONDUCT.hits("courtyard_cael") != 2 or CONDUCT.attitude("courtyard_cael") != attitude_before + 12:
        _fail("Conduct: NPC memories did not survive flags serialization.")
        return
    GameState.new_game({"name": "Clean Record", "species": "Human", "background": "Pilgrim", "answers": []})
    if CONDUCT.pending() or CONDUCT.hits("courtyard_cael") != 0 or CONDUCT.attitude("courtyard_cael") != 50:
        _fail("Conduct: starting a new game did not clear the old character's record.")
        return

    print("Conduct smoke test passed: stable M2 world, witnesses, escalating reports, duty lock, hearing, apologies, probation, restitution, save flags and new-game reset.")
    get_tree().quit(0)

func _find_by_name(root: Node, wanted: String):
    if root.get("display_name") != null and str(root.get("display_name")) == wanted:
        return root
    for child in root.get_children():
        var found = _find_by_name(child, wanted)
        if found != null:
            return found
    return null

func _has_action(dialogue: Dictionary, wanted: String) -> bool:
    for choice in dialogue.get("choices", []):
        if str(choice.get("action", "")) == wanted:
            return true
    return false

func _fail(message: String) -> void:
    push_error(message)
    get_tree().quit(1)
