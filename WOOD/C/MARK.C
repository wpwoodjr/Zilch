/* Zilch Screen Editor,
 * Copyright (c) 1982,1983,1984,1986,1987 William P. Wood, Jr. */

#include "symbols.h"
#include "session.cmn"
#include "memory.cmn"

void case_change(void)
{
  register bufferp bu;
  register textind m1, m2;

  bu = se_current_buffer;
  if (bu_mark1(bu) != 0 && bu_mark2(bu) != 0) {
    m1 = min(bu_mark1(bu), bu_size(bu)+1);
    m2 = min(bu_mark2(bu), bu_size(bu)+1);
    tx_case_change(bu, min(m1, m2), max(m1, m2) - 1);
    }
  else
    ms_error("Both marks must be set!");
}

void save_text(void)
{
  register bufferp bu;
  register textind m1, m2;

  bu = se_current_buffer;
  if (bu_mark1(bu) != 0 && bu_mark2(bu) != 0) {
    m1 = min(bu_mark1(bu), bu_size(bu)+1);
    m2 = min(bu_mark2(bu), bu_size(bu)+1);
    if (q_copy_region_to_buffer("Save", m1, m2))
      ms_report_number2("Saved ", abs(m1 - m2),
	  " character.", " characters.");
    }
  else
    ms_error("Both marks must be set!");
}

void extract_text(void)
{
  register bufferp bu;
  register textind m1, m2;

  bu = se_current_buffer;
  if (bu_mark1(bu) != 0 && bu_mark2(bu) != 0) {
    m1 = min(bu_mark1(bu), bu_size(bu)+1);
    m2 = min(bu_mark2(bu), bu_size(bu)+1);
    delete_region_to_buffer("Save", m1, m2);
    ms_report_number2("Extracted ", abs(m1 - m2),
						" character.", " characters.");
    mk_set_mark(bu_mark1_ptr(bu), 0, bu);
    mk_set_mark(bu_mark2_ptr(bu), 0, bu);
    }
  else
    ms_error("Both marks must be set!");
}

void delete_text(void)
{
  register bufferp bu;
  register textind m1, m2;

  bu = se_current_buffer;
  if (bu_mark1(bu) != 0 && bu_mark2(bu) != 0) {
    m1 = min(bu_mark1(bu), bu_size(bu)+1);
    m2 = min(bu_mark2(bu), bu_size(bu)+1);
    delete_region(m1, m2);
    ms_report_number2("Deleted ", abs(m1 - m2),
						" character.", " characters.");
    mk_set_mark(bu_mark1_ptr(bu), 0, bu);
    mk_set_mark(bu_mark2_ptr(bu), 0, bu);
    }
  else
    ms_error("Both marks must be set!");
}

void add_text_after_cursor(void)
{
  register bufferp bu;

  bu = se_current_buffer;
  mk_set_mark(bu_mark1_ptr(bu), wi_dot(se_current_window), bu);
  yank_buffer("Save");
  mk_set_mark(bu_mark2_ptr(bu), wi_dot(se_current_window), bu);
  wi_dot(se_current_window) = bu_mark1(bu);
}

void add_text_before_cursor(void)
{
  register bufferp bu;

  bu = se_current_buffer;
  mk_set_mark(bu_mark1_ptr(bu), wi_dot(se_current_window), bu);
  yank_buffer("Save");
  mk_set_mark(bu_mark2_ptr(bu), wi_dot(se_current_window), bu);
}

void save_location(void)
{
  register bufferp bu;

  bu = se_current_buffer;
  mk_set_mark(bu_save_dot_ptr(bu), wi_dot(se_current_window), bu);
  mk_set_mark(bu_save_bow_ptr(bu), wi_bow(se_current_window), bu);
  ms_message("Current location saved.");
}

void exchange_dot_and_save_location(void)
{
  register bufferp bu;

  bu = se_current_buffer;
  wi_dot(se_current_window) = min(bu_size(bu)+1,
    mk_set_mark(bu_save_dot_ptr(bu), wi_dot(se_current_window), bu));
  wi_set_bow(se_current_window, find_bol(bu,
    mk_set_mark(bu_save_bow_ptr(bu), wi_bow(se_current_window), bu)));
}

void goto_save_location(void)
{
  register bufferp bu;

  bu = se_current_buffer;
  wi_dot(se_current_window) = min(bu_size(bu)+1, bu_save_dot(bu));
  wi_set_bow(se_current_window, find_bol(bu,bu_save_bow(bu)));
}

void write_text(void)
{
  register bufferp bu;
  stringp st;
  register textind m1, m2;
  int len, stat;

  bu = se_current_buffer;
  if (bu_mark1(bu) != 0 && bu_mark2(bu) != 0) {
    st = st_allocate(MAX_PROMPT);
    if (q_pr_read_prompt(
  "Where to print (eg. HQ:FILE.OUT, or RETURN for local printer): ",st,&len)) {
      m1 = min(bu_mark1(bu), bu_size(bu)+1);
      m2 = min(bu_mark2(bu), bu_size(bu)+1);
      if (len == 0) {
	ho_scopy("SYS$COMMAND", 1, st_buffer(st), 1);
	te_printer_on();
	ti_flush();
	se_interrupt_enabled = true;  /* allow printer output to be aborted */
	}
      if (q_fi_write_region(bu, st_buffer(st), min(m1, m2), max(m1, m2)-1,
								'N', &stat)) {
	if (len > 0) {
	  ms_message("Wrote ");
	  ms_add_to_message(st_buffer(st));
	  }
	}
      else {
	ms_message2("Can't write ",st);
	ms_error("");
	}
      if (len == 0) {
	se_interrupt_enabled = false;
	te_printer_off();
	ti_flush();
	redraw();
	}
      }
    st_deallocate(st);
    }
  else
    ms_error("Both marks must be set!");
}

markp mk_new(textind mark)
{
  register markp mk;

  mk = me_allocate(mk_sizeof);
  mk_next(mk) = null;
  mk_mark(mk) = mark;
  return mk;
}

markp mk_link(register markp mk, register bufferp bu)
{
  register markp mk2;

  mk_map(bu_markers(bu), mk2)
    if (mk2 == mk)
      return mk;
  mk_next(mk) = bu_markers(bu);
  bu_markers(bu) = mk;
  return mk;
}

markp mk_unlink(register markp mk, register bufferp bu)
{
  register markp mk2, prev;

  prev = null;
  mk_map(bu_markers(bu), mk2)
    if (mk2 == mk) {
      if (prev == null)
	bu_markers(bu) = mk_next(mk);
      else
	mk_next(prev) = mk_next(mk);
      break;
      }
    else
      prev = mk2;
  mk_next(mk) = null;
  return mk;
}

/* If a mark is 0 or 1, it needn't be in the buffer's list of marks
 * because its value can't change.  This routine sets a mark, and unlinks
 * or links it into the buffer's mark list depending on the new mark value
 */
textind mk_set_mark(register markp mk, textind mark, register bufferp bu)
{
  textind savemark;

  savemark = mk_mark(mk);
  mk_mark(mk) = mark;
  if (mark > 1)
    mk_link(mk, bu);
  else
    mk_unlink(mk, bu);
  return savemark;
}
