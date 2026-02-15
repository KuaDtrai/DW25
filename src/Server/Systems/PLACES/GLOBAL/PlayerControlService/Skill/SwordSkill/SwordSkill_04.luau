--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

export type SwordSkill_04 = {
	__index: SwordSkill_04,
	new: () -> SwordSkill_04,
	Destroy: (self: SwordSkill_04) -> (),
}
local Class: SwordSkill_04 = {} :: SwordSkill_04
Class.__index = Class

function Class.new(): SwordSkill_04
	local self: SwordSkill_04 = setmetatable({} :: any, Class)
	return self
end

function Class:Destroy() end

return Class
