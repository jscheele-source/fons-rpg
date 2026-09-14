extends Control

const SPECIES := [
    "Human",
    "Felid",
    "Gruhanian",
    "Conglomerate",
    "Sargasson",
    "Glauxi",
]

const SPECIES_TEXT := {
    "Human": "Humans vary widely in build and origin. Their biology carries no unusual movement or sensory assumptions.",
    "Felid": "Catlike people ranging from small and wiry to very large and powerful. Felids possess feline senses, claws, mobile ears, and expressive tails.",
    "Gruhanian": "Large, slower-moving people with broad green heads, beaks, and yellow eyes. Gruhanians perceive a much wider range of color than most other peoples.",
    "Conglomerate": "Large yellow-green reptilian people resembling bipedal komodo dragons. Their bodies are heavy, long-tailed, and naturally hunch-backed.",
    "Sargasson": "Short, spindly people with elongated heads, eyestalks, and three legs: two forward and one rear. Off-world Sargassons normally breathe through a hip-mounted gas canister connected to a fitted mouthpiece.",
    "Glauxi": "Tall, thin owl-like people covered in protective feathers. Their arms are wings. True flight requires exceptional strength and control, but Glauxi anatomy gives them a natural advantage when learning Flamen-assisted flight.",
}

const BACKGROUNDS := [
    "Monastery Ward",
    "Provincial Guard",
    "Datapad Scholar",
    "Shuttlehand",
    "Pilgrim",
    "Drifter",
]

const BACKGROUND_TEXT := {
    "Monastery Ward": "Raised around religious houses and their routines. +5 Meditation, +5 Lore.",
    "Provincial Guard": "You learned discipline with ordinary weapons before answering the Flamen summons. +5 Blade, +5 Athletics.",
    "Datapad Scholar": "You came to the order through old texts, archives, and technical records. +5 Lore, +5 Technology.",
    "Shuttlehand": "You worked around docks, machines, cargo, and people who rarely stay anywhere long. +5 Technology, +5 Athletics.",
    "Pilgrim": "You have spent years moving between shrines, teachers, and unfamiliar customs. +5 Meditation, +5 Speechcraft.",
    "Drifter": "You learned to read strangers quickly and keep moving when a place became dangerous. +5 Athletics, +5 Speechcraft.",
}

const ATTRIBUTES := ["Strength", "Endurance", "Agility", "Willpower", "Intellect", "Presence"]
const SKILLS := ["Blade", "Athletics", "Meditation", "Flamecraft", "Speechcraft", "Technology", "Lore"]

const APTITUDES := {
    "Militant": {
        "attribute": "Strength",
        "skills": ["Blade", "Athletics", "Flamecraft"],
        "description": "The record suggests direct action, physical discipline, and the forceful use of the inner flame.",
    },
    "Warden": {
        "attribute": "Endurance",
        "skills": ["Blade", "Meditation", "Athletics"],
        "description": "The record suggests patience under pressure, defensive discipline, and steadiness in difficult places.",
    },
    "Contemplative": {
        "attribute": "Willpower",
        "skills": ["Meditation", "Flamecraft", "Lore"],
        "description": "The record suggests unusual inward attention and a natural inclination toward deliberate control of the inner flame.",
    },
    "Scholar": {
        "attribute": "Intellect",
        "skills": ["Lore", "Technology", "Meditation"],
        "description": "The record suggests a habit of understanding systems before acting, whether the system is a machine, a text, or a doctrine.",
    },
    "Envoy": {
        "attribute": "Presence",
        "skills": ["Speechcraft", "Lore", "Meditation"],
        "description": "The record suggests sensitivity to people, institutions, and the meanings hidden behind what is said aloud.",
    },
    "Wayfarer": {
        "attribute": "Agility",
        "skills": ["Athletics", "Technology", "Speechcraft"],
        "description": "The record suggests adaptability, quick judgment, and comfort moving through unfamiliar places without much guidance.",
    },
}

