/*	Zilch Screen Editor,
 *	Copyright (c) 1982,1987 William P. Wood, Jr. */

#include "symbols.h"
#include "tables.cmn"

/* ho_length - compute length of hollerith string */
int ho_length(register const char *str)
{
   register const char *s2 = str;

   while (*str++)
      ;
   return str - s2 - 1;
}

/* ho_scopy - copy string at from(i) to to(j) */
void ho_scopy(register const char *from, int i, register char *to, int j)
{
   from += i - 1;
   to += j - 1;
   while ((*to++ = *from++) != EOS)
      ;
}

/* ho_clower - change letter to lower case */
int ho_clower(int c)
{
   return ta_clower(c);
}

/* ho_cupper - change letter to upper case */
int ho_cupper(int c)
{
   return c >= 'a' && c <= 'z' ? c - 'a' + 'A' : c ;
}

/* q_ho_is_upper - return true if c is upper case letter */
int q_ho_is_upper(int c)
{
  return c >= 'A' && c <= 'Z';
}

/* q_ho_equal - compare str1 to str2; return true if equal, false if not */
int q_ho_equal(register const char *str1, register const char *str2)
{
   while (ta_clower(*str1) == ta_clower(*str2++))
      if (*str1++ == EOS)
	 return true;
   return false;
}

/* ho_index - find character  c  in string  str */
int ho_index(register const char *str, int c)
{
   register const char *s2 = str;

   while (*str)
      if (*str++ == c)
	 return str - s2;
   return 0;
}

/* ho_indexq - find character c in str, ignoring chars within quoted strings */
int ho_indexq(register const char *str, int c)
{
   register int index;

   for (index = ho_nuqcp(str, 1); str[index-1];
	index = ho_nuqcp(str, index+1))
      if (str[index-1] == c)
         return index;
   return 0;
}

/* ho_nuqcp - return pos of next char which isn't part of a quoted (") string */
int ho_nuqcp(register const char *buf, register int i)
{
  if (buf[i-1] != '"')
    return i;
  while (buf[i++])
    if (buf[i-1] == '"') {
      if (buf[i++] != '"')
	return i;
      }
  return i;
}

/* ho_bkscnq - return index of first break char in str,
 *	       ignore chars inside quotes */
int ho_bkscnq(register const char *str, const char *brk, int i)
{
  register int index;

  for (index = ho_nuqcp(str,i); str[index-1];
		index = ho_nuqcp(str,index+1))
    if (ho_index(brk, str[index-1]) != 0)
      break;
  return index;
}

/* ho_itoc - convert integer intg  to char string in  str */
int ho_itoc(long int intg, register char *str, int size)
{
   register long int intval;
   char c, *s;
   int d, i;

   intval = intg;
   s = str;
   *str++ = EOS;
   i = 1;
   do {					/* generate digits */
      i++;
      d = intval % 10;
      *str++ = abs(d) + '0';
      intval = (intval-d)/10;
      } while (intval != 0 && i < size);
   if (intg < 0 && i < size) {		/* then sign */
      i++;
      *str++ = '-';
      }
   do {					/* then reverse */
      c = *--str;
      *str = *s;
      *s++ = c;
      } while (str > s);
   return i - 1;
}

/* ho_itocrj - convert integer to character in a right-adjusted field */
#define MAXCHARS 20
int ho_itocrj(long int intg, char *str, int size)
{
   register char *s1;
   register const char *s2;
   char tbuf[MAXCHARS];

   s2 = tbuf + ho_itoc(intg, tbuf, MAXCHARS);
   for (s1 = str + size - 1; s2 >= tbuf && s1 >= str; )
      *s1-- = *s2--;
   while (s1 >= str)
      *s1-- = ' ';
   return size - 1;
}

/* ho_ctoi - convert string at in(i) to integer, increment index */
long int ho_ctoi(register const char *in, int *index)
{
   register const char *inp;
   long int intval;
   int d, neg;

   inp = in + *index - 1;
   while (*inp == ' ' || *inp == TAB)
      inp++;
   if (*inp == '-') {
     neg = true;
     inp++;
     }
   else
     neg = false;
   for (intval = 0; *inp; inp++) {
      d = *inp - '0';
      if (d < 0 || d > 9)		/* non-digit */
         break;
      intval = 10 * intval + d;
      }
   *index = inp - in + 1;
   return neg ? -intval : intval;
}
