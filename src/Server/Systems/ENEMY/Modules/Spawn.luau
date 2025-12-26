--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

export type Spawn = {
	__index: Spawn,
	new: () -> Spawn,
	Destroy: (self: Spawn) -> (),
}
local Class: Spawn = {} :: Spawn
Class.__index = Class

function Class.new(): Spawn
	local self: Spawn = setmetatable({} :: any, Class)
	return self
end

function Class:Destroy() end

return Class
