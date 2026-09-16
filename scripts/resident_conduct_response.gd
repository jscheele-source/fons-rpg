extends "res://scripts/resident_conduct.gd"

const ALERT = preload("res://scripts/conduct_alert.gd")

func take_damage(damage: float, source) -> void:
    super.take_damage(damage, source)
    ALERT.report_incident(self, source as Node3D, get_conduct_id())

func get_dialogue() -> Dictionary:
    if ALERT.involved(get_conduct_id()) and not CONDUCT.duty_blocked():
        var line := "We are not discussing duties while people are being struck. Speak to Varro."
        match resident_id:
            "archivist": line = "Sel steps away from her papers. 'That was violence, not a misunderstanding. Find Varro.'"
            "keeper": line = "Oru holds up one claw. 'I heard that. Keep your distance until Varro intervenes.'"
            "sargasson_novice": line = "Pell's respirator clicks rapidly. 'Please do not come any closer. Varro has been called.'"
        return {"speaker": display_name, "text": line, "choices": [{"text": "Leave.", "action": "close"}]}
    return super.get_dialogue()

func choose(action: String) -> void:
    if ALERT.involved(get_conduct_id()) and not CONDUCT.duty_blocked():
        return
    super.choose(action)
