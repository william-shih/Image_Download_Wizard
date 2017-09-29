#! /usr/bin/perl -w

use Term::ANSIColor;
use POSIX;
use sigtrap qw/handler signal_handler normal-signals/;

# start

set_title();
set_environment();
select_project();
show_SKU_and_debug();

sub set_title{
	print "\n*******************************************************************\n";
	print " Module: Images Download Wizard\n\n";
	print " Copyright: Ver 1.4 2017/9/29\t William_Shih<william_shih\@asus\.com>\n\n";
	print " This file used to get official images without trivial commands.\n\n";
	print " Enjoy your download procedure!!\n";
	print "*******************************************************************\n\n\n";
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
		Error_Handle("Please execute \"Images_Download_Wizard_install.sh\" again");
	}
}

# select download destination folder and create one if not exist.
sub select_project{

	my $prj_file = "Prj_list";
	$project = "Z301ML"; #default
	show_frame_title("Project List:\n");
	if(-f $prj_file){
		my @prjs = `cat $prj_file`;
		my @new_prjs;
		my $cnt = 1;
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
		}else{
			Error_Handle("Invalid input");
		}
	}else{
		Error_Handle("Please provide $prj_file");
	}
	$des_dir = "$wizard_root/$dir_name/$project"; #output folder
	print "destination folder: $des_dir\n";
	if(! -d $des_dir){
		system("mkdir -p $des_dir"); # if not exist, create one
		print "Create $des_dir folder.\n"
	}
	set_project_config();
}

# show selected project and set download source server
sub set_project_config{
	print "Project: $project\n";
	$server = "$wizard_root/$remote_mount1";
	if(-d "$wizard_root/$remote_mount2/$project"){
		$server = "$wizard_root/$remote_mount2";
	}else{
		Error_Handle("\nNot support path for $project");
	}
	show_image_version("-t");
}

# show available versions of selected project
sub show_image_version{
	my @vers;
	@vers=`ls $_[0] $server/$project/Images`;
	my @new_ver;
	show_frame_title("\nVersion of $project\n");
	if(!@vers){
		print "Remounting ...\n";
		system("bash $wizard_root/$script &");
		sleep 1;
		my @vers=`ls $server/$project/Images`;
		if(!@vers){
			Error_Handle("Cannot find mount script");
		}
	}
	my $cnt = 1;
	foreach my $file (@vers){
		if ($file =~ m/([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\.?[0-9]?)_/){
			$ver = $1;
			print "[";
			printf ("%02s",$cnt);
			print "] $ver\t";
			chomp $file;
			$new_ver[$cnt] = $file;
			$cnt = $cnt + 1;
			if (($cnt-1) % $array_width == 0){
				print "\n";
			}
		}
	}
	show_select_prompt("Please select version or sort again (t/v): ");
	chomp($input=<STDIN>);
	if ($input =~ /^\s*[0-9][0-9]*\s*$/){
		if($input >= $cnt){
			Error_Handle("Out of range");
		}
		$ver = $new_ver[$input];
		print "Select verion \"$ver\"\n\n";
	}elsif($input eq "v" or $input eq "V"){
		clear_screen();
		show_image_version("");
	}elsif($input eq "t" or $input eq "T"){
		clear_screen();
		show_image_version("-t");
	}else{
		Error_Handle("Invalid input");
	}
	set_percent_bar();
}
sub show_SKU_and_debug{
	my @imgs=`ls $server/$project/Images/$ver/*.raw.zip`;
	my @fname_arr;
	my @new_img;

	if(!@imgs){
		clear_screen();
		print "Image is not ready, back.\n";
		show_image_version("-t");
		show_SKU_and_debug();
	}else{
		show_frame_title("Image of $ver\n");
	        my $cnt = 1;
		foreach my $file (@imgs){
			if($file =~ m/.*\/(.*)\.raw\.zip/){
				$fname = $1;
				print "($cnt) $fname\n";
				$fname_arr[$cnt] = $fname;
				chomp $file;
				$new_img[$cnt] = "$fname\.raw\.zip";
				$cnt = $cnt + 1;
			}
		}
		show_select_prompt("Please select image: ");
		chomp($input=<STDIN>);
		if ($input =~ /^\s*[1-9][0-9]*\s*$/){
			if($input >= $cnt){
				Error_Handle("Out of range");
			}
			$fname = $fname_arr[$input];
			$img = $new_img[$input];
			print "Select image zipfile \"$img\"\n\n";
		}else{
			Error_Handle("Invalid input");
		}
		yes_or_no("Is this right", $slt);
		if($slt eq "y"){
			yes_or_no("Flash after download task", $flash);
			if (-f "$des_dir/$img") {
				yes_or_no("File already exit. Copy whatever", $slt);
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
				yes_or_no("Directory already exit. Unzip whatever", $slt);
				if($slt eq "y"){
					print "select yes $des_dir/$fname\n";
					system("rm -rf $des_dir/$fname");
					sleep 1;
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
			print "Restart\n";
			select_project();
			show_SKU_and_debug();
		}else{
			Error_Handle("Invalid input");
		}
	}
	if($flash eq "y"){
		flash_image_hook();
	}
}

sub show_percent_bar(){
	$cur_size = 0;
	$srcinfo = `du $_[0]`;
	$des_path = $_[1];
	$frame_title = $_[2];
	if($srcinfo =~ m/([1-9][0-9]*)[\t ]+\/home\//){
		$total_size = $1;
		print "$total_size\n";
		if ($_[3]){                      # unzip part
			$line = `unzip -l $_[0] | tail -n1`;
			if($line =~ m/([1-9][0-9]*)[\t ].*files/){
				$total_size = floor($1 / 1024);
			}
		}
		print "Total Size: $total_size\n";
	}
	while($cur_size < $total_size){
		show_frame("/");
		show_frame("-");
		show_frame("\\");
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
	my $idx = 0;
	my $str = ">";
	while($idx <= 100){
		$percent_bar[$idx] = $str;
		$str = "=$str";
		$idx = $idx + 1;
	}
}

sub clear_screen(){
	system("clear");
}

sub show_frame(){
	$pattern = $_[0];
	$desinfo = `du $des_path`;
	if($desinfo =~ m/([1-9][0-9]*)[\t ]+\/home\//){
		$cur_size = $1;
	}
	$percent = floor(100 * $cur_size / $total_size);
	clear_screen();
	print "$frame_title\n";
	print "[$percent%] $percent_bar[$percent] $pattern\n";
}

sub show_frame_title(){
	print "$_[0]";
	print "=============================================================\n";
}

sub show_select_prompt(){
	print "\n\n\n";
	print "$_[0]";
}

sub yes_or_no(){
	print "$_[0]?(y/n) ";
	chomp($input=<STDIN>);
	$_[1] = lc $input;
}

sub Error_Handle(){
	print "$_[0], Exit!!\n";
	exit 1;
}

sub signal_handler(){
	print "\nleaving ...\n";
	@threads = `ps -t`;
	foreach my $thread (@threads){
		if($thread =~ m/([1-9][0-9]*) .*:[0-9][0-9] ([a-z]+) /){
			$pid = $1;
			$cmd = $2;
			if($cmd eq "cp"){
				system("kill -9 $pid");
				print("Removing $des_dir/$img ...");
				system("rm $des_dir/$img");
				print "\nRemoving thread $pid\n";

			}
			if($cmd eq "unzip"){
				system("kill -9 $pid");
				print("Removing $des_dir/$fname ...");
				system("rm -rf $des_dir/$fname");
				sleep 2;
				print "\nRemoving thread $pid\n";
			}
		}
	}
	exit 1;
}
