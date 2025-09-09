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
				Client.Attack.Fire()
			elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
				Client.Block.Fire()
			elseif input.KeyCode == Enum.KeyCode.Q then
				Client.Dash.Fire()
			elseif input.KeyCode == Enum.KeyCode.LeftShift then
				Client.ShiftToggle.Fire(true)
			end
		end)
		-- On Release V button
		UserInputService.InputEnded:Connect(function(input: InputObject, gameProcessedEvent: boolean)
			if gameProcessedEvent then
				return
			end

			if input.KeyCode == Enum.UserInputType.MouseButton2 then
				Client.Block.Fire(false)
			end
		end)
	end)
end

return init
