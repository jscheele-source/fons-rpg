extends "res://scripts/monastery_gameplay.gd"

const FLAME_DAVIAN = preload("res://scripts/davian_flame_projection.gd")

# Replace only the Davian factory. The meditation hall, novice bed and all
# existing training stations still come from the stable parent.
func _spawn_davian() -> void:
    var davian = FLAME_DAVIAN.new()
    davian.position = INTERIOR_ORIGIN + Vector3(4.8, 0.10, -15.7)
    add_child(davian)
