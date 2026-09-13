extends Node3D

const NPC = preload("res://scripts/npc.gd")
const PICKUP = preload("res://scripts/pickup.gd")
const LORE = preload("res://scripts/lore_object.gd")
const DUMMY = preload("res://scripts/training_dummy.gd")
const TRAVEL = preload("res://scripts/travel_marker.gd")
const RITUAL = preload("res://scripts/ritual_object.gd")

const STONE_DARK := Color(0.19, 0.18, 0.16)
const STONE_MID := Color(0.31, 0.29, 0.25)
const STONE_PALE := Color(0.43, 0.39, 0.32)
const ASH := Color(0.24, 0.23, 0.20)
const OCHRE := Color(0.38, 0.27, 0.15)
const MACHINE := Color(0.12, 0.16, 0.16)

func _ready() -> void:
    if bool(GameState.world_flags.get("load_on_start", false)):
        GameState.load_game($Player)
        GameState.world_flags["load_on_start"] = false
    _build_world()

func _build_world() -> void:
    # Iustitia is rock, cloud and old stone. Nothing here should feel clean.
    _box("Ground", Vector3(0, -0.55, 0), Vector3(120, 1.0, 120), ASH, false)
    _box("CourtyardStone", Vector3(0, 0.02, 3), Vector3(30, 0.16, 28), STONE_MID, false)

    # Broken paving gives the court a hand-built, weathered rhythm.
    for x in [-10.5, -7.0, -3.5, 0.0, 3.5, 7.0, 10.5]:
        for z in [-6.5, -2.5, 1.5, 5.5, 9.5]:
            var lift: float = 0.10 + abs(sin(x * 0.31 + z * 0.17)) * 0.035
            _box("Paver", Vector3(x, lift, z), Vector3(3.0, 0.10, 3.2), STONE_PALE.darkened(0.08), false)

    # Outer monastery shell: heavy and slightly too tall for comfort.
    _box("NorthWall", Vector3(0, 4.0, -10.5), Vector3(30, 8, 1.4), STONE_DARK)
    _box("WestWall", Vector3(-14.7, 3.7, 1.5), Vector3(1.4, 7.4, 25), STONE_DARK)
    _box("EastWall", Vector3(14.7, 3.7, 1.5), Vector3(1.4, 7.4, 25), STONE_DARK)
    _box("ArchiveWing", Vector3(-9.7, 2.1, -6.8), Vector3(7.8, 4.2, 5.3), Color(0.24, 0.23, 0.21))
    _box("MeditationWing", Vector3(9.2, 2.1, -6.8), Vector3(7.4, 4.2, 5.3), Color(0.24, 0.23, 0.21))

    _stone_arch(Vector3(0, 0, -9.8), 4.1, 5.7)
    _box("NorthButtressL", Vector3(-12.3, 3.0, -9.5), Vector3(2.0, 6.0, 3.0), STONE_MID)
    _box("NorthButtressR", Vector3(12.3, 3.0, -9.5), Vector3(2.0, 6.0, 3.0), STONE_MID)

    for x in [-11.2, -7.3, -3.4, 3.4, 7.3, 11.2]:
        _column(Vector3(x, 2.45, -1.8), STONE_PALE)

    _banner(Vector3(-6.9, 3.4, -9.72), Vector3(1.2, 3.2, 0.09), Color(0.31, 0.12, 0.08))
    _banner(Vector3(6.9, 3.4, -9.72), Vector3(1.2, 3.2, 0.09), Color(0.31, 0.12, 0.08))

    # Machines occupy sacred space awkwardly, as if no one agreed where they belonged.
    _box("MachinePad", Vector3(8.5, 0.30, 7.5), Vector3(7.4, 0.5, 6.2), Color(0.15, 0.15, 0.14), false)
    _machine_box("Generator", Vector3(9.6, 1.15, 7.4), Vector3(2.5, 2.2, 2.2))
    _machine_box("RelayA", Vector3(11.2, 0.85, 6.0), Vector3(0.8, 1.5, 1.0))
    _box("CrateA", Vector3(6.5, 0.65, 7.0), Vector3(1.3, 1.2, 1.3), OCHRE)
    _box("CrateB", Vector3(7.3, 0.65, 8.6), Vector3(1.3, 1.2, 1.3), OCHRE.darkened(0.12))

    _brazier(Vector3(-5.8, 0, -5.6))
    _brazier(Vector3(5.8, 0, -5.6))

    # Annex: visibly newer, but still weathered and low-tech in silhouette.
    _box("AnnexFloor", Vector3(34, 0.15, -5), Vector3(18, 0.3, 18), Color(0.14, 0.15, 0.14), false)
    _box("AnnexNorth", Vector3(34, 2.5, -13.5), Vector3(18, 5, 1), MACHINE)
    _box("AnnexEast", Vector3(42.5, 2.5, -5), Vector3(1, 5, 18), MACHINE)
    _box("AnnexSouthA", Vector3(29.0, 2.5, 3.5), Vector3(8, 5, 1), MACHINE)
    _box("AnnexSouthB", Vector3(39.5, 2.5, 3.5), Vector3(6, 5, 1), MACHINE)
    _box("AnnexWestA", Vector3(25.5, 2.5, -10.0), Vector3(1, 5, 7), MACHINE)
    _box("AnnexWestB", Vector3(25.5, 2.5, 0.0), Vector3(1, 5, 7), MACHINE)
    _machine_box("AnnexConsoleBank", Vector3(39.0, 0.8, -10.5), Vector3(4.2, 1.4, 0.8))

    # Distant shapes vanish into cloud and make the monastery feel much larger than the playable cell.
    for p in [Vector3(-34, 3, -28), Vector3(30, 5, -38), Vector3(-42, 6, 20), Vector3(46, 4, 24)]:
        _distant_monolith(p)
    for data in [
        [Vector3(-18, 0.0, -19), Vector3(5.0, 6.0, 4.0)],
        [Vector3(19, 0.0, -22), Vector3(7.0, 8.0, 5.0)],
        [Vector3(-25, 0.0, 16), Vector3(8.0, 5.5, 7.0)],
        [Vector3(24, 0.0, 17), Vector3(6.0, 7.0, 5.0)],
    ]:
        _rock(data[0], data[1], Color(0.17, 0.17, 0.16))

    _spawn_npc("Preceptor Varro", "varro", Vector3(0.0, 0.10, -5.0), Color(0.30, 0.22, 0.16))
    _spawn_npc("Brother Cael", "cael", Vector3(-2.5, 0.10, 3.0), Color(0.43, 0.27, 0.12))
    _spawn_npc("Surveyor Nemm", "sera", Vector3(8.0, 0.10, 10.5), Color(0.18, 0.31, 0.28))
    _spawn_npc("Initiate Kes", "novice", Vector3(-7.5, 0.10, 5.5), Color(0.28, 0.29, 0.36))

    var bell = RITUAL.new()
    bell.position = Vector3(-10.8, 0, -5.5)
    add_child(bell)

    var dummy = DUMMY.new()
    dummy.position = Vector3(-8.5, 0, 8.0)
    add_child(dummy)

    var terminal = LORE.new()
    terminal.title = "Annex Terminal 3"
    terminal.prompt = "Access"
    terminal.body = "[b]Recovered fragment[/b]\n\nRESONANCE TEST 14: Output remains inconsistent. The core responds more strongly to living charge than to reactor current. Recommendation: suspend trials until ethical review.\n\nA later hand has added: [i]The distinction between relic and instrument is political, not physical.[/i]"
    terminal.position = Vector3(38.0, 0, -9.5)
    add_child(terminal)

    if GameState.quests.has("resonator_core") and not GameState.has_item("resonator_core") and GameState.quests["resonator_core"]["state"] != "completed":
        var core = PICKUP.new()
        core.item_id = "resonator_core"
        core.display_name = "Pneuma Resonator Core"
        core.description = "A humming sphere that responds to charged life and nearby machinery."
        core.item_color = Color(0.72, 0.63, 0.86)
        core.position = Vector3(34.0, 1.0, -5.0)
        add_child(core)

    var marker_a = TRAVEL.new()
    marker_a.display_name = "Annex Shuttle Marker"
    marker_a.destination = Vector3(30.0, 1.25, 1.0)
    marker_a.position = Vector3(12.0, 0, 13.0)
    add_child(marker_a)

    var marker_b = TRAVEL.new()
    marker_b.display_name = "Courtyard Shuttle Marker"
    marker_b.destination = Vector3(10.0, 1.25, 12.0)
    marker_b.position = Vector3(28.0, 0, 1.5)
    marker_b.marker_color = Color(0.43, 0.27, 0.48)
    add_child(marker_b)

    for p in [Vector3(-11,0,11), Vector3(-10,0,5), Vector3(11,0,3), Vector3(4,0,-7), Vector3(-5,0,-7), Vector3(12,0,-7)]:
        _alien_plant(p)

