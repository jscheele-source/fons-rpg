extends "res://scripts/hud.gd"

const CONDUCT = preload("res://scripts/conduct_rules.gd")
const ALERT = preload("res://scripts/conduct_alert.gd")

# Case file in the existing journal: no additional meshes, panels or world nodes.
func _refresh_journal() -> void:
    super._refresh_journal()
    var section := "\n\n[font_size=19][b]Monastery Conduct: Case File[/b][/font_size]\n"
    section += CONDUCT.status_text() + "\n"
    if ALERT.active():
        section += "[b]ACTIVE RESPONSE[/b] — Varro has been called. Speak to him; stand down or face a refusal charge.\n"
        if ALERT.defied():
            section += "You refused the order. The disciplinary hearing is now mandatory.\n"
    section += "Recorded assaults: %d | Hearings: %d | Service records: %d\n" % [int(GameState.world_flags.get("conduct_total", 0)), int(GameState.world_flags.get("conduct_resolutions", 0)), int(GameState.world_flags.get("conduct_service_completed", 0))]
    section += "Complied with orders: %d | Refused orders: %d\n" % [int(GameState.world_flags.get("conduct_compliances", 0)), int(GameState.world_flags.get("conduct_defiances", 0))]
    if CONDUCT.pending():
        section += "Latest report: %s\n" % str(GameState.world_flags.get("conduct_last_victim", "resident"))
        section += "Restitution at this hearing: %d credits (or disciplinary resolution).\n" % CONDUCT.fine_due()
        var heard: Array = GameState.world_flags.get("conduct_latest_witnesses", [])
        if heard.is_empty():
            section += "No other nearby witness recorded.\n"
        else:
            var names: Array[String] = []
            for person_id in heard:
                names.append(str(CONDUCT.NAMES.get(str(person_id), str(person_id))))
            section += "Nearby witnesses: %s\n" % ", ".join(names)
    if CONDUCT.service_active():
        section += "[b]Supervised restitution — outdoor checklist[/b]\n"
        for task_id in ["post", "annex", "drill"]:
            if CONDUCT.service_required(task_id):
                var checked := "[DONE]" if CONDUCT.service_done(task_id) else "[TODO]"
                section += "%s %s\n" % [checked, CONDUCT.SERVICE_TASKS[task_id]]
        if CONDUCT.service_required("drill") and not CONDUCT.service_done("drill"):
            section += "Controlled strikes: %d/3\n" % int(GameState.world_flags.get("conduct_practice_hits", 0))
        section += "Return to Preceptor Varro for sign-off.\n" if CONDUCT.service_ready() else "No dwelling access until the checklist is complete and signed.\n"
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
            section += " (heard %d incident(s))" % witnessed
        section += "\n"
    journal_text.text += section
