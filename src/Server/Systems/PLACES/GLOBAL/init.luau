--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Server = require(ReplicatedStorage.Shared.Network.Server)
local Openday = require(ReplicatedStorage.Shared.Openday)

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
	Server.Attack.SetCallback(function(Player)
		warn("Attack", Player)
	end)

	Server.Block.SetCallback(function(Player)
		warn("Block", Player)
	end)

	Server.Dash.SetCallback(function(Player)
		warn("Dash", Player)
	end)

	Server.Skill.SetCallback(function(Player)
		warn("Skill", Player)
	end)
end

return init
