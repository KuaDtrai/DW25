--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Server = require(ReplicatedStorage.Shared.Network.Server)

local Lance_1 = require(script.Lance_1)
local Lance_2 = require(script.Lance_2)
local Lance_3 = require(script.Lance_3)
local Lance_4 = require(script.Lance_4)

export type init = {
	__index: init,
	new: () -> init,
	Destroy: (self: init) -> (),
}
local Class: init = {} :: init
Class.__index = Class

function Class.new(): init
	local self: init = setmetatable({} :: any, Class)

	self.Lance_1 = Lance_1.new()
	self.Lance_2 = Lance_2.new()
	self.Lance_3 = Lance_3.new()
	self.Lance_4 = Lance_4.new()

	return self
end

function Class:Cast(character)
	if character:GetAttribute("IsAttacking") then
		return
	end

	local ComboIndex = character:GetAttribute("ComboIndex")
	if ComboIndex == 0 then
		self.Lance_1:play(character)
	elseif ComboIndex == 1 then
		self.Lance_2:play(character)
	elseif ComboIndex == 2 then
		self.Lance_3:play(character)
	elseif ComboIndex == 3 then
		self.Lance_4:play(character)
	end

	Server.VFX_Signal.FireAll("LANCE_" .. ComboIndex + 1, character.PrimaryPart.CFrame)
end

function Class:Destroy() end

return Class
