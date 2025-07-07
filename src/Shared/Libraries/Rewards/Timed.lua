--!strict

local SECOND: number = 1
local MINUTE: number = 60 * SECOND
local HOUR: number = 60 * MINUTE

export type Reward = {
	Time: number,
	Image: {
		Claimable: string,
		Claimed: string,
	},
	Model: Model?,
	Rewards: {
		Coins: number,
		Gems: number,
	},
}

return {}
