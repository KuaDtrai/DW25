--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Client = require(ReplicatedStorage.Shared.Network.Client)
local Dash = require(script.Parent.Dash)

export type UI = {
	__index: UI,
	new: () -> UI,
	Destroy: (self: UI) -> (),
}
local Class: UI = {} :: UI
Class.__index = Class

function Class.new(): UI
	local self: UI = setmetatable({} :: any, Class)

	self.PlayerGui = Player:WaitForChild("PlayerGui")

	self.MainUI = self.PlayerGui:WaitForChild("HUD") :: ScreenGui
	self.MainUI.Enabled = true

	self.BTN_Attack = self.MainUI:WaitForChild("Attack_BTN") :: ImageButton
	self.BTN_Dash = self.MainUI:WaitForChild("Dash_BTN") :: ImageButton
	self.BTN_Jump = self.MainUI:WaitForChild("Jump_BTN") :: ImageButton
	self.BTN_Skill_01 = self.MainUI:WaitForChild("Skill_01_BTN") :: ImageButton
	self.BTN_Skill_02 = self.MainUI:WaitForChild("Skill_02_BTN") :: ImageButton
	self.BTN_Skill_03 = self.MainUI:WaitForChild("Skill_03_BTN") :: ImageButton
	self.BTN_Skill_Ulti = self.MainUI:WaitForChild("Skill_Ultimate_BTN") :: ImageButton

	self.PlayerInfo = self.MainUI:WaitForChild("PlayerInfo") :: Frame
	self.PlayerName = self.PlayerInfo:WaitForChild("Player name") :: TextLabel
	self.PlayerName.Text = Player.Name
	self.AvaFrame = self.PlayerInfo:FindFirstChild("Polygon 32 1").ImageLabel :: ImageLabel
	local content, isReady =
		Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)

	-- if isReady then
	self.AvaFrame.Image = content
	-- end
	-- Nút ATTACK
	if self.BTN_Attack:IsA("ImageButton") then
		self.BTN_Attack.MouseButton1Click:Connect(function()
			Client.Player_Action.Fire("ATTACK", true)
		end)
	end

	-- Nút DASH (có debounce)
	if self.BTN_Dash:IsA("ImageButton") then
		self.BTN_Dash.MouseButton1Click:Connect(function()
			if not Player:GetAttribute("IsAttacking") then
				Dash:DoDash()
			end
		end)
	end

	-- Nút JUMP
	if self.BTN_Jump:IsA("ImageButton") then
		self.BTN_Jump.MouseButton1Click:Connect(function()
			local character = Player.Character
			if not character then
				return
			end

			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if not humanoid then
				return
			end

			-- CHỈ nhảy khi đang đứng trên mặt đất
			if humanoid.FloorMaterial ~= Enum.Material.Air then
				humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end)
	end

	-- Nút SKILL
	if self.BTN_Skill_01:IsA("ImageButton") then
		self.BTN_Skill_01.MouseButton1Click:Connect(function()
			Client.Player_Action.Fire("SKILL_01", true)
			warn("Skill 1 Button Clicked")
		end)
	end

	if self.BTN_Skill_02:IsA("ImageButton") then
		self.BTN_Skill_02.MouseButton1Click:Connect(function()
			Client.Player_Action.Fire("SKILL_02", true)
			warn("Skill 2 Button Clicked")
		end)
	end

	if self.BTN_Skill_03:IsA("ImageButton") then
		self.BTN_Skill_03.MouseButton1Click:Connect(function()
			-- Client.Player_Action.Fire("SKILL_03", true)
			warn("Skill 3 Button Clicked")
		end)
	end

	if self.BTN_Skill_Ulti:IsA("ImageButton") then
		self.BTN_Skill_Ulti.MouseButton1Click:Connect(function()
			Client.Player_Action.Fire("SKILL_ULTI", true)
			warn("Ultimate Skill Button Clicked")
		end)
	end
end

local function EditMobileCoreGUI()
	PlayerGui:WaitForChild("TouchGui"):WaitForChild("TouchControlFrame").JumpButton:Destroy()
	local DynamicThumbstick = PlayerGui:WaitForChild("TouchGui")
		:WaitForChild("TouchControlFrame")
		:WaitForChild("DynamicThumbstickFrame")
		:WaitForChild("ThumbstickEnd")
	local CustomThumbstick = ReplicatedStorage.Shared.Assets.PlayerGUI:WaitForChild("Custom_Thumbstick")

	local thumbstickClone = CustomThumbstick:Clone()
	thumbstickClone.Parent = DynamicThumbstick

	DynamicThumbstick:GetPropertyChangedSignal("ImageTransparency"):Connect(function()
		thumbstickClone.ImageTransparency = DynamicThumbstick.ImageTransparency
	end)
end

-- 🔹 Kiểm tra nếu người chơi đang trên thiết bị di động
if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
	EditMobileCoreGUI()

	local PlayerModule = require(Player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
	PlayerModule:GetControls()
	local TouchJumpButton = Player.PlayerGui:WaitForChild("TouchGui", 10)
	if TouchJumpButton then
		local jumpBtn = TouchJumpButton:FindFirstChild("JumpButton", true)
		if jumpBtn and jumpBtn:IsA("ImageButton") then
			-- Kích thước {0,50}, {0,50}
			jumpBtn.Size = UDim2.new(0, 50, 0, 50)
			-- Vị trí {1,-30}, {1,-60}
			jumpBtn.Position = UDim2.new(1, -30, 1, -60)
			warn("Adjusted Jump Button for Mobile")
		end
	end
end
function Class:Destroy() end

return Class
