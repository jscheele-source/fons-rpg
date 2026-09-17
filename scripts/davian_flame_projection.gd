extends "res://scripts/davian_conduct_response.gd"

const VISUAL = preload("res://scripts/refined_humanoid_visual.gd")

func _build_body() -> void:
    var shape := CapsuleShape3D.new()
    shape.radius = 0.43
    shape.height = 1.95
    var collision := CollisionShape3D.new()
    collision.shape = shape
    collision.position.y = 0.98
    add_child(collision)
    VISUAL.build(self, body_color, Color(0.50, 0.36, 0.28))

# Projection follows the existing Measure of Fire lesson; the old lesson and
# Varro's disciplinary restrictions retain precedence.
func get_dialogue() -> Dictionary:
    if current_page == "projection_lesson" and not CONDUCT.duty_blocked():
        return {
            "speaker": display_name,
            "text": "A flame thrown outward is life spent, not a limitless weapon. Focus your breath, point toward the training post, and press Q. Each projection consumes thirty-five percent of your full charge. You may need that charge to heal yourself. Practice restraint before accuracy.",
            "choices": [{"text": "I'll practice at the courtyard post.", "action": "close"}]
        }
    var result: Dictionary = super.get_dialogue()
    if current_page != "start" or not GameState.quest_is_completed("measure_of_fire"):
        return result
    if CONDUCT.duty_blocked() or ALERT.involved(get_conduct_id()):
        return result
    var choices: Array = result.get("choices", []).duplicate(true)
    if bool(GameState.world_flags.get("flame_projection_learned", false)):
        choices.insert(0, {"text": "Remind me how to project my flame.", "action": "projection_recap"})
    else:
        choices.insert(0, {"text": "Can you teach me to project my inner flame?", "action": "projection_lesson"})
    result["choices"] = choices
    return result

func choose(action: String) -> void:
    if action in ["projection_lesson", "projection_recap"]:
        if CONDUCT.duty_blocked() or not GameState.quest_is_completed("measure_of_fire"):
            return
        if action == "projection_lesson":
            GameState.world_flags["flame_projection_learned"] = true
            GameState.state_changed.emit()
            GameState.message_requested.emit("Flame Projection learned: Q launches a costly ranged bolt.")
        current_page = "projection_lesson"
        return
    super.choose(action)
