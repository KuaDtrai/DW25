--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

local Openday = require(ReplicatedStorage.Shared.Openday)
local Server = require(ReplicatedStorage.Shared.Network.Server)
local CONSTANTS = require(ReplicatedStorage.Shared.Libraries.CONSTANTS)

export type System = {
	_Extensions: { Openday.Extension },
	_Start: (self: System) -> (),
	_Setup: (self: System) -> (),
}

local init = {
	_Extensions = {},
} :: System

function init:_Setup() end

function init:_Start()
	--!strict
	-- local Lighting = game:GetService("Lighting")
	-- local Players = game:GetService("Players")
	-- local RunService = game:GetService("RunService")

	-- -- Hàm lấy thời gian Việt Nam (UTC+7)
	-- local function getVietnamTime()
	-- 	local dt = os.date("!*t") -- UTC time as table
	-- 	dt.hour = dt.hour + 7
	-- 	if dt.hour >= 24 then
	-- 		dt.hour = dt.hour - 24
	-- 		dt.day = dt.day + 1
	-- 		-- Cập nhật wday nếu cần (không bắt buộc cho giờ)
	-- 		dt.wday = dt.wday + 1
	-- 		if dt.wday > 7 then
	-- 			dt.wday = 1
	-- 		end
	-- 	end
	-- 	return os.time(dt)
	-- end

	-- -- Set thời gian game ban đầu dựa vào thời gian thực Việt Nam
	-- local vietnamTime = getVietnamTime()
	-- local gameTime = vietnamTime % (24 * 60 * 60) / 3600 -- Giờ thập phân (0-24)
	-- Lighting.ClockTime = gameTime

	-- -- Cập nhật mỗi giây để sync với real time
	-- local connection
	-- connection = RunService.Heartbeat:Connect(function()
	-- 	local vietnamTime = getVietnamTime()
	-- 	local newGameTime = vietnamTime % (24 * 60 * 60) / 3600
	-- 	Lighting.ClockTime = newGameTime
	-- end)

	-- Cleanup khi cần (ví dụ khi player leave, nhưng ở đây là server script thì optional)
	-- Players.PlayerRemoving:Connect(function()
	-- 	connection:Disconnect()
	-- end)

	Server.TeleportToCampaign.SetCallback(function(player: Player, campaign: string)
		warn("Teleport to campaign", player, campaign)
		local tele_to = CONSTANTS.LOBBY_ID
		if campaign == "LACDUONG" then
			tele_to = CONSTANTS.LACDUONG_ID
		elseif campaign == "LOBBY" then
			tele_to = CONSTANTS.LOBBY_ID
		elseif campaign == "MAP1" then
			tele_to = CONSTANTS.MAP1_ID
		elseif campaign == "MAP2" then
			tele_to = CONSTANTS.MAP2_ID
		elseif campaign == "MAP3" then
			tele_to = CONSTANTS.MAP3_ID
		end
		warn(campaign)
		TeleportService:Teleport(tele_to, player, "Teleport")
	end)

	Server.MatchMaking.SetCallback(function(player, Value)
		warn("Match making", player, Value)
		TeleportService:Teleport(CONSTANTS.ARENA_ID, player)
	end)
end

return init
