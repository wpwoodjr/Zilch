$ save_verify := 'f$verify("NO")'
$ on control_y then goto done
$ on error then goto done
$ curdir := 'f$logical("sys$disk")''f$directory()'
$ copy [-]'p1'.rat,.obj []/log
$ open/append/err=create_1 logs assign.com
$ goto 10
$create_1:
$ open/write/err=done logs assign.com
$10:
$ write logs "$ assign/nolog/job ''curdir'''p1' ''p1'"
$ close logs
$ assign/nolog/job 'curdir''p1' 'p1'
$ open/append/err=create_2 logs deassign.com
$ goto 20
$create_2:
$ open/write/err=done logs deassign.com
$20:
$ write logs "$ deassign/job ''p1'"
$ close logs
$done:
$ if save_verify then set verify
