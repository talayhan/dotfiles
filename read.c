#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>

#include <sys/stat.h>
#include <sys/types.h>
#include <signal.h>

#include <sys/file.h> /*for BSD flock*/
/*
 *BSD lock Features:
 *
 *    not specified in POSIX, but widely available on various Unix systems
 *    always lock the entire file
 *    associated with a file object
 *    do not guarantee atomic switch between the locking modes (exclusive and shared)
 *    up to Linux 2.6.11, didn’t work on NFS; since Linux 2.6.12, flock() locks on NFS
 *    are emulated using fcntl() POSIX record byte-range locks on the entire file
 *    (unless the emulation is disabled in the NFS mount options)
 */

/*
 *These locks are associated with a file object, i.e.:
 *
 *    duplicated file descriptors, e.g. created using dup2 or fork, refer to the same lock
 *    distinct file descriptors, e.g. created using two open calls (even for the same file), refer to different locks
 *
 *    @NOTE: However, flock() DOESN’T GUARANTEE atomic mode switch.
 */

#include <fcntl.h> /*for POSIX lock*/
/*
 *POSIX record locks (fcntl)
 *
 * POSIX record locks, also known as process-associated locks, are provided by fcntl(2),
 * see “Advisory record locking” section in the man page.
 *
 *Features:
 *
 *    specified in POSIX (base standard)
 *    can be applied to a byte range
 *    associated with an [i-node, pid] pair instead of a file object
 *    guarantee atomic switch between the locking modes (exclusive and shared)
 *    work on NFS (on Linux)
 *
 */

/*local incldues*/
/*#include "debug.h"*/

#define DAT_FILE_NAME "file.dat"

static int usr_interrupt = 0;
static int dont_read_anymore = 1;

void signal_handler(int signum) {
	switch (signum) {
		case SIGUSR1:
			printf("[%s-%d]Caught SIGUSR1\n", __func__, __LINE__);
			usr_interrupt = 1;
			break;
		case SIGUSR2:
			printf("[%s-%d]Caught SIGUSR2\n", __func__, __LINE__);
			dont_read_anymore = 0;
			break;
		case SIGKILL:
			printf("[%s-%d]Caught SIGKILL\n", __func__, __LINE__);
			break;
		default:
			printf("[%s-%d]We dont care this type of signal\n", __func__, __LINE__);
	}
}

static int num_of_lines(FILE *fp) {
	char ch = '\0';
	int count = 0;
	do {
		ch = fgetc(fp);
		if(ch == '\n') count++;
	} while(ch != EOF);
	rewind(fp); // do not forget to rewind
	printf("Total number of lines %d\n", count);

	return count;
}

int main(int argc, char *argv[])
{
	int ret = 0;
	int fd;
	FILE *fp = NULL;

	sigset_t sigset;
	struct sigaction sact;

	sigset_t mask, oldmask;

	sigemptyset(&sact.sa_mask);
	sact.sa_flags = 0;
	sact.sa_handler = signal_handler;

	if (sigaction(SIGUSR1, &sact, NULL) != 0)
		perror("1st sigaction() error");

	if (sigaction(SIGUSR2, &sact, NULL) != 0)
		perror("1st sigaction() error");

	if (sigaction(SIGUSR2, &sact, NULL) != 0)
		perror("1st sigaction() error");
	/*TODO handle SIGKILL here etc.*/

	printf("[%s-%d]getpid()=%d\n", __func__, __LINE__, getpid());

	int numl = 0;
	char line[256] = {0};

	fp = fopen(DAT_FILE_NAME, "r");
	if (fp == NULL) {
		printf("[%s-%d]open failed![%d-%s]\n", __func__, __LINE__, errno, strerror(errno));
		if (errno == ENOENT) {
			/* Set up the mask of signals to temporarily block. */
			sigemptyset (&mask);
			sigaddset (&mask, SIGUSR1);

			printf("[%s-%d]ENOENT - file doesn't exist! wait a signal to go.\n", __func__, __LINE__);
			/* Wait for a signal to arrive. */
			sigprocmask (SIG_BLOCK, &mask, &oldmask);
			while (!usr_interrupt) {
				printf("[%s-%d]enter\n", __func__, __LINE__);
				sigsuspend (&oldmask);
			}
			sigprocmask (SIG_UNBLOCK, &mask, NULL);
		}
		goto out;
	}

	/*get integer description*/
	fd = fileno(fp);
	if (fd < 0) {
		printf("[%s-%d]fileno failed![%d-%s]\n", __func__, __LINE__, errno, strerror(errno));
		goto out;
	}

	printf("[%s-%d]fd=%d\n", __func__, __LINE__, fd);

	do {
		dont_read_anymore = 1;

		/*acquire lock*/
		ret = flock(fd, LOCK_EX);
		if (ret != 0) {
			printf("[%s-%d]acquire lock failed![%d-%s]\n", __func__, __LINE__, errno, strerror(errno));
			goto out;
		} else {
			printf("[%s-%d]acquire lock\n", __func__, __LINE__);
		}

		/*detect total number of lines*/
		numl = num_of_lines(fp);
		if (numl > 0) {
			;
			/*ret = fread(line, sizeof *line, 256, fp);*/
			if (fgets(line, 255, fp) == NULL) {
				printf("[%s-%d]fgets failed![%d-%s]\n", __func__, __LINE__, errno, strerror(errno));
			} else {
				printf("[%s-%d]Read = %s\n", __func__, __LINE__, line);
			}
		} else {
			/* Set up the mask of signals to temporarily block. */
			sigemptyset (&mask);
			sigaddset (&mask, SIGUSR2);

			/* Wait for a signal to arrive but first release lock. */
			ret = flock(fd, LOCK_UN);
			if (ret != 0) {
				printf("[%s-%d]flock failed![%d-%s]\n", __func__, __LINE__, errno, strerror(errno));
				goto out;
			} else {
				printf("[%s-%d]release lock\n", __func__, __LINE__);
			}
			printf("[%s-%d]wait for a signal to put new helllo[%d-%s]\n", __func__, __LINE__, errno, strerror(errno));
			printf("[%s-%d]dont_read_anymore=%d\n", __func__, __LINE__, dont_read_anymore);
			sigprocmask (SIG_BLOCK, &mask, &oldmask);
			while (dont_read_anymore) {
				printf("[%s-%d]enter\n", __func__, __LINE__);
				sigsuspend (&oldmask);
			}
			sigprocmask (SIG_UNBLOCK, &mask, NULL);
		}

		/*release lock*/
		ret = flock(fd, LOCK_UN);
		if (ret != 0) {
			printf("[%s-%d]release lock failed![%d-%s]\n", __func__, __LINE__, errno, strerror(errno));
			goto out;
		} else {
			printf("[%s-%d]release lock\n", __func__, __LINE__);
		}

		sleep(1);
	} while (1);

out:
	/*release lock*/
	ret = flock(fd, LOCK_UN);
	if (ret != 0) {
		printf("[%s-%d]release lock failed![%d-%s]\n", __func__, __LINE__, errno, strerror(errno));
	}

	if (fp != NULL) {
		fclose(fp);
	}
	return ret;
}
