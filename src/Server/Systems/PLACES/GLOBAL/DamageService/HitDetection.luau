--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

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
			if not otherPart.Parent:FindFirstChildOfClass("Humanoid") or otherPart.Name ~= "HumanoidRootPart" then
				return
			end
			warn("Touched", otherPart)
			local character = otherPart.Parent

			self:ApplyDamage(character:FindFirstChildOfClass("Humanoid"))
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
