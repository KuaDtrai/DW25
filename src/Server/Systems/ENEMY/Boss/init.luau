--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Spawn = require(script.Parent.Modules.Spawn)
local Patrol = require(script.Parent.Modules.Patrol)
local Target = require(script.Parent.Modules.Target)
local Offensive = require(script.Parent.Modules.Offensive)
local Death = require(script.Parent.Modules.Death)
local Animation = require(script.Parent.Modules.Animation)
local WeaponDrop = require(script.Parent.Modules.WeaponDrop)

local BossModel = ReplicatedStorage.Shared.Assets.NPC:WaitForChild("Boss")

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

	self.Bosses = {}

	CollectionService:GetInstanceAddedSignal("Boss"):Connect(function(instance)
		if not instance:IsA("Model") then
			return
		end
		Death.new(instance)
		Target.new(instance)
		Animation.new(instance)
		WeaponDrop.new(instance)
		instance:GetAttributeChangedSignal("State"):Connect(function()
			init.update(instance)
		end)
		table.insert(self.Bosses, instance)
	end)

	CollectionService:GetInstanceRemovedSignal("Boss"):Connect(function(instance)
		for index, value in ipairs(self.Bosses) do
			if value == instance then
				table.remove(self.Bosses, index)
				break
			end
		end
	end)
end

function init:_Start()
	self.spawnSystem:Spawn("BOSS_SPAWNER", BossModel)
end

return init
