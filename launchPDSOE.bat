@echo off

REM Set this value to false to disable overriding high DPI scaling
set enableHighDPI="true"

set DLC=C:\progress\OE128_64
set foundServer=true
set foundEdge=true

REM Checking if the current machine is windows server machine
systeminfo | findstr /B /C:"OS Name" | find /c "Server" >NUL
if errorlevel 1 set foundServer=false

REM echo "foundServer is %foundServer%"

REM Checking if edge browser exists in the machine, if it exists and is of server keeping flag foundEdge as false
IF EXIST "%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe" (
	echo "found edge"
	if %foundServer% == true set foundEdge=false
) ELSE (
	echo "Edge not found"
	set foundEdge=false
)

REM echo "foundEdge is %foundEdge%"

REM If edge is found in the machine and is of not server we will set default browser as edge
IF %foundEdge% == true (
   echo "Microsoft Edge browser exists.Configuring default as Microsoft Edge"
   find "-Dorg.eclipse.swt.browser.DefaultType" %DLC%/oeide/eclipse/eclipse.ini >NUL
   if errorlevel  1 ECHO -Dorg.eclipse.swt.browser.DefaultType="edge">>%DLC%/oeide/eclipse/eclipse.ini
)
if enableHighDPI=="false" goto launchPDSOE

REM Check if the windows version is 10(including any service packs). For Windows 10 the high DPI scaling will be enabled for eclipse.exe 
ver | find /i "Version 10" > nul
if ERRORLEVEL = 1 goto launchPDSOE

REM Add regsitry entry to enable high DPI settings
REG ADD "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "C:\progress\OE128_64\oeide\eclipse\eclipse.exe" /t REG_SZ /d "~ HIGHDPIAWARE" /f > nul

:launchPDSOE
call "C:\progress\OE128_64\bin\java_env.bat"
start "Progress Developer Studio for OpenEdge" "C:\progress\OE128_64\oeide\eclipse\eclipse.exe" -vm "%JAVA_HOME%\bin\javaw.exe" -data c:\projects\mcp %*

