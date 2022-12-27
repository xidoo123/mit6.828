## Homework 3


change these files 

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

look at this commit:

https://github.com/xidoo123/mit6.828/commit/a066df8b15972fbe0b27ef50e39128d0a07bcfdd