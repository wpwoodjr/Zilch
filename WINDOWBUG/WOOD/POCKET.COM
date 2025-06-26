$ macrop sys$input: pocket.rno >t.tmp
_macro(_width,46)
$ runo/nobold/out=t.tmp t.tmp
$ @icr$command:makelist t.tmp
$ list t.tmp s
3,/editing functions/-1p>1.tm1
,/miscellaneous/-1p>2.tm1
,/c o m m a n d/-1p>3.tm1
,/mapping characters:/-1p>4.tm1
,+1//-1>1.tm2
,+1//-1>2.tm2
,+1//-1>3.tm2
,+1//>4.tm2
$ run pocket
46
$ delete t.tmp;*,*.tm1;*,*.tm2;*
$ purge pocket.lis
