--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Client = require(ReplicatedStorage.Shared.Network.Client)
local CONSTANTS = require(ReplicatedStorage.Shared.Libraries.CONSTANTS)

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
	-- self.ScreenGui = self.PlayerGui:WaitForChild("ScreenGui")

	self.CampaignList = self.PlayerGui:WaitForChild("CampaignList") :: ScreenGui
	self.MainUI = self.PlayerGui:WaitForChild("MainUI") :: ScreenGui
	self.OptionUI = self.PlayerGui:WaitForChild("OptionUI") :: ScreenGui
	self.ArenaList = self.PlayerGui:WaitForChild("ArenaList") :: ScreenGui

	--MainUI
	self.MainUIFrame = self.MainUI:WaitForChild("MainUI") :: Frame
	self.BTN_Campaign = self.MainUIFrame:WaitForChild("BTN_Campaign") :: ImageButton
	self.BTN_Arena = self.MainUIFrame:WaitForChild("BTN_Arena") :: ImageButton
	self.BTN_Option = self.MainUIFrame:WaitForChild("BTN_Option") :: ImageButton

	--Campaign UI
	self.CampaignFrame = self.CampaignList:WaitForChild("Select-Campaign") :: Frame
	self.CloseBTN = self.CampaignFrame:WaitForChild("BTN_Close") :: ImageButton
	self.Map1BTN = self.CampaignFrame:WaitForChild("BTN_Map1") :: ImageButton
	self.Map2BTN = self.CampaignFrame:WaitForChild("BTN_Map2") :: ImageButton
	self.Map3BTN = self.CampaignFrame:WaitForChild("BTN_Map3") :: ImageButton

	--Option UI
	self.OptionFrame = self.OptionUI:WaitForChild("OptionUI") :: Frame
	self.CloseBTN2 = self.OptionFrame:WaitForChild("BTN_Close") :: ImageButton
	self.ExitBTN = self.OptionFrame:WaitForChild("BTN_ExitPlace") :: ImageButton

	--ArenaUI
	self.ArenaFrame = self.ArenaList:WaitForChild("Select-PVE") :: Frame
	self.CloseBTN3 = self.ArenaFrame:WaitForChild("BTN_Close") :: ImageButton
	self.Map1BTN1 = self.ArenaFrame:WaitForChild("BTN_Map1") :: ImageButton
	self.Map2BTN1 = self.ArenaFrame:WaitForChild("BTN_Map2") :: ImageButton
	self.Map3BTN1 = self.ArenaFrame:WaitForChild("BTN_Map3") :: ImageButton

	-- self.LacDuongBTN = self.ScreenGui:WaitForChild("LacDuongThanh") :: TextButton
	-- self.MAP1BTN = self.ScreenGui:WaitForChild("Map1") :: TextButton

	if self.BTN_Campaign:IsA("ImageButton") then
		self.BTN_Campaign.MouseButton1Click:Connect(function()
			self.CampaignList.Enabled = true
			warn("Campaign Clicked")
		end)
	end

	if self.BTN_Arena:IsA("ImageButton") then
		self.BTN_Arena.MouseButton1Click:Connect(function()
			self.ArenaList.Enabled = true
			warn("ARENA Clicked")
		end)
	end

	if self.BTN_Option:IsA("ImageButton") then
		self.BTN_Option.MouseButton1Click:Connect(function()
			self.OptionUI.Enabled = true
			warn("Option Clicked")
		end)
	end

	--Campaign UI features
	if self.CloseBTN:IsA("ImageButton") then
		self.CloseBTN.MouseButton1Click:Connect(function()
			self.CampaignList.Enabled = false
		end)
	end
	if self.Map1BTN:IsA("ImageButton") then
		self.Map1BTN.MouseButton1Click:Connect(function()
			Client.TeleportToCampaign.Fire("Map1")
		end)
	end

	--Arena UI features
	if self.CloseBTN3:IsA("ImageButton") then
		self.CloseBTN3.MouseButton1Click:Connect(function()
			self.ArenaList.Enabled = false
		end)
	end
	if self.Map1BTN1:IsA("ImageButton") then
		self.Map1BTN1.MouseButton1Click:Connect(function()
			Client.TeleportToCampaign.Fire("Arena")
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
				Client.TeleportToCampaign.Fire("LACDUONG")
				warn("haha")
			end
		end)
	end

	-- if self.LacDuongBTN:IsA("GuiButton") then
	-- 	self.LacDuongBTN.MouseButton1Click:Connect(function()
	-- 		Client.TeleportToCampaign.Fire("LACDUONG")
	-- 	end)
	-- end

	-- if self.MAP1BTN:IsA("GuiButton") then
	-- 	self.MAP1BTN.MouseButton1Click:Connect(function()
	-- 		Client.TeleportToCampaign.Fire("MAP1")
	-- 	end)
	-- end

	return self
end

function Class:Destroy() end

return Class
