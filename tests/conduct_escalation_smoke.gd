extends Node3D

const MAIN = preload("res://scenes/Main.tscn")
const CONDUCT = preload("res://scripts/conduct_rules.gd")

func _ready() -> void:
    GameState.new_game({"name": "Escalation Test", "species": "Human", "background": "Pilgrim", "answers": []})
    call_deferred("_run_test")

func _run_test() -> void:
    var main = MAIN.instantiate()
    add_child(main)
    for _i in range(8):
        await get_tree().process_frame
    var script: Script = main.get_script()
    if script == null or script.get_base_script() == null or script.get_base_script().resource_path != "res://scripts/world_m2.gd":
        _fail("Escalation requires direct inheritance from stable M2.")
        return
    if main.get_node_or_null("WestBotanicalCloister") != null or main.get_node_or_null("M4GardenLayers") != null:
        _fail("Procedural garden returned.")
        return
    var player = main.get_node_or_null("Player")
    var cael = _find(main, "display_name", "Brother Cael")
    var varro = _find(main, "display_name", "Preceptor Varro")
    var sel = _find(main, "display_name", "Archivist Sel")
    var door = _find(main, "display_name", "Main Monastic Dwelling")
    var post = _find(main, "script_path", "res://scripts/training_dummy.gd")
    var terminal = _find(main, "title", "Annex Terminal 3")
    if player == null or cael == null or varro == null or sel == null or door == null or post == null or terminal == null:
        _fail("Required M2 actors and interactables must remain present.")
        return
    GameState.quests["first_steps"]["state"] = "completed"
    GameState.world_flags["interior_admitted"] = true
    if door._is_locked() or CONDUCT.access_suspended():
        _fail("Clean admission must open dwelling.")
        return
    cael.take_damage(1.0, player)
    cael.take_damage(1.0, player)
    if not CONDUCT.pending() or CONDUCT.tier() != 1:
        _fail("Two assaults must trigger first hearing.")
        return
    varro.choose("conduct_reprimand")
    if CONDUCT.pending() or not GameState.world_flags.get("conduct_probation", false):
        _fail("Reprimand must start probation.")
        return
    sel.take_damage(1.0, player)
    varro.choose("conduct_restitution")
    if CONDUCT.pending() or GameState.credits != 5 or CONDUCT.tier() != 1:
        _fail("Restitution must close second report for 20 credits.")
        return
    cael.take_damage(1.0, player)
    if not CONDUCT.pending() or CONDUCT.tier() != 2 or not CONDUCT.access_suspended() or CONDUCT.fine_due() != 60 or not door._is_locked():
        _fail("Fourth assault must suspend access and escalate fine.")
        return
    var hearing: Dictionary = varro.get_dialogue()
    if not _choice(hearing, "conduct_service") or _choice(hearing, "conduct_reprimand"):
        _fail("Serious hearing must offer service instead of routine reprimand.")
        return
    varro.choose("conduct_service")
    if CONDUCT.pending() or not CONDUCT.service_active() or not CONDUCT.duty_blocked() or not door._is_locked():
        _fail("Service must keep duties and access suspended.")
        return
    if not str(sel.get_dialogue().get("text", "")).contains("service"):
        _fail("Archivist must refuse business while service active.")
        return
    var old_state: String = GameState.quests["missing_copy"]["state"]
    sel.choose("archive_work")
    if GameState.quests["missing_copy"]["state"] != old_state or CONDUCT.finish_service() or CONDUCT.service_ready():
        _fail("Service may not be bypassed by direct dialogue or early completion.")
        return
    post.interact(player)
    post.interact(player)
    if not CONDUCT.service_done("post") or CONDUCT.service_ready():
        _fail("Practice post audit should register once.")
        return
    terminal.interact(player)
    if not CONDUCT.service_done("annex") or not CONDUCT.service_ready():
        _fail("Annex audit should unlock service completion.")
        return
    varro.choose("conduct_finish_service")
    if CONDUCT.duty_blocked() or door._is_locked() or GameState.world_flags.get("conduct_probation", false) or int(GameState.world_flags.get("conduct_service_completed", 0)) != 1:
        _fail("Finished service must restore access and retain one record.")
        return
    cael.take_damage(1.0, player)
    player.global_position = Vector3(-104, 1.25, -13)
    sel.take_damage(1.0, player)
    if CONDUCT.tier() != 3 or not CONDUCT.pending() or CONDUCT.fine_due() != 120:
        _fail("Sixth assault must trigger exclusion review.")
        return
    if player.global_position.distance_to(Vector3(0, 1.25, 13)) > 0.02 or not door._is_locked() or not _choice(varro.get_dialogue(), "conduct_service"):
        _fail("Exclusion must escort player outside while preserving service route.")
        return
    GameState.add_credits(200)
    if not _choice(varro.get_dialogue(), "conduct_restitution"):
        _fail("Sufficiently funded player should have restitution route.")
        return
    varro.choose("conduct_service")
    post.interact(player)
    terminal.interact(player)
    if CONDUCT.service_ready() or not CONDUCT.service_required("drill"):
        _fail("Exclusion additionally requires controlled drill.")
        return
    for _i in range(3):
        post.take_damage(2.0, player)
    if not CONDUCT.service_done("drill") or not CONDUCT.service_ready():
        _fail("Three practice strikes must finish drill.")
        return
    varro.choose("conduct_finish_service")
    if CONDUCT.duty_blocked() or CONDUCT.access_suspended() or CONDUCT.pending() or door._is_locked() or int(GameState.world_flags.get("conduct_service_completed", 0)) != 2:
        _fail("Finished exclusion service must restore access and retain records.")
        return
    var saved: Variant = JSON.parse_string(JSON.stringify(GameState.world_flags))
    if typeof(saved) != TYPE_DICTIONARY:
        _fail("Conduct history failed JSON round-trip.")
        return
    GameState.world_flags = saved
    if CONDUCT.tier() != 3 or CONDUCT.access_suspended() or int(GameState.world_flags.get("conduct_total", 0)) != 6:
        _fail("Load lost conduct history or relocked access.")
        return
    GameState.new_game({"name": "Clean Slate", "species": "Human", "background": "Pilgrim", "answers": []})
    if CONDUCT.pending() or CONDUCT.duty_blocked() or CONDUCT.access_suspended() or CONDUCT.tier() != 0:
        _fail("New game must clear old conduct state.")
        return
    print("Escalation smoke test passed: M2 inheritance, fines, access, hearings, service, escort, drill, persistence, reset.")
    get_tree().quit(0)

func _find(root: Node, key: String, value: String):
    if key == "script_path":
        if root.get_script() != null and root.get_script().resource_path == value:
            return root
    elif root.get(key) != null and str(root.get(key)) == value:
        return root
    for child in root.get_children():
        var found = _find(child, key, value)
        if found != null:
            return found
    return null

func _choice(dialogue: Dictionary, wanted: String) -> bool:
    for choice in dialogue.get("choices", []):
        if str(choice.get("action", "")) == wanted:
            return true
    return false

func _fail(message: String) -> void:
    push_error(message)
    get_tree().quit(1)
