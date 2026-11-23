@echo off
rem Compila la aplicacion web y la despliega en el Tomcat de XAMPP.
rem Despues, con Tomcat encendido, abrir http://localhost:8080/skillmatch-vacantes/
cd /d "%~dp0"
set TOMCAT=C:\xampp\tomcat
call "%~dp0mvnw.cmd" -q -o package -DskipTests || exit /b 1
rem Archivo .war (para entregar o desplegar en otro servidor)
set JAR=jar
if defined JAVA_HOME set JAR="%JAVA_HOME%\bin\jar.exe"
%JAR% --create --file target\skillmatch-vacantes.war -C target\webapp . || exit /b 1
rem Copia la aplicacion a Tomcat (carpeta expandida: Tomcat la recarga sola)
robocopy target\webapp "%TOMCAT%\webapps\skillmatch-vacantes" /MIR /NFL /NDL /NJH /NJS /NP >nul
if %ERRORLEVEL% GEQ 8 exit /b 1
echo Desplegado en %TOMCAT%\webapps\skillmatch-vacantes
echo Abre http://localhost:8080/skillmatch-vacantes/
exit /b 0
