/*	Zilch Screen Editor,
 *	Copyright (c) 1982,1983,1984,1987 William P. Wood, Jr. */

#include "symbols.h"
#include "session.cmn"
#include "memory.cmn"

static void backup_lines(int n)
{
  textind dot;
  int i;

  for (i = 1; i <= n; i++)
    previous_line();
  if (! q_dot_is_visible()) {
    dot = wi_dot(se_current_window);
    wi_dot(se_current_window) = wi_bow(se_current_window);
    for (i = 1; i <= n; i++)
      previous_line();
    line_to_top_of_window();
    wi_dot(se_current_window) = dot;
    }
}

void next_character(void)
{
  wi_dot(se_current_window) = min(wi_dot(se_current_window)+1,
				bu_size(se_current_buffer)+1);
}

void previous_character(void)
{
  wi_dot(se_current_window) = max(wi_dot(se_current_window)-1,1);
}

void next_line(void)
{
  bufferp bu;

  bu = se_current_buffer;
  wi_dot(se_current_window) = min(find_eol(bu,wi_dot(se_current_window)),
    							bu_size(bu))+1;
}

void scroll_next_line(void)
{
  next_line();
  if (! q_dot_is_visible())
    scroll_one_line_up();
}

void scroll_next_line_col(textind hug)
{
  if (hug == 0) {
    if (q_eol())
      hug = MAXINT;
    else
      hug = current_column();
    }
  scroll_next_line();
  goto_column(hug);
}

void previous_line(void)
{
  bufferp bu;

  bu = se_current_buffer;
  wi_dot(se_current_window) =
		find_bol(bu,max(1,find_bol(bu,wi_dot(se_current_window)) - 1));
}

void scroll_previous_line(void)
{
  previous_line();
  if (! q_dot_is_visible())
    scroll_one_line_down();
}

void scroll_previous_line_col(textind hug)
{
  if (hug == 0) {
    if (q_eol())
      hug = MAXINT;
    else
      hug = current_column();
    }
  scroll_previous_line();
  goto_column(hug);
}

void scroll_one_line_up(void)
{
  textind t;

  t = wi_dot(se_current_window);
  wi_dot(se_current_window) = wi_bow(se_current_window);
  next_line();
  wi_set_bow(se_current_window,find_bol(se_current_buffer,
						wi_dot(se_current_window)));
  wi_dot(se_current_window) = t;
}

void scroll_one_line_down(void)
{
  textind t;

  t = wi_dot(se_current_window);
  wi_dot(se_current_window) = wi_bow(se_current_window);
  previous_line();
  wi_set_bow(se_current_window,wi_dot(se_current_window));
  wi_dot(se_current_window) = t;
}

void next_half_screen(void)
{
  textind dot;
  int n, i;

  n = (wi_size(se_current_window) + 1)/2;
  for (i = 1; i <= n; i++)
    next_line();
  if (! q_dot_is_visible()) {
    dot = wi_dot(se_current_window);
    wi_dot(se_current_window) = wi_bow(se_current_window);
    for (i = 1; i <= n; i++)
      next_line();
    line_to_top_of_window();
    wi_dot(se_current_window) = dot;
    }
}

void previous_half_screen(void)
{
  backup_lines((wi_size(se_current_window) + 1)/2);
}

void previous_screen(void)
{
  backup_lines(wi_size(se_current_window)-1);
}

void next_screen(void)
{
  textind t;
  int i;

  t = wi_dot(se_current_window);
  beginning_of_line();
  if (wi_dot(se_current_window) == wi_bow(se_current_window))
    for (i = 1; i < wi_size(se_current_window); i++)
      next_line();
  else
    wi_dot(se_current_window) = t;
  line_to_top_of_window();
}

textind find_bol(bufferp bu, textind loc)
{
  textind tx;

  for (tx = min(loc-1, bu_size(bu)); tx > 0; tx = tx-1)
    if (tx_text(tx_address(bu, tx)) == NEWLINE)
      break;
  return tx+1;
}

void beginning_of_line(void)
{
  wi_dot(se_current_window) =
  			find_bol(se_current_buffer,wi_dot(se_current_window));
}

