--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
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
	self.MainUIFrame = self.MainUI:WaitForChild("MainUI") :: Frame
	self.BTN_Option = self.MainUIFrame:WaitForChild("BTN_Option") :: ImageButton

	--Option UI
	self.OptionFrame = self.OptionUI:WaitForChild("OptionUI") :: Frame
	self.CloseBTN2 = self.OptionFrame:WaitForChild("BTN_Close") :: ImageButton
	self.ExitBTN = self.OptionFrame:WaitForChild("BTN_ExitPlace") :: ImageButton

	-- self.LacDuongBTN = self.ScreenGui:WaitForChild("LacDuongThanh") :: TextButton
	-- self.MAP1BTN = self.ScreenGui:WaitForChild("Map1") :: TextButton

	if self.BTN_Option:IsA("ImageButton") then
		self.BTN_Option.MouseButton1Click:Connect(function()
			self.OptionUI.Enabled = true
			warn("Option Clicked")
		end)
	end

	--Option UI features
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

	return self
end

function Class:Destroy() end

return Class
