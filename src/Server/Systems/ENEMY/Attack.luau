--!strict
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local DETECTION_RANGE = 50
local ATTACK_RANGE = 5
local ATTACK_COOLDOWN = 1.5
local HITBOX_TAG = "NPC_HITBOX"

local EnemyAI = {}
EnemyAI.__index = EnemyAI

function EnemyAI.new(enemyModel: Model)
	local self = setmetatable({}, EnemyAI)

	self.Enemy = enemyModel
	self.Humanoid = enemyModel:FindFirstChildOfClass("Humanoid")
	self.PrimaryPart = enemyModel.PrimaryPart or enemyModel:FindFirstChildWhichIsA("BasePart")

	if not (self.Humanoid and self.PrimaryPart) then
		error("Enemy không có Humanoid hoặc PrimaryPart!")
	end

	self.LastAttackTime = 0
	self.CurrentTarget = nil
	self.IsAttacking = false

	-- Bắt đầu AI
	self:Start()

	return self
end

-- Tìm người chơi gần nhất trong phạm vi
function EnemyAI:FindNearestPlayer(): Player?
	local closestPlayer: Player? = nil
	local closestDist = DETECTION_RANGE

	for _, player in Players:GetPlayers() do
		local char = player.Character
		if char and char.PrimaryPart then
			local dist = (char.PrimaryPart.Position - self.PrimaryPart.Position).Magnitude
			if dist <= DETECTION_RANGE and (not closestPlayer or dist < closestDist) then
				closestPlayer = player
				closestDist = dist
			end
		end
	end

	return closestPlayer
end

-- Spawn cube hitbox gây damage
function EnemyAI:SpawnHitbox()
	local now = tick()
	if now - self.LastAttackTime < ATTACK_COOLDOWN then
		return
	end

	local hitbox = Instance.new("Part")
	hitbox.Size = Vector3.new(6, 6, 6)
	hitbox.Shape = Enum.PartType.Ball -- hoặc Block
	hitbox.Transparency = 0.7
	hitbox.Color = Color3.fromRGB(255, 0, 0)
	hitbox.CanCollide = false
	hitbox.Anchored = true
	hitbox.CFrame = self.PrimaryPart.CFrame * CFrame.new(0, 0, -4) -- trước mặt enemy

	CollectionService:AddTag(hitbox, HITBOX_TAG)
	warn(hitbox, self.Enemy)
	hitbox.Parent = self.Enemy

	self.LastAttackTime = now

	-- Tự hủy sau 0.3 giây
	task.delay(0.3, function()
		if hitbox and hitbox.Parent then
			hitbox:Destroy()
		end
	end)
end

function EnemyAI:Start()
	task.spawn(function()
		while self.Enemy and self.Enemy.Parent do
			local targetPlayer = self:FindNearestPlayer()

			if targetPlayer and targetPlayer.Character and targetPlayer.Character.PrimaryPart then
				local targetPos = targetPlayer.Character.PrimaryPart.Position
				local distance = (targetPos - self.PrimaryPart.Position).Magnitude

				if distance <= ATTACK_RANGE then
					-- DỪNG LẠI + TẤN CÔNG
					self.Humanoid:MoveTo(self.PrimaryPart.Position) -- đứng yên
					self:SpawnHitbox()
					self.IsAttacking = true
				else
					-- RƯỢT THEO
					self.Humanoid:MoveTo(targetPos)
					self.IsAttacking = false
				end
			else
				-- Không thấy ai → đứng yên
				self.Humanoid:MoveTo(self.PrimaryPart.Position)
				self.IsAttacking = false
			end

			task.wait(0.2) -- tốc độ update AI
		end
	end)
end

function EnemyAI:Destroy()
	if self.HitboxFolder then
		self.HitboxFolder:Destroy()
	end
end

return EnemyAI
