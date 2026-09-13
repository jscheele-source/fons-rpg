extends Node3D

const DOOR = preload("res://scripts/interior_door.gd")

const INTERIOR_ORIGIN := Vector3(-108.0, 0.0, 0.0)
const STONE_DARK := Color(0.155, 0.145, 0.13)
const STONE_MID := Color(0.255, 0.235, 0.20)
const STONE_PALE := Color(0.38, 0.34, 0.28)
const FLOOR := Color(0.205, 0.19, 0.165)
const WOOD := Color(0.24, 0.15, 0.085)
const CLOTH := Color(0.29, 0.20, 0.14)
const MACHINE := Color(0.10, 0.14, 0.145)
const BLUE_DOOR := Color(0.075, 0.12, 0.15)
const WARM := Color(1.0, 0.62, 0.30)

func _ready() -> void:
    _build_courtyard_entrance()
    var interior := Node3D.new()
    interior.name = "IustitiaMonasteryInterior"
    interior.position = INTERIOR_ORIGIN
    add_child(interior)
    _build_interior(interior)

func _build_courtyard_entrance() -> void:
    var entrance = DOOR.new()
    entrance.display_name = "Main Monastic Dwelling"
    entrance.position = Vector3(0.0, 0.0, -9.42)
    entrance.destination = INTERIOR_ORIGIN + Vector3(0.0, 1.25, 14.2)
    entrance.arrival_yaw = 0.0
    entrance.door_color = BLUE_DOOR
    entrance.travel_message = "The blue door parts with a low mechanical sigh."
    add_child(entrance)

func _build_interior(root: Node3D) -> void:
    # Entry hall: broad enough for processions, nearly empty in ordinary use.
    _room_floor(root, "EntryFloor", Vector3(0, 0.06, 13), Vector3(10, 0.12, 10))
    _ceiling(root, "EntryCeiling", Vector3(0, 4.9, 13), Vector3(10, 0.28, 10))
    _wall(root, "EntryWest", Vector3(-5, 2.45, 13), Vector3(0.45, 4.9, 10))
    _wall(root, "EntryEast", Vector3(5, 2.45, 13), Vector3(0.45, 4.9, 10))
    _wall(root, "EntrySouthL", Vector3(-3.35, 2.45, 18), Vector3(3.3, 4.9, 0.45))
    _wall(root, "EntrySouthR", Vector3(3.35, 2.45, 18), Vector3(3.3, 4.9, 0.45))
    _wall(root, "EntryNorthL", Vector3(-3.55, 2.45, 8), Vector3(2.9, 4.9, 0.45))
    _wall(root, "EntryNorthR", Vector3(3.55, 2.45, 8), Vector3(2.9, 4.9, 0.45))
    _interior_arch(root, Vector3(0, 0, 8.15), 4.1, 4.5)
    _brazier(root, Vector3(-3.3, 0, 10.4))
    _brazier(root, Vector3(3.3, 0, 10.4))
    _warm_light(root, Vector3(0, 3.7, 13), 1.9, 9.0)

    var exit_door = DOOR.new()
    exit_door.display_name = "Outer Courtyard"
    exit_door.position = Vector3(0, 0, 17.72)
    exit_door.destination = Vector3(0.0, 1.25, -6.7)
    exit_door.arrival_yaw = PI
    exit_door.door_color = BLUE_DOOR
    exit_door.travel_message = "Cold Iustitian air returns around you."
    root.add_child(exit_door)

    # Narrow central passage. The monastery is much larger than its population requires.
    _corridor_z(root, Vector3(0, 0, 5.0), 5.0, 6.0, true)

    # Junction hall connecting the older wings.
    _room_floor(root, "JunctionFloor", Vector3(0, 0.06, 0), Vector3(8, 0.12, 6))
    _ceiling(root, "JunctionCeiling", Vector3(0, 4.7, 0), Vector3(8, 0.28, 6))
    _corner_wall(root, Vector3(-3.8, 2.35, 2.75), Vector3(0.4, 4.7, 1.5))
    _corner_wall(root, Vector3(3.8, 2.35, 2.75), Vector3(0.4, 4.7, 1.5))
    _corner_wall(root, Vector3(-3.8, 2.35, -2.75), Vector3(0.4, 4.7, 1.5))
    _corner_wall(root, Vector3(3.8, 2.35, -2.75), Vector3(0.4, 4.7, 1.5))
    _warm_light(root, Vector3(0, 3.6, 0), 1.25, 8.0)

    # West branch: monastic library and study room.
    _corridor_x(root, Vector3(-6.0, 0, 0), 4.0, 3.4)
    _build_library(root)

    # East branch: spartan dormitory wing.
    _corridor_x(root, Vector3(6.0, 0, 0), 4.0, 3.4)
    _build_dormitory(root)

    # North branch: meditation courtyard and the old council passage.
    _corridor_z(root, Vector3(0, 0, -6.0), 4.0, 6.0, true)
    _build_meditation_court(root)
    _build_council_passage(root)

