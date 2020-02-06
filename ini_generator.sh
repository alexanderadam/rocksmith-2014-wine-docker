#!/bin/bash

# https://www.playonlinux.com/en/topic-14040-Script_Rocksmith_2014_Steam.html

read width height <<<$(xrandr | fgrep '*' | egrep -o '[0-9]+x[0-9]+' | egrep -o '[0-9]+')

if [ -f Rocksmith.ini ]; then
    #if Rocksmith.ini exists, fix it
    # set Win32UltraLowLatencyMode=0 to make sure cable is detected
    sed -i 's/^\(Win32UltraLowLatencyMode=\).*/\10/' Rocksmith.ini
    # set ExclusiveMode=0 to make sure cable is detected
    sed -i 's/^\(ExclusiveMode=\).*/\10/' Rocksmith.ini
    # set display resolution
    sed -i "s/^\(ScreenWidth=\).*/\1$width/" Rocksmith.ini
    sed -i "s/^\(ScreenHeight=\).*/\1$height/" Rocksmith.ini
else
    # if Rocksmith.ini does not exist, create new one
    echo "[Audio]" > Rocksmith.ini
    echo "EnableMicrophone=1" >> Rocksmith.ini
    echo "ExclusiveMode=0" >> Rocksmith.ini
    echo "LatencyBuffer=4" >> Rocksmith.ini
    echo "ForceDefaultPlaybackDevice=" >> Rocksmith.ini
    echo "ForceWDM=0" >> Rocksmith.ini
    echo "ForceDirectXSink=0" >> Rocksmith.ini
    echo "Win32UltraLowLatencyMode=0" >> Rocksmith.ini
    echo "DumpAudioLog=0" >> Rocksmith.ini
    echo "MaxOutputBufferSize=0" >> Rocksmith.ini
    echo "[Renderer.Win32]" >> Rocksmith.ini
    echo "ShowGamepadUI=0" >> Rocksmith.ini
    echo "ScreenWidth=$width" >> Rocksmith.ini
    echo "ScreenHeight=$height" >> Rocksmith.ini
    echo "Fullscreen=2" >> Rocksmith.ini
    echo "VisualQuality=1" >> Rocksmith.ini
    echo "RenderingWidth=0" >> Rocksmith.ini
    echo "RenderingHeight=0" >> Rocksmith.ini
    echo "EnablePostEffects=1" >> Rocksmith.ini
    echo "EnableShadows=1" >> Rocksmith.ini
    echo "EnableHighResScope=1" >> Rocksmith.ini
    echo "EnableDepthOfField=1" >> Rocksmith.ini
    echo "EnablePerPixelLighting=1" >> Rocksmith.ini
    echo "MsaaSamples=4" >> Rocksmith.ini
    echo "DisableBrowser=0" >> Rocksmith.ini
    echo "[Net]" >> Rocksmith.ini
    echo "UseProxy=1" >> Rocksmith.ini
fi
