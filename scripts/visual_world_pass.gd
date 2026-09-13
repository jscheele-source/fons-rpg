extends Node3D

const STONE := Color(0.18, 0.17, 0.155)
const STONE_LIGHT := Color(0.30, 0.28, 0.24)
const WOOD := Color(0.20, 0.13, 0.075)
const METAL := Color(0.10, 0.13, 0.14)
const EMBER := Color(0.68, 0.29, 0.08)

var shuttle: Node3D

func _ready() -> void:
    _configure_sky()
    _build_distant_landscape()
    _build_courtyard_detail()
    _build_distant_shuttle()
    call_deferred("_decorate_characters")

func _process(delta: float) -> void:
    if shuttle != null and is_instance_valid(shuttle):
        shuttle.position.x += delta * 2.2
        shuttle.position.z += delta * 0.16
        if shuttle.position.x > 55.0:
            shuttle.position = Vector3(-55.0, 18.5, -42.0)

func _configure_sky() -> void:
    var env_node := get_parent().get_node_or_null("WorldEnvironment") as WorldEnvironment
    if env_node == null or env_node.environment == null:
        return
    var env := env_node.environment
    var sky := Sky.new()
    var material := ProceduralSkyMaterial.new()
    material.sky_top_color = Color(0.055, 0.062, 0.070)
    material.sky_horizon_color = Color(0.25, 0.23, 0.20)
    material.ground_bottom_color = Color(0.035, 0.034, 0.032)
    material.ground_horizon_color = Color(0.20, 0.19, 0.17)
    material.sun_angle_max = 4.0
    material.sun_curve = 0.06
    sky.sky_material = material
    env.sky = sky
    env.background_mode = Environment.BG_SKY
    env.fog_light_color = Color(0.28, 0.27, 0.25)
    env.fog_density = 0.024
    env.fog_sky_affect = 0.86

func _build_distant_landscape() -> void:
    var mountains := [
        [Vector3(-46, 0, -48), 16.0, 26.0, 6],
        [Vector3(-25, 0, -57), 20.0, 34.0, 7],
        [Vector3(2, 0, -63), 18.0, 39.0, 5],
        [Vector3(30, 0, -56), 20.0, 31.0, 6],
        [Vector3(52, 0, -44), 15.0, 24.0, 5],
        [Vector3(-54, 0, 28), 18.0, 26.0, 6],
        [Vector3(48, 0, 31), 17.0, 29.0, 6],
    ]
    for data in mountains:
        _mountain(data[0], float(data[1]), float(data[2]), int(data[3]))

    # Distant monastery masses make the playable court feel like one small
    # precinct of a much larger religious complex.
    for data in [
        [Vector3(-28, 5.5, -31), Vector3(9, 11, 8)],
        [Vector3(24, 7.0, -35), Vector3(11, 14, 9)],
        [Vector3(-37, 4.0, 10), Vector3(8, 8, 12)],
        [Vector3(38, 4.5, 8), Vector3(9, 9, 13)],
    ]:
        _visual_box(data[0], data[1], STONE.darkened(0.08))

    for data in [
        [Vector3(-31, 15.0, -31), 2.1, 11.0],
        [Vector3(28, 18.0, -35), 2.4, 14.0],
        [Vector3(-39, 11.0, 10), 1.8, 9.0],
        [Vector3(41, 11.5, 8), 1.9, 10.0],
    ]:
        _tower(data[0], float(data[1]), float(data[2]))

func _build_courtyard_detail() -> void:
    _bench(Vector3(-12.2, 0.25, 0.2), 90.0)
    _bench(Vector3(12.2, 0.25, 0.8), -90.0)
    _bench(Vector3(-10.7, 0.25, 10.4), 0.0)

    _stone_basin(Vector3(3.5, 0.0, 8.5))
    _urn(Vector3(-12.0, 0.0, -6.5), 1.0)
    _urn(Vector3(12.0, 0.0, -6.2), 0.82)
    _urn(Vector3(-4.5, 0.0, 11.2), 0.72)

    # Old service conduits disappear into the monastery walls. Their function
    # is deliberately mundane and unexplained.
    _conduit(Vector3(-14.18, 1.2, 2.5), Vector3(0.18, 0.18, 8.5))
    _conduit(Vector3(14.18, 1.65, -0.5), Vector3(0.18, 0.18, 6.0))
    _conduit(Vector3(8.8, 0.35, -9.85), Vector3(5.0, 0.16, 0.16))

    # A small devotional niche helps the wall read as architecture rather than
    # a boundary around a sandbox.
    _visual_box(Vector3(-13.95, 1.8, -3.3), Vector3(0.28, 2.8, 2.2), STONE_LIGHT)
    _visual_box(Vector3(-13.68, 1.2, -3.3), Vector3(0.12, 1.1, 1.25), Color(0.08, 0.07, 0.06))
    _small_flame(Vector3(-13.55, 1.42, -3.3))