func _spawn_npc(name_text: String, id: String, pos: Vector3, color: Color) -> void:
    var npc = NPC.new()
    npc.display_name = name_text
    npc.dialogue_id = id
    npc.body_color = color
    npc.position = pos
    add_child(npc)

func _box(node_name: String, pos: Vector3, size: Vector3, color: Color, collision_enabled: bool = true) -> void:
    var body := StaticBody3D.new()
    body.name = node_name
    body.position = pos
    var mesh_instance := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.96
    mesh.material = mat
    mesh_instance.mesh = mesh
    body.add_child(mesh_instance)
    if collision_enabled or node_name in ["Ground", "CourtyardStone", "AnnexFloor", "MachinePad"]:
        var shape := BoxShape3D.new()
        shape.size = size
        var collision := CollisionShape3D.new()
        collision.shape = shape
        body.add_child(collision)
    add_child(body)

func _machine_box(node_name: String, pos: Vector3, size: Vector3) -> void:
    var body := StaticBody3D.new()
    body.name = node_name
    body.position = pos
    var mesh_instance := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    var mat := StandardMaterial3D.new()
    mat.albedo_color = MACHINE
    mat.metallic = 0.55
    mat.roughness = 0.62
    mesh.material = mat
    mesh_instance.mesh = mesh
    body.add_child(mesh_instance)
    var shape := BoxShape3D.new()
    shape.size = size
    var collision := CollisionShape3D.new()
    collision.shape = shape
    body.add_child(collision)
    add_child(body)

