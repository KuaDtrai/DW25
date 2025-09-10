--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local Client = require(ReplicatedStorage.Shared.Network.Client)

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
	-- self.PlayerState = PlayerState.new()
end

function init:_Start()
	Player.CharacterAdded:Connect(function(character: Model)
		UserInputService.InputBegan:Connect(function(input, gameProcessedEvent: boolean)
			if gameProcessedEvent then
				return
			end
			-- Mouse 1 Click
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				-- Tấn công --
				Client.Player_Action.Fire("ATTACK", true)
			elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
				-- Thủ --
				Client.Player_Action.Fire("BLOCK", true)
			elseif input.KeyCode == Enum.KeyCode.Q then
				-- Lướt --
				Client.Player_Action.Fire("DASH", true)
			elseif input.KeyCode == Enum.KeyCode.E then
				-- Chiêu --
				Client.Player_Action.Fire("SKILL", true)
			elseif input.KeyCode == Enum.KeyCode.M then
				-- Bản đồ
				warn("Map")
			elseif input.KeyCode == Enum.KeyCode.B then
				-- Túi đồ/Hành trang --
				warn("Bag")
			elseif input.KeyCode == Enum.KeyCode.P then
				-- Tạm dừng/Tùy chọn
				warn("Pause/Option")
			end
		end)
		-- On Release Right Mouse Button
		UserInputService.InputEnded:Connect(function(input: InputObject, gameProcessedEvent: boolean)
			if gameProcessedEvent then
				return
			end

			if input.UserInputType == Enum.UserInputType.MouseButton2 then
				Client.Player_Action.Fire("BLOCK", false)
			end
		end)
	end)
end

return init
