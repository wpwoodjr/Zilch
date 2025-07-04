From:	V04::ROTHAUS      "Miker"  3-AUG-1988 10:46
To:	WOOD
Subj:	IBMPC.C

Here is the C module which contains the EGA (also included in EMACSSRC.ARC):

/*
 * The routines in this file provide support for the IBM-PC and other
 * compatible terminals. It goes directly to the graphics RAM to do
 * screen output. It compiles into nothing if not an IBM-PC driver
 * Supported monitor cards include CGA, MONO and EGA.
 */

#define	termdef	1			/* don't define "term" external */

#include        <stdio.h>
#include	"estruct.h"
#include	"etype.h"
#include        "edef.h"

#if     IBMPC
#define NROW	50			/* Max Screen size.		*/
#define NCOL    80                      /* Edit if you want to.         */
#define	MARGIN	8			/* size of minimim margin and	*/
#define	SCRSIZ	64			/* scroll size for extended lines */
#define	NPAUSE	200			/* # times thru update to pause */
#define BEL     0x07                    /* BEL character.               */
#define ESC     0x1B                    /* ESC character.               */
#define	SPACE	32			/* space character		*/

#define	SCADC	0xb8000000L		/* CGA address of screen RAM	*/
#define	SCADM	0xb0000000L		/* MONO address of screen RAM	*/
#define SCADE	0xb8000000L		/* EGA/VGA address of screen RAM*/

#define MONOCRSR 0x0B0D			/* monochrome cursor		*/
#define CGACRSR 0x0607			/* CGA cursor			*/
#define EGACRSR 0x0709			/* EGA/VGA cursor		*/

#define	CDCGA	0			/* color graphics card		*/
#define	CDMONO	1			/* monochrome text card		*/
#define	CDEGA	2			/* EGA color adapter		*/
#define	CDVGA	3			/* VGA color adapter		*/
#define	CDSENSE	9			/* detect the card type		*/

#define NDRIVE	4			/* number of screen drivers	*/

int dtype = -1;				/* current display type		*/
char drvname[][8] = {			/* screen resolution names	*/
	"CGA", "MONO", "EGA", "VGA"
};
long scadd;				/* address of screen ram	*/
int *scptr[NROW];			/* pointer to screen lines	*/
unsigned int sline[NCOL];		/* screen line image		*/
int egaexist = FALSE;			/* is an EGA card available?	*/
int vgaexist = FALSE;			/* is video graphics array available? */
extern union REGS rg;			/* cpu register for use of DOS calls */

PASCAL NEAR ibmmove();
PASCAL NEAR ibmeeol();
PASCAL NEAR ibmputc();
PASCAL NEAR ibmeeop();
PASCAL NEAR ibmrev();
PASCAL NEAR ibmcres();
PASCAL NEAR spal();
PASCAL NEAR ibmbeep();
PASCAL NEAR ibmopen();
PASCAL NEAR ibmclose();
PASCAL NEAR ibmkopen();
PASCAL NEAR ibmkclose();
PASCAL NEAR scinit();
int PASCAL NEAR getboard();
PASCAL NEAR egaopen();
PASCAL NEAR egaclose();
PASCAL NEAR fnclabel();

#if	COLOR
PASCAL NEAR ibmfcol();
PASCAL NEAR ibmbcol();
int	cfcolor = -1;		/* current forground color */
int	cbcolor = -1;		/* current background color */
int	ctrans[] =		/* ansi to ibm color translation table */
	{0, 4, 2, 6, 1, 5, 3, 7};
#endif

/*
 * Standard terminal interface dispatch table. Most of the fields point into
 * "termio" code.
 */
TERM    term    = {
	NROW-1,
        NROW-1,
        NCOL,
        NCOL,
	MARGIN,
	SCRSIZ,
	NPAUSE,
        ibmopen,
        ibmclose,
	ibmkopen,
	ibmkclose,
        ttgetc,
	ibmputc,
        ttflush,
        ibmmove,
        ibmeeol,
        ibmeeop,
        ibmbeep,
	ibmrev,
	ibmcres
#if	COLOR
	, ibmfcol,
	ibmbcol
#endif
};

