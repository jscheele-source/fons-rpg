extends "res://scripts/hud_conduct.gd"

const FBS = preload("res://scripts/flame_beneath_state.gd")

func refresh() -> void:
    super.refresh()
    if FBS.started() and not FBS.completed():
        quest_label.text = "THE FLAME BENEATH\n" + FBS.objective()

func _refresh_journal() -> void:
    super._refresh_journal()
    var quest_text := FBS.journal_text()
    if quest_text != "":
        journal_text.text += "\n\n[font_size=19][b]Investigation[/b][/font_size]\n" + quest_text
