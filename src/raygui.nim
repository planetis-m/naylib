import raylib

from os import parentDir, `/`
const rayguiHeader = currentSourcePath().parentDir()/"raylib/raygui.h"
{.passC: "-DRAYGUI_IMPLEMENTATION".}

## *****************************************************************************************
##
##    raygui v4.5-dev - A simple and easy-to-use immediate-mode gui library
##
##    DESCRIPTION:
##        raygui is a tools-dev-focused immediate-mode-gui library based on raylib but also
##        available as a standalone library, as long as input and drawing functions are provided.
##
##    FEATURES:
##        - Immediate-mode gui, minimal retained data
##        - +25 controls provided (basic and advanced)
##        - Styling system for colors, font and metrics
##        - Icons supported, embedded as a 1-bit icons pack
##        - Standalone mode option (custom input/graphics backend)
##        - Multiple support tools provided for raygui development
##
##    POSSIBLE IMPROVEMENTS:
##        - Better standalone mode API for easy plug of custom backends
##        - Externalize required inputs, allow user easier customization
##
##    LIMITATIONS:
##        - No editable multi-line word-wraped text box supported
##        - No auto-layout mechanism, up to the user to define controls position and size
##        - Standalone mode requires library modification and some user work to plug another backend
##
##    NOTES:
##        - WARNING: GuiLoadStyle() and GuiLoadStyle{Custom}() functions, allocate memory for
##          font atlas recs and glyphs, freeing that memory is (usually) up to the user,
##          no unload function is explicitly provided... but note that GuiLoadStyleDefault() unloads
##          by default any previously loaded font (texture, recs, glyphs).
##        - Global UI alpha (guiAlpha) is applied inside GuiDrawRectangle() and GuiDrawText() functions
##
##    CONTROLS PROVIDED:
##      # Container/separators Controls
##        - WindowBox     --> StatusBar, Panel
##        - GroupBox      --> Line
##        - Line
##        - Panel         --> StatusBar
##        - ScrollPanel   --> StatusBar
##        - TabBar        --> Button
##
##      # Basic Controls
##        - Label
##        - LabelButton   --> Label
##        - Button
##        - Toggle
##        - ToggleGroup   --> Toggle
##        - ToggleSlider
##        - CheckBox
##        - ComboBox
##        - DropdownBox
##        - TextBox
##        - ValueBox      --> TextBox
##        - Spinner       --> Button, ValueBox
##        - Slider
##        - SliderBar     --> Slider
##        - ProgressBar
##        - StatusBar
##        - DummyRec
##        - Grid
##
##      # Advance Controls
##        - ListView
##        - ColorPicker   --> ColorPanel, ColorBarHue
##        - MessageBox    --> Window, Label, Button
##        - TextInputBox  --> Window, Label, TextBox, Button
##
##      It also provides a set of functions for styling the controls based on its properties (size, color).
##
##
##    RAYGUI STYLE (guiStyle):
##        raygui uses a global data array for all gui style properties (allocated on data segment by default),
##        when a new style is loaded, it is loaded over the global style... but a default gui style could always be
##        recovered with GuiLoadStyleDefault() function, that overwrites the current style to the default one
##
##        The global style array size is fixed and depends on the number of controls and properties:
##
##            static unsigned int guiStyle[RAYGUI_MAX_CONTROLS*(RAYGUI_MAX_PROPS_BASE + RAYGUI_MAX_PROPS_EXTENDED)];
##
##        guiStyle size is by default: 16*(16 + 8) = 384*4 = 1536 bytes = 1.5 KB
##
##        Note that the first set of BASE properties (by default guiStyle[0..15]) belong to the generic style
##        used for all controls, when any of those base values is set, it is automatically populated to all
##        controls, so, specific control values overwriting generic style should be set after base values.
##
##        After the first BASE set we have the EXTENDED properties (by default guiStyle[16..23]), those
##        properties are actually common to all controls and can not be overwritten individually (like BASE ones)
##        Some of those properties are: TEXT_SIZE, TEXT_SPACING, LINE_COLOR, BACKGROUND_COLOR
##
##        Custom control properties can be defined using the EXTENDED properties for each independent control.
##
##        TOOL: rGuiStyler is a visual tool to customize raygui style: github.com/raysan5/rguistyler
##
##
##    RAYGUI ICONS (guiIcons):
##        raygui could use a global array containing icons data (allocated on data segment by default),
##        a custom icons set could be loaded over this array using GuiLoadIcons(), but loaded icons set
##        must be same RAYGUI_ICON_SIZE and no more than RAYGUI_ICON_MAX_ICONS will be loaded
##
##        Every icon is codified in binary form, using 1 bit per pixel, so, every 16x16 icon
##        requires 8 integers (16*16/32) to be stored in memory.
##
##        When the icon is draw, actually one quad per pixel is drawn if the bit for that pixel is set.
##
##        The global icons array size is fixed and depends on the number of icons and size:
##
##            static unsigned int guiIcons[RAYGUI_ICON_MAX_ICONS*RAYGUI_ICON_DATA_ELEMENTS];
##
##        guiIcons size is by default: 256*(16*16/32) = 2048*4 = 8192 bytes = 8 KB
##
##        TOOL: rGuiIcons is a visual tool to customize/create raygui icons: github.com/raysan5/rguiicons
##
##    RAYGUI LAYOUT:
##        raygui currently does not provide an auto-layout mechanism like other libraries,
##        layouts must be defined manually on controls drawing, providing the right bounds Rectangle for it.
##
##        TOOL: rGuiLayout is a visual tool to create raygui layouts: github.com/raysan5/rguilayout
##
##    CONFIGURATION:
##        #define RAYGUI_IMPLEMENTATION
##            Generates the implementation of the library into the included file.
##            If not defined, the library is in header only mode and can be included in other headers
##            or source files without problems. But only ONE file should hold the implementation.
##
##        #define RAYGUI_STANDALONE
##            Avoid raylib.h header inclusion in this file. Data types defined on raylib are defined
##            internally in the library and input management and drawing functions must be provided by
##            the user (check library implementation for further details).
##
##        #define RAYGUI_NO_ICONS
##            Avoid including embedded ricons data (256 icons, 16x16 pixels, 1-bit per pixel, 2KB)
##
##        #define RAYGUI_CUSTOM_ICONS
##            Includes custom ricons.h header defining a set of custom icons,
##            this file can be generated using rGuiIcons tool
##
##        #define RAYGUI_DEBUG_RECS_BOUNDS
##            Draw control bounds rectangles for debug
##
##        #define RAYGUI_DEBUG_TEXT_BOUNDS
##            Draw text bounds rectangles for debug
##
##    VERSIONS HISTORY:
##        5.0-dev (2025)    Current dev version...
##                          ADDED: guiControlExclusiveMode and guiControlExclusiveRec for exclusive modes
##                          ADDED: GuiValueBoxFloat()
##                          ADDED: GuiDropdonwBox() properties: DROPDOWN_ARROW_HIDDEN, DROPDOWN_ROLL_UP
##                          ADDED: GuiListView() property: LIST_ITEMS_BORDER_WIDTH
##                          ADDED: GuiLoadIconsFromMemory()
##                          ADDED: Multiple new icons
##                          REMOVED: GuiSpinner() from controls list, using BUTTON + VALUEBOX properties
##                          REMOVED: GuiSliderPro(), functionality was redundant
##                          REVIEWED: Controls using text labels to use LABEL properties
##                          REVIEWED: Replaced sprintf() by snprintf() for more safety
##                          REVIEWED: GuiTabBar(), close tab with mouse middle button
##                          REVIEWED: GuiScrollPanel(), scroll speed proportional to content
##                          REVIEWED: GuiDropdownBox(), support roll up and hidden arrow
##                          REVIEWED: GuiTextBox(), cursor position initialization
##                          REVIEWED: GuiSliderPro(), control value change check
##                          REVIEWED: GuiGrid(), simplified implementation
##                          REVIEWED: GuiIconText(), increase buffer size and reviewed padding
##                          REVIEWED: GuiDrawText(), improved wrap mode drawing
##                          REVIEWED: GuiScrollBar(), minor tweaks
##                          REVIEWED: GuiProgressBar(), improved borders computing
##                          REVIEWED: GuiTextBox(), multiple improvements: autocursor and more
##                          REVIEWED: Functions descriptions, removed wrong return value reference
##                          REDESIGNED: GuiColorPanel(), improved HSV <-> RGBA convertion
##
##        4.0 (12-Sep-2023) ADDED: GuiToggleSlider()
##                          ADDED: GuiColorPickerHSV() and GuiColorPanelHSV()
##                          ADDED: Multiple new icons, mostly compiler related
##                          ADDED: New DEFAULT properties: TEXT_LINE_SPACING, TEXT_ALIGNMENT_VERTICAL, TEXT_WRAP_MODE
##                          ADDED: New enum values: GuiTextAlignment, GuiTextAlignmentVertical, GuiTextWrapMode
##                          ADDED: Support loading styles with custom font charset from external file
##                          REDESIGNED: GuiTextBox(), support mouse cursor positioning
##                          REDESIGNED: GuiDrawText(), support multiline and word-wrap modes (read only)
##                          REDESIGNED: GuiProgressBar() to be more visual, progress affects border color
##                          REDESIGNED: Global alpha consideration moved to GuiDrawRectangle() and GuiDrawText()
##                          REDESIGNED: GuiScrollPanel(), get parameters by reference and return result value
##                          REDESIGNED: GuiToggleGroup(), get parameters by reference and return result value
##                          REDESIGNED: GuiComboBox(), get parameters by reference and return result value
##                          REDESIGNED: GuiCheckBox(), get parameters by reference and return result value
##                          REDESIGNED: GuiSlider(), get parameters by reference and return result value
##                          REDESIGNED: GuiSliderBar(), get parameters by reference and return result value
##                          REDESIGNED: GuiProgressBar(), get parameters by reference and return result value
##                          REDESIGNED: GuiListView(), get parameters by reference and return result value
##                          REDESIGNED: GuiColorPicker(), get parameters by reference and return result value
##                          REDESIGNED: GuiColorPanel(), get parameters by reference and return result value
##                          REDESIGNED: GuiColorBarAlpha(), get parameters by reference and return result value
##                          REDESIGNED: GuiColorBarHue(), get parameters by reference and return result value
##                          REDESIGNED: GuiGrid(), get parameters by reference and return result value
##                          REDESIGNED: GuiGrid(), added extra parameter
##                          REDESIGNED: GuiListViewEx(), change parameters order
##                          REDESIGNED: All controls return result as int value
##                          REVIEWED: GuiScrollPanel() to avoid smallish scroll-bars
##                          REVIEWED: All examples and specially controls_test_suite
##                          RENAMED: gui_file_dialog module to gui_window_file_dialog
##                          UPDATED: All styles to include ISO-8859-15 charset (as much as possible)
##
##        3.6 (10-May-2023) ADDED: New icon: SAND_TIMER
##                          ADDED: GuiLoadStyleFromMemory() (binary only)
##                          REVIEWED: GuiScrollBar() horizontal movement key
##                          REVIEWED: GuiTextBox() crash on cursor movement
##                          REVIEWED: GuiTextBox(), additional inputs support
##                          REVIEWED: GuiLabelButton(), avoid text cut
##                          REVIEWED: GuiTextInputBox(), password input
##                          REVIEWED: Local GetCodepointNext(), aligned with raylib
##                          REDESIGNED: GuiSlider*()/GuiScrollBar() to support out-of-bounds
##
##        3.5 (20-Apr-2023) ADDED: GuiTabBar(), based on GuiToggle()
##                          ADDED: Helper functions to split text in separate lines
##                          ADDED: Multiple new icons, useful for code editing tools
##                          REMOVED: Unneeded icon editing functions
##                          REMOVED: GuiTextBoxMulti(), very limited and broken
##                          REMOVED: MeasureTextEx() dependency, logic directly implemented
##                          REMOVED: DrawTextEx() dependency, logic directly implemented
##                          REVIEWED: GuiScrollBar(), improve mouse-click behaviour
##                          REVIEWED: Library header info, more info, better organized
##                          REDESIGNED: GuiTextBox() to support cursor movement
##                          REDESIGNED: GuiDrawText() to divide drawing by lines
##
##        3.2 (22-May-2022) RENAMED: Some enum values, for unification, avoiding prefixes
##                          REMOVED: GuiScrollBar(), only internal
##                          REDESIGNED: GuiPanel() to support text parameter
##                          REDESIGNED: GuiScrollPanel() to support text parameter
##                          REDESIGNED: GuiColorPicker() to support text parameter
##                          REDESIGNED: GuiColorPanel() to support text parameter
##                          REDESIGNED: GuiColorBarAlpha() to support text parameter
##                          REDESIGNED: GuiColorBarHue() to support text parameter
##                          REDESIGNED: GuiTextInputBox() to support password
##
##        3.1 (12-Jan-2022) REVIEWED: Default style for consistency (aligned with rGuiLayout v2.5 tool)
##                          REVIEWED: GuiLoadStyle() to support compressed font atlas image data and unload previous textures
##                          REVIEWED: External icons usage logic
##                          REVIEWED: GuiLine() for centered alignment when including text
##                          RENAMED: Multiple controls properties definitions to prepend RAYGUI_
##                          RENAMED: RICON_ references to RAYGUI_ICON_ for library consistency
##                          Projects updated and multiple tweaks
##
##        3.0 (04-Nov-2021) Integrated ricons data to avoid external file
##                          REDESIGNED: GuiTextBoxMulti()
##                          REMOVED: GuiImageButton*()
##                          Multiple minor tweaks and bugs corrected
##
##        2.9 (17-Mar-2021) REMOVED: Tooltip API
##        2.8 (03-May-2020) Centralized rectangles drawing to GuiDrawRectangle()
##        2.7 (20-Feb-2020) ADDED: Possible tooltips API
##        2.6 (09-Sep-2019) ADDED: GuiTextInputBox()
##                          REDESIGNED: GuiListView*(), GuiDropdownBox(), GuiSlider*(), GuiProgressBar(), GuiMessageBox()
##                          REVIEWED: GuiTextBox(), GuiSpinner(), GuiValueBox(), GuiLoadStyle()
##                          Replaced property INNER_PADDING by TEXT_PADDING, renamed some properties
##                          ADDED: 8 new custom styles ready to use
##                          Multiple minor tweaks and bugs corrected
##
##        2.5 (28-May-2019) Implemented extended GuiTextBox(), GuiValueBox(), GuiSpinner()
##        2.3 (29-Apr-2019) ADDED: rIcons auxiliar library and support for it, multiple controls reviewed
##                          Refactor all controls drawing mechanism to use control state
##        2.2 (05-Feb-2019) ADDED: GuiScrollBar(), GuiScrollPanel(), reviewed GuiListView(), removed Gui*Ex() controls
##        2.1 (26-Dec-2018) REDESIGNED: GuiCheckBox(), GuiComboBox(), GuiDropdownBox(), GuiToggleGroup() > Use combined text string
##                          REDESIGNED: Style system (breaking change)
##        2.0 (08-Nov-2018) ADDED: Support controls guiLock and custom fonts
##                          REVIEWED: GuiComboBox(), GuiListView()...
##        1.9 (09-Oct-2018) REVIEWED: GuiGrid(), GuiTextBox(), GuiTextBoxMulti(), GuiValueBox()...
##        1.8 (01-May-2018) Lot of rework and redesign to align with rGuiStyler and rGuiLayout
##        1.5 (21-Jun-2017) Working in an improved styles system
##        1.4 (15-Jun-2017) Rewritten all GUI functions (removed useless ones)
##        1.3 (12-Jun-2017) Complete redesign of style system
##        1.1 (01-Jun-2017) Complete review of the library
##        1.0 (07-Jun-2016) Converted to header-only by Ramon Santamaria.
##        0.9 (07-Mar-2016) Reviewed and tested by Albert Martos, Ian Eito, Sergio Martinez and Ramon Santamaria.
##        0.8 (27-Aug-2015) Initial release. Implemented by Kevin Gato, Daniel Nicolás and Ramon Santamaria.
##
##    DEPENDENCIES:
##        raylib 5.0  - Inputs reading (keyboard/mouse), shapes drawing, font loading and text drawing
##
##    STANDALONE MODE:
##        By default raygui depends on raylib mostly for the inputs and the drawing functionality but that dependency can be disabled
##        with the config flag RAYGUI_STANDALONE. In that case is up to the user to provide another backend to cover library needs.
##
##        The following functions should be redefined for a custom backend:
##
##            - Vector2 GetMousePosition(void);
##            - float GetMouseWheelMove(void);
##            - bool IsMouseButtonDown(int button);
##            - bool IsMouseButtonPressed(int button);
##            - bool IsMouseButtonReleased(int button);
##            - bool IsKeyDown(int key);
##            - bool IsKeyPressed(int key);
##            - int GetCharPressed(void);         // -- GuiTextBox(), GuiValueBox()
##
##            - void DrawRectangle(int x, int y, int width, int height, Color color); // -- GuiDrawRectangle()
##            - void DrawRectangleGradientEx(Rectangle rec, Color col1, Color col2, Color col3, Color col4); // -- GuiColorPicker()
##
##            - Font GetFontDefault(void);                            // -- GuiLoadStyleDefault()
##            - Font LoadFontEx(const char *fileName, int fontSize, int *codepoints, int codepointCount); // -- GuiLoadStyle()
##            - Texture2D LoadTextureFromImage(Image image);          // -- GuiLoadStyle(), required to load texture from embedded font atlas image
##            - void SetShapesTexture(Texture2D tex, Rectangle rec);  // -- GuiLoadStyle(), required to set shapes rec to font white rec (optimization)
##            - char *LoadFileText(const char *fileName);             // -- GuiLoadStyle(), required to load charset data
##            - void UnloadFileText(char *text);                      // -- GuiLoadStyle(), required to unload charset data
##            - const char *GetDirectoryPath(const char *filePath);   // -- GuiLoadStyle(), required to find charset/font file from text .rgs
##            - int *LoadCodepoints(const char *text, int *count);    // -- GuiLoadStyle(), required to load required font codepoints list
##            - void UnloadCodepoints(int *codepoints);               // -- GuiLoadStyle(), required to unload codepoints list
##            - unsigned char *DecompressData(const unsigned char *compData, int compDataSize, int *dataSize); // -- GuiLoadStyle()
##
##    CONTRIBUTORS:
##        Ramon Santamaria:   Supervision, review, redesign, update and maintenance
##        Vlad Adrian:        Complete rewrite of GuiTextBox() to support extended features (2019)
##        Sergio Martinez:    Review, testing (2015) and redesign of multiple controls (2018)
##        Adria Arranz:       Testing and implementation of additional controls (2018)
##        Jordi Jorba:        Testing and implementation of additional controls (2018)
##        Albert Martos:      Review and testing of the library (2015)
##        Ian Eito:           Review and testing of the library (2015)
##        Kevin Gato:         Initial implementation of basic components (2014)
##        Daniel Nicolas:     Initial implementation of basic components (2014)
##
##
##    LICENSE: zlib/libpng
##
##    Copyright (c) 2014-2025 Ramon Santamaria (@raysan5)
##
##    This software is provided "as-is", without any express or implied warranty. In no event
##    will the authors be held liable for any damages arising from the use of this software.
##
##    Permission is granted to anyone to use this software for any purpose, including commercial
##    applications, and to alter it and redistribute it freely, subject to the following restrictions:
##
##      1. The origin of this software must not be misrepresented; you must not claim that you
##      wrote the original software. If you use this software in a product, an acknowledgment
##      in the product documentation would be appreciated but is not required.
##
##      2. Altered source versions must be plainly marked as such, and must not be misrepresented
##      as being the original software.
##
##      3. This notice may not be removed or altered from any source distribution.
##
## ********************************************************************************************

