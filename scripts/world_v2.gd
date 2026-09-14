extends "res://scripts/world.gd"

const NPC_V2 = preload("res://scripts/npc_v2.gd")

var _garden_clock := 0.0
var _pampin_strands: Array[Node3D] = []

func _process(delta: float) -> void:
    _garden_clock += delta
    for i in range(_pampin_strands.size()):
        var strand := _pampin_strands[i]
        if strand == null or not is_instance_valid(strand):
            continue
        strand.rotation_degrees.z = sin(_garden_clock * 1.15 + float(i) * 0.63) * 4.5

func _build_world() -> void:
    super._build_world()
    _open_west_garden()
    _build_west_garden()

func _spawn_npc(name_text: String, id: String, pos: Vector3, color: Color) -> void:
    var npc = NPC_V2.new()
    npc.display_name = name_text
    npc.dialogue_id = id
    npc.body_color = color
    npc.position = pos
    add_child(npc)

func _rock(pos: Vector3, rock_scale: Vector3, color: Color) -> void:
    super._rock(pos, rock_scale, color)
    var body := StaticBody3D.new()
    body.name = "RockCollision"
    body.position = pos + Vector3(0, rock_scale.y * 0.45, 0)
    var shape := BoxShape3D.new()
    shape.size = Vector3(rock_scale.x * 1.55, rock_scale.y * 1.55, rock_scale.z * 1.55)
    var collision := CollisionShape3D.new()
    collision.shape = shape
    body.add_child(collision)
    add_child(body)

func _distant_monolith(pos: Vector3) -> void:
    super._distant_monolith(pos)
    var body := StaticBody3D.new()
    body.name = "MonolithCollision"
    body.position = pos
    body.rotation_degrees = Vector3(0, pos.z, -4.0 + fmod(abs(pos.x), 8.0))
    var shape := BoxShape3D.new()
    shape.size = Vector3(3.0, 11.0, 2.2)
    var collision := CollisionShape3D.new()
    collision.shape = shape
    body.add_child(collision)
    add_child(body)

func _open_west_garden() -> void:
    var old_wall := get_node_or_null("WestWall")
    if old_wall != null:
        old_wall.queue_free()

    _box("WestWallNorth", Vector3(-14.7, 3.7, -4.85), Vector3(1.4, 7.4, 11.7), STONE_DARK)
    _box("WestWallSouth", Vector3(-14.7, 3.7, 11.15), Vector3(1.4, 7.4, 6.7), STONE_DARK)
    _box("GardenGateNorthPier", Vector3(-14.7, 2.35, 1.25), Vector3(1.8, 4.7, 0.82), STONE_PALE)
    _box("GardenGateSouthPier", Vector3(-14.7, 2.35, 8.05), Vector3(1.8, 4.7, 0.82), STONE_PALE)
    _box("GardenGateLintel", Vector3(-14.7, 4.65, 4.65), Vector3(1.8, 0.82, 7.6), STONE_PALE)
    _box("GardenThreshold", Vector3(-16.0, 0.05, 4.65), Vector3(3.8, 0.18, 5.8), STONE_MID, false)

func _build_west_garden() -> void:
    var garden := Node3D.new()
    garden.name = "AlienBotanicalCloister"
    add_child(garden)

    _box("GardenGround", Vector3(-36.3, -0.01, 3.2), Vector3(43.0, 0.18, 23.6), Color(0.18, 0.17, 0.15))
    _box("GardenWestWall", Vector3(-57.8, 3.15, 3.2), Vector3(1.2, 6.3, 23.6), STONE_DARK)
    _box("GardenNorthWall", Vector3(-36.3, 3.15, -8.6), Vector3(43.0, 6.3, 1.2), STONE_DARK)
    _box("GardenSouthWall", Vector3(-36.3, 3.15, 15.0), Vector3(43.0, 6.3, 1.2), STONE_DARK)
    _box("GardenEastNorthMass", Vector3(-16.0, 3.15, -5.5), Vector3(2.0, 6.3, 5.0), STONE_DARK)
    _box("GardenEastSouthMass", Vector3(-16.0, 3.15, 12.5), Vector3(2.0, 6.3, 5.0), STONE_DARK)

    _build_path_network()
    _build_eytelia_cloister()
    _build_flora_fontis_court()
    _build_tamdin_garden()

