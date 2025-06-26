#if VMS
#include <descrip.h>
/*
 *	A simple macro to construct a string descriptor:
 */
#define vms_char_descr(name,string,len) \
	struct dsc$descriptor_s name = \
		{ len, DSC$K_DTYPE_T, DSC$K_CLASS_S, string }

#define set_vms_char_descr_len(name,len) name.dsc$w_length = len
#endif
