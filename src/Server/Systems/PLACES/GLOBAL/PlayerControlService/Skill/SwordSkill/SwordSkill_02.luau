--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

export type SwordSkill_02 = {
	__index: SwordSkill_02,
	new: () -> SwordSkill_02,
	Destroy: (self: SwordSkill_02) -> (),
}
local Class: SwordSkill_02 = {} :: SwordSkill_02
Class.__index = Class

function Class.new(): SwordSkill_02
	local self: SwordSkill_02 = setmetatable({} :: any, Class)
	return self
end

function Class:Destroy() end

return Class
