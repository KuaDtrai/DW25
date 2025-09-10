--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Dash = require(script.Dash)
local Attack = require(script.Attack)
local Block = require(script.Block)
local Skill = require(script.Skill)

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
local Dash = Dash.new()
local Attack = Attack.new()
local Block = Block.new()
local Skill = Skill.new()
function init:_Setup()
	-- self.Dash = Dash.new()
	-- self.Attack = Attack.new()
	-- self.Block = Block.new()
	-- self.Skill = Skill.new()
end

function init:_Start()
	Server.Player_Action.SetCallback(function(Player, Action, State)
		warn("Player_Action", Player, Action, State)
		if Action == "ATTACK" then
			Attack:onAttack(Player, State)
		elseif Action == "BLOCK" then
			Block:onBlock(Player, State)
		elseif Action == "DASH" then
			Dash:onDash(Player)
		elseif Action == "SKILL" then
			Skill:onSkill(Player)
		end
	end)
end

return init
