# Installation / Quick Start

Este documento mostra formas rápidas de executar o UwU Hub a partir do GitHub ou com fallbacks para executores diferentes.

One-liner (raw GitHub)
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/NyxDevidk/uwuhub/main/UwUHub.luau"))()
```

Sinapse X (Synapse) fallback
```lua
loadstring(syn.request({Url = "https://raw.githubusercontent.com/NyxDevidk/uwuhub/main/UwUHub.luau", Method = "GET"}).Body)()
```

Outro executor com `request`
```lua
loadstring(request({Url = "https://raw.githubusercontent.com/NyxDevidk/uwuhub/main/UwUHub.luau", Method = "GET"}).Body)()
```

Notas
- Sempre verifique a URL raw no navegador: `https://raw.githubusercontent.com/<user>/<repo>/<branch>/<path>`.
- Se o seu executor bloquear `game:HttpGet`, use os fallbacks acima.
- O carregamento da Rayfield (UI alternativa) é tentado automaticamente pelo `ui/main.luau` via:
```lua
loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
```

Configuração opcional (Rayfield)
- `ui/main.luau` cria a janela Rayfield com `ConfigurationSaving` habilitado por padrão:
  - Folder: `UwUHub`
  - FileName: `config`
- Se desejar desabilitar o salvamento, edite o código ou modifique os parâmetros de `CreateWindow`.

Testando localmente
- Para desenvolvimento local (não via loadstring), você pode requerer `UwUHub.luau` diretamente em um `LocalScript` durante testes. Exemplo:
```lua
local UwUHub = require(path.to.UwUHub) -- ajuste o caminho
UwUHub:Initialize()
```

Aviso de segurança
- Não execute scripts de fontes não confiáveis. Considere verificar o conteúdo e/ou hashes antes de executar remote loadstrings.