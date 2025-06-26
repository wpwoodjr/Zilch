***  AAA  *********************************************************************
*
*			Include Library for the 
*           University of Wisconsin Genetics Computer Group
*	
*	 Copyright (c) August 1983 John Devereux and Paul Haeberli
*
*		 Revised for UWGCG release 3.0 June 1985.
*
*******************************************************************************
***  CLCommon  *****************************************************************
*
*   contains common variables used by the command line primitives.
*
********************************************************************************

	Implicit None

	Common /CLCommon/ PCount, QCount, Ready, NoInteract,
     *			  Quals, QValues, CLComLine, Params

	Integer PCount, QCount
	Logical Ready, NoInteract
	Character Params(132,100), Quals(25,100), QValues(100,100)
	Character CLComLine(2000)

***  End ! of CLCommon  ********************************************************
******************************************************************************
**
**	Common block containing default values for the size of the plot,
**	positions of the labels, frame boxes and scale maximum
**
******************************************************************************

	Implicit None

	Common /CodonPrefCommon/ PHeight, PLength, APLength, 
     *				 XIndent, YIndent,
     *				 MinY, MaxY, ScaleMax, FrameLine,
     *				 Window, Density, CmDensity, Threshold, 
     *				 AcidArray,
     *				 NoPlot, NoRare, NoFrame, AllFrame, 
     *				 ToFile, Table, Publish,
     *				 StartAcid, StopAcid,
     *				 LCHeight, TCHeight,
     *				 Black, Green, Blue, Red

* the size and offset of the plot port in percent platten units
* APLength is used for the absolute PLength for label location on 
* plot ports that do not use all of PLength

	Real PHeight/80.0/, PLength/120.0/, APLength/120.0/
	Real XIndent/13.0/, YIndent/10.0/

* the fractions of the plot port for each plot window

	Real MinY(3)/0.050, 0.383, 0.716/, MaxY(3)/0.333, 0.666, 1.0/

* the scale maximum for codonpreference

	Real ScaleMax/2.25/

* the hieght in the plot port of the frame lines

	Real FrameLine(3)/0.025, 0.358, 0.691/

* the window in codons

	Integer Window/25/

* the density and threshold for rare codon display

	Real Density, CmDensity, Threshold/0.1/

* the genetics code

	Character AcidArray(5,5,5)

* command line logicals control plot and output file options

	Logical NoPlot, NoRare, NoFrame, AllFrame
	Logical ToFile, Table, Publish

* the constants for the start and stop codons

	Character StartAcid/'M'/, StopAcid/'*'/

* Character heights for labels

	Real LCHeight/1.5/, TCHeight/1.0/

* the pen colors

	Integer Black/1/, Green/2/, Blue/3/, Red/4/

* END ! of CommonLib(CodonPref)
***  DBCommon  ****************************************************************
*
*    This file containss the data structures and common block allocations
*    for a UWGCG interface to NBRF files.
*
*******************************************************************************

	Parameter DBINDICATOR = 20 000
	Parameter MAXINDEXSIZE = 10 000

	Structure /DBEntry/
	  Character DBName(64)
	  Integer SeqPtr, RefPtr
	  Integer CurSeqPtr, CurRefPtr
	  Integer SEQFile, REFFile, IndFile
	  Logical Active
	End Structure

	Common /DataBaseCommon/ DBEntries, NumDBEntries,
     *		CacheSeqPtr, CacheRefPtr, CacheName

	Record /DBEntry/ DBEntries(25)
	Integer NumDBEntries
	Integer CacheSeqPtr, CacheRefPtr
	Character CacheName(256)
**  DOTCOMMON  ****************************************************************
*
*	contains the common block used by DOTPLOT
*
*******************************************************************************

	Implicit None

	Common / DotCommon / 

     *	PointArray, NPoints,       ! the points for "dot-plotting"

     *	Pleft, Pright, Pbot, Ptop, ! unrestricted port
     *	Mleft, Mright, Mbot, Mtop, ! metric unrestricted window

     *	PPleft, PPright, 
     *	PPbot, PPtop,              ! plot port

     *  PlotX1, PlotX2, 
     *	PlotY1, PlotY2,            ! metric plot window

     *	Left, Right,		   ! sequence units of plot window
     *	Bot, Top,		   ! +/- 1.0 for axes

     *  DivX1, DivX2, DivY1, DivY2,! divider rectangle

     *	HorLabX, HorLabY, 
     *	VrtLabX, VrtLabY,          ! label locations
     *	TimLabX, TimLabY, 
     *	ParaLabX, ParaLabY,

     *  TCHeight, LCHeight,        ! label char sizes

     *  LabelColor, AxisColor,     ! color of each component
     *	DivColor, PointColor,

     *	HorSeqName, VrtSeqName,    ! define the sequences
     *  HorBegin, VrtBegin, 
     *  HorEnd,VrtEnd,
     *  HorCheck, VrtCheck,
     *  HorRev, VrtRev,
     *  HorPoints, VrtPoints,      ! number of points perpage
     *  HorPage, VrtPage,          ! actual page being plotted
     *  HorPlots, VrtPlots, Nplots,! number of pages
     *  HorStartFin, VrtStartFin,  ! seq numbers for each page
     *	FastDiagonal, FastPlot,
     *	Axis, TopOnly, CutOff,     ! extra plot features
     *  TickLabels, Feed,
     *  Window,	Base, Word, 	   ! parameters from COMPARE 
     *	Stringency, Density

	Integer PointArray(2,200 000), Npoints
	Real Pleft, Pright, Pbot, Ptop
	Real Mleft, Mright, Mbot, Mtop

	Real PPleft, PPright, PPbot, PPtop
	Real PlotX1, PlotX2, PlotY1, PlotY2
	Real Left, Right, Bot, Top

 	Real DivX1, DivX2, DivY1, DivY2
	Real HorLabX, HorLabY, VrtLabX, VrtLabY
	Real TimLabX, TimLabY, ParaLabX, ParaLabY
	Real TCHeight, LCHeight

	Integer LabelColor, AxisColor, DivColor, PointColor

	Character HorSeqName(132), VrtSeqName(132)
	Integer HorBegin, VrtBegin, HorEnd, VrtEnd
	Integer HorCheck, VrtCheck
	Logical HorRev, VrtRev
	Integer HorPoints, VrtPoints
	Integer HorPage, VrtPage
	Integer HorPlots, VrtPlots, Nplots
	Integer HorStartFin(2,30), VrtStartFin(2,30) 

	Logical FastDiagonal, FastPlot, Axis, TopOnly, CutOff
	Character TickLabels(132)
	Integer Feed
	Integer Window, Base
	Logical Word
	Real Stringency, Density
***  GCGTime  *****************************************************************
*
*    This module contains the structure definition used by the time and
*    date handling primitives.  Applications that manipulate time should
*    include 'commonlib(gcgtime)'.
*
*******************************************************************************

	Structure /GCGTime/
	  Integer Year, Month, Day
	  Integer Hour, Minute
	  Real Second
	End Structure
***  GKS  **********************************************************************
*
*	included common block for GKS plot driver
*
********************************************************************************

	Include 'CommonLib(PlotBlock)'

	Common /GKSBlock/ Segs, LineMacro, NLineStyles,
     *	UserXForm, TextXForm, Rotate, PolyX, PolyY, RevX, RevY

	Integer MaxPSegs
	Parameter ( MaxPSegs = 1000 )

	Integer Segs
	Logical LineMacro
	Integer NLineStyles
	Integer UserXForm/1/, TextXForm/2/
	Logical Rotate
	Real PolyX(MaxPSegs), PolyY(MaxPSegs)
	Logical RevX, RevY

* Function Declaration

	Logical VMSInterrupt

***	End ! of GKS  (common block for UWGCG GKS plot driver)  ****************
***  HPGL  *********************************************************************
*
*	included common block for HPGL plot driver
*
********************************************************************************

	Include 'CommonLib(PlotBlock)'

	Common /HPGLBlock/ PSegs, LSegs, LineMacro, MaxPSegs, 
     *			   MaxLSegs, PageFeed, A4, TextFirstCall

	Integer PSegs/0/, LSegs
	Logical LineMacro/.false./
	Integer MaxPSegs/100/, MaxLSegs/100 000/
	Integer PageFeed/0/
	Logical A4, TextFirstCall

	Logical VMSInterrupt

