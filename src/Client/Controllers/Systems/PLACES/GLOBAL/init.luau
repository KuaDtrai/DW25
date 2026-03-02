--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local PlayerGUI = Player:WaitForChild("PlayerGui")
local SoundService = game:GetService("SoundService")
-- local sound = ReplicatedStorage.Shared.Assets.Sounds:WaitForChild("Sword_Swing_01")
local TeleportService = game:GetService("TeleportService")
local TeleportData = TeleportService:GetLocalPlayerTeleportData() or {}
local Dash = require(script.Dash)

local Utilities = require(ReplicatedStorage.Shared.Modules.Utilities)
local Client = require(ReplicatedStorage.Shared.Network.Client)
local Openday = require(ReplicatedStorage.Shared.Openday)

local UI = require(script.UI)
local GUI = require(script.GUI)
-- local Minimap = require(script.Minimap)

local VFX_Folder = ReplicatedStorage.Shared.Assets.VFXs
local WeaponVFXs = VFX_Folder:WaitForChild("Weapon")

local Sword_VFXs = WeaponVFXs:WaitForChild("Sword")
local Greatsword_VFXs = WeaponVFXs:WaitForChild("Greatsword")
local Lance_VFXs = WeaponVFXs:WaitForChild("Lance")

local Sword_1 = Sword_VFXs:WaitForChild("1")
local Sword_2 = Sword_VFXs:WaitForChild("2")
local Sword_3 = Sword_VFXs:WaitForChild("3")
local Sword_4 = Sword_VFXs:WaitForChild("4")

local Greatsword_1 = Greatsword_VFXs:WaitForChild("1")
local Greatsword_2 = Greatsword_VFXs:WaitForChild("2")
local Greatsword_3 = Greatsword_VFXs:WaitForChild("3")
local Greatsword_4 = Greatsword_VFXs:WaitForChild("4")

local Lance_1 = Lance_VFXs:WaitForChild("1")
local Lance_2 = Lance_VFXs:WaitForChild("2")
local Lance_3 = Lance_VFXs:WaitForChild("3")
local Lance_4 = Lance_VFXs:WaitForChild("4")

-- local VFX_C1 = ReplicatedStorage.Shared.Assets.VFXs.COMBO1
-- local VFX_C2 = ReplicatedStorage.Shared.Assets.VFXs.COMBO2
-- local VFX_C3 = ReplicatedStorage.Shared.Assets.VFXs.COMBO3
local VFX_Hit = ReplicatedStorage.Shared.Assets.VFXs.HIT

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
	-- self.Minimap = Minimap.new()
	self.UI = UI.new()
	self.MouseLock:Enable()
end

----------------------------------------------------------------
-- System Start
----------------------------------------------------------------
function init:_Start()
	Client.VFX_Signal.SetCallback(function(name, position)
		if name == "SWORD_1" then
			Utilities.ParticleBurst(Sword_1, position)
		elseif name == "SWORD_2" then
			Utilities.ParticleBurst(Sword_2, position)
		elseif name == "SWORD_3" then
			Utilities.ParticleBurst(Sword_3, position)
		elseif name == "SWORD_4" then
			Utilities.ParticleBurst(Sword_4, position)
		elseif name == "GREATSWORD_1" then
			Utilities.ParticleBurst(Greatsword_1, position)
		elseif name == "GREATSWORD_2" then
			Utilities.ParticleBurst(Greatsword_2, position)
		elseif name == "GREATSWORD_3" then
			Utilities.ParticleBurst(Greatsword_3, position)
		elseif name == "GREATSWORD_4" then
			Utilities.ParticleBurst(Greatsword_4, position)
		elseif name == "LANCE_1" then
			Utilities.ParticleBurst(Lance_1, position)
		elseif name == "LANCE_2" then
			Utilities.ParticleBurst(Lance_2, position)
		elseif name == "LANCE_3" then
			Utilities.ParticleBurst(Lance_3, position)
		elseif name == "LANCE_4" then
			Utilities.ParticleBurst(Lance_4, position)
		elseif name == "HIT" then
			Utilities.ParticleBurst(VFX_Hit, position)
		end

		SoundService:FindFirstChild("Sword_Swing_01"):Play()
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
		elseif input.KeyCode == Enum.KeyCode.X then
			Client.Player_Action.Fire("SKILL_01", true)
		----------------------------------------------------------------
		-- DASH
		----------------------------------------------------------------
		elseif input.KeyCode == Enum.KeyCode.Q then
			if not Player:GetAttribute("IsAttacking") then
				Dash:DoDash()
			end

		----------------------------------------------------------------
		-- SKILL
		----------------------------------------------------------------
		elseif input.KeyCode == Enum.KeyCode.E then
			Client.Player_Action.Fire("SKILL", true)
		end
	end)
end

return init
