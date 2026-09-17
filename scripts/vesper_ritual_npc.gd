extends StaticBody3D
class_name VesperRitualNpc

const FBS = preload("res://scripts/flame_beneath_state.gd")
const VISUAL = preload("res://scripts/refined_humanoid_visual.gd")

var role := "leader"
var display_name := "Vesper"
var body_color := Color(0.20, 0.15, 0.14)
var hp := 55.0
var attack_timer := 0.0
var current_page := "start"

func _ready() -> void:
    var shape := CapsuleShape3D.new()
    shape.radius = 0.43
    shape.height = 1.95
    var collision := CollisionShape3D.new()
    collision.shape = shape
    collision.position.y = 0.98
    add_child(collision)
    var skin := Color(0.52, 0.37, 0.28)
    if role == "initiate":
        skin = Color(0.44, 0.34, 0.29)
    VISUAL.build(self, body_color, skin)
    if FBS.completed() and str(GameState.world_flags.get("flame_beneath_resolution", "")) == "reported" and role != "initiate":
        visible = false
        collision.disabled = true

func get_interaction_text() -> String:
    if role == "initiate":
        return "Speak with %s" % display_name
    if _defeated():
        return "Examine %s" % display_name
    return "Confront %s" % display_name

func interact(player) -> void:
    current_page = "start"
    player.open_dialogue(self)

func take_damage(amount: float, _source) -> void:
    if role == "initiate" or _defeated() or FBS.completed():
        return
    GameState.world_flags["flame_beneath_combat"] = true
    FBS.advance(6)
    hp -= amount
    GameState.message_requested.emit("%s takes %.0f damage." % [display_name, amount])
    if hp <= 0.0:
        hp = 0.0
        GameState.world_flags["flame_beneath_%s_defeated" % role] = true
        GameState.message_requested.emit("%s yields and collapses away from the ritual circle." % display_name)
        var collision := get_node_or_null("CollisionShape3D") as CollisionShape3D
        if collision != null:
            collision.disabled = true
        visible = false

func _process(delta: float) -> void:
    if role == "initiate" or _defeated() or FBS.completed():
        return
    if not bool(GameState.world_flags.get("flame_beneath_combat", false)):
        return
    attack_timer = maxf(0.0, attack_timer - delta)
    var player := get_tree().current_scene.get_node_or_null("Player") as Node3D
    if player == null or global_position.distance_to(player.global_position) > 10.5 or attack_timer > 0.0:
        return
    attack_timer = 1.35 if role == "leader" else 1.65
    var damage := 9.0 if role == "leader" else 6.0
    GameState.damage(damage)
    GameState.message_requested.emit("%s tears at your flame for %.0f damage." % [display_name, damage])

func _defeated() -> bool:
    return bool(GameState.world_flags.get("flame_beneath_%s_defeated" % role, false))

