extends StaticBody3D
class_name VesperArchiveClue

const FBS = preload("res://scripts/flame_beneath_state.gd")

func _ready() -> void:
    var shape := BoxShape3D.new()
    shape.size = Vector3(0.70, 0.10, 0.52)
    var collision := CollisionShape3D.new()
    collision.shape = shape
    collision.position.y = 0.05
    add_child(collision)

    var mesh := BoxMesh.new()
    mesh.size = Vector3(0.70, 0.10, 0.52)
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.18, 0.12, 0.08)
    mat.roughness = 0.92
    mesh.material = mat
    var visual := MeshInstance3D.new()
    visual.mesh = mesh
    visual.position.y = 0.05
    add_child(visual)

func get_interaction_text() -> String:
    return "Read damaged service plan"

func interact(player) -> void:
    if not FBS.started():
        player.open_text("Old service plan", "A brittle maintenance plan of the eastern dormitory. Most annotations are ordinary: lamp oil, conduit access, cracked stone. One obsolete notation reads: THIRD LAMP — DARK BY ORDER — RECESS SEALED AFTER SCHISM.")
        return
    FBS.note_archive_clue()
    player.open_text("Old service plan", "A brittle maintenance plan of the eastern dormitory. Beside a sketched row of wall lamps: THIRD LAMP — DARK BY ORDER — RECESS SEALED AFTER SCHISM. A later hand has added a phrase in cramped script: second flame, third darkness. The plan marks a hollow space behind the east wall.")
