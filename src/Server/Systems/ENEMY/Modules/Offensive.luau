--!strict
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

export type offensive = {
	__index: offensive,
	new: () -> offensive,
	Destroy: (self: offensive) -> (),
}
local Class: offensive = {} :: offensive
Class.__index = Class

function Class.new(): offensive
	local self: offensive = setmetatable({} :: any, Class)
	return self
end

local MovementConnections = {} :: {
	[Model]: RBXScriptConnection?,
}

local function createHitbox(enemy: Model, duration: number)
	local root = enemy:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	local part = Instance.new("Part")
	part.Name = "EnemyHitbox"
	part.Size = Vector3.new(3, 3, 7)
	part.Shape = Enum.PartType.Block
	part.CanTouch = false
	part.Transparency = 1
	part.CanCollide = false
	part.Anchored = true
	part.CFrame = root.CFrame * CFrame.new(0, 0, -7)
	CollectionService:AddTag(part, "HITBOX")
	CollectionService:AddTag(part, "NPC_HITBOX")

	part:SetAttribute("Damage", enemy:GetAttribute("Damage"))
	part.Parent = workspace

	Debris:AddItem(part, duration + 0.1)

	task.delay(duration * 70 / 100, function()
		part.CanTouch = true
	end)

	task.delay(duration, function()
		enemy:SetAttribute("State", "None")
	end)
end

local function EnterRun(humanoid: Humanoid, target: Model)
	local npc = humanoid.Parent
	if not target or not target.PrimaryPart then
		return
	end

	-- clear connection cũ
	if MovementConnections[npc] then
		MovementConnections[npc]:Disconnect()
	end

	local speedRange = npc:GetAttribute("Speed") :: NumberRange
	humanoid.WalkSpeed = speedRange.Max - math.random(0, 10)

	MovementConnections[npc] = RunService.Heartbeat:Connect(function()
		if not target.PrimaryPart or humanoid.Health <= 0 then
			return
		end

		humanoid:MoveTo(target.PrimaryPart.Position)
	end)
end

local function EnterWalk(humanoid: Humanoid, target: Model)
	local npc = humanoid.Parent
	if not target or not target.PrimaryPart then
		return
	end

	if MovementConnections[npc] then
		MovementConnections[npc]:Disconnect()
	end

	local speedRange = npc:GetAttribute("Speed") :: NumberRange
	humanoid.WalkSpeed = speedRange.Min

	MovementConnections[npc] = RunService.Heartbeat:Connect(function()
		if not target.PrimaryPart or humanoid.Health <= 0 then
			return
		end

		humanoid:MoveTo(target.PrimaryPart.Position)
	end)
end

local function EnterAttack(humanoid: Humanoid, target: Model)
	local npc = humanoid.Parent

	-- dừng di chuyển
	if MovementConnections[npc] then
		MovementConnections[npc]:Disconnect()
		MovementConnections[npc] = nil
	end

	humanoid:Move(Vector3.zero)
	humanoid.WalkSpeed = 0
	-- tạo hitbox (ví dụ tồn tại 0.3s)
	createHitbox(npc, 1)
end

function Class:DoOffensive(npcModel)
	local state = npcModel:GetAttribute("State")
	local humanoid = npcModel:FindFirstChildOfClass("Humanoid")
	local targetValue = npcModel:FindFirstChild("TargetPlayer").Value.Character

	npcModel:GetAttributeChangedSignal("State"):Connect(function()
		state = npcModel:GetAttribute("State")
		if state ~= "Sight" and state ~= "Approach" and state ~= "Attack" then
			MovementConnections[npcModel]:Disconnect()
		end
	end)

	if state == "Sight" then
		EnterRun(humanoid, targetValue)
	elseif state == "Approach" then
		EnterWalk(humanoid, targetValue)
	elseif state == "Attack" then
		EnterAttack(humanoid, targetValue)
	end
end

function Class:DestroyNPC() end

return Class
