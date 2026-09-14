extends Node3D

const INTERIOR_ORIGIN := Vector3(-108.0, 0.0, 0.0)
const STONE_DARK := Color(0.155, 0.145, 0.13)

func _ready() -> void:
    # The monastery and expansion build their geometry procedurally in sibling
    # _ready() calls. Repair the junctions after all of that geometry exists.
    call_deferred("_repair_passages")

func _repair_passages() -> void:
    var interior := get_parent().get_node_or_null("MonasteryInterior/IustitiaMonasteryInterior")
    if interior == null:
        push_error("Monastery layout repair could not find the interior root.")
        return

    # The original corridor helpers extended their side walls through the
    # turning squares. Remove those overlapping wall runs.
    _remove_wall(interior, "CorridorWallL", Vector3(-2.0, 2.25, -23.5))
    _remove_wall(interior, "CorridorWallR", Vector3(2.0, 2.25, -23.5))

    _remove_wall(interior, "CorridorWallN", Vector3(-3.0, 2.25, -28.0))
    _remove_wall(interior, "CorridorWallS", Vector3(-3.0, 2.25, -24.0))

    _remove_wall(interior, "CorridorWallL", Vector3(-8.0, 2.25, -29.5))
    _remove_wall(interior, "CorridorWallR", Vector3(-4.0, 2.25, -29.5))

    # Put the walls back only along the straight runs between junction rooms.
    # This leaves the first square open west toward the council passage and
    # east toward the new service wing.
    _wall("ApproachWest", Vector3(-2.0, 2.25, -22.55), Vector3(0.40, 4.5, 2.9))
    _wall("ApproachEast", Vector3(2.0, 2.25, -22.55), Vector3(0.40, 4.5, 2.9))

    _wall("FirstTurnNorth", Vector3(-3.0, 2.25, -28.0), Vector3(2.05, 4.5, 0.40))
    _wall("FirstTurnSouth", Vector3(-3.0, 2.25, -24.0), Vector3(2.05, 4.5, 0.40))

    _wall("SecondTurnWest", Vector3(-8.0, 2.25, -29.5), Vector3(0.40, 4.5, 3.05))
    _wall("SecondTurnEast", Vector3(-4.0, 2.25, -29.5), Vector3(0.40, 4.5, 3.05))

    print("Monastery layout repair applied: council and service-wing junctions are open.")

func _remove_wall(root: Node, node_name: String, local_position: Vector3) -> void:
    for child in root.get_children():
        if child is StaticBody3D and child.name == node_name:
            var body := child as StaticBody3D
            if body.position.distance_to(local_position) < 0.08:
                body.queue_free()
                return

func _wall(node_name: String, local_position: Vector3, size: Vector3) -> void:
    var body := StaticBody3D.new()
    body.name = node_name
    body.position = INTERIOR_ORIGIN + local_position

    var visual := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    var material := StandardMaterial3D.new()
    material.albedo_color = STONE_DARK
    material.roughness = 0.95
    mesh.material = material
    visual.mesh = mesh
    body.add_child(visual)

    var shape := BoxShape3D.new()
    shape.size = size
    var collision := CollisionShape3D.new()
    collision.shape = shape
    body.add_child(collision)
    add_child(body)
