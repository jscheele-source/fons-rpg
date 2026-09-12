extends StaticBody3D
class_name TravelMarker

var display_name := "Shuttle Marker"
var destination := Vector3.ZERO
var marker_color := Color(0.22, 0.5, 0.62)

func _ready() -> void:
    var shape := CylinderShape3D.new()
    shape.radius = 0.6
    shape.height = 1.8
    var collision := CollisionShape3D.new()
    collision.shape = shape
    collision.position.y = 0.9
    add_child(collision)

    var mesh := CylinderMesh.new()
    mesh.top_radius = 0.35
    mesh.bottom_radius = 0.6
    mesh.height = 1.8
    var mat := StandardMaterial3D.new()
    mat.albedo_color = marker_color
    mat.emission_enabled = true
    mat.emission = marker_color * 0.25
    mesh.material = mat
    var visual := MeshInstance3D.new()
    visual.mesh = mesh
    visual.position.y = 0.9
    add_child(visual)

func get_interaction_text() -> String:
    return "Use %s" % display_name

func interact(player) -> void:
    player.global_position = destination
    GameState.message_requested.emit("You travel by monastery shuttle marker.")
