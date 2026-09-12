extends CanvasLayer

var dialogue_open := false
var journal_open := false
var text_open := false

var prompt_label: Label
var message_label: Label
var health_bar: ProgressBar
var charge_bar: ProgressBar
var quest_label: Label
var dialogue_panel: PanelContainer
var dialogue_speaker: Label
var dialogue_text: Label
var dialogue_choices: VBoxContainer
var journal_panel: PanelContainer
var journal_text: RichTextLabel
var text_panel: PanelContainer
var text_title: Label
var text_body: RichTextLabel
var crosshair: Label
var active_npc = null
var message_timer := 0.0

func _ready() -> void:
    _build_hud()
    GameState.message_requested.connect(show_message)
    GameState.state_changed.connect(refresh)
    GameState.quest_updated.connect(_on_quest_updated)
    GameState.skill_increased.connect(_on_skill_increased)
    refresh()

func _process(delta: float) -> void:
    if message_timer > 0:
        message_timer -= delta
        if message_timer <= 0:
            message_label.text = ""

func _build_hud() -> void:
    crosshair = Label.new()
    crosshair.text = "+"
    crosshair.set_anchors_preset(Control.PRESET_CENTER)
    crosshair.position = Vector2(-5, -12)
    crosshair.add_theme_font_size_override("font_size", 22)
    add_child(crosshair)

    var status := VBoxContainer.new()
    status.position = Vector2(22, 22)
    status.size = Vector2(290, 100)
    add_child(status)
    var health_label := Label.new(); health_label.text = "Health"; status.add_child(health_label)
    health_bar = ProgressBar.new(); health_bar.max_value = 100; health_bar.show_percentage = false; health_bar.custom_minimum_size = Vector2(260, 14); status.add_child(health_bar)
    var charge_label := Label.new(); charge_label.text = "Inner Flame / Charge"; status.add_child(charge_label)
    charge_bar = ProgressBar.new(); charge_bar.max_value = 100; charge_bar.show_percentage = false; charge_bar.custom_minimum_size = Vector2(260, 14); status.add_child(charge_bar)

    quest_label = Label.new()
    quest_label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
    quest_label.position = Vector2(-420, 24)
    quest_label.size = Vector2(390, 110)
    quest_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    quest_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    add_child(quest_label)

    prompt_label = Label.new()
    prompt_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
    prompt_label.position = Vector2(-250, -105)
    prompt_label.size = Vector2(500, 35)
    prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    prompt_label.add_theme_font_size_override("font_size", 18)
    add_child(prompt_label)

    message_label = Label.new()
    message_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
    message_label.position = Vector2(-310, -65)
    message_label.size = Vector2(620, 35)
    message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    add_child(message_label)

    dialogue_panel = PanelContainer.new()
    dialogue_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
    dialogue_panel.offset_left = 150; dialogue_panel.offset_top = 405; dialogue_panel.offset_right = -150; dialogue_panel.offset_bottom = -40
    dialogue_panel.visible = false
    add_child(dialogue_panel)
    var dv := VBoxContainer.new(); dv.add_theme_constant_override("separation", 10); dialogue_panel.add_child(dv)
    dialogue_speaker = Label.new(); dialogue_speaker.add_theme_font_size_override("font_size", 22); dv.add_child(dialogue_speaker)
    dialogue_text = Label.new(); dialogue_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; dialogue_text.custom_minimum_size = Vector2(0, 72); dv.add_child(dialogue_text)
    dialogue_choices = VBoxContainer.new(); dv.add_child(dialogue_choices)

    journal_panel = PanelContainer.new()
    journal_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
    journal_panel.offset_left = 140; journal_panel.offset_top = 70; journal_panel.offset_right = -140; journal_panel.offset_bottom = -70
    journal_panel.visible = false
    add_child(journal_panel)
    var jv := VBoxContainer.new(); journal_panel.add_child(jv)
    var jtitle := Label.new(); jtitle.text = "JOURNAL / CHARACTER"; jtitle.add_theme_font_size_override("font_size", 24); jv.add_child(jtitle)
    journal_text = RichTextLabel.new(); journal_text.bbcode_enabled = true; journal_text.fit_content = false; journal_text.custom_minimum_size = Vector2(0, 510); jv.add_child(journal_text)
    var close_j := Button.new(); close_j.text = "Close [J / Esc]"; close_j.pressed.connect(close_modal); jv.add_child(close_j)

    text_panel = PanelContainer.new()
    text_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
    text_panel.offset_left = 210; text_panel.offset_top = 120; text_panel.offset_right = -210; text_panel.offset_bottom = -120
    text_panel.visible = false
    add_child(text_panel)
    var tv := VBoxContainer.new(); text_panel.add_child(tv)
    text_title = Label.new(); text_title.add_theme_font_size_override("font_size", 24); tv.add_child(text_title)
    text_body = RichTextLabel.new(); text_body.bbcode_enabled = true; text_body.custom_minimum_size = Vector2(0, 350); tv.add_child(text_body)
    var close_t := Button.new(); close_t.text = "Close"; close_t.pressed.connect(close_modal); tv.add_child(close_t)

