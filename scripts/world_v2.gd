extends "res://scripts/world.gd"

const NPC_V2 = preload("res://scripts/npc_v2.gd")

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

    # Leave a five-meter opening centered at z=4.5.
    _box("WestWallNorth", Vector3(-14.7, 3.7, -4.5), Vector3(1.4, 7.4, 13.0), STONE_DARK)
    _box("WestWallSouth", Vector3(-14.7, 3.7, 10.5), Vector3(1.4, 7.4, 7.0), STONE_DARK)

    # Framed threshold into the garden.
    _box("GardenGateNorthPier", Vector3(-14.7, 2.2, 1.55), Vector3(1.65, 4.4, 0.72), STONE_PALE)
    _box("GardenGateSouthPier", Vector3(-14.7, 2.2, 7.45), Vector3(1.65, 4.4, 0.72), STONE_PALE)
    _box("GardenGateLintel", Vector3(-14.7, 4.35, 4.5), Vector3(1.65, 0.75, 6.6), STONE_PALE)
    _box("GardenThreshold", Vector3(-16.1, 0.04, 4.5), Vector3(3.5, 0.16, 5.2), STONE_MID, false)

func _build_west_garden() -> void:
    var center := Vector3(-24.3, 0.0, 4.7)
    _box("WestGardenFloor", center + Vector3(0, 0.02, 0), Vector3(17.8, 0.16, 18.6), STONE_MID.darkened(0.08), false)

    _box("WestGardenWall", Vector3(-33.2, 3.0, 4.7), Vector3(1.1, 6.0, 18.6), STONE_DARK)
    _box("WestGardenNorthWall", Vector3(-24.3, 3.0, -4.6), Vector3(17.8, 6.0, 1.1), STONE_DARK)
    _box("WestGardenSouthWall", Vector3(-24.3, 3.0, 14.0), Vector3(17.8, 6.0, 1.1), STONE_DARK)

    # A loose peristyle along the outer wall keeps the space monastic rather than park-like.
    for z in [-2.2, 1.2, 4.6, 8.0, 11.4]:
        _column(Vector3(-31.0, 2.45, z), STONE_PALE.darkened(0.03))

    _build_eytelia_tree(Vector3(-24.8, 0.0, 4.4))
    _build_pampin_vines(Vector3(-29.2, 0.0, -2.7), 8.7)
    _build_pampin_vines(Vector3(-29.2, 0.0, 11.8), 8.7)

    # Flora fontis patches: the native Iustitian life among imported garden cuttings.
    for p in [
        Vector3(-20.0, 0.0, -1.4), Vector3(-18.8, 0.0, 1.0), Vector3(-20.3, 0.0, 10.0),
        Vector3(-27.7, 0.0, 9.4), Vector3(-27.9, 0.0, -0.6), Vector3(-22.0, 0.0, 12.0)
    ]:
        _flora_fontis(p)

    # A few ordinary imported plants keep the garden from reading as a shrine display.
    _alien_plant(Vector3(-18.8, 0, 6.8))
    _alien_plant(Vector3(-29.2, 0, 5.5))