func _build_library(root: Node3D) -> void:
    var center := Vector3(-13.0, 0, 0)
    _room_floor(root, "LibraryFloor", center + Vector3(0, 0.06, 0), Vector3(10, 0.12, 12))
    _ceiling(root, "LibraryCeiling", center + Vector3(0, 4.8, 0), Vector3(10, 0.28, 12))
    _wall(root, "LibraryWest", center + Vector3(-5, 2.4, 0), Vector3(0.45, 4.8, 12))
    _wall(root, "LibraryNorth", center + Vector3(0, 2.4, -6), Vector3(10, 4.8, 0.45))
    _wall(root, "LibrarySouth", center + Vector3(0, 2.4, 6), Vector3(10, 4.8, 0.45))
    _wall(root, "LibraryEastN", center + Vector3(5, 2.4, -4.1), Vector3(0.45, 4.8, 3.8))
    _wall(root, "LibraryEastS", center + Vector3(5, 2.4, 4.1), Vector3(0.45, 4.8, 3.8))

    _shelf(root, center + Vector3(-3.5, 0, -3.6), Vector3(0, 90, 0))
    _shelf(root, center + Vector3(-3.5, 0, 0), Vector3(0, 90, 0))
    _shelf(root, center + Vector3(-3.5, 0, 3.6), Vector3(0, 90, 0))
    _shelf(root, center + Vector3(1.2, 0, -4.7), Vector3.ZERO)
    _shelf(root, center + Vector3(1.2, 0, 4.7), Vector3.ZERO)

    _table(root, center + Vector3(1.2, 0, 0), Vector3(3.8, 0.18, 1.6))
    _datapad(root, center + Vector3(0.7, 1.04, -0.1))
    _datapad(root, center + Vector3(1.8, 1.04, 0.15))
    _scroll_stack(root, center + Vector3(0.2, 1.02, 0.45))
    _warm_light(root, center + Vector3(1.2, 3.55, 0), 1.6, 9.5)

func _build_dormitory(root: Node3D) -> void:
    var center := Vector3(13.0, 0, 0)
    _room_floor(root, "DormFloor", center + Vector3(0, 0.06, 0), Vector3(10, 0.12, 16))
    _ceiling(root, "DormCeiling", center + Vector3(0, 4.55, 0), Vector3(10, 0.28, 16))
    _wall(root, "DormEast", center + Vector3(5, 2.3, 0), Vector3(0.45, 4.6, 16))
    _wall(root, "DormNorth", center + Vector3(0, 2.3, -8), Vector3(10, 4.6, 0.45))
    _wall(root, "DormSouth", center + Vector3(0, 2.3, 8), Vector3(10, 4.6, 0.45))
    _wall(root, "DormWestN", center + Vector3(-5, 2.3, -5.0), Vector3(0.45, 4.6, 6.0))
    _wall(root, "DormWestS", center + Vector3(-5, 2.3, 5.0), Vector3(0.45, 4.6, 6.0))

    # Low partitions imply many more cells than are currently occupied.
    _wall(root, "DormDividerN", center + Vector3(0, 1.55, -2.7), Vector3(10, 3.1, 0.30))
    _wall(root, "DormDividerS", center + Vector3(0, 1.55, 2.7), Vector3(10, 3.1, 0.30))
    _wall(root, "DormDividerW", center + Vector3(0, 1.55, -5.35), Vector3(0.30, 3.1, 5.0))
    _wall(root, "DormDividerE", center + Vector3(0, 1.55, 5.35), Vector3(0.30, 3.1, 5.0))

    _bed(root, center + Vector3(-2.7, 0, -5.5), 0.0)
    _dresser(root, center + Vector3(2.7, 0, -5.8))
    _bed(root, center + Vector3(2.7, 0, 5.5), 180.0)
    _dresser(root, center + Vector3(-2.7, 0, 5.8))
    _bed(root, center + Vector3(-2.7, 0, 0.2), 0.0)
    _dresser(root, center + Vector3(2.7, 0, 0.2))

    _wall_lamp(root, center + Vector3(4.7, 2.6, -5.4))
    _wall_lamp(root, center + Vector3(4.7, 2.6, 0.0))
    _wall_lamp(root, center + Vector3(4.7, 2.6, 5.4))

