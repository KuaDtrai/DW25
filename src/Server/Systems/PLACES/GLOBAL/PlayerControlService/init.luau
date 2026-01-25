--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Dash = require(script.Dash)
local Attack = require(script.Attack)
local Skill = require(script.Skill)

-- local MovementController = require(script.CharacterMovementController)

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
			-- MovementController.bind(character)

			character:SetAttribute("IsAttacking", false)
			-- MovementController.bind(character)
			character:WaitForChild("Humanoid").Died:Connect(function()
				-- MovementController.unbind(character)
			end)

			local healthScript = character:WaitForChild("Health", 3)
			if healthScript then
				healthScript:Destroy()
			end
		end)
	end)

	Server.Player_Action.SetCallback(function(Player, Action, State)
		-- warn("Player_Action", Player.Name, Action, State)

		if Action == "ATTACK" then
			self.Attack:onAttack(Player)
		elseif Action == "DASH" and Player.Character:GetAttribute("IsAttacking") == false then
			self.Dash:onDash(Player)
		elseif Action == "SKILL" then
			self.Skill:onSkill(Player)
		end
	end)
end

return init
