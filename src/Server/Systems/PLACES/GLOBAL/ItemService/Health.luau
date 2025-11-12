--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

export type Health = {
	__index: Health,
	new: () -> Health,
	Destroy: (self: Health) -> (),
	OnUse: (self: Health, item: Instance, player: Player) -> (), -- Updated type
}

local Class: Health = {} :: Health
Class.__index = Class

function Class.new(): Health
	local self: Health = setmetatable({} :: any, Class)
	return self
end

function Class.OnUse(item: BasePart, player: Player)
	-- Ensure the item is valid and has the "Point" attribute
	warn(item)
	if not item or not item:GetAttribute("Point") then
		warn("Health.OnUse: Item is invalid or missing 'Point' attribute")
		return
	end

	-- Get the Point value
	local point = item:GetAttribute("Point") :: number
	if type(point) ~= "number" or point <= 0 then
		warn("Health.OnUse: 'Point' attribute must be a positive number, got:", point)
		return
	end

	-- Get the player's character and Humanoid
	local character = player.Character
	if not character then
		warn("Health.OnUse: Player has no character")
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		warn("Health.OnUse: No Humanoid found in player's character")
		return
	end

	-- Restore health, ensuring it doesn't exceed MaxHealth
	humanoid.Health = math.min(humanoid.Health + point, humanoid.MaxHealth)
	warn(string.format("Health.OnUse: Restored %d health to %s (New Health: %d)", point, player.Name, humanoid.Health))

	-- Destroy the touched item
	item:Destroy()
	warn("Item destroyed:", item)
end

function Class:Destroy()
	-- Cleanup logic if needed (currently empty)
end

return Class
