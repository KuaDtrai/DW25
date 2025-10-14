--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CONSTANTS = require(ReplicatedStorage.Shared.Libraries.CONSTANTS)

local Openday = require(ReplicatedStorage.Shared.Openday)
local LobbyUI = require(script.LobbyUI)

export type System = {
	_Extensions: { Openday.Extension },
	_Start: (self: System) -> (),
	_Setup: (self: System) -> (),
}

local init = {
	_Extensions = {},
} :: System

function init:_Setup()
	if game.PlaceId ~= CONSTANTS.LOBBY_ID then
		script:Destroy()
		return
	end
	self.LobbyUI = LobbyUI.new()
end

function init:_Start() end

return init