func _build_distant_shuttle() -> void:
    shuttle = Node3D.new()
    shuttle.name = "DistantShuttle"
    shuttle.position = Vector3(-52.0, 18.5, -42.0)
    shuttle.rotation_degrees = Vector3(0, -8, 0)
    add_child(shuttle)

    var hull := MeshInstance3D.new()
    var hull_mesh := CylinderMesh.new()
    hull_mesh.top_radius = 0.42
    hull_mesh.bottom_radius = 0.72
    hull_mesh.height = 4.6
    hull_mesh.radial_segments = 6
    hull_mesh.material = _material(METAL.lightened(0.05), 0.42, 0.48)
    hull.mesh = hull_mesh
    hull.rotation_degrees.z = 90
    shuttle.add_child(hull)

    _child_box(shuttle, Vector3(-0.25, 0, 0), Vector3(2.8, 0.12, 3.8), METAL.darkened(0.06), Vector3(0, 0, 0))
    _child_box(shuttle, Vector3(1.7, 0, 0), Vector3(0.55, 0.55, 1.25), Color(0.18, 0.24, 0.24), Vector3.ZERO)
    _child_box(shuttle, Vector3(-2.2, 0, -0.32), Vector3(0.18, 0.22, 0.28), Color(0.72, 0.32, 0.10), Vector3.ZERO, true)
    _child_box(shuttle, Vector3(-2.2, 0, 0.32), Vector3(0.18, 0.22, 0.28), Color(0.72, 0.32, 0.10), Vector3.ZERO, true)

func _decorate_characters() -> void:
    var world := get_parent()
    for node in world.get_children():
        if not node.has_method("get_dialogue"):
            continue
        var label = node.get("display_name")
        if label == null:
            continue
        match str(label):
            "Brother Cael":
                _make_felid(node)
            "Surveyor Nemm":
                _make_conglomerate(node)
            "Initiate Kes":
                _make_glauxi(node)
            _:
                pass

func _make_felid(npc: Node3D) -> void:
    var fur := Color(0.47, 0.34, 0.20)
    _child_cone(npc, Vector3(-0.17, 2.27, 0), 0.13, 0.30, fur, Vector3(0, 0, -8))
    _child_cone(npc, Vector3(0.17, 2.27, 0), 0.13, 0.30, fur, Vector3(0, 0, 8))
    _child_box(npc, Vector3(0, 1.04, 0.48), Vector3(0.12, 1.25, 0.12), fur.darkened(0.10), Vector3(58, 0, 0))
    _child_box(npc, Vector3(0, 0.47, 0.83), Vector3(0.10, 0.72, 0.10), fur.darkened(0.10), Vector3(72, 0, 0))

func _make_conglomerate(npc: Node3D) -> void:
    npc.scale = Vector3(1.12, 1.05, 1.12)
    var scale_color := Color(0.48, 0.52, 0.19)
    _child_box(npc, Vector3(0, 1.92, -0.34), Vector3(0.46, 0.28, 0.72), scale_color, Vector3(8, 0, 0))
    _child_box(npc, Vector3(0, 1.43, 0.28), Vector3(0.72, 0.48, 0.50), scale_color.darkened(0.12), Vector3(18, 0, 0))
    _child_box(npc, Vector3(0, 0.88, 0.62), Vector3(0.18, 0.18, 1.35), scale_color.darkened(0.18), Vector3(48, 0, 0))
    _child_box(npc, Vector3(0, 0.34, 1.25), Vector3(0.12, 0.12, 0.95), scale_color.darkened(0.18), Vector3(69, 0, 0))

func _make_glauxi(npc: Node3D) -> void:
    npc.scale = Vector3(0.94, 1.10, 0.94)
    var feather := Color(0.36, 0.34, 0.31)
    var pale := Color(0.58, 0.54, 0.46)
    _child_box(npc, Vector3(-0.49, 1.13, 0), Vector3(0.32, 1.55, 0.16), feather, Vector3(0, 0, -10))
    _child_box(npc, Vector3(0.49, 1.13, 0), Vector3(0.32, 1.55, 0.16), feather, Vector3(0, 0, 10))
    _child_box(npc, Vector3(-0.62, 0.52, 0.03), Vector3(0.24, 0.78, 0.12), feather.darkened(0.08), Vector3(0, 0, -18))
    _child_box(npc, Vector3(0.62, 0.52, 0.03), Vector3(0.24, 0.78, 0.12), feather.darkened(0.08), Vector3(0, 0, 18))
    _child_cone(npc, Vector3(0, 1.93, -0.37), 0.10, 0.26, pale, Vector3(90, 0, 0))
    _child_box(npc, Vector3(0, 1.95, -0.18), Vector3(0.54, 0.44, 0.08), pale, Vector3.ZERO)

func _mountain(pos: Vector3, radius: float, height: float, segments: int) -> void:
    var mesh_instance := MeshInstance3D.new()
    var mesh := CylinderMesh.new()
    mesh.top_radius = radius * 0.055
    mesh.bottom_radius = radius
    mesh.height = height
    mesh.radial_segments = segments
    mesh.material = _material(Color(0.105, 0.11, 0.105), 0.0, 1.0)
    mesh_instance.mesh = mesh
    mesh_instance.position = pos + Vector3(0, height * 0.5 - 1.0, 0)
    mesh_instance.rotation_degrees.y = pos.x * 1.7
    add_child(mesh_instance)

