#! /bin/bash

# program name
PROG=Images_Download_Wizard

# username
unset usr_name
usr_name="$(whoami)"
echo "username: $usr_name"

# wizard root
WROOT=/home/$usr_name/$PROG
GET_IMG_CONFIG=$WROOT/.get_img_config
CUR=`pwd`

# environment setting
clear
echo "Installing needed packages: Do not skip at first time!!"
read -p "Skip?(y/n)" check
if [ "$check" == "n" ]; then
	echo "Installing packages ..."
	sudo apt-get install cifs-utils nfs-common
fi

# mount remote server
unset mount1 mount2
check="n"
if [ -f $GET_IMG_CONFIG ]; then
	echo "Mount remote server: configure file already exist"
	read -p "Skip?(y/n)" check
fi
yn=$check
while [ "$yn" == "n" ]; do
	clear
	echo "We will mount remote server (Prj/Prj2) to your server (\$mount1/\$mount2)."
	read -p "Enter dirname (\$mount1) -> Prj: " mount1
	read -p "Enter dirname (\$mount2) -> Prj2: " mount2
	echo "dir path: $WROOT/$mount1"
	echo "          $WROOT/$mount2"
	read -p "OK?(y/n)" yn
	yn=$(echo $yn | perl -ne 'print lc')
	echo $yn
done
if [ "$check" == "n" ]; then
	clear
	echo "Creating $mount1 $mount2 ..."
	mkdir -p $WROOT/$mount1
	mkdir -p $WROOT/$mount2
fi

# set mount script
unset fname
unset OA_name
check="n"
if [ -f $GET_IMG_CONFIG ]; then
	echo "Create mount script: configure file already exist"
	read -p "Skip?(y/n)" check
fi
yn=$check
while [ "$yn" == "n" ]; do
	clear
	unset OA_name OA_pwd fname
	read -p "Enter your OA username: " OA_name
	echo -n "Enter your OA password: "
	read -s OA_pwd
	echo
	read -p "Enter filename of mount script: " fname
	echo
	echo "OA username=$OA_name"
	echo "OA password=$OA_pwd"
	echo "file path: $WROOT/$fname"
	read -p "OK?(y/n)" yn
	yn=$(echo $yn | perl -ne 'print lc')
done

if [ "$check" == "n" ]; then
	clear
	FILENAME=$WROOT/$fname
	UMOUNT=$WROOT/umount.sh
	echo "Creating $FILENAME ..."
	touch $FILENAME
	echo "sudo mount -t cifs //10.72.71.208/Prj/ $WROOT/$mount1 -o username=$OA_name,password=$OA_pwd" > $FILENAME
	echo "sudo mount -t cifs //10.72.71.208/Prj2/ $WROOT/$mount2 -o username=$OA_name,password=$OA_pwd" >> $FILENAME
	chmod 755 $WROOT/$fname
	touch $UMOUNT
	echo "sudo umount $mount1 $mount2" > $UMOUNT
	echo "rm -rf $mount1 $mount2" >> $UMOUNT
	chmod 755 $UMOUNT
fi

# Create destination folder
unset img_dir

check="n"
if [ -f $GET_IMG_CONFIG ]; then
	clear
	echo "Create destination folder: configure file already exist"
	read -p "Skip?(y/n)" check
fi
yn=$check
while [ "$yn" == "n" ]; do
	clear
	echo "We will copy img from server to \$dir."
	read -p "Enter \$dir name: " img_dir
	echo "dir path: $WROOT/$img_dir"
	read -p "OK?(y/n)" yn
	yn=$(echo $yn | perl -ne 'print lc')
done

if [ $check == "n" ]; then
	clear
	echo "Creating $WROOT/$img_dir ..."
	mkdir -p $WROOT/$img_dir
fi

clear
width=6
read -p "The default width is $width. Is it OK?(y/n)" yn
while [ "$yn" == "n" ]; do
	read -p "Set width as : " width
	echo "width of array is $width now"
	read -p "OK?(y/n)" yn
	yn=$(echo $yn | perl -ne 'print lc')
done

echo "Creating .get_img_config ..."


if [ -f $GET_IMG_CONFIG ]; then
	clear
	read -p "configure file exist, overwrite?(y/n)" yn
fi
if [ "$yn" == "y" ]; then
	touch $GET_IMG_CONFIG
	echo "dir_name = $img_dir" > $GET_IMG_CONFIG
	echo "remote_mount1 = \"$mount1\"" >> $GET_IMG_CONFIG
	echo "remote_mount2 = \"$mount2\"" >> $GET_IMG_CONFIG
	echo "script = \"$fname\"" >> $GET_IMG_CONFIG
	echo "width = $width" >> $GET_IMG_CONFIG
fi

# execute the mount script
clear
echo "Mount remote server ..."
sudo $FILENAME

# create symbolic link
clear
echo "Create symbolic link at $WROOT/get_official_image.pl ..."
ln -s $CUR/Images_Download_Wizard.pl $CUR/../get_official_image.pl
echo "Done. You can enjoy your download now!"
echo "Try ./Download_Image_Wizard.pl"