func _build_eytelia_tree(pos: Vector3) -> void:
    var body := StaticBody3D.new()
    body.name = "EyteliaTree"
    body.position = pos
    add_child(body)

    var trunk_mesh := CylinderMesh.new()
    trunk_mesh.top_radius = 0.38
    trunk_mesh.bottom_radius = 0.64
    trunk_mesh.height = 4.8
    trunk_mesh.radial_segments = 7
    var trunk_mat := StandardMaterial3D.new()
    trunk_mat.albedo_color = Color(0.25, 0.16, 0.09)
    trunk_mat.roughness = 1.0
    trunk_mesh.material = trunk_mat
    var trunk := MeshInstance3D.new()
    trunk.mesh = trunk_mesh
    trunk.position.y = 2.4
    trunk.rotation_degrees.z = -4.0
    body.add_child(trunk)

    var trunk_shape := CylinderShape3D.new()
    trunk_shape.radius = 0.64
    trunk_shape.height = 4.8
    var collision := CollisionShape3D.new()
    collision.shape = trunk_shape
    collision.position.y = 2.4
    body.add_child(collision)

    for data in [
        [Vector3(-1.35, 4.25, 0.2), Vector3(2.1, 1.2, 1.6)],
        [Vector3(1.25, 4.55, -0.4), Vector3(1.9, 1.3, 1.7)],
        [Vector3(0.2, 5.25, 0.6), Vector3(2.35, 1.25, 1.9)],
        [Vector3(-0.3, 4.7, -1.1), Vector3(1.7, 1.0, 1.45)]
    ]:
        var canopy := MeshInstance3D.new()
        var mesh := SphereMesh.new()
        mesh.radius = 1.0
        mesh.height = 2.0
        mesh.radial_segments = 7
        mesh.rings = 4
        var mat := StandardMaterial3D.new()
        mat.albedo_color = Color(0.18, 0.29, 0.16)
        mat.roughness = 1.0
        mesh.material = mat
        canopy.mesh = mesh
        canopy.position = data[0]
        canopy.scale = data[1]
        body.add_child(canopy)

func _build_pampin_vines(pos: Vector3, length: float) -> void:
    var root := Node3D.new()
    root.position = pos
    add_child(root)

    _box("PampinBeam", pos + Vector3(length * 0.5, 2.9, 0), Vector3(length, 0.18, 0.20), Color(0.21, 0.15, 0.09))
    for i in range(8):
        var x := 0.45 + float(i) * (length - 0.9) / 7.0
        var vine := MeshInstance3D.new()
        var mesh := CylinderMesh.new()
        mesh.top_radius = 0.035
        mesh.bottom_radius = 0.055
        mesh.height = 1.5 + 0.22 * sin(float(i) * 1.7)
        mesh.radial_segments = 6
        var mat := StandardMaterial3D.new()
        mat.albedo_color = Color(0.20, 0.34, 0.16)
        mat.roughness = 1.0
        mesh.material = mat
        vine.mesh = mesh
        vine.position = Vector3(x, 2.15, 0)
        vine.rotation_degrees.z = -5.0 + float(i % 3) * 5.0
        root.add_child(vine)

func _flora_fontis(pos: Vector3) -> void:
    var root := Node3D.new()
    root.position = pos
    add_child(root)
    for i in range(4):
        var stalk := MeshInstance3D.new()
        var stalk_mesh := CylinderMesh.new()
        stalk_mesh.top_radius = 0.035
        stalk_mesh.bottom_radius = 0.05
        stalk_mesh.height = 0.42 + float(i) * 0.06
        stalk_mesh.radial_segments = 5
        var stalk_mat := StandardMaterial3D.new()
        stalk_mat.albedo_color = Color(0.20, 0.26, 0.15)
        stalk_mesh.material = stalk_mat
        stalk.mesh = stalk_mesh
        stalk.position = Vector3(-0.18 + i * 0.12, 0.22 + i * 0.02, 0.04 * (i % 2))
        root.add_child(stalk)

        var bloom := MeshInstance3D.new()
        var bloom_mesh := SphereMesh.new()
        bloom_mesh.radius = 0.12
        bloom_mesh.height = 0.20
        bloom_mesh.radial_segments = 6
        bloom_mesh.rings = 3
        var bloom_mat := StandardMaterial3D.new()
        bloom_mat.albedo_color = Color(0.52, 0.27, 0.40)
        bloom_mat.emission_enabled = true
        bloom_mat.emission = Color(0.36, 0.16, 0.30)
        bloom_mat.emission_energy_multiplier = 0.75
        bloom_mesh.material = bloom_mat
        bloom.mesh = bloom_mesh
        bloom.position = stalk.position + Vector3(0, 0.28, 0)
        root.add_child(bloom)
