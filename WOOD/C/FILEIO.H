#define FI_OK 0
#define FI_OPEN_ERROR 1
#define FI_IO_ERROR 2
typedef struct {
	long int end_of_file_block;
	short int protection_code;
	} file_info;
