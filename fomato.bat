@echo off
echo Formateando archivos seleccionados...

:: Pasa la lista exacta de archivos o patrones a formatear
mix format  *.ex *.exs

if errorlevel 1 (
    echo.
    echo Error durante la ejecucion de mix format.
    pause
    exit /b 1
)

echo Format completado con éxito