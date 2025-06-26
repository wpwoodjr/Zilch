Here is another pseudo terminal driver, brought to you by Kevin
Carosso. This latest version is a modification of the driver by Dale
Moore at CMU, updated to VMS v4.?.

This is a DCL archive. Cut on the "cut here" line and execute the
resulting file.

----------------------------   cut here   ---------------------------------
$ show default
$ write sys$output "Creating 000README.TXT"
$ create 000README.TXT
$ DECK/DOLLARS="*$*$*EOD*$*$*"
These files make up a pseudo terminal driver for VAX/VMS.  This
driver runs under VMS version 4.x.  It will not work under VMS prior
to 4.  See PSEUDO.DOC for documentation and NOTES.TXT for my
additional comments and observations.

	/Kevin Carosso                   engvax!kvc @ CIT-VAX.ARPA
	 Hughes Aircraft Co.

	 September 16, 1985
*$*$*EOD*$*$*
$ write sys$output "Creating BUILD.COM"
$ create BUILD.COM
$ DECK/DOLLARS="*$*$*EOD*$*$*"
$ macro pydriver
$ macro ptdriver
$ link pydriver,p.opt/opt,sys$system:sys.stb/sel
$ link ptdriver,p.opt/opt,sys$system:sys.stb/sel
$ exit
*$*$*EOD*$*$*
$ write sys$output "Creating NOTES.TXT"
$ create NOTES.TXT
$ DECK/DOLLARS="*$*$*EOD*$*$*"
These notes should be considered an addition to the documentation
to be found in PSEUDO.DOC.  These notes document some enhancements
I have made to the drivers as well as some bugs I have found and not
been able to fix.  If you find more bugs or come up with a fix for
those mentioned here, PLEASE PLEASE PLEASE let me know ASAP!

First of all, I want to grant credit to the original authors of the
driver, they are listed at the beginning of the two source files.  In
private correspondence with Dale Moore at CMU, he has chosen to release the
driver to the public domain.  You should, therefore, feel free to go ahead
and use it.  There have been various incarnations of this driver in the
past.  I started with a version that was modified to run (just barely)
under VMS V4 and cleaned it up and made CONNECT/DISCONNECT and HANGUP work
consistently.  It's been tested on VMS V4 up through 4.2.

Load the two drivers as PYA0: and PTA0:.  Then, just assign a channel to
PYA0:, which will create a PYAn: and a PTAn: (the unit numbers just
go up).  Anything you write to that channel appears on the PT as if
typed at a terminal.  Any output to the terminal PTAn: is available to
be read from PYAn:.  The devices do flow control between one another
and all buffering.  So, you can just read, for example, with a 100
char buffer from PY and the read will complete with whatever number of
characters the QIO to the PT terminal had, anywhere from 1 to MAXBUF.
If the QIO to the PT had more chars than your read buffer, it'll just
fill the read buffer and return, and you can get the rest on the next
read.  It is very simple to use.

Also, if you assign a mailbox with the PYAn: device (use LIB$ASN_WTH_MBX
when assigning channel to PYA0:) you will get a MBX$_TRMHANGUP (or
something like that, see the VMS terminal driver doc in I/O User's
Guide) message in the mailbox whenever the terminal is hung-up.  Like
when a process logouts out of it or deassigns the last channel to the
device.  It works just like the HANGUP on terminals with modem signals.
You can even ignore the hangup message if you want, it only generates
the message in the mailbox, you can continue to use the device if you
choose after getting the message.

Should you deassign the PYAn: device, a DISCONNECT will be forced on
any process using the PTAn: device.  Just like dropping carrier on
a modem line.  If you have the TT2$M_DISCONNECT bit set in the
default terminal characteristics (TTY_DEFCHAR2 in SYSGEN), then you will
get a virtual terminal upon logging into a PTAn: device.  Then you
get CONNECT/DISCONNECT to work.  Really nice on network connections.

Note that, just as with normal VMS terminals, you will only get a
VTAn: if the line has the DISCONNECT terminal characteristic before
you log into it, and only if you use LOGINOUT to start a process on
the terminal.  Just sending a <CR> into the device as the first thing
will start up LOGINOUT just like a normal terminal.

There are currently two bugs in the drivers.  The first is very minor and
is actually a side-effect of the driver being cautious in order to prevent
possible problems.  If you have a virtual terminal associated with the
pseudo-terminal, and you deassign the last channel to the control device
(the PY device) then a DISCONNECT is forced on any process on the PT and
the PY and PT are both deleted.  In this case, the PT will not be deleted,
although the PY will and the PT will be marked as OFFLINE.  This is because
I rely on VMS to do the actual delete of the device and because the VT's
screw up the way device reference counts work, VMS never gets around to
deleting the device.  It is marked for delete, so anything you do (I like
SHOW TERM) will cause it to be zapped.  I could fix this by zapping the
device explicitly after forcing the DISCONNECT, however I am not convinced
that someone, somewhere, won't try to use the UCB and thus cause bad
things to occur.  Like I said, it's a bug because I'm possibly being too
careful.  Note that it DOES get deleted correctly if you do not have
a virtual terminal associated with the PT or if you have no processes
active on the PT when the PY and PT are to be deleted.

The second bug is nastier, though much rarer.  Sometimes, and I don't
know exactly when, a character may get munged that is being output to
the pseudo-terminal.  It appears to happen to the last <LF> after the
first output line after a noecho read, if the output line is a certain
length.  It also has been seen in other places, but that's the only one
I can reproduce semi-reliably.  The character is always changed into
the hex byte xC, where x is any nybble.  Thus, you get things like:
"l", "L", <FF>, ",", "<", etc...   I am working on this one, but it's
a bitch.  It seems to be more likely to occur during a small window
where there is no outstanding read on the master device, the PY.
Programs which do a lot of work between reads on the master device
are more likely to see this happen.

There are no known system-crashers or process killers.

Load the two drivers as PYA0: and PTA0:.  Then, just assign a channel to
PYA0:, which will create a PYAn: and a PTAn: (the unit numbers just
go up).  Anything you write to that channel appears on the PT as if
typed at a terminal.  Any output to the terminal PTAn: is available to
be read from PYAn:.  The devices do flow control between one another
and all buffering.  So, you can just read, for example, with a 100
char buffer from PY and the read will complete with whatever number of
characters the QIO to the PT terminal had, anywhere from 1 to MAXBUF.
If the QIO to the PT had more chars than your read buffer, it'll just
fill the read buffer and return, and you can get the rest on the next
read.  It is very simple to use.

Also, if you assign a mailbox with the PYAn: device (use LIB$ASN_WTH_MBX
when assigning channel to PYA0:) you will get a MBX$_TRMHANGUP (or
something like that, see the VMS terminal driver doc in I/O User's
Guide) message in the mailbox whenever the terminal is hung-up.  Like
when a process logouts out of it or deassigns the last channel to the
device.  It works just like the HANGUP on terminals with modem signals.
You can even ignore the hangup message if you want, it only generates
the message in the mailbox, you can continue to use the device if you
choose after getting the message.

Should you deassign the PYAn: device, a DISCONNECT will be forced on
any process using the PTAn: device.  Just like dropping carrier on
a modem line.  If you have the TT2$M_DISCONNECT bit set in the
default terminal characteristics (TTY_DEFCHAR2 in SYSGEN), then you will
get a virtual terminal upon logging into a PTAn: device.  Then you
get CONNECT/DISCONNECT to work.  Really nice on network connections.

Note that, just as with normal VMS terminals, you will only get a
VTAn: if the line has the DISCONNECT terminal characteristic before
you log into it, and only if you use LOGINOUT to start a process on
the terminal.  Just sending a <CR> into the device as the first thing
will start up LOGINOUT just like a normal terminal.

There are currently two bugs in the drivers.  The first is very minor and
is actually a side-effect of the driver being cautious in order to prevent
possible problems.  If you have a virtual terminal associated with the
pseudo-terminal, and you deassign the last channel to the control device
(the PY device) then a DISCONNECT is forced on any process on the PT and
the PY and PT are both deleted.  In this case, the PT will not be deleted,
although the PY will and the PT will be marked as OFFLINE.  This is because
I rely on VMS to do the actual delete of the device and because the VT's
screw up the way device reference counts work, VMS never gets around to
deleting the device.  It is marked for delete, so anything you do (I like
SHOW TERM) will cause it to be zapped.  I could fix this by zapping the
device explicitly after forcing the DISCONNECT, however I am not convinced
that someone, somewhere, won't try to use the UCB and thus cause bad
things to occur.  Like I said, it's a bug because I'm possibly being too
careful.  Note that it DOES get deleted correctly if you do not have
a virtual terminal associated with the PT or if you have no processes
active on the PT when the PY and PT are to be deleted.

The second bug is nastier, though much rarer.  Sometimes, and I don't
know exactly when, a character may get munged that is being output to
the pseudo-terminal.  It appears to happen to the last <LF> after the
first output line after a noecho read, if the output line is a certain
length.  It also has been seen in other places, but that's the only one
I can reproduce semi-reliably.  The character is always changed into
the hex byte xC, where x is any nybble.  Thus, you get things like:
"l", "L", <FF>, ",", "<", etc...   I am working on this one, but it's
a bitch.  It seems to be more likely to occur during a small window
where there is no outstanding read on the master device, the PY.
Programs which do a lot of work between reads on the master device
are more likely to see this happen.

There are no known system-crashers or process killers.

I am currently considering a few enhancements.  It should be possible
to set the PT terminal characteristics through the PY device, so the
controlling program can set them.  I will probably implement this by
letting you do an IO$_SETMODE to the PY device.  Also, I should make the
PT device driver notify the controlling program (via the associated
mailbox) whenever the PT terminal characteristics are changed (but not
when changed by the PY device driver!) in case you need to know such
things in your applications.  I need to think about the ramifications
of changing device characteristics on TTDRIVER unexpectedly, however,
before I make these changes.

If you need to set characteristics of the terminal device right now,
you must assign a channel to the PT device and use a SETMODE QIO
then deassign the channel before using the PT device for real.  You
will get a HANGUP message in the associated mailbox when you
deassign if the HANGUP attribute was set on the device.  You can just
ignore this message, however, and go ahead and use the device.  This
is true in all cases of a HANGUP.  You are free to ignore the hangup
and continue using the PT should you so desire.

You cannot set characteristics of the master device.  This used to be
allowed, though it had no purpose, and it crashes the system (at
least under V4).

	/Kevin Carosso               engvax!kvc @ CIT-VAX.ARPA
	 Hughes Aircraft Co.

	 September 16, 1985
*$*$*EOD*$*$*
$ write sys$output "Creating P.OPT"
$ create P.OPT
$ DECK/DOLLARS="*$*$*EOD*$*$*"
base=0
*$*$*EOD*$*$*
$ write sys$output "Creating PSEUDO.DOC"
$ create PSEUDO.DOC
$ DECK/DOLLARS="*$*$*EOD*$*$*"


1. Pty Driver
  This  chapter  describes  the  use  of  the VAX/VMS Pseudo Terminal Driver as
implemented Carnegie-Mellon University Compter Science Department.    Addtional
informatin  about VMS device drivers and the VMS operating system interface can
be found in VAX/VMS I/O User's Guide, and in VAX/VMS System  Service  Reference
Manual.

1.1 Pty Driver Features and Capabilities
  Pseudo  terminals  (or  Ptys)  are  virtual  terminals in the system.  Unlike
normal terminals where the I/O is actually done with a physical  device,  Pty's
I/O  has  no  interface to any physical device.  In this way they are much like
mailboxes.



