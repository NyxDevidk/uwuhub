# Examples

Exemplos práticos de uso e integração do UwU Hub.

## Carregar via loadstring (one-liner)
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/NyxDevidk/uwuhub/main/UwUHub.luau"))()
```

## Versão segura (fetch + pcall + loadstring)
```lua
local url = "https://raw.githubusercontent.com/NyxDevidk/uwuhub/main/UwUHub.luau"
local ok, body = pcall(function()
    if syn and syn.request then return syn.request({Url = url, Method = "GET"}).Body end
    if request then return request({Url = url, Method = "GET"}).Body end
    if http and http.request then return http.request({Url = url, Method = "GET"}).Body end
    if game and game.HttpGet then return game:HttpGet(url) end
    error("Nenhum método HTTP disponível")
end)

if not ok or not body or #body == 0 then
    warn("Falha ao obter script:", body)
    return
end

local chunk, loadErr = loadstring(body)
if not chunk then
    warn("loadstring error:", loadErr)
    return
end

local success, runRes = pcall(chunk)
if not success then
    warn("Erro ao executar script:", runRes)
end
```

## Usando módulos programaticamente (ex.: AimLock)
```lua
local AimLock = require(path.to.modules.aimlock)
-- inicializa sem criar GUI legada (bom quando usando Rayfield)
AimLock:Initialize(false)

-- ligar o AimLock
AimLock:SetEnabled(true)

-- mudar FOV
AimLock:SetFOV(8)

-- mudar modo (1..n)
AimLock:SetMode(2)

-- ajustar keybind em runtime
AimLock.Keybind = Enum.KeyCode.Z
AimLock.KeyMode = "Hold"
```

## Integração Rayfield (exemplo conceitual)
- A `ui/main.luau` tenta carregar a Rayfield e chama `AimLock:SetupRayfieldControls(tab)` e `ESP:SetupRayfieldControls(tab)` para construir a interface.
- Os controles incluem toggles, sliders, dropdowns, keybinds e color pickers (quando suportados pela Rayfield).

## Testes rápidos
- Carregue o `UwUHub.luau` no executor e verifique se a Rayfield aparece. Caso não apareça, verifique no output se houve erros ao buscar o `sirius.menu`.
- Teste toggles e keybinds (LeftAlt / LeftCtrl por padrão) e ajuste conforme necessário.

Se precisar, eu adapto estes exemplos para snippets HTML com destaque de código prontos para colocar no site.