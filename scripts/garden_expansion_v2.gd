extends Node3D

# Garden Expansion V2 is intentionally isolated from world_m3.gd. The stable M3
# courtyard remains the base world; this node only opens one portal in the M3
# botanical cloister and adds a deeper Tamdin annex plus a dedicated flora-fontis
# bed. If this node ever fails, the underlying world still exists.

const STONE_DARK := Color(0.19, 0.18, 0.16)
const STONE_MID := Color(0.31, 0.29, 0.25)
const STONE_PALE := Color(0.43, 0.39, 0.32)
const TAMDIN_SOIL := Color(0.48, 0.245, 0.30)
const TAMDIN_PATH := Color(0.57, 0.48, 0.43)

var _built := false

func _ready() -> void:
    call_deferred("_build_expansion")

func _build_expansion() -> void:
    if _built:
        return
    _built = true

    var main := get_parent() as Node3D
    if main == null:
        return

    _open_tamdin_portal(main)
    _replace_scattered_flora_fontis(main)
    _decorate_eytelia(main)
    _build_tamdin_annex()

func _open_tamdin_portal(main: Node3D) -> void:
    # The portal sits between two existing M3 peristyle columns, so the old
    # cloister still reads as a coherent architectural space.
    var old_wall := main.get_node_or_null("WestGardenWall")
    if old_wall != null:
        old_wall.queue_free()

    # Original wall range: z -4.6 through 14.0. Opening centered on z=-0.5,
    # safely between the existing columns at -2.2 and 1.2.
    _box("G2WestWallNorth", Vector3(-33.2, 3.0, -3.60), Vector3(1.1, 6.0, 2.0), STONE_DARK)
    _box("G2WestWallSouth", Vector3(-33.2, 3.0, 6.15), Vector3(1.1, 6.0, 15.7), STONE_DARK)
    _box("G2TamdinGateNorthPier", Vector3(-33.2, 2.15, -2.05), Vector3(1.35, 4.3, 0.55), STONE_PALE)
    _box("G2TamdinGateSouthPier", Vector3(-33.2, 2.15, 1.05), Vector3(1.35, 4.3, 0.55), STONE_PALE)
    _box("G2TamdinGateLintel", Vector3(-33.2, 4.25, -0.5), Vector3(1.35, 0.72, 3.65), STONE_PALE)
    _box("G2TamdinThreshold", Vector3(-34.15, 0.08, -0.5), Vector3(2.6, 0.16, 2.45), STONE_MID)

func _build_tamdin_annex() -> void:
    var root := Node3D.new()
    root.name = "G2TamdinGarden"
    add_child(root)

    # A significantly larger second garden west of the M3 cloister. Its entire
    # walkable base is one simple collider; paths and plants are visual-only.
    _box("G2TamdinSoilFloor", Vector3(-43.0, 0.02, -3.0), Vector3(18.8, 0.16, 15.0), TAMDIN_SOIL)
    _box("G2TamdinWestWall", Vector3(-52.4, 3.0, -3.0), Vector3(1.0, 6.0, 15.0), STONE_DARK)
    _box("G2TamdinNorthWall", Vector3(-43.0, 3.0, -10.5), Vector3(18.8, 6.0, 1.0), STONE_DARK)
    _box("G2TamdinSouthWall", Vector3(-43.0, 3.0, 4.5), Vector3(18.8, 6.0, 1.0), STONE_DARK)

    # A short entry court keeps the transition legible before the garden becomes
    # visually dense.
    _box("G2EntryPaving", Vector3(-36.0, 0.115, -0.5), Vector3(4.0, 0.07, 2.35), STONE_MID.darkened(0.04), false)
    _column(Vector3(-35.2, 2.45, -2.6), STONE_PALE.darkened(0.04))
    _column(Vector3(-35.2, 2.45, 1.6), STONE_PALE.darkened(0.04))

    _build_spiral_paths()
    _build_tamdin_plants()

    # Central open space corresponds to the crowd-gathering area in the novel.
    _disc("G2TamdinCentralClearing", Vector3(-45.1, 0.125, -3.0), 2.05, TAMDIN_PATH.lightened(0.08))

func _build_spiral_paths() -> void:
    # A clockwise rectangular spiral. These strips sit just above the soil and
    # intentionally have no collision, so they cannot create invisible snags.
    var strips := [
        [Vector3(-37.7, 0.12, -0.5), Vector3(5.6, 0.06, 1.25), 0.0],
        [Vector3(-40.15, 0.12, -3.65), Vector3(1.25, 0.06, 7.4), 0.0],
        [Vector3(-44.65, 0.12, -6.75), Vector3(10.2, 0.06, 1.25), 0.0],
        [Vector3(-49.15, 0.12, -3.55), Vector3(1.25, 0.06, 7.65), 0.0],
        [Vector3(-46.25, 0.12, -0.35), Vector3(7.0, 0.06, 1.25), 0.0],
        [Vector3(-43.35, 0.12, -2.0), Vector3(1.25, 0.06, 4.1), 0.0],
        [Vector3(-44.75, 0.12, -3.55), Vector3(4.05, 0.06, 1.20), 0.0],
    ]
    for i in range(strips.size()):
        var data = strips[i]
        _visual_box("G2SpiralPath_%02d" % i, data[0], data[1], TAMDIN_PATH)

