$ save_verify := 'f$verify("NO")'
$ makebind := $sys$disk:[]makebind
$ if p2 .eqs. "/CODE" then goto 10
$ p4 = p3
$ if p4 .eqs. "" then p4 := com$8:[wood.window.wood]zbind.fnc
$ p3 = p2
$ p2 = ""
$10:
$ makebind 'p2' 'p3' 'p4'
$ if save_verify then set verify