1.1.1 Concept of Control and Terminal Device
  A single Pty consists of two devices, a control and a terminal device.    The
terminal device is the device that acts like a terminal.

  The  control  device  on  VMS is named ``PYAx:''.  For example, a pty control
device could be named ``PYA1:''.  The terminal device portion  of  the  pty  is
name  ``PTAx:''.    The  terminal  device  ``PTA1:'' is the mate to the control
device ``PYA1:''.  Similarly, the control device ``PYA5:'' is the mate  to  the
terminal device ``PTA5:''.


1.1.1.1 Similarities Between Ptys and Terminals
  The  terminal  portion  of  a  pty  behaves  very much like a regular VAX/VMS
terminal.  The terminal portion of a pty has

   - Type-ahead

   - Specifiable or default line terminators

   - Special operating modes, such as NOECHO and PASSALL

   - American National Standard escape sequence detection

   - Terminal/mailbox interaction

   - Terminal control characters  such  as  Sontrol-S  and  Control-Q  for
     starting  and  stopping  output, Control-O for discarding output, and
     all other special characters that are handled by the VAX/VMS terminal
     driver.

   - Limited  full-duplex  operation(simultaneously  active read and write
     requests)


1.1.1.2 Differences Between Ptys and Terminals
  The difference between a VAX/VMS terminal and the terminal portion of  a  pty
is  where  the  input  comes  from  and where the output goes to.  On a VAX/VMS
terminal, the input comes from an actual terminal and the  output  goes  to  an
actual  terminal.    On  a  pty the input comes from the control device and the
output goes to the control device.  In order to simulate someone typing at  the
terminal  device  ``PTA5:''  we must write to the control device ``PYA5:''.  In
order to read what has been typed out to the terminal device ``PTA5:''  we must
read  from  the  control  device  ``PYA5:''.  Ptys are like terminals that only
software can access.

  There is no buffering of the input on the control device.  It is possible  to
fill up the terminal device's typeahead buffer by writing large amounts of data
to the control device.

  Ptys are virtual devices.  When allocating  a  pty,  they  behave  much  like
mailboxes or network devices.  To allocate a pty, simply allocate the first one
('PYA0:').  The allocating routine will be create a new pty and  assign  it  to
you.  The pty will be deallocated when no process is referencing the device.


1.1.1.3 Uses of Ptys
  There  is  no  device  from  DEC  which suffices for remote logins when using
non-DECnet protocols.  The remote terminal driver expects the remote node to do
the local line editing.  This includes delete, control-o, control-s, control-q,
and much other stuff.  Ptys handle the local line editing locally.    When  the
line  editing  is  done locally, the remote machine has to know much less about
VMS and its terminal handling conventions.

1.2 Installing Ptys
  In VAX/VMS V3.0, several pieces of software support the  terminal  interface.
The  hardware  independent portion is SYS$SYSTEM:TTDRIVER.EXE.  This version of
ptys does not require any changes or patches to this code.    There  are  other
pieces   of   software  for  particular  pieces  of  hardware.    The  code  in
SYS$SYSTEM:DZDRIVER.EXE is the device driver required for  DZ11's  and  DZ32's.
The  code in SYS$SYSTEM:YCDRIVER.EXE is the device driver required for DMF32's.
Pty drivers consist of  two  device  drivers,  PTDRIVER.EXE  for  the  terminal
portion of the pty's, and PYDRIVER.EXE for the control portion.



1.2.1 Compiling Sources
  There   are  several  pieces  of  source  code  that  make  up  pty  drivers.
PYDRIVER.MAR is the source for the control portion.  PTDRIVER.MAR is the source
for the terminal portion.

  The commands for compiling and linking the devices are:
$ ! Compile the drivers
$ MACRO /LIST /OBJECT PTDRIVER.MAR+SYS$LIBRARY:LIB/LIBRARY
$ MACRO /LIST /OBJECT PYDRIVER.MAR+SYS$LIBRARY:LIB/LIBRARY
$ ! Link the drivers
$ LINK /SHARE /MAP /FULL /CROSS -
        PTDRIVER,SYS$SYSTEM:SYS.STB/SELECTIVE,SYS$INPUT:/OPTION
BASE=0
$ LINK /SHARE /MAP /FULL /CROSS -
        PYDRIVER,SYS$SYSTEM:SYS.STB/SELECTIVE,SYS$INPUT:/OPTION
BASE=0



1.2.2 Installing the Devices
  To  load  a  pty,  login  to  a  privileged  account  and issue the following
commands.
$ RUN SYS$SYSTEM:SYSGEN
CONNECT PTA0/NOADAPTER/DRIVER=device:[directory]PTDRIVER
CONNECT PYA0/NOADAPTER/DRIVER=device:[directory]PYDRIVER

  You may want to build a command file which installs the devices at boot  time
by modifying SYS$MANAGER:SYSTARTUP.COM.

  Don't try to use PTB0 or PYB0.  The code is not built to handle these.  It is
only built to handle the PYA and PTA control and terminal devices.

1.3 Device Information
  User processes can obtain terminal and control device  information  by  using
the  $GETDVI,  $GETCHN and $GETDEV system services (see VAX/VMS System Services
Reference Manual).

  It is recommended that new programs make use  of  the  $GETDVI  and  $GETDVIW
system services.



1.3.1 Pty Terminal Device Dependent Information
  The  information  returned  about  a terminal device is in the same format as
information returned about a regular VAX/VMS terminal.  By only looking at  the
information returned from $GETCHN and $GETDEV system services, it is impossible
to tell the difference between a pty terminal device  and  an  actual  terminal
device.



1.3.2 Pty Control Device Dependent Information
  When  applied  to  a  pty  control  device, $GETCHN return information in the
format as show in Figure 1-1.


              31        24 23        16 15         8 7          0
             -----------------------------------------------------
             |              Device Characteristics               |
             -----------------------------------------------------
             |       Buffer Size       |    Type    |    Class   |
             -----------------------------------------------------
             |           Unused        |     PT Unit Number      |
             -----------------------------------------------------

            Figure 1-1:   Pty Control Device Dependent Information

  The first longword contains device-independent data.  The  second  and  third
longwords contain device-dependent data.


1.3.2.1 Device Characteristics
  The  characteristics  of  the  the  pty  control device (PYA) can be found by
either using the first longword returned by  the  $GETDEV  and  $GETCHN  system
services, or by using the item code DVI$ DEVCHAR to the $GETDVI system service.

  A pty control device has the following characteristics.

   - DEV$M AVL - On line and available

   - DEV$M IDV - Capable of input

   - DEV$M ODV - Capable of output

   - DEV$M REC - Record oriented

  A pty control device does not have the following characteristics.

   - DEV$M CCL - Carriage Control

   - DEV$M TRM - Terminal Device


1.3.2.2 Buffer Size
  Also returned from $GETDVI by using item code DVI$ DEVBUFSIZ.


1.3.2.3 Device Type
  The  device  type  is  DT$ PY.  Since a pty is a nonstandard device, you will
probably not find the correct macros, literals or  constants  for  this  device
type.  This field should have a value of 0.

  Also returned from $GETDVI by using item code DVI$ DEVTYPE.


1.3.2.4 Device Class
  The  device  class  is DC$ PY.  Since a pty seems to be such an odd creature,
this field should be FF in hex, or 177 in octal.

  Also returned from $GETDVI by using item code DVI$ DEVCLASS.


1.3.2.5 PT Unit Number
  The unit number is unit number of the associated pty terminal device.

  The unit number is also returned as the low sixteen bits in DVI$ DEVDEPEND by
$GETDVI.

1.4 Pty Function Codes
  The  function  codes for the terminal device portion of a pty are exactly the
same as those for regular VAX/VMS terminals.  For more information  on  VAX/VMS
terminal I/O see VAX/VMS I/O User's Guide.

  The  basic  function  of the control portion of a pty are read, write and set
mode or characteristics.

  A user does not need to have assigned the pty terminal device in order to  do
I/O  operations  on  the  pty  control device.  If the terminal device has type
ahead enabled, sending the right characters at the control device will  send  a
message  to  OPCOM  to  start  running  SYS$SYSTEM:LOGINOUT.EXE on the terminal
device.



1.4.1 Read
  The basic purpose of a pty control device read is to transfer data  from  the
output buffer of the pty terminal device to a user specified buffer.  There are
three read functions which a user can apply to a pty control device.

   - IO$ READVBLK - Read virtual block

   - IO$ READLBLK - Read logical block

   - IO$ READPBLK - Read physical block

  A read is complete if either of the below conditions occur:

   - The user specified buffer is full

   - At least one character is available from the pty terminal device

  The read function codes can  take  the  following  device/function  dependent
arguments:

   - P1  =  The  starting virtual address of the buffer that is to receive
     the data read

   - P2 = The size of the buffer that is to receive the data read in bytes

   - P3, P4, P5, P6 = ignored



1.4.2 Write
  The basic purpose of a pty control device write is to transfer data from  the
user  specified  buffer  to  the  typeahead  buffer of the pty terminal device.
There are three write functions which a user can apply to a pty control device.

   - IO$ WRITEVBLK - write virtual block

   - IO$ WRITELBLK - write logical block

   - IO$ WRITEPBLK - write physical block

  The write function codes can take  the  following  device/function  dependent
arguments:

   - P1 = The starting virtual address of the buffer that is to be written
     to the pty terminal device

   - P2 = The number of bytes that are to be sent

   - P3, P4, P5, P6 = Ignored



1.4.3 Set Mode and Set Characteristics
  The Set Mode function affects the mode and temporary characteristics  of  the
associated pty control device.  Set Mode is a logical I/O function and requires
no privilege.  A single function code is provided:

   - IO$ SETMODE

  The Set Charateristics function affects the permanent characteristics of  the
associated  pty control device.  Set Characteristics is a physical I/O function
and requires the privilege  necessary  to  perform  physical  I/O.    A  single
function code is provided:

   - IO$ SETCHAR

  These  functions take the following device/function dependent arguments if no
function modifiers are specified:

   - P1 = address of characteristics buffer

   - P2, P3, P4, P5, P6 = ignored

  The P1 argument points to a quadword block, as shown in Figure 1-2.


              31        24 23        16 15         8 7          0
             -----------------------------------------------------
             |       Buffer Size       |    Type    |    Class   |
             -----------------------------------------------------
             |                      Unused                       |
             -----------------------------------------------------

                 Figure 1-2:   Set Mode Characteristics Buffer


1.4.3.1 Function Modifiers
  Function Modifiers to the control device currently do not affect the state or
accessibility of terminal device.

  You  cannot  change  the  mode  or  characteristics of the terminal device by
adding function modifiers to the I/O routines  for  the  control  device.    An
earlier version of ptydrivers supported this feature.  This feature has not yet
been added to this version.



1.4.4  Sense Mode and Sense Characterisitics
  The two function codes to sense the mode of the pty control device are:

   - IO$ SENSEMODE

   - IO$ SENSECHAR

  The IO$ SENSEMODE function returns the process-associated, that is temporary,
characteristics  of the pty control device.  The IO$ SENSECHAR function returns
the permanent characteristics of the pty control  device.    The  IO$ SENSEMODE
function  is  a  logical function and requires no privilege.  The IO$ SENSECHAR
function is a physical function and requires the privilege necessary to perform
physical I/O.

  These function codes take the following device/function dependent.

   - P1 = address of the quadword characteristics buffer

   - P2, P3, P4, P5, P6 = ignored

  The  P1  argument  points to a quadword block which is the same format as the
Set Mode Characteristics Buffer, shown in Figure 1-2



1.4.5 I/O Status Block
  The I/O status block formats for read, write, set mode  and  sense  mode  I/O