const APTITUDE_QUESTIONS := [
    {
        "prompt": "A sealed door fails during a storm. Nobody present knows whether the mechanism or the stone around it is older. What do you do first?",
        "options": [
            ["Force it before the weather worsens.", "Militant"],
            ["Brace the passage and make sure nobody is trapped.", "Warden"],
            ["Become still and feel for the current moving through it.", "Contemplative"],
            ["Open the housing and determine what actually failed.", "Scholar"],
            ["Find whoever last used it and ask what they noticed.", "Envoy"],
            ["Look for another route before committing to the door.", "Wayfarer"],
        ],
    },
    {
        "prompt": "In a crowded port, a stranger loudly accuses you of taking something that is plainly still in their hand. What matters first?",
        "options": [
            ["Make it clear that threatening me was a mistake.", "Militant"],
            ["Stay where I am until the confusion burns itself out.", "Warden"],
            ["Keep my temper from becoming part of the problem.", "Contemplative"],
            ["Work out why they chose me before I answer.", "Scholar"],
            ["Make the crowd laugh before the accusation can harden.", "Envoy"],
            ["Leave. Being right is not worth missing a shuttle.", "Wayfarer"],
        ],
    },
    {
        "prompt": "You wake from a dream in which a familiar voice calls your name from beneath a floor of black stone. By morning the details are already fading. What do you do?",
        "options": [
            ["If there is a place beneath the stone, I would go armed.", "Militant"],
            ["Tell a superior before curiosity becomes secrecy.", "Warden"],
            ["Return to meditation and try to hear the voice again.", "Contemplative"],
            ["Write down every detail before memory edits it.", "Scholar"],
            ["Tell someone I trust and listen to what the dream means to them.", "Envoy"],
            ["Find the floor. Dreams are easier to judge when standing over them.", "Wayfarer"],
        ],
    },
    {
        "prompt": "A teacher tells you that the inner flame becomes strongest when a person learns what they lack. Which answer comes easiest?",
        "options": [
            ["Strength is learned by spending it.", "Militant"],
            ["What I lack is the ability to endure without changing.", "Warden"],
            ["Most people cannot hear themselves clearly enough to know what they lack.", "Contemplative"],
            ["I would rather know whether the teacher can prove that claim.", "Scholar"],
            ["What we lack is often visible to other people first.", "Envoy"],
            ["If I knew what I lacked, I would already be looking for it.", "Wayfarer"],
        ],
    },
]

const GOLD := Color(0.88, 0.77, 0.56)
const GOLD_BRIGHT := Color(0.98, 0.88, 0.66)
const BROWN := Color(0.10, 0.075, 0.050, 0.96)
const BORDER := Color(0.46, 0.32, 0.17)

var content: VBoxContainer
var name_edit: LineEdit
var species_option: OptionButton
var species_description: Label
var background_option: OptionButton
var background_description: Label
var draft_profile := {}
var aptitude_scores: Dictionary = {}
var aptitude_question_index := 0
var favored_attribute_option: OptionButton
var major_skill_options: Array[OptionButton] = []
var custom_error: Label

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    _build_frame()
    _show_title()

func _panel_style(bg: Color) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = bg
    style.border_color = BORDER
    style.border_width_left = 2
    style.border_width_top = 2
    style.border_width_right = 2
    style.border_width_bottom = 2
    style.content_margin_left = 14
    style.content_margin_right = 14
    style.content_margin_top = 10
    style.content_margin_bottom = 10
    return style

func _style_input(control: Control) -> void:
    if control is LineEdit:
        control.add_theme_color_override("font_color", GOLD)
        control.add_theme_color_override("font_placeholder_color", Color(0.55, 0.48, 0.38))
        control.add_theme_stylebox_override("normal", _panel_style(Color(0.065, 0.052, 0.040, 0.98)))
        control.add_theme_stylebox_override("focus", _panel_style(Color(0.12, 0.085, 0.05, 0.98)))
    elif control is OptionButton:
        control.add_theme_color_override("font_color", GOLD)
        control.add_theme_color_override("font_hover_color", GOLD_BRIGHT)
        control.add_theme_stylebox_override("normal", _panel_style(Color(0.065, 0.052, 0.040, 0.98)))
        control.add_theme_stylebox_override("hover", _panel_style(Color(0.12, 0.085, 0.05, 0.98)))
        control.add_theme_stylebox_override("pressed", _panel_style(Color(0.15, 0.10, 0.055, 0.98)))

func _build_frame() -> void:
    var bg := ColorRect.new()
    bg.color = Color(0.035, 0.031, 0.026, 1.0)
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(bg)

    var haze := ColorRect.new()
    haze.color = Color(0.18, 0.135, 0.085, 0.20)
    haze.anchor_left = 0.0
    haze.anchor_right = 1.0
    haze.anchor_top = 0.18
    haze.anchor_bottom = 0.82
    add_child(haze)

    var shade := PanelContainer.new()
    shade.anchor_left = 0.17
    shade.anchor_right = 0.83
    shade.anchor_top = 0.035
    shade.anchor_bottom = 0.965
    shade.add_theme_stylebox_override("panel", _panel_style(Color(0.055, 0.043, 0.032, 0.92)))
    add_child(shade)

    content = VBoxContainer.new()
    content.anchor_left = 0.5
    content.anchor_right = 0.5
    content.anchor_top = 0.5
    content.anchor_bottom = 0.5
    content.offset_left = -330
    content.offset_right = 330
    content.offset_top = -315
    content.offset_bottom = 315
    content.alignment = BoxContainer.ALIGNMENT_CENTER
    content.add_theme_constant_override("separation", 12)
    add_child(content)

