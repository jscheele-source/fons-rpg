extends Node

var menu: Control

func _ready() -> void:
    var scene := preload("res://scenes/Menu.tscn")
    menu = scene.instantiate()
    add_child(menu)
    await get_tree().process_frame

    menu._show_character_creation()
    await get_tree().process_frame
    if not _contains_text(menu, "REGISTRY OF INITIATES"):
        _fail("Character creation did not open.")
        return

    menu.name_edit.text = "Test Initiate"
    menu.species_option.select(0)
    menu.background_option.select(0)
    menu._record_basic_profile()
    await get_tree().process_frame
    if not _contains_text(menu, "If justice and peace cannot both be preserved"):
        _fail("Worldview question did not appear after basic profile.")
        return

    menu._answer_worldview("Justice")
    await get_tree().process_frame
    if not _contains_text(menu, "THE INITIATE'S MEASURE") or not _contains_text(menu, "Question 1 of 4"):
        _fail("Aptitude questionnaire did not begin after worldview answer.")
        return

    menu._answer_aptitude("Open the housing and determine what actually failed.", "Scholar")
    menu._answer_aptitude("Work out why they chose me before I answer.", "Scholar")
    menu._answer_aptitude("Write down every detail before memory edits it.", "Scholar")
    menu._answer_aptitude("I would rather know whether the teacher can prove that claim.", "Scholar")
    await get_tree().process_frame

    if not _contains_text(menu, "APTITUDE: SCHOLAR"):
        _fail("Aptitude result did not appear after four answers.")
        return

    print("Menu flow smoke test passed: aptitude questionnaire is reachable and completes.")
    get_tree().quit(0)

func _contains_text(root: Node, needle: String) -> bool:
    if root is Label and str(root.text).find(needle) != -1:
        return true
    if root is Button and str(root.text).find(needle) != -1:
        return true
    for child in root.get_children():
        if _contains_text(child, needle):
            return true
    return false

func _fail(message: String) -> void:
    push_error(message)
    get_tree().quit(1)
