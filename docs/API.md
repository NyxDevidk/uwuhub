# API Reference

Este documento descreve as funções públicas e propriedades que os módulos expõem para integração programática.

## AimLock (modules/aimlock.luau)
- `AimLock:Initialize(useGui)`
  - Inicializa o módulo. Se `useGui == false`, pula a criação da GUI legada (útil quando usando Rayfield).
- `AimLock:SetEnabled(boolean)`
  - Habilita ou desabilita o AimLock.
- `AimLock:SetFOV(number)`
  - Define o valor do FOV (clamp entre 1 e 50).
- `AimLock:SetMode(number)`
  - Escolhe o modo (índice em `AimLock.Modes`).
- `AimLock.Keybind` (Enum.KeyCode)
  - Tecla usada para alternar/segurar o AimLock.
- `AimLock.KeyMode` (string)
  - "Toggle" ou "Hold". Define o comportamento da tecla.
- `AimLock:SetupRayfieldControls(tab)`
  - Cria toggles/sliders/dropdowns/keybind no Rayfield tab passado.

## ESP (modules/esp.luau)
- `ESP:Initialize(useGui)`
  - Inicializa o módulo; `useGui == false` pula a criação da GUI legada.
- `ESP:SetEnabled(boolean)`
  - Habilita/desabilita o ESP.
- `ESP.SetupRayfieldControls(tab)`
  - Cria controles no Rayfield (toggle, opções de exibição e slider de alcance).

## UI (ui/main.luau)
- A UI tenta carregar a Rayfield automaticamente (se disponível) e cria uma janela com:
  - `ConfigurationSaving` habilitado (por padrão `UwUHub/config`)
  - Tabs para `AimLock` e `ESP` que chamam `SetupRayfieldControls` dos módulos
- Se a Rayfield não estiver disponível, a GUI legada (`ScreenGui`) é criada e usada pelos módulos.

## Utils
- `modules/utils.luau` contém helpers de fetch e exec (se presente) — funções para buscar via `syn.request`, `request`, `game:HttpGet` e wrapper `execRemote`/`execString` (consulte o arquivo para detalhes).

Notas
- Todas as chamadas externas (fetch/load) usam `pcall` onde aplicável para evitar crashing direto no executor.
- A integração com Rayfield usa `pcall` para detectar suporte a métodos (ex.: `CreateKeybind`, `CreateColorPicker`). Se a Rayfield não fornecer uma API específica, a integração faz fallback para controles simples.

Se quiser, posso gerar um arquivo mais detalhado com assinaturas de funções e exemplos para cada método (responda "detalhar API").