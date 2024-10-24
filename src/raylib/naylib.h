// Windows API naming conflict workarounds
#define Rectangle rlRectangle
#define CloseWindow rlCloseWindow
#define ShowCursor rlShowCursor
#define LoadImage rlLoadImage
#define DrawText rlDrawText
#define DrawTextEx rlDrawTextEx

#include "raylib.h"

#undef Rectangle
#undef CloseWindow
#undef ShowCursor
#undef LoadImage
#undef DrawText
#undef DrawTextEx
