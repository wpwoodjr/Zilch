/* Zilch Screen Editor,
 *	Copyright (c) 1982,1983,1984,1986,1987 William P. Wood, Jr. */

#include "symbols.h"
#include "terminal.cmn"
#include "syscodes.h"

#if VMS
# include "descr.h"

void ti_initialize(void)
{
  long int plen, pid, biocnt, bytcnt, astcnt;
  int status;
  char ttnam[63], process_name[16];
  vms_char_descr(d_ttnam, ttnam, 63);
  static vms_char_descr(d_sys$command, "SYS$COMMAND", sizeof("SYS$COMMAND")-1);

  ti_flush_iofc = IO$_WRITEVBLK | IO$M_NOFORMAT;
  ti_in_type_ahead_iofc = IO$_READVBLK | IO$M_TRMNOECHO | IO$M_NOFILTR |
	IO$M_NOECHO | IO$M_TIMED;
  ti_in_character_iofc = IO$_READVBLK | IO$M_TRMNOECHO | IO$M_NOFILTR |
	IO$M_NOECHO;
  icr_trnlog_str(&d_sys$command, &d_ttnam);
  ti_channel = 0;
  status = 0;
  plen = sizeof(process_name);
  if (get_process_info(process_name, &plen, &pid, &biocnt, &bytcnt, &astcnt)) {
    if (astcnt >= 3 && biocnt >= 3 &&
    				bytcnt >= BUFFER_SIZE + MBX_SIZE + 2048) {
      sprintf(mbx.name, "Z_%08x", pid);
      status = sys$crembx(0, &mbx.channel, MBX_SIZE,
			  min(4*MBX_SIZE, bytcnt - BUFFER_SIZE - 2048),
			  0xFF0F, 0, &d_mbx_name);
      if (status)
	status = sys$assign(&d_ttnam, &ti_channel, 0, &d_mbx_name);
      if (status) {
	ef_in_mask = (1 << TI_IN_EFN) + (1 << MBX_IN_EFN);
	mbx_read();
	}
      }
    }
  if (! status) {
    mbx.channel = 0;
    ef_in_mask = 1 << TI_IN_EFN;
    status = sys$assign(&d_ttnam, &ti_channel, 0, 0);
    }
  ti_get_characteristics();
  ti_disable_ctrl();
}

void ti_disable_ctrl(void)
{
  long int di_mask[2] = { 0, 0x8 };

  if (ttclass == dc$_term) {
    lib$disable_ctrl(0x100000, ti_ctrl_mask);		/* disable ^T */
    status = sys$qiow(0, ti_channel,			/* enable ^C AST */
		  IO$_SETMODE | IO$M_OUTBAND, iosb,
		  0, 0, ti_ctrl_ast, di_mask, 0, 0, 0, 0);
    ttchar_save = ttchar;
    ttxchar_save = ttxchar;
    ttchar = (ttchar | TT$M_NOBRDCST | TT$M_MECHFORM) & (! TT$M_MECHTAB);
    if (mbx.channel != 0) {
      ttchar = ttchar | TT$M_MBXDSABL;
      ttxchar = ttxchar | TT2$M_BRDCSTMBX;
      }
    status = sys$qiow( , %val(ti_channel), %val(IO$_SETMODE), iosb,
		       , , characteristics, %val(12), , , , );
    ttchar = ttchar_save;
    ttxchar = ttxchar_save;
    }
  return;

  entry ti_enable_ctrl
  if (ttclass == dc$_term) {
    status = sys$qiow( , %val(ti_channel), %val(IO$_SETMODE), iosb,
		       , , characteristics, %val(12), , , , );
    status = sys$qiow( , %val(ti_channel),		/* disable ^C AST */
		  %val(IO$_SETMODE | IO$M_OUTBAND), iosb,
		  , , %val(0), di_mask, %val(0), , , );
    lib$enable_ctrl(ti_ctrl_mask);			/* enable ^T */
    }
  return
}