***	End ! of HPGL  (common block for UWGCG HPGL plot driver)  **************
***  LineUpCommonBlock  ***************************************************************
*
*	the include file for LINEUP
*
*******************************************************************************

	common /LINEUPblock/ SeqTable, NumSeqs,
     *		RowTable, RowCache, NumWRows, NumWCols, 
     *		WHMargin, WVMargin,
     *		CurrentRow, CurrentOffset, TentativeOffset, MaxHeadingLines,
     *		MemSlopTerm, RowSlopTerm, WLeftCol, WTopRow,
     *		debugout, debugcode, charmap, ActiveSeq, MaxRow, MinRow,
     *		MaxOffset, MinOffset, SeqGroupName, markloc, markchar,
     *		DefaultConsensus, ConsensusRow, ConsensusEntry, AutoCons,
     *		LikesSpaceWalk, IsNucleotide, CharClass, FileFormat,
     *		ConsExten, FragExten, MSFExten, FOSNExten, LikesCons,
     *		SingleCommand

	integer NAMELEN
	Parameter ( NAMELEN = 10 )

* types

	Structure /EntrySeqTable/ 
	   Character SeqName(NAMELEN)
	   Integer SeqSeg     	! index to SegBases for sequence storage.
				! This field is ZERO when entry not in use.
	   Integer HeadingSeg	! index to SegBases for heading storage.
	   Integer NumHeadingLines ! Number of lines in this heading
	   Integer SeqOffset	! start of this sequence ruler position.
	   Integer SeqLen	! length of sequence
	   Integer DisplayRow	! which row this sequence appears in.
	   Character Strand	! '+' = 5', '-' = 3'.
	   Integer Score	! vestige of wordsearch.  Just preserved.
	   Integer Width	! vestige of wordsearch.  Just preserved.
	   Real    Weight	! vestige of pretty.  Just preserved.
	   Integer NextSeq, LastSeq	
		! 'pointers' to neighbor sequences on the same row in the 
		! display.  The sequences in a row in the sequence comparison 
		! chart are stored in a linked list sorted by offset.
	end Structure

* RowTable limits
	integer HighRow, LowRow
	parameter ( HighRow = 15, LowRow = -15 )
	integer MaxSeqs
	parameter ( MaxSeqs = 500 )

	Integer MaxRows  ! max number of rows in sequence comparison chart.
        parameter ( MaxRows = HighRow - LowRow )
*globals
	Character SeqGroupName(256)

	Record /EntrySeqTable/ SeqTable(MaxSeqs)  
		!  A sequence descriptor is an index into this table.

	Integer NumSeqs	! number of sequences stored currently

	Integer RowTable(LowRow:HighRow)	
		! pointers to first sequence in row as ordered by offset 

	Integer RowCache(LowRow:HighRow)
		! pointers to roughly the most recently touched 
		! sequences in each row.

	Integer ActiveSeq  !  index to SeqTable of seq most recently used

	Integer MinOffset, MaxOffset
		! range of values active

	Integer MinRow, MaxRow
		!  range of row values active.  MUST NOT INDEX AN EMPTY ROW!

* Attributes of the sequence display window:

	Integer WTopRow	! Row of Seq comparison chart currently 
		! displayed in the top window row.  Initialized by
		! LoadMultSeq.

	Integer WLeftCol	! left most col displayed in the window.
		! Initialized by LoadMultSeq

* Current position in the sequence display

	Integer CurrentRow, CurrentOffset 
		! current position in the sequence comparison chart

	Integer TentativeOffset
		! position only tentative while doing vertical motion.

* consensus attributes

	Integer DefaultConsensus/0/, ConsensusRow, ConsensusEntry

* assorted horse shit

	Integer MaxHeadingLines/100/ ! max number of heading lines to be stored.

	Integer MemSlopTerm/100/ ! margin for growth in the memory allocation

	Integer RowSlopTerm/100/ ! margin for growth in the row selection

	character charmap(0:255)

	integer markloc(129)
	character markchar(129)

* debug variables

	integer debugout, debugcode/0/  !  channel and control resp.    

* State variable:  is the consensus updated with each change?

	Logical AutoCons

* State variable:  Does the user like to use SpaceWalk?

	Logical LikesSpaceWalk

* is the sequence a nucleotide sequence for the purposes of consensus def?

	Logical IsNucleotide

* Used to define consensus...does AlphaToNum by table lookup for speed.

	Integer CharClass (0:255)

* Do I want File Of File Names (FOSN) or Mutliple Sequence File (MSF) format?

	Integer FileFormat
	Integer FOSN, MSF
	Parameter (FOSN = 1, MSF = 2)

* GetFragName needs to know if the name is new or a rename.  This is because
* a new (meaning empty) sequence can be created as the consensus, but another
* sequence cannot be made the consensus.

	Integer RENAME, NEW
	Parameter (RENAME = 1, NEW = 2)

* What are the default file extentions for the consensus seq and the
* observation seqs (Frags) in the FOSN case:

	Character ConsExten(10), FragExten(10)

* File extentions for MSF and FOSN files

	Character MSFExten(10), FOSNExten(10)

* Does the user want there to be a consensus in a new group by default?

	Logical LikesCons

* should there only be one command given before returning to screen mode?

	Logical SingleCommand

* Parameters discribing the sequence display window:

	Integer WTop/2/, WBot/17/, WLeft/5/, WRight/79/
	Integer NumWRows/16/	! Number of screen rows in display window.
	Integer NumWCols/75/	! Number of cols in display window.
	Integer WHMargin/10/	! Horizontal margin in window for scrolling
	Integer WVMargin/2/	! Vertical margin in window for scrolling

* Control characters

	character BACKSPACE, ESC, CTLZ, NULL, DEL, CARRET, CTLR
	character CTLE, CTLH, CTLC, CTLD, CTLI

	Parameter ( BACKSPACE=Char(8), ESC=Char(27), CTLZ=Char(26) ) 
	Parameter ( NULL=Char(0), DEL=Char(127), CARRET=Char(13) )
	Parameter ( CTLR=Char(18), CTLE=Char(5), CTLH=Char(8) )
	Parameter ( CTLC=Char(3), CTLD=Char(4), CTLI=Char(9) )
                        



* Paul's function declarations.  Some sifting and winowing is in order.

	Character GetCh, ToUpper, ToLower, xchar
	Integer StrFind, StrLen,  CheckSeq, StrToken, cistrfind
	Integer delbases, getcmd, insertbase, goodscalelen, drawbar
	Logical IsFile, Openf, IsUWGCG, IsDigit, IsLower
	Logical cmdmatch, nameok, StrMatch, GetDataFile, StrToInt
	Logical IsWhite, MoreChars, StrToReal

* functions

	character TwGetCh
	integer ILimit, TwArrow

* parameters 

	Integer NOADDR
	Integer CHECKSTR, ORIGSTR
	Integer CSCREEN, CNULL,  CFIND, CHEADING, CDEBUG
	Integer CHELP,  CWRITE,  CWQ,   CEDIT, CDELETE
	Integer CGET, CREDRAW, CQUIT, CFILE, CCOM, CINCL, CMARK
	integer CNEW, CMOVE, CCONS, CREMOVE, CAUTO, CNOAUTO, CRENAME
	integer CSPACEWALK, CNOSPACEWALK, CNUCLEOTIDE, CNONUCLEOTIDE
	integer CMSF, CFOSN, CPRINT, CSLIDE, CGOTO, CSUMMARY, CROWMOVE
	Character NEWLINE
	Character CNTRLL, CNTRLR
	Character CNTRLZ

	Parameter ( NOADDR = 1 000 000 )  !  also defined in TwTextEdit
	Parameter ( CHECKSTR = 0, ORIGSTR = 1 )

	Parameter ( CNULL  = 0,  CDEBUG	 = 1,  CFIND   = 2 )
	Parameter ( CHELP  = 3,  CWRITE  = 4,  CWQ     = 5 )
	Parameter ( CEDIT  = 6,  CDELETE = 8 )
	Parameter ( CGET   = 9,	 CREDRAW = 10, CQUIT   = 11 )
	Parameter ( CFILE  = 12, CCOM    = 13, CINCL   = 14 )        
	Parameter ( CMARK  = 15, CHEADING = 16, CSCREEN = 17 )        
	Parameter ( CNEW   = 18, CMOVE   = 19, CCONS   = 20 )
	Parameter ( CREMOVE = 21,CAUTO   = 22, CNOAUTO = 23 )
	Parameter ( CRENAME = 24,CSPACEWALK=25, CNOSPACEWALK=26 )   
	Parameter ( CNUCLEOTIDE = 27, CNONUCLEOTIDE = 28 )
	Parameter ( CMSF = 29, CFOSN = 30, CPRINT = 31 )
	Parameter ( CSLIDE = 32, CGOTO = 33, CSUMMARY = 34 )
	Parameter ( CROWMOVE = 35 )
	Parameter (NEWLINE=Char(10) )
	Parameter (CNTRLL=Char(12), CNTRLR=Char(18) )
	Parameter (CNTRLZ=Char(26))



