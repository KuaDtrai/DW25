--!strict
local TextService = game:GetService("TextService")
--[[
	
Rich text markup with support for modifying any TextLabel property per character + inline images + entrance animations

Written by Defaultio ~ August 30 2017

Changes:	
	October 21 2017 - Unicode support added thanks to Tiffany Bennett - https://gist.github.com/tiffany352/ccb3559738f4e8d4152d940126998c41
	January 29 2018 - Added finishAnimate parameter to RichTextObject:Show() function
					- Fixed bug on iOS devices causing some characters to fail to appear. Using TextWrapped = false on character labels fixed this, thanks Buildthomas.
	June 23 2019 	- Fixed reoccurance of bug where some characters fail to appear when on mobile, added one extra pixel to each character frame.
	July 16 2018	- Disabled AutoLocalize for generated text labels


			TODO:
				- exit animations
				- emphasis animations
				- support for inline buttons
				- sounds for each text step
				- markup events that will fire a callback provided in the constructor when the text animation is reached, use for character animations, etc
			
			Let me know if these features will be useful and I'll add them more quickly.

___________________________________________________________________________________________________________________

API:

Constructor:

	RichText:New(GuiObject frame, String text, Dictionary startingProperties = {}, Boolean allowOverflow = true)
		frame: the parent frame which will be populated with text
		text: self explanitory
		startingProperties: a dictionary of what the default text properties should be
		allowOverflow: if false, text will stop rendering when it fills the vertical height of the frame. To continue the text in another frame, see RichText:ContinueOverflow() below...
		
		returns: RichText object
			
	RichText:ContinueOverflow(GuiObject nextFrame, RichTextObject previousRichTextObject)
		nextFrame: the parent frame that text will continue into
		previousRichTextObject: the previous RichTextObject that is being overflown from.
		
		returns: richTextObject
	
			
RichText Object: (returned by constructor)

	RichTextObject:Animate(doYield = false)
		Will run the animation. If doYield is true, the thread will yield until the animation is complete. Else, it will wrap the animation function in a coroutine
		
	RichTextObject:Show(finishAnimation = false)
		Shows the entirety of the text body. Will interrupt and stop the animation if it's running. if finishAnimation is true, the remaining text will animate in instead of appearing instantly.
		
	RichTextObject:Hide()
		Hides the text body. Will interrupt and stop the animation if it's running. The animation can be replayed after hiding.
		
	
	Vector2 RichTextObject.ContentSize
		Content size in pixels
		
	Boolean RichTextObject.Overflown
		If allowOverflow was false, this value shows if the text is overflown or if it fit in the frame. If overflown, use RichText:ContinueOverflow to continue into a new frame.
		


___________________________________________________________________________________________________________________

USAGE:

The text supplied in the constructor can be any text string. Insert a markup modifier by including <MarkupKey=MarkupValue>. No spaces.

	Examples of what this looks like include:
		<Font=ArialBold> --Set the font to ArialBold
		<Img=639588687> -- Insert an inline image with this ID
		<AnimateStepTime=0.4> -- Set the animate step time to 0.4 seconds.
		<AnimateYield=1> -- Yield for one second at this point in the animation
		<TextColor3=1,0,0> -- Set text color to red
		<Color=Red> -- Equivalent to above. The shortcut for the property name is defined in the propertyShortcuts table, and the color shortcut is defined in the colors table.
		
	After you set any markup value, you can revert it back to default later by setting it to "/". For example:
		<Font=/>
		<AnimateStepTime=/>
		<Color=/>
		
	Default values are defined by values in the "default" table below, or by values supplied in the startingProperties dictionary when the object is constructed.

Currently does not support escapement characters for < and >, so you can't use these characters in the text string.


To when using RichText:ContinueOverflow, calling Animate(), Show(), or Hide() on the initial RichText object will pass this call onto subsequent overflown rich text objects, so
only a call to the first object is neccessary. See example.

___________________________________________________________________________________________________________________

Example code:

	local RichText = require(richTextModule)
	local text = "Hello world!\nLine two! <AnimateDelay=1><Img=Thinking>"
	local textObject = RichText:New(frame, text)
	textObject:Animate(true)
	print("Animation done!")


Example string 1: Basic

	local text = "<Font=SourceSansBold><TextScale=0.3>Oh!<TextScale=/><Font=/><AnimateYield=1> I didn't see you there<AnimateStepFrequency=1><AnimateStepTime=0.4> . . .<AnimateStepFrequency=/><AnimateStepTime=/>\n I wasn't expecting <Color=255,0,0>you<Color=/>. Please forgive the state of my room.<AnimateYield=1><Img=639588687>"
	
	--This yields this result: https://twitter.com/Defaultio/status/903094769617747968


Example string 2: Wind Waker

	Insert the WindWakerExample ScreenGui in this module into StarterGui.
	Insert this module into WindWakerExample.
	Ensure WindWakerExample.LocalText is not Disabled.
	
	-- This yields this result: https://twitter.com/Defaultio/status/903138250054709248
	
	
Example string 3: Text-in animations

	local text = "This text is about to be <Color=Green><AnimateStyle=Wiggle><AnimateStepFrequency=1><AnimateStyleTime=2>wiggly<AnimateStyle=/><AnimateStepFrequency=/><AnimateStyleTime=/><Color=/>!<AnimateYield=1.5>\nIt can also be <Color=Red><AnimateStyle=Fade><AnimateStepFrequency=1><AnimateStyleTime=0.5>fadey fadey<AnimateStyle=/><AnimateStepFrequency=/><AnimateStyleTime=/><Color=/>!<AnimateYield=1>\n<AnimateStyle=Rainbow><AnimateStyleTime=2>Or rainbow!!! :O<AnimateStyle=/><AnimateStyleTime=/><AnimateYield=1>\n<AnimateStyle=Swing><AnimateStyleTime=3>Make custom animations!"
	
	-- This yields this result: https://twitter.com/Defaultio/status/903346975688425472
	
	
Example string 4: Variable text justification per line

	local text = "Have you ever <Color=Red>thought<Color=/><AnimateStepFrequency=1><AnimateStepTime=0.4> . . .<AnimateStepFrequency=/><AnimateStepTime=/><AnimateYield=1><ContainerHorizontalAlignment=Center>\n<TextScale=0.5><AnimateStyle=Rainbow><AnimateStyleTime=2.5><Img=Thinking><AnimateStyle=/><TextScale=/><AnimateYield=3><ContainerHorizontalAlignment=Right>\n<Color=Green><AnimateStyle=Spin><AnimateStyleTime=1.5>Wow<AnimateStyle=/><Color=/>!"

	-- This yields this result: https://twitter.com/Defaultio/status/903381787467956224

Example 5: Overflowing

	Insert the OverflowingExample ScreenGui in this module into StarterGui.
	Inert this module into the OverflowingExample ScreenGui.
	Ensure OverflowingExample.LocalText is not disabled.
	
	-- This yields this result: https://twitter.com/Defaultio/status/918619989107621888

___________________________________________________________________________________________________________________	
	
--]]

