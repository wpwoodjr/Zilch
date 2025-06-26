/*	Zilch Screen Editor,
 *	Copyright (c) 1982,1986,1987 William P. Wood, Jr. */

#include "symbols.h"
#include "session.cmn"
#include "memory.cmn"

static char name[FILENAMESIZE];

static int q_ch_name(bufferp bu, char *name)
{
  if (bu_file_name(bu) == null)
    return q_ch_gen_name(st_buffer(bu_name(bu)),name);
  else
    return q_ch_gen_name(st_buffer(bu_file_name(bu)),name);
}

static int q_ch_gen_name(const char *buname, char *chname)
{
  int i, len;

  i = ho_length(buname);
  len = min(77, i);
  chname[0] = '$';
  movc(buname+max(0, i - len), chname+1, len);
  len++;
  if (len <= 39)
    chname[len] = '.';
  else
    movc(chname+39, chname+40, len-39);
  len++;
  chname[len] = EOS;
  for (i = 1; i < len; i++)
    if (i == 39)
      chname[i] = '.';
    else if (!isalnum(chname[i]) && chname[i] != '$' && chname[i] != '_' &&
		chname[i] != '-')
      chname[i] = '_';
  return ! q_ho_equal(buname+ho_indexq(buname, ']'), chname);
}

static int q_ch_buffer(bufferp bu)
{
  int modif, status, stat;

  if (bu_modified(bu) == 3)
    status = true;
  else {
    status = q_ch_name(bu, name);
    if (status) {
      modif = bu_modified(bu);
      status = q_mp_write_file(bu, name, 'U', &stat);
      if (status && mod(modif, 2) == 1)
	bu_modified(bu) = 3;		/* up-to-date checkpoint file exists */
      else
	bu_modified(bu) = modif;
      }
    }
  return status;
}

void checkpoint_modified_files(void)
{
  bufferp bu;
  int nch;

  nch = 0;
  bu_map(se_buffers,bu)
    if (bu_modified(bu) == 1 && bu_file_name(bu) != null)
      if (q_ch_buffer(bu))
	nch = nch + 1;
      else {
	ms_message2("Error checkpointing buffer ",bu_name(bu));
	ms_error("");
	}
  if (nch > 0)
    ms_report_number2("Checkpointed ", nch, " file.", " files.");
}

void ch_delete(bufferp bu)
{
  if (q_ch_name(bu, name)) {
    q_fi_delete(WRITE_UNIT,name);
    if (bu_modified(bu) == 3)		/* up-to-date checkpoint file exists */
      bu_modified(bu) = 1;
    }
}

int q_ch_recover(bufferp bu)
{
  if (q_ch_name(bu, name))
    if (q_mp_read_file(bu,name,0,false)) {
      ms_message2("Recovered ",bu_file_name(bu));
      ms_add_to_message(" from ");
      ms_add_to_message(name);
      bu_modified(bu) = 3;		/* up-to-date checkpoint file exists */
      return true;
      }
  return false;
}
