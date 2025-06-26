/*	Zilch Screen Editor,
 *	Copyright (c) 1982,1986,1987 William P. Wood, Jr. */

#include "symbols.h"
#include "session.cmn"
#include "memory.cmn"
#include "screen.cmn"

void ms_message(const char *mess)
{
  ms_message2(mess, null);
}

void ms_message3(const char *mess, stringp st, int stlen, textind dot)
{
  char c;
  int i, j, len, ichar;

  if (! se_error_occurred) {
    len = ho_length(mess);
    sc_fill_line(sc_size, mess, len);
    sc_cursor_x = len + 1;
    if (st != null) {
      for (i = 0; i < stlen; ) {
	c = *st_buffer(st + i++);
	if (c >= ' ' && c <= '~') {
	  len++;
	  sc_add_to_line(sc_size,&c,1);
	  }
	else if (c == TAB) {
	  for (j = len + 8 - mod(len, 8); len < j; len++)
	    sc_add_to_line(sc_size," ",1);
	  }
	else if (c >= 0 && c <= 037) {
	  len += 2;
	  sc_add_to_line(sc_size,"^",1);
	  c |= 0100;
	  sc_add_to_line(sc_size,&c,1);
	  }
	else {
	  len += 4;
	  sc_add_to_line(sc_size,"\\",1);
	  ichar = c;
	  c = '0' + (ichar & 0300)/0100;
	  sc_add_to_line(sc_size,&c,1);
	  c = '0' + (ichar & 070)/010;
	  sc_add_to_line(sc_size,&c,1);
	  c = '0' + (ichar & 07);
	  sc_add_to_line(sc_size,&c,1);
	  }
	if (dot == i)
	  sc_cursor_x = len + 1;
	}
      }
    sc_cursor_x = min(sc_width, sc_cursor_x);
    }
}

void ms_message2(const char *mess, stringp st)
{
  if (! se_error_occurred) {
    sc_fill_line(sc_size, mess, ho_length(mess));
    if (st != null)
      sc_add_to_line(sc_size, st_buffer(st), st_length(st));
    sc_cursor_x = min(sc_width, sc_new_length(sc_size)+1);
    }
}

void ms_user_message(char *msg, int len)
{
  int i;

  for (i = 0; i < len; i++)
    if (msg[i] == '%') {
      if (i + 4 < MAX_PROMPT) {
	ho_itocrj((100*(wi_dot(se_current_window)-1))/ _
			    max(1, bu_size(se_current_buffer)), msg + i, 4);
	msg[i + 3] = '%';
	if (i + 4 > len)
	  msg[i + 4] = EOS;
	}
      break;
      }
  if (msg[0] == '!')
    ms_error(msg + 1);
  else
    ms_message(msg);
}

void ms_add_to_message(const char *mess)
{
  if (! se_error_occurred) {
    sc_add_to_line(sc_size, mess, ho_length(mess));
    sc_cursor_x = min(sc_width, sc_new_length(sc_size)+1);
    }
}

void ms_error(const char *mess)
{
  int len;

  if (! se_error_occurred) {
    len = ho_length(mess);
    if (len > 0) {
      sc_fill_line(sc_size, mess, len);
      sc_cursor_x = min(sc_width, sc_new_length(sc_size)+1);
      }
    }
  sc_error_occurred = se_error_occurred = true;
}

void ms_report_number(const char *s1, long int n, const char *s2)
{
  char num[15];

  if (! se_error_occurred) {
    ms_message2(s1, null);
    ho_itoc(n, num, 15);
    ms_add_to_message(num);
    ms_add_to_message(s2);
    }
}

void ms_report_number2(const char *s1,long int n,const char *ss,const char *sp)
{
  if (n == 1)
    ms_report_number(s1, n, ss);
  else
    ms_report_number(s1, n, sp);
}
