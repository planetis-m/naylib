# Configuration Review Guide

After generating the new API definitions, follow these steps to update the configuration files:

## Step 1: Compare API Definitions

Use git to compare the API changes:

```bash
# Generate diffs for all API files
git diff -- tools/wrapper/api/raylib.json > raylib_api_changes.diff
git diff -- tools/wrapper/api/raymath.json > raymath_api_changes.diff
git diff -- tools/wrapper/api/rlgl.json > rlgl_api_changes.diff
git diff -- tools/wrapper/api/rcamera.json > rcamera_api_changes.diff
```

## Step 2: Analyze API Changes

Review the diff files, looking for:

1. **New Functions**: Look for new function entries
   ```diff
   +    {
   +      "name": "NewFunction",
   +      "description": "A new function added to the API",
   +      "returnType": "void",
   +      "params": [
   +        {
   +          "type": "int",
   +          "name": "param1"
   +        }
   +      ]
   +    },
   ```

2. **Changed Function Signatures**: Look for modifications to existing functions
   ```diff
         {
           "name": "ExistingFunction",
           "params": [
             {
   -          "type": "OldType",
   +          "type": "NewType",
               "name": "param"
             }
           ]
         },
   ```

3. **New Structures**: Look for new struct definitions
   ```diff
   +    {
   +      "name": "NewStruct",
   +      "description": "A new structure added to the API",
   +      "fields": [
   +        {
   +          "type": "float",
   +          "name": "field1",
   +          "description": "First field"
   +        }
   +      ]
   +    },
   ```

4. **Changed Structure Fields**: Look for modifications to existing struct fields
   ```diff
           "name": "ExistingStruct",
           "fields": [
   +        {
   +          "type": "int",
   +          "name": "newField",
   +          "description": "Newly added field"
   +        },
             {
   -          "type": "OldType",
   +          "type": "NewType",
               "name": "changedField",
               "description": "Field with changed type"
             }
           ]
         },
   ```

5. **New Enums or Enum Values**: Look for new enum types or values
   ```diff
           "name": "ConfigFlags",
           "values": [
   +        {
   +          "name": "FLAG_NEW_VALUE",
   +          "value": 128,
   +          "description": "New configuration flag"
   +        },
           ]
         },
   +    {
   +      "name": "NewEnumType",
   +      "description": "A completely new enum type",
   +      "values": [
   +        {
   +          "name": "NEW_ENUM_VALUE1",
   +          "value": 0
   +        }
   +      ]
   +    },
   ```

## Step 3: Identify Array Parameters and Other Special Types

### Array Parameters
Look for parameters with pointer types (`*`) often paired with a count parameter:

```json
{
  "type": "const Vector2 *",  // Pointer type indicates an array
  "name": "points"
},
{
  "type": "int",
  "name": "pointCount"        // Count parameter
}
```

These should be added to `[ArrayTypes]` and `[OpenArrayParameters]` sections.

### Output Parameters
Look for non-const pointer parameters that the function will modify:

```json
{
  "type": "Vector2 *",  // Non-const pointer to be modified
  "name": "collision"
}
```

These should be added to `[OutParameters]` section.

### Bool Return Functions
Look for functions returning `int` but semantically returning a boolean value:

```json
{
  "name": "IsWindowMinimized",
  "returnType": "int"  // Actually returns 0 or 1
}
```

These should be added to `[BoolReturn]` section.

### Struct Field Changes
When struct fields change:
- New array fields need to be added to `[ArrayTypes]`
- Fields with special types need entries in `[TypeReplacements]`
- Fields that should be read-only need to be added to `[ReadOnlyFields]`

## Step 4: Update Configuration Files as Needed

Based on your findings, modify files in `tools/wrapper/config/`:

### Common Configuration Updates

1. **New array parameters**: Add to `[ArrayTypes]` and `[OpenArrayParameters]` sections
   - Example: `DrawLineStrip/points`

2. **New out parameters**: Add to `[OutParameters]` section
   - Example: `NewFunction/outputParam`

3. **New enum prefixes**: Add to `[EnumValuePrefixes]` section
   - If you see new enums with consistent prefixes (e.g., `FLAG_`, `KEY_`)
   - Example: `NEW_PREFIX_`

4. **Special type handling**: Add to `[TypeReplacements]` section
   - For complex types that need special mapping in Nim
   - Example: `NewStruct/complexField: "CustomNimType"`

5. **Function return handling**: Update as needed
   - `[BoolReturn]` for functions returning int but logically represent boolean
   - `[DiscardReturn]` for functions whose return value can be ignored
   - `[NoSideEffectsFuncs]` for pure functions

6. **Struct field handling**: Update as needed
   - `[ReadOnlyFields]` for fields that should be read-only
   - `[PrivateSymbols]` for fields that should not be exposed publicly

For a complete reference of all available configuration options and their detailed usage, refer to the [Configuration Guide](config_guide.md).

