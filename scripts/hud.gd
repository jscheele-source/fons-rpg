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

const INK := Color(0.82, 0.73, 0.56)
const INK_DIM := Color(0.66, 0.58, 0.44)
const INK_BRIGHT := Color(0.95, 0.86, 0.67)
const PANEL := Color(0.052, 0.043, 0.033, 0.94)
const PANEL_ALT := Color(0.075, 0.058, 0.041, 0.97)
const BORDER := Color(0.43, 0.31, 0.17)
const BORDER_HOT := Color(0.66, 0.48, 0.25)

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

func _panel_style(bg: Color = PANEL, border_width: int = 2) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = bg
    style.border_color = BORDER
    style.border_width_left = border_width
    style.border_width_top = border_width
    style.border_width_right = border_width
    style.border_width_bottom = border_width
    style.content_margin_left = 14
    style.content_margin_right = 14
    style.content_margin_top = 11
    style.content_margin_bottom = 11
    return style

func _topic_style(bg: Color, border: Color) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = bg
    style.border_color = border
    style.border_width_left = 1
    style.border_width_top = 1
    style.border_width_right = 1
    style.border_width_bottom = 1
    style.content_margin_left = 10
    style.content_margin_right = 8
    style.content_margin_top = 4
    style.content_margin_bottom = 4
    return style

func _bar_style(color: Color) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = color
    style.border_color = Color(0.14, 0.10, 0.07)
    style.border_width_left = 1
    style.border_width_top = 1
    style.border_width_right = 1
    style.border_width_bottom = 1
    return style

func _style_button(button: Button, compact: bool = false) -> void:
    button.add_theme_font_size_override("font_size", 15 if compact else 16)
    button.add_theme_color_override("font_color", INK)
    button.add_theme_color_override("font_hover_color", INK_BRIGHT)
    button.add_theme_color_override("font_pressed_color", Color(1.0, 0.92, 0.72))
    button.add_theme_color_override("font_focus_color", INK_BRIGHT)

    var normal: StyleBoxFlat
    var hover: StyleBoxFlat
    var pressed: StyleBoxFlat
    if compact:
        normal = _topic_style(Color(0.067, 0.051, 0.037, 0.98), BORDER)
        hover = _topic_style(Color(0.115, 0.080, 0.046, 0.99), BORDER_HOT)
        pressed = _topic_style(Color(0.145, 0.095, 0.050, 0.99), BORDER_HOT)
        button.custom_minimum_size = Vector2(0, 32)
    else:
        normal = _panel_style(Color(0.080, 0.060, 0.043, 0.98), 1)
        hover = _panel_style(Color(0.135, 0.095, 0.055, 0.98), 1)
        pressed = _panel_style(Color(0.17, 0.115, 0.060, 0.98), 1)
        button.custom_minimum_size = Vector2(0, 38)

    button.add_theme_stylebox_override("normal", normal)
    button.add_theme_stylebox_override("hover", hover)
    button.add_theme_stylebox_override("pressed", pressed)
    button.add_theme_stylebox_override("focus", hover)

func _style_label(label: Label, bright: bool = false) -> void:
    label.add_theme_color_override("font_color", INK_BRIGHT if bright else INK)
    label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.78))
    label.add_theme_constant_override("shadow_offset_x", 1)
    label.add_theme_constant_override("shadow_offset_y", 1)

