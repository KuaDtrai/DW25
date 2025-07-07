--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerManager = require(script.PlayerManager)
local Promise = require(ReplicatedStorage.Packages.Promise)

export type System = {
	_Name: string?,
	_Setup: (System) -> (),
	_Start: (System) -> (),
	_Extensions: { Extension }?,
	[any]: any,
}

export type Extension = {
	_PreSetup: (System) -> ()?,
	_PreStart: (System) -> ()?,
	[any]: any,
}

export type Openday = {
	_Systems: { [string]: System },
	_Extensions: {
		Optionals: { [string]: Extension },
		Standard: { [string]: Extension },
	},
	_PlayerManager: PlayerManager.Connections,

	_RunExtensions: (self: Openday, funcName: string, system: System) -> (),
	AddExtensions: (self: Openday, storage: Folder | Model, extensionTypes: "Standard" | "Optionals") -> (),
	AddSystems: (self: Openday, storage: Folder | Model) -> (),

	Start: (self: Openday) -> Promise.Promise,
	OnStart: () -> (),
}

local Openday = {} :: Openday
Openday._PlayerManager = PlayerManager
Openday._Systems = {}
Openday._Extensions = {
	Standard = {},
	Optionals = {},
}

local _Started: boolean = false
local _Completed: boolean = false
local _OnComplete: BindableEvent = Instance.new("BindableEvent")

local function _Run(system: System, extension: Extension, funcName: string)
	local func = extension[funcName]
	if typeof(func) == "function" then
		func(extension, system)
	end
end

function Openday:_RunExtensions(funcName: string, system: System)
	for _: string, extension: Extension in self._Extensions.Standard do
		_Run(system, extension, funcName)
	end

	if system._Extensions then
		for _, extension: Extension in system._Extensions do
			_Run(system, extension, funcName)
		end
	end
end

function Openday:AddExtensions(storage: Folder | Model, extensionTypes: "Standard" | "Optionals")
	if _Started then
		error("Cannot add extensions after Openday has started", 2)
	end

	for _, object: Instance in storage:GetDescendants() do
		if not object:IsA("ModuleScript") then
			continue
		end

		if self._Extensions[extensionTypes][object.Name] then
			warn("Cannot add extension, extension already exist:", object.Name)
			continue
		end

		self._Extensions[extensionTypes][object.Name] = require(object) :: System
	end
end

function Openday:AddSystems(storage: Folder | Model)
	if _Started then
		error("Cannot add systems after Openday has started", 2)
	end

	for _, object: Instance in storage:GetDescendants() do
		if not object:IsA("ModuleScript") then
			continue
		end

		if self._Systems[object.Name] then
			warn("Cannot add system, system already exist:", object.Name)
			continue
		end

		self._Systems[object.Name] = require(object) :: System
	end
end

function Openday:Start(): Promise.Promise
	if _Started then
		return Promise.Reject("Openday already started")
	end
	_Started = true

	return Promise.new(function(Resolve: (...any) -> (), _: (...any) -> ())
		local setupPromises: { Promise.Promise } = {}

		for name: string, system: System in self._Systems do
			if typeof(system._Setup) == "function" then
				table.insert(
					setupPromises,
					Promise.new(function(SetupResolve: (...any) -> (), _: (...any) -> ())
						debug.setmemorycategory(name)

						self:_RunExtensions("_PreSetup", system)
						system:_Setup()

						SetupResolve()
					end)
				)
			end
		end

		Resolve(Promise.All(setupPromises))
	end):Then(function()
		for _: string, system: System in self._Systems do
			if typeof(system._Start) == "function" then
				task.spawn(function()
					self:_RunExtensions("_PreStart", system)
					system:_Start()
				end)
			end
		end

		_Completed = true
		_OnComplete:Fire()

		task.defer(function()
			_OnComplete:Destroy()
		end)
	end)
end

function Openday.OnStart()
	if _Completed then
		return Promise.Resolve()
	else
		return Promise.new(function(Resolve, _)
			local connection: RBXScriptConnection?
			connection = _OnComplete.Event:Connect(function()
				Resolve()
				if connection then
					connection:Disconnect()
					connection = nil
				end
			end)
		end)
	end
end

return Openday
