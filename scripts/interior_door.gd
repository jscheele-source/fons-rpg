extends StaticBody3D
class_name InteriorDoor

var display_name: String = "Door"
var destination: Vector3 = Vector3.ZERO
var arrival_yaw: float = 0.0
var door_color: Color = Color(0.10, 0.15, 0.18)
var travel_message: String = ""
var door_size: Vector3 = Vector3(3.3, 4.4, 0.34)

func _ready() -> void:
    var mesh_instance := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = door_size
    var mat := StandardMaterial3D.new()
    mat.albedo_color = door_color
    mat.metallic = 0.28
    mat.roughness = 0.72
    mesh.material = mat
    mesh_instance.mesh = mesh
    mesh_instance.position.y = door_size.y * 0.5
    add_child(mesh_instance)

    var shape := BoxShape3D.new()
    shape.size = door_size
    var collision := CollisionShape3D.new()
    collision.shape = shape
    collision.position.y = door_size.y * 0.5
    add_child(collision)

    # A narrow amber control strip keeps the ancient door just technological enough.
    var strip := MeshInstance3D.new()
    var strip_mesh := BoxMesh.new()
    strip_mesh.size = Vector3(0.10, 1.15, 0.05)
    var strip_mat := StandardMaterial3D.new()
    strip_mat.albedo_color = Color(0.52, 0.33, 0.10)
    strip_mat.emission_enabled = true
    strip_mat.emission = Color(0.42, 0.22, 0.05)
    strip_mat.emission_energy_multiplier = 1.35
    strip_mesh.material = strip_mat
    strip.mesh = strip_mesh
    strip.position = Vector3(door_size.x * 0.38, door_size.y * 0.47, -door_size.z * 0.58)
    add_child(strip)

func get_interaction_text() -> String:
    return "Enter %s" % display_name

func interact(player) -> void:
    player.global_position = destination
    player.rotation.y = arrival_yaw
    player.velocity = Vector3.ZERO
    if travel_message != "":
        GameState.message_requested.emit(travel_message)
