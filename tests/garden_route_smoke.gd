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

    for required in ["EyteliaTree", "TamdinGarden", "FloraFontisCourt", "AlienBotanicalCloister"]:
        if main.get_node_or_null(required) == null:
            _fail("Rebuilt garden is missing required section: %s" % required)
            return

    var probe := SphereShape3D.new()
    probe.radius = 0.40
    query.shape = probe
    query.collision_mask = 1
    query.collide_with_areas = false
    query.collide_with_bodies = true

    var routes: Array = [
        # Original courtyard through the broad west gate to the central fork.
        [Vector3(-10.0, 1.0, 4.65), Vector3(-14.7, 1.0, 4.65), Vector3(-20.0, 1.0, 4.65), Vector3(-27.5, 1.0, 4.65)],
        # North branch toward the flora-fontis court.
        [Vector3(-27.5, 1.0, 4.65), Vector3(-27.5, 1.0, -2.65), Vector3(-36.0, 1.0, -2.65), Vector3(-43.0, 1.0, -2.65)],
        # South branch toward the eytelia and pampin cloister.
        [Vector3(-27.5, 1.0, 4.65), Vector3(-27.5, 1.0, 11.15), Vector3(-34.0, 1.0, 11.15), Vector3(-37.0, 1.0, 11.15)],
        # Deep west branch into the Tamdin spiral.
        [Vector3(-27.5, 1.0, 4.65), Vector3(-38.0, 1.0, 4.65), Vector3(-44.0, 1.0, 4.65), Vector3(-50.0, 1.0, 4.65)],
    ]

    for route in routes:
        for i in range(route.size() - 1):
            if not _segment_clear(main, route[i], route[i + 1]):
                return

    print("Garden route smoke test passed: gate, flora court, eytelia cloister, and Tamdin garden are physically reachable.")
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