func _build_path_network() -> void:
    var path_color := STONE_PALE.darkened(0.12)
    _path_slab(Vector3(-22.1, 0.10, 4.65), Vector3(12.2, 0.12, 3.0), path_color)
    _path_slab(Vector3(-28.2, 0.10, 4.65), Vector3(3.0, 0.12, 14.6), path_color)
    _path_slab(Vector3(-35.4, 0.10, -2.65), Vector3(14.6, 0.12, 2.5), path_color)
    _path_slab(Vector3(-36.0, 0.10, 11.15), Vector3(15.8, 0.12, 2.5), path_color)
    _path_slab(Vector3(-40.3, 0.10, 4.65), Vector3(21.2, 0.12, 2.6), path_color)
    _path_slab(Vector3(-50.3, 0.10, 1.1), Vector3(2.6, 0.12, 8.4), path_color)
    _path_slab(Vector3(-47.2, 0.10, -2.55), Vector3(8.8, 0.12, 2.3), path_color)
    _path_slab(Vector3(-43.4, 0.10, 0.2), Vector3(2.3, 0.12, 7.8), path_color)
    _path_slab(Vector3(-46.4, 0.10, 3.55), Vector3(7.8, 0.12, 2.1), path_color)

func _path_slab(pos: Vector3, size: Vector3, color: Color) -> void:
    _box("GardenPath", pos, size, color, false)

func _build_eytelia_cloister() -> void:
    var root := Node3D.new()
    root.name = "EyteliaCloister"
    add_child(root)

    _box("EyteliaBed", Vector3(-40.8, 0.08, 11.15), Vector3(7.0, 0.14, 5.5), Color(0.10, 0.095, 0.08), false)
    _build_eytelia_tree(Vector3(-40.8, 0.0, 11.1))
    _build_pampin_vines(Vector3(-31.7, 0.0, 8.3), 11.0, 90.0)
    _build_pampin_vines(Vector3(-31.7, 0.0, 13.95), 11.0, 90.0)

    for p in [
        Vector3(-45.4, 0, 9.0), Vector3(-46.4, 0, 12.9), Vector3(-37.0, 0, 9.0),
        Vector3(-36.5, 0, 13.1), Vector3(-49.0, 0, 10.8)
    ]:
        _alien_plant(p)

func _build_flora_fontis_court() -> void:
    var root := Node3D.new()
    root.name = "FloraFontisCourt"
    add_child(root)

    _box("FloraFontisSoil", Vector3(-39.7, 0.075, -5.25), Vector3(17.4, 0.14, 5.2), Color(0.22, 0.20, 0.17), false)
    for x in [-46.6, -44.7, -42.8, -40.9, -39.0, -37.1, -35.2, -33.3]:
        _flora_fontis(Vector3(x, 0.0, -5.9), false)
        _flora_fontis(Vector3(x + 0.65, 0.0, -4.25), false)
    _flora_fontis(Vector3(-45.8, 0.0, -4.45), true)
    _flora_fontis(Vector3(-38.25, 0.0, -5.4), true)

    for x in [-48.2, -43.0, -37.8, -32.6]:
        _column(Vector3(x, 2.45, -7.4), STONE_PALE.darkened(0.05))

