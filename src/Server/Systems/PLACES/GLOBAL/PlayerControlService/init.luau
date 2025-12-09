--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Dash = require(script.Dash)
local Attack = require(script.Attack)
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
	self.Dash = Dash.new()
	self.Attack = Attack.new()
	self.Skill = Skill.new(self.Attack)
end

function init:_Start()
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			local healthScript = character:WaitForChild("Health", 3)
			if healthScript then
				healthScript:Destroy()
			end
		end)
	end)

	Server.Player_Action.SetCallback(function(Player, Action, State)
		warn("Player_Action", Player.Name, Action, State)

		if Action == "ATTACK" then
			self.Attack:onAttack(Player)
		elseif Action == "DASH" then
			self.Dash:onDash(Player)
		elseif Action == "SKILL" then
			self.Skill:onSkill(Player)
		end
	end)
end

return init
