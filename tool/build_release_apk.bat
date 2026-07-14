@echo off
rem Release APK (not appbundle) — for direct adb-install device verification.
cd /d C:\Users\helmsdeep\MyProjects\nisteia
set LOG=C:\Users\helmsdeep\MyProjects\nisteia\apk_build.log
call C:\Users\helmsdeep\dev\flutter\bin\flutter.bat build apk --release > %LOG% 2>&1
echo DONE_MARKER >> %LOG%
