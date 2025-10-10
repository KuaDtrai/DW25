--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
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
	-- self.PlayerState = PlayerState.new()

	self.GUI = GUI.new()
	self.Minimap = Minimap.new()

	self.ComboResetTime = 1
	self.ComboResetTask = nil
	self.cooldown = false
	self.cooldownTime = 0.5
	self.ComboCooldownTime = 1
	self.comboCount = 0
	self.SkillCooldown = false
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
				if not self.cooldown then
					self.cooldown = true

					-- Cancel old reset timer
					if self.comboResetTask then
						task.cancel(self.comboResetTask)
						self.comboResetTask = nil
					end

					-- Increment combo
					if self.comboCount <= 2 and self.SkillCooldown == false then
						self.comboCount += 1
						-- Normal attack cooldown
						Client.Player_Action.Fire("ATTACK", true)
						task.delay(self.cooldownTime, function()
							self.cooldown = false
						end)
					else
						-- After 3rd hit → Combo cooldown
						task.delay(self.ComboCooldownTime, function()
							self.comboCount = 0
							self.SkillCooldown = false
							self.cooldown = false
						end)
					end
					-- Start/reset combo timeout timer
					self.comboResetTask = task.delay(self.ComboResetTime, function()
						self.comboCount = 0
					end)
				end
				-- Client.Player_Action.Fire("ATTACK", true)
			elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
				-- Thủ --
				Client.Player_Action.Fire("BLOCK", true)
			elseif input.KeyCode == Enum.KeyCode.Q then
				-- Lướt --
				Client.Player_Action.Fire("DASH", true)
			elseif input.KeyCode == Enum.KeyCode.E then
				-- Chiêu --
				if self.comboCount == 1 then
					warn("Skill 1")
					self.SkillCooldown = true
					Client.Player_Action.Fire("SKILL", true)
				elseif self.comboCount == 2 then
					warn("Skill 2")
					self.SkillCooldown = true
					Client.Player_Action.Fire("SKILL", true)
				elseif self.comboCount == 3 then
					warn("Skill 3")
					self.SkillCooldown = true
					Client.Player_Action.Fire("SKILL", true)
				end
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
