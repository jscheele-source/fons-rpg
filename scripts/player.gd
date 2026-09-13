extends CharacterBody3D

const WALK_SPEED := 5.0
const SPRINT_SPEED := 7.6
const JUMP_VELOCITY := 4.7
const MOUSE_SENSITIVITY := 0.0022

@onready var camera: Camera3D = $Camera3D
@onready var interact_ray: RayCast3D = $Camera3D/InteractRay
@onready var combat_ray: RayCast3D = $Camera3D/CombatRay
@onready var hud = get_node("../HUD")

var pitch := 0.0
var attack_cooldown := 0.0
var athletics_timer := 0.0

func _ready() -> void:
    # Web browsers only allow pointer-lock after an explicit user gesture.
    # Starting visible lets the first click reliably enter the game.
    if OS.has_feature("web"):
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
        hud.show_message("Click inside the game to begin. Esc releases the mouse.")
    else:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        match event.physical_keycode:
            KEY_ESCAPE:
                if hud.has_modal_open():
                    hud.close_modal()
                else:
                    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED
            KEY_E:
                if not hud.has_modal_open():
                    interact()
            KEY_F:
                if not hud.has_modal_open():
                    kindle_flame()
            KEY_M:
                if not hud.has_modal_open():
                    meditate()
            KEY_J:
                if not hud.dialogue_open:
                    hud.toggle_journal()
            KEY_F5:
                GameState.save_game(self)
            KEY_F9:
                GameState.load_game(self)

    # In browsers, pointer lock must be requested from a click event.
    # The first click enters the game; subsequent left clicks attack.
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        if hud.has_modal_open():
            return
        if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
            hud.show_message("Mouse captured. WASD to move, E to interact, Esc to release.")
            get_viewport().set_input_as_handled()
            return
        attack()
        return

    if hud.has_modal_open():
        return
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
        pitch = clamp(pitch - event.relative.y * MOUSE_SENSITIVITY, deg_to_rad(-85), deg_to_rad(85))
        camera.rotation.x = pitch

func _physics_process(delta: float) -> void:
    attack_cooldown = max(attack_cooldown - delta, 0.0)
    if hud.has_modal_open() or Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
        velocity.x = move_toward(velocity.x, 0, WALK_SPEED)
        velocity.z = move_toward(velocity.z, 0, WALK_SPEED)
        if not is_on_floor():
            velocity.y -= 9.8 * delta
        move_and_slide()
        update_prompt()
        return

    var input_vec := Vector2.ZERO
    if Input.is_key_pressed(KEY_W):
        input_vec.y -= 1.0
    if Input.is_key_pressed(KEY_S):
        input_vec.y += 1.0
    if Input.is_key_pressed(KEY_A):
        input_vec.x -= 1.0
    if Input.is_key_pressed(KEY_D):
        input_vec.x += 1.0
    input_vec = input_vec.normalized()

    var speed := SPRINT_SPEED if Input.is_key_pressed(KEY_SHIFT) else WALK_SPEED
    var direction := (transform.basis * Vector3(input_vec.x, 0, input_vec.y)).normalized()
    if direction != Vector3.ZERO:
        velocity.x = direction.x * speed
        velocity.z = direction.z * speed
        athletics_timer += delta
        if athletics_timer >= 5.0:
            athletics_timer = 0.0
            GameState.add_skill_xp("Athletics", 1.0)
    else:
        velocity.x = move_toward(velocity.x, 0, speed * 4.0 * delta)
        velocity.z = move_toward(velocity.z, 0, speed * 4.0 * delta)

    if not is_on_floor():
        velocity.y -= 9.8 * delta
    elif Input.is_key_pressed(KEY_SPACE):
        velocity.y = JUMP_VELOCITY

    move_and_slide()
    update_prompt()

func update_prompt() -> void:
    interact_ray.force_raycast_update()
    if interact_ray.is_colliding():
        var collider = interact_ray.get_collider()
        if collider != null and collider.has_method("get_interaction_text"):
            hud.set_prompt("[E] " + str(collider.get_interaction_text()))
            return
    hud.set_prompt("")

func interact() -> void:
    interact_ray.force_raycast_update()
    if interact_ray.is_colliding():
        var collider = interact_ray.get_collider()
        if collider != null and collider.has_method("interact"):
            collider.interact(self)

func attack() -> void:
    if attack_cooldown > 0.0:
        return
    attack_cooldown = 0.55
    combat_ray.force_raycast_update()
    hud.flash_crosshair()
    if combat_ray.is_colliding():
        var collider = combat_ray.get_collider()
        if collider != null and collider.has_method("take_damage"):
            var blade_level := int(GameState.skills["Blade"]["level"])
            var damage: float = 8.0 + float(GameState.attributes["Strength"]) * 0.10 + float(blade_level) * 0.15
            collider.take_damage(damage, self)
            GameState.add_skill_xp("Blade", 1.5)

func kindle_flame() -> void:
    if GameState.spend_charge(18.0):
        GameState.heal(24.0 + GameState.skills["Flamecraft"]["level"] * 0.4)
        GameState.add_skill_xp("Flamecraft", 1.2)
        hud.show_message("You kindle your inner flame and knit your wounds.")

func meditate() -> void:
    if velocity.length() > 0.2:
        hud.show_message("You must be still to meditate.")
        return
    GameState.restore_charge(16.0 + GameState.skills["Meditation"]["level"] * 0.5)
    GameState.add_skill_xp("Meditation", 1.0)
    hud.show_message("You steady your breathing and gather Pneuma.")

func open_dialogue(npc) -> void:
    hud.open_dialogue(npc)

func open_text(title: String, body: String) -> void:
    hud.open_text(title, body)
