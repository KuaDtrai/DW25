--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local NPCFolder = workspace:WaitForChild("NPCs")

export type Spawn = {
	__index: Spawn,
	new: () -> Spawn,
	Spawn: (self: Spawn, spawner: string, npcModel: Model) -> (),
	Destroy: (self: Spawn) -> (),
}

type SpawnPointNPCMap = {
	[Instance]: Model?,
}

local Class: Spawn = {} :: Spawn
Class.__index = Class

local PhysicsService = game:GetService("PhysicsService")

local NPC_GROUP = "NPC"

-- Tạo group nếu chưa có
pcall(function()
	PhysicsService:CreateCollisionGroup(NPC_GROUP)
end)

-- NPC không collide với NPC
PhysicsService:CollisionGroupSetCollidable(NPC_GROUP, NPC_GROUP, false)

function Class.new(): Spawn
	local self = setmetatable({}, Class) :: any
	self._spawnPointNPCs = {} :: SpawnPointNPCMap
	return self
end

local function setNPCNoCollision(model: Model)
	for _, desc in ipairs(model:GetDescendants()) do
		if desc:IsA("BasePart") then
			PhysicsService:SetPartCollisionGroup(desc, "NPC")
		end
	end
end

function Class:Spawn(spawner: string, npcModel: Model)
	local spawnPoints = CollectionService:GetTagged(spawner)
	if #spawnPoints == 0 then
		warn("No spawn point found for tag: " .. spawner)
		return
	end

	for _, spawnPoint in spawnPoints do
		-- nếu spawn point này đang có NPC thì bỏ qua
		spawnPoint.Transparency = 1
		if self._spawnPointNPCs[spawnPoint] then
			continue
		end

		local model = npcModel:Clone()
		model:PivotTo(spawnPoint.CFrame)
		model.Parent = NPCFolder

		setNPCNoCollision(model)

		local spawnerValue = Instance.new("ObjectValue")
		spawnerValue.Name = "Spawner"
		spawnerValue.Value = spawnPoint
		spawnerValue.Parent = model

		CollectionService:AddTag(model, "Creep")
		self._spawnPointNPCs[spawnPoint] = model

		local humanoid = model:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.Died:Connect(function()
				self._spawnPointNPCs[spawnPoint] = nil

				task.delay(60, function()
					-- spawn lại đúng spawn point cũ
					if spawnPoint.Parent then
						self:Spawn(spawner, npcModel)
					end
				end)
			end)
		else
			warn("NPC model has no Humanoid:", model.Name)
		end
	end
end

function Class:Destroy()
	for _, npc in pairs(self._spawnPointNPCs) do
		if npc then
			npc:Destroy()
		end
	end
	self._spawnPointNPCs = {}
end

return Class
