--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Server = require(ReplicatedStorage.Shared.Network.Server)

local Greatsword_1 = require(script.Greatsword_1)
local Greatsword_2 = require(script.Greatsword_2)
local Greatsword_3 = require(script.Greatsword_3)
local Greatsword_4 = require(script.Greatsword_4)

export type init = {
	__index: init,
	new: () -> init,
	Destroy: (self: init) -> (),
}
local Class: init = {} :: init
Class.__index = Class

function Class.new(): init
	local self: init = setmetatable({} :: any, Class)

	self.Greatsword_1 = Greatsword_1.new()
	self.Greatsword_2 = Greatsword_2.new()
	self.Greatsword_3 = Greatsword_3.new()
	self.Greatsword_4 = Greatsword_4.new()

	return self
end

function Class:Cast(character)
	if character:GetAttribute("IsAttacking") then
		return
	end

	local ComboIndex = character:GetAttribute("ComboIndex")
	if ComboIndex == 0 then
		self.Greatsword_1:play(character)
	elseif ComboIndex == 1 then
		self.Greatsword_2:play(character)
	elseif ComboIndex == 2 then
		self.Greatsword_3:play(character)
	elseif ComboIndex == 3 then
		self.Greatsword_4:play(character)
	end

	Server.VFX_Signal.FireAll("GREATSWORD_" .. ComboIndex + 1, character.PrimaryPart.CFrame)
end

function Class:Destroy() end

return Class
