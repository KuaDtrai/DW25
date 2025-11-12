--!strict
local is_random_spawn = game.Workspace:GetAttribute("IS_RANDOM_SPAWN")

local Constants = {
	LOBBY_ID = 119334285068261,
	LACDUONG_ID = 119334285068261,
	ARENA_ID = 122596162108564,
	MAP1_ID = 80052819822430,
	MAP2_ID = 98402206815955,
	MAP3_ID = 103160072410402,

	ANIMATION = {
		ATTACK = 102407853326594,
		COMBO1 = 124724317691145,
		COMBO2 = 108697907740378,
		COMBO3 = 101073181365844,
		BLOCK = 94477524681114,
		DASH = 116692188781498,
		SKILL1 = 123145420290181,
		SKILL2 = 93585525749851,
		SKILL3 = 87039251536328,
		WALK = "Walk",
		IDLE = "Idle",
		DEAD = "Dead",
		DEATH = "Death",
		DIE = "Die",
		FLY = "Fly",
		LAND = "Land",
		JUMP = "Jump",
		RUN = "Run",
	},

	COLLECTABLE_TAG = "COLLECTED_ITEM",
	FLYING_TAG = "Flying_Dino",

	IS_RANDOM_SPAWN = is_random_spawn,

	ATTACK = "Attack",
	CONSUME = "Consume",
	ITEM_TYPE = {
		WEAPON = "Weapons",
		CONSUMABLE = "Consumables",
		FUSE = "Fuse",
	},
	BULLET_GRAVITY_AFFECT = 10,
	VISUAL_STORAGE = "",

	COLLISION_GROUPS = {
		COLLECTABLES = "COLLECTABLES",
		PLAYER = "PLAYER",
	},

	WILD_DINOSAUR_TAG = "WILD_DINO",

	getPlaceId = function(self, placeName)
		local placeId = rawget(self.PLACE_ID, placeName)
		if type(placeId) == "number" then
			return placeId
		elseif type(placeId) == "string" then
			return tonumber(placeId)
		end
		return 0
	end,

	getAnimation = function(self, animationName)
		local animId = rawget(self.ANIMATION, animationName)
		if type(animId) == "number" then
			return tostring("rbxassetid://" .. animId)
		elseif type(animId) == "string" then
			return animId
		end
		return ""
	end,
}

return Constants
