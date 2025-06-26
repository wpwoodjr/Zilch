# ARCHIVE CDEFIO.                 10  16-MAY-83 13:29:03
#----------------------------------------------------------------------
# preprocessor common block to hold input characters
# Put on a file called 'cdefio'
# Used by ratfiv preprocessor and macro

 common /cdefio/ bp, bplow, bpsave(NFILES), buf(BUFSIZE)
   integer bp           # next available character; init = 0
   integer bplow	# bottom of push-back buffer at current file level
   integer bpsave	# holds bplow for active file levels
   character buf        # pushed-back characters
# ARCHIVE CERRBF.                  3  16-MAY-83 13:29:03
# cerrbf - holds an error message for later output by synerr
  common /cerrbf/ errbuf(MAXTOK)
  character errbuf
# ARCHIVE CLINE.                  14  16-MAY-83 13:29:03
#-----------------------------------------------------------------------
# preprocessor common block to hold info about lines and included files
# put on a file named 'cline'
# used by ratfiv preproccessor and macro

  common /cline/ level, infile(NFILES), linect(NFILES), fnamp(NFILES),
		 fnames(MAXFNAMES), ioin(MAXLINE)

    integer level        # level of file inclusion; init = 1
    integer infile       # file number(level); init infile(1) = STDIN
    integer linect       # line count on input file(level); init = 1
    integer fnamp        # next free slot in fnames
    character fnames     # stack of open file names
    character ioin	 # input buffer
# ARCHIVE CLOOK.                  10  16-MAY-83 13:29:03
 #--------------------------------------------------------------------
 ## preprocessor common block to hold definitions
 # put on a file named 'clook'
 # Used by ratfiv preprocessor, macro, and form tools
 
 common /clook/ avail, tabptr(127), table(MAXTBL)
 
        integer avail   #first location in table; init = 1
        integer tabptr  #name poiners; init = 0
        character table   #actual text of names and definitions
# ARCHIVE CMACRO.                 15  16-MAY-83 13:29:04
 # -cmacro- common block
 # put on a file called 'cmacro'
 # Used only by the macro tool
 
 common /cmacro/ cp, ep, evalst(EVALSIZE), defcnt, defstk(DEFSTACKSIZE),
		 ap, argstk(ARGSIZE), callst(CALLSIZE), plev(CALLSIZE)
    integer cp         # current call stack pointer
    integer ep         # next free position in evalst
    character evalst   # evaluation stack
    logical defcnt     # depth of _ifdef nesting
    logical defstk     # remembers status of _ifdef levels
    integer ap	       # pointer to next available space in argstk
    integer argstk     # pointers to evalst
    integer callst     # points to invocation frames in argstk
    integer plev       # parenthesis level at current invocation frame
# ARCHIVE FAC.M                    1  16-MAY-83 13:24:58
_macro(fac,_ifelse($1,0,1,_arith($1,*,fac(_arith($1,-,1)))))
# ARCHIVE LISP.M                   6  16-MAY-83 13:24:58
_macro(setq,_macro(%1,$2))
_macro(car,_substr($&,1,1))
_macro(cdr,_substr($&,2))
_macro(cons,$1$2)
_macro(cond,_ifelse)
_macro(reverse,cond($&,,,cons(reverse(cdr($&)),car($&))))
# ARCHIVE MACRO.CMD               10  16-MAY-83 13:24:58
MCR RAT/SYMBOLS MACSYM MACSRC.ARC >MACRO.FTN
FOR/SW:(/NOTR/NOCK/CO:15) MACRO
LINK/OPT/TASK:MACRO/MU/READ_WRITE MACRO,-
[6,76]RATLIB/LIB,-
LB:[22,2]ICR/LIB
TASK=...MPP
UNITS=10
ACTFIL=8
MAXBUF=512
/
# ARCHIVE MACSRC.ARC            1059  16-MAY-83 13:29:05
# ARCHIVE MACRO.HDR               51   3-MAR-82 00:04:15
#
#
#
#    MACRO preprocessor
#    ==================
#
#         Authors: Original by B. Kernighan and P. J. Plauger,
#                  with rewrites and enhancements by David Hanson and
#                  friends (U. of Arizona), Joe Sventek and Debbie
#                  Scherrer (Lawrence Berkely Laboratory), and
#                  William P. Wood, Jr. (Institute For Cancer Research).
#
#         Address: William P. Wood, Jr.
#                  Computer Center
#                  Institute For Cancer Research
#                  7701 Burholme Ave.
#                  Philadelphia, Pa. 19111
#                  (215) 728 2760
#
#         Version: 2.1
#
#         Date:    March 3, 1982
#
#
#
#      *******************************************************
#      *                                                     *
#      *      THIS SOFTWARE WAS DEVELOPED WITH SUPPORT       *
#      *      FROM THE NATIONAL INSTITUTES OF HEALTH:        *
#      *         NIH CA06927                                 *
#      *         NIH CA22780                                 *
#      *                                                     *
#      *      DIRECT INQUIRIES TO:                           *
#      *            COMPUTER CENTER                          *
#      *            THE INSTITUTE FOR CANCER RESEARCH        *
#      *            7701 BURHOLME AVENUE                     *
#      *            PHILADELPHIA, PENNSYLVANIA   19111       *
#      *                                                     *
#      *      NO WARRANTY OR REPRESENTATION, EXPRESS OR      *
#      *      IMPLIED, IS MADE WITH RESPECT TO THE           *
#      *      CORRECTNESS, COMPLETENESS, OR USEFULNESS       *
#      *      OF THIS SOFTWARE, NOR THAT USE OF THIS         *
#      *      SOFTWARE MIGHT NOT INFRINGE PRIVATELY          *
#      *      OWNED RIGHTS.                                  *
#      *                                                     *
#      *      NO LIABILITY IS ASSUMED WITH RESPECT TO        *
#      *      THE USE OF, OR FOR DAMAGES RESULTING FROM      *
#      *      THE USE OF THIS SOFTWARE                       *
#      *                                                     *
#      *******************************************************
#
# ARCHIVE ARGTYP.RAT              44   3-MAR-82 00:06:42
# argtyp - return flags for argument types in defn
#	 - caution this routine modifies defn!!!
  integer function argtyp(defn)
  character defn(ARB)
  integer atype, i, j, n, found(10), set, index, isset
  string digits "0123456789"
  string amperr "arguments cannot be both numeric and & types."

  do i = 1, 10
    found(i) = NOTARG
  atype = 0
  for (i = 1; defn(i) != EOS; i = i+1)
    if (defn(i) == EVALARG | defn(i) == NOEVALARG) {
      n = index(digits, defn(i+1))
      if (defn(i+1) == AMPER) {
	if (isset(atype, COMMA_OK) == NO) {
	  do j = 1, 10
	    if (found(j) != NOTARG) {
	      call synerr(amperr)
	      next 2
	      }
	  atype = set(atype, COMMA_OK)
	  }
	n = 2
	}
      if (n != 0) {
        atype = set(atype, HASARGS)
	if (defn(i+1) != AMPER & isset(atype, COMMA_OK) == YES) {
	  call synerr(amperr)
	  n = 2
	  }
	else if (found(n) != NOTARG & found(n) != defn(i))
	  call synerr("argument cannot be both eval type and noeval type.")
	else {
	  found(n) = defn(i)
	  if (defn(i) == NOEVALARG)
	    atype = set(atype, n-1)
	  }
        defn(i) = ARGFLAG
	defn(i+1) = digits(n)
        }
      }
  return(atype)
  end
