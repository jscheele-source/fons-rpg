extends "res://scripts/davian_conduct.gd"

const ALERT = preload("res://scripts/conduct_alert.gd")

func take_damage(damage: float, source) -> void:
    super.take_damage(damage, source)
    ALERT.report_incident(self, source as Node3D, get_conduct_id())

func get_dialogue() -> Dictionary:
    if ALERT.involved(get_conduct_id()) and not CONDUCT.duty_blocked():
        return {"speaker": display_name, "text": "Davian puts a hand between you and the others. 'Enough. Leave them alone and answer Varro. We can speak after everyone is safe.'", "choices": [{"text": "Leave.", "action": "close"}]}
    return super.get_dialogue()

func choose(action: String) -> void:
    if ALERT.involved(get_conduct_id()) and not CONDUCT.duty_blocked():
        return
    super.choose(action)
