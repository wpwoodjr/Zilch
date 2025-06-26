	byte seq(1000)
	character*10 x
	real*8 icr_stdescr

	crap type *,x(icr_stdescr(%descr(seq),1))
	type *,(char(seq(i)),i=1,11)
	end

	character*10 function x(seq)
	character*1 seq(*)
	do i = 1,10
	  seq(i) = char(ichar('0')-1+i)
	  enddo
	x=seq(1)//seq(2)//seq(3)
	return
	end
