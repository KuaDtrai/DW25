--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local SpawnModule = require(script.Parent.Modules.Spawn)
local PatrolModule = require(script.Parent.Modules.Patrol)
local TargetModule = require(script.Parent.Modules.Target)
local AttackModule = require(script.Parent.Modules.Attack)

local CreepModel = ReplicatedStorage.:WaitForChild("Creep")

local Openday = require(ReplicatedStorage.Shared.Openday)

export type System = {
	_Extensions: { Openday.Extension },
	_Start: (self: System) -> (),
	_Setup: (self: System) -> (),
}

local init = {
	_Extensions = {},
} :: System

function init:_Setup() end

function init:_Start() end

return init
