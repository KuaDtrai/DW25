--!strict
local is_random_spawn = game.Workspace:GetAttribute("IS_RANDOM_SPAWN")

local Constants = {
	LOBBY_ID = 119334285068261,
	LACDUONG_ID = 106860163281620,
	ARENA_ID = 122596162108564,
	MAP1_ID = 80052819822430,
	MAP2_ID = 98402206815955,
	MAP3_ID = 103160072410402,

	ANIMATION = {
		ATTACK = 102407853326594,
		COMBO1 = 89757122292834,
		COMBO2 = 89757122292834,
		COMBO3 = 89757122292834,
		BLOCK = 94477524681114,
		DASH = 116692188781498,
		SKILL1 = "Skill",
		SKILL2 = "Skill",
		SKILL3 = "Skill",
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

	ARENDA_ID = 103160072410402,

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
