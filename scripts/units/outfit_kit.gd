class_name OutfitKit
extends RefCounted
## Code-generated outfit/prop kits attached to a BlendShellRig. Kits are data
## (role + material tier), and every prop is a primitive mesh — still zero art.
## Gives peasants/soldiers/commander distinct looks per age.

const TIER_COLORS: Dictionary = {
	"wood": Color(0.55, 0.40, 0.25),
	"stone": Color(0.55, 0.55, 0.58),
	"iron": Color(0.65, 0.66, 0.68),
	"steel": Color(0.78, 0.80, 0.84),
	"diamond": Color(0.55, 0.85, 0.95),
	"gold": Color(0.95, 0.80, 0.35),
}

## Attach a role outfit to a rig. role: "peasant" | "commander" | "soldier"
## tier: key of TIER_COLORS (age/material).
static func apply(rig: BlendShellRig, role: String, tier: String = "wood") -> void:
	_clear_props(rig)
	match role:
		"peasant":
			_add_hat(rig, TIER_COLORS.get(tier, Color.WHITE))
			_add_backpack(rig)
		"commander":
			_add_helm(rig, TIER_COLORS.get(tier, Color.GOLD), true)
			_add_pauldrons(rig, TIER_COLORS.get(tier, Color.GOLD))
		"soldier":
			_add_helm(rig, TIER_COLORS.get(tier, Color.GRAY), false)
			_add_shield(rig, TIER_COLORS.get(tier, Color.GRAY))
	rig.set_meta("outfit_props", rig.get_meta("outfit_props", []))

static func _clear_props(rig: BlendShellRig) -> void:
	var props: Array = rig.get_meta("outfit_props", [])
	for p in props:
		if is_instance_valid(p):
			p.queue_free()
	rig.set_meta("outfit_props", [])

static func _track(rig: BlendShellRig, node: Node3D) -> void:
	var props: Array = rig.get_meta("outfit_props", [])
	props.append(node)
	rig.set_meta("outfit_props", props)

static func _mat(color: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.6
	m.metallic = 0.4
	return m

static func _add_hat(rig: BlendShellRig, color: Color) -> void:
	var hat := MeshInstance3D.new()
	hat.name = "Hat"
	var m := CylinderMesh.new()
	m.top_radius = 0.05
	m.bottom_radius = 0.17
	m.height = 0.12
	hat.mesh = m
	hat.material_override = _mat(color)
	var head := rig.anchor_head()
	hat.position = Vector3(0, 0.18, 0)
	head.add_child(hat)
	_track(rig, hat)

static func _add_helm(rig: BlendShellRig, color: Color, plume: bool) -> void:
	var helm := MeshInstance3D.new()
	helm.name = "Helm"
	var m := SphereMesh.new()
	m.radius = 0.18
	m.height = 0.22
	helm.mesh = m
	helm.material_override = _mat(color)
	var head := rig.anchor_head()
	helm.position = Vector3(0, 0.06, 0)
	head.add_child(helm)
	_track(rig, helm)
	if plume:
		var pl := MeshInstance3D.new()
		pl.name = "Plume"
		var pm := BoxMesh.new()
		pm.size = Vector3(0.04, 0.22, 0.12)
		pl.mesh = pm
		pl.material_override = _mat(Color(0.85, 0.30, 0.30))
		pl.position = Vector3(0, 0.24, 0)
		helm.add_child(pl)

static func _add_backpack(rig: BlendShellRig) -> void:
	var pack := MeshInstance3D.new()
	pack.name = "Backpack"
	var m := BoxMesh.new()
	m.size = Vector3(0.24, 0.3, 0.14)
	pack.mesh = m
	pack.material_override = _mat(Color(0.45, 0.32, 0.20))
	var back := rig.anchor_back()
	pack.position = Vector3(0, 0.05, -0.24)
	back.add_child(pack)
	_track(rig, pack)

static func _add_pauldrons(rig: BlendShellRig, color: Color) -> void:
	for side in [-1, 1]:
		var pad := MeshInstance3D.new()
		pad.name = "Pauldron"
		var m := SphereMesh.new()
		m.radius = 0.11
		m.height = 0.12
		pad.mesh = m
		pad.material_override = _mat(color)
		var pivot := rig.pivot_arm_l if side < 0 else rig.pivot_arm_r
		pad.position = Vector3(0, 0.04, 0)
		pivot.add_child(pad)
		_track(rig, pad)

static func _add_shield(rig: BlendShellRig, color: Color) -> void:
	var shield := MeshInstance3D.new()
	shield.name = "Shield"
	var m := BoxMesh.new()
	m.size = Vector3(0.05, 0.4, 0.28)
	shield.mesh = m
	shield.material_override = _mat(color)
	var arm := rig.pivot_arm_l
	shield.position = Vector3(-0.12, -0.2, 0.08)
	arm.add_child(shield)
	_track(rig, shield)

## Attach a hand tool prop (axe, pick, spear, hammer) to the right hand.
static func give_tool(rig: BlendShellRig, tool: String, tier: String = "wood") -> void:
	var existing := rig.anchor_hand_right().get_node_or_null("Tool")
	if existing:
		existing.queue_free()
	var color: Color = TIER_COLORS.get(tier, Color.WHITE)
	var tool_node := MeshInstance3D.new()
	tool_node.name = "Tool"
	match tool:
		"axe":
			var handle := BoxMesh.new()
			handle.size = Vector3(0.04, 0.5, 0.04)
			tool_node.mesh = handle
			tool_node.material_override = _mat(Color(0.5, 0.35, 0.2))
			var head_m := MeshInstance3D.new()
			var hm := BoxMesh.new()
			hm.size = Vector3(0.16, 0.12, 0.03)
			head_m.mesh = hm
			head_m.material_override = _mat(color)
			head_m.position = Vector3(0.09, 0.2, 0)
			tool_node.add_child(head_m)
		"pick":
			var handle2 := BoxMesh.new()
			handle2.size = Vector3(0.04, 0.5, 0.04)
			tool_node.mesh = handle2
			tool_node.material_override = _mat(Color(0.5, 0.35, 0.2))
			var head_m2 := MeshInstance3D.new()
			var hm2 := BoxMesh.new()
			hm2.size = Vector3(0.26, 0.05, 0.05)
			head_m2.mesh = hm2
			head_m2.material_override = _mat(color)
			head_m2.position = Vector3(0, 0.22, 0)
			tool_node.add_child(head_m2)
		"spear":
			var shaft := CylinderMesh.new()
			shaft.top_radius = 0.02
			shaft.bottom_radius = 0.02
			shaft.height = 0.9
			tool_node.mesh = shaft
			tool_node.material_override = _mat(Color(0.5, 0.35, 0.2))
			var tip := MeshInstance3D.new()
			var tm := PrismMesh.new()
			tm.size = Vector3(0.06, 0.16, 0.06)
			tip.mesh = tm
			tip.material_override = _mat(color)
			tip.position = Vector3(0, 0.5, 0)
			tool_node.add_child(tip)
		_:
			return
	tool_node.position = Vector3(0, -0.4, 0)
	tool_node.rotation.x = deg_to_rad(90)
	rig.anchor_hand_right().add_child(tool_node)
	_track(rig, tool_node)
