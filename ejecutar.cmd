@echo off
rem Compila y ejecuta el modulo de vacantes. Requiere MySQL encendido en XAMPP.
rem Uso:  ejecutar.cmd          -> menu interactivo
rem       ejecutar.cmd --demo   -> crea, consulta, actualiza y elimina una vacante de prueba
cd /d "%~dp0"
call "%~dp0mvnw.cmd" -q -o package -DskipTests || exit /b 1
java -Dstdout.encoding=UTF-8 -jar target\skillmatch-vacantes-1.0.0.jar %*
