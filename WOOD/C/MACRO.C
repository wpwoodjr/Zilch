/*	Zilch Screen Editor,
 *	Copyright (c) 1982,1986,1987 William P. Wood, Jr. */

#include "symbols.h"
#include "macro.cmn"

void ma_initialize(void)
{
  int i;

  for (i = 0; i < MAX_MACROS; i++) {
    ma_len[i] = 0;
    ma_start[i] = 0;
    }
  ma_next = 0;
  ma_defining_macro = false;
}

void ma_begin(void)
{
  if (ma_defining_macro)
    ms_error("Already remembering... previous characters lost!");
  else
    ms_message("Remembering...");
  ma_defining_macro = true;
  ma_delete(0);
  ma_start[0] = ma_next;
}

void ma_end(void)
{
# include "pushb.cmn"

  /* if pu_tty_c is < 0 then this "macro end" command came from a pushed back
   * macro, so ignore it. */
  if (ma_defining_macro && pu_tty_c >= 0) {
    ma_defining_macro = false;
    ms_message("Keyboard macro defined.");
    }
}

void ma_invoke(int mnumb)
{
  if (ma_defining_macro && mnumb == 0) {
    ms_error("You can't call a keyboard macro while defining it!");
    ma_delete(0);
    }
  else
    pu_push_back_buf(ma_text+ma_start[mnumb], ma_len[mnumb]);
}

void ma_delete(int mnumb)
{
  int i;

  if (ma_len[mnumb] > 0) {
    movc(ma_text+ma_start[mnumb]+ma_len[mnumb],
    	      ma_text+ma_start[mnumb],ma_next-ma_start[mnumb]-ma_len[mnumb]);
    ma_next = ma_next-ma_len[mnumb];
    for (i = 0; i < MAX_MACROS; i++) {
      if (ma_len[i] > 0 && ma_start[i] > ma_start[mnumb])
	ma_start[i] = ma_start[i]-ma_len[mnumb];
      }
    ma_len[mnumb] = 0;
    }
}

void ma_replace(int mnumb)
{
  if (ma_defining_macro) {
    ms_error("You can't rename a keyboard macro while defining it!");
    ma_delete(0);
    }
  else if (mnumb > 0) {
    ma_delete(mnumb);
    ma_start[mnumb] = ma_start[0];
    ma_len[mnumb] = ma_len[0];
    ma_len[0] = 0;
    }
}

/* assume bsize >= MAX_MACROS */
void ma_save_macros(char *buf, int *nc, int bsize)
{
  int mnumb;

  *nc = 0;
  for (mnumb = 0; mnumb < MAX_MACROS; mnumb++) {
    if (ma_len[mnumb] > 0)
      if (*nc + ma_len[mnumb] + (MAX_MACROS - mnumb) <= bsize) {
	movc(ma_text+ma_start[mnumb], buf + *nc, ma_len[mnumb]);
	*nc += ma_len[mnumb];
	}
    buf[*nc++] = -1;
    }
}

void ma_restore_macros(const char *buf, int nc)
{
  int i, mnumb;

  i = 0;
  ma_next = 0;
  for (mnumb = 0; mnumb < MAX_MACROS; mnumb++) {
    ma_start[mnumb] = ma_next;
    ma_len[mnumb] = 0;
    for ( ; i < nc; i++)
      if (buf[i] == -1) {
    	i++;
	break;
	}
      else if (ma_next < MACRO_SIZE) {
	ma_text[ma_next++] = buf[i];
	ma_len[mnumb] += 1;
	}
      else
	ma_len[mnumb] = 0;
    ma_next = ma_start[mnumb] + ma_len[mnumb];
    }
}

int q_ma_write_macros(const char *file)
{
  int mnumb, err;

  if (! q_fi_open_write(WRITE_UNIT, file, 'N', 0xFFFF))
    return false;
  for (mnumb = 0; mnumb < MAX_MACROS; mnumb++)
    if (! q_fi_put(WRITE_UNIT, ma_text+ma_start[mnumb], ma_len[mnumb], &err)) {
      q_fi_close(WRITE_UNIT);
      return false;
      }
  return q_fi_close(WRITE_UNIT);
}

int q_ma_read_macros(const char *file)
{
  int mnumb;
  file_info finfo;

  if (ma_defining_macro) {
    ms_error("You can't read macros while defining a macro!");
    ma_delete(0);
    return false;
    }
  if (! q_fi_open_read(READ_UNIT, file, &finfo))
    return false;
  ma_next = 0;
  for (mnumb = 0; mnumb < MAX_MACROS; mnumb++) {
    ma_start[mnumb] = ma_next;
    if (! q_fi_get(READ_UNIT,ma_text+ma_next,MACRO_SIZE-ma_next,ma_len+mnumb))
      ma_len[mnumb] = 0;
    else
      ma_next = ma_next + ma_len[mnumb];
    }
  return q_fi_close(READ_UNIT);
}
