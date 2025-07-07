--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Openday = require(ReplicatedStorage.Shared.Openday)
export type Extension = {
	_PreSetup: (self: Extension, system: Openday.System) -> (),
	_PreStart: (self: Extension, system: Openday.System) -> (),
}

local Game: Extension = {} :: Extension

local Callbacks: { () -> () } = {}

game:BindToClose(function()
	for _, callback: () -> () in Callbacks do
		callback()
	end
end)

function Game:_PreSetup(system: Openday.System)
	if type(system.GameClosing) == "function" then
		table.insert(Callbacks, function()
			system.GameClosing()
		end)
	end
end

function Game:_PreStart(system: Openday.System) end

return Game
