extends Node3D

const MAIN = preload("res://scenes/Main.tscn")

var query := PhysicsShapeQueryParameters3D.new()

func _ready() -> void:
    GameState.new_game({
        "name": "Garden Route Test",
        "species": "Human",
        "background": "Pilgrim",
        "answers": [],
    })
    call_deferred("_run_test")

func _run_test() -> void:
    var main = MAIN.instantiate()
    add_child(main)

    await get_tree().process_frame
    await get_tree().process_frame
    await get_tree().physics_frame

    var garden_tree = main.get_node_or_null("EyteliaTree")
    if garden_tree == null:
        _fail("West garden did not create its eytelia tree.")
        return

    var probe := SphereShape3D.new()
    probe.radius = 0.40
    query.shape = probe
    query.collision_mask = 1
    query.collide_with_areas = false
    query.collide_with_bodies = true

    # Walk from the original courtyard, through the new west opening, and
    # around the eytelia tree into the deeper garden. The samples sit above
    # the floor so only walls/scenery can block the route.
    var route: Array[Vector3] = [
        Vector3(-10.0, 1.0, 4.5),
        Vector3(-14.7, 1.0, 4.5),
        Vector3(-18.0, 1.0, 4.5),
        Vector3(-20.0, 1.0, 8.5),
        Vector3(-28.0, 1.0, 8.5),
    ]

    for i in range(route.size() - 1):
        if not _segment_clear(main, route[i], route[i + 1]):
            return

    print("Garden route smoke test passed: courtyard opening and west garden are physically reachable.")
    get_tree().quit(0)

func _segment_clear(main: Node3D, a: Vector3, b: Vector3) -> bool:
    var distance: float = a.distance_to(b)
    var steps: int = maxi(1, int(ceil(distance / 0.12)))
    for i in range(steps + 1):
        var t: float = float(i) / float(steps)
        var p: Vector3 = a.lerp(b, t)
        if not _point_clear(main, p, "garden route %s -> %s" % [str(a), str(b)]):
            return false
    return true

func _point_clear(_main: Node3D, point: Vector3, context: String) -> bool:
    query.transform = Transform3D(Basis.IDENTITY, point)
    var hits := get_world_3d().direct_space_state.intersect_shape(query, 32)
    if hits.is_empty():
        return true

    var names: Array[String] = []
    for hit in hits:
        var collider = hit.get("collider")
        if collider != null:
            names.append(str(collider.name))
    _fail("Garden route blocked at %s (%s) by %s" % [str(point), context, ", ".join(names)])
    return false

func _fail(message: String) -> void:
    push_error(message)
    get_tree().quit(1)