functions are shown in Figures 1-3 and 1-4.


              31        24 23        16 15         8 7          0
             -----------------------------------------------------
             |       Byte Count        |         Status          |
             -----------------------------------------------------
             |                      Unused                       |
             -----------------------------------------------------

             Figure 1-3:   IOSB Contents - Read and Write Function


              31        24 23        16 15         8 7          0
             -----------------------------------------------------
             |         Unused          |         Status          |
             -----------------------------------------------------
             |                      Unused                       |
             -----------------------------------------------------

Figure 1-4:   IOSB Contents - Set and Sense Mode and Characteristics Functions

  The status indicates the succes or failure of the specified operation.  Below
are possible values for the status field:

   - SS$ ABORT - The operation was canceled by the Cancel I/O  on  Channel
     ($CANCEL)  system service.  Applicable only if the drive was actively
     involved in an operation.

   - SS$ NORMAL - Successful Completion

   - SS$ ACCVIO - The specified buffer is not accessible to the  specified
     process

1.5 Possible Improvements and Bugs
  Watch  the  error counts on the devices.  Occasionally, a pty terminal device
might get a timeout.  Perhaps,  it  is  not  executing  at  a  sufficient  IPL.
Somehow, we aren't entering the startio routine soon after the UCB$V_TIM bit is
set in UCB$W_STS.

  It may be useful for the associated mailbox of the PY  device  to  receive  a
message  every  time  the  stop,  start, abort, resume, xoff, or xon routine is
called.  This would permit programs that control the  PY  device  to  determine
when  to slow down the data rate, or abort the output in the buffers which have
already been read.



                               Table of Contents

1. Pty Driver                                                                 2

   1.1 Pty Driver Features and Capabilities                                   2
       1.1.1 Concept of Control and Terminal Device                           2
           1.1.1.1 Similarities Between Ptys and Terminals                    2
           1.1.1.2 Differences Between Ptys and Terminals                     2
           1.1.1.3 Uses of Ptys                                               2
   1.2 Installing Ptys                                                        2
       1.2.1 Compiling Sources                                                2
       1.2.2 Installing the Devices                                           2
   1.3 Device Information                                                     2
       1.3.1 Pty Terminal Device Dependent Information                        2
       1.3.2 Pty Control Device Dependent Information                         2
           1.3.2.1 Device Characteristics                                     2
           1.3.2.2 Buffer Size                                                2
           1.3.2.3 Device Type                                                2
           1.3.2.4 Device Class                                               3
           1.3.2.5 PT Unit Number                                             3
   1.4 Pty Function Codes                                                     3
       1.4.1 Read                                                             3
       1.4.2 Write                                                            3
       1.4.3 Set Mode and Set Characteristics                                 3
           1.4.3.1 Function Modifiers                                         3
       1.4.4  Sense Mode and Sense Characterisitics                           3
       1.4.5 I/O Status Block                                                 3
   1.5 Possible Improvements and Bugs                                         3



                                List of Figures
   Figure 1-1:   Pty Control Device Dependent Information                     2
   Figure 1-2:   Set Mode Characteristics Buffer                              3
   Figure 1-3:   IOSB Contents - Read and Write Function                      3
   Figure 1-4:   IOSB Contents - Set and Sense  Mode  and  Characteristics    3
                 Functions
*$*$*EOD*$*$*
$ write sys$output "Creating PTDRIVER.MAR"
$ create PTDRIVER.MAR
$ DECK/DOLLARS="*$*$*EOD*$*$*"
	.TITLE	PTDRIVER - Pseudo terminal driver for Front End and ethernet
	.IDENT	'V03-007'

;
;++
; FACILITY:
;
;	VAX/VMS TERMINAL DRIVER
;
; ABSTRACT:
;
;	PSEUDO TERMINAL ROUTINES.
;
; AUTHOR:
;
;	19-NOV-1982	Dale Moore (dwm) at CMU
;		Redone for VMS V3.0
;
;	This program has been granted to the public domain by the author.
;
; MODIFICATIONS:
;	Version 'V03-001':
;		DWM	- Added .Page above each .sbttl
;			- added modem transition routines in disco and init
;			- removed $ACBDEF external def's
;			- restored timeout to resume
;			- added ioc$initiate call in xoff and xon routines.
;	Version V03-002 - Changed PT startio to clear TIM in UCB$W_STS
;	Version V03-003 - Changed PT$RESUME to not set timeout bit in sts
;
;	Version V03-004 (Thu Dec  9 12:43:17 1982) D. Kashtan
;			  Made into a TEMPLATE driver.
;			  (***WARNING*** -- LOOK AT COMMENTS FOR ROUTINE
;			   PT$SET_LINE.  THERE IS IMPORTANT INFORMATION
;			   ABOUT CHANGES TO VMS THAT WILL AFFECT THE PTDRIVER)
;	Version V03-005 - (14-Jun-1983 )Dale Moore
;			  Add R4 to masks on calls to ioc$initiate.
;			  TTY$STARTIO clobber R4.
;	Version V03-006	- Change PT$XON and PT$XOFF routines from
;			  unconditionally calling IOC$INITIATE.
;			  IOC$INITIATE will branch to PY$STARTIO,
;			  Which will call TTY$GETNEXTCHAR (UCB$L_TT_GETNEXT),
;			  Which will branch to EOLSEEN,
;			  which calls TTY$READONE,
;			  which calls the PORT_XOFF routine which is PT$XOFF.
;			  This cycle was eating up all of the kernel stack.
;	Version V03-007 - (12-Jul-1983) Mark London
;			  Set default of PT to TERM to allow REPLY/USERS.
;			  Make PT owned and not a TEMPLATE in order that
;			  SHO TERM PTA0 does not cause a crash (SHOW attempts
;			  an ASSIGN to the device.)
;	Verison V04-001 - ( 9-Nov-1984 ) L. Bellamy and D. Davis
;			  In order of appearance:
;
;			  Added Object Rights Block offset definitions.
;			  Add TEMPLATE bit to UCB$W_STS.
;			  Add ORB definitions in prologue.
;			  Modify to allow vector definitions using VEC macro.
;			  Use CLASS_CTRL_INIT and CLASS_UNIT_INIT to locate
;			   vector table.
;			  Update powerfail routines.
;			  Use new methodology for XON/XOFF flow control.
;			  Get rid of all the SET_LINE stack manipulation
;			  since the terminal driver does not do anything
;			  malicious as suggested.
;
;			  NOTE - Comments in subroutine preambles not altered
;			  to reflect changes in most places.
;
;	Version V04-003 (24-Jun-1985) Kevin Carosso, Hughes Aircraft Co., S&CG
;			Cleaned this thing up quite a bit.
;			- Got rid of MBX characteristic on the devices.  This
;			  was a holdover to before cloned devices really
;			  existed.
;			- Leave the PT template device OFFLINE.  This is what
;			  other TEMPLATE devices do, to indicate that you
;			  really cannot do I/O to the template.  Also left
;			  it UNAVAILABLE, since the only way it is supposed to
;			  get used is by cloning in the PY device.
;			- Got rid of all modem operations.  Improper use tended
;			  to crash the system and they are not necessary.  PT
;			  device is always NOMODEM.  HANGUP works as you want
;			  it to without the modem stuff.
;			- Setup forced characteristics and default permanent
;			  characteristics.  Forced are: NOAUTOBAUD, and NODMA.
;			  Default is HANGUP.
;			- Fixed up PT$DISCONNECT to properly send a message
;			  to PY device's associated mailbox only if we are
;			  actually doing a hangup.  It used to do it every
;			  time.  Changed the message to MSG$_TRMHANGUP.
;			- Got rid of the BRDCST on/off stuff.  It doesn't seem
;			  to be necessary any more.  It also had a bug in it
;			  somewhere that caused the terminal to start off
;			  NOBRDCST when it shouldn't.
;			- General house-cleaning.  Got rid of commented out
;			  lines from VMS V3 version.  Fixed up typos in 
;			  comments.
;--

	.PAGE
	.SBTTL	Declarations

	.LIBRARY	/SYS$LIBRARY:LIB.MLB/

;
; EXTERNAL DEFINITIONS:
;
.NOCROSS
	$CRBDEF				; DEFINE CRB
	$DCDEF				; DEVICE CLASSES AND TYPES
	$DDBDEF				; DEFINE DDB
	$DDTDEF				; DEFINE DDT
	$DEVDEF				; DEVICE CHARACTERISTICS
	$DYNDEF				; Dynamic structure definitions
	$IDBDEF				; DEFINE IDB OFFSETS
	$IODEF				; I/O Function Codes
	$IRPDEF				; IRP definitions
	$MSGDEF				; Message types
	$ORBDEF				; Define Object's Rights Block offsets
	$TTYDEF				; DEFINE TERMINAL DRIVER SYMBOLS
	$TTDEF				; DEFINE TERMINAL TYPES
	$TT2DEF				; Define Extended Characteristics
	$UCBDEF				; DEFINE UCB
	$VECDEF				; DEFINE VECTOR FOR CRB
	$TTYMACS			; DEFINE TERMINAL DRIVER MACROS
	$TTYDEFS			; DEFINE TERMINAL DRIVER SYMBOLS
;	$TTYMODEM			; DEFINE MODEM DEFINITIONS
.CROSS

;
; LOCAL DEFINITIONS
;
DT$_PT = ^XFF
;
; Definitions that follow the standard UCB fields for PT driver
;  This will all probably have to be the same as the standard term

	$DEFINI	UCB			; Start of UCB definitions

	.=UCB$K_TT_LENGTH		; Position at end of UCB

$DEF	UCB$L_PT_XUCB	.BLKL	1	; UCB of corresponding
					;  control/application unit
$DEF	UCB$K_PT_LEN			; Size of UCB

	$DEFEND	UCB			; End of UCB definitions
;
; Definitions that follow the standard UCB fields in PY devices
;

	$DEFINI UCB			; Start of UCB definitions

	.=UCB$K_LENGTH		; position at end of UCB

$DEF	UCB$L_PY_XUCB	.BLKL 1	; UCB of terminal part of pseudo terminal

$DEF	UCB$K_PY_LEN		; Size of UCB

	$DEFEND UCB		; end of UCB definitions

;
; LOCAL STORAGE
;
	.PSECT	$$$105_PROLOGUE

	.PAGE
	.SBTTL	Standard Tables

