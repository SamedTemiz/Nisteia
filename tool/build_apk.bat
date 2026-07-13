@echo off
rem Detached APK build. Launch via tool\run_detached_build.ps1 (WMI process
rem creation) -- NOT Task Scheduler, which has been observed to silently
rem no-op in this dev sandbox (reports success, spawns nothing). See that
rem script's header comment for the full story.
cd /d C:\Users\helmsdeep\MyProjects\nisteia
set LOG=C:\Users\helmsdeep\MyProjects\nisteia\apk_build.log
call C:\Users\helmsdeep\dev\flutter\bin\flutter.bat pub get > %LOG% 2>&1
call C:\Users\helmsdeep\dev\flutter\bin\flutter.bat gen-l10n >> %LOG% 2>&1
call C:\Users\helmsdeep\dev\flutter\bin\flutter.bat build apk --debug >> %LOG% 2>&1
echo DONE_MARKER >> %LOG%
