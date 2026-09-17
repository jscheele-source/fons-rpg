extends Node3D

const MAIN = preload("res://scenes/Main.tscn")
const FBS = preload("res://scripts/flame_beneath_state.gd")

func _ready() -> void:
    GameState.new_game({"name":"Records Test","species":"Human","background":"Pilgrim","answers":[]})
    call_deferred("_run")

func _run() -> void:
    var main = MAIN.instantiate()
    add_child(main)
    for _i in range(10):
        await get_tree().process_frame

    if main.get_node_or_null("WestBotanicalCloister") != null or main.get_node_or_null("M4GardenLayers") != null:
        _fail("Records expansion reintroduced garden geometry.")
        return
    var records = main.get_node_or_null("LowerRecords/LowerRecordsAnnex")
    var stair = main.get_node_or_null("LowerRecords/LowerRecordsStair")
    if records == null or stair == null:
        _fail("Lower records annex or scriptorium transition is missing.")
        return
    var clue = records.get_node_or_null("VesperDoctrineFragment")
    if clue == null or not clue.has_method("interact"):
        _fail("Restricted Vesper doctrine clue is missing.")
        return
    FBS.start()
    FBS.note_doctrine_clue()
    if not FBS.knows_channel_risk():
        _fail("Doctrine clue did not persist in quest state.")
        return
    var varro = _named(main, "Preceptor Varro")
    var davian = _named(main, "Elder Davian")
    if varro == null or davian == null:
        _fail("Varro or Davian missing after visual rework.")
        return
    if varro.get_node_or_null("CharacterModel") == null or davian.get_node_or_null("CharacterModel") == null:
        _fail("Refined character model missing on Varro or Davian.")
        return

    print("Temple records smoke test passed: safe annex, doctrine route, and refined authority models are active.")
    get_tree().quit(0)

func _named(root: Node, wanted: String):
    if root.get("display_name") != null and str(root.get("display_name")) == wanted:
        return root
    for child in root.get_children():
        var found = _named(child, wanted)
        if found != null:
            return found
    return null

func _fail(message: String) -> void:
    push_error(message)
    get_tree().quit(1)
