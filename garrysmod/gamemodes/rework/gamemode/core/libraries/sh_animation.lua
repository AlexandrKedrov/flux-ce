--[[ 
	Rework © 2016-2017 TeslaCloud Studios
	Do not share or re-distribute before 
	the framework is publicly released.
--]]

library.New("anim", rw)
local stored = rw.anim.stored or {}
local models = rw.anim.models or {}
rw.anim.stored = stored
rw.anim.models = models

stored.player = {
	normal = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE_ANGRY_SMG1},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_COVER_LOW},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK_AIM_RIFLE_STIMULATED},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN_AIM_RIFLE_STIMULATED},
		glide = ACT_GLIDE
	},
	pistol = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_RANGE_ATTACK_PISTOL},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_RANGE_ATTACK_PISTOL_LOW},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK_AIM_RIFLE_STIMULATED},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN_AIM_RIFLE_STIMULATED},
		attack = ACT_GESTURE_RANGE_ATTACK_PISTOL,
		reload = ACT_RELOAD_PISTOL
	},
	smg = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_SMG1_RELAXED, ACT_IDLE_ANGRY_SMG1},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW_RPG, ACT_RANGE_AIM_SMG1_LOW},
		[ACT_MP_WALK] = {ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_AIM_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN_RIFLE, ACT_RUN_AIM_RIFLE_STIMULATED},
		attack = ACT_GESTURE_RANGE_ATTACK_SMG1,
		reload = ACT_GESTURE_RELOAD_SMG1
	},
	shotgun = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_SHOTGUN_RELAXED, ACT_IDLE_ANGRY_SMG1},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW_RPG, ACT_RANGE_AIM_SMG1_LOW},
		[ACT_MP_WALK] = {ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN_RIFLE_RELAXED, ACT_RUN_AIM_RIFLE_STIMULATED},
		attack = ACT_GESTURE_RANGE_ATTACK_SHOTGUN
	},
	grenade = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE_MANNEDGUN},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_COVER_PISTOL_LOW},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK_AIM_RIFLE_STIMULATED},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN_RIFLE_STIMULATED},
		attack = ACT_RANGE_ATTACK_THROW
	},
	melee = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_SUITCASE, ACT_IDLE_ANGRY_MELEE},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_COVER_LOW},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK_AIM_RIFLE},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN},
		attack = ACT_MELEE_ATTACK_SWING
	},
	rpg = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_RPG_RELAXED, ACT_IDLE_ANGRY_SMG1},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW_RPG, ACT_COVER_LOW_RPG},
		[ACT_MP_WALK] = {ACT_WALK_RPG_RELAXED, ACT_WALK_RPG},
		[ACT_MP_CROUCHWALK] = ACT_WALK_CROUCH_RPG,
		[ACT_MP_RUN] = {ACT_RUN_RPG_RELAXED, ACT_RUN_RPG},
		attack = ACT_RANGE_ATTACK_RPG
	},
	ar2 = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_SHOTGUN_RELAXED, ACT_IDLE_AIM_RIFLE_STIMULATED},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW_RPG, ACT_RANGE_AIM_AR2_LOW},
		[ACT_MP_WALK] = {ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN_RIFLE_RELAXED, ACT_RUN_AIM_RIFLE_STIMULATED},
		attack = ACT_GESTURE_RANGE_ATTACK_AR2,
		reload = ACT_GESTURE_RELOAD_SMG1
	},
	vehicle = {
		prop_vehicle_prisoner_pod = {"podpose", Vector(-3, 0, 0)},
		prop_vehicle_jeep = {"sitchair1", Vector(14, 0, -14)},
		prop_vehicle_airboat = {"sitchair1", Vector(8, 0, -20)}
	}
}

function rw.anim:GetStored()
	return stored
end

function rw.anim:SetModelClass(model, class)
	if (!stored[class]) then
		class = "player"
	end

	models[string.lower(model)] = class
end

function rw.anim:GetModelClass(model)
	if (!model) then return "player"; end

	local modelClass = models[string.lower(model)]

	if (modelClass) then
		return modelClass
	end

	return "player"
end

function rw.anim:GetTable(model)
	if (!model) then return nil; end

	if (string.find(model, "/player/")) then
		return nil;	
	end

	return stored[self:GetModelClass(model)]
end

do
	local translateHoldTypes = {
		[""] = "normal",
		["physgun"] = "smg",
		["ar2"] = "smg",
		["crossbow"] = "shotgun",
		["rpg"] = "shotgun",
		["slam"] = "normal",
		["grenade"] = "normal",
		["fist"] = "normal",
		["melee2"] = "melee",
		["passive"] = "normal",
		["knife"] = "melee",
		["duel"] = "pistol",
		["camera"] = "smg",
		["revolver"] = "pistol"
	}

	local weaponHoldTypes = {
		["weapon_ar2"] = "smg",
		["weapon_smg1"] = "smg",
		["weapon_physgun"] = "smg",
		["weapon_crossbow"] = "smg",
		["weapon_physcannon"] = "smg",
		["weapon_crowbar"] = "melee",
		["weapon_bugbait"] = "melee",
		["weapon_stunstick"] = "melee",
		["weapon_stunstick"] = "melee",
		["gmod_tool"] = "pistol",
		["weapon_357"] = "pistol",
		["weapon_pistol"] = "pistol",
		["weapon_frag"] = "grenade",
		["weapon_slam"] = "grenade",
		["weapon_rpg"] = "shotgun",
		["weapon_shotgun"] = "shotgun",
		["weapon_annabelle"] = "shotgun"
	}

	-- A function to get a weapon's hold type.
	function rw.anim:GetWeaponHoldType(player, weapon)
		if (!IsValid(weapon)) then return "normal"; end

		local class = string.lower(weapon:GetClass())
		local holdType = "normal"

		if (weaponHoldTypes[class]) then
			holdType = weaponHoldTypes[class]
		elseif (weapon and weapon.HoldType) then
			if (translateHoldTypes[weapon.HoldType]) then
				holdType = translateHoldTypes[weapon.HoldType]
			else
				holdType = weapon.HoldType
			end
		end

		return string.lower(holdType)
	end
end