$ save_verify = 'f$verify("NO")'
$ ext := .RAT
$ extloc = 'f$locate(".",p1)'
$ if extloc.ge.'f$length(p1)' then goto no_ext
$   ext := 'f$extract(extloc,100,p1)'
$   p1 := 'f$extract(0,extloc,p1)'
$ no_ext:
$ assign/user nl: sys$output
$ paste usr$clp:build.com usr$clp:'p1'>'p1'
$ purge usr$clp:build.com
$ clp ret 'p1''ext'
$ if $status .ne. 17 .and. $status .ne. 19 then goto done
$ on error then continue
$ copy usr$clp:'p1'.obj prj$clp:'p1'.obj;0
$ delete usr$clp:'p1'.obj;*,usr$clp:'p1'.lis;*
$done:
$ if save_verify then set verify
