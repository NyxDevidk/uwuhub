--!strict
-- UI Main Module
-- Gerencia a interface principal do UwU Hub

local UI = {}

-- Rayfield integration (optional)
local Rayfield: any = nil
local RayfieldWindow: any = nil

local function tryLoadRayfield()
	local ok, rf = pcall(function()
		return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
	end)
	if ok and rf then
		Rayfield = rf
		return true
	end
	return false
end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Tipos
export type TabInfo = {
	Button: TextButton,
	Content: Frame?
}

-- Propriedades
UI.Screen: ScreenGui? = nil
UI.Main: Frame? = nil
UI.OpenBtn: ImageButton? = nil
UI.Tabs: {[string]: TabInfo} = {}
UI.CurrentTab: string = "AimLock"

-- Utilitário para criar elementos
local function create<T>(className: string, props: {[string]: any}?): T
	local obj = Instance.new(className)
	if props then 
		for k, v in pairs(props) do 
			(obj :: any)[k] = v
		end 
	end
	return obj :: any
end

-- Criar UI Principal
function UI:Create(config: {Name: string, Discord: string}): ()
	local localPlayer = Players.LocalPlayer
	local playerGui = localPlayer:WaitForChild("PlayerGui") :: PlayerGui
	
	-- ScreenGui Principal
	self.Screen = create("ScreenGui", {
		Name = "UwUHubUI",
		ResetOnSpawn = false,
		Parent = playerGui,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	})
	
	-- Botão de Abrir (minimizado)
	self:CreateOpenButton()
	
	-- Frame Principal
	self:CreateMainFrame(config)
	
	-- Criar Abas
	self:CreateTabs()
	
	-- Animação de entrada
	self:AnimateOpen()

	-- Tentar carregar Rayfield e criar uma janela adicional com controles
	local loaded = pcall(tryLoadRayfield)
	if loaded and Rayfield then
		local ok, err = pcall(function()
			RayfieldWindow = Rayfield:CreateWindow({
				Name = config.Name or "UwU Hub",
				LoadingTitle = config.Name or "UwU Hub",
				LoadingSubtitle = config.Discord or "",
				ConfigurationSaving = {Enabled = true, Folder = "UwUHub", FileName = "config"},
				Discord = {Enabled = false},
				KeySystem = false,
			})

			local aimTab = RayfieldWindow:CreateTab("AimLock")
			local espTab = RayfieldWindow:CreateTab("ESP")

			-- Setup Rayfield controls for AimLock and ESP
			local AimLock = require(script.Parent.Parent.modules.aimlock)
			local ESP = require(script.Parent.Parent.modules.esp)
			pcall(function()
				if AimLock then
					-- initialize logic without legacy GUI
					pcall(function() AimLock:Initialize(false) end)
					if AimLock.SetupRayfieldControls then
						AimLock:SetupRayfieldControls(aimTab)
					else
						-- fallback simple toggle
						aimTab:CreateToggle({
							Name = "Enable AimLock",
							CurrentValue = AimLock.State and AimLock.State.Enabled or false,
							Callback = function(val) pcall(function() AimLock:SetEnabled(val) end) end
						})
					end
					-- Keybind to toggle AimLock
					pcall(function()
						if aimTab.CreateKeybind then
							aimTab:CreateKeybind({
								Name = "Toggle AimLock Key",
								CurrentKey = Enum.KeyCode.LeftAlt,
								Mode = "Toggle",
								Flag = "AimLockKey",
								Callback = function(key)
									-- Toggle current state
									pcall(function()
										local cur = AimLock.State and AimLock.State.Enabled or false
										AimLock:SetEnabled(not cur)
									end)
								end
							})
						end
					end)
				end
				if ESP then
					pcall(function() ESP:Initialize(false) end)
					if ESP.SetupRayfieldControls then
						ESP:SetupRayfieldControls(espTab)
					else
						espTab:CreateToggle({
							Name = "Enable ESP",
							CurrentValue = ESP.Config and ESP.Config.Enabled or false,
							Callback = function(val) pcall(function() ESP:SetEnabled(val) end) end
						})
					end
					-- Keybind to toggle ESP
					pcall(function()
						if espTab.CreateKeybind then
							espTab:CreateKeybind({
								Name = "Toggle ESP Key",
								CurrentKey = Enum.KeyCode.LeftControl,
								Mode = "Toggle",
								Flag = "ESPKey",
								Callback = function(key)
									pcall(function()
										local cur = ESP.Config and ESP.Config.Enabled or false
										ESP:SetEnabled(not cur)
									end)
								end
							})
						end
					end)
					-- Color picker for ESP color (if supported by module)
					pcall(function()
						if espTab.CreateColorPicker then
							espTab:CreateColorPicker({
								Name = "ESP Color",
								Default = Color3.fromRGB(255, 105, 180),
								Flag = "ESPColor",
								Callback = function(color)
									-- apply color to existing ESP strokes if present
									pcall(function()
										if ESP and ESP.State and ESP.State.ESPObjects then
											for _, obj in pairs(ESP.State.ESPObjects) do
												if obj and obj.Box then
													local stroke = obj.Box:FindFirstChildOfClass("UIStroke")
													if stroke then stroke.Color = color end
												end
											end
										end)
									end)
								end
							})
						end
					end)
				end
			end)
		end)
		if not ok then
			warn("Rayfield loaded but window creation failed:", err)
		end
	end
