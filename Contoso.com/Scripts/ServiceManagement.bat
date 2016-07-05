@Echo off

sc query | find "%1" > NUL
if ERRORLEVEL 1 (
	echo Dienst %1 nicht vorhanden.
) else (
	echo Dienst %1 vorhanden, wird gestoppt und geloescht...
	sc stop %1 > NUL
	sc delete %1 > NUL
)