func get_dialogue() -> Dictionary:
    if role == "initiate":
        return _initiate_dialogue()
    if _defeated():
        return {"speaker": display_name, "text": "%s can no longer resist you." % display_name, "choices": [{"text": "Leave.", "action": "close"}]}
    if role == "acolyte":
        var choices: Array = [{"text": "Stand aside.", "action": "acolyte_stand_down"}, {"text": "Leave.", "action": "close"}]
        if FBS.knows_channel_risk():
            choices.insert(0, {"text": "The restricted records say the donor cannot end a collapsing channel. You were lied to too.", "action": "acolyte_informed"})
        return {"speaker": display_name, "text": "The younger Vesper grips the edge of the stone circle. 'I was told this was a sharing rite. I did not know they meant all of it.'", "choices": choices}

    if current_page == "truth":
        var truth_choices: Array = [{"text": "You're going to kill them.", "action": "evidence"}, {"text": "Show me how to take it.", "action": "join"}, {"text": "Not while I'm standing here.", "action": "fight"}]
        if FBS.knows_channel_risk():
            truth_choices.insert(0, {"text": "The old records say the donor loses control once the channel collapses. This was never informed consent.", "action": "doctrine_challenge"})
        return {"speaker": display_name, "text": "'The initiate offered charge willingly. That is true. What they did not understand is that a flame cannot be divided cleanly once the channel opens. We will take the whole of it, and from that death the rest of us will endure.'", "choices": truth_choices}
    if current_page == "challenged":
        return {"speaker": display_name, "text": "Corvin's expression hardens. 'You have been reading condemnations written by frightened men. Call it murder if that makes your elders easier to obey.' Behind him, Sael visibly falters.", "choices": [{"text": "Sael, you heard him. Walk away.", "action": "turn_acolyte"}, {"text": "I'm taking this to Varro.", "action": "evidence"}, {"text": "Then I'll stop you myself.", "action": "fight"}]}
    if current_page == "evidence":
        return {"speaker": display_name, "text": "The leader smiles without warmth. 'Go to your elders if you like. By the time they believe you, the rite will be finished.'", "choices": [{"text": "We'll see.", "action": "close"}, {"text": "No. It ends now.", "action": "fight"}]}
    return {"speaker": display_name, "text": "A robed Flamen stands at the head of a shallow stone circle. The initiate kneeling within it is pale and trembling. 'You were not invited. But perhaps the second flame brought you here for a reason.'", "choices": [{"text": "What are you doing to them?", "action": "truth"}, {"text": "I'm stopping this now.", "action": "fight"}, {"text": "I want to understand before I choose.", "action": "truth"}]}

func _initiate_dialogue() -> Dictionary:
    if FBS.completed():
        var survived := bool(GameState.world_flags.get("flame_beneath_initiate_survived", false))
        return {"speaker": display_name, "text": "The initiate breathes shakily beside the broken circle." if survived else "The ritual stone is cold. The initiate's flame is gone.", "choices": [{"text": "Leave.", "action": "close"}]}
    if bool(GameState.world_flags.get("flame_beneath_combat", false)):
        var leader_down := bool(GameState.world_flags.get("flame_beneath_leader_defeated", false))
        var acolyte_down := bool(GameState.world_flags.get("flame_beneath_acolyte_defeated", false)) or bool(GameState.world_flags.get("flame_beneath_acolyte_stood_down", false))
        if leader_down and acolyte_down:
            return {"speaker": display_name, "text": "'I agreed to give them some of my charge. I swear I did. Then the circle closed and they told me I would not survive it. Please—get me out.'", "choices": [{"text": "You're safe now. Come with me.", "action": "rescue"}]}
    return {"speaker": display_name, "text": "The initiate's hands shake against the stone. 'They said I would be weak for a few days. They never said I would die.'", "choices": [{"text": "Hold on. I'm getting you out.", "action": "fight"}, {"text": "Stay still for now.", "action": "close"}]}

func choose(action: String) -> void:
    match action:
        "truth":
            FBS.reveal_chamber()
            current_page = "truth"
        "doctrine_challenge":
            FBS.mark_evidence()
            GameState.add_skill_xp("Lore", 1.0)
            current_page = "challenged"
        "evidence":
            FBS.mark_evidence()
            current_page = "evidence"
        "fight":
            FBS.mark_evidence()
            GameState.world_flags["flame_beneath_combat"] = true
            FBS.advance(6)
            current_page = "start"
        "join":
            FBS.mark_evidence()
            FBS.resolve("joined")
            current_page = "start"
        "acolyte_stand_down", "acolyte_informed", "turn_acolyte":
            GameState.world_flags["flame_beneath_acolyte_stood_down"] = true
            visible = false
            var collision := get_node_or_null("CollisionShape3D") as CollisionShape3D
            if collision != null:
                collision.disabled = true
            GameState.add_skill_xp("Speechcraft", 1.0 if action == "acolyte_stand_down" else 1.5)
            GameState.message_requested.emit("Sael backs away from the circle and refuses to continue the rite.")
        "rescue":
            FBS.resolve("rescued")
            current_page = "start"
