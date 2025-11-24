# UwU Hub — Overview

UwU Hub é um hub modular escrito em Luau para ambientes Roblox/executor. O objetivo é fornecer um conjunto pequeno e consistente de módulos (AimLock, ESP, Utils) com uma UI integrada e compatibilidade opcional com a biblioteca Rayfield.

Principais objetivos
- Código modular e extensível.
- Interfaces opcionais: GUI legada (ScreenGui) e integração com Rayfield.
- APIs públicas para controlar módulos sem depender da GUI.

Principais funcionalidades
- AimLock: mira assistida com modos (Suave, Legit, Intenso), FOV configurável, checagem de parede e suporte a keybind (Toggle/Hold).
- ESP: boxes, nomes, distância, barra de vida, filtros por equipe e alcance máximo.
- UI: UI própria (`ui/main.luau`) e integração com Rayfield (carrega Rayfield se disponível e cria janela de controles).
- Utils: funções utilitárias para fetch remoto, logging e helpers comuns.

Estrutura do repositório
```
UwUHub.luau
modules/
    aimlock.luau
    esp.luau
    utils.luau
ui/
    main.luau
README.md
PROJECT_SUMMARY.txt
docs/
    Overview.md
    Installation.md
    API.md
    Examples.md
```

Compatibilidade
- Projetado para ser executado por executores que suportem `loadstring` e APIs de HTTP comuns (`game:HttpGet`, `syn.request`, `request`, `http.request`).
- Alguns recursos dependem de permissões/executor (carregamento de Rayfield, HttpGet, etc.).

Segurança
- Executar código remoto possui riscos: o hub usa `pcall` para evitar crashes, mas ainda executa código vindo da internet. Use apenas fontes confiáveis e, se possível, verifique hashes/assinaturas.

Licença & contato
- Veja `README.md` para instruções de contribuição e informação de licença. Owner: `NyxDevidk` (repositório GitHub).