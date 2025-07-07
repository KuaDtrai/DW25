--!strict
local RunService = game:GetService("RunService")

local Utility = require(script.Parent.Utility)
local Styles = require(script.Style)

export type QueueObject = {
	Char: GuiObject,
	Settings: { [string]: any },
	Start: number,
}

export type AnimationProperties = {
	Done: boolean,
	Processed: boolean,
	Animated: number,
	Queue: { QueueObject },
	Step: {
		Grouping: "Word" | "Letter" | "All",
		Time: number,
		Frequency: number,
	},
}

export type TextAnimator = {
	__index: TextAnimator,
	new: (
		id: string,
		textFrames: { { GuiObject } },
		frameProperties: { [GuiObject]: { [string]: any } },
		sources: { TextLabel: TextLabel, ImageLabel: ImageLabel }
	) -> TextAnimator,
	Run: (self: TextAnimator, yieldUntilDone: boolean, reversed: boolean) -> (),
	Character: (self: TextAnimator, char: GuiObject, properties: { [string]: any }) -> (),
	Yield: (self: TextAnimator) -> (),
	Update: (self: TextAnimator) -> (),
	SetGroupVisible: (self: TextAnimator, frame: GuiObject, show: boolean) -> (),
	SetFrameToDefault: (self: TextAnimator, frame: GuiObject) -> (),
	ApplyProperty: (self: TextAnimator, key: string, value: any) -> (),

	Id: string,
	OverrideYield: boolean,
	Animation: AnimationProperties,

	Source: { TextLabel: TextLabel, ImageLabel: ImageLabel },
	Frames: { { GuiObject } },
	Properties: { [GuiObject]: { [string]: any } },
}

local TextAnimator = {} :: TextAnimator
TextAnimator.__index = TextAnimator

function TextAnimator.new(
	id: string,
	textFrames: { { GuiObject } },
	frameProperties: { [GuiObject]: { [string]: any } },
	sources: { TextLabel: TextLabel, ImageLabel: ImageLabel }
): TextAnimator
	local self: TextAnimator = setmetatable({} :: any, TextAnimator)

	self.Frames = textFrames
	self.Properties = frameProperties

	self.OverrideYield = false
	self.Id = id

	self.Animation = {
		Done = false,
		Processed = false,
		Animated = 0,
		Queue = {},
		Step = {
			Grouping = "Word",
			Time = 0,
			Frequency = 0,
		},
	}

	return self
end

function TextAnimator:Run(yieldUntilDone: boolean, reversed: boolean)
	self.Animation.Done = false

	RunService:BindToRenderStep(self.Id, Enum.RenderPriority.Last.Value, function(delta: number)
		self:Update()
	end)

	-- Make everything invisible to start
	for lineNum: number, list in pairs(self.Frames) do
		for _, frame in pairs(list) do
			self:SetGroupVisible(frame, false)
		end
	end

	local process = function(frame)
		local properties = self.Properties[frame]
		if
			not (properties.AnimateStepGrouping == self.Animation.Step.Grouping)
			or not (properties.AnimateStepFrequency == self.Animation.Step.Frequency)
		then
			self.Animation.Animated = 0
		end
		self.Animation.Step.Grouping = properties.AnimateStepGrouping
		self.Animation.Step.Time = properties.AnimateStepTime
		self.Animation.Step.Frequency = properties.AnimateStepFrequency

		if properties.AnimateYield > 0 then
			task.wait(properties.AnimateYield)
		end

		if self.Animation.Step.Grouping == "Word" or self.Animation.Step.Grouping == "All" then
			if frame:IsA("TextLabel") then
				frame.Visible = true
				for _, v in pairs(frame:GetChildren()) do
					self:Character(v :: GuiObject, self.Properties[v :: GuiObject])
				end
			else
				self:Character(frame, properties)
			end

			if self.Animation.Step.Grouping == "Word" then
				self.Animation.Animated += 1
				self:Yield()
			end
		elseif self.Animation.Step.Grouping == "Letter" then
			if frame:IsA("TextLabel") then
				frame.Visible = true

				local index = 1
				while true do
					local v = frame:FindFirstChild(string.format("Char%03d", index)) :: GuiObject?
					if not v then
						break
					end

					self:Character(v, self.Properties[v])
					self.Animation.Animated += 1

					self:Yield()
					if self.Animation.Done then
						return
					end
					index += 1
				end
			else
				self:Character(frame, properties)
				self.Animation.Animated += 1
				self:Yield()
			end
		else
			warn("Invalid step grouping: ", self.Animation.Step.Grouping)
		end

		if self.Animation.Done then
			return
		end
	end

	for lineNum: number, list in pairs(self.Frames) do
		if not reversed then
			for i = 1, #list do
				process(list[i])
			end
		else
			for i = #list, 1, -1 do
				process(list[i])
			end
		end
	end

	self.Animation.Processed = true

	if yieldUntilDone then
		while #self.Animation.Queue > 0 do
			RunService.RenderStepped:Wait()
		end
	end
