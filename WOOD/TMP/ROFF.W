#-h- roffsym          901 asc 08-may-80 10:58:20
   #  additional definitions for the text formatter of chapter 7
   #  put on a file called 'roffsym'
   #  These are used only by the text formatter
 
  define(INSIZE,400)
  define(MAXOUT,400)
  define(FLMAX,10)
  define(PAGENUM,SHARP)
  define(DATECHAR,PERCENT)
  define(PAGEWIDTH,65)
  define(PAGELEN,66)
  define(MAXCHARS,10)
  define(UNKNOWN,0)
  define(LEFT,1)
  define(CENTER,2)
  define(RIGHT,3)
  define(CONTROLL,12)
  define(FI,1)
  define(NF,2)
  define(BR,3)
  define(LS,4)
  define(BP,5)
  define(SP,6)
  define(IN,7)
  define(RM,8)
  define(TI,9)
  define(CE,10)
  define(UL,11)
  define(HE,12)
  define(FO,13)
  define(PL,14)
  define(PO,15)
  define(BD,16)
  define(M1,17)
  define(M2,18)
  define(M3,19)
  define(M4,20)
  define(EH,21)
  define(OH,22)
  define(EF,23)
  define(OF,24)
  define(CC,25)
  define(NE,26)
  define(BS,27)
  define(JU,28)
  define(NJ,29)
  define(HUGE,1000)
#-h- cout             503 asc 08-may-80 10:58:21
 #  common block /cout/
 #  put on a file called 'cout'
 #  used only the text formatter
 
 
 common /cout/ outp, outw, outwds, prep, outbuf(MAXOUT)
   integer outp      # last char position in outbuf; init = 0
   integer outw      # width of text currently in outbuf; init = 0
   integer prep      # last charac position of next to last
                    # word in outbuf; init=0
   integer outwds      # number of words in outbuf; init = 0
   character outbuf      # lines to be filled collect here
#-h- cpage           1676 asc 08-may-80 10:58:22
#  common block /cpage/
 # put on a file called 'cpage'
 # used only by the text formatter
 
 
 common /cpage/ curpag,newpag,lineno,plval,m1val,m2val,m3val,m4val,
  bottom, ehlim(2), ohlim(2), eflim(2), oflim(2), stopx,
  frstpg, lstpag, print, offset, ehead(MAXLINE), ohead(MAXLINE),
  efoot(MAXLINE), ofoot(MAXLINE)
   integer curpag   # current output page number; init = 0
   integer newpag   # next output page number; init = 1
   integer lineno   # next line to be printed; init = 0
   integer plval   # page length in lines; init = PAGELEN = 66
   integer m1val   # margin before and including header
   integer m2val   # margin after header
   integer m3val   # margin after last text line
   integer m4val   # bottom margin, including footer
   integer bottom   # last live line on page, = plval-m3val-m4val
   integer ehlim   # left,right margins for even header;init=inval,rmval
  integer frstpg    #first page to begin printing with
  integer lstpag    #last page to be printed
  integer print       #flag to indicate whether page should be printed
  integer offset      #number of blanks to offset page by; init = 0
   integer ohlim   # left,right margins for odd  header;init=inval,rmval
   integer eflim   # left,right margins for even footer;init=inval,rmval
   integer oflim   # left,right margins for odd  footer;init=inval,rmval
  integer stopx     #flag for pausing between pages
   character ehead   # top of page title for even pages;init=NEWLINE
   character ohead   # top of page title for odd  pages;init=NEWLINE
   character efoot   # bot of page title for even pages;init=NEWLINE
   character ofoot   # bot of page title for odd  pages;init=NEWLINE
#-h- cparam           966 asc 08-may-80 10:58:24
 #  common block /cparam/
 #  put on a file called 'cparam'
 #  used only by the text formatter
 
 
 common /cparam/ fill, lsval, inval, rmval, tival, ceval, ulval, boval,
                 tjust(3), bsval, rjust, cchar
   integer fill      # fill if YES; init = YES
   integer lsval   # current line spacing; init = 1
   integer inval   # current indent; >= 0; init = 0
   integer rmval   # current right margin; init = PAGEWIDTH = 60
   integer tival   # current temporary indent; init = 0
   integer ceval   # number of lines to center; init = 0
   integer ulval   # number of lines to underline; init = 0
   integer boval   # number of lines to boldface; init = 0
   integer tjust   # justification types for heads and foots;
                   # init = LEFT, CENTER, RIGHT
   integer bsval   # number of lines to blank suppress; init=0
   integer rjust   # right justify filled lines if YES; init=YES
   character cchar   # line control character; init = PERIOD
