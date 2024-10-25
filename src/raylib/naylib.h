// Only redefine if the Windows names aren't already defined
#ifndef RECTANGLE_DEFINED
  #define Rectangle rlRectangle
  #define RECTANGLE_DEFINED
#endif

#ifndef CLOSEWINDOW_DEFINED
  #define CloseWindow rlCloseWindow
  #define CLOSEWINDOW_DEFINED
#endif

#ifndef SHOWCURSOR_DEFINED
  #define ShowCursor rlShowCursor
  #define SHOWCURSOR_DEFINED
#endif

#ifndef LOADIMAGE_DEFINED
  #define LoadImage rlLoadImage
  #define LOADIMAGE_DEFINED
#endif

#ifndef DRAWTEXT_DEFINED
  #define DrawText rlDrawText
  #define DRAWTEXT_DEFINED
#endif

#ifndef DRAWTEXTEX_DEFINED
  #define DrawTextEx rlDrawTextEx
  #define DRAWTEXTEX_DEFINED
#endif

// Include raylib after setting up the defines
#include "raylib.h"

// Undefine to restore original Windows API names if necessary
#ifdef RECTANGLE_DEFINED
  #undef Rectangle
  #undef RECTANGLE_DEFINED
#endif

#ifdef CLOSEWINDOW_DEFINED
  #undef CloseWindow
  #undef CLOSEWINDOW_DEFINED
#endif

#ifdef SHOWCURSOR_DEFINED
  #undef ShowCursor
  #undef SHOWCURSOR_DEFINED
#endif

#ifdef LOADIMAGE_DEFINED
  #undef LoadImage
  #undef LOADIMAGE_DEFINED
#endif

#ifdef DRAWTEXT_DEFINED
  #undef DrawText
  #undef DRAWTEXT_DEFINED
#endif

#ifdef DRAWTEXTEX_DEFINED
  #undef DrawTextEx
  #undef DRAWTEXTEX_DEFINED
#endif
