extends StaticBody3D
class_name FoundationNPC

var display_name := "Traveler"
var dialogue_id := "generic"
var body_color := Color(0.5, 0.5, 0.55)
var current_page := "start"

func _ready() -> void:
    _build_body()

func _build_body() -> void:
    var shape := CapsuleShape3D.new()
    shape.radius = 0.45
    shape.height = 1.75
    var collision := CollisionShape3D.new()
    collision.shape = shape
    collision.position.y = 0.9
    add_child(collision)

    var mesh := CapsuleMesh.new()
    mesh.radius = 0.45
    mesh.height = 1.75
    var mat := StandardMaterial3D.new()
    mat.albedo_color = body_color
    mat.roughness = 0.8
    mesh.material = mat
    var visual := MeshInstance3D.new()
    visual.mesh = mesh
    visual.position.y = 0.9
    add_child(visual)

    var head_mesh := SphereMesh.new()
    head_mesh.radius = 0.34
    head_mesh.height = 0.68
    head_mesh.material = mat
    var head := MeshInstance3D.new()
    head.mesh = head_mesh
    head.position.y = 2.0
    add_child(head)

func get_interaction_text() -> String:
    return "Speak with %s" % display_name

func interact(player) -> void:
    current_page = "start"
    player.open_dialogue(self)

func get_dialogue() -> Dictionary:
    match dialogue_id:
        "cael": return _cael_dialogue()
        "sera": return _sera_dialogue()
        _:
            return {"speaker": display_name, "text": "Safe roads, traveler.", "choices": [{"text": "Goodbye.", "action": "close"}]}

func choose(action: String) -> void:
    GameState.add_skill_xp("Speechcraft", 0.35)
    match action:
        "cael_work":
            GameState.start_quest("resonator_core")
            current_page = "task"
        "cael_lore": current_page = "lore"
        "cael_flame": current_page = "flame"
        "cael_return_core":
            if GameState.remove_item("resonator_core", 1):
                GameState.complete_quest("resonator_core", "flamen")
                GameState.change_reputation("Flamen", 5)
                GameState.add_credits(45)
                current_page = "thanks"
        "sera_lore": current_page = "sera_lore"
        "sera_offer": current_page = "sera_offer"
        "sera_give_core":
            if GameState.remove_item("resonator_core", 1):
                GameState.complete_quest("resonator_core", "piri_riis")
                GameState.change_reputation("Piri Riis", 5)
                GameState.add_credits(65)
                current_page = "sera_thanks"
        "back": current_page = "start"

func _cael_dialogue() -> Dictionary:
    var q: Dictionary = GameState.quests["resonator_core"]
    if q["state"] == "active" and GameState.has_item("resonator_core"):
        return {
            "speaker": display_name,
            "text": "That resonance is unmistakable. You found the core. The elders will want it sealed before anyone decides its power proves a doctrine.",
            "choices": [
                {"text": "Give Cael the Resonator Core.", "action": "cael_return_core"},
                {"text": "I have not decided who should have it.", "action": "close"},
            ]
        }
    if q["state"] == "completed":
        var resolution := str(q["resolution"])
        var text := "You have done enough for this courtyard today."
        if resolution == "piri_riis":
            text = "So. The Piri Riis researchers have the core. I hope your judgment proves better than our fears."
        elif resolution == "flamen":
            text = "The core is secure. Whether it is relic or instrument, it will be studied cautiously."
        return {"speaker": display_name, "text": text, "choices": [{"text": "Goodbye.", "action": "close"}]}

    if current_page == "task":
        return {"speaker": display_name, "text": "The annex lies beyond the eastern colonnade. Recover the Pneuma Resonator Core. Do not mistake possession for understanding.", "choices": [{"text": "I will return with it.", "action": "close"}]}
    if current_page == "lore":
        return {"speaker": display_name, "text": "This is an outer court of Iustitia's monastery. The old stone predates most of the machines now being wheeled through its gates. That tension is becoming our daily life.", "choices": [{"text": "Back.", "action": "back"}]}
    if current_page == "flame":
        return {"speaker": display_name, "text": "Pneuma kindles the charge we call the inner flame. Meditation can husband it; proximity to the Fons restores it. Taking that charge from living things is forbidden.", "choices": [{"text": "Back.", "action": "back"}]}

    var choices: Array = []
    if q["state"] == "not_started":
        choices.append({"text": "Do you have work for an outsider?", "action": "cael_work"})
    else:
        choices.append({"text": "Remind me where the core is.", "action": "cael_work"})
    choices.append({"text": "Tell me about this place.", "action": "cael_lore"})
    choices.append({"text": "How does the inner flame work?", "action": "cael_flame"})
    choices.append({"text": "Goodbye.", "action": "close"})
    return {"speaker": display_name, "text": "Welcome to the Outer Courtyard. These days we receive pilgrims, traders, engineers, and opportunists in nearly equal measure.", "choices": choices}

func _sera_dialogue() -> Dictionary:
    var q: Dictionary = GameState.quests["resonator_core"]
    if q["state"] == "active" and GameState.has_item("resonator_core"):
        return {
            "speaker": display_name,
            "text": "You're carrying the resonator. Cael will call it sacred. My people will call it evidence. Those are not always different things—but the people who control the evidence usually decide the story.",
            "choices": [
                {"text": "What would you do with it?", "action": "sera_offer"},
                {"text": "Give Sera the core.", "action": "sera_give_core"},
                {"text": "Not yet.", "action": "close"},
            ]
        }
    if current_page == "sera_offer":
        return {"speaker": display_name, "text": "Study it openly. Publish the readings. Let Flamen theologians argue with Piri Riis engineers where everyone can hear them. I will also pay you better than the monastery will.", "choices": [{"text": "Give her the core.", "action": "sera_give_core"}, {"text": "Back.", "action": "back"}]}
    if current_page == "sera_lore":
        return {"speaker": display_name, "text": "'Piri Riis' is a people, not a species. That seems obvious to us and strangely difficult for outsiders. We share histories, loyalties, customs, and arguments. Biology is the least interesting part.", "choices": [{"text": "Back.", "action": "back"}]}
    if current_page == "sera_thanks":
        return {"speaker": display_name, "text": "Good. Whatever it proves, more than one institution will have to live with the answer.", "choices": [{"text": "Goodbye.", "action": "close"}]}
    if q["state"] == "completed" and q["resolution"] == "flamen":
        return {"speaker": display_name, "text": "You gave the core to the monastery. Sensible. Safe. Perhaps even wise. I only hope 'safe' does not become another word for 'secret.'", "choices": [{"text": "Goodbye.", "action": "close"}]}
    return {"speaker": display_name, "text": "You are new here. So am I, depending on which century's map you trust.", "choices": [{"text": "What does Piri Riis mean?", "action": "sera_lore"}, {"text": "Goodbye.", "action": "close"}]}
