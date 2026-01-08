--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

export type TargetState = "None" | "Sight" | "Approach" | "Attack"

export type TargetResult = {
	player: Player?,
	state: TargetState,
	distance: number?,
}

export type Target = {
	__index: Target,
	new: (npcModel: Model) -> Target,
	Targeting: (self: Target, npcModel: Model) -> TargetResult,
	Destroy: (self: Target) -> (),
}

local Class: Target = {} :: Target
Class.__index = Class

function Class.new(npcModel: Model): Target
	local self: Target = setmetatable({} :: any, Class)

	RunService.Heartbeat:Connect(function(deltaTime)
		self.NPC = npcModel
		local result = self.Targeting(npcModel)

		local target_player = result.player
	end)

	return self
end

function Class.Targeting(npcModel: Model): TargetResult
	local root = npcModel:FindFirstChild("HumanoidRootPart")
	if not root then
		npcModel:SetAttribute("State", "None")
		return { player = nil, state = "None", distance = nil }
	end

	-- Lấy bán kính từ Attribute
	local sightRads = npcModel:GetAttribute("SightRads")
	local approachRads = npcModel:GetAttribute("ApproachRads")
	local attackRads = npcModel:GetAttribute("AttackRads")

	if typeof(sightRads) ~= "number" or typeof(approachRads) ~= "number" or typeof(attackRads) ~= "number" then
		warn("NPC missing radius attributes:", npcModel.Name)
		npcModel:SetAttribute("State", "None")
		return { player = nil, state = "None", distance = nil }
	end

	local closestPlayer: Player? = nil
	local closestDistance = math.huge

	for _, player in Players:GetPlayers() do
		local character = player.Character
		if not character then
			continue
		end

		local hrp = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not hrp or not humanoid or humanoid.Health <= 0 then
			continue
		end

		local distance = (hrp.Position - root.Position).Magnitude
		if distance < closestDistance then
			closestDistance = distance
			closestPlayer = player
		end
	end

	local state: TargetState = "None"

	if closestPlayer and closestDistance <= sightRads then
		local targetValue = npcModel:FindFirstChild("TargetPlayer") :: ObjectValue
		if not targetValue then
			targetValue = Instance.new("ObjectValue")
			targetValue.Name = "TargetPlayer"
			targetValue.Value = closestPlayer
			targetValue.Parent = npcModel
		else
			targetValue.Value = closestPlayer
		end
		if closestDistance <= attackRads then
			state = "Attack"
		elseif closestDistance <= approachRads then
			state = "Approach"
		else
			state = "Sight"
		end
	else
		-- Xoá TargetPlayer nếu có
		local targetValue = npcModel:FindFirstChild("TargetPlayer") :: ObjectValue
		if targetValue then
			targetValue:Destroy()
		end
	end

	-- Set state lên Attribute
	npcModel:SetAttribute("State", state)
	return {
		player = closestPlayer,
		state = state,
		distance = closestPlayer and closestDistance or nil,
	}
end

function Class:Destroy()
	-- cleanup nếu cần
end

return Class
