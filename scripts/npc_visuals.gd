extends RefCounted
class_name NPCVisuals

static func build(root: Node3D, species: String, robe_color: Color, role: String = "") -> void:
    var model := Node3D.new()
    model.name = "CharacterModel"
    root.add_child(model)

    match species:
        "Felid":
            _build_felid(model, robe_color)
        "Conglomerate":
            _build_conglomerate(model, robe_color)
        "Glauxi":
            _build_glauxi(model, robe_color)
        _:
            _build_human(model, robe_color, role)

static func _build_human(root: Node3D, robe: Color, role: String) -> void:
    var skin := Color(0.55, 0.42, 0.32)
    if role == "davian":
        skin = Color(0.29, 0.20, 0.15)
    var leather := robe.darkened(0.27)
    var cloth_dark := robe.darkened(0.18)

    _skirt(root, Vector3(0, 0.58, 0), 0.35, 0.47, 0.96, robe)
    _box(root, Vector3(0, 1.25, 0), Vector3(0.66, 0.70, 0.34), robe.lightened(0.025))
    _box(root, Vector3(0, 0.96, -0.01), Vector3(0.72, 0.10, 0.38), leather)
    _box(root, Vector3(0, 1.55, 0.03), Vector3(0.78, 0.13, 0.38), cloth_dark)

    _limb(root, Vector3(-0.43, 1.29, 0), 0.14, 0.58, robe, Vector3(0, 0, -7))
    _limb(root, Vector3(0.43, 1.29, 0), 0.14, 0.58, robe, Vector3(0, 0, 7))
    _limb(root, Vector3(-0.47, 0.86, -0.01), 0.12, 0.50, cloth_dark, Vector3(0, 0, -3))
    _limb(root, Vector3(0.47, 0.86, -0.01), 0.12, 0.50, cloth_dark, Vector3(0, 0, 3))
    _sphere(root, Vector3(-0.48, 0.57, -0.02), Vector3(0.13, 0.15, 0.12), skin)
    _sphere(root, Vector3(0.48, 0.57, -0.02), Vector3(0.13, 0.15, 0.12), skin)

    _box(root, Vector3(-0.21, 0.12, -0.05), Vector3(0.23, 0.18, 0.42), leather)
    _box(root, Vector3(0.21, 0.12, -0.05), Vector3(0.23, 0.18, 0.42), leather)

    _sphere(root, Vector3(0, 1.92, 0), Vector3(0.30, 0.34, 0.28), skin)
    _sphere(root, Vector3(-0.105, 1.98, -0.263), Vector3(0.048, 0.035, 0.025), Color(0.07, 0.055, 0.04))
    _sphere(root, Vector3(0.105, 1.98, -0.263), Vector3(0.048, 0.035, 0.025), Color(0.07, 0.055, 0.04))
    _box(root, Vector3(0, 1.90, -0.29), Vector3(0.065, 0.10, 0.08), skin.darkened(0.06))
    _box(root, Vector3(0, 1.79, -0.275), Vector3(0.16, 0.025, 0.035), Color(0.16, 0.08, 0.06))

    if role == "varro":
        _sphere(root, Vector3(0, 2.11, 0.04), Vector3(0.305, 0.12, 0.28), Color(0.24, 0.22, 0.19))
        _box(root, Vector3(0, 1.73, -0.275), Vector3(0.21, 0.11, 0.055), Color(0.28, 0.25, 0.21))
    elif role == "davian":
        _sphere(root, Vector3(0, 2.11, 0.03), Vector3(0.305, 0.10, 0.27), Color(0.08, 0.065, 0.055))