* end ! of include file for LINEUP
***  MapPlasmid  ***************************************************************
*
*    common block for the program MAPPLASMID
*
********************************************************************************

	Implicit None

*******************************************************************************
*
*	F I X E D   P A R A M E T E R S
*
*******************************************************************************

	Integer ArraySize, MaxInfo, MaxLabSize,
     *		black, green, blue, red, MAXREM
   
	Parameter (ArraySize  = 520,	!  space allotted for record arrays
     *		   MaxInfo    = 500,	!  max number of pieces of info.
     *		   MaxLabSize =  50,	!  space allotted for a label
     *		   black = 1,		!  \/    \/    \/     \/     \/
     *		   green = 2,		!  the color codes for the plotter,
     *		   blue  = 3,		!  set by calling WNewColor.
     *		   red   = 4,		!  /\    /\    /\     /\     /\
     *		   MAXREM = 10)		!  number of below-circle remarks

*******************************************************************************
*
*	S T R U C T U R E   T Y P E   D E F I N I T I O N S
*
*******************************************************************************

	Structure /RawData/	!  record type for raw data from file
	  Integer  To,		!  beginning base number
     *		   From,	!  ending base number
     *		   Type,	!  type of information (how to be displayed)
     *		   EndStyle(2),	!  symbols at ends of ranges
     *		   Color,	!  label color
     *		   Strand
	  Character Label(MaxLabSize)    !  the label string
	End Structure

	Structure /RorBType/	!  record for processed range or block info
	  Integer LabStrLen,	!  the number of characters in label
     *		  RingPlace,	!  the number of ring where placed
     *		  LabelPtr	!  points to label information (rawdata)
	  Real    Center,	!  the center of the range (in degrees)
     *		  LabelSpan,	!  angular span of the label
     *		  SegSpan	!  the span of the arc (ignoring the
				!  label arc contribution)
	End Structure

	Structure /TickType/	!  record type for processed tick info
	  Real    Angle,	!  the angular location of the tick
     *		  ExtAng,	!  the angle of the tick extension
     *		  ExtLen	!  the length of the tick extension
	  Integer PtrLabList	!  the pointer to the linked list of 
				!  index for the raw data 
				!  (containing labels)
	End Structure

	Structure /TLabList/	! record type for linked list of tick labels
	  Integer LabIndex,	! index of for TickData that has label info
     *		  Next		! pointer to next element of the linked list
	  Logical Equal		! equality with previous, or just proximity?
	End Structure

	Structure /Locations/	!  record type for cartesian co-ordinates
	  Real X, Y
	  Logical  ToTheRight	!  does text go to the right from location?
	  Character Delim	!  what character separates labels?
	End Structure

*******************************************************************************
*
*	C O M M O N   B L O C K
*
*******************************************************************************

	COMMON	DNALength, CheckSum, NumSpacing, ColorPtr, 
     *		BoldLayers, CircleLayers, Tick, Range, Block,
     *		plus, minus,
     *		XDim, YDim, MMToPlatConv, MMPenWidth, 
     *		PenWidth, margin, MaxY,		
     *		EdgeLength, Aspect, CirRad, Features, 
     *		Ticks, TLabelList, TLabLoc, DelimLoc,
     *		NumOfTicks, TPtrs, TColorList,
     *		NumOfDelims, QuadFirst, QuadLast, BaseTick, ExtendLn,
     *		DefTCharHeight, MinTCharHeight, TCharHeight, TCharWidth,
     *		NumberHeight, LineSpac, space, close, XImag, YImag,
     *		CrowdLine, EmptyQuad, Ranges, NumOfRanges, NumRRIngs, 
     *		NoSymbol, ArrowHead, ArrowTail, 
     *		JunctionHead, JunctionTail, Bar, 
     *		RColorList, DefRCharHeight, RCharHeight,
     *		DefRSpacing, RSpacing, MinRSpacing, ROuterRing, 
     *		MinRRadius, TextSpaceConst, 
     *		Blocks, NumOfBlocks, NumBRings, BColorList, BWidth, 
     *		DefBCharHeight, BCharHeight,
     *		MaxBRadius, MinBRadius, 
     *		TitleHeight, Title, IDLine, IDLine2, Remarks, NumRemarks,
     *		BoldRanges, BoldCircle,  BoldMajTicks,
     *		DrawScale, DrawRays, NoArcText, 
     *		InnerNumbers, OuterNumbers, 
     *		NoSortRanges, NoSortBlocks, 
     *		ShowTitle, ShowCaption, HalfShade,
     *		XHashDensity, NoShading, sparse, medium, dense, solid,
     *		PlotLocation, WholePlaten, LeftCenter, RightCenter,
     *		NWcorner, SWcorner, NEcorner, SEcorner,
     *		OriginShow, ZERO, DNAEnd, Both,
     *		OriginEmphasis, NoEmphasis, Boldface, Parenthesis,
     *		Asterisks,
     *		MMTitleHeight, MMNumberHeight,
     *		MMTCharHeight, MMRCharHeight, MMBCharHeight,
     *		MMScaleTLength,
     *		TickColor, ScaleColor, RayColor, RangeColor, 
     *		NumberColor, DelimColor, TitleColor, 
     *		CircleColor, Separator1, Separator2

*******************************************************************************
*
*	G E N E R A L   I N F O R M A T I O N
*
*******************************************************************************

	Integer DNALength,	!  base length of the DNA
     *		CheckSum,	!  data code number
     *		NumSpacing,	!  spacing of numbered ticks
     *		ColorPtr(4),	!  for sorting colors of features
     *		BoldLayers,	!  number of layers for bold features
     *		CircleLayers,	!  number of layers for bold circle
     *		Tick/1/,	!  \/  \/  \/  \/  \/  \/  \/  \/  \/
     *		Range/2/,	!  codes for different types of attributes
     *		Block/3/,	!  /\  /\  /\  /\  /\  /\  /\  /\  /\
     *		PLUS/1/,
     *		MINUS/2/

	Real	XDim/150.0/,	!  platen's X dimension
     *		YDim/100.0/,	!  platen's Y dimension
     *		MMToPlatConv/0.3937/,	!  converts mm. to platen units
     *		MMPenWidth/0.268/,	!  pen width in millimeters
     *		PenWidth,	!  pen width in % platen units
     *		Margin,		!  margin above and below map
     *		MaxY,		!  maximum Y - coordinate of the map
     *		EdgeLength,	!  size of edge of square viewport
     *		Aspect/0.6/,	!  character aspect throughout display
     *		CirRad		!  the outer circle radius

	Record	/RawData/ Features(ArraySize)	! holds the unprocessed
						! information about all
						! of the ticks (points),
						! ranges, and blocks.

*******************************************************************************
*
*	T I C K - R E L A T E D   I N F O R M A T I O N
*
*******************************************************************************

	Record /TickType/ Ticks(ArraySize)		! holds the processed
							! tick information

	Record /TLabList/ TLabelList(ArraySize)		! the linked list of
							! pointers to labels

	Record /Locations/ TLabLoc(ArraySize),		! TLabel text origin
     *			   DelimLoc(ArraySize)		! delimiter location

	Integer	NumOfTicks,		!  the number of ticks
     *		TPtrs(ArraySize),	!  the sorted tick pointers
     *		TColorList(4, ArraySize), ! color sorting of ticks
     *		NumOfDelims,		!  the number of delimiters
     *		QuadFirst(4),		!  indices of most equatorial ticks
     *		QuadLast(4)		!  indices of ticks closest to top

	Real	BaseTick,	!  length of the straight part of tick
     *		ExtendLn,	!  default length of tick extension
     *		DefTCharHeight/1.3/, ! default character height of tick labels
     *		MinTCharHeight, !  minimum character height of tick labels
     *		TCharHeight,	!  actual character height of tick labels
     *		TCharWidth,	!  the character width  of tick labels
     *		NumberHeight,	!  height of scale numbers inside circle
     *		LineSpac,	!  min. vertical dist. between tick labels
     *		space,		!  the space between tick end and text
     *		close,		!  related to horizontal tick separation
     *		XImag,		!  imaginary X to place tick labels
     *		YImag,		!  imaginary Y to place tick labels
     *		CrowdLine/0.69/ !  beyond which is the most crowd-prone

	Logical	EmptyQuad(4)	!  Are there no ticks in quadrant ?

	Character Separator1,	!  separates equal-base labels
     *		  Separator2	!  separates coalesced labels

