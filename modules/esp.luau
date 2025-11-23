--!strict
-- ESP Module para UwU Hub
-- Sistema de ESP/Wallhack visual

local ESP = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Tipos
export type ESPConfig = {
	Enabled: boolean,
	ShowNames: boolean,
	ShowDistance: boolean,
	ShowHealth: boolean,
	ShowBoxes: boolean,
	TeamCheck: boolean,
	MaxDistance: number
}

export type ESPObject = {
	Player: Player,
	Box: Frame?,
	Name: TextLabel?,
	Distance: TextLabel?,
	Health: Frame?,
	Connection: RBXScriptConnection?
}

-- Configurações
ESP.Config: ESPConfig = {
	Enabled = false,
	ShowNames = true,
	ShowDistance = true,
	ShowHealth = true,
	ShowBoxes = true,
	TeamCheck = true,
	MaxDistance = 1000
}

-- Estado
ESP.State = {
	Initialized = false,
	ESPObjects = {} :: {[Player]: ESPObject},
	Container = nil :: ScreenGui?
}

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

-- Criar Container para ESP
function ESP:CreateContainer(): ()
	local playerGui = localPlayer:WaitForChild("PlayerGui") :: PlayerGui
	
	self.State.Container = create("ScreenGui", {
		Name = "UwUHubESP",
		ResetOnSpawn = false,
		Parent = playerGui,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	})
end

-- Criar ESP para um player
function ESP:CreateESPForPlayer(player: Player): ()
	if self.State.ESPObjects[player] then
		return
	end
	
	if not self.State.Container then
		self:CreateContainer()
	end
	
	-- Frame principal (Box)
	local box = create("Frame", {
		Parent = self.State.Container,
		Size = UDim2.new(0, 100, 0, 100),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = false
	})
	
	-- Borda do box
	local stroke = create("UIStroke", {
		Parent = box,
		Color = Color3.fromRGB(255, 105, 180),
		Thickness = 2,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	})
	
	-- Nome do player
	local nameLabel = create("TextLabel", {
		Parent = box,
		Size = UDim2.new(1, 0, 0, 20),
		Position = UDim2.new(0, 0, 0, -25),
		BackgroundTransparency = 1,
		Text = player.Name,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextStrokeTransparency = 0.5,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Center
	})
	
	-- Distância
	local distanceLabel = create("TextLabel", {
		Parent = box,
		Size = UDim2.new(1, 0, 0, 16),
		Position = UDim2.new(0, 0, 1, 5),
		BackgroundTransparency = 1,
		Text = "0m",
		TextColor3 = Color3.fromRGB(200, 200, 200),
		TextStrokeTransparency = 0.5,
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Center
	})
	
	-- Barra de HP
	local healthBg = create("Frame", {
		Parent = box,
		Size = UDim2.new(0, 4, 1, 0),
		Position = UDim2.new(0, -8, 0, 0),
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
		BorderSizePixel = 0
	})
	create("UICorner", {Parent = healthBg, CornerRadius = UDim.new(0, 2)})
	
	local healthFill = create("Frame", {
		Parent = healthBg,
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0, 0, 1, 0),
		AnchorPoint = Vector2.new(0, 1),
		BackgroundColor3 = Color3.fromRGB(0, 255, 100),
		BorderSizePixel = 0
	})
	create("UICorner", {Parent = healthFill, CornerRadius = UDim.new(0, 2)})
	
	-- Armazenar
	self.State.ESPObjects[player] = {
		Player = player,
		Box = box,
		Name = nameLabel,
		Distance = distanceLabel,
		Health = healthFill,
		Connection = nil
	}
end

-- Remover ESP de um player
function ESP:RemoveESPForPlayer(player: Player): ()
	local espObj = self.State.ESPObjects[player]
	if not espObj then return end
	
	if espObj.Connection then
		espObj.Connection:Disconnect()
	end
	
	if espObj.Box then
		espObj.Box:Destroy()
	end
	
	self.State.ESPObjects[player] = nil
end

