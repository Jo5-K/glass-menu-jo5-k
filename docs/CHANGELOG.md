# Glass Menu - Jo5-k — 0.1.7

Mod independente para G1R 0.3.97+, API 3, Emerald, Ruby, Sapphire, FireRed e LeafGreen.

Ative Glass Menu - Jo5-k no gerenciador de mods. Nas opções do próprio mod, escolha Original (interface nativa), Glass (padrão), Marfim ou GBA. A opção Glass Menu permite desativar sua apresentação sem remover os arquivos. A persistência é a do gerenciador nativo.

Altera os painéis padronizados dos menus de campo e o texto que usa a cor padrão. Mantém posições, textos estruturados, traduções, imagens, ícones, callbacks e comandos originais. Não modifica mapa, sprites, câmera, iluminação ou dados do jogo. Menus abertos durante batalha ficam excluídos, incluindo a evolução originada por batalha.

Esta versão inicial estiliza molduras e preenchimentos compartilhados pelo sistema Window/Chrome. Telas com fundos desenhados em imagens próprias, como partes da mochila, Pokédex, armazenamento e cartão, conservam essas imagens. Interfaces próprias de outros mods que não usam os componentes nativos também as conservam. Não é uma substituição visual completa dessas telas.

Não há dependência do 2D Battle Menu, nem conflito declarado com ele. Não altera o mod anterior. Não inclui atualização automática ou publicação no GitHub.

## Verificação

Testado com o carregador oficial 0.3.97 e seu SDK simulado nos cinco jogos: carregamento API 3, desenho dos painéis, restauração do estado gráfico, identidade dos textos traduzidos, retornos nativos, exclusão em batalha, delegação de entrada e limpeza idempotente. Sem ROM, GPU real ou teste físico em Android nesta execução. A aparência final precisa de validação no jogo.

O módulo skin.lua reutiliza o desenho de painéis do projeto 2D Battle Menu - Jo5-k. Nenhum recurso de cenários, Pokémon ou iluminação é carregado.

## 0.1.1

START → GLASS abre a seleção de tema. Original não modifica molduras, preenchimentos ou texto. Painéis claros com contraste, borda fina e sombra discreta substituem os cartões escuros da primeira versão. Os nomes dos temas foram encurtados. Placas mantêm sua geometria e arte nativas.

## 0.1.2

Corrigida a seleção START → GLASS: desenho e texto usam a fonte ROM da terceira geração, sem depender de glifos da primeira geração. A lista mantém Original, Glass, Marfim e GBA e acrescenta Atual e Clássico, adaptados para menus de campo. As sombras das letras contrastam com a cor principal: escuras em letras claras e claras em letras escuras. Cores semânticas de texto são preservadas; opções de fonte e paletas são copiadas sem modificar tabelas nativas. Original continua sem interferência visual.

Testes do carregador oficial nos cinco jogos incluem desenho da tela de configuração em cada tema, seleção e persistência, restauração nativa em Original, contraste das sombras, preservação de textos e exclusão de batalha. Testes sem ROM/GPU: confirmação visual no aplicativo ainda necessária. Nenhum arquivo do 2D Battle Menu foi alterado nesta correção.

## 0.1.3 — configuração atual

Tema e Texto são preferências independentes, disponíveis em START → GLASS e no gerenciador nativo. Temas: Original, Glass, Marfim, GBA, Atual, Clássico e Flutuante. Texto: Nativo (padrão, preserva integralmente as opções nativas), Claro (sombra escura) e Escuro (sombra clara). Mudar o tema nunca muda a opção Texto. Original com Texto Nativo restaura a apresentação original; pode também ser combinado com um dos estilos de texto. A lista de ajustes possui rolagem e seis linhas visíveis. Esta regra substitui o contraste automático por tema das versões anteriores.

Validado no SDK do carregador oficial para os cinco jogos: sete temas × três estilos de texto, desenho dos ajustes, persistência e exclusão das batalhas. Sem confirmação visual com ROM ou dispositivo Android.

## 0.1.4

