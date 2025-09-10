--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

export type Skill = {
	__index: Skill,
	new: () -> Skill,
	onSkill: (self: Skill, player: Player) -> (),
	Destroy: (self: Skill) -> (),
}
local Class: Skill = {} :: Skill
Class.__index = Class

function Class.new(): Skill
	local self: Skill = setmetatable({} :: any, Class)
	return self
end

function Class:onSkill(player: Player) end

function Class:Destroy() end

return Class