-- Atualizar ESP de um player
function ESP:UpdateESP(player: Player): ()
	if not self.Config.Enabled then return end
	if player == localPlayer then return end
	
	local espObj = self.State.ESPObjects[player]
	if not espObj or not espObj.Box then return end
	
	-- Team check
	if self.Config.TeamCheck and player.Team == localPlayer.Team and player.Team ~= nil then
		espObj.Box.Visible = false
		return
	end
	
	local character = player.Character
	if not character then
		espObj.Box.Visible = false
		return
	end
	
	local rootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart?
	local humanoid = character:FindFirstChild("Humanoid") :: Humanoid?
	
	if not rootPart or not humanoid or humanoid.Health <= 0 then
		espObj.Box.Visible = false
		return
	end
	
	-- Calcular distância
	local myRoot = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not myRoot then
		espObj.Box.Visible = false
		return
	end
	
	local distance = (rootPart.Position - myRoot.Position).Magnitude
	
	if distance > self.Config.MaxDistance then
		espObj.Box.Visible = false
		return
	end
	
	-- Converter posição 3D para 2D
	local camera = workspace.CurrentCamera
	local screenPos, onScreen = camera:WorldToViewportPoint(rootPart.Position)
	
	if not onScreen then
		espObj.Box.Visible = false
		return
	end
	
	-- Calcular tamanho do box baseado na distância
	local scaleFactor = 1000 / distance
	local boxSize = Vector2.new(
		math.clamp(scaleFactor * 4, 30, 150),
		math.clamp(scaleFactor * 6, 50, 200)
	)
	
	-- Atualizar posição e tamanho
	espObj.Box.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y)
	espObj.Box.Size = UDim2.new(0, boxSize.X, 0, boxSize.Y)
	espObj.Box.Visible = true
	
	-- Atualizar distância
	if espObj.Distance and self.Config.ShowDistance then
		espObj.Distance.Text = string.format("%.0fm", distance)
		espObj.Distance.Visible = true
	elseif espObj.Distance then
		espObj.Distance.Visible = false
	end
	
	-- Atualizar HP
	if espObj.Health and self.Config.ShowHealth then
		local healthPercent = humanoid.Health / humanoid.MaxHealth
		espObj.Health.Size = UDim2.new(1, 0, healthPercent, 0)
		
		-- Cor da barra de HP
		if healthPercent > 0.6 then
			espObj.Health.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
		elseif healthPercent > 0.3 then
			espObj.Health.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
		else
			espObj.Health.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
		end
		espObj.Health.Visible = true
	elseif espObj.Health then
		espObj.Health.Visible = false
	end
	
	-- Atualizar nome
	if espObj.Name then
		espObj.Name.Visible = self.Config.ShowNames
	end
end

-- Loop de atualização
function ESP:StartUpdateLoop(): ()
	RunService:BindToRenderStep("UwUHubESP", Enum.RenderPriority.Camera.Value, function()
		if not self.Config.Enabled then return end
		
		for player, _ in pairs(self.State.ESPObjects) do
			self:UpdateESP(player)
		end
	end)
end

-- Inicializar
function ESP:Initialize(): ()
	print("[UwU Hub] 👁️ Inicializando ESP...")
	
	self:CreateContainer()
	
	-- Adicionar ESP para players existentes
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= localPlayer then
			self:CreateESPForPlayer(player)
		end
	end
	
	-- Listener para novos players
	Players.PlayerAdded:Connect(function(player)
		task.wait(1)
		self:CreateESPForPlayer(player)
	end)
	
	-- Listener para players saindo
	Players.PlayerRemoving:Connect(function(player)
		self:RemoveESPForPlayer(player)
	end)
	
	-- Iniciar loop de atualização
	self:StartUpdateLoop()
	
	self.State.Initialized = true
	print("[UwU Hub] ✅ ESP inicializado!")
end

-- Toggle ESP
function ESP:Toggle(): ()
	self.Config.Enabled = not self.Config.Enabled
	
	if not self.Config.Enabled then
		for _, espObj in pairs(self.State.ESPObjects) do
			if espObj.Box then
				espObj.Box.Visible = false
			end
		end
	end
	
	print(`[UwU Hub] ESP {self.Config.Enabled and "ativado ✨" or "desativado 😴"}`)
end

-- Cleanup
function ESP:Cleanup(): ()
	RunService:UnbindFromRenderStep("UwUHubESP")
	
	for player, _ in pairs(self.State.ESPObjects) do
		self:RemoveESPForPlayer(player)
	end
	
	if self.State.Container then
		self.State.Container:Destroy()
		self.State.Container = nil
	end
	
	print("[UwU Hub] 🧹 ESP cleanup completo")
end

return ESP