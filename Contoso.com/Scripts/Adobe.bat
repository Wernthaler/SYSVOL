@Echo off

sc query | find "AdobeARMservice" > NUL
if ERRORLEVEL 1 (
	echo Dienst AdobeARMservice nicht vorhanden.
) else (
	echo Dienst AdobeARMservice vorhanden, wird gestoppt und deaktiviert...
	sc stop AdobeARMservice > NUL
	sc config AdobeARMservice start= disabled > NUL
)


sc query | find "AdobeFlashPlayerUpdateSvc" > NUL
if ERRORLEVEL 1 (
	echo Dienst AdobeFlashPlayerUpdateSvc nicht vorhanden.
) else (
	echo Dienst AdobeFlashPlayerUpdateSvc vorhanden, wird gestoppt und deaktiviert...
	sc stop AdobeFlashPlayerUpdateSvc > NUL
	sc config AdobeFlashPlayerUpdateSvc start= disabled > NUL
)


schtasks /Query /TN "Adobe Acrobat Update Task" > NUL
if ERRORLEVEL 1 (
	echo Task Adobe Acrobat Update Task nicht vorhanden.
) else (
	echo Task Adobe Acrobat Update Task vorhanden, wird deaktiviert...
	schtasks /Change /TN "Adobe Acrobat Update Task" /Disable > NUL
)


schtasks /Query /TN "Adobe Flash Player Updater" > NUL
if ERRORLEVEL 1 (
	echo Task Adobe Flash Player Updater nicht vorhanden.
) else (
	echo Task Adobe Flash Player Updater vorhanden, wird deaktiviert...
	schtasks /Change /TN "Adobe Flash Player Updater" /Disable > NUL
)
