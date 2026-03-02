--!strict
local SpawnHitbox = require(script.Parent.Parent.SpawnHitbox)

local AttackAnimUtil = require(script.Parent.Parent.AttackAnimationUtil)

local Anim = "rbxassetid://138082426536940"

local ATTACK_TIME = 0.4
local FREEZE_TIME = 0.5

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
	warn("Lance 1 Attack")

	AttackAnimUtil.playFixedTime(character, Anim, ATTACK_TIME, FREEZE_TIME)

	SpawnHitbox:createHitbox(character, ATTACK_TIME, Vector3.new(10, 3, 5))

	task.delay(ATTACK_TIME, function()
		character:SetAttribute("ComboIndex", 1)
		character:SetAttribute("IsAttacking", false)
	end)
end

return Class
