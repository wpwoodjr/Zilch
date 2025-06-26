$ username := 'f$getjpi(0,"USERNAME")'
$ curdir := 'f$logical("sys$disk")''f$directory()'
$ 'p1' :== $'curdir''p1' -
  /save='f$extract(0,9,username)'.zil -
  /restore='f$extract(0,9,username)'.zil -
  /help=dpc_edit:zhelp.hlp -
  /ratmap=dpc_edit:ratmap. -
  /formap=dpc_edit:formap. -
  /pasmap=dpc_edit:pasmap. -
  /textmap=dpc_edit:rnomap. -
  /cross_lines