end

function TextAnimator:Character(char: GuiObject, properties: { [string]: any })
	table.insert(self.Animation.Queue, { Char = char, Settings = properties, Start = workspace:GetServerTimeNow() })
end

function TextAnimator:Yield()
	if
		not self.OverrideYield
		and self.Animation.Animated % self.Animation.Step.Frequency == 0
		and self.Animation.Step.Time >= 0
	then
		local yieldTime: number? = self.Animation.Step.Time > 0 and self.Animation.Step.Time or nil
		task.wait(yieldTime)
	end
end

function TextAnimator:Update()
	if self.Animation.Processed and #self.Animation.Queue == 0 or self.Animation.Done then
		self.Animation.Done = true
		RunService:UnbindFromRenderStep(self.Id)
		self.Animation.Queue = {}
		return
	end

	local t: number = workspace:GetServerTimeNow()
	for i = #self.Animation.Queue, 1, -1 do
		local set = self.Animation.Queue[i]
		local properties = set.Settings
		local animateStyle = Styles[properties.AnimateStyle]
		if not animateStyle then
			warn("No animation style found for: ", properties.AnimateStyle, ", defaulting to Appear")
			animateStyle = Styles.Appear
		end
		local animateAlpha = math.min((t - set.Start) / properties.AnimateStyleTime, 1)
		animateStyle(set.Char, animateAlpha, properties)
		if animateAlpha >= 1 then
			table.remove(self.Animation.Queue, i)
		end
	end
end

function TextAnimator:SetFrameToDefault(frame: GuiObject)
	frame.Position = self.Properties[frame].InitialPosition
	frame.Size = self.Properties[frame].InitialSize
	frame.AnchorPoint = self.Properties[frame].InitialAnchorPoint

	for propertyKey: string, propertyValue: any in pairs(self.Properties[frame]) do
		self:ApplyProperty(propertyKey, propertyValue)
	end
end

function TextAnimator:SetGroupVisible(frame: GuiObject, visible: boolean)
	frame.Visible = visible
	for _, v in pairs(frame:GetChildren()) do
		if v:IsA("GuiObject") then
		end
	end

	if visible and frame:IsA("ImageLabel") then
		self:SetFrameToDefault(frame)
	end
end

function TextAnimator:ApplyProperty(key: string, value: any, frame: Frame?): boolean
	local propertyType: string
	local ret: boolean = false

	for _, label: GuiObject in pairs(frame and { frame } or self.Source) do
		local isProperty = pcall(function()
			propertyType = typeof((label :: any)[key])
		end) -- is there a better way to check if it's a property?

		if isProperty then
			if propertyType == "Color3" then
				(label :: any)[key] = Utility.GetColorFromString(value)
			elseif propertyType == "Vector2" then
				(label :: any)[key] = Utility.GetVector2FromString(value)
			else
				(label :: any)[key] = value
			end
			ret = true
		end
	end

	return ret
end

return TextAnimator