end

-- Botão Abrir
function UI:CreateOpenButton(): ()
	self.OpenBtn = create("ImageButton", {
		Parent = self.Screen,
		Size = UDim2.new(0, 100, 0, 40),
		Position = UDim2.new(0, 10, 0.5, -20),
		BackgroundColor3 = Color3.fromRGB(24, 24, 24),
		Image = "rbxassetid://80222934775009",
		ImageTransparency = 0,
		ImageColor3 = Color3.new(1, 1, 1),
		ScaleType = Enum.ScaleType.Fit,
		Visible = false
	})
	create("UICorner", {Parent = self.OpenBtn, CornerRadius = UDim.new(0, 8)})
	create("UIStroke", {
		Parent = self.OpenBtn, 
		Color = Color3.fromRGB(255, 105, 180), -- Rosa UwU
		Thickness = 2
	})
	
	self.OpenBtn.MouseButton1Click:Connect(function()
		if self.Main then
			self.Main.Visible = true
			self.OpenBtn.Visible = false
			self:AnimateOpen()
		end
	end)
end

-- Frame Principal
function UI:CreateMainFrame(config: {Name: string, Discord: string}): ()
	self.Main = create("Frame", {
		Name = "Main",
		Size = UDim2.new(0, 500, 0, 300),
		Position = UDim2.new(0.5, -250, 0.5, -150),
		BackgroundColor3 = Color3.fromRGB(20, 20, 25),
		BorderSizePixel = 0,
		Parent = self.Screen,
		Active = true,
		Draggable = true
	})
	create("UICorner", {Parent = self.Main, CornerRadius = UDim.new(0, 12)})
	create("UIStroke", {
		Parent = self.Main,
		Color = Color3.fromRGB(255, 105, 180),
		Thickness = 2
	})
	
	-- Gradiente de fundo
	local gradient = create("UIGradient", {
		Parent = self.Main,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 25)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 20, 35))
		}),
		Rotation = 45
	})
	
	-- Botão Minimizar
	local minBtn = create("TextButton", {
		Parent = self.Main,
		Size = UDim2.new(0, 30, 0, 30),
		Position = UDim2.new(1, -35, 0, 5),
		BackgroundColor3 = Color3.fromRGB(200, 50, 100),
		Text = "−",
		Font = Enum.Font.GothamBold,
		TextSize = 20,
		TextColor3 = Color3.new(1, 1, 1)
	})
	create("UICorner", {Parent = minBtn, CornerRadius = UDim.new(0, 6)})
	
	minBtn.MouseButton1Click:Connect(function()
		self:AnimateClose()
		task.wait(0.2)
		if self.Main then
			self.Main.Visible = false
		end
		if self.OpenBtn then
			self.OpenBtn.Visible = true
		end
	end)
	
	-- Título com emoji UwU
	create("TextLabel", {
		Parent = self.Main,
		Text = "✨ " .. config.Name .. " ✨",
		Font = Enum.Font.GothamBold,
		TextSize = 20,
		TextColor3 = Color3.fromRGB(255, 105, 180),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 20, 0, 8),
		Size = UDim2.new(0, 300, 0, 28),
		TextXAlignment = Enum.TextXAlignment.Left
	})
	
	-- Subtítulo
	create("TextLabel", {
		Parent = self.Main,
		Text = "🌸 " .. config.Discord,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = Color3.fromRGB(200, 150, 200),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 20, 0, 36),
		Size = UDim2.new(0, 280, 0, 18),
		TextXAlignment = Enum.TextXAlignment.Left
	})
