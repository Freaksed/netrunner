# Comprehensive Netrunner Ability Language Specification

## Overview

This document defines a comprehensive JSON-based language for describing all Android: Netrunner card abilities. The language is designed to be:

- **Complete**: Cover all possible game mechanics and interactions
- **Precise**: Unambiguous specification of complex timing and effects  
- **Extensible**: Easy to add new mechanics as the game evolves
- **Human-readable**: Clear structure that matches the game rules
- **Machine-parseable**: Efficient processing by the ability engine

## Core Concepts

### Ability Types

Every ability has a `type` that determines when and how it can be activated:

#### `static`
Abilities that provide constant effects while the card is active.
```json
{
  "type": "static",
  "effects": [
    {
      "type": "modify_memory",
      "target": "runner", 
      "amount": 2
    }
  ]
}
```

#### `triggered`
Abilities that activate automatically when specific game events occur.
```json
{
  "type": "triggered",
  "timing": "successful_run",
  "effects": [
    {
      "type": "modify_credits",
      "target": "runner",
      "amount": 1
    }
  ]
}
```

#### `paid`
Abilities that can be activated by paying costs during appropriate timing windows.
```json
{
  "type": "paid", 
  "cost": {
    "clicks": 1,
    "credits": 2
  },
  "effects": [
    {
      "type": "draw_cards",
      "target": "runner",
      "amount": 1
    }
  ]
}
```

#### `subroutine`
ICE subroutines that fire when encountered unless broken.
```json
{
  "type": "subroutine",
  "effects": [
    {
      "type": "end_run"
    }
  ]
}
```

#### `install_restriction`, `play_restriction`, `access_restriction`
Special abilities that modify when/how cards can be used.
```json
{
  "type": "install_restriction", 
  "condition": {
    "query": "player_tags",
    "target": "runner",
    "operator": ">=",
    "value": 1
  }
}
```

#### `replacement_effect`
Abilities that replace normal game rules under specific conditions.
```json
{
  "type": "replacement_effect",
  "condition": {
    "query": "damage_amount",
    "operator": ">",
    "value": 0
  },
  "effects": [
    {
      "type": "prevent_damage",
      "amount": 1
    }
  ]
}
```

### Timing System

The timing system specifies when abilities can be used or when they trigger:

#### Simple Timing
```json
{
  "timing": "start_of_turn"
}
```

#### Complex Timing with Filters
```json
{
  "timing": {
    "when": "card_installed",
    "filter": {
      "query": "cards_with_subtype", 
      "target": "installed_card",
      "subtype": "Virus",
      "operator": "exists",
      "value": true
    }
  }
}
```

#### Available Timing Windows
- **Turn Structure**: `start_of_turn`, `end_of_turn`, `action_phase`, `mandatory_draw_phase`, `discard_phase`
- **Run Structure**: `start_of_run`, `approach_ice`, `encounter_ice`, `pass_ice`, `breach_server`, `access_card`, `end_of_run`, `successful_run`, `unsuccessful_run`
- **Card Events**: `when_installed`, `when_played`, `when_rezzed`, `when_trashed`, `when_accessed`, `when_scored`, `when_stolen`, `when_advanced`
- **Player Events**: `when_damaged`, `when_tagged`, `when_purged`

### Condition System

Conditions determine when abilities can be used and when effects apply:

