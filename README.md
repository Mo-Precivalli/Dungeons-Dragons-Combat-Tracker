# 🐉 Rastreador de Combate D&D (D&D Combat Tracker)

Bem-vindo ao **Rastreador de Combate D&D**! Este é o seu assistente digital completo para mestres gerenciarem campanhas e encontros de RPG (**Dungeons & Dragons 5e / 2024**).

Desenvolvido para ser **rápido**, **intuitivo** e **visualmente organizado**, ele permite que você foque na narrativa da mesa enquanto o aplicativo cuida da matemática, iniciativa, concentração, testes contra a morte e ordem dos turnos.

---

## ✨ Funcionalidades Principais

*   **🛡️ Campanhas e Grupos Fixos de Jogadores**:
    *   Crie múltiplas **Campanhas / Grupos** com os personagens fixos da sua mesa (Nome, Classe, CA, PV Máximo e Bônus de Iniciativa).
    *   Filtre seus combates por campanha na tela inicial para não misturar mesas diferentes.
    *   **Sincronização Automática**: Jogadores adicionados ou editados dentro de um combate vinculado a uma campanha são salvos automaticamente no grupo da campanha para os próximos encontros.
*   **🎲 Iniciativa ao Começar a Luta**:
    *   Sempre que um combate é iniciado/aberto, o app exibe a janela **Iniciativa da Luta**, separando **Jogadores** e **Monstros / NPCs**.
    *   Digite o valor rolado pelos jogadores na mesa ou use os botões rápidos **Rolar Monstros**, **Rolar Todos** ou o dado individual (`1d20`) de cada participante.
    *   Adicione novos monstros, NPCs ou jogadores diretamente dessa janela antes de clicar em **Começar Luta!**.
*   **📖 Bestiário D&D 5e Integrado & Criação Rápida**:
    *   Fluxo guiado para adicionar **Jogador** (com as 13 classes de D&D, ícones e cores próprias), **Monstro do Bestiário** (filtrado por Tipo e Nível de Desafio — ND), **Monstro Customizado** ou **NPC / Aliado**.
    *   Suporte a adição de múltiplos monstros de uma só vez (ex: *4x Goblin*), com numeração automática e opção de **PV Médio** ou **Rolar PV nos Dados** (ex: `2d6`).
*   **❤️ Controle Inteligente de Vida (HP) e HP Temporário**:
    *   Ajuste rápido de dano (`-`) e cura (`+`) com incremento padrão de `1` (basta clicar sem digitar) ou qualquer valor digitado no campo.
    *   **Escudo de HP Temporário**: O dano recebido é descontado automaticamente do HP Temporário antes de reduzir os pontos de vida reais.
    *   Barra de vida ampla com porcentagem (`%`) e cores dinâmicas (verde, âmbar e vermelho).
*   **⚡ Alerta Automático de Teste de Concentração**:
    *   Quando um combatente com a condição **Concentrando** sofre dano, o card exibe um alerta em vermelho calculando automaticamente a **CD do teste de Constituição** (`CD = máx(10, dano ÷ 2)`).
    *   Botões rápidos **Permanece** (mantém a magia) e **Perde** (remove a condição *Concentrando* imediatamente) direto no card.
*   **💀 Testes Contra a Morte (Death Saves)**:
    *   Quando um **Jogador** cai a `0 HP`, o card exibe o painel interativo de **Sucessos** e **Falhas** contra a morte (`0/3`).
    *   Ao completar 3 sucessos, o personagem recebe automaticamente a condição **Estabilizado**; com 3 falhas, é marcado como **Morto**.
*   **↩️ Botão Desfazer (Undo Multi-nível)**:
    *   Errou o valor do dano ou avançou o turno sem querer? O botão **Desfazer** na barra superior reverte passo a passo as últimas ações (dano, cura, avanço de turno, condições, testes de concentração/morte e iniciativas).
*   **🏷️ Condições e Status de D&D**:
    *   Adicione ou remova condições oficiais (*Caído*, *Concentrando*, *Envenenado*, *Invisível*, *Atordoado*, etc.) com um toque.
*   **🎯 Rolagem Inteligente e Sem Piscar (Zero Flicker)**:
    *   A lista acompanha o turno ativo suavemente apenas quando o card sai da área visível da tela, sem recarregar ou piscar a interface.
