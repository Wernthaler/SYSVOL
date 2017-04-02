@Echo off

REM starte Sync mit Master-Verzeichnis
robocopy \\Server2012R2\Holz-Manager\HMTablet C:\HMTablet /MIR /R:1 /W:1 /XD FirstChange

:End
