extends StaticBody3D
class_name MonasteryResident

const VISUALS = preload("res://scripts/npc_visuals.gd")

var display_name := "Resident"
var resident_id := "generic"
var species := "Human"
var body_color := Color(0.34, 0.26, 0.18)
var current_page := "start"

func _ready() -> void:
    _build_collision()
    _build_visual()

func _build_collision() -> void:
    var shape := CapsuleShape3D.new()
    match species:
        "Gruhanian":
            shape.radius = 0.58
            shape.height = 2.05
        "Sargasson":
            shape.radius = 0.40
            shape.height = 1.45
        _:
            shape.radius = 0.43
            shape.height = 1.95
    var collision := CollisionShape3D.new()
    collision.shape = shape
    collision.position.y = shape.height * 0.5
    add_child(collision)

func _build_visual() -> void:
    if species in ["Human", "Felid", "Conglomerate", "Glauxi"]:
        VISUALS.build(self, species, body_color, resident_id)
    elif species == "Gruhanian":
        _build_gruhanian()
    elif species == "Sargasson":
        _build_sargasson()
    else:
        VISUALS.build(self, "Human", body_color, resident_id)

func get_interaction_text() -> String:
    return "Speak with %s" % display_name

func interact(player) -> void:
    current_page = "start"
    player.open_dialogue(self)

func choose(action: String) -> void:
    GameState.add_skill_xp("Speechcraft", 0.25)
    match action:
        "archive_work":
            GameState.start_quest("missing_copy")
            current_page = "archive_task"
        "archive_clue":
            current_page = "archive_clue"
        "archive_return":
            if GameState.remove_item("missing_copy", 1):
                GameState.complete_quest("missing_copy", "returned")
                GameState.change_reputation("Flamen", 1)
                GameState.add_skill_xp("Lore", 2.0)
                current_page = "archive_thanks"
        "keeper_colors":
            current_page = "keeper_colors"
        "keeper_plants":
            current_page = "keeper_plants"
        "sargasson_air":
            current_page = "sargasson_air"
        "sargasson_food":
            current_page = "sargasson_food"
        "back":
            current_page = "start"

func get_dialogue() -> Dictionary:
    match resident_id:
        "archivist": return _archivist_dialogue()
        "keeper": return _keeper_dialogue()
        "sargasson_novice": return _sargasson_dialogue()
        _:
            return {"speaker": display_name, "text": "The resident gives you a brief nod.", "choices": [{"text": "Goodbye.", "action": "close"}]}

func _archivist_dialogue() -> Dictionary:
    var q: Dictionary = GameState.quests.get("missing_copy", {})
    var state := str(q.get("state", "not_started"))

    if current_page == "archive_task":
        return {
            "speaker": display_name,
            "text": "A copied commentary on the early Quinconsistory is missing from this room. It was signed out three days ago and never returned. Find it. Do not steal an older copy to make the shelf look complete; somebody already tried that once.",
            "choices": [{"text": "Where was it last taken?", "action": "archive_clue"}, {"text": "I'll look for it.", "action": "close"}]
        }
    if current_page == "archive_clue":
        return {
            "speaker": display_name,
            "text": "The ledger says refectory. That does not mean it is in the refectory. It means the person who took it intended to eat while reading.",
            "choices": [{"text": "Back.", "action": "back"}]
        }
    if current_page == "archive_thanks":
        return {
            "speaker": display_name,
            "text": "There. A small thing returned to its proper place. Institutions are mostly that, repeated long enough to look permanent.",
            "choices": [{"text": "Goodbye.", "action": "close"}]
        }

    if state == "active" and GameState.has_item("missing_copy"):
        return {
            "speaker": display_name,
            "text": "You found the missing copy. The crease on the cover tells me exactly which table it was left on.",
            "choices": [{"text": "Return the copied scroll.", "action": "archive_return"}, {"text": "Not yet.", "action": "close"}]
        }
    if state == "active":
        return {
            "speaker": display_name,
            "text": "Still missing. Check where people become careless: tables, benches, the place beside a cup they swear they never set down.",
            "choices": [{"text": "Where was it signed out to?", "action": "archive_clue"}, {"text": "Goodbye.", "action": "close"}]
        }
    if state == "completed":
        return {
            "speaker": display_name,
            "text": "The shelf is complete again. For the moment.",
            "choices": [{"text": "Goodbye.", "action": "close"}]
        }

    return {
        "speaker": display_name,
        "text": "Archivist Sel watches you read the shelf labels before deciding whether you are worth interrupting.",
        "choices": [{"text": "Is there anything a novice can help with?", "action": "archive_work"}, {"text": "Goodbye.", "action": "close"}]
    }

