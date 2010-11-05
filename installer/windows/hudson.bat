@echo off
:: This file is to be run on the Windows Hudson build machine only.
:: To build the Windows installer locally, run the buildexe.bat file.

:: Requires two paramters
:: hudson.bat %repo_path% %revision%
:: See Usage at bottom
if "x%2"=="x" goto Usage
if not "x%3"=="x" goto Usage
set repo_path=%1
set revision=%2

set HTDOCS=C:\Program Files\Apache Software Foundation\Apache2.2\htdocs
set PATH=%PATH%;C:\Program Files\wget\bin;C:\Program Files\NSIS;C:\Program Files\Subversion\bin

:: %repo_winpath% (redundantly) defined here
:: Can probably remove this
for /f "tokens=1,2 delims=\/" %%a in ("%REPO_PATH%") do (
  if "x%%b"=="x" (
    set repo_winpath=%%a
  ) else (
    set repo_winpath=%%a\%%b
  )
)

:: Build process
echo Calling build process...
echo.
cd windows
call buildexe.bat %repo_path% %revision%


:: Name the file
:: Note: %id% is defined in buildexe.bat
set outfile=OpenGeoSuite-%id%-b%BUILD_NUMBER%.exe
ren OpenGeo*.exe %outfile%

:: Create outpath
set outpath=%HTDOCS%\winbuilds\%repo_winpath%
if not exist "%outpath%" mkdir "%outpath%"

:: Move files into place
echo Moving the EXE into its proper place...
echo.
move /y %outfile% "%outpath%"

:: Copy to OpenGeoSuite-latest.exe if building from trunk
if %repo_winpath%==trunk (
  echo Copying to OpenGeoSuite-latest.exe
  echo.
  copy /y "%outpath%\%outfile%" "%outpath%\OpenGeoSuite-latest.exe"
)

:: Cleanup
echo Deleting old files...
echo.
:: Keep only the most recent 7 builds (8 includes "latest")
for /f "skip=8" %%a in ('dir /b /o-d "%outpath%"') do del "%outpath%\%%a"

:: Final output
echo The Hudson build number is b%BUILD_NUMBER%
echo The files were built from %repo_path%
echo The revision is %rev% (%revision%)
echo Output file is called %outfile%
echo Output file saved to %outpath%
echo.
echo Done.
echo.

goto End


:Usage
echo.
echo This program requires two parameters:
echo.
echo Usage:
echo   hudson.bat repo_path revision
echo.


:End
