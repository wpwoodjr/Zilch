#define _tolower(c)	((c) >= 'A' && (c) <= 'Z' ? (c) | 0x20:(c))
#include <stdio.h>
#include "symbols.h"
#include "tables.cmn"

main(int argc, const char *argv[])
{
	int i;

  for(i = -128; i < 128; i++)
	  if (ho_clower(i) != _tolower(i))
		  printf("1: %d, %d, %d\n", i,  ho_clower(i), _tolower(i));
  for(i = -128; i < 128; i++)
	  if (ta_clower(i) != _tolower(i))
		  printf("2: %d, %d, %d\n", i,  ho_clower(i), _tolower(i));
  for(i = -128; i < 128; i++)
	  if (ta_lower(i) != _tolower(max(0, i)))
		  printf("3: %d, %d, %d\n", i,  ho_clower(i), _tolower(i));
}

int tclower(int c)
{
return ta_clower(c);
}
int tlower(int c)
{
return ta_lower(c);
}
