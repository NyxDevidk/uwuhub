--!strict
-- Utils Module - Funções Utilitárias
-- Biblioteca de funções compartilhadas para UwU Hub

local Utils = {}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- ========================================
-- CRIAÇÃO DE INSTÂNCIAS
-- ========================================

-- Criar instância com propriedades tipadas
function Utils.Create<T>(className: string, properties: {[string]: any}?): T
	local instance = Instance.new(className)
	if properties then
		for k, v in pairs(properties) do
			(instance :: any)[k] = v
		end
	end
	return instance :: any
end

-- ========================================
-- PLAYERS & CHARACTERS
-- ========================================

-- Verificar se player é da mesma equipe
function Utils.IsTeammate(player1: Player?, player2: Player?): boolean
	if not player1 or not player2 then 
		return false 
	end
	if player1.Team == nil or player2.Team == nil then 
		return false 
	end
	return player1.Team == player2.Team
end

-- Verificar se character é válido e está vivo
function Utils.IsValidCharacter(character: Model?): boolean
	if not character then 
		return false 
	end
	
	local humanoid = character:FindFirstChild("Humanoid") :: Humanoid?
	local rootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart?
	
	return humanoid ~= nil 
		and humanoid.Health > 0 
		and rootPart ~= nil
end

-- Obter parte específica do character
function Utils.GetCharacterPart(character: Model?, partName: string): BasePart?
	if not character then 
		return nil 
	end
	return character:FindFirstChild(partName) :: BasePart?
end

-- Obter todos os players vivos
function Utils.GetAlivePlayers(excludeLocalPlayer: boolean?): {Player}
	local players: {Player} = {}
	local localPlayer = Players.LocalPlayer
	
	for _, player in pairs(Players:GetPlayers()) do
		if excludeLocalPlayer and player == localPlayer then 
			continue 
		end
		
		if Utils.IsValidCharacter(player.Character) then
			table.insert(players, player)
		end
	end
	
	return players
end

-- Obter player mais próximo
function Utils.GetClosestPlayer(
	fromPosition: Vector3, 
	teamCheck: boolean?,
	maxDistance: number?
): Player?
	local localPlayer = Players.LocalPlayer
	local closestPlayer: Player? = nil
	local closestDistance = maxDistance or math.huge
	
	for _, player in pairs(Utils.GetAlivePlayers(true)) do
		if teamCheck and Utils.IsTeammate(player, localPlayer) then
			continue
		end
		
		local root = Utils.GetCharacterPart(player.Character, "HumanoidRootPart")
		if root then
			local distance = (root.Position - fromPosition).Magnitude
			if distance < closestDistance then
				closestDistance = distance
				closestPlayer = player
			end
		end
	end
	
	return closestPlayer
end

-- ========================================
-- MATEMÁTICA & GEOMETRIA
-- ========================================

-- Calcular distância entre dois objetos
function Utils.GetDistance(obj1: BasePart?, obj2: BasePart?): number
	if not obj1 or not obj2 then 
		return math.huge 
	end
	return (obj1.Position - obj2.Position).Magnitude
end

-- Interpolar valores (lerp)
function Utils.Lerp(a: number, b: number, t: number): number
	return a + (b - a) * t
end

-- Clampar valor entre min e max
function Utils.Clamp(value: number, min: number, max: number): number
	return math.max(min, math.min(max, value))
end

-- Verificar se valor está entre um range
function Utils.InRange(value: number, min: number, max: number): boolean
	return value >= min and value <= max
end

-- Formatar número com casas decimais
function Utils.FormatNumber(num: number, decimals: number?): number
	decimals = decimals or 0
	local mult = 10 ^ decimals
	return math.floor(num * mult + 0.5) / mult
end

-- Arredondar para o inteiro mais próximo
function Utils.Round(num: number): number
	return math.floor(num + 0.5)
end

-- Interpolação suave de CFrame
function Utils.LerpCFrame(a: CFrame, b: CFrame, t: number): CFrame
	return a:Lerp(b, t)
end

-- Verificar distância 2D na tela
function Utils.GetScreenDistance(pos1: Vector2, pos2: Vector2): number
	return (pos1 - pos2).Magnitude
end

-- ========================================
-- CAMERA & VISIBILIDADE
-- ========================================

-- Verificar se posição está na tela
function Utils.IsOnScreen(camera: Camera, position: Vector3): boolean
	local _, onScreen = camera:WorldToViewportPoint(position)
	return onScreen
end

-- Verificar se está no FOV
function Utils.IsInFOV(
	camera: Camera, 
	targetPosition: Vector3, 
	fovRadius: number
): boolean
	local screenPos, onScreen = camera:WorldToViewportPoint(targetPosition)
	if not onScreen then 
		return false 
	end
	
	local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
	local targetPos2D = Vector2.new(screenPos.X, screenPos.Y)
	local distance = (targetPos2D - center).Magnitude
	
	return distance <= fovRadius
end

-- ========================================
-- RAYCASTING
-- ========================================

-- Raycast simples e seguro
function Utils.Raycast(
	origin: Vector3, 
	direction: Vector3, 
	ignoreList: {Instance}?
): RaycastResult?
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = ignoreList or {}
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.IgnoreWater = true
	
	return Workspace:Raycast(origin, direction, raycastParams)
end

-- Verificar line of sight (visão direta)
function Utils.HasLineOfSight(
	from: Vector3, 
	to: Vector3, 
	ignoreList: {Instance}?
): boolean
	local direction = to - from
	local result = Utils.Raycast(from, direction, ignoreList)
	return result == nil
end

-- Raycast para chão
function Utils.GetFloorPosition(position: Vector3, maxDistance: number?): Vector3?
	maxDistance = maxDistance or 100
	local origin = position
	local direction = Vector3.new(0, -maxDistance, 0)
	
	local result = Utils.Raycast(origin, direction, {})
	if result then
		return result.Position
	end
	
	return nil
end

-- ========================================
-- FORMATAÇÃO & STRINGS
-- ========================================

-- Converter segundos para formato MM:SS
function Utils.FormatTime(seconds: number): string
	local mins = math.floor(seconds / 60)
	local secs = seconds % 60
	return string.format("%02d:%02d", mins, secs)
end

-- Formatar número grande com K, M, B
function Utils.FormatNumberShort(num: number): string
	if num >= 1000000000 then
		return string.format("%.1fB", num / 1000000000)
	elseif num >= 1000000 then
		return string.format("%.1fM", num / 1000000)
	elseif num >= 1000 then
		return string.format("%.1fK", num / 1000)
	else
		return tostring(math.floor(num))
	end
end

-- Capitalizar primeira letra
function Utils.Capitalize(str: string): string
	return str:sub(1, 1):upper() .. str:sub(2):lower()
end

-- UwUfy texto (Easter Egg)
function Utils.UwUfy(text: string): string
	return text
		:gsub("[lL]", "w")
		:gsub("[rR]", "w")
		.. " 🌸"
end

-- ========================================
-- TABELAS & ARRAYS
-- ========================================

-- Deep copy de tabelas
function Utils.DeepCopy<T>(original: T): T
	local copy: any
	
	if type(original) == "table" then
		copy = {}
		for k, v in next, original :: any, nil do
			copy[Utils.DeepCopy(k)] = Utils.DeepCopy(v)
		end
		setmetatable(copy, Utils.DeepCopy(getmetatable(original :: any)))
	else
		copy = original
	end
	
	return copy
end

-- Verificar se tabela contém valor
function Utils.TableContains(tbl: {any}, value: any): boolean
	for _, v in pairs(tbl) do
		if v == value then
			return true
		end
	end
	return false
end

-- Contar elementos em tabela
function Utils.TableCount(tbl: {[any]: any}): number
	local count = 0
	for _ in pairs(tbl) do
		count = count + 1
	end
	return count
end

-- Limpar tabela
function Utils.TableClear(tbl: {[any]: any}): ()
	for k in pairs(tbl) do
		tbl[k] = nil
	end
end

-- ========================================
-- RANDOM & ALEATORIEDADE
-- ========================================

-- Randomizar com seed (para consistência)
function Utils.SeededRandom(seed: number, min: number?, max: number?): number
	local rng = Random.new(seed)
	if min and max then
		return rng:NextNumber(min, max)
	end
	return rng:NextNumber()
