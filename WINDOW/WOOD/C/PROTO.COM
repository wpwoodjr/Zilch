$ if p1 .nes. "" then list/noprompt 'p1'.c (/%{/-1g+2)>>proto.h
$ if p1 .eqs. "" then list/noprompt *.c (/%{/-1g+2)>proto.h
$ x/save=nl:/ini=sys$input proto.h
10000c;\12\12
10000c\12;\12
[/staticmt]1000xm