*******************************************************************************
*
*	R A N G E - R E L A T E D   I N F O R M A T I O N
*
*******************************************************************************

	Record /RorBType/ Ranges(MaxInfo)	! record for the processed
						! range information

	Integer	NumOfRanges,		!  the number of ranges      
     *		NumRRings,		!  the number of rings for ranges
     *		NoSymbol/0/,		!  \/  \/  \/  \/  \/  \/  \/  \/  \/
     *		ArrowHead/1/,		!  \/  \/  \/  \/  \/  \/  \/  \/  \/
     *		ArrowTail/2/,		!  integer codes for different end
     *		JunctionHead/3/,	!  symbols for the end of ranges.
     *		JunctionTail/4/,	!  /\  /\  /\  /\  /\  /\  /\  /\  /\
     *		Bar/5/,			!  /\  /\  /\  /\  /\  /\  /\  /\  /\
     *		RColorList(4,MaxInfo)	! pointers to color sorted ranges

	Real	DefRCharHeight/1.1/,	! default range character height
     *		RCharHeight,		!  actual range character height
     *		DefRSpacing,	!  default spacing between range rings
     *		RSpacing,	!  actual  spacing between range rings
     *		MinRSpacing,	!  the minimum spacing of ranges
     *		ROuterRing,	!  the radius of the outer ring of ranges
     *		MinRRadius,	!  the minimum radius for innermost range
     *		TextSpaceConst	!  ( __ * RCharHeight) is distance to text

*******************************************************************************
*
*	B L O C K - R E L A T E D   I N F O R M A T I O N
*
*******************************************************************************

	Record /RorBType/ Blocks(MaxInfo)	! record for the processed
						! block information

	Integer	NumOfBlocks,		!  the number of blocks
     *		NumBRings,		!  the number of rings used for blocks
     *		BColorList(4,MaxInfo)	! pointers to color sorted blocks

	Real	BWidth,			!  width of blocks
     *		DefBCharHeight/1.2/,	!  default block character height
     *		BCharHeight,		!  actual block char. hgt. (if it fits)
     *		MaxBRadius,	!  the maximum radius for outermost block
     *		MinBRadius	!  the minimum radius for innermost block

*******************************************************************************
*
*	T I T L E   I N F O R M A T I O N
*
*******************************************************************************

	Real		TitleHeight		!  the actual  title char height
	Character	Title(MaxLabSize),	!  the title string
     *			IDLine(256),		!  the identification strings
     *			IDLine2(256)		!  /\  /\  /\  /\  /\  /\  /\
	Character	Remarks(256,MAXREM)	!  remarks below the circle
	Integer		NumRemarks

*******************************************************************************
*
*	U S E R   O P T I O N S
*
*******************************************************************************

	Logical	BoldRanges,	! Draws over the ranges making thicker
     *		BoldCircle,	! Draws over the circle making thicker
     *		BoldMajTicks,	! Draws over major ticks making thicker
     *		DrawScale,	! draws scale ticks in a double circle
     *		DrawRays,	! draws radial dotted lines 
     *		NoArcText,	! supresses arc text
     *		InnerNumbers,	! draws scale numbered ticks on inside
     *		OuterNumbers,	! draws scale numbered ticks on outside
     *		NoSortRanges,	! cancels range size sort
     *		NoSortBlocks,	! cancels block size sort
     *		ShowTitle,	! show title text at center of the circle
     *		ShowCaption,	! show the identification caption
     *		HalfShade	! slanted lines instead of X-hatching

	Integer	XHashDensity,	! density of block shading (cross hashing)
     *		  NoShading/0/,	!       SHADING  CHOICES:
     *		  sparse/1/,
     *		  medium/2/,
     *		  dense/3/,
     *		  solid/4/,
     *		PlotLocation,		! part of platen on which to draw map
     *		  WholePlaten/1/,	! (1)  over the whole platen surface
     *		  LeftCenter/2/,	! (2)  left  half, vertically centered
     *		  RightCenter/3/,	! (3)  right half, vertically centered
     *		  NWcorner/4/,		! (4)  upper left  quarter of platen
     *		  SWcorner/5/,		! (5)  lower left  quarter of platen
     *		  NEcorner/6/,		! (6)  upper right quarter of platen
     *		  SEcorner/7/,		! (7)  lower right quarter of platen
     *		OriginShow,		! How is the origin to be labeled ?
     *		  ZERO/0/,		! (0)  display only the zero
     *		  DNAEnd/1/,		! (1)  display only DNALength (not ZERO)
     *		  Both/2/,		! (2)  display both (DNALength) in paran
     *		OriginEmphasis,		! If DNALength only is displayed :
     *		  NoEmphasis/0/,
     *		  BoldFace/1/,
     *		  Parenthesis/2/,
     *		  Asterisks/3/

*******************************************************************************
*
*	D E F A U L T   S I Z E S   F O R   C H A R A C T E R
*
*			H E I G H T S
*
*		( I N   M I L L I M E T E R S )
*
*******************************************************************************

	Real	MMNumberHeight,		!  height of the inner scale numbers
     *		MMTitleHeight,		!  height of the title characters
     *		MMTCharHeight,		!  height of the labels on the ticks
     *		MMRCharHeight,		!  height of the range labels
     *		MMBCharHeight,		!  height of the block labels
     *		MMScaleTLength		!  size of scale ticks inside the circle

*******************************************************************************
*
*	C O L O R   S E L E C T I O N
*
*******************************************************************************

	Integer	TickColor   /black/,	!  color of ticks
     *		ScaleColor  /green/,	!  color of scale ticks
     *		RayColor    /green/,	!  color of dotted line scale & numbers
     *		RangeColor  /black/,	!  color of ranges
     *		NumberColor /black/,	!  color of outside scale numbers
     *		DelimColor  /black/,	!  the color of the delimeter
     *		TitleColor  /blue/,	!  the color of the title
     *		CircleColor /green/	!  color of circle

*******************************************************************************
*
*	T Y P E   D E C L A R A T I O N S   O F   F U N C T I O N S
*
*******************************************************************************

	Integer	WQuadrant,	!  cartesian quadrant of an angle
     *		StrLen,		!  number of chars in string
     *		Duplicate	!  is this tick angle taken?

	Real	WDomain,	!  equivalent angle in  [ 0.0, 360.0 )
     *		WCharArcSpan,	!  the angular span of a character
     *		WPlCharArcSpan,	!  (same as above except uses plotblock)
     *		LineRelCenter,	!  the Y-component of end of tick
     *		LocAngle,	!  given base #, returns the angle
     *		ArgSign,	!  ArgSign(x) returns   ABS(x)/x
     *		ReadMapData	!  reads in the raw data about features

	Logical	WAngContain,	!  Does this arc contain that angle ?
     *		ROverLap,	!  Ranges overlap in their display ?
     *		BOverLap,	!  Blocks overlap in their display ?
     *		ODD		!  Is it an odd integer ?
***  MapPlot  *****************************************************************
*
*	Common block for the MapPlot program
*
*******************************************************************************

	Implicit None

	Common / MapPlotCommon / 
     *	Pleft, Pright, Pbot, Ptop, ! percent platten dimensions of port
     *	Mleft, Mright, Mbot, Mtop, ! metric units of window
     *	UserLeft, UserRight,       ! sequence units of window
     *  MCenter,                   ! center of sequence line in PP units
     *  Increment, Delta,          ! separation of lines, ticksize
     *  Epsilon,                   ! horizontal increment for mismatch ident
     *  StartHeight,               ! height of 1st line
     *  Height,                    ! height of current line
     *  LabelHeight, NumHeight,    ! for the doc line and numbering
     *  LinesPerPage,              ! digests shown on each page
     *  OutFile, Width,            ! file representing the MAPPLOT
     *	Append, Plot,              ! flags for plot, width
     *	Double,                    ! double size for screen plots
     *  TailCHeight, EnzCHeight,   ! character sizes
     *  HeadCHeight, NumCHeight,
     *  Silent, Superset, Perfect, ! command line states
     *  Circular, Ambiguity, SixBase, 
     *  Text                       ! for the headers

	Real Pleft, Pright, Pbot, Ptop
	Real Mleft, Mright, Mbot, Mtop
	Real UserLeft, UserRight, MCenter, Increment, Delta, Epsilon
	Real StartHeight, Height, LabelHeight, NumHeight
	Integer LinesPerPage
	Integer OutFile, Width/45/
	Logical Append, Plot, Double
	Real TailCHeight, EnzCHeight, HeadCHeight, NumCHeight
	Logical Silent, Superset, Perfect, Circular
	Logical Ambiguity, SixBase 
	Character Text(132)

