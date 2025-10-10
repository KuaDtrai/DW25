--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local MapFolder = workspace:WaitForChild("MapFolder")

export type Minimap = {
	__index: Minimap,
	new: () -> Minimap,
	Destroy: (self: Minimap) -> (),
}

local Class: Minimap = {} :: Minimap
Class.__index = Class

function Class.new(): Minimap
	local self: Minimap = setmetatable({} :: any, Class)

	local hrp = Character:WaitForChild("HumanoidRootPart")

	local playerGui = Player:WaitForChild("PlayerGui")
	local minimapGui = playerGui:WaitForChild("Minimap") :: ScreenGui
	local frame = minimapGui:WaitForChild("MapFrame") :: ViewportFrame
	local playerIcon = frame:WaitForChild("ImageLabel") :: ImageLabel

	local camera = Instance.new("Camera")
	camera.CameraType = Enum.CameraType.Scriptable
	camera.FieldOfView = 1
	frame.CurrentCamera = camera

	for _, object in ipairs(MapFolder:GetChildren()) do
		local clone = object:Clone()
		clone.Parent = frame
	end

	RunService.RenderStepped:Connect(function()
		camera.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 2500, 0), hrp.Position)
		playerIcon.Rotation = -hrp.Orientation.Y
	end)

	self.hrp = hrp
	self.Camera = camera
	self.Frame = frame
	self.PlayerDirect = playerIcon

	return self
end

function Class:Destroy()
	self.Camera:Destroy()
end

return Class
