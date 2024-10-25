// raylib_wrapper.h
#pragma once  // Prevent multiple inclusions

// First, save any existing Windows macros/definitions if they exist
#ifdef CloseWindow
  #define PREV_CloseWindow CloseWindow
  #undef CloseWindow
#endif

#ifdef Rectangle
  #define PREV_Rectangle Rectangle
  #undef Rectangle
#endif

#ifdef ShowCursor
  #define PREV_ShowCursor ShowCursor
  #undef ShowCursor
#endif

#ifdef LoadImage
  #define PREV_LoadImage LoadImage
  #undef LoadImage
#endif

#ifdef DrawText
  #define PREV_DrawText DrawText
  #undef DrawText
#endif

#ifdef DrawTextEx
  #define PREV_DrawTextEx DrawTextEx
  #undef DrawTextEx
#endif

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

// Restore previous Windows definitions if they existed
#ifdef PREV_CloseWindow
  #define CloseWindow PREV_CloseWindow
  #undef PREV_CloseWindow
#endif

#ifdef PREV_Rectangle
  #define Rectangle PREV_Rectangle
  #undef PREV_Rectangle
#endif

#ifdef PREV_ShowCursor
  #define ShowCursor PREV_ShowCursor
  #undef PREV_ShowCursor
#endif

#ifdef PREV_LoadImage
  #define LoadImage PREV_LoadImage
  #undef PREV_LoadImage
#endif

#ifdef PREV_DrawText
  #define DrawText PREV_DrawText
  #undef PREV_DrawText
#endif

#ifdef PREV_DrawTextEx
  #define DrawTextEx PREV_DrawTextEx
  #undef PREV_DrawTextEx
#endif
