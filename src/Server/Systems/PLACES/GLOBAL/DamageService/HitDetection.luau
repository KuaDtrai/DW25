--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local Server = require(ReplicatedStorage.Shared.Network.Server)

export type HitDetection = {
	__index: HitDetection,
	new: () -> HitDetection,
	Destroy: (self: HitDetection) -> (),
}

local Class: HitDetection = {} :: HitDetection
Class.__index = Class

-- Cấu hình
local DAMAGE = 20

function Class.new(): HitDetection
	local self: HitDetection = setmetatable({} :: any, Class)

	CollectionService:GetInstanceAddedSignal("HITBOX"):Connect(function(hitbox: BasePart)
		warn("New hitbox added", hitbox)
		hitbox.Touched:Connect(function(otherPart)
			local hitHumanoid = otherPart.Parent and otherPart.Parent:FindFirstChildOfClass("Humanoid")
			if not hitHumanoid or otherPart.Name ~= "HumanoidRootPart" then
				return
			end

			local hitCharacter = otherPart.Parent
			local hitPlayer = Players:GetPlayerFromCharacter(hitCharacter)

			-- 🧠 Chủ sở hữu
			local ownerValue = hitbox:FindFirstChild("Owner")
			local ownerPlayer = ownerValue and ownerValue.Value

			-- ❌ Không damage chính chủ
			if ownerPlayer and hitPlayer == ownerPlayer then
				return
			end

			-- 🔍 NEW: Kiểm tra nếu hitbox là NPC_HITBOX thì không damage NPC khác
			local isNPCHitbox = CollectionService:HasTag(hitbox, "NPC_HITBOX")
			local isNPCTarget = CollectionService:HasTag(hitCharacter, "ENEMY")

			if isNPCHitbox and isNPCTarget then
				return
			end

			self:ApplyDamage(hitHumanoid)
			Server.VFX_Signal.FireAll("HIT", otherPart.CFrame)
		end)
	end)

	return self
end

function Class:getAllHitboxes()
	self.Hitbox = CollectionService:GetTagged("HITBOX")
	warn(self.Hitbox)
	task.spawn(function()
		CollectionService:GetInstanceAddedSignal("HITBOX"):Connect(function(hitbox)
			table.insert(self.Hitbox, hitbox)
			warn("New hitbox added", hitbox)
		end)
	end)
end

function Class:ApplyDamage(humanoid: Humanoid)
	if humanoid and humanoid.Health > 0 then
		humanoid:TakeDamage(DAMAGE)
	end
end

function Class:Destroy() end

return Class
