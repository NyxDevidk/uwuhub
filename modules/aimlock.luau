--!strict
-- AimLock Module
-- Sistema de mira assistida para UwU Hub

local AimLock = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- Tipos
export type AimMode = {
	Name: string,
	Smoothness: number,
	Description: string
}

export type Config = {
	AimPart: string,
	TeamCheck: boolean,
	WallCheck: boolean,
	FOVMultiplier: number
}

export type State = {
	Enabled: boolean,
	CurrentModeIndex: number,
	FOVRadius: number,
	SelectedTarget: Player?,
	Dragging: boolean
}

-- Configurações
AimLock.Config: Config = {
	AimPart = "Head",
	TeamCheck = true,
	WallCheck = false,
	FOVMultiplier = 1.5
}

-- Modos de Mira
AimLock.Modes: {AimMode} = {
	{Name = "Suave 🌸", Smoothness = 0.04, Description = "Leve e discreto"},
	{Name = "Legit ✨", Smoothness = 0.15, Description = "Equilibrado"},
	{Name = "Intenso 💫", Smoothness = 0.60, Description = "Rápido e preciso"}
}

-- Estado
AimLock.State: State = {
	Enabled = false,
	CurrentModeIndex = 1,
	FOVRadius = 5,
	SelectedTarget = nil,
	Dragging = false
}

-- UI Elements
AimLock.UI: {[string]: any} = {}

local localPlayer = Players.LocalPlayer

-- Utilitário
local function create<T>(className: string, props: {[string]: any}?): T
	local obj = Instance.new(className)
	if props then 
		for k, v in pairs(props) do 
			(obj :: any)[k] = v
		end 
	end
	return obj :: any
end

-- Verificar visibilidade através de paredes
local function isVisible(targetPart: BasePart): boolean
	if not AimLock.Config.WallCheck then 
		return true 
	end
	
	local origin = Camera.CFrame.Position
	local direction = targetPart.Position - origin
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {localPlayer.Character, targetPart.Parent}
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	
	local result = workspace:Raycast(origin, direction.unit * direction.Magnitude, raycastParams)
	return result == nil
end

-- Obter alvo
function AimLock:GetTarget(): (BasePart?, Vector2?)
	local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
	local radius = (self.State.FOVRadius / 10) * Camera.ViewportSize.X * 0.2 * self.Config.FOVMultiplier
	
	-- Target fixo selecionado
	if self.State.SelectedTarget then
		local char = self.State.SelectedTarget.Character
		if char and char:FindFirstChild(self.Config.AimPart) then
			local part = char:FindFirstChild(self.Config.AimPart) :: BasePart
			local hum = char:FindFirstChild("Humanoid") :: Humanoid?
			if hum and hum.Health > 0 then
				local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
				return part, Vector2.new(screenPos.X, screenPos.Y)
			end
		end
		return nil, nil
	end
	
	-- Auto target (mais próximo no FOV)
	local closest: BasePart? = nil
	local closestDist = math.huge
	local closestPos: Vector2? = nil
	local myRoot = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	
	if not myRoot then 
		return nil, nil 
	end
	
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= localPlayer and plr.Character then
			if self.Config.TeamCheck and plr.Team == localPlayer.Team and plr.Team ~= nil then 
				continue 
			end
			
			local part = plr.Character:FindFirstChild(self.Config.AimPart) :: BasePart?
			local root = plr.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
			local hum = plr.Character:FindFirstChild("Humanoid") :: Humanoid?
			
			if part and root and hum and hum.Health > 0 then
				local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
				if onScreen then
					local v2Pos = Vector2.new(screenPos.X, screenPos.Y)
					local distCircle = (v2Pos - center).Magnitude
					
					if distCircle <= radius then
						local dist3D = (root.Position - myRoot.Position).Magnitude
						if dist3D < closestDist and isVisible(part) then
							closestDist = dist3D
							closest = part
							closestPos = v2Pos
						end
					end
				end
			end
		end
	end
	
	return closest, closestPos
