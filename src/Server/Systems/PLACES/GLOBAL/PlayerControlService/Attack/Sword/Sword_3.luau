--!strict
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")

local AttackAnimUtil = require(script.Parent.Parent.AttackAnimationUtil)

local Anim = "rbxassetid://76224405313005"

local ATTACK_TIME = 0.5
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
	warn("Sword 3 Attack")

	AttackAnimUtil.playFixedTime(character, Anim, ATTACK_TIME, FREEZE_TIME, 5)

	self:createHitbox(character, ATTACK_TIME)

	task.delay(ATTACK_TIME, function()
		character:SetAttribute("ComboIndex", 3)
		character:SetAttribute("IsAttacking", false)
	end)
end

function Class:createHitbox(character: Model, activeTime: number)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end

	local part = Instance.new("Part")
	part.Name = "Hitbox_" .. HttpService:GenerateGUID(false)
	part.Size = Vector3.new(10, 10, 10)
	part.CFrame = hrp.CFrame * CFrame.new(0, 0, -6)
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = self.HitboxVisible and 0 or 1
	part.Parent = workspace

	CollectionService:AddTag(part, "HITBOX")
	CollectionService:AddTag(part, "STUN_HITBOX")

	part:SetAttribute("Damage", character:GetAttribute("Damage"))

	local owner = Instance.new("ObjectValue")
	owner.Name = "Owner"
	owner.Value = Players:GetPlayerFromCharacter(character)
	owner.Parent = part

	Debris:AddItem(part, activeTime)
end

return Class
