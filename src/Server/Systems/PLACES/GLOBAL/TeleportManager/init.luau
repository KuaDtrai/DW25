--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

local Openday = require(ReplicatedStorage.Shared.Openday)
local Server = require(ReplicatedStorage.Shared.Network.Server)
local CONSTANTS = require(ReplicatedStorage.Shared.Libraries.CONSTANTS)

export type System = {
	_Extensions: { Openday.Extension },
	_Start: (self: System) -> (),
	_Setup: (self: System) -> (),
}

local init = {
	_Extensions = {},
} :: System

function init:_Setup() end

function init:_Start()
	Server.TeleportToCampaign.SetCallback(function(player: Player, campaign: string)
		warn("Teleport to campaign", player, campaign)
		local tele_to = CONSTANTS.LOBBY_ID
		if campaign == "LACDUONG" then
			tele_to = CONSTANTS.LACDUONG_ID
		elseif campaign == "LOBBY" then
			tele_to = CONSTANTS.LOBBY_ID
		elseif campaign == "MAP1" then
			tele_to = CONSTANTS.MAP1_ID
		elseif campaign == "MAP2" then
			tele_to = CONSTANTS.MAP2_ID
		elseif campaign == "MAP3" then
			tele_to = CONSTANTS.MAP3_ID
		end
		warn(campaign)
		TeleportService:Teleport(tele_to, player, "Teleport")
	end)

	Server.MatchMaking.SetCallback(function(player, Value)
		warn("Match making", player, Value)
		TeleportService:Teleport(CONSTANTS.ARENA_ID, player)
	end)
end

return init