#if	COLOR
PASCAL NEAR ibmfcol(color)	/* set the current output color */

int color;	/* color to set */

{
	cfcolor = ctrans[color];
}

PASCAL NEAR ibmbcol(color)	/* set the current background color */

int color;	/* color to set */

{
        cbcolor = ctrans[color];
}
#endif

PASCAL NEAR ibmmove(row, col)
{
	rg.h.ah = 2;		/* set cursor position function code */
	rg.h.dl = col;
	rg.h.dh = row;
	rg.h.bh = 0;		/* set screen page number */
	int86(0x10, &rg, &rg);
}

PASCAL NEAR ibmeeol()	/* erase to the end of the line */

{
	unsigned int attr;	/* attribute byte mask to place in RAM */
	unsigned int *lnptr;	/* pointer to the destination line */
	int i;
	int ccol;	/* current column cursor lives */
	int crow;	/*	   row	*/

	/* find the current cursor position */
	rg.h.ah = 3;		/* read cursor position function code */
	rg.h.bh = 0;		/* current video page */
	int86(0x10, &rg, &rg);
	ccol = rg.h.dl;		/* record current column */
	crow = rg.h.dh;		/* and row */

	/* build the attribute byte and setup the screen pointer */
#if	COLOR
	if (dtype != CDMONO)
		attr = (((cbcolor & 15) << 4) | (cfcolor & 15)) << 8;
	else
		attr = 0x0700;
#else
	attr = 0x0700;
#endif
	lnptr = &sline[0];
	for (i=0; i < term.t_ncol; i++)
		*lnptr++ = SPACE | attr;

	if (flickcode && (dtype == CDCGA)) {
		/* wait for vertical retrace to be off */
		while ((inp(0x3da) & 8))
			;
	
		/* and to be back on */
		while ((inp(0x3da) & 8) == 0)
			;
	}			

	/* and send the string out */
	movmem(&sline[0], scptr[crow]+ccol, (term.t_ncol-ccol)*2);

}

PASCAL NEAR ibmputc(ch) /* put a character at the current position in the
		   current colors */

int ch;

{
	/* if its a newline, we have to move the cursor */
	if (ch == '\n' || ch == '\r') {
		rg.h.ah = 3;
		int86(0x10, &rg, &rg);
		if (rg.h.dh == 24) {
			ibmmove(20, 0);
			/* we must scroll the screen */
			rg.h.ah = 6;	/* scroll up */
			rg.h.al = 1;	/* # of lines to scroll by */
			rg.h.bh = cfcolor; /* attribute for blank line */
			rg.x.cx = 0;	/* upper left corner of scroll */
			rg.x.dx = 0x184f;/* lower right */
			int86(0x10, &rg, &rg);
			rg.h.dh = 23;
		}
		ibmmove(rg.h.dh + 1, 0);
		return;
	}

	rg.h.ah = 14;		/* write char to screen with current attrs */
	rg.h.al = ch;
#if	COLOR
	if (dtype != CDMONO)
		rg.h.bl = cfcolor;
	else
		rg.h.bl = 0x07;
#else
	rg.h.bl = 0x07;
#endif
	int86(0x10, &rg, &rg);
}

PASCAL NEAR ibmeeop()
{
	int attr;		/* attribute to fill screen with */

	rg.h.ah = 6;		/* scroll page up function code */
	rg.h.al = 0;		/* # lines to scroll (clear it) */
	rg.x.cx = 0;		/* upper left corner of scroll */
	rg.x.dx = (term.t_nrow << 8) | (term.t_ncol - 1);
				/* lower right corner of scroll */
#if	COLOR
	if (dtype != CDMONO)
		attr = ((ctrans[gbcolor] & 15) << 4) | (ctrans[gfcolor] & 15);
	else
		attr = 0;
#else
	attr = 0;
#endif
	rg.h.bh = attr;
	int86(0x10, &rg, &rg);
}

