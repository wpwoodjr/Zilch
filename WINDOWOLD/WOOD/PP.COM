$ save_verify := 'f$verify("NO")'
$ assign/user sys$command sys$input
$ list 'p1' n 1,$p
$ if save_verify then set verify
