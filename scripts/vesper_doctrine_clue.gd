extends StaticBody3D
class_name VesperDoctrineClue

const FBS = preload("res://scripts/flame_beneath_state.gd")

func _ready() -> void:
    var shape := BoxShape3D.new()
    shape.size = Vector3(0.72, 0.10, 0.54)
    var collision := CollisionShape3D.new()
    collision.shape = shape
    collision.position.y = 0.05
    add_child(collision)

    var mesh := BoxMesh.new()
    mesh.size = Vector3(0.72, 0.10, 0.54)
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.14, 0.09, 0.07)
    mat.roughness = 0.94
    mesh.material = mat
    var visual := MeshInstance3D.new()
    visual.mesh = mesh
    visual.position.y = 0.05
    add_child(visual)

func get_interaction_text() -> String:
    return "Read restricted Vesper fragment"

func interact(player) -> void:
    FBS.note_doctrine_clue()
    player.open_text("Restricted fragment: On the Second Flame", "A copied condemnation of Vesper teaching preserves several lines of the doctrine it attacks. The author insists that charge taken from another life is not 'shared' once the donor's flame begins to collapse: the channel continues drawing until it is deliberately broken. A marginal note adds that early cells disguised lethal rites as mutual replenishment ceremonies.\n\nOne line is underlined twice: [i]Consent to the cup is not consent to be emptied.[/i]")
