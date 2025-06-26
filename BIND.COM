$ save_verify := 'f$verify("NO")'
$ makebind := $sys$disk:[-.wood]makebind
$ if p2 .eqs. "/CODE" then goto 10
$ p4 = p3
$ if p4 .eqs. "" then p4 := 'f$directory()'zbind.fnc
$ p3 = p2
$ p2 = ""
$10:
$ makebind 'p2' 'p3' 'p4'
$ fortran/nolist/nocheck/nodebug/object='p3'.bbj 'p3'.bor
$ link/nomap/share='p3'.exe 'p3'.bbj,sys$input/options
psect=bind,wrt,noshr
gsmatch=lequal,1,1000
$ delete 'p3'.bor;*,'p3'.bbj;*
$ assign 'f$logical("sys$disk")''f$directory()''p3'.exe zilchbind
$ if p2 .nes. "" then @build 'p3'
$ if save_verify then set verify
