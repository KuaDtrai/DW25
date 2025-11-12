--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local VFX = require(script.Parent.VFX)

local HitBoxFolder = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Assets"):WaitForChild("HitBox") :: Folder
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
	self.Combo = {
		HitBoxFolder:FindFirstChild("45_degree"),
		HitBoxFolder:FindFirstChild("90_degree"),
		HitBoxFolder:FindFirstChild("180_degree"),
	}

	self.ComboAnims = {
		CONSTANTS:getAnimation("COMBO1"),
		CONSTANTS:getAnimation("COMBO2"),
		CONSTANTS:getAnimation("COMBO3"),
	}

	self.ComboResetTime = 1.5
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

	-- Nếu đang cooldown sau combo3 → không cho tấn công
	if comboData.IsOnCooldown then
		warn(Player.Name, "⛔ Đang hồi chiêu, không thể tấn công.")
		return
	end

	-- Hủy timer reset combo nếu có click mới
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
		local nextIndex = (comboData.ComboIndex % #self.Combo) + 1
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
	local hitboxTemplate = self.Combo[comboIndex]
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

	-- if comboIndex == 3 then
	-- 	-- Đẩy nhân vật về phía trước 5 stud
	-- 	local distance = 20
	-- 	local tweenTime = 0.5 -- thời gian di chuyển (giây)
	-- 	local goalCFrame = hrp.CFrame * CFrame.new(0, 0, -distance)
	-- 	local tweenInfo = TweenInfo.new(
	-- 		tweenTime,
	-- 		Enum.EasingStyle.Quad, -- kiểu easing (có thể thử: Linear, Sine, Quint, Back, Elastic...)
	-- 		Enum.EasingDirection.Out -- hướng easing
	-- 	)
	-- 	local tween = TweenService:Create(hrp, tweenInfo, { CFrame = goalCFrame })
	-- 	tween:Play()
	-- end

	if hitboxTemplate then
		self:spawnArcHitbox(character, hitboxTemplate, hitTime)
	end

	task.delay(animLength, function()
		if not character or not character.Parent then
			return
		end
		comboData.IsAnimating = false
		Player:SetAttribute("IsAttacking", false)

		-- Nếu có queue → đánh combo tiếp theo
		if comboData.AttackQueue then
			comboData.AttackQueue = false
			comboData.ComboIndex = (comboData.ComboIndex % #self.Combo) + 1
			warn(Player.Name, "🔁 Queue → chuyển sang combo:", comboData.ComboIndex)
			self:executeAttack(Player, comboData)
			return
		end

		-- Nếu là combo cuối cùng (combo3)
		if comboIndex == 3 then
			warn(Player.Name, "🚀 Hoàn thành combo 3 → đẩy về phía trước và hồi chiêu.")
			comboData.IsOnCooldown = true

			-- Reset combo sau 1.5s
			comboData.ResetTimer = task.delay(self.ComboResetTime, function()
				if Player.Parent then
					comboData.ComboIndex = 0
					Player:SetAttribute("Combo", 0)
					comboData.ResetTimer = nil
					warn(Player.Name, "⏱️ Reset combo sau combo3")
				end
			end)

			-- Chờ 1.5s hồi chiêu
			task.delay(1.5, function()
				if Player.Parent then
					comboData.IsOnCooldown = false
					warn(Player.Name, "✅ Hết thời gian hồi chiêu, có thể tấn công lại.")
				end
			end)
		else
			-- Combo 1 hoặc 2 → đặt timer reset combo bình thường
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

function Class:spawnArcHitbox(character: Model, hitboxTemplate: Model, activeTime: number)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not hrp or not humanoid then
		return
	end

	local clone = hitboxTemplate:Clone()
	clone.Anchored = false
	clone.CanCollide = false
	clone.Transparency = 1
	clone.Parent = hrp
	clone.CFrame = hrp.CFrame * CFrame.new(0, 0, -4)

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = hrp
	weld.Part1 = clone
	weld.Parent = clone

	local oldWalk = humanoid.WalkSpeed
	humanoid.WalkSpeed = 0

	task.delay(activeTime, function()
		if clone then
			clone:Destroy()
		end
		if humanoid and humanoid.Parent then
			humanoid.WalkSpeed = oldWalk
		end
	end)
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
	warn(Player.Name, "🔁 Combo đã được reset hoàn toàn (sau skill hoặc reset thủ công)")
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
