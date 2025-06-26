/*	Zilch Screen Editor,
 *	Copyright (c) 1982,1983,1984,1986,1987 William P. Wood, Jr. */

#include <stdlib.h>
#include "symbols.h"
#include "memory.cmn"
#include "session.cmn"
#include "screen.cmn"

#if VMS
#include "descr.h"
static vms_char_descr(d_sys$command, "SYS$COMMAND", sizeof("SYS$COMMAND")-1);
static int pid = 0;

void dcl_call(void)
{
  char process_name[16];
  static char spawn_cmd[] = "$ lo*goff := attach/id=xxxxxxxx";
  vms_char_descr(d_spawn_cmd, spawn_cmd, sizeof(spawn_cmd)-1);
  long int plen, curpid, biocnt, bytcnt, astcnt;
  int status;

  ms_message("");
  sc_update(&zero);
  te_finish();
  te_pos(sc_size,1);
  ti_flush();
  ti_finish();
  if (pid != 0)
    if (! lib$attach(&pid))
      pid = 0;
  if (pid == 0) {
    plen = sizeof(process_name);
    status = get_process_info(process_name, &plen, &curpid,
						  &biocnt, &bytcnt, &astcnt);
    if (status) {
      sprintf(spawn_cmd + 23, "%08x", curpid);
      status = lib$spawn(&d_spawn_cmd,&d_sys$command,&d_sys$command,0,0,&pid);
      if (! status) {
	ms_report_number(
"Error number ", status, " occurred while trying to spawn a subprocess.");
	ms_error("");
	}
      }
    else {
      ms_report_number(
"Error number ", status, " occurred while trying to get process information.");
      ms_error("");
      }
    }
  ti_initialize();
  redraw();
}

void dcl_finish(void)
{
  if (pid != 0)
    sys$delprc(&pid, 0);
}

long int get_process_info(char *process_name,long int *plen,long int *pid,long int *biocnt,long int *bytcnt,long int *astcnt)
{
# include <jpidef.h>
  long int jpibuf[16];
  int status;

  jpibuf[0] = JPI$_PRCNAM << 16 | *plen - 1;
  *plen = 0;
  jpibuf[1] = process_name;
  jpibuf[2] = plen;
  jpibuf[3] = JPI$_PID << 16 | 4;
  jpibuf[4] = pid;
  jpibuf[5] = 0;
  jpibuf[6] = JPI$_BIOCNT << 16 | 4;
  jpibuf[7] = biocnt;
  jpibuf[8] = 0;
  jpibuf[9] = JPI$_BYTCNT << 16 | 4;
  jpibuf[10] = bytcnt;
  jpibuf[11] = 0;
  jpibuf[12] = JPI$_ASTCNT << 16 | 4;
  jpibuf[13] = astcnt;
  jpibuf[14] = 0;
  jpibuf[15] = 0;

  status = sys$getjpi(0,0,0,jpibuf,0,0,0);
  if (status)
    process_name[*plen] = EOS;
  return status;
}
#endif

#if MSDOS
#include <process.h>

void dcl_call(void)
{
  char *command;

  command = getenv("COMSPEC");
  if (command != 0) {
    te_finish();
    te_pos(sc_size,1);
    ti_flush();
    ti_finish();
    spawnlp(P_WAIT, command, command, NULL);
    ti_initialize();
    redraw();
    }
  else
    ms_error("Couldn't get value of COMSPEC environment variable!");
}

void dcl_finish(void)
{
}

static int msdos_spawn(const char *cmd, const char *file)
{
  char *command;
  int lc;

  lc = ho_length(cmd);
  if (lc == 0) {
    cmd = getenv("COMSPEC");
    if (cmd != 0)
      lc = ho_length(cmd);
    else
      ms_error("Couldn't get value of COMSPEC environment variable!");
    }
  if (lc != 0) {
    command = malloc(lc + ho_length(file) + 3);
    if (command != NULL) {
      ho_scopy(cmd, 1, command, 1);
      strcat(command, " >");
      strcat(command, file);
      system(command);
      free(command);
      return 1;
      }
    else
      ms_error("Couldn't allocate memory for command!");
    }
  return 0;
}
#endif

void dcl_xcall(void)
{
# include "terminal.cmn"
  int i, size, len, status;
  stringp st = st_allocate(MAX_PROMPT);

# if VMS
  windowp wi = se_current_window;
  vms_char_descr(d_st, st_buffer(st), MAX_PROMPT-1);
  static char zilchlog[] = "sys$login:zilch.log";
  vms_char_descr(d_zilchlog, zilchlog, sizeof(zilchlog)-1);
  static char cli_prompt[] = "$ ";
  char mbx_trans_name[63];
  vms_char_descr(d_mbx_trans_name, mbx_trans_name, 63);
  vms_char_descr(d_mbx_name, mbx.name, sizeof(mbx.name)-1);
  vms_char_descr(d_nl, "nl:", sizeof("nl:")-1);
# endif

# if MSDOS
  static char zilchlog[] = "\\zilch.log";
# include <dir.h>
  char cli_prompt[FILENAMESIZE+2];
  if (getcwd(cli_prompt, FILENAMESIZE) == NULL)
    ho_scopy("> ", 1, cli_prompt, 1);
  else
    strcat(cli_prompt, "> ");
# endif

  if (q_pr_read_prompt(cli_prompt,st,&len))
    if (q_bu_find_window("Session log")) {
      mp_set_mappings(se_current_buffer, TEXT);
      size = bu_size(se_current_buffer);
      wi_dot(se_current_window) = size + 1;
      line_to_top_of_window();
      insert_string(cli_prompt);
      for (i = st; i < st+len; )
	insert_character(*st_buffer(i++));
# if VMS
      if (len > 0) {
	set_vms_char_descr_len(d_st, len);
	if (mbx.channel != 0) {
	  icr_trnlog_str(&d_mbx_name, &d_mbx_trans_name);
	  status = lib$spawn(&d_st, &d_nl, &d_mbx_trans_name, &1);
	  }
	else {
	  sc_update(&zero);
	  status = lib$spawn(&d_st, &d_nl, &d_zilchlog);
	  }
	insert_character(NEWLINE);
	}
      else {
# endif
	sc_update(&zero);
	te_finish();
	te_pos(sc_size,1);
	ti_flush();
	ti_finish();
# if VMS
	status = lib$spawn(0, &d_sys$command, &d_zilchlog);
# endif
# if MSDOS
	insert_character(NEWLINE);
	status = msdos_spawn(st_buffer(st), zilchlog);
# endif
	ti_initialize();
	redraw();
# if VMS
	}
# endif
      if (! status) {
	ms_report_number(
    "Error number ", status, " occurred while trying to spawn a subprocess.");
	ms_error("");
	}
# if VMS
      else if (mbx.channel != 0 && len > 0)
	;
# endif
      else if (! q_mp_read_file(se_current_buffer,zilchlog,
					bu_size(se_current_buffer)+1, false)) {
	ms_message("Can't read ");
	ms_add_to_message(zilchlog);
	ms_error("");
	}
      else
	q_fi_delete(WRITE_UNIT, zilchlog);
      bu_modified(se_current_buffer) = 0;
      wi_dot(se_current_window) = size + 1;
      line_to_top_of_window();
# if VMS
      if (mbx.channel != 0 && len > 0)
	while (se_current_window != wi)
	  next_window();
# endif
      }
  st_deallocate(st);
}
