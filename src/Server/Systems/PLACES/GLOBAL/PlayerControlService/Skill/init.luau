--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Skill1 = require(script.Skill1)
local Skill2 = require(script.Skill2)

export type init = {
	__index: init,
	new: () -> init,
	Destroy: (self: init) -> (),
}
local Class: init = {} :: init
Class.__index = Class

function Class.new(): init
	local self: init = setmetatable({} :: any, Class)
	self.Skill1 = Skill1.new()
	self.Skill2 = Skill2.new()
	return self
end

function Class:onSkill()
	self.Skill1:Cast()
	self.Skill2:Cast()
end

function Class:Destroy() end

return Class
