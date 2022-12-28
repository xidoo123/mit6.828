## Homework5

Recall in hw3, we need to change these files to add syscall

```
x1do0@ubuntu:~/mit6.828/xv6$ grep -n uptime *.[chS]
syscall.c:105:extern int sys_uptime(void);
syscall.c:121:[SYS_uptime]  sys_uptime,
syscall.c:145:[SYS_uptime]  "uptime",
syscall.h:15:#define SYS_uptime 14
sysproc.c:83:sys_uptime(void)
user.h:25:int uptime(void);
usys.S:31:SYSCALL(uptime)
```

Tick time on my computer seems to be bit slower, so I changed `main` in alarmtest.c to achieve better results.

```c
main(int argc, char *argv[])
{
  int i;
  printf(1, "alarmtest starting\n");

  alarm(10, periodic);
  for(i = 0; i < 25*500000*50; i++){
    if((i % 2500000) == 0)
      write(2, ".", 1);
  }
  exit();
}
```

Result:

```
$ alarmtest
alarmtest starting
..............alarm!
..................alarm!
..................alarm!
..................alarm!
................alarm!
...................alarm!
..............alarm!
......................alarm!
...................alarm!
.........alarm!
..............alarm!
........................alarm!
..................alarm!
...............alarm!
............alarm!
$
```