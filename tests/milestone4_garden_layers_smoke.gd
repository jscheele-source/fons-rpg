extends Node3D

const MAIN = preload("res://scenes/Main.tscn")

func _ready() -> void:
    GameState.new_game({
        "name": "Garden Layers Test",
        "species": "Human",
        "background": "Pilgrim",
        "answers": [],
    })
    call_deferred("_run_test")

func _run_test() -> void:
    var main = MAIN.instantiate()
    add_child(main)

    for _i in range(6):
        await get_tree().process_frame

    var flora := main.get_node_or_null("M4FloraFontisLayer")
    var tamdin := main.get_node_or_null("M4TamdinPocket")
    var psittacus := main.get_node_or_null("M4PsittacusBed")
    var pampin := main.get_node_or_null("M4PampinGallery")
    if flora == null or tamdin == null or psittacus == null or pampin == null:
        _fail("Milestone 4: one or more botanical layers are missing.")
        return

    var flora_blooms := _count_prefix(main, "M4FloraBloom_")
    var tamdin_clusters := _count_prefix(main, "M4TamdinCluster_")
    var psittacus_bulbs := _count_prefix(main, "M4PsittacusBulb_")
    var pampin_leaves := _count_prefix(main, "M4PampinLeaf_")
    if flora_blooms < 14:
        _fail("Milestone 4: low flora layer is too sparse; expected at least 14 blooms, found %d." % flora_blooms)
        return
    if tamdin_clusters < 6:
        _fail("Milestone 4: Tamdin layer is incomplete; expected at least 6 clusters, found %d." % tamdin_clusters)
        return
    if psittacus_bulbs < 7:
        _fail("Milestone 4: Psittacus bed is incomplete; expected at least 7 bulbs, found %d." % psittacus_bulbs)
        return
    if pampin_leaves < 11:
        _fail("Milestone 4: overhead pampin layer is incomplete; expected at least 11 leaves, found %d." % pampin_leaves)
        return

    # M4 is visual layering only. Traversal continues to be enforced by the M3
    # route test, and the new plant roots must not introduce physics colliders.
    for root in [flora, tamdin, psittacus, pampin]:
        if _contains_collision_shape(root):
            _fail("Milestone 4: visual plant layer %s unexpectedly contains collision geometry." % str(root.name))
            return

    print("Milestone 4 smoke test passed: low, mid-height, bulb, and overhead alien garden layers are present without new collision snags.")
    get_tree().quit(0)

func _count_prefix(root: Node, prefix: String) -> int:
    var total := 1 if str(root.name).begins_with(prefix) else 0
    for child in root.get_children():
        total += _count_prefix(child, prefix)
    return total

func _contains_collision_shape(root: Node) -> bool:
    if root is CollisionShape3D:
        return true
    for child in root.get_children():
        if _contains_collision_shape(child):
            return true
    return false

func _fail(message: String) -> void:
    push_error(message)
    get_tree().quit(1)