func _build_hud() -> void:
    crosshair = Label.new()
    crosshair.text = "·"
    crosshair.set_anchors_preset(Control.PRESET_CENTER)
    crosshair.position = Vector2(-3, -11)
    crosshair.add_theme_font_size_override("font_size", 22)
    _style_label(crosshair, true)
    add_child(crosshair)

    var status_panel := PanelContainer.new()
    status_panel.position = Vector2(18, 18)
    status_panel.size = Vector2(286, 104)
    status_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.045, 0.038, 0.031, 0.80), 1))
    add_child(status_panel)
    var status := VBoxContainer.new()
    status.add_theme_constant_override("separation", 2)
    status_panel.add_child(status)

    var health_label := Label.new()
    health_label.text = "Health"
    health_label.add_theme_font_size_override("font_size", 15)
    _style_label(health_label)
    status.add_child(health_label)
    health_bar = ProgressBar.new()
    health_bar.max_value = 100
    health_bar.show_percentage = false
    health_bar.custom_minimum_size = Vector2(250, 11)
    health_bar.add_theme_stylebox_override("background", _bar_style(Color(0.085, 0.06, 0.045)))
    health_bar.add_theme_stylebox_override("fill", _bar_style(Color(0.47, 0.10, 0.075)))
    status.add_child(health_bar)

    var charge_label := Label.new()
    charge_label.text = "Inner Flame"
    charge_label.add_theme_font_size_override("font_size", 15)
    _style_label(charge_label)
    status.add_child(charge_label)
    charge_bar = ProgressBar.new()
    charge_bar.max_value = 100
    charge_bar.show_percentage = false
    charge_bar.custom_minimum_size = Vector2(250, 11)
    charge_bar.add_theme_stylebox_override("background", _bar_style(Color(0.085, 0.06, 0.045)))
    charge_bar.add_theme_stylebox_override("fill", _bar_style(Color(0.66, 0.39, 0.09)))
    status.add_child(charge_bar)

    var quest_panel := PanelContainer.new()
    quest_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
    quest_panel.offset_left = -380
    quest_panel.offset_top = 18
    quest_panel.offset_right = -18
    quest_panel.offset_bottom = 106
    quest_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.045, 0.038, 0.031, 0.76), 1))
    add_child(quest_panel)
    quest_label = Label.new()
    quest_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    quest_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    quest_label.add_theme_font_size_override("font_size", 15)
    _style_label(quest_label)
    quest_panel.add_child(quest_label)

    prompt_label = Label.new()
    prompt_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
    prompt_label.position = Vector2(-260, -83)
    prompt_label.size = Vector2(520, 30)
    prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    prompt_label.add_theme_font_size_override("font_size", 16)
    _style_label(prompt_label, true)
    add_child(prompt_label)

    message_label = Label.new()
    message_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
    message_label.position = Vector2(-330, -49)
    message_label.size = Vector2(660, 30)
    message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    message_label.add_theme_font_size_override("font_size", 15)
    _style_label(message_label, true)
    add_child(message_label)

    dialogue_panel = PanelContainer.new()
    dialogue_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
    dialogue_panel.offset_left = 92
    dialogue_panel.offset_right = -92
    dialogue_panel.offset_top = -286
    dialogue_panel.offset_bottom = -22
    dialogue_panel.add_theme_stylebox_override("panel", _panel_style(PANEL_ALT, 2))
    dialogue_panel.visible = false
    add_child(dialogue_panel)

    var dv := VBoxContainer.new()
    dv.add_theme_constant_override("separation", 6)
    dialogue_panel.add_child(dv)

    dialogue_speaker = Label.new()
    dialogue_speaker.add_theme_font_size_override("font_size", 20)
    _style_label(dialogue_speaker, true)
    dv.add_child(dialogue_speaker)

    var rule := ColorRect.new()
    rule.color = Color(BORDER.r, BORDER.g, BORDER.b, 0.72)
    rule.custom_minimum_size = Vector2(0, 1)
    rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
    dv.add_child(rule)

    dialogue_text = Label.new()
    dialogue_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    dialogue_text.custom_minimum_size = Vector2(0, 54)
    dialogue_text.add_theme_font_size_override("font_size", 15)
    _style_label(dialogue_text)
    dv.add_child(dialogue_text)

    dialogue_choices = VBoxContainer.new()
    dialogue_choices.add_theme_constant_override("separation", 3)
    dv.add_child(dialogue_choices)

    journal_panel = PanelContainer.new()
    journal_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
    journal_panel.offset_left = 120
    journal_panel.offset_top = 54
    journal_panel.offset_right = -120
    journal_panel.offset_bottom = -54
    journal_panel.add_theme_stylebox_override("panel", _panel_style(PANEL_ALT, 2))
    journal_panel.visible = false
    add_child(journal_panel)
    var jv := VBoxContainer.new()
    jv.add_theme_constant_override("separation", 8)
    journal_panel.add_child(jv)
    var jtitle := Label.new()
    jtitle.text = "JOURNAL & RECORD"
    jtitle.add_theme_font_size_override("font_size", 22)
    _style_label(jtitle, true)
    jv.add_child(jtitle)
    journal_text = RichTextLabel.new()
    journal_text.bbcode_enabled = true
    journal_text.fit_content = false
    journal_text.custom_minimum_size = Vector2(0, 500)
    journal_text.add_theme_color_override("default_color", INK)
    journal_text.add_theme_font_size_override("normal_font_size", 15)
    jv.add_child(journal_text)
    var close_j := Button.new()
    close_j.text = "Close [J / Esc]"
    _style_button(close_j)
    close_j.pressed.connect(close_modal)
    jv.add_child(close_j)

    text_panel = PanelContainer.new()
    text_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
    text_panel.offset_left = 190
    text_panel.offset_top = 100
    text_panel.offset_right = -190
    text_panel.offset_bottom = -100
    text_panel.add_theme_stylebox_override("panel", _panel_style(PANEL_ALT, 2))
    text_panel.visible = false
    add_child(text_panel)
    var tv := VBoxContainer.new()
    tv.add_theme_constant_override("separation", 8)
    text_panel.add_child(tv)
    text_title = Label.new()
    text_title.add_theme_font_size_override("font_size", 21)
    _style_label(text_title, true)
    tv.add_child(text_title)
    text_body = RichTextLabel.new()
    text_body.bbcode_enabled = true
    text_body.custom_minimum_size = Vector2(0, 350)
    text_body.add_theme_color_override("default_color", INK)
    text_body.add_theme_font_size_override("normal_font_size", 15)
    tv.add_child(text_body)
    var close_t := Button.new()
    close_t.text = "Close"
    _style_button(close_t)
    close_t.pressed.connect(close_modal)
    tv.add_child(close_t)