#### Logical Operators
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
        "query": "successful_runs_this_turn",
        "operator": ">=", 
        "value": 1
      }
    ]
  }
}
```

#### Game State Queries
```json
{
  "condition": {
    "query": "cards_in_zone",
    "target": "runner",
    "zone": "grip",
    "operator": "<=",
    "value": 2
  }
}
```

### Targeting System

The targeting system specifies what game objects abilities affect:

#### Simple Targets
```json
{
  "target": "runner"
}
```

#### Complex Targeting with Player Choice
```json
{
  "target": {
    "type": "player_choice",
    "zone": "grip",
    "count": 2,
    "prompt": "Choose 2 cards to discard"
  }
}
```

#### Filtered Targeting
```json
{
  "target": {
    "type": "cards_with_subtype",
    "zone": "installed",
    "subtype": "Program",
    "condition": {
      "query": "install_cost",
      "operator": "<=", 
      "value": 3
    }
  }
}
```

### Cost System

Costs specify what must be paid to activate paid abilities:

#### Basic Costs
```json
{
  "cost": {
    "clicks": 1,
    "credits": 3
  }
}
```

#### Counter Costs
```json
{
  "cost": {
    "counters": [
      {
        "type": "virus",
        "amount": 2,
        "from": "self"
      }
    ]
  }
}
```

#### Complex Costs
```json
{
  "cost": {
    "trash": {
      "type": "player_choice",
      "zone": "installed", 
      "subtype": "Program",
      "count": 1
    }
  }
}
```

### Effect System

Effects specify what happens when abilities resolve:

#### Resource Effects
```json
{
  "type": "modify_credits",
  "target": "runner",
  "amount": 3
}
```

#### Card Manipulation
```json
{
  "type": "move_card", 
  "target": {
    "type": "player_choice",
    "zone": "heap",
    "count": 1
  },
  "zone_to": "grip"
}
```

#### Run Effects
```json
{
  "type": "initiate_run",
  "server": "hq",
  "effects_during_run": [
    {
      "type": "modify_strength",
      "target": "self",
      "amount": 2,
      "duration": "end_of_run"
    }
  ]
}
```

### Dynamic Values

Values can be calculated dynamically based on game state:

#### Simple Dynamic Value
```json
{
  "amount": {
    "base": 1,
    "multiply_by": {
      "type": "cards_with_subtype",
      "target": "runner",
      "zone": "installed",
      "subtype": "Virus"
    }
  }
}
```

#### Complex Calculation
```json
{
  "amount": {
    "base": 0,
    "add": {
      "type": "player_credits", 
      "target": "corp"
    },
    "divide_by": {
      "type": "constant",
      "value": 2
    },
    "round": "down",
    "minimum": 1,
    "maximum": 5
  }
}
```

## Advanced Features

### Choice Effects

Allow players to choose between multiple effects:

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

### Conditional Effects

Effects that only apply under certain conditions:

```json
{
  "type": "conditional_effect",
  "condition": {
    "query": "successful_runs_this_turn",
    "operator": ">=",
    "value": 1
  },
  "then": {
    "type": "modify_credits",
    "target": "runner", 
    "amount": 3
  },
  "else": {
    "type": "modify_credits",
    "target": "runner",
    "amount": 1
  }
}
```

### Delayed Effects

Effects that happen at a future time:

```json
{
  "type": "delayed_effect",
  "delay_until": "start_of_next_turn",
  "effects": [
    {
      "type": "deal_damage",
      "target": "runner",
      "damage_type": "net",
      "amount": 2
    }
  ]
}
```

### Replacement Effects

Effects that replace normal game rules:

```json
{
  "type": "replacement_effect",
  "replacement_condition": {
    "query": "damage_amount",
    "operator": ">",
    "value": 0  
  },
  "replacement": {
    "type": "prevent_damage",
    "amount": 1
  }
}
```

## Usage Limitations

### Once Per Turn
```json
{
  "once_per_turn": true
}
```

### Custom Limits
```json
{
  "limit": {
    "uses_per_turn": 2,
    "reset_condition": {
      "query": "successful_runs_this_turn",
      "operator": ">=", 
      "value": 1
    }
  }
}
```

## Examples

### Simple ICE Subroutine
```json
{
  "type": "subroutine",
  "effects": [
    {
      "type": "give_tag",
      "target": "runner",
      "amount": 1
    }
  ]
}
```

### Complex Virus Program
```json
{
  "type": "triggered",
  "timing": {
    "when": "successful_run",
    "filter": {
      "query": "run_server",
      "operator": "in",
      "value": ["hq", "rd", "archives"]
    }
  },
  "effects": [
    {
      "type": "modify_counters",
      "target": "self",
      "counter_type": "virus",
      "amount": 1
    }
  ]
},
{
  "type": "paid",
  "cost": {
    "counters": [
      {
        "type": "virus",
        "amount": 1,
        "from": "self"
      }
    ]
  },
  "timing": "encounter_ice",
  "effects": [
    {
      "type": "modify_strength",
      "target": "current_ice",
      "amount": -1,
      "duration": "end_of_encounter"
    }
  ]
}
```

### Card with X Cost
```json
{
  "type": "triggered",
  "timing": "when_played",
  "effects": [
    {
      "type": "deal_damage",
      "target": "runner",
      "damage_type": "net",
      "amount": {
        "base": 0,
        "add": {
          "type": "x_value"
        }
      }
    }
  ]
}
```

This language provides complete coverage of Android: Netrunner's complex card interactions while remaining readable and maintainable.