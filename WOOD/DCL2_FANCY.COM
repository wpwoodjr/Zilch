$ set nocontrol=t
$ assign nl: tt
$ assign nl: sys$error
$ deassign sys$output
$ assign nl: sys$output
$ delete/symbol/local lo
$ delete/symbol/local logo
$ delete/symbol/local logoff
$ delete/symbol/local logout
$ delete/symbol/global lo
$ delete/symbol/global logo
$ delete/symbol/global logoff
$ delete/symbol/global logout
$ logoff :== @'p1'/output='p2'
$ logout :== @'p1'/output='p2'
$ lo*goff :== @'p1'/output='p2'
$ deassign sys$output
$ assign 'p2' sys$output
