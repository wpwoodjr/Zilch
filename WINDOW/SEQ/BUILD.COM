$ assign/nolog genoblib:genlib gl
$ assign/nolog plotoblib pl
$ @[-]build zbind gl/lib,pl/lib,gl/lib, /trace
