--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Health = require(script.Health)
local Mana = require(script.Mana)
local Speed = require(script.Speed)

local Openday = require(ReplicatedStorage.Shared.Openday)

export type System = {
	_Extensions: { Openday.Extension },
	_Start: (self: System) -> (),
	_Setup: (self: System) -> (),
	Items: { Instance }, -- Type for Items
}

local init = {
	_Extensions = {},
	Items = {}, -- Initialize Items array
} :: System

function init:_Setup()
	-- Populate Items with all objects tagged "ITEMS"
	self.Health = Health.new()
	self.Mana = Mana.new()
	self.Speed = Speed.new()

	self.Items = CollectionService:GetTagged("ITEMS")

	-- Listen for new items added with the "ITEMS" tag
	CollectionService:GetInstanceAddedSignal("ITEMS"):Connect(function(item)
		table.insert(self.Items, item)
		warn("Item added:", item)
	end)

	-- Listen for items removed from the "ITEMS" tag
	CollectionService:GetInstanceRemovedSignal("ITEMS"):Connect(function(item)
		for i, storedItem in ipairs(self.Items) do
			if storedItem == item then
				table.remove(self.Items, i)
				warn("Item removed:", item)
				break
			end
		end
	end)
end

function init:_Start()
	-- Helper function to handle touch events
	local function onTouch(part: BasePart, hit: BasePart)
		-- Check if the touching part belongs to a player's character
		local character = hit.Parent
		local player = game.Players:GetPlayerFromCharacter(character)
		if player then
			if part:HasTag("HEALTH") then
				self.Health.OnUse(part, player)
			elseif part:HasTag("MANA") then
				self.Mana.OnUse(part, player)
			elseif part:HasTag("SPEED") then
				warn(part)
				self.Speed.OnUse(part, player)
			end
		end
	end

	-- Connect Touched event for existing items
	for _, item in CollectionService:GetTagged("ITEMS") do
		if item:IsA("BasePart") then
			item.Touched:Connect(function(hit)
				onTouch(item, hit)
			end)
		end
	end

	-- Connect Touched event for newly added items
	CollectionService:GetInstanceAddedSignal("ITEMS"):Connect(function(item)
		if item:IsA("BasePart") then
			item.Touched:Connect(function(hit)
				onTouch(item, hit)
			end)
		end
	end)
end

return init
