--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HitBoxFolder = ReplicatedStorage.Shared.Assets.HitBox :: Folder
local Debris = game:GetService("Debris")

local CONSTANTS = require(ReplicatedStorage.Shared.Libraries.CONSTANTS)

export type Attack = {
	__index: Attack,
	new: () -> Attack,
	onAttack: (self: Attack, player: Player) -> (),
	Destroy: (self: Attack) -> (),
}
local Class: Attack = {} :: Attack
Class.__index = Class

function Class.new(): Attack
	local self: Attack = setmetatable({} :: any, Class)

	local cone_45 = HitBoxFolder:FindFirstChild("45_degree")
	local cone_90 = HitBoxFolder:FindFirstChild("90_degree")
	local cone_180 = HitBoxFolder:FindFirstChild("180_degree")

	self.Combo = {
		cone_45,
		cone_90,
		cone_180,
	}

	self.HITBOX_TIME = {
		0.2,
		0.4,
		0.6,
	}

	-- 🔹 Combo animations (each has a hitbox timing)
	-- self.ComboAnims = {
	-- 	{ Key = "ATTACK_1", HitboxDelay = 0.15 },
	-- 	{ Key = "ATTACK_2", HitboxDelay = 0.20 },
	-- 	{ Key = "ATTACK_3", HitboxDelay = 0.25 },
	-- 	{ Key = "ATTACK_4", HitboxDelay = 0.18 }, -- finisher
	-- }
	-- HitboxDelay is the length of an animation

	self.ComboIndex = 1
	self.ComboResetTime = 1.2
	self.LastAttackTime = 0
	warn(self)
	return self
end

function Class:onAttack(Player)
	local character = Player.Character
	if not character then
		warn(0)
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		warn(0)
		return
	end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		warn(0)
		return
	end
	-- Unitl have anim will uncmt this line
	-- 🔹 Reset combo if too slow
	local now = tick()
	if now - self.LastAttackTime > self.ComboResetTime then
		self.ComboIndex = 1
	end
	self.LastAttackTime = now

	local comboData = self.Combo[self.ComboIndex]
	local comboTime = self.HITBOX_TIME[self.ComboIndex]

	-- -- 🔹 Get current combo data
	-- local comboData = self.ComboAnims[self.ComboIndex]
	-- local animationId = CONSTANTS:getAnimation(comboData.Key)

	-- if animationId ~= "" then
	-- 	local animator = humanoid:FindFirstChildOfClass("Animator")
	-- 	if not animator then
	-- 		animator = Instance.new("Animator")
	-- 		animator.Parent = humanoid
	-- 	end

	-- 	local anim = Instance.new("Animation")
	-- 	anim.AnimationId = animationId

	-- 	local track = animator:LoadAnimation(anim)
	-- 	track.Priority = Enum.AnimationPriority.Action
	-- 	track:Play()

	-- Spawn hitbox during active frames

	-- task.delay(comboData.HitboxDelay, function()
	-- 	if humanoid.Health > 0 then
	-- 		local rightHand = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
	-- 		if rightHand then
	-- 			self:spawnHitbox(rightHand, character)
	-- 		end
	-- 	end
	-- end)

	Class.spawnArcHitbox(character, comboData, comboTime)

	-- 🔹 Advance combo
	if self.ComboIndex >= #self.Combo then
		-- reached finisher, reset back to first
		self.ComboIndex = 1
	else
		self.ComboIndex += 1
	end
end

function Class.spawnArcHitbox(character: Model, hitbox: Model, time)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local Humanoid = character:FindFirstChild("Humanoid")
	Humanoid.WalkSpeed = 0

	local clone = hitbox:Clone()
	clone.Parent = hrp
	clone.CFrame = hrp.CFrame * CFrame.new(0, 0, -5) * CFrame.Angles(0, math.rad(180), 0)

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = hrp
	weld.Part1 = clone
	weld.Parent = clone

	clone.Transparency = 0.5
	clone.Color = Color3.new(1, 0, 0)

	task.delay(time, function()
		if clone then
			clone:Destroy()
			Humanoid.WalkSpeed = 16
		end
	end)
end

function Class:Destroy() end

return Class
