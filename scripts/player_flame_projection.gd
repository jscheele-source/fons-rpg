extends "res://scripts/player_m2.gd"

const FLAME_BOLT = preload("res://scripts/flame_bolt.gd")
const PROJECTION_COST_FRACTION := 0.35
const PROJECTION_COOLDOWN := 0.9

var projection_cooldown := 0.0

func _physics_process(delta: float) -> void:
    super._physics_process(delta)
    projection_cooldown = maxf(0.0, projection_cooldown - delta)

func _unhandled_input(event: InputEvent) -> void:
    super._unhandled_input(event)
    if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_Q:
        if not hud.has_modal_open():
            project_flame()

func project_flame() -> bool:
    if not bool(GameState.world_flags.get("flame_projection_learned", false)):
        hud.show_message("Davian has not taught you to project your flame. Finish his first lesson.")
        return false
    if projection_cooldown > 0.0 or hud.has_modal_open():
        return false
    var cost := GameState.max_charge * PROJECTION_COST_FRACTION
    if not GameState.spend_charge(cost):
        return false
    projection_cooldown = PROJECTION_COOLDOWN
    var forward: Vector3 = -camera.global_transform.basis.z.normalized()
    var projectile = FLAME_BOLT.new()
    var flamecraft := float(GameState.skills.get("Flamecraft", {}).get("level", 10))
    projectile.configure(self, forward, 25.0 + flamecraft * 0.4)
    get_tree().current_scene.add_child(projectile)
    projectile.global_position = camera.global_position + forward * 0.72 - Vector3(0.0, 0.11, 0.0)
    GameState.add_skill_xp("Flamecraft", 1.5)
    hud.flash_crosshair()
    hud.show_message("Flame projected: %.0f charge spent. Save your remaining energy for healing." % cost)
    return true
