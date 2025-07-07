local is_random_spawn = game.Workspace:GetAttribute("IS_RANDOM_SPAWN")
return {
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
}
