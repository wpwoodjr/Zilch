#define pa_next(pa) me_mem(pa)
#define pa_number(pa) me_mem(1+pa)
#define pa_windows(pa) me_mem(2+pa)
#define pa_current_window(pa) me_mem(3+pa)
#define pa_sizeof 4
#define pa_map(pa1, pa2) for (pa2 = pa1; pa2 != null; pa2 = pa_next(pa2))
#define pa_update (pa_current_window(se_current_page) = se_current_window)
