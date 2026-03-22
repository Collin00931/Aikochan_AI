@echo off
setlocal

rem ROOT = folder where this .bat resides (Launcher)
set "ROOT=%~dp0"

rem Paths relative to Launcher
set "LUA_BIN=%ROOT%lua\lua54.exe"
set "ROCKS=%ROOT%Rocks"
set "CORE=%ROOT%..\core"

rem Normalize paths for Lua
set "ROCKS=%ROOT%Rocks"
set "LUA_PATH=%ROCKS%\share\lua\5.4\?.lua;%ROCKS%\share\lua\5.4\?\init.lua;%ROCKS%\share\lua\5.4\luarocks\?.lua;%CORE%\?.lua"
set "LUA_CPATH=%ROCKS%\lib\lua/5.4\?.dll"


echo Checking for luarocks.loader in: %ROCKS%\share\lua\5.4\luarocks\loader.lua
if exist "%ROCKS%\share\lua\5.4\luarocks\loader.lua" (
    echo Found luarocks.loader!
) else (
    echo luarocks.loader.lua is missing — LuaRocks runtime not included properly.
)



rem Lua module paths
set "LUA_PATH=%ROCKS%\share\lua\5.4/?.lua;%ROCKS%\share\lua/5.4/?/init.lua;%CORE%\?.lua"
set "LUA_CPATH=%ROCKS%\lib\lua/5.4/?.dll"

rem Debug info
echo Running Lua at: %LUA_BIN%
echo Using LUA_PATH: %LUA_PATH%
echo Using LUA_CPATH: %LUA_CPATH%
echo Core script: %CORE%\chatbot.lua
echo.

rem Change to core directory so relative paths work
cd /d "%CORE%"

rem Run chatbot.lua interactively
"%LUA_BIN%" "chatbot.lua"

rem Keep window open after Lua exits
echo.
echo Lua session ended. Press any key to close...
pause


