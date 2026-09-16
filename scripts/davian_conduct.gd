extends "res://scripts/davian_npc.gd"

const CONDUCT = preload("res://scripts/conduct_rules.gd")

func _ready() -> void:
    super._ready()
    add_to_group("conduct_witnesses")

func get_conduct_id() -> String:
    return "elder_davian"

func take_damage(_damage: float, source) -> void:
    CONDUCT.record_assault(self, source, get_conduct_id(), "Davian takes a step back and calls for Varro.")

func get_dialogue() -> Dictionary:
    if CONDUCT.pending():
        return {"speaker": display_name, "text": "Your violence has been entered in the register. Speak to Varro; we will not train while this is unsettled.", "choices": [{"text": "Goodbye.", "action": "close"}]}
    if current_page == "conduct_apology":
        return {"speaker": display_name, "text": "An apology is a beginning, not an undoing. We will see what follows.", "choices": [{"text": "Goodbye.", "action": "close"}]}
    var dialogue: Dictionary = super.get_dialogue()
    if CONDUCT.attitude(get_conduct_id()) < 45:
        dialogue["text"] = CONDUCT.temper_text(get_conduct_id()) + str(dialogue.get("text", ""))
    if current_page == "start" and CONDUCT.can_apologize(get_conduct_id()):
        var choices: Array = dialogue.get("choices", []).duplicate(true)
        choices.insert(0, {"text": "I owe you an apology.", "action": "conduct_apologize"})
        dialogue["choices"] = choices
    return dialogue

func choose(action: String) -> void:
    if CONDUCT.pending():
        return
    if action == "conduct_apologize":
        if CONDUCT.apologize(get_conduct_id()):
            current_page = "conduct_apology"
        return
    super.choose(action)