PASCAL NEAR ibmrev(state)	/* change reverse video state */

int state;	/* TRUE = reverse, FALSE = normal */

{
	/* This never gets used under the IBM-PC driver */
}

PASCAL NEAR ibmcres(res) /* change screen resolution */

char *res;	/* resolution to change to */

{
	int i;		/* index */

	for (i = 0; i < NDRIVE; i++)
		if (strcmp(res, drvname[i]) == 0) {
			scinit(i);
			return(TRUE);
		}
	return(FALSE);
}

PASCAL NEAR spal()	/* reset the pallette registers */

{
	/* nothin here now..... */
}

PASCAL NEAR ibmbeep()
{
#if	MWC
	ttputc(BEL);
#else
	bdos(6, BEL, 0);
#endif
}

PASCAL NEAR ibmopen()
{
	scinit(CDSENSE);
	revexist = TRUE;
        ttopen();
}

PASCAL NEAR ibmclose()

{
#if	COLOR
	ibmfcol(7);
	ibmbcol(0);
#endif
	/* if we had the EGA open... close it */
	if (dtype == CDEGA || dtype == CDVGA)
		egaclose();

	ttclose();
}

PASCAL NEAR ibmkopen()	/* open the keyboard */

{
	rg.x.ax = 0x3301;
	rg.h.dl = 0x00;
	intdos(&rg, &rg);
}

PASCAL NEAR ibmkclose() /* close the keyboard */

{
}

PASCAL NEAR scinit(type) /* initialize the screen head pointers */

int type;	/* type of adapter to init for */

{
	union {
		long laddr;	/* long form of address */
		int *paddr;	/* pointer form of address */
	} addr;
	int i;

	/* if asked...find out what display is connected */
	if (type == CDSENSE)
		type = getboard();

	/* if we have nothing to do....don't do it */
	if (dtype == type)
		return(TRUE);

	/* if we try to switch to EGA and there is none, don't */
	if (type == CDEGA && !egaexist)
		return(FALSE);

	/* if we try to switch to VGA and there is none, don't */
	if (type == CDVGA && !vgaexist )
		return(FALSE);

	/* if we had the EGA or VGA open... close it */
	if (dtype == CDEGA || dtype == CDVGA)
		egaclose();

	/* and set up the various parameters as needed */
	switch (type) {
		case CDMONO:	/* Monochrome adapter */
				scadd = SCADM;
				newsize(TRUE, 25);
				break;

		case CDCGA:	/* Color graphics adapter */
				scadd = SCADC;
				newsize(TRUE, 25);
				break;

		case CDEGA:	/* Enhanced graphics adapter */
				scadd = SCADE;
				egaopen();
				newsize(TRUE, 43);
				break;

		case CDVGA:	/* video graphics array - acts as EGA but more lines */
				scadd = SCADE;
				egaopen();
				newsize(TRUE, 50);
				break;
	}

	/* reset the $sres environment variable */
	strcpy(sres, drvname[type]);
	dtype = type;

	/* initialize the screen pointer array */
	for (i = 0; i < NROW; i++) {
		addr.laddr = scadd + (long)(NCOL * i * 2);
		scptr[i] = addr.paddr;
	}
	return(TRUE);
}

/* getboard:	Determine which type of display board is attached.
		Current known types include:

		CDMONO	Monochrome graphics adapter
		CDCGA	Color Graphics Adapter
		CDEGA	Extended graphics Adapter
		CDVGA	Vidio Graphics Array

		if MONO	set to MONO
		   CGA	set to CGA	EGAexist = FALSE VGAexist = FALSE
		   EGA	set to CGA	EGAexist = TRUE  VGAexist = FALSE
		   VGA	set to CGA	EGAexist = TRUE  VGAexist = TRUE
*/

