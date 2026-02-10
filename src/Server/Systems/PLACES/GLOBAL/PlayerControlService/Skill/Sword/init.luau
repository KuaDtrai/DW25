--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Sword_1 = require(script.Parent.Sword.Sword_1)
local Sword_2 = require(script.Parent.Sword.Sword_2)
local Sword_3 = require(script.Parent.Sword.Sword_3)
local Sword_4 = require(script.Parent.Sword.Sword_4)
local Server = require(ReplicatedStorage.Shared.Network.Server)

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
		task.delay(0.35, function()
			Server.CancelLockControl.Fire(Players:GetPlayerFromCharacter(character))
		end)
	elseif ComboIndex == 1 then
		self.Sword_2:play(character)
		task.delay(0.55, function()
			Server.CancelLockControl.Fire(Players:GetPlayerFromCharacter(character))
		end)
	elseif ComboIndex == 2 then
		self.Sword_3:play(character)
		task.delay(0.45, function()
			Server.CancelLockControl.Fire(Players:GetPlayerFromCharacter(character))
		end)
	elseif ComboIndex == 3 then
		self.Sword_4:play(character)
		task.delay(0.95, function()
			Server.CancelLockControl.Fire(Players:GetPlayerFromCharacter(character))
		end)
	end
end

function Class:Destroy() end

return Class
