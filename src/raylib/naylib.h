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

// Include raylib with our names
#include "raylib.h"

#define rlRectangle Rectangle
// Create our wrapped versions with unique names
inline void rlCloseWindow(void) { CloseWindow(); }
inline void rlShowCursor(void) { ShowCursor(); }
inline Image rlLoadImage(const char* fileName) { return LoadImage(fileName); }
inline void rlDrawText(const char* text, int x, int y, int fontSize, Color color) { DrawText(text, x, y, fontSize, color); }
inline void rlDrawTextEx(Font font, const char* text, Vector2 position, float fontSize, float spacing, Color tint) {
    DrawTextEx(font, text, position, fontSize, spacing, tint);
}

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
