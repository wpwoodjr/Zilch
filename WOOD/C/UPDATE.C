/*	Zilch Screen Editor,
 *	Copyright (c) 1982,1983,1984,1986,1987 William P. Wood, Jr. */

#define TIMER 0
#define NODE_INFO 0
#define DEBUG 0

#include "symbols.h"
#include "update.cmn"
#include "screen.cmn"

#if NODE_INFO
#include "nodeinfo.cmn"
#endif

#define NONE 1
#define REPLACE 2
#define CLEAR 3
#define DELETE -1
#define INSERT -2
#define INSERT2 -3
#define UNTOUCHED 0
#define ON_OPEN 1
#define ON_CLOSED 2
#define succ(x) (x+1)
 
static void new_node(int cst,int idc,int old,int new,int neq,int op,nodep fa)
{
  register int index;

#if NODE_INFO
  nodes_generated = succ(nodes_generated);
#endif
  index = min(old - 1, sc_size) + (new - 1)*(sc_size + 1);
  if (up_stat(index) != ON_CLOSED)
    if (up_stat(index) == ON_OPEN) {
      if (up_cost(index) > cst) {
#if NODE_INFO
	nodes_replaced = succ(nodes_replaced);
#endif
	up_cost(index) = cst;
	up_insert_delete_count(index) = idc;
	up_operation(index) = op;
	up_father(index) = fa;
	up_neq(index) = neq;
	}
      }
    else {
#if NODE_INFO
      nodes_inserted = succ(nodes_inserted);
#endif
      up_open(index) = open;
      up_prev(index) = null;
      if (open != null)
	up_prev(open) = index;
      open = index;
      up_stat(index) = ON_OPEN;
      up_new_pos(index) = new;
      up_old_pos(index) = min(old,sc_size+1);
      up_cost(index) = cst;
      up_insert_delete_count(index) = idc;
      up_operation(index) = op;
      up_father(index) = fa;
      up_neq(index) = neq;
      }
}

static void remove_min_cost_node(void)
{
  register nodep op;
  int min_cost, i;

  min_node = open;
  min_cost = up_cost(open);
  op = up_open(open);
  while (op != null) {
    i = up_cost(op);
    if ((i < min_cost) ||
       ((i == min_cost) && (up_new_pos(op) > sc_size))) {
      min_cost = i;
      min_node = op;
      }
    op = up_open(op);
    }
  if (up_open(min_node) != null)
    up_prev(up_open(min_node)) = up_prev(min_node);
  if (up_prev(min_node) == null)
    open = up_open(min_node);
  else
    up_open(up_prev(min_node)) = up_open(min_node);
  up_stat(min_node) = ON_CLOSED;
}

static void skip(int *neq)
{
  while (up_new_pos(min_node) <= sc_size)
    /* this compare compares for reverse video too */
    if (q_cmpc(sc_buffer[sc_old][up_old_pos(min_node)-1],
	     sc_old_length(up_old_pos(min_node))+1,
	     sc_buffer[sc_new][up_new_pos(min_node)-1],
	     sc_new_length(up_new_pos(min_node))+1,
	     &neq)) {
      up_new_pos(min_node) = succ(up_new_pos(min_node));
      up_old_pos(min_node) = min(succ(up_old_pos(min_node)),sc_size+1);
      }
    else {
      neq = max(0, neq - 1);	/* because of reverse video */
      break;
      }
}