***  End ! of MapPlot common block  ********************************************
***  MemCommon  ***************************************************************
*
*	Include file for any routine which will have access to the 
*	dynamically allocated memory.
*
*	The storage which is parselled out is the array mem.
*	The start positions of the segments of memory must be
*	implemented with a level of indirection so that compaction
*	may relocate the segments.  The array seq is for this purpose.
*
*******************************************************************************

	Implicit None

	common /memblock/ Mem, SegBase, NumSegs, SegSize

	Integer MAXSEGS
	Parameter (MAXSEGS = 1000)
	Integer MEMSIZE
	Parameter (MEMSIZE = 	2000000)

	character Mem(MEMSIZE)  !  storage carved and allocated by mem routines
	integer SegBase(MAXSEGS)   !  indirection for mem segment start indecies
	integer SegSize(MAXSEGS)   !  how big is this physical segment?
	integer NumSegs	        !  number of segments currently being used.

* parameters 
                               
	Character INUSE/17/, FREE/13/

* end ! of include file for uses of dynamically allocated memory.
***  NextFileCommon  **********************************************************
*
*	include file and common block for the NextFile utilities
*
*******************************************************************************

	Integer MaxStream
	Parameter (MaxStream=5)
	Integer MaxDepth
	Parameter (MaxDepth=5)
	Common / NextFileCommon / FABDepth, FABArray
	Integer FABDepth(MaxStream)
	Integer FABArray(MaxDepth,MaxStream)
***  PAT  **********************************************************************
*
*	UWGCG included common block for all sequence translation and one to 
*	three-letter amino acid mappings.  This common block may be 
*	included in an application program so that its data structures 
*	may be addressed directly.
*
********************************************************************************

	Implicit None

	Common /PATBlock/ Rec, Scan, MaxRec, Os, MisCount,
     *			  Mis, MinTry, MaxTry, Try, Offset,
     *			  SuperSet, Perfect, Subset, Mismatch,
     *                    ThisPat, MaxPat, PatLen, ThisLen,
     *			  Pat

	Integer Rec                ! the record being examined
        Integer Scan               ! the position in the sequence
        Integer MaxRec             ! how many records are there
        Integer Os                 ! offset for the find if found
        Integer MisCount           ! how many mismatches to here
        Integer Mis(20)            ! mismatches for the trys on this record
        Integer MinTry(20)         ! minimum number of tries
        Integer MaxTry(20)         ! maximum number of tries
        Integer Try(20)            ! how many have been tried
        Integer Offset(20)         ! total added to scan from this rec
	Logical SuperSet           ! The 3 kinds of binary comparison:
	Logical Perfect            !              -
	Logical Subset             !              -
        Integer Mismatch           ! the number of mismatches to allow
        Integer ThisPat(20)        ! index to pattern being tried
        Integer MaxPat(20)         ! number of patterns each record of Patts 
        Integer PatLen(20)         ! length of pattern in this record
        Integer ThisLen(20)        ! length added to scan by PATMATCH
        Character Pat(50,20)       ! has the patterns

***	End ! of PAT  (common block for pattern recognition)  ***********
***  PepPlot  *****************************************************************
**
**	common block and function declarations for PEPPLOT
**
** 	Assign values to plotting parameters
**
**	1: residue type and sequence
**	2: alpha beta prediction: Chou - Fasman
**	3: alpha beta N terminal prediction: Chou - Fasman
**	4: alpha beta C terminal prediction: Chou - Fasman
**	5: turn prediction: Chou - Fasman
**	6: hydrophobicity plot: Kyte - Doolittle
**	7: Structure Prediction: Garnier et al
**	8: helical hydrophobic moment alpha: Eisenberg et al
**	9: max angle of hel. hyd. mom.:alpha
**	10: helical hydrophobic moment beta: Eisenberg et al
**	11: max angle of hel. hyd. mom.:beta
**
**	Left      = indent from left side of platten in inches
**	PLength   = Length of plot in inches
**	Low       = indent up from bottom of platten in inches
**	PHeight   = height of plot in inches
**	MinY,MaxY = Upper and lower bounds of subplot as a fraction of 
**		    PHeight - used by WViewPort
**	MinScale, MaxScale = Upper and lower values of vertical scale 
**			     for subplot - used by WWindow
**	PenColor = Color to draw each plot, Beta is always the color of 
**		   alpha + 1
**	Window = Size of window used for each calculation - used mainly
**		 by getstartstop to set start and stop for the
**		 calculation
**	HorTLen, VrtTLen = tick lengths for the horizontal
**			   and vertical major ticks
**	CHeights   = heights for various characters
**
*******************************************************************************

	Implicit None

	Common /PepPlotCommon/ 
     *			Left, PLength, Low, Pheight, MinY, MaxY,
     *     		Minscale, Maxscale, Window, 
     *			HorTLen, VrtTLen,
     *			LabCHeight, TCHeight, SCHeight, BFCHeight,
     *			Black, Green, Blue, Red

	Real Left/2.0/, PLength/11.75/
	Real Low/0.7/, PHeight/8.0/
	Real MinY(11)/0.9, 0.6, 0.525, 0.45, 0.375, 0.0, 0.0, 0.25, 
     *		     0.25, 0.125, 0.125/
	Real MaxY(11)/1.0, 0.9, 0.6, 0.525, 0.45, 0.125, 0.0, 0.375,
     *		     0.375, 0.25, 0.25/
	Real MinScale(11)/-0.7, 0.5,  0.0,  0.0,    0.0, -3.0, -400.0,
     *			 0.0, 88.0, 0.0, 138.0/
	Real MaxScale(11)/ 0.5, 1.5, 15.0, 15.0, 0.0005,  3.0,  400.0, 
     *			  0.9, 112.0, 0.9, 182.0/
	Integer Window(11)/  1, 4, 6, 6, 4, 9, 17, 8, 8, 6, 6/
	Real HorTLen/.1/, VrtTLen/.1/
	Real LabCHeight/1.5/		! for the page headings
	Real TCHeight/1.0/		! for the ticks
	Real SCHeight/1.1/		! for the each measure heading
	Real BFCHeight/0.75/		! for the breaking/forming
	Integer Black/1/, Green/2/, Blue/3/, Red/4/
***  PepSortCommon  ***********************************************************
*
*	used by the program PepSort (PEPTIDESORT).
*
*******************************************************************************

	Implicit None

	Common / PepSortCommon /

     *	rWeight, rReten21, 
     *	rReten74, rCharge, weight,
     *	iBegin, iEnd,
     *	iAroma, iAcidity,
     *	iBaseness, iSulphur, 
     *	iPhilic, iPhobic,
     *	Indices, iContent,
     *  Charge, Aroma, Acidity, Baseness,
     *	Sulphur, Philic, Phobic, Reten21, Reten74

	Real rWeight(1000), rReten21(1000)
	Real rReten74(1000), rCharge(1000), Weight(32)

	Integer iBegin(1000),iEnd(1000)
	Integer iAroma(1000), iAcidity(1000)
	Integer iBaseness(1000), iSulphur(1000)
	Integer iPhilic(1000), iPhobic(1000)
	Integer Indices(1000), iContent(32,1000)

	Real Charge(32), Aroma(32), Acidity(32), Baseness(32)
	Real Sulphur(32), Philic(32), Phobic(32)
	Real Reten21(32), Reten74(32)
***  PLOTBLOCK   **************************************************************
*
*	included common block for UW plotting routines
*	BE SURE TO RECOMPILE ALL OF THE MODULES IN GENLIB THAT INCLUDE
*	THIS COMMON BLOCK OF ANY CHANGES ARE MADE.
*
*******************************************************************************

	Implicit None

	Common /PlotBlock/ Aspect, NColors, AutoPage, AutoCut,
     *		Width, Height, PlotIn, PlotOut, TermPort,
     *		LabelOrigin, Direction, CAspect, CHeight, CSlant,
     *		LineStyle, LinePeriod, SetLineStyle,
     *		HardLeft, HardRight, HardBot, HardTop,
     *		VPLeft, VPRight, VPBot, VPTop, XComp, YComp,
     *		UserLeft, UserRight, UserBot, UserTop, XPos, YPos,
     *		HorExpand, VrtExpand, HorShift, VrtShift,
     *		PointMacro, PenColor, PenSpeed, MaxPenSpeed,
     *		Slow, Black, Clipping, SetClipping, Device, Font, NFonts

* plotter physical qualities

	Real Aspect 		! aspect ratio of platten surface
	Integer NColors		! number of colors available
	Logical AutoPage 	! plotter feeds paper automatically
	Logical AutoCut 	! plotter cuts off paper automatically

* platten physical dimensions

	Real Width		! physical dimension of platten
	Real Height		! (in inches)

* logical unit for I/O to plotter

	Integer PlotIn		! logical unit for output (to plotter)
	Integer PlotOut		! logical unit for input  (to plotter)
	Logical TermPort        ! plotter is BEHIND the terminal

* text parameters

	Integer LabelOrigin	! relation of label to pen position
	Real Direction		! direction to make labels

