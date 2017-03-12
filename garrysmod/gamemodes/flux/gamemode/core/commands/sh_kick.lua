--[[
	Flux © 2016-2017 TeslaCloud Studios
	Do not share or re-distribute before
	the framework is publicly released.
--]]

local COMMAND = Command("kick")
COMMAND.name = "Kick"
COMMAND.description = "#KickCMD_Description"
COMMAND.syntax = "#KickCMD_Syntax"
COMMAND.category = "administration"
COMMAND.arguments = 1
COMMAND.immunity = true
COMMAND.aliases = {"plykick"}

function COMMAND:OnRun(player, target, ...)
	local pieces = {...}
	local reason = "Kicked for unspecified reason."

	if (#pieces > 0) then
		reason = string.Implode(" ", pieces)
	end

	fl.player:NotifyAll(L("KickMessage", (IsValid(player) and player:Name()) or "Console", target:Name(), reason))

	target:Kick(reason)
end

COMMAND:Register()