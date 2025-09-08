--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Signal = require(ReplicatedStorage.Packages.Signal)
local SheetValues = require(ServerScriptService.Packages.SheetValues)
local Openday = require(ReplicatedStorage.Shared.Openday)

local SPREAD: string = "1gxT3-AHXrl0HAP5eG-CvN2IVVjrZpxKgmBiMp84EWRc"
local SHEETS = {}

local _Loaded: boolean = false

export type SheetManager = {
	Values: { [string]: any },
	LastUpdated: number,
	LastSource: string,

	Changed: RBXScriptSignal<any>,

	UpdateValues: (self: SheetManager) -> { [string]: any },
	GetValue: (self: SheetManager, valueId: string, defaultValue: any) -> { [string]: any },
	GetValueChangedSignal: (self: SheetManager, valueName: string) -> RBXScriptSignal<any, any>,
	Destroy: (self: SheetManager) -> (),
}

export type System = {
	_Extensions: { Openday.Extension },
	_Start: (self: System) -> (),
	_Setup: (self: System) -> (),

	Get: (self: System, SheetsName: string, id: string) -> { [string]: any }?,
	Ready: (self: System) -> boolean,

	Sheets: { [string]: SheetManager },
	Loaded: Signal.Signal<nil>,
}

local Sheets: System = {} :: System

local function CountDictionary(dict: { [string]: any }): number
	local count = 0
	for _, _ in dict do
		count += 1
	end

	return count
end

function Sheets:_Setup()
	self.Sheets = {}
	self.Loaded = Signal()

	local count: number = CountDictionary(SHEETS)
	local loaded: number = 0
	for name: string, id: number in pairs(SHEETS) do
		local sheet: SheetManager = SheetValues.new(SPREAD, tostring(id))

		sheet.Changed:Connect(function()
			self.Sheets[name] = sheet
			print("🦀| " .. name .. " Sheets updated!")

			loaded += 1
			if loaded == count then
				print("🦀| Libraries loaded!")
				self.Loaded:Fire()
				_Loaded = true
				task.defer(function()
					self.Loaded:DisconnectAll()
				end)
			end
		end)
	end
end

function Sheets:_Start() end

function Sheets:Get(sheetsName: string, id: string)
	if not _Loaded then
		return
	end

	local sheet: SheetManager = self.Sheets[sheetsName]
	if sheet then
		return sheet:GetValue(id)
	end

	return
end

function Sheets:Ready(): boolean
	return _Loaded
end

return Sheets
