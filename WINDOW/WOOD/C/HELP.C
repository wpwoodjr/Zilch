/*	Zilch Screen Editor,
 *	Copyright (c) 1982,1986,1987 William P. Wood, Jr. */

#include "symbols.h"
#include "memory.cmn"
#include "spfiles.cmn"
#include "session.cmn"

int q_he_help(void)
{
  static const char nohelp[] = "Can't read Help file!";

  if (sp_read_buffer("Help",&sp_help,nohelp) == null) {
    ms_error(nohelp);
    return false;
    }
  else {
    pa_switch(-1);
    q_switch_to_buffer(null, "Help");
    delete_other_windows();
    ms_message("Type carriage-return to exit Help.");
    return true;
    }
}
