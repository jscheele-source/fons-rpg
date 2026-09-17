extends StaticBody3D
class_name InteriorTransition

var display_name := "stone stair"
var prompt := "Descend"
var destination := Vector3.ZERO
var arrival_yaw := 0.0
var panel_color := Color(0.18, 0.16, 0.14)
var message := "You pass deeper into the monastery."

func _ready() -> void:
    var shape := BoxShape3D.new()
    shape.size = Vector3(1.1, 1.9, 0.18)
    var collision := CollisionShape3D.new()
    collision.shape = shape
    collision.position.y = 0.95
    add_child(collision)

    var mesh := BoxMesh.new()
    mesh.size = Vector3(1.1, 1.9, 0.18)
    var mat := StandardMaterial3D.new()
    mat.albedo_color = panel_color
    mat.roughness = 0.96
    mesh.material = mat
    var visual := MeshInstance3D.new()
    visual.mesh = mesh
    visual.position.y = 0.95
    add_child(visual)

func get_interaction_text() -> String:
    return "%s — %s" % [prompt, display_name]

func interact(player) -> void:
    player.global_position = destination
    player.velocity = Vector3.ZERO
    player.rotation.y = arrival_yaw
    GameState.message_requested.emit(message)
