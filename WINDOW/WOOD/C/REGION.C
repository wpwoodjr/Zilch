/*	Zilch Screen Editor,
 *	Copyright (c) 1982,1987 William P. Wood, Jr. */

#include "symbols.h"
#include "session.cmn"
#include "memory.cmn"

void delete_region(textind t1, textind t2)
{
  tx_delete(se_current_buffer, min(t1, t2), max(t1, t2)-1);
}

void yank_buffer(const char *buffer)
{
  bufferp bu;

  bu = bu_find_by_name(buffer);
  if (bu == null) {
    ms_message("Non-existent buffer: \"");
    ms_add_to_message(buffer);
    ms_add_to_message("\"");
    ms_error("");
    }
  else if (bu == se_current_buffer)
    ms_error("Can't insert a buffer into itself!");
  else {
    wi_dot(se_current_window) = wi_dot(se_current_window)+1;/* make it inc dot */
    tx_copy_text(bu, 1, se_current_buffer,
		      wi_dot(se_current_window)-1, bu_size(bu));
    wi_dot(se_current_window) = wi_dot(se_current_window)-1;/* end fake-out */
    }
}

int q_copy_region_to_buffer(const char *buffer, textind t1, textind t2)
{
  bufferp bu;

  bu = bu_find_by_name(buffer);
  if (bu == null)
    bu = bu_new(buffer, "");
  else if (bu == se_current_buffer) {
    ms_error("Can't insert a buffer into itself!");
    return false;
    }
  else {
    bu_clear_text(bu);
    tx_more_memory_please(bu, abs(t1-t2));
    }
  tx_copy_text(se_current_buffer, min(t1,t2), bu, 1, abs(t1-t2));
  bu_modified(bu) = 0;
  return true;
}

void delete_region_to_buffer(const char *buffer, textind t1, textind t2)
{
  if (q_copy_region_to_buffer(buffer, t1, t2))
    delete_region(t1, t2);
}
