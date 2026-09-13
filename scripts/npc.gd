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
        "varro": return _varro_dialogue()
        "cael": return _cael_dialogue()
        "sera": return _sera_dialogue()
        "novice": return _novice_dialogue()
        _:
            return {"speaker": display_name, "text": "Safe roads.", "choices": [{"text": "Goodbye.", "action": "close"}]}

func choose(action: String) -> void:
    GameState.add_skill_xp("Speechcraft", 0.35)
    match action:
        "varro_bell_apology":
            GameState.world_flags["varro_addressed_bell"] = true
            current_page = "bell_apology"
        "varro_bell_defiant":
            GameState.world_flags["varro_addressed_bell"] = true
            GameState.world_flags["varro_defiant"] = true
            current_page = "bell_defiant"
        "varro_report":
            GameState.world_flags["varro_met"] = true
            if GameState.quests.has("first_steps"):
                GameState.set_quest_stage("first_steps", 1)
            current_page = "instructions"
        "varro_finish":
            GameState.complete_first_steps()
            current_page = "varro_done"
        "cael_work":
            GameState.start_quest("resonator_core")
            if GameState.quests.has("first_steps") and GameState.quests["first_steps"]["state"] == "active":
                GameState.set_quest_stage("first_steps", 2)
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
        "novice_lucretia": current_page = "novice_lucretia"
        "novice_bryleigh": current_page = "novice_bryleigh"
        "novice_war": current_page = "novice_war"
        "novice_bell": current_page = "novice_bell"
        "back": current_page = "start"

func _varro_dialogue() -> Dictionary:
    var first_state := "missing"
    var first_stage := -1
    if GameState.quests.has("first_steps"):
        first_state = str(GameState.quests["first_steps"]["state"])
        first_stage = int(GameState.quests["first_steps"]["stage"])

    if bool(GameState.world_flags.get("rang_processional_bell", false)) and not bool(GameState.world_flags.get("varro_addressed_bell", false)):
        return {
            "speaker": display_name,
            "text": "You are the new arrival. And you rang the processional bell before presenting yourself.",
            "choices": [
                {"text": "I didn't know what it was.", "action": "varro_bell_apology"},
                {"text": "Then it should have been marked.", "action": "varro_bell_defiant"},
            ]
        }

    if current_page == "bell_apology":
        return {
            "speaker": display_name,
            "text": "Of course you didn't. Now you do. We do not ring it for arrivals.",
            "choices": [{"text": "I was told to report to you.", "action": "varro_report"}]
        }
    if current_page == "bell_defiant":
        return {
            "speaker": display_name,
            "text": "It is marked. You cannot read the mark yet.",
            "choices": [{"text": "I was told to report to you.", "action": "varro_report"}]
        }
    if current_page == "instructions":
        return {
            "speaker": display_name,
            "text": "Find Brother Cael. Ask him for a courtyard duty. Do what he gives you, then return. If you wait for someone to explain which parts matter, you will wait a long time.",
            "choices": [{"text": "Understood.", "action": "close"}]
        }
    if current_page == "varro_done":
        return {
            "speaker": display_name,
            "text": "You may remain in the novice quarters tonight. Tomorrow you will be assigned properly.",
            "choices": [{"text": "Goodbye.", "action": "close"}]
        }

    if first_state == "active" and first_stage >= 3 and GameState.quests.has("resonator_core") and GameState.quests["resonator_core"]["state"] == "completed":
        var resolution := str(GameState.quests["resonator_core"].get("resolution", ""))
        var line := "Cael says the matter is finished."
        if resolution == "flamen":
            line = "You returned the core to Cael. Sensible. Do not mistake my approval for certainty."
        elif resolution == "piri_riis":
            line = "You gave the core to Nemm. Cael has filed an objection. A written objection here can outlive the person who made it."
        return {
            "speaker": display_name,
            "text": line,
            "choices": [
                {"text": "Was that a test?", "action": "varro_finish"},
                {"text": "I made the choice I thought was right.", "action": "varro_finish"},
            ]
        }

    if first_state == "completed":
        var line_done := "You have been entered among the novices. Try not to confuse admission with belonging."
        if bool(GameState.world_flags.get("varro_defiant", false)):
            line_done = "You are still here. That is already more useful than your argument about the bell."
        return {"speaker": display_name, "text": line_done, "choices": [{"text": "Goodbye.", "action": "close"}]}

    if first_state == "active" and first_stage >= 1:
        return {"speaker": display_name, "text": "Cael first. Return when the duty is finished.", "choices": [{"text": "Goodbye.", "action": "close"}]}

    return {
        "speaker": display_name,
        "text": "Say your name.",
        "choices": [{"text": "I am %s." % str(GameState.player_profile.get("name", "Initiate")), "action": "varro_report"}]
    }

