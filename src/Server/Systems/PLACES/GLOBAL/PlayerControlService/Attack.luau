--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
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
		0.2,
		0.2,
	}
	self.ComboAnims = {
		CONSTANTS:getAnimation("COMBO1"),
		CONSTANTS:getAnimation("COMBO2"),
		CONSTANTS:getAnimation("COMBO3"),
	}

	self.ComboIndex = 1
	self.ComboResetTime = 1
	self.LastAttackTime = 0
	return self
end

function Class:onAttack(Player)
	local character = Player.Character
	if not character then
		warn("No character found for player:", Player.Name)
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not hrp then
		warn("Humanoid or HRP missing for character:", character.Name)
		return
	end

	-- Reset combo if too slow
	local now = tick()
	if now - self.LastAttackTime > self.ComboResetTime then
		self.ComboIndex = 1
	end
	self.LastAttackTime = now

	-- Get combo data
	local hitboxModel = self.Combo[self.ComboIndex]
	local spawnDelay = self.HITBOX_TIME[self.ComboIndex]
	local animId = self.ComboAnims[self.ComboIndex]

	-- Play animation
	if animId and animId ~= "" then
		local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
		animator.Parent = humanoid

		local anim = Instance.new("Animation")
		anim.AnimationId = animId
		Debris:AddItem(anim, 1.5) -- Clean up animation object

		local track = animator:LoadAnimation(anim)
		if track then
			-- Stop other animations
			for _, playingTrack in ipairs(animator:GetPlayingAnimationTracks()) do
				playingTrack:Stop()
			end
			track.Priority = Enum.AnimationPriority.Action
			track:Play()
			print("Playing animation:", animId)
		else
			warn("Failed to load animation with ID:", animId)
		end

		-- Spawn hitbox during active frames
		task.delay(spawnDelay, function()
			if humanoid.Health > 0 then
				Class.spawnArcHitbox(character, hitboxModel, spawnDelay)
			end
		end)
	else
		warn("Invalid or empty AnimationId for ComboIndex:", self.ComboIndex)
	end

	Player:SetAttribute("Combo", self.ComboIndex)

	-- Schedule reset after ComboResetTime
	local thisAttackTime = self.LastAttackTime
	task.delay(self.ComboResetTime, function()
		-- Only reset if no new attacks happened since
		if self.LastAttackTime == thisAttackTime then
			self.ComboIndex = 1
			Player:SetAttribute("Combo", 0) -- reset to 0
		end
	end)

	-- Advance combo
	if self.ComboIndex >= #self.Combo then
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