void ti_ctrl_ast(void)
{
# include "memory.cmn"
# include "pushb.cmn"
# include "session.cmn"
# include "screen.cmn"

  if (se_count > 1) {				/* abort repeating commands */
    se_count = 0;
    sc_error_occurred = true;
    se_error_occurred = true;
    }
  else if (pu_buffer != null)
    if (bu_size(pu_buffer) > 0) {		/* abort pushed back commands */
      sc_error_occurred = true;
      se_error_occurred = true;
      }
  else if (se_interrupt_enabled) {		/* handling interrupts */
    sc_error_occurred = true;
    se_error_occurred = true;
    }
  return;
}

void ti_finish(void)
{

  ti_enable_ctrl();
  status = sys$dassgn(%val(ti_channel));
  if (mbx.channel != 0)
    status = sys$dassgn(%val(mbx.channel));
  return
}

void ti_get_characteristics(void)
{
  int first;
  save first;
  data first /true/;

  if (first) {
    first = false;
    status = sys$qiow( , %val(ti_channel), %val(IO$_SENSEMODE), iosb,
		  , , characteristics, %val(12), , , , );
    if (ttclass != dc$_term) {
      ti_channel = 0;
      te_type = VT100;
      ti_fast = true;
      ti_lffill = 0;
      ti_width = 80;
      ti_length = 24;
      }
    else {
      if (tttype == TT$_VT52)
	te_type = VT52;
      else if ((ttxchar & TT2$M_DECCRT) != 0)
	te_type = VT100;
      else if (tttype == TT$_VT100 ||
	       tttype == TT$_VT101 ||
	       tttype == TT$_VT102 ||
	       tttype == TT$_VT105 ||
	       tttype == TT$_VT125 ||
	       tttype == TT$_VT131 ||
	       tttype == TT$_VT132 ||
	       tttype == TT$_VT200_SERIES)
	te_type = VT100;
      else
	te_type = ADM3A;
/* ti_fast should be set true at speeds over 2400 baud. */
      if (ttspeed > TT$C_BAUD_2400)
	ti_fast = true;
      else
	ti_fast = false;
      ti_lffill = lffill;
      if (ti_lffill > 24 || ti_lffill < 0)
	ti_lffill = 24;
      ti_width = ttwidth;
      ti_length = ttlength;
      }
    }
  return
}
 
void ti_outch(const char *output, int count)
{
  data ti_count/0/;

  for (ip = 1; ip <= count; ip = ip+n) {
    if (ti_count >= BUFFER_SIZE)
      ti_flush();
    n = min(count+1-ip, BUFFER_SIZE - ti_count);
    movc(output(ip), ti_buffer[ti_count], n);
    ti_count = ti_count + n;
    }
  return
}

void ti_flush(void)
{

  if (ti_count > 0) {
    sys$qiow( , %val(ti_channel), %val(ti_flush_iofc), , , , ti_buffer,
 	%val(ti_count), , %val(0), , );
    ti_count = 0;
    }
  return
}

void ti_kill(void)
{

  ti_count = 0;
  return
}

pint q_ti_in_type_ahead(c)
{
  char c;

  sys$qiow( , %val(ti_channel), %val(ti_in_type_ahead_iofc),
		iosb, , , c, %val(1), %val(0), , , );
  if (trm_offset + trm_size > 0) {
    if (c == 033)
      ti_interpret_escape(c);
    return true;
    }
  return false;
}

void ti_queue_character_read(void)
{
  integer errcnt;
  save errcnt;
  data errcnt /0/;

  ti_character = 031;				/* ^Y */
  if (! sys$qio(%val(TI_IN_EFN), %val(ti_channel), %val(ti_in_character_iofc),
	  iosb, , , ti_character, %val(1), , , , )) {
    errcnt++;
    if (errcnt > 6)
      ti_exit();
    ti_character = 0;				/* indicates QIO error */
    iosb_status = 1;
    }
  return
}

void ti_get_character(c)
{
  char c;

  if (! iosb_status) {
L10: sys$wflor(%val(TI_IN_EFN), %val(ef_in_mask));
    if (! iosb_status) {
      mbx_handler();
      goto L10;
      }
    }
  c = ti_character;
  if (c == 033)
    ti_interpret_escape(c);
  return
}

