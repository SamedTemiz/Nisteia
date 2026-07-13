# Runs tool/build_apk.bat outside the calling process's job object.
#
# Why this exists: in this dev sandbox, both direct `flutter build apk` and
# Windows Task Scheduler (`schtasks /run`) fail to produce a real build --
# direct execution hits "Unable to establish loopback connection" in Gradle's
# daemon IPC, and schtasks silently no-ops (reports LastTaskResult=0 with no
# process ever spawned) without any visible error. WMI process creation
# (Win32_Process.Create) is the one method that reliably escapes both: it
# spawns via the WMI provider host, not as a child of the calling shell.
#
# Usage:
#   powershell -File tool\run_detached_build.ps1
# Then poll apk_build.log for the literal line "DONE_MARKER" (written last,
# after `flutter build apk` returns) rather than trusting any earlier log
# content or process/task "success" status -- both have been seen to lie.

$log = "C:\Users\helmsdeep\MyProjects\nisteia\apk_build.log"
Remove-Item $log -ErrorAction SilentlyContinue

$cmd = "cmd.exe /c C:\Users\helmsdeep\MyProjects\nisteia\tool\build_apk.bat"
$result = Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments @{ CommandLine = $cmd }

if ($result.ReturnValue -ne 0) {
    Write-Error "Win32_Process.Create failed, ReturnValue=$($result.ReturnValue)"
    exit 1
}
Write-Output "Spawned PID $($result.ProcessId). Poll $log for the line 'DONE_MARKER'."
