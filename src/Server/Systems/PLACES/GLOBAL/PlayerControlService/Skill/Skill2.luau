--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

export type Skill2 = {
	__index: Skill2,
	new: () -> Skill2,
	Destroy: (self: Skill2) -> (),
}
local Class: Skill2 = {} :: Skill2
Class.__index = Class

function Class.new(): Skill2
	local self: Skill2 = setmetatable({} :: any, Class)
	return self
end

function Class:Cast()
	print("Skill2 Casted")
end

function Class:Destroy() end

return Class
