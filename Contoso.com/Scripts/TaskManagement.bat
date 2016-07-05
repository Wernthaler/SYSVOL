@Echo off

schtasks /Query /TN "%1" > NUL
if ERRORLEVEL 1 (
	echo Task %1 nicht vorhanden.
) else (
	echo Task %1 vorhanden, wird deaktiviert...
	schtasks /Change /TN "%1" /Disable > NUL
)

