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

## Step 3: Filter Out Ignored Symbols

When reviewing API changes, filter out symbols that are explicitly ignored in the configuration:

```bash
# View the ignored symbols in the configuration files
grep -A 85 "\[ IgnoredSymbols \]" tools/wrapper/config/raylib.cfg
grep -A 20 "\[ IgnoredSymbols \]" tools/wrapper/config/raymath.cfg
```

Functions related to text management, file operations, compression, and encoding are excluded from the wrapper.

## Step 4: Identify Array Parameters and Other Special Types

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
  "name": "collisionPoint"
}
```

These should be added to `[OutParameters]` section.

### Bool Return Functions
Look for functions returning `int` but semantically returning a boolean value:

```json
{
  "name": "GuiWindowBox",
  "returnType": "int"  // Actually returns 0 or 1
}
```

These should be added to `[BoolReturn]` section.

### Struct Field Changes
When struct fields change:
- New array fields need to be added to `[ArrayTypes]`
- Fields with enum types that appear as `int` in C API need entries in `[TypeReplacements]`
- Fields that track counts or sizes should be added to `[ReadOnlyFields]` (e.g., `Mesh/boneCount`) to prevent memory access violations if modified directly

## Step 5: Update Configuration Files as Needed

Based on your findings, modify files in `tools/wrapper/config/`:

### Common Configuration Updates

1. **Enum Type Parameters**: Add to `[TypeReplacements]`
   - Convert `int` parameters to proper enum types
   - Example: `IsKeyPressed/key: "KeyboardKey"`

2. **Boolean Returns**: Add to `[BoolReturn]`
   - For functions returning `int` (0/1) but logically representing booleans
   - Example: `IsKeyPressed`, `CheckCollision` functions

3. **Arrays**: Update `[ArrayTypes]` and `[OpenArrayParameters]`
   - Example: `DrawLineStrip/points`, `UpdateMeshBuffer/data`

4. **Output Parameters**: Add to `[OutParameters]`
   - Example: `CheckCollisionLines/collisionPoint`

5. **Discardable Returns**: Add to `[DiscardReturn]`
   - For functions whose return values are optional
   - Example: UI functions like `GuiButton`

6. **Pure Functions**: Add to `[NoSideEffectsFuncs]`
   - For functions without side effects
   - Example: Math functions like `Vector2Add`

7. **Function Overloads**: Update `[FunctionOverloads]` section
   - Simplifies APIs with multiple versions (suffixed with V, Rec, Ex)
   - Example: `DrawPixelV` becomes an overload of `DrawPixel`

8. **Field Access Control**: 
   - `[ReadOnlyFields]`: For count/size fields (e.g., `Font/glyphCount`)
   - `[PrivateSymbols]`: For internal functions/fields (e.g., `UnloadFont`)

For a complete reference of all available configuration options and their detailed usage, refer to the [Configuration Guide](config_guide.md).