end

-- Criar Abas
function UI:CreateTabs(): ()
	local tabBar = create("Frame", {
		Parent = self.Main,
		Position = UDim2.new(0, 0, 0, 60),
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = Color3.fromRGB(15, 15, 20),
	})
	
	-- Content Frame
	local contentFrame = create("Frame", {
		Name = "Content",
		Parent = self.Main,
		Position = UDim2.new(0, 0, 0, 100),
		Size = UDim2.new(1, 0, 1, -100),
		BackgroundTransparency = 1,
	})
	
	-- Tab AimLock
	local aimLockBtn = create("TextButton", {
		Parent = tabBar,
		Size = UDim2.new(0.5, -5, 1, -2),
		Position = UDim2.new(0, 5, 0, 1),
		BackgroundColor3 = Color3.fromRGB(255, 105, 180),
		Text = "🎯 AIM LOCK",
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = Color3.new(1, 1, 1),
	})
	create("UICorner", {Parent = aimLockBtn, CornerRadius = UDim.new(0, 6)})
	
	-- Tab ESP
	local espBtn = create("TextButton", {
		Parent = tabBar,
		Size = UDim2.new(0.5, -5, 1, -2),
		Position = UDim2.new(0.5, 0, 0, 1),
		BackgroundColor3 = Color3.fromRGB(30, 30, 35),
		Text = "👁️ ESP",
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = Color3.fromRGB(150, 150, 150),
	})
	create("UICorner", {Parent = espBtn, CornerRadius = UDim.new(0, 6)})
	
	-- Armazenar
	self.Tabs.AimLock = {Button = aimLockBtn, Content = contentFrame}
	self.Tabs.ESP = {Button = espBtn}
	
	-- Eventos de clique (preparado para múltiplas abas)
	espBtn.MouseButton1Click:Connect(function()
		print("[UwU Hub] 🚧 ESP em desenvolvimento!")
	end)
end

-- Animações
function UI:AnimateOpen(): ()
	if not self.Main then return end
	
	local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	self.Main.Size = UDim2.new(0, 0, 0, 0)
	
	local tween = TweenService:Create(self.Main, tweenInfo, {
		Size = UDim2.new(0, 500, 0, 300)
	})
	tween:Play()
end

function UI:AnimateClose(): ()
	if not self.Main then return end
	
	local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In)
	local tween = TweenService:Create(self.Main, tweenInfo, {
		Size = UDim2.new(0, 0, 0, 0)
	})
	tween:Play()
end

-- Obter Content Frame
function UI:GetContentFrame(): Frame?
	return self.Main and self.Main:FindFirstChild("Content") :: Frame
end

-- Cleanup
function UI:Cleanup(): ()
	if self.Screen then
		self.Screen:Destroy()
	end
end

return UI