func _build_tamdin_garden() -> void:
    var root := Node3D.new()
    root.name = "TamdinGarden"
    add_child(root)

    _box("TamdinPinkSoil", Vector3(-49.2, 0.07, 5.8), Vector3(15.8, 0.14, 15.8), Color(0.53, 0.36, 0.39), false)

    var plants = [
        [Vector3(-54.3, 0, -0.9), Color(0.54, 0.23, 0.30), 1.15, 0],
        [Vector3(-47.0, 0, -0.2), Color(0.20, 0.45, 0.43), 0.95, 1],
        [Vector3(-53.3, 0, 3.0), Color(0.43, 0.30, 0.57), 1.25, 2],
        [Vector3(-46.4, 0, 2.3), Color(0.62, 0.39, 0.18), 0.90, 0],
        [Vector3(-55.1, 0, 6.0), Color(0.29, 0.37, 0.58), 1.05, 1],
        [Vector3(-47.9, 0, 6.2), Color(0.51, 0.24, 0.43), 1.35, 2],
        [Vector3(-53.7, 0, 9.5), Color(0.18, 0.46, 0.34), 0.92, 0],
        [Vector3(-46.2, 0, 9.8), Color(0.55, 0.34, 0.18), 1.18, 1],
        [Vector3(-51.1, 0, 12.1), Color(0.48, 0.25, 0.55), 1.05, 2],
        [Vector3(-43.5, 0, 7.9), Color(0.22, 0.42, 0.49), 0.82, 0]
    ]
    for data in plants:
        _tamdin_plant(data[0], data[1], float(data[2]), int(data[3]))

    _tamdin_humanoid(Vector3(-51.4, 0, 6.9), Color(0.55, 0.28, 0.33), 1.12)

func _build_eytelia_tree(pos: Vector3) -> void:
    var body := StaticBody3D.new()
    body.name = "EyteliaTree"
    body.position = pos
    add_child(body)

    var trunk_mat := _garden_material(Color(0.26, 0.12, 0.10), false)
    _cylinder_visual(body, Vector3(0, 2.7, 0), 0.36, 0.70, 5.4, trunk_mat, Vector3(0, 0, -5))
    _cylinder_visual(body, Vector3(-0.72, 5.0, 0.0), 0.20, 0.34, 3.0, trunk_mat, Vector3(0, 0, -32))
    _cylinder_visual(body, Vector3(0.82, 5.15, -0.15), 0.18, 0.32, 2.8, trunk_mat, Vector3(8, 0, 34))
    _cylinder_visual(body, Vector3(0.0, 5.6, 0.75), 0.16, 0.30, 2.4, trunk_mat, Vector3(36, 0, 0))

    var trunk_shape := CylinderShape3D.new()
    trunk_shape.radius = 0.72
    trunk_shape.height = 5.2
    var collision := CollisionShape3D.new()
    collision.shape = trunk_shape
    collision.position.y = 2.6
    body.add_child(collision)

    var blossom_colors = [Color(0.52, 0.65, 0.54), Color(0.70, 0.53, 0.58), Color(0.50, 0.56, 0.70)]
    var crowns = [
        [Vector3(-1.9, 6.0, 0.0), Vector3(1.8, 0.8, 1.3), 0],
        [Vector3(1.8, 6.2, -0.2), Vector3(1.7, 0.9, 1.4), 1],
        [Vector3(0.0, 6.8, 1.4), Vector3(1.5, 0.8, 1.2), 2],
        [Vector3(0.1, 7.0, -1.1), Vector3(1.6, 0.7, 1.1), 0]
    ]
    for data in crowns:
        var canopy := MeshInstance3D.new()
        var mesh := SphereMesh.new()
        mesh.radius = 1.0
        mesh.height = 2.0
        mesh.radial_segments = 7
        mesh.rings = 4
        mesh.material = _garden_material(blossom_colors[int(data[2])], false)
        canopy.mesh = mesh
        canopy.position = data[0]
        canopy.scale = data[1]
        body.add_child(canopy)

