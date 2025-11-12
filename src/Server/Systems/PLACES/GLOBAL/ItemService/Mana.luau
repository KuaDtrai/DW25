--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

export type Mana = {
	__index: Mana,
	new: () -> Mana,
	Destroy: (self: Mana) -> (),
}
local Class: Mana = {} :: Mana
Class.__index = Class

function Class.new(): Mana
	local self: Mana = setmetatable({} :: any, Class)
	return self
end

function Class:Destroy() end

return Class
