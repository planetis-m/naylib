# Updating raylib and Nim Wrappers

This guide describes the process of updating the bundled raylib version and regenerating the Nim wrappers.

## Update raylib source

1. Edit `update_bindings.nims`:
   - Update the `RayLatestCommit` constant to the desired raylib commit hash
2. Run the update task:
   ```bash
   nim update update_bindings.nims
   ```
   This fetches the specified raylib version in `raylib/` and copies the sources to `src/raylib/`
3. Build the parser, mangler and wrapper tools:
   ```bash
   nim buildTools update_bindings.nims
   ```

## Resolve identifier conflicts

Some C symbols in raylib conflict with each other. To fix these clashes:

1. **Run the mangling script**

   ```bash
   nim mangle update_bindings.nims
   ```

   This modifies the raylib C source files in `src/raylib`, renaming symbols that would otherwise cause collisions.

2. **Manually adjust `rlgl` header**
   The API generator cannot correctly process `#if defined` conditional sections in `rlgl.h`. You must preprocess the file in `raylib/src/` manually:

   ```bash
   cd raylib && { unifdef -UGRAPHICS_API_OPENGL_ES2 -DGRAPHICS_API_OPENGL_33 src/rlgl.h > src/rlgl.h.tmp || [ $? -le 1 ]; } && mv -f src/rlgl.h.tmp src/rlgl.h
   ```

   If something goes wrong, you can restore the original file:

   ```bash
   cd raylib && git checkout src/rlgl.h # This is a git directory tracking raysan5/raylib
   ```

**Important:** Perform this step **before** updating the API definitions.

## Update API JSON definitions

1. Generate new JSON definitions:
   ```bash
   nim genApi update_bindings.nims
   ```
   This creates updated JSON files in `tools/wrapper/api/` for raylib, rcamera, raymath, and rlgl.

## Update Nim wrappers

1. (Optional) Adjust configuration files in `tools/wrapper/config/` if the new raylib version has:
   - New functions/structs that need special type handling
   - Changed function signatures
   - New enum prefixes
2. Generate updated Nim wrappers:
   ```bash
   nim genWrappers update_bindings.nims
   ```
   This creates updated `.nim` files in `src/` based on the new JSON definitions and configuration files.

## Update documentation

Generate updated HTML documentation:
```bash
nim docs update_bindings.nims
```

## Verify changes

1. Review the generated wrappers in `src/`
2. Check for any new compiler warnings or errors
3. Run tests to ensure functionality wasn't broken:
   ```bash
   nimble test
   ```