func _build_pampin_vines(pos: Vector3, length: float, yaw: float = 0.0) -> void:
    var root := Node3D.new()
    root.name = "PampinTrellis"
    root.position = pos
    root.rotation_degrees.y = yaw
    add_child(root)

    var beam_mat := _garden_material(Color(0.22, 0.14, 0.085), false)
    _box_visual(root, Vector3(length * 0.5, 3.45, 0), Vector3(length, 0.20, 0.22), beam_mat)
    _box_visual(root, Vector3(0, 1.75, 0), Vector3(0.18, 3.5, 0.18), beam_mat)
    _box_visual(root, Vector3(length, 1.75, 0), Vector3(0.18, 3.5, 0.18), beam_mat)

    for i in range(12):
        var strand := Node3D.new()
        strand.position = Vector3(0.35 + float(i) * (length - 0.7) / 11.0, 3.32, 0)
        root.add_child(strand)
        _pampin_strands.append(strand)

        var vine_mat := _garden_material(Color(0.16, 0.40, 0.23), false)
        _cylinder_visual(strand, Vector3(0, -0.85, 0), 0.035, 0.065, 1.7 + 0.16 * float(i % 3), vine_mat)
        for j in range(3):
            var leaf := MeshInstance3D.new()
            var leaf_mesh := SphereMesh.new()
            leaf_mesh.radius = 0.11
            leaf_mesh.height = 0.18
            leaf_mesh.radial_segments = 5
            leaf_mesh.rings = 3
            leaf_mesh.material = _garden_material(Color(0.25, 0.48, 0.28), false)
            leaf.mesh = leaf_mesh
            leaf.position = Vector3(0.10 if j % 2 == 0 else -0.10, -0.45 - float(j) * 0.42, 0)
            leaf.scale = Vector3(1.8, 0.7, 0.7)
            strand.add_child(leaf)

func _flora_fontis(pos: Vector3, blooming: bool = false) -> void:
    var root := Node3D.new()
    root.name = "FloraFontisBloom" if blooming else "FloraFontis"
    root.position = pos
    add_child(root)

    var stem_mat := _garden_material(Color(0.18, 0.27, 0.16), false)
    var bloom_mat := _garden_material(Color(0.38, 0.19, 0.33), false)
    _cylinder_visual(root, Vector3(0, 0.32, 0), 0.035, 0.055, 0.64, stem_mat)

    var bud := MeshInstance3D.new()
    var bud_mesh := SphereMesh.new()
    bud_mesh.radius = 0.17 if blooming else 0.12
    bud_mesh.height = 0.28 if blooming else 0.20
    bud_mesh.radial_segments = 7
    bud_mesh.rings = 4
    bud_mesh.material = bloom_mat
    bud.mesh = bud_mesh
    bud.position = Vector3(0, 0.68, 0)
    root.add_child(bud)

    if blooming:
        for i in range(3):
            var halo := MeshInstance3D.new()
            var halo_mesh := SphereMesh.new()
            halo_mesh.radius = 0.32 + float(i) * 0.18
            halo_mesh.height = 0.08
            halo_mesh.radial_segments = 10
            halo_mesh.rings = 3
            halo_mesh.material = _garden_material(Color(0.73, 0.38, 0.72), true)
            halo.mesh = halo_mesh
            halo.position = Vector3(0, 0.71 + float(i) * 0.025, 0)
            halo.scale = Vector3(1.0, 0.16, 1.0)
            root.add_child(halo)

func _tamdin_plant(pos: Vector3, color: Color, scale_factor: float, variant: int) -> void:
    var body := StaticBody3D.new()
    body.name = "TamdinCoral"
    body.position = pos
    add_child(body)

    var flesh := _garden_material(color, false)
    var bone := _garden_material(Color(0.72, 0.66, 0.55), false)

    var trunk_height := (2.3 + float(variant) * 0.35) * scale_factor
    _cylinder_visual(body, Vector3(0, trunk_height * 0.5, 0), 0.20 * scale_factor, 0.38 * scale_factor, trunk_height, flesh, Vector3(0, 0, -4 + variant * 3))

    var branch_data = [
        [Vector3(-0.55, 1.75, 0.0) * scale_factor, 1.55 * scale_factor, Vector3(0, 0, -48)],
        [Vector3(0.58, 1.95, 0.15) * scale_factor, 1.45 * scale_factor, Vector3(12, 0, 52)],
        [Vector3(0.10, 2.35, -0.28) * scale_factor, 1.20 * scale_factor, Vector3(-34, 0, 5)]
    ]
    if variant == 1:
        branch_data.append([Vector3(-0.15, 1.25, 0.52) * scale_factor, 1.10 * scale_factor, Vector3(58, 0, -12)])
    elif variant == 2:
        branch_data.append([Vector3(0.20, 2.65, 0.20) * scale_factor, 1.35 * scale_factor, Vector3(20, 0, 22)])

    for data in branch_data:
        _cylinder_visual(body, data[0], 0.11 * scale_factor, 0.20 * scale_factor, float(data[1]), flesh, data[2])
        var bone_tip := MeshInstance3D.new()
        var bone_mesh := SphereMesh.new()
        bone_mesh.radius = 0.10 * scale_factor
        bone_mesh.height = 0.26 * scale_factor
        bone_mesh.radial_segments = 5
        bone_mesh.rings = 3
        bone_mesh.material = bone
        bone_tip.mesh = bone_mesh
        bone_tip.position = data[0] + Vector3(0, 0.42 * scale_factor, 0)
        body.add_child(bone_tip)

    var shape := CylinderShape3D.new()
    shape.radius = 0.48 * scale_factor
    shape.height = min(trunk_height, 3.2)
    var collision := CollisionShape3D.new()
    collision.shape = shape
    collision.position.y = shape.height * 0.5
    body.add_child(collision)

