/*	Zilch Screen Editor,
 *	Copyright (c) 1982,1986,1987 William P. Wood, Jr. */

#include "symbols.h"
#include "session.cmn"

void se_initialize(void)
{
  se_pages = null;
  se_current_page = pa_new(0);
  se_buffers = null;
  se_current_window = null;
  se_save = null;
  se_restore = null;
  se_macros = null;
  se_command_count = 0;
  se_count = 0;
  se_search_string = st_allocate(MAX_PROMPT);
  se_search_mask = st_allocate(MAX_PROMPT);
  se_search_length = 0;
  se_error_occurred = false;
  se_interrupt_enabled = false;
  se_in_prompt = false;
  se_cross_lines = false;
  se_recover = false;
  se_default_case = 0;				/* lower/upper case */
  se_indent = 2;

/* define default classes; also note that Q_MP_GET_FIRST_WORD uses class 1,
 * SO DON'T MESS WITH CLASS 1 (class 1 is "A-Za-z~0-9"). */

  q_se_define_word_class("A-Za-z~0-9,0-9~.A-Za-z,)", 1);

/* if you need to change the default class definitions, add a second call
 * which starts defining at class 2, for example:
 *
 *	q_se_define_word_class("A-Z,0-9", 2)
 *
 * defines two classes, uppercase A through Z and 0-9.
 * This way Q_MP_GET_FIRST_WORD will still be able to use class 1, but classes 2
 * and above will be used for the user's word searches.
 */
}

/* Q_SE_DEFINE_WORD_CLASS defines the meaning of a "word" for word movement
 * commands. There may be up to MAX_WORD_CLASS definitions of what a word means.
 * There are two routines that scan over words, called WO_SKIP_WORD and
 * WO_SKIP_NON_WORD.  They each take as an argument what word class to use.
 * These routines are both called by the user-level routines NEXT_WORD and
 * PREVIOUS_WORD.  They work by first scanning over characters that aren't
 * in any class, then determining a class to use based on the character
 * which stopped the scan, then scanning over characters in that class.
 * Class 0 is special.  It contains, for each character, the number of the
 * class that the character is in, and 0 if the character is not in a class.
 * In fact, a character may be in more than one class, but it's PRIMARY
 * class is the one indicated by Class 0;  when NEXT_WORD and PREVIOUS_WORD
 * check what class a character is in, they check Class 0.  If a character
 * is in a class that is not it's primary class, then it cannot be used
 * to start a scan in that class, but once a scan is started, it will be
 * scanned over.  It is possible for a character to have a secondary class
 * but not a primary class, in which case it can participate in scans but
 * never start one, since its primary class is class 0.
 * For example, the following class definitions scan over numbers and words:
 *
 *	A-Za-z~0-9,0-9~.A-Za-z
 *
 * The first class definition is "A-Za-z~0-9".  That means that A through Z and
 * little a through little z are primary class members, while 0-9 are secondary
 * class members. The ~ (tilde) separates the primary and secondary class
 * members.  This class scans over words beginning with A-Z or a-z until
 * encountering a character which is not A-Z, a-z, or 0-9.
 * The second class definition is "0-9~.A-Za-z".  It is separated from the
 * first class definition by a comma.  This class scans over numbers
 * beginning with 0-9 until encountering a character which is not a period,
 * A-Z, or a-z.  Note that period is not a primary member in either class,
 * but is a secondary member of the second class.  This means that it cannot
 * start a scan, but can be scanned over if the number starts with 0-9.
 */
int q_se_define_word_class(const char *list, int start_class)
{
  int j, lastc, c, class, do_range, secondary_class;

  for (j = -128; j <= 127; j++)			/* initialize Class 0 */
    se_word_definition(j, 0) = 0;		/* no primary class to start */
  for (class = start_class; class <= MAX_WORD_CLASS; class++) {
    for (j = -128; j <= 127; j++)
      se_word_definition(j, class) = 0;	  /* no chars in this class yet */
    do_range = -1;		/* first time through - ignore leading " */
    secondary_class = false;	/* first define primary class members */
    for ( ; ; list++) {
      switch (*list) {
	case EOS:				/* done */
	  goto L20;
	case ',':				/* new class starting... */
	  list++;
	  goto L10;
	case '"':
	  if (list[1] == '"') {
	    list++;
	    c = '"';
	    break;
	    }
	  else
	    continue;			/* ignore isolated double quotes */
	case '-':			/* range, eg. A-Z */
	  if (do_range != 0)
	    c = *list;
	  else
	    do_range = 1;
	  break;
	case '~':			/* Now define secondary chars */
	  secondary_class = true;
	  break;
	case '^':			/* control character */
	  c = ho_cupper(* ++list) - 0100;
	  break;
	case '\\':			/* literal or octal number */
	  list++;
	  if (*list >= '0' && *list <= '9') {
	    c = 0;
	    do {
	      c = c*8 + (c - '0');
	      list++;
	      } while (*list >= '0' && *list <= '9');
	    list--;
	    }
	  else if (*list == 'n' || *list == 'N')
	    c = NEWLINE;
	  else if (*list == 't' || *list == 'T')
	    c = TAB;
	  else
	    c = *list;
	  break;
	default:				/* add to class */
	  c = *list;
	  break;
	}
      switch (do_range) {
	case -1:
	case  0:
	  do_range = 0;
	  lastc = c;
	  se_word_definition(c, class) = class;
	  if (! secondary_class)
	    se_word_definition(c, 0) = class;
	  break;
	case 1:
	  do_range = 2;
	  break;
	case 2:
	  do_range = 0;
	  for (j = lastc; j <= c; j++) {
	    se_word_definition(j, class) = class;
	    if (! secondary_class)
	      se_word_definition(j, 0) = class;
	    }
	  lastc = c;
	  break;
	}
      }
L10:
    ;
    }
L20:
  if (class > MAX_WORD_CLASS)
    return false;
  return true;
}
