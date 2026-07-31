class_name BlendShellRig
extends Node3D
## Procedural character rig built entirely from primitive meshes. No Skeleton3D,
## no AnimationPlayer, no external assets. Body parts are exposed as nodes so
## silly_physics.gd can pose them per frame.
##
## Parameters produce distinct silhouettes (peasant vs commander vs soldier)
## with zero art. Team tint colors the torso/head; outfit kits add props later.

const TEAM_COLORS: Array[Color] = [
	Color(0.30, 0.50, 0.85),  # blue
	Color(0.85, 0.35, 0.30),  # red
	Color(0.35, 0.75, 0.40),  # green
	Color(0.90, 0.75, 0.30),  # yellow
]

@export var height: float = 1.0        # overall scale multiplier
@export var build: float = 1.0         # torso width multiplier
@export var head_scale: float = 1.0
@export var team_index: int = 0
@export var skin_color: Color = Color(0.88, 0.72, 0.58)

var torso: MeshInstance3D
var head: MeshInstance3D
var arm_l: MeshInstance3D
var arm_r: MeshInstance3D
var leg_l: MeshInstance3D
var leg_r: MeshInstance3D

# Pivots for limb swing (shoulders/hips at top of limbs).
var pivot_arm_l: Node3D
var pivot_arm_r: Node3D
var pivot_leg_l: Node3D
var pivot_leg_r: Node3D

func _ready() -> void:
	_build()

func _build() -> void:
	var team_color: Color = TEAM_COLORS[clampi(team_index, 0, TEAM_COLORS.size() - 1)]
	var torso_h: float = 0.55 * height
	var torso_w: float = 0.34 * build
	var limb_r: float = 0.07 * build
	var arm_len: float = 0.42 * height
	var leg_len: float = 0.5 * height
	var head_r: float = 0.16 * head_scale

	# Torso (capsule), centered so its base is at hip height.
	torso = MeshInstance3D.new()
	torso.name = "Torso"
	var torso_mesh := CapsuleMesh.new()
	torso_mesh.radius = torso_w
	torso_mesh.height = torso_h
	torso.mesh = torso_mesh
	torso.material_override = _mat(team_color)
	torso.position.y = leg_len + torso_h * 0.5
	add_child(torso)

	# Head (sphere) on top of torso.
	head = MeshInstance3D.new()
	head.name = "Head"
	var head_mesh := SphereMesh.new()
	head_mesh.radius = head_r
	head_mesh.height = head_r * 2.0
	head.mesh = head_mesh
	head.material_override = _mat(skin_color)
	head.position.y = leg_len + torso_h + head_r * 0.9
	add_child(head)

	# Arms (capsules) hanging from shoulder pivots.
	var shoulder_y: float = leg_len + torso_h * 0.9
	var shoulder_x: float = torso_w + limb_r + 0.02
	pivot_arm_l = _make_pivot("PivotArmL", Vector3(-shoulder_x, shoulder_y, 0))
	pivot_arm_r = _make_pivot("PivotArmR", Vector3(shoulder_x, shoulder_y, 0))
	arm_l = _make_limb("ArmL", limb_r, arm_len, _mat(skin_color))
	arm_r = _make_limb("ArmR", limb_r, arm_len, _mat(skin_color))
	pivot_arm_l.add_child(arm_l)
	pivot_arm_r.add_child(arm_r)

	# Legs (capsules) hanging from hip pivots.
	var hip_y: float = leg_len
	var hip_x: float = torso_w * 0.5
	pivot_leg_l = _make_pivot("PivotLegL", Vector3(-hip_x, hip_y, 0))
	pivot_leg_r = _make_pivot("PivotLegR", Vector3(hip_x, hip_y, 0))
	leg_l = _make_limb("LegL", limb_r * 1.15, leg_len, _mat(team_color.darkened(0.25)))
	leg_r = _make_limb("LegR", limb_r * 1.15, leg_len, _mat(team_color.darkened(0.25)))
	pivot_leg_l.add_child(leg_l)
	pivot_leg_r.add_child(leg_r)

func _make_pivot(pivot_name: String, pos: Vector3) -> Node3D:
	var p := Node3D.new()
	p.name = pivot_name
	p.position = pos
	add_child(p)
	return p

func _make_limb(limb_name: String, radius: float, length: float, mat: Material) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = limb_name
	var m := CapsuleMesh.new()
	m.radius = radius
	m.height = length
	mi.mesh = m
	mi.material_override = mat
	# Limb mesh hangs downward from its pivot (pivot at top of the limb).
	mi.position.y = -length * 0.5
	return mi

func _mat(color: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.85
	return m

## Anchors for outfit kits and tool props (hands, head top, back).
func anchor_hand_right() -> Node3D:
	return pivot_arm_r

func anchor_head() -> Node3D:
	return head

func anchor_back() -> Node3D:
	return torso