func _build_tamdin_plants() -> void:
    # Positions intentionally live between/around the spiral strips. The visual
    # density rises toward the outer walls while the center remains open.
    var positions: Array[Vector3] = [
        Vector3(-36.6, 0, -7.9), Vector3(-38.2, 0, -8.7), Vector3(-41.5, 0, -8.5),
        Vector3(-45.0, 0, -8.6), Vector3(-48.3, 0, -8.4), Vector3(-50.5, 0, -7.6),
        Vector3(-50.6, 0, -5.2), Vector3(-50.7, 0, -0.5), Vector3(-50.3, 0, 2.4),
        Vector3(-47.8, 0, 2.7), Vector3(-44.7, 0, 2.5), Vector3(-41.4, 0, 2.7),
        Vector3(-38.4, 0, 2.6), Vector3(-37.0, 0, -3.3), Vector3(-42.0, 0, -5.2),
        Vector3(-47.3, 0, -5.0), Vector3(-47.0, 0, 0.8), Vector3(-41.2, 0, 0.7),
    ]

    for i in range(positions.size()):
        if i in [2, 8, 14]:
            _tamdin_figure(positions[i], i)
        else:
            _tamdin_coral(positions[i], i)

func _tamdin_coral(pos: Vector3, index: int) -> void:
    var root := Node3D.new()
    root.name = "G2TamdinCoral_%02d" % index
    root.position = pos
    add_child(root)

    var palette := [
        Color(0.61, 0.28, 0.36), Color(0.34, 0.49, 0.47), Color(0.47, 0.34, 0.57),
        Color(0.66, 0.43, 0.25), Color(0.42, 0.55, 0.31), Color(0.55, 0.29, 0.48)
    ]
    var flesh: Color = palette[index % palette.size()]
    var height: float = 1.35 + float(index % 5) * 0.30

    _limb(root, "Trunk", Vector3(0, height * 0.5, 0), height, 0.15, flesh, Vector3(0, 0, -6 + (index % 4) * 4))
    _limb(root, "Bone", Vector3(0.02, height * 0.48, -0.035), height * 0.80, 0.045, Color(0.77, 0.66, 0.58), Vector3(0, 0, -4))

    for branch_i in range(3 + index % 2):
        var side := -1.0 if branch_i % 2 == 0 else 1.0
        var branch_h: float = height * (0.42 + float(branch_i) * 0.08)
        var angle: float = side * (34.0 + float(branch_i) * 9.0)
        _limb(root, "Branch_%d" % branch_i, Vector3(side * 0.18, height * (0.56 + branch_i * 0.08), 0.02 * branch_i), branch_h, 0.10, flesh.lightened(0.04), Vector3(0, 0, angle))
        _tip_lobe(root, Vector3(side * (0.48 + branch_i * 0.08), height * (0.72 + branch_i * 0.08), 0.03 * branch_i), flesh.lightened(0.08), branch_i)

func _tamdin_figure(pos: Vector3, index: int) -> void:
    # Not literal people: just close enough to the silhouette that the eye keeps
    # trying to read a frozen person into the plant, as Harvey does.
    var root := Node3D.new()
    root.name = "G2TamdinFigure_%02d" % index
    root.position = pos
    add_child(root)

    var flesh := Color(0.53, 0.26, 0.33) if index % 2 == 0 else Color(0.34, 0.42, 0.55)
    var h := 2.35 + float(index % 3) * 0.28
    _limb(root, "Torso", Vector3(0, h * 0.48, 0), h * 0.78, 0.16, flesh, Vector3(0, 0, -3))
    _limb(root, "InnerBone", Vector3(0, h * 0.47, -0.04), h * 0.70, 0.045, Color(0.80, 0.68, 0.60), Vector3(0, 0, -2))
    _limb(root, "LeftReach", Vector3(-0.28, h * 0.68, 0), h * 0.58, 0.105, flesh.lightened(0.03), Vector3(0, 0, 58))
    _limb(root, "RightReach", Vector3(0.30, h * 0.70, 0), h * 0.62, 0.105, flesh.lightened(0.03), Vector3(0, 0, -52))
    _tip_lobe(root, Vector3(-0.62, h * 0.90, 0), flesh.lightened(0.08), 0)
    _tip_lobe(root, Vector3(0.64, h * 0.88, 0), flesh.lightened(0.08), 1)

    var crown := MeshInstance3D.new()
    crown.name = "Crown"
    var mesh := SphereMesh.new()
    mesh.radius = 0.25
    mesh.height = 0.58
    mesh.radial_segments = 7
    mesh.rings = 4
    var mat := StandardMaterial3D.new()
    mat.albedo_color = flesh
    mat.roughness = 0.92
    mesh.material = mat
    crown.mesh = mesh
    crown.position = Vector3(0.04, h * 0.90, 0)
    crown.scale = Vector3(0.72, 1.35, 0.68)
    root.add_child(crown)

