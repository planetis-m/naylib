Files management functions
~~~~~~~~~~~~~~~~~~~~~~~~~~

========================== ================================ =================
raylib function            Native alternative               Notes
========================== ================================ =================
LoadFileData               readFile                         Cast to seq[byte]
UnloadFileData             None                             Not needed
SaveFileData               writeFile
LoadFileText               readFile
UnloadFileText             None                             Not needed
SaveFileText               writeFile
FileExists                 os.fileExists
DirectoryExists            os.dirExists
IsFileExtension            strutils.endsWith
GetFileExtension           os.splitFile, os.searchExtPos
GetFileName                os.extractFilename
GetFileLength              os.getFileSize
GetFileNameWithoutExt      os.splitFile
GetDirectoryPath           os.splitFile
GetPrevDirectoryPath       os.parentDir, os.parentDirs
GetWorkingDirectory        os.getCurrentDir
GetApplicationDirectory    os.getAppDir
GetDirectoryFiles          os.walkDir, os.walkFiles
ChangeDirectory            os.setCurrentDir
GetFileModTime             os.getLastModificationTime
IsPathFile                 os.getFileInfo
========================== ================================ =================

Text strings management functions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

================== ========================================== ================
raylib function    Native alternative                         Notes
================== ========================================== ================
TextCopy           assignment
TextIsEqual        `==`
TextLength         len
TextFormat         strutils.format, strformat.`&`
TextSubtext        substr
TextReplace        strutils.replace, strutils.multiReplace
TextInsert         insert
TextJoin           strutils.join
TextSplit          strutils.split, unicode.split
TextAppend         add
TextFindIndex      strutils.find
TextToUpper        strutils.toUpperAscii, unicode.toUpper
TextToLower        strutils.toLowerAscii, unicode.toLower
TextToPascal       None                                       Write a function
TextToInteger      strutils.parseInt
================== ========================================== ================

Text codepoints management functions (unicode characters)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

======================= ===================== ==============================
raylib function         Native alternative    Notes
======================= ===================== ==============================
LoadCodepoints          toRunes
UnloadCodepoints        None                  Not needed
GetCodepoint            runeAt, size          Returns 0xFFFD on error
GetCodepointCount       runeLen
GetCodepointPrevious    None                  toRunes and iterate in reverse
GetCodepointNext        None                  Use runes iterator
CodepointToUTF8         toUTF8
LoadUTF8                toUTF8
UnloadUTF8              None                  Not needed
======================= ===================== ==============================

See also procs like ``graphemeLen``, ``runeSubStr``, and other functions provided by the standard
library's ``std/unicode`` module that can be used for working with Unicode strings in Nim.

Compression/Encoding functionality
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

================== ===================== ================
raylib function    Native alternative    Notes
================== ===================== ================
CompressData       zippy.compress        External package
DecompressData     zippy.decompress
EncodeDataBase64   base64.encode
DecodeDataBase64   base64.decode
================== ===================== ================

Misc
~~~~

================== ============================== =========================
raylib function    Native alternative             Notes
================== ============================== =========================
GetRandomValue     random.rand
SetRandomSeed      random.randomize
OpenURL            browsers.openDefaultBrowser
PI (C macros)      math.PI
DEG2RAD            math.degToRad                  A function not a constant
RAD2DEG            math.radToDeg
================== ============================== =========================
