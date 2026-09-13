extends StaticBody3D
class_name RestBed

var display_name := "Assigned Novice Bed"

func _ready() -> void:
    var shape := BoxShape3D.new()
    shape.size = Vector3(1.75, 0.30, 0.82)
    var collision := CollisionShape3D.new()
    collision.shape = shape
    add_child(collision)

    # A small pale slate marks this bed as the player's assignment.
    var plaque_mesh := BoxMesh.new()
    plaque_mesh.size = Vector3(0.44, 0.08, 0.24)
    var plaque_mat := StandardMaterial3D.new()
    plaque_mat.albedo_color = Color(0.46, 0.40, 0.30)
    plaque_mat.roughness = 0.94
    plaque_mesh.material = plaque_mat
    var plaque := MeshInstance3D.new()
    plaque.mesh = plaque_mesh
    plaque.position = Vector3(0.65, 0.20, 0)
    add_child(plaque)

func get_interaction_text() -> String:
    if GameState.quests.has("novice_quarters"):
        var q: Dictionary = GameState.quests["novice_quarters"]
        if q["state"] == "active" and int(q["stage"]) == 0:
            return "Inspect %s" % display_name
    return "Rest at %s" % display_name

func interact(player) -> void:
    if not GameState.quest_is_completed("first_steps"):
        GameState.message_requested.emit("The slate at the bed foot is blank.")
        return

    if GameState.quests.has("novice_quarters"):
        var q: Dictionary = GameState.quests["novice_quarters"]
        if q["state"] == "active" and int(q["stage"]) == 0:
            GameState.set_quest_stage("novice_quarters", 1)
            GameState.message_requested.emit("A thin slate at the bed foot bears your name. Someone has already placed a folded blanket beneath it.")
            return

    GameState.health = GameState.max_health
    GameState.charge = GameState.max_charge
    GameState.state_changed.emit()

    if GameState.quests.has("novice_quarters"):
        var quarters: Dictionary = GameState.quests["novice_quarters"]
        if quarters["state"] == "active" and int(quarters["stage"]) >= 1:
            GameState.complete_quest("novice_quarters", "rested")

    GameState.save_game(player)
    GameState.message_requested.emit("You rest until the bells change. Your body and inner flame recover.")