#-h- flist            244 asc 08-may-80 10:58:25
 ## flist common block
 #  Put on a file called 'flist'
 # Used by the tools:  sort, roff, lpr (VMS version), ls (VMS version)
 
 #flist - common block
 
  common /flist/  flevel, ffiles(FILENAMESIZE, FLMAX)
  integer flevel
  character ffiles
#-h- rscrat           267 asc 08-may-80 10:58:25
#  common block /rscrat/
 # put on a file called 'rscrat'
 # used only by the text formatter
 
 
common /rscrat/ tbuf1(MAXLINE), tbuf2(MAXLINE), ttl(MAXLINE)
 
  character tbuf1   # scratch arrays for use by puttl and tabs
  character tbuf2   #
  character ttl     #
#-h- roff.r         27734 asc 08-may-80 10:58:31
#-h- rofmain.q        133 asc 08-may-80 10:57:35
#-------------------------------------------------------------
##	main driver for roff

#	call initr4
#	call roff
#	call endr4
#	end
#-h- roffs.q         1240 asc 08-may-80 10:57:36
#-------------------------------------------------------------

#	include symbols
	include roffsym

#--------------------------------------------------------------
##	roff -- roff program

#	subroutine roff
	subroutine main

	character iarg(FILENAMESIZE)
	character inbuf(INSIZE)
        integer i, int
        integer getarg, open, getlin
#	integer getctp, type

	include flist
	include cpage
	include cout
	include cparam

	data flevel/0/

	call rofint

 for (i=1; getarg(i, iarg, FILENAMESIZE) != EOF; i=i+1)
	    {
            if ((iarg(1) == MINUS | iarg(1) == PLUS) &
                iarg(2) != EOS)
		call rofcmd(iarg)
	    else if (iarg(1) == QMARK & iarg(2) == EOS)
		call error ('usage:  roff [+n] [-n] [-s] [-po] [file].')
	    else
		call fstack(iarg)
	    }

 if (flevel <= 0)
 	{
 	flevel = 1
        ffiles(1,1) = MINUS
 	}
 for (i=1; i<= flevel; i=i+1)
	{
	if (ffiles(1,i) == MINUS)
		int = STDIN
	else
		int = open (ffiles(1,i), READ)
	if (int == ERR)
		call cant(ffiles(1,i))
	while (getlin(inbuf, int) != EOF)
		{
		if (inbuf(1) == cchar)
		    call comand(inbuf)
		else
		    call text(inbuf)
		}
	if (int != STDIN)
		call close(int)
	}
	
 if (lineno > 0 | outp > 0)
	call space(HUGE)
	
 call putc(NEWLINE)
 return
 end
#-h- brk.q            322 asc 08-may-80 10:57:37
   #------------------------------------------------------------


 ## brk - end current filled line
    subroutine brk
    include cout

    if (outp > 0) {
       outbuf(outp) = NEWLINE
       outbuf(outp+1) = EOS
       call put(outbuf)
       }
    outp = 0
    outw = 0
    outwds = 0
    prep = 0
    return
    end
#-h- center.q         279 asc 08-may-80 10:57:38
   #------------------------------------------------------------
 ## center - center a line by setting tival
    subroutine center(buf)
    character buf(ARB)
#   integer max
    integer width
    include cparam

    tival = max((rmval+tival-width(buf))/2, 0)
    return
    end
#-h- rofcmd.q        1208 asc 08-may-80 10:57:38
   #------------------------------------------------------------
   ## rofcmd - process control command (preceded by MINUS or PLUS sign)
 
   subroutine rofcmd (iarg)
 
   integer create, ctoi, i, val
    character iarg(ARB), argtyp, terml(FILENAMESIZE)
 
   include flist
   include cpage
   include cparam

   #check for pause flag (-S)
   if (iarg(1) == MINUS & (iarg(2) == LETS | iarg(2) == BIGS))
	{		#open channel to user's teletype
	call termin (terml)
	stopx = create(terml, READ)
	if (stopx == ERR)
		{
		call remark ("Can't open user's terminal.")
		stopx = 0
		}
	}
 
  #check for page offset (-POn)
   else if (iarg(1) == MINUS &
            (iarg(2) == LETP | iarg(2) == BIGP) &
            (iarg(3) == LETO | iarg(3) == BIGO))
     {
     i = 4
     val = ctoi (iarg, i)
     argtyp = iarg(4)
     call set (offset, val, argtyp, 0, 0, rmval-1)
     }
 
   #check for beginning page number (+n)
   else if (iarg(1) == PLUS)
      {
      i = 2
      frstpg = ctoi (iarg, i)
      }
 
   #check for last page number (-n)
      else if (iarg(1) == MINUS)
      {
      i = 2
      lstpag = ctoi (iarg, i)
      }
 
 
   #error
   else call remark ('ignoring invalid argument' )
 
   return
   end