*   **🌗 Temas Claro e Escuro**:
    *   Alterne entre **Modo Claro** e **Modo Escuro** a qualquer momento na barra superior.

---

## 📖 Guia do Mestre (Como Usar)

### 1. Criando Campanhas e Grupos (Opcional, mas Recomendado!)
1. Na tela inicial, toque no ícone de **Grupos** (`👥`) no topo ou em **Nova Campanha** na barra de filtros.
2. Crie sua campanha (ex: *"Maldição de Strahd"*) e cadastre os heróis do grupo.
3. Sempre que criar um novo combate para essa campanha, os jogadores já entrarão automaticamente!

### 2. Criando e Iniciando um Combate
1. Toque no botão **+** na tela inicial.
2. Escolha o nome do encontro (ex: *"Emboscada Goblin"*) e selecione a **Campanha / Grupo** (ou deixe como *Combate Avulso*).
3. Ao entrar no combate, a janela **Iniciativa da Luta** será aberta:
   * Adicione os monstros ou NPCs do encontro clicando em **Adicionar Monstro / NPC / Jogador**.
   * Insira ou role (`🎲`) a iniciativa de cada participante e clique em **Começar Luta!**.

### 3. Entendendo o Card do Combatente
Cada participante possui um card otimizado em **duas faixas horizontais**:

*   **Faixa Superior (Identidade e Ações Rápidas)**:
    *   **Esquerda**: Círculo com a **Iniciativa** e pílula com a **CA (Classe de Armadura)**.
    *   **Centro**: Nome completo (com destaque de cor e ícone da Classe, Monstro ou NPC), etiqueta de **Classe / Tipo e ND**, além dos chips de **HP Temporário** e **Condições** ativas.
    *   **Direita**: Botões rápidos de **HP Temporário** (`🛡️`), **Condições** (`🏷️`) e menu `⋮` (**Editar** / **Excluir**).
*   **Faixa Inferior (Vida e Controles)**:
    *   **Esquerda**: Barra de progresso de HP com valores `Atual / Máximo HP` e porcentagem.
    *   **Direita**: Cápsula `[-] [ 1 ] [+]` para aplicar dano ou cura rapidamente.

### 4. Gerenciando Turnos e Rodadas
*   O combatente ativo do turno recebe uma **borda dourada/colorida em destaque**.
*   Use o botão **PRÓXIMO TURNO** na barra inferior para avançar na ordem de iniciativa e incrementar as **Rodadas** automaticamente.
*   Precisa corrigir algo? Toque no ícone **Desfazer (`↩️`)** na barra superior para voltar a última movimentação.

---

## 🏗️ Arquitetura do Projeto

O projeto segue uma arquitetura limpa e modularizada em camadas:

```text
lib/
├── data/
│   ├── models/          # Modelos persistidos no Hive (Combat, Combatant, Campaign, PartyHero)
│   ├── repositories/    # Implementação concreta (HiveCombatRepository)
│   └── monster_database.dart # Catálogo de classes D&D 5e e Bestiário por Tipo/ND
├── domain/
│   ├── repositories/    # Contratos desacoplados (ICombatRepository)
│   └── services/        # Gerenciador de histórico/Undo (CombatUndoManager)
└── presentation/
    ├── controllers/     # Controladores de estado (CombatController, ThemeController)
    ├── providers/       # Serviço de aplicação e providers Riverpod (CombatTrackerService)
    ├── screens/         # Telas (Dashboard, Campaigns, CreateCombat, CombatDetail)
    └── widgets/         # Componentes modulares (CombatantCard, CombatInitiativeDialog, etc.)
```

---

## 🛠️ Para Desenvolvedores

### Executar o Projeto
```bash
flutter pub get
flutter run
```

### Executar Análise Estática e Testes Automatizados
```bash
flutter analyze
flutter test
```

### Gerar APK de Release (Android)
```bash
flutter build apk --release
```
O arquivo será gerado em: `build/app/outputs/flutter-apk/app-release.apk`

### Tecnologias Utilizadas
*   **Flutter** (UI Multiplataforma — Android, iOS, Web, Desktop)
*   **Flutter Riverpod** (Injeção de Dependência e Gerenciamento de Estado)
*   **Hive** (Banco de Dados Local NoSQL de alta performance)
*   **Google Fonts** (Tipografia `Inter` e `Cinzel`)

---

*Que os dados rolem sempre a seu favor! (Ou não, sou o Mestre afinal... 😈)*
