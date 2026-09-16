extends "res://scripts/monastery_gameplay.gd"

const RESPONDING_DAVIAN = preload("res://scripts/davian_conduct_response.gd")

# Override only the NPC factory; bed, training objects and lore remain unchanged.
func _spawn_davian() -> void:
    var davian = RESPONDING_DAVIAN.new()
    davian.position = INTERIOR_ORIGIN + Vector3(4.8, 0.10, -15.7)
    add_child(davian)