func _column(pos: Vector3, color: Color) -> void:
    var body := StaticBody3D.new()
    body.position = pos
    var mesh_instance := MeshInstance3D.new()
    var mesh := CylinderMesh.new()
    mesh.top_radius = 0.43
    mesh.bottom_radius = 0.62
    mesh.height = 4.9
    mesh.radial_segments = 8
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.98
    mesh.material = mat
    mesh_instance.mesh = mesh
    body.add_child(mesh_instance)
    var shape := CylinderShape3D.new()
    shape.radius = 0.62
    shape.height = 4.9
    var collision := CollisionShape3D.new()
    collision.shape = shape
    body.add_child(collision)
    add_child(body)

func _stone_arch(pos: Vector3, opening_width: float, opening_height: float) -> void:
    _box("ArchLeft", pos + Vector3(-opening_width * 0.68, opening_height * 0.42, 0), Vector3(1.5, opening_height, 1.8), STONE_PALE)
    _box("ArchRight", pos + Vector3(opening_width * 0.68, opening_height * 0.42, 0), Vector3(1.5, opening_height, 1.8), STONE_PALE)
    _box("ArchLintel", pos + Vector3(0, opening_height, 0), Vector3(opening_width + 3.0, 1.2, 1.8), STONE_PALE)

func _banner(pos: Vector3, size: Vector3, color: Color) -> void:
    var cloth := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 1.0
    mesh.material = mat
    cloth.mesh = mesh
    cloth.position = pos
    add_child(cloth)

