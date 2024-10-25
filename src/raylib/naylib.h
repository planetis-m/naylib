// raylib_wrapper.h
#pragma once  // Prevent multiple inclusions

// Step 1: Redefine conflicting raylib symbols to custom names
#define Rectangle rlRectangle
#define CloseWindow rlCloseWindow
#define ShowCursor rlShowCursor
#define LoadImage rlLoadImage
#define DrawText rlDrawText
#define DrawTextEx rlDrawTextEx

// Step 2: Include raylib.h with renamed symbols
#include "raylib.h"

// Step 3: Undefine the renaming macros to avoid affecting other includes
#undef Rectangle
#undef CloseWindow
#undef ShowCursor
#undef LoadImage
#undef DrawText
#undef DrawTextEx
