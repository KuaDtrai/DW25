--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

export type Stun = {
	__index: Stun,
	new: () -> Stun,
	Destroy: (self: Stun) -> (),
}
local Class: Stun = {} :: Stun
Class.__index = Class

function Class.new(): Stun
	local self: Stun = setmetatable({} :: any, Class)
	return self
end

function Class:Destroy() end

return Class
