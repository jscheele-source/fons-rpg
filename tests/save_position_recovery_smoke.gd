extends Node3D

const MAIN = preload("res://scenes/Main.tscn")

func _ready() -> void:
    GameState.new_game({
        "name": "Save Recovery Test",
        "species": "Human",
        "background": "Pilgrim",
        "answers": [],
    })
    call_deferred("_run_test")

func _run_test() -> void:
    var main = MAIN.instantiate()
    add_child(main)

    for _i in range(4):
        await get_tree().process_frame

    var player := main.get_node_or_null("Player") as CharacterBody3D
    if player == null:
        _fail("Save recovery: player missing.")
        return

    player.global_position = Vector3(-40.0, -50.0, 0.0)
    await get_tree().physics_frame
    await get_tree().physics_frame

    if player.global_position.distance_to(Vector3(0.0, 1.25, 13.0)) > 0.2:
        _fail("Save recovery: unsafe player position did not return to courtyard; got %s." % str(player.global_position))
        return

    print("Save-position recovery smoke test passed: void coordinates return to the Outer Courtyard.")
    get_tree().quit(0)

func _fail(message: String) -> void:
    push_error(message)
    get_tree().quit(1)
