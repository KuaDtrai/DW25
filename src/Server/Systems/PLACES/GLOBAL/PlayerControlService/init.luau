--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

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
	self.Dash = Dash.new()
	self.Attack = Attack.new()
	self.Block = Block.new()
	self.Skill = Skill.new(self.Attack)
end

function init:_Start()
	-- Lưu combo state cho mỗi player
	local playerComboData = {}

	-- Cleanup khi player rời game
	Players.PlayerRemoving:Connect(function(player)
		playerComboData[player] = nil
	end)

	Server.Player_Action.SetCallback(function(Player, Action, State)
		warn("Player_Action", Player.Name, Action, State)

		if Action == "ATTACK" then
			self.Attack:onAttack(Player)
		elseif Action == "BLOCK" then
			self.Block:onBlock(Player, State)
		elseif Action == "DASH" then
			self.Dash:onDash(Player)
		elseif Action == "SKILL" then
			-- State giờ là combo index (1, 2, 3)
			local comboIndex = State
			self.Skill:onSkill(Player)
		end
	end)
end

return init
