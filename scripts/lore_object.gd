extends StaticBody3D
class_name LoreObject

var title := "Terminal"
var body := ""
var prompt := "Read"
var object_color := Color(0.15, 0.28, 0.32)

func _ready() -> void:
    var shape := BoxShape3D.new()
    shape.size = Vector3(1.1, 1.4, 0.55)
    var collision := CollisionShape3D.new()
    collision.shape = shape
    collision.position.y = 0.7
    add_child(collision)

    var mesh := BoxMesh.new()
    mesh.size = Vector3(1.1, 1.4, 0.55)
    var mat := StandardMaterial3D.new()
    mat.albedo_color = object_color
    mat.metallic = 0.65
    mat.roughness = 0.35
    mesh.material = mat
    var visual := MeshInstance3D.new()
    visual.mesh = mesh
    visual.position.y = 0.7
    add_child(visual)

func get_interaction_text() -> String:
    return "%s %s" % [prompt, title]

func interact(player) -> void:
    GameState.add_skill_xp("Technology", 0.8)
    player.open_text(title, body)
