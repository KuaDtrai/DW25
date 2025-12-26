--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

export type Attack = {
	__index: Attack,
	new: () -> Attack,
	Destroy: (self: Attack) -> (),
}
local Class: Attack = {} :: Attack
Class.__index = Class

function Class.new(): Attack
	local self: Attack = setmetatable({} :: any, Class)
	return self
end

function Class.OnAttack() end

function Class:Destroy() end

return Class