void ti_interpret_escape(c)
{
# include "bind.cmn"
  byte c, ta_characteristics(8), ta_character;
  integer*2 ta_count;
  equivalence (ta_characteristics(1), ta_count),
	      (ta_characteristics(3), ta_character)
  integer*4 delta(2);
  data delta/_arith(20,*,-100000), -1/		/* wait in 100ths of seconds */

  if (bind.alternate_escape != EOS) {
    sys$qiow( , %val(ti_channel), %val(IO$_SENSEMODE | IO$M_TYPEAHDCNT),
		  , , , ta_characteristics, %val(8), , , , );
    if (ta_count == 0) {
      sys$setimr(%val(0), delta, , );
      sys$waitfr(%val(0));
      sys$qiow( , %val(ti_channel), %val(IO$_SENSEMODE | IO$M_TYPEAHDCNT),
		    , , , ta_characteristics, %val(8), , , , );
      }
    if (ta_count != 0)
      if (bind.alternate_escape_followers[ta_character])
	c = bind.alternate_escape;
    }
  return
}

void ti_exit(void)
{

  ti_kill();
  te_finish();
  ti_flush();
  ti_finish();
  dcl_finish();
  checkpoint_modified_files();
  ed_save_session();
  stop _
"Zilch - QIO error! Attempted to checkpoint modified files. Exiting...";
}

void mbx_handler(void)
{
# include "memory.cmn"
# include "session.cmn"
# include "screen.cmn"
%	#include '($msgdef)'
  int mbread;
  character date*23;
  static const char bell[] = "\7",
		    crlf[] = "\15\12";
  static char bname[] = "Broadcast  9-Jul-1984 11:56:07.00";
  equivalence (date, bname(11))

  mbread = false;
  if (! mbx.iosb.status)
    ;
  else if (mbx.bdcst.type == msg$_trmbrdcst && mbx.iosb.byte_count >= 2) {
    lib$sys_asctim( , date);
    mlen = mbx.bdcst.size;
    if (q_bu_pop_up_message(mbx.bdcst.msg, mlen, bname)) {
      sc_fill_line(sc_size,sc_buffer(1,sc_size,sc_old),
			sc_old_length(sc_size));
      sc_update(&zero);
      ti_outch(bell, 1);
      }
    else {
      send_tty(crlf, 2);
      send_tty(mbx.bdcst.msg, mlen);
      }
    ti_flush();
    }
  else if (mbx.iosb.byte_count < 2 ||
      (mbx.bdcst.type != msg$_trmhangup && mbx.bdcst.type != msg$_trmunsolic)) {
    bu = bu_find_by_name("Session log");
    if (bu != null) {
      t = bu_size(bu) + 1;
      mlen = mbx.iosb.byte_count;
      if (bu_gap_size(bu) < mlen)
	tx_more_memory_please(bu,4*4*512+mlen);
      tx_insert_buffer(bu, bu_size(bu) + 1, mbx.buffer, mlen);
      mbx_read();
      mbread = true;
      tx_insert_character(bu, NEWLINE, bu_size(bu) + 1);
      bu_map_windows(bu,wi)
	if (wi_dot(wi) == t) {			/* display new stuff in window */
	  wi_dot(wi) = bu_size(bu) + 1;
	  t2 = wi_dot(wi);
	  for (i = 1; i < wi_size(wi); i = i+1)
	    t2 = find_bol(bu, max(1, t2 - 1));
	  if (wi_bow(wi) < t2)
	    wi_set_bow(wi,t2);
	  }
      bu_modified(bu) = 0;
      if (! mbx.iosb.status && ! iosb_status) {
	sc_fill_line(sc_size,sc_buffer(1,sc_size,sc_old),
			  sc_old_length(sc_size));
	sc_update(&zero);
	}
      }
    }
  if (! mbread)
    mbx_read();
  return
}

void mbx_read(void)
{
  external mbx_ast();

  status = sys$qio(%val(MBX_IN_EFN), %val(mbx.channel), %val(IO$_READVBLK),
	     mbx.iosb, mbx_ast, , mbx.buffer, %val(MBX_SIZE), , , , );
  return
}

void mbx_ast(void)
{
%	#include '($msgdef)'

  if (! mbx.iosb.status)
    ;
  else if (mbx.bdcst.type == msg$_trmhangup && mbx.iosb.byte_count >= 2) {
    checkpoint_modified_files();
    ed_save_session();
    }
  return
}

#endif
