--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
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

function init:_Setup()
	self.GUI = GUI.new()
	self.Minimap = Minimap.new()
	self.UI = UI.new()
	-- Chỉ giữ cooldown cơ bản
	self.cooldown = false
	self.cooldownTime = 0.5
end

function init:_Start()
	UserInputService.InputBegan:Connect(function(input, gameProcessedEvent: boolean)
		if gameProcessedEvent then
			return
		end

		-- Mouse 1 Click - Tấn công
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if not self.cooldown then
				self.cooldown = true
				Client.Player_Action.Fire("ATTACK", true)

				-- Reset cooldown sau 0.5s
				task.delay(self.cooldownTime, function()
					self.cooldown = false
				end)
			end

		-- Right Mouse Button - Thủ
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			Client.Player_Action.Fire("BLOCK", true)

		-- Q - Lướt
		elseif input.KeyCode == Enum.KeyCode.Q then
			Client.Player_Action.Fire("DASH", true)

		-- E - Skill (gửi kèm combo index hiện tại từ server)
		elseif input.KeyCode == Enum.KeyCode.E then
			local currentCombo = Player:GetAttribute("Combo") or 0
			if currentCombo > 0 then
				Client.Player_Action.Fire("SKILL", currentCombo)
			end
		end
	end)

	-- Release Right Mouse Button
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
