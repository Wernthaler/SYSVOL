@Echo off

sc query | find "gusvc" > NUL
if ERRORLEVEL 1 (
	echo Dienst GUSVC nicht vorhanden.
) else (
	echo Dienst GUSVC vorhanden, wird gestoppt und geloescht...
	sc stop gusvc > NUL
	sc delete gusvc > NUL
)


sc query | find "gupdate" > NUL
if ERRORLEVEL 1 (
	echo Dienst GUPDATE nicht vorhanden.
) else (
	echo Dienst GUPDATE vorhanden, wird gestoppt und geloescht...
	sc stop gupdate > NUL
	sc delete gupdate > NUL
)


sc query | find "gupdatem" > NUL
if ERRORLEVEL 1 (
	echo Dienst GUPDATEM nicht vorhanden.
) else (
	echo Dienst GUPDATEM vorhanden, wird gestoppt und geloescht...
	sc stop gupdatem > NUL
	sc delete gupdatem > NUL
)
