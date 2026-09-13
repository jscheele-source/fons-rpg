extends Node

const NPC = preload("res://scripts/npc.gd")

func _ready() -> void:
    GameState.new_game({
        "name": "Test Initiate",
        "species": "Human",
        "background": "Pilgrim",
        "answers": [],
    })
    GameState.start_quest("resonator_core")
    GameState.add_item("resonator_core", "Pneuma Resonator Core", 1)

    var npc = NPC.new()
    npc.display_name = "Surveyor Nemm"
    npc.dialogue_id = "sera"
    npc.current_page = "start"

    var root: Dictionary = npc.get_dialogue()
    if str(root.get("text", "")).find("carrying the resonator") == -1:
        push_error("Nemm root dialogue did not enter the carrying-core branch.")
        get_tree().quit(1)
        return

    npc.choose("sera_offer")
    var offer: Dictionary = npc.get_dialogue()
    if str(offer.get("text", "")).find("Measure it. Copy the readings.") == -1:
        push_error("Nemm's 'What would you do with it?' topic did not advance.")
        get_tree().quit(1)
        return

    print("Dialogue smoke test passed: Nemm offer topic advances correctly.")
    get_tree().quit(0)
