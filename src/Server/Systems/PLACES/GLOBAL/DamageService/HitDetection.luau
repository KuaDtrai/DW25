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

		-- hitbox.Touched:Connect(function(otherPart)
		-- 	local hitHumanoid = otherPart.Parent and otherPart.Parent:FindFirstChildOfClass("Humanoid")
		-- 	if not hitHumanoid or otherPart.Name ~= "HumanoidRootPart" then
		-- 		return
		-- 	end

		-- 	local hitCharacter = otherPart.Parent
		-- 	local hitPlayer = Players:GetPlayerFromCharacter(hitCharacter)

		-- 	-- 🧠 Kiểm tra chủ sở hữu
		-- 	local ownerValue = hitbox:FindFirstChild("Owner")
		-- 	local ownerPlayer = ownerValue and ownerValue.Value

		-- 	-- ❌ Bỏ qua nếu hit chính chủ
		-- 	if ownerPlayer and hitPlayer == ownerPlayer then
		-- 		-- print("Bỏ qua va chạm với chủ sở hữu:", ownerPlayer.Name)
		-- 		return
		-- 	end

		-- 	warn("✅ Touched:", hitCharacter.Name, "bởi hitbox của", ownerPlayer and ownerPlayer.Name)
		-- 	self:ApplyDamage(hitHumanoid)
		-- end)

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
				-- NPC_HITBOX không thể gây damage lên NPC
				-- warn("NPC_HITBOX không thể đánh NPC:", hitCharacter.Name)
				return
			end

			-- Nếu tới đây là hợp lệ -> gây damage
			-- warn("Gây damage lên", hitCharacter.Name, "bởi hitbox của", ownerPlayer and ownerPlayer.Name)
			self:ApplyDamage(hitHumanoid)
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