;
; Driver prologue table:
;
PT$DPT::
	DPTAB	-			; DRIVER PROLOGUE TABLE
		END=PT_END,-		; End and offset to INIT's vectors
		UCBSIZE=UCB$K_PT_LEN,- 	; SIZE OF UCB
		FLAGS=DPT$M_NOUNLOAD,-	; Do not allow unload
		ADAPTER=NULL,-		; ADAPTER TYPE
		NAME=PTDRIVER,-		; NAME OF DRIVER
		VECTOR=PORT_VECTOR
	DPT_STORE INIT
	DPT_STORE UCB,UCB$W_UNIT_SEED,W,0	; SET UNIT # SEED TO ZERO
	DPT_STORE UCB,UCB$B_FIPL,B,8	; FORK IPL
	DPT_STORE UCB,UCB$L_DEVCHAR,L,<-; CHARACTERISTICS
			DEV$M_REC!-	;
			DEV$M_IDV!-	;
			DEV$M_ODV!-	;
			DEV$M_TRM!-	;
			DEV$M_CCL>
	DPT_STORE UCB,UCB$W_STS,W,-
			<UCB$M_TEMPLATE>		; Template device
	DPT_STORE UCB,UCB$B_DEVCLASS,B,DC$_TERM		;
	DPT_STORE UCB,UCB$B_TT_DETYPE,B,TT$_UNKNOWN	; TYPE
	DPT_STORE UCB,UCB$W_TT_DESIZE,@W,TTY$GW_DEFBUF	; BUFFER SIZE
	DPT_STORE UCB,UCB$L_TT_DECHAR,@L,TTY$GL_DEFCHAR	; DEFAULT CHARACTERS
	DPT_STORE UCB,UCB$L_TT_DECHA1,@L,TTY$GL_DEFCHAR2; DEFAULT CHARACTERS
	DPT_STORE UCB,UCB$W_TT_DESPEE,@B,TTY$GB_DEFSPEED; DEFAULT SPEED
	DPT_STORE UCB,UCB$W_TT_DESPEE+1,@B,TTY$GB_RSPEED; DEFAULT SPEED
	DPT_STORE UCB,UCB$B_TT_DEPARI,@B,TTY$GB_PARITY	; DEFAULT PARITY
	DPT_STORE UCB,UCB$B_TT_PARITY,@B,TTY$GB_PARITY	; DEFAULT PARITY
	DPT_STORE UCB,UCB$B_DEVTYPE,B,TT$_UNKNOWN	; TYPE
	DPT_STORE UCB,UCB$W_DEVBUFSIZ,@W,TTY$GW_DEFBUF	; BUFFER SIZE
	DPT_STORE UCB,UCB$L_DEVDEPEND,@L,TTY$GL_DEFCHAR	; DEFAULT CHARACTERS
	DPT_STORE UCB,UCB$L_TT_DEVDP1,@L,TTY$GL_DEFCHAR2; Default Characters
	DPT_STORE UCB,UCB$W_TT_SPEED,@B,TTY$GB_DEFSPEED	; DEFAULT SPEED
	DPT_STORE UCB,UCB$W_TT_SPEED+1,@B,TTY$GB_RSPEED	; DEFAULT SPEED
	DPT_STORE UCB,UCB$B_DIPL,B,8			; DEV IPL (no device)
	DPT_STORE UCB,UCB$L_TT_WFLINK,L,0	; Zero write queue.
	DPT_STORE UCB,UCB$L_TT_WBLINK,L,0	; Zero write queue.
	DPT_STORE UCB,UCB$L_TT_RTIMOU,L,0	; Zero read timed out disp.
;
; Added ORB definitions 
;
	DPT_STORE ORB,ORB$B_FLAGS,B,-
			   <ORB$M_PROT_16!-
			    ORB$M_ACL_QUEUE>
	DPT_STORE ORB,ORB$W_PROT,@W,TTY$GW_PROT
	DPT_STORE ORB,ORB$L_OWNER,@L,TTY$GL_OWNUIC

	DPT_STORE DDB,DDB$L_DDT,D,PT$DDT

	DPT_STORE REINIT
	DPT_STORE CRB,CRB$L_INTD+VEC$L_INITIAL,D,PT$INITIAL; CONTROLLER INIT
	DPT_STORE CRB,CRB$L_INTD+VEC$L_UNITINIT,D,PT$INITLINE; UNIT INIT
	DPT_STORE END

	DDTAB	DEVNAM	= PT,-		; Dummy PT port Driver Dispatch table
		START	= 0,-
		FUNCTB	= 0

	.PSECT $$$115_DRIVER,LONG

; The associated class driver uses this table to command the port driver.
; The address of the table is contained in the terminal UCB extension area.
; The offset definitions are defined by the ttydefs.

;
; PT specific dispatch table
;
PORT_VECTOR:
;
; Added port vector table using VEC macros 
;
	$VECINI	PT,PT$NULL
	$VEC	STARTIO,PT$STARTIO
	$VEC	DISCONNECT,PT$DISCONNECT
	$VEC	SET_LINE,PT$SET_LINE
	$VEC	XON,PT$XON
	$VEC	XOFF,PT$XOFF
	$VEC	STOP,PT$STOP
	$VEC	ABORT,PT$ABORT
	$VEC	RESUME,PT$RESUME
	$VECEND

PT$NULL:				; Null port routine
	RSB


	.PAGE
	.SBTTL	PT$INITIAL - Initialize pseudo terminal interface
;++
; PT$INITIAL - INITIALIZE INTERFACE
;
; FUNCTIONAL DESCRIPTION:
;
; This routine is entered at device CONNECT time and power recovery.
; All we do is connect ourselves up to the class driver.
;
; INPUTS:
;
;	R4 = ADDRESS OF THE UNIT CSR
;	R5 = IDB OF UNIT
;	R8 = ADDRESS OF THE UNIT CRB
;
; OUTPUTS:
;
;	R0, R1, R2, R3 are destroyed.
;
; IMPLICIT INPUTS:
;
;	IPL = IPL$_POWER
;
;--
PT$INITIAL::

	CLASS_CTRL_INIT PT$DPT,PORT_VECTOR
	MOVB	#DT$_PT,CRB$B_TT_TYPE(R8)
	RSB

	.PAGE
	.SBTTL	PT$INITLINE - RESET INDIVIDUAL LINE
;++
; PT$INITLINE - RESET pseudo terminal control state
;
; FUNCTIONAL DESCRIPTION:
;
; This routine performs a simple unit initialization.
;
;
; INPUTS:
;
;	R5 = UCB ADDRESS
;
; OUTPUTS:
;
;	R2,R5 ARE PRESERVED.
;--
PT$INITLINE::				; RESET SINGLE LINE
	MOVAL	PT$VEC,R0		; Set PT port vector table 
	CLASS_UNIT_INIT			
	TSTL	UCB$W_UNIT(R5)		; Skip initialization of TEMPLATE
	BEQL	40$			; Unit #0 = Template: Skip everything!

	BBS	#UCB$V_POWER,UCB$W_STS(R5),-	; Skip if powerfail recovery
		20$
	movl	UCB$L_TT_LOGUCB(r5), r1		; Look at logical term UCB
	beql	10$				; If none, then has no refs
	tstw	UCB$W_REFC(r1)			; See if PT has any references
	BNEQ	20$				; If so don't reinit ucb
10$:	bsb	set_forced_chars		; Set required characteristics
	BISL	#TT2$M_HANGUP,-			; Set default characteristics
		UCB$L_TT_DECHA1(R5)
	MOVL	UCB$L_TT_CLASS(R5),R1		; Address class vector table
	JSB	@CLASS_SETUP_UCB(R1)		; Init ucb fields

20$:	BBC	#UCB$V_POWER,UCB$W_STS(R5),40$	; Powerfail handler
	MOVL	UCB$L_TT_CLASS(R5),R0		
	JMP	@CLASS_POWERFAIL(R0)		

40$:	RSB

;
; This little routine sets certain required characteristics.  It is called by
; the INITLINE code to set them at the outset and by the SETLINE code to reset
; them unconditionally if someone tries to set them.
;
set_forced_chars:
	bicl2	#<TT2$M_DMA ! TT2$M_AUTOBAUD>, -
		UCB$L_TT_DEVDP1(R5)
	bicl2	#<TT2$M_DMA ! TT2$M_AUTOBAUD>, -
		UCB$L_TT_DECHA1(R5)
	rsb


;++
; PT$SET_LINE - Used to Reset SPEED and UCB
;
; FUNCTIONAL DESCRIPTION:
;
;	Called whenever someone tries to set terminal modes/characteristics.
;	All we do is reset anything that we think should never be changed.
;
; INPUTS:
;
;	R5 = UCB ADDRESS of PT
;
; OUTPUTS:
;
;	none
;--
PT$SET_LINE::
	brb	set_forced_chars



	.Page
;++
; PT$DISCONNECT - SHUT OFF UNIT
;
; FUNCTIONAL DESCRIPTION:
;
; This routine is used when for some reason the unit must be disconnected.
; This can be at hangup or last deassign.  If the PY device has an associated
; mailbox, signal an MSG$_TRMHANGUP in it.
;
; Although we are disconnecting a virtual device, we don't do anything
; more than send a hangup message because we want to allow the device to
; be reusable.  It's really only if the control device (PY) goes away
; that we mark the PT offline and delete it's UCB.  That code's all in
; PYDRIVER.
;
; INPUTS:
;
;	R0 = (0 for hangup, 1 for nohangup)
;	R5 = UCB ADDRESS of PT
;
; OUTPUTS:
;
;	R3,R4 ARE USED.
;--
PT$DISCONNECT::
	blbs	r0, 99$			; If no hangup, skip all this.

	PUSHR	#^M<R0,R1,R2,R3,R4,R5>	; Save the registers

	MOVL	UCB$L_PT_XUCB(R5),R5	; Get PY UCB
	BEQL	10$			; If disconnected, ignore
	MOVL	UCB$L_AMB(R5),R3	; Load Associated Mailbox of PY UCB
	BEQL	10$			; If EQL then no mailbox
	MOVZWL	#MSG$_TRMHANGUP,R4	; Load Message Type
	JSB	G^EXE$SNDEVMSG		; Send the message
10$:	POPR	#^M<R0,R1,R2,R3,R4,R5>	; Restore everything
99$:	RSB



	.PAGE
	.SBTTL	PT START I/O ROUTINE
;++
; PT$STARTIO - START I/O OPERATION ON PT
;
; FUNCTIONAL DESCRIPTION:
;
;	This routine is entered from the device independent terminal startio
;	routine to enable output interrupts on an idle PT unit
;
; INPUTS:
;
;	R3 =	Character	AND	CC = Plus (N EQL 0)
;	R3 =	Address		AND	CC = Negative (N EQL 1)
;
;	R5 = UCB ADDRESS
;
; OUTPUTS:
;
;	R5 = UCB ADDRESS
;--
PT$STARTIO::				; START I/O ON UNIT
	BGEQ	20$			; Single character
	BISW	#TTY$M_TANK_BURST,-	; Signal burst active
		UCB$W_TT_HOLD(R5)
10$:
;
; Here we must do something to notify our mate device that
; there is data to pick up
;
	PUSHR	#^M<R0,R2,R3,R4,R5>	; Save PT UCB
	BICW	#UCB$M_TIM,UCB$W_STS(R5); Clear timeout on PT
	MOVL	UCB$L_PT_XUCB(R5),R5	; Switch to PY UCB
	BEQL	17$			; PY is disconnected: skip
	DSBINT	UCB$B_FIPL(R5)
	BBC	#UCB$V_BSY,-		; If the device isn't busy,
		UCB$W_STS(R5),15$	; then dont do i/o
	MOVL	UCB$L_IRP(R5),R3	; Get IRP address
	JSB	G^IOC$INITIATE		; IOC$INITIATE needs IRP addr
15$:	ENBINT	
16$:	POPR	#^M<R0,R2,R3,R4,R5>	; Switch back to PT UCB
	RSB
;
; Come here if we have no PY control device to send stuff to.  Just
; suck all the data we can out of the class driver and throw it away.
;
17$:	POPR	#^M<R0,R2,R3,R4,R5>	; Switch back to PT UCB
18$:	bicb	#<UCB$M_TIM!UCB$M_INT>, -
		UCB$W_STS(r5)
	jsb	@UCB$L_TT_GETNXT(r5)
	tstb	UCB$B_TT_OUTYPE(r5)
	bneq	18$
	rsb

20$:
	MOVB	R3,UCB$W_TT_HOLD(R5)	; Save output character
	BISW	#TTY$M_TANK_HOLD,-	; Signal charater in tank
		UCB$W_TT_HOLD(R5)	
	BRB	10$

	.PAGE
	.SBTTL	Port Routines Stop,Resume,XON,XOFF
