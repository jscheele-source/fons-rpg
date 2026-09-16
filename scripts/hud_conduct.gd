extends "res://scripts/hud.gd"

const CONDUCT = preload("res://scripts/conduct_rules.gd")

# Journal-only text; does not create any meshes, 3-D nodes or new UI panels.
func _refresh_journal() -> void:
    super._refresh_journal()
    var section := "\n\n[font_size=19][b]Monastery Conduct[/b][/font_size]\n"
    section += CONDUCT.status_text() + "\n"
    section += "Recorded assaults: %d\n" % int(GameState.world_flags.get("conduct_total", 0))
    var opinions: Dictionary = GameState.world_flags.get("conduct_opinions", {})
    var witnesses: Dictionary = GameState.world_flags.get("conduct_witnesses", {})
    for person_id in CONDUCT.NAMES.keys():
        if not opinions.has(person_id):
            continue
        var attitude: int = int(opinions[person_id])
        var mood := "friendly" if attitude >= 55 else ("neutral" if attitude >= 45 else ("wary" if attitude >= 20 else "hostile"))
        var witnessed: int = int(witnesses.get(person_id, 0))
        section += "%s: %s" % [CONDUCT.NAMES[person_id], mood]
        if witnessed > 0:
            section += " (witnessed %d)" % witnessed
        section += "\n"
    journal_text.text += section