const
  RAYGUI_VERSION_MAJOR* = 4
  RAYGUI_VERSION_MINOR* = 5
  RAYGUI_VERSION_PATCH* = 0
  RAYGUI_VERSION* = "5.0-dev"

## ----------------------------------------------------------------------------------
##  Defines and Macros
## ----------------------------------------------------------------------------------
##  Simple log system to avoid printf() calls if required
##  NOTE: Avoiding those calls, also avoids const strings memory usage

proc RAYGUI_LOG*() {.varargs, importc: "RAYGUI_LOG", header: rayguiHeader.}
## ----------------------------------------------------------------------------------
##  Types and Structures Definition
##  NOTE: Some types are required for RAYGUI_STANDALONE usage
## ----------------------------------------------------------------------------------

when defined(RAYGUI_STANDALONE):
  ##  Boolean type
  when not defined(true):
    type
      bool* {.size: sizeof(cint).} = enum
        false, true
  ##  Vector2 type
  type
    Vector2* {.importc: "Vector2", header: rayguiHeader, bycopy.} = object
      x* {.importc: "x".}: cfloat
      y* {.importc: "y".}: cfloat

  ##  Vector3 type                 // -- ConvertHSVtoRGB(), ConvertRGBtoHSV()
  type
    Vector3* {.importc: "Vector3", header: rayguiHeader, bycopy.} = object
      x* {.importc: "x".}: cfloat
      y* {.importc: "y".}: cfloat
      z* {.importc: "z".}: cfloat

  ##  Color type, RGBA (32bit)
  type
    Color* {.importc: "Color", header: rayguiHeader, bycopy.} = object
      r* {.importc: "r".}: cuchar
      g* {.importc: "g".}: cuchar
      b* {.importc: "b".}: cuchar
      a* {.importc: "a".}: cuchar

  ##  Rectangle type
  type
    Rectangle* {.importc: "Rectangle", header: rayguiHeader, bycopy.} = object
      x* {.importc: "x".}: cfloat
      y* {.importc: "y".}: cfloat
      width* {.importc: "width".}: cfloat
      height* {.importc: "height".}: cfloat

  ##  TODO: Texture2D type is very coupled to raylib, required by Font type
  ##  It should be redesigned to be provided by user
  type
    Texture2D* {.importc: "Texture2D", header: rayguiHeader, bycopy.} = object
      id* {.importc: "id".}: cuint
      ##  OpenGL texture id
      width* {.importc: "width".}: cint
      ##  Texture base width
      height* {.importc: "height".}: cint
      ##  Texture base height
      mipmaps* {.importc: "mipmaps".}: cint
      ##  Mipmap levels, 1 by default
      format* {.importc: "format".}: cint
      ##  Data format (PixelFormat type)

  ##  Image, pixel data stored in CPU memory (RAM)
  type
    Image* {.importc: "Image", header: rayguiHeader, bycopy.} = object
      data* {.importc: "data".}: pointer
      ##  Image raw data
      width* {.importc: "width".}: cint
      ##  Image base width
      height* {.importc: "height".}: cint
      ##  Image base height
      mipmaps* {.importc: "mipmaps".}: cint
      ##  Mipmap levels, 1 by default
      format* {.importc: "format".}: cint
      ##  Data format (PixelFormat type)

  ##  GlyphInfo, font characters glyphs info
  type
    GlyphInfo* {.importc: "GlyphInfo", header: rayguiHeader, bycopy.} = object
      value* {.importc: "value".}: cint
      ##  Character value (Unicode)
      offsetX* {.importc: "offsetX".}: cint
      ##  Character offset X when drawing
      offsetY* {.importc: "offsetY".}: cint
      ##  Character offset Y when drawing
      advanceX* {.importc: "advanceX".}: cint
      ##  Character advance position X
      image* {.importc: "image".}: Image
      ##  Character image data

  ##  TODO: Font type is very coupled to raylib, mostly required by GuiLoadStyle()
  ##  It should be redesigned to be provided by user
  type
    Font* {.importc: "Font", header: rayguiHeader, bycopy.} = object
      baseSize* {.importc: "baseSize".}: cint
      ##  Base size (default chars height)
      glyphCount* {.importc: "glyphCount".}: cint
      ##  Number of glyph characters
      glyphPadding* {.importc: "glyphPadding".}: cint
      ##  Padding around the glyph characters
      texture* {.importc: "texture".}: Texture2D
      ##  Texture atlas containing the glyphs
      recs* {.importc: "recs".}: ptr Rectangle
      ##  Rectangles in texture for the glyphs
      glyphs* {.importc: "glyphs".}: ptr GlyphInfo
      ##  Glyphs info data

