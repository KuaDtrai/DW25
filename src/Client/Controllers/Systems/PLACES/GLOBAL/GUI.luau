--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local PlayerGUIFolder = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Assets")

export type GUI = {
	__index: GUI,
	Connections: { RBXScriptConnection },
	new: () -> GUI,
	AttachToCharacter: (self: GUI, character: Model) -> (),
	Destroy: (self: GUI) -> (),
}

local GUIClass = {} :: GUI
GUIClass.__index = GUIClass

-- =======================
-- Constructor
-- =======================
function GUIClass.new(): GUI
	local self = setmetatable({}, GUIClass)
	self.Connections = {}

	warn(1)
	-- Gắn cho tất cả player hiện tại (kể cả LocalPlayer)
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character then
			self:AttachToCharacter(player.Character)
		end

		table.insert(
			self.Connections,
			player.CharacterAdded:Connect(function(character)
				self:AttachToCharacter(character)
			end)
		)
	end

	-- Player mới vào
	table.insert(
		self.Connections,
		Players.PlayerAdded:Connect(function(player)
			player.CharacterAdded:Connect(function(character)
				self:AttachToCharacter(character)
			end)
		end)
	)

	return self
end

-- =======================
-- Attach GUI
-- =======================
function GUIClass:AttachToCharacter(character: Model)
	if character:FindFirstChild("PlayerBillboard") then
		return -- tránh gắn trùng
	end

	local head = character:WaitForChild("Head")
	local humanoid = character:WaitForChild("Humanoid")
	local owner = Players:GetPlayerFromCharacter(character)

	local guiFolder = PlayerGUIFolder:WaitForChild("PlayerGUI")
	local healthGui = guiFolder.Health:Clone()
	local powGui = guiFolder.Pow:Clone()
	local nameGui = guiFolder.Playername:Clone()

	-- Đánh dấu để không attach lại
	local tag = Instance.new("Folder")
	tag.Name = "PlayerBillboard"
	tag.Parent = character

	-- Cấu hình chung
	for _, gui in ipairs({ healthGui, powGui, nameGui }) do
		gui.AlwaysOnTop = true
		-- gui.StudsOffset = Vector3.new(0, 2.5, 0)
		gui.Parent = head
	end

	-- Name
	local nameLabel = nameGui:WaitForChild("NameLabel") :: TextLabel
	nameLabel.Text = owner and (owner.DisplayName or owner.Name) or character.Name

	-- Health bar
	local healthBar = healthGui:WaitForChild("Frame") :: Frame

	local function updateHealth()
		local percent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
		healthBar.Size = UDim2.new(percent, 0, 1, 0)
	end

	humanoid.HealthChanged:Connect(updateHealth)
	humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(updateHealth)
	updateHealth()
end

-- =======================
-- Destroy
-- =======================
function GUIClass:Destroy()
	for _, conn in ipairs(self.Connections) do
		conn:Disconnect()
	end
	self.Connections = {}
end

return GUIClass