end

-- Inicializar
function AimLock:Initialize(): ()
	print("[UwU Hub] 🎯 Inicializando AimLock...")
	
	-- Obter UI do módulo principal
	local UI = require(script.Parent.Parent.ui.main)
	local contentFrame = UI:GetContentFrame()
	
	if not contentFrame then
		warn("[UwU Hub] ❌ Content frame não encontrado!")
		return
	end
	
	-- Criar UI do AimLock
	self:CreateUI(contentFrame)
	
	-- Criar Circle Overlay
	self:CreateOverlay(UI.Screen)
	
	-- Iniciar Loop de Targeting
	self:StartTargeting()
	
	print("[UwU Hub] ✅ AimLock inicializado!")
end

-- Criar UI (Parte 1)
function AimLock:CreateUI(parent: Frame): ()
	local content = create("Frame", {
		Name = "AimLockContent",
		Parent = parent,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Visible = true
	})
	
	-- Toggle Button
	self.UI.Toggle = create("TextButton", {
		Parent = content,
		Size = UDim2.new(0, 170, 0, 34),
		Position = UDim2.new(0, 20, 0, 10),
		BackgroundColor3 = Color3.fromRGB(200, 50, 100),
		Text = "🎯 Aim: OFF",
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = Color3.new(1, 1, 1),
	})
	create("UICorner", {Parent = self.UI.Toggle, CornerRadius = UDim.new(0, 8)})
	
	self.UI.Toggle.MouseButton1Click:Connect(function()
		self:ToggleAimAssist()
	end)
	
	-- FOV Label
	create("TextLabel", {
		Parent = content,
		Text = "🔘 FOV Radius:",
		Font = Enum.Font.GothamSemibold,
		TextSize = 13,
		TextColor3 = Color3.fromRGB(220, 220, 220),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 200, 0, 10),
		Size = UDim2.new(0, 100, 0, 34),
		TextXAlignment = Enum.TextXAlignment.Left
	})
	
	-- Input Box FOV
	self.UI.ValueBox = create("TextBox", {
		Parent = content,
		Size = UDim2.new(0, 50, 0, 24),
		Position = UDim2.new(0, 310, 0, 15),
		BackgroundColor3 = Color3.fromRGB(30, 30, 35),
		Text = "5",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		ClearTextOnFocus = true,
		PlaceholderText = "1-10"
	})
	create("UICorner", {Parent = self.UI.ValueBox, CornerRadius = UDim.new(0, 6)})
	create("UIStroke", {Parent = self.UI.ValueBox, Color = Color3.fromRGB(255, 105, 180), Thickness = 1})
	
	-- Slider Track
	local track = create("Frame", {
		Parent = content,
		Position = UDim2.new(0, 200, 0, 50),
		Size = UDim2.new(0, 280, 0, 8),
		BackgroundColor3 = Color3.fromRGB(40, 40, 45),
	})
	create("UICorner", {Parent = track, CornerRadius = UDim.new(1, 0)})
	
	-- Slider Fill
	self.UI.SliderFill = create("Frame", {
		Parent = track,
		Size = UDim2.new(0.5, 0, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(255, 105, 180),
	})
	create("UICorner", {Parent = self.UI.SliderFill, CornerRadius = UDim.new(1, 0)})
	
	self.UI.Track = track
	
	-- Continua na próxima parte...
	self:CreateUIControls(content)
	
	self.UI.Content = content
end

-- Criar Controles da UI (Parte 2)
function AimLock:CreateUIControls(content: Frame): ()
	-- Mode Button
	self.UI.ModeBtn = create("TextButton", {
		Parent = content,
		Size = UDim2.new(0, 460, 0, 36),
		Position = UDim2.new(0, 20, 0, 75),
		BackgroundColor3 = Color3.fromRGB(40, 30, 50),
		Text = "⚡ Modo: " .. self.Modes[self.State.CurrentModeIndex].Name,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = Color3.new(1, 1, 1),
	})
	create("UICorner", {Parent = self.UI.ModeBtn, CornerRadius = UDim.new(0, 8)})
	
	self.UI.ModeBtn.MouseButton1Click:Connect(function()
		self:CycleMo()
	end)
	
	-- Target Status
	self.UI.TargetStatus = create("TextLabel", {
		Parent = content,
		Text = "🎯 Alvo: Auto (Nenhum)",
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = Color3.fromRGB(150, 150, 150),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 20, 0, 125),
		Size = UDim2.new(0, 460, 0, 20),
		TextXAlignment = Enum.TextXAlignment.Center
	})
	
	-- Player List Button
	self.UI.ListBtn = create("TextButton", {
		Parent = content,
		Size = UDim2.new(0, 460, 0, 34),
		Position = UDim2.new(0, 20, 0, 155),
		BackgroundColor3 = Color3.fromRGB(100, 50, 150),
		Text = "👥 SELECIONAR PLAYER",
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = Color3.new(1, 1, 1),
	})
	create("UICorner", {Parent = self.UI.ListBtn, CornerRadius = UDim.new(0, 8)})
	
	-- Eventos do slider serão adicionados depois
	self:SetupSlider()
