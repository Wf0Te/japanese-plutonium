@echo off
cscript launcher.vbs
echo waiting for plutonium-bootstrapper-win32.exe
:loop
tasklist /fi "imagename eq plutonium-bootstrapper-win32.exe" |find ":" > nul
if errorlevel 1 goto found
goto loop

:found
echo copying files.
xcopy /y mainlobby.lua C:\Users\devpi\AppData\Local\Plutonium\storage\t6\ui\t6\
xcopy /y partylobby.lua C:\Users\devpi\AppData\Local\Plutonium\storage\t6\ui\t6\
xcopy /y optionssettings.lua C:\Users\devpi\AppData\Local\Plutonium\storage\t6\ui\t6\menus\
xcopy /y optionscontrols.lua C:\Users\devpi\AppData\Local\Plutonium\storage\t6\ui\t6\menus\
xcopy /y mainmenu.lua C:\Users\devpi\AppData\Local\Plutonium\storage\t6\ui_mp\t6\
xcopy /y class.lua C:\Users\devpi\AppData\Local\Plutonium\storage\t6\ui_mp\t6\hud\

