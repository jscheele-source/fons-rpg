extends Node3D

const INTERIOR_ORIGIN := Vector3(-108.0, 0.0, 0.0)
const STONE_DARK := Color(0.155, 0.145, 0.13)
const STONE_MID := Color(0.255, 0.235, 0.20)
const STONE_PALE := Color(0.38, 0.34, 0.28)
const FLOOR := Color(0.205, 0.19, 0.165)
const WOOD := Color(0.24, 0.15, 0.085)
const CLOTH := Color(0.31, 0.22, 0.15)
const MACHINE := Color(0.10, 0.14, 0.145)
const WARM := Color(1.0, 0.62, 0.30)

func _ready() -> void:
    var root := Node3D.new()
    root.name = "MonasteryServiceWing"
    root.position = INTERIOR_ORIGIN
    add_child(root)
    _build_east_passage(root)
    _build_service_hall(root)
    _build_scriptorium(root)
    _build_refectory(root)

func _build_east_passage(root: Node3D) -> void:
    # Branches east from the first turning square in the council approach.
    _floor(root, Vector3(4.0, 0.05, -26.0), Vector3(8.0, 0.10, 4.0))
    _box(root, "ServicePassCeiling", Vector3(4.0, 4.45, -26.0), Vector3(8.0, 0.25, 4.0), STONE_DARK)
    _box(root, "ServicePassNorth", Vector3(4.0, 2.2, -28.0), Vector3(8.0, 4.4, 0.45), STONE_DARK)
    _box(root, "ServicePassSouth", Vector3(4.0, 2.2, -24.0), Vector3(8.0, 4.4, 0.45), STONE_DARK)
    _wall_lamp(root, Vector3(4.8, 2.65, -27.72), Vector3(0, 0, 1))

func _build_service_hall(root: Node3D) -> void:
    var center := Vector3(10.0, 0.0, -26.0)
    _floor(root, center + Vector3(0, 0.05, 0), Vector3(8.0, 0.10, 8.0))
    _box(root, "ServiceHallCeiling", center + Vector3(0, 4.45, 0), Vector3(8.0, 0.25, 8.0), STONE_DARK)
    _wall_x_door(root, "ServiceNorth", center + Vector3(0, 0, -4.0), 8.0, 3.0, 4.4)
    _wall_x(root, "ServiceSouth", center + Vector3(0, 0, 4.0), 8.0, 4.4)
    _wall_z_door(root, "ServiceWest", center + Vector3(-4.0, 0, 0), 8.0, 4.0, 4.4)
    _wall_z_door(root, "ServiceEast", center + Vector3(4.0, 0, 0), 8.0, 3.2, 4.4)
    _warm_light(root, center + Vector3(0, 3.4, 0), 1.0, 7.0)
    _box(root, "ServiceBenchA", center + Vector3(-1.7, 0.42, 2.7), Vector3(2.8, 0.42, 0.65), WOOD)
    _box(root, "ServiceBenchB", center + Vector3(1.7, 0.42, 2.7), Vector3(2.8, 0.42, 0.65), WOOD)
    _box(root, "NoticePanel", center + Vector3(0, 2.1, 3.72), Vector3(3.8, 1.55, 0.10), Color(0.20, 0.13, 0.075), false)

    # North corridor to the refectory.
    _floor(root, Vector3(10.0, 0.05, -31.0), Vector3(3.0, 0.10, 6.0))
    _box(root, "RefectoryCorridorCeiling", Vector3(10.0, 4.45, -31.0), Vector3(3.0, 0.25, 6.0), STONE_DARK)
    _box(root, "RefectoryCorridorWest", Vector3(8.5, 2.2, -31.0), Vector3(0.45, 4.4, 6.0), STONE_DARK)
    _box(root, "RefectoryCorridorEast", Vector3(11.5, 2.2, -31.0), Vector3(0.45, 4.4, 6.0), STONE_DARK)

