--!strict
local HttpService = game:GetService("HttpService")
export type Profile = {
	Data: Data,
	--to work with ProfileService
	Release: (any) -> (),
}

local Template: Data = {
	TimePlayed = 0,
	FailedTime = 0,
	PKs = 0,
	Coin = 0,

	Inventory = {
		Weapons = {
			-- {
			-- 	Name = "Knife",
			-- 	Type = "Sword",
			-- 	Rarity = "Common",
			-- 	Damage = 10,
			-- 	Durability = 100,
			-- },
			-- {
			-- 	Name = "Stick",
			-- 	Type = "Sword",
			-- 	Rarity = "Common",
			-- 	Damage = 10,
			-- 	Durability = 100,
			-- },
		},
		Consumables = {
			-- {
			-- 	Name = "Herb",
			-- 	Type = "HERB",
			-- 	Rarity = "Common",
			-- 	HP = 10,
			-- 	Quantity = 10,
			-- },
			-- {
			-- 	Name = "Steak",
			-- 	Type = "FOOD",
			-- 	Rarity = "Common",
			-- 	HP = 10,
			-- 	Quantity = 10,
			-- },
		},
		Fuse = {

			-- {
			-- 	Name = "Bomb Fruit",
			-- 	Type = "BOMB",
			-- 	Rarity = "Common",
			-- 	Quantity = 10,
			-- },
			-- {
			-- 	Name = "Fire Fruit",
			-- 	Type = "FIRE",
			-- 	Rarity = "Common",
			-- 	Quantity = 10,
			-- },
			-- {
			-- 	Name = "Smoke Fruit",
			-- 	Type = "SMOKE",
			-- 	Rarity = "Common",
			-- 	Quantity = 10,
			-- },
		},
	},

	-- Toolbar = {
	-- 	Slots = {
	-- 		{
	-- 			Name = "Knife",
	-- 			Type = "Weapons",
	-- 			Rarity = "Common",
	-- 			Damage = 10,
	-- 			Durability = 100,
	-- 		},
	-- 		{
	-- 			Name = "Steak",
	-- 			Type = "Consumables",
	-- 			Rarity = "Common",
	-- 			HP = 10,
	-- 			Quantity = 10,
	-- 		},
	-- 		{
	-- 			Name = "Herb",
	-- 			Type = "Consumables",
	-- 			Rarity = "Common",
	-- 			HP = 10,

	-- 		{
	-- 			Name = "Bomb Fruit",
	-- 			Type = "BOMB",
	-- 			Rarity = "Common",
	-- 			Quantity = 10,
	-- 		},
	-- 		{
	-- 			Name = "Fire Fruit",
	-- 			Type = "FIRE",
	-- 			Rarity = "Common",
	-- 			Quantity = 10,
	-- 		},
	-- 		{
	-- 			Name = "Smoke Fruit",
	-- 			Type = "SMOKE",
	-- 			Rarity = "Common",

	-- 			Quantity = 10,
	-- 		},
	-- 	},
	-- },
}

local Profiles: { [Player]: Profile } = {}

export type Profiles = {
	VERSION: string,
	Template: Data,
	Profiles: { [Player]: Profile },
}

export type Data = typeof(Template)

local DATA_CONSTANT_RESET: boolean = true
local UUID: string = DATA_CONSTANT_RESET and HttpService:GenerateGUID() or ""

return {

	VERSION = "DEV_0.0.0" .. UUID,
	Template = Template,
	Profiles = Profiles,
} :: Profiles
