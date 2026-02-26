--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FireworksFolder = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Assets"):WaitForChild("Fireworks")

export type FireworkEquipModule = {
	Start: (self: FireworkEquipModule) -> (),
	Destroy: (self: FireworkEquipModule) -> (),
}

local Module = {}
Module.__index = Module

--==============================
-- Utils
--==============================

local function getRandomFirework(): Model?
	local list = FireworksFolder:GetChildren()
	if #list == 0 then
		return nil
	end

	return list[math.random(1, #list)]:Clone()
end

local function attachToBack(character: Model, model: Model)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	local root = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
	if not root then
		return
	end

	local primary = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
	if not primary then
		warn("Firework missing PrimaryPart")
		return
	end

	model.Name = "Firework"
	model.PrimaryPart = primary
	model.Parent = character

	model:SetPrimaryPartCFrame(root.CFrame)

	local motor = Instance.new("Motor6D")
	motor.Name = "FireworkMotor"
	motor.Part0 = root
	motor.Part1 = primary

	motor.C0 = CFrame.new(0, 0, 1)
	motor.C1 = CFrame.new(2, 0, 0) * CFrame.Angles(0, 0, -math.rad(90))

	motor.Parent = root
end

local function giveFirework(player: Player, character: Model)
	if character:FindFirstChild("Firework") then
		return
	end

	local firework = getRandomFirework()
	if not firework then
		return
	end

	attachToBack(character, firework)

	-- bật nút skill
	local playerGui = player:FindFirstChild("PlayerGui")
	if playerGui then
		local hud = playerGui:FindFirstChild("HUD")
		if hud then
			local button = hud:FindFirstChild("Skill_01_BTN")
			if button and button:IsA("ImageButton") then
				button.Visible = true
			end
		end
	end
end

--==============================
-- Module
--==============================

function Module.new(): FireworkEquipModule
	local self = setmetatable({}, Module)
	return self
end

function Module:Start()
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			character:WaitForChild("Humanoid")

			giveFirework(player, character)
		end)
	end)
end

function Module:Destroy()
	-- reserved for cleanup nếu cần sau này
end

return Module