static void sc_find_a_way(volatile int *readc,int (*cs_replace)(int old,int new,int neq),int (*cs_delete)(int cheap,int idc),int (*cs_insert)(int newlen,int neq,int cheap,int idc))
{
  int old_new, op, np, cost, idc, neq;

#if DEBUG
  write(8,(" new page"));
#endif
  for ( ; ; ) {
    remove_min_cost_node();
    old_new = up_new_pos(min_node);
    skip(&neq);
    op = up_old_pos(min_node);
    np = up_new_pos(min_node);
    cost = up_cost(min_node);
    idc = up_insert_delete_count(min_node);
#if DEBUG
    write(8,(6i8)) op, np, up_operation(min_node), neq, cost;
#endif
#if NODE_INFO
    nodes_examined = succ(nodes_examined);
#endif
    if (np > sc_size || *readc)			/* done or read a character? */
      break;
    if (up_operation(min_node) > 0 || np != old_new) {
      new_node(
	    cost + (*cs_replace)(sc_old_length(op),sc_new_length(np),neq),
	    idc,
	    succ(op),
	    succ(np),
	    neq,
	    REPLACE,
	    min_node);
      if (op < sc_size) {
	new_node(
	    cost + (*cs_delete)(false, idc),
	    idc - 1,
	    succ(op),
	    np,
	    0,
	    DELETE,
	    min_node);
	if (np < sc_size) {
	  q_cmpc(0,0,sc_buffer[sc_new][np-1]+1,sc_new_length(np),&neq);
	  new_node(
	      cost + (*cs_insert)(sc_new_length(np), neq, false, idc),
	      idc + 1,
	      op,
	      succ(np),
	      neq,
	      INSERT,
	      min_node);
	  }
	}
      }
    else if (op < sc_size) {
      if (up_operation(min_node) == DELETE)
	new_node(
	    cost + (*cs_delete)(true, idc),
	    idc - 1,
	    succ(op),
	    np,
	    0,
	    DELETE,
	    min_node);
      else if (up_operation(min_node) == INSERT && np < sc_size) {
	q_cmpc(0,0,sc_buffer[sc_new][np-1]+1,sc_new_length(np),&neq);
	new_node(
	    cost + (*cs_insert)(sc_new_length(np), neq, true, idc),
	    idc + 1,
	    op,
	    succ(np),
	    neq,
	    INSERT,
	    min_node);
	}
      }
    }
}

static void sc_find_a_way_2(volatile int *readc,int (*cs_replace_2)(int old,int new,int neq),int cs_delete_2)
{
  int neq;

  for ( ; ; ) {
    remove_min_cost_node();
    if (up_operation(min_node) == NONE)
      new_node(cs_delete_2, 0, 2, 1, 0, DELETE, min_node);
    else if (up_new_pos(min_node) == 1 && up_old_pos(min_node) < sc_size)
      new_node(
	    up_cost(min_node) + cs_delete_2,
	    0,
	    succ(up_old_pos(min_node)),
	    1,
	    0,
	    DELETE,
	    min_node);
    skip(&neq);
#if NODE_INFO
    nodes_examined = succ(nodes_examined);
#endif
    if (up_new_pos(min_node) > sc_size || *readc)  /* done or read char? */
      break;
    new_node(
	    up_cost(min_node) +
			(*cs_replace_2)(sc_old_length(up_old_pos(min_node)),
					   sc_new_length(up_new_pos(min_node)),
					   neq),
	    0,
	    succ(up_old_pos(min_node)),
	    succ(up_new_pos(min_node)),
	    neq,
	    REPLACE,
	    min_node);
    }
}

static void do_deletes(nodep node)
{
  nodep i, j, k, m;
  int totdel, nd, ns, lastd;

  totdel = 0;
  for (i = node; i != null; )
    if (up_operation(i) != DELETE)
      i = up_son(i);
    else {
      nd = 1;
      lastd = i;
      for (j = up_son(i); j != null; j = up_son(j))
	if (up_operation(j) == DELETE && up_new_pos(j) == up_new_pos(i)) {
	  nd++;
	  lastd = j;
	  }
	else
	  break;
      /* try and merge insert-delete pairs into a scroll down */
      for (k = up_father(i); k != null && nd > 0; )
	if (up_operation(k) == INSERT) {
	  ns = 0;
	  for (m = k; k != null && ns < nd; k = up_father(k))
	    if (up_operation(k) == INSERT && up_old_pos(k) == up_old_pos(m)) {
	      ns++;
	      up_operation(k) = INSERT2;
	      }
	    else
	      break;
	  nd = nd-ns;
	  te_scroll_down_lines(up_old_pos(m)-totdel,
			    		up_old_pos(lastd)-totdel,ns);
	  up_old_pos(i) = up_old_pos(i) + ns;	/* might have been scrolled */
	  }
	else
	  k = up_father(k);
      /* try and merge delete-insert pairs into a scroll up */
      for (k = j; k != null && nd > 0; )
	if (up_operation(k) == INSERT) {
	  ns = 0;
	  for (m = k; k != null && ns < nd; k = up_son(k))
	    if (up_operation(k) == INSERT && up_old_pos(k) == up_old_pos(m)) {
	      ns++;
	      up_operation(k) = INSERT2;
	      }
	    else
	      break;
	  nd = nd-ns;
	  te_scroll_up_lines(up_old_pos(i)-totdel,
			    		up_old_pos(m)-1-totdel,ns);
	  /* fix up intervening deletes' delete position */
	  for (m = up_father(m); m != lastd; m = up_father(m))
	    if (up_operation(m) == DELETE)
	      up_old_pos(m) = up_old_pos(m)-ns;
	  }
	else
	  k = up_son(k);
      if (nd > 0) {
	te_scroll_up_lines(up_old_pos(i)-totdel,sc_size,nd);
	totdel = totdel + nd;
	}
      up_son(up_father(i)) = j;	/* remove delete nodes from list */
      if (j != null)
	up_father(j) = up_father(i);
      i = j;
      }
}

