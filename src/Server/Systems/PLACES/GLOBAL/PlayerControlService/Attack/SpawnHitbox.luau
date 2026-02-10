--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")

local HitboxVisible = false

export type SpawnHitbox = {
	__index: SpawnHitbox,
	new: () -> SpawnHitbox,
	Destroy: (self: SpawnHitbox) -> (),
}
local Class: SpawnHitbox = {} :: SpawnHitbox
Class.__index = Class

function Class:createHitbox(character: Model, activeTime: number, size: Vector3, offset: number?)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end

	local part = Instance.new("Part")
	part.Name = "Hitbox_" .. HttpService:GenerateGUID(false)
	part.Size = size
	-- part.CFrame = hrp.CFrame * CFrame.new(0, 0, 15)
	part.Anchored = false -- ❌ tắt anchor
	part.CanCollide = false
	part.Massless = true

	if HitboxVisible then
		part.Transparency = 0.5
		part.Color = Color3.new(1, 0, 0)
	else
		part.Transparency = 1
	end

	part.Parent = workspace

	-- Motor6D weld
	local motor = Instance.new("Motor6D")
	motor.Name = "HitboxMotor"
	motor.Part0 = part
	motor.Part1 = hrp

	-- Giữ offset phía trước HRP
	motor.C0 = CFrame.new(0, 0, offset or 6)
	motor.C1 = CFrame.identity
	motor.Parent = hrp

	CollectionService:AddTag(part, "HITBOX")
	CollectionService:AddTag(part, "STUN_HITBOX")
	part:SetAttribute("Damage", character:GetAttribute("Damage"))

	local owner = Instance.new("ObjectValue")
	owner.Name = "Owner"
	owner.Value = Players:GetPlayerFromCharacter(character)
	owner.Parent = part

	Debris:AddItem(part, activeTime)
end

function Class:Destroy() end

return Class