#-h- comand.q        3210 asc 08-may-80 10:57:40
   #------------------------------------------------------------
 ## comand - perform formatting command
 # call to set for underline corrected 12 April 78 - DEH
    subroutine comand(buf)
    character buf(MAXLINE), argtyp
#   integer max
    integer comtyp, getval
    integer ct, spval, val
    include cpage
    include cparam
 
    ct = comtyp(buf)
    if (ct == UNKNOWN)   # ignore unknown commands
       return
    val = getval(buf, argtyp)
    if (ct == FI) {
       call brk
       fill = YES
       }
    else if (ct == NF) {
       call brk
       fill = NO
       }
    else if (ct == BR)
       call brk
    else if (ct == LS)
       call set(lsval, val, argtyp, 1, 1, HUGE)
    else if (ct == CE) {
       call brk
       call set(ceval, val, argtyp, 1, 0, HUGE)
       }
    else if (ct == UL)
       call set(ulval, val, argtyp, 1, 0, HUGE)
    else if (ct == BD) {
       call set(boval, val, argtyp, 0, 1, HUGE)
     }
    else if (ct == HE)
       {
       call gettl(buf, ehead, ehlim)
       call gettl(buf, ohead, ohlim)
       }
    else if (ct == FO)
       {
       call gettl(buf, efoot, eflim)
       call gettl(buf, ofoot, oflim)
       }
    else if (ct == BP) {
       call brk       # perform break explicitly
       if (lineno > 0)
          {
          call space(HUGE)
          }
       call set(curpag, val, argtyp, curpag+1, -HUGE, HUGE)
       newpag = curpag
       }
    else if (ct == SP) {
       call set(spval, val, argtyp, 1, 0, HUGE)
       call space(spval)
       }
    else if (ct == IN) {
       call brk
       call set(inval, val, argtyp, 0, 0, rmval-1)
       tival = inval
       }
    else if (ct == RM)
       call set(rmval, val, argtyp, PAGEWIDTH, tival+1, HUGE)
    else if (ct == TI) {
       call brk
       call set(tival, val, argtyp, 0, 0, rmval)
       }
    else if (ct == PL) {
       call set(plval, val, argtyp, PAGELEN,
          m1val+m2val+m3val+m4val+1, HUGE)
       bottom = plval - m3val - m4val
       }
    else if (ct == PO)
       call set (offset, val, argtyp, 0, 0, rmval-1)
    else if (ct == M1)
       call set (m1val, val, argtyp, 3, 0,
            plval-m2val-m3val-m4val-1)
    else if (ct == M2)
       call set (m2val, val, argtyp, 2, 0,
            plval-m1val-m3val-m4val-1)
    else if (ct == M3)
       {
       call set (m3val, val, argtyp, 2, 0,
            plval-m1val-m2val-m4val-1)
       bottom = plval - m3val - m4val
       }
    else if (ct == M4)
       {
       call set (m4val, val, argtyp, 3, 0,
            plval-m1val-m2val-m3val-1)
       bottom = plval - m3val - m4val
       }
    else if (ct == EH)
       call gettl(buf,ehead, ehlim)
    else if (ct == OH)
       call gettl(buf,ohead, ohlim)
    else if (ct == EF)
       call gettl(buf,efoot, eflim)
    else if (ct == OF)
       call gettl(buf,ofoot, oflim)
    else if (ct == CC)
       cchar = argtyp
    else if (ct == NE)
       {
       if ((lineno + val) > bottom & lineno <= bottom)
          {
          call space(val)
          lineno = 0
          }
       }
    else if (ct == BS)
       call set(bsval, val, argtyp, 1, 0, HUGE)
    else if (ct == JU)
       rjust = YES
    else if (ct == NJ)
       rjust = NO
    return
    end
