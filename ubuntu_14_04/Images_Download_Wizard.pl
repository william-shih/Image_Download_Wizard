#! /usr/bin/perl -w

use Term::ANSIColor;
use POSIX;

# start

set_title();
set_environment();
select_project();
set_project_config();
show_image_version("1");
show_SKU_and_debug();

sub set_title{
	print color("grey13"), "\n*******************************************************************\n";
	print " Module: ",color("white"), "Images Download Wizard\n\n", color("grey13");
	print " Copyright: Ver 1.0 2017/5/18\t William_Shih<william_shih\@asus\.com>\n\n";
	print "            Ver 1.1 2017/5/22\t William_Shih<william_shih\@asus\.com>\n\n";
	print "            Ver 1.2 2017/9/20\t William_Shih<william_shih\@asus\.com>\n\n";
	print "            Ver 1.3 2017/9/28\t William_Shih<william_shih\@asus\.com>\n\n";
	print " This file used to get official images without trivial commands.\n\n";
	print " Enjoy your download procedure!!\n";
	print "*******************************************************************\n\n\n", color("reset");
}

sub set_environment{
	$user_name=getpwuid($<); # get the username from this server
	$wizard_root=`pwd`; # current path
	chomp($wizard_root);
	print "Current Path: $wizard_root\n\n";
	my $config_file = ".get_img_config"; # configure file for this wizard
	$dir_name = "Images";               # output folder
	if(-f "$config_file"){
		open(FHD, "$config_file") or die "Could not open file $config_file $!";
		while (my $line = <FHD>){
			chomp $line;
			if($line =~ m/dir_name[ \t]*=[ \t]*(.*)/){
				$dir_name = $1;
			}elsif($line =~ m/remote_mount1[ \t]*=[ \t]*(.*)/){
				$remote_mount1 = $1;
			}elsif($line =~ m/remote_mount2[ \t]*=[ \t]*(.*)/){
				$remote_mount2 = $1;
			}elsif($line =~ m/script[ \t]*=[ \t]*(.*)/){
				$script = $1;
			}elsif($line =~ m/width[ \t]*=[ \t]*(.*)/){
				$array_width = $1;
			}
		}
		close($config_file);
	}else{
		# use default setting
		$remote_mount1 = "Remote_mount/3F_Release";  # prj
		$remote_mount2 = "Remote_mount/3F_Release2"; # prj2
		$script = ".bash_mountremote";               # mount script
		$array_width = 6;                            # default set array width as 6
	}
}

# select download destination folder and create one if not exist.
sub select_project{

	my $prj_file = "Prj_list";
	$project = "Z301ML"; #default
	print "Project List:\n";
	print "=============================================================\n";
	if(-f $prj_file){
		my @prjs = `cat $prj_file`;
		my @new_prjs;
		$cnt = 1;
		foreach my $prj (@prjs){
			chomp($prj);
			print "$cnt. $prj\n";
			$new_prjs[$cnt] = $prj;
			$cnt = $cnt + 1;
		}
		print "\nPlease select the project ($project): ";
		chomp($input=<STDIN>);
		if ($input =~ /^\s*[1-9][0-9]*\s*$/){
			if($input >= $cnt){
				Error_Handle("Out of range");
			}
			$project = $new_prjs[$input];
	#		print "Select project: ", color("bold yellow"), "\"$project\"\n\n", color("reset");
		}else{
			Error_Handle("Invalid input");
		}
	}else{
		print "1. Z301ML\n";
		print "2. V500KL\n";
		print "3. Z301MFL\n";
		print "\nPlease select the project ($project): ";
		chomp($input=<STDIN>);
		if($input eq 1 ){
			$project = "Z301ML";
		}elsif($input eq 2){
			$project = "V500KL";
		}elsif($input eq 3){
			$project = "Z301MFL";
		}elsif($input){
			$project = $input;
		}
	}
	$des_dir = "$wizard_root/$dir_name/$project"; #output folder
	print "destination folder: $des_dir\n";
	if(! -d $des_dir){
		system("mkdir -p $des_dir"); # if not exist, create one
		print "Create $des_dir folder.\n"
	}
}

