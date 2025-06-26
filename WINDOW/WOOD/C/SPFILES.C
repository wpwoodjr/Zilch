/*	Zilch Screen Editor,
 *	Copyright (c) 1982,1987 William P. Wood, Jr. */

#include "symbols.h"
#include "memory.cmn"

bufferp sp_read_buffer(const char *na, stringp *fp, const char *err)
{
  bufferp bu;

  if (*fp == null)
    return null;
  bu = bu_find_by_name(na);
  if (bu == null) {
    bu = bu_new(na, "");
    if (! q_mp_read_file(bu, st_buffer(*fp), 0, false)) {
      st_deallocate(*fp);
      *fp = null;
      ms_error(err);
      return null;
      }
    }
  return bu;
}