end

-- Toggle Aim Assist
function AimLock:ToggleAimAssist(): ()
	self.State.Enabled = not self.State.Enabled
	if self.State.Enabled then
		self.UI.Toggle.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
		self.UI.Toggle.Text = "🎯 Aim: ON"
	else
		self.UI.Toggle.BackgroundColor3 = Color3.fromRGB(200, 50, 100)
		self.UI.Toggle.Text = "🎯 Aim: OFF"
	end
end

-- Alternar modo
function AimLock:CycleMo(): ()
	self.State.CurrentModeIndex = (self.State.CurrentModeIndex % #self.Modes) + 1
	self.UI.ModeBtn.Text = "⚡ Modo: " .. self.Modes[self.State.CurrentModeIndex].Name
end

-- Setup do Slider
function AimLock:SetupSlider(): ()
	-- Implementação completa do slider...
	-- (continuaria aqui com os eventos do slider)
end

-- Criar Overlay (círculo FOV)
function AimLock:CreateOverlay(screen: ScreenGui?): ()
	if not screen then return end
	
	local overlay = create("Frame", {
		Parent = screen,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ZIndex = 50
	})
	
	self.UI.Circle = create("Frame", {
		Parent = overlay,
		Size = UDim2.new(0, 200, 0, 200),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
	})
	create("UICorner", {Parent = self.UI.Circle, CornerRadius = UDim.new(1, 0)})
	self.UI.CircleStroke = create("UIStroke", {
		Parent = self.UI.Circle,
		Color = Color3.fromRGB(255, 105, 180),
		Thickness = 2,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	})
end

-- Iniciar Targeting Loop
function AimLock:StartTargeting(): ()
	RunService:BindToRenderStep("UwUHubAimAssist", Enum.RenderPriority.Camera.Value + 1, function()
		self:Update()
	end)
end

-- Update Loop
function AimLock:Update(): ()
	if not self.State.Enabled then return end
	
	local targetPart, screenPos = self:GetTarget()
	
	if targetPart and screenPos then
		local smoothness = self.Modes[self.State.CurrentModeIndex].Smoothness
		Camera.CFrame = Camera.CFrame:Lerp(
			CFrame.new(Camera.CFrame.Position, targetPart.Position),
			smoothness
		)
	end
end

-- Cleanup
function AimLock:Cleanup(): ()
	RunService:UnbindFromRenderStep("UwUHubAimAssist")
	if self.UI.Content then
		self.UI.Content:Destroy()
	end
	print("[UwU Hub] 🧹 AimLock cleanup completo")
end

return AimLock