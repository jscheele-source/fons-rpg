extends Node3D

func _ready() -> void:
    call_deferred("_move_legacy_boulder")

func _move_legacy_boulder() -> void:
    var world := get_parent()
    if world == null:
        return

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
