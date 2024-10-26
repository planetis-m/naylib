Raylib Functions to Nim Alternatives
************************************

Some raylib functions are not directly wrapped in Naylib because they closely reflect the C API. For these cases, we provide Nim alternatives. Bellow is a comprehensive list of equivalent Nim functions.

Files management functions
~~~~~~~~~~~~~~~~~~~~~~~~~~

========================== ================================ =================
raylib function            Native alternative               Notes
========================== ================================ =================
LoadFileData               readFile                         Cast to seq[byte]
SaveFileData               writeFile                        seq[byte] overload
LoadFileText               readFile
SaveFileText               writeFile                        string overload
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
MakeDirectory              os.createDir
GetFileModTime             os.getLastModificationTime
IsPathFile                 os.getFileInfo
IsFileNameValid            os.isValidFilename
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
TextToFloat        strutils.parseFloat
TextToSnake        None                                       Write a function
TextToCamel        None                                       Write a function
================== ========================================== ================

Text codepoints management functions (unicode characters)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

======================= ===================== ==============================
raylib function         Native alternative    Notes
======================= ===================== ==============================
LoadCodepoints          toRunes
GetCodepoint            runeAt, size          Returns 0xFFFD on error
GetCodepointCount       runeLen
GetCodepointPrevious    None                  toRunes and iterate in reverse
GetCodepointNext        None                  Use runes iterator
CodepointToUTF8         toUTF8
LoadUTF8                toUTF8
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
ComputeCRC32       crunchy.crc32         External package
ComputeMD5         checksums.md5         External package
ComputeSHA1        checksums.sha1        External package
================== ===================== ================

Misc
~~~~

================== ============================== =========================
raylib function    Native alternative             Notes
================== ============================== =========================
ColorIsEqual       `==`
GetRandomValue     random.rand
SetRandomSeed      random.randomize
LoadRandomSequence None                           Easy to translate
OpenURL            browsers.openDefaultBrowser
PI (C macros)      math.PI
DEG2RAD            math.degToRad                  A function not a constant
RAD2DEG            math.radToDeg
================== ============================== =========================