#-h- comtyp.q        1940 asc 08-may-80 10:57:42
   #------------------------------------------------------------
 ## comtyp - decode command type
    integer function comtyp(buf)
    character buf(MAXLINE), c1, c2, clower

    c1 = clower(buf(2))
    c2 = clower(buf(3))
 
    if (c1 == LETF & c2 == LETI)
       comtyp = FI
    else if (c1 == LETN & c2 == LETF)
       comtyp = NF
    else if (c1 == LETB & c2 == LETR)
       comtyp = BR
    else if (c1 == LETL & c2 == LETS)
       comtyp = LS
    else if (c1 == LETB & c2 == LETP)
       comtyp = BP
    else if (c1 == LETS & c2 == LETP)
       comtyp = SP
    else if (c1 == LETI & c2 == LETN)
       comtyp = IN
    else if (c1 == LETR & c2 == LETM)
       comtyp = RM
    else if (c1 == LETT & c2 == LETI)
       comtyp = TI
    else if (c1 == LETC & c2 == LETE)
       comtyp = CE
    else if (c1 == LETU & c2 == LETL)
       comtyp = UL
    else if (c1 == LETH & c2 == LETE)
       comtyp = HE
    else if (c1 == LETF & c2 == LETO)
       comtyp = FO
    else if (c1 == LETP & c2 == LETL)
       comtyp = PL
    else if (c1 == LETP & c2 == LETO)
        comtyp = PO
    else if (c1 == LETB & c2 == LETD)
        comtyp = BD
    else if (c1 == LETM & c2 == DIG1)
        comtyp = M1
    else if (c1 == LETM & c2 == DIG2)
        comtyp = M2
    else if (c1 == LETM & c2 == DIG3)
        comtyp = M3
    else if (c1 == LETM & c2 == DIG4)
        comtyp = M4
    else if (c1 == LETE & c2 == LETH)
        comtyp = EH
    else if (c1 == LETO & c2 == LETH)
        comtyp = OH
    else if (c1 == LETE & c2 == LETF)
        comtyp = EF
    else if (c1 == LETO & c2 == LETF)
        comtyp = OF
    else if (c1 == LETC & c2 == LETC)
        comtyp = CC
    else if (c1 == LETN & c2 == LETE)
        comtyp = NE
    else if (c1 == LETB & c2 == LETS)
        comtyp = BS
    else if (c1 == LETJ & c2 == LETU)
        comtyp = JU
    else if (c1 == LETN & c2 == LETJ)
        comtyp = NJ
    else
       comtyp = UNKNOWN
    return
    end
#-h- fstack.q         358 asc 08-may-80 10:57:44
   #------------------------------------------------------------
   ## fstack - generate stack of input files

   subroutine fstack (iarg)

   integer i
   character iarg(FILENAMESIZE)

   include flist

   if (flevel < FLMAX)
     {
     flevel = flevel + 1
     for (i=1; i<=FILENAMESIZE; i=i+1)
         ffiles(i,flevel) = iarg(i)
     }
   return
   end
#-h- gettl.q          528 asc 08-may-80 10:57:45
   #------------------------------------------------------------
 ## gettl - copy title from buf to ttl
    subroutine gettl(buf, ttl, lim)
    character buf(MAXLINE), ttl(MAXLINE)
    integer i, lim(2)

    include cparam
    i = 1            # skip command name
    while (buf(i) != BLANK & buf(i) != TAB & buf(i) != NEWLINE)
       i = i + 1
    call skipbl(buf, i)      # find argument
    call scopy(buf, i, ttl, 1)   # copy titles to ttl
    lim(1) = inval               # set limits
    lim(2) = rmval
    return
    end
#-h- getval.q         512 asc 08-may-80 10:57:45
   #------------------------------------------------------------
 ## getval - evaluate optional numeric argument
    integer function getval(buf, argtyp)
    character buf(MAXLINE), argtyp
    integer ctoi
    integer i

    i = 1            # skip command name
    while (buf(i) != BLANK & buf(i) != TAB & buf(i) != NEWLINE)
       i = i + 1
    call skipbl(buf, i)      # find argument
    argtyp = buf(i)
    if (argtyp == PLUS | argtyp == MINUS)
       i = i + 1
    getval = ctoi(buf, i)
    return
    end
