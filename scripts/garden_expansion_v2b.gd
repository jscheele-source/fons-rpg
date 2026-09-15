extends "res://scripts/garden_expansion_v2.gd"

# Narrow corrective subclass: keep the isolated Garden V2 implementation intact,
# but replace the portal geometry with wall segments that terminate at the piers.
func _open_tamdin_portal(main: Node3D) -> void:
    var old_wall := main.get_node_or_null("WestGardenWall")
    if old_wall != null:
        old_wall.queue_free()

    # Original wall range is z=-4.6..14.0. These segments leave a true opening
    # between the existing peristyle columns at z=-2.2 and z=1.2.
    _box("G2WestWallNorth", Vector3(-33.2, 3.0, -3.45), Vector3(1.1, 6.0, 2.30), STONE_DARK)
    _box("G2WestWallSouth", Vector3(-33.2, 3.0, 7.55), Vector3(1.1, 6.0, 12.90), STONE_DARK)
    _box("G2TamdinGateNorthPier", Vector3(-33.2, 2.15, -2.05), Vector3(1.35, 4.3, 0.55), STONE_PALE)
    _box("G2TamdinGateSouthPier", Vector3(-33.2, 2.15, 1.05), Vector3(1.35, 4.3, 0.55), STONE_PALE)
    _box("G2TamdinGateLintel", Vector3(-33.2, 4.25, -0.5), Vector3(1.35, 0.72, 3.65), STONE_PALE)
    _box("G2TamdinThreshold", Vector3(-34.15, 0.08, -0.5), Vector3(2.6, 0.16, 2.45), STONE_MID)
