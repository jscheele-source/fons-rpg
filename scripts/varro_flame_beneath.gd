extends "res://scripts/npc_conduct_response.gd"

const FBS = preload("res://scripts/flame_beneath_state.gd")

func get_dialogue() -> Dictionary:
    var result: Dictionary = super.get_dialogue()
    if dialogue_id != "varro" or current_page != "start":
        return result
    if CONDUCT.duty_blocked() or ALERT.active() or FBS.completed():
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
    super.choose(action)

func get_interaction_text() -> String:
    if bool(GameState.world_flags.get("flame_beneath_evidence", false)) and not FBS.completed() and not CONDUCT.duty_blocked():
        return "Report the Vesper cell to Preceptor Varro"
    return super.get_interaction_text()