func _replace_scattered_flora_fontis(main: Node3D) -> void:
    # M3 used several permanently glowing blossoms as placeholders. Replace them
    # with a dedicated preservation bed: mostly dormant plants and one rare bloom.
    for child in main.get_children():
        if str(child.name).begins_with("FloraFontis"):
            child.queue_free()

    var root := Node3D.new()
    root.name = "G2FloraFontisCourt"
    add_child(root)

    _visual_box("G2FloraBed", Vector3(-20.1, 0.105, 10.55), Vector3(5.1, 0.07, 3.4), Color(0.12, 0.105, 0.09))
    _visual_box("G2FloraBedEdgeN", Vector3(-20.1, 0.17, 8.88), Vector3(5.3, 0.22, 0.20), STONE_PALE.darkened(0.10))
    _visual_box("G2FloraBedEdgeS", Vector3(-20.1, 0.17, 12.22), Vector3(5.3, 0.22, 0.20), STONE_PALE.darkened(0.10))

    for i in range(18):
        var x: float = -22.0 + float(i % 6) * 0.76
        var z: float = 9.45 + float(i / 6) * 1.05 + float(i % 2) * 0.10
        _flora_dormant(Vector3(x, 0.0, z), i)

    _flora_bloom(Vector3(-19.7, 0.0, 10.55))

func _flora_dormant(pos: Vector3, index: int) -> void:
    var root := Node3D.new()
    root.name = "G2FloraDormant_%02d" % index
    root.position = pos
    add_child(root)

    var base := MeshInstance3D.new()
    var mesh := SphereMesh.new()
    mesh.radius = 0.13 + float(index % 3) * 0.018
    mesh.height = 0.18
    mesh.radial_segments = 6
    mesh.rings = 3
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.21, 0.28, 0.18)
    mat.roughness = 0.95
    mesh.material = mat
    base.mesh = mesh
    base.position.y = 0.13
    base.scale = Vector3(1.35, 0.65, 1.0)
    root.add_child(base)

    for j in range(3):
        var bud := MeshInstance3D.new()
        var bud_mesh := SphereMesh.new()
        bud_mesh.radius = 0.055
        bud_mesh.height = 0.16
        bud_mesh.radial_segments = 5
        bud_mesh.rings = 3
        var bud_mat := StandardMaterial3D.new()
        bud_mat.albedo_color = Color(0.36, 0.23 + j * 0.025, 0.31)
        bud_mat.roughness = 0.88
        bud_mesh.material = bud_mat
        bud.mesh = bud_mesh
        bud.position = Vector3(-0.07 + j * 0.07, 0.24 + j * 0.015, 0)
        root.add_child(bud)

func _flora_bloom(pos: Vector3) -> void:
    var root := Node3D.new()
    root.name = "G2FloraBloom"
    root.position = pos
    add_child(root)

    var center := MeshInstance3D.new()
    var mesh := SphereMesh.new()
    mesh.radius = 0.105
    mesh.height = 0.20
    mesh.radial_segments = 7
    mesh.rings = 4
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.62, 0.34, 0.52)
    mat.emission_enabled = true
    mat.emission = Color(0.42, 0.16, 0.37)
    mat.emission_energy_multiplier = 1.1
    mesh.material = mat
    center.mesh = mesh
    center.position.y = 0.32
    root.add_child(center)

    # Concentric translucent-looking luminous rings stand in for the waves of
    # phosphorescent pollen that create the illusion of petals.
    for i in range(4):
        var ring := MeshInstance3D.new()
        ring.name = "PollenWave_%d" % i
        var torus := TorusMesh.new()
        torus.inner_radius = 0.17 + float(i) * 0.10
        torus.outer_radius = 0.205 + float(i) * 0.10
        torus.rings = 10
        torus.ring_segments = 6
        var ring_mat := StandardMaterial3D.new()
        ring_mat.albedo_color = Color(0.60, 0.25, 0.53)
        ring_mat.emission_enabled = true
        ring_mat.emission = Color(0.45, 0.16, 0.40)
        ring_mat.emission_energy_multiplier = 0.72 - float(i) * 0.09
        ring_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
        ring_mat.albedo_color.a = 0.58 - float(i) * 0.08
        torus.material = ring_mat
        ring.mesh = torus
        ring.position.y = 0.32 + float(i) * 0.018
        root.add_child(ring)

