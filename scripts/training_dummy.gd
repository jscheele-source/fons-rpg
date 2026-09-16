extends StaticBody3D
class_name TrainingDummy

const CONDUCT = preload("res://scripts/conduct_rules.gd")
var hp := 55.0

func _ready() -> void:
    var shape := BoxShape3D.new()
    shape.size = Vector3(0.8, 2.0, 0.5)
    var collision := CollisionShape3D.new()
    collision.shape = shape
    collision.position.y = 1.0
    add_child(collision)

    var mesh := BoxMesh.new()
    mesh.size = Vector3(0.8, 2.0, 0.5)
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.35, 0.22, 0.12)
    mesh.material = mat
    var visual := MeshInstance3D.new()
    visual.mesh = mesh
    visual.position.y = 1.0
    add_child(visual)

func get_interaction_text() -> String:
    if CONDUCT.service_required("post") and not CONDUCT.service_done("post"):
        return "Inspect training post for supervised service"
    return "Inspect training post"

func interact(player) -> void:
    if CONDUCT.service_required("post"):
        CONDUCT.complete_service_task("post")
        player.open_text("Training-post inspection", "You tighten its bracing, inspect the old practice damage, and record that this is where controlled force belongs. Varro still requires the annex review and, for an exclusion review, three measured practice strikes.")
        return
    player.open_text("Flamen Training Post", "A scarred training post used for blade drills. Left-click while looking at it to practice combat and raise Blade skill.")

func take_damage(amount: float, _attacker) -> void:
    hp -= amount
    GameState.message_requested.emit("Training strike: %.0f damage" % amount)
    CONDUCT.record_practice_hit()
    if hp <= 0:
        hp = 55.0
        GameState.message_requested.emit("The training post is defeated. It remains heroically wooden.")
