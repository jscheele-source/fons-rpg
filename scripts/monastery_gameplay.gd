extends Node3D

const DAVIAN = preload("res://scripts/davian_conduct_response.gd")
const REST_BED = preload("res://scripts/rest_bed.gd")
const TRAINING = preload("res://scripts/training_station.gd")
const LORE = preload("res://scripts/lore_object.gd")

const INTERIOR_ORIGIN := Vector3(-108.0, 0.0, 0.0)

func _ready() -> void:
    _spawn_davian()
    _spawn_assigned_bed()
    _spawn_training_objects()
    _spawn_readables()

func _spawn_davian() -> void:
    var davian = DAVIAN.new()
    davian.position = INTERIOR_ORIGIN + Vector3(4.8, 0.10, -15.7)
    add_child(davian)

func _spawn_assigned_bed() -> void:
    var bed = REST_BED.new()
    bed.position = INTERIOR_ORIGIN + Vector3(10.4, 0.84, 0.2)
    add_child(bed)

func _spawn_training_objects() -> void:
    var focus = TRAINING.new()
    focus.mode = "meditation"
    focus.display_name = "Low Meditation Stone"
    focus.position = INTERIOR_ORIGIN + Vector3(-4.7, 0.10, -16.8)
    add_child(focus)

    var ember = TRAINING.new()
    ember.mode = "ember"
    ember.display_name = "Practice Ember"
    ember.position = INTERIOR_ORIGIN + Vector3(-5.45, 0.12, -14.9)
    add_child(ember)

func _spawn_readables() -> void:
    var register = LORE.new()
    register.title = "Novice Register: Dormitory East"
    register.prompt = "Read"
    register.object_color = Color(0.20, 0.16, 0.11)
    register.body = "The register is a mixture of handwriting and later datapad printouts. Whole columns of sleeping cells are marked vacant. Several older entries have been crossed out so carefully that the names beneath can no longer be read.\n\nA recent line bears your own name, entered in a different hand from the rest."
    register.position = INTERIOR_ORIGIN + Vector3(14.7, 0.0, 6.4)
    add_child(register)

    var library_note = LORE.new()
    library_note.title = "Shelf Notice"
    library_note.prompt = "Read"
    library_note.object_color = Color(0.18, 0.19, 0.17)
    library_note.body = "RETURN COPIES TO THE SHELF FROM WHICH THEY WERE TAKEN.\n\nPhysical volumes, copied scrolls, and local datapads are all catalogued separately. A handwritten addition beneath the notice reads: [i]This does not mean the three catalogues agree.[/i]"
    library_note.position = INTERIOR_ORIGIN + Vector3(-10.2, 0.0, 3.7)
