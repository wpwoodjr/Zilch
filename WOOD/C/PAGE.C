/*	Zilch Screen Editor,
 *	Copyright (c) 1982,1986,1987 William P. Wood, Jr. */

#include "symbols.h"
#include "memory.cmn"
#include "session.cmn"
#include "page.cmn"

void pa_switch(int n)
{
  register pagep pa;
  register windowp wn;
  windowp wi, prev;

  pa_map(se_pages,pa)
    if (pa_number(pa) == n)
      goto L10;
  pa = pa_new(n);	/* page doesn't exist; make a copy of current page */
  prev = null;
  wi_map(se_windows,wi) {
    wn = wi_copy(wi);
    if (prev == null)
      pa_windows(pa) = wn;
    else
      wi_next(prev) = wn;
    wi_prev(wn) = prev;
    prev = wn;
    if (wi == se_current_window)
      pa_current_window(pa) = wn;
    }
L10:
  pa_make_current(pa);
}

void pa_make_current(pagep pa)
{
  register windowp wi, wi2;

  wi_map(se_windows,wi)				/* save window locations */
    wi_map_sub_windows(wi, wi2)
      if (wi_buffer(wi2) != null) {
	bu_dot(wi_buffer(wi2)) = wi_dot(wi2);
	bu_bow(wi_buffer(wi2)) = wi_bow(wi2);
	if (wi2 == wi)
	  bu_current(wi_buffer(wi2)) = 1;
	else
	  bu_current(wi_buffer(wi2)) = 0;
	}
  pa_update;
  se_current_page = pa;
  se_current_window = pa_current_window(pa);
  wi_map(se_windows,wi)
    wi_modified(wi) = 1;
}

void pa_generate(register int n)
{
  register pagep pa;

  if (n == pa_highest_n)		/* optimize for last page... */
    n++;
  else {
    for (n++; ; n++) {			/* find new page number */
      pa_map(se_pages, pa)
	if (pa_number(pa) == n)
	  goto L10;
      break;
L10:  ;
      }
    }
  pa_make_current(pa_new(n));
}

pagep pa_new(int n)
{
  register pagep pan;
  pagep pa, prev;

  pan = me_allocate(pa_sizeof);
  if (n > pa_highest_n || pa_last_page == null) {  /* optimize for last page... */
    prev = pa_last_page;
    pa_last_page = pan;
    pa_highest_n = n;
    }
  else
    for (prev = null, pa = se_pages; pa != null; prev = pa, pa = pa_next(pa))
      if (n <= pa_number(pa))
	break;
  if (prev == null) {
    pa_next(pan) = se_pages;
    se_pages = pan;
    }
  else {
    pa_next(pan) = pa_next(prev);
    pa_next(prev) = pan;
    }
  pa_number(pan) = n;
  pa_windows(pan) = null;
  pa_current_window(pan) = null;
  return pan;
}

void switch_to_page(int n)
{
  pa_switch(n);
  ms_report_number("Page ", n, "");
  pa_ready(se_current_page);
}

void pa_ready(pagep pa)
{
  register windowp wi;

  wi_map(pa_windows(pa),wi) {
    bu_ready(wi_buffer(wi));
    wi_ready(wi);
    }
}

void pa_next_page(void)
{
  register pagep pa;

  pa_map(pa_next(se_current_page), pa)
    if (pa_number(pa) >= 0)
      break;
  if (pa == null)
    ms_error("This is the last page!");
  else
    switch_to_page(pa_number(pa));
}

void pa_previous_page(void)
{
  register pagep pa;

  for (pa = pa_prev(se_current_page); pa != null; pa = pa_prev(pa))
    if (pa_number(pa) >= 0)
      break;
  if (pa == null)
    ms_error("This is the first page!");
  else
    switch_to_page(pa_number(pa));
}

pagep pa_prev(pagep page)
{
  register pagep pa, prev;

  for (pa = se_pages, prev = null; pa != page; prev = pa, pa = pa_next(pa))
    ;
  return prev;
}
