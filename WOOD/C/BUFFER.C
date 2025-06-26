/*	Zilch Screen Editor,
 *	Copyright (c) 1982,1983,1984,1986,1987 William P. Wood, Jr. */

#include "symbols.h"
#include "memory.cmn"
#include "session.cmn"

int q_switch_to_buffer(register bufferp bu, const char *na)
{
  windowp wicur;
  register windowp wi, wi2;

  if (bu == null)
    bu = bu_find_by_name(na);
  if (bu == null)
    bu = bu_new(na,"");
  wi_switch_to_buffer(se_current_window, bu);
  wi_map(se_windows,wi) /* try to find another window onto bu to set dot from */
    if (wi != se_current_window && wi_parent_buffer(wi) == bu_parent(bu)) {
      wicur = wi_parent(se_current_window);
      wi_map_sub_windows(wi, wi2) {
	wi_dot(wicur) = wi_dot(wi2);
	wi_set_bow(wicur,wi_bow(wi2));
	if (wi2 == wi)
	  se_current_window = wicur;
	wicur = wi_sub_windows(wicur);
	}
      break;
      }
  return true;
}

int q_pop_to_buffer(bufferp bu, const char *na)
{
  if (q_pop_up_window())
    return q_switch_to_buffer(bu, na);
  ms_error("Can't make a new window!");
  return false;
}

int q_visit_file(const char *na, int switch_buffer, int nf)
{
  register bufferp bu;

  bu = bu_find_by_file_name(na);
  if (bu == null) {
    bu = bu_new("",na);
    if (se_recover)
      q_ch_recover(bu);
    }
  if (switch_buffer)
    return q_switch_to_buffer(bu, st_buffer(bu_name(bu)));
  else if (nf == 1)
    if (q_pop_up_window())
      return q_switch_to_buffer(bu, st_buffer(bu_name(bu)));
  pa_generate(pa_number(se_current_page));
  if (q_split_current_window())
    return q_switch_to_buffer(bu, st_buffer(bu_name(bu)));
  return false;
}

void multi_visit_file(const char *na, int switch_buffer, int clear_context)
{
  register stringp st, st1, fi;
  pagep pa;
  int totfiles, nfile, n;

  fi = st_allocate(FILENAMESIZE);
  st = st_allocate(max(MAX_COMMAND,MAX_PROMPT));
  st1 = st_allocate(max(MAX_COMMAND,MAX_PROMPT));
  pa = se_current_page;
  totfiles = 0;
  while (q_co_parse(na, st_buffer(st1), false)) {
    nfile = 0;
    while (q_co_parse(st_buffer(st1), st_buffer(st), true)) {
      n = 0;
      if (q_fi_find_file(FIND_UNIT,st_buffer(st),st_buffer(fi),n,true,
				totfiles == 0 && clear_context)) {
	do {
	  nfile = nfile + 1;
	  totfiles = totfiles + 1;
	  q_visit_file(st_buffer(fi), switch_buffer && totfiles == 1, nfile);
	  } while (q_fi_find_file(FIND_UNIT, st_buffer(st), st_buffer(fi), n,
					true, false));
	}
      else
	ms_error("Bad file name encountered!");
      }
    if (se_current_page != pa) {
      ms_message("Some files windowed on succeeding pages.");
      pa_switch(pa_number(pa));
      }
    }
  st_deallocate(fi);
  st_deallocate(st);
  st_deallocate(st1);
}

void bu_ready(register bufferp bu)
{
  register bufferp bu2;

  if (bu_modified(bu) == 2) {
    if (! q_mp_read_file(bu,st_buffer(bu_file_name(bu)),0,true))
      ms_message2("New file: ",bu_file_name(bu));
    bu_modified(bu) = 0;
    }
  bu_map_sub_buffers(bu, bu2)
    if (bu_gap(bu2) == null)
      tx_more_memory_please(bu2, 0);
}

int q_bu_find_window(const char *na)
{
  register bufferp bu;
  register windowp wi;

  bu = bu_find_by_name(na);
  if (bu == null)
    return q_pop_to_buffer(null, na);
  wi_map(se_windows, wi)
    if (wi_buffer(wi) == bu) {
      while (wi != se_current_window)
	next_window();
      return true;
      }
  return q_pop_to_buffer(bu, na);
}