local TextObject = require(script.TextObject)
local Utility = require(script.Utility)

export type RichText = {
	__index: RichText,
	new: (
		frame: Frame,
		text: string?,
		startingProperties: { [string]: any }?,
		allowOverflow: boolean?,
		prevTextObject: TextObject.TextObject?
	) -> RichText,

	Run: (self: RichText, prevTextObject: TextObject.TextObject?) -> (),
	ApplyMarkup: (self: RichText, key: string, value: any) -> boolean,
	ApplyProperty: (self: RichText, key: string, value: any, frame: Frame?) -> boolean,
	GetTextSize: (self: RichText) -> number,
	AddLine: (self: RichText) -> (),
	AddFrameProperties: (self: RichText, frame: GuiObject) -> (),
	FormatLabel: (
		self: RichText,
		newLabel: GuiLabel,
		labelHeight: number,
		labelWidth: number,
		endOfLineCallback: () -> ()
	) -> (),
	PrintText: (self: RichText, text: string) -> (),
	PrintImage: (self: RichText, imageId: string) -> (),
	PrintSeries: (self: RichText, labelSeries: { string }) -> (),
	ContinueOverflow: (self: RichText, newFrame: Frame, prevTextObject: TextObject.TextObject) -> (),

	Animate: (self: RichText, yield: boolean, reversed: boolean) -> (),
	Show: (self: RichText, finishAnimation: boolean) -> (),
	Hide: (self: RichText) -> (),

	----------------------------------

	Frame: Frame,
	LayerCollector: LayerCollector,
	ListLayout: UIListLayout,

	Text: string,
	LabelSeries: { string },

	AllowOverflow: boolean,
	Overflown: boolean,

	LinePosition: number,
	TextPosition: number,
	ContentHeight: number,

	Frames: {
		Lines: { Frame },
		Texts: { { GuiObject } },
	},

	Source: { TextLabel: TextLabel, ImageLabel: ImageLabel },

	Properties: {
		Current: { [string]: any },
		Default: { [string]: any },
		Frames: { [GuiObject]: { [string]: any } },
	},

	TextObject: TextObject.TextObject,
}

