extends "res://scripts/monastery_population.gd"

const RESIDENT_M2 = preload("res://scripts/monastery_resident_m2.gd")

func _spawn_residents() -> void:
    var archivist = RESIDENT_M2.new()
    archivist.name = "ArchivistSel"
    archivist.display_name = "Archivist Sel"
    archivist.resident_id = "archivist"
    archivist.species = "Felid"
    archivist.body_color = Color(0.27, 0.20, 0.15)
    archivist.position = INTERIOR_ORIGIN + Vector3(22.6, 0.10, -24.6)
    archivist.rotation_degrees.y = 90.0
    add_child(archivist)

    var keeper = RESIDENT_M2.new()
    keeper.name = "KeeperOru"
    keeper.display_name = "Keeper Oru"
    keeper.resident_id = "keeper"
    keeper.species = "Gruhanian"
    keeper.body_color = Color(0.24, 0.22, 0.13)
    keeper.position = INTERIOR_ORIGIN + Vector3(4.7, 0.10, -39.0)
    keeper.rotation_degrees.y = 90.0
    add_child(keeper)

    var novice = RESIDENT_M2.new()
    novice.name = "NovicePell"
    novice.display_name = "Novice Pell"
    novice.resident_id = "sargasson_novice"
    novice.species = "Sargasson"
    novice.body_color = Color(0.25, 0.27, 0.30)
    novice.position = INTERIOR_ORIGIN + Vector3(15.5, 0.10, -39.0)
    novice.rotation_degrees.y = -90.0
    add_child(novice)