# ARCHIVE DEFTOK.RAT             134   3-FEB-82 11:26:59
# deftok - get token, process macro invocations
  character function deftok(token, toksiz)
  character token(ARB), defn(MAXDEF)
  integer j, nlb, toksiz, argty
  character gtoken
  integer lookup, push, length, isset, noeval
  include cmacro
  include clook
  include cdefio
  include cline
  string balp "()"

  while (level > 0 | bp > bplow) {
    for (deftok = gtoken(token, toksiz); deftok !=  EOF;
         deftok = gtoken(token, toksiz))
        {
       if (deftok == ALPHA) {
          if (lookup(token, defn, argty) == NO)
             if (cp == 0) {
		if (defstk(defcnt))
                   return
		}
             else
                call puttok(token)
          else if (noeval(cp, ap, callst, argstk) == YES)
             call puttok(token)
          else {            # defined; put it in eval stack
             cp = cp + 1
             if (cp > CALLSIZE)
                call fatal("call stack overflow.")
             callst(cp) = ap
             ap = push(argty, argstk, ap)
             ap = push(ep, argstk, ap)
             call puttok(defn)   # stack definition
             call putchr(EOS)
             ap = push(ep, argstk, ap)
             call puttok(token)   # stack name
             call putchr(EOS)
             ap = push(ep, argstk, ap)
	     if (isset(argty, HASARGS) == YES) {
	       j = 0
	       repeat {
		  deftok = gtoken(token, toksiz)   # peek at next
		  j = j + 1
		  } until (deftok != BLANK)
	       call pbstr(token)
	       if (deftok != LPAREN) {   # add ( ) if not present
		  for ( ; j > 1; j = j-1)
		     call putbak(BLANK)
		  call pbstr(balp)
		  }
               }
	     else
	       call pbstr(balp)
             plev(cp) = 0
             }
          }
       else if (cp == 0) {			# not in a macro at all
	  if (defstk(defcnt))
	     return
	  }

_ifdef(BRACKETS)			# the use of brackets is too obscure
       else if (deftok == LBRACK) {
          if (noeval(cp, ap, callst, argstk) == YES)
             call puttok(token)
          else {		# strip one level of []
             nlb = 1
             repeat {
                deftok = gtoken(token, toksiz)
                if (deftok == LBRACK)
                   nlb = nlb + 1
                else if (deftok == RBRACK) {
                   nlb = nlb - 1
                   if (nlb == 0)
                      break
                   }
                else if (deftok == EOF) {
                   call synerr("EOF in bracketed string.")
                   call putbak(EOF)
                   break
                   }
                call puttok(token)
                }
             }
          }
_enddef

       else if (deftok == LPAREN) {
          if (plev(cp) > 0)
             call puttok(token)
          plev(cp) = plev(cp) + 1
          }
       else if (deftok == RPAREN) {
          plev(cp) = plev(cp) - 1
          if (plev(cp) > 0)
             call puttok(token)
          else {            # end of argument list
             call putchr(EOS)
             call eval(callst(cp) + 1, callst(cp) + 2, ap - callst(cp) - 3)
             ap = callst(cp)   # pop eval stack
             ep = argstk(ap+1)
             cp = cp - 1
             }
          }
       else if (deftok == COMMA & plev(cp) == 1) {	# new argument
	  if (isset(argstk(callst(cp)), COMMA_OK) == YES)
						# allow commas in argument
	     call puttok(token)
	  else {
	     call putchr(EOS)
	     if (ap - callst(cp) - 3 >= 9)
		call synerr("too many arguments passed to a macro.")
	     else
		ap = push(ep, argstk, ap)
	     }
          }
       else
          call puttok(token)		# just stack it
       }
    if (level > 0) {
      if (infile(level) != STDIN)	# here on EOF; pop back to last file
	 call close(infile(level))
      bplow = bpsave(level)		# restore bottom of push-back buffer
      level = level - 1
      }
    }
  if (cp != 0 | defcnt > 1)
     call synerr("unexpected EOF.")
  deftok = EOF				# in case called at EOF
  token(1) = EOF
  token(2) = EOS
  return
  end
