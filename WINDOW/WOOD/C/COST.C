/*	Zilch Screen Editor,
 *	Copyright (c) 1982,1986,1987 William P. Wood, Jr. */

#include "symbols.h"

int cs_adm3a_clear(void)
{
  return 3;
}

int cs_adm3a_replace(int old, int new, int neq)
{
  return 4 + max(old,new) - neq;
}

int cs_adm3a_delete(void)
{
# include "terminal.cmn"

  return 1 + ti_lffill;
}

int cs_adm5_replace(int old, int new, int neq)
{
  return 4 + max(0,new-neq) + max(0,min(2,old-max(neq,new)));
}

int cs_vt100_clear(void)
{
  return 7;
}

int cs_vt100_replace(int old, int new, int neq)
{
  return 7 + max(0,new-neq) + max(0,min(3,old-max(neq,new)));
}

int cs_vt100_insert(int newlen, int neq, int cheap, int idc)
{
  register int cost;

  cost = newlen - neq;
  if (cost > 0)
    cost += 7;			/* because of cursor positioning */
  if (idc < 0)
    return cost;
  else if (cheap)
    return cost + 8;		/* would be 2 if could resolve idc problem */
				/* bumped from 5 to 8 May 6, 1988 -
				   scrolling too slow on Vax station */
  else
    return cost + 7 + 2 + 4;
}

int cs_vt100_delete(int cheap, int idc)
{
  if (idc > 0)
    return 0;
  else if (cheap)
    return 8;			/* would be 1 if could resolve idc problem */
				/* bumped from 5 to 8 May 6, 1988 -
				   scrolling too slow on Vax station */
  else
    return 7 + 5 + 1 + 4;
}

int cs_vt52_clear(void)
{
  return 4;
}

int cs_vt52_replace(int old, int new, int neq)
{
  return 4 + max(0,new-neq) + max(0,min(2,old-max(neq,new)));
}
