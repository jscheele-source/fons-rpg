extends Node3D

const MAIN = preload("res://scenes/Main.tscn")
const CONDUCT = preload("res://scripts/conduct_rules.gd")
const ALERT = preload("res://scripts/conduct_alert.gd")

func _ready() -> void:
    GameState.new_game({"name": "Response Test", "species": "Human", "background": "Pilgrim", "answers": []})
    call_deferred("_run")

func _run() -> void:
    var main = MAIN.instantiate()
    add_child(main)
    for _i in range(8):
        await get_tree().process_frame
    if str(main.get_script().resource_path) != "res://scripts/world_m2.gd" or main.get_node_or_null("WestBotanicalCloister") != null:
        _fail("Response: baseline world changed or garden returned.")
        return
    var player = main.get_node_or_null("Player")
    var varro = _named(main, "Preceptor Varro")
    var cael = _named(main, "Brother Cael")
    var kes = _named(main, "Initiate Kes")
    var sel = _named(main, "Archivist Sel")
    var davian = _named(main, "Elder Davian")
    if player == null or varro == null or cael == null or kes == null or sel == null or davian == null:
        _fail("Response: stable resident or player missing.")
        return
    if ALERT.active():
        _fail("Response: new character began with an active alarm.")
        return

    var varro_home: Vector3 = varro.position
    cael.take_damage(1.0, player)
    if not ALERT.active() or CONDUCT.pending():
        _fail("Response: first assault must raise an immediate alarm without a formal case yet.")
        return
    if not ALERT.involved("courtyard_cael") or not ALERT.involved("courtyard_varro") or not ALERT.involved("courtyard_novice"):
        _fail("Response: victim and nearby witnesses were not marked as involved.")
        return
    if not str(cael.get_dialogue().get("text", "")).contains("Varro"):
        _fail("Response: alerted victim continued ordinary duties.")
        return
    if not _choice(varro.get_dialogue(), "conduct_yield") or not _choice(varro.get_dialogue(), "conduct_defy"):
        _fail("Response: Varro has no immediate compliance or defiance choices.")
        return
    varro._physics_process(0.75)
    if varro.position.z <= varro_home.z + 0.1 or varro.position.distance_to(varro_home) > 2.7:
        _fail("Response: Varro did not move along his bounded courtyard approach.")
        return
    varro.choose("conduct_yield")
    if ALERT.active() or CONDUCT.pending() or int(GameState.world_flags.get("conduct_total", 0)) != 1:
        _fail("Response: compliance failed to end only the immediate alarm, preserving case history.")
        return
    if CONDUCT.attitude("courtyard_cael") >= 50:
        _fail("Response: compliance incorrectly erased the victim's memories.")
        return
    varro._physics_process(2.0)
    if varro.position.distance_to(varro_home) > 0.02:
        _fail("Response: Varro did not return to his original safe anchor.")
        return

    cael.take_damage(1.0, player)
    if not CONDUCT.pending() or not ALERT.active():
        _fail("Response: second assault lost the existing disciplinary hearing.")
        return
    var hearing = varro.get_dialogue()
    if not _choice(hearing, "conduct_reprimand") or not _choice(hearing, "conduct_yield"):
        _fail("Response: alert blocked the existing hearing resolutions.")
        return
    var before_rep: int = int(GameState.factions.get("Flamen", 0))
    varro.choose("conduct_defy")
    if not ALERT.defied() or not CONDUCT.pending() or int(GameState.factions.get("Flamen", 0)) != before_rep - 3:
        _fail("Response: defying Varro did not generate one consequential refusal.")
        return
    varro.choose("conduct_defy")
    if int(GameState.factions.get("Flamen", 0)) != before_rep - 3:
        _fail("Response: a single incident could farm multiple refusal penalties.")
        return
    varro.choose("conduct_reprimand")
    if ALERT.active() or ALERT.defied() or CONDUCT.pending() or not bool(GameState.world_flags.get("conduct_probation", false)):
        _fail("Response: completed hearing left the alarm stuck or broke probation.")
        return

    sel.take_damage(1.0, player)
    if not ALERT.active() or not CONDUCT.pending():
        _fail("Response: interior assaults must raise alerts alongside existing reports.")
        return
    varro.choose("conduct_restitution")
    if ALERT.active() or CONDUCT.pending():
        _fail("Response: restitution did not release the standoff.")
        return
    var saved: Variant = JSON.parse_string(JSON.stringify(GameState.world_flags))
    if typeof(saved) != TYPE_DICTIONARY:
        _fail("Response: alert record is not JSON save-compatible.")
        return
    GameState.world_flags = saved
    if int(GameState.world_flags.get("conduct_defiances", 0)) != 1 or int(GameState.world_flags.get("conduct_compliances", 0)) != 1:
        _fail("Response: compliance or defiance history failed save round-trip.")
        return
    GameState.new_game({"name": "No Alarm", "species": "Human", "background": "Pilgrim", "answers": []})
    if ALERT.active() or ALERT.defied() or int(GameState.world_flags.get("conduct_defiances", 0)) != 0:
        _fail("Response: alerts leaked into a new game.")
        return
    print("Conduct response smoke test passed: baseline, alarm, witness refusal, Varro movement, compliance, defiance, hearing, interior report, save and reset.")
    get_tree().quit(0)

func _named(root: Node, wanted: String):
    if root.get("display_name") != null and str(root.get("display_name")) == wanted:
        return root
    for child in root.get_children():
        var found = _named(child, wanted)
        if found != null:
            return found
    return null

func _choice(dialogue: Dictionary, action: String) -> bool:
    for choice in dialogue.get("choices", []):
        if str(choice.get("action", "")) == action:
            return true
    return false

func _fail(message: String) -> void:
    push_error(message)
    get_tree().quit(1)
