--!strict
local TweenService = game:GetService("TweenService")

local Util = {}

--------------------------------------------------
-- INTERNAL STATE
--------------------------------------------------
local CurrentAttackTrack: { [Model]: AnimationTrack } = {}
local CurrentAttackId: { [Model]: number } = {}

local ATTACK_WALK_SPEED = 0
local NORMAL_WALK_SPEED = 16

local IsInAttackState: { [Model]: boolean } = {}

--------------------------------------------------
-- STATE
--------------------------------------------------
local function exitAttackState(character: Model)
	if not IsInAttackState[character] then
		return
	end
	IsInAttackState[character] = false

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.AutoRotate = true
		humanoid.WalkSpeed = NORMAL_WALK_SPEED
	end
end

local function forceExitAttack(character: Model)
	-- invalidate toàn bộ delay cũ
	CurrentAttackId[character] = (CurrentAttackId[character] or 0) + 1

	local track = CurrentAttackTrack[character]
	if track then
		track:Stop(0)
	end

	CurrentAttackTrack[character] = nil
	exitAttackState(character)
end

local function enterAttackState(character: Model)
	-- 🚨 Nếu còn attack cũ → huỷ ngay
	if IsInAttackState[character] then
		forceExitAttack(character)
	end

	IsInAttackState[character] = true

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.AutoRotate = false
	end
end

--------------------------------------------------
-- DASH FORWARD (INTERNAL)
--------------------------------------------------
local function dashForward(character: Model, distance: number, duration: number)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end

	-- Huỷ tween cũ
	local oldTween = hrp:FindFirstChild("AttackDashTween")
	if oldTween then
		oldTween:Cancel()
		oldTween:Destroy()
	end

	-- Anti-gravity (chỉ Y)
	local bodyPos = Instance.new("BodyPosition")
	bodyPos.MaxForce = Vector3.new(0, math.huge, 0)
	bodyPos.P = 4000
	bodyPos.D = 800
	bodyPos.Position = hrp.Position
	bodyPos.Parent = hrp

	local startCF = hrp.CFrame
	local forward = Vector3.new(startCF.LookVector.X, 0, startCF.LookVector.Z)
	if forward.Magnitude < 0.01 then
		bodyPos:Destroy()
		return
	end

	forward = forward.Unit
	local targetCF = startCF + forward * distance

	local tween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), { CFrame = targetCF })

	tween.Name = "AttackDashTween"
	tween.Parent = hrp
	tween:Play()

	tween.Completed:Once(function()
		tween:Destroy()
		bodyPos:Destroy()
	end)
end

--------------------------------------------------
-- PUBLIC API
--------------------------------------------------
function Util.playFixedTime(
	character: Model,
	animId: string,
	attackTime: number,
	freezeTime: number,
	dashDistance: number?
)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		return
	end

	-- ✅ FORCE reset trước khi attack mới
	forceExitAttack(character)
	enterAttackState(character)

	CurrentAttackId[character] = (CurrentAttackId[character] or 0) + 1
	local attackId = CurrentAttackId[character]

	local oldTrack = CurrentAttackTrack[character]
	if oldTrack then
		oldTrack:Stop(0)
	end

	--------------------------------------------------
	-- ATTACK PHASE
	--------------------------------------------------
	humanoid.WalkSpeed = ATTACK_WALK_SPEED

	if dashDistance and dashDistance > 0 then
		dashForward(character, dashDistance, attackTime)
	end

	local anim = Instance.new("Animation")
	anim.AnimationId = animId

	local track = animator:LoadAnimation(anim)
	track.Priority = Enum.AnimationPriority.Action
	track:Play(0)

	CurrentAttackTrack[character] = track

	if track.Length > 0 then
		track:AdjustSpeed(track.Length / attackTime)
	end

	--------------------------------------------------
	-- RECOVERY
	--------------------------------------------------
	task.delay(attackTime, function()
		if CurrentAttackId[character] ~= attackId then
			return
		end
		if not track.IsPlaying then
			return
		end

		track.TimePosition = track.Length
		track:AdjustSpeed(0)

		humanoid.WalkSpeed = NORMAL_WALK_SPEED

		task.delay(freezeTime, function()
			if CurrentAttackId[character] ~= attackId then
				return
			end

			if track.IsPlaying then
				track:Stop(0.1)
			end

			CurrentAttackTrack[character] = nil
			exitAttackState(character)
		end)
	end)
end

return Util
