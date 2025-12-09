--!strict
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local Workspace = game.Workspace

local ENEMY_TAG = "ENEMY"

local DETECTION_RANGE = 50
local ATTACK_RANGE = 5
local ATTACK_COOLDOWN = 1.5

local ATTACK_ANIM_ID = "rbxassetid://93630352572586"
local MOVE_ANIM_ID = "rbxassetid://126918793505286"

---------------------------------------------------------------------

local function createTimedHitbox(enemy: Model, duration: number)
	local root = enemy:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	local hitbox = Instance.new("Part")
	hitbox.Name = "EnemyHitbox"
	hitbox.Size = Vector3.new(7, 7, 7)
	hitbox.Shape = Enum.PartType.Ball
	hitbox.Transparency = 0.7
	hitbox.Color = Color3.fromRGB(255, 60, 60)
	hitbox.CanCollide = false
	hitbox.Anchored = true
	hitbox.CFrame = root.CFrame * CFrame.new(0, 0, -4)
	CollectionService:AddTag(hitbox, "HITBOX")
	CollectionService:AddTag(hitbox, "NPC_HITBOX")
	hitbox.Parent = workspace

	task.delay(duration, function()
		if hitbox then
			hitbox:Destroy()
		end
	end)
end

---------------------------------------------------------------------

local function activateEnemyAI(enemyModel: Model)
	local humanoid = enemyModel:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	if not humanoid or not animator then
		return
	end

	local lastAttack = 0

	-- Load animations
	local moveAnim = Instance.new("Animation")
	moveAnim.AnimationId = MOVE_ANIM_ID
	local moveTrack = animator:LoadAnimation(moveAnim)
	moveTrack.Priority = Enum.AnimationPriority.Movement
	moveTrack.Looped = false

	local attackAnim = Instance.new("Animation")
	attackAnim.AnimationId = ATTACK_ANIM_ID
	local attackTrack = animator:LoadAnimation(attackAnim)
	attackTrack.Priority = Enum.AnimationPriority.Action

	local connection
	connection = game:GetService("RunService").Heartbeat:Connect(function()
		if humanoid.Health <= 0 or not enemyModel.Parent then
			connection:Disconnect()
			return
		end

		-- Tìm player gần nhất
		local closestPlayer = nil
		local closestDist = DETECTION_RANGE

		for _, p in Players:GetPlayers() do
			local char = p.Character
			if char and char.PrimaryPart then
				local dist = (char.PrimaryPart.Position - enemyModel.PrimaryPart.Position).Magnitude
				if dist < closestDist then
					closestDist = dist
					closestPlayer = p
				end
			end
		end

		if closestPlayer and closestPlayer.Character and closestPlayer.Character.PrimaryPart then
			local playerRoot = closestPlayer.Character.PrimaryPart
			local dist = closestDist

			if dist > ATTACK_RANGE then
				-- NPC đang di chuyển → CHẠY ANIMATION MOVE
				humanoid:MoveTo(playerRoot.Position)

				if not moveTrack.IsPlaying then
					moveTrack:Play()
				end
			else
				-- NPC gần player → TẤN CÔNG
				humanoid:MoveTo(enemyModel.PrimaryPart.Position)

				-- Dừng animation chạy
				if moveTrack.IsPlaying then
					moveTrack:Stop()
				end

				local now = tick()
				if now - lastAttack >= ATTACK_COOLDOWN then
					lastAttack = now

					attackTrack:Play()

					task.wait(0.3)

					createTimedHitbox(enemyModel, 0.1)
				end
			end
		else
			-- Không có player nào
			humanoid:MoveTo(enemyModel.PrimaryPart.Position)
			if moveTrack.IsPlaying then
				moveTrack:Stop()
			end
		end
	end)
end

---------------------------------------------------------------------

local system = {}

function system:_Setup()
	for _, inst in CollectionService:GetTagged(ENEMY_TAG) do
		if inst:IsA("Model") then
			activateEnemyAI(inst)
		end
	end
end

function system:_Start()
	CollectionService:GetInstanceAddedSignal(ENEMY_TAG):Connect(function(inst)
		if inst:IsA("Model") then
			activateEnemyAI(inst)
		end
	end)
end

return system
