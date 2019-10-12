
#include "libbenchmark.hpp"

subproc_t *h_subproc = NULL;

bool subproc_create(char * const argv[], subproc_t *p)
{
  int fd_pipe[2];
  if(pipe(fd_pipe) != 0)
    return false;

  p->fd_read = fd_pipe[0];

  pid_t pid = fork();
  if(pid < 0){ // error
    close(fd_pipe[0]);
    close(fd_pipe[1]);
    return false;
  }
  else if(pid == 0){ // child
    close(fd_pipe[0]); // close copied read pipe
    dup2(fd_pipe[1], STDOUT_FILENO); // replace default stdout by write pipe
    execvp(*argv, argv); // replace process by command
    // only reached on error
    perror("execvp");
    exit(1);
  }
  else{ // parent
    close(fd_pipe[1]);
    p->pid = pid;
    p->running = true;
    p->start_time = mclock();
  }

  return true;
}

int subproc_step(subproc_t *p, void *buf, size_t count, int timeout)
{
  // check end and fill resource usage data
  rusage rdata;
  if(p->running && wait4(p->pid, &p->status, WNOHANG, &rdata) == p->pid){
    p->running = false;
    p->maxrss = rdata.ru_maxrss;
    p->utime = rdata.ru_utime.tv_usec*1e-6+rdata.ru_utime.tv_sec;
    p->stime = rdata.ru_stime.tv_usec*1e-6+rdata.ru_stime.tv_sec;
  }

  // read
  pollfd pfd;
  pfd.fd = p->fd_read;
  pfd.events = POLLIN;

  int n = -1;
  if(poll(&pfd,1,timeout) > 0)
    n = read(p->fd_read, buf, count);

  return n;
}

void subproc_kill(subproc_t *p)
{
  kill(p->pid, SIGKILL);
}

void subproc_close(subproc_t *p)
{
  close(p->fd_read);
}

double mclock()
{
  timespec t;
  if(clock_gettime(CLOCK_MONOTONIC, &t) == 0)
    return t.tv_nsec*1e-9+t.tv_sec;
  else
    return -1;
}

void subproc_signal_handler(int signum)
{
  if(h_subproc)
    h_subproc->time = mclock()-h_subproc->start_time;
}

void bind_signal_handler(subproc_t *p)
{
  h_subproc = p;
  struct sigaction act;

  /* Set up the structure to specify the new action. */
  act.sa_handler = subproc_signal_handler;
  sigemptyset(&act.sa_mask);
  act.sa_flags = 0;
  sigaction(SIGCHLD, &act, NULL);
}