local RichText = {} :: RichText
RichText.__index = RichText

function RichText.new(
	frame: Frame,
	text: string?,
	startingProperties: { [string]: any }?,
	allowOverflow: boolean?,
	prevTextObject: TextObject.TextObject?
): RichText
	local self: RichText = setmetatable({} :: any, RichText)

	for _, v: any in pairs(frame:GetChildren()) do
		v:Destroy()
	end

	-- Init flags and local properties
	self.Text = text :: string

	self.AllowOverflow = if allowOverflow == nil then true else allowOverflow
	self.Overflown = false

	self.LinePosition = 0
	self.TextPosition = 1

	-- Init instances
	self.LabelSeries = {}
	self.Frames = {
		Lines = {},
		Texts = {},
	}
	self.Source = {
		TextLabel = Instance.new("TextLabel"),
		ImageLabel = Instance.new("ImageLabel"),
	}
	self.Source.TextLabel.AutoLocalize = false
	self.Frame = frame
	self.LayerCollector = Utility.GetLayerCollector(frame) :: LayerCollector

	-- Init Properties
	self.Properties = {
		Default = {},
		Current = {},
		Frames = {},
	}
	if prevTextObject then
		self.Text = prevTextObject.Text
		startingProperties = prevTextObject.StartingProperties
	end

	-- Fill Properties
	for key: string, value: any in pairs(Utility.DEFAULTS) do
		self:ApplyMarkup(key, value)

		self.Properties.Default[Utility.SHORT_CUTS.Properties[key] or key] =
			self.Properties.Current[Utility.SHORT_CUTS.Properties[key] or key]
	end

	for key: string, value: any in pairs(startingProperties or {}) do
		self:ApplyMarkup(key, value)

		self.Properties.Default[Utility.SHORT_CUTS.Properties[key] or key] =
			self.Properties.Current[Utility.SHORT_CUTS.Properties[key] or key]
	end

	if prevTextObject then
		self.Properties.Current = prevTextObject.OverflowPickupProperties
		for key: string, value: any in pairs(Utility.DEFAULTS) do
			self:ApplyMarkup(key, value)
		end
	end

	self.ContentHeight = 0
	self:Run()

	-- Post init
	self.ListLayout = Instance.new("UIListLayout")
	self.ListLayout.HorizontalAlignment = self.Properties.Current.ContainerHorizontalAlignment
	self.ListLayout.VerticalAlignment = self.Properties.Current.ContainerVerticalAlignment
	self.ListLayout.Parent = frame

	----- Calculate content size -----

	local contentLeft: number = frame.AbsoluteSize.X
	local contentRight: number = 0
	for _, lineFrame: Frame in pairs(self.Frames.Lines) do
		local container = lineFrame:FindFirstChild("Container") :: Frame?
		if container then
			self.ContentHeight += lineFrame.Size.Y.Offset
			local left, right
			if container.AnchorPoint.X == 0 then
				left = container.Position.X.Offset
				right = container.Size.X.Offset
			elseif container.AnchorPoint.X == 0.5 then
				left = lineFrame.AbsoluteSize.X / 2 - container.Size.X.Offset / 2
				right = lineFrame.AbsoluteSize.X / 2 + container.Size.X.Offset / 2
			elseif container.AnchorPoint.X == 1 then
				left = lineFrame.AbsoluteSize.X - container.Size.X.Offset
				right = lineFrame.AbsoluteSize.X
			end
			contentLeft = math.min(contentLeft, left)
			contentRight = math.max(contentRight, right)
		end
	end

	self.TextObject = TextObject.new(self.Text, self.Frames.Texts, self.Properties.Frames, self.Source, {
		Overflown = self.Overflown,
		OverflowPickupIndex = self.TextPosition,
		StartingProperties = startingProperties,
		OverflowPickupProperties = self.Properties.Current,

		ContentSize = { Right = contentRight, Left = contentLeft, Height = self.ContentHeight },
	})

	return self
