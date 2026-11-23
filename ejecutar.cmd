@echo off
rem Compila y ejecuta el módulo de vacantes. Requiere MySQL encendido en XAMPP.
rem Uso:  ejecutar.cmd          -> menú interactivo
rem       ejecutar.cmd --demo   -> crea, consulta, actualiza y elimina una vacante de prueba
chcp 65001 >nul
cd /d "%~dp0"
call mvnw.cmd -q -o package -DskipTests || exit /b 1
java -Dstdout.encoding=UTF-8 -jar target\skillmatch-vacantes-1.0.0.jar %*