static func _build_felid(root: Node3D, robe: Color) -> void:
    var fur := Color(0.56, 0.34, 0.16)
    var fur_pale := Color(0.72, 0.57, 0.37)
    var leather := robe.darkened(0.28)

    _skirt(root, Vector3(0, 0.58, 0), 0.34, 0.46, 0.96, robe)
    _box(root, Vector3(0, 1.25, 0), Vector3(0.66, 0.70, 0.34), robe.lightened(0.03))
    _box(root, Vector3(0, 0.96, 0), Vector3(0.72, 0.10, 0.38), leather)
    _box(root, Vector3(0, 1.55, 0.02), Vector3(0.78, 0.13, 0.38), robe.darkened(0.18))

    _limb(root, Vector3(-0.43, 1.27, 0), 0.14, 0.60, robe, Vector3(0, 0, -8))
    _limb(root, Vector3(0.43, 1.27, 0), 0.14, 0.60, robe, Vector3(0, 0, 8))
    _limb(root, Vector3(-0.48, 0.84, -0.01), 0.115, 0.48, fur, Vector3(0, 0, -4))
    _limb(root, Vector3(0.48, 0.84, -0.01), 0.115, 0.48, fur, Vector3(0, 0, 4))
    _sphere(root, Vector3(-0.49, 0.57, -0.03), Vector3(0.14, 0.13, 0.11), fur_pale)
    _sphere(root, Vector3(0.49, 0.57, -0.03), Vector3(0.14, 0.13, 0.11), fur_pale)

    _box(root, Vector3(-0.21, 0.12, -0.06), Vector3(0.24, 0.18, 0.43), fur.darkened(0.12))
    _box(root, Vector3(0.21, 0.12, -0.06), Vector3(0.24, 0.18, 0.43), fur.darkened(0.12))

    _sphere(root, Vector3(0, 1.93, 0), Vector3(0.32, 0.34, 0.29), fur)
    _cone(root, Vector3(-0.19, 2.19, 0.015), 0.13, 0.28, fur.darkened(0.08), Vector3(0, 0, -7))
    _cone(root, Vector3(0.19, 2.19, 0.015), 0.13, 0.28, fur.darkened(0.08), Vector3(0, 0, 7))
    _sphere(root, Vector3(-0.105, 2.00, -0.275), Vector3(0.065, 0.045, 0.025), Color(0.83, 0.67, 0.20))
    _sphere(root, Vector3(0.105, 2.00, -0.275), Vector3(0.065, 0.045, 0.025), Color(0.83, 0.67, 0.20))
    _sphere(root, Vector3(-0.103, 2.00, -0.296), Vector3(0.020, 0.038, 0.012), Color(0.03, 0.025, 0.02))
    _sphere(root, Vector3(0.103, 2.00, -0.296), Vector3(0.020, 0.038, 0.012), Color(0.03, 0.025, 0.02))
    _sphere(root, Vector3(-0.09, 1.88, -0.30), Vector3(0.13, 0.10, 0.09), fur_pale)
    _sphere(root, Vector3(0.09, 1.88, -0.30), Vector3(0.13, 0.10, 0.09), fur_pale)
    _box(root, Vector3(0, 1.93, -0.38), Vector3(0.10, 0.065, 0.07), Color(0.16, 0.09, 0.065))

    _limb(root, Vector3(0, 0.80, 0.43), 0.055, 0.72, fur.darkened(0.10), Vector3(65, 0, 0))
    _limb(root, Vector3(0, 0.45, 0.70), 0.048, 0.55, fur.darkened(0.13), Vector3(76, 0, 0))