A própria tela GLASS acompanha agora o fundo do tema selecionado; a opção Texto permanece independente. Acrescentados Emerald Verde (verde-petróleo #366B5A, reflexo #3B7663, sombra #173C33) e Emerald GBA (paleta original do módulo Floating Glass: #526B63, #7B9484, #293A42), mantendo os sete temas anteriores.

Novo adaptador de superfícies: fundos nativos da mochila, equipe, resumo, Pokédex, loja, estojo de TMs, bolsa de frutas e molduras/fundo do PC. Superfícies carregadas pelo scene_kit e mapas de interface da Pokédex são identificados para receber a paleta na GPU. Texturas de Pokémon, retratos, ícones, tipos, status e mapas geográficos ficam excluídas. Não muda coordenadas, dados ou navegação. Não aplica filtro à tela inteira. Shaders nativos em uso têm precedência. Sem suporte a shader, conserva o desenho nativo dessas superfícies. Cartões e telas com desenho proprietário fora desses pontos podem conservar elementos nativos; não há substituição indiscriminada de imagens.

Verificado no carregador oficial dos cinco jogos e em teste específico de seleção de superfícies, preservação de retratos/mapas, exclusão da batalha e restauração do shader em caso de erro. Não houve validação com ROM/GPU real nem Android.

## 0.1.5 — menus sobre o mundo

Menús de campo gerenciados deixam de suprimir o plano do mundo. Pokédex, mochila, equipe, resumo, opções, salvar, cartão, PC, loja e nomeação mantêm sua navegação modal, sem liberar movimento do personagem. Original, desativação, batalhas e minigames preservam a decisão nativa de tela inteira. Fundos gráficos têm 87% de opacidade; o preenchimento integral de preparação usa 8%, evitando ocultar novamente o mundo sob a imagem. Painéis grandes recebem a paleta selecionada. Textos e sombras continuam independentes do tema. Sem suporte a shader, superfícies recebem modulação de cor e alpha, sem processamento de pixels por CPU. O fechamento ou a troca para Original não modifica as flags nativas persistentes das camadas.

Testes simulados: roteamento do mundo em onze telas, preservação de Original/batalha/minigame, restauração de cor, seletividade das superfícies e carregamento nos cinco jogos. Não houve validação visual em ROM/GPU ou Android físico nesta execução. Apenas Glass Menu alterado; Floating Glass legado permanece intacto.

## 0.1.6 — Pokédex e Trainer Card

Corrigidos os identificadores reais de camada rse_pokedex e trainer, ausentes na exclusão de tela inteira. Pokédex Hoenn usa principalmente renderMap (4 bpp), além de renderMap8 (8 bpp); ambas as etapas de fundo agora são interceptadas. Cartão Emerald: camadas front/back/screen são reconhecidas por caminho sem incluir o retrato, insígnias ou estrelas. Cartão FRLG: fundos privados de 240×160 são tratados somente durante o desenho do cartão; quads de ícones e Canvas final não recebem filtro. RS: fundo do Canvas privado é limpo com alpha zero, e modulação de cor/alpha mantém os shaders nativos de fade/virada. Original e desativação preservam o desenho nativo. Texto permanece independente.

Testes específicos cobrem renderMap principal da Pokédex, seleção de fundo de cartão sem recolorir retratos e identificadores reais das camadas; carregador oficial passou nos cinco jogos. Ainda sem conferência visual de ROM/GPU ou Android físico.

## 0.1.7 — PC

Adicionados os identificadores item_pc e rse_item_storage ao tratamento flutuante. As texturas privadas do PC são registradas por identidade após PcChrome.ensure: fundo, moldura, botões, painel da equipe, slots pequenos, janela de escolher caixa e faixa de transição. O tema não envolve o desenho completo da equipe: Pokémon, itens, cursores, textos e papel de parede selecionado para a caixa continuam separados. Os menus e confirmações que usam Window/Chrome mantêm seus dados e navegação nativos.

Testes simulados cobrem aplicação do tema em slots de 32×24, preservação do papel de parede, retorno nativo de ensure, identificadores do depósito, exclusão de Original e batalha, e carregamento API 3 nos cinco jogos. Sem validação visual de ROM/GPU ou Android físico. Apenas instalação local; ainda não há release 0.1.7 no índice.