# ARCHIVE DOARTH.RAT              30  30-NOV-81 14:32:08
# doarth - arithmetic interpreter
  subroutine doarth(iargs, nargs)
  integer iargs, nargs
  integer ctoi
  integer k,op1,op2,a
  character op
  include cmacro

  if (nargs > 0) {
     a = arg(1)
     op1 = ctoi(evalst, a)
     for (k = 2; k+1 <= nargs; k = k+2) {
	op = evalst(arg(k))
        a = arg(k+1)
	op2 = ctoi(evalst, a)
	if (op == PLUS)
	  op1 = op1 + op2
	else if (op == MINUS)
	  op1 = op1 - op2
	else if (op == STAR)
	  op1 = op1 * op2
	else if (op == SLASH & op2 != 0)
	  op1 = op1 / op2
        else
          call synerr("arith error.")
	}
     }
  call pbnum(op1)
  return
  end
# ARCHIVE DODEF.RAT               32  30-NOV-81 14:32:09
# dodef - install definition in table
    subroutine dodef(iargs, nargs)
    integer a1, iargs, nargs, argtyp, i
    character c, ngetch, type
    include cmacro

    if (nargs >= 1) {
       a1 = arg(1)
       i = 0
       repeat {
	  if (type(evalst(a1+i)) != LETTER & evalst(a1+i) != UNDERLINE &
_ifdef(MACRO)
	     evalst(a1+i) != PERIOD &
_enddef
	     evalst(a1+i) != DOLLAR & (i == 0 | type(evalst(a1+i)) != DIGIT)) {
	     call errlin(evalst(a1))
	     call synerr("illegal macro name.")
	     goto 10
	     }
          i = i+1
	  } until (evalst(a1+i) == COMMA | evalst(a1+i) == EOS)
       if (evalst(a1+i) != EOS) {
	  evalst(a1+i) = EOS
	  call instal(evalst(a1), evalst(a1+i+1), argtyp(evalst(a1+i+1)))
	  }
       else
	  call instal(evalst(a1), EOS, 0)
       }
10  if (ngetch(c) != NEWLINE)
       call putbak(c)
    return
    end
# ARCHIVE DOELSD.RAT              13  30-NOV-81 14:32:09
# doelsd - handle _elsedef
  subroutine doelsd
  character c, ngetch
  include cmacro

  if (defcnt <= 1)
    call synerr("bad _elsedef.")
  else
    defstk(defcnt) = defstk(defcnt-1) & !defstk(defcnt)
  if (ngetch(c) != NEWLINE)
    call putbak(c)
  return
  end
# ARCHIVE DOENDD.RAT              13  30-NOV-81 14:32:09
# doendd - handle _enddef
  subroutine doendd
  character c, ngetch
  include cmacro

  if (defcnt <= 1)
    call synerr("bad _enddef.")
  else
    defcnt = defcnt - 1
  if (ngetch(c) != NEWLINE)
    call putbak(c)
  return
  end
# ARCHIVE DOIF.RAT                14  30-NOV-81 14:32:09
# doif - select one of two (macro) arguments    /*/sor/macror/doif
    subroutine doif(iargs, nargs)
    integer equal
    integer iargs, nargs
    include cmacro

    if (nargs < 3)
       return
    if (equal(evalst(arg(1)), evalst(arg(2))) == YES)   # subarrays
       call pbstr(evalst(arg(3)))
    else if (nargs >= 4)
       call pbstr(evalst(arg(4)))
    return
    end
# ARCHIVE DOIFD.RAT               18  30-NOV-81 14:32:09
# doifd - do ifdef builtin macro
  subroutine doifd(iargs, nargs)
  integer iargs, nargs, locdef, junk1, junk2
  character c, ngetch
  include cmacro

  defcnt = defcnt + 1
  if (defcnt > DEFSTACKSIZE)
    call fatal("_ifdefs nested too deeply.")
  defstk(defcnt) = defstk(defcnt-1)
  if (defstk(defcnt))
    if (nargs > 0)
      if (locdef(evalst(arg(1)), junk1, junk2, c) != YES)
	defstk(defcnt) = .false.
  if (ngetch(c) != NEWLINE)
    call putbak(c)
  return
  end
