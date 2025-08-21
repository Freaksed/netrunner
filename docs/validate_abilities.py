#!/usr/bin/env python3
"""
Validation script for the comprehensive Netrunner ability language.
This script validates example cards against the new schemas.
"""

import json
import os
from pathlib import Path

try:
    import jsonschema
    from jsonschema import validate, Draft7Validator
    JSONSCHEMA_AVAILABLE = True
except ImportError:
    JSONSCHEMA_AVAILABLE = False
    print("Warning: jsonschema not available. Install with: pip install jsonschema")

def load_schema(schema_path):
    """Load a JSON schema from file."""
    with open(schema_path, 'r') as f:
        return json.load(f)

def load_card(card_path):
    """Load a card definition from file."""
    with open(card_path, 'r') as f:
        return json.load(f)

def validate_card_abilities(card_data, ability_schema):
    """Validate all abilities in a card against the schema."""
    errors = []
    
    abilities = card_data.get('abilities', [])
    for i, ability in enumerate(abilities):
        try:
            validate(instance=ability, schema=ability_schema)
        except jsonschema.ValidationError as e:
            errors.append(f"Ability {i}: {e.message}")
        except Exception as e:
            errors.append(f"Ability {i}: Unexpected error - {str(e)}")
    
    return errors

def main():
    """Main validation function."""
    if not JSONSCHEMA_AVAILABLE:
        print("Cannot validate without jsonschema library.")
        return
    
    # Get paths
    base_dir = Path(__file__).parent
    schema_dir = base_dir / "schemas"
    examples_dir = base_dir / "examples"
    
    # Load schemas
    try:
        ability_schema = load_schema(schema_dir / "comprehensive_ability.schema.json")
        effect_schema = load_schema(schema_dir / "comprehensive_effect.schema.json")
        print("✓ Schemas loaded successfully")
    except Exception as e:
        print(f"✗ Failed to load schemas: {e}")
        return
    
    # Validate schemas themselves
    try:
        Draft7Validator.check_schema(ability_schema)
        Draft7Validator.check_schema(effect_schema)
        print("✓ Schemas are valid JSON Schema Draft 7")
    except Exception as e:
        print(f"✗ Schema validation failed: {e}")
        return
    
    # Find and validate example cards
    example_files = list(examples_dir.glob("*.json"))
    if not example_files:
        print("No example cards found")
        return
    
    print(f"\nValidating {len(example_files)} example cards...")
    
    all_valid = True
    for card_file in example_files:
        try:
            card_data = load_card(card_file)
            errors = validate_card_abilities(card_data, ability_schema)
            
            if errors:
                print(f"✗ {card_file.name}:")
                for error in errors:
                    print(f"  - {error}")
                all_valid = False
            else:
                print(f"✓ {card_file.name}")
        
        except Exception as e:
            print(f"✗ {card_file.name}: Failed to validate - {e}")
            all_valid = False
    
    if all_valid:
        print("\n✓ All example cards are valid!")
    else:
        print("\n✗ Some cards have validation errors.")

def test_specific_features():
    """Test specific language features with minimal examples."""
    if not JSONSCHEMA_AVAILABLE:
        return
    
    base_dir = Path(__file__).parent
    schema_path = base_dir / "schemas" / "comprehensive_ability.schema.json"
    ability_schema = load_schema(schema_path)
    
    print("\nTesting specific language features...")
    
    # Test cases for different ability types
    test_cases = [
        {
            "name": "Static ability",
            "ability": {
                "type": "static",
                "effects": [
                    {
                        "type": "modify_memory",
                        "target": "runner",
                        "amount": 1
                    }
                ]
            }
        },
        {
            "name": "Triggered ability with complex timing",
            "ability": {
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
                        "type": "modify_credits",
                        "target": "runner",
                        "amount": 1
                    }
                ]
            }
        },
        {
            "name": "Paid ability with counter cost",
            "ability": {
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
                "effects": [
                    {
                        "type": "modify_strength",
                        "target": "current_ice",
                        "amount": -1,
                        "duration": "end_of_encounter"
                    }
                ]
            }
        },
        {
            "name": "Choice effect",
            "ability": {
                "type": "triggered",
                "timing": "when_played",
                "effects": [
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
                ]
            }
        },
        {
            "name": "Dynamic value calculation",
            "ability": {
                "type": "triggered",
                "timing": "when_played",
                "effects": [
                    {
                        "type": "modify_credits",
                        "target": "runner",
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
                ]
            }
        }
    ]
    
    for test in test_cases:
        try:
            validate(instance=test["ability"], schema=ability_schema)
            print(f"✓ {test['name']}")
        except jsonschema.ValidationError as e:
            print(f"✗ {test['name']}: {e.message}")

if __name__ == "__main__":
    main()
    test_specific_features()