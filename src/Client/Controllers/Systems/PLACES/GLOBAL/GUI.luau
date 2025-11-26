--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local camera = Workspace.CurrentCamera

local Player = Players.LocalPlayer
local OtherPlayers = {}
local PlayerGUIFolder = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Assets")

export type GUI = {
	__index: GUI,
	HealthGui: BillboardGui,
	PowGui: BillboardGui,
	NameGui: BillboardGui,
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
	local nameTemplate = guiFolder:WaitForChild("Playername") :: BillboardGui

	self.HealthGui = healthTemplate:Clone()
	self.HealthBar = self.HealthGui:WaitForChild("Frame") :: Frame

	self.PowGui = powTemplate:Clone()
	self.PowBar = self.PowGui:WaitForChild("Frame") :: Frame

	self.NameGui = nameTemplate:Clone()

	self.Connections = {}

	-- Gắn GUI cho người chơi khác
	for _, other in ipairs(Players:GetPlayers()) do
		if other ~= Player and other.Character then
			self:AttachToCharacter(other.Character)
		end

		table.insert(
			self.Connections,
			other.CharacterAdded:Connect(function(character)
				if other ~= Player then
					character:WaitForChild("Head")
					self:AttachToCharacter(character)
				end
			end)
		)
	end

	-- Khi có người mới tham gia server
	table.insert(
		self.Connections,
		Players.PlayerAdded:Connect(function(other)
			if other ~= Player then
				other.CharacterAdded:Connect(function(character)
					character:WaitForChild("Head")
					self:AttachToCharacter(character)
				end)
			end
		end)
	)

	return self
end

-- Gắn GUI vào nhân vật
function GUIClass:AttachToCharacter(character: Model)
	if not character or not character:FindFirstChild("Head") then
		character:WaitForChild("Head")
	end

	local head = character:FindFirstChild("Head") or character:WaitForChild("Head")
	local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid")
	local owner = Players:GetPlayerFromCharacter(character)

	-- Clone GUI mới cho từng nhân vật
	local healthGui = self.HealthGui:Clone()
	local powGui = self.PowGui:Clone()
	local nameGui = self.NameGui:Clone()

	local healthBar = healthGui:WaitForChild("Frame") :: Frame
	local powBar = powGui:WaitForChild("Frame") :: Frame
	local nameLabel = nameGui:WaitForChild("NameLabel") :: TextLabel

	-- Gắn GUI vào đầu nhân vật
	healthGui.Parent = head
	powGui.Parent = head
	nameGui.Parent = head

	-- Hiển thị tên người chơi
	if owner then
		nameLabel.Text = owner.DisplayName or owner.Name
	else
		nameLabel.Text = character.Name
	end

	-- Cập nhật máu lần đầu
	local function updateHealth()
		local health = humanoid.Health
		local maxHealth = humanoid.MaxHealth
		local percent = math.clamp(health / maxHealth, 0, 1)
		healthBar.Size = UDim2.new(percent, 0, 1, 0)

		local color
		if percent > 0.5 then
			color = Color3.fromRGB(0, 255, 0)
		elseif percent > 0.25 then
			color = Color3.fromRGB(255, 255, 0)
		else
			color = Color3.fromRGB(255, 0, 0)
		end
		healthBar.BackgroundColor3 = color
	end

	humanoid.HealthChanged:Connect(updateHealth)
	humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(updateHealth)
	updateHealth()
end

-- Cập nhật thanh máu (cho instance chính của local player)
function GUIClass:UpdateHealth(humanoid: Humanoid)
	local health = humanoid.Health
	local maxHealth = humanoid.MaxHealth
	local percent = math.clamp(health / maxHealth, 0, 1)

	self.HealthBar.Size = UDim2.new(percent, 0, 1, 0)

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
	if self.NameGui then
		self.NameGui:Destroy()
	end
end

return GUIClass
