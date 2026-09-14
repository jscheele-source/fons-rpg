extends "res://scripts/npc.gd"

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

func _varro_dialogue() -> Dictionary:
    var first_state := "missing"
    var first_stage := -1
    if GameState.quests.has("first_steps"):
        first_state = str(GameState.quests["first_steps"]["state"])
        first_stage = int(GameState.quests["first_steps"]["stage"])

    if bool(GameState.world_flags.get("rang_processional_bell", false)) and not bool(GameState.world_flags.get("varro_addressed_bell", false)):
        return {
            "speaker": display_name,
            "text": "You're the new arrival. You also rang the processional bell.",
            "choices": [
                {"text": "I didn't know what it was.", "action": "varro_bell_apology"},
                {"text": "Then someone should mark it more clearly.", "action": "varro_bell_defiant"},
            ]
        }

    if current_page == "bell_apology":
        return {
            "speaker": display_name,
            "text": "I gathered that. Now you know.",
            "choices": [{"text": "I was told to report to you.", "action": "varro_report"}]
        }
    if current_page == "bell_defiant":
        return {
            "speaker": display_name,
            "text": "It is marked. You just can't read the mark yet.",
            "choices": [{"text": "I was told to report to you.", "action": "varro_report"}]
        }
    if current_page == "instructions":
        return {
            "speaker": display_name,
            "text": "Find Cael. Tell him I sent you and take whatever duty he gives you. Come back when it's done.",
            "choices": [{"text": "Understood.", "action": "close"}]
        }
    if current_page == "varro_done":
        return {
            "speaker": display_name,
            "text": "Good. Your name is on the novice roll now. There's a bed inside with it on the slate.",
            "choices": [{"text": "Thank you.", "action": "close"}]
        }

    if first_state == "active" and first_stage >= 3 and GameState.quests.has("resonator_core") and GameState.quests["resonator_core"]["state"] == "completed":
        var resolution := str(GameState.quests["resonator_core"].get("resolution", ""))
        var line := "Cael says the matter is finished."
        if resolution == "flamen":
            line = "Cael has the core. Good. I wouldn't call the question settled, but at least it isn't humming in your pocket."
        elif resolution == "independent_research":
            line = "Nemm has the core. Cael has already filed an objection. You'll discover that objections live a very long time here."
        return {
            "speaker": display_name,
            "text": line,
            "choices": [
                {"text": "Was that a test?", "action": "varro_finish"},
                {"text": "I made the choice I thought was right.", "action": "varro_finish"},
            ]
        }

    if first_state == "completed":
        var line_done := "You're on the novice roll. Don't mistake that for knowing your way around."
        if bool(GameState.world_flags.get("varro_defiant", false)):
            line_done = "Still here? Good. Perhaps we'll survive the bell argument after all."
        return {"speaker": display_name, "text": line_done, "choices": [{"text": "Goodbye.", "action": "close"}]}

    if first_state == "active" and first_stage >= 1:
        return {"speaker": display_name, "text": "Cael first. Then me.", "choices": [{"text": "Right.", "action": "close"}]}

    return {
        "speaker": display_name,
        "text": "Name?",
        "choices": [{"text": "%s." % str(GameState.player_profile.get("name", "Initiate")), "action": "varro_report"}]
    }

func _cael_dialogue() -> Dictionary:
    var q: Dictionary = GameState.quests["resonator_core"]
    if q["state"] == "active" and GameState.has_item("resonator_core"):
        return {
            "speaker": display_name,
            "text": "I can hear it from here. So you found the thing.",
            "choices": [
                {"text": "Give Cael the Resonator Core.", "action": "cael_return_core"},
                {"text": "I haven't decided who should have it.", "action": "close"},
            ]
        }
    if q["state"] == "completed":
        var resolution := str(q["resolution"])
        var text := "You've done enough running around for one day."
        if resolution == "independent_research":
            text = "Nemm has it. I objected. I'd rather not rehearse the objection aloud."
        elif resolution == "flamen":
            text = "The core is locked away. That doesn't mean anyone understands it."
        return {"speaker": display_name, "text": text, "choices": [{"text": "Goodbye.", "action": "close"}]}

    if current_page == "task":
        return {
            "speaker": display_name,
            "text": "There's an old annex east of the court. A resonator core was left inside when the work stopped. Bring it back. If something in there starts sounding familiar, leave first and be curious later.",
            "choices": [{"text": "I'll find it.", "action": "close"}]
        }
    if current_page == "lore":
        return {
            "speaker": display_name,
            "text": "After a few years here you stop trying to guess whether the stone or the machinery came first.",
            "choices": [{"text": "Back.", "action": "back"}]
        }
    if current_page == "flame":
        return {
            "speaker": display_name,
            "text": "Start by sitting still. Notice your own warmth. Then notice what isn't yours. That's enough for the first day.",
            "choices": [{"text": "Back.", "action": "back"}]
        }

    var choices: Array = []
    var first_steps_ready: bool = GameState.quests.has("first_steps") and GameState.quests["first_steps"]["state"] == "active" and int(GameState.quests["first_steps"]["stage"]) == 1
    if q["state"] == "not_started":
        var work_text := "Varro sent me." if first_steps_ready else "Do you need a hand with anything?"
        choices.append({"text": work_text, "action": "cael_work"})
    else:
        choices.append({"text": "Where was that core again?", "action": "cael_work"})
    choices.append({"text": "How old is this place?", "action": "cael_lore"})
    choices.append({"text": "Can you show me how to work with the inner flame?", "action": "cael_flame"})
    choices.append({"text": "Goodbye.", "action": "close"})
    return {"speaker": display_name, "text": "Cael keeps one eye on the courtyard while you approach.", "choices": choices}

