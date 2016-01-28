@echo off
REM mydate only works on UK locale. Other locale has to be modified accordingly prior to executing script
for /F "usebackq tokens=1,2,3,4 delims=/ " %%a IN (`date /t`) do set mydate=%%b.%%c.%%d
powershell -file "c:\path\script.ps1" > C:\path\script_%mydate%.txt
