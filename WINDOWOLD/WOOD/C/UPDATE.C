enum up_operation {...}

struct {
	*up_node up_father,
	*up_node up_open,
	*up_node up_prev,
	short int up_cost,
	unsigned char up_neq,
	char up_old_pos,
	char up_new_pos,

#define up_son up_prev
