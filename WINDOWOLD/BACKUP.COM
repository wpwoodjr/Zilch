$ define ba u$0:[public.wood]
$ delete ba:*.*;*
$ copy *.* ba:
$ del ba:*.obj;*
