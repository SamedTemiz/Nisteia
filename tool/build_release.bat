@echo off
rem Release App Bundle for Play Store. Launch via run_detached_build.ps1
rem (WMI process creation) — see that script's header for why.
cd /d C:\Users\helmsdeep\MyProjects\nisteia
set LOG=C:\Users\helmsdeep\MyProjects\nisteia\apk_build.log
call C:\Users\helmsdeep\dev\flutter\bin\flutter.bat pub get > %LOG% 2>&1
call C:\Users\helmsdeep\dev\flutter\bin\flutter.bat gen-l10n >> %LOG% 2>&1
call C:\Users\helmsdeep\dev\flutter\bin\flutter.bat build appbundle --release >> %LOG% 2>&1
echo DONE_MARKER >> %LOG%