static func _build_conglomerate(root: Node3D, robe: Color) -> void:
    var scales := Color(0.50, 0.55, 0.20)
    var scales_dark := Color(0.31, 0.36, 0.13)
    var eye := Color(0.92, 0.78, 0.16)
    var leather := robe.darkened(0.28)

    _skirt(root, Vector3(0, 0.57, 0.02), 0.42, 0.52, 0.90, robe)
    _box(root, Vector3(0, 1.22, 0.08), Vector3(0.82, 0.72, 0.42), robe.lightened(0.03), Vector3(10, 0, 0))
    _sphere(root, Vector3(0, 1.49, 0.22), Vector3(0.48, 0.30, 0.35), scales_dark)
    _box(root, Vector3(0, 0.96, -0.02), Vector3(0.88, 0.11, 0.46), leather)

    _limb(root, Vector3(-0.52, 1.18, -0.02), 0.16, 0.62, robe, Vector3(0, 0, -12))
    _limb(root, Vector3(0.52, 1.18, -0.02), 0.16, 0.62, robe, Vector3(0, 0, 12))
    _limb(root, Vector3(-0.58, 0.73, -0.08), 0.13, 0.52, scales, Vector3(0, 0, -5))
    _limb(root, Vector3(0.58, 0.73, -0.08), 0.13, 0.52, scales, Vector3(0, 0, 5))
    _sphere(root, Vector3(-0.60, 0.44, -0.10), Vector3(0.14, 0.12, 0.13), scales)
    _sphere(root, Vector3(0.60, 0.44, -0.10), Vector3(0.14, 0.12, 0.13), scales)

    _box(root, Vector3(-0.25, 0.12, -0.09), Vector3(0.30, 0.20, 0.52), scales_dark)
    _box(root, Vector3(0.25, 0.12, -0.09), Vector3(0.30, 0.20, 0.52), scales_dark)

    _sphere(root, Vector3(0, 1.88, -0.03), Vector3(0.39, 0.29, 0.40), scales)
    _box(root, Vector3(0, 1.82, -0.38), Vector3(0.42, 0.22, 0.48), scales)
    _box(root, Vector3(0, 1.77, -0.64), Vector3(0.30, 0.15, 0.22), scales.darkened(0.05))
    _sphere(root, Vector3(-0.17, 1.96, -0.35), Vector3(0.065, 0.055, 0.035), eye)
    _sphere(root, Vector3(0.17, 1.96, -0.35), Vector3(0.065, 0.055, 0.035), eye)
    _sphere(root, Vector3(-0.17, 1.96, -0.377), Vector3(0.022, 0.043, 0.015), Color(0.03, 0.03, 0.02))
    _sphere(root, Vector3(0.17, 1.96, -0.377), Vector3(0.022, 0.043, 0.015), Color(0.03, 0.03, 0.02))

    _limb(root, Vector3(0, 0.78, 0.48), 0.09, 0.82, scales_dark, Vector3(62, 0, 0))
    _limb(root, Vector3(0, 0.35, 0.83), 0.07, 0.68, scales_dark.darkened(0.08), Vector3(73, 0, 0))

static func _build_glauxi(root: Node3D, robe: Color) -> void:
    var feather := Color(0.38, 0.36, 0.33)
    var feather_pale := Color(0.67, 0.62, 0.52)
    var feather_dark := Color(0.20, 0.19, 0.18)
    var leather := robe.darkened(0.28)

    _skirt(root, Vector3(0, 0.61, 0), 0.29, 0.39, 1.02, robe)
    _box(root, Vector3(0, 1.31, 0), Vector3(0.54, 0.72, 0.30), robe.lightened(0.03))
    _box(root, Vector3(0, 1.58, 0.03), Vector3(0.65, 0.12, 0.32), robe.darkened(0.18))
    _box(root, Vector3(0, 1.00, 0), Vector3(0.60, 0.09, 0.34), leather)

    _wing(root, -1.0, feather, feather_dark)
    _wing(root, 1.0, feather, feather_dark)

    _box(root, Vector3(-0.16, 0.15, -0.04), Vector3(0.13, 0.30, 0.22), feather_dark)
    _box(root, Vector3(0.16, 0.15, -0.04), Vector3(0.13, 0.30, 0.22), feather_dark)
    _box(root, Vector3(-0.19, 0.04, -0.20), Vector3(0.28, 0.07, 0.12), feather_pale)
    _box(root, Vector3(0.19, 0.04, -0.20), Vector3(0.28, 0.07, 0.12), feather_pale)

    _sphere(root, Vector3(0, 1.98, 0), Vector3(0.31, 0.34, 0.27), feather)
    _sphere(root, Vector3(0, 1.98, -0.25), Vector3(0.27, 0.28, 0.07), feather_pale)
    _sphere(root, Vector3(-0.105, 2.03, -0.31), Vector3(0.08, 0.09, 0.035), Color(0.10, 0.095, 0.075))
    _sphere(root, Vector3(0.105, 2.03, -0.31), Vector3(0.08, 0.09, 0.035), Color(0.10, 0.095, 0.075))
    _sphere(root, Vector3(-0.105, 2.03, -0.342), Vector3(0.028, 0.040, 0.013), Color(0.01, 0.01, 0.01))
    _sphere(root, Vector3(0.105, 2.03, -0.342), Vector3(0.028, 0.040, 0.013), Color(0.01, 0.01, 0.01))
    _cone(root, Vector3(0, 1.91, -0.39), 0.075, 0.20, Color(0.58, 0.46, 0.23), Vector3(90, 0, 0))
    _cone(root, Vector3(-0.21, 2.19, 0.01), 0.09, 0.20, feather_dark, Vector3(0, 0, -15))
    _cone(root, Vector3(0.21, 2.19, 0.01), 0.09, 0.20, feather_dark, Vector3(0, 0, 15))

