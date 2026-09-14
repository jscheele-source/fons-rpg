extends Node3D

# Repairs the older corridor blockout so its side walls stop at junctions
# instead of continuing across the player's turning path.
const STONE_DARK := Color(0.155, 0.145, 0.13)
const STONE_PALE := Color(0.38, 0.34, 0.28)

const BLOCKER_POSITIONS: Array[Vector3] = [
    Vector3(-2.0, 2.25, -23.5),
    Vector3(2.0, 2.25, -23.5),
    Vector3(-3.0, 2.25, -28.0),
    Vector3(-3.0, 2.25, -24.0),
    Vector3(-8.0, 2.25, -29.5),
    Vector3(-4.0, 2.25, -29.5),
]

func _ready() -> void:
    call_deferred("_repair_route")

func _repair_route() -> void:
    var interior := get_node_or_null("../MonasteryInterior/IustitiaMonasteryInterior")
    var service_root := get_node_or_null("../MonasteryExpansion/MonasteryServiceWing")
    if interior == null:
        push_warning("Monastery route repair could not find the interior root.")
        return
    if service_root == null:
        push_warning("Monastery route repair could not find the service-wing root.")
        return

    # Remove the six old council-approach wall slabs by position, not by node
    # name. Godot may rename duplicate programmatically-created sibling nodes,
    # which made the previous name-based repair unreliable.
    var removed_count := 0
    for child in interior.get_children():
        if not child is StaticBody3D:
            continue
        var p: Vector3 = child.position
        for blocker in BLOCKER_POSITIONS:
            if p.distance_to(blocker) < 0.08:
                child.queue_free()
                removed_count += 1
                break

    # The first service-wing corridor was also too long: its north/south side
    # walls began at x=0 and therefore crossed the turning square itself.
    # Remove those two slabs by position and rebuild them only between the
    # doorway and the service hall.
    var service_removed := 0
    for child in service_root.get_children():
        if not child is StaticBody3D:
            continue
        var p: Vector3 = child.position
        if p.distance_to(Vector3(4.0, 2.2, -24.0)) < 0.08 or p.distance_to(Vector3(4.0, 2.2, -28.0)) < 0.08:
            child.queue_free()
            service_removed += 1

    # Rebuild the council-approach walls only between junction boundaries.
    _wall(interior, "CouncilEntryWallL", Vector3(-2.0, 2.25, -22.6), Vector3(0.40, 4.5, 3.15), STONE_DARK)
    _wall(interior, "CouncilEntryWallR", Vector3(2.0, 2.25, -22.6), Vector3(0.40, 4.5, 3.15), STONE_DARK)

    _wall(interior, "CouncilWestWallN", Vector3(-3.0, 2.25, -28.0), Vector3(2.15, 4.5, 0.40), STONE_DARK)
    _wall(interior, "CouncilWestWallS", Vector3(-3.0, 2.25, -24.0), Vector3(2.15, 4.5, 0.40), STONE_DARK)

    _wall(interior, "CouncilNorthWallL", Vector3(-8.0, 2.25, -29.5), Vector3(0.40, 4.5, 3.15), STONE_DARK)
    _wall(interior, "CouncilNorthWallR", Vector3(-4.0, 2.25, -29.5), Vector3(0.40, 4.5, 3.15), STONE_DARK)

    # Short, clean side walls for the service corridor: x=2.2 to x=5.8.
    _wall(service_root, "ServicePassNorthClean", Vector3(4.0, 2.2, -28.0), Vector3(3.6, 4.4, 0.45), STONE_DARK)
    _wall(service_root, "ServicePassSouthClean", Vector3(4.0, 2.2, -24.0), Vector3(3.6, 4.4, 0.45), STONE_DARK)

    # Give the new service wing an unmistakable architectural entrance at
    # the east edge of the first turning square.
    _doorway_z(interior, Vector3(2.05, 0.0, -26.0), 4.0, 3.0, 4.5)

    print("Monastery route repair removed %d council blockers and %d service-corridor blockers." % [removed_count, service_removed])

func _doorway_z(root: Node3D, base: Vector3, total_length: float, opening: float, height: float) -> void:
    var segment: float = (total_length - opening) * 0.5
    var offset: float = opening * 0.5 + segment * 0.5
    _wall(root, "ServiceArchN", base + Vector3(0, height * 0.5, -offset), Vector3(0.38, height, segment), STONE_PALE)
    _wall(root, "ServiceArchS", base + Vector3(0, height * 0.5, offset), Vector3(0.38, height, segment), STONE_PALE)
    var opening_height := 3.25
    var lintel_height: float = height - opening_height
    _wall(root, "ServiceArchLintel", base + Vector3(0, opening_height + lintel_height * 0.5, 0), Vector3(0.38, lintel_height, opening), STONE_PALE)

func _wall(root: Node3D, node_name: String, pos: Vector3, size: Vector3, color: Color) -> void:
    var body := StaticBody3D.new()
    body.name = node_name
    body.position = pos

    var visual := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = 0.95
    mesh.material = material
    visual.mesh = mesh
    body.add_child(visual)

    var shape := BoxShape3D.new()
    shape.size = size
    var collision := CollisionShape3D.new()
    collision.shape = shape
    body.add_child(collision)
    root.add_child(body)