end

function RichText:Run(prevTextObject: TextObject.TextObject?)
	-- Lines
	self:AddLine()

	local text: string = self.Text
	local length = #text

	if prevTextObject then
		self.TextPosition = prevTextObject.OverflowPickupIndex
	end

	while self.TextPosition and self.TextPosition <= length do
		local nextMarkupStart: number?, nextMarkupEnd: number? = string.find(text, "<.->", self.TextPosition)
		local nextSpaceStart: number?, nextSpaceEnd: number? = string.find(text, "[ \t\n]", self.TextPosition)

		local nextBreakStart: number, nextBreakEnd: number, breakIsWhitespace: boolean
		if nextMarkupStart and nextMarkupEnd and (not nextSpaceStart or nextMarkupStart < nextSpaceStart) then
			nextBreakStart, nextBreakEnd = nextMarkupStart, nextMarkupEnd
		else
			nextBreakStart, nextBreakEnd = nextSpaceStart or length + 1, nextSpaceEnd or length + 1
			breakIsWhitespace = true
		end

		local nextWord: string? = nextBreakStart > self.TextPosition
				and string.sub(text, self.TextPosition, nextBreakStart - 1)
			or nil
		local nextBreak: string? = nextBreakStart <= length and string.sub(text, nextBreakStart, nextBreakEnd) or nil
		if nextWord then
			table.insert(self.LabelSeries, nextWord)
		end

		if breakIsWhitespace then
			self:PrintSeries(self.LabelSeries)
			if self.Overflown then
				break
			end

			if nextBreak then
				self:PrintSeries({ nextBreak })
			end

			if self.Overflown then
				self.TextPosition = nextBreakStart
				break
			end
			self.LabelSeries = {}
		elseif nextBreak then
			table.insert(self.LabelSeries, nextBreak)
		end

		self.TextPosition = nextBreakEnd + 1
	end

	if not self.Overflown then
		self:PrintSeries(self.LabelSeries)
	end
end

