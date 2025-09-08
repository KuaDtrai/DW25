--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CONSTANTS = require(ReplicatedStorage.Shared.Libraries.CONSTANTS)

local Openday = require(ReplicatedStorage.Shared.Openday)

export type System = {
	_Extensions: { Openday.Extension },
	_Start: (self: System) -> (),
	_Setup: (self: System) -> (),
}

local init = {
	_Extensions = {},
} :: System

function init:_Setup()
	if game.PlaceId ~= CONSTANTS.MAP1_ID then
		script:Destroy()
		return
	end
end

function init:_Start() end

return init
