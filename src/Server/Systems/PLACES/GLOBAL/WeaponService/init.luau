--!strict
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WeaponFolder = ReplicatedStorage.Shared.Assets.Items:WaitForChild("Weapon")
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

local DEFAULT_OFFSET = CFrame.Angles(math.rad(-90), math.rad(90), 0)

-------------------------------------------------------
-- 🔥 PICKUP LOGIC
-------------------------------------------------------
local function pickupWeapon(prompt: ProximityPrompt, player: Player)
	local character = player.Character
	if not character then
		return
	end

	local rightHand = character:FindFirstChild("RightHand") :: BasePart?
	if not rightHand then
		warn("Không tìm thấy RightHand!")
		return
	end

	local worldWeapon = prompt.Parent :: MeshPart?
	if not worldWeapon or not worldWeapon:IsA("MeshPart") then
		warn("Weapon ngoài map không hợp lệ")
		return
	end

	-------------------------------------------------------
	-- 🔥 XOÁ VŨ KHÍ CŨ (NẾU CÓ)
	-------------------------------------------------------
	local oldWeapon = character:FindFirstChild("Weapon")
	if oldWeapon then
		local oldMotor = rightHand:FindFirstChild("WeaponGrip")
		if oldMotor then
			oldMotor:Destroy()
		end
		oldWeapon:Destroy()
	end

	-------------------------------------------------------
	-- 🔥 XÁC ĐỊNH TEMPLATE TỪ TAG
	-------------------------------------------------------
	local template: MeshPart? = nil

	if CollectionService:HasTag(worldWeapon, "WEAPON_SWORD") then
		template = WeaponFolder:FindFirstChild("Sword") :: MeshPart?
		character:SetAttribute("EquippedWeapon", "SWORD")
	elseif CollectionService:HasTag(worldWeapon, "WEAPON_LANCE") then
		template = WeaponFolder:FindFirstChild("Lance") :: MeshPart?
		character:SetAttribute("EquippedWeapon", "LANCE")
	elseif CollectionService:HasTag(worldWeapon, "WEAPON_GREATSWORD") then
		template = WeaponFolder:FindFirstChild("Greatsword") :: MeshPart?
		character:SetAttribute("EquippedWeapon", "GREATSWORD")
	end

	if not template then
		warn("Không tìm thấy template vũ khí")
		return
	end

	-------------------------------------------------------
	-- 🔥 CLONE VŨ KHÍ VÀO NHÂN VẬT
	-------------------------------------------------------
	local newWeapon = template:Clone()
	newWeapon.Name = "Weapon"
	newWeapon.Parent = character
	newWeapon.Anchored = false
	newWeapon.CanCollide = false

	-------------------------------------------------------
	-- 🔥 TẠO MOTOR6D
	-------------------------------------------------------
	local motor = Instance.new("Motor6D")
	motor.Name = "WeaponGrip"
	motor.Part0 = rightHand
	motor.Part1 = newWeapon

	-- lấy offset từ attribute trên vũ khí
	local offset = newWeapon:GetAttribute("Offset")
	if typeof(offset) == "CFrame" then
		motor.C0 = offset
	else
		motor.C0 = DEFAULT_OFFSET
	end

	motor.C1 = CFrame.new()
	motor.Parent = rightHand

	newWeapon:FindFirstChild("ProximityPrompt").Enabled = false
	-------------------------------------------------------
	-- 🔥 XOÁ VŨ KHÍ NGOÀI MAP
	-------------------------------------------------------
	worldWeapon:Destroy()

	print(player.Name .. " đã nhặt " .. template.Name)
end

-------------------------------------------------------
-- 🔥 SETUP PROMPT
-------------------------------------------------------
local function setupPrompt(instance: Instance)
	if not instance:IsA("ProximityPrompt") then
		return
	end

	print("Đã connect prompt:", instance:GetFullName())

	instance.Triggered:Connect(function(player)
		print(player.Name .. " triggered prompt")
		task.spawn(pickupWeapon, instance, player)
	end)
end

-------------------------------------------------------
-- 🔥 START SYSTEM
-------------------------------------------------------
function WeaponPickupSystem:_Start()
	for _, obj in ipairs(CollectionService:GetTagged(TAG)) do
		setupPrompt(obj)
	end

	CollectionService:GetInstanceAddedSignal(TAG):Connect(setupPrompt)

	print("[WeaponPickupSystem] Start")
end

function WeaponPickupSystem:_Setup() end

return WeaponPickupSystem
