extends Node3D

const SUSPECT = preload("res://scripts/vesper_suspect.gd")
const CLUE = preload("res://scripts/vesper_archive_clue.gd")
const PANEL = preload("res://scripts/vesper_secret_panel.gd")
const RITUAL_NPC = preload("res://scripts/vesper_ritual_npc.gd")

const CHAMBER := Vector3(-155.0, 0.0, 0.0)
const DORM_RETURN := Vector3(-91.5, 1.25, 0.0)
const STONE := Color(0.145, 0.135, 0.125)
const STONE_PALE := Color(0.29, 0.255, 0.22)
const VESPER := Color(0.24, 0.13, 0.12)

func _ready() -> void:
    _spawn_investigation()
    _build_hidden_chamber()

func _spawn_investigation() -> void:
    var suspect = SUSPECT.new()
    suspect.name = "BrotherIlyon"
    suspect.position = Vector3(-94.9, 0.10, 4.4)
    suspect.rotation_degrees.y = 180.0
    add_child(suspect)

    var clue = CLUE.new()
    clue.name = "VesperServicePlan"
    clue.position = Vector3(-119.9, 1.05, 0.20)
    add_child(clue)

    var panel = PANEL.new()
    panel.name = "VesperDormitoryPanel"
    panel.position = Vector3(-90.25, 0.15, 0.0)
    panel.rotation_degrees.y = 90.0
    panel.destination = CHAMBER + Vector3(0, 1.25, 4.8)
    add_child(panel)

func _build_hidden_chamber() -> void:
    var root := Node3D.new()
    root.name = "HiddenVesperChamber"
    add_child(root)

    _box(root, "Floor", CHAMBER + Vector3(0, 0.02, 0), Vector3(12.0, 0.16, 12.0), STONE, true)
    _box(root, "Ceiling", CHAMBER + Vector3(0, 4.7, 0), Vector3(12.0, 0.24, 12.0), STONE, true)
    _box(root, "WestWall", CHAMBER + Vector3(-5.9, 2.35, 0), Vector3(0.35, 4.7, 12.0), STONE, true)
    _box(root, "EastWall", CHAMBER + Vector3(5.9, 2.35, 0), Vector3(0.35, 4.7, 12.0), STONE, true)
    _box(root, "NorthWall", CHAMBER + Vector3(0, 2.35, -5.9), Vector3(12.0, 4.7, 0.35), STONE, true)
    _box(root, "SouthWall", CHAMBER + Vector3(0, 2.35, 5.9), Vector3(12.0, 4.7, 0.35), STONE, true)
    _box(root, "RitualDais", CHAMBER + Vector3(0, 0.18, -1.0), Vector3(5.0, 0.28, 4.2), STONE_PALE, true)
    _box(root, "DrainChannel", CHAMBER + Vector3(0, 0.36, -1.0), Vector3(3.6, 0.10, 0.18), VESPER, false)
    _box(root, "OldRelief", CHAMBER + Vector3(0, 2.2, -5.68), Vector3(5.8, 2.2, 0.10), Color(0.20, 0.17, 0.15), false)

    for x in [-4.1, 4.1]:
        for z in [-3.7, 3.2]:
            _ember(root, CHAMBER + Vector3(float(x), 1.15, float(z)))

    var light := OmniLight3D.new()
    light.position = CHAMBER + Vector3(0, 2.7, -0.5)
    light.light_color = Color(0.78, 0.28, 0.16)
    light.light_energy = 2.1
    light.omni_range = 10.0
    root.add_child(light)

    var exit_panel = PANEL.new()
    exit_panel.name = "VesperReturnPanel"
    exit_panel.position = CHAMBER + Vector3(0, 0.15, 5.55)
    exit_panel.return_panel = true
    exit_panel.destination = DORM_RETURN
    root.add_child(exit_panel)

    var leader = RITUAL_NPC.new()
    leader.name = "VesperLeader"
    leader.role = "leader"
    leader.display_name = "Flamen Corvin"
    leader.body_color = Color(0.22, 0.12, 0.12)
    leader.position = CHAMBER + Vector3(0, 0.10, -3.35)
    root.add_child(leader)

    var acolyte = RITUAL_NPC.new()
    acolyte.name = "VesperAcolyte"
    acolyte.role = "acolyte"
    acolyte.display_name = "Brother Sael"
    acolyte.body_color = Color(0.24, 0.17, 0.16)
    acolyte.position = CHAMBER + Vector3(2.65, 0.10, -0.8)
    acolyte.rotation_degrees.y = -65.0
    root.add_child(acolyte)

    var initiate = RITUAL_NPC.new()
    initiate.name = "VesperInitiate"
    initiate.role = "initiate"
    initiate.display_name = "Initiate Mara"
    initiate.body_color = Color(0.30, 0.25, 0.21)
    initiate.position = CHAMBER + Vector3(0, 0.10, -0.55)
    initiate.rotation_degrees.y = 180.0
    root.add_child(initiate)

func _box(root: Node3D, name_text: String, pos: Vector3, size: Vector3, color: Color, collision_enabled: bool) -> void:
    var body := StaticBody3D.new() if collision_enabled else Node3D.new()
    body.name = name_text
    body.position = pos
    var mesh := BoxMesh.new()
    mesh.size = size
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.96
    mesh.material = mat
    var visual := MeshInstance3D.new()
    visual.mesh = mesh
    body.add_child(visual)
    if collision_enabled:
        var shape := BoxShape3D.new()
        shape.size = size
        var collision := CollisionShape3D.new()
        collision.shape = shape
        body.add_child(collision)
    root.add_child(body)

func _ember(root: Node3D, pos: Vector3) -> void:
    var pedestal := Node3D.new()
    pedestal.position = pos
    var mesh := SphereMesh.new()
    mesh.radius = 0.16
    mesh.height = 0.32
    mesh.radial_segments = 8
    mesh.rings = 4
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.60, 0.18, 0.08)
    mat.emission_enabled = true
    mat.emission = Color(0.72, 0.12, 0.04)
    mat.emission_energy_multiplier = 1.6
    mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    mesh.material = mat
    var visual := MeshInstance3D.new()
    visual.mesh = mesh
    pedestal.add_child(visual)
    root.add_child(pedestal)
