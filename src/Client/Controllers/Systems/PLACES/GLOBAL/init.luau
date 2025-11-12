--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGUI = Player:WaitForChild("PlayerGui")
local MainUIFrame = PlayerGUI:WaitForChild("MainUI").MainFrame
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
local dashCooldown = 1 -- 0.5 giây hồi chiêu Dash

function init:_Setup()
	self.GUI = GUI.new()
	self.Minimap = Minimap.new()
	self.UI = UI.new()

	self.BTN_Attack = MainUIFrame:FindFirstChild("BTN_Attack") :: ImageButton
	self.BTN_Def = MainUIFrame:FindFirstChild("BTN_Def") :: ImageButton
	self.BTN_Dash = MainUIFrame:FindFirstChild("BTN_Dash") :: ImageButton
	self.BTN_Skill = MainUIFrame:FindFirstChild("BTN_Skill") :: ImageButton
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

	-- Nút ATTACK
	self.BTN_Attack.MouseButton1Click:Connect(function()
		Client.Player_Action.Fire("ATTACK", true)
	end)

	-- Nút DEF
	self.BTN_Def.MouseButton1Down:Connect(function()
		Client.Player_Action.Fire("BLOCK", true)
	end)
	self.BTN_Def.MouseButton1Up:Connect(function()
		Client.Player_Action.Fire("BLOCK", false)
	end)

	-- Nút DASH (có debounce)
	self.BTN_Dash.MouseButton1Click:Connect(function()
		if canDash then
			canDash = false
			Client.Player_Action.Fire("DASH", true)
			task.delay(dashCooldown, function()
				canDash = true
			end)
		end
	end)

	-- Nút SKILL
	self.BTN_Skill.MouseButton1Click:Connect(function()
		Client.Player_Action.Fire("SKILL", true)
	end)

	--!strict
	local Lighting = game:GetService("Lighting")

	-- Cấu hình
	local DAY_LENGTH = 60 * 60 -- 60 phút = 3600 giây ngoài đời

	-- Tính toán tốc độ tăng ClockTime (24 giờ game / 3600 giây thực)
	local HOURS_PER_SECOND = 24 / DAY_LENGTH

	-- Khởi tạo giá trị ban đầu (có thể để tùy ý, ví dụ 6 = 6 giờ sáng)
	Lighting.ClockTime = 6

	-- Vòng lặp cập nhật thời gian
	while true do
		task.wait(1)
		Lighting.ClockTime += HOURS_PER_SECOND
		if Lighting.ClockTime >= 24 then
			Lighting.ClockTime -= 24
		end
	end
end

return init
