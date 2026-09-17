extends "res://scripts/npc_conduct_response.gd"

const FBS = preload("res://scripts/flame_beneath_state.gd")
const VISUAL = preload("res://scripts/refined_humanoid_visual.gd")

func _build_body() -> void:
    var shape := CapsuleShape3D.new()
    shape.radius = 0.43
    shape.height = 1.95
    var collision := CollisionShape3D.new()
    collision.shape = shape
    collision.position.y = 0.98
    add_child(collision)
    VISUAL.build(self, body_color, Color(0.54, 0.40, 0.31))

func get_dialogue() -> Dictionary:
    if dialogue_id == "varro" and current_page == "vesper_reported":
        return {"speaker": display_name, "text": "Varro's face goes still as you finish. 'You did correctly by bringing this to me before blood made the decision for us. The chamber will be sealed, the cell removed, and the initiate examined by Davian. You may be called before the elders to repeat exactly what you saw.'", "choices": [{"text": "Understood.", "action": "vesper_aftermath_ack"}]}
    if dialogue_id == "varro" and current_page == "vesper_aftermath":
        return {"speaker": display_name, "text": "'Do not confuse a quiet corridor with a solved problem. People do not begin forbidden rites because they think of themselves as villains.'", "choices": [{"text": "I won't.", "action": "close"}]}

    var result: Dictionary = super.get_dialogue()
    if dialogue_id != "varro" or current_page != "start":
        return result
    if CONDUCT.duty_blocked() or ALERT.active():
        return result

    if FBS.completed():
        var resolution := str(GameState.world_flags.get("flame_beneath_resolution", ""))
        if resolution == "reported" and bool(GameState.world_flags.get("flame_beneath_aftermath_pending", false)):
            return {"speaker": display_name, "text": "'The chamber is being sealed. Ilyon and the others are gone from the dormitory. Mara is alive. That part matters.'", "choices": [{"text": "What happens now?", "action": "vesper_aftermath_ack"}]}
        if resolution == "rescued" and bool(GameState.world_flags.get("flame_beneath_aftermath_pending", false)):
            return {"speaker": display_name, "text": "Varro studies the cuts on your clothing. 'You found a hidden cell and chose force. Mara is alive, which is not a small thing. The elders will still want to know why blood was shed beneath their roof.'", "choices": [{"text": "I would do it again.", "action": "vesper_aftermath_ack"}, {"text": "I didn't see another way.", "action": "vesper_aftermath_ack"}]}
        return result

    if bool(GameState.world_flags.get("flame_beneath_evidence", false)):
        var choices: Array = result.get("choices", []).duplicate(true)
        choices.insert(0, {"text": "There are Vespers meeting beneath the dormitory. I saw the rite.", "action": "vesper_report"})
        result["choices"] = choices
    return result

func choose(action: String) -> void:
    if action == "vesper_report" and bool(GameState.world_flags.get("flame_beneath_evidence", false)) and not FBS.completed():
        FBS.resolve("reported")
        current_page = "vesper_reported"
        return
    if action == "vesper_aftermath_ack":
        GameState.world_flags["flame_beneath_aftermath_pending"] = false
        GameState.state_changed.emit()
        current_page = "vesper_aftermath"
        return
    super.choose(action)

func get_interaction_text() -> String:
    if bool(GameState.world_flags.get("flame_beneath_evidence", false)) and not FBS.completed() and not CONDUCT.duty_blocked():
        return "Report the Vesper cell to Preceptor Varro"
    if FBS.completed() and bool(GameState.world_flags.get("flame_beneath_aftermath_pending", false)):
        return "Speak with Varro about the Vesper aftermath"
    return super.get_interaction_text()
