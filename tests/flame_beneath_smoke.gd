extends Node3D

const MAIN = preload("res://scenes/Main.tscn")
const FBS = preload("res://scripts/flame_beneath_state.gd")

func _ready() -> void:
    GameState.new_game({"name":"Flame Quest Test","species":"Human","background":"Pilgrim","answers":[]})
    call_deferred("_run")

func _run() -> void:
    var main = MAIN.instantiate()
    add_child(main)
    for _i in range(8):
        await get_tree().process_frame

    var player = main.get_node_or_null("Player")
    var suspect = main.get_node_or_null("FlameBeneath/BrotherIlyon")
    var clue = main.get_node_or_null("FlameBeneath/VesperServicePlan")
    var panel = main.get_node_or_null("FlameBeneath/VesperDormitoryPanel")
    var chamber = main.get_node_or_null("FlameBeneath/HiddenVesperChamber")
    var leader = main.get_node_or_null("FlameBeneath/HiddenVesperChamber/VesperLeader")
    var acolyte = main.get_node_or_null("FlameBeneath/HiddenVesperChamber/VesperAcolyte")
    var initiate = main.get_node_or_null("FlameBeneath/HiddenVesperChamber/VesperInitiate")
    var varro = _named(main, "Preceptor Varro")
    if player == null or suspect == null or clue == null or panel == null or chamber == null or leader == null or acolyte == null or initiate == null or varro == null:
        _fail("Flame Beneath: required quest actor or chamber node missing.")
        return
    if suspect.get_node_or_null("CharacterModel") == null or leader.get_node_or_null("CharacterModel") == null:
        _fail("Flame Beneath: refined humanoid visuals are not active on new characters.")
        return

    suspect.choose("start")
    suspect.choose("cryptic")
    if FBS.stage() < 2 or FBS.can_find_panel():
        _fail("Flame Beneath: questioning path skipped investigation clues.")
        return
    clue.interact(player)
    if not FBS.can_find_panel() or FBS.stage() < 3:
        _fail("Flame Beneath: archive clue failed to reveal panel logic.")
        return
    panel.interact(player)
    if player.global_position.distance_to(Vector3(-155.0, 1.25, 4.8)) > 0.05 or FBS.stage() < 4:
        _fail("Flame Beneath: concealed passage does not reach the isolated chamber.")
        return

    leader.choose("truth")
    leader.choose("evidence")
    if not bool(GameState.world_flags.get("flame_beneath_evidence", false)):
        _fail("Flame Beneath: ritual truth did not create reportable evidence.")
        return
    leader.choose("fight")
    leader.take_damage(999.0, player)
    acolyte.choose("acolyte_stand_down")
    var rescue_dialogue: Dictionary = initiate.get_dialogue()
    if not _has_action(rescue_dialogue, "rescue"):
        _fail("Flame Beneath: defeated/standing-down Vespers did not expose rescue resolution.")
        return
    initiate.choose("rescue")
    if str(GameState.world_flags.get("flame_beneath_resolution", "")) != "rescued" or not bool(GameState.world_flags.get("flame_beneath_initiate_survived", false)):
        _fail("Flame Beneath: combat rescue resolution failed.")
        return

    GameState.new_game({"name":"Report Route","species":"Human","background":"Pilgrim","answers":[]})
    FBS.start()
    FBS.mark_evidence()
    var report_dialogue: Dictionary = varro.get_dialogue()
    if not _has_action(report_dialogue, "vesper_report"):
        _fail("Flame Beneath: Varro report route is unreachable with direct evidence.")
        return
    varro.choose("vesper_report")
    if str(GameState.world_flags.get("flame_beneath_resolution", "")) != "reported":
        _fail("Flame Beneath: report resolution failed.")
        return

    GameState.new_game({"name":"Join Route","species":"Human","background":"Pilgrim","answers":[]})
    FBS.start()
    leader.current_page = "truth"
    leader.choose("join")
    if str(GameState.world_flags.get("flame_beneath_resolution", "")) != "joined" or not bool(GameState.world_flags.get("vesper_siphon_learned", false)):
        _fail("Flame Beneath: join resolution failed to persist its forbidden consequence.")
        return

    print("Flame Beneath smoke test passed: investigation, archive/direct clue gate, hidden chamber, refined models, combat rescue, report and join resolutions.")
    get_tree().quit(0)

func _named(root: Node, wanted: String):
    if root.get("display_name") != null and str(root.get("display_name")) == wanted:
        return root
    for child in root.get_children():
        var found = _named(child, wanted)
        if found != null:
            return found
    return null

func _has_action(dialogue: Dictionary, action: String) -> bool:
    for choice in dialogue.get("choices", []):
        if str(choice.get("action", "")) == action:
            return true
    return false

func _fail(message: String) -> void:
    push_error(message)
    get_tree().quit(1)
