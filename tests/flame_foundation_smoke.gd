extends Node3D

const MAIN = preload("res://scenes/Main.tscn")

func _ready() -> void:
    GameState.new_game({"name": "Flame Foundation Test", "species": "Human", "background": "Pilgrim", "answers": []})
    call_deferred("_run")

func _run() -> void:
    var main = MAIN.instantiate()
    add_child(main)
    for _i in range(8):
        await get_tree().process_frame
    await get_tree().physics_frame

    if str(main.get_script().resource_path) != "res://scripts/world_flame_foundation.gd":
        _fail("Flame foundation: stable world wrapper is not active.")
        return
    if main.get_node_or_null("MonasteryInterior/IustitiaMonasteryInterior") == null:
        _fail("Flame foundation: the working monastery interior is missing.")
        return

    var cael = _find_character(main, "Brother Cael")
    var davian = _find_character(main, "Elder Davian")
    if cael == null or davian == null:
        _fail("Flame foundation: Cael or Davian failed to spawn.")
        return
    var model = cael.get_node_or_null("CharacterModel")
    if model == null or model.get_child_count() < 20:
        _fail("Flame foundation: refined Cael has no assembled model.")
        return
    for shape in model.get_children():
        if shape is MeshInstance3D and shape.mesh is BoxMesh:
            _fail("Flame foundation: Cael still contains box-shaped body geometry.")
            return

    var player = main.get_node_or_null("Player")
    if player == null or not player.has_method("project_flame"):
        _fail("Flame foundation: projection is not present on player.")
        return
    var initial_charge := GameState.charge
    if player.project_flame() or not is_equal_approx(GameState.charge, initial_charge):
        _fail("Flame foundation: untrained projection must not spend charge or fire.")
        return

    GameState.complete_first_steps()
    GameState.complete_measure_of_fire()
    davian.choose("projection_lesson")
    if not bool(GameState.world_flags.get("flame_projection_learned", false)):
        _fail("Flame foundation: Davian did not teach projection.")
        return
    var charge_before := GameState.charge
    var expected_cost := GameState.max_charge * 0.35
    if not player.project_flame():
        _fail("Flame foundation: learned projection did not fire.")
        return
    if not is_equal_approx(charge_before - GameState.charge, expected_cost):
        _fail("Flame foundation: projection did not consume 35 percent of maximum charge.")
        return
    var found_bolt := false
    for child in get_tree().current_scene.get_children():
        if child is FlameBolt:
            found_bolt = true
            if child.get_node_or_null("VisibleFlame") == null:
                _fail("Flame foundation: projectile has no visible mesh.")
                return
    if not found_bolt:
        _fail("Flame foundation: player did not spawn a projectile.")
        return

    player.projection_cooldown = 0.0
    GameState.charge = 1.0
    if player.project_flame() or not is_equal_approx(GameState.charge, 1.0):
        _fail("Flame foundation: insufficient charge must prevent casting without spending it.")
        return
    print("Flame foundation smoke passed: stable M2 world, refined Cael, Davian training, visible bolt, high cost, and low-charge guard.")
    get_tree().quit(0)

func _find_character(root: Node, wanted: String):
    if root.get("display_name") != null and str(root.get("display_name")) == wanted:
        return root
    for child in root.get_children():
        var found = _find_character(child, wanted)
        if found != null:
            return found
    return null

func _fail(message: String) -> void:
    push_error(message)
    get_tree().quit(1)
