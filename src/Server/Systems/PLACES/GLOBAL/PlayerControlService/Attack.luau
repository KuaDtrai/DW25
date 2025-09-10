--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local CONSTANTS = require(ReplicatedStorage.Shared.Libraries.CONSTANTS)

export type Attack = {
	__index: Attack,
	new: () -> Attack,
	onAttack: (self: Attack, player: Player) -> (),
	Destroy: (self: Attack) -> (),
}
local Class: Attack = {} :: Attack
Class.__index = Class

function Class.new(): Attack
	local self: Attack = setmetatable({} :: any, Class)
	return self
end

function Class:onAttack(Player)
	local character = Player.Character
	if not character then
		warn("No character found for player", Player)
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		warn("No Humanoid found for player", Player)
		return
	end

	local animationId = CONSTANTS:getAnimation("ATTACK")
	if animationId == "" then
		warn("No AnimationId found for ATTACK")
		return
	end
	local animation = Instance.new("Animation", humanoid)
	animation.AnimationId = animationId
	local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator")
	local animationTrack = animator:LoadAnimation(animation)
	animationTrack:Play()
end

function Class:Destroy() end

return Class
