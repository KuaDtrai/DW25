type Rarity = {
	{
		Name: string,
		SpawnRate: number,
		ChestSpawn: number,
	}
}

local Chances = {
	[1] = {
		Name = "Common",
		SpawnRate = 0.8,
		SpawnChance = 0.1,
	},
	[2] = {
		Name = "Uncommon",
		SpawnRate = 0.45,
		SpawnChance = 0.25,
	},
	[3] = {
		Name = "Rare",
		SpawnRate = 0.35,
		SpawnChance = 0.4,
	},
	[4] = {
		Name = "Epic",
		SpawnRate = 0.05,
		SpawnChance = 0.7,
	},
}

return Chances
