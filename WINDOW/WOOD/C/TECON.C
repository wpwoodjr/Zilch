/*	Zilch Screen Editor,
 *	Copyright (c) 1982,1983,1984,1986,1987 William P. Wood, Jr. */

#include "symbols.h"
#include "terminal.cmn"

static void te_output_number(register int n)
{
  char ot[3];

  if (n < 10) {
    ot[0] = n + '0';
    ti_outch(ot, 1);
    }
  else if (n < 100) {
    ot[0] = n/10 + '0';
    ot[1] = mod(n, 10) + '0';
    ti_outch(ot, 2);
    }
  else {
    ot[0] = n/100 + '0';
    ot[1] = mod(n/10, 10) + '0';
    ot[2] = mod(n, 10) + '0';
    ti_outch(ot, 3);
    }
}

static void te_set_window(int top, int bot)
{
# define len_vt100_set_window 2
  static char vt100_set_window[] = "\33[";

  ti_outch(vt100_set_window, len_vt100_set_window);
  if (top > 1)
    te_output_number(top);
  ti_outch(";", 1);
  if (bot != 0)
    te_output_number(bot);
  ti_outch("r", 1);
  te_pos_x = 1;
  te_pos_y = top;
}

void te_initialize(void)
{
  ti_kill();
  switch (te_type) {
    case VT100:
      te_size_x = 80;
      te_size_y = 24;
      te_rv = true;
      te_in = true;
      te_application_keypad = false;
      break;
    case ADM3A:
    case ADM5:
    case VT52:
      te_size_x = 80;
      te_size_y = 24;
      te_rv = false;
      te_in = false;
      te_application_keypad = false;
      break;
    }
  te_pos_x = te_size_x + 1;		/* invalidate cursor position */
}

int q_te_set_type(char *type)
{
  if (q_ho_equal(type, "vt100"))
    te_type = VT100;
  else if (q_ho_equal(type, "adm3a"))
    te_type = ADM3A;
  else if (q_ho_equal(type, "adm5"))
    te_type = ADM5;
  else if (q_ho_equal(type, "vt52"))
    te_type = VT52;
  else
    return false;
  te_initialize();
  return true;
}

int q_te_set_width(int width)
{
  int result;

  result = false;
  switch (te_type) {
    case VT100:
      if (width >= 1)
	if (width <= 80) {
	  te_size_x = 80;
	  result = true;
	  }
	else if (width <= 132) {
	  te_size_x = 132;
	  result = true;
	  }
      break;
    case ADM3A:
    case ADM5:
    case VT52:
      if (width >= 1 && width <= 80) {
	te_size_x = 80;
	result = true;
	}
      break;
    }
  te_pos_x = te_size_x + 1;		/* invalidate cursor position */
  return result;
}

int q_te_set_length(int length)
{
  switch (te_type) {
    case VT100:
      if (length >= 1)
	if (length <= SCREEN_SIZE) {
	  te_size_y = max(ti_length, length); /* te_size_y is max screen len */
	  return true;
	  }
      break;
    case ADM3A:
    case ADM5:
    case VT52:
      if (length >= 1)
	if (length <= 24) {
	  te_size_y = 24;
	  return true;
	  }
      break;
    }
  return false;
}

/* Position the cursor */
void te_pos(int irow, int icol)
{
  int dif;
  static const char bspaces[] = "\10\10\10";
  char c;

  if (te_pos_x >= te_size_x || te_pos_x != icol || te_pos_y != irow) {
    dif = te_pos_x - icol;
    if (te_pos_x < te_size_x && te_pos_y == irow && dif > 0 && dif < 4)
      ti_outch(bspaces, dif);
    else {
      switch (te_type) {
	case ADM3A:
	case ADM5:
	  ti_outch("\33=", 2);
	  c = irow + 31;
	  ti_outch(&c, 1);
	  c = icol + 31;
	  ti_outch(&c, 1);
	  break;
	case VT52:
	  ti_outch("\33Y", 2);
	  c = irow + 31;
	  ti_outch(&c, 1);
	  c = icol + 31;
	  ti_outch(&c, 1);
	  break;
	case VT100:
	  ti_outch("\33[", 2);
	  te_output_number(irow);
	  ti_outch(";", 1);
	  te_output_number(icol);
	  ti_outch("H", 1);
	  break;
	}
      }
    te_pos_x = icol;
    te_pos_y = irow;
    }
}

void te_clear(void)
{
  switch (te_type) {
    case ADM3A:
    case ADM5:
      ti_outch("\33;\32", 3);
      break;
    case VT100:
      ti_outch("\33[2J\33[H", 7);
      break;
    case VT52:
      ti_outch("\33H\33J", 4);
      break;
    }
  te_pos_x = 1;
  te_pos_y = 1;
}

void te_init_sequence(void)
{
# include "screen.cmn"
# define len_vt100_init 26
  static char vt100_init[] = "\33<\33[?6h\33[;r\33>\33[?7l\33[?1l\33[m";
					/* enter ANSI mode,
					 * set origin mode - relative,
					 * set full screen scroll region,
					 * key pad - numeric,
					 * no auto wrap,
					 * cursor mode reset,
					 * normal text attributes */
# define len_vt100_application 2
  static char vt100_application[] = "\33=";	/* key pad - application */
# define len_vt100_set_80 5
  static char vt100_set_80[] = "\33[?3l";	/* set terminal width to 80 */
# define len_vt100_set_132 5
  static char vt100_set_132[] = "\33[?3h";	/* set terminal width to 132 */
# define len_vt52_init 2
  static char vt52_init[] = "\33>";		/* key pad - numeric */
# define len_vt52_application 2
  static char vt52_application[] = "\33=";	/* key pad - application */

  switch (te_type) {
    case VT100:
      ti_outch(vt100_init, len_vt100_init);
      if (te_application_keypad)
	ti_outch(vt100_application, len_vt100_application);
      if (sc_width <= 80 && ti_width > 80)
	ti_outch(vt100_set_80, len_vt100_set_80);
      else if (sc_width > 80 && ti_width <= 80)
	ti_outch(vt100_set_132, len_vt100_set_132);
      break;
    case VT52:
      ti_outch(vt52_init, len_vt52_init);
      if (te_application_keypad)
	ti_outch(vt52_application, len_vt52_application);
      break;
    }
  te_pos_x = te_size_x + 1;		/* invalidate cursor position */
}

