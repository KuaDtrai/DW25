--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

export type Skill1 = {
	__index: Skill1,
	new: () -> Skill1,
	Destroy: (self: Skill1) -> (),
}
local Class: Skill1 = {} :: Skill1
Class.__index = Class

function Class.new(): Skill1
	local self: Skill1 = setmetatable({} :: any, Class)
	return self
end

function Class:Cast()
	print("Skill1 Casted")
end

function Class:Destroy() end

return Class
