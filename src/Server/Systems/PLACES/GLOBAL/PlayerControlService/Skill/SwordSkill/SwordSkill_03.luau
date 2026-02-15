--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

export type SwordSkill_03 = {
	__index: SwordSkill_03,
	new: () -> SwordSkill_03,
	Destroy: (self: SwordSkill_03) -> (),
}
local Class: SwordSkill_03 = {} :: SwordSkill_03
Class.__index = Class

function Class.new(): SwordSkill_03
	local self: SwordSkill_03 = setmetatable({} :: any, Class)
	return self
end

function Class:Destroy() end

return Class