#-h- rofint.q        1139 asc 08-may-80 10:57:46
   #------------------------------------------------------------
 ## rofint - set parameters to default values
    subroutine rofint
 
 
    include cparam
    include cpage
    include cout
 
   #initialize /cparam/ variables
    inval = 0
    rmval = PAGEWIDTH
    tival = 0
    lsval = 1
    fill = YES
    ceval = 0
    ulval = 0
    boval = 0
    cchar = PERIOD       # initial command character
    tjust(1) = LEFT; tjust(2) = CENTER; tjust(3) = RIGHT
    bsval = 0
    rjust = YES
 
   #initialize /cpage/ variables
    lineno = 0
    curpag = 0
    newpag = 1
    plval = PAGELEN
    m1val = 3; m2val = 2; m3val = 2; m4val = 3
    bottom = plval - m3val - m4val
    ehead(1) = EOS	# initial titles
    ohead(1) = EOS
    efoot(1) = EOS
    ofoot(1) = EOS
    ehlim(1) = inval;  ehlim(2) = rmval  #initial limits for headers
    ohlim(1) = inval;  ohlim(2) = rmval
    eflim(1) = inval;  eflim(2) = rmval
    oflim(1) = inval;  oflim(2) = rmval
    print = YES
    frstpg = 0
    lstpag = 1000
    stopx = 0
    offset = 0
 
   #initialize /cout/ variables
    outp = 0
    outw = 0
    outwds = 0
    prep = 0
 
    return
    end
#-h- leadbl.q         506 asc 08-may-80 10:57:48
   #------------------------------------------------------------
 ## leadbl - delete leading blanks, set tival
    subroutine leadbl(buf)
    character buf(MAXLINE)
#   integer max
    integer i, j
    include cparam

    call brk
    for (i = 1; buf(i) == BLANK; i = i + 1)   # find 1st non-blank
       ;
    if (buf(i) != NEWLINE)
       tival = i - 1
    for (j = 1; buf(i) != EOS; j = j + 1) {   # move line to left
       buf(j) = buf(i)
       i = i + 1
       }
    buf(j) = EOS
    return
    end
#-h- pfoot.q          399 asc 08-may-80 10:57:48
   #------------------------------------------------------------
 ## pfoot - put out page footer
    subroutine pfoot
    include cpage
    integer even

    call skip(m3val)
                     # check for even/odd
       if(even(curpag) == YES) call puttl(efoot,eflim,curpag)
                        else call puttl(ofoot,oflim,curpag)
    if(print == YES) call putc(CONTROLL)
    return
    end
#-h- phead.q         1092 asc 08-may-80 10:57:49
   #------------------------------------------------------------
 ## phead - put out page header
    subroutine phead
 
    include cpage
    include rscrat
   integer even, first, tty, getlin, junk
   data first /YES/
 
 
    curpag = newpag
   #see if current page should be printed
   if (curpag >= frstpg & curpag <= lstpag)  print = YES
   else print = NO
 
   if (print == YES)
       {
       if (first == YES)
           {
           if (stopx != 0 & tty(STDOUT) == YES)
		{
		call putlin('Position paper, then hit CR to continue', 
			STDOUT)
		call putch(NEWLINE, STDOUT)
		}
           first = NO
           if (tty(STDOUT) != YES) call putc(CONTROLL)
           }
       if (stopx != 0 & tty(STDOUT) == YES)
           junk = getlin (tbuf1, stopx)
       }
    newpag = newpag + 1
       call skip(m1val-1)
       lineno = max(m1val-1, 0)
                      # check for even/odd
       if(even(curpag) == YES) call puttl(ehead,ehlim,curpag)
                        else call puttl(ohead,ohlim,curpag)
    call skip(m2val)
    lineno = lineno + max(m2val, 0)
    return
    end
#-h- put.q            716 asc 08-may-80 10:57:50
   #------------------------------------------------------------
 ## put - put out line with proper spacing and indenting
    subroutine put(buf)


    character buf(MAXLINE)
#   integer min
    integer i

    include cpage
    include cparam

    if (lineno == 0 | lineno > bottom)
       call phead
  if (print == YES)           #handle page offset
     {
       for (i=1; i<=offset; i=i+1)  call putc (BLANK)
     }

    for (i = 1; i <= tival; i = i + 1)      # indenting
       if (print == YES) call putc(BLANK)
    tival = inval
    if (print == YES) call putlin(buf, STDOUT)
    call skip(min(lsval-1, bottom-lineno))
    lineno = lineno + lsval
    if (lineno > bottom)
       call pfoot
    return
    end