##  Style property
##  NOTE: Used when exporting style as code for convenience

type
  GuiStyleProp* {.importc: "GuiStyleProp", header: rayguiHeader, bycopy.} = object
    controlId* {.importc: "controlId".}: cushort
    ##  Control identifier
    propertyId* {.importc: "propertyId".}: cushort
    ##  Property identifier
    propertyValue* {.importc: "propertyValue".}: cint
    ##  Property value


##
## // Controls text style -NOT USED-
## // NOTE: Text style is defined by control
## typedef struct GuiTextStyle {
##     unsigned int size;
##     int charSpacing;
##     int lineSpacing;
##     int alignmentH;
##     int alignmentV;
##     int padding;
## } GuiTextStyle;
##
##  Gui control state

type
  GuiState* {.size: sizeof(cint).} = enum
    STATE_NORMAL = 0, STATE_FOCUSED, STATE_PRESSED, STATE_DISABLED


##  Gui control text alignment

type
  GuiTextAlignment* {.size: sizeof(cint).} = enum
    TEXT_ALIGN_LEFT = 0, TEXT_ALIGN_CENTER, TEXT_ALIGN_RIGHT


##  Gui control text alignment vertical
##  NOTE: Text vertical position inside the text bounds

type
  GuiTextAlignmentVertical* {.size: sizeof(cint).} = enum
    TEXT_ALIGN_TOP = 0, TEXT_ALIGN_MIDDLE, TEXT_ALIGN_BOTTOM


