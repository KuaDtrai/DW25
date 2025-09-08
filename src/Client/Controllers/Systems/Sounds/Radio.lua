--!strict
local TweenService = game:GetService("TweenService")

export type Radio = {
	__index: Radio,
	new: (soundGroup: SoundGroup) -> Radio,
	Destroy: (self: Radio) -> (),

	Play: (self: Radio, soundName: string?) -> (),
	Stop: (self: Radio) -> (),
	Volume: (self: Radio, volume: number) -> (),

	_Group: SoundGroup,
	_Index: number,
	_Sounds: { Sound },
	_Connection: RBXScriptConnection?,
	_Current: Sound?,
}
local Class: Radio = {} :: Radio
Class.__index = Class

function Class.new(soundGroup: SoundGroup): Radio
	local self: Radio = setmetatable({} :: any, Class)

	self._Group = soundGroup
	self._Index = 0
	self._Sounds = {}
	self._Connection = nil
	self._Current = nil

	for _, child in pairs(soundGroup:GetChildren()) do
		if child:IsA("Sound") then
			table.insert(self._Sounds, child)
		end
	end

	return self
end

function Class:Volume(volume: number)
	if self._Group then
		TweenService:Create(self._Group, TweenInfo.new(0.5), { Volume = volume }):Play()
	end
end

function Class:Play(soundName: string?)
	if not soundName then
		self._Index += 1
		if self._Index > #self._Sounds then
			self._Index = 1
		end
		local currentSound = self._Sounds[self._Index]
		if currentSound and currentSound:IsA("Sound") then
			currentSound:Play()
			self._Current = currentSound

			self._Connection = currentSound.Ended:Connect(function()
				self:Play()
			end)
		end
	else
		local sound = self._Group:FindFirstChild(soundName, true)

		if sound and sound:IsA("Sound") then
			if self._Connection then
				self._Connection:Disconnect()
			end

			self._Current = sound
			sound:Play()
		end
	end
end

function Class:Stop()
	if self._Connection then
		self._Connection:Disconnect()
	end

	if self._Current then
		self._Current:Stop()
	end
end

function Class:Destroy() end

return Class
