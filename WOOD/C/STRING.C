/*	Zilch Screen Editor
 *	Copyright (c) 1982,1987 William P. Wood, Jr. */

#include "symbols.h"
#include "memory.cmn"

stringp st_allocate(int size)
{
  return CHARS_PER_INT*me_allocate((size - 1)/CHARS_PER_INT + 1);
}

void st_deallocate(stringp ptr)
{
  me_deallocate(ptr/CHARS_PER_INT);
}

void st_display(stringp st)
{
  send_message_to_terminal(st_buffer(st));
}

void st_scopy(stringp s1, stringp s2)
{
  ho_scopy(st_buffer(s1), 1, st_buffer(s2), 1);
}

int st_length(stringp st)
{
  return ho_length(st_buffer(st));
}
