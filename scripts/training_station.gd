extends StaticBody3D
class_name TrainingStation

var mode := "meditation"
var display_name := "Meditation Focus"

func _ready() -> void:
    if mode == "ember":
        _build_ember()
    else:
        _build_focus()

func _build_focus() -> void:
    var shape := CylinderShape3D.new()
    shape.radius = 0.58
    shape.height = 0.18
    var collision := CollisionShape3D.new()
    collision.shape = shape
    collision.position.y = 0.09
    add_child(collision)

    var mesh := CylinderMesh.new()
    mesh.top_radius = 0.54
    mesh.bottom_radius = 0.58
    mesh.height = 0.18
    mesh.radial_segments = 8
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.31, 0.28, 0.23)
    mat.roughness = 1.0
    mesh.material = mat
    var visual := MeshInstance3D.new()
    visual.mesh = mesh
    visual.position.y = 0.09
    add_child(visual)

func _build_ember() -> void:
    var shape := CylinderShape3D.new()
    shape.radius = 0.44
    shape.height = 0.72
    var collision := CollisionShape3D.new()
    collision.shape = shape
    collision.position.y = 0.36
    add_child(collision)

    var bowl_mesh := CylinderMesh.new()
    bowl_mesh.top_radius = 0.42
    bowl_mesh.bottom_radius = 0.28
    bowl_mesh.height = 0.34
    bowl_mesh.radial_segments = 8
    var bowl_mat := StandardMaterial3D.new()
    bowl_mat.albedo_color = Color(0.14, 0.12, 0.10)
    bowl_mat.metallic = 0.28
    bowl_mat.roughness = 0.72
    bowl_mesh.material = bowl_mat
    var bowl := MeshInstance3D.new()
    bowl.mesh = bowl_mesh
    bowl.position.y = 0.34
    add_child(bowl)

    var coal_mesh := SphereMesh.new()
    coal_mesh.radius = 0.16
    coal_mesh.height = 0.24
    coal_mesh.radial_segments = 6
    coal_mesh.rings = 3
    var coal_mat := StandardMaterial3D.new()
    coal_mat.albedo_color = Color(0.22, 0.08, 0.035)
    coal_mat.emission_enabled = true
    coal_mat.emission = Color(0.22, 0.045, 0.01)
    coal_mat.emission_energy_multiplier = 0.7
    coal_mesh.material = coal_mat
    var coal := MeshInstance3D.new()
    coal.mesh = coal_mesh
    coal.position.y = 0.62
    add_child(coal)

func get_interaction_text() -> String:
    if mode == "ember":
        return "Kindle %s" % display_name
    return "Use %s" % display_name

func interact(_player) -> void:
    if not GameState.quests.has("measure_of_fire"):
        return
    var q: Dictionary = GameState.quests["measure_of_fire"]
    if q["state"] != "active":
        GameState.message_requested.emit("The training place is quiet. No lesson has been assigned here.")
        return

    var stage := int(q["stage"])
    if mode == "meditation":
        if stage != 1:
            GameState.message_requested.emit("The stone is only a stone until you know what you are meant to practice.")
            return
        GameState.restore_charge(30.0)
        GameState.add_skill_xp("Meditation", 2.0)
        GameState.set_quest_stage("measure_of_fire", 2)
        GameState.message_requested.emit("You settle your breathing until the warmth inside you and the warmth around you stop feeling entirely separate.")
        return

    if stage != 2:
        GameState.message_requested.emit("The practice bowl holds only cold ash.")
        return
    if not GameState.spend_charge(12.0):
        return
    GameState.add_skill_xp("Flamecraft", 2.0)
    GameState.set_quest_stage("measure_of_fire", 3)
    GameState.message_requested.emit("A small flame catches above the ash. It lasts only a few breaths, but it answered you deliberately.")
