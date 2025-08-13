# Updating raylib and Nim Wrappers

This guide describes the process of updating the bundled raylib version and regenerating the Nim wrappers.

## Prerequisites

Ensure you have the necessary tools installed:
- Git
- A C compiler (for building raylib_parser)
- Nim (for building tools and generating wrappers)

## Update Process

### 1. Update raylib source

1. Edit `update_bindings.nims`:
   - Update the `RayLatestCommit` constant to the desired raylib commit hash
2. Run the update task:
   ```bash
   nim update update_bindings.nims
   ```
   This fetches the specified raylib version in `raylib/` and copies the sources to `src/raylib/`

### 2. Resolve identifier conflicts

Some C symbols in raylib conflict with each other. To fix these clashes:

1. **Run the mangling script**

   ```bash
   nim mangle update_bindings.nims
   ```

   This modifies the raylib C source files, renaming symbols that would otherwise cause collisions.

2. **Manually adjust `rlgl` header**
   The API generator cannot correctly process `#if defined` conditional sections in `rlgl.h`. You must preprocess the file manually:

   ```bash
   cd raylib # Do not confuse the top-level raylib directory with src/raylib
   # unifdef returns non-zero when it processes a file, even if the processing is successful
   unifdef -UGRAPHICS_API_OPENGL_ES2 -DGRAPHICS_API_OPENGL_33 src/rlgl.h > src/rlgl.h.tmp
   # Move the temporary file in a separate step
   mv src/rlgl.h.tmp src/rlgl.h
   ```

   If something goes wrong, you can restore the original file:

   ```bash
   cd raylib # This is a git directory tracking raysan5/raylib
   git checkout src/rlgl.h
   ```

**Important:** Perform this step **before** updating the API definitions.

### 3. Update API JSON definitions

1. Build the parser tool:
   ```bash
   nim buildTools update_bindings.nims
   ```
2. Generate new JSON definitions:
   ```bash
   nim genApi update_bindings.nims
   ```
   This creates updated JSON files in `tools/wrapper/api/` for raylib, rcamera, raymath, and rlgl.

### 4. Update Nim wrappers

1. (Optional) Adjust configuration files in `tools/wrapper/config/` if the new raylib version has:
   - New functions/structs that need special type handling
   - Changed function signatures
   - New enum prefixes
2. Generate updated Nim wrappers:
   ```bash
   nim genWrappers update_bindings.nims
   ```
   This creates updated `.nim` files in `src/` based on the new JSON definitions and configuration files.

### 5. Update documentation

Generate updated HTML documentation:
```bash
nim docs update_bindings.nims
```

### 6. Verify changes

1. Review the generated wrappers in `src/`
2. Check for any new compiler warnings or errors
3. Run tests to ensure functionality wasn't broken:
   ```bash
   nimble test
   ```

## Key Files

The key files involved in this process are:
- `update_bindings.nims`: Controls the update process
- `tools/wrapper/config/*.cfg`: Configuration files for each module's wrapper generation
- `tools/wrapper/api/*.json`: Generated API definitions (intermediate files)
- `src/*.nim`: Generated Nim wrappers
- `src/raylib/*`: Bundled raylib C source files
