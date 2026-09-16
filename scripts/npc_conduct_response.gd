extends "res://scripts/npc_conduct.gd"

const ALERT = preload("res://scripts/conduct_alert.gd")

# A safe, deliberately short authority approach inside the proven courtyard.
# No navmesh, new guards, added scenery or procedural meshes.
var home_position := Vector3.ZERO

func _ready() -> void:
    super._ready()
    home_position = position

func _physics_process(delta: float) -> void:
    if dialogue_id != "varro":
        return
    var target := home_position
    var player := get_node_or_null("../Player") as Node3D
    if ALERT.active() and player != null:
        var p := player.global_position
        if p.x >= -13.0 and p.x <= 13.0 and p.z >= -7.0 and p.z <= 15.0:
            target = home_position + Vector3(0, 0, 2.6)
    position = position.move_toward(target, 1.45 * delta)
    if ALERT.active() and player != null and position.z >= home_position.z + 1.0:
        if global_position.distance_to(player.global_position) < 6.5:
            ALERT.warn_once()

func react_to_assault(aggressor: Node3D) -> void:
    if dialogue_id == "varro" or aggressor == null:
        return
    var away: Vector3 = global_position - aggressor.global_position
    away.y = 0.0
    if away.length() <= 0.01:
        return
    var destination: Vector3 = position + away.normalized() * 0.22
    destination.y = home_position.y
    # Stay close to the known safe NPC anchor, including under repeated attacks.
    if destination.distance_to(home_position) <= 0.60:
        position = destination

func take_damage(damage: float, source) -> void:
    super.take_damage(damage, source)
    ALERT.report_incident(self, source as Node3D, get_conduct_id())

func get_interaction_text() -> String:
    if dialogue_id == "varro" and ALERT.active():
        return "Answer Varro's order"
    if ALERT.involved(get_conduct_id()) and dialogue_id != "varro" and not CONDUCT.duty_blocked():
        return "Speak with %s (on alert)" % display_name
    return super.get_interaction_text()

func get_dialogue() -> Dictionary:
    var person_id := get_conduct_id()
    if dialogue_id == "varro" and ALERT.active() and not CONDUCT.pending():
        return ALERT.confront_dialogue(display_name)
    if CONDUCT.pending() and dialogue_id == "varro":
        return ALERT.add_standoff_choices(CONDUCT.review_dialogue(display_name))
    if ALERT.involved(person_id) and dialogue_id != "varro" and not CONDUCT.duty_blocked():
        var warning: String = "I heard the blow. I am not discussing business while someone may be hurt. Answer Varro's order."
        match dialogue_id:
            "cael": warning = "Cael draws back. 'Enough. Go to Varro, and don't strike anyone else.'"
            "sera": warning = "Nemm steps out of reach. 'My contract doesn't include getting hit. Speak to your preceptor.'"
            "novice": warning = "Kes keeps away from you. 'I called for help. Please go speak to Varro.'"
        return {"speaker": display_name, "text": warning, "choices": [{"text": "Leave.", "action": "close"}]}
    return super.get_dialogue()

func choose(action: String) -> void:
    if dialogue_id == "varro" and ALERT.active():
        if action == "conduct_yield":
            if ALERT.stand_down():
                current_page = "start"
            return
        if action == "conduct_defy":
            if ALERT.refuse_order():
                current_page = "start"
            return
    super.choose(action)
    if dialogue_id == "varro" and action in ["conduct_reprimand", "conduct_restitution", "conduct_service", "conduct_finish_service"]:
        if not CONDUCT.pending():
            ALERT.end_incident()