func refresh() -> void:
    health_bar.max_value = GameState.max_health
    charge_bar.max_value = GameState.max_charge
    health_bar.value = GameState.health
    charge_bar.value = GameState.charge
    quest_label.text = "CURRENT DUTY\n" + GameState.current_objective()
    if journal_open:
        _refresh_journal()

func set_prompt(text: String) -> void:
    prompt_label.text = text if not has_modal_open() else ""

func show_message(text: String) -> void:
    message_label.text = text
    message_timer = 3.5

func flash_crosshair() -> void:
    crosshair.text = "×"
    get_tree().create_timer(0.12).timeout.connect(func(): crosshair.text = "·")

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
        close_modal()
        return

    var data: Dictionary = active_npc.get_dialogue()
    dialogue_speaker.text = str(data.get("speaker", ""))
    dialogue_text.text = str(data.get("text", ""))

    for child in dialogue_choices.get_children():
        child.queue_free()

    var choices: Array = data.get("choices", [])
    var choice_count: int = choices.size()
    var desired_height: float = clamp(170.0 + float(choice_count) * 36.0, 225.0, 330.0)
    dialogue_panel.offset_top = -desired_height

    for choice in choices:
        var button := Button.new()
        button.text = str(choice.get("text", "Continue"))
        button.alignment = HORIZONTAL_ALIGNMENT_LEFT
        _style_button(button, true)
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
    var t := "[font_size=19][b]Attributes[/b][/font_size]\n"
    for key in GameState.attributes:
        t += "%s: %s    " % [key, GameState.attributes[key]]
    t += "\n\n[font_size=19][b]Skills[/b][/font_size]\n"
    for key in GameState.skills:
        t += "%s %d    " % [key, int(GameState.skills[key]["level"])]
    t += "\n\n[font_size=19][b]Standing[/b][/font_size]\n"
    for key in GameState.factions:
        if key == "Piri Riis" and not bool(GameState.world_flags.get("piri_riis_known", false)):
            continue
        t += "%s: %+d\n" % [key, int(GameState.factions[key])]
    t += "\n[font_size=19][b]Inventory[/b][/font_size]   Credits: %d\n" % GameState.credits
    for item_id in GameState.inventory:
        var item: Dictionary = GameState.inventory[item_id]
        t += "• %s x%d" % [item["name"], int(item["count"])]
        if str(item.get("description", "")) != "":
            t += " — %s" % item["description"]
        t += "\n"
    t += "\n[font_size=19][b]Journal[/b][/font_size]\n"
    for quest_id in GameState.quests:
        var q: Dictionary = GameState.quests[quest_id]
        if q["state"] == "not_started":
            continue
        t += "[u]%s[/u] — %s\n" % [q["name"], q["state"]]
        if q["state"] == "active":
            t += "  %s\n" % q["objectives"][int(q["stage"])]
        elif q["state"] == "completed":
            t += "  Resolution: %s\n" % q["resolution"]
    t += "\n[i]WASD move • Shift sprint • Space jump • E interact • Left-click attack • F kindle • M meditate • R ration • J journal • F5 save • F9 load[/i]"
    journal_text.text = t

func close_modal() -> void:
    dialogue_open = false
    journal_open = false
    text_open = false
    dialogue_panel.visible = false
    journal_panel.visible = false
    text_panel.visible = false
    active_npc = null
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_quest_updated(_quest_id: String) -> void:
    refresh()

func _on_skill_increased(_skill_name: String, _new_level: int) -> void:
    refresh()