func _build_scriptorium(root: Node3D) -> void:
    var center := Vector3(20.0, 0.0, -26.0)
    _floor(root, center + Vector3(0, 0.05, 0), Vector3(12.0, 0.10, 12.0))
    _box(root, "ScriptoriumCeiling", center + Vector3(0, 4.55, 0), Vector3(12.0, 0.25, 12.0), STONE_DARK)
    _wall_x(root, "ScriptoriumNorth", center + Vector3(0, 0, -6.0), 12.0, 4.5)
    _wall_x(root, "ScriptoriumSouth", center + Vector3(0, 0, 6.0), 12.0, 4.5)
    _wall_z_door(root, "ScriptoriumWest", center + Vector3(-6.0, 0, 0), 12.0, 3.2, 4.5)
    _wall_z(root, "ScriptoriumEast", center + Vector3(6.0, 0, 0), 12.0, 4.5)

    _shelf(root, center + Vector3(4.8, 0, -3.9), 90.0)
    _shelf(root, center + Vector3(4.8, 0, 0.0), 90.0)
    _shelf(root, center + Vector3(4.8, 0, 3.9), 90.0)
    _shelf(root, center + Vector3(0.0, 0, -5.0), 0.0)

    _table(root, center + Vector3(-1.0, 0, -1.8), Vector3(4.4, 0.18, 1.45))
    _table(root, center + Vector3(-1.0, 0, 2.0), Vector3(4.4, 0.18, 1.45))
    for p in [
        center + Vector3(-2.0, 1.05, -1.9),
        center + Vector3(0.2, 1.05, -1.7),
        center + Vector3(-1.3, 1.05, 1.9),
    ]:
        _datapad(root, p)
    _scroll_stack(root, center + Vector3(0.1, 1.05, 2.2))
    _scroll_stack(root, center + Vector3(-2.2, 1.05, -1.5))
    _warm_light(root, center + Vector3(-1.0, 3.5, 0), 1.45, 9.0)
    _wall_lamp(root, center + Vector3(5.72, 2.5, 0.0), Vector3(-1, 0, 0))

func _build_refectory(root: Node3D) -> void:
    var center := Vector3(10.0, 0.0, -39.0)
    _floor(root, center + Vector3(0, 0.05, 0), Vector3(14.0, 0.10, 10.0))
    _box(root, "RefectoryCeiling", center + Vector3(0, 4.65, 0), Vector3(14.0, 0.25, 10.0), STONE_DARK)
    _wall_x(root, "RefectoryNorth", center + Vector3(0, 0, -5.0), 14.0, 4.6)
    _wall_x_door(root, "RefectorySouth", center + Vector3(0, 0, 5.0), 14.0, 3.0, 4.6)
    _wall_z(root, "RefectoryWest", center + Vector3(-7.0, 0, 0), 10.0, 4.6)
    _wall_z(root, "RefectoryEast", center + Vector3(7.0, 0, 0), 10.0, 4.6)

    _table(root, center + Vector3(-2.2, 0, 0), Vector3(1.55, 0.18, 6.4))
    _table(root, center + Vector3(2.2, 0, 0), Vector3(1.55, 0.18, 6.4))
    for z in [-2.2, 0.0, 2.2]:
        _bench(root, center + Vector3(-3.7, 0, z), Vector3(0.7, 0.38, 1.55))
        _bench(root, center + Vector3(-0.7, 0, z), Vector3(0.7, 0.38, 1.55))
        _bench(root, center + Vector3(0.7, 0, z), Vector3(0.7, 0.38, 1.55))
        _bench(root, center + Vector3(3.7, 0, z), Vector3(0.7, 0.38, 1.55))

    # Service counter and old heating unit: domestic life beside machinery.
    _box(root, "ServingCounter", center + Vector3(0, 0.85, -4.0), Vector3(7.4, 1.55, 0.95), WOOD)
    _box(root, "HeatingUnit", center + Vector3(5.8, 1.0, -3.8), Vector3(1.45, 1.8, 1.6), MACHINE)
    _box(root, "HeatingGlow", center + Vector3(5.0, 1.0, -3.8), Vector3(0.04, 0.75, 0.65), Color(0.65, 0.22, 0.08), false)
    _basin(root, center + Vector3(-5.3, 0, -3.7))
    _warm_light(root, center + Vector3(-3.2, 3.5, 0), 1.2, 8.5)
    _warm_light(root, center + Vector3(3.2, 3.5, 0), 1.2, 8.5)

func _floor(root: Node3D, pos: Vector3, size: Vector3) -> void:
    _box(root, "Floor", pos, size, FLOOR)

func _wall_x(root: Node3D, prefix: String, base: Vector3, width: float, height: float) -> void:
    _box(root, prefix, base + Vector3(0, height * 0.5, 0), Vector3(width, height, 0.55), STONE_DARK)

func _wall_z(root: Node3D, prefix: String, base: Vector3, length: float, height: float) -> void:
    _box(root, prefix, base + Vector3(0, height * 0.5, 0), Vector3(0.55, height, length), STONE_DARK)

