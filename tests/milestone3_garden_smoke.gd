extends Node3D

const MAIN = preload("res://scenes/Main.tscn")
var query := PhysicsShapeQueryParameters3D.new()

func _ready() -> void:
    GameState.new_game({
        "name": "Garden Milestone Test",
        "species": "Human",
        "background": "Pilgrim",
        "answers": [],
    })
    call_deferred("_run_test")

func _run_test() -> void:
    var main = MAIN.instantiate()
    add_child(main)

    for _i in range(6):
        await get_tree().process_frame
    await get_tree().physics_frame

    if main.get_node_or_null("EyteliaTree") == null:
        _fail("Milestone 3: west cloister did not create its eytelia tree.")
        return
    if main.get_node_or_null("WestGardenFloor") == null:
        _fail("Milestone 3: west cloister floor is missing.")
        return
    if main.get_node_or_null("GardenGateLintel") == null:
        _fail("Milestone 3: framed garden threshold is missing.")
        return
    if main.get_node_or_null("WestWall") != null:
        _fail("Milestone 3: original solid west wall still exists after the garden opening was built.")
        return

    var probe := SphereShape3D.new()
    probe.radius = 0.40
    query.shape = probe
    query.collision_mask = 1
    query.collide_with_areas = false
    query.collide_with_bodies = true

    # Enter from the original courtyard, pass through the new opening, go around
    # the eytelia trunk, then reach the back half of the cloister.
    var route: Array[Vector3] = [
        Vector3(-10.0, 1.0, 4.5),
        Vector3(-14.7, 1.0, 4.5),
        Vector3(-18.0, 1.0, 4.5),
        Vector3(-20.0, 1.0, 8.5),
        Vector3(-28.0, 1.0, 8.5),
        Vector3(-29.0, 1.0, 5.8),
    ]
    for i in range(route.size() - 1):
        if not _segment_clear(route[i], route[i + 1]):
            return

    # The M2 southwest legacy boulder must no longer occupy this garden's edge.
    for child in main.get_children():
        if str(child.name).begins_with("M2RockCollision_") and child is Node3D:
            var p := (child as Node3D).position
            if p.x > -34.0 and p.x < -15.0 and p.z > -5.0 and p.z < 14.5:
                _fail("Milestone 3: a legacy courtyard boulder collision still intrudes into the west cloister at %s." % str(p))
                return

    print("Milestone 3 smoke test passed: compact west botanical cloister exists and is continuously reachable from the courtyard.")
    get_tree().quit(0)

func _segment_clear(a: Vector3, b: Vector3) -> bool:
    var distance: float = a.distance_to(b)
    var steps: int = maxi(1, int(ceil(distance / 0.12)))
    for i in range(steps + 1):
        var t: float = float(i) / float(steps)
        var p: Vector3 = a.lerp(b, t)
        if not _point_clear(p, "garden route %s -> %s" % [str(a), str(b)]):
            return false
    return true

func _point_clear(point: Vector3, context: String) -> bool:
    query.transform = Transform3D(Basis.IDENTITY, point)
    var hits := get_world_3d().direct_space_state.intersect_shape(query, 32)
    if hits.is_empty():
        return true

    var names: Array[String] = []
    for hit in hits:
        var collider = hit.get("collider")
        if collider != null:
            names.append(str(collider.name))
    _fail("Milestone 3: route blocked at %s (%s) by %s" % [str(point), context, ", ".join(names)])
    return false

func _fail(message: String) -> void:
    push_error(message)
    get_tree().quit(1)
