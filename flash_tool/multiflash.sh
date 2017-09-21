#! /bin/bash

DEVS=`fastboot devices | sed -e s/fastboot//`
for sn in $DEVS;
do
MODEL=$( { fastboot -s $sn oem get_build_version; } 2>&1 )
MODEL=${MODEL%%-*}
MODEL=${MODEL#*_}
echo "$MODEL: flashing $sn ..."
./schedule.sh "$sn" "$MODEL" &
SCHE_PID=$!
echo "PID: $SCHE_PID"
sleep 3
done
