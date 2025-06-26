$ save_verify = 'f$verify("NO")'
$ ext := .RAT
$ extloc = 'f$locate(".",p1)'
$ if extloc.ge.'f$length(p1)' then goto no_ext
$   ext := 'f$extract(extloc,100,p1)'
$   p1 := 'f$extract(0,extloc,p1)'
$ no_ext:
$ clp get 'p1''ext'
$ if $status.ne.81 .and. $status.ne.97 then goto done
$ assign/user nl: sys$output
$ paste usr$clp:build.com 'p1'>usr$clp:'p1'
$ purge usr$clp:build.com
$ on error then continue
$ copy prj$clp:'p1'.obj usr$clp:
$ done:
$ if save_verify then set verify
