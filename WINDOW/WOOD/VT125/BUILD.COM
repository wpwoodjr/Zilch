$ assign [--] zs
$ compile -
  /link=(zs:alloc,zs:iobuffer,zs:movc,zs:tecon,zs:bind,zs:def,zs:hollerith, -
    icr$library:icr/lib)-
	vt125,tty