##  Gui control text wrap mode
##  NOTE: Useful for multiline text

type
  GuiTextWrapMode* {.size: sizeof(cint).} = enum
    TEXT_WRAP_NONE = 0, TEXT_WRAP_CHAR, TEXT_WRAP_WORD


##  Gui controls

type                          ##  Default -> populates to all controls when set
  GuiControl* {.size: sizeof(cint).} = enum
    DEFAULT = 0,                ##  Basic controls
    LABEL,                    ##  Used also for: LABELBUTTON
    BUTTON, TOGGLE,            ##  Used also for: TOGGLEGROUP
    SLIDER,                   ##  Used also for: SLIDERBAR, TOGGLESLIDER
    PROGRESSBAR, CHECKBOX, COMBOBOX, DROPDOWNBOX, TEXTBOX, ##  Used also for: TEXTBOXMULTI
    VALUEBOX, CONTROL11, LISTVIEW, COLORPICKER, SCROLLBAR, STATUSBAR


##  Gui base properties for every control
##  NOTE: RAYGUI_MAX_PROPS_BASE properties (by default 16 properties)

type
  GuiControlProperty* {.size: sizeof(cint).} = enum
    BORDER_COLOR_NORMAL = 0,    ##  Control border color in STATE_NORMAL
    BASE_COLOR_NORMAL,        ##  Control base color in STATE_NORMAL
    TEXT_COLOR_NORMAL,        ##  Control text color in STATE_NORMAL
    BORDER_COLOR_FOCUSED,     ##  Control border color in STATE_FOCUSED
    BASE_COLOR_FOCUSED,       ##  Control base color in STATE_FOCUSED
    TEXT_COLOR_FOCUSED,       ##  Control text color in STATE_FOCUSED
    BORDER_COLOR_PRESSED,     ##  Control border color in STATE_PRESSED
    BASE_COLOR_PRESSED,       ##  Control base color in STATE_PRESSED
    TEXT_COLOR_PRESSED,       ##  Control text color in STATE_PRESSED
    BORDER_COLOR_DISABLED,    ##  Control border color in STATE_DISABLED
    BASE_COLOR_DISABLED,      ##  Control base color in STATE_DISABLED
    TEXT_COLOR_DISABLED,      ##  Control text color in STATE_DISABLED
    BORDER_WIDTH = 12, ##  Control border size, 0 for no border
                    ## TEXT_SIZE,                  // Control text size (glyphs max height) -> GLOBAL for all controls
                    ## TEXT_SPACING,               // Control text spacing between glyphs -> GLOBAL for all controls
                    ## TEXT_LINE_SPACING,          // Control text spacing between lines -> GLOBAL for all controls
    TEXT_PADDING = 13,          ##  Control text padding, not considering border
    TEXT_ALIGNMENT = 14 ##  Control text horizontal alignment inside control text bound (after border and padding)
                     ## TEXT_WRAP_MODE              // Control text wrap-mode inside text bounds -> GLOBAL for all controls


