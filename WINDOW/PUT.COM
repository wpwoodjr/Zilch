$ save_verify := 'f$verify("NO")'
$ on control_y then goto done
$ on error then goto done
$ inquire/nopunct ans "Do you want to copy ''p1' back up? "
$ if f$extract(0,1,ans) .nes. "Y" then goto 10
$ purge 'p1'.*
$ rename 'p1'.rat,.obj [-]/log
$ libr [-]zilch [-]'p1'/log
$10:
$ list/nonumbers assign.com /~'p1'/,$?x>*.*
$ @assign
$ if p1 .eqs. "EDIT" then deassign edit
$done:
$ if save_verify then set verify