# ARCHIVE DOINCL.RAT              12   1-DEC-81 11:46:04
# doincl - handle file inclusion for macro
  subroutine doincl(iargs, nargs)
  integer iargs, nargs
  character ngetch, c
  include cmacro
  include cline

  if (ngetch(c) != NEWLINE)
     call putbak(c)
  call includ(evalst(arg(1)))
  return
  end
# ARCHIVE DOINCR.RAT              12  30-NOV-81 14:32:10
# doincr - increment macro argument by 1
    subroutine doincr(iargs, nargs)
    integer ctoi
    integer iargs, nargs, k
    include cmacro

    if (nargs != 0) {
      k = arg(1)
      call pbnum(ctoi(evalst, k)+1)
      }
    return
    end
# ARCHIVE DOIND.RAT               12  30-NOV-81 14:32:10
# doind - get index of arg2 in arg1
  subroutine doind(iargs, nargs)
  integer iargs, nargs
  integer index
  include cmacro

  if (nargs == 1)
    call pbnum(0)
  else if (nargs >= 2)
    call pbnum(index(evalst(arg(1)), evalst(arg(2))))
  return
  end
# ARCHIVE DOLEN.RAT               12  30-NOV-81 14:32:10
# dolen - get length of argument
  subroutine dolen(iargs, nargs)
  integer iargs, nargs
  integer length
  include cmacro

  if (nargs < 1)
    call pbnum(0)
  else
    call pbnum(length(evalst(arg(1))))
  return
  end
# ARCHIVE DOSUB.RAT               29  30-NOV-81 14:32:10
# dosub - select macro substring
    subroutine dosub(iargs, nargs)
    integer ctoi, length
    integer ap1, fc, iargs, nargs, k, nc, bs
    include cmacro

    if (nargs == 0)
       return
    if (nargs == 1)
       bs = 1
    else {
       k = arg(2)
       bs = ctoi(evalst, k)
       }
    if (nargs <= 2)
       nc = MAXINT
    else {
       k = arg(3)
       nc = ctoi(evalst, k)      # number of characters
       }
    ap1 = arg(1)         # target string
    fc = ap1 + bs - 1    # first char of substring
    if (fc >= ap1 & fc < ap1 + length(evalst(ap1))) {   # subarrays
       k = fc + min(nc, length(evalst(fc))) - 1
       for ( ; k >= fc; k = k - 1)
          call putbak(evalst(k))
       }
    return
    end
# ARCHIVE DOUND.RAT               17  30-NOV-81 14:32:11
# dound - undefine a macro and garbage collect
  subroutine dound(iargs, nargs)
  integer iargs, nargs, a1, i, index
  character ngetch, c
  include cmacro

  if (nargs >= 1) {
    a1 = arg(1)
    i = index(evalst(a1), COMMA)
    if (i != 0)
      evalst(a1+i-1) = EOS
    call undef(evalst(a1))
    }
  if (ngetch(c) != NEWLINE)
    call putbak(c)
  return
  end
# ARCHIVE ERRLIN.RAT              12  30-NOV-81 14:32:11
# errlin - save a string to output to STDOUT and to ERROUT
  subroutine errlin(mess)
  character mess(ARB)
  integer i, j, length
  include cerrbf

  j = length(errbuf)
  for (i = j + 1; i < MAXTOK & mess(i - j) != EOS; i = i + 1)
    errbuf(i) = mess(i - j)
  errbuf(i) = EOS
  return
  end
# ARCHIVE EVAL.RAT                63   4-DEC-81 13:25:18
# eval - expand args: evaluate builtin or push back defn
    subroutine eval(idefn, iargs, nargs)
    integer index, length
    integer argno, idefn, iargs, nargs, k, t, td
    include cmacro
    string digits '0123456789'

    t = argstk(idefn)
    td = evalst(t)
    if (td < 0) {
      if (td == IFDEFTYPE)
	  call doifd(iargs, nargs)
      else if (td == ELSEDEFTYPE)
	  call doelsd
      else if (td == ENDDEFTYPE)
	  call doendd
      else if (td == INCRTYPE)
	 call doincr(iargs, nargs)
      else if (td == SUBSTRTYPE)
	 call dosub(iargs, nargs)
      else if (td == IFELSETYPE)
	 call doif(iargs, nargs)
      else if (td == ARITHTYPE)
	  call doarth(iargs, nargs)
      else if (td == LENTYPE)
	  call dolen(iargs, nargs)
      else if (td == INDEXTYPE)
	  call doind(iargs, nargs)
      else if (td == INCLUDETYPE) {
	 if (defstk(defcnt))
	    call doincl(iargs, nargs)
	 }
      else if (td == DEFINETYPE) {
	 if (defstk(defcnt))
	    call dodef(iargs, nargs)
	 }
      else if (td == UNDEFTYPE) {
	 if (defstk(defcnt))
            call dound(iargs, nargs)
	 }
      else			# just pass it along
          call putbak(evalst(t))
      }
    else {
       for (k = t+length(evalst(t))-1; k > t; k = k - 1)
          if (evalst(k-1) != ARGFLAG)
             call putbak(evalst(k))
          else {
             argno = index(digits, evalst(k)) - 1
             if (argno >= 0 & argno <= nargs) {
                call pbstr(evalst(arg(argno)))
 	        k = k - 1   # skip over $
                }
	     else if (argno == -1)		# wasn't a digit
		call putbak(evalst(k))
             else
                k = k - 1   # skip over $
             }
       if (k == t)         # do last character
          call putbak(evalst(k))
       }
    return
    end
