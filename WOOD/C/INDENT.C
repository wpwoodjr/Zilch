/*	Zilch Screen Editor,
 *	Copyright (c) 1982,1986,1987 William P. Wood, Jr. */

#include "symbols.h"
#include "memory.cmn"
#include "session.cmn"

void advance_over_white_space(void)
{
  char c;
  bufferp bu;
  textind tx;

  bu = se_current_buffer;
  for (tx = wi_dot(se_current_window); tx <= bu_size(bu); tx++) {
    c = tx_text(tx_address(bu,tx));
    if (c != ' ' && c != TAB)
      break;
    }
  wi_dot(se_current_window) = tx;
}

void delete_white_space(void)
{
  char c;
  bufferp bu;
  textind tx;

  bu = se_current_buffer;
  advance_over_white_space();
  for (tx = wi_dot(se_current_window) - 1; tx > 0; tx--) {
    c = tx_text(tx_address(bu,tx));
    if (c == ' ' || c == TAB)
      delete_previous_character();
    else
      break;
    }
}

void do_indent(textind n)
{
  mp_beginning_of_line();
  if (! q_mp_at_comment()) {
    set_indent(current_column() + n);
    delete_white_space();
    if (! q_eol())
      tab_to_column(bu_indent(se_current_buffer));
    }
  next_line();
}

textind current_indent(void)
{
  textind t, indent;

  t = wi_dot(se_current_window);
  mp_beginning_of_line();
  indent = current_column();
  wi_dot(se_current_window) = t;
  return indent;
}

textind current_column(void)
{
  bufferp bu;
  textind tx, t, col;

  t = wi_dot(se_current_window);
  beginning_of_line();
  bu = se_current_buffer;
  col = 0;
  for (tx = wi_dot(se_current_window); tx < t; tx++)
    if (tx_text(tx_address(bu,tx)) == TAB)
      col += 8-mod(col,8);
    else
      col++;
  wi_dot(se_current_window) = t;
  return col + 1;
}

void goto_column(textind n)
{
  bufferp bu;
  textind tx, col;
  char c;

  beginning_of_line();
  bu = se_current_buffer;
  col = 0;
  for (tx = wi_dot(se_current_window); tx <= bu_size(bu) && col+1 < n; tx++) {
    c = tx_text(tx_address(bu,tx));
    if (c == TAB)
      col += 8-mod(col,8);
    else if (c == NEWLINE)
      break;
    else
      col++;
    }
  wi_dot(se_current_window) = tx;
}

void set_indent(textind n)
{
  bu_indent(se_current_buffer) = max(mp_minimum_indent(se_current_buffer), n);
}

void tab_to_column(textind n)
{
  textind i, tabcol;

  for (i = current_column(); i < n; i++) {
    tabcol = i-1+8-mod(i-1,8);
    if (tabcol < n) {
      i = tabcol;
      insert_character(TAB);
      }
    else
      insert_character(' ');
    }
}
