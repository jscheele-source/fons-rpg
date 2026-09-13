extends Node3D

const NPC = preload("res://scripts/npc.gd")
const PICKUP = preload("res://scripts/pickup.gd")
const LORE = preload("res://scripts/lore_object.gd")
const DUMMY = preload("res://scripts/training_dummy.gd")
const TRAVEL = preload("res://scripts/travel_marker.gd")
const RITUAL = preload("res://scripts/ritual_object.gd")

func _ready() -> void:
    _build_world()

func _build_world() -> void:
    _box("Ground", Vector3(0, -0.45, 0), Vector3(100, 0.8, 100), Color(0.22, 0.18, 0.18), false)
    _box("CourtyardStone", Vector3(0, 0.03, 3), Vector3(30, 0.18, 28), Color(0.42, 0.38, 0.36), false)

    _box("NorthWall", Vector3(0, 3.0, -10), Vector3(28, 6, 1.1), Color(0.30, 0.27, 0.28))
    _box("WestWall", Vector3(-14, 3.0, 1.5), Vector3(1.1, 6, 24), Color(0.30, 0.27, 0.28))
    _box("EastWall", Vector3(14, 3.0, 1.5), Vector3(1.1, 6, 24), Color(0.30, 0.27, 0.28))
    _box("ArchiveWing", Vector3(-9.5, 1.75, -6.5), Vector3(7.5, 3.5, 5), Color(0.27, 0.25, 0.28))
    _box("MeditationWing", Vector3(9.0, 1.75, -6.5), Vector3(7, 3.5, 5), Color(0.27, 0.25, 0.28))

    for x in [-11.0, -7.0, -3.0, 3.0, 7.0, 11.0]:
        _column(Vector3(x, 2.2, -2.2), Color(0.48, 0.43, 0.40))

    _box("MachinePad", Vector3(8.5, 0.35, 7.5), Vector3(7, 0.6, 6), Color(0.16, 0.18, 0.21), false)
    _box("Generator", Vector3(9.5, 1.2, 7.5), Vector3(2.4, 2.4, 2.4), Color(0.10, 0.22, 0.28))
    _box("CrateA", Vector3(6.7, 0.65, 7.0), Vector3(1.2, 1.2, 1.2), Color(0.28, 0.24, 0.19))
    _box("CrateB", Vector3(7.4, 0.65, 8.4), Vector3(1.2, 1.2, 1.2), Color(0.28, 0.24, 0.19))

    _box("AnnexFloor", Vector3(34, 0.15, -5), Vector3(18, 0.3, 18), Color(0.16, 0.18, 0.20), false)
    _box("AnnexNorth", Vector3(34, 2.5, -13.5), Vector3(18, 5, 1), Color(0.12, 0.15, 0.18))
    _box("AnnexEast", Vector3(42.5, 2.5, -5), Vector3(1, 5, 18), Color(0.12, 0.15, 0.18))
    _box("AnnexSouthA", Vector3(29.0, 2.5, 3.5), Vector3(8, 5, 1), Color(0.12, 0.15, 0.18))
    _box("AnnexSouthB", Vector3(39.5, 2.5, 3.5), Vector3(6, 5, 1), Color(0.12, 0.15, 0.18))
    _box("AnnexWestA", Vector3(25.5, 2.5, -10.0), Vector3(1, 5, 7), Color(0.12, 0.15, 0.18))
    _box("AnnexWestB", Vector3(25.5, 2.5, 0.0), Vector3(1, 5, 7), Color(0.12, 0.15, 0.18))

    _spawn_npc("Preceptor Varro", "varro", Vector3(0.0, 0, -5.0), Color(0.36, 0.28, 0.25))
    _spawn_npc("Brother Cael", "cael", Vector3(-2.5, 0, 3.0), Color(0.58, 0.34, 0.16))
    _spawn_npc("Sera Nemm", "sera", Vector3(8.0, 0, 10.5), Color(0.18, 0.48, 0.42))
    _spawn_npc("Initiate Kes", "novice", Vector3(-7.5, 0, 5.5), Color(0.36, 0.40, 0.55))

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
        core.item_color = Color(0.78, 0.73, 1.0)
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
    marker_b.marker_color = Color(0.52, 0.31, 0.60)
    add_child(marker_b)

    for p in [Vector3(-11,0,11), Vector3(-10,0,5), Vector3(11,0,3), Vector3(4,0,-7), Vector3(-5,0,-7)]:
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
    mat.roughness = 0.9
    mesh.material = mat
    mesh_instance.mesh = mesh
    body.add_child(mesh_instance)
    if collision_enabled or node_name in ["Ground", "CourtyardStone", "AnnexFloor", "MachinePad"]:
        var shape := BoxShape3D.new(); shape.size = size
        var collision := CollisionShape3D.new(); collision.shape = shape
        body.add_child(collision)
    add_child(body)

func _column(pos: Vector3, color: Color) -> void:
    var body := StaticBody3D.new(); body.position = pos
    var mesh_instance := MeshInstance3D.new()
    var mesh := CylinderMesh.new(); mesh.top_radius = 0.45; mesh.bottom_radius = 0.58; mesh.height = 4.4
    var mat := StandardMaterial3D.new(); mat.albedo_color = color; mat.roughness = 0.95; mesh.material = mat
    mesh_instance.mesh = mesh; body.add_child(mesh_instance)
    var shape := CylinderShape3D.new(); shape.radius = 0.58; shape.height = 4.4
    var collision := CollisionShape3D.new(); collision.shape = shape; body.add_child(collision)
    add_child(body)

func _alien_plant(pos: Vector3) -> void:
    var root := Node3D.new(); root.position = pos; add_child(root)
    for i in range(3):
        var mesh_instance := MeshInstance3D.new()
        var mesh := SphereMesh.new(); mesh.radius = 0.28 + i * 0.11; mesh.height = (0.28 + i * 0.11) * 2
        var mat := StandardMaterial3D.new(); mat.albedo_color = Color(0.34 + i*0.06, 0.18, 0.40 + i*0.04); mat.roughness = 0.75; mesh.material = mat
        mesh_instance.mesh = mesh
        mesh_instance.position = Vector3((i-1)*0.28, 0.25 + i*0.22, (i%2)*0.16)
        root.add_child(mesh_instance)