;++
; PT$XOFF -	Send Xoff
; PT$XON -	Send Xon
; PT$STOP -	Stop output
; PT$STOP2 - 	Alternate stop
; PT$ABORT -	Abort current output
; PT$RESUME -	Resume stopped output
;
; Functional Description:
;
;	These routines are used by the terminal class driver to
;	control output on the port
;
; Inputs:
;
;	R5 = UCB Address
;
; Outputs:
;
;	R5 = UCB Address
;--
	.ENABLE LSB
;
; Schedule xon/xoff to be sent
;
PT$XOFF:
PT$XON:
;
; Changed schedule bit mask 
;
	BISW	#TTY$M_TANK_PREMPT,UCB$W_TT_HOLD(R5)	; Schedule xon
	MOVB	R3,UCB$B_TT_PREMPT(R5)			; Save character
20$:
	RSB
	.DISABLE LSB
;
; Stop port output
;
PT$STOP:
	BISW	#TTY$M_TANK_STOP,-		; Schedule stop.
		UCB$W_TT_HOLD(R5)
	RSB
;
; Abort any port currently active
;
PT$ABORT:
	BBCC	#TTY$V_TANK_BURST,UCB$W_TT_HOLD(R5),-	; reset burst active
		10$
10$:
	TIMSET	1					; Set Timeout 
							; in case output active
	RSB
;
; Resume previously stopped output
;
PT$RESUME:
5$:	BICW	#TTY$M_TANK_STOP-
		,UCB$W_TT_HOLD(R5)			; reset stop conditions
	BBS	#TTY$V_TANK_BURST,UCB$W_TT_HOLD(R5),20$	; burst in progress
10$:							; char in tank or other
	TIMSET	1					; set timeout 
	BRB	30$
20$:
	PUSHL	R1					; Save a register
	MOVZWL	UCB$W_TT_OUTLEN(R5),R1			;Get number characters
	.LIST	ME
	TIMSET	R1,R1					
	.NLIST	ME
	POPL	R1
30$:
	PUSHR	#^M<R0,R1,R2,R3,R4,R5>
	BICW	#UCB$M_TIM,UCB$W_STS(R5)	; Clear timeout
	MOVL	UCB$L_PT_XUCB(R5),R5		; Switch to PY UCB
	BEQL	17$				; PY is disconnected
	DSBINT	UCB$B_FIPL(R5)
	BBC	#UCB$V_BSY,-			; if device isn't busy
		UCB$W_STS(R5), 15$		; then don't do I/O
	MOVL	UCB$L_IRP(R5),R3		; Get IRP address
	JSB	G^IOC$INITIATE
15$:	ENBINT
17$:	POPR	#^M<R0,R1,R2,R3,R4,R5>		; Switch back to PT UCB
	RSB

PT_END:				; End of driver

	.END
*$*$*EOD*$*$*
$ write sys$output "Creating PTY.PAS"
$ create PTY.PAS
$ DECK/DOLLARS="*$*$*EOD*$*$*"
(* Simple program to converse with the pseudo-terminal control device. *)

[inherit ('SYS$LIBRARY:STARLET')]
program PTY;

const
  buffer_size = 256;
  CTRL_A = chr (1);

type
  string = varying [256] of char;
  unsigned_byte = [byte] 0..255;
  unsigned_word = [word] 0..65535;
  characteristic_buffer = packed record
			    dev_class, dev_type : unsigned_byte;
			    width : unsigned_word;
			    charbits, extended_bits : unsigned;
			  end;
  status_block = packed record
		   status, count, terminator, terminator_size : unsigned_word;
		 end;

var
  stat : integer;
  mbx_chan, tt_chan, pty_chan : [static, volatile] unsigned_word;
  input_char : [static, volatile] char;
  buffer : packed array [1..buffer_size] of char;
  mbx_buffer : [static, volatile] packed array [1..40] of char;
  term_chars, old_term_chars : [static, volatile] characteristic_buffer;
  in_iosb, out_iosb, mbx_iosb : [static, volatile] status_block;
  exit_descriptor : [static] packed record
		      flink : unsigned;
		      handler : unsigned;
		      argnum : integer;
		      reason : ^integer;
		    end := (0, 0, 1, nil);
  message : [static, volatile] string :=
				''(13, 10, 7)'Got a mailbox message'(13, 10);

{-----------------------------------------------------------------------------}

  [external]
  function LIB$ASN_WTH_MBX
		(DEVNAM : [class_s] packed array [l1..u1:integer] of char;
		 MAXMSG, BUFQUO : integer;
		 var DEVCHAN, MBXCHAN : [volatile] unsigned_word
		) : integer; extern;

(*
 * CLEANUP is our exit handler.  It resets the terminal characteristics.
 *)

  [unbound]
  function Cleanup (reason : integer) : integer;

  var
    stat : integer;
    iosb : status_block;

  begin (* Cleanup *)
    Cleanup := reason;
    stat := $QIOW (CHAN := tt_chan,
		     FUNC := IO$_SETMODE,
		     P1 := old_term_chars,
		     P2 := size (old_term_chars));
    if not odd (stat) then Cleanup := stat;
  end; (* Cleanup *)

  [asynchronous, unbound]
  procedure Set_asynch_mbx_input; forward;

(*
 * MBX_INPUT_AST is the AST handler invoked whenever we get something in
 * the associated mailbox.
 *)
  [asynchronous, unbound]
  procedure Mbx_input_AST;

  var
    stat : integer;
    iosb : status_block;

  begin (* Mbx_input_AST *)
    if not odd (mbx_iosb.status) then $EXIT (mbx_iosb.status);

    stat := $QIOW (CHAN := tt_chan,
		   FUNC := IO$_WRITEVBLK,
		   IOSB := iosb,
		   P1 := message.body,
		   P2 := message.length);
    if not odd (stat) then $EXIT (stat);
    if not odd (iosb.status) then $EXIT (iosb.status);

    Set_asynch_mbx_input;
  end; (* mbx_input_AST *)

(*
 * SET_ASYNCH_MBX_INPUT issues an asynchronous read on the terminal.
 *)
  procedure Set_asynch_mbx_input;

  var
    stat : integer;

  begin (* Set_asynch_mbx_input *)
    stat := $QIO (CHAN := mbx_chan,
		  FUNC := IO$_READVBLK,
		  IOSB := mbx_iosb,
		  ASTADR := mbx_input_AST,
		  P1 := mbx_buffer,
		  P2 := size (mbx_buffer));
    if not odd (stat) then $EXIT (stat);
  end; (* Set_asynch_mbx_input *)

  [asynchronous, unbound]
  procedure Set_asynch_input; forward;

(*
 * INPUT_AST is the AST handler invoked whenever we get something in
 * from the terminal.  Just ship it to the PTY.
 *)
  [asynchronous, unbound]
  procedure Input_AST;

  var
    stat : integer;

  begin (* Input_AST *)
    if not odd (in_iosb.status) then $EXIT (in_iosb.status);
    if input_char = CTRL_A then $EXIT (SS$_NORMAL);

    stat := $QIOW (CHAN := pty_chan,
		   FUNC := IO$_WRITEVBLK,
		   IOSB := in_iosb,
		   P1 := input_char,
		   P2 := 1);
    if not odd (stat) then $EXIT (stat);
    if not odd (in_iosb.status) then $EXIT (in_iosb.status);

    Set_asynch_input;
  end; (* Input_AST *)

(*
 * SET_ASYNCH_INPUT issues an asynchronous read on the terminal.
 *)
  procedure Set_asynch_input;

  var
    stat : integer;

  begin (* Set_asynch_input *)
    stat := $QIO (CHAN := tt_chan,
		  FUNC := IO$_READVBLK,
		  IOSB := in_iosb,
		  ASTADR := Input_AST,
		  P1 := input_char,
		  P2 := 1);
    if not odd (stat) then $EXIT (stat);
  end; (* Set_asynch_input *)

begin (* PTY *)
  stat := LIB$ASN_WTH_MBX (DEVNAM := 'PYA0:',
			    MAXMSG := size (mbx_buffer),
			    BUFQUO := 2 * size (mbx_buffer),
			    DEVCHAN := pty_chan,
			    MBXCHAN := mbx_chan);
  if not odd (stat) then $EXIT (stat);

  Set_asynch_mbx_input;

  stat := $ASSIGN (CHAN := tt_chan, DEVNAM := 'TT');
  if not odd (stat) then $EXIT (stat);

(* Get terminal characteristics. *)

  stat := $QIOW (CHAN := tt_chan,
		 FUNC := IO$_SENSEMODE,
		 P1 := term_chars,
		 P2 := size (term_chars));
  if not odd (stat) then $EXIT (stat);

  if term_chars.dev_class <> DC$_TERM then
    $EXIT (SS$_IVDEVNAM);

  old_term_chars := term_chars;

(* declare exit handler so that terminal chars are restored *)

  exit_descriptor.handler := iaddress (Cleanup);
  new (exit_descriptor.reason);

  stat := $DCLEXH (DESBLK := exit_descriptor);
  if not odd (stat) then $EXIT (stat);

(*
 * Set terminal characteristics we need:
 *    PASSTHRU, NOECHO, NOTTSYNC, NOHOSTSYNC
 *)

  with term_chars do
  begin
    extended_bits := UOR (extended_bits, TT2$M_PASTHRU);
    charbits := UOR (charbits, TT$M_NOECHO);
    charbits := UAND (charbits, UNOT (TT$M_TTSYNC));
    charbits := UAND (charbits, UNOT (TT$M_HOSTSYNC));
  end;

  stat := $QIOW (CHAN := tt_chan,
		 FUNC := IO$_SETMODE,
		 P1 := term_chars,
		 P2 := size (term_chars));
  if not odd (stat) then $EXIT (stat);

  Set_asynch_input;

  repeat
    stat := $QIOW (CHAN := pty_chan,
		   FUNC := IO$_READVBLK,
		   IOSB := out_iosb,
		   P1 := buffer,
		   P2 := size (buffer));
    if not odd (stat) then $EXIT (stat);
    if not odd (out_iosb.status) then $EXIT (out_iosb.status);

    stat := $QIOW (CHAN := tt_chan,
		   FUNC := IO$_WRITEVBLK,
		   IOSB := out_iosb,
		   P1 := buffer,
		   P2 := out_iosb.count);
    if not odd (stat) then $EXIT (stat);
    if not odd (out_iosb.status) then $EXIT (out_iosb.status);
  until false;
end. (* PTY *)
*$*$*EOD*$*$*
$ write sys$output "Creating PYDRIVER.MAR"
$ create PYDRIVER.MAR
$ DECK/DOLLARS="*$*$*EOD*$*$*"
	.TITLE	PYDRIVER - Pseudo terminal driver interface
	.IDENT 'V03-005'