##  TODO: Which text styling properties should be global or per-control?
##  At this moment TEXT_PADDING and TEXT_ALIGNMENT is configured and saved per control while
##  TEXT_SIZE, TEXT_SPACING, TEXT_LINE_SPACING, TEXT_ALIGNMENT_VERTICAL, TEXT_WRAP_MODE are global and
##  should be configured by user as needed while defining the UI layout
##  Gui extended properties depend on control
##  NOTE: RAYGUI_MAX_PROPS_EXTENDED properties (by default, max 8 properties)
## ----------------------------------------------------------------------------------
##  DEFAULT extended properties
##  NOTE: Those properties are common to all controls or global
##  WARNING: We only have 8 slots for those properties by default!!! -> New global control: TEXT?

type
  GuiDefaultProperty* {.size: sizeof(cint).} = enum
    TEXT_SIZE = 16,             ##  Text size (glyphs max height)
    TEXT_SPACING,             ##  Text spacing between glyphs
    LINE_COLOR,               ##  Line control color
    BACKGROUND_COLOR,         ##  Background color
    TEXT_LINE_SPACING,        ##  Text spacing between lines
    TEXT_ALIGNMENT_VERTICAL,  ##  Text vertical alignment inside text bounds (after border and padding)
    TEXT_WRAP_MODE ##  Text wrap-mode inside text bounds
                  ## TEXT_DECORATION             // Text decoration: 0-None, 1-Underline, 2-Line-through, 3-Overline
                  ## TEXT_DECORATION_THICK       // Text decoration line thickness


##  Other possible text properties:
##  TEXT_WEIGHT                  // Normal, Italic, Bold -> Requires specific font change
##  TEXT_INDENT                  // Text indentation -> Now using TEXT_PADDING...
##  Label
## typedef enum { } GuiLabelProperty;
##  Button/Spinner
## typedef enum { } GuiButtonProperty;
##  Toggle/ToggleGroup

type
  GuiToggleProperty* {.size: sizeof(cint).} = enum
    GROUP_PADDING = 16          ##  ToggleGroup separation between toggles


##  Slider/SliderBar

type
  GuiSliderProperty* {.size: sizeof(cint).} = enum
    SLIDER_WIDTH = 16,          ##  Slider size of internal bar
    SLIDER_PADDING            ##  Slider/SliderBar internal bar padding


##  ProgressBar

type
  GuiProgressBarProperty* {.size: sizeof(cint).} = enum
    PROGRESS_PADDING = 16       ##  ProgressBar internal padding


##  ScrollBar

type
  GuiScrollBarProperty* {.size: sizeof(cint).} = enum
    ARROWS_SIZE = 16,           ##  ScrollBar arrows size
    ARROWS_VISIBLE,           ##  ScrollBar arrows visible
    SCROLL_SLIDER_PADDING,    ##  ScrollBar slider internal padding
    SCROLL_SLIDER_SIZE,       ##  ScrollBar slider size
    SCROLL_PADDING,           ##  ScrollBar scroll padding from arrows
    SCROLL_SPEED              ##  ScrollBar scrolling speed


##  CheckBox

type
  GuiCheckBoxProperty* {.size: sizeof(cint).} = enum
    CHECK_PADDING = 16          ##  CheckBox internal check padding


##  ComboBox

type
  GuiComboBoxProperty* {.size: sizeof(cint).} = enum
    COMBO_BUTTON_WIDTH = 16,    ##  ComboBox right button width
    COMBO_BUTTON_SPACING      ##  ComboBox button separation


##  DropdownBox

type
  GuiDropdownBoxProperty* {.size: sizeof(cint).} = enum
    ARROW_PADDING = 16,         ##  DropdownBox arrow separation from border and items
    DROPDOWN_ITEMS_SPACING,   ##  DropdownBox items separation
    DROPDOWN_ARROW_HIDDEN,    ##  DropdownBox arrow hidden
    DROPDOWN_ROLL_UP          ##  DropdownBox roll up flag (default rolls down)


##  TextBox/TextBoxMulti/ValueBox/Spinner

type
  GuiTextBoxProperty* {.size: sizeof(cint).} = enum
    TEXT_READONLY = 16          ##  TextBox in read-only mode: 0-text editable, 1-text no-editable


##  ValueBox/Spinner

type
  GuiValueBoxProperty* {.size: sizeof(cint).} = enum
    SPINNER_BUTTON_WIDTH = 16,  ##  Spinner left/right buttons width
    SPINNER_BUTTON_SPACING    ##  Spinner buttons separation


##  Control11
## typedef enum { } GuiControl11Property;
##  ListView

type
  GuiListViewProperty* {.size: sizeof(cint).} = enum
    LIST_ITEMS_HEIGHT = 16,     ##  ListView items height
    LIST_ITEMS_SPACING,       ##  ListView items separation
    SCROLLBAR_WIDTH,          ##  ListView scrollbar size (usually width)
    SCROLLBAR_SIDE,           ##  ListView scrollbar side (0-SCROLLBAR_LEFT_SIDE, 1-SCROLLBAR_RIGHT_SIDE)
    LIST_ITEMS_BORDER_NORMAL, ##  ListView items border enabled in normal state
    LIST_ITEMS_BORDER_WIDTH   ##  ListView items border width


##  ColorPicker

type
  GuiColorPickerProperty* {.size: sizeof(cint).} = enum
    COLOR_SELECTOR_SIZE = 16, HUEBAR_WIDTH, ##  ColorPicker right hue bar width
    HUEBAR_PADDING,           ##  ColorPicker right hue bar separation from panel
    HUEBAR_SELECTOR_HEIGHT,   ##  ColorPicker right hue bar selector height
    HUEBAR_SELECTOR_OVERFLOW  ##  ColorPicker right hue bar selector overflow


const
  SCROLLBAR_LEFT_SIDE* = 0
  SCROLLBAR_RIGHT_SIDE* = 1

## ----------------------------------------------------------------------------------
##  Global Variables Definition
## ----------------------------------------------------------------------------------
##  ...
## ----------------------------------------------------------------------------------
##  Module Functions Declaration
## ----------------------------------------------------------------------------------

##  Global gui state control functions

proc guiEnable*() {.cdecl, importc: "GuiEnable", header: rayguiHeader.}
##  Enable gui controls (global state)

proc guiDisable*() {.cdecl, importc: "GuiDisable", header: rayguiHeader.}
##  Disable gui controls (global state)

proc guiLock*() {.cdecl, importc: "GuiLock", header: rayguiHeader.}
##  Lock gui controls (global state)

proc guiUnlock*() {.cdecl, importc: "GuiUnlock", header: rayguiHeader.}
##  Unlock gui controls (global state)

proc guiIsLocked*(): bool {.cdecl, importc: "GuiIsLocked", header: rayguiHeader.}
##  Check if gui is locked (global state)

proc guiSetAlpha*(alpha: cfloat) {.cdecl, importc: "GuiSetAlpha", header: rayguiHeader.}
##  Set gui controls alpha (global state), alpha goes from 0.0f to 1.0f

proc guiSetState*(state: cint) {.cdecl, importc: "GuiSetState", header: rayguiHeader.}
##  Set gui state (global state)

