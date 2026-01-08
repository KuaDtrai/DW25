--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Spawn = require(script.Parent.Modules.Spawn)
local Patrol = require(script.Parent.Modules.Patrol)
local Target = require(script.Parent.Modules.Target)
local Offensive = require(script.Parent.Modules.Offensive)
local Death = require(script.Parent.Modules.Death)
local Animation = require(script.Parent.Modules.Animation)

local CreepModel = ReplicatedStorage.Shared.Assets.NPC:WaitForChild("Creep")

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
	self.spawnSystem = Spawn.new()

	self.patrolSystem = Patrol.new()
	self.offensiveSystem = Offensive.new()

	self.Creeps = {}

	CollectionService:GetInstanceAddedSignal("Creep"):Connect(function(instance)
		if not instance:IsA("Model") then
			return
		end
		Death.new(instance)
		Target.new(instance)
		Animation.new(instance)
		instance:GetAttributeChangedSignal("State"):Connect(function()
			init.update(instance)
		end)
		table.insert(self.Creeps, instance)
	end)

	CollectionService:GetInstanceRemovedSignal("Creep"):Connect(function(instance)
		for index, value in ipairs(self.Creeps) do
			if value == instance then
				table.remove(self.Creeps, index)
				break
			end
		end
	end)
end

function init.update(instance: Model)
	local state = instance:GetAttribute("State")
	if state == "None" or state == "Idle" then
		init.patrolSystem:DoPatrol(instance)
	elseif state == "Sight" or state == "Approach" or state == "Attack" then
		init.offensiveSystem:DoOffensive(instance)
	else
		-- None state
	end
end

function init:_Start()
	-- Spawn model Creep
	self.spawnSystem:Spawn("CREEP_SPAWNER", CreepModel)
end

return init
