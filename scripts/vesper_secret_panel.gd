extends StaticBody3D
class_name VesperSecretPanel

const FBS = preload("res://scripts/flame_beneath_state.gd")

var display_name := "sealed wall panel"
var destination := Vector3.ZERO
var return_panel := false

func _ready() -> void:
    var shape := BoxShape3D.new()
    shape.size = Vector3(0.95, 1.65, 0.18)
    var collision := CollisionShape3D.new()
    collision.shape = shape
    collision.position.y = 0.82
    add_child(collision)

    var mesh := BoxMesh.new()
    mesh.size = Vector3(0.95, 1.65, 0.18)
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.20, 0.19, 0.17) if not return_panel else Color(0.16, 0.12, 0.11)
    mat.roughness = 0.96
    mesh.material = mat
    var visual := MeshInstance3D.new()
    visual.mesh = mesh
    visual.position.y = 0.82
    add_child(visual)

func get_interaction_text() -> String:
    if return_panel:
        return "Open concealed return panel"
    if not FBS.can_find_panel():
        return "Examine extinguished wall lamp"
    return "Press stone beneath extinguished third lamp"

func interact(player) -> void:
    if not return_panel and not FBS.can_find_panel():
        GameState.message_requested.emit("The lamp is dead and the stone beneath it looks ordinary. You do not know what to look for yet.")
        return
    if not return_panel:
        FBS.reveal_chamber()
    player.global_position = destination
    player.velocity = Vector3.ZERO
    player.rotation.y = 0.0
    GameState.message_requested.emit("Stone grinds against stone. A narrow concealed passage opens.")