proc guiGetState*(): cint {.cdecl, importc: "GuiGetState", header: rayguiHeader.}
##  Get gui state (global state)
##  Font set/get functions

proc guiSetFont*(font: Font) {.cdecl, importc: "GuiSetFont", header: rayguiHeader.}
##  Set gui custom font (global state)

proc guiGetFont*(): Font {.cdecl, importc: "GuiGetFont", header: rayguiHeader.}
##  Get gui custom font (global state)
##  Style set/get functions

proc guiSetStyle*(control: cint; property: cint; value: cint) {.cdecl,
    importc: "GuiSetStyle", header: rayguiHeader.}
##  Set one style property

proc guiGetStyle*(control: cint; property: cint): cint {.cdecl, importc: "GuiGetStyle",
    header: rayguiHeader.}
##  Get one style property
##  Styles loading functions

proc guiLoadStyle*(fileName: cstring) {.cdecl, importc: "GuiLoadStyle",
                                     header: rayguiHeader.}
##  Load style file over global style variable (.rgs)

proc guiLoadStyleDefault*() {.cdecl, importc: "GuiLoadStyleDefault",
                            header: rayguiHeader.}
##  Load style default over global style
##  Tooltips management functions

proc guiEnableTooltip*() {.cdecl, importc: "GuiEnableTooltip", header: rayguiHeader.}
##  Enable gui tooltips (global state)

proc guiDisableTooltip*() {.cdecl, importc: "GuiDisableTooltip", header: rayguiHeader.}
##  Disable gui tooltips (global state)

proc guiSetTooltip*(tooltip: cstring) {.cdecl, importc: "GuiSetTooltip",
                                     header: rayguiHeader.}
##  Set tooltip string
##  Icons functionality

proc guiIconText*(iconId: cint; text: cstring): cstring {.cdecl,
    importc: "GuiIconText", header: rayguiHeader.}
##  Get text with icon id prepended (if supported)

when not defined(RAYGUI_NO_ICONS):
  proc guiSetIconScale*(scale: cint) {.cdecl, importc: "GuiSetIconScale",
                                    header: rayguiHeader.}
  ##  Set default icon drawing size
  proc guiGetIcons*(): ptr cuint {.cdecl, importc: "GuiGetIcons", header: rayguiHeader.}
  ##  Get raygui icons data pointer
  proc guiLoadIcons*(fileName: cstring; loadIconsName: bool): cstringArray {.cdecl,
      importc: "GuiLoadIcons", header: rayguiHeader.}
  ##  Load raygui icons file (.rgi) into internal icons data
  proc guiDrawIcon*(iconId: cint; posX: cint; posY: cint; pixelSize: cint; color: Color) {.
      cdecl, importc: "GuiDrawIcon", header: rayguiHeader.}
  ##  Draw icon using pixel size at specified position
##  Controls
## ----------------------------------------------------------------------------------------------------------
##  Container/separator controls, useful for controls organization

proc guiWindowBox*(bounds: Rectangle; title: cstring): cint {.cdecl,
    importc: "GuiWindowBox", header: rayguiHeader.}
##  Window Box control, shows a window that can be closed

proc guiGroupBox*(bounds: Rectangle; text: cstring): cint {.cdecl,
    importc: "GuiGroupBox", header: rayguiHeader.}
##  Group Box control with text name

proc guiLine*(bounds: Rectangle; text: cstring): cint {.cdecl, importc: "GuiLine",
    header: rayguiHeader.}
##  Line separator control, could contain text

proc guiPanel*(bounds: Rectangle; text: cstring): cint {.cdecl, importc: "GuiPanel",
    header: rayguiHeader.}
##  Panel control, useful to group controls

proc guiTabBar*(bounds: Rectangle; text: cstringArray; count: cint; active: ptr cint): cint {.
    cdecl, importc: "GuiTabBar", header: rayguiHeader.}
##  Tab Bar control, returns TAB to be closed or -1

proc guiScrollPanel*(bounds: Rectangle; text: cstring; content: Rectangle;
                    scroll: ptr Vector2; view: ptr Rectangle): cint {.cdecl,
    importc: "GuiScrollPanel", header: rayguiHeader.}
##  Scroll Panel control
##  Basic controls set

proc guiLabel*(bounds: Rectangle; text: cstring): cint {.cdecl, importc: "GuiLabel",
    header: rayguiHeader.}
##  Label control

proc guiButton*(bounds: Rectangle; text: cstring): cint {.cdecl, importc: "GuiButton",
    header: rayguiHeader.}
##  Button control, returns true when clicked

proc guiLabelButton*(bounds: Rectangle; text: cstring): cint {.cdecl,
    importc: "GuiLabelButton", header: rayguiHeader.}
##  Label button control, returns true when clicked

proc guiToggle*(bounds: Rectangle; text: cstring; active: ptr bool): cint {.cdecl,
    importc: "GuiToggle", header: rayguiHeader.}
##  Toggle Button control

proc guiToggleGroup*(bounds: Rectangle; text: cstring; active: ptr cint): cint {.cdecl,
    importc: "GuiToggleGroup", header: rayguiHeader.}
##  Toggle Group control

proc guiToggleSlider*(bounds: Rectangle; text: cstring; active: ptr cint): cint {.cdecl,
    importc: "GuiToggleSlider", header: rayguiHeader.}
##  Toggle Slider control

proc guiCheckBox*(bounds: Rectangle; text: cstring; checked: ptr bool): cint {.cdecl,
    importc: "GuiCheckBox", header: rayguiHeader.}
##  Check Box control, returns true when active

proc guiComboBox*(bounds: Rectangle; text: cstring; active: ptr cint): cint {.cdecl,
    importc: "GuiComboBox", header: rayguiHeader.}
##  Combo Box control

proc guiDropdownBox*(bounds: Rectangle; text: cstring; active: ptr cint; editMode: bool): cint {.
    cdecl, importc: "GuiDropdownBox", header: rayguiHeader.}
##  Dropdown Box control

proc guiSpinner*(bounds: Rectangle; text: cstring; value: ptr cint; minValue: cint;
                maxValue: cint; editMode: bool): cint {.cdecl, importc: "GuiSpinner",
    header: rayguiHeader.}
##  Spinner control

proc guiValueBox*(bounds: Rectangle; text: cstring; value: ptr cint; minValue: cint;
                 maxValue: cint; editMode: bool): cint {.cdecl,
    importc: "GuiValueBox", header: rayguiHeader.}
##  Value Box control, updates input text with numbers

proc guiValueBoxFloat*(bounds: Rectangle; text: cstring; textValue: cstring;
                      value: ptr cfloat; editMode: bool): cint {.cdecl,
    importc: "GuiValueBoxFloat", header: rayguiHeader.}
##  Value box control for float values

proc guiTextBox*(bounds: Rectangle; text: cstring; textSize: cint; editMode: bool): cint {.
    cdecl, importc: "GuiTextBox", header: rayguiHeader.}
##  Text Box control, updates input text

proc guiSlider*(bounds: Rectangle; textLeft: cstring; textRight: cstring;
               value: ptr cfloat; minValue: cfloat; maxValue: cfloat): cint {.cdecl,
    importc: "GuiSlider", header: rayguiHeader.}
##  Slider control