static func _wing(root: Node3D, side: float, feather: Color, feather_dark: Color) -> void:
    _limb(root, Vector3(0.39 * side, 1.30, 0.01), 0.12, 0.58, feather, Vector3(0, 0, -12.0 * side))
    _limb(root, Vector3(0.47 * side, 0.88, 0.02), 0.10, 0.52, feather_dark, Vector3(0, 0, -6.0 * side))
    for i in range(3):
        _box(root, Vector3((0.49 + float(i) * 0.055) * side, 0.72 - float(i) * 0.09, 0.08 + float(i) * 0.02), Vector3(0.12, 0.54 - float(i) * 0.06, 0.08), feather.darkened(0.04 * float(i)), Vector3(0, 0, -6.0 * side))

static func _skirt(root: Node3D, pos: Vector3, top_r: float, bottom_r: float, height: float, color: Color) -> void:
    var mesh := CylinderMesh.new()
    mesh.top_radius = top_r
    mesh.bottom_radius = bottom_r
    mesh.height = height
    mesh.radial_segments = 8
    mesh.material = _mat(color)
    var node := MeshInstance3D.new()
    node.mesh = mesh
    node.position = pos
    root.add_child(node)

static func _limb(root: Node3D, pos: Vector3, radius: float, height: float, color: Color, rotation: Vector3 = Vector3.ZERO) -> void:
    var mesh := CylinderMesh.new()
    mesh.top_radius = radius * 0.82
    mesh.bottom_radius = radius
    mesh.height = height
    mesh.radial_segments = 7
    mesh.material = _mat(color)
    var node := MeshInstance3D.new()
    node.mesh = mesh
    node.position = pos
    node.rotation_degrees = rotation
    root.add_child(node)

static func _box(root: Node3D, pos: Vector3, size: Vector3, color: Color, rotation: Vector3 = Vector3.ZERO) -> void:
    var mesh := BoxMesh.new()
    mesh.size = size
    mesh.material = _mat(color)
    var node := MeshInstance3D.new()
    node.mesh = mesh
    node.position = pos
    node.rotation_degrees = rotation
    root.add_child(node)

static func _sphere(root: Node3D, pos: Vector3, scale_v: Vector3, color: Color) -> void:
    var mesh := SphereMesh.new()
    mesh.radius = 1.0
    mesh.height = 2.0
    mesh.radial_segments = 8
    mesh.rings = 5
    mesh.material = _mat(color)
    var node := MeshInstance3D.new()
    node.mesh = mesh
    node.position = pos
    node.scale = scale_v
    root.add_child(node)

static func _cone(root: Node3D, pos: Vector3, radius: float, height: float, color: Color, rotation: Vector3 = Vector3.ZERO) -> void:
    var mesh := CylinderMesh.new()
    mesh.top_radius = 0.0
    mesh.bottom_radius = radius
    mesh.height = height
    mesh.radial_segments = 6
    mesh.material = _mat(color)
    var node := MeshInstance3D.new()
    node.mesh = mesh
    node.position = pos
    node.rotation_degrees = rotation
    root.add_child(node)

static func _mat(color: Color) -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.93
    return mat
