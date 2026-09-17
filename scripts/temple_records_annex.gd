extends Node3D

const TRANSITION = preload("res://scripts/interior_transition.gd")
const DOCTRINE = preload("res://scripts/vesper_doctrine_clue.gd")
const LORE = preload("res://scripts/lore_object.gd")

const ANNEX := Vector3(-176.0, 0.0, -24.0)
const STONE := Color(0.15, 0.14, 0.13)
const FLOOR := Color(0.21, 0.19, 0.17)
const WOOD := Color(0.22, 0.14, 0.085)
const BLUE_WOOD := Color(0.12, 0.19, 0.24)

func _ready() -> void:
    _build_scriptorium_access()
    _build_annex()

func _build_scriptorium_access() -> void:
    var stair = TRANSITION.new()
    stair.name = "LowerRecordsStair"
    stair.position = Vector3(-82.75, 0.10, -26.0)
    stair.rotation_degrees.y = 90.0
    stair.display_name = "lower records stair"
    stair.prompt = "Descend"
    stair.destination = ANNEX + Vector3(0, 1.25, 3.7)
    stair.arrival_yaw = 3.14159
    stair.panel_color = BLUE_WOOD
    stair.message = "A narrow blue-wood door opens onto stairs descending into older records rooms."
    add_child(stair)

func _build_annex() -> void:
    var root := Node3D.new()
    root.name = "LowerRecordsAnnex"
    add_child(root)

    _box(root, "Floor", ANNEX + Vector3(0, 0.02, 0), Vector3(14.0, 0.16, 10.0), FLOOR, true)
    _box(root, "Ceiling", ANNEX + Vector3(0, 4.45, 0), Vector3(14.0, 0.24, 10.0), STONE, true)
    _box(root, "WestWall", ANNEX + Vector3(-6.9, 2.2, 0), Vector3(0.35, 4.4, 10.0), STONE, true)
    _box(root, "EastWall", ANNEX + Vector3(6.9, 2.2, 0), Vector3(0.35, 4.4, 10.0), STONE, true)
    _box(root, "NorthWall", ANNEX + Vector3(0, 2.2, -4.9), Vector3(14.0, 4.4, 0.35), STONE, true)
    _box(root, "SouthWall", ANNEX + Vector3(0, 2.2, 4.9), Vector3(14.0, 4.4, 0.35), STONE, true)

    for x in [-4.8, 0.0, 4.8]:
        _shelf(root, ANNEX + Vector3(float(x), 0.0, -3.9))
    for x in [-4.8, 4.8]:
        _shelf(root, ANNEX + Vector3(float(x), 0.0, 3.25))

    _table(root, ANNEX + Vector3(0, 0, 0.2))
    _box(root, "RestrictionScreen", ANNEX + Vector3(0, 2.0, -4.65), Vector3(4.2, 1.55, 0.10), BLUE_WOOD, false)

    var doctrine = DOCTRINE.new()
    doctrine.name = "VesperDoctrineFragment"
    doctrine.position = ANNEX + Vector3(-0.55, 1.02, 0.1)
    root.add_child(doctrine)

    var register = LORE.new()
    register.title = "Restricted Records Register"
    register.prompt = "Read"
    register.object_color = Color(0.17, 0.12, 0.08)
    register.body = "Several entries are marked SEALED AFTER SCHISM. One recurring notation appears beside confiscated Vesper texts: donor instability after channel onset. A later archivist has written in the margin: [i]Voluntary transfer does not remain voluntary if the channel cannot be ended by the donor.[/i]"
    register.position = ANNEX + Vector3(1.2, 0.98, 0.1)
    root.add_child(register)

    var return_stair = TRANSITION.new()
    return_stair.name = "ReturnToScriptorium"
    return_stair.position = ANNEX + Vector3(0, 0.10, 4.58)
    return_stair.display_name = "stair to the scriptorium"
    return_stair.prompt = "Ascend"
    return_stair.destination = Vector3(-83.6, 1.25, -26.0)
    return_stair.arrival_yaw = -1.5708
    return_stair.panel_color = BLUE_WOOD
    return_stair.message = "You climb back into the working scriptorium."
    root.add_child(return_stair)

    var light := OmniLight3D.new()
    light.position = ANNEX + Vector3(0, 3.35, 0)
    light.light_color = Color(0.82, 0.60, 0.38)
    light.light_energy = 1.7
    light.omni_range = 11.0
    root.add_child(light)

func _shelf(root: Node3D, pos: Vector3) -> void:
    _box(root, "ShelfBack", pos + Vector3(0, 1.35, 0.28), Vector3(3.2, 2.7, 0.20), WOOD, true)
    for y in [0.30, 0.93, 1.56, 2.19]:
        _box(root, "ShelfBoard", pos + Vector3(0, y, 0), Vector3(3.2, 0.10, 0.72), WOOD, true)

func _table(root: Node3D, pos: Vector3) -> void:
    _box(root, "ReadingTable", pos + Vector3(0, 0.92, 0), Vector3(4.5, 0.18, 1.5), WOOD, true)
    for x in [-1.8, 1.8]:
        for z in [-0.48, 0.48]:
            _box(root, "TableLeg", pos + Vector3(float(x), 0.45, float(z)), Vector3(0.18, 0.9, 0.18), WOOD, true)

func _box(root: Node3D, name_text: String, pos: Vector3, size: Vector3, color: Color, collision_enabled: bool) -> void:
    var node: Node3D = StaticBody3D.new() if collision_enabled else Node3D.new()
    node.name = name_text
    node.position = pos
    var mesh := BoxMesh.new()
    mesh.size = size
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.95
    mesh.material = mat
    var visual := MeshInstance3D.new()
    visual.mesh = mesh
    node.add_child(visual)
    if collision_enabled:
        var shape := BoxShape3D.new()
        shape.size = size
        var collision := CollisionShape3D.new()
        collision.shape = shape
        node.add_child(collision)
    root.add_child(node)
