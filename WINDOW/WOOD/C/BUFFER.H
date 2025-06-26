#define bu_parent(bu) me_mem(bu)	/* parent buffer of this buffer */
#define bu_next(bu) \
	  me_mem(1+bu_parent(bu))	/* next buffer in list */
#define bu_name(bu) \
	  me_mem(2+bu_parent(bu))	/* pointer to buffer name */
#define bu_file_name(bu) \
	  me_mem(3+bu_parent(bu))	/* pointer to buffer file name */
#define bu_modified(bu) \
	  me_mem(4+bu_parent(bu))	/* modified flag:
					 * if even, buffer not modified
					 *   if 0, not modified
					 *   if 2, file not read yet
					 * if odd, buffer was modified
					 *   if 1, modified
					 *   if 3, has valid checkpoint file */
#define bu_type(bu) \
	  me_mem(5+bu_parent(bu))	/* mapping type of buffer */
#define bu_mappings(bu) \
	  me_mem(6+bu_parent(bu))	/* pointer to mappings buffer */
#define bu_protection(bu) \
	  me_mem(7+bu_parent(bu))	/* file protection code */
#define bu_indent(bu) \
	  me_mem(8+bu_parent(bu))	/* current indent in buffer */
#define bu_case(bu) \
	  me_mem(9+bu_parent(bu))	/* 1 - upper case; 0 - upper/lower */
#define bu_windows(bu) me_mem(10+bu)	/* list of windows onto the buffer */
#define bu_size(bu) me_mem(11+bu)	/* size in chars of text buffer */
#define bu_base(bu) me_mem(12+bu)	/* address-1 of text buffer */
#define bu_gap(bu) me_mem(13+bu)	/* address of gap in text buffer */
#define bu_gap_size(bu) me_mem(14+bu)	/* size of gap */
#define bu_dot(bu) me_mem(15+bu)	/* hold cursor pos when text not visible */
#define bu_bow(bu) me_mem(16+bu)	/* hold beg of window when text not vis */
#define bu_save_dot_ptr(bu) \
	  me_mem(17+bu)			/* cursor position at last position save */
#define bu_save_dot(bu) mk_mark(bu_save_dot_ptr(bu))
#define bu_save_bow_ptr(bu) \
	  me_mem(18+bu)			/* beg. of window at last position save */
#define bu_save_bow(bu) mk_mark(bu_save_bow_ptr(bu))
#define bu_mark1_ptr(bu) me_mem(19+bu)	/* text mark 1 */
#define bu_mark1(bu) mk_mark(bu_mark1_ptr(bu))
#define bu_mark2_ptr(bu) me_mem(20+bu)	/* text mark 2 */
#define bu_mark2(bu) mk_mark(bu_mark2_ptr(bu))
#define bu_markers(bu) me_mem(21+bu)	/* list of text markers */
#define bu_id(bu) me_mem(22+bu)		/* id of buffer */
#define bu_current(bu) me_mem(23+bu)	/* tells which sub-buf was last current */
#define bu_sub_buffers(bu) me_mem(24+bu)/* list of sub-buffers - sub-buffers do
					 * not appear in the list of session
					 * buffers */
#define bu_sizeof 25

#define bu_map(bu1, bu2) \
	  for (bu2 = bu1; bu2 != null; bu2 = bu_next(bu2))
#define bu_map_windows(bu, wi) \
	  for (wi = bu_windows(bu); wi != null; wi = wi_next_bu_window(wi))
#define bu_map_sub_buffers(bu1, bu2) \
	  for (bu2 = bu_parent(bu1); bu2 != null; bu2 = bu_sub_buffers(bu2))
