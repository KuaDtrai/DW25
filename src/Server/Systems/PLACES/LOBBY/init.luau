--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CONSTANTS = require(ReplicatedStorage.Shared.Libraries.CONSTANTS)
local Server = require(ReplicatedStorage.Shared.Network.Server)

local Openday = require(ReplicatedStorage.Shared.Openday)

export type System = {
	_Extensions: { Openday.Extension },
	_Start: (self: System) -> (),
	_Setup: (self: System) -> (),
}

local init = {
	_Extensions = {},
} :: System

function init:_Setup()
	if game.PlaceId ~= CONSTANTS.LOBBY_ID then
		script:Destroy()
		return
	end
end

function init:_Start()
	local Players = game:GetService("Players")
	local TrainingFolder = workspace:WaitForChild("Training")

	-- Lưu beam theo player
	local playerBeams: { [Player]: { Beam } } = {}

	local function clearBeams(player: Player)
		if playerBeams[player] then
			for _, beam in ipairs(playerBeams[player]) do
				if beam and beam.Parent then
					beam:Destroy()
				end
			end
		end
		playerBeams[player] = {}
	end

	local function createBeam(char: Model, target: Instance): Beam?
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then
			return
		end

		local targetPart = target:IsA("Model") and target.PrimaryPart or target

		if not targetPart then
			warn("Target missing PrimaryPart:", target.Name)
			return
		end

		local att0 = Instance.new("Attachment")
		att0.Parent = hrp

		local att1 = Instance.new("Attachment")
		att1.Parent = targetPart

		local beam = Instance.new("Beam")
		beam.Attachment0 = att0
		beam.Attachment1 = att1
		beam.Width0 = 0.2
		beam.Width1 = 0.2
		beam.FaceCamera = true
		beam.Color = ColorSequence.new(Color3.fromRGB(255, 170, 0))
		beam.Parent = hrp

		return beam
	end

	local function createWeaponBeams(player: Player, char: Model)
		clearBeams(player)

		for i = 1, 3 do
			local weapon = TrainingFolder:FindFirstChild("Weapon" .. i)
			if weapon then
				local beam = createBeam(char, weapon)
				if beam then
					table.insert(playerBeams[player], beam)
				end
			end
		end
	end

	local function createDummyBeams(player: Player, char: Model)
		clearBeams(player)

		local dummyNames = {
			"Training Dummy",
			"Training Dummy1",
			"Training Dummy2",
		}

		for _, name in ipairs(dummyNames) do
			local dummy = TrainingFolder:FindFirstChild(name)
			if dummy then
				local beam = createBeam(char, dummy)
				if beam then
					table.insert(playerBeams[player], beam)
				end
			end
		end

		-- 🔥 Sau 10 giây tự xoá beam
		task.delay(10, function()
			-- nếu player đã respawn thì bỏ
			if not player.Character or player.Character ~= char then
				return
			end

			-- nếu vẫn đang equip thì mới xoá
			if char:GetAttribute("EquippedWeapon") ~= nil then
				clearBeams(player)
			end
		end)
	end

	local function setupCharacter(player: Player, char: Model)
		playerBeams[player] = {}

		-- Tạo beam ban đầu tới Weapon
		createWeaponBeams(player, char)

		-- Theo dõi EquippedWeapon
		char:GetAttributeChangedSignal("EquippedWeapon"):Connect(function()
			local value = char:GetAttribute("EquippedWeapon")

			if value ~= nil then
				createDummyBeams(player, char)
			else
				createWeaponBeams(player, char)
			end
		end)
	end

	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(char)
			task.wait(0.5)
			setupCharacter(player, char)
		end)
	end)
end

return init
