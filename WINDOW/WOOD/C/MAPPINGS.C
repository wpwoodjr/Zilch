/*	Zilch Screen Editor,
 *	Copyright (c) 1982,1986,1987 William P. Wood, Jr. */

#include "symbols.h"
#include "spfiles.cmn"
#include "memory.cmn"
#include "mappings.cmn"
#include "session.cmn"

static int q_mp_get_first_word(textind *wb, textind *we)
{
  textind dot, end;

  dot = wi_dot(se_current_window);
  end = bu_size(se_current_buffer) + 1;
  beginning_of_line();
  wo_skip_non_word(end, 1, false, 1);
  *wb = wi_dot(se_current_window);
  wo_skip_word(end, 1, 1);
  *we = wi_dot(se_current_window);
  wi_dot(se_current_window) = dot;
  return *wb != *we;
}

static void mp_ratfiv_block(void)
{
  static const char s[] = "\t{\33\60\60\t}\33\60-";

  mp_mark = wi_dot(se_current_window);
  mp_save_indent = bu_indent(se_current_buffer);
  mp_push_character(END_OF_MAPPING);
  mp_push_string(s);
  mp_pop();
}

static void mp_pascal_block(void)
{
  textind wb, we;

  static const char s1[] = "\tbegin\33\60\60\tend (* ",
		    s2[] = " *);\33\60-",
		    s3[] = "\tbegin\33\60+\tend;\33-0";

  mp_mark = wi_dot(se_current_window);
  mp_save_indent = bu_indent(se_current_buffer);
  mp_push_character(END_OF_MAPPING);
  if (q_mp_get_first_word(&wb, &we)) {
    mp_push_string(s2);
    mp_push_region(se_current_buffer, wb, we);
    mp_push_string(s1);
    }
  else
    mp_push_string(s3);
  mp_pop();
}

static void mp_get_block(void)
{
  switch (bu_type(se_current_buffer)) {
    case RATFIV:
    case C:
      mp_ratfiv_block();
      break;
    case PASCAL:
      mp_pascal_block();
      break;
    default:
      ms_error("");
      break;
    }
}

static void mp_cancel(void)
{
  char c;

  if (mp_mark == 0)
    ms_error("Can't cancel mapping!");
  else {
    if (mp_mark > 0)
      for (mp_nextc(&c); c != END_OF_MAPPING; mp_nextc(&c))
	;
    else
      mp_mark = -mp_mark;
    if (wi_dot(se_current_window) > mp_mark)
      delete_region(wi_dot(se_current_window),mp_mark);
    mp_mark = 0;
    set_indent(mp_save_indent);
    }
}

static int q_mp_next_pascal_procedure(void)
{
  beginning_of_line();
  if (q_sr_buffer_search_forward(se_current_buffer, "(**", 3,
  				wi_dot(se_current_window),
  				bu_size(se_current_buffer),
  				&wi_dot(se_current_window))) {
    end_of_line();
    return true;
    }
  return false;
}

static int q_mp_previous_pascal_procedure(void)
{
  beginning_of_line();
  if (q_sr_buffer_search_reverse(se_current_buffer, "(**", 3,
				1,
  				wi_dot(se_current_window),
  				&wi_dot(se_current_window)))
    return true;
  return false;
}

static int q_mp_is_fortran_eop(void)
{
  textind loc;

  loc = wi_dot(se_current_window);
  mp_beginning_of_line();
  if (loc == wi_dot(se_current_window)) {
    wi_dot(se_current_window) = wi_dot(se_current_window) + 3;
    advance_over_white_space();
    if (q_eol())
      return true;
    else if (q_mp_at_comment())
      return true;
    }
  return false;
}

static int q_mp_next_fortran_procedure(void)
{
  beginning_of_line();
  while (q_sr_buffer_search_forward(se_current_buffer, "end", 3,
  				wi_dot(se_current_window),
  				bu_size(se_current_buffer),
  				&wi_dot(se_current_window))) {
    if (q_mp_is_fortran_eop()) {
      end_of_line();
      return true;
      }
    else
      next_line();
    }
  return false;
}

static int q_mp_previous_fortran_procedure(void)
{
  beginning_of_line();
  while (q_sr_buffer_search_reverse(se_current_buffer, "end", 3,
				1,
  				wi_dot(se_current_window),
  				&wi_dot(se_current_window))) {
    if (q_mp_is_fortran_eop())
      return true;
    else
      beginning_of_line();
    }
  return false;
}

