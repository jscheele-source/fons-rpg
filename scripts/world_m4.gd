extends "res://scripts/world_m3.gd"

# Milestone 4 adds botanical density in visual layers while preserving the exact
# M3 walls, floor, threshold, and tested walking route.
func _build_world() -> void:
    super._build_world()
    _build_layered_garden_detail()

func _build_layered_garden_detail() -> void:
    var layers := Node3D.new()
    layers.name = "M4GardenLayers"
    add_child(layers)

    _build_m4_flora_fontis_layer(Vector3(-19.1, 0.0, 11.2))
    _build_m4_tamdin_pocket(Vector3(-27.0, 0.0, -1.8))
    _build_m4_psittacus_bed(Vector3(-28.3, 0.0, 10.9))
    _build_m4_pampin_gallery(Vector3(-22.8, 0.0, -3.2), 6.2)

func _build_m4_flora_fontis_layer(pos: Vector3) -> void:
    var root := Node3D.new()
    root.name = "M4FloraFontisLayer"
    root.position = pos
    add_child(root)

    # Dark substrate makes the low native light read without making the whole
    # garden glow. It is visual-only, so it cannot catch the player's feet.
    _box("M4FloraBed", pos + Vector3(0, 0.035, 0), Vector3(4.8, 0.07, 3.0), Color(0.095, 0.085, 0.075), false)
    for i in range(14):
        var angle: float = float(i) * 2.399
        var radius: float = 0.35 + float(i % 5) * 0.34
        var local := Vector3(cos(angle) * radius, 0.0, sin(angle) * radius * 0.62)
        _m4_luminous_bloom(root, local, i)

func _m4_luminous_bloom(root: Node3D, pos: Vector3, index: int) -> void:
    var stalk := MeshInstance3D.new()
    stalk.name = "M4FloraStalk_%02d" % index
    var stalk_mesh := CylinderMesh.new()
    stalk_mesh.top_radius = 0.025
    stalk_mesh.bottom_radius = 0.045
    stalk_mesh.height = 0.28 + float(index % 4) * 0.05
    stalk_mesh.radial_segments = 5
    var stalk_mat := StandardMaterial3D.new()
    stalk_mat.albedo_color = Color(0.14, 0.22, 0.13)
    stalk_mat.roughness = 1.0
    stalk_mesh.material = stalk_mat
    stalk.mesh = stalk_mesh
    stalk.position = pos + Vector3(0, stalk_mesh.height * 0.5, 0)
    root.add_child(stalk)

    var bloom := MeshInstance3D.new()
    bloom.name = "M4FloraBloom_%02d" % index
    var bloom_mesh := SphereMesh.new()
    bloom_mesh.radius = 0.095 + float(index % 3) * 0.018
    bloom_mesh.height = bloom_mesh.radius * 1.55
    bloom_mesh.radial_segments = 6
    bloom_mesh.rings = 3
    var bloom_mat := StandardMaterial3D.new()
    bloom_mat.albedo_color = Color(0.54, 0.25 + float(index % 2) * 0.06, 0.43)
    bloom_mat.emission_enabled = true
    bloom_mat.emission = Color(0.31, 0.10, 0.25)
    bloom_mat.emission_energy_multiplier = 0.72
    bloom_mesh.material = bloom_mat
    bloom.mesh = bloom_mesh
    bloom.position = pos + Vector3(0, stalk_mesh.height + 0.04, 0)
    root.add_child(bloom)

func _build_m4_tamdin_pocket(pos: Vector3) -> void:
    var root := Node3D.new()
    root.name = "M4TamdinPocket"
    root.position = pos
    add_child(root)

    # Canon-inspired Tamdin planting: pink soil, fleshy coral-like structures,
    # pale internal 'bones,' and vaguely humanoid silhouettes. Deliberately
    # motionless and untrimmed.
    _box("M4TamdinSoil", pos + Vector3(0, 0.04, 0), Vector3(4.4, 0.08, 3.5), Color(0.39, 0.18, 0.23), false)
    var offsets: Array[Vector3] = [
        Vector3(-1.35, 0, -0.75), Vector3(-0.55, 0, 0.45), Vector3(0.35, 0, -0.35),
        Vector3(1.25, 0, 0.55), Vector3(0.9, 0, -1.05), Vector3(-1.05, 0, 1.05)
    ]
    for i in range(offsets.size()):
        _m4_tamdin_cluster(root, offsets[i], i)

