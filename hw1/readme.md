## Homework 1

This hw is intended to let us familiar with gcc x86 calling conventions, skipped.

```
x1do0@ubuntu:~/mit6.828/xv6$ nm kernel | grep _start
8010a48c D _binary_entryother_start
8010a460 D _binary_initcode_start
0010000c T _start
```

```
(gdb) info reg
eax            0x0      0
ecx            0x0      0
edx            0x1f0    496
ebx            0x10094  65684
esp            0x7bdc   0x7bdc
ebp            0x7bf8   0x7bf8
esi            0x10094  65684
edi            0x0      0
eip            0x10000c 0x10000c
eflags         0x46     [ PF ZF ]
cs             0x8      8
ss             0x10     16
ds             0x10     16
es             0x10     16
fs             0x0      0
gs             0x0      0
(gdb) x/24x $esp
0x7bdc: 0x00007db4      0x00000000      0x00000000      0x00000000
0x7bec: 0x00000000      0x00000000      0x00000000      0x00000000
0x7bfc: 0x00007c4d      0x8ec031fa      0x8ec08ed8      0xa864e4d0
0x7c0c: 0xb0fa7502      0xe464e6d1      0x7502a864      0xe6dfb0fa
0x7c1c: 0x16010f60      0x200f7c78      0xc88366c0      0xc0220f01
0x7c2c: 0x087c31ea      0x10b86600      0x8ed88e00      0x66d08ec0
```
