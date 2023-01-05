# Homework 12


```
x1do0@ubuntu:~/mit6.828/hw12$ ./mmap
page_size is 4096
Validating square root table contents...
oops got SIGSEGV at 0x7f14ba46cf18
```

Detect whether a page is already mmaped: https://stackoverflow.com/questions/8362747/how-can-i-detect-whether-a-specific-page-is-mapped-in-memory. Not sure if it actually works.



```
...
oops got SIGSEGV 250455 at 0x7f2793128000
-1
Calculating at 0x7f2793128000
Try to calculate at 0x7fff0dae5940
Try to calculate at 0x7fff0dae5940
oops got SIGSEGV 250456 at 0x7f2769f24000
-1
Calculating at 0x7f2769f24000
Try to calculate at 0x7fff0dae5940
All tests passed!
```

