/* Prototypes for asssembler, or macro, routines */

#if VMS

#define movc movc_c
void movc(const char *in, char *out, unsigned short int len);
#define q_cmpc q_cmpc_c
int q_cmpc(const char *s1, unsigned int l1, const char *s2,
		unsigned int l2, int *neq);
#define fillc fillc_c
fillc(char *out, unsigned int len, char c);
#define secnds secnds_c		/* gasp! FORTRAN! */
secnds(float secs);

#endif

#if MSDOS

#include <mem.h>

#define movc(in, out, len) memcpy(out, in, len)

#endif
