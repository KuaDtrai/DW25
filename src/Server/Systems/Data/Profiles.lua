--!strict
local HttpService = game:GetService("HttpService")
export type Profile = {
	Data: Data,
	--to work with ProfileService
	Release: (any) -> (),
}

local Template: Data = {
	Inventory = {},
	Unlocked_Heros = {},
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
