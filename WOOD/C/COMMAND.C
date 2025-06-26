/*	Zilch Screen Editor,
 *	Copyright (c) 1982,1986,1987 William P. Wood, Jr. */

#include "symbols.h"
#include "tables.cmn"

/* q_co_parse - return first arg in comand and increment comand */
int q_co_parse(const char **comand, char *arg, int comma_is_white)
{
  register const char *cmd;
  const char *begincmd;
  int litral, inbrak;

  for (cmd = *comand; *cmd == ' ' || (comma_is_white && *cmd == ','); cmd++)
    ;
  for (begincmd = cmd, litral = false, inbrak = false;
	  *cmd && (litral || inbrak || (*cmd != ' ' &&
					(*cmd != ',' || !comma_is_white) &&
					(cmd == begincmd || *cmd != '/'))); ) {
    if (*cmd == '"')
      if (cmd[1] == '"')
	*arg++ = *cmd++;
      else
	litral = !litral;
    else if ((*cmd == '<' || *cmd == '[') && ! litral)
      inbrak = true;
    else if ((*cmd == '>' || *cmd == ']') && ! litral)
      inbrak = false;
    if (litral)
      *arg++ = *cmd++;
    else
      *arg++ = ta_clower(*cmd++);
    }
  *arg = EOS;
  *comand = cmd;
  return cmd != begincmd;
}
 
#define isupper(c) ((c) >= 'A' && (c) <= 'Z')

/* q_co_matswi - match a switch (qualifier) */
int q_co_matswi(const char *swtch, const char *templ, int *ler, const char *errmsg, long int *n, char *cbuf, int csize)
{
  int i, j, bs;
  long int l;

  for (i = 0, j = 0; templ[j] && templ[j] != '='; j++)
    if (ta_clower(swtch[i]) == ta_clower(templ[j]) && i == j)
      i++;
    else if (isupper(templ[j]))
      return false;

  if (! templ[j])
    if (! swtch[i])
      return true;
    else if (swtch[i] == '=') {
      co_error(swtch, i, "No qualifier argument expected.");
      *ler = true;
      return false;
      }

  if (swtch[i] != '=') {
    if (swtch[i])
      return false;
    if (*errmsg)
      co_error(swtch, i, "Qualifier argument expected.");
    *ler = true;
    return false;
    }

  i++;
  bs = i;
  switch (templ[j+1]) {
    case '#':
      i++;
      l = ho_ctoi(swtch, &i);
      if (swtch[i-1])			/* didn't exhaust the string */
	break;
      *n = l;
      return true;

    case '\'':
      for(j = 0; j < csize && ((*cbuf++ = swtch[i++]) != EOS); j++)
	;
      if (j >= csize || j == 0)
	break;
      *n = j;
      return true;
    }

  if (*errmsg)
    co_error(swtch, bs, errmsg);
  *ler = true;
  return false;
}
 
void co_error(const char *swtch, int i, const char *errmsg)
{
if (*swtch)
  printf("%s\n", swtch);
printf("%s\n", errmsg);
/*
  ti_kill();
  if (*swtch)
    send_message_to_terminal(swtch);
  send_message_to_terminal(errmsg);
  ti_finish();
  exit(EXIT_BAD);
*/
}
