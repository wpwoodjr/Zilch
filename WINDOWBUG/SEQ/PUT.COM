$ save_verify := 'f$verify("NO")'
$ on control_y then goto done
$ on error then goto done
$ list/nonumbers assign.com /~'p1'/,$?x>*.*
$ list/nonumbers deassign.com /~'p1'/,$?x>*.*
$ purge 'p1'.*
$ deassign/job 'p1'
$done:
$ if save_verify then set verify
