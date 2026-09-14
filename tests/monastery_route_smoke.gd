extends Node3D

const MAIN = preload("res://scenes/Main.tscn")
const INTERIOR_ORIGIN := Vector3(-108.0, 0.0, 0.0)

var query := PhysicsShapeQueryParameters3D.new()

func _ready() -> void:
    GameState.new_game({
        "name": "Route Test",
        "species": "Human",
        "background": "Pilgrim",
        "answers": [],
    })
    call_deferred("_run_test")

func _run_test() -> void:
    var main = MAIN.instantiate()
    add_child(main)

    # Allow procedural geometry and the deferred route repair to complete.
    await get_tree().process_frame
    await get_tree().process_frame
    await get_tree().process_frame
    await get_tree().physics_frame

    var interior = main.get_node_or_null("MonasteryInterior/IustitiaMonasteryInterior")
    if interior == null:
        _fail("Interior root was not created.")
        return
    if interior.get_node_or_null("ServiceArchLintel") == null:
        _fail("The service-wing doorway arch was not created at the first junction.")
        return

    # Player-width clearance probe. Sampling continuously along each route is
    # intentional: the old test skipped directly from x=1.5 to x=2.6 and
    # therefore stepped over the thin blocking wall at x=2.0.
    var probe := SphereShape3D.new()
    probe.radius = 0.42
    query.shape = probe
    query.collision_mask = 1
    query.collide_with_areas = false
    query.collide_with_bodies = true

    var routes: Array = [
        # Meditation court -> first turning square -> service hall -> scriptorium.
        [Vector3(0.0, 1.0, -22.3), Vector3(0.0, 1.0, -26.0), Vector3(10.0, 1.0, -26.0), Vector3(17.0, 1.0, -26.0)],
        # Service hall -> refectory.
        [Vector3(10.0, 1.0, -26.0), Vector3(10.0, 1.0, -38.0)],
        # First turn -> winding council approach.
        [Vector3(0.0, 1.0, -26.0), Vector3(-6.0, 1.0, -26.0), Vector3(-6.0, 1.0, -33.0), Vector3(-1.0, 1.0, -33.0)],
    ]

    for route in routes:
        for i in range(route.size() - 1):
            if not _segment_clear(route[i], route[i + 1]):
                return

    # Explicitly test the exact center of the east doorway that was blocked in
    # the browser build.
    if not _point_clear(Vector3(2.05, 1.0, -26.0), "service-wing doorway center"):
        return

    print("Monastery route smoke test passed: doorway, service wing, refectory, scriptorium, and council approach are continuously clear.")
    get_tree().quit(0)

func _segment_clear(a: Vector3, b: Vector3) -> bool:
    var distance: float = a.distance_to(b)
    var steps: int = maxi(1, int(ceil(distance / 0.12)))
    for i in range(steps + 1):
        var t: float = float(i) / float(steps)
        var p: Vector3 = a.lerp(b, t)
        if not _point_clear(p, "route segment %s -> %s" % [str(a), str(b)]):
            return false
    return true

func _point_clear(local_point: Vector3, context: String) -> bool:
    query.transform = Transform3D(Basis.IDENTITY, INTERIOR_ORIGIN + local_point)
    var hits := get_world_3d().direct_space_state.intersect_shape(query, 32)
    if hits.is_empty():
        return true

    var details: Array[String] = []
    for hit in hits:
        var collider = hit.get("collider")
        if collider == null:
            continue
        var detail := str(collider.name)
        if collider is Node:
            detail += " path=" + str(collider.get_path())
        if collider is Node3D:
            detail += " global=" + str((collider as Node3D).global_position)
            detail += " local=" + str((collider as Node3D).position)
        details.append(detail)
    _fail("Monastery route blocked at %s (%s) by %s" % [str(local_point), context, " | ".join(details)])
    return false

func _fail(message: String) -> void:
    push_error(message)
    get_tree().quit(1)
