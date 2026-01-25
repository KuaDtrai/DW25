--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Shared.Libraries.CONSTANTS)

export type Dash = {
	__index: Dash,
	new: () -> Dash,
	onDash: (self: Dash, player: Player) -> (),
	Destroy: (self: Dash) -> (),
}
local Class: Dash = {} :: Dash
Class.__index = Class

function Class.new(): Dash
	local self: Dash = setmetatable({} :: any, Class)
	return self
end

function Class:onDash(player: Player)
	local character = player.Character
	if character and character:FindFirstChild("Humanoid") and character:FindFirstChild("HumanoidRootPart") then
		character:SetAttribute("IsDashing", true)

		local humanoid = character.Humanoid
		local humanoidRootPart = character.HumanoidRootPart
		local moveDirection = humanoid.MoveDirection
		if moveDirection.Magnitude == 0 then
			moveDirection = humanoidRootPart.CFrame.LookVector
		end

		-- local animationId = CONSTANTS:getAnimation("DASH")
		-- if animationId == "" then
		-- 	warn("No AnimationId found for DASH")
		-- 	return
		-- end

		-- Áp dụng lực lướt
		local dashSpeed = 75 -- Tốc độ lướt (có thể điều chỉnh)
		local dashDuration = 0.3 -- Thời gian lướt (giây)
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = Vector3.new(math.huge, 0, math.huge)
		bodyVelocity.Velocity = moveDirection * dashSpeed
		bodyVelocity.Parent = humanoidRootPart

		-- Xóa lực sau khi lướt xong
		game.Debris:AddItem(bodyVelocity, dashDuration)

		-- Tải và chạy animation
		-- local animation = Instance.new("Animation")
		-- animation.AnimationId = animationId
		-- local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
		-- local animationTrack = animator:LoadAnimation(animation)
		-- warn(animationTrack)
		-- animationTrack:Play()
		-- end
	end
end

function Class:Destroy() end

return Class
