--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EquipModule = require(script.EquipModule)

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
	self.EquipModule = EquipModule.new()
end

function init:_Start()
	self.EquipModule:Start()
end

return init
