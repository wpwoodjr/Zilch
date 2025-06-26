$ on error then goto done
$ on control_y then goto done
$ set def [-]
$ compile/symbols/nolist -
	/link=(/nomap/exe=[.wood]makebind -
		hollerith,icr$library:icr/lib) -
	[.wood]makebind/nocheck/nodebug,bind/nocheck/nodebug/inc=bind.cmn
$done:
$ set def [.wood]
