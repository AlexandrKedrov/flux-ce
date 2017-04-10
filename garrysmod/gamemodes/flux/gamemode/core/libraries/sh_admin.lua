--[[
	Flux © 2016-2017 TeslaCloud Studios
	Do not share or re-distribute before
	the framework is publicly released.
--]]

library.New("admin", fl)
local groups = fl.admin.groups or {}			-- Usergroups data
local permissions = fl.admin.permissions or {}	-- Permission descriptions and other data
local players = fl.admin.players or {}			-- Compiled permissions for each player
fl.admin.groups = groups
fl.admin.permissions = permissions
fl.admin.players = players

local compilerCache = {}

function fl.admin:CreateGroup(id, data)
	if (!isstring(id)) then return end

	data.m_uniqueID = id

	if (data.m_Base) then
		local parent = groups[data.m_Base]

		if (parent) then
			local parentCopy = table.Copy(parent)

			table.Merge(parentCopy.m_Permissions, data.m_Permissions)

			data.m_Permissions = parentCopy.m_Permissions

			for k, v in pairs(parentCopy) do
				if (k == "m_Permissions") then continue end

				if (!data[k]) then
					data[k] = v
				end
			end
		end
	end

	if (!groups[id]) then
		groups[id] = data
	end
end

function fl.admin:AddPermission(id, category, data)
	if (!id) then return end

	category = category or "general"
	data.uniqueID = id
	permissions[category] = permissions[category] or {}

	if (!permissions[category][id]) then
		permissions[category][id] = data
	end
end

function fl.admin:PermissionFromCommand(cmdObj)
	if (!cmdObj) then return end

	local data = {}
		data.uniqueID = cmdObj.uniqueID or cmdObj.name:MakeID()
		data.description = cmdObj.description or "No description provided"
		data.category = cmdObj.category or "general"
		data.name = cmdObj.name or cmdObj.uniqueID
	self:AddPermission(data.uniqueID, data.category, data)
end

function fl.admin:CheckPermission(player, permission)
	local playerPermissions = players[player:SteamID()]

	if (playerPermissions) then
		return playerPermissions[permission]
	end
end

function fl.admin:GetPermissionsInCategory(category)
	local perms = {}

	if (category == "all") then
		for k, v in pairs(permissions) do
			for k2, v2 in pairs(v) do
				table.insert(perms, k2)
			end
		end
	else
		if (permissions[category]) then
			for k, v in pairs(permissions[category]) do
				table.insert(perms, k)
			end
		end
	end

	return perms
end

function fl.admin:IsCategory(id)
	if (id == "all" or permissions[id]) then
		return true
	end

	return false
end

function fl.admin:GetGroupPermissions(id)
	if (groups[id]) then
		return groups[id].m_Permissions
	else
		return {}
	end
end

function fl.admin:HasPermission(player, permission)
	if (!IsValid(player)) then return true end
	if (player:IsOwner()) then return true end
	if (player:IsCoOwner()) then return true end

	local steamID = player:SteamID()

	if (players[steamID] and (players[steamID][permission] or players[steamID]["all"])) then
		return true
	end

	local netPerms = player:GetNetVar("flPermissions", {})

	if (netPerms and netPerms[permission]) then
		return true
	end

	return false
end

function fl.admin:FindGroup(id)
	if (groups[id]) then
		return groups[id]
	end

	return nil
end

function fl.admin:GroupExists(id)
	return self:FindGroup(id)
end

function fl.admin:CheckImmunity(player, target, canBeEqual)
	if (!IsValid(player) or !IsValid(target)) then
		return true
	end

	local group1 = self:FindGroup(player:GetUserGroup())
	local group2 = self:FindGroup(target:GetUserGroup())

	if (!isnumber(group1.immunity) or !isnumber(group2.immunity)) then
		return true
	end

	if (group1.immunity > group2.immunity) then
		return true
	end

	if (canBeEqual and group1.immunity == group2.immunity) then
		return true
	end

	return false
end

pipeline.Register("group", function(uniqueID, fileName, pipe)
	GROUP = Group(uniqueID)

	util.Include(fileName)

	GROUP:Register() GROUP = nil
end)

function fl.admin:IncludeGroups(directory)
	pipeline.IncludeDirectory("group", directory)
end

if (SERVER) then
	local function SetPermission(steamID, permID, value)
		players[steamID] = players[steamID] or {}
		players[steamID][permID] = value
	end

	local function DeterminePermission(steamID, permID, value)
		local permTable = compilerCache[steamID]

		permTable[permID] = permTable[permID] or PERM_NO

		if (value == PERM_NO) then return end
		if (permTable[permID] == PERM_ALLOW_OVERRIDE) then return end

		if (value == PERM_ALLOW_OVERRIDE) then
			permTable[permID] = PERM_ALLOW_OVERRIDE
			SetPermission(steamID, permID, true)

			return
		end

		if (permTable[permID] == PERM_NEVER) then return end
		if (permTable[permID] == value) then return end

		if (value == PERM_NEVER) then
			permTable[permID] = PERM_NEVER
			SetPermission(steamID, permID, false)

			return
		elseif (value == PERM_ALLOW) then
			permTable[permID] = PERM_ALLOW
			SetPermission(steamID, permID, true)

			return
		end

		permTable[permID] = PERM_ERROR
		SetPermission(steamID, permID, false)
	end

	local function DetermineCategory(steamID, permID, value)
		if (fl.admin:IsCategory(permID)) then
			local catPermissions = fl.admin:GetPermissionsInCategory(permID)

			for k, v in ipairs(catPermissions) do
				DeterminePermission(steamID, v, value)
			end
		else
			DeterminePermission(steamID, permID, value)
		end
	end

	function fl.admin:CompilePermissions(player)
		if (!IsValid(player)) then return end

		local steamID = player:SteamID()
		local userGroup = player:GetUserGroup()
		local secondaryGroups = player:GetSecondaryGroups()
		local playerPermissions = player:GetCustomPermissions()
		local groupPermissions = self:GetGroupPermissions(userGroup)

		compilerCache[steamID] = {}

		for k, v in pairs(groupPermissions) do
			DetermineCategory(steamID, k, v)
		end

		for _, group in ipairs(secondaryGroups) do
			local permTable = self:GetGroupPermissions(group)

			for k, v in pairs(permTable) do
				DetermineCategory(steamID, k, v)
			end
		end

		for k, v in pairs(playerPermissions) do
			DetermineCategory(steamID, k, v)
		end

		local extras = {}

		hook.Run("OnPermissionsCompiled", extras)

		if (istable(extras)) then
			for id, extra in pairs(extras) do
				for k, v in pairs(extra) do
					DeterminePermissions(steamID, k, v)
				end
			end
		end

		player:SetPermissions(players[steamID])
		compilerCache[steamID] = nil
	end
end