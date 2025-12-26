--!strict
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game.Workspace
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ENEMY_TAG = "ENEMY"

local DETECTION_RANGE = 50
local ATTACK_RANGE = 6
local ATTACK_COOLDOWN = 1.5
local ATTACK_PREPARE_TIME = 0.25

local MOVE_ANIM = "rbxassetid://126918793505286"
local ATTACK_ANIM = "rbxassetid://93630352572586"

local WeaponsFolder = ReplicatedStorage.Shared.Assets.Weapon

--------------------------------------------------------
-- DROP WEAPON
--------------------------------------------------------
local function dropRandomWeapon(cframe: CFrame)
	if not WeaponsFolder then
		return
	end

	local list = WeaponsFolder:GetChildren()
	if #list == 0 then
		return
	end

	local w = list[math.random(1, #list)]:Clone()

	local origin = cframe.Position
	local ray = workspace:Raycast(origin, Vector3.new(0, -20, 0))

	local y = ray and ray.Position.Y or origin.Y - 3

	local finalCF = CFrame.new(origin.X, y + 0.2, origin.Z) * CFrame.Angles(0, math.rad(math.random(0, 360)), 0)

	if w:IsA("Model") then
		w:PivotTo(finalCF)
	else
		w.CFrame = finalCF
	end

	w.Parent = workspace
end

--------------------------------------------------------
-- CREATE HITBOX
--------------------------------------------------------
local function createHitbox(enemy: Model, duration: number)
	local root = enemy:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	local part = Instance.new("Part")
	part.Name = "EnemyHitbox"
	part.Size = Vector3.new(7, 7, 7)
	part.Shape = Enum.PartType.Ball
	part.Transparency = 1
	part.CanCollide = false
	part.Anchored = true
	part.CFrame = root.CFrame * CFrame.new(0, 0, -4)

	CollectionService:AddTag(part, "HITBOX")
	CollectionService:AddTag(part, "NPC_HITBOX")
	part.Parent = workspace

	task.delay(duration, function()
		if part then
			part:Destroy()
		end
	end)
end

--------------------------------------------------------
-- ENEMY AI
--------------------------------------------------------
local function activateAI(enemy: Model)
	local humanoid = enemy:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		return
	end

	local moveAnim = Instance.new("Animation")
	moveAnim.AnimationId = MOVE_ANIM
	local moveTrack = animator:LoadAnimation(moveAnim)
	moveTrack.Priority = Enum.AnimationPriority.Movement

	local atkAnim = Instance.new("Animation")
	atkAnim.AnimationId = ATTACK_ANIM
	local atkTrack = animator:LoadAnimation(atkAnim)
	atkTrack.Priority = Enum.AnimationPriority.Action

	local lastAttackTime = 0
	local currentState = "IDLE"

	humanoid.AutoRotate = true

	--------------------------------------------------------
	-- STATE HANDLERS
	--------------------------------------------------------
	local function rotateTowards(targetPos: Vector3)
		local root = enemy.PrimaryPart
		if not root then
			return
		end

		local lookCF = CFrame.lookAt(root.Position, targetPos)
		local _, y, _ = lookCF:ToEulerAnglesYXZ()

		enemy:SetPrimaryPartCFrame(CFrame.new(root.Position) * CFrame.Angles(0, y, 0))
	end

	local function doAttack(targetRoot: BasePart)
		currentState = "ATTACK"

		-- Khóa xoay
		humanoid.AutoRotate = false

		-- Hướng về player một lần
		rotateTowards(targetRoot.Position)

		atkTrack:Play()

		task.wait(ATTACK_PREPARE_TIME)
		createHitbox(enemy, 0.12)

		task.wait(0.2)
		humanoid.AutoRotate = true
		currentState = "IDLE"
	end

	--------------------------------------------------------
	-- MAIN LOOP (0.1s)
	--------------------------------------------------------
	task.spawn(function()
		while enemy.Parent and humanoid.Health > 0 do
			task.wait(0.05)

			-- DEAD → DROP + DELETE
			if humanoid.Health <= 0 then
				local root = enemy:FindFirstChild("HumanoidRootPart")
				if root then
					dropRandomWeapon(root.CFrame)
				end

				for _, obj in ipairs(enemy:GetDescendants()) do
					if obj:IsA("BasePart") or obj:IsA("MeshPart") then
						obj:Destroy()
					end
				end
				return
			end

			--------------------------------------------------------
			-- FIND NEAREST PLAYER
			--------------------------------------------------------
			local nearest = nil
			local nearestDist = DETECTION_RANGE

			for _, plr in Players:GetPlayers() do
				local char = plr.Character
				if char and char.PrimaryPart then
					local dist = (char.PrimaryPart.Position - enemy.PrimaryPart.Position).Magnitude
					if dist < nearestDist then
						nearestDist = dist
						nearest = char
					end
				end
			end

			if not nearest then
				currentState = "IDLE"
				continue
			end

			local charRoot = nearest.PrimaryPart
			local distance = nearestDist

			--------------------------------------------------------
			-- CHASE
			--------------------------------------------------------
			if distance > ATTACK_RANGE then
				currentState = "CHASE"

				if not moveTrack.IsPlaying then
					moveTrack:Play()
				end

				humanoid:MoveTo(charRoot.Position)
			end

			--------------------------------------------------------
			-- ATTACK
			--------------------------------------------------------
			if distance <= ATTACK_RANGE then
				moveTrack:Stop()
				humanoid:MoveTo(enemy.PrimaryPart.Position)

				local now = tick()
				if now - lastAttackTime >= ATTACK_COOLDOWN then
					lastAttackTime = now
					doAttack(charRoot)
				end
			end
		end
	end)
end

--------------------------------------------------------
-- SYSTEM
--------------------------------------------------------
local system = {}

function system:_Setup()
	for _, inst in CollectionService:GetTagged(ENEMY_TAG) do
		if inst:IsA("Model") then
			activateAI(inst)
		end
	end
end

function system:_Start()
	CollectionService:GetInstanceAddedSignal(ENEMY_TAG):Connect(function(inst)
		if inst:IsA("Model") then
			activateAI(inst)
		end
	end)
end

return system