func _keeper_dialogue() -> Dictionary:
    if current_page == "keeper_colors":
        return {
            "speaker": display_name,
            "text": "The western lamp is drifting toward a band your eyes probably call the same yellow as the others. Mine do not. That is useful until someone asks me to explain the difference with words invented by people who cannot see it.",
            "choices": [{"text": "Back.", "action": "back"}]
        }
    if current_page == "keeper_plants":
        return {
            "speaker": display_name,
            "text": "Most of these are imports. Iustitia grows almost nothing willingly. The order has kept some cuttings alive longer than the governments that donated them.",
            "choices": [{"text": "Back.", "action": "back"}]
        }
    return {
        "speaker": display_name,
        "text": "Keeper Oru is cleaning mineral residue from a shallow basin with great concentration.",
        "choices": [
            {"text": "You keep looking at the lamps.", "action": "keeper_colors"},
            {"text": "Do these plants grow on Iustitia?", "action": "keeper_plants"},
            {"text": "Goodbye.", "action": "close"},
        ]
    }

func _sargasson_dialogue() -> Dictionary:
    if current_page == "sargasson_air":
        return {
            "speaker": display_name,
            "text": "The canister is not uncomfortable. People keep asking that. What is uncomfortable is forgetting the spare coupling and discovering every workshop on Iustitia uses a different thread size.",
            "choices": [{"text": "Back.", "action": "back"}]
        }
    if current_page == "sargasson_food":
        return {
            "speaker": display_name,
            "text": "The broth is fine. The spoons are designed by enemies.",
            "choices": [{"text": "Back.", "action": "back"}]
        }
    return {
        "speaker": display_name,
        "text": "Novice Pell shifts on three narrow legs and moves a cup away from a stack of copied pages.",
        "choices": [
            {"text": "Does the respirator bother you?", "action": "sargasson_air"},
            {"text": "How is monastery food?", "action": "sargasson_food"},
            {"text": "Goodbye.", "action": "close"},
        ]
    }

func _build_gruhanian() -> void:
    var model := Node3D.new()
    model.name = "CharacterModel"
    add_child(model)
    var skin := Color(0.34, 0.46, 0.23)
    var skin_dark := Color(0.22, 0.31, 0.15)
    var eye := Color(0.95, 0.82, 0.16)
    _skirt(model, Vector3(0, 0.63, 0), 0.48, 0.62, 1.02, body_color)
    _box_visual(model, Vector3(0, 1.38, 0), Vector3(0.92, 0.82, 0.48), body_color.lightened(0.03))
    _box_visual(model, Vector3(0, 1.02, 0), Vector3(0.98, 0.12, 0.52), body_color.darkened(0.28))
    _limb(model, Vector3(-0.57, 1.25, 0), 0.18, 0.72, body_color, Vector3(0, 0, -9))
    _limb(model, Vector3(0.57, 1.25, 0), 0.18, 0.72, body_color, Vector3(0, 0, 9))
    _limb(model, Vector3(-0.63, 0.72, -0.02), 0.15, 0.56, skin_dark, Vector3(0, 0, -4))
    _limb(model, Vector3(0.63, 0.72, -0.02), 0.15, 0.56, skin_dark, Vector3(0, 0, 4))
    _sphere_visual(model, Vector3(0, 2.02, 0), Vector3(0.52, 0.40, 0.38), skin)
    _box_visual(model, Vector3(0, 1.93, -0.39), Vector3(0.30, 0.18, 0.42), Color(0.46, 0.39, 0.19))
    _cone_visual(model, Vector3(0, 1.91, -0.66), 0.17, 0.40, Color(0.47, 0.39, 0.18), Vector3(90, 0, 0))
    _sphere_visual(model, Vector3(-0.19, 2.10, -0.34), Vector3(0.075, 0.060, 0.040), eye)
    _sphere_visual(model, Vector3(0.19, 2.10, -0.34), Vector3(0.075, 0.060, 0.040), eye)
    _box_visual(model, Vector3(-0.24, 0.12, -0.06), Vector3(0.30, 0.20, 0.50), skin_dark)
    _box_visual(model, Vector3(0.24, 0.12, -0.06), Vector3(0.30, 0.20, 0.50), skin_dark)

