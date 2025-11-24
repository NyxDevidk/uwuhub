--!strict
-- UI Main Module (Rayfield Only)

local UI = {}
local Rayfield = nil

function UI:Create(config: {Name: string, Discord: string}): ()
	print("[UwU Hub] Carregando Rayfield...")
	
	-- Load Rayfield
	local ok, result = pcall(function()
		return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
	end)
	
	if not ok or not result then
		warn("[UwU Hub] Falha ao carregar Rayfield")
		return
	end
	
	Rayfield = result
	
	-- Create Window
	local Window = Rayfield:CreateWindow({
		Name = config.Name or "UwU Hub",
		LoadingTitle = config.Name or "UwU Hub",
		LoadingSubtitle = config.Discord or "",
		ConfigurationSaving = {Enabled = true, Folder = "UwUHub", FileName = "config"},
		Theme = {
			TextColor = Color3.fromRGB(250, 240, 250),
			Background = Color3.fromRGB(28, 20, 30),
			Topbar = Color3.fromRGB(45, 20, 35),
			Shadow = Color3.fromRGB(15, 10, 15),
			NotificationBackground = Color3.fromRGB(30, 20, 30),
			NotificationActionsBackground = Color3.fromRGB(250, 240, 250),
			TabBackground = Color3.fromRGB(60, 40, 55),
			TabStroke = Color3.fromRGB(70, 45, 65),
			TabBackgroundSelected = Color3.fromRGB(255, 220, 235),
			TabTextColor = Color3.fromRGB(240, 230, 240),
			SelectedTabTextColor = Color3.fromRGB(40, 20, 30),
			ElementBackground = Color3.fromRGB(35, 25, 35),
			ElementBackgroundHover = Color3.fromRGB(45, 30, 45),
			SecondaryElementBackground = Color3.fromRGB(25, 20, 25),
			ElementStroke = Color3.fromRGB(80, 50, 70),
			SecondaryElementStroke = Color3.fromRGB(60, 40, 55),
			SliderBackground = Color3.fromRGB(255, 105, 180),
			SliderProgress = Color3.fromRGB(255, 130, 200),
			SliderStroke = Color3.fromRGB(255, 160, 220),
			ToggleBackground = Color3.fromRGB(30, 25, 30),
			ToggleEnabled = Color3.fromRGB(255, 105, 180),
			ToggleDisabled = Color3.fromRGB(130, 110, 130),
			ToggleEnabledStroke = Color3.fromRGB(255, 140, 200),
			ToggleDisabledStroke = Color3.fromRGB(125, 125, 125),
			ToggleEnabledOuterStroke = Color3.fromRGB(160, 120, 140),
			ToggleDisabledOuterStroke = Color3.fromRGB(65, 65, 65),
			DropdownSelected = Color3.fromRGB(45, 30, 40),
			DropdownUnselected = Color3.fromRGB(30, 20, 30),
			InputBackground = Color3.fromRGB(30, 25, 30),
			InputStroke = Color3.fromRGB(70, 50, 70),
			PlaceholderColor = Color3.fromRGB(200, 180, 200)
		},
		Discord = {Enabled = false},
		KeySystem = false,
	})
	
	-- Tabs
	local AimTab = Window:CreateTab("🎯 AimLock")
	local EspTab = Window:CreateTab("👁️ ESP")
	
	-- Load AimLock
	local AimLock = nil
	pcall(function()
		AimLock = require(script.Parent.Parent.modules.aimlock)
		if AimLock then
			AimLock:Initialize(false)
			if AimLock.SetupRayfieldControls then
				AimLock:SetupRayfieldControls(AimTab)
			end
		end
	end)
	
	-- Load ESP
	local ESP = nil
	pcall(function()
		ESP = require(script.Parent.Parent.modules.esp)
		if ESP then
			ESP:Initialize(false)
			if ESP.SetupRayfieldControls then
				ESP:SetupRayfieldControls(EspTab)
			end
		end
	end)
	
	print("[UwU Hub] ✅ Interface carregada!")
end

return UI
