--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local Client = ReplicatedStorage.Shared.Network.Client
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

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
				-- Send signal to PlayerManager
				Client.LeftClicked.Fire()
				-- Pressed V button
			elseif input.KeyCode == Enum.KeyCode.F then
				-- Send signal to PlayerManager
				Client.Block.Fire(true)
			elseif input.KeyCode == Enum.KeyCode.Q then
				Client.AltToggle.Fire()
			elseif input.KeyCode == Enum.KeyCode.LeftShift then
				Client.ShiftToggle.Fire(true)
			end
		end)
		-- On Release V button
		UserInputService.InputEnded:Connect(function(input: InputObject, gameProcessedEvent: boolean)
			if gameProcessedEvent then
				return
			end

			if input.KeyCode == Enum.KeyCode.F then
				-- Send signal to PlayerManager
				Client.Block.Fire(false)
			-- elseif input.KeyCode == Enum.KeyCode.Q then
			-- 	Client.AltToggle.Fire(false)
			elseif input.KeyCode == Enum.KeyCode.LeftShift then
				Client.ShiftToggle.Fire(false)
			end
		end)
	end)
end

return init