static void do_inserts(nodep node)
{
  nodep i, j;
  int ni;

  for (i = node; i != null; )
    if (up_operation(i) != INSERT)
      i = up_son(i);
    else {
      ni = 1;
      for (j = up_son(i); j != null; j = up_son(j))
	if (up_operation(j) == INSERT && up_old_pos(j) == up_old_pos(i))
	  ni++;
	else
	  break;
      te_scroll_down_lines(up_new_pos(i), sc_size, ni);
      i = j;
      }
}

/* An optimal buffer size is now computed by Q_DO_REPLACES (Nov 3, 1986)
 * which optimizes interruption of the screen update (by characters typed
 * by the user) versus effective QIO output speed.  One could use
 * the line speed indicated by the terminal's baud rate setting to set the
 * buffer size, but QIO output speed is a better measure of "interruptability"
 * than baud rate if you are logged in through a DECSA or are SET HOST.
 *
 * The idea is to let the user interrupt the screen update frequently
 * at low baud rates, and less frequently at high baud rates, so that
 * overall it takes about 1/4 of a second for the update to be interrupted.
 * Q_DO_REPLACES computes an optimal threshold size for the output buffer
 * after which the buffer is flushed at the next end of line.
 *
 * The technique is to measure the time it takes to write a screen which
 * contains more than 200 characters (less than 200 leads to unpredictable
 * results), then divide the time by the number of characters sent.  This
 * results in a figure for characters per second which is averaged over
 * 5 updates.  The buffer size is then set as large as possible while still
 * maintaining good interruptability.
 *
 * This technique results in high buffer sizes when SET HOST, leading to low
 * interruptability, because the RT driver seems to buffer the output
 * and send it more or less all at once.  Because of the driver's buffering,
 * Q_DO_REPLACES measures a high effective baud rate since it doesn't take
 * long to send the output to the RT driver's buffer.  Therefor Q_DO_REPLACES
 * measures an incorrect communications speed in this case, but it measures
 * the "interruptability" of the communications line correctly!  The reason is
 * that the routine measures the time for QIO's to complete, not line speed;
 * if all the QIOs complete quickly, there is no way to interrupt them anyway,
 * so the buffer size should be set high. */

