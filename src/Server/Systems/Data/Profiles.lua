--!strict
local HttpService = game:GetService("HttpService")
export type Profile = {
	Data: Data,
	--to work with ProfileService
	Release: (any) -> (),
}

local Template: Data = {
	TimePlayed = 0,
	MatchPlayed = 0,
	Wins = 0,
	PKs = 0,
	Coin = 0,

	StatUpgradePoints = 5,
	Inventory = {},
	Equipment = "SwordShield",
	Character_Stat_Profile = {
		[1] = {
			Strength = 0,
			Dexterity = 0,
			Constitution = 0,
			Athletics = 0,
		},
	},
}

local Profiles: { [Player]: Profile } = {}

export type Profiles = {
	VERSION: string,
	Template: Data,
	Profiles: { [Player]: Profile },
}

export type Data = typeof(Template)

local DATA_CONSTANT_RESET: boolean = false
local UUID: string = DATA_CONSTANT_RESET and HttpService:GenerateGUID() or ""

return {

	VERSION = "DEV_0.0.0" .. UUID,
	Template = Template,
	Profiles = Profiles,
} :: Profiles