func _brazier(pos: Vector3) -> void:
    var root := Node3D.new()
    root.position = pos
    add_child(root)

    var stand := MeshInstance3D.new()
    var stand_mesh := CylinderMesh.new()
    stand_mesh.top_radius = 0.12
    stand_mesh.bottom_radius = 0.18
    stand_mesh.height = 1.15
    stand_mesh.radial_segments = 6
    var iron := StandardMaterial3D.new()
    iron.albedo_color = Color(0.12, 0.10, 0.08)
    iron.metallic = 0.65
    iron.roughness = 0.7
    stand_mesh.material = iron
    stand.mesh = stand_mesh
    stand.position.y = 0.58
    root.add_child(stand)

    var bowl := MeshInstance3D.new()
    var bowl_mesh := CylinderMesh.new()
    bowl_mesh.top_radius = 0.48
    bowl_mesh.bottom_radius = 0.30
    bowl_mesh.height = 0.26
    bowl_mesh.radial_segments = 8
    bowl_mesh.material = iron
    bowl.mesh = bowl_mesh
    bowl.position.y = 1.18
    root.add_child(bowl)

    var flame := MeshInstance3D.new()
    var flame_mesh := CylinderMesh.new()
    flame_mesh.top_radius = 0.03
    flame_mesh.bottom_radius = 0.16
    flame_mesh.height = 0.62
    flame_mesh.radial_segments = 6
    var flame_mat := StandardMaterial3D.new()
    flame_mat.albedo_color = Color(0.86, 0.42, 0.12)
    flame_mat.emission_enabled = true
    flame_mat.emission = Color(0.88, 0.30, 0.08)
    flame_mat.emission_energy_multiplier = 2.0
    flame_mesh.material = flame_mat
    flame.mesh = flame_mesh
    flame.position.y = 1.53
    root.add_child(flame)

    var light := OmniLight3D.new()
    light.light_color = Color(1.0, 0.56, 0.27)
    light.light_energy = 2.0
    light.omni_range = 6.0
    light.position.y = 1.6
    root.add_child(light)

func _rock(pos: Vector3, rock_scale: Vector3, color: Color) -> void:
    var rock := MeshInstance3D.new()
    var mesh := SphereMesh.new()
    mesh.radius = 1.0
    mesh.height = 2.0
    mesh.radial_segments = 7
    mesh.rings = 4
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 1.0
    mesh.material = mat
    rock.mesh = mesh
    rock.position = pos + Vector3(0, rock_scale.y * 0.45, 0)
    rock.scale = rock_scale
    rock.rotation_degrees = Vector3(0, pos.x * 2.7, 8.0)
    add_child(rock)

func _distant_monolith(pos: Vector3) -> void:
    var monolith := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = Vector3(3.0, 11.0, 2.2)
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.14, 0.14, 0.13)
    mat.roughness = 1.0
    mesh.material = mat
    monolith.mesh = mesh
    monolith.position = pos
    monolith.rotation_degrees = Vector3(0, pos.z, -4.0 + fmod(abs(pos.x), 8.0))
    add_child(monolith)

func _alien_plant(pos: Vector3) -> void:
    var root := Node3D.new()
    root.position = pos
    add_child(root)

    for i in range(3):
        var stalk := MeshInstance3D.new()
        var stalk_mesh := CylinderMesh.new()
        stalk_mesh.top_radius = 0.08
        stalk_mesh.bottom_radius = 0.13
        stalk_mesh.height = 0.55 + i * 0.18
        stalk_mesh.radial_segments = 6
        var stalk_mat := StandardMaterial3D.new()
        stalk_mat.albedo_color = Color(0.19, 0.23 + i * 0.02, 0.14)
        stalk_mat.roughness = 1.0
        stalk_mesh.material = stalk_mat
        stalk.mesh = stalk_mesh
        stalk.position = Vector3((i - 1) * 0.24, 0.28 + i * 0.09, (i % 2) * 0.14)
        stalk.rotation_degrees.z = (i - 1) * 12.0
        root.add_child(stalk)

        var bulb := MeshInstance3D.new()
        var bulb_mesh := SphereMesh.new()
        bulb_mesh.radius = 0.18 + i * 0.035
        bulb_mesh.height = (0.18 + i * 0.035) * 2.0
        bulb_mesh.radial_segments = 7
        bulb_mesh.rings = 4
        var bulb_mat := StandardMaterial3D.new()
        bulb_mat.albedo_color = Color(0.39 + i * 0.04, 0.24, 0.31)
        bulb_mat.roughness = 0.82
        bulb_mesh.material = bulb_mat
        bulb.mesh = bulb_mesh
        bulb.position = stalk.position + Vector3(0, 0.36 + i * 0.08, 0)
        root.add_child(bulb)
