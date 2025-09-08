--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Radio = require(script.Radio)
local Openday = require(ReplicatedStorage.Shared.Openday)

export type System = {
	_Extensions: { Openday.Extension },
	_Start: (self: System) -> (),
	_Setup: (self: System) -> (),

	BGMRadio: Radio.Radio?,
	SFXRadio: Radio.Radio?,
	GUIRadio: Radio.Radio?,
	BossRadio: Radio.Radio?,
	VFXRadio: Radio.Radio?,
}

local Sounds = {
	_Extensions = {},
} :: System

function Sounds:_Setup() end

function Sounds:_Start()
	local bgm = SoundService:FindFirstChild("BGM") :: SoundGroup
	if bgm then
		self.BGMRadio = Radio.new(bgm)
	end

	local gui = SoundService:FindFirstChild("GUI") :: SoundGroup
	if gui then
		self.GUIRadio = Radio.new(gui)
	end

	local sfx = SoundService:FindFirstChild("SFX") :: SoundGroup
	if sfx then
		self.SFXRadio = Radio.new(sfx)
	end

	local boss = SoundService:FindFirstChild("BOSS") :: SoundGroup
	if boss then
		self.BossRadio = Radio.new(boss)
	end

	local vfx = SoundService:FindFirstChild("VFX") :: SoundGroup
	if vfx then
		self.VFXRadio = Radio.new(vfx)
	end

	SoundService.ChildAdded:Connect(function(child: Instance)
		if child:IsA("SoundGroup") then
			if child.Name == "SFX" and not self.SFXRadio then
				self.SFXRadio = Radio.new(child)
			elseif child.Name == "GUI" and not self.GUIRadio then
				self.GUIRadio = Radio.new(child)
			elseif child.Name == "BGM" and not self.BGMRadio then
				self.BGMRadio = Radio.new(child)
			elseif child.Name == "BOSS" and not self.BossRadio then
				self.BossRadio = Radio.new(child)
			elseif child.Name == "VFX" and not self.VFXRadio then
				self.VFXRadio = Radio.new(child)
			end
		end
	end)

	if self.BGMRadio then
		self.BGMRadio:Play()
	end
end

return Sounds
