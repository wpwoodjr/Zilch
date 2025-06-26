$ curdir := 'f$logical("sys$disk")''f$directory()'
$ if p1 .eqs. "" then assign 'curdir'vt.exe zilchbind
$ if p1 .nes. "" then assign 'curdir''p1'.exe zilchbind
$ username := wood !'f$getjpi(0,"USERNAME")'
$ x :== $'curdir'zilch -
  /save='f$extract(0,9,username)'.zil -
  /restore='f$extract(0,9,username)'.zil -
  /help=dpc_edit:zhelp.hlp -
  /ratmap=dpc_edit:ratmap. -
  /formap=dpc_edit:formap. -
  /pasmap=dpc_edit:pasmap. -
  /textmap=dpc_edit:rnomap. -
  /cross_lines
$ clean :== purg *.exe,*.bbj,*.bor,*.fnc,zbind.rat,[-...]*.obj
$ sr :== search [-...]*.rat
$ ll :== 'list'/nonumbers/noprompt sys$login:b*.log /error|link/?x
$ bind :== @'curdir'bind dummy
