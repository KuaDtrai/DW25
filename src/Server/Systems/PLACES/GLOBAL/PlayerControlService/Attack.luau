--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local VFX = require(script.Parent.VFX)

local CONSTANTS = require(ReplicatedStorage.Shared.Libraries.CONSTANTS)

export type Attack = {
	__index: Attack,
	new: () -> Attack,
	onAttack: (self: Attack, player: Player) -> (),
	Destroy: (self: Attack) -> (),
}

local Class: Attack = {}
Class.__index = Class

-- Key theo UserId để không bị memory leak
local playerComboData: { [number]: any } = {}

local function getComboData(player: Player)
	local id = player.UserId
	if not playerComboData[id] then
		playerComboData[id] = {
			ComboIndex = 0,
			IsAnimating = false,
			NextComboQueued = false,
			CurrentTrack = nil,
			CurrentComboWindow = 0,
			ResetTimer = nil,
			IsOnCooldown = false,

			OrigWalkSpeed = nil,
			OrigJumpPower = nil,
			OrigJumpHeight = nil,

			Animator = nil,
		}
	end
	return playerComboData[id]
end

Players.PlayerRemoving:Connect(function(player)
	local id = player.UserId
	local data = playerComboData[id]
	if data then
		if data.ResetTimer then
			task.cancel(data.ResetTimer)
		end
		if data.CurrentTrack then
			data.CurrentTrack:Stop()
		end
		playerComboData[id] = nil
	end
end)

function Class.new(): Attack
	local self: Attack = setmetatable({}, Class)
	self.VFX = VFX.new()
	self.ComboResetTime = 1.5
	self.HitboxVisible = false
	self.ComboAnims = {
		CONSTANTS:getAnimation("COMBO1"),
		CONSTANTS:getAnimation("COMBO2"),
		CONSTANTS:getAnimation("COMBO3"),
	}
	return self
end

function Class:onAttack(player: Player)
	local character = player.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not hrp then
		return
	end

	local comboData = getComboData(player)

	if comboData.IsOnCooldown then
		return
	end

	local track = comboData.CurrentTrack
	if track and track.IsPlaying then
		local timeLeft = track.Length - track.TimePosition
		if timeLeft > comboData.CurrentComboWindow then
			return
		end
	end

	comboData.NextComboQueued = true

	if not comboData.IsAnimating then
		comboData.ComboIndex = (comboData.ComboIndex % #self.ComboAnims) + 1
		self:executeAttack(player, comboData)
	end
end

function Class:executeAttack(player: Player, comboData: any)
	local character = player.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not hrp then
		return
	end

	local comboIndex = comboData.ComboIndex
	local animId = self.ComboAnims[comboIndex]

	-- State
	comboData.IsAnimating = true
	comboData.NextComboQueued = false

	player:SetAttribute("Combo", comboIndex)
	player:SetAttribute("IsAttacking", true)

	-- Save movement state
	if comboData.OrigWalkSpeed == nil then
		comboData.OrigWalkSpeed = humanoid.WalkSpeed
		comboData.OrigJumpPower = humanoid.JumpPower
		comboData.OrigJumpHeight = humanoid.JumpHeight
	end

	-- Freeze
	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 0
	humanoid.JumpHeight = 0

	-- Animator
	local animator = comboData.Animator
	if not animator then
		animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
		comboData.Animator = animator
	end

	local anim = Instance.new("Animation")
	anim.AnimationId = animId
	local track = animator:LoadAnimation(anim)
	track.Priority = Enum.AnimationPriority.Action
	track.Looped = false
	comboData.CurrentTrack = track

	track:Play()

	-- Wait track length loaded
	local t = 0
	while track.Length == 0 and t < 0.4 do
		task.wait(0.03)
		t += 0.03
	end

	-- Speed
	-- if comboIndex == 3 then
	-- 	track:AdjustSpeed(2)
	-- else
	-- track:AdjustSpeed(1.5)
	-- end

	local actualLength = math.max(track.Length / track.Speed, 0.2)
	local comboWindow = math.max(actualLength * 0.5, 0.1)
	comboData.CurrentComboWindow = comboWindow

	self.VFX.PlayVFX(character, actualLength)

	-- Hitbox timing
	local hitDelay = math.clamp(actualLength * 0.4, 0.1, 1)
	task.delay(hitDelay, function()
		self:spawnArcHitbox(character, 0.15)
	end)

	-- End animation
	task.delay(actualLength, function()
		if not player.Parent then
			return
		end

		-- Restore movement
		humanoid.WalkSpeed = comboData.OrigWalkSpeed
		humanoid.JumpPower = comboData.OrigJumpPower
		humanoid.JumpHeight = comboData.OrigJumpHeight

		-- Reset state
		comboData.CurrentTrack = nil
		comboData.IsAnimating = false
		player:SetAttribute("IsAttacking", false)

		-- Next combo queued
		if comboData.NextComboQueued then
			comboData.ComboIndex = (comboData.ComboIndex % #self.ComboAnims) + 1
			self:executeAttack(player, comboData)
			return
		end

		-- Reset combo after window
		comboData.ResetTimer = task.delay(comboWindow, function()
			if player.Parent then
				comboData.ComboIndex = 0
				player:SetAttribute("Combo", 0)
			end
		end)

		-- Cooldown on final hit
		if comboIndex == 3 then
			comboData.IsOnCooldown = true
			task.delay(self.ComboResetTime, function()
				comboData.IsOnCooldown = false
				comboData.ComboIndex = 0
				player:SetAttribute("Combo", 0)
			end)
		end
	end)

	Debris:AddItem(anim, 2)
end

function Class:spawnArcHitbox(character: Model, activeTime: number)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end

	local part = Instance.new("Part")
	part.Name = "Hitbox_" .. HttpService:GenerateGUID(false)
	part.Size = Vector3.new(10, 10, 10)
	part.CFrame = hrp.CFrame * CFrame.new(0, 0, -6)
	part.CanCollide = false
	part.Anchored = true

	-- ❗ Không parent vào character
	part.Parent = workspace

	CollectionService:AddTag(part, "HITBOX")

	local ownerValue = Instance.new("ObjectValue")
	ownerValue.Name = "Owner"
	ownerValue.Value = Players:GetPlayerFromCharacter(character)
	ownerValue.Parent = part

	if not self.HitboxVisible then
		part.Transparency = 1
	end

	Debris:AddItem(part, activeTime)
end

function Class:resetComboForPlayer(player: Player)
	local data = playerComboData[player.UserId]
	if not data then
		return
	end

	if data.ResetTimer then
		task.cancel(data.ResetTimer)
	end

	data.ComboIndex = 0
	data.IsAnimating = false
	data.NextComboQueued = false
	data.IsOnCooldown = false

	player:SetAttribute("Combo", 0)
	player:SetAttribute("IsAttacking", false)
end

return Class
