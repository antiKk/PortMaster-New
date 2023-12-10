#!/bin/bash

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
if [ -z ${TASKSET+x} ]; then
  source $controlfolder/tasksetter
fi

get_controls

## TODO: Change to PortMaster/tty when Johnnyonflame merges the changes in,
CUR_TTY=/dev/tty0

PORTDIR="/$directory/ports"
GAMEDIR="$PORTDIR/zeldansq"

if [ -f "/etc/os-release" ]; then
  source "/etc/os-release"
fi 

if [ "$VERSION" == "19.10 (Eoan Ermine)" ]; then

cp /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.10.0 /$GAMEDIR/libs && mv /$GAMEDIR/libs/libSDL2-2.0.so.0.10.0 /$GAMEDIR/libs/libSDL2-2.0.so.0

fi


cd $GAMEDIR

$ESUDO chmod 666 $CUR_TTY
$ESUDO touch log.txt
$ESUDO chmod 666 log.txt
export TERM=linux
printf "\033c" > $CUR_TTY

printf "\033c" > $CUR_TTY
## RUN SCRIPT HERE
$ESUDO chmod -x ./zeldansq

echo "Starting game." > $CUR_TTY

$GPTOKEYB "zeldansq" -c "zeldansq.gptk" &
LD_LIBRARY_PATH="$GAMEDIR/libs" ./zeldansq 2>&1 | $ESUDO tee -a ./log.txt

$ESUDO kill -9 $(pidof gptokeyb)
unset LD_LIBRARY_PATH
unset SDL_GAMECONTROLLERCONFIG
$ESUDO systemctl restart oga_events &

# Disable console
printf "\033c" > $CUR_TTY