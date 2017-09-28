#! /bin/bash

# username
unset usr_name
usr_name="$(whoami)"
echo "username: $usr_name"

# wizard root
CUR=`pwd`
GET_IMG_CONFIG=$CUR/../.get_img_config

# environment setting
clear
echo "Installing packages ..."
sudo apt-get install cifs-utils nfs-common

# mount remote server
clear
unset mount1 mount2
mount1=3F_server1
mount2=3F_server2
echo "Creating $mount1 $mount2 ..."
mkdir -p $CUR/../$mount1
mkdir -p $CUR/../$mount2

# set mount script
unset FILENAME
FILENAME=$CUR/../mount.sh
yn="n"
while [ "$yn" == "n" ]; do
	clear
	unset OA_name OA_pwd fname
	read -p "Enter your OA username: " OA_name
	echo -n "Enter your OA password: "
	read -s OA_pwd
	echo
	echo "OA username=$OA_name"
	echo "OA password=$OA_pwd"
	echo "file path: $FILENAME"
	read -p "OK?(y/n)" yn
	yn=$(echo $yn | perl -ne 'print lc')
done

clear
echo "Creating $FILENAME ..."
touch $FILENAME
echo "sudo mount -t cifs //10.72.71.208/Prj/ $CUR/../$mount1 -o username=$OA_name,password=$OA_pwd" > $FILENAME
echo "sudo mount -t cifs //10.72.71.208/Prj2/ $CUR/../$mount2 -o username=$OA_name,password=$OA_pwd" >> $FILENAME
chmod 755 $FILENAME

# Create unmount script
UMOUNT=$CUR/../umount.sh
touch $UMOUNT
echo "sudo umount $mount1 $mount2" > $UMOUNT
echo "rm -rf $mount1 $mount2" >> $UMOUNT
chmod 755 $UMOUNT

# Create destination folder
unset img_dir
img_dir=Images

clear
echo "Creating $CUR/../$img_dir ..."
mkdir -p $CUR/../$img_dir

width=6
clear
echo "The default width is 6"
read -p "Reset width as : " width

echo "Creating .get_img_config ..."

yn="y"
if [ -f $GET_IMG_CONFIG ]; then
	clear
	read -p "configure file exist, overwrite?(y/n)" yn
fi
if [ "$yn" == "y" ]; then
	touch $GET_IMG_CONFIG
	echo "dir_name = $img_dir" > $GET_IMG_CONFIG
	echo "remote_mount1 = \"$mount1\"" >> $GET_IMG_CONFIG
	echo "remote_mount2 = \"$mount2\"" >> $GET_IMG_CONFIG
	echo "script = \"mount.sh\"" >> $GET_IMG_CONFIG
	echo "width = $width" >> $GET_IMG_CONFIG
fi

# execute the mount script
clear
echo "Mount remote server ..."
sudo $FILENAME

# create symbolic link
clear
echo "Create symbolic link at $CUR/../get_official_image.pl ..."
ln -s $CUR/Images_Download_Wizard.pl $CUR/../get_official_image.pl
echo "Done. You can enjoy your download now!"
echo "Try ./Download_Image_Wizard.pl"
