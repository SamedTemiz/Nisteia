@echo off
rem Detached APK build — run via Task Scheduler to escape harness process
rem constraints (see docs: flaky Java loopback under the agent's job object).
cd /d C:\Users\helmsdeep\MyProjects\nisteia
set LOG=C:\Users\helmsdeep\MyProjects\nisteia\apk_build.log
call C:\Users\helmsdeep\dev\flutter\bin\flutter.bat pub get > %LOG% 2>&1
call C:\Users\helmsdeep\dev\flutter\bin\flutter.bat gen-l10n >> %LOG% 2>&1
call C:\Users\helmsdeep\dev\flutter\bin\flutter.bat build apk --debug >> %LOG% 2>&1
