#define FORTRAN 1
#define RATFIV 2
#define PASCAL 3
#define TEXT 4
#define C 6
#define END_OF_MAPPING -1
#define INDENT_FOLLOWS -2
#define MP_PROMPT 020
#define mp_push_region(bu,p1,p2) pu_push_region(mp_stack,bu,p1,p2)
#define mp_push_string(str) pu_push_string(mp_stack,str)
#define mp_push_character(c) pu_push_character(mp_stack,c)
#define mp_nextc(c) pu_nextc(mp_stack,c)
