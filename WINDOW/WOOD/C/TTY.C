/*	Zilch Screen Editor,
 *	Copyright (c) 1982,1983,1984,1986,1987 William P. Wood, Jr. */

#include "symbols.h"

static void send_tty(const char *buf, int len)
{
# include "terminal.cmn"
  static const char lf[] =
		    "\12\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0";

  for ( ; len-- > 0; buf++)
    if (*buf == *lf)
      ti_outch(lf, 1 + ti_lffill);
    else
      ti_outch(buf, 1);
  te_pos_x = te_size_x+1;		/* invalidate cursor position */
}

void send_string_to_terminal(const char *buf)
{
  send_tty(buf, ho_length(buf));
  ti_flush();
}

void send_message_to_terminal(const char *buf)
{
  static const char crlf[] = "\15\12";

#if ! VAX
  send_tty(crlf,2);
#endif
  send_tty(buf,ho_length(buf));
#if VAX
  send_tty(crlf,2);
#endif
  ti_flush();
}

int get_tty_character(void)
{
# include "memory.cmn"
# include "session.cmn"
# include "macro.cmn"
# include "pushb.cmn"
# include "terminal.cmn"
  char c;
  static int was_type_ahead = false;

  if (se_error_occurred) {
    se_error_occurred = false;
    bu_clear_text(pu_buffer);			/* purge push-back-buffer */
    sc_update(&zero);				/* force screen update */
    while (q_ti_in_type_ahead(&pu_tty_c))	/* purge type-ahead */
      ;
    was_type_ahead = false;
    ti_queue_character_read();
    ti_get_character(&pu_tty_c);
    c = pu_tty_c;
    }
  else if (bu_size(pu_buffer) > 0) {
    pu_nextc(pu_buffer,&pu_tty_c);
    c = abs(pu_tty_c);
    }
  else {
    if (! was_type_ahead)
      goto L10;
    if (! q_ti_in_type_ahead(&pu_tty_c)) {
      was_type_ahead = false;
L10:  ti_queue_character_read();
      sc_update(&iosb_status);		/* now we update the screen! */
      if (iosb_status)
	was_type_ahead = true;
      ti_get_character(&pu_tty_c);
      }
    c = pu_tty_c;
    }
  if (ma_defining_macro)
    if (pu_tty_c >= 0)		     /* pu_tty_c < 0 - pushed back character */
      if (ma_next >= MACRO_SIZE) {
	ms_error("Keyboard macro overflow!");
	ma_delete(0);
	}
      else {
	ma_text[ma_next++] = c;
	ma_len[0] += 1;
	}
  pu_last_key_struck = c;
  return c;
}

int q_get_tty_number(long int *n, const char *pr)
{
  long int local_n;
  int neg, result, d;
  char c;

  local_n = 0;
  ms_message(pr);
  c = get_tty_character();
  if (c == '-') {
    neg = true;
    ms_message(pr);
    ms_add_to_message("-");
    c = get_tty_character();
    }
  else
    neg = false;
  result = false;
  for ( ; (d = ho_index("0123456789", c)) != 0; ) {
    result = true;
    local_n = 10*local_n + d - 1;
    ms_report_number(pr, local_n, "");
    c = get_tty_character();
    }
  pu_push_back_character(c);
  *n = neg ? - local_n : local_n;
  return result;
}
