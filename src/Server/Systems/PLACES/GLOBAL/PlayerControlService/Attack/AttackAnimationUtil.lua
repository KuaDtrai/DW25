--!strict
local TweenService = game:GetService("TweenService")

local Util = {}

--------------------------------------------------
-- INTERNAL STATE
--------------------------------------------------
local CurrentAttackTrack: { [Model]: AnimationTrack } = {}
local CurrentAttackId: { [Model]: number } = {}

local ATTACK_WALK_SPEED = 5
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
end

--------------------------------------------------
-- PUBLIC API
--------------------------------------------------
function Util.playFixedTime(character: Model, animId: string, attackTime: number, freezeTime: number)
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

		-- 🚨 luôn reset gameplay state
		humanoid.WalkSpeed = NORMAL_WALK_SPEED

		-- animation chỉ là phụ
		if track.IsPlaying then
			track.TimePosition = track.Length
			track:AdjustSpeed(0)
		end

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
