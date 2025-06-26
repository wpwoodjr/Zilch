$ macro pydriver
$ macro ptdriver
$ link pydriver,p.opt/opt,sys$system:sys.stb/sel
$ link ptdriver,p.opt/opt,sys$system:sys.stb/sel
$ exit
