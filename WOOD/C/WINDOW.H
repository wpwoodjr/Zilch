/*
typedef struct window {
	buffer		*wi_buffer;
	window		*wi_next;
	window		*wi_prev;
	window		*wi_parent;
	window		*wi_sub_windows;
	window		*wi_next_bu_window;
	string		*wi_mode_line;
	textind		wi_dot;
	textind		wi_bow;
	int		wi_size;
	int		wi_sub_size;
	int		wi_min_size;
	int		wi_modified;
	int		wi_id;
	} window;
 */

#define wi_buffer(wi) me_mem(wi)
#define wi_dot(wi) me_mem(1+wi)
#define wi_bow(wi) me_mem(2+wi)
#define wi_size(wi) me_mem(3+wi)
#define wi_sub_size(wi) me_mem(4+wi)
#define wi_min_size(wi) me_mem(5+wi)
#define wi_modified(wi) me_mem(6+wi)
#define wi_id(wi) me_mem(7+wi)
#define wi_mode_line(wi) me_mem(8+wi)
#define wi_next(wi) me_mem(9+wi)
#define wi_prev(wi) me_mem(10+wi)
#define wi_parent(wi) me_mem(11+wi)
#define wi_sub_windows(wi) me_mem(12+wi)
#define wi_next_bu_window(wi) me_mem(13+wi)
#define wi_sizeof 14

#define wi_parent_buffer(wi) bu_parent(wi_buffer(wi))
#define wi_map(wi1, wi2) for (wi2 = wi1; wi2 != null; wi2 = wi_next(wi2))
#define wi_map_back(wi1, wi2) for (wi2 = wi1; wi2 != null; wi2 = wi_prev(wi2))
#define wi_set_bow(wi, bow) {wi_bow(wi) = bow; wi_modified(wi) = 1;}
#define wi_map_sub_windows(wi1, wi2) \
	  for (wi2 = wi_parent(wi1); wi2 != null; wi2 = wi_sub_windows(wi2))
