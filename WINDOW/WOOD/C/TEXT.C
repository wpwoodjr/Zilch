/*	Zilch Screen Editor,
 *	Copyright (c) 1982,1986,1987 William P. Wood, Jr. */

#include "symbols.h"
#include "session.cmn"
#include "memory.cmn"

textp tx_address(bufferp bu, textind x)
{
  textp i;

  i = x + bu_base(bu);
  if (i >= bu_gap(bu))
    return i+bu_gap_size(bu);
  else
    return i;
}

void tx_set_gap(bufferp bu, textind x)
{
  textp gap, loc;

  gap = bu_gap(bu);
  loc = bu_base(bu)+x;
  if (gap < loc)
    tx_movc(gap+bu_gap_size(bu), gap, loc-gap);
  else if (gap > loc)
    tx_movc(loc, loc+bu_gap_size(bu), gap-loc);
  bu_gap(bu) = loc;
}

void tx_movc(textp from, textp to, textind len)
{
  textind i;

  if (from >= to)
    for (i = 0; i < len; i += 65535)
      movc(&tx_text(from+i), &tx_text(to+i), min(len-i, 65535));
  else
    for (i = len; i > 0; i -= 65535)
      movc(&tx_text(from+max(0, i-65535)), &tx_text(to+max(0, i-65535)),
      								min(i, 65535));
}

void tx_delete(bufferp bu, textind tx1, textind tx2)
{
  textind len;
  windowp wi;
  markp mk;

  tx_set_gap(bu, tx1);
  len = tx2 - tx1 + 1;
  if (len > 0) {
    bu_gap_size(bu) = bu_gap_size(bu) + len;
    bu_modified(bu) = 1;
    bu_size(bu) = bu_size(bu) - len;
    bu_map_windows(bu, wi) {
      if (wi_dot(wi) > tx2)		/* ok */
	wi_dot(wi) = wi_dot(wi) - len;
      else if (wi_dot(wi) > tx1)	/* ok */
	wi_dot(wi) = tx1;
      if (wi_bow(wi) > tx2)		/* ok */
	if (wi_bow(wi) == tx2 + 1)
	  wi_bow(wi) = find_bol(bu, wi_bow(wi) - len);
	else {
	  wi_bow(wi) = wi_bow(wi) - len;
	  continue;
	  }
      else if (wi_bow(wi) > tx1)	/* ok */
	wi_bow(wi) = find_bol(bu, tx1);
      wi_modified(wi) = 1;
      }
    mk_map(bu_markers(bu), mk)
      if (mk_mark(mk) > tx2)
	mk_mark(mk) = mk_mark(mk) - len;
      else if (mk_mark(mk) > tx1)
	mk_mark(mk) = tx1;
    }
}

void tx_insert_character(bufferp bu, int c, textind tx)
{
  windowp wi;
  markp mk;

  if (bu_gap_size(bu) <= 0)
    tx_more_memory_please(bu, 1);
  tx_set_gap(bu, tx);
  tx_text(bu_gap(bu)) = c;
  bu_gap(bu) = bu_gap(bu) + 1;
  bu_gap_size(bu) = bu_gap_size(bu) - 1;
  bu_modified(bu) = 1;
  bu_size(bu) = bu_size(bu) + 1;
  bu_map_windows(bu, wi) {
    if (wi_dot(wi) > tx)		/* ok */
      wi_dot(wi) = wi_dot(wi) + 1;
    if (wi_bow(wi) > tx)		/* ok */
      wi_bow(wi) = wi_bow(wi) + 1;
    else
      wi_modified(wi) = 1;
    }
  mk_map(bu_markers(bu), mk)
    if (mk_mark(mk) > tx)
      mk_mark(mk) = mk_mark(mk) + 1;
}

#ifdef INTERFACE
void tx_add_character(bufferp bu, int c)
{
  if (bu_gap_size(bu) <= 0)
    tx_more_memory_please(bu, 1);
  tx_text(bu_gap(bu)) = c;
  bu_gap(bu) = bu_gap(bu) + 1;
  bu_gap_size(bu) = bu_gap_size(bu) - 1;
  bu_size(bu) = bu_size(bu) + 1;
}
#endif

void tx_insert_buffer(bufferp bu, textind tx, const char *buf, int len)
{
  windowp wi;
  markp mk;

  if (bu_gap_size(bu) < len)
    tx_more_memory_please(bu, len);
  if (len > 0) {
    tx_set_gap(bu, tx);
    movc(buf, &tx_text(bu_gap(bu)), len);
    bu_gap(bu) = bu_gap(bu) + len;
    bu_gap_size(bu) = bu_gap_size(bu) - len;
    bu_modified(bu) = 1;
    bu_size(bu) = bu_size(bu) + len;
    bu_map_windows(bu, wi) {
      if (wi_dot(wi) > tx)		/* ok */
	wi_dot(wi) = wi_dot(wi) + len;
      if (wi_bow(wi) > tx)		/* ok */
	wi_bow(wi) = wi_bow(wi) + len;
      else
	wi_modified(wi) = 1;
      }
    mk_map(bu_markers(bu), mk)
      if (mk_mark(mk) > tx)
	mk_mark(mk) = mk_mark(mk) + len;
    }
}

