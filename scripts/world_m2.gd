extends "res://scripts/world_m1.gd"

const NPC_M2 = preload("res://scripts/npc_conduct_response.gd")

# Stable M2 layout: only the NPC class changed for active conduct behavior.
func _spawn_npc(name_text: String, id: String, pos: Vector3, color: Color) -> void:
    var npc = NPC_M2.new()
    npc.display_name = name_text
    npc.dialogue_id = id
    npc.body_color = color
    npc.position = pos
    add_child(npc)

func _rock(pos: Vector3, rock_scale: Vector3, color: Color) -> void:
    super._rock(pos, rock_scale, color)

    var body := StaticBody3D.new()
    body.name = "M2RockCollision_%d_%d" % [int(abs(pos.x)), int(abs(pos.z))]
    body.position = pos + Vector3(0, rock_scale.y * 0.45, 0)
    body.rotation_degrees = Vector3(0, pos.x * 2.7, 8.0)

    var shape := BoxShape3D.new()
    shape.size = Vector3(rock_scale.x * 1.55, rock_scale.y * 1.55, rock_scale.z * 1.55)
    var collision := CollisionShape3D.new()
    collision.name = "CollisionShape3D"
    collision.shape = shape
    body.add_child(collision)
    add_child(body)

func _distant_monolith(pos: Vector3) -> void:
    super._distant_monolith(pos)

    var body := StaticBody3D.new()
    body.name = "M2MonolithCollision_%d_%d" % [int(abs(pos.x)), int(abs(pos.z))]
    body.position = pos
    body.rotation_degrees = Vector3(0, pos.z, -4.0 + fmod(abs(pos.x), 8.0))

    var shape := BoxShape3D.new()
    shape.size = Vector3(3.0, 11.0, 2.2)
    var collision := CollisionShape3D.new()
    collision.name = "CollisionShape3D"
    collision.shape = shape
    body.add_child(collision)
    add_child(body)
