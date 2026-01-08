--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

export type Idle = {
	__index: Idle,
	new: () -> Idle,
	Destroy: (self: Idle) -> (),
}
local Class: Idle = {} :: Idle
Class.__index = Class

function Class.new(): Idle
	local self: Idle = setmetatable({} :: any, Class)
	return self
end

function Class:Destroy() end

return Class
