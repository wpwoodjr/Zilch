/*	Zilch Screen Editor,
 *	Copyright (c) 1982,1986,1987 William P. Wood, Jr. */

#define DEBUG 0
#include "symbols.h"
#include "memory.cmn"
#include "screen.cmn"
#include "session.cmn"

static void ed_save_string(stringp s1, stringp *s2)
{
  st_deallocate(*s2);
  *s2 = st_allocate(st_length(s1) + 1);
  st_scopy(s1, *s2);
}

#define RS_WI_BOW 0
#define RS_WI_DOT 1
#define RS_WI_SIZE 2
#define RS_WI_MIN_SIZE 2
#define RS_IS_PA_CURRENT_WINDOW 3
#define RS_PA_NUMBER 4
#define RS_IS_SE_CURRENT_PAGE 5
#define RS_SC_SIZE 6
#define RS_SC_WIDTH 7
#define RS_IS_FILE 8
#define RS_BU_INDENT 9
#define RS_BU_MARK1 10
#define RS_BU_MARK2 11
#define RS_BU_SAVE_DOT 12
#define RS_BU_SAVE_BOW 13
#define RS_BU_CASE 14
#define RS_BU_TYPE 15
#define RS_SE_DEFAULT_CASE 16
#define RS_SE_INDENT 16
#define RS_FILE 17
#define RS_BUFFER_SIZE max(MACRO_SIZE+MAX_MACROS, \
    			   FILENAMESIZE + (CHARS_PER_INT*RS_FILE))
static void ed_restore_session(void)
{
  intp buf[RS_BUFFER_SIZE];
  int oldsiz, nc, np;
  pagep pa;
  bufferp bu;
  windowp wi;
  file_info finfo;

  if (se_restore != null)
    if (! q_fi_open_read(FIND_UNIT, st_buffer(se_restore), &finfo))
      co_error(st_buffer(se_restore),1,
      					"Can't open session restore file.");
    else {
      sc_size = SCREEN_SIZE;
      oldsiz = SCREEN_SIZE;
      if (get(FIND_UNIT, buf, RS_BUFFER_SIZE, &nc))    /* restore macros */
	ma_restore_macros((char *) buf, nc);
      if (get(FIND_UNIT, buf, RS_BUFFER_SIZE, &nc)) {  /* restore search string */
	se_search_length = nc;
	if (se_search_length > 0)
	  movc(buf,st_buffer(se_search_string),se_search_length);
	}
      np = 0;
      while (get(FIND_UNIT, buf, RS_BUFFER_SIZE, &nc)) { /* restore windows */
	if (buf[RS_PA_NUMBER] != np) {
	  np = buf[RS_PA_NUMBER];
	  pa = pa_new(np);
	  pa_switch(np);
	  }
	if (buf[RS_IS_FILE] != 0)		/* was a file? */
	  q_visit_file((char *)buf + RS_FILE, false, 1);
	else
	  q_pop_to_buffer(null, (char *)buf + RS_FILE);
	}
      if (! q_fi_rewind(FIND_UNIT))
	co_error("",1,"Error rewinding session restore file.");
      get(FIND_UNIT, buf, RS_BUFFER_SIZE, &nc);
      get(FIND_UNIT, buf, RS_BUFFER_SIZE, &nc);
      pa_map(se_pages,pa)
	wi_map(pa_windows(pa),wi) {
	  if (get(FIND_UNIT, buf, RS_BUFFER_SIZE, &nc)) {
	    bu = wi_buffer(wi);
	    mk_set_mark(bu_mark1_ptr(bu), buf[RS_BU_MARK1], bu);
	    mk_set_mark(bu_mark2_ptr(bu), buf[RS_BU_MARK2], bu);
	    mk_set_mark(bu_save_dot_ptr(bu), buf[RS_BU_SAVE_DOT], bu);
	    mk_set_mark(bu_save_bow_ptr(bu), buf[RS_BU_SAVE_BOW], bu);
	    bu_case(bu) = buf[RS_BU_CASE];
	    bu_type(bu) = buf[RS_BU_TYPE];
	    mp_set_mappings(bu,bu_type(bu));
	    bu_indent(bu) = buf[RS_BU_INDENT];
	    bu_bow(bu) = buf[RS_WI_BOW];
	    bu_dot(bu) = buf[RS_WI_DOT];
	    wi_bow(wi) = buf[RS_WI_BOW];
	    wi_dot(wi) = buf[RS_WI_DOT];
	    wi_size(wi) = buf[RS_WI_SIZE] & 0xffff;
	    wi_min_size(wi) = max(1,buf[RS_WI_MIN_SIZE]/0x10000);
	    if (buf[RS_IS_PA_CURRENT_WINDOW] == 1)
	      pa_current_window(pa) = wi;
	    if (buf[RS_IS_SE_CURRENT_PAGE] == 1)
	      se_current_page = pa;
	    if (buf[RS_IS_PA_CURRENT_WINDOW] == 1 &&
		buf[RS_IS_SE_CURRENT_PAGE] == 1)
	      se_current_window = wi;
	    sc_size = buf[RS_SC_SIZE];
	    sc_width = buf[RS_SC_WIDTH];
	    se_default_case = buf[RS_SE_DEFAULT_CASE] & 1;
	    se_indent = buf[RS_SE_INDENT]/2;
	    if (se_indent == 0)
	      se_indent = 2;
	    }
	  }
      if (oldsiz != sc_size) {			/* retreive the message line! */
	sc_fill_line(sc_size,sc_buffer[sc_new][oldsiz-1]+1,
						  sc_new_length(oldsiz));
	sc_reverse_video(sc_size,sc_new) = false;
	}
      if (! q_fi_close(FIND_UNIT))
	co_error("",1,"Error closing session restore file.");
      }
}

