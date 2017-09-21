# Image_Download_Wizard
Execute "Images_Download_Wizard_install.sh" or setup by yourself

Manaul:
# install package
	$ sudo apt-get install cifs-utils nfs-common

# create script, set
	(1) mount remote direct, ${DIR1/DIR2} (must exist)
	(2) username
	(3) OA password
	sudo mount -t cifs //10.72.71.208/Prj/ ${DIR1}  -o username=${username},password=${password}
	sudo mount -t cifs //10.72.71.208/Prj2/ ${DIR2}  -o username=${username},password=${password}

	save as "${Script}" in /home/${username}/

# create file ".get_img_config" and folder ${dir_name} at /home/${username}/.
	EX:
	dir_name = "Official_Images"                 <---Copy to image folder
	remote_mount1 = "Remote_mount/3F_Release"    <---DIR1
	remote_mount2 = "Remote_mount/3F_Release2"   <---DIR2
	script = ".bash_mountremote"                 <---Script

Usage:

$ ./Images_Download_Wizard.pl

[screen]
	Project List:
	=============================================================
	1. Z301ML
	2. V500KL
	3. Z301MFL

	Please select the project (Z301ML): 2

# You can select one project to download image.

[screen]
	Project: V500KL

	Version of V500KL
	=========================================================================================
	[01] 14.0200.1612.34    [02] 14.0100.1612.34    [03] 14.0200.1612.33    [04] 14.0100.1612.33    [05] 14.0100.1612.32    [06] 14.0200.1612.32
	[07] 14.0200.1612.30.1  [08] 14.0101.1612.7     [09] 14.0200.1612.31    [10] 14.0100.1612.31    [11] 14.0200.1612.30    [12] 14.0100.1612.30
	[13] 14.0200.1612.29    [14] 14.0100.1612.29    [15] 14.0200.1612.28    [16] 14.0200.1612.27    [17] 14.0100.1612.28    [18] 14.0200.1612.27
	[19] 14.0100.1612.27    [20] 14.0200.1612.26    [21] 14.0100.1612.26    [22] 14.0200.1612.25    [23] 14.0100.1612.25    [24] 14.0200.1612.24
	[25] 14.0100.1612.24    [26] 14.0200.1612.23    [27] 14.0101.1612.6     [28] 14.0200.1612.23    [29] 14.0100.1612.23    [30] 14.0101.1612.5
	[31] 14.0200.1612.22    [32] 14.0100.1612.22    [33] 14.0101.1612.4     [34] 14.0200.1612.21    [35] 14.0100.1612.21    [36] 14.0101.1612.3
	[37] 14.0101.1612.2     [38] 14.0200.1612.20    [39] 14.0100.1612.20    [40] 14.0200.1612.19    [41] 14.0100.1612.19    [42] 14.0101.1612.1
	[43] 14.0101.1612.1     [44] 14.0200.1612.18    [45] 14.0100.1612.18    [46] 14.0200.1612.17    [47] 14.0100.1612.17    [48] 14.0200.1612.16
	[49] 14.0100.1612.16    [50] 14.0200.1612.15    [51] 14.0100.1612.15    [52] 14.0200.1612.13    [53] 14.0100.1612.14    [54] 14.0100.1612.13
	[55] 14.0200.1612.5     [56] 14.0100.1612.12    [57] 14.0100.1612.11    [58] 14.0100.1612.7     [59] 14.0100.1612.10    [60] 14.0100.1612.9
	[61] 14.0100.1612.8     [62] 14.0100.1612.6     [63] 14.0100.1612.5     [64] 14.0100.1612.2     [65] 14.0100.1612.4     [66] 14.0100.1612.3



	Please select version or resort (t/v): 1

# Here the versions are default sorted by time, if you want sort by filename you can enter "v".

[screen]
	Images of 14.0200.1612.34_3000320_18.3.0_170523_20170524
	=========================================================================================
	(1) VZW_V500KL_14.0200.1612.34_3000320_18.3.0_170523_Phone-userdebug
	(2) VZW_V500KL_14.0200.1612.34_3000320_18.3.0_170523_Phone-user



	Please select image: 1

# Select the sku or debug image to download

[screen]
	Select image zipfile "VZW_V500KL_14.0200.1612.33_3000320_18.3.0_170523_Phone-userdebug.raw.zip"

	Is this right?(y/n) y

	Copy file ...
	[6%] ======> -

[screen]
	Unzip file ...
	[100%] ====================================================================================================> \
	Complete
	Unzip done.
	Path: /home/william_shih/Official_Images/V500KL/VZW_V500KL_14.0200.1612.33_3000320_18.3.0_170523_Phone-userdebug