func _build_meditation_court(root: Node3D) -> void:
    var center := Vector3(0, 0, -15.0)
    _room_floor(root, "MeditationStone", center + Vector3(0, 0.05, 0), Vector3(14, 0.10, 12), STONE_MID)
    _box(root, "MeditationSoil", center + Vector3(0, 0.12, 0), Vector3(7.2, 0.16, 6.6), Color(0.30, 0.20, 0.20), false)
    _wall(root, "MeditationWest", center + Vector3(-7, 2.5, 0), Vector3(0.45, 5.0, 12))
    _wall(root, "MeditationEast", center + Vector3(7, 2.5, 0), Vector3(0.45, 5.0, 12))
    _wall(root, "MeditationSouthL", center + Vector3(-4.3, 2.5, 6), Vector3(5.4, 5.0, 0.45))
    _wall(root, "MeditationSouthR", center + Vector3(4.3, 2.5, 6), Vector3(5.4, 5.0, 0.45))
    _wall(root, "MeditationNorthL", center + Vector3(-4.3, 2.5, -6), Vector3(5.4, 5.0, 0.45))
    _wall(root, "MeditationNorthR", center + Vector3(4.3, 2.5, -6), Vector3(5.4, 5.0, 0.45))

    _tree(root, center + Vector3(0, 0.12, 0))
    _mat(root, center + Vector3(-4.7, 0.18, -1.8), 15.0)
    _mat(root, center + Vector3(4.7, 0.18, -1.8), -15.0)
    _mat(root, center + Vector3(-4.7, 0.18, 2.0), -12.0)
    _mat(root, center + Vector3(4.7, 0.18, 2.0), 12.0)

    # Davian-like meditation altar: candles, herbs, stones and small chimes.
    _box(root, "MeditationAltar", center + Vector3(0, 1.05, -5.25), Vector3(4.2, 1.8, 0.55), STONE_PALE)
    for x in [-1.5, -0.7, 0.1, 0.9, 1.55]:
        _candle(root, center + Vector3(x, 2.05, -4.92))
    _chimes(root, center + Vector3(-2.25, 3.1, -4.9))
    _chimes(root, center + Vector3(2.25, 3.1, -4.9))
    _warm_light(root, center + Vector3(0, 2.4, -4.5), 1.35, 7.0)

func _build_council_passage(root: Node3D) -> void:
    # A cramped, dim, coiling approach to the council chamber.
    _corridor_z(root, Vector3(0, 0, -23.6), 3.2, 5.2, false)
    _corridor_x(root, Vector3(-3.0, 0, -26.2), 6.0, 3.2, false)
    _corridor_z(root, Vector3(-6.0, 0, -29.4), 3.2, 6.4, false)
    _corridor_x(root, Vector3(-2.0, 0, -32.6), 8.0, 3.2, false)

    _warm_light(root, Vector3(-5.9, 2.8, -29.5), 0.65, 5.0, Color(0.72, 0.38, 0.18))
    _box(root, "CouncilDoor", Vector3(2.05, 2.25, -32.6), Vector3(0.38, 4.5, 3.1), BLUE_DOOR)
    _box(root, "CouncilControl", Vector3(1.80, 1.4, -31.35), Vector3(0.12, 0.8, 0.25), MACHINE, false)

func _corridor_z(root: Node3D, center: Vector3, width: float, length: float, lit: bool = false) -> void:
    _room_floor(root, "CorridorFloor", center + Vector3(0, 0.05, 0), Vector3(width, 0.10, length))
    _ceiling(root, "CorridorCeiling", center + Vector3(0, 4.45, 0), Vector3(width, 0.25, length))
    _wall(root, "CorridorWallL", center + Vector3(-width * 0.5, 2.25, 0), Vector3(0.35, 4.5, length))
    _wall(root, "CorridorWallR", center + Vector3(width * 0.5, 2.25, 0), Vector3(0.35, 4.5, length))
    if lit:
        _warm_light(root, center + Vector3(0, 3.3, 0), 0.9, 6.0)

