extends Node3D

const PROP = preload("res://scripts/physics_prop.gd")
const INTERIOR_ORIGIN := Vector3(-108.0, 0.0, 0.0)
const WARM := Color(1.0, 0.63, 0.34)

func _ready() -> void:
    call_deferred("_apply_polish")

func _apply_polish() -> void:
    await get_tree().process_frame
    _fix_scriptorium_shelves()
    _reposition_residents()
    _add_interior_lighting()
    _spawn_loose_props()

func _fix_scriptorium_shelves() -> void:
    var service_root := get_node_or_null("../MonasteryExpansion/MonasteryServiceWing")
    if service_root == null:
        return

    for child in service_root.get_children():
        if not child is Node3D:
            continue
        var p: Vector3 = child.position
        if abs(p.x - 24.8) < 0.08 and (abs(p.z + 29.9) < 0.08 or abs(p.z + 26.0) < 0.08 or abs(p.z + 22.1) < 0.08):
            # Shelf fronts face +Z in local space. -90 faces them into the room.
            child.rotation_degrees.y = -90.0

func _reposition_residents() -> void:
    var population := get_node_or_null("../MonasteryPopulation")
    if population == null:
        return

    for child in population.get_children():
        if child.get("display_name") == null:
            continue
        if str(child.get("display_name")) == "Archivist Sel":
            child.position = INTERIOR_ORIGIN + Vector3(22.6, 0.10, -24.6)
            child.rotation_degrees.y = 90.0

func _add_interior_lighting() -> void:
    var interior := get_node_or_null("../MonasteryInterior/IustitiaMonasteryInterior")
    var service := get_node_or_null("../MonasteryExpansion/MonasteryServiceWing")

    if interior != null:
        # Keep the monastery dim, but eliminate the completely black pockets.
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

func _spawn_loose_props() -> void:
    var interior := get_node_or_null("../MonasteryInterior/IustitiaMonasteryInterior")
    var service := get_node_or_null("../MonasteryExpansion/MonasteryServiceWing")

    if interior != null:
        # These are supported by shelf/table geometry until the player knocks them free.
        _loose_book(interior, Vector3(-16.35, 1.20, -3.72), Vector3(0.28, 0.42, 0.12), Color(0.38, 0.19, 0.11), "Loose Meditation Volume", Vector3(0, 90, 0))
        _loose_book(interior, Vector3(-11.7, 1.18, 0.25), Vector3(0.46, 0.10, 0.32), Color(0.20, 0.28, 0.22), "Open Reference Book", Vector3(0, 8, 0))

    if service != null:
        _loose_book(service, Vector3(24.47, 1.21, -26.0), Vector3(0.28, 0.44, 0.12), Color(0.42, 0.24, 0.12), "Loose Commentary", Vector3(0, -90, 0))
        _loose_book(service, Vector3(19.1, 1.18, -24.0), Vector3(0.44, 0.10, 0.30), Color(0.24, 0.31, 0.23), "Copied Treatise", Vector3(0, -12, 0))
        _loose_book(service, Vector3(12.3, 1.05, -38.1), Vector3(0.38, 0.09, 0.28), Color(0.48, 0.38, 0.22), "Meal-side Notes", Vector3(0, 18, 0))

func _loose_book(root: Node3D, pos: Vector3, size: Vector3, color: Color, label: String, rot: Vector3) -> void:
    var prop: RigidBody3D = PROP.new()
    prop.set("display_name", label)
    prop.set("prop_size", size)
    prop.set("prop_color", color)
    prop.set("prop_mass", 0.55)
    prop.position = pos
    prop.rotation_degrees = rot
    root.add_child(prop)

func _soft_light(root: Node3D, pos: Vector3, energy: float, radius: float, color: Color = WARM) -> void:
    var light := OmniLight3D.new()
    light.name = "PolishLight"
    light.position = pos
    light.light_color = color
    light.light_energy = energy
    light.omni_range = radius
    light.shadow_enabled = false
    root.add_child(light)
