--!strict
export type Patrol = {
	__index: Patrol,
	new: () -> Patrol,
	DoPatrol: (self: Patrol, npcModel: Model) -> (),
	Destroy: (self: Patrol) -> (),
}

local Class: Patrol = {} :: Patrol
Class.__index = Class

function Class.new(): Patrol
	local self: Patrol = setmetatable({} :: any, Class)
	return self
end

function Class:DoPatrol(npcModel: Model)
	if npcModel:GetAttribute("PatrolLocked") == true then
		return
	end

	local humanoid = npcModel:FindFirstChildOfClass("Humanoid")
	humanoid.WalkSpeed = npcModel:GetAttribute("PatrolSpeed") or 5
	local root = npcModel:FindFirstChild("HumanoidRootPart")
	local spawnerValue = npcModel:FindFirstChild("Spawner")

	if not humanoid or not root or not spawnerValue then
		return
	end

	local spawner = spawnerValue.Value
	if not spawner or not spawner:IsA("BasePart") then
		return
	end

	local patrolRads = npcModel:GetAttribute("PatrolRads")
	if typeof(patrolRads) ~= "number" or patrolRads <= 0 then
		return
	end

	-- Random điểm patrol (>= 90% bán kính)
	local theta = math.random() * math.pi * 2
	local minRadius = patrolRads * 0.9
	local radius = minRadius + math.random() * (patrolRads - minRadius)

	local offset = Vector3.new(math.cos(theta) * radius, 0, math.sin(theta) * radius)

	local targetPos = spawner.Position + offset

	-- Lock patrol
	npcModel:SetAttribute("PatrolLocked", true)
	npcModel:SetAttribute("State", "Patrol")

	humanoid:MoveTo(targetPos)

	local conn
	conn = humanoid.MoveToFinished:Connect(function()
		if conn then
			conn:Disconnect()
		end
		-- ⏳ Đứng yên 2 giây rồi mới patrol tiếp
		npcModel:SetAttribute("IsStop", true)

		task.delay(math.random(1, 3), function()
			if npcModel.Parent then
				npcModel:SetAttribute("IsStop", false)
				npcModel:SetAttribute("State", "Idle")
				npcModel:SetAttribute("PatrolLocked", false)
			end
		end)
	end)
end

function Class:Destroy() end

return Class