int PASCAL NEAR getboard()

{
	int type;	/* board type to return */

	type = CDCGA;
	int86(0x11, &rg, &rg);
	if ((((rg.x.ax >> 4) & 3) == 3))
		type = CDMONO;

	/* test if EGA present */
	rg.x.ax = 0x1200;
	rg.x.bx = 0xff10;
	int86(0x10,&rg, &rg);		/* If EGA, bh=0-1 and bl=0-3 */
	egaexist = !(rg.x.bx & 0xfefc);	/* Yes, it's EGA */
	if (egaexist) {
		/* Adapter says it's an EGA. We'll get the same response
		   from a VGA, so try to tell the two apart */
		rg.x.ax = 0x1a00;	/* read display combination */
		int86(0x10,&rg,&rg);
		if (rg.h.al == 0x1a && (rg.h.bl == 7 || rg.h.bl == 8)) {
			/* Function is supported and it's a PS/2 50,60,80 with
			   analog display, so it's VGA (I hope!) */
			vgaexist = TRUE;
		} else {
			/* Either BIOS function not supported or something
			   other then VGA so set it to be EGA */
			vgaexist = FALSE;
		}
	}
	return(type);
}

PASCAL NEAR egaopen()	/* init the computer to work with the EGA or VGA */

{
	/* put the beast into EGA 43/VGA 50 line mode */
	rg.x.ax = 3;
	int86(16, &rg, &rg);

	rg.h.ah = 17;		/* set char. generator function code */
	rg.h.al = 18;		/*  to 8 by 8 double dot ROM         */
	rg.h.bl = 0;		/* block 0                           */
	int86(16, &rg, &rg);

	rg.h.ah = 18;		/* alternate select function code    */
	rg.h.al = 0;		/* clear AL for no good reason       */
	rg.h.bl = 32;		/* alt. print screen routine         */
	int86(16, &rg, &rg);

	rg.h.ah = 1;		/* set cursor size function code */
	rg.x.cx = 0x0607;	/* turn cursor on code */
	int86(0x10, &rg, &rg);

	outp(0x3d4, 10);	/* video bios bug patch */
	outp(0x3d5, 6);
}

PASCAL NEAR egaclose()

{
	/* put the beast into 80 column mode */
	rg.x.ax = 3;
	int86(16, &rg, &rg);
}

PASCAL NEAR scwrite(row, outstr, forg, bacg)	/* write a line out*/

int row;	/* row of screen to place outstr on */
char *outstr;	/* string to write out (must be term.t_ncol long) */
int forg;	/* forground color of string to write */
int bacg;	/* background color */

{
	unsigned int attr;	/* attribute byte mask to place in RAM */
	unsigned int *lnptr;	/* pointer to the destination line */
	int i;

	/* build the attribute byte and setup the screen pointer */
#if	COLOR
	if (dtype != CDMONO)
		attr = (((ctrans[bacg] & 15) << 4) | (ctrans[forg] & 15)) << 8;
	else
		attr = (((bacg & 15) << 4) | (forg & 15)) << 8;
#else
	attr = (((bacg & 15) << 4) | (forg & 15)) << 8;
#endif
	lnptr = &sline[0];
	for (i=0; i<term.t_ncol; i++)
		*lnptr++ = (outstr[i] & 255) | attr;

	if (flickcode && (dtype == CDCGA)) {
		/* wait for vertical retrace to be off */
		while ((inp(0x3da) & 8))
			;
	
		/* and to be back on */
		while ((inp(0x3da) & 8) == 0)
			;
	}

	/* and send the string out */
	movmem(&sline[0], scptr[row],term.t_ncol*2);
}

#if	FLABEL
PASCAL NEAR fnclabel(f, n)	/* label a function key */

int f,n;	/* default flag, numeric argument [unused] */

{
	/* on machines with no function keys...don't bother */
	return(TRUE);
}
#endif
#else
ibmhello()
{
}
#endif