void tx_copy_text(bufferp buf,textind from,bufferp but,textind to,textind len)
{
  windowp wi;
  markp mk;

  if (len > bu_gap_size(but))
    tx_more_memory_please(but, len);
  if (len > 0) {
    tx_set_gap(but, to);
    tx_set_gap(buf, from);
    tx_movc(tx_address(buf, from), bu_gap(but), len);
    bu_gap(but) = bu_gap(but) + len;
    bu_gap_size(but) = bu_gap_size(but) - len;
    bu_modified(but) = 1;
    bu_size(but) = bu_size(but) + len;
    bu_map_windows(but, wi) {
      if (wi_dot(wi) > to)		/* ok */
	wi_dot(wi) = wi_dot(wi) + len;
      if (wi_bow(wi) > to)		/* ok */
	wi_bow(wi) = wi_bow(wi) + len;
      else
	wi_modified(wi) = 1;
      }
    mk_map(bu_markers(but), mk)
      if (mk_mark(mk) > to)
	mk_mark(mk) = mk_mark(mk) + len;
    }
}

void tx_more_memory_please(bufferp bu, textind size)
{
  stringp st;
  textind gapoff, len;
  int i;

  if (size == 0 || bu_gap_size(bu) < size || bu_gap_size(bu) > 2*(size + 4*512)){
    if (size != 0)
      size += 4*512;
    st = st_allocate(size + bu_size(bu) + SCREEN_SIZE - 2);
    gapoff = bu_gap(bu) - (bu_base(bu) + 1);
    if (gapoff > 0)
      tx_movc(bu_base(bu)+1, st, gapoff);
    len = bu_size(bu) - gapoff;
    if (len > 0)
      tx_movc(bu_gap(bu) + bu_gap_size(bu),
			  st + gapoff + size, len);
    for (i = 0; i < SCREEN_SIZE-2; i++)       /* bit of hocus-pocus here... */
      tx_text(st+bu_size(bu)+size+i) = NEWLINE; /* makes things easier */
    st_deallocate(bu_base(bu) + 1);
    bu_base(bu) = st - 1;
    bu_gap_size(bu) = size;
    bu_gap(bu) = st + gapoff;
    }
}

int q_tx_search_forward(bufferp bu,textind t1,textind t2,const char *buf,const char *mask,int len,textind *loc)
{
  textp tx, end;
  int j;

  if (bu_gap(bu) > bu_base(bu) + t1)
    tx_set_gap(bu, t1);
  for (tx = tx_address(bu, t1), end = tx_address(bu, t2+1);
			tx+len <= end; tx++) {
    for (j = 0; j < len; j++)
      if (buf[j] != (mask[j] | tx_text(j+tx)))
	goto L10;
    *loc = tx - bu_base(bu) - bu_gap_size(bu);
    return true;
L10:
    ;
    }
  return false;
}

int q_tx_search_reverse(bufferp bu,textind t1,textind t2,const char *buf,const char *mask,int len,textind *loc)
{
  textp tx, beg;
  int j;

  if (t2 > 0) {
    if (bu_gap(bu) < bu_base(bu) + t2 + 1)
      tx_set_gap(bu, t2 + 1);
    for (tx = tx_address(bu, t2+1-len), beg = tx_address(bu, t1);
			  tx >= beg; tx--) {
      for (j = 0; j < len; j++)
	if (buf[j] != (mask[j] | tx_text(j+tx)))
	  goto L10;
      *loc = tx - bu_base(bu);
      return true;
L10:
      ;
      }
    }
  return false;
}

void tx_case_change(bufferp bu, textind t1, textind t2)
{
  textp tx;
  windowp wi;
# include "tables.cmn"

  if (t2 >= t1) {
    while (t1 <= t2) {
      tx = tx_address(bu, t1++);
      if (bu_case(bu) == 1)
	tx_text(tx) = ho_cupper(tx_text(tx));
      else
	tx_text(tx) = ta_clower(tx_text(tx));
      }
    bu_modified(bu) = 1;
    bu_map_windows(bu, wi)
      if (wi_bow(wi) <= t2)
	wi_modified(wi) = 1;
    }
}

void tx_copy_text_to_string(bufferp bu, textind t1, textind t2, stringp st)
{
  while (t1 <= t2)
    *st_buffer(st++) = tx_text(tx_address(bu, t1++));
}
