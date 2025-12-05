--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGUI = Player:WaitForChild("PlayerGui")
-- local MainUIFrame = PlayerGUI:WaitForChild("MainUI").MainFrame
local UserInputService = game:GetService("UserInputService")

local UI = require(script.UI)
local Client = require(ReplicatedStorage.Shared.Network.Client)
local Openday = require(ReplicatedStorage.Shared.Openday)
local GUI = require(script.GUI)
local Minimap = require(script.Minimap)

export type System = {
	_Extensions: { Openday.Extension },
	_Start: (self: System) -> (),
	_Setup: (self: System) -> (),
}

local init = {
	_Extensions = {},
} :: System

-- Biến debounce cho Dash
local canDash = true
local dashCooldown = 1

function init:_Setup()
	self.GUI = GUI.new()
	self.Minimap = Minimap.new()
	self.UI = UI.new()
end

function init:_Start()
	UserInputService.InputBegan:Connect(function(input, gameProcessedEvent: boolean)
		if gameProcessedEvent then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			Client.Player_Action.Fire("ATTACK", true)
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			Client.Player_Action.Fire("BLOCK", true)
		elseif input.KeyCode == Enum.KeyCode.Q then
			if canDash then
				canDash = false
				Client.Player_Action.Fire("DASH", true)
				task.delay(dashCooldown, function()
					canDash = true
				end)
			end
		elseif input.KeyCode == Enum.KeyCode.E then
			Client.Player_Action.Fire("SKILL", true)
		end
	end)

	UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			Client.Player_Action.Fire("BLOCK", false)
		end
	end)
end

return init