void te_finish(void)
{
# include "screen.cmn"
# define len_vt100_finish 11
  static char vt100_finish[] = "\33[?6l\33[;r\33>";
      					/* set origin mode - absolute,
					 * set full screen scroll region,
					 * key pad - numeric */
# define len_vt100_set_80 5
  static char vt100_set_80[] = "\33[?3l";  /* set terminal width to 80 */
# define len_vt100_set_132 5
  static char vt100_set_132[] = "\33[?3h"; /* set terminal width to 132 */
# define len_vt52_finish 2
  static char vt52_finish[] = "\33>";	/* key pad - numeric */

  switch (te_type) {
    case VT100:
      ti_outch(vt100_finish, len_vt100_finish);
      if (ti_width <= 80 && sc_width > 80)
	ti_outch(vt100_set_80, len_vt100_set_80);
      else if (ti_width > 80 && sc_width <= 80)
	ti_outch(vt100_set_132, len_vt100_set_132);
      break;
    case VT52:
      ti_outch(vt52_finish, len_vt52_finish);
      break;
    }
  te_pos_x = te_size_x + 1;		/* invalidate cursor position */
}

void te_scroll_up_lines(int top, int bot, register int nlines)
{
# define len_vt100_cursor_down 2
  static char vt100_cursor_down[] = "\33[";
  static char lfnull[] = "\12\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0";

  switch (te_type) {
    case VT100:
      te_set_window(top, bot);
      ti_outch(vt100_cursor_down, len_vt100_cursor_down);
      te_output_number(bot - top);
      ti_outch("B", 1);
      for ( ; nlines > 0; nlines--)
	ti_outch(lfnull, 1);
      te_set_window(1, 0);
      break;
    case ADM3A:
    case ADM5:
    case VT52:
      /* can only be scroll screen */
      te_pos(te_size_y, 1);
      for ( ; nlines > 0; nlines--)
	ti_outch(lfnull, 1 + ti_lffill);
      break;
    }
}

void te_scroll_down_lines(int top, int bot, register int nlines)
{
# define len_vt100_reverse_index 2
  static char vt100_reverse_index[] = "\33M";

  te_set_window(top, bot);
  for ( ; nlines > 0; nlines--)
    ti_outch(vt100_reverse_index, len_vt100_reverse_index);
  te_set_window(1, 0);
}

void te_erase_to_end_of_line(int old, int new)
{
# define len_adm5_erase_to_eol 2
# define len_vt100_erase_to_eol 3
# define len_vt52_erase_to_eol 2
  static char adm5_erase_to_eol[] = "\33T";
  static char vt100_erase_to_eol[] = "\33[K";
  static char vt52_erase_to_eol[] = "\33K";
  static char blanks80[80] =
"                                                                                ";
  register int i;

  i = min(old, te_size_x) - min(new, te_size_x);
  switch (te_type) {
    case VT100:
      if (i >= len_vt100_erase_to_eol)
	ti_outch(vt100_erase_to_eol, len_vt100_erase_to_eol);
      else if (i > 0) {
	ti_outch(blanks80, i);
	te_pos_x = te_pos_x+i;
	}
      break;
    case VT52:
      if (i >= len_vt52_erase_to_eol)
	ti_outch(vt52_erase_to_eol, len_vt52_erase_to_eol);
      else if (i > 0) {
	ti_outch(blanks80, i);
	te_pos_x = te_pos_x+i;
	}
      break;
    case ADM5:
      if (i >= len_adm5_erase_to_eol)
	ti_outch(adm5_erase_to_eol, len_adm5_erase_to_eol);
      else if (i > 0) {
	ti_outch(blanks80, i);
	te_pos_x = te_pos_x+i;
	}
      break;
    case ADM3A:
      if (i > 0) {
	ti_outch(blanks80, i);
	te_pos_x = te_pos_x+i;
	}
      break;
    }
}

void te_reverse_video(void)
{
# define len_vt100_reverse_video 4
  static char vt100_reverse_video[] = "\33[7m";

  switch (te_type) {
    case VT100:
      ti_outch(vt100_reverse_video, len_vt100_reverse_video);
      break;
    }
}

void te_reverse_video_off(void)
{
# define len_vt100_reverse_video_off 3
  static char vt100_reverse_video_off[] = "\33[m";

  switch (te_type) {
    case VT100:
      ti_outch(vt100_reverse_video_off, len_vt100_reverse_video_off);
      break;
    }
}

void te_printer_on(void)
{
# define len_vt100_printer_on 4
  static char vt100_printer_on[] = "\33[5i";

  switch (te_type) {
    case VT100:
      ti_outch(vt100_printer_on, len_vt100_printer_on);
      break;
    }
}

void te_printer_off(void)
{
# define len_vt100_printer_off 4
  static char vt100_printer_off[] = "\33[4i";

  switch (te_type) {
    case VT100:
      ti_outch(vt100_printer_off, len_vt100_printer_off);
      break;
    }
}
