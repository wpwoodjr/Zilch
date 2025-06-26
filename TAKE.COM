$ save_verify := 'f$verify("NO")'
$ on control_y then goto done
$ on error then goto done
$ inquire/nopunct ans "Do you want to copy ''p1' here? "
$ if f$extract(0,1,ans) .eqs. "Y" then copy [-]'p1'.rat,.obj []/log
$ curdir := 'f$logical("sys$disk")''f$directory()'
$ ddir = "[" + f$extract(f$locate("WINDOW",curdir)+6,100,curdir)
$ open/append/err=create_1 logs assign.com
$ goto 10
$create_1:
$ open/write logs assign.com
$ write logs "$ take_files == """""
$10:
$ if p1 .nes. "EDIT" then -
	write logs "$ take_files == take_files + ""''ddir'''p1',"""
$ if p1 .eqs. "EDIT" then -
	write logs "$ assign/nolog ''curdir'''p1' edit"
$ close logs
$ @assign
$done:
$ if save_verify then set verify