function RichText:ApplyMarkup(key: string, value: any): boolean
	key = Utility.SHORT_CUTS.Properties[key] or key
	if value == "/" then
		if self.Properties.Default[key] then
			value = self.Properties.Default[key]
		else
			warn("Attempt to default <" .. key .. "> to value with no default")
		end
	end

	if tonumber(value) then
		value = tonumber(value)
	elseif value == "false" or value == "true" then
		value = value == "true"
	end
	self.Properties.Current[key] = value

	if self:ApplyProperty(key, value) then
		return true
	elseif key == "ContainerHorizontalAlignment" and self.Frames.Lines[#self.Frames.Lines] then
		local container: GuiObject? = self.Frames.Lines[#self.Frames.Lines]:FindFirstChild("Container") :: GuiObject?
		if container then
			Utility.SetHorizontalAlignment(container, value)
		end
	elseif Utility.DEFAULTS[key] then
		return true
	elseif key == "Img" then
		self:PrintImage(value)
	else
		-- Unknown value
		return false
	end

	return true
end

function RichText:ApplyProperty(key: string, value: any, frame: Frame?): boolean
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

function RichText:GetTextSize(): number
	if self.Properties.Current.TextScaled == true then
		local relativeHeight: number
		if self.Properties.Current.TextScaleRelativeTo == "Screen" and self.LayerCollector then
			relativeHeight = self.LayerCollector.AbsoluteSize.Y
		elseif self.Properties.Current.TextScaleRelativeTo == "Frame" then
			relativeHeight = self.Frame.AbsoluteSize.Y
		end

		return math.min(self.Properties.Current.TextScale * relativeHeight, 100)
	else
		return self.Properties.Current.TextSize
	end
end

function RichText:AddLine()
	local lastLineFrame: Frame = self.Frames.Lines[#self.Frames.Lines]
	if lastLineFrame then
		self.ContentHeight += lastLineFrame.Size.Y.Offset
		if not self.AllowOverflow and self.ContentHeight + self:GetTextSize() > self.Frame.AbsoluteSize.Y then
			self.Overflown = true
			return
		end
	end

	local lineFrame = Instance.new("Frame")
	lineFrame.Name = string.format("Line%03d", #self.Frames.Lines + 1)
	lineFrame.Size = UDim2.new(0, 0, 0, 0)
	lineFrame.BackgroundTransparency = 1
	local textContainer = Instance.new("Frame", lineFrame)
	textContainer.Name = "Container"
	textContainer.Size = UDim2.new(0, 0, 0, 0)
	textContainer.BackgroundTransparency = 1

	Utility.SetHorizontalAlignment(textContainer, self.Properties.Current.ContainerHorizontalAlignment)
	lineFrame.Parent = self.Frame
	table.insert(self.Frames.Lines, lineFrame)
	self.Frames.Texts[#self.Frames.Lines] = {}

	self.LinePosition = 0
end

function RichText:AddFrameProperties(frame: GuiObject)
	self.Properties.Frames[frame] = Utility.ShallowCopy(self.Properties.Current)
	self.Properties.Frames[frame].InitialSize = frame.Size
	self.Properties.Frames[frame].InitialPosition = frame.Position
	self.Properties.Frames[frame].InitialAnchorPoint = frame.AnchorPoint
end

function RichText:FormatLabel(newLabel: GuiObject, labelHeight: number, labelWidth: number, endOfLineCallback: () -> ())
	local lineFrame: Frame = self.Frames.Lines[#self.Frames.Lines]
	local lineContainer: GuiLabel? = lineFrame:FindFirstChild("Container") :: GuiLabel?

	if lineContainer then
		local verticalAlignment = tostring(self.Properties.Current.TextYAlignment)
		if verticalAlignment == "Top" then
			newLabel.Position = UDim2.new(0, self.LinePosition, 0, 0)
			newLabel.AnchorPoint = Vector2.new(0, 0)
		elseif verticalAlignment == "Center" then
			newLabel.Position = UDim2.new(0, self.LinePosition, 0.5, 0)
			newLabel.AnchorPoint = Vector2.new(0, 0.5)
		elseif verticalAlignment == "Bottom" then
			newLabel.Position = UDim2.new(0, self.LinePosition, 1, 0)
			newLabel.AnchorPoint = Vector2.new(0, 1)
		end

		self.LinePosition += labelWidth
		if self.LinePosition > self.Frame.AbsoluteSize.X and not (self.LinePosition == labelWidth) then
			-- Newline, get rid of label and retry it on the next line
			newLabel:Destroy()
			local lastLabel: GuiObject = self.Frames.Texts[#self.Frames.Lines][#self.Frames.Texts[#self.Frames.Lines]]
			if lastLabel:IsA("TextLabel") and lastLabel.Text == " " then -- get rid of trailing space
				lineContainer.Size = UDim2.new(0, self.LinePosition - labelWidth - lastLabel.Size.X.Offset, 1, 0)
				lastLabel:Destroy()

				table.remove(self.Frames.Texts[#self.Frames.Lines])
			end

			self:AddLine()
			endOfLineCallback()
		else
			-- Label is ok
			newLabel.Size = UDim2.new(0, labelWidth, 0, labelHeight)
			newLabel.Name = string.format("Group%03d", #self.Frames.Texts[#self.Frames.Lines] + 1)
			newLabel.Parent = lineContainer

			lineContainer.Size = UDim2.new(0, self.LinePosition, 1, 0)
			lineFrame.Size = UDim2.new(1, 0, 0, math.max(lineFrame.Size.Y.Offset, labelHeight))

			table.insert(self.Frames.Texts[#self.Frames.Lines], newLabel)
			self:AddFrameProperties(newLabel)

			self.Properties.Current.AnimateYield = 0
		end
	end
end

function RichText:PrintText(text: string)
	if text == "\n" then
		self:AddLine()
		return
	elseif text == " " and self.LinePosition == 0 then
		return -- no leading spaces
	end

	local textSize: number = self:GetTextSize()
	local textWidth: number = TextService:GetTextSize(
		text,
		textSize,
		self.Source.TextLabel.Font,
		Vector2.new(self.LayerCollector.AbsoluteSize.X, textSize)
	).X

	local newTextLabel: TextLabel = self.Source.TextLabel:Clone()
	newTextLabel.TextScaled = false
	newTextLabel.TextSize = textSize
	newTextLabel.Text = text -- This text is never actually displayed. We just use it as a reference for knowing what the group string is.
	newTextLabel.TextTransparency = 1
	newTextLabel.TextStrokeTransparency = 1
	newTextLabel.TextWrapped = false
	newTextLabel.TextColor3 = Color3.fromRGB(88, 63, 153)
	newTextLabel.Font = Enum.Font.Nunito

	-- Keep the real text in individual frames per character:
	local charPos = 0
	local i = 1
	for first, last in utf8.graphemes(text) do
		local character = string.sub(text, first, last)
		local characterWidth = TextService:GetTextSize(
			character,
			textSize,
			self.Source.TextLabel.Font,
			Vector2.new(self.LayerCollector.AbsoluteSize.X, textSize)
		).X

		local characterLabel = self.Source.TextLabel:Clone()
		characterLabel.Text = character
		characterLabel.TextScaled = false
		characterLabel.TextSize = textSize
		characterLabel.Position = UDim2.new(0, charPos, 0, 0)
		characterLabel.Size = UDim2.new(0, characterWidth + 1, 0, textSize)
		characterLabel.Name = string.format("Char%03d", i)
		characterLabel.Parent = newTextLabel
		characterLabel.Visible = false
		self:AddFrameProperties(characterLabel)
		charPos = charPos + characterWidth
		i = i + 1
	end

	self:FormatLabel(newTextLabel, textSize, textWidth, function()
		if not self.Overflown then
			self:PrintText(text)
		end
	end)
end

function RichText:PrintImage(imageId: string)
	local imageHeight: number = self:GetTextSize()
	local imageWidth: number = imageHeight -- Would be nice if we could get aspect ratio of image to get width properly.

	local newImageLabel = self.Source.ImageLabel:Clone()

	if Utility.SHORT_CUTS.Images[imageId] then
		newImageLabel.Image = typeof(Utility.SHORT_CUTS.Images[imageId]) == "number"
				and "rbxassetid://" .. Utility.SHORT_CUTS.Images[imageId]
			or Utility.SHORT_CUTS.Images[imageId]
	else
		newImageLabel.Image = "rbxassetid://" .. imageId
	end
	newImageLabel.Size = UDim2.new(0, imageHeight, 0, imageWidth)
	newImageLabel.Visible = false

	self:FormatLabel(newImageLabel, imageHeight, imageWidth, function()
		if not self.Overflown then
			self:PrintImage(imageId)
		end
	end)
end

function RichText:PrintSeries(labelSeries: { string })
	for _, t: string in pairs(labelSeries) do
		local markupKey: string?, markupValue: string? = string.match(t, "<(.+)=(.+)>")
		if markupKey and markupValue then
			if not self:ApplyMarkup(markupKey, markupValue) then
				warn("Could not apply markup: ", t)
			end
		else
			self:PrintText(t)
		end
	end
end

function RichText:ContinueOverflow(newFrame: Frame, prevTextObject: TextObject.TextObject)
	return RichText.new(newFrame, nil, nil, false, prevTextObject)
end

function RichText:Animate(waitToFinish: boolean, reversed: boolean)
	self.TextObject:Animate(waitToFinish, reversed)
end

function RichText:Show(finishAnimation: boolean)
	self.TextObject:Show(finishAnimation)
end

function RichText:Hide()
	self.TextObject:Hide()
end

return RichText
