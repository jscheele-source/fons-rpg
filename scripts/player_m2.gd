extends "res://scripts/player.gd"

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