# ARCHIVE FATAL.RAT                8  30-NOV-81 14:32:11
# fatal - handle fatal error
  subroutine fatal(mess)
  character mess(ARB)

  call synerr(mess)
  call error(EOS)
  return
  end
# ARCHIVE GETINT.RAT              11  30-NOV-81 14:32:12
# getint - get an integer from table
  integer function getint(table)
  character table(CHARSPERINT), c(CHARSPERINT)
  integer i, j
  equivalence (i, c)

  do j = 1, CHARSPERINT
    c(j) = table(j)
  getint = i
  return
  end
# ARCHIVE GTOKENM.RAT             42  30-NOV-81 14:32:12
_ifdef(MACRO)
# gtoken - get alphanumeric string or single non-alph for macro
  character function gtoken(token, toksiz)
  character ngetch, type
  integer i, toksiz
  character token (ARB)

  for (i = 1; i < toksiz; i = i+1) {
      gtoken = type( ngetch(token(i)))
      if (gtoken != LETTER & gtoken != DIGIT & gtoken != UNDERLINE
        & gtoken != PERIOD & gtoken != DOLLAR)
          break
      }
  if (token(1) == ACCENT) {		# leave stuff in here alone
      for (i = 2; i < toksiz; i = i+1)
	  if (ngetch(token(i)) == ACCENT) {
	      if (ngetch(token(i+1)) != ACCENT) {
                  call putbak(token(i+1))
                  break
                  }
              else
                  i = i+1
              }
          else if (token(i) == EOF) {
              call synerr("EOF in literal string.")
              call putbak(EOF)
              token(i) = ACCENT
              break
              }
      }
  if (i >= toksiz)
      call fatal ("token too long.")
  if (i > 1  &  token(1) != ACCENT) {       # some alpha was seen
      call putbak (token(i))
      i = i - 1
      gtoken = ALPHA
      }
 # else single character token
  token(i+1) = EOS
  return
  end
_enddef
# ARCHIVE INCLUD.RAT              26   1-DEC-81 11:47:48
# includ - handle file inclusion
  subroutine includ(file)
  character file(ARB)
  integer length, open
  include cline
  include cdefio

  if (level >= NFILES)
    call synerr("includes nested too deeply.")
  else {
    infile(level+1) = open(file, READ)
    if (infile(level+1) == ERR) {
      call errlin(file)
      call synerr("can't open included file.")
      }
    else {
      level = level+1
      linect(level) = 0
      fnamp(level) = fnamp(level-1) + length(fnames(fnamp(level-1))) + 1
      call scopy(file, 1, fnames, fnamp(level))
      bpsave(level) = bplow
      bplow = bp
      }
    }
  return
  end
