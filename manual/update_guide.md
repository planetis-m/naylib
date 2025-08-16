# Updating raylib and Nim Wrappers

This guide describes the process of updating the bundled raylib version and regenerating the Nim wrappers.

## Step 1: Update raylib source

1. Edit `update_bindings.nims`:
   - Update the `RayLatestCommit` constant to the desired raylib commit hash
2. Run the update task:
   ```bash
   nim update update_bindings.nims
   ```
   This fetches the specified raylib version in `raylib/` (a git repository tracking raysan5/raylib) and copies the sources to `src/raylib/`
3. Build the parser, mangler and wrapper tools:
   ```bash
   nim buildTools update_bindings.nims
   ```

## Step 2: Resolve identifier conflicts

Some C symbols in raylib conflict with each other. To fix these clashes:

1. **Run the mangling script**

   ```bash
   nim mangle update_bindings.nims
   ```

   This modifies the raylib C source files in `src/raylib/` (the bundled sources), renaming symbols that would otherwise cause collisions.

2. **Manually adjust `rlgl` header**
   The API generator cannot correctly process `#if defined` conditional sections in `rlgl.h`. You must preprocess the file in `raylib/src/` manually:

   ```bash
   cd raylib && { unifdef -UGRAPHICS_API_OPENGL_ES2 -DGRAPHICS_API_OPENGL_33 src/rlgl.h > src/rlgl.h.tmp || [ $? -le 1 ]; } && mv -f src/rlgl.h.tmp src/rlgl.h
   ```

## Step 3: Update API JSON definitions

1. Generate new JSON definitions:
   ```bash
   nim genApi update_bindings.nims
   ```
   This creates updated JSON files in `tools/wrapper/api/` for raylib, rcamera, raymath, and rlgl.

## Step 4: Update Nim wrappers

1. **CRITICAL STEP**: Before generating wrappers, read `manual/review_guide.md` and follow its steps carefully!
2. Generate updated Nim wrappers:
   ```bash
   nim genWrappers update_bindings.nims
   ```
   This creates updated `.nim` files in `src/` based on the new JSON definitions and configuration files.

## Step 5: Update documentation

Generate updated HTML documentation:
```bash
nim docs update_bindings.nims
```

## Step 6: Verify changes

1. Run tests to ensure functionality isn't broken:
   ```bash
   nimble test
   ```
2. Check for any compiler warnings or errors