# show selected project and set download source server
sub set_project_config{
	print "Project:", color("bold yellow"), " $project\n", color("reset");
	$server = "$wizard_root/$remote_mount1";
	print "$wizard_root/$remote_mount2";
	if(-d "$wizard_root/$remote_mount1/$project"){
		$server = "$wizard_root/$remote_mount1";
	}elsif(-d "$wizard_root/$remote_mount2/$project"){
		$server = "$wizard_root/$remote_mount2";
	}else{
		Error_Handle("\nNot support path for $project");
	}
}

# show available versions of selected project
sub show_image_version{
	my @vers;
	if($_[0] eq "0"){
		@vers=`ls $server/$project/Images`;
	}elsif($_[0] eq "1"){
		@vers=`ls -t $server/$project/Images`;
	}
	my @new_ver;
	$cnt = 1;
	print "\nVersion of $project\n";
	print "=========================================================================================\n";
	if(!@vers){
		print "Remounting ...\n";
		system("bash $wizard_root/$script");
		sleep 3;
		my @vers=`ls $server/$project/Images`;
		if(!@vers){
			print "Please set the mount script!\n";
			exit 1;
		}
	}
	foreach my $file (@vers){
		if ($file =~ m/([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\.?[0-9]?)_/){
			$ver = $1;
			print "[", color("bold yellow");
			printf ("%02s",$cnt);
			print color("reset"),"] $ver\t";
			chomp $file;
			$new_ver[$cnt] = $file;
			$cnt = $cnt + 1;
			if (($cnt-1) % $array_width == 0){
				print "\n";
			}
		}
	}
	print "\n\n\n";
	print "Please select version or sort again (t/v): ";
	chomp($input=<STDIN>);
	if ($input =~ /^\s*[0-9][0-9]*\s*$/){
		if($input >= $cnt){
			Error_Handle("Out of range");
		}
		$ver = $new_ver[$input];
		print "Select verion ", color("bold yellow"), "\"$ver\"\n\n", color("reset");
	}elsif($input eq "v" or $input eq "V"){
		clear_screen();
		show_image_version("0");
	}elsif($input eq "t" or $input eq "T"){
		clear_screen();
		show_image_version("1");
	}else{
		Error_Handle("Invalid input");
	}
	set_percent_bar();
}
sub show_SKU_and_debug{
	my @imgs=`ls $server/$project/Images/$ver/*.raw.zip`;
	my @fname_arr;
	my @new_img;
	$cnt = 1;

	if(!@imgs){
		clear_screen();
		print "Image are not ready, back.\n";
		show_image_version("1");
		show_SKU_and_debug();
	}else{
		print "Images of $ver\n";
		print "=========================================================================================\n";
		foreach my $file (@imgs){
			if($file =~ m/.*\/(.*)\.raw\.zip/){
				$fname = $1;
				print "(", color("bold yellow"), "$cnt", color("reset"), ") $fname\n";
				$fname_arr[$cnt] = $fname;
				chomp $file;
				$new_img[$cnt] = "$fname\.raw\.zip";
				$cnt = $cnt + 1;
			}
		}
		print "\n\n\n";
		print "Please select image: ";
		chomp($input=<STDIN>);
		if ($input =~ /^\s*[1-9][0-9]*\s*$/){
			if($input >= $cnt){
				Error_Handle("Out of range");
			}
			$fname = $fname_arr[$input];
			$img = $new_img[$input];
			print "Select image zipfile ", color("bold yellow"), "\"$img\"\n\n", color("reset");
		}else{
			Error_Handle("Invalid input");
		}
		print "Is this right?(y/n) ";
		chomp($input=<STDIN>);
		$slt = lc $input;
		if($slt eq "y"){
			print "Flash after download task?(y/n) ";
			chomp($input=<STDIN>);
			$flash = lc $input;
			if (-f "$des_dir/$img") {
				print "File already exit. Copy whatever?(y/n) ";
				chomp($input=<STDIN>);
				$slt = lc $input;
				if($slt eq "y"){
					system("rm $des_dir/$img");
					sleep 1;
					system("cp $server/$project/Images/$ver/$img $des_dir &");
					show_percent_bar("$server/$project/Images/$ver/$img", "$des_dir/$img", "Copy file ...");
					print "Copy done.\n";
				}
			}else{
				print "Copying to $wizard_root ...\n";
				system("cp $server/$project/Images/$ver/$img $des_dir &");
				clear_screen();
				show_percent_bar("$server/$project/Images/$ver/$img", "$des_dir/$img", "Copy file ...");
				print "Copy done. Start unzipping $img ...\n";
			}
			if(-d "$des_dir/$fname") {
				print "Directory already exit. Unzip whatever?(y/n) ";
				chomp($input=<STDIN>);
				$slt = lc $input;
				if($slt eq "y"){
					system("rm -rf $des_dir/$fname");
					sleep 2;
					system("unzip $des_dir/$img -d $des_dir/$fname > /dev/null &") == 0 or warn "$0: unzip exited " . ($? >> 8) . "\n";
					show_percent_bar("$des_dir/$img", "$des_dir/$fname", "Unzip file ...", "zip");
					print "Unzip done.\n";
				}
			}else{
				print "Start unzipping $img ...\n";
				system("unzip $des_dir/$img -d $des_dir/$fname > /dev/null &") == 0 or warn "$0: unzip exited " . ($? >> 8) . "\n";
				show_percent_bar("$des_dir/$img", "$des_dir/$fname", "Unzip file ...", "zip");
				print "Unzip done.\n";
			}
			print "Path: $des_dir/$fname\n";
		}elsif ($slt eq "n"){
			clear_screen();
			print color("green"), "Restart\n", color("reset");
			select_project();
			set_project_config();
			show_image_version("1");
			show_SKU_and_debug();
		}else{
			print "Error input, STOP!!\n"
		}
	}
	if($flash eq "y"){
		flash_image_hook();
	}
}

sub show_percent_bar(){
	$cur_size = 0;
	$srcinfo = `du $_[0]`;
	if($srcinfo =~ m/([1-9][0-9]*)[\t ]+\/home\//){
		print "$total_size\n";
		$total_size = $1;
		if ($_[3]){
			$line = `unzip -l $_[0] | tail -n1`;
			if($line =~ m/([1-9][0-9]*)[\t ].*files/){
				$total_size = floor($1 / 1024);
			}
		}
		print "Total Size: $total_size\n";
	}
	while($cur_size < $total_size){
		$desinfo = `du $_[1]`;
		if($desinfo =~ m/([1-9][0-9]*)[\t ]+\/home\//){
			$cur_size = $1;
		}
		$percent = floor(100 * $cur_size / $total_size);
		clear_screen();
		print "$_[2]\n";
		print color("bold yellow"), "[$percent%] ", color("reset"), "$percent_bar[$percent] /\n";
		$desinfo = `du $_[1]`;
		if($desinfo =~ m/([1-9][0-9]*)[\t ]+\/home\//){
			$cur_size = $1;
		}
		$percent = floor(100 * $cur_size / $total_size);
		clear_screen();
		print "$_[2]\n";
		print color("bold yellow"), "[$percent%] ", color("reset"), "$percent_bar[$percent] -\n";
		$desinfo = `du $_[1]`;
		if($desinfo =~ m/([1-9][0-9]*)[\t ]+\/home\//){
			$cur_size = $1;
		}
		$percent = floor(100 * $cur_size / $total_size);
		clear_screen();
		print "$_[2]\n";
		print color("bold yellow"), "[$percent%] ", color("reset"), "$percent_bar[$percent] \\\n";
	}
	print "Complete\n";
}

sub flash_image_hook(){
	chdir "$des_dir/$fname";
	system("cp $wizard_root/flash_tool/* $des_dir/$fname");
	system("./multiflash.sh");
	chdir "/home/$user_name";
}

sub set_percent_bar(){
	$idx = 0;
	$str = ">";
	while($idx <= 100){
		$percent_bar[$idx] = $str;
		$str = "=$str";
		$idx = $idx + 1;
	}
}

sub clear_screen(){
	system("clear");
}

sub gen_percent_bar(){
	open(out_file, ">percent_bar.txt");
	$idx = 1;
	$str = ">";
	while($idx <= 100){
		print out_file "}elsif(\$percent < $idx){\n";
		print out_file "\tprint \"$str /\\n\";\n";
		$str = "=$str";
		$idx = $idx + 1;
	}
	print out_file "}\n";
	close(out_file);
}

sub Error_Handle(){
	$str = $_[0];
	print color("red"), "$str, Exit!!\n", color("reset");
	exit 1;
}
