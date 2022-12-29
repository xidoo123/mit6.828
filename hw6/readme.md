# Homework6

Missing key due to race condition between two threads, as in when A thread and B thread do  `insert` in the meantime, consistence of the link list will break. Check the slides for more explaination. Original result:

```
x1do0@ubuntu:~/mit6.828/hw6$  gcc -g -O2 ph.c -pthread
x1do0@ubuntu:~/mit6.828/hw6$ ./a.out 2
0: put time = 0.008527
1: put time = 0.008930
1: get time = 5.636540
1: 16304 keys missing
0: get time = 5.844841
0: 16304 keys missing
completion time = 5.854307
x1do0@ubuntu:~/mit6.828/hw6$ ./a.out 1
0: put time = 0.005713
0: get time = 5.927066
0: 0 keys missing
completion time = 5.932929
```

adding lock in `insert` and `get`

```
x1do0@ubuntu:~/mit6.828/hw6$ ./a.out 2
0: put time = 0.010270
1: put time = 0.011275
1: get time = 11.334690
1: 0 keys missing
0: get time = 11.444454
0: 0 keys missing
completion time = 11.456196
```

only adding lock in `insert`, we achieve good results. Because there is only read operation in `get` function, will not affect consistence of this link list.

```
x1do0@ubuntu:~/mit6.828/hw6$ ./a.out 2
1: put time = 0.009280
0: put time = 0.011623
0: get time = 5.559373
0: 0 keys missing
1: get time = 5.597156
1: 0 keys missing
completion time = 5.609483
```