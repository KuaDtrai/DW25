--!strict
local HttpService = game:GetService("HttpService")

local Animator = require(script.Parent.Animator)
local Utility = require(script.Parent.Utility)

export type ContentSize = {
	Right: number,
	Left: number,
	Height: number,
}

export type Constructor = {
	Overflown: boolean,
	OverflowPickupIndex: number,
	StartingProperties: any,
	OverflowPickupProperties: any,

	ContentSize: ContentSize,
}

export type TextObject = {
	__index: TextObject,
	new: (
		text: string,
		textFrames: { { GuiObject } },
		frameProperties: { [GuiObject]: { [string]: any } },
		sources: { TextLabel: TextLabel, ImageLabel: ImageLabel },
		constructor: Constructor,
		previousRichTextObject: TextObject?
	) -> TextObject,
	Animate: (self: TextObject, yield: boolean, reversed: boolean) -> (),
	Show: (self: TextObject, finishAnimation: boolean) -> (),
	Hide: (self: TextObject) -> (),
	SetGroupVisible: (self: TextObject, frame: GuiObject, show: boolean) -> (),
	SetFrameToDefault: (self: TextObject, frame: GuiObject) -> (),
	ApplyProperty: (self: TextObject, key: string, value: any) -> (),

	Id: string,
	Text: string,

	Source: { TextLabel: TextLabel, ImageLabel: ImageLabel },
	Frames: { { GuiObject } },
	Properties: { [GuiObject]: { [string]: any } },

	Animator: Animator.TextAnimator,
	ContentSize: Vector2,

	Overflown: boolean,
	StartingProperties: {},
	OverflowPickupIndex: number,
	OverflowPickupProperties: { [string]: any },
	NextTextObject: TextObject?,
}

local TextObject = {} :: TextObject
TextObject.__index = TextObject

function TextObject.new(
	text: string,
	textFrames: { { GuiObject } },
	frameProperties: { [GuiObject]: { [string]: any } },
	sources: { TextLabel: TextLabel, ImageLabel: ImageLabel },
	constructor: Constructor,
	previousRichTextObject: TextObject?
): TextObject
	local self: TextObject = setmetatable({} :: any, TextObject)

	self.Id = HttpService:GenerateGUID()
	self.Text = text

	self.Animator = Animator.new(self.Id, textFrames, frameProperties, sources)
	self.Source = sources

	-- to overflow: check if textObject.Overflown, then use RichText:ContinueOverflow(newFrame, textObject) to continue to another frame.
	self.Overflown = constructor.Overflown
	self.OverflowPickupIndex = constructor.OverflowPickupIndex
	self.StartingProperties = constructor.StartingProperties
	self.OverflowPickupProperties = constructor.OverflowPickupProperties
	self.Frames = textFrames
	self.Properties = frameProperties

	local contentSize = constructor.ContentSize
	self.ContentSize = Vector2.new(contentSize.Right - contentSize.Left, contentSize.Height)

	if previousRichTextObject then
		previousRichTextObject.NextTextObject = self
	end

	return self
end

function TextObject:Animate(yield: boolean, reversed: boolean)
	if yield then
		self.Animator:Run(yield, reversed)
	else
		coroutine.wrap(function()
			self.Animator:Run(yield, reversed)
		end)()
	end

	if self.NextTextObject then
		self.NextTextObject:Animate(yield, reversed)
	end
end

function TextObject:Show(finishAnimation: boolean)
	if finishAnimation then
		self.Animator.OverrideYield = true
	else
		self.Animator.Animation.Done = true
		for lineNum, list in pairs(self.Frames) do
			for _, frame in pairs(list) do
				self:SetGroupVisible(frame, true)
			end
		end
	end
	if self.NextTextObject then
		self.NextTextObject:Show(finishAnimation)
	end
end

function TextObject:Hide()
	self.Animator.Animation.Done = true
	for lineNum: number, list in pairs(self.Frames) do
		for _, frame in pairs(list) do
			self:SetGroupVisible(frame, false)
		end
	end
	if self.NextTextObject then
		self.NextTextObject:Hide()
	end
end

function TextObject:SetFrameToDefault(frame: GuiObject)
	frame.Position = self.Properties[frame].InitialPosition
	frame.Size = self.Properties[frame].InitialSize
	frame.AnchorPoint = self.Properties[frame].InitialAnchorPoint

	for propertyKey: string, propertyValue: any in pairs(self.Properties[frame]) do
		self:ApplyProperty(propertyKey, propertyValue)
	end
end

function TextObject:SetGroupVisible(frame: GuiObject, visible: boolean)
	frame.Visible = visible
	for _, v in pairs(frame:GetChildren()) do
		if v:IsA("GuiObject") then
		end
	end

	if visible and frame:IsA("ImageLabel") then
		self:SetFrameToDefault(frame)
	end
end

function TextObject:ApplyProperty(key: string, value: any, frame: Frame?): boolean
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

return TextObject
