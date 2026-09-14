extends "res://scripts/monastery_resident_m1.gd"

func take_damage(_damage: float, source) -> void:
    var key := "resident_hit_%s" % resident_id
    var hits := int(GameState.world_flags.get(key, 0)) + 1
    GameState.world_flags[key] = hits

    if source is Node3D:
        var away: Vector3 = global_position - source.global_position
        away.y = 0.0
        if away.length() > 0.01:
            position += away.normalized() * 0.10

    if hits == 1:
        GameState.change_reputation("Flamen", -1)

    match resident_id:
        "archivist":
            GameState.message_requested.emit("Sel stumbles back from the table. 'If you're testing whether archivists bruise, the answer is yes.'")
        "keeper":
            GameState.message_requested.emit("Oru recoils and fixes you with both yellow eyes. 'Do not do that again.'")
        "sargasson_novice":
            GameState.message_requested.emit("Pell's respirator clicks sharply as he jerks away. 'What was that for?'")
        _:
            GameState.message_requested.emit("The resident recoils from the blow.")
