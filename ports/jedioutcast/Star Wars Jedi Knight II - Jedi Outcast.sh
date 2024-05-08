#!/bin/bash

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
source $controlfolder/device_info.txt
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

GAMEDIR="/$directory/ports/JediOutcast"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

if [ ! -f $GAMEDIR/conf/openjo/base/openjo_sp.cfg ]; then
  if [[ -e "/dev/input/by-path/platform-odroidgo3-joypad-event-joystick" ]] || [[ "$(cat /sys/firmware/devicetree/base/model)" == "Rockchip RK3566 EVB2 LP4X V10 Board" ]] || [[ "$(cat /sys/firmware/devicetree/base/model)" == "Anbernic RG503" ]]; then
    mv -f $GAMEDIR/conf/openjo/base/openjo_sp.cfg.ogs $GAMEDIR/conf/openjo/base/openjo_sp.cfg
    rm -f $GAMEDIR/conf/openjo/base/openjo_sp.cfg.*
  else
    mv -f $GAMEDIR/conf/openjo/base/openjo_sp.cfg.rg552 $GAMEDIR/conf/openjo/base/openjo_sp.cfg
    rm -f $GAMEDIR/conf/openjo/base/openjo_sp.cfg.* 
  fi
fi

cd $GAMEDIR

$ESUDO rm -rf ~/.local/share/openjo
ln -sfv $GAMEDIR/conf/openjo/ ~/.local/share/

export DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

if [ "$LIBGL_FB" != "" ]; then
export SDL_VIDEO_GL_DRIVER="$GAMEDIR/gl4es.aarch64/libGL.so.1"
fi 

export LD_LIBRARY_PATH=$GAMEDIR/libs:$LD_LIBRARY_PATH
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

source /etc/profile

whichos=$(grep "title=" "/usr/share/plymouth/themes/text.plymouth")
if [[ $whichos == *"RetroOZ"* ]]; then
  APP_TO_KILL="."
  execute_perf=0
else
  APP_TO_KILL="openjo_sp.aarch64"
  execute_perf=1
fi

((execute_perf)) && maxperf

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

$GPTOKEYB $APP_TO_KILL -c "openjo_sp.aarch64.gptk" &
./openjo_sp.aarch64

$ESUDO kill -9 $(pidof gptokeyb)
((execute_perf)) && normperf
$ESUDO systemctl restart oga_events & 
printf "\033c" >> /dev/tty1
