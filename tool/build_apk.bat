@echo off
rem Detached APK build. Launch via tool\run_detached_build.ps1 (WMI process
rem creation) -- NOT Task Scheduler, which has been observed to silently
rem no-op in this dev sandbox (reports success, spawns nothing). See that
rem script's header comment for the full story.
rem Arguments are passed straight through to `flutter build`, so this drives
rem both artefacts: "apk --debug" for sideloading onto a test device, and
rem "appbundle --release" for the Play Store upload. Defaults to a debug APK.
rem Release is the one that exercises R8, which is where this project has
rem actually been bitten before.
cd /d C:\Users\helmsdeep\MyProjects\nisteia
set ARGS=%*
if "%ARGS%"=="" set ARGS=apk --debug
set LOG=C:\Users\helmsdeep\MyProjects\nisteia\apk_build.log
call C:\Users\helmsdeep\dev\flutter\bin\flutter.bat pub get > %LOG% 2>&1
call C:\Users\helmsdeep\dev\flutter\bin\flutter.bat gen-l10n >> %LOG% 2>&1
call C:\Users\helmsdeep\dev\flutter\bin\flutter.bat build %ARGS% >> %LOG% 2>&1
echo DONE_MARKER >> %LOG%
