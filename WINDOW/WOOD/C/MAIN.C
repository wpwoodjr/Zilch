/*	Zilch Screen Editor,
 *	Copyright (c) 1987 William P. Wood, Jr. */

#include "symbols.h"

int main(int argc, const char *argv[])
{
#if VMS
/*
 *	We can't use C command line processing because it deletes any
 *	quotation marks in the command line, which may be needed for DECNET
 *	file names.
 */
# include "descr.h"
  char cline[MAX_COMMAND];
  vms_char_descr(d_cline, cline, MAX_COMMAND-1);
  const char *clinep[] = { argv[0], cline };
  short int len;

  if ((lib$get_foreign(&d_cline, 0, &len) & 1) == 1) {
    len = max(0, len);
    cline[len] = EOS;
    }
  else {
    len = 0;
    cline[0] = EOS;
    }

  zilch(2, clinep);

#else

  zilch(argc, argv);

#endif

  return EXIT_GOOD;
}