#-h- puttl.q         1535 asc 08-may-80 10:57:51
   #------------------------------------------------------------
 ## puttl - put out title line with optional page number
    subroutine puttl(buf, lim, pageno)
    character buf(MAXLINE), chars(MAXCHARS), delim, datbuf(10)
    integer pageno, lim(2), first
    integer nc, itoc, i, j, n, left, right, gfield
    include cpage
    include cparam
    include rscrat
 
    data first /YES/
 
    if (print == YES & buf(1) != EOS)
        {
	if (first == YES)
	    {
	    call date(datbuf)
	    datbuf(10) = EOS
	    first = NO
	    }
	lineno = lineno + 1		# increment line count
        left = lim(1) + 1
        right = lim(2) + 1
        nc = itoc(pageno, chars, MAXCHARS) # format pageno
                                           # nc = no. of characters
        i = 1
        delim = buf(i)                     # get delimiter
        for (j=1; j<right; j=j+1)   ttl(j) = BLANK #initialize title
        n = 0
        repeat
            {
            n = n + 1         # update title counter
            if (gfield(buf,i,right-left,tbuf1,delim) > 0)
                {
                call sbst (tbuf1,PAGENUM,tbuf2,chars,nc)
		call sbst (tbuf2,DATECHAR,tbuf1,datbuf,9)
                call justfy(tbuf1,left,right,tjust(n),ttl)
                }
            }
        until (buf(i) == EOS | buf(i) == NEWLINE | n == 3)
        ttl(right) = NEWLINE
        ttl(right+1) = EOS
        for (i=1; i<=offset; i=i+1) call putc(BLANK)  # offset
        for (i=1; ttl(i) != EOS; i=i+1) call putc(ttl(i)) #title
        }
    return
    end
#-h- putwrd.q        2011 asc 08-may-80 10:57:53
   #------------------------------------------------------------
 ## putwrd - put a word in outbuf; includes margin justification
   # changed to allow blank suppression between words--26MAY78-JSS
   # cosmetic adjustments of 1st 4 lines of executable code
   # done 12 April 79 - DEH
    subroutine putwrd(wrdbuf, bs)
    character wrdbuf(INSIZE)
    integer length, width
    integer last, llval, nextra, w
    integer bs, nb, i, j, wwidth
    include cout
    include cparam
    include rscrat

    prep = outp
    if (outp != 0 & bs > 0)
	nb = 0
    else
	nb = 1
    w = width(wrdbuf)
    last = length(wrdbuf) + outp + nb   # new end of outbuf
    llval = rmval - tival
    wwidth = outw + w + nb - 1
    if (prep > 0 & (wwidth > llval | last >= MAXOUT))    # too big
        {
        last = last - prep
        if (nb == 0)   # copy entire compressed word into wrdbuf
            {
            i = prep + 1
            j = 1
            while (i < outp)
                {
                tbuf1(j) = outbuf(i)
                i = i + 1
                j = j + 1
                }
            call scopy(wrdbuf, 1, tbuf1, j)
            call scopy(tbuf1, 1, wrdbuf, 1)
            outwds = outwds - 1    # compressed word was contained in count
            }
        outp = prep
        w = width(wrdbuf)
        nextra = llval - wwidth + w + 1
        nb = 1
   #  check to see if last word in outbuf is end of sentence
        if (outbuf(outp-2) == PERIOD & outbuf(outp-1) == BLANK)
           {
           outp = outp - 1
           nextra = nextra + 1
           }

        if (rjust == YES)
           {
           call spread(outbuf, outp, nextra, outwds)
           if (nextra > 0 & outwds > 1)
              outp = outp + nextra
           }
        call brk         # flush previous line
        }
    call scopy(wrdbuf, 1, outbuf, outp+nb)
    outp = last
    outbuf(outp) = BLANK      # blank between words
    outw = outw + w + nb      # 1 for blank
    outwds = outwds + nb
    return
    end
#-h- set.q            603 asc 08-may-80 10:57:55
   #------------------------------------------------------------
 ## set - set parameter and check range
    subroutine set(param, val, argtyp, defval, minval, maxval)
#   integer max, min
    character argtyp
    integer defval, maxval, minval, param, val

    if (argtyp == NEWLINE)      # defaulted
       param = defval
    else if (argtyp == PLUS)      # relative +
       param = param + val
    else if (argtyp == MINUS)   # relative -
       param = param - val
    else               # absolute
       param = val
    param = min(param, maxval)
    param = max(param, minval)
    return
   end
#-h- skip.q           266 asc 08-may-80 10:57:55
   #------------------------------------------------------------
 ## skip - output  n  blank lines
    subroutine skip(n)
    integer i, n
   include cpage

    for (i = 1; i <= n; i = i + 1) {
       if (print == YES) call putc(NEWLINE)
       }
    return
    end
#-h- space.q          403 asc 08-may-80 10:57:56
   #------------------------------------------------------------
 ## space - space  n  lines or to bottom of page
    subroutine space(n)
#   integer min
    integer n
    include cpage

    call brk
    if (lineno > bottom)
       return
    if (lineno == 0)
       call phead
    call skip(min(n, bottom+1-lineno))
    lineno = lineno + n
    if (lineno > bottom)
       call pfoot
    return
    end
