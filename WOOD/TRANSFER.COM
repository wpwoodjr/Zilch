$ if .not.("''p1'" .eqs. "" .or. "''p1'" .eqs. "EXE") then goto noexe
$ copy zilch.exe dpc_exe:
$ set proc/priv=cmkrnl
$ mcr install
dpc_exe:zilch/replace
$ purge dpc_exe:zilch.exe
$ set file/owner=parent dpc_exe:zilch.exe
$! copy zbind.exe dpc_exe:
$ copy pc.exe dpc_exe:zbind.exe
$ purge dpc_exe:zbind.exe
$ set file/owner=parent dpc_exe:zbind.exe
$noexe:
$ if .not.("''p1'" .eqs. "" .or. "''p1'" .eqs. "HLP") then goto nohlp
$ copy [-]zilch.rnh dpc_root:[libr.help]
$ purge dpc_root:[libr.help]zilch.rnh
$ set file/owner=parent dpc_root:[libr.help]zilch.rnh
$ libr/replace/help dpc_libr:dpchelp [-]zilch.hlp
$ copy [-]zhelp. dpc_edit:zhelp.hlp
$ purge dpc_edit:zhelp.hlp
$ set file/owner=parent dpc_edit:zhelp.hlp
$nohlp:
$ if .not.("''p1'" .eqs. "" .or. "''p1'" .eqs. "DOC") then goto nodoc
$ copy [-]zilch.doc dpc_doc:
$ purge dpc_doc:zilch.doc
$ set file/owner=parent dpc_doc:zilch.doc
$ copy [-]zilch.rnd dpc_doc:
$ purge dpc_doc:zilch.rnd
$ set file/owner=parent dpc_doc:zilch.rnd
$nodoc:
$ if .not.("''p1'" .eqs. "" .or. "''p1'" .eqs. "MAP") then goto nomap
$ copy [-]ratmap. dpc_edit:
$ purge dpc_edit:ratmap.
$ set file/owner=parent dpc_edit:ratmap.
$ copy [-]formap. dpc_edit:
$ purge dpc_edit:formap.
$ set file/owner=parent dpc_edit:formap.
$ copy [-]pasmap. dpc_edit:
$ purge dpc_edit:pasmap.
$ set file/owner=parent dpc_edit:pasmap.
$ copy [-]rnomap. dpc_edit:
$ purge dpc_edit:rnomap.
$ set file/owner=parent dpc_edit:rnomap.
$nomap:
