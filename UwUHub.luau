--!strict
-- UwU Hub - Main Entry Point
-- Arquivo principal que inicializa todo o Hub

local UwUHub = {}

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Módulos (ajuste os caminhos conforme sua estrutura)
local UI = require(script.Parent.ui.main)
local AimLock = require(script.Parent.modules.aimlock)
local ESP = require(script.Parent.modules.esp)
local Utils = require(script.Parent.modules.utils)

-- Tipos
export type Config = {
	Version: string,
	Name: string,
	Discord: string
}

export type State = {
	Initialized: boolean,
	ActiveModules: {[string]: any},
	CurrentTab: string
}

-- Configuração Global
UwUHub.Config: Config = {
	Version = "1.0.0",
	Name = "UwU HUB",
	Discord = "discord.gg/uwuhub"
}

-- Estado Global
UwUHub.State: State = {
	Initialized = false,
	ActiveModules = {},
	CurrentTab = "AimLock"
}

-- Inicialização do Hub
function UwUHub:Initialize(): ()
	if self.State.Initialized then
		warn("⚠️ UwU Hub já foi inicializado!")
		return
	end
	
	Utils.Logger.Info("Inicializando UwU Hub... ✨")
	
	-- Limpar UI anterior se existir
	local localPlayer = Players.LocalPlayer
	local playerGui = localPlayer:WaitForChild("PlayerGui") :: PlayerGui
	local old = playerGui:FindFirstChild("UwUHubUI")
	if old then 
		old:Destroy()
		Utils.Logger.Info("UI anterior removida")
	end
	
	-- Inicializar Interface
	UI:Create(self.Config)
	Utils.Logger.Success("Interface criada")
	
	-- Carregar Módulos
	self:LoadModule("AimLock", AimLock)
	self:LoadModule("ESP", ESP)
	
	self.State.Initialized = true
	Utils.Logger.Success("UwU Hub inicializado com sucesso! 🌸")
	Utils.Notify("UwU Hub", "Inicializado com sucesso! 🌸", 3)
end

-- Carregar um módulo específico
function UwUHub:LoadModule(name: string, module: any): ()
	if self.State.ActiveModules[name] then
		Utils.Logger.Warn(`Módulo {name} já está carregado!`)
		return
	end
	
	Utils.Logger.Info(`Carregando módulo: {name}`)
	
	-- Verificar se o módulo tem função Initialize
	if module.Initialize then
		local success, err = pcall(function()
			module:Initialize()
		end)
		
		if not success then
			Utils.Logger.Error(`Erro ao inicializar {name}: {err}`)
			return
		end
	end
	
	self.State.ActiveModules[name] = module
	Utils.Logger.Success(`Módulo {name} carregado`)
end

-- Descarregar um módulo
function UwUHub:UnloadModule(name: string): ()
	local module = self.State.ActiveModules[name]
	if not module then 
		Utils.Logger.Warn(`Módulo {name} não encontrado`)
		return 
	end
	
	-- Executar cleanup se existir
	if module.Cleanup then
		local success, err = pcall(function()
			module:Cleanup()
		end)
		
		if not success then
			Utils.Logger.Error(`Erro ao limpar {name}: {err}`)
		end
	end
	
	self.State.ActiveModules[name] = nil
	Utils.Logger.Info(`Módulo {name} descarregado`)
end

-- Obter um módulo específico
function UwUHub:GetModule(name: string): any?
	return self.State.ActiveModules[name]
end

-- Alternar um módulo (enable/disable)
function UwUHub:ToggleModule(name: string): boolean?
	local module = self.State.ActiveModules[name]
	if not module then 
		Utils.Logger.Warn(`Módulo {name} não encontrado`)
		return nil
	end
	
	if module.Toggle then
		module:Toggle()
		return true
	end
	
	return false
end

-- Recarregar um módulo
function UwUHub:ReloadModule(name: string): ()
	Utils.Logger.Info(`Recarregando módulo: {name}`)
	
	local module = self.State.ActiveModules[name]
	if module then
		self:UnloadModule(name)
		task.wait(0.5)
		self:LoadModule(name, module)
	end
end

-- Cleanup completo do Hub
function UwUHub:Cleanup(): ()
	Utils.Logger.Info("Iniciando cleanup do UwU Hub...")
	
	-- Descarregar todos os módulos
	for name, _ in pairs(self.State.ActiveModules) do
		self:UnloadModule(name)
	end
	
	-- Limpar interface
	if UI.Cleanup then
		local success, err = pcall(function()
			UI:Cleanup()
		end)
		
		if not success then
			Utils.Logger.Error(`Erro ao limpar UI: {err}`)
		end
	end
	
	self.State.Initialized = false
	self.State.ActiveModules = {}
	
	Utils.Logger.Success("Cleanup completo! 🧹")
end

-- Obter informações do Hub
function UwUHub:GetInfo(): {Version: string, ModulesLoaded: number, IsInitialized: boolean}
	return {
		Version = self.Config.Version,
		ModulesLoaded = 0,
		IsInitialized = self.State.Initialized
	}
end

-- Auto-inicializar quando o script carregar
task.spawn(function()
	-- Aguardar um pouco para garantir que tudo carregou
	task.wait(1)
	
	local success, err = pcall(function()
		UwUHub:Initialize()
	end)
	
	if not success then
		warn(`❌ Erro ao inicializar UwU Hub: {err}`)
	end
end)

-- Cleanup ao sair do jogo
game:GetService("Players").LocalPlayer.AncestryChanged:Connect(function()
	if not game:GetService("Players").LocalPlayer:IsDescendantOf(game) then
		UwUHub:Cleanup()
	end
end)

return UwUHub