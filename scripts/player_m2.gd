extends "res://scripts/player.gd"

const SAFE_COURTYARD_SPAWN := Vector3(0.0, 1.25, 13.0)

# Milestone 2 treats the current bare-hand attack as an impact rather than a
# blade strike. Later combat/equipment work can replace this with weapon data.
func attack() -> void:
    if attack_cooldown > 0.0:
        return
    attack_cooldown = 0.48
    combat_ray.force_raycast_update()
    hud.flash_crosshair()

    if not combat_ray.is_colliding():
        return

    var target = combat_ray.get_collider()
    if target == null:
        return

    var strength_value := float(GameState.attributes.get("Strength", 40))
    var impact_value := 4.0 + strength_value * 0.08

    if target.has_method("take_damage"):
        target.take_damage(impact_value, self)
        return

    if target is RigidBody3D:
        var direction := -camera.global_transform.basis.z
        direction.y += 0.18
        target.sleeping = false
        target.apply_central_impulse(direction.normalized() * (2.0 + strength_value * 0.035))

func _physics_process(delta: float) -> void:
    super._physics_process(delta)

    # Save files preserve exact player coordinates. Experimental garden builds
    # can therefore strand an otherwise-valid save in deleted terrain or below
    # the world after a rollback. Recover automatically instead of leaving the
    # player staring at nothing but the skybox.
    if _position_is_unsafe(global_position):
        _safe_respawn("Your saved position was outside the playable world. You have been returned to the Outer Courtyard.")

func _unhandled_input(event: InputEvent) -> void:
    super._unhandled_input(event)
    if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_F10:
        _safe_respawn("Emergency respawn: returned to the Outer Courtyard.")

func _position_is_unsafe(pos: Vector3) -> bool:
    # Wide enough to include the monastery interior (around x=-108) and all
    # current courtyard/garden space, while rejecting void positions from old
    # experimental builds and any fall below the map.
    return pos.y < -6.0 or pos.y > 60.0 or pos.x < -170.0 or pos.x > 90.0 or pos.z < -120.0 or pos.z > 120.0

func _safe_respawn(message: String) -> void:
    global_position = SAFE_COURTYARD_SPAWN
    velocity = Vector3.ZERO
    rotation.y = 0.0
    hud.show_message(message)
