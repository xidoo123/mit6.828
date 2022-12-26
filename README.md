# mit6.828

Looking for answers all the time makes one miss the most intersting part, but having an answer for reference definitely make life easier. 


## lab1

In this lab, grader will check two functions

* octal part of printf implementation

* backtrace implementation

Result:

```
x1do0@ubuntu:~/mit6.828/lab$ make grade
make clean
make[1]: Entering directory '/home/x1do0/mit6.828/lab'
rm -rf obj .gdbinit jos.in qemu.log
make[1]: Leaving directory '/home/x1do0/mit6.828/lab'
./grade-lab1
make[1]: Entering directory '/home/x1do0/mit6.828/lab'
+ as kern/entry.S
+ cc kern/entrypgdir.c
+ cc kern/init.c
+ cc kern/console.c
+ cc kern/monitor.c
+ cc kern/printf.c
+ cc kern/kdebug.c
+ cc lib/printfmt.c
+ cc lib/readline.c
+ cc lib/string.c
+ ld obj/kern/kernel
ld: warning: section `.bss' type changed to PROGBITS
+ as boot/boot.S
+ cc -Os boot/main.c
+ ld boot/boot
boot block is 390 bytes (max 510)
+ mk obj/kern/kernel.img
make[1]: Leaving directory '/home/x1do0/mit6.828/lab'
running JOS: (0.4s)
  printf: OK
  backtrace count: OK
  backtrace arguments: OK
  backtrace symbols: OK
  backtrace lines: OK
Score: 50/50
```


### exercise 12

LD script sytax: https://users.informatik.haw-hamburg.de/~krabat/FH-Labor/gnupro/5_GNUPro_Utilities/c_Using_LD/ldLinker_scripts.html#Concepts




## lab2

### `boot_alloc`

we can print out what exactly the magic `end` are

```c
// create initial page directory.
kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
memset(kern_pgdir, 0, PGSIZE);

cprintf("[?] %x\n", kern_pgdir);

//////////////////////////////////////////////////////////////////////
// Recursively insert PD in itself as a page table, to form
// a virtual page table at virtual address UVPT.
// (For now, you don't have understand the greater purpose of the
// following line.)

// Permissions: kernel R, user R
kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;

//////////////////////////////////////////////////////////////////////
// Allocate an array of npages 'struct PageInfo's and store it in 'pages'.
// The kernel uses this array to keep track of physical pages: for
// each physical page, there is a corresponding struct PageInfo in this
// array.  'npages' is the number of physical pages in memory.  Use memset
// to initialize all fields of each struct PageInfo to 0.
// Your code goes here:

n = npages * sizeof(struct PageInfo);
pages = (struct PageInfo *) boot_alloc(n);
memset(pages, 0, n);

cprintf("[?] %x\n", pages);
```

According to `memlayout.h`, this is in the Remapped Physical Memory region

```
[?] f0114000
[?] f0115000
```

So I guess out-of-memory panic in `boot_alloc` should look like this:

```c
if (nextfree > 0xffffffff - n)
  panic("boot_alloc: out of memory\n");
```

### `page_init`

If the physical address is in use, we set `pp_ref` to 1, make `pp_link` point to null and don't update `page_free_list`.

```c
pages[0].pp_ref = 1;
pages[0].pp_link = 0;
```

If the physical address is free, do these like the original example.

```c
pages[i].pp_ref = 0;
pages[i].pp_link = page_free_list;
page_free_list = &pages[i];
```

When I try to print out these variables, I find two of them are the same.

```c
cprintf("[?] %d, %d, %d\n", npages_basemem, IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE);
// [?] 160, 160, 256
```

Not sure if this is expected, because I don't know anything about hardware (`npages_basemem` read from `mc146818_read`).

For the last part, we need to identify whether the physical memory above `EXTPHYSMEM` is in use. We need to first find out how large the Remapped Physical Memory is because what we have done changed the size of this region

```c
cprintf("[?] %d\n", PADDR(boot_alloc(0)) / PGSIZE);
// [?] 341
```

The next question is whether all the region from `EXTPHYSMEM` to here is all in use. I have no idea atm.

After finishing this part, we will see there is one check pass.

```
check_page_free_list() succeeded!
```

