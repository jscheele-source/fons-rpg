extends "res://scripts/world_m2.gd"

const RESPONDING_NPC = preload("res://scripts/npc_conduct_response.gd")

# Only swap the resident script; every M2 wall, collider, light and spawn stays.
func _spawn_npc(name_text: String, id: String, pos: Vector3, color: Color) -> void:
    var npc = RESPONDING_NPC.new()
    npc.display_name = name_text
    npc.dialogue_id = id
    npc.body_color = color
    npc.position = pos
    add_child(npc)