func _cael_dialogue() -> Dictionary:
    var q: Dictionary = GameState.quests["resonator_core"]
    if q["state"] == "active" and GameState.has_item("resonator_core"):
        return {
            "speaker": display_name,
            "text": "That resonance is unmistakable. You found it. The elders will want the core sealed before three committees decide what it means.",
            "choices": [
                {"text": "Give Cael the Resonator Core.", "action": "cael_return_core"},
                {"text": "I have not decided who should have it.", "action": "close"},
            ]
        }
    if q["state"] == "completed":
        var resolution := str(q["resolution"])
        var text := "You have done enough for this courtyard today."
        if resolution == "piri_riis":
            text = "Nemm has the core. I objected. That is all I will say while the objection is fresh."
        elif resolution == "flamen":
            text = "The core is secure. Secure is not the same as understood."
        return {"speaker": display_name, "text": text, "choices": [{"text": "Goodbye.", "action": "close"}]}

    if current_page == "task":
        return {"speaker": display_name, "text": "The abandoned annex is east of the court. Bring back the Pneuma Resonator Core. If anything in there speaks with a voice you recognize, leave it there.", "choices": [{"text": "I'll return with it.", "action": "close"}]}
    if current_page == "lore":
        return {"speaker": display_name, "text": "The stone is old. The machines are older than they look. People like to put those facts in the opposite order.", "choices": [{"text": "Back.", "action": "back"}]}
    if current_page == "flame":
        return {"speaker": display_name, "text": "Sit still long enough and you will feel where your own warmth stops and the world's begins. Start there. The rest takes years.", "choices": [{"text": "Back.", "action": "back"}]}

    var choices: Array = []
    var first_steps_ready: bool = GameState.quests.has("first_steps") and GameState.quests["first_steps"]["state"] == "active" and int(GameState.quests["first_steps"]["stage"]) == 1
    if q["state"] == "not_started":
        var work_text := "Preceptor Varro sent me." if first_steps_ready else "Do you have work for me?"
        choices.append({"text": work_text, "action": "cael_work"})
    else:
        choices.append({"text": "Remind me where the core is.", "action": "cael_work"})
    choices.append({"text": "This courtyard feels older than it looks.", "action": "cael_lore"})
    choices.append({"text": "How do I begin working with the inner flame?", "action": "cael_flame"})
    choices.append({"text": "Goodbye.", "action": "close"})
    return {"speaker": display_name, "text": "Cael watches the courtyard while pretending not to.", "choices": choices}

func _sera_dialogue() -> Dictionary:
    var q: Dictionary = GameState.quests["resonator_core"]
    if q["state"] == "active" and GameState.has_item("resonator_core"):
        return {
            "speaker": display_name,
            "text": "You're carrying the resonator. Cael will want it inside monastery walls. I would rather it spend a few days somewhere with windows.",
            "choices": [
                {"text": "What would you do with it?", "action": "sera_offer"},
                {"text": "Give Sera the core.", "action": "sera_give_core"},
                {"text": "Not yet.", "action": "close"},
            ]
        }
    if current_page == "sera_offer":
        return {"speaker": display_name, "text": "Measure it. Copy the readings. Let everyone argue from the same numbers for once. I will also pay you better than the monastery will.", "choices": [{"text": "Give her the core.", "action": "sera_give_core"}, {"text": "Back.", "action": "back"}]}
    if current_page == "sera_lore":
        return {"speaker": display_name, "text": "Research. Nemm's consortium pays its fees and keeps its own shrines. Taahir's officers would rather we kept our distance. Both can call themselves Piri Riis without asking the other.", "choices": [{"text": "Back.", "action": "back"}]}
    if current_page == "sera_thanks":
        return {"speaker": display_name, "text": "Good. Whatever it proves, more than one institution will have to live with the answer.", "choices": [{"text": "Goodbye.", "action": "close"}]}
    if q["state"] == "completed" and q["resolution"] == "flamen":
        return {"speaker": display_name, "text": "You gave the core to the monastery. Sensible. Safe. Those words overlap more often than I like.", "choices": [{"text": "Goodbye.", "action": "close"}]}
    return {
        "speaker": display_name,
        "text": "Sera glances at your novice papers, then at you.",
        "choices": [
            {"text": "What brings you to Iustitia?", "action": "sera_lore"},
            {"text": "Goodbye.", "action": "close"},
        ]
    }

func _novice_dialogue() -> Dictionary:
    if current_page == "novice_lucretia":
        return {"speaker": display_name, "text": "They have stopped correcting people who call her Anointed. That's what I noticed.", "choices": [{"text": "Back.", "action": "back"}]}
    if current_page == "novice_bryleigh":
        return {"speaker": display_name, "text": "There was a librarian by that name. There are three versions of what happened and at least five reasons not to ask in the library.", "choices": [{"text": "Back.", "action": "back"}]}
    if current_page == "novice_war":
        return {"speaker": display_name, "text": "The quartermaster calls the new crates training stock. The seals on them are not from a training yard.", "choices": [{"text": "Back.", "action": "back"}]}
    if current_page == "novice_bell":
        return {"speaker": display_name, "text": "That was you? I wondered. No, I don't know what it is for. I only know everyone else knew not to touch it.", "choices": [{"text": "Back.", "action": "back"}]}

    var choices: Array = [
        {"text": "Lucretia.", "action": "novice_lucretia"},
        {"text": "Bryleigh.", "action": "novice_bryleigh"},
        {"text": "Are we really preparing for war?", "action": "novice_war"},
    ]
    if bool(GameState.world_flags.get("rang_processional_bell", false)):
        choices.append({"text": "The bell.", "action": "novice_bell"})
    choices.append({"text": "Goodbye.", "action": "close"})
    return {"speaker": display_name, "text": "First day? You still look at the signs as if they intend to help.", "choices": choices}
