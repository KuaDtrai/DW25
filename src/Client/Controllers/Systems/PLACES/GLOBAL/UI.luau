--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local Client = require(ReplicatedStorage.Shared.Network.Client)
local CONSTANTS = require(ReplicatedStorage.Shared.Libraries.CONSTANTS)
local Utilities = require(ReplicatedStorage.Shared.Modules.Utilities)

export type UI = {
	__index: UI,
	new: () -> UI,
	Destroy: (self: UI) -> (),
}
local Class: UI = {} :: UI
Class.__index = Class

function Class.new(): UI
	local self: UI = setmetatable({} :: any, Class)

	self.PlayerGui = Player:WaitForChild("PlayerGui")

	self.MainUI = self.PlayerGui:WaitForChild("MainUI") :: ScreenGui
	self.OptionUI = self.PlayerGui:WaitForChild("OptionUI") :: ScreenGui

	--MainUI
	self.MainUIFrame = self.MainUI:WaitForChild("MainFrame") :: Frame
	self.BTN_Option = self.MainUIFrame:WaitForChild("BTN_Option") :: ImageButton

	--Option UI
	self.OptionFrame = self.OptionUI:WaitForChild("OptionUI") :: Frame
	self.CloseBTN2 = self.OptionFrame:WaitForChild("BTN_Close") :: ImageButton
	self.ExitBTN = self.OptionFrame:WaitForChild("BTN_ExitPlace") :: ImageButton

	-- Sự kiện nhấn nút Option
	if self.BTN_Option:IsA("ImageButton") then
		self.BTN_Option.MouseButton1Click:Connect(function()
			self.OptionUI.Enabled = true
			warn("Option Clicked")
		end)
	end

	-- Sự kiện trong Option UI
	if self.CloseBTN2:IsA("ImageButton") then
		self.CloseBTN2.MouseButton1Click:Connect(function()
			self.OptionUI.Enabled = false
		end)
	end

	if self.ExitBTN:IsA("ImageButton") then
		self.ExitBTN.MouseButton1Click:Connect(function()
			if game.PlaceId == CONSTANTS.LACDUONG_ID then
				warn("hihi")
			else
				Utilities.ShowLoadingUI(Player)
				Client.TeleportToCampaign.Fire("LACDUONG")
				warn("haha")
			end
		end)
	end

	-- 🔹 Kiểm tra nếu người chơi đang trên thiết bị di động
	if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
		local PlayerModule = require(Player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
		local Controls = PlayerModule:GetControls()
		local TouchJumpButton = Player.PlayerGui:WaitForChild("TouchGui", 10)
		if TouchJumpButton then
			local jumpBtn = TouchJumpButton:FindFirstChild("JumpButton", true)
			if jumpBtn and jumpBtn:IsA("ImageButton") then
				-- Kích thước {0,50}, {0,50}
				jumpBtn.Size = UDim2.new(0, 50, 0, 50)
				-- Vị trí {1,-30}, {1,-60}
				jumpBtn.Position = UDim2.new(1, -30, 1, -60)
				warn("Adjusted Jump Button for Mobile")
			end
		end
	end

	return self
end

function Class:Destroy() end

return Class
