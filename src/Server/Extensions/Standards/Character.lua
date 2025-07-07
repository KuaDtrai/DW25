--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Openday = require(ReplicatedStorage.Shared.Openday)
export type Extension = {
	_PreSetup: (self: Extension, system: Openday.System) -> (),
	_PreStart: (self: Extension, system: Openday.System) -> (),
}

local Login: Extension = {} :: Extension

function Login:_PreSetup(system: Openday.System) end

function Login:_PreStart(system: Openday.System)
	if type(system.CharacterAdded) == "function" then
		Openday._PlayerManager.AddCharacterAddedCallback(function(player: Player, character: Model)
			system.CharacterAdded(player, character)
		end)
	end

	if type(system.CharacterRemoving) == "function" then
		Openday._PlayerManager.AddCharacterRemovingCallback(function(player: Player, character: Model)
			system.CharacterRemoving(player, character)
		end)
	end
end

return Login
