extends StaticBody3D

var display_name := "Processional Bell"

func _ready() -> void:
    _build_bell()

func _build_bell() -> void:
    var post_mesh := CylinderMesh.new()
    post_mesh.top_radius = 0.12
    post_mesh.bottom_radius = 0.16
    post_mesh.height = 2.6
    var post_mat := StandardMaterial3D.new()
    post_mat.albedo_color = Color(0.23, 0.20, 0.18)
    post_mat.metallic = 0.25
    post_mat.roughness = 0.75
    post_mesh.material = post_mat
    var post := MeshInstance3D.new()
    post.mesh = post_mesh
    post.position.y = 1.3
    add_child(post)

    var bell_mesh := CylinderMesh.new()
    bell_mesh.top_radius = 0.24
    bell_mesh.bottom_radius = 0.52
    bell_mesh.height = 0.8
    var bell_mat := StandardMaterial3D.new()
    bell_mat.albedo_color = Color(0.37, 0.29, 0.18)
    bell_mat.metallic = 0.7
    bell_mat.roughness = 0.42
    bell_mesh.material = bell_mat
    var bell := MeshInstance3D.new()
    bell.mesh = bell_mesh
    bell.position = Vector3(0, 2.25, 0)
    add_child(bell)

    var shape := CylinderShape3D.new()
    shape.radius = 0.55
    shape.height = 2.8
    var collision := CollisionShape3D.new()
    collision.shape = shape
    collision.position.y = 1.4
    add_child(collision)

func get_interaction_text() -> String:
    return "Ring bell"

func interact(_player) -> void:
    GameState.ring_processional_bell()
