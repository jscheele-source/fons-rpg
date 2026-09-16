extends RefCounted
class_name RefinedCaelVisual

# One-character silhouette study. Smooth tapered low-poly primitives replace
# the cuboid torso/boots while keeping the established palette and scale.
static func build(root: Node3D, robe: Color) -> void:
    var model := Node3D.new()
    model.name = "CharacterModel"
    root.add_child(model)
    var fur := Color(0.56, 0.34, 0.16)
    var fur_light := Color(0.72, 0.57, 0.37)
    var leather := robe.darkened(0.28)
    var trim := robe.darkened(0.17)

    # Continuous silhouette: bell-shaped lower robe, tapered torso and cowl.
    _taper(model, Vector3(0.0, 0.57, 0), 0.31, 0.45, 1.08, robe)
    _taper(model, Vector3(0, 1.30, 0), 0.34, 0.28, 0.72, robe.lightened(0.035))
    _oval(model, Vector3(0, 1.56, 0.025), Vector3(0.38, 0.105, 0.215), trim)
    _taper(model, Vector3(0, 0.98, 0), 0.33, 0.34, 0.105, leather)
    _oval(model, Vector3(0, 1.66, 0.02), Vector3(0.14, 0.11, 0.14), fur)

    for side in [-1.0, 1.0]:
        var s: float = side
        _oval(model, Vector3(s * 0.34, 1.50, 0), Vector3(0.18, 0.15, 0.19), robe)
        _taper(model, Vector3(s * 0.44, 1.24, 0), 0.14, 0.19, 0.55, robe, Vector3(0, 0, s * 9.0))
        _taper(model, Vector3(s * 0.48, 0.90, -0.02), 0.115, 0.13, 0.28, trim, Vector3(0, 0, s * 5.0))
        _oval(model, Vector3(s * 0.49, 0.70, -0.025), Vector3(0.115, 0.16, 0.105), fur_light)
        _taper(model, Vector3(s * 0.19, 0.24, 0.02), 0.115, 0.145, 0.41, trim)
        _oval(model, Vector3(s * 0.20, 0.12, -0.12), Vector3(0.15, 0.12, 0.245), leather)

    # A catlike face without box-built snout or squared-off brows.
    _oval(model, Vector3(0, 1.94, 0.02), Vector3(0.31, 0.32, 0.28), fur)
    _oval(model, Vector3(0, 1.77, -0.10), Vector3(0.24, 0.15, 0.20), fur_light)
    for side in [-1.0, 1.0]:
        var s: float = side
        _taper(model, Vector3(s * 0.19, 2.19, 0.045), 0.012, 0.13, 0.30, fur, Vector3(0, 0, -s * 10.0))
        _taper(model, Vector3(s * 0.19, 2.20, -0.015), 0.008, 0.068, 0.20, Color(0.47, 0.27, 0.23), Vector3(0, 0, -s * 10.0))
        _oval(model, Vector3(s * 0.12, 1.98, -0.239), Vector3(0.067, 0.049, 0.031), Color(0.84, 0.67, 0.21))
        _oval(model, Vector3(s * 0.12, 1.98, -0.266), Vector3(0.020, 0.040, 0.012), Color(0.045, 0.034, 0.026))
        _oval(model, Vector3(s * 0.093, 1.835, -0.29), Vector3(0.133, 0.094, 0.11), fur_light)
    _oval(model, Vector3(0, 1.89, -0.38), Vector3(0.075, 0.043, 0.050), Color(0.22, 0.11, 0.085))
    _oval(model, Vector3(0, 1.765, -0.314), Vector3(0.084, 0.016, 0.018), Color(0.29, 0.17, 0.11))

    # Tail gives the Felid a readable back-view silhouette.
    _taper(model, Vector3(0, 0.75, 0.39), 0.065, 0.09, 0.63, fur, Vector3(57, 0, 0))
    _taper(model, Vector3(0, 0.48, 0.71), 0.085, 0.065, 0.49, fur.darkened(0.12), Vector3(78, 0, 0))

static func _taper(root: Node3D, pos: Vector3, top_radius: float, bottom_radius: float, height: float, color: Color, turn: Vector3 = Vector3.ZERO) -> void:
    var mesh := CylinderMesh.new()
    mesh.top_radius = top_radius
    mesh.bottom_radius = bottom_radius
    mesh.height = height
    mesh.radial_segments = 12
    mesh.material = _material(color)
    var visual := MeshInstance3D.new()
    visual.mesh = mesh
    visual.position = pos
    visual.rotation_degrees = turn
    root.add_child(visual)

static func _oval(root: Node3D, pos: Vector3, dimensions: Vector3, color: Color) -> void:
    var mesh := SphereMesh.new()
    mesh.radius = 1.0
    mesh.height = 2.0
    mesh.radial_segments = 12
    mesh.rings = 8
    mesh.material = _material(color)
    var visual := MeshInstance3D.new()
    visual.mesh = mesh
    visual.position = pos
    visual.scale = dimensions
    root.add_child(visual)

static func _material(color: Color) -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.94
    return mat
