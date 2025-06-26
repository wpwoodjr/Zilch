/*	Zilch Screen Editor,
 *	Copyright (c) 1982,1987 William P. Wood, Jr. */

#include <stdlib.h>
#include "symbols.h"
#include "memory.cmn"

intp me_allocate(int size)
{
  register intp ptr;
  register intp *mptr;

  mptr = malloc(size*CHARS_PER_INT);
  if (mptr != NULL) {
    if ((intp) mptr % CHARS_PER_INT != 0 || (intp) memory.me_memory %
							CHARS_PER_INT != 0) {
      printf("mptr or memory.me_memory not on intp boundary in me_allocate!\n");
      exit(EXIT_BAD);
      }
    ptr = ((intp) mptr - (intp) memory.me_memory)/CHARS_PER_INT;
    return ptr;
    }
  else {
    ti_kill();
    te_clear();
    te_finish();
    te_pos(1,1);
    send_message_to_terminal(
"Dynamic memory overflow! All modified file buffers are being checkpointed...");
    ti_finish();
    dcl_finish();
    checkpoint_modified_files();
    exit(EXIT_BAD);
    return null;
    }
}

void me_deallocate(intp ptr)
{
  if (ptr != null)
    free((void *) (ptr*CHARS_PER_INT + (intp) memory.me_memory));
}
