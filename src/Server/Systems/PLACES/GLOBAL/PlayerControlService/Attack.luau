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

local Class: Attack = {} :: Attack
Class.__index = Class

-- Dữ liệu combo cho từng player
local playerComboData: { [Player]: any } = {}

function Class.new(): Attack
	local self: Attack = setmetatable({} :: any, Class)

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
			AttackQueue = false,
			ResetTimer = nil,
			IsOnCooldown = false,
		}
	end

	local comboData = playerComboData[Player]

	if comboData.IsOnCooldown then
		warn(Player.Name, "⛔ Đang hồi chiêu, không thể tấn công.")
		return
	end

	if comboData.ResetTimer then
		task.cancel(comboData.ResetTimer)
		comboData.ResetTimer = nil
	end

	if comboData.IsAnimating then
		if not comboData.AttackQueue then
			comboData.AttackQueue = true
			warn(Player.Name, "🕐 Đang animation → thêm 1 queue (tối đa 1)")
		else
			warn(Player.Name, "⚠️ Queue đã đầy → bỏ qua click")
		end
	else
		local nextIndex = (comboData.ComboIndex % #self.ComboAnims) + 1
		comboData.ComboIndex = nextIndex
		warn(Player.Name, "💥 Đánh combo:", nextIndex)
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
	comboData.AttackQueue = false

	Player:SetAttribute("Combo", comboIndex)
	Player:SetAttribute("IsAttacking", true)
	warn(Player.Name, "▶️ Thực thi combo", comboIndex, "Anim:", animId)

	local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
	local anim = Instance.new("Animation")
	anim.AnimationId = animId
	local track = animator:LoadAnimation(anim)
	track.Priority = Enum.AnimationPriority.Action
	track.Looped = false
	self.VFX.PlayVFX(character, track.Length)
	track:Play()
	Debris:AddItem(anim, 2)

	local animLength = track.Length
	local hitTime = math.clamp(animLength * 0.4, 0.1, 1)

	-- Gọi hàm tạo hitbox mới
	self:spawnArcHitbox(character, hitTime)

	task.delay(animLength, function()
		if not character or not character.Parent then
			return
		end
		comboData.IsAnimating = false
		Player:SetAttribute("IsAttacking", false)

		-- Nếu có queue → đánh combo tiếp theo
		if comboData.AttackQueue then
			comboData.AttackQueue = false
			comboData.ComboIndex = (comboData.ComboIndex % #self.ComboAnims) + 1
			warn(Player.Name, "🔁 Queue → chuyển sang combo:", comboData.ComboIndex)
			self:executeAttack(Player, comboData)
			return
		end

		-- Nếu là combo cuối cùng (combo3)
		if comboIndex == 3 then
			warn(Player.Name, "🚀 Hoàn thành combo 3 → hồi chiêu.")
			comboData.IsOnCooldown = true

			comboData.ResetTimer = task.delay(self.ComboResetTime, function()
				if Player.Parent then
					comboData.ComboIndex = 0
					Player:SetAttribute("Combo", 0)
					comboData.ResetTimer = nil
					warn(Player.Name, "⏱️ Reset combo sau combo3")
				end
			end)

			task.delay(1.5, function()
				if Player.Parent then
					comboData.IsOnCooldown = false
					warn(Player.Name, "✅ Hết hồi chiêu, có thể tấn công lại.")
				end
			end)
		else
			comboData.ResetTimer = task.delay(self.ComboResetTime, function()
				if Player.Parent then
					comboData.ComboIndex = 0
					Player:SetAttribute("Combo", 0)
					comboData.ResetTimer = nil
					warn(Player.Name, "⏱️ Reset combo → COMBO1")
				end
			end)
		end
	end)
end

-- 🔹 Hàm tạo hitbox vuông mới thay cho clone template
function Class:spawnArcHitbox(character: Model, activeTime: number)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end

	local part = Instance.new("Part")
	part.Name = "aisarwinning_" .. HttpService:GenerateGUID(false)
	part.Size = Vector3.new(10, 10, 10)
	part.CFrame = hrp.CFrame * CFrame.new(0, 0, -4)
	part.CanCollide = false
	part.Anchored = true
	part.Parent = workspace
	CollectionService:AddTag(part, "HITBOX")

	-- Hiển thị hitbox (debug)
	if self.HitboxVisible then
		part.Transparency = 1
		part.Color = Color3.fromRGB(17, 17, 17)

		local Highlight = Instance.new("SelectionBox")
		Highlight.Name = "highlight"
		Highlight.Parent = part
		Highlight.Adornee = part
		Highlight.LineThickness = 0.05
		Highlight.SurfaceTransparency = 1
		Highlight.Transparency = 0.5
		Highlight.Color3 = Color3.fromRGB(166, 0, 0)
		Highlight.Visible = true
	end

	-- Tự hủy sau activeTime
	Debris:AddItem(part, activeTime)
end

function Class:resetComboForPlayer(Player: Player)
	local comboData = playerComboData[Player]
	if comboData then
		if comboData.ResetTimer then
			task.cancel(comboData.ResetTimer)
			comboData.ResetTimer = nil
		end
		comboData.ComboIndex = 0
		comboData.IsAnimating = false
		comboData.AttackQueue = false
		comboData.IsOnCooldown = false
	end

	Player:SetAttribute("Combo", 0)
	Player:SetAttribute("IsAttacking", false)
	warn(Player.Name, "🔁 Combo đã được reset hoàn toàn")
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
