 # UwU Hub

 > Um Hub modular escrito em Luau para Roblox (UI + módulos utilitários).

 ## Descrição

 UwU Hub é um projeto em Luau que oferece uma interface simples e módulos reutilizáveis para funcionalidades de visualização e assistência de mira (ESP, AimLock) com uma camada utilitária (`utils`) e uma UI minimalista. O código está organizado de forma modular para facilitar extensão e manutenção.

 ## Principais Features

 - AimLock: Sistema de mira assistida com modos e overlay de FOV.
 - ESP: Sistema de visualização de jogadores (boxes, nomes, distância e barra de vida).
 - Utils: Biblioteca utilitária (funções matemáticas, raycast, logging, UI helpers, etc.).
 - UI: Interface principal com abas, controles e animações.

 ## Estrutura do Projeto

 ```
 UwUHub.luau
 modules/
     aimlock.luau
     esp.luau
     utils.luau
 ui/
     main.luau
 ```

 ## Arquivos principais

 - `UwUHub.luau`: entrypoint que inicializa a UI e carrega os módulos.
 - `modules/aimlock.luau`: implementação do assistente de mira (AimLock).
 - `modules/esp.luau`: implementação do ESP (boxes, nomes, distância e HP).
 - `modules/utils.luau`: funções utilitárias compartilhadas e sistema de logging.
 - `ui/main.luau`: criação e gerenciamento da interface do usuário.

 ## Como usar

 1. Coloque o conteúdo deste projeto em um ambiente de execução Luau/Roblox (por exemplo, dentro de um `LocalScript` para testes locais).
 2. Requeira o entrypoint e inicialize o Hub:

 ```lua
 local UwUHub = require(path.to.UwUHub) -- ajuste o caminho conforme necessário
 UwUHub:Initialize()
 ```

 ## Configuração e Personalização

 - As configurações padrão estão definidas dentro de cada módulo (`AimLock.Config`, `ESP.Config`, `Utils.Version`, etc.).
 - Para alterar comportamentos (por exemplo, mudar `AimPart` de `Head` para `Torso`), edite `modules/aimlock.luau`.
 - A UI é criada em `ui/main.luau`. Você pode ajustar cores, tamanhos e posicionamento por lá.

 ## Notas de desenvolvimento

 - Código tipado usando `--!strict` e `export type` para melhorar a qualidade.
 - Módulos usam funções `Initialize`, `Toggle` e `Cleanup` para facilitar carregamento/descarga.
 - Funções utilitárias em `modules/utils.luau` são desenhadas para serem reutilizáveis por outros módulos.

 ## Boas práticas

 - Sempre rode testes em um ambiente isolado.
 - Não compartilhe credenciais nem IDs sensíveis.
 - Documente qualquer alteração significativa em cada módulo.

 ## Aviso de responsabilidade

 Este repositório contém código destinado ao aprendizado, experimentação e desenvolvimento de interfaces e padrões modulares em Luau. Não incentive ou instrua comportamento que viole termos de serviço de plataformas. Use este código de forma ética e responsável.

 ## Contribuições

 Se quiser contribuir:

 - Abra uma issue com a descrição do problema/feature.
 - Faça um fork, crie uma branch, implemente a mudança e envie um pull request.

 ## Licença

 Adicione aqui a licença desejada (por exemplo, MIT) ou remova esta seção se for privado.

 ## Contato

 Se quiser ajuda ou quiser que eu melhore o README (mais exemplos, badges, passos de deploy, screenshots), diga o que quer e eu atualizo.
