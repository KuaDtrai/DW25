--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Server = require(ReplicatedStorage.Shared.Network.Server)
local Sword_1 = require(script.Sword_1)
local Sword_2 = require(script.Sword_2)
local Sword_3 = require(script.Sword_3)
local Sword_4 = require(script.Sword_4)

export type init = {
	__index: init,
	new: () -> init,
	Destroy: (self: init) -> (),
}
local Class: init = {} :: init
Class.__index = Class

function Class.new(): init
	local self: init = setmetatable({} :: any, Class)

	self.Sword_1 = Sword_1.new()
	self.Sword_2 = Sword_2.new()
	self.Sword_3 = Sword_3.new()
	self.Sword_4 = Sword_4.new()

	return self
end

function Class:Cast(character)
	if character:GetAttribute("IsAttacking") then
		return
	end

	local ComboIndex = character:GetAttribute("ComboIndex")
	if ComboIndex == 0 then
		self.Sword_1:play(character)
	elseif ComboIndex == 1 then
		self.Sword_2:play(character)
	elseif ComboIndex == 2 then
		self.Sword_3:play(character)
	elseif ComboIndex == 3 then
		self.Sword_4:play(character)
	end

	Server.VFX_Signal.FireAll("SWORD_" .. ComboIndex + 1, character.PrimaryPart.CFrame)
end

function Class:Destroy() end

return Class
