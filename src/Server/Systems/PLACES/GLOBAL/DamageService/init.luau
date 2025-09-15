--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HitDetection = require(script.HitDetection)
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
	self.HitDetection = HitDetection.new()
	warn(self)
end

function init:_Start() end

return init
