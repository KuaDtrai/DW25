--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Client = require(ReplicatedStorage.Shared.Network.Client)

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
	self.LacDuongBTN = self.ScreenGui:WaitForChild("LacDuongThanh") :: TextButton
	self.MAP1BTN = self.ScreenGui:WaitForChild("Map1") :: TextButton

	if self.LacDuongBTN:IsA("GuiButton") then
		self.LacDuongBTN.MouseButton1Click:Connect(function()
			Client.TeleportToCampaign.Fire("LACDUONG")
		end)
	end

	if self.MAP1BTN:IsA("GuiButton") then
		self.MAP1BTN.MouseButton1Click:Connect(function()
			Client.TeleportToCampaign.Fire("MAP1")
		end)
	end

	return self
end

function Class:Destroy() end

return Class
