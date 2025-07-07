-- export type Weapon = {
-- 	Item: string,
-- 	Type: string,
-- 	Price: number,
-- 	Durability: number,
-- 	Level: number,
-- 	Damage: number,
-- 	Speed: number,
-- 	Rarity: number,
-- }

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Packages.Signal)
local _FastCast_Redux = require(ReplicatedStorage.Packages.fastcastredux)

local _ActiveCastStatic =
	require(ReplicatedStorage.Packages._Index["encodedvenom_fastcastredux@0.1.3"].fastcastredux.ActiveCast)
local FastCastTypeDefinitions =
	require(ReplicatedStorage.Packages._Index["encodedvenom_fastcastredux@0.1.3"].fastcastredux.TypeDefinitions)
local ConsumableType = require(ReplicatedStorage.Shared.Consumables.ConsumableType)
local WeaponType = require(ReplicatedStorage.Shared.Weapons.WeaponType)

export type Behavior = FastCastTypeDefinitions.FastCastBehavior
export type Caster = FastCastTypeDefinitions.Caster & typeof(_FastCast_Redux) & { [string]: any }
export type CastTrajectory = FastCastTypeDefinitions.CastTrajectory
export type CastRayInfo = FastCastTypeDefinitions.CastRayInfo
export type CastStateInfo = FastCastTypeDefinitions.CastStateInfo
export type _ActiveCast = FastCastTypeDefinitions.ActiveCast
export type ActiveCast = _ActiveCast & typeof(_ActiveCastStatic)

export type Weapon = WeaponType.Weapon

export type ConsumeItem = ConsumableType.Item

export type Equipment = {
	Model: Model?,
	Data: Weapon?,
	RigidConstraint: RigidConstraint?,
	Motor6D: Motor6D?,
}

export type Attack = {
	__index: Attack,

	new: (character: Model, damage: number, weapon: string) -> Attack,
	Setup: (self: Attack) -> (),
	Fire: (self: Attack, shootingPos: Vector3?, direction: Vector3?) -> (),
	Destroy: (self: Attack) -> (),

	_Last: number,
	_Tracks: { Fire: AnimationTrack?, Idle: AnimationTrack? },
	Damage: number,
	Character: Model,
	Weapon: Weapon,
	Caster: Caster,
	Behavior: Behavior,
}

export type Consume = {
	__index: Consume,

	new: (character: Model, healPoint: number, item: string) -> Consume,
	Setup: (self: Consume) -> (),
	Fire: (self: Consume) -> (),
	Destroy: (self: Consume) -> (),

	_Last: number,
	_Tracks: { Fire: AnimationTrack?, Idle: AnimationTrack? },
	_Heal: Signal.Signal<Model, number?, string>,
	HealPoint: number,
	Character: Model,
	Item: ConsumeItem,
}

-- TODO: Thinking about this sections
export type Movement = {
	__index: Movement,

	Character: Model,
	Root: BasePart,
	Humanoid: Humanoid,

	_Action: string,
	_Actions: { [string]: (controller: Movement, ...any) -> () & { [string]: any } },
	_Movement: {
		Left: boolean,
		Right: boolean,
		Direction: number,
		Speed: number,
	},

	ActionChanged: RBXScriptSignal,
	Connections: { RBXScriptConnection },

	new: (character: Model) -> Movement,
	Move: (self: Movement, right: boolean, state: Enum.UserInputState) -> (),
	Do: (self: Movement, actionName: string, ...any) -> (),
	Face: (self: Movement, direction: Vector3, alpha: number?) -> (),
	Update: (self: Movement, dt: number) -> (),

	IsInState: (self: Movement, stateName: string) -> boolean,
	GetAction: (self: Movement) -> string,
	SetAction: (self: Movement, action: string) -> (),
	ClearAction: (self: Movement) -> (),
	GetTimeSinceAction: (self: Movement, action: string) -> number,

	Destroy: (self: Movement) -> (),
}

export type Camera = {
	__index: Camera,
	new: (character: Model) -> Camera,

	Shock: (self: Camera) -> (),
	Bind: (self: Camera) -> (),
	Unbind: (self: Camera) -> (),
	LookAt: (self: Camera, position: Vector3) -> (),
	Update: (self: Camera, mousePosition: { X: number, Y: number }) -> (),
	Destroy: (self: Camera) -> (),

	FOV: number,
	Speed: number,

	Character: Model,
	Humanoid: Humanoid,
	Joints: {
		Neck: JointInstance?,
		Waist: JointInstance?,
		YOffsetNeck: CFrame,
		YOffsetWaist: CFrame,
	},
}

export type VFX = {
	__index: VFX,
	new: (character: Model) -> VFX,
	Do: (self: VFX, action: string) -> (),
	LoadAnimations: (self: VFX) -> (),
	PlayAnimation: (self: VFX, action: string) -> (),
	Destroy: (self: VFX) -> (),

	Local: boolean,
	Character: Model,
	AnimationTracks: { [string]: AnimationTrack },
	Connections: { RBXScriptConnection },

	_LoopedAnimation: AnimationTrack?,
	_Actions: { [string]: (controller: Movement, ...any) -> () & { [string]: any } },
	_Effects: { [string]: (character: Model) -> () },
}

return true
