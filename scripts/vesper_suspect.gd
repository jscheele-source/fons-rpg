extends StaticBody3D
class_name VesperSuspect

const FBS = preload("res://scripts/flame_beneath_state.gd")
const CONDUCT = preload("res://scripts/conduct_rules.gd")
const VISUAL = preload("res://scripts/refined_humanoid_visual.gd")

var display_name := "Brother Ilyon"
var current_page := "start"

func _ready() -> void:
    var shape := CapsuleShape3D.new()
    shape.radius = 0.43
    shape.height = 1.95
    var collision := CollisionShape3D.new()
    collision.shape = shape
    collision.position.y = 0.98
    add_child(collision)
    VISUAL.build(self, Color(0.26, 0.20, 0.16), Color(0.55, 0.39, 0.29))

func get_interaction_text() -> String:
    return "Speak with %s" % display_name

func interact(player) -> void:
    current_page = "start"
    player.open_dialogue(self)

func take_damage(_damage: float, source) -> void:
    CONDUCT.record_assault(self, source, "resident_ilyon", "Ilyon recoils and shouts for help.")

func get_dialogue() -> Dictionary:
    if current_page == "meeting":
        return {"speaker": display_name, "text": "'A meeting? No. I only said I would be awake after the last bell.' His eyes flick toward the dormitory lamps. 'Some of us prefer to pray where the fountain cannot see us.'", "choices": [{"text": "Where, exactly?", "action": "press"}, {"text": "What does that mean?", "action": "cryptic"}, {"text": "Leave him alone.", "action": "close"}]}
    if current_page == "cryptic":
        return {"speaker": display_name, "text": "'The old phrase is second flame, third darkness. It is historical. Ask Sel if you care that much.' He has said too much and knows it.", "choices": [{"text": "I'll ask the archivist.", "action": "close"}, {"text": "No. Tell me now.", "action": "press"}]}
    if current_page == "pressed":
        return {"speaker": display_name, "text": "Ilyon lowers his voice. 'Third lamp on the east dormitory wall. It has not burned in decades. Touch the stone beneath it after the evening bell. If you follow me, I never told you.'", "choices": [{"text": "Understood.", "action": "close"}]}
    if FBS.completed():
        var resolution := str(GameState.world_flags.get("flame_beneath_resolution", ""))
        var line := "Ilyon will not meet your eyes."
        if resolution == "joined": line = "Ilyon gives you a tiny, frightened nod: recognition, not friendship."
        elif resolution == "reported": line = "Ilyon's sleeping space is empty; only a folded blanket remains."
        elif resolution == "rescued": line = "Ilyon sits rigidly on his bunk, waiting to learn what the elders will do with him."
        return {"speaker": display_name, "text": line, "choices": [{"text": "Leave.", "action": "close"}]}
    if not FBS.started():
        return {"speaker": display_name, "text": "The Flamen snaps a small waxed packet shut when you approach. 'Can I help you?' The answer comes too quickly.", "choices": [{"text": "You look nervous.", "action": "start"}, {"text": "What did you just hide?", "action": "start"}, {"text": "Never mind.", "action": "close"}]}
    return {"speaker": display_name, "text": "Ilyon keeps glancing toward the dormitory entrance as though expecting someone.", "choices": [{"text": "You mentioned a meeting.", "action": "meeting"}, {"text": "Goodbye.", "action": "close"}]}

func choose(action: String) -> void:
    match action:
        "start":
            FBS.start()
            FBS.advance(2)
            current_page = "meeting"
        "meeting": current_page = "meeting"
        "cryptic": current_page = "cryptic"
        "press":
            FBS.note_direct_clue()
            GameState.add_skill_xp("Speechcraft", 1.0)
            current_page = "pressed"
