#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <sys/resource.h>
#include <sys/wait.h>
#include <poll.h>
#include <time.h>
#include <signal.h>

struct subproc_t{
  long int pid;
  int fd_read;
  bool running;
  int status;
  double start_time;
  double time, utime, stime;
  long maxrss;
};

extern "C" {

// create sub-process
// return true on success (struct will be valid)
bool subproc_create(char * const argv[], subproc_t *p);

// read chunk of output / check process (non blocking)
// will set running, status, utime, stime, maxrss on end of process
// return number of bytes read from process stdout (0: eof, -1: nothing to read)
int subproc_step(subproc_t *p, void *buf, size_t count, int timeout);

void subproc_kill(subproc_t *p);

// close fd_read
void subproc_close(subproc_t *p);

// clock_gettime(CLOCK_MONOTONIC, ...) in seconds
double mclock();

void set_signal_handler(void (*handler)(int));

};
