extends StaticBody3D
class_name DavianNPC

var display_name := "Elder Davian"
var body_color := Color(0.34, 0.30, 0.24)
var current_page := "start"

func _ready() -> void:
    _build_body()

func _build_body() -> void:
    var shape := CapsuleShape3D.new()
    shape.radius = 0.46
    shape.height = 1.8
    var collision := CollisionShape3D.new()
    collision.shape = shape
    collision.position.y = 0.9
    add_child(collision)

    var robe_mesh := CylinderMesh.new()
    robe_mesh.top_radius = 0.30
    robe_mesh.bottom_radius = 0.49
    robe_mesh.height = 1.55
    robe_mesh.radial_segments = 8
    var robe_mat := StandardMaterial3D.new()
    robe_mat.albedo_color = body_color
    robe_mat.roughness = 0.97
    robe_mesh.material = robe_mat
    var robe := MeshInstance3D.new()
    robe.mesh = robe_mesh
    robe.position.y = 0.82
    add_child(robe)

    var shoulder_mesh := BoxMesh.new()
    shoulder_mesh.size = Vector3(0.82, 0.18, 0.34)
    var shoulder := MeshInstance3D.new()
    shoulder.mesh = shoulder_mesh
    shoulder.position = Vector3(0, 1.48, 0)
    shoulder.material_override = robe_mat
    add_child(shoulder)

    var skin_mat := StandardMaterial3D.new()
    skin_mat.albedo_color = Color(0.33, 0.27, 0.22)
    skin_mat.roughness = 0.92
    var head_mesh := SphereMesh.new()
    head_mesh.radius = 0.31
    head_mesh.height = 0.62
    head_mesh.radial_segments = 8
    head_mesh.rings = 4
    head_mesh.material = skin_mat
    var head := MeshInstance3D.new()
    head.mesh = head_mesh
    head.position.y = 1.92
    add_child(head)

func get_interaction_text() -> String:
    return "Speak with %s" % display_name

func interact(player) -> void:
    current_page = "start"
    player.open_dialogue(self)

func choose(action: String) -> void:
    GameState.add_skill_xp("Speechcraft", 0.25)
    match action:
        "begin_lesson":
            GameState.start_quest("measure_of_fire")
            current_page = "lesson"
        "finish_lesson":
            GameState.complete_measure_of_fire()
            current_page = "finished"
        "ask_flame":
            current_page = "flame"
        "back":
            current_page = "start"

func get_dialogue() -> Dictionary:
    if current_page == "lesson":
        return {
            "speaker": display_name,
            "text": "Use the low stone first. Do not reach for fire. Gather until you can feel the difference between having strength and merely wanting it. Then kindle the practice bowl once. Once is enough.",
            "choices": [{"text": "I understand.", "action": "close"}]
        }
    if current_page == "flame":
        return {
            "speaker": display_name,
            "text": "Everyone carries it. Most people spend a lifetime calling its smallest movements instinct, courage, fever, luck, or fear. Naming a thing does not make you master of it.",
            "choices": [{"text": "Back.", "action": "back"}]
        }
    if current_page == "finished":
        return {
            "speaker": display_name,
            "text": "Good. You gathered, spent, and remained yourself. That is more important than making a larger flame.",
            "choices": [{"text": "Goodbye.", "action": "close"}]
        }

    if not GameState.quest_is_completed("first_steps"):
        return {
            "speaker": display_name,
            "text": "You are not entered among the novices yet. Finish what Varro gave you. We can speak afterward.",
            "choices": [{"text": "Goodbye.", "action": "close"}]
        }

    var q: Dictionary = GameState.quests["measure_of_fire"]
    if q["state"] == "not_started":
        return {
            "speaker": display_name,
            "text": "You have already learned to make your flame answer when frightened, wounded, or desperate. That is not the same as making it answer because you asked.",
            "choices": [
                {"text": "Will you teach me?", "action": "begin_lesson"},
                {"text": "What is the inner flame, exactly?", "action": "ask_flame"},
                {"text": "Not now.", "action": "close"},
            ]
        }
    if q["state"] == "active":
        var stage := int(q["stage"])
        if stage == 1:
            return {"speaker": display_name, "text": "The low stone. Breathe until you stop trying to force an answer.", "choices": [{"text": "Goodbye.", "action": "close"}]}
        if stage == 2:
            return {"speaker": display_name, "text": "Now the bowl. A spark you choose is worth more than a blaze you cannot stop.", "choices": [{"text": "Goodbye.", "action": "close"}]}
        if stage >= 3:
            return {
                "speaker": display_name,
                "text": "I saw the ember. More importantly, I saw you let it die when the exercise was finished.",
                "choices": [{"text": "Was that the lesson?", "action": "finish_lesson"}]
            }

    return {
        "speaker": display_name,
        "text": "Practice when you are calm. Anybody can discover strength while panicking.",
        "choices": [
            {"text": "What is the inner flame, exactly?", "action": "ask_flame"},
            {"text": "Goodbye.", "action": "close"},
        ]
    }
