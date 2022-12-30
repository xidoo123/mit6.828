# Homework8

before

```
x1do0@ubuntu:~/mit6.828/xv6$ make qemu CPUS=1
gcc -fno-pic -static -fno-builtin -fno-strict-aliasing -O2 -Wall -MD -ggdb -m32 -Werror -fno-omit-frame-pointer -fno-stack-protector -fno-pie -no-pie   -c -o uthread.o uthread.c
gcc -m32 -gdwarf-2 -Wa,-divide   -c -o uthread_switch.o uthread_switch.S
ld -m    elf_i386 -N -e main -Ttext 0 -o _uthread uthread.o uthread_switch.o ulib.o usys.o printf.o umalloc.o
objdump -S _uthread > uthread.asm
./mkfs fs.img README _cat _echo _forktest _grep _init _kill _ln _ls _mkdir _rm _sh _stressfs _usertests _wc _zombie _date _alarmtest _uthread
nmeta 59 (boot, super, log blocks 30 inode blocks 26, bitmap blocks 1) blocks 941 total 1000
balloc: first 651 blocks have been allocated
balloc: write bitmap block at sector 58
qemu-system-i386 -serial mon:stdio -nographic -drive file=fs.img,index=1,media=disk,format=raw -drive file=xv6.img,index=0,media=disk,format=raw -smp 1 -m 512
xv6...
cpu0: starting 0
sb: size 1000 nblocks 941 ninodes 200 nlog 30 logstart 2 inodestart 32 bmap start 58
init: starting sh
$ uthread
lapicid 0: panic: remap
 801069b7 8010594f 801056ec 0 0 0 0 0 0 0QEMU: Terminated
```

after 

```
init: starting sh
$ uthread
my thread running
my thread 0x2D08
my thread running
my thread 0x4D10
my thread 0x2D08
my thread 0x4D10
my thread 0x2D08
my thread 0x4D10
my thread 0x2D08
my thread 0x4D10
my thread 0x2D08
my thread 0x4D10
...
my thread 0x2D08
my thread 0x4D10
my thread: exit
my thread: exit
thread_schedule: no runnable threads
$
```