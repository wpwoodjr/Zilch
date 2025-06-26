#if VMS				/* VMS is predefined by VMS C */
# define TURBOC 0
# define MSDOS 0
#else
# define TURBOC 1
# define MSDOS 1
#endif

#ifdef initialize		/* allocating storage in EXTERN.C */
#define declare
#else				/* otherwise just declaring the storage */
#define declare extern
#endif

typedef long int intp;		/* data type of pointers into memory */
typedef intp stringp;		/* pointer to strings */
typedef intp bufferp;		/* pointer to buffers */
typedef intp windowp;		/* pointer to windows */
typedef intp pagep;		/* pointer to pages */
typedef intp markp;		/* pointer to marks */
typedef intp textp;		/* pointer to text in text buffer */
typedef long int textind;	/* index into text buffer */

#if VAX
#define SCREEN_SIZE 52		/* max screen length */
#define SCREEN_WIDTH 132	/* max screen width */
#define MAX_PROMPT 513
#define MAX_COMMAND 513
#endif
#if MSDOS
#define SCREEN_SIZE 25		/* max screen length */
#define SCREEN_WIDTH 80		/* max screen width */
#define MAX_PROMPT 129
#define MAX_COMMAND 129
#endif
#define EOS '\0'
#define ARB 1
#define CR 015
#define LF 012
#define NEWLINE 012
#define TAB 011
#define CONTROL_U 025
#define CONTROL_Q 021
#define RUBOUT 0177
#define CHARS_PER_INT sizeof(intp)
#define MAXINT 0x7fffffffL
#define MACRO_SIZE 512
#define MAX_MACROS 10
/* #define EOF -10 */
#define RECORDTOOLONG -40
#define READ_UNIT 1
#define WRITE_UNIT 2
#define FIND_UNIT 3
#define false 0
#define true 1
#define null 0

#include <stddef.h>
#include "proto.h"
#include "protoasm.h"		/* Assembler, or Macro, routine prototypes */
#include "session.h"
#include "buffer.h"
#include "window.h"
#include "bind.h"
#include "screen.h"
#include "page.h"
#include "mappings.h"
#include "mark.h"
#include "fileio.h"
#include "text.h"
/*include "[.seq]seq.sym" */

#ifndef abs
#define abs(x) ((x) < 0 ? -(x) : (x))
#endif
#ifndef min
#define min(x, y) ((x) < (y) ? (x) : (y))
#endif
#ifndef max
#define max(x, y) ((x) > (y) ? (x) : (y))
#endif
#define mod(x, y) ((x) % (y))

#ifdef VMS
#define EXIT_GOOD 1
#define EXIT_BAD 2
#define NODESIZE 256
#define DEVSIZE 256
#define UICSIZE 256
#define NAMESIZE 256
#define EXTSIZE 41
#define VERSIZE 7
#define FILENAMESIZE 256
#endif

#ifdef MSDOS
#define EXIT_GOOD 0
#define EXIT_BAD 1
#define NODESIZE 1
#define DEVSIZE 3
#define UICSIZE 61
#define NAMESIZE 9
#define EXTSIZE 5
#define VERSIZE 1
#define FILENAMESIZE 75
#endif
