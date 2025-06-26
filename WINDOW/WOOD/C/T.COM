$ search *.rat,*.c,*.bnd mp_get_mapping,mp_pop,mp_set_mappings
$ search *.rat,*.c,*.bnd mp_minimum_indent,mp_change_mappings,mp_cancel,mp_initialize
$ search *.rat,*.c,*.bnd q_mp_empty,mp_ratfiv_block,mp_pascal_block
$ search *.rat,*.c,*.bnd q_mp_get_first_word,mp_next_procedure,mp_previous_procedure
$ search *.rat,*.c,*.bnd q_mp_next_pascal_procedure,q_mp_previous_pascal_procedure,-
q_mp_next_fortran_procedure,q_mp_previous_fortran_procedure,-
q_mp_is_fortran_eop,q_mp_next_c_procedure,q_mp_previous_c_procedure,-
q_mp_next_paragraph,q_mp_previous_paragraph,q_mp_at_comment
$ search *.rat,*.c,*.bnd mp_beginning_of_line,q_mp_read_file,q_mp_write_file
