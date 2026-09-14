extends RigidBody3D
class_name MilestonePhysicsProp

var display_name := "Loose object"
var prop_size := Vector3(0.34, 0.12, 0.48)
var prop_color := Color(0.38, 0.24, 0.12)
var prop_mass := 0.65

func _ready() -> void:
    mass = prop_mass
    linear_damp = 2.1
    angular_damp = 2.8
    contact_monitor = true
    max_contacts_reported = 4
    collision_layer = 1
    collision_mask = 1
    freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
    freeze = true

    var shape := BoxShape3D.new()
    shape.size = prop_size
    var collision := CollisionShape3D.new()
    collision.shape = shape
    add_child(collision)

    var mesh := BoxMesh.new()
    mesh.size = prop_size
    var material := StandardMaterial3D.new()
    material.albedo_color = prop_color
    material.roughness = 0.92
    mesh.material = material
    var visual := MeshInstance3D.new()
    visual.mesh = mesh
    add_child(visual)

func get_interaction_text() -> String:
    return "Examine %s" % display_name

func interact(player) -> void:
    player.open_text(display_name, "A loose object. Unlike most of the monastery's furnishings, nothing is fastening it in place.")

func take_damage(damage: float, source) -> void:
    freeze = false
    sleeping = false
    var direction := Vector3(0, 0.25, -1)
    if source is Node3D:
        direction = global_position - source.global_position
        direction.y = max(direction.y, 0.22)
    if direction.length() < 0.01:
        direction = Vector3(0, 0.25, -1)
    direction = direction.normalized()
    var impulse_strength := clamp(1.8 + damage * 0.18, 2.0, 6.5)
    apply_central_impulse(direction * impulse_strength)
    apply_torque_impulse(Vector3(0.15, 0.55, -0.25) * impulse_strength * 0.22)
