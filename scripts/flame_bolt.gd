extends Node3D
class_name FlameBolt

# A single low-poly, unlit projectile: no particles, procedural terrain, or
# additional world geometry. Damage is resolved by a short physics ray each tick.
const SPEED := 19.0
const MAX_TRAVEL := 22.0

var caster: CollisionObject3D
var direction := Vector3.FORWARD
var damage := 30.0
var distance_travelled := 0.0

func configure(source: CollisionObject3D, travel_direction: Vector3, hit_damage: float) -> void:
    caster = source
    direction = travel_direction.normalized()
    damage = hit_damage

func _ready() -> void:
    var glow := StandardMaterial3D.new()
    glow.albedo_color = Color(1.0, 0.49, 0.12)
    glow.emission_enabled = true
    glow.emission = Color(1.0, 0.31, 0.07)
    glow.emission_energy_multiplier = 2.0
    glow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    var sphere := SphereMesh.new()
    sphere.radius = 0.18
    sphere.height = 0.36
    sphere.radial_segments = 8
    sphere.rings = 4
    sphere.material = glow
    var visual := MeshInstance3D.new()
    visual.name = "VisibleFlame"
    visual.mesh = sphere
    add_child(visual)

func _physics_process(delta: float) -> void:
    var step: float = minf(SPEED * delta, MAX_TRAVEL - distance_travelled)
    if step <= 0.0:
        queue_free()
        return
    var endpoint: Vector3 = global_position + direction * step
    var query := PhysicsRayQueryParameters3D.create(global_position, endpoint)
    query.collision_mask = 1
    if is_instance_valid(caster):
        query.exclude = [caster.get_rid()]
    var collision: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
    if not collision.is_empty():
        var target = collision.get("collider")
        if target != null and target.has_method("take_damage"):
            target.take_damage(damage, caster)
        queue_free()
        return
    global_position = endpoint
    distance_travelled += step
    if distance_travelled >= MAX_TRAVEL - 0.001:
        queue_free()
