# Netrunner - Godot Implementation

A digital implementation of Android: Netrunner, the asymmetric cyberpunk card game, built with Godot 4.

## Overview

This project recreates the Android: Netrunner card game experience in Godot 4, featuring:
- Full implementation of core game mechanics
- JSON-driven card ability system
- Event-driven architecture for game state management
- 3D playfield with 2D card UI elements
- Support for both Runner and Corp sides

## Features

- **Card Database**: Complete card implementation from System Gateway set
- **Ability Engine**: Data-driven ability execution from JSON definitions
- **Deck Building**: Create and save custom decks
- **Game Modes**: Local play with both sides implemented
- **Visual Effects**: 3D table view with card animations
- **Turn Management**: Full turn structure with clicks, credits, and actions

## Requirements

- Godot 4.4 or higher
- No additional dependencies required

## Installation

1. Clone the repository:
```bash
git clone https://github.com/Freaksed/netrunner.git
cd netrunner
```

2. Open the project in Godot:
```bash
godot -e
```

3. Run the game:
```bash
godot
```

## Project Structure

```
netrunner/
├── cards/               # Card data and artwork
│   ├── data/           # JSON card definitions
│   └── art/            # Card images
├── scenes/             # Godot scene files
├── src/                # GDScript source code
│   ├── autoload/       # Global singletons
│   ├── core/           # Core game logic
│   ├── player/         # Player mechanics
│   ├── rules/          # Ability engine
│   └── ui/             # User interface
├── schemas/            # JSON validation schemas
└── materials/          # Visual materials and shaders
```

## Architecture

The game uses an event-driven architecture with three main autoload singletons:

- **GameEvents**: Central event bus for all game state changes
- **CardDatabase**: Manages card data loading and caching
- **SceneStack**: Handles scene transitions and navigation

See [CLAUDE.md](CLAUDE.md) for detailed architecture documentation.

## Playing the Game

1. Launch the game from Godot
2. Load or create decks in the deck builder
3. Start a new game from the main menu
4. Play cards by dragging from hand to playfield
5. Click the credit icon to gain credits (costs 1 click)
6. Click the deck to draw cards (costs 1 click)

## Development

### Adding New Cards

1. Create a JSON file in `cards/data/{SetName}/{id}.json`
2. Add card artwork to `cards/art/{SetName}/{id}.jpg`
3. Define abilities using the JSON schema format
4. Cards are automatically loaded on game start

### Extending the Ability System

The ability engine (`src/rules/ability_engine.gd`) interprets JSON ability definitions. To add new effect types:

1. Add the effect type to the appropriate schema
2. Implement the effect handler in `ability_engine.gd`
3. Test with sample cards

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This is a fan implementation for educational purposes. Android: Netrunner is a trademark of Fantasy Flight Games and Null Signal Games.

## Acknowledgments

- Card data and rules from Null Signal Games
- Built with Godot Engine
- Community resources and comprehensive rules documentation