# ARCHIVE INIMAC.RAT              82   3-MAR-82 00:02:51
# inimac - initialize macro preproccessor
  subroutine inimac

    include cmacro
    include clook
    include cdefio
    include cerrbf

    integer set, argtyp
    character macnam(7), mactyp(2)
    character undnam(7), undtyp(2)
    character incnam(6), inctyp(2)
    character subnam(8), subtyp(2)
    character ifenam(8), ifetyp(2)
    character arinam(7), arityp(2)
    character lennam(5), lentyp(2)
    character indnam(7), indtyp(2)
    character ifdnam(7), ifdtyp(2)
    character elsnam(9), elstyp(2)
    character endnam(8), endtyp(2)
    character iclnam(9), icltyp(2)

    string ifnnam "_ifndef", ifndef "_ifdef(%1)_elsedef"
    string ifnotn "_ifnotdef", ifnotd "_ifdef(%1)_elsedef"
    string repnam "_repdef", repdef "_undef(%&)_macro(%&)"

    data macnam /UNDERLINE, LETM, LETA, LETC, LETR, LETO, EOS/,
         mactyp /DEFINETYPE, EOS/
    data undnam /UNDERLINE, LETU, LETN, LETD, LETE, LETF, EOS/,
         undtyp /UNDEFTYPE, EOS/
    data incnam /UNDERLINE, LETI, LETN, LETC, LETR, EOS/,
         inctyp /INCRTYPE, EOS/
    data subnam /UNDERLINE, LETS, LETU, LETB, LETS, LETT, LETR, EOS/,
         subtyp /SUBSTRTYPE, EOS/
    data ifenam /UNDERLINE, LETI, LETF, LETE, LETL, LETS, LETE, EOS/,
         ifetyp /IFELSETYPE, EOS/
    data arinam /UNDERLINE, LETA, LETR, LETI, LETT, LETH, EOS/,
         arityp /ARITHTYPE, EOS/
    data lennam /UNDERLINE, LETL, LETE, LETN, EOS/,
         lentyp /LENTYPE, EOS/
    data indnam /UNDERLINE, LETI, LETN, LETD, LETE, LETX, EOS/,
         indtyp /INDEXTYPE, EOS/
    data ifdnam /UNDERLINE, LETI, LETF, LETD, LETE, LETF, EOS/,
         ifdtyp /IFDEFTYPE, EOS/
    data elsnam /UNDERLINE, LETE, LETL, LETS, LETE, LETD, LETE, LETF, EOS/,
         elstyp /ELSEDEFTYPE, EOS/
    data endnam /UNDERLINE, LETE, LETN, LETD, LETD, LETE, LETF, EOS/,
         endtyp /ENDDEFTYPE, EOS/
    data iclnam /UNDERLINE, LETI, LETN, LETC, LETL, LETU, LETD, LETE, EOS/,
         icltyp /INCLUDETYPE, EOS/

    avail = 1
    for (i = 1; i <= 127; i = i+1)
      tabptr(i) = 0
    call insupl(macnam, mactyp, set(set(set(0, HASARGS), COMMA_OK), 1))
    call insupl(undnam, undtyp, set(set(set(0, HASARGS), COMMA_OK), 1))
    call insupl(incnam, inctyp, set(0, HASARGS))
    call insupl(subnam, subtyp, set(0, HASARGS))
    call insupl(ifenam, ifetyp, set(set(set(0, HASARGS), 3), 4))
    call insupl(arinam, arityp, set(0, HASARGS))
    call insupl(lennam, lentyp, set(set(0, HASARGS), COMMA_OK))
    call insupl(indnam, indtyp, set(0, HASARGS))
    call insupl(ifdnam, ifdtyp, set(set(0, HASARGS), 1))
    call insupl(elsnam, elstyp, 0)
    call insupl(endnam, endtyp, 0)
    call insupl(iclnam, icltyp, set(set(0, HASARGS), COMMA_OK))
    call insupl(ifnnam, ifndef, argtyp(ifndef))
    call insupl(ifnotn, ifnotd, argtyp(ifnotd))
    call insupl(repnam, repdef, argtyp(repdef))

  # initialize pointers, etc.
    bp = 0
    bpsave(1) = 0
    bplow = 0
    cp = 0
    ap = 1
    ep = 1
    defcnt = 1
    defstk(1) = .true.
    errbuf(1) = EOS
    return
    end
# ARCHIVE INSTAL.RAT              30  30-NOV-81 14:32:12
# instal - add name and definition to table
   subroutine instal(name, defn, flag)
   character defn(MAXDEF), name(MAXTOK), c
   integer length
   integer dlen, nlen, flag
   include clook

   if (name(1) != EOS) {
     nlen = length(name) + 1
     dlen = length(defn) + 1
     if (dlen > MAXDEF) {
	call errlin(name)
	call synerr("definition too long.")
        return
	}
     if (avail + nlen + dlen + 2*CHARSPERINT > MAXTBL+1) {
	call errlin(name)
	call fatal("too many definitions.")
        return
	}
     call setint(table(avail+CHARSPERINT), flag)
     call scopy (name, 1, table, avail+2*CHARSPERINT)
     call scopy (defn, 1, table, avail+nlen+2*CHARSPERINT)
     c = table(avail+2*CHARSPERINT)
     call setint(table(avail), tabptr(c))
     tabptr(c) = avail
     avail = avail + nlen + dlen + 2*CHARSPERINT
     }
   return
   end
# ARCHIVE INSUPL.RAT              11  30-NOV-81 14:32:13
# insupl - install upper and lower case versions of name
  subroutine insupl(name, defn, flag)
  character name(MAXTOK), defn(MAXDEF), fname(MAXTOK)
  integer flag

  call instal(name, defn, flag)
  call scopy(name, 1, fname, 1)
  call upper(fname)
  call instal(fname, defn, flag)
  return
  end
# ARCHIVE ISSET.RAT               11  30-NOV-81 14:32:13
# isset - return YES if bit n is set in flags
  integer function isset(flags, n)
  integer flags, n
  integer bitmsk(12)
  data bitmsk /1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048/

  isset = NO
  if (mod(flags/bitmsk(n+1), 2) == 1)
    isset = YES
  return
  end
# ARCHIVE LOCDEF.RAT              23   3-FEB-82 23:24:23
# locdef - locate name
   integer function locdef(name, i, j, c)
   character name(MAXTOK), c
   integer i, j, k
   integer getint
   include clook

   if (name(1) != EOS) {
     c = name(1)
     for (i = tabptr(c); i > 0; i = getint(table(i))) {
	j = i + 2*CHARSPERINT
	for (k = 1; name(k) == table(j) & name(k) != EOS; k = k + 1)
	   j = j + 1
	if (name(k) == table(j)) {      # got one
	   j = j+1
	   locdef = YES
	   return
	   }
	}
     }
   locdef = NO
   return
   end
# ARCHIVE LOOKUP.RAT              13  30-NOV-81 14:32:13
# lookup - locate name, extract definition from table
   integer function lookup(name, defn, flag)
   character defn(MAXDEF), name(MAXTOK), c
   integer flag, i, j, locdef, getint
   include clook

   lookup = locdef(name, i, j, c)
   if (lookup == YES) {
     call scopy(table, j, defn, 1)
     flag = getint(table(i+CHARSPERINT))
     }
   return
   end
