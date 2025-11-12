--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HitBoxFolder = ReplicatedStorage.Shared.Assets.HitBox :: Folder
local CONSTANTS = require(ReplicatedStorage.Shared.Libraries.CONSTANTS)
local Debris = game:GetService("Debris")
local VFX = require(script.Parent.VFX)

export type Skill = {
	__index: Skill,
	new: (Attack: any) -> Skill,
	onSkill: (self: Skill, player: Player) -> (),
	spawnArcHitbox: (character: Model, hitbox: Model, time: number, color: Color3) -> (),
	Destroy: (self: Skill) -> (),
}

local Class: Skill = {} :: Skill
Class.__index = Class

function Class.new(Attack): Skill
	local self: Skill = setmetatable({} :: any, Class)
	self.Attack = Attack
	self.VFX = VFX.new()

	self.Combo = {
		HitBoxFolder:FindFirstChild("45_degree"),
		HitBoxFolder:FindFirstChild("90_degree"),
		HitBoxFolder:FindFirstChild("180_degree"),
	}

	self.SkillAnims = {
		CONSTANTS:getAnimation("SKILL1"),
		CONSTANTS:getAnimation("SKILL2"),
		CONSTANTS:getAnimation("SKILL3"),
	}

	self.Green = Color3.new(0.145098, 1, 0.011764)
	self.Blue = Color3.new(0.027450, 0.011764, 1)
	self.Purple = Color3.new(0.721568, 0.011764, 1)

	return self
end

-- 🧠 Kích hoạt skill chỉ khi đã hoàn thành đòn đánh
function Class:onSkill(Player: Player)
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

	local combo = Player:GetAttribute("Combo") or 0
	local isAttacking = Player:GetAttribute("IsAttacking") or false
	local isUsingSkill = Player:GetAttribute("IsUsingSkill") or false

	-- ❌ Chưa ra đòn nào thì không làm gì
	if combo == 0 then
		print(Player.Name .. " tried to use skill but no combo active.")
		return
	end

	-- ⚠️ Nếu đang đánh hoặc đang skill thì không thể kích hoạt skill
	if isAttacking or isUsingSkill then
		print(Player.Name .. " is busy (attacking/using skill), cannot use skill.")
		return
	end

	print(Player.Name .. " 🌀 Kích hoạt skill từ combo:", combo)
	Player:SetAttribute("IsUsingSkill", true)

	local hitbox = self.Combo[combo]
	local animId = self.SkillAnims[combo]
	local color = (combo == 1 and self.Green) or (combo == 2 and self.Blue) or self.Purple

	if not hitbox or not animId then
		warn("❌ Missing hitbox or anim for combo:", combo)
		Player:SetAttribute("IsUsingSkill", false)
		return
	end

	-- 🔄 Phát animation skill
	local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
	local anim = Instance.new("Animation")
	anim.AnimationId = animId
	local track = animator:LoadAnimation(anim)
	Debris:AddItem(anim, 2)

	track.Priority = Enum.AnimationPriority.Action
	track.Looped = false
	self.VFX.PlayVFX(character, track.Length)
	track:Play()

	-- Lấy thời lượng animation để điều khiển hitbox
	local animLength = track.Length
	print(Player.Name, "🎬 Skill animation length:", animLength)

	-- ⚔️ Gọi spawn hitbox theo thời gian thật của animation
	Class.spawnArcHitbox(character, hitbox, animLength, color)

	-- Khi animation kết thúc
	task.delay(animLength, function()
		if not Player.Parent then
			return
		end

		Player:SetAttribute("IsUsingSkill", false)

		-- ✅ Reset combo hoàn toàn
		if self.Attack and self.Attack.resetComboForPlayer then
			self.Attack:resetComboForPlayer(Player)
		else
			Player:SetAttribute("Combo", 0)
		end

		print(Player.Name .. " 🔁 Skill kết thúc → có thể tấn công lại")
	end)
end

-- ⚔️ Sinh hitbox và khoá di chuyển tạm thời
function Class.spawnArcHitbox(character: Model, hitbox: Model, time: number, color: Color3)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local Humanoid = character:FindFirstChild("Humanoid")
	if not hrp or not Humanoid or not hitbox then
		return
	end

	local oldWalkSpeed = Humanoid.WalkSpeed
	Humanoid.WalkSpeed = 0

	local clone = hitbox:Clone()
	clone.Parent = hrp
	clone.CFrame = hrp.CFrame * CFrame.new(0, 0, -5) * CFrame.Angles(0, math.rad(180), 0)

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = hrp
	weld.Part1 = clone
	weld.Parent = clone

	clone.Transparency = 1
	clone.Color = color

	task.delay(time, function()
		if clone and clone.Parent then
			clone:Destroy()
		end
		if Humanoid and Humanoid.Parent then
			Humanoid.WalkSpeed = oldWalkSpeed
		end
	end)
end

function Class:Destroy() end

return Class