#-h- spread.q        1071 asc 08-may-80 10:57:57
   #------------------------------------------------------------
 ## spread - spread words to justify right margin
    subroutine spread(buf, outp, nextra, outwds)
    character buf(MAXOUT)
    include cparam
#   integer min
    integer dir, i, j, nb, ne, nextra, nholes, outp, outwds
    data dir /0/

    if (nextra <= 0 | outwds <= 1)
       return
    dir = 1 - dir   # reverse previous direction
    ne = nextra
    nholes = outwds - 1
    if (tival != inval & nholes > 1)
       nholes = nholes - 1
    i = outp - 1
    j = min(MAXOUT-2, i+ne)   # leave room for NEWLINE, EOS
    while (i < j) {
       buf(j) = buf(i)
 #             check for a blank following a non-blank
       if (buf(i) == BLANK & buf(i-1) != BLANK) {
          if (dir == 0)
             nb = (ne-1) / nholes + 1
          else
             nb = ne / nholes
          ne = ne - nb
          nholes = nholes - 1
          for ( ; nb > 0; nb = nb - 1) {
             j = j - 1
             buf(j) = BLANK
             }
          }
       i = i - 1
       j = j - 1
       }
    return
    end
#-h- text.q          1307 asc 08-may-80 10:57:58
   #------------------------------------------------------------
 ## text - process text lines
    subroutine text(inbuf)
    character inbuf(INSIZE), wrdbuf(INSIZE)
    integer getwrb
    integer i, bs, j
    include cparam

    if (inbuf(1) == BLANK | inbuf(1) == NEWLINE)
       call leadbl(inbuf)                    # move left, set tival
    if (ulval > 0) {                         # underlining
       call underl(inbuf, wrdbuf, INSIZE)
       ulval = ulval - 1
       }
    if (boval > 0) {                         # boldfacing
       call bold(inbuf, wrdbuf, INSIZE)
       boval = boval - 1
       }
    if (ceval > 0) {                         # centering
       call center(inbuf)
       call put(inbuf)
       ceval = ceval - 1
       }
    else if (inbuf(1) == NEWLINE)            # all blank line
       call put(inbuf)
    else if (fill == NO)                     # unfilled text
       call put(inbuf)
    else                                     # filled text
       {
       j = 0
       for (i = 1; getwrb(inbuf, i, wrdbuf) > 0; )
           {
           j = j + 1
           if(bsval > 0 & j == 1)
               {
               bs = 1
               bsval = bsval - 1
               }
           else bs = 0
           call putwrd(wrdbuf, bs)
           }
       }
    return
    end
#-h- underl.q         618 asc 08-may-80 10:57:59
   #------------------------------------------------------------
 ## underl - underline a line
    subroutine underl(buf, tbuf, size)
    integer i, j, size
    character buf(size), tbuf(size)

    j = 1      # expand into tbuf
    for (i = 1; buf(i) != NEWLINE & j < size-1; i = i + 1) {
       if (buf(i) != BLANK & buf(i) != TAB & buf(i) != BACKSPACE) {
          tbuf(j) = UNDERLINE
          tbuf(j+1) = BACKSPACE
          j = j + 2
          }
       tbuf(j) = buf(i)
       j = j + 1
       }
    tbuf(j) = NEWLINE
    tbuf(j+1) = EOS
    call scopy(tbuf, 1, buf, 1)   # copy it back to buf
    return
    end
#-h- width.q          383 asc 08-may-80 10:58:00
   #------------------------------------------------------------
 ## width - compute width of character string
    integer function width(buf)
    character buf(MAXLINE)
    integer i

    width = 0
    for (i = 1; buf(i) != EOS; i = i + 1)
       if (buf(i) == BACKSPACE)
          width = width - 1
       else if (buf(i) != NEWLINE)
          width = width + 1
    return
    end
#-h- bold.q           692 asc 08-may-80 10:58:01
   #------------------------------------------------------------
 ## bold - bold-face or overstrike a line
    subroutine bold(buf, tbuf, size)
    integer i, j, size
    character buf(size), tbuf(size)

    j = 1      # expand into tbuf
    for (i = 1; buf(i) != NEWLINE & j < size-1; i = i + 1) {
       tbuf(j) = buf(i)
       j = j + 1
       if (buf(i) != BLANK & buf(i) != TAB & buf(i) != BACKSPACE) {
          tbuf(j) = BACKSPACE
          tbuf(j+1) = tbuf(j-1)
          tbuf(j+2) = BACKSPACE
          tbuf(j+3) = tbuf(j+1)
          j = j + 4
          }
       }
    tbuf(j) = NEWLINE
    tbuf(j+1) = EOS
    call scopy(tbuf, 1, buf, 1)   # copy it back to buf
    return
    end