func _build_sargasson() -> void:
    var model := Node3D.new()
    model.name = "CharacterModel"
    add_child(model)
    var hide := Color(0.48, 0.42, 0.34)
    var hide_dark := Color(0.29, 0.26, 0.22)
    var eye := Color(0.72, 0.83, 0.66)
    _box_visual(model, Vector3(0, 0.96, 0), Vector3(0.42, 0.82, 0.28), body_color)
    _box_visual(model, Vector3(0, 0.63, 0), Vector3(0.48, 0.10, 0.32), body_color.darkened(0.30))
    # Three narrow legs: two forward, one rear.
    _limb(model, Vector3(-0.18, 0.34, -0.11), 0.07, 0.68, hide_dark, Vector3(0, 0, -4))
    _limb(model, Vector3(0.18, 0.34, -0.11), 0.07, 0.68, hide_dark, Vector3(0, 0, 4))
    _limb(model, Vector3(0, 0.34, 0.18), 0.07, 0.66, hide_dark, Vector3(5, 0, 0))
    _limb(model, Vector3(-0.31, 0.97, 0), 0.065, 0.62, hide, Vector3(0, 0, -7))
    _limb(model, Vector3(0.31, 0.97, 0), 0.065, 0.62, hide, Vector3(0, 0, 7))
    _sphere_visual(model, Vector3(0, 1.49, 0.03), Vector3(0.25, 0.26, 0.48), hide)
    _sphere_visual(model, Vector3(0, 1.47, -0.26), Vector3(0.20, 0.18, 0.31), hide)
    # Eye stalks.
    _limb(model, Vector3(-0.12, 1.73, -0.10), 0.035, 0.32, hide_dark, Vector3(-18, 0, -12))
    _limb(model, Vector3(0.12, 1.73, -0.10), 0.035, 0.32, hide_dark, Vector3(-18, 0, 12))
    _sphere_visual(model, Vector3(-0.17, 1.88, -0.17), Vector3(0.07, 0.07, 0.06), eye)
    _sphere_visual(model, Vector3(0.17, 1.88, -0.17), Vector3(0.07, 0.07, 0.06), eye)
    # Respirator mouthpiece and hip canister.
    _box_visual(model, Vector3(0, 1.43, -0.49), Vector3(0.26, 0.16, 0.10), Color(0.10, 0.13, 0.14))
    _box_visual(model, Vector3(0.31, 0.72, 0.03), Vector3(0.20, 0.42, 0.24), Color(0.12, 0.15, 0.16))
    _limb(model, Vector3(0.23, 1.04, -0.22), 0.025, 0.88, Color(0.08, 0.10, 0.10), Vector3(38, 0, -22))

func _material(color: Color) -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.96
    return mat

func _box_visual(root: Node3D, pos: Vector3, size: Vector3, color: Color, rotation: Vector3 = Vector3.ZERO) -> void:
    var node := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    mesh.material = _material(color)
    node.mesh = mesh
    node.position = pos
    node.rotation_degrees = rotation
    root.add_child(node)

func _sphere_visual(root: Node3D, pos: Vector3, scale_value: Vector3, color: Color) -> void:
    var node := MeshInstance3D.new()
    var mesh := SphereMesh.new()
    mesh.radius = 1.0
    mesh.height = 2.0
    mesh.radial_segments = 8
    mesh.rings = 5
    mesh.material = _material(color)
    node.mesh = mesh
    node.position = pos
    node.scale = scale_value
    root.add_child(node)

func _limb(root: Node3D, pos: Vector3, radius: float, height: float, color: Color, rotation: Vector3) -> void:
    var node := MeshInstance3D.new()
    var mesh := CylinderMesh.new()
    mesh.top_radius = radius * 0.86
    mesh.bottom_radius = radius
    mesh.height = height
    mesh.radial_segments = 7
    mesh.material = _material(color)
    node.mesh = mesh
    node.position = pos
    node.rotation_degrees = rotation
    root.add_child(node)

func _cone_visual(root: Node3D, pos: Vector3, radius: float, height: float, color: Color, rotation: Vector3) -> void:
    var node := MeshInstance3D.new()
    var mesh := CylinderMesh.new()
    mesh.top_radius = 0.02
    mesh.bottom_radius = radius
    mesh.height = height
    mesh.radial_segments = 7
    mesh.material = _material(color)
    node.mesh = mesh
    node.position = pos
    node.rotation_degrees = rotation
    root.add_child(node)

func _skirt(root: Node3D, pos: Vector3, top_radius: float, bottom_radius: float, height: float, color: Color) -> void:
    var node := MeshInstance3D.new()
    var mesh := CylinderMesh.new()
    mesh.top_radius = top_radius
    mesh.bottom_radius = bottom_radius
    mesh.height = height
    mesh.radial_segments = 8
    mesh.material = _material(color)
    node.mesh = mesh
    node.position = pos
    root.add_child(node)
