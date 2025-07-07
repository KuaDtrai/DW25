-- Adding this later on
export type Reward = {
	Type: string,
	Rewards: {
		Pinkies: number,
		ObbyFragment: number,
		Package: number,
	},
}

local chestReward = {
	["Common"] = {
		Pinkies = 100,
		ObbyFragment = 5,
		Package = 0,
	},
	["Uncommon"] = {
		Pinkies = 150,
		ObbyFragment = 10,
		Package = 0,
	},
	["Rare"] = {
		Pinkies = 300,
		ObbyFragment = 20,
		Package = 2,
	},
	["Epic"] = {
		Pinkies = 500,
		ObbyFragment = 30,
		Package = 5,
	},
}

return chestReward