static int q_do_replaces(nodep node, volatile int *readc)
{
  nodep i, j, k;
  int status, n, np, outlen;
  declare char
	tmp_buffer [SCREEN_SIZE] [SCREEN_WIDTH + 1];
  char tmp_length[SCREEN_SIZE];
# include "terminal.cmn"
# if VMS
  float seconds;
  static float characters_per_second = 0.0;
  static int setting_buffer_size = true;
  static int setting_buffer_size_count = 0;
  int nch;

  if (setting_buffer_size) {
    nch = 0;
    seconds = secnds(0.0);
    }
# endif
  status = true;
  for (i = node; i != null; i = up_son(i)) {
    if (ti_count >= up_buffer_size) {
# if VAX
      nch = nch + ti_count;
# endif
      ti_flush();
      if (*readc) {
	for (k = i; k != null; k = up_son(k)) {
	  if (up_operation(k) != REPLACE) {
	    tmp_length[up_new_pos(k)-1] = 0;
	    tmp_buffer[up_new_pos(k)-1][0] = false;
	    }
	  else {
	    tmp_length[up_new_pos(k)-1] = sc_old_length(up_old_pos(k));
	    movc(sc_buffer[sc_old][up_old_pos(k)-1],
		      tmp_buffer[up_new_pos(k)-1],
		      tmp_length[up_new_pos(k)-1]+1);
	    }
	  sc_modified(up_new_pos(k)) = true;
	  }
	for (j = 1; j <= sc_size; j++)
	  if (sc_modified(j))
	    if (i == null)
	      goto L10;
	    else if (j == up_new_pos(i)) {
	      movc(tmp_buffer[j-1],sc_buffer[sc_old][j-1],
			      tmp_length[j-1]+1);
	      sc_old_length(j) = tmp_length[j-1];
	      i = up_son(i);
	      }
	    else {
L10:	      movc(sc_buffer[sc_new][j-1],sc_buffer[sc_old][j-1],
			      sc_new_length(j)+1);
	      sc_old_length(j) = sc_new_length(j);
	      sc_modified(j) = false;
	      }
	status = false;
	break;
	}
      }
    n = up_neq(i);
    np = up_new_pos(i);
    outlen = sc_new_length(np) - n;
    if (outlen > 0 || up_operation(i) == REPLACE) {
      te_pos(np, n + 1);
      if (outlen > 0) {
	if (sc_reverse_video(np,sc_new))
	  te_reverse_video();
	ti_outch(sc_buffer[sc_new][np-1]+n+1,outlen);
	te_pos_x = te_pos_x + outlen;
	if (sc_reverse_video(np,sc_new))
	  te_reverse_video_off();
	}
      if (up_operation(i) == REPLACE)
	te_erase_to_end_of_line(sc_old_length(up_old_pos(i)),
			  max(n, sc_new_length(np)));
      }
    }
#if VMS
  if (setting_buffer_size) {
    if (nch > 200) {
/* flush the buffer one last time, but DON'T add the number of characters
 * in it to NCH; empirically, this results in more accurate results;
 * each flush seems to have to wait for the one before it to complete,
 * so we are only waiting for characters output BEFORE this flush. */
      ti_flush();
      seconds = secnds(seconds);
      if (seconds > 0.0) {
	characters_per_second = characters_per_second + (nch/seconds);
	if (characters_per_second <= 300)
	  /* make life easier for probable 1200 baud users */
	  up_buffer_size = 0;
	setting_buffer_size_count = setting_buffer_size_count + 1;
	if (setting_buffer_size_count >= 5) {
	  setting_buffer_size = false;
	  characters_per_second =
	    characters_per_second/setting_buffer_size_count;
	  if (characters_per_second <= 200)
	    up_buffer_size = 0;
	  else if (characters_per_second <= 300)
	    up_buffer_size = 50;
	  else if (characters_per_second <= 600)
	    up_buffer_size = 100;
	  else if (characters_per_second <= 1200)
	    up_buffer_size = 200;
	  else
	    up_buffer_size = 400;
	  }
	}
      }
    }
# endif
  return status;
}

static int q_update_screen(volatile int *readc)
{
  register nodep i;

  up_son(min_node) = null;
  for (i = min_node; up_operation(i) != NONE; i = up_father(i)) {
    up_son(up_father(i)) = i;
    up_old_pos(i) = up_old_pos(up_father(i));
    up_new_pos(i) = up_new_pos(up_father(i));
    }
#if DEBUG
  j = i;
  write(7,(/" *** new page ***"));
  for (i = up_son(i); i != null; i = up_son(i)) {
    switch (up_operation(i)) {
      case REPLACE:
	write(7,(' Replace old line 'i2' with new line 'i2'; cost = 'i4)) 
	  up_old_pos(i),up_new_pos(i),up_cost(i);
	break;
      case DELETE:
	write(7,(' Delete old line 'i2'; new line is 'i2'; cost = 'i4)) 
	  up_old_pos(i),up_new_pos(i),up_cost(i);
	break;
      case INSERT:
	write(7,(' Insert new line 'i2' before old line 'i2'; cost = 'i4)) 
	  up_new_pos(i),up_old_pos(i),up_cost(i);
	break;
      case CLEAR:
	write(7,(' Clear screen; cost = 'i4)) up_cost(i);
	break;
      }
    }
  i = j;
#endif
#if NODE_INFO
#define writeint write(9,(" $&:",5i8)) $&
  writeint(nodes_generated);
  writeint(nodes_examined);
  writeint(nodes_inserted);
  writeint(nodes_replaced);
  writeint(nodes_inserted + nodes_replaced);
#undef(writeint)
#endif
  if (up_son(i) != null)
    if (up_operation(up_son(i)) == CLEAR) {
      if (sc_redraw)
	te_init_sequence();
      te_clear();
      sc_redraw = false;
      return q_do_replaces(up_son(up_son(i)), readc);
      }
    else {
      do_deletes(up_son(i));
      do_inserts(up_son(i));
      return q_do_replaces(up_son(i), readc);
      }
  return true;
}

