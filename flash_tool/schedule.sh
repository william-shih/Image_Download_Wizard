#! /bin/bash

echo "=====$2: Setting dev $1====="
if [ "$2" == "Z301ML" ]; then
  # Z301ML workaround
  NUM=`cat flashall.sh | grep -n "\-n \$1" | cut -f1 -d:`
  cp flashall.sh temp.sh
  sed "${NUM}s/\$1/\"\$1\"/" "temp.sh" > "flashall.sh"
  rm temp.sh
fi
if [ "$2" == "V500KL" ]; then
  # V500KL workaround
  cp V500KL_flashall.sh flashall.sh
fi
./flashall.sh "-s $1"
./skip_setup_wizard.sh "-s $1"
echo "=====     DONE     ====="
