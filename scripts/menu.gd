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

var content: VBoxContainer
var name_edit: LineEdit
var species_option: OptionButton
var species_description: Label
var background_option: OptionButton
var background_description: Label
var draft_profile := {}

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    _build_frame()
    _show_title()

func _build_frame() -> void:
    var bg := ColorRect.new()
    bg.color = Color(0.035, 0.03, 0.045, 1.0)
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(bg)

    var shade := ColorRect.new()
    shade.color = Color(0.12, 0.08, 0.12, 0.42)
    shade.anchor_left = 0.18
    shade.anchor_right = 0.82
    shade.anchor_top = 0.0
    shade.anchor_bottom = 1.0
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
    content.add_theme_constant_override("separation", 14)
    add_child(content)

func _clear() -> void:
    for child in content.get_children():
        child.free()

func _heading(text: String, size: int = 36) -> Label:
    var label := Label.new()
    label.text = text
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.add_theme_font_size_override("font_size", size)
    label.add_theme_color_override("font_color", Color(0.88, 0.80, 0.65))
    return label

func _body(text: String) -> Label:
    var label := Label.new()
    label.text = text
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.custom_minimum_size = Vector2(620, 0)
    label.add_theme_font_size_override("font_size", 17)
    label.add_theme_color_override("font_color", Color(0.80, 0.78, 0.76))
    return label

func _button(text: String, callback: Callable) -> Button:
    var button := Button.new()
    button.text = text
    button.custom_minimum_size = Vector2(340, 48)
    button.add_theme_font_size_override("font_size", 18)
    button.pressed.connect(callback)
    return button

func _show_title() -> void:
    _clear()
    content.add_child(_heading("FONS", 58))
    content.add_child(_heading("NEW WAYS", 28))
    content.add_child(_body("A science-fantasy role-playing game"))
    var spacer := Control.new(); spacer.custom_minimum_size.y = 28; content.add_child(spacer)
    content.add_child(_button("NEW GAME", _show_character_creation))
    var continue_button := _button("CONTINUE", _continue_game)
    continue_button.disabled = not FileAccess.file_exists("user://fons_save.json")
    content.add_child(continue_button)
    content.add_child(_button("ABOUT THIS BUILD", _show_about))
    var version := _body("Prototype 0.2 — Iustitia initiation build")
    version.add_theme_font_size_override("font_size", 13)
    content.add_child(version)

func _show_about() -> void:
    _clear()
    content.add_child(_heading("THE NEW WAYS", 36))
    content.add_child(_body("The Flamen order, diminished for generations, is recruiting again. Rumors of miracles, heresy, war, and an Anointed woman named Lucretia have reached worlds far beyond Origo.\n\nYou have answered the summons to Iustitia.\n\nThis is an evolving prototype. The world will grow around the same saveable RPG foundation as development continues."))
    content.add_child(_button("RETURN", _show_title))

func _show_character_creation() -> void:
    _clear()
    content.add_child(_heading("REGISTRY OF INITIATES", 32))
    content.add_child(_body("The clerk does not look up when you approach. A datapad rests beside a roll of old paper covered in earlier names."))

    var name_label := _body("Name")
    name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    content.add_child(name_label)
    name_edit = LineEdit.new()
    name_edit.placeholder_text = "Enter your name"
    name_edit.text = "Initiate"
    name_edit.custom_minimum_size = Vector2(540, 42)
    content.add_child(name_edit)

    var species_label := _body("Species")
    species_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    content.add_child(species_label)
    species_option = OptionButton.new()
    for species in SPECIES:
        species_option.add_item(species)
    species_option.custom_minimum_size = Vector2(540, 42)
    species_option.item_selected.connect(_update_species_text)
    content.add_child(species_option)

    species_description = _body(SPECIES_TEXT[SPECIES[0]])
    species_description.add_theme_font_size_override("font_size", 14)
    content.add_child(species_description)

    var species_note := _body("Species describes your body, not your culture, religion, politics, or personality.")
    species_note.add_theme_font_size_override("font_size", 13)
    content.add_child(species_note)

    var background_label := _body("Background")
    background_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    content.add_child(background_label)
    background_option = OptionButton.new()
    for background in BACKGROUNDS:
        background_option.add_item(background)
    background_option.custom_minimum_size = Vector2(540, 42)
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
    }
    _show_question()

func _show_question() -> void:
    _clear()
    content.add_child(_heading("A QUESTION", 32))
    content.add_child(_body("The next official is older. There is no datapad before them. They study you for a long moment, then ask:"))
    var question := _body("“If justice and peace cannot both be preserved, which have you been taught to keep?”")
    question.add_theme_font_size_override("font_size", 23)
    question.add_theme_color_override("font_color", Color(0.92, 0.86, 0.74))
    content.add_child(question)
    content.add_child(_button("Justice.", func(): _answer_question("Justice")))
    content.add_child(_button("Peace.", func(): _answer_question("Peace")))
    content.add_child(_button("I do not accept the choice.", func(): _answer_question("Refusal")))
    content.add_child(_button("I don't know.", func(): _answer_question("Uncertain")))

func _answer_question(answer: String) -> void:
    draft_profile["answers"] = [answer]
    _show_review()

func _show_review() -> void:
    _clear()
    content.add_child(_heading("THE RECORD", 32))
    content.add_child(_body("Name: %s\nSpecies: %s\nBackground: %s\n\nYour final answer is entered without comment." % [draft_profile["name"], draft_profile["species"], draft_profile["background"]]))
    content.add_child(_button("ACCEPT THE SUMMONS", _begin_new_game))
    content.add_child(_button("START OVER", _show_character_creation))

func _begin_new_game() -> void:
    GameState.new_game(draft_profile)
    _show_arrival()

func _show_arrival() -> void:
    _clear()
    content.add_child(_heading("IUSTITIA", 40))
    content.add_child(_body("For most of the descent there is nothing beneath the shuttle but cloud.\n\nThen the monastery appears. Black peaks rise through the storm like broken teeth. Ancient walls cling to stone that should not hold them. A landing beacon flashes beside a courtyard older than the language on your travel papers.\n\nNo one aboard applauds.\n\nAcross the aisle, another initiate quietly removes their shoes before the shuttle has even touched down. Nobody explains why."))
    content.add_child(_button("DISEMBARK", _enter_iustitia))

func _enter_iustitia() -> void:
    get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _continue_game() -> void:
    GameState.world_flags["load_on_start"] = true
    get_tree().change_scene_to_file("res://scenes/Main.tscn")