* character parameters

	Real CAspect		! character aspect ratio
	Real CHeight		! character Height in mm
	Real CSlant		! slant of characters

* line drawing style

	Integer LineStyle	! type of lines to draw
	Real LinePeriod		! pattern repeat size in percent platten units
	Logical SetLineStyle    ! before next pen movement

* percent-platten units for whole platten

 	Real HardLeft, HardRight 	! percent-platten coordinates
 	Real HardBot, HardTop		! whole platten surface

* current View port in percent-platten units

 	Real VPLeft, VPRight 	! percent-platten dimensions for
 	Real VPBot, VPTop	! current view port
	Real XComp, YComp	! scaling for plot compression

* current user units mapped into current view port

 	Real UserLeft, UserRight 	! user coordinates (window) for
 	Real UserBot, UserTop		! current view port

* current pen position

	Real XPos, YPos		! current pen position

* expansion and shift for user units to keep ranges to 10,000 units

	Real HorExpand, VrtExpand	! keep user ranges to 10000 units
	Real HorShift, VrtShift		! within 16 bit range

* software state variable

	Logical PointMacro      ! Is the point macro set?
	Integer PenColor        ! pen currently in the plotter
	Real PenSpeed           ! current pen speed from 1.0-10.0
	Real MaxPenSpeed        ! current pen speed from 1.0-10.0

* command line global parameters

	Logical Slow		! command line switches for pen
	Logical Black		! control

* state of clipping

	Logical Clipping	! plot only within viewport
	Logical SetClipping	! clipping state has changed

* function delclarations for plotting routines

	Real RLimit, GetRealNum
	Integer ILimit
	Logical ComCheck

* a trivial name (number) for the device

	Integer Device

* the text font (0=firmware), NFonts is the number of fonts available

	Integer Font, NFonts 
***  PlotChou  ****************************************************************
*
*	common block for PlotChou
*
*******************************************************************************

	Common     / PlotChouCommon /
	1          Theta, R, D, Bnd,  Angle1, Rad,
	2          Angle, Angle2, Dir, Sgn, 
	3          Xpos, Ypos, XLeft, Xspan, YBot, Yspan, Sspan,
	4          SeqPOffset, IP, NInterval,
	5          HyPhilCurr, HydroLimit

	Real       Theta, R, D, Bnd(3),  Angle1, Rad
	Real       Angle, Angle2, Dir, Sgn
	Real       Xpos, Ypos, XLeft, Xspan, YBot, Yspan, Sspan
	Integer    SeqPOffset, IP, NInterval
	Real       HyPhilCurr, HydroLimit

***  End ! of PlotChou
**	Left      = indent from left side of platten in inches
**	PLength   = Length of plot in inches
**	Low       = indent up from bottom of platten in inches
**	PHeight   = height of plot in inches
**	PenColor = Color to draw each plot
**	Window = Size of window 
**	HorTLen, VrtTLen = tick lengths for the horizontal
**			   and vertical major ticks
**	CHeights   = heights for various characters
**
*******************************************************************************

	Common /Plotsim/ 
     *			Left, PLength, Low, Pheight, Window, 
     *			HorTLen, VrtTLen,
     *			LabCHeight, TCHeight, SCHeight, BFCHeight,
     *			Black, Green, Blue, Red

	Real Left/2.0/, PLength/11.75/
	Real Low/0.7/, PHeight/8.0/
	Integer Window/ 10 /
	Real HorTLen/.1/, VrtTLen/.1/
	Real LabCHeight/1.5/		! for the page headings
	Real TCHeight/1.0/		! for the ticks
	Real SCHeight/1.1/		! for the each measure heading
	Real BFCHeight/0.75/		! for the breaking/forming
	Integer Black/1/, Green/2/, Blue/3/, Red/4/
        common /polar/   XCenter, YCenter
        real             XCenter, YCenter
***  Publish  ******************************************************************
*
*	contains the common block for publish
*
********************************************************************************

	Implicit None

	Common  /PublishBlock/ 
     *	InFile, OutFile, 
     *	Strand, 
     *	Begin, End, Length,
     *	Menu, Numbering, SkipZero, Skip,
     *	LineBlock, Offset, BlockSize, 
     *	BlocksPer, Increment, 
     *	TransTable, OutLine 
 
	Integer InFile, OutFile
	Character Strand(100 001)
	Integer Begin, End, Length
	Character Menu(132)
	Logical Numbering(132), SkipZero, Skip(132) 
	character LineBlock(100 001,20)
	Integer Offset(132)
	Integer BlockSize, BlocksPer, Increment/10/
	Character TransTable(4096), OutLine(512)

***	End ! of Publish Common Block  *****************************************
***  QUICBLOCK   **************************************************************
*
*	included common block for QUIC specific UWGCG plotting routines
*
*******************************************************************************

	Common /QUICBlock/ 
     *		XRes,YRes,XScale,YScale,
     *		PixelsInPeriod,
     *		lf, ff,
     * 		dx,   dy,   tmin, tmax,
     *		xc,   yc,   xn,   yn,
     *		xc1,  xc2,  yc1,  yc2,
     *		uu1,  uu2,  vv1,  vv2,
     *		xmin, xmax, ymin, ymax,
     *		orientation,portrait,landscape,
     *		linewidth,
     *		nx2s, ny2s,
     *		nx1, nx2, ny1, ny2,
     *		open, clipset,
     *		nexteject,
     *		DefaultFont,
     *		Xorigin, Yorigin

* Platten physical dimensions, additional for raster device

	Real XRes		! Plotter divisions per inch
	Real YRes		! Plotter divisions per inch
	Real XScale		! Ease conversion to physical cood. 
	Real YScale		! Ease conversion to physical coord.

* LineStyle parameters

	Real PixelsInPeriod

	byte lf/10/, ff/12/

	Real dx,   dy,   tmin, tmax
	Real xc,   yc,   xn,   yn
	Real xc1,  xc2,  yc1,  yc2
	Real uu1,  uu2,  vv1,  vv2
	Real xmin, xmax, ymin, ymax

	integer orientation,portrait/0/,landscape/1/
	integer linewidth
	integer nx2s, ny2s
	integer nx1, nx2, ny1, ny2

	logical open, clipset
	logical nexteject

	integer DefaultFont
	Real Xorigin, Yorigin

***  Rastor  ************************************************************
*
*	Included common block for the rastor device driver.
*
*************************************************************************


	Common /Pixel_Map/ Pixel_Map, XRes, YRes, XScale, YScale,
     *		Printer, la50, la100,
     *		MapHeight, MapWidth, PrinterInSeries

	Byte Pixel_map(0:120 ,0:1715)  ! constructed image

* Platin physical dimensions

	Real XRes		! Plotter divisions per inch
	Real YRes		! Plotter divisions per inch
	Real XScale		! Ease conversion to physical coord.
	Real YScale		! same.

* Device code

	Integer Printer, la50/0/, la100/1/

* Physical Platin dimensions

	Integer MapHeight, MapWidth

* Is the printer on a pass-through port of the terminal, requiring 
* an escape sequence to use?

	Logical PrinterInSeries
***  ReGIS  ********************************************************************
*
*	This contains all ReGIS specific common variables.
*	
********************************************************************************


	Common /ReGISBlock/ PlatinHeight, PlatinWidth, PlatinBottom,
     *		LeftMargin, BottomMargin, PhysHorShift, PhysVrtShift,
     *		XTrans, YTrans, XCenter, YCenter, WasJustClipping,
     *		XPosClipped, YPosClipped, WantScreenBlanked

* Leave a margin around the portion of the platin used.
* (Without this text is clipped in some applications incl. DotPlot.)

	Integer PlatinHeight, PlatinWidth

* The VT241 has physical units which increase downward.  So all 
* coordinates sent for the verical axis are subtracted from the device's 
* idea of the bottom of the screen.

	Integer PlatinBottom

* These define the small boarder around the portion of the platin used.

	Integer LeftMargin, BottomMargin

* These are defined by WViewPort as the physical device unit distance 
* from the screen edge to the viewport boarder, including the margins.

	Real PhysHorShift, PhysVrtShift

* We allow the user to expand as well as compress the platin for the 
* VT241, since resolution is such a problem.  So we also allow her to pan
* by specifying a translation interactively.

	Real XTrans, YTrans

* compression must be done relative to the center of the platin.

	Real XCenter, YCenter

* Must be able to tell when have just been clipping incase the next call
* to WPoint, WMove, or WDraw is into the negative coordinate region of 
* the device where there are no absolute addresses and all positions must 
* be discribed in relative offsets.

	Logical WasJustClipping

* Store the real cursor position in the case that clipping is being 
* performed.  Then when clipping is turned off, the software can refer 
* to the real device position (in user units).

	Real XPosClipped, YPosClipped

