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
	self.Skill = Skill.new()
end

function init:_Start()
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			character:SetAttribute("IsAttacking", false)
			character:WaitForChild("Humanoid").Died:Connect(function() end)

			local healthScript = character:WaitForChild("Health", 3)
			if healthScript then
				healthScript:Destroy()
			end
		end)
	end)

	Server.Player_Action.SetCallback(function(Player, Action, State)
		if Action == "ATTACK" then
			self.Attack:onAttack(Player)
		elseif Action == "DASH" and Player.Character:GetAttribute("IsAttacking") == false then
			self.Dash:onDash(Player)
		elseif Action == "SKILL_01" then
			self.Skill:onSkill(Player, 1)
		elseif Action == "SKILL_02" then
			self.Skill:onSkill(Player, 2)
		elseif Action == "SKILL_03" then
			self.Skill:onSkill(Player, 3)
		elseif Action == "SKILL_ULTI" then
			self.Skill:onSkill(Player, 4)
		end
	end)
end

return init