proc guiSliderBar*(bounds: Rectangle; textLeft: cstring; textRight: cstring;
                  value: ptr cfloat; minValue: cfloat; maxValue: cfloat): cint {.cdecl,
    importc: "GuiSliderBar", header: rayguiHeader.}
##  Slider Bar control

proc guiProgressBar*(bounds: Rectangle; textLeft: cstring; textRight: cstring;
                    value: ptr cfloat; minValue: cfloat; maxValue: cfloat): cint {.
    cdecl, importc: "GuiProgressBar", header: rayguiHeader.}
##  Progress Bar control

proc guiStatusBar*(bounds: Rectangle; text: cstring): cint {.cdecl,
    importc: "GuiStatusBar", header: rayguiHeader.}
##  Status Bar control, shows info text

proc guiDummyRec*(bounds: Rectangle; text: cstring): cint {.cdecl,
    importc: "GuiDummyRec", header: rayguiHeader.}
##  Dummy control for placeholders

proc guiGrid*(bounds: Rectangle; text: cstring; spacing: cfloat; subdivs: cint;
             mouseCell: ptr Vector2): cint {.cdecl, importc: "GuiGrid",
    header: rayguiHeader.}
##  Grid control
##  Advance controls set

proc guiListView*(bounds: Rectangle; text: cstring; scrollIndex: ptr cint;
                 active: ptr cint): cint {.cdecl, importc: "GuiListView",
                                       header: rayguiHeader.}
##  List View control

proc guiListViewEx*(bounds: Rectangle; text: cstringArray; count: cint;
                   scrollIndex: ptr cint; active: ptr cint; focus: ptr cint): cint {.
    cdecl, importc: "GuiListViewEx", header: rayguiHeader.}
##  List View with extended parameters

proc guiMessageBox*(bounds: Rectangle; title: cstring; message: cstring;
                   buttons: cstring): cint {.cdecl, importc: "GuiMessageBox",
    header: rayguiHeader.}
##  Message Box control, displays a message

proc guiTextInputBox*(bounds: Rectangle; title: cstring; message: cstring;
                     buttons: cstring; text: cstring; textMaxSize: cint;
                     secretViewActive: ptr bool): cint {.cdecl,
    importc: "GuiTextInputBox", header: rayguiHeader.}
##  Text Input Box control, ask for text, supports secret

proc guiColorPicker*(bounds: Rectangle; text: cstring; color: ptr Color): cint {.cdecl,
    importc: "GuiColorPicker", header: rayguiHeader.}
##  Color Picker control (multiple color controls)

proc guiColorPanel*(bounds: Rectangle; text: cstring; color: ptr Color): cint {.cdecl,
    importc: "GuiColorPanel", header: rayguiHeader.}
##  Color Panel control

proc guiColorBarAlpha*(bounds: Rectangle; text: cstring; alpha: ptr cfloat): cint {.
    cdecl, importc: "GuiColorBarAlpha", header: rayguiHeader.}
##  Color Bar Alpha control

proc guiColorBarHue*(bounds: Rectangle; text: cstring; value: ptr cfloat): cint {.cdecl,
    importc: "GuiColorBarHue", header: rayguiHeader.}
##  Color Bar Hue control

proc guiColorPickerHSV*(bounds: Rectangle; text: cstring; colorHsv: ptr Vector3): cint {.
    cdecl, importc: "GuiColorPickerHSV", header: rayguiHeader.}
##  Color Picker control that avoids conversion to RGB on each call (multiple color controls)

proc guiColorPanelHSV*(bounds: Rectangle; text: cstring; colorHsv: ptr Vector3): cint {.
    cdecl, importc: "GuiColorPanelHSV", header: rayguiHeader.}
##  Color Panel control that updates Hue-Saturation-Value color value, used by GuiColorPickerHSV()
## ----------------------------------------------------------------------------------------------------------

