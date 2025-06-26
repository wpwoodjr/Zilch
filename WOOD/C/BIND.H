#define NUM_MODES 10
#define NUM_MACROS 100
#define CONTROL_MODE 0
#define INSERT_MODE 1
#define OVERSTRIKE_MODE 2
#define PROMPT_MODE 3
#define CHANGE_MODE 4
#define SEQ_MODE 5
#define CALC_MODE 6
#define KEYPAD_NUMERIC 0
#define KEYPAD_APPLICATION 1

/* offset by 1 because if bi == 0, has special meaning - should modify makebind
   to put in filler at bi = 0 */
#define bi_mem(bi) bind.mem[(bi)-1]
#define bi_next(bi) bind.mem[(bi)]	/*1+(bi)]*/
#define bi_char(bi) bind.mem[1+(bi)]	/*2+(bi)]*/
#define bi_sizeof 3
