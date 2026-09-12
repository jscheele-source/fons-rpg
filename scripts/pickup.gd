extends StaticBody3D
class_name WorldPickup

var item_id := "item"
var display_name := "Item"
var description := ""
var item_color := Color(0.8, 0.8, 0.9)

func _ready() -> void:
    var shape := SphereShape3D.new()
    shape.radius = 0.45
    var collision := CollisionShape3D.new()
    collision.shape = shape
    add_child(collision)

    var mesh := SphereMesh.new()
    mesh.radius = 0.42
    mesh.height = 0.84
    var mat := StandardMaterial3D.new()
    mat.albedo_color = item_color
    mat.emission_enabled = true
    mat.emission = item_color * 0.6
    mat.emission_energy_multiplier = 1.6
    mesh.material = mat
    var visual := MeshInstance3D.new()
    visual.mesh = mesh
    add_child(visual)

    var light := OmniLight3D.new()
    light.light_color = item_color
    light.light_energy = 1.3
    light.omni_range = 4.0
    add_child(light)

func get_interaction_text() -> String:
    return "Take %s" % display_name

func interact(_player) -> void:
    GameState.add_item(item_id, display_name, 1, description)
    if item_id == "resonator_core":
        GameState.set_quest_stage("resonator_core", 2)
    GameState.message_requested.emit("Added to inventory: %s" % display_name)
    queue_free()
