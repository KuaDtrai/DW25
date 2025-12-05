--!strict
-- WeaponPickupSystem.server.lua (không dùng Tool)

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Openday = require(ReplicatedStorage.Shared.Openday)

export type System = {
	_Extensions: { Openday.Extension },
	_Start: (self: System) -> (),
	_Setup: (self: System) -> (),
}

local WeaponPickupSystem = {
	_Extensions = {},
} :: System

local TAG = "WEAPON_PROMPT"

-- CFrame gắn vũ khí (tùy chỉnh theo model của bạn)
local WEAPON_CFRAME = CFrame.Angles(math.rad(-90), math.rad(90), 0)

local function pickupWeapon(prompt: ProximityPrompt, player: Player)
	local character = player.Character
	if not character or not character.Parent then
		return
	end

	local rightHand = character:FindFirstChild("RightHand")
	if not rightHand then
		warn("[WeaponPickup] Không tìm thấy RightHand của", player.Name)
		return
	end

	-- Lấy Handle (phần chứa prompt)
	local handle = prompt.Parent
	if not handle or not handle:IsA("BasePart") then
		warn("[WeaponPickup] Prompt không có BasePart cha!")
		return
	end

	-- Tìm Model cha của vũ khí (nếu có)
	local weaponRoot = handle
	repeat
		if weaponRoot:IsA("Model") then
			break
		end
		weaponRoot = weaponRoot.Parent
	until not weaponRoot or not weaponRoot.Parent

	if not weaponRoot then
		weaponRoot = handle
	end

	-- Bước 1: Xóa vũ khí cũ tên "Weapon" trong tay (nếu có)
	local oldWeapon = rightHand:FindFirstChild("Weapon")
	if oldWeapon then
		oldWeapon:Destroy()
	end

	-- Bước 2: Tắt Anchored + CanCollide của tất cả BasePart trong vũ khí
	for _, part in ipairs(weaponRoot:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = false
			part.CanCollide = false
		end
	end

	-- Bước 3: Đổi tên thành "Weapon"
	weaponRoot.Name = "Weapon"

	-- Bước 4: Di chuyển vào tay phải
	weaponRoot.Parent = rightHand

	-- Bước 5: Tạo Motor6D gắn Handle vào tay
	local motor = Instance.new("Motor6D")
	motor.Name = "WeaponGrip"
	motor.Part0 = rightHand
	motor.Part1 = handle
	motor.C0 = WEAPON_CFRAME
	motor.C1 = CFrame.new() -- giữ offset gốc của Handle
	motor.Parent = rightHand

	-- Bước 6: Xóa prompt
	prompt:Destroy()

	print(`[WeaponPickup] {player.DisplayName} đã cầm vũ khí!`)
end

-- Thiết lập prompt
local function setupPrompt(prompt: Instance)
	if not prompt:IsA("ProximityPrompt") then
		return
	end

	prompt.Triggered:Connect(function(player)
		task.spawn(pickupWeapon, prompt, player)
	end)
end

function WeaponPickupSystem:_Start()
	-- Xử lý tất cả prompt hiện có
	for _, obj in CollectionService:GetTagged(TAG) do
		setupPrompt(obj)
	end

	-- Tự động xử lý khi có prompt mới
	CollectionService:GetInstanceAddedSignal(TAG):Connect(setupPrompt)

	print(
		"[WeaponPickupSystem] Đã khởi động – vũ khí sẽ được đổi tên thành 'Weapon' và gắn vào tay!"
	)
end

function WeaponPickupSystem:_Setup() end

return WeaponPickupSystem
