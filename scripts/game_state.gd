extends Node

signal state_changed
signal skill_increased(skill_name: String, new_level: int)
signal quest_updated(quest_id: String)
signal message_requested(text: String)

var attributes := {
    "Strength": 40,
    "Endurance": 40,
    "Agility": 40,
    "Willpower": 40,
    "Intellect": 40,
    "Presence": 40,
}

var skills := {
    "Blade": {"level": 15, "xp": 0.0},
    "Athletics": {"level": 10, "xp": 0.0},
    "Meditation": {"level": 10, "xp": 0.0},
    "Flamecraft": {"level": 10, "xp": 0.0},
    "Speechcraft": {"level": 10, "xp": 0.0},
    "Technology": {"level": 10, "xp": 0.0},
    "Lore": {"level": 10, "xp": 0.0},
}

var max_health := 100.0
var health := 100.0
var max_charge := 100.0
var charge := 70.0
var credits := 25

var inventory: Dictionary = {
    "traveler_ration": {"name": "Traveler's Ration", "count": 2, "description": "Dense monastery travel food."},
}

var factions := {
    "Flamen": 0,
    "Piri Riis": 0,
    "Independent": 0,
}

var quests: Dictionary = {}
var discovered_locations: Array[String] = ["Outer Courtyard"]
var world_flags: Dictionary = {}

func _ready() -> void:
    reset_quests()

func reset_quests() -> void:
    quests = {
        "resonator_core": {
            "name": "A Question of Resonance",
            "state": "not_started",
            "stage": 0,
            "resolution": "",
            "objectives": [
                "Ask Brother Cael about work in the Outer Courtyard.",
                "Recover the Pneuma Resonator Core from the abandoned research annex.",
                "Decide who should receive the Resonator Core.",
            ],
        }
    }

func damage(amount: float) -> void:
    health = clamp(health - amount, 0.0, max_health)
    state_changed.emit()

func heal(amount: float) -> void:
    health = clamp(health + amount, 0.0, max_health)
    state_changed.emit()

func spend_charge(amount: float) -> bool:
    if charge < amount:
        message_requested.emit("Your inner flame is too weak.")
        return false
    charge -= amount
    state_changed.emit()
    return true

func restore_charge(amount: float) -> void:
    charge = clamp(charge + amount, 0.0, max_charge)
    state_changed.emit()

func add_item(item_id: String, item_name: String, count: int = 1, description: String = "") -> void:
    if inventory.has(item_id):
        inventory[item_id]["count"] += count
    else:
        inventory[item_id] = {"name": item_name, "count": count, "description": description}
    state_changed.emit()

func has_item(item_id: String, count: int = 1) -> bool:
    return inventory.has(item_id) and int(inventory[item_id]["count"]) >= count

func remove_item(item_id: String, count: int = 1) -> bool:
    if not has_item(item_id, count):
        return false
    inventory[item_id]["count"] -= count
    if inventory[item_id]["count"] <= 0:
        inventory.erase(item_id)
    state_changed.emit()
    return true

func change_reputation(faction_name: String, amount: int) -> void:
    factions[faction_name] = int(factions.get(faction_name, 0)) + amount
    message_requested.emit("%s reputation %+d" % [faction_name, amount])
    state_changed.emit()

func add_credits(amount: int) -> void:
    credits += amount
    state_changed.emit()

func add_skill_xp(skill_name: String, amount: float) -> void:
    if not skills.has(skill_name):
        return
    skills[skill_name]["xp"] += amount
    var level := int(skills[skill_name]["level"])
    var threshold := 8.0 + float(level) * 1.4
    if skills[skill_name]["xp"] >= threshold:
        skills[skill_name]["xp"] -= threshold
        skills[skill_name]["level"] = level + 1
        skill_increased.emit(skill_name, level + 1)
        message_requested.emit("%s increased to %d." % [skill_name, level + 1])
        state_changed.emit()

func start_quest(quest_id: String) -> void:
    if not quests.has(quest_id):
        return
    if quests[quest_id]["state"] == "not_started":
        quests[quest_id]["state"] = "active"
        quests[quest_id]["stage"] = 1
        quest_updated.emit(quest_id)
        message_requested.emit("Quest started: %s" % quests[quest_id]["name"])

func set_quest_stage(quest_id: String, stage: int) -> void:
    if not quests.has(quest_id):
        return
    quests[quest_id]["state"] = "active"
    quests[quest_id]["stage"] = stage
    quest_updated.emit(quest_id)
    state_changed.emit()

func complete_quest(quest_id: String, resolution: String) -> void:
    if not quests.has(quest_id):
        return
    quests[quest_id]["state"] = "completed"
    quests[quest_id]["resolution"] = resolution
    quest_updated.emit(quest_id)
    message_requested.emit("Quest completed: %s" % quests[quest_id]["name"])
    state_changed.emit()

func current_objective() -> String:
    for quest_id in quests:
        var q: Dictionary = quests[quest_id]
        if q["state"] == "active":
            var stage := int(q["stage"])
            if stage >= 0 and stage < q["objectives"].size():
                return q["objectives"][stage]
    return "Explore the Outer Courtyard."

func save_game(player: Node3D) -> void:
    var save_data := {
        "attributes": attributes,
        "skills": skills,
        "health": health,
        "charge": charge,
        "credits": credits,
        "inventory": inventory,
        "factions": factions,
        "quests": quests,
        "flags": world_flags,
        "discovered_locations": discovered_locations,
        "player_position": [player.global_position.x, player.global_position.y, player.global_position.z],
        "player_rotation_y": player.rotation.y,
    }
    var file := FileAccess.open("user://fons_save.json", FileAccess.WRITE)
    file.store_string(JSON.stringify(save_data, "  "))
    message_requested.emit("Game saved.")

func load_game(player: Node3D) -> void:
    if not FileAccess.file_exists("user://fons_save.json"):
        message_requested.emit("No save file found.")
        return
    var file := FileAccess.open("user://fons_save.json", FileAccess.READ)
    var data = JSON.parse_string(file.get_as_text())
    if typeof(data) != TYPE_DICTIONARY:
        message_requested.emit("Save file could not be read.")
        return
    attributes = data.get("attributes", attributes)
    skills = data.get("skills", skills)
    health = float(data.get("health", health))
    charge = float(data.get("charge", charge))
    credits = int(data.get("credits", credits))
    inventory = data.get("inventory", inventory)
    factions = data.get("factions", factions)
    quests = data.get("quests", quests)
    world_flags = data.get("flags", world_flags)
    discovered_locations.assign(data.get("discovered_locations", discovered_locations))
    var p = data.get("player_position", [0, 1.25, 13])
    player.global_position = Vector3(float(p[0]), float(p[1]), float(p[2]))
    player.rotation.y = float(data.get("player_rotation_y", player.rotation.y))
    state_changed.emit()
    message_requested.emit("Game loaded.")
