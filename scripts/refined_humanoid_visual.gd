extends RefCounted
class_name RefinedHumanoidVisual

static func build(root: Node3D, robe: Color, skin: Color = Color(0.58, 0.43, 0.33)) -> void:
    var model := Node3D.new()
    model.name = "CharacterModel"
    root.add_child(model)
    var trim := robe.darkened(0.18)
    var leather := robe.darkened(0.30)
    var skin_light := skin.lightened(0.12)

    _taper(model, Vector3(0, 0.57, 0), 0.30, 0.43, 1.08, robe)
    _taper(model, Vector3(0, 1.31, 0), 0.34, 0.27, 0.72, robe.lightened(0.035))
    _oval(model, Vector3(0, 1.57, 0.02), Vector3(0.36, 0.10, 0.20), trim)
    _taper(model, Vector3(0, 0.98, 0), 0.32, 0.34, 0.10, leather)

    for side in [-1.0, 1.0]:
        var s: float = side
        _oval(model, Vector3(s * 0.34, 1.50, 0), Vector3(0.17, 0.15, 0.18), robe)
        _taper(model, Vector3(s * 0.44, 1.24, 0), 0.13, 0.18, 0.55, robe, Vector3(0, 0, s * 8.0))
        _taper(model, Vector3(s * 0.48, 0.90, -0.01), 0.10, 0.12, 0.27, trim, Vector3(0, 0, s * 4.0))
        _oval(model, Vector3(s * 0.49, 0.71, -0.03), Vector3(0.10, 0.15, 0.10), skin_light)
        _taper(model, Vector3(s * 0.19, 0.25, 0.02), 0.11, 0.14, 0.42, trim)
        _oval(model, Vector3(s * 0.20, 0.12, -0.12), Vector3(0.14, 0.11, 0.23), leather)

    _taper(model, Vector3(0, 1.69, 0), 0.12, 0.13, 0.16, skin)
    _oval(model, Vector3(0, 1.96, -0.01), Vector3(0.28, 0.32, 0.25), skin)
    _oval(model, Vector3(0, 1.84, -0.23), Vector3(0.19, 0.10, 0.08), skin_light)
    for side in [-1.0, 1.0]:
        var s: float = side
        _oval(model, Vector3(s * 0.10, 1.99, -0.235), Vector3(0.046, 0.035, 0.018), Color(0.13, 0.11, 0.08))
        _oval(model, Vector3(s * 0.27, 1.97, 0), Vector3(0.035, 0.085, 0.045), skin)
    _oval(model, Vector3(0, 1.79, -0.284), Vector3(0.07, 0.018, 0.014), skin.darkened(0.32))

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