func _wall_x_door(root: Node3D, prefix: String, base: Vector3, total_width: float, opening: float, height: float) -> void:
    var segment: float = (total_width - opening) * 0.5
    var offset: float = opening * 0.5 + segment * 0.5
    _box(root, prefix + "L", base + Vector3(-offset, height * 0.5, 0), Vector3(segment + 0.1, height, 0.55), STONE_DARK)
    _box(root, prefix + "R", base + Vector3(offset, height * 0.5, 0), Vector3(segment + 0.1, height, 0.55), STONE_DARK)
    var door_height := 3.3
    _box(root, prefix + "Lintel", base + Vector3(0, door_height + (height - door_height) * 0.5, 0), Vector3(opening + 0.14, height - door_height, 0.55), STONE_DARK)

func _wall_z_door(root: Node3D, prefix: String, base: Vector3, total_length: float, opening: float, height: float) -> void:
    var segment: float = (total_length - opening) * 0.5
    var offset: float = opening * 0.5 + segment * 0.5
    _box(root, prefix + "N", base + Vector3(0, height * 0.5, -offset), Vector3(0.55, height, segment + 0.1), STONE_DARK)
    _box(root, prefix + "S", base + Vector3(0, height * 0.5, offset), Vector3(0.55, height, segment + 0.1), STONE_DARK)
    var door_height := 3.3
    _box(root, prefix + "Lintel", base + Vector3(0, door_height + (height - door_height) * 0.5, 0), Vector3(0.55, height - door_height, opening + 0.14), STONE_DARK)

func _box(root: Node3D, node_name: String, pos: Vector3, size: Vector3, color: Color, collision_enabled: bool = true) -> void:
    var body := StaticBody3D.new()
    body.name = node_name
    body.position = pos
    var visual := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = 0.95
    mesh.material = material
    visual.mesh = mesh
    body.add_child(visual)
    if collision_enabled:
        var shape := BoxShape3D.new()
        shape.size = size
        var collision := CollisionShape3D.new()
        collision.shape = shape
        body.add_child(collision)
    root.add_child(body)

func _table(root: Node3D, pos: Vector3, size: Vector3) -> void:
    _box(root, "TableTop", pos + Vector3(0, 0.92, 0), size, WOOD)
    for x in [-size.x * 0.38, size.x * 0.38]:
        for z in [-size.z * 0.38, size.z * 0.38]:
            _box(root, "TableLeg", pos + Vector3(x, 0.45, z), Vector3(0.18, 0.9, 0.18), WOOD)

func _bench(root: Node3D, pos: Vector3, size: Vector3) -> void:
    _box(root, "Bench", pos + Vector3(0, 0.34, 0), size, WOOD)

func _shelf(root: Node3D, pos: Vector3, yaw: float) -> void:
    var shelf := Node3D.new()
    shelf.position = pos
    shelf.rotation_degrees.y = yaw
    root.add_child(shelf)
    _box(shelf, "ShelfBack", Vector3(0, 1.35, -0.30), Vector3(3.2, 2.7, 0.22), WOOD)
    for y in [0.30, 0.93, 1.56, 2.19]:
        _box(shelf, "ShelfBoard", Vector3(0, y, 0.02), Vector3(3.2, 0.12, 0.72), WOOD)
    for row in range(3):
        for col in range(7):
            var tone: float = 0.16 + float((row + col) % 4) * 0.035
            var book_color := Color(0.26 + tone, 0.18 + tone * 0.45, 0.10 + tone * 0.25)
            _box(shelf, "Volume", Vector3(-1.28 + col * 0.42, 0.57 + row * 0.63, 0.30), Vector3(0.28, 0.46, 0.24), book_color, false)

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

func _basin(root: Node3D, pos: Vector3) -> void:
    _box(root, "BasinBase", pos + Vector3(0, 0.38, 0), Vector3(1.5, 0.70, 1.1), STONE_PALE)
    _box(root, "BasinWater", pos + Vector3(0, 0.76, 0), Vector3(1.18, 0.05, 0.78), Color(0.18, 0.25, 0.25), false)

func _wall_lamp(root: Node3D, pos: Vector3, facing: Vector3) -> void:
    _box(root, "LampPlate", pos, Vector3(0.32 if abs(facing.z) > 0.5 else 0.08, 0.48, 0.08 if abs(facing.z) > 0.5 else 0.32), MACHINE, false)
    var light := OmniLight3D.new()
    light.position = pos + facing * 0.25
    light.light_color = WARM
    light.light_energy = 0.75
    light.omni_range = 5.0
    root.add_child(light)

func _warm_light(root: Node3D, pos: Vector3, energy: float, radius: float) -> void:
    var light := OmniLight3D.new()
    light.position = pos
    light.light_color = WARM
    light.light_energy = energy
    light.omni_range = radius
    root.add_child(light)
