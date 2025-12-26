--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

export type Patrol = {
	__index: Patrol,
	new: () -> Patrol,
	Destroy: (self: Patrol) -> (),
}
local Class: Patrol = {} :: Patrol
Class.__index = Class

function Class.new(): Patrol
	local self: Patrol = setmetatable({} :: any, Class)
	return self
end

function Class:Destroy() end

return Class
