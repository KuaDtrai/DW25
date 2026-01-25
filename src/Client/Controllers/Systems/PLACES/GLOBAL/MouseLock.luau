--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local MouseLockController = {}
MouseLockController.__index = MouseLockController

type Controller = {
	_enabled: boolean,
	_conn: RBXScriptConnection?,
}

-- =====================
-- INTERNAL
-- =====================

local function getCharacter()
	local char = player.Character
	if not char then
		return
	end

	local humanoid = char:FindFirstChildOfClass("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart")

	if humanoid and root then
		return char, humanoid, root
	end
end

local function getYawFromCamera()
	local look = camera.CFrame.LookVector
	return math.atan2(-look.X, -look.Z)
end

-- =====================
-- PUBLIC API
-- =====================

function MouseLockController.new(): Controller
	return setmetatable({
		_enabled = false,
		_conn = nil,
	}, MouseLockController)
end

function MouseLockController:Enable()
	if self._enabled then
		return
	end
	self._enabled = true

	-- khóa chuột
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	UserInputService.MouseIconEnabled = false

	local _, humanoid = getCharacter()
	if humanoid then
		humanoid.AutoRotate = false
	end

	self._conn = RunService.RenderStepped:Connect(function()
		local _, humanoid, root = getCharacter()
		if not humanoid or not root then
			return
		end

		local yaw = getYawFromCamera()
		root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, yaw, 0)
	end)
end

function MouseLockController:Disable()
	if not self._enabled then
		return
	end
	self._enabled = false

	if self._conn then
		self._conn:Disconnect()
		self._conn = nil
	end

	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	UserInputService.MouseIconEnabled = true

	local _, humanoid = getCharacter()
	if humanoid then
		humanoid.AutoRotate = true
	end
end

function MouseLockController:IsEnabled(): boolean
	return self._enabled
end

return MouseLockController
