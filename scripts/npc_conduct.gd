extends "res://scripts/npc_m2.gd"

const CONDUCT = preload("res://scripts/conduct_rules.gd")

func _ready() -> void:
    super._ready()
    add_to_group("conduct_witnesses")

func get_conduct_id() -> String:
    return "courtyard_" + dialogue_id

func get_interaction_text() -> String:
    if dialogue_id == "varro" and CONDUCT.duty_blocked():
        return "Report to Preceptor Varro"
    if dialogue_id != "varro" and CONDUCT.duty_blocked():
        return "Speak with %s (duties suspended)" % display_name
    return super.get_interaction_text()

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
    if dialogue_id == "varro" and current_page == "conduct_resolved" and not CONDUCT.duty_blocked():
        return {"speaker": display_name, "text": "The report is settled. The record remains; your conduct from here is your choice. Return to your duties.", "choices": [{"text": "Understood.", "action": "close"}]}
    if CONDUCT.pending():
        if dialogue_id == "varro":
            return CONDUCT.review_dialogue(display_name)
        var warning := "The report is with Varro. We will not speak about duties until he hears it."
        if CONDUCT.tier() >= 3:
            warning = "Keep your distance. Your exclusion review is underway. Only Varro can restore your standing."
        elif CONDUCT.tier() >= 2:
            warning = "Your dwelling seal has been suspended. See Varro; I am not taking another assignment from you."
        return {"speaker": display_name, "text": warning, "choices": [{"text": "Leave.", "action": "close"}]}
    if CONDUCT.service_active():
        if dialogue_id == "varro":
            if current_page == "conduct_service_assigned":
                return {"speaker": display_name, "text": "Inspect the training post, then read Annex Terminal 3. If you are under exclusion review, perform three controlled strikes at the post too. Return here when your journal shows all tasks complete.", "choices": [{"text": "I'll do it.", "action": "close"}]}
            return CONDUCT.service_dialogue(display_name)
        return {"speaker": display_name, "text": "Varro has you on supervised service. Finish the outdoor tasks and have him sign the ledger before I resume our business.", "choices": [{"text": "Leave.", "action": "close"}]}
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
        elif action == "conduct_service":
            if CONDUCT.resolve_report("service"):
                current_page = "conduct_service_assigned"
        return
    if CONDUCT.service_active():
        if dialogue_id == "varro" and action == "conduct_finish_service":
            if CONDUCT.finish_service():
                current_page = "conduct_resolved"
        return
    if action == "conduct_apologize":
        if CONDUCT.apologize(get_conduct_id()):
            current_page = "conduct_apology"
        return
    super.choose(action)
