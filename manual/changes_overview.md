# Overview of Changes

## Memory Management of Raylib Types using Destructors

In Naylib, types such as `Image` and `Wave` utilize destructors for memory management. This approach not only eliminates the need for manual `Unload` calls but also offers other benefits, including more reliable and safer memory management, reduced code complexity, and easier maintenance.

## Change in Naming Convention

In raylib, various functions have similar names that differ in suffixes based on the type of arguments they receive. For instance, functions like `DrawRectangle`, `DrawRectangleV`, `DrawRectangleRec`, and `DrawRectanglePro` vary in their suffixes. However, in Naylib, this naming convention has changed. Functions that return `Vector2` or `Rectangle` still follow the previous naming convention, but function overloading is now used for cases that previously employed different suffixes. This allows for a more uniform and intuitive naming convention.

## Encapsulation and Safe API for Pointers to Arrays of Structures

Data types that hold pointers to arrays of structures, such as `Model`, are encapsulated and offer index operators to provide a safe and idiomatic API. As an example, the code snippet `model.materials[0].maps[MaterialMapIndex.Diffuse].texture = texture` includes a runtime bounds check on the index to ensure safe access to the data.

## Mapping of C Enums to Nim

The C enums have been mapped to Nim, and their values have been shortened by removing their prefix. For instance, `LOG_TRACE` is represented as `Trace`.

## Type Checking for Enums

Each function argument, array index or object field that is intended to employ a particular enum type undergoes type checking. Consequently, erroneous code such as `isKeyPressed(MouseButton.Left)` fails to compile.

## Abstraction of Raw Pointers and CString Parameters

To improve the safety and usability of the public API, Naylib has abstracted the use of raw pointers through the use of `openArray[T]`. `cstring` parameters are automatically wrapped to `string`.

## Safer Begin-End Pairs with Syntactic Sugar

To enhance the usability of begin-end pairs like `beginDrawing` and `endDrawing` in naylib, additional syntactic sugar has been introduced in the form of templates such as `drawing` and `mode3D`. These templates can accept a block of code and offer added safety measures in case of any errors. As a result, even if an error occurs, the program will not be left in an invalid state, as the "end" part will always be executed.

## Addition of RArray Type

The `RArray[T]` type has been added to encapsulate memory managed by raylib. It provides index operators, len, and `@` (which converts to `seq`) and `toOpenArray`. You can use this type to work with raylib functions that manage memory without needing to make copies.

## Working with Bitflags in Nim

Raylib uses bitflags for `ConfigFlags` and `Gesture`. To work with these flags in Nim, you can use the `flags` procedure which returns `Flags[T]`. An example of this would be `flags(Msaa4xHint, WindowHighdpi)`.

## Change in Dropped Files Functions

In raylib 4.2, the functions `LoadDroppedFiles` and `UnloadDroppedFiles` were introduced but were later removed. Instead, the older function `getDroppedFiles` was reintroduced as it is more efficient and easier to wrap, requiring fewer copies.

## Using Embedded Images and Waves in Naylib

Use the `toWeak*` procs to get an `WeakImage` or `WeakWave`, which are not memory managed and can be embedded directly into source code. To use this feature, first export the image or wave as code using the `exportImageAsCode` or `exportWaveAsCode` procs. An example of how to use this feature can be found in the example [others/embedded_files_loading.nim](https://github.com/planetis-m/raylib-examples/blob/main/others/embedded_files_loading.nim).

## Integration of External Data Types with ShaderV and Pixel

The concepts of `ShaderV` and `Pixel` permit the integration of external data types into procs that employ them, such as `setShaderValue` and `updateTexture`.

## Using IsValid() in Asset Loading

To prevent unexpected behavior or crashes, `Load()` functions utilize `IsValid()` to confirm asset loading success and raise `RaylibError` if an asset is not found. This approach ensures that the program not only logs an error but also immediately takes action to handle it appropriately.

## Math Libraries

In addition to porting the `raymath` and `reasings` libraries to Nim, Naylib also provides math operators like `+`, `*`, `-=` for convenience.
