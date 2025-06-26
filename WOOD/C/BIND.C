/*	Zilch Screen Editor
 *	Copyright (c) 1982,1983,1984,1986,1987 William P. Wood, Jr. */

#include "symbols.h"
#include "bind.cmn"
#include "tables.cmn"
#include "screen.cmn"

int bi_use_keymap(int mode)
{
  register int i;

  for (i = 0; i < NUM_MODES; ++i)
    if (bind.modes[i] == bind.mode)
      break;
  if (mode < 0 || mode >= NUM_MODES)
    goto L10;
  else if (bind.modes[mode] == null) {
L10:
    ms_report_number("Illegal mode: ", mode, "");
    ms_error("");
    }
  else
    bind.mode = bind.modes[mode];
  return i;
}

int bi_get_command(void)
{
  register int bi;
  register char c;
  int errmsglen, newerrmsglen;

  errmsglen = sc_new_length(sc_size);
  bi = bi_mem(ta_lower(get_tty_character()) + bind.mode);
  newerrmsglen = sc_new_length(sc_size);
  for ( ; bi > 0; bi = bi_mem(bi)) {
    sc_new_length(sc_size) = errmsglen;
    c = get_tty_character();
    while (bi_char(bi) != ta_lower(c) && bi_char(bi) != - c) {
      bi = bi_next(bi);
      if (bi == 0) {
	sc_new_length(sc_size) = newerrmsglen;
	return 0;
	}
      }
    }
  sc_new_length(sc_size) = newerrmsglen;
  return (-bi);
}

int bi_allocate(int n)
{
  register int i;

  if (bind.free + n - 1 > bind.bmax) {
    ms_error("Binding memory overflow!");
    return null;
    }
  else {
    for (i = bind.free; bind.free < i + n; )
      bi_mem(bind.free++) = null;
    return i;
    }
}

int bi_new(int k)
{
  register int bi;

  bi = bi_allocate(bi_sizeof);
  bi_next(bi) = 0;
  bi_char(bi) = ho_clower(k);
  bi_mem(bi) = 0;
  return bi;
}

int bi_make_bindings(int fnc, register const char *key)
{
  int bi, bitmp;

  bi = bitmp = bi_new(key[0]);
  for ( ; *++key != EOS; ) {
    bi_mem(bi) = bi_new(*key);
    bi = bi_mem(bi);
    }
  bi_mem(bi) = - fnc;
  return bitmp;
}

void bi_bind_to_key(int fnc, register const char *key)
{
  int bi, nxtchar, t;

  if (key[0] != EOS) {
    if (key[0] == bind.alternate_escape)
      if (key[1] != EOS)
	if (key[1] >= 0) {
	  bind.alternate_escape_followers[key[1]] = true;
	  bind.alternate_escape_followers[ho_clower(key[1])] = true;
	  }
	else
	  bind.alternate_escape_followers[- key[1]] = true;
    bi = ho_clower(*key++) + bind.mode;
    while (bi_mem(bi) > 0 && *key != EOS) {
      for (nxtchar = bi_mem(bi); nxtchar > 0; nxtchar = bi_next(nxtchar))
	if (bi_char(nxtchar) == ho_clower(*key)) {
	  bi = nxtchar;
	  goto L10;
	  }
      break;
L10:
      key++;
      }
    if (*key == EOS) {			/* found it */
      if (bi_mem(bi) <= 0)		/* don't overwrite longer binds */
	bi_mem(bi) = - fnc;
      }
    else {
      t = bi_make_bindings(fnc, key);
      bi_next(t) = max(0, bi_mem(bi));
      bi_mem(bi) = t;
      }
    }
}

int q_bi_in_mode(int mode)
{
  if (mode < 0 || mode >= NUM_MODES)
    return false;
  else if (bind.mode == bind.modes[mode])
    return true;
  else
    return false;
}