static void ed_init_file(const char *file)
{
  int nc, i;
  file_info finfo;
# include "pushb.cmn"

  if (q_fi_open_read(READ_UNIT, file, &finfo)) {
    while (get(READ_UNIT, file, MAX_COMMAND, &nc))
      for (i = 0; i < nc; )
	tx_insert_character(pu_buffer, file[i++], bu_size(pu_buffer) + 1);
    if (! q_fi_close(READ_UNIT))
      co_error("", 1, "Error closing initialization file.");
    }
  else
    co_error("", 1, "Can't read initialization file.");
}

static int q_ed_initialize(int argc, const char *argv[])
{
# include "spfiles.cmn"
  int i, ler, status, cl_width, nfiles;
  long int n;
  stringp st;
  const char *argp;
  static const char illlen[] = "Illegal screen length.",
		    illwid[] = "Illegal screen width.",
		    illter[] = "Illegal terminal type.",
		    illfil[] = "Illegal file name.",
		    illcas[] = "Case must be \"upper\" or \"lower\".",
		    illind[] = "Illegal indent.",
		    illword[] = "Illegal word definition.";

  status = false;
  ti_initialize();
  sc_initialize();
  cl_width = 0;		/* cl_width, the width returned from command line */
  te_initialize();
  se_initialize();
  pu_initialize();
  mp_initialize();
  ma_initialize();
  st = st_allocate(MAX_COMMAND);
  nfiles = 0;
  for (i = 1; i < argc; i++) {
    argp = argv[i];
    while (q_co_parse(&argp, st_buffer(st), false)) {
      ler = false;
      if (*st_buffer(st) == '/') {
	if (nfiles > 0)
	  co_error("", 1, "Switches may not appear on file names.");
	else if (q_co_matswi(st_buffer(st), "/INItialize='", &ler,
			illfil, &n, st_buffer(st), MAX_COMMAND))
	  ed_init_file(st_buffer(st));
	else if (q_co_matswi(st_buffer(st), "/Length=#", &ler,
			illlen, &n, st_buffer(st), MAX_COMMAND)) {
	  sc_size = n;
	  if (sc_size < 3 || sc_size > SCREEN_SIZE)
	    co_error("", 1, illlen);
	  }
	else if (q_co_matswi(st_buffer(st), "/Width=#", &ler,
			illwid, &n, st_buffer(st), MAX_COMMAND))
	  cl_width = n;
	else if (q_co_matswi(st_buffer(st), "/Terminal='", &ler,
			illter, &n, st_buffer(st), MAX_COMMAND)) {
	  if (! q_te_set_type(st_buffer(st)))
	    co_error(st_buffer(st), 1, illter);
	  }
	else if (q_co_matswi(st_buffer(st), "/Restore='", &ler,
			illfil, &n, st_buffer(st), MAX_COMMAND))
	  ed_save_string(st, &se_restore);
	else if (q_co_matswi(st_buffer(st), "/Save='", &ler,
			illfil, &n, st_buffer(st), MAX_COMMAND))
	  ed_save_string(st, &se_save);
	else if (q_co_matswi(st_buffer(st), "/Help='", &ler,
			illfil, &n, st_buffer(st), MAX_COMMAND))
	  ed_save_string(st, &sp_help);
	else if (q_co_matswi(st_buffer(st), "/RATMap='", &ler,
			illfil, &n, st_buffer(st), MAX_COMMAND))
	  ed_save_string(st, &sp_ratmap);
	else if (q_co_matswi(st_buffer(st), "/PASMap='", &ler,
			illfil, &n, st_buffer(st), MAX_COMMAND))
	  ed_save_string(st, &sp_pasmap);
	else if (q_co_matswi(st_buffer(st), "/FORMap='", &ler,
			illfil, &n, st_buffer(st), MAX_COMMAND))
	  ed_save_string(st, &sp_formap);
	else if (q_co_matswi(st_buffer(st), "/TEXTMap='", &ler,
			illfil, &n, st_buffer(st), MAX_COMMAND))
	  ed_save_string(st, &sp_textmap);
	else if (q_co_matswi(st_buffer(st), "/CMap='", &ler,
			illfil, &n, st_buffer(st), MAX_COMMAND))
	  ed_save_string(st, &sp_cmap);
	else if (q_co_matswi(st_buffer(st), "/CAse='", &ler,
			illcas, &n, st_buffer(st), MAX_COMMAND)) {
	  if (q_ho_equal(st_buffer(st), "lower"))
	    se_default_case = 0;
	  else if (q_ho_equal(st_buffer(st), "upper"))
	    se_default_case = 1;
	  else
	    co_error(st_buffer(st),1,illcas);
	  }
	else if (q_co_matswi(st_buffer(st), "/INDent=#", &ler,
			illind, &n, st_buffer(st), MAX_COMMAND))
	  se_indent = n;
	else if (q_co_matswi(st_buffer(st), "/CRoss_lines", &ler,
			"", &n, st_buffer(st), MAX_COMMAND))
	  se_cross_lines = true;
	else if (q_co_matswi(st_buffer(st), "/NOCRoss_lines", &ler,
			"", &n, st_buffer(st), MAX_COMMAND))
	  se_cross_lines = false;
	else if (q_co_matswi(st_buffer(st), "/WOrd='", &ler,
			illword, &n, st_buffer(st), MAX_COMMAND)) {
	  if (! q_se_define_word_class(st_buffer(st), 2))
	    co_error("", 1, "Too many word class definitions.");
	  }
	else if (q_co_matswi(st_buffer(st), "/MAcros='", &ler,
			illfil, &n, st_buffer(st), MAX_COMMAND)) {
	  ed_save_string(st, &se_macros);
	  if (! q_ma_read_macros(st_buffer(st)))
	    co_error(st_buffer(st), 1, "Can't open macro file.");
	  }
	else if (q_co_matswi(st_buffer(st), "/RECover", &ler,
			"", &n, st_buffer(st), MAX_COMMAND))
	  se_recover = true;
	else if (! ler)
	  co_error(st_buffer(st), 1, "Illegal switch.");
	}
      else {
	nfiles = nfiles+1;
	pr_add_to_recall(st_buffer(st));
	multi_visit_file(st_buffer(st),false,nfiles == 1);
	}
      }
    }

  if (se_macros == null) {
    ho_scopy("sys$login:zilch.macros", 1, st_buffer(st), 1);
    ed_save_string(st, &se_macros);
    if (nfiles != 0)
      if (! q_ma_read_macros(st_buffer(st)))
	;
    }
  if (nfiles == 0)
    ed_restore_session();
  else {
    se_current_window = se_windows;
    wi_equalize();
    }
  if (cl_width != 0)
    sc_width = cl_width;
  if (se_windows == null)
    if (nfiles > 0)
      co_error("", 1, "Bad file name.");
    else
      co_error("", 1, "No files on command line.");
  else if ((! q_te_set_length(sc_size)) || sc_size < 3)
    co_error("", 1, illlen);
  else if (! q_te_set_width(sc_width))
    co_error("", 1, illwid);
  else {
    status = true;
    ky_bind_keys();
    redraw();
    }
  st_deallocate(st);
  return status;
}

