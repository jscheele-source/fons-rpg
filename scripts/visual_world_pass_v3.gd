extends "res://scripts/visual_world_pass_v2.gd"

func _mountain(pos: Vector3, radius: float, height: float, segments: int) -> void:
    super._mountain(pos, radius, height, segments)
    var body := StaticBody3D.new()
    body.name = "MountainCollision"
    body.position = pos + Vector3(0, height * 0.5 - 1.0, 0)
    body.rotation_degrees.y = pos.x * 1.7
    var shape := CylinderShape3D.new()
    shape.radius = radius * 0.88
    shape.height = height
    var collision := CollisionShape3D.new()
    collision.shape = shape
    body.add_child(collision)
    add_child(body)

func _tower(pos: Vector3, radius: float, height: float) -> void:
    super._tower(pos, radius, height)
    var body := StaticBody3D.new()
    body.name = "DistantTowerCollision"
    body.position = pos
    var shape := CylinderShape3D.new()
    shape.radius = radius
    shape.height = height
    var collision := CollisionShape3D.new()
    collision.shape = shape
    body.add_child(collision)
    add_child(body)

func _visual_box(pos: Vector3, size: Vector3, color: Color) -> void:
    super._visual_box(pos, size, color)
    _box_collision(pos, size)

func _bench(pos: Vector3, yaw: float) -> void:
    super._bench(pos, yaw)
    var body := StaticBody3D.new()
    body.name = "BenchCollision"
    body.position = pos + Vector3(0, 0.38, 0)
    body.rotation_degrees.y = yaw
    var shape := BoxShape3D.new()
    shape.size = Vector3(2.45, 0.72, 0.70)
    var collision := CollisionShape3D.new()
    collision.shape = shape
    body.add_child(collision)
    add_child(body)

func _stone_basin(pos: Vector3) -> void:
    super._stone_basin(pos)
    var body := StaticBody3D.new()
    body.name = "BasinCollision"
    body.position = pos + Vector3(0, 0.30, 0)
    var shape := CylinderShape3D.new()
    shape.radius = 1.0
    shape.height = 0.60
    var collision := CollisionShape3D.new()
    collision.shape = shape
    body.add_child(collision)
    add_child(body)

func _urn(pos: Vector3, scale_factor: float) -> void:
    super._urn(pos, scale_factor)
    var body := StaticBody3D.new()
    body.name = "UrnCollision"
    body.position = pos + Vector3(0, 0.44 * scale_factor, 0)
    var shape := CylinderShape3D.new()
    shape.radius = 0.38 * scale_factor
    shape.height = 0.88 * scale_factor
    var collision := CollisionShape3D.new()
    collision.shape = shape
    body.add_child(collision)
    add_child(body)

func _box_collision(pos: Vector3, size: Vector3) -> void:
    var body := StaticBody3D.new()
    body.name = "SceneryCollision"
    body.position = pos
    var shape := BoxShape3D.new()
    shape.size = size
    var collision := CollisionShape3D.new()
    collision.shape = shape
    body.add_child(collision)
    add_child(body)