* WNewPage sets this logical to indicate whether WPlotInit should blank 
* the screen.

	Logical WantScreenBlanked/.True./

* VMS trap interrupt (GCG) test function

	logical VMSInterrupt

***  End ! of ReGISBlock  ******************************************************
***  SeqEdCommon  *************************************************************
*
*	the include file for SEQED
*
*******************************************************************************

	Implicit None

	Common /SeqedBlock/ scalelen, seqpos, seqlen, modified, 
     *	   comlines, findseq, seqname, seq,
     *	   comments, chekseq,
     *	   scrseqlen, scredge, scrscalelen, scrbarlen,
     *	   charmap, checking, checkstart, checkfinish, strand,
     *	   logon, logfile, comtable, position, comsup,
     *	   markloc, markchar, blind, IsNucleotide, SingleCommand

	Integer scalelen, seqpos, seqlen, modified, comlines
	Character findseq(256), seqname(256), seq(100 001)
	Character comments(256,1000)
	Character chekseq(100 001)
	Integer scrseqlen, scredge, scrscalelen, scrbarlen
	Character charmap(0:255)
	logical checking
	Integer checkstart, checkfinish, strand, logon
	Integer LogFile
	Character ComTable(128,1000)
	Integer Position(1000)
	logical comsup
	integer markloc(129)
	character markchar(129)
	logical blind
	logical IsNucleotide
	logical SingleCommand  !  true -> return to screen mode after commands.

* parameters 

	Integer NOADDR
	Integer CHECKSTR, ORIGSTR
	Integer CSCREEN, CNULL,  CGO,   CFIND, CHEADING
	Integer CHELP,  CWRITE,  CWQ,   CEDIT, CREAD, CDELETE
	Integer CCHECK, CREDRAW, CQUIT, CFILE, CCOM, CINCL, CMARK
	Integer CNUC, CPROT
	Character NEWLINE, CNTRLH, ESC
	Character CNTRLL, CNTRLR, NULL
	Character CARRET, DEL, CNTRLZ, CNTRLE

	Parameter ( NOADDR = 1 000 000 )  !  also defined in TwTextEdit
	Parameter ( CHECKSTR = 0, ORIGSTR = 1 )

	Parameter ( CNULL  = 0,  CGO     = 1,  CFIND   = 2 )
	Parameter ( CHELP  = 3,  CWRITE  = 4,  CWQ     = 5 )
	Parameter ( CEDIT  = 6,  CREAD   = 7,  CDELETE = 8 )
	Parameter ( CCHECK = 9,  CREDRAW = 10, CQUIT   = 11 )
	Parameter ( CFILE  = 12, CCOM    = 13, CINCL   = 14 )
	Parameter ( CMARK  = 15, CHEADING = 16, CSCREEN = 17 )
	Parameter ( CNUC   = 18, CPROT   = 19 )
	Parameter ( NEWLINE=Char(10), CNTRLH=Char(8), ESC=Char(27) )
	Parameter ( CNTRLL=Char(12),  CNTRLR=Char(18),   NULL=Char(0) )
	Parameter ( CARRET=Char(13),  DEL=Char(127),   CNTRLZ=Char(26) )
	Parameter ( CNTRLE=Char(5) )

* function declarations

	Character ToUpper, ToLower, xchar, NumToAlpha, TwGetCh
	Character CChar
	Integer StrFind, StrLen,  CheckSeq, StrToken, cistrfind
	Integer delbases, getcmd, insertbase, goodscalelen, drawbar
	Integer ILimit, ComSize
	Integer TwArrow
	Logical IsFile, Openf, IsUWGCG, IsDigit, IsLower
	Logical cmdmatch, nameok, StrMatch, GetDataFile, StrToInt
	Logical IsWhite, MoreChars, LoadSeq, ReadSq

* end ! of include file for SEQED

**  STATPLOT  ******************************************************************
*
*	contains the common block used by STATPLOT
*
********************************************************************************

	Common / StatCommon / 

     *	Pointers, Array, NPoints,  ! the points for "stat-plotting"
     *  MaxPoints, FieldNames,	   ! name of each stat field
     *	Pleft, Pright, Pbot, Ptop, ! unrestricted port
     *	Mleft, Mright, Mbot, Mtop, ! metric unrestricted window

     *	PPleft, PPright, 
     *	PPbot, PPtop,              ! plot port

     *  PlotX1, PlotX2, 
     *	PlotY1, PlotY2,            ! metric whole plot window
     *  PlotWidth, PlotHeight,     ! metric sizes of plot- port

     *	Left, Right,		   ! sequence units of plot window
     *	Bot, Top,		   ! +/- 1.0 for axes

     *  DivX1, DivX2, DivY1, DivY2,! divider rectangle
     *  MarkY1, MarkY2,

     *	HorLabX, HorLabY, 
     *	VrtLabX, VrtLabY,          ! label locations
     *	TimLabX, TimLabY, 
     *	SeqLabX, SeqLabY,
     *	ProgLabX, ProgLabY,
     *	VrtTDivs, HorTDivs,

     *  TCHeight, LCHeight,        ! label char sizes

     *  LabelColor, AxisColor,     ! color of each component
     *	DivColor, CurveColor,

     *	SeqName, SeqLabel,	   ! define the sequences
     *  Begin, End, Check, Rev,
     *  HorPoints,		   ! number of points perpage
     *  Page,			   ! actual page being plotted
     *  Nplots,			   ! number of pages
     *  Field,			   ! field now being plotted
     *  NFields, MaxFields,	   ! number of fields in plot
     *  HorStartFin,		   ! seq numbers for each page
     *  VrtStartFin,		   ! stat ranges for each field
     *  VrtTSpace, TLen1, TLen2, FastPlot, CutOff, Consistent, Scaling,
     *	PointStyle, FullLabel, Feed, ProgLabel, Window, Density

	Integer Pointers(100 000)
	Real Array(100 000, 6)
	Integer Npoints, MaxPoints
	Character FieldNames(32,6)

	Real Pleft, Pright, Pbot, Ptop
	Real Mleft, Mright, Mbot, Mtop

	Real PPleft, PPright, PPbot, PPtop
	Real PlotX1, PlotX2, PlotY1, PlotY2
	Real PlotWidth, PlotHeight
	Real Left, Right, Bot, Top

 	Real DivX1, DivX2, DivY1, DivY2, MarkY1, MarkY2
	Real HorLabX, HorLabY, VrtLabX, VrtLabY
	Real TimLabX, TimLabY, SeqLabX, SeqLabY, ProgLabX, ProgLabY
	Integer HorTDivs, VrtTDivs
	Real TCHeight, LCHeight

	Integer LabelColor, AxisColor, DivColor, CurveColor

	Character SeqName(132), SeqLabel(132)
	Integer Begin, End, Check
	Logical Rev
	Integer HorPoints, Page
	Integer Nplots, Field, NFields, MaxFields
	Integer HorStartFin(2,30)
	Real    VrtStartFin(2,6), VrtTSpace(6), TLen1/2.2/, Tlen2/1.5/

	Logical FastPlot, CutOff, Consistent, Scaling
	Logical PointStyle, FullLabel
	Integer Feed
	Character ProgLabel(132)
	Integer Window
	Real Density

***	End ! of StatPlot Common  **********************************************
***  TESTCODE  *****************************************************************
*
*	contains the common block and include code for TESTCODE
*
********************************************************************************

	Implicit None

	Common / TestCommon / 

     *	PLeft, PRight, PBot, PTop,     ! unrestricted port
     *	MPLeft, MPRight, MPBot, MPTop, ! metric window of unrestricted port

     *	PPLeft, PPRight, 
     *	PPBot, PPTop,              ! whole plot port (maximum)

     *  PortRight,		   ! right side of actual port

     *  MPPLeft, MPPRight, 
     *	MPPBot, MPPTop, 	   ! metric window of whole plot port

     *	Left, Right,		   ! user units in the plot port
     *	Bot, Top,		   ! (+/- 1.0 for seq axis)

     *	FickBot, FickTop,	   ! fickett user units
     *	FickVBot, FickVTop,	   ! Window of vulnerability

     *	TopLabX, TopLabY1, TopLabY2, 
     *	SideLabX, SideLabY,        ! label locations

     *  MarkBot, MarkTop,	   ! mark regions of interest

     *  TCHeight, LCHeight,        ! label char sizes

     *  TLen, SymbolHeight,	   ! the tick length (mm)

     *  LabelColor, AxisColor,     ! color of each component
     *	CurveColor, FrameColor, 
     *  Window, Increment, HWind, SetIncrement


	Real PLeft, PRight, PBot, PTop
	Real MPLeft, MPRight, MPBot, MPTop

	Real PPLeft, PPRight, PPBot, PPTop
	Real PortRight
	Real MPPLeft, MPPRight, MPPBot, MPPTop
	Real Left, Right, Bot, Top
	Real FickBot, FickTop, FickVBot, FickVTop

	Real TopLabX, TopLabY1, TopLabY2, SideLabX, SideLabY
	Real MarkBot, MarkTop
	Real TCHeight, LCHeight, TLen, SymbolHeight

	Integer LabelColor, AxisColor, CurveColor, FrameColor
	Integer Window, Increment
	Real HWind
	Logical SetIncrement

