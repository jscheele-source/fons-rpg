extends "res://scripts/world_m2.gd"

const REFINED_COURTYARD_NPC = preload("res://scripts/npc_refined_cael.gd")

# Keep the confirmed M2 courtyard and all its colliders identical. Only Cael's
# character mesh is different; other residents still use their proven models.
func _spawn_npc(name_text: String, id: String, pos: Vector3, color: Color) -> void:
    if id != "cael":
        super._spawn_npc(name_text, id, pos, color)
        return
    var npc = REFINED_COURTYARD_NPC.new()
    npc.display_name = name_text
    npc.dialogue_id = id
    npc.body_color = color
    npc.position = pos
    add_child(npc)
