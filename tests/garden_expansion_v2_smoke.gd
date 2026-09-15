extends Node3D

const MAIN = preload("res://scenes/Main.tscn")
var query := PhysicsShapeQueryParameters3D.new()

func _ready() -> void:
    GameState.new_game({
        "name": "Garden Expansion V2 Test",
        "species": "Human",
        "background": "Pilgrim",
        "answers": [],
    })
    call_deferred("_run_test")

func _run_test() -> void:
    var main = MAIN.instantiate()
    add_child(main)

    for _i in range(10):
        await get_tree().process_frame
    await get_tree().physics_frame

    # Critical safety rule: the working M3 world must remain the base world.
    var main_script = main.get_script()
    if main_script == null or str(main_script.resource_path) != "res://scripts/world_m3.gd":
        _fail("Garden V2: Main no longer uses the stable world_m3.gd base.")
        return

    var garden = main.get_node_or_null("GardenExpansionV2")
    if garden == null:
        _fail("Garden V2: expansion node is missing.")
        return

    if main.get_node_or_null("WestGardenWall") != null:
        _fail("Garden V2: old solid west-garden wall still blocks the Tamdin portal.")
        return

    for required in [
        "G2WestWallNorth", "G2WestWallSouth", "G2TamdinGateLintel",
        "G2TamdinSoilFloor", "G2TamdinWestWall", "G2TamdinNorthWall", "G2TamdinSouthWall",
        "G2FloraFontisCourt", "G2FloraBloom"
    ]:
        if garden.get_node_or_null(required) == null:
            _fail("Garden V2: required node missing: %s" % required)
            return

    var coral_count := _count_prefix(garden, "G2TamdinCoral_")
    var figure_count := _count_prefix(garden, "G2TamdinFigure_")
    var dormant_count := _count_prefix(garden, "G2FloraDormant_")
    var path_count := _count_prefix(garden, "G2SpiralPath_")
    if coral_count < 15 or figure_count < 3:
        _fail("Garden V2: Tamdin planting incomplete; coral=%d figures=%d." % [coral_count, figure_count])
        return
    if dormant_count < 18:
        _fail("Garden V2: flora-fontis preservation bed incomplete; dormant=%d." % dormant_count)
        return
    if path_count < 7:
        _fail("Garden V2: clockwise spiral pathway is incomplete; strips=%d." % path_count)
        return

    var tree = main.get_node_or_null("EyteliaTree")
    if tree == null or tree.get_node_or_null("G2EyteliaBlossoms") == null:
        _fail("Garden V2: eytelia blossom pass is missing.")
        return

    # New botanical specimens are visual-only. Structural walls/floor have
    # collision, but the plants themselves must never become invisible snags.
    for child in garden.get_children():
        var n := str(child.name)
        if n.begins_with("G2TamdinCoral_") or n.begins_with("G2TamdinFigure_") or n.begins_with("G2FloraDormant_") or n == "G2FloraBloom":
            if _contains_collision_shape(child):
                _fail("Garden V2: botanical specimen unexpectedly contains collision: %s" % n)
                return

    var probe := SphereShape3D.new()
    probe.radius = 0.40
    query.shape = probe
    query.collision_mask = 1
    query.collide_with_areas = false
    query.collide_with_bodies = true

    # Continuous player-width route from the proven M3 cloister, between the
    # existing peristyle columns, through the new portal, and into the Tamdin
    # garden's central gathering space.
    var route: Array[Vector3] = [
        Vector3(-27.8, 1.0, -0.5),
        Vector3(-30.8, 1.0, -0.5),
        Vector3(-33.3, 1.0, -0.5),
        Vector3(-36.8, 1.0, -0.5),
        Vector3(-39.2, 1.0, -0.5),
        Vector3(-40.0, 1.0, -3.0),
        Vector3(-45.1, 1.0, -3.0),
    ]
    for i in range(route.size() - 1):
        if not _segment_clear(route[i], route[i + 1]):
            return

    print("Garden Expansion V2 smoke test passed: stable M3 base retained, Tamdin annex reachable, flora-fontis court present, and plants are non-blocking.")
    get_tree().quit(0)

func _count_prefix(root: Node, prefix: String) -> int:
    var total := 1 if str(root.name).begins_with(prefix) else 0
    for child in root.get_children():
        total += _count_prefix(child, prefix)
    return total

func _contains_collision_shape(root: Node) -> bool:
    if root is CollisionShape3D:
        return true
    for child in root.get_children():
        if _contains_collision_shape(child):
            return true
    return false

func _segment_clear(a: Vector3, b: Vector3) -> bool:
    var distance: float = a.distance_to(b)
    var steps: int = maxi(1, int(ceil(distance / 0.12)))
    for i in range(steps + 1):
        var t: float = float(i) / float(steps)
        var p: Vector3 = a.lerp(b, t)
        if not _point_clear(p, "%s -> %s" % [str(a), str(b)]):
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
    _fail("Garden V2: player-width route blocked at %s (%s) by %s" % [str(point), context, ", ".join(names)])
    return false

func _fail(message: String) -> void:
    push_error(message)
    get_tree().quit(1)
