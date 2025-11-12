--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local camera = Workspace.CurrentCamera

local Player = Players.LocalPlayer
local PlayerGUIFolder = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Assets")

export type GUI = {
	__index: GUI,
	HealthGui: BillboardGui,
	PowGui: BillboardGui,
	HealthBar: Frame,
	PowBar: Frame,
	Connections: { RBXScriptConnection },
	new: () -> GUI,
	AttachToCharacter: (self: GUI, character: Model) -> (),
	UpdateHealth: (self: GUI, humanoid: Humanoid) -> (),
	Destroy: (self: GUI) -> (),
}

local GUIClass = {} :: GUI
GUIClass.__index = GUIClass

-- Khởi tạo GUI cho người chơi
function GUIClass.new(): GUI
	local self = setmetatable({} :: any, GUIClass)

	local guiFolder = PlayerGUIFolder:WaitForChild("PlayerGUI")
	local healthTemplate = guiFolder:WaitForChild("Health") :: BillboardGui
	local powTemplate = guiFolder:WaitForChild("Pow") :: BillboardGui

	-- Clone để mỗi nhân vật có bản riêng
	self.HealthGui = healthTemplate:Clone()
	self.HealthBar = self.HealthGui:WaitForChild("Frame") :: Frame

	self.PowGui = powTemplate:Clone()
	self.PowBar = self.PowGui:WaitForChild("Frame") :: Frame

	self.Connections = {}

	-- Khi nhân vật được spawn
	table.insert(
		self.Connections,
		Player.CharacterAdded:Connect(function(character)
			self:AttachToCharacter(character)
			camera.CameraSubject = character.Head
		end)
	)

	-- Nếu nhân vật đã tồn tại (respawn nhanh)

	if Player.Character then
		camera.CameraSubject = Player.Character.LowerTorso
		self:AttachToCharacter(Player.Character)
	end

	return self
end

-- Gắn GUI vào nhân vật mới
function GUIClass:AttachToCharacter(character: Model)
	local head = character:WaitForChild("Head")
	local humanoid = character:WaitForChild("Humanoid")

	self.HealthGui.Parent = head
	self.PowGui.Parent = head

	-- Cập nhật lần đầu
	self:UpdateHealth(humanoid)

	-- Kết nối sự kiện
	table.insert(
		self.Connections,
		humanoid.HealthChanged:Connect(function()
			self:UpdateHealth(humanoid)
		end)
	)

	table.insert(
		self.Connections,
		humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function()
			self:UpdateHealth(humanoid)
		end)
	)
end

-- Cập nhật thanh máu
function GUIClass:UpdateHealth(humanoid: Humanoid)
	local health = humanoid.Health
	local maxHealth = humanoid.MaxHealth
	local percent = math.clamp(health / maxHealth, 0, 1)

	self.HealthBar.Size = UDim2.new(percent, 0, 1, 0)

	-- Đổi màu theo % máu
	local color
	if percent > 0.5 then
		color = Color3.fromRGB(0, 255, 0)
	elseif percent > 0.25 then
		color = Color3.fromRGB(255, 255, 0)
	else
		color = Color3.fromRGB(255, 0, 0)
	end
	self.HealthBar.BackgroundColor3 = color
end

-- Hủy GUI và ngắt kết nối
function GUIClass:Destroy()
	for _, conn in ipairs(self.Connections) do
		conn:Disconnect()
	end
	self.Connections = {}

	if self.HealthGui then
		self.HealthGui:Destroy()
	end
	if self.PowGui then
		self.PowGui:Destroy()
	end
end

return GUIClass
