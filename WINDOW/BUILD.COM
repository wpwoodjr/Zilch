$ save_verify := 'f$verify("NO")'
$ on control_y then goto done
$ on error then goto done
$	comp*ile	:= $dpc_exe:compile com
$ assign/nolog 'f$logical("sys$disk")''f$directory()' z
$ if p1 .eqs. "" then p1 = "zbind"
$ if p3 .eqs. "" then p3 = "/notrace"
$ set def [-]
$ take_files = "''take_files'"
$ if take_files .nes. "" then -
	compile/symbols/nolist/nocheck/nodebug 'take_files'
$ compile/nolist/disable=(debug,trace)/libr=zilch -
		movc,-
		fillc,-
		cmpc,-
		findnew,-
		gpopen
$ compile/symbols/nolist/nocheck/nodebug/libr=zilch -
		macro,-
		bind/inc=bind.cmn,-
		fileio,-
		text,-
		hollerith,-
		buffer,-
		window,-
		page,-
		message,-
		indent,-
		mark,-
		search,-
		mappings,-
		dcl,-
		help,-
		spfiles,-
		pushb
$ compile/symbols/nolist/nocheck/nodebug/libr=zilch -
		[]screen/nocheck/nodebug,-
		session,-
		alloc,-
		string,-
		update/nocheck/nodebug,-
		cost,-
		tecon/noch,-
		iobuffer,-
		[]tty,-
		edfunc,-
		word,-
		region,-
		insert,-
		command,-
		hyper,-
		checkp
$ assign/nolog icr$library:icr i$
$ comp/sym/nolis/noch/nodeb/link=(/nomap/nodeb'p3'/exe=z:zilch-
		'take_files'zilch/lib,zilch/opt,'p2'i$/lib) -
	edit,z:'p1'
$done:
$ set default z:
$ if save_verify then set verify
