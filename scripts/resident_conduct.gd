extends "res://scripts/monastery_resident_m2.gd"

const CONDUCT = preload("res://scripts/conduct_rules.gd")

func _ready() -> void:
    super._ready()
    add_to_group("conduct_witnesses")

func get_conduct_id() -> String:
    return "resident_" + resident_id

func get_interaction_text() -> String:
    if CONDUCT.duty_blocked():
        return "Speak with %s (duties suspended)" % display_name
    return super.get_interaction_text()

func take_damage(_damage: float, source) -> void:
    if source is Node3D:
        var away: Vector3 = global_position - source.global_position
        away.y = 0.0
        if away.length() > 0.01:
            position += away.normalized() * 0.10
    var reaction := "The resident recoils."
    match resident_id:
        "archivist": reaction = "Sel stumbles away from the table."
        "keeper": reaction = "Oru recoils and calls for help."
        "sargasson_novice": reaction = "Pell's respirator clicks as he backs away."
    CONDUCT.record_assault(self, source, get_conduct_id(), reaction)

func get_dialogue() -> Dictionary:
    var person_id := get_conduct_id()
    if CONDUCT.pending():
        var statement := "There is an assault report with Varro. I won't discuss duties until he has heard you."
        if CONDUCT.tier() >= 3:
            statement = "You're under exclusion review. Get away from my table. Varro can hear your explanation."
        elif CONDUCT.tier() >= 2:
            statement = "Your dwelling seal is suspended. Speak to Varro. I will not give you work."
        return {"speaker": display_name, "text": statement, "choices": [{"text": "Leave.", "action": "close"}]}
    if CONDUCT.service_active():
        return {"speaker": display_name, "text": "Finish Varro's supervised courtyard service before returning to the monastery's ordinary duties.", "choices": [{"text": "Leave.", "action": "close"}]}
    if current_page == "conduct_apology":
        return {"speaker": display_name, "text": "All right. I heard the apology. Give me some room.", "choices": [{"text": "Goodbye.", "action": "close"}]}
    var dialogue: Dictionary = super.get_dialogue()
    if CONDUCT.attitude(person_id) < 45:
        dialogue["text"] = CONDUCT.temper_text(person_id) + str(dialogue.get("text", ""))
    if current_page == "start" and CONDUCT.can_apologize(person_id):
        var choices: Array = dialogue.get("choices", []).duplicate(true)
        choices.insert(0, {"text": "I owe you an apology.", "action": "conduct_apologize"})
        dialogue["choices"] = choices
    return dialogue

func choose(action: String) -> void:
    if CONDUCT.duty_blocked():
        return
    if action == "conduct_apologize":
        if CONDUCT.apologize(get_conduct_id()):
            current_page = "conduct_apology"
        return
    super.choose(action)