static int q_mp_next_c_procedure(void)
{
  static char eop[] = "\n}";

  eop[0] = NEWLINE;
  beginning_of_line();
  if (q_sr_buffer_search_forward(se_current_buffer, eop, 2,
  				wi_dot(se_current_window),
  				bu_size(se_current_buffer),
  				&wi_dot(se_current_window))) {
    wi_dot(se_current_window) = wi_dot(se_current_window) + 2;
    end_of_line();
    return true;
    }
  return false;
}

static int q_mp_previous_c_procedure(void)
{
  static char eop[] = "\n}";

  eop[0] = NEWLINE;
  beginning_of_line();
  if (q_sr_buffer_search_reverse(se_current_buffer, eop, 2,
				1,
  				wi_dot(se_current_window),
  				&wi_dot(se_current_window)))
    return true;
  return false;
}

static int q_mp_next_paragraph(void)
{
  beginning_of_line();
  for ( ; ; ) {
    advance_over_white_space();
    if (q_eol())
      return true;
    next_line();
    }
}

static int q_mp_previous_paragraph(void)
{
  beginning_of_line();
  while (wi_dot(se_current_window) > 1) {
    advance_over_white_space();
    if (q_eol()) {
      do {
	previous_line();
	advance_over_white_space();
	} while (q_eol() && wi_dot(se_current_window) != 1);
      return true;
      }
    previous_line();
    }
  return false;
}

static bufferp mp_mappings(int typ)
{
  bufferp mappings;

  switch (typ) {
    case FORTRAN:
      mappings = sp_read_buffer("formap", &sp_formap,
				    "Can't read Fortran mapping file!");
      break;
    case RATFIV:
      mappings = sp_read_buffer("ratmap", &sp_ratmap,
				    "Can't read Ratfiv mapping file!");
      break;
    case PASCAL:
      mappings = sp_read_buffer("pasmap", &sp_pasmap,
				    "Can't read Pascal mapping file!");
      break;
    case C:
      mappings = sp_read_buffer("cmap", &sp_cmap,
				    "Can't read C mapping file!");
      break;
    case TEXT:
      mappings = sp_read_buffer("textmap", &sp_textmap,
				    "Can't read Text mapping file!");
      break;
    default:
      mappings = null;
      break;
    }
  return mappings;
}

void mp_initialize(void)
{
  if (mp_stack == null) {
    mp_stack = bu_find_by_name("mapping stack");
    if (mp_stack == null)
      mp_stack = bu_new("mapping stack", "");
    }
  mp_mark = 0;
}

void mp_get_mapping(void)
{
  bufferp bu, maping;
  textind loc, col;
  static char search[] = "\12 ";

  bu = se_current_buffer;
  search[1] = get_tty_character();
  switch (search[1]) {
    case RUBOUT:
      mp_cancel();
      break;
    case '[':
      mp_get_block();
      break;
    default:
      if (bu_mappings(bu) == null)
	bu_mappings(bu) = mp_mappings(bu_type(bu));
      maping = bu_mappings(bu);
      if (maping != null) {
	if (q_sr_buffer_search_forward(maping,search,2,1,
      					bu_size(maping),&loc)) {
	  mp_mark = wi_dot(se_current_window);
	  mp_save_indent = bu_indent(bu);
	  mp_push_character(END_OF_MAPPING);
	  mp_push_region(maping, loc+2, find_eol(maping, loc+2));
	  if (search[1] == '{') {		/* comment mapping */
	    switch (bu_type(bu)) {
	      case FORTRAN:
	      case RATFIV:
		col = 49;
	      default:
		col = 41;
	      }
	    if (current_column() >= col)
	      insert_character(' ');
	    else
	      tab_to_column(col);
	    }
	  mp_pop();
	  }
	else
	  insert_character(search[1]);
	}
      else
	insert_character(search[1]);
      break;
    }
}