func _corridor_x(root: Node3D, center: Vector3, length: float, width: float, lit: bool = true) -> void:
    _room_floor(root, "CorridorFloor", center + Vector3(0, 0.05, 0), Vector3(length, 0.10, width))
    _ceiling(root, "CorridorCeiling", center + Vector3(0, 4.45, 0), Vector3(length, 0.25, width))
    _wall(root, "CorridorWallN", center + Vector3(0, 2.25, -width * 0.5), Vector3(length, 4.5, 0.35))
    _wall(root, "CorridorWallS", center + Vector3(0, 2.25, width * 0.5), Vector3(length, 4.5, 0.35))
    if lit:
        _warm_light(root, center + Vector3(0, 3.3, 0), 0.9, 6.0)

func _room_floor(root: Node3D, node_name: String, pos: Vector3, size: Vector3, color: Color = FLOOR) -> void:
    _box(root, node_name, pos, size, color)

func _ceiling(root: Node3D, node_name: String, pos: Vector3, size: Vector3) -> void:
    _box(root, node_name, pos, size, STONE_DARK)

func _wall(root: Node3D, node_name: String, pos: Vector3, size: Vector3) -> void:
    _box(root, node_name, pos, size, STONE_DARK)

func _corner_wall(root: Node3D, pos: Vector3, size: Vector3) -> void:
    _box(root, "JunctionWall", pos, size, STONE_DARK)

func _box(root: Node3D, node_name: String, pos: Vector3, size: Vector3, color: Color, collision_enabled: bool = true) -> void:
    var body := StaticBody3D.new()
    body.name = node_name
    body.position = pos
    var mesh_instance := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.95
    mesh.material = mat
    mesh_instance.mesh = mesh
    body.add_child(mesh_instance)
    if collision_enabled:
        var shape := BoxShape3D.new()
        shape.size = size
        var collision := CollisionShape3D.new()
        collision.shape = shape
        body.add_child(collision)
    root.add_child(body)

func _interior_arch(root: Node3D, pos: Vector3, opening_width: float, opening_height: float) -> void:
    _box(root, "InnerArchL", pos + Vector3(-opening_width * 0.64, opening_height * 0.45, 0), Vector3(1.05, opening_height, 0.8), STONE_PALE)
    _box(root, "InnerArchR", pos + Vector3(opening_width * 0.64, opening_height * 0.45, 0), Vector3(1.05, opening_height, 0.8), STONE_PALE)
    _box(root, "InnerArchTop", pos + Vector3(0, opening_height, 0), Vector3(opening_width + 2.3, 0.8, 0.8), STONE_PALE)

func _brazier(root: Node3D, pos: Vector3) -> void:
    var holder := Node3D.new()
    holder.position = pos
    root.add_child(holder)

    var stem := MeshInstance3D.new()
    var stem_mesh := CylinderMesh.new()
    stem_mesh.top_radius = 0.10
    stem_mesh.bottom_radius = 0.18
    stem_mesh.height = 1.10
    stem_mesh.radial_segments = 6
    var iron := StandardMaterial3D.new()
    iron.albedo_color = Color(0.08, 0.07, 0.06)
    iron.metallic = 0.55
    iron.roughness = 0.70
    stem_mesh.material = iron
    stem.mesh = stem_mesh
    stem.position.y = 0.55
    holder.add_child(stem)

    var flame := MeshInstance3D.new()
    var flame_mesh := CylinderMesh.new()
    flame_mesh.top_radius = 0.03
    flame_mesh.bottom_radius = 0.15
    flame_mesh.height = 0.58
    flame_mesh.radial_segments = 6
    var flame_mat := StandardMaterial3D.new()
    flame_mat.albedo_color = Color(0.85, 0.34, 0.08)
    flame_mat.emission_enabled = true
    flame_mat.emission = Color(0.78, 0.22, 0.05)
    flame_mat.emission_energy_multiplier = 2.2
    flame_mesh.material = flame_mat
    flame.mesh = flame_mesh
    flame.position.y = 1.35
    holder.add_child(flame)