int q_bu_pop_up_message(register const char *msg, int mlen, const char *na)
{
  int all_blank, size, nlines;
  register int i;
  register windowp wi;
  bufferp bu;

  wi = se_current_window;
  size = wi_size(wi);
  if (! q_pop_up_window())
    return false;
  wi_size(wi) = max(1, size - 2);
  wi_size(se_current_window) = 1;
  bu = bu_new(na, "");
  if (q_switch_to_buffer(bu, st_buffer(bu_name(bu)))) {
    all_blank = true;
    nlines = 1;
    for (i = 0; i < mlen; ++i) {
      if (msg[i] == CR)
	if (i < mlen-1) {
	  if (msg[i+1] == LF)
	    continue;
	  }
	else {
	  insert_character(NEWLINE);
	  continue;
	  }
      if (msg[i] == LF) {
	insert_character(NEWLINE);
	if (i < mlen-1 && ! all_blank)
	  nlines = nlines + 1;
	}
      else {
	if (all_blank) {
	  line_to_top_of_window();
	  all_blank = false;
	  }
	insert_character(msg[i]);
	}
      }
    wi_dot(se_current_window) = wi_bow(se_current_window);
    bu_modified(se_current_buffer) = 0;
    size = wi_size(wi);
    wi_size(wi) = max(1, wi_size(wi) - nlines + 1);
    wi_size(se_current_window) = wi_size(se_current_window) +
							size - wi_size(wi);
    wi_fill();
    while (wi != se_current_window)
      next_window();
    return true;
    }
  else
    return false;
}

bufferp bu_find_by_file_name(const char *na)
{
  register bufferp bu;

  bu_map(se_buffers,bu)
    if (bu_file_name(bu) != null)
      if (q_ho_equal(st_buffer(bu_file_name(bu)), na))
	return bu;
  return null;
}

bufferp bu_find_by_name(const char *na)
{
  register bufferp bu;

  bu_map(se_buffers,bu)
    if (bu_name(bu) != null)
      if (q_ho_equal(st_buffer(bu_name(bu)), na))
	return bu;
  return null;
}

bufferp bu_new(const char *name, const char *fname)
{
  register bufferp bu;
  static bufferp bu_last_buffer = null;

  bu = me_allocate(bu_sizeof);
  bu_parent(bu) = bu;
  bu_next(bu) = null;
  bu_sub_buffers(bu) = null;
  bu_name(bu) = null;
  bu_file_name(bu) = null;
  if (fname[0] != EOS)
    bu_modified(bu) = 2;			/* file, not read in yet */
  else
    bu_modified(bu) = 0;
  bu_type(bu) = 0;
  bu_mappings(bu) = null;
  bu_protection(bu) = -1;
  bu_indent(bu) = 1;
  bu_case(bu) = se_default_case;
  bu_windows(bu) = null;
  bu_size(bu) = 0;
  bu_base(bu) = null - 1;
  bu_gap(bu) = null;
  bu_gap_size(bu) = 0;
  bu_dot(bu) = 1;
  bu_bow(bu) = 1;
  bu_save_dot_ptr(bu) = mk_new(1);
  bu_save_bow_ptr(bu) = mk_new(1);
  bu_mark1_ptr(bu) = mk_new(0);
  bu_mark2_ptr(bu) = mk_new(0);
  bu_markers(bu) = null;
  bu_id(bu) = 0;
  bu_current(bu) = 1;
  if (name[0] != EOS || fname[0] != EOS) {	/* if not a sub-buffer... */
    if (bu_last_buffer == null)
      se_buffers = bu;
    else
      bu_next(bu_last_buffer) = bu;
    bu_last_buffer = bu;
    bu_new_names(bu, name, fname);
    }
  return bu;
}

bufferp bu_new_sub_buffer(bufferp parent, int id)
{
  register bufferp bu;

  bu = bu_new("", "");
  bu_parent(bu) = parent;
  bu_id(bu) = id;
  bu_current(bu) = 0;
  return bu;
}

/* Should deallocate unused space! */
bufferp bu_delete_sub_buffer(register bufferp bu)
{
  return bu_sub_buffers(bu);
}

void bu_new_names(register bufferp bu, const char *name, const char *fname)
{
  register windowp wi;
  char num[14];
  stringp old, st, st2;
  int sl, n, nl;

  old = bu_name(bu);
  bu_name(bu) = null;
  st_deallocate(bu_file_name(bu));
  if (name[0] != EOS) {
    st = st_allocate(ho_length(name)+1);
    ho_scopy(name, 1, st_buffer(st), 1);
    for (st2 = st; *st_buffer(st2) != EOS; st2++)
      *st_buffer(st2) = ho_clower(*st_buffer(st2));
    }
  else
    st = bu_make_name(fname);
  if (fname[0] != EOS) {
    bu_file_name(bu) = st_allocate(ho_length(fname)+1);
    ho_scopy(fname, 1, st_buffer(bu_file_name(bu)), 1);
    }
  else
    bu_file_name(bu) = null;
  sl = st_length(st);
  for (n = 2; bu_find_by_name(st_buffer(st)) != null; n++) {
    nl = ho_itoc(n, num + 1, 12);
    num[0] = '<';
    num[1+nl] = '>';
    num[2+nl] = EOS;
    st2 = st_allocate(3+nl+sl);
    st_scopy(st, st2);
    ho_scopy(num, 1, st_buffer(st2+sl), 1);
    st_deallocate(st);
    st = st2;
    }
  bu_name(bu) = st;
  if (old != null) {				/* update old pointers */
    bu_map_windows(bu, wi)
      if (wi_mode_line(wi) == old) {
	wi_mode_line(wi) = bu_name(bu);
	wi_modified(wi) = 1;
	}
    st_deallocate(old);
    }
  mp_set_mappings(bu, 0);
}