func _clear() -> void:
    for child in content.get_children():
        child.free()

func _heading(text: String, size: int = 36) -> Label:
    var label := Label.new()
    label.text = text
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.add_theme_font_size_override("font_size", size)
    label.add_theme_color_override("font_color", GOLD_BRIGHT)
    label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
    label.add_theme_constant_override("shadow_offset_x", 2)
    label.add_theme_constant_override("shadow_offset_y", 2)
    return label

func _body(text: String) -> Label:
    var label := Label.new()
    label.text = text
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.custom_minimum_size = Vector2(620, 0)
    label.add_theme_font_size_override("font_size", 17)
    label.add_theme_color_override("font_color", GOLD)
    return label

func _button(text: String, callback: Callable) -> Button:
    var button := Button.new()
    button.text = text
    button.custom_minimum_size = Vector2(340, 43)
    button.add_theme_font_size_override("font_size", 17)
    button.add_theme_color_override("font_color", GOLD)
    button.add_theme_color_override("font_hover_color", GOLD_BRIGHT)
    button.add_theme_stylebox_override("normal", _panel_style(BROWN))
    button.add_theme_stylebox_override("hover", _panel_style(Color(0.17, 0.115, 0.060, 0.98)))
    button.add_theme_stylebox_override("pressed", _panel_style(Color(0.22, 0.145, 0.070, 0.98)))
    button.add_theme_stylebox_override("focus", _panel_style(Color(0.17, 0.115, 0.060, 0.98)))
    button.pressed.connect(callback)
    return button

func _rule() -> ColorRect:
    var rule := ColorRect.new()
    rule.color = BORDER
    rule.custom_minimum_size = Vector2(420, 2)
    return rule

func _show_title() -> void:
    _clear()
    content.add_child(_heading("FONS", 60))
    content.add_child(_heading("NEW WAYS", 27))
    content.add_child(_rule())
    content.add_child(_body("A science-fantasy role-playing game"))
    var spacer := Control.new()
    spacer.custom_minimum_size.y = 20
    content.add_child(spacer)
    content.add_child(_button("NEW GAME", _show_character_creation))
    var continue_button := _button("CONTINUE", _continue_game)
    continue_button.disabled = not FileAccess.file_exists("user://fons_save.json")
    content.add_child(continue_button)
    content.add_child(_button("ABOUT THIS BUILD", _show_about))
    var version := _body("Prototype 0.5 — The Initiate's Measure")
    version.add_theme_font_size_override("font_size", 13)
    content.add_child(version)

func _show_about() -> void:
    _clear()
    content.add_child(_heading("THE NEW WAYS", 36))
    content.add_child(_rule())
    content.add_child(_body("The Flamen order, diminished for generations, is recruiting again. Rumors of miracles, heresy, war, and an Anointed woman named Lucretia have reached worlds far beyond Origo.\n\nYou have answered the summons to Iustitia.\n\nThis is an evolving prototype. The world will grow around the same saveable RPG foundation as development continues."))
    content.add_child(_button("RETURN", _show_title))

func _show_character_creation() -> void:
    _clear()
    content.add_child(_heading("REGISTRY OF INITIATES", 32))
    content.add_child(_rule())
    content.add_child(_body("The clerk does not look up when you approach. A datapad rests beside a roll of old paper covered in earlier names."))

    var name_label := _body("Name")
    name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    content.add_child(name_label)
    name_edit = LineEdit.new()
    name_edit.placeholder_text = "Enter your name"
    name_edit.text = "Initiate"
    name_edit.custom_minimum_size = Vector2(540, 40)
    _style_input(name_edit)
    content.add_child(name_edit)

    var species_label := _body("Species")
    species_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    content.add_child(species_label)
    species_option = OptionButton.new()
    for species in SPECIES:
        species_option.add_item(species)
    species_option.custom_minimum_size = Vector2(540, 40)
    _style_input(species_option)
    species_option.item_selected.connect(_update_species_text)
    content.add_child(species_option)

    species_description = _body(SPECIES_TEXT[SPECIES[0]])
    species_description.add_theme_font_size_override("font_size", 14)
    content.add_child(species_description)

    var background_label := _body("Background")
    background_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    content.add_child(background_label)
    background_option = OptionButton.new()
    for background in BACKGROUNDS:
        background_option.add_item(background)
    background_option.custom_minimum_size = Vector2(540, 40)
    _style_input(background_option)
    background_option.item_selected.connect(_update_background_text)
    content.add_child(background_option)

    background_description = _body(BACKGROUND_TEXT[BACKGROUNDS[0]])
    background_description.add_theme_font_size_override("font_size", 14)
    content.add_child(background_description)

    content.add_child(_button("CONTINUE", _record_basic_profile))
    content.add_child(_button("BACK", _show_title))

