$ assign dpc_root:[libr.emacs]		emdir
$ assign dpc_root:[libr.emacs]		owndir
$ assign dpc_root:[libr.emacs]emacs.ini 	emacs_init
$ assign "|emdir:" 				epath
$ assign "vt100" 				term
$ assign/user sys$command sys$input
$ e := $dpc_root:[libr.emacs.old]emacs
$ e 'p1'