;
;++
; FACILITY:
;
;	VAX/VMS Pseudo Terminal Driver interface
;
; ABSTRACT:
;
;	The pseudo terminal consists of two devices.
;	This is the non terminal part of the two devices.
;
; AUTHOR:
;
;	19-Nov-1982	Dale Moore	Redid the PT driver for VMS 3.0
;
;	This program has been granted to the public domain by the author.
;
; Revision History:
;
;	Version 'V03-001'
;		DWM	- Added Page seperators
;			- On Last cancel, invoke hangup on PT device
;			- changed PY_STOP and PY_STOP2 to return instead
;			  of looping for more.
;			- Changed last cancel to call ioc$reqcom instead of
;			  using macro REQCOM which is a branch ioc$reqcom.
;	Version V03-002	- Changed to Clear word rather than clear byte
;			  in startio routine on word field.
;
;	Version V03-003 (Thu Dec  9 12:42:38 1982) D. Kashtan
;			  Made into a TEMPLATE driver.
;	Version V03-004 (Fri Dec 10 11:40:35 1982) D. Kashtan
;			  Made EXE$... into +EXE$... in FDT dispatch table,
;			  fixing bug that crashed system in SET/SENSE MODE/CHAR
;	Version V03-005	(14-Jun-1983) Dale Moore
;			  Add R4 to calls to IOC$INITIATE.
;			  TTY$STARTIO mucks R4
;	Version V03-006	(12-Jul-1983) Mark London, MIT Plasma Fusion Center
;			- Set terminal to NOBROADCAST when no READ QIO avail-
;			  able so as to allow Broadcasts without hanging up.
;			  (When no QIO available, UCB$M_INT is enabled, and
;			  the Broadcast don't get handled.  The sender of a
;			  Broadcast goes into a wait state until the broadcast
;			  is completed or timed-out, neither or which can
;			  happen.  Setting NOBROADCASTs at least allow the
;			  Broadcast to finish. What is needed is a CTRLS state
;			  that doesn't allow Broadcasts to break through.)
;			- Added MOVC3 instruction for burst data in PY$STARTIO,
;			  which "should" speed up the transfers.
;			- Fixed data transfer problem by raising to fork IPL
;			  while calling PUTNXT in PY$FDTWRITE. NOTE: PTA0 must
;			  be a mailbox to avoid TT reads from timing out.
;
;	Version V04-001 - Doug Davis, Digital Equipment
;			- Most of the changes required for migration to
;			  Version 4.0 relate to the new handling of UCB
;			  creation and deletion. This includes adding 
;			  a CLONEDUCB entry point to the dispatch table,
;			  and "cloning" the UNITINIT routine to handle the
;			  required entry. Also changed the call from 
;			  IOC$CREATE_UCB to IOC$CLONE_UCB, with associated
;			  maintainence of the UCB$V_DELETEUCB bit in the
;			  UCB$L_STS field.
;			- Changes were also incorporated reflecting new
;			  methods of  XON/XOFF flow control.
;			- Although pieces of the original code have been
;			  superceded by these changes ( example - functions
;			  that were performed by Unit_Init for new units
;			  are are now performed by Clone_Init ), most of
;			  the original code was left in place and/or commented
;			  out.
;			
;			NOTE - No subroutines preambles were modified to
;			       reflect these changes.
;
;	Version V04-002	(20-Jan-1985) Mark London, MIT Plasma Fusion Center
;			- Changed test for output characters after call to
;			  UCB$L_TT_PUTNXT and UCB$L_TT_GETNXT.  Output is
;			  indicated in UCB$B_TT_OUTYPE.
;
;	Version V04-003 (24-Jun-1985) Kevin Carosso, Hughes Aircraft Co., S&CG
;			Cleaned this thing up quite a bit.
;			- Got rid of MBX characteristic on the devices.  This
;			  was a holdover to before cloned devices really
;			  existed.
;			- Got rid of the UNIT_INIT routine completely.  This
;			  was replaced by a CLONE_UCB routine.
;			- Leave the PY template device OFFLINE.  This is what
;			  other TEMPLATE devices do, to indicate that you
;			  really cannot do I/O to the template.
;			- Rewrote the CANCEL_IO routine to issue a DISCONNECT
;			  on the PT device at last deassign of the PY device.
;			  This causes the PT device to hangup on it's process.
;			  Works quite nicely with VMS V4 connect/disconnect
;			  mechanism.  Also, the devices should never stay
;			  around after last deassign on the PY, if you want to
;			  reconnect, count on VMS connect/disconnect instead,
;			  it's much less of a security hole.
;			- Got rid of all modem operations.  Improper use tended
;			  to crash the system and they are not necessary.  PT
;			  device is always NOMODEM.  HANGUP works as you want
;			  it to without the modem stuff.
;			- Got rid of the BRDCST on/off stuff.  It doesn't seem
;			  to be necessary any more.  It also had a bug in it
;			  somewhere that caused the terminal to start off
;			  NOBRDCST when it shouldn't.
;			- General house-cleaning.  Got rid of commented out
;			  lines from VMS V3 version.  Fixed up typos in 
;			  comments.
;--

	.PAGE
	.SBTTL	Declarations

	.LIBRARY	/SYS$LIBRARY:LIB.MLB/

;
; External Definitions:
;

.NOCROSS
;	$ACBDEF				; Define ACB
	$CRBDEF				; Define CRB
	$CANDEF				; Define cancel codes
	$DDBDEF				; DEFINE DDB
	$DDTDEF				; DEFINE DDT
	$DEVDEF				; DEVICE CHARACTERISTICS
	$DYNDEF				; Dynamic structure definitions
	$IODEF				; I/O Function Codes
	$IRPDEF				; IRP definitions
	$JIBDEF				; Define JIB offsets
	$SSDEF				; DEFINE System Status
	$PCBDEF				; Define PCB
	$PRDEF				; Define PR
	$TTYDEF				; DEFINE TERMINAL DRIVER SYMBOLS
	$TTDEF				; DEFINE TERMINAL TYPES
	$TT2DEF				; Define Extended Characteristics
	$UCBDEF				; DEFINE UCB
	$VECDEF				; DEFINE VECTOR FOR CRB
	$TTYMACS			; DEFINE TERMINAL DRIVER MACROS
	$TTYDEFS			; DEFINE TERMINAL DRIVER SYMBOLS
.CROSS

;
; Local definitions
;
; QIO Argument list offsets
;
P1 = 0
P2 = 4
P3 = 8
P4 = 12
P5 = 16
P6 = 20
;
; New device class for control end
;
DC$_PY = ^XFF
DT$_PY = 0

;
; Definitions that follow the standard UCB fields for PT driver
;  This will all probably have to be the same as the standard term

	$DEFINI	UCB			; Start of UCB definitions

	.=UCB$K_TT_LENGTH		; Position at end of UCB

$DEF	UCB$L_PT_XUCB	.BLKL	1	; UCB of corresponding
					;  control/application unit
$DEF	UCB$K_PT_LEN			; Size of UCB

	$DEFEND	UCB			; End of UCB definitions

;
; Definitions that follow the standard UCB fields in PY devices
;

	$DEFINI UCB			; Start of UCB definitions

	.=UCB$K_LENGTH		; position at end of UCB

$DEF	UCB$L_PY_XUCB	.BLKL 1	; UCB of terminal part of pseudo terminal

$DEF	UCB$K_PY_LEN		; Size of UCB

	$DEFEND UCB		; end of UCB definitions

	.PAGE
;
; LOCAL Storage
;
	.PSECT $$$105_PROLOGUE

	.SBTTL	Standard Tables

;
; Driver prologue table:
;
PY$DPT::
	DPTAB	-			; Driver Prologue table
		END = PY$END,-		; End and offset to INIT's vectors
		UCBSIZE = UCB$K_PY_LEN,-; Size of UCB
		FLAGS=DPT$M_NOUNLOAD,-		; Don't allow unload
		ADAPTER=NULL,-			; ADAPTER TYPE
		NAME	= PYDRIVER		; Name of driver
	DPT_STORE INIT
	DPT_STORE UCB,UCB$W_UNIT_SEED,W,0	; SET UNIT # SEED TO ZERO
	DPT_STORE UCB,UCB$B_FIPL,B,8		; Fork IPL
	DPT_STORE UCB,UCB$W_STS,W,-		; TEMPLATE device
			<UCB$M_TEMPLATE>
	DPT_STORE UCB,UCB$L_DEVCHAR,L,<-	; Charactersitics
			DEV$M_REC!-		;   record oriented
			DEV$M_AVL!-		;   available
			DEV$M_IDV!-		;   input device
			DEV$M_ODV>		;   output device
	DPT_STORE UCB,UCB$B_DEVCLASS,B,DC$_PY
	DPT_STORE UCB,UCB$B_DIPL,B,8		; Device IPL = FIPL (no device)
	DPT_STORE DDB,DDB$L_DDT,D,PY$DDT

	DPT_STORE REINIT
	DPT_STORE CRB,CRB$L_INTD+VEC$L_INITIAL,D,PY$INITIAL	; Controller
	DPT_STORE END

	.PAGE
	.SBTTL Driver Dispatch table and function decistion table
;
; Driver Dispatch table
;
	DDTAB	DEVNAM	= PY,-			; Device name
		START	= PY$STARTIO,-		; Start I/O routine
		FUNCTB	= PY$FUNCTAB,-		; The function table
		CANCEL	= PY$CANCEL,-		; the cancel i/o routine
		CLONEDUCB = PY$CLONE_INIT	; Entry when template cloned.
;
; Function Decision table for PY devices
;
PY$FUNCTAB:
	FUNCTAB	,-			; Legal Functions
		<READLBLK,-
		WRITELBLK,-
		READVBLK,-
		WRITEVBLK,-
		READPBLK,-
		WRITEPBLK,-
;		SETMODE,-		; Disallow, can crash and not needed
;		SETCHAR,-		; /kvc
		SENSEMODE,-
		SENSECHAR,-
		>
	FUNCTAB	,-			; Buffered I/O functions
		<READLBLK,-
		WRITELBLK,-
		READVBLK,-
		WRITEVBLK,-
		READPBLK,-
		WRITEPBLK,-
		>
	FUNCTAB	PY$FDTREAD,<READLBLK,READVBLK,READPBLK>
	FUNCTAB PY$FDTWRITE,<WRITELBLK,WRITEVBLK,WRITEPBLK>
;	FUNCTAB +EXE$SETMODE,<SETMODE>
;	FUNCTAB +EXE$SETCHAR,<SETCHAR>
	FUNCTAB +EXE$SENSEMODE,<SENSEMODE,SENSECHAR>

	.SBTTL	Local Storage - Name of companion device

PTSTRING:	.ASCII	/PTA/
PTLENGTH = . - PTSTRING

	.PAGE
	.SBTTL	PY$FDTREAD - Function decision routine for PY control read
;++
; PY$FDTREAD
;
; Functional Description:
;
;	This routine is called from the function decision table dispatcher
; 	to process a read physical, read logical, read virtual I/O function.
;
;	The function first verifies the caller's parameters, terminating
;	the request with immediate success or error if necessary.
;	A system buffer is allocated and its
;	address is saved in the IRP.  The caller's quota is updated, and
;	the read request is queued to the driver for startup.
;
; Inputs:
;
;	R0,R1,R2	= Scratch
;	R3		= IRP Address
;	R4		= Address of PCB for current process
;	R5		= Device UCB address
;	R6		= Address of CCB
;	R7		= I/O function code
;	R8		= FDT Dispatch addr
;	R9,R10,R11	= Scratch
;	AP		= Address of function parameter list
;			P1(AP) = Buffer Address
;			P2(AP) = Buffer Size
;
; Outputs:
;
;	R0,R1,R2,R11	= Destroyed
;	R3-R10,AP	= Preserved (pickled)
;	IRP$L_SVAPTE(R3)= Address of allocated system buffer
;	IRP$W_BOFF(R3)	= Requested byte count
;
;	System Buffer:
;		LONGWORD/0	= Address of start of data= buff+12
;		LONGWORD/1	= Address of user buffer
;
;--
PY$FDTREAD::
	MOVZWL	P2(AP),R1	; Get buffer Size
	BNEQ	15$
	JMP	10$		; Is the size zero? If so, go do it easy.
15$:	MOVL	P1(AP),R0	; Get buffer Address
	JSB	G^EXE$READCHK	; Do we have access to the buffer
	PUSHR	#^M<R0,R3>	; Save user buffer address and IRP address
	ADDL	#12,R1		; Add 12 bytes for buffer header
	JSB	G^EXE$BUFFRQUOTA; Is there enough buffer space left in
				;  the quota?
	BLBC	R0, 30$		; Branch if insufficient quota
	JSB	G^EXE$ALLOCBUF	; Allocate a system buffer
	BLBC	R0, 30$		; Branch if none available
	POPR	#^M<R0,R3>	; Restore user buffer and irp address
	MOVL	R2,IRP$L_SVAPTE(R3)	; Save address of buffer
	MOVW	R1,IRP$W_BOFF(R3)	;  and requested byte count
	MOVZWL	R1,R1			; convert to longword count
	MOVL	PCB$L_JIB(R4),R11	; Get Jib address
	SUBL	R1,JIB$L_BYTCNT(R11)	; Adjust quota count
	MOVAB	12(R2),(R2)		; Save addr of start of user data
	MOVL	R0,4(R2)		; Save user buffer address in 2nd
					; longword
	JMP	G^EXE$QIODRVPKT	; Queue I/O packet to start I/O routine
;
; Did he request a read of zero bytes?
;
10$:	MOVL	#SS$_NORMAL,R0		; Everything is ok
	JMP	G^EXE$FINISHIOC		; complete I/O request
;
; Come here when something goes wrong
;
30$:	POPR	#^M<R0,R3>		; Clear buffer addr and restore IRP
	JMP	G^EXE$ABORTIO		; complete I/O request

	.PAGE
	.SBTTL	PY$FDTWRITE - Function decision routine for PY control write
;++
; PY$FDTWRITE
;
; Functional Description:
;
;	This routine is called from the function decision table dispatcher
; 	to process a write physical, write logical, write virtual I/O
;	function.
;
;	The function first verifies the caller's parameters, terminating
;	the request with immediate success or error if necessary.
;	The routine then immediately start cramming the characters into
;	the associated units typeahead buffer by calling putnxtchr.
;
; Inputs:
;
;	R0,R1,R2	= Scratch
;	R3		= IRP Address
;	R4		= Address of PCB for current process
;	R5		= Device UCB address
;	R6		= Address of CCB
;	R7		= I/O function code
;	R8		= FDT Dispatch addr
;	R9,R10,R11	= Scratch
;	AP		= Address of function parameter list
;		P1(AP)	= Buffer Address
;		P2(AP)	= Buffer Size
;
; Outputs:
;
;	R0,R1,R2	= Destroyed
;	R3-R8,AP	= Preserved (pickled)
;
; External Routines:
;
;	EXE$ABORTIO - FDT abort io routine
;	Input Parameters:
;		R0 - First longword of IOSB
;		R3 - IRP Address
;		R4 - PCB Address
;		R5 - UCB Address
;
;	EXE$FINISHIOC - FDT finish IO routine
;	Input Parameters:
;		R0 - First longword of IOSB
;		R3 - IRP Address
;		R4 - PCB Address
;		R5 - UCB Address
;
;	EXE$WRITECHK - Check access to buffer
;	Input Parameters:
;		R0 - Address of buffer
;		R1 - Size of buffer
;		R3 - IRP Address
;	Output Parameters:
;		R0,R1,R3 - Preserved
;		R2 - clear
;
;	@UCB$L_TT_PUTNXT(R5) - Port driver input character routine
;	Input Parameters:
;		R3 - character
;		R5 - UCB Address
;	Output Parameters:
;		R3 - if EQL then nothing
;		     if LSS then Burst address to output
;		     if GTR then char to output
;		R5 - UCB Address
;		R1,R2,R4 - trashed
;		R0 - Is this trashed or preserved? Documentation say preserve.
;
;--
PY$FDTWRITE::
	MOVZWL	P2(AP),R1	; Get buffer Size
	BEQL	40$		; Is the size zero? If so, go do it easy.
	MOVL	P1(AP),R0	; Get buffer Address
	JSB	G^EXE$WRITECHK	; Do we have access to the buffer
				; No return means no access
;
; Change the UCB's around abit
;
	PUSHR	#^M<R3,R4,R5>
	MOVZWL	R1,R9			; Set size in R9
	MOVL	UCB$L_PY_XUCB(R5),R5	; Set fake UCB in R5
;
; Loop through the packet R0 is address R9 is size
;
10$:
	MOVZBL	(R0)+,R3		; Get the byte and set address to next
	DSBINT	UCB$B_FIPL(R5)
	JSB	@UCB$L_TT_PUTNXT(R5)	; Buffer the character
	ENBINT
	TSTB	UCB$B_TT_OUTYPE(R5)	; Test output
	BLEQ	20$			; None or string output
	MOVB	R3,UCB$W_TT_HOLD(R5)	; save the character in tank
	BISW	#TTY$M_TANK_HOLD,-
		UCB$W_TT_HOLD(R5)	; Signal char in tank
	BRB	25$
20$:
	BEQL	30$			; No character
	BISW	#TTY$M_TANK_BURST,-	; Signal burst
		UCB$W_TT_HOLD(R5)
25$:	PUSHR	#^M<R0,R2,R3,R5,R9>	; Save State
	BICW	#UCB$M_TIM,UCB$W_STS(R5); Clear timeout
	MOVL	UCB$L_PT_XUCB(R5),R5	; Switch to PY UCB
	DSBINT	UCB$B_FIPL(R5)
	BBC	#UCB$V_BSY,UCB$W_STS(R5),27$
	MOVL	UCB$L_IRP(R5),R3	; Get IRP
	JSB	G^IOC$INITIATE		; Go to the start I/O
27$:	ENBINT
	POPR	#^M<R0,R2,R3,R5,R9>	; Restore State
30$:
	DECW	R9			; decrease number to do
	BGTR	10$			; if gtr then more to do
	POPR	#^M<R3,R4,R5>		; Restore real UCB and IRP
;
; Finish up the read
;
40$:
	MOVZWL	P2(AP),R0		; Move number of bytes output
	ASHL	#16,R0,R0		; Put it in the high word
	MOVW	#SS$_NORMAL,R0		; Everything is just fine
	JMP	G^EXE$FINISHIOC		; Complete the I/O request

	.PAGE
	.SBTTL	PY$CANCEL - Cancel the IO on the PY device
;++
;
; Functional Description:
;
;	This routine is entered to stop io on a PY unit.  If this is the last
;	deassign on the PY device, issue a CLASS_DISCONNECT on our associated
;	PT device to get it away from any processes using it.
;
; Inputs:
;
;	R2 = Negative of the Channel Number,
;		also called channel index number
;	R3 = Current IO package address
;	R4 = PCB of canceling process
;	R5 = UCB Address
;	R8 = CAN$C_CANCEL on CANCEL IO or CAN$C_DASSGN on DEASSIGN
;
; Outputs:
;	Everything should be preserved
;--
PY$CANCEL::					; Cancel PY usage
	JSB	G^IOC$CANCELIO			; Call the cancel routine
	BBC	#UCB$V_CANCEL,UCB$W_STS(R5),10$	; Branch if not for this guy
	MOVQ	#SS$_ABORT,R0			; Status is request canceled
	BICW	#<UCB$M_BSY!UCB$M_CANCEL>,-	;
		UCB$W_STS(R5)			; Clear unit status flags
	JSB	G^IOC$REQCOM			; Complete request
10$:	TSTW	UCB$W_REFC(R5)			; Last Deassign
	BNEQ	100$				; No, just exit
;
; Do a DISCONNECT on the PT device.
;
	pushr	#^M<r2, r3, r4, r5>
	movl	UCB$L_PY_XUCB(r5), r5		; Switch to PT UCB
	beql	20$				; if not there, skip
	clrl	UCB$L_PT_XUCB(r5)		; Clear backlink to PY device
	bisl2	#UCB$M_DELETEUCB, UCB$L_STS(r5) ; Set it to go bye-bye
	bicw2	#UCB$M_ONLINE,UCB$W_STS(R5)	; Mark offline
	bicb2	#UCB$M_INT, UCB$W_STS(r5)	; Don't expect interrupt
	movl	UCB$L_TT_LOGUCB(r5), r1		; Look at logical term UCB
	tstw	UCB$W_REFC(r1)			; See if PT has any references
	bneq	15$				; If so, go and do disconnect
	jsb	G^IOC$DELETE_UCB		; if not, delete the UCB
	brb	20$
15$:	clrl	r0				; indicate that we must hangup
	movl	UCB$L_TT_CLASS(r5), r1
	jsb	@CLASS_DISCONNECT(r1)		; Force disconnect
20$:	popr	#^M<r2, r3, r4, r5>		; Switch back to PY UCB
	clrl	UCB$L_PY_XUCB(r5)		; Clear link to deleted PT
	bisl2	#UCB$M_DELETEUCB, UCB$L_STS(r5)	; Set our own delete bit
100$:	rsb

	.PAGE
	.SBTTL PY$INITIAL - Initialize Pseudo terminal interface

;++
; PY$INITIAL - Initialize the interface
;
; Functional Description:
;
;	This routine is entered at device connect time and power recovery.
;	There isn't much to do to the device.
;
; Inputs:
;
;	R4 = The devices CSR  (but there is no csr!)
;	R5 = address of IDB
;	R6 = address of DDB
;	R7 = address of CRB
;
; Outputs:
;
;	All registers preserved
;
;--
PY$INITIAL::
	RSB

	.PAGE
	.SBTTL	PY$CLONE_INIT - initialize the unit
;++
; PY$CLONE_INIT - Initialize new PY device
;
; Functional Description:
;
;	Main thing we do here is clone up an associated terminal device
;	and initialize fields in the two new UCB's.
;
; Inputs:
;
;	R5	= Address of UCB
;
; Outputs:
;
;	All preserved
;--

PY$CLONE_INIT::

;+ ---
;	Ignore inits on UNIT #0 (the template PY UCB)
;- ---
	TSTL	UCB$W_UNIT(R2)			;UNIT #0??
	BNEQ	10$				;No: Initialize
	RSB					;Yes: Return

10$:	PUSHR	#^M<R0,R1,R2,R4,R6,R7,R8>
	Bicl2	#UCB$M_DELETEUCB,UCB$L_STS(R2)	; Clear ucbdelete - dec
	Movl	R2,R5
;
; Find the associated device.
;
; NOTE: We can't call IOC$SEARCHDEV because it expects the string to
;	be accessible from the previous access mode. (It executes the
;	prober instruction with mode=#0). I don't know how to make the
;	string accessible from the previous access mode cleanly, but I
;	do know how to move most of IOC$SEARCHDEV into the py driver.
;
	MOVAL	G^IOC$GL_DEVLIST-DDB$L_LINK,-	; Get address of i/o database
		R8				; listhead
	CLRL	R6				; Desired mate = PTY UNIT 0
	MOVAB	L^PTSTRING,R7			; String address for PTA
	MOVL	#PTLENGTH,R4			; String length
	BSBW	SEARCHDEV			; Find the DDB
	BNEQ	20$				; Device not found
	BSBW	SEARCHUNIT			; Search for specific unit
	BNEQ	30$				; unit found
20$:	POPR	#^M<R0,R1,R2,R4,R6,R7,R8>	; NOT FOUND: Return
	RSB
	
;
; Create the PTY, R1 has template UCB of PT device (reset SEEDs)
;
30$:	PUSHL	R5				; Save R5
	MOVL	UCB$L_DDB(R5),R0		; Find UNIT #0 UCB FOR PY DEV.
	MOVL	DDB$L_UCB(R0),R0
	MOVL	R1,R5				; R5 = UCB to CLONE
	JSB	G^IOC$CLONE_UCB			; Clone UCB

	MOVL	R2,R1				; Put PTY UCB back into R1
	POPL	R5				; Restore R5
	BLBS	R0,40$				; WIN!!! (big deal.)
;+ ---
;	CREATE_UCB failed, mark our PY device offline
;- ---
	BICW2	#UCB$M_ONLINE,UCB$W_STS(R5)	; Mark offline
	BRW	100$				; And return
;+ ---
;	PTY UCB created successfully, link the UCBs together
;- ---
40$:	MOVL	R1,UCB$L_PY_XUCB(R5)		; Store associated UCB
	MOVL	R5,UCB$L_PT_XUCB(R1)		; Store the other one back
	CLRL	UCB$L_PID(R1)			; Clear the owner PID in PTY
	CLRW	UCB$W_REFC(R1)			; Reference count is ZERO
	Bicl2	#UCB$M_DELETEUCB,UCB$L_STS(R1)	; Inhibit deletion
	MOVW	UCB$W_UNIT(R1),-		; Set associated PT unit
		UCB$L_DEVDEPEND(R5)		; number in PY devdepend
;+ ---
;	Call the PTY unit init routine
;- ---
	MOVL	UCB$L_DDT(R1),R0		; Get DDT
	MOVL	DDT$L_UNITINIT(R0),R0		; Get Unit Init Addr in DDT
	CMPL	R0,#IOC$RETURN			; Null Address??
	BNEQ	50$				; No: Call it
	MOVL	UCB$L_CRB(R1),R0		; Yes: Look in the CRB
	MOVL	CRB$L_INTD+VEC$L_UNITINIT(R0),R0
	BEQL	100$				; No: Unit init routine

50$:	PUSHL	R5				; Save R5
	MOVL	R1,R5				; R5 = PTY UCB
	JSB	(R0)				; CALL THE UNIT INIT ROUTINE
	POPL	R5				; Restore R5

100$:	POPR	#^M<R0,R1,R2,R4,R6,R7,R8>
	RSB

	.PAGE
	.SBTTL	DDB finding Routines
;++
; SearchDev - Search for device DDB
;
; This routine is called to search the device database for a DDB.
; This is the first step in finding another devices UCB.
;
; This routine copied out of IOC$SEARCHDEV in IOSUBPAGD
;
; Inputs:
;
;	R8 = DDB Head
;	R7 = Address of String
;		String = ddc format: example = /TTA/
;	R4 = Length of string
;
; Outputs:
;
;	R8 = DDB of desired device if EQL, otherwise not found
;	R0 is trashed
;	R1 is trashed
;--
SEARCHDEV:				; Search for device name
10$:	MOVL	DDB$L_LINK(R8),R8	; Get address of next ddb
	BEQL	20$			; If eql end of list
	MOVAL	DDB$T_NAME(R8),R0	; Get address of generic device name
	MOVB	(R0)+,R1		; Calculate len of string to compare
	CMPB	R1,R4			; Length of names match?
	BNEQ	10$			; If neq no
	CMPC	R4,(R0),(R7)		; Compare device names
	BNEQ	10$			; If neq names do not match
	RSB
20$:	INCL	R8			; indicate search failure
	RSB

	.SBTTL	UCB finding routine
;++
; SEARCHUNIT - Subroutine to search for UCB given DDB
;
; Given the DDB of a device, get the UCB and run down the ucb list until
; we get the ucb with the desired unit number.  This code is taken out of
; IOC$SEARCHDEV in IOSUBPAGD.
;
; Inputs:
;
;	R8 = DDB of device
;	R6 = unit number of desired UCB
;
; Outputs:
;
;	R1 = UCB of device if NEQ, otherwise not found
;	R0 is trashed
;
;--
SEARCHUNIT:				; Search for unit number
	MOVAL	DDB$L_UCB-UCB$L_LINK(R8),-
		R1			; Get address of next ucb address
10$:	MOVL	UCB$L_LINK(R1),R1	; Get Address of next ucb
	BEQL	40$			; If EQL then end of list
	CMPW	R6,UCB$W_UNIT(R1)	; Unit number match?
	BEQL	30$			; If eql yes
	BRB	10$
30$:	MOVL	#SS$_NORMAL,R0		; Indicate match
40$:	RSB

	.PAGE
	.SBTTL	PY$STARTIO - Device Startio routines
;++
; PY$STARTIO	- Start Input on idle device
;
; Functional Description:
;
;	If after the read FDT routines are done and nobody is doing
;	anything on the device (UCB$V_BSY = 0) then call the start io
;	routine.
;
; Called from:
;
;	Called from any one of five places:
;	- The EXE$QIODRVPKT in the PY FDT READ routine
;		which calls EXE$INSIOQ which calls IOC$INITIATE
;	- The IOC$REQCOM at the end of this PY startio routine
;		which calls IOC$INITIATE
;	- The PT startio routine which calls IOC$INITIATE
;	- The PY write fdt routine which calls IOC$INITIATE.
;		In case we must echo a character.
;	- The PY$RESUME routine which calls IOC$INITIATE.
;
; Inputs:
;
;	R3 = IRP Address
;	R5 = UCB Address
;		UCB$W_BCNT and UCB$L_SVAPTE are written by IOC$INITIATE
;
; Outputs:
;
;	R5 - UCB Address
;
;--
PY$STARTIO::
	.ENABLE LSB

	MOVL	@UCB$L_SVAPTE(R5),-		; Initialize buffer
		UCB$L_SVAPTE(R5)		;  pointers
PY_OUT_LOOP:
;
; Here R5 must point at the PY device UCB and not at
;  the UCB of the associated PT device.
;
5$:	TSTW	UCB$W_BCNT(R5)			; Any space left in rd packet
	BLEQ	50$				; No, Completed I/O
;
; Switch to terminal UCB
;
	MOVL	UCB$L_PY_XUCB(R5),R5		; Set to PT ucb
;
; Look for next output in state tank
;
; Change Case statement to reflect V4 changes in routines - DEC 
;
10$:	FFS	#0,#6,UCB$W_TT_HOLD+1(R5),R3
	CASE	R3,TYPE=B,<-			; Dispatch
		PY_PREMPT,-			; Send Prempt Characte - DEC 
		PY_STOP,-			; Stop output
		PY_CHAR,-			; Char in tank
		PY_BURST,-			; Burst in progress
		>
;
; No Pending Data - Look for next character
;
	BICB	#UCB$M_TIM!UCB$M_INT,-		; Clear timeout and expected
		UCB$W_STS(R5)
;
; Call class driver for more output
;
	JSB	@UCB$L_TT_GETNXT(R5)	; Get the next character
	CASEB	UCB$B_TT_OUTYPE(R5),#-1,#1
1$:	.WORD	PY_START_BURST-1$	; Burst specified
	.WORD	PY_DONE-1$		; None
	BRW	BUFFER_CHAR		; Buffer the character
;
; Output queue exhausted
PY_DONE:
	MOVL	UCB$L_PT_XUCB(R5),R5	; Switch UCBs to PY UCB
	BBC	#UCB$V_BSY,-		; If not BSY then ignore
		UCB$W_STS(R5),47$	; the char
	MOVL	UCB$L_IRP(R5),R3	; Restore IRP
	CMPW	IRP$W_BCNT(R3),-	; Any characters moved
		UCB$W_BCNT(R5)
	BNEQ	50$			; Yes complete I/O
47$:	RSB
;
; read buffer exhausted
;
50$:	MOVL	UCB$L_IRP(R5),R3	; Restore IRP
	MOVW	#SS$_NORMAL,-		; Set successful completetion
		IRP$L_IOST1(R3)
	SUBW	UCB$W_BCNT(R5),-	; Update byte count
		IRP$W_BCNT(R3)
	MOVW	IRP$W_BCNT(R3),-	; Set in status
		IRP$L_IOST1+2(R3)
;
; If we wanted to here we could set the second longword of the device status
;
	CLRL	IRP$L_IOST2(R3)		; No status
	MOVQ	IRP$L_IOST1(R3),R0	; Load IOSB return values

	JMP	G^IOC$REQCOM
;
; Put the character into the read buffer
;
BUFFER_CHAR:
	MOVL	UCB$L_PT_XUCB(R5),R5	; Switch UCBs to PY UCB
	BBC	#UCB$V_BSY,-
		UCB$W_STS(R5), 60$	; If no PY IRP, ignore
	MOVB	R3,@UCB$L_SVAPTE(R5)	; Add character to buffer
	INCL	UCB$L_SVAPTE(R5)	; Bump pointer
	DECW	UCB$W_BCNT(R5)		; Show character added
60$:	BRW	PY_OUT_LOOP		; Go for another char
;
; Take care of Burst mode R5 must be PT UCB
;
PY_START_BURST:
	BISW	#TTY$M_TANK_BURST,-	; Signal burst active
		UCB$W_TT_HOLD(R5)
;
; Continue burst
;
PY_BURST:
	MOVL	UCB$L_PT_XUCB(R5),R1	; Save PY UCB in R1
	CLRL	R3			; Initialize output size
	CMPW	UCB$W_TT_OUTLEN(R5),UCB$W_BCNT(R1)  ; Is buffer too small?
	BGTR	61$			; Yes
	MOVW	UCB$W_TT_OUTLEN(R5),R3	; Nope, so output all
	BRB	62$
61$:	MOVW	UCB$W_BCNT(R1),R3	; Just output what we can

62$:	PUSHR	#^M<R0,R1,R2,R3,R4,R5>	; MOVC3 destroys these registers
	MOVC3	R3,@UCB$L_TT_OUTADR(R5),@UCB$L_SVAPTE(R1)
					; Transfer burst to the buffer
	POPR	#^M<R0,R1,R2,R3,R4,R5>	; Restore the registers

	ADDL2	R3,UCB$L_SVAPTE(R1)	; Update output pointer
	SUBW2	R3,UCB$W_BCNT(R1)	; Update output count
	ADDL2	R3,UCB$L_TT_OUTADR(R5)	; Update input pointer
	SUBW2	R3,UCB$W_TT_OUTLEN(R5)	; Update input count
	BNEQ	65$			; Not the last character
	BICW	#TTY$M_TANK_BURST,-
		UCB$W_TT_HOLD(R5)	; Reset burst not active
65$:	MOVL	UCB$L_PT_XUCB(R5),R5	; Swicht UCBs to PY UCB
	BRW	PY_OUT_LOOP
;
; Get a single char from tt and put in read buffer R5 = PT UCB
;
PY_CHAR:
	MOVB	UCB$W_TT_HOLD(R5),R3	; Get the next byte
	BICW	#TTY$M_TANK_HOLD,-	; Show tank empty
		UCB$W_TT_HOLD(R5)
	BRW	BUFFER_CHAR
;
; Stop the output R5 = PT UCB
;
; Deleted PY_STOP2 routine and changed bit clear to byte operation - DEC 
;
PY_STOP:
	BICB	#UCB$M_INT!UCB$M_TIM,-	; DEC 
		UCB$W_STS(R5)		; Reset output active
	BRW	PY_DONE			; DON'T go for anymore
					; Or we'll get into an infinite loop
;
; Send Xon or Xoff characters, R5 = PT UCB
;
; Changed PY_XOFF and PY_XON to be PY_PREMPT - DEC 
;
PY_PREMPT:
	movb	UCB$B_TT_PREMPT(r5), r3	; Pick up the character
	BICW	#TTY$M_TANK_PREMPT,-	; Reset Xoff state
		UCB$W_TT_HOLD(R5)
	BRW	BUFFER_CHAR
	.DISABLE LSB

PY$END:
					; End of driver
	.END
*$*$*EOD*$*$*
$ exit

