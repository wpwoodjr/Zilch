#-h- crypsym          112 asc 07-may-80 15:14:35
 # definitions for crypt tool
 # put on a file called 'crypsym'
 # Used only by crypt
 
 define(MAXKEY,MAXLINE)
#-h- crypt.r         1114 asc 07-may-80 15:14:36
#-h- main             295 asc 07-may-80 15:14:14
 #---------------------------------------------------------------------
 # include symbol definitions
 #        include symbols
          include crypsym
 #---------------------------------------------------------------------
 # crypt - main driver
# call initr4
# call crypt
# call endr4
# end
#-h- crypts           551 asc 07-may-80 15:14:15
 # crypt - encrypt and decrypt standard input
# subroutine crypt
 subroutine main
 character getc, xor
 character c, key(MAXKEY), b
 integer getarg, mod
 integer i, keylen
  
 keylen = getarg(1,key,MAXKEY)
 if (keylen == EOF | (key(1) == QMARK & key(2) == EOS))
	call error('usage: crypt key.')
 for (i=1; getc(c) != EOF; i = mod(i,keylen) + 1)
	{
	if (c < BLANK)		#leave control characters alone
		call putc(c)
	else
		{
		b = xor(c, key(i) & 31)
      		if (b == 127)		#DEC can't handle RUBOUT char
      			b = c
		call putc(b)
		}
	}
 return
 end
#-h- xor              121 asc 07-may-80 15:14:15
 # xor - exclusive-or of a and b
 character function xor(a,b)
 character a, b
  
 xor = (a & !b) | (!a & b)
 return
 end
