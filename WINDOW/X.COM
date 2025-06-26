$ curdir := 'f$logical("sys$disk")''f$directory()'
$ if p1 .nes. "" then assign 'curdir''p1'.exe zilchbind
$ username := wood !'f$getjpi(0,"USERNAME")'
$ x :== $'curdir'zilch -
  /save='f$extract(0,9,username)'.zil -
  /restore='f$extract(0,9,username)'.zil -
  /help=sc_root:[zilch]zhelp.hlp -
  /ratm=sc_root:[zilch]ratmap. -
  /form=sc_root:[zilch]formap. -
  /pasm=sc_root:[zilch]pasmap. -
  /cm=com$8:[wood.window]cmap. -
  /textm=sc_root:[zilch]rnomap. -
  /cross_lines
$ if p2 .eqs. "" then p2 = p1
$ clean :== purg 'p2'.rat,*.exe,*.bbj,*.bor,*.fnc,[-...]*.obj
$ sr :== search [-...]*.rat
$ ll :== 'list'/nonumbers/noprompt sys$login:b*.log /error|link/?x
$ bind :== @[-]bind dummy
$ take :== @[-]take
$ put :== @[-]put
$ if f$logical("edit") .nes. "" then deassign/log edit
$ take_files == ""
$ if f$search("assign.com") .nes. "" then @assign
