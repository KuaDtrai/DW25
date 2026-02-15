--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

export type First = {
	__index: First,
	new: () -> First,
	Destroy: (self: First) -> (),
}
local Class: First = {} :: First
Class.__index = Class

function Class.new(): First
	local self: First = setmetatable({} :: any, Class)
	return self
end

function Class:Destroy() end

return Class
