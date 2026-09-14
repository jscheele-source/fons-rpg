extends StaticBody3D
class_name DavianNPC

const VISUALS = preload("res://scripts/npc_visuals.gd")

var display_name := "Elder Davian"
var body_color := Color(0.34, 0.30, 0.24)
var current_page := "start"

func _ready() -> void:
    _build_body()

func _build_body() -> void:
    var shape := CapsuleShape3D.new()
    shape.radius = 0.43
    shape.height = 1.95
    var collision := CollisionShape3D.new()
    collision.shape = shape
    collision.position.y = 0.98
    add_child(collision)
    VISUALS.build(self, "Human", body_color, "davian")

func get_interaction_text() -> String:
    return "Speak with %s" % display_name

func interact(player) -> void:
    current_page = "start"
    player.open_dialogue(self)

func take_damage(_damage: float, source) -> void:
    var hits := int(GameState.world_flags.get("npc_hit_davian", 0)) + 1
    GameState.world_flags["npc_hit_davian"] = hits
    if hits == 1:
        GameState.change_reputation("Flamen", -1)
    if source is Node3D:
        var away: Vector3 = global_position - source.global_position
        away.y = 0.0
        if away.length() > 0.01:
            position += away.normalized() * 0.10
    GameState.message_requested.emit("Davian catches himself and looks at you for a long moment. 'I hope that was an accident.'")

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
            "text": "Use the low stone first. Don't reach for fire yet. Gather until you can feel the difference between having strength and merely wanting it. Then kindle the practice bowl once.",
            "choices": [{"text": "I understand.", "action": "close"}]
        }
    if current_page == "flame":
        return {
            "speaker": display_name,
            "text": "Everyone carries it. Most people spend their lives calling its smallest movements instinct, courage, fever, luck, or fear. A Flamen simply learns to notice it on purpose.",
            "choices": [{"text": "Back.", "action": "back"}]
        }
    if current_page == "finished":
        return {
            "speaker": display_name,
            "text": "Good. You gathered it, spent it, and stopped when you meant to stop. That's the part I wanted to see.",
            "choices": [{"text": "Goodbye.", "action": "close"}]
        }

    if not GameState.quest_is_completed("first_steps"):
        return {
            "speaker": display_name,
            "text": "Varro hasn't entered you among the novices yet. Finish what he gave you and come back afterward.",
            "choices": [{"text": "Goodbye.", "action": "close"}]
        }

    var q: Dictionary = GameState.quests["measure_of_fire"]
    if q["state"] == "not_started":
        return {
            "speaker": display_name,
            "text": "You've probably felt your flame answer when you were frightened or hurt. That's different from making it answer because you asked.",
            "choices": [
                {"text": "Will you teach me?", "action": "begin_lesson"},
                {"text": "What is the inner flame, exactly?", "action": "ask_flame"},
                {"text": "Not now.", "action": "close"},
            ]
        }
    if q["state"] == "active":
        var stage := int(q["stage"])
        if stage == 1:
            return {"speaker": display_name, "text": "The low stone first. Breathe. Stop trying to force the answer.", "choices": [{"text": "Goodbye.", "action": "close"}]}
        if stage == 2:
            return {"speaker": display_name, "text": "Now the bowl. One deliberate spark is enough.", "choices": [{"text": "Goodbye.", "action": "close"}]}
        if stage >= 3:
            return {
                "speaker": display_name,
                "text": "I saw the ember. I also saw you let it die when you were finished.",
                "choices": [{"text": "Was that the lesson?", "action": "finish_lesson"}]
            }

    return {
        "speaker": display_name,
        "text": "Practice when you're calm. Panic is very good at finding strength for you.",
        "choices": [
            {"text": "What is the inner flame, exactly?", "action": "ask_flame"},
            {"text": "Goodbye.", "action": "close"},
        ]
    }
