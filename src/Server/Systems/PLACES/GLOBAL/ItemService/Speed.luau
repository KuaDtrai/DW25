--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

export type Speed = {
	__index: Speed,

	new: () -> Speed,
	Destroy: (self: Speed) -> (),

	OnUse: (item: BasePart, player: Player) -> (),
}

local Class: Speed = {} :: any
Class.__index = Class

local DEFAULT_WALKSPEED = 16
local BOOST_WALKSPEED = 30
local BOOST_DURATION = 30 -- giây

function Class.new(): Speed
	local self = setmetatable({}, Class)
	return self
end

-- Hàm được gọi khi người chơi sử dụng item
function Class.OnUse(item: BasePart, player: Player)
	-- Kiểm tra xem player còn tồn tại và có Character không
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	-- Nếu đang trong trạng thái boost rồi thì không cho dùng thêm (tùy ý)
	if humanoid.WalkSpeed == BOOST_WALKSPEED then
		return
	end

	-- Tăng tốc độ
	local originalSpeed = humanoid.WalkSpeed
	humanoid.WalkSpeed = BOOST_WALKSPEED

	Debris:AddItem(item, 0) -- xóa ngay lập tức

	-- Tự động trở về tốc độ cũ sau 30 giây
	task.delay(BOOST_DURATION, function()
		-- Kiểm tra xem humanoid còn tồn tại không (tránh lỗi khi player rời game/chết)
		if humanoid and humanoid.Parent then
			humanoid.WalkSpeed = DEFAULT_WALKSPEED
		end
	end)
end

function Class:Destroy()
	-- Dọn dẹp nếu cần (hiện tại không cần)
end

return Class