func _warm_light(root: Node3D, pos: Vector3, energy: float, radius: float, color: Color = WARM) -> void:
    var light := OmniLight3D.new()
    light.position = pos
    light.light_color = color
    light.light_energy = energy
    light.omni_range = radius
    root.add_child(light)

func _shelf(root: Node3D, pos: Vector3, rot: Vector3) -> void:
    var shelf_root := Node3D.new()
    shelf_root.position = pos
    shelf_root.rotation_degrees = rot
    root.add_child(shelf_root)
    _box(shelf_root, "ShelfBack", Vector3(0, 1.35, 0), Vector3(3.2, 2.7, 0.28), WOOD)
    for y in [0.32, 0.95, 1.58, 2.21]:
        _box(shelf_root, "Shelf", Vector3(0, y, -0.27), Vector3(3.2, 0.12, 0.72), WOOD)
    for row in range(3):
        for col in range(7):
            var tone: float = 0.16 + float((row + col) % 4) * 0.035
            _box(shelf_root, "Volume", Vector3(-1.28 + col * 0.42, 0.58 + row * 0.63, -0.52), Vector3(0.28, 0.46, 0.24), Color(0.26 + tone, 0.18 + tone * 0.45, 0.10 + tone * 0.25), false)

func _table(root: Node3D, pos: Vector3, top_size: Vector3) -> void:
    _box(root, "TableTop", pos + Vector3(0, 0.92, 0), top_size, WOOD)
    for x in [-top_size.x * 0.38, top_size.x * 0.38]:
        for z in [-top_size.z * 0.30, top_size.z * 0.30]:
            _box(root, "TableLeg", pos + Vector3(x, 0.45, z), Vector3(0.18, 0.9, 0.18), WOOD)

func _datapad(root: Node3D, pos: Vector3) -> void:
    _box(root, "Datapad", pos, Vector3(0.62, 0.06, 0.42), MACHINE, false)
    _box(root, "DatapadGlow", pos + Vector3(0, 0.04, 0), Vector3(0.48, 0.02, 0.28), Color(0.18, 0.32, 0.31), false)

func _scroll_stack(root: Node3D, pos: Vector3) -> void:
    for i in range(4):
        var roll := MeshInstance3D.new()
        var mesh := CylinderMesh.new()
        mesh.top_radius = 0.075
        mesh.bottom_radius = 0.075
        mesh.height = 0.68
        mesh.radial_segments = 7
        var mat := StandardMaterial3D.new()
        mat.albedo_color = Color(0.54, 0.46, 0.32)
        mat.roughness = 1.0
        mesh.material = mat
        roll.mesh = mesh
        roll.position = pos + Vector3(float(i) * 0.17, float(i % 2) * 0.09, 0)
        roll.rotation_degrees = Vector3(0, 0, 90)
        root.add_child(roll)

func _bed(root: Node3D, pos: Vector3, yaw: float) -> void:
    var bed_root := Node3D.new()
    bed_root.position = pos
    bed_root.rotation_degrees.y = yaw
    root.add_child(bed_root)
    _box(bed_root, "BedFrame", Vector3(0, 0.32, 0), Vector3(2.2, 0.38, 1.05), WOOD)
    _box(bed_root, "Bedroll", Vector3(0, 0.58, 0), Vector3(2.05, 0.20, 0.92), CLOTH)
    _box(bed_root, "Pillow", Vector3(-0.78, 0.74, 0), Vector3(0.38, 0.16, 0.72), Color(0.35, 0.31, 0.24), false)

func _dresser(root: Node3D, pos: Vector3) -> void:
    _box(root, "Dresser", pos + Vector3(0, 0.62, 0), Vector3(1.15, 1.25, 0.62), WOOD)
    for y in [0.35, 0.72, 1.07]:
        _box(root, "DrawerLine", pos + Vector3(0, y, -0.32), Vector3(0.86, 0.035, 0.035), Color(0.11, 0.075, 0.05), false)

func _wall_lamp(root: Node3D, pos: Vector3) -> void:
    _box(root, "LampPlate", pos, Vector3(0.08, 0.46, 0.34), MACHINE, false)
    var light := OmniLight3D.new()
    light.position = pos + Vector3(-0.25, 0, 0)
    light.light_color = Color(1.0, 0.72, 0.38)
    light.light_energy = 0.8
    light.omni_range = 5.2
    root.add_child(light)

