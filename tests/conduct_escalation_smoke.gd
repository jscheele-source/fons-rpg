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
    if str(main.get_script().resource_path) != "res://scripts/world_m2.gd":
        _fail("Escalation changed the M2 world or added garden geometry.")
        return
    if main.get_node_or_null("WestBotanicalCloister") != null or main.get_node_or_null("M4GardenLayers") != null:
        _fail("Escalation reintroduced procedural gardens.")
        return

    var player = main.get_node_or_null("Player")
    var cael = _by_display_name(main, "Brother Cael")
    var varro = _by_display_name(main, "Preceptor Varro")
    var sel = _by_display_name(main, "Archivist Sel")
    var door = _by_display_name(main, "Main Monastic Dwelling")
    var post = _by_script(main, "res://scripts/training_dummy.gd")
    var terminal = _by_title(main, "Annex Terminal 3")
    if player == null or cael == null or varro == null or sel == null or door == null or post == null or terminal == null:
        _fail("Escalation: a required stable M2 actor, door, post or terminal is missing.")
        return

    # Independently unlock the dwelling to prove that conduct, not first_steps,
    # is what later locks this existing door.
    GameState.quests["first_steps"]["state"] = "completed"
    GameState.world_flags["interior_admitted"] = true
    if door._is_locked() or CONDUCT.access_suspended():
        _fail("Escalation: an admitted, clean player cannot enter the dwelling.")
        return

    # Preserve all the original low-level report/reprimand/restitution behavior.
    cael.take_damage(1.0, player)
    cael.take_damage(1.0, player)
    if not CONDUCT.pending() or CONDUCT.tier() != 1:
        _fail("Escalation: original first hearing broken.")
        return
    varro.choose("conduct_reprimand")
    if CONDUCT.pending() or not bool(GameState.world_flags.get("conduct_probation", false)):
        _fail("Escalation: first reprimand did not restore duties with probation.")
        return
    sel.take_damage(1.0, player)
    varro.choose("conduct_restitution")
    if CONDUCT.pending() or int(GameState.credits) != 5 or CONDUCT.tier() != 1:
        _fail("Escalation: second report still requires 20-credit restitution.")
        return

    # The fourth assault changes actual access and requires an escalation path.
    cael.take_damage(1.0, player)
    if not CONDUCT.pending() or CONDUCT.tier() != 2 or not CONDUCT.access_suspended() or CONDUCT.fine_due() != 60:
        _fail("Escalation: fourth assault did not revoke dwelling access or increase the fine.")
        return
    if not door._is_locked():
        _fail("Escalation: main dwelling ignored disciplinary lock.")
        return
    var hearing: Dictionary = varro.get_dialogue()
    if not _has_action(hearing, "conduct_service") or _has_action(hearing, "conduct_reprimand"):
        _fail("Escalation: Varro still allows a routine reprimand for serious repeat violence.")
        return
    varro.choose("conduct_service")
    if CONDUCT.pending() or not CONDUCT.service_active() or not CONDUCT.duty_blocked() or not door._is_locked():
        _fail("Escalation: supervised restitution failed to keep services and access suspended.")
        return
    if str(sel.get_dialogue().get("text", "")).find("service") < 0:
        _fail("Escalation: residents resumed normal quests during supervised restitution.")
        return
    var previous_state: String = str(GameState.quests["missing_copy"]["state"])
    sel.choose("archive_work")
    if str(GameState.quests["missing_copy"]["state"]) != previous_state:
        _fail("Escalation: calling resident.choose directly bypassed the duty lock.")
        return
    if CONDUCT.finish_service() or CONDUCT.service_ready():
        _fail("Escalation: unfinished service was signed off without tasks.")
        return

    post.interact(player)
    post.interact(player)
    if not CONDUCT.service_done("post") or CONDUCT.service_ready():
        _fail("Escalation: training-post audit did not register once, or ended service too early.")
        return
    terminal.interact(player)
    if not CONDUCT.service_done("annex") or not CONDUCT.service_ready():
        _fail("Escalation: annex audit failed to complete two-step service.")
        return
    varro.choose("conduct_finish_service")
    if CONDUCT.duty_blocked() or door._is_locked() or bool(GameState.world_flags.get("conduct_probation", false)):
        _fail("Escalation: completed service did not restore privileges.")
        return
    if int(GameState.world_flags.get("conduct_service_completed", 0)) != 1:
        _fail("Escalation: the service record was not retained.")
        return

    # Further violence, even after restitution, leads to an exclusion review.
    cael.take_damage(1.0, player) # fifth total; report pending
    player.global_position = Vector3(-104, 1.25, -13)
    sel.take_damage(1.0, player) # sixth total; now inside the monastery
    if CONDUCT.tier() != 3 or not CONDUCT.pending() or CONDUCT.fine_due() != 120:
        _fail("Escalation: repeated violence did not trigger the exclusion review.")
        return
    if player.global_position.distance_to(Vector3(0, 1.25, 13)) > 0.02:
        _fail("Escalation: severe indoor assault did not escort player to safe courtyard.")
        return
    if not door._is_locked() or not _has_action(varro.get_dialogue(), "conduct_service"):
        _fail("Escalation: excluded player has no viable non-monetary hearing.")
        return
    GameState.add_credits(200)
    if not _has_action(varro.get_dialogue(), "conduct_restitution"):
        _fail("Escalation: sufficiently funded player lacks higher restitution option.")
        return
    varro.choose("conduct_service")
    post.interact(player)
    terminal.interact(player)
    if CONDUCT.service_ready() or not CONDUCT.service_required("drill"):
        _fail("Escalation: exclusion review requires a three-strike controlled drill.")
        return
    for _i in range(3):
        post.take_damage(2.0, player)
    if not CONDUCT.service_done("drill") or not CONDUCT.service_ready():
        _fail("Escalation: completing three controlled strikes did not finish the drill.")
        return
    varro.choose("conduct_finish_service")
    if CONDUCT.duty_blocked() or CONDUCT.access_suspended() or CONDUCT.pending() or door._is_locked():
        _fail("Escalation: exclusion remediation did not reopen the monastery.")
        return
    if int(GameState.world_flags.get("conduct_service_completed", 0)) != 2:
        _fail("Escalation: previous service completion did not persist.")
        return

    var saved: Variant = JSON.parse_string(JSON.stringify(GameState.world_flags))
    if typeof(saved) != TYPE_DICTIONARY:
        _fail("Escalation: conduct flags failed JSON save round-trip.")
        return
    GameState.world_flags = saved
    if CONDUCT.tier() != 3 or CONDUCT.access_suspended() or int(GameState.world_flags.get("conduct_total", 0)) != 6:
        _fail("Escalation: case history was lost or erroneously relocked on load.")
        return
    GameState.new_game({"name": "Clean Slate", "species": "Human", "background": "Pilgrim", "answers": []})
    if CONDUCT.pending() or CONDUCT.duty_blocked() or CONDUCT.access_suspended() or CONDUCT.tier() != 0:
        _fail("Escalation: old case leaked into a new game.")
        return

    print("Escalation smoke test passed: stable M2, rising fines, locked dwelling, quest protection, two-stage service, exclusion escort, supervised drill, lasting case history and clean new game.")
    get_tree().quit(0)

func _by_display_name(root: Node, wanted: String):
    if root.get("display_name") != null and str(root.get("display_name")) == wanted:
        return root
    for child in root.get_children():
        var result = _by_display_name(child, wanted)
        if result != null:
            return result
    return null

func _by_title(root: Node, wanted: String):
    if root.get("title") != null and str(root.get("title")) == wanted:
        return root
    for child in root.get_children():
        var result = _by_title(child, wanted)
        if result != null:
            return result
    return null

func _by_script(root: Node, wanted: String):
    if root.get_script() != null and str(root.get_script().resource_path) == wanted:
        return root
    for child in root.get_children():
        var result = _by_script(child, wanted)
        if result != null:
            return result
    return null

func _has_action(dialogue: Dictionary, wanted: String) -> bool:
    for choice in dialogue.get("choices", []):
        if str(choice.get("action", "")) == wanted:
            return true
    return false

func _fail(message: String) -> void:
    push_error(message)
    get_tree().quit(1)
