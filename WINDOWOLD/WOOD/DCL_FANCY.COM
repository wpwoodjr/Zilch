$	save_verify = 'f$verify(0)'			       !COM 28-Mar-1984
$	lo*gout :== @dcl/output='p1' 'p1' 'p2' 'p3'
$	open/read in 'p2'
$	on control_y then goto loop
$ loop:
$	read/error=read_error in line
$ 'line'
$	goto loop
$ read_error:
$	write sys$output "Error in DCL's read loop"
$	goto loop
$ done:
$	close in
$	if save_verify then set verify
