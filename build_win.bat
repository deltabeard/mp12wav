@ECHO OFF
SETLOCAL

IF NOT DEFINED VSCMD_VER (
	ECHO You must run this within Visual Studio Native Tools Command Line
	EXIT /B 1
)

WHERE GNUMAKE.EXE >nul 2>nul
IF ERRORLEVEL 1 (
	ECHO GNUMAKE.EXE was not found
	REM You can compile GNU Make within Visual Studio Native Tools Command
	REM Line natively by executing build_w32.bat within the root folder of
	REM GNU Make source code.
	REM You can download GNU Make source code at
	REM   http://ftpmirror.gnu.org/make/
	EXIT /B 1
)

SET CC="cl"
SET OBJEXT="obj"
SET RM="del"
SET EXEOUT="/Fe"
SET CFLAGS="/nologo /analyze /diagnostics:caret /O1 /Zo- /MD /Gw /fp:fast /W3"
SET LDFLAGS="/link /SUBSYSTEM:CONSOLE"

REM Options specific to 32-bit platforms
if "%VSCMD_ARG_TGT_ARCH%"=="x32" (
	REM Uncomment the following to use SSE instructions (since Pentium III).
	REM set CFLAGS=%CFLAGS% /arch:SSE

	REM Uncomment the following to support ReactOS and Windows XP.
	set CFLAGS=%CFLAGS% /Fdvc141.pdb
)

set ICON_FILE=icon.ico
set RES=meta\winres.res

@ECHO ON
GNUMAKE.EXE CC=%CC% OBJEXT=%OBJEXT% RM=%RM% EXEOUT=%EXEOUT% CFLAGS=%CFLAGS% LDFLAGS=%LDFLAGS% ICON_FILE=%ICON_FILE% RES=%RES% %1
@ECHO OFF

ENDLOCAL
@ECHO ON