func _mat(root: Node3D, pos: Vector3, yaw: float) -> void:
    var mat_root := Node3D.new()
    mat_root.position = pos
    mat_root.rotation_degrees.y = yaw
    root.add_child(mat_root)
    _box(mat_root, "MeditationMat", Vector3.ZERO, Vector3(1.5, 0.06, 0.85), Color(0.24, 0.15, 0.10), false)

func _tree(root: Node3D, pos: Vector3) -> void:
    var trunk := MeshInstance3D.new()
    var trunk_mesh := CylinderMesh.new()
    trunk_mesh.top_radius = 0.28
    trunk_mesh.bottom_radius = 0.50
    trunk_mesh.height = 4.1
    trunk_mesh.radial_segments = 7
    var trunk_mat := StandardMaterial3D.new()
    trunk_mat.albedo_color = Color(0.24, 0.16, 0.09)
    trunk_mat.roughness = 1.0
    trunk_mesh.material = trunk_mat
    trunk.mesh = trunk_mesh
    trunk.position = pos + Vector3(0, 2.05, 0)
    root.add_child(trunk)

    for data in [
        [Vector3(-1.2, 4.15, 0.2), Vector3(1.9, 1.15, 1.5)],
        [Vector3(1.1, 4.35, -0.4), Vector3(1.8, 1.2, 1.6)],
        [Vector3(0.0, 5.05, 0.5), Vector3(2.15, 1.15, 1.8)],
    ]:
        var canopy := MeshInstance3D.new()
        var canopy_mesh := SphereMesh.new()
        canopy_mesh.radius = 1.0
        canopy_mesh.height = 2.0
        canopy_mesh.radial_segments = 7
        canopy_mesh.rings = 4
        var canopy_mat := StandardMaterial3D.new()
        canopy_mat.albedo_color = Color(0.20, 0.28, 0.16)
        canopy_mat.roughness = 1.0
        canopy_mesh.material = canopy_mat
        canopy.mesh = canopy_mesh
        canopy.position = pos + data[0]
        canopy.scale = data[1]
        root.add_child(canopy)

func _candle(root: Node3D, pos: Vector3) -> void:
    var wax := MeshInstance3D.new()
    var wax_mesh := CylinderMesh.new()
    wax_mesh.top_radius = 0.055
    wax_mesh.bottom_radius = 0.06
    wax_mesh.height = 0.34
    wax_mesh.radial_segments = 7
    var wax_mat := StandardMaterial3D.new()
    wax_mat.albedo_color = Color(0.72, 0.63, 0.45)
    wax_mat.roughness = 1.0
    wax_mesh.material = wax_mat
    wax.mesh = wax_mesh
    wax.position = pos
    root.add_child(wax)

    var flame := MeshInstance3D.new()
    var flame_mesh := SphereMesh.new()
    flame_mesh.radius = 0.055
    flame_mesh.height = 0.11
    flame_mesh.radial_segments = 6
    flame_mesh.rings = 3
    var flame_mat := StandardMaterial3D.new()
    flame_mat.albedo_color = Color(1.0, 0.52, 0.12)
    flame_mat.emission_enabled = true
    flame_mat.emission = Color(1.0, 0.30, 0.05)
    flame_mat.emission_energy_multiplier = 1.8
    flame_mesh.material = flame_mat
    flame.mesh = flame_mesh
    flame.position = pos + Vector3(0, 0.22, 0)
    root.add_child(flame)

func _chimes(root: Node3D, pos: Vector3) -> void:
    _box(root, "ChimeBeam", pos, Vector3(1.0, 0.08, 0.12), WOOD, false)
    for i in range(4):
        var tube := MeshInstance3D.new()
        var tube_mesh := CylinderMesh.new()
        tube_mesh.top_radius = 0.035
        tube_mesh.bottom_radius = 0.035
        tube_mesh.height = 0.55 + float(i) * 0.10
        tube_mesh.radial_segments = 6
        var tube_mat := StandardMaterial3D.new()
        tube_mat.albedo_color = Color(0.48, 0.43, 0.31)
        tube_mat.metallic = 0.35
        tube_mat.roughness = 0.48
        tube_mesh.material = tube_mat
        tube.mesh = tube_mesh
        tube.position = pos + Vector3(-0.36 + float(i) * 0.24, -0.36 - float(i) * 0.04, 0)
        root.add_child(tube)
