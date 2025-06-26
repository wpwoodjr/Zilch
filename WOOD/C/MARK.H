#define mk_next(mk) me_mem(mk)		/* next marker in list */
#define mk_mark(mk) me_mem(1+mk)	/* number of marked character in buffer */
#define mk_sizeof 2
#define mk_map(mk1, mk2) for (mk2 = mk1; mk2 != null; mk2 = mk_next(mk2))