func refresh() -> void:
    health_bar.value = GameState.health
    charge_bar.value = GameState.charge
    quest_label.text = "OBJECTIVE\n" + GameState.current_objective()
    if journal_open:
        _refresh_journal()

func set_prompt(text: String) -> void:
    prompt_label.text = text if not has_modal_open() else ""

func show_message(text: String) -> void:
    message_label.text = text
    message_timer = 3.5

func flash_crosshair() -> void:
    crosshair.text = "×"
    get_tree().create_timer(0.12).timeout.connect(func(): crosshair.text = "+")

func has_modal_open() -> bool:
    return dialogue_open or journal_open or text_open

func open_dialogue(npc) -> void:
    close_modal()
    active_npc = npc
    dialogue_open = true
    dialogue_panel.visible = true
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    _render_dialogue()

func _render_dialogue() -> void:
    if active_npc == null or not is_instance_valid(active_npc):
        close_modal(); return
    var data: Dictionary = active_npc.get_dialogue()
    dialogue_speaker.text = str(data.get("speaker", ""))
    dialogue_text.text = str(data.get("text", ""))
    for child in dialogue_choices.get_children():
        child.queue_free()
    for choice in data.get("choices", []):
        var button := Button.new()
        button.text = str(choice.get("text", "Continue"))
        button.alignment = HORIZONTAL_ALIGNMENT_LEFT
        button.pressed.connect(_dialogue_choice.bind(str(choice.get("action", "close"))))
        dialogue_choices.add_child(button)

func _dialogue_choice(action: String) -> void:
    if action == "close":
        close_modal()
        return
    if active_npc != null and is_instance_valid(active_npc):
        active_npc.choose(action)
        _render_dialogue()

func open_text(title: String, body: String) -> void:
    close_modal()
    text_open = true
    text_panel.visible = true
    text_title.text = title
    text_body.text = body
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func toggle_journal() -> void:
    if journal_open:
        close_modal()
        return
    close_modal()
    journal_open = true
    journal_panel.visible = true
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    _refresh_journal()

func _refresh_journal() -> void:
    var t := "[b]Attributes[/b]\n"
    for key in GameState.attributes:
        t += "%s: %s    " % [key, GameState.attributes[key]]
    t += "\n\n[b]Skills[/b]\n"
    for key in GameState.skills:
        t += "%s %d    " % [key, int(GameState.skills[key]["level"])]
    t += "\n\n[b]Faction Reputation[/b]\n"
    for key in GameState.factions:
        t += "%s: %+d\n" % [key, int(GameState.factions[key])]
    t += "\n[b]Inventory[/b]  •  Credits: %d\n" % GameState.credits
    for item_id in GameState.inventory:
        var item: Dictionary = GameState.inventory[item_id]
        t += "• %s x%d" % [item["name"], int(item["count"])]
        if str(item.get("description", "")) != "":
            t += " — %s" % item["description"]
        t += "\n"
    t += "\n[b]Quests[/b]\n"
    for quest_id in GameState.quests:
        var q: Dictionary = GameState.quests[quest_id]
        t += "[u]%s[/u] — %s\n" % [q["name"], q["state"]]
        if q["state"] == "active":
            t += "  %s\n" % q["objectives"][int(q["stage"])]
        elif q["state"] == "completed":
            t += "  Resolution: %s\n" % q["resolution"]
    t += "\n[i]Controls: WASD move • Shift sprint • Space jump • E interact • Left-click attack • F kindle/heal • M meditate • J journal • F5 save • F9 load[/i]"
    journal_text.text = t

func close_modal() -> void:
    dialogue_open = false; journal_open = false; text_open = false
    dialogue_panel.visible = false; journal_panel.visible = false; text_panel.visible = false
    active_npc = null
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_quest_updated(_quest_id: String) -> void:
    refresh()

func _on_skill_increased(_skill_name: String, _new_level: int) -> void:
    refresh()
