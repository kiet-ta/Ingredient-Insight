# 03. Runtime Flow (Mermaid v11.13.0)

## 1. Startup flow

```mermaid
flowchart TD
    A[Game boot] --> B[Load modinfo.lua]
    B --> C[Load modmain.lua]
    C --> D[require widgets/recipeboard]
    D --> E[Register AddClassPostConstruct widgets/itemtile]
    E --> F[Register AddGamePostInit BuildRecipeCache]
    F --> G[Frontend ready]
```

## 2. Hover-to-render flow

```mermaid
flowchart TD
    A[ItemTile OnGainFocus] --> B{self.item and prefab?}
    B -- No --> C[HideRecipeBoard]
    B -- Yes --> D[GetRecipesForIngredient]
    D --> E{recipes > 0?}
    E -- No --> C
    E -- Yes --> F[EnsureRecipeBoard]
    F --> G[board:SetRecipes]
    G --> H[board:Show + MoveToFront]
```

## 3. Update + grace timer flow

```mermaid
flowchart TD
    A[ItemTile OnUpdate dt] --> B{Hovering tile or board?}
    B -- No --> C[Decrease linger timer]
    C --> D{linger <= 0?}
    D -- Yes --> E[Hide + Clear + StopUpdating]
    D -- No --> F[Keep waiting]
    B -- Yes --> G[Reset linger]
    G --> H{valid item + recipes?}
    H -- No --> E
    H -- Yes --> I[Ensure board shown and refreshed]
```

## 4. Pagination input routing flow

```mermaid
flowchart TD
    A[Left click] --> B{Over nav button/hitbox?}
    B -- No --> C[Fallback old itemtile handler]
    B -- Yes --> D[TryHandleBoardPageAction]
    D --> E[board:HandlePageAction]
    E --> F{handled?}
    F -- Yes --> G[return true consume input]
    F -- No --> C
```

## 5. Startup + runtime sequence

```mermaid
sequenceDiagram
    participant Game
    participant ModMain as modmain.lua
    participant Tile as widgets/itemtile
    participant Board as RecipeBoard

    Game->>ModMain: Load modmain
    ModMain->>Board: require("widgets/recipeboard")
    ModMain->>Tile: AddClassPostConstruct hook
    Game->>ModMain: AddGamePostInit callback
    ModMain->>ModMain: BuildRecipeCache (guarded)

    Tile->>ModMain: OnGainFocus
    ModMain->>ModMain: GetRecipesForIngredient
    ModMain->>Board: EnsureRecipeBoard + SetRecipes
    Board-->>Tile: Show board

    Game->>Tile: Left click nav area
    Tile->>Board: GetHoveredPageAction
    Tile->>Board: HandlePageAction
    Board-->>Tile: handled=true
    Tile-->>Game: consume input
```

## 6. First-fault troubleshooting flow

```mermaid
flowchart TD
    A[Crash when Apply mod] --> B[Open client_log.txt]
    B --> C{First error points to mod file?}
    C -- No --> D[Check core/profile data issues]
    C -- Yes --> E[Locate top frame line + file]
    E --> F{Strict/global error?}
    F -- Yes --> G[Remove undeclared globals]
    F -- No --> H{Input leak/drop issue?}
    H -- Yes --> I[Enforce consume in itemtile + board]
    H -- No --> J[Follow stacktrace to nil/asset guard fix]
```
