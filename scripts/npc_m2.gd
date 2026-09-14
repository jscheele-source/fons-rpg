extends "res://scripts/npc_m1.gd"

# Milestone 2 restores physical reactions without turning the monastery into a
# full crime/combat simulation yet. The first assault costs Flamen reputation;
# repeated hits still provoke dialogue but do not repeatedly stack the penalty.
func take_damage(_damage: float, source) -> void:
    var key := "npc_hit_%s" % dialogue_id
    var hits := int(GameState.world_flags.get(key, 0)) + 1
    GameState.world_flags[key] = hits

    if source is Node3D:
        var away: Vector3 = global_position - source.global_position
        away.y = 0.0
        if away.length() > 0.01:
            position += away.normalized() * 0.12

    if hits == 1:
        GameState.change_reputation("Flamen", -1)

    match dialogue_id:
        "varro":
            GameState.message_requested.emit("Varro recoils, more offended than hurt. 'Do that again and we will have a different conversation.'")
        "cael":
            GameState.message_requested.emit("Cael jerks back. 'Was there a reason for that?'")
        "sera":
            GameState.message_requested.emit("Nemm steps away and stares at you. 'That was not part of my contract.'")
        "novice":
            GameState.message_requested.emit("Kes flinches. 'What is wrong with you?'")
        _:
            GameState.message_requested.emit("The resident recoils from the blow.")