func _sera_dialogue() -> Dictionary:
    var q: Dictionary = GameState.quests["resonator_core"]

    if current_page == "sera_offer":
        return {
            "speaker": display_name,
            "text": "I'd measure it, duplicate the readings, and send one set off-world before anyone has time to lose the only copy. Bago pays me to be suspicious of single copies.",
            "choices": [
                {"text": "Give Nemm the core.", "action": "sera_give_core"},
                {"text": "Back.", "action": "back"},
            ]
        }
    if current_page == "sera_lore":
        return {
            "speaker": display_name,
            "text": "Bago calls this a research lease. The monastery calls it temporary accommodation. I stopped asking which phrase is on the contract."
            ,"choices": [{"text": "Back.", "action": "back"}]
        }
    if current_page == "sera_thanks":
        return {
            "speaker": display_name,
            "text": "Good. Give me an hour and there'll be two copies of every reading.",
            "choices": [{"text": "Goodbye.", "action": "close"}]
        }

    if q["state"] == "active" and GameState.has_item("resonator_core"):
        return {
            "speaker": display_name,
            "text": "That's the resonator, isn't it? Cael will want it inside. I wouldn't mind seeing what it does before a committee gives it a sacred name.",
            "choices": [
                {"text": "What would you do with it?", "action": "sera_offer"},
                {"text": "Give Nemm the core.", "action": "sera_give_core"},
                {"text": "Not yet.", "action": "close"},
            ]
        }
    if q["state"] == "completed" and q["resolution"] == "flamen":
        return {"speaker": display_name, "text": "You gave it to Cael. Fair enough. I hope somebody remembers to measure it before they lock it away.", "choices": [{"text": "Goodbye.", "action": "close"}]}
    return {
        "speaker": display_name,
        "text": "Nemm looks up from a slate covered in measurements.",
        "choices": [
            {"text": "What are you doing here?", "action": "sera_lore"},
            {"text": "Goodbye.", "action": "close"},
        ]
    }

func _novice_dialogue() -> Dictionary:
    if current_page == "novice_lucretia":
        return {"speaker": display_name, "text": "People used to correct you if you called her Anointed. They don't anymore. Make of that what you like.", "choices": [{"text": "Back.", "action": "back"}]}
    if current_page == "novice_bryleigh":
        return {"speaker": display_name, "text": "Bryleigh? I only know the stories, and none of them agree. The librarians get quiet when his name comes up.", "choices": [{"text": "Back.", "action": "back"}]}
    if current_page == "novice_war":
        return {"speaker": display_name, "text": "I don't know. There are more crates than there were last month. Someone asked whether they were for Fanum and the quartermaster nearly swallowed his tongue.", "choices": [{"text": "Back.", "action": "back"}]}
    if current_page == "novice_bell":
        return {"speaker": display_name, "text": "That was you? I heard it from the dormitory. I still don't know what it's for. I just know everyone else knew not to touch it.", "choices": [{"text": "Back.", "action": "back"}]}

    var choices: Array = [
        {"text": "What have you heard about Lucretia?", "action": "novice_lucretia"},
        {"text": "Who was Bryleigh?", "action": "novice_bryleigh"},
        {"text": "Do you think we're preparing for war?", "action": "novice_war"},
    ]
    if bool(GameState.world_flags.get("rang_processional_bell", false)):
        choices.append({"text": "About that bell...", "action": "novice_bell"})
    choices.append({"text": "Goodbye.", "action": "close"})
    return {"speaker": display_name, "text": "Kes gives you the quick, curious look of someone hoping you know more than they do.", "choices": choices}
