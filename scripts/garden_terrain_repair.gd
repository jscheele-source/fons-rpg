extends Node3D

func _ready() -> void:
    call_deferred("_repair_expanded_garden_terrain")

func _repair_expanded_garden_terrain() -> void:
    var world := get_parent()
    if world == null:
        return

    _move_legacy_boulder(world)
    _move_legacy_monastery_mass(world)

func _move_legacy_boulder(world: Node) -> void:
    # This boulder was originally distant scenery at (-25, 0, 16). The expanded
    # botanical cloister now occupies that ground, so preserve the silhouette by
    # moving both its mesh and matching collision body beyond the south wall.
    var old_center := Vector3(-25.0, 2.475, 16.0)
    var new_center := Vector3(-27.5, 2.475, 23.0)

    for child in world.get_children():
        if not child is Node3D:
            continue
        var node := child as Node3D
        if node.position.distance_to(old_center) > 0.20:
            continue
        # Duplicate RockCollision nodes are auto-renamed by Godot, so position
        # is the reliable identifier for this specific legacy rock pair.
        if node is MeshInstance3D or node is StaticBody3D:
            node.position = new_center

func _move_legacy_monastery_mass(world: Node) -> void:
    var visual_pass := world.get_node_or_null("VisualWorldPass")
    if visual_pass == null:
        return

    # The old skyline put a large visual building at (-37, 4, 10), with a
    # matching collision box, and a tower just behind it. That was safely
    # non-playable before the garden expansion. Move the whole skyline cluster
    # beyond the new west wall instead of forcing the garden paths around it.
    _move_children_near(visual_pass, Vector3(-37.0, 4.0, 10.0), Vector3(-65.0, 5.0, 10.0), 0.25)
    _move_children_near(visual_pass, Vector3(-39.0, 11.0, 10.0), Vector3(-67.0, 12.0, 10.0), 0.25)

func _move_children_near(parent: Node, old_pos: Vector3, new_pos: Vector3, tolerance: float) -> void:
    for child in parent.get_children():
        if not child is Node3D:
            continue
        var node := child as Node3D
        if node.position.distance_to(old_pos) <= tolerance:
            node.position = new_pos
