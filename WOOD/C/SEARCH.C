/*	Zilch Screen Editor,
 *	Copyright (c) 1982,1986,1987 William P. Wood, Jr. */

#include "symbols.h"
#include "session.cmn"
#include "memory.cmn"

static void sr_compile(char *s, char *m, int len)
{
  int i;

  for (i = 0; i < len; i++) {
    if (s[i] >= 'A' && s[i] <= 'Z')
      s[i] += 040;			/* convert to lower case */
    if (s[i] >= 'a' && s[i] <= 'z')
      *m++ = 040;			/* mask converts text to lower */
    else
      *m++ = 0;
    }
}

int q_sr_get_search_string(const char *pr)
{
  stringp st;
  int len, status;

  st = st_allocate(MAX_PROMPT);
  status = q_pr_read_prompt(pr, st, &len);
  if (status)
    if (len == 0) {
      if (se_search_length == 0) {
	ms_error("No previous search string!");
	status = false;
	}
      }
    else {					/* new search string */
      movc(st_buffer(st), st_buffer(se_search_string), len);
      se_search_length = len;
      }
  st_deallocate(st);
  if (status)
    sr_compile(st_buffer(se_search_string), st_buffer(se_search_mask),
			  se_search_length);
  return status;
}

int q_search_forward(long int count)
{
  int status;

  status = q_sr_get_search_string("Search for: ");
  if (status)
    for ( ; count > 0; count--) {
      status = q_tx_search_forward(se_current_buffer,
		  wi_dot(se_current_window), bu_size(se_current_buffer),
		  st_buffer(se_search_string),
		  st_buffer(se_search_mask), se_search_length,
		  &wi_dot(se_current_window));
      if (! status) {
	ms_error("Can't find it!");
	break;
	}
      else
	wi_dot(se_current_window) = wi_dot(se_current_window)+se_search_length;
      }
  return status;
}

int q_search_reverse(long int count)
{
  int status;

  status = q_sr_get_search_string("Reverse search for: ");
  if (status)
    for ( ; count > 0; count = count - 1) {
      status = q_tx_search_reverse(se_current_buffer, 1,
		  wi_dot(se_current_window)-2,
		  st_buffer(se_search_string),
		  st_buffer(se_search_mask), se_search_length,
		  &wi_dot(se_current_window));
      if (! status) {
	ms_error("Can't find it!");
	break;
	}
      else
	wi_dot(se_current_window) = wi_dot(se_current_window)+se_search_length;
      }
  return status;
}

void sr_replace(const char *buf, int len)
{
  bufferp bu;
  int beg, i, upfirs, upall;

  upfirs = false;
  upall = false;
  bu = se_current_buffer;
  beg = wi_dot(se_current_window) - se_search_length;
  if (se_search_length > 0)
    if (q_ho_is_upper(tx_text(tx_address(bu, beg)))) {
      upfirs = true;
      if (se_search_length > 1)
	if (q_ho_is_upper(tx_text(tx_address(bu, beg+1))))
	  upall = true;
      }
  delete_region(wi_dot(se_current_window), beg);
  for (i = 0; i < len; i++)
    if (upall || (i == 0 && upfirs))
      insert_character(ho_cupper(buf[i]));
    else
      insert_character(buf[i]);
}

int q_sr_buffer_search_forward(bufferp bu,char *str,int len,textind from,textind to,textind *loc)
{
  int status;

  sr_compile(str, st_buffer(se_search_mask), len);
  status = q_tx_search_forward(bu, from, to, str,
  				st_buffer(se_search_mask), len, loc);
  return status;
}

int q_sr_buffer_search_reverse(bufferp bu,char *str,int len,textind from,textind to,textind *loc)
{
  int status;

  sr_compile(str, st_buffer(se_search_mask), len);
  status = q_tx_search_reverse(bu, from, to, str,
  				st_buffer(se_search_mask), len, loc);
  return status;
}
