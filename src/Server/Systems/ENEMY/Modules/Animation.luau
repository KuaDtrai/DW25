--!strict
local Players = game:GetService("Players")

export type AnimationController = {
	__index: AnimationController,
	new: (npcModel: Model) -> AnimationController,
	Destroy: (self: AnimationController) -> (),
}

local Class: AnimationController = {} :: AnimationController
Class.__index = Class

-- Cache animation track theo NPC
type TrackCache = {
	[string]: AnimationTrack,
}

function Class.new(npcModel: Model): AnimationController
	local self = setmetatable({}, Class) :: any

	self.npcModel = npcModel

	self.humanoid = npcModel:FindFirstChildOfClass("Humanoid")
	if not self.humanoid then
		error("NPC has no Humanoid")
	end

	self.animator = self.humanoid:FindFirstChildOfClass("Animator")
	if not self.animator then
		self.animator = Instance.new("Animator")
		self.animator.Parent = self.humanoid
	end

	self.tracks = {} :: TrackCache
	self.currentState = nil

	-- Listen State
	self._stateConn = npcModel:GetAttributeChangedSignal("State"):Connect(function()
		self:_onStateChanged()
	end)

	-- Listen OnStop
	self._stopConn = npcModel:GetAttributeChangedSignal("IsStop"):Connect(function()
		warn("OnStop changed")
		self:_onStopChanged()
	end)

	-- 🔥 Kick lần đầu
	self:_onStateChanged()

	return self
end

-- =========================
-- State handling
-- =========================

function Class:_onStateChanged()
	local newState = self.npcModel:GetAttribute("State")
	if newState == self.currentState then
		return
	end

	self.currentState = newState
	self:_playByState(newState)
end

function Class:_onStopChanged()
	local onStop = self.npcModel:GetAttribute("IsStop")
	if onStop == true then
		self:_playStop()
	else
		-- quay lại animation theo state hiện tại
		self:_playByState(self.currentState)
	end
end

-- =========================
-- Play logic
-- =========================

function Class:_playByState(state: string?)
	-- ⚠️ Stop animation có độ ưu tiên cao hơn state
	if self.npcModel:GetAttribute("IsStop") == true then
		return
	end

	self:_stopAll()

	if state == "Patrol" or state == "None" then
		self:_playLoop("Animation-Patrol")
	elseif state == "Sight" then
		self:_playLoop("Animation-Run")
	elseif state == "Approach" then
		self:_playLoop("Animation-Approach")
	elseif state == "Attack" then
		self:_playOnce("Animation-Attack")
	end
end

function Class:_playStop()
	self:_stopAll()
	warn("Playing Stop Animation")
	local animId = self.npcModel:GetAttribute("Animation-Stop")
	if typeof(animId) ~= "string" then
		return
	end

	local track = self:_getOrLoad("Animation-Stop", animId)
	track.Looped = true
	track.Priority = Enum.AnimationPriority.Movement
	track:Play(0.05)

	task.delay(track.Length, function()
		if self.npcModel.Parent then
			track:AdjustSpeed(0)
		end
	end)
end

-- =========================
-- Track helpers
-- =========================

function Class:_playLoop(attributeName: string)
	local animId = self.npcModel:GetAttribute(attributeName)
	if typeof(animId) ~= "string" then
		return
	end

	local track = self:_getOrLoad(attributeName, animId)
	track.Looped = true
	track.Priority = Enum.AnimationPriority.Movement
	track:Play(0.2)
end

function Class:_playOnce(attributeName: string)
	local animId = self.npcModel:GetAttribute(attributeName)
	if typeof(animId) ~= "string" then
		return
	end

	local track = self:_getOrLoad(attributeName, animId)
	track.Looped = false
	track.Priority = Enum.AnimationPriority.Action
	track:Play(0.1)
end

function Class:_getOrLoad(key: string, animId: string): AnimationTrack
	if self.tracks[key] then
		return self.tracks[key]
	end

	local anim = Instance.new("Animation")
	anim.AnimationId = animId

	local track = self.animator:LoadAnimation(anim)
	self.tracks[key] = track

	return track
end

function Class:_stopAll()
	for _, track in pairs(self.tracks) do
		if track.IsPlaying then
			track:Stop(0.15)
		end
	end
end

-- =========================
-- Cleanup
-- =========================

function Class:Destroy()
	if self._stateConn then
		self._stateConn:Disconnect()
	end

	if self._stopConn then
		self._stopConn:Disconnect()
	end

	self:_stopAll()
	self.tracks = {}
end

return Class
