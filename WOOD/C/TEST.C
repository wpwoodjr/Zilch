#include "symbols.h"
#include "tables.cmn"

test()
{
	register char *tp = ta_clow + 128;
	char cl, c = y(1);

	cl = ta_clow[128 + c];
	x(cl);
	cl = *(ta_clow + 128 + c);
	x(cl);
	cl = tp[c];
	x(cl);
	cl = *(tp + c);
	x(cl);
	cl = ta_clow[(unsigned char) c];
	x(cl);
}
y(int x)
{
	return -1;
}
x(int c)
{
	printf("%d",c);
}
