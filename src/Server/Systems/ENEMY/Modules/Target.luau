--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

export type Target = {
	__index: Target,
	new: () -> Target,
	Destroy: (self: Target) -> (),
}
local Class: Target = {} :: Target
Class.__index = Class

function Class.new(): Target
	local self: Target = setmetatable({} :: any, Class)
	return self
end

function Class:Destroy() end

return Class