void ed_save_session(void)
{
  intp buf[RS_BUFFER_SIZE];
  pagep pa;
  windowp wi;
  bufferp bu;
  int nc, ier;
  static const char opener[] = "Can't open session save file!\15\12",
		    closer[] = "Error closing session save file!\15\12";

  if (se_save != null)
    if (! q_fi_open_write(WRITE_UNIT, st_buffer(se_save), 'U', 0xFFFF))
      ms_error(opener);
    else {
      ma_save_macros((char *)buf, &nc, RS_BUFFER_SIZE);
      put(WRITE_UNIT, buf, nc, &ier);
      put(WRITE_UNIT, st_buffer(se_search_string), se_search_length, &ier);
      pa_update;
      pa_map(se_pages, pa)
	if (pa_number(pa) >= 0)
	  wi_map (pa_windows(pa), wi) {
	    buf[RS_WI_BOW] = wi_bow(wi);
	    buf[RS_WI_DOT] = wi_dot(wi);
	    buf[RS_WI_SIZE] = wi_size(wi);
	    buf[RS_WI_MIN_SIZE] = buf[RS_WI_SIZE] | (0x10000*wi_min_size(wi));
	    if (wi == pa_current_window(pa))
	      buf[RS_IS_PA_CURRENT_WINDOW] = 1;
	    else
	      buf[RS_IS_PA_CURRENT_WINDOW] = 0;
	    buf[RS_PA_NUMBER] = pa_number(pa);
	    if (pa == se_current_page)
	      buf[RS_IS_SE_CURRENT_PAGE] = 1;
	    else
	      buf[RS_IS_SE_CURRENT_PAGE] = 0;
	    buf[RS_SC_SIZE] = sc_size;
	    buf[RS_SC_WIDTH] = sc_width;
	    buf[RS_SE_DEFAULT_CASE] = se_default_case | (se_indent*2);
	    bu = wi_buffer(wi);
	    buf[RS_BU_INDENT] = bu_indent(bu);
	    buf[RS_BU_MARK1] = bu_mark1(bu);
	    buf[RS_BU_MARK2] = bu_mark2(bu);
	    buf[RS_BU_SAVE_DOT] = bu_save_dot(bu);
	    buf[RS_BU_SAVE_BOW] = bu_save_bow(bu);
	    buf[RS_BU_CASE] = bu_case(bu);
	    buf[RS_BU_TYPE] = bu_type(bu);
	    if (bu_file_name(bu) == null) {
	      buf[RS_IS_FILE] = 0;
	      ho_scopy(st_buffer(bu_name(bu)), 1, (char *)buf + RS_FILE, 1);
	      }
	    else {
	      buf[RS_IS_FILE] = 1;
	      ho_scopy(st_buffer(bu_file_name(bu)),1,(char *)buf + RS_FILE,1);
	      }
	    put(WRITE_UNIT, buf, ho_length((char *)buf + RS_FILE) + 1 +
				      CHARS_PER_INT*RS_FILE, &ier);
	    }
      if (! q_fi_close(WRITE_UNIT))
	ms_error(closer);
      }
}

static int q_ed_finish(void)
{
  int aborted, status;
  bufferp bu;

  status = true;
  if (mod(bu_modified(se_current_buffer), 2) == 1)
    if (q_pr_ask("Save file [y]? ", true, &aborted)) {
      if (! q_fi_write_buffer(se_current_buffer))
	return false;
      }
    else if (aborted)
      return false;
  bu_map(se_buffers, bu)
    if (bu != se_current_buffer && mod(bu_modified(bu), 2) == 1 &&
	bu_file_name(bu) != null) {
      if (! q_pr_ask("Modified files exist; exit [n]? ", false, &aborted))
	status = false;
      break;
      }
  if (status) {
    ed_save_session();
    ms_message("");
    sc_update(&zero);
    te_finish();
    te_pos(sc_size, 1);
    ti_flush();
    ti_finish();
    dcl_finish();
    }
  return status;
}

void zilch(int argc, const char *argv[])
{
#if DEBUG
  timrb();
#endif
  if (q_ed_initialize(argc, argv))
    do {
      ky_edit();
      } while (! q_ed_finish());
#if DEBUG
  timre();
#endif
}
