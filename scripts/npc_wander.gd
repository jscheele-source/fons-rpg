extends Node
class_name NPCWander

var actor: Node3D
var anchor := Vector3.ZERO
var target := Vector3.ZERO
var half_extents := Vector2(1.5, 1.5)
var walk_speed := 0.62
var wait_timer := 0.0
var moving := false
var rng := RandomNumberGenerator.new()

func _ready() -> void:
    set_process(false)

func configure(npc: Node3D, area_half_extents: Vector2, speed: float = 0.62) -> void:
    actor = npc
    anchor = npc.global_position
    target = anchor
    half_extents = area_half_extents
    walk_speed = speed
    rng.seed = hash(str(npc.get("display_name")))
    wait_timer = rng.randf_range(1.4, 3.8)
    moving = false
    _face_player_if_available()
    set_process(true)

func _process(delta: float) -> void:
    if actor == null or not is_instance_valid(actor):
        queue_free()
        return

    var world := actor.get_parent()
    var hud = world.get_node_or_null("HUD")
    if hud != null and bool(hud.dialogue_open) and hud.active_npc == actor:
        moving = false
        wait_timer = 1.5
        _face_player_if_available()
        return

    if moving:
        var flat_target := Vector3(target.x, actor.global_position.y, target.z)
        var offset := flat_target - actor.global_position
        offset.y = 0.0
        var distance := offset.length()
        if distance <= 0.06:
            actor.global_position = flat_target
            moving = false
            wait_timer = rng.randf_range(2.5, 6.5)
            return

        _face(flat_target)
        var step: float = minf(walk_speed * delta, distance)
        actor.global_position += offset.normalized() * step
        return

    wait_timer -= delta
    if wait_timer <= 0.0:
        _choose_target()

func _choose_target() -> void:
    # Small post-specific rectangles keep these first wandering NPCs in places
    # that are already known to be walkable. Later this can be replaced by a
    # real navigation mesh and daily schedules.
    target = anchor + Vector3(
        rng.randf_range(-half_extents.x, half_extents.x),
        0.0,
        rng.randf_range(-half_extents.y, half_extents.y)
    )
    moving = true

func _face_player_if_available() -> void:
    if actor == null:
        return
    var world := actor.get_parent()
    if world == null:
        actor.rotation.y += PI
        return
    var player := world.get_node_or_null("Player") as Node3D
    if player != null:
        _face(player.global_position)
    else:
        actor.rotation.y += PI

func _face(point: Vector3) -> void:
    if actor == null:
        return
    var flat := Vector3(point.x, actor.global_position.y, point.z)
    if flat.distance_squared_to(actor.global_position) < 0.0001:
        return
    # Godot's Node3D.look_at points local -Z toward the target, which matches
    # the front of the low-poly NPC models (eyes/muzzles/beaks are on -Z).
    actor.look_at(flat, Vector3.UP)
