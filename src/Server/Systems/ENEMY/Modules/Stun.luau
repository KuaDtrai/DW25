--!strict
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")

export type Stun = {
	__index: Stun,
	new: (npcModel: Model) -> Stun,
	Destroy: (self: Stun) -> (),
}

local Class: Stun = {} :: Stun
Class.__index = Class

local STUN_TIME = 0.5
local KNOCKBACK_DISTANCE = 8

function Class.new(npcModel: Model): Stun
	local self: Stun = setmetatable({}, Class)

	local humanoid = npcModel:FindFirstChildOfClass("Humanoid")
	local root = npcModel:FindFirstChild("HumanoidRootPart")

	if not humanoid or not root then
		return self
	end

	local stunned = false
	local oldWalkSpeed = humanoid.WalkSpeed
	local oldJumpPower = humanoid.JumpPower

	local function onTouched(hit: BasePart)
		if stunned then
			return
		end

		if not CollectionService:HasTag(hit, "STUN_HITBOX") then
			return
		end

		stunned = true

		-- Disable movement
		oldWalkSpeed = humanoid.WalkSpeed
		oldJumpPower = humanoid.JumpPower
		humanoid.WalkSpeed = 0
		humanoid.JumpPower = 0

		-- Direction knockback (ngược lại hitbox)
		local direction = (root.Position - hit.Position)
		if direction.Magnitude > 0 then
			direction = direction.Unit
		end

		local targetCFrame = CFrame.new(root.Position + direction * KNOCKBACK_DISTANCE)
			* CFrame.Angles(0, root.Orientation.Y * math.pi / 180, 0)

		local tween = TweenService:Create(
			root,
			TweenInfo.new(STUN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ CFrame = targetCFrame }
		)

		tween:Play()

		task.delay(STUN_TIME, function()
			if humanoid.Parent then
				humanoid.WalkSpeed = oldWalkSpeed
				humanoid.JumpPower = oldJumpPower
			end
			stunned = false
		end)
	end

	-- Connect tất cả STUN_HITBOX hiện có
	for _, hitbox in ipairs(CollectionService:GetTagged("STUN_HITBOX")) do
		if hitbox:IsA("BasePart") then
			root.Touched:Connect(onTouched)
			break
		end
	end

	-- Khi có hitbox mới
	CollectionService:GetInstanceAddedSignal("STUN_HITBOX"):Connect(function()
		root.Touched:Connect(onTouched)
	end)

	return self
end

function Class:Destroy()
	-- nếu sau này cần cleanup connection
end

return Class
