#include <stdio.h>
#include "symbols.h"

zilch(int argc, const char *argv[])
{
  char arg[MAX_COMMAND] = "how-dee-doo";
  const char *argp;
  int ler, i;
  long int n;

  for (i = 0; i < argc; i++) {
    printf("argv[%d] = %s\n", i, argv[i]);
    argp = argv[i];
    while (q_co_parse(&argp, arg, false)) {
      printf("arg = %s, argv[%d] = %s\n", arg, i, argv[i]);
      ler = false;
      if (q_co_matswi(arg, "/INItialize='", &ler,
			"Bad file", &n, arg, MAX_COMMAND))
	printf("/INItialize=%s\n", arg);
      else if (q_co_matswi(arg, "/Length=#", &ler,
    			"Bad len", &n, arg, MAX_COMMAND))
	printf("/Length=%d\n", n);
      else if (q_co_matswi(arg, "/HELLO", &ler,
    			"Bad hello", &n, arg, MAX_COMMAND))
	printf("/Hello\n");
      else if (! ler)
	printf("GG: Unknown switch: %s\n", arg);
      }
    }
}