func _m4_tamdin_cluster(root: Node3D, pos: Vector3, index: int) -> void:
    var cluster := Node3D.new()
    cluster.name = "M4TamdinCluster_%02d" % index
    cluster.position = pos
    root.add_child(cluster)

    var height: float = 1.05 + float(index % 4) * 0.28
    _m4_fleshy_limb(cluster, Vector3(0, height * 0.5, 0), height, 0.13, Color(0.47, 0.22, 0.28), Vector3(0, 0, -4.0 + float(index % 3) * 4.0))
    _m4_fleshy_limb(cluster, Vector3(-0.22, height * 0.70, 0), height * 0.58, 0.095, Color(0.52, 0.25, 0.31), Vector3(0, 0, 38))
    _m4_fleshy_limb(cluster, Vector3(0.23, height * 0.72, 0.03), height * 0.52, 0.09, Color(0.50, 0.23, 0.29), Vector3(0, 0, -42))

    # Pale cores visible through gaps suggest the rigid internal structures
    # described for Tamdin flora without trying to anatomically define them.
    _m4_fleshy_limb(cluster, Vector3(0, height * 0.52, -0.035), height * 0.78, 0.038, Color(0.72, 0.59, 0.53), Vector3(0, 0, -3))

    var crown := MeshInstance3D.new()
    crown.name = "M4TamdinCrown_%02d" % index
    var crown_mesh := SphereMesh.new()
    crown_mesh.radius = 0.24
    crown_mesh.height = 0.52
    crown_mesh.radial_segments = 7
    crown_mesh.rings = 4
    var crown_mat := StandardMaterial3D.new()
    crown_mat.albedo_color = Color(0.56, 0.27, 0.33)
    crown_mat.roughness = 0.88
    crown_mesh.material = crown_mat
    crown.mesh = crown_mesh
    crown.position = Vector3(0, height + 0.12, 0)
    crown.scale = Vector3(0.72, 1.25, 0.65)
    cluster.add_child(crown)

func _m4_fleshy_limb(root: Node3D, pos: Vector3, height: float, radius: float, color: Color, rotation: Vector3) -> void:
    var limb := MeshInstance3D.new()
    limb.name = "M4TamdinBranch"
    var mesh := CylinderMesh.new()
    mesh.top_radius = radius * 0.72
    mesh.bottom_radius = radius
    mesh.height = height
    mesh.radial_segments = 7
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.91
    mesh.material = mat
    limb.mesh = mesh
    limb.position = pos
    limb.rotation_degrees = rotation
    root.add_child(limb)

func _build_m4_psittacus_bed(pos: Vector3) -> void:
    var root := Node3D.new()
    root.name = "M4PsittacusBed"
    root.position = pos
    add_child(root)
    _box("M4PsittacusSoil", pos + Vector3(0, 0.035, 0), Vector3(3.0, 0.07, 2.0), Color(0.12, 0.105, 0.085), false)

    for i in range(7):
        var x: float = -1.05 + float(i % 4) * 0.70
        var z: float = -0.45 + float(i / 4) * 0.82 + float(i % 2) * 0.12
        var bulb := MeshInstance3D.new()
        bulb.name = "M4PsittacusBulb_%02d" % i
        var mesh := SphereMesh.new()
        mesh.radius = 0.22 + float(i % 2) * 0.04
        mesh.height = 0.58
        mesh.radial_segments = 7
        mesh.rings = 4
        var mat := StandardMaterial3D.new()
        mat.albedo_color = Color(0.34, 0.25 + float(i % 3) * 0.035, 0.18)
        mat.roughness = 0.82
        mesh.material = mat
        bulb.mesh = mesh
        bulb.position = Vector3(x, 0.30, z)
        bulb.scale = Vector3(0.82, 1.20, 0.82)
        root.add_child(bulb)

func _build_m4_pampin_gallery(pos: Vector3, length: float) -> void:
    var root := Node3D.new()
    root.name = "M4PampinGallery"
    root.position = pos
    add_child(root)

    # Overhead layer: pods and leaves hang above head height and remain visual
    # only. The M3 route test therefore continues to police the traversable floor.
    for i in range(11):
        var x: float = float(i) * length / 10.0
        var leaf := MeshInstance3D.new()
        leaf.name = "M4PampinLeaf_%02d" % i
        var leaf_mesh := SphereMesh.new()
        leaf_mesh.radius = 0.18
        leaf_mesh.height = 0.38
        leaf_mesh.radial_segments = 6
        leaf_mesh.rings = 3
        var leaf_mat := StandardMaterial3D.new()
        leaf_mat.albedo_color = Color(0.15, 0.31 + float(i % 3) * 0.025, 0.13)
        leaf_mat.roughness = 0.95
        leaf_mesh.material = leaf_mat
        leaf.mesh = leaf_mesh
        leaf.position = Vector3(x, 2.45 + float(i % 2) * 0.18, sin(float(i) * 1.3) * 0.18)
        leaf.rotation_degrees.z = -32.0 + float(i % 4) * 18.0
        leaf.scale = Vector3(0.55, 1.35, 0.45)
        root.add_child(leaf)

        if i % 3 == 1:
            var pod := MeshInstance3D.new()
            pod.name = "M4PampinPod_%02d" % i
            var pod_mesh := SphereMesh.new()
            pod_mesh.radius = 0.13
            pod_mesh.height = 0.42
            pod_mesh.radial_segments = 6
            pod_mesh.rings = 3
            var pod_mat := StandardMaterial3D.new()
            pod_mat.albedo_color = Color(0.42, 0.24, 0.16)
            pod_mat.roughness = 0.88
            pod_mesh.material = pod_mat
            pod.mesh = pod_mesh
            pod.position = Vector3(x + 0.12, 2.02, 0.08)
            root.add_child(pod)
