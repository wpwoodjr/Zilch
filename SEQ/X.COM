$ @[-]x zbind
$ if f$logical("gendisk") .nes. "" then exit
$ assign/nolog -
	gendisk:[uwgcg.source],gendisk:[uwgcg.library.temp],gendocsource: uws
$ gcg
$ tek
