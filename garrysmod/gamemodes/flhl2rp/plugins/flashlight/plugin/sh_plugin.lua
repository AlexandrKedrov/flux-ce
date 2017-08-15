--[[
	Flux © 2016-2017 TeslaCloud Studios
	Do not share or re-distribute before
	the framework is publicly released.
--]]

if (SERVER) then
	function PLUGIN:PlayerSwitchFlashlight(player, bIsOn)
		if (bIsOn and !player:HasItem("flashlight")) then
			return false
		end

		return true
	end

	function PLUGIN:OnItemTaken(player, instanceID, slotID)
		if (player:FlashlightIsOn() and !player:HasItem("flashlight")) then
			player:Flashlight(false)
		end
	end
end