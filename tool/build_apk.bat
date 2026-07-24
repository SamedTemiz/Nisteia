@echo off
rem Detached APK build. Launch via tool\run_detached_build.ps1 (WMI process
rem creation) -- NOT Task Scheduler, which has been observed to silently
rem no-op in this dev sandbox (reports success, spawns nothing). See that
rem script's header comment for the full story.
rem First argument selects the build mode (--debug / --release); defaults to
rem --debug. Release is the one that exercises R8, which is where this project
rem has actually been bitten before.
cd /d C:\Users\helmsdeep\MyProjects\nisteia
set MODE=%1
if "%MODE%"=="" set MODE=--debug
set LOG=C:\Users\helmsdeep\MyProjects\nisteia\apk_build.log
call C:\Users\helmsdeep\dev\flutter\bin\flutter.bat pub get > %LOG% 2>&1
call C:\Users\helmsdeep\dev\flutter\bin\flutter.bat gen-l10n >> %LOG% 2>&1
call C:\Users\helmsdeep\dev\flutter\bin\flutter.bat build apk %MODE% >> %LOG% 2>&1
echo DONE_MARKER >> %LOG%