func _tamdin_humanoid(pos: Vector3, color: Color, scale_factor: float) -> void:
    var body := StaticBody3D.new()
    body.name = "TamdinHumanoidGrowth"
    body.position = pos
    add_child(body)

    var flesh := _garden_material(color, false)
    var bone := _garden_material(Color(0.76, 0.69, 0.56), false)
    _cylinder_visual(body, Vector3(0, 1.45, 0) * scale_factor, 0.23, 0.40, 2.9 * scale_factor, flesh, Vector3(0, 0, 4))
    _cylinder_visual(body, Vector3(-0.68, 2.05, 0) * scale_factor, 0.13, 0.22, 1.7 * scale_factor, flesh, Vector3(0, 0, -64))
    _cylinder_visual(body, Vector3(0.68, 2.00, 0) * scale_factor, 0.13, 0.22, 1.65 * scale_factor, flesh, Vector3(0, 0, 61))
    _cylinder_visual(body, Vector3(-0.27, 0.55, 0) * scale_factor, 0.13, 0.22, 1.3 * scale_factor, flesh, Vector3(0, 0, -13))
    _cylinder_visual(body, Vector3(0.27, 0.55, 0) * scale_factor, 0.13, 0.22, 1.3 * scale_factor, flesh, Vector3(0, 0, 13))

    var head := MeshInstance3D.new()
    var head_mesh := SphereMesh.new()
    head_mesh.radius = 0.38 * scale_factor
    head_mesh.height = 0.72 * scale_factor
    head_mesh.radial_segments = 7
    head_mesh.rings = 4
    head_mesh.material = flesh
    head.mesh = head_mesh
    head.position = Vector3(0.03, 3.05, 0) * scale_factor
    head.scale = Vector3(0.75, 1.35, 0.72)
    body.add_child(head)

    _cylinder_visual(body, Vector3(0.0, 1.55, -0.25) * scale_factor, 0.05, 0.07, 1.7 * scale_factor, bone, Vector3.ZERO)

    var shape := CylinderShape3D.new()
    shape.radius = 0.52 * scale_factor
    shape.height = 2.9 * scale_factor
    var collision := CollisionShape3D.new()
    collision.shape = shape
    collision.position.y = 1.45 * scale_factor
    body.add_child(collision)

func _garden_material(color: Color, emissive: bool) -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.93
    if emissive:
        mat.emission_enabled = true
        mat.emission = color
        mat.emission_energy_multiplier = 2.0
    return mat

func _cylinder_visual(parent: Node3D, pos: Vector3, top_radius: float, bottom_radius: float, height: float, material: Material, rot: Vector3 = Vector3.ZERO) -> void:
    var visual := MeshInstance3D.new()
    var mesh := CylinderMesh.new()
    mesh.top_radius = top_radius
    mesh.bottom_radius = bottom_radius
    mesh.height = height
    mesh.radial_segments = 7
    mesh.material = material
    visual.mesh = mesh
    visual.position = pos
    visual.rotation_degrees = rot
    parent.add_child(visual)

func _box_visual(parent: Node3D, pos: Vector3, size: Vector3, material: Material) -> void:
    var visual := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    mesh.material = material
    visual.mesh = mesh
    visual.position = pos
    parent.add_child(visual)