func _update_species_text(index: int) -> void:
    species_description.text = SPECIES_TEXT[SPECIES[index]]

func _update_background_text(index: int) -> void:
    background_description.text = BACKGROUND_TEXT[BACKGROUNDS[index]]

func _record_basic_profile() -> void:
    var chosen_name := name_edit.text.strip_edges()
    if chosen_name.is_empty():
        chosen_name = "Initiate"
    draft_profile = {
        "name": chosen_name,
        "species": SPECIES[species_option.selected],
        "background": BACKGROUNDS[background_option.selected],
        "answers": [],
        "aptitude": "",
        "favored_attribute": "",
        "major_skills": [],
    }
    aptitude_scores = {}
    for aptitude in APTITUDES.keys():
        aptitude_scores[aptitude] = 0
    aptitude_question_index = 0
    _show_worldview_question()

func _show_worldview_question() -> void:
    _clear()
    content.add_child(_heading("A QUESTION", 32))
    content.add_child(_rule())
    content.add_child(_body("The next official is older. There is no datapad before them. They study you for a long moment, then ask:"))
    var question := _body("“If justice and peace cannot both be preserved, which have you been taught to keep?”")
    question.add_theme_font_size_override("font_size", 23)
    question.add_theme_color_override("font_color", GOLD_BRIGHT)
    content.add_child(question)
    content.add_child(_button("Justice.", func(): _answer_worldview("Justice")))
    content.add_child(_button("Peace.", func(): _answer_worldview("Peace")))
    content.add_child(_button("I do not accept the choice.", func(): _answer_worldview("Refusal")))
    content.add_child(_button("I don't know.", func(): _answer_worldview("Uncertain")))

func _answer_worldview(answer: String) -> void:
    draft_profile["answers"].append(answer)
    _show_aptitude_question()

func _show_aptitude_question() -> void:
    if aptitude_question_index >= APTITUDE_QUESTIONS.size():
        _calculate_aptitude()
        return

    _clear()
    content.add_child(_heading("THE INITIATE'S MEASURE", 30))
    content.add_child(_rule())
    var counter := _body("Question %d of %d" % [aptitude_question_index + 1, APTITUDE_QUESTIONS.size()])
    counter.add_theme_font_size_override("font_size", 13)
    content.add_child(counter)

    var q: Dictionary = APTITUDE_QUESTIONS[aptitude_question_index]
    var prompt := _body(str(q["prompt"]))
    prompt.add_theme_font_size_override("font_size", 19)
    prompt.add_theme_color_override("font_color", GOLD_BRIGHT)
    content.add_child(prompt)

    var options: Array = q["options"]
    for option in options:
        var answer_text := str(option[0])
        var aptitude := str(option[1])
        content.add_child(_button(answer_text, _answer_aptitude.bind(answer_text, aptitude)))

func _answer_aptitude(answer_text: String, aptitude: String) -> void:
    draft_profile["answers"].append(answer_text)
    aptitude_scores[aptitude] = int(aptitude_scores.get(aptitude, 0)) + 1
    aptitude_question_index += 1
    _show_aptitude_question()

func _calculate_aptitude() -> void:
    var best := "Militant"
    var best_score := -1
    for aptitude in ["Militant", "Warden", "Contemplative", "Scholar", "Envoy", "Wayfarer"]:
        var score := int(aptitude_scores.get(aptitude, 0))
        if score > best_score:
            best = aptitude
            best_score = score

    draft_profile["aptitude"] = best
    draft_profile["favored_attribute"] = str(APTITUDES[best]["attribute"])
    draft_profile["major_skills"] = APTITUDES[best]["skills"].duplicate()
    _show_aptitude_result()