end

-- Escolher elemento aleatório de array
function Utils.RandomChoice<T>(array: {T}): T?
	if #array == 0 then return nil end
	return array[math.random(1, #array)]
end

-- Embaralhar array
function Utils.Shuffle<T>(array: {T}): {T}
	local shuffled = table.clone(array)
	for i = #shuffled, 2, -1 do
		local j = math.random(i)
		shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
	end
	return shuffled
end

-- ========================================
-- UI & NOTIFICAÇÕES
-- ========================================

-- Notificação UwU style
function Utils.Notify(title: string, text: string, duration: number?): ()
	duration = duration or 3
	
	local success = pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = "✨ " .. title,
			Text = text,
			Duration = duration,
			Icon = "rbxassetid://80222934775009"
		})
	end)
	
	if not success then
		warn(`[UwU Hub] Notificação falhou: {title} - {text}`)
	end
end

-- ========================================
-- LOGGING SYSTEM
-- ========================================

Utils.Logger = {
	-- Log informativo
	Info = function(msg: string): ()
		print(`[UwU Hub] ℹ️  {msg}`)
	end,
	
	-- Log de aviso
	Warn = function(msg: string): ()
		warn(`[UwU Hub] ⚠️  {msg}`)
	end,
	
	-- Log de erro
	Error = function(msg: string): ()
		error(`[UwU Hub] ❌ {msg}`)
	end,
	
	-- Log de sucesso
	Success = function(msg: string): ()
		print(`[UwU Hub] ✅ {msg}`)
	end,
	
	-- Log de debug
	Debug = function(msg: string): ()
		print(`[UwU Hub] 🐛 {msg}`)
	end,
	
	-- Log com timestamp
	Timestamped = function(msg: string): ()
		local timestamp = os.date("%H:%M:%S")
		print(`[UwU Hub] [{timestamp}] {msg}`)
	end
}

-- ========================================
-- PERFORMANCE & TIMING
-- ========================================

-- Debounce simples
function Utils.Debounce(func: () -> (), delay: number): () -> ()
	local lastRun = 0
	
	return function()
		local now = tick()
		if now - lastRun >= delay then
			lastRun = now
			func()
		end
	end
end

-- Medir tempo de execução
function Utils.Benchmark(func: () -> (), name: string?): number
	local startTime = tick()
	func()
	local endTime = tick()
	local duration = endTime - startTime
	
	if name then
		Utils.Logger.Debug(`Benchmark [{name}]: {duration * 1000}ms`)
	end
	
	return duration
end

-- ========================================
-- UTILITÁRIOS DE COR
-- ========================================

-- Converter RGB para HSV
function Utils.RGBtoHSV(color: Color3): (number, number, number)
	local r, g, b = color.R, color.G, color.B
	local max = math.max(r, g, b)
	local min = math.min(r, g, b)
	local delta = max - min
	
	local h, s, v = 0, 0, max
	
	if max ~= 0 then
		s = delta / max
	end
	
	if delta ~= 0 then
		if max == r then
			h = ((g - b) / delta) % 6
		elseif max == g then
			h = (b - r) / delta + 2
		else
			h = (r - g) / delta + 4
		end
		h = h / 6
	end
	
	return h, s, v
end

-- Interpolar cores
function Utils.LerpColor(a: Color3, b: Color3, t: number): Color3
	return Color3.new(
		Utils.Lerp(a.R, b.R, t),
		Utils.Lerp(a.G, b.G, t),
		Utils.Lerp(a.B, b.B, t)
	)
end

-- ========================================
-- VERSÃO & INFO
-- ========================================

Utils.Version = "1.0.0"
Utils.Author = "UwU Hub Team"

-- Obter informações do sistema
function Utils.GetSystemInfo(): {FPS: number, Ping: number, Memory: number}
	local stats = game:GetService("Stats")
	
	return {
		FPS = math.floor(1 / stats.RenderStepTime:GetValue()),
		Ping = math.floor(stats.Network.ServerStatsItem["Data Ping"]:GetValue()),
		Memory = math.floor(stats:GetTotalMemoryUsageMb())
	}
end

return Utils