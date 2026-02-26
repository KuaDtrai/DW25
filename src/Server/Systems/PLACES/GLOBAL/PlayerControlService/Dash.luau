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
	warn(character)
	if character and character:FindFirstChild("Humanoid") and character:FindFirstChild("HumanoidRootPart") then
		character:SetAttribute("Dashing", true)

		local humanoid = character.Humanoid
		local humanoidRootPart = character.HumanoidRootPart
		local moveDirection = humanoid.MoveDirection
		if moveDirection.Magnitude == 0 then
			moveDirection = humanoidRootPart.CFrame.LookVector
		end

		local dashSpeed = 75 -- Tốc độ lướt (có thể điều chỉnh)
		local dashDuration = 0.3 -- Thời gian lướt (giây)
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = Vector3.new(math.huge, 0, math.huge)
		bodyVelocity.Velocity = moveDirection * dashSpeed
		bodyVelocity.Parent = humanoidRootPart

		game.Debris:AddItem(bodyVelocity, dashDuration)

		task.delay(dashDuration, function()
			character:SetAttribute("Dashing", false)
		end)
	end
end

function Class:Destroy() end

return Class