textind find_eol(bufferp bu, textind loc)
{
  textp tx;

  tx = bu_base(bu) + loc;
  tx_find_newline(tx, bu_gap(bu), bu_gap_size(bu), &tx_text(0));
  return tx - 1 - bu_base(bu);
}

void end_of_line(void)
{
  wi_dot(se_current_window) =
  			find_eol(se_current_buffer,wi_dot(se_current_window));
}

void ends_of_line(void)
{
  if (q_bol())
    end_of_line();
  else
    beginning_of_line();
}

void line_to_top_of_window(void)
{
  textind dot;

  dot = wi_dot(se_current_window);
  beginning_of_line();
  wi_set_bow(se_current_window, wi_dot(se_current_window));
  wi_dot(se_current_window) = dot;
}

int q_bol(void)
{
  if (wi_dot(se_current_window) == 1)
    return true;
  if (tx_text(tx_address(se_current_buffer,
			  wi_dot(se_current_window)-1)) == NEWLINE)
    return true;
  return false;
}

/* this subroutine relies on the extra NEWLINES hidden at the end of each buffer */
int q_eol(void)
{
  return tx_text(tx_address(se_current_buffer,
			  wi_dot(se_current_window))) == NEWLINE;
}

void beginning_of_file(void)
{
  wi_dot(se_current_window) = 1;
  line_to_top_of_window();
}

void goto_last_lines_of_file(void)
{
  int i;

  end_of_file();
  previous_character();
  beginning_of_line();
  for (i = 1; i < wi_size(se_current_window); i++)
    previous_line();
  line_to_top_of_window();
}

void goto_end_of_file(void)
{
  int i;

  end_of_file();
  for (i = 1; i < wi_size(se_current_window); i++)
    previous_line();
  line_to_top_of_window();
  end_of_file();
}

void end_of_file(void)
{
  wi_dot(se_current_window) = bu_size(se_current_buffer) + 1;
}

void insert_character(int c)
{
  tx_insert_character(se_current_buffer, c, wi_dot(se_current_window));
  wi_dot(se_current_window) = wi_dot(se_current_window) + 1;
}

void insert_string(const char *buf)
{
  int len;

  len = ho_length(buf);
  tx_insert_buffer(se_current_buffer, wi_dot(se_current_window), buf, len);
  wi_dot(se_current_window) = wi_dot(se_current_window) + len;
}

void delete_previous_character(void)
{
  if (wi_dot(se_current_window) > 1)
    tx_delete(se_current_buffer,wi_dot(se_current_window)-1,
		wi_dot(se_current_window)-1);
}

void delete_next_character(void)
{
  if (wi_dot(se_current_window) <= bu_size(se_current_buffer))
    tx_delete(se_current_buffer,wi_dot(se_current_window),
		wi_dot(se_current_window));
}

void kill_to_beginning_of_line(void)
{
  textind t;

  t = wi_dot(se_current_window);
  beginning_of_line();
  delete_region_to_buffer("kill", t, wi_dot(se_current_window));
}

void kill_through_end_of_line(void)
{
  textind t;

  t = wi_dot(se_current_window);
  if (t > bu_size(se_current_buffer))
    ms_error("You're at the end of the buffer.");
  else {
    end_of_line();
    delete_region_to_buffer("kill", t,
	      min(wi_dot(se_current_window)+1, bu_size(se_current_buffer)+1));
    }
}

void kill_to_end_of_line(void)
{
  textind t;

  t = wi_dot(se_current_window);
  if (t > bu_size(se_current_buffer))
    ms_error("You're at the end of the buffer.");
  else {
    end_of_line();
    delete_region_to_buffer("kill", t, wi_dot(se_current_window));
    }
}

void yank_kill(void)
{
  textind t;

  t = wi_dot(se_current_window);
  yank_buffer("kill");
  wi_dot(se_current_window) = t;
}

int q_dot_is_visible(void)
{
  return q_sc_dot_is_visible(se_current_window, se_current_buffer);
}

/* this subroutine relies on the extra NEWLINES hidden at the end of each buffer */
int find_next_character(void)
{
  return tx_text(tx_address(se_current_buffer,wi_dot(se_current_window)));
}
