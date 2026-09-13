extends "res://scripts/visual_world_pass.gd"

const NPC_WANDER = preload("res://scripts/npc_wander.gd")

# Species anatomy now belongs to the character model itself. This pass only
# handles presentation/ambient behavior for already-built characters.
func _decorate_characters() -> void:
    _visit_for_characters(get_parent())

func _visit_for_characters(root: Node) -> void:
    for node in root.get_children():
        if node.has_method("get_dialogue"):
            _prepare_character(node)
        _visit_for_characters(node)

func _prepare_character(npc: Node3D) -> void:
    var label = npc.get("display_name")
    if label == null:
        return

    var name_text := str(label)
    var controller = NPC_WANDER.new()
    npc.add_child(controller)

    match name_text:
        "Preceptor Varro":
            controller.configure(npc, Vector2(1.8, 1.15), 0.52)
        "Brother Cael":
            controller.configure(npc, Vector2(2.0, 1.7), 0.60)
        "Surveyor Nemm":
            controller.configure(npc, Vector2(1.35, 1.15), 0.46)
        "Initiate Kes":
            controller.configure(npc, Vector2(1.7, 1.45), 0.66)
        _:
            # Characters without a safe wander zone still face the player
            # correctly but remain at their assigned post.
            controller.configure(npc, Vector2.ZERO, 0.0)
