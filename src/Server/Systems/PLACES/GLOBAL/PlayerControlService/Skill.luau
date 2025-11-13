--!strict
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game.Players
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

-- ⚔️ Sinh hitbox và khoá di chuyển tạm thời (tạo mới Part thay vì clone)
function Class.spawnArcHitbox(character: Model, _hitbox: Model, time: number, color: Color3)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not hrp or not humanoid then
		return
	end

	-- 🧱 Tạo hitbox mới (thay vì clone)
	local part = Instance.new("Part")
	part.Name = "SkillHitbox_" .. game:GetService("HttpService"):GenerateGUID(false)
	part.Parent = character
	CollectionService:AddTag(part, "HITBOX")
	part.Size = Vector3.new(12, 8, 12)
	part.CFrame = hrp.CFrame * CFrame.new(0, 0, -6)
	part.Anchored = true
	part.CanCollide = false
	part.Massless = true

	-- 🧠 Lưu chủ sở hữu
	local ownerValue = Instance.new("ObjectValue")
	ownerValue.Name = "Owner"
	ownerValue.Value = Players:GetPlayerFromCharacter(character)
	ownerValue.Parent = part

	-- 🎨 Hiển thị hitbox nếu đang bật chế độ debug
	if shared.HitboxVisible then
		part.Transparency = 1
		part.Color = color

		local highlight = Instance.new("SelectionBox")
		highlight.Name = "SkillHitboxHighlight"
		highlight.Parent = part
		highlight.Adornee = part
		highlight.LineThickness = 0.05
		highlight.SurfaceTransparency = 1
		highlight.Transparency = 0.5
		highlight.Color3 = color
		highlight.Visible = true
	else
		part.Transparency = 1
	end

	-- 🔒 Khóa di chuyển trong lúc skill
	local oldWalk = humanoid.WalkSpeed
	humanoid.WalkSpeed = 0

	-- 🕒 Xóa hitbox sau thời gian animation
	task.delay(time, function()
		if part and part.Parent then
			part:Destroy()
		end
		if humanoid and humanoid.Parent then
			humanoid.WalkSpeed = oldWalk
		end
	end)
end

function Class:Destroy() end

return Class
