# Comprehensive Netrunner Ability Language

This directory contains a complete JSON-based language specification for describing all Android: Netrunner card abilities. The language is designed to be comprehensive, precise, and extensible while remaining human-readable.

## Overview

The ability language consists of several key components:

### 1. Core Schema (`comprehensive_ability.schema.json`)
The main schema that defines the structure of abilities, including:
- **Ability Types**: static, triggered, paid, subroutine, restrictions, replacement effects
- **Timing System**: When abilities trigger or can be activated
- **Condition System**: Complex logical conditions using game state queries
- **Target System**: Sophisticated targeting with filters and player choice
- **Cost System**: All types of costs abilities can require
- **Dynamic Values**: Values calculated from game state

### 2. Effect Schema (`comprehensive_effect.schema.json`)
Detailed definitions for all possible effects, including:
- Resource modifications (credits, clicks, tags, etc.)
- Card manipulation (draw, discard, move, install, trash)
- Run mechanics (initiate, end, break subroutines, traces)
- Complex effects (choices, conditionals, delayed effects)

### 3. Documentation (`ability_language.md`)
Complete documentation with examples showing how to use the language to describe complex card interactions.

### 4. Examples (`examples/`)
Real card examples demonstrating the language features:
- `advanced_snare.json` - Access restrictions and conditional effects
- `data_sucker.json` - Virus counters and strength modification
- `brain_taping_warehouse.json` - Complex player choices with mathematical calculations
- `account_siphon.json` - Run replacement effects and credit manipulation
- `data_raven.json` - ICE encounter triggers and traces
- `gordian_blade.json` - Icebreaker mechanics with costs and conditions

## Key Features

### Comprehensive Coverage
The language covers all game mechanics including:
- Turn structure and timing windows
- Run mechanics and server interactions
- Ice encounters and subroutines
- Damage, tags, and traces
- Counters and advancement
- Card zones and movement
- Player resources and restrictions

### Precise Timing
Abilities can specify exactly when they trigger or can be used:
```json
{
  "timing": {
    "when": "successful_run",
    "filter": {
      "query": "run_server",
      "operator": "in", 
      "value": ["hq", "rd", "archives"]
    }
  }
}
```

### Complex Conditions
Rich condition system supports game state queries with logical operators:
```json
{
  "condition": {
    "and": [
      {
        "query": "player_credits",
        "target": "runner",
        "operator": ">=",
        "value": 5
      },
      {
        "not": {
          "query": "player_tags",
          "target": "runner", 
          "operator": ">",
          "value": 0
        }
      }
    ]
  }
}
```

### Dynamic Values
Values can be calculated from game state:
```json
{
  "amount": {
    "base": 1,
    "multiply_by": {
      "type": "cards_with_subtype",
      "target": "runner",
      "zone": "installed",
      "subtype": "Virus"
    },
    "minimum": 1,
    "maximum": 5
  }
}
```

### Player Choices
Support for complex player decisions:
```json
{
  "type": "choose_and_execute",
  "prompt": "Choose one:",
  "choices": [
    {
      "type": "modify_credits",
      "target": "runner",
      "amount": 2
    },
    {
      "type": "draw_cards",
      "target": "runner", 
      "amount": 1
    }
  ]
}
```

## Usage

### Validating Card Abilities
Use the JSON schemas to validate card ability definitions:

```bash
# Validate using a JSON schema validator
ajv validate -s schemas/comprehensive_ability.schema.json -d cards/data/example_card.json
```

### Integration with Game Engine
The `ability_engine.gd` file in the main project can be extended to support all language features:

1. Parse JSON ability definitions
2. Execute abilities based on timing triggers
3. Resolve targets using the targeting system
4. Calculate dynamic values from game state
5. Handle complex effects like choices and conditionals

### Creating New Cards
When creating new cards:

1. Define the card's basic properties (cost, type, etc.)
2. Add abilities using the comprehensive language
3. Validate against the schemas
4. Test with the game engine

## Language Design Principles

### Completeness
Every possible game mechanic should be expressible in the language, from simple resource modifications to complex replacement effects.

### Precision 
The language should unambiguously specify exactly what happens and when, with no room for interpretation.

### Extensibility
New mechanics can be added by extending the schemas without breaking existing card definitions.

### Readability
JSON structure should be clear and match how players think about the game rules.

### Performance
The language should enable efficient processing by the game engine while remaining expressive.

## Future Extensions

The language is designed to be easily extended as new mechanics are added to the game:

- New ability types can be added to the `type` enum
- New effect types can be added to the effect schema
- New query types can be added for game state access
- New timing windows can be added as the game evolves

## Contributing

When extending the language:

1. Update the relevant schema files
2. Add documentation with examples
3. Create test card examples
4. Ensure backward compatibility
5. Update the game engine if needed

This comprehensive language enables precise specification of all Netrunner card mechanics while remaining maintainable and extensible.