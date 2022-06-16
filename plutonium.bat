Rem exmaple bat. lua files must be replaced after plutonium bootstrapper has initialized to bypass it's update process.
@echo off
cscript launcher.vbs
echo waiting for plutonium-bootstrapper-win32.exe
:loop
tasklist /fi "imagename eq plutonium-bootstrapper-win32.exe" |find ":" > nul
if errorlevel 1 goto found
goto loop

:found
echo copying files.
xcopy /y mainlobby.lua %APPDATA%\Local\Plutonium\storage\t6\ui\t6\
xcopy /y partylobby.lua %APPDATA%\Local\Plutonium\storage\t6\ui\t6\
xcopy /y optionssettings.lua %APPDATA%\Local\Plutonium\storage\t6\ui\t6\menus\
xcopy /y optionscontrols.lua %APPDATA%\Local\Plutonium\storage\t6\ui\t6\menus\
xcopy /y mainmenu.lua %APPDATA%\Local\Plutonium\storage\t6\ui_mp\t6\
xcopy /y class.lua %APPDATA%\Local\Plutonium\storage\t6\ui_mp\t6\hud\