func _show_aptitude_result() -> void:
    _clear()
    var aptitude := str(draft_profile["aptitude"])
    var data: Dictionary = APTITUDES[aptitude]
    content.add_child(_heading("APTITUDE: %s" % aptitude.to_upper(), 29))
    content.add_child(_rule())
    content.add_child(_body(str(data["description"])))
    content.add_child(_body("Favored attribute: %s (+10)\nFavored skills: %s (+5), %s (+5), %s (+5)" % [
        draft_profile["favored_attribute"],
        draft_profile["major_skills"][0],
        draft_profile["major_skills"][1],
        draft_profile["major_skills"][2],
    ]))
    content.add_child(_body("The examiner makes the notation in the margin rather than the main record. “A tendency is not a sentence,” they say."))
    content.add_child(_button("ACCEPT RECOMMENDATION", _show_review))
    content.add_child(_button("REVISE THE RECORD", _show_manual_specialization))

func _show_manual_specialization() -> void:
    _clear()
    content.add_child(_heading("REVISE THE RECORD", 30))
    content.add_child(_rule())
    content.add_child(_body("Choose one favored attribute and three different favored skills. This changes only where you begin, not what you may eventually learn."))

    favored_attribute_option = OptionButton.new()
    for attribute in ATTRIBUTES:
        favored_attribute_option.add_item(attribute)
    favored_attribute_option.custom_minimum_size = Vector2(540, 40)
    _style_input(favored_attribute_option)
    content.add_child(favored_attribute_option)

    major_skill_options.clear()
    for i in range(3):
        var option := OptionButton.new()
        for skill in SKILLS:
            option.add_item(skill)
        option.selected = min(i, SKILLS.size() - 1)
        option.custom_minimum_size = Vector2(540, 40)
        _style_input(option)
        major_skill_options.append(option)
        content.add_child(option)

    custom_error = _body("")
    custom_error.add_theme_font_size_override("font_size", 14)
    custom_error.add_theme_color_override("font_color", Color(0.92, 0.52, 0.38))
    content.add_child(custom_error)
    content.add_child(_button("ENTER REVISIONS", _accept_manual_specialization))
    content.add_child(_button("KEEP RECOMMENDATION", _show_aptitude_result))

func _accept_manual_specialization() -> void:
    var chosen_skills: Array[String] = []
    for option in major_skill_options:
        chosen_skills.append(SKILLS[option.selected])
    var unique := {}
    for skill in chosen_skills:
        unique[skill] = true
    if unique.size() != 3:
        custom_error.text = "The registry requires three different favored skills."
        return

    draft_profile["aptitude"] = "Unclassified"
    draft_profile["favored_attribute"] = ATTRIBUTES[favored_attribute_option.selected]
    draft_profile["major_skills"] = chosen_skills
    _show_review()

func _show_review() -> void:
    _clear()
    content.add_child(_heading("THE RECORD", 32))
    content.add_child(_rule())
    var aptitude := str(draft_profile.get("aptitude", "Unclassified"))
    var favored := str(draft_profile.get("favored_attribute", ""))
    var majors: Array = draft_profile.get("major_skills", [])
    var skill_line := ""
    if majors.size() >= 3:
        skill_line = "%s, %s, %s" % [majors[0], majors[1], majors[2]]
    content.add_child(_body("Name: %s\nSpecies: %s\nBackground: %s\nAptitude: %s\nFavored attribute: %s\nFavored skills: %s\n\nThe final page is left unsigned until you accept the summons." % [
        draft_profile["name"],
        draft_profile["species"],
        draft_profile["background"],
        aptitude,
        favored,
        skill_line,
    ]))
    content.add_child(_button("ACCEPT THE SUMMONS", _begin_new_game))
    content.add_child(_button("START OVER", _show_character_creation))

func _begin_new_game() -> void:
    GameState.new_game(draft_profile)
    _show_arrival()

func _show_arrival() -> void:
    _clear()
    content.add_child(_heading("IUSTITIA", 40))
    content.add_child(_rule())
    content.add_child(_body("For most of the descent there is nothing beneath the shuttle but cloud.\n\nThen the monastery appears. Black peaks rise through the storm like broken teeth. Ancient walls cling to stone that should not hold them. A landing beacon flashes beside a courtyard older than the language on your travel papers.\n\nOn final approach, the conversations around you stop one by one. Nothing outside has changed except the cloud. You cannot tell whether the silence is habit, prayer, or nerves.\n\nThe landing gear strikes stone."))
    content.add_child(_button("DISEMBARK", _enter_iustitia))

func _enter_iustitia() -> void:
    get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _continue_game() -> void:
    GameState.world_flags["load_on_start"] = true
    get_tree().change_scene_to_file("res://scenes/Main.tscn")