void mp_pop(void)
{
  bufferp bu;
  char c;

  bu = se_current_buffer;
  mp_nextc(&c);
  if (c == INDENT_FOLLOWS) {
    mp_nextc(&c);
    set_indent((textind) c);
    mp_nextc(&c);
    }
  while (c != END_OF_MAPPING && c != 033) {
    if (c == TAB)
      if (current_column() <= bu_indent(bu))
	tab_to_column(bu_indent(bu));
      else
	insert_character(' ');
    else if (c == CR)
      in_carriage_return();
    else if (c == '\\') {
      mp_nextc(&c);
      if (c == END_OF_MAPPING)
	break;
      insert_character(c);
      }
    else if (c == MP_PROMPT) {
      stringp st = st_allocate(MAX_PROMPT);
      int i = 0;
      for (mp_nextc(&c); c != END_OF_MAPPING && c != MP_PROMPT;
						mp_nextc(&c))
	if (i < MAX_PROMPT)
	  *st_buffer(st + i++) = c;
      ms_message3("", st, i, i+1);
      st_deallocate(st);
      }
    else if (bu_case(bu) == 1)
      if (bu_type(bu) == RATFIV && (c == '{' || c == '}'))
	insert_character(c - 040);
      else
	insert_character(ho_cupper(c));
    else
      insert_character(c);
    mp_nextc(&c);
    }
  if (c == 033) {
    mp_nextc(&c);
    if (c == '+')
      in_increase_indent();
    else if (c == '-')
      in_decrease_indent();
    mp_nextc(&c);
    if (c == '+')
      set_indent(bu_indent(bu) + se_indent);
    else if (c == '-')
      set_indent(bu_indent(bu) - se_indent);
    mp_nextc(&c);
    if (c != END_OF_MAPPING) {
      mp_push_character(c);
      mp_push_character(bu_indent(bu));
      mp_push_character(INDENT_FOLLOWS);
      }
    }
  if (c == END_OF_MAPPING)
    if (mp_mark <= 0)
      mp_mark = 0;
    else
      mp_mark = -mp_mark;
}

void mp_set_mappings(bufferp bu, int type)
{
  char ftype[4];
  int i, j;

  if (type == 0) {
    i = ho_indexq(st_buffer(bu_name(bu)), '.');
    if (i == 0)
      ftype[0] = EOS;
    else
      for (i--, j = 0; j < 4; j++) {
	ftype[j] = *st_buffer(bu_name(bu)+i+j);
	if (ftype[j] == EOS)
	  break;
	else if (ftype[j] == ';' || ftype[j] == '<') {
	  ftype[j] = EOS;
	  break;
	  }
	}
    if (q_ho_equal(ftype, ".for") || q_ho_equal(ftype, ".ftn"))
      type = FORTRAN;
    else if (q_ho_equal(ftype, ".rat"))
      type = RATFIV;
    else if (q_ho_equal(ftype, ".pas"))
      type = PASCAL;
    else if (q_ho_equal(ftype, ".c") || q_ho_equal(ftype, ".cpp") ||
		q_ho_equal(ftype, ".cp"))
      type = C;
    else
      type = TEXT;
    }
  bu_type(bu) = type;
  bu_indent(bu) = (type == FORTRAN ? 9 : 1);
  bu_mappings(bu) = null;
}

int mp_minimum_indent(bufferp bu)
{
  return bu_type(bu) == FORTRAN ? 7 : 1;
}

void mp_change_mappings(void)
{
  int type, len;
  stringp st;

  type = 0;
  st = st_allocate(MAX_PROMPT);
  if (q_pr_read_prompt("Mapping type (Pascal, Fortran, Ratfiv, C, Text)? ",
			st, &len)) {
    if (q_ho_equal(st_buffer(st),"fortran"))
      type = FORTRAN;
    else if (q_ho_equal(st_buffer(st),"pascal"))
      type = PASCAL;
    else if (q_ho_equal(st_buffer(st),"ratfiv"))
      type = RATFIV;
    else if (q_ho_equal(st_buffer(st),"c"))
      type = C;
    else if (q_ho_equal(st_buffer(st),"text"))
      type = TEXT;
    else {
      ms_message2("Illegal mapping type: ",st);
      ms_error("");
      }
    if (type != 0) {
      mp_set_mappings(se_current_buffer, type);
      ms_message2("Mapping type is now ", st);
      }
    }
  st_deallocate(st);
}

int q_mp_empty(void)
{
  return bu_size(mp_stack) == 0;
}

void mp_next_procedure(void)
{
  int found;

  beginning_of_line();
  while (wi_dot(se_current_window) > 1) {
    advance_over_white_space();
    if (! q_eol())
      break;
    previous_line();
    }
  switch (bu_type(se_current_buffer)) {
    case RATFIV:
    case FORTRAN:
      found = q_mp_next_fortran_procedure();
      break;
    case PASCAL:
      found = q_mp_next_pascal_procedure();
      break;
    case C:
      found = q_mp_next_c_procedure();
      break;
    default:
      found = q_mp_next_paragraph();
      break;
    }
  if (found) {
    while (wi_dot(se_current_window) <= bu_size(se_current_buffer) && q_eol()) {
      wi_dot(se_current_window) = wi_dot(se_current_window) + 1;
      advance_over_white_space();
      }
    beginning_of_line();
    }
  else
    end_of_file();
  line_to_top_of_window();
}