#-h- even.q           250 asc 08-may-80 10:58:02
   #------------------------------------------------------------
 ## even - integer function returning true if integer is even
    integer function even(i)
    integer i,mod

    if(mod(i,2) == 0) even = YES
        else even = NO
    return
    end
#-h- getwrb.q        1246 asc 08-may-80 10:58:02
   #----------------------------------------------------------
 ## getwrb - new getwrd -- hangs onto trailing blanks
    integer function getwrb(in,i,out)
    character in(ARB),out(ARB)
    integer i, j
#    space forward to first character
    while (in(i) == BLANK | in(i) == TAB)  i = i + 1
#    now count and copy non-blank characters
    j = 1
    while (in(i) != EOS & in(i) != BLANK &
           in(i) != TAB & in(i) != NEWLINE)
        {
        out(j) = in(i)
        i = i + 1
        j = j + 1
        }
#--new-- count and copy trailing blanks until non-blank char is found
  repeat
    {
    while (in(i) == BLANK)
        {
        out(j) = BLANK
        i = i + 1
        j = j + 1
        }
 #  if trailing blanks are followed by a standard punctuation mark
 #  add it to out also
    while (in(i) == PERIOD | in(i) == COMMA | in(i) == COLON |
        in(i) == RBRACE | in(i) == RBRACK | in(i) == RPAREN |
        in(i) == SEMICOL | in(i) == BACKSPACE)
        {
        out(j) = in(i)
        i = i + 1
        j = j + 1
        }
    }
  until (in(i) != BLANK)
 #  if last character in out is blank, drop it
    if (out(j-1) == BLANK) j = j - 1
#--new-- end of new addition
    out(j) = EOS
    getwrb = j - 1
    return
    end
#-h- jcopy.q          343 asc 08-may-80 10:58:04
   #-------------------------------------------------------
 ## jcopy - scopy without copying EOS
    subroutine jcopy(from,i,to,j)
    character from(ARB),to(ARB)
    integer i,j,k1,k2


    k1 = i
    k2 = j
    while (from(k1) != EOS)
        {
        to(k2) = from(k1)
        k1 = k1 + 1
        k2 = k2 + 1
        }
    return
    end
#-h- gfield.q         761 asc 08-may-80 10:58:04
   #--------------------------------------------------------------
 ## gfield - get next tab or title field
    integer function gfield(buf,i,n,temp,delim)
    character buf(ARB), temp(ARB), delim
    integer i, j, n
    j = 1
    if (n > 0)
        {
        if (buf(i) == delim) i = i + 1  # step over delimiter
        while (buf(i) != delim & buf(i) != EOS & buf(i) != NEWLINE &
               j <= n)
            {
            temp(j) = buf(i)
            j = j + 1
            i = i + 1
            }
        }
    temp(j) = EOS    # terminate temp
    gfield = j - 1   # set to number of characters copied
    while (buf(i) != delim & buf(i) != EOS & buf(i) != NEWLINE)  i = i + 1
            #  space to delimiter or to end of string
    return
    end
#-h- justfy.q         499 asc 08-may-80 10:58:05
   #------------------------------------------------------------------
 ## justfy - justifies string in its tab column
    subroutine justfy(in,left,right,type,out)
    character in(ARB), out(ARB)
#   integer max
    integer left, right, type, j, n, width
    n = width(in)
    if (type == RIGHT) call jcopy(in,1,out,right-n)
    else if (type == CENTER)
        {
        j = max((right+left-n)/2,left)
        call jcopy(in,1,out,j)
        }
    else call jcopy(in,1,out,left)
    return
    end
#-h- sbst.q           645 asc 08-may-80 10:58:06
   #--------------------------------------------------------------------
 ## sbst  - substitutes a string for a specified character
    subroutine sbst (in,char,out,subara,n)
    character in(ARB), char, out(ARB), subara(ARB)
    integer i, j, k, n
    i = 1
    j = 1
    while (in(i) != EOS)
        {
        if (in(i) == char)
            {
            for (k=1; k<=n; k=k+1)
                {
                out(j) = subara(k)
                j = j + 1
                }
            }
        else
            {
            out(j) = in(i)
            j = j + 1
            }
        i = i + 1
        }
    out(j) = EOS
    return
    end