# ARCHIVE MACMAIN.RAT             50   1-DEC-81 11:26:17
_ifdef(MACRO)
# macro - expand macros with arguments
  program macro			# remove this if necessary on your system

  include cline
  integer getarg, i, j, open
  character deftok
  character file(MAXLINE), token(MAXTOK)
  string stdinn "STDIN"


  call initr4
  call inimac
  for (i=1; ;i=i+1) {
    fnamp(1) = 1
    level = 1
    linect(1) = 0
    if (getarg(i, file, MAXLINE) == EOF) {
         if (i != 1)  break
         infile(level) = STDIN
         call scopy(stdinn, 1, fnames, 1)
         }
    else if (file(1) == QMARK & file(2) == EOS)
        call remark('usage:  macro [file ...].')
    else if (file(1) == MINUS & file(2) == EOS) {
        infile(level) = STDIN
        call scopy(stdinn, 1, fnames, 1)
        }
    else {
         infile(level) = open(file, READ)
         call scopy(file, 1, fnames, 1)
         if (infile(level) == ERR)
                call cant (file)
        }
    while (deftok(token, MAXTOK) != EOF)
       if (token(1) == ACCENT)
          for (j = 2; ; j = j+1) {
             if (token(j) == ACCENT)
                if (token(j+1) == ACCENT)
                   j = j+1
                else
                   break
    	     call putch(token(j), STDOUT)
             }
       else
          call putlin(token, STDOUT)
    }
  call endr4
  end
_enddef
# ARCHIVE NGETCH.RAT              35   3-FEB-82 13:22:38
# ngetch - get a (possibly pushed back) character
  character function ngetch(c)
  character c
  integer i, getlin
  include cdefio
  include cline

  repeat {
    if (bp <= bplow) {
      if (level > 0)
	i = getlin(ioin, infile(level))
      else
	i = EOF
      if (i == EOF) {
	c = EOF
	return (c)
	}
      linect(level) = linect(level) + 1
      repeat {				# push ioin on pushback buffer
	bp = bp+1
	buf(bp) = ioin(i)
	i = i-1
	} until (i == 0)
      }
    c = buf(bp)
    bp = bp - 1
    if (c == UNDERLINE)
      if (bp > bplow)
	if (buf(bp) == NEWLINE) {
	  bp = bp-1
	  next
	  }
    return (c)
    }
  end
# ARCHIVE NOEVAL.RAT               9  30-NOV-81 14:32:14
# noeval - check if macro arguments should be evaluated now
  integer function noeval(cp, ap, callst, argstk)
  integer cp, ap, callst(ARB), argstk(ARB), isset

  noeval = NO
  if (cp != 0)
    noeval = isset(argstk(callst(cp)), ap - callst(cp) - 3)
  return
  end
# ARCHIVE PBNUM.RAT                9  30-NOV-81 14:32:14
# pbnum - convert number to string, push back on input
  subroutine pbnum(n)
  integer n, i, itoc
  character str(MAXCHARS)

  i = itoc(n, str, MAXCHARS)
  call pbstr(str)
  return
  end
# ARCHIVE PBSTR.RAT               10  30-NOV-81 14:32:14
# pbstr - push string back onto input
   subroutine pbstr(in)
   character in(ARB)
   integer length
   integer i

   for (i = length(in); i > 0; i = i - 1)
      call putbak(in(i))
   return
   end
# ARCHIVE PUSH.RAT                10  30-NOV-81 14:32:15
# push - push ep onto argstk, return new pointer ap   /*/sor/macror/push
    integer function push(ep, argstk, ap)
    integer ap, argstk(ARGSIZE), ep

    if (ap > ARGSIZE)
       call fatal("argument stack overflow.")
    argstk(ap) = ep
    push = ap + 1
    return
    end
# ARCHIVE PUTBAK.RAT              11   1-DEC-81 09:29:28
# putbak - push character back onto input
   subroutine putbak(c)
   character c
   include cdefio

   bp = bp + 1
   if (bp > BUFSIZE)
      call fatal("too many characters pushed back.")
   buf(bp) = c
   return
   end
# ARCHIVE PUTCHR.RAT              11  30-NOV-81 14:32:15
# putchr - put single char into eval stack
    subroutine putchr(c)
    character c
    include cmacro

    if (ep > EVALSIZE)
      call fatal("evaluation stack overflow.")
    evalst(ep) = c
    ep = ep + 1
    return
    end
# ARCHIVE PUTTOK.RAT               9   3-DEC-81 09:35:40
# puttok - put token into eval stack
    subroutine puttok(str)
    character str(MAXTOK)
    integer i

    for (i = 1; str(i) != EOS; i = i + 1)
       call putchr(str(i))
    return
    end
# ARCHIVE SET.RAT                 11  30-NOV-81 14:32:15
# set - return flags with bit n set
  integer function set(flags, n)
  integer flags, n
  integer bitmsk(12), isset
  data bitmsk /1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048/

  set = flags
  if (isset(flags, n) != YES)
    set = flags + bitmsk(n+1)
  return
  end
