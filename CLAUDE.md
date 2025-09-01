# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Godot 4 implementation of Android: Netrunner, a two-player asymmetric card game. The project uses GDScript for all game logic and implements a data-driven ability system for card effects.

## Development Commands

### Running the Game
```bash
# Run the game
godot

# Run specific scene
godot --scene scenes/main.tscn

# Run in editor mode
godot -e
```

### Project Management
```bash
# Convert project files if needed
godot --convert-3to4

# Export project (requires export templates)
godot --export-release "Linux" netrunner.x86_64
```

## Architecture

### Core Systems

The game uses an event-driven architecture with several key systems:

1. **Event Bus** (src/autoload/game_events.gd): Central event system for game state changes. All major game actions emit signals through GameEvents autoload.

2. **Card Database** (src/autoload/card_database.gd): Manages card data loading from JSON files in cards/data/. Cards are referenced by set and ID.

3. **Game Manager** (src/core/game_manager.gd): Orchestrates game flow, manages players, handles turn structure. Creates LocalPlayer and RemotePlayer nodes.

4. **Player System** (src/player/player.gd): Base player class handling clicks, credits, deck operations. Specialized into PlayerCorp and PlayerRunner for side-specific logic.

5. **Ability Engine** (src/rules/ability_engine.gd): JSON-driven ability execution system. Interprets card ability definitions to execute game effects, handle conditions, and manage costs.

### Game State Flow

1. Main scene loads → GameManager initializes players
2. Players load decks from JSON files (user://decks/)
3. Game setup: shuffle decks, draw cards, set initial resources
4. Turn loop managed through GameEvents signals
5. Card plays validated through Player.valid_to_play()
6. Abilities executed through AbilityEngine with JSON definitions

### Card Data Structure

Cards stored in cards/data/{SetName}/{id}.json with:
- Basic properties (title, type, cost, strength)
- Abilities array with timing, conditions, effects
- Deck building info (faction, influence)

Card art in cards/art/{SetName}/{id}.jpg

### UI Architecture

- **2D Hand**: src/ui/hand2d.gd manages card display in hand
- **3D Playfield**: Cards on table rendered as 3D objects
- **Deck Builder**: src/ui/deck/deck_builder.gd for deck construction
- **Identity Panels**: Display player state (credits, clicks, faction)

### Key Autoloads

- **SceneStack**: Scene management and navigation
- **CardDatabase**: Card data loading and caching  
- **GameEvents**: Global event bus for game state changes

### Testing Approach

Currently no automated tests. Manual testing through:
1. Running main scene
2. Loading test decks from user://decks/
3. Verifying card interactions in-game

## Important Files

- project.godot: Godot project configuration
- src/core/game_manager.gd: Main game logic controller
- src/rules/ability_engine.gd: Card ability execution
- src/player/player.gd: Core player mechanics
- cards/data/: JSON card definitions
- schemas/: JSON schemas for card validation

## Development Notes

- Game uses Godot 4.4 with mobile renderer
- All scripts in GDScript
- Card abilities defined in JSON, not code
- Event-driven architecture via signals
- No external dependencies beyond Godot

## Project Structure

```
netrunner/
├── cards/                    # Card data and artwork
│   ├── art/                  # Card images organized by set
│   │   └── System Gateway/   # JPG files for each card (1.jpg, 2.jpg, etc.)
│   └── data/                 # Card JSON definitions
│       └── System Gateway/   # JSON files for each card (1.json, 2.json, etc.)
├── scenes/                   # Godot scene files (.tscn)
│   ├── main.tscn            # Main game scene
│   ├── mainmenu.tscn        # Main menu
│   ├── deck_builder.tscn    # Deck building interface
│   ├── playfield.tscn       # Game board/playfield
│   └── ...                  # Other UI scenes
├── src/                      # GDScript source code
│   ├── autoload/            # Global singleton scripts
│   │   ├── card_database.gd # Card data management
│   │   ├── game_events.gd   # Event bus system
│   │   └── scene_manager.gd # Scene navigation
│   ├── core/                # Core game systems
│   │   ├── card.gd          # Base card class
│   │   ├── game_manager.gd  # Main game controller
│   │   └── server3d.gd      # 3D server representation
│   ├── game/                # Game flow logic
│   │   └── turn_manager.gd  # Turn structure management
│   ├── player/              # Player-specific logic
│   │   ├── player.gd        # Base player class
│   │   ├── player_corp.gd   # Corporation player
│   │   └── player_runner.gd # Runner player
│   ├── rules/               # Game rules and abilities
│   │   ├── ability.gd       # Ability data structures
│   │   ├── ability_engine.gd # Ability execution engine
│   │   └── run.gd           # Run mechanics
│   ├── state/               # Game state management
│   │   ├── game_state.gd    # Global game state
│   │   └── zones.gd         # Card zone definitions
│   └── ui/                  # UI components
│       ├── deck/            # Deck-related UI
│       ├── menus/           # Menu screens
│       ├── hand2d.gd        # Hand display
│       └── playfield.gd     # Playfield UI controller
├── schemas/                  # JSON validation schemas
│   ├── ability.schema.json  # Ability definitions
│   ├── deck.schema.json     # Deck format
│   └── ...                  # Card type schemas
├── materials/               # Godot material resources
├── shaders/                 # Custom shader files
├── Faction Glyphs/          # SVG faction icons
├── Game Symbols/            # SVG game symbols (credits, clicks, etc.)
├── Set Symbols/             # SVG set symbols
└── project.godot            # Godot project configuration