func _tower(pos: Vector3, radius: float, height: float) -> void:
    var tower := MeshInstance3D.new()
    var mesh := CylinderMesh.new()
    mesh.top_radius = radius * 0.72
    mesh.bottom_radius = radius
    mesh.height = height
    mesh.radial_segments = 6
    mesh.material = _material(STONE.darkened(0.08), 0.0, 0.98)
    tower.mesh = mesh
    tower.position = pos
    add_child(tower)
    _visual_box(pos + Vector3(0, height * 0.48, 0), Vector3(radius * 2.6, 0.55, radius * 2.6), STONE_LIGHT.darkened(0.18))

func _bench(pos: Vector3, yaw: float) -> void:
    var root := Node3D.new()
    root.position = pos
    root.rotation_degrees.y = yaw
    add_child(root)
    _child_box(root, Vector3(0, 0.40, 0), Vector3(2.4, 0.18, 0.62), WOOD, Vector3.ZERO)
    _child_box(root, Vector3(-0.9, 0.17, 0), Vector3(0.18, 0.50, 0.44), WOOD.darkened(0.12), Vector3.ZERO)
    _child_box(root, Vector3(0.9, 0.17, 0), Vector3(0.18, 0.50, 0.44), WOOD.darkened(0.12), Vector3.ZERO)

func _stone_basin(pos: Vector3) -> void:
    var base := MeshInstance3D.new()
    var mesh := CylinderMesh.new()
    mesh.top_radius = 1.0
    mesh.bottom_radius = 0.82
    mesh.height = 0.52
    mesh.radial_segments = 8
    mesh.material = _material(STONE_LIGHT, 0.0, 1.0)
    base.mesh = mesh
    base.position = pos + Vector3(0, 0.26, 0)
    add_child(base)
    var dark := MeshInstance3D.new()
    var dark_mesh := CylinderMesh.new()
    dark_mesh.top_radius = 0.72
    dark_mesh.bottom_radius = 0.70
    dark_mesh.height = 0.04
    dark_mesh.radial_segments = 8
    dark_mesh.material = _material(Color(0.075, 0.07, 0.06), 0.0, 1.0)
    dark.mesh = dark_mesh
    dark.position = pos + Vector3(0, 0.54, 0)
    add_child(dark)

func _urn(pos: Vector3, scale_factor: float) -> void:
    var urn := MeshInstance3D.new()
    var mesh := CylinderMesh.new()
    mesh.top_radius = 0.24 * scale_factor
    mesh.bottom_radius = 0.38 * scale_factor
    mesh.height = 0.88 * scale_factor
    mesh.radial_segments = 7
    mesh.material = _material(Color(0.34, 0.24, 0.16), 0.0, 0.96)
    urn.mesh = mesh
    urn.position = pos + Vector3(0, 0.44 * scale_factor, 0)
    add_child(urn)

func _conduit(pos: Vector3, size: Vector3) -> void:
    _visual_box(pos, size, METAL.lightened(0.03))
    _visual_box(pos + Vector3(0.04, 0.04, 0.04), size * 0.55, Color(0.16, 0.23, 0.22))

func _small_flame(pos: Vector3) -> void:
    var flame := MeshInstance3D.new()
    var mesh := CylinderMesh.new()
    mesh.top_radius = 0.01
    mesh.bottom_radius = 0.09
    mesh.height = 0.34
    mesh.radial_segments = 5
    var mat := _material(EMBER, 0.0, 0.5)
    mat.emission_enabled = true
    mat.emission = EMBER
    mat.emission_energy_multiplier = 1.8
    mesh.material = mat
    flame.mesh = mesh
    flame.position = pos
    add_child(flame)

func _visual_box(pos: Vector3, size: Vector3, color: Color) -> void:
    var visual := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    mesh.material = _material(color, 0.0, 0.98)
    visual.mesh = mesh
    visual.position = pos
    add_child(visual)

func _child_box(parent: Node3D, pos: Vector3, size: Vector3, color: Color, rot: Vector3, glowing: bool = false) -> void:
    var visual := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    var mat := _material(color, 0.0, 0.92)
    if glowing:
        mat.emission_enabled = true
        mat.emission = color
        mat.emission_energy_multiplier = 1.4
    mesh.material = mat
    visual.mesh = mesh
    visual.position = pos
    visual.rotation_degrees = rot
    parent.add_child(visual)

func _child_cone(parent: Node3D, pos: Vector3, radius: float, height: float, color: Color, rot: Vector3) -> void:
    var visual := MeshInstance3D.new()
    var mesh := CylinderMesh.new()
    mesh.top_radius = 0.0
    mesh.bottom_radius = radius
    mesh.height = height
    mesh.radial_segments = 3
    mesh.material = _material(color, 0.0, 1.0)
    visual.mesh = mesh
    visual.position = pos
    visual.rotation_degrees = rot
    parent.add_child(visual)

func _material(color: Color, metallic: float, roughness: float) -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.metallic = metallic
    mat.roughness = roughness
    return mat
