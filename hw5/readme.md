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