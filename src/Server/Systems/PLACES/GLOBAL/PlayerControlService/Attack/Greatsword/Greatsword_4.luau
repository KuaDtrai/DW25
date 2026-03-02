--!strict
local SpawnHitbox = require(script.Parent.Parent.SpawnHitbox)

local AttackAnimUtil = require(script.Parent.Parent.AttackAnimationUtil)

local Anim = "rbxassetid://133866253844008"

local ATTACK_TIME = 1
local FREEZE_TIME = 0.5
local DELAY = 0.5

export type First = {
	__index: First,
	new: () -> First,
	play: (self: First, character: Model) -> (),
	createHitbox: (self: First, character: Model, time: number) -> (),
}

local Class: First = {} :: First
Class.__index = Class

function Class.new(): First
	return setmetatable(
		{
			HitboxVisible = false,
		} :: any,
		Class
	)
end

function Class:play(character: Model)
	if character:GetAttribute("IsAttacking") then
		return
	end

	character:SetAttribute("IsAttacking", true)
	warn("Lance 4 Attack")

	AttackAnimUtil.playFixedTime(character, Anim, ATTACK_TIME, FREEZE_TIME)

	SpawnHitbox:createHitbox(character, 0.4, Vector3.new(5, 3, 10))

	task.delay(0.7, function()
		SpawnHitbox:createHitbox(character, 0.4, Vector3.new(5, 3, 10))
	end)

	task.delay(ATTACK_TIME, function()
		character:SetAttribute("ComboIndex", 4)
		character:SetAttribute("IsAttacking", false)

		task.delay(DELAY, function()
			character:SetAttribute("ComboIndex", 0)
		end)
	end)
end

return Class
