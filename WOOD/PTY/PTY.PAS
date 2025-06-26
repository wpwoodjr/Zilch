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