void mp_previous_procedure(void)
{
  textind dot;
  int found, n, i;

  dot = wi_dot(se_current_window);
  n = 1;
  do {
    for (i = 1; i <= n; i++)
      switch (bu_type(se_current_buffer)) {
	case RATFIV:
	case FORTRAN:
	  found = q_mp_previous_fortran_procedure();
	  break;
	case PASCAL:
	  found = q_mp_previous_pascal_procedure();
	  break;
	case C:
	  found = q_mp_previous_c_procedure();
	  break;
	default:
	  found = q_mp_previous_paragraph();
	  break;
	}
    if (found)
      mp_next_procedure();
    else
      beginning_of_file();
    n = n + 1;
    } while(wi_dot(se_current_window) != 1 && wi_dot(se_current_window) >= dot);
}

int q_mp_at_comment(void)
{
  textind tx, cc;
  bufferp bu;
  int status;
  char c, c2;

  status = false;
  tx = wi_dot(se_current_window);
  bu = se_current_buffer;
  if (tx <= bu_size(bu)) {
    c = tx_text(tx_address(bu,tx));
    switch (bu_type(bu)) {
      case FORTRAN:
	cc = current_column();
	if (cc > 72 || c == '!' || (cc == 1 && (ho_clower(c) == 'c' || c == '*')))
	  status = true;
	break;
      case RATFIV:
	if (c == '#')
	  status = true;
	break;
      case PASCAL:
	if (c == '{' || c == '}')
	  status = true;
	else if (tx + 1 <= bu_size(bu)) {
	  c2 = tx_text(tx_address(bu,tx+1));
	  if ((c == '(' && c2 == '*') || (c == '*' && c2 == ')'))
	    status = true;
	  }
	break;
      case C:
	if (tx + 1 <= bu_size(bu)) {
	  c2 = tx_text(tx_address(bu,tx+1));
	  if ((c == '/' && c2 == '*') ||
	      (c=='*' && (c2=='/' || c2==' ' || c2==TAB || c2==NEWLINE)) ||
	      (c == '/' && c2 == '/'))		/* for C++ */
	    status = true;
	  }
	break;
      case TEXT:
	if (c == '!')
	  status = true;
	break;
      }
    }
  return status;
}

void mp_beginning_of_line(void)
{
  textind tx;
  bufferp bu;
  char c;

  beginning_of_line();
  bu = se_current_buffer;
  tx = wi_dot(se_current_window);
  switch (bu_type(bu)) {
    case FORTRAN:
      if (! q_mp_at_comment()) {
	goto_column(6);
	tx = wi_dot(se_current_window);
	if (tx <= bu_size(bu)) {
	  c = tx_text(tx_address(bu,tx));
	  if (c != ' ' && c != TAB && c != NEWLINE && current_column() == 6)
	    tx = tx+1;
	  else {
	    advance_over_white_space();
	    tx = wi_dot(se_current_window);
	    if (current_column() == 9 && tx <= bu_size(bu)) {
	      c = tx_text(tx_address(bu,tx));
	      if (c >= '1' && c <= '9')
		tx = tx + 1;
	      }
	    }
	  }
	}
      break;
    case RATFIV:
      for ( ; tx <= bu_size(bu); tx = tx+1) {
	c = tx_text(tx_address(bu,tx));
	if (c < '0' || c > '9')
	  break;
	}
      break;
    case TEXT:
      if (tx <= bu_size(bu))
	if (tx_text(tx_address(bu,tx)) == '$')	/* for DCL command files */
	  tx = tx+1;
      break;
    }
  wi_dot(se_current_window) = tx;
  advance_over_white_space();
}

int q_mp_read_file(bufferp bu, const char *name, textind dot, int setpro)
{
  return q_fi_read_file(bu, name, dot, setpro);
}

int q_mp_write_file(bufferp bu, const char *name, int type, int *stat)
{
  int status;

  status = q_fi_write_region(bu, name, 1, bu_size(bu), type, stat);
  if (status) {
    bu_modified(bu) = 0;
    ms_message("Wrote ");
    ms_add_to_message(name);
    if (type == 'N')		/* NEW file - not writing checkpoint file */
      ch_delete(bu);
    }
  return status;
}
