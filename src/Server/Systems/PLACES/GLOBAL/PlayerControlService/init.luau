--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Dash = require(script.Dash)
local Attack = require(script.Attack)
local UseFirework = require(script.UseFireworkModule)

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
	self.UseFirework = UseFirework.new()
end

function init:_Start()
	warn(self)

	Server.Player_Action.SetCallback(function(Player, Action, State)
		if Action == "ATTACK" then
			self.Attack:onAttack(Player)
		elseif Action == "DASH" and Player.Character:GetAttribute("IsAttacking") == false then
			self.Dash:onDash(Player)
		elseif Action == "SKILL_01" then
			if not Player.Character:FindFirstChild("Firework") then
				return
			end
			local pos = Player.Character.PrimaryPart.CFrame.Position
			self.UseFirework:Use(Player, pos)
		end
	end)

	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			character:SetAttribute("ComboIndex", 0)
			character:SetAttribute("Damage", 20)
			character:SetAttribute("Dashing", true)
			character:SetAttribute("EquippedWeapon", "")
			character:SetAttribute("IsAttacking", false)

			character:WaitForChild("Humanoid").Died:Connect(function() end)

			local healthScript = character:WaitForChild("Health", 3)
			if healthScript then
				healthScript:Destroy()
			end
		end)
	end)
end

return init
