--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Openday = require(ReplicatedStorage.Shared.Openday)

export type System = {
	_Extensions: { Openday.Extension },
	_Start: (self: System) -> (),
	_Setup: (self: System) -> (),
}

local Dash = {
	_Extensions = {},
} :: System

local RS = game:GetService("ReplicatedStorage")
local VfxFolder = RS.Shared.Assets:WaitForChild("VFX")
local DashClone = VfxFolder:WaitForChild("DashClone")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local TweenService = game:GetService("TweenService")

local Player = game.Players.LocalPlayer
local Char = Player.Character or Player.CharacterAdded:Wait()

local Hum = Char:WaitForChild("Humanoid")
local HRP = Char:WaitForChild("HumanoidRootPart")

local WKeyDown = false
local AKeyDown = false
local SKeyDown = false
local DKeyDown = false

local DashDeb = false
local DashTime = 0.5

local AnimationFolder = RS.Shared.Assets:WaitForChild("Animations")

local ForwardDashAnime = Hum:LoadAnimation(AnimationFolder:WaitForChild("ForwardDash"))
local BackDashAnime = Hum:LoadAnimation(AnimationFolder:WaitForChild("BackDash"))
local LeftDashAnime = Hum:LoadAnimation(AnimationFolder:WaitForChild("LeftDash"))
local RightDashAnime = Hum:LoadAnimation(AnimationFolder:WaitForChild("RightDash"))

local Client = require(RS.Shared.Network.Client)

UIS.InputBegan:Connect(function(Key, IsTyping)
	if IsTyping then
		return
	end
	if Key.KeyCode == Enum.KeyCode.Q then
		if DashDeb == false and Char:FindFirstChild("Deb") == nil then
			DashDeb = true
			delay(DashTime + 0.7, function()
				DashDeb = false
			end)
			if WKeyDown then
				coroutine.wrap(function()
					DashEffect()
				end)()
				local Tween = TweenService:Create(
					HRP,
					TweenInfo.new(DashTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{ Velocity = HRP.CFrame.LookVector * 70 }
				)
				Tween:Play()
				ForwardDashAnime:Play()
				Client.Player_Action.Fire("DASH", true)
				delay(DashTime + 0.1, function()
					ForwardDashAnime:Stop()
				end)
			elseif AKeyDown then
				coroutine.wrap(function()
					DashEffect()
				end)()
				local Tween = TweenService:Create(
					HRP,
					TweenInfo.new(DashTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{ Velocity = HRP.CFrame.RightVector * -70 }
				)
				Tween:Play()
				LeftDashAnime:Play()
				Client.Player_Action.Fire("DASH", true)
				delay(DashTime + 0.1, function()
					LeftDashAnime:Stop()
				end)
			elseif SKeyDown then
				coroutine.wrap(function()
					DashEffect()
				end)()
				local Tween = TweenService:Create(
					HRP,
					TweenInfo.new(DashTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{ Velocity = HRP.CFrame.LookVector * -70 }
				)
				Tween:Play()
				BackDashAnime:Play()
				Client.Player_Action.Fire("DASH", true)
				delay(DashTime + 0.1, function()
					BackDashAnime:Stop()
				end)
			elseif DKeyDown then
				coroutine.wrap(function()
					DashEffect()
				end)()
				local Tween = TweenService:Create(
					HRP,
					TweenInfo.new(DashTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{ Velocity = HRP.CFrame.RightVector * 70 }
				)
				Tween:Play()
				RightDashAnime:Play()
				Client.Player_Action.Fire("DASH", true)
				delay(DashTime + 0.1, function()
					RightDashAnime:Stop()
				end)
			end
		end
	end
end)

RunService.RenderStepped:Connect(function()
	if UIS:IsKeyDown(Enum.KeyCode.W) then
		WKeyDown = true
	else
		WKeyDown = false
	end
	if UIS:IsKeyDown(Enum.KeyCode.A) then
		AKeyDown = true
	else
		AKeyDown = false
	end
	if UIS:IsKeyDown(Enum.KeyCode.S) then
		SKeyDown = true
	else
		SKeyDown = false
	end
	if UIS:IsKeyDown(Enum.KeyCode.D) then
		DKeyDown = true
	else
		DKeyDown = false
	end
end)

function DashEffect()
	for i = 1, 7 do
		local Clone = DashClone:Clone()
		Clone:SetPrimaryPartCFrame(HRP.CFrame)
		Clone.Parent = workspace
		game.Debris:AddItem(Clone, 0.5)
		spawn(function()
			for i, v in pairs(Clone:GetChildren()) do
				spawn(function()
					if v:IsA("MeshPart") or v:IsA("Part") then
						v.CFrame = Char:FindFirstChild(v.Name).CFrame
						for i = 0.25, 1, 0.1 do
							v.Transparency = i
							v.Reflectance = i
							wait()
						end
						Clone:Destroy()
					end
				end)
			end
		end)
		wait(0.05)
	end
end

return Dash
