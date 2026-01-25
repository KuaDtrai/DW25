--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local MouseLock = require(script.MouseLock)
local Player = Players.LocalPlayer
local PlayerGUI = Player:WaitForChild("PlayerGui")

local Utilities = require(ReplicatedStorage.Shared.Modules.Utilities)
local Client = require(ReplicatedStorage.Shared.Network.Client)
local Openday = require(ReplicatedStorage.Shared.Openday)

local UI = require(script.UI)
local GUI = require(script.GUI)
local Minimap = require(script.Minimap)

local VFX_C1 = ReplicatedStorage.Shared.Assets.VFX.COMBO1
local VFX_C2 = ReplicatedStorage.Shared.Assets.VFX.COMBO2
local VFX_C3 = ReplicatedStorage.Shared.Assets.VFX.COMBO3
local VFX_Hit = ReplicatedStorage.Shared.Assets.VFX.HIT

export type System = {
	_Extensions: { Openday.Extension },
	_Start: (self: System) -> (),
	_Setup: (self: System) -> (),
}

local init = {
	_Extensions = {},
} :: System

----------------------------------------------------------------
-- System Setup
----------------------------------------------------------------
function init:_Setup()
	self.GUI = GUI.new()
	self.Minimap = Minimap.new()
	self.UI = UI.new()
	self.MouseLock = MouseLock.new()

	self.MouseLock:Enable()
end

----------------------------------------------------------------
-- System Start
----------------------------------------------------------------
function init:_Start()
	Client.VFX_Signal.SetCallback(function(name, position)
		if name == "COMBO1" then
			Utilities.ParticleBurst(VFX_C1, position)
		elseif name == "COMBO2" then
			Utilities.ParticleBurst(VFX_C2, position)
		elseif name == "COMBO3" then
			Utilities.ParticleBurst(VFX_C3, position)
		elseif name == "HIT" then
			Utilities.ParticleBurst(VFX_Hit, position)
		end
	end)

	UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent then
			return
		end

		----------------------------------------------------------------
		-- ATTACK
		----------------------------------------------------------------
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if not Player.Character:GetAttribute("IsAttacking") then
				Client.Player_Action.Fire("ATTACK", true)
			end

		----------------------------------------------------------------
		-- DASH
		----------------------------------------------------------------
		elseif input.KeyCode == Enum.KeyCode.Q then
		----------------------------------------------------------------
		-- SKILL
		----------------------------------------------------------------
		elseif input.KeyCode == Enum.KeyCode.E then
			Client.Player_Action.Fire("SKILL", true)
		end
	end)
end

return init
