$ exportit ratfiv
$ define zexp icr$export:[export.zilch]
$ copy sys$system:zilch.exe icr$export:[export]
$ copy sys$system:zbind.exe icr$export:[export]
$ copy zilch.olb zexp:
$ copy *map. icr$export:[export]
$ copy zhelp. icr$export:[export]
$ copy zilch.rnh zexp:
$ copy zilch.hlp zexp:
$ copy zilch.rnd zexp:
$ copy zilch.doc zexp:
$ copy aaareadme.rno zexp:
$ copy [.wood]pocket.lis zexp:
$ copy zcai$:*.* icr$export:[export]
$ copy icr$document:zcai.doc zexp:
$ copy u$0:[public.source.zcai]zcai.rnd zexp:
$ set def zexp:
$ runoff/output=aaareadme.txt aaareadme
$ comm makelist aaareadme.txt
$ purge
$ deass zexp
