#./fastboot getvar version-bootloader
echo "Saving log to fastboot.log"

FASTBOOT="./fastboot $1"
echo "FASTBOOT=$FASTBOOT"

echo "flash partition gpt_both0.bin..."
$FASTBOOT flash partition gpt_both0.bin > fastboot.log 2>&1
grep -E 'FAILED|error' fastboot.log
RETVAL=$?
if [ $RETVAL -eq 0 ];then
        echo 'failed and exit'; exit 1
fi

echo "flash bootloader bootloader.img ..."
$FASTBOOT flash bootloader bootloader.img >> fastboot.log 2>&1
grep -E 'FAILED|error' fastboot.log
RETVAL=$?
if [ $RETVAL -eq 0 ];then
        echo 'failed and exit'; exit 1
fi

echo "flash splash splash.img..."
$FASTBOOT flash splash splash.img >> fastboot.log 2>&1
grep -E 'FAILED|error' fastboot.log
RETVAL=$?
if [ $RETVAL -eq 0 ];then
        echo 'failed and exit'; exit 1
fi

echo "flash dsp adspso.bin..."
$FASTBOOT flash dsp adspso.bin >> fastboot.log 2>&1
grep -E 'FAILED|error' fastboot.log
RETVAL=$?
if [ $RETVAL -eq 0 ];then
        echo 'failed and exit'; exit 1
fi

echo "reboot-bootloader..."
$FASTBOOT reboot-bootloader >> fastboot.log 2>&1
grep -E 'FAILED|error' fastboot.log
RETVAL=$?
if [ $RETVAL -eq 0 ];then
        echo 'failed and exit'; exit 1
fi
echo "wait for 5 seconds for bootloader to be ready..."
sleep 5

echo "flash modem NON-HLOS.bin..."
$FASTBOOT flash modem NON-HLOS.bin >> fastboot.log 2>&1
grep -E 'FAILED|error' fastboot.log
RETVAL=$?
if [ $RETVAL -eq 0 ];then
        echo 'failed and exit'; exit 1
fi

echo "flash boot boot.img..."
$FASTBOOT flash boot boot.img >> fastboot.log 2>&1
grep -E 'FAILED|error' fastboot.log
RETVAL=$?
if [ $RETVAL -eq 0 ];then
        echo 'failed and exit'; exit 1
fi

echo "flash recovery recovery.img..."
$FASTBOOT flash recovery recovery.img >> fastboot.log 2>&1
grep -E 'FAILED|error' fastboot.log
RETVAL=$?
if [ $RETVAL -eq 0 ];then
        echo 'failed and exit'; exit 1
fi

echo "flash system system.img..."
$FASTBOOT flash -S 128M system system.img >> fastboot.log 2>&1
grep -E 'FAILED|error' fastboot.log
RETVAL=$?
if [ $RETVAL -eq 0 ];then
        echo 'failed and exit'; exit 1
fi

echo "format VZW..."
$FASTBOOT format VZW >> fastboot.log 2>&1
grep -E 'FAILED|error' fastboot.log
RETVAL=$?
if [ $RETVAL -eq 0 ];then
        echo 'failed and exit'; exit 1
fi

echo "format asdf..."
$FASTBOOT format asdf >> fastboot.log 2>&1
grep -E 'FAILED|error' fastboot.log
RETVAL=$?
if [ $RETVAL -eq 0 ];then
        echo 'failed and exit'; exit 1
fi

$FASTBOOT -w
$FASTBOOT oem adb_enable 1
