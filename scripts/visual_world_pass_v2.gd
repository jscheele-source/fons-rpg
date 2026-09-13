extends "res://scripts/visual_world_pass.gd"

# Species anatomy now belongs to the character model itself. The earlier
# atmosphere pass glued silhouette pieces onto already-built NPCs; keeping this
# override empty prevents those proof-of-concept shapes from being added twice.
func _decorate_characters() -> void:
    pass
