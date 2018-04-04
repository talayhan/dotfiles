#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>

#include <sys/stat.h>
#include <sys/types.h>
#include <sys/wait.h>
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
#include "debug.h"

/*#endif*/
#define DAT_FILE_NAME "file.dat"

/*
 * @NOTE:
 * Use sigaction instead of signal,
 *
 *    The signal() function does not (necessarily) block other signals from
 *    arriving while the current handler is executing; sigaction() can block
 *    other signals until the current handler returns.
 *
 *    The signal() function (usually) resets the signal action back to SIG_DFL
 *    (default) for almost all signals. This means that the signal() handler must
 *    reinstall itself as its first action. It also opens up a window of
 *    vulnerability between the time when the signal is detected and the handler
 *    is reinstalled during which if a second instance of the signal arrives, the
 *    default behaviour (usually terminate, sometimes with prejudice - aka core
 *    dump) occurs.
 *
 *    The exact behaviour of signal() varies between systems — and the standards
 *    permit those variations.
 *
 */

void signal_handler(int signum) {
	switch (signum) {
		case SIGUSR1:
			debugf("Caught SIGUSR1");
			break;
		case SIGUSR2:
			debugf("Caught SIGUSR2");
			break;
		case SIGINT: /*ctrl+c*/
			debugf("Caught SIGINT");
			break;
		default:
			errorf("We dont care this type of signal");
	}
}

int main(int argc, char *argv[])
{
	int ret;
	int pid;

	sigset_t sigset;
	struct sigaction sact;

	debugf("my pid=%d", getpid());

	sigemptyset(&sact.sa_mask);
	sact.sa_flags = 0;
	sact.sa_handler = signal_handler;
	if (sigaction(SIGUSR1, &sact, NULL) != 0)
		perror("1st sigaction() error");

	if (sigaction(SIGUSR2, &sact, NULL) != 0)
		perror("1st sigaction() error");

	if (sigaction(SIGINT, &sact, NULL) != 0)
		perror("1st sigaction() error");

	ret = fork();
	if (ret == 0) {
		debugf("Running child = %d", getpid());
		sleep(1);
		debugf("Ending child = %d", getpid());
	} else {
		debugf("Running Parent = %d", getpid());
		wait(NULL);
		debugf("Ending Parent = %d", getpid());
	}

	return 0;
}

