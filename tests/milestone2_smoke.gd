extends Node3D

const MAIN = preload("res://scenes/Main.tscn")

func _ready() -> void:
    GameState.new_game({
        "name": "Milestone Two Test",
        "species": "Human",
        "background": "Pilgrim",
        "answers": [],
    })
    call_deferred("_run_test")

func _run_test() -> void:
    var main = MAIN.instantiate()
    add_child(main)

    for _i in range(8):
        await get_tree().process_frame
    await get_tree().physics_frame

    var rock_collisions := 0
    var monolith_collisions := 0
    for child in main.get_children():
        if str(child.name).begins_with("M2RockCollision_"):
            rock_collisions += 1
            if child.get_node_or_null("CollisionShape3D") == null:
                _fail("Milestone 2: rock collision body has no shape: %s" % str(child.name))
                return
        elif str(child.name).begins_with("M2MonolithCollision_"):
            monolith_collisions += 1
            if child.get_node_or_null("CollisionShape3D") == null:
                _fail("Milestone 2: monolith collision body has no shape: %s" % str(child.name))
                return
    if rock_collisions != 4 or monolith_collisions != 4:
        _fail("Milestone 2: expected 4 rock and 4 monolith collision bodies; found %d and %d." % [rock_collisions, monolith_collisions])
        return

    var interior := main.get_node_or_null("MonasteryInterior/IustitiaMonasteryInterior") as Node3D
    var service := main.get_node_or_null("MonasteryExpansion/MonasteryServiceWing") as Node3D
    if interior == null or service == null:
        _fail("Milestone 2: interior roots missing.")
        return

    var props: Array[Node] = []
    _collect_m2_props(interior, props)
    _collect_m2_props(service, props)
    if props.size() < 6:
        _fail("Milestone 2: expected at least 6 loose physics props, found %d." % props.size())
        return

    var player := main.get_node_or_null("Player") as Node3D
    if player == null:
        _fail("Milestone 2: player missing.")
        return

    var prop = props[0]
    if not prop is RigidBody3D or not prop.has_method("take_damage"):
        _fail("Milestone 2: loose prop is not a reactive RigidBody3D.")
        return
    if not bool(prop.freeze):
        _fail("Milestone 2: loose prop should begin frozen in place until struck.")
        return
    prop.take_damage(8.0, player)
    if bool(prop.freeze):
        _fail("Milestone 2: striking a loose prop did not release it into physics.")
        return

    var varro = _find_by_display_name(main, "Preceptor Varro")
    if varro == null or not varro.has_method("take_damage"):
        _fail("Milestone 2: courtyard NPC hit reaction is not active.")
        return
    var rep_before := int(GameState.factions.get("Flamen", 0))
    varro.take_damage(1.0, player)
    if int(GameState.world_flags.get("npc_hit_varro", 0)) != 1:
        _fail("Milestone 2: Varro hit reaction did not record the assault.")
        return
    if int(GameState.factions.get("Flamen", 0)) != rep_before - 1:
        _fail("Milestone 2: first NPC assault should cost exactly 1 Flamen reputation.")
        return

    var sel = main.get_node_or_null("MonasteryPopulation/ArchivistSel")
    if sel == null or not sel.has_method("take_damage"):
        _fail("Milestone 2: interior resident hit reaction is not active.")
        return

    print("Milestone 2 smoke test passed: scenery collision, NPC reactions, resident reactions, and loose physics props are active.")
    get_tree().quit(0)

func _collect_m2_props(root: Node, out: Array[Node]) -> void:
    for child in root.get_children():
        if str(child.name).begins_with("M2") and child is RigidBody3D:
            out.append(child)
        _collect_m2_props(child, out)

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
