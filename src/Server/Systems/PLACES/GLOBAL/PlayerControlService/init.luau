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
function init:_Setup()
	warn(1)
	self.Dash = Dash.new()
	warn(2)
	self.Attack = Attack.new()
	warn(3)
	self.Block = Block.new()
	warn(4)
	self.Skill = Skill.new()
	warn(5)
end

function init:_Start()
	Server.Player_Action.SetCallback(function(Player, Action, State)
		warn("Player_Action", Player, Action, State)
		if Action == "ATTACK" then
			self.Attack:onAttack(Player, State)
		elseif Action == "BLOCK" then
			self.Block:onBlock(Player, State)
		elseif Action == "DASH" then
			self.Dash:onDash(Player)
		elseif Action == "SKILL" then
			self.Skill:onSkill(Player)
		end
	end)
end

return init
