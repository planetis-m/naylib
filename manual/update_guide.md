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
   nim update update_bindings.nims update
   ```
   This fetches the specified raylib version and copies the sources to `src/raylib/`

### 2. Update API JSON definitions

1. Build the parser tool:
   ```bash
   nim update update_bindings.nims buildTools
   ```
2. Generate new JSON definitions:
   ```bash
   nim update update_bindings.nims genApi
   ```
   This creates updated JSON files in `tools/wrapper/api/` for raylib, rcamera, raymath, and rlgl.

### 3. Update Nim wrappers

1. (Optional) Adjust configuration files in `tools/wrapper/config/` if the new raylib version has:
   - New functions/structs that need special type handling
   - Changed function signatures
   - New enum prefixes
2. Generate updated Nim wrappers:
   ```bash
   nim update update_bindings.nims genWrappers
   ```
   This creates updated `.nim` files in `src/` based on the new JSON definitions and configuration files.

### 4. Handle identifier mangling (if needed)

If there are C symbol clashes:
```bash
nim update update_bindings.nims mangle
```
This modifies the raylib C source files to rename conflicting symbols.

### 5. Update documentation

Generate updated HTML documentation:
```bash
nim update update_bindings.nims docs
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