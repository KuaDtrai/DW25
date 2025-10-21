--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
warn(Player)
local Client = require(ReplicatedStorage.Shared.Network.Client)
local CONSTANTS = require(ReplicatedStorage.Shared.Libraries.CONSTANTS)
local Utilities = require(ReplicatedStorage.Shared.Modules.Utilities)

export type LobbyUI = {
	__index: LobbyUI,
	new: () -> LobbyUI,
	Destroy: (self: LobbyUI) -> (),
}
local Class: LobbyUI = {} :: LobbyUI
Class.__index = Class

function Class.new(): LobbyUI
	local self: LobbyUI = setmetatable({} :: any, Class)

	self.PlayerGui = Player:WaitForChild("PlayerGui")
	-- self.ScreenGui = self.PlayerGui:WaitForChild("ScreenGui")

	self.CampaignList = self.PlayerGui:WaitForChild("CampaignList") :: ScreenGui
	self.MainUI = self.PlayerGui:WaitForChild("MainUI") :: ScreenGui
	self.ArenaList = self.PlayerGui:WaitForChild("ArenaList") :: ScreenGui

	--MainUI
	self.MainUIFrame = self.MainUI:WaitForChild("MainUI") :: Frame
	self.BTN_Campaign = self.MainUIFrame:WaitForChild("BTN_Campaign") :: ImageButton
	self.BTN_Arena = self.MainUIFrame:WaitForChild("BTN_Arena") :: ImageButton

	--Campaign UI
	self.CampaignFrame = self.CampaignList:WaitForChild("Select-Campaign") :: Frame
	self.CloseBTN = self.CampaignFrame:WaitForChild("BTN_Close") :: ImageButton
	self.Map1BTN = self.CampaignFrame:WaitForChild("BTN_Map1") :: ImageButton
	self.Map2BTN = self.CampaignFrame:WaitForChild("BTN_Map2") :: ImageButton
	self.Map3BTN = self.CampaignFrame:WaitForChild("BTN_Map3") :: ImageButton

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

	--Campaign UI features
	if self.CloseBTN:IsA("ImageButton") then
		self.CloseBTN.MouseButton1Click:Connect(function()
			self.CampaignList.Enabled = false
		end)
	end
	if self.Map1BTN:IsA("ImageButton") then
		self.Map1BTN.MouseButton1Click:Connect(function()
			Utilities.ShowLoadingUI(Player)
			Client.TeleportToCampaign.Fire("MAP1")
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
			Utilities.ShowLoadingUI(Player)
			Client.MatchMaking.Fire()
		end)
	end
	return self
end

function Class:Destroy() end

return Class