when not defined(RAYGUI_NO_ICONS):
  when not defined(RAYGUI_CUSTOM_ICONS):
    ## ----------------------------------------------------------------------------------
    ##  Icons enumeration
    ## ----------------------------------------------------------------------------------
    type
      GuiIconName* {.size: sizeof(cint).} = enum
        ICON_NONE = 0, ICON_FOLDER_FILE_OPEN = 1, ICON_FILE_SAVE_CLASSIC = 2,
        ICON_FOLDER_OPEN = 3, ICON_FOLDER_SAVE = 4, ICON_FILE_OPEN = 5,
        ICON_FILE_SAVE = 6, ICON_FILE_EXPORT = 7, ICON_FILE_ADD = 8,
        ICON_FILE_DELETE = 9, ICON_FILETYPE_TEXT = 10, ICON_FILETYPE_AUDIO = 11,
        ICON_FILETYPE_IMAGE = 12, ICON_FILETYPE_PLAY = 13, ICON_FILETYPE_VIDEO = 14,
        ICON_FILETYPE_INFO = 15, ICON_FILE_COPY = 16, ICON_FILE_CUT = 17,
        ICON_FILE_PASTE = 18, ICON_CURSOR_HAND = 19, ICON_CURSOR_POINTER = 20,
        ICON_CURSOR_CLASSIC = 21, ICON_PENCIL = 22, ICON_PENCIL_BIG = 23,
        ICON_BRUSH_CLASSIC = 24, ICON_BRUSH_PAINTER = 25, ICON_WATER_DROP = 26,
        ICON_COLOR_PICKER = 27, ICON_RUBBER = 28, ICON_COLOR_BUCKET = 29,
        ICON_TEXT_T = 30, ICON_TEXT_A = 31, ICON_SCALE = 32, ICON_RESIZE = 33,
        ICON_FILTER_POINT = 34, ICON_FILTER_BILINEAR = 35, ICON_CROP = 36,
        ICON_CROP_ALPHA = 37, ICON_SQUARE_TOGGLE = 38, ICON_SYMMETRY = 39,
        ICON_SYMMETRY_HORIZONTAL = 40, ICON_SYMMETRY_VERTICAL = 41, ICON_LENS = 42,
        ICON_LENS_BIG = 43, ICON_EYE_ON = 44, ICON_EYE_OFF = 45, ICON_FILTER_TOP = 46,
        ICON_FILTER = 47, ICON_TARGET_POINT = 48, ICON_TARGET_SMALL = 49,
        ICON_TARGET_BIG = 50, ICON_TARGET_MOVE = 51, ICON_CURSOR_MOVE = 52,
        ICON_CURSOR_SCALE = 53, ICON_CURSOR_SCALE_RIGHT = 54,
        ICON_CURSOR_SCALE_LEFT = 55, ICON_UNDO = 56, ICON_REDO = 57, ICON_REREDO = 58,
        ICON_MUTATE = 59, ICON_ROTATE = 60, ICON_REPEAT = 61, ICON_SHUFFLE = 62,
        ICON_EMPTYBOX = 63, ICON_TARGET = 64, ICON_TARGET_SMALL_FILL = 65,
        ICON_TARGET_BIG_FILL = 66, ICON_TARGET_MOVE_FILL = 67,
        ICON_CURSOR_MOVE_FILL = 68, ICON_CURSOR_SCALE_FILL = 69,
        ICON_CURSOR_SCALE_RIGHT_FILL = 70, ICON_CURSOR_SCALE_LEFT_FILL = 71,
        ICON_UNDO_FILL = 72, ICON_REDO_FILL = 73, ICON_REREDO_FILL = 74,
        ICON_MUTATE_FILL = 75, ICON_ROTATE_FILL = 76, ICON_REPEAT_FILL = 77,
        ICON_SHUFFLE_FILL = 78, ICON_EMPTYBOX_SMALL = 79, ICON_BOX = 80,
        ICON_BOX_TOP = 81, ICON_BOX_TOP_RIGHT = 82, ICON_BOX_RIGHT = 83,
        ICON_BOX_BOTTOM_RIGHT = 84, ICON_BOX_BOTTOM = 85, ICON_BOX_BOTTOM_LEFT = 86,
        ICON_BOX_LEFT = 87, ICON_BOX_TOP_LEFT = 88, ICON_BOX_CENTER = 89,
        ICON_BOX_CIRCLE_MASK = 90, ICON_POT = 91, ICON_ALPHA_MULTIPLY = 92,
        ICON_ALPHA_CLEAR = 93, ICON_DITHERING = 94, ICON_MIPMAPS = 95,
        ICON_BOX_GRID = 96, ICON_GRID = 97, ICON_BOX_CORNERS_SMALL = 98,
        ICON_BOX_CORNERS_BIG = 99, ICON_FOUR_BOXES = 100, ICON_GRID_FILL = 101,
        ICON_BOX_MULTISIZE = 102, ICON_ZOOM_SMALL = 103, ICON_ZOOM_MEDIUM = 104,
        ICON_ZOOM_BIG = 105, ICON_ZOOM_ALL = 106, ICON_ZOOM_CENTER = 107,
        ICON_BOX_DOTS_SMALL = 108, ICON_BOX_DOTS_BIG = 109, ICON_BOX_CONCENTRIC = 110,
        ICON_BOX_GRID_BIG = 111, ICON_OK_TICK = 112, ICON_CROSS = 113,
        ICON_ARROW_LEFT = 114, ICON_ARROW_RIGHT = 115, ICON_ARROW_DOWN = 116,
        ICON_ARROW_UP = 117, ICON_ARROW_LEFT_FILL = 118, ICON_ARROW_RIGHT_FILL = 119,
        ICON_ARROW_DOWN_FILL = 120, ICON_ARROW_UP_FILL = 121, ICON_AUDIO = 122,
        ICON_FX = 123, ICON_WAVE = 124, ICON_WAVE_SINUS = 125, ICON_WAVE_SQUARE = 126,
        ICON_WAVE_TRIANGULAR = 127, ICON_CROSS_SMALL = 128,
        ICON_PLAYER_PREVIOUS = 129, ICON_PLAYER_PLAY_BACK = 130,
        ICON_PLAYER_PLAY = 131, ICON_PLAYER_PAUSE = 132, ICON_PLAYER_STOP = 133,
        ICON_PLAYER_NEXT = 134, ICON_PLAYER_RECORD = 135, ICON_MAGNET = 136,
        ICON_LOCK_CLOSE = 137, ICON_LOCK_OPEN = 138, ICON_CLOCK = 139, ICON_TOOLS = 140,
        ICON_GEAR = 141, ICON_GEAR_BIG = 142, ICON_BIN = 143, ICON_HAND_POINTER = 144,
        ICON_LASER = 145, ICON_COIN = 146, ICON_EXPLOSION = 147, ICON_1UP = 148,
        ICON_PLAYER = 149, ICON_PLAYER_JUMP = 150, ICON_KEY = 151, ICON_DEMON = 152,
        ICON_TEXT_POPUP = 153, ICON_GEAR_EX = 154, ICON_CRACK = 155,
        ICON_CRACK_POINTS = 156, ICON_STAR = 157, ICON_DOOR = 158, ICON_EXIT = 159,
        ICON_MODE_2D = 160, ICON_MODE_3D = 161, ICON_CUBE = 162,
        ICON_CUBE_FACE_TOP = 163, ICON_CUBE_FACE_LEFT = 164,
        ICON_CUBE_FACE_FRONT = 165, ICON_CUBE_FACE_BOTTOM = 166,
        ICON_CUBE_FACE_RIGHT = 167, ICON_CUBE_FACE_BACK = 168, ICON_CAMERA = 169,
        ICON_SPECIAL = 170, ICON_LINK_NET = 171, ICON_LINK_BOXES = 172,
        ICON_LINK_MULTI = 173, ICON_LINK = 174, ICON_LINK_BROKE = 175,
        ICON_TEXT_NOTES = 176, ICON_NOTEBOOK = 177, ICON_SUITCASE = 178,
        ICON_SUITCASE_ZIP = 179, ICON_MAILBOX = 180, ICON_MONITOR = 181,
        ICON_PRINTER = 182, ICON_PHOTO_CAMERA = 183, ICON_PHOTO_CAMERA_FLASH = 184,
        ICON_HOUSE = 185, ICON_HEART = 186, ICON_CORNER = 187, ICON_VERTICAL_BARS = 188,
        ICON_VERTICAL_BARS_FILL = 189, ICON_LIFE_BARS = 190, ICON_INFO = 191,
        ICON_CROSSLINE = 192, ICON_HELP = 193, ICON_FILETYPE_ALPHA = 194,
        ICON_FILETYPE_HOME = 195, ICON_LAYERS_VISIBLE = 196, ICON_LAYERS = 197,
        ICON_WINDOW = 198, ICON_HIDPI = 199, ICON_FILETYPE_BINARY = 200, ICON_HEX = 201,
        ICON_SHIELD = 202, ICON_FILE_NEW = 203, ICON_FOLDER_ADD = 204, ICON_ALARM = 205,
        ICON_CPU = 206, ICON_ROM = 207, ICON_STEP_OVER = 208, ICON_STEP_INTO = 209,
        ICON_STEP_OUT = 210, ICON_RESTART = 211, ICON_BREAKPOINT_ON = 212,
        ICON_BREAKPOINT_OFF = 213, ICON_BURGER_MENU = 214, ICON_CASE_SENSITIVE = 215,
        ICON_REG_EXP = 216, ICON_FOLDER = 217, ICON_FILE = 218, ICON_SAND_TIMER = 219,
        ICON_WARNING = 220, ICON_HELP_BOX = 221, ICON_INFO_BOX = 222,
        ICON_PRIORITY = 223, ICON_LAYERS_ISO = 224, ICON_LAYERS2 = 225,
        ICON_MLAYERS = 226, ICON_MAPS = 227, ICON_HOT = 228, ICON_LABEL = 229,
        ICON_NAME_ID = 230, ICON_SLICING = 231, ICON_MANUAL_CONTROL = 232,
        ICON_COLLISION = 233, ICON_234 = 234, ICON_235 = 235, ICON_236 = 236,
        ICON_237 = 237, ICON_238 = 238, ICON_239 = 239, ICON_240 = 240, ICON_241 = 241,
        ICON_242 = 242, ICON_243 = 243, ICON_244 = 244, ICON_245 = 245, ICON_246 = 246,
        ICON_247 = 247, ICON_248 = 248, ICON_249 = 249, ICON_250 = 250, ICON_251 = 251,
        ICON_252 = 252, ICON_253 = 253, ICON_254 = 254, ICON_255 = 255
