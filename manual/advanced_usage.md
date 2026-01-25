## 0. Destructor-Based Memory Management (No `Unload*` APIs)

### Why `Unload*` Functions Are Not Exported

Naylib manages Raylib resources (`Image`, `Wave`, `Texture`, `Shader`, `Mesh`, etc.) using **destructors**, not `Unload*` functions.

* `Unload*` APIs are **not exported**
* Resources are released automatically when they go out of scope
* Manual unload calls are unnecessary

This follows Nim’s RAII model and prevents double-free and lifetime errors.

### Forcing Early Resource Release

If a resource must be released early, use `reset`:

```nim
var texture = loadTexture("resources/example.png")
reset(texture) # explicitly destroy the resource
```

This immediately invokes the destructor. Use only when necessary.

---

## 1. Memory Management

### Handling Types Without Copy Hooks

Some Naylib types—such as `Texture`, `Shader`, `Mesh`, and `Font`—intentionally do **not** define `=copy` hooks in order to prevent accidental copying of resource handles.

If shared access is required, use references:

```nim
var texture: ref Texture
new(texture)
texture[] = loadTexture("resources/example.png")

let copy = texture # Copies the reference, not the resource
```

This ensures that ownership remains explicit and prevents unintended duplication of GPU-backed resources.

---

## 2. Common Patterns and Idioms

### Texture Ownership in Models

Assigning a texture to a model performs only a **shallow copy** of the texture handle. The model does not take ownership of the resource; it merely stores another handle referring to the same underlying texture.

The texture must therefore remain valid and in scope for the entire duration of the model’s use.

```nim
var model = loadModel("resources/models/plane.obj")
let texture = loadTexture("resources/models/plane_diffuse.png")

model.materials[0].maps[MaterialMapIndex.Diffuse].texture = texture
```

### Mesh Ownership Transfer

When creating a model from a mesh, ownership *is* transferred.

The `sink Mesh` parameter consumes the argument. Because copy operations are disabled for `Mesh`, the compiler enforces that the mesh is moved into the model. After the call, the original variable must no longer be used.

```nim
let mesh = genMeshHeightmap(image, Vector3(x: 16, y: 8, z: 16))
var model = loadModelFromMesh(mesh) # Mesh is consumed and owned by the model
```

At this point, the model is responsible for unloading the mesh via its destructor.

---

## 3. Advanced Usage Patterns

### Properly Calling `closeWindow`

Although most resources are managed via destructors, `closeWindow` requires special care. It **must be called at the very end of the program**, after all dependent variables have been destroyed.

Recommended patterns:

#### 1. Using `defer` (or `try` / `finally`)

```nim
initWindow(800, 450, "example")
defer: closeWindow()

let texture = loadTexture("resources/example.png")
# Game logic goes here
```

#### 2. Wrapping the window lifetime in an owning object

```nim
type Game = object

proc `=destroy`(x: Game) =
  assert isWindowReady(), "Window is already closed"
  closeWindow()

# Disable copying and moving
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
let texture = loadTexture("resources/example.png")
# Game logic goes here
```

---

## 4. Working with Embedded Resources

Embedded byte arrays (exported via `exportImageAsCode` or `exportWaveAsCode`) should be wrapped as **non-owning views** using `toWeakImage` or `toWeakWave`.

These weak views reference static data embedded in the binary and do not manage memory themselves.

```nim
# Embedded arrays are part of the binary. Metadata must match the embedded data.
let image = toWeakImage(ImageData, ImageWidth, ImageHeight, ImageFormat)
let texture = loadTextureFromImage(Image(image)) # convert WeakImage to Image
```

This avoids unnecessary copying while remaining compatible with standard loading APIs.

---

## 5. Custom Pixel Formats

Custom mappings from element types to GPU formats can be defined using `pixelKind`. The API automatically infers the pixel format from the element type and validates both size and layout during uploads.

```nim
type RGBAPixel* = distinct byte

template pixelKind*(x: typedesc[RGBAPixel]): PixelFormat =
  UncompressedR8g8b8a8

proc loadExternalRGBA8(width, height: int): seq[RGBAPixel]

let rgba = loadExternalRGBA8(width, height)
let tex = loadTextureFromData(rgba, width, height)
updateTexture(tex, rgba)
```

The API enforces that:

* `len(rgba) == width * height * 4`
* The inferred format matches the declared `pixelKind`

This provides strong correctness guarantees while remaining flexible for external data sources.

---

## 6. Swapping `raymath`

Raylib is independent of `raymath`. You may use alternative math libraries such as `vmath`, `geometrymath`, or `glm`.

If you do, define converters for the Raylib math types you use:

```nim
converter toVector2*(v: geometrymath.Vector2[float32]): raylib.Vector2 {.inline.} =
  raylib.Vector2(x: v.x, y: v.y)

converter fromVector2*(v: raylib.Vector2): geometrymath.Vector2[float32] {.inline.} =
  geometrymath.Vector2[float32](x: v.x, y: v.y)
```