func _decorate_eytelia(main: Node3D) -> void:
    var tree := main.get_node_or_null("EyteliaTree") as Node3D
    if tree == null:
        return

    var blossom_root := Node3D.new()
    blossom_root.name = "G2EyteliaBlossoms"
    tree.add_child(blossom_root)

    for i in range(20):
        var blossom := MeshInstance3D.new()
        blossom.name = "Blossom_%02d" % i
        var mesh := SphereMesh.new()
        mesh.radius = 0.10 + float(i % 3) * 0.025
        mesh.height = 0.16
        mesh.radial_segments = 5
        mesh.rings = 3
        var mat := StandardMaterial3D.new()
        mat.albedo_color = Color(0.72 + float(i % 2) * 0.06, 0.56, 0.48 + float(i % 3) * 0.035)
        mat.roughness = 0.88
        mesh.material = mat
        blossom.mesh = mesh
        var angle: float = float(i) * 2.18
        var radius: float = 0.6 + float(i % 5) * 0.28
        blossom.position = Vector3(cos(angle) * radius, 4.15 + float(i % 4) * 0.34, sin(angle) * radius * 0.70)
        blossom_root.add_child(blossom)

func _limb(root: Node3D, node_name: String, pos: Vector3, height: float, radius: float, color: Color, rotation: Vector3) -> void:
    var limb := MeshInstance3D.new()
    limb.name = node_name
    var mesh := CylinderMesh.new()
    mesh.top_radius = radius * 0.72
    mesh.bottom_radius = radius
    mesh.height = height
    mesh.radial_segments = 7
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.91
    mesh.material = mat
    limb.mesh = mesh
    limb.position = pos
    limb.rotation_degrees = rotation
    root.add_child(limb)

func _tip_lobe(root: Node3D, pos: Vector3, color: Color, index: int) -> void:
    var lobe := MeshInstance3D.new()
    lobe.name = "LeafLobe_%d" % index
    var mesh := SphereMesh.new()
    mesh.radius = 0.18
    mesh.height = 0.42
    mesh.radial_segments = 6
    mesh.rings = 3
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.93
    mesh.material = mat
    lobe.mesh = mesh
    lobe.position = pos
    lobe.scale = Vector3(0.70, 1.35, 0.60)
    root.add_child(lobe)

func _box(node_name: String, pos: Vector3, size: Vector3, color: Color, collision_enabled: bool = true) -> StaticBody3D:
    var body := StaticBody3D.new()
    body.name = node_name
    body.position = pos

    var visual := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.96
    mesh.material = mat
    visual.mesh = mesh
    body.add_child(visual)

    if collision_enabled:
        var shape := BoxShape3D.new()
        shape.size = size
        var collision := CollisionShape3D.new()
        collision.name = "CollisionShape3D"
        collision.shape = shape
        body.add_child(collision)

    add_child(body)
    return body

func _visual_box(node_name: String, pos: Vector3, size: Vector3, color: Color) -> void:
    var visual := MeshInstance3D.new()
    visual.name = node_name
    var mesh := BoxMesh.new()
    mesh.size = size
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.96
    mesh.material = mat
    visual.mesh = mesh
    visual.position = pos
    add_child(visual)

func _column(pos: Vector3, color: Color) -> void:
    var body := StaticBody3D.new()
    body.name = "G2Column"
    body.position = pos
    var visual := MeshInstance3D.new()
    var mesh := CylinderMesh.new()
    mesh.top_radius = 0.43
    mesh.bottom_radius = 0.62
    mesh.height = 4.9
    mesh.radial_segments = 8
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.98
    mesh.material = mat
    visual.mesh = mesh
    body.add_child(visual)
    var shape := CylinderShape3D.new()
    shape.radius = 0.62
    shape.height = 4.9
    var collision := CollisionShape3D.new()
    collision.name = "CollisionShape3D"
    collision.shape = shape
    body.add_child(collision)
    add_child(body)

func _disc(node_name: String, pos: Vector3, radius: float, color: Color) -> void:
    var visual := MeshInstance3D.new()
    visual.name = node_name
    var mesh := CylinderMesh.new()
    mesh.top_radius = radius
    mesh.bottom_radius = radius
    mesh.height = 0.055
    mesh.radial_segments = 18
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.96
    mesh.material = mat
    visual.mesh = mesh
    visual.position = pos
    add_child(visual)