void sc_update(volatile int *readc)
{
# include "terminal.cmn"
  static const char bell[] = "\7";
  nodep op;
  int modlin, i;
#if TIMER
  long int handle = 0;
#endif

  if (*readc)						/* type-ahead? */
    return;
#if NODE_INFO
  nodes_generated = 0;
  nodes_examined = 0;
  nodes_inserted = 0;
  nodes_replaced = 0;
#endif
#if TIMER
  lib$init_timer(&handle);
#endif
  sc_fill_new();
  for (modlin = 1; modlin <= sc_size; modlin++)
    if (sc_modified(modlin))
      break;
  if (modlin <= sc_size || sc_redraw) {
    fillc(up_stat_a, (SCREEN_SIZE+1)*(SCREEN_SIZE+1), UNTOUCHED);
    sc_old_length(sc_size+1) = 0;
    sc_reverse_video(sc_size+1, sc_old) = false;
    open = null;
    new_node(0, 0, modlin, modlin, 0, NONE, null);
    op = open;
    if (sc_redraw)
      remove_min_cost_node();		/* only generate nodes after clear */
    switch (te_type) {
      case ADM3A:
	new_node(cs_adm3a_clear(), 0, sc_size+1, 1, 0, CLEAR, op);
	sc_find_a_way_2(readc, cs_adm3a_replace, cs_adm3a_delete());
	break;
      case ADM5:
	new_node(cs_adm3a_clear(), 0, sc_size+1, 1, 0, CLEAR, op);
	sc_find_a_way_2(readc, cs_adm5_replace, cs_adm3a_delete());
	break;
      case VT100:
	new_node(cs_vt100_clear(), 0, sc_size+1, 1, 0, CLEAR, op);
	sc_find_a_way(readc, cs_vt100_replace, cs_vt100_delete,
    							cs_vt100_insert);
	break;
      case VT52:
	new_node(cs_vt52_clear(), 0, sc_size+1, 1, 0, CLEAR, op);
	sc_find_a_way_2(readc, cs_vt52_replace, cs_adm3a_delete());
	break;
      }
    if (*readc)
      return;
    if (! q_update_screen(readc))
      return;
    for (i = modlin; i <= sc_size; i++)
      if (sc_modified(i)) {
	movc(sc_buffer[sc_new][i-1], sc_buffer[sc_old][i-1],
      			sc_new_length(i)+1);
	sc_old_length(i) = sc_new_length(i);
	sc_modified(i) = false;
	}
    if (sc_new_length(sc_size) != 0) {		/* clear messages */
      sc_modified(sc_size) = true;
      sc_new_length(sc_size) = 0;
      }
    }
  te_pos(sc_cursor_y, sc_cursor_x);
  if (sc_error_occurred) {
    ti_outch(bell, 1);
    sc_error_occurred = false;
    }
  ti_flush();
#if TIMER
  te_pos(22, 30);
  ti_flush();
  lib$show_timer(&handle, &2);
  te_pos(sc_cursor_y, sc_cursor_x);
  ti_flush();
#endif
}

void up_display_buffer_size(void)
{
  ms_report_number2("Output buffer size threshold is ",
  	up_buffer_size, " character.", " characters.");
}
