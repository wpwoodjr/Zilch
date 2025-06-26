c **  seqed  ******************************************************************
c **
c **	a screen editor for biological sequences
c **
c **		copyright 1982 Paul Haeberli
c **		translated into FORTRAN at EMBL, August 1984
c **		by Paul Haeberli and John Devereux
c **
c **		modified to support embedded comments and to be closer
c **		to UWGCG standard by John Devereux 1984.
c **
c **		Modified to support editing of embedded comments and 
c **		heading comments, and the commands mark and include
c **		by Will Winsborough 1985.
c **
c **		Modified to support Dayhoff-style database input
c **		by Philip Marquess, Feb, 1986.
c **
c *****************************************************************************

	program seqed

	include 'commonlib(seqed)'

	character oneline(132)
	integer com, start, finish
	character comstr(132), argstr(132), cmdline(132), token(132)
	integer pos, junk, NextCommentIndex, FirstCom
	character RUN(10)
	logical CLGetParam, MustGetFName

	logical DoLog/.true./  !  directive to doincl

	call account('seqed')
	call edinit

	if ( isfile('seqed.log') ) then
	   if ( CLGetParam('INfile1', 1, oneline) ) then
	      call printf 
     *		('\n Last SeqEd session terminated abnormally.  
     *            \n To recover run seqEd without a file parameter.  
     *		  \n To start a new session, delete seqed.log.\n')
	      call cleanup
	   end if

	   call recover
	else

* see if the file name was given on the command line.
* use oneline to get file name  and let doedit verify that it's
* okay.              

	   if ( .not.CLGetParam('INfile1', 1, oneline) ) then
	      MustGetFName = .true.
	   else
	      if ( oneline(1).eq.NULL ) then
		 MustGetFName = .true.
	      else
		 MustGetFName = .false.
	      end if
	   end if

	   if ( MustGetFName ) then
	      call twgotoxy(0,22)
	      call twaddstr(' SEQED of what sequence ?  ')
	      call twgetstr(oneline)
	      if ( strlen(oneline).eq.0 ) call cleanup
	   end if
              
	   call doedit (oneline)

	   do while ( strlen(seqname).eq.0  )
	      call twgotoxy(0,22)
	      call twaddstr(' What sequence to edit ?  ')
	      call twgetstr(oneline)
	      if ( strlen(oneline).eq.0 ) call cleanup
	      call doedit(oneline)
	   end do

	call twgotoxy(1,22)
	call twclrtoeol

	end if

	call doscreen

100	com = getcmd(start, finish, comstr, argstr)

	call showtext (' ')

	if ( com.eq.CNULL .or. com.eq.CSCREEN ) then
	   call  doscreen
	else if ( com.eq.CGO ) then
	   seqpos = ilimit(1, start, seqlen+1)
	else if ( com.eq.CFIND ) then
	   call dofind
	else if ( com.eq.CHELP ) then
	   call dohelp
	else if ( com.eq.CWRITE ) then
	   call dowrite(start, finish, argstr)
	else if ( com.eq.CWQ ) then
	   call dowq(start, finish, argstr)
	else if ( com.eq.CEDIT ) then
	   call doedit(argstr)
	else if ( com.eq.CDELETE ) then
	   call dodelete(start,finish)
	else if ( com.eq.CCHECK ) then
	   call docheck(start, argstr)
	else if ( com.eq.CREDRAW ) then
	   call doredraw
	else if ( com.eq.CCOM ) then
	   call docomment(start, argstr)
	else if ( com.eq.CFILE ) then
	   call dofile
	else if ( com.eq.CQUIT ) then
	   call doquit
	else if ( com.eq.CINCL ) then
	   call doincl (start, argstr, DoLog, 0, 0, .false.) ! last args ignored
	else if ( com.eq.CMARK ) then
	   call domark(start, argstr)
	else if ( com.eq.CHEADING ) then
	   call DoHeading(start)
	else if ( com.eq.CNUC ) then
	   IsNucleotide = .true.
	else if ( com.eq.CPROT ) then
	   IsNucleotide = .false.
  	end if

* update the screen

    	call update
	call findfirst(NextCommentIndex(seqpos), FirstCom, junk)
	call DisplayComments (FirstCom)

* controled by command line switch /SINGlecommand

	if ( SingleCommand ) call doscreen

	go to 100

	end ! of seqed

c **  getcmd  *****************************************************************
c **
c **	parse a command line and return the command number
c **
c **	Start and Finish get the first and second numbers from the 
c **	command line.  Comstr gets the command string and argstr,
c **	the argument string.  The order listed is the order they occur
c **	on the command line.
c **
c ****************************************************************************

	function getcmd( start, finish, comstr, argstr )

	include 'commonlib(seqed)'

	integer start, finish
	character comstr(*), argstr(*)

	character oneline(132), tempstr(132)
	integer cmd, pos, tp

	character PastCmds(132, 0:19)
	integer Newest, Oldest, Step
	logical FirstCall/.true./
	integer ReturnCode, twgetstr
	integer rightmod

* return codes for twgetstr

	integer  UP/1/, DOWN/2/, RET/5/, CTLZ/6/ 

c get the command line
c incase the command is illegal, we'll return to this label:

 100	continue

	oneline(1) = NULL

	call twgotoxy(0,22)
	call twclrtoeol
	call twaddstr(': ')	
	ReturnCode = twgetstr(oneline)
                         
	Step = Newest
	do while ( ReturnCode.ne.RET )
	   if ( ReturnCode.eq.UP ) then
	      if ( Step.ne.Oldest ) then
	         Step = rightmod (Step-1, 20)
	         call strcopy (oneline, PastCmds(1, Step) )
	      end if 
		   else if ( ReturnCode.eq.DOWN ) then
	      if ( Step.ne.Newest ) then
	         Step = rightmod (Step+1, 20)
	         call strcopy (oneline, PastCmds(1, Step) )
	      end if
	   else if ( ReturnCode.eq.CTLZ ) then
	      Step = Newest
	      call strcopy (oneline, PastCmds(1, Step) )
	   else 
	      call sprintf (oneline, 
     *		' Error in value returned by TwGetStr to GetCmd')
	      call showtext (oneline)
	      call cleanup
	   end if 

	   call twgotoxy(0,22)
	   call twclrtoeol
	   call twaddstr(': ')	
	   ReturnCode = TwGetStr (oneline)
	end do

* set up to record commands for command line editing with history

	if ( FirstCall ) then
	   Newest = 0
	   Oldest = 0
	   FirstCall = .false.
	end if

* record this command for posterity

	call strcopy (PastCmds(1, Newest), oneline)

	Newest = rightmod (Newest+1, 20)
	PastCmds(1, Newest) = Char(0)  ! null out 
	if ( Oldest .eq. Newest ) Oldest = rightmod (Oldest+1, 20)

	call twgotoxy(0,22)
	call twclrtoeol
	call twrefresh

c skip white space at the beginning - return if nothing in command

	pos = 1
	do while( iswhite(oneline(pos)) .and. oneline(pos).ne.NULL )
	   pos = pos+1
	end do
	if ( oneline(pos).eq.NULL ) then
	   call showtext(' ')
	   getcmd = CNULL
* don't include that in the command history after all
	    Newest = rightmod (Newest-1, 20)
	    PastCmds(1, Newest) = Char(0)
	   return
	end if

c scan a number from the start of the command if it is there

	tp = 1
	do while( oneline(pos).eq.'-' .or. isdigit(oneline(pos)) )
	   tempstr(tp) = oneline(pos)
	   pos = pos+1
	   tp = tp+1
	end do
	tempstr(tp) = NULL
	if( .not.strtoint(tempstr,start) ) start = NOADDR

c skip white space, a comma and more white space

	do while( iswhite(oneline(pos)) .or. oneline(pos).eq.',' )
	    pos = pos+1
	end do                     

c scan another number off the command line
	
	tp = 1
	do while( oneline(pos).eq.'-' .or. isdigit(oneline(pos)) )
	   tempstr(tp) = oneline(pos)
	   pos = pos+1
	   tp = tp+1
	end do
	tempstr(tp) = NULL
	if ( .not.strtoint(tempstr,finish) ) finish = NOADDR

c skip white space

	do while( iswhite(oneline(pos)) .and. oneline(pos).ne.NULL )
	   pos = pos+1
	end do

c get the command
	
	tp = 1
	do while( .not.iswhite(oneline(pos)) .and. oneline(pos).ne.NULL )
	   comstr(tp) = oneline(pos)
	   pos = pos+1
	   tp = tp+1
	end do
	comstr(tp) = NULL

* skip the while space

	do while( iswhite(oneline(pos)) .and. oneline(pos).ne.NULL )
	   pos = pos + 1
	end do

c look for a filename following the command
	
	tp = 1
	do while ( oneline(pos).ne.NULL )
	   argstr(tp) = oneline(pos)
	   pos = pos+1
	   tp = tp+1
	end do
	argstr(tp) = NULL

* meanit flags are no longer supported, but they may still be in use!

	tp = strfind('!', comstr)
	if (tp.ge.1) comstr(tp) = NULL

	if ( cmdmatch(' ', comstr) ) then
	    getcmd = CNULL
* don't include that in the command history after all
	    Newest = rightmod (Newest-1, 20)
	    PastCmds(1, Newest) = Char(0)
	else if ( cmdmatch('screen',comstr) ) then
	    getcmd = CSCREEN
	else if ( cmdmatch('/',comstr) ) then
	    getcmd = CFIND
	else if ( cmdmatch('Find',comstr) ) then
	    getcmd = CFIND
	else if ( cmdmatch('Help',comstr) ) then
	    getcmd = CHELP
	else if ( cmdmatch('Write',comstr) ) then
	    getcmd = CWRITE  
	else if ( cmdmatch('WQ',comstr) ) then
	    getcmd = CWQ
	else if ( cmdmatch('EDit',comstr) ) then
	    getcmd = CEDIT
	else if ( cmdmatch('EXit',comstr) ) then
	    getcmd = CWQ
	else if ( cmdmatch('Read',comstr) ) then
	    getcmd = CREAD
	else if ( cmdmatch('Delete',comstr) ) then
	    getcmd = CDELETE
	else if ( cmdmatch('CHeck',comstr) ) then
	    getcmd = CCHECK
	else if ( cmdmatch('COmment',comstr) ) then
	    getcmd = CCOM
	else if ( cmdmatch('REDraw',comstr) ) then
	    getcmd = CREDRAW
	else if ( cmdmatch('Quit',comstr) ) then
	    getcmd = CQUIT
	else if ( cmdmatch('Seq',comstr) ) then
	    getcmd = CFILE
	else if ( cmdmatch('Go',comstr) ) then
	    getcmd = CGO
	else if ( cmdmatch('Include', comstr) ) then
	    getcmd = CINCL
	else if ( cmdmatch('Mark', comstr) ) then
	    getcmd = CMARK
	else if ( cmdmatch('HEAding', comstr) ) then
	    getcmd = CHEADING
	else if ( cmdmatch('NUCleotide', comstr) ) then
	    getcmd = CNUC
	else if ( cmdmatch('PROTein', comstr) ) then
	    getcmd = CPROT
	else if (comstr(1).eq.'/') then
	    call strcopy(argstr,comstr(2))
	    getcmd = CFIND
	else if ( (start.ne.NOADDR.or.finish.ne.NOADDR) .and.
     *		  strlen(comstr).eq.0                   .and.
     *		  strlen(argstr).eq.0                         ) then
	    if ( start.eq.NOADDR ) start = finish
	    getcmd = CGO
	else
	    call sprintf(oneline, 
     *		' "%s" is not an editor command!  Try again.', comstr)
	    call showtext(oneline)
	    goto 100 ! ask for another command
	end if

	return
	end ! of getcmd

***  rightmod  *************************************************************
*
*	FORTRAN does not implement mod correctly!  A negative number mod
*	a positive number is negative in FORTRAN.  That makes lots of 
*	data structures a pain in the ass to implement, e.g., circular
*	fucking queues.  So here I clean up their act.  But I don't 
*	allow you to mod by a negative number.
*
*************************************************************************

	integer function rightmod (op1, op2)

	integer op1, op2, answer

	if ( op2.le.0 ) then
	   call showtext
     *	    (' You called rightmod with a non-positive second operand.')
	   stop
	end if

	answer = mod (op1, op2)

	if ( answer.lt.0 ) answer = op2 + answer

	rightmod = answer

	return
	end ! of rightfuckingmod


***  edinit  ******************************************************************
*
*	performs the initialization for seqed
*
*******************************************************************************

	subroutine edinit

	include 'commonlib(seqed)'

	integer i
	character initfilename(20)
	logical CLRetBool

	scalelen = 100
	seqpos = 1
	seqlen = 0
	comlines = 0
	findseq(1) = NULL
	seqname(1) = NULL
	seq(1) = NULL
	checking = .FALSE.

	do i = 1, 129
	    markloc(i) = -1
	end do

	scrseqlen = 0
	scredge = 0
	scrscalelen = 100
	scrbarlen = 0

	call twinit
	call makescales(scalelen)
	call twgotoxy(0,22)
	call twrefresh
	call readinit

	logon = .FALSE.

	call strcopy (initfilename, 'seqed.init')
	call CLFileInit (initfilename)

	IsNucleotide = .not.(CLRetBool('PERfect').or.
     *	      	CLRetBool('PROtein').or.CLRetBool('PEPtide'))

	SingleCommand = CLRetBool('SINGlecommand')
                                                             
     	return
	end ! of edinit

c **  doedit  *****************************************************************
c **
c **	starts the session with a new or used sequence file.
c **
c *****************************************************************************

	subroutine doedit( fname )

	include 'commonlib(seqed)'

	character fname(*)

  	integer seqfile, NextCommentIndex
  	integer linelen, i, row, check, FirstCom, junk, dotpos1, dotpos2
	logical newseq
  	character oneline(256)
	integer TwTextEdit, step
	logical database
	integer runit, xx

	logical dbisfile ! function
	logical IsProtein ! function
                                                     
	call strsqueeze(fname)
	if ( nameok(fname, newseq) ) then
	   checking = .false.
	   comlines = 0

* keep and display the sequence name

	   call strcopy(seqname, fname)
	   call twgoaddstr(0, 0, '                      ')
	   call twgoaddstr(0, 0, seqname)

* initialize position array to be all -1

	   do i = 1, 1000
	      position (i) = -1
	   end do        

* clear embedded comment display area

	   do step = 6, 9
	      call TwGoToXY (0, step)
	      call TwClrToEOL
	   end do

* it's either a new file

	   if ( newseq ) then
	      seq(1) = NULL
	      seqlen = 0
	      seqpos = 1
	      comtable(1,1) = NULL
	      position(1) = -1
	      comments(1,1) = NULL
	      comlines = 1

	      do step = 1, 4
		 call TwGoToXY(0,step)
		 call TwClrToEOL
	         call TwGoToXY(4,step)
	         call TwAddStr (':')
	         call TwGoToXY (76,step)
	         call TwAddStr (':')
	      end do

	      call update

	      ComLines = TwTextEdit (comments,1000,comlines,1,6,74,1,4)

* or it's an existing file

	   else
	      if ( .not. openf(seqfile, fname, 'rdb') ) then
	         call beep(1)
	         call sprintf(oneline,
     *			' "%s" cannot be opened.', fname)
		 call showtext (oneline)
	         return
	      end if
	      call sprintf(oneline, ' "%s" . . .', fname)
	      call showtext(oneline)

* hose down the user if the seqfile is not in UWGCG format

	      if ( .not.loadseq(seqfile, seq, seqlen, check,
     *				 comtable, position)         ) then
		 call beep(1)
	         call sprintf(oneline, 
     *		 ' "%s" is not a sequence file in UWGCG format!', fname)
		 call showtext(oneline)
* The following disgusting control mechanism tells the caller loading failed.
		 seqname(1) = NULL  
		 call closef (seqfile)
		 return
	      end if
                    
* or just tell him about a successful read

	      call sprintf(oneline, ' "%s"  %d bases',
     *						fname, seqlen)
	      call showtext(oneline)

* get the heading, show the first 5 lines, save the first 999 lines
              
	      call rewindf(seqfile)
	      if ( dbisfile(seqfile) ) then
		call dbgetunits(seqfile, xx, runit, xx)
		database = .true.
	      else
		runit = seqfile
		database = .false.
	      end if
	      call readstring(runit, oneline, linelen)
	      do while( linelen.ge.0                 .and.
     *			comlines.lt.999              .and.
     *			strfind('..', oneline).eq.0         )
		 if ( database .and. comlines.ne.0 .and.
     *		      oneline(1).eq.'>' ) go to 9999
		 comlines = comlines + 1
		 oneline(ILimit(1,linelen+1,256)) = NULL
		 call strcopy(comments(1,comlines), oneline)
		 comments(1,comlines+1) = NULL
		 call readstring(runit, oneline, linelen)
	      end do
9999	      continue
	      call closef(seqfile)
	   end if

	   call showdoc
	   call ComScale(0, 14, 79, 10, 4, scredge)

	   call twrefresh
	   seqpos = 1
	   call endlog(logon,logfile)
	   call sqbeginlog(newseq)
	   Strand = ORIGSTR

* Delete version number from the sequence name, strip the directory spec 
* from sequence name and give db entries file extentions.
* This must be done after the call to sqbeginlog to keep the logfile correct.

	   call basename(seqname)
	   if ( database ) then
	      if ( IsProtein (seq) ) then
		 call NewFileType(seqname,'pep')
	      else
		 call NewFileType(seqname,'seq')
	      end if
	   end if

	else
	   call sprintf(oneline, ' Illegal file name.  Try again.')
	   call showtext(oneline)
	end if

	return
	end ! of doedit

***  doquit  ******************************************************************
*
*	quit the editor
*
*******************************************************************************

	subroutine doquit

	include 'commonlib(seqed)'

        Call endlog(logon, logfile)
        Call cleanup                        ! never returns

	End ! of doquit

***  dofile  ******************************************************************
*
*	tell about the file being editted.
*
*******************************************************************************

	subroutine dofile

	include 'commonlib(seqed)'

	character oneline(132)
	character mstring(20), fstring(20)

	call strcopy(mstring, ' ')
	If ( strlen(seqname).eq.0 ) then
	   call strcopy(fstring, ' No file')
    	else
           call sprintf(fstring, ' "%s"', seqname) 
        end if
	call sprintf( oneline, 
     *	  ' %s%s Now at base %d of %d',
     *			 fstring, mstring, seqpos, seqlen)
	call showtext(oneline) 

	return
	end ! of dofile

c **  dowrite  ****************************************************************
c **
c **  	write out the sequence file.  Returns true if it worked.
c **
c *****************************************************************************

	Logical function dowrite( start, finish, fname )
             
	include 'commonlib(seqed)'
      
	integer start, finish
	character fname(*)

	integer s, f, i, newseq, outfile
	character onebase, oneline(132), outfname(132)

	dowrite = .false.

	call strsqueeze(fname)
	if ( strlen(fname).eq.0 ) then
	   if ( strlen(seqname).eq.0 ) then
	      call showtext(' No current filename')
	      return
	   else
	      call strcopy(outfname, seqname)
	   end if
	else
	   call strcopy(outfname, fname)
	end if

	if ( .not.nameok(outfname, newseq) ) then
	   call sprintf(oneline, ' Can''t write into "%s"!', outfname)
	   call showtext(oneline)
	   return
	end if

	s = start
	f = finish
	if ( s.eq.NOADDR ) s = 1
	if ( f.eq.NOADDR ) f = seqlen
	if ( f.gt.seqlen ) f = seqlen
	if ( s.gt.f .and. seqlen.ne.0 ) then
	   call showtext(' First address exceeds second')
	   return
	end if
	if ( s.lt.1 .or. ( f.lt.1  .and. seqlen.ne.0 ) ) then
	   call showtext(' Negative address - first base is 1')
	   return
	end if

	if ( .not.openf(outfile, outfname, 'w') ) then
	   call sprintf (oneline, ' Cannot write to file %s ', outfname)
	   call showtext(oneline)
	   return
	end if

	do i = 1, comlines
	   call writestring(outfile, comments(1,i))
	end do
	onebase = seq(f+1)
	seq(f+1) = NULL

* will include fname verison number on checksum line when version 
* number specified in the write command

	call writesq(outfile, seq(s), outfname,
     *			 comtable, position)
	seq(f+1) = onebase
	
	call closef(outfile)
	call strtolower(outfname)
	call strtolower(seqname)
	if ( strmatch(outfname,seqname) ) then
	   call endlog(logon, logfile)
	   call sqbeginlog(.false.)
	end if
	call sprintf(oneline,' "%s"  %d bases', outfname, f-s+1)
	call showtext(oneline)

	dowrite = .true.

	return
	end ! of dowrite

c **  dowq  *******************************************************************
c **
c **	do write and quit
c **
c *****************************************************************************
                     
	subroutine dowq( start, finish, fname )
	
	include 'commonlib(seqed)'

	integer start, finish
	character fname(*)

	logical dowrite

	if (strlen(fname).eq.0) then
	    if(strlen(seqname).eq.0) then
		call showtext(' No current filename')
		return 
	    else
		if ( .not.dowrite(start,finish,seqname) ) return
	    end if
	else
	    if ( .not.dowrite(start,finish,fname) ) return
	end if

	call doquit

	Return
      	end ! of dowq

c **  docheck  ****************************************************************
c **
c **	go into checking mode
c **
c *****************************************************************************

	subroutine docheck( start, argstr )
		
	include 'commonlib(seqed)'

	integer start
	character argstr(*)

	character oneline(132)

	if ( start.eq.NOADDR ) then
	    checkstart = 1
	else
	    checkstart = start
	end if
	if ( checkstart.lt.1 ) checkstart = 1
	if ( checkstart.gt.seqlen+1 ) checkstart = seqlen+1
	checkfinish = checkstart-1

	checking = .true.

	Blind = .false.

	if ( strlen(argstr).ne.0 ) then
	   call strsqueeze (argstr)
	   if ( argstr(1).eq.'/' ) then
	      call strcopy (oneline, argstr(2))
	      if ( cmdmatch('Blind', oneline) )   Blind = .true.
	   end if
	end if

	Strand = CHECKSTR

	return
	end ! of docheck


c **  readinit  ***************************************************************
c **
c **	this reads the seqinit file which allows the user to customize
c **	the translation of keystrokes when gels are entered.
c **
c **	here is a simple seqinit file:
c **
c **		this is the seqinit file format.  Coments can go here!
c **
c **					..
c **		Change a  into g
c **		Change f  into c
c **		Change t  into ^H
c **	      	Change y  into ^F
c **
c *****************************************************************************

	subroutine readinit
	
	include 'commonlib(seqed)'

	integer infile, inf
	character oneline(132), oneword(132), inchar, outchar
	character onechar
	integer i, length, pos, step

* make a conventional map for no remapping desired

	do i = 0, 255
	   charmap(i) = char(i)
	end do
	charmap(127) = DEL	! map delete to DELETE

	call strcopy (oneline, 'seqedinit.txt')
	if ( .not.getdatafile(infile, oneline) ) return

* if there is a local version of seqedinit.txt then use it to remap the 
* terminal keys
      
* first set all charmap's uwgcg sequence characters to a non-sense character

	do i = 1, 31
	   charmap(ichar(tolower(numtoalpha(i)))) = '~'
	   charmap(ichar(toupper(numtoalpha(i)))) = '~'
      	end do

	call skiptext(infile, '..')
	
	call readstring(infile, oneline, length)
	do while ( length.ge.0 )
	   if ( oneline(1).ne.'!' ) then
	      pos = 1
	      call strtoken(oneword, oneline, pos)
	      call strtoupper(oneword)
	      if ( strfind('CHANGE', oneword).eq.1 ) then
		 call strtoken(oneword, oneline, pos)
		 inchar = cchar(oneword)
		 call strtoken(oneword, oneline, pos) ! the into token
		 call strtoken(oneword, oneline, pos)
		 outchar = cchar(oneword)
		 charmap(ichar(inchar)) = outchar
	      end if
	   end if
	   call readstring(infile, oneline, length)
	end do
	
	call closef(infile)

* be sure the command characters are not remapped so the user doesn't get
* in a situation she can't control.
             
	call RefuseMap(CARRET, charmap)
      	call RefuseMap(NULL, charmap)
	call RefuseMap(':', charmap)
	call RefuseMap(CNTRLH, charmap)
	call RefuseMap(CNTRLR, charmap)
	call RefuseMap(CNTRLE, charmap)
	call RefuseMap(CNTRLZ, charmap)
	call RefuseMap('/', charmap)
	call RefuseMap('[', charmap)
	call RefuseMap(']', charmap)
	call RefuseMap('{', charmap)
	call RefuseMap('}', charmap)
	call RefuseMap('(', charmap)
	call RefuseMap(')', charmap)
	call RefuseMap(',', charmap)
	do step = 48, 57 ! the digits.
	   call RefuseMap(char(step), charmap)
	end do

	return
	end ! of readinit


*** RefuseMap *****************************************************************
*
*	refuses to remap the parameter character and complains if the user
*	if he did different.
*
******************************************************************************

	subroutine RefuseMap (ch, charmap)

	implicit none

	character ch, charmap(0:255)

	character oneline(256)

	if ( charmap(ichar(ch)).ne.ch ) then
     	   call sprintf(oneline, ' You have tried to remapped the'//
     *	       ' character key "%^c" but may not.', ch)
	   call beep(1)
	   call showtext (oneline)
	   call wait (2.0)
	   charmap(ichar(ch)) = ch
	end if

	return
	end ! of RefuseMap


c **  cmdmatch  ***************************************************************
c **
c **	this compares a string with a command and returns true if they 
c **	match.  The string can be shorter than the command but it must
c **	match all capital letters in cmdstr.
c **
c **
c *****************************************************************************

	function cmdmatch( cmdstr, string )

	include 'commonlib(seqed)'

	character cmdstr(*), string(*)
	integer pos

	if ( strlen(string).gt.strlen(cmdstr) ) then
	   cmdmatch = .false.
	   return
	end if

	pos = 1
	do while ( toupper(cmdstr(pos)) .eq. toupper(string(pos))
     *			.and. string(pos).ne.NULL )
  	     pos = pos+1
	end do

	if ( string(pos).ne.NULL ) then
	   cmdmatch = .false.
	   return
	end if

	if ( islower(cmdstr(pos)).or.cmdstr(pos).eq.NULL ) then
	   cmdmatch = .true.
	else
	   cmdmatch = .false.
	end if

	return
	end ! of cmdmatch

c **  delbases  ***************************************************************
c **
c **	Delete bases from the specified range in a sequence.  This does 
c **	no checking on the range.
c **
c *****************************************************************************

	integer function delbases( seq, len, start, finish )

	implicit none

	character seq(*)
	integer len, start, finish

	integer ipos, opos
	
	opos = start
	do ipos = finish+1, len
	    seq(opos) = seq(ipos) 
	    opos = opos+1
	end do

	delbases = len-(finish-start+1)

	return 
	end ! of delbases

c **  SQbeginlog  *************************************************************
c **
c **	this starts a new log file
c **	It is called by DoWrite and DoEdit.
c **
c *****************************************************************************

 	subroutine SQbeginlog( newseq )

	include 'commonlib(seqed)'

	logical newseq

	integer i, seqfile, checkfile
	character oneline (236)

	call openlog(logfile)

	if ( newseq ) then
	    call fprintf(logfile, 'new\n')
	    call fprintf(logfile, '0\n')
	else
	    call fprintf(logfile, 'old\n')
	    if ( .not. openf (seqfile, seqname, 'rdb') ) then
	       call sprintf (oneline, 
     *' Cannot open "%s" for reading (for log), check file protection.',
     *		 seqname)
	       call showtext(oneline)
	       call cleanup
	    end if
	    call fprintf(logfile, '%d\n', checkfile(seqfile) )
	    call closef(seqfile)
	end if

	call fprintf(logfile,'%s %d\n', seqname, checkseq(seq))

	logon = .true.

	return
	end ! of SQBeginLog

***  ShowDoc  *****************************************************************
*                                               
*	shows the first five lines of documentation on the 3-7 lines of 
* 	the screen.
*	Called by recover and doedit.
*
*******************************************************************************

	subroutine showdoc

	include 'commonlib(seqed)'

	integer line

	do line = 1, 4
	   call twgotoxy(0, line)
	   call twclrtoeol                       ! clear the line
	   if ( line.le.comlines ) then
	      call twgotoxy(4, line)
	      call twaddstr(': ')
	      call TwStopStr(comments(1,line), 74)
	      call twgotoxy(76, line)
	      call twaddstr(':')

*	      call twgoaddstr(8, line, ': ')
*	      call twaddstr(comments(1,line))    ! show the comment
	   end if
	end do

	return
	end ! of showdoc

***  getdoc  *****************************************************************
*
*
* --> THIS ROUTINE IS NO LONGER BEING USED.  THROW IT AWAY IF IT'S STILL
* --> NOT BEING USED.   Winsborough 10/9/85
*
*	gets indefinitely many lines of documentation from the user
*	displaying only the last four
*
*******************************************************************************

	subroutine getdoc

	include 'commonlib(seqed)'

	character oneline(132)

	integer row, FirstRow/1/

* clear the documentary part of the screen

	do row = FirstRow, FirstRow+4
	   call twgotoxy(0, row)
	   call twclrtoeol
	end do

* now get the documentation

	call strcopy(oneline, ' ')

	do while ( comlines.ne.1000      .and.
     *		   strlen(oneline).ne.0         )
	   row = min(FirstRow+4,comlines+FirstRow)
	   call twgotoxy(8, row)
	   call twaddstr(': ')
	   oneline(1) = NULL
	   call twgetstr(oneline)
	   comlines = comlines + 1

* not an issue since twgetstr limits string len to 125 characters
*	   if ( strlen(oneline).gt.131 ) then
*	      oneline(132) = NULL
*	      call beep(1)
*	      call showtext(' *** Line truncated to 131 characters@!
*    * ***')
*	   end if

	   call strcopy(comments(1,comlines), oneline)
	   if ( comlines.ge.5 .and. strlen(OneLine).gt.0 ) then
	      call twscroll(FirstRow+4, FirstRow, 0, 79)
	   end if

* remove last colon from screen

	   if ( strlen(oneline).eq.0 ) then
	      call TwGoToXY (8, row)
	      call TwClrToEol
	   end if

	end do

	comments(1,comlines) = NULL
	comlines = comlines - 1

	return
	end ! of getdoc


c **  doscreen  ***************************************************************
c **
c **	the screen mode loop for SEQED
c **
c *****************************************************************************

	subroutine doscreen

	include 'commonlib(seqed)'

  	character onechar, comchar, lastchar, oneline(132)
  	integer rep, step/1/, i

	Integer ArrowNum ! receives arrow code from TwArrow
	Integer Up/1/, Down/2/, Right/3/, Left/4/  
	Integer FirstCom, junk, NextCommentIndex, LastPos
	integer CurrX, CurrY
                    
  	lastchar = NULL
  	comchar = '%'
	LastPos = 0

*  	if ( checking ) then 
*	   strand = CHECKSTR
*	else 
*	   strand = ORIGSTR
*	end if

	do while ( comchar.ne.':' .and. comchar.ne.CNTRLZ )

    	    if ( strand.eq.CHECKSTR ) then
	        LastPos = seqpos
		seqpos = ilimit(checkstart, seqpos, checkfinish+1)
	    end if 

* update the screen

    	    call update
	    call findfirst(NextCommentIndex(seqpos), FirstCom, junk)
	    call DisplayComments (FirstCom)
	    

* get and map a new character

    	    comchar = TwGetCh(comchar)
    	    comchar = charmap(Ichar(comchar))

* clear off the showtext line

	   call TwGetXY (CurrX,CurrY)
	   call TwGoToXY (0,23)
	   call TwClrToEOL
	   call TwGoToXY (CurrX,CurrY)

* insert a sequence character at the current cursor position.
* If the last char is [ then we may have an incomplete arrow
* escape sequence and we can't print the character.

	    if ( comchar.eq.'~' ) then
	       call beep(1)

	    else if ( isuwgcg(comchar).and.LastChar.ne.'[') then
      	       if ( strand.eq.ORIGSTR ) then
                  call fprintf(logfile, 'i %d %c\n', seqpos, comchar)
                  seqlen = insertbase( seq, seqlen, seqpos, comchar )
		  if ( position(1).ne.-1 ) then
		     call comexpand(comtable, position, seqpos, 1)
	             call ComScale(0, 14, 79, 10, 4, scredge)
	          end if
		  if ( markloc(1).ne.-1 ) then
		     call markexpand(markloc, seqpos, 1)
		  end if

                  seqpos = seqpos + 1
               else  !  CHECKSTR
                  if ( seqpos.le.seqlen ) then
                     if ( seq(seqpos).ne.comchar ) call beep(1)
                     checkfinish = insertbase( chekseq, 
     *					  checkfinish, seqpos, comchar)
                     seqpos = seqpos + 1
	          else  ! off end
		     call beep(1)
                  end if
               end if

* or delete a base with the delete key

	    else if ( comchar.eq.DEL ) then
	       if ( isdigit(lastchar) ) then
		  rep = rep/10
               else if ( strand.eq.ORIGSTR ) then
                  if ( seqpos.gt.1 ) then
		     seqpos=seqpos-1
		     call dodelete(seqpos,seqpos)
                     if ( checking .and. seqpos.lt.checkstart ) then
		        checkfinish = delbases(chekseq, checkfinish,
     *							  seqpos, seqpos)
		        checkstart = checkstart-1
	             end if
	             if ( checking .and. checkfinish.gt.seqlen ) then
	                checkfinish = delbases(chekseq,
     *			checkfinish,checkfinish,checkfinish)
		     end if
                  end if
               else
                  if ( seqpos.gt.checkstart ) then
		     seqpos=seqpos-1
		     checkfinish = delbases(chekseq,
     *					checkfinish,seqpos,seqpos)
		  end if
               end if

* or move the cursor with the arrow keys

	    else if ( TwArrow(comchar, ArrowNum) .ne. 0) then
	       if ( isdigit(lastchar) ) then
		  step = rep
	       else
		  step = 1
	       end if
	       if ( ArrowNum .eq. Up ) then
		  if ( checking ) strand = CHECKSTR
	       else if ( ArrowNum .eq. Down ) then
		  if ( checking ) then
		     strand = ORIGSTR
		     if ( LastPos.ne.0 ) seqpos = Lastpos
		  end if
	       else if ( ArrowNum .eq. Right ) then
		  seqpos = ilimit (1, seqpos+step, seqlen+1)
	       else if ( ArrowNum .eq. Left ) then
		  seqpos = ilimit (1, seqpos-step, seqlen+1)
	       else
		  call showtext 
     *	(' error in return value from TwArrow in DoScreen')
		  call cleanup
	       end if

* or accumulate a number

            else if ( isdigit(comchar) ) then
              if ( .not.isdigit(lastchar) ) rep = 0
	      rep = 10 * rep + Ichar(comchar) - Ichar('0')
	      rep = min(rep, 100000)

* or find a pattern with the /xxxx syntax

            else if ( comchar.eq.'/' ) then
               call dofind

* or go to an absolute position with nnn<rtn>

            else if ( comchar.eq.CARRET ) then
                if ( isdigit(lastchar) ) seqpos=ilimit(1, rep, Seqlen+1)

* or go to the right or left 50 bases with > or <

            else if ( comchar.eq.'>' ) then
	       seqpos = Min(seqpos+50, seqlen+1)
            else if ( comchar.eq.'<' ) then
	       seqpos = Max(seqpos-50, 1)

* or move to the beginning or end of the sequence

	    else if ( comchar.eq.CNTRLH ) then  ! start of seq
		seqpos = 1

	    else if ( comchar.eq.CNTRLE ) then  ! end of seq
		seqpos = seqlen + 1

* or move the cursor to right or left n bases with nnn+ and nnn- syntax
* note that '+' is currently a UWGCG sequence character !!!

            else if ( comchar.eq.'-' ) then	
	       if ( isdigit(lastchar) ) seqpos=ilimit(1,seqpos-rep,seqlen+1)
            else if ( comchar.eq.'+' ) then	
	       if ( isdigit(lastchar) ) seqpos=ilimit(1,seqpos+rep,seqlen+1)

* or redraw the whole screen

	    else if ((comchar.eq.CNTRLL).or.(comchar.eq.CNTRLR)) then
	       call doredraw

* or go to a mark set by the user
	    else if (comchar.eq.'''') then
		onechar = TwGetCh (onechar)
		i = 0

		do while (markloc(i) .ne. -1 .and.
     *			  markchar(i) .ne. onechar .and.
     *			  i .le. 128)
		   i = i + 1
		end do

		if (markloc(i) .ne. -1) then
		   seqpos = ilimit(1, markloc(i), seqlen+1)
		end if
	    end if

* now remember the last character and zero last position

	lastchar = comchar
	LastPos = 0

	end do

	return
     	end ! of doscreen

***  domark  **************************************************************
*
*	This establishes marks set by the user.
*
***************************************************************************

	Subroutine domark (newmarkloc, newmarkchar)

	include 'commonlib(seqed)'

	integer newmarkloc
	character newmarkchar(*)

	character markch
	integer step
	character oneline(128)

	if (strlen(newmarkchar) .eq. 0) return

	if ( newmarkloc.eq.NOADDR ) then
	   newmarkloc = seqpos
	else
	   newmarkloc = ilimit(1, newmarkloc, seqlen+1)
	end if

	markch = cchar(newmarkchar)
	step = 1
	do while (step .le. 128 .and.
     *		  markchar(step) .ne. markch  .and.
     * 		  markloc(step) .ne. -1)
	   step = step + 1
	end do

* enter the new mark in sorted order to simplify actions necessary 
* upon insertion and deletion of sequence characters.

	if (markloc(step) .eq. -1) then
	    markloc(step+1) = -1

* find the right spot for the new mark and move everything else down

	    do while(step .gt. 1 .and.
     *		     markloc(step-1) .gt. newmarkloc)
		step = step - 1
		markloc (step+1) = markloc (step)
		markchar (step+1) = markchar (step)
	    end do

	    markloc(step) = newmarkloc
	    markchar(step) = markch

	else if (markchar(step) .eq. markch) then
	    markloc(step) = newmarkloc

	else 
	    call strcopy (oneline, 
     *		' Error in domark:  no more room in markchar array.')
	    call showtext (oneline)
	end if

	return
	end ! of domark


***  dodelete  ****************************************************************
*
*  	This deletes a range of the sequence.
*
*******************************************************************************

	Subroutine dodelete(start, finish)

	include 'commonlib(seqed)'

	integer start, finish

	integer s, f
	
	If ( start .eq. NOADDR .or. finish .eq. NOADDR ) then
           call showtext(' Specify the range you want to delete') 
        else if ( start.gt.finish ) then
           call showtext(' First address exceeds second')   
        else if ( start.lt.1 .or. finish.lt.1 ) then
           call showtext(' Negative address - first base is 1')
        else if ( start.le.seqlen ) then
           s = start
           f = min(seqlen, finish)
           call FPrintF(logfile, 'd %d %d\n', s, f)
           seqlen = delbases(seq, seqlen, s, f)
              
	   if ( position(1).ne.-1 ) then
	      call comcontract(comtable, position, s, f)
	      call ComScale(0, 14, 79, 10, 4, scredge)  
	   end if

	   if (markloc(1) .ne. -1)
     *		call markcontract (markchar, markloc, s, f)

	   seqpos = ilimit(1, seqpos, seqlen+1)

        end if

	Return
	end ! of dodelete


***  docomment  ****************************************************************
*
*  	Inserts a comment into the comtable at seqpos or start.
*	Start passes in the numeric parameter from the command line
*	specifying where the comment should go.  If none was specified,
*	the value in start is NOADDR and the current seqpos value 
*	(cursor position) is used.
*	Comstr is the argument from the command line.  It specifies the
*	comment to be added.  If no argument was on the command line,
*	the user is queried and her responce read into comstr.
*
*******************************************************************************

	Subroutine docomment(start, comstr)

	include 'commonlib(seqed)'

	integer start
	character comstr(*)

	integer len, s, cominsert, NewComIndex
	character oneline(256)

* find out where to insert the comment
	
	if ( start.eq.NOADDR ) then
	   s = seqpos
	else
	   s = ilimit(0, start, seqlen+1)
	   if ( s .ne. start ) then
	      call sprintf (oneline, 
     *' Position is off end of sequence.  Comment placed at:  %d', s)
	      call showtext (oneline)
	   end if
	end if
                       
	call strcompress(comstr)

* now insert it
                 
	NewComIndex = cominsert(comstr, s, comtable, position)

* adjust the ruler to indicate this comment position

	call comscale(0,14,79,10,4,scredge)

* either go to screen editing of comments or just check delimiters
* and update the log file

	if (strlen (comstr).eq.0) then
	   call EditCom(NewComIndex)
	else
	   call DelimCheck(ComTable(1, NewComIndex), s, seqlen)
	   call FPrintF(logfile, 'cominsert %d %s\n', s, 
     *				ComTable(1, NewComIndex))
	end if

	return
	end ! of docomment

***  DelimCheck  ********************************************************
*
*	Checks that its argument is a comment with legal delimiters and
*	changes it so that it is.
*	insures that if the comments is at either end it points inwards
*	since it makes no sence to have a >-comment on position 0.
*
*************************************************************************

	Subroutine DelimCheck (comstr, pos, length)

	Implicit None

	Character comstr(*)
	integer pos, length

	Character  FirstChar(64), LastChar(64), delim(64), NULL/0/
	Character  oneline (256)
	Integer len, strlen, step

	len = strlen(comstr)
	FirstChar(1) = comstr(1)
	Firstchar(2) = NULL
     	LastChar(1) = comstr(len)
	LastChar(2) = NULL

	if (   FirstChar(1).eq.'>' .or.
     *	       FirstChar(1).eq.'<' .or.
     *	       FirstChar(1).eq.'$'          ) then
	   if (FirstChar(1) .ne. LastChar(1)) 
     *	      call strconcat(comstr, FirstChar(1))

	else if ( LastChar(1) .eq. '>' .or.
     *	          LastChar(1) .eq. '<' .or.
     *	          LastChar(1) .eq. '$'       ) then
	   call strinsert(LastChar, comstr, 1)
              
	else  !  no delimiters on either end
	   delim(1) = NULL
	   do while (delim(1) .ne. '<' .and.
     *		     delim(1) .ne. '>' .and.
     *		     delim(1) .ne. '$'       )
	      delim(1) = NULL
	      call showtext(' what comment delimiter
     * >, <, or $ (* < *) ?  ')
	      call twgetstr(delim)
	      call strsqueeze(delim)
	      delim(2) = NULL
	      if ( strlen(delim).eq.0 ) then
	         delim(1) = '<'
	      end if
	   end do
	   call strinsert(delim, comstr, 1)
	   call strconcat(comstr, delim)
	end if

	if (len.eq.1) then  !  a single delimiter would mess things up
	   comstr(2) = comstr(1)
	   comstr(3) = NULL
	end if

* Now be sure that the comment delimiter points in a reasonable direction.

	if ( pos.eq.0 ) then
	   comstr(1) = '<'
	   comstr(strlen(comstr)) = '<'
	else if (pos.eq.length+1) then
	   if (comstr(1).eq.'<') then
	      comstr(1) = '>'
	      comstr(strlen(comstr)) = '>'
	   end if
	end if

* Be sure there are no embedded occurances of the delimiter.

	len = strlen(comstr)
	step = 2
	do while ( step.lt.len )
	   if ( comstr(step).eq.comstr(1) ) then
	      call StrChDel (comstr, step, len)
	      call beep(1)
	      call sprintf (oneline, 
     *	' The delimiter %c was deleted from the middle of the comment.',
     *		    comstr(1) )
	      call showtext (oneline)
	   else
	      step = step + 1
	   end if
	end do

	end ! of DelimCheck




c **  comscale  **************************************************************
c **
c **    This is a version of DrawScale which puts special characters 
c **	where comments occur.
c **	This draws a more complicated scale which has tics where there 
c **	are comments embedded in the sequence.
c **
c *****************************************************************************

	subroutine comscale( col, row, width, divs, offset, newedge )

	include 'commonlib(seqed)'

	integer col, row, width, divs, offset, newedge
	integer count
	integer step

	step = 1
	call twgotoxy(col,row)
	do count = 1, width
	    if ( mod(count-offset-1,divs).eq.0) then
	       do while (step .lt. 1000 .and. position(step) .ne. -1
     *		   .and. position(step) .lt. newedge-5+count) ! check expr
			step = step + 1
	       end do
	       if (position(step) .eq. newedge-5+count  .and.
     *		   position(step) .ne. -1) then
	          call twaddchar('i')
	       else
		  call twaddchar('l')
	       end if
	    else
	       do while (step .lt. 1000 .and. position(step) .ne. -1
     *		   .and. position(step) .lt. newedge-5+count) ! check expr
			step = step + 1
	       end do
	       if (position(step) .eq. newedge-5+count  .and.
     *		   position(step) .ne. -1) then
	          call twaddchar(':')
	       else
		  call twaddchar('.')
	       end if

	    end if
	end do

	return
	end ! of comscale

	


c **  update  *****************************************************************
c **
c **	updates and refreshes the screen consistent with seqlen, seq, 
c **	seqpos, etc, using its current ides of the screen scrseqlen, 
c **	scredge, scrscalelen, and scrbarlen
c **
c *****************************************************************************

	subroutine update

	include 'commonlib(seqed)'

	integer i, newedge, maxpos
	integer ScrBarPos, ScrSeqPos
	logical NewScale

* get the scaling for the big picture

	if ( seqlen.gt.scrscalelen ) then
	   scalelen = goodscalelen(seqlen)
	else
	   if ( seqlen.lt.scrscalelen/3 ) scalelen = goodscalelen(seqlen)
	end if


* put in the tildes

	if ( seqlen.ne.scrseqlen ) then
	   scrbarlen = drawbar(4, 18, scrbarlen, seqlen*71/scalelen)
	   scrseqlen = seqlen
	end if

* update the big picture scales

	NewScale = .false.
	if ( scalelen.ne.scrscalelen ) then
	   call numberscale(4, 20, 71, 7, 0, 0, scalelen/10)
	   scrscalelen = scalelen
	   NewScale  = .true.
	end if

* add circumflex to show current pos.

	If ( ScrSeqPos.ne.SeqPos ) then
	   If ( .not.NewScale ) then
              If ( ScrSeqPos .gt. ScrSeqLen ) then
	        Call TwGoAddStr( 4+ScrBarPos, 18, ' ')
	      Else
	        Call TwGoAddStr( 4+ScrBarPos, 18, '~')
	      End if
	   end if
	   If( Seqlen .gt. 0) then 
	     ScrBarPos = (SeqPos*ScrBarLen)/SeqLen
	   Else
	     ScrBarPos = 0
	   End if
	   Call TwGoAddStr( 4+ScrBarPos, 18, '^' )
	   ScrSeqPos = SeqPos
	end if

* set newedge if the cursor is too near the edge

	if ( seqpos.lt.scredge+10 ) then
	   newedge = max(0, 10*(seqpos/10-2))
	else
	   if ( seqpos.gt.scredge+60 ) then
	      newedge = 10*(seqpos/10-4)
	   else
	      newedge = scredge
	   end if
	end if

* and make new numbers below the sequence

	if ( newedge.ne.scredge ) then
	   call comscale (0, 14, 79, 10, 4, NewEdge)
	   call numberscale(0, 15, 80, 10, 4, newedge, 10)
	   scredge = newedge
	end if

* clear the main sequence

	call twgotoxy(0, 13)
	call twclrtoeol

* redraw the main sequence

	if ( strand.eq.ORIGSTR .or. .not.Blind ) then
	   maxpos = min(scredge+74, seqlen)
	   do i = scredge-4, maxpos
	      if ( i.lt.1 ) then
	         call twaddchar(' ')
	      else
	         call twaddchar(seq(i))
	      end if
	   end do
	end if

* now clear and renew the check sequence
	
	call twgotoxy(0,12)
	call twclrtoeol
	call twgotoxy(0, 11)
	call twclrtoeol

	if ( strand.eq.CHECKSTR .or. (.not.Blind .and. checking) ) then
	   call twgotoxy(0,11)
	   maxpos = min(scredge+74, checkfinish)
	   do i = scredge-4, maxpos
	      if ( i.lt.checkstart ) then
		 call twaddchar(' ')
	      else
		 call twaddchar(chekseq(i))
	      end if
	   end do
	   call twgotoxy(0,12)
	   do i = scredge-4, maxpos
	      if ( i.lt.checkstart ) then
		 call twaddchar(' ')
	      else
		 if ( seq(i).eq.chekseq(i) ) then
		    call twaddchar(' ')	
	    	 else
		    call twaddchar('^')
		 end if
	      end if
	   end do
	end if

* now put the cursor back where it belongs
	
	if ( strand.eq.ORIGSTR ) then
	   call twgotoxy(4+seqpos-scredge, 13)
	else
	   call twgotoxy(4+seqpos-scredge, 11)
	end if

* and refresh the screen

	if ( .not.morechars() ) call twrefresh

	return
	end ! of update

 

***  recover  *****************************************************************
*
*  	this recovers from an aborted session with SEQED.
*	
*******************************************************************************

	subroutine recover

	include 'commonlib(seqed)'

	integer  FILE, infile, inseq
	integer count, pos, s, f, i, newcheck, oldcheck, length, inclpos
	integer PosToken3
	character oneline(256), age(132)
	character token1(40), token2(40), token3(256)
	character token4(40), token5(40), token6(40)
	integer filecheck, checkfile, len, step, ComIndex
	logical okay
	integer st, fin  ! for incl recover
	logical rev      ! ditto
	integer linelen

	integer runit, xx
	logical database, dbisfile

	character errortext(256)

	logical DoNotLog/.false./  ! directive to doincl
  
* announce recovering and open log file

  	call showtext(' Recovering . . .')
	if ( .not.openf(infile, 'seqed.log', 'r') ) then
	   call showtext 
     *		(' Cannot open "seqed.log" to write recovery journal.')
	   call cleanup
	end if

* get the age of the sequence last edited

	pos = 1
	call readstring(infile, oneline, length)
	call strtoken(age, oneline, pos)

* and the checksum of the file so that comments will be sure to be the same.

	pos = 1
	call readstring (infile, oneline, length)
	call strtoken(token1, oneline, pos)
	if ( strtoint(token1, filecheck ) ) continue

* and the sequence checksum

	pos = 1
	call readstring(infile, oneline, length)
	call strtoken(seqname, oneline, pos)
	call strtoken(token1, oneline, pos)
	if ( strtoint(token1, oldcheck) ) continue

* show what sequence it was

	call twgoaddstr(0, 0, '              ')
	call twgoaddstr(0, 0, seqname)

* initialize postion

	do i = 1, 1000
	   position (i) = -1
	end do

* get the seq for an old file

	If ( strmatch(age, 'old') ) then

           If ( .not.openf(inseq, seqname, 'rdb') ) then
	      call sprintf(errortext,' Can''t open "%s" '//
     *			   'for recover!!', seqname)
              call showtext(errortext)
              call cleanup
	   end if

	   if ( .not. loadseq(inseq, seq, seqlen, newcheck,
     *			 	comtable, position) )      then
              call showtext (' The SEQED recover file is out of date. 
     * Delete seqed.log!')
              call cleanup
	   end if

	   if ( oldcheck.ne.newcheck .or.
     *		      filecheck.ne.checkfile(inseq) ) then
                 call showtext(' The SEQED recover file is out of date.
     *  Delete seqed.log!')
                 call cleanup
           end if

* XXX read the comments out of the sequence file
* get the heading, show the first 5 lines, save the first 999 lines

	   call rewindf(inseq)
	   if ( dbisfile(inseq) ) then
	      call dbgetunits(inseq, xx, runit, xx)
	      database = .true.
	   else
	      runit = inseq
	      database = .false.
	   end if
	   call readstring(runit, oneline, linelen)
	   do while( linelen.ge.0 .and. comlines.lt.999 .and.
     *		strfind('..', oneline).eq.0         )
	      if ( database .and. comlines.ne.0 .and.
     *		   oneline(1).eq.'>' ) go to 9999
	      comlines = comlines + 1
	      oneline(ILimit(1,linelen+1,256)) = NULL
	      call strcopy(comments(1,comlines), oneline)
	      comments(1,comlines+1) = NULL
	      call readstring(runit, oneline, linelen)
	   end do

9999	   continue

	   call closef(inseq)

	else   !  then it was a new sequence
	   seq(1)=NULL
	end if

* and modifiy the sequence and comments as per the log file instructions

	seqpos = 1
	call readstring(infile, oneline, length)
	do while( length.ge.0 ) 
	   pos = 1
	   call strtoken(token1, oneline, pos) 
	   call strtoken(token2, oneline, pos) 
	   do while (oneline(pos) .eq. ' ')
	      pos = pos + 1
	   end do
	   PosToken3 = pos
	   call strtoken(token3, oneline, pos) 
                                                 
* handle insertion of sequence elements

	   If ( strmatch('i', token1) ) then
               if ( .not.strtoint(token2,seqpos) ) then
                  call showtext(' Bad integer in recover log file!!')
                  call cleanup
               end if
               If ( .not.isuwgcg(token3) ) then
                  call showtext(' Bad symbol in recover log file!!')
                  call cleanup
               end if
	       seqlen = insertbase(seq, seqlen, seqpos, token3)
	       if ( position(1).ne.-1 )
     *	          call comexpand(comtable, position, seqpos, 1)

* handle sequence element deletes

           else if ( strmatch('d', token1) ) then
               If ( .not. ( strtoint(token2, s) .and.
     *			    strtoint(token3, f)       )  ) then
                  call showtext(' Bad integer in recover log file!!')
                  call cleanup
               end if
               seqlen = delbases(seq, seqlen, s, f)
	       if ( position(1).ne.-1 )
     *		  call comcontract(comtable, position, s, f)
               seqpos = s

* handle new comment inserts

	   else if (strmatch ('cominsert', token1) ) then
	      if (.not. strtoint (token2, seqpos) ) then
	         call showtext (' Bad integer in recover log file!!')
	         call cleanup
	      end if
	      call strcopy (token3, oneline(PosToken3))

* check the validity of the comment

	      len = StrLen(token3)
	      okay = .true.

	      if ( len.lt.2 ) then
	         okay = .false.
	      else if ( token3(1).ne.token3(len) ) then
	         okay = .false.
	      else if ( token3(1) .ne. '>'    .and.
     *                  token3(1) .ne. '<'    .and.
     *		        token3(1) .ne. '$'        ) then
	         okay = .false.
	      else 
	         step = 2
	         do while ( step.lt.len )
		    if ( token3(1).eq.token3(step) ) okay = .false.
		    step = step + 1
		 end do
	      end if

	      if ( .not.okay ) then
	         call showtext (' Bad comment in recover log file!!')
	         call cleanup
	      end if

* finally insert the comment

	      call cominsert (token3, seqpos, comtable, position)

* handle comment replacement

	   else if (strmatch ('comreplace', token1)) then

	      if (.not. strtoint (token2, ComIndex) ) then
	         call showtext (' Bad integer in recover log file!!')
	         call cleanup
	      end if
	      call strcopy (token3, oneline(PosToken3))

* check the validity of the comment

	      len = StrLen(token3)
	      okay = .true.

	      if ( len.lt.2 ) then
	         okay = .false.
	      else if ( token3(1).ne.token3(len) ) then
	         okay = .false.
	      else if ( token3(1) .ne. '>'    .and.
     *                  token3(1) .ne. '<'    .and.
     *		        token3(1) .ne. '$'        ) then
	         okay = .false.
	      else 
	         step = 2
	         do while ( step.lt.len )
		    if ( token3(1).eq.token3(step) ) okay = .false.
		    step = step + 1
		 end do
	      end if

	      if ( .not.okay ) then
	         call showtext (' Bad comment in recover log file!!')
	         call cleanup
	      end if

	      call strcopy ( ComTable(1, ComIndex), token3 )

* handle comment deletes

	   else if (strmatch ('comdelete', token1)) then

	      if (.not. strtoint (token2, ComIndex) ) then
	         call showtext (' Bad integer in recover log file!!')
	         call cleanup
	      end if

	      call comdel (comtable, position, ComIndex)

* handle includes

	   else if (strmatch ('incl', token1)) then
	      if (.not.strtoint(token2, inclpos)) then
	         call showtext (' Bad include in recover log file!!!')
	         call cleanup
	      end if 
	      call strtoken (token4, oneline, pos)
	      if (.not.strtoint(token4, st) ) then
		 call showtext ('  Bad include in recover log file!!!')
	      end if

	      call strtoken (token5, oneline, pos)
	      if (.not.strtoint(token5, fin) ) then
		 call showtext ('  Bad include in recover log file!!!')
	      end if

	      call strtoken (token6, oneline, pos)
	      call strcompress(token6)
	      rev = (strmatch(token6, 'Yes'))

	      call doincl (inclpos, token3, DoNotLog, st, fin, rev)

	   else if (strmatch ('heading', token1)) then
	      if (.not. strtoint (token2, comlines) ) then
	         call showtext (' Bad integer in recover log file!!')
	         call cleanup
	      end if

	      do i = 1, comlines
	         call readstring(infile, oneline, length) 
	         OneLine(132) = Char(0)
	         call strcopy(comments(1,i), oneline)
	      end do

           else
              call showtext(
     *		' Unrecognized command in recover log file!!')
              call cleanup
	   end if
	   call readstring(infile, oneline, length)
  	end do
	seq(seqlen+1) = NULL

* close the log file for reading

	call closef(infile)

* and reopen it "write-append"

	If ( .not.openf (logfile, 'seqed.log', 'wa') ) then
           call showtext(' The SEQED logfile can''t be appended')
           call cleanup
        end if

	call ShowDoc

	call comscale(0,14,79,10,4,scredge)

	Strand = ORIGSTR

	logon = .TRUE.
	call showtext(' Recovery complete')

	return
	end ! of recover


***  EditCom  *********************************************************
*
*	This allows screen oriented editting of comments.
*
***********************************************************************

	Subroutine EditCom (CurrentCom)

	Include 'Commonlib(SeqEd)'

	integer CurrentCom

	Integer TwGetStr, ReturnCode, FirstCom, ActScrLine
	Integer UP/1/, DOWN/2/, RET/5/, CTLZ/6/
	Logical ComDeleted, NewCom
	Character oneline(132), token(132), oldcomment(132)
	Character debugstr(128)  ! debug
	Integer basenumber, cominsert, junk, One, pos


	call FindFirst (CurrentCom, FirstCom, ActScrLine)
	call DisplayComments (FirstCom)

	ReturnCode = 0
	NewCom = .true.

	Do while ( ReturnCode.ne.CTLZ .and.
     *	           ReturnCode.ne.RET  .and.
     *		   Position(1).ne.-1        )

	   ComDeleted = .false.

	   call strcopy(oldcomment, ComTable(1, CurrentCom))

	   call TwGoToXY (10, ActScrLine+6)
	   ReturnCode = TwGetStr (ComTable(1, CurrentCom))

	   if ( StrLen(ComTable(1, CurrentCom)).eq.0 ) then
	      call ComDel (ComTable, Position, CurrentCom)
	      ComDeleted = .true.
	      call ComScale(0, 14, 79, 10, 4, scredge)
	      if ( .not.NewCom ) then
		 call fprintf(logfile, 'comdelete %d\n', CurrentCom)
	      end if 
	   else
	      call DelimCheck (ComTable(1,CurrentCom), 
     *		Position(CurrentCom), Seqlen)
	      if ( .not.StrMatch(oldcomment, 
     *		              ComTable(1, CurrentCom)) ) then
		 if ( NewCom ) then 
		    call fprintf(logfile, 'cominsert %d %s\n',
     *			Position(CurrentCom), ComTable(1, CurrentCom) )
		 else
	            call fprintf(logfile, 'comreplace %d %s\n', 
     *				CurrentCom, ComTable(1, CurrentCom) )
		 end if
	      end if
	   end if 

	   NewCom = .false.

	   if (ReturnCode.eq.DOWN) then
	      if ( Position (CurrentCom + 1).ne.-1 .and.
     *		   .not.ComDeleted                      ) then
	         CurrentCom = CurrentCom + 1
	      end if
	      if ( Position (CurrentCom).eq.-1 .and.
     *		                     CurrentCom.gt.1 ) ! last com was deleted.
     *		 CurrentCom = CurrentCom - 1
	   end if

	   if (ReturnCode.eq.UP .and.
     *	       CurrentCom.ne.1           ) then
	         CurrentCom = CurrentCom - 1
	   end if

	   if (position(CurrentCom).ne.-1) seqpos = Position(CurrentCom)

	   call update

	   call FindFirst (CurrentCom, FirstCom, ActScrLine)
	   call DisplayComments (FirstCom)
              
	   if ( .not.morechars() ) call twrefresh

	end do

	return
	end ! of EditCom


***  FindFirst  *************************************************
*
*	Given the current position this returns the index to the
*	first of the four comment lines which will be displayed.
*	If there is a comment at the current position, the last 
*	argument, ActScrLine, will return the number of the line
*	(0-3) upon which that comment will appear.
*
*****************************************************************

	Subroutine FindFirst (CurrentPos, FirstCom, ActScrLine)

	Include 'commonlib(SeqEd)'

	Integer CurrentPos, FirstCom, ActScrLine
	Integer X,Y  		! debug
	Character oneline(132)  ! debug  

	Integer LastPos /0/
	Save LastPos

	if (CurrentPos.eq.0) then
	   FirstCom = 0
	   return
	end if

	if (CurrentPos.ge.LastPos) then
	   FirstCom = CurrentPos - 2
	   ActScrLine = 2
	else
	   FirstCom = CurrentPos - 1
	   ActScrLine = 1
	end if

	LastPos = CurrentPos

	do while ((Position(FirstCom+3).eq.-1).or.(FirstCom+3.gt.1000))
	   FirstCom = FirstCom - 1
	   ActScrLine = ActScrLine + 1
	end do

	do while (FirstCom.lt.1)
	   FirstCom = FirstCom + 1
	   ActScrLine = ActScrLine - 1
	end do

*  Check for errors in code.  ActScrLine may be as large as 4 because 
*  the current position may be larger than the position of any comment.

	if (ActScrLine.lt.0 .or. ActScrLine.gt.4) then
	   call showtext('Error in FindFirst.')
	   call cleanup
	end if 

* DEBUG:
*	call twgetxy (X,Y)
*	call twgotoXY (0,23)
*	call twclrtoeol
*	call sprintf (oneline, 'Curr: %d, FirstCom: %d, ActScrLine: %d',
*     *		CurrentPos, FirstCom, ActScrLine)
*	call twaddstr(oneline)
*	call twgotoXY (X,Y)

	return
	end ! of FindFirst


***  DisplayComments  ******************************************************
*
*	displays the comments starting at the index given in the argument.
*	Screws up current currsor position.
*
***************************************************************************

	Subroutine DisplayComments (FirstCom)

	Include 'Commonlib(SeqEd)'

	Integer FirstCom

	Integer Step, X, Y
	Character oneline (152)

* DEBUG:
*	call twgetxy (X,Y)
*	call twgotoXY (50,23)
*	call sprintf (oneline, 'FirstCom in DisplayCom: %d', 
*     *		 FirstCom)
*	call twaddstr(oneline)
*	call twgotoXY (X,Y)

	if (FirstCom.eq.0) return

	call twgetxy (X, Y)

	Step = 0
	Do while ( Step.le.3 )
	      call twgotoxy (0, 6+step)  ! comments start line 6 (nums: 0-23)
	      call twclrtoeol
	   if ( FirstCom+Step.le.1000 .and.
     *		  Position(FirstCom+Step).ne.-1) then
	      call sprintf (oneline, '   %6d %s', 
     *		 position(FirstCom+Step), comtable(1, FirstCom+Step))
	      call twaddstr (oneline) 
	   end if
	   Step = Step + 1
	end do

	call twgotoxy (X, Y)

	if ( .not.morechars() ) call twrefresh

	return
	end ! of DisplayComments


***  NextCommentIndex ************************************************
*
*	Used to find the first index of the comment in ComTable at or 
*	following the argument's sequence position.  Zero is returned
*	if no such comment exists.
*
*************************************************************************

	Integer Function NextCommentIndex ( pos )

	Include 'commonlib(SeqEd)'

	Integer pos

	Integer X,Y  ! debug
	character oneline (132)  ! debug

	integer abv/1/, LastPos/0/
	save abv, LastPos

	if ( position(abv).lt.pos .and.
     *	     position(abv).ne.-1        ) then
	   do while ( position(abv).ne.-1  .and.
     *		      position(abv).lt.pos       )
	      abv = abv + 1
	   end do
	else
	   do while ( abv.gt.1       .and.
     *	     ( position(abv-1).ge.pos .or. position(abv-1).eq.-1 ) )
	      abv = abv - 1
	   end do
	end if

*  If the direction of motion is negative then make the return value the 
*  largest index of a position <= the current seqpos (the input 
*  parameter).

	if ( pos.lt.LastPos ) then 
	   do while ( position(abv).gt.pos )
	      abv = abv - 1
	   end do
	end if

* if abv's value is zero but there are comments in the table, make abv 1

	if ( abv.eq.0 .and. position(1).ne.-1 ) abv = 1

	LastPos = pos

	NextCommentIndex = abv

* DEBUG:
*	call twgetxy (X,Y)
*	call twgotoXY (45,22)
*	call twclrtoeol
*	call sprintf (oneline, 'In NextCom pos: %d, abv: %d', pos, abv)
*	call twaddstr(oneline)
*	call twgotoXY (X,Y)


	return
	end ! of NextCommentIndex

c **  doincl  *****************************************************************
c **         
c **	reads a sequence from the file specified by the user.  loads it 
c **	into the sequence currently being edited before inclpos 
c **	(default inclpos value is seqpos).  A temporary buffer is used
c **	to simplify the process and make it more flexible.
c **
c *****************************************************************************

	subroutine doincl( inclpos, fname, IsUserCall, st, fin, rev )

	include 'commonlib(seqed)'

	character fname(*)	! name of file holding new sequence
	integer inclpos		! position in current seq before which to add
	logical IsUserCall	! indicate whether call was made by recover
* the following parameters are only of interest when IsUserCall.eq..false.
	integer st, fin		! start and finish
	logical rev		! should reverse

  	integer seqfile
  	integer linelen, i, row, check	! ???
  	character oneline(256)		! ???
	character locseq (100 001), inclseq (100 001)
	integer locseqlen, inclseqlen
	character LocComTable (128, 1000)
	integer locposition (1000)
	integer NumNewComs, NumOldComs, InclComLoc, FirstCom, LastCom
	logical newseq
	integer start, finish, offset
	logical reverse
	character numstr(132)
	character temp
	logical yes
	integer GetFragment  ! function
	Logical GetReverse, GetYesNo  ! function


	do while (strlen(fname) .eq. 0)
	   call showtext (' SEDED include of what file ?  ')
	   call twgotoxy(30,23)
	   call twgetstr(fname)
	end do

	call strsqueeze(fname)

	if ( .not.nameok(fname, newseq) ) then
	   call sprintf(oneline, ' Illegal include file name. ')
	   call showtext(oneline)
	   if (IsUserCall) then
	      return
	   else
	      call cleanup
	   end if                 
	end if

	if (newseq) then
	   call sprintf(oneline,
     *       ' Include file: "%s" does not exist.', fname)
	   call showtext (oneline)
	   if (IsUserCall) then
	      return
	   else
	      call cleanup
	   end if
	end if

	checking = .false.
	if (inclpos .eq. NoADDR) inclpos = seqpos

	if ( .not. openf(seqfile, fname, 'rdb') ) then
	   call sprintf( oneline, ' Cannot open file "%s" for include.')
	   call showtext (oneline)
	   if ( IsUserCall ) then
	      return
	   else
	      call cleanup
	   end if
	end if

* hose down the user if the seqfile is not in UWGCG format

	if ( .not.loadseq(seqfile, locseq, locseqlen, check,
     *				 loccomtable, locposition)     ) then
	   call beep(1)
	   call sprintf(oneline, 
     *	      ' Include file: "%s" is not a sequence file in UWGCG 
     *format!', fname)
	   call showtext(oneline)
	   call closef (seqfile)
	   if (IsUserCall) then
	      return
	   else
	      call cleanup
	   end if
	end if
                                
	call closef(seqfile)

*  determine fragment of strand to be included and whether to reverse it.

	If (IsUserCall) then

	   if (locseqlen.eq.0) then
	      call showtext
     *	(' The sequence you specified is empty and cannot be included.')
	      return
	   end if


	   call clearscreen

	   call sprintf (oneline, 
     *		'\n                   SEQED include of %s\n\n', fname)
	   call printf (oneline)

	   InclSeqLen = GetFragment(inclseq, locseq, locseqlen, 
     *                           start, finish)

	   if ( GetReverse( reverse ) ) then
	      call RevSeq ( inclseq, 1, InclSeqLen)
	   end if

	   if ( finish.le.60 ) then
	      call PrintF ('\n Fragment to be included:  %s\n', inclseq)
	   else 
	      temp = inclseq (51)
	      inclseq(51) = NULL
	      call PrintF ('\n First 50 bases:  %s\n', inclseq)
	      inclseq(51) = temp
	      call PrintF ('\n Last %d bases:  %s\n', 
     *		 Min (50,finish-(start-1)-50), 
     *		 inclseq(Max(50,finish-(start-1)-49)))
	   end if
                                            
	   call printf (
     *	      '\n Is this what you want included  (* Yes *)  ?  ')
	   yes = .true.

	   if ( .not.GetYesNo (yes) ) then
	      call twtouch
	      call twrefresh
	      return
	   end if

	   call twtouch
	   call twrefresh

	else
	   start = st
	   finish = fin
	   if (start.lt.1 .or. start.gt.locseqlen .or. finish.lt.1 .or.
     *				finish.gt.locseqlen) then
	      call showtext ('  Bad included in recover sequence file.')
	      call cleanup
	   end if

	   reverse = rev
	   If ( start.gt.finish ) then
	      Do i = start, locseqlen
	         inclseq(i-start+1) = locseq(i)
	      End Do
	      Offset = locseqlen - start + 1
	      Do i = 1, finish
	         inclseq(i+Offset) = locseq(i)
	      End Do
	      InclSeqLen = offset + i - 1
	   Else if ( start.le.finish ) then
	      Do i = start, finish
	         inclseq(i-start+1) = locseq(i)
	      End Do
	      InclSeqLen = finish - start + 1
	   End If
	   inclseq(InclSeqLen+1) = Char(0)
	end if  ! IsUserCall



* complain if the sequence included makes the current sequence too large.

	if (seqlen + (finish - start + 1) .gt. 100 000) then
	   call sprintf (oneline,
     *	      ' Include sequence: "%s" too long to be included!', fname)
	   call showtext (oneline)
	   if (IsUserCall) then
	      return
	   else
	      call cleanup
	   end if
	end if

* or just tell him about a successful read

	if (IsUserCall) then
	   if (reverse) then
	      call sprintf(oneline, 
     *	      ' included reverse of: "%s"  from: %d to: %d  at pos: %d',
     *		fname, start, finish, inclpos)
	   else
	      call sprintf(oneline, 
     *		' included: "%s"  from: %d to: %d  at pos: %d',
     *		fname, start, finish, inclpos)
	   end if
	call showtext(oneline)
	end if ! IsUserCall

C include the buffered sequence and embedded comments in the main 
C sequence info.

	i = 1
	do while (i .lt. 999 .and. locposition(i).lt.start .and.
     *						locposition(i) .ne. -1)
	   i = i + 1
	end do
	FirstCom = i

	do while (i.lt.999 .and. locposition(i).le.finish .and.
     *						locposition(i) .ne. -1)
	   i = i + 1
	end do
	LastCom = i - 1

	NumNewComs = LastCom -  FirstCom + 1

	i = 1
	do while (i .lt. 999 .and. position(i) .ne. -1)
	   i = i + 1                                               
	end do
	NumOldComs = i - 1

* Adjust the embedded comment positions to allow for new inclusion.

	call comexpand (comtable, position, inclpos, InclSeqLen)

* find out whether there is room for the new comments

	if (NumNewComs + NumOldComs .le. 999) then
	   i = 1
	   do while (i .lt. 999 .and. position(i) .ne. -1 .and.
     *		     position(i) .lt. inclpos+inclseqlen)
	      i = i + 1
	   end do
	   InclComLoc = i

* Open a gap for the new comments

	   do i = NumOldComs, InclComLoc, -1
	      Position(i+NumNewComs+2) = Position(i)
	      call strcopy (ComTable(1,i+NumNewComs+2), ComTable(1,i))
	   end do

* put new comments in

	   if (reverse) then
	      do i = 1, NumNewComs
	         Position (i+InclComLoc) = 
     *	   	     inclpos-1 + InclSeqLen - 
     *		  (LocPosition((FirstCom-1)+(NumNewComs-(i-1)))-Start)

	         call strcopy (ComTable(1, i+InclComLoc), 
     *		         LocComTable(1,(FirstCom-1)+NumNewComs-(i-1)) )
	      end do
	   else
	      do i = 1, NumNewComs 
	         Position (i+InclComLoc) = 
     *	   	    LocPosition((FirstCom - 1) + i) - Start + inclpos

	         call strcopy (ComTable(1, i+InclComLoc), 
     *		            LocComTable(1,(FirstCom - 1) + i))
	      end do
	   end if

* put in an automatically generated comment at each end of the included 
* stuff marking the addition of this include file.  The first one goes 
* on the first base in the included section, the second goes on the first 
* base after the included section.

	   if (reverse) then
	      call sprintf(oneline,
     *	          '>SEQED (include) reverse of:  %s
     *  check:  %d  from:  %d  to: %d>',
     *		 fname, check, start, finish)
	   else
	     call sprintf(oneline,
     *	     '>SEQED (include) of:  %s  check:  %d  from:  %d  to: %d>',
     *		 fname, check, start, finish)
	   end if

	   Position (InclComLoc) = inclpos
	   call strcopy (ComTable(1, IncLComLoc), oneline)

	   if (reverse) then
	      call sprintf(oneline,
     *	     '<SEQED (include) reverse of: %s
     *  check: %d  from: %d  to: %d<',
     *		 fname, check, start, finish)
	   else
	      call sprintf(oneline,
     *	     '<SEQED (include) of: %s  check: %d  from: %d  to: %d<',
     *		 fname, check, start, finish)
	   end if

	   Position (InclComLoc + NumNewComs + 1) = 
     *		   				inclpos + inclseqlen - 1
	   call strcopy (ComTable(1, IncLComLoc + NumNewComs + 1),
     *						 oneline)

	   Position (NumOldComs + NumNewComs + 3) = -1

	else  ! can't incl all comments.  Still put in incl seq locators
	   if (NumOldComs+3.lt.999) then

	      i = 1
	      do while (i .lt. 999 .and. position(i) .ne. -1 .and.
     *		     position(i) .lt. inclpos+inclseqlen)
	         i = i + 1
	      end do
	      InclComLoc = i

	      do i = NumOldComs, InclComLoc, -1
	         Position(i+3) = Position(i)
	         call strcopy (ComTable(1,i+3), ComTable(1,i))
	      end do

* put in an automatically generated comment at each end of the included 
* stuff marking the addition of this include file.  The first one goes 
* on the first base in the included section, the second goes on the first 
* base after the included section.

	      if (reverse) then
	         call sprintf(oneline,
     *	             '>SEQED (include) reverse of:  %s
     *  check:  %d  from:  %d  to: %d>',
     *	   	 fname, check, start, finish)
	      else
	        call sprintf(oneline,
     *	     '>SEQED (include) of:  %s  check:  %d  from:  %d  to: %d>',
     *		 fname, check, start, finish)
	      end if

	      Position (InclComLoc) = inclpos
	      call strcopy (ComTable(1, IncLComLoc), oneline)

	      call sprintf(oneline, 
     *'>SEQED was unable to include the embedded comments "%s".>',
     *  	   		fname)
	      Position(InclComLoc + 1) = inclpos
	      call strcopy (ComTable(1, InclComLoc + 1), oneline)

	      if (reverse) then
	         call sprintf(oneline,
     *	        '<SEQED (include) reverse of: %s
     *  check: %d  from: %d  to: %d<',
     *	   	    fname, check, start, finish)
	      else
	         call sprintf(oneline,
     *	     '<SEQED (include) of: %s  check: %d  from: %d  to: %d<',
     *		 fname, check, start, finish)
	      end if

	      Position (InclComLoc + 2) = inclpos + inclseqlen
	      call strcopy (ComTable(1, InclComLoc + 2), oneline)

	      Position(NumOldComs + 3) = -1
	   else
	      call wait (2.0)
	      call sprintf (oneline, 
     *    ' Lost embedded comments in %s due to insufficient storage.',
     *	    fname)
	      call showtext (oneline)
	   end if
	end if

*  Load in new sequence data

	do i = seqlen, inclpos, -1
	   seq(i + inclseqlen) = seq(i)
	end do

	do i = 1, inclseqlen
	   seq(inclpos + i - 1) = inclseq(i)
	end do

* adjust any marks.

	call markexpand (markloc, inclpos, inclseqlen)

* update sequence length

	seqlen = seqlen + inclseqlen
	seqpos = inclpos + inclseqlen

	call ComScale(0, 14, 79, 10, 4, scredge)
	
	call twrefresh

	if (IsUserCall) 
     *		call fprintf (logfile, 'incl %d %s %d %d %b\n', 
     *  	inclpos, fname, start, finish, reverse )

	return
	end ! doincl


**  Subroutine DoHeading  ************************************************
*
*	This routine allows the user to edit the heading comments.
*	It is primarily a call to TwTextEdit.
*
**************************************************************************

	subroutine DoHeading (start)

	include 'commonlib(seqed)'
	
	integer start

	integer step
	integer TwTextEdit  ! function

	do step = 1, 4
	   call TwGoToXY(4,step)
	   call TwAddStr (':')
	   call TwGoToXY (76,step)
	   call TwAddStr (':')
	end do

	ComLines = TwTextEdit (comments,1000,comlines,start,6,74,1,4)

	call DelDelims (comments, comlines, 1000)

	call fprintf(logfile, 'heading %d\n', comlines)

	do step = 1, comlines
	    call fprintf(logfile, '%s\n', comments(1,step))
	end do


	return
	end ! of DoHeading

***  DelDelims  ***************************************************
*
*	This routine ensures that no comment contains the .. delimiter
*	so as not to confuse sequence readers.  Any adjacent pairs of 
*	periods are separated by a space.
*
*******************************************************************

	subroutine DelDelims (comments, comlines, NumRows)

	Implicit None

	character comments (256,*)
	integer comlines, NumRows

	integer line, pos, len
	integer strlen  !  function
	character NULL

	parameter ( NULL=char(0) )


	do line = 1, comlines
	   pos = 1
	   do while (comments(pos,line).ne.NULL) 
	      if ( comments(pos,  line).eq.'.' .and. 
     *		   comments(pos+1,line).eq.'.'      ) then
		 comments(254,line) = NULL ! incase must truncate
		 len = strlen(comments(1,line))
	         call StrChInsert (comments(1,line), ' ', pos+1, len)
		 call showtext ('Adjacent periods separated by a space')
		 pos = pos + 1
	      end if
	      pos = pos + 1
	   end do
	end do

	return
	end ! of DelDelims



***  DoFind  **************************************************************
*
*	gets a search pattern from the user and finds it in the sequence
*	supporting ambiguity codes if appropriate.
*	Because it would require verification that no change has been made
*	to the sequence, this routine never reuses cuts, even if the pattern
*	is reused.
*
***************************************************************************

	Subroutine DoFind

	include 'CommonLib(seqed)'
                                                               
	character TempSeq(-100:100 101), Cuts(100 000), EnzDesc(50)
	character oneline (256), copypattern(41)
	integer step, NumCuts
	integer loc, oldseqpos
	logical PerfectMatch

	integer AddCuts	   ! function
     	logical PatReverse ! function

	if ( IsNucleotide ) then
	   call showtext (' Enter Nucleotide search pattern')
	else
	   call showtext (' Enter Perfect match search pattern')
	end if

	call twgoaddchar(1,22, '/')
	call mapgetstr(oneline, charmap)
	call strsqueeze (oneline)

	if ( strlen(oneline).eq.0 ) then  ! pattern is old
	   if ( strlen(findseq).eq.0 ) then
	      call showtext (' No previous pattern')
	      call TwGoToXY (1,22)
	      call TwClrToEOL
	      return
	   end if

	   call twaddstr (findseq)
	   call twrefresh
	else
	   if ( strlen(oneline).gt.40 ) then
	      call showtext 
     *	      	(' Pattern cannot be more than 40 characters long.')
	      call TwGoToXY (1,22)
	      call TwClrToEOL
	      return
	   end if

	   call strcopy (findseq,oneline)
	end if

	seq(seqlen+1) = NULL

* check to see if the user wants a perfect match

	if ( findseq(1).eq.'=' ) then
	   PerfectMatch = .true.
	   call StrCopy (findseq, findseq(2))
	else
	   PerfectMatch = .false.
	end if

	if ( IsNucleotide .and. .not.PerfectMatch ) then

* first be sure the pattern is okay.

	   call strcopy (copypattern, findseq)
	   if ( .not. PatReverse(copypattern) ) then
	      call TwTouch
	      call TwRefresh
	      call showtext (' Illegal search pattern')
	      call TwGoToXY (0,22)
	      call TwClrToEOL
	      return
	   end if

	   call StrCopy (TempSeq(1), Seq)
	   call Circularize (TempSeq(-100), TempSeq(1))
	   call StrToUpper (TempSeq(-100))
	   call SeqToCode (TempSeq(-100))
	   call ClearCuts (cuts, 1, seqlen)
	   call StrCopy (EnzDesc(7), findseq)
	   EnzDesc(48) = NULL
	   EnzDesc(49) = Char (129)
	   EnzDesc(50) = Char (1)
	   NumCuts = AddCuts (TempSeq(-100), 1, seqlen, EnzDesc, Cuts,
     *		0, .true., .false., .true.)
	   NumCuts = NumCuts + AddCuts (TempSeq(-100), 1, seqlen, 
     *		EnzDesc, Cuts, 0, .true., .true., .false.)
	   NumCuts = NumCuts + AddCuts (TempSeq(-100), 1, seqlen, 
     *		EnzDesc, Cuts, 0, .true., .false., .false.)
                                          
	   if ( NumCuts.eq.0 ) then
	      call ShowText 
     *		(' Nucleotide code match:  Pattern not found.')
	      call TwGoToXY (1,22)
	      call TwClrToEOL
	      return
	   else
	      step = seqpos + 1
	      do while ( step.le.seqlen .and. cuts(step).eq.NULL )
	         step = step + 1
	      end do

	      if ( step.le.seqlen ) then
	      	 seqpos = step
	      else
		 step = 1
		 do while ( step.lt.seqpos .and. cuts(step).eq.NULL )
		    step = step + 1
		 end do
		 if ( step.lt.seqpos ) then
		    seqpos = step
		 else
		    call sprintf  (oneline, 
     *		      ' Nucleotide code search:  Pattern %s NOT found.',
     *		      findseq)
		    call showtext (oneline)
	            call TwGoToXY (1,22)
	            call TwClrToEOL
		    return
		 end if
	      end if
	      call sprintf (oneline, 
     *		' Nucleotide code search:  Pattern %s found.', findseq)
	      call showtext (oneline)
	   end if ! NumCuts is Zero

	else ! is not a nucleotide sequence
	   oldseqpos = seqpos
	   seqpos = seqpos + 1       
	   if ( seqpos.gt.seqlen ) seqpos = 1
	   loc = cistrfind (findseq,seq(seqpos))

	   if ( loc.gt.0 ) then
	      seqpos = seqpos + loc - 1
	   else
	      loc = cistrfind(findseq,seq)
	      if ( loc.gt.0 ) then
		 seqpos = loc
	      else
		 call sprintf (oneline, 
     *		    ' Perfect match:  Pattern %s NOT found.', findseq)
		 call showtext (oneline)
		 seqpos = oldseqpos
	      end if
	   end if

	   call sprintf (oneline, ' Perfect match:  Pattern %s found.',
     *		findseq)
	   call showtext (oneline)

	end if ! not a Nucleotide seq.

	call TwGoToXY (1,22)
	call TwClrToEOL
	return
	end ! of dofind
              
