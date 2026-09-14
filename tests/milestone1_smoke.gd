extends Node3D

const MAIN = preload("res://scenes/Main.tscn")
const INTERIOR_ORIGIN := Vector3(-108.0, 0.0, 0.0)

func _ready() -> void:
    GameState.new_game({
        "name": "Milestone Test",
        "species": "Human",
        "background": "Pilgrim",
        "answers": [],
    })
    call_deferred("_run_test")

func _run_test() -> void:
    var main = MAIN.instantiate()
    add_child(main)

    # Population and polish both initialize deferred; allow all procedural work
    # to settle before checking the final browser-facing scene graph.
    for _i in range(6):
        await get_tree().process_frame

    var service := main.get_node_or_null("MonasteryExpansion/MonasteryServiceWing") as Node3D
    if service == null:
        _fail("Milestone 1: service wing was not created.")
        return

    var east_shelves := 0
    var north_shelf := false
    for child in service.get_children():
        if not child is Node3D:
            continue
        var shelf := child as Node3D
        if shelf.get_node_or_null("ShelfBack") == null:
            continue
        var p := shelf.position
        if abs(p.x - 24.8) < 0.08 and (abs(p.z + 29.9) < 0.08 or abs(p.z + 26.0) < 0.08 or abs(p.z + 22.1) < 0.08):
            east_shelves += 1
            if abs(wrapf(shelf.rotation_degrees.y + 90.0, -180.0, 180.0)) > 0.2:
                _fail("Milestone 1: an east-wall scriptorium shelf still faces the wall at %s (yaw %.2f)." % [str(p), shelf.rotation_degrees.y])
                return
        elif abs(p.x - 20.0) < 0.08 and abs(p.z + 31.0) < 0.08:
            north_shelf = true
            if abs(wrapf(shelf.rotation_degrees.y, -180.0, 180.0)) > 0.2:
                _fail("Milestone 1: north scriptorium shelf has an unexpected yaw %.2f." % shelf.rotation_degrees.y)
                return
    if east_shelves != 3 or not north_shelf:
        _fail("Milestone 1: expected all four scriptorium shelves; found %d east shelves and north=%s." % [east_shelves, str(north_shelf)])
        return

    var population := main.get_node_or_null("MonasteryPopulation") as Node3D
    if population == null:
        _fail("Milestone 1: population root missing.")
        return

    if not _check_resident(population, "ArchivistSel", INTERIOR_ORIGIN + Vector3(22.6, 0.10, -24.6)):
        return
    if not _check_resident(population, "KeeperOru", INTERIOR_ORIGIN + Vector3(4.7, 0.10, -39.0)):
        return
    if not _check_resident(population, "NovicePell", INTERIOR_ORIGIN + Vector3(15.5, 0.10, -39.0)):
        return

    var interior := main.get_node_or_null("MonasteryInterior/IustitiaMonasteryInterior") as Node3D
    if interior == null:
        _fail("Milestone 1: monastery interior root missing.")
        return
    var light_count := _count_named_lights(interior, "M1SoftLight") + _count_named_lights(service, "M1SoftLight")
    if light_count < 11:
        _fail("Milestone 1: supplemental lighting incomplete; expected 11 soft lights, found %d." % light_count)
        return

    var varro = _find_by_display_name(main, "Preceptor Varro")
    if varro == null:
        _fail("Milestone 1: Preceptor Varro not found.")
        return
    var varro_dialogue: Dictionary = varro.get_dialogue()
    if str(varro_dialogue.get("text", "")) != "Name?":
        _fail("Milestone 1: polished courtyard dialogue is not active. Varro said: %s" % str(varro_dialogue.get("text", "")))
        return

    var sel = population.get_node_or_null("ArchivistSel")
    if sel == null:
        _fail("Milestone 1: Archivist Sel missing after placement pass.")
        return
    var sel_dialogue: Dictionary = sel.get_dialogue()
    if not str(sel_dialogue.get("text", "")).begins_with("Sel finishes a line"):
        _fail("Milestone 1: polished service-wing dialogue is not active.")
        return

    print("Milestone 1 smoke test passed: shelves face inward, residents occupy safe anchors, lighting is present, and polished dialogue is active.")
    get_tree().quit(0)

func _check_resident(population: Node3D, node_name: String, expected: Vector3) -> bool:
    var resident := population.get_node_or_null(node_name) as Node3D
    if resident == null:
        _fail("Milestone 1: missing resident node %s." % node_name)
        return false
    if resident.global_position.distance_to(expected) > 0.08:
        _fail("Milestone 1: %s is not at its safe anchor. Expected %s, found %s." % [node_name, str(expected), str(resident.global_position)])
        return false
    return true

func _count_named_lights(root: Node, wanted_name: String) -> int:
    var count := 0
    for child in root.get_children():
        if child is OmniLight3D and str(child.name).begins_with(wanted_name):
            count += 1
        count += _count_named_lights(child, wanted_name)
    return count

func _find_by_display_name(root: Node, wanted: String):
    if root.get("display_name") != null and str(root.get("display_name")) == wanted:
        return root
    for child in root.get_children():
        var found = _find_by_display_name(child, wanted)
        if found != null:
            return found
    return null

func _fail(message: String) -> void:
    push_error(message)
    get_tree().quit(1)
