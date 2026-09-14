extends Node3D

const INTERIOR_ORIGIN := Vector3(-108.0, 0.0, 0.0)
const WARM := Color(1.0, 0.63, 0.34)

func _ready() -> void:
    call_deferred("_apply_polish")

func _apply_polish() -> void:
    # Let the procedural monastery, service wing, and population finish first.
    await get_tree().process_frame
    await get_tree().process_frame
    _fix_scriptorium_shelves()
    _reposition_residents()
    _add_interior_lighting()

func _fix_scriptorium_shelves() -> void:
    var service_root := get_node_or_null("../MonasteryExpansion/MonasteryServiceWing")
    if service_root == null:
        return

    # Shelf fronts are local +Z. The three shelves on the east wall must face
    # west into the scriptorium; the north shelf already faces south correctly.
    for child in service_root.get_children():
        if not child is Node3D:
            continue
        var shelf := child as Node3D
        if shelf.get_node_or_null("ShelfBack") == null:
            continue
        var p: Vector3 = shelf.position
        if abs(p.x - 24.8) < 0.08 and (abs(p.z + 29.9) < 0.08 or abs(p.z + 26.0) < 0.08 or abs(p.z + 22.1) < 0.08):
            shelf.rotation_degrees.y = -90.0
        elif abs(p.x - 20.0) < 0.08 and abs(p.z + 31.0) < 0.08:
            shelf.rotation_degrees.y = 0.0

func _reposition_residents() -> void:
    var population := get_node_or_null("../MonasteryPopulation")
    if population == null:
        return

    # These are explicit standing anchors in open floor space. Keeping this
    # safety pass separate from the population builder makes accidental future
    # furniture changes less likely to leave a resident inside a table.
    for child in population.get_children():
        if not child is Node3D or child.get("display_name") == null:
            continue
        var resident := child as Node3D
        match str(resident.get("display_name")):
            "Archivist Sel":
                resident.position = INTERIOR_ORIGIN + Vector3(22.6, 0.10, -24.6)
                resident.rotation_degrees.y = 90.0
            "Keeper Oru":
                resident.position = INTERIOR_ORIGIN + Vector3(4.7, 0.10, -39.0)
                resident.rotation_degrees.y = 90.0
            "Novice Pell":
                resident.position = INTERIOR_ORIGIN + Vector3(15.5, 0.10, -39.0)
                resident.rotation_degrees.y = -90.0

func _add_interior_lighting() -> void:
    var interior := get_node_or_null("../MonasteryInterior/IustitiaMonasteryInterior")
    var service := get_node_or_null("../MonasteryExpansion/MonasteryServiceWing")

    if interior != null:
        # Add small pools of light rather than raising global exposure. The
        # monastery should remain dim; these only eliminate truly black pockets.
        _soft_light(interior, Vector3(-15.5, 3.1, -4.2), 0.42, 5.4)
        _soft_light(interior, Vector3(-15.5, 3.1, 4.2), 0.42, 5.4)
        _soft_light(interior, Vector3(13.1, 2.9, -5.4), 0.45, 4.8)
        _soft_light(interior, Vector3(13.1, 2.9, 0.0), 0.42, 4.8)
        _soft_light(interior, Vector3(13.1, 2.9, 5.4), 0.45, 4.8)
        _soft_light(interior, Vector3(4.6, 2.8, -15.0), 0.35, 4.8)
        _soft_light(interior, Vector3(0.0, 2.8, -25.8), 0.30, 4.0, Color(0.76, 0.42, 0.22))
        _soft_light(interior, Vector3(-5.8, 2.8, -33.0), 0.28, 4.0, Color(0.70, 0.36, 0.18))

    if service != null:
        _soft_light(service, Vector3(3.8, 2.8, -26.0), 0.45, 5.0)
        _soft_light(service, Vector3(19.5, 3.0, -31.0), 0.38, 5.2)
        _soft_light(service, Vector3(10.0, 2.8, -33.0), 0.40, 4.7)

func _soft_light(root: Node3D, pos: Vector3, energy: float, radius: float, color: Color = WARM) -> void:
    var light := OmniLight3D.new()
    light.name = "M1SoftLight"
    light.position = pos
    light.light_color = color
    light.light_energy = energy
    light.omni_range = radius
    light.shadow_enabled = false
    root.add_child(light)