bufferp bu_make_name(const char *file)
{
  register int i, j, k;
  bufferp bu;

  i = 0;
  for (j = ho_nuqcp(file, 1); file[j-1] != EOS; j = ho_nuqcp(file, j+1))
    if (file[j-1] == ']' || file[j-1] == '>' || file[j-1] == ':')
      i = j;
  bu = st_allocate(j - i);
  i = i + 1;
  for (k = i; k <= j; k++)
    *st_buffer(bu + k - i) = file[k-1];
  return bu;
}

void bu_clear_text(register bufferp bu)
{
  register bufferp sb;
  textind save_dot, save_bow;

  bu_map_sub_buffers(bu, sb) {
    if (bu_modified(sb) != 2) {		/* don't mess with "unread file" buffers */
      save_dot = bu_save_dot(sb);	/* so that restores work properly */
      save_bow = bu_save_bow(sb);
      tx_delete(sb, 1, bu_size(sb));
      mk_set_mark(bu_mark1_ptr(sb), 0, sb);
      mk_set_mark(bu_mark2_ptr(sb), 0, sb);
      mk_set_mark(bu_save_dot_ptr(sb), save_dot, sb);
      mk_set_mark(bu_save_bow_ptr(sb), save_bow, sb);
      bu_dot(sb) = 1;
      bu_bow(sb) = 1;
      if (sb == bu)
	bu_current(sb) = 1;
      else
	bu_current(sb) = 0;
      }
    }
  if (mod(bu_modified(bu), 2) == 1)
    bu_modified(bu) = 0;
}

#include "screen.cmn"
int q_buffer_list(void)
{
  int flen, nlen, curcol, do_files;
  static const char head[] = "  Name\t\t\tSize    Page    Filename\n\n";
  char num[9];
  pagep pacurrent;
  register bufferp bu, bu2;

  pacurrent = se_current_page;
  pa_switch(-1);
  q_switch_to_buffer(null, "Buffer list");
  delete_other_windows();
  pa_update;
  bu_clear_text(se_current_buffer);
  mp_set_mappings(se_current_buffer, TEXT);
  insert_string(head);
  do_files = true;
  do {
    bu_map(se_buffers,bu) {
      if (do_files ^ (bu_file_name(bu) == null)) { /* do files, then buffers */
	bu_map_sub_buffers(bu,bu2) {
	  if (bu2 == bu_parent(bu)) {
	    if (bu_parent(bu2) != bu_parent(se_current_buffer) &&
		  mod(bu_modified(bu2),2) == 1)
	      insert_string("M ");
	    else
	      insert_string("  ");
	    curcol = 3;
	    if (bu_name(bu2) != null) {
	      insert_string(st_buffer(bu_name(bu2)));
	      curcol = curcol + ho_length(st_buffer(bu_name(bu2)));
	      }
	    }
	  else
	    curcol = 1;
	  if (bu2 == se_current_buffer || bu_modified(bu2) == 2) {
	    nlen = 0;
	    num[0] = EOS;
	    }
	  else
	    nlen = ho_itoc(bu_size(bu2),num,9);
	  if (curcol + 1 + nlen > 29)
	    insert_character(NEWLINE);
	  tab_to_column(29 - nlen);
	  insert_string(num);
	  if (bu2 == bu_parent(bu)) {
	    bu_list_page(bu2,pacurrent);
	    if (bu_file_name(bu2) != null) {
	      flen = st_length(bu_file_name(bu2));
	      if (41 + flen > sc_width) {
		insert_character(NEWLINE);
		tab_to_column(max(5, ((int)(sc_width - flen - 1)/8)*8 + 1));
		}
	      else
		tab_to_column(41);
	      insert_string(st_buffer(bu_file_name(bu2)));
	      }
	    }
	  insert_character(NEWLINE);
	  }
	}
      }
    do_files = ! do_files;
    } while (! do_files);			/* do files, then buffers */
  wi_dot(se_current_window) = 1;
  bu_modified(se_current_buffer) = 0;
  ms_message("Type carriage-return to exit Buffer list.");
  return true;
}

void bu_list_page(register bufferp bu, pagep pacurrent)
{
  register pagep pa;
  register windowp wi;
  char num[9];

  pa = pacurrent;
  wi_map(pa_windows(pa),wi)
    if (wi_parent_buffer(wi) == bu_parent(bu))
      goto L10;
  pa_map(se_pages, pa)
    if (pa != pacurrent)
      wi_map(pa_windows(pa), wi)
	if (wi_parent_buffer(wi) == bu_parent(bu))
	  goto L10;
  return;
L10:
  ho_itocrj(pa_number(pa),num,9);
  insert_string(num);
  if (wi == pa_current_window(pacurrent))
    insert_character('*');
}

void bu_switch_case(void)
{
  bu_case(se_current_buffer) = 1 - bu_case(se_current_buffer);
  if (bu_case(se_current_buffer) == 1)
    ms_message("Buffer is now in upper case mode.");
  else
    ms_message("Buffer is now in lower/upper case mode.");
}
