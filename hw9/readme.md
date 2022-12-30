# Homework9

before

```
x1do0@ubuntu:~/mit6.828/hw9$ ./a.out 2
a.out: barrier.c:42: thread: Assertion `i == t' failed.
Aborted
```

after 

```
x1do0@ubuntu:~/mit6.828/hw9$ gcc -g -O2 -pthread barrier.c
x1do0@ubuntu:~/mit6.828/hw9$ ./a.out 2
OK; passed
x1do0@ubuntu:~/mit6.828/hw9$ ./a.out 1
OK; passed
x1do0@ubuntu:~/mit6.828/hw9$ ./a.out 4
OK; passed
```
