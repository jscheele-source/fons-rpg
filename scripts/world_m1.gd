extends "res://scripts/world.gd"

# Milestone 1 deliberately keeps the stable courtyard/world geometry intact.
# Only the NPC class is swapped so the dialogue polish can ship independently
# of the later garden/collision work.
const NPC_M1 = preload("res://scripts/npc_m1.gd")

func _spawn_npc(name_text: String, id: String, pos: Vector3, color: Color) -> void:
    var npc = NPC_M1.new()
    npc.display_name = name_text
    npc.dialogue_id = id
    npc.body_color = color
    npc.position = pos
    add_child(npc)
