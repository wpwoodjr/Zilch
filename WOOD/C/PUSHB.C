/*	Zilch Screen Editor,
 *	Copyright (c) 1982,1987 William P. Wood, Jr. */

#include "symbols.h"
#include "pushb.cmn"
#include "memory.cmn"

void pu_initialize(void)
{
  pu_buffer = bu_new("push-back", "");
}

void pu_push_region(bufferp but, bufferp buf, textind p1, textind p2)
{
  tx_copy_text(buf, p1, but, 1, p2-p1);
  bu_modified(but) = 0;
}

void pu_push_string(bufferp bu, register const char *str)
{
  const char *s;

  for (s = str, str += ho_length(str); str-- > s; )
    tx_insert_character(bu, *str, 1);
  bu_modified(bu) = 0;
}

void pu_push_character(bufferp bu, int c)
{
  tx_insert_character(bu, c, 1);
  bu_modified(bu) = 0;
}

void pu_push_back_character(int c)
{
  tx_insert_character(pu_buffer, - c, 1);
  bu_modified(pu_buffer) = 0;
}

void pu_push_back_buf(register const char *buf, int len)
{
  for (buf += len; len-- > 0; )
    tx_insert_character(pu_buffer, - (*--buf), 1);
  bu_modified(pu_buffer) = 0;
}

void pu_nextc(bufferp bu, char *c)
{
  if (bu_size(bu) > 0) {
    *c = tx_text(tx_address(bu, 1));
    tx_delete(bu, 1, 1);
    bu_modified(bu) = 0;
    }
}
