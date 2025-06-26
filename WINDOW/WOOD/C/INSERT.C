/*	Zilch Screen Editor,
 *	Copyright (c) 1982,1987 William P. Wood, Jr. */

#include "symbols.h"
#include "session.cmn"
#include "insert.cmn"
#include "mappings.cmn"
#include "memory.cmn"

void in_enter(void)
{
  stringp st;
# include "terminal.cmn"

  in_cr = false;
  if (te_in)
    in_deol = false;
  else
    in_deol = true;
  st = st_allocate(st_length(wi_mode_line(se_current_window)) + 5);
  ho_scopy("<I> ", 1, st_buffer(st), 1);
  st_scopy(wi_mode_line(se_current_window), st+4);
  wi_mode_line(se_current_window) = st;
  wi_modified(se_current_window) = 1;
  in_reenter();
  bi_use_keymap(INSERT_MODE);
}

void in_reenter(void)
{
  int modif, i;
  textind tdot, col;

  modif = bu_modified(se_current_buffer);
  tdot = wi_dot(se_current_window);
  if (in_cr)
    for (i = 1; i <= wi_size(se_current_window); i++)
      insert_character(NEWLINE);
  else if (in_deol)
    delete_region_to_buffer("insert-tmp",tdot,
    					find_eol(se_current_buffer,tdot));
  else {
    col = current_column();
    insert_character(NEWLINE);
    tab_to_column(col);
    }
  in_nchars = wi_dot(se_current_window) - tdot;
  wi_dot(se_current_window) = tdot;
  bu_modified(se_current_buffer) = modif;
  sc_fill_new();
}

void in_exit(void)
{
  in_post_inserted_text();
  st_deallocate(wi_mode_line(se_current_window));
  wi_mode_line(se_current_window) = bu_name(se_current_buffer);
  wi_modified(se_current_window) = 1;
  bi_use_keymap(CONTROL_MODE);
}

void in_post_inserted_text(void)
{
  int modif;
  textind tdot;

  mp_mark = 0;
  modif = bu_modified(se_current_buffer);
  if (in_deol) {
    tdot = wi_dot(se_current_window);
    yank_buffer("insert-tmp");
    wi_dot(se_current_window) = tdot;
    }
  else if (in_nchars > 0)
    delete_region(wi_dot(se_current_window),
		  wi_dot(se_current_window) + in_nchars);
  bu_modified(se_current_buffer) = modif;
}

void in_escape(void)
{
  if (q_mp_empty())
    in_exit();
  else
    mp_pop();
}

void in_carriage_return(void)
{
# include "terminal.cmn"

  insert_character(NEWLINE);
  in_post_inserted_text();
  if (wi_size(se_current_window) > 1 && !(te_in || in_cr)) {
    in_cr = true;
    in_deol = false;
    }
  in_reenter();
}

void in_increase_indent(void)
{
  mp_beginning_of_line();
  if (! q_mp_at_comment()) {
    delete_white_space();
    set_indent(bu_indent(se_current_buffer) + se_indent);
    tab_to_column(bu_indent(se_current_buffer));
    }
  end_of_line();
}

void in_decrease_indent(void)
{
  mp_beginning_of_line();
  if (! q_mp_at_comment()) {
    delete_white_space();
    set_indent(bu_indent(se_current_buffer) - se_indent);
    tab_to_column(bu_indent(se_current_buffer));
    }
  end_of_line();
}

void in_self_insert(void)
{
# include "pushb.cmn"
# include "screen.cmn"
  char c;

  c = pu_last_key_struck;
  if (bu_case(se_current_buffer) == 1)
    if (c >= 'a' && c <= 'z')
      c = c - 040;
  if (wi_modified(se_current_window) == 0) {
    insert_character(c);
    wi_modified(se_current_window) = 0;
    sc_add_to_line(sc_cursor_y, &c, 1);
    }
  else
    insert_character(c);
}

void in_delete_previous_character(void)
{
# include "screen.cmn"
  register char c;

  if (wi_dot(se_current_window) > 1) {
    c = tx_text(tx_address(se_current_buffer, wi_dot(se_current_window) - 1));
    if (c == NEWLINE) {
      if (se_cross_lines)
	delete_previous_character();
      }
    else if (c >= ' ' && c <= '~') {
      if (wi_modified(se_current_window) == 0 &&
			      sc_new_length(sc_cursor_y) < sc_width) {
	delete_previous_character();
	wi_modified(se_current_window) = 0;
	sc_new_length(sc_cursor_y) = sc_new_length(sc_cursor_y) - 1;
	sc_modified(sc_cursor_y) = true;
	}
      else
	delete_previous_character();
      }
    else
      delete_previous_character();
    }
}
