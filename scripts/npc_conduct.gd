extends "res://scripts/npc_m2.gd"

const CONDUCT = preload("res://scripts/conduct_rules.gd")

func _ready() -> void:
    super._ready()
    add_to_group("conduct_witnesses")

func get_conduct_id() -> String:
    return "courtyard_" + dialogue_id

func take_damage(_damage: float, source) -> void:
    if source is Node3D:
        var away: Vector3 = global_position - source.global_position
        away.y = 0.0
        if away.length() > 0.01:
            position += away.normalized() * 0.12

    var reaction := "The resident recoils."
    match dialogue_id:
        "varro": reaction = "Varro steps back, visibly angry."
        "cael": reaction = "Cael jerks away from the blow."
        "sera": reaction = "Nemm backs away from you."
        "novice": reaction = "Kes flinches and calls out."
    CONDUCT.record_assault(self, source, get_conduct_id(), reaction)

func get_dialogue() -> Dictionary:
    var person_id := get_conduct_id()
    if dialogue_id == "varro" and current_page == "conduct_resolved":
        return {"speaker": display_name, "text": "The report is settled. Your actions are still remembered. Return to your duties.", "choices": [{"text": "Understood.", "action": "close"}]}
    if CONDUCT.pending():
        if dialogue_id == "varro":
            return CONDUCT.review_dialogue(display_name)
        return {"speaker": display_name, "text": "Your assault has been reported. Varro expects you. We can talk after he has dealt with it.", "choices": [{"text": "Goodbye.", "action": "close"}]}
    if current_page == "conduct_apology":
        return {"speaker": display_name, "text": "I heard you. I am not ready to forget it.", "choices": [{"text": "Goodbye.", "action": "close"}]}

    var dialogue: Dictionary = super.get_dialogue()
    if CONDUCT.attitude(person_id) < 45:
        dialogue["text"] = CONDUCT.temper_text(person_id) + str(dialogue.get("text", ""))
    if current_page == "start" and CONDUCT.can_apologize(person_id):
        var choices: Array = dialogue.get("choices", []).duplicate(true)
        choices.insert(0, {"text": "I owe you an apology.", "action": "conduct_apologize"})
        dialogue["choices"] = choices
    return dialogue

func choose(action: String) -> void:
    if CONDUCT.pending():
        if dialogue_id != "varro":
            return
        if action == "conduct_reprimand":
            if CONDUCT.resolve_report("reprimand"):
                current_page = "conduct_resolved"
        elif action == "conduct_restitution":
            if CONDUCT.resolve_report("restitution"):
                current_page = "conduct_resolved"
        return
    if action == "conduct_apologize":
        if CONDUCT.apologize(get_conduct_id()):
            current_page = "conduct_apology"
        return
    super.choose(action)
