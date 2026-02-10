--!strict
----------------------------------------------------------------
-- SERVICES
----------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

----------------------------------------------------------------
-- MODULE
----------------------------------------------------------------
local Dash = {}
Dash.__index = Dash

----------------------------------------------------------------
-- PLAYER
----------------------------------------------------------------
local Player = Players.LocalPlayer

----------------------------------------------------------------
-- CONFIG
----------------------------------------------------------------
local DASH_TIME = 0.3
local DASH_FORCE = 70
local DASH_COOLDOWN = 0.7

----------------------------------------------------------------
-- INPUT STATE
----------------------------------------------------------------
local W, A, S, D = false, false, false, false
local DashDebounce = false

----------------------------------------------------------------
-- CHARACTER REFERENCES
----------------------------------------------------------------
local Character: Model? = nil
local Humanoid: Humanoid? = nil
local HRP: BasePart? = nil

----------------------------------------------------------------
-- ASSETS
----------------------------------------------------------------
local RS = ReplicatedStorage
local VfxFolder = RS:WaitForChild("VfxFolder")
local DashCloneTemplate = VfxFolder:WaitForChild("DashClone")

local AnimFolder = RS.Shared.Assets.Animations

----------------------------------------------------------------
-- DASH ANIMATIONS (LOAD THEO HỆ CŨ)
----------------------------------------------------------------
local ForwardDash: AnimationTrack? = nil
local BackDash: AnimationTrack? = nil
local LeftDash: AnimationTrack? = nil
local RightDash: AnimationTrack? = nil

local CurrentDashTrack: AnimationTrack? = nil

----------------------------------------------------------------
-- BIND CHARACTER (RESPAWN SAFE)
----------------------------------------------------------------
local function BindCharacter(char: Model)
	Character = char
	Humanoid = char:WaitForChild("Humanoid")
	HRP = char:WaitForChild("HumanoidRootPart")

	ForwardDash = Humanoid:LoadAnimation(AnimFolder:WaitForChild("ForwardDash"))
	BackDash = Humanoid:LoadAnimation(AnimFolder:WaitForChild("BackDash"))
	LeftDash = Humanoid:LoadAnimation(AnimFolder:WaitForChild("LeftDash"))
	RightDash = Humanoid:LoadAnimation(AnimFolder:WaitForChild("RightDash"))
end

if Player.Character then
	BindCharacter(Player.Character)
end

Player.CharacterAdded:Connect(BindCharacter)

----------------------------------------------------------------
-- INPUT TRACK
----------------------------------------------------------------
RunService.RenderStepped:Connect(function()
	W = UserInputService:IsKeyDown(Enum.KeyCode.W)
	A = UserInputService:IsKeyDown(Enum.KeyCode.A)
	S = UserInputService:IsKeyDown(Enum.KeyCode.S)
	D = UserInputService:IsKeyDown(Enum.KeyCode.D)
end)

----------------------------------------------------------------
-- DASH EFFECT (CLONE ANIM THEO DASH)
----------------------------------------------------------------
local function DashEffect()
	if not Character or not HRP or not CurrentDashTrack then
		return
	end

	for _ = 1, 7 do
		if not Character then
			return
		end

		local clone = DashCloneTemplate:Clone()
		clone:SetPrimaryPartCFrame(HRP.CFrame)
		clone.Parent = workspace
		Debris:AddItem(clone, 0.5)

		-- Gắn humanoid giả để play animation
		local hum = Instance.new("Humanoid")
		hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		hum.Parent = clone

		local anim = Instance.new("Animation")
		anim.AnimationId = CurrentDashTrack.Animation.AnimationId

		local track = hum:LoadAnimation(anim)
		track.TimePosition = CurrentDashTrack.TimePosition
		track:Play()

		task.spawn(function()
			for _, part in ipairs(clone:GetChildren()) do
				if part:IsA("BasePart") then
					part.Anchored = true
					part.CanCollide = false
					for t = 0.25, 1, 0.1 do
						part.Transparency = t
						part.Reflectance = t
						task.wait()
					end
				end
			end
			clone:Destroy()
		end)

		task.wait(0.05)
	end
end

----------------------------------------------------------------
-- PUBLIC DASH
----------------------------------------------------------------
function Dash:DoDash()
	if DashDebounce or not Character or not Humanoid or not HRP then
		return
	end

	if Character:FindFirstChild("Deb") then
		return
	end

	DashDebounce = true
	task.delay(DASH_TIME + DASH_COOLDOWN, function()
		DashDebounce = false
	end)

	local dashDir: Vector3
	local dashTrack: AnimationTrack

	if W then
		dashDir = HRP.CFrame.LookVector
		dashTrack = ForwardDash
	elseif S then
		dashDir = -HRP.CFrame.LookVector
		dashTrack = BackDash
	elseif A then
		dashDir = -HRP.CFrame.RightVector
		dashTrack = LeftDash
	elseif D then
		dashDir = HRP.CFrame.RightVector
		dashTrack = RightDash
	else
		dashDir = HRP.CFrame.LookVector
		dashTrack = ForwardDash
	end

	if not dashTrack then
		return
	end

	CurrentDashTrack = dashTrack

	task.spawn(DashEffect)

	TweenService:Create(
		HRP,
		TweenInfo.new(DASH_TIME, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
		{ Velocity = dashDir * DASH_FORCE }
	):Play()

	dashTrack:Play()
	task.delay(DASH_TIME + 0.1, function()
		dashTrack:Stop()
	end)
end

----------------------------------------------------------------
-- INPUT (Q)
----------------------------------------------------------------
UserInputService.InputBegan:Connect(function(input, typing)
	if typing then
		return
	end
	if input.KeyCode == Enum.KeyCode.Q then
		Dash:DoDash()
	end
end)

return Dash
