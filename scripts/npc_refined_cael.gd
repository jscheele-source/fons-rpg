extends "res://scripts/npc_conduct_response.gd"

const REFINED_CAEL = preload("res://scripts/refined_cael_visual.gd")

func _build_body() -> void:
    if dialogue_id != "cael":
        super._build_body()
        return
    var shape := CapsuleShape3D.new()
    shape.radius = 0.43
    shape.height = 1.95
    var collision := CollisionShape3D.new()
    collision.shape = shape
    collision.position.y = 0.98
    add_child(collision)
    REFINED_CAEL.build(self, body_color)
