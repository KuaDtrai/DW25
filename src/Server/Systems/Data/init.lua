--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Signal = require(ReplicatedStorage.Packages.Signal)
local ProfileService = require(script.ProfileService)
local Profiles = require(script.Profiles)
local Openday = require(ReplicatedStorage.Shared.Openday)

local ProfileStore: any = ProfileService.GetProfileStore(Profiles.VERSION, Profiles.Template)

export type Data = Profiles.Data
export type Profile = Profiles.Profile
export type Profiles = Profiles.Profiles

local function Get(player: Player): Profile?
	return Profiles.Profiles[player]
end

local function Save(player: Player, isClose: boolean)
	-- Grab the player's profile
	local profile: Profile? = Get(player)
	if not profile then
		return
	end

	-- If the server is closing
	if isClose then
		-- Grab the player's data
		local data = profile.Data
		if not data then
			return
		end

		-- Save soft shutdown data
		-- local SoftShutdownService = Openday.GetService("SoftShutdownService")
		-- SoftShutdownService:SaveShutdownData(player)
	else
		-- Release the profile
		profile:Release()
	end
end

local function Load(player: Player)
	local profile = ProfileStore:LoadProfileAsync("UserId_" .. player.UserId)
	player:SetAttribute("Joined", workspace:GetServerTimeNow())

	if profile ~= nil then
		profile:AddUserId(player.UserId) -- GDPR compliance

		-- The profile could've been loaded on another Roblox server
		profile:ListenToRelease(function()
			Profiles.Profiles[player] = nil
			player:Kick("There is a problem with your data. You have been kicked to prevent data corruption.")
		end)

		if player:IsDescendantOf(Players) then -- Profile has been successfully loaded
			profile:Reconcile(player, profile)
			Profiles.Profiles[player] = profile
		else -- Player left before the profile loaded
			profile:Release()
		end
	else -- Profile couldn't be loaded
		player:Kick("Your data couldn't be loaded.")
		return
	end

	print("🦀| " .. player.Name .. "'s Data loaded!")
	return Get(player)
end

export type System = {
	_Extensions: { Openday.Extension },
	_Start: (self: System) -> (),
	_Setup: (self: System) -> (),
	Get: (self: System, player: Player) -> Data?,

	PlayerAdded: (player: Player) -> (),
	PlayerRemoving: (player: Player) -> (),

	OnDataLoaded: Signal.Signal<Player, Data>,

	GameClosing: () -> (),
}

local Data: System = {
	_Extensions = {},
} :: System

function Data:_Setup()
	self.OnDataLoaded = Signal()
end

function Data:_Start() end

function Data:Get(player: Player): Data?
	local profile = Get(player)
	if profile then
		return profile.Data
	end
	return
end

function Data.PlayerAdded(player: Player)
	local profile: Profile? = Load(player)
	if profile then
		Data.OnDataLoaded:Fire(player, profile.Data)
	end
end

function Data.PlayerRemoving(player: Player)
	-- Wait for the player to completely exit the server
	while player:IsDescendantOf(game) do
		player.AncestryChanged:Wait()
	end

	-- Save player's data & release their profile
	Save(player, false)
end

function Data.GameClosing()
	if RunService:IsStudio() then
		return
	end

	-- Save each player's data in close mode
	for _, player in ipairs(Players:GetPlayers()) do
		Save(player, true)
	end
end

return Data
