# Naylib Advanced Usage Guide

## Destructor-Based Management

Naylib manages Raylib resources—such as `Image`, `Wave`, `Texture`, `Shader`, and `Mesh`—using Nim’s **destructors** (RAII) rather than manual `Unload*` functions.

* **No Manual Unloading:** `Unload*` APIs are intentionally not exported to the user.
* **Automatic Release:** Resources are released automatically when they go out of scope.
* **Safety:** This approach follows Nim’s memory model to prevent double-free errors and lifetime issues.

---

## Early Resource Release

If a resource must be released before it goes out of scope—for example, to free up RAM after uploading data to the GPU—use the `reset` procedure:

```nim
var image = loadImage("resources/heightmap.png") # Load heightmap image (RAM)
let texture = loadTextureFromImage(image)        # Convert image to texture (VRAM)
reset(image)                                     # Explicitly destroy the RAM resource
```

This immediately invokes the destructor. Use this pattern when working with large assets that don't need to persist in system memory.

---

## Copying and References

To maintain strict control over GPU resources, certain types—including `Texture`, `Shader`, `Mesh`, and `Font`—intentionally do **not** define `=copy` hooks. This prevents accidental duplication of handles.

If shared access to a resource is required across different parts of your code, use references:

```nim
var texture: ref Texture
new(texture)
texture[] = loadTexture("resources/example.png")

let copy = texture # Copies the reference, not the resource handle itself
```

---

## Model and Mesh Ownership

Naylib distinguishes between "viewing" a resource and "owning" it, particularly when dealing with 3D models.

### Texture Ownership in Models

Assigning a texture to a model performs only a **shallow copy**. The model stores the handle but does not take ownership.

> **Note:** The texture must remain valid and in scope for the entire duration of the model’s use.

```nim
var model = loadModel("resources/models/plane.obj")
let texture = loadTexture("resources/models/plane_diffuse.png")

model.materials[0].maps[MaterialMapIndex.Diffuse].texture = texture
```

### Mesh Ownership Transfer

When creating a model from a mesh via `loadModelFromMesh`, ownership **is** transferred. The `sink Mesh` parameter consumes the mesh. Because meshes cannot be copied, the compiler enforces that the mesh is moved into the model.

```nim
let mesh = genMeshHeightmap(image, Vector3(x: 16, y: 8, z: 16))
var model = loadModelFromMesh(mesh) # Mesh is now owned by the model
```

At this point, the original `mesh` variable should not be used. The model's destructor will eventually unload the mesh.

---

## Window Lifecycle Management

While most resources are managed automatically, `closeWindow` requires special care. It **must** be called at the very end of the program, after all dependent variables have been destroyed.

### Recommended Pattern: `defer`

```nim
initWindow(800, 450, "example")
defer: closeWindow()

let texture = loadTexture("resources/example.png")
# Game logic...
```

### Advanced Pattern: The Owning Object

For larger applications, you can wrap the window lifetime in an object. This ensures the window is the last resource cleaned up by the program.

```nim
type Game = object

proc `=destroy`(x: Game) =
  assert isWindowReady(), "Window is already closed"
  closeWindow()

# Explicitly disable copying and moving for the Game object
proc `=sink`(x: var Game; y: Game) {.error.}
proc `=dup`(y: Game): Game {.error.}
proc `=copy`(x: var Game; y: Game) {.error.}
proc `=wasMoved`(x: var Game) {.error.}

proc initGame(width, height, fps: int32, flags: Flags[ConfigFlags], title: string): Game =
  assert not isWindowReady(), "Window is already opened"
  setConfigFlags(flags)
  initWindow(width, height, title)
  setTargetFPS(fps)

let game = initGame(800, 450, 60, flags(Msaa4xHint, WindowHighdpi), "example")
```

---

## Embedded Resources and Pixel Formats

When working with data embedded directly in the binary (via `exportImageAsCode`), use "weak" views to avoid unnecessary memory overhead.

### Weak Views

`toWeakImage` and `toWeakWave` create non-owning references to static data.

```nim
# ImageData is a static array embedded in the binary
let image = toWeakImage(ImageData, ImageWidth, ImageHeight, ImageFormat)
let texture = loadTextureFromImage(Image(image)) 
```

### Custom Pixel Formats

You can define custom mappings for external data sources using `pixelKind`. Naylib will automatically infer the format and validate buffer sizes.

```nim
type RGBAPixel* = distinct byte

template pixelKind*(x: typedesc[RGBAPixel]): PixelFormat =
  UncompressedR8g8b8a8

let rgba = loadExternalRGBA8(width, height)
let tex = loadTextureFromData(rgba, width, height)
updateTexture(tex, rgba)
```

---

## Math Library Integration

Naylib is designed to be math-agnostic. If you use external libraries like `vmath` or `glm`, you can bridge them using converters.

```nim
converter toVector2*(v: geometrymath.Vector2[float32]): raylib.Vector2 {.inline.} =
  raylib.Vector2(x: v.x, y: v.y)

converter fromVector2*(v: raylib.Vector2): geometrymath.Vector2[float32] {.inline.} =
  geometrymath.Vector2[float32](x: v.x, y: v.y)
```

