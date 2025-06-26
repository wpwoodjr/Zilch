/*	Zilch Screen Editor,
 *	Copyright (c) 1982,1986 William P. Wood, Jr. */

#include "symbols.h"
#include "session.cmn"
#include "memory.cmn"

/* this subroutine relies on the extra NEWLINES hidden at the end of each buffer */
void next_word(void)
{
  textind end;
  int class;

  end = bu_size(se_current_buffer) + 1;
  wo_skip_non_word(end,1,se_cross_lines,0);
  class = se_word_definition(
	tx_text(tx_address(se_current_buffer, wi_dot(se_current_window))), 0);
  wo_skip_word(end,1,class);
}

/* this subroutine relies on the extra NEWLINES hidden at the end of each buffer */
void previous_word(void)
{
  int class;

  if (wi_dot(se_current_window) > 1) {
    previous_character();
    wo_skip_non_word(0,-1,se_cross_lines,0);
    class = se_word_definition(
	tx_text(tx_address(se_current_buffer, wi_dot(se_current_window))), 0);
    wo_skip_word(0,-1,class);
    next_character();
    }
}

/* this subroutine relies on the extra NEWLINES hidden at the end of each buffer */
void wo_skip_non_word(int end, int inc, int cross, int class)
{
  register char c;
  register textind tx;
  register bufferp bu;

  bu = se_current_buffer;
  for (tx = wi_dot(se_current_window); tx != end; tx = tx+inc) {
    c = tx_text(tx_address(bu, tx));
    if (se_word_definition(c, class) != 0)
      break;
    else if (c == NEWLINE && ! cross)
      break;
    }
  wi_dot(se_current_window) = tx;
}

/* this subroutine relies on the extra NEWLINES hidden at the end of each buffer */
void wo_skip_word(int end, int inc, int class)
{
  register textind tx;
  register bufferp bu;

  bu = se_current_buffer;
  for (tx = wi_dot(se_current_window); tx != end; tx = tx+inc)
    if (se_word_definition(tx_text(tx_address(bu, tx)), class) == 0)
      break;
  wi_dot(se_current_window) = tx;
}
