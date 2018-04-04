/*##########################################################################*/
/*                                                                          */
/* debug.h                                                                  */
/* Created on date by author                                                */
/*                                                                          */
/* Description                                                              */
/* Notes                                                                    */
/* References                                                               */
/* (If any)                                                                 */
/*                                                                          */
/*##########################################################################*/
#ifndef DEBUG_H
#define DEBUG_H

#include "color.h"

#define bool int
#define true 1
#define false 0

#define MAX_STR_LEN 1024

#ifndef DEBUG
#define DEBUG 0
#endif

#define NULL_CHECK(val)  if (val == NULL) return -1;

#define debugf(fmt, args...)\
	do { if (DEBUG) fprintf(stderr, GRN "[debug]" RESET "(%d-%s):" fmt "\n", \
			__LINE__, __func__, ##args); } while (0)

#define infof(fmt, args...)\
	do { fprintf(stderr, BLU "[info]" RESET "(%d-%s):" fmt "\n", \
			__LINE__, __func__, ##args); } while (0)


#define errorf(fmt, args...)\
	do { fprintf(stderr, RED "[error]" RESET "(%d-%s):" fmt "\n", \
			__LINE__, __func__, ##args); } while (0)

enum return_state {
	RET_FAILED,
	RET_SUCCESS,
	RET_INVALID,
};

#endif /* end of include guard: DEBUG_H */

