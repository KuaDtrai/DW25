--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Sword = require(script.Sword)
local Lance = require(script.Lance)
local Greatsword = require(script.Greatsword)

export type init = {
	__index: init,
	new: () -> init,
	Destroy: (self: init) -> (),
}
local Class: init = {} :: init
Class.__index = Class

function Class.new(): init
	local self: init = setmetatable({} :: any, Class)

	self.Sword = Sword.new()
	self.Lance = Lance.new()
	self.Greatsword = Greatsword.new()

	return self
end

function Class:onAttack(player: Player)
	local character = player.Character
	if not character then
		return
	end

	-- warn(player.Name .. " initiated an attack.")

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	local EquippedWeapon = character:GetAttribute("EquippedWeapon")
	if not EquippedWeapon then
		return
	end

	if EquippedWeapon == "SWORD" then
		warn("Sword Attack for ", character.Name)
		weaponClone = self.Sword:Cast(character)
	elseif EquippedWeapon == "LANCE" then
		weaponClone = self.Lance:Cast(character)
	elseif EquippedWeapon == "GREATSWORD" then
		weaponClone = self.Greatsword:Cast(character)
	end
end

function Class:Destroy() end

return Class
