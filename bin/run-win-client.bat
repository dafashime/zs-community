@echo off
setlocal
REM BaiZhuClient.exe launcher - Quick-Cocos2dx-Community 3.6.1 Win32
REM layout: bin\run-win-client.bat + client\lib\ = Quick project root
set ROOT=%~dp0..\client\lib
set EXE=%ROOT%\frameworks\runtime-src\proj.win32\Debug.win32\BaiZhuClient.exe
set BINDIR=%ROOT%\frameworks\runtime-src\proj.win32\Debug.win32
set WORKDIR=%ROOT%\frameworks\runtime-src\proj.win32

if not exist "%ROOT%" goto err_root
if not exist "%EXE%" goto err_exe

REM prepend binary dir so DLLs resolve
set PATH=%BINDIR%;%SystemRoot%\SysWOW64;%SystemRoot%\System32;%PATH%

pushd "%WORKDIR%"
"%EXE%"
set ERR=%ERRORLEVEL%
popd
exit /b %ERR%

:err_root
echo ERROR: Quick project not found at %ROOT%
echo Please unpack BaiZhuClient.zip into client\lib first.
exit /b 1

:err_exe
echo ERROR: BaiZhuClient.exe not found at %EXE%
echo Build it first - see client compile guide.
exit /b 1