# ARCHIVE SETINT.RAT               8  30-NOV-81 14:32:16
# setint - put an integer into table
  subroutine setint(table, val)
  character table(CHARSPERINT), val(CHARSPERINT)

  do i = 1, CHARSPERINT
    table(i) = val(i)
  return
  end
# ARCHIVE SYN2.RAT                24  30-NOV-81 14:32:16
# syn2 - report Ratfiv syntax error
   subroutine syn2(msg, f)
   character lc(MAXCHARS), msg(ARB)
   integer itoc
   integer i, junk, f
   include cline
   string serror '? error at line '
   string in ' in '

   call putlin(serror, f)
   if (level >= 1)
      i = level
   else
      i = 1   # for EOF errors
   junk = itoc(linect(i), lc, MAXCHARS)
   call putlin(lc, f)
   call putlin(in, f)
   call putlin(fnames(fnamp(i)), f)
   call putch(COLON, f)
   call putch(BLANK, f)
   call putlin(msg, f)
   call putch(NEWLINE, f)
   return
   end
# ARCHIVE SYNERR.RAT              13  30-NOV-81 14:32:16
# synerr - report ratfiv syntax error
  subroutine synerr(msg)
  character msg(ARB)
  include cerrbf

  call xitsta(EXIT_ERROR)
  call putlin(errbuf, ERROUT)
  call syn2(msg, ERROUT)
  call putlin(errbuf, STDOUT)
  call syn2(msg, STDOUT)
  errbuf(1) = EOS
  return
  end
# ARCHIVE UNDEF.RAT               33  30-NOV-81 14:32:16
# undef - undefine a macro and garbage collect
  subroutine undef(name)
  character name(MAXTOK), c
  integer i, j, k, knext, l, deflen, locdef, length, getint
  include clook

  if (locdef(name, i, j, c) == YES) {
    if (tabptr(c) == i)
      tabptr(c) = getint(table(i))
    else {
      for (k = tabptr(c); getint(table(k)) != i; k = getint(table(k)))
	;
      call setint(table(k), getint(table(i)))
      }
    j = j + length(table(j)) + 1
    deflen = j - i
    do l = 1, 127
      if (tabptr(l) > i) {
	k = tabptr(l)
	tabptr(l) = tabptr(l) - deflen
	for ( ; getint(table(k)) > i; k = knext) {
	  knext = getint(table(k))
	  call setint(table(k), knext - deflen)
	  }
	}
    for ( ; j < avail; j = j+1) {
      table(i) = table(j)
      i = i+1
      }
    avail = i
    }
  return
  end
# ARCHIVE MACSYM.                 46  16-MAY-83 13:29:07
# definitions for macro processor
# put on a file named 'macsym'

 define(ARGFLAG,DOLLAR)
 define(EVALARG,ARGFLAG)
 define(NOEVALARG,PERCENT)
 define(HASARGS,10)
 define(COMMA_OK,11)
 define(NOTARG,0)

 define(DEFINETYPE,-20)
 define(IFELSETYPE,-21)
 define(INCRTYPE,-22)
 define(SUBSTRTYPE,-23)
 define(ARITHTYPE,-24)
 define(LENTYPE,-25)
 define(INDEXTYPE,-26)
 define(IFDEFTYPE,-27)
 define(ELSEDEFTYPE,-28)
 define(ENDDEFTYPE,-29)
 define(INCLUDETYPE,-30)
 define(UNDEFTYPE,-31)

 define(EVALSIZE,500)
 define(DEFSTACKSIZE,20)
 define(CALLSIZE,30)
 define(ARGSIZE,120)
 define(BUFSIZE,900)	  # pushback buffer for ngetch and putbak
 define(MAXDEF,500)       # max chars in a definition
 define(NFILES,4)         # max depth of file inclusion
 define(MAXTBL,10001)     # max chars in all definitions
 define(MAXTOK,201)       # max chars in a token
 define(MAXFNAMES,_arith(NFILES,*,FILENAMESIZE))

_ifdef(VAX)
 define(CHARSPERINT,4)	  # number of characters per integer
_elsedef
 define(CHARSPERINT,2)	  # number of characters per integer
_enddef

 define(abs,iabs)
 define(max,max0)
 define(min,min0)

 define(MACRO)
 define(arg,argstk(iargs+$1))
# ARCHIVE TEST.M                  24  16-MAY-83 13:25:00
_macro(x)
_macro(y)
_ifdef(x)
	"`x` defined"
	_ifdef(c)
	    _macro(dd)
	    "!c"
	_elsedef
	    _ifdef(dd)
		!dd!
		_enddef
	    else c
	    _enddef
	back in `x`
_elsedef
	!else x!
	_ifdef(y)
	    !ifdef y!
	_elsedef
	    !else y!
	    _enddef
	!!else2 x!
	_enddef
top level
# ARCHIVE UTIL.M                   7  16-MAY-83 13:25:01
_macro(set,_macro(%1,$2))
_macro(push,_macro(_stack,$1)_stack)
_macro(pop,_stack``_undef(_stack)``)
_macro(isdef,_ifelse([%1],%1,,%1))
_macro(cc,$1$2)
_macro(clear,_ifelse(isdef(%1),,%1,_undef(%1)clear(%1)))
_macro(eat,%2)
