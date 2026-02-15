--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

export type SwordSkill_01 = {
	__index: SwordSkill_01,
	new: () -> SwordSkill_01,
	Destroy: (self: SwordSkill_01) -> (),
}
local Class: SwordSkill_01 = {} :: SwordSkill_01
Class.__index = Class

function Class.new(): SwordSkill_01
	local self: SwordSkill_01 = setmetatable({} :: any, Class)
	return self
end

function Class:Destroy() end

return Class
