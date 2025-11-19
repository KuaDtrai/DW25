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

local playerComboData: { [Player]: any } = {}

function Class.new(): Attack
	local self: Attack = setmetatable({}, Class)
	self.VFX = VFX.new()
	self.ComboResetTime = 1
	self.HitboxVisible = true
	self.ComboAnims = {
		CONSTANTS:getAnimation("COMBO1"),
		CONSTANTS:getAnimation("COMBO2"),
		CONSTANTS:getAnimation("COMBO3"),
	}
	return self
end

function Class:onAttack(Player: Player)
	local character = Player.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not hrp then
		return
	end

	if not playerComboData[Player] then
		playerComboData[Player] = {
			ComboIndex = 0,
			IsAnimating = false,
			NextComboQueued = false,
			CurrentTrack = nil,
			CurrentComboWindow = 0,
			ResetTimer = nil,
			IsOnCooldown = false,
		}
	end

	local comboData = playerComboData[Player]

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
		self:executeAttack(Player, comboData)
	end
end

function Class:executeAttack(Player: Player, comboData: any)
	local character = Player.Character
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

	comboData.IsAnimating = true
	comboData.NextComboQueued = false

	Player:SetAttribute("Combo", comboIndex)
	Player:SetAttribute("IsAttacking", true)

	-- ✅ BUỘC ĐỨNG IM - DISABLE WALK
	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 0
	humanoid.JumpHeight = 0

	local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
	local anim = Instance.new("Animation")
	anim.AnimationId = animId
	local track = animator:LoadAnimation(anim)
	track.Priority = Enum.AnimationPriority.Action
	track.Looped = false
	comboData.CurrentTrack = track

	self.VFX.PlayVFX(character, track.Length)
	track:Play()

	if comboIndex == 3 then
		track:AdjustSpeed(2)
	else
		track:AdjustSpeed(1.5)
	end

	local actualLength = track.Length / track.Speed
	local dynamicWindow = math.max(actualLength * 0.5, 0.1)

	comboData.CurrentComboWindow = dynamicWindow

	warn(
		string.format(
			"Combo %d | Origin: %.3f | Speed: %.1f | Actual: %.3f | Window: %.3f",
			comboIndex,
			track.Length,
			track.Speed,
			actualLength,
			dynamicWindow
		)
	)

	local hitTime = math.clamp(actualLength * 0.4, 0.1, 1)
	self:spawnArcHitbox(character, hitTime)

	task.delay(actualLength, function()
		if not character or not character.Parent then
			return
		end

		-- ✅ MỞ KHÓA DI CHUYỂN
		humanoid.WalkSpeed = 16
		humanoid.JumpPower = 50
		humanoid.JumpHeight = 7.2

		comboData.CurrentTrack = nil
		comboData.IsAnimating = false
		Player:SetAttribute("IsAttacking", false)

		if comboData.NextComboQueued then
			comboData.ComboIndex = (comboData.ComboIndex % #self.ComboAnims) + 1
			self:executeAttack(Player, comboData)
			return
		else
			comboData.ResetTimer = task.delay(dynamicWindow, function()
				if Player.Parent then
					comboData.ComboIndex = 0
					Player:SetAttribute("Combo", 0)
				end
			end)
		end

		if comboIndex == 3 then
			comboData.IsOnCooldown = true
			task.delay(self.ComboResetTime, function()
				if Player.Parent then
					comboData.IsOnCooldown = false
					comboData.ComboIndex = 0
					Player:SetAttribute("Combo", 0)
				end
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
	part.Name = "aisarwinning_" .. HttpService:GenerateGUID(false)
	part.Size = Vector3.new(10, 10, 5)
	part.CFrame = hrp.CFrame * CFrame.new(0, 0, -7.5)
	part.CanCollide = false
	part.Anchored = true
	part.Parent = character
	CollectionService:AddTag(part, "HITBOX")

	local ownerValue = Instance.new("ObjectValue")
	ownerValue.Name = "Owner"
	ownerValue.Value = Players:GetPlayerFromCharacter(character)
	ownerValue.Parent = part

	if self.HitboxVisible then
		part.Transparency = 1
		part.Color = Color3.fromRGB(17, 17, 17)
	end

	Debris:AddItem(part, activeTime)
end

function Class:resetComboForPlayer(Player: Player)
	local comboData = playerComboData[Player]
	if comboData then
		if comboData.ResetTimer then
			task.cancel(comboData.ResetTimer)
		end
		comboData.ComboIndex = 0
		comboData.IsAnimating = false
		comboData.NextComboQueued = false
		comboData.IsOnCooldown = false
		comboData.CurrentTrack = nil
		comboData.CurrentComboWindow = 0
	end
	Player:SetAttribute("Combo", 0)
	Player:SetAttribute("IsAttacking", false)
end

function Class:Destroy()
	for _, data in pairs(playerComboData) do
		if data.ResetTimer then
			task.cancel(data.ResetTimer)
		end
	end
	playerComboData = {}
end

return Class
