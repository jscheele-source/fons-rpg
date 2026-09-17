extends "res://scripts/world_flame_foundation.gd"

const VARRO_FLAME_BENEATH = preload("res://scripts/varro_flame_beneath.gd")

func _spawn_npc(name_text: String, id: String, pos: Vector3, color: Color) -> void:
    if id != "varro":
        super._spawn_npc(name_text, id, pos, color)
        return
    var npc = VARRO_FLAME_BENEATH.new()
    npc.display_name = name_text
    npc.dialogue_id = id
    npc.body_color = color
    npc.position = pos
    add_child(npc)
