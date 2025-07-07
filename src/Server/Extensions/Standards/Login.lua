--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Openday = require(ReplicatedStorage.Shared.Openday)
export type Extension = {
	_PreSetup: (self: Extension, system: Openday.System) -> (),
	_PreStart: (self: Extension, system: Openday.System) -> (),
}

local Login: Extension = {} :: Extension

function Login:_PreSetup(system: Openday.System)
	if type(system.PlayerAdded) == "function" then
		Openday._PlayerManager.AddPlayerAddedCallback(function(player: Player)
			system.PlayerAdded(player)
		end)

		for _, player in ipairs(Players:GetPlayers()) do
			task.spawn(function()
				system.PlayerAdded(player)
				return
			end)
		end
	end

	if type(system.PlayerRemoving) == "function" then
		Openday._PlayerManager.AddPlayerRemovingCallback(function(player: Player)
			system.PlayerRemoving(player)
		end)
	end
end

function Login:_PreStart(system: Openday.System) end

return Login
