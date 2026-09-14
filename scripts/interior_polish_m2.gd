extends "res://scripts/interior_polish_m1.gd"

const PROP = preload("res://scripts/physics_prop_m2.gd")

func _apply_polish() -> void:
    await super._apply_polish()
    _spawn_loose_props()

func _spawn_loose_props() -> void:
    var interior := get_node_or_null("../MonasteryInterior/IustitiaMonasteryInterior") as Node3D
    var service := get_node_or_null("../MonasteryExpansion/MonasteryServiceWing") as Node3D

    if interior != null:
        _loose_prop(interior, "M2LooseMeditationVolume", Vector3(-16.05, 1.18, -3.72), Vector3(0.28, 0.42, 0.12), Color(0.38, 0.19, 0.11), "Loose Meditation Volume", Vector3(0, 90, 0), 0.55)
        _loose_prop(interior, "M2OpenReferenceBook", Vector3(-11.7, 1.18, 0.25), Vector3(0.46, 0.10, 0.32), Color(0.20, 0.28, 0.22), "Open Reference Book", Vector3(0, 8, 0), 0.60)

    if service != null:
        _loose_prop(service, "M2LooseCommentary", Vector3(24.15, 1.18, -26.0), Vector3(0.28, 0.44, 0.12), Color(0.42, 0.24, 0.12), "Loose Commentary", Vector3(0, -90, 0), 0.55)
        _loose_prop(service, "M2CopiedTreatise", Vector3(19.1, 1.18, -24.0), Vector3(0.44, 0.10, 0.30), Color(0.24, 0.31, 0.23), "Copied Treatise", Vector3(0, -12, 0), 0.60)
        _loose_prop(service, "M2MealSideNotes", Vector3(12.3, 1.05, -38.1), Vector3(0.38, 0.09, 0.28), Color(0.48, 0.38, 0.22), "Meal-side Notes", Vector3(0, 18, 0), 0.45)
        _loose_prop(service, "M2RefectoryCup", Vector3(8.8, 1.02, -38.0), Vector3(0.18, 0.24, 0.18), Color(0.26, 0.25, 0.22), "Stoneware Cup", Vector3(0, -8, 0), 0.85)

func _loose_prop(root: Node3D, node_name: String, pos: Vector3, size: Vector3, color: Color, label: String, rot: Vector3, prop_mass: float) -> void:
    var prop = PROP.new()
    prop.name = node_name
    prop.display_name = label
    prop.prop_size = size
    prop.prop_color = color
    prop.prop_mass = prop_mass
    prop.position = pos
    prop.rotation_degrees = rot
    root.add_child(prop)
