#! /bin/bash

if [ -n "$1" ]; then
  ADB="adb $1"
  $ADB wait-for-device
  COMPLETE_FLAG=""
  TIME_WAIT=0
  NAP_TIME=10
  while [ -z "$COMPLETE_FLAG" ]; do
        COMPLETE_FLAG=`$ADB logcat -d -b events | grep boot_progress_ams_ready`
        TIME_WAIT=`expr $TIME_WAIT + $NAP_TIME`
        sleep $NAP_TIME
        if [ `echo "$TIME_WAIT % 30" | bc` -eq 0 ]; then
           echo "Already waited for $TIME_WAIT seconds..."
        fi
  done
  $ADB shell settings put secure user_setup_complete 1
else
  adb wait-for-device
  DEV=`adb devices | sed -e s/device//g | tail -n +2`
  for sn in $DEV;
  do
    echo $sn
    adb -s $sn shell settings put secure user_setup_complete 1
  done
fi