***	End ! of TestCode Common Block  ****************************************
***  TRL  **********************************************************************
*
*	UWGCG included common block for all sequence translation and one to 
*	three-letter amino acid mappings.  This common block may be 
*	included in an application program so that its data structures 
*	may be addressed directly.
*
********************************************************************************

	Implicit None

	Common /TRLBlock/ TransFile, TransFName, TRLIsSet, TRLLocFile,
     *		          CodonSettings, AcidArray, Threelet, 
     *			  AmbCodons, TRLTable, StartStop

	Integer TransFile          ! the unit with the translation file
        Character TransFName(256)  ! the name of the translation file
	Logical TRLIsSet/.false./  ! has this common block been initialized?
	Logical TRLLocFile/.false./! user-specified translation scheme?
	Integer CodonSettings      ! number of file-specified codon changes
	Character AcidArray(5,5,5) ! genetic code <=> one letter amino acids
        Character ThreeLet(3,33)   ! three-letter names for UWGCG seq symbols
        Character AmbCodons(3,33)  ! ambiguous codons for each UWGCG symbol

* TRLTable has a UWGCG sequence symbol for every possible IUPAC codon
* index.  See GATCToCode and ReadTransTable

        Character TRLTable(0:15,0:15,0:15) ! amino acids for any IUPAC codon

* StartStop has a '+' for start codons, a '*' for 
* stop codons and a '.' for every other codon

	Character StartStop(5,5,5) ! shows starts and stops

***	End ! of TRL  (common block for UWGCG translation programs)  ***********
***  TwCommon  ****************************************************************
*
*	common block for the screen curses package
*
*******************************************************************************

	Implicit None

	Common /ScreenBlock/ TwOld,  TwOldX, TwOldY,
     *                       TwNew,  TwX,    TwY, 
     *			     TwDirt, TwBuffer, TwBuffPoint, TwBuffSize,
     *			     TwClear, TwPutBack, TwTopChar, TwScrWidth

	Character TwOld(0:79, 0:23)
	Integer TwOldX, TwOldY
	Character TwNew(0:79, 0:23)
	Integer TwX, TwY
	Logical TwDirt(0:23)
	Character TwBuffer(256)
	Integer TwBuffPoint, TwBuffSize/255/
	Logical TwClear
	Integer TwScrWidth/80/  ! will be set by command line eventually

* to handle escape sequences we allow unconsumed characters to be put 
* back in TwPutBack.  TwTopChar keeps track of where they are.


	Character TwPutBack(128)
	Integer TwTopChar/0/
C **  VMSInterrupt  ************************************************************
C **
C **	a common block used by the UWGCG interrupt handling routines
C **
C ******************************************************************************

	Implicit None

	Common /VMSInterruptCommon/ TrapSet, Reset, Sprung

	Logical TrapSet, Reset, Sprung
	
***	End ! of VMSInterrupt  *************************************************
**  WINDOWCOMMON  *************************************************************
*
*	contains the common block used by WINDOW
*
*******************************************************************************

	Common / WindowCommon / 

     *	Pointers, StatArray,	   ! the points for the output file
     *  NPoints,  FieldNames,	   ! name of each stat field
     *  Cuts, Observations,	   ! logical arrays for observations
     *  MaxStats, MaxSeg,	   ! maximum dimensions
     *  MaxPatChars, 
     *	SeqFName, Strand,	   ! define the sequences
     *  SeqBegin, SeqEnd, SeqCheck,
     *  SeqLen, Reverse,
     *  Menu, Patterns,
     *	Field,			   ! field now being calculated
     *  NFields,		   ! number of fields in analysis
     *  Window,	Shift,		   ! size and increment for sliding
     *	MisMatch, MaxMisMatch,	   ! allowed in pattern searches
     *  Circular, All, Perfect	   ! search globals

	Integer Pointers(100 000)
	Real StatArray(100 000, 6)
	Integer Npoints
	Character FieldNames(32,6), Cuts(100 100)
	Character Observations(100 000,11)
	Integer MaxStats, MaxSeg, MaxPatChars
	Character SeqFName(132), Strand(-100: 100 100)
	Integer SeqBegin, SeqEnd, SeqCheck, SeqLen
	Logical Reverse
	Character Menu(132), Patterns(32,2,6)
	Integer Field, NFields, Window, Shift, MisMatch, MaxMisMatch
	Logical Circular, All, Perfect
***  WORDSEARCH  ***************************************************************
*
*	contains the common block used by WordSearch (WORD.for)
*
********************************************************************************

	Implicit None

	Common / WordSearch / 

     *	HorSeqName, VrtSeqName, WildFName, OutFName,
     *  Seq, RSeq, Line,
     *  HorCode, HorHash, VrtCode, VrtHash, RVrtCode,
     *  HorLen, VrtLen, MaxVrtLen,
     *  HorCheck, VrtCheck,
     *  Reverse,
     *  Masking, Mask, MaskVector, MaskOffset, MaskLen,
     *	Window, WordSize, Width, MaxWord, Base, NBest, Stats,
     *  AllDiagonals, Protein, Monitor, Summary, 
     *  Segment, Score, Entry, Record, NameCheck,
     *  SScore, SEntry, SRecord, Pointers,
     *  ShiftHist, Pos, 
     *  HashTable, HitList, RHashTable, RHitList, OrdTable,
     *	ShiftBegin, ShiftEnd,
     *  Sum, Frame, AvHits, TotHits, HistSize, HistTot, Bptot,
     *	Sequences, Files, OutFile

* the file-name buffers

	Character HorSeqName(256), VrtSeqName(256), WildFName(256)
	Character OutFName(256)

* the sequence and line buffers

	Character Seq(100 001), RSeq(32 001), Line(256)

* the ordcode and hash code buffers

	Integer*2  HorCode(100 001), HorHash(100 001)
	Integer*2  VrtCode(32 001),  VrtHash(32 001)
	Integer*2 RVrtCode(32 001), RVrtHash(32 001)

* parameters defining the sequences

	Integer HorLen, VrtLen, MaxVrtLen/32 000/, HorCheck, VrtCheck

	Logical Reverse		! look at the reverse strand??
	Logical Masking		! is masking in effect (command line)
	Character Mask(132)	! the users mask
	Logical MaskVector(132)	! points in mask that must match
	Integer MaskOffset(132) ! the new matches for each movement of the mask
	Integer MaskLen		! the part of the mask need for WordSize
	Integer Window		! the WHOLE width of the word or mask
	Integer WordSize	! the actual hashing word size
	Integer Width/3/	! the window of histogram integration
	Integer MaxWord		! the largest wordsize for 2-byte addressing
	Integer Base		! the alphabet size (vertical composition)
	Integer NBest/25/	! the list size
	Integer Stats/0/
	Logical AllDiagonals	! show all diagonals
	Logical Protein		! the vertical sequence is a protein??
	Logical Monitor         ! shows each file on the screen
	Logical Summary         ! shows summary on the screen

* the list buffers

	Integer Segment
	Integer Score(1000)	! the structures figure of merit
	Integer Entry(1000)     ! the sequence entry number in multi-seq files
	Character Record(256, 1000)	! goodies about the structure
	Integer NameCheck(1000)	! the file name checksum for each diagonal
	Integer SScore(1000)	
	Integer SEntry(1000)
	Character SRecord(256, 1000)
	Integer Pointers(1000)	! Sort pointers for the list

	Integer*2 ShiftHist( -34 000: 100 133 ) ! the histogram
	Integer Pos

	Integer*2 HashTable(34 000)	! the hash table  (vertical sequence)
	Integer*2 HitList(32 000)	! the linked list     "         "

	Integer*2 RHashTable(34 000)	! the same for the opposite Strand
	Integer*2 RHitList(32 000)	! of the vertical sequence

	Integer*2 Ordtable(0:255)	! the OrdTable alphabet-filter

	Integer ShiftBegin, ShiftEnd	! the part of the histogram used

* figures summarizing the search

	Integer Sum, Frame, AvHits, TotHits
	Integer HistSize, HistTot, BpTot, Sequences, Files, OutFile

***  End ! of WORDSEARCH Common block  *****************************************
