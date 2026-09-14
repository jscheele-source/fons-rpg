extends Node3D

const MAIN = preload("res://scenes/Main.tscn")
const INTERIOR_ORIGIN := Vector3(-108.0, 0.0, 0.0)

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

    # Allow procedural geometry and the deferred layout repair to complete.
    await get_tree().process_frame
    await get_tree().process_frame
    await get_tree().physics_frame

    var sphere := SphereShape3D.new()
    sphere.radius = 0.28
    var query := PhysicsShapeQueryParameters3D.new()
    query.shape = sphere
    query.collision_mask = 1
    query.collide_with_areas = false
    query.collide_with_bodies = true

    var route_points: Array[Vector3] = [
        # Meditation court into the first junction.
        Vector3(0.0, 1.0, -22.5),
        Vector3(0.0, 1.0, -26.0),

        # East branch into the service hall and scriptorium.
        Vector3(1.5, 1.0, -26.0),
        Vector3(2.6, 1.0, -26.0),
        Vector3(4.0, 1.0, -26.0),
        Vector3(5.6, 1.0, -26.0),
        Vector3(6.5, 1.0, -26.0),
        Vector3(10.0, 1.0, -26.0),
        Vector3(13.2, 1.0, -26.0),
        Vector3(14.7, 1.0, -26.0),
        Vector3(17.0, 1.0, -26.0),

        # North from the service hall into the refectory.
        Vector3(10.0, 1.0, -29.0),
        Vector3(10.0, 1.0, -30.5),
        Vector3(10.0, 1.0, -32.5),
        Vector3(10.0, 1.0, -34.5),
        Vector3(10.0, 1.0, -38.0),

        # West/south winding route toward the sealed council chamber.
        Vector3(-1.5, 1.0, -26.0),
        Vector3(-2.6, 1.0, -26.0),
        Vector3(-3.5, 1.0, -26.0),
        Vector3(-5.0, 1.0, -26.0),
        Vector3(-6.0, 1.0, -26.0),
        Vector3(-6.0, 1.0, -28.5),
        Vector3(-6.0, 1.0, -30.0),
        Vector3(-6.0, 1.0, -31.8),
        Vector3(-6.0, 1.0, -33.0),
        Vector3(-4.5, 1.0, -33.0),
        Vector3(-3.0, 1.0, -33.0),
        Vector3(-1.0, 1.0, -33.0),
    ]

    for local_point in route_points:
        query.transform = Transform3D(Basis.IDENTITY, INTERIOR_ORIGIN + local_point)
        var hits := get_world_3d().direct_space_state.intersect_shape(query, 16)
        if not hits.is_empty():
            var names: Array[String] = []
            for hit in hits:
                var collider = hit.get("collider")
                if collider != null:
                    names.append(str(collider.name))
            push_error("Monastery route blocked at %s by %s" % [str(local_point), ", ".join(names)])
            get_tree().quit(1)
            return

    print("Monastery route smoke test passed: service wing and council approach are physically reachable.")
    get_tree().quit(0)
