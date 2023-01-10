
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 10 12 00       	mov    $0x121000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 10 12 f0       	mov    $0xf0121000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 5c 00 00 00       	call   f010009a <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100048:	83 3d 8c ae 2a f0 00 	cmpl   $0x0,0xf02aae8c
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 8c ae 2a f0    	mov    %esi,0xf02aae8c

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 75 5d 00 00       	call   f0105dd6 <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 e0 6b 10 f0       	push   $0xf0106be0
f010006d:	e8 10 39 00 00       	call   f0103982 <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 e0 38 00 00       	call   f010395c <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 f9 74 10 f0 	movl   $0xf01074f9,(%esp)
f0100083:	e8 fa 38 00 00       	call   f0103982 <cprintf>
	va_end(ap);
f0100088:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010008b:	83 ec 0c             	sub    $0xc,%esp
f010008e:	6a 00                	push   $0x0
f0100090:	e8 1c 09 00 00       	call   f01009b1 <monitor>
f0100095:	83 c4 10             	add    $0x10,%esp
f0100098:	eb f1                	jmp    f010008b <_panic+0x4b>

f010009a <i386_init>:
static void boot_aps(void);


void
i386_init(void)
{
f010009a:	55                   	push   %ebp
f010009b:	89 e5                	mov    %esp,%ebp
f010009d:	53                   	push   %ebx
f010009e:	83 ec 04             	sub    $0x4,%esp
	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000a1:	e8 a0 05 00 00       	call   f0100646 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000a6:	83 ec 08             	sub    $0x8,%esp
f01000a9:	68 ac 1a 00 00       	push   $0x1aac
f01000ae:	68 4c 6c 10 f0       	push   $0xf0106c4c
f01000b3:	e8 ca 38 00 00       	call   f0103982 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000b8:	e8 b7 14 00 00       	call   f0101574 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000bd:	e8 21 31 00 00       	call   f01031e3 <env_init>
	trap_init();
f01000c2:	e8 ae 39 00 00       	call   f0103a75 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000c7:	e8 00 5a 00 00       	call   f0105acc <mp_init>
	lapic_init();
f01000cc:	e8 20 5d 00 00       	call   f0105df1 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000d1:	e8 bd 37 00 00       	call   f0103893 <pic_init>

	// Lab 6 hardware initialization functions
	time_init();
f01000d6:	e8 11 68 00 00       	call   f01068ec <time_init>
	pci_init();
f01000db:	e8 ec 67 00 00       	call   f01068cc <pci_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000e0:	c7 04 24 c0 33 12 f0 	movl   $0xf01233c0,(%esp)
f01000e7:	e8 58 5f 00 00       	call   f0106044 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000ec:	83 c4 10             	add    $0x10,%esp
f01000ef:	83 3d 94 ae 2a f0 07 	cmpl   $0x7,0xf02aae94
f01000f6:	77 16                	ja     f010010e <i386_init+0x74>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01000f8:	68 00 70 00 00       	push   $0x7000
f01000fd:	68 04 6c 10 f0       	push   $0xf0106c04
f0100102:	6a 66                	push   $0x66
f0100104:	68 67 6c 10 f0       	push   $0xf0106c67
f0100109:	e8 32 ff ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f010010e:	83 ec 04             	sub    $0x4,%esp
f0100111:	b8 32 5a 10 f0       	mov    $0xf0105a32,%eax
f0100116:	2d b8 59 10 f0       	sub    $0xf01059b8,%eax
f010011b:	50                   	push   %eax
f010011c:	68 b8 59 10 f0       	push   $0xf01059b8
f0100121:	68 00 70 00 f0       	push   $0xf0007000
f0100126:	e8 d8 56 00 00       	call   f0105803 <memmove>
f010012b:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010012e:	bb 20 b0 2a f0       	mov    $0xf02ab020,%ebx
f0100133:	eb 4d                	jmp    f0100182 <i386_init+0xe8>
		if (c == cpus + cpunum())  // We've started already.
f0100135:	e8 9c 5c 00 00       	call   f0105dd6 <cpunum>
f010013a:	6b c0 74             	imul   $0x74,%eax,%eax
f010013d:	05 20 b0 2a f0       	add    $0xf02ab020,%eax
f0100142:	39 c3                	cmp    %eax,%ebx
f0100144:	74 39                	je     f010017f <i386_init+0xe5>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100146:	89 d8                	mov    %ebx,%eax
f0100148:	2d 20 b0 2a f0       	sub    $0xf02ab020,%eax
f010014d:	c1 f8 02             	sar    $0x2,%eax
f0100150:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100156:	c1 e0 0f             	shl    $0xf,%eax
f0100159:	05 00 40 2b f0       	add    $0xf02b4000,%eax
f010015e:	a3 90 ae 2a f0       	mov    %eax,0xf02aae90
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100163:	83 ec 08             	sub    $0x8,%esp
f0100166:	68 00 70 00 00       	push   $0x7000
f010016b:	0f b6 03             	movzbl (%ebx),%eax
f010016e:	50                   	push   %eax
f010016f:	e8 cb 5d 00 00       	call   f0105f3f <lapic_startap>
f0100174:	83 c4 10             	add    $0x10,%esp
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f0100177:	8b 43 04             	mov    0x4(%ebx),%eax
f010017a:	83 f8 01             	cmp    $0x1,%eax
f010017d:	75 f8                	jne    f0100177 <i386_init+0xdd>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010017f:	83 c3 74             	add    $0x74,%ebx
f0100182:	6b 05 c4 b3 2a f0 74 	imul   $0x74,0xf02ab3c4,%eax
f0100189:	05 20 b0 2a f0       	add    $0xf02ab020,%eax
f010018e:	39 c3                	cmp    %eax,%ebx
f0100190:	72 a3                	jb     f0100135 <i386_init+0x9b>

	// Starting non-boot CPUs
	boot_aps();

	// Start fs.
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f0100192:	83 ec 08             	sub    $0x8,%esp
f0100195:	6a 01                	push   $0x1
f0100197:	68 f8 b5 1d f0       	push   $0xf01db5f8
f010019c:	e8 d5 31 00 00       	call   f0103376 <env_create>
	ENV_CREATE(net_ns, ENV_TYPE_NS);
#endif

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01001a1:	83 c4 08             	add    $0x8,%esp
f01001a4:	6a 00                	push   $0x0
f01001a6:	68 ac e8 21 f0       	push   $0xf021e8ac
f01001ab:	e8 c6 31 00 00       	call   f0103376 <env_create>
	ENV_CREATE(user_icode, ENV_TYPE_USER);
	// ENV_CREATE(user_primes, ENV_TYPE_USER);
#endif // TEST*

	// Should not be necessary - drains keyboard because interrupt has given up.
	kbd_intr();
f01001b0:	e8 35 04 00 00       	call   f01005ea <kbd_intr>

	// Schedule and run the first user environment!
	sched_yield();
f01001b5:	e8 18 44 00 00       	call   f01045d2 <sched_yield>

f01001ba <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01001ba:	55                   	push   %ebp
f01001bb:	89 e5                	mov    %esp,%ebp
f01001bd:	83 ec 08             	sub    $0x8,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01001c0:	a1 98 ae 2a f0       	mov    0xf02aae98,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001c5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001ca:	77 12                	ja     f01001de <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001cc:	50                   	push   %eax
f01001cd:	68 28 6c 10 f0       	push   $0xf0106c28
f01001d2:	6a 7d                	push   $0x7d
f01001d4:	68 67 6c 10 f0       	push   $0xf0106c67
f01001d9:	e8 62 fe ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01001de:	05 00 00 00 10       	add    $0x10000000,%eax
f01001e3:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001e6:	e8 eb 5b 00 00       	call   f0105dd6 <cpunum>
f01001eb:	83 ec 08             	sub    $0x8,%esp
f01001ee:	50                   	push   %eax
f01001ef:	68 73 6c 10 f0       	push   $0xf0106c73
f01001f4:	e8 89 37 00 00       	call   f0103982 <cprintf>

	lapic_init();
f01001f9:	e8 f3 5b 00 00       	call   f0105df1 <lapic_init>
	env_init_percpu();
f01001fe:	e8 b0 2f 00 00       	call   f01031b3 <env_init_percpu>
	trap_init_percpu();
f0100203:	e8 8e 37 00 00       	call   f0103996 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100208:	e8 c9 5b 00 00       	call   f0105dd6 <cpunum>
f010020d:	6b d0 74             	imul   $0x74,%eax,%edx
f0100210:	81 c2 20 b0 2a f0    	add    $0xf02ab020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0100216:	b8 01 00 00 00       	mov    $0x1,%eax
f010021b:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010021f:	c7 04 24 c0 33 12 f0 	movl   $0xf01233c0,(%esp)
f0100226:	e8 19 5e 00 00       	call   f0106044 <spin_lock>
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:

	lock_kernel();
	sched_yield();
f010022b:	e8 a2 43 00 00       	call   f01045d2 <sched_yield>

f0100230 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100230:	55                   	push   %ebp
f0100231:	89 e5                	mov    %esp,%ebp
f0100233:	53                   	push   %ebx
f0100234:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100237:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010023a:	ff 75 0c             	pushl  0xc(%ebp)
f010023d:	ff 75 08             	pushl  0x8(%ebp)
f0100240:	68 89 6c 10 f0       	push   $0xf0106c89
f0100245:	e8 38 37 00 00       	call   f0103982 <cprintf>
	vcprintf(fmt, ap);
f010024a:	83 c4 08             	add    $0x8,%esp
f010024d:	53                   	push   %ebx
f010024e:	ff 75 10             	pushl  0x10(%ebp)
f0100251:	e8 06 37 00 00       	call   f010395c <vcprintf>
	cprintf("\n");
f0100256:	c7 04 24 f9 74 10 f0 	movl   $0xf01074f9,(%esp)
f010025d:	e8 20 37 00 00       	call   f0103982 <cprintf>
	va_end(ap);
}
f0100262:	83 c4 10             	add    $0x10,%esp
f0100265:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100268:	c9                   	leave  
f0100269:	c3                   	ret    

f010026a <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010026a:	55                   	push   %ebp
f010026b:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010026d:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100272:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100273:	a8 01                	test   $0x1,%al
f0100275:	74 0b                	je     f0100282 <serial_proc_data+0x18>
f0100277:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010027c:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010027d:	0f b6 c0             	movzbl %al,%eax
f0100280:	eb 05                	jmp    f0100287 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100282:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100287:	5d                   	pop    %ebp
f0100288:	c3                   	ret    

f0100289 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100289:	55                   	push   %ebp
f010028a:	89 e5                	mov    %esp,%ebp
f010028c:	53                   	push   %ebx
f010028d:	83 ec 04             	sub    $0x4,%esp
f0100290:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100292:	eb 2b                	jmp    f01002bf <cons_intr+0x36>
		if (c == 0)
f0100294:	85 c0                	test   %eax,%eax
f0100296:	74 27                	je     f01002bf <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f0100298:	8b 0d 24 a2 2a f0    	mov    0xf02aa224,%ecx
f010029e:	8d 51 01             	lea    0x1(%ecx),%edx
f01002a1:	89 15 24 a2 2a f0    	mov    %edx,0xf02aa224
f01002a7:	88 81 20 a0 2a f0    	mov    %al,-0xfd55fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002ad:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01002b3:	75 0a                	jne    f01002bf <cons_intr+0x36>
			cons.wpos = 0;
f01002b5:	c7 05 24 a2 2a f0 00 	movl   $0x0,0xf02aa224
f01002bc:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002bf:	ff d3                	call   *%ebx
f01002c1:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002c4:	75 ce                	jne    f0100294 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01002c6:	83 c4 04             	add    $0x4,%esp
f01002c9:	5b                   	pop    %ebx
f01002ca:	5d                   	pop    %ebp
f01002cb:	c3                   	ret    

f01002cc <kbd_proc_data>:
f01002cc:	ba 64 00 00 00       	mov    $0x64,%edx
f01002d1:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f01002d2:	a8 01                	test   $0x1,%al
f01002d4:	0f 84 f8 00 00 00    	je     f01003d2 <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f01002da:	a8 20                	test   $0x20,%al
f01002dc:	0f 85 f6 00 00 00    	jne    f01003d8 <kbd_proc_data+0x10c>
f01002e2:	ba 60 00 00 00       	mov    $0x60,%edx
f01002e7:	ec                   	in     (%dx),%al
f01002e8:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01002ea:	3c e0                	cmp    $0xe0,%al
f01002ec:	75 0d                	jne    f01002fb <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f01002ee:	83 0d 00 a0 2a f0 40 	orl    $0x40,0xf02aa000
		return 0;
f01002f5:	b8 00 00 00 00       	mov    $0x0,%eax
f01002fa:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01002fb:	55                   	push   %ebp
f01002fc:	89 e5                	mov    %esp,%ebp
f01002fe:	53                   	push   %ebx
f01002ff:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f0100302:	84 c0                	test   %al,%al
f0100304:	79 36                	jns    f010033c <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100306:	8b 0d 00 a0 2a f0    	mov    0xf02aa000,%ecx
f010030c:	89 cb                	mov    %ecx,%ebx
f010030e:	83 e3 40             	and    $0x40,%ebx
f0100311:	83 e0 7f             	and    $0x7f,%eax
f0100314:	85 db                	test   %ebx,%ebx
f0100316:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100319:	0f b6 d2             	movzbl %dl,%edx
f010031c:	0f b6 82 00 6e 10 f0 	movzbl -0xfef9200(%edx),%eax
f0100323:	83 c8 40             	or     $0x40,%eax
f0100326:	0f b6 c0             	movzbl %al,%eax
f0100329:	f7 d0                	not    %eax
f010032b:	21 c8                	and    %ecx,%eax
f010032d:	a3 00 a0 2a f0       	mov    %eax,0xf02aa000
		return 0;
f0100332:	b8 00 00 00 00       	mov    $0x0,%eax
f0100337:	e9 a4 00 00 00       	jmp    f01003e0 <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f010033c:	8b 0d 00 a0 2a f0    	mov    0xf02aa000,%ecx
f0100342:	f6 c1 40             	test   $0x40,%cl
f0100345:	74 0e                	je     f0100355 <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100347:	83 c8 80             	or     $0xffffff80,%eax
f010034a:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010034c:	83 e1 bf             	and    $0xffffffbf,%ecx
f010034f:	89 0d 00 a0 2a f0    	mov    %ecx,0xf02aa000
	}

	shift |= shiftcode[data];
f0100355:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100358:	0f b6 82 00 6e 10 f0 	movzbl -0xfef9200(%edx),%eax
f010035f:	0b 05 00 a0 2a f0    	or     0xf02aa000,%eax
f0100365:	0f b6 8a 00 6d 10 f0 	movzbl -0xfef9300(%edx),%ecx
f010036c:	31 c8                	xor    %ecx,%eax
f010036e:	a3 00 a0 2a f0       	mov    %eax,0xf02aa000

	c = charcode[shift & (CTL | SHIFT)][data];
f0100373:	89 c1                	mov    %eax,%ecx
f0100375:	83 e1 03             	and    $0x3,%ecx
f0100378:	8b 0c 8d e0 6c 10 f0 	mov    -0xfef9320(,%ecx,4),%ecx
f010037f:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100383:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100386:	a8 08                	test   $0x8,%al
f0100388:	74 1b                	je     f01003a5 <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f010038a:	89 da                	mov    %ebx,%edx
f010038c:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f010038f:	83 f9 19             	cmp    $0x19,%ecx
f0100392:	77 05                	ja     f0100399 <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f0100394:	83 eb 20             	sub    $0x20,%ebx
f0100397:	eb 0c                	jmp    f01003a5 <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f0100399:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f010039c:	8d 4b 20             	lea    0x20(%ebx),%ecx
f010039f:	83 fa 19             	cmp    $0x19,%edx
f01003a2:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003a5:	f7 d0                	not    %eax
f01003a7:	a8 06                	test   $0x6,%al
f01003a9:	75 33                	jne    f01003de <kbd_proc_data+0x112>
f01003ab:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003b1:	75 2b                	jne    f01003de <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f01003b3:	83 ec 0c             	sub    $0xc,%esp
f01003b6:	68 a3 6c 10 f0       	push   $0xf0106ca3
f01003bb:	e8 c2 35 00 00       	call   f0103982 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003c0:	ba 92 00 00 00       	mov    $0x92,%edx
f01003c5:	b8 03 00 00 00       	mov    $0x3,%eax
f01003ca:	ee                   	out    %al,(%dx)
f01003cb:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003ce:	89 d8                	mov    %ebx,%eax
f01003d0:	eb 0e                	jmp    f01003e0 <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f01003d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01003d7:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f01003d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01003dd:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003de:	89 d8                	mov    %ebx,%eax
}
f01003e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01003e3:	c9                   	leave  
f01003e4:	c3                   	ret    

f01003e5 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003e5:	55                   	push   %ebp
f01003e6:	89 e5                	mov    %esp,%ebp
f01003e8:	57                   	push   %edi
f01003e9:	56                   	push   %esi
f01003ea:	53                   	push   %ebx
f01003eb:	83 ec 1c             	sub    $0x1c,%esp
f01003ee:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01003f0:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003f5:	be fd 03 00 00       	mov    $0x3fd,%esi
f01003fa:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003ff:	eb 09                	jmp    f010040a <cons_putc+0x25>
f0100401:	89 ca                	mov    %ecx,%edx
f0100403:	ec                   	in     (%dx),%al
f0100404:	ec                   	in     (%dx),%al
f0100405:	ec                   	in     (%dx),%al
f0100406:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100407:	83 c3 01             	add    $0x1,%ebx
f010040a:	89 f2                	mov    %esi,%edx
f010040c:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010040d:	a8 20                	test   $0x20,%al
f010040f:	75 08                	jne    f0100419 <cons_putc+0x34>
f0100411:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100417:	7e e8                	jle    f0100401 <cons_putc+0x1c>
f0100419:	89 f8                	mov    %edi,%eax
f010041b:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010041e:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100423:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100424:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100429:	be 79 03 00 00       	mov    $0x379,%esi
f010042e:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100433:	eb 09                	jmp    f010043e <cons_putc+0x59>
f0100435:	89 ca                	mov    %ecx,%edx
f0100437:	ec                   	in     (%dx),%al
f0100438:	ec                   	in     (%dx),%al
f0100439:	ec                   	in     (%dx),%al
f010043a:	ec                   	in     (%dx),%al
f010043b:	83 c3 01             	add    $0x1,%ebx
f010043e:	89 f2                	mov    %esi,%edx
f0100440:	ec                   	in     (%dx),%al
f0100441:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100447:	7f 04                	jg     f010044d <cons_putc+0x68>
f0100449:	84 c0                	test   %al,%al
f010044b:	79 e8                	jns    f0100435 <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010044d:	ba 78 03 00 00       	mov    $0x378,%edx
f0100452:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100456:	ee                   	out    %al,(%dx)
f0100457:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010045c:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100461:	ee                   	out    %al,(%dx)
f0100462:	b8 08 00 00 00       	mov    $0x8,%eax
f0100467:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100468:	89 fa                	mov    %edi,%edx
f010046a:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100470:	89 f8                	mov    %edi,%eax
f0100472:	80 cc 07             	or     $0x7,%ah
f0100475:	85 d2                	test   %edx,%edx
f0100477:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f010047a:	89 f8                	mov    %edi,%eax
f010047c:	0f b6 c0             	movzbl %al,%eax
f010047f:	83 f8 09             	cmp    $0x9,%eax
f0100482:	74 74                	je     f01004f8 <cons_putc+0x113>
f0100484:	83 f8 09             	cmp    $0x9,%eax
f0100487:	7f 0a                	jg     f0100493 <cons_putc+0xae>
f0100489:	83 f8 08             	cmp    $0x8,%eax
f010048c:	74 14                	je     f01004a2 <cons_putc+0xbd>
f010048e:	e9 99 00 00 00       	jmp    f010052c <cons_putc+0x147>
f0100493:	83 f8 0a             	cmp    $0xa,%eax
f0100496:	74 3a                	je     f01004d2 <cons_putc+0xed>
f0100498:	83 f8 0d             	cmp    $0xd,%eax
f010049b:	74 3d                	je     f01004da <cons_putc+0xf5>
f010049d:	e9 8a 00 00 00       	jmp    f010052c <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f01004a2:	0f b7 05 28 a2 2a f0 	movzwl 0xf02aa228,%eax
f01004a9:	66 85 c0             	test   %ax,%ax
f01004ac:	0f 84 e6 00 00 00    	je     f0100598 <cons_putc+0x1b3>
			crt_pos--;
f01004b2:	83 e8 01             	sub    $0x1,%eax
f01004b5:	66 a3 28 a2 2a f0    	mov    %ax,0xf02aa228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004bb:	0f b7 c0             	movzwl %ax,%eax
f01004be:	66 81 e7 00 ff       	and    $0xff00,%di
f01004c3:	83 cf 20             	or     $0x20,%edi
f01004c6:	8b 15 2c a2 2a f0    	mov    0xf02aa22c,%edx
f01004cc:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004d0:	eb 78                	jmp    f010054a <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004d2:	66 83 05 28 a2 2a f0 	addw   $0x50,0xf02aa228
f01004d9:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004da:	0f b7 05 28 a2 2a f0 	movzwl 0xf02aa228,%eax
f01004e1:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004e7:	c1 e8 16             	shr    $0x16,%eax
f01004ea:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004ed:	c1 e0 04             	shl    $0x4,%eax
f01004f0:	66 a3 28 a2 2a f0    	mov    %ax,0xf02aa228
f01004f6:	eb 52                	jmp    f010054a <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f01004f8:	b8 20 00 00 00       	mov    $0x20,%eax
f01004fd:	e8 e3 fe ff ff       	call   f01003e5 <cons_putc>
		cons_putc(' ');
f0100502:	b8 20 00 00 00       	mov    $0x20,%eax
f0100507:	e8 d9 fe ff ff       	call   f01003e5 <cons_putc>
		cons_putc(' ');
f010050c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100511:	e8 cf fe ff ff       	call   f01003e5 <cons_putc>
		cons_putc(' ');
f0100516:	b8 20 00 00 00       	mov    $0x20,%eax
f010051b:	e8 c5 fe ff ff       	call   f01003e5 <cons_putc>
		cons_putc(' ');
f0100520:	b8 20 00 00 00       	mov    $0x20,%eax
f0100525:	e8 bb fe ff ff       	call   f01003e5 <cons_putc>
f010052a:	eb 1e                	jmp    f010054a <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010052c:	0f b7 05 28 a2 2a f0 	movzwl 0xf02aa228,%eax
f0100533:	8d 50 01             	lea    0x1(%eax),%edx
f0100536:	66 89 15 28 a2 2a f0 	mov    %dx,0xf02aa228
f010053d:	0f b7 c0             	movzwl %ax,%eax
f0100540:	8b 15 2c a2 2a f0    	mov    0xf02aa22c,%edx
f0100546:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f010054a:	66 81 3d 28 a2 2a f0 	cmpw   $0x7cf,0xf02aa228
f0100551:	cf 07 
f0100553:	76 43                	jbe    f0100598 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100555:	a1 2c a2 2a f0       	mov    0xf02aa22c,%eax
f010055a:	83 ec 04             	sub    $0x4,%esp
f010055d:	68 00 0f 00 00       	push   $0xf00
f0100562:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100568:	52                   	push   %edx
f0100569:	50                   	push   %eax
f010056a:	e8 94 52 00 00       	call   f0105803 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010056f:	8b 15 2c a2 2a f0    	mov    0xf02aa22c,%edx
f0100575:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010057b:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100581:	83 c4 10             	add    $0x10,%esp
f0100584:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100589:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010058c:	39 d0                	cmp    %edx,%eax
f010058e:	75 f4                	jne    f0100584 <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100590:	66 83 2d 28 a2 2a f0 	subw   $0x50,0xf02aa228
f0100597:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100598:	8b 0d 30 a2 2a f0    	mov    0xf02aa230,%ecx
f010059e:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005a3:	89 ca                	mov    %ecx,%edx
f01005a5:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01005a6:	0f b7 1d 28 a2 2a f0 	movzwl 0xf02aa228,%ebx
f01005ad:	8d 71 01             	lea    0x1(%ecx),%esi
f01005b0:	89 d8                	mov    %ebx,%eax
f01005b2:	66 c1 e8 08          	shr    $0x8,%ax
f01005b6:	89 f2                	mov    %esi,%edx
f01005b8:	ee                   	out    %al,(%dx)
f01005b9:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005be:	89 ca                	mov    %ecx,%edx
f01005c0:	ee                   	out    %al,(%dx)
f01005c1:	89 d8                	mov    %ebx,%eax
f01005c3:	89 f2                	mov    %esi,%edx
f01005c5:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01005c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005c9:	5b                   	pop    %ebx
f01005ca:	5e                   	pop    %esi
f01005cb:	5f                   	pop    %edi
f01005cc:	5d                   	pop    %ebp
f01005cd:	c3                   	ret    

f01005ce <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01005ce:	80 3d 34 a2 2a f0 00 	cmpb   $0x0,0xf02aa234
f01005d5:	74 11                	je     f01005e8 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01005d7:	55                   	push   %ebp
f01005d8:	89 e5                	mov    %esp,%ebp
f01005da:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01005dd:	b8 6a 02 10 f0       	mov    $0xf010026a,%eax
f01005e2:	e8 a2 fc ff ff       	call   f0100289 <cons_intr>
}
f01005e7:	c9                   	leave  
f01005e8:	f3 c3                	repz ret 

f01005ea <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01005ea:	55                   	push   %ebp
f01005eb:	89 e5                	mov    %esp,%ebp
f01005ed:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01005f0:	b8 cc 02 10 f0       	mov    $0xf01002cc,%eax
f01005f5:	e8 8f fc ff ff       	call   f0100289 <cons_intr>
}
f01005fa:	c9                   	leave  
f01005fb:	c3                   	ret    

f01005fc <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01005fc:	55                   	push   %ebp
f01005fd:	89 e5                	mov    %esp,%ebp
f01005ff:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100602:	e8 c7 ff ff ff       	call   f01005ce <serial_intr>
	kbd_intr();
f0100607:	e8 de ff ff ff       	call   f01005ea <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010060c:	a1 20 a2 2a f0       	mov    0xf02aa220,%eax
f0100611:	3b 05 24 a2 2a f0    	cmp    0xf02aa224,%eax
f0100617:	74 26                	je     f010063f <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100619:	8d 50 01             	lea    0x1(%eax),%edx
f010061c:	89 15 20 a2 2a f0    	mov    %edx,0xf02aa220
f0100622:	0f b6 88 20 a0 2a f0 	movzbl -0xfd55fe0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100629:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f010062b:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100631:	75 11                	jne    f0100644 <cons_getc+0x48>
			cons.rpos = 0;
f0100633:	c7 05 20 a2 2a f0 00 	movl   $0x0,0xf02aa220
f010063a:	00 00 00 
f010063d:	eb 05                	jmp    f0100644 <cons_getc+0x48>
		return c;
	}
	return 0;
f010063f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100644:	c9                   	leave  
f0100645:	c3                   	ret    

f0100646 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100646:	55                   	push   %ebp
f0100647:	89 e5                	mov    %esp,%ebp
f0100649:	57                   	push   %edi
f010064a:	56                   	push   %esi
f010064b:	53                   	push   %ebx
f010064c:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010064f:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100656:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010065d:	5a a5 
	if (*cp != 0xA55A) {
f010065f:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100666:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010066a:	74 11                	je     f010067d <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010066c:	c7 05 30 a2 2a f0 b4 	movl   $0x3b4,0xf02aa230
f0100673:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100676:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f010067b:	eb 16                	jmp    f0100693 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010067d:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100684:	c7 05 30 a2 2a f0 d4 	movl   $0x3d4,0xf02aa230
f010068b:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010068e:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100693:	8b 3d 30 a2 2a f0    	mov    0xf02aa230,%edi
f0100699:	b8 0e 00 00 00       	mov    $0xe,%eax
f010069e:	89 fa                	mov    %edi,%edx
f01006a0:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006a1:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006a4:	89 da                	mov    %ebx,%edx
f01006a6:	ec                   	in     (%dx),%al
f01006a7:	0f b6 c8             	movzbl %al,%ecx
f01006aa:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006ad:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006b2:	89 fa                	mov    %edi,%edx
f01006b4:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006b5:	89 da                	mov    %ebx,%edx
f01006b7:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006b8:	89 35 2c a2 2a f0    	mov    %esi,0xf02aa22c
	crt_pos = pos;
f01006be:	0f b6 c0             	movzbl %al,%eax
f01006c1:	09 c8                	or     %ecx,%eax
f01006c3:	66 a3 28 a2 2a f0    	mov    %ax,0xf02aa228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006c9:	e8 1c ff ff ff       	call   f01005ea <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006ce:	83 ec 0c             	sub    $0xc,%esp
f01006d1:	0f b7 05 a8 33 12 f0 	movzwl 0xf01233a8,%eax
f01006d8:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006dd:	50                   	push   %eax
f01006de:	e8 38 31 00 00       	call   f010381b <irq_setmask_8259A>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006e3:	be fa 03 00 00       	mov    $0x3fa,%esi
f01006e8:	b8 00 00 00 00       	mov    $0x0,%eax
f01006ed:	89 f2                	mov    %esi,%edx
f01006ef:	ee                   	out    %al,(%dx)
f01006f0:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01006f5:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006fa:	ee                   	out    %al,(%dx)
f01006fb:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f0100700:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100705:	89 da                	mov    %ebx,%edx
f0100707:	ee                   	out    %al,(%dx)
f0100708:	ba f9 03 00 00       	mov    $0x3f9,%edx
f010070d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100712:	ee                   	out    %al,(%dx)
f0100713:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100718:	b8 03 00 00 00       	mov    $0x3,%eax
f010071d:	ee                   	out    %al,(%dx)
f010071e:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100723:	b8 00 00 00 00       	mov    $0x0,%eax
f0100728:	ee                   	out    %al,(%dx)
f0100729:	ba f9 03 00 00       	mov    $0x3f9,%edx
f010072e:	b8 01 00 00 00       	mov    $0x1,%eax
f0100733:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100734:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100739:	ec                   	in     (%dx),%al
f010073a:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010073c:	83 c4 10             	add    $0x10,%esp
f010073f:	3c ff                	cmp    $0xff,%al
f0100741:	0f 95 05 34 a2 2a f0 	setne  0xf02aa234
f0100748:	89 f2                	mov    %esi,%edx
f010074a:	ec                   	in     (%dx),%al
f010074b:	89 da                	mov    %ebx,%edx
f010074d:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

	// Enable serial interrupts
	if (serial_exists)
f010074e:	80 f9 ff             	cmp    $0xff,%cl
f0100751:	74 21                	je     f0100774 <cons_init+0x12e>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_SERIAL));
f0100753:	83 ec 0c             	sub    $0xc,%esp
f0100756:	0f b7 05 a8 33 12 f0 	movzwl 0xf01233a8,%eax
f010075d:	25 ef ff 00 00       	and    $0xffef,%eax
f0100762:	50                   	push   %eax
f0100763:	e8 b3 30 00 00       	call   f010381b <irq_setmask_8259A>
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100768:	83 c4 10             	add    $0x10,%esp
f010076b:	80 3d 34 a2 2a f0 00 	cmpb   $0x0,0xf02aa234
f0100772:	75 10                	jne    f0100784 <cons_init+0x13e>
		cprintf("Serial port does not exist!\n");
f0100774:	83 ec 0c             	sub    $0xc,%esp
f0100777:	68 af 6c 10 f0       	push   $0xf0106caf
f010077c:	e8 01 32 00 00       	call   f0103982 <cprintf>
f0100781:	83 c4 10             	add    $0x10,%esp
}
f0100784:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100787:	5b                   	pop    %ebx
f0100788:	5e                   	pop    %esi
f0100789:	5f                   	pop    %edi
f010078a:	5d                   	pop    %ebp
f010078b:	c3                   	ret    

f010078c <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010078c:	55                   	push   %ebp
f010078d:	89 e5                	mov    %esp,%ebp
f010078f:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100792:	8b 45 08             	mov    0x8(%ebp),%eax
f0100795:	e8 4b fc ff ff       	call   f01003e5 <cons_putc>
}
f010079a:	c9                   	leave  
f010079b:	c3                   	ret    

f010079c <getchar>:

int
getchar(void)
{
f010079c:	55                   	push   %ebp
f010079d:	89 e5                	mov    %esp,%ebp
f010079f:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007a2:	e8 55 fe ff ff       	call   f01005fc <cons_getc>
f01007a7:	85 c0                	test   %eax,%eax
f01007a9:	74 f7                	je     f01007a2 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007ab:	c9                   	leave  
f01007ac:	c3                   	ret    

f01007ad <iscons>:

int
iscons(int fdnum)
{
f01007ad:	55                   	push   %ebp
f01007ae:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007b0:	b8 01 00 00 00       	mov    $0x1,%eax
f01007b5:	5d                   	pop    %ebp
f01007b6:	c3                   	ret    

f01007b7 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007b7:	55                   	push   %ebp
f01007b8:	89 e5                	mov    %esp,%ebp
f01007ba:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007bd:	68 00 6f 10 f0       	push   $0xf0106f00
f01007c2:	68 1e 6f 10 f0       	push   $0xf0106f1e
f01007c7:	68 23 6f 10 f0       	push   $0xf0106f23
f01007cc:	e8 b1 31 00 00       	call   f0103982 <cprintf>
f01007d1:	83 c4 0c             	add    $0xc,%esp
f01007d4:	68 dc 6f 10 f0       	push   $0xf0106fdc
f01007d9:	68 2c 6f 10 f0       	push   $0xf0106f2c
f01007de:	68 23 6f 10 f0       	push   $0xf0106f23
f01007e3:	e8 9a 31 00 00       	call   f0103982 <cprintf>
f01007e8:	83 c4 0c             	add    $0xc,%esp
f01007eb:	68 35 6f 10 f0       	push   $0xf0106f35
f01007f0:	68 53 6f 10 f0       	push   $0xf0106f53
f01007f5:	68 23 6f 10 f0       	push   $0xf0106f23
f01007fa:	e8 83 31 00 00       	call   f0103982 <cprintf>
	return 0;
}
f01007ff:	b8 00 00 00 00       	mov    $0x0,%eax
f0100804:	c9                   	leave  
f0100805:	c3                   	ret    

f0100806 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100806:	55                   	push   %ebp
f0100807:	89 e5                	mov    %esp,%ebp
f0100809:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010080c:	68 5d 6f 10 f0       	push   $0xf0106f5d
f0100811:	e8 6c 31 00 00       	call   f0103982 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100816:	83 c4 08             	add    $0x8,%esp
f0100819:	68 0c 00 10 00       	push   $0x10000c
f010081e:	68 04 70 10 f0       	push   $0xf0107004
f0100823:	e8 5a 31 00 00       	call   f0103982 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100828:	83 c4 0c             	add    $0xc,%esp
f010082b:	68 0c 00 10 00       	push   $0x10000c
f0100830:	68 0c 00 10 f0       	push   $0xf010000c
f0100835:	68 2c 70 10 f0       	push   $0xf010702c
f010083a:	e8 43 31 00 00       	call   f0103982 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010083f:	83 c4 0c             	add    $0xc,%esp
f0100842:	68 c1 6b 10 00       	push   $0x106bc1
f0100847:	68 c1 6b 10 f0       	push   $0xf0106bc1
f010084c:	68 50 70 10 f0       	push   $0xf0107050
f0100851:	e8 2c 31 00 00       	call   f0103982 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100856:	83 c4 0c             	add    $0xc,%esp
f0100859:	68 00 a0 2a 00       	push   $0x2aa000
f010085e:	68 00 a0 2a f0       	push   $0xf02aa000
f0100863:	68 74 70 10 f0       	push   $0xf0107074
f0100868:	e8 15 31 00 00       	call   f0103982 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010086d:	83 c4 0c             	add    $0xc,%esp
f0100870:	68 60 80 2f 00       	push   $0x2f8060
f0100875:	68 60 80 2f f0       	push   $0xf02f8060
f010087a:	68 98 70 10 f0       	push   $0xf0107098
f010087f:	e8 fe 30 00 00       	call   f0103982 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100884:	b8 5f 84 2f f0       	mov    $0xf02f845f,%eax
f0100889:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010088e:	83 c4 08             	add    $0x8,%esp
f0100891:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0100896:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010089c:	85 c0                	test   %eax,%eax
f010089e:	0f 48 c2             	cmovs  %edx,%eax
f01008a1:	c1 f8 0a             	sar    $0xa,%eax
f01008a4:	50                   	push   %eax
f01008a5:	68 bc 70 10 f0       	push   $0xf01070bc
f01008aa:	e8 d3 30 00 00       	call   f0103982 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01008af:	b8 00 00 00 00       	mov    $0x0,%eax
f01008b4:	c9                   	leave  
f01008b5:	c3                   	ret    

f01008b6 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008b6:	55                   	push   %ebp
f01008b7:	89 e5                	mov    %esp,%ebp
f01008b9:	57                   	push   %edi
f01008ba:	56                   	push   %esi
f01008bb:	53                   	push   %ebx
f01008bc:	83 ec 78             	sub    $0x78,%esp

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008bf:	89 eb                	mov    %ebp,%ebx

	uint32_t _ebp, _eip;
	// _esp = read_esp();
	_ebp = read_ebp();

	uint32_t args[5] = {0, 0, 0, 0, 0};
f01008c1:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f01008c8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f01008cf:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f01008d6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01008dd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	struct Eipdebuginfo context;

	cprintf("Stack backtrace:\n");
f01008e4:	68 76 6f 10 f0       	push   $0xf0106f76
f01008e9:	e8 94 30 00 00       	call   f0103982 <cprintf>

	while (_ebp != 0) {
f01008ee:	83 c4 10             	add    $0x10,%esp
f01008f1:	e9 a6 00 00 00       	jmp    f010099c <mon_backtrace+0xe6>
		
		_eip = *(uint32_t *)(_ebp + 4);		// ret addr
f01008f6:	8b 73 04             	mov    0x4(%ebx),%esi

		for (int i=0; i<5; i++) {
f01008f9:	b8 00 00 00 00       	mov    $0x0,%eax
			args[i] = *(uint32_t *)(_ebp + 8 + i * 4);
f01008fe:	8b 54 83 08          	mov    0x8(%ebx,%eax,4),%edx
f0100902:	89 54 85 d4          	mov    %edx,-0x2c(%ebp,%eax,4)

	while (_ebp != 0) {
		
		_eip = *(uint32_t *)(_ebp + 4);		// ret addr

		for (int i=0; i<5; i++) {
f0100906:	83 c0 01             	add    $0x1,%eax
f0100909:	83 f8 05             	cmp    $0x5,%eax
f010090c:	75 f0                	jne    f01008fe <mon_backtrace+0x48>
			args[i] = *(uint32_t *)(_ebp + 8 + i * 4);
		}

		debuginfo_eip((uintptr_t)_eip, &context);
f010090e:	83 ec 08             	sub    $0x8,%esp
f0100911:	8d 45 bc             	lea    -0x44(%ebp),%eax
f0100914:	50                   	push   %eax
f0100915:	56                   	push   %esi
f0100916:	e8 09 44 00 00       	call   f0104d24 <debuginfo_eip>

		char function_name[50] = {0};
f010091b:	c7 45 8a 00 00 00 00 	movl   $0x0,-0x76(%ebp)
f0100922:	c7 45 b8 00 00 00 00 	movl   $0x0,-0x48(%ebp)
f0100929:	8d 7d 8c             	lea    -0x74(%ebp),%edi
f010092c:	b9 0c 00 00 00       	mov    $0xc,%ecx
f0100931:	b8 00 00 00 00       	mov    $0x0,%eax
f0100936:	f3 ab                	rep stos %eax,%es:(%edi)
		int i = 0;
		for (; i<context.eip_fn_namelen; i++) {
f0100938:	8b 4d c8             	mov    -0x38(%ebp),%ecx
			function_name[i] = context.eip_fn_name[i];
f010093b:	8b 7d c4             	mov    -0x3c(%ebp),%edi

		debuginfo_eip((uintptr_t)_eip, &context);

		char function_name[50] = {0};
		int i = 0;
		for (; i<context.eip_fn_namelen; i++) {
f010093e:	83 c4 10             	add    $0x10,%esp
f0100941:	eb 0b                	jmp    f010094e <mon_backtrace+0x98>
			function_name[i] = context.eip_fn_name[i];
f0100943:	0f b6 14 07          	movzbl (%edi,%eax,1),%edx
f0100947:	88 54 05 8a          	mov    %dl,-0x76(%ebp,%eax,1)

		debuginfo_eip((uintptr_t)_eip, &context);

		char function_name[50] = {0};
		int i = 0;
		for (; i<context.eip_fn_namelen; i++) {
f010094b:	83 c0 01             	add    $0x1,%eax
f010094e:	39 c8                	cmp    %ecx,%eax
f0100950:	7c f1                	jl     f0100943 <mon_backtrace+0x8d>
			function_name[i] = context.eip_fn_name[i];
		}
		function_name[i] = '\0';
f0100952:	85 c9                	test   %ecx,%ecx
f0100954:	b8 00 00 00 00       	mov    $0x0,%eax
f0100959:	0f 48 c8             	cmovs  %eax,%ecx
f010095c:	c6 44 0d 8a 00       	movb   $0x0,-0x76(%ebp,%ecx,1)

		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", _ebp, _eip, args[0], args[1], args[2], args[3], args[4]);
f0100961:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100964:	ff 75 e0             	pushl  -0x20(%ebp)
f0100967:	ff 75 dc             	pushl  -0x24(%ebp)
f010096a:	ff 75 d8             	pushl  -0x28(%ebp)
f010096d:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100970:	56                   	push   %esi
f0100971:	53                   	push   %ebx
f0100972:	68 e8 70 10 f0       	push   $0xf01070e8
f0100977:	e8 06 30 00 00       	call   f0103982 <cprintf>
		cprintf("         %s:%d: %s+%d\n", context.eip_file, context.eip_line, function_name, _eip - context.eip_fn_addr);
f010097c:	83 c4 14             	add    $0x14,%esp
f010097f:	2b 75 cc             	sub    -0x34(%ebp),%esi
f0100982:	56                   	push   %esi
f0100983:	8d 45 8a             	lea    -0x76(%ebp),%eax
f0100986:	50                   	push   %eax
f0100987:	ff 75 c0             	pushl  -0x40(%ebp)
f010098a:	ff 75 bc             	pushl  -0x44(%ebp)
f010098d:	68 88 6f 10 f0       	push   $0xf0106f88
f0100992:	e8 eb 2f 00 00       	call   f0103982 <cprintf>

		// _rsp = _ebp + 8;			// old_rsp
		_ebp = *(uint32_t *)_ebp;	// old_ebp
f0100997:	8b 1b                	mov    (%ebx),%ebx
f0100999:	83 c4 20             	add    $0x20,%esp

	struct Eipdebuginfo context;

	cprintf("Stack backtrace:\n");

	while (_ebp != 0) {
f010099c:	85 db                	test   %ebx,%ebx
f010099e:	0f 85 52 ff ff ff    	jne    f01008f6 <mon_backtrace+0x40>
		_ebp = *(uint32_t *)_ebp;	// old_ebp

	} 

	return 0;
}
f01009a4:	b8 00 00 00 00       	mov    $0x0,%eax
f01009a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01009ac:	5b                   	pop    %ebx
f01009ad:	5e                   	pop    %esi
f01009ae:	5f                   	pop    %edi
f01009af:	5d                   	pop    %ebp
f01009b0:	c3                   	ret    

f01009b1 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01009b1:	55                   	push   %ebp
f01009b2:	89 e5                	mov    %esp,%ebp
f01009b4:	57                   	push   %edi
f01009b5:	56                   	push   %esi
f01009b6:	53                   	push   %ebx
f01009b7:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01009ba:	68 20 71 10 f0       	push   $0xf0107120
f01009bf:	e8 be 2f 00 00       	call   f0103982 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01009c4:	c7 04 24 44 71 10 f0 	movl   $0xf0107144,(%esp)
f01009cb:	e8 b2 2f 00 00       	call   f0103982 <cprintf>

	if (tf != NULL)
f01009d0:	83 c4 10             	add    $0x10,%esp
f01009d3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01009d7:	74 0e                	je     f01009e7 <monitor+0x36>
		print_trapframe(tf);
f01009d9:	83 ec 0c             	sub    $0xc,%esp
f01009dc:	ff 75 08             	pushl  0x8(%ebp)
f01009df:	e8 5f 35 00 00       	call   f0103f43 <print_trapframe>
f01009e4:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01009e7:	83 ec 0c             	sub    $0xc,%esp
f01009ea:	68 9f 6f 10 f0       	push   $0xf0106f9f
f01009ef:	e8 53 4b 00 00       	call   f0105547 <readline>
f01009f4:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01009f6:	83 c4 10             	add    $0x10,%esp
f01009f9:	85 c0                	test   %eax,%eax
f01009fb:	74 ea                	je     f01009e7 <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01009fd:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100a04:	be 00 00 00 00       	mov    $0x0,%esi
f0100a09:	eb 0a                	jmp    f0100a15 <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100a0b:	c6 03 00             	movb   $0x0,(%ebx)
f0100a0e:	89 f7                	mov    %esi,%edi
f0100a10:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100a13:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100a15:	0f b6 03             	movzbl (%ebx),%eax
f0100a18:	84 c0                	test   %al,%al
f0100a1a:	74 63                	je     f0100a7f <monitor+0xce>
f0100a1c:	83 ec 08             	sub    $0x8,%esp
f0100a1f:	0f be c0             	movsbl %al,%eax
f0100a22:	50                   	push   %eax
f0100a23:	68 a3 6f 10 f0       	push   $0xf0106fa3
f0100a28:	e8 4c 4d 00 00       	call   f0105779 <strchr>
f0100a2d:	83 c4 10             	add    $0x10,%esp
f0100a30:	85 c0                	test   %eax,%eax
f0100a32:	75 d7                	jne    f0100a0b <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f0100a34:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100a37:	74 46                	je     f0100a7f <monitor+0xce>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100a39:	83 fe 0f             	cmp    $0xf,%esi
f0100a3c:	75 14                	jne    f0100a52 <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a3e:	83 ec 08             	sub    $0x8,%esp
f0100a41:	6a 10                	push   $0x10
f0100a43:	68 a8 6f 10 f0       	push   $0xf0106fa8
f0100a48:	e8 35 2f 00 00       	call   f0103982 <cprintf>
f0100a4d:	83 c4 10             	add    $0x10,%esp
f0100a50:	eb 95                	jmp    f01009e7 <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f0100a52:	8d 7e 01             	lea    0x1(%esi),%edi
f0100a55:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100a59:	eb 03                	jmp    f0100a5e <monitor+0xad>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100a5b:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a5e:	0f b6 03             	movzbl (%ebx),%eax
f0100a61:	84 c0                	test   %al,%al
f0100a63:	74 ae                	je     f0100a13 <monitor+0x62>
f0100a65:	83 ec 08             	sub    $0x8,%esp
f0100a68:	0f be c0             	movsbl %al,%eax
f0100a6b:	50                   	push   %eax
f0100a6c:	68 a3 6f 10 f0       	push   $0xf0106fa3
f0100a71:	e8 03 4d 00 00       	call   f0105779 <strchr>
f0100a76:	83 c4 10             	add    $0x10,%esp
f0100a79:	85 c0                	test   %eax,%eax
f0100a7b:	74 de                	je     f0100a5b <monitor+0xaa>
f0100a7d:	eb 94                	jmp    f0100a13 <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f0100a7f:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a86:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100a87:	85 f6                	test   %esi,%esi
f0100a89:	0f 84 58 ff ff ff    	je     f01009e7 <monitor+0x36>
f0100a8f:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a94:	83 ec 08             	sub    $0x8,%esp
f0100a97:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a9a:	ff 34 85 80 71 10 f0 	pushl  -0xfef8e80(,%eax,4)
f0100aa1:	ff 75 a8             	pushl  -0x58(%ebp)
f0100aa4:	e8 72 4c 00 00       	call   f010571b <strcmp>
f0100aa9:	83 c4 10             	add    $0x10,%esp
f0100aac:	85 c0                	test   %eax,%eax
f0100aae:	75 21                	jne    f0100ad1 <monitor+0x120>
			return commands[i].func(argc, argv, tf);
f0100ab0:	83 ec 04             	sub    $0x4,%esp
f0100ab3:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100ab6:	ff 75 08             	pushl  0x8(%ebp)
f0100ab9:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100abc:	52                   	push   %edx
f0100abd:	56                   	push   %esi
f0100abe:	ff 14 85 88 71 10 f0 	call   *-0xfef8e78(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100ac5:	83 c4 10             	add    $0x10,%esp
f0100ac8:	85 c0                	test   %eax,%eax
f0100aca:	78 25                	js     f0100af1 <monitor+0x140>
f0100acc:	e9 16 ff ff ff       	jmp    f01009e7 <monitor+0x36>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100ad1:	83 c3 01             	add    $0x1,%ebx
f0100ad4:	83 fb 03             	cmp    $0x3,%ebx
f0100ad7:	75 bb                	jne    f0100a94 <monitor+0xe3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100ad9:	83 ec 08             	sub    $0x8,%esp
f0100adc:	ff 75 a8             	pushl  -0x58(%ebp)
f0100adf:	68 c5 6f 10 f0       	push   $0xf0106fc5
f0100ae4:	e8 99 2e 00 00       	call   f0103982 <cprintf>
f0100ae9:	83 c4 10             	add    $0x10,%esp
f0100aec:	e9 f6 fe ff ff       	jmp    f01009e7 <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100af1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100af4:	5b                   	pop    %ebx
f0100af5:	5e                   	pop    %esi
f0100af6:	5f                   	pop    %edi
f0100af7:	5d                   	pop    %ebp
f0100af8:	c3                   	ret    

f0100af9 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100af9:	55                   	push   %ebp
f0100afa:	89 e5                	mov    %esp,%ebp
f0100afc:	56                   	push   %esi
f0100afd:	53                   	push   %ebx
f0100afe:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100b00:	83 ec 0c             	sub    $0xc,%esp
f0100b03:	50                   	push   %eax
f0100b04:	e8 e4 2c 00 00       	call   f01037ed <mc146818_read>
f0100b09:	89 c6                	mov    %eax,%esi
f0100b0b:	83 c3 01             	add    $0x1,%ebx
f0100b0e:	89 1c 24             	mov    %ebx,(%esp)
f0100b11:	e8 d7 2c 00 00       	call   f01037ed <mc146818_read>
f0100b16:	c1 e0 08             	shl    $0x8,%eax
f0100b19:	09 f0                	or     %esi,%eax
}
f0100b1b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100b1e:	5b                   	pop    %ebx
f0100b1f:	5e                   	pop    %esi
f0100b20:	5d                   	pop    %ebp
f0100b21:	c3                   	ret    

f0100b22 <boot_alloc>:
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100b22:	83 3d 38 a2 2a f0 00 	cmpl   $0x0,0xf02aa238
f0100b29:	75 11                	jne    f0100b3c <boot_alloc+0x1a>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100b2b:	ba 5f 90 2f f0       	mov    $0xf02f905f,%edx
f0100b30:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b36:	89 15 38 a2 2a f0    	mov    %edx,0xf02aa238
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

	if ((uint32_t)nextfree > 0xffffffff - n)
f0100b3c:	8b 15 38 a2 2a f0    	mov    0xf02aa238,%edx
f0100b42:	89 c1                	mov    %eax,%ecx
f0100b44:	f7 d1                	not    %ecx
f0100b46:	39 ca                	cmp    %ecx,%edx
f0100b48:	76 17                	jbe    f0100b61 <boot_alloc+0x3f>
// before the page_free_list list has been set up.
// Note that when this function is called, we are still using entry_pgdir,
// which only maps the first 4MB of physical memory.
static void *
boot_alloc(uint32_t n)
{
f0100b4a:	55                   	push   %ebp
f0100b4b:	89 e5                	mov    %esp,%ebp
f0100b4d:	83 ec 0c             	sub    $0xc,%esp
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

	if ((uint32_t)nextfree > 0xffffffff - n)
		panic("boot_alloc: out of memory\n");
f0100b50:	68 a4 71 10 f0       	push   $0xf01071a4
f0100b55:	6a 70                	push   $0x70
f0100b57:	68 bf 71 10 f0       	push   $0xf01071bf
f0100b5c:	e8 df f4 ff ff       	call   f0100040 <_panic>

	result = nextfree;
	nextfree = ROUNDUP(result + n , PGSIZE);
f0100b61:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100b68:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b6d:	a3 38 a2 2a f0       	mov    %eax,0xf02aa238

	return result;
}
f0100b72:	89 d0                	mov    %edx,%eax
f0100b74:	c3                   	ret    

f0100b75 <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100b75:	89 d1                	mov    %edx,%ecx
f0100b77:	c1 e9 16             	shr    $0x16,%ecx
f0100b7a:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100b7d:	a8 01                	test   $0x1,%al
f0100b7f:	74 52                	je     f0100bd3 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b81:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b86:	89 c1                	mov    %eax,%ecx
f0100b88:	c1 e9 0c             	shr    $0xc,%ecx
f0100b8b:	3b 0d 94 ae 2a f0    	cmp    0xf02aae94,%ecx
f0100b91:	72 1b                	jb     f0100bae <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100b93:	55                   	push   %ebp
f0100b94:	89 e5                	mov    %esp,%ebp
f0100b96:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b99:	50                   	push   %eax
f0100b9a:	68 04 6c 10 f0       	push   $0xf0106c04
f0100b9f:	68 40 04 00 00       	push   $0x440
f0100ba4:	68 bf 71 10 f0       	push   $0xf01071bf
f0100ba9:	e8 92 f4 ff ff       	call   f0100040 <_panic>
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));

	// cprintf("[?] In check_va2pa\n");
	// cprintf("[?] *pte_store:%x, **pte_store:%x\n", &p[PTX(va)], p[PTX(va)]);

	if (!(p[PTX(va)] & PTE_P))
f0100bae:	c1 ea 0c             	shr    $0xc,%edx
f0100bb1:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100bb7:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100bbe:	89 c2                	mov    %eax,%edx
f0100bc0:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100bc3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100bc8:	85 d2                	test   %edx,%edx
f0100bca:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100bcf:	0f 44 c2             	cmove  %edx,%eax
f0100bd2:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100bd3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	// cprintf("[?] *pte_store:%x, **pte_store:%x\n", &p[PTX(va)], p[PTX(va)]);

	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100bd8:	c3                   	ret    

f0100bd9 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100bd9:	55                   	push   %ebp
f0100bda:	89 e5                	mov    %esp,%ebp
f0100bdc:	57                   	push   %edi
f0100bdd:	56                   	push   %esi
f0100bde:	53                   	push   %ebx
f0100bdf:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100be2:	84 c0                	test   %al,%al
f0100be4:	0f 85 a0 02 00 00    	jne    f0100e8a <check_page_free_list+0x2b1>
f0100bea:	e9 ad 02 00 00       	jmp    f0100e9c <check_page_free_list+0x2c3>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100bef:	83 ec 04             	sub    $0x4,%esp
f0100bf2:	68 2c 75 10 f0       	push   $0xf010752c
f0100bf7:	68 71 03 00 00       	push   $0x371
f0100bfc:	68 bf 71 10 f0       	push   $0xf01071bf
f0100c01:	e8 3a f4 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100c06:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100c09:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100c0c:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100c0f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100c12:	89 c2                	mov    %eax,%edx
f0100c14:	2b 15 9c ae 2a f0    	sub    0xf02aae9c,%edx
f0100c1a:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100c20:	0f 95 c2             	setne  %dl
f0100c23:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100c26:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100c2a:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100c2c:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c30:	8b 00                	mov    (%eax),%eax
f0100c32:	85 c0                	test   %eax,%eax
f0100c34:	75 dc                	jne    f0100c12 <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100c36:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c39:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100c3f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c42:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100c45:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100c47:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100c4a:	a3 40 a2 2a f0       	mov    %eax,0xf02aa240
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c4f:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c54:	8b 1d 40 a2 2a f0    	mov    0xf02aa240,%ebx
f0100c5a:	eb 53                	jmp    f0100caf <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c5c:	89 d8                	mov    %ebx,%eax
f0100c5e:	2b 05 9c ae 2a f0    	sub    0xf02aae9c,%eax
f0100c64:	c1 f8 03             	sar    $0x3,%eax
f0100c67:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100c6a:	89 c2                	mov    %eax,%edx
f0100c6c:	c1 ea 16             	shr    $0x16,%edx
f0100c6f:	39 f2                	cmp    %esi,%edx
f0100c71:	73 3a                	jae    f0100cad <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c73:	89 c2                	mov    %eax,%edx
f0100c75:	c1 ea 0c             	shr    $0xc,%edx
f0100c78:	3b 15 94 ae 2a f0    	cmp    0xf02aae94,%edx
f0100c7e:	72 12                	jb     f0100c92 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c80:	50                   	push   %eax
f0100c81:	68 04 6c 10 f0       	push   $0xf0106c04
f0100c86:	6a 58                	push   $0x58
f0100c88:	68 cb 71 10 f0       	push   $0xf01071cb
f0100c8d:	e8 ae f3 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100c92:	83 ec 04             	sub    $0x4,%esp
f0100c95:	68 80 00 00 00       	push   $0x80
f0100c9a:	68 97 00 00 00       	push   $0x97
f0100c9f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ca4:	50                   	push   %eax
f0100ca5:	e8 0c 4b 00 00       	call   f01057b6 <memset>
f0100caa:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100cad:	8b 1b                	mov    (%ebx),%ebx
f0100caf:	85 db                	test   %ebx,%ebx
f0100cb1:	75 a9                	jne    f0100c5c <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100cb3:	b8 00 00 00 00       	mov    $0x0,%eax
f0100cb8:	e8 65 fe ff ff       	call   f0100b22 <boot_alloc>
f0100cbd:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100cc0:	8b 15 40 a2 2a f0    	mov    0xf02aa240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100cc6:	8b 0d 9c ae 2a f0    	mov    0xf02aae9c,%ecx
		assert(pp < pages + npages);
f0100ccc:	a1 94 ae 2a f0       	mov    0xf02aae94,%eax
f0100cd1:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100cd4:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100cd7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100cda:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100cdd:	be 00 00 00 00       	mov    $0x0,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ce2:	e9 52 01 00 00       	jmp    f0100e39 <check_page_free_list+0x260>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100ce7:	39 ca                	cmp    %ecx,%edx
f0100ce9:	73 19                	jae    f0100d04 <check_page_free_list+0x12b>
f0100ceb:	68 d9 71 10 f0       	push   $0xf01071d9
f0100cf0:	68 e5 71 10 f0       	push   $0xf01071e5
f0100cf5:	68 8b 03 00 00       	push   $0x38b
f0100cfa:	68 bf 71 10 f0       	push   $0xf01071bf
f0100cff:	e8 3c f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100d04:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100d07:	72 19                	jb     f0100d22 <check_page_free_list+0x149>
f0100d09:	68 fa 71 10 f0       	push   $0xf01071fa
f0100d0e:	68 e5 71 10 f0       	push   $0xf01071e5
f0100d13:	68 8c 03 00 00       	push   $0x38c
f0100d18:	68 bf 71 10 f0       	push   $0xf01071bf
f0100d1d:	e8 1e f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d22:	89 d0                	mov    %edx,%eax
f0100d24:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100d27:	a8 07                	test   $0x7,%al
f0100d29:	74 19                	je     f0100d44 <check_page_free_list+0x16b>
f0100d2b:	68 50 75 10 f0       	push   $0xf0107550
f0100d30:	68 e5 71 10 f0       	push   $0xf01071e5
f0100d35:	68 8d 03 00 00       	push   $0x38d
f0100d3a:	68 bf 71 10 f0       	push   $0xf01071bf
f0100d3f:	e8 fc f2 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100d44:	c1 f8 03             	sar    $0x3,%eax
f0100d47:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100d4a:	85 c0                	test   %eax,%eax
f0100d4c:	75 19                	jne    f0100d67 <check_page_free_list+0x18e>
f0100d4e:	68 0e 72 10 f0       	push   $0xf010720e
f0100d53:	68 e5 71 10 f0       	push   $0xf01071e5
f0100d58:	68 90 03 00 00       	push   $0x390
f0100d5d:	68 bf 71 10 f0       	push   $0xf01071bf
f0100d62:	e8 d9 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d67:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d6c:	75 19                	jne    f0100d87 <check_page_free_list+0x1ae>
f0100d6e:	68 1f 72 10 f0       	push   $0xf010721f
f0100d73:	68 e5 71 10 f0       	push   $0xf01071e5
f0100d78:	68 91 03 00 00       	push   $0x391
f0100d7d:	68 bf 71 10 f0       	push   $0xf01071bf
f0100d82:	e8 b9 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d87:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d8c:	75 19                	jne    f0100da7 <check_page_free_list+0x1ce>
f0100d8e:	68 84 75 10 f0       	push   $0xf0107584
f0100d93:	68 e5 71 10 f0       	push   $0xf01071e5
f0100d98:	68 92 03 00 00       	push   $0x392
f0100d9d:	68 bf 71 10 f0       	push   $0xf01071bf
f0100da2:	e8 99 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100da7:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100dac:	75 19                	jne    f0100dc7 <check_page_free_list+0x1ee>
f0100dae:	68 38 72 10 f0       	push   $0xf0107238
f0100db3:	68 e5 71 10 f0       	push   $0xf01071e5
f0100db8:	68 93 03 00 00       	push   $0x393
f0100dbd:	68 bf 71 10 f0       	push   $0xf01071bf
f0100dc2:	e8 79 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100dc7:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100dcc:	0f 86 f1 00 00 00    	jbe    f0100ec3 <check_page_free_list+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100dd2:	89 c7                	mov    %eax,%edi
f0100dd4:	c1 ef 0c             	shr    $0xc,%edi
f0100dd7:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0100dda:	77 12                	ja     f0100dee <check_page_free_list+0x215>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ddc:	50                   	push   %eax
f0100ddd:	68 04 6c 10 f0       	push   $0xf0106c04
f0100de2:	6a 58                	push   $0x58
f0100de4:	68 cb 71 10 f0       	push   $0xf01071cb
f0100de9:	e8 52 f2 ff ff       	call   f0100040 <_panic>
f0100dee:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100df4:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100df7:	0f 86 b6 00 00 00    	jbe    f0100eb3 <check_page_free_list+0x2da>
f0100dfd:	68 a8 75 10 f0       	push   $0xf01075a8
f0100e02:	68 e5 71 10 f0       	push   $0xf01071e5
f0100e07:	68 94 03 00 00       	push   $0x394
f0100e0c:	68 bf 71 10 f0       	push   $0xf01071bf
f0100e11:	e8 2a f2 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e16:	68 52 72 10 f0       	push   $0xf0107252
f0100e1b:	68 e5 71 10 f0       	push   $0xf01071e5
f0100e20:	68 96 03 00 00       	push   $0x396
f0100e25:	68 bf 71 10 f0       	push   $0xf01071bf
f0100e2a:	e8 11 f2 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100e2f:	83 c6 01             	add    $0x1,%esi
f0100e32:	eb 03                	jmp    f0100e37 <check_page_free_list+0x25e>
		else
			++nfree_extmem;
f0100e34:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e37:	8b 12                	mov    (%edx),%edx
f0100e39:	85 d2                	test   %edx,%edx
f0100e3b:	0f 85 a6 fe ff ff    	jne    f0100ce7 <check_page_free_list+0x10e>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100e41:	85 f6                	test   %esi,%esi
f0100e43:	7f 19                	jg     f0100e5e <check_page_free_list+0x285>
f0100e45:	68 6f 72 10 f0       	push   $0xf010726f
f0100e4a:	68 e5 71 10 f0       	push   $0xf01071e5
f0100e4f:	68 9e 03 00 00       	push   $0x39e
f0100e54:	68 bf 71 10 f0       	push   $0xf01071bf
f0100e59:	e8 e2 f1 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100e5e:	85 db                	test   %ebx,%ebx
f0100e60:	7f 19                	jg     f0100e7b <check_page_free_list+0x2a2>
f0100e62:	68 81 72 10 f0       	push   $0xf0107281
f0100e67:	68 e5 71 10 f0       	push   $0xf01071e5
f0100e6c:	68 9f 03 00 00       	push   $0x39f
f0100e71:	68 bf 71 10 f0       	push   $0xf01071bf
f0100e76:	e8 c5 f1 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100e7b:	83 ec 0c             	sub    $0xc,%esp
f0100e7e:	68 f0 75 10 f0       	push   $0xf01075f0
f0100e83:	e8 fa 2a 00 00       	call   f0103982 <cprintf>
}
f0100e88:	eb 49                	jmp    f0100ed3 <check_page_free_list+0x2fa>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100e8a:	a1 40 a2 2a f0       	mov    0xf02aa240,%eax
f0100e8f:	85 c0                	test   %eax,%eax
f0100e91:	0f 85 6f fd ff ff    	jne    f0100c06 <check_page_free_list+0x2d>
f0100e97:	e9 53 fd ff ff       	jmp    f0100bef <check_page_free_list+0x16>
f0100e9c:	83 3d 40 a2 2a f0 00 	cmpl   $0x0,0xf02aa240
f0100ea3:	0f 84 46 fd ff ff    	je     f0100bef <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ea9:	be 00 04 00 00       	mov    $0x400,%esi
f0100eae:	e9 a1 fd ff ff       	jmp    f0100c54 <check_page_free_list+0x7b>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100eb3:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100eb8:	0f 85 76 ff ff ff    	jne    f0100e34 <check_page_free_list+0x25b>
f0100ebe:	e9 53 ff ff ff       	jmp    f0100e16 <check_page_free_list+0x23d>
f0100ec3:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100ec8:	0f 85 61 ff ff ff    	jne    f0100e2f <check_page_free_list+0x256>
f0100ece:	e9 43 ff ff ff       	jmp    f0100e16 <check_page_free_list+0x23d>

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);

	cprintf("check_page_free_list() succeeded!\n");
}
f0100ed3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ed6:	5b                   	pop    %ebx
f0100ed7:	5e                   	pop    %esi
f0100ed8:	5f                   	pop    %edi
f0100ed9:	5d                   	pop    %ebp
f0100eda:	c3                   	ret    

f0100edb <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100edb:	55                   	push   %ebp
f0100edc:	89 e5                	mov    %esp,%ebp
f0100ede:	56                   	push   %esi
f0100edf:	53                   	push   %ebx
	// 	pages[i].pp_link = page_free_list;
	// 	page_free_list = &pages[i];
	// }

	// 1)	first page in use
	pages[0].pp_ref = 1;
f0100ee0:	a1 9c ae 2a f0       	mov    0xf02aae9c,%eax
f0100ee5:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	pages[0].pp_link = 0;
f0100eeb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	extern unsigned char mpentry_start[], mpentry_end[];
	uint32_t size = ROUNDUP(mpentry_end - mpentry_start, PGSIZE);
f0100ef1:	be 31 6a 10 f0       	mov    $0xf0106a31,%esi
f0100ef6:	81 ee b8 59 10 f0    	sub    $0xf01059b8,%esi
f0100efc:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	// cprintf("[?] Init from 0x%x to 0x%x\n", PGSIZE, PGSIZE * npages_basemem);

	// 2)	[1-npages_basemem) free, except APs area (lab4)
	for (i = 1; i < npages_basemem; i++) {
f0100f02:	bb 01 00 00 00       	mov    $0x1,%ebx
		if (i * PGSIZE >= MPENTRY_PADDR && i * PGSIZE < MPENTRY_PADDR + size) {
f0100f07:	81 c6 00 70 00 00    	add    $0x7000,%esi
	extern unsigned char mpentry_start[], mpentry_end[];
	uint32_t size = ROUNDUP(mpentry_end - mpentry_start, PGSIZE);
	// cprintf("[?] Init from 0x%x to 0x%x\n", PGSIZE, PGSIZE * npages_basemem);

	// 2)	[1-npages_basemem) free, except APs area (lab4)
	for (i = 1; i < npages_basemem; i++) {
f0100f0d:	eb 61                	jmp    f0100f70 <page_init+0x95>
f0100f0f:	89 d8                	mov    %ebx,%eax
f0100f11:	c1 e0 0c             	shl    $0xc,%eax
		if (i * PGSIZE >= MPENTRY_PADDR && i * PGSIZE < MPENTRY_PADDR + size) {
f0100f14:	3d ff 6f 00 00       	cmp    $0x6fff,%eax
f0100f19:	76 2a                	jbe    f0100f45 <page_init+0x6a>
f0100f1b:	39 c6                	cmp    %eax,%esi
f0100f1d:	76 26                	jbe    f0100f45 <page_init+0x6a>
			pages[i].pp_ref = 1;
f0100f1f:	a1 9c ae 2a f0       	mov    0xf02aae9c,%eax
f0100f24:	8d 04 d8             	lea    (%eax,%ebx,8),%eax
f0100f27:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link = 0;
f0100f2d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			cprintf("[?] non-boot CPUs (APs)\n");
f0100f33:	83 ec 0c             	sub    $0xc,%esp
f0100f36:	68 92 72 10 f0       	push   $0xf0107292
f0100f3b:	e8 42 2a 00 00       	call   f0103982 <cprintf>
f0100f40:	83 c4 10             	add    $0x10,%esp
f0100f43:	eb 28                	jmp    f0100f6d <page_init+0x92>
		}
		else {
			pages[i].pp_ref = 0;
f0100f45:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100f4c:	89 c2                	mov    %eax,%edx
f0100f4e:	03 15 9c ae 2a f0    	add    0xf02aae9c,%edx
f0100f54:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
			pages[i].pp_link = page_free_list;
f0100f5a:	8b 0d 40 a2 2a f0    	mov    0xf02aa240,%ecx
f0100f60:	89 0a                	mov    %ecx,(%edx)
			page_free_list = &pages[i];
f0100f62:	03 05 9c ae 2a f0    	add    0xf02aae9c,%eax
f0100f68:	a3 40 a2 2a f0       	mov    %eax,0xf02aa240
	extern unsigned char mpentry_start[], mpentry_end[];
	uint32_t size = ROUNDUP(mpentry_end - mpentry_start, PGSIZE);
	// cprintf("[?] Init from 0x%x to 0x%x\n", PGSIZE, PGSIZE * npages_basemem);

	// 2)	[1-npages_basemem) free, except APs area (lab4)
	for (i = 1; i < npages_basemem; i++) {
f0100f6d:	83 c3 01             	add    $0x1,%ebx
f0100f70:	3b 1d 44 a2 2a f0    	cmp    0xf02aa244,%ebx
f0100f76:	72 97                	jb     f0100f0f <page_init+0x34>
f0100f78:	8b 0d 40 a2 2a f0    	mov    0xf02aa240,%ecx
f0100f7e:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100f85:	ba 00 00 00 00       	mov    $0x0,%edx
f0100f8a:	eb 23                	jmp    f0100faf <page_init+0xd4>
	}

	// [npages_basemem, IOPHYSMEM / PGSIZE) free
	// cprintf("[?] %d, %d, %d\n", npages_basemem, IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE);
	for (; i < IOPHYSMEM / PGSIZE; i++) {
		pages[i].pp_ref = 0;
f0100f8c:	89 c2                	mov    %eax,%edx
f0100f8e:	03 15 9c ae 2a f0    	add    0xf02aae9c,%edx
f0100f94:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f0100f9a:	89 0a                	mov    %ecx,(%edx)
		page_free_list = &pages[i];
f0100f9c:	89 c1                	mov    %eax,%ecx
f0100f9e:	03 0d 9c ae 2a f0    	add    0xf02aae9c,%ecx
		}
	}

	// [npages_basemem, IOPHYSMEM / PGSIZE) free
	// cprintf("[?] %d, %d, %d\n", npages_basemem, IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE);
	for (; i < IOPHYSMEM / PGSIZE; i++) {
f0100fa4:	83 c3 01             	add    $0x1,%ebx
f0100fa7:	83 c0 08             	add    $0x8,%eax
f0100faa:	ba 01 00 00 00       	mov    $0x1,%edx
f0100faf:	81 fb 9f 00 00 00    	cmp    $0x9f,%ebx
f0100fb5:	76 d5                	jbe    f0100f8c <page_init+0xb1>
f0100fb7:	84 d2                	test   %dl,%dl
f0100fb9:	74 06                	je     f0100fc1 <page_init+0xe6>
f0100fbb:	89 0d 40 a2 2a f0    	mov    %ecx,0xf02aa240
f0100fc1:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100fc8:	eb 1a                	jmp    f0100fe4 <page_init+0x109>
		page_free_list = &pages[i];
	}

	// 3) [IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE) in use
	for (; i < EXTPHYSMEM / PGSIZE; i++) {
		pages[i].pp_ref = 1;
f0100fca:	89 c2                	mov    %eax,%edx
f0100fcc:	03 15 9c ae 2a f0    	add    0xf02aae9c,%edx
f0100fd2:	66 c7 42 04 01 00    	movw   $0x1,0x4(%edx)
		pages[i].pp_link = 0;
f0100fd8:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}

	// 3) [IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE) in use
	for (; i < EXTPHYSMEM / PGSIZE; i++) {
f0100fde:	83 c3 01             	add    $0x1,%ebx
f0100fe1:	83 c0 08             	add    $0x8,%eax
f0100fe4:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f0100fea:	76 de                	jbe    f0100fca <page_init+0xef>
f0100fec:	8d 34 dd 00 00 00 00 	lea    0x0(,%ebx,8),%esi
f0100ff3:	eb 1a                	jmp    f010100f <page_init+0x134>

	// cprintf("[?] Init from 0x%x to 0x%x\n", EXTPHYSMEM, PGSIZE * npages);
	// cprintf("[?] %d\n", PADDR(boot_alloc(0)) / PGSIZE);
	// 4) [EXTPHYSMEM / PGSIZE, kernel end) in use
	for (; i < PADDR(boot_alloc(0)) / PGSIZE; i++) {
		pages[i].pp_ref = 1;
f0100ff5:	89 f0                	mov    %esi,%eax
f0100ff7:	03 05 9c ae 2a f0    	add    0xf02aae9c,%eax
f0100ffd:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
		pages[i].pp_link = 0;
f0101003:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}

	// cprintf("[?] Init from 0x%x to 0x%x\n", EXTPHYSMEM, PGSIZE * npages);
	// cprintf("[?] %d\n", PADDR(boot_alloc(0)) / PGSIZE);
	// 4) [EXTPHYSMEM / PGSIZE, kernel end) in use
	for (; i < PADDR(boot_alloc(0)) / PGSIZE; i++) {
f0101009:	83 c3 01             	add    $0x1,%ebx
f010100c:	83 c6 08             	add    $0x8,%esi
f010100f:	b8 00 00 00 00       	mov    $0x0,%eax
f0101014:	e8 09 fb ff ff       	call   f0100b22 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101019:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010101e:	77 15                	ja     f0101035 <page_init+0x15a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101020:	50                   	push   %eax
f0101021:	68 28 6c 10 f0       	push   $0xf0106c28
f0101026:	68 7d 01 00 00       	push   $0x17d
f010102b:	68 bf 71 10 f0       	push   $0xf01071bf
f0101030:	e8 0b f0 ff ff       	call   f0100040 <_panic>
f0101035:	05 00 00 00 10       	add    $0x10000000,%eax
f010103a:	c1 e8 0c             	shr    $0xc,%eax
f010103d:	39 c3                	cmp    %eax,%ebx
f010103f:	72 b4                	jb     f0100ff5 <page_init+0x11a>
f0101041:	8b 0d 40 a2 2a f0    	mov    0xf02aa240,%ecx
f0101047:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f010104e:	ba 00 00 00 00       	mov    $0x0,%edx
f0101053:	eb 23                	jmp    f0101078 <page_init+0x19d>
		pages[i].pp_link = 0;
	}

	// [kernel end, npages) free
	for (; i < npages; i++) {
		pages[i].pp_ref = 0;
f0101055:	89 c2                	mov    %eax,%edx
f0101057:	03 15 9c ae 2a f0    	add    0xf02aae9c,%edx
f010105d:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f0101063:	89 0a                	mov    %ecx,(%edx)
		page_free_list = &pages[i];
f0101065:	89 c1                	mov    %eax,%ecx
f0101067:	03 0d 9c ae 2a f0    	add    0xf02aae9c,%ecx
		pages[i].pp_ref = 1;
		pages[i].pp_link = 0;
	}

	// [kernel end, npages) free
	for (; i < npages; i++) {
f010106d:	83 c3 01             	add    $0x1,%ebx
f0101070:	83 c0 08             	add    $0x8,%eax
f0101073:	ba 01 00 00 00       	mov    $0x1,%edx
f0101078:	3b 1d 94 ae 2a f0    	cmp    0xf02aae94,%ebx
f010107e:	72 d5                	jb     f0101055 <page_init+0x17a>
f0101080:	84 d2                	test   %dl,%dl
f0101082:	74 06                	je     f010108a <page_init+0x1af>
f0101084:	89 0d 40 a2 2a f0    	mov    %ecx,0xf02aa240
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}

}
f010108a:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010108d:	5b                   	pop    %ebx
f010108e:	5e                   	pop    %esi
f010108f:	5d                   	pop    %ebp
f0101090:	c3                   	ret    

f0101091 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0101091:	55                   	push   %ebp
f0101092:	89 e5                	mov    %esp,%ebp
f0101094:	56                   	push   %esi
f0101095:	53                   	push   %ebx
	// Fill this function in

	// no more page in free list, we run out of free memory
	if (page_free_list == 0)
f0101096:	8b 1d 40 a2 2a f0    	mov    0xf02aa240,%ebx
f010109c:	85 db                	test   %ebx,%ebx
f010109e:	74 59                	je     f01010f9 <page_alloc+0x68>
		return 0;

	// get the previous page in free link
	struct PageInfo* last_free = page_free_list->pp_link;
f01010a0:	8b 33                	mov    (%ebx),%esi
	struct PageInfo* result = page_free_list;

	// get a free page from the list
	page_free_list->pp_link = 0;
f01010a2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (alloc_flags & ALLOC_ZERO) {
f01010a8:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01010ac:	74 45                	je     f01010f3 <page_alloc+0x62>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01010ae:	89 d8                	mov    %ebx,%eax
f01010b0:	2b 05 9c ae 2a f0    	sub    0xf02aae9c,%eax
f01010b6:	c1 f8 03             	sar    $0x3,%eax
f01010b9:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01010bc:	89 c2                	mov    %eax,%edx
f01010be:	c1 ea 0c             	shr    $0xc,%edx
f01010c1:	3b 15 94 ae 2a f0    	cmp    0xf02aae94,%edx
f01010c7:	72 12                	jb     f01010db <page_alloc+0x4a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010c9:	50                   	push   %eax
f01010ca:	68 04 6c 10 f0       	push   $0xf0106c04
f01010cf:	6a 58                	push   $0x58
f01010d1:	68 cb 71 10 f0       	push   $0xf01071cb
f01010d6:	e8 65 ef ff ff       	call   f0100040 <_panic>
		// cprintf("[?] alloc zero, %x, %x\n", page_free_list, PADDR(page_free_list));
		// memset((char *)page2pa(page_free_list), 0, PGSIZE);
		memset(page2kva(page_free_list), 0, PGSIZE);
f01010db:	83 ec 04             	sub    $0x4,%esp
f01010de:	68 00 10 00 00       	push   $0x1000
f01010e3:	6a 00                	push   $0x0
f01010e5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01010ea:	50                   	push   %eax
f01010eb:	e8 c6 46 00 00       	call   f01057b6 <memset>
f01010f0:	83 c4 10             	add    $0x10,%esp
	}
	
	// update free list head
	page_free_list = last_free;
f01010f3:	89 35 40 a2 2a f0    	mov    %esi,0xf02aa240

	return result;
}
f01010f9:	89 d8                	mov    %ebx,%eax
f01010fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01010fe:	5b                   	pop    %ebx
f01010ff:	5e                   	pop    %esi
f0101100:	5d                   	pop    %ebp
f0101101:	c3                   	ret    

f0101102 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0101102:	55                   	push   %ebp
f0101103:	89 e5                	mov    %esp,%ebp
f0101105:	83 ec 08             	sub    $0x8,%esp
f0101108:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.

	if (pp == 0)
f010110b:	85 c0                	test   %eax,%eax
f010110d:	74 47                	je     f0101156 <page_free+0x54>
		return;
	if (pp->pp_link != 0)
f010110f:	83 38 00             	cmpl   $0x0,(%eax)
f0101112:	74 17                	je     f010112b <page_free+0x29>
		panic("page_free: double free or corrupted\n");
f0101114:	83 ec 04             	sub    $0x4,%esp
f0101117:	68 14 76 10 f0       	push   $0xf0107614
f010111c:	68 c1 01 00 00       	push   $0x1c1
f0101121:	68 bf 71 10 f0       	push   $0xf01071bf
f0101126:	e8 15 ef ff ff       	call   f0100040 <_panic>
	if (pp->pp_ref != 0)
f010112b:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101130:	74 17                	je     f0101149 <page_free+0x47>
		panic("page_free: other pointers still point to it, mind use-after-free!\n");
f0101132:	83 ec 04             	sub    $0x4,%esp
f0101135:	68 3c 76 10 f0       	push   $0xf010763c
f010113a:	68 c3 01 00 00       	push   $0x1c3
f010113f:	68 bf 71 10 f0       	push   $0xf01071bf
f0101144:	e8 f7 ee ff ff       	call   f0100040 <_panic>

	pp->pp_link = page_free_list;
f0101149:	8b 15 40 a2 2a f0    	mov    0xf02aa240,%edx
f010114f:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101151:	a3 40 a2 2a f0       	mov    %eax,0xf02aa240

}
f0101156:	c9                   	leave  
f0101157:	c3                   	ret    

f0101158 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0101158:	55                   	push   %ebp
f0101159:	89 e5                	mov    %esp,%ebp
f010115b:	83 ec 08             	sub    $0x8,%esp
f010115e:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0101161:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0101165:	83 e8 01             	sub    $0x1,%eax
f0101168:	66 89 42 04          	mov    %ax,0x4(%edx)
f010116c:	66 85 c0             	test   %ax,%ax
f010116f:	75 0c                	jne    f010117d <page_decref+0x25>
		page_free(pp);
f0101171:	83 ec 0c             	sub    $0xc,%esp
f0101174:	52                   	push   %edx
f0101175:	e8 88 ff ff ff       	call   f0101102 <page_free>
f010117a:	83 c4 10             	add    $0x10,%esp
}
f010117d:	c9                   	leave  
f010117e:	c3                   	ret    

f010117f <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that manipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f010117f:	55                   	push   %ebp
f0101180:	89 e5                	mov    %esp,%ebp
f0101182:	57                   	push   %edi
f0101183:	56                   	push   %esi
f0101184:	53                   	push   %ebx
f0101185:	83 ec 0c             	sub    $0xc,%esp
f0101188:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in

	// we have virtual address
	// cprintf("[?] %x\n", va);

	if ((uint32_t)va == 0xeebfe000)
f010118b:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
f0101191:	0f 85 c8 00 00 00    	jne    f010125f <pgdir_walk+0xe0>
		cprintf("Error hit\n");
f0101197:	83 ec 0c             	sub    $0xc,%esp
f010119a:	68 ab 72 10 f0       	push   $0xf01072ab
f010119f:	e8 de 27 00 00       	call   f0103982 <cprintf>
	uint32_t Page_Directory_Index = PDX(va);
	uint32_t Page_Table_Index = PTX(va);
	uint32_t Offset_In_PTE = PGOFF(va);

	// level 2 page table not exist
	if (pgdir[Page_Directory_Index] == 0) {
f01011a4:	8b 45 08             	mov    0x8(%ebp),%eax
f01011a7:	8d b8 e8 0e 00 00    	lea    0xee8(%eax),%edi
f01011ad:	83 c4 10             	add    $0x10,%esp
f01011b0:	83 b8 e8 0e 00 00 00 	cmpl   $0x0,0xee8(%eax)
f01011b7:	75 53                	jne    f010120c <pgdir_walk+0x8d>

		if ((uint32_t)va == 0xeebfe000)
			cprintf("Error hit2\n");
f01011b9:	83 ec 0c             	sub    $0xc,%esp
f01011bc:	68 b6 72 10 f0       	push   $0xf01072b6
f01011c1:	e8 bc 27 00 00       	call   f0103982 <cprintf>
f01011c6:	83 c4 10             	add    $0x10,%esp

	if ((uint32_t)va == 0xeebfe000)
		cprintf("Error hit\n");

	uint32_t Page_Directory_Index = PDX(va);
	uint32_t Page_Table_Index = PTX(va);
f01011c9:	be fe 03 00 00       	mov    $0x3fe,%esi
	if (pgdir[Page_Directory_Index] == 0) {

		if ((uint32_t)va == 0xeebfe000)
			cprintf("Error hit2\n");

		if (create == 0)
f01011ce:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01011d2:	74 7d                	je     f0101251 <pgdir_walk+0xd2>
			return NULL;
		
		// allocate a new physical page to be a page table
		struct PageInfo *new_page = page_alloc(ALLOC_ZERO);
f01011d4:	83 ec 0c             	sub    $0xc,%esp
f01011d7:	6a 01                	push   $0x1
f01011d9:	e8 b3 fe ff ff       	call   f0101091 <page_alloc>
		// cprintf("[??] %x\n", new_page);
		if (new_page == 0)	// page allocate fail
f01011de:	83 c4 10             	add    $0x10,%esp
f01011e1:	85 c0                	test   %eax,%eax
f01011e3:	74 73                	je     f0101258 <pgdir_walk+0xd9>
		// set level 1 page table entry to this new level 2 page table
		// this new page is for level2 PT, so flags are:
		// 	PTE_P: this page is present
		//	PTE_U: user process can use this page
		//	PTE_W: this page can be edit
		pgdir[Page_Directory_Index] = page2pa(new_page) | PTE_P | PTE_U | PTE_W;
f01011e5:	89 c2                	mov    %eax,%edx
f01011e7:	2b 15 9c ae 2a f0    	sub    0xf02aae9c,%edx
f01011ed:	c1 fa 03             	sar    $0x3,%edx
f01011f0:	c1 e2 0c             	shl    $0xc,%edx
f01011f3:	83 ca 07             	or     $0x7,%edx
f01011f6:	89 17                	mov    %edx,(%edi)
		new_page->pp_ref = 1;
f01011f8:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)

	}

	if ((uint32_t)va == 0xeebfe000)
f01011fe:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
f0101204:	0f 85 9e 00 00 00    	jne    f01012a8 <pgdir_walk+0x129>
f010120a:	eb 05                	jmp    f0101211 <pgdir_walk+0x92>

	if ((uint32_t)va == 0xeebfe000)
		cprintf("Error hit\n");

	uint32_t Page_Directory_Index = PDX(va);
	uint32_t Page_Table_Index = PTX(va);
f010120c:	be fe 03 00 00       	mov    $0x3fe,%esi
		new_page->pp_ref = 1;

	}

	if ((uint32_t)va == 0xeebfe000)
		cprintf("Error hit3, 0x%x\n", pgdir[Page_Directory_Index]);
f0101211:	83 ec 08             	sub    $0x8,%esp
f0101214:	ff 37                	pushl  (%edi)
f0101216:	68 c2 72 10 f0       	push   $0xf01072c2
f010121b:	e8 62 27 00 00       	call   f0103982 <cprintf>
	// cprintf("[?] %x\n", KADDR(PTE_ADDR(pgdir[Page_Directory_Index])));
	
	// remember each entry is 4 byte long
	// so we need to convert type to pte_t * in order to add 4 on address each time
	// instead of add 1
	pte_t *p = (pte_t *) KADDR(PTE_ADDR(pgdir[Page_Directory_Index]));
f0101220:	8b 07                	mov    (%edi),%eax
f0101222:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101227:	89 c2                	mov    %eax,%edx
f0101229:	c1 ea 0c             	shr    $0xc,%edx
f010122c:	83 c4 10             	add    $0x10,%esp
f010122f:	3b 15 94 ae 2a f0    	cmp    0xf02aae94,%edx
f0101235:	72 48                	jb     f010127f <pgdir_walk+0x100>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101237:	50                   	push   %eax
f0101238:	68 04 6c 10 f0       	push   $0xf0106c04
f010123d:	68 1c 02 00 00       	push   $0x21c
f0101242:	68 bf 71 10 f0       	push   $0xf01071bf
f0101247:	e8 f4 ed ff ff       	call   f0100040 <_panic>

	if ((uint32_t)va == 0xeebfe000)
		cprintf("Error hit4, 0x%x, 0x%x\n", (uint32_t)p, (uint32_t)*p);

	return &p[Page_Table_Index];
f010124c:	8d 04 b3             	lea    (%ebx,%esi,4),%eax
f010124f:	eb 70                	jmp    f01012c1 <pgdir_walk+0x142>

		if ((uint32_t)va == 0xeebfe000)
			cprintf("Error hit2\n");

		if (create == 0)
			return NULL;
f0101251:	b8 00 00 00 00       	mov    $0x0,%eax
f0101256:	eb 69                	jmp    f01012c1 <pgdir_walk+0x142>
		
		// allocate a new physical page to be a page table
		struct PageInfo *new_page = page_alloc(ALLOC_ZERO);
		// cprintf("[??] %x\n", new_page);
		if (new_page == 0)	// page allocate fail
			return NULL;
f0101258:	b8 00 00 00 00       	mov    $0x0,%eax
f010125d:	eb 62                	jmp    f01012c1 <pgdir_walk+0x142>

	if ((uint32_t)va == 0xeebfe000)
		cprintf("Error hit\n");

	uint32_t Page_Directory_Index = PDX(va);
	uint32_t Page_Table_Index = PTX(va);
f010125f:	89 de                	mov    %ebx,%esi
f0101261:	c1 ee 0c             	shr    $0xc,%esi
f0101264:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	uint32_t Offset_In_PTE = PGOFF(va);

	// level 2 page table not exist
	if (pgdir[Page_Directory_Index] == 0) {
f010126a:	89 d8                	mov    %ebx,%eax
f010126c:	c1 e8 16             	shr    $0x16,%eax
f010126f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101272:	8d 3c 81             	lea    (%ecx,%eax,4),%edi
f0101275:	83 3f 00             	cmpl   $0x0,(%edi)
f0101278:	75 2e                	jne    f01012a8 <pgdir_walk+0x129>
f010127a:	e9 4f ff ff ff       	jmp    f01011ce <pgdir_walk+0x4f>
	return (void *)(pa + KERNBASE);
f010127f:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
f0101285:	89 d3                	mov    %edx,%ebx
	// so we need to convert type to pte_t * in order to add 4 on address each time
	// instead of add 1
	pte_t *p = (pte_t *) KADDR(PTE_ADDR(pgdir[Page_Directory_Index]));

	if ((uint32_t)va == 0xeebfe000)
		cprintf("Error hit4, 0x%x, 0x%x\n", (uint32_t)p, (uint32_t)*p);
f0101287:	83 ec 04             	sub    $0x4,%esp
f010128a:	ff b0 00 00 00 f0    	pushl  -0x10000000(%eax)
f0101290:	52                   	push   %edx
f0101291:	68 d4 72 10 f0       	push   $0xf01072d4
f0101296:	e8 e7 26 00 00       	call   f0103982 <cprintf>
f010129b:	83 c4 10             	add    $0x10,%esp
f010129e:	eb ac                	jmp    f010124c <pgdir_walk+0xcd>
f01012a0:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f01012a6:	eb a4                	jmp    f010124c <pgdir_walk+0xcd>
	// cprintf("[?] %x\n", KADDR(PTE_ADDR(pgdir[Page_Directory_Index])));
	
	// remember each entry is 4 byte long
	// so we need to convert type to pte_t * in order to add 4 on address each time
	// instead of add 1
	pte_t *p = (pte_t *) KADDR(PTE_ADDR(pgdir[Page_Directory_Index]));
f01012a8:	8b 07                	mov    (%edi),%eax
f01012aa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01012af:	89 c2                	mov    %eax,%edx
f01012b1:	c1 ea 0c             	shr    $0xc,%edx
f01012b4:	3b 15 94 ae 2a f0    	cmp    0xf02aae94,%edx
f01012ba:	72 e4                	jb     f01012a0 <pgdir_walk+0x121>
f01012bc:	e9 76 ff ff ff       	jmp    f0101237 <pgdir_walk+0xb8>

	if ((uint32_t)va == 0xeebfe000)
		cprintf("Error hit4, 0x%x, 0x%x\n", (uint32_t)p, (uint32_t)*p);

	return &p[Page_Table_Index];
}
f01012c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012c4:	5b                   	pop    %ebx
f01012c5:	5e                   	pop    %esi
f01012c6:	5f                   	pop    %edi
f01012c7:	5d                   	pop    %ebp
f01012c8:	c3                   	ret    

f01012c9 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f01012c9:	55                   	push   %ebp
f01012ca:	89 e5                	mov    %esp,%ebp
f01012cc:	57                   	push   %edi
f01012cd:	56                   	push   %esi
f01012ce:	53                   	push   %ebx
f01012cf:	83 ec 20             	sub    $0x20,%esp
f01012d2:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01012d5:	89 d7                	mov    %edx,%edi
f01012d7:	89 cb                	mov    %ecx,%ebx
	
	cprintf("[boot_map_region] 0x%x, len 0x%x\n", va, size);
f01012d9:	51                   	push   %ecx
f01012da:	52                   	push   %edx
f01012db:	68 80 76 10 f0       	push   $0xf0107680
f01012e0:	e8 9d 26 00 00       	call   f0103982 <cprintf>
	
	// Fill this function in	
	if (size % PGSIZE != 0)
f01012e5:	83 c4 10             	add    $0x10,%esp
f01012e8:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f01012ee:	74 17                	je     f0101307 <boot_map_region+0x3e>
		panic("boot_map_region: size is not a multiple of PGSIZE\n");
f01012f0:	83 ec 04             	sub    $0x4,%esp
f01012f3:	68 a4 76 10 f0       	push   $0xf01076a4
f01012f8:	68 37 02 00 00       	push   $0x237
f01012fd:	68 bf 71 10 f0       	push   $0xf01071bf
f0101302:	e8 39 ed ff ff       	call   f0100040 <_panic>
	
	if (va % PGSIZE != 0 || pa % PGSIZE != 0)
f0101307:	f7 c7 ff 0f 00 00    	test   $0xfff,%edi
f010130d:	75 24                	jne    f0101333 <boot_map_region+0x6a>
f010130f:	f7 45 08 ff 0f 00 00 	testl  $0xfff,0x8(%ebp)
f0101316:	75 1b                	jne    f0101333 <boot_map_region+0x6a>
f0101318:	c1 eb 0c             	shr    $0xc,%ebx
f010131b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
		panic("boot_map_region: va or pa is not page-aligned\n");


	// set all pages related
	for (int i=0; i<size/PGSIZE; i++) {
f010131e:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101321:	be 00 00 00 00       	mov    $0x0,%esi

		// find the real PTE for va
		// create on walk, if not present
		pte_t* pte = pgdir_walk(pgdir, (void *)va, 1);	
f0101326:	29 df                	sub    %ebx,%edi

		// set the real PTE to pa, zero out least 12 bits
		*pte = PTE_ADDR(pa);
		
		// set flags
		*pte |= (perm | PTE_P);
f0101328:	8b 45 0c             	mov    0xc(%ebp),%eax
f010132b:	83 c8 01             	or     $0x1,%eax
f010132e:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0101331:	eb 5c                	jmp    f010138f <boot_map_region+0xc6>
	// Fill this function in	
	if (size % PGSIZE != 0)
		panic("boot_map_region: size is not a multiple of PGSIZE\n");
	
	if (va % PGSIZE != 0 || pa % PGSIZE != 0)
		panic("boot_map_region: va or pa is not page-aligned\n");
f0101333:	83 ec 04             	sub    $0x4,%esp
f0101336:	68 d8 76 10 f0       	push   $0xf01076d8
f010133b:	68 3a 02 00 00       	push   $0x23a
f0101340:	68 bf 71 10 f0       	push   $0xf01071bf
f0101345:	e8 f6 ec ff ff       	call   f0100040 <_panic>
	// set all pages related
	for (int i=0; i<size/PGSIZE; i++) {

		// find the real PTE for va
		// create on walk, if not present
		pte_t* pte = pgdir_walk(pgdir, (void *)va, 1);	
f010134a:	83 ec 04             	sub    $0x4,%esp
f010134d:	6a 01                	push   $0x1
f010134f:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f0101352:	50                   	push   %eax
f0101353:	ff 75 e0             	pushl  -0x20(%ebp)
f0101356:	e8 24 fe ff ff       	call   f010117f <pgdir_walk>

		if (pte == 0)
f010135b:	83 c4 10             	add    $0x10,%esp
f010135e:	85 c0                	test   %eax,%eax
f0101360:	75 17                	jne    f0101379 <boot_map_region+0xb0>
			panic("boot_map_region: pgdir_walk return NULL\n");
f0101362:	83 ec 04             	sub    $0x4,%esp
f0101365:	68 08 77 10 f0       	push   $0xf0107708
f010136a:	68 45 02 00 00       	push   $0x245
f010136f:	68 bf 71 10 f0       	push   $0xf01071bf
f0101374:	e8 c7 ec ff ff       	call   f0100040 <_panic>

		// set the real PTE to pa, zero out least 12 bits
		*pte = PTE_ADDR(pa);
		
		// set flags
		*pte |= (perm | PTE_P);
f0101379:	89 da                	mov    %ebx,%edx
f010137b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101381:	0b 55 dc             	or     -0x24(%ebp),%edx
f0101384:	89 10                	mov    %edx,(%eax)

		// deal with next page
		va += PGSIZE;
		pa += PGSIZE;
f0101386:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	if (va % PGSIZE != 0 || pa % PGSIZE != 0)
		panic("boot_map_region: va or pa is not page-aligned\n");


	// set all pages related
	for (int i=0; i<size/PGSIZE; i++) {
f010138c:	83 c6 01             	add    $0x1,%esi
f010138f:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0101392:	75 b6                	jne    f010134a <boot_map_region+0x81>
		va += PGSIZE;
		pa += PGSIZE;

	}

}
f0101394:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101397:	5b                   	pop    %ebx
f0101398:	5e                   	pop    %esi
f0101399:	5f                   	pop    %edi
f010139a:	5d                   	pop    %ebp
f010139b:	c3                   	ret    

f010139c <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f010139c:	55                   	push   %ebp
f010139d:	89 e5                	mov    %esp,%ebp
f010139f:	53                   	push   %ebx
f01013a0:	83 ec 08             	sub    $0x8,%esp
f01013a3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in

	// do a page table walk to find real PTE
	pte_t * pte = pgdir_walk(pgdir, va, 0);
f01013a6:	6a 00                	push   $0x0
f01013a8:	ff 75 0c             	pushl  0xc(%ebp)
f01013ab:	ff 75 08             	pushl  0x8(%ebp)
f01013ae:	e8 cc fd ff ff       	call   f010117f <pgdir_walk>

	// cprintf("[?] In page_lookup\n");
	// cprintf("[?] %x\n", pte);

	// if not present, return NULL
	if (pte == 0 || *pte == 0)
f01013b3:	83 c4 10             	add    $0x10,%esp
f01013b6:	85 c0                	test   %eax,%eax
f01013b8:	74 37                	je     f01013f1 <page_lookup+0x55>
f01013ba:	83 38 00             	cmpl   $0x0,(%eax)
f01013bd:	74 39                	je     f01013f8 <page_lookup+0x5c>
		return NULL;
	
	// store pte
	if (pte_store != 0)
f01013bf:	85 db                	test   %ebx,%ebx
f01013c1:	74 02                	je     f01013c5 <page_lookup+0x29>
		*pte_store = pte;
f01013c3:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01013c5:	8b 00                	mov    (%eax),%eax
f01013c7:	c1 e8 0c             	shr    $0xc,%eax
f01013ca:	3b 05 94 ae 2a f0    	cmp    0xf02aae94,%eax
f01013d0:	72 14                	jb     f01013e6 <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f01013d2:	83 ec 04             	sub    $0x4,%esp
f01013d5:	68 34 77 10 f0       	push   $0xf0107734
f01013da:	6a 51                	push   $0x51
f01013dc:	68 cb 71 10 f0       	push   $0xf01071cb
f01013e1:	e8 5a ec ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f01013e6:	8b 15 9c ae 2a f0    	mov    0xf02aae9c,%edx
f01013ec:	8d 04 c2             	lea    (%edx,%eax,8),%eax

	return pa2page(PTE_ADDR(*pte)) ;
f01013ef:	eb 0c                	jmp    f01013fd <page_lookup+0x61>
	// cprintf("[?] In page_lookup\n");
	// cprintf("[?] %x\n", pte);

	// if not present, return NULL
	if (pte == 0 || *pte == 0)
		return NULL;
f01013f1:	b8 00 00 00 00       	mov    $0x0,%eax
f01013f6:	eb 05                	jmp    f01013fd <page_lookup+0x61>
f01013f8:	b8 00 00 00 00       	mov    $0x0,%eax
	// store pte
	if (pte_store != 0)
		*pte_store = pte;

	return pa2page(PTE_ADDR(*pte)) ;
}
f01013fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101400:	c9                   	leave  
f0101401:	c3                   	ret    

f0101402 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101402:	55                   	push   %ebp
f0101403:	89 e5                	mov    %esp,%ebp
f0101405:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f0101408:	e8 c9 49 00 00       	call   f0105dd6 <cpunum>
f010140d:	6b c0 74             	imul   $0x74,%eax,%eax
f0101410:	83 b8 28 b0 2a f0 00 	cmpl   $0x0,-0xfd54fd8(%eax)
f0101417:	74 16                	je     f010142f <tlb_invalidate+0x2d>
f0101419:	e8 b8 49 00 00       	call   f0105dd6 <cpunum>
f010141e:	6b c0 74             	imul   $0x74,%eax,%eax
f0101421:	8b 80 28 b0 2a f0    	mov    -0xfd54fd8(%eax),%eax
f0101427:	8b 55 08             	mov    0x8(%ebp),%edx
f010142a:	39 50 60             	cmp    %edx,0x60(%eax)
f010142d:	75 06                	jne    f0101435 <tlb_invalidate+0x33>
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010142f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101432:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f0101435:	c9                   	leave  
f0101436:	c3                   	ret    

f0101437 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101437:	55                   	push   %ebp
f0101438:	89 e5                	mov    %esp,%ebp
f010143a:	56                   	push   %esi
f010143b:	53                   	push   %ebx
f010143c:	83 ec 14             	sub    $0x14,%esp
f010143f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101442:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in

	// pte_t *tmp;
	pte_t *pte_store = NULL;
f0101445:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	struct PageInfo * pp = page_lookup(pgdir, va, &pte_store);
f010144c:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010144f:	50                   	push   %eax
f0101450:	56                   	push   %esi
f0101451:	53                   	push   %ebx
f0101452:	e8 45 ff ff ff       	call   f010139c <page_lookup>

	// if not present, silently return
	if (pp == NULL)
f0101457:	83 c4 10             	add    $0x10,%esp
f010145a:	85 c0                	test   %eax,%eax
f010145c:	74 1f                	je     f010147d <page_remove+0x46>
		return;

	// decrement ref count, and if reaches 0, free it
	page_decref(pp);
f010145e:	83 ec 0c             	sub    $0xc,%esp
f0101461:	50                   	push   %eax
f0101462:	e8 f1 fc ff ff       	call   f0101158 <page_decref>

	// null the real PTE pointer 
	*pte_store = 0;
f0101467:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010146a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	// cprintf("[?] In page_remove\n");
	// cprintf("[?] *pte_store:%x, **pte_store:%x\n", *pte_store, **pte_store);

	// tlb invalidate
	tlb_invalidate(pgdir, va);
f0101470:	83 c4 08             	add    $0x8,%esp
f0101473:	56                   	push   %esi
f0101474:	53                   	push   %ebx
f0101475:	e8 88 ff ff ff       	call   f0101402 <tlb_invalidate>
f010147a:	83 c4 10             	add    $0x10,%esp

}
f010147d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101480:	5b                   	pop    %ebx
f0101481:	5e                   	pop    %esi
f0101482:	5d                   	pop    %ebp
f0101483:	c3                   	ret    

f0101484 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101484:	55                   	push   %ebp
f0101485:	89 e5                	mov    %esp,%ebp
f0101487:	57                   	push   %edi
f0101488:	56                   	push   %esi
f0101489:	53                   	push   %ebx
f010148a:	83 ec 10             	sub    $0x10,%esp
f010148d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101490:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in

	// find the real PTE for va
	// create on walk, if not present
	pte_t* pte = pgdir_walk(pgdir, va, 1);	
f0101493:	6a 01                	push   $0x1
f0101495:	57                   	push   %edi
f0101496:	ff 75 08             	pushl  0x8(%ebp)
f0101499:	e8 e1 fc ff ff       	call   f010117f <pgdir_walk>

	if (pte == 0)
f010149e:	83 c4 10             	add    $0x10,%esp
f01014a1:	85 c0                	test   %eax,%eax
f01014a3:	74 59                	je     f01014fe <page_insert+0x7a>
f01014a5:	89 c6                	mov    %eax,%esi
		return -E_NO_MEM;

	// already have a page
	// remove it and invalidate tlb
	if (*pte != 0) {
f01014a7:	8b 00                	mov    (%eax),%eax
f01014a9:	85 c0                	test   %eax,%eax
f01014ab:	74 2d                	je     f01014da <page_insert+0x56>
		// corner case
		if (page2pa(pp) == PTE_ADDR(*pte))
f01014ad:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01014b2:	89 da                	mov    %ebx,%edx
f01014b4:	2b 15 9c ae 2a f0    	sub    0xf02aae9c,%edx
f01014ba:	c1 fa 03             	sar    $0x3,%edx
f01014bd:	c1 e2 0c             	shl    $0xc,%edx
f01014c0:	39 d0                	cmp    %edx,%eax
f01014c2:	75 07                	jne    f01014cb <page_insert+0x47>
			pp->pp_ref--;	// keep pp_ref consistent, in the meantime change perm potentially.
f01014c4:	66 83 6b 04 01       	subw   $0x1,0x4(%ebx)
f01014c9:	eb 0f                	jmp    f01014da <page_insert+0x56>
		else
			page_remove(pgdir, va);
f01014cb:	83 ec 08             	sub    $0x8,%esp
f01014ce:	57                   	push   %edi
f01014cf:	ff 75 08             	pushl  0x8(%ebp)
f01014d2:	e8 60 ff ff ff       	call   f0101437 <page_remove>
f01014d7:	83 c4 10             	add    $0x10,%esp

	// set the real PTE to pa, zero out least 12 bits
	*pte = PTE_ADDR(page2pa(pp));
	
	// set flags
	*pte |= (perm | PTE_P);
f01014da:	89 d8                	mov    %ebx,%eax
f01014dc:	2b 05 9c ae 2a f0    	sub    0xf02aae9c,%eax
f01014e2:	c1 f8 03             	sar    $0x3,%eax
f01014e5:	c1 e0 0c             	shl    $0xc,%eax
f01014e8:	8b 55 14             	mov    0x14(%ebp),%edx
f01014eb:	83 ca 01             	or     $0x1,%edx
f01014ee:	09 d0                	or     %edx,%eax
f01014f0:	89 06                	mov    %eax,(%esi)

	// increment ref cnt
	pp->pp_ref++;
f01014f2:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)

	return 0;
f01014f7:	b8 00 00 00 00       	mov    $0x0,%eax
f01014fc:	eb 05                	jmp    f0101503 <page_insert+0x7f>
	// find the real PTE for va
	// create on walk, if not present
	pte_t* pte = pgdir_walk(pgdir, va, 1);	

	if (pte == 0)
		return -E_NO_MEM;
f01014fe:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax

	// increment ref cnt
	pp->pp_ref++;

	return 0;
}
f0101503:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101506:	5b                   	pop    %ebx
f0101507:	5e                   	pop    %esi
f0101508:	5f                   	pop    %edi
f0101509:	5d                   	pop    %ebp
f010150a:	c3                   	ret    

f010150b <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f010150b:	55                   	push   %ebp
f010150c:	89 e5                	mov    %esp,%ebp
f010150e:	56                   	push   %esi
f010150f:	53                   	push   %ebx
f0101510:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	// panic("mmio_map_region not implemented");

	uintptr_t mmio = base;
f0101513:	8b 35 00 33 12 f0    	mov    0xf0123300,%esi

	if (ROUNDUP(mmio + size, PGSIZE) >= MMIOLIM)
f0101519:	8d 84 0e ff 0f 00 00 	lea    0xfff(%esi,%ecx,1),%eax
f0101520:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101525:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f010152a:	76 17                	jbe    f0101543 <mmio_map_region+0x38>
		panic("mmio_map_region: mmio out of memory");
f010152c:	83 ec 04             	sub    $0x4,%esp
f010152f:	68 54 77 10 f0       	push   $0xf0107754
f0101534:	68 0c 03 00 00       	push   $0x30c
f0101539:	68 bf 71 10 f0       	push   $0xf01071bf
f010153e:	e8 fd ea ff ff       	call   f0100040 <_panic>
		
	boot_map_region(kern_pgdir, mmio, ROUNDUP(size, PGSIZE), pa, PTE_PCD|PTE_PWT|PTE_W);
f0101543:	8d 99 ff 0f 00 00    	lea    0xfff(%ecx),%ebx
f0101549:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f010154f:	83 ec 08             	sub    $0x8,%esp
f0101552:	6a 1a                	push   $0x1a
f0101554:	ff 75 08             	pushl  0x8(%ebp)
f0101557:	89 d9                	mov    %ebx,%ecx
f0101559:	89 f2                	mov    %esi,%edx
f010155b:	a1 98 ae 2a f0       	mov    0xf02aae98,%eax
f0101560:	e8 64 fd ff ff       	call   f01012c9 <boot_map_region>

	base += ROUNDUP(size, PGSIZE);
f0101565:	01 1d 00 33 12 f0    	add    %ebx,0xf0123300

	return (void *)mmio;
}
f010156b:	89 f0                	mov    %esi,%eax
f010156d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101570:	5b                   	pop    %ebx
f0101571:	5e                   	pop    %esi
f0101572:	5d                   	pop    %ebp
f0101573:	c3                   	ret    

f0101574 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101574:	55                   	push   %ebp
f0101575:	89 e5                	mov    %esp,%ebp
f0101577:	57                   	push   %edi
f0101578:	56                   	push   %esi
f0101579:	53                   	push   %ebx
f010157a:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f010157d:	b8 15 00 00 00       	mov    $0x15,%eax
f0101582:	e8 72 f5 ff ff       	call   f0100af9 <nvram_read>
f0101587:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0101589:	b8 17 00 00 00       	mov    $0x17,%eax
f010158e:	e8 66 f5 ff ff       	call   f0100af9 <nvram_read>
f0101593:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101595:	b8 34 00 00 00       	mov    $0x34,%eax
f010159a:	e8 5a f5 ff ff       	call   f0100af9 <nvram_read>
f010159f:	c1 e0 06             	shl    $0x6,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f01015a2:	85 c0                	test   %eax,%eax
f01015a4:	74 07                	je     f01015ad <mem_init+0x39>
		totalmem = 16 * 1024 + ext16mem;
f01015a6:	05 00 40 00 00       	add    $0x4000,%eax
f01015ab:	eb 0b                	jmp    f01015b8 <mem_init+0x44>
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f01015ad:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f01015b3:	85 f6                	test   %esi,%esi
f01015b5:	0f 44 c3             	cmove  %ebx,%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f01015b8:	89 c2                	mov    %eax,%edx
f01015ba:	c1 ea 02             	shr    $0x2,%edx
f01015bd:	89 15 94 ae 2a f0    	mov    %edx,0xf02aae94
	npages_basemem = basemem / (PGSIZE / 1024);
f01015c3:	89 da                	mov    %ebx,%edx
f01015c5:	c1 ea 02             	shr    $0x2,%edx
f01015c8:	89 15 44 a2 2a f0    	mov    %edx,0xf02aa244

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01015ce:	89 c2                	mov    %eax,%edx
f01015d0:	29 da                	sub    %ebx,%edx
f01015d2:	52                   	push   %edx
f01015d3:	53                   	push   %ebx
f01015d4:	50                   	push   %eax
f01015d5:	68 78 77 10 f0       	push   $0xf0107778
f01015da:	e8 a3 23 00 00       	call   f0103982 <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01015df:	b8 00 10 00 00       	mov    $0x1000,%eax
f01015e4:	e8 39 f5 ff ff       	call   f0100b22 <boot_alloc>
f01015e9:	a3 98 ae 2a f0       	mov    %eax,0xf02aae98
	memset(kern_pgdir, 0, PGSIZE);
f01015ee:	83 c4 0c             	add    $0xc,%esp
f01015f1:	68 00 10 00 00       	push   $0x1000
f01015f6:	6a 00                	push   $0x0
f01015f8:	50                   	push   %eax
f01015f9:	e8 b8 41 00 00       	call   f01057b6 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01015fe:	a1 98 ae 2a f0       	mov    0xf02aae98,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101603:	83 c4 10             	add    $0x10,%esp
f0101606:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010160b:	77 15                	ja     f0101622 <mem_init+0xae>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010160d:	50                   	push   %eax
f010160e:	68 28 6c 10 f0       	push   $0xf0106c28
f0101613:	68 9b 00 00 00       	push   $0x9b
f0101618:	68 bf 71 10 f0       	push   $0xf01071bf
f010161d:	e8 1e ea ff ff       	call   f0100040 <_panic>
f0101622:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101628:	83 ca 05             	or     $0x5,%edx
f010162b:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:

	n = npages * sizeof(struct PageInfo);
f0101631:	a1 94 ae 2a f0       	mov    0xf02aae94,%eax
f0101636:	8d 1c c5 00 00 00 00 	lea    0x0(,%eax,8),%ebx
	pages = (struct PageInfo *) boot_alloc(n);
f010163d:	89 d8                	mov    %ebx,%eax
f010163f:	e8 de f4 ff ff       	call   f0100b22 <boot_alloc>
f0101644:	a3 9c ae 2a f0       	mov    %eax,0xf02aae9c
	memset(pages, 0, n);
f0101649:	83 ec 04             	sub    $0x4,%esp
f010164c:	53                   	push   %ebx
f010164d:	6a 00                	push   $0x0
f010164f:	50                   	push   %eax
f0101650:	e8 61 41 00 00       	call   f01057b6 <memset>
	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.

	n = NENV * sizeof(struct Env);
	envs = (struct Env *) boot_alloc(n);
f0101655:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f010165a:	e8 c3 f4 ff ff       	call   f0100b22 <boot_alloc>
f010165f:	a3 48 a2 2a f0       	mov    %eax,0xf02aa248
	memset(envs, 0, n);
f0101664:	83 c4 0c             	add    $0xc,%esp
f0101667:	68 00 f0 01 00       	push   $0x1f000
f010166c:	6a 00                	push   $0x0
f010166e:	50                   	push   %eax
f010166f:	e8 42 41 00 00       	call   f01057b6 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101674:	e8 62 f8 ff ff       	call   f0100edb <page_init>

	check_page_free_list(1);
f0101679:	b8 01 00 00 00       	mov    $0x1,%eax
f010167e:	e8 56 f5 ff ff       	call   f0100bd9 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101683:	83 c4 10             	add    $0x10,%esp
f0101686:	83 3d 9c ae 2a f0 00 	cmpl   $0x0,0xf02aae9c
f010168d:	75 17                	jne    f01016a6 <mem_init+0x132>
		panic("'pages' is a null pointer!");
f010168f:	83 ec 04             	sub    $0x4,%esp
f0101692:	68 ec 72 10 f0       	push   $0xf01072ec
f0101697:	68 b2 03 00 00       	push   $0x3b2
f010169c:	68 bf 71 10 f0       	push   $0xf01071bf
f01016a1:	e8 9a e9 ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01016a6:	a1 40 a2 2a f0       	mov    0xf02aa240,%eax
f01016ab:	bb 00 00 00 00       	mov    $0x0,%ebx
f01016b0:	eb 05                	jmp    f01016b7 <mem_init+0x143>
		++nfree;
f01016b2:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01016b5:	8b 00                	mov    (%eax),%eax
f01016b7:	85 c0                	test   %eax,%eax
f01016b9:	75 f7                	jne    f01016b2 <mem_init+0x13e>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01016bb:	83 ec 0c             	sub    $0xc,%esp
f01016be:	6a 00                	push   $0x0
f01016c0:	e8 cc f9 ff ff       	call   f0101091 <page_alloc>
f01016c5:	89 c7                	mov    %eax,%edi
f01016c7:	83 c4 10             	add    $0x10,%esp
f01016ca:	85 c0                	test   %eax,%eax
f01016cc:	75 19                	jne    f01016e7 <mem_init+0x173>
f01016ce:	68 07 73 10 f0       	push   $0xf0107307
f01016d3:	68 e5 71 10 f0       	push   $0xf01071e5
f01016d8:	68 ba 03 00 00       	push   $0x3ba
f01016dd:	68 bf 71 10 f0       	push   $0xf01071bf
f01016e2:	e8 59 e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01016e7:	83 ec 0c             	sub    $0xc,%esp
f01016ea:	6a 00                	push   $0x0
f01016ec:	e8 a0 f9 ff ff       	call   f0101091 <page_alloc>
f01016f1:	89 c6                	mov    %eax,%esi
f01016f3:	83 c4 10             	add    $0x10,%esp
f01016f6:	85 c0                	test   %eax,%eax
f01016f8:	75 19                	jne    f0101713 <mem_init+0x19f>
f01016fa:	68 1d 73 10 f0       	push   $0xf010731d
f01016ff:	68 e5 71 10 f0       	push   $0xf01071e5
f0101704:	68 bb 03 00 00       	push   $0x3bb
f0101709:	68 bf 71 10 f0       	push   $0xf01071bf
f010170e:	e8 2d e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101713:	83 ec 0c             	sub    $0xc,%esp
f0101716:	6a 00                	push   $0x0
f0101718:	e8 74 f9 ff ff       	call   f0101091 <page_alloc>
f010171d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101720:	83 c4 10             	add    $0x10,%esp
f0101723:	85 c0                	test   %eax,%eax
f0101725:	75 19                	jne    f0101740 <mem_init+0x1cc>
f0101727:	68 33 73 10 f0       	push   $0xf0107333
f010172c:	68 e5 71 10 f0       	push   $0xf01071e5
f0101731:	68 bc 03 00 00       	push   $0x3bc
f0101736:	68 bf 71 10 f0       	push   $0xf01071bf
f010173b:	e8 00 e9 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101740:	39 f7                	cmp    %esi,%edi
f0101742:	75 19                	jne    f010175d <mem_init+0x1e9>
f0101744:	68 49 73 10 f0       	push   $0xf0107349
f0101749:	68 e5 71 10 f0       	push   $0xf01071e5
f010174e:	68 bf 03 00 00       	push   $0x3bf
f0101753:	68 bf 71 10 f0       	push   $0xf01071bf
f0101758:	e8 e3 e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010175d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101760:	39 c6                	cmp    %eax,%esi
f0101762:	74 04                	je     f0101768 <mem_init+0x1f4>
f0101764:	39 c7                	cmp    %eax,%edi
f0101766:	75 19                	jne    f0101781 <mem_init+0x20d>
f0101768:	68 b4 77 10 f0       	push   $0xf01077b4
f010176d:	68 e5 71 10 f0       	push   $0xf01071e5
f0101772:	68 c0 03 00 00       	push   $0x3c0
f0101777:	68 bf 71 10 f0       	push   $0xf01071bf
f010177c:	e8 bf e8 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101781:	8b 0d 9c ae 2a f0    	mov    0xf02aae9c,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101787:	8b 15 94 ae 2a f0    	mov    0xf02aae94,%edx
f010178d:	c1 e2 0c             	shl    $0xc,%edx
f0101790:	89 f8                	mov    %edi,%eax
f0101792:	29 c8                	sub    %ecx,%eax
f0101794:	c1 f8 03             	sar    $0x3,%eax
f0101797:	c1 e0 0c             	shl    $0xc,%eax
f010179a:	39 d0                	cmp    %edx,%eax
f010179c:	72 19                	jb     f01017b7 <mem_init+0x243>
f010179e:	68 5b 73 10 f0       	push   $0xf010735b
f01017a3:	68 e5 71 10 f0       	push   $0xf01071e5
f01017a8:	68 c1 03 00 00       	push   $0x3c1
f01017ad:	68 bf 71 10 f0       	push   $0xf01071bf
f01017b2:	e8 89 e8 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01017b7:	89 f0                	mov    %esi,%eax
f01017b9:	29 c8                	sub    %ecx,%eax
f01017bb:	c1 f8 03             	sar    $0x3,%eax
f01017be:	c1 e0 0c             	shl    $0xc,%eax
f01017c1:	39 c2                	cmp    %eax,%edx
f01017c3:	77 19                	ja     f01017de <mem_init+0x26a>
f01017c5:	68 78 73 10 f0       	push   $0xf0107378
f01017ca:	68 e5 71 10 f0       	push   $0xf01071e5
f01017cf:	68 c2 03 00 00       	push   $0x3c2
f01017d4:	68 bf 71 10 f0       	push   $0xf01071bf
f01017d9:	e8 62 e8 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01017de:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01017e1:	29 c8                	sub    %ecx,%eax
f01017e3:	c1 f8 03             	sar    $0x3,%eax
f01017e6:	c1 e0 0c             	shl    $0xc,%eax
f01017e9:	39 c2                	cmp    %eax,%edx
f01017eb:	77 19                	ja     f0101806 <mem_init+0x292>
f01017ed:	68 95 73 10 f0       	push   $0xf0107395
f01017f2:	68 e5 71 10 f0       	push   $0xf01071e5
f01017f7:	68 c3 03 00 00       	push   $0x3c3
f01017fc:	68 bf 71 10 f0       	push   $0xf01071bf
f0101801:	e8 3a e8 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101806:	a1 40 a2 2a f0       	mov    0xf02aa240,%eax
f010180b:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010180e:	c7 05 40 a2 2a f0 00 	movl   $0x0,0xf02aa240
f0101815:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101818:	83 ec 0c             	sub    $0xc,%esp
f010181b:	6a 00                	push   $0x0
f010181d:	e8 6f f8 ff ff       	call   f0101091 <page_alloc>
f0101822:	83 c4 10             	add    $0x10,%esp
f0101825:	85 c0                	test   %eax,%eax
f0101827:	74 19                	je     f0101842 <mem_init+0x2ce>
f0101829:	68 b2 73 10 f0       	push   $0xf01073b2
f010182e:	68 e5 71 10 f0       	push   $0xf01071e5
f0101833:	68 ca 03 00 00       	push   $0x3ca
f0101838:	68 bf 71 10 f0       	push   $0xf01071bf
f010183d:	e8 fe e7 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101842:	83 ec 0c             	sub    $0xc,%esp
f0101845:	57                   	push   %edi
f0101846:	e8 b7 f8 ff ff       	call   f0101102 <page_free>
	page_free(pp1);
f010184b:	89 34 24             	mov    %esi,(%esp)
f010184e:	e8 af f8 ff ff       	call   f0101102 <page_free>
	page_free(pp2);
f0101853:	83 c4 04             	add    $0x4,%esp
f0101856:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101859:	e8 a4 f8 ff ff       	call   f0101102 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010185e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101865:	e8 27 f8 ff ff       	call   f0101091 <page_alloc>
f010186a:	89 c6                	mov    %eax,%esi
f010186c:	83 c4 10             	add    $0x10,%esp
f010186f:	85 c0                	test   %eax,%eax
f0101871:	75 19                	jne    f010188c <mem_init+0x318>
f0101873:	68 07 73 10 f0       	push   $0xf0107307
f0101878:	68 e5 71 10 f0       	push   $0xf01071e5
f010187d:	68 d1 03 00 00       	push   $0x3d1
f0101882:	68 bf 71 10 f0       	push   $0xf01071bf
f0101887:	e8 b4 e7 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010188c:	83 ec 0c             	sub    $0xc,%esp
f010188f:	6a 00                	push   $0x0
f0101891:	e8 fb f7 ff ff       	call   f0101091 <page_alloc>
f0101896:	89 c7                	mov    %eax,%edi
f0101898:	83 c4 10             	add    $0x10,%esp
f010189b:	85 c0                	test   %eax,%eax
f010189d:	75 19                	jne    f01018b8 <mem_init+0x344>
f010189f:	68 1d 73 10 f0       	push   $0xf010731d
f01018a4:	68 e5 71 10 f0       	push   $0xf01071e5
f01018a9:	68 d2 03 00 00       	push   $0x3d2
f01018ae:	68 bf 71 10 f0       	push   $0xf01071bf
f01018b3:	e8 88 e7 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01018b8:	83 ec 0c             	sub    $0xc,%esp
f01018bb:	6a 00                	push   $0x0
f01018bd:	e8 cf f7 ff ff       	call   f0101091 <page_alloc>
f01018c2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01018c5:	83 c4 10             	add    $0x10,%esp
f01018c8:	85 c0                	test   %eax,%eax
f01018ca:	75 19                	jne    f01018e5 <mem_init+0x371>
f01018cc:	68 33 73 10 f0       	push   $0xf0107333
f01018d1:	68 e5 71 10 f0       	push   $0xf01071e5
f01018d6:	68 d3 03 00 00       	push   $0x3d3
f01018db:	68 bf 71 10 f0       	push   $0xf01071bf
f01018e0:	e8 5b e7 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01018e5:	39 fe                	cmp    %edi,%esi
f01018e7:	75 19                	jne    f0101902 <mem_init+0x38e>
f01018e9:	68 49 73 10 f0       	push   $0xf0107349
f01018ee:	68 e5 71 10 f0       	push   $0xf01071e5
f01018f3:	68 d5 03 00 00       	push   $0x3d5
f01018f8:	68 bf 71 10 f0       	push   $0xf01071bf
f01018fd:	e8 3e e7 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101902:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101905:	39 c7                	cmp    %eax,%edi
f0101907:	74 04                	je     f010190d <mem_init+0x399>
f0101909:	39 c6                	cmp    %eax,%esi
f010190b:	75 19                	jne    f0101926 <mem_init+0x3b2>
f010190d:	68 b4 77 10 f0       	push   $0xf01077b4
f0101912:	68 e5 71 10 f0       	push   $0xf01071e5
f0101917:	68 d6 03 00 00       	push   $0x3d6
f010191c:	68 bf 71 10 f0       	push   $0xf01071bf
f0101921:	e8 1a e7 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101926:	83 ec 0c             	sub    $0xc,%esp
f0101929:	6a 00                	push   $0x0
f010192b:	e8 61 f7 ff ff       	call   f0101091 <page_alloc>
f0101930:	83 c4 10             	add    $0x10,%esp
f0101933:	85 c0                	test   %eax,%eax
f0101935:	74 19                	je     f0101950 <mem_init+0x3dc>
f0101937:	68 b2 73 10 f0       	push   $0xf01073b2
f010193c:	68 e5 71 10 f0       	push   $0xf01071e5
f0101941:	68 d7 03 00 00       	push   $0x3d7
f0101946:	68 bf 71 10 f0       	push   $0xf01071bf
f010194b:	e8 f0 e6 ff ff       	call   f0100040 <_panic>
f0101950:	89 f0                	mov    %esi,%eax
f0101952:	2b 05 9c ae 2a f0    	sub    0xf02aae9c,%eax
f0101958:	c1 f8 03             	sar    $0x3,%eax
f010195b:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010195e:	89 c2                	mov    %eax,%edx
f0101960:	c1 ea 0c             	shr    $0xc,%edx
f0101963:	3b 15 94 ae 2a f0    	cmp    0xf02aae94,%edx
f0101969:	72 12                	jb     f010197d <mem_init+0x409>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010196b:	50                   	push   %eax
f010196c:	68 04 6c 10 f0       	push   $0xf0106c04
f0101971:	6a 58                	push   $0x58
f0101973:	68 cb 71 10 f0       	push   $0xf01071cb
f0101978:	e8 c3 e6 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f010197d:	83 ec 04             	sub    $0x4,%esp
f0101980:	68 00 10 00 00       	push   $0x1000
f0101985:	6a 01                	push   $0x1
f0101987:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010198c:	50                   	push   %eax
f010198d:	e8 24 3e 00 00       	call   f01057b6 <memset>
	page_free(pp0);
f0101992:	89 34 24             	mov    %esi,(%esp)
f0101995:	e8 68 f7 ff ff       	call   f0101102 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010199a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01019a1:	e8 eb f6 ff ff       	call   f0101091 <page_alloc>
f01019a6:	83 c4 10             	add    $0x10,%esp
f01019a9:	85 c0                	test   %eax,%eax
f01019ab:	75 19                	jne    f01019c6 <mem_init+0x452>
f01019ad:	68 c1 73 10 f0       	push   $0xf01073c1
f01019b2:	68 e5 71 10 f0       	push   $0xf01071e5
f01019b7:	68 dc 03 00 00       	push   $0x3dc
f01019bc:	68 bf 71 10 f0       	push   $0xf01071bf
f01019c1:	e8 7a e6 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f01019c6:	39 c6                	cmp    %eax,%esi
f01019c8:	74 19                	je     f01019e3 <mem_init+0x46f>
f01019ca:	68 df 73 10 f0       	push   $0xf01073df
f01019cf:	68 e5 71 10 f0       	push   $0xf01071e5
f01019d4:	68 dd 03 00 00       	push   $0x3dd
f01019d9:	68 bf 71 10 f0       	push   $0xf01071bf
f01019de:	e8 5d e6 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01019e3:	89 f0                	mov    %esi,%eax
f01019e5:	2b 05 9c ae 2a f0    	sub    0xf02aae9c,%eax
f01019eb:	c1 f8 03             	sar    $0x3,%eax
f01019ee:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01019f1:	89 c2                	mov    %eax,%edx
f01019f3:	c1 ea 0c             	shr    $0xc,%edx
f01019f6:	3b 15 94 ae 2a f0    	cmp    0xf02aae94,%edx
f01019fc:	72 12                	jb     f0101a10 <mem_init+0x49c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01019fe:	50                   	push   %eax
f01019ff:	68 04 6c 10 f0       	push   $0xf0106c04
f0101a04:	6a 58                	push   $0x58
f0101a06:	68 cb 71 10 f0       	push   $0xf01071cb
f0101a0b:	e8 30 e6 ff ff       	call   f0100040 <_panic>
f0101a10:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101a16:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++) {
		// cprintf("[?] %d\n", i);
		assert(c[i] == 0);
f0101a1c:	80 38 00             	cmpb   $0x0,(%eax)
f0101a1f:	74 19                	je     f0101a3a <mem_init+0x4c6>
f0101a21:	68 ef 73 10 f0       	push   $0xf01073ef
f0101a26:	68 e5 71 10 f0       	push   $0xf01071e5
f0101a2b:	68 e1 03 00 00       	push   $0x3e1
f0101a30:	68 bf 71 10 f0       	push   $0xf01071bf
f0101a35:	e8 06 e6 ff ff       	call   f0100040 <_panic>
f0101a3a:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++) {
f0101a3d:	39 d0                	cmp    %edx,%eax
f0101a3f:	75 db                	jne    f0101a1c <mem_init+0x4a8>
		// cprintf("[?] %d\n", i);
		assert(c[i] == 0);
	}

	// give free list back
	page_free_list = fl;
f0101a41:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101a44:	a3 40 a2 2a f0       	mov    %eax,0xf02aa240

	// free the pages we took
	page_free(pp0);
f0101a49:	83 ec 0c             	sub    $0xc,%esp
f0101a4c:	56                   	push   %esi
f0101a4d:	e8 b0 f6 ff ff       	call   f0101102 <page_free>
	page_free(pp1);
f0101a52:	89 3c 24             	mov    %edi,(%esp)
f0101a55:	e8 a8 f6 ff ff       	call   f0101102 <page_free>
	page_free(pp2);
f0101a5a:	83 c4 04             	add    $0x4,%esp
f0101a5d:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101a60:	e8 9d f6 ff ff       	call   f0101102 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101a65:	a1 40 a2 2a f0       	mov    0xf02aa240,%eax
f0101a6a:	83 c4 10             	add    $0x10,%esp
f0101a6d:	eb 05                	jmp    f0101a74 <mem_init+0x500>
		--nfree;
f0101a6f:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101a72:	8b 00                	mov    (%eax),%eax
f0101a74:	85 c0                	test   %eax,%eax
f0101a76:	75 f7                	jne    f0101a6f <mem_init+0x4fb>
		--nfree;
	assert(nfree == 0);
f0101a78:	85 db                	test   %ebx,%ebx
f0101a7a:	74 19                	je     f0101a95 <mem_init+0x521>
f0101a7c:	68 f9 73 10 f0       	push   $0xf01073f9
f0101a81:	68 e5 71 10 f0       	push   $0xf01071e5
f0101a86:	68 ef 03 00 00       	push   $0x3ef
f0101a8b:	68 bf 71 10 f0       	push   $0xf01071bf
f0101a90:	e8 ab e5 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101a95:	83 ec 0c             	sub    $0xc,%esp
f0101a98:	68 d4 77 10 f0       	push   $0xf01077d4
f0101a9d:	e8 e0 1e 00 00       	call   f0103982 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101aa2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101aa9:	e8 e3 f5 ff ff       	call   f0101091 <page_alloc>
f0101aae:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101ab1:	83 c4 10             	add    $0x10,%esp
f0101ab4:	85 c0                	test   %eax,%eax
f0101ab6:	75 19                	jne    f0101ad1 <mem_init+0x55d>
f0101ab8:	68 07 73 10 f0       	push   $0xf0107307
f0101abd:	68 e5 71 10 f0       	push   $0xf01071e5
f0101ac2:	68 59 04 00 00       	push   $0x459
f0101ac7:	68 bf 71 10 f0       	push   $0xf01071bf
f0101acc:	e8 6f e5 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101ad1:	83 ec 0c             	sub    $0xc,%esp
f0101ad4:	6a 00                	push   $0x0
f0101ad6:	e8 b6 f5 ff ff       	call   f0101091 <page_alloc>
f0101adb:	89 c3                	mov    %eax,%ebx
f0101add:	83 c4 10             	add    $0x10,%esp
f0101ae0:	85 c0                	test   %eax,%eax
f0101ae2:	75 19                	jne    f0101afd <mem_init+0x589>
f0101ae4:	68 1d 73 10 f0       	push   $0xf010731d
f0101ae9:	68 e5 71 10 f0       	push   $0xf01071e5
f0101aee:	68 5a 04 00 00       	push   $0x45a
f0101af3:	68 bf 71 10 f0       	push   $0xf01071bf
f0101af8:	e8 43 e5 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101afd:	83 ec 0c             	sub    $0xc,%esp
f0101b00:	6a 00                	push   $0x0
f0101b02:	e8 8a f5 ff ff       	call   f0101091 <page_alloc>
f0101b07:	89 c6                	mov    %eax,%esi
f0101b09:	83 c4 10             	add    $0x10,%esp
f0101b0c:	85 c0                	test   %eax,%eax
f0101b0e:	75 19                	jne    f0101b29 <mem_init+0x5b5>
f0101b10:	68 33 73 10 f0       	push   $0xf0107333
f0101b15:	68 e5 71 10 f0       	push   $0xf01071e5
f0101b1a:	68 5b 04 00 00       	push   $0x45b
f0101b1f:	68 bf 71 10 f0       	push   $0xf01071bf
f0101b24:	e8 17 e5 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101b29:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101b2c:	75 19                	jne    f0101b47 <mem_init+0x5d3>
f0101b2e:	68 49 73 10 f0       	push   $0xf0107349
f0101b33:	68 e5 71 10 f0       	push   $0xf01071e5
f0101b38:	68 5e 04 00 00       	push   $0x45e
f0101b3d:	68 bf 71 10 f0       	push   $0xf01071bf
f0101b42:	e8 f9 e4 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101b47:	39 c3                	cmp    %eax,%ebx
f0101b49:	74 05                	je     f0101b50 <mem_init+0x5dc>
f0101b4b:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101b4e:	75 19                	jne    f0101b69 <mem_init+0x5f5>
f0101b50:	68 b4 77 10 f0       	push   $0xf01077b4
f0101b55:	68 e5 71 10 f0       	push   $0xf01071e5
f0101b5a:	68 5f 04 00 00       	push   $0x45f
f0101b5f:	68 bf 71 10 f0       	push   $0xf01071bf
f0101b64:	e8 d7 e4 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101b69:	a1 40 a2 2a f0       	mov    0xf02aa240,%eax
f0101b6e:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101b71:	c7 05 40 a2 2a f0 00 	movl   $0x0,0xf02aa240
f0101b78:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101b7b:	83 ec 0c             	sub    $0xc,%esp
f0101b7e:	6a 00                	push   $0x0
f0101b80:	e8 0c f5 ff ff       	call   f0101091 <page_alloc>
f0101b85:	83 c4 10             	add    $0x10,%esp
f0101b88:	85 c0                	test   %eax,%eax
f0101b8a:	74 19                	je     f0101ba5 <mem_init+0x631>
f0101b8c:	68 b2 73 10 f0       	push   $0xf01073b2
f0101b91:	68 e5 71 10 f0       	push   $0xf01071e5
f0101b96:	68 66 04 00 00       	push   $0x466
f0101b9b:	68 bf 71 10 f0       	push   $0xf01071bf
f0101ba0:	e8 9b e4 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101ba5:	83 ec 04             	sub    $0x4,%esp
f0101ba8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101bab:	50                   	push   %eax
f0101bac:	6a 00                	push   $0x0
f0101bae:	ff 35 98 ae 2a f0    	pushl  0xf02aae98
f0101bb4:	e8 e3 f7 ff ff       	call   f010139c <page_lookup>
f0101bb9:	83 c4 10             	add    $0x10,%esp
f0101bbc:	85 c0                	test   %eax,%eax
f0101bbe:	74 19                	je     f0101bd9 <mem_init+0x665>
f0101bc0:	68 f4 77 10 f0       	push   $0xf01077f4
f0101bc5:	68 e5 71 10 f0       	push   $0xf01071e5
f0101bca:	68 69 04 00 00       	push   $0x469
f0101bcf:	68 bf 71 10 f0       	push   $0xf01071bf
f0101bd4:	e8 67 e4 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101bd9:	6a 02                	push   $0x2
f0101bdb:	6a 00                	push   $0x0
f0101bdd:	53                   	push   %ebx
f0101bde:	ff 35 98 ae 2a f0    	pushl  0xf02aae98
f0101be4:	e8 9b f8 ff ff       	call   f0101484 <page_insert>
f0101be9:	83 c4 10             	add    $0x10,%esp
f0101bec:	85 c0                	test   %eax,%eax
f0101bee:	78 19                	js     f0101c09 <mem_init+0x695>
f0101bf0:	68 2c 78 10 f0       	push   $0xf010782c
f0101bf5:	68 e5 71 10 f0       	push   $0xf01071e5
f0101bfa:	68 6c 04 00 00       	push   $0x46c
f0101bff:	68 bf 71 10 f0       	push   $0xf01071bf
f0101c04:	e8 37 e4 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101c09:	83 ec 0c             	sub    $0xc,%esp
f0101c0c:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101c0f:	e8 ee f4 ff ff       	call   f0101102 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101c14:	6a 02                	push   $0x2
f0101c16:	6a 00                	push   $0x0
f0101c18:	53                   	push   %ebx
f0101c19:	ff 35 98 ae 2a f0    	pushl  0xf02aae98
f0101c1f:	e8 60 f8 ff ff       	call   f0101484 <page_insert>
f0101c24:	83 c4 20             	add    $0x20,%esp
f0101c27:	85 c0                	test   %eax,%eax
f0101c29:	74 19                	je     f0101c44 <mem_init+0x6d0>
f0101c2b:	68 5c 78 10 f0       	push   $0xf010785c
f0101c30:	68 e5 71 10 f0       	push   $0xf01071e5
f0101c35:	68 70 04 00 00       	push   $0x470
f0101c3a:	68 bf 71 10 f0       	push   $0xf01071bf
f0101c3f:	e8 fc e3 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101c44:	8b 3d 98 ae 2a f0    	mov    0xf02aae98,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101c4a:	a1 9c ae 2a f0       	mov    0xf02aae9c,%eax
f0101c4f:	89 c1                	mov    %eax,%ecx
f0101c51:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101c54:	8b 17                	mov    (%edi),%edx
f0101c56:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101c5c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c5f:	29 c8                	sub    %ecx,%eax
f0101c61:	c1 f8 03             	sar    $0x3,%eax
f0101c64:	c1 e0 0c             	shl    $0xc,%eax
f0101c67:	39 c2                	cmp    %eax,%edx
f0101c69:	74 19                	je     f0101c84 <mem_init+0x710>
f0101c6b:	68 8c 78 10 f0       	push   $0xf010788c
f0101c70:	68 e5 71 10 f0       	push   $0xf01071e5
f0101c75:	68 71 04 00 00       	push   $0x471
f0101c7a:	68 bf 71 10 f0       	push   $0xf01071bf
f0101c7f:	e8 bc e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101c84:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c89:	89 f8                	mov    %edi,%eax
f0101c8b:	e8 e5 ee ff ff       	call   f0100b75 <check_va2pa>
f0101c90:	89 da                	mov    %ebx,%edx
f0101c92:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101c95:	c1 fa 03             	sar    $0x3,%edx
f0101c98:	c1 e2 0c             	shl    $0xc,%edx
f0101c9b:	39 d0                	cmp    %edx,%eax
f0101c9d:	74 19                	je     f0101cb8 <mem_init+0x744>
f0101c9f:	68 b4 78 10 f0       	push   $0xf01078b4
f0101ca4:	68 e5 71 10 f0       	push   $0xf01071e5
f0101ca9:	68 72 04 00 00       	push   $0x472
f0101cae:	68 bf 71 10 f0       	push   $0xf01071bf
f0101cb3:	e8 88 e3 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101cb8:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101cbd:	74 19                	je     f0101cd8 <mem_init+0x764>
f0101cbf:	68 04 74 10 f0       	push   $0xf0107404
f0101cc4:	68 e5 71 10 f0       	push   $0xf01071e5
f0101cc9:	68 73 04 00 00       	push   $0x473
f0101cce:	68 bf 71 10 f0       	push   $0xf01071bf
f0101cd3:	e8 68 e3 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101cd8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101cdb:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101ce0:	74 19                	je     f0101cfb <mem_init+0x787>
f0101ce2:	68 15 74 10 f0       	push   $0xf0107415
f0101ce7:	68 e5 71 10 f0       	push   $0xf01071e5
f0101cec:	68 74 04 00 00       	push   $0x474
f0101cf1:	68 bf 71 10 f0       	push   $0xf01071bf
f0101cf6:	e8 45 e3 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101cfb:	6a 02                	push   $0x2
f0101cfd:	68 00 10 00 00       	push   $0x1000
f0101d02:	56                   	push   %esi
f0101d03:	57                   	push   %edi
f0101d04:	e8 7b f7 ff ff       	call   f0101484 <page_insert>
f0101d09:	83 c4 10             	add    $0x10,%esp
f0101d0c:	85 c0                	test   %eax,%eax
f0101d0e:	74 19                	je     f0101d29 <mem_init+0x7b5>
f0101d10:	68 e4 78 10 f0       	push   $0xf01078e4
f0101d15:	68 e5 71 10 f0       	push   $0xf01071e5
f0101d1a:	68 77 04 00 00       	push   $0x477
f0101d1f:	68 bf 71 10 f0       	push   $0xf01071bf
f0101d24:	e8 17 e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d29:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d2e:	a1 98 ae 2a f0       	mov    0xf02aae98,%eax
f0101d33:	e8 3d ee ff ff       	call   f0100b75 <check_va2pa>
f0101d38:	89 f2                	mov    %esi,%edx
f0101d3a:	2b 15 9c ae 2a f0    	sub    0xf02aae9c,%edx
f0101d40:	c1 fa 03             	sar    $0x3,%edx
f0101d43:	c1 e2 0c             	shl    $0xc,%edx
f0101d46:	39 d0                	cmp    %edx,%eax
f0101d48:	74 19                	je     f0101d63 <mem_init+0x7ef>
f0101d4a:	68 20 79 10 f0       	push   $0xf0107920
f0101d4f:	68 e5 71 10 f0       	push   $0xf01071e5
f0101d54:	68 78 04 00 00       	push   $0x478
f0101d59:	68 bf 71 10 f0       	push   $0xf01071bf
f0101d5e:	e8 dd e2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101d63:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d68:	74 19                	je     f0101d83 <mem_init+0x80f>
f0101d6a:	68 26 74 10 f0       	push   $0xf0107426
f0101d6f:	68 e5 71 10 f0       	push   $0xf01071e5
f0101d74:	68 79 04 00 00       	push   $0x479
f0101d79:	68 bf 71 10 f0       	push   $0xf01071bf
f0101d7e:	e8 bd e2 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101d83:	83 ec 0c             	sub    $0xc,%esp
f0101d86:	6a 00                	push   $0x0
f0101d88:	e8 04 f3 ff ff       	call   f0101091 <page_alloc>
f0101d8d:	83 c4 10             	add    $0x10,%esp
f0101d90:	85 c0                	test   %eax,%eax
f0101d92:	74 19                	je     f0101dad <mem_init+0x839>
f0101d94:	68 b2 73 10 f0       	push   $0xf01073b2
f0101d99:	68 e5 71 10 f0       	push   $0xf01071e5
f0101d9e:	68 7c 04 00 00       	push   $0x47c
f0101da3:	68 bf 71 10 f0       	push   $0xf01071bf
f0101da8:	e8 93 e2 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101dad:	6a 02                	push   $0x2
f0101daf:	68 00 10 00 00       	push   $0x1000
f0101db4:	56                   	push   %esi
f0101db5:	ff 35 98 ae 2a f0    	pushl  0xf02aae98
f0101dbb:	e8 c4 f6 ff ff       	call   f0101484 <page_insert>
f0101dc0:	83 c4 10             	add    $0x10,%esp
f0101dc3:	85 c0                	test   %eax,%eax
f0101dc5:	74 19                	je     f0101de0 <mem_init+0x86c>
f0101dc7:	68 e4 78 10 f0       	push   $0xf01078e4
f0101dcc:	68 e5 71 10 f0       	push   $0xf01071e5
f0101dd1:	68 7f 04 00 00       	push   $0x47f
f0101dd6:	68 bf 71 10 f0       	push   $0xf01071bf
f0101ddb:	e8 60 e2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101de0:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101de5:	a1 98 ae 2a f0       	mov    0xf02aae98,%eax
f0101dea:	e8 86 ed ff ff       	call   f0100b75 <check_va2pa>
f0101def:	89 f2                	mov    %esi,%edx
f0101df1:	2b 15 9c ae 2a f0    	sub    0xf02aae9c,%edx
f0101df7:	c1 fa 03             	sar    $0x3,%edx
f0101dfa:	c1 e2 0c             	shl    $0xc,%edx
f0101dfd:	39 d0                	cmp    %edx,%eax
f0101dff:	74 19                	je     f0101e1a <mem_init+0x8a6>
f0101e01:	68 20 79 10 f0       	push   $0xf0107920
f0101e06:	68 e5 71 10 f0       	push   $0xf01071e5
f0101e0b:	68 80 04 00 00       	push   $0x480
f0101e10:	68 bf 71 10 f0       	push   $0xf01071bf
f0101e15:	e8 26 e2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101e1a:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101e1f:	74 19                	je     f0101e3a <mem_init+0x8c6>
f0101e21:	68 26 74 10 f0       	push   $0xf0107426
f0101e26:	68 e5 71 10 f0       	push   $0xf01071e5
f0101e2b:	68 81 04 00 00       	push   $0x481
f0101e30:	68 bf 71 10 f0       	push   $0xf01071bf
f0101e35:	e8 06 e2 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101e3a:	83 ec 0c             	sub    $0xc,%esp
f0101e3d:	6a 00                	push   $0x0
f0101e3f:	e8 4d f2 ff ff       	call   f0101091 <page_alloc>
f0101e44:	83 c4 10             	add    $0x10,%esp
f0101e47:	85 c0                	test   %eax,%eax
f0101e49:	74 19                	je     f0101e64 <mem_init+0x8f0>
f0101e4b:	68 b2 73 10 f0       	push   $0xf01073b2
f0101e50:	68 e5 71 10 f0       	push   $0xf01071e5
f0101e55:	68 85 04 00 00       	push   $0x485
f0101e5a:	68 bf 71 10 f0       	push   $0xf01071bf
f0101e5f:	e8 dc e1 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101e64:	8b 15 98 ae 2a f0    	mov    0xf02aae98,%edx
f0101e6a:	8b 02                	mov    (%edx),%eax
f0101e6c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101e71:	89 c1                	mov    %eax,%ecx
f0101e73:	c1 e9 0c             	shr    $0xc,%ecx
f0101e76:	3b 0d 94 ae 2a f0    	cmp    0xf02aae94,%ecx
f0101e7c:	72 15                	jb     f0101e93 <mem_init+0x91f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101e7e:	50                   	push   %eax
f0101e7f:	68 04 6c 10 f0       	push   $0xf0106c04
f0101e84:	68 88 04 00 00       	push   $0x488
f0101e89:	68 bf 71 10 f0       	push   $0xf01071bf
f0101e8e:	e8 ad e1 ff ff       	call   f0100040 <_panic>
f0101e93:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101e98:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101e9b:	83 ec 04             	sub    $0x4,%esp
f0101e9e:	6a 00                	push   $0x0
f0101ea0:	68 00 10 00 00       	push   $0x1000
f0101ea5:	52                   	push   %edx
f0101ea6:	e8 d4 f2 ff ff       	call   f010117f <pgdir_walk>
f0101eab:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101eae:	8d 51 04             	lea    0x4(%ecx),%edx
f0101eb1:	83 c4 10             	add    $0x10,%esp
f0101eb4:	39 d0                	cmp    %edx,%eax
f0101eb6:	74 19                	je     f0101ed1 <mem_init+0x95d>
f0101eb8:	68 50 79 10 f0       	push   $0xf0107950
f0101ebd:	68 e5 71 10 f0       	push   $0xf01071e5
f0101ec2:	68 89 04 00 00       	push   $0x489
f0101ec7:	68 bf 71 10 f0       	push   $0xf01071bf
f0101ecc:	e8 6f e1 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101ed1:	6a 06                	push   $0x6
f0101ed3:	68 00 10 00 00       	push   $0x1000
f0101ed8:	56                   	push   %esi
f0101ed9:	ff 35 98 ae 2a f0    	pushl  0xf02aae98
f0101edf:	e8 a0 f5 ff ff       	call   f0101484 <page_insert>
f0101ee4:	83 c4 10             	add    $0x10,%esp
f0101ee7:	85 c0                	test   %eax,%eax
f0101ee9:	74 19                	je     f0101f04 <mem_init+0x990>
f0101eeb:	68 90 79 10 f0       	push   $0xf0107990
f0101ef0:	68 e5 71 10 f0       	push   $0xf01071e5
f0101ef5:	68 8c 04 00 00       	push   $0x48c
f0101efa:	68 bf 71 10 f0       	push   $0xf01071bf
f0101eff:	e8 3c e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f04:	8b 3d 98 ae 2a f0    	mov    0xf02aae98,%edi
f0101f0a:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f0f:	89 f8                	mov    %edi,%eax
f0101f11:	e8 5f ec ff ff       	call   f0100b75 <check_va2pa>
f0101f16:	89 f2                	mov    %esi,%edx
f0101f18:	2b 15 9c ae 2a f0    	sub    0xf02aae9c,%edx
f0101f1e:	c1 fa 03             	sar    $0x3,%edx
f0101f21:	c1 e2 0c             	shl    $0xc,%edx
f0101f24:	39 d0                	cmp    %edx,%eax
f0101f26:	74 19                	je     f0101f41 <mem_init+0x9cd>
f0101f28:	68 20 79 10 f0       	push   $0xf0107920
f0101f2d:	68 e5 71 10 f0       	push   $0xf01071e5
f0101f32:	68 8d 04 00 00       	push   $0x48d
f0101f37:	68 bf 71 10 f0       	push   $0xf01071bf
f0101f3c:	e8 ff e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101f41:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101f46:	74 19                	je     f0101f61 <mem_init+0x9ed>
f0101f48:	68 26 74 10 f0       	push   $0xf0107426
f0101f4d:	68 e5 71 10 f0       	push   $0xf01071e5
f0101f52:	68 8e 04 00 00       	push   $0x48e
f0101f57:	68 bf 71 10 f0       	push   $0xf01071bf
f0101f5c:	e8 df e0 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101f61:	83 ec 04             	sub    $0x4,%esp
f0101f64:	6a 00                	push   $0x0
f0101f66:	68 00 10 00 00       	push   $0x1000
f0101f6b:	57                   	push   %edi
f0101f6c:	e8 0e f2 ff ff       	call   f010117f <pgdir_walk>
f0101f71:	83 c4 10             	add    $0x10,%esp
f0101f74:	f6 00 04             	testb  $0x4,(%eax)
f0101f77:	75 19                	jne    f0101f92 <mem_init+0xa1e>
f0101f79:	68 d0 79 10 f0       	push   $0xf01079d0
f0101f7e:	68 e5 71 10 f0       	push   $0xf01071e5
f0101f83:	68 8f 04 00 00       	push   $0x48f
f0101f88:	68 bf 71 10 f0       	push   $0xf01071bf
f0101f8d:	e8 ae e0 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101f92:	a1 98 ae 2a f0       	mov    0xf02aae98,%eax
f0101f97:	f6 00 04             	testb  $0x4,(%eax)
f0101f9a:	75 19                	jne    f0101fb5 <mem_init+0xa41>
f0101f9c:	68 37 74 10 f0       	push   $0xf0107437
f0101fa1:	68 e5 71 10 f0       	push   $0xf01071e5
f0101fa6:	68 90 04 00 00       	push   $0x490
f0101fab:	68 bf 71 10 f0       	push   $0xf01071bf
f0101fb0:	e8 8b e0 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101fb5:	6a 02                	push   $0x2
f0101fb7:	68 00 10 00 00       	push   $0x1000
f0101fbc:	56                   	push   %esi
f0101fbd:	50                   	push   %eax
f0101fbe:	e8 c1 f4 ff ff       	call   f0101484 <page_insert>
f0101fc3:	83 c4 10             	add    $0x10,%esp
f0101fc6:	85 c0                	test   %eax,%eax
f0101fc8:	74 19                	je     f0101fe3 <mem_init+0xa6f>
f0101fca:	68 e4 78 10 f0       	push   $0xf01078e4
f0101fcf:	68 e5 71 10 f0       	push   $0xf01071e5
f0101fd4:	68 93 04 00 00       	push   $0x493
f0101fd9:	68 bf 71 10 f0       	push   $0xf01071bf
f0101fde:	e8 5d e0 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101fe3:	83 ec 04             	sub    $0x4,%esp
f0101fe6:	6a 00                	push   $0x0
f0101fe8:	68 00 10 00 00       	push   $0x1000
f0101fed:	ff 35 98 ae 2a f0    	pushl  0xf02aae98
f0101ff3:	e8 87 f1 ff ff       	call   f010117f <pgdir_walk>
f0101ff8:	83 c4 10             	add    $0x10,%esp
f0101ffb:	f6 00 02             	testb  $0x2,(%eax)
f0101ffe:	75 19                	jne    f0102019 <mem_init+0xaa5>
f0102000:	68 04 7a 10 f0       	push   $0xf0107a04
f0102005:	68 e5 71 10 f0       	push   $0xf01071e5
f010200a:	68 94 04 00 00       	push   $0x494
f010200f:	68 bf 71 10 f0       	push   $0xf01071bf
f0102014:	e8 27 e0 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102019:	83 ec 04             	sub    $0x4,%esp
f010201c:	6a 00                	push   $0x0
f010201e:	68 00 10 00 00       	push   $0x1000
f0102023:	ff 35 98 ae 2a f0    	pushl  0xf02aae98
f0102029:	e8 51 f1 ff ff       	call   f010117f <pgdir_walk>
f010202e:	83 c4 10             	add    $0x10,%esp
f0102031:	f6 00 04             	testb  $0x4,(%eax)
f0102034:	74 19                	je     f010204f <mem_init+0xadb>
f0102036:	68 38 7a 10 f0       	push   $0xf0107a38
f010203b:	68 e5 71 10 f0       	push   $0xf01071e5
f0102040:	68 95 04 00 00       	push   $0x495
f0102045:	68 bf 71 10 f0       	push   $0xf01071bf
f010204a:	e8 f1 df ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f010204f:	6a 02                	push   $0x2
f0102051:	68 00 00 40 00       	push   $0x400000
f0102056:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102059:	ff 35 98 ae 2a f0    	pushl  0xf02aae98
f010205f:	e8 20 f4 ff ff       	call   f0101484 <page_insert>
f0102064:	83 c4 10             	add    $0x10,%esp
f0102067:	85 c0                	test   %eax,%eax
f0102069:	78 19                	js     f0102084 <mem_init+0xb10>
f010206b:	68 70 7a 10 f0       	push   $0xf0107a70
f0102070:	68 e5 71 10 f0       	push   $0xf01071e5
f0102075:	68 98 04 00 00       	push   $0x498
f010207a:	68 bf 71 10 f0       	push   $0xf01071bf
f010207f:	e8 bc df ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102084:	6a 02                	push   $0x2
f0102086:	68 00 10 00 00       	push   $0x1000
f010208b:	53                   	push   %ebx
f010208c:	ff 35 98 ae 2a f0    	pushl  0xf02aae98
f0102092:	e8 ed f3 ff ff       	call   f0101484 <page_insert>
f0102097:	83 c4 10             	add    $0x10,%esp
f010209a:	85 c0                	test   %eax,%eax
f010209c:	74 19                	je     f01020b7 <mem_init+0xb43>
f010209e:	68 a8 7a 10 f0       	push   $0xf0107aa8
f01020a3:	68 e5 71 10 f0       	push   $0xf01071e5
f01020a8:	68 9b 04 00 00       	push   $0x49b
f01020ad:	68 bf 71 10 f0       	push   $0xf01071bf
f01020b2:	e8 89 df ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01020b7:	83 ec 04             	sub    $0x4,%esp
f01020ba:	6a 00                	push   $0x0
f01020bc:	68 00 10 00 00       	push   $0x1000
f01020c1:	ff 35 98 ae 2a f0    	pushl  0xf02aae98
f01020c7:	e8 b3 f0 ff ff       	call   f010117f <pgdir_walk>
f01020cc:	83 c4 10             	add    $0x10,%esp
f01020cf:	f6 00 04             	testb  $0x4,(%eax)
f01020d2:	74 19                	je     f01020ed <mem_init+0xb79>
f01020d4:	68 38 7a 10 f0       	push   $0xf0107a38
f01020d9:	68 e5 71 10 f0       	push   $0xf01071e5
f01020de:	68 9c 04 00 00       	push   $0x49c
f01020e3:	68 bf 71 10 f0       	push   $0xf01071bf
f01020e8:	e8 53 df ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01020ed:	8b 3d 98 ae 2a f0    	mov    0xf02aae98,%edi
f01020f3:	ba 00 00 00 00       	mov    $0x0,%edx
f01020f8:	89 f8                	mov    %edi,%eax
f01020fa:	e8 76 ea ff ff       	call   f0100b75 <check_va2pa>
f01020ff:	89 c1                	mov    %eax,%ecx
f0102101:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102104:	89 d8                	mov    %ebx,%eax
f0102106:	2b 05 9c ae 2a f0    	sub    0xf02aae9c,%eax
f010210c:	c1 f8 03             	sar    $0x3,%eax
f010210f:	c1 e0 0c             	shl    $0xc,%eax
f0102112:	39 c1                	cmp    %eax,%ecx
f0102114:	74 19                	je     f010212f <mem_init+0xbbb>
f0102116:	68 e4 7a 10 f0       	push   $0xf0107ae4
f010211b:	68 e5 71 10 f0       	push   $0xf01071e5
f0102120:	68 9f 04 00 00       	push   $0x49f
f0102125:	68 bf 71 10 f0       	push   $0xf01071bf
f010212a:	e8 11 df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010212f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102134:	89 f8                	mov    %edi,%eax
f0102136:	e8 3a ea ff ff       	call   f0100b75 <check_va2pa>
f010213b:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f010213e:	74 19                	je     f0102159 <mem_init+0xbe5>
f0102140:	68 10 7b 10 f0       	push   $0xf0107b10
f0102145:	68 e5 71 10 f0       	push   $0xf01071e5
f010214a:	68 a0 04 00 00       	push   $0x4a0
f010214f:	68 bf 71 10 f0       	push   $0xf01071bf
f0102154:	e8 e7 de ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102159:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f010215e:	74 19                	je     f0102179 <mem_init+0xc05>
f0102160:	68 4d 74 10 f0       	push   $0xf010744d
f0102165:	68 e5 71 10 f0       	push   $0xf01071e5
f010216a:	68 a2 04 00 00       	push   $0x4a2
f010216f:	68 bf 71 10 f0       	push   $0xf01071bf
f0102174:	e8 c7 de ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102179:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010217e:	74 19                	je     f0102199 <mem_init+0xc25>
f0102180:	68 5e 74 10 f0       	push   $0xf010745e
f0102185:	68 e5 71 10 f0       	push   $0xf01071e5
f010218a:	68 a3 04 00 00       	push   $0x4a3
f010218f:	68 bf 71 10 f0       	push   $0xf01071bf
f0102194:	e8 a7 de ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102199:	83 ec 0c             	sub    $0xc,%esp
f010219c:	6a 00                	push   $0x0
f010219e:	e8 ee ee ff ff       	call   f0101091 <page_alloc>
f01021a3:	83 c4 10             	add    $0x10,%esp
f01021a6:	85 c0                	test   %eax,%eax
f01021a8:	74 04                	je     f01021ae <mem_init+0xc3a>
f01021aa:	39 c6                	cmp    %eax,%esi
f01021ac:	74 19                	je     f01021c7 <mem_init+0xc53>
f01021ae:	68 40 7b 10 f0       	push   $0xf0107b40
f01021b3:	68 e5 71 10 f0       	push   $0xf01071e5
f01021b8:	68 a6 04 00 00       	push   $0x4a6
f01021bd:	68 bf 71 10 f0       	push   $0xf01071bf
f01021c2:	e8 79 de ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01021c7:	83 ec 08             	sub    $0x8,%esp
f01021ca:	6a 00                	push   $0x0
f01021cc:	ff 35 98 ae 2a f0    	pushl  0xf02aae98
f01021d2:	e8 60 f2 ff ff       	call   f0101437 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01021d7:	8b 3d 98 ae 2a f0    	mov    0xf02aae98,%edi
f01021dd:	ba 00 00 00 00       	mov    $0x0,%edx
f01021e2:	89 f8                	mov    %edi,%eax
f01021e4:	e8 8c e9 ff ff       	call   f0100b75 <check_va2pa>
f01021e9:	83 c4 10             	add    $0x10,%esp
f01021ec:	83 f8 ff             	cmp    $0xffffffff,%eax
f01021ef:	74 19                	je     f010220a <mem_init+0xc96>
f01021f1:	68 64 7b 10 f0       	push   $0xf0107b64
f01021f6:	68 e5 71 10 f0       	push   $0xf01071e5
f01021fb:	68 aa 04 00 00       	push   $0x4aa
f0102200:	68 bf 71 10 f0       	push   $0xf01071bf
f0102205:	e8 36 de ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010220a:	ba 00 10 00 00       	mov    $0x1000,%edx
f010220f:	89 f8                	mov    %edi,%eax
f0102211:	e8 5f e9 ff ff       	call   f0100b75 <check_va2pa>
f0102216:	89 da                	mov    %ebx,%edx
f0102218:	2b 15 9c ae 2a f0    	sub    0xf02aae9c,%edx
f010221e:	c1 fa 03             	sar    $0x3,%edx
f0102221:	c1 e2 0c             	shl    $0xc,%edx
f0102224:	39 d0                	cmp    %edx,%eax
f0102226:	74 19                	je     f0102241 <mem_init+0xccd>
f0102228:	68 10 7b 10 f0       	push   $0xf0107b10
f010222d:	68 e5 71 10 f0       	push   $0xf01071e5
f0102232:	68 ab 04 00 00       	push   $0x4ab
f0102237:	68 bf 71 10 f0       	push   $0xf01071bf
f010223c:	e8 ff dd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102241:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102246:	74 19                	je     f0102261 <mem_init+0xced>
f0102248:	68 04 74 10 f0       	push   $0xf0107404
f010224d:	68 e5 71 10 f0       	push   $0xf01071e5
f0102252:	68 ac 04 00 00       	push   $0x4ac
f0102257:	68 bf 71 10 f0       	push   $0xf01071bf
f010225c:	e8 df dd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102261:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102266:	74 19                	je     f0102281 <mem_init+0xd0d>
f0102268:	68 5e 74 10 f0       	push   $0xf010745e
f010226d:	68 e5 71 10 f0       	push   $0xf01071e5
f0102272:	68 ad 04 00 00       	push   $0x4ad
f0102277:	68 bf 71 10 f0       	push   $0xf01071bf
f010227c:	e8 bf dd ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102281:	6a 00                	push   $0x0
f0102283:	68 00 10 00 00       	push   $0x1000
f0102288:	53                   	push   %ebx
f0102289:	57                   	push   %edi
f010228a:	e8 f5 f1 ff ff       	call   f0101484 <page_insert>
f010228f:	83 c4 10             	add    $0x10,%esp
f0102292:	85 c0                	test   %eax,%eax
f0102294:	74 19                	je     f01022af <mem_init+0xd3b>
f0102296:	68 88 7b 10 f0       	push   $0xf0107b88
f010229b:	68 e5 71 10 f0       	push   $0xf01071e5
f01022a0:	68 b0 04 00 00       	push   $0x4b0
f01022a5:	68 bf 71 10 f0       	push   $0xf01071bf
f01022aa:	e8 91 dd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f01022af:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01022b4:	75 19                	jne    f01022cf <mem_init+0xd5b>
f01022b6:	68 6f 74 10 f0       	push   $0xf010746f
f01022bb:	68 e5 71 10 f0       	push   $0xf01071e5
f01022c0:	68 b1 04 00 00       	push   $0x4b1
f01022c5:	68 bf 71 10 f0       	push   $0xf01071bf
f01022ca:	e8 71 dd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f01022cf:	83 3b 00             	cmpl   $0x0,(%ebx)
f01022d2:	74 19                	je     f01022ed <mem_init+0xd79>
f01022d4:	68 7b 74 10 f0       	push   $0xf010747b
f01022d9:	68 e5 71 10 f0       	push   $0xf01071e5
f01022de:	68 b2 04 00 00       	push   $0x4b2
f01022e3:	68 bf 71 10 f0       	push   $0xf01071bf
f01022e8:	e8 53 dd ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01022ed:	83 ec 08             	sub    $0x8,%esp
f01022f0:	68 00 10 00 00       	push   $0x1000
f01022f5:	ff 35 98 ae 2a f0    	pushl  0xf02aae98
f01022fb:	e8 37 f1 ff ff       	call   f0101437 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102300:	8b 3d 98 ae 2a f0    	mov    0xf02aae98,%edi
f0102306:	ba 00 00 00 00       	mov    $0x0,%edx
f010230b:	89 f8                	mov    %edi,%eax
f010230d:	e8 63 e8 ff ff       	call   f0100b75 <check_va2pa>
f0102312:	83 c4 10             	add    $0x10,%esp
f0102315:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102318:	74 19                	je     f0102333 <mem_init+0xdbf>
f010231a:	68 64 7b 10 f0       	push   $0xf0107b64
f010231f:	68 e5 71 10 f0       	push   $0xf01071e5
f0102324:	68 b6 04 00 00       	push   $0x4b6
f0102329:	68 bf 71 10 f0       	push   $0xf01071bf
f010232e:	e8 0d dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102333:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102338:	89 f8                	mov    %edi,%eax
f010233a:	e8 36 e8 ff ff       	call   f0100b75 <check_va2pa>
f010233f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102342:	74 19                	je     f010235d <mem_init+0xde9>
f0102344:	68 c0 7b 10 f0       	push   $0xf0107bc0
f0102349:	68 e5 71 10 f0       	push   $0xf01071e5
f010234e:	68 b7 04 00 00       	push   $0x4b7
f0102353:	68 bf 71 10 f0       	push   $0xf01071bf
f0102358:	e8 e3 dc ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f010235d:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102362:	74 19                	je     f010237d <mem_init+0xe09>
f0102364:	68 90 74 10 f0       	push   $0xf0107490
f0102369:	68 e5 71 10 f0       	push   $0xf01071e5
f010236e:	68 b8 04 00 00       	push   $0x4b8
f0102373:	68 bf 71 10 f0       	push   $0xf01071bf
f0102378:	e8 c3 dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010237d:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102382:	74 19                	je     f010239d <mem_init+0xe29>
f0102384:	68 5e 74 10 f0       	push   $0xf010745e
f0102389:	68 e5 71 10 f0       	push   $0xf01071e5
f010238e:	68 b9 04 00 00       	push   $0x4b9
f0102393:	68 bf 71 10 f0       	push   $0xf01071bf
f0102398:	e8 a3 dc ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f010239d:	83 ec 0c             	sub    $0xc,%esp
f01023a0:	6a 00                	push   $0x0
f01023a2:	e8 ea ec ff ff       	call   f0101091 <page_alloc>
f01023a7:	83 c4 10             	add    $0x10,%esp
f01023aa:	39 c3                	cmp    %eax,%ebx
f01023ac:	75 04                	jne    f01023b2 <mem_init+0xe3e>
f01023ae:	85 c0                	test   %eax,%eax
f01023b0:	75 19                	jne    f01023cb <mem_init+0xe57>
f01023b2:	68 e8 7b 10 f0       	push   $0xf0107be8
f01023b7:	68 e5 71 10 f0       	push   $0xf01071e5
f01023bc:	68 bc 04 00 00       	push   $0x4bc
f01023c1:	68 bf 71 10 f0       	push   $0xf01071bf
f01023c6:	e8 75 dc ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01023cb:	83 ec 0c             	sub    $0xc,%esp
f01023ce:	6a 00                	push   $0x0
f01023d0:	e8 bc ec ff ff       	call   f0101091 <page_alloc>
f01023d5:	83 c4 10             	add    $0x10,%esp
f01023d8:	85 c0                	test   %eax,%eax
f01023da:	74 19                	je     f01023f5 <mem_init+0xe81>
f01023dc:	68 b2 73 10 f0       	push   $0xf01073b2
f01023e1:	68 e5 71 10 f0       	push   $0xf01071e5
f01023e6:	68 bf 04 00 00       	push   $0x4bf
f01023eb:	68 bf 71 10 f0       	push   $0xf01071bf
f01023f0:	e8 4b dc ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01023f5:	8b 0d 98 ae 2a f0    	mov    0xf02aae98,%ecx
f01023fb:	8b 11                	mov    (%ecx),%edx
f01023fd:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102403:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102406:	2b 05 9c ae 2a f0    	sub    0xf02aae9c,%eax
f010240c:	c1 f8 03             	sar    $0x3,%eax
f010240f:	c1 e0 0c             	shl    $0xc,%eax
f0102412:	39 c2                	cmp    %eax,%edx
f0102414:	74 19                	je     f010242f <mem_init+0xebb>
f0102416:	68 8c 78 10 f0       	push   $0xf010788c
f010241b:	68 e5 71 10 f0       	push   $0xf01071e5
f0102420:	68 c2 04 00 00       	push   $0x4c2
f0102425:	68 bf 71 10 f0       	push   $0xf01071bf
f010242a:	e8 11 dc ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f010242f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102435:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102438:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010243d:	74 19                	je     f0102458 <mem_init+0xee4>
f010243f:	68 15 74 10 f0       	push   $0xf0107415
f0102444:	68 e5 71 10 f0       	push   $0xf01071e5
f0102449:	68 c4 04 00 00       	push   $0x4c4
f010244e:	68 bf 71 10 f0       	push   $0xf01071bf
f0102453:	e8 e8 db ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102458:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010245b:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102461:	83 ec 0c             	sub    $0xc,%esp
f0102464:	50                   	push   %eax
f0102465:	e8 98 ec ff ff       	call   f0101102 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f010246a:	83 c4 0c             	add    $0xc,%esp
f010246d:	6a 01                	push   $0x1
f010246f:	68 00 10 40 00       	push   $0x401000
f0102474:	ff 35 98 ae 2a f0    	pushl  0xf02aae98
f010247a:	e8 00 ed ff ff       	call   f010117f <pgdir_walk>
f010247f:	89 c7                	mov    %eax,%edi
f0102481:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102484:	a1 98 ae 2a f0       	mov    0xf02aae98,%eax
f0102489:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010248c:	8b 40 04             	mov    0x4(%eax),%eax
f010248f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102494:	8b 0d 94 ae 2a f0    	mov    0xf02aae94,%ecx
f010249a:	89 c2                	mov    %eax,%edx
f010249c:	c1 ea 0c             	shr    $0xc,%edx
f010249f:	83 c4 10             	add    $0x10,%esp
f01024a2:	39 ca                	cmp    %ecx,%edx
f01024a4:	72 15                	jb     f01024bb <mem_init+0xf47>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024a6:	50                   	push   %eax
f01024a7:	68 04 6c 10 f0       	push   $0xf0106c04
f01024ac:	68 cb 04 00 00       	push   $0x4cb
f01024b1:	68 bf 71 10 f0       	push   $0xf01071bf
f01024b6:	e8 85 db ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01024bb:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f01024c0:	39 c7                	cmp    %eax,%edi
f01024c2:	74 19                	je     f01024dd <mem_init+0xf69>
f01024c4:	68 a1 74 10 f0       	push   $0xf01074a1
f01024c9:	68 e5 71 10 f0       	push   $0xf01071e5
f01024ce:	68 cc 04 00 00       	push   $0x4cc
f01024d3:	68 bf 71 10 f0       	push   $0xf01071bf
f01024d8:	e8 63 db ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f01024dd:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01024e0:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f01024e7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01024ea:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01024f0:	2b 05 9c ae 2a f0    	sub    0xf02aae9c,%eax
f01024f6:	c1 f8 03             	sar    $0x3,%eax
f01024f9:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01024fc:	89 c2                	mov    %eax,%edx
f01024fe:	c1 ea 0c             	shr    $0xc,%edx
f0102501:	39 d1                	cmp    %edx,%ecx
f0102503:	77 12                	ja     f0102517 <mem_init+0xfa3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102505:	50                   	push   %eax
f0102506:	68 04 6c 10 f0       	push   $0xf0106c04
f010250b:	6a 58                	push   $0x58
f010250d:	68 cb 71 10 f0       	push   $0xf01071cb
f0102512:	e8 29 db ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102517:	83 ec 04             	sub    $0x4,%esp
f010251a:	68 00 10 00 00       	push   $0x1000
f010251f:	68 ff 00 00 00       	push   $0xff
f0102524:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102529:	50                   	push   %eax
f010252a:	e8 87 32 00 00       	call   f01057b6 <memset>
	page_free(pp0);
f010252f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102532:	89 3c 24             	mov    %edi,(%esp)
f0102535:	e8 c8 eb ff ff       	call   f0101102 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f010253a:	83 c4 0c             	add    $0xc,%esp
f010253d:	6a 01                	push   $0x1
f010253f:	6a 00                	push   $0x0
f0102541:	ff 35 98 ae 2a f0    	pushl  0xf02aae98
f0102547:	e8 33 ec ff ff       	call   f010117f <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010254c:	89 fa                	mov    %edi,%edx
f010254e:	2b 15 9c ae 2a f0    	sub    0xf02aae9c,%edx
f0102554:	c1 fa 03             	sar    $0x3,%edx
f0102557:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010255a:	89 d0                	mov    %edx,%eax
f010255c:	c1 e8 0c             	shr    $0xc,%eax
f010255f:	83 c4 10             	add    $0x10,%esp
f0102562:	3b 05 94 ae 2a f0    	cmp    0xf02aae94,%eax
f0102568:	72 12                	jb     f010257c <mem_init+0x1008>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010256a:	52                   	push   %edx
f010256b:	68 04 6c 10 f0       	push   $0xf0106c04
f0102570:	6a 58                	push   $0x58
f0102572:	68 cb 71 10 f0       	push   $0xf01071cb
f0102577:	e8 c4 da ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010257c:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102582:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102585:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010258b:	f6 00 01             	testb  $0x1,(%eax)
f010258e:	74 19                	je     f01025a9 <mem_init+0x1035>
f0102590:	68 b9 74 10 f0       	push   $0xf01074b9
f0102595:	68 e5 71 10 f0       	push   $0xf01071e5
f010259a:	68 d6 04 00 00       	push   $0x4d6
f010259f:	68 bf 71 10 f0       	push   $0xf01071bf
f01025a4:	e8 97 da ff ff       	call   f0100040 <_panic>
f01025a9:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01025ac:	39 d0                	cmp    %edx,%eax
f01025ae:	75 db                	jne    f010258b <mem_init+0x1017>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01025b0:	a1 98 ae 2a f0       	mov    0xf02aae98,%eax
f01025b5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01025bb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01025be:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f01025c4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01025c7:	89 0d 40 a2 2a f0    	mov    %ecx,0xf02aa240

	// free the pages we took
	page_free(pp0);
f01025cd:	83 ec 0c             	sub    $0xc,%esp
f01025d0:	50                   	push   %eax
f01025d1:	e8 2c eb ff ff       	call   f0101102 <page_free>
	page_free(pp1);
f01025d6:	89 1c 24             	mov    %ebx,(%esp)
f01025d9:	e8 24 eb ff ff       	call   f0101102 <page_free>
	page_free(pp2);
f01025de:	89 34 24             	mov    %esi,(%esp)
f01025e1:	e8 1c eb ff ff       	call   f0101102 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f01025e6:	83 c4 08             	add    $0x8,%esp
f01025e9:	68 01 10 00 00       	push   $0x1001
f01025ee:	6a 00                	push   $0x0
f01025f0:	e8 16 ef ff ff       	call   f010150b <mmio_map_region>
f01025f5:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f01025f7:	83 c4 08             	add    $0x8,%esp
f01025fa:	68 00 10 00 00       	push   $0x1000
f01025ff:	6a 00                	push   $0x0
f0102601:	e8 05 ef ff ff       	call   f010150b <mmio_map_region>
f0102606:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f0102608:	8d 83 00 20 00 00    	lea    0x2000(%ebx),%eax
f010260e:	83 c4 10             	add    $0x10,%esp
f0102611:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102617:	76 07                	jbe    f0102620 <mem_init+0x10ac>
f0102619:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f010261e:	76 19                	jbe    f0102639 <mem_init+0x10c5>
f0102620:	68 0c 7c 10 f0       	push   $0xf0107c0c
f0102625:	68 e5 71 10 f0       	push   $0xf01071e5
f010262a:	68 e6 04 00 00       	push   $0x4e6
f010262f:	68 bf 71 10 f0       	push   $0xf01071bf
f0102634:	e8 07 da ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f0102639:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
f010263f:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102645:	77 08                	ja     f010264f <mem_init+0x10db>
f0102647:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010264d:	77 19                	ja     f0102668 <mem_init+0x10f4>
f010264f:	68 34 7c 10 f0       	push   $0xf0107c34
f0102654:	68 e5 71 10 f0       	push   $0xf01071e5
f0102659:	68 e7 04 00 00       	push   $0x4e7
f010265e:	68 bf 71 10 f0       	push   $0xf01071bf
f0102663:	e8 d8 d9 ff ff       	call   f0100040 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102668:	89 da                	mov    %ebx,%edx
f010266a:	09 f2                	or     %esi,%edx
f010266c:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102672:	74 19                	je     f010268d <mem_init+0x1119>
f0102674:	68 5c 7c 10 f0       	push   $0xf0107c5c
f0102679:	68 e5 71 10 f0       	push   $0xf01071e5
f010267e:	68 e9 04 00 00       	push   $0x4e9
f0102683:	68 bf 71 10 f0       	push   $0xf01071bf
f0102688:	e8 b3 d9 ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8192 <= mm2);
f010268d:	39 c6                	cmp    %eax,%esi
f010268f:	73 19                	jae    f01026aa <mem_init+0x1136>
f0102691:	68 d0 74 10 f0       	push   $0xf01074d0
f0102696:	68 e5 71 10 f0       	push   $0xf01071e5
f010269b:	68 eb 04 00 00       	push   $0x4eb
f01026a0:	68 bf 71 10 f0       	push   $0xf01071bf
f01026a5:	e8 96 d9 ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01026aa:	8b 3d 98 ae 2a f0    	mov    0xf02aae98,%edi
f01026b0:	89 da                	mov    %ebx,%edx
f01026b2:	89 f8                	mov    %edi,%eax
f01026b4:	e8 bc e4 ff ff       	call   f0100b75 <check_va2pa>
f01026b9:	85 c0                	test   %eax,%eax
f01026bb:	74 19                	je     f01026d6 <mem_init+0x1162>
f01026bd:	68 84 7c 10 f0       	push   $0xf0107c84
f01026c2:	68 e5 71 10 f0       	push   $0xf01071e5
f01026c7:	68 ed 04 00 00       	push   $0x4ed
f01026cc:	68 bf 71 10 f0       	push   $0xf01071bf
f01026d1:	e8 6a d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01026d6:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f01026dc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01026df:	89 c2                	mov    %eax,%edx
f01026e1:	89 f8                	mov    %edi,%eax
f01026e3:	e8 8d e4 ff ff       	call   f0100b75 <check_va2pa>
f01026e8:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01026ed:	74 19                	je     f0102708 <mem_init+0x1194>
f01026ef:	68 a8 7c 10 f0       	push   $0xf0107ca8
f01026f4:	68 e5 71 10 f0       	push   $0xf01071e5
f01026f9:	68 ee 04 00 00       	push   $0x4ee
f01026fe:	68 bf 71 10 f0       	push   $0xf01071bf
f0102703:	e8 38 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102708:	89 f2                	mov    %esi,%edx
f010270a:	89 f8                	mov    %edi,%eax
f010270c:	e8 64 e4 ff ff       	call   f0100b75 <check_va2pa>
f0102711:	85 c0                	test   %eax,%eax
f0102713:	74 19                	je     f010272e <mem_init+0x11ba>
f0102715:	68 d8 7c 10 f0       	push   $0xf0107cd8
f010271a:	68 e5 71 10 f0       	push   $0xf01071e5
f010271f:	68 ef 04 00 00       	push   $0x4ef
f0102724:	68 bf 71 10 f0       	push   $0xf01071bf
f0102729:	e8 12 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f010272e:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102734:	89 f8                	mov    %edi,%eax
f0102736:	e8 3a e4 ff ff       	call   f0100b75 <check_va2pa>
f010273b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010273e:	74 19                	je     f0102759 <mem_init+0x11e5>
f0102740:	68 fc 7c 10 f0       	push   $0xf0107cfc
f0102745:	68 e5 71 10 f0       	push   $0xf01071e5
f010274a:	68 f0 04 00 00       	push   $0x4f0
f010274f:	68 bf 71 10 f0       	push   $0xf01071bf
f0102754:	e8 e7 d8 ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102759:	83 ec 04             	sub    $0x4,%esp
f010275c:	6a 00                	push   $0x0
f010275e:	53                   	push   %ebx
f010275f:	57                   	push   %edi
f0102760:	e8 1a ea ff ff       	call   f010117f <pgdir_walk>
f0102765:	83 c4 10             	add    $0x10,%esp
f0102768:	f6 00 1a             	testb  $0x1a,(%eax)
f010276b:	75 19                	jne    f0102786 <mem_init+0x1212>
f010276d:	68 28 7d 10 f0       	push   $0xf0107d28
f0102772:	68 e5 71 10 f0       	push   $0xf01071e5
f0102777:	68 f2 04 00 00       	push   $0x4f2
f010277c:	68 bf 71 10 f0       	push   $0xf01071bf
f0102781:	e8 ba d8 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102786:	83 ec 04             	sub    $0x4,%esp
f0102789:	6a 00                	push   $0x0
f010278b:	53                   	push   %ebx
f010278c:	ff 35 98 ae 2a f0    	pushl  0xf02aae98
f0102792:	e8 e8 e9 ff ff       	call   f010117f <pgdir_walk>
f0102797:	8b 00                	mov    (%eax),%eax
f0102799:	83 c4 10             	add    $0x10,%esp
f010279c:	83 e0 04             	and    $0x4,%eax
f010279f:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01027a2:	74 19                	je     f01027bd <mem_init+0x1249>
f01027a4:	68 6c 7d 10 f0       	push   $0xf0107d6c
f01027a9:	68 e5 71 10 f0       	push   $0xf01071e5
f01027ae:	68 f3 04 00 00       	push   $0x4f3
f01027b3:	68 bf 71 10 f0       	push   $0xf01071bf
f01027b8:	e8 83 d8 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f01027bd:	83 ec 04             	sub    $0x4,%esp
f01027c0:	6a 00                	push   $0x0
f01027c2:	53                   	push   %ebx
f01027c3:	ff 35 98 ae 2a f0    	pushl  0xf02aae98
f01027c9:	e8 b1 e9 ff ff       	call   f010117f <pgdir_walk>
f01027ce:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f01027d4:	83 c4 0c             	add    $0xc,%esp
f01027d7:	6a 00                	push   $0x0
f01027d9:	ff 75 d4             	pushl  -0x2c(%ebp)
f01027dc:	ff 35 98 ae 2a f0    	pushl  0xf02aae98
f01027e2:	e8 98 e9 ff ff       	call   f010117f <pgdir_walk>
f01027e7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f01027ed:	83 c4 0c             	add    $0xc,%esp
f01027f0:	6a 00                	push   $0x0
f01027f2:	56                   	push   %esi
f01027f3:	ff 35 98 ae 2a f0    	pushl  0xf02aae98
f01027f9:	e8 81 e9 ff ff       	call   f010117f <pgdir_walk>
f01027fe:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102804:	c7 04 24 e2 74 10 f0 	movl   $0xf01074e2,(%esp)
f010280b:	e8 72 11 00 00       	call   f0103982 <cprintf>
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f0102810:	a1 9c ae 2a f0       	mov    0xf02aae9c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102815:	83 c4 10             	add    $0x10,%esp
f0102818:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010281d:	77 15                	ja     f0102834 <mem_init+0x12c0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010281f:	50                   	push   %eax
f0102820:	68 28 6c 10 f0       	push   $0xf0106c28
f0102825:	68 ca 00 00 00       	push   $0xca
f010282a:	68 bf 71 10 f0       	push   $0xf01071bf
f010282f:	e8 0c d8 ff ff       	call   f0100040 <_panic>
f0102834:	83 ec 08             	sub    $0x8,%esp
f0102837:	6a 04                	push   $0x4
f0102839:	05 00 00 00 10       	add    $0x10000000,%eax
f010283e:	50                   	push   %eax
f010283f:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102844:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102849:	a1 98 ae 2a f0       	mov    0xf02aae98,%eax
f010284e:	e8 76 ea ff ff       	call   f01012c9 <boot_map_region>
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.

	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U);
f0102853:	a1 48 a2 2a f0       	mov    0xf02aa248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102858:	83 c4 10             	add    $0x10,%esp
f010285b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102860:	77 15                	ja     f0102877 <mem_init+0x1303>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102862:	50                   	push   %eax
f0102863:	68 28 6c 10 f0       	push   $0xf0106c28
f0102868:	68 d4 00 00 00       	push   $0xd4
f010286d:	68 bf 71 10 f0       	push   $0xf01071bf
f0102872:	e8 c9 d7 ff ff       	call   f0100040 <_panic>
f0102877:	83 ec 08             	sub    $0x8,%esp
f010287a:	6a 04                	push   $0x4
f010287c:	05 00 00 00 10       	add    $0x10000000,%eax
f0102881:	50                   	push   %eax
f0102882:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102887:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f010288c:	a1 98 ae 2a f0       	mov    0xf02aae98,%eax
f0102891:	e8 33 ea ff ff       	call   f01012c9 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102896:	83 c4 10             	add    $0x10,%esp
f0102899:	b8 00 90 11 f0       	mov    $0xf0119000,%eax
f010289e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01028a3:	77 15                	ja     f01028ba <mem_init+0x1346>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01028a5:	50                   	push   %eax
f01028a6:	68 28 6c 10 f0       	push   $0xf0106c28
f01028ab:	68 e2 00 00 00       	push   $0xe2
f01028b0:	68 bf 71 10 f0       	push   $0xf01071bf
f01028b5:	e8 86 d7 ff ff       	call   f0100040 <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f01028ba:	83 ec 08             	sub    $0x8,%esp
f01028bd:	6a 02                	push   $0x2
f01028bf:	68 00 90 11 00       	push   $0x119000
f01028c4:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01028c9:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01028ce:	a1 98 ae 2a f0       	mov    0xf02aae98,%eax
f01028d3:	e8 f1 e9 ff ff       	call   f01012c9 <boot_map_region>
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, KERNBASE, ROUNDUP(~0 - KERNBASE, PGSIZE), 0, PTE_W);
f01028d8:	83 c4 08             	add    $0x8,%esp
f01028db:	6a 02                	push   $0x2
f01028dd:	6a 00                	push   $0x0
f01028df:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01028e4:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01028e9:	a1 98 ae 2a f0       	mov    0xf02aae98,%eax
f01028ee:	e8 d6 e9 ff ff       	call   f01012c9 <boot_map_region>
f01028f3:	c7 45 c4 00 c0 2a f0 	movl   $0xf02ac000,-0x3c(%ebp)
f01028fa:	83 c4 10             	add    $0x10,%esp
f01028fd:	bb 00 c0 2a f0       	mov    $0xf02ac000,%ebx
f0102902:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102907:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f010290d:	77 15                	ja     f0102924 <mem_init+0x13b0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010290f:	53                   	push   %ebx
f0102910:	68 28 6c 10 f0       	push   $0xf0106c28
f0102915:	68 26 01 00 00       	push   $0x126
f010291a:	68 bf 71 10 f0       	push   $0xf01071bf
f010291f:	e8 1c d7 ff ff       	call   f0100040 <_panic>

	uint32_t kstacktop_i;

	for (int i=0; i<NCPU; i++) {
		kstacktop_i = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
		boot_map_region(kern_pgdir, kstacktop_i - KSTKSIZE, KSTKSIZE, PADDR(&percpu_kstacks[i]), PTE_W );
f0102924:	83 ec 08             	sub    $0x8,%esp
f0102927:	6a 02                	push   $0x2
f0102929:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f010292f:	50                   	push   %eax
f0102930:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102935:	89 f2                	mov    %esi,%edx
f0102937:	a1 98 ae 2a f0       	mov    0xf02aae98,%eax
f010293c:	e8 88 e9 ff ff       	call   f01012c9 <boot_map_region>
f0102941:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102947:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//
	// LAB 4: Your code here:

	uint32_t kstacktop_i;

	for (int i=0; i<NCPU; i++) {
f010294d:	83 c4 10             	add    $0x10,%esp
f0102950:	b8 00 c0 2e f0       	mov    $0xf02ec000,%eax
f0102955:	39 d8                	cmp    %ebx,%eax
f0102957:	75 ae                	jne    f0102907 <mem_init+0x1393>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102959:	8b 3d 98 ae 2a f0    	mov    0xf02aae98,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010295f:	a1 94 ae 2a f0       	mov    0xf02aae94,%eax
f0102964:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102967:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f010296e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102973:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102976:	8b 35 9c ae 2a f0    	mov    0xf02aae9c,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010297c:	89 75 d0             	mov    %esi,-0x30(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010297f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102984:	eb 55                	jmp    f01029db <mem_init+0x1467>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102986:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f010298c:	89 f8                	mov    %edi,%eax
f010298e:	e8 e2 e1 ff ff       	call   f0100b75 <check_va2pa>
f0102993:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f010299a:	77 15                	ja     f01029b1 <mem_init+0x143d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010299c:	56                   	push   %esi
f010299d:	68 28 6c 10 f0       	push   $0xf0106c28
f01029a2:	68 07 04 00 00       	push   $0x407
f01029a7:	68 bf 71 10 f0       	push   $0xf01071bf
f01029ac:	e8 8f d6 ff ff       	call   f0100040 <_panic>
f01029b1:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f01029b8:	39 c2                	cmp    %eax,%edx
f01029ba:	74 19                	je     f01029d5 <mem_init+0x1461>
f01029bc:	68 a0 7d 10 f0       	push   $0xf0107da0
f01029c1:	68 e5 71 10 f0       	push   $0xf01071e5
f01029c6:	68 07 04 00 00       	push   $0x407
f01029cb:	68 bf 71 10 f0       	push   $0xf01071bf
f01029d0:	e8 6b d6 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01029d5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01029db:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01029de:	77 a6                	ja     f0102986 <mem_init+0x1412>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01029e0:	8b 35 48 a2 2a f0    	mov    0xf02aa248,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01029e6:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f01029e9:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f01029ee:	89 da                	mov    %ebx,%edx
f01029f0:	89 f8                	mov    %edi,%eax
f01029f2:	e8 7e e1 ff ff       	call   f0100b75 <check_va2pa>
f01029f7:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f01029fe:	77 15                	ja     f0102a15 <mem_init+0x14a1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a00:	56                   	push   %esi
f0102a01:	68 28 6c 10 f0       	push   $0xf0106c28
f0102a06:	68 0c 04 00 00       	push   $0x40c
f0102a0b:	68 bf 71 10 f0       	push   $0xf01071bf
f0102a10:	e8 2b d6 ff ff       	call   f0100040 <_panic>
f0102a15:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f0102a1c:	39 d0                	cmp    %edx,%eax
f0102a1e:	74 19                	je     f0102a39 <mem_init+0x14c5>
f0102a20:	68 d4 7d 10 f0       	push   $0xf0107dd4
f0102a25:	68 e5 71 10 f0       	push   $0xf01071e5
f0102a2a:	68 0c 04 00 00       	push   $0x40c
f0102a2f:	68 bf 71 10 f0       	push   $0xf01071bf
f0102a34:	e8 07 d6 ff ff       	call   f0100040 <_panic>
f0102a39:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102a3f:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102a45:	75 a7                	jne    f01029ee <mem_init+0x147a>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102a47:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0102a4a:	c1 e6 0c             	shl    $0xc,%esi
f0102a4d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102a52:	eb 30                	jmp    f0102a84 <mem_init+0x1510>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102a54:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102a5a:	89 f8                	mov    %edi,%eax
f0102a5c:	e8 14 e1 ff ff       	call   f0100b75 <check_va2pa>
f0102a61:	39 c3                	cmp    %eax,%ebx
f0102a63:	74 19                	je     f0102a7e <mem_init+0x150a>
f0102a65:	68 08 7e 10 f0       	push   $0xf0107e08
f0102a6a:	68 e5 71 10 f0       	push   $0xf01071e5
f0102a6f:	68 10 04 00 00       	push   $0x410
f0102a74:	68 bf 71 10 f0       	push   $0xf01071bf
f0102a79:	e8 c2 d5 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102a7e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102a84:	39 f3                	cmp    %esi,%ebx
f0102a86:	72 cc                	jb     f0102a54 <mem_init+0x14e0>
f0102a88:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102a8d:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0102a90:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0102a93:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102a96:	8d 88 00 80 00 00    	lea    0x8000(%eax),%ecx
f0102a9c:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0102a9f:	89 c3                	mov    %eax,%ebx
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102aa1:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102aa4:	05 00 80 00 20       	add    $0x20008000,%eax
f0102aa9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102aac:	89 da                	mov    %ebx,%edx
f0102aae:	89 f8                	mov    %edi,%eax
f0102ab0:	e8 c0 e0 ff ff       	call   f0100b75 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ab5:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102abb:	77 15                	ja     f0102ad2 <mem_init+0x155e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102abd:	56                   	push   %esi
f0102abe:	68 28 6c 10 f0       	push   $0xf0106c28
f0102ac3:	68 18 04 00 00       	push   $0x418
f0102ac8:	68 bf 71 10 f0       	push   $0xf01071bf
f0102acd:	e8 6e d5 ff ff       	call   f0100040 <_panic>
f0102ad2:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102ad5:	8d 94 0b 00 c0 2a f0 	lea    -0xfd54000(%ebx,%ecx,1),%edx
f0102adc:	39 d0                	cmp    %edx,%eax
f0102ade:	74 19                	je     f0102af9 <mem_init+0x1585>
f0102ae0:	68 30 7e 10 f0       	push   $0xf0107e30
f0102ae5:	68 e5 71 10 f0       	push   $0xf01071e5
f0102aea:	68 18 04 00 00       	push   $0x418
f0102aef:	68 bf 71 10 f0       	push   $0xf01071bf
f0102af4:	e8 47 d5 ff ff       	call   f0100040 <_panic>
f0102af9:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102aff:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f0102b02:	75 a8                	jne    f0102aac <mem_init+0x1538>
f0102b04:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102b07:	8d 98 00 80 ff ff    	lea    -0x8000(%eax),%ebx
f0102b0d:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102b10:	89 c6                	mov    %eax,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102b12:	89 da                	mov    %ebx,%edx
f0102b14:	89 f8                	mov    %edi,%eax
f0102b16:	e8 5a e0 ff ff       	call   f0100b75 <check_va2pa>
f0102b1b:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102b1e:	74 19                	je     f0102b39 <mem_init+0x15c5>
f0102b20:	68 78 7e 10 f0       	push   $0xf0107e78
f0102b25:	68 e5 71 10 f0       	push   $0xf01071e5
f0102b2a:	68 1a 04 00 00       	push   $0x41a
f0102b2f:	68 bf 71 10 f0       	push   $0xf01071bf
f0102b34:	e8 07 d5 ff ff       	call   f0100040 <_panic>
f0102b39:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102b3f:	39 f3                	cmp    %esi,%ebx
f0102b41:	75 cf                	jne    f0102b12 <mem_init+0x159e>
f0102b43:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102b46:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f0102b4d:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f0102b54:	81 c6 00 80 00 00    	add    $0x8000,%esi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102b5a:	b8 00 c0 2e f0       	mov    $0xf02ec000,%eax
f0102b5f:	39 f0                	cmp    %esi,%eax
f0102b61:	0f 85 2c ff ff ff    	jne    f0102a93 <mem_init+0x151f>
f0102b67:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b6c:	eb 2a                	jmp    f0102b98 <mem_init+0x1624>
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102b6e:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102b74:	83 fa 04             	cmp    $0x4,%edx
f0102b77:	77 1f                	ja     f0102b98 <mem_init+0x1624>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f0102b79:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102b7d:	75 7e                	jne    f0102bfd <mem_init+0x1689>
f0102b7f:	68 fb 74 10 f0       	push   $0xf01074fb
f0102b84:	68 e5 71 10 f0       	push   $0xf01071e5
f0102b89:	68 25 04 00 00       	push   $0x425
f0102b8e:	68 bf 71 10 f0       	push   $0xf01071bf
f0102b93:	e8 a8 d4 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102b98:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102b9d:	76 3f                	jbe    f0102bde <mem_init+0x166a>
				assert(pgdir[i] & PTE_P);
f0102b9f:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102ba2:	f6 c2 01             	test   $0x1,%dl
f0102ba5:	75 19                	jne    f0102bc0 <mem_init+0x164c>
f0102ba7:	68 fb 74 10 f0       	push   $0xf01074fb
f0102bac:	68 e5 71 10 f0       	push   $0xf01071e5
f0102bb1:	68 29 04 00 00       	push   $0x429
f0102bb6:	68 bf 71 10 f0       	push   $0xf01071bf
f0102bbb:	e8 80 d4 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102bc0:	f6 c2 02             	test   $0x2,%dl
f0102bc3:	75 38                	jne    f0102bfd <mem_init+0x1689>
f0102bc5:	68 0c 75 10 f0       	push   $0xf010750c
f0102bca:	68 e5 71 10 f0       	push   $0xf01071e5
f0102bcf:	68 2a 04 00 00       	push   $0x42a
f0102bd4:	68 bf 71 10 f0       	push   $0xf01071bf
f0102bd9:	e8 62 d4 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102bde:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102be2:	74 19                	je     f0102bfd <mem_init+0x1689>
f0102be4:	68 1d 75 10 f0       	push   $0xf010751d
f0102be9:	68 e5 71 10 f0       	push   $0xf01071e5
f0102bee:	68 2c 04 00 00       	push   $0x42c
f0102bf3:	68 bf 71 10 f0       	push   $0xf01071bf
f0102bf8:	e8 43 d4 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102bfd:	83 c0 01             	add    $0x1,%eax
f0102c00:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102c05:	0f 86 63 ff ff ff    	jbe    f0102b6e <mem_init+0x15fa>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102c0b:	83 ec 0c             	sub    $0xc,%esp
f0102c0e:	68 9c 7e 10 f0       	push   $0xf0107e9c
f0102c13:	e8 6a 0d 00 00       	call   f0103982 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102c18:	a1 98 ae 2a f0       	mov    0xf02aae98,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c1d:	83 c4 10             	add    $0x10,%esp
f0102c20:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c25:	77 15                	ja     f0102c3c <mem_init+0x16c8>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c27:	50                   	push   %eax
f0102c28:	68 28 6c 10 f0       	push   $0xf0106c28
f0102c2d:	68 fc 00 00 00       	push   $0xfc
f0102c32:	68 bf 71 10 f0       	push   $0xf01071bf
f0102c37:	e8 04 d4 ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102c3c:	05 00 00 00 10       	add    $0x10000000,%eax
f0102c41:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102c44:	b8 00 00 00 00       	mov    $0x0,%eax
f0102c49:	e8 8b df ff ff       	call   f0100bd9 <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102c4e:	0f 20 c0             	mov    %cr0,%eax
f0102c51:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102c54:	0d 23 00 05 80       	or     $0x80050023,%eax
f0102c59:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102c5c:	83 ec 0c             	sub    $0xc,%esp
f0102c5f:	6a 00                	push   $0x0
f0102c61:	e8 2b e4 ff ff       	call   f0101091 <page_alloc>
f0102c66:	89 c3                	mov    %eax,%ebx
f0102c68:	83 c4 10             	add    $0x10,%esp
f0102c6b:	85 c0                	test   %eax,%eax
f0102c6d:	75 19                	jne    f0102c88 <mem_init+0x1714>
f0102c6f:	68 07 73 10 f0       	push   $0xf0107307
f0102c74:	68 e5 71 10 f0       	push   $0xf01071e5
f0102c79:	68 08 05 00 00       	push   $0x508
f0102c7e:	68 bf 71 10 f0       	push   $0xf01071bf
f0102c83:	e8 b8 d3 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102c88:	83 ec 0c             	sub    $0xc,%esp
f0102c8b:	6a 00                	push   $0x0
f0102c8d:	e8 ff e3 ff ff       	call   f0101091 <page_alloc>
f0102c92:	89 c7                	mov    %eax,%edi
f0102c94:	83 c4 10             	add    $0x10,%esp
f0102c97:	85 c0                	test   %eax,%eax
f0102c99:	75 19                	jne    f0102cb4 <mem_init+0x1740>
f0102c9b:	68 1d 73 10 f0       	push   $0xf010731d
f0102ca0:	68 e5 71 10 f0       	push   $0xf01071e5
f0102ca5:	68 09 05 00 00       	push   $0x509
f0102caa:	68 bf 71 10 f0       	push   $0xf01071bf
f0102caf:	e8 8c d3 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102cb4:	83 ec 0c             	sub    $0xc,%esp
f0102cb7:	6a 00                	push   $0x0
f0102cb9:	e8 d3 e3 ff ff       	call   f0101091 <page_alloc>
f0102cbe:	89 c6                	mov    %eax,%esi
f0102cc0:	83 c4 10             	add    $0x10,%esp
f0102cc3:	85 c0                	test   %eax,%eax
f0102cc5:	75 19                	jne    f0102ce0 <mem_init+0x176c>
f0102cc7:	68 33 73 10 f0       	push   $0xf0107333
f0102ccc:	68 e5 71 10 f0       	push   $0xf01071e5
f0102cd1:	68 0a 05 00 00       	push   $0x50a
f0102cd6:	68 bf 71 10 f0       	push   $0xf01071bf
f0102cdb:	e8 60 d3 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0102ce0:	83 ec 0c             	sub    $0xc,%esp
f0102ce3:	53                   	push   %ebx
f0102ce4:	e8 19 e4 ff ff       	call   f0101102 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102ce9:	89 f8                	mov    %edi,%eax
f0102ceb:	2b 05 9c ae 2a f0    	sub    0xf02aae9c,%eax
f0102cf1:	c1 f8 03             	sar    $0x3,%eax
f0102cf4:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102cf7:	89 c2                	mov    %eax,%edx
f0102cf9:	c1 ea 0c             	shr    $0xc,%edx
f0102cfc:	83 c4 10             	add    $0x10,%esp
f0102cff:	3b 15 94 ae 2a f0    	cmp    0xf02aae94,%edx
f0102d05:	72 12                	jb     f0102d19 <mem_init+0x17a5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d07:	50                   	push   %eax
f0102d08:	68 04 6c 10 f0       	push   $0xf0106c04
f0102d0d:	6a 58                	push   $0x58
f0102d0f:	68 cb 71 10 f0       	push   $0xf01071cb
f0102d14:	e8 27 d3 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102d19:	83 ec 04             	sub    $0x4,%esp
f0102d1c:	68 00 10 00 00       	push   $0x1000
f0102d21:	6a 01                	push   $0x1
f0102d23:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102d28:	50                   	push   %eax
f0102d29:	e8 88 2a 00 00       	call   f01057b6 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102d2e:	89 f0                	mov    %esi,%eax
f0102d30:	2b 05 9c ae 2a f0    	sub    0xf02aae9c,%eax
f0102d36:	c1 f8 03             	sar    $0x3,%eax
f0102d39:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102d3c:	89 c2                	mov    %eax,%edx
f0102d3e:	c1 ea 0c             	shr    $0xc,%edx
f0102d41:	83 c4 10             	add    $0x10,%esp
f0102d44:	3b 15 94 ae 2a f0    	cmp    0xf02aae94,%edx
f0102d4a:	72 12                	jb     f0102d5e <mem_init+0x17ea>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d4c:	50                   	push   %eax
f0102d4d:	68 04 6c 10 f0       	push   $0xf0106c04
f0102d52:	6a 58                	push   $0x58
f0102d54:	68 cb 71 10 f0       	push   $0xf01071cb
f0102d59:	e8 e2 d2 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102d5e:	83 ec 04             	sub    $0x4,%esp
f0102d61:	68 00 10 00 00       	push   $0x1000
f0102d66:	6a 02                	push   $0x2
f0102d68:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102d6d:	50                   	push   %eax
f0102d6e:	e8 43 2a 00 00       	call   f01057b6 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102d73:	6a 02                	push   $0x2
f0102d75:	68 00 10 00 00       	push   $0x1000
f0102d7a:	57                   	push   %edi
f0102d7b:	ff 35 98 ae 2a f0    	pushl  0xf02aae98
f0102d81:	e8 fe e6 ff ff       	call   f0101484 <page_insert>
	assert(pp1->pp_ref == 1);
f0102d86:	83 c4 20             	add    $0x20,%esp
f0102d89:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102d8e:	74 19                	je     f0102da9 <mem_init+0x1835>
f0102d90:	68 04 74 10 f0       	push   $0xf0107404
f0102d95:	68 e5 71 10 f0       	push   $0xf01071e5
f0102d9a:	68 0f 05 00 00       	push   $0x50f
f0102d9f:	68 bf 71 10 f0       	push   $0xf01071bf
f0102da4:	e8 97 d2 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102da9:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102db0:	01 01 01 
f0102db3:	74 19                	je     f0102dce <mem_init+0x185a>
f0102db5:	68 bc 7e 10 f0       	push   $0xf0107ebc
f0102dba:	68 e5 71 10 f0       	push   $0xf01071e5
f0102dbf:	68 10 05 00 00       	push   $0x510
f0102dc4:	68 bf 71 10 f0       	push   $0xf01071bf
f0102dc9:	e8 72 d2 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102dce:	6a 02                	push   $0x2
f0102dd0:	68 00 10 00 00       	push   $0x1000
f0102dd5:	56                   	push   %esi
f0102dd6:	ff 35 98 ae 2a f0    	pushl  0xf02aae98
f0102ddc:	e8 a3 e6 ff ff       	call   f0101484 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102de1:	83 c4 10             	add    $0x10,%esp
f0102de4:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102deb:	02 02 02 
f0102dee:	74 19                	je     f0102e09 <mem_init+0x1895>
f0102df0:	68 e0 7e 10 f0       	push   $0xf0107ee0
f0102df5:	68 e5 71 10 f0       	push   $0xf01071e5
f0102dfa:	68 12 05 00 00       	push   $0x512
f0102dff:	68 bf 71 10 f0       	push   $0xf01071bf
f0102e04:	e8 37 d2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102e09:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102e0e:	74 19                	je     f0102e29 <mem_init+0x18b5>
f0102e10:	68 26 74 10 f0       	push   $0xf0107426
f0102e15:	68 e5 71 10 f0       	push   $0xf01071e5
f0102e1a:	68 13 05 00 00       	push   $0x513
f0102e1f:	68 bf 71 10 f0       	push   $0xf01071bf
f0102e24:	e8 17 d2 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102e29:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102e2e:	74 19                	je     f0102e49 <mem_init+0x18d5>
f0102e30:	68 90 74 10 f0       	push   $0xf0107490
f0102e35:	68 e5 71 10 f0       	push   $0xf01071e5
f0102e3a:	68 14 05 00 00       	push   $0x514
f0102e3f:	68 bf 71 10 f0       	push   $0xf01071bf
f0102e44:	e8 f7 d1 ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102e49:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102e50:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102e53:	89 f0                	mov    %esi,%eax
f0102e55:	2b 05 9c ae 2a f0    	sub    0xf02aae9c,%eax
f0102e5b:	c1 f8 03             	sar    $0x3,%eax
f0102e5e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102e61:	89 c2                	mov    %eax,%edx
f0102e63:	c1 ea 0c             	shr    $0xc,%edx
f0102e66:	3b 15 94 ae 2a f0    	cmp    0xf02aae94,%edx
f0102e6c:	72 12                	jb     f0102e80 <mem_init+0x190c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102e6e:	50                   	push   %eax
f0102e6f:	68 04 6c 10 f0       	push   $0xf0106c04
f0102e74:	6a 58                	push   $0x58
f0102e76:	68 cb 71 10 f0       	push   $0xf01071cb
f0102e7b:	e8 c0 d1 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102e80:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102e87:	03 03 03 
f0102e8a:	74 19                	je     f0102ea5 <mem_init+0x1931>
f0102e8c:	68 04 7f 10 f0       	push   $0xf0107f04
f0102e91:	68 e5 71 10 f0       	push   $0xf01071e5
f0102e96:	68 16 05 00 00       	push   $0x516
f0102e9b:	68 bf 71 10 f0       	push   $0xf01071bf
f0102ea0:	e8 9b d1 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102ea5:	83 ec 08             	sub    $0x8,%esp
f0102ea8:	68 00 10 00 00       	push   $0x1000
f0102ead:	ff 35 98 ae 2a f0    	pushl  0xf02aae98
f0102eb3:	e8 7f e5 ff ff       	call   f0101437 <page_remove>
	assert(pp2->pp_ref == 0);
f0102eb8:	83 c4 10             	add    $0x10,%esp
f0102ebb:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102ec0:	74 19                	je     f0102edb <mem_init+0x1967>
f0102ec2:	68 5e 74 10 f0       	push   $0xf010745e
f0102ec7:	68 e5 71 10 f0       	push   $0xf01071e5
f0102ecc:	68 18 05 00 00       	push   $0x518
f0102ed1:	68 bf 71 10 f0       	push   $0xf01071bf
f0102ed6:	e8 65 d1 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102edb:	8b 0d 98 ae 2a f0    	mov    0xf02aae98,%ecx
f0102ee1:	8b 11                	mov    (%ecx),%edx
f0102ee3:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102ee9:	89 d8                	mov    %ebx,%eax
f0102eeb:	2b 05 9c ae 2a f0    	sub    0xf02aae9c,%eax
f0102ef1:	c1 f8 03             	sar    $0x3,%eax
f0102ef4:	c1 e0 0c             	shl    $0xc,%eax
f0102ef7:	39 c2                	cmp    %eax,%edx
f0102ef9:	74 19                	je     f0102f14 <mem_init+0x19a0>
f0102efb:	68 8c 78 10 f0       	push   $0xf010788c
f0102f00:	68 e5 71 10 f0       	push   $0xf01071e5
f0102f05:	68 1b 05 00 00       	push   $0x51b
f0102f0a:	68 bf 71 10 f0       	push   $0xf01071bf
f0102f0f:	e8 2c d1 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102f14:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102f1a:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102f1f:	74 19                	je     f0102f3a <mem_init+0x19c6>
f0102f21:	68 15 74 10 f0       	push   $0xf0107415
f0102f26:	68 e5 71 10 f0       	push   $0xf01071e5
f0102f2b:	68 1d 05 00 00       	push   $0x51d
f0102f30:	68 bf 71 10 f0       	push   $0xf01071bf
f0102f35:	e8 06 d1 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102f3a:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102f40:	83 ec 0c             	sub    $0xc,%esp
f0102f43:	53                   	push   %ebx
f0102f44:	e8 b9 e1 ff ff       	call   f0101102 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102f49:	c7 04 24 30 7f 10 f0 	movl   $0xf0107f30,(%esp)
f0102f50:	e8 2d 0a 00 00       	call   f0103982 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102f55:	83 c4 10             	add    $0x10,%esp
f0102f58:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f5b:	5b                   	pop    %ebx
f0102f5c:	5e                   	pop    %esi
f0102f5d:	5f                   	pop    %edi
f0102f5e:	5d                   	pop    %ebp
f0102f5f:	c3                   	ret    

f0102f60 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102f60:	55                   	push   %ebp
f0102f61:	89 e5                	mov    %esp,%ebp
f0102f63:	57                   	push   %edi
f0102f64:	56                   	push   %esi
f0102f65:	53                   	push   %ebx
f0102f66:	83 ec 1c             	sub    $0x1c,%esp
f0102f69:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102f6c:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 3: Your code here.

	pte_t* pte;

	// for every page in this region
	for (void* i=ROUNDDOWN((void *)va, PGSIZE); i<ROUNDUP((void *)(va+len), PGSIZE); i+=PGSIZE) {
f0102f6f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f72:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102f77:	89 c3                	mov    %eax,%ebx
f0102f79:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0102f7c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f7f:	03 45 10             	add    0x10(%ebp),%eax
f0102f82:	05 ff 0f 00 00       	add    $0xfff,%eax
f0102f87:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102f8c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102f8f:	e9 9e 00 00 00       	jmp    f0103032 <user_mem_check+0xd2>

		if ((uintptr_t)i >= ULIM) {
f0102f94:	89 5d e0             	mov    %ebx,-0x20(%ebp)
f0102f97:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102f9d:	76 18                	jbe    f0102fb7 <user_mem_check+0x57>
			user_mem_check_addr = (i == ROUNDDOWN((void *)va, PGSIZE))? (uintptr_t)va:(uintptr_t)i;
f0102f9f:	3b 5d dc             	cmp    -0x24(%ebp),%ebx
f0102fa2:	89 d8                	mov    %ebx,%eax
f0102fa4:	0f 44 45 0c          	cmove  0xc(%ebp),%eax
f0102fa8:	a3 3c a2 2a f0       	mov    %eax,0xf02aa23c
			return -E_FAULT;
f0102fad:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102fb2:	e9 89 00 00 00       	jmp    f0103040 <user_mem_check+0xe0>
		}

		//  get this page
		pte = pgdir_walk(env->env_pgdir, i, 0);
f0102fb7:	83 ec 04             	sub    $0x4,%esp
f0102fba:	6a 00                	push   $0x0
f0102fbc:	53                   	push   %ebx
f0102fbd:	ff 77 60             	pushl  0x60(%edi)
f0102fc0:	e8 ba e1 ff ff       	call   f010117f <pgdir_walk>

		if (pte == NULL || (uint32_t)(*pte) == 0) {
f0102fc5:	83 c4 10             	add    $0x10,%esp
f0102fc8:	85 c0                	test   %eax,%eax
f0102fca:	74 06                	je     f0102fd2 <user_mem_check+0x72>
f0102fcc:	8b 10                	mov    (%eax),%edx
f0102fce:	85 d2                	test   %edx,%edx
f0102fd0:	75 2b                	jne    f0102ffd <user_mem_check+0x9d>
			user_mem_check_addr = (i == ROUNDDOWN((void *)va, PGSIZE))? (uintptr_t)va:(uintptr_t)i;
f0102fd2:	3b 5d dc             	cmp    -0x24(%ebp),%ebx
f0102fd5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0102fd8:	0f 44 4d 0c          	cmove  0xc(%ebp),%ecx
f0102fdc:	89 0d 3c a2 2a f0    	mov    %ecx,0xf02aa23c
			cprintf("[-] page [0x%x] error, %d, %d\n", (uint32_t)(*pte), ((uint32_t)(*pte) & perm), perm);
f0102fe2:	8b 00                	mov    (%eax),%eax
f0102fe4:	56                   	push   %esi
f0102fe5:	21 c6                	and    %eax,%esi
f0102fe7:	56                   	push   %esi
f0102fe8:	50                   	push   %eax
f0102fe9:	68 5c 7f 10 f0       	push   $0xf0107f5c
f0102fee:	e8 8f 09 00 00       	call   f0103982 <cprintf>
			return -E_FAULT;
f0102ff3:	83 c4 10             	add    $0x10,%esp
f0102ff6:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102ffb:	eb 43                	jmp    f0103040 <user_mem_check+0xe0>
		}

		// perm wrong
		if (((uint32_t)(*pte) & perm) != perm) {
f0102ffd:	89 d0                	mov    %edx,%eax
f0102fff:	21 f0                	and    %esi,%eax
f0103001:	39 c6                	cmp    %eax,%esi
f0103003:	74 27                	je     f010302c <user_mem_check+0xcc>
			// if happens at first page, we return va instead of ROUNDDOWN(va, PGSIZE)
			// just to make it more precise 
			user_mem_check_addr = (i == ROUNDDOWN((void *)va, PGSIZE))? (uintptr_t)va:(uintptr_t)i;
f0103005:	3b 5d dc             	cmp    -0x24(%ebp),%ebx
f0103008:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010300b:	0f 44 4d 0c          	cmove  0xc(%ebp),%ecx
f010300f:	89 0d 3c a2 2a f0    	mov    %ecx,0xf02aa23c
			cprintf("[-] page [0x%x] perf error, %d, %d\n", (uint32_t)(*pte), ((uint32_t)(*pte) & perm), perm);
f0103015:	56                   	push   %esi
f0103016:	50                   	push   %eax
f0103017:	52                   	push   %edx
f0103018:	68 7c 7f 10 f0       	push   $0xf0107f7c
f010301d:	e8 60 09 00 00       	call   f0103982 <cprintf>
			return -E_FAULT;
f0103022:	83 c4 10             	add    $0x10,%esp
f0103025:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010302a:	eb 14                	jmp    f0103040 <user_mem_check+0xe0>
	// LAB 3: Your code here.

	pte_t* pte;

	// for every page in this region
	for (void* i=ROUNDDOWN((void *)va, PGSIZE); i<ROUNDUP((void *)(va+len), PGSIZE); i+=PGSIZE) {
f010302c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103032:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0103035:	0f 82 59 ff ff ff    	jb     f0102f94 <user_mem_check+0x34>
			return -E_FAULT;
		}

	}

	return 0;
f010303b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103040:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103043:	5b                   	pop    %ebx
f0103044:	5e                   	pop    %esi
f0103045:	5f                   	pop    %edi
f0103046:	5d                   	pop    %ebp
f0103047:	c3                   	ret    

f0103048 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0103048:	55                   	push   %ebp
f0103049:	89 e5                	mov    %esp,%ebp
f010304b:	53                   	push   %ebx
f010304c:	83 ec 04             	sub    $0x4,%esp
f010304f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0103052:	8b 45 14             	mov    0x14(%ebp),%eax
f0103055:	83 c8 04             	or     $0x4,%eax
f0103058:	50                   	push   %eax
f0103059:	ff 75 10             	pushl  0x10(%ebp)
f010305c:	ff 75 0c             	pushl  0xc(%ebp)
f010305f:	53                   	push   %ebx
f0103060:	e8 fb fe ff ff       	call   f0102f60 <user_mem_check>
f0103065:	83 c4 10             	add    $0x10,%esp
f0103068:	85 c0                	test   %eax,%eax
f010306a:	79 21                	jns    f010308d <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f010306c:	83 ec 04             	sub    $0x4,%esp
f010306f:	ff 35 3c a2 2a f0    	pushl  0xf02aa23c
f0103075:	ff 73 48             	pushl  0x48(%ebx)
f0103078:	68 a0 7f 10 f0       	push   $0xf0107fa0
f010307d:	e8 00 09 00 00       	call   f0103982 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0103082:	89 1c 24             	mov    %ebx,(%esp)
f0103085:	e8 e1 05 00 00       	call   f010366b <env_destroy>
f010308a:	83 c4 10             	add    $0x10,%esp
	}
}
f010308d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103090:	c9                   	leave  
f0103091:	c3                   	ret    

f0103092 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0103092:	55                   	push   %ebp
f0103093:	89 e5                	mov    %esp,%ebp
f0103095:	57                   	push   %edi
f0103096:	56                   	push   %esi
f0103097:	53                   	push   %ebx
f0103098:	83 ec 0c             	sub    $0xc,%esp
f010309b:	89 c7                	mov    %eax,%edi
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)

	for (void* i=ROUNDDOWN(va, PGSIZE); i<ROUNDUP(va+len, PGSIZE); i += PGSIZE) {
f010309d:	89 d3                	mov    %edx,%ebx
f010309f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f01030a5:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f01030ac:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
f01030b2:	eb 56                	jmp    f010310a <region_alloc+0x78>

		struct PageInfo* pp = page_alloc(ALLOC_ZERO);
f01030b4:	83 ec 0c             	sub    $0xc,%esp
f01030b7:	6a 01                	push   $0x1
f01030b9:	e8 d3 df ff ff       	call   f0101091 <page_alloc>
		if (pp == 0) {
f01030be:	83 c4 10             	add    $0x10,%esp
f01030c1:	85 c0                	test   %eax,%eax
f01030c3:	75 17                	jne    f01030dc <region_alloc+0x4a>
			panic("region_alloc: page_alloc return 0");
f01030c5:	83 ec 04             	sub    $0x4,%esp
f01030c8:	68 d8 7f 10 f0       	push   $0xf0107fd8
f01030cd:	68 2d 01 00 00       	push   $0x12d
f01030d2:	68 9c 80 10 f0       	push   $0xf010809c
f01030d7:	e8 64 cf ff ff       	call   f0100040 <_panic>
		}

		int err = page_insert(e->env_pgdir, pp, i, PTE_U | PTE_W);
f01030dc:	6a 06                	push   $0x6
f01030de:	53                   	push   %ebx
f01030df:	50                   	push   %eax
f01030e0:	ff 77 60             	pushl  0x60(%edi)
f01030e3:	e8 9c e3 ff ff       	call   f0101484 <page_insert>
		if (err < 0) {
f01030e8:	83 c4 10             	add    $0x10,%esp
f01030eb:	85 c0                	test   %eax,%eax
f01030ed:	79 15                	jns    f0103104 <region_alloc+0x72>
			panic("region_alloc: page_insert failed: %e", err);
f01030ef:	50                   	push   %eax
f01030f0:	68 fc 7f 10 f0       	push   $0xf0107ffc
f01030f5:	68 32 01 00 00       	push   $0x132
f01030fa:	68 9c 80 10 f0       	push   $0xf010809c
f01030ff:	e8 3c cf ff ff       	call   f0100040 <_panic>
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)

	for (void* i=ROUNDDOWN(va, PGSIZE); i<ROUNDUP(va+len, PGSIZE); i += PGSIZE) {
f0103104:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010310a:	39 f3                	cmp    %esi,%ebx
f010310c:	72 a6                	jb     f01030b4 <region_alloc+0x22>
		}

	}

	
}
f010310e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103111:	5b                   	pop    %ebx
f0103112:	5e                   	pop    %esi
f0103113:	5f                   	pop    %edi
f0103114:	5d                   	pop    %ebp
f0103115:	c3                   	ret    

f0103116 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0103116:	55                   	push   %ebp
f0103117:	89 e5                	mov    %esp,%ebp
f0103119:	56                   	push   %esi
f010311a:	53                   	push   %ebx
f010311b:	8b 45 08             	mov    0x8(%ebp),%eax
f010311e:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103121:	85 c0                	test   %eax,%eax
f0103123:	75 1a                	jne    f010313f <envid2env+0x29>
		*env_store = curenv;
f0103125:	e8 ac 2c 00 00       	call   f0105dd6 <cpunum>
f010312a:	6b c0 74             	imul   $0x74,%eax,%eax
f010312d:	8b 80 28 b0 2a f0    	mov    -0xfd54fd8(%eax),%eax
f0103133:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103136:	89 01                	mov    %eax,(%ecx)
		return 0;
f0103138:	b8 00 00 00 00       	mov    $0x0,%eax
f010313d:	eb 70                	jmp    f01031af <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f010313f:	89 c3                	mov    %eax,%ebx
f0103141:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0103147:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f010314a:	03 1d 48 a2 2a f0    	add    0xf02aa248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103150:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103154:	74 05                	je     f010315b <envid2env+0x45>
f0103156:	3b 43 48             	cmp    0x48(%ebx),%eax
f0103159:	74 10                	je     f010316b <envid2env+0x55>
		*env_store = 0;
f010315b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010315e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103164:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103169:	eb 44                	jmp    f01031af <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f010316b:	84 d2                	test   %dl,%dl
f010316d:	74 36                	je     f01031a5 <envid2env+0x8f>
f010316f:	e8 62 2c 00 00       	call   f0105dd6 <cpunum>
f0103174:	6b c0 74             	imul   $0x74,%eax,%eax
f0103177:	3b 98 28 b0 2a f0    	cmp    -0xfd54fd8(%eax),%ebx
f010317d:	74 26                	je     f01031a5 <envid2env+0x8f>
f010317f:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0103182:	e8 4f 2c 00 00       	call   f0105dd6 <cpunum>
f0103187:	6b c0 74             	imul   $0x74,%eax,%eax
f010318a:	8b 80 28 b0 2a f0    	mov    -0xfd54fd8(%eax),%eax
f0103190:	3b 70 48             	cmp    0x48(%eax),%esi
f0103193:	74 10                	je     f01031a5 <envid2env+0x8f>
		*env_store = 0;
f0103195:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103198:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010319e:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01031a3:	eb 0a                	jmp    f01031af <envid2env+0x99>
	}

	*env_store = e;
f01031a5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01031a8:	89 18                	mov    %ebx,(%eax)
	return 0;
f01031aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01031af:	5b                   	pop    %ebx
f01031b0:	5e                   	pop    %esi
f01031b1:	5d                   	pop    %ebp
f01031b2:	c3                   	ret    

f01031b3 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f01031b3:	55                   	push   %ebp
f01031b4:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f01031b6:	b8 20 33 12 f0       	mov    $0xf0123320,%eax
f01031bb:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f01031be:	b8 23 00 00 00       	mov    $0x23,%eax
f01031c3:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f01031c5:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f01031c7:	b8 10 00 00 00       	mov    $0x10,%eax
f01031cc:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f01031ce:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f01031d0:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f01031d2:	ea d9 31 10 f0 08 00 	ljmp   $0x8,$0xf01031d9
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f01031d9:	b8 00 00 00 00       	mov    $0x0,%eax
f01031de:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f01031e1:	5d                   	pop    %ebp
f01031e2:	c3                   	ret    

f01031e3 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f01031e3:	55                   	push   %ebp
f01031e4:	89 e5                	mov    %esp,%ebp
f01031e6:	56                   	push   %esi
f01031e7:	53                   	push   %ebx
	// LAB 3: Your code here.

	// make sure env_free_list point to envs[0]
	// so that the first env_alloc() will return envs[0]
	for (int i=NENV-1; i>=0; i--) {
		envs[i].env_id = 0;
f01031e8:	8b 35 48 a2 2a f0    	mov    0xf02aa248,%esi
f01031ee:	8b 15 4c a2 2a f0    	mov    0xf02aa24c,%edx
f01031f4:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f01031fa:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f01031fd:	89 c1                	mov    %eax,%ecx
f01031ff:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0103206:	89 50 44             	mov    %edx,0x44(%eax)
f0103209:	83 e8 7c             	sub    $0x7c,%eax
		env_free_list = &envs[i];
f010320c:	89 ca                	mov    %ecx,%edx
	// Set up envs array
	// LAB 3: Your code here.

	// make sure env_free_list point to envs[0]
	// so that the first env_alloc() will return envs[0]
	for (int i=NENV-1; i>=0; i--) {
f010320e:	39 d8                	cmp    %ebx,%eax
f0103210:	75 eb                	jne    f01031fd <env_init+0x1a>
f0103212:	89 35 4c a2 2a f0    	mov    %esi,0xf02aa24c
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
	}

	// Per-CPU part of the initialization
	env_init_percpu();
f0103218:	e8 96 ff ff ff       	call   f01031b3 <env_init_percpu>
}
f010321d:	5b                   	pop    %ebx
f010321e:	5e                   	pop    %esi
f010321f:	5d                   	pop    %ebp
f0103220:	c3                   	ret    

f0103221 <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103221:	55                   	push   %ebp
f0103222:	89 e5                	mov    %esp,%ebp
f0103224:	56                   	push   %esi
f0103225:	53                   	push   %ebx
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0103226:	8b 1d 4c a2 2a f0    	mov    0xf02aa24c,%ebx
f010322c:	85 db                	test   %ebx,%ebx
f010322e:	0f 84 2f 01 00 00    	je     f0103363 <env_alloc+0x142>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103234:	83 ec 0c             	sub    $0xc,%esp
f0103237:	6a 01                	push   $0x1
f0103239:	e8 53 de ff ff       	call   f0101091 <page_alloc>
f010323e:	89 c6                	mov    %eax,%esi
f0103240:	83 c4 10             	add    $0x10,%esp
f0103243:	85 c0                	test   %eax,%eax
f0103245:	0f 84 1f 01 00 00    	je     f010336a <env_alloc+0x149>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010324b:	2b 05 9c ae 2a f0    	sub    0xf02aae9c,%eax
f0103251:	c1 f8 03             	sar    $0x3,%eax
f0103254:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103257:	89 c2                	mov    %eax,%edx
f0103259:	c1 ea 0c             	shr    $0xc,%edx
f010325c:	3b 15 94 ae 2a f0    	cmp    0xf02aae94,%edx
f0103262:	72 12                	jb     f0103276 <env_alloc+0x55>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103264:	50                   	push   %eax
f0103265:	68 04 6c 10 f0       	push   $0xf0106c04
f010326a:	6a 58                	push   $0x58
f010326c:	68 cb 71 10 f0       	push   $0xf01071cb
f0103271:	e8 ca cd ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0103276:	2d 00 00 00 10       	sub    $0x10000000,%eax
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.

	e->env_pgdir = page2kva(p);
f010327b:	89 43 60             	mov    %eax,0x60(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f010327e:	83 ec 04             	sub    $0x4,%esp
f0103281:	68 00 10 00 00       	push   $0x1000
f0103286:	ff 35 98 ae 2a f0    	pushl  0xf02aae98
f010328c:	50                   	push   %eax
f010328d:	e8 d9 25 00 00       	call   f010586b <memcpy>
	p->pp_ref++;
f0103292:	66 83 46 04 01       	addw   $0x1,0x4(%esi)

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103297:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010329a:	83 c4 10             	add    $0x10,%esp
f010329d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01032a2:	77 15                	ja     f01032b9 <env_alloc+0x98>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032a4:	50                   	push   %eax
f01032a5:	68 28 6c 10 f0       	push   $0xf0106c28
f01032aa:	68 c8 00 00 00       	push   $0xc8
f01032af:	68 9c 80 10 f0       	push   $0xf010809c
f01032b4:	e8 87 cd ff ff       	call   f0100040 <_panic>
f01032b9:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01032bf:	83 ca 05             	or     $0x5,%edx
f01032c2:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01032c8:	8b 43 48             	mov    0x48(%ebx),%eax
f01032cb:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01032d0:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f01032d5:	ba 00 10 00 00       	mov    $0x1000,%edx
f01032da:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f01032dd:	89 da                	mov    %ebx,%edx
f01032df:	2b 15 48 a2 2a f0    	sub    0xf02aa248,%edx
f01032e5:	c1 fa 02             	sar    $0x2,%edx
f01032e8:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f01032ee:	09 d0                	or     %edx,%eax
f01032f0:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f01032f3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01032f6:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f01032f9:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103300:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103307:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010330e:	83 ec 04             	sub    $0x4,%esp
f0103311:	6a 44                	push   $0x44
f0103313:	6a 00                	push   $0x0
f0103315:	53                   	push   %ebx
f0103316:	e8 9b 24 00 00       	call   f01057b6 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f010331b:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103321:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103327:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f010332d:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103334:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.

	e->env_tf.tf_eflags |= FL_IF;
f010333a:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103341:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103348:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f010334c:	8b 43 44             	mov    0x44(%ebx),%eax
f010334f:	a3 4c a2 2a f0       	mov    %eax,0xf02aa24c
	*newenv_store = e;
f0103354:	8b 45 08             	mov    0x8(%ebp),%eax
f0103357:	89 18                	mov    %ebx,(%eax)

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
f0103359:	83 c4 10             	add    $0x10,%esp
f010335c:	b8 00 00 00 00       	mov    $0x0,%eax
f0103361:	eb 0c                	jmp    f010336f <env_alloc+0x14e>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103363:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103368:	eb 05                	jmp    f010336f <env_alloc+0x14e>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f010336a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f010336f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103372:	5b                   	pop    %ebx
f0103373:	5e                   	pop    %esi
f0103374:	5d                   	pop    %ebp
f0103375:	c3                   	ret    

f0103376 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103376:	55                   	push   %ebp
f0103377:	89 e5                	mov    %esp,%ebp
f0103379:	57                   	push   %edi
f010337a:	56                   	push   %esi
f010337b:	53                   	push   %ebx
f010337c:	83 ec 34             	sub    $0x34,%esp
f010337f:	8b 7d 08             	mov    0x8(%ebp),%edi
	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.

	struct Env *newenv_store;
	envid_t parent_id = 0;
	int err = env_alloc(&newenv_store, 0);
f0103382:	6a 00                	push   $0x0
f0103384:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103387:	50                   	push   %eax
f0103388:	e8 94 fe ff ff       	call   f0103221 <env_alloc>
	if (err < 0) 
f010338d:	83 c4 10             	add    $0x10,%esp
f0103390:	85 c0                	test   %eax,%eax
f0103392:	79 15                	jns    f01033a9 <env_create+0x33>
		panic("env_create: env_alloc failed: %e", err);
f0103394:	50                   	push   %eax
f0103395:	68 24 80 10 f0       	push   $0xf0108024
f010339a:	68 bc 01 00 00       	push   $0x1bc
f010339f:	68 9c 80 10 f0       	push   $0xf010809c
f01033a4:	e8 97 cc ff ff       	call   f0100040 <_panic>
	load_icode(newenv_store, binary);
f01033a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01033ac:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// LAB 3: Your code here.

	// read and check ELF property, inspired by boot/main.c
	struct Elf* elf = (struct Elf*) binary;

	if (elf->e_magic != ELF_MAGIC)
f01033af:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f01033b5:	74 17                	je     f01033ce <env_create+0x58>
		panic("load_icode: not a valid ELF format file");
f01033b7:	83 ec 04             	sub    $0x4,%esp
f01033ba:	68 48 80 10 f0       	push   $0xf0108048
f01033bf:	68 75 01 00 00       	push   $0x175
f01033c4:	68 9c 80 10 f0       	push   $0xf010809c
f01033c9:	e8 72 cc ff ff       	call   f0100040 <_panic>

	struct Proghdr *ph, *eph;
	
	ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f01033ce:	89 fb                	mov    %edi,%ebx
f01033d0:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + elf->e_phnum;
f01033d3:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f01033d7:	c1 e6 05             	shl    $0x5,%esi
f01033da:	01 de                	add    %ebx,%esi

	// we are setting user virtual address, but now we are in kernel mode
	// load env pgdir to cr3
	lcr3(PADDR(e->env_pgdir));	
f01033dc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01033df:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01033e2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01033e7:	77 15                	ja     f01033fe <env_create+0x88>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033e9:	50                   	push   %eax
f01033ea:	68 28 6c 10 f0       	push   $0xf0106c28
f01033ef:	68 7e 01 00 00       	push   $0x17e
f01033f4:	68 9c 80 10 f0       	push   $0xf010809c
f01033f9:	e8 42 cc ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01033fe:	05 00 00 00 10       	add    $0x10000000,%eax
f0103403:	0f 22 d8             	mov    %eax,%cr3
f0103406:	eb 59                	jmp    f0103461 <env_create+0xeb>

	// for every segment
	for (; ph < eph; ph++) {

		// only load this type of segment
		if (ph->p_type == ELF_PROG_LOAD) {
f0103408:	83 3b 01             	cmpl   $0x1,(%ebx)
f010340b:	75 51                	jne    f010345e <env_create+0xe8>

			if (ph->p_filesz > ph->p_memsz)
f010340d:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103410:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f0103413:	76 17                	jbe    f010342c <env_create+0xb6>
				panic("load_icode: not a valid ELF format file (2)");
f0103415:	83 ec 04             	sub    $0x4,%esp
f0103418:	68 70 80 10 f0       	push   $0xf0108070
f010341d:	68 87 01 00 00       	push   $0x187
f0103422:	68 9c 80 10 f0       	push   $0xf010809c
f0103427:	e8 14 cc ff ff       	call   f0100040 <_panic>

			// allocate and map each segment
			// this function needs e->env_pgdir
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f010342c:	8b 53 08             	mov    0x8(%ebx),%edx
f010342f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103432:	e8 5b fc ff ff       	call   f0103092 <region_alloc>

			// all clear to 0
			memset((void *)ph->p_va, 0, ph->p_memsz);
f0103437:	83 ec 04             	sub    $0x4,%esp
f010343a:	ff 73 14             	pushl  0x14(%ebx)
f010343d:	6a 00                	push   $0x0
f010343f:	ff 73 08             	pushl  0x8(%ebx)
f0103442:	e8 6f 23 00 00       	call   f01057b6 <memset>

			// copy [binary + ph->p_offset, binary + ph->p_offset + ph->p_filesz) to ph->p_va
			// binary is of type uint8_t *, remember not use elf cuz its type is struct Elf*
			// making elf + ph->p_offset pointing to nowhere
			memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f0103447:	83 c4 0c             	add    $0xc,%esp
f010344a:	ff 73 10             	pushl  0x10(%ebx)
f010344d:	89 f8                	mov    %edi,%eax
f010344f:	03 43 04             	add    0x4(%ebx),%eax
f0103452:	50                   	push   %eax
f0103453:	ff 73 08             	pushl  0x8(%ebx)
f0103456:	e8 10 24 00 00       	call   f010586b <memcpy>
f010345b:	83 c4 10             	add    $0x10,%esp
	// we are setting user virtual address, but now we are in kernel mode
	// load env pgdir to cr3
	lcr3(PADDR(e->env_pgdir));	

	// for every segment
	for (; ph < eph; ph++) {
f010345e:	83 c3 20             	add    $0x20,%ebx
f0103461:	39 de                	cmp    %ebx,%esi
f0103463:	77 a3                	ja     f0103408 <env_create+0x92>
		}

	}

	// load program entry point to eip
	e->env_tf.tf_eip = elf->e_entry;
f0103465:	8b 47 18             	mov    0x18(%edi),%eax
f0103468:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010346b:	89 47 30             	mov    %eax,0x30(%edi)
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.

	region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f010346e:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103473:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103478:	89 f8                	mov    %edi,%eax
f010347a:	e8 13 fc ff ff       	call   f0103092 <region_alloc>

	// after loading things from elf, restore cr3 in kernel
	lcr3(PADDR(kern_pgdir));
f010347f:	a1 98 ae 2a f0       	mov    0xf02aae98,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103484:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103489:	77 15                	ja     f01034a0 <env_create+0x12a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010348b:	50                   	push   %eax
f010348c:	68 28 6c 10 f0       	push   $0xf0106c28
f0103491:	68 a5 01 00 00       	push   $0x1a5
f0103496:	68 9c 80 10 f0       	push   $0xf010809c
f010349b:	e8 a0 cb ff ff       	call   f0100040 <_panic>
f01034a0:	05 00 00 00 10       	add    $0x10000000,%eax
f01034a5:	0f 22 d8             	mov    %eax,%cr3
	envid_t parent_id = 0;
	int err = env_alloc(&newenv_store, 0);
	if (err < 0) 
		panic("env_create: env_alloc failed: %e", err);
	load_icode(newenv_store, binary);
	newenv_store->env_type = type;
f01034a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01034ab:	8b 55 0c             	mov    0xc(%ebp),%edx
f01034ae:	89 50 50             	mov    %edx,0x50(%eax)

	if (type == ENV_TYPE_FS) {
f01034b1:	83 fa 01             	cmp    $0x1,%edx
f01034b4:	75 07                	jne    f01034bd <env_create+0x147>
        newenv_store->env_tf.tf_eflags |= FL_IOPL_MASK;
f01034b6:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
    }

}
f01034bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01034c0:	5b                   	pop    %ebx
f01034c1:	5e                   	pop    %esi
f01034c2:	5f                   	pop    %edi
f01034c3:	5d                   	pop    %ebp
f01034c4:	c3                   	ret    

f01034c5 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01034c5:	55                   	push   %ebp
f01034c6:	89 e5                	mov    %esp,%ebp
f01034c8:	57                   	push   %edi
f01034c9:	56                   	push   %esi
f01034ca:	53                   	push   %ebx
f01034cb:	83 ec 1c             	sub    $0x1c,%esp
f01034ce:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01034d1:	e8 00 29 00 00       	call   f0105dd6 <cpunum>
f01034d6:	6b c0 74             	imul   $0x74,%eax,%eax
f01034d9:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01034e0:	39 b8 28 b0 2a f0    	cmp    %edi,-0xfd54fd8(%eax)
f01034e6:	75 30                	jne    f0103518 <env_free+0x53>
		lcr3(PADDR(kern_pgdir));
f01034e8:	a1 98 ae 2a f0       	mov    0xf02aae98,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01034ed:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01034f2:	77 15                	ja     f0103509 <env_free+0x44>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01034f4:	50                   	push   %eax
f01034f5:	68 28 6c 10 f0       	push   $0xf0106c28
f01034fa:	68 d4 01 00 00       	push   $0x1d4
f01034ff:	68 9c 80 10 f0       	push   $0xf010809c
f0103504:	e8 37 cb ff ff       	call   f0100040 <_panic>
f0103509:	05 00 00 00 10       	add    $0x10000000,%eax
f010350e:	0f 22 d8             	mov    %eax,%cr3
f0103511:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103518:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010351b:	89 d0                	mov    %edx,%eax
f010351d:	c1 e0 02             	shl    $0x2,%eax
f0103520:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103523:	8b 47 60             	mov    0x60(%edi),%eax
f0103526:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0103529:	f7 c6 01 00 00 00    	test   $0x1,%esi
f010352f:	0f 84 a8 00 00 00    	je     f01035dd <env_free+0x118>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103535:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010353b:	89 f0                	mov    %esi,%eax
f010353d:	c1 e8 0c             	shr    $0xc,%eax
f0103540:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103543:	39 05 94 ae 2a f0    	cmp    %eax,0xf02aae94
f0103549:	77 15                	ja     f0103560 <env_free+0x9b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010354b:	56                   	push   %esi
f010354c:	68 04 6c 10 f0       	push   $0xf0106c04
f0103551:	68 e3 01 00 00       	push   $0x1e3
f0103556:	68 9c 80 10 f0       	push   $0xf010809c
f010355b:	e8 e0 ca ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103560:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103563:	c1 e0 16             	shl    $0x16,%eax
f0103566:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103569:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f010356e:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103575:	01 
f0103576:	74 17                	je     f010358f <env_free+0xca>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103578:	83 ec 08             	sub    $0x8,%esp
f010357b:	89 d8                	mov    %ebx,%eax
f010357d:	c1 e0 0c             	shl    $0xc,%eax
f0103580:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103583:	50                   	push   %eax
f0103584:	ff 77 60             	pushl  0x60(%edi)
f0103587:	e8 ab de ff ff       	call   f0101437 <page_remove>
f010358c:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010358f:	83 c3 01             	add    $0x1,%ebx
f0103592:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103598:	75 d4                	jne    f010356e <env_free+0xa9>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f010359a:	8b 47 60             	mov    0x60(%edi),%eax
f010359d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01035a0:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01035a7:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01035aa:	3b 05 94 ae 2a f0    	cmp    0xf02aae94,%eax
f01035b0:	72 14                	jb     f01035c6 <env_free+0x101>
		panic("pa2page called with invalid pa");
f01035b2:	83 ec 04             	sub    $0x4,%esp
f01035b5:	68 34 77 10 f0       	push   $0xf0107734
f01035ba:	6a 51                	push   $0x51
f01035bc:	68 cb 71 10 f0       	push   $0xf01071cb
f01035c1:	e8 7a ca ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f01035c6:	83 ec 0c             	sub    $0xc,%esp
f01035c9:	a1 9c ae 2a f0       	mov    0xf02aae9c,%eax
f01035ce:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01035d1:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f01035d4:	50                   	push   %eax
f01035d5:	e8 7e db ff ff       	call   f0101158 <page_decref>
f01035da:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01035dd:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f01035e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01035e4:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f01035e9:	0f 85 29 ff ff ff    	jne    f0103518 <env_free+0x53>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01035ef:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01035f2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01035f7:	77 15                	ja     f010360e <env_free+0x149>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01035f9:	50                   	push   %eax
f01035fa:	68 28 6c 10 f0       	push   $0xf0106c28
f01035ff:	68 f1 01 00 00       	push   $0x1f1
f0103604:	68 9c 80 10 f0       	push   $0xf010809c
f0103609:	e8 32 ca ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f010360e:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103615:	05 00 00 00 10       	add    $0x10000000,%eax
f010361a:	c1 e8 0c             	shr    $0xc,%eax
f010361d:	3b 05 94 ae 2a f0    	cmp    0xf02aae94,%eax
f0103623:	72 14                	jb     f0103639 <env_free+0x174>
		panic("pa2page called with invalid pa");
f0103625:	83 ec 04             	sub    $0x4,%esp
f0103628:	68 34 77 10 f0       	push   $0xf0107734
f010362d:	6a 51                	push   $0x51
f010362f:	68 cb 71 10 f0       	push   $0xf01071cb
f0103634:	e8 07 ca ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f0103639:	83 ec 0c             	sub    $0xc,%esp
f010363c:	8b 15 9c ae 2a f0    	mov    0xf02aae9c,%edx
f0103642:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103645:	50                   	push   %eax
f0103646:	e8 0d db ff ff       	call   f0101158 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f010364b:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103652:	a1 4c a2 2a f0       	mov    0xf02aa24c,%eax
f0103657:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f010365a:	89 3d 4c a2 2a f0    	mov    %edi,0xf02aa24c
}
f0103660:	83 c4 10             	add    $0x10,%esp
f0103663:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103666:	5b                   	pop    %ebx
f0103667:	5e                   	pop    %esi
f0103668:	5f                   	pop    %edi
f0103669:	5d                   	pop    %ebp
f010366a:	c3                   	ret    

f010366b <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f010366b:	55                   	push   %ebp
f010366c:	89 e5                	mov    %esp,%ebp
f010366e:	53                   	push   %ebx
f010366f:	83 ec 04             	sub    $0x4,%esp
f0103672:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103675:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103679:	75 19                	jne    f0103694 <env_destroy+0x29>
f010367b:	e8 56 27 00 00       	call   f0105dd6 <cpunum>
f0103680:	6b c0 74             	imul   $0x74,%eax,%eax
f0103683:	3b 98 28 b0 2a f0    	cmp    -0xfd54fd8(%eax),%ebx
f0103689:	74 09                	je     f0103694 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f010368b:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103692:	eb 33                	jmp    f01036c7 <env_destroy+0x5c>
	}

	env_free(e);
f0103694:	83 ec 0c             	sub    $0xc,%esp
f0103697:	53                   	push   %ebx
f0103698:	e8 28 fe ff ff       	call   f01034c5 <env_free>

	if (curenv == e) {
f010369d:	e8 34 27 00 00       	call   f0105dd6 <cpunum>
f01036a2:	6b c0 74             	imul   $0x74,%eax,%eax
f01036a5:	83 c4 10             	add    $0x10,%esp
f01036a8:	3b 98 28 b0 2a f0    	cmp    -0xfd54fd8(%eax),%ebx
f01036ae:	75 17                	jne    f01036c7 <env_destroy+0x5c>
		curenv = NULL;
f01036b0:	e8 21 27 00 00       	call   f0105dd6 <cpunum>
f01036b5:	6b c0 74             	imul   $0x74,%eax,%eax
f01036b8:	c7 80 28 b0 2a f0 00 	movl   $0x0,-0xfd54fd8(%eax)
f01036bf:	00 00 00 
		sched_yield();
f01036c2:	e8 0b 0f 00 00       	call   f01045d2 <sched_yield>
	}
}
f01036c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01036ca:	c9                   	leave  
f01036cb:	c3                   	ret    

f01036cc <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01036cc:	55                   	push   %ebp
f01036cd:	89 e5                	mov    %esp,%ebp
f01036cf:	53                   	push   %ebx
f01036d0:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f01036d3:	e8 fe 26 00 00       	call   f0105dd6 <cpunum>
f01036d8:	6b c0 74             	imul   $0x74,%eax,%eax
f01036db:	8b 98 28 b0 2a f0    	mov    -0xfd54fd8(%eax),%ebx
f01036e1:	e8 f0 26 00 00       	call   f0105dd6 <cpunum>
f01036e6:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f01036e9:	8b 65 08             	mov    0x8(%ebp),%esp
f01036ec:	61                   	popa   
f01036ed:	07                   	pop    %es
f01036ee:	1f                   	pop    %ds
f01036ef:	83 c4 08             	add    $0x8,%esp
f01036f2:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01036f3:	83 ec 04             	sub    $0x4,%esp
f01036f6:	68 a7 80 10 f0       	push   $0xf01080a7
f01036fb:	68 28 02 00 00       	push   $0x228
f0103700:	68 9c 80 10 f0       	push   $0xf010809c
f0103705:	e8 36 c9 ff ff       	call   f0100040 <_panic>

f010370a <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f010370a:	55                   	push   %ebp
f010370b:	89 e5                	mov    %esp,%ebp
f010370d:	53                   	push   %ebx
f010370e:	83 ec 04             	sub    $0x4,%esp
f0103711:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

	// context switch
	if (curenv != e) {
f0103714:	e8 bd 26 00 00       	call   f0105dd6 <cpunum>
f0103719:	6b c0 74             	imul   $0x74,%eax,%eax
f010371c:	39 98 28 b0 2a f0    	cmp    %ebx,-0xfd54fd8(%eax)
f0103722:	74 3a                	je     f010375e <env_run+0x54>

		if (curenv != NULL && curenv->env_status == ENV_RUNNING)
f0103724:	e8 ad 26 00 00       	call   f0105dd6 <cpunum>
f0103729:	6b c0 74             	imul   $0x74,%eax,%eax
f010372c:	83 b8 28 b0 2a f0 00 	cmpl   $0x0,-0xfd54fd8(%eax)
f0103733:	74 29                	je     f010375e <env_run+0x54>
f0103735:	e8 9c 26 00 00       	call   f0105dd6 <cpunum>
f010373a:	6b c0 74             	imul   $0x74,%eax,%eax
f010373d:	8b 80 28 b0 2a f0    	mov    -0xfd54fd8(%eax),%eax
f0103743:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103747:	75 15                	jne    f010375e <env_run+0x54>
			curenv->env_status = ENV_RUNNABLE;
f0103749:	e8 88 26 00 00       	call   f0105dd6 <cpunum>
f010374e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103751:	8b 80 28 b0 2a f0    	mov    -0xfd54fd8(%eax),%eax
f0103757:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
			
	}
	
	curenv = e;
f010375e:	e8 73 26 00 00       	call   f0105dd6 <cpunum>
f0103763:	6b c0 74             	imul   $0x74,%eax,%eax
f0103766:	89 98 28 b0 2a f0    	mov    %ebx,-0xfd54fd8(%eax)
	curenv->env_status = ENV_RUNNING;
f010376c:	e8 65 26 00 00       	call   f0105dd6 <cpunum>
f0103771:	6b c0 74             	imul   $0x74,%eax,%eax
f0103774:	8b 80 28 b0 2a f0    	mov    -0xfd54fd8(%eax),%eax
f010377a:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f0103781:	e8 50 26 00 00       	call   f0105dd6 <cpunum>
f0103786:	6b c0 74             	imul   $0x74,%eax,%eax
f0103789:	8b 80 28 b0 2a f0    	mov    -0xfd54fd8(%eax),%eax
f010378f:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3(PADDR(curenv->env_pgdir));
f0103793:	e8 3e 26 00 00       	call   f0105dd6 <cpunum>
f0103798:	6b c0 74             	imul   $0x74,%eax,%eax
f010379b:	8b 80 28 b0 2a f0    	mov    -0xfd54fd8(%eax),%eax
f01037a1:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01037a4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01037a9:	77 15                	ja     f01037c0 <env_run+0xb6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01037ab:	50                   	push   %eax
f01037ac:	68 28 6c 10 f0       	push   $0xf0106c28
f01037b1:	68 52 02 00 00       	push   $0x252
f01037b6:	68 9c 80 10 f0       	push   $0xf010809c
f01037bb:	e8 80 c8 ff ff       	call   f0100040 <_panic>
f01037c0:	05 00 00 00 10       	add    $0x10000000,%eax
f01037c5:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01037c8:	83 ec 0c             	sub    $0xc,%esp
f01037cb:	68 c0 33 12 f0       	push   $0xf01233c0
f01037d0:	e8 0c 29 00 00       	call   f01060e1 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01037d5:	f3 90                	pause  

	unlock_kernel();

	// iret to execute entry point stored in tf_eip
	// cprintf("[?] try to execute at entry point: %x\n", curenv->env_tf.tf_eip);
	env_pop_tf(&curenv->env_tf);
f01037d7:	e8 fa 25 00 00       	call   f0105dd6 <cpunum>
f01037dc:	83 c4 04             	add    $0x4,%esp
f01037df:	6b c0 74             	imul   $0x74,%eax,%eax
f01037e2:	ff b0 28 b0 2a f0    	pushl  -0xfd54fd8(%eax)
f01037e8:	e8 df fe ff ff       	call   f01036cc <env_pop_tf>

f01037ed <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01037ed:	55                   	push   %ebp
f01037ee:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01037f0:	ba 70 00 00 00       	mov    $0x70,%edx
f01037f5:	8b 45 08             	mov    0x8(%ebp),%eax
f01037f8:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01037f9:	ba 71 00 00 00       	mov    $0x71,%edx
f01037fe:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01037ff:	0f b6 c0             	movzbl %al,%eax
}
f0103802:	5d                   	pop    %ebp
f0103803:	c3                   	ret    

f0103804 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103804:	55                   	push   %ebp
f0103805:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103807:	ba 70 00 00 00       	mov    $0x70,%edx
f010380c:	8b 45 08             	mov    0x8(%ebp),%eax
f010380f:	ee                   	out    %al,(%dx)
f0103810:	ba 71 00 00 00       	mov    $0x71,%edx
f0103815:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103818:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103819:	5d                   	pop    %ebp
f010381a:	c3                   	ret    

f010381b <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f010381b:	55                   	push   %ebp
f010381c:	89 e5                	mov    %esp,%ebp
f010381e:	56                   	push   %esi
f010381f:	53                   	push   %ebx
f0103820:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103823:	66 a3 a8 33 12 f0    	mov    %ax,0xf01233a8
	if (!didinit)
f0103829:	80 3d 50 a2 2a f0 00 	cmpb   $0x0,0xf02aa250
f0103830:	74 5a                	je     f010388c <irq_setmask_8259A+0x71>
f0103832:	89 c6                	mov    %eax,%esi
f0103834:	ba 21 00 00 00       	mov    $0x21,%edx
f0103839:	ee                   	out    %al,(%dx)
f010383a:	66 c1 e8 08          	shr    $0x8,%ax
f010383e:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103843:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f0103844:	83 ec 0c             	sub    $0xc,%esp
f0103847:	68 b3 80 10 f0       	push   $0xf01080b3
f010384c:	e8 31 01 00 00       	call   f0103982 <cprintf>
f0103851:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103854:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103859:	0f b7 f6             	movzwl %si,%esi
f010385c:	f7 d6                	not    %esi
f010385e:	0f a3 de             	bt     %ebx,%esi
f0103861:	73 11                	jae    f0103874 <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f0103863:	83 ec 08             	sub    $0x8,%esp
f0103866:	53                   	push   %ebx
f0103867:	68 53 85 10 f0       	push   $0xf0108553
f010386c:	e8 11 01 00 00       	call   f0103982 <cprintf>
f0103871:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103874:	83 c3 01             	add    $0x1,%ebx
f0103877:	83 fb 10             	cmp    $0x10,%ebx
f010387a:	75 e2                	jne    f010385e <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f010387c:	83 ec 0c             	sub    $0xc,%esp
f010387f:	68 f9 74 10 f0       	push   $0xf01074f9
f0103884:	e8 f9 00 00 00       	call   f0103982 <cprintf>
f0103889:	83 c4 10             	add    $0x10,%esp
}
f010388c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010388f:	5b                   	pop    %ebx
f0103890:	5e                   	pop    %esi
f0103891:	5d                   	pop    %ebp
f0103892:	c3                   	ret    

f0103893 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f0103893:	c6 05 50 a2 2a f0 01 	movb   $0x1,0xf02aa250
f010389a:	ba 21 00 00 00       	mov    $0x21,%edx
f010389f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01038a4:	ee                   	out    %al,(%dx)
f01038a5:	ba a1 00 00 00       	mov    $0xa1,%edx
f01038aa:	ee                   	out    %al,(%dx)
f01038ab:	ba 20 00 00 00       	mov    $0x20,%edx
f01038b0:	b8 11 00 00 00       	mov    $0x11,%eax
f01038b5:	ee                   	out    %al,(%dx)
f01038b6:	ba 21 00 00 00       	mov    $0x21,%edx
f01038bb:	b8 20 00 00 00       	mov    $0x20,%eax
f01038c0:	ee                   	out    %al,(%dx)
f01038c1:	b8 04 00 00 00       	mov    $0x4,%eax
f01038c6:	ee                   	out    %al,(%dx)
f01038c7:	b8 03 00 00 00       	mov    $0x3,%eax
f01038cc:	ee                   	out    %al,(%dx)
f01038cd:	ba a0 00 00 00       	mov    $0xa0,%edx
f01038d2:	b8 11 00 00 00       	mov    $0x11,%eax
f01038d7:	ee                   	out    %al,(%dx)
f01038d8:	ba a1 00 00 00       	mov    $0xa1,%edx
f01038dd:	b8 28 00 00 00       	mov    $0x28,%eax
f01038e2:	ee                   	out    %al,(%dx)
f01038e3:	b8 02 00 00 00       	mov    $0x2,%eax
f01038e8:	ee                   	out    %al,(%dx)
f01038e9:	b8 01 00 00 00       	mov    $0x1,%eax
f01038ee:	ee                   	out    %al,(%dx)
f01038ef:	ba 20 00 00 00       	mov    $0x20,%edx
f01038f4:	b8 68 00 00 00       	mov    $0x68,%eax
f01038f9:	ee                   	out    %al,(%dx)
f01038fa:	b8 0a 00 00 00       	mov    $0xa,%eax
f01038ff:	ee                   	out    %al,(%dx)
f0103900:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103905:	b8 68 00 00 00       	mov    $0x68,%eax
f010390a:	ee                   	out    %al,(%dx)
f010390b:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103910:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103911:	0f b7 05 a8 33 12 f0 	movzwl 0xf01233a8,%eax
f0103918:	66 83 f8 ff          	cmp    $0xffff,%ax
f010391c:	74 13                	je     f0103931 <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f010391e:	55                   	push   %ebp
f010391f:	89 e5                	mov    %esp,%ebp
f0103921:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0103924:	0f b7 c0             	movzwl %ax,%eax
f0103927:	50                   	push   %eax
f0103928:	e8 ee fe ff ff       	call   f010381b <irq_setmask_8259A>
f010392d:	83 c4 10             	add    $0x10,%esp
}
f0103930:	c9                   	leave  
f0103931:	f3 c3                	repz ret 

f0103933 <irq_eoi>:
	cprintf("\n");
}

void
irq_eoi(void)
{
f0103933:	55                   	push   %ebp
f0103934:	89 e5                	mov    %esp,%ebp
f0103936:	ba 20 00 00 00       	mov    $0x20,%edx
f010393b:	b8 20 00 00 00       	mov    $0x20,%eax
f0103940:	ee                   	out    %al,(%dx)
f0103941:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103946:	ee                   	out    %al,(%dx)
	//   s: specific
	//   e: end-of-interrupt
	// xxx: specific interrupt line
	outb(IO_PIC1, 0x20);
	outb(IO_PIC2, 0x20);
}
f0103947:	5d                   	pop    %ebp
f0103948:	c3                   	ret    

f0103949 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103949:	55                   	push   %ebp
f010394a:	89 e5                	mov    %esp,%ebp
f010394c:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f010394f:	ff 75 08             	pushl  0x8(%ebp)
f0103952:	e8 35 ce ff ff       	call   f010078c <cputchar>
	*cnt++;
}
f0103957:	83 c4 10             	add    $0x10,%esp
f010395a:	c9                   	leave  
f010395b:	c3                   	ret    

f010395c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010395c:	55                   	push   %ebp
f010395d:	89 e5                	mov    %esp,%ebp
f010395f:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103962:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103969:	ff 75 0c             	pushl  0xc(%ebp)
f010396c:	ff 75 08             	pushl  0x8(%ebp)
f010396f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103972:	50                   	push   %eax
f0103973:	68 49 39 10 f0       	push   $0xf0103949
f0103978:	e8 b5 17 00 00       	call   f0105132 <vprintfmt>
	return cnt;
}
f010397d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103980:	c9                   	leave  
f0103981:	c3                   	ret    

f0103982 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103982:	55                   	push   %ebp
f0103983:	89 e5                	mov    %esp,%ebp
f0103985:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103988:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f010398b:	50                   	push   %eax
f010398c:	ff 75 08             	pushl  0x8(%ebp)
f010398f:	e8 c8 ff ff ff       	call   f010395c <vcprintf>
	va_end(ap);

	return cnt;
}
f0103994:	c9                   	leave  
f0103995:	c3                   	ret    

f0103996 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103996:	55                   	push   %ebp
f0103997:	89 e5                	mov    %esp,%ebp
f0103999:	57                   	push   %edi
f010399a:	56                   	push   %esi
f010399b:	53                   	push   %ebx
f010399c:	83 ec 0c             	sub    $0xc,%esp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = (uintptr_t) percpu_kstacks[cpunum()];
f010399f:	e8 32 24 00 00       	call   f0105dd6 <cpunum>
f01039a4:	89 c3                	mov    %eax,%ebx
f01039a6:	e8 2b 24 00 00       	call   f0105dd6 <cpunum>
f01039ab:	6b db 74             	imul   $0x74,%ebx,%ebx
f01039ae:	c1 e0 0f             	shl    $0xf,%eax
f01039b1:	05 00 c0 2a f0       	add    $0xf02ac000,%eax
f01039b6:	89 83 30 b0 2a f0    	mov    %eax,-0xfd54fd0(%ebx)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f01039bc:	e8 15 24 00 00       	call   f0105dd6 <cpunum>
f01039c1:	6b c0 74             	imul   $0x74,%eax,%eax
f01039c4:	66 c7 80 34 b0 2a f0 	movw   $0x10,-0xfd54fcc(%eax)
f01039cb:	10 00 
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f01039cd:	e8 04 24 00 00       	call   f0105dd6 <cpunum>
f01039d2:	6b c0 74             	imul   $0x74,%eax,%eax
f01039d5:	66 c7 80 92 b0 2a f0 	movw   $0x68,-0xfd54f6e(%eax)
f01039dc:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + cpunum()] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
f01039de:	e8 f3 23 00 00       	call   f0105dd6 <cpunum>
f01039e3:	8d 58 05             	lea    0x5(%eax),%ebx
f01039e6:	e8 eb 23 00 00       	call   f0105dd6 <cpunum>
f01039eb:	89 c7                	mov    %eax,%edi
f01039ed:	e8 e4 23 00 00       	call   f0105dd6 <cpunum>
f01039f2:	89 c6                	mov    %eax,%esi
f01039f4:	e8 dd 23 00 00       	call   f0105dd6 <cpunum>
f01039f9:	66 c7 04 dd 40 33 12 	movw   $0x67,-0xfedccc0(,%ebx,8)
f0103a00:	f0 67 00 
f0103a03:	6b ff 74             	imul   $0x74,%edi,%edi
f0103a06:	81 c7 2c b0 2a f0    	add    $0xf02ab02c,%edi
f0103a0c:	66 89 3c dd 42 33 12 	mov    %di,-0xfedccbe(,%ebx,8)
f0103a13:	f0 
f0103a14:	6b d6 74             	imul   $0x74,%esi,%edx
f0103a17:	81 c2 2c b0 2a f0    	add    $0xf02ab02c,%edx
f0103a1d:	c1 ea 10             	shr    $0x10,%edx
f0103a20:	88 14 dd 44 33 12 f0 	mov    %dl,-0xfedccbc(,%ebx,8)
f0103a27:	c6 04 dd 45 33 12 f0 	movb   $0x99,-0xfedccbb(,%ebx,8)
f0103a2e:	99 
f0103a2f:	c6 04 dd 46 33 12 f0 	movb   $0x40,-0xfedccba(,%ebx,8)
f0103a36:	40 
f0103a37:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a3a:	05 2c b0 2a f0       	add    $0xf02ab02c,%eax
f0103a3f:	c1 e8 18             	shr    $0x18,%eax
f0103a42:	88 04 dd 47 33 12 f0 	mov    %al,-0xfedccb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + cpunum()].sd_s = 0;
f0103a49:	e8 88 23 00 00       	call   f0105dd6 <cpunum>
f0103a4e:	80 24 c5 6d 33 12 f0 	andb   $0xef,-0xfedcc93(,%eax,8)
f0103a55:	ef 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + (cpunum() << 3));
f0103a56:	e8 7b 23 00 00       	call   f0105dd6 <cpunum>
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f0103a5b:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
f0103a62:	0f 00 d8             	ltr    %ax
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f0103a65:	b8 ac 33 12 f0       	mov    $0xf01233ac,%eax
f0103a6a:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f0103a6d:	83 c4 0c             	add    $0xc,%esp
f0103a70:	5b                   	pop    %ebx
f0103a71:	5e                   	pop    %esi
f0103a72:	5f                   	pop    %edi
f0103a73:	5d                   	pop    %ebp
f0103a74:	c3                   	ret    

f0103a75 <trap_init>:
}


void
trap_init(void)
{
f0103a75:	55                   	push   %ebp
f0103a76:	89 e5                	mov    %esp,%ebp
f0103a78:	83 ec 08             	sub    $0x8,%esp
	void _IRQ_SPURIOUS_handler();
	void _IRQ_IDE_handler();
	void _IRQ_ERROR_handler();

	// SETGATE(gate, istrap, sel, off, dpl);
	SETGATE(idt[T_DIVIDE], 0, GD_KT, _T_DIVIDE_handler, 0);
f0103a7b:	b8 60 44 10 f0       	mov    $0xf0104460,%eax
f0103a80:	66 a3 60 a2 2a f0    	mov    %ax,0xf02aa260
f0103a86:	66 c7 05 62 a2 2a f0 	movw   $0x8,0xf02aa262
f0103a8d:	08 00 
f0103a8f:	c6 05 64 a2 2a f0 00 	movb   $0x0,0xf02aa264
f0103a96:	c6 05 65 a2 2a f0 8e 	movb   $0x8e,0xf02aa265
f0103a9d:	c1 e8 10             	shr    $0x10,%eax
f0103aa0:	66 a3 66 a2 2a f0    	mov    %ax,0xf02aa266
	SETGATE(idt[T_DEBUG], 0, GD_KT, _T_DEBUG_handler, 0);
f0103aa6:	b8 6a 44 10 f0       	mov    $0xf010446a,%eax
f0103aab:	66 a3 68 a2 2a f0    	mov    %ax,0xf02aa268
f0103ab1:	66 c7 05 6a a2 2a f0 	movw   $0x8,0xf02aa26a
f0103ab8:	08 00 
f0103aba:	c6 05 6c a2 2a f0 00 	movb   $0x0,0xf02aa26c
f0103ac1:	c6 05 6d a2 2a f0 8e 	movb   $0x8e,0xf02aa26d
f0103ac8:	c1 e8 10             	shr    $0x10,%eax
f0103acb:	66 a3 6e a2 2a f0    	mov    %ax,0xf02aa26e
	SETGATE(idt[T_NMI], 0, GD_KT, _T_NMI_handler, 0);
f0103ad1:	b8 70 44 10 f0       	mov    $0xf0104470,%eax
f0103ad6:	66 a3 70 a2 2a f0    	mov    %ax,0xf02aa270
f0103adc:	66 c7 05 72 a2 2a f0 	movw   $0x8,0xf02aa272
f0103ae3:	08 00 
f0103ae5:	c6 05 74 a2 2a f0 00 	movb   $0x0,0xf02aa274
f0103aec:	c6 05 75 a2 2a f0 8e 	movb   $0x8e,0xf02aa275
f0103af3:	c1 e8 10             	shr    $0x10,%eax
f0103af6:	66 a3 76 a2 2a f0    	mov    %ax,0xf02aa276
	SETGATE(idt[T_BRKPT], 0, GD_KT, _T_BRKPT_handler, 3);
f0103afc:	b8 76 44 10 f0       	mov    $0xf0104476,%eax
f0103b01:	66 a3 78 a2 2a f0    	mov    %ax,0xf02aa278
f0103b07:	66 c7 05 7a a2 2a f0 	movw   $0x8,0xf02aa27a
f0103b0e:	08 00 
f0103b10:	c6 05 7c a2 2a f0 00 	movb   $0x0,0xf02aa27c
f0103b17:	c6 05 7d a2 2a f0 ee 	movb   $0xee,0xf02aa27d
f0103b1e:	c1 e8 10             	shr    $0x10,%eax
f0103b21:	66 a3 7e a2 2a f0    	mov    %ax,0xf02aa27e
	SETGATE(idt[T_OFLOW], 0, GD_KT, _T_OFLOW_handler, 0);
f0103b27:	b8 7c 44 10 f0       	mov    $0xf010447c,%eax
f0103b2c:	66 a3 80 a2 2a f0    	mov    %ax,0xf02aa280
f0103b32:	66 c7 05 82 a2 2a f0 	movw   $0x8,0xf02aa282
f0103b39:	08 00 
f0103b3b:	c6 05 84 a2 2a f0 00 	movb   $0x0,0xf02aa284
f0103b42:	c6 05 85 a2 2a f0 8e 	movb   $0x8e,0xf02aa285
f0103b49:	c1 e8 10             	shr    $0x10,%eax
f0103b4c:	66 a3 86 a2 2a f0    	mov    %ax,0xf02aa286
	SETGATE(idt[T_BOUND], 0, GD_KT, _T_BOUND_handler, 0);
f0103b52:	b8 82 44 10 f0       	mov    $0xf0104482,%eax
f0103b57:	66 a3 88 a2 2a f0    	mov    %ax,0xf02aa288
f0103b5d:	66 c7 05 8a a2 2a f0 	movw   $0x8,0xf02aa28a
f0103b64:	08 00 
f0103b66:	c6 05 8c a2 2a f0 00 	movb   $0x0,0xf02aa28c
f0103b6d:	c6 05 8d a2 2a f0 8e 	movb   $0x8e,0xf02aa28d
f0103b74:	c1 e8 10             	shr    $0x10,%eax
f0103b77:	66 a3 8e a2 2a f0    	mov    %ax,0xf02aa28e
	SETGATE(idt[T_ILLOP], 0, GD_KT, _T_ILLOP_handler, 0);
f0103b7d:	b8 88 44 10 f0       	mov    $0xf0104488,%eax
f0103b82:	66 a3 90 a2 2a f0    	mov    %ax,0xf02aa290
f0103b88:	66 c7 05 92 a2 2a f0 	movw   $0x8,0xf02aa292
f0103b8f:	08 00 
f0103b91:	c6 05 94 a2 2a f0 00 	movb   $0x0,0xf02aa294
f0103b98:	c6 05 95 a2 2a f0 8e 	movb   $0x8e,0xf02aa295
f0103b9f:	c1 e8 10             	shr    $0x10,%eax
f0103ba2:	66 a3 96 a2 2a f0    	mov    %ax,0xf02aa296
	SETGATE(idt[T_DEVICE], 0, GD_KT, _T_DEVICE_handler, 0);
f0103ba8:	b8 8e 44 10 f0       	mov    $0xf010448e,%eax
f0103bad:	66 a3 98 a2 2a f0    	mov    %ax,0xf02aa298
f0103bb3:	66 c7 05 9a a2 2a f0 	movw   $0x8,0xf02aa29a
f0103bba:	08 00 
f0103bbc:	c6 05 9c a2 2a f0 00 	movb   $0x0,0xf02aa29c
f0103bc3:	c6 05 9d a2 2a f0 8e 	movb   $0x8e,0xf02aa29d
f0103bca:	c1 e8 10             	shr    $0x10,%eax
f0103bcd:	66 a3 9e a2 2a f0    	mov    %ax,0xf02aa29e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, _T_DBLFLT_handler, 0);
f0103bd3:	b8 94 44 10 f0       	mov    $0xf0104494,%eax
f0103bd8:	66 a3 a0 a2 2a f0    	mov    %ax,0xf02aa2a0
f0103bde:	66 c7 05 a2 a2 2a f0 	movw   $0x8,0xf02aa2a2
f0103be5:	08 00 
f0103be7:	c6 05 a4 a2 2a f0 00 	movb   $0x0,0xf02aa2a4
f0103bee:	c6 05 a5 a2 2a f0 8e 	movb   $0x8e,0xf02aa2a5
f0103bf5:	c1 e8 10             	shr    $0x10,%eax
f0103bf8:	66 a3 a6 a2 2a f0    	mov    %ax,0xf02aa2a6
	SETGATE(idt[T_TSS], 0, GD_KT, _T_TSS_handler, 0);
f0103bfe:	b8 98 44 10 f0       	mov    $0xf0104498,%eax
f0103c03:	66 a3 b0 a2 2a f0    	mov    %ax,0xf02aa2b0
f0103c09:	66 c7 05 b2 a2 2a f0 	movw   $0x8,0xf02aa2b2
f0103c10:	08 00 
f0103c12:	c6 05 b4 a2 2a f0 00 	movb   $0x0,0xf02aa2b4
f0103c19:	c6 05 b5 a2 2a f0 8e 	movb   $0x8e,0xf02aa2b5
f0103c20:	c1 e8 10             	shr    $0x10,%eax
f0103c23:	66 a3 b6 a2 2a f0    	mov    %ax,0xf02aa2b6
	SETGATE(idt[T_SEGNP], 0, GD_KT, _T_SEGNP_handler, 0);
f0103c29:	b8 9c 44 10 f0       	mov    $0xf010449c,%eax
f0103c2e:	66 a3 b8 a2 2a f0    	mov    %ax,0xf02aa2b8
f0103c34:	66 c7 05 ba a2 2a f0 	movw   $0x8,0xf02aa2ba
f0103c3b:	08 00 
f0103c3d:	c6 05 bc a2 2a f0 00 	movb   $0x0,0xf02aa2bc
f0103c44:	c6 05 bd a2 2a f0 8e 	movb   $0x8e,0xf02aa2bd
f0103c4b:	c1 e8 10             	shr    $0x10,%eax
f0103c4e:	66 a3 be a2 2a f0    	mov    %ax,0xf02aa2be
	SETGATE(idt[T_STACK], 0, GD_KT, _T_STACK_handler, 0);
f0103c54:	b8 a0 44 10 f0       	mov    $0xf01044a0,%eax
f0103c59:	66 a3 c0 a2 2a f0    	mov    %ax,0xf02aa2c0
f0103c5f:	66 c7 05 c2 a2 2a f0 	movw   $0x8,0xf02aa2c2
f0103c66:	08 00 
f0103c68:	c6 05 c4 a2 2a f0 00 	movb   $0x0,0xf02aa2c4
f0103c6f:	c6 05 c5 a2 2a f0 8e 	movb   $0x8e,0xf02aa2c5
f0103c76:	c1 e8 10             	shr    $0x10,%eax
f0103c79:	66 a3 c6 a2 2a f0    	mov    %ax,0xf02aa2c6
	SETGATE(idt[T_GPFLT], 0, GD_KT, _T_GPFLT_handler, 0);
f0103c7f:	b8 a4 44 10 f0       	mov    $0xf01044a4,%eax
f0103c84:	66 a3 c8 a2 2a f0    	mov    %ax,0xf02aa2c8
f0103c8a:	66 c7 05 ca a2 2a f0 	movw   $0x8,0xf02aa2ca
f0103c91:	08 00 
f0103c93:	c6 05 cc a2 2a f0 00 	movb   $0x0,0xf02aa2cc
f0103c9a:	c6 05 cd a2 2a f0 8e 	movb   $0x8e,0xf02aa2cd
f0103ca1:	c1 e8 10             	shr    $0x10,%eax
f0103ca4:	66 a3 ce a2 2a f0    	mov    %ax,0xf02aa2ce
	SETGATE(idt[T_PGFLT], 0, GD_KT, _T_PGFLT_handler, 0);
f0103caa:	b8 a8 44 10 f0       	mov    $0xf01044a8,%eax
f0103caf:	66 a3 d0 a2 2a f0    	mov    %ax,0xf02aa2d0
f0103cb5:	66 c7 05 d2 a2 2a f0 	movw   $0x8,0xf02aa2d2
f0103cbc:	08 00 
f0103cbe:	c6 05 d4 a2 2a f0 00 	movb   $0x0,0xf02aa2d4
f0103cc5:	c6 05 d5 a2 2a f0 8e 	movb   $0x8e,0xf02aa2d5
f0103ccc:	c1 e8 10             	shr    $0x10,%eax
f0103ccf:	66 a3 d6 a2 2a f0    	mov    %ax,0xf02aa2d6
	SETGATE(idt[T_FPERR], 0, GD_KT, _T_FPERR_handler, 0);
f0103cd5:	b8 ac 44 10 f0       	mov    $0xf01044ac,%eax
f0103cda:	66 a3 e0 a2 2a f0    	mov    %ax,0xf02aa2e0
f0103ce0:	66 c7 05 e2 a2 2a f0 	movw   $0x8,0xf02aa2e2
f0103ce7:	08 00 
f0103ce9:	c6 05 e4 a2 2a f0 00 	movb   $0x0,0xf02aa2e4
f0103cf0:	c6 05 e5 a2 2a f0 8e 	movb   $0x8e,0xf02aa2e5
f0103cf7:	c1 e8 10             	shr    $0x10,%eax
f0103cfa:	66 a3 e6 a2 2a f0    	mov    %ax,0xf02aa2e6
	SETGATE(idt[T_ALIGN], 0, GD_KT, _T_ALIGN_handler, 0);
f0103d00:	b8 b2 44 10 f0       	mov    $0xf01044b2,%eax
f0103d05:	66 a3 e8 a2 2a f0    	mov    %ax,0xf02aa2e8
f0103d0b:	66 c7 05 ea a2 2a f0 	movw   $0x8,0xf02aa2ea
f0103d12:	08 00 
f0103d14:	c6 05 ec a2 2a f0 00 	movb   $0x0,0xf02aa2ec
f0103d1b:	c6 05 ed a2 2a f0 8e 	movb   $0x8e,0xf02aa2ed
f0103d22:	c1 e8 10             	shr    $0x10,%eax
f0103d25:	66 a3 ee a2 2a f0    	mov    %ax,0xf02aa2ee
	SETGATE(idt[T_MCHK], 0, GD_KT, _T_MCHK_handler, 0);
f0103d2b:	b8 b6 44 10 f0       	mov    $0xf01044b6,%eax
f0103d30:	66 a3 f0 a2 2a f0    	mov    %ax,0xf02aa2f0
f0103d36:	66 c7 05 f2 a2 2a f0 	movw   $0x8,0xf02aa2f2
f0103d3d:	08 00 
f0103d3f:	c6 05 f4 a2 2a f0 00 	movb   $0x0,0xf02aa2f4
f0103d46:	c6 05 f5 a2 2a f0 8e 	movb   $0x8e,0xf02aa2f5
f0103d4d:	c1 e8 10             	shr    $0x10,%eax
f0103d50:	66 a3 f6 a2 2a f0    	mov    %ax,0xf02aa2f6
	SETGATE(idt[T_SIMDERR], 0, GD_KT, _T_SIMDERR_handler, 0);
f0103d56:	b8 bc 44 10 f0       	mov    $0xf01044bc,%eax
f0103d5b:	66 a3 f8 a2 2a f0    	mov    %ax,0xf02aa2f8
f0103d61:	66 c7 05 fa a2 2a f0 	movw   $0x8,0xf02aa2fa
f0103d68:	08 00 
f0103d6a:	c6 05 fc a2 2a f0 00 	movb   $0x0,0xf02aa2fc
f0103d71:	c6 05 fd a2 2a f0 8e 	movb   $0x8e,0xf02aa2fd
f0103d78:	c1 e8 10             	shr    $0x10,%eax
f0103d7b:	66 a3 fe a2 2a f0    	mov    %ax,0xf02aa2fe
	SETGATE(idt[T_SYSCALL], 0, GD_KT, _T_SYSCALL_handler, 3);
f0103d81:	b8 c2 44 10 f0       	mov    $0xf01044c2,%eax
f0103d86:	66 a3 e0 a3 2a f0    	mov    %ax,0xf02aa3e0
f0103d8c:	66 c7 05 e2 a3 2a f0 	movw   $0x8,0xf02aa3e2
f0103d93:	08 00 
f0103d95:	c6 05 e4 a3 2a f0 00 	movb   $0x0,0xf02aa3e4
f0103d9c:	c6 05 e5 a3 2a f0 ee 	movb   $0xee,0xf02aa3e5
f0103da3:	c1 e8 10             	shr    $0x10,%eax
f0103da6:	66 a3 e6 a3 2a f0    	mov    %ax,0xf02aa3e6

	SETGATE(idt[IRQ_TIMER + IRQ_OFFSET], 0, GD_KT, _IRQ_TIMER_handler, 0);
f0103dac:	b8 c8 44 10 f0       	mov    $0xf01044c8,%eax
f0103db1:	66 a3 60 a3 2a f0    	mov    %ax,0xf02aa360
f0103db7:	66 c7 05 62 a3 2a f0 	movw   $0x8,0xf02aa362
f0103dbe:	08 00 
f0103dc0:	c6 05 64 a3 2a f0 00 	movb   $0x0,0xf02aa364
f0103dc7:	c6 05 65 a3 2a f0 8e 	movb   $0x8e,0xf02aa365
f0103dce:	c1 e8 10             	shr    $0x10,%eax
f0103dd1:	66 a3 66 a3 2a f0    	mov    %ax,0xf02aa366
	SETGATE(idt[IRQ_KBD + IRQ_OFFSET], 0, GD_KT, _IRQ_KBD_handler, 0);
f0103dd7:	b8 ce 44 10 f0       	mov    $0xf01044ce,%eax
f0103ddc:	66 a3 68 a3 2a f0    	mov    %ax,0xf02aa368
f0103de2:	66 c7 05 6a a3 2a f0 	movw   $0x8,0xf02aa36a
f0103de9:	08 00 
f0103deb:	c6 05 6c a3 2a f0 00 	movb   $0x0,0xf02aa36c
f0103df2:	c6 05 6d a3 2a f0 8e 	movb   $0x8e,0xf02aa36d
f0103df9:	c1 e8 10             	shr    $0x10,%eax
f0103dfc:	66 a3 6e a3 2a f0    	mov    %ax,0xf02aa36e
	SETGATE(idt[IRQ_SERIAL + IRQ_OFFSET], 0, GD_KT, _IRQ_SERIAL_handler, 0);
f0103e02:	b8 d4 44 10 f0       	mov    $0xf01044d4,%eax
f0103e07:	66 a3 80 a3 2a f0    	mov    %ax,0xf02aa380
f0103e0d:	66 c7 05 82 a3 2a f0 	movw   $0x8,0xf02aa382
f0103e14:	08 00 
f0103e16:	c6 05 84 a3 2a f0 00 	movb   $0x0,0xf02aa384
f0103e1d:	c6 05 85 a3 2a f0 8e 	movb   $0x8e,0xf02aa385
f0103e24:	c1 e8 10             	shr    $0x10,%eax
f0103e27:	66 a3 86 a3 2a f0    	mov    %ax,0xf02aa386
	SETGATE(idt[IRQ_SPURIOUS + IRQ_OFFSET], 0, GD_KT, _IRQ_SPURIOUS_handler, 0);
f0103e2d:	b8 da 44 10 f0       	mov    $0xf01044da,%eax
f0103e32:	66 a3 98 a3 2a f0    	mov    %ax,0xf02aa398
f0103e38:	66 c7 05 9a a3 2a f0 	movw   $0x8,0xf02aa39a
f0103e3f:	08 00 
f0103e41:	c6 05 9c a3 2a f0 00 	movb   $0x0,0xf02aa39c
f0103e48:	c6 05 9d a3 2a f0 8e 	movb   $0x8e,0xf02aa39d
f0103e4f:	c1 e8 10             	shr    $0x10,%eax
f0103e52:	66 a3 9e a3 2a f0    	mov    %ax,0xf02aa39e
	SETGATE(idt[IRQ_IDE + IRQ_OFFSET], 0, GD_KT, _IRQ_IDE_handler, 0);
f0103e58:	b8 e0 44 10 f0       	mov    $0xf01044e0,%eax
f0103e5d:	66 a3 d0 a3 2a f0    	mov    %ax,0xf02aa3d0
f0103e63:	66 c7 05 d2 a3 2a f0 	movw   $0x8,0xf02aa3d2
f0103e6a:	08 00 
f0103e6c:	c6 05 d4 a3 2a f0 00 	movb   $0x0,0xf02aa3d4
f0103e73:	c6 05 d5 a3 2a f0 8e 	movb   $0x8e,0xf02aa3d5
f0103e7a:	c1 e8 10             	shr    $0x10,%eax
f0103e7d:	66 a3 d6 a3 2a f0    	mov    %ax,0xf02aa3d6
	SETGATE(idt[IRQ_ERROR + IRQ_OFFSET], 0, GD_KT, _IRQ_ERROR_handler, 0);
f0103e83:	b8 e6 44 10 f0       	mov    $0xf01044e6,%eax
f0103e88:	66 a3 f8 a3 2a f0    	mov    %ax,0xf02aa3f8
f0103e8e:	66 c7 05 fa a3 2a f0 	movw   $0x8,0xf02aa3fa
f0103e95:	08 00 
f0103e97:	c6 05 fc a3 2a f0 00 	movb   $0x0,0xf02aa3fc
f0103e9e:	c6 05 fd a3 2a f0 8e 	movb   $0x8e,0xf02aa3fd
f0103ea5:	c1 e8 10             	shr    $0x10,%eax
f0103ea8:	66 a3 fe a3 2a f0    	mov    %ax,0xf02aa3fe

	// Per-CPU setup 
	trap_init_percpu();
f0103eae:	e8 e3 fa ff ff       	call   f0103996 <trap_init_percpu>
}
f0103eb3:	c9                   	leave  
f0103eb4:	c3                   	ret    

f0103eb5 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103eb5:	55                   	push   %ebp
f0103eb6:	89 e5                	mov    %esp,%ebp
f0103eb8:	53                   	push   %ebx
f0103eb9:	83 ec 0c             	sub    $0xc,%esp
f0103ebc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103ebf:	ff 33                	pushl  (%ebx)
f0103ec1:	68 c7 80 10 f0       	push   $0xf01080c7
f0103ec6:	e8 b7 fa ff ff       	call   f0103982 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103ecb:	83 c4 08             	add    $0x8,%esp
f0103ece:	ff 73 04             	pushl  0x4(%ebx)
f0103ed1:	68 d6 80 10 f0       	push   $0xf01080d6
f0103ed6:	e8 a7 fa ff ff       	call   f0103982 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103edb:	83 c4 08             	add    $0x8,%esp
f0103ede:	ff 73 08             	pushl  0x8(%ebx)
f0103ee1:	68 e5 80 10 f0       	push   $0xf01080e5
f0103ee6:	e8 97 fa ff ff       	call   f0103982 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103eeb:	83 c4 08             	add    $0x8,%esp
f0103eee:	ff 73 0c             	pushl  0xc(%ebx)
f0103ef1:	68 f4 80 10 f0       	push   $0xf01080f4
f0103ef6:	e8 87 fa ff ff       	call   f0103982 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103efb:	83 c4 08             	add    $0x8,%esp
f0103efe:	ff 73 10             	pushl  0x10(%ebx)
f0103f01:	68 03 81 10 f0       	push   $0xf0108103
f0103f06:	e8 77 fa ff ff       	call   f0103982 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103f0b:	83 c4 08             	add    $0x8,%esp
f0103f0e:	ff 73 14             	pushl  0x14(%ebx)
f0103f11:	68 12 81 10 f0       	push   $0xf0108112
f0103f16:	e8 67 fa ff ff       	call   f0103982 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103f1b:	83 c4 08             	add    $0x8,%esp
f0103f1e:	ff 73 18             	pushl  0x18(%ebx)
f0103f21:	68 21 81 10 f0       	push   $0xf0108121
f0103f26:	e8 57 fa ff ff       	call   f0103982 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103f2b:	83 c4 08             	add    $0x8,%esp
f0103f2e:	ff 73 1c             	pushl  0x1c(%ebx)
f0103f31:	68 30 81 10 f0       	push   $0xf0108130
f0103f36:	e8 47 fa ff ff       	call   f0103982 <cprintf>
}
f0103f3b:	83 c4 10             	add    $0x10,%esp
f0103f3e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103f41:	c9                   	leave  
f0103f42:	c3                   	ret    

f0103f43 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103f43:	55                   	push   %ebp
f0103f44:	89 e5                	mov    %esp,%ebp
f0103f46:	56                   	push   %esi
f0103f47:	53                   	push   %ebx
f0103f48:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103f4b:	e8 86 1e 00 00       	call   f0105dd6 <cpunum>
f0103f50:	83 ec 04             	sub    $0x4,%esp
f0103f53:	50                   	push   %eax
f0103f54:	53                   	push   %ebx
f0103f55:	68 94 81 10 f0       	push   $0xf0108194
f0103f5a:	e8 23 fa ff ff       	call   f0103982 <cprintf>
	print_regs(&tf->tf_regs);
f0103f5f:	89 1c 24             	mov    %ebx,(%esp)
f0103f62:	e8 4e ff ff ff       	call   f0103eb5 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103f67:	83 c4 08             	add    $0x8,%esp
f0103f6a:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103f6e:	50                   	push   %eax
f0103f6f:	68 b2 81 10 f0       	push   $0xf01081b2
f0103f74:	e8 09 fa ff ff       	call   f0103982 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103f79:	83 c4 08             	add    $0x8,%esp
f0103f7c:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103f80:	50                   	push   %eax
f0103f81:	68 c5 81 10 f0       	push   $0xf01081c5
f0103f86:	e8 f7 f9 ff ff       	call   f0103982 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103f8b:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f0103f8e:	83 c4 10             	add    $0x10,%esp
f0103f91:	83 f8 13             	cmp    $0x13,%eax
f0103f94:	77 09                	ja     f0103f9f <print_trapframe+0x5c>
		return excnames[trapno];
f0103f96:	8b 14 85 60 84 10 f0 	mov    -0xfef7ba0(,%eax,4),%edx
f0103f9d:	eb 1f                	jmp    f0103fbe <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f0103f9f:	83 f8 30             	cmp    $0x30,%eax
f0103fa2:	74 15                	je     f0103fb9 <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103fa4:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f0103fa7:	83 fa 10             	cmp    $0x10,%edx
f0103faa:	b9 5e 81 10 f0       	mov    $0xf010815e,%ecx
f0103faf:	ba 4b 81 10 f0       	mov    $0xf010814b,%edx
f0103fb4:	0f 43 d1             	cmovae %ecx,%edx
f0103fb7:	eb 05                	jmp    f0103fbe <print_trapframe+0x7b>
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0103fb9:	ba 3f 81 10 f0       	mov    $0xf010813f,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103fbe:	83 ec 04             	sub    $0x4,%esp
f0103fc1:	52                   	push   %edx
f0103fc2:	50                   	push   %eax
f0103fc3:	68 d8 81 10 f0       	push   $0xf01081d8
f0103fc8:	e8 b5 f9 ff ff       	call   f0103982 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103fcd:	83 c4 10             	add    $0x10,%esp
f0103fd0:	3b 1d 60 aa 2a f0    	cmp    0xf02aaa60,%ebx
f0103fd6:	75 1a                	jne    f0103ff2 <print_trapframe+0xaf>
f0103fd8:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103fdc:	75 14                	jne    f0103ff2 <print_trapframe+0xaf>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103fde:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103fe1:	83 ec 08             	sub    $0x8,%esp
f0103fe4:	50                   	push   %eax
f0103fe5:	68 ea 81 10 f0       	push   $0xf01081ea
f0103fea:	e8 93 f9 ff ff       	call   f0103982 <cprintf>
f0103fef:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103ff2:	83 ec 08             	sub    $0x8,%esp
f0103ff5:	ff 73 2c             	pushl  0x2c(%ebx)
f0103ff8:	68 f9 81 10 f0       	push   $0xf01081f9
f0103ffd:	e8 80 f9 ff ff       	call   f0103982 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0104002:	83 c4 10             	add    $0x10,%esp
f0104005:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104009:	75 49                	jne    f0104054 <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f010400b:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f010400e:	89 c2                	mov    %eax,%edx
f0104010:	83 e2 01             	and    $0x1,%edx
f0104013:	ba 78 81 10 f0       	mov    $0xf0108178,%edx
f0104018:	b9 6d 81 10 f0       	mov    $0xf010816d,%ecx
f010401d:	0f 44 ca             	cmove  %edx,%ecx
f0104020:	89 c2                	mov    %eax,%edx
f0104022:	83 e2 02             	and    $0x2,%edx
f0104025:	ba 8a 81 10 f0       	mov    $0xf010818a,%edx
f010402a:	be 84 81 10 f0       	mov    $0xf0108184,%esi
f010402f:	0f 45 d6             	cmovne %esi,%edx
f0104032:	83 e0 04             	and    $0x4,%eax
f0104035:	be ee 82 10 f0       	mov    $0xf01082ee,%esi
f010403a:	b8 8f 81 10 f0       	mov    $0xf010818f,%eax
f010403f:	0f 44 c6             	cmove  %esi,%eax
f0104042:	51                   	push   %ecx
f0104043:	52                   	push   %edx
f0104044:	50                   	push   %eax
f0104045:	68 07 82 10 f0       	push   $0xf0108207
f010404a:	e8 33 f9 ff ff       	call   f0103982 <cprintf>
f010404f:	83 c4 10             	add    $0x10,%esp
f0104052:	eb 10                	jmp    f0104064 <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0104054:	83 ec 0c             	sub    $0xc,%esp
f0104057:	68 f9 74 10 f0       	push   $0xf01074f9
f010405c:	e8 21 f9 ff ff       	call   f0103982 <cprintf>
f0104061:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0104064:	83 ec 08             	sub    $0x8,%esp
f0104067:	ff 73 30             	pushl  0x30(%ebx)
f010406a:	68 16 82 10 f0       	push   $0xf0108216
f010406f:	e8 0e f9 ff ff       	call   f0103982 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0104074:	83 c4 08             	add    $0x8,%esp
f0104077:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f010407b:	50                   	push   %eax
f010407c:	68 25 82 10 f0       	push   $0xf0108225
f0104081:	e8 fc f8 ff ff       	call   f0103982 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104086:	83 c4 08             	add    $0x8,%esp
f0104089:	ff 73 38             	pushl  0x38(%ebx)
f010408c:	68 38 82 10 f0       	push   $0xf0108238
f0104091:	e8 ec f8 ff ff       	call   f0103982 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0104096:	83 c4 10             	add    $0x10,%esp
f0104099:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f010409d:	74 25                	je     f01040c4 <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f010409f:	83 ec 08             	sub    $0x8,%esp
f01040a2:	ff 73 3c             	pushl  0x3c(%ebx)
f01040a5:	68 47 82 10 f0       	push   $0xf0108247
f01040aa:	e8 d3 f8 ff ff       	call   f0103982 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01040af:	83 c4 08             	add    $0x8,%esp
f01040b2:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01040b6:	50                   	push   %eax
f01040b7:	68 56 82 10 f0       	push   $0xf0108256
f01040bc:	e8 c1 f8 ff ff       	call   f0103982 <cprintf>
f01040c1:	83 c4 10             	add    $0x10,%esp
	}
}
f01040c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01040c7:	5b                   	pop    %ebx
f01040c8:	5e                   	pop    %esi
f01040c9:	5d                   	pop    %ebp
f01040ca:	c3                   	ret    

f01040cb <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01040cb:	55                   	push   %ebp
f01040cc:	89 e5                	mov    %esp,%ebp
f01040ce:	57                   	push   %edi
f01040cf:	56                   	push   %esi
f01040d0:	53                   	push   %ebx
f01040d1:	83 ec 1c             	sub    $0x1c,%esp
f01040d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01040d7:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) == 0)
f01040da:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01040de:	75 15                	jne    f01040f5 <page_fault_handler+0x2a>
		panic("page fault in kernel at %x!", fault_va);
f01040e0:	56                   	push   %esi
f01040e1:	68 69 82 10 f0       	push   $0xf0108269
f01040e6:	68 73 01 00 00       	push   $0x173
f01040eb:	68 85 82 10 f0       	push   $0xf0108285
f01040f0:	e8 4b bf ff ff       	call   f0100040 <_panic>
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	if (curenv->env_pgfault_upcall) {
f01040f5:	e8 dc 1c 00 00       	call   f0105dd6 <cpunum>
f01040fa:	6b c0 74             	imul   $0x74,%eax,%eax
f01040fd:	8b 80 28 b0 2a f0    	mov    -0xfd54fd8(%eax),%eax
f0104103:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0104107:	0f 84 af 00 00 00    	je     f01041bc <page_fault_handler+0xf1>
		uint32_t estack_top = UXSTACKTOP;

		// if pgfault happens in user exception stack
		// as mentioned above, we push things right after the previous exception stack 
		// started with dummy 4 bytes
		if (tf->tf_esp < UXSTACKTOP && tf->tf_esp >= UXSTACKTOP - PGSIZE)
f010410d:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104110:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			estack_top = tf->tf_esp - 4;
f0104116:	83 e8 04             	sub    $0x4,%eax
f0104119:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f010411f:	bf 00 00 c0 ee       	mov    $0xeec00000,%edi
f0104124:	0f 46 f8             	cmovbe %eax,%edi

		// char* utrapframe = (char *)(estack_top - sizeof(struct UTrapframe));
		struct UTrapframe *utf = (struct UTrapframe *)(estack_top - sizeof(struct UTrapframe));
f0104127:	8d 47 cc             	lea    -0x34(%edi),%eax
f010412a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// do a memory check
		user_mem_assert(curenv, (void *)utf, sizeof(struct UTrapframe), PTE_W | PTE_P);
f010412d:	e8 a4 1c 00 00       	call   f0105dd6 <cpunum>
f0104132:	6a 03                	push   $0x3
f0104134:	6a 34                	push   $0x34
f0104136:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104139:	6b c0 74             	imul   $0x74,%eax,%eax
f010413c:	ff b0 28 b0 2a f0    	pushl  -0xfd54fd8(%eax)
f0104142:	e8 01 ef ff ff       	call   f0103048 <user_mem_assert>

		// copy context to utrapframe 
		// memcpy(utrapframe, (char *)tf, sizeof(struct UTrapframe));
		// *(uint32_t *)utrapframe = fault_va;
		utf->utf_fault_va = fault_va;
f0104147:	89 77 cc             	mov    %esi,-0x34(%edi)
        utf->utf_err      = tf->tf_trapno;
f010414a:	8b 43 28             	mov    0x28(%ebx),%eax
f010414d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104150:	89 42 04             	mov    %eax,0x4(%edx)
        utf->utf_regs     = tf->tf_regs;
f0104153:	83 ef 2c             	sub    $0x2c,%edi
f0104156:	b9 08 00 00 00       	mov    $0x8,%ecx
f010415b:	89 de                	mov    %ebx,%esi
f010415d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
        utf->utf_eflags   = tf->tf_eflags;
f010415f:	8b 43 38             	mov    0x38(%ebx),%eax
f0104162:	89 42 2c             	mov    %eax,0x2c(%edx)
        utf->utf_eip      = tf->tf_eip;
f0104165:	8b 43 30             	mov    0x30(%ebx),%eax
f0104168:	89 d6                	mov    %edx,%esi
f010416a:	89 42 28             	mov    %eax,0x28(%edx)
        utf->utf_esp      = tf->tf_esp;
f010416d:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104170:	89 42 30             	mov    %eax,0x30(%edx)

		curenv->env_tf.tf_esp = (uint32_t)utf;
f0104173:	e8 5e 1c 00 00       	call   f0105dd6 <cpunum>
f0104178:	6b c0 74             	imul   $0x74,%eax,%eax
f010417b:	8b 80 28 b0 2a f0    	mov    -0xfd54fd8(%eax),%eax
f0104181:	89 70 3c             	mov    %esi,0x3c(%eax)
		curenv->env_tf.tf_eip = (uint32_t)curenv->env_pgfault_upcall;
f0104184:	e8 4d 1c 00 00       	call   f0105dd6 <cpunum>
f0104189:	6b c0 74             	imul   $0x74,%eax,%eax
f010418c:	8b 98 28 b0 2a f0    	mov    -0xfd54fd8(%eax),%ebx
f0104192:	e8 3f 1c 00 00       	call   f0105dd6 <cpunum>
f0104197:	6b c0 74             	imul   $0x74,%eax,%eax
f010419a:	8b 80 28 b0 2a f0    	mov    -0xfd54fd8(%eax),%eax
f01041a0:	8b 40 64             	mov    0x64(%eax),%eax
f01041a3:	89 43 30             	mov    %eax,0x30(%ebx)
		env_run(curenv);
f01041a6:	e8 2b 1c 00 00       	call   f0105dd6 <cpunum>
f01041ab:	83 c4 04             	add    $0x4,%esp
f01041ae:	6b c0 74             	imul   $0x74,%eax,%eax
f01041b1:	ff b0 28 b0 2a f0    	pushl  -0xfd54fd8(%eax)
f01041b7:	e8 4e f5 ff ff       	call   f010370a <env_run>

	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01041bc:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f01041bf:	e8 12 1c 00 00       	call   f0105dd6 <cpunum>
		env_run(curenv);

	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01041c4:	57                   	push   %edi
f01041c5:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f01041c6:	6b c0 74             	imul   $0x74,%eax,%eax
		env_run(curenv);

	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01041c9:	8b 80 28 b0 2a f0    	mov    -0xfd54fd8(%eax),%eax
f01041cf:	ff 70 48             	pushl  0x48(%eax)
f01041d2:	68 38 84 10 f0       	push   $0xf0108438
f01041d7:	e8 a6 f7 ff ff       	call   f0103982 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f01041dc:	89 1c 24             	mov    %ebx,(%esp)
f01041df:	e8 5f fd ff ff       	call   f0103f43 <print_trapframe>
	env_destroy(curenv);
f01041e4:	e8 ed 1b 00 00       	call   f0105dd6 <cpunum>
f01041e9:	83 c4 04             	add    $0x4,%esp
f01041ec:	6b c0 74             	imul   $0x74,%eax,%eax
f01041ef:	ff b0 28 b0 2a f0    	pushl  -0xfd54fd8(%eax)
f01041f5:	e8 71 f4 ff ff       	call   f010366b <env_destroy>
}
f01041fa:	83 c4 10             	add    $0x10,%esp
f01041fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104200:	5b                   	pop    %ebx
f0104201:	5e                   	pop    %esi
f0104202:	5f                   	pop    %edi
f0104203:	5d                   	pop    %ebp
f0104204:	c3                   	ret    

f0104205 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0104205:	55                   	push   %ebp
f0104206:	89 e5                	mov    %esp,%ebp
f0104208:	57                   	push   %edi
f0104209:	56                   	push   %esi
f010420a:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f010420d:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f010420e:	83 3d 8c ae 2a f0 00 	cmpl   $0x0,0xf02aae8c
f0104215:	74 01                	je     f0104218 <trap+0x13>
		asm volatile("hlt");
f0104217:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104218:	e8 b9 1b 00 00       	call   f0105dd6 <cpunum>
f010421d:	6b d0 74             	imul   $0x74,%eax,%edx
f0104220:	81 c2 20 b0 2a f0    	add    $0xf02ab020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0104226:	b8 01 00 00 00       	mov    $0x1,%eax
f010422b:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010422f:	83 f8 02             	cmp    $0x2,%eax
f0104232:	75 10                	jne    f0104244 <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104234:	83 ec 0c             	sub    $0xc,%esp
f0104237:	68 c0 33 12 f0       	push   $0xf01233c0
f010423c:	e8 03 1e 00 00       	call   f0106044 <spin_lock>
f0104241:	83 c4 10             	add    $0x10,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0104244:	9c                   	pushf  
f0104245:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104246:	f6 c4 02             	test   $0x2,%ah
f0104249:	74 19                	je     f0104264 <trap+0x5f>
f010424b:	68 91 82 10 f0       	push   $0xf0108291
f0104250:	68 e5 71 10 f0       	push   $0xf01071e5
f0104255:	68 3b 01 00 00       	push   $0x13b
f010425a:	68 85 82 10 f0       	push   $0xf0108285
f010425f:	e8 dc bd ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0104264:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104268:	83 e0 03             	and    $0x3,%eax
f010426b:	66 83 f8 03          	cmp    $0x3,%ax
f010426f:	0f 85 a0 00 00 00    	jne    f0104315 <trap+0x110>
f0104275:	83 ec 0c             	sub    $0xc,%esp
f0104278:	68 c0 33 12 f0       	push   $0xf01233c0
f010427d:	e8 c2 1d 00 00       	call   f0106044 <spin_lock>
		// serious kernel work.
		// LAB 4: Your code here.

		lock_kernel();

		assert(curenv);
f0104282:	e8 4f 1b 00 00       	call   f0105dd6 <cpunum>
f0104287:	6b c0 74             	imul   $0x74,%eax,%eax
f010428a:	83 c4 10             	add    $0x10,%esp
f010428d:	83 b8 28 b0 2a f0 00 	cmpl   $0x0,-0xfd54fd8(%eax)
f0104294:	75 19                	jne    f01042af <trap+0xaa>
f0104296:	68 aa 82 10 f0       	push   $0xf01082aa
f010429b:	68 e5 71 10 f0       	push   $0xf01071e5
f01042a0:	68 45 01 00 00       	push   $0x145
f01042a5:	68 85 82 10 f0       	push   $0xf0108285
f01042aa:	e8 91 bd ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f01042af:	e8 22 1b 00 00       	call   f0105dd6 <cpunum>
f01042b4:	6b c0 74             	imul   $0x74,%eax,%eax
f01042b7:	8b 80 28 b0 2a f0    	mov    -0xfd54fd8(%eax),%eax
f01042bd:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01042c1:	75 2d                	jne    f01042f0 <trap+0xeb>
			env_free(curenv);
f01042c3:	e8 0e 1b 00 00       	call   f0105dd6 <cpunum>
f01042c8:	83 ec 0c             	sub    $0xc,%esp
f01042cb:	6b c0 74             	imul   $0x74,%eax,%eax
f01042ce:	ff b0 28 b0 2a f0    	pushl  -0xfd54fd8(%eax)
f01042d4:	e8 ec f1 ff ff       	call   f01034c5 <env_free>
			curenv = NULL;
f01042d9:	e8 f8 1a 00 00       	call   f0105dd6 <cpunum>
f01042de:	6b c0 74             	imul   $0x74,%eax,%eax
f01042e1:	c7 80 28 b0 2a f0 00 	movl   $0x0,-0xfd54fd8(%eax)
f01042e8:	00 00 00 
			sched_yield();
f01042eb:	e8 e2 02 00 00       	call   f01045d2 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01042f0:	e8 e1 1a 00 00       	call   f0105dd6 <cpunum>
f01042f5:	6b c0 74             	imul   $0x74,%eax,%eax
f01042f8:	8b 80 28 b0 2a f0    	mov    -0xfd54fd8(%eax),%eax
f01042fe:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104303:	89 c7                	mov    %eax,%edi
f0104305:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104307:	e8 ca 1a 00 00       	call   f0105dd6 <cpunum>
f010430c:	6b c0 74             	imul   $0x74,%eax,%eax
f010430f:	8b b0 28 b0 2a f0    	mov    -0xfd54fd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104315:	89 35 60 aa 2a f0    	mov    %esi,0xf02aaa60
	// Handle keyboard and serial interrupts.
	// LAB 5: Your code here.

	struct PushRegs* r = &tf->tf_regs;

	switch(tf->tf_trapno) {
f010431b:	8b 46 28             	mov    0x28(%esi),%eax
f010431e:	83 f8 21             	cmp    $0x21,%eax
f0104321:	0f 84 80 00 00 00    	je     f01043a7 <trap+0x1a2>
f0104327:	83 f8 21             	cmp    $0x21,%eax
f010432a:	77 15                	ja     f0104341 <trap+0x13c>
f010432c:	83 f8 0e             	cmp    $0xe,%eax
f010432f:	74 21                	je     f0104352 <trap+0x14d>
f0104331:	83 f8 20             	cmp    $0x20,%eax
f0104334:	74 62                	je     f0104398 <trap+0x193>
f0104336:	83 f8 03             	cmp    $0x3,%eax
f0104339:	0f 85 90 00 00 00    	jne    f01043cf <trap+0x1ca>
f010433f:	eb 22                	jmp    f0104363 <trap+0x15e>
f0104341:	83 f8 27             	cmp    $0x27,%eax
f0104344:	74 6f                	je     f01043b5 <trap+0x1b0>
f0104346:	83 f8 30             	cmp    $0x30,%eax
f0104349:	74 29                	je     f0104374 <trap+0x16f>
f010434b:	83 f8 24             	cmp    $0x24,%eax
f010434e:	75 7f                	jne    f01043cf <trap+0x1ca>
f0104350:	eb 5c                	jmp    f01043ae <trap+0x1a9>
		case (T_PGFLT):
			page_fault_handler(tf);
f0104352:	83 ec 0c             	sub    $0xc,%esp
f0104355:	56                   	push   %esi
f0104356:	e8 70 fd ff ff       	call   f01040cb <page_fault_handler>
f010435b:	83 c4 10             	add    $0x10,%esp
f010435e:	e9 bc 00 00 00       	jmp    f010441f <trap+0x21a>
			break;
		case (T_BRKPT):
			monitor(tf);	// open a JOS monitor
f0104363:	83 ec 0c             	sub    $0xc,%esp
f0104366:	56                   	push   %esi
f0104367:	e8 45 c6 ff ff       	call   f01009b1 <monitor>
f010436c:	83 c4 10             	add    $0x10,%esp
f010436f:	e9 ab 00 00 00       	jmp    f010441f <trap+0x21a>
			break;
		case (T_SYSCALL):
			// call syscall in kern/syscall.c
			r->reg_eax = syscall(r->reg_eax, r->reg_edx, r->reg_ecx, r->reg_ebx, r->reg_edi, r->reg_esi);
f0104374:	83 ec 08             	sub    $0x8,%esp
f0104377:	ff 76 04             	pushl  0x4(%esi)
f010437a:	ff 36                	pushl  (%esi)
f010437c:	ff 76 10             	pushl  0x10(%esi)
f010437f:	ff 76 18             	pushl  0x18(%esi)
f0104382:	ff 76 14             	pushl  0x14(%esi)
f0104385:	ff 76 1c             	pushl  0x1c(%esi)
f0104388:	e8 01 03 00 00       	call   f010468e <syscall>
f010438d:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104390:	83 c4 20             	add    $0x20,%esp
f0104393:	e9 87 00 00 00       	jmp    f010441f <trap+0x21a>
			break;
		case (IRQ_OFFSET + IRQ_TIMER):
			lapic_eoi();	// Acknowledge interrupt.
f0104398:	e8 84 1b 00 00       	call   f0105f21 <lapic_eoi>
			time_tick();
f010439d:	e8 59 25 00 00       	call   f01068fb <time_tick>
			sched_yield();
f01043a2:	e8 2b 02 00 00       	call   f01045d2 <sched_yield>
			break;
		case (IRQ_OFFSET + IRQ_KBD):
			kbd_intr();
f01043a7:	e8 3e c2 ff ff       	call   f01005ea <kbd_intr>
f01043ac:	eb 71                	jmp    f010441f <trap+0x21a>
			break;
		case (IRQ_OFFSET + IRQ_SERIAL):
			serial_intr();
f01043ae:	e8 1b c2 ff ff       	call   f01005ce <serial_intr>
f01043b3:	eb 6a                	jmp    f010441f <trap+0x21a>
			break;
		case (IRQ_OFFSET + IRQ_SPURIOUS):
			cprintf("Spurious interrupt on irq 7\n");
f01043b5:	83 ec 0c             	sub    $0xc,%esp
f01043b8:	68 b1 82 10 f0       	push   $0xf01082b1
f01043bd:	e8 c0 f5 ff ff       	call   f0103982 <cprintf>
			print_trapframe(tf);
f01043c2:	89 34 24             	mov    %esi,(%esp)
f01043c5:	e8 79 fb ff ff       	call   f0103f43 <print_trapframe>
f01043ca:	83 c4 10             	add    $0x10,%esp
f01043cd:	eb 50                	jmp    f010441f <trap+0x21a>
			return;
		default:
			// Unexpected trap: The user process or the kernel has a bug.
			cprintf("[trapno: %x]\n", tf->tf_trapno);
f01043cf:	83 ec 08             	sub    $0x8,%esp
f01043d2:	50                   	push   %eax
f01043d3:	68 ce 82 10 f0       	push   $0xf01082ce
f01043d8:	e8 a5 f5 ff ff       	call   f0103982 <cprintf>
			print_trapframe(tf);
f01043dd:	89 34 24             	mov    %esi,(%esp)
f01043e0:	e8 5e fb ff ff       	call   f0103f43 <print_trapframe>
			if (tf->tf_cs == GD_KT)
f01043e5:	83 c4 10             	add    $0x10,%esp
f01043e8:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01043ed:	75 17                	jne    f0104406 <trap+0x201>
				panic("unhandled trap in kernel");
f01043ef:	83 ec 04             	sub    $0x4,%esp
f01043f2:	68 dc 82 10 f0       	push   $0xf01082dc
f01043f7:	68 20 01 00 00       	push   $0x120
f01043fc:	68 85 82 10 f0       	push   $0xf0108285
f0104401:	e8 3a bc ff ff       	call   f0100040 <_panic>
			else {
				env_destroy(curenv);
f0104406:	e8 cb 19 00 00       	call   f0105dd6 <cpunum>
f010440b:	83 ec 0c             	sub    $0xc,%esp
f010440e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104411:	ff b0 28 b0 2a f0    	pushl  -0xfd54fd8(%eax)
f0104417:	e8 4f f2 ff ff       	call   f010366b <env_destroy>
f010441c:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f010441f:	e8 b2 19 00 00       	call   f0105dd6 <cpunum>
f0104424:	6b c0 74             	imul   $0x74,%eax,%eax
f0104427:	83 b8 28 b0 2a f0 00 	cmpl   $0x0,-0xfd54fd8(%eax)
f010442e:	74 2a                	je     f010445a <trap+0x255>
f0104430:	e8 a1 19 00 00       	call   f0105dd6 <cpunum>
f0104435:	6b c0 74             	imul   $0x74,%eax,%eax
f0104438:	8b 80 28 b0 2a f0    	mov    -0xfd54fd8(%eax),%eax
f010443e:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104442:	75 16                	jne    f010445a <trap+0x255>
		env_run(curenv);
f0104444:	e8 8d 19 00 00       	call   f0105dd6 <cpunum>
f0104449:	83 ec 0c             	sub    $0xc,%esp
f010444c:	6b c0 74             	imul   $0x74,%eax,%eax
f010444f:	ff b0 28 b0 2a f0    	pushl  -0xfd54fd8(%eax)
f0104455:	e8 b0 f2 ff ff       	call   f010370a <env_run>
	else
		sched_yield();
f010445a:	e8 73 01 00 00       	call   f01045d2 <sched_yield>
f010445f:	90                   	nop

f0104460 <_T_DIVIDE_handler>:
/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */


TRAPHANDLER_NOEC(_T_DIVIDE_handler, T_DIVIDE)
f0104460:	6a 00                	push   $0x0
f0104462:	6a 00                	push   $0x0
f0104464:	e9 83 00 00 00       	jmp    f01044ec <_alltraps>
f0104469:	90                   	nop

f010446a <_T_DEBUG_handler>:
TRAPHANDLER_NOEC(_T_DEBUG_handler, T_DEBUG)
f010446a:	6a 00                	push   $0x0
f010446c:	6a 01                	push   $0x1
f010446e:	eb 7c                	jmp    f01044ec <_alltraps>

f0104470 <_T_NMI_handler>:
TRAPHANDLER_NOEC(_T_NMI_handler, T_NMI)
f0104470:	6a 00                	push   $0x0
f0104472:	6a 02                	push   $0x2
f0104474:	eb 76                	jmp    f01044ec <_alltraps>

f0104476 <_T_BRKPT_handler>:
TRAPHANDLER_NOEC(_T_BRKPT_handler, T_BRKPT)
f0104476:	6a 00                	push   $0x0
f0104478:	6a 03                	push   $0x3
f010447a:	eb 70                	jmp    f01044ec <_alltraps>

f010447c <_T_OFLOW_handler>:
TRAPHANDLER_NOEC(_T_OFLOW_handler, T_OFLOW)
f010447c:	6a 00                	push   $0x0
f010447e:	6a 04                	push   $0x4
f0104480:	eb 6a                	jmp    f01044ec <_alltraps>

f0104482 <_T_BOUND_handler>:
TRAPHANDLER_NOEC(_T_BOUND_handler, T_BOUND)
f0104482:	6a 00                	push   $0x0
f0104484:	6a 05                	push   $0x5
f0104486:	eb 64                	jmp    f01044ec <_alltraps>

f0104488 <_T_ILLOP_handler>:
TRAPHANDLER_NOEC(_T_ILLOP_handler, T_ILLOP)
f0104488:	6a 00                	push   $0x0
f010448a:	6a 06                	push   $0x6
f010448c:	eb 5e                	jmp    f01044ec <_alltraps>

f010448e <_T_DEVICE_handler>:
TRAPHANDLER_NOEC(_T_DEVICE_handler, T_DEVICE)
f010448e:	6a 00                	push   $0x0
f0104490:	6a 07                	push   $0x7
f0104492:	eb 58                	jmp    f01044ec <_alltraps>

f0104494 <_T_DBLFLT_handler>:
TRAPHANDLER(_T_DBLFLT_handler, T_DBLFLT)
f0104494:	6a 08                	push   $0x8
f0104496:	eb 54                	jmp    f01044ec <_alltraps>

f0104498 <_T_TSS_handler>:
TRAPHANDLER(_T_TSS_handler, T_TSS)
f0104498:	6a 0a                	push   $0xa
f010449a:	eb 50                	jmp    f01044ec <_alltraps>

f010449c <_T_SEGNP_handler>:
TRAPHANDLER(_T_SEGNP_handler, T_SEGNP)
f010449c:	6a 0b                	push   $0xb
f010449e:	eb 4c                	jmp    f01044ec <_alltraps>

f01044a0 <_T_STACK_handler>:
TRAPHANDLER(_T_STACK_handler, T_STACK)
f01044a0:	6a 0c                	push   $0xc
f01044a2:	eb 48                	jmp    f01044ec <_alltraps>

f01044a4 <_T_GPFLT_handler>:
TRAPHANDLER(_T_GPFLT_handler, T_GPFLT)
f01044a4:	6a 0d                	push   $0xd
f01044a6:	eb 44                	jmp    f01044ec <_alltraps>

f01044a8 <_T_PGFLT_handler>:
TRAPHANDLER(_T_PGFLT_handler, T_PGFLT)
f01044a8:	6a 0e                	push   $0xe
f01044aa:	eb 40                	jmp    f01044ec <_alltraps>

f01044ac <_T_FPERR_handler>:
TRAPHANDLER_NOEC(_T_FPERR_handler, T_FPERR)
f01044ac:	6a 00                	push   $0x0
f01044ae:	6a 10                	push   $0x10
f01044b0:	eb 3a                	jmp    f01044ec <_alltraps>

f01044b2 <_T_ALIGN_handler>:
TRAPHANDLER(_T_ALIGN_handler, T_ALIGN)
f01044b2:	6a 11                	push   $0x11
f01044b4:	eb 36                	jmp    f01044ec <_alltraps>

f01044b6 <_T_MCHK_handler>:
TRAPHANDLER_NOEC(_T_MCHK_handler, T_MCHK)
f01044b6:	6a 00                	push   $0x0
f01044b8:	6a 12                	push   $0x12
f01044ba:	eb 30                	jmp    f01044ec <_alltraps>

f01044bc <_T_SIMDERR_handler>:
TRAPHANDLER_NOEC(_T_SIMDERR_handler, T_SIMDERR)
f01044bc:	6a 00                	push   $0x0
f01044be:	6a 13                	push   $0x13
f01044c0:	eb 2a                	jmp    f01044ec <_alltraps>

f01044c2 <_T_SYSCALL_handler>:
TRAPHANDLER_NOEC(_T_SYSCALL_handler, T_SYSCALL)
f01044c2:	6a 00                	push   $0x0
f01044c4:	6a 30                	push   $0x30
f01044c6:	eb 24                	jmp    f01044ec <_alltraps>

f01044c8 <_IRQ_TIMER_handler>:

TRAPHANDLER_NOEC(_IRQ_TIMER_handler, IRQ_TIMER + IRQ_OFFSET)
f01044c8:	6a 00                	push   $0x0
f01044ca:	6a 20                	push   $0x20
f01044cc:	eb 1e                	jmp    f01044ec <_alltraps>

f01044ce <_IRQ_KBD_handler>:
TRAPHANDLER_NOEC(_IRQ_KBD_handler, IRQ_KBD + IRQ_OFFSET)
f01044ce:	6a 00                	push   $0x0
f01044d0:	6a 21                	push   $0x21
f01044d2:	eb 18                	jmp    f01044ec <_alltraps>

f01044d4 <_IRQ_SERIAL_handler>:
TRAPHANDLER_NOEC(_IRQ_SERIAL_handler, IRQ_SERIAL + IRQ_OFFSET)
f01044d4:	6a 00                	push   $0x0
f01044d6:	6a 24                	push   $0x24
f01044d8:	eb 12                	jmp    f01044ec <_alltraps>

f01044da <_IRQ_SPURIOUS_handler>:
TRAPHANDLER_NOEC(_IRQ_SPURIOUS_handler, IRQ_SPURIOUS + IRQ_OFFSET)
f01044da:	6a 00                	push   $0x0
f01044dc:	6a 27                	push   $0x27
f01044de:	eb 0c                	jmp    f01044ec <_alltraps>

f01044e0 <_IRQ_IDE_handler>:
TRAPHANDLER_NOEC(_IRQ_IDE_handler, IRQ_IDE + IRQ_OFFSET)
f01044e0:	6a 00                	push   $0x0
f01044e2:	6a 2e                	push   $0x2e
f01044e4:	eb 06                	jmp    f01044ec <_alltraps>

f01044e6 <_IRQ_ERROR_handler>:
TRAPHANDLER_NOEC(_IRQ_ERROR_handler, IRQ_ERROR + IRQ_OFFSET)
f01044e6:	6a 00                	push   $0x0
f01044e8:	6a 33                	push   $0x33
f01044ea:	eb 00                	jmp    f01044ec <_alltraps>

f01044ec <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */

_alltraps:
	pushl %ds
f01044ec:	1e                   	push   %ds
	pushl %es
f01044ed:	06                   	push   %es
	pushal	/* push all general registers */
f01044ee:	60                   	pusha  

	movl $GD_KD, %eax
f01044ef:	b8 10 00 00 00       	mov    $0x10,%eax
	movl %eax, %ds
f01044f4:	8e d8                	mov    %eax,%ds
	movl %eax, %es
f01044f6:	8e c0                	mov    %eax,%es

	push %esp
f01044f8:	54                   	push   %esp
f01044f9:	e8 07 fd ff ff       	call   f0104205 <trap>

f01044fe <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f01044fe:	55                   	push   %ebp
f01044ff:	89 e5                	mov    %esp,%ebp
f0104501:	83 ec 08             	sub    $0x8,%esp
f0104504:	a1 48 a2 2a f0       	mov    0xf02aa248,%eax
f0104509:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f010450c:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104511:	8b 02                	mov    (%edx),%eax
f0104513:	83 e8 01             	sub    $0x1,%eax
f0104516:	83 f8 02             	cmp    $0x2,%eax
f0104519:	76 10                	jbe    f010452b <sched_halt+0x2d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f010451b:	83 c1 01             	add    $0x1,%ecx
f010451e:	83 c2 7c             	add    $0x7c,%edx
f0104521:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104527:	75 e8                	jne    f0104511 <sched_halt+0x13>
f0104529:	eb 08                	jmp    f0104533 <sched_halt+0x35>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f010452b:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104531:	75 1f                	jne    f0104552 <sched_halt+0x54>
		cprintf("No runnable environments in the system!\n");
f0104533:	83 ec 0c             	sub    $0xc,%esp
f0104536:	68 b0 84 10 f0       	push   $0xf01084b0
f010453b:	e8 42 f4 ff ff       	call   f0103982 <cprintf>
f0104540:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0104543:	83 ec 0c             	sub    $0xc,%esp
f0104546:	6a 00                	push   $0x0
f0104548:	e8 64 c4 ff ff       	call   f01009b1 <monitor>
f010454d:	83 c4 10             	add    $0x10,%esp
f0104550:	eb f1                	jmp    f0104543 <sched_halt+0x45>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104552:	e8 7f 18 00 00       	call   f0105dd6 <cpunum>
f0104557:	6b c0 74             	imul   $0x74,%eax,%eax
f010455a:	c7 80 28 b0 2a f0 00 	movl   $0x0,-0xfd54fd8(%eax)
f0104561:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104564:	a1 98 ae 2a f0       	mov    0xf02aae98,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104569:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010456e:	77 12                	ja     f0104582 <sched_halt+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104570:	50                   	push   %eax
f0104571:	68 28 6c 10 f0       	push   $0xf0106c28
f0104576:	6a 52                	push   $0x52
f0104578:	68 d9 84 10 f0       	push   $0xf01084d9
f010457d:	e8 be ba ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104582:	05 00 00 00 10       	add    $0x10000000,%eax
f0104587:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f010458a:	e8 47 18 00 00       	call   f0105dd6 <cpunum>
f010458f:	6b d0 74             	imul   $0x74,%eax,%edx
f0104592:	81 c2 20 b0 2a f0    	add    $0xf02ab020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0104598:	b8 02 00 00 00       	mov    $0x2,%eax
f010459d:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01045a1:	83 ec 0c             	sub    $0xc,%esp
f01045a4:	68 c0 33 12 f0       	push   $0xf01233c0
f01045a9:	e8 33 1b 00 00       	call   f01060e1 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01045ae:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f01045b0:	e8 21 18 00 00       	call   f0105dd6 <cpunum>
f01045b5:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f01045b8:	8b 80 30 b0 2a f0    	mov    -0xfd54fd0(%eax),%eax
f01045be:	bd 00 00 00 00       	mov    $0x0,%ebp
f01045c3:	89 c4                	mov    %eax,%esp
f01045c5:	6a 00                	push   $0x0
f01045c7:	6a 00                	push   $0x0
f01045c9:	fb                   	sti    
f01045ca:	f4                   	hlt    
f01045cb:	eb fd                	jmp    f01045ca <sched_halt+0xcc>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f01045cd:	83 c4 10             	add    $0x10,%esp
f01045d0:	c9                   	leave  
f01045d1:	c3                   	ret    

f01045d2 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f01045d2:	55                   	push   %ebp
f01045d3:	89 e5                	mov    %esp,%ebp
f01045d5:	56                   	push   %esi
f01045d6:	53                   	push   %ebx
	// below to halt the cpu.

	// LAB 4: Your code here.
	// cprintf("[yield]\n");

	struct Env *now = thiscpu->cpu_env;
f01045d7:	e8 fa 17 00 00       	call   f0105dd6 <cpunum>
f01045dc:	6b c0 74             	imul   $0x74,%eax,%eax
f01045df:	8b 80 28 b0 2a f0    	mov    -0xfd54fd8(%eax),%eax
    int32_t startid = (now) ? ENVX(now->env_id): 0;
f01045e5:	85 c0                	test   %eax,%eax
f01045e7:	74 0b                	je     f01045f4 <sched_yield+0x22>
f01045e9:	8b 50 48             	mov    0x48(%eax),%edx
f01045ec:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01045f2:	eb 05                	jmp    f01045f9 <sched_yield+0x27>
f01045f4:	ba 00 00 00 00       	mov    $0x0,%edx
    int32_t nextid;
    size_t i;

    for(i = 0; i < NENV; i++) {
        nextid = (startid+i)%NENV;
        if(envs[nextid].env_status == ENV_RUNNABLE) {
f01045f9:	8b 0d 48 a2 2a f0    	mov    0xf02aa248,%ecx
f01045ff:	89 d6                	mov    %edx,%esi
f0104601:	8d 9a 00 04 00 00    	lea    0x400(%edx),%ebx
f0104607:	89 d0                	mov    %edx,%eax
f0104609:	25 ff 03 00 00       	and    $0x3ff,%eax
f010460e:	6b c0 7c             	imul   $0x7c,%eax,%eax
f0104611:	01 c8                	add    %ecx,%eax
f0104613:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0104617:	75 09                	jne    f0104622 <sched_yield+0x50>
                env_run(&envs[nextid]);
f0104619:	83 ec 0c             	sub    $0xc,%esp
f010461c:	50                   	push   %eax
f010461d:	e8 e8 f0 ff ff       	call   f010370a <env_run>
f0104622:	83 c2 01             	add    $0x1,%edx
	struct Env *now = thiscpu->cpu_env;
    int32_t startid = (now) ? ENVX(now->env_id): 0;
    int32_t nextid;
    size_t i;

    for(i = 0; i < NENV; i++) {
f0104625:	39 da                	cmp    %ebx,%edx
f0104627:	75 de                	jne    f0104607 <sched_yield+0x35>
                env_run(&envs[nextid]);
                return;
            }
    }
    
    if(envs[startid].env_status == ENV_RUNNING && envs[startid].env_cpunum == cpunum()) {
f0104629:	6b f6 7c             	imul   $0x7c,%esi,%esi
f010462c:	01 f1                	add    %esi,%ecx
f010462e:	83 79 54 03          	cmpl   $0x3,0x54(%ecx)
f0104632:	75 1b                	jne    f010464f <sched_yield+0x7d>
f0104634:	8b 59 5c             	mov    0x5c(%ecx),%ebx
f0104637:	e8 9a 17 00 00       	call   f0105dd6 <cpunum>
f010463c:	39 c3                	cmp    %eax,%ebx
f010463e:	75 0f                	jne    f010464f <sched_yield+0x7d>
        env_run(&envs[startid]);
f0104640:	83 ec 0c             	sub    $0xc,%esp
f0104643:	03 35 48 a2 2a f0    	add    0xf02aa248,%esi
f0104649:	56                   	push   %esi
f010464a:	e8 bb f0 ff ff       	call   f010370a <env_run>
    }

	// cprintf("[halt]\n");

	// sched_halt never returns
	sched_halt();
f010464f:	e8 aa fe ff ff       	call   f01044fe <sched_halt>
}
f0104654:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104657:	5b                   	pop    %ebx
f0104658:	5e                   	pop    %esi
f0104659:	5d                   	pop    %ebp
f010465a:	c3                   	ret    

f010465b <sys_e1000_try_send>:

}

int 
sys_e1000_try_send(void *buf, uint32_t len)
{
f010465b:	55                   	push   %ebp
f010465c:	89 e5                	mov    %esp,%ebp
f010465e:	56                   	push   %esi
f010465f:	53                   	push   %ebx
f0104660:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104663:	8b 75 0c             	mov    0xc(%ebp),%esi
    user_mem_assert(curenv, buf, len, 0);
f0104666:	e8 6b 17 00 00       	call   f0105dd6 <cpunum>
f010466b:	6a 00                	push   $0x0
f010466d:	56                   	push   %esi
f010466e:	53                   	push   %ebx
f010466f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104672:	ff b0 28 b0 2a f0    	pushl  -0xfd54fd8(%eax)
f0104678:	e8 cb e9 ff ff       	call   f0103048 <user_mem_assert>
    return e1000_transmit(buf, len);
f010467d:	83 c4 08             	add    $0x8,%esp
f0104680:	56                   	push   %esi
f0104681:	53                   	push   %ebx
f0104682:	e8 d1 1c 00 00       	call   f0106358 <e1000_transmit>
}
f0104687:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010468a:	5b                   	pop    %ebx
f010468b:	5e                   	pop    %esi
f010468c:	5d                   	pop    %ebp
f010468d:	c3                   	ret    

f010468e <syscall>:


// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f010468e:	55                   	push   %ebp
f010468f:	89 e5                	mov    %esp,%ebp
f0104691:	57                   	push   %edi
f0104692:	56                   	push   %esi
f0104693:	53                   	push   %ebx
f0104694:	83 ec 1c             	sub    $0x1c,%esp
f0104697:	8b 45 08             	mov    0x8(%ebp),%eax
	// Return any appropriate return value.
	// LAB 3: Your code here.

	// panic("syscall not implemented");

	switch (syscallno) {
f010469a:	83 f8 0f             	cmp    $0xf,%eax
f010469d:	0f 87 75 05 00 00    	ja     f0104c18 <syscall+0x58a>
f01046a3:	ff 24 85 ec 84 10 f0 	jmp    *-0xfef7b14(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, 0);		// just check if PTE_U is set
f01046aa:	e8 27 17 00 00       	call   f0105dd6 <cpunum>
f01046af:	6a 00                	push   $0x0
f01046b1:	ff 75 10             	pushl  0x10(%ebp)
f01046b4:	ff 75 0c             	pushl  0xc(%ebp)
f01046b7:	6b c0 74             	imul   $0x74,%eax,%eax
f01046ba:	ff b0 28 b0 2a f0    	pushl  -0xfd54fd8(%eax)
f01046c0:	e8 83 e9 ff ff       	call   f0103048 <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f01046c5:	83 c4 0c             	add    $0xc,%esp
f01046c8:	ff 75 0c             	pushl  0xc(%ebp)
f01046cb:	ff 75 10             	pushl  0x10(%ebp)
f01046ce:	68 e6 84 10 f0       	push   $0xf01084e6
f01046d3:	e8 aa f2 ff ff       	call   f0103982 <cprintf>
f01046d8:	83 c4 10             	add    $0x10,%esp
	// panic("syscall not implemented");

	switch (syscallno) {
		case SYS_cputs:
			sys_cputs((char *)a1, a2);
			return 0;
f01046db:	bb 00 00 00 00       	mov    $0x0,%ebx
f01046e0:	e9 3f 05 00 00       	jmp    f0104c24 <syscall+0x596>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f01046e5:	e8 12 bf ff ff       	call   f01005fc <cons_getc>
f01046ea:	89 c3                	mov    %eax,%ebx
	switch (syscallno) {
		case SYS_cputs:
			sys_cputs((char *)a1, a2);
			return 0;
		case SYS_cgetc:
			return sys_cgetc();
f01046ec:	e9 33 05 00 00       	jmp    f0104c24 <syscall+0x596>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f01046f1:	e8 e0 16 00 00       	call   f0105dd6 <cpunum>
f01046f6:	6b c0 74             	imul   $0x74,%eax,%eax
f01046f9:	8b 80 28 b0 2a f0    	mov    -0xfd54fd8(%eax),%eax
f01046ff:	8b 58 48             	mov    0x48(%eax),%ebx
			sys_cputs((char *)a1, a2);
			return 0;
		case SYS_cgetc:
			return sys_cgetc();
		case SYS_getenvid:
			return sys_getenvid();
f0104702:	e9 1d 05 00 00       	jmp    f0104c24 <syscall+0x596>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104707:	83 ec 04             	sub    $0x4,%esp
f010470a:	6a 01                	push   $0x1
f010470c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010470f:	50                   	push   %eax
f0104710:	ff 75 0c             	pushl  0xc(%ebp)
f0104713:	e8 fe e9 ff ff       	call   f0103116 <envid2env>
f0104718:	83 c4 10             	add    $0x10,%esp
		return r;
f010471b:	89 c3                	mov    %eax,%ebx
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f010471d:	85 c0                	test   %eax,%eax
f010471f:	0f 88 ff 04 00 00    	js     f0104c24 <syscall+0x596>
		return r;
	env_destroy(e);
f0104725:	83 ec 0c             	sub    $0xc,%esp
f0104728:	ff 75 e4             	pushl  -0x1c(%ebp)
f010472b:	e8 3b ef ff ff       	call   f010366b <env_destroy>
f0104730:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104733:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104738:	e9 e7 04 00 00       	jmp    f0104c24 <syscall+0x596>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f010473d:	e8 90 fe ff ff       	call   f01045d2 <sched_yield>
	// LAB 4: Your code here.
	// panic("sys_exofork not implemented");

	struct Env *newenv;

	int err = env_alloc(&newenv , curenv->env_id);
f0104742:	e8 8f 16 00 00       	call   f0105dd6 <cpunum>
f0104747:	83 ec 08             	sub    $0x8,%esp
f010474a:	6b c0 74             	imul   $0x74,%eax,%eax
f010474d:	8b 80 28 b0 2a f0    	mov    -0xfd54fd8(%eax),%eax
f0104753:	ff 70 48             	pushl  0x48(%eax)
f0104756:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104759:	50                   	push   %eax
f010475a:	e8 c2 ea ff ff       	call   f0103221 <env_alloc>
	if (err < 0)
f010475f:	83 c4 10             	add    $0x10,%esp
		return err;
f0104762:	89 c3                	mov    %eax,%ebx
	// panic("sys_exofork not implemented");

	struct Env *newenv;

	int err = env_alloc(&newenv , curenv->env_id);
	if (err < 0)
f0104764:	85 c0                	test   %eax,%eax
f0104766:	0f 88 b8 04 00 00    	js     f0104c24 <syscall+0x596>
		return err;

	// memcpy(&newenv->env_tf, &curenv->env_tf, sizeof(struct Trapframe));
	newenv->env_tf = curenv->env_tf;
f010476c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010476f:	e8 62 16 00 00       	call   f0105dd6 <cpunum>
f0104774:	6b c0 74             	imul   $0x74,%eax,%eax
f0104777:	8b b0 28 b0 2a f0    	mov    -0xfd54fd8(%eax),%esi
f010477d:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104782:	89 df                	mov    %ebx,%edi
f0104784:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	newenv->env_status = ENV_NOT_RUNNABLE;
f0104786:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104789:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)

	// tweak newenv, to make it appear to return 0
	newenv->env_tf.tf_regs.reg_eax = 0;
f0104790:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

	return newenv->env_id;
f0104797:	8b 58 48             	mov    0x48(%eax),%ebx
f010479a:	e9 85 04 00 00       	jmp    f0104c24 <syscall+0x596>

	// LAB 4: Your code here.
	// panic("sys_env_set_status not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
f010479f:	83 ec 04             	sub    $0x4,%esp
f01047a2:	6a 01                	push   $0x1
f01047a4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01047a7:	50                   	push   %eax
f01047a8:	ff 75 0c             	pushl  0xc(%ebp)
f01047ab:	e8 66 e9 ff ff       	call   f0103116 <envid2env>
	if (err < 0)
f01047b0:	83 c4 10             	add    $0x10,%esp
f01047b3:	85 c0                	test   %eax,%eax
f01047b5:	78 20                	js     f01047d7 <syscall+0x149>
		return err;

	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
f01047b7:	8b 45 10             	mov    0x10(%ebp),%eax
f01047ba:	83 e8 02             	sub    $0x2,%eax
f01047bd:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f01047c2:	75 1a                	jne    f01047de <syscall+0x150>
		return -E_INVAL;

	env_store->env_status = status;
f01047c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01047c7:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01047ca:	89 48 54             	mov    %ecx,0x54(%eax)

	return 0;
f01047cd:	bb 00 00 00 00       	mov    $0x0,%ebx
f01047d2:	e9 4d 04 00 00       	jmp    f0104c24 <syscall+0x596>
	// panic("sys_env_set_status not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
	if (err < 0)
		return err;
f01047d7:	89 c3                	mov    %eax,%ebx
f01047d9:	e9 46 04 00 00       	jmp    f0104c24 <syscall+0x596>

	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
		return -E_INVAL;
f01047de:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			sys_yield();
			return 0;
		case SYS_exofork:
			return sys_exofork();
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1, a2);
f01047e3:	e9 3c 04 00 00       	jmp    f0104c24 <syscall+0x596>

	// LAB 4: Your code here.
	// panic("sys_page_alloc not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
f01047e8:	83 ec 04             	sub    $0x4,%esp
f01047eb:	6a 01                	push   $0x1
f01047ed:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01047f0:	50                   	push   %eax
f01047f1:	ff 75 0c             	pushl  0xc(%ebp)
f01047f4:	e8 1d e9 ff ff       	call   f0103116 <envid2env>
	if (err < 0)
f01047f9:	83 c4 10             	add    $0x10,%esp
f01047fc:	85 c0                	test   %eax,%eax
f01047fe:	78 6b                	js     f010486b <syscall+0x1dd>
		return err;	// E_BAD_ENV

	if ((perm | PTE_AVAIL | PTE_W) != (PTE_AVAIL | PTE_W | PTE_U | PTE_P))
		return -E_INVAL;

	if ((uint32_t)va >= UTOP || ((uint32_t) va % PGSIZE) != 0)
f0104800:	8b 45 14             	mov    0x14(%ebp),%eax
f0104803:	0d 02 0e 00 00       	or     $0xe02,%eax
f0104808:	3d 07 0e 00 00       	cmp    $0xe07,%eax
f010480d:	75 63                	jne    f0104872 <syscall+0x1e4>
f010480f:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104816:	77 5a                	ja     f0104872 <syscall+0x1e4>
f0104818:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010481f:	75 5b                	jne    f010487c <syscall+0x1ee>
		return -E_INVAL;
	
	struct PageInfo * pp = page_alloc(ALLOC_ZERO);
f0104821:	83 ec 0c             	sub    $0xc,%esp
f0104824:	6a 01                	push   $0x1
f0104826:	e8 66 c8 ff ff       	call   f0101091 <page_alloc>
f010482b:	89 c6                	mov    %eax,%esi
	if (pp == NULL)
f010482d:	83 c4 10             	add    $0x10,%esp
f0104830:	85 c0                	test   %eax,%eax
f0104832:	74 52                	je     f0104886 <syscall+0x1f8>
		return -E_NO_MEM;
	
	err = page_insert(env_store->env_pgdir, pp, va, perm);
f0104834:	ff 75 14             	pushl  0x14(%ebp)
f0104837:	ff 75 10             	pushl  0x10(%ebp)
f010483a:	50                   	push   %eax
f010483b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010483e:	ff 70 60             	pushl  0x60(%eax)
f0104841:	e8 3e cc ff ff       	call   f0101484 <page_insert>
f0104846:	89 c7                	mov    %eax,%edi
	if (err < 0) {
f0104848:	83 c4 10             	add    $0x10,%esp
		page_free(pp);
		return err; // E_NO_MEM
	}

	return 0;
f010484b:	bb 00 00 00 00       	mov    $0x0,%ebx
	struct PageInfo * pp = page_alloc(ALLOC_ZERO);
	if (pp == NULL)
		return -E_NO_MEM;
	
	err = page_insert(env_store->env_pgdir, pp, va, perm);
	if (err < 0) {
f0104850:	85 c0                	test   %eax,%eax
f0104852:	0f 89 cc 03 00 00    	jns    f0104c24 <syscall+0x596>
		page_free(pp);
f0104858:	83 ec 0c             	sub    $0xc,%esp
f010485b:	56                   	push   %esi
f010485c:	e8 a1 c8 ff ff       	call   f0101102 <page_free>
f0104861:	83 c4 10             	add    $0x10,%esp
		return err; // E_NO_MEM
f0104864:	89 fb                	mov    %edi,%ebx
f0104866:	e9 b9 03 00 00       	jmp    f0104c24 <syscall+0x596>
	// panic("sys_page_alloc not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
	if (err < 0)
		return err;	// E_BAD_ENV
f010486b:	89 c3                	mov    %eax,%ebx
f010486d:	e9 b2 03 00 00       	jmp    f0104c24 <syscall+0x596>

	if ((perm | PTE_AVAIL | PTE_W) != (PTE_AVAIL | PTE_W | PTE_U | PTE_P))
		return -E_INVAL;

	if ((uint32_t)va >= UTOP || ((uint32_t) va % PGSIZE) != 0)
		return -E_INVAL;
f0104872:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104877:	e9 a8 03 00 00       	jmp    f0104c24 <syscall+0x596>
f010487c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104881:	e9 9e 03 00 00       	jmp    f0104c24 <syscall+0x596>
	
	struct PageInfo * pp = page_alloc(ALLOC_ZERO);
	if (pp == NULL)
		return -E_NO_MEM;
f0104886:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f010488b:	e9 94 03 00 00       	jmp    f0104c24 <syscall+0x596>
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	// panic("sys_page_map not implemented");

	if ((uint32_t)srcva >= UTOP || ((uint32_t)srcva % PGSIZE) != 0 || (uint32_t)dstva >= UTOP || ((uint32_t)dstva % PGSIZE != 0))
f0104890:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104897:	0f 87 c2 00 00 00    	ja     f010495f <syscall+0x2d1>
f010489d:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01048a4:	0f 85 bf 00 00 00    	jne    f0104969 <syscall+0x2db>
f01048aa:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f01048b1:	0f 87 b2 00 00 00    	ja     f0104969 <syscall+0x2db>
f01048b7:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f01048be:	0f 85 af 00 00 00    	jne    f0104973 <syscall+0x2e5>
		return -E_INVAL;
	
	struct Env *srcenv, *dstenv;
	int err = envid2env(srcenvid, &srcenv, 1);
f01048c4:	83 ec 04             	sub    $0x4,%esp
f01048c7:	6a 01                	push   $0x1
f01048c9:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01048cc:	50                   	push   %eax
f01048cd:	ff 75 0c             	pushl  0xc(%ebp)
f01048d0:	e8 41 e8 ff ff       	call   f0103116 <envid2env>
	if(err < 0)
f01048d5:	83 c4 10             	add    $0x10,%esp
		return err;	// E_BAD_ENV
f01048d8:	89 c3                	mov    %eax,%ebx
	if ((uint32_t)srcva >= UTOP || ((uint32_t)srcva % PGSIZE) != 0 || (uint32_t)dstva >= UTOP || ((uint32_t)dstva % PGSIZE != 0))
		return -E_INVAL;
	
	struct Env *srcenv, *dstenv;
	int err = envid2env(srcenvid, &srcenv, 1);
	if(err < 0)
f01048da:	85 c0                	test   %eax,%eax
f01048dc:	0f 88 42 03 00 00    	js     f0104c24 <syscall+0x596>
		return err;	// E_BAD_ENV
	err = envid2env(dstenvid, &dstenv, 1);
f01048e2:	83 ec 04             	sub    $0x4,%esp
f01048e5:	6a 01                	push   $0x1
f01048e7:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01048ea:	50                   	push   %eax
f01048eb:	ff 75 14             	pushl  0x14(%ebp)
f01048ee:	e8 23 e8 ff ff       	call   f0103116 <envid2env>
	if(err < 0)
f01048f3:	83 c4 10             	add    $0x10,%esp
		return err;	// E_BAD_ENV
f01048f6:	89 c3                	mov    %eax,%ebx
	struct Env *srcenv, *dstenv;
	int err = envid2env(srcenvid, &srcenv, 1);
	if(err < 0)
		return err;	// E_BAD_ENV
	err = envid2env(dstenvid, &dstenv, 1);
	if(err < 0)
f01048f8:	85 c0                	test   %eax,%eax
f01048fa:	0f 88 24 03 00 00    	js     f0104c24 <syscall+0x596>
		return err;	// E_BAD_ENV

	pte_t *pte;
	struct PageInfo *pp = page_lookup(srcenv->env_pgdir, srcva, &pte);
f0104900:	83 ec 04             	sub    $0x4,%esp
f0104903:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104906:	50                   	push   %eax
f0104907:	ff 75 10             	pushl  0x10(%ebp)
f010490a:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010490d:	ff 70 60             	pushl  0x60(%eax)
f0104910:	e8 87 ca ff ff       	call   f010139c <page_lookup>
	if (pp == NULL) 
f0104915:	83 c4 10             	add    $0x10,%esp
f0104918:	85 c0                	test   %eax,%eax
f010491a:	74 61                	je     f010497d <syscall+0x2ef>
		return -E_INVAL;	// not mapped
	
	if ( ((*pte) & PTE_W) == 0 && (perm & PTE_W) != 0)
f010491c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010491f:	f6 02 02             	testb  $0x2,(%edx)
f0104922:	75 06                	jne    f010492a <syscall+0x29c>
f0104924:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104928:	75 5d                	jne    f0104987 <syscall+0x2f9>
		return -E_INVAL;	// read-only page

	// same perm restrictions as in sys_page_alloc
	if ((perm | PTE_AVAIL | PTE_W) != (PTE_AVAIL | PTE_W | PTE_U | PTE_P))
f010492a:	8b 55 1c             	mov    0x1c(%ebp),%edx
f010492d:	81 ca 02 0e 00 00    	or     $0xe02,%edx
f0104933:	81 fa 07 0e 00 00    	cmp    $0xe07,%edx
f0104939:	75 56                	jne    f0104991 <syscall+0x303>
		return -E_INVAL;

	err = page_insert(dstenv->env_pgdir, pp, dstva, perm);
f010493b:	ff 75 1c             	pushl  0x1c(%ebp)
f010493e:	ff 75 18             	pushl  0x18(%ebp)
f0104941:	50                   	push   %eax
f0104942:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104945:	ff 70 60             	pushl  0x60(%eax)
f0104948:	e8 37 cb ff ff       	call   f0101484 <page_insert>
f010494d:	83 c4 10             	add    $0x10,%esp
f0104950:	85 c0                	test   %eax,%eax
f0104952:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104957:	0f 4e d8             	cmovle %eax,%ebx
f010495a:	e9 c5 02 00 00       	jmp    f0104c24 <syscall+0x596>

	// LAB 4: Your code here.
	// panic("sys_page_map not implemented");

	if ((uint32_t)srcva >= UTOP || ((uint32_t)srcva % PGSIZE) != 0 || (uint32_t)dstva >= UTOP || ((uint32_t)dstva % PGSIZE != 0))
		return -E_INVAL;
f010495f:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104964:	e9 bb 02 00 00       	jmp    f0104c24 <syscall+0x596>
f0104969:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010496e:	e9 b1 02 00 00       	jmp    f0104c24 <syscall+0x596>
f0104973:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104978:	e9 a7 02 00 00       	jmp    f0104c24 <syscall+0x596>
		return err;	// E_BAD_ENV

	pte_t *pte;
	struct PageInfo *pp = page_lookup(srcenv->env_pgdir, srcva, &pte);
	if (pp == NULL) 
		return -E_INVAL;	// not mapped
f010497d:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104982:	e9 9d 02 00 00       	jmp    f0104c24 <syscall+0x596>
	
	if ( ((*pte) & PTE_W) == 0 && (perm & PTE_W) != 0)
		return -E_INVAL;	// read-only page
f0104987:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010498c:	e9 93 02 00 00       	jmp    f0104c24 <syscall+0x596>

	// same perm restrictions as in sys_page_alloc
	if ((perm | PTE_AVAIL | PTE_W) != (PTE_AVAIL | PTE_W | PTE_U | PTE_P))
		return -E_INVAL;
f0104991:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1, a2);
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1, (void *)a2, a3);
		case SYS_page_map:
			return sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4, a5);
f0104996:	e9 89 02 00 00       	jmp    f0104c24 <syscall+0x596>
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	// panic("sys_page_unmap not implemented");

	if ((uint32_t)va >= UTOP || ((uint32_t) va % PGSIZE) != 0)
f010499b:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01049a2:	77 45                	ja     f01049e9 <syscall+0x35b>
f01049a4:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01049ab:	75 46                	jne    f01049f3 <syscall+0x365>
		return -E_INVAL;

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
f01049ad:	83 ec 04             	sub    $0x4,%esp
f01049b0:	6a 01                	push   $0x1
f01049b2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01049b5:	50                   	push   %eax
f01049b6:	ff 75 0c             	pushl  0xc(%ebp)
f01049b9:	e8 58 e7 ff ff       	call   f0103116 <envid2env>
	if (err < 0)
f01049be:	83 c4 10             	add    $0x10,%esp
		return err;	// E_BAD_ENV
f01049c1:	89 c3                	mov    %eax,%ebx
	if ((uint32_t)va >= UTOP || ((uint32_t) va % PGSIZE) != 0)
		return -E_INVAL;

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
	if (err < 0)
f01049c3:	85 c0                	test   %eax,%eax
f01049c5:	0f 88 59 02 00 00    	js     f0104c24 <syscall+0x596>
		return err;	// E_BAD_ENV

	page_remove(env_store->env_pgdir, va);
f01049cb:	83 ec 08             	sub    $0x8,%esp
f01049ce:	ff 75 10             	pushl  0x10(%ebp)
f01049d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01049d4:	ff 70 60             	pushl  0x60(%eax)
f01049d7:	e8 5b ca ff ff       	call   f0101437 <page_remove>
f01049dc:	83 c4 10             	add    $0x10,%esp

	return 0;
f01049df:	bb 00 00 00 00       	mov    $0x0,%ebx
f01049e4:	e9 3b 02 00 00       	jmp    f0104c24 <syscall+0x596>

	// LAB 4: Your code here.
	// panic("sys_page_unmap not implemented");

	if ((uint32_t)va >= UTOP || ((uint32_t) va % PGSIZE) != 0)
		return -E_INVAL;
f01049e9:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049ee:	e9 31 02 00 00       	jmp    f0104c24 <syscall+0x596>
f01049f3:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049f8:	e9 27 02 00 00       	jmp    f0104c24 <syscall+0x596>
{
	// LAB 4: Your code here.
	// panic("sys_env_set_pgfault_upcall not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
f01049fd:	83 ec 04             	sub    $0x4,%esp
f0104a00:	6a 01                	push   $0x1
f0104a02:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104a05:	50                   	push   %eax
f0104a06:	ff 75 0c             	pushl  0xc(%ebp)
f0104a09:	e8 08 e7 ff ff       	call   f0103116 <envid2env>
	if (err < 0)
f0104a0e:	83 c4 10             	add    $0x10,%esp
f0104a11:	85 c0                	test   %eax,%eax
f0104a13:	78 13                	js     f0104a28 <syscall+0x39a>
		return err;

	env_store->env_pgfault_upcall = func;
f0104a15:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104a18:	8b 55 10             	mov    0x10(%ebp),%edx
f0104a1b:	89 50 64             	mov    %edx,0x64(%eax)

	return 0;
f0104a1e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104a23:	e9 fc 01 00 00       	jmp    f0104c24 <syscall+0x596>
	// panic("sys_env_set_pgfault_upcall not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
	if (err < 0)
		return err;
f0104a28:	89 c3                	mov    %eax,%ebx
		case SYS_page_map:
			return sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4, a5);
		case SYS_page_unmap:
			return sys_page_unmap((envid_t)a1, (void *)a2);
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
f0104a2a:	e9 f5 01 00 00       	jmp    f0104c24 <syscall+0x596>
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	// panic("sys_ipc_recv not implemented");

	if ((uint32_t)dstva < UTOP) {
f0104a2f:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0104a36:	77 21                	ja     f0104a59 <syscall+0x3cb>
		if ((uint32_t)dstva % PGSIZE != 0)
f0104a38:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0104a3f:	0f 85 da 01 00 00    	jne    f0104c1f <syscall+0x591>
			return -E_INVAL;
		curenv->env_ipc_dstva = dstva;
f0104a45:	e8 8c 13 00 00       	call   f0105dd6 <cpunum>
f0104a4a:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a4d:	8b 80 28 b0 2a f0    	mov    -0xfd54fd8(%eax),%eax
f0104a53:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104a56:	89 78 6c             	mov    %edi,0x6c(%eax)
	}

	// set recving flags
	curenv->env_ipc_recving = true;
f0104a59:	e8 78 13 00 00       	call   f0105dd6 <cpunum>
f0104a5e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a61:	8b 80 28 b0 2a f0    	mov    -0xfd54fd8(%eax),%eax
f0104a67:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_from = 0;
f0104a6b:	e8 66 13 00 00       	call   f0105dd6 <cpunum>
f0104a70:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a73:	8b 80 28 b0 2a f0    	mov    -0xfd54fd8(%eax),%eax
f0104a79:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)

	// mark yourself not runnable, and then give up the CPU.
	curenv->env_status = ENV_NOT_RUNNABLE;
f0104a80:	e8 51 13 00 00       	call   f0105dd6 <cpunum>
f0104a85:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a88:	8b 80 28 b0 2a f0    	mov    -0xfd54fd8(%eax),%eax
f0104a8e:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	sched_yield();
f0104a95:	e8 38 fb ff ff       	call   f01045d2 <sched_yield>
{
	// LAB 4: Your code here.
	// panic("sys_ipc_try_send not implemented");

	struct Env *env;
	int err = envid2env(envid, &env, 0);
f0104a9a:	83 ec 04             	sub    $0x4,%esp
f0104a9d:	6a 00                	push   $0x0
f0104a9f:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104aa2:	50                   	push   %eax
f0104aa3:	ff 75 0c             	pushl  0xc(%ebp)
f0104aa6:	e8 6b e6 ff ff       	call   f0103116 <envid2env>
	if(err < 0)
f0104aab:	83 c4 10             	add    $0x10,%esp
f0104aae:	85 c0                	test   %eax,%eax
f0104ab0:	0f 88 02 01 00 00    	js     f0104bb8 <syscall+0x52a>
		return err;	// E_BAD_ENV
	
	// not recving, or already recving
	if (env->env_ipc_recving != true || env->env_ipc_from != 0)
f0104ab6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104ab9:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0104abd:	0f 84 f9 00 00 00    	je     f0104bbc <syscall+0x52e>
f0104ac3:	8b 58 74             	mov    0x74(%eax),%ebx
f0104ac6:	85 db                	test   %ebx,%ebx
f0104ac8:	0f 85 f5 00 00 00    	jne    f0104bc3 <syscall+0x535>

	// first check if the recver is willing to recv a page
	// any error happens, fall fast
	if (env->env_ipc_dstva != 0) {
		
		if ((uint32_t)srcva < UTOP) {
f0104ace:	83 78 6c 00          	cmpl   $0x0,0x6c(%eax)
f0104ad2:	0f 84 ac 00 00 00    	je     f0104b84 <syscall+0x4f6>
f0104ad8:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104adf:	0f 87 9f 00 00 00    	ja     f0104b84 <syscall+0x4f6>
			if ((uint32_t)srcva % PGSIZE != 0)
f0104ae5:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0104aec:	75 64                	jne    f0104b52 <syscall+0x4c4>
				return -E_INVAL;
			if ((perm & (PTE_P | PTE_U)) != (PTE_P | PTE_U))
f0104aee:	8b 45 18             	mov    0x18(%ebp),%eax
f0104af1:	83 e0 05             	and    $0x5,%eax
f0104af4:	83 f8 05             	cmp    $0x5,%eax
f0104af7:	75 63                	jne    f0104b5c <syscall+0x4ce>
            	return -E_INVAL;

			pte_t *pte;
			struct PageInfo *pp = page_lookup(curenv->env_pgdir, srcva, &pte);
f0104af9:	e8 d8 12 00 00       	call   f0105dd6 <cpunum>
f0104afe:	83 ec 04             	sub    $0x4,%esp
f0104b01:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104b04:	52                   	push   %edx
f0104b05:	ff 75 14             	pushl  0x14(%ebp)
f0104b08:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b0b:	8b 80 28 b0 2a f0    	mov    -0xfd54fd8(%eax),%eax
f0104b11:	ff 70 60             	pushl  0x60(%eax)
f0104b14:	e8 83 c8 ff ff       	call   f010139c <page_lookup>
			if (!pp) 
f0104b19:	83 c4 10             	add    $0x10,%esp
f0104b1c:	85 c0                	test   %eax,%eax
f0104b1e:	74 46                	je     f0104b66 <syscall+0x4d8>
				return -E_INVAL;  
			
			if ((perm & PTE_W) && ((size_t) *pte & PTE_W) != PTE_W) 
f0104b20:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104b24:	74 08                	je     f0104b2e <syscall+0x4a0>
f0104b26:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104b29:	f6 02 02             	testb  $0x2,(%edx)
f0104b2c:	74 42                	je     f0104b70 <syscall+0x4e2>
				return -E_INVAL;

			if (page_insert(env->env_pgdir, pp, env->env_ipc_dstva, perm) < 0) 
f0104b2e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104b31:	ff 75 18             	pushl  0x18(%ebp)
f0104b34:	ff 72 6c             	pushl  0x6c(%edx)
f0104b37:	50                   	push   %eax
f0104b38:	ff 72 60             	pushl  0x60(%edx)
f0104b3b:	e8 44 c9 ff ff       	call   f0101484 <page_insert>
f0104b40:	83 c4 10             	add    $0x10,%esp
f0104b43:	85 c0                	test   %eax,%eax
f0104b45:	78 33                	js     f0104b7a <syscall+0x4ec>
				return -E_NO_MEM;
			
			env->env_ipc_perm = perm;
f0104b47:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b4a:	8b 7d 18             	mov    0x18(%ebp),%edi
f0104b4d:	89 78 78             	mov    %edi,0x78(%eax)
f0104b50:	eb 32                	jmp    f0104b84 <syscall+0x4f6>
	// any error happens, fall fast
	if (env->env_ipc_dstva != 0) {
		
		if ((uint32_t)srcva < UTOP) {
			if ((uint32_t)srcva % PGSIZE != 0)
				return -E_INVAL;
f0104b52:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b57:	e9 c8 00 00 00       	jmp    f0104c24 <syscall+0x596>
			if ((perm & (PTE_P | PTE_U)) != (PTE_P | PTE_U))
            	return -E_INVAL;
f0104b5c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b61:	e9 be 00 00 00       	jmp    f0104c24 <syscall+0x596>

			pte_t *pte;
			struct PageInfo *pp = page_lookup(curenv->env_pgdir, srcva, &pte);
			if (!pp) 
				return -E_INVAL;  
f0104b66:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b6b:	e9 b4 00 00 00       	jmp    f0104c24 <syscall+0x596>
			
			if ((perm & PTE_W) && ((size_t) *pte & PTE_W) != PTE_W) 
				return -E_INVAL;
f0104b70:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b75:	e9 aa 00 00 00       	jmp    f0104c24 <syscall+0x596>

			if (page_insert(env->env_pgdir, pp, env->env_ipc_dstva, perm) < 0) 
				return -E_NO_MEM;
f0104b7a:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f0104b7f:	e9 a0 00 00 00       	jmp    f0104c24 <syscall+0x596>
			env->env_ipc_perm = perm;
		}

	}

	env->env_ipc_from = curenv->env_id;
f0104b84:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104b87:	e8 4a 12 00 00       	call   f0105dd6 <cpunum>
f0104b8c:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b8f:	8b 80 28 b0 2a f0    	mov    -0xfd54fd8(%eax),%eax
f0104b95:	8b 40 48             	mov    0x48(%eax),%eax
f0104b98:	89 46 74             	mov    %eax,0x74(%esi)
	env->env_ipc_recving = false;
f0104b9b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b9e:	c6 40 68 00          	movb   $0x0,0x68(%eax)
	env->env_ipc_value = value;
f0104ba2:	8b 55 10             	mov    0x10(%ebp),%edx
f0104ba5:	89 50 70             	mov    %edx,0x70(%eax)
	env->env_status = ENV_RUNNABLE;
f0104ba8:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)

	// make the recver return 0
	env->env_tf.tf_regs.reg_eax = 0;
f0104baf:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
f0104bb6:	eb 6c                	jmp    f0104c24 <syscall+0x596>
	// panic("sys_ipc_try_send not implemented");

	struct Env *env;
	int err = envid2env(envid, &env, 0);
	if(err < 0)
		return err;	// E_BAD_ENV
f0104bb8:	89 c3                	mov    %eax,%ebx
f0104bba:	eb 68                	jmp    f0104c24 <syscall+0x596>
	
	// not recving, or already recving
	if (env->env_ipc_recving != true || env->env_ipc_from != 0)
		return -E_IPC_NOT_RECV;
f0104bbc:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f0104bc1:	eb 61                	jmp    f0104c24 <syscall+0x596>
f0104bc3:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
		case SYS_ipc_recv:
			return sys_ipc_recv((void *)a1);
		case SYS_ipc_try_send:
			return sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned)a4);
f0104bc8:	eb 5a                	jmp    f0104c24 <syscall+0x596>
		case SYS_env_set_trapframe:
			return sys_env_set_trapframe((envid_t)a1, (struct Trapframe *)a2);
f0104bca:	8b 75 10             	mov    0x10(%ebp),%esi
	// Remember to check whether the user has supplied us with a good
	// address!
	// panic("sys_env_set_trapframe not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
f0104bcd:	83 ec 04             	sub    $0x4,%esp
f0104bd0:	6a 01                	push   $0x1
f0104bd2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104bd5:	50                   	push   %eax
f0104bd6:	ff 75 0c             	pushl  0xc(%ebp)
f0104bd9:	e8 38 e5 ff ff       	call   f0103116 <envid2env>
	if (err < 0)
f0104bde:	83 c4 10             	add    $0x10,%esp
f0104be1:	85 c0                	test   %eax,%eax
f0104be3:	78 11                	js     f0104bf6 <syscall+0x568>
		return err;
	
	env_store->env_tf = *tf;
f0104be5:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104bea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104bed:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

	return 0;
f0104bef:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104bf4:	eb 2e                	jmp    f0104c24 <syscall+0x596>
	// panic("sys_env_set_trapframe not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
	if (err < 0)
		return err;
f0104bf6:	89 c3                	mov    %eax,%ebx
		case SYS_ipc_recv:
			return sys_ipc_recv((void *)a1);
		case SYS_ipc_try_send:
			return sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned)a4);
		case SYS_env_set_trapframe:
			return sys_env_set_trapframe((envid_t)a1, (struct Trapframe *)a2);
f0104bf8:	eb 2a                	jmp    f0104c24 <syscall+0x596>
sys_time_msec(void)
{
	// LAB 6: Your code here.
	// panic("sys_time_msec not implemented");

	return time_msec();
f0104bfa:	e8 2b 1d 00 00       	call   f010692a <time_msec>
f0104bff:	89 c3                	mov    %eax,%ebx
		case SYS_ipc_try_send:
			return sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned)a4);
		case SYS_env_set_trapframe:
			return sys_env_set_trapframe((envid_t)a1, (struct Trapframe *)a2);
		case SYS_time_msec:
			return sys_time_msec();
f0104c01:	eb 21                	jmp    f0104c24 <syscall+0x596>
		case SYS_e1000_try_send:
			return sys_e1000_try_send((void *)a1, (uint32_t)a2);
f0104c03:	83 ec 08             	sub    $0x8,%esp
f0104c06:	ff 75 10             	pushl  0x10(%ebp)
f0104c09:	ff 75 0c             	pushl  0xc(%ebp)
f0104c0c:	e8 4a fa ff ff       	call   f010465b <sys_e1000_try_send>
f0104c11:	89 c3                	mov    %eax,%ebx
f0104c13:	83 c4 10             	add    $0x10,%esp
f0104c16:	eb 0c                	jmp    f0104c24 <syscall+0x596>
		default:
			return -E_INVAL;
f0104c18:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104c1d:	eb 05                	jmp    f0104c24 <syscall+0x596>
		case SYS_page_unmap:
			return sys_page_unmap((envid_t)a1, (void *)a2);
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
		case SYS_ipc_recv:
			return sys_ipc_recv((void *)a1);
f0104c1f:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		case SYS_e1000_try_send:
			return sys_e1000_try_send((void *)a1, (uint32_t)a2);
		default:
			return -E_INVAL;
	}
}
f0104c24:	89 d8                	mov    %ebx,%eax
f0104c26:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104c29:	5b                   	pop    %ebx
f0104c2a:	5e                   	pop    %esi
f0104c2b:	5f                   	pop    %edi
f0104c2c:	5d                   	pop    %ebp
f0104c2d:	c3                   	ret    

f0104c2e <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104c2e:	55                   	push   %ebp
f0104c2f:	89 e5                	mov    %esp,%ebp
f0104c31:	57                   	push   %edi
f0104c32:	56                   	push   %esi
f0104c33:	53                   	push   %ebx
f0104c34:	83 ec 14             	sub    $0x14,%esp
f0104c37:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104c3a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104c3d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104c40:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104c43:	8b 1a                	mov    (%edx),%ebx
f0104c45:	8b 01                	mov    (%ecx),%eax
f0104c47:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104c4a:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104c51:	eb 7f                	jmp    f0104cd2 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0104c53:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104c56:	01 d8                	add    %ebx,%eax
f0104c58:	89 c6                	mov    %eax,%esi
f0104c5a:	c1 ee 1f             	shr    $0x1f,%esi
f0104c5d:	01 c6                	add    %eax,%esi
f0104c5f:	d1 fe                	sar    %esi
f0104c61:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0104c64:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104c67:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104c6a:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104c6c:	eb 03                	jmp    f0104c71 <stab_binsearch+0x43>
			m--;
f0104c6e:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104c71:	39 c3                	cmp    %eax,%ebx
f0104c73:	7f 0d                	jg     f0104c82 <stab_binsearch+0x54>
f0104c75:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104c79:	83 ea 0c             	sub    $0xc,%edx
f0104c7c:	39 f9                	cmp    %edi,%ecx
f0104c7e:	75 ee                	jne    f0104c6e <stab_binsearch+0x40>
f0104c80:	eb 05                	jmp    f0104c87 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104c82:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0104c85:	eb 4b                	jmp    f0104cd2 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104c87:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104c8a:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104c8d:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104c91:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104c94:	76 11                	jbe    f0104ca7 <stab_binsearch+0x79>
			*region_left = m;
f0104c96:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104c99:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104c9b:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104c9e:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104ca5:	eb 2b                	jmp    f0104cd2 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104ca7:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104caa:	73 14                	jae    f0104cc0 <stab_binsearch+0x92>
			*region_right = m - 1;
f0104cac:	83 e8 01             	sub    $0x1,%eax
f0104caf:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104cb2:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104cb5:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104cb7:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104cbe:	eb 12                	jmp    f0104cd2 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104cc0:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104cc3:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0104cc5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104cc9:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104ccb:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104cd2:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104cd5:	0f 8e 78 ff ff ff    	jle    f0104c53 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104cdb:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104cdf:	75 0f                	jne    f0104cf0 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0104ce1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104ce4:	8b 00                	mov    (%eax),%eax
f0104ce6:	83 e8 01             	sub    $0x1,%eax
f0104ce9:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104cec:	89 06                	mov    %eax,(%esi)
f0104cee:	eb 2c                	jmp    f0104d1c <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104cf0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104cf3:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104cf5:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104cf8:	8b 0e                	mov    (%esi),%ecx
f0104cfa:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104cfd:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104d00:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104d03:	eb 03                	jmp    f0104d08 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0104d05:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104d08:	39 c8                	cmp    %ecx,%eax
f0104d0a:	7e 0b                	jle    f0104d17 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0104d0c:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0104d10:	83 ea 0c             	sub    $0xc,%edx
f0104d13:	39 df                	cmp    %ebx,%edi
f0104d15:	75 ee                	jne    f0104d05 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0104d17:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104d1a:	89 06                	mov    %eax,(%esi)
	}
}
f0104d1c:	83 c4 14             	add    $0x14,%esp
f0104d1f:	5b                   	pop    %ebx
f0104d20:	5e                   	pop    %esi
f0104d21:	5f                   	pop    %edi
f0104d22:	5d                   	pop    %ebp
f0104d23:	c3                   	ret    

f0104d24 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104d24:	55                   	push   %ebp
f0104d25:	89 e5                	mov    %esp,%ebp
f0104d27:	57                   	push   %edi
f0104d28:	56                   	push   %esi
f0104d29:	53                   	push   %ebx
f0104d2a:	83 ec 3c             	sub    $0x3c,%esp
f0104d2d:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104d30:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104d33:	c7 03 2c 85 10 f0    	movl   $0xf010852c,(%ebx)
	info->eip_line = 0;
f0104d39:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104d40:	c7 43 08 2c 85 10 f0 	movl   $0xf010852c,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104d47:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104d4e:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104d51:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104d58:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0104d5e:	0f 87 a3 00 00 00    	ja     f0104e07 <debuginfo_eip+0xe3>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0104d64:	a1 00 00 20 00       	mov    0x200000,%eax
f0104d69:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stab_end = usd->stab_end;
f0104d6c:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f0104d72:	8b 15 08 00 20 00    	mov    0x200008,%edx
f0104d78:	89 55 b8             	mov    %edx,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f0104d7b:	a1 0c 00 20 00       	mov    0x20000c,%eax
f0104d80:	89 45 bc             	mov    %eax,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0 ||
f0104d83:	e8 4e 10 00 00       	call   f0105dd6 <cpunum>
f0104d88:	6a 04                	push   $0x4
f0104d8a:	6a 10                	push   $0x10
f0104d8c:	68 00 00 20 00       	push   $0x200000
f0104d91:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d94:	ff b0 28 b0 2a f0    	pushl  -0xfd54fd8(%eax)
f0104d9a:	e8 c1 e1 ff ff       	call   f0102f60 <user_mem_check>
f0104d9f:	83 c4 10             	add    $0x10,%esp
f0104da2:	85 c0                	test   %eax,%eax
f0104da4:	0f 88 27 02 00 00    	js     f0104fd1 <debuginfo_eip+0x2ad>
			user_mem_check(curenv, stabs, stab_end-stabs, PTE_U) < 0 ||
f0104daa:	e8 27 10 00 00       	call   f0105dd6 <cpunum>
f0104daf:	6a 04                	push   $0x4
f0104db1:	89 f2                	mov    %esi,%edx
f0104db3:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104db6:	29 ca                	sub    %ecx,%edx
f0104db8:	c1 fa 02             	sar    $0x2,%edx
f0104dbb:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0104dc1:	52                   	push   %edx
f0104dc2:	51                   	push   %ecx
f0104dc3:	6b c0 74             	imul   $0x74,%eax,%eax
f0104dc6:	ff b0 28 b0 2a f0    	pushl  -0xfd54fd8(%eax)
f0104dcc:	e8 8f e1 ff ff       	call   f0102f60 <user_mem_check>
		stabstr = usd->stabstr;
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0 ||
f0104dd1:	83 c4 10             	add    $0x10,%esp
f0104dd4:	85 c0                	test   %eax,%eax
f0104dd6:	0f 88 fc 01 00 00    	js     f0104fd8 <debuginfo_eip+0x2b4>
			user_mem_check(curenv, stabs, stab_end-stabs, PTE_U) < 0 ||
			user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U) < 0
f0104ddc:	e8 f5 0f 00 00       	call   f0105dd6 <cpunum>
f0104de1:	6a 04                	push   $0x4
f0104de3:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0104de6:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0104de9:	29 ca                	sub    %ecx,%edx
f0104deb:	52                   	push   %edx
f0104dec:	51                   	push   %ecx
f0104ded:	6b c0 74             	imul   $0x74,%eax,%eax
f0104df0:	ff b0 28 b0 2a f0    	pushl  -0xfd54fd8(%eax)
f0104df6:	e8 65 e1 ff ff       	call   f0102f60 <user_mem_check>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0 ||
			user_mem_check(curenv, stabs, stab_end-stabs, PTE_U) < 0 ||
f0104dfb:	83 c4 10             	add    $0x10,%esp
f0104dfe:	85 c0                	test   %eax,%eax
f0104e00:	79 1f                	jns    f0104e21 <debuginfo_eip+0xfd>
f0104e02:	e9 d8 01 00 00       	jmp    f0104fdf <debuginfo_eip+0x2bb>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104e07:	c7 45 bc b6 89 11 f0 	movl   $0xf01189b6,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0104e0e:	c7 45 b8 49 45 11 f0 	movl   $0xf0114549,-0x48(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0104e15:	be 48 45 11 f0       	mov    $0xf0114548,%esi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104e1a:	c7 45 c0 34 8d 10 f0 	movl   $0xf0108d34,-0x40(%ebp)
		)
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104e21:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104e24:	39 45 b8             	cmp    %eax,-0x48(%ebp)
f0104e27:	0f 83 b9 01 00 00    	jae    f0104fe6 <debuginfo_eip+0x2c2>
f0104e2d:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0104e31:	0f 85 b6 01 00 00    	jne    f0104fed <debuginfo_eip+0x2c9>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104e37:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104e3e:	2b 75 c0             	sub    -0x40(%ebp),%esi
f0104e41:	c1 fe 02             	sar    $0x2,%esi
f0104e44:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f0104e4a:	83 e8 01             	sub    $0x1,%eax
f0104e4d:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104e50:	83 ec 08             	sub    $0x8,%esp
f0104e53:	57                   	push   %edi
f0104e54:	6a 64                	push   $0x64
f0104e56:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0104e59:	89 d1                	mov    %edx,%ecx
f0104e5b:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104e5e:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0104e61:	89 f0                	mov    %esi,%eax
f0104e63:	e8 c6 fd ff ff       	call   f0104c2e <stab_binsearch>
	if (lfile == 0)
f0104e68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e6b:	83 c4 10             	add    $0x10,%esp
f0104e6e:	85 c0                	test   %eax,%eax
f0104e70:	0f 84 7e 01 00 00    	je     f0104ff4 <debuginfo_eip+0x2d0>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104e76:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104e79:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104e7c:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104e7f:	83 ec 08             	sub    $0x8,%esp
f0104e82:	57                   	push   %edi
f0104e83:	6a 24                	push   $0x24
f0104e85:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0104e88:	89 d1                	mov    %edx,%ecx
f0104e8a:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104e8d:	89 f0                	mov    %esi,%eax
f0104e8f:	e8 9a fd ff ff       	call   f0104c2e <stab_binsearch>

	if (lfun <= rfun) {
f0104e94:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104e97:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104e9a:	83 c4 10             	add    $0x10,%esp
f0104e9d:	39 d0                	cmp    %edx,%eax
f0104e9f:	7f 2e                	jg     f0104ecf <debuginfo_eip+0x1ab>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104ea1:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0104ea4:	8d 34 8e             	lea    (%esi,%ecx,4),%esi
f0104ea7:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f0104eaa:	8b 36                	mov    (%esi),%esi
f0104eac:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0104eaf:	2b 4d b8             	sub    -0x48(%ebp),%ecx
f0104eb2:	39 ce                	cmp    %ecx,%esi
f0104eb4:	73 06                	jae    f0104ebc <debuginfo_eip+0x198>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104eb6:	03 75 b8             	add    -0x48(%ebp),%esi
f0104eb9:	89 73 08             	mov    %esi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104ebc:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0104ebf:	8b 4e 08             	mov    0x8(%esi),%ecx
f0104ec2:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0104ec5:	29 cf                	sub    %ecx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0104ec7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104eca:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0104ecd:	eb 0f                	jmp    f0104ede <debuginfo_eip+0x1ba>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104ecf:	89 7b 10             	mov    %edi,0x10(%ebx)
		lline = lfile;
f0104ed2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104ed5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104ed8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104edb:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104ede:	83 ec 08             	sub    $0x8,%esp
f0104ee1:	6a 3a                	push   $0x3a
f0104ee3:	ff 73 08             	pushl  0x8(%ebx)
f0104ee6:	e8 af 08 00 00       	call   f010579a <strfind>
f0104eeb:	2b 43 08             	sub    0x8(%ebx),%eax
f0104eee:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.


	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104ef1:	83 c4 08             	add    $0x8,%esp
f0104ef4:	57                   	push   %edi
f0104ef5:	6a 44                	push   $0x44
f0104ef7:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104efa:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104efd:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0104f00:	89 f0                	mov    %esi,%eax
f0104f02:	e8 27 fd ff ff       	call   f0104c2e <stab_binsearch>
	if (lline == 0)
f0104f07:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0104f0a:	83 c4 10             	add    $0x10,%esp
f0104f0d:	85 d2                	test   %edx,%edx
f0104f0f:	0f 84 e6 00 00 00    	je     f0104ffb <debuginfo_eip+0x2d7>
		return -1;
	// cprintf("[+] %d, %d, %d, %x\n", lline, rline, lfun, stabs[lfun].n_value);
	info->eip_line = stabs[rline].n_desc;
f0104f15:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104f18:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104f1b:	0f b7 44 86 06       	movzwl 0x6(%esi,%eax,4),%eax
f0104f20:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104f23:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104f26:	89 d0                	mov    %edx,%eax
f0104f28:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104f2b:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0104f2e:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0104f32:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104f35:	eb 0a                	jmp    f0104f41 <debuginfo_eip+0x21d>
f0104f37:	83 e8 01             	sub    $0x1,%eax
f0104f3a:	83 ea 0c             	sub    $0xc,%edx
f0104f3d:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0104f41:	39 c7                	cmp    %eax,%edi
f0104f43:	7e 05                	jle    f0104f4a <debuginfo_eip+0x226>
f0104f45:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104f48:	eb 47                	jmp    f0104f91 <debuginfo_eip+0x26d>
	       && stabs[lline].n_type != N_SOL
f0104f4a:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104f4e:	80 f9 84             	cmp    $0x84,%cl
f0104f51:	75 0e                	jne    f0104f61 <debuginfo_eip+0x23d>
f0104f53:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104f56:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104f5a:	74 1c                	je     f0104f78 <debuginfo_eip+0x254>
f0104f5c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104f5f:	eb 17                	jmp    f0104f78 <debuginfo_eip+0x254>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104f61:	80 f9 64             	cmp    $0x64,%cl
f0104f64:	75 d1                	jne    f0104f37 <debuginfo_eip+0x213>
f0104f66:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0104f6a:	74 cb                	je     f0104f37 <debuginfo_eip+0x213>
f0104f6c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104f6f:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104f73:	74 03                	je     f0104f78 <debuginfo_eip+0x254>
f0104f75:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104f78:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104f7b:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104f7e:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0104f81:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104f84:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0104f87:	29 f8                	sub    %edi,%eax
f0104f89:	39 c2                	cmp    %eax,%edx
f0104f8b:	73 04                	jae    f0104f91 <debuginfo_eip+0x26d>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104f8d:	01 fa                	add    %edi,%edx
f0104f8f:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104f91:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104f94:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104f97:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104f9c:	39 f2                	cmp    %esi,%edx
f0104f9e:	7d 67                	jge    f0105007 <debuginfo_eip+0x2e3>
		for (lline = lfun + 1;
f0104fa0:	83 c2 01             	add    $0x1,%edx
f0104fa3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104fa6:	89 d0                	mov    %edx,%eax
f0104fa8:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104fab:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104fae:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0104fb1:	eb 04                	jmp    f0104fb7 <debuginfo_eip+0x293>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104fb3:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104fb7:	39 c6                	cmp    %eax,%esi
f0104fb9:	7e 47                	jle    f0105002 <debuginfo_eip+0x2de>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104fbb:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104fbf:	83 c0 01             	add    $0x1,%eax
f0104fc2:	83 c2 0c             	add    $0xc,%edx
f0104fc5:	80 f9 a0             	cmp    $0xa0,%cl
f0104fc8:	74 e9                	je     f0104fb3 <debuginfo_eip+0x28f>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104fca:	b8 00 00 00 00       	mov    $0x0,%eax
f0104fcf:	eb 36                	jmp    f0105007 <debuginfo_eip+0x2e3>
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0 ||
			user_mem_check(curenv, stabs, stab_end-stabs, PTE_U) < 0 ||
			user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U) < 0
		)
			return -1;
f0104fd1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104fd6:	eb 2f                	jmp    f0105007 <debuginfo_eip+0x2e3>
f0104fd8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104fdd:	eb 28                	jmp    f0105007 <debuginfo_eip+0x2e3>
f0104fdf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104fe4:	eb 21                	jmp    f0105007 <debuginfo_eip+0x2e3>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104fe6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104feb:	eb 1a                	jmp    f0105007 <debuginfo_eip+0x2e3>
f0104fed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104ff2:	eb 13                	jmp    f0105007 <debuginfo_eip+0x2e3>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0104ff4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104ff9:	eb 0c                	jmp    f0105007 <debuginfo_eip+0x2e3>
	// Your code here.


	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline == 0)
		return -1;
f0104ffb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105000:	eb 05                	jmp    f0105007 <debuginfo_eip+0x2e3>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105002:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105007:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010500a:	5b                   	pop    %ebx
f010500b:	5e                   	pop    %esi
f010500c:	5f                   	pop    %edi
f010500d:	5d                   	pop    %ebp
f010500e:	c3                   	ret    

f010500f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f010500f:	55                   	push   %ebp
f0105010:	89 e5                	mov    %esp,%ebp
f0105012:	57                   	push   %edi
f0105013:	56                   	push   %esi
f0105014:	53                   	push   %ebx
f0105015:	83 ec 1c             	sub    $0x1c,%esp
f0105018:	89 c7                	mov    %eax,%edi
f010501a:	89 d6                	mov    %edx,%esi
f010501c:	8b 45 08             	mov    0x8(%ebp),%eax
f010501f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105022:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105025:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105028:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010502b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105030:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0105033:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0105036:	39 d3                	cmp    %edx,%ebx
f0105038:	72 05                	jb     f010503f <printnum+0x30>
f010503a:	39 45 10             	cmp    %eax,0x10(%ebp)
f010503d:	77 45                	ja     f0105084 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010503f:	83 ec 0c             	sub    $0xc,%esp
f0105042:	ff 75 18             	pushl  0x18(%ebp)
f0105045:	8b 45 14             	mov    0x14(%ebp),%eax
f0105048:	8d 58 ff             	lea    -0x1(%eax),%ebx
f010504b:	53                   	push   %ebx
f010504c:	ff 75 10             	pushl  0x10(%ebp)
f010504f:	83 ec 08             	sub    $0x8,%esp
f0105052:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105055:	ff 75 e0             	pushl  -0x20(%ebp)
f0105058:	ff 75 dc             	pushl  -0x24(%ebp)
f010505b:	ff 75 d8             	pushl  -0x28(%ebp)
f010505e:	e8 dd 18 00 00       	call   f0106940 <__udivdi3>
f0105063:	83 c4 18             	add    $0x18,%esp
f0105066:	52                   	push   %edx
f0105067:	50                   	push   %eax
f0105068:	89 f2                	mov    %esi,%edx
f010506a:	89 f8                	mov    %edi,%eax
f010506c:	e8 9e ff ff ff       	call   f010500f <printnum>
f0105071:	83 c4 20             	add    $0x20,%esp
f0105074:	eb 18                	jmp    f010508e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0105076:	83 ec 08             	sub    $0x8,%esp
f0105079:	56                   	push   %esi
f010507a:	ff 75 18             	pushl  0x18(%ebp)
f010507d:	ff d7                	call   *%edi
f010507f:	83 c4 10             	add    $0x10,%esp
f0105082:	eb 03                	jmp    f0105087 <printnum+0x78>
f0105084:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0105087:	83 eb 01             	sub    $0x1,%ebx
f010508a:	85 db                	test   %ebx,%ebx
f010508c:	7f e8                	jg     f0105076 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010508e:	83 ec 08             	sub    $0x8,%esp
f0105091:	56                   	push   %esi
f0105092:	83 ec 04             	sub    $0x4,%esp
f0105095:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105098:	ff 75 e0             	pushl  -0x20(%ebp)
f010509b:	ff 75 dc             	pushl  -0x24(%ebp)
f010509e:	ff 75 d8             	pushl  -0x28(%ebp)
f01050a1:	e8 ca 19 00 00       	call   f0106a70 <__umoddi3>
f01050a6:	83 c4 14             	add    $0x14,%esp
f01050a9:	0f be 80 36 85 10 f0 	movsbl -0xfef7aca(%eax),%eax
f01050b0:	50                   	push   %eax
f01050b1:	ff d7                	call   *%edi
}
f01050b3:	83 c4 10             	add    $0x10,%esp
f01050b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01050b9:	5b                   	pop    %ebx
f01050ba:	5e                   	pop    %esi
f01050bb:	5f                   	pop    %edi
f01050bc:	5d                   	pop    %ebp
f01050bd:	c3                   	ret    

f01050be <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01050be:	55                   	push   %ebp
f01050bf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01050c1:	83 fa 01             	cmp    $0x1,%edx
f01050c4:	7e 0e                	jle    f01050d4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f01050c6:	8b 10                	mov    (%eax),%edx
f01050c8:	8d 4a 08             	lea    0x8(%edx),%ecx
f01050cb:	89 08                	mov    %ecx,(%eax)
f01050cd:	8b 02                	mov    (%edx),%eax
f01050cf:	8b 52 04             	mov    0x4(%edx),%edx
f01050d2:	eb 22                	jmp    f01050f6 <getuint+0x38>
	else if (lflag)
f01050d4:	85 d2                	test   %edx,%edx
f01050d6:	74 10                	je     f01050e8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f01050d8:	8b 10                	mov    (%eax),%edx
f01050da:	8d 4a 04             	lea    0x4(%edx),%ecx
f01050dd:	89 08                	mov    %ecx,(%eax)
f01050df:	8b 02                	mov    (%edx),%eax
f01050e1:	ba 00 00 00 00       	mov    $0x0,%edx
f01050e6:	eb 0e                	jmp    f01050f6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f01050e8:	8b 10                	mov    (%eax),%edx
f01050ea:	8d 4a 04             	lea    0x4(%edx),%ecx
f01050ed:	89 08                	mov    %ecx,(%eax)
f01050ef:	8b 02                	mov    (%edx),%eax
f01050f1:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01050f6:	5d                   	pop    %ebp
f01050f7:	c3                   	ret    

f01050f8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01050f8:	55                   	push   %ebp
f01050f9:	89 e5                	mov    %esp,%ebp
f01050fb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01050fe:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0105102:	8b 10                	mov    (%eax),%edx
f0105104:	3b 50 04             	cmp    0x4(%eax),%edx
f0105107:	73 0a                	jae    f0105113 <sprintputch+0x1b>
		*b->buf++ = ch;
f0105109:	8d 4a 01             	lea    0x1(%edx),%ecx
f010510c:	89 08                	mov    %ecx,(%eax)
f010510e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105111:	88 02                	mov    %al,(%edx)
}
f0105113:	5d                   	pop    %ebp
f0105114:	c3                   	ret    

f0105115 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0105115:	55                   	push   %ebp
f0105116:	89 e5                	mov    %esp,%ebp
f0105118:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010511b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010511e:	50                   	push   %eax
f010511f:	ff 75 10             	pushl  0x10(%ebp)
f0105122:	ff 75 0c             	pushl  0xc(%ebp)
f0105125:	ff 75 08             	pushl  0x8(%ebp)
f0105128:	e8 05 00 00 00       	call   f0105132 <vprintfmt>
	va_end(ap);
}
f010512d:	83 c4 10             	add    $0x10,%esp
f0105130:	c9                   	leave  
f0105131:	c3                   	ret    

f0105132 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0105132:	55                   	push   %ebp
f0105133:	89 e5                	mov    %esp,%ebp
f0105135:	57                   	push   %edi
f0105136:	56                   	push   %esi
f0105137:	53                   	push   %ebx
f0105138:	83 ec 2c             	sub    $0x2c,%esp
f010513b:	8b 75 08             	mov    0x8(%ebp),%esi
f010513e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105141:	8b 7d 10             	mov    0x10(%ebp),%edi
f0105144:	eb 12                	jmp    f0105158 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0105146:	85 c0                	test   %eax,%eax
f0105148:	0f 84 89 03 00 00    	je     f01054d7 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f010514e:	83 ec 08             	sub    $0x8,%esp
f0105151:	53                   	push   %ebx
f0105152:	50                   	push   %eax
f0105153:	ff d6                	call   *%esi
f0105155:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105158:	83 c7 01             	add    $0x1,%edi
f010515b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f010515f:	83 f8 25             	cmp    $0x25,%eax
f0105162:	75 e2                	jne    f0105146 <vprintfmt+0x14>
f0105164:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0105168:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f010516f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0105176:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f010517d:	ba 00 00 00 00       	mov    $0x0,%edx
f0105182:	eb 07                	jmp    f010518b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105184:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0105187:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010518b:	8d 47 01             	lea    0x1(%edi),%eax
f010518e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105191:	0f b6 07             	movzbl (%edi),%eax
f0105194:	0f b6 c8             	movzbl %al,%ecx
f0105197:	83 e8 23             	sub    $0x23,%eax
f010519a:	3c 55                	cmp    $0x55,%al
f010519c:	0f 87 1a 03 00 00    	ja     f01054bc <vprintfmt+0x38a>
f01051a2:	0f b6 c0             	movzbl %al,%eax
f01051a5:	ff 24 85 80 86 10 f0 	jmp    *-0xfef7980(,%eax,4)
f01051ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01051af:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f01051b3:	eb d6                	jmp    f010518b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01051b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01051b8:	b8 00 00 00 00       	mov    $0x0,%eax
f01051bd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f01051c0:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01051c3:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f01051c7:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f01051ca:	8d 51 d0             	lea    -0x30(%ecx),%edx
f01051cd:	83 fa 09             	cmp    $0x9,%edx
f01051d0:	77 39                	ja     f010520b <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01051d2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f01051d5:	eb e9                	jmp    f01051c0 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01051d7:	8b 45 14             	mov    0x14(%ebp),%eax
f01051da:	8d 48 04             	lea    0x4(%eax),%ecx
f01051dd:	89 4d 14             	mov    %ecx,0x14(%ebp)
f01051e0:	8b 00                	mov    (%eax),%eax
f01051e2:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01051e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f01051e8:	eb 27                	jmp    f0105211 <vprintfmt+0xdf>
f01051ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01051ed:	85 c0                	test   %eax,%eax
f01051ef:	b9 00 00 00 00       	mov    $0x0,%ecx
f01051f4:	0f 49 c8             	cmovns %eax,%ecx
f01051f7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01051fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01051fd:	eb 8c                	jmp    f010518b <vprintfmt+0x59>
f01051ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0105202:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0105209:	eb 80                	jmp    f010518b <vprintfmt+0x59>
f010520b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010520e:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0105211:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105215:	0f 89 70 ff ff ff    	jns    f010518b <vprintfmt+0x59>
				width = precision, precision = -1;
f010521b:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010521e:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105221:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0105228:	e9 5e ff ff ff       	jmp    f010518b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f010522d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105230:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0105233:	e9 53 ff ff ff       	jmp    f010518b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105238:	8b 45 14             	mov    0x14(%ebp),%eax
f010523b:	8d 50 04             	lea    0x4(%eax),%edx
f010523e:	89 55 14             	mov    %edx,0x14(%ebp)
f0105241:	83 ec 08             	sub    $0x8,%esp
f0105244:	53                   	push   %ebx
f0105245:	ff 30                	pushl  (%eax)
f0105247:	ff d6                	call   *%esi
			break;
f0105249:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010524c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f010524f:	e9 04 ff ff ff       	jmp    f0105158 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0105254:	8b 45 14             	mov    0x14(%ebp),%eax
f0105257:	8d 50 04             	lea    0x4(%eax),%edx
f010525a:	89 55 14             	mov    %edx,0x14(%ebp)
f010525d:	8b 00                	mov    (%eax),%eax
f010525f:	99                   	cltd   
f0105260:	31 d0                	xor    %edx,%eax
f0105262:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105264:	83 f8 0f             	cmp    $0xf,%eax
f0105267:	7f 0b                	jg     f0105274 <vprintfmt+0x142>
f0105269:	8b 14 85 e0 87 10 f0 	mov    -0xfef7820(,%eax,4),%edx
f0105270:	85 d2                	test   %edx,%edx
f0105272:	75 18                	jne    f010528c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0105274:	50                   	push   %eax
f0105275:	68 4e 85 10 f0       	push   $0xf010854e
f010527a:	53                   	push   %ebx
f010527b:	56                   	push   %esi
f010527c:	e8 94 fe ff ff       	call   f0105115 <printfmt>
f0105281:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105284:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0105287:	e9 cc fe ff ff       	jmp    f0105158 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f010528c:	52                   	push   %edx
f010528d:	68 f7 71 10 f0       	push   $0xf01071f7
f0105292:	53                   	push   %ebx
f0105293:	56                   	push   %esi
f0105294:	e8 7c fe ff ff       	call   f0105115 <printfmt>
f0105299:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010529c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010529f:	e9 b4 fe ff ff       	jmp    f0105158 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01052a4:	8b 45 14             	mov    0x14(%ebp),%eax
f01052a7:	8d 50 04             	lea    0x4(%eax),%edx
f01052aa:	89 55 14             	mov    %edx,0x14(%ebp)
f01052ad:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f01052af:	85 ff                	test   %edi,%edi
f01052b1:	b8 47 85 10 f0       	mov    $0xf0108547,%eax
f01052b6:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f01052b9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01052bd:	0f 8e 94 00 00 00    	jle    f0105357 <vprintfmt+0x225>
f01052c3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f01052c7:	0f 84 98 00 00 00    	je     f0105365 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f01052cd:	83 ec 08             	sub    $0x8,%esp
f01052d0:	ff 75 d0             	pushl  -0x30(%ebp)
f01052d3:	57                   	push   %edi
f01052d4:	e8 77 03 00 00       	call   f0105650 <strnlen>
f01052d9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01052dc:	29 c1                	sub    %eax,%ecx
f01052de:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f01052e1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f01052e4:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f01052e8:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01052eb:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01052ee:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01052f0:	eb 0f                	jmp    f0105301 <vprintfmt+0x1cf>
					putch(padc, putdat);
f01052f2:	83 ec 08             	sub    $0x8,%esp
f01052f5:	53                   	push   %ebx
f01052f6:	ff 75 e0             	pushl  -0x20(%ebp)
f01052f9:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01052fb:	83 ef 01             	sub    $0x1,%edi
f01052fe:	83 c4 10             	add    $0x10,%esp
f0105301:	85 ff                	test   %edi,%edi
f0105303:	7f ed                	jg     f01052f2 <vprintfmt+0x1c0>
f0105305:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0105308:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010530b:	85 c9                	test   %ecx,%ecx
f010530d:	b8 00 00 00 00       	mov    $0x0,%eax
f0105312:	0f 49 c1             	cmovns %ecx,%eax
f0105315:	29 c1                	sub    %eax,%ecx
f0105317:	89 75 08             	mov    %esi,0x8(%ebp)
f010531a:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010531d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105320:	89 cb                	mov    %ecx,%ebx
f0105322:	eb 4d                	jmp    f0105371 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105324:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105328:	74 1b                	je     f0105345 <vprintfmt+0x213>
f010532a:	0f be c0             	movsbl %al,%eax
f010532d:	83 e8 20             	sub    $0x20,%eax
f0105330:	83 f8 5e             	cmp    $0x5e,%eax
f0105333:	76 10                	jbe    f0105345 <vprintfmt+0x213>
					putch('?', putdat);
f0105335:	83 ec 08             	sub    $0x8,%esp
f0105338:	ff 75 0c             	pushl  0xc(%ebp)
f010533b:	6a 3f                	push   $0x3f
f010533d:	ff 55 08             	call   *0x8(%ebp)
f0105340:	83 c4 10             	add    $0x10,%esp
f0105343:	eb 0d                	jmp    f0105352 <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0105345:	83 ec 08             	sub    $0x8,%esp
f0105348:	ff 75 0c             	pushl  0xc(%ebp)
f010534b:	52                   	push   %edx
f010534c:	ff 55 08             	call   *0x8(%ebp)
f010534f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105352:	83 eb 01             	sub    $0x1,%ebx
f0105355:	eb 1a                	jmp    f0105371 <vprintfmt+0x23f>
f0105357:	89 75 08             	mov    %esi,0x8(%ebp)
f010535a:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010535d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105360:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105363:	eb 0c                	jmp    f0105371 <vprintfmt+0x23f>
f0105365:	89 75 08             	mov    %esi,0x8(%ebp)
f0105368:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010536b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010536e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105371:	83 c7 01             	add    $0x1,%edi
f0105374:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105378:	0f be d0             	movsbl %al,%edx
f010537b:	85 d2                	test   %edx,%edx
f010537d:	74 23                	je     f01053a2 <vprintfmt+0x270>
f010537f:	85 f6                	test   %esi,%esi
f0105381:	78 a1                	js     f0105324 <vprintfmt+0x1f2>
f0105383:	83 ee 01             	sub    $0x1,%esi
f0105386:	79 9c                	jns    f0105324 <vprintfmt+0x1f2>
f0105388:	89 df                	mov    %ebx,%edi
f010538a:	8b 75 08             	mov    0x8(%ebp),%esi
f010538d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105390:	eb 18                	jmp    f01053aa <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0105392:	83 ec 08             	sub    $0x8,%esp
f0105395:	53                   	push   %ebx
f0105396:	6a 20                	push   $0x20
f0105398:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010539a:	83 ef 01             	sub    $0x1,%edi
f010539d:	83 c4 10             	add    $0x10,%esp
f01053a0:	eb 08                	jmp    f01053aa <vprintfmt+0x278>
f01053a2:	89 df                	mov    %ebx,%edi
f01053a4:	8b 75 08             	mov    0x8(%ebp),%esi
f01053a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01053aa:	85 ff                	test   %edi,%edi
f01053ac:	7f e4                	jg     f0105392 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01053ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01053b1:	e9 a2 fd ff ff       	jmp    f0105158 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01053b6:	83 fa 01             	cmp    $0x1,%edx
f01053b9:	7e 16                	jle    f01053d1 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f01053bb:	8b 45 14             	mov    0x14(%ebp),%eax
f01053be:	8d 50 08             	lea    0x8(%eax),%edx
f01053c1:	89 55 14             	mov    %edx,0x14(%ebp)
f01053c4:	8b 50 04             	mov    0x4(%eax),%edx
f01053c7:	8b 00                	mov    (%eax),%eax
f01053c9:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01053cc:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01053cf:	eb 32                	jmp    f0105403 <vprintfmt+0x2d1>
	else if (lflag)
f01053d1:	85 d2                	test   %edx,%edx
f01053d3:	74 18                	je     f01053ed <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f01053d5:	8b 45 14             	mov    0x14(%ebp),%eax
f01053d8:	8d 50 04             	lea    0x4(%eax),%edx
f01053db:	89 55 14             	mov    %edx,0x14(%ebp)
f01053de:	8b 00                	mov    (%eax),%eax
f01053e0:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01053e3:	89 c1                	mov    %eax,%ecx
f01053e5:	c1 f9 1f             	sar    $0x1f,%ecx
f01053e8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01053eb:	eb 16                	jmp    f0105403 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f01053ed:	8b 45 14             	mov    0x14(%ebp),%eax
f01053f0:	8d 50 04             	lea    0x4(%eax),%edx
f01053f3:	89 55 14             	mov    %edx,0x14(%ebp)
f01053f6:	8b 00                	mov    (%eax),%eax
f01053f8:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01053fb:	89 c1                	mov    %eax,%ecx
f01053fd:	c1 f9 1f             	sar    $0x1f,%ecx
f0105400:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0105403:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105406:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0105409:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010540e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105412:	79 74                	jns    f0105488 <vprintfmt+0x356>
				putch('-', putdat);
f0105414:	83 ec 08             	sub    $0x8,%esp
f0105417:	53                   	push   %ebx
f0105418:	6a 2d                	push   $0x2d
f010541a:	ff d6                	call   *%esi
				num = -(long long) num;
f010541c:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010541f:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105422:	f7 d8                	neg    %eax
f0105424:	83 d2 00             	adc    $0x0,%edx
f0105427:	f7 da                	neg    %edx
f0105429:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f010542c:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0105431:	eb 55                	jmp    f0105488 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0105433:	8d 45 14             	lea    0x14(%ebp),%eax
f0105436:	e8 83 fc ff ff       	call   f01050be <getuint>
			base = 10;
f010543b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0105440:	eb 46                	jmp    f0105488 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
f0105442:	8d 45 14             	lea    0x14(%ebp),%eax
f0105445:	e8 74 fc ff ff       	call   f01050be <getuint>
			base = 8;
f010544a:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f010544f:	eb 37                	jmp    f0105488 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
f0105451:	83 ec 08             	sub    $0x8,%esp
f0105454:	53                   	push   %ebx
f0105455:	6a 30                	push   $0x30
f0105457:	ff d6                	call   *%esi
			putch('x', putdat);
f0105459:	83 c4 08             	add    $0x8,%esp
f010545c:	53                   	push   %ebx
f010545d:	6a 78                	push   $0x78
f010545f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0105461:	8b 45 14             	mov    0x14(%ebp),%eax
f0105464:	8d 50 04             	lea    0x4(%eax),%edx
f0105467:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f010546a:	8b 00                	mov    (%eax),%eax
f010546c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0105471:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0105474:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0105479:	eb 0d                	jmp    f0105488 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f010547b:	8d 45 14             	lea    0x14(%ebp),%eax
f010547e:	e8 3b fc ff ff       	call   f01050be <getuint>
			base = 16;
f0105483:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105488:	83 ec 0c             	sub    $0xc,%esp
f010548b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f010548f:	57                   	push   %edi
f0105490:	ff 75 e0             	pushl  -0x20(%ebp)
f0105493:	51                   	push   %ecx
f0105494:	52                   	push   %edx
f0105495:	50                   	push   %eax
f0105496:	89 da                	mov    %ebx,%edx
f0105498:	89 f0                	mov    %esi,%eax
f010549a:	e8 70 fb ff ff       	call   f010500f <printnum>
			break;
f010549f:	83 c4 20             	add    $0x20,%esp
f01054a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01054a5:	e9 ae fc ff ff       	jmp    f0105158 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01054aa:	83 ec 08             	sub    $0x8,%esp
f01054ad:	53                   	push   %ebx
f01054ae:	51                   	push   %ecx
f01054af:	ff d6                	call   *%esi
			break;
f01054b1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01054b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01054b7:	e9 9c fc ff ff       	jmp    f0105158 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01054bc:	83 ec 08             	sub    $0x8,%esp
f01054bf:	53                   	push   %ebx
f01054c0:	6a 25                	push   $0x25
f01054c2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01054c4:	83 c4 10             	add    $0x10,%esp
f01054c7:	eb 03                	jmp    f01054cc <vprintfmt+0x39a>
f01054c9:	83 ef 01             	sub    $0x1,%edi
f01054cc:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f01054d0:	75 f7                	jne    f01054c9 <vprintfmt+0x397>
f01054d2:	e9 81 fc ff ff       	jmp    f0105158 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f01054d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01054da:	5b                   	pop    %ebx
f01054db:	5e                   	pop    %esi
f01054dc:	5f                   	pop    %edi
f01054dd:	5d                   	pop    %ebp
f01054de:	c3                   	ret    

f01054df <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01054df:	55                   	push   %ebp
f01054e0:	89 e5                	mov    %esp,%ebp
f01054e2:	83 ec 18             	sub    $0x18,%esp
f01054e5:	8b 45 08             	mov    0x8(%ebp),%eax
f01054e8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01054eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01054ee:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01054f2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01054f5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01054fc:	85 c0                	test   %eax,%eax
f01054fe:	74 26                	je     f0105526 <vsnprintf+0x47>
f0105500:	85 d2                	test   %edx,%edx
f0105502:	7e 22                	jle    f0105526 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105504:	ff 75 14             	pushl  0x14(%ebp)
f0105507:	ff 75 10             	pushl  0x10(%ebp)
f010550a:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010550d:	50                   	push   %eax
f010550e:	68 f8 50 10 f0       	push   $0xf01050f8
f0105513:	e8 1a fc ff ff       	call   f0105132 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105518:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010551b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010551e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105521:	83 c4 10             	add    $0x10,%esp
f0105524:	eb 05                	jmp    f010552b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105526:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f010552b:	c9                   	leave  
f010552c:	c3                   	ret    

f010552d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010552d:	55                   	push   %ebp
f010552e:	89 e5                	mov    %esp,%ebp
f0105530:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105533:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105536:	50                   	push   %eax
f0105537:	ff 75 10             	pushl  0x10(%ebp)
f010553a:	ff 75 0c             	pushl  0xc(%ebp)
f010553d:	ff 75 08             	pushl  0x8(%ebp)
f0105540:	e8 9a ff ff ff       	call   f01054df <vsnprintf>
	va_end(ap);

	return rc;
}
f0105545:	c9                   	leave  
f0105546:	c3                   	ret    

f0105547 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105547:	55                   	push   %ebp
f0105548:	89 e5                	mov    %esp,%ebp
f010554a:	57                   	push   %edi
f010554b:	56                   	push   %esi
f010554c:	53                   	push   %ebx
f010554d:	83 ec 0c             	sub    $0xc,%esp
f0105550:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f0105553:	85 c0                	test   %eax,%eax
f0105555:	74 11                	je     f0105568 <readline+0x21>
		cprintf("%s", prompt);
f0105557:	83 ec 08             	sub    $0x8,%esp
f010555a:	50                   	push   %eax
f010555b:	68 f7 71 10 f0       	push   $0xf01071f7
f0105560:	e8 1d e4 ff ff       	call   f0103982 <cprintf>
f0105565:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f0105568:	83 ec 0c             	sub    $0xc,%esp
f010556b:	6a 00                	push   $0x0
f010556d:	e8 3b b2 ff ff       	call   f01007ad <iscons>
f0105572:	89 c7                	mov    %eax,%edi
f0105574:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
f0105577:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f010557c:	e8 1b b2 ff ff       	call   f010079c <getchar>
f0105581:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105583:	85 c0                	test   %eax,%eax
f0105585:	79 29                	jns    f01055b0 <readline+0x69>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f0105587:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
f010558c:	83 fb f8             	cmp    $0xfffffff8,%ebx
f010558f:	0f 84 9b 00 00 00    	je     f0105630 <readline+0xe9>
				cprintf("read error: %e\n", c);
f0105595:	83 ec 08             	sub    $0x8,%esp
f0105598:	53                   	push   %ebx
f0105599:	68 3f 88 10 f0       	push   $0xf010883f
f010559e:	e8 df e3 ff ff       	call   f0103982 <cprintf>
f01055a3:	83 c4 10             	add    $0x10,%esp
			return NULL;
f01055a6:	b8 00 00 00 00       	mov    $0x0,%eax
f01055ab:	e9 80 00 00 00       	jmp    f0105630 <readline+0xe9>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01055b0:	83 f8 08             	cmp    $0x8,%eax
f01055b3:	0f 94 c2             	sete   %dl
f01055b6:	83 f8 7f             	cmp    $0x7f,%eax
f01055b9:	0f 94 c0             	sete   %al
f01055bc:	08 c2                	or     %al,%dl
f01055be:	74 1a                	je     f01055da <readline+0x93>
f01055c0:	85 f6                	test   %esi,%esi
f01055c2:	7e 16                	jle    f01055da <readline+0x93>
			if (echoing)
f01055c4:	85 ff                	test   %edi,%edi
f01055c6:	74 0d                	je     f01055d5 <readline+0x8e>
				cputchar('\b');
f01055c8:	83 ec 0c             	sub    $0xc,%esp
f01055cb:	6a 08                	push   $0x8
f01055cd:	e8 ba b1 ff ff       	call   f010078c <cputchar>
f01055d2:	83 c4 10             	add    $0x10,%esp
			i--;
f01055d5:	83 ee 01             	sub    $0x1,%esi
f01055d8:	eb a2                	jmp    f010557c <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01055da:	83 fb 1f             	cmp    $0x1f,%ebx
f01055dd:	7e 26                	jle    f0105605 <readline+0xbe>
f01055df:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01055e5:	7f 1e                	jg     f0105605 <readline+0xbe>
			if (echoing)
f01055e7:	85 ff                	test   %edi,%edi
f01055e9:	74 0c                	je     f01055f7 <readline+0xb0>
				cputchar(c);
f01055eb:	83 ec 0c             	sub    $0xc,%esp
f01055ee:	53                   	push   %ebx
f01055ef:	e8 98 b1 ff ff       	call   f010078c <cputchar>
f01055f4:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01055f7:	88 9e 80 aa 2a f0    	mov    %bl,-0xfd55580(%esi)
f01055fd:	8d 76 01             	lea    0x1(%esi),%esi
f0105600:	e9 77 ff ff ff       	jmp    f010557c <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0105605:	83 fb 0a             	cmp    $0xa,%ebx
f0105608:	74 09                	je     f0105613 <readline+0xcc>
f010560a:	83 fb 0d             	cmp    $0xd,%ebx
f010560d:	0f 85 69 ff ff ff    	jne    f010557c <readline+0x35>
			if (echoing)
f0105613:	85 ff                	test   %edi,%edi
f0105615:	74 0d                	je     f0105624 <readline+0xdd>
				cputchar('\n');
f0105617:	83 ec 0c             	sub    $0xc,%esp
f010561a:	6a 0a                	push   $0xa
f010561c:	e8 6b b1 ff ff       	call   f010078c <cputchar>
f0105621:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0105624:	c6 86 80 aa 2a f0 00 	movb   $0x0,-0xfd55580(%esi)
			return buf;
f010562b:	b8 80 aa 2a f0       	mov    $0xf02aaa80,%eax
		}
	}
}
f0105630:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105633:	5b                   	pop    %ebx
f0105634:	5e                   	pop    %esi
f0105635:	5f                   	pop    %edi
f0105636:	5d                   	pop    %ebp
f0105637:	c3                   	ret    

f0105638 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105638:	55                   	push   %ebp
f0105639:	89 e5                	mov    %esp,%ebp
f010563b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010563e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105643:	eb 03                	jmp    f0105648 <strlen+0x10>
		n++;
f0105645:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105648:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010564c:	75 f7                	jne    f0105645 <strlen+0xd>
		n++;
	return n;
}
f010564e:	5d                   	pop    %ebp
f010564f:	c3                   	ret    

f0105650 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105650:	55                   	push   %ebp
f0105651:	89 e5                	mov    %esp,%ebp
f0105653:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105656:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105659:	ba 00 00 00 00       	mov    $0x0,%edx
f010565e:	eb 03                	jmp    f0105663 <strnlen+0x13>
		n++;
f0105660:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105663:	39 c2                	cmp    %eax,%edx
f0105665:	74 08                	je     f010566f <strnlen+0x1f>
f0105667:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f010566b:	75 f3                	jne    f0105660 <strnlen+0x10>
f010566d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f010566f:	5d                   	pop    %ebp
f0105670:	c3                   	ret    

f0105671 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105671:	55                   	push   %ebp
f0105672:	89 e5                	mov    %esp,%ebp
f0105674:	53                   	push   %ebx
f0105675:	8b 45 08             	mov    0x8(%ebp),%eax
f0105678:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010567b:	89 c2                	mov    %eax,%edx
f010567d:	83 c2 01             	add    $0x1,%edx
f0105680:	83 c1 01             	add    $0x1,%ecx
f0105683:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0105687:	88 5a ff             	mov    %bl,-0x1(%edx)
f010568a:	84 db                	test   %bl,%bl
f010568c:	75 ef                	jne    f010567d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f010568e:	5b                   	pop    %ebx
f010568f:	5d                   	pop    %ebp
f0105690:	c3                   	ret    

f0105691 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105691:	55                   	push   %ebp
f0105692:	89 e5                	mov    %esp,%ebp
f0105694:	53                   	push   %ebx
f0105695:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105698:	53                   	push   %ebx
f0105699:	e8 9a ff ff ff       	call   f0105638 <strlen>
f010569e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01056a1:	ff 75 0c             	pushl  0xc(%ebp)
f01056a4:	01 d8                	add    %ebx,%eax
f01056a6:	50                   	push   %eax
f01056a7:	e8 c5 ff ff ff       	call   f0105671 <strcpy>
	return dst;
}
f01056ac:	89 d8                	mov    %ebx,%eax
f01056ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01056b1:	c9                   	leave  
f01056b2:	c3                   	ret    

f01056b3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01056b3:	55                   	push   %ebp
f01056b4:	89 e5                	mov    %esp,%ebp
f01056b6:	56                   	push   %esi
f01056b7:	53                   	push   %ebx
f01056b8:	8b 75 08             	mov    0x8(%ebp),%esi
f01056bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01056be:	89 f3                	mov    %esi,%ebx
f01056c0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01056c3:	89 f2                	mov    %esi,%edx
f01056c5:	eb 0f                	jmp    f01056d6 <strncpy+0x23>
		*dst++ = *src;
f01056c7:	83 c2 01             	add    $0x1,%edx
f01056ca:	0f b6 01             	movzbl (%ecx),%eax
f01056cd:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01056d0:	80 39 01             	cmpb   $0x1,(%ecx)
f01056d3:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01056d6:	39 da                	cmp    %ebx,%edx
f01056d8:	75 ed                	jne    f01056c7 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01056da:	89 f0                	mov    %esi,%eax
f01056dc:	5b                   	pop    %ebx
f01056dd:	5e                   	pop    %esi
f01056de:	5d                   	pop    %ebp
f01056df:	c3                   	ret    

f01056e0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01056e0:	55                   	push   %ebp
f01056e1:	89 e5                	mov    %esp,%ebp
f01056e3:	56                   	push   %esi
f01056e4:	53                   	push   %ebx
f01056e5:	8b 75 08             	mov    0x8(%ebp),%esi
f01056e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01056eb:	8b 55 10             	mov    0x10(%ebp),%edx
f01056ee:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01056f0:	85 d2                	test   %edx,%edx
f01056f2:	74 21                	je     f0105715 <strlcpy+0x35>
f01056f4:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f01056f8:	89 f2                	mov    %esi,%edx
f01056fa:	eb 09                	jmp    f0105705 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01056fc:	83 c2 01             	add    $0x1,%edx
f01056ff:	83 c1 01             	add    $0x1,%ecx
f0105702:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105705:	39 c2                	cmp    %eax,%edx
f0105707:	74 09                	je     f0105712 <strlcpy+0x32>
f0105709:	0f b6 19             	movzbl (%ecx),%ebx
f010570c:	84 db                	test   %bl,%bl
f010570e:	75 ec                	jne    f01056fc <strlcpy+0x1c>
f0105710:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0105712:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105715:	29 f0                	sub    %esi,%eax
}
f0105717:	5b                   	pop    %ebx
f0105718:	5e                   	pop    %esi
f0105719:	5d                   	pop    %ebp
f010571a:	c3                   	ret    

f010571b <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010571b:	55                   	push   %ebp
f010571c:	89 e5                	mov    %esp,%ebp
f010571e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105721:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105724:	eb 06                	jmp    f010572c <strcmp+0x11>
		p++, q++;
f0105726:	83 c1 01             	add    $0x1,%ecx
f0105729:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010572c:	0f b6 01             	movzbl (%ecx),%eax
f010572f:	84 c0                	test   %al,%al
f0105731:	74 04                	je     f0105737 <strcmp+0x1c>
f0105733:	3a 02                	cmp    (%edx),%al
f0105735:	74 ef                	je     f0105726 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105737:	0f b6 c0             	movzbl %al,%eax
f010573a:	0f b6 12             	movzbl (%edx),%edx
f010573d:	29 d0                	sub    %edx,%eax
}
f010573f:	5d                   	pop    %ebp
f0105740:	c3                   	ret    

f0105741 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105741:	55                   	push   %ebp
f0105742:	89 e5                	mov    %esp,%ebp
f0105744:	53                   	push   %ebx
f0105745:	8b 45 08             	mov    0x8(%ebp),%eax
f0105748:	8b 55 0c             	mov    0xc(%ebp),%edx
f010574b:	89 c3                	mov    %eax,%ebx
f010574d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105750:	eb 06                	jmp    f0105758 <strncmp+0x17>
		n--, p++, q++;
f0105752:	83 c0 01             	add    $0x1,%eax
f0105755:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105758:	39 d8                	cmp    %ebx,%eax
f010575a:	74 15                	je     f0105771 <strncmp+0x30>
f010575c:	0f b6 08             	movzbl (%eax),%ecx
f010575f:	84 c9                	test   %cl,%cl
f0105761:	74 04                	je     f0105767 <strncmp+0x26>
f0105763:	3a 0a                	cmp    (%edx),%cl
f0105765:	74 eb                	je     f0105752 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105767:	0f b6 00             	movzbl (%eax),%eax
f010576a:	0f b6 12             	movzbl (%edx),%edx
f010576d:	29 d0                	sub    %edx,%eax
f010576f:	eb 05                	jmp    f0105776 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105771:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105776:	5b                   	pop    %ebx
f0105777:	5d                   	pop    %ebp
f0105778:	c3                   	ret    

f0105779 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105779:	55                   	push   %ebp
f010577a:	89 e5                	mov    %esp,%ebp
f010577c:	8b 45 08             	mov    0x8(%ebp),%eax
f010577f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105783:	eb 07                	jmp    f010578c <strchr+0x13>
		if (*s == c)
f0105785:	38 ca                	cmp    %cl,%dl
f0105787:	74 0f                	je     f0105798 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105789:	83 c0 01             	add    $0x1,%eax
f010578c:	0f b6 10             	movzbl (%eax),%edx
f010578f:	84 d2                	test   %dl,%dl
f0105791:	75 f2                	jne    f0105785 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0105793:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105798:	5d                   	pop    %ebp
f0105799:	c3                   	ret    

f010579a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010579a:	55                   	push   %ebp
f010579b:	89 e5                	mov    %esp,%ebp
f010579d:	8b 45 08             	mov    0x8(%ebp),%eax
f01057a0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01057a4:	eb 03                	jmp    f01057a9 <strfind+0xf>
f01057a6:	83 c0 01             	add    $0x1,%eax
f01057a9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01057ac:	38 ca                	cmp    %cl,%dl
f01057ae:	74 04                	je     f01057b4 <strfind+0x1a>
f01057b0:	84 d2                	test   %dl,%dl
f01057b2:	75 f2                	jne    f01057a6 <strfind+0xc>
			break;
	return (char *) s;
}
f01057b4:	5d                   	pop    %ebp
f01057b5:	c3                   	ret    

f01057b6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01057b6:	55                   	push   %ebp
f01057b7:	89 e5                	mov    %esp,%ebp
f01057b9:	57                   	push   %edi
f01057ba:	56                   	push   %esi
f01057bb:	53                   	push   %ebx
f01057bc:	8b 7d 08             	mov    0x8(%ebp),%edi
f01057bf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01057c2:	85 c9                	test   %ecx,%ecx
f01057c4:	74 36                	je     f01057fc <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01057c6:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01057cc:	75 28                	jne    f01057f6 <memset+0x40>
f01057ce:	f6 c1 03             	test   $0x3,%cl
f01057d1:	75 23                	jne    f01057f6 <memset+0x40>
		c &= 0xFF;
f01057d3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01057d7:	89 d3                	mov    %edx,%ebx
f01057d9:	c1 e3 08             	shl    $0x8,%ebx
f01057dc:	89 d6                	mov    %edx,%esi
f01057de:	c1 e6 18             	shl    $0x18,%esi
f01057e1:	89 d0                	mov    %edx,%eax
f01057e3:	c1 e0 10             	shl    $0x10,%eax
f01057e6:	09 f0                	or     %esi,%eax
f01057e8:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f01057ea:	89 d8                	mov    %ebx,%eax
f01057ec:	09 d0                	or     %edx,%eax
f01057ee:	c1 e9 02             	shr    $0x2,%ecx
f01057f1:	fc                   	cld    
f01057f2:	f3 ab                	rep stos %eax,%es:(%edi)
f01057f4:	eb 06                	jmp    f01057fc <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01057f6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01057f9:	fc                   	cld    
f01057fa:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01057fc:	89 f8                	mov    %edi,%eax
f01057fe:	5b                   	pop    %ebx
f01057ff:	5e                   	pop    %esi
f0105800:	5f                   	pop    %edi
f0105801:	5d                   	pop    %ebp
f0105802:	c3                   	ret    

f0105803 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105803:	55                   	push   %ebp
f0105804:	89 e5                	mov    %esp,%ebp
f0105806:	57                   	push   %edi
f0105807:	56                   	push   %esi
f0105808:	8b 45 08             	mov    0x8(%ebp),%eax
f010580b:	8b 75 0c             	mov    0xc(%ebp),%esi
f010580e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105811:	39 c6                	cmp    %eax,%esi
f0105813:	73 35                	jae    f010584a <memmove+0x47>
f0105815:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105818:	39 d0                	cmp    %edx,%eax
f010581a:	73 2e                	jae    f010584a <memmove+0x47>
		s += n;
		d += n;
f010581c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010581f:	89 d6                	mov    %edx,%esi
f0105821:	09 fe                	or     %edi,%esi
f0105823:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105829:	75 13                	jne    f010583e <memmove+0x3b>
f010582b:	f6 c1 03             	test   $0x3,%cl
f010582e:	75 0e                	jne    f010583e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0105830:	83 ef 04             	sub    $0x4,%edi
f0105833:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105836:	c1 e9 02             	shr    $0x2,%ecx
f0105839:	fd                   	std    
f010583a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010583c:	eb 09                	jmp    f0105847 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f010583e:	83 ef 01             	sub    $0x1,%edi
f0105841:	8d 72 ff             	lea    -0x1(%edx),%esi
f0105844:	fd                   	std    
f0105845:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105847:	fc                   	cld    
f0105848:	eb 1d                	jmp    f0105867 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010584a:	89 f2                	mov    %esi,%edx
f010584c:	09 c2                	or     %eax,%edx
f010584e:	f6 c2 03             	test   $0x3,%dl
f0105851:	75 0f                	jne    f0105862 <memmove+0x5f>
f0105853:	f6 c1 03             	test   $0x3,%cl
f0105856:	75 0a                	jne    f0105862 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0105858:	c1 e9 02             	shr    $0x2,%ecx
f010585b:	89 c7                	mov    %eax,%edi
f010585d:	fc                   	cld    
f010585e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105860:	eb 05                	jmp    f0105867 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105862:	89 c7                	mov    %eax,%edi
f0105864:	fc                   	cld    
f0105865:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105867:	5e                   	pop    %esi
f0105868:	5f                   	pop    %edi
f0105869:	5d                   	pop    %ebp
f010586a:	c3                   	ret    

f010586b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010586b:	55                   	push   %ebp
f010586c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010586e:	ff 75 10             	pushl  0x10(%ebp)
f0105871:	ff 75 0c             	pushl  0xc(%ebp)
f0105874:	ff 75 08             	pushl  0x8(%ebp)
f0105877:	e8 87 ff ff ff       	call   f0105803 <memmove>
}
f010587c:	c9                   	leave  
f010587d:	c3                   	ret    

f010587e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010587e:	55                   	push   %ebp
f010587f:	89 e5                	mov    %esp,%ebp
f0105881:	56                   	push   %esi
f0105882:	53                   	push   %ebx
f0105883:	8b 45 08             	mov    0x8(%ebp),%eax
f0105886:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105889:	89 c6                	mov    %eax,%esi
f010588b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010588e:	eb 1a                	jmp    f01058aa <memcmp+0x2c>
		if (*s1 != *s2)
f0105890:	0f b6 08             	movzbl (%eax),%ecx
f0105893:	0f b6 1a             	movzbl (%edx),%ebx
f0105896:	38 d9                	cmp    %bl,%cl
f0105898:	74 0a                	je     f01058a4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f010589a:	0f b6 c1             	movzbl %cl,%eax
f010589d:	0f b6 db             	movzbl %bl,%ebx
f01058a0:	29 d8                	sub    %ebx,%eax
f01058a2:	eb 0f                	jmp    f01058b3 <memcmp+0x35>
		s1++, s2++;
f01058a4:	83 c0 01             	add    $0x1,%eax
f01058a7:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01058aa:	39 f0                	cmp    %esi,%eax
f01058ac:	75 e2                	jne    f0105890 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01058ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01058b3:	5b                   	pop    %ebx
f01058b4:	5e                   	pop    %esi
f01058b5:	5d                   	pop    %ebp
f01058b6:	c3                   	ret    

f01058b7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01058b7:	55                   	push   %ebp
f01058b8:	89 e5                	mov    %esp,%ebp
f01058ba:	53                   	push   %ebx
f01058bb:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01058be:	89 c1                	mov    %eax,%ecx
f01058c0:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f01058c3:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01058c7:	eb 0a                	jmp    f01058d3 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f01058c9:	0f b6 10             	movzbl (%eax),%edx
f01058cc:	39 da                	cmp    %ebx,%edx
f01058ce:	74 07                	je     f01058d7 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01058d0:	83 c0 01             	add    $0x1,%eax
f01058d3:	39 c8                	cmp    %ecx,%eax
f01058d5:	72 f2                	jb     f01058c9 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01058d7:	5b                   	pop    %ebx
f01058d8:	5d                   	pop    %ebp
f01058d9:	c3                   	ret    

f01058da <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01058da:	55                   	push   %ebp
f01058db:	89 e5                	mov    %esp,%ebp
f01058dd:	57                   	push   %edi
f01058de:	56                   	push   %esi
f01058df:	53                   	push   %ebx
f01058e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01058e3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01058e6:	eb 03                	jmp    f01058eb <strtol+0x11>
		s++;
f01058e8:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01058eb:	0f b6 01             	movzbl (%ecx),%eax
f01058ee:	3c 20                	cmp    $0x20,%al
f01058f0:	74 f6                	je     f01058e8 <strtol+0xe>
f01058f2:	3c 09                	cmp    $0x9,%al
f01058f4:	74 f2                	je     f01058e8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01058f6:	3c 2b                	cmp    $0x2b,%al
f01058f8:	75 0a                	jne    f0105904 <strtol+0x2a>
		s++;
f01058fa:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01058fd:	bf 00 00 00 00       	mov    $0x0,%edi
f0105902:	eb 11                	jmp    f0105915 <strtol+0x3b>
f0105904:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0105909:	3c 2d                	cmp    $0x2d,%al
f010590b:	75 08                	jne    f0105915 <strtol+0x3b>
		s++, neg = 1;
f010590d:	83 c1 01             	add    $0x1,%ecx
f0105910:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105915:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010591b:	75 15                	jne    f0105932 <strtol+0x58>
f010591d:	80 39 30             	cmpb   $0x30,(%ecx)
f0105920:	75 10                	jne    f0105932 <strtol+0x58>
f0105922:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105926:	75 7c                	jne    f01059a4 <strtol+0xca>
		s += 2, base = 16;
f0105928:	83 c1 02             	add    $0x2,%ecx
f010592b:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105930:	eb 16                	jmp    f0105948 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0105932:	85 db                	test   %ebx,%ebx
f0105934:	75 12                	jne    f0105948 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105936:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010593b:	80 39 30             	cmpb   $0x30,(%ecx)
f010593e:	75 08                	jne    f0105948 <strtol+0x6e>
		s++, base = 8;
f0105940:	83 c1 01             	add    $0x1,%ecx
f0105943:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0105948:	b8 00 00 00 00       	mov    $0x0,%eax
f010594d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105950:	0f b6 11             	movzbl (%ecx),%edx
f0105953:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105956:	89 f3                	mov    %esi,%ebx
f0105958:	80 fb 09             	cmp    $0x9,%bl
f010595b:	77 08                	ja     f0105965 <strtol+0x8b>
			dig = *s - '0';
f010595d:	0f be d2             	movsbl %dl,%edx
f0105960:	83 ea 30             	sub    $0x30,%edx
f0105963:	eb 22                	jmp    f0105987 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0105965:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105968:	89 f3                	mov    %esi,%ebx
f010596a:	80 fb 19             	cmp    $0x19,%bl
f010596d:	77 08                	ja     f0105977 <strtol+0x9d>
			dig = *s - 'a' + 10;
f010596f:	0f be d2             	movsbl %dl,%edx
f0105972:	83 ea 57             	sub    $0x57,%edx
f0105975:	eb 10                	jmp    f0105987 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0105977:	8d 72 bf             	lea    -0x41(%edx),%esi
f010597a:	89 f3                	mov    %esi,%ebx
f010597c:	80 fb 19             	cmp    $0x19,%bl
f010597f:	77 16                	ja     f0105997 <strtol+0xbd>
			dig = *s - 'A' + 10;
f0105981:	0f be d2             	movsbl %dl,%edx
f0105984:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0105987:	3b 55 10             	cmp    0x10(%ebp),%edx
f010598a:	7d 0b                	jge    f0105997 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f010598c:	83 c1 01             	add    $0x1,%ecx
f010598f:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105993:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0105995:	eb b9                	jmp    f0105950 <strtol+0x76>

	if (endptr)
f0105997:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010599b:	74 0d                	je     f01059aa <strtol+0xd0>
		*endptr = (char *) s;
f010599d:	8b 75 0c             	mov    0xc(%ebp),%esi
f01059a0:	89 0e                	mov    %ecx,(%esi)
f01059a2:	eb 06                	jmp    f01059aa <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01059a4:	85 db                	test   %ebx,%ebx
f01059a6:	74 98                	je     f0105940 <strtol+0x66>
f01059a8:	eb 9e                	jmp    f0105948 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f01059aa:	89 c2                	mov    %eax,%edx
f01059ac:	f7 da                	neg    %edx
f01059ae:	85 ff                	test   %edi,%edi
f01059b0:	0f 45 c2             	cmovne %edx,%eax
}
f01059b3:	5b                   	pop    %ebx
f01059b4:	5e                   	pop    %esi
f01059b5:	5f                   	pop    %edi
f01059b6:	5d                   	pop    %ebp
f01059b7:	c3                   	ret    

f01059b8 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f01059b8:	fa                   	cli    

	xorw    %ax, %ax
f01059b9:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f01059bb:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01059bd:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01059bf:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f01059c1:	0f 01 16             	lgdtl  (%esi)
f01059c4:	74 70                	je     f0105a36 <mpsearch1+0x3>
	movl    %cr0, %eax
f01059c6:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f01059c9:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f01059cd:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f01059d0:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f01059d6:	08 00                	or     %al,(%eax)

f01059d8 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f01059d8:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f01059dc:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01059de:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01059e0:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f01059e2:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f01059e6:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f01059e8:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f01059ea:	b8 00 10 12 00       	mov    $0x121000,%eax
	movl    %eax, %cr3
f01059ef:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f01059f2:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f01059f5:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f01059fa:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f01059fd:	8b 25 90 ae 2a f0    	mov    0xf02aae90,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105a03:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105a08:	b8 ba 01 10 f0       	mov    $0xf01001ba,%eax
	call    *%eax
f0105a0d:	ff d0                	call   *%eax

f0105a0f <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105a0f:	eb fe                	jmp    f0105a0f <spin>
f0105a11:	8d 76 00             	lea    0x0(%esi),%esi

f0105a14 <gdt>:
	...
f0105a1c:	ff                   	(bad)  
f0105a1d:	ff 00                	incl   (%eax)
f0105a1f:	00 00                	add    %al,(%eax)
f0105a21:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105a28:	00                   	.byte 0x0
f0105a29:	92                   	xchg   %eax,%edx
f0105a2a:	cf                   	iret   
	...

f0105a2c <gdtdesc>:
f0105a2c:	17                   	pop    %ss
f0105a2d:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105a32 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105a32:	90                   	nop

f0105a33 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105a33:	55                   	push   %ebp
f0105a34:	89 e5                	mov    %esp,%ebp
f0105a36:	57                   	push   %edi
f0105a37:	56                   	push   %esi
f0105a38:	53                   	push   %ebx
f0105a39:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105a3c:	8b 0d 94 ae 2a f0    	mov    0xf02aae94,%ecx
f0105a42:	89 c3                	mov    %eax,%ebx
f0105a44:	c1 eb 0c             	shr    $0xc,%ebx
f0105a47:	39 cb                	cmp    %ecx,%ebx
f0105a49:	72 12                	jb     f0105a5d <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105a4b:	50                   	push   %eax
f0105a4c:	68 04 6c 10 f0       	push   $0xf0106c04
f0105a51:	6a 57                	push   $0x57
f0105a53:	68 dd 89 10 f0       	push   $0xf01089dd
f0105a58:	e8 e3 a5 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105a5d:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105a63:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105a65:	89 c2                	mov    %eax,%edx
f0105a67:	c1 ea 0c             	shr    $0xc,%edx
f0105a6a:	39 ca                	cmp    %ecx,%edx
f0105a6c:	72 12                	jb     f0105a80 <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105a6e:	50                   	push   %eax
f0105a6f:	68 04 6c 10 f0       	push   $0xf0106c04
f0105a74:	6a 57                	push   $0x57
f0105a76:	68 dd 89 10 f0       	push   $0xf01089dd
f0105a7b:	e8 c0 a5 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105a80:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f0105a86:	eb 2f                	jmp    f0105ab7 <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105a88:	83 ec 04             	sub    $0x4,%esp
f0105a8b:	6a 04                	push   $0x4
f0105a8d:	68 ed 89 10 f0       	push   $0xf01089ed
f0105a92:	53                   	push   %ebx
f0105a93:	e8 e6 fd ff ff       	call   f010587e <memcmp>
f0105a98:	83 c4 10             	add    $0x10,%esp
f0105a9b:	85 c0                	test   %eax,%eax
f0105a9d:	75 15                	jne    f0105ab4 <mpsearch1+0x81>
f0105a9f:	89 da                	mov    %ebx,%edx
f0105aa1:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f0105aa4:	0f b6 0a             	movzbl (%edx),%ecx
f0105aa7:	01 c8                	add    %ecx,%eax
f0105aa9:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105aac:	39 d7                	cmp    %edx,%edi
f0105aae:	75 f4                	jne    f0105aa4 <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105ab0:	84 c0                	test   %al,%al
f0105ab2:	74 0e                	je     f0105ac2 <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0105ab4:	83 c3 10             	add    $0x10,%ebx
f0105ab7:	39 f3                	cmp    %esi,%ebx
f0105ab9:	72 cd                	jb     f0105a88 <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105abb:	b8 00 00 00 00       	mov    $0x0,%eax
f0105ac0:	eb 02                	jmp    f0105ac4 <mpsearch1+0x91>
f0105ac2:	89 d8                	mov    %ebx,%eax
}
f0105ac4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105ac7:	5b                   	pop    %ebx
f0105ac8:	5e                   	pop    %esi
f0105ac9:	5f                   	pop    %edi
f0105aca:	5d                   	pop    %ebp
f0105acb:	c3                   	ret    

f0105acc <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105acc:	55                   	push   %ebp
f0105acd:	89 e5                	mov    %esp,%ebp
f0105acf:	57                   	push   %edi
f0105ad0:	56                   	push   %esi
f0105ad1:	53                   	push   %ebx
f0105ad2:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105ad5:	c7 05 c0 b3 2a f0 20 	movl   $0xf02ab020,0xf02ab3c0
f0105adc:	b0 2a f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105adf:	83 3d 94 ae 2a f0 00 	cmpl   $0x0,0xf02aae94
f0105ae6:	75 16                	jne    f0105afe <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105ae8:	68 00 04 00 00       	push   $0x400
f0105aed:	68 04 6c 10 f0       	push   $0xf0106c04
f0105af2:	6a 6f                	push   $0x6f
f0105af4:	68 dd 89 10 f0       	push   $0xf01089dd
f0105af9:	e8 42 a5 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105afe:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105b05:	85 c0                	test   %eax,%eax
f0105b07:	74 16                	je     f0105b1f <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f0105b09:	c1 e0 04             	shl    $0x4,%eax
f0105b0c:	ba 00 04 00 00       	mov    $0x400,%edx
f0105b11:	e8 1d ff ff ff       	call   f0105a33 <mpsearch1>
f0105b16:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105b19:	85 c0                	test   %eax,%eax
f0105b1b:	75 3c                	jne    f0105b59 <mp_init+0x8d>
f0105b1d:	eb 20                	jmp    f0105b3f <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105b1f:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105b26:	c1 e0 0a             	shl    $0xa,%eax
f0105b29:	2d 00 04 00 00       	sub    $0x400,%eax
f0105b2e:	ba 00 04 00 00       	mov    $0x400,%edx
f0105b33:	e8 fb fe ff ff       	call   f0105a33 <mpsearch1>
f0105b38:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105b3b:	85 c0                	test   %eax,%eax
f0105b3d:	75 1a                	jne    f0105b59 <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0105b3f:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105b44:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105b49:	e8 e5 fe ff ff       	call   f0105a33 <mpsearch1>
f0105b4e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0105b51:	85 c0                	test   %eax,%eax
f0105b53:	0f 84 5d 02 00 00    	je     f0105db6 <mp_init+0x2ea>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105b59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105b5c:	8b 70 04             	mov    0x4(%eax),%esi
f0105b5f:	85 f6                	test   %esi,%esi
f0105b61:	74 06                	je     f0105b69 <mp_init+0x9d>
f0105b63:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105b67:	74 15                	je     f0105b7e <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f0105b69:	83 ec 0c             	sub    $0xc,%esp
f0105b6c:	68 50 88 10 f0       	push   $0xf0108850
f0105b71:	e8 0c de ff ff       	call   f0103982 <cprintf>
f0105b76:	83 c4 10             	add    $0x10,%esp
f0105b79:	e9 38 02 00 00       	jmp    f0105db6 <mp_init+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105b7e:	89 f0                	mov    %esi,%eax
f0105b80:	c1 e8 0c             	shr    $0xc,%eax
f0105b83:	3b 05 94 ae 2a f0    	cmp    0xf02aae94,%eax
f0105b89:	72 15                	jb     f0105ba0 <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105b8b:	56                   	push   %esi
f0105b8c:	68 04 6c 10 f0       	push   $0xf0106c04
f0105b91:	68 90 00 00 00       	push   $0x90
f0105b96:	68 dd 89 10 f0       	push   $0xf01089dd
f0105b9b:	e8 a0 a4 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105ba0:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105ba6:	83 ec 04             	sub    $0x4,%esp
f0105ba9:	6a 04                	push   $0x4
f0105bab:	68 f2 89 10 f0       	push   $0xf01089f2
f0105bb0:	53                   	push   %ebx
f0105bb1:	e8 c8 fc ff ff       	call   f010587e <memcmp>
f0105bb6:	83 c4 10             	add    $0x10,%esp
f0105bb9:	85 c0                	test   %eax,%eax
f0105bbb:	74 15                	je     f0105bd2 <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105bbd:	83 ec 0c             	sub    $0xc,%esp
f0105bc0:	68 80 88 10 f0       	push   $0xf0108880
f0105bc5:	e8 b8 dd ff ff       	call   f0103982 <cprintf>
f0105bca:	83 c4 10             	add    $0x10,%esp
f0105bcd:	e9 e4 01 00 00       	jmp    f0105db6 <mp_init+0x2ea>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105bd2:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f0105bd6:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f0105bda:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105bdd:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105be2:	b8 00 00 00 00       	mov    $0x0,%eax
f0105be7:	eb 0d                	jmp    f0105bf6 <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f0105be9:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0105bf0:	f0 
f0105bf1:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105bf3:	83 c0 01             	add    $0x1,%eax
f0105bf6:	39 c7                	cmp    %eax,%edi
f0105bf8:	75 ef                	jne    f0105be9 <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105bfa:	84 d2                	test   %dl,%dl
f0105bfc:	74 15                	je     f0105c13 <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105bfe:	83 ec 0c             	sub    $0xc,%esp
f0105c01:	68 b4 88 10 f0       	push   $0xf01088b4
f0105c06:	e8 77 dd ff ff       	call   f0103982 <cprintf>
f0105c0b:	83 c4 10             	add    $0x10,%esp
f0105c0e:	e9 a3 01 00 00       	jmp    f0105db6 <mp_init+0x2ea>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0105c13:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0105c17:	3c 01                	cmp    $0x1,%al
f0105c19:	74 1d                	je     f0105c38 <mp_init+0x16c>
f0105c1b:	3c 04                	cmp    $0x4,%al
f0105c1d:	74 19                	je     f0105c38 <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105c1f:	83 ec 08             	sub    $0x8,%esp
f0105c22:	0f b6 c0             	movzbl %al,%eax
f0105c25:	50                   	push   %eax
f0105c26:	68 d8 88 10 f0       	push   $0xf01088d8
f0105c2b:	e8 52 dd ff ff       	call   f0103982 <cprintf>
f0105c30:	83 c4 10             	add    $0x10,%esp
f0105c33:	e9 7e 01 00 00       	jmp    f0105db6 <mp_init+0x2ea>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105c38:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f0105c3c:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105c40:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105c45:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f0105c4a:	01 ce                	add    %ecx,%esi
f0105c4c:	eb 0d                	jmp    f0105c5b <mp_init+0x18f>
f0105c4e:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f0105c55:	f0 
f0105c56:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105c58:	83 c0 01             	add    $0x1,%eax
f0105c5b:	39 c7                	cmp    %eax,%edi
f0105c5d:	75 ef                	jne    f0105c4e <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105c5f:	89 d0                	mov    %edx,%eax
f0105c61:	02 43 2a             	add    0x2a(%ebx),%al
f0105c64:	74 15                	je     f0105c7b <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105c66:	83 ec 0c             	sub    $0xc,%esp
f0105c69:	68 f8 88 10 f0       	push   $0xf01088f8
f0105c6e:	e8 0f dd ff ff       	call   f0103982 <cprintf>
f0105c73:	83 c4 10             	add    $0x10,%esp
f0105c76:	e9 3b 01 00 00       	jmp    f0105db6 <mp_init+0x2ea>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0105c7b:	85 db                	test   %ebx,%ebx
f0105c7d:	0f 84 33 01 00 00    	je     f0105db6 <mp_init+0x2ea>
		return;
	ismp = 1;
f0105c83:	c7 05 00 b0 2a f0 01 	movl   $0x1,0xf02ab000
f0105c8a:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105c8d:	8b 43 24             	mov    0x24(%ebx),%eax
f0105c90:	a3 00 c0 2e f0       	mov    %eax,0xf02ec000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105c95:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0105c98:	be 00 00 00 00       	mov    $0x0,%esi
f0105c9d:	e9 85 00 00 00       	jmp    f0105d27 <mp_init+0x25b>
		switch (*p) {
f0105ca2:	0f b6 07             	movzbl (%edi),%eax
f0105ca5:	84 c0                	test   %al,%al
f0105ca7:	74 06                	je     f0105caf <mp_init+0x1e3>
f0105ca9:	3c 04                	cmp    $0x4,%al
f0105cab:	77 55                	ja     f0105d02 <mp_init+0x236>
f0105cad:	eb 4e                	jmp    f0105cfd <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105caf:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105cb3:	74 11                	je     f0105cc6 <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f0105cb5:	6b 05 c4 b3 2a f0 74 	imul   $0x74,0xf02ab3c4,%eax
f0105cbc:	05 20 b0 2a f0       	add    $0xf02ab020,%eax
f0105cc1:	a3 c0 b3 2a f0       	mov    %eax,0xf02ab3c0
			if (ncpu < NCPU) {
f0105cc6:	a1 c4 b3 2a f0       	mov    0xf02ab3c4,%eax
f0105ccb:	83 f8 07             	cmp    $0x7,%eax
f0105cce:	7f 13                	jg     f0105ce3 <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f0105cd0:	6b d0 74             	imul   $0x74,%eax,%edx
f0105cd3:	88 82 20 b0 2a f0    	mov    %al,-0xfd54fe0(%edx)
				ncpu++;
f0105cd9:	83 c0 01             	add    $0x1,%eax
f0105cdc:	a3 c4 b3 2a f0       	mov    %eax,0xf02ab3c4
f0105ce1:	eb 15                	jmp    f0105cf8 <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105ce3:	83 ec 08             	sub    $0x8,%esp
f0105ce6:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105cea:	50                   	push   %eax
f0105ceb:	68 28 89 10 f0       	push   $0xf0108928
f0105cf0:	e8 8d dc ff ff       	call   f0103982 <cprintf>
f0105cf5:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105cf8:	83 c7 14             	add    $0x14,%edi
			continue;
f0105cfb:	eb 27                	jmp    f0105d24 <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105cfd:	83 c7 08             	add    $0x8,%edi
			continue;
f0105d00:	eb 22                	jmp    f0105d24 <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105d02:	83 ec 08             	sub    $0x8,%esp
f0105d05:	0f b6 c0             	movzbl %al,%eax
f0105d08:	50                   	push   %eax
f0105d09:	68 50 89 10 f0       	push   $0xf0108950
f0105d0e:	e8 6f dc ff ff       	call   f0103982 <cprintf>
			ismp = 0;
f0105d13:	c7 05 00 b0 2a f0 00 	movl   $0x0,0xf02ab000
f0105d1a:	00 00 00 
			i = conf->entry;
f0105d1d:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f0105d21:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105d24:	83 c6 01             	add    $0x1,%esi
f0105d27:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0105d2b:	39 c6                	cmp    %eax,%esi
f0105d2d:	0f 82 6f ff ff ff    	jb     f0105ca2 <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105d33:	a1 c0 b3 2a f0       	mov    0xf02ab3c0,%eax
f0105d38:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105d3f:	83 3d 00 b0 2a f0 00 	cmpl   $0x0,0xf02ab000
f0105d46:	75 26                	jne    f0105d6e <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105d48:	c7 05 c4 b3 2a f0 01 	movl   $0x1,0xf02ab3c4
f0105d4f:	00 00 00 
		lapicaddr = 0;
f0105d52:	c7 05 00 c0 2e f0 00 	movl   $0x0,0xf02ec000
f0105d59:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105d5c:	83 ec 0c             	sub    $0xc,%esp
f0105d5f:	68 70 89 10 f0       	push   $0xf0108970
f0105d64:	e8 19 dc ff ff       	call   f0103982 <cprintf>
		return;
f0105d69:	83 c4 10             	add    $0x10,%esp
f0105d6c:	eb 48                	jmp    f0105db6 <mp_init+0x2ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105d6e:	83 ec 04             	sub    $0x4,%esp
f0105d71:	ff 35 c4 b3 2a f0    	pushl  0xf02ab3c4
f0105d77:	0f b6 00             	movzbl (%eax),%eax
f0105d7a:	50                   	push   %eax
f0105d7b:	68 f7 89 10 f0       	push   $0xf01089f7
f0105d80:	e8 fd db ff ff       	call   f0103982 <cprintf>

	if (mp->imcrp) {
f0105d85:	83 c4 10             	add    $0x10,%esp
f0105d88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105d8b:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105d8f:	74 25                	je     f0105db6 <mp_init+0x2ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105d91:	83 ec 0c             	sub    $0xc,%esp
f0105d94:	68 9c 89 10 f0       	push   $0xf010899c
f0105d99:	e8 e4 db ff ff       	call   f0103982 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105d9e:	ba 22 00 00 00       	mov    $0x22,%edx
f0105da3:	b8 70 00 00 00       	mov    $0x70,%eax
f0105da8:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105da9:	ba 23 00 00 00       	mov    $0x23,%edx
f0105dae:	ec                   	in     (%dx),%al
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105daf:	83 c8 01             	or     $0x1,%eax
f0105db2:	ee                   	out    %al,(%dx)
f0105db3:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105db6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105db9:	5b                   	pop    %ebx
f0105dba:	5e                   	pop    %esi
f0105dbb:	5f                   	pop    %edi
f0105dbc:	5d                   	pop    %ebp
f0105dbd:	c3                   	ret    

f0105dbe <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105dbe:	55                   	push   %ebp
f0105dbf:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105dc1:	8b 0d 04 c0 2e f0    	mov    0xf02ec004,%ecx
f0105dc7:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105dca:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105dcc:	a1 04 c0 2e f0       	mov    0xf02ec004,%eax
f0105dd1:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105dd4:	5d                   	pop    %ebp
f0105dd5:	c3                   	ret    

f0105dd6 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105dd6:	55                   	push   %ebp
f0105dd7:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105dd9:	a1 04 c0 2e f0       	mov    0xf02ec004,%eax
f0105dde:	85 c0                	test   %eax,%eax
f0105de0:	74 08                	je     f0105dea <cpunum+0x14>
		return lapic[ID] >> 24;
f0105de2:	8b 40 20             	mov    0x20(%eax),%eax
f0105de5:	c1 e8 18             	shr    $0x18,%eax
f0105de8:	eb 05                	jmp    f0105def <cpunum+0x19>
	return 0;
f0105dea:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105def:	5d                   	pop    %ebp
f0105df0:	c3                   	ret    

f0105df1 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0105df1:	a1 00 c0 2e f0       	mov    0xf02ec000,%eax
f0105df6:	85 c0                	test   %eax,%eax
f0105df8:	0f 84 21 01 00 00    	je     f0105f1f <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0105dfe:	55                   	push   %ebp
f0105dff:	89 e5                	mov    %esp,%ebp
f0105e01:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0105e04:	68 00 10 00 00       	push   $0x1000
f0105e09:	50                   	push   %eax
f0105e0a:	e8 fc b6 ff ff       	call   f010150b <mmio_map_region>
f0105e0f:	a3 04 c0 2e f0       	mov    %eax,0xf02ec004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105e14:	ba 27 01 00 00       	mov    $0x127,%edx
f0105e19:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105e1e:	e8 9b ff ff ff       	call   f0105dbe <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0105e23:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105e28:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105e2d:	e8 8c ff ff ff       	call   f0105dbe <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105e32:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105e37:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105e3c:	e8 7d ff ff ff       	call   f0105dbe <lapicw>
	lapicw(TICR, 10000000); 
f0105e41:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105e46:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105e4b:	e8 6e ff ff ff       	call   f0105dbe <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0105e50:	e8 81 ff ff ff       	call   f0105dd6 <cpunum>
f0105e55:	6b c0 74             	imul   $0x74,%eax,%eax
f0105e58:	05 20 b0 2a f0       	add    $0xf02ab020,%eax
f0105e5d:	83 c4 10             	add    $0x10,%esp
f0105e60:	39 05 c0 b3 2a f0    	cmp    %eax,0xf02ab3c0
f0105e66:	74 0f                	je     f0105e77 <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f0105e68:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105e6d:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105e72:	e8 47 ff ff ff       	call   f0105dbe <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0105e77:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105e7c:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105e81:	e8 38 ff ff ff       	call   f0105dbe <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105e86:	a1 04 c0 2e f0       	mov    0xf02ec004,%eax
f0105e8b:	8b 40 30             	mov    0x30(%eax),%eax
f0105e8e:	c1 e8 10             	shr    $0x10,%eax
f0105e91:	3c 03                	cmp    $0x3,%al
f0105e93:	76 0f                	jbe    f0105ea4 <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f0105e95:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105e9a:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105e9f:	e8 1a ff ff ff       	call   f0105dbe <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105ea4:	ba 33 00 00 00       	mov    $0x33,%edx
f0105ea9:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105eae:	e8 0b ff ff ff       	call   f0105dbe <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0105eb3:	ba 00 00 00 00       	mov    $0x0,%edx
f0105eb8:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105ebd:	e8 fc fe ff ff       	call   f0105dbe <lapicw>
	lapicw(ESR, 0);
f0105ec2:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ec7:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105ecc:	e8 ed fe ff ff       	call   f0105dbe <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0105ed1:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ed6:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105edb:	e8 de fe ff ff       	call   f0105dbe <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0105ee0:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ee5:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105eea:	e8 cf fe ff ff       	call   f0105dbe <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105eef:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105ef4:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105ef9:	e8 c0 fe ff ff       	call   f0105dbe <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105efe:	8b 15 04 c0 2e f0    	mov    0xf02ec004,%edx
f0105f04:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105f0a:	f6 c4 10             	test   $0x10,%ah
f0105f0d:	75 f5                	jne    f0105f04 <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0105f0f:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f14:	b8 20 00 00 00       	mov    $0x20,%eax
f0105f19:	e8 a0 fe ff ff       	call   f0105dbe <lapicw>
}
f0105f1e:	c9                   	leave  
f0105f1f:	f3 c3                	repz ret 

f0105f21 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105f21:	83 3d 04 c0 2e f0 00 	cmpl   $0x0,0xf02ec004
f0105f28:	74 13                	je     f0105f3d <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105f2a:	55                   	push   %ebp
f0105f2b:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0105f2d:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f32:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105f37:	e8 82 fe ff ff       	call   f0105dbe <lapicw>
}
f0105f3c:	5d                   	pop    %ebp
f0105f3d:	f3 c3                	repz ret 

f0105f3f <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105f3f:	55                   	push   %ebp
f0105f40:	89 e5                	mov    %esp,%ebp
f0105f42:	56                   	push   %esi
f0105f43:	53                   	push   %ebx
f0105f44:	8b 75 08             	mov    0x8(%ebp),%esi
f0105f47:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105f4a:	ba 70 00 00 00       	mov    $0x70,%edx
f0105f4f:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105f54:	ee                   	out    %al,(%dx)
f0105f55:	ba 71 00 00 00       	mov    $0x71,%edx
f0105f5a:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105f5f:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105f60:	83 3d 94 ae 2a f0 00 	cmpl   $0x0,0xf02aae94
f0105f67:	75 19                	jne    f0105f82 <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105f69:	68 67 04 00 00       	push   $0x467
f0105f6e:	68 04 6c 10 f0       	push   $0xf0106c04
f0105f73:	68 98 00 00 00       	push   $0x98
f0105f78:	68 14 8a 10 f0       	push   $0xf0108a14
f0105f7d:	e8 be a0 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105f82:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105f89:	00 00 
	wrv[1] = addr >> 4;
f0105f8b:	89 d8                	mov    %ebx,%eax
f0105f8d:	c1 e8 04             	shr    $0x4,%eax
f0105f90:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105f96:	c1 e6 18             	shl    $0x18,%esi
f0105f99:	89 f2                	mov    %esi,%edx
f0105f9b:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105fa0:	e8 19 fe ff ff       	call   f0105dbe <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105fa5:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105faa:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105faf:	e8 0a fe ff ff       	call   f0105dbe <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105fb4:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105fb9:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105fbe:	e8 fb fd ff ff       	call   f0105dbe <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105fc3:	c1 eb 0c             	shr    $0xc,%ebx
f0105fc6:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105fc9:	89 f2                	mov    %esi,%edx
f0105fcb:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105fd0:	e8 e9 fd ff ff       	call   f0105dbe <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105fd5:	89 da                	mov    %ebx,%edx
f0105fd7:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105fdc:	e8 dd fd ff ff       	call   f0105dbe <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105fe1:	89 f2                	mov    %esi,%edx
f0105fe3:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105fe8:	e8 d1 fd ff ff       	call   f0105dbe <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105fed:	89 da                	mov    %ebx,%edx
f0105fef:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105ff4:	e8 c5 fd ff ff       	call   f0105dbe <lapicw>
		microdelay(200);
	}
}
f0105ff9:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105ffc:	5b                   	pop    %ebx
f0105ffd:	5e                   	pop    %esi
f0105ffe:	5d                   	pop    %ebp
f0105fff:	c3                   	ret    

f0106000 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0106000:	55                   	push   %ebp
f0106001:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0106003:	8b 55 08             	mov    0x8(%ebp),%edx
f0106006:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f010600c:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106011:	e8 a8 fd ff ff       	call   f0105dbe <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0106016:	8b 15 04 c0 2e f0    	mov    0xf02ec004,%edx
f010601c:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106022:	f6 c4 10             	test   $0x10,%ah
f0106025:	75 f5                	jne    f010601c <lapic_ipi+0x1c>
		;
}
f0106027:	5d                   	pop    %ebp
f0106028:	c3                   	ret    

f0106029 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0106029:	55                   	push   %ebp
f010602a:	89 e5                	mov    %esp,%ebp
f010602c:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f010602f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0106035:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106038:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f010603b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0106042:	5d                   	pop    %ebp
f0106043:	c3                   	ret    

f0106044 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0106044:	55                   	push   %ebp
f0106045:	89 e5                	mov    %esp,%ebp
f0106047:	56                   	push   %esi
f0106048:	53                   	push   %ebx
f0106049:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f010604c:	83 3b 00             	cmpl   $0x0,(%ebx)
f010604f:	74 14                	je     f0106065 <spin_lock+0x21>
f0106051:	8b 73 08             	mov    0x8(%ebx),%esi
f0106054:	e8 7d fd ff ff       	call   f0105dd6 <cpunum>
f0106059:	6b c0 74             	imul   $0x74,%eax,%eax
f010605c:	05 20 b0 2a f0       	add    $0xf02ab020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0106061:	39 c6                	cmp    %eax,%esi
f0106063:	74 07                	je     f010606c <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0106065:	ba 01 00 00 00       	mov    $0x1,%edx
f010606a:	eb 20                	jmp    f010608c <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f010606c:	8b 5b 04             	mov    0x4(%ebx),%ebx
f010606f:	e8 62 fd ff ff       	call   f0105dd6 <cpunum>
f0106074:	83 ec 0c             	sub    $0xc,%esp
f0106077:	53                   	push   %ebx
f0106078:	50                   	push   %eax
f0106079:	68 24 8a 10 f0       	push   $0xf0108a24
f010607e:	6a 41                	push   $0x41
f0106080:	68 86 8a 10 f0       	push   $0xf0108a86
f0106085:	e8 b6 9f ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f010608a:	f3 90                	pause  
f010608c:	89 d0                	mov    %edx,%eax
f010608e:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106091:	85 c0                	test   %eax,%eax
f0106093:	75 f5                	jne    f010608a <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106095:	e8 3c fd ff ff       	call   f0105dd6 <cpunum>
f010609a:	6b c0 74             	imul   $0x74,%eax,%eax
f010609d:	05 20 b0 2a f0       	add    $0xf02ab020,%eax
f01060a2:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f01060a5:	83 c3 0c             	add    $0xc,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01060a8:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01060aa:	b8 00 00 00 00       	mov    $0x0,%eax
f01060af:	eb 0b                	jmp    f01060bc <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f01060b1:	8b 4a 04             	mov    0x4(%edx),%ecx
f01060b4:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01060b7:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01060b9:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f01060bc:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f01060c2:	76 11                	jbe    f01060d5 <spin_lock+0x91>
f01060c4:	83 f8 09             	cmp    $0x9,%eax
f01060c7:	7e e8                	jle    f01060b1 <spin_lock+0x6d>
f01060c9:	eb 0a                	jmp    f01060d5 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f01060cb:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f01060d2:	83 c0 01             	add    $0x1,%eax
f01060d5:	83 f8 09             	cmp    $0x9,%eax
f01060d8:	7e f1                	jle    f01060cb <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f01060da:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01060dd:	5b                   	pop    %ebx
f01060de:	5e                   	pop    %esi
f01060df:	5d                   	pop    %ebp
f01060e0:	c3                   	ret    

f01060e1 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f01060e1:	55                   	push   %ebp
f01060e2:	89 e5                	mov    %esp,%ebp
f01060e4:	57                   	push   %edi
f01060e5:	56                   	push   %esi
f01060e6:	53                   	push   %ebx
f01060e7:	83 ec 4c             	sub    $0x4c,%esp
f01060ea:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f01060ed:	83 3e 00             	cmpl   $0x0,(%esi)
f01060f0:	74 18                	je     f010610a <spin_unlock+0x29>
f01060f2:	8b 5e 08             	mov    0x8(%esi),%ebx
f01060f5:	e8 dc fc ff ff       	call   f0105dd6 <cpunum>
f01060fa:	6b c0 74             	imul   $0x74,%eax,%eax
f01060fd:	05 20 b0 2a f0       	add    $0xf02ab020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0106102:	39 c3                	cmp    %eax,%ebx
f0106104:	0f 84 a5 00 00 00    	je     f01061af <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f010610a:	83 ec 04             	sub    $0x4,%esp
f010610d:	6a 28                	push   $0x28
f010610f:	8d 46 0c             	lea    0xc(%esi),%eax
f0106112:	50                   	push   %eax
f0106113:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0106116:	53                   	push   %ebx
f0106117:	e8 e7 f6 ff ff       	call   f0105803 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f010611c:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f010611f:	0f b6 38             	movzbl (%eax),%edi
f0106122:	8b 76 04             	mov    0x4(%esi),%esi
f0106125:	e8 ac fc ff ff       	call   f0105dd6 <cpunum>
f010612a:	57                   	push   %edi
f010612b:	56                   	push   %esi
f010612c:	50                   	push   %eax
f010612d:	68 50 8a 10 f0       	push   $0xf0108a50
f0106132:	e8 4b d8 ff ff       	call   f0103982 <cprintf>
f0106137:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f010613a:	8d 7d a8             	lea    -0x58(%ebp),%edi
f010613d:	eb 54                	jmp    f0106193 <spin_unlock+0xb2>
f010613f:	83 ec 08             	sub    $0x8,%esp
f0106142:	57                   	push   %edi
f0106143:	50                   	push   %eax
f0106144:	e8 db eb ff ff       	call   f0104d24 <debuginfo_eip>
f0106149:	83 c4 10             	add    $0x10,%esp
f010614c:	85 c0                	test   %eax,%eax
f010614e:	78 27                	js     f0106177 <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0106150:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106152:	83 ec 04             	sub    $0x4,%esp
f0106155:	89 c2                	mov    %eax,%edx
f0106157:	2b 55 b8             	sub    -0x48(%ebp),%edx
f010615a:	52                   	push   %edx
f010615b:	ff 75 b0             	pushl  -0x50(%ebp)
f010615e:	ff 75 b4             	pushl  -0x4c(%ebp)
f0106161:	ff 75 ac             	pushl  -0x54(%ebp)
f0106164:	ff 75 a8             	pushl  -0x58(%ebp)
f0106167:	50                   	push   %eax
f0106168:	68 96 8a 10 f0       	push   $0xf0108a96
f010616d:	e8 10 d8 ff ff       	call   f0103982 <cprintf>
f0106172:	83 c4 20             	add    $0x20,%esp
f0106175:	eb 12                	jmp    f0106189 <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0106177:	83 ec 08             	sub    $0x8,%esp
f010617a:	ff 36                	pushl  (%esi)
f010617c:	68 ad 8a 10 f0       	push   $0xf0108aad
f0106181:	e8 fc d7 ff ff       	call   f0103982 <cprintf>
f0106186:	83 c4 10             	add    $0x10,%esp
f0106189:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f010618c:	8d 45 e8             	lea    -0x18(%ebp),%eax
f010618f:	39 c3                	cmp    %eax,%ebx
f0106191:	74 08                	je     f010619b <spin_unlock+0xba>
f0106193:	89 de                	mov    %ebx,%esi
f0106195:	8b 03                	mov    (%ebx),%eax
f0106197:	85 c0                	test   %eax,%eax
f0106199:	75 a4                	jne    f010613f <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f010619b:	83 ec 04             	sub    $0x4,%esp
f010619e:	68 b5 8a 10 f0       	push   $0xf0108ab5
f01061a3:	6a 67                	push   $0x67
f01061a5:	68 86 8a 10 f0       	push   $0xf0108a86
f01061aa:	e8 91 9e ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f01061af:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f01061b6:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01061bd:	b8 00 00 00 00       	mov    $0x0,%eax
f01061c2:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f01061c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01061c8:	5b                   	pop    %ebx
f01061c9:	5e                   	pop    %esi
f01061ca:	5f                   	pop    %edi
f01061cb:	5d                   	pop    %ebp
f01061cc:	c3                   	ret    

f01061cd <pci_e1000_attach>:
void e1000_transmit_init();


int 
pci_e1000_attach(struct pci_func *f)
{
f01061cd:	55                   	push   %ebp
f01061ce:	89 e5                	mov    %esp,%ebp
f01061d0:	56                   	push   %esi
f01061d1:	53                   	push   %ebx
f01061d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
    pci_func_enable(f);
f01061d5:	83 ec 0c             	sub    $0xc,%esp
f01061d8:	53                   	push   %ebx
f01061d9:	e8 bb 05 00 00       	call   f0106799 <pci_func_enable>

    if (!f->reg_base[0])
f01061de:	8b 43 14             	mov    0x14(%ebx),%eax
f01061e1:	83 c4 10             	add    $0x10,%esp
f01061e4:	85 c0                	test   %eax,%eax
f01061e6:	0f 84 59 01 00 00    	je     f0106345 <pci_e1000_attach+0x178>
		return -1;

    e1000 = mmio_map_region(f->reg_base[0], f->reg_size[0]);
f01061ec:	83 ec 08             	sub    $0x8,%esp
f01061ef:	ff 73 2c             	pushl  0x2c(%ebx)
f01061f2:	50                   	push   %eax
f01061f3:	e8 13 b3 ff ff       	call   f010150b <mmio_map_region>
f01061f8:	a3 44 7e 2f f0       	mov    %eax,0xf02f7e44

    // status offest is 8
    uint32_t status = *(uint32_t *)E1000_ADDR(8);

    if (status != 0x80080783)
f01061fd:	83 c4 10             	add    $0x10,%esp
f0106200:	81 78 08 83 07 08 80 	cmpl   $0x80080783,0x8(%eax)
f0106207:	0f 85 3f 01 00 00    	jne    f010634c <pci_e1000_attach+0x17f>
f010620d:	b9 40 c0 2e f0       	mov    $0xf02ec040,%ecx
f0106212:	ba 6c 7e 2f f0       	mov    $0xf02f7e6c,%edx
f0106217:	be 40 7e 2f f0       	mov    $0xf02f7e40,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010621c:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f0106222:	77 12                	ja     f0106236 <pci_e1000_attach+0x69>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0106224:	51                   	push   %ecx
f0106225:	68 28 6c 10 f0       	push   $0xf0106c28
f010622a:	6a 2b                	push   $0x2b
f010622c:	68 cd 8a 10 f0       	push   $0xf0108acd
f0106231:	e8 0a 9e ff ff       	call   f0100040 <_panic>

void 
e1000_transmit_init()
{
    for (int i = 0; i < 32; i++) {
        transmit_desc_array[i].addr = PADDR(transmit_buffer[i]);
f0106236:	8d 99 00 00 00 10    	lea    0x10000000(%ecx),%ebx
f010623c:	89 5a f4             	mov    %ebx,-0xc(%edx)
f010623f:	c7 42 f8 00 00 00 00 	movl   $0x0,-0x8(%edx)
        transmit_desc_array[i].cmd = 0;
f0106246:	c6 42 ff 00          	movb   $0x0,-0x1(%edx)
        transmit_desc_array[i].status |= E1000_TXD_STAT_DD;
f010624a:	80 0a 01             	orb    $0x1,(%edx)
f010624d:	81 c1 f0 05 00 00    	add    $0x5f0,%ecx
f0106253:	83 c2 10             	add    $0x10,%edx
}

void 
e1000_transmit_init()
{
    for (int i = 0; i < 32; i++) {
f0106256:	39 f1                	cmp    %esi,%ecx
f0106258:	75 c2                	jne    f010621c <pci_e1000_attach+0x4f>
        transmit_desc_array[i].cmd = 0;
        transmit_desc_array[i].status |= E1000_TXD_STAT_DD;
    }

    struct e1000_tdlen *tdlen = (struct e1000_tdlen *)E1000_ADDR(E1000_TDLEN);
    tdlen->len = 32;
f010625a:	8b 90 08 38 00 00    	mov    0x3808(%eax),%edx
f0106260:	81 e2 7f 00 f0 ff    	and    $0xfff0007f,%edx
f0106266:	80 ce 10             	or     $0x10,%dh
f0106269:	89 90 08 38 00 00    	mov    %edx,0x3808(%eax)
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010626f:	ba 60 7e 2f f0       	mov    $0xf02f7e60,%edx
f0106274:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010627a:	77 12                	ja     f010628e <pci_e1000_attach+0xc1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010627c:	52                   	push   %edx
f010627d:	68 28 6c 10 f0       	push   $0xf0106c28
f0106282:	6a 34                	push   $0x34
f0106284:	68 cd 8a 10 f0       	push   $0xf0108acd
f0106289:	e8 b2 9d ff ff       	call   f0100040 <_panic>

    uint32_t *tdbal = (uint32_t *)E1000_ADDR(E1000_TDBAL);
    *tdbal = PADDR(transmit_desc_array);
f010628e:	c7 80 00 38 00 00 60 	movl   $0x2f7e60,0x3800(%eax)
f0106295:	7e 2f 00 

    uint32_t *tdbah = (uint32_t *)E1000_ADDR(E1000_TDBAH);
    *tdbah = 0;
f0106298:	c7 80 04 38 00 00 00 	movl   $0x0,0x3804(%eax)
f010629f:	00 00 00 

    tdh = (struct e1000_tdh *)E1000_ADDR(E1000_TDH);
f01062a2:	8d 90 10 38 00 00    	lea    0x3810(%eax),%edx
f01062a8:	89 15 20 c0 2e f0    	mov    %edx,0xf02ec020
    tdh->tdh = 0;
f01062ae:	66 c7 80 10 38 00 00 	movw   $0x0,0x3810(%eax)
f01062b5:	00 00 

    tdt = (struct e1000_tdt *)E1000_ADDR(E1000_TDT);
f01062b7:	8d 90 18 38 00 00    	lea    0x3818(%eax),%edx
f01062bd:	89 15 40 7e 2f f0    	mov    %edx,0xf02f7e40
    tdt->tdt = 0;
f01062c3:	66 c7 80 18 38 00 00 	movw   $0x0,0x3818(%eax)
f01062ca:	00 00 

    struct e1000_tctl *tctl = (struct e1000_tctl *)E1000_ADDR(E1000_TCTL);
    tctl->en = 1;
    tctl->psp = 1;
f01062cc:	80 88 00 04 00 00 0a 	orb    $0xa,0x400(%eax)
    tctl->ct = 0x10;
f01062d3:	0f b7 90 00 04 00 00 	movzwl 0x400(%eax),%edx
f01062da:	66 81 e2 0f f0       	and    $0xf00f,%dx
f01062df:	80 ce 01             	or     $0x1,%dh
f01062e2:	66 89 90 00 04 00 00 	mov    %dx,0x400(%eax)
    tctl->cold = 0x40;
f01062e9:	8b 90 00 04 00 00    	mov    0x400(%eax),%edx
f01062ef:	81 e2 ff 0f c0 ff    	and    $0xffc00fff,%edx
f01062f5:	81 ca 00 00 04 00    	or     $0x40000,%edx
f01062fb:	89 90 00 04 00 00    	mov    %edx,0x400(%eax)

    struct e1000_tipg *tipg = (struct e1000_tipg *)E1000_ADDR(E1000_TIPG);
    tipg->ipgt = 10;
f0106301:	0f b7 90 10 04 00 00 	movzwl 0x410(%eax),%edx
f0106308:	66 81 e2 00 fc       	and    $0xfc00,%dx
f010630d:	83 ca 0a             	or     $0xa,%edx
f0106310:	66 89 90 10 04 00 00 	mov    %dx,0x410(%eax)
    tipg->ipgr1 = 4;
f0106317:	8b 90 10 04 00 00    	mov    0x410(%eax),%edx
f010631d:	81 e2 ff 03 f0 ff    	and    $0xfff003ff,%edx
f0106323:	80 ce 10             	or     $0x10,%dh
f0106326:	89 90 10 04 00 00    	mov    %edx,0x410(%eax)
    tipg->ipgr2 = 6;
f010632c:	c1 ea 10             	shr    $0x10,%edx
f010632f:	66 81 e2 0f c0       	and    $0xc00f,%dx
f0106334:	83 ca 60             	or     $0x60,%edx
f0106337:	66 89 90 12 04 00 00 	mov    %dx,0x412(%eax)
        return -1;
    
    e1000_transmit_init();
    // e1000_receive_init();

    return 0;
f010633e:	b8 00 00 00 00       	mov    $0x0,%eax
f0106343:	eb 0c                	jmp    f0106351 <pci_e1000_attach+0x184>
pci_e1000_attach(struct pci_func *f)
{
    pci_func_enable(f);

    if (!f->reg_base[0])
		return -1;
f0106345:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010634a:	eb 05                	jmp    f0106351 <pci_e1000_attach+0x184>

    // status offest is 8
    uint32_t status = *(uint32_t *)E1000_ADDR(8);

    if (status != 0x80080783)
        return -1;
f010634c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    
    e1000_transmit_init();
    // e1000_receive_init();

    return 0;
}
f0106351:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106354:	5b                   	pop    %ebx
f0106355:	5e                   	pop    %esi
f0106356:	5d                   	pop    %ebp
f0106357:	c3                   	ret    

f0106358 <e1000_transmit>:
}


int
e1000_transmit(char *data, uint32_t len)
{
f0106358:	55                   	push   %ebp
f0106359:	89 e5                	mov    %esp,%ebp
f010635b:	53                   	push   %ebx
f010635c:	83 ec 04             	sub    $0x4,%esp
f010635f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
    uint32_t current = tdt->tdt;
f0106362:	a1 40 7e 2f f0       	mov    0xf02f7e40,%eax
f0106367:	0f b7 18             	movzwl (%eax),%ebx

    if(!(transmit_desc_array[current].status & E1000_TXD_STAT_DD)) {
f010636a:	89 d8                	mov    %ebx,%eax
f010636c:	c1 e0 04             	shl    $0x4,%eax
f010636f:	0f b6 90 6c 7e 2f f0 	movzbl -0xfd08194(%eax),%edx
f0106376:	f6 c2 01             	test   $0x1,%dl
f0106379:	74 4e                	je     f01063c9 <e1000_transmit+0x71>
        return -1;
    }

    transmit_desc_array[current].length = len;
f010637b:	89 d8                	mov    %ebx,%eax
f010637d:	c1 e0 04             	shl    $0x4,%eax
f0106380:	66 89 88 68 7e 2f f0 	mov    %cx,-0xfd08198(%eax)
    transmit_desc_array[current].status &= ~E1000_TXD_STAT_DD;
f0106387:	83 e2 fe             	and    $0xfffffffe,%edx
f010638a:	88 90 6c 7e 2f f0    	mov    %dl,-0xfd08194(%eax)

    if(!(transmit_desc_array[current].status & E1000_TXD_STAT_DD)) {
        return -1;
    }

    transmit_desc_array[current].length = len;
f0106390:	05 60 7e 2f f0       	add    $0xf02f7e60,%eax
    transmit_desc_array[current].status &= ~E1000_TXD_STAT_DD;
    transmit_desc_array[current].cmd |= (E1000_TXD_CMD_EOP | E1000_TXD_CMD_RS);
f0106395:	80 48 0b 09          	orb    $0x9,0xb(%eax)

    memcpy(transmit_buffer[current], data, len);
f0106399:	83 ec 04             	sub    $0x4,%esp
f010639c:	51                   	push   %ecx
f010639d:	ff 75 08             	pushl  0x8(%ebp)
f01063a0:	69 c3 f0 05 00 00    	imul   $0x5f0,%ebx,%eax
f01063a6:	05 40 c0 2e f0       	add    $0xf02ec040,%eax
f01063ab:	50                   	push   %eax
f01063ac:	e8 ba f4 ff ff       	call   f010586b <memcpy>
    uint32_t next = (current + 1) % 32;
    tdt->tdt = next;
f01063b1:	83 c3 01             	add    $0x1,%ebx
f01063b4:	83 e3 1f             	and    $0x1f,%ebx
f01063b7:	a1 40 7e 2f f0       	mov    0xf02f7e40,%eax
f01063bc:	66 89 18             	mov    %bx,(%eax)

    return 0;
f01063bf:	83 c4 10             	add    $0x10,%esp
f01063c2:	b8 00 00 00 00       	mov    $0x0,%eax
f01063c7:	eb 05                	jmp    f01063ce <e1000_transmit+0x76>
e1000_transmit(char *data, uint32_t len)
{
    uint32_t current = tdt->tdt;

    if(!(transmit_desc_array[current].status & E1000_TXD_STAT_DD)) {
        return -1;
f01063c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    memcpy(transmit_buffer[current], data, len);
    uint32_t next = (current + 1) % 32;
    tdt->tdt = next;

    return 0;
f01063ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01063d1:	c9                   	leave  
f01063d2:	c3                   	ret    

f01063d3 <pci_attach_match>:
}

static int __attribute__((warn_unused_result))
pci_attach_match(uint32_t key1, uint32_t key2,
		 struct pci_driver *list, struct pci_func *pcif)
{
f01063d3:	55                   	push   %ebp
f01063d4:	89 e5                	mov    %esp,%ebp
f01063d6:	57                   	push   %edi
f01063d7:	56                   	push   %esi
f01063d8:	53                   	push   %ebx
f01063d9:	83 ec 0c             	sub    $0xc,%esp
f01063dc:	8b 7d 08             	mov    0x8(%ebp),%edi
f01063df:	8b 45 10             	mov    0x10(%ebp),%eax
f01063e2:	8d 58 08             	lea    0x8(%eax),%ebx
	uint32_t i;

	for (i = 0; list[i].attachfn; i++) {
f01063e5:	eb 3a                	jmp    f0106421 <pci_attach_match+0x4e>
		if (list[i].key1 == key1 && list[i].key2 == key2) {
f01063e7:	39 7b f8             	cmp    %edi,-0x8(%ebx)
f01063ea:	75 32                	jne    f010641e <pci_attach_match+0x4b>
f01063ec:	8b 55 0c             	mov    0xc(%ebp),%edx
f01063ef:	39 56 fc             	cmp    %edx,-0x4(%esi)
f01063f2:	75 2a                	jne    f010641e <pci_attach_match+0x4b>
			int r = list[i].attachfn(pcif);
f01063f4:	83 ec 0c             	sub    $0xc,%esp
f01063f7:	ff 75 14             	pushl  0x14(%ebp)
f01063fa:	ff d0                	call   *%eax
			if (r > 0)
f01063fc:	83 c4 10             	add    $0x10,%esp
f01063ff:	85 c0                	test   %eax,%eax
f0106401:	7f 26                	jg     f0106429 <pci_attach_match+0x56>
				return r;
			if (r < 0)
f0106403:	85 c0                	test   %eax,%eax
f0106405:	79 17                	jns    f010641e <pci_attach_match+0x4b>
				cprintf("pci_attach_match: attaching "
f0106407:	83 ec 0c             	sub    $0xc,%esp
f010640a:	50                   	push   %eax
f010640b:	ff 36                	pushl  (%esi)
f010640d:	ff 75 0c             	pushl  0xc(%ebp)
f0106410:	57                   	push   %edi
f0106411:	68 dc 8a 10 f0       	push   $0xf0108adc
f0106416:	e8 67 d5 ff ff       	call   f0103982 <cprintf>
f010641b:	83 c4 20             	add    $0x20,%esp
f010641e:	83 c3 0c             	add    $0xc,%ebx
f0106421:	89 de                	mov    %ebx,%esi
pci_attach_match(uint32_t key1, uint32_t key2,
		 struct pci_driver *list, struct pci_func *pcif)
{
	uint32_t i;

	for (i = 0; list[i].attachfn; i++) {
f0106423:	8b 03                	mov    (%ebx),%eax
f0106425:	85 c0                	test   %eax,%eax
f0106427:	75 be                	jne    f01063e7 <pci_attach_match+0x14>
					"%x.%x (%p): e\n",
					key1, key2, list[i].attachfn, r);
		}
	}
	return 0;
}
f0106429:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010642c:	5b                   	pop    %ebx
f010642d:	5e                   	pop    %esi
f010642e:	5f                   	pop    %edi
f010642f:	5d                   	pop    %ebp
f0106430:	c3                   	ret    

f0106431 <pci_conf1_set_addr>:
static void
pci_conf1_set_addr(uint32_t bus,
		   uint32_t dev,
		   uint32_t func,
		   uint32_t offset)
{
f0106431:	55                   	push   %ebp
f0106432:	89 e5                	mov    %esp,%ebp
f0106434:	53                   	push   %ebx
f0106435:	83 ec 04             	sub    $0x4,%esp
f0106438:	8b 5d 08             	mov    0x8(%ebp),%ebx
	assert(bus < 256);
f010643b:	3d ff 00 00 00       	cmp    $0xff,%eax
f0106440:	76 16                	jbe    f0106458 <pci_conf1_set_addr+0x27>
f0106442:	68 34 8c 10 f0       	push   $0xf0108c34
f0106447:	68 e5 71 10 f0       	push   $0xf01071e5
f010644c:	6a 2c                	push   $0x2c
f010644e:	68 3e 8c 10 f0       	push   $0xf0108c3e
f0106453:	e8 e8 9b ff ff       	call   f0100040 <_panic>
	assert(dev < 32);
f0106458:	83 fa 1f             	cmp    $0x1f,%edx
f010645b:	76 16                	jbe    f0106473 <pci_conf1_set_addr+0x42>
f010645d:	68 49 8c 10 f0       	push   $0xf0108c49
f0106462:	68 e5 71 10 f0       	push   $0xf01071e5
f0106467:	6a 2d                	push   $0x2d
f0106469:	68 3e 8c 10 f0       	push   $0xf0108c3e
f010646e:	e8 cd 9b ff ff       	call   f0100040 <_panic>
	assert(func < 8);
f0106473:	83 f9 07             	cmp    $0x7,%ecx
f0106476:	76 16                	jbe    f010648e <pci_conf1_set_addr+0x5d>
f0106478:	68 52 8c 10 f0       	push   $0xf0108c52
f010647d:	68 e5 71 10 f0       	push   $0xf01071e5
f0106482:	6a 2e                	push   $0x2e
f0106484:	68 3e 8c 10 f0       	push   $0xf0108c3e
f0106489:	e8 b2 9b ff ff       	call   f0100040 <_panic>
	assert(offset < 256);
f010648e:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f0106494:	76 16                	jbe    f01064ac <pci_conf1_set_addr+0x7b>
f0106496:	68 5b 8c 10 f0       	push   $0xf0108c5b
f010649b:	68 e5 71 10 f0       	push   $0xf01071e5
f01064a0:	6a 2f                	push   $0x2f
f01064a2:	68 3e 8c 10 f0       	push   $0xf0108c3e
f01064a7:	e8 94 9b ff ff       	call   f0100040 <_panic>
	assert((offset & 0x3) == 0);
f01064ac:	f6 c3 03             	test   $0x3,%bl
f01064af:	74 16                	je     f01064c7 <pci_conf1_set_addr+0x96>
f01064b1:	68 68 8c 10 f0       	push   $0xf0108c68
f01064b6:	68 e5 71 10 f0       	push   $0xf01071e5
f01064bb:	6a 30                	push   $0x30
f01064bd:	68 3e 8c 10 f0       	push   $0xf0108c3e
f01064c2:	e8 79 9b ff ff       	call   f0100040 <_panic>
}

static inline void
outl(int port, uint32_t data)
{
	asm volatile("outl %0,%w1" : : "a" (data), "d" (port));
f01064c7:	c1 e1 08             	shl    $0x8,%ecx
f01064ca:	81 cb 00 00 00 80    	or     $0x80000000,%ebx
f01064d0:	09 cb                	or     %ecx,%ebx
f01064d2:	c1 e2 0b             	shl    $0xb,%edx
f01064d5:	09 d3                	or     %edx,%ebx
f01064d7:	c1 e0 10             	shl    $0x10,%eax
f01064da:	09 d8                	or     %ebx,%eax
f01064dc:	ba f8 0c 00 00       	mov    $0xcf8,%edx
f01064e1:	ef                   	out    %eax,(%dx)

	uint32_t v = (1 << 31) |		// config-space
		(bus << 16) | (dev << 11) | (func << 8) | (offset);
	outl(pci_conf1_addr_ioport, v);
}
f01064e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01064e5:	c9                   	leave  
f01064e6:	c3                   	ret    

f01064e7 <pci_conf_read>:

static uint32_t
pci_conf_read(struct pci_func *f, uint32_t off)
{
f01064e7:	55                   	push   %ebp
f01064e8:	89 e5                	mov    %esp,%ebp
f01064ea:	53                   	push   %ebx
f01064eb:	83 ec 10             	sub    $0x10,%esp
	pci_conf1_set_addr(f->bus->busno, f->dev, f->func, off);
f01064ee:	8b 48 08             	mov    0x8(%eax),%ecx
f01064f1:	8b 58 04             	mov    0x4(%eax),%ebx
f01064f4:	8b 00                	mov    (%eax),%eax
f01064f6:	8b 40 04             	mov    0x4(%eax),%eax
f01064f9:	52                   	push   %edx
f01064fa:	89 da                	mov    %ebx,%edx
f01064fc:	e8 30 ff ff ff       	call   f0106431 <pci_conf1_set_addr>

static inline uint32_t
inl(int port)
{
	uint32_t data;
	asm volatile("inl %w1,%0" : "=a" (data) : "d" (port));
f0106501:	ba fc 0c 00 00       	mov    $0xcfc,%edx
f0106506:	ed                   	in     (%dx),%eax
	return inl(pci_conf1_data_ioport);
}
f0106507:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010650a:	c9                   	leave  
f010650b:	c3                   	ret    

f010650c <pci_scan_bus>:
		f->irq_line);
}

static int
pci_scan_bus(struct pci_bus *bus)
{
f010650c:	55                   	push   %ebp
f010650d:	89 e5                	mov    %esp,%ebp
f010650f:	57                   	push   %edi
f0106510:	56                   	push   %esi
f0106511:	53                   	push   %ebx
f0106512:	81 ec 00 01 00 00    	sub    $0x100,%esp
f0106518:	89 c3                	mov    %eax,%ebx
	int totaldev = 0;
	struct pci_func df;
	memset(&df, 0, sizeof(df));
f010651a:	6a 48                	push   $0x48
f010651c:	6a 00                	push   $0x0
f010651e:	8d 45 a0             	lea    -0x60(%ebp),%eax
f0106521:	50                   	push   %eax
f0106522:	e8 8f f2 ff ff       	call   f01057b6 <memset>
	df.bus = bus;
f0106527:	89 5d a0             	mov    %ebx,-0x60(%ebp)

	for (df.dev = 0; df.dev < 32; df.dev++) {
f010652a:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f0106531:	83 c4 10             	add    $0x10,%esp
}

static int
pci_scan_bus(struct pci_bus *bus)
{
	int totaldev = 0;
f0106534:	c7 85 00 ff ff ff 00 	movl   $0x0,-0x100(%ebp)
f010653b:	00 00 00 
	struct pci_func df;
	memset(&df, 0, sizeof(df));
	df.bus = bus;

	for (df.dev = 0; df.dev < 32; df.dev++) {
		uint32_t bhlc = pci_conf_read(&df, PCI_BHLC_REG);
f010653e:	ba 0c 00 00 00       	mov    $0xc,%edx
f0106543:	8d 45 a0             	lea    -0x60(%ebp),%eax
f0106546:	e8 9c ff ff ff       	call   f01064e7 <pci_conf_read>
		if (PCI_HDRTYPE_TYPE(bhlc) > 1)	    // Unsupported or no device
f010654b:	89 c2                	mov    %eax,%edx
f010654d:	c1 ea 10             	shr    $0x10,%edx
f0106550:	83 e2 7f             	and    $0x7f,%edx
f0106553:	83 fa 01             	cmp    $0x1,%edx
f0106556:	0f 87 4b 01 00 00    	ja     f01066a7 <pci_scan_bus+0x19b>
			continue;

		totaldev++;
f010655c:	83 85 00 ff ff ff 01 	addl   $0x1,-0x100(%ebp)

		struct pci_func f = df;
f0106563:	8d bd 10 ff ff ff    	lea    -0xf0(%ebp),%edi
f0106569:	8d 75 a0             	lea    -0x60(%ebp),%esi
f010656c:	b9 12 00 00 00       	mov    $0x12,%ecx
f0106571:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f0106573:	c7 85 18 ff ff ff 00 	movl   $0x0,-0xe8(%ebp)
f010657a:	00 00 00 
f010657d:	25 00 00 80 00       	and    $0x800000,%eax
f0106582:	83 f8 01             	cmp    $0x1,%eax
f0106585:	19 c0                	sbb    %eax,%eax
f0106587:	83 e0 f9             	and    $0xfffffff9,%eax
f010658a:	83 c0 08             	add    $0x8,%eax
f010658d:	89 85 04 ff ff ff    	mov    %eax,-0xfc(%ebp)

			af.dev_id = pci_conf_read(&f, PCI_ID_REG);
			if (PCI_VENDOR(af.dev_id) == 0xffff)
				continue;

			uint32_t intr = pci_conf_read(&af, PCI_INTERRUPT_REG);
f0106593:	8d 9d 58 ff ff ff    	lea    -0xa8(%ebp),%ebx
			continue;

		totaldev++;

		struct pci_func f = df;
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f0106599:	e9 f7 00 00 00       	jmp    f0106695 <pci_scan_bus+0x189>
		     f.func++) {
			struct pci_func af = f;
f010659e:	8d bd 58 ff ff ff    	lea    -0xa8(%ebp),%edi
f01065a4:	8d b5 10 ff ff ff    	lea    -0xf0(%ebp),%esi
f01065aa:	b9 12 00 00 00       	mov    $0x12,%ecx
f01065af:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

			af.dev_id = pci_conf_read(&f, PCI_ID_REG);
f01065b1:	ba 00 00 00 00       	mov    $0x0,%edx
f01065b6:	8d 85 10 ff ff ff    	lea    -0xf0(%ebp),%eax
f01065bc:	e8 26 ff ff ff       	call   f01064e7 <pci_conf_read>
f01065c1:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
			if (PCI_VENDOR(af.dev_id) == 0xffff)
f01065c7:	66 83 f8 ff          	cmp    $0xffff,%ax
f01065cb:	0f 84 bd 00 00 00    	je     f010668e <pci_scan_bus+0x182>
				continue;

			uint32_t intr = pci_conf_read(&af, PCI_INTERRUPT_REG);
f01065d1:	ba 3c 00 00 00       	mov    $0x3c,%edx
f01065d6:	89 d8                	mov    %ebx,%eax
f01065d8:	e8 0a ff ff ff       	call   f01064e7 <pci_conf_read>
			af.irq_line = PCI_INTERRUPT_LINE(intr);
f01065dd:	88 45 9c             	mov    %al,-0x64(%ebp)

			af.dev_class = pci_conf_read(&af, PCI_CLASS_REG);
f01065e0:	ba 08 00 00 00       	mov    $0x8,%edx
f01065e5:	89 d8                	mov    %ebx,%eax
f01065e7:	e8 fb fe ff ff       	call   f01064e7 <pci_conf_read>
f01065ec:	89 85 68 ff ff ff    	mov    %eax,-0x98(%ebp)

static void
pci_print_func(struct pci_func *f)
{
	const char *class = pci_class[0];
	if (PCI_CLASS(f->dev_class) < ARRAY_SIZE(pci_class))
f01065f2:	89 c1                	mov    %eax,%ecx
f01065f4:	c1 e9 18             	shr    $0x18,%ecx
};

static void
pci_print_func(struct pci_func *f)
{
	const char *class = pci_class[0];
f01065f7:	be 7c 8c 10 f0       	mov    $0xf0108c7c,%esi
	if (PCI_CLASS(f->dev_class) < ARRAY_SIZE(pci_class))
f01065fc:	83 f9 06             	cmp    $0x6,%ecx
f01065ff:	77 07                	ja     f0106608 <pci_scan_bus+0xfc>
		class = pci_class[PCI_CLASS(f->dev_class)];
f0106601:	8b 34 8d f0 8c 10 f0 	mov    -0xfef7310(,%ecx,4),%esi

	cprintf("PCI: %02x:%02x.%d: %04x:%04x: class: %x.%x (%s) irq: %d\n",
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
f0106608:	8b 95 64 ff ff ff    	mov    -0x9c(%ebp),%edx
{
	const char *class = pci_class[0];
	if (PCI_CLASS(f->dev_class) < ARRAY_SIZE(pci_class))
		class = pci_class[PCI_CLASS(f->dev_class)];

	cprintf("PCI: %02x:%02x.%d: %04x:%04x: class: %x.%x (%s) irq: %d\n",
f010660e:	83 ec 08             	sub    $0x8,%esp
f0106611:	0f b6 7d 9c          	movzbl -0x64(%ebp),%edi
f0106615:	57                   	push   %edi
f0106616:	56                   	push   %esi
f0106617:	c1 e8 10             	shr    $0x10,%eax
f010661a:	0f b6 c0             	movzbl %al,%eax
f010661d:	50                   	push   %eax
f010661e:	51                   	push   %ecx
f010661f:	89 d0                	mov    %edx,%eax
f0106621:	c1 e8 10             	shr    $0x10,%eax
f0106624:	50                   	push   %eax
f0106625:	0f b7 d2             	movzwl %dx,%edx
f0106628:	52                   	push   %edx
f0106629:	ff b5 60 ff ff ff    	pushl  -0xa0(%ebp)
f010662f:	ff b5 5c ff ff ff    	pushl  -0xa4(%ebp)
f0106635:	8b 85 58 ff ff ff    	mov    -0xa8(%ebp),%eax
f010663b:	ff 70 04             	pushl  0x4(%eax)
f010663e:	68 08 8b 10 f0       	push   $0xf0108b08
f0106643:	e8 3a d3 ff ff       	call   f0103982 <cprintf>
static int
pci_attach(struct pci_func *f)
{
	return
		pci_attach_match(PCI_CLASS(f->dev_class),
				 PCI_SUBCLASS(f->dev_class),
f0106648:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax

static int
pci_attach(struct pci_func *f)
{
	return
		pci_attach_match(PCI_CLASS(f->dev_class),
f010664e:	83 c4 30             	add    $0x30,%esp
f0106651:	53                   	push   %ebx
f0106652:	68 0c 34 12 f0       	push   $0xf012340c
f0106657:	89 c2                	mov    %eax,%edx
f0106659:	c1 ea 10             	shr    $0x10,%edx
f010665c:	0f b6 d2             	movzbl %dl,%edx
f010665f:	52                   	push   %edx
f0106660:	c1 e8 18             	shr    $0x18,%eax
f0106663:	50                   	push   %eax
f0106664:	e8 6a fd ff ff       	call   f01063d3 <pci_attach_match>
				 PCI_SUBCLASS(f->dev_class),
				 &pci_attach_class[0], f) ||
f0106669:	83 c4 10             	add    $0x10,%esp
f010666c:	85 c0                	test   %eax,%eax
f010666e:	75 1e                	jne    f010668e <pci_scan_bus+0x182>
		pci_attach_match(PCI_VENDOR(f->dev_id),
				 PCI_PRODUCT(f->dev_id),
f0106670:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
{
	return
		pci_attach_match(PCI_CLASS(f->dev_class),
				 PCI_SUBCLASS(f->dev_class),
				 &pci_attach_class[0], f) ||
		pci_attach_match(PCI_VENDOR(f->dev_id),
f0106676:	53                   	push   %ebx
f0106677:	68 f4 33 12 f0       	push   $0xf01233f4
f010667c:	89 c2                	mov    %eax,%edx
f010667e:	c1 ea 10             	shr    $0x10,%edx
f0106681:	52                   	push   %edx
f0106682:	0f b7 c0             	movzwl %ax,%eax
f0106685:	50                   	push   %eax
f0106686:	e8 48 fd ff ff       	call   f01063d3 <pci_attach_match>
f010668b:	83 c4 10             	add    $0x10,%esp

		totaldev++;

		struct pci_func f = df;
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
		     f.func++) {
f010668e:	83 85 18 ff ff ff 01 	addl   $0x1,-0xe8(%ebp)
			continue;

		totaldev++;

		struct pci_func f = df;
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f0106695:	8b 85 04 ff ff ff    	mov    -0xfc(%ebp),%eax
f010669b:	3b 85 18 ff ff ff    	cmp    -0xe8(%ebp),%eax
f01066a1:	0f 87 f7 fe ff ff    	ja     f010659e <pci_scan_bus+0x92>
	int totaldev = 0;
	struct pci_func df;
	memset(&df, 0, sizeof(df));
	df.bus = bus;

	for (df.dev = 0; df.dev < 32; df.dev++) {
f01066a7:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f01066aa:	83 c0 01             	add    $0x1,%eax
f01066ad:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f01066b0:	83 f8 1f             	cmp    $0x1f,%eax
f01066b3:	0f 86 85 fe ff ff    	jbe    f010653e <pci_scan_bus+0x32>
			pci_attach(&af);
		}
	}

	return totaldev;
}
f01066b9:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
f01066bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01066c2:	5b                   	pop    %ebx
f01066c3:	5e                   	pop    %esi
f01066c4:	5f                   	pop    %edi
f01066c5:	5d                   	pop    %ebp
f01066c6:	c3                   	ret    

f01066c7 <pci_bridge_attach>:

static int
pci_bridge_attach(struct pci_func *pcif)
{
f01066c7:	55                   	push   %ebp
f01066c8:	89 e5                	mov    %esp,%ebp
f01066ca:	57                   	push   %edi
f01066cb:	56                   	push   %esi
f01066cc:	53                   	push   %ebx
f01066cd:	83 ec 1c             	sub    $0x1c,%esp
f01066d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32_t ioreg  = pci_conf_read(pcif, PCI_BRIDGE_STATIO_REG);
f01066d3:	ba 1c 00 00 00       	mov    $0x1c,%edx
f01066d8:	89 d8                	mov    %ebx,%eax
f01066da:	e8 08 fe ff ff       	call   f01064e7 <pci_conf_read>
f01066df:	89 c7                	mov    %eax,%edi
	uint32_t busreg = pci_conf_read(pcif, PCI_BRIDGE_BUS_REG);
f01066e1:	ba 18 00 00 00       	mov    $0x18,%edx
f01066e6:	89 d8                	mov    %ebx,%eax
f01066e8:	e8 fa fd ff ff       	call   f01064e7 <pci_conf_read>

	if (PCI_BRIDGE_IO_32BITS(ioreg)) {
f01066ed:	83 e7 0f             	and    $0xf,%edi
f01066f0:	83 ff 01             	cmp    $0x1,%edi
f01066f3:	75 1f                	jne    f0106714 <pci_bridge_attach+0x4d>
		cprintf("PCI: %02x:%02x.%d: 32-bit bridge IO not supported.\n",
f01066f5:	ff 73 08             	pushl  0x8(%ebx)
f01066f8:	ff 73 04             	pushl  0x4(%ebx)
f01066fb:	8b 03                	mov    (%ebx),%eax
f01066fd:	ff 70 04             	pushl  0x4(%eax)
f0106700:	68 44 8b 10 f0       	push   $0xf0108b44
f0106705:	e8 78 d2 ff ff       	call   f0103982 <cprintf>
			pcif->bus->busno, pcif->dev, pcif->func);
		return 0;
f010670a:	83 c4 10             	add    $0x10,%esp
f010670d:	b8 00 00 00 00       	mov    $0x0,%eax
f0106712:	eb 4e                	jmp    f0106762 <pci_bridge_attach+0x9b>
f0106714:	89 c6                	mov    %eax,%esi
	}

	struct pci_bus nbus;
	memset(&nbus, 0, sizeof(nbus));
f0106716:	83 ec 04             	sub    $0x4,%esp
f0106719:	6a 08                	push   $0x8
f010671b:	6a 00                	push   $0x0
f010671d:	8d 7d e0             	lea    -0x20(%ebp),%edi
f0106720:	57                   	push   %edi
f0106721:	e8 90 f0 ff ff       	call   f01057b6 <memset>
	nbus.parent_bridge = pcif;
f0106726:	89 5d e0             	mov    %ebx,-0x20(%ebp)
	nbus.busno = (busreg >> PCI_BRIDGE_BUS_SECONDARY_SHIFT) & 0xff;
f0106729:	89 f0                	mov    %esi,%eax
f010672b:	0f b6 c4             	movzbl %ah,%eax
f010672e:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	if (pci_show_devs)
		cprintf("PCI: %02x:%02x.%d: bridge to PCI bus %d--%d\n",
f0106731:	83 c4 08             	add    $0x8,%esp
f0106734:	89 f2                	mov    %esi,%edx
f0106736:	c1 ea 10             	shr    $0x10,%edx
f0106739:	0f b6 f2             	movzbl %dl,%esi
f010673c:	56                   	push   %esi
f010673d:	50                   	push   %eax
f010673e:	ff 73 08             	pushl  0x8(%ebx)
f0106741:	ff 73 04             	pushl  0x4(%ebx)
f0106744:	8b 03                	mov    (%ebx),%eax
f0106746:	ff 70 04             	pushl  0x4(%eax)
f0106749:	68 78 8b 10 f0       	push   $0xf0108b78
f010674e:	e8 2f d2 ff ff       	call   f0103982 <cprintf>
			pcif->bus->busno, pcif->dev, pcif->func,
			nbus.busno,
			(busreg >> PCI_BRIDGE_BUS_SUBORDINATE_SHIFT) & 0xff);

	pci_scan_bus(&nbus);
f0106753:	83 c4 20             	add    $0x20,%esp
f0106756:	89 f8                	mov    %edi,%eax
f0106758:	e8 af fd ff ff       	call   f010650c <pci_scan_bus>
	return 1;
f010675d:	b8 01 00 00 00       	mov    $0x1,%eax
}
f0106762:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106765:	5b                   	pop    %ebx
f0106766:	5e                   	pop    %esi
f0106767:	5f                   	pop    %edi
f0106768:	5d                   	pop    %ebp
f0106769:	c3                   	ret    

f010676a <pci_conf_write>:
	return inl(pci_conf1_data_ioport);
}

static void
pci_conf_write(struct pci_func *f, uint32_t off, uint32_t v)
{
f010676a:	55                   	push   %ebp
f010676b:	89 e5                	mov    %esp,%ebp
f010676d:	56                   	push   %esi
f010676e:	53                   	push   %ebx
f010676f:	89 cb                	mov    %ecx,%ebx
	pci_conf1_set_addr(f->bus->busno, f->dev, f->func, off);
f0106771:	8b 48 08             	mov    0x8(%eax),%ecx
f0106774:	8b 70 04             	mov    0x4(%eax),%esi
f0106777:	8b 00                	mov    (%eax),%eax
f0106779:	8b 40 04             	mov    0x4(%eax),%eax
f010677c:	83 ec 0c             	sub    $0xc,%esp
f010677f:	52                   	push   %edx
f0106780:	89 f2                	mov    %esi,%edx
f0106782:	e8 aa fc ff ff       	call   f0106431 <pci_conf1_set_addr>
}

static inline void
outl(int port, uint32_t data)
{
	asm volatile("outl %0,%w1" : : "a" (data), "d" (port));
f0106787:	ba fc 0c 00 00       	mov    $0xcfc,%edx
f010678c:	89 d8                	mov    %ebx,%eax
f010678e:	ef                   	out    %eax,(%dx)
	outl(pci_conf1_data_ioport, v);
}
f010678f:	83 c4 10             	add    $0x10,%esp
f0106792:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106795:	5b                   	pop    %ebx
f0106796:	5e                   	pop    %esi
f0106797:	5d                   	pop    %ebp
f0106798:	c3                   	ret    

f0106799 <pci_func_enable>:

// External PCI subsystem interface

void
pci_func_enable(struct pci_func *f)
{
f0106799:	55                   	push   %ebp
f010679a:	89 e5                	mov    %esp,%ebp
f010679c:	57                   	push   %edi
f010679d:	56                   	push   %esi
f010679e:	53                   	push   %ebx
f010679f:	83 ec 1c             	sub    $0x1c,%esp
f01067a2:	8b 7d 08             	mov    0x8(%ebp),%edi
	pci_conf_write(f, PCI_COMMAND_STATUS_REG,
f01067a5:	b9 07 00 00 00       	mov    $0x7,%ecx
f01067aa:	ba 04 00 00 00       	mov    $0x4,%edx
f01067af:	89 f8                	mov    %edi,%eax
f01067b1:	e8 b4 ff ff ff       	call   f010676a <pci_conf_write>
		       PCI_COMMAND_MEM_ENABLE |
		       PCI_COMMAND_MASTER_ENABLE);

	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
f01067b6:	be 10 00 00 00       	mov    $0x10,%esi
	     bar += bar_width)
	{
		uint32_t oldv = pci_conf_read(f, bar);
f01067bb:	89 f2                	mov    %esi,%edx
f01067bd:	89 f8                	mov    %edi,%eax
f01067bf:	e8 23 fd ff ff       	call   f01064e7 <pci_conf_read>
f01067c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		bar_width = 4;
		pci_conf_write(f, bar, 0xffffffff);
f01067c7:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
f01067cc:	89 f2                	mov    %esi,%edx
f01067ce:	89 f8                	mov    %edi,%eax
f01067d0:	e8 95 ff ff ff       	call   f010676a <pci_conf_write>
		uint32_t rv = pci_conf_read(f, bar);
f01067d5:	89 f2                	mov    %esi,%edx
f01067d7:	89 f8                	mov    %edi,%eax
f01067d9:	e8 09 fd ff ff       	call   f01064e7 <pci_conf_read>
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
	     bar += bar_width)
	{
		uint32_t oldv = pci_conf_read(f, bar);

		bar_width = 4;
f01067de:	bb 04 00 00 00       	mov    $0x4,%ebx
		pci_conf_write(f, bar, 0xffffffff);
		uint32_t rv = pci_conf_read(f, bar);

		if (rv == 0)
f01067e3:	85 c0                	test   %eax,%eax
f01067e5:	0f 84 a6 00 00 00    	je     f0106891 <pci_func_enable+0xf8>
			continue;

		int regnum = PCI_MAPREG_NUM(bar);
f01067eb:	8d 56 f0             	lea    -0x10(%esi),%edx
f01067ee:	c1 ea 02             	shr    $0x2,%edx
f01067f1:	89 55 e0             	mov    %edx,-0x20(%ebp)
		uint32_t base, size;
		if (PCI_MAPREG_TYPE(rv) == PCI_MAPREG_TYPE_MEM) {
f01067f4:	a8 01                	test   $0x1,%al
f01067f6:	75 2c                	jne    f0106824 <pci_func_enable+0x8b>
			if (PCI_MAPREG_MEM_TYPE(rv) == PCI_MAPREG_MEM_TYPE_64BIT)
f01067f8:	89 c2                	mov    %eax,%edx
f01067fa:	83 e2 06             	and    $0x6,%edx
				bar_width = 8;
f01067fd:	83 fa 04             	cmp    $0x4,%edx
f0106800:	0f 94 c3             	sete   %bl
f0106803:	0f b6 db             	movzbl %bl,%ebx
f0106806:	8d 1c 9d 04 00 00 00 	lea    0x4(,%ebx,4),%ebx

			size = PCI_MAPREG_MEM_SIZE(rv);
f010680d:	83 e0 f0             	and    $0xfffffff0,%eax
f0106810:	89 c2                	mov    %eax,%edx
f0106812:	f7 da                	neg    %edx
f0106814:	21 c2                	and    %eax,%edx
f0106816:	89 55 d8             	mov    %edx,-0x28(%ebp)
			base = PCI_MAPREG_MEM_ADDR(oldv);
f0106819:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010681c:	83 e0 f0             	and    $0xfffffff0,%eax
f010681f:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0106822:	eb 1a                	jmp    f010683e <pci_func_enable+0xa5>
			if (pci_show_addrs)
				cprintf("  mem region %d: %d bytes at 0x%x\n",
					regnum, size, base);
		} else {
			size = PCI_MAPREG_IO_SIZE(rv);
f0106824:	83 e0 fc             	and    $0xfffffffc,%eax
f0106827:	89 c2                	mov    %eax,%edx
f0106829:	f7 da                	neg    %edx
f010682b:	21 c2                	and    %eax,%edx
f010682d:	89 55 d8             	mov    %edx,-0x28(%ebp)
			base = PCI_MAPREG_IO_ADDR(oldv);
f0106830:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106833:	83 e0 fc             	and    $0xfffffffc,%eax
f0106836:	89 45 dc             	mov    %eax,-0x24(%ebp)
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
	     bar += bar_width)
	{
		uint32_t oldv = pci_conf_read(f, bar);

		bar_width = 4;
f0106839:	bb 04 00 00 00       	mov    $0x4,%ebx
			if (pci_show_addrs)
				cprintf("  io region %d: %d bytes at 0x%x\n",
					regnum, size, base);
		}

		pci_conf_write(f, bar, oldv);
f010683e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0106841:	89 f2                	mov    %esi,%edx
f0106843:	89 f8                	mov    %edi,%eax
f0106845:	e8 20 ff ff ff       	call   f010676a <pci_conf_write>
f010684a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010684d:	8d 04 87             	lea    (%edi,%eax,4),%eax
		f->reg_base[regnum] = base;
f0106850:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0106853:	89 50 14             	mov    %edx,0x14(%eax)
		f->reg_size[regnum] = size;
f0106856:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0106859:	89 48 2c             	mov    %ecx,0x2c(%eax)

		if (size && !base)
f010685c:	85 c9                	test   %ecx,%ecx
f010685e:	74 31                	je     f0106891 <pci_func_enable+0xf8>
f0106860:	85 d2                	test   %edx,%edx
f0106862:	75 2d                	jne    f0106891 <pci_func_enable+0xf8>
			cprintf("PCI device %02x:%02x.%d (%04x:%04x) "
				"may be misconfigured: "
				"region %d: base 0x%x, size %d\n",
				f->bus->busno, f->dev, f->func,
				PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
f0106864:	8b 47 0c             	mov    0xc(%edi),%eax
		pci_conf_write(f, bar, oldv);
		f->reg_base[regnum] = base;
		f->reg_size[regnum] = size;

		if (size && !base)
			cprintf("PCI device %02x:%02x.%d (%04x:%04x) "
f0106867:	83 ec 0c             	sub    $0xc,%esp
f010686a:	51                   	push   %ecx
f010686b:	52                   	push   %edx
f010686c:	ff 75 e0             	pushl  -0x20(%ebp)
f010686f:	89 c2                	mov    %eax,%edx
f0106871:	c1 ea 10             	shr    $0x10,%edx
f0106874:	52                   	push   %edx
f0106875:	0f b7 c0             	movzwl %ax,%eax
f0106878:	50                   	push   %eax
f0106879:	ff 77 08             	pushl  0x8(%edi)
f010687c:	ff 77 04             	pushl  0x4(%edi)
f010687f:	8b 07                	mov    (%edi),%eax
f0106881:	ff 70 04             	pushl  0x4(%eax)
f0106884:	68 a8 8b 10 f0       	push   $0xf0108ba8
f0106889:	e8 f4 d0 ff ff       	call   f0103982 <cprintf>
f010688e:	83 c4 30             	add    $0x30,%esp
		       PCI_COMMAND_MASTER_ENABLE);

	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
	     bar += bar_width)
f0106891:	01 de                	add    %ebx,%esi
		       PCI_COMMAND_MEM_ENABLE |
		       PCI_COMMAND_MASTER_ENABLE);

	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
f0106893:	83 fe 27             	cmp    $0x27,%esi
f0106896:	0f 86 1f ff ff ff    	jbe    f01067bb <pci_func_enable+0x22>
				regnum, base, size);
	}

	cprintf("PCI function %02x:%02x.%d (%04x:%04x) enabled\n",
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id));
f010689c:	8b 47 0c             	mov    0xc(%edi),%eax
				f->bus->busno, f->dev, f->func,
				PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
				regnum, base, size);
	}

	cprintf("PCI function %02x:%02x.%d (%04x:%04x) enabled\n",
f010689f:	83 ec 08             	sub    $0x8,%esp
f01068a2:	89 c2                	mov    %eax,%edx
f01068a4:	c1 ea 10             	shr    $0x10,%edx
f01068a7:	52                   	push   %edx
f01068a8:	0f b7 c0             	movzwl %ax,%eax
f01068ab:	50                   	push   %eax
f01068ac:	ff 77 08             	pushl  0x8(%edi)
f01068af:	ff 77 04             	pushl  0x4(%edi)
f01068b2:	8b 07                	mov    (%edi),%eax
f01068b4:	ff 70 04             	pushl  0x4(%eax)
f01068b7:	68 04 8c 10 f0       	push   $0xf0108c04
f01068bc:	e8 c1 d0 ff ff       	call   f0103982 <cprintf>
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id));
}
f01068c1:	83 c4 20             	add    $0x20,%esp
f01068c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01068c7:	5b                   	pop    %ebx
f01068c8:	5e                   	pop    %esi
f01068c9:	5f                   	pop    %edi
f01068ca:	5d                   	pop    %ebp
f01068cb:	c3                   	ret    

f01068cc <pci_init>:

int
pci_init(void)
{
f01068cc:	55                   	push   %ebp
f01068cd:	89 e5                	mov    %esp,%ebp
f01068cf:	83 ec 0c             	sub    $0xc,%esp
	static struct pci_bus root_bus;
	memset(&root_bus, 0, sizeof(root_bus));
f01068d2:	6a 08                	push   $0x8
f01068d4:	6a 00                	push   $0x0
f01068d6:	68 80 ae 2a f0       	push   $0xf02aae80
f01068db:	e8 d6 ee ff ff       	call   f01057b6 <memset>

	return pci_scan_bus(&root_bus);
f01068e0:	b8 80 ae 2a f0       	mov    $0xf02aae80,%eax
f01068e5:	e8 22 fc ff ff       	call   f010650c <pci_scan_bus>
}
f01068ea:	c9                   	leave  
f01068eb:	c3                   	ret    

f01068ec <time_init>:

static unsigned int ticks;

void
time_init(void)
{
f01068ec:	55                   	push   %ebp
f01068ed:	89 e5                	mov    %esp,%ebp
	ticks = 0;
f01068ef:	c7 05 88 ae 2a f0 00 	movl   $0x0,0xf02aae88
f01068f6:	00 00 00 
}
f01068f9:	5d                   	pop    %ebp
f01068fa:	c3                   	ret    

f01068fb <time_tick>:
// This should be called once per timer interrupt.  A timer interrupt
// fires every 10 ms.
void
time_tick(void)
{
	ticks++;
f01068fb:	a1 88 ae 2a f0       	mov    0xf02aae88,%eax
f0106900:	83 c0 01             	add    $0x1,%eax
f0106903:	a3 88 ae 2a f0       	mov    %eax,0xf02aae88
	if (ticks * 10 < ticks)
f0106908:	8d 14 80             	lea    (%eax,%eax,4),%edx
f010690b:	01 d2                	add    %edx,%edx
f010690d:	39 d0                	cmp    %edx,%eax
f010690f:	76 17                	jbe    f0106928 <time_tick+0x2d>

// This should be called once per timer interrupt.  A timer interrupt
// fires every 10 ms.
void
time_tick(void)
{
f0106911:	55                   	push   %ebp
f0106912:	89 e5                	mov    %esp,%ebp
f0106914:	83 ec 0c             	sub    $0xc,%esp
	ticks++;
	if (ticks * 10 < ticks)
		panic("time_tick: time overflowed");
f0106917:	68 0c 8d 10 f0       	push   $0xf0108d0c
f010691c:	6a 13                	push   $0x13
f010691e:	68 27 8d 10 f0       	push   $0xf0108d27
f0106923:	e8 18 97 ff ff       	call   f0100040 <_panic>
f0106928:	f3 c3                	repz ret 

f010692a <time_msec>:
}

unsigned int
time_msec(void)
{
f010692a:	55                   	push   %ebp
f010692b:	89 e5                	mov    %esp,%ebp
	return ticks * 10;
f010692d:	a1 88 ae 2a f0       	mov    0xf02aae88,%eax
f0106932:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0106935:	01 c0                	add    %eax,%eax
}
f0106937:	5d                   	pop    %ebp
f0106938:	c3                   	ret    
f0106939:	66 90                	xchg   %ax,%ax
f010693b:	66 90                	xchg   %ax,%ax
f010693d:	66 90                	xchg   %ax,%ax
f010693f:	90                   	nop

f0106940 <__udivdi3>:
f0106940:	55                   	push   %ebp
f0106941:	57                   	push   %edi
f0106942:	56                   	push   %esi
f0106943:	53                   	push   %ebx
f0106944:	83 ec 1c             	sub    $0x1c,%esp
f0106947:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010694b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010694f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0106953:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106957:	85 f6                	test   %esi,%esi
f0106959:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010695d:	89 ca                	mov    %ecx,%edx
f010695f:	89 f8                	mov    %edi,%eax
f0106961:	75 3d                	jne    f01069a0 <__udivdi3+0x60>
f0106963:	39 cf                	cmp    %ecx,%edi
f0106965:	0f 87 c5 00 00 00    	ja     f0106a30 <__udivdi3+0xf0>
f010696b:	85 ff                	test   %edi,%edi
f010696d:	89 fd                	mov    %edi,%ebp
f010696f:	75 0b                	jne    f010697c <__udivdi3+0x3c>
f0106971:	b8 01 00 00 00       	mov    $0x1,%eax
f0106976:	31 d2                	xor    %edx,%edx
f0106978:	f7 f7                	div    %edi
f010697a:	89 c5                	mov    %eax,%ebp
f010697c:	89 c8                	mov    %ecx,%eax
f010697e:	31 d2                	xor    %edx,%edx
f0106980:	f7 f5                	div    %ebp
f0106982:	89 c1                	mov    %eax,%ecx
f0106984:	89 d8                	mov    %ebx,%eax
f0106986:	89 cf                	mov    %ecx,%edi
f0106988:	f7 f5                	div    %ebp
f010698a:	89 c3                	mov    %eax,%ebx
f010698c:	89 d8                	mov    %ebx,%eax
f010698e:	89 fa                	mov    %edi,%edx
f0106990:	83 c4 1c             	add    $0x1c,%esp
f0106993:	5b                   	pop    %ebx
f0106994:	5e                   	pop    %esi
f0106995:	5f                   	pop    %edi
f0106996:	5d                   	pop    %ebp
f0106997:	c3                   	ret    
f0106998:	90                   	nop
f0106999:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01069a0:	39 ce                	cmp    %ecx,%esi
f01069a2:	77 74                	ja     f0106a18 <__udivdi3+0xd8>
f01069a4:	0f bd fe             	bsr    %esi,%edi
f01069a7:	83 f7 1f             	xor    $0x1f,%edi
f01069aa:	0f 84 98 00 00 00    	je     f0106a48 <__udivdi3+0x108>
f01069b0:	bb 20 00 00 00       	mov    $0x20,%ebx
f01069b5:	89 f9                	mov    %edi,%ecx
f01069b7:	89 c5                	mov    %eax,%ebp
f01069b9:	29 fb                	sub    %edi,%ebx
f01069bb:	d3 e6                	shl    %cl,%esi
f01069bd:	89 d9                	mov    %ebx,%ecx
f01069bf:	d3 ed                	shr    %cl,%ebp
f01069c1:	89 f9                	mov    %edi,%ecx
f01069c3:	d3 e0                	shl    %cl,%eax
f01069c5:	09 ee                	or     %ebp,%esi
f01069c7:	89 d9                	mov    %ebx,%ecx
f01069c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01069cd:	89 d5                	mov    %edx,%ebp
f01069cf:	8b 44 24 08          	mov    0x8(%esp),%eax
f01069d3:	d3 ed                	shr    %cl,%ebp
f01069d5:	89 f9                	mov    %edi,%ecx
f01069d7:	d3 e2                	shl    %cl,%edx
f01069d9:	89 d9                	mov    %ebx,%ecx
f01069db:	d3 e8                	shr    %cl,%eax
f01069dd:	09 c2                	or     %eax,%edx
f01069df:	89 d0                	mov    %edx,%eax
f01069e1:	89 ea                	mov    %ebp,%edx
f01069e3:	f7 f6                	div    %esi
f01069e5:	89 d5                	mov    %edx,%ebp
f01069e7:	89 c3                	mov    %eax,%ebx
f01069e9:	f7 64 24 0c          	mull   0xc(%esp)
f01069ed:	39 d5                	cmp    %edx,%ebp
f01069ef:	72 10                	jb     f0106a01 <__udivdi3+0xc1>
f01069f1:	8b 74 24 08          	mov    0x8(%esp),%esi
f01069f5:	89 f9                	mov    %edi,%ecx
f01069f7:	d3 e6                	shl    %cl,%esi
f01069f9:	39 c6                	cmp    %eax,%esi
f01069fb:	73 07                	jae    f0106a04 <__udivdi3+0xc4>
f01069fd:	39 d5                	cmp    %edx,%ebp
f01069ff:	75 03                	jne    f0106a04 <__udivdi3+0xc4>
f0106a01:	83 eb 01             	sub    $0x1,%ebx
f0106a04:	31 ff                	xor    %edi,%edi
f0106a06:	89 d8                	mov    %ebx,%eax
f0106a08:	89 fa                	mov    %edi,%edx
f0106a0a:	83 c4 1c             	add    $0x1c,%esp
f0106a0d:	5b                   	pop    %ebx
f0106a0e:	5e                   	pop    %esi
f0106a0f:	5f                   	pop    %edi
f0106a10:	5d                   	pop    %ebp
f0106a11:	c3                   	ret    
f0106a12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106a18:	31 ff                	xor    %edi,%edi
f0106a1a:	31 db                	xor    %ebx,%ebx
f0106a1c:	89 d8                	mov    %ebx,%eax
f0106a1e:	89 fa                	mov    %edi,%edx
f0106a20:	83 c4 1c             	add    $0x1c,%esp
f0106a23:	5b                   	pop    %ebx
f0106a24:	5e                   	pop    %esi
f0106a25:	5f                   	pop    %edi
f0106a26:	5d                   	pop    %ebp
f0106a27:	c3                   	ret    
f0106a28:	90                   	nop
f0106a29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106a30:	89 d8                	mov    %ebx,%eax
f0106a32:	f7 f7                	div    %edi
f0106a34:	31 ff                	xor    %edi,%edi
f0106a36:	89 c3                	mov    %eax,%ebx
f0106a38:	89 d8                	mov    %ebx,%eax
f0106a3a:	89 fa                	mov    %edi,%edx
f0106a3c:	83 c4 1c             	add    $0x1c,%esp
f0106a3f:	5b                   	pop    %ebx
f0106a40:	5e                   	pop    %esi
f0106a41:	5f                   	pop    %edi
f0106a42:	5d                   	pop    %ebp
f0106a43:	c3                   	ret    
f0106a44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106a48:	39 ce                	cmp    %ecx,%esi
f0106a4a:	72 0c                	jb     f0106a58 <__udivdi3+0x118>
f0106a4c:	31 db                	xor    %ebx,%ebx
f0106a4e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0106a52:	0f 87 34 ff ff ff    	ja     f010698c <__udivdi3+0x4c>
f0106a58:	bb 01 00 00 00       	mov    $0x1,%ebx
f0106a5d:	e9 2a ff ff ff       	jmp    f010698c <__udivdi3+0x4c>
f0106a62:	66 90                	xchg   %ax,%ax
f0106a64:	66 90                	xchg   %ax,%ax
f0106a66:	66 90                	xchg   %ax,%ax
f0106a68:	66 90                	xchg   %ax,%ax
f0106a6a:	66 90                	xchg   %ax,%ax
f0106a6c:	66 90                	xchg   %ax,%ax
f0106a6e:	66 90                	xchg   %ax,%ax

f0106a70 <__umoddi3>:
f0106a70:	55                   	push   %ebp
f0106a71:	57                   	push   %edi
f0106a72:	56                   	push   %esi
f0106a73:	53                   	push   %ebx
f0106a74:	83 ec 1c             	sub    $0x1c,%esp
f0106a77:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0106a7b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f0106a7f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0106a83:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106a87:	85 d2                	test   %edx,%edx
f0106a89:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0106a8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106a91:	89 f3                	mov    %esi,%ebx
f0106a93:	89 3c 24             	mov    %edi,(%esp)
f0106a96:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106a9a:	75 1c                	jne    f0106ab8 <__umoddi3+0x48>
f0106a9c:	39 f7                	cmp    %esi,%edi
f0106a9e:	76 50                	jbe    f0106af0 <__umoddi3+0x80>
f0106aa0:	89 c8                	mov    %ecx,%eax
f0106aa2:	89 f2                	mov    %esi,%edx
f0106aa4:	f7 f7                	div    %edi
f0106aa6:	89 d0                	mov    %edx,%eax
f0106aa8:	31 d2                	xor    %edx,%edx
f0106aaa:	83 c4 1c             	add    $0x1c,%esp
f0106aad:	5b                   	pop    %ebx
f0106aae:	5e                   	pop    %esi
f0106aaf:	5f                   	pop    %edi
f0106ab0:	5d                   	pop    %ebp
f0106ab1:	c3                   	ret    
f0106ab2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106ab8:	39 f2                	cmp    %esi,%edx
f0106aba:	89 d0                	mov    %edx,%eax
f0106abc:	77 52                	ja     f0106b10 <__umoddi3+0xa0>
f0106abe:	0f bd ea             	bsr    %edx,%ebp
f0106ac1:	83 f5 1f             	xor    $0x1f,%ebp
f0106ac4:	75 5a                	jne    f0106b20 <__umoddi3+0xb0>
f0106ac6:	3b 54 24 04          	cmp    0x4(%esp),%edx
f0106aca:	0f 82 e0 00 00 00    	jb     f0106bb0 <__umoddi3+0x140>
f0106ad0:	39 0c 24             	cmp    %ecx,(%esp)
f0106ad3:	0f 86 d7 00 00 00    	jbe    f0106bb0 <__umoddi3+0x140>
f0106ad9:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106add:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106ae1:	83 c4 1c             	add    $0x1c,%esp
f0106ae4:	5b                   	pop    %ebx
f0106ae5:	5e                   	pop    %esi
f0106ae6:	5f                   	pop    %edi
f0106ae7:	5d                   	pop    %ebp
f0106ae8:	c3                   	ret    
f0106ae9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106af0:	85 ff                	test   %edi,%edi
f0106af2:	89 fd                	mov    %edi,%ebp
f0106af4:	75 0b                	jne    f0106b01 <__umoddi3+0x91>
f0106af6:	b8 01 00 00 00       	mov    $0x1,%eax
f0106afb:	31 d2                	xor    %edx,%edx
f0106afd:	f7 f7                	div    %edi
f0106aff:	89 c5                	mov    %eax,%ebp
f0106b01:	89 f0                	mov    %esi,%eax
f0106b03:	31 d2                	xor    %edx,%edx
f0106b05:	f7 f5                	div    %ebp
f0106b07:	89 c8                	mov    %ecx,%eax
f0106b09:	f7 f5                	div    %ebp
f0106b0b:	89 d0                	mov    %edx,%eax
f0106b0d:	eb 99                	jmp    f0106aa8 <__umoddi3+0x38>
f0106b0f:	90                   	nop
f0106b10:	89 c8                	mov    %ecx,%eax
f0106b12:	89 f2                	mov    %esi,%edx
f0106b14:	83 c4 1c             	add    $0x1c,%esp
f0106b17:	5b                   	pop    %ebx
f0106b18:	5e                   	pop    %esi
f0106b19:	5f                   	pop    %edi
f0106b1a:	5d                   	pop    %ebp
f0106b1b:	c3                   	ret    
f0106b1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106b20:	8b 34 24             	mov    (%esp),%esi
f0106b23:	bf 20 00 00 00       	mov    $0x20,%edi
f0106b28:	89 e9                	mov    %ebp,%ecx
f0106b2a:	29 ef                	sub    %ebp,%edi
f0106b2c:	d3 e0                	shl    %cl,%eax
f0106b2e:	89 f9                	mov    %edi,%ecx
f0106b30:	89 f2                	mov    %esi,%edx
f0106b32:	d3 ea                	shr    %cl,%edx
f0106b34:	89 e9                	mov    %ebp,%ecx
f0106b36:	09 c2                	or     %eax,%edx
f0106b38:	89 d8                	mov    %ebx,%eax
f0106b3a:	89 14 24             	mov    %edx,(%esp)
f0106b3d:	89 f2                	mov    %esi,%edx
f0106b3f:	d3 e2                	shl    %cl,%edx
f0106b41:	89 f9                	mov    %edi,%ecx
f0106b43:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106b47:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0106b4b:	d3 e8                	shr    %cl,%eax
f0106b4d:	89 e9                	mov    %ebp,%ecx
f0106b4f:	89 c6                	mov    %eax,%esi
f0106b51:	d3 e3                	shl    %cl,%ebx
f0106b53:	89 f9                	mov    %edi,%ecx
f0106b55:	89 d0                	mov    %edx,%eax
f0106b57:	d3 e8                	shr    %cl,%eax
f0106b59:	89 e9                	mov    %ebp,%ecx
f0106b5b:	09 d8                	or     %ebx,%eax
f0106b5d:	89 d3                	mov    %edx,%ebx
f0106b5f:	89 f2                	mov    %esi,%edx
f0106b61:	f7 34 24             	divl   (%esp)
f0106b64:	89 d6                	mov    %edx,%esi
f0106b66:	d3 e3                	shl    %cl,%ebx
f0106b68:	f7 64 24 04          	mull   0x4(%esp)
f0106b6c:	39 d6                	cmp    %edx,%esi
f0106b6e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106b72:	89 d1                	mov    %edx,%ecx
f0106b74:	89 c3                	mov    %eax,%ebx
f0106b76:	72 08                	jb     f0106b80 <__umoddi3+0x110>
f0106b78:	75 11                	jne    f0106b8b <__umoddi3+0x11b>
f0106b7a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0106b7e:	73 0b                	jae    f0106b8b <__umoddi3+0x11b>
f0106b80:	2b 44 24 04          	sub    0x4(%esp),%eax
f0106b84:	1b 14 24             	sbb    (%esp),%edx
f0106b87:	89 d1                	mov    %edx,%ecx
f0106b89:	89 c3                	mov    %eax,%ebx
f0106b8b:	8b 54 24 08          	mov    0x8(%esp),%edx
f0106b8f:	29 da                	sub    %ebx,%edx
f0106b91:	19 ce                	sbb    %ecx,%esi
f0106b93:	89 f9                	mov    %edi,%ecx
f0106b95:	89 f0                	mov    %esi,%eax
f0106b97:	d3 e0                	shl    %cl,%eax
f0106b99:	89 e9                	mov    %ebp,%ecx
f0106b9b:	d3 ea                	shr    %cl,%edx
f0106b9d:	89 e9                	mov    %ebp,%ecx
f0106b9f:	d3 ee                	shr    %cl,%esi
f0106ba1:	09 d0                	or     %edx,%eax
f0106ba3:	89 f2                	mov    %esi,%edx
f0106ba5:	83 c4 1c             	add    $0x1c,%esp
f0106ba8:	5b                   	pop    %ebx
f0106ba9:	5e                   	pop    %esi
f0106baa:	5f                   	pop    %edi
f0106bab:	5d                   	pop    %ebp
f0106bac:	c3                   	ret    
f0106bad:	8d 76 00             	lea    0x0(%esi),%esi
f0106bb0:	29 f9                	sub    %edi,%ecx
f0106bb2:	19 d6                	sbb    %edx,%esi
f0106bb4:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106bb8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106bbc:	e9 18 ff ff ff       	jmp    f0106ad9 <__umoddi3+0x69>
