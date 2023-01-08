
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
f0100015:	b8 00 00 12 00       	mov    $0x120000,%eax
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
f0100034:	bc 00 00 12 f0       	mov    $0xf0120000,%esp

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
f0100048:	83 3d 98 9e 2a f0 00 	cmpl   $0x0,0xf02a9e98
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 98 9e 2a f0    	mov    %esi,0xf02a9e98

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 2d 5d 00 00       	call   f0105d8e <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 80 69 10 f0       	push   $0xf0106980
f010006d:	e8 1f 39 00 00       	call   f0103991 <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 ef 38 00 00       	call   f010396b <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 99 72 10 f0 	movl   $0xf0107299,(%esp)
f0100083:	e8 09 39 00 00       	call   f0103991 <cprintf>
	va_end(ap);
f0100088:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010008b:	83 ec 0c             	sub    $0xc,%esp
f010008e:	6a 00                	push   $0x0
f0100090:	e8 2b 09 00 00       	call   f01009c0 <monitor>
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
f01000a1:	e8 af 05 00 00       	call   f0100655 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000a6:	83 ec 08             	sub    $0x8,%esp
f01000a9:	68 ac 1a 00 00       	push   $0x1aac
f01000ae:	68 ec 69 10 f0       	push   $0xf01069ec
f01000b3:	e8 d9 38 00 00       	call   f0103991 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000b8:	e8 c6 14 00 00       	call   f0101583 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000bd:	e8 30 31 00 00       	call   f01031f2 <env_init>
	trap_init();
f01000c2:	e8 bd 39 00 00       	call   f0103a84 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000c7:	e8 b8 59 00 00       	call   f0105a84 <mp_init>
	lapic_init();
f01000cc:	e8 d8 5c 00 00       	call   f0105da9 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000d1:	e8 cc 37 00 00       	call   f01038a2 <pic_init>

	// Lab 6 hardware initialization functions
	time_init();
f01000d6:	e8 c3 65 00 00       	call   f010669e <time_init>
	pci_init();
f01000db:	e8 9e 65 00 00       	call   f010667e <pci_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000e0:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f01000e7:	e8 10 5f 00 00       	call   f0105ffc <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000ec:	83 c4 10             	add    $0x10,%esp
f01000ef:	83 3d a0 9e 2a f0 07 	cmpl   $0x7,0xf02a9ea0
f01000f6:	77 16                	ja     f010010e <i386_init+0x74>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01000f8:	68 00 70 00 00       	push   $0x7000
f01000fd:	68 a4 69 10 f0       	push   $0xf01069a4
f0100102:	6a 60                	push   $0x60
f0100104:	68 07 6a 10 f0       	push   $0xf0106a07
f0100109:	e8 32 ff ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f010010e:	83 ec 04             	sub    $0x4,%esp
f0100111:	b8 ea 59 10 f0       	mov    $0xf01059ea,%eax
f0100116:	2d 70 59 10 f0       	sub    $0xf0105970,%eax
f010011b:	50                   	push   %eax
f010011c:	68 70 59 10 f0       	push   $0xf0105970
f0100121:	68 00 70 00 f0       	push   $0xf0007000
f0100126:	e8 8d 56 00 00       	call   f01057b8 <memmove>
f010012b:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010012e:	bb 20 a0 2a f0       	mov    $0xf02aa020,%ebx
f0100133:	eb 4d                	jmp    f0100182 <i386_init+0xe8>
		if (c == cpus + cpunum())  // We've started already.
f0100135:	e8 54 5c 00 00       	call   f0105d8e <cpunum>
f010013a:	6b c0 74             	imul   $0x74,%eax,%eax
f010013d:	05 20 a0 2a f0       	add    $0xf02aa020,%eax
f0100142:	39 c3                	cmp    %eax,%ebx
f0100144:	74 39                	je     f010017f <i386_init+0xe5>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100146:	89 d8                	mov    %ebx,%eax
f0100148:	2d 20 a0 2a f0       	sub    $0xf02aa020,%eax
f010014d:	c1 f8 02             	sar    $0x2,%eax
f0100150:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100156:	c1 e0 0f             	shl    $0xf,%eax
f0100159:	05 00 30 2b f0       	add    $0xf02b3000,%eax
f010015e:	a3 9c 9e 2a f0       	mov    %eax,0xf02a9e9c
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100163:	83 ec 08             	sub    $0x8,%esp
f0100166:	68 00 70 00 00       	push   $0x7000
f010016b:	0f b6 03             	movzbl (%ebx),%eax
f010016e:	50                   	push   %eax
f010016f:	e8 83 5d 00 00       	call   f0105ef7 <lapic_startap>
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
f0100182:	6b 05 c4 a3 2a f0 74 	imul   $0x74,0xf02aa3c4,%eax
f0100189:	05 20 a0 2a f0       	add    $0xf02aa020,%eax
f010018e:	39 c3                	cmp    %eax,%ebx
f0100190:	72 a3                	jb     f0100135 <i386_init+0x9b>

	// Starting non-boot CPUs
	boot_aps();

	// Start fs.
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f0100192:	83 ec 08             	sub    $0x8,%esp
f0100195:	6a 01                	push   $0x1
f0100197:	68 f0 a0 1d f0       	push   $0xf01da0f0
f010019c:	e8 e4 31 00 00       	call   f0103385 <env_create>

#if !defined(TEST_NO_NS)
	// Start ns.
	ENV_CREATE(net_ns, ENV_TYPE_NS);
f01001a1:	83 c4 08             	add    $0x8,%esp
f01001a4:	6a 02                	push   $0x2
f01001a6:	68 b4 16 23 f0       	push   $0xf02316b4
f01001ab:	e8 d5 31 00 00       	call   f0103385 <env_create>
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	// ENV_CREATE(user_dumbfork, ENV_TYPE_USER);
	ENV_CREATE(user_icode, ENV_TYPE_USER);
f01001b0:	83 c4 08             	add    $0x8,%esp
f01001b3:	6a 00                	push   $0x0
f01001b5:	68 b8 4f 1d f0       	push   $0xf01d4fb8
f01001ba:	e8 c6 31 00 00       	call   f0103385 <env_create>
	// ENV_CREATE(user_primes, ENV_TYPE_USER);
#endif // TEST*

	// Should not be necessary - drains keyboard because interrupt has given up.
	kbd_intr();
f01001bf:	e8 35 04 00 00       	call   f01005f9 <kbd_intr>

	// Schedule and run the first user environment!
	sched_yield();
f01001c4:	e8 0f 44 00 00       	call   f01045d8 <sched_yield>

f01001c9 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01001c9:	55                   	push   %ebp
f01001ca:	89 e5                	mov    %esp,%ebp
f01001cc:	83 ec 08             	sub    $0x8,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01001cf:	a1 a4 9e 2a f0       	mov    0xf02a9ea4,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001d4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001d9:	77 12                	ja     f01001ed <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001db:	50                   	push   %eax
f01001dc:	68 c8 69 10 f0       	push   $0xf01069c8
f01001e1:	6a 77                	push   $0x77
f01001e3:	68 07 6a 10 f0       	push   $0xf0106a07
f01001e8:	e8 53 fe ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01001ed:	05 00 00 00 10       	add    $0x10000000,%eax
f01001f2:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001f5:	e8 94 5b 00 00       	call   f0105d8e <cpunum>
f01001fa:	83 ec 08             	sub    $0x8,%esp
f01001fd:	50                   	push   %eax
f01001fe:	68 13 6a 10 f0       	push   $0xf0106a13
f0100203:	e8 89 37 00 00       	call   f0103991 <cprintf>

	lapic_init();
f0100208:	e8 9c 5b 00 00       	call   f0105da9 <lapic_init>
	env_init_percpu();
f010020d:	e8 b0 2f 00 00       	call   f01031c2 <env_init_percpu>
	trap_init_percpu();
f0100212:	e8 8e 37 00 00       	call   f01039a5 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100217:	e8 72 5b 00 00       	call   f0105d8e <cpunum>
f010021c:	6b d0 74             	imul   $0x74,%eax,%edx
f010021f:	81 c2 20 a0 2a f0    	add    $0xf02aa020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0100225:	b8 01 00 00 00       	mov    $0x1,%eax
f010022a:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010022e:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f0100235:	e8 c2 5d 00 00       	call   f0105ffc <spin_lock>
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:

	lock_kernel();
	sched_yield();
f010023a:	e8 99 43 00 00       	call   f01045d8 <sched_yield>

f010023f <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010023f:	55                   	push   %ebp
f0100240:	89 e5                	mov    %esp,%ebp
f0100242:	53                   	push   %ebx
f0100243:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100246:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100249:	ff 75 0c             	pushl  0xc(%ebp)
f010024c:	ff 75 08             	pushl  0x8(%ebp)
f010024f:	68 29 6a 10 f0       	push   $0xf0106a29
f0100254:	e8 38 37 00 00       	call   f0103991 <cprintf>
	vcprintf(fmt, ap);
f0100259:	83 c4 08             	add    $0x8,%esp
f010025c:	53                   	push   %ebx
f010025d:	ff 75 10             	pushl  0x10(%ebp)
f0100260:	e8 06 37 00 00       	call   f010396b <vcprintf>
	cprintf("\n");
f0100265:	c7 04 24 99 72 10 f0 	movl   $0xf0107299,(%esp)
f010026c:	e8 20 37 00 00       	call   f0103991 <cprintf>
	va_end(ap);
}
f0100271:	83 c4 10             	add    $0x10,%esp
f0100274:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100277:	c9                   	leave  
f0100278:	c3                   	ret    

f0100279 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100279:	55                   	push   %ebp
f010027a:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010027c:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100281:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100282:	a8 01                	test   $0x1,%al
f0100284:	74 0b                	je     f0100291 <serial_proc_data+0x18>
f0100286:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010028b:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010028c:	0f b6 c0             	movzbl %al,%eax
f010028f:	eb 05                	jmp    f0100296 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100291:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100296:	5d                   	pop    %ebp
f0100297:	c3                   	ret    

f0100298 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100298:	55                   	push   %ebp
f0100299:	89 e5                	mov    %esp,%ebp
f010029b:	53                   	push   %ebx
f010029c:	83 ec 04             	sub    $0x4,%esp
f010029f:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01002a1:	eb 2b                	jmp    f01002ce <cons_intr+0x36>
		if (c == 0)
f01002a3:	85 c0                	test   %eax,%eax
f01002a5:	74 27                	je     f01002ce <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f01002a7:	8b 0d 24 92 2a f0    	mov    0xf02a9224,%ecx
f01002ad:	8d 51 01             	lea    0x1(%ecx),%edx
f01002b0:	89 15 24 92 2a f0    	mov    %edx,0xf02a9224
f01002b6:	88 81 20 90 2a f0    	mov    %al,-0xfd56fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002bc:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01002c2:	75 0a                	jne    f01002ce <cons_intr+0x36>
			cons.wpos = 0;
f01002c4:	c7 05 24 92 2a f0 00 	movl   $0x0,0xf02a9224
f01002cb:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002ce:	ff d3                	call   *%ebx
f01002d0:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002d3:	75 ce                	jne    f01002a3 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01002d5:	83 c4 04             	add    $0x4,%esp
f01002d8:	5b                   	pop    %ebx
f01002d9:	5d                   	pop    %ebp
f01002da:	c3                   	ret    

f01002db <kbd_proc_data>:
f01002db:	ba 64 00 00 00       	mov    $0x64,%edx
f01002e0:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f01002e1:	a8 01                	test   $0x1,%al
f01002e3:	0f 84 f8 00 00 00    	je     f01003e1 <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f01002e9:	a8 20                	test   $0x20,%al
f01002eb:	0f 85 f6 00 00 00    	jne    f01003e7 <kbd_proc_data+0x10c>
f01002f1:	ba 60 00 00 00       	mov    $0x60,%edx
f01002f6:	ec                   	in     (%dx),%al
f01002f7:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01002f9:	3c e0                	cmp    $0xe0,%al
f01002fb:	75 0d                	jne    f010030a <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f01002fd:	83 0d 00 90 2a f0 40 	orl    $0x40,0xf02a9000
		return 0;
f0100304:	b8 00 00 00 00       	mov    $0x0,%eax
f0100309:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f010030a:	55                   	push   %ebp
f010030b:	89 e5                	mov    %esp,%ebp
f010030d:	53                   	push   %ebx
f010030e:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f0100311:	84 c0                	test   %al,%al
f0100313:	79 36                	jns    f010034b <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100315:	8b 0d 00 90 2a f0    	mov    0xf02a9000,%ecx
f010031b:	89 cb                	mov    %ecx,%ebx
f010031d:	83 e3 40             	and    $0x40,%ebx
f0100320:	83 e0 7f             	and    $0x7f,%eax
f0100323:	85 db                	test   %ebx,%ebx
f0100325:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100328:	0f b6 d2             	movzbl %dl,%edx
f010032b:	0f b6 82 a0 6b 10 f0 	movzbl -0xfef9460(%edx),%eax
f0100332:	83 c8 40             	or     $0x40,%eax
f0100335:	0f b6 c0             	movzbl %al,%eax
f0100338:	f7 d0                	not    %eax
f010033a:	21 c8                	and    %ecx,%eax
f010033c:	a3 00 90 2a f0       	mov    %eax,0xf02a9000
		return 0;
f0100341:	b8 00 00 00 00       	mov    $0x0,%eax
f0100346:	e9 a4 00 00 00       	jmp    f01003ef <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f010034b:	8b 0d 00 90 2a f0    	mov    0xf02a9000,%ecx
f0100351:	f6 c1 40             	test   $0x40,%cl
f0100354:	74 0e                	je     f0100364 <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100356:	83 c8 80             	or     $0xffffff80,%eax
f0100359:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010035b:	83 e1 bf             	and    $0xffffffbf,%ecx
f010035e:	89 0d 00 90 2a f0    	mov    %ecx,0xf02a9000
	}

	shift |= shiftcode[data];
f0100364:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100367:	0f b6 82 a0 6b 10 f0 	movzbl -0xfef9460(%edx),%eax
f010036e:	0b 05 00 90 2a f0    	or     0xf02a9000,%eax
f0100374:	0f b6 8a a0 6a 10 f0 	movzbl -0xfef9560(%edx),%ecx
f010037b:	31 c8                	xor    %ecx,%eax
f010037d:	a3 00 90 2a f0       	mov    %eax,0xf02a9000

	c = charcode[shift & (CTL | SHIFT)][data];
f0100382:	89 c1                	mov    %eax,%ecx
f0100384:	83 e1 03             	and    $0x3,%ecx
f0100387:	8b 0c 8d 80 6a 10 f0 	mov    -0xfef9580(,%ecx,4),%ecx
f010038e:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100392:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100395:	a8 08                	test   $0x8,%al
f0100397:	74 1b                	je     f01003b4 <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f0100399:	89 da                	mov    %ebx,%edx
f010039b:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f010039e:	83 f9 19             	cmp    $0x19,%ecx
f01003a1:	77 05                	ja     f01003a8 <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f01003a3:	83 eb 20             	sub    $0x20,%ebx
f01003a6:	eb 0c                	jmp    f01003b4 <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f01003a8:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01003ab:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01003ae:	83 fa 19             	cmp    $0x19,%edx
f01003b1:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003b4:	f7 d0                	not    %eax
f01003b6:	a8 06                	test   $0x6,%al
f01003b8:	75 33                	jne    f01003ed <kbd_proc_data+0x112>
f01003ba:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003c0:	75 2b                	jne    f01003ed <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f01003c2:	83 ec 0c             	sub    $0xc,%esp
f01003c5:	68 43 6a 10 f0       	push   $0xf0106a43
f01003ca:	e8 c2 35 00 00       	call   f0103991 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003cf:	ba 92 00 00 00       	mov    $0x92,%edx
f01003d4:	b8 03 00 00 00       	mov    $0x3,%eax
f01003d9:	ee                   	out    %al,(%dx)
f01003da:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003dd:	89 d8                	mov    %ebx,%eax
f01003df:	eb 0e                	jmp    f01003ef <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f01003e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01003e6:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f01003e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01003ec:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003ed:	89 d8                	mov    %ebx,%eax
}
f01003ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01003f2:	c9                   	leave  
f01003f3:	c3                   	ret    

f01003f4 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003f4:	55                   	push   %ebp
f01003f5:	89 e5                	mov    %esp,%ebp
f01003f7:	57                   	push   %edi
f01003f8:	56                   	push   %esi
f01003f9:	53                   	push   %ebx
f01003fa:	83 ec 1c             	sub    $0x1c,%esp
f01003fd:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01003ff:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100404:	be fd 03 00 00       	mov    $0x3fd,%esi
f0100409:	b9 84 00 00 00       	mov    $0x84,%ecx
f010040e:	eb 09                	jmp    f0100419 <cons_putc+0x25>
f0100410:	89 ca                	mov    %ecx,%edx
f0100412:	ec                   	in     (%dx),%al
f0100413:	ec                   	in     (%dx),%al
f0100414:	ec                   	in     (%dx),%al
f0100415:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100416:	83 c3 01             	add    $0x1,%ebx
f0100419:	89 f2                	mov    %esi,%edx
f010041b:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010041c:	a8 20                	test   $0x20,%al
f010041e:	75 08                	jne    f0100428 <cons_putc+0x34>
f0100420:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100426:	7e e8                	jle    f0100410 <cons_putc+0x1c>
f0100428:	89 f8                	mov    %edi,%eax
f010042a:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010042d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100432:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100433:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100438:	be 79 03 00 00       	mov    $0x379,%esi
f010043d:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100442:	eb 09                	jmp    f010044d <cons_putc+0x59>
f0100444:	89 ca                	mov    %ecx,%edx
f0100446:	ec                   	in     (%dx),%al
f0100447:	ec                   	in     (%dx),%al
f0100448:	ec                   	in     (%dx),%al
f0100449:	ec                   	in     (%dx),%al
f010044a:	83 c3 01             	add    $0x1,%ebx
f010044d:	89 f2                	mov    %esi,%edx
f010044f:	ec                   	in     (%dx),%al
f0100450:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100456:	7f 04                	jg     f010045c <cons_putc+0x68>
f0100458:	84 c0                	test   %al,%al
f010045a:	79 e8                	jns    f0100444 <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010045c:	ba 78 03 00 00       	mov    $0x378,%edx
f0100461:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100465:	ee                   	out    %al,(%dx)
f0100466:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010046b:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100470:	ee                   	out    %al,(%dx)
f0100471:	b8 08 00 00 00       	mov    $0x8,%eax
f0100476:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100477:	89 fa                	mov    %edi,%edx
f0100479:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f010047f:	89 f8                	mov    %edi,%eax
f0100481:	80 cc 07             	or     $0x7,%ah
f0100484:	85 d2                	test   %edx,%edx
f0100486:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100489:	89 f8                	mov    %edi,%eax
f010048b:	0f b6 c0             	movzbl %al,%eax
f010048e:	83 f8 09             	cmp    $0x9,%eax
f0100491:	74 74                	je     f0100507 <cons_putc+0x113>
f0100493:	83 f8 09             	cmp    $0x9,%eax
f0100496:	7f 0a                	jg     f01004a2 <cons_putc+0xae>
f0100498:	83 f8 08             	cmp    $0x8,%eax
f010049b:	74 14                	je     f01004b1 <cons_putc+0xbd>
f010049d:	e9 99 00 00 00       	jmp    f010053b <cons_putc+0x147>
f01004a2:	83 f8 0a             	cmp    $0xa,%eax
f01004a5:	74 3a                	je     f01004e1 <cons_putc+0xed>
f01004a7:	83 f8 0d             	cmp    $0xd,%eax
f01004aa:	74 3d                	je     f01004e9 <cons_putc+0xf5>
f01004ac:	e9 8a 00 00 00       	jmp    f010053b <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f01004b1:	0f b7 05 28 92 2a f0 	movzwl 0xf02a9228,%eax
f01004b8:	66 85 c0             	test   %ax,%ax
f01004bb:	0f 84 e6 00 00 00    	je     f01005a7 <cons_putc+0x1b3>
			crt_pos--;
f01004c1:	83 e8 01             	sub    $0x1,%eax
f01004c4:	66 a3 28 92 2a f0    	mov    %ax,0xf02a9228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004ca:	0f b7 c0             	movzwl %ax,%eax
f01004cd:	66 81 e7 00 ff       	and    $0xff00,%di
f01004d2:	83 cf 20             	or     $0x20,%edi
f01004d5:	8b 15 2c 92 2a f0    	mov    0xf02a922c,%edx
f01004db:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004df:	eb 78                	jmp    f0100559 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004e1:	66 83 05 28 92 2a f0 	addw   $0x50,0xf02a9228
f01004e8:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004e9:	0f b7 05 28 92 2a f0 	movzwl 0xf02a9228,%eax
f01004f0:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004f6:	c1 e8 16             	shr    $0x16,%eax
f01004f9:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004fc:	c1 e0 04             	shl    $0x4,%eax
f01004ff:	66 a3 28 92 2a f0    	mov    %ax,0xf02a9228
f0100505:	eb 52                	jmp    f0100559 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f0100507:	b8 20 00 00 00       	mov    $0x20,%eax
f010050c:	e8 e3 fe ff ff       	call   f01003f4 <cons_putc>
		cons_putc(' ');
f0100511:	b8 20 00 00 00       	mov    $0x20,%eax
f0100516:	e8 d9 fe ff ff       	call   f01003f4 <cons_putc>
		cons_putc(' ');
f010051b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100520:	e8 cf fe ff ff       	call   f01003f4 <cons_putc>
		cons_putc(' ');
f0100525:	b8 20 00 00 00       	mov    $0x20,%eax
f010052a:	e8 c5 fe ff ff       	call   f01003f4 <cons_putc>
		cons_putc(' ');
f010052f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100534:	e8 bb fe ff ff       	call   f01003f4 <cons_putc>
f0100539:	eb 1e                	jmp    f0100559 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010053b:	0f b7 05 28 92 2a f0 	movzwl 0xf02a9228,%eax
f0100542:	8d 50 01             	lea    0x1(%eax),%edx
f0100545:	66 89 15 28 92 2a f0 	mov    %dx,0xf02a9228
f010054c:	0f b7 c0             	movzwl %ax,%eax
f010054f:	8b 15 2c 92 2a f0    	mov    0xf02a922c,%edx
f0100555:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100559:	66 81 3d 28 92 2a f0 	cmpw   $0x7cf,0xf02a9228
f0100560:	cf 07 
f0100562:	76 43                	jbe    f01005a7 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100564:	a1 2c 92 2a f0       	mov    0xf02a922c,%eax
f0100569:	83 ec 04             	sub    $0x4,%esp
f010056c:	68 00 0f 00 00       	push   $0xf00
f0100571:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100577:	52                   	push   %edx
f0100578:	50                   	push   %eax
f0100579:	e8 3a 52 00 00       	call   f01057b8 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010057e:	8b 15 2c 92 2a f0    	mov    0xf02a922c,%edx
f0100584:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010058a:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100590:	83 c4 10             	add    $0x10,%esp
f0100593:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100598:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010059b:	39 d0                	cmp    %edx,%eax
f010059d:	75 f4                	jne    f0100593 <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010059f:	66 83 2d 28 92 2a f0 	subw   $0x50,0xf02a9228
f01005a6:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01005a7:	8b 0d 30 92 2a f0    	mov    0xf02a9230,%ecx
f01005ad:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005b2:	89 ca                	mov    %ecx,%edx
f01005b4:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01005b5:	0f b7 1d 28 92 2a f0 	movzwl 0xf02a9228,%ebx
f01005bc:	8d 71 01             	lea    0x1(%ecx),%esi
f01005bf:	89 d8                	mov    %ebx,%eax
f01005c1:	66 c1 e8 08          	shr    $0x8,%ax
f01005c5:	89 f2                	mov    %esi,%edx
f01005c7:	ee                   	out    %al,(%dx)
f01005c8:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005cd:	89 ca                	mov    %ecx,%edx
f01005cf:	ee                   	out    %al,(%dx)
f01005d0:	89 d8                	mov    %ebx,%eax
f01005d2:	89 f2                	mov    %esi,%edx
f01005d4:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01005d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005d8:	5b                   	pop    %ebx
f01005d9:	5e                   	pop    %esi
f01005da:	5f                   	pop    %edi
f01005db:	5d                   	pop    %ebp
f01005dc:	c3                   	ret    

f01005dd <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01005dd:	80 3d 34 92 2a f0 00 	cmpb   $0x0,0xf02a9234
f01005e4:	74 11                	je     f01005f7 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01005e6:	55                   	push   %ebp
f01005e7:	89 e5                	mov    %esp,%ebp
f01005e9:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01005ec:	b8 79 02 10 f0       	mov    $0xf0100279,%eax
f01005f1:	e8 a2 fc ff ff       	call   f0100298 <cons_intr>
}
f01005f6:	c9                   	leave  
f01005f7:	f3 c3                	repz ret 

f01005f9 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01005f9:	55                   	push   %ebp
f01005fa:	89 e5                	mov    %esp,%ebp
f01005fc:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01005ff:	b8 db 02 10 f0       	mov    $0xf01002db,%eax
f0100604:	e8 8f fc ff ff       	call   f0100298 <cons_intr>
}
f0100609:	c9                   	leave  
f010060a:	c3                   	ret    

f010060b <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f010060b:	55                   	push   %ebp
f010060c:	89 e5                	mov    %esp,%ebp
f010060e:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100611:	e8 c7 ff ff ff       	call   f01005dd <serial_intr>
	kbd_intr();
f0100616:	e8 de ff ff ff       	call   f01005f9 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010061b:	a1 20 92 2a f0       	mov    0xf02a9220,%eax
f0100620:	3b 05 24 92 2a f0    	cmp    0xf02a9224,%eax
f0100626:	74 26                	je     f010064e <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100628:	8d 50 01             	lea    0x1(%eax),%edx
f010062b:	89 15 20 92 2a f0    	mov    %edx,0xf02a9220
f0100631:	0f b6 88 20 90 2a f0 	movzbl -0xfd56fe0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100638:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f010063a:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100640:	75 11                	jne    f0100653 <cons_getc+0x48>
			cons.rpos = 0;
f0100642:	c7 05 20 92 2a f0 00 	movl   $0x0,0xf02a9220
f0100649:	00 00 00 
f010064c:	eb 05                	jmp    f0100653 <cons_getc+0x48>
		return c;
	}
	return 0;
f010064e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100653:	c9                   	leave  
f0100654:	c3                   	ret    

f0100655 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100655:	55                   	push   %ebp
f0100656:	89 e5                	mov    %esp,%ebp
f0100658:	57                   	push   %edi
f0100659:	56                   	push   %esi
f010065a:	53                   	push   %ebx
f010065b:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010065e:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100665:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010066c:	5a a5 
	if (*cp != 0xA55A) {
f010066e:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100675:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100679:	74 11                	je     f010068c <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010067b:	c7 05 30 92 2a f0 b4 	movl   $0x3b4,0xf02a9230
f0100682:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100685:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f010068a:	eb 16                	jmp    f01006a2 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010068c:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100693:	c7 05 30 92 2a f0 d4 	movl   $0x3d4,0xf02a9230
f010069a:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010069d:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01006a2:	8b 3d 30 92 2a f0    	mov    0xf02a9230,%edi
f01006a8:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006ad:	89 fa                	mov    %edi,%edx
f01006af:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006b0:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006b3:	89 da                	mov    %ebx,%edx
f01006b5:	ec                   	in     (%dx),%al
f01006b6:	0f b6 c8             	movzbl %al,%ecx
f01006b9:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006bc:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006c1:	89 fa                	mov    %edi,%edx
f01006c3:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006c4:	89 da                	mov    %ebx,%edx
f01006c6:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006c7:	89 35 2c 92 2a f0    	mov    %esi,0xf02a922c
	crt_pos = pos;
f01006cd:	0f b6 c0             	movzbl %al,%eax
f01006d0:	09 c8                	or     %ecx,%eax
f01006d2:	66 a3 28 92 2a f0    	mov    %ax,0xf02a9228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006d8:	e8 1c ff ff ff       	call   f01005f9 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006dd:	83 ec 0c             	sub    $0xc,%esp
f01006e0:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f01006e7:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006ec:	50                   	push   %eax
f01006ed:	e8 38 31 00 00       	call   f010382a <irq_setmask_8259A>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006f2:	be fa 03 00 00       	mov    $0x3fa,%esi
f01006f7:	b8 00 00 00 00       	mov    $0x0,%eax
f01006fc:	89 f2                	mov    %esi,%edx
f01006fe:	ee                   	out    %al,(%dx)
f01006ff:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100704:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100709:	ee                   	out    %al,(%dx)
f010070a:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f010070f:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100714:	89 da                	mov    %ebx,%edx
f0100716:	ee                   	out    %al,(%dx)
f0100717:	ba f9 03 00 00       	mov    $0x3f9,%edx
f010071c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100721:	ee                   	out    %al,(%dx)
f0100722:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100727:	b8 03 00 00 00       	mov    $0x3,%eax
f010072c:	ee                   	out    %al,(%dx)
f010072d:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100732:	b8 00 00 00 00       	mov    $0x0,%eax
f0100737:	ee                   	out    %al,(%dx)
f0100738:	ba f9 03 00 00       	mov    $0x3f9,%edx
f010073d:	b8 01 00 00 00       	mov    $0x1,%eax
f0100742:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100743:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100748:	ec                   	in     (%dx),%al
f0100749:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010074b:	83 c4 10             	add    $0x10,%esp
f010074e:	3c ff                	cmp    $0xff,%al
f0100750:	0f 95 05 34 92 2a f0 	setne  0xf02a9234
f0100757:	89 f2                	mov    %esi,%edx
f0100759:	ec                   	in     (%dx),%al
f010075a:	89 da                	mov    %ebx,%edx
f010075c:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

	// Enable serial interrupts
	if (serial_exists)
f010075d:	80 f9 ff             	cmp    $0xff,%cl
f0100760:	74 21                	je     f0100783 <cons_init+0x12e>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_SERIAL));
f0100762:	83 ec 0c             	sub    $0xc,%esp
f0100765:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f010076c:	25 ef ff 00 00       	and    $0xffef,%eax
f0100771:	50                   	push   %eax
f0100772:	e8 b3 30 00 00       	call   f010382a <irq_setmask_8259A>
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100777:	83 c4 10             	add    $0x10,%esp
f010077a:	80 3d 34 92 2a f0 00 	cmpb   $0x0,0xf02a9234
f0100781:	75 10                	jne    f0100793 <cons_init+0x13e>
		cprintf("Serial port does not exist!\n");
f0100783:	83 ec 0c             	sub    $0xc,%esp
f0100786:	68 4f 6a 10 f0       	push   $0xf0106a4f
f010078b:	e8 01 32 00 00       	call   f0103991 <cprintf>
f0100790:	83 c4 10             	add    $0x10,%esp
}
f0100793:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100796:	5b                   	pop    %ebx
f0100797:	5e                   	pop    %esi
f0100798:	5f                   	pop    %edi
f0100799:	5d                   	pop    %ebp
f010079a:	c3                   	ret    

f010079b <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010079b:	55                   	push   %ebp
f010079c:	89 e5                	mov    %esp,%ebp
f010079e:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01007a1:	8b 45 08             	mov    0x8(%ebp),%eax
f01007a4:	e8 4b fc ff ff       	call   f01003f4 <cons_putc>
}
f01007a9:	c9                   	leave  
f01007aa:	c3                   	ret    

f01007ab <getchar>:

int
getchar(void)
{
f01007ab:	55                   	push   %ebp
f01007ac:	89 e5                	mov    %esp,%ebp
f01007ae:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007b1:	e8 55 fe ff ff       	call   f010060b <cons_getc>
f01007b6:	85 c0                	test   %eax,%eax
f01007b8:	74 f7                	je     f01007b1 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007ba:	c9                   	leave  
f01007bb:	c3                   	ret    

f01007bc <iscons>:

int
iscons(int fdnum)
{
f01007bc:	55                   	push   %ebp
f01007bd:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007bf:	b8 01 00 00 00       	mov    $0x1,%eax
f01007c4:	5d                   	pop    %ebp
f01007c5:	c3                   	ret    

f01007c6 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007c6:	55                   	push   %ebp
f01007c7:	89 e5                	mov    %esp,%ebp
f01007c9:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007cc:	68 a0 6c 10 f0       	push   $0xf0106ca0
f01007d1:	68 be 6c 10 f0       	push   $0xf0106cbe
f01007d6:	68 c3 6c 10 f0       	push   $0xf0106cc3
f01007db:	e8 b1 31 00 00       	call   f0103991 <cprintf>
f01007e0:	83 c4 0c             	add    $0xc,%esp
f01007e3:	68 7c 6d 10 f0       	push   $0xf0106d7c
f01007e8:	68 cc 6c 10 f0       	push   $0xf0106ccc
f01007ed:	68 c3 6c 10 f0       	push   $0xf0106cc3
f01007f2:	e8 9a 31 00 00       	call   f0103991 <cprintf>
f01007f7:	83 c4 0c             	add    $0xc,%esp
f01007fa:	68 d5 6c 10 f0       	push   $0xf0106cd5
f01007ff:	68 f3 6c 10 f0       	push   $0xf0106cf3
f0100804:	68 c3 6c 10 f0       	push   $0xf0106cc3
f0100809:	e8 83 31 00 00       	call   f0103991 <cprintf>
	return 0;
}
f010080e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100813:	c9                   	leave  
f0100814:	c3                   	ret    

f0100815 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100815:	55                   	push   %ebp
f0100816:	89 e5                	mov    %esp,%ebp
f0100818:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010081b:	68 fd 6c 10 f0       	push   $0xf0106cfd
f0100820:	e8 6c 31 00 00       	call   f0103991 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100825:	83 c4 08             	add    $0x8,%esp
f0100828:	68 0c 00 10 00       	push   $0x10000c
f010082d:	68 a4 6d 10 f0       	push   $0xf0106da4
f0100832:	e8 5a 31 00 00       	call   f0103991 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100837:	83 c4 0c             	add    $0xc,%esp
f010083a:	68 0c 00 10 00       	push   $0x10000c
f010083f:	68 0c 00 10 f0       	push   $0xf010000c
f0100844:	68 cc 6d 10 f0       	push   $0xf0106dcc
f0100849:	e8 43 31 00 00       	call   f0103991 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010084e:	83 c4 0c             	add    $0xc,%esp
f0100851:	68 71 69 10 00       	push   $0x106971
f0100856:	68 71 69 10 f0       	push   $0xf0106971
f010085b:	68 f0 6d 10 f0       	push   $0xf0106df0
f0100860:	e8 2c 31 00 00       	call   f0103991 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100865:	83 c4 0c             	add    $0xc,%esp
f0100868:	68 00 90 2a 00       	push   $0x2a9000
f010086d:	68 00 90 2a f0       	push   $0xf02a9000
f0100872:	68 14 6e 10 f0       	push   $0xf0106e14
f0100877:	e8 15 31 00 00       	call   f0103991 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010087c:	83 c4 0c             	add    $0xc,%esp
f010087f:	68 08 b0 2e 00       	push   $0x2eb008
f0100884:	68 08 b0 2e f0       	push   $0xf02eb008
f0100889:	68 38 6e 10 f0       	push   $0xf0106e38
f010088e:	e8 fe 30 00 00       	call   f0103991 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100893:	b8 07 b4 2e f0       	mov    $0xf02eb407,%eax
f0100898:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010089d:	83 c4 08             	add    $0x8,%esp
f01008a0:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f01008a5:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01008ab:	85 c0                	test   %eax,%eax
f01008ad:	0f 48 c2             	cmovs  %edx,%eax
f01008b0:	c1 f8 0a             	sar    $0xa,%eax
f01008b3:	50                   	push   %eax
f01008b4:	68 5c 6e 10 f0       	push   $0xf0106e5c
f01008b9:	e8 d3 30 00 00       	call   f0103991 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01008be:	b8 00 00 00 00       	mov    $0x0,%eax
f01008c3:	c9                   	leave  
f01008c4:	c3                   	ret    

f01008c5 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008c5:	55                   	push   %ebp
f01008c6:	89 e5                	mov    %esp,%ebp
f01008c8:	57                   	push   %edi
f01008c9:	56                   	push   %esi
f01008ca:	53                   	push   %ebx
f01008cb:	83 ec 78             	sub    $0x78,%esp

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008ce:	89 eb                	mov    %ebp,%ebx

	uint32_t _ebp, _eip;
	// _esp = read_esp();
	_ebp = read_ebp();

	uint32_t args[5] = {0, 0, 0, 0, 0};
f01008d0:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f01008d7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f01008de:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f01008e5:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01008ec:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	struct Eipdebuginfo context;

	cprintf("Stack backtrace:\n");
f01008f3:	68 16 6d 10 f0       	push   $0xf0106d16
f01008f8:	e8 94 30 00 00       	call   f0103991 <cprintf>

	while (_ebp != 0) {
f01008fd:	83 c4 10             	add    $0x10,%esp
f0100900:	e9 a6 00 00 00       	jmp    f01009ab <mon_backtrace+0xe6>
		
		_eip = *(uint32_t *)(_ebp + 4);		// ret addr
f0100905:	8b 73 04             	mov    0x4(%ebx),%esi

		for (int i=0; i<5; i++) {
f0100908:	b8 00 00 00 00       	mov    $0x0,%eax
			args[i] = *(uint32_t *)(_ebp + 8 + i * 4);
f010090d:	8b 54 83 08          	mov    0x8(%ebx,%eax,4),%edx
f0100911:	89 54 85 d4          	mov    %edx,-0x2c(%ebp,%eax,4)

	while (_ebp != 0) {
		
		_eip = *(uint32_t *)(_ebp + 4);		// ret addr

		for (int i=0; i<5; i++) {
f0100915:	83 c0 01             	add    $0x1,%eax
f0100918:	83 f8 05             	cmp    $0x5,%eax
f010091b:	75 f0                	jne    f010090d <mon_backtrace+0x48>
			args[i] = *(uint32_t *)(_ebp + 8 + i * 4);
		}

		debuginfo_eip((uintptr_t)_eip, &context);
f010091d:	83 ec 08             	sub    $0x8,%esp
f0100920:	8d 45 bc             	lea    -0x44(%ebp),%eax
f0100923:	50                   	push   %eax
f0100924:	56                   	push   %esi
f0100925:	e8 af 43 00 00       	call   f0104cd9 <debuginfo_eip>

		char function_name[50] = {0};
f010092a:	c7 45 8a 00 00 00 00 	movl   $0x0,-0x76(%ebp)
f0100931:	c7 45 b8 00 00 00 00 	movl   $0x0,-0x48(%ebp)
f0100938:	8d 7d 8c             	lea    -0x74(%ebp),%edi
f010093b:	b9 0c 00 00 00       	mov    $0xc,%ecx
f0100940:	b8 00 00 00 00       	mov    $0x0,%eax
f0100945:	f3 ab                	rep stos %eax,%es:(%edi)
		int i = 0;
		for (; i<context.eip_fn_namelen; i++) {
f0100947:	8b 4d c8             	mov    -0x38(%ebp),%ecx
			function_name[i] = context.eip_fn_name[i];
f010094a:	8b 7d c4             	mov    -0x3c(%ebp),%edi

		debuginfo_eip((uintptr_t)_eip, &context);

		char function_name[50] = {0};
		int i = 0;
		for (; i<context.eip_fn_namelen; i++) {
f010094d:	83 c4 10             	add    $0x10,%esp
f0100950:	eb 0b                	jmp    f010095d <mon_backtrace+0x98>
			function_name[i] = context.eip_fn_name[i];
f0100952:	0f b6 14 07          	movzbl (%edi,%eax,1),%edx
f0100956:	88 54 05 8a          	mov    %dl,-0x76(%ebp,%eax,1)

		debuginfo_eip((uintptr_t)_eip, &context);

		char function_name[50] = {0};
		int i = 0;
		for (; i<context.eip_fn_namelen; i++) {
f010095a:	83 c0 01             	add    $0x1,%eax
f010095d:	39 c8                	cmp    %ecx,%eax
f010095f:	7c f1                	jl     f0100952 <mon_backtrace+0x8d>
			function_name[i] = context.eip_fn_name[i];
		}
		function_name[i] = '\0';
f0100961:	85 c9                	test   %ecx,%ecx
f0100963:	b8 00 00 00 00       	mov    $0x0,%eax
f0100968:	0f 48 c8             	cmovs  %eax,%ecx
f010096b:	c6 44 0d 8a 00       	movb   $0x0,-0x76(%ebp,%ecx,1)

		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", _ebp, _eip, args[0], args[1], args[2], args[3], args[4]);
f0100970:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100973:	ff 75 e0             	pushl  -0x20(%ebp)
f0100976:	ff 75 dc             	pushl  -0x24(%ebp)
f0100979:	ff 75 d8             	pushl  -0x28(%ebp)
f010097c:	ff 75 d4             	pushl  -0x2c(%ebp)
f010097f:	56                   	push   %esi
f0100980:	53                   	push   %ebx
f0100981:	68 88 6e 10 f0       	push   $0xf0106e88
f0100986:	e8 06 30 00 00       	call   f0103991 <cprintf>
		cprintf("         %s:%d: %s+%d\n", context.eip_file, context.eip_line, function_name, _eip - context.eip_fn_addr);
f010098b:	83 c4 14             	add    $0x14,%esp
f010098e:	2b 75 cc             	sub    -0x34(%ebp),%esi
f0100991:	56                   	push   %esi
f0100992:	8d 45 8a             	lea    -0x76(%ebp),%eax
f0100995:	50                   	push   %eax
f0100996:	ff 75 c0             	pushl  -0x40(%ebp)
f0100999:	ff 75 bc             	pushl  -0x44(%ebp)
f010099c:	68 28 6d 10 f0       	push   $0xf0106d28
f01009a1:	e8 eb 2f 00 00       	call   f0103991 <cprintf>

		// _rsp = _ebp + 8;			// old_rsp
		_ebp = *(uint32_t *)_ebp;	// old_ebp
f01009a6:	8b 1b                	mov    (%ebx),%ebx
f01009a8:	83 c4 20             	add    $0x20,%esp

	struct Eipdebuginfo context;

	cprintf("Stack backtrace:\n");

	while (_ebp != 0) {
f01009ab:	85 db                	test   %ebx,%ebx
f01009ad:	0f 85 52 ff ff ff    	jne    f0100905 <mon_backtrace+0x40>
		_ebp = *(uint32_t *)_ebp;	// old_ebp

	} 

	return 0;
}
f01009b3:	b8 00 00 00 00       	mov    $0x0,%eax
f01009b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01009bb:	5b                   	pop    %ebx
f01009bc:	5e                   	pop    %esi
f01009bd:	5f                   	pop    %edi
f01009be:	5d                   	pop    %ebp
f01009bf:	c3                   	ret    

f01009c0 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01009c0:	55                   	push   %ebp
f01009c1:	89 e5                	mov    %esp,%ebp
f01009c3:	57                   	push   %edi
f01009c4:	56                   	push   %esi
f01009c5:	53                   	push   %ebx
f01009c6:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01009c9:	68 c0 6e 10 f0       	push   $0xf0106ec0
f01009ce:	e8 be 2f 00 00       	call   f0103991 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01009d3:	c7 04 24 e4 6e 10 f0 	movl   $0xf0106ee4,(%esp)
f01009da:	e8 b2 2f 00 00       	call   f0103991 <cprintf>

	if (tf != NULL)
f01009df:	83 c4 10             	add    $0x10,%esp
f01009e2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01009e6:	74 0e                	je     f01009f6 <monitor+0x36>
		print_trapframe(tf);
f01009e8:	83 ec 0c             	sub    $0xc,%esp
f01009eb:	ff 75 08             	pushl  0x8(%ebp)
f01009ee:	e8 5f 35 00 00       	call   f0103f52 <print_trapframe>
f01009f3:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01009f6:	83 ec 0c             	sub    $0xc,%esp
f01009f9:	68 3f 6d 10 f0       	push   $0xf0106d3f
f01009fe:	e8 f9 4a 00 00       	call   f01054fc <readline>
f0100a03:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100a05:	83 c4 10             	add    $0x10,%esp
f0100a08:	85 c0                	test   %eax,%eax
f0100a0a:	74 ea                	je     f01009f6 <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100a0c:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100a13:	be 00 00 00 00       	mov    $0x0,%esi
f0100a18:	eb 0a                	jmp    f0100a24 <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100a1a:	c6 03 00             	movb   $0x0,(%ebx)
f0100a1d:	89 f7                	mov    %esi,%edi
f0100a1f:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100a22:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100a24:	0f b6 03             	movzbl (%ebx),%eax
f0100a27:	84 c0                	test   %al,%al
f0100a29:	74 63                	je     f0100a8e <monitor+0xce>
f0100a2b:	83 ec 08             	sub    $0x8,%esp
f0100a2e:	0f be c0             	movsbl %al,%eax
f0100a31:	50                   	push   %eax
f0100a32:	68 43 6d 10 f0       	push   $0xf0106d43
f0100a37:	e8 f2 4c 00 00       	call   f010572e <strchr>
f0100a3c:	83 c4 10             	add    $0x10,%esp
f0100a3f:	85 c0                	test   %eax,%eax
f0100a41:	75 d7                	jne    f0100a1a <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f0100a43:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100a46:	74 46                	je     f0100a8e <monitor+0xce>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100a48:	83 fe 0f             	cmp    $0xf,%esi
f0100a4b:	75 14                	jne    f0100a61 <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a4d:	83 ec 08             	sub    $0x8,%esp
f0100a50:	6a 10                	push   $0x10
f0100a52:	68 48 6d 10 f0       	push   $0xf0106d48
f0100a57:	e8 35 2f 00 00       	call   f0103991 <cprintf>
f0100a5c:	83 c4 10             	add    $0x10,%esp
f0100a5f:	eb 95                	jmp    f01009f6 <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f0100a61:	8d 7e 01             	lea    0x1(%esi),%edi
f0100a64:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100a68:	eb 03                	jmp    f0100a6d <monitor+0xad>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100a6a:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a6d:	0f b6 03             	movzbl (%ebx),%eax
f0100a70:	84 c0                	test   %al,%al
f0100a72:	74 ae                	je     f0100a22 <monitor+0x62>
f0100a74:	83 ec 08             	sub    $0x8,%esp
f0100a77:	0f be c0             	movsbl %al,%eax
f0100a7a:	50                   	push   %eax
f0100a7b:	68 43 6d 10 f0       	push   $0xf0106d43
f0100a80:	e8 a9 4c 00 00       	call   f010572e <strchr>
f0100a85:	83 c4 10             	add    $0x10,%esp
f0100a88:	85 c0                	test   %eax,%eax
f0100a8a:	74 de                	je     f0100a6a <monitor+0xaa>
f0100a8c:	eb 94                	jmp    f0100a22 <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f0100a8e:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a95:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100a96:	85 f6                	test   %esi,%esi
f0100a98:	0f 84 58 ff ff ff    	je     f01009f6 <monitor+0x36>
f0100a9e:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100aa3:	83 ec 08             	sub    $0x8,%esp
f0100aa6:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100aa9:	ff 34 85 20 6f 10 f0 	pushl  -0xfef90e0(,%eax,4)
f0100ab0:	ff 75 a8             	pushl  -0x58(%ebp)
f0100ab3:	e8 18 4c 00 00       	call   f01056d0 <strcmp>
f0100ab8:	83 c4 10             	add    $0x10,%esp
f0100abb:	85 c0                	test   %eax,%eax
f0100abd:	75 21                	jne    f0100ae0 <monitor+0x120>
			return commands[i].func(argc, argv, tf);
f0100abf:	83 ec 04             	sub    $0x4,%esp
f0100ac2:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100ac5:	ff 75 08             	pushl  0x8(%ebp)
f0100ac8:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100acb:	52                   	push   %edx
f0100acc:	56                   	push   %esi
f0100acd:	ff 14 85 28 6f 10 f0 	call   *-0xfef90d8(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100ad4:	83 c4 10             	add    $0x10,%esp
f0100ad7:	85 c0                	test   %eax,%eax
f0100ad9:	78 25                	js     f0100b00 <monitor+0x140>
f0100adb:	e9 16 ff ff ff       	jmp    f01009f6 <monitor+0x36>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100ae0:	83 c3 01             	add    $0x1,%ebx
f0100ae3:	83 fb 03             	cmp    $0x3,%ebx
f0100ae6:	75 bb                	jne    f0100aa3 <monitor+0xe3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100ae8:	83 ec 08             	sub    $0x8,%esp
f0100aeb:	ff 75 a8             	pushl  -0x58(%ebp)
f0100aee:	68 65 6d 10 f0       	push   $0xf0106d65
f0100af3:	e8 99 2e 00 00       	call   f0103991 <cprintf>
f0100af8:	83 c4 10             	add    $0x10,%esp
f0100afb:	e9 f6 fe ff ff       	jmp    f01009f6 <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100b00:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100b03:	5b                   	pop    %ebx
f0100b04:	5e                   	pop    %esi
f0100b05:	5f                   	pop    %edi
f0100b06:	5d                   	pop    %ebp
f0100b07:	c3                   	ret    

f0100b08 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100b08:	55                   	push   %ebp
f0100b09:	89 e5                	mov    %esp,%ebp
f0100b0b:	56                   	push   %esi
f0100b0c:	53                   	push   %ebx
f0100b0d:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100b0f:	83 ec 0c             	sub    $0xc,%esp
f0100b12:	50                   	push   %eax
f0100b13:	e8 e4 2c 00 00       	call   f01037fc <mc146818_read>
f0100b18:	89 c6                	mov    %eax,%esi
f0100b1a:	83 c3 01             	add    $0x1,%ebx
f0100b1d:	89 1c 24             	mov    %ebx,(%esp)
f0100b20:	e8 d7 2c 00 00       	call   f01037fc <mc146818_read>
f0100b25:	c1 e0 08             	shl    $0x8,%eax
f0100b28:	09 f0                	or     %esi,%eax
}
f0100b2a:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100b2d:	5b                   	pop    %ebx
f0100b2e:	5e                   	pop    %esi
f0100b2f:	5d                   	pop    %ebp
f0100b30:	c3                   	ret    

f0100b31 <boot_alloc>:
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100b31:	83 3d 38 92 2a f0 00 	cmpl   $0x0,0xf02a9238
f0100b38:	75 11                	jne    f0100b4b <boot_alloc+0x1a>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100b3a:	ba 07 c0 2e f0       	mov    $0xf02ec007,%edx
f0100b3f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b45:	89 15 38 92 2a f0    	mov    %edx,0xf02a9238
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

	if ((uint32_t)nextfree > 0xffffffff - n)
f0100b4b:	8b 15 38 92 2a f0    	mov    0xf02a9238,%edx
f0100b51:	89 c1                	mov    %eax,%ecx
f0100b53:	f7 d1                	not    %ecx
f0100b55:	39 ca                	cmp    %ecx,%edx
f0100b57:	76 17                	jbe    f0100b70 <boot_alloc+0x3f>
// before the page_free_list list has been set up.
// Note that when this function is called, we are still using entry_pgdir,
// which only maps the first 4MB of physical memory.
static void *
boot_alloc(uint32_t n)
{
f0100b59:	55                   	push   %ebp
f0100b5a:	89 e5                	mov    %esp,%ebp
f0100b5c:	83 ec 0c             	sub    $0xc,%esp
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

	if ((uint32_t)nextfree > 0xffffffff - n)
		panic("boot_alloc: out of memory\n");
f0100b5f:	68 44 6f 10 f0       	push   $0xf0106f44
f0100b64:	6a 70                	push   $0x70
f0100b66:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0100b6b:	e8 d0 f4 ff ff       	call   f0100040 <_panic>

	result = nextfree;
	nextfree = ROUNDUP(result + n , PGSIZE);
f0100b70:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100b77:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b7c:	a3 38 92 2a f0       	mov    %eax,0xf02a9238

	return result;
}
f0100b81:	89 d0                	mov    %edx,%eax
f0100b83:	c3                   	ret    

f0100b84 <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100b84:	89 d1                	mov    %edx,%ecx
f0100b86:	c1 e9 16             	shr    $0x16,%ecx
f0100b89:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100b8c:	a8 01                	test   $0x1,%al
f0100b8e:	74 52                	je     f0100be2 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b90:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b95:	89 c1                	mov    %eax,%ecx
f0100b97:	c1 e9 0c             	shr    $0xc,%ecx
f0100b9a:	3b 0d a0 9e 2a f0    	cmp    0xf02a9ea0,%ecx
f0100ba0:	72 1b                	jb     f0100bbd <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100ba2:	55                   	push   %ebp
f0100ba3:	89 e5                	mov    %esp,%ebp
f0100ba5:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ba8:	50                   	push   %eax
f0100ba9:	68 a4 69 10 f0       	push   $0xf01069a4
f0100bae:	68 40 04 00 00       	push   $0x440
f0100bb3:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0100bb8:	e8 83 f4 ff ff       	call   f0100040 <_panic>
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));

	// cprintf("[?] In check_va2pa\n");
	// cprintf("[?] *pte_store:%x, **pte_store:%x\n", &p[PTX(va)], p[PTX(va)]);

	if (!(p[PTX(va)] & PTE_P))
f0100bbd:	c1 ea 0c             	shr    $0xc,%edx
f0100bc0:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100bc6:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100bcd:	89 c2                	mov    %eax,%edx
f0100bcf:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100bd2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100bd7:	85 d2                	test   %edx,%edx
f0100bd9:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100bde:	0f 44 c2             	cmove  %edx,%eax
f0100be1:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100be2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	// cprintf("[?] *pte_store:%x, **pte_store:%x\n", &p[PTX(va)], p[PTX(va)]);

	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100be7:	c3                   	ret    

f0100be8 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100be8:	55                   	push   %ebp
f0100be9:	89 e5                	mov    %esp,%ebp
f0100beb:	57                   	push   %edi
f0100bec:	56                   	push   %esi
f0100bed:	53                   	push   %ebx
f0100bee:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100bf1:	84 c0                	test   %al,%al
f0100bf3:	0f 85 a0 02 00 00    	jne    f0100e99 <check_page_free_list+0x2b1>
f0100bf9:	e9 ad 02 00 00       	jmp    f0100eab <check_page_free_list+0x2c3>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100bfe:	83 ec 04             	sub    $0x4,%esp
f0100c01:	68 cc 72 10 f0       	push   $0xf01072cc
f0100c06:	68 71 03 00 00       	push   $0x371
f0100c0b:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0100c10:	e8 2b f4 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100c15:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100c18:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100c1b:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100c1e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100c21:	89 c2                	mov    %eax,%edx
f0100c23:	2b 15 a8 9e 2a f0    	sub    0xf02a9ea8,%edx
f0100c29:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100c2f:	0f 95 c2             	setne  %dl
f0100c32:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100c35:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100c39:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100c3b:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c3f:	8b 00                	mov    (%eax),%eax
f0100c41:	85 c0                	test   %eax,%eax
f0100c43:	75 dc                	jne    f0100c21 <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100c45:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c48:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100c4e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c51:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100c54:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100c56:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100c59:	a3 40 92 2a f0       	mov    %eax,0xf02a9240
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c5e:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c63:	8b 1d 40 92 2a f0    	mov    0xf02a9240,%ebx
f0100c69:	eb 53                	jmp    f0100cbe <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c6b:	89 d8                	mov    %ebx,%eax
f0100c6d:	2b 05 a8 9e 2a f0    	sub    0xf02a9ea8,%eax
f0100c73:	c1 f8 03             	sar    $0x3,%eax
f0100c76:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100c79:	89 c2                	mov    %eax,%edx
f0100c7b:	c1 ea 16             	shr    $0x16,%edx
f0100c7e:	39 f2                	cmp    %esi,%edx
f0100c80:	73 3a                	jae    f0100cbc <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c82:	89 c2                	mov    %eax,%edx
f0100c84:	c1 ea 0c             	shr    $0xc,%edx
f0100c87:	3b 15 a0 9e 2a f0    	cmp    0xf02a9ea0,%edx
f0100c8d:	72 12                	jb     f0100ca1 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c8f:	50                   	push   %eax
f0100c90:	68 a4 69 10 f0       	push   $0xf01069a4
f0100c95:	6a 58                	push   $0x58
f0100c97:	68 6b 6f 10 f0       	push   $0xf0106f6b
f0100c9c:	e8 9f f3 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100ca1:	83 ec 04             	sub    $0x4,%esp
f0100ca4:	68 80 00 00 00       	push   $0x80
f0100ca9:	68 97 00 00 00       	push   $0x97
f0100cae:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100cb3:	50                   	push   %eax
f0100cb4:	e8 b2 4a 00 00       	call   f010576b <memset>
f0100cb9:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100cbc:	8b 1b                	mov    (%ebx),%ebx
f0100cbe:	85 db                	test   %ebx,%ebx
f0100cc0:	75 a9                	jne    f0100c6b <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100cc2:	b8 00 00 00 00       	mov    $0x0,%eax
f0100cc7:	e8 65 fe ff ff       	call   f0100b31 <boot_alloc>
f0100ccc:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ccf:	8b 15 40 92 2a f0    	mov    0xf02a9240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100cd5:	8b 0d a8 9e 2a f0    	mov    0xf02a9ea8,%ecx
		assert(pp < pages + npages);
f0100cdb:	a1 a0 9e 2a f0       	mov    0xf02a9ea0,%eax
f0100ce0:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100ce3:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100ce6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100ce9:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100cec:	be 00 00 00 00       	mov    $0x0,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100cf1:	e9 52 01 00 00       	jmp    f0100e48 <check_page_free_list+0x260>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100cf6:	39 ca                	cmp    %ecx,%edx
f0100cf8:	73 19                	jae    f0100d13 <check_page_free_list+0x12b>
f0100cfa:	68 79 6f 10 f0       	push   $0xf0106f79
f0100cff:	68 85 6f 10 f0       	push   $0xf0106f85
f0100d04:	68 8b 03 00 00       	push   $0x38b
f0100d09:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0100d0e:	e8 2d f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100d13:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100d16:	72 19                	jb     f0100d31 <check_page_free_list+0x149>
f0100d18:	68 9a 6f 10 f0       	push   $0xf0106f9a
f0100d1d:	68 85 6f 10 f0       	push   $0xf0106f85
f0100d22:	68 8c 03 00 00       	push   $0x38c
f0100d27:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0100d2c:	e8 0f f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d31:	89 d0                	mov    %edx,%eax
f0100d33:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100d36:	a8 07                	test   $0x7,%al
f0100d38:	74 19                	je     f0100d53 <check_page_free_list+0x16b>
f0100d3a:	68 f0 72 10 f0       	push   $0xf01072f0
f0100d3f:	68 85 6f 10 f0       	push   $0xf0106f85
f0100d44:	68 8d 03 00 00       	push   $0x38d
f0100d49:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0100d4e:	e8 ed f2 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100d53:	c1 f8 03             	sar    $0x3,%eax
f0100d56:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100d59:	85 c0                	test   %eax,%eax
f0100d5b:	75 19                	jne    f0100d76 <check_page_free_list+0x18e>
f0100d5d:	68 ae 6f 10 f0       	push   $0xf0106fae
f0100d62:	68 85 6f 10 f0       	push   $0xf0106f85
f0100d67:	68 90 03 00 00       	push   $0x390
f0100d6c:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0100d71:	e8 ca f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d76:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d7b:	75 19                	jne    f0100d96 <check_page_free_list+0x1ae>
f0100d7d:	68 bf 6f 10 f0       	push   $0xf0106fbf
f0100d82:	68 85 6f 10 f0       	push   $0xf0106f85
f0100d87:	68 91 03 00 00       	push   $0x391
f0100d8c:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0100d91:	e8 aa f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d96:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d9b:	75 19                	jne    f0100db6 <check_page_free_list+0x1ce>
f0100d9d:	68 24 73 10 f0       	push   $0xf0107324
f0100da2:	68 85 6f 10 f0       	push   $0xf0106f85
f0100da7:	68 92 03 00 00       	push   $0x392
f0100dac:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0100db1:	e8 8a f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100db6:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100dbb:	75 19                	jne    f0100dd6 <check_page_free_list+0x1ee>
f0100dbd:	68 d8 6f 10 f0       	push   $0xf0106fd8
f0100dc2:	68 85 6f 10 f0       	push   $0xf0106f85
f0100dc7:	68 93 03 00 00       	push   $0x393
f0100dcc:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0100dd1:	e8 6a f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100dd6:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100ddb:	0f 86 f1 00 00 00    	jbe    f0100ed2 <check_page_free_list+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100de1:	89 c7                	mov    %eax,%edi
f0100de3:	c1 ef 0c             	shr    $0xc,%edi
f0100de6:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0100de9:	77 12                	ja     f0100dfd <check_page_free_list+0x215>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100deb:	50                   	push   %eax
f0100dec:	68 a4 69 10 f0       	push   $0xf01069a4
f0100df1:	6a 58                	push   $0x58
f0100df3:	68 6b 6f 10 f0       	push   $0xf0106f6b
f0100df8:	e8 43 f2 ff ff       	call   f0100040 <_panic>
f0100dfd:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100e03:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100e06:	0f 86 b6 00 00 00    	jbe    f0100ec2 <check_page_free_list+0x2da>
f0100e0c:	68 48 73 10 f0       	push   $0xf0107348
f0100e11:	68 85 6f 10 f0       	push   $0xf0106f85
f0100e16:	68 94 03 00 00       	push   $0x394
f0100e1b:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0100e20:	e8 1b f2 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e25:	68 f2 6f 10 f0       	push   $0xf0106ff2
f0100e2a:	68 85 6f 10 f0       	push   $0xf0106f85
f0100e2f:	68 96 03 00 00       	push   $0x396
f0100e34:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0100e39:	e8 02 f2 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100e3e:	83 c6 01             	add    $0x1,%esi
f0100e41:	eb 03                	jmp    f0100e46 <check_page_free_list+0x25e>
		else
			++nfree_extmem;
f0100e43:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e46:	8b 12                	mov    (%edx),%edx
f0100e48:	85 d2                	test   %edx,%edx
f0100e4a:	0f 85 a6 fe ff ff    	jne    f0100cf6 <check_page_free_list+0x10e>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100e50:	85 f6                	test   %esi,%esi
f0100e52:	7f 19                	jg     f0100e6d <check_page_free_list+0x285>
f0100e54:	68 0f 70 10 f0       	push   $0xf010700f
f0100e59:	68 85 6f 10 f0       	push   $0xf0106f85
f0100e5e:	68 9e 03 00 00       	push   $0x39e
f0100e63:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0100e68:	e8 d3 f1 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100e6d:	85 db                	test   %ebx,%ebx
f0100e6f:	7f 19                	jg     f0100e8a <check_page_free_list+0x2a2>
f0100e71:	68 21 70 10 f0       	push   $0xf0107021
f0100e76:	68 85 6f 10 f0       	push   $0xf0106f85
f0100e7b:	68 9f 03 00 00       	push   $0x39f
f0100e80:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0100e85:	e8 b6 f1 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100e8a:	83 ec 0c             	sub    $0xc,%esp
f0100e8d:	68 90 73 10 f0       	push   $0xf0107390
f0100e92:	e8 fa 2a 00 00       	call   f0103991 <cprintf>
}
f0100e97:	eb 49                	jmp    f0100ee2 <check_page_free_list+0x2fa>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100e99:	a1 40 92 2a f0       	mov    0xf02a9240,%eax
f0100e9e:	85 c0                	test   %eax,%eax
f0100ea0:	0f 85 6f fd ff ff    	jne    f0100c15 <check_page_free_list+0x2d>
f0100ea6:	e9 53 fd ff ff       	jmp    f0100bfe <check_page_free_list+0x16>
f0100eab:	83 3d 40 92 2a f0 00 	cmpl   $0x0,0xf02a9240
f0100eb2:	0f 84 46 fd ff ff    	je     f0100bfe <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100eb8:	be 00 04 00 00       	mov    $0x400,%esi
f0100ebd:	e9 a1 fd ff ff       	jmp    f0100c63 <check_page_free_list+0x7b>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100ec2:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100ec7:	0f 85 76 ff ff ff    	jne    f0100e43 <check_page_free_list+0x25b>
f0100ecd:	e9 53 ff ff ff       	jmp    f0100e25 <check_page_free_list+0x23d>
f0100ed2:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100ed7:	0f 85 61 ff ff ff    	jne    f0100e3e <check_page_free_list+0x256>
f0100edd:	e9 43 ff ff ff       	jmp    f0100e25 <check_page_free_list+0x23d>

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);

	cprintf("check_page_free_list() succeeded!\n");
}
f0100ee2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ee5:	5b                   	pop    %ebx
f0100ee6:	5e                   	pop    %esi
f0100ee7:	5f                   	pop    %edi
f0100ee8:	5d                   	pop    %ebp
f0100ee9:	c3                   	ret    

f0100eea <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100eea:	55                   	push   %ebp
f0100eeb:	89 e5                	mov    %esp,%ebp
f0100eed:	56                   	push   %esi
f0100eee:	53                   	push   %ebx
	// 	pages[i].pp_link = page_free_list;
	// 	page_free_list = &pages[i];
	// }

	// 1)	first page in use
	pages[0].pp_ref = 1;
f0100eef:	a1 a8 9e 2a f0       	mov    0xf02a9ea8,%eax
f0100ef4:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	pages[0].pp_link = 0;
f0100efa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	extern unsigned char mpentry_start[], mpentry_end[];
	uint32_t size = ROUNDUP(mpentry_end - mpentry_start, PGSIZE);
f0100f00:	be e9 69 10 f0       	mov    $0xf01069e9,%esi
f0100f05:	81 ee 70 59 10 f0    	sub    $0xf0105970,%esi
f0100f0b:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	// cprintf("[?] Init from 0x%x to 0x%x\n", PGSIZE, PGSIZE * npages_basemem);

	// 2)	[1-npages_basemem) free, except APs area (lab4)
	for (i = 1; i < npages_basemem; i++) {
f0100f11:	bb 01 00 00 00       	mov    $0x1,%ebx
		if (i * PGSIZE >= MPENTRY_PADDR && i * PGSIZE < MPENTRY_PADDR + size) {
f0100f16:	81 c6 00 70 00 00    	add    $0x7000,%esi
	extern unsigned char mpentry_start[], mpentry_end[];
	uint32_t size = ROUNDUP(mpentry_end - mpentry_start, PGSIZE);
	// cprintf("[?] Init from 0x%x to 0x%x\n", PGSIZE, PGSIZE * npages_basemem);

	// 2)	[1-npages_basemem) free, except APs area (lab4)
	for (i = 1; i < npages_basemem; i++) {
f0100f1c:	eb 61                	jmp    f0100f7f <page_init+0x95>
f0100f1e:	89 d8                	mov    %ebx,%eax
f0100f20:	c1 e0 0c             	shl    $0xc,%eax
		if (i * PGSIZE >= MPENTRY_PADDR && i * PGSIZE < MPENTRY_PADDR + size) {
f0100f23:	3d ff 6f 00 00       	cmp    $0x6fff,%eax
f0100f28:	76 2a                	jbe    f0100f54 <page_init+0x6a>
f0100f2a:	39 c6                	cmp    %eax,%esi
f0100f2c:	76 26                	jbe    f0100f54 <page_init+0x6a>
			pages[i].pp_ref = 1;
f0100f2e:	a1 a8 9e 2a f0       	mov    0xf02a9ea8,%eax
f0100f33:	8d 04 d8             	lea    (%eax,%ebx,8),%eax
f0100f36:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link = 0;
f0100f3c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			cprintf("[?] non-boot CPUs (APs)\n");
f0100f42:	83 ec 0c             	sub    $0xc,%esp
f0100f45:	68 32 70 10 f0       	push   $0xf0107032
f0100f4a:	e8 42 2a 00 00       	call   f0103991 <cprintf>
f0100f4f:	83 c4 10             	add    $0x10,%esp
f0100f52:	eb 28                	jmp    f0100f7c <page_init+0x92>
		}
		else {
			pages[i].pp_ref = 0;
f0100f54:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100f5b:	89 c2                	mov    %eax,%edx
f0100f5d:	03 15 a8 9e 2a f0    	add    0xf02a9ea8,%edx
f0100f63:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
			pages[i].pp_link = page_free_list;
f0100f69:	8b 0d 40 92 2a f0    	mov    0xf02a9240,%ecx
f0100f6f:	89 0a                	mov    %ecx,(%edx)
			page_free_list = &pages[i];
f0100f71:	03 05 a8 9e 2a f0    	add    0xf02a9ea8,%eax
f0100f77:	a3 40 92 2a f0       	mov    %eax,0xf02a9240
	extern unsigned char mpentry_start[], mpentry_end[];
	uint32_t size = ROUNDUP(mpentry_end - mpentry_start, PGSIZE);
	// cprintf("[?] Init from 0x%x to 0x%x\n", PGSIZE, PGSIZE * npages_basemem);

	// 2)	[1-npages_basemem) free, except APs area (lab4)
	for (i = 1; i < npages_basemem; i++) {
f0100f7c:	83 c3 01             	add    $0x1,%ebx
f0100f7f:	3b 1d 44 92 2a f0    	cmp    0xf02a9244,%ebx
f0100f85:	72 97                	jb     f0100f1e <page_init+0x34>
f0100f87:	8b 0d 40 92 2a f0    	mov    0xf02a9240,%ecx
f0100f8d:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100f94:	ba 00 00 00 00       	mov    $0x0,%edx
f0100f99:	eb 23                	jmp    f0100fbe <page_init+0xd4>
	}

	// [npages_basemem, IOPHYSMEM / PGSIZE) free
	// cprintf("[?] %d, %d, %d\n", npages_basemem, IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE);
	for (; i < IOPHYSMEM / PGSIZE; i++) {
		pages[i].pp_ref = 0;
f0100f9b:	89 c2                	mov    %eax,%edx
f0100f9d:	03 15 a8 9e 2a f0    	add    0xf02a9ea8,%edx
f0100fa3:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f0100fa9:	89 0a                	mov    %ecx,(%edx)
		page_free_list = &pages[i];
f0100fab:	89 c1                	mov    %eax,%ecx
f0100fad:	03 0d a8 9e 2a f0    	add    0xf02a9ea8,%ecx
		}
	}

	// [npages_basemem, IOPHYSMEM / PGSIZE) free
	// cprintf("[?] %d, %d, %d\n", npages_basemem, IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE);
	for (; i < IOPHYSMEM / PGSIZE; i++) {
f0100fb3:	83 c3 01             	add    $0x1,%ebx
f0100fb6:	83 c0 08             	add    $0x8,%eax
f0100fb9:	ba 01 00 00 00       	mov    $0x1,%edx
f0100fbe:	81 fb 9f 00 00 00    	cmp    $0x9f,%ebx
f0100fc4:	76 d5                	jbe    f0100f9b <page_init+0xb1>
f0100fc6:	84 d2                	test   %dl,%dl
f0100fc8:	74 06                	je     f0100fd0 <page_init+0xe6>
f0100fca:	89 0d 40 92 2a f0    	mov    %ecx,0xf02a9240
f0100fd0:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100fd7:	eb 1a                	jmp    f0100ff3 <page_init+0x109>
		page_free_list = &pages[i];
	}

	// 3) [IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE) in use
	for (; i < EXTPHYSMEM / PGSIZE; i++) {
		pages[i].pp_ref = 1;
f0100fd9:	89 c2                	mov    %eax,%edx
f0100fdb:	03 15 a8 9e 2a f0    	add    0xf02a9ea8,%edx
f0100fe1:	66 c7 42 04 01 00    	movw   $0x1,0x4(%edx)
		pages[i].pp_link = 0;
f0100fe7:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}

	// 3) [IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE) in use
	for (; i < EXTPHYSMEM / PGSIZE; i++) {
f0100fed:	83 c3 01             	add    $0x1,%ebx
f0100ff0:	83 c0 08             	add    $0x8,%eax
f0100ff3:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f0100ff9:	76 de                	jbe    f0100fd9 <page_init+0xef>
f0100ffb:	8d 34 dd 00 00 00 00 	lea    0x0(,%ebx,8),%esi
f0101002:	eb 1a                	jmp    f010101e <page_init+0x134>

	// cprintf("[?] Init from 0x%x to 0x%x\n", EXTPHYSMEM, PGSIZE * npages);
	// cprintf("[?] %d\n", PADDR(boot_alloc(0)) / PGSIZE);
	// 4) [EXTPHYSMEM / PGSIZE, kernel end) in use
	for (; i < PADDR(boot_alloc(0)) / PGSIZE; i++) {
		pages[i].pp_ref = 1;
f0101004:	89 f0                	mov    %esi,%eax
f0101006:	03 05 a8 9e 2a f0    	add    0xf02a9ea8,%eax
f010100c:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
		pages[i].pp_link = 0;
f0101012:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}

	// cprintf("[?] Init from 0x%x to 0x%x\n", EXTPHYSMEM, PGSIZE * npages);
	// cprintf("[?] %d\n", PADDR(boot_alloc(0)) / PGSIZE);
	// 4) [EXTPHYSMEM / PGSIZE, kernel end) in use
	for (; i < PADDR(boot_alloc(0)) / PGSIZE; i++) {
f0101018:	83 c3 01             	add    $0x1,%ebx
f010101b:	83 c6 08             	add    $0x8,%esi
f010101e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101023:	e8 09 fb ff ff       	call   f0100b31 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101028:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010102d:	77 15                	ja     f0101044 <page_init+0x15a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010102f:	50                   	push   %eax
f0101030:	68 c8 69 10 f0       	push   $0xf01069c8
f0101035:	68 7d 01 00 00       	push   $0x17d
f010103a:	68 5f 6f 10 f0       	push   $0xf0106f5f
f010103f:	e8 fc ef ff ff       	call   f0100040 <_panic>
f0101044:	05 00 00 00 10       	add    $0x10000000,%eax
f0101049:	c1 e8 0c             	shr    $0xc,%eax
f010104c:	39 c3                	cmp    %eax,%ebx
f010104e:	72 b4                	jb     f0101004 <page_init+0x11a>
f0101050:	8b 0d 40 92 2a f0    	mov    0xf02a9240,%ecx
f0101056:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f010105d:	ba 00 00 00 00       	mov    $0x0,%edx
f0101062:	eb 23                	jmp    f0101087 <page_init+0x19d>
		pages[i].pp_link = 0;
	}

	// [kernel end, npages) free
	for (; i < npages; i++) {
		pages[i].pp_ref = 0;
f0101064:	89 c2                	mov    %eax,%edx
f0101066:	03 15 a8 9e 2a f0    	add    0xf02a9ea8,%edx
f010106c:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f0101072:	89 0a                	mov    %ecx,(%edx)
		page_free_list = &pages[i];
f0101074:	89 c1                	mov    %eax,%ecx
f0101076:	03 0d a8 9e 2a f0    	add    0xf02a9ea8,%ecx
		pages[i].pp_ref = 1;
		pages[i].pp_link = 0;
	}

	// [kernel end, npages) free
	for (; i < npages; i++) {
f010107c:	83 c3 01             	add    $0x1,%ebx
f010107f:	83 c0 08             	add    $0x8,%eax
f0101082:	ba 01 00 00 00       	mov    $0x1,%edx
f0101087:	3b 1d a0 9e 2a f0    	cmp    0xf02a9ea0,%ebx
f010108d:	72 d5                	jb     f0101064 <page_init+0x17a>
f010108f:	84 d2                	test   %dl,%dl
f0101091:	74 06                	je     f0101099 <page_init+0x1af>
f0101093:	89 0d 40 92 2a f0    	mov    %ecx,0xf02a9240
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}

}
f0101099:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010109c:	5b                   	pop    %ebx
f010109d:	5e                   	pop    %esi
f010109e:	5d                   	pop    %ebp
f010109f:	c3                   	ret    

f01010a0 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f01010a0:	55                   	push   %ebp
f01010a1:	89 e5                	mov    %esp,%ebp
f01010a3:	56                   	push   %esi
f01010a4:	53                   	push   %ebx
	// Fill this function in

	// no more page in free list, we run out of free memory
	if (page_free_list == 0)
f01010a5:	8b 1d 40 92 2a f0    	mov    0xf02a9240,%ebx
f01010ab:	85 db                	test   %ebx,%ebx
f01010ad:	74 59                	je     f0101108 <page_alloc+0x68>
		return 0;

	// get the previous page in free link
	struct PageInfo* last_free = page_free_list->pp_link;
f01010af:	8b 33                	mov    (%ebx),%esi
	struct PageInfo* result = page_free_list;

	// get a free page from the list
	page_free_list->pp_link = 0;
f01010b1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (alloc_flags & ALLOC_ZERO) {
f01010b7:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01010bb:	74 45                	je     f0101102 <page_alloc+0x62>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01010bd:	89 d8                	mov    %ebx,%eax
f01010bf:	2b 05 a8 9e 2a f0    	sub    0xf02a9ea8,%eax
f01010c5:	c1 f8 03             	sar    $0x3,%eax
f01010c8:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01010cb:	89 c2                	mov    %eax,%edx
f01010cd:	c1 ea 0c             	shr    $0xc,%edx
f01010d0:	3b 15 a0 9e 2a f0    	cmp    0xf02a9ea0,%edx
f01010d6:	72 12                	jb     f01010ea <page_alloc+0x4a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010d8:	50                   	push   %eax
f01010d9:	68 a4 69 10 f0       	push   $0xf01069a4
f01010de:	6a 58                	push   $0x58
f01010e0:	68 6b 6f 10 f0       	push   $0xf0106f6b
f01010e5:	e8 56 ef ff ff       	call   f0100040 <_panic>
		// cprintf("[?] alloc zero, %x, %x\n", page_free_list, PADDR(page_free_list));
		// memset((char *)page2pa(page_free_list), 0, PGSIZE);
		memset(page2kva(page_free_list), 0, PGSIZE);
f01010ea:	83 ec 04             	sub    $0x4,%esp
f01010ed:	68 00 10 00 00       	push   $0x1000
f01010f2:	6a 00                	push   $0x0
f01010f4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01010f9:	50                   	push   %eax
f01010fa:	e8 6c 46 00 00       	call   f010576b <memset>
f01010ff:	83 c4 10             	add    $0x10,%esp
	}
	
	// update free list head
	page_free_list = last_free;
f0101102:	89 35 40 92 2a f0    	mov    %esi,0xf02a9240

	return result;
}
f0101108:	89 d8                	mov    %ebx,%eax
f010110a:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010110d:	5b                   	pop    %ebx
f010110e:	5e                   	pop    %esi
f010110f:	5d                   	pop    %ebp
f0101110:	c3                   	ret    

f0101111 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0101111:	55                   	push   %ebp
f0101112:	89 e5                	mov    %esp,%ebp
f0101114:	83 ec 08             	sub    $0x8,%esp
f0101117:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.

	if (pp == 0)
f010111a:	85 c0                	test   %eax,%eax
f010111c:	74 47                	je     f0101165 <page_free+0x54>
		return;
	if (pp->pp_link != 0)
f010111e:	83 38 00             	cmpl   $0x0,(%eax)
f0101121:	74 17                	je     f010113a <page_free+0x29>
		panic("page_free: double free or corrupted\n");
f0101123:	83 ec 04             	sub    $0x4,%esp
f0101126:	68 b4 73 10 f0       	push   $0xf01073b4
f010112b:	68 c1 01 00 00       	push   $0x1c1
f0101130:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101135:	e8 06 ef ff ff       	call   f0100040 <_panic>
	if (pp->pp_ref != 0)
f010113a:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010113f:	74 17                	je     f0101158 <page_free+0x47>
		panic("page_free: other pointers still point to it, mind use-after-free!\n");
f0101141:	83 ec 04             	sub    $0x4,%esp
f0101144:	68 dc 73 10 f0       	push   $0xf01073dc
f0101149:	68 c3 01 00 00       	push   $0x1c3
f010114e:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101153:	e8 e8 ee ff ff       	call   f0100040 <_panic>

	pp->pp_link = page_free_list;
f0101158:	8b 15 40 92 2a f0    	mov    0xf02a9240,%edx
f010115e:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101160:	a3 40 92 2a f0       	mov    %eax,0xf02a9240

}
f0101165:	c9                   	leave  
f0101166:	c3                   	ret    

f0101167 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0101167:	55                   	push   %ebp
f0101168:	89 e5                	mov    %esp,%ebp
f010116a:	83 ec 08             	sub    $0x8,%esp
f010116d:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0101170:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0101174:	83 e8 01             	sub    $0x1,%eax
f0101177:	66 89 42 04          	mov    %ax,0x4(%edx)
f010117b:	66 85 c0             	test   %ax,%ax
f010117e:	75 0c                	jne    f010118c <page_decref+0x25>
		page_free(pp);
f0101180:	83 ec 0c             	sub    $0xc,%esp
f0101183:	52                   	push   %edx
f0101184:	e8 88 ff ff ff       	call   f0101111 <page_free>
f0101189:	83 c4 10             	add    $0x10,%esp
}
f010118c:	c9                   	leave  
f010118d:	c3                   	ret    

f010118e <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that manipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f010118e:	55                   	push   %ebp
f010118f:	89 e5                	mov    %esp,%ebp
f0101191:	57                   	push   %edi
f0101192:	56                   	push   %esi
f0101193:	53                   	push   %ebx
f0101194:	83 ec 0c             	sub    $0xc,%esp
f0101197:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in

	// we have virtual address
	// cprintf("[?] %x\n", va);

	if ((uint32_t)va == 0xeebfe000)
f010119a:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
f01011a0:	0f 85 c8 00 00 00    	jne    f010126e <pgdir_walk+0xe0>
		cprintf("Error hit\n");
f01011a6:	83 ec 0c             	sub    $0xc,%esp
f01011a9:	68 4b 70 10 f0       	push   $0xf010704b
f01011ae:	e8 de 27 00 00       	call   f0103991 <cprintf>
	uint32_t Page_Directory_Index = PDX(va);
	uint32_t Page_Table_Index = PTX(va);
	uint32_t Offset_In_PTE = PGOFF(va);

	// level 2 page table not exist
	if (pgdir[Page_Directory_Index] == 0) {
f01011b3:	8b 45 08             	mov    0x8(%ebp),%eax
f01011b6:	8d b8 e8 0e 00 00    	lea    0xee8(%eax),%edi
f01011bc:	83 c4 10             	add    $0x10,%esp
f01011bf:	83 b8 e8 0e 00 00 00 	cmpl   $0x0,0xee8(%eax)
f01011c6:	75 53                	jne    f010121b <pgdir_walk+0x8d>

		if ((uint32_t)va == 0xeebfe000)
			cprintf("Error hit2\n");
f01011c8:	83 ec 0c             	sub    $0xc,%esp
f01011cb:	68 56 70 10 f0       	push   $0xf0107056
f01011d0:	e8 bc 27 00 00       	call   f0103991 <cprintf>
f01011d5:	83 c4 10             	add    $0x10,%esp

	if ((uint32_t)va == 0xeebfe000)
		cprintf("Error hit\n");

	uint32_t Page_Directory_Index = PDX(va);
	uint32_t Page_Table_Index = PTX(va);
f01011d8:	be fe 03 00 00       	mov    $0x3fe,%esi
	if (pgdir[Page_Directory_Index] == 0) {

		if ((uint32_t)va == 0xeebfe000)
			cprintf("Error hit2\n");

		if (create == 0)
f01011dd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01011e1:	74 7d                	je     f0101260 <pgdir_walk+0xd2>
			return NULL;
		
		// allocate a new physical page to be a page table
		struct PageInfo *new_page = page_alloc(ALLOC_ZERO);
f01011e3:	83 ec 0c             	sub    $0xc,%esp
f01011e6:	6a 01                	push   $0x1
f01011e8:	e8 b3 fe ff ff       	call   f01010a0 <page_alloc>
		// cprintf("[??] %x\n", new_page);
		if (new_page == 0)	// page allocate fail
f01011ed:	83 c4 10             	add    $0x10,%esp
f01011f0:	85 c0                	test   %eax,%eax
f01011f2:	74 73                	je     f0101267 <pgdir_walk+0xd9>
		// set level 1 page table entry to this new level 2 page table
		// this new page is for level2 PT, so flags are:
		// 	PTE_P: this page is present
		//	PTE_U: user process can use this page
		//	PTE_W: this page can be edit
		pgdir[Page_Directory_Index] = page2pa(new_page) | PTE_P | PTE_U | PTE_W;
f01011f4:	89 c2                	mov    %eax,%edx
f01011f6:	2b 15 a8 9e 2a f0    	sub    0xf02a9ea8,%edx
f01011fc:	c1 fa 03             	sar    $0x3,%edx
f01011ff:	c1 e2 0c             	shl    $0xc,%edx
f0101202:	83 ca 07             	or     $0x7,%edx
f0101205:	89 17                	mov    %edx,(%edi)
		new_page->pp_ref = 1;
f0101207:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)

	}

	if ((uint32_t)va == 0xeebfe000)
f010120d:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
f0101213:	0f 85 9e 00 00 00    	jne    f01012b7 <pgdir_walk+0x129>
f0101219:	eb 05                	jmp    f0101220 <pgdir_walk+0x92>

	if ((uint32_t)va == 0xeebfe000)
		cprintf("Error hit\n");

	uint32_t Page_Directory_Index = PDX(va);
	uint32_t Page_Table_Index = PTX(va);
f010121b:	be fe 03 00 00       	mov    $0x3fe,%esi
		new_page->pp_ref = 1;

	}

	if ((uint32_t)va == 0xeebfe000)
		cprintf("Error hit3, 0x%x\n", pgdir[Page_Directory_Index]);
f0101220:	83 ec 08             	sub    $0x8,%esp
f0101223:	ff 37                	pushl  (%edi)
f0101225:	68 62 70 10 f0       	push   $0xf0107062
f010122a:	e8 62 27 00 00       	call   f0103991 <cprintf>
	// cprintf("[?] %x\n", KADDR(PTE_ADDR(pgdir[Page_Directory_Index])));
	
	// remember each entry is 4 byte long
	// so we need to convert type to pte_t * in order to add 4 on address each time
	// instead of add 1
	pte_t *p = (pte_t *) KADDR(PTE_ADDR(pgdir[Page_Directory_Index]));
f010122f:	8b 07                	mov    (%edi),%eax
f0101231:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101236:	89 c2                	mov    %eax,%edx
f0101238:	c1 ea 0c             	shr    $0xc,%edx
f010123b:	83 c4 10             	add    $0x10,%esp
f010123e:	3b 15 a0 9e 2a f0    	cmp    0xf02a9ea0,%edx
f0101244:	72 48                	jb     f010128e <pgdir_walk+0x100>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101246:	50                   	push   %eax
f0101247:	68 a4 69 10 f0       	push   $0xf01069a4
f010124c:	68 1c 02 00 00       	push   $0x21c
f0101251:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101256:	e8 e5 ed ff ff       	call   f0100040 <_panic>

	if ((uint32_t)va == 0xeebfe000)
		cprintf("Error hit4, 0x%x, 0x%x\n", (uint32_t)p, (uint32_t)*p);

	return &p[Page_Table_Index];
f010125b:	8d 04 b3             	lea    (%ebx,%esi,4),%eax
f010125e:	eb 70                	jmp    f01012d0 <pgdir_walk+0x142>

		if ((uint32_t)va == 0xeebfe000)
			cprintf("Error hit2\n");

		if (create == 0)
			return NULL;
f0101260:	b8 00 00 00 00       	mov    $0x0,%eax
f0101265:	eb 69                	jmp    f01012d0 <pgdir_walk+0x142>
		
		// allocate a new physical page to be a page table
		struct PageInfo *new_page = page_alloc(ALLOC_ZERO);
		// cprintf("[??] %x\n", new_page);
		if (new_page == 0)	// page allocate fail
			return NULL;
f0101267:	b8 00 00 00 00       	mov    $0x0,%eax
f010126c:	eb 62                	jmp    f01012d0 <pgdir_walk+0x142>

	if ((uint32_t)va == 0xeebfe000)
		cprintf("Error hit\n");

	uint32_t Page_Directory_Index = PDX(va);
	uint32_t Page_Table_Index = PTX(va);
f010126e:	89 de                	mov    %ebx,%esi
f0101270:	c1 ee 0c             	shr    $0xc,%esi
f0101273:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	uint32_t Offset_In_PTE = PGOFF(va);

	// level 2 page table not exist
	if (pgdir[Page_Directory_Index] == 0) {
f0101279:	89 d8                	mov    %ebx,%eax
f010127b:	c1 e8 16             	shr    $0x16,%eax
f010127e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101281:	8d 3c 81             	lea    (%ecx,%eax,4),%edi
f0101284:	83 3f 00             	cmpl   $0x0,(%edi)
f0101287:	75 2e                	jne    f01012b7 <pgdir_walk+0x129>
f0101289:	e9 4f ff ff ff       	jmp    f01011dd <pgdir_walk+0x4f>
	return (void *)(pa + KERNBASE);
f010128e:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
f0101294:	89 d3                	mov    %edx,%ebx
	// so we need to convert type to pte_t * in order to add 4 on address each time
	// instead of add 1
	pte_t *p = (pte_t *) KADDR(PTE_ADDR(pgdir[Page_Directory_Index]));

	if ((uint32_t)va == 0xeebfe000)
		cprintf("Error hit4, 0x%x, 0x%x\n", (uint32_t)p, (uint32_t)*p);
f0101296:	83 ec 04             	sub    $0x4,%esp
f0101299:	ff b0 00 00 00 f0    	pushl  -0x10000000(%eax)
f010129f:	52                   	push   %edx
f01012a0:	68 74 70 10 f0       	push   $0xf0107074
f01012a5:	e8 e7 26 00 00       	call   f0103991 <cprintf>
f01012aa:	83 c4 10             	add    $0x10,%esp
f01012ad:	eb ac                	jmp    f010125b <pgdir_walk+0xcd>
f01012af:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f01012b5:	eb a4                	jmp    f010125b <pgdir_walk+0xcd>
	// cprintf("[?] %x\n", KADDR(PTE_ADDR(pgdir[Page_Directory_Index])));
	
	// remember each entry is 4 byte long
	// so we need to convert type to pte_t * in order to add 4 on address each time
	// instead of add 1
	pte_t *p = (pte_t *) KADDR(PTE_ADDR(pgdir[Page_Directory_Index]));
f01012b7:	8b 07                	mov    (%edi),%eax
f01012b9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01012be:	89 c2                	mov    %eax,%edx
f01012c0:	c1 ea 0c             	shr    $0xc,%edx
f01012c3:	3b 15 a0 9e 2a f0    	cmp    0xf02a9ea0,%edx
f01012c9:	72 e4                	jb     f01012af <pgdir_walk+0x121>
f01012cb:	e9 76 ff ff ff       	jmp    f0101246 <pgdir_walk+0xb8>

	if ((uint32_t)va == 0xeebfe000)
		cprintf("Error hit4, 0x%x, 0x%x\n", (uint32_t)p, (uint32_t)*p);

	return &p[Page_Table_Index];
}
f01012d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012d3:	5b                   	pop    %ebx
f01012d4:	5e                   	pop    %esi
f01012d5:	5f                   	pop    %edi
f01012d6:	5d                   	pop    %ebp
f01012d7:	c3                   	ret    

f01012d8 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f01012d8:	55                   	push   %ebp
f01012d9:	89 e5                	mov    %esp,%ebp
f01012db:	57                   	push   %edi
f01012dc:	56                   	push   %esi
f01012dd:	53                   	push   %ebx
f01012de:	83 ec 20             	sub    $0x20,%esp
f01012e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01012e4:	89 d7                	mov    %edx,%edi
f01012e6:	89 cb                	mov    %ecx,%ebx
	
	cprintf("[boot_map_region] 0x%x, len 0x%x\n", va, size);
f01012e8:	51                   	push   %ecx
f01012e9:	52                   	push   %edx
f01012ea:	68 20 74 10 f0       	push   $0xf0107420
f01012ef:	e8 9d 26 00 00       	call   f0103991 <cprintf>
	
	// Fill this function in	
	if (size % PGSIZE != 0)
f01012f4:	83 c4 10             	add    $0x10,%esp
f01012f7:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f01012fd:	74 17                	je     f0101316 <boot_map_region+0x3e>
		panic("boot_map_region: size is not a multiple of PGSIZE\n");
f01012ff:	83 ec 04             	sub    $0x4,%esp
f0101302:	68 44 74 10 f0       	push   $0xf0107444
f0101307:	68 37 02 00 00       	push   $0x237
f010130c:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101311:	e8 2a ed ff ff       	call   f0100040 <_panic>
	
	if (va % PGSIZE != 0 || pa % PGSIZE != 0)
f0101316:	f7 c7 ff 0f 00 00    	test   $0xfff,%edi
f010131c:	75 24                	jne    f0101342 <boot_map_region+0x6a>
f010131e:	f7 45 08 ff 0f 00 00 	testl  $0xfff,0x8(%ebp)
f0101325:	75 1b                	jne    f0101342 <boot_map_region+0x6a>
f0101327:	c1 eb 0c             	shr    $0xc,%ebx
f010132a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
		panic("boot_map_region: va or pa is not page-aligned\n");


	// set all pages related
	for (int i=0; i<size/PGSIZE; i++) {
f010132d:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101330:	be 00 00 00 00       	mov    $0x0,%esi

		// find the real PTE for va
		// create on walk, if not present
		pte_t* pte = pgdir_walk(pgdir, (void *)va, 1);	
f0101335:	29 df                	sub    %ebx,%edi

		// set the real PTE to pa, zero out least 12 bits
		*pte = PTE_ADDR(pa);
		
		// set flags
		*pte |= (perm | PTE_P);
f0101337:	8b 45 0c             	mov    0xc(%ebp),%eax
f010133a:	83 c8 01             	or     $0x1,%eax
f010133d:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0101340:	eb 5c                	jmp    f010139e <boot_map_region+0xc6>
	// Fill this function in	
	if (size % PGSIZE != 0)
		panic("boot_map_region: size is not a multiple of PGSIZE\n");
	
	if (va % PGSIZE != 0 || pa % PGSIZE != 0)
		panic("boot_map_region: va or pa is not page-aligned\n");
f0101342:	83 ec 04             	sub    $0x4,%esp
f0101345:	68 78 74 10 f0       	push   $0xf0107478
f010134a:	68 3a 02 00 00       	push   $0x23a
f010134f:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101354:	e8 e7 ec ff ff       	call   f0100040 <_panic>
	// set all pages related
	for (int i=0; i<size/PGSIZE; i++) {

		// find the real PTE for va
		// create on walk, if not present
		pte_t* pte = pgdir_walk(pgdir, (void *)va, 1);	
f0101359:	83 ec 04             	sub    $0x4,%esp
f010135c:	6a 01                	push   $0x1
f010135e:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f0101361:	50                   	push   %eax
f0101362:	ff 75 e0             	pushl  -0x20(%ebp)
f0101365:	e8 24 fe ff ff       	call   f010118e <pgdir_walk>

		if (pte == 0)
f010136a:	83 c4 10             	add    $0x10,%esp
f010136d:	85 c0                	test   %eax,%eax
f010136f:	75 17                	jne    f0101388 <boot_map_region+0xb0>
			panic("boot_map_region: pgdir_walk return NULL\n");
f0101371:	83 ec 04             	sub    $0x4,%esp
f0101374:	68 a8 74 10 f0       	push   $0xf01074a8
f0101379:	68 45 02 00 00       	push   $0x245
f010137e:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101383:	e8 b8 ec ff ff       	call   f0100040 <_panic>

		// set the real PTE to pa, zero out least 12 bits
		*pte = PTE_ADDR(pa);
		
		// set flags
		*pte |= (perm | PTE_P);
f0101388:	89 da                	mov    %ebx,%edx
f010138a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101390:	0b 55 dc             	or     -0x24(%ebp),%edx
f0101393:	89 10                	mov    %edx,(%eax)

		// deal with next page
		va += PGSIZE;
		pa += PGSIZE;
f0101395:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	if (va % PGSIZE != 0 || pa % PGSIZE != 0)
		panic("boot_map_region: va or pa is not page-aligned\n");


	// set all pages related
	for (int i=0; i<size/PGSIZE; i++) {
f010139b:	83 c6 01             	add    $0x1,%esi
f010139e:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f01013a1:	75 b6                	jne    f0101359 <boot_map_region+0x81>
		va += PGSIZE;
		pa += PGSIZE;

	}

}
f01013a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01013a6:	5b                   	pop    %ebx
f01013a7:	5e                   	pop    %esi
f01013a8:	5f                   	pop    %edi
f01013a9:	5d                   	pop    %ebp
f01013aa:	c3                   	ret    

f01013ab <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01013ab:	55                   	push   %ebp
f01013ac:	89 e5                	mov    %esp,%ebp
f01013ae:	53                   	push   %ebx
f01013af:	83 ec 08             	sub    $0x8,%esp
f01013b2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in

	// do a page table walk to find real PTE
	pte_t * pte = pgdir_walk(pgdir, va, 0);
f01013b5:	6a 00                	push   $0x0
f01013b7:	ff 75 0c             	pushl  0xc(%ebp)
f01013ba:	ff 75 08             	pushl  0x8(%ebp)
f01013bd:	e8 cc fd ff ff       	call   f010118e <pgdir_walk>

	// cprintf("[?] In page_lookup\n");
	// cprintf("[?] %x\n", pte);

	// if not present, return NULL
	if (pte == 0 || *pte == 0)
f01013c2:	83 c4 10             	add    $0x10,%esp
f01013c5:	85 c0                	test   %eax,%eax
f01013c7:	74 37                	je     f0101400 <page_lookup+0x55>
f01013c9:	83 38 00             	cmpl   $0x0,(%eax)
f01013cc:	74 39                	je     f0101407 <page_lookup+0x5c>
		return NULL;
	
	// store pte
	if (pte_store != 0)
f01013ce:	85 db                	test   %ebx,%ebx
f01013d0:	74 02                	je     f01013d4 <page_lookup+0x29>
		*pte_store = pte;
f01013d2:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01013d4:	8b 00                	mov    (%eax),%eax
f01013d6:	c1 e8 0c             	shr    $0xc,%eax
f01013d9:	3b 05 a0 9e 2a f0    	cmp    0xf02a9ea0,%eax
f01013df:	72 14                	jb     f01013f5 <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f01013e1:	83 ec 04             	sub    $0x4,%esp
f01013e4:	68 d4 74 10 f0       	push   $0xf01074d4
f01013e9:	6a 51                	push   $0x51
f01013eb:	68 6b 6f 10 f0       	push   $0xf0106f6b
f01013f0:	e8 4b ec ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f01013f5:	8b 15 a8 9e 2a f0    	mov    0xf02a9ea8,%edx
f01013fb:	8d 04 c2             	lea    (%edx,%eax,8),%eax

	return pa2page(PTE_ADDR(*pte)) ;
f01013fe:	eb 0c                	jmp    f010140c <page_lookup+0x61>
	// cprintf("[?] In page_lookup\n");
	// cprintf("[?] %x\n", pte);

	// if not present, return NULL
	if (pte == 0 || *pte == 0)
		return NULL;
f0101400:	b8 00 00 00 00       	mov    $0x0,%eax
f0101405:	eb 05                	jmp    f010140c <page_lookup+0x61>
f0101407:	b8 00 00 00 00       	mov    $0x0,%eax
	// store pte
	if (pte_store != 0)
		*pte_store = pte;

	return pa2page(PTE_ADDR(*pte)) ;
}
f010140c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010140f:	c9                   	leave  
f0101410:	c3                   	ret    

f0101411 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101411:	55                   	push   %ebp
f0101412:	89 e5                	mov    %esp,%ebp
f0101414:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f0101417:	e8 72 49 00 00       	call   f0105d8e <cpunum>
f010141c:	6b c0 74             	imul   $0x74,%eax,%eax
f010141f:	83 b8 28 a0 2a f0 00 	cmpl   $0x0,-0xfd55fd8(%eax)
f0101426:	74 16                	je     f010143e <tlb_invalidate+0x2d>
f0101428:	e8 61 49 00 00       	call   f0105d8e <cpunum>
f010142d:	6b c0 74             	imul   $0x74,%eax,%eax
f0101430:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
f0101436:	8b 55 08             	mov    0x8(%ebp),%edx
f0101439:	39 50 60             	cmp    %edx,0x60(%eax)
f010143c:	75 06                	jne    f0101444 <tlb_invalidate+0x33>
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010143e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101441:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f0101444:	c9                   	leave  
f0101445:	c3                   	ret    

f0101446 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101446:	55                   	push   %ebp
f0101447:	89 e5                	mov    %esp,%ebp
f0101449:	56                   	push   %esi
f010144a:	53                   	push   %ebx
f010144b:	83 ec 14             	sub    $0x14,%esp
f010144e:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101451:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in

	// pte_t *tmp;
	pte_t *pte_store = NULL;
f0101454:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	struct PageInfo * pp = page_lookup(pgdir, va, &pte_store);
f010145b:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010145e:	50                   	push   %eax
f010145f:	56                   	push   %esi
f0101460:	53                   	push   %ebx
f0101461:	e8 45 ff ff ff       	call   f01013ab <page_lookup>

	// if not present, silently return
	if (pp == NULL)
f0101466:	83 c4 10             	add    $0x10,%esp
f0101469:	85 c0                	test   %eax,%eax
f010146b:	74 1f                	je     f010148c <page_remove+0x46>
		return;

	// decrement ref count, and if reaches 0, free it
	page_decref(pp);
f010146d:	83 ec 0c             	sub    $0xc,%esp
f0101470:	50                   	push   %eax
f0101471:	e8 f1 fc ff ff       	call   f0101167 <page_decref>

	// null the real PTE pointer 
	*pte_store = 0;
f0101476:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101479:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	// cprintf("[?] In page_remove\n");
	// cprintf("[?] *pte_store:%x, **pte_store:%x\n", *pte_store, **pte_store);

	// tlb invalidate
	tlb_invalidate(pgdir, va);
f010147f:	83 c4 08             	add    $0x8,%esp
f0101482:	56                   	push   %esi
f0101483:	53                   	push   %ebx
f0101484:	e8 88 ff ff ff       	call   f0101411 <tlb_invalidate>
f0101489:	83 c4 10             	add    $0x10,%esp

}
f010148c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010148f:	5b                   	pop    %ebx
f0101490:	5e                   	pop    %esi
f0101491:	5d                   	pop    %ebp
f0101492:	c3                   	ret    

f0101493 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101493:	55                   	push   %ebp
f0101494:	89 e5                	mov    %esp,%ebp
f0101496:	57                   	push   %edi
f0101497:	56                   	push   %esi
f0101498:	53                   	push   %ebx
f0101499:	83 ec 10             	sub    $0x10,%esp
f010149c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010149f:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in

	// find the real PTE for va
	// create on walk, if not present
	pte_t* pte = pgdir_walk(pgdir, va, 1);	
f01014a2:	6a 01                	push   $0x1
f01014a4:	57                   	push   %edi
f01014a5:	ff 75 08             	pushl  0x8(%ebp)
f01014a8:	e8 e1 fc ff ff       	call   f010118e <pgdir_walk>

	if (pte == 0)
f01014ad:	83 c4 10             	add    $0x10,%esp
f01014b0:	85 c0                	test   %eax,%eax
f01014b2:	74 59                	je     f010150d <page_insert+0x7a>
f01014b4:	89 c6                	mov    %eax,%esi
		return -E_NO_MEM;

	// already have a page
	// remove it and invalidate tlb
	if (*pte != 0) {
f01014b6:	8b 00                	mov    (%eax),%eax
f01014b8:	85 c0                	test   %eax,%eax
f01014ba:	74 2d                	je     f01014e9 <page_insert+0x56>
		// corner case
		if (page2pa(pp) == PTE_ADDR(*pte))
f01014bc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01014c1:	89 da                	mov    %ebx,%edx
f01014c3:	2b 15 a8 9e 2a f0    	sub    0xf02a9ea8,%edx
f01014c9:	c1 fa 03             	sar    $0x3,%edx
f01014cc:	c1 e2 0c             	shl    $0xc,%edx
f01014cf:	39 d0                	cmp    %edx,%eax
f01014d1:	75 07                	jne    f01014da <page_insert+0x47>
			pp->pp_ref--;	// keep pp_ref consistent, in the meantime change perm potentially.
f01014d3:	66 83 6b 04 01       	subw   $0x1,0x4(%ebx)
f01014d8:	eb 0f                	jmp    f01014e9 <page_insert+0x56>
		else
			page_remove(pgdir, va);
f01014da:	83 ec 08             	sub    $0x8,%esp
f01014dd:	57                   	push   %edi
f01014de:	ff 75 08             	pushl  0x8(%ebp)
f01014e1:	e8 60 ff ff ff       	call   f0101446 <page_remove>
f01014e6:	83 c4 10             	add    $0x10,%esp

	// set the real PTE to pa, zero out least 12 bits
	*pte = PTE_ADDR(page2pa(pp));
	
	// set flags
	*pte |= (perm | PTE_P);
f01014e9:	89 d8                	mov    %ebx,%eax
f01014eb:	2b 05 a8 9e 2a f0    	sub    0xf02a9ea8,%eax
f01014f1:	c1 f8 03             	sar    $0x3,%eax
f01014f4:	c1 e0 0c             	shl    $0xc,%eax
f01014f7:	8b 55 14             	mov    0x14(%ebp),%edx
f01014fa:	83 ca 01             	or     $0x1,%edx
f01014fd:	09 d0                	or     %edx,%eax
f01014ff:	89 06                	mov    %eax,(%esi)

	// increment ref cnt
	pp->pp_ref++;
f0101501:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)

	return 0;
f0101506:	b8 00 00 00 00       	mov    $0x0,%eax
f010150b:	eb 05                	jmp    f0101512 <page_insert+0x7f>
	// find the real PTE for va
	// create on walk, if not present
	pte_t* pte = pgdir_walk(pgdir, va, 1);	

	if (pte == 0)
		return -E_NO_MEM;
f010150d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax

	// increment ref cnt
	pp->pp_ref++;

	return 0;
}
f0101512:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101515:	5b                   	pop    %ebx
f0101516:	5e                   	pop    %esi
f0101517:	5f                   	pop    %edi
f0101518:	5d                   	pop    %ebp
f0101519:	c3                   	ret    

f010151a <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f010151a:	55                   	push   %ebp
f010151b:	89 e5                	mov    %esp,%ebp
f010151d:	56                   	push   %esi
f010151e:	53                   	push   %ebx
f010151f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	// panic("mmio_map_region not implemented");

	uintptr_t mmio = base;
f0101522:	8b 35 00 23 12 f0    	mov    0xf0122300,%esi

	if (ROUNDUP(mmio + size, PGSIZE) >= MMIOLIM)
f0101528:	8d 84 0e ff 0f 00 00 	lea    0xfff(%esi,%ecx,1),%eax
f010152f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101534:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0101539:	76 17                	jbe    f0101552 <mmio_map_region+0x38>
		panic("mmio_map_region: mmio out of memory");
f010153b:	83 ec 04             	sub    $0x4,%esp
f010153e:	68 f4 74 10 f0       	push   $0xf01074f4
f0101543:	68 0c 03 00 00       	push   $0x30c
f0101548:	68 5f 6f 10 f0       	push   $0xf0106f5f
f010154d:	e8 ee ea ff ff       	call   f0100040 <_panic>
		
	boot_map_region(kern_pgdir, mmio, ROUNDUP(size, PGSIZE), pa, PTE_PCD|PTE_PWT|PTE_W);
f0101552:	8d 99 ff 0f 00 00    	lea    0xfff(%ecx),%ebx
f0101558:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f010155e:	83 ec 08             	sub    $0x8,%esp
f0101561:	6a 1a                	push   $0x1a
f0101563:	ff 75 08             	pushl  0x8(%ebp)
f0101566:	89 d9                	mov    %ebx,%ecx
f0101568:	89 f2                	mov    %esi,%edx
f010156a:	a1 a4 9e 2a f0       	mov    0xf02a9ea4,%eax
f010156f:	e8 64 fd ff ff       	call   f01012d8 <boot_map_region>

	base += ROUNDUP(size, PGSIZE);
f0101574:	01 1d 00 23 12 f0    	add    %ebx,0xf0122300

	return (void *)mmio;
}
f010157a:	89 f0                	mov    %esi,%eax
f010157c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010157f:	5b                   	pop    %ebx
f0101580:	5e                   	pop    %esi
f0101581:	5d                   	pop    %ebp
f0101582:	c3                   	ret    

f0101583 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101583:	55                   	push   %ebp
f0101584:	89 e5                	mov    %esp,%ebp
f0101586:	57                   	push   %edi
f0101587:	56                   	push   %esi
f0101588:	53                   	push   %ebx
f0101589:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f010158c:	b8 15 00 00 00       	mov    $0x15,%eax
f0101591:	e8 72 f5 ff ff       	call   f0100b08 <nvram_read>
f0101596:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0101598:	b8 17 00 00 00       	mov    $0x17,%eax
f010159d:	e8 66 f5 ff ff       	call   f0100b08 <nvram_read>
f01015a2:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f01015a4:	b8 34 00 00 00       	mov    $0x34,%eax
f01015a9:	e8 5a f5 ff ff       	call   f0100b08 <nvram_read>
f01015ae:	c1 e0 06             	shl    $0x6,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f01015b1:	85 c0                	test   %eax,%eax
f01015b3:	74 07                	je     f01015bc <mem_init+0x39>
		totalmem = 16 * 1024 + ext16mem;
f01015b5:	05 00 40 00 00       	add    $0x4000,%eax
f01015ba:	eb 0b                	jmp    f01015c7 <mem_init+0x44>
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f01015bc:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f01015c2:	85 f6                	test   %esi,%esi
f01015c4:	0f 44 c3             	cmove  %ebx,%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f01015c7:	89 c2                	mov    %eax,%edx
f01015c9:	c1 ea 02             	shr    $0x2,%edx
f01015cc:	89 15 a0 9e 2a f0    	mov    %edx,0xf02a9ea0
	npages_basemem = basemem / (PGSIZE / 1024);
f01015d2:	89 da                	mov    %ebx,%edx
f01015d4:	c1 ea 02             	shr    $0x2,%edx
f01015d7:	89 15 44 92 2a f0    	mov    %edx,0xf02a9244

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01015dd:	89 c2                	mov    %eax,%edx
f01015df:	29 da                	sub    %ebx,%edx
f01015e1:	52                   	push   %edx
f01015e2:	53                   	push   %ebx
f01015e3:	50                   	push   %eax
f01015e4:	68 18 75 10 f0       	push   $0xf0107518
f01015e9:	e8 a3 23 00 00       	call   f0103991 <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01015ee:	b8 00 10 00 00       	mov    $0x1000,%eax
f01015f3:	e8 39 f5 ff ff       	call   f0100b31 <boot_alloc>
f01015f8:	a3 a4 9e 2a f0       	mov    %eax,0xf02a9ea4
	memset(kern_pgdir, 0, PGSIZE);
f01015fd:	83 c4 0c             	add    $0xc,%esp
f0101600:	68 00 10 00 00       	push   $0x1000
f0101605:	6a 00                	push   $0x0
f0101607:	50                   	push   %eax
f0101608:	e8 5e 41 00 00       	call   f010576b <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010160d:	a1 a4 9e 2a f0       	mov    0xf02a9ea4,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101612:	83 c4 10             	add    $0x10,%esp
f0101615:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010161a:	77 15                	ja     f0101631 <mem_init+0xae>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010161c:	50                   	push   %eax
f010161d:	68 c8 69 10 f0       	push   $0xf01069c8
f0101622:	68 9b 00 00 00       	push   $0x9b
f0101627:	68 5f 6f 10 f0       	push   $0xf0106f5f
f010162c:	e8 0f ea ff ff       	call   f0100040 <_panic>
f0101631:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101637:	83 ca 05             	or     $0x5,%edx
f010163a:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:

	n = npages * sizeof(struct PageInfo);
f0101640:	a1 a0 9e 2a f0       	mov    0xf02a9ea0,%eax
f0101645:	8d 1c c5 00 00 00 00 	lea    0x0(,%eax,8),%ebx
	pages = (struct PageInfo *) boot_alloc(n);
f010164c:	89 d8                	mov    %ebx,%eax
f010164e:	e8 de f4 ff ff       	call   f0100b31 <boot_alloc>
f0101653:	a3 a8 9e 2a f0       	mov    %eax,0xf02a9ea8
	memset(pages, 0, n);
f0101658:	83 ec 04             	sub    $0x4,%esp
f010165b:	53                   	push   %ebx
f010165c:	6a 00                	push   $0x0
f010165e:	50                   	push   %eax
f010165f:	e8 07 41 00 00       	call   f010576b <memset>
	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.

	n = NENV * sizeof(struct Env);
	envs = (struct Env *) boot_alloc(n);
f0101664:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101669:	e8 c3 f4 ff ff       	call   f0100b31 <boot_alloc>
f010166e:	a3 48 92 2a f0       	mov    %eax,0xf02a9248
	memset(envs, 0, n);
f0101673:	83 c4 0c             	add    $0xc,%esp
f0101676:	68 00 f0 01 00       	push   $0x1f000
f010167b:	6a 00                	push   $0x0
f010167d:	50                   	push   %eax
f010167e:	e8 e8 40 00 00       	call   f010576b <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101683:	e8 62 f8 ff ff       	call   f0100eea <page_init>

	check_page_free_list(1);
f0101688:	b8 01 00 00 00       	mov    $0x1,%eax
f010168d:	e8 56 f5 ff ff       	call   f0100be8 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101692:	83 c4 10             	add    $0x10,%esp
f0101695:	83 3d a8 9e 2a f0 00 	cmpl   $0x0,0xf02a9ea8
f010169c:	75 17                	jne    f01016b5 <mem_init+0x132>
		panic("'pages' is a null pointer!");
f010169e:	83 ec 04             	sub    $0x4,%esp
f01016a1:	68 8c 70 10 f0       	push   $0xf010708c
f01016a6:	68 b2 03 00 00       	push   $0x3b2
f01016ab:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01016b0:	e8 8b e9 ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01016b5:	a1 40 92 2a f0       	mov    0xf02a9240,%eax
f01016ba:	bb 00 00 00 00       	mov    $0x0,%ebx
f01016bf:	eb 05                	jmp    f01016c6 <mem_init+0x143>
		++nfree;
f01016c1:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01016c4:	8b 00                	mov    (%eax),%eax
f01016c6:	85 c0                	test   %eax,%eax
f01016c8:	75 f7                	jne    f01016c1 <mem_init+0x13e>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01016ca:	83 ec 0c             	sub    $0xc,%esp
f01016cd:	6a 00                	push   $0x0
f01016cf:	e8 cc f9 ff ff       	call   f01010a0 <page_alloc>
f01016d4:	89 c7                	mov    %eax,%edi
f01016d6:	83 c4 10             	add    $0x10,%esp
f01016d9:	85 c0                	test   %eax,%eax
f01016db:	75 19                	jne    f01016f6 <mem_init+0x173>
f01016dd:	68 a7 70 10 f0       	push   $0xf01070a7
f01016e2:	68 85 6f 10 f0       	push   $0xf0106f85
f01016e7:	68 ba 03 00 00       	push   $0x3ba
f01016ec:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01016f1:	e8 4a e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01016f6:	83 ec 0c             	sub    $0xc,%esp
f01016f9:	6a 00                	push   $0x0
f01016fb:	e8 a0 f9 ff ff       	call   f01010a0 <page_alloc>
f0101700:	89 c6                	mov    %eax,%esi
f0101702:	83 c4 10             	add    $0x10,%esp
f0101705:	85 c0                	test   %eax,%eax
f0101707:	75 19                	jne    f0101722 <mem_init+0x19f>
f0101709:	68 bd 70 10 f0       	push   $0xf01070bd
f010170e:	68 85 6f 10 f0       	push   $0xf0106f85
f0101713:	68 bb 03 00 00       	push   $0x3bb
f0101718:	68 5f 6f 10 f0       	push   $0xf0106f5f
f010171d:	e8 1e e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101722:	83 ec 0c             	sub    $0xc,%esp
f0101725:	6a 00                	push   $0x0
f0101727:	e8 74 f9 ff ff       	call   f01010a0 <page_alloc>
f010172c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010172f:	83 c4 10             	add    $0x10,%esp
f0101732:	85 c0                	test   %eax,%eax
f0101734:	75 19                	jne    f010174f <mem_init+0x1cc>
f0101736:	68 d3 70 10 f0       	push   $0xf01070d3
f010173b:	68 85 6f 10 f0       	push   $0xf0106f85
f0101740:	68 bc 03 00 00       	push   $0x3bc
f0101745:	68 5f 6f 10 f0       	push   $0xf0106f5f
f010174a:	e8 f1 e8 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010174f:	39 f7                	cmp    %esi,%edi
f0101751:	75 19                	jne    f010176c <mem_init+0x1e9>
f0101753:	68 e9 70 10 f0       	push   $0xf01070e9
f0101758:	68 85 6f 10 f0       	push   $0xf0106f85
f010175d:	68 bf 03 00 00       	push   $0x3bf
f0101762:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101767:	e8 d4 e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010176c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010176f:	39 c6                	cmp    %eax,%esi
f0101771:	74 04                	je     f0101777 <mem_init+0x1f4>
f0101773:	39 c7                	cmp    %eax,%edi
f0101775:	75 19                	jne    f0101790 <mem_init+0x20d>
f0101777:	68 54 75 10 f0       	push   $0xf0107554
f010177c:	68 85 6f 10 f0       	push   $0xf0106f85
f0101781:	68 c0 03 00 00       	push   $0x3c0
f0101786:	68 5f 6f 10 f0       	push   $0xf0106f5f
f010178b:	e8 b0 e8 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101790:	8b 0d a8 9e 2a f0    	mov    0xf02a9ea8,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101796:	8b 15 a0 9e 2a f0    	mov    0xf02a9ea0,%edx
f010179c:	c1 e2 0c             	shl    $0xc,%edx
f010179f:	89 f8                	mov    %edi,%eax
f01017a1:	29 c8                	sub    %ecx,%eax
f01017a3:	c1 f8 03             	sar    $0x3,%eax
f01017a6:	c1 e0 0c             	shl    $0xc,%eax
f01017a9:	39 d0                	cmp    %edx,%eax
f01017ab:	72 19                	jb     f01017c6 <mem_init+0x243>
f01017ad:	68 fb 70 10 f0       	push   $0xf01070fb
f01017b2:	68 85 6f 10 f0       	push   $0xf0106f85
f01017b7:	68 c1 03 00 00       	push   $0x3c1
f01017bc:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01017c1:	e8 7a e8 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01017c6:	89 f0                	mov    %esi,%eax
f01017c8:	29 c8                	sub    %ecx,%eax
f01017ca:	c1 f8 03             	sar    $0x3,%eax
f01017cd:	c1 e0 0c             	shl    $0xc,%eax
f01017d0:	39 c2                	cmp    %eax,%edx
f01017d2:	77 19                	ja     f01017ed <mem_init+0x26a>
f01017d4:	68 18 71 10 f0       	push   $0xf0107118
f01017d9:	68 85 6f 10 f0       	push   $0xf0106f85
f01017de:	68 c2 03 00 00       	push   $0x3c2
f01017e3:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01017e8:	e8 53 e8 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01017ed:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01017f0:	29 c8                	sub    %ecx,%eax
f01017f2:	c1 f8 03             	sar    $0x3,%eax
f01017f5:	c1 e0 0c             	shl    $0xc,%eax
f01017f8:	39 c2                	cmp    %eax,%edx
f01017fa:	77 19                	ja     f0101815 <mem_init+0x292>
f01017fc:	68 35 71 10 f0       	push   $0xf0107135
f0101801:	68 85 6f 10 f0       	push   $0xf0106f85
f0101806:	68 c3 03 00 00       	push   $0x3c3
f010180b:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101810:	e8 2b e8 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101815:	a1 40 92 2a f0       	mov    0xf02a9240,%eax
f010181a:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010181d:	c7 05 40 92 2a f0 00 	movl   $0x0,0xf02a9240
f0101824:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101827:	83 ec 0c             	sub    $0xc,%esp
f010182a:	6a 00                	push   $0x0
f010182c:	e8 6f f8 ff ff       	call   f01010a0 <page_alloc>
f0101831:	83 c4 10             	add    $0x10,%esp
f0101834:	85 c0                	test   %eax,%eax
f0101836:	74 19                	je     f0101851 <mem_init+0x2ce>
f0101838:	68 52 71 10 f0       	push   $0xf0107152
f010183d:	68 85 6f 10 f0       	push   $0xf0106f85
f0101842:	68 ca 03 00 00       	push   $0x3ca
f0101847:	68 5f 6f 10 f0       	push   $0xf0106f5f
f010184c:	e8 ef e7 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101851:	83 ec 0c             	sub    $0xc,%esp
f0101854:	57                   	push   %edi
f0101855:	e8 b7 f8 ff ff       	call   f0101111 <page_free>
	page_free(pp1);
f010185a:	89 34 24             	mov    %esi,(%esp)
f010185d:	e8 af f8 ff ff       	call   f0101111 <page_free>
	page_free(pp2);
f0101862:	83 c4 04             	add    $0x4,%esp
f0101865:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101868:	e8 a4 f8 ff ff       	call   f0101111 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010186d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101874:	e8 27 f8 ff ff       	call   f01010a0 <page_alloc>
f0101879:	89 c6                	mov    %eax,%esi
f010187b:	83 c4 10             	add    $0x10,%esp
f010187e:	85 c0                	test   %eax,%eax
f0101880:	75 19                	jne    f010189b <mem_init+0x318>
f0101882:	68 a7 70 10 f0       	push   $0xf01070a7
f0101887:	68 85 6f 10 f0       	push   $0xf0106f85
f010188c:	68 d1 03 00 00       	push   $0x3d1
f0101891:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101896:	e8 a5 e7 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010189b:	83 ec 0c             	sub    $0xc,%esp
f010189e:	6a 00                	push   $0x0
f01018a0:	e8 fb f7 ff ff       	call   f01010a0 <page_alloc>
f01018a5:	89 c7                	mov    %eax,%edi
f01018a7:	83 c4 10             	add    $0x10,%esp
f01018aa:	85 c0                	test   %eax,%eax
f01018ac:	75 19                	jne    f01018c7 <mem_init+0x344>
f01018ae:	68 bd 70 10 f0       	push   $0xf01070bd
f01018b3:	68 85 6f 10 f0       	push   $0xf0106f85
f01018b8:	68 d2 03 00 00       	push   $0x3d2
f01018bd:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01018c2:	e8 79 e7 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01018c7:	83 ec 0c             	sub    $0xc,%esp
f01018ca:	6a 00                	push   $0x0
f01018cc:	e8 cf f7 ff ff       	call   f01010a0 <page_alloc>
f01018d1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01018d4:	83 c4 10             	add    $0x10,%esp
f01018d7:	85 c0                	test   %eax,%eax
f01018d9:	75 19                	jne    f01018f4 <mem_init+0x371>
f01018db:	68 d3 70 10 f0       	push   $0xf01070d3
f01018e0:	68 85 6f 10 f0       	push   $0xf0106f85
f01018e5:	68 d3 03 00 00       	push   $0x3d3
f01018ea:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01018ef:	e8 4c e7 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01018f4:	39 fe                	cmp    %edi,%esi
f01018f6:	75 19                	jne    f0101911 <mem_init+0x38e>
f01018f8:	68 e9 70 10 f0       	push   $0xf01070e9
f01018fd:	68 85 6f 10 f0       	push   $0xf0106f85
f0101902:	68 d5 03 00 00       	push   $0x3d5
f0101907:	68 5f 6f 10 f0       	push   $0xf0106f5f
f010190c:	e8 2f e7 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101911:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101914:	39 c7                	cmp    %eax,%edi
f0101916:	74 04                	je     f010191c <mem_init+0x399>
f0101918:	39 c6                	cmp    %eax,%esi
f010191a:	75 19                	jne    f0101935 <mem_init+0x3b2>
f010191c:	68 54 75 10 f0       	push   $0xf0107554
f0101921:	68 85 6f 10 f0       	push   $0xf0106f85
f0101926:	68 d6 03 00 00       	push   $0x3d6
f010192b:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101930:	e8 0b e7 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101935:	83 ec 0c             	sub    $0xc,%esp
f0101938:	6a 00                	push   $0x0
f010193a:	e8 61 f7 ff ff       	call   f01010a0 <page_alloc>
f010193f:	83 c4 10             	add    $0x10,%esp
f0101942:	85 c0                	test   %eax,%eax
f0101944:	74 19                	je     f010195f <mem_init+0x3dc>
f0101946:	68 52 71 10 f0       	push   $0xf0107152
f010194b:	68 85 6f 10 f0       	push   $0xf0106f85
f0101950:	68 d7 03 00 00       	push   $0x3d7
f0101955:	68 5f 6f 10 f0       	push   $0xf0106f5f
f010195a:	e8 e1 e6 ff ff       	call   f0100040 <_panic>
f010195f:	89 f0                	mov    %esi,%eax
f0101961:	2b 05 a8 9e 2a f0    	sub    0xf02a9ea8,%eax
f0101967:	c1 f8 03             	sar    $0x3,%eax
f010196a:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010196d:	89 c2                	mov    %eax,%edx
f010196f:	c1 ea 0c             	shr    $0xc,%edx
f0101972:	3b 15 a0 9e 2a f0    	cmp    0xf02a9ea0,%edx
f0101978:	72 12                	jb     f010198c <mem_init+0x409>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010197a:	50                   	push   %eax
f010197b:	68 a4 69 10 f0       	push   $0xf01069a4
f0101980:	6a 58                	push   $0x58
f0101982:	68 6b 6f 10 f0       	push   $0xf0106f6b
f0101987:	e8 b4 e6 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f010198c:	83 ec 04             	sub    $0x4,%esp
f010198f:	68 00 10 00 00       	push   $0x1000
f0101994:	6a 01                	push   $0x1
f0101996:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010199b:	50                   	push   %eax
f010199c:	e8 ca 3d 00 00       	call   f010576b <memset>
	page_free(pp0);
f01019a1:	89 34 24             	mov    %esi,(%esp)
f01019a4:	e8 68 f7 ff ff       	call   f0101111 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01019a9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01019b0:	e8 eb f6 ff ff       	call   f01010a0 <page_alloc>
f01019b5:	83 c4 10             	add    $0x10,%esp
f01019b8:	85 c0                	test   %eax,%eax
f01019ba:	75 19                	jne    f01019d5 <mem_init+0x452>
f01019bc:	68 61 71 10 f0       	push   $0xf0107161
f01019c1:	68 85 6f 10 f0       	push   $0xf0106f85
f01019c6:	68 dc 03 00 00       	push   $0x3dc
f01019cb:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01019d0:	e8 6b e6 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f01019d5:	39 c6                	cmp    %eax,%esi
f01019d7:	74 19                	je     f01019f2 <mem_init+0x46f>
f01019d9:	68 7f 71 10 f0       	push   $0xf010717f
f01019de:	68 85 6f 10 f0       	push   $0xf0106f85
f01019e3:	68 dd 03 00 00       	push   $0x3dd
f01019e8:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01019ed:	e8 4e e6 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01019f2:	89 f0                	mov    %esi,%eax
f01019f4:	2b 05 a8 9e 2a f0    	sub    0xf02a9ea8,%eax
f01019fa:	c1 f8 03             	sar    $0x3,%eax
f01019fd:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101a00:	89 c2                	mov    %eax,%edx
f0101a02:	c1 ea 0c             	shr    $0xc,%edx
f0101a05:	3b 15 a0 9e 2a f0    	cmp    0xf02a9ea0,%edx
f0101a0b:	72 12                	jb     f0101a1f <mem_init+0x49c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101a0d:	50                   	push   %eax
f0101a0e:	68 a4 69 10 f0       	push   $0xf01069a4
f0101a13:	6a 58                	push   $0x58
f0101a15:	68 6b 6f 10 f0       	push   $0xf0106f6b
f0101a1a:	e8 21 e6 ff ff       	call   f0100040 <_panic>
f0101a1f:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101a25:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++) {
		// cprintf("[?] %d\n", i);
		assert(c[i] == 0);
f0101a2b:	80 38 00             	cmpb   $0x0,(%eax)
f0101a2e:	74 19                	je     f0101a49 <mem_init+0x4c6>
f0101a30:	68 8f 71 10 f0       	push   $0xf010718f
f0101a35:	68 85 6f 10 f0       	push   $0xf0106f85
f0101a3a:	68 e1 03 00 00       	push   $0x3e1
f0101a3f:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101a44:	e8 f7 e5 ff ff       	call   f0100040 <_panic>
f0101a49:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++) {
f0101a4c:	39 d0                	cmp    %edx,%eax
f0101a4e:	75 db                	jne    f0101a2b <mem_init+0x4a8>
		// cprintf("[?] %d\n", i);
		assert(c[i] == 0);
	}

	// give free list back
	page_free_list = fl;
f0101a50:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101a53:	a3 40 92 2a f0       	mov    %eax,0xf02a9240

	// free the pages we took
	page_free(pp0);
f0101a58:	83 ec 0c             	sub    $0xc,%esp
f0101a5b:	56                   	push   %esi
f0101a5c:	e8 b0 f6 ff ff       	call   f0101111 <page_free>
	page_free(pp1);
f0101a61:	89 3c 24             	mov    %edi,(%esp)
f0101a64:	e8 a8 f6 ff ff       	call   f0101111 <page_free>
	page_free(pp2);
f0101a69:	83 c4 04             	add    $0x4,%esp
f0101a6c:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101a6f:	e8 9d f6 ff ff       	call   f0101111 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101a74:	a1 40 92 2a f0       	mov    0xf02a9240,%eax
f0101a79:	83 c4 10             	add    $0x10,%esp
f0101a7c:	eb 05                	jmp    f0101a83 <mem_init+0x500>
		--nfree;
f0101a7e:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101a81:	8b 00                	mov    (%eax),%eax
f0101a83:	85 c0                	test   %eax,%eax
f0101a85:	75 f7                	jne    f0101a7e <mem_init+0x4fb>
		--nfree;
	assert(nfree == 0);
f0101a87:	85 db                	test   %ebx,%ebx
f0101a89:	74 19                	je     f0101aa4 <mem_init+0x521>
f0101a8b:	68 99 71 10 f0       	push   $0xf0107199
f0101a90:	68 85 6f 10 f0       	push   $0xf0106f85
f0101a95:	68 ef 03 00 00       	push   $0x3ef
f0101a9a:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101a9f:	e8 9c e5 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101aa4:	83 ec 0c             	sub    $0xc,%esp
f0101aa7:	68 74 75 10 f0       	push   $0xf0107574
f0101aac:	e8 e0 1e 00 00       	call   f0103991 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101ab1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ab8:	e8 e3 f5 ff ff       	call   f01010a0 <page_alloc>
f0101abd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101ac0:	83 c4 10             	add    $0x10,%esp
f0101ac3:	85 c0                	test   %eax,%eax
f0101ac5:	75 19                	jne    f0101ae0 <mem_init+0x55d>
f0101ac7:	68 a7 70 10 f0       	push   $0xf01070a7
f0101acc:	68 85 6f 10 f0       	push   $0xf0106f85
f0101ad1:	68 59 04 00 00       	push   $0x459
f0101ad6:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101adb:	e8 60 e5 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101ae0:	83 ec 0c             	sub    $0xc,%esp
f0101ae3:	6a 00                	push   $0x0
f0101ae5:	e8 b6 f5 ff ff       	call   f01010a0 <page_alloc>
f0101aea:	89 c3                	mov    %eax,%ebx
f0101aec:	83 c4 10             	add    $0x10,%esp
f0101aef:	85 c0                	test   %eax,%eax
f0101af1:	75 19                	jne    f0101b0c <mem_init+0x589>
f0101af3:	68 bd 70 10 f0       	push   $0xf01070bd
f0101af8:	68 85 6f 10 f0       	push   $0xf0106f85
f0101afd:	68 5a 04 00 00       	push   $0x45a
f0101b02:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101b07:	e8 34 e5 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101b0c:	83 ec 0c             	sub    $0xc,%esp
f0101b0f:	6a 00                	push   $0x0
f0101b11:	e8 8a f5 ff ff       	call   f01010a0 <page_alloc>
f0101b16:	89 c6                	mov    %eax,%esi
f0101b18:	83 c4 10             	add    $0x10,%esp
f0101b1b:	85 c0                	test   %eax,%eax
f0101b1d:	75 19                	jne    f0101b38 <mem_init+0x5b5>
f0101b1f:	68 d3 70 10 f0       	push   $0xf01070d3
f0101b24:	68 85 6f 10 f0       	push   $0xf0106f85
f0101b29:	68 5b 04 00 00       	push   $0x45b
f0101b2e:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101b33:	e8 08 e5 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101b38:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101b3b:	75 19                	jne    f0101b56 <mem_init+0x5d3>
f0101b3d:	68 e9 70 10 f0       	push   $0xf01070e9
f0101b42:	68 85 6f 10 f0       	push   $0xf0106f85
f0101b47:	68 5e 04 00 00       	push   $0x45e
f0101b4c:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101b51:	e8 ea e4 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101b56:	39 c3                	cmp    %eax,%ebx
f0101b58:	74 05                	je     f0101b5f <mem_init+0x5dc>
f0101b5a:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101b5d:	75 19                	jne    f0101b78 <mem_init+0x5f5>
f0101b5f:	68 54 75 10 f0       	push   $0xf0107554
f0101b64:	68 85 6f 10 f0       	push   $0xf0106f85
f0101b69:	68 5f 04 00 00       	push   $0x45f
f0101b6e:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101b73:	e8 c8 e4 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101b78:	a1 40 92 2a f0       	mov    0xf02a9240,%eax
f0101b7d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101b80:	c7 05 40 92 2a f0 00 	movl   $0x0,0xf02a9240
f0101b87:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101b8a:	83 ec 0c             	sub    $0xc,%esp
f0101b8d:	6a 00                	push   $0x0
f0101b8f:	e8 0c f5 ff ff       	call   f01010a0 <page_alloc>
f0101b94:	83 c4 10             	add    $0x10,%esp
f0101b97:	85 c0                	test   %eax,%eax
f0101b99:	74 19                	je     f0101bb4 <mem_init+0x631>
f0101b9b:	68 52 71 10 f0       	push   $0xf0107152
f0101ba0:	68 85 6f 10 f0       	push   $0xf0106f85
f0101ba5:	68 66 04 00 00       	push   $0x466
f0101baa:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101baf:	e8 8c e4 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101bb4:	83 ec 04             	sub    $0x4,%esp
f0101bb7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101bba:	50                   	push   %eax
f0101bbb:	6a 00                	push   $0x0
f0101bbd:	ff 35 a4 9e 2a f0    	pushl  0xf02a9ea4
f0101bc3:	e8 e3 f7 ff ff       	call   f01013ab <page_lookup>
f0101bc8:	83 c4 10             	add    $0x10,%esp
f0101bcb:	85 c0                	test   %eax,%eax
f0101bcd:	74 19                	je     f0101be8 <mem_init+0x665>
f0101bcf:	68 94 75 10 f0       	push   $0xf0107594
f0101bd4:	68 85 6f 10 f0       	push   $0xf0106f85
f0101bd9:	68 69 04 00 00       	push   $0x469
f0101bde:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101be3:	e8 58 e4 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101be8:	6a 02                	push   $0x2
f0101bea:	6a 00                	push   $0x0
f0101bec:	53                   	push   %ebx
f0101bed:	ff 35 a4 9e 2a f0    	pushl  0xf02a9ea4
f0101bf3:	e8 9b f8 ff ff       	call   f0101493 <page_insert>
f0101bf8:	83 c4 10             	add    $0x10,%esp
f0101bfb:	85 c0                	test   %eax,%eax
f0101bfd:	78 19                	js     f0101c18 <mem_init+0x695>
f0101bff:	68 cc 75 10 f0       	push   $0xf01075cc
f0101c04:	68 85 6f 10 f0       	push   $0xf0106f85
f0101c09:	68 6c 04 00 00       	push   $0x46c
f0101c0e:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101c13:	e8 28 e4 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101c18:	83 ec 0c             	sub    $0xc,%esp
f0101c1b:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101c1e:	e8 ee f4 ff ff       	call   f0101111 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101c23:	6a 02                	push   $0x2
f0101c25:	6a 00                	push   $0x0
f0101c27:	53                   	push   %ebx
f0101c28:	ff 35 a4 9e 2a f0    	pushl  0xf02a9ea4
f0101c2e:	e8 60 f8 ff ff       	call   f0101493 <page_insert>
f0101c33:	83 c4 20             	add    $0x20,%esp
f0101c36:	85 c0                	test   %eax,%eax
f0101c38:	74 19                	je     f0101c53 <mem_init+0x6d0>
f0101c3a:	68 fc 75 10 f0       	push   $0xf01075fc
f0101c3f:	68 85 6f 10 f0       	push   $0xf0106f85
f0101c44:	68 70 04 00 00       	push   $0x470
f0101c49:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101c4e:	e8 ed e3 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101c53:	8b 3d a4 9e 2a f0    	mov    0xf02a9ea4,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101c59:	a1 a8 9e 2a f0       	mov    0xf02a9ea8,%eax
f0101c5e:	89 c1                	mov    %eax,%ecx
f0101c60:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101c63:	8b 17                	mov    (%edi),%edx
f0101c65:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101c6b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c6e:	29 c8                	sub    %ecx,%eax
f0101c70:	c1 f8 03             	sar    $0x3,%eax
f0101c73:	c1 e0 0c             	shl    $0xc,%eax
f0101c76:	39 c2                	cmp    %eax,%edx
f0101c78:	74 19                	je     f0101c93 <mem_init+0x710>
f0101c7a:	68 2c 76 10 f0       	push   $0xf010762c
f0101c7f:	68 85 6f 10 f0       	push   $0xf0106f85
f0101c84:	68 71 04 00 00       	push   $0x471
f0101c89:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101c8e:	e8 ad e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101c93:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c98:	89 f8                	mov    %edi,%eax
f0101c9a:	e8 e5 ee ff ff       	call   f0100b84 <check_va2pa>
f0101c9f:	89 da                	mov    %ebx,%edx
f0101ca1:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101ca4:	c1 fa 03             	sar    $0x3,%edx
f0101ca7:	c1 e2 0c             	shl    $0xc,%edx
f0101caa:	39 d0                	cmp    %edx,%eax
f0101cac:	74 19                	je     f0101cc7 <mem_init+0x744>
f0101cae:	68 54 76 10 f0       	push   $0xf0107654
f0101cb3:	68 85 6f 10 f0       	push   $0xf0106f85
f0101cb8:	68 72 04 00 00       	push   $0x472
f0101cbd:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101cc2:	e8 79 e3 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101cc7:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101ccc:	74 19                	je     f0101ce7 <mem_init+0x764>
f0101cce:	68 a4 71 10 f0       	push   $0xf01071a4
f0101cd3:	68 85 6f 10 f0       	push   $0xf0106f85
f0101cd8:	68 73 04 00 00       	push   $0x473
f0101cdd:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101ce2:	e8 59 e3 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101ce7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101cea:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101cef:	74 19                	je     f0101d0a <mem_init+0x787>
f0101cf1:	68 b5 71 10 f0       	push   $0xf01071b5
f0101cf6:	68 85 6f 10 f0       	push   $0xf0106f85
f0101cfb:	68 74 04 00 00       	push   $0x474
f0101d00:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101d05:	e8 36 e3 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101d0a:	6a 02                	push   $0x2
f0101d0c:	68 00 10 00 00       	push   $0x1000
f0101d11:	56                   	push   %esi
f0101d12:	57                   	push   %edi
f0101d13:	e8 7b f7 ff ff       	call   f0101493 <page_insert>
f0101d18:	83 c4 10             	add    $0x10,%esp
f0101d1b:	85 c0                	test   %eax,%eax
f0101d1d:	74 19                	je     f0101d38 <mem_init+0x7b5>
f0101d1f:	68 84 76 10 f0       	push   $0xf0107684
f0101d24:	68 85 6f 10 f0       	push   $0xf0106f85
f0101d29:	68 77 04 00 00       	push   $0x477
f0101d2e:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101d33:	e8 08 e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d38:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d3d:	a1 a4 9e 2a f0       	mov    0xf02a9ea4,%eax
f0101d42:	e8 3d ee ff ff       	call   f0100b84 <check_va2pa>
f0101d47:	89 f2                	mov    %esi,%edx
f0101d49:	2b 15 a8 9e 2a f0    	sub    0xf02a9ea8,%edx
f0101d4f:	c1 fa 03             	sar    $0x3,%edx
f0101d52:	c1 e2 0c             	shl    $0xc,%edx
f0101d55:	39 d0                	cmp    %edx,%eax
f0101d57:	74 19                	je     f0101d72 <mem_init+0x7ef>
f0101d59:	68 c0 76 10 f0       	push   $0xf01076c0
f0101d5e:	68 85 6f 10 f0       	push   $0xf0106f85
f0101d63:	68 78 04 00 00       	push   $0x478
f0101d68:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101d6d:	e8 ce e2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101d72:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d77:	74 19                	je     f0101d92 <mem_init+0x80f>
f0101d79:	68 c6 71 10 f0       	push   $0xf01071c6
f0101d7e:	68 85 6f 10 f0       	push   $0xf0106f85
f0101d83:	68 79 04 00 00       	push   $0x479
f0101d88:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101d8d:	e8 ae e2 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101d92:	83 ec 0c             	sub    $0xc,%esp
f0101d95:	6a 00                	push   $0x0
f0101d97:	e8 04 f3 ff ff       	call   f01010a0 <page_alloc>
f0101d9c:	83 c4 10             	add    $0x10,%esp
f0101d9f:	85 c0                	test   %eax,%eax
f0101da1:	74 19                	je     f0101dbc <mem_init+0x839>
f0101da3:	68 52 71 10 f0       	push   $0xf0107152
f0101da8:	68 85 6f 10 f0       	push   $0xf0106f85
f0101dad:	68 7c 04 00 00       	push   $0x47c
f0101db2:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101db7:	e8 84 e2 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101dbc:	6a 02                	push   $0x2
f0101dbe:	68 00 10 00 00       	push   $0x1000
f0101dc3:	56                   	push   %esi
f0101dc4:	ff 35 a4 9e 2a f0    	pushl  0xf02a9ea4
f0101dca:	e8 c4 f6 ff ff       	call   f0101493 <page_insert>
f0101dcf:	83 c4 10             	add    $0x10,%esp
f0101dd2:	85 c0                	test   %eax,%eax
f0101dd4:	74 19                	je     f0101def <mem_init+0x86c>
f0101dd6:	68 84 76 10 f0       	push   $0xf0107684
f0101ddb:	68 85 6f 10 f0       	push   $0xf0106f85
f0101de0:	68 7f 04 00 00       	push   $0x47f
f0101de5:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101dea:	e8 51 e2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101def:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101df4:	a1 a4 9e 2a f0       	mov    0xf02a9ea4,%eax
f0101df9:	e8 86 ed ff ff       	call   f0100b84 <check_va2pa>
f0101dfe:	89 f2                	mov    %esi,%edx
f0101e00:	2b 15 a8 9e 2a f0    	sub    0xf02a9ea8,%edx
f0101e06:	c1 fa 03             	sar    $0x3,%edx
f0101e09:	c1 e2 0c             	shl    $0xc,%edx
f0101e0c:	39 d0                	cmp    %edx,%eax
f0101e0e:	74 19                	je     f0101e29 <mem_init+0x8a6>
f0101e10:	68 c0 76 10 f0       	push   $0xf01076c0
f0101e15:	68 85 6f 10 f0       	push   $0xf0106f85
f0101e1a:	68 80 04 00 00       	push   $0x480
f0101e1f:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101e24:	e8 17 e2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101e29:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101e2e:	74 19                	je     f0101e49 <mem_init+0x8c6>
f0101e30:	68 c6 71 10 f0       	push   $0xf01071c6
f0101e35:	68 85 6f 10 f0       	push   $0xf0106f85
f0101e3a:	68 81 04 00 00       	push   $0x481
f0101e3f:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101e44:	e8 f7 e1 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101e49:	83 ec 0c             	sub    $0xc,%esp
f0101e4c:	6a 00                	push   $0x0
f0101e4e:	e8 4d f2 ff ff       	call   f01010a0 <page_alloc>
f0101e53:	83 c4 10             	add    $0x10,%esp
f0101e56:	85 c0                	test   %eax,%eax
f0101e58:	74 19                	je     f0101e73 <mem_init+0x8f0>
f0101e5a:	68 52 71 10 f0       	push   $0xf0107152
f0101e5f:	68 85 6f 10 f0       	push   $0xf0106f85
f0101e64:	68 85 04 00 00       	push   $0x485
f0101e69:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101e6e:	e8 cd e1 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101e73:	8b 15 a4 9e 2a f0    	mov    0xf02a9ea4,%edx
f0101e79:	8b 02                	mov    (%edx),%eax
f0101e7b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101e80:	89 c1                	mov    %eax,%ecx
f0101e82:	c1 e9 0c             	shr    $0xc,%ecx
f0101e85:	3b 0d a0 9e 2a f0    	cmp    0xf02a9ea0,%ecx
f0101e8b:	72 15                	jb     f0101ea2 <mem_init+0x91f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101e8d:	50                   	push   %eax
f0101e8e:	68 a4 69 10 f0       	push   $0xf01069a4
f0101e93:	68 88 04 00 00       	push   $0x488
f0101e98:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101e9d:	e8 9e e1 ff ff       	call   f0100040 <_panic>
f0101ea2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101ea7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101eaa:	83 ec 04             	sub    $0x4,%esp
f0101ead:	6a 00                	push   $0x0
f0101eaf:	68 00 10 00 00       	push   $0x1000
f0101eb4:	52                   	push   %edx
f0101eb5:	e8 d4 f2 ff ff       	call   f010118e <pgdir_walk>
f0101eba:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101ebd:	8d 51 04             	lea    0x4(%ecx),%edx
f0101ec0:	83 c4 10             	add    $0x10,%esp
f0101ec3:	39 d0                	cmp    %edx,%eax
f0101ec5:	74 19                	je     f0101ee0 <mem_init+0x95d>
f0101ec7:	68 f0 76 10 f0       	push   $0xf01076f0
f0101ecc:	68 85 6f 10 f0       	push   $0xf0106f85
f0101ed1:	68 89 04 00 00       	push   $0x489
f0101ed6:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101edb:	e8 60 e1 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101ee0:	6a 06                	push   $0x6
f0101ee2:	68 00 10 00 00       	push   $0x1000
f0101ee7:	56                   	push   %esi
f0101ee8:	ff 35 a4 9e 2a f0    	pushl  0xf02a9ea4
f0101eee:	e8 a0 f5 ff ff       	call   f0101493 <page_insert>
f0101ef3:	83 c4 10             	add    $0x10,%esp
f0101ef6:	85 c0                	test   %eax,%eax
f0101ef8:	74 19                	je     f0101f13 <mem_init+0x990>
f0101efa:	68 30 77 10 f0       	push   $0xf0107730
f0101eff:	68 85 6f 10 f0       	push   $0xf0106f85
f0101f04:	68 8c 04 00 00       	push   $0x48c
f0101f09:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101f0e:	e8 2d e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f13:	8b 3d a4 9e 2a f0    	mov    0xf02a9ea4,%edi
f0101f19:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f1e:	89 f8                	mov    %edi,%eax
f0101f20:	e8 5f ec ff ff       	call   f0100b84 <check_va2pa>
f0101f25:	89 f2                	mov    %esi,%edx
f0101f27:	2b 15 a8 9e 2a f0    	sub    0xf02a9ea8,%edx
f0101f2d:	c1 fa 03             	sar    $0x3,%edx
f0101f30:	c1 e2 0c             	shl    $0xc,%edx
f0101f33:	39 d0                	cmp    %edx,%eax
f0101f35:	74 19                	je     f0101f50 <mem_init+0x9cd>
f0101f37:	68 c0 76 10 f0       	push   $0xf01076c0
f0101f3c:	68 85 6f 10 f0       	push   $0xf0106f85
f0101f41:	68 8d 04 00 00       	push   $0x48d
f0101f46:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101f4b:	e8 f0 e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101f50:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101f55:	74 19                	je     f0101f70 <mem_init+0x9ed>
f0101f57:	68 c6 71 10 f0       	push   $0xf01071c6
f0101f5c:	68 85 6f 10 f0       	push   $0xf0106f85
f0101f61:	68 8e 04 00 00       	push   $0x48e
f0101f66:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101f6b:	e8 d0 e0 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101f70:	83 ec 04             	sub    $0x4,%esp
f0101f73:	6a 00                	push   $0x0
f0101f75:	68 00 10 00 00       	push   $0x1000
f0101f7a:	57                   	push   %edi
f0101f7b:	e8 0e f2 ff ff       	call   f010118e <pgdir_walk>
f0101f80:	83 c4 10             	add    $0x10,%esp
f0101f83:	f6 00 04             	testb  $0x4,(%eax)
f0101f86:	75 19                	jne    f0101fa1 <mem_init+0xa1e>
f0101f88:	68 70 77 10 f0       	push   $0xf0107770
f0101f8d:	68 85 6f 10 f0       	push   $0xf0106f85
f0101f92:	68 8f 04 00 00       	push   $0x48f
f0101f97:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101f9c:	e8 9f e0 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101fa1:	a1 a4 9e 2a f0       	mov    0xf02a9ea4,%eax
f0101fa6:	f6 00 04             	testb  $0x4,(%eax)
f0101fa9:	75 19                	jne    f0101fc4 <mem_init+0xa41>
f0101fab:	68 d7 71 10 f0       	push   $0xf01071d7
f0101fb0:	68 85 6f 10 f0       	push   $0xf0106f85
f0101fb5:	68 90 04 00 00       	push   $0x490
f0101fba:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101fbf:	e8 7c e0 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101fc4:	6a 02                	push   $0x2
f0101fc6:	68 00 10 00 00       	push   $0x1000
f0101fcb:	56                   	push   %esi
f0101fcc:	50                   	push   %eax
f0101fcd:	e8 c1 f4 ff ff       	call   f0101493 <page_insert>
f0101fd2:	83 c4 10             	add    $0x10,%esp
f0101fd5:	85 c0                	test   %eax,%eax
f0101fd7:	74 19                	je     f0101ff2 <mem_init+0xa6f>
f0101fd9:	68 84 76 10 f0       	push   $0xf0107684
f0101fde:	68 85 6f 10 f0       	push   $0xf0106f85
f0101fe3:	68 93 04 00 00       	push   $0x493
f0101fe8:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101fed:	e8 4e e0 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101ff2:	83 ec 04             	sub    $0x4,%esp
f0101ff5:	6a 00                	push   $0x0
f0101ff7:	68 00 10 00 00       	push   $0x1000
f0101ffc:	ff 35 a4 9e 2a f0    	pushl  0xf02a9ea4
f0102002:	e8 87 f1 ff ff       	call   f010118e <pgdir_walk>
f0102007:	83 c4 10             	add    $0x10,%esp
f010200a:	f6 00 02             	testb  $0x2,(%eax)
f010200d:	75 19                	jne    f0102028 <mem_init+0xaa5>
f010200f:	68 a4 77 10 f0       	push   $0xf01077a4
f0102014:	68 85 6f 10 f0       	push   $0xf0106f85
f0102019:	68 94 04 00 00       	push   $0x494
f010201e:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102023:	e8 18 e0 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102028:	83 ec 04             	sub    $0x4,%esp
f010202b:	6a 00                	push   $0x0
f010202d:	68 00 10 00 00       	push   $0x1000
f0102032:	ff 35 a4 9e 2a f0    	pushl  0xf02a9ea4
f0102038:	e8 51 f1 ff ff       	call   f010118e <pgdir_walk>
f010203d:	83 c4 10             	add    $0x10,%esp
f0102040:	f6 00 04             	testb  $0x4,(%eax)
f0102043:	74 19                	je     f010205e <mem_init+0xadb>
f0102045:	68 d8 77 10 f0       	push   $0xf01077d8
f010204a:	68 85 6f 10 f0       	push   $0xf0106f85
f010204f:	68 95 04 00 00       	push   $0x495
f0102054:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102059:	e8 e2 df ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f010205e:	6a 02                	push   $0x2
f0102060:	68 00 00 40 00       	push   $0x400000
f0102065:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102068:	ff 35 a4 9e 2a f0    	pushl  0xf02a9ea4
f010206e:	e8 20 f4 ff ff       	call   f0101493 <page_insert>
f0102073:	83 c4 10             	add    $0x10,%esp
f0102076:	85 c0                	test   %eax,%eax
f0102078:	78 19                	js     f0102093 <mem_init+0xb10>
f010207a:	68 10 78 10 f0       	push   $0xf0107810
f010207f:	68 85 6f 10 f0       	push   $0xf0106f85
f0102084:	68 98 04 00 00       	push   $0x498
f0102089:	68 5f 6f 10 f0       	push   $0xf0106f5f
f010208e:	e8 ad df ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102093:	6a 02                	push   $0x2
f0102095:	68 00 10 00 00       	push   $0x1000
f010209a:	53                   	push   %ebx
f010209b:	ff 35 a4 9e 2a f0    	pushl  0xf02a9ea4
f01020a1:	e8 ed f3 ff ff       	call   f0101493 <page_insert>
f01020a6:	83 c4 10             	add    $0x10,%esp
f01020a9:	85 c0                	test   %eax,%eax
f01020ab:	74 19                	je     f01020c6 <mem_init+0xb43>
f01020ad:	68 48 78 10 f0       	push   $0xf0107848
f01020b2:	68 85 6f 10 f0       	push   $0xf0106f85
f01020b7:	68 9b 04 00 00       	push   $0x49b
f01020bc:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01020c1:	e8 7a df ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01020c6:	83 ec 04             	sub    $0x4,%esp
f01020c9:	6a 00                	push   $0x0
f01020cb:	68 00 10 00 00       	push   $0x1000
f01020d0:	ff 35 a4 9e 2a f0    	pushl  0xf02a9ea4
f01020d6:	e8 b3 f0 ff ff       	call   f010118e <pgdir_walk>
f01020db:	83 c4 10             	add    $0x10,%esp
f01020de:	f6 00 04             	testb  $0x4,(%eax)
f01020e1:	74 19                	je     f01020fc <mem_init+0xb79>
f01020e3:	68 d8 77 10 f0       	push   $0xf01077d8
f01020e8:	68 85 6f 10 f0       	push   $0xf0106f85
f01020ed:	68 9c 04 00 00       	push   $0x49c
f01020f2:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01020f7:	e8 44 df ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01020fc:	8b 3d a4 9e 2a f0    	mov    0xf02a9ea4,%edi
f0102102:	ba 00 00 00 00       	mov    $0x0,%edx
f0102107:	89 f8                	mov    %edi,%eax
f0102109:	e8 76 ea ff ff       	call   f0100b84 <check_va2pa>
f010210e:	89 c1                	mov    %eax,%ecx
f0102110:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102113:	89 d8                	mov    %ebx,%eax
f0102115:	2b 05 a8 9e 2a f0    	sub    0xf02a9ea8,%eax
f010211b:	c1 f8 03             	sar    $0x3,%eax
f010211e:	c1 e0 0c             	shl    $0xc,%eax
f0102121:	39 c1                	cmp    %eax,%ecx
f0102123:	74 19                	je     f010213e <mem_init+0xbbb>
f0102125:	68 84 78 10 f0       	push   $0xf0107884
f010212a:	68 85 6f 10 f0       	push   $0xf0106f85
f010212f:	68 9f 04 00 00       	push   $0x49f
f0102134:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102139:	e8 02 df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010213e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102143:	89 f8                	mov    %edi,%eax
f0102145:	e8 3a ea ff ff       	call   f0100b84 <check_va2pa>
f010214a:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f010214d:	74 19                	je     f0102168 <mem_init+0xbe5>
f010214f:	68 b0 78 10 f0       	push   $0xf01078b0
f0102154:	68 85 6f 10 f0       	push   $0xf0106f85
f0102159:	68 a0 04 00 00       	push   $0x4a0
f010215e:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102163:	e8 d8 de ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102168:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f010216d:	74 19                	je     f0102188 <mem_init+0xc05>
f010216f:	68 ed 71 10 f0       	push   $0xf01071ed
f0102174:	68 85 6f 10 f0       	push   $0xf0106f85
f0102179:	68 a2 04 00 00       	push   $0x4a2
f010217e:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102183:	e8 b8 de ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102188:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010218d:	74 19                	je     f01021a8 <mem_init+0xc25>
f010218f:	68 fe 71 10 f0       	push   $0xf01071fe
f0102194:	68 85 6f 10 f0       	push   $0xf0106f85
f0102199:	68 a3 04 00 00       	push   $0x4a3
f010219e:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01021a3:	e8 98 de ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01021a8:	83 ec 0c             	sub    $0xc,%esp
f01021ab:	6a 00                	push   $0x0
f01021ad:	e8 ee ee ff ff       	call   f01010a0 <page_alloc>
f01021b2:	83 c4 10             	add    $0x10,%esp
f01021b5:	85 c0                	test   %eax,%eax
f01021b7:	74 04                	je     f01021bd <mem_init+0xc3a>
f01021b9:	39 c6                	cmp    %eax,%esi
f01021bb:	74 19                	je     f01021d6 <mem_init+0xc53>
f01021bd:	68 e0 78 10 f0       	push   $0xf01078e0
f01021c2:	68 85 6f 10 f0       	push   $0xf0106f85
f01021c7:	68 a6 04 00 00       	push   $0x4a6
f01021cc:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01021d1:	e8 6a de ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01021d6:	83 ec 08             	sub    $0x8,%esp
f01021d9:	6a 00                	push   $0x0
f01021db:	ff 35 a4 9e 2a f0    	pushl  0xf02a9ea4
f01021e1:	e8 60 f2 ff ff       	call   f0101446 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01021e6:	8b 3d a4 9e 2a f0    	mov    0xf02a9ea4,%edi
f01021ec:	ba 00 00 00 00       	mov    $0x0,%edx
f01021f1:	89 f8                	mov    %edi,%eax
f01021f3:	e8 8c e9 ff ff       	call   f0100b84 <check_va2pa>
f01021f8:	83 c4 10             	add    $0x10,%esp
f01021fb:	83 f8 ff             	cmp    $0xffffffff,%eax
f01021fe:	74 19                	je     f0102219 <mem_init+0xc96>
f0102200:	68 04 79 10 f0       	push   $0xf0107904
f0102205:	68 85 6f 10 f0       	push   $0xf0106f85
f010220a:	68 aa 04 00 00       	push   $0x4aa
f010220f:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102214:	e8 27 de ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102219:	ba 00 10 00 00       	mov    $0x1000,%edx
f010221e:	89 f8                	mov    %edi,%eax
f0102220:	e8 5f e9 ff ff       	call   f0100b84 <check_va2pa>
f0102225:	89 da                	mov    %ebx,%edx
f0102227:	2b 15 a8 9e 2a f0    	sub    0xf02a9ea8,%edx
f010222d:	c1 fa 03             	sar    $0x3,%edx
f0102230:	c1 e2 0c             	shl    $0xc,%edx
f0102233:	39 d0                	cmp    %edx,%eax
f0102235:	74 19                	je     f0102250 <mem_init+0xccd>
f0102237:	68 b0 78 10 f0       	push   $0xf01078b0
f010223c:	68 85 6f 10 f0       	push   $0xf0106f85
f0102241:	68 ab 04 00 00       	push   $0x4ab
f0102246:	68 5f 6f 10 f0       	push   $0xf0106f5f
f010224b:	e8 f0 dd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102250:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102255:	74 19                	je     f0102270 <mem_init+0xced>
f0102257:	68 a4 71 10 f0       	push   $0xf01071a4
f010225c:	68 85 6f 10 f0       	push   $0xf0106f85
f0102261:	68 ac 04 00 00       	push   $0x4ac
f0102266:	68 5f 6f 10 f0       	push   $0xf0106f5f
f010226b:	e8 d0 dd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102270:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102275:	74 19                	je     f0102290 <mem_init+0xd0d>
f0102277:	68 fe 71 10 f0       	push   $0xf01071fe
f010227c:	68 85 6f 10 f0       	push   $0xf0106f85
f0102281:	68 ad 04 00 00       	push   $0x4ad
f0102286:	68 5f 6f 10 f0       	push   $0xf0106f5f
f010228b:	e8 b0 dd ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102290:	6a 00                	push   $0x0
f0102292:	68 00 10 00 00       	push   $0x1000
f0102297:	53                   	push   %ebx
f0102298:	57                   	push   %edi
f0102299:	e8 f5 f1 ff ff       	call   f0101493 <page_insert>
f010229e:	83 c4 10             	add    $0x10,%esp
f01022a1:	85 c0                	test   %eax,%eax
f01022a3:	74 19                	je     f01022be <mem_init+0xd3b>
f01022a5:	68 28 79 10 f0       	push   $0xf0107928
f01022aa:	68 85 6f 10 f0       	push   $0xf0106f85
f01022af:	68 b0 04 00 00       	push   $0x4b0
f01022b4:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01022b9:	e8 82 dd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f01022be:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01022c3:	75 19                	jne    f01022de <mem_init+0xd5b>
f01022c5:	68 0f 72 10 f0       	push   $0xf010720f
f01022ca:	68 85 6f 10 f0       	push   $0xf0106f85
f01022cf:	68 b1 04 00 00       	push   $0x4b1
f01022d4:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01022d9:	e8 62 dd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f01022de:	83 3b 00             	cmpl   $0x0,(%ebx)
f01022e1:	74 19                	je     f01022fc <mem_init+0xd79>
f01022e3:	68 1b 72 10 f0       	push   $0xf010721b
f01022e8:	68 85 6f 10 f0       	push   $0xf0106f85
f01022ed:	68 b2 04 00 00       	push   $0x4b2
f01022f2:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01022f7:	e8 44 dd ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01022fc:	83 ec 08             	sub    $0x8,%esp
f01022ff:	68 00 10 00 00       	push   $0x1000
f0102304:	ff 35 a4 9e 2a f0    	pushl  0xf02a9ea4
f010230a:	e8 37 f1 ff ff       	call   f0101446 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010230f:	8b 3d a4 9e 2a f0    	mov    0xf02a9ea4,%edi
f0102315:	ba 00 00 00 00       	mov    $0x0,%edx
f010231a:	89 f8                	mov    %edi,%eax
f010231c:	e8 63 e8 ff ff       	call   f0100b84 <check_va2pa>
f0102321:	83 c4 10             	add    $0x10,%esp
f0102324:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102327:	74 19                	je     f0102342 <mem_init+0xdbf>
f0102329:	68 04 79 10 f0       	push   $0xf0107904
f010232e:	68 85 6f 10 f0       	push   $0xf0106f85
f0102333:	68 b6 04 00 00       	push   $0x4b6
f0102338:	68 5f 6f 10 f0       	push   $0xf0106f5f
f010233d:	e8 fe dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102342:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102347:	89 f8                	mov    %edi,%eax
f0102349:	e8 36 e8 ff ff       	call   f0100b84 <check_va2pa>
f010234e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102351:	74 19                	je     f010236c <mem_init+0xde9>
f0102353:	68 60 79 10 f0       	push   $0xf0107960
f0102358:	68 85 6f 10 f0       	push   $0xf0106f85
f010235d:	68 b7 04 00 00       	push   $0x4b7
f0102362:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102367:	e8 d4 dc ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f010236c:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102371:	74 19                	je     f010238c <mem_init+0xe09>
f0102373:	68 30 72 10 f0       	push   $0xf0107230
f0102378:	68 85 6f 10 f0       	push   $0xf0106f85
f010237d:	68 b8 04 00 00       	push   $0x4b8
f0102382:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102387:	e8 b4 dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010238c:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102391:	74 19                	je     f01023ac <mem_init+0xe29>
f0102393:	68 fe 71 10 f0       	push   $0xf01071fe
f0102398:	68 85 6f 10 f0       	push   $0xf0106f85
f010239d:	68 b9 04 00 00       	push   $0x4b9
f01023a2:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01023a7:	e8 94 dc ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01023ac:	83 ec 0c             	sub    $0xc,%esp
f01023af:	6a 00                	push   $0x0
f01023b1:	e8 ea ec ff ff       	call   f01010a0 <page_alloc>
f01023b6:	83 c4 10             	add    $0x10,%esp
f01023b9:	39 c3                	cmp    %eax,%ebx
f01023bb:	75 04                	jne    f01023c1 <mem_init+0xe3e>
f01023bd:	85 c0                	test   %eax,%eax
f01023bf:	75 19                	jne    f01023da <mem_init+0xe57>
f01023c1:	68 88 79 10 f0       	push   $0xf0107988
f01023c6:	68 85 6f 10 f0       	push   $0xf0106f85
f01023cb:	68 bc 04 00 00       	push   $0x4bc
f01023d0:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01023d5:	e8 66 dc ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01023da:	83 ec 0c             	sub    $0xc,%esp
f01023dd:	6a 00                	push   $0x0
f01023df:	e8 bc ec ff ff       	call   f01010a0 <page_alloc>
f01023e4:	83 c4 10             	add    $0x10,%esp
f01023e7:	85 c0                	test   %eax,%eax
f01023e9:	74 19                	je     f0102404 <mem_init+0xe81>
f01023eb:	68 52 71 10 f0       	push   $0xf0107152
f01023f0:	68 85 6f 10 f0       	push   $0xf0106f85
f01023f5:	68 bf 04 00 00       	push   $0x4bf
f01023fa:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01023ff:	e8 3c dc ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102404:	8b 0d a4 9e 2a f0    	mov    0xf02a9ea4,%ecx
f010240a:	8b 11                	mov    (%ecx),%edx
f010240c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102412:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102415:	2b 05 a8 9e 2a f0    	sub    0xf02a9ea8,%eax
f010241b:	c1 f8 03             	sar    $0x3,%eax
f010241e:	c1 e0 0c             	shl    $0xc,%eax
f0102421:	39 c2                	cmp    %eax,%edx
f0102423:	74 19                	je     f010243e <mem_init+0xebb>
f0102425:	68 2c 76 10 f0       	push   $0xf010762c
f010242a:	68 85 6f 10 f0       	push   $0xf0106f85
f010242f:	68 c2 04 00 00       	push   $0x4c2
f0102434:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102439:	e8 02 dc ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f010243e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102444:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102447:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010244c:	74 19                	je     f0102467 <mem_init+0xee4>
f010244e:	68 b5 71 10 f0       	push   $0xf01071b5
f0102453:	68 85 6f 10 f0       	push   $0xf0106f85
f0102458:	68 c4 04 00 00       	push   $0x4c4
f010245d:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102462:	e8 d9 db ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102467:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010246a:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102470:	83 ec 0c             	sub    $0xc,%esp
f0102473:	50                   	push   %eax
f0102474:	e8 98 ec ff ff       	call   f0101111 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102479:	83 c4 0c             	add    $0xc,%esp
f010247c:	6a 01                	push   $0x1
f010247e:	68 00 10 40 00       	push   $0x401000
f0102483:	ff 35 a4 9e 2a f0    	pushl  0xf02a9ea4
f0102489:	e8 00 ed ff ff       	call   f010118e <pgdir_walk>
f010248e:	89 c7                	mov    %eax,%edi
f0102490:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102493:	a1 a4 9e 2a f0       	mov    0xf02a9ea4,%eax
f0102498:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010249b:	8b 40 04             	mov    0x4(%eax),%eax
f010249e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01024a3:	8b 0d a0 9e 2a f0    	mov    0xf02a9ea0,%ecx
f01024a9:	89 c2                	mov    %eax,%edx
f01024ab:	c1 ea 0c             	shr    $0xc,%edx
f01024ae:	83 c4 10             	add    $0x10,%esp
f01024b1:	39 ca                	cmp    %ecx,%edx
f01024b3:	72 15                	jb     f01024ca <mem_init+0xf47>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024b5:	50                   	push   %eax
f01024b6:	68 a4 69 10 f0       	push   $0xf01069a4
f01024bb:	68 cb 04 00 00       	push   $0x4cb
f01024c0:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01024c5:	e8 76 db ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01024ca:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f01024cf:	39 c7                	cmp    %eax,%edi
f01024d1:	74 19                	je     f01024ec <mem_init+0xf69>
f01024d3:	68 41 72 10 f0       	push   $0xf0107241
f01024d8:	68 85 6f 10 f0       	push   $0xf0106f85
f01024dd:	68 cc 04 00 00       	push   $0x4cc
f01024e2:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01024e7:	e8 54 db ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f01024ec:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01024ef:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f01024f6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01024f9:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01024ff:	2b 05 a8 9e 2a f0    	sub    0xf02a9ea8,%eax
f0102505:	c1 f8 03             	sar    $0x3,%eax
f0102508:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010250b:	89 c2                	mov    %eax,%edx
f010250d:	c1 ea 0c             	shr    $0xc,%edx
f0102510:	39 d1                	cmp    %edx,%ecx
f0102512:	77 12                	ja     f0102526 <mem_init+0xfa3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102514:	50                   	push   %eax
f0102515:	68 a4 69 10 f0       	push   $0xf01069a4
f010251a:	6a 58                	push   $0x58
f010251c:	68 6b 6f 10 f0       	push   $0xf0106f6b
f0102521:	e8 1a db ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102526:	83 ec 04             	sub    $0x4,%esp
f0102529:	68 00 10 00 00       	push   $0x1000
f010252e:	68 ff 00 00 00       	push   $0xff
f0102533:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102538:	50                   	push   %eax
f0102539:	e8 2d 32 00 00       	call   f010576b <memset>
	page_free(pp0);
f010253e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102541:	89 3c 24             	mov    %edi,(%esp)
f0102544:	e8 c8 eb ff ff       	call   f0101111 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102549:	83 c4 0c             	add    $0xc,%esp
f010254c:	6a 01                	push   $0x1
f010254e:	6a 00                	push   $0x0
f0102550:	ff 35 a4 9e 2a f0    	pushl  0xf02a9ea4
f0102556:	e8 33 ec ff ff       	call   f010118e <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010255b:	89 fa                	mov    %edi,%edx
f010255d:	2b 15 a8 9e 2a f0    	sub    0xf02a9ea8,%edx
f0102563:	c1 fa 03             	sar    $0x3,%edx
f0102566:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102569:	89 d0                	mov    %edx,%eax
f010256b:	c1 e8 0c             	shr    $0xc,%eax
f010256e:	83 c4 10             	add    $0x10,%esp
f0102571:	3b 05 a0 9e 2a f0    	cmp    0xf02a9ea0,%eax
f0102577:	72 12                	jb     f010258b <mem_init+0x1008>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102579:	52                   	push   %edx
f010257a:	68 a4 69 10 f0       	push   $0xf01069a4
f010257f:	6a 58                	push   $0x58
f0102581:	68 6b 6f 10 f0       	push   $0xf0106f6b
f0102586:	e8 b5 da ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010258b:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102591:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102594:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010259a:	f6 00 01             	testb  $0x1,(%eax)
f010259d:	74 19                	je     f01025b8 <mem_init+0x1035>
f010259f:	68 59 72 10 f0       	push   $0xf0107259
f01025a4:	68 85 6f 10 f0       	push   $0xf0106f85
f01025a9:	68 d6 04 00 00       	push   $0x4d6
f01025ae:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01025b3:	e8 88 da ff ff       	call   f0100040 <_panic>
f01025b8:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01025bb:	39 d0                	cmp    %edx,%eax
f01025bd:	75 db                	jne    f010259a <mem_init+0x1017>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01025bf:	a1 a4 9e 2a f0       	mov    0xf02a9ea4,%eax
f01025c4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01025ca:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01025cd:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f01025d3:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01025d6:	89 0d 40 92 2a f0    	mov    %ecx,0xf02a9240

	// free the pages we took
	page_free(pp0);
f01025dc:	83 ec 0c             	sub    $0xc,%esp
f01025df:	50                   	push   %eax
f01025e0:	e8 2c eb ff ff       	call   f0101111 <page_free>
	page_free(pp1);
f01025e5:	89 1c 24             	mov    %ebx,(%esp)
f01025e8:	e8 24 eb ff ff       	call   f0101111 <page_free>
	page_free(pp2);
f01025ed:	89 34 24             	mov    %esi,(%esp)
f01025f0:	e8 1c eb ff ff       	call   f0101111 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f01025f5:	83 c4 08             	add    $0x8,%esp
f01025f8:	68 01 10 00 00       	push   $0x1001
f01025fd:	6a 00                	push   $0x0
f01025ff:	e8 16 ef ff ff       	call   f010151a <mmio_map_region>
f0102604:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102606:	83 c4 08             	add    $0x8,%esp
f0102609:	68 00 10 00 00       	push   $0x1000
f010260e:	6a 00                	push   $0x0
f0102610:	e8 05 ef ff ff       	call   f010151a <mmio_map_region>
f0102615:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f0102617:	8d 83 00 20 00 00    	lea    0x2000(%ebx),%eax
f010261d:	83 c4 10             	add    $0x10,%esp
f0102620:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102626:	76 07                	jbe    f010262f <mem_init+0x10ac>
f0102628:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f010262d:	76 19                	jbe    f0102648 <mem_init+0x10c5>
f010262f:	68 ac 79 10 f0       	push   $0xf01079ac
f0102634:	68 85 6f 10 f0       	push   $0xf0106f85
f0102639:	68 e6 04 00 00       	push   $0x4e6
f010263e:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102643:	e8 f8 d9 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f0102648:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
f010264e:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102654:	77 08                	ja     f010265e <mem_init+0x10db>
f0102656:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010265c:	77 19                	ja     f0102677 <mem_init+0x10f4>
f010265e:	68 d4 79 10 f0       	push   $0xf01079d4
f0102663:	68 85 6f 10 f0       	push   $0xf0106f85
f0102668:	68 e7 04 00 00       	push   $0x4e7
f010266d:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102672:	e8 c9 d9 ff ff       	call   f0100040 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102677:	89 da                	mov    %ebx,%edx
f0102679:	09 f2                	or     %esi,%edx
f010267b:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102681:	74 19                	je     f010269c <mem_init+0x1119>
f0102683:	68 fc 79 10 f0       	push   $0xf01079fc
f0102688:	68 85 6f 10 f0       	push   $0xf0106f85
f010268d:	68 e9 04 00 00       	push   $0x4e9
f0102692:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102697:	e8 a4 d9 ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8192 <= mm2);
f010269c:	39 c6                	cmp    %eax,%esi
f010269e:	73 19                	jae    f01026b9 <mem_init+0x1136>
f01026a0:	68 70 72 10 f0       	push   $0xf0107270
f01026a5:	68 85 6f 10 f0       	push   $0xf0106f85
f01026aa:	68 eb 04 00 00       	push   $0x4eb
f01026af:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01026b4:	e8 87 d9 ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01026b9:	8b 3d a4 9e 2a f0    	mov    0xf02a9ea4,%edi
f01026bf:	89 da                	mov    %ebx,%edx
f01026c1:	89 f8                	mov    %edi,%eax
f01026c3:	e8 bc e4 ff ff       	call   f0100b84 <check_va2pa>
f01026c8:	85 c0                	test   %eax,%eax
f01026ca:	74 19                	je     f01026e5 <mem_init+0x1162>
f01026cc:	68 24 7a 10 f0       	push   $0xf0107a24
f01026d1:	68 85 6f 10 f0       	push   $0xf0106f85
f01026d6:	68 ed 04 00 00       	push   $0x4ed
f01026db:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01026e0:	e8 5b d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01026e5:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f01026eb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01026ee:	89 c2                	mov    %eax,%edx
f01026f0:	89 f8                	mov    %edi,%eax
f01026f2:	e8 8d e4 ff ff       	call   f0100b84 <check_va2pa>
f01026f7:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01026fc:	74 19                	je     f0102717 <mem_init+0x1194>
f01026fe:	68 48 7a 10 f0       	push   $0xf0107a48
f0102703:	68 85 6f 10 f0       	push   $0xf0106f85
f0102708:	68 ee 04 00 00       	push   $0x4ee
f010270d:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102712:	e8 29 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102717:	89 f2                	mov    %esi,%edx
f0102719:	89 f8                	mov    %edi,%eax
f010271b:	e8 64 e4 ff ff       	call   f0100b84 <check_va2pa>
f0102720:	85 c0                	test   %eax,%eax
f0102722:	74 19                	je     f010273d <mem_init+0x11ba>
f0102724:	68 78 7a 10 f0       	push   $0xf0107a78
f0102729:	68 85 6f 10 f0       	push   $0xf0106f85
f010272e:	68 ef 04 00 00       	push   $0x4ef
f0102733:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102738:	e8 03 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f010273d:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102743:	89 f8                	mov    %edi,%eax
f0102745:	e8 3a e4 ff ff       	call   f0100b84 <check_va2pa>
f010274a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010274d:	74 19                	je     f0102768 <mem_init+0x11e5>
f010274f:	68 9c 7a 10 f0       	push   $0xf0107a9c
f0102754:	68 85 6f 10 f0       	push   $0xf0106f85
f0102759:	68 f0 04 00 00       	push   $0x4f0
f010275e:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102763:	e8 d8 d8 ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102768:	83 ec 04             	sub    $0x4,%esp
f010276b:	6a 00                	push   $0x0
f010276d:	53                   	push   %ebx
f010276e:	57                   	push   %edi
f010276f:	e8 1a ea ff ff       	call   f010118e <pgdir_walk>
f0102774:	83 c4 10             	add    $0x10,%esp
f0102777:	f6 00 1a             	testb  $0x1a,(%eax)
f010277a:	75 19                	jne    f0102795 <mem_init+0x1212>
f010277c:	68 c8 7a 10 f0       	push   $0xf0107ac8
f0102781:	68 85 6f 10 f0       	push   $0xf0106f85
f0102786:	68 f2 04 00 00       	push   $0x4f2
f010278b:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102790:	e8 ab d8 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102795:	83 ec 04             	sub    $0x4,%esp
f0102798:	6a 00                	push   $0x0
f010279a:	53                   	push   %ebx
f010279b:	ff 35 a4 9e 2a f0    	pushl  0xf02a9ea4
f01027a1:	e8 e8 e9 ff ff       	call   f010118e <pgdir_walk>
f01027a6:	8b 00                	mov    (%eax),%eax
f01027a8:	83 c4 10             	add    $0x10,%esp
f01027ab:	83 e0 04             	and    $0x4,%eax
f01027ae:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01027b1:	74 19                	je     f01027cc <mem_init+0x1249>
f01027b3:	68 0c 7b 10 f0       	push   $0xf0107b0c
f01027b8:	68 85 6f 10 f0       	push   $0xf0106f85
f01027bd:	68 f3 04 00 00       	push   $0x4f3
f01027c2:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01027c7:	e8 74 d8 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f01027cc:	83 ec 04             	sub    $0x4,%esp
f01027cf:	6a 00                	push   $0x0
f01027d1:	53                   	push   %ebx
f01027d2:	ff 35 a4 9e 2a f0    	pushl  0xf02a9ea4
f01027d8:	e8 b1 e9 ff ff       	call   f010118e <pgdir_walk>
f01027dd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f01027e3:	83 c4 0c             	add    $0xc,%esp
f01027e6:	6a 00                	push   $0x0
f01027e8:	ff 75 d4             	pushl  -0x2c(%ebp)
f01027eb:	ff 35 a4 9e 2a f0    	pushl  0xf02a9ea4
f01027f1:	e8 98 e9 ff ff       	call   f010118e <pgdir_walk>
f01027f6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f01027fc:	83 c4 0c             	add    $0xc,%esp
f01027ff:	6a 00                	push   $0x0
f0102801:	56                   	push   %esi
f0102802:	ff 35 a4 9e 2a f0    	pushl  0xf02a9ea4
f0102808:	e8 81 e9 ff ff       	call   f010118e <pgdir_walk>
f010280d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102813:	c7 04 24 82 72 10 f0 	movl   $0xf0107282,(%esp)
f010281a:	e8 72 11 00 00       	call   f0103991 <cprintf>
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f010281f:	a1 a8 9e 2a f0       	mov    0xf02a9ea8,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102824:	83 c4 10             	add    $0x10,%esp
f0102827:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010282c:	77 15                	ja     f0102843 <mem_init+0x12c0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010282e:	50                   	push   %eax
f010282f:	68 c8 69 10 f0       	push   $0xf01069c8
f0102834:	68 ca 00 00 00       	push   $0xca
f0102839:	68 5f 6f 10 f0       	push   $0xf0106f5f
f010283e:	e8 fd d7 ff ff       	call   f0100040 <_panic>
f0102843:	83 ec 08             	sub    $0x8,%esp
f0102846:	6a 04                	push   $0x4
f0102848:	05 00 00 00 10       	add    $0x10000000,%eax
f010284d:	50                   	push   %eax
f010284e:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102853:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102858:	a1 a4 9e 2a f0       	mov    0xf02a9ea4,%eax
f010285d:	e8 76 ea ff ff       	call   f01012d8 <boot_map_region>
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.

	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U);
f0102862:	a1 48 92 2a f0       	mov    0xf02a9248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102867:	83 c4 10             	add    $0x10,%esp
f010286a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010286f:	77 15                	ja     f0102886 <mem_init+0x1303>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102871:	50                   	push   %eax
f0102872:	68 c8 69 10 f0       	push   $0xf01069c8
f0102877:	68 d4 00 00 00       	push   $0xd4
f010287c:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102881:	e8 ba d7 ff ff       	call   f0100040 <_panic>
f0102886:	83 ec 08             	sub    $0x8,%esp
f0102889:	6a 04                	push   $0x4
f010288b:	05 00 00 00 10       	add    $0x10000000,%eax
f0102890:	50                   	push   %eax
f0102891:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102896:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f010289b:	a1 a4 9e 2a f0       	mov    0xf02a9ea4,%eax
f01028a0:	e8 33 ea ff ff       	call   f01012d8 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01028a5:	83 c4 10             	add    $0x10,%esp
f01028a8:	b8 00 80 11 f0       	mov    $0xf0118000,%eax
f01028ad:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01028b2:	77 15                	ja     f01028c9 <mem_init+0x1346>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01028b4:	50                   	push   %eax
f01028b5:	68 c8 69 10 f0       	push   $0xf01069c8
f01028ba:	68 e2 00 00 00       	push   $0xe2
f01028bf:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01028c4:	e8 77 d7 ff ff       	call   f0100040 <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f01028c9:	83 ec 08             	sub    $0x8,%esp
f01028cc:	6a 02                	push   $0x2
f01028ce:	68 00 80 11 00       	push   $0x118000
f01028d3:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01028d8:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01028dd:	a1 a4 9e 2a f0       	mov    0xf02a9ea4,%eax
f01028e2:	e8 f1 e9 ff ff       	call   f01012d8 <boot_map_region>
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, KERNBASE, ROUNDUP(~0 - KERNBASE, PGSIZE), 0, PTE_W);
f01028e7:	83 c4 08             	add    $0x8,%esp
f01028ea:	6a 02                	push   $0x2
f01028ec:	6a 00                	push   $0x0
f01028ee:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01028f3:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01028f8:	a1 a4 9e 2a f0       	mov    0xf02a9ea4,%eax
f01028fd:	e8 d6 e9 ff ff       	call   f01012d8 <boot_map_region>
f0102902:	c7 45 c4 00 b0 2a f0 	movl   $0xf02ab000,-0x3c(%ebp)
f0102909:	83 c4 10             	add    $0x10,%esp
f010290c:	bb 00 b0 2a f0       	mov    $0xf02ab000,%ebx
f0102911:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102916:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f010291c:	77 15                	ja     f0102933 <mem_init+0x13b0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010291e:	53                   	push   %ebx
f010291f:	68 c8 69 10 f0       	push   $0xf01069c8
f0102924:	68 26 01 00 00       	push   $0x126
f0102929:	68 5f 6f 10 f0       	push   $0xf0106f5f
f010292e:	e8 0d d7 ff ff       	call   f0100040 <_panic>

	uint32_t kstacktop_i;

	for (int i=0; i<NCPU; i++) {
		kstacktop_i = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
		boot_map_region(kern_pgdir, kstacktop_i - KSTKSIZE, KSTKSIZE, PADDR(&percpu_kstacks[i]), PTE_W );
f0102933:	83 ec 08             	sub    $0x8,%esp
f0102936:	6a 02                	push   $0x2
f0102938:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f010293e:	50                   	push   %eax
f010293f:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102944:	89 f2                	mov    %esi,%edx
f0102946:	a1 a4 9e 2a f0       	mov    0xf02a9ea4,%eax
f010294b:	e8 88 e9 ff ff       	call   f01012d8 <boot_map_region>
f0102950:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102956:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//
	// LAB 4: Your code here:

	uint32_t kstacktop_i;

	for (int i=0; i<NCPU; i++) {
f010295c:	83 c4 10             	add    $0x10,%esp
f010295f:	b8 00 b0 2e f0       	mov    $0xf02eb000,%eax
f0102964:	39 d8                	cmp    %ebx,%eax
f0102966:	75 ae                	jne    f0102916 <mem_init+0x1393>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102968:	8b 3d a4 9e 2a f0    	mov    0xf02a9ea4,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010296e:	a1 a0 9e 2a f0       	mov    0xf02a9ea0,%eax
f0102973:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102976:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f010297d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102982:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102985:	8b 35 a8 9e 2a f0    	mov    0xf02a9ea8,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010298b:	89 75 d0             	mov    %esi,-0x30(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010298e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102993:	eb 55                	jmp    f01029ea <mem_init+0x1467>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102995:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f010299b:	89 f8                	mov    %edi,%eax
f010299d:	e8 e2 e1 ff ff       	call   f0100b84 <check_va2pa>
f01029a2:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f01029a9:	77 15                	ja     f01029c0 <mem_init+0x143d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029ab:	56                   	push   %esi
f01029ac:	68 c8 69 10 f0       	push   $0xf01069c8
f01029b1:	68 07 04 00 00       	push   $0x407
f01029b6:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01029bb:	e8 80 d6 ff ff       	call   f0100040 <_panic>
f01029c0:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f01029c7:	39 c2                	cmp    %eax,%edx
f01029c9:	74 19                	je     f01029e4 <mem_init+0x1461>
f01029cb:	68 40 7b 10 f0       	push   $0xf0107b40
f01029d0:	68 85 6f 10 f0       	push   $0xf0106f85
f01029d5:	68 07 04 00 00       	push   $0x407
f01029da:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01029df:	e8 5c d6 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01029e4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01029ea:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01029ed:	77 a6                	ja     f0102995 <mem_init+0x1412>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01029ef:	8b 35 48 92 2a f0    	mov    0xf02a9248,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01029f5:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f01029f8:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f01029fd:	89 da                	mov    %ebx,%edx
f01029ff:	89 f8                	mov    %edi,%eax
f0102a01:	e8 7e e1 ff ff       	call   f0100b84 <check_va2pa>
f0102a06:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102a0d:	77 15                	ja     f0102a24 <mem_init+0x14a1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a0f:	56                   	push   %esi
f0102a10:	68 c8 69 10 f0       	push   $0xf01069c8
f0102a15:	68 0c 04 00 00       	push   $0x40c
f0102a1a:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102a1f:	e8 1c d6 ff ff       	call   f0100040 <_panic>
f0102a24:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f0102a2b:	39 d0                	cmp    %edx,%eax
f0102a2d:	74 19                	je     f0102a48 <mem_init+0x14c5>
f0102a2f:	68 74 7b 10 f0       	push   $0xf0107b74
f0102a34:	68 85 6f 10 f0       	push   $0xf0106f85
f0102a39:	68 0c 04 00 00       	push   $0x40c
f0102a3e:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102a43:	e8 f8 d5 ff ff       	call   f0100040 <_panic>
f0102a48:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102a4e:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102a54:	75 a7                	jne    f01029fd <mem_init+0x147a>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102a56:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0102a59:	c1 e6 0c             	shl    $0xc,%esi
f0102a5c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102a61:	eb 30                	jmp    f0102a93 <mem_init+0x1510>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102a63:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102a69:	89 f8                	mov    %edi,%eax
f0102a6b:	e8 14 e1 ff ff       	call   f0100b84 <check_va2pa>
f0102a70:	39 c3                	cmp    %eax,%ebx
f0102a72:	74 19                	je     f0102a8d <mem_init+0x150a>
f0102a74:	68 a8 7b 10 f0       	push   $0xf0107ba8
f0102a79:	68 85 6f 10 f0       	push   $0xf0106f85
f0102a7e:	68 10 04 00 00       	push   $0x410
f0102a83:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102a88:	e8 b3 d5 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102a8d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102a93:	39 f3                	cmp    %esi,%ebx
f0102a95:	72 cc                	jb     f0102a63 <mem_init+0x14e0>
f0102a97:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102a9c:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0102a9f:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0102aa2:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102aa5:	8d 88 00 80 00 00    	lea    0x8000(%eax),%ecx
f0102aab:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0102aae:	89 c3                	mov    %eax,%ebx
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102ab0:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102ab3:	05 00 80 00 20       	add    $0x20008000,%eax
f0102ab8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102abb:	89 da                	mov    %ebx,%edx
f0102abd:	89 f8                	mov    %edi,%eax
f0102abf:	e8 c0 e0 ff ff       	call   f0100b84 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ac4:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102aca:	77 15                	ja     f0102ae1 <mem_init+0x155e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102acc:	56                   	push   %esi
f0102acd:	68 c8 69 10 f0       	push   $0xf01069c8
f0102ad2:	68 18 04 00 00       	push   $0x418
f0102ad7:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102adc:	e8 5f d5 ff ff       	call   f0100040 <_panic>
f0102ae1:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102ae4:	8d 94 0b 00 b0 2a f0 	lea    -0xfd55000(%ebx,%ecx,1),%edx
f0102aeb:	39 d0                	cmp    %edx,%eax
f0102aed:	74 19                	je     f0102b08 <mem_init+0x1585>
f0102aef:	68 d0 7b 10 f0       	push   $0xf0107bd0
f0102af4:	68 85 6f 10 f0       	push   $0xf0106f85
f0102af9:	68 18 04 00 00       	push   $0x418
f0102afe:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102b03:	e8 38 d5 ff ff       	call   f0100040 <_panic>
f0102b08:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102b0e:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f0102b11:	75 a8                	jne    f0102abb <mem_init+0x1538>
f0102b13:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102b16:	8d 98 00 80 ff ff    	lea    -0x8000(%eax),%ebx
f0102b1c:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102b1f:	89 c6                	mov    %eax,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102b21:	89 da                	mov    %ebx,%edx
f0102b23:	89 f8                	mov    %edi,%eax
f0102b25:	e8 5a e0 ff ff       	call   f0100b84 <check_va2pa>
f0102b2a:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102b2d:	74 19                	je     f0102b48 <mem_init+0x15c5>
f0102b2f:	68 18 7c 10 f0       	push   $0xf0107c18
f0102b34:	68 85 6f 10 f0       	push   $0xf0106f85
f0102b39:	68 1a 04 00 00       	push   $0x41a
f0102b3e:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102b43:	e8 f8 d4 ff ff       	call   f0100040 <_panic>
f0102b48:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102b4e:	39 f3                	cmp    %esi,%ebx
f0102b50:	75 cf                	jne    f0102b21 <mem_init+0x159e>
f0102b52:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102b55:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f0102b5c:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f0102b63:	81 c6 00 80 00 00    	add    $0x8000,%esi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102b69:	b8 00 b0 2e f0       	mov    $0xf02eb000,%eax
f0102b6e:	39 f0                	cmp    %esi,%eax
f0102b70:	0f 85 2c ff ff ff    	jne    f0102aa2 <mem_init+0x151f>
f0102b76:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b7b:	eb 2a                	jmp    f0102ba7 <mem_init+0x1624>
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102b7d:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102b83:	83 fa 04             	cmp    $0x4,%edx
f0102b86:	77 1f                	ja     f0102ba7 <mem_init+0x1624>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f0102b88:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102b8c:	75 7e                	jne    f0102c0c <mem_init+0x1689>
f0102b8e:	68 9b 72 10 f0       	push   $0xf010729b
f0102b93:	68 85 6f 10 f0       	push   $0xf0106f85
f0102b98:	68 25 04 00 00       	push   $0x425
f0102b9d:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102ba2:	e8 99 d4 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102ba7:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102bac:	76 3f                	jbe    f0102bed <mem_init+0x166a>
				assert(pgdir[i] & PTE_P);
f0102bae:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102bb1:	f6 c2 01             	test   $0x1,%dl
f0102bb4:	75 19                	jne    f0102bcf <mem_init+0x164c>
f0102bb6:	68 9b 72 10 f0       	push   $0xf010729b
f0102bbb:	68 85 6f 10 f0       	push   $0xf0106f85
f0102bc0:	68 29 04 00 00       	push   $0x429
f0102bc5:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102bca:	e8 71 d4 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102bcf:	f6 c2 02             	test   $0x2,%dl
f0102bd2:	75 38                	jne    f0102c0c <mem_init+0x1689>
f0102bd4:	68 ac 72 10 f0       	push   $0xf01072ac
f0102bd9:	68 85 6f 10 f0       	push   $0xf0106f85
f0102bde:	68 2a 04 00 00       	push   $0x42a
f0102be3:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102be8:	e8 53 d4 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102bed:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102bf1:	74 19                	je     f0102c0c <mem_init+0x1689>
f0102bf3:	68 bd 72 10 f0       	push   $0xf01072bd
f0102bf8:	68 85 6f 10 f0       	push   $0xf0106f85
f0102bfd:	68 2c 04 00 00       	push   $0x42c
f0102c02:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102c07:	e8 34 d4 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102c0c:	83 c0 01             	add    $0x1,%eax
f0102c0f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102c14:	0f 86 63 ff ff ff    	jbe    f0102b7d <mem_init+0x15fa>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102c1a:	83 ec 0c             	sub    $0xc,%esp
f0102c1d:	68 3c 7c 10 f0       	push   $0xf0107c3c
f0102c22:	e8 6a 0d 00 00       	call   f0103991 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102c27:	a1 a4 9e 2a f0       	mov    0xf02a9ea4,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c2c:	83 c4 10             	add    $0x10,%esp
f0102c2f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c34:	77 15                	ja     f0102c4b <mem_init+0x16c8>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c36:	50                   	push   %eax
f0102c37:	68 c8 69 10 f0       	push   $0xf01069c8
f0102c3c:	68 fc 00 00 00       	push   $0xfc
f0102c41:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102c46:	e8 f5 d3 ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102c4b:	05 00 00 00 10       	add    $0x10000000,%eax
f0102c50:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102c53:	b8 00 00 00 00       	mov    $0x0,%eax
f0102c58:	e8 8b df ff ff       	call   f0100be8 <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102c5d:	0f 20 c0             	mov    %cr0,%eax
f0102c60:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102c63:	0d 23 00 05 80       	or     $0x80050023,%eax
f0102c68:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102c6b:	83 ec 0c             	sub    $0xc,%esp
f0102c6e:	6a 00                	push   $0x0
f0102c70:	e8 2b e4 ff ff       	call   f01010a0 <page_alloc>
f0102c75:	89 c3                	mov    %eax,%ebx
f0102c77:	83 c4 10             	add    $0x10,%esp
f0102c7a:	85 c0                	test   %eax,%eax
f0102c7c:	75 19                	jne    f0102c97 <mem_init+0x1714>
f0102c7e:	68 a7 70 10 f0       	push   $0xf01070a7
f0102c83:	68 85 6f 10 f0       	push   $0xf0106f85
f0102c88:	68 08 05 00 00       	push   $0x508
f0102c8d:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102c92:	e8 a9 d3 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102c97:	83 ec 0c             	sub    $0xc,%esp
f0102c9a:	6a 00                	push   $0x0
f0102c9c:	e8 ff e3 ff ff       	call   f01010a0 <page_alloc>
f0102ca1:	89 c7                	mov    %eax,%edi
f0102ca3:	83 c4 10             	add    $0x10,%esp
f0102ca6:	85 c0                	test   %eax,%eax
f0102ca8:	75 19                	jne    f0102cc3 <mem_init+0x1740>
f0102caa:	68 bd 70 10 f0       	push   $0xf01070bd
f0102caf:	68 85 6f 10 f0       	push   $0xf0106f85
f0102cb4:	68 09 05 00 00       	push   $0x509
f0102cb9:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102cbe:	e8 7d d3 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102cc3:	83 ec 0c             	sub    $0xc,%esp
f0102cc6:	6a 00                	push   $0x0
f0102cc8:	e8 d3 e3 ff ff       	call   f01010a0 <page_alloc>
f0102ccd:	89 c6                	mov    %eax,%esi
f0102ccf:	83 c4 10             	add    $0x10,%esp
f0102cd2:	85 c0                	test   %eax,%eax
f0102cd4:	75 19                	jne    f0102cef <mem_init+0x176c>
f0102cd6:	68 d3 70 10 f0       	push   $0xf01070d3
f0102cdb:	68 85 6f 10 f0       	push   $0xf0106f85
f0102ce0:	68 0a 05 00 00       	push   $0x50a
f0102ce5:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102cea:	e8 51 d3 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0102cef:	83 ec 0c             	sub    $0xc,%esp
f0102cf2:	53                   	push   %ebx
f0102cf3:	e8 19 e4 ff ff       	call   f0101111 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102cf8:	89 f8                	mov    %edi,%eax
f0102cfa:	2b 05 a8 9e 2a f0    	sub    0xf02a9ea8,%eax
f0102d00:	c1 f8 03             	sar    $0x3,%eax
f0102d03:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102d06:	89 c2                	mov    %eax,%edx
f0102d08:	c1 ea 0c             	shr    $0xc,%edx
f0102d0b:	83 c4 10             	add    $0x10,%esp
f0102d0e:	3b 15 a0 9e 2a f0    	cmp    0xf02a9ea0,%edx
f0102d14:	72 12                	jb     f0102d28 <mem_init+0x17a5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d16:	50                   	push   %eax
f0102d17:	68 a4 69 10 f0       	push   $0xf01069a4
f0102d1c:	6a 58                	push   $0x58
f0102d1e:	68 6b 6f 10 f0       	push   $0xf0106f6b
f0102d23:	e8 18 d3 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102d28:	83 ec 04             	sub    $0x4,%esp
f0102d2b:	68 00 10 00 00       	push   $0x1000
f0102d30:	6a 01                	push   $0x1
f0102d32:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102d37:	50                   	push   %eax
f0102d38:	e8 2e 2a 00 00       	call   f010576b <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102d3d:	89 f0                	mov    %esi,%eax
f0102d3f:	2b 05 a8 9e 2a f0    	sub    0xf02a9ea8,%eax
f0102d45:	c1 f8 03             	sar    $0x3,%eax
f0102d48:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102d4b:	89 c2                	mov    %eax,%edx
f0102d4d:	c1 ea 0c             	shr    $0xc,%edx
f0102d50:	83 c4 10             	add    $0x10,%esp
f0102d53:	3b 15 a0 9e 2a f0    	cmp    0xf02a9ea0,%edx
f0102d59:	72 12                	jb     f0102d6d <mem_init+0x17ea>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d5b:	50                   	push   %eax
f0102d5c:	68 a4 69 10 f0       	push   $0xf01069a4
f0102d61:	6a 58                	push   $0x58
f0102d63:	68 6b 6f 10 f0       	push   $0xf0106f6b
f0102d68:	e8 d3 d2 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102d6d:	83 ec 04             	sub    $0x4,%esp
f0102d70:	68 00 10 00 00       	push   $0x1000
f0102d75:	6a 02                	push   $0x2
f0102d77:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102d7c:	50                   	push   %eax
f0102d7d:	e8 e9 29 00 00       	call   f010576b <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102d82:	6a 02                	push   $0x2
f0102d84:	68 00 10 00 00       	push   $0x1000
f0102d89:	57                   	push   %edi
f0102d8a:	ff 35 a4 9e 2a f0    	pushl  0xf02a9ea4
f0102d90:	e8 fe e6 ff ff       	call   f0101493 <page_insert>
	assert(pp1->pp_ref == 1);
f0102d95:	83 c4 20             	add    $0x20,%esp
f0102d98:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102d9d:	74 19                	je     f0102db8 <mem_init+0x1835>
f0102d9f:	68 a4 71 10 f0       	push   $0xf01071a4
f0102da4:	68 85 6f 10 f0       	push   $0xf0106f85
f0102da9:	68 0f 05 00 00       	push   $0x50f
f0102dae:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102db3:	e8 88 d2 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102db8:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102dbf:	01 01 01 
f0102dc2:	74 19                	je     f0102ddd <mem_init+0x185a>
f0102dc4:	68 5c 7c 10 f0       	push   $0xf0107c5c
f0102dc9:	68 85 6f 10 f0       	push   $0xf0106f85
f0102dce:	68 10 05 00 00       	push   $0x510
f0102dd3:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102dd8:	e8 63 d2 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102ddd:	6a 02                	push   $0x2
f0102ddf:	68 00 10 00 00       	push   $0x1000
f0102de4:	56                   	push   %esi
f0102de5:	ff 35 a4 9e 2a f0    	pushl  0xf02a9ea4
f0102deb:	e8 a3 e6 ff ff       	call   f0101493 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102df0:	83 c4 10             	add    $0x10,%esp
f0102df3:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102dfa:	02 02 02 
f0102dfd:	74 19                	je     f0102e18 <mem_init+0x1895>
f0102dff:	68 80 7c 10 f0       	push   $0xf0107c80
f0102e04:	68 85 6f 10 f0       	push   $0xf0106f85
f0102e09:	68 12 05 00 00       	push   $0x512
f0102e0e:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102e13:	e8 28 d2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102e18:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102e1d:	74 19                	je     f0102e38 <mem_init+0x18b5>
f0102e1f:	68 c6 71 10 f0       	push   $0xf01071c6
f0102e24:	68 85 6f 10 f0       	push   $0xf0106f85
f0102e29:	68 13 05 00 00       	push   $0x513
f0102e2e:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102e33:	e8 08 d2 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102e38:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102e3d:	74 19                	je     f0102e58 <mem_init+0x18d5>
f0102e3f:	68 30 72 10 f0       	push   $0xf0107230
f0102e44:	68 85 6f 10 f0       	push   $0xf0106f85
f0102e49:	68 14 05 00 00       	push   $0x514
f0102e4e:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102e53:	e8 e8 d1 ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102e58:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102e5f:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102e62:	89 f0                	mov    %esi,%eax
f0102e64:	2b 05 a8 9e 2a f0    	sub    0xf02a9ea8,%eax
f0102e6a:	c1 f8 03             	sar    $0x3,%eax
f0102e6d:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102e70:	89 c2                	mov    %eax,%edx
f0102e72:	c1 ea 0c             	shr    $0xc,%edx
f0102e75:	3b 15 a0 9e 2a f0    	cmp    0xf02a9ea0,%edx
f0102e7b:	72 12                	jb     f0102e8f <mem_init+0x190c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102e7d:	50                   	push   %eax
f0102e7e:	68 a4 69 10 f0       	push   $0xf01069a4
f0102e83:	6a 58                	push   $0x58
f0102e85:	68 6b 6f 10 f0       	push   $0xf0106f6b
f0102e8a:	e8 b1 d1 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102e8f:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102e96:	03 03 03 
f0102e99:	74 19                	je     f0102eb4 <mem_init+0x1931>
f0102e9b:	68 a4 7c 10 f0       	push   $0xf0107ca4
f0102ea0:	68 85 6f 10 f0       	push   $0xf0106f85
f0102ea5:	68 16 05 00 00       	push   $0x516
f0102eaa:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102eaf:	e8 8c d1 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102eb4:	83 ec 08             	sub    $0x8,%esp
f0102eb7:	68 00 10 00 00       	push   $0x1000
f0102ebc:	ff 35 a4 9e 2a f0    	pushl  0xf02a9ea4
f0102ec2:	e8 7f e5 ff ff       	call   f0101446 <page_remove>
	assert(pp2->pp_ref == 0);
f0102ec7:	83 c4 10             	add    $0x10,%esp
f0102eca:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102ecf:	74 19                	je     f0102eea <mem_init+0x1967>
f0102ed1:	68 fe 71 10 f0       	push   $0xf01071fe
f0102ed6:	68 85 6f 10 f0       	push   $0xf0106f85
f0102edb:	68 18 05 00 00       	push   $0x518
f0102ee0:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102ee5:	e8 56 d1 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102eea:	8b 0d a4 9e 2a f0    	mov    0xf02a9ea4,%ecx
f0102ef0:	8b 11                	mov    (%ecx),%edx
f0102ef2:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102ef8:	89 d8                	mov    %ebx,%eax
f0102efa:	2b 05 a8 9e 2a f0    	sub    0xf02a9ea8,%eax
f0102f00:	c1 f8 03             	sar    $0x3,%eax
f0102f03:	c1 e0 0c             	shl    $0xc,%eax
f0102f06:	39 c2                	cmp    %eax,%edx
f0102f08:	74 19                	je     f0102f23 <mem_init+0x19a0>
f0102f0a:	68 2c 76 10 f0       	push   $0xf010762c
f0102f0f:	68 85 6f 10 f0       	push   $0xf0106f85
f0102f14:	68 1b 05 00 00       	push   $0x51b
f0102f19:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102f1e:	e8 1d d1 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102f23:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102f29:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102f2e:	74 19                	je     f0102f49 <mem_init+0x19c6>
f0102f30:	68 b5 71 10 f0       	push   $0xf01071b5
f0102f35:	68 85 6f 10 f0       	push   $0xf0106f85
f0102f3a:	68 1d 05 00 00       	push   $0x51d
f0102f3f:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102f44:	e8 f7 d0 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102f49:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102f4f:	83 ec 0c             	sub    $0xc,%esp
f0102f52:	53                   	push   %ebx
f0102f53:	e8 b9 e1 ff ff       	call   f0101111 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102f58:	c7 04 24 d0 7c 10 f0 	movl   $0xf0107cd0,(%esp)
f0102f5f:	e8 2d 0a 00 00       	call   f0103991 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102f64:	83 c4 10             	add    $0x10,%esp
f0102f67:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f6a:	5b                   	pop    %ebx
f0102f6b:	5e                   	pop    %esi
f0102f6c:	5f                   	pop    %edi
f0102f6d:	5d                   	pop    %ebp
f0102f6e:	c3                   	ret    

f0102f6f <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102f6f:	55                   	push   %ebp
f0102f70:	89 e5                	mov    %esp,%ebp
f0102f72:	57                   	push   %edi
f0102f73:	56                   	push   %esi
f0102f74:	53                   	push   %ebx
f0102f75:	83 ec 1c             	sub    $0x1c,%esp
f0102f78:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102f7b:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 3: Your code here.

	pte_t* pte;

	// for every page in this region
	for (void* i=ROUNDDOWN((void *)va, PGSIZE); i<ROUNDUP((void *)(va+len), PGSIZE); i+=PGSIZE) {
f0102f7e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f81:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102f86:	89 c3                	mov    %eax,%ebx
f0102f88:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0102f8b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f8e:	03 45 10             	add    0x10(%ebp),%eax
f0102f91:	05 ff 0f 00 00       	add    $0xfff,%eax
f0102f96:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102f9b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102f9e:	e9 9e 00 00 00       	jmp    f0103041 <user_mem_check+0xd2>

		if ((uintptr_t)i >= ULIM) {
f0102fa3:	89 5d e0             	mov    %ebx,-0x20(%ebp)
f0102fa6:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102fac:	76 18                	jbe    f0102fc6 <user_mem_check+0x57>
			user_mem_check_addr = (i == ROUNDDOWN((void *)va, PGSIZE))? (uintptr_t)va:(uintptr_t)i;
f0102fae:	3b 5d dc             	cmp    -0x24(%ebp),%ebx
f0102fb1:	89 d8                	mov    %ebx,%eax
f0102fb3:	0f 44 45 0c          	cmove  0xc(%ebp),%eax
f0102fb7:	a3 3c 92 2a f0       	mov    %eax,0xf02a923c
			return -E_FAULT;
f0102fbc:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102fc1:	e9 89 00 00 00       	jmp    f010304f <user_mem_check+0xe0>
		}

		//  get this page
		pte = pgdir_walk(env->env_pgdir, i, 0);
f0102fc6:	83 ec 04             	sub    $0x4,%esp
f0102fc9:	6a 00                	push   $0x0
f0102fcb:	53                   	push   %ebx
f0102fcc:	ff 77 60             	pushl  0x60(%edi)
f0102fcf:	e8 ba e1 ff ff       	call   f010118e <pgdir_walk>

		if (pte == NULL || (uint32_t)(*pte) == 0) {
f0102fd4:	83 c4 10             	add    $0x10,%esp
f0102fd7:	85 c0                	test   %eax,%eax
f0102fd9:	74 06                	je     f0102fe1 <user_mem_check+0x72>
f0102fdb:	8b 10                	mov    (%eax),%edx
f0102fdd:	85 d2                	test   %edx,%edx
f0102fdf:	75 2b                	jne    f010300c <user_mem_check+0x9d>
			user_mem_check_addr = (i == ROUNDDOWN((void *)va, PGSIZE))? (uintptr_t)va:(uintptr_t)i;
f0102fe1:	3b 5d dc             	cmp    -0x24(%ebp),%ebx
f0102fe4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0102fe7:	0f 44 4d 0c          	cmove  0xc(%ebp),%ecx
f0102feb:	89 0d 3c 92 2a f0    	mov    %ecx,0xf02a923c
			cprintf("[-] page [0x%x] error, %d, %d\n", (uint32_t)(*pte), ((uint32_t)(*pte) & perm), perm);
f0102ff1:	8b 00                	mov    (%eax),%eax
f0102ff3:	56                   	push   %esi
f0102ff4:	21 c6                	and    %eax,%esi
f0102ff6:	56                   	push   %esi
f0102ff7:	50                   	push   %eax
f0102ff8:	68 fc 7c 10 f0       	push   $0xf0107cfc
f0102ffd:	e8 8f 09 00 00       	call   f0103991 <cprintf>
			return -E_FAULT;
f0103002:	83 c4 10             	add    $0x10,%esp
f0103005:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010300a:	eb 43                	jmp    f010304f <user_mem_check+0xe0>
		}

		// perm wrong
		if (((uint32_t)(*pte) & perm) != perm) {
f010300c:	89 d0                	mov    %edx,%eax
f010300e:	21 f0                	and    %esi,%eax
f0103010:	39 c6                	cmp    %eax,%esi
f0103012:	74 27                	je     f010303b <user_mem_check+0xcc>
			// if happens at first page, we return va instead of ROUNDDOWN(va, PGSIZE)
			// just to make it more precise 
			user_mem_check_addr = (i == ROUNDDOWN((void *)va, PGSIZE))? (uintptr_t)va:(uintptr_t)i;
f0103014:	3b 5d dc             	cmp    -0x24(%ebp),%ebx
f0103017:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010301a:	0f 44 4d 0c          	cmove  0xc(%ebp),%ecx
f010301e:	89 0d 3c 92 2a f0    	mov    %ecx,0xf02a923c
			cprintf("[-] page [0x%x] perf error, %d, %d\n", (uint32_t)(*pte), ((uint32_t)(*pte) & perm), perm);
f0103024:	56                   	push   %esi
f0103025:	50                   	push   %eax
f0103026:	52                   	push   %edx
f0103027:	68 1c 7d 10 f0       	push   $0xf0107d1c
f010302c:	e8 60 09 00 00       	call   f0103991 <cprintf>
			return -E_FAULT;
f0103031:	83 c4 10             	add    $0x10,%esp
f0103034:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103039:	eb 14                	jmp    f010304f <user_mem_check+0xe0>
	// LAB 3: Your code here.

	pte_t* pte;

	// for every page in this region
	for (void* i=ROUNDDOWN((void *)va, PGSIZE); i<ROUNDUP((void *)(va+len), PGSIZE); i+=PGSIZE) {
f010303b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103041:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0103044:	0f 82 59 ff ff ff    	jb     f0102fa3 <user_mem_check+0x34>
			return -E_FAULT;
		}

	}

	return 0;
f010304a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010304f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103052:	5b                   	pop    %ebx
f0103053:	5e                   	pop    %esi
f0103054:	5f                   	pop    %edi
f0103055:	5d                   	pop    %ebp
f0103056:	c3                   	ret    

f0103057 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0103057:	55                   	push   %ebp
f0103058:	89 e5                	mov    %esp,%ebp
f010305a:	53                   	push   %ebx
f010305b:	83 ec 04             	sub    $0x4,%esp
f010305e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0103061:	8b 45 14             	mov    0x14(%ebp),%eax
f0103064:	83 c8 04             	or     $0x4,%eax
f0103067:	50                   	push   %eax
f0103068:	ff 75 10             	pushl  0x10(%ebp)
f010306b:	ff 75 0c             	pushl  0xc(%ebp)
f010306e:	53                   	push   %ebx
f010306f:	e8 fb fe ff ff       	call   f0102f6f <user_mem_check>
f0103074:	83 c4 10             	add    $0x10,%esp
f0103077:	85 c0                	test   %eax,%eax
f0103079:	79 21                	jns    f010309c <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f010307b:	83 ec 04             	sub    $0x4,%esp
f010307e:	ff 35 3c 92 2a f0    	pushl  0xf02a923c
f0103084:	ff 73 48             	pushl  0x48(%ebx)
f0103087:	68 40 7d 10 f0       	push   $0xf0107d40
f010308c:	e8 00 09 00 00       	call   f0103991 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0103091:	89 1c 24             	mov    %ebx,(%esp)
f0103094:	e8 e1 05 00 00       	call   f010367a <env_destroy>
f0103099:	83 c4 10             	add    $0x10,%esp
	}
}
f010309c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010309f:	c9                   	leave  
f01030a0:	c3                   	ret    

f01030a1 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f01030a1:	55                   	push   %ebp
f01030a2:	89 e5                	mov    %esp,%ebp
f01030a4:	57                   	push   %edi
f01030a5:	56                   	push   %esi
f01030a6:	53                   	push   %ebx
f01030a7:	83 ec 0c             	sub    $0xc,%esp
f01030aa:	89 c7                	mov    %eax,%edi
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)

	for (void* i=ROUNDDOWN(va, PGSIZE); i<ROUNDUP(va+len, PGSIZE); i += PGSIZE) {
f01030ac:	89 d3                	mov    %edx,%ebx
f01030ae:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f01030b4:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f01030bb:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
f01030c1:	eb 56                	jmp    f0103119 <region_alloc+0x78>

		struct PageInfo* pp = page_alloc(ALLOC_ZERO);
f01030c3:	83 ec 0c             	sub    $0xc,%esp
f01030c6:	6a 01                	push   $0x1
f01030c8:	e8 d3 df ff ff       	call   f01010a0 <page_alloc>
		if (pp == 0) {
f01030cd:	83 c4 10             	add    $0x10,%esp
f01030d0:	85 c0                	test   %eax,%eax
f01030d2:	75 17                	jne    f01030eb <region_alloc+0x4a>
			panic("region_alloc: page_alloc return 0");
f01030d4:	83 ec 04             	sub    $0x4,%esp
f01030d7:	68 78 7d 10 f0       	push   $0xf0107d78
f01030dc:	68 2d 01 00 00       	push   $0x12d
f01030e1:	68 3c 7e 10 f0       	push   $0xf0107e3c
f01030e6:	e8 55 cf ff ff       	call   f0100040 <_panic>
		}

		int err = page_insert(e->env_pgdir, pp, i, PTE_U | PTE_W);
f01030eb:	6a 06                	push   $0x6
f01030ed:	53                   	push   %ebx
f01030ee:	50                   	push   %eax
f01030ef:	ff 77 60             	pushl  0x60(%edi)
f01030f2:	e8 9c e3 ff ff       	call   f0101493 <page_insert>
		if (err < 0) {
f01030f7:	83 c4 10             	add    $0x10,%esp
f01030fa:	85 c0                	test   %eax,%eax
f01030fc:	79 15                	jns    f0103113 <region_alloc+0x72>
			panic("region_alloc: page_insert failed: %e", err);
f01030fe:	50                   	push   %eax
f01030ff:	68 9c 7d 10 f0       	push   $0xf0107d9c
f0103104:	68 32 01 00 00       	push   $0x132
f0103109:	68 3c 7e 10 f0       	push   $0xf0107e3c
f010310e:	e8 2d cf ff ff       	call   f0100040 <_panic>
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)

	for (void* i=ROUNDDOWN(va, PGSIZE); i<ROUNDUP(va+len, PGSIZE); i += PGSIZE) {
f0103113:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103119:	39 f3                	cmp    %esi,%ebx
f010311b:	72 a6                	jb     f01030c3 <region_alloc+0x22>
		}

	}

	
}
f010311d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103120:	5b                   	pop    %ebx
f0103121:	5e                   	pop    %esi
f0103122:	5f                   	pop    %edi
f0103123:	5d                   	pop    %ebp
f0103124:	c3                   	ret    

f0103125 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0103125:	55                   	push   %ebp
f0103126:	89 e5                	mov    %esp,%ebp
f0103128:	56                   	push   %esi
f0103129:	53                   	push   %ebx
f010312a:	8b 45 08             	mov    0x8(%ebp),%eax
f010312d:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103130:	85 c0                	test   %eax,%eax
f0103132:	75 1a                	jne    f010314e <envid2env+0x29>
		*env_store = curenv;
f0103134:	e8 55 2c 00 00       	call   f0105d8e <cpunum>
f0103139:	6b c0 74             	imul   $0x74,%eax,%eax
f010313c:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
f0103142:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103145:	89 01                	mov    %eax,(%ecx)
		return 0;
f0103147:	b8 00 00 00 00       	mov    $0x0,%eax
f010314c:	eb 70                	jmp    f01031be <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f010314e:	89 c3                	mov    %eax,%ebx
f0103150:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0103156:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0103159:	03 1d 48 92 2a f0    	add    0xf02a9248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f010315f:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103163:	74 05                	je     f010316a <envid2env+0x45>
f0103165:	3b 43 48             	cmp    0x48(%ebx),%eax
f0103168:	74 10                	je     f010317a <envid2env+0x55>
		*env_store = 0;
f010316a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010316d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103173:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103178:	eb 44                	jmp    f01031be <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f010317a:	84 d2                	test   %dl,%dl
f010317c:	74 36                	je     f01031b4 <envid2env+0x8f>
f010317e:	e8 0b 2c 00 00       	call   f0105d8e <cpunum>
f0103183:	6b c0 74             	imul   $0x74,%eax,%eax
f0103186:	3b 98 28 a0 2a f0    	cmp    -0xfd55fd8(%eax),%ebx
f010318c:	74 26                	je     f01031b4 <envid2env+0x8f>
f010318e:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0103191:	e8 f8 2b 00 00       	call   f0105d8e <cpunum>
f0103196:	6b c0 74             	imul   $0x74,%eax,%eax
f0103199:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
f010319f:	3b 70 48             	cmp    0x48(%eax),%esi
f01031a2:	74 10                	je     f01031b4 <envid2env+0x8f>
		*env_store = 0;
f01031a4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01031a7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01031ad:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01031b2:	eb 0a                	jmp    f01031be <envid2env+0x99>
	}

	*env_store = e;
f01031b4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01031b7:	89 18                	mov    %ebx,(%eax)
	return 0;
f01031b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01031be:	5b                   	pop    %ebx
f01031bf:	5e                   	pop    %esi
f01031c0:	5d                   	pop    %ebp
f01031c1:	c3                   	ret    

f01031c2 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f01031c2:	55                   	push   %ebp
f01031c3:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f01031c5:	b8 20 23 12 f0       	mov    $0xf0122320,%eax
f01031ca:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f01031cd:	b8 23 00 00 00       	mov    $0x23,%eax
f01031d2:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f01031d4:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f01031d6:	b8 10 00 00 00       	mov    $0x10,%eax
f01031db:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f01031dd:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f01031df:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f01031e1:	ea e8 31 10 f0 08 00 	ljmp   $0x8,$0xf01031e8
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f01031e8:	b8 00 00 00 00       	mov    $0x0,%eax
f01031ed:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f01031f0:	5d                   	pop    %ebp
f01031f1:	c3                   	ret    

f01031f2 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f01031f2:	55                   	push   %ebp
f01031f3:	89 e5                	mov    %esp,%ebp
f01031f5:	56                   	push   %esi
f01031f6:	53                   	push   %ebx
	// LAB 3: Your code here.

	// make sure env_free_list point to envs[0]
	// so that the first env_alloc() will return envs[0]
	for (int i=NENV-1; i>=0; i--) {
		envs[i].env_id = 0;
f01031f7:	8b 35 48 92 2a f0    	mov    0xf02a9248,%esi
f01031fd:	8b 15 4c 92 2a f0    	mov    0xf02a924c,%edx
f0103203:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0103209:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f010320c:	89 c1                	mov    %eax,%ecx
f010320e:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0103215:	89 50 44             	mov    %edx,0x44(%eax)
f0103218:	83 e8 7c             	sub    $0x7c,%eax
		env_free_list = &envs[i];
f010321b:	89 ca                	mov    %ecx,%edx
	// Set up envs array
	// LAB 3: Your code here.

	// make sure env_free_list point to envs[0]
	// so that the first env_alloc() will return envs[0]
	for (int i=NENV-1; i>=0; i--) {
f010321d:	39 d8                	cmp    %ebx,%eax
f010321f:	75 eb                	jne    f010320c <env_init+0x1a>
f0103221:	89 35 4c 92 2a f0    	mov    %esi,0xf02a924c
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
	}

	// Per-CPU part of the initialization
	env_init_percpu();
f0103227:	e8 96 ff ff ff       	call   f01031c2 <env_init_percpu>
}
f010322c:	5b                   	pop    %ebx
f010322d:	5e                   	pop    %esi
f010322e:	5d                   	pop    %ebp
f010322f:	c3                   	ret    

f0103230 <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103230:	55                   	push   %ebp
f0103231:	89 e5                	mov    %esp,%ebp
f0103233:	56                   	push   %esi
f0103234:	53                   	push   %ebx
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0103235:	8b 1d 4c 92 2a f0    	mov    0xf02a924c,%ebx
f010323b:	85 db                	test   %ebx,%ebx
f010323d:	0f 84 2f 01 00 00    	je     f0103372 <env_alloc+0x142>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103243:	83 ec 0c             	sub    $0xc,%esp
f0103246:	6a 01                	push   $0x1
f0103248:	e8 53 de ff ff       	call   f01010a0 <page_alloc>
f010324d:	89 c6                	mov    %eax,%esi
f010324f:	83 c4 10             	add    $0x10,%esp
f0103252:	85 c0                	test   %eax,%eax
f0103254:	0f 84 1f 01 00 00    	je     f0103379 <env_alloc+0x149>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010325a:	2b 05 a8 9e 2a f0    	sub    0xf02a9ea8,%eax
f0103260:	c1 f8 03             	sar    $0x3,%eax
f0103263:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103266:	89 c2                	mov    %eax,%edx
f0103268:	c1 ea 0c             	shr    $0xc,%edx
f010326b:	3b 15 a0 9e 2a f0    	cmp    0xf02a9ea0,%edx
f0103271:	72 12                	jb     f0103285 <env_alloc+0x55>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103273:	50                   	push   %eax
f0103274:	68 a4 69 10 f0       	push   $0xf01069a4
f0103279:	6a 58                	push   $0x58
f010327b:	68 6b 6f 10 f0       	push   $0xf0106f6b
f0103280:	e8 bb cd ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0103285:	2d 00 00 00 10       	sub    $0x10000000,%eax
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.

	e->env_pgdir = page2kva(p);
f010328a:	89 43 60             	mov    %eax,0x60(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f010328d:	83 ec 04             	sub    $0x4,%esp
f0103290:	68 00 10 00 00       	push   $0x1000
f0103295:	ff 35 a4 9e 2a f0    	pushl  0xf02a9ea4
f010329b:	50                   	push   %eax
f010329c:	e8 7f 25 00 00       	call   f0105820 <memcpy>
	p->pp_ref++;
f01032a1:	66 83 46 04 01       	addw   $0x1,0x4(%esi)

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01032a6:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01032a9:	83 c4 10             	add    $0x10,%esp
f01032ac:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01032b1:	77 15                	ja     f01032c8 <env_alloc+0x98>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032b3:	50                   	push   %eax
f01032b4:	68 c8 69 10 f0       	push   $0xf01069c8
f01032b9:	68 c8 00 00 00       	push   $0xc8
f01032be:	68 3c 7e 10 f0       	push   $0xf0107e3c
f01032c3:	e8 78 cd ff ff       	call   f0100040 <_panic>
f01032c8:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01032ce:	83 ca 05             	or     $0x5,%edx
f01032d1:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01032d7:	8b 43 48             	mov    0x48(%ebx),%eax
f01032da:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01032df:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f01032e4:	ba 00 10 00 00       	mov    $0x1000,%edx
f01032e9:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f01032ec:	89 da                	mov    %ebx,%edx
f01032ee:	2b 15 48 92 2a f0    	sub    0xf02a9248,%edx
f01032f4:	c1 fa 02             	sar    $0x2,%edx
f01032f7:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f01032fd:	09 d0                	or     %edx,%eax
f01032ff:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103302:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103305:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103308:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f010330f:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103316:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010331d:	83 ec 04             	sub    $0x4,%esp
f0103320:	6a 44                	push   $0x44
f0103322:	6a 00                	push   $0x0
f0103324:	53                   	push   %ebx
f0103325:	e8 41 24 00 00       	call   f010576b <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f010332a:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103330:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103336:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f010333c:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103343:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.

	e->env_tf.tf_eflags |= FL_IF;
f0103349:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103350:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103357:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f010335b:	8b 43 44             	mov    0x44(%ebx),%eax
f010335e:	a3 4c 92 2a f0       	mov    %eax,0xf02a924c
	*newenv_store = e;
f0103363:	8b 45 08             	mov    0x8(%ebp),%eax
f0103366:	89 18                	mov    %ebx,(%eax)

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
f0103368:	83 c4 10             	add    $0x10,%esp
f010336b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103370:	eb 0c                	jmp    f010337e <env_alloc+0x14e>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103372:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103377:	eb 05                	jmp    f010337e <env_alloc+0x14e>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103379:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f010337e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103381:	5b                   	pop    %ebx
f0103382:	5e                   	pop    %esi
f0103383:	5d                   	pop    %ebp
f0103384:	c3                   	ret    

f0103385 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103385:	55                   	push   %ebp
f0103386:	89 e5                	mov    %esp,%ebp
f0103388:	57                   	push   %edi
f0103389:	56                   	push   %esi
f010338a:	53                   	push   %ebx
f010338b:	83 ec 34             	sub    $0x34,%esp
f010338e:	8b 7d 08             	mov    0x8(%ebp),%edi
	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.

	struct Env *newenv_store;
	envid_t parent_id = 0;
	int err = env_alloc(&newenv_store, 0);
f0103391:	6a 00                	push   $0x0
f0103393:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103396:	50                   	push   %eax
f0103397:	e8 94 fe ff ff       	call   f0103230 <env_alloc>
	if (err < 0) 
f010339c:	83 c4 10             	add    $0x10,%esp
f010339f:	85 c0                	test   %eax,%eax
f01033a1:	79 15                	jns    f01033b8 <env_create+0x33>
		panic("env_create: env_alloc failed: %e", err);
f01033a3:	50                   	push   %eax
f01033a4:	68 c4 7d 10 f0       	push   $0xf0107dc4
f01033a9:	68 bc 01 00 00       	push   $0x1bc
f01033ae:	68 3c 7e 10 f0       	push   $0xf0107e3c
f01033b3:	e8 88 cc ff ff       	call   f0100040 <_panic>
	load_icode(newenv_store, binary);
f01033b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01033bb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// LAB 3: Your code here.

	// read and check ELF property, inspired by boot/main.c
	struct Elf* elf = (struct Elf*) binary;

	if (elf->e_magic != ELF_MAGIC)
f01033be:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f01033c4:	74 17                	je     f01033dd <env_create+0x58>
		panic("load_icode: not a valid ELF format file");
f01033c6:	83 ec 04             	sub    $0x4,%esp
f01033c9:	68 e8 7d 10 f0       	push   $0xf0107de8
f01033ce:	68 75 01 00 00       	push   $0x175
f01033d3:	68 3c 7e 10 f0       	push   $0xf0107e3c
f01033d8:	e8 63 cc ff ff       	call   f0100040 <_panic>

	struct Proghdr *ph, *eph;
	
	ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f01033dd:	89 fb                	mov    %edi,%ebx
f01033df:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + elf->e_phnum;
f01033e2:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f01033e6:	c1 e6 05             	shl    $0x5,%esi
f01033e9:	01 de                	add    %ebx,%esi

	// we are setting user virtual address, but now we are in kernel mode
	// load env pgdir to cr3
	lcr3(PADDR(e->env_pgdir));	
f01033eb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01033ee:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01033f1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01033f6:	77 15                	ja     f010340d <env_create+0x88>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033f8:	50                   	push   %eax
f01033f9:	68 c8 69 10 f0       	push   $0xf01069c8
f01033fe:	68 7e 01 00 00       	push   $0x17e
f0103403:	68 3c 7e 10 f0       	push   $0xf0107e3c
f0103408:	e8 33 cc ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010340d:	05 00 00 00 10       	add    $0x10000000,%eax
f0103412:	0f 22 d8             	mov    %eax,%cr3
f0103415:	eb 59                	jmp    f0103470 <env_create+0xeb>

	// for every segment
	for (; ph < eph; ph++) {

		// only load this type of segment
		if (ph->p_type == ELF_PROG_LOAD) {
f0103417:	83 3b 01             	cmpl   $0x1,(%ebx)
f010341a:	75 51                	jne    f010346d <env_create+0xe8>

			if (ph->p_filesz > ph->p_memsz)
f010341c:	8b 4b 14             	mov    0x14(%ebx),%ecx
f010341f:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f0103422:	76 17                	jbe    f010343b <env_create+0xb6>
				panic("load_icode: not a valid ELF format file (2)");
f0103424:	83 ec 04             	sub    $0x4,%esp
f0103427:	68 10 7e 10 f0       	push   $0xf0107e10
f010342c:	68 87 01 00 00       	push   $0x187
f0103431:	68 3c 7e 10 f0       	push   $0xf0107e3c
f0103436:	e8 05 cc ff ff       	call   f0100040 <_panic>

			// allocate and map each segment
			// this function needs e->env_pgdir
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f010343b:	8b 53 08             	mov    0x8(%ebx),%edx
f010343e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103441:	e8 5b fc ff ff       	call   f01030a1 <region_alloc>

			// all clear to 0
			memset((void *)ph->p_va, 0, ph->p_memsz);
f0103446:	83 ec 04             	sub    $0x4,%esp
f0103449:	ff 73 14             	pushl  0x14(%ebx)
f010344c:	6a 00                	push   $0x0
f010344e:	ff 73 08             	pushl  0x8(%ebx)
f0103451:	e8 15 23 00 00       	call   f010576b <memset>

			// copy [binary + ph->p_offset, binary + ph->p_offset + ph->p_filesz) to ph->p_va
			// binary is of type uint8_t *, remember not use elf cuz its type is struct Elf*
			// making elf + ph->p_offset pointing to nowhere
			memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f0103456:	83 c4 0c             	add    $0xc,%esp
f0103459:	ff 73 10             	pushl  0x10(%ebx)
f010345c:	89 f8                	mov    %edi,%eax
f010345e:	03 43 04             	add    0x4(%ebx),%eax
f0103461:	50                   	push   %eax
f0103462:	ff 73 08             	pushl  0x8(%ebx)
f0103465:	e8 b6 23 00 00       	call   f0105820 <memcpy>
f010346a:	83 c4 10             	add    $0x10,%esp
	// we are setting user virtual address, but now we are in kernel mode
	// load env pgdir to cr3
	lcr3(PADDR(e->env_pgdir));	

	// for every segment
	for (; ph < eph; ph++) {
f010346d:	83 c3 20             	add    $0x20,%ebx
f0103470:	39 de                	cmp    %ebx,%esi
f0103472:	77 a3                	ja     f0103417 <env_create+0x92>
		}

	}

	// load program entry point to eip
	e->env_tf.tf_eip = elf->e_entry;
f0103474:	8b 47 18             	mov    0x18(%edi),%eax
f0103477:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010347a:	89 47 30             	mov    %eax,0x30(%edi)
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.

	region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f010347d:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103482:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103487:	89 f8                	mov    %edi,%eax
f0103489:	e8 13 fc ff ff       	call   f01030a1 <region_alloc>

	// after loading things from elf, restore cr3 in kernel
	lcr3(PADDR(kern_pgdir));
f010348e:	a1 a4 9e 2a f0       	mov    0xf02a9ea4,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103493:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103498:	77 15                	ja     f01034af <env_create+0x12a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010349a:	50                   	push   %eax
f010349b:	68 c8 69 10 f0       	push   $0xf01069c8
f01034a0:	68 a5 01 00 00       	push   $0x1a5
f01034a5:	68 3c 7e 10 f0       	push   $0xf0107e3c
f01034aa:	e8 91 cb ff ff       	call   f0100040 <_panic>
f01034af:	05 00 00 00 10       	add    $0x10000000,%eax
f01034b4:	0f 22 d8             	mov    %eax,%cr3
	envid_t parent_id = 0;
	int err = env_alloc(&newenv_store, 0);
	if (err < 0) 
		panic("env_create: env_alloc failed: %e", err);
	load_icode(newenv_store, binary);
	newenv_store->env_type = type;
f01034b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01034ba:	8b 55 0c             	mov    0xc(%ebp),%edx
f01034bd:	89 50 50             	mov    %edx,0x50(%eax)

	if (type == ENV_TYPE_FS) {
f01034c0:	83 fa 01             	cmp    $0x1,%edx
f01034c3:	75 07                	jne    f01034cc <env_create+0x147>
        newenv_store->env_tf.tf_eflags |= FL_IOPL_MASK;
f01034c5:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
    }

}
f01034cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01034cf:	5b                   	pop    %ebx
f01034d0:	5e                   	pop    %esi
f01034d1:	5f                   	pop    %edi
f01034d2:	5d                   	pop    %ebp
f01034d3:	c3                   	ret    

f01034d4 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01034d4:	55                   	push   %ebp
f01034d5:	89 e5                	mov    %esp,%ebp
f01034d7:	57                   	push   %edi
f01034d8:	56                   	push   %esi
f01034d9:	53                   	push   %ebx
f01034da:	83 ec 1c             	sub    $0x1c,%esp
f01034dd:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01034e0:	e8 a9 28 00 00       	call   f0105d8e <cpunum>
f01034e5:	6b c0 74             	imul   $0x74,%eax,%eax
f01034e8:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01034ef:	39 b8 28 a0 2a f0    	cmp    %edi,-0xfd55fd8(%eax)
f01034f5:	75 30                	jne    f0103527 <env_free+0x53>
		lcr3(PADDR(kern_pgdir));
f01034f7:	a1 a4 9e 2a f0       	mov    0xf02a9ea4,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01034fc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103501:	77 15                	ja     f0103518 <env_free+0x44>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103503:	50                   	push   %eax
f0103504:	68 c8 69 10 f0       	push   $0xf01069c8
f0103509:	68 d4 01 00 00       	push   $0x1d4
f010350e:	68 3c 7e 10 f0       	push   $0xf0107e3c
f0103513:	e8 28 cb ff ff       	call   f0100040 <_panic>
f0103518:	05 00 00 00 10       	add    $0x10000000,%eax
f010351d:	0f 22 d8             	mov    %eax,%cr3
f0103520:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103527:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010352a:	89 d0                	mov    %edx,%eax
f010352c:	c1 e0 02             	shl    $0x2,%eax
f010352f:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103532:	8b 47 60             	mov    0x60(%edi),%eax
f0103535:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0103538:	f7 c6 01 00 00 00    	test   $0x1,%esi
f010353e:	0f 84 a8 00 00 00    	je     f01035ec <env_free+0x118>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103544:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010354a:	89 f0                	mov    %esi,%eax
f010354c:	c1 e8 0c             	shr    $0xc,%eax
f010354f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103552:	39 05 a0 9e 2a f0    	cmp    %eax,0xf02a9ea0
f0103558:	77 15                	ja     f010356f <env_free+0x9b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010355a:	56                   	push   %esi
f010355b:	68 a4 69 10 f0       	push   $0xf01069a4
f0103560:	68 e3 01 00 00       	push   $0x1e3
f0103565:	68 3c 7e 10 f0       	push   $0xf0107e3c
f010356a:	e8 d1 ca ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010356f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103572:	c1 e0 16             	shl    $0x16,%eax
f0103575:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103578:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f010357d:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103584:	01 
f0103585:	74 17                	je     f010359e <env_free+0xca>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103587:	83 ec 08             	sub    $0x8,%esp
f010358a:	89 d8                	mov    %ebx,%eax
f010358c:	c1 e0 0c             	shl    $0xc,%eax
f010358f:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103592:	50                   	push   %eax
f0103593:	ff 77 60             	pushl  0x60(%edi)
f0103596:	e8 ab de ff ff       	call   f0101446 <page_remove>
f010359b:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010359e:	83 c3 01             	add    $0x1,%ebx
f01035a1:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01035a7:	75 d4                	jne    f010357d <env_free+0xa9>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01035a9:	8b 47 60             	mov    0x60(%edi),%eax
f01035ac:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01035af:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01035b6:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01035b9:	3b 05 a0 9e 2a f0    	cmp    0xf02a9ea0,%eax
f01035bf:	72 14                	jb     f01035d5 <env_free+0x101>
		panic("pa2page called with invalid pa");
f01035c1:	83 ec 04             	sub    $0x4,%esp
f01035c4:	68 d4 74 10 f0       	push   $0xf01074d4
f01035c9:	6a 51                	push   $0x51
f01035cb:	68 6b 6f 10 f0       	push   $0xf0106f6b
f01035d0:	e8 6b ca ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f01035d5:	83 ec 0c             	sub    $0xc,%esp
f01035d8:	a1 a8 9e 2a f0       	mov    0xf02a9ea8,%eax
f01035dd:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01035e0:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f01035e3:	50                   	push   %eax
f01035e4:	e8 7e db ff ff       	call   f0101167 <page_decref>
f01035e9:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01035ec:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f01035f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01035f3:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f01035f8:	0f 85 29 ff ff ff    	jne    f0103527 <env_free+0x53>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01035fe:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103601:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103606:	77 15                	ja     f010361d <env_free+0x149>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103608:	50                   	push   %eax
f0103609:	68 c8 69 10 f0       	push   $0xf01069c8
f010360e:	68 f1 01 00 00       	push   $0x1f1
f0103613:	68 3c 7e 10 f0       	push   $0xf0107e3c
f0103618:	e8 23 ca ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f010361d:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103624:	05 00 00 00 10       	add    $0x10000000,%eax
f0103629:	c1 e8 0c             	shr    $0xc,%eax
f010362c:	3b 05 a0 9e 2a f0    	cmp    0xf02a9ea0,%eax
f0103632:	72 14                	jb     f0103648 <env_free+0x174>
		panic("pa2page called with invalid pa");
f0103634:	83 ec 04             	sub    $0x4,%esp
f0103637:	68 d4 74 10 f0       	push   $0xf01074d4
f010363c:	6a 51                	push   $0x51
f010363e:	68 6b 6f 10 f0       	push   $0xf0106f6b
f0103643:	e8 f8 c9 ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f0103648:	83 ec 0c             	sub    $0xc,%esp
f010364b:	8b 15 a8 9e 2a f0    	mov    0xf02a9ea8,%edx
f0103651:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103654:	50                   	push   %eax
f0103655:	e8 0d db ff ff       	call   f0101167 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f010365a:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103661:	a1 4c 92 2a f0       	mov    0xf02a924c,%eax
f0103666:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103669:	89 3d 4c 92 2a f0    	mov    %edi,0xf02a924c
}
f010366f:	83 c4 10             	add    $0x10,%esp
f0103672:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103675:	5b                   	pop    %ebx
f0103676:	5e                   	pop    %esi
f0103677:	5f                   	pop    %edi
f0103678:	5d                   	pop    %ebp
f0103679:	c3                   	ret    

f010367a <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f010367a:	55                   	push   %ebp
f010367b:	89 e5                	mov    %esp,%ebp
f010367d:	53                   	push   %ebx
f010367e:	83 ec 04             	sub    $0x4,%esp
f0103681:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103684:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103688:	75 19                	jne    f01036a3 <env_destroy+0x29>
f010368a:	e8 ff 26 00 00       	call   f0105d8e <cpunum>
f010368f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103692:	3b 98 28 a0 2a f0    	cmp    -0xfd55fd8(%eax),%ebx
f0103698:	74 09                	je     f01036a3 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f010369a:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f01036a1:	eb 33                	jmp    f01036d6 <env_destroy+0x5c>
	}

	env_free(e);
f01036a3:	83 ec 0c             	sub    $0xc,%esp
f01036a6:	53                   	push   %ebx
f01036a7:	e8 28 fe ff ff       	call   f01034d4 <env_free>

	if (curenv == e) {
f01036ac:	e8 dd 26 00 00       	call   f0105d8e <cpunum>
f01036b1:	6b c0 74             	imul   $0x74,%eax,%eax
f01036b4:	83 c4 10             	add    $0x10,%esp
f01036b7:	3b 98 28 a0 2a f0    	cmp    -0xfd55fd8(%eax),%ebx
f01036bd:	75 17                	jne    f01036d6 <env_destroy+0x5c>
		curenv = NULL;
f01036bf:	e8 ca 26 00 00       	call   f0105d8e <cpunum>
f01036c4:	6b c0 74             	imul   $0x74,%eax,%eax
f01036c7:	c7 80 28 a0 2a f0 00 	movl   $0x0,-0xfd55fd8(%eax)
f01036ce:	00 00 00 
		sched_yield();
f01036d1:	e8 02 0f 00 00       	call   f01045d8 <sched_yield>
	}
}
f01036d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01036d9:	c9                   	leave  
f01036da:	c3                   	ret    

f01036db <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01036db:	55                   	push   %ebp
f01036dc:	89 e5                	mov    %esp,%ebp
f01036de:	53                   	push   %ebx
f01036df:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f01036e2:	e8 a7 26 00 00       	call   f0105d8e <cpunum>
f01036e7:	6b c0 74             	imul   $0x74,%eax,%eax
f01036ea:	8b 98 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%ebx
f01036f0:	e8 99 26 00 00       	call   f0105d8e <cpunum>
f01036f5:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f01036f8:	8b 65 08             	mov    0x8(%ebp),%esp
f01036fb:	61                   	popa   
f01036fc:	07                   	pop    %es
f01036fd:	1f                   	pop    %ds
f01036fe:	83 c4 08             	add    $0x8,%esp
f0103701:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103702:	83 ec 04             	sub    $0x4,%esp
f0103705:	68 47 7e 10 f0       	push   $0xf0107e47
f010370a:	68 28 02 00 00       	push   $0x228
f010370f:	68 3c 7e 10 f0       	push   $0xf0107e3c
f0103714:	e8 27 c9 ff ff       	call   f0100040 <_panic>

f0103719 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103719:	55                   	push   %ebp
f010371a:	89 e5                	mov    %esp,%ebp
f010371c:	53                   	push   %ebx
f010371d:	83 ec 04             	sub    $0x4,%esp
f0103720:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

	// context switch
	if (curenv != e) {
f0103723:	e8 66 26 00 00       	call   f0105d8e <cpunum>
f0103728:	6b c0 74             	imul   $0x74,%eax,%eax
f010372b:	39 98 28 a0 2a f0    	cmp    %ebx,-0xfd55fd8(%eax)
f0103731:	74 3a                	je     f010376d <env_run+0x54>

		if (curenv != NULL && curenv->env_status == ENV_RUNNING)
f0103733:	e8 56 26 00 00       	call   f0105d8e <cpunum>
f0103738:	6b c0 74             	imul   $0x74,%eax,%eax
f010373b:	83 b8 28 a0 2a f0 00 	cmpl   $0x0,-0xfd55fd8(%eax)
f0103742:	74 29                	je     f010376d <env_run+0x54>
f0103744:	e8 45 26 00 00       	call   f0105d8e <cpunum>
f0103749:	6b c0 74             	imul   $0x74,%eax,%eax
f010374c:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
f0103752:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103756:	75 15                	jne    f010376d <env_run+0x54>
			curenv->env_status = ENV_RUNNABLE;
f0103758:	e8 31 26 00 00       	call   f0105d8e <cpunum>
f010375d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103760:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
f0103766:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
			
	}
	
	curenv = e;
f010376d:	e8 1c 26 00 00       	call   f0105d8e <cpunum>
f0103772:	6b c0 74             	imul   $0x74,%eax,%eax
f0103775:	89 98 28 a0 2a f0    	mov    %ebx,-0xfd55fd8(%eax)
	curenv->env_status = ENV_RUNNING;
f010377b:	e8 0e 26 00 00       	call   f0105d8e <cpunum>
f0103780:	6b c0 74             	imul   $0x74,%eax,%eax
f0103783:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
f0103789:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f0103790:	e8 f9 25 00 00       	call   f0105d8e <cpunum>
f0103795:	6b c0 74             	imul   $0x74,%eax,%eax
f0103798:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
f010379e:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3(PADDR(curenv->env_pgdir));
f01037a2:	e8 e7 25 00 00       	call   f0105d8e <cpunum>
f01037a7:	6b c0 74             	imul   $0x74,%eax,%eax
f01037aa:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
f01037b0:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01037b3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01037b8:	77 15                	ja     f01037cf <env_run+0xb6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01037ba:	50                   	push   %eax
f01037bb:	68 c8 69 10 f0       	push   $0xf01069c8
f01037c0:	68 52 02 00 00       	push   $0x252
f01037c5:	68 3c 7e 10 f0       	push   $0xf0107e3c
f01037ca:	e8 71 c8 ff ff       	call   f0100040 <_panic>
f01037cf:	05 00 00 00 10       	add    $0x10000000,%eax
f01037d4:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01037d7:	83 ec 0c             	sub    $0xc,%esp
f01037da:	68 c0 23 12 f0       	push   $0xf01223c0
f01037df:	e8 b5 28 00 00       	call   f0106099 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01037e4:	f3 90                	pause  

	unlock_kernel();

	// iret to execute entry point stored in tf_eip
	// cprintf("[?] try to execute at entry point: %x\n", curenv->env_tf.tf_eip);
	env_pop_tf(&curenv->env_tf);
f01037e6:	e8 a3 25 00 00       	call   f0105d8e <cpunum>
f01037eb:	83 c4 04             	add    $0x4,%esp
f01037ee:	6b c0 74             	imul   $0x74,%eax,%eax
f01037f1:	ff b0 28 a0 2a f0    	pushl  -0xfd55fd8(%eax)
f01037f7:	e8 df fe ff ff       	call   f01036db <env_pop_tf>

f01037fc <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01037fc:	55                   	push   %ebp
f01037fd:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01037ff:	ba 70 00 00 00       	mov    $0x70,%edx
f0103804:	8b 45 08             	mov    0x8(%ebp),%eax
f0103807:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103808:	ba 71 00 00 00       	mov    $0x71,%edx
f010380d:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f010380e:	0f b6 c0             	movzbl %al,%eax
}
f0103811:	5d                   	pop    %ebp
f0103812:	c3                   	ret    

f0103813 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103813:	55                   	push   %ebp
f0103814:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103816:	ba 70 00 00 00       	mov    $0x70,%edx
f010381b:	8b 45 08             	mov    0x8(%ebp),%eax
f010381e:	ee                   	out    %al,(%dx)
f010381f:	ba 71 00 00 00       	mov    $0x71,%edx
f0103824:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103827:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103828:	5d                   	pop    %ebp
f0103829:	c3                   	ret    

f010382a <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f010382a:	55                   	push   %ebp
f010382b:	89 e5                	mov    %esp,%ebp
f010382d:	56                   	push   %esi
f010382e:	53                   	push   %ebx
f010382f:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103832:	66 a3 a8 23 12 f0    	mov    %ax,0xf01223a8
	if (!didinit)
f0103838:	80 3d 50 92 2a f0 00 	cmpb   $0x0,0xf02a9250
f010383f:	74 5a                	je     f010389b <irq_setmask_8259A+0x71>
f0103841:	89 c6                	mov    %eax,%esi
f0103843:	ba 21 00 00 00       	mov    $0x21,%edx
f0103848:	ee                   	out    %al,(%dx)
f0103849:	66 c1 e8 08          	shr    $0x8,%ax
f010384d:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103852:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f0103853:	83 ec 0c             	sub    $0xc,%esp
f0103856:	68 53 7e 10 f0       	push   $0xf0107e53
f010385b:	e8 31 01 00 00       	call   f0103991 <cprintf>
f0103860:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103863:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103868:	0f b7 f6             	movzwl %si,%esi
f010386b:	f7 d6                	not    %esi
f010386d:	0f a3 de             	bt     %ebx,%esi
f0103870:	73 11                	jae    f0103883 <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f0103872:	83 ec 08             	sub    $0x8,%esp
f0103875:	53                   	push   %ebx
f0103876:	68 eb 82 10 f0       	push   $0xf01082eb
f010387b:	e8 11 01 00 00       	call   f0103991 <cprintf>
f0103880:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103883:	83 c3 01             	add    $0x1,%ebx
f0103886:	83 fb 10             	cmp    $0x10,%ebx
f0103889:	75 e2                	jne    f010386d <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f010388b:	83 ec 0c             	sub    $0xc,%esp
f010388e:	68 99 72 10 f0       	push   $0xf0107299
f0103893:	e8 f9 00 00 00       	call   f0103991 <cprintf>
f0103898:	83 c4 10             	add    $0x10,%esp
}
f010389b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010389e:	5b                   	pop    %ebx
f010389f:	5e                   	pop    %esi
f01038a0:	5d                   	pop    %ebp
f01038a1:	c3                   	ret    

f01038a2 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f01038a2:	c6 05 50 92 2a f0 01 	movb   $0x1,0xf02a9250
f01038a9:	ba 21 00 00 00       	mov    $0x21,%edx
f01038ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01038b3:	ee                   	out    %al,(%dx)
f01038b4:	ba a1 00 00 00       	mov    $0xa1,%edx
f01038b9:	ee                   	out    %al,(%dx)
f01038ba:	ba 20 00 00 00       	mov    $0x20,%edx
f01038bf:	b8 11 00 00 00       	mov    $0x11,%eax
f01038c4:	ee                   	out    %al,(%dx)
f01038c5:	ba 21 00 00 00       	mov    $0x21,%edx
f01038ca:	b8 20 00 00 00       	mov    $0x20,%eax
f01038cf:	ee                   	out    %al,(%dx)
f01038d0:	b8 04 00 00 00       	mov    $0x4,%eax
f01038d5:	ee                   	out    %al,(%dx)
f01038d6:	b8 03 00 00 00       	mov    $0x3,%eax
f01038db:	ee                   	out    %al,(%dx)
f01038dc:	ba a0 00 00 00       	mov    $0xa0,%edx
f01038e1:	b8 11 00 00 00       	mov    $0x11,%eax
f01038e6:	ee                   	out    %al,(%dx)
f01038e7:	ba a1 00 00 00       	mov    $0xa1,%edx
f01038ec:	b8 28 00 00 00       	mov    $0x28,%eax
f01038f1:	ee                   	out    %al,(%dx)
f01038f2:	b8 02 00 00 00       	mov    $0x2,%eax
f01038f7:	ee                   	out    %al,(%dx)
f01038f8:	b8 01 00 00 00       	mov    $0x1,%eax
f01038fd:	ee                   	out    %al,(%dx)
f01038fe:	ba 20 00 00 00       	mov    $0x20,%edx
f0103903:	b8 68 00 00 00       	mov    $0x68,%eax
f0103908:	ee                   	out    %al,(%dx)
f0103909:	b8 0a 00 00 00       	mov    $0xa,%eax
f010390e:	ee                   	out    %al,(%dx)
f010390f:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103914:	b8 68 00 00 00       	mov    $0x68,%eax
f0103919:	ee                   	out    %al,(%dx)
f010391a:	b8 0a 00 00 00       	mov    $0xa,%eax
f010391f:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103920:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f0103927:	66 83 f8 ff          	cmp    $0xffff,%ax
f010392b:	74 13                	je     f0103940 <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f010392d:	55                   	push   %ebp
f010392e:	89 e5                	mov    %esp,%ebp
f0103930:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0103933:	0f b7 c0             	movzwl %ax,%eax
f0103936:	50                   	push   %eax
f0103937:	e8 ee fe ff ff       	call   f010382a <irq_setmask_8259A>
f010393c:	83 c4 10             	add    $0x10,%esp
}
f010393f:	c9                   	leave  
f0103940:	f3 c3                	repz ret 

f0103942 <irq_eoi>:
	cprintf("\n");
}

void
irq_eoi(void)
{
f0103942:	55                   	push   %ebp
f0103943:	89 e5                	mov    %esp,%ebp
f0103945:	ba 20 00 00 00       	mov    $0x20,%edx
f010394a:	b8 20 00 00 00       	mov    $0x20,%eax
f010394f:	ee                   	out    %al,(%dx)
f0103950:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103955:	ee                   	out    %al,(%dx)
	//   s: specific
	//   e: end-of-interrupt
	// xxx: specific interrupt line
	outb(IO_PIC1, 0x20);
	outb(IO_PIC2, 0x20);
}
f0103956:	5d                   	pop    %ebp
f0103957:	c3                   	ret    

f0103958 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103958:	55                   	push   %ebp
f0103959:	89 e5                	mov    %esp,%ebp
f010395b:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f010395e:	ff 75 08             	pushl  0x8(%ebp)
f0103961:	e8 35 ce ff ff       	call   f010079b <cputchar>
	*cnt++;
}
f0103966:	83 c4 10             	add    $0x10,%esp
f0103969:	c9                   	leave  
f010396a:	c3                   	ret    

f010396b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010396b:	55                   	push   %ebp
f010396c:	89 e5                	mov    %esp,%ebp
f010396e:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103971:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103978:	ff 75 0c             	pushl  0xc(%ebp)
f010397b:	ff 75 08             	pushl  0x8(%ebp)
f010397e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103981:	50                   	push   %eax
f0103982:	68 58 39 10 f0       	push   $0xf0103958
f0103987:	e8 5b 17 00 00       	call   f01050e7 <vprintfmt>
	return cnt;
}
f010398c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010398f:	c9                   	leave  
f0103990:	c3                   	ret    

f0103991 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103991:	55                   	push   %ebp
f0103992:	89 e5                	mov    %esp,%ebp
f0103994:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103997:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f010399a:	50                   	push   %eax
f010399b:	ff 75 08             	pushl  0x8(%ebp)
f010399e:	e8 c8 ff ff ff       	call   f010396b <vcprintf>
	va_end(ap);

	return cnt;
}
f01039a3:	c9                   	leave  
f01039a4:	c3                   	ret    

f01039a5 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f01039a5:	55                   	push   %ebp
f01039a6:	89 e5                	mov    %esp,%ebp
f01039a8:	57                   	push   %edi
f01039a9:	56                   	push   %esi
f01039aa:	53                   	push   %ebx
f01039ab:	83 ec 0c             	sub    $0xc,%esp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = (uintptr_t) percpu_kstacks[cpunum()];
f01039ae:	e8 db 23 00 00       	call   f0105d8e <cpunum>
f01039b3:	89 c3                	mov    %eax,%ebx
f01039b5:	e8 d4 23 00 00       	call   f0105d8e <cpunum>
f01039ba:	6b db 74             	imul   $0x74,%ebx,%ebx
f01039bd:	c1 e0 0f             	shl    $0xf,%eax
f01039c0:	05 00 b0 2a f0       	add    $0xf02ab000,%eax
f01039c5:	89 83 30 a0 2a f0    	mov    %eax,-0xfd55fd0(%ebx)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f01039cb:	e8 be 23 00 00       	call   f0105d8e <cpunum>
f01039d0:	6b c0 74             	imul   $0x74,%eax,%eax
f01039d3:	66 c7 80 34 a0 2a f0 	movw   $0x10,-0xfd55fcc(%eax)
f01039da:	10 00 
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f01039dc:	e8 ad 23 00 00       	call   f0105d8e <cpunum>
f01039e1:	6b c0 74             	imul   $0x74,%eax,%eax
f01039e4:	66 c7 80 92 a0 2a f0 	movw   $0x68,-0xfd55f6e(%eax)
f01039eb:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + cpunum()] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
f01039ed:	e8 9c 23 00 00       	call   f0105d8e <cpunum>
f01039f2:	8d 58 05             	lea    0x5(%eax),%ebx
f01039f5:	e8 94 23 00 00       	call   f0105d8e <cpunum>
f01039fa:	89 c7                	mov    %eax,%edi
f01039fc:	e8 8d 23 00 00       	call   f0105d8e <cpunum>
f0103a01:	89 c6                	mov    %eax,%esi
f0103a03:	e8 86 23 00 00       	call   f0105d8e <cpunum>
f0103a08:	66 c7 04 dd 40 23 12 	movw   $0x67,-0xfeddcc0(,%ebx,8)
f0103a0f:	f0 67 00 
f0103a12:	6b ff 74             	imul   $0x74,%edi,%edi
f0103a15:	81 c7 2c a0 2a f0    	add    $0xf02aa02c,%edi
f0103a1b:	66 89 3c dd 42 23 12 	mov    %di,-0xfeddcbe(,%ebx,8)
f0103a22:	f0 
f0103a23:	6b d6 74             	imul   $0x74,%esi,%edx
f0103a26:	81 c2 2c a0 2a f0    	add    $0xf02aa02c,%edx
f0103a2c:	c1 ea 10             	shr    $0x10,%edx
f0103a2f:	88 14 dd 44 23 12 f0 	mov    %dl,-0xfeddcbc(,%ebx,8)
f0103a36:	c6 04 dd 45 23 12 f0 	movb   $0x99,-0xfeddcbb(,%ebx,8)
f0103a3d:	99 
f0103a3e:	c6 04 dd 46 23 12 f0 	movb   $0x40,-0xfeddcba(,%ebx,8)
f0103a45:	40 
f0103a46:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a49:	05 2c a0 2a f0       	add    $0xf02aa02c,%eax
f0103a4e:	c1 e8 18             	shr    $0x18,%eax
f0103a51:	88 04 dd 47 23 12 f0 	mov    %al,-0xfeddcb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + cpunum()].sd_s = 0;
f0103a58:	e8 31 23 00 00       	call   f0105d8e <cpunum>
f0103a5d:	80 24 c5 6d 23 12 f0 	andb   $0xef,-0xfeddc93(,%eax,8)
f0103a64:	ef 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + (cpunum() << 3));
f0103a65:	e8 24 23 00 00       	call   f0105d8e <cpunum>
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f0103a6a:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
f0103a71:	0f 00 d8             	ltr    %ax
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f0103a74:	b8 ac 23 12 f0       	mov    $0xf01223ac,%eax
f0103a79:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f0103a7c:	83 c4 0c             	add    $0xc,%esp
f0103a7f:	5b                   	pop    %ebx
f0103a80:	5e                   	pop    %esi
f0103a81:	5f                   	pop    %edi
f0103a82:	5d                   	pop    %ebp
f0103a83:	c3                   	ret    

f0103a84 <trap_init>:
}


void
trap_init(void)
{
f0103a84:	55                   	push   %ebp
f0103a85:	89 e5                	mov    %esp,%ebp
f0103a87:	83 ec 08             	sub    $0x8,%esp
	void _IRQ_SPURIOUS_handler();
	void _IRQ_IDE_handler();
	void _IRQ_ERROR_handler();

	// SETGATE(gate, istrap, sel, off, dpl);
	SETGATE(idt[T_DIVIDE], 0, GD_KT, _T_DIVIDE_handler, 0);
f0103a8a:	b8 66 44 10 f0       	mov    $0xf0104466,%eax
f0103a8f:	66 a3 60 92 2a f0    	mov    %ax,0xf02a9260
f0103a95:	66 c7 05 62 92 2a f0 	movw   $0x8,0xf02a9262
f0103a9c:	08 00 
f0103a9e:	c6 05 64 92 2a f0 00 	movb   $0x0,0xf02a9264
f0103aa5:	c6 05 65 92 2a f0 8e 	movb   $0x8e,0xf02a9265
f0103aac:	c1 e8 10             	shr    $0x10,%eax
f0103aaf:	66 a3 66 92 2a f0    	mov    %ax,0xf02a9266
	SETGATE(idt[T_DEBUG], 0, GD_KT, _T_DEBUG_handler, 0);
f0103ab5:	b8 70 44 10 f0       	mov    $0xf0104470,%eax
f0103aba:	66 a3 68 92 2a f0    	mov    %ax,0xf02a9268
f0103ac0:	66 c7 05 6a 92 2a f0 	movw   $0x8,0xf02a926a
f0103ac7:	08 00 
f0103ac9:	c6 05 6c 92 2a f0 00 	movb   $0x0,0xf02a926c
f0103ad0:	c6 05 6d 92 2a f0 8e 	movb   $0x8e,0xf02a926d
f0103ad7:	c1 e8 10             	shr    $0x10,%eax
f0103ada:	66 a3 6e 92 2a f0    	mov    %ax,0xf02a926e
	SETGATE(idt[T_NMI], 0, GD_KT, _T_NMI_handler, 0);
f0103ae0:	b8 76 44 10 f0       	mov    $0xf0104476,%eax
f0103ae5:	66 a3 70 92 2a f0    	mov    %ax,0xf02a9270
f0103aeb:	66 c7 05 72 92 2a f0 	movw   $0x8,0xf02a9272
f0103af2:	08 00 
f0103af4:	c6 05 74 92 2a f0 00 	movb   $0x0,0xf02a9274
f0103afb:	c6 05 75 92 2a f0 8e 	movb   $0x8e,0xf02a9275
f0103b02:	c1 e8 10             	shr    $0x10,%eax
f0103b05:	66 a3 76 92 2a f0    	mov    %ax,0xf02a9276
	SETGATE(idt[T_BRKPT], 0, GD_KT, _T_BRKPT_handler, 3);
f0103b0b:	b8 7c 44 10 f0       	mov    $0xf010447c,%eax
f0103b10:	66 a3 78 92 2a f0    	mov    %ax,0xf02a9278
f0103b16:	66 c7 05 7a 92 2a f0 	movw   $0x8,0xf02a927a
f0103b1d:	08 00 
f0103b1f:	c6 05 7c 92 2a f0 00 	movb   $0x0,0xf02a927c
f0103b26:	c6 05 7d 92 2a f0 ee 	movb   $0xee,0xf02a927d
f0103b2d:	c1 e8 10             	shr    $0x10,%eax
f0103b30:	66 a3 7e 92 2a f0    	mov    %ax,0xf02a927e
	SETGATE(idt[T_OFLOW], 0, GD_KT, _T_OFLOW_handler, 0);
f0103b36:	b8 82 44 10 f0       	mov    $0xf0104482,%eax
f0103b3b:	66 a3 80 92 2a f0    	mov    %ax,0xf02a9280
f0103b41:	66 c7 05 82 92 2a f0 	movw   $0x8,0xf02a9282
f0103b48:	08 00 
f0103b4a:	c6 05 84 92 2a f0 00 	movb   $0x0,0xf02a9284
f0103b51:	c6 05 85 92 2a f0 8e 	movb   $0x8e,0xf02a9285
f0103b58:	c1 e8 10             	shr    $0x10,%eax
f0103b5b:	66 a3 86 92 2a f0    	mov    %ax,0xf02a9286
	SETGATE(idt[T_BOUND], 0, GD_KT, _T_BOUND_handler, 0);
f0103b61:	b8 88 44 10 f0       	mov    $0xf0104488,%eax
f0103b66:	66 a3 88 92 2a f0    	mov    %ax,0xf02a9288
f0103b6c:	66 c7 05 8a 92 2a f0 	movw   $0x8,0xf02a928a
f0103b73:	08 00 
f0103b75:	c6 05 8c 92 2a f0 00 	movb   $0x0,0xf02a928c
f0103b7c:	c6 05 8d 92 2a f0 8e 	movb   $0x8e,0xf02a928d
f0103b83:	c1 e8 10             	shr    $0x10,%eax
f0103b86:	66 a3 8e 92 2a f0    	mov    %ax,0xf02a928e
	SETGATE(idt[T_ILLOP], 0, GD_KT, _T_ILLOP_handler, 0);
f0103b8c:	b8 8e 44 10 f0       	mov    $0xf010448e,%eax
f0103b91:	66 a3 90 92 2a f0    	mov    %ax,0xf02a9290
f0103b97:	66 c7 05 92 92 2a f0 	movw   $0x8,0xf02a9292
f0103b9e:	08 00 
f0103ba0:	c6 05 94 92 2a f0 00 	movb   $0x0,0xf02a9294
f0103ba7:	c6 05 95 92 2a f0 8e 	movb   $0x8e,0xf02a9295
f0103bae:	c1 e8 10             	shr    $0x10,%eax
f0103bb1:	66 a3 96 92 2a f0    	mov    %ax,0xf02a9296
	SETGATE(idt[T_DEVICE], 0, GD_KT, _T_DEVICE_handler, 0);
f0103bb7:	b8 94 44 10 f0       	mov    $0xf0104494,%eax
f0103bbc:	66 a3 98 92 2a f0    	mov    %ax,0xf02a9298
f0103bc2:	66 c7 05 9a 92 2a f0 	movw   $0x8,0xf02a929a
f0103bc9:	08 00 
f0103bcb:	c6 05 9c 92 2a f0 00 	movb   $0x0,0xf02a929c
f0103bd2:	c6 05 9d 92 2a f0 8e 	movb   $0x8e,0xf02a929d
f0103bd9:	c1 e8 10             	shr    $0x10,%eax
f0103bdc:	66 a3 9e 92 2a f0    	mov    %ax,0xf02a929e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, _T_DBLFLT_handler, 0);
f0103be2:	b8 9a 44 10 f0       	mov    $0xf010449a,%eax
f0103be7:	66 a3 a0 92 2a f0    	mov    %ax,0xf02a92a0
f0103bed:	66 c7 05 a2 92 2a f0 	movw   $0x8,0xf02a92a2
f0103bf4:	08 00 
f0103bf6:	c6 05 a4 92 2a f0 00 	movb   $0x0,0xf02a92a4
f0103bfd:	c6 05 a5 92 2a f0 8e 	movb   $0x8e,0xf02a92a5
f0103c04:	c1 e8 10             	shr    $0x10,%eax
f0103c07:	66 a3 a6 92 2a f0    	mov    %ax,0xf02a92a6
	SETGATE(idt[T_TSS], 0, GD_KT, _T_TSS_handler, 0);
f0103c0d:	b8 9e 44 10 f0       	mov    $0xf010449e,%eax
f0103c12:	66 a3 b0 92 2a f0    	mov    %ax,0xf02a92b0
f0103c18:	66 c7 05 b2 92 2a f0 	movw   $0x8,0xf02a92b2
f0103c1f:	08 00 
f0103c21:	c6 05 b4 92 2a f0 00 	movb   $0x0,0xf02a92b4
f0103c28:	c6 05 b5 92 2a f0 8e 	movb   $0x8e,0xf02a92b5
f0103c2f:	c1 e8 10             	shr    $0x10,%eax
f0103c32:	66 a3 b6 92 2a f0    	mov    %ax,0xf02a92b6
	SETGATE(idt[T_SEGNP], 0, GD_KT, _T_SEGNP_handler, 0);
f0103c38:	b8 a2 44 10 f0       	mov    $0xf01044a2,%eax
f0103c3d:	66 a3 b8 92 2a f0    	mov    %ax,0xf02a92b8
f0103c43:	66 c7 05 ba 92 2a f0 	movw   $0x8,0xf02a92ba
f0103c4a:	08 00 
f0103c4c:	c6 05 bc 92 2a f0 00 	movb   $0x0,0xf02a92bc
f0103c53:	c6 05 bd 92 2a f0 8e 	movb   $0x8e,0xf02a92bd
f0103c5a:	c1 e8 10             	shr    $0x10,%eax
f0103c5d:	66 a3 be 92 2a f0    	mov    %ax,0xf02a92be
	SETGATE(idt[T_STACK], 0, GD_KT, _T_STACK_handler, 0);
f0103c63:	b8 a6 44 10 f0       	mov    $0xf01044a6,%eax
f0103c68:	66 a3 c0 92 2a f0    	mov    %ax,0xf02a92c0
f0103c6e:	66 c7 05 c2 92 2a f0 	movw   $0x8,0xf02a92c2
f0103c75:	08 00 
f0103c77:	c6 05 c4 92 2a f0 00 	movb   $0x0,0xf02a92c4
f0103c7e:	c6 05 c5 92 2a f0 8e 	movb   $0x8e,0xf02a92c5
f0103c85:	c1 e8 10             	shr    $0x10,%eax
f0103c88:	66 a3 c6 92 2a f0    	mov    %ax,0xf02a92c6
	SETGATE(idt[T_GPFLT], 0, GD_KT, _T_GPFLT_handler, 0);
f0103c8e:	b8 aa 44 10 f0       	mov    $0xf01044aa,%eax
f0103c93:	66 a3 c8 92 2a f0    	mov    %ax,0xf02a92c8
f0103c99:	66 c7 05 ca 92 2a f0 	movw   $0x8,0xf02a92ca
f0103ca0:	08 00 
f0103ca2:	c6 05 cc 92 2a f0 00 	movb   $0x0,0xf02a92cc
f0103ca9:	c6 05 cd 92 2a f0 8e 	movb   $0x8e,0xf02a92cd
f0103cb0:	c1 e8 10             	shr    $0x10,%eax
f0103cb3:	66 a3 ce 92 2a f0    	mov    %ax,0xf02a92ce
	SETGATE(idt[T_PGFLT], 0, GD_KT, _T_PGFLT_handler, 0);
f0103cb9:	b8 ae 44 10 f0       	mov    $0xf01044ae,%eax
f0103cbe:	66 a3 d0 92 2a f0    	mov    %ax,0xf02a92d0
f0103cc4:	66 c7 05 d2 92 2a f0 	movw   $0x8,0xf02a92d2
f0103ccb:	08 00 
f0103ccd:	c6 05 d4 92 2a f0 00 	movb   $0x0,0xf02a92d4
f0103cd4:	c6 05 d5 92 2a f0 8e 	movb   $0x8e,0xf02a92d5
f0103cdb:	c1 e8 10             	shr    $0x10,%eax
f0103cde:	66 a3 d6 92 2a f0    	mov    %ax,0xf02a92d6
	SETGATE(idt[T_FPERR], 0, GD_KT, _T_FPERR_handler, 0);
f0103ce4:	b8 b2 44 10 f0       	mov    $0xf01044b2,%eax
f0103ce9:	66 a3 e0 92 2a f0    	mov    %ax,0xf02a92e0
f0103cef:	66 c7 05 e2 92 2a f0 	movw   $0x8,0xf02a92e2
f0103cf6:	08 00 
f0103cf8:	c6 05 e4 92 2a f0 00 	movb   $0x0,0xf02a92e4
f0103cff:	c6 05 e5 92 2a f0 8e 	movb   $0x8e,0xf02a92e5
f0103d06:	c1 e8 10             	shr    $0x10,%eax
f0103d09:	66 a3 e6 92 2a f0    	mov    %ax,0xf02a92e6
	SETGATE(idt[T_ALIGN], 0, GD_KT, _T_ALIGN_handler, 0);
f0103d0f:	b8 b8 44 10 f0       	mov    $0xf01044b8,%eax
f0103d14:	66 a3 e8 92 2a f0    	mov    %ax,0xf02a92e8
f0103d1a:	66 c7 05 ea 92 2a f0 	movw   $0x8,0xf02a92ea
f0103d21:	08 00 
f0103d23:	c6 05 ec 92 2a f0 00 	movb   $0x0,0xf02a92ec
f0103d2a:	c6 05 ed 92 2a f0 8e 	movb   $0x8e,0xf02a92ed
f0103d31:	c1 e8 10             	shr    $0x10,%eax
f0103d34:	66 a3 ee 92 2a f0    	mov    %ax,0xf02a92ee
	SETGATE(idt[T_MCHK], 0, GD_KT, _T_MCHK_handler, 0);
f0103d3a:	b8 bc 44 10 f0       	mov    $0xf01044bc,%eax
f0103d3f:	66 a3 f0 92 2a f0    	mov    %ax,0xf02a92f0
f0103d45:	66 c7 05 f2 92 2a f0 	movw   $0x8,0xf02a92f2
f0103d4c:	08 00 
f0103d4e:	c6 05 f4 92 2a f0 00 	movb   $0x0,0xf02a92f4
f0103d55:	c6 05 f5 92 2a f0 8e 	movb   $0x8e,0xf02a92f5
f0103d5c:	c1 e8 10             	shr    $0x10,%eax
f0103d5f:	66 a3 f6 92 2a f0    	mov    %ax,0xf02a92f6
	SETGATE(idt[T_SIMDERR], 0, GD_KT, _T_SIMDERR_handler, 0);
f0103d65:	b8 c2 44 10 f0       	mov    $0xf01044c2,%eax
f0103d6a:	66 a3 f8 92 2a f0    	mov    %ax,0xf02a92f8
f0103d70:	66 c7 05 fa 92 2a f0 	movw   $0x8,0xf02a92fa
f0103d77:	08 00 
f0103d79:	c6 05 fc 92 2a f0 00 	movb   $0x0,0xf02a92fc
f0103d80:	c6 05 fd 92 2a f0 8e 	movb   $0x8e,0xf02a92fd
f0103d87:	c1 e8 10             	shr    $0x10,%eax
f0103d8a:	66 a3 fe 92 2a f0    	mov    %ax,0xf02a92fe
	SETGATE(idt[T_SYSCALL], 0, GD_KT, _T_SYSCALL_handler, 3);
f0103d90:	b8 c8 44 10 f0       	mov    $0xf01044c8,%eax
f0103d95:	66 a3 e0 93 2a f0    	mov    %ax,0xf02a93e0
f0103d9b:	66 c7 05 e2 93 2a f0 	movw   $0x8,0xf02a93e2
f0103da2:	08 00 
f0103da4:	c6 05 e4 93 2a f0 00 	movb   $0x0,0xf02a93e4
f0103dab:	c6 05 e5 93 2a f0 ee 	movb   $0xee,0xf02a93e5
f0103db2:	c1 e8 10             	shr    $0x10,%eax
f0103db5:	66 a3 e6 93 2a f0    	mov    %ax,0xf02a93e6

	SETGATE(idt[IRQ_TIMER + IRQ_OFFSET], 0, GD_KT, _IRQ_TIMER_handler, 0);
f0103dbb:	b8 ce 44 10 f0       	mov    $0xf01044ce,%eax
f0103dc0:	66 a3 60 93 2a f0    	mov    %ax,0xf02a9360
f0103dc6:	66 c7 05 62 93 2a f0 	movw   $0x8,0xf02a9362
f0103dcd:	08 00 
f0103dcf:	c6 05 64 93 2a f0 00 	movb   $0x0,0xf02a9364
f0103dd6:	c6 05 65 93 2a f0 8e 	movb   $0x8e,0xf02a9365
f0103ddd:	c1 e8 10             	shr    $0x10,%eax
f0103de0:	66 a3 66 93 2a f0    	mov    %ax,0xf02a9366
	SETGATE(idt[IRQ_KBD + IRQ_OFFSET], 0, GD_KT, _IRQ_KBD_handler, 0);
f0103de6:	b8 d4 44 10 f0       	mov    $0xf01044d4,%eax
f0103deb:	66 a3 68 93 2a f0    	mov    %ax,0xf02a9368
f0103df1:	66 c7 05 6a 93 2a f0 	movw   $0x8,0xf02a936a
f0103df8:	08 00 
f0103dfa:	c6 05 6c 93 2a f0 00 	movb   $0x0,0xf02a936c
f0103e01:	c6 05 6d 93 2a f0 8e 	movb   $0x8e,0xf02a936d
f0103e08:	c1 e8 10             	shr    $0x10,%eax
f0103e0b:	66 a3 6e 93 2a f0    	mov    %ax,0xf02a936e
	SETGATE(idt[IRQ_SERIAL + IRQ_OFFSET], 0, GD_KT, _IRQ_SERIAL_handler, 0);
f0103e11:	b8 da 44 10 f0       	mov    $0xf01044da,%eax
f0103e16:	66 a3 80 93 2a f0    	mov    %ax,0xf02a9380
f0103e1c:	66 c7 05 82 93 2a f0 	movw   $0x8,0xf02a9382
f0103e23:	08 00 
f0103e25:	c6 05 84 93 2a f0 00 	movb   $0x0,0xf02a9384
f0103e2c:	c6 05 85 93 2a f0 8e 	movb   $0x8e,0xf02a9385
f0103e33:	c1 e8 10             	shr    $0x10,%eax
f0103e36:	66 a3 86 93 2a f0    	mov    %ax,0xf02a9386
	SETGATE(idt[IRQ_SPURIOUS + IRQ_OFFSET], 0, GD_KT, _IRQ_SPURIOUS_handler, 0);
f0103e3c:	b8 e0 44 10 f0       	mov    $0xf01044e0,%eax
f0103e41:	66 a3 98 93 2a f0    	mov    %ax,0xf02a9398
f0103e47:	66 c7 05 9a 93 2a f0 	movw   $0x8,0xf02a939a
f0103e4e:	08 00 
f0103e50:	c6 05 9c 93 2a f0 00 	movb   $0x0,0xf02a939c
f0103e57:	c6 05 9d 93 2a f0 8e 	movb   $0x8e,0xf02a939d
f0103e5e:	c1 e8 10             	shr    $0x10,%eax
f0103e61:	66 a3 9e 93 2a f0    	mov    %ax,0xf02a939e
	SETGATE(idt[IRQ_IDE + IRQ_OFFSET], 0, GD_KT, _IRQ_IDE_handler, 0);
f0103e67:	b8 e6 44 10 f0       	mov    $0xf01044e6,%eax
f0103e6c:	66 a3 d0 93 2a f0    	mov    %ax,0xf02a93d0
f0103e72:	66 c7 05 d2 93 2a f0 	movw   $0x8,0xf02a93d2
f0103e79:	08 00 
f0103e7b:	c6 05 d4 93 2a f0 00 	movb   $0x0,0xf02a93d4
f0103e82:	c6 05 d5 93 2a f0 8e 	movb   $0x8e,0xf02a93d5
f0103e89:	c1 e8 10             	shr    $0x10,%eax
f0103e8c:	66 a3 d6 93 2a f0    	mov    %ax,0xf02a93d6
	SETGATE(idt[IRQ_ERROR + IRQ_OFFSET], 0, GD_KT, _IRQ_ERROR_handler, 0);
f0103e92:	b8 ec 44 10 f0       	mov    $0xf01044ec,%eax
f0103e97:	66 a3 f8 93 2a f0    	mov    %ax,0xf02a93f8
f0103e9d:	66 c7 05 fa 93 2a f0 	movw   $0x8,0xf02a93fa
f0103ea4:	08 00 
f0103ea6:	c6 05 fc 93 2a f0 00 	movb   $0x0,0xf02a93fc
f0103ead:	c6 05 fd 93 2a f0 8e 	movb   $0x8e,0xf02a93fd
f0103eb4:	c1 e8 10             	shr    $0x10,%eax
f0103eb7:	66 a3 fe 93 2a f0    	mov    %ax,0xf02a93fe

	// Per-CPU setup 
	trap_init_percpu();
f0103ebd:	e8 e3 fa ff ff       	call   f01039a5 <trap_init_percpu>
}
f0103ec2:	c9                   	leave  
f0103ec3:	c3                   	ret    

f0103ec4 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103ec4:	55                   	push   %ebp
f0103ec5:	89 e5                	mov    %esp,%ebp
f0103ec7:	53                   	push   %ebx
f0103ec8:	83 ec 0c             	sub    $0xc,%esp
f0103ecb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103ece:	ff 33                	pushl  (%ebx)
f0103ed0:	68 67 7e 10 f0       	push   $0xf0107e67
f0103ed5:	e8 b7 fa ff ff       	call   f0103991 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103eda:	83 c4 08             	add    $0x8,%esp
f0103edd:	ff 73 04             	pushl  0x4(%ebx)
f0103ee0:	68 76 7e 10 f0       	push   $0xf0107e76
f0103ee5:	e8 a7 fa ff ff       	call   f0103991 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103eea:	83 c4 08             	add    $0x8,%esp
f0103eed:	ff 73 08             	pushl  0x8(%ebx)
f0103ef0:	68 85 7e 10 f0       	push   $0xf0107e85
f0103ef5:	e8 97 fa ff ff       	call   f0103991 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103efa:	83 c4 08             	add    $0x8,%esp
f0103efd:	ff 73 0c             	pushl  0xc(%ebx)
f0103f00:	68 94 7e 10 f0       	push   $0xf0107e94
f0103f05:	e8 87 fa ff ff       	call   f0103991 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103f0a:	83 c4 08             	add    $0x8,%esp
f0103f0d:	ff 73 10             	pushl  0x10(%ebx)
f0103f10:	68 a3 7e 10 f0       	push   $0xf0107ea3
f0103f15:	e8 77 fa ff ff       	call   f0103991 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103f1a:	83 c4 08             	add    $0x8,%esp
f0103f1d:	ff 73 14             	pushl  0x14(%ebx)
f0103f20:	68 b2 7e 10 f0       	push   $0xf0107eb2
f0103f25:	e8 67 fa ff ff       	call   f0103991 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103f2a:	83 c4 08             	add    $0x8,%esp
f0103f2d:	ff 73 18             	pushl  0x18(%ebx)
f0103f30:	68 c1 7e 10 f0       	push   $0xf0107ec1
f0103f35:	e8 57 fa ff ff       	call   f0103991 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103f3a:	83 c4 08             	add    $0x8,%esp
f0103f3d:	ff 73 1c             	pushl  0x1c(%ebx)
f0103f40:	68 d0 7e 10 f0       	push   $0xf0107ed0
f0103f45:	e8 47 fa ff ff       	call   f0103991 <cprintf>
}
f0103f4a:	83 c4 10             	add    $0x10,%esp
f0103f4d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103f50:	c9                   	leave  
f0103f51:	c3                   	ret    

f0103f52 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103f52:	55                   	push   %ebp
f0103f53:	89 e5                	mov    %esp,%ebp
f0103f55:	56                   	push   %esi
f0103f56:	53                   	push   %ebx
f0103f57:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103f5a:	e8 2f 1e 00 00       	call   f0105d8e <cpunum>
f0103f5f:	83 ec 04             	sub    $0x4,%esp
f0103f62:	50                   	push   %eax
f0103f63:	53                   	push   %ebx
f0103f64:	68 34 7f 10 f0       	push   $0xf0107f34
f0103f69:	e8 23 fa ff ff       	call   f0103991 <cprintf>
	print_regs(&tf->tf_regs);
f0103f6e:	89 1c 24             	mov    %ebx,(%esp)
f0103f71:	e8 4e ff ff ff       	call   f0103ec4 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103f76:	83 c4 08             	add    $0x8,%esp
f0103f79:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103f7d:	50                   	push   %eax
f0103f7e:	68 52 7f 10 f0       	push   $0xf0107f52
f0103f83:	e8 09 fa ff ff       	call   f0103991 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103f88:	83 c4 08             	add    $0x8,%esp
f0103f8b:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103f8f:	50                   	push   %eax
f0103f90:	68 65 7f 10 f0       	push   $0xf0107f65
f0103f95:	e8 f7 f9 ff ff       	call   f0103991 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103f9a:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f0103f9d:	83 c4 10             	add    $0x10,%esp
f0103fa0:	83 f8 13             	cmp    $0x13,%eax
f0103fa3:	77 09                	ja     f0103fae <print_trapframe+0x5c>
		return excnames[trapno];
f0103fa5:	8b 14 85 00 82 10 f0 	mov    -0xfef7e00(,%eax,4),%edx
f0103fac:	eb 1f                	jmp    f0103fcd <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f0103fae:	83 f8 30             	cmp    $0x30,%eax
f0103fb1:	74 15                	je     f0103fc8 <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103fb3:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f0103fb6:	83 fa 10             	cmp    $0x10,%edx
f0103fb9:	b9 fe 7e 10 f0       	mov    $0xf0107efe,%ecx
f0103fbe:	ba eb 7e 10 f0       	mov    $0xf0107eeb,%edx
f0103fc3:	0f 43 d1             	cmovae %ecx,%edx
f0103fc6:	eb 05                	jmp    f0103fcd <print_trapframe+0x7b>
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0103fc8:	ba df 7e 10 f0       	mov    $0xf0107edf,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103fcd:	83 ec 04             	sub    $0x4,%esp
f0103fd0:	52                   	push   %edx
f0103fd1:	50                   	push   %eax
f0103fd2:	68 78 7f 10 f0       	push   $0xf0107f78
f0103fd7:	e8 b5 f9 ff ff       	call   f0103991 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103fdc:	83 c4 10             	add    $0x10,%esp
f0103fdf:	3b 1d 60 9a 2a f0    	cmp    0xf02a9a60,%ebx
f0103fe5:	75 1a                	jne    f0104001 <print_trapframe+0xaf>
f0103fe7:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103feb:	75 14                	jne    f0104001 <print_trapframe+0xaf>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103fed:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103ff0:	83 ec 08             	sub    $0x8,%esp
f0103ff3:	50                   	push   %eax
f0103ff4:	68 8a 7f 10 f0       	push   $0xf0107f8a
f0103ff9:	e8 93 f9 ff ff       	call   f0103991 <cprintf>
f0103ffe:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0104001:	83 ec 08             	sub    $0x8,%esp
f0104004:	ff 73 2c             	pushl  0x2c(%ebx)
f0104007:	68 99 7f 10 f0       	push   $0xf0107f99
f010400c:	e8 80 f9 ff ff       	call   f0103991 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0104011:	83 c4 10             	add    $0x10,%esp
f0104014:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104018:	75 49                	jne    f0104063 <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f010401a:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f010401d:	89 c2                	mov    %eax,%edx
f010401f:	83 e2 01             	and    $0x1,%edx
f0104022:	ba 18 7f 10 f0       	mov    $0xf0107f18,%edx
f0104027:	b9 0d 7f 10 f0       	mov    $0xf0107f0d,%ecx
f010402c:	0f 44 ca             	cmove  %edx,%ecx
f010402f:	89 c2                	mov    %eax,%edx
f0104031:	83 e2 02             	and    $0x2,%edx
f0104034:	ba 2a 7f 10 f0       	mov    $0xf0107f2a,%edx
f0104039:	be 24 7f 10 f0       	mov    $0xf0107f24,%esi
f010403e:	0f 45 d6             	cmovne %esi,%edx
f0104041:	83 e0 04             	and    $0x4,%eax
f0104044:	be 8e 80 10 f0       	mov    $0xf010808e,%esi
f0104049:	b8 2f 7f 10 f0       	mov    $0xf0107f2f,%eax
f010404e:	0f 44 c6             	cmove  %esi,%eax
f0104051:	51                   	push   %ecx
f0104052:	52                   	push   %edx
f0104053:	50                   	push   %eax
f0104054:	68 a7 7f 10 f0       	push   $0xf0107fa7
f0104059:	e8 33 f9 ff ff       	call   f0103991 <cprintf>
f010405e:	83 c4 10             	add    $0x10,%esp
f0104061:	eb 10                	jmp    f0104073 <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0104063:	83 ec 0c             	sub    $0xc,%esp
f0104066:	68 99 72 10 f0       	push   $0xf0107299
f010406b:	e8 21 f9 ff ff       	call   f0103991 <cprintf>
f0104070:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0104073:	83 ec 08             	sub    $0x8,%esp
f0104076:	ff 73 30             	pushl  0x30(%ebx)
f0104079:	68 b6 7f 10 f0       	push   $0xf0107fb6
f010407e:	e8 0e f9 ff ff       	call   f0103991 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0104083:	83 c4 08             	add    $0x8,%esp
f0104086:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f010408a:	50                   	push   %eax
f010408b:	68 c5 7f 10 f0       	push   $0xf0107fc5
f0104090:	e8 fc f8 ff ff       	call   f0103991 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104095:	83 c4 08             	add    $0x8,%esp
f0104098:	ff 73 38             	pushl  0x38(%ebx)
f010409b:	68 d8 7f 10 f0       	push   $0xf0107fd8
f01040a0:	e8 ec f8 ff ff       	call   f0103991 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01040a5:	83 c4 10             	add    $0x10,%esp
f01040a8:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01040ac:	74 25                	je     f01040d3 <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01040ae:	83 ec 08             	sub    $0x8,%esp
f01040b1:	ff 73 3c             	pushl  0x3c(%ebx)
f01040b4:	68 e7 7f 10 f0       	push   $0xf0107fe7
f01040b9:	e8 d3 f8 ff ff       	call   f0103991 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01040be:	83 c4 08             	add    $0x8,%esp
f01040c1:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01040c5:	50                   	push   %eax
f01040c6:	68 f6 7f 10 f0       	push   $0xf0107ff6
f01040cb:	e8 c1 f8 ff ff       	call   f0103991 <cprintf>
f01040d0:	83 c4 10             	add    $0x10,%esp
	}
}
f01040d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01040d6:	5b                   	pop    %ebx
f01040d7:	5e                   	pop    %esi
f01040d8:	5d                   	pop    %ebp
f01040d9:	c3                   	ret    

f01040da <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01040da:	55                   	push   %ebp
f01040db:	89 e5                	mov    %esp,%ebp
f01040dd:	57                   	push   %edi
f01040de:	56                   	push   %esi
f01040df:	53                   	push   %ebx
f01040e0:	83 ec 1c             	sub    $0x1c,%esp
f01040e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01040e6:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) == 0)
f01040e9:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01040ed:	75 15                	jne    f0104104 <page_fault_handler+0x2a>
		panic("page fault in kernel at %x!", fault_va);
f01040ef:	56                   	push   %esi
f01040f0:	68 09 80 10 f0       	push   $0xf0108009
f01040f5:	68 72 01 00 00       	push   $0x172
f01040fa:	68 25 80 10 f0       	push   $0xf0108025
f01040ff:	e8 3c bf ff ff       	call   f0100040 <_panic>
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	if (curenv->env_pgfault_upcall) {
f0104104:	e8 85 1c 00 00       	call   f0105d8e <cpunum>
f0104109:	6b c0 74             	imul   $0x74,%eax,%eax
f010410c:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
f0104112:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0104116:	0f 84 af 00 00 00    	je     f01041cb <page_fault_handler+0xf1>
		uint32_t estack_top = UXSTACKTOP;

		// if pgfault happens in user exception stack
		// as mentioned above, we push things right after the previous exception stack 
		// started with dummy 4 bytes
		if (tf->tf_esp < UXSTACKTOP && tf->tf_esp >= UXSTACKTOP - PGSIZE)
f010411c:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010411f:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			estack_top = tf->tf_esp - 4;
f0104125:	83 e8 04             	sub    $0x4,%eax
f0104128:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f010412e:	bf 00 00 c0 ee       	mov    $0xeec00000,%edi
f0104133:	0f 46 f8             	cmovbe %eax,%edi

		// char* utrapframe = (char *)(estack_top - sizeof(struct UTrapframe));
		struct UTrapframe *utf = (struct UTrapframe *)(estack_top - sizeof(struct UTrapframe));
f0104136:	8d 47 cc             	lea    -0x34(%edi),%eax
f0104139:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// do a memory check
		user_mem_assert(curenv, (void *)utf, sizeof(struct UTrapframe), PTE_W | PTE_P);
f010413c:	e8 4d 1c 00 00       	call   f0105d8e <cpunum>
f0104141:	6a 03                	push   $0x3
f0104143:	6a 34                	push   $0x34
f0104145:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104148:	6b c0 74             	imul   $0x74,%eax,%eax
f010414b:	ff b0 28 a0 2a f0    	pushl  -0xfd55fd8(%eax)
f0104151:	e8 01 ef ff ff       	call   f0103057 <user_mem_assert>

		// copy context to utrapframe 
		// memcpy(utrapframe, (char *)tf, sizeof(struct UTrapframe));
		// *(uint32_t *)utrapframe = fault_va;
		utf->utf_fault_va = fault_va;
f0104156:	89 77 cc             	mov    %esi,-0x34(%edi)
        utf->utf_err      = tf->tf_trapno;
f0104159:	8b 43 28             	mov    0x28(%ebx),%eax
f010415c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010415f:	89 42 04             	mov    %eax,0x4(%edx)
        utf->utf_regs     = tf->tf_regs;
f0104162:	83 ef 2c             	sub    $0x2c,%edi
f0104165:	b9 08 00 00 00       	mov    $0x8,%ecx
f010416a:	89 de                	mov    %ebx,%esi
f010416c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
        utf->utf_eflags   = tf->tf_eflags;
f010416e:	8b 43 38             	mov    0x38(%ebx),%eax
f0104171:	89 42 2c             	mov    %eax,0x2c(%edx)
        utf->utf_eip      = tf->tf_eip;
f0104174:	8b 43 30             	mov    0x30(%ebx),%eax
f0104177:	89 d6                	mov    %edx,%esi
f0104179:	89 42 28             	mov    %eax,0x28(%edx)
        utf->utf_esp      = tf->tf_esp;
f010417c:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010417f:	89 42 30             	mov    %eax,0x30(%edx)

		curenv->env_tf.tf_esp = (uint32_t)utf;
f0104182:	e8 07 1c 00 00       	call   f0105d8e <cpunum>
f0104187:	6b c0 74             	imul   $0x74,%eax,%eax
f010418a:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
f0104190:	89 70 3c             	mov    %esi,0x3c(%eax)
		curenv->env_tf.tf_eip = (uint32_t)curenv->env_pgfault_upcall;
f0104193:	e8 f6 1b 00 00       	call   f0105d8e <cpunum>
f0104198:	6b c0 74             	imul   $0x74,%eax,%eax
f010419b:	8b 98 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%ebx
f01041a1:	e8 e8 1b 00 00       	call   f0105d8e <cpunum>
f01041a6:	6b c0 74             	imul   $0x74,%eax,%eax
f01041a9:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
f01041af:	8b 40 64             	mov    0x64(%eax),%eax
f01041b2:	89 43 30             	mov    %eax,0x30(%ebx)
		env_run(curenv);
f01041b5:	e8 d4 1b 00 00       	call   f0105d8e <cpunum>
f01041ba:	83 c4 04             	add    $0x4,%esp
f01041bd:	6b c0 74             	imul   $0x74,%eax,%eax
f01041c0:	ff b0 28 a0 2a f0    	pushl  -0xfd55fd8(%eax)
f01041c6:	e8 4e f5 ff ff       	call   f0103719 <env_run>

	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01041cb:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f01041ce:	e8 bb 1b 00 00       	call   f0105d8e <cpunum>
		env_run(curenv);

	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01041d3:	57                   	push   %edi
f01041d4:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f01041d5:	6b c0 74             	imul   $0x74,%eax,%eax
		env_run(curenv);

	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01041d8:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
f01041de:	ff 70 48             	pushl  0x48(%eax)
f01041e1:	68 d8 81 10 f0       	push   $0xf01081d8
f01041e6:	e8 a6 f7 ff ff       	call   f0103991 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f01041eb:	89 1c 24             	mov    %ebx,(%esp)
f01041ee:	e8 5f fd ff ff       	call   f0103f52 <print_trapframe>
	env_destroy(curenv);
f01041f3:	e8 96 1b 00 00       	call   f0105d8e <cpunum>
f01041f8:	83 c4 04             	add    $0x4,%esp
f01041fb:	6b c0 74             	imul   $0x74,%eax,%eax
f01041fe:	ff b0 28 a0 2a f0    	pushl  -0xfd55fd8(%eax)
f0104204:	e8 71 f4 ff ff       	call   f010367a <env_destroy>
}
f0104209:	83 c4 10             	add    $0x10,%esp
f010420c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010420f:	5b                   	pop    %ebx
f0104210:	5e                   	pop    %esi
f0104211:	5f                   	pop    %edi
f0104212:	5d                   	pop    %ebp
f0104213:	c3                   	ret    

f0104214 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0104214:	55                   	push   %ebp
f0104215:	89 e5                	mov    %esp,%ebp
f0104217:	57                   	push   %edi
f0104218:	56                   	push   %esi
f0104219:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f010421c:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f010421d:	83 3d 98 9e 2a f0 00 	cmpl   $0x0,0xf02a9e98
f0104224:	74 01                	je     f0104227 <trap+0x13>
		asm volatile("hlt");
f0104226:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104227:	e8 62 1b 00 00       	call   f0105d8e <cpunum>
f010422c:	6b d0 74             	imul   $0x74,%eax,%edx
f010422f:	81 c2 20 a0 2a f0    	add    $0xf02aa020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0104235:	b8 01 00 00 00       	mov    $0x1,%eax
f010423a:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010423e:	83 f8 02             	cmp    $0x2,%eax
f0104241:	75 10                	jne    f0104253 <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104243:	83 ec 0c             	sub    $0xc,%esp
f0104246:	68 c0 23 12 f0       	push   $0xf01223c0
f010424b:	e8 ac 1d 00 00       	call   f0105ffc <spin_lock>
f0104250:	83 c4 10             	add    $0x10,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0104253:	9c                   	pushf  
f0104254:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104255:	f6 c4 02             	test   $0x2,%ah
f0104258:	74 19                	je     f0104273 <trap+0x5f>
f010425a:	68 31 80 10 f0       	push   $0xf0108031
f010425f:	68 85 6f 10 f0       	push   $0xf0106f85
f0104264:	68 3a 01 00 00       	push   $0x13a
f0104269:	68 25 80 10 f0       	push   $0xf0108025
f010426e:	e8 cd bd ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0104273:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104277:	83 e0 03             	and    $0x3,%eax
f010427a:	66 83 f8 03          	cmp    $0x3,%ax
f010427e:	0f 85 a0 00 00 00    	jne    f0104324 <trap+0x110>
f0104284:	83 ec 0c             	sub    $0xc,%esp
f0104287:	68 c0 23 12 f0       	push   $0xf01223c0
f010428c:	e8 6b 1d 00 00       	call   f0105ffc <spin_lock>
		// serious kernel work.
		// LAB 4: Your code here.

		lock_kernel();

		assert(curenv);
f0104291:	e8 f8 1a 00 00       	call   f0105d8e <cpunum>
f0104296:	6b c0 74             	imul   $0x74,%eax,%eax
f0104299:	83 c4 10             	add    $0x10,%esp
f010429c:	83 b8 28 a0 2a f0 00 	cmpl   $0x0,-0xfd55fd8(%eax)
f01042a3:	75 19                	jne    f01042be <trap+0xaa>
f01042a5:	68 4a 80 10 f0       	push   $0xf010804a
f01042aa:	68 85 6f 10 f0       	push   $0xf0106f85
f01042af:	68 44 01 00 00       	push   $0x144
f01042b4:	68 25 80 10 f0       	push   $0xf0108025
f01042b9:	e8 82 bd ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f01042be:	e8 cb 1a 00 00       	call   f0105d8e <cpunum>
f01042c3:	6b c0 74             	imul   $0x74,%eax,%eax
f01042c6:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
f01042cc:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01042d0:	75 2d                	jne    f01042ff <trap+0xeb>
			env_free(curenv);
f01042d2:	e8 b7 1a 00 00       	call   f0105d8e <cpunum>
f01042d7:	83 ec 0c             	sub    $0xc,%esp
f01042da:	6b c0 74             	imul   $0x74,%eax,%eax
f01042dd:	ff b0 28 a0 2a f0    	pushl  -0xfd55fd8(%eax)
f01042e3:	e8 ec f1 ff ff       	call   f01034d4 <env_free>
			curenv = NULL;
f01042e8:	e8 a1 1a 00 00       	call   f0105d8e <cpunum>
f01042ed:	6b c0 74             	imul   $0x74,%eax,%eax
f01042f0:	c7 80 28 a0 2a f0 00 	movl   $0x0,-0xfd55fd8(%eax)
f01042f7:	00 00 00 
			sched_yield();
f01042fa:	e8 d9 02 00 00       	call   f01045d8 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01042ff:	e8 8a 1a 00 00       	call   f0105d8e <cpunum>
f0104304:	6b c0 74             	imul   $0x74,%eax,%eax
f0104307:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
f010430d:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104312:	89 c7                	mov    %eax,%edi
f0104314:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104316:	e8 73 1a 00 00       	call   f0105d8e <cpunum>
f010431b:	6b c0 74             	imul   $0x74,%eax,%eax
f010431e:	8b b0 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104324:	89 35 60 9a 2a f0    	mov    %esi,0xf02a9a60
	// Handle keyboard and serial interrupts.
	// LAB 5: Your code here.

	struct PushRegs* r = &tf->tf_regs;

	switch(tf->tf_trapno) {
f010432a:	8b 46 28             	mov    0x28(%esi),%eax
f010432d:	83 f8 21             	cmp    $0x21,%eax
f0104330:	74 7b                	je     f01043ad <trap+0x199>
f0104332:	83 f8 21             	cmp    $0x21,%eax
f0104335:	77 15                	ja     f010434c <trap+0x138>
f0104337:	83 f8 0e             	cmp    $0xe,%eax
f010433a:	74 21                	je     f010435d <trap+0x149>
f010433c:	83 f8 20             	cmp    $0x20,%eax
f010433f:	74 62                	je     f01043a3 <trap+0x18f>
f0104341:	83 f8 03             	cmp    $0x3,%eax
f0104344:	0f 85 8b 00 00 00    	jne    f01043d5 <trap+0x1c1>
f010434a:	eb 22                	jmp    f010436e <trap+0x15a>
f010434c:	83 f8 27             	cmp    $0x27,%eax
f010434f:	74 6a                	je     f01043bb <trap+0x1a7>
f0104351:	83 f8 30             	cmp    $0x30,%eax
f0104354:	74 29                	je     f010437f <trap+0x16b>
f0104356:	83 f8 24             	cmp    $0x24,%eax
f0104359:	75 7a                	jne    f01043d5 <trap+0x1c1>
f010435b:	eb 57                	jmp    f01043b4 <trap+0x1a0>
		case (T_PGFLT):
			page_fault_handler(tf);
f010435d:	83 ec 0c             	sub    $0xc,%esp
f0104360:	56                   	push   %esi
f0104361:	e8 74 fd ff ff       	call   f01040da <page_fault_handler>
f0104366:	83 c4 10             	add    $0x10,%esp
f0104369:	e9 b7 00 00 00       	jmp    f0104425 <trap+0x211>
			break;
		case (T_BRKPT):
			monitor(tf);	// open a JOS monitor
f010436e:	83 ec 0c             	sub    $0xc,%esp
f0104371:	56                   	push   %esi
f0104372:	e8 49 c6 ff ff       	call   f01009c0 <monitor>
f0104377:	83 c4 10             	add    $0x10,%esp
f010437a:	e9 a6 00 00 00       	jmp    f0104425 <trap+0x211>
			break;
		case (T_SYSCALL):
			// call syscall in kern/syscall.c
			r->reg_eax = syscall(r->reg_eax, r->reg_edx, r->reg_ecx, r->reg_ebx, r->reg_edi, r->reg_esi);
f010437f:	83 ec 08             	sub    $0x8,%esp
f0104382:	ff 76 04             	pushl  0x4(%esi)
f0104385:	ff 36                	pushl  (%esi)
f0104387:	ff 76 10             	pushl  0x10(%esi)
f010438a:	ff 76 18             	pushl  0x18(%esi)
f010438d:	ff 76 14             	pushl  0x14(%esi)
f0104390:	ff 76 1c             	pushl  0x1c(%esi)
f0104393:	e8 c9 02 00 00       	call   f0104661 <syscall>
f0104398:	89 46 1c             	mov    %eax,0x1c(%esi)
f010439b:	83 c4 20             	add    $0x20,%esp
f010439e:	e9 82 00 00 00       	jmp    f0104425 <trap+0x211>
			break;
		case (IRQ_OFFSET + IRQ_TIMER):
			lapic_eoi();	// Acknowledge interrupt.
f01043a3:	e8 31 1b 00 00       	call   f0105ed9 <lapic_eoi>
			sched_yield();
f01043a8:	e8 2b 02 00 00       	call   f01045d8 <sched_yield>
			break;
		case (IRQ_OFFSET + IRQ_KBD):
			kbd_intr();
f01043ad:	e8 47 c2 ff ff       	call   f01005f9 <kbd_intr>
f01043b2:	eb 71                	jmp    f0104425 <trap+0x211>
			break;
		case (IRQ_OFFSET + IRQ_SERIAL):
			serial_intr();
f01043b4:	e8 24 c2 ff ff       	call   f01005dd <serial_intr>
f01043b9:	eb 6a                	jmp    f0104425 <trap+0x211>
			break;
		case (IRQ_OFFSET + IRQ_SPURIOUS):
			cprintf("Spurious interrupt on irq 7\n");
f01043bb:	83 ec 0c             	sub    $0xc,%esp
f01043be:	68 51 80 10 f0       	push   $0xf0108051
f01043c3:	e8 c9 f5 ff ff       	call   f0103991 <cprintf>
			print_trapframe(tf);
f01043c8:	89 34 24             	mov    %esi,(%esp)
f01043cb:	e8 82 fb ff ff       	call   f0103f52 <print_trapframe>
f01043d0:	83 c4 10             	add    $0x10,%esp
f01043d3:	eb 50                	jmp    f0104425 <trap+0x211>
			return;
		default:
			// Unexpected trap: The user process or the kernel has a bug.
			cprintf("[trapno: %x]\n", tf->tf_trapno);
f01043d5:	83 ec 08             	sub    $0x8,%esp
f01043d8:	50                   	push   %eax
f01043d9:	68 6e 80 10 f0       	push   $0xf010806e
f01043de:	e8 ae f5 ff ff       	call   f0103991 <cprintf>
			print_trapframe(tf);
f01043e3:	89 34 24             	mov    %esi,(%esp)
f01043e6:	e8 67 fb ff ff       	call   f0103f52 <print_trapframe>
			if (tf->tf_cs == GD_KT)
f01043eb:	83 c4 10             	add    $0x10,%esp
f01043ee:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01043f3:	75 17                	jne    f010440c <trap+0x1f8>
				panic("unhandled trap in kernel");
f01043f5:	83 ec 04             	sub    $0x4,%esp
f01043f8:	68 7c 80 10 f0       	push   $0xf010807c
f01043fd:	68 1f 01 00 00       	push   $0x11f
f0104402:	68 25 80 10 f0       	push   $0xf0108025
f0104407:	e8 34 bc ff ff       	call   f0100040 <_panic>
			else {
				env_destroy(curenv);
f010440c:	e8 7d 19 00 00       	call   f0105d8e <cpunum>
f0104411:	83 ec 0c             	sub    $0xc,%esp
f0104414:	6b c0 74             	imul   $0x74,%eax,%eax
f0104417:	ff b0 28 a0 2a f0    	pushl  -0xfd55fd8(%eax)
f010441d:	e8 58 f2 ff ff       	call   f010367a <env_destroy>
f0104422:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104425:	e8 64 19 00 00       	call   f0105d8e <cpunum>
f010442a:	6b c0 74             	imul   $0x74,%eax,%eax
f010442d:	83 b8 28 a0 2a f0 00 	cmpl   $0x0,-0xfd55fd8(%eax)
f0104434:	74 2a                	je     f0104460 <trap+0x24c>
f0104436:	e8 53 19 00 00       	call   f0105d8e <cpunum>
f010443b:	6b c0 74             	imul   $0x74,%eax,%eax
f010443e:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
f0104444:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104448:	75 16                	jne    f0104460 <trap+0x24c>
		env_run(curenv);
f010444a:	e8 3f 19 00 00       	call   f0105d8e <cpunum>
f010444f:	83 ec 0c             	sub    $0xc,%esp
f0104452:	6b c0 74             	imul   $0x74,%eax,%eax
f0104455:	ff b0 28 a0 2a f0    	pushl  -0xfd55fd8(%eax)
f010445b:	e8 b9 f2 ff ff       	call   f0103719 <env_run>
	else
		sched_yield();
f0104460:	e8 73 01 00 00       	call   f01045d8 <sched_yield>
f0104465:	90                   	nop

f0104466 <_T_DIVIDE_handler>:
/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */


TRAPHANDLER_NOEC(_T_DIVIDE_handler, T_DIVIDE)
f0104466:	6a 00                	push   $0x0
f0104468:	6a 00                	push   $0x0
f010446a:	e9 83 00 00 00       	jmp    f01044f2 <_alltraps>
f010446f:	90                   	nop

f0104470 <_T_DEBUG_handler>:
TRAPHANDLER_NOEC(_T_DEBUG_handler, T_DEBUG)
f0104470:	6a 00                	push   $0x0
f0104472:	6a 01                	push   $0x1
f0104474:	eb 7c                	jmp    f01044f2 <_alltraps>

f0104476 <_T_NMI_handler>:
TRAPHANDLER_NOEC(_T_NMI_handler, T_NMI)
f0104476:	6a 00                	push   $0x0
f0104478:	6a 02                	push   $0x2
f010447a:	eb 76                	jmp    f01044f2 <_alltraps>

f010447c <_T_BRKPT_handler>:
TRAPHANDLER_NOEC(_T_BRKPT_handler, T_BRKPT)
f010447c:	6a 00                	push   $0x0
f010447e:	6a 03                	push   $0x3
f0104480:	eb 70                	jmp    f01044f2 <_alltraps>

f0104482 <_T_OFLOW_handler>:
TRAPHANDLER_NOEC(_T_OFLOW_handler, T_OFLOW)
f0104482:	6a 00                	push   $0x0
f0104484:	6a 04                	push   $0x4
f0104486:	eb 6a                	jmp    f01044f2 <_alltraps>

f0104488 <_T_BOUND_handler>:
TRAPHANDLER_NOEC(_T_BOUND_handler, T_BOUND)
f0104488:	6a 00                	push   $0x0
f010448a:	6a 05                	push   $0x5
f010448c:	eb 64                	jmp    f01044f2 <_alltraps>

f010448e <_T_ILLOP_handler>:
TRAPHANDLER_NOEC(_T_ILLOP_handler, T_ILLOP)
f010448e:	6a 00                	push   $0x0
f0104490:	6a 06                	push   $0x6
f0104492:	eb 5e                	jmp    f01044f2 <_alltraps>

f0104494 <_T_DEVICE_handler>:
TRAPHANDLER_NOEC(_T_DEVICE_handler, T_DEVICE)
f0104494:	6a 00                	push   $0x0
f0104496:	6a 07                	push   $0x7
f0104498:	eb 58                	jmp    f01044f2 <_alltraps>

f010449a <_T_DBLFLT_handler>:
TRAPHANDLER(_T_DBLFLT_handler, T_DBLFLT)
f010449a:	6a 08                	push   $0x8
f010449c:	eb 54                	jmp    f01044f2 <_alltraps>

f010449e <_T_TSS_handler>:
TRAPHANDLER(_T_TSS_handler, T_TSS)
f010449e:	6a 0a                	push   $0xa
f01044a0:	eb 50                	jmp    f01044f2 <_alltraps>

f01044a2 <_T_SEGNP_handler>:
TRAPHANDLER(_T_SEGNP_handler, T_SEGNP)
f01044a2:	6a 0b                	push   $0xb
f01044a4:	eb 4c                	jmp    f01044f2 <_alltraps>

f01044a6 <_T_STACK_handler>:
TRAPHANDLER(_T_STACK_handler, T_STACK)
f01044a6:	6a 0c                	push   $0xc
f01044a8:	eb 48                	jmp    f01044f2 <_alltraps>

f01044aa <_T_GPFLT_handler>:
TRAPHANDLER(_T_GPFLT_handler, T_GPFLT)
f01044aa:	6a 0d                	push   $0xd
f01044ac:	eb 44                	jmp    f01044f2 <_alltraps>

f01044ae <_T_PGFLT_handler>:
TRAPHANDLER(_T_PGFLT_handler, T_PGFLT)
f01044ae:	6a 0e                	push   $0xe
f01044b0:	eb 40                	jmp    f01044f2 <_alltraps>

f01044b2 <_T_FPERR_handler>:
TRAPHANDLER_NOEC(_T_FPERR_handler, T_FPERR)
f01044b2:	6a 00                	push   $0x0
f01044b4:	6a 10                	push   $0x10
f01044b6:	eb 3a                	jmp    f01044f2 <_alltraps>

f01044b8 <_T_ALIGN_handler>:
TRAPHANDLER(_T_ALIGN_handler, T_ALIGN)
f01044b8:	6a 11                	push   $0x11
f01044ba:	eb 36                	jmp    f01044f2 <_alltraps>

f01044bc <_T_MCHK_handler>:
TRAPHANDLER_NOEC(_T_MCHK_handler, T_MCHK)
f01044bc:	6a 00                	push   $0x0
f01044be:	6a 12                	push   $0x12
f01044c0:	eb 30                	jmp    f01044f2 <_alltraps>

f01044c2 <_T_SIMDERR_handler>:
TRAPHANDLER_NOEC(_T_SIMDERR_handler, T_SIMDERR)
f01044c2:	6a 00                	push   $0x0
f01044c4:	6a 13                	push   $0x13
f01044c6:	eb 2a                	jmp    f01044f2 <_alltraps>

f01044c8 <_T_SYSCALL_handler>:
TRAPHANDLER_NOEC(_T_SYSCALL_handler, T_SYSCALL)
f01044c8:	6a 00                	push   $0x0
f01044ca:	6a 30                	push   $0x30
f01044cc:	eb 24                	jmp    f01044f2 <_alltraps>

f01044ce <_IRQ_TIMER_handler>:

TRAPHANDLER_NOEC(_IRQ_TIMER_handler, IRQ_TIMER + IRQ_OFFSET)
f01044ce:	6a 00                	push   $0x0
f01044d0:	6a 20                	push   $0x20
f01044d2:	eb 1e                	jmp    f01044f2 <_alltraps>

f01044d4 <_IRQ_KBD_handler>:
TRAPHANDLER_NOEC(_IRQ_KBD_handler, IRQ_KBD + IRQ_OFFSET)
f01044d4:	6a 00                	push   $0x0
f01044d6:	6a 21                	push   $0x21
f01044d8:	eb 18                	jmp    f01044f2 <_alltraps>

f01044da <_IRQ_SERIAL_handler>:
TRAPHANDLER_NOEC(_IRQ_SERIAL_handler, IRQ_SERIAL + IRQ_OFFSET)
f01044da:	6a 00                	push   $0x0
f01044dc:	6a 24                	push   $0x24
f01044de:	eb 12                	jmp    f01044f2 <_alltraps>

f01044e0 <_IRQ_SPURIOUS_handler>:
TRAPHANDLER_NOEC(_IRQ_SPURIOUS_handler, IRQ_SPURIOUS + IRQ_OFFSET)
f01044e0:	6a 00                	push   $0x0
f01044e2:	6a 27                	push   $0x27
f01044e4:	eb 0c                	jmp    f01044f2 <_alltraps>

f01044e6 <_IRQ_IDE_handler>:
TRAPHANDLER_NOEC(_IRQ_IDE_handler, IRQ_IDE + IRQ_OFFSET)
f01044e6:	6a 00                	push   $0x0
f01044e8:	6a 2e                	push   $0x2e
f01044ea:	eb 06                	jmp    f01044f2 <_alltraps>

f01044ec <_IRQ_ERROR_handler>:
TRAPHANDLER_NOEC(_IRQ_ERROR_handler, IRQ_ERROR + IRQ_OFFSET)
f01044ec:	6a 00                	push   $0x0
f01044ee:	6a 33                	push   $0x33
f01044f0:	eb 00                	jmp    f01044f2 <_alltraps>

f01044f2 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */

_alltraps:
	pushl %ds
f01044f2:	1e                   	push   %ds
	pushl %es
f01044f3:	06                   	push   %es
	pushal	/* push all general registers */
f01044f4:	60                   	pusha  

	movl $GD_KD, %eax
f01044f5:	b8 10 00 00 00       	mov    $0x10,%eax
	movl %eax, %ds
f01044fa:	8e d8                	mov    %eax,%ds
	movl %eax, %es
f01044fc:	8e c0                	mov    %eax,%es

	push %esp
f01044fe:	54                   	push   %esp
f01044ff:	e8 10 fd ff ff       	call   f0104214 <trap>

f0104504 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104504:	55                   	push   %ebp
f0104505:	89 e5                	mov    %esp,%ebp
f0104507:	83 ec 08             	sub    $0x8,%esp
f010450a:	a1 48 92 2a f0       	mov    0xf02a9248,%eax
f010450f:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104512:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104517:	8b 02                	mov    (%edx),%eax
f0104519:	83 e8 01             	sub    $0x1,%eax
f010451c:	83 f8 02             	cmp    $0x2,%eax
f010451f:	76 10                	jbe    f0104531 <sched_halt+0x2d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104521:	83 c1 01             	add    $0x1,%ecx
f0104524:	83 c2 7c             	add    $0x7c,%edx
f0104527:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f010452d:	75 e8                	jne    f0104517 <sched_halt+0x13>
f010452f:	eb 08                	jmp    f0104539 <sched_halt+0x35>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0104531:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104537:	75 1f                	jne    f0104558 <sched_halt+0x54>
		cprintf("No runnable environments in the system!\n");
f0104539:	83 ec 0c             	sub    $0xc,%esp
f010453c:	68 50 82 10 f0       	push   $0xf0108250
f0104541:	e8 4b f4 ff ff       	call   f0103991 <cprintf>
f0104546:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0104549:	83 ec 0c             	sub    $0xc,%esp
f010454c:	6a 00                	push   $0x0
f010454e:	e8 6d c4 ff ff       	call   f01009c0 <monitor>
f0104553:	83 c4 10             	add    $0x10,%esp
f0104556:	eb f1                	jmp    f0104549 <sched_halt+0x45>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104558:	e8 31 18 00 00       	call   f0105d8e <cpunum>
f010455d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104560:	c7 80 28 a0 2a f0 00 	movl   $0x0,-0xfd55fd8(%eax)
f0104567:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f010456a:	a1 a4 9e 2a f0       	mov    0xf02a9ea4,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010456f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104574:	77 12                	ja     f0104588 <sched_halt+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104576:	50                   	push   %eax
f0104577:	68 c8 69 10 f0       	push   $0xf01069c8
f010457c:	6a 52                	push   $0x52
f010457e:	68 79 82 10 f0       	push   $0xf0108279
f0104583:	e8 b8 ba ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104588:	05 00 00 00 10       	add    $0x10000000,%eax
f010458d:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104590:	e8 f9 17 00 00       	call   f0105d8e <cpunum>
f0104595:	6b d0 74             	imul   $0x74,%eax,%edx
f0104598:	81 c2 20 a0 2a f0    	add    $0xf02aa020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f010459e:	b8 02 00 00 00       	mov    $0x2,%eax
f01045a3:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01045a7:	83 ec 0c             	sub    $0xc,%esp
f01045aa:	68 c0 23 12 f0       	push   $0xf01223c0
f01045af:	e8 e5 1a 00 00       	call   f0106099 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01045b4:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f01045b6:	e8 d3 17 00 00       	call   f0105d8e <cpunum>
f01045bb:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f01045be:	8b 80 30 a0 2a f0    	mov    -0xfd55fd0(%eax),%eax
f01045c4:	bd 00 00 00 00       	mov    $0x0,%ebp
f01045c9:	89 c4                	mov    %eax,%esp
f01045cb:	6a 00                	push   $0x0
f01045cd:	6a 00                	push   $0x0
f01045cf:	fb                   	sti    
f01045d0:	f4                   	hlt    
f01045d1:	eb fd                	jmp    f01045d0 <sched_halt+0xcc>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f01045d3:	83 c4 10             	add    $0x10,%esp
f01045d6:	c9                   	leave  
f01045d7:	c3                   	ret    

f01045d8 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f01045d8:	55                   	push   %ebp
f01045d9:	89 e5                	mov    %esp,%ebp
f01045db:	56                   	push   %esi
f01045dc:	53                   	push   %ebx
	// below to halt the cpu.

	// LAB 4: Your code here.
	// cprintf("[yield]\n");

	struct Env *now = thiscpu->cpu_env;
f01045dd:	e8 ac 17 00 00       	call   f0105d8e <cpunum>
f01045e2:	6b c0 74             	imul   $0x74,%eax,%eax
f01045e5:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
    int32_t startid = (now) ? ENVX(now->env_id): 0;
f01045eb:	85 c0                	test   %eax,%eax
f01045ed:	74 0b                	je     f01045fa <sched_yield+0x22>
f01045ef:	8b 50 48             	mov    0x48(%eax),%edx
f01045f2:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01045f8:	eb 05                	jmp    f01045ff <sched_yield+0x27>
f01045fa:	ba 00 00 00 00       	mov    $0x0,%edx
    int32_t nextid;
    size_t i;

    for(i = 0; i < NENV; i++) {
        nextid = (startid+i)%NENV;
        if(envs[nextid].env_status == ENV_RUNNABLE) {
f01045ff:	8b 0d 48 92 2a f0    	mov    0xf02a9248,%ecx
f0104605:	89 d6                	mov    %edx,%esi
f0104607:	8d 9a 00 04 00 00    	lea    0x400(%edx),%ebx
f010460d:	89 d0                	mov    %edx,%eax
f010460f:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104614:	6b c0 7c             	imul   $0x7c,%eax,%eax
f0104617:	01 c8                	add    %ecx,%eax
f0104619:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f010461d:	75 09                	jne    f0104628 <sched_yield+0x50>
                env_run(&envs[nextid]);
f010461f:	83 ec 0c             	sub    $0xc,%esp
f0104622:	50                   	push   %eax
f0104623:	e8 f1 f0 ff ff       	call   f0103719 <env_run>
f0104628:	83 c2 01             	add    $0x1,%edx
	struct Env *now = thiscpu->cpu_env;
    int32_t startid = (now) ? ENVX(now->env_id): 0;
    int32_t nextid;
    size_t i;

    for(i = 0; i < NENV; i++) {
f010462b:	39 da                	cmp    %ebx,%edx
f010462d:	75 de                	jne    f010460d <sched_yield+0x35>
                env_run(&envs[nextid]);
                return;
            }
    }
    
    if(envs[startid].env_status == ENV_RUNNING && envs[startid].env_cpunum == cpunum()) {
f010462f:	6b f6 7c             	imul   $0x7c,%esi,%esi
f0104632:	01 f1                	add    %esi,%ecx
f0104634:	83 79 54 03          	cmpl   $0x3,0x54(%ecx)
f0104638:	75 1b                	jne    f0104655 <sched_yield+0x7d>
f010463a:	8b 59 5c             	mov    0x5c(%ecx),%ebx
f010463d:	e8 4c 17 00 00       	call   f0105d8e <cpunum>
f0104642:	39 c3                	cmp    %eax,%ebx
f0104644:	75 0f                	jne    f0104655 <sched_yield+0x7d>
        env_run(&envs[startid]);
f0104646:	83 ec 0c             	sub    $0xc,%esp
f0104649:	03 35 48 92 2a f0    	add    0xf02a9248,%esi
f010464f:	56                   	push   %esi
f0104650:	e8 c4 f0 ff ff       	call   f0103719 <env_run>
    }

	// cprintf("[halt]\n");

	// sched_halt never returns
	sched_halt();
f0104655:	e8 aa fe ff ff       	call   f0104504 <sched_halt>
}
f010465a:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010465d:	5b                   	pop    %ebx
f010465e:	5e                   	pop    %esi
f010465f:	5d                   	pop    %ebp
f0104660:	c3                   	ret    

f0104661 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104661:	55                   	push   %ebp
f0104662:	89 e5                	mov    %esp,%ebp
f0104664:	57                   	push   %edi
f0104665:	56                   	push   %esi
f0104666:	53                   	push   %ebx
f0104667:	83 ec 1c             	sub    $0x1c,%esp
f010466a:	8b 45 08             	mov    0x8(%ebp),%eax
	// Return any appropriate return value.
	// LAB 3: Your code here.

	// panic("syscall not implemented");

	switch (syscallno) {
f010466d:	83 f8 0d             	cmp    $0xd,%eax
f0104670:	0f 87 57 05 00 00    	ja     f0104bcd <syscall+0x56c>
f0104676:	ff 24 85 8c 82 10 f0 	jmp    *-0xfef7d74(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, 0);		// just check if PTE_U is set
f010467d:	e8 0c 17 00 00       	call   f0105d8e <cpunum>
f0104682:	6a 00                	push   $0x0
f0104684:	ff 75 10             	pushl  0x10(%ebp)
f0104687:	ff 75 0c             	pushl  0xc(%ebp)
f010468a:	6b c0 74             	imul   $0x74,%eax,%eax
f010468d:	ff b0 28 a0 2a f0    	pushl  -0xfd55fd8(%eax)
f0104693:	e8 bf e9 ff ff       	call   f0103057 <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104698:	83 c4 0c             	add    $0xc,%esp
f010469b:	ff 75 0c             	pushl  0xc(%ebp)
f010469e:	ff 75 10             	pushl  0x10(%ebp)
f01046a1:	68 86 82 10 f0       	push   $0xf0108286
f01046a6:	e8 e6 f2 ff ff       	call   f0103991 <cprintf>
f01046ab:	83 c4 10             	add    $0x10,%esp
	// panic("syscall not implemented");

	switch (syscallno) {
		case SYS_cputs:
			sys_cputs((char *)a1, a2);
			return 0;
f01046ae:	bb 00 00 00 00       	mov    $0x0,%ebx
f01046b3:	e9 21 05 00 00       	jmp    f0104bd9 <syscall+0x578>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f01046b8:	e8 4e bf ff ff       	call   f010060b <cons_getc>
f01046bd:	89 c3                	mov    %eax,%ebx
	switch (syscallno) {
		case SYS_cputs:
			sys_cputs((char *)a1, a2);
			return 0;
		case SYS_cgetc:
			return sys_cgetc();
f01046bf:	e9 15 05 00 00       	jmp    f0104bd9 <syscall+0x578>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f01046c4:	e8 c5 16 00 00       	call   f0105d8e <cpunum>
f01046c9:	6b c0 74             	imul   $0x74,%eax,%eax
f01046cc:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
f01046d2:	8b 58 48             	mov    0x48(%eax),%ebx
			sys_cputs((char *)a1, a2);
			return 0;
		case SYS_cgetc:
			return sys_cgetc();
		case SYS_getenvid:
			return sys_getenvid();
f01046d5:	e9 ff 04 00 00       	jmp    f0104bd9 <syscall+0x578>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01046da:	83 ec 04             	sub    $0x4,%esp
f01046dd:	6a 01                	push   $0x1
f01046df:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01046e2:	50                   	push   %eax
f01046e3:	ff 75 0c             	pushl  0xc(%ebp)
f01046e6:	e8 3a ea ff ff       	call   f0103125 <envid2env>
f01046eb:	83 c4 10             	add    $0x10,%esp
		return r;
f01046ee:	89 c3                	mov    %eax,%ebx
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01046f0:	85 c0                	test   %eax,%eax
f01046f2:	0f 88 e1 04 00 00    	js     f0104bd9 <syscall+0x578>
		return r;
	env_destroy(e);
f01046f8:	83 ec 0c             	sub    $0xc,%esp
f01046fb:	ff 75 e4             	pushl  -0x1c(%ebp)
f01046fe:	e8 77 ef ff ff       	call   f010367a <env_destroy>
f0104703:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104706:	bb 00 00 00 00       	mov    $0x0,%ebx
f010470b:	e9 c9 04 00 00       	jmp    f0104bd9 <syscall+0x578>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104710:	e8 c3 fe ff ff       	call   f01045d8 <sched_yield>
	// LAB 4: Your code here.
	// panic("sys_exofork not implemented");

	struct Env *newenv;

	int err = env_alloc(&newenv , curenv->env_id);
f0104715:	e8 74 16 00 00       	call   f0105d8e <cpunum>
f010471a:	83 ec 08             	sub    $0x8,%esp
f010471d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104720:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
f0104726:	ff 70 48             	pushl  0x48(%eax)
f0104729:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010472c:	50                   	push   %eax
f010472d:	e8 fe ea ff ff       	call   f0103230 <env_alloc>
	if (err < 0)
f0104732:	83 c4 10             	add    $0x10,%esp
		return err;
f0104735:	89 c3                	mov    %eax,%ebx
	// panic("sys_exofork not implemented");

	struct Env *newenv;

	int err = env_alloc(&newenv , curenv->env_id);
	if (err < 0)
f0104737:	85 c0                	test   %eax,%eax
f0104739:	0f 88 9a 04 00 00    	js     f0104bd9 <syscall+0x578>
		return err;

	// memcpy(&newenv->env_tf, &curenv->env_tf, sizeof(struct Trapframe));
	newenv->env_tf = curenv->env_tf;
f010473f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104742:	e8 47 16 00 00       	call   f0105d8e <cpunum>
f0104747:	6b c0 74             	imul   $0x74,%eax,%eax
f010474a:	8b b0 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%esi
f0104750:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104755:	89 df                	mov    %ebx,%edi
f0104757:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	newenv->env_status = ENV_NOT_RUNNABLE;
f0104759:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010475c:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)

	// tweak newenv, to make it appear to return 0
	newenv->env_tf.tf_regs.reg_eax = 0;
f0104763:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

	return newenv->env_id;
f010476a:	8b 58 48             	mov    0x48(%eax),%ebx
f010476d:	e9 67 04 00 00       	jmp    f0104bd9 <syscall+0x578>

	// LAB 4: Your code here.
	// panic("sys_env_set_status not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
f0104772:	83 ec 04             	sub    $0x4,%esp
f0104775:	6a 01                	push   $0x1
f0104777:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010477a:	50                   	push   %eax
f010477b:	ff 75 0c             	pushl  0xc(%ebp)
f010477e:	e8 a2 e9 ff ff       	call   f0103125 <envid2env>
	if (err < 0)
f0104783:	83 c4 10             	add    $0x10,%esp
f0104786:	85 c0                	test   %eax,%eax
f0104788:	78 20                	js     f01047aa <syscall+0x149>
		return err;

	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
f010478a:	8b 45 10             	mov    0x10(%ebp),%eax
f010478d:	83 e8 02             	sub    $0x2,%eax
f0104790:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f0104795:	75 1a                	jne    f01047b1 <syscall+0x150>
		return -E_INVAL;

	env_store->env_status = status;
f0104797:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010479a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010479d:	89 48 54             	mov    %ecx,0x54(%eax)

	return 0;
f01047a0:	bb 00 00 00 00       	mov    $0x0,%ebx
f01047a5:	e9 2f 04 00 00       	jmp    f0104bd9 <syscall+0x578>
	// panic("sys_env_set_status not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
	if (err < 0)
		return err;
f01047aa:	89 c3                	mov    %eax,%ebx
f01047ac:	e9 28 04 00 00       	jmp    f0104bd9 <syscall+0x578>

	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
		return -E_INVAL;
f01047b1:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			sys_yield();
			return 0;
		case SYS_exofork:
			return sys_exofork();
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1, a2);
f01047b6:	e9 1e 04 00 00       	jmp    f0104bd9 <syscall+0x578>

	// LAB 4: Your code here.
	// panic("sys_page_alloc not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
f01047bb:	83 ec 04             	sub    $0x4,%esp
f01047be:	6a 01                	push   $0x1
f01047c0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01047c3:	50                   	push   %eax
f01047c4:	ff 75 0c             	pushl  0xc(%ebp)
f01047c7:	e8 59 e9 ff ff       	call   f0103125 <envid2env>
	if (err < 0)
f01047cc:	83 c4 10             	add    $0x10,%esp
f01047cf:	85 c0                	test   %eax,%eax
f01047d1:	78 6b                	js     f010483e <syscall+0x1dd>
		return err;	// E_BAD_ENV

	if ((perm | PTE_AVAIL | PTE_W) != (PTE_AVAIL | PTE_W | PTE_U | PTE_P))
		return -E_INVAL;

	if ((uint32_t)va >= UTOP || ((uint32_t) va % PGSIZE) != 0)
f01047d3:	8b 45 14             	mov    0x14(%ebp),%eax
f01047d6:	0d 02 0e 00 00       	or     $0xe02,%eax
f01047db:	3d 07 0e 00 00       	cmp    $0xe07,%eax
f01047e0:	75 63                	jne    f0104845 <syscall+0x1e4>
f01047e2:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01047e9:	77 5a                	ja     f0104845 <syscall+0x1e4>
f01047eb:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01047f2:	75 5b                	jne    f010484f <syscall+0x1ee>
		return -E_INVAL;
	
	struct PageInfo * pp = page_alloc(ALLOC_ZERO);
f01047f4:	83 ec 0c             	sub    $0xc,%esp
f01047f7:	6a 01                	push   $0x1
f01047f9:	e8 a2 c8 ff ff       	call   f01010a0 <page_alloc>
f01047fe:	89 c6                	mov    %eax,%esi
	if (pp == NULL)
f0104800:	83 c4 10             	add    $0x10,%esp
f0104803:	85 c0                	test   %eax,%eax
f0104805:	74 52                	je     f0104859 <syscall+0x1f8>
		return -E_NO_MEM;
	
	err = page_insert(env_store->env_pgdir, pp, va, perm);
f0104807:	ff 75 14             	pushl  0x14(%ebp)
f010480a:	ff 75 10             	pushl  0x10(%ebp)
f010480d:	50                   	push   %eax
f010480e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104811:	ff 70 60             	pushl  0x60(%eax)
f0104814:	e8 7a cc ff ff       	call   f0101493 <page_insert>
f0104819:	89 c7                	mov    %eax,%edi
	if (err < 0) {
f010481b:	83 c4 10             	add    $0x10,%esp
		page_free(pp);
		return err; // E_NO_MEM
	}

	return 0;
f010481e:	bb 00 00 00 00       	mov    $0x0,%ebx
	struct PageInfo * pp = page_alloc(ALLOC_ZERO);
	if (pp == NULL)
		return -E_NO_MEM;
	
	err = page_insert(env_store->env_pgdir, pp, va, perm);
	if (err < 0) {
f0104823:	85 c0                	test   %eax,%eax
f0104825:	0f 89 ae 03 00 00    	jns    f0104bd9 <syscall+0x578>
		page_free(pp);
f010482b:	83 ec 0c             	sub    $0xc,%esp
f010482e:	56                   	push   %esi
f010482f:	e8 dd c8 ff ff       	call   f0101111 <page_free>
f0104834:	83 c4 10             	add    $0x10,%esp
		return err; // E_NO_MEM
f0104837:	89 fb                	mov    %edi,%ebx
f0104839:	e9 9b 03 00 00       	jmp    f0104bd9 <syscall+0x578>
	// panic("sys_page_alloc not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
	if (err < 0)
		return err;	// E_BAD_ENV
f010483e:	89 c3                	mov    %eax,%ebx
f0104840:	e9 94 03 00 00       	jmp    f0104bd9 <syscall+0x578>

	if ((perm | PTE_AVAIL | PTE_W) != (PTE_AVAIL | PTE_W | PTE_U | PTE_P))
		return -E_INVAL;

	if ((uint32_t)va >= UTOP || ((uint32_t) va % PGSIZE) != 0)
		return -E_INVAL;
f0104845:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010484a:	e9 8a 03 00 00       	jmp    f0104bd9 <syscall+0x578>
f010484f:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104854:	e9 80 03 00 00       	jmp    f0104bd9 <syscall+0x578>
	
	struct PageInfo * pp = page_alloc(ALLOC_ZERO);
	if (pp == NULL)
		return -E_NO_MEM;
f0104859:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f010485e:	e9 76 03 00 00       	jmp    f0104bd9 <syscall+0x578>
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	// panic("sys_page_map not implemented");

	if ((uint32_t)srcva >= UTOP || ((uint32_t)srcva % PGSIZE) != 0 || (uint32_t)dstva >= UTOP || ((uint32_t)dstva % PGSIZE != 0))
f0104863:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f010486a:	0f 87 c2 00 00 00    	ja     f0104932 <syscall+0x2d1>
f0104870:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104877:	0f 85 bf 00 00 00    	jne    f010493c <syscall+0x2db>
f010487d:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104884:	0f 87 b2 00 00 00    	ja     f010493c <syscall+0x2db>
f010488a:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f0104891:	0f 85 af 00 00 00    	jne    f0104946 <syscall+0x2e5>
		return -E_INVAL;
	
	struct Env *srcenv, *dstenv;
	int err = envid2env(srcenvid, &srcenv, 1);
f0104897:	83 ec 04             	sub    $0x4,%esp
f010489a:	6a 01                	push   $0x1
f010489c:	8d 45 dc             	lea    -0x24(%ebp),%eax
f010489f:	50                   	push   %eax
f01048a0:	ff 75 0c             	pushl  0xc(%ebp)
f01048a3:	e8 7d e8 ff ff       	call   f0103125 <envid2env>
	if(err < 0)
f01048a8:	83 c4 10             	add    $0x10,%esp
		return err;	// E_BAD_ENV
f01048ab:	89 c3                	mov    %eax,%ebx
	if ((uint32_t)srcva >= UTOP || ((uint32_t)srcva % PGSIZE) != 0 || (uint32_t)dstva >= UTOP || ((uint32_t)dstva % PGSIZE != 0))
		return -E_INVAL;
	
	struct Env *srcenv, *dstenv;
	int err = envid2env(srcenvid, &srcenv, 1);
	if(err < 0)
f01048ad:	85 c0                	test   %eax,%eax
f01048af:	0f 88 24 03 00 00    	js     f0104bd9 <syscall+0x578>
		return err;	// E_BAD_ENV
	err = envid2env(dstenvid, &dstenv, 1);
f01048b5:	83 ec 04             	sub    $0x4,%esp
f01048b8:	6a 01                	push   $0x1
f01048ba:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01048bd:	50                   	push   %eax
f01048be:	ff 75 14             	pushl  0x14(%ebp)
f01048c1:	e8 5f e8 ff ff       	call   f0103125 <envid2env>
	if(err < 0)
f01048c6:	83 c4 10             	add    $0x10,%esp
		return err;	// E_BAD_ENV
f01048c9:	89 c3                	mov    %eax,%ebx
	struct Env *srcenv, *dstenv;
	int err = envid2env(srcenvid, &srcenv, 1);
	if(err < 0)
		return err;	// E_BAD_ENV
	err = envid2env(dstenvid, &dstenv, 1);
	if(err < 0)
f01048cb:	85 c0                	test   %eax,%eax
f01048cd:	0f 88 06 03 00 00    	js     f0104bd9 <syscall+0x578>
		return err;	// E_BAD_ENV

	pte_t *pte;
	struct PageInfo *pp = page_lookup(srcenv->env_pgdir, srcva, &pte);
f01048d3:	83 ec 04             	sub    $0x4,%esp
f01048d6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01048d9:	50                   	push   %eax
f01048da:	ff 75 10             	pushl  0x10(%ebp)
f01048dd:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01048e0:	ff 70 60             	pushl  0x60(%eax)
f01048e3:	e8 c3 ca ff ff       	call   f01013ab <page_lookup>
	if (pp == NULL) 
f01048e8:	83 c4 10             	add    $0x10,%esp
f01048eb:	85 c0                	test   %eax,%eax
f01048ed:	74 61                	je     f0104950 <syscall+0x2ef>
		return -E_INVAL;	// not mapped
	
	if ( ((*pte) & PTE_W) == 0 && (perm & PTE_W) != 0)
f01048ef:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01048f2:	f6 02 02             	testb  $0x2,(%edx)
f01048f5:	75 06                	jne    f01048fd <syscall+0x29c>
f01048f7:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f01048fb:	75 5d                	jne    f010495a <syscall+0x2f9>
		return -E_INVAL;	// read-only page

	// same perm restrictions as in sys_page_alloc
	if ((perm | PTE_AVAIL | PTE_W) != (PTE_AVAIL | PTE_W | PTE_U | PTE_P))
f01048fd:	8b 55 1c             	mov    0x1c(%ebp),%edx
f0104900:	81 ca 02 0e 00 00    	or     $0xe02,%edx
f0104906:	81 fa 07 0e 00 00    	cmp    $0xe07,%edx
f010490c:	75 56                	jne    f0104964 <syscall+0x303>
		return -E_INVAL;

	err = page_insert(dstenv->env_pgdir, pp, dstva, perm);
f010490e:	ff 75 1c             	pushl  0x1c(%ebp)
f0104911:	ff 75 18             	pushl  0x18(%ebp)
f0104914:	50                   	push   %eax
f0104915:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104918:	ff 70 60             	pushl  0x60(%eax)
f010491b:	e8 73 cb ff ff       	call   f0101493 <page_insert>
f0104920:	83 c4 10             	add    $0x10,%esp
f0104923:	85 c0                	test   %eax,%eax
f0104925:	bb 00 00 00 00       	mov    $0x0,%ebx
f010492a:	0f 4e d8             	cmovle %eax,%ebx
f010492d:	e9 a7 02 00 00       	jmp    f0104bd9 <syscall+0x578>

	// LAB 4: Your code here.
	// panic("sys_page_map not implemented");

	if ((uint32_t)srcva >= UTOP || ((uint32_t)srcva % PGSIZE) != 0 || (uint32_t)dstva >= UTOP || ((uint32_t)dstva % PGSIZE != 0))
		return -E_INVAL;
f0104932:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104937:	e9 9d 02 00 00       	jmp    f0104bd9 <syscall+0x578>
f010493c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104941:	e9 93 02 00 00       	jmp    f0104bd9 <syscall+0x578>
f0104946:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010494b:	e9 89 02 00 00       	jmp    f0104bd9 <syscall+0x578>
		return err;	// E_BAD_ENV

	pte_t *pte;
	struct PageInfo *pp = page_lookup(srcenv->env_pgdir, srcva, &pte);
	if (pp == NULL) 
		return -E_INVAL;	// not mapped
f0104950:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104955:	e9 7f 02 00 00       	jmp    f0104bd9 <syscall+0x578>
	
	if ( ((*pte) & PTE_W) == 0 && (perm & PTE_W) != 0)
		return -E_INVAL;	// read-only page
f010495a:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010495f:	e9 75 02 00 00       	jmp    f0104bd9 <syscall+0x578>

	// same perm restrictions as in sys_page_alloc
	if ((perm | PTE_AVAIL | PTE_W) != (PTE_AVAIL | PTE_W | PTE_U | PTE_P))
		return -E_INVAL;
f0104964:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1, a2);
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1, (void *)a2, a3);
		case SYS_page_map:
			return sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4, a5);
f0104969:	e9 6b 02 00 00       	jmp    f0104bd9 <syscall+0x578>
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	// panic("sys_page_unmap not implemented");

	if ((uint32_t)va >= UTOP || ((uint32_t) va % PGSIZE) != 0)
f010496e:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104975:	77 45                	ja     f01049bc <syscall+0x35b>
f0104977:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010497e:	75 46                	jne    f01049c6 <syscall+0x365>
		return -E_INVAL;

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
f0104980:	83 ec 04             	sub    $0x4,%esp
f0104983:	6a 01                	push   $0x1
f0104985:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104988:	50                   	push   %eax
f0104989:	ff 75 0c             	pushl  0xc(%ebp)
f010498c:	e8 94 e7 ff ff       	call   f0103125 <envid2env>
	if (err < 0)
f0104991:	83 c4 10             	add    $0x10,%esp
		return err;	// E_BAD_ENV
f0104994:	89 c3                	mov    %eax,%ebx
	if ((uint32_t)va >= UTOP || ((uint32_t) va % PGSIZE) != 0)
		return -E_INVAL;

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
	if (err < 0)
f0104996:	85 c0                	test   %eax,%eax
f0104998:	0f 88 3b 02 00 00    	js     f0104bd9 <syscall+0x578>
		return err;	// E_BAD_ENV

	page_remove(env_store->env_pgdir, va);
f010499e:	83 ec 08             	sub    $0x8,%esp
f01049a1:	ff 75 10             	pushl  0x10(%ebp)
f01049a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01049a7:	ff 70 60             	pushl  0x60(%eax)
f01049aa:	e8 97 ca ff ff       	call   f0101446 <page_remove>
f01049af:	83 c4 10             	add    $0x10,%esp

	return 0;
f01049b2:	bb 00 00 00 00       	mov    $0x0,%ebx
f01049b7:	e9 1d 02 00 00       	jmp    f0104bd9 <syscall+0x578>

	// LAB 4: Your code here.
	// panic("sys_page_unmap not implemented");

	if ((uint32_t)va >= UTOP || ((uint32_t) va % PGSIZE) != 0)
		return -E_INVAL;
f01049bc:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049c1:	e9 13 02 00 00       	jmp    f0104bd9 <syscall+0x578>
f01049c6:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049cb:	e9 09 02 00 00       	jmp    f0104bd9 <syscall+0x578>
{
	// LAB 4: Your code here.
	// panic("sys_env_set_pgfault_upcall not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
f01049d0:	83 ec 04             	sub    $0x4,%esp
f01049d3:	6a 01                	push   $0x1
f01049d5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01049d8:	50                   	push   %eax
f01049d9:	ff 75 0c             	pushl  0xc(%ebp)
f01049dc:	e8 44 e7 ff ff       	call   f0103125 <envid2env>
	if (err < 0)
f01049e1:	83 c4 10             	add    $0x10,%esp
f01049e4:	85 c0                	test   %eax,%eax
f01049e6:	78 13                	js     f01049fb <syscall+0x39a>
		return err;

	env_store->env_pgfault_upcall = func;
f01049e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01049eb:	8b 55 10             	mov    0x10(%ebp),%edx
f01049ee:	89 50 64             	mov    %edx,0x64(%eax)

	return 0;
f01049f1:	bb 00 00 00 00       	mov    $0x0,%ebx
f01049f6:	e9 de 01 00 00       	jmp    f0104bd9 <syscall+0x578>
	// panic("sys_env_set_pgfault_upcall not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
	if (err < 0)
		return err;
f01049fb:	89 c3                	mov    %eax,%ebx
		case SYS_page_map:
			return sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4, a5);
		case SYS_page_unmap:
			return sys_page_unmap((envid_t)a1, (void *)a2);
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
f01049fd:	e9 d7 01 00 00       	jmp    f0104bd9 <syscall+0x578>
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	// panic("sys_ipc_recv not implemented");

	if ((uint32_t)dstva < UTOP) {
f0104a02:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0104a09:	77 21                	ja     f0104a2c <syscall+0x3cb>
		if ((uint32_t)dstva % PGSIZE != 0)
f0104a0b:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0104a12:	0f 85 bc 01 00 00    	jne    f0104bd4 <syscall+0x573>
			return -E_INVAL;
		curenv->env_ipc_dstva = dstva;
f0104a18:	e8 71 13 00 00       	call   f0105d8e <cpunum>
f0104a1d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a20:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
f0104a26:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104a29:	89 78 6c             	mov    %edi,0x6c(%eax)
	}

	// set recving flags
	curenv->env_ipc_recving = true;
f0104a2c:	e8 5d 13 00 00       	call   f0105d8e <cpunum>
f0104a31:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a34:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
f0104a3a:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_from = 0;
f0104a3e:	e8 4b 13 00 00       	call   f0105d8e <cpunum>
f0104a43:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a46:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
f0104a4c:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)

	// mark yourself not runnable, and then give up the CPU.
	curenv->env_status = ENV_NOT_RUNNABLE;
f0104a53:	e8 36 13 00 00       	call   f0105d8e <cpunum>
f0104a58:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a5b:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
f0104a61:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	sched_yield();
f0104a68:	e8 6b fb ff ff       	call   f01045d8 <sched_yield>
{
	// LAB 4: Your code here.
	// panic("sys_ipc_try_send not implemented");

	struct Env *env;
	int err = envid2env(envid, &env, 0);
f0104a6d:	83 ec 04             	sub    $0x4,%esp
f0104a70:	6a 00                	push   $0x0
f0104a72:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104a75:	50                   	push   %eax
f0104a76:	ff 75 0c             	pushl  0xc(%ebp)
f0104a79:	e8 a7 e6 ff ff       	call   f0103125 <envid2env>
	if(err < 0)
f0104a7e:	83 c4 10             	add    $0x10,%esp
f0104a81:	85 c0                	test   %eax,%eax
f0104a83:	0f 88 02 01 00 00    	js     f0104b8b <syscall+0x52a>
		return err;	// E_BAD_ENV
	
	// not recving, or already recving
	if (env->env_ipc_recving != true || env->env_ipc_from != 0)
f0104a89:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104a8c:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0104a90:	0f 84 f9 00 00 00    	je     f0104b8f <syscall+0x52e>
f0104a96:	8b 58 74             	mov    0x74(%eax),%ebx
f0104a99:	85 db                	test   %ebx,%ebx
f0104a9b:	0f 85 f5 00 00 00    	jne    f0104b96 <syscall+0x535>

	// first check if the recver is willing to recv a page
	// any error happens, fall fast
	if (env->env_ipc_dstva != 0) {
		
		if ((uint32_t)srcva < UTOP) {
f0104aa1:	83 78 6c 00          	cmpl   $0x0,0x6c(%eax)
f0104aa5:	0f 84 ac 00 00 00    	je     f0104b57 <syscall+0x4f6>
f0104aab:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104ab2:	0f 87 9f 00 00 00    	ja     f0104b57 <syscall+0x4f6>
			if ((uint32_t)srcva % PGSIZE != 0)
f0104ab8:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0104abf:	75 64                	jne    f0104b25 <syscall+0x4c4>
				return -E_INVAL;
			if ((perm & (PTE_P | PTE_U)) != (PTE_P | PTE_U))
f0104ac1:	8b 45 18             	mov    0x18(%ebp),%eax
f0104ac4:	83 e0 05             	and    $0x5,%eax
f0104ac7:	83 f8 05             	cmp    $0x5,%eax
f0104aca:	75 63                	jne    f0104b2f <syscall+0x4ce>
            	return -E_INVAL;

			pte_t *pte;
			struct PageInfo *pp = page_lookup(curenv->env_pgdir, srcva, &pte);
f0104acc:	e8 bd 12 00 00       	call   f0105d8e <cpunum>
f0104ad1:	83 ec 04             	sub    $0x4,%esp
f0104ad4:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104ad7:	52                   	push   %edx
f0104ad8:	ff 75 14             	pushl  0x14(%ebp)
f0104adb:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ade:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
f0104ae4:	ff 70 60             	pushl  0x60(%eax)
f0104ae7:	e8 bf c8 ff ff       	call   f01013ab <page_lookup>
			if (!pp) 
f0104aec:	83 c4 10             	add    $0x10,%esp
f0104aef:	85 c0                	test   %eax,%eax
f0104af1:	74 46                	je     f0104b39 <syscall+0x4d8>
				return -E_INVAL;  
			
			if ((perm & PTE_W) && ((size_t) *pte & PTE_W) != PTE_W) 
f0104af3:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104af7:	74 08                	je     f0104b01 <syscall+0x4a0>
f0104af9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104afc:	f6 02 02             	testb  $0x2,(%edx)
f0104aff:	74 42                	je     f0104b43 <syscall+0x4e2>
				return -E_INVAL;

			if (page_insert(env->env_pgdir, pp, env->env_ipc_dstva, perm) < 0) 
f0104b01:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104b04:	ff 75 18             	pushl  0x18(%ebp)
f0104b07:	ff 72 6c             	pushl  0x6c(%edx)
f0104b0a:	50                   	push   %eax
f0104b0b:	ff 72 60             	pushl  0x60(%edx)
f0104b0e:	e8 80 c9 ff ff       	call   f0101493 <page_insert>
f0104b13:	83 c4 10             	add    $0x10,%esp
f0104b16:	85 c0                	test   %eax,%eax
f0104b18:	78 33                	js     f0104b4d <syscall+0x4ec>
				return -E_NO_MEM;
			
			env->env_ipc_perm = perm;
f0104b1a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b1d:	8b 7d 18             	mov    0x18(%ebp),%edi
f0104b20:	89 78 78             	mov    %edi,0x78(%eax)
f0104b23:	eb 32                	jmp    f0104b57 <syscall+0x4f6>
	// any error happens, fall fast
	if (env->env_ipc_dstva != 0) {
		
		if ((uint32_t)srcva < UTOP) {
			if ((uint32_t)srcva % PGSIZE != 0)
				return -E_INVAL;
f0104b25:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b2a:	e9 aa 00 00 00       	jmp    f0104bd9 <syscall+0x578>
			if ((perm & (PTE_P | PTE_U)) != (PTE_P | PTE_U))
            	return -E_INVAL;
f0104b2f:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b34:	e9 a0 00 00 00       	jmp    f0104bd9 <syscall+0x578>

			pte_t *pte;
			struct PageInfo *pp = page_lookup(curenv->env_pgdir, srcva, &pte);
			if (!pp) 
				return -E_INVAL;  
f0104b39:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b3e:	e9 96 00 00 00       	jmp    f0104bd9 <syscall+0x578>
			
			if ((perm & PTE_W) && ((size_t) *pte & PTE_W) != PTE_W) 
				return -E_INVAL;
f0104b43:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b48:	e9 8c 00 00 00       	jmp    f0104bd9 <syscall+0x578>

			if (page_insert(env->env_pgdir, pp, env->env_ipc_dstva, perm) < 0) 
				return -E_NO_MEM;
f0104b4d:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f0104b52:	e9 82 00 00 00       	jmp    f0104bd9 <syscall+0x578>
			env->env_ipc_perm = perm;
		}

	}

	env->env_ipc_from = curenv->env_id;
f0104b57:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104b5a:	e8 2f 12 00 00       	call   f0105d8e <cpunum>
f0104b5f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b62:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
f0104b68:	8b 40 48             	mov    0x48(%eax),%eax
f0104b6b:	89 46 74             	mov    %eax,0x74(%esi)
	env->env_ipc_recving = false;
f0104b6e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b71:	c6 40 68 00          	movb   $0x0,0x68(%eax)
	env->env_ipc_value = value;
f0104b75:	8b 55 10             	mov    0x10(%ebp),%edx
f0104b78:	89 50 70             	mov    %edx,0x70(%eax)
	env->env_status = ENV_RUNNABLE;
f0104b7b:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)

	// make the recver return 0
	env->env_tf.tf_regs.reg_eax = 0;
f0104b82:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
f0104b89:	eb 4e                	jmp    f0104bd9 <syscall+0x578>
	// panic("sys_ipc_try_send not implemented");

	struct Env *env;
	int err = envid2env(envid, &env, 0);
	if(err < 0)
		return err;	// E_BAD_ENV
f0104b8b:	89 c3                	mov    %eax,%ebx
f0104b8d:	eb 4a                	jmp    f0104bd9 <syscall+0x578>
	
	// not recving, or already recving
	if (env->env_ipc_recving != true || env->env_ipc_from != 0)
		return -E_IPC_NOT_RECV;
f0104b8f:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f0104b94:	eb 43                	jmp    f0104bd9 <syscall+0x578>
f0104b96:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
		case SYS_ipc_recv:
			return sys_ipc_recv((void *)a1);
		case SYS_ipc_try_send:
			return sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned)a4);
f0104b9b:	eb 3c                	jmp    f0104bd9 <syscall+0x578>
		case SYS_env_set_trapframe:
			return sys_env_set_trapframe((envid_t)a1, (struct Trapframe *)a2);
f0104b9d:	8b 75 10             	mov    0x10(%ebp),%esi
	// Remember to check whether the user has supplied us with a good
	// address!
	// panic("sys_env_set_trapframe not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
f0104ba0:	83 ec 04             	sub    $0x4,%esp
f0104ba3:	6a 01                	push   $0x1
f0104ba5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104ba8:	50                   	push   %eax
f0104ba9:	ff 75 0c             	pushl  0xc(%ebp)
f0104bac:	e8 74 e5 ff ff       	call   f0103125 <envid2env>
	if (err < 0)
f0104bb1:	83 c4 10             	add    $0x10,%esp
f0104bb4:	85 c0                	test   %eax,%eax
f0104bb6:	78 11                	js     f0104bc9 <syscall+0x568>
		return err;
	
	env_store->env_tf = *tf;
f0104bb8:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104bbd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104bc0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

	return 0;
f0104bc2:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104bc7:	eb 10                	jmp    f0104bd9 <syscall+0x578>
	// panic("sys_env_set_trapframe not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
	if (err < 0)
		return err;
f0104bc9:	89 c3                	mov    %eax,%ebx
		case SYS_ipc_recv:
			return sys_ipc_recv((void *)a1);
		case SYS_ipc_try_send:
			return sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned)a4);
		case SYS_env_set_trapframe:
			return sys_env_set_trapframe((envid_t)a1, (struct Trapframe *)a2);
f0104bcb:	eb 0c                	jmp    f0104bd9 <syscall+0x578>
		default:
			return -E_INVAL;
f0104bcd:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104bd2:	eb 05                	jmp    f0104bd9 <syscall+0x578>
		case SYS_page_unmap:
			return sys_page_unmap((envid_t)a1, (void *)a2);
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
		case SYS_ipc_recv:
			return sys_ipc_recv((void *)a1);
f0104bd4:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		case SYS_env_set_trapframe:
			return sys_env_set_trapframe((envid_t)a1, (struct Trapframe *)a2);
		default:
			return -E_INVAL;
	}
}
f0104bd9:	89 d8                	mov    %ebx,%eax
f0104bdb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104bde:	5b                   	pop    %ebx
f0104bdf:	5e                   	pop    %esi
f0104be0:	5f                   	pop    %edi
f0104be1:	5d                   	pop    %ebp
f0104be2:	c3                   	ret    

f0104be3 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104be3:	55                   	push   %ebp
f0104be4:	89 e5                	mov    %esp,%ebp
f0104be6:	57                   	push   %edi
f0104be7:	56                   	push   %esi
f0104be8:	53                   	push   %ebx
f0104be9:	83 ec 14             	sub    $0x14,%esp
f0104bec:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104bef:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104bf2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104bf5:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104bf8:	8b 1a                	mov    (%edx),%ebx
f0104bfa:	8b 01                	mov    (%ecx),%eax
f0104bfc:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104bff:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104c06:	eb 7f                	jmp    f0104c87 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0104c08:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104c0b:	01 d8                	add    %ebx,%eax
f0104c0d:	89 c6                	mov    %eax,%esi
f0104c0f:	c1 ee 1f             	shr    $0x1f,%esi
f0104c12:	01 c6                	add    %eax,%esi
f0104c14:	d1 fe                	sar    %esi
f0104c16:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0104c19:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104c1c:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104c1f:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104c21:	eb 03                	jmp    f0104c26 <stab_binsearch+0x43>
			m--;
f0104c23:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104c26:	39 c3                	cmp    %eax,%ebx
f0104c28:	7f 0d                	jg     f0104c37 <stab_binsearch+0x54>
f0104c2a:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104c2e:	83 ea 0c             	sub    $0xc,%edx
f0104c31:	39 f9                	cmp    %edi,%ecx
f0104c33:	75 ee                	jne    f0104c23 <stab_binsearch+0x40>
f0104c35:	eb 05                	jmp    f0104c3c <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104c37:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0104c3a:	eb 4b                	jmp    f0104c87 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104c3c:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104c3f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104c42:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104c46:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104c49:	76 11                	jbe    f0104c5c <stab_binsearch+0x79>
			*region_left = m;
f0104c4b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104c4e:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104c50:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104c53:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104c5a:	eb 2b                	jmp    f0104c87 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104c5c:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104c5f:	73 14                	jae    f0104c75 <stab_binsearch+0x92>
			*region_right = m - 1;
f0104c61:	83 e8 01             	sub    $0x1,%eax
f0104c64:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104c67:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104c6a:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104c6c:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104c73:	eb 12                	jmp    f0104c87 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104c75:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104c78:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0104c7a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104c7e:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104c80:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104c87:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104c8a:	0f 8e 78 ff ff ff    	jle    f0104c08 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104c90:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104c94:	75 0f                	jne    f0104ca5 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0104c96:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104c99:	8b 00                	mov    (%eax),%eax
f0104c9b:	83 e8 01             	sub    $0x1,%eax
f0104c9e:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104ca1:	89 06                	mov    %eax,(%esi)
f0104ca3:	eb 2c                	jmp    f0104cd1 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104ca5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104ca8:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104caa:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104cad:	8b 0e                	mov    (%esi),%ecx
f0104caf:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104cb2:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104cb5:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104cb8:	eb 03                	jmp    f0104cbd <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0104cba:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104cbd:	39 c8                	cmp    %ecx,%eax
f0104cbf:	7e 0b                	jle    f0104ccc <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0104cc1:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0104cc5:	83 ea 0c             	sub    $0xc,%edx
f0104cc8:	39 df                	cmp    %ebx,%edi
f0104cca:	75 ee                	jne    f0104cba <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0104ccc:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104ccf:	89 06                	mov    %eax,(%esi)
	}
}
f0104cd1:	83 c4 14             	add    $0x14,%esp
f0104cd4:	5b                   	pop    %ebx
f0104cd5:	5e                   	pop    %esi
f0104cd6:	5f                   	pop    %edi
f0104cd7:	5d                   	pop    %ebp
f0104cd8:	c3                   	ret    

f0104cd9 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104cd9:	55                   	push   %ebp
f0104cda:	89 e5                	mov    %esp,%ebp
f0104cdc:	57                   	push   %edi
f0104cdd:	56                   	push   %esi
f0104cde:	53                   	push   %ebx
f0104cdf:	83 ec 3c             	sub    $0x3c,%esp
f0104ce2:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104ce5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104ce8:	c7 03 c4 82 10 f0    	movl   $0xf01082c4,(%ebx)
	info->eip_line = 0;
f0104cee:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104cf5:	c7 43 08 c4 82 10 f0 	movl   $0xf01082c4,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104cfc:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104d03:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104d06:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104d0d:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0104d13:	0f 87 a3 00 00 00    	ja     f0104dbc <debuginfo_eip+0xe3>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0104d19:	a1 00 00 20 00       	mov    0x200000,%eax
f0104d1e:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stab_end = usd->stab_end;
f0104d21:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f0104d27:	8b 15 08 00 20 00    	mov    0x200008,%edx
f0104d2d:	89 55 b8             	mov    %edx,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f0104d30:	a1 0c 00 20 00       	mov    0x20000c,%eax
f0104d35:	89 45 bc             	mov    %eax,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0 ||
f0104d38:	e8 51 10 00 00       	call   f0105d8e <cpunum>
f0104d3d:	6a 04                	push   $0x4
f0104d3f:	6a 10                	push   $0x10
f0104d41:	68 00 00 20 00       	push   $0x200000
f0104d46:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d49:	ff b0 28 a0 2a f0    	pushl  -0xfd55fd8(%eax)
f0104d4f:	e8 1b e2 ff ff       	call   f0102f6f <user_mem_check>
f0104d54:	83 c4 10             	add    $0x10,%esp
f0104d57:	85 c0                	test   %eax,%eax
f0104d59:	0f 88 27 02 00 00    	js     f0104f86 <debuginfo_eip+0x2ad>
			user_mem_check(curenv, stabs, stab_end-stabs, PTE_U) < 0 ||
f0104d5f:	e8 2a 10 00 00       	call   f0105d8e <cpunum>
f0104d64:	6a 04                	push   $0x4
f0104d66:	89 f2                	mov    %esi,%edx
f0104d68:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104d6b:	29 ca                	sub    %ecx,%edx
f0104d6d:	c1 fa 02             	sar    $0x2,%edx
f0104d70:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0104d76:	52                   	push   %edx
f0104d77:	51                   	push   %ecx
f0104d78:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d7b:	ff b0 28 a0 2a f0    	pushl  -0xfd55fd8(%eax)
f0104d81:	e8 e9 e1 ff ff       	call   f0102f6f <user_mem_check>
		stabstr = usd->stabstr;
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0 ||
f0104d86:	83 c4 10             	add    $0x10,%esp
f0104d89:	85 c0                	test   %eax,%eax
f0104d8b:	0f 88 fc 01 00 00    	js     f0104f8d <debuginfo_eip+0x2b4>
			user_mem_check(curenv, stabs, stab_end-stabs, PTE_U) < 0 ||
			user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U) < 0
f0104d91:	e8 f8 0f 00 00       	call   f0105d8e <cpunum>
f0104d96:	6a 04                	push   $0x4
f0104d98:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0104d9b:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0104d9e:	29 ca                	sub    %ecx,%edx
f0104da0:	52                   	push   %edx
f0104da1:	51                   	push   %ecx
f0104da2:	6b c0 74             	imul   $0x74,%eax,%eax
f0104da5:	ff b0 28 a0 2a f0    	pushl  -0xfd55fd8(%eax)
f0104dab:	e8 bf e1 ff ff       	call   f0102f6f <user_mem_check>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0 ||
			user_mem_check(curenv, stabs, stab_end-stabs, PTE_U) < 0 ||
f0104db0:	83 c4 10             	add    $0x10,%esp
f0104db3:	85 c0                	test   %eax,%eax
f0104db5:	79 1f                	jns    f0104dd6 <debuginfo_eip+0xfd>
f0104db7:	e9 d8 01 00 00       	jmp    f0104f94 <debuginfo_eip+0x2bb>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104dbc:	c7 45 bc 65 7f 11 f0 	movl   $0xf0117f65,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0104dc3:	c7 45 b8 d5 3e 11 f0 	movl   $0xf0113ed5,-0x48(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0104dca:	be d4 3e 11 f0       	mov    $0xf0113ed4,%esi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104dcf:	c7 45 c0 c8 8a 10 f0 	movl   $0xf0108ac8,-0x40(%ebp)
		)
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104dd6:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104dd9:	39 45 b8             	cmp    %eax,-0x48(%ebp)
f0104ddc:	0f 83 b9 01 00 00    	jae    f0104f9b <debuginfo_eip+0x2c2>
f0104de2:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0104de6:	0f 85 b6 01 00 00    	jne    f0104fa2 <debuginfo_eip+0x2c9>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104dec:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104df3:	2b 75 c0             	sub    -0x40(%ebp),%esi
f0104df6:	c1 fe 02             	sar    $0x2,%esi
f0104df9:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f0104dff:	83 e8 01             	sub    $0x1,%eax
f0104e02:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104e05:	83 ec 08             	sub    $0x8,%esp
f0104e08:	57                   	push   %edi
f0104e09:	6a 64                	push   $0x64
f0104e0b:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0104e0e:	89 d1                	mov    %edx,%ecx
f0104e10:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104e13:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0104e16:	89 f0                	mov    %esi,%eax
f0104e18:	e8 c6 fd ff ff       	call   f0104be3 <stab_binsearch>
	if (lfile == 0)
f0104e1d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e20:	83 c4 10             	add    $0x10,%esp
f0104e23:	85 c0                	test   %eax,%eax
f0104e25:	0f 84 7e 01 00 00    	je     f0104fa9 <debuginfo_eip+0x2d0>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104e2b:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104e2e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104e31:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104e34:	83 ec 08             	sub    $0x8,%esp
f0104e37:	57                   	push   %edi
f0104e38:	6a 24                	push   $0x24
f0104e3a:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0104e3d:	89 d1                	mov    %edx,%ecx
f0104e3f:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104e42:	89 f0                	mov    %esi,%eax
f0104e44:	e8 9a fd ff ff       	call   f0104be3 <stab_binsearch>

	if (lfun <= rfun) {
f0104e49:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104e4c:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104e4f:	83 c4 10             	add    $0x10,%esp
f0104e52:	39 d0                	cmp    %edx,%eax
f0104e54:	7f 2e                	jg     f0104e84 <debuginfo_eip+0x1ab>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104e56:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0104e59:	8d 34 8e             	lea    (%esi,%ecx,4),%esi
f0104e5c:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f0104e5f:	8b 36                	mov    (%esi),%esi
f0104e61:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0104e64:	2b 4d b8             	sub    -0x48(%ebp),%ecx
f0104e67:	39 ce                	cmp    %ecx,%esi
f0104e69:	73 06                	jae    f0104e71 <debuginfo_eip+0x198>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104e6b:	03 75 b8             	add    -0x48(%ebp),%esi
f0104e6e:	89 73 08             	mov    %esi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104e71:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0104e74:	8b 4e 08             	mov    0x8(%esi),%ecx
f0104e77:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0104e7a:	29 cf                	sub    %ecx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0104e7c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104e7f:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0104e82:	eb 0f                	jmp    f0104e93 <debuginfo_eip+0x1ba>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104e84:	89 7b 10             	mov    %edi,0x10(%ebx)
		lline = lfile;
f0104e87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e8a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104e8d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104e90:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104e93:	83 ec 08             	sub    $0x8,%esp
f0104e96:	6a 3a                	push   $0x3a
f0104e98:	ff 73 08             	pushl  0x8(%ebx)
f0104e9b:	e8 af 08 00 00       	call   f010574f <strfind>
f0104ea0:	2b 43 08             	sub    0x8(%ebx),%eax
f0104ea3:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.


	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104ea6:	83 c4 08             	add    $0x8,%esp
f0104ea9:	57                   	push   %edi
f0104eaa:	6a 44                	push   $0x44
f0104eac:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104eaf:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104eb2:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0104eb5:	89 f0                	mov    %esi,%eax
f0104eb7:	e8 27 fd ff ff       	call   f0104be3 <stab_binsearch>
	if (lline == 0)
f0104ebc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0104ebf:	83 c4 10             	add    $0x10,%esp
f0104ec2:	85 d2                	test   %edx,%edx
f0104ec4:	0f 84 e6 00 00 00    	je     f0104fb0 <debuginfo_eip+0x2d7>
		return -1;
	// cprintf("[+] %d, %d, %d, %x\n", lline, rline, lfun, stabs[lfun].n_value);
	info->eip_line = stabs[rline].n_desc;
f0104eca:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104ecd:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104ed0:	0f b7 44 86 06       	movzwl 0x6(%esi,%eax,4),%eax
f0104ed5:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104ed8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104edb:	89 d0                	mov    %edx,%eax
f0104edd:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104ee0:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0104ee3:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0104ee7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104eea:	eb 0a                	jmp    f0104ef6 <debuginfo_eip+0x21d>
f0104eec:	83 e8 01             	sub    $0x1,%eax
f0104eef:	83 ea 0c             	sub    $0xc,%edx
f0104ef2:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0104ef6:	39 c7                	cmp    %eax,%edi
f0104ef8:	7e 05                	jle    f0104eff <debuginfo_eip+0x226>
f0104efa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104efd:	eb 47                	jmp    f0104f46 <debuginfo_eip+0x26d>
	       && stabs[lline].n_type != N_SOL
f0104eff:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104f03:	80 f9 84             	cmp    $0x84,%cl
f0104f06:	75 0e                	jne    f0104f16 <debuginfo_eip+0x23d>
f0104f08:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104f0b:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104f0f:	74 1c                	je     f0104f2d <debuginfo_eip+0x254>
f0104f11:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104f14:	eb 17                	jmp    f0104f2d <debuginfo_eip+0x254>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104f16:	80 f9 64             	cmp    $0x64,%cl
f0104f19:	75 d1                	jne    f0104eec <debuginfo_eip+0x213>
f0104f1b:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0104f1f:	74 cb                	je     f0104eec <debuginfo_eip+0x213>
f0104f21:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104f24:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104f28:	74 03                	je     f0104f2d <debuginfo_eip+0x254>
f0104f2a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104f2d:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104f30:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104f33:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0104f36:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104f39:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0104f3c:	29 f8                	sub    %edi,%eax
f0104f3e:	39 c2                	cmp    %eax,%edx
f0104f40:	73 04                	jae    f0104f46 <debuginfo_eip+0x26d>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104f42:	01 fa                	add    %edi,%edx
f0104f44:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104f46:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104f49:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104f4c:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104f51:	39 f2                	cmp    %esi,%edx
f0104f53:	7d 67                	jge    f0104fbc <debuginfo_eip+0x2e3>
		for (lline = lfun + 1;
f0104f55:	83 c2 01             	add    $0x1,%edx
f0104f58:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104f5b:	89 d0                	mov    %edx,%eax
f0104f5d:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104f60:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104f63:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0104f66:	eb 04                	jmp    f0104f6c <debuginfo_eip+0x293>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104f68:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104f6c:	39 c6                	cmp    %eax,%esi
f0104f6e:	7e 47                	jle    f0104fb7 <debuginfo_eip+0x2de>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104f70:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104f74:	83 c0 01             	add    $0x1,%eax
f0104f77:	83 c2 0c             	add    $0xc,%edx
f0104f7a:	80 f9 a0             	cmp    $0xa0,%cl
f0104f7d:	74 e9                	je     f0104f68 <debuginfo_eip+0x28f>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104f7f:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f84:	eb 36                	jmp    f0104fbc <debuginfo_eip+0x2e3>
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0 ||
			user_mem_check(curenv, stabs, stab_end-stabs, PTE_U) < 0 ||
			user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U) < 0
		)
			return -1;
f0104f86:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f8b:	eb 2f                	jmp    f0104fbc <debuginfo_eip+0x2e3>
f0104f8d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f92:	eb 28                	jmp    f0104fbc <debuginfo_eip+0x2e3>
f0104f94:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f99:	eb 21                	jmp    f0104fbc <debuginfo_eip+0x2e3>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104f9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104fa0:	eb 1a                	jmp    f0104fbc <debuginfo_eip+0x2e3>
f0104fa2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104fa7:	eb 13                	jmp    f0104fbc <debuginfo_eip+0x2e3>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0104fa9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104fae:	eb 0c                	jmp    f0104fbc <debuginfo_eip+0x2e3>
	// Your code here.


	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline == 0)
		return -1;
f0104fb0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104fb5:	eb 05                	jmp    f0104fbc <debuginfo_eip+0x2e3>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104fb7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104fbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104fbf:	5b                   	pop    %ebx
f0104fc0:	5e                   	pop    %esi
f0104fc1:	5f                   	pop    %edi
f0104fc2:	5d                   	pop    %ebp
f0104fc3:	c3                   	ret    

f0104fc4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104fc4:	55                   	push   %ebp
f0104fc5:	89 e5                	mov    %esp,%ebp
f0104fc7:	57                   	push   %edi
f0104fc8:	56                   	push   %esi
f0104fc9:	53                   	push   %ebx
f0104fca:	83 ec 1c             	sub    $0x1c,%esp
f0104fcd:	89 c7                	mov    %eax,%edi
f0104fcf:	89 d6                	mov    %edx,%esi
f0104fd1:	8b 45 08             	mov    0x8(%ebp),%eax
f0104fd4:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104fd7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104fda:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104fdd:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104fe0:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104fe5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104fe8:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104feb:	39 d3                	cmp    %edx,%ebx
f0104fed:	72 05                	jb     f0104ff4 <printnum+0x30>
f0104fef:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104ff2:	77 45                	ja     f0105039 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104ff4:	83 ec 0c             	sub    $0xc,%esp
f0104ff7:	ff 75 18             	pushl  0x18(%ebp)
f0104ffa:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ffd:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0105000:	53                   	push   %ebx
f0105001:	ff 75 10             	pushl  0x10(%ebp)
f0105004:	83 ec 08             	sub    $0x8,%esp
f0105007:	ff 75 e4             	pushl  -0x1c(%ebp)
f010500a:	ff 75 e0             	pushl  -0x20(%ebp)
f010500d:	ff 75 dc             	pushl  -0x24(%ebp)
f0105010:	ff 75 d8             	pushl  -0x28(%ebp)
f0105013:	e8 d8 16 00 00       	call   f01066f0 <__udivdi3>
f0105018:	83 c4 18             	add    $0x18,%esp
f010501b:	52                   	push   %edx
f010501c:	50                   	push   %eax
f010501d:	89 f2                	mov    %esi,%edx
f010501f:	89 f8                	mov    %edi,%eax
f0105021:	e8 9e ff ff ff       	call   f0104fc4 <printnum>
f0105026:	83 c4 20             	add    $0x20,%esp
f0105029:	eb 18                	jmp    f0105043 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f010502b:	83 ec 08             	sub    $0x8,%esp
f010502e:	56                   	push   %esi
f010502f:	ff 75 18             	pushl  0x18(%ebp)
f0105032:	ff d7                	call   *%edi
f0105034:	83 c4 10             	add    $0x10,%esp
f0105037:	eb 03                	jmp    f010503c <printnum+0x78>
f0105039:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f010503c:	83 eb 01             	sub    $0x1,%ebx
f010503f:	85 db                	test   %ebx,%ebx
f0105041:	7f e8                	jg     f010502b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0105043:	83 ec 08             	sub    $0x8,%esp
f0105046:	56                   	push   %esi
f0105047:	83 ec 04             	sub    $0x4,%esp
f010504a:	ff 75 e4             	pushl  -0x1c(%ebp)
f010504d:	ff 75 e0             	pushl  -0x20(%ebp)
f0105050:	ff 75 dc             	pushl  -0x24(%ebp)
f0105053:	ff 75 d8             	pushl  -0x28(%ebp)
f0105056:	e8 c5 17 00 00       	call   f0106820 <__umoddi3>
f010505b:	83 c4 14             	add    $0x14,%esp
f010505e:	0f be 80 ce 82 10 f0 	movsbl -0xfef7d32(%eax),%eax
f0105065:	50                   	push   %eax
f0105066:	ff d7                	call   *%edi
}
f0105068:	83 c4 10             	add    $0x10,%esp
f010506b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010506e:	5b                   	pop    %ebx
f010506f:	5e                   	pop    %esi
f0105070:	5f                   	pop    %edi
f0105071:	5d                   	pop    %ebp
f0105072:	c3                   	ret    

f0105073 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0105073:	55                   	push   %ebp
f0105074:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0105076:	83 fa 01             	cmp    $0x1,%edx
f0105079:	7e 0e                	jle    f0105089 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f010507b:	8b 10                	mov    (%eax),%edx
f010507d:	8d 4a 08             	lea    0x8(%edx),%ecx
f0105080:	89 08                	mov    %ecx,(%eax)
f0105082:	8b 02                	mov    (%edx),%eax
f0105084:	8b 52 04             	mov    0x4(%edx),%edx
f0105087:	eb 22                	jmp    f01050ab <getuint+0x38>
	else if (lflag)
f0105089:	85 d2                	test   %edx,%edx
f010508b:	74 10                	je     f010509d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f010508d:	8b 10                	mov    (%eax),%edx
f010508f:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105092:	89 08                	mov    %ecx,(%eax)
f0105094:	8b 02                	mov    (%edx),%eax
f0105096:	ba 00 00 00 00       	mov    $0x0,%edx
f010509b:	eb 0e                	jmp    f01050ab <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f010509d:	8b 10                	mov    (%eax),%edx
f010509f:	8d 4a 04             	lea    0x4(%edx),%ecx
f01050a2:	89 08                	mov    %ecx,(%eax)
f01050a4:	8b 02                	mov    (%edx),%eax
f01050a6:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01050ab:	5d                   	pop    %ebp
f01050ac:	c3                   	ret    

f01050ad <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01050ad:	55                   	push   %ebp
f01050ae:	89 e5                	mov    %esp,%ebp
f01050b0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01050b3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01050b7:	8b 10                	mov    (%eax),%edx
f01050b9:	3b 50 04             	cmp    0x4(%eax),%edx
f01050bc:	73 0a                	jae    f01050c8 <sprintputch+0x1b>
		*b->buf++ = ch;
f01050be:	8d 4a 01             	lea    0x1(%edx),%ecx
f01050c1:	89 08                	mov    %ecx,(%eax)
f01050c3:	8b 45 08             	mov    0x8(%ebp),%eax
f01050c6:	88 02                	mov    %al,(%edx)
}
f01050c8:	5d                   	pop    %ebp
f01050c9:	c3                   	ret    

f01050ca <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01050ca:	55                   	push   %ebp
f01050cb:	89 e5                	mov    %esp,%ebp
f01050cd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01050d0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01050d3:	50                   	push   %eax
f01050d4:	ff 75 10             	pushl  0x10(%ebp)
f01050d7:	ff 75 0c             	pushl  0xc(%ebp)
f01050da:	ff 75 08             	pushl  0x8(%ebp)
f01050dd:	e8 05 00 00 00       	call   f01050e7 <vprintfmt>
	va_end(ap);
}
f01050e2:	83 c4 10             	add    $0x10,%esp
f01050e5:	c9                   	leave  
f01050e6:	c3                   	ret    

f01050e7 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01050e7:	55                   	push   %ebp
f01050e8:	89 e5                	mov    %esp,%ebp
f01050ea:	57                   	push   %edi
f01050eb:	56                   	push   %esi
f01050ec:	53                   	push   %ebx
f01050ed:	83 ec 2c             	sub    $0x2c,%esp
f01050f0:	8b 75 08             	mov    0x8(%ebp),%esi
f01050f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01050f6:	8b 7d 10             	mov    0x10(%ebp),%edi
f01050f9:	eb 12                	jmp    f010510d <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01050fb:	85 c0                	test   %eax,%eax
f01050fd:	0f 84 89 03 00 00    	je     f010548c <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0105103:	83 ec 08             	sub    $0x8,%esp
f0105106:	53                   	push   %ebx
f0105107:	50                   	push   %eax
f0105108:	ff d6                	call   *%esi
f010510a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010510d:	83 c7 01             	add    $0x1,%edi
f0105110:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105114:	83 f8 25             	cmp    $0x25,%eax
f0105117:	75 e2                	jne    f01050fb <vprintfmt+0x14>
f0105119:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f010511d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0105124:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f010512b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0105132:	ba 00 00 00 00       	mov    $0x0,%edx
f0105137:	eb 07                	jmp    f0105140 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105139:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f010513c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105140:	8d 47 01             	lea    0x1(%edi),%eax
f0105143:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105146:	0f b6 07             	movzbl (%edi),%eax
f0105149:	0f b6 c8             	movzbl %al,%ecx
f010514c:	83 e8 23             	sub    $0x23,%eax
f010514f:	3c 55                	cmp    $0x55,%al
f0105151:	0f 87 1a 03 00 00    	ja     f0105471 <vprintfmt+0x38a>
f0105157:	0f b6 c0             	movzbl %al,%eax
f010515a:	ff 24 85 20 84 10 f0 	jmp    *-0xfef7be0(,%eax,4)
f0105161:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0105164:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0105168:	eb d6                	jmp    f0105140 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010516a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010516d:	b8 00 00 00 00       	mov    $0x0,%eax
f0105172:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0105175:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0105178:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f010517c:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f010517f:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0105182:	83 fa 09             	cmp    $0x9,%edx
f0105185:	77 39                	ja     f01051c0 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0105187:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f010518a:	eb e9                	jmp    f0105175 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f010518c:	8b 45 14             	mov    0x14(%ebp),%eax
f010518f:	8d 48 04             	lea    0x4(%eax),%ecx
f0105192:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0105195:	8b 00                	mov    (%eax),%eax
f0105197:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010519a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f010519d:	eb 27                	jmp    f01051c6 <vprintfmt+0xdf>
f010519f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01051a2:	85 c0                	test   %eax,%eax
f01051a4:	b9 00 00 00 00       	mov    $0x0,%ecx
f01051a9:	0f 49 c8             	cmovns %eax,%ecx
f01051ac:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01051af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01051b2:	eb 8c                	jmp    f0105140 <vprintfmt+0x59>
f01051b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f01051b7:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f01051be:	eb 80                	jmp    f0105140 <vprintfmt+0x59>
f01051c0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01051c3:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f01051c6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01051ca:	0f 89 70 ff ff ff    	jns    f0105140 <vprintfmt+0x59>
				width = precision, precision = -1;
f01051d0:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01051d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01051d6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f01051dd:	e9 5e ff ff ff       	jmp    f0105140 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01051e2:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01051e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f01051e8:	e9 53 ff ff ff       	jmp    f0105140 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01051ed:	8b 45 14             	mov    0x14(%ebp),%eax
f01051f0:	8d 50 04             	lea    0x4(%eax),%edx
f01051f3:	89 55 14             	mov    %edx,0x14(%ebp)
f01051f6:	83 ec 08             	sub    $0x8,%esp
f01051f9:	53                   	push   %ebx
f01051fa:	ff 30                	pushl  (%eax)
f01051fc:	ff d6                	call   *%esi
			break;
f01051fe:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105201:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0105204:	e9 04 ff ff ff       	jmp    f010510d <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0105209:	8b 45 14             	mov    0x14(%ebp),%eax
f010520c:	8d 50 04             	lea    0x4(%eax),%edx
f010520f:	89 55 14             	mov    %edx,0x14(%ebp)
f0105212:	8b 00                	mov    (%eax),%eax
f0105214:	99                   	cltd   
f0105215:	31 d0                	xor    %edx,%eax
f0105217:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105219:	83 f8 0f             	cmp    $0xf,%eax
f010521c:	7f 0b                	jg     f0105229 <vprintfmt+0x142>
f010521e:	8b 14 85 80 85 10 f0 	mov    -0xfef7a80(,%eax,4),%edx
f0105225:	85 d2                	test   %edx,%edx
f0105227:	75 18                	jne    f0105241 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0105229:	50                   	push   %eax
f010522a:	68 e6 82 10 f0       	push   $0xf01082e6
f010522f:	53                   	push   %ebx
f0105230:	56                   	push   %esi
f0105231:	e8 94 fe ff ff       	call   f01050ca <printfmt>
f0105236:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105239:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f010523c:	e9 cc fe ff ff       	jmp    f010510d <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0105241:	52                   	push   %edx
f0105242:	68 97 6f 10 f0       	push   $0xf0106f97
f0105247:	53                   	push   %ebx
f0105248:	56                   	push   %esi
f0105249:	e8 7c fe ff ff       	call   f01050ca <printfmt>
f010524e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105251:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105254:	e9 b4 fe ff ff       	jmp    f010510d <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105259:	8b 45 14             	mov    0x14(%ebp),%eax
f010525c:	8d 50 04             	lea    0x4(%eax),%edx
f010525f:	89 55 14             	mov    %edx,0x14(%ebp)
f0105262:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0105264:	85 ff                	test   %edi,%edi
f0105266:	b8 df 82 10 f0       	mov    $0xf01082df,%eax
f010526b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f010526e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105272:	0f 8e 94 00 00 00    	jle    f010530c <vprintfmt+0x225>
f0105278:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f010527c:	0f 84 98 00 00 00    	je     f010531a <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105282:	83 ec 08             	sub    $0x8,%esp
f0105285:	ff 75 d0             	pushl  -0x30(%ebp)
f0105288:	57                   	push   %edi
f0105289:	e8 77 03 00 00       	call   f0105605 <strnlen>
f010528e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105291:	29 c1                	sub    %eax,%ecx
f0105293:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0105296:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0105299:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f010529d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01052a0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01052a3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01052a5:	eb 0f                	jmp    f01052b6 <vprintfmt+0x1cf>
					putch(padc, putdat);
f01052a7:	83 ec 08             	sub    $0x8,%esp
f01052aa:	53                   	push   %ebx
f01052ab:	ff 75 e0             	pushl  -0x20(%ebp)
f01052ae:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01052b0:	83 ef 01             	sub    $0x1,%edi
f01052b3:	83 c4 10             	add    $0x10,%esp
f01052b6:	85 ff                	test   %edi,%edi
f01052b8:	7f ed                	jg     f01052a7 <vprintfmt+0x1c0>
f01052ba:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01052bd:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01052c0:	85 c9                	test   %ecx,%ecx
f01052c2:	b8 00 00 00 00       	mov    $0x0,%eax
f01052c7:	0f 49 c1             	cmovns %ecx,%eax
f01052ca:	29 c1                	sub    %eax,%ecx
f01052cc:	89 75 08             	mov    %esi,0x8(%ebp)
f01052cf:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01052d2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01052d5:	89 cb                	mov    %ecx,%ebx
f01052d7:	eb 4d                	jmp    f0105326 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01052d9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01052dd:	74 1b                	je     f01052fa <vprintfmt+0x213>
f01052df:	0f be c0             	movsbl %al,%eax
f01052e2:	83 e8 20             	sub    $0x20,%eax
f01052e5:	83 f8 5e             	cmp    $0x5e,%eax
f01052e8:	76 10                	jbe    f01052fa <vprintfmt+0x213>
					putch('?', putdat);
f01052ea:	83 ec 08             	sub    $0x8,%esp
f01052ed:	ff 75 0c             	pushl  0xc(%ebp)
f01052f0:	6a 3f                	push   $0x3f
f01052f2:	ff 55 08             	call   *0x8(%ebp)
f01052f5:	83 c4 10             	add    $0x10,%esp
f01052f8:	eb 0d                	jmp    f0105307 <vprintfmt+0x220>
				else
					putch(ch, putdat);
f01052fa:	83 ec 08             	sub    $0x8,%esp
f01052fd:	ff 75 0c             	pushl  0xc(%ebp)
f0105300:	52                   	push   %edx
f0105301:	ff 55 08             	call   *0x8(%ebp)
f0105304:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105307:	83 eb 01             	sub    $0x1,%ebx
f010530a:	eb 1a                	jmp    f0105326 <vprintfmt+0x23f>
f010530c:	89 75 08             	mov    %esi,0x8(%ebp)
f010530f:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105312:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105315:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105318:	eb 0c                	jmp    f0105326 <vprintfmt+0x23f>
f010531a:	89 75 08             	mov    %esi,0x8(%ebp)
f010531d:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105320:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105323:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105326:	83 c7 01             	add    $0x1,%edi
f0105329:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f010532d:	0f be d0             	movsbl %al,%edx
f0105330:	85 d2                	test   %edx,%edx
f0105332:	74 23                	je     f0105357 <vprintfmt+0x270>
f0105334:	85 f6                	test   %esi,%esi
f0105336:	78 a1                	js     f01052d9 <vprintfmt+0x1f2>
f0105338:	83 ee 01             	sub    $0x1,%esi
f010533b:	79 9c                	jns    f01052d9 <vprintfmt+0x1f2>
f010533d:	89 df                	mov    %ebx,%edi
f010533f:	8b 75 08             	mov    0x8(%ebp),%esi
f0105342:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105345:	eb 18                	jmp    f010535f <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0105347:	83 ec 08             	sub    $0x8,%esp
f010534a:	53                   	push   %ebx
f010534b:	6a 20                	push   $0x20
f010534d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010534f:	83 ef 01             	sub    $0x1,%edi
f0105352:	83 c4 10             	add    $0x10,%esp
f0105355:	eb 08                	jmp    f010535f <vprintfmt+0x278>
f0105357:	89 df                	mov    %ebx,%edi
f0105359:	8b 75 08             	mov    0x8(%ebp),%esi
f010535c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010535f:	85 ff                	test   %edi,%edi
f0105361:	7f e4                	jg     f0105347 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105363:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105366:	e9 a2 fd ff ff       	jmp    f010510d <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010536b:	83 fa 01             	cmp    $0x1,%edx
f010536e:	7e 16                	jle    f0105386 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0105370:	8b 45 14             	mov    0x14(%ebp),%eax
f0105373:	8d 50 08             	lea    0x8(%eax),%edx
f0105376:	89 55 14             	mov    %edx,0x14(%ebp)
f0105379:	8b 50 04             	mov    0x4(%eax),%edx
f010537c:	8b 00                	mov    (%eax),%eax
f010537e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105381:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105384:	eb 32                	jmp    f01053b8 <vprintfmt+0x2d1>
	else if (lflag)
f0105386:	85 d2                	test   %edx,%edx
f0105388:	74 18                	je     f01053a2 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f010538a:	8b 45 14             	mov    0x14(%ebp),%eax
f010538d:	8d 50 04             	lea    0x4(%eax),%edx
f0105390:	89 55 14             	mov    %edx,0x14(%ebp)
f0105393:	8b 00                	mov    (%eax),%eax
f0105395:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105398:	89 c1                	mov    %eax,%ecx
f010539a:	c1 f9 1f             	sar    $0x1f,%ecx
f010539d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01053a0:	eb 16                	jmp    f01053b8 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f01053a2:	8b 45 14             	mov    0x14(%ebp),%eax
f01053a5:	8d 50 04             	lea    0x4(%eax),%edx
f01053a8:	89 55 14             	mov    %edx,0x14(%ebp)
f01053ab:	8b 00                	mov    (%eax),%eax
f01053ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01053b0:	89 c1                	mov    %eax,%ecx
f01053b2:	c1 f9 1f             	sar    $0x1f,%ecx
f01053b5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01053b8:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01053bb:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01053be:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01053c3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01053c7:	79 74                	jns    f010543d <vprintfmt+0x356>
				putch('-', putdat);
f01053c9:	83 ec 08             	sub    $0x8,%esp
f01053cc:	53                   	push   %ebx
f01053cd:	6a 2d                	push   $0x2d
f01053cf:	ff d6                	call   *%esi
				num = -(long long) num;
f01053d1:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01053d4:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01053d7:	f7 d8                	neg    %eax
f01053d9:	83 d2 00             	adc    $0x0,%edx
f01053dc:	f7 da                	neg    %edx
f01053de:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f01053e1:	b9 0a 00 00 00       	mov    $0xa,%ecx
f01053e6:	eb 55                	jmp    f010543d <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01053e8:	8d 45 14             	lea    0x14(%ebp),%eax
f01053eb:	e8 83 fc ff ff       	call   f0105073 <getuint>
			base = 10;
f01053f0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f01053f5:	eb 46                	jmp    f010543d <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
f01053f7:	8d 45 14             	lea    0x14(%ebp),%eax
f01053fa:	e8 74 fc ff ff       	call   f0105073 <getuint>
			base = 8;
f01053ff:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0105404:	eb 37                	jmp    f010543d <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
f0105406:	83 ec 08             	sub    $0x8,%esp
f0105409:	53                   	push   %ebx
f010540a:	6a 30                	push   $0x30
f010540c:	ff d6                	call   *%esi
			putch('x', putdat);
f010540e:	83 c4 08             	add    $0x8,%esp
f0105411:	53                   	push   %ebx
f0105412:	6a 78                	push   $0x78
f0105414:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0105416:	8b 45 14             	mov    0x14(%ebp),%eax
f0105419:	8d 50 04             	lea    0x4(%eax),%edx
f010541c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f010541f:	8b 00                	mov    (%eax),%eax
f0105421:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0105426:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0105429:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f010542e:	eb 0d                	jmp    f010543d <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0105430:	8d 45 14             	lea    0x14(%ebp),%eax
f0105433:	e8 3b fc ff ff       	call   f0105073 <getuint>
			base = 16;
f0105438:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f010543d:	83 ec 0c             	sub    $0xc,%esp
f0105440:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0105444:	57                   	push   %edi
f0105445:	ff 75 e0             	pushl  -0x20(%ebp)
f0105448:	51                   	push   %ecx
f0105449:	52                   	push   %edx
f010544a:	50                   	push   %eax
f010544b:	89 da                	mov    %ebx,%edx
f010544d:	89 f0                	mov    %esi,%eax
f010544f:	e8 70 fb ff ff       	call   f0104fc4 <printnum>
			break;
f0105454:	83 c4 20             	add    $0x20,%esp
f0105457:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010545a:	e9 ae fc ff ff       	jmp    f010510d <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010545f:	83 ec 08             	sub    $0x8,%esp
f0105462:	53                   	push   %ebx
f0105463:	51                   	push   %ecx
f0105464:	ff d6                	call   *%esi
			break;
f0105466:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105469:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f010546c:	e9 9c fc ff ff       	jmp    f010510d <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105471:	83 ec 08             	sub    $0x8,%esp
f0105474:	53                   	push   %ebx
f0105475:	6a 25                	push   $0x25
f0105477:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105479:	83 c4 10             	add    $0x10,%esp
f010547c:	eb 03                	jmp    f0105481 <vprintfmt+0x39a>
f010547e:	83 ef 01             	sub    $0x1,%edi
f0105481:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0105485:	75 f7                	jne    f010547e <vprintfmt+0x397>
f0105487:	e9 81 fc ff ff       	jmp    f010510d <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f010548c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010548f:	5b                   	pop    %ebx
f0105490:	5e                   	pop    %esi
f0105491:	5f                   	pop    %edi
f0105492:	5d                   	pop    %ebp
f0105493:	c3                   	ret    

f0105494 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105494:	55                   	push   %ebp
f0105495:	89 e5                	mov    %esp,%ebp
f0105497:	83 ec 18             	sub    $0x18,%esp
f010549a:	8b 45 08             	mov    0x8(%ebp),%eax
f010549d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01054a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01054a3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01054a7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01054aa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01054b1:	85 c0                	test   %eax,%eax
f01054b3:	74 26                	je     f01054db <vsnprintf+0x47>
f01054b5:	85 d2                	test   %edx,%edx
f01054b7:	7e 22                	jle    f01054db <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01054b9:	ff 75 14             	pushl  0x14(%ebp)
f01054bc:	ff 75 10             	pushl  0x10(%ebp)
f01054bf:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01054c2:	50                   	push   %eax
f01054c3:	68 ad 50 10 f0       	push   $0xf01050ad
f01054c8:	e8 1a fc ff ff       	call   f01050e7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01054cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01054d0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01054d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01054d6:	83 c4 10             	add    $0x10,%esp
f01054d9:	eb 05                	jmp    f01054e0 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01054db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01054e0:	c9                   	leave  
f01054e1:	c3                   	ret    

f01054e2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01054e2:	55                   	push   %ebp
f01054e3:	89 e5                	mov    %esp,%ebp
f01054e5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01054e8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01054eb:	50                   	push   %eax
f01054ec:	ff 75 10             	pushl  0x10(%ebp)
f01054ef:	ff 75 0c             	pushl  0xc(%ebp)
f01054f2:	ff 75 08             	pushl  0x8(%ebp)
f01054f5:	e8 9a ff ff ff       	call   f0105494 <vsnprintf>
	va_end(ap);

	return rc;
}
f01054fa:	c9                   	leave  
f01054fb:	c3                   	ret    

f01054fc <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01054fc:	55                   	push   %ebp
f01054fd:	89 e5                	mov    %esp,%ebp
f01054ff:	57                   	push   %edi
f0105500:	56                   	push   %esi
f0105501:	53                   	push   %ebx
f0105502:	83 ec 0c             	sub    $0xc,%esp
f0105505:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f0105508:	85 c0                	test   %eax,%eax
f010550a:	74 11                	je     f010551d <readline+0x21>
		cprintf("%s", prompt);
f010550c:	83 ec 08             	sub    $0x8,%esp
f010550f:	50                   	push   %eax
f0105510:	68 97 6f 10 f0       	push   $0xf0106f97
f0105515:	e8 77 e4 ff ff       	call   f0103991 <cprintf>
f010551a:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f010551d:	83 ec 0c             	sub    $0xc,%esp
f0105520:	6a 00                	push   $0x0
f0105522:	e8 95 b2 ff ff       	call   f01007bc <iscons>
f0105527:	89 c7                	mov    %eax,%edi
f0105529:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
f010552c:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0105531:	e8 75 b2 ff ff       	call   f01007ab <getchar>
f0105536:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105538:	85 c0                	test   %eax,%eax
f010553a:	79 29                	jns    f0105565 <readline+0x69>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f010553c:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
f0105541:	83 fb f8             	cmp    $0xfffffff8,%ebx
f0105544:	0f 84 9b 00 00 00    	je     f01055e5 <readline+0xe9>
				cprintf("read error: %e\n", c);
f010554a:	83 ec 08             	sub    $0x8,%esp
f010554d:	53                   	push   %ebx
f010554e:	68 df 85 10 f0       	push   $0xf01085df
f0105553:	e8 39 e4 ff ff       	call   f0103991 <cprintf>
f0105558:	83 c4 10             	add    $0x10,%esp
			return NULL;
f010555b:	b8 00 00 00 00       	mov    $0x0,%eax
f0105560:	e9 80 00 00 00       	jmp    f01055e5 <readline+0xe9>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105565:	83 f8 08             	cmp    $0x8,%eax
f0105568:	0f 94 c2             	sete   %dl
f010556b:	83 f8 7f             	cmp    $0x7f,%eax
f010556e:	0f 94 c0             	sete   %al
f0105571:	08 c2                	or     %al,%dl
f0105573:	74 1a                	je     f010558f <readline+0x93>
f0105575:	85 f6                	test   %esi,%esi
f0105577:	7e 16                	jle    f010558f <readline+0x93>
			if (echoing)
f0105579:	85 ff                	test   %edi,%edi
f010557b:	74 0d                	je     f010558a <readline+0x8e>
				cputchar('\b');
f010557d:	83 ec 0c             	sub    $0xc,%esp
f0105580:	6a 08                	push   $0x8
f0105582:	e8 14 b2 ff ff       	call   f010079b <cputchar>
f0105587:	83 c4 10             	add    $0x10,%esp
			i--;
f010558a:	83 ee 01             	sub    $0x1,%esi
f010558d:	eb a2                	jmp    f0105531 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010558f:	83 fb 1f             	cmp    $0x1f,%ebx
f0105592:	7e 26                	jle    f01055ba <readline+0xbe>
f0105594:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010559a:	7f 1e                	jg     f01055ba <readline+0xbe>
			if (echoing)
f010559c:	85 ff                	test   %edi,%edi
f010559e:	74 0c                	je     f01055ac <readline+0xb0>
				cputchar(c);
f01055a0:	83 ec 0c             	sub    $0xc,%esp
f01055a3:	53                   	push   %ebx
f01055a4:	e8 f2 b1 ff ff       	call   f010079b <cputchar>
f01055a9:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01055ac:	88 9e 80 9a 2a f0    	mov    %bl,-0xfd56580(%esi)
f01055b2:	8d 76 01             	lea    0x1(%esi),%esi
f01055b5:	e9 77 ff ff ff       	jmp    f0105531 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f01055ba:	83 fb 0a             	cmp    $0xa,%ebx
f01055bd:	74 09                	je     f01055c8 <readline+0xcc>
f01055bf:	83 fb 0d             	cmp    $0xd,%ebx
f01055c2:	0f 85 69 ff ff ff    	jne    f0105531 <readline+0x35>
			if (echoing)
f01055c8:	85 ff                	test   %edi,%edi
f01055ca:	74 0d                	je     f01055d9 <readline+0xdd>
				cputchar('\n');
f01055cc:	83 ec 0c             	sub    $0xc,%esp
f01055cf:	6a 0a                	push   $0xa
f01055d1:	e8 c5 b1 ff ff       	call   f010079b <cputchar>
f01055d6:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01055d9:	c6 86 80 9a 2a f0 00 	movb   $0x0,-0xfd56580(%esi)
			return buf;
f01055e0:	b8 80 9a 2a f0       	mov    $0xf02a9a80,%eax
		}
	}
}
f01055e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01055e8:	5b                   	pop    %ebx
f01055e9:	5e                   	pop    %esi
f01055ea:	5f                   	pop    %edi
f01055eb:	5d                   	pop    %ebp
f01055ec:	c3                   	ret    

f01055ed <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01055ed:	55                   	push   %ebp
f01055ee:	89 e5                	mov    %esp,%ebp
f01055f0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01055f3:	b8 00 00 00 00       	mov    $0x0,%eax
f01055f8:	eb 03                	jmp    f01055fd <strlen+0x10>
		n++;
f01055fa:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01055fd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105601:	75 f7                	jne    f01055fa <strlen+0xd>
		n++;
	return n;
}
f0105603:	5d                   	pop    %ebp
f0105604:	c3                   	ret    

f0105605 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105605:	55                   	push   %ebp
f0105606:	89 e5                	mov    %esp,%ebp
f0105608:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010560b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010560e:	ba 00 00 00 00       	mov    $0x0,%edx
f0105613:	eb 03                	jmp    f0105618 <strnlen+0x13>
		n++;
f0105615:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105618:	39 c2                	cmp    %eax,%edx
f010561a:	74 08                	je     f0105624 <strnlen+0x1f>
f010561c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0105620:	75 f3                	jne    f0105615 <strnlen+0x10>
f0105622:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0105624:	5d                   	pop    %ebp
f0105625:	c3                   	ret    

f0105626 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105626:	55                   	push   %ebp
f0105627:	89 e5                	mov    %esp,%ebp
f0105629:	53                   	push   %ebx
f010562a:	8b 45 08             	mov    0x8(%ebp),%eax
f010562d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105630:	89 c2                	mov    %eax,%edx
f0105632:	83 c2 01             	add    $0x1,%edx
f0105635:	83 c1 01             	add    $0x1,%ecx
f0105638:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010563c:	88 5a ff             	mov    %bl,-0x1(%edx)
f010563f:	84 db                	test   %bl,%bl
f0105641:	75 ef                	jne    f0105632 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0105643:	5b                   	pop    %ebx
f0105644:	5d                   	pop    %ebp
f0105645:	c3                   	ret    

f0105646 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105646:	55                   	push   %ebp
f0105647:	89 e5                	mov    %esp,%ebp
f0105649:	53                   	push   %ebx
f010564a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010564d:	53                   	push   %ebx
f010564e:	e8 9a ff ff ff       	call   f01055ed <strlen>
f0105653:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0105656:	ff 75 0c             	pushl  0xc(%ebp)
f0105659:	01 d8                	add    %ebx,%eax
f010565b:	50                   	push   %eax
f010565c:	e8 c5 ff ff ff       	call   f0105626 <strcpy>
	return dst;
}
f0105661:	89 d8                	mov    %ebx,%eax
f0105663:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105666:	c9                   	leave  
f0105667:	c3                   	ret    

f0105668 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105668:	55                   	push   %ebp
f0105669:	89 e5                	mov    %esp,%ebp
f010566b:	56                   	push   %esi
f010566c:	53                   	push   %ebx
f010566d:	8b 75 08             	mov    0x8(%ebp),%esi
f0105670:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105673:	89 f3                	mov    %esi,%ebx
f0105675:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105678:	89 f2                	mov    %esi,%edx
f010567a:	eb 0f                	jmp    f010568b <strncpy+0x23>
		*dst++ = *src;
f010567c:	83 c2 01             	add    $0x1,%edx
f010567f:	0f b6 01             	movzbl (%ecx),%eax
f0105682:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105685:	80 39 01             	cmpb   $0x1,(%ecx)
f0105688:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010568b:	39 da                	cmp    %ebx,%edx
f010568d:	75 ed                	jne    f010567c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010568f:	89 f0                	mov    %esi,%eax
f0105691:	5b                   	pop    %ebx
f0105692:	5e                   	pop    %esi
f0105693:	5d                   	pop    %ebp
f0105694:	c3                   	ret    

f0105695 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105695:	55                   	push   %ebp
f0105696:	89 e5                	mov    %esp,%ebp
f0105698:	56                   	push   %esi
f0105699:	53                   	push   %ebx
f010569a:	8b 75 08             	mov    0x8(%ebp),%esi
f010569d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01056a0:	8b 55 10             	mov    0x10(%ebp),%edx
f01056a3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01056a5:	85 d2                	test   %edx,%edx
f01056a7:	74 21                	je     f01056ca <strlcpy+0x35>
f01056a9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f01056ad:	89 f2                	mov    %esi,%edx
f01056af:	eb 09                	jmp    f01056ba <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01056b1:	83 c2 01             	add    $0x1,%edx
f01056b4:	83 c1 01             	add    $0x1,%ecx
f01056b7:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01056ba:	39 c2                	cmp    %eax,%edx
f01056bc:	74 09                	je     f01056c7 <strlcpy+0x32>
f01056be:	0f b6 19             	movzbl (%ecx),%ebx
f01056c1:	84 db                	test   %bl,%bl
f01056c3:	75 ec                	jne    f01056b1 <strlcpy+0x1c>
f01056c5:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f01056c7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01056ca:	29 f0                	sub    %esi,%eax
}
f01056cc:	5b                   	pop    %ebx
f01056cd:	5e                   	pop    %esi
f01056ce:	5d                   	pop    %ebp
f01056cf:	c3                   	ret    

f01056d0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01056d0:	55                   	push   %ebp
f01056d1:	89 e5                	mov    %esp,%ebp
f01056d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01056d6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01056d9:	eb 06                	jmp    f01056e1 <strcmp+0x11>
		p++, q++;
f01056db:	83 c1 01             	add    $0x1,%ecx
f01056de:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01056e1:	0f b6 01             	movzbl (%ecx),%eax
f01056e4:	84 c0                	test   %al,%al
f01056e6:	74 04                	je     f01056ec <strcmp+0x1c>
f01056e8:	3a 02                	cmp    (%edx),%al
f01056ea:	74 ef                	je     f01056db <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01056ec:	0f b6 c0             	movzbl %al,%eax
f01056ef:	0f b6 12             	movzbl (%edx),%edx
f01056f2:	29 d0                	sub    %edx,%eax
}
f01056f4:	5d                   	pop    %ebp
f01056f5:	c3                   	ret    

f01056f6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01056f6:	55                   	push   %ebp
f01056f7:	89 e5                	mov    %esp,%ebp
f01056f9:	53                   	push   %ebx
f01056fa:	8b 45 08             	mov    0x8(%ebp),%eax
f01056fd:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105700:	89 c3                	mov    %eax,%ebx
f0105702:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105705:	eb 06                	jmp    f010570d <strncmp+0x17>
		n--, p++, q++;
f0105707:	83 c0 01             	add    $0x1,%eax
f010570a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010570d:	39 d8                	cmp    %ebx,%eax
f010570f:	74 15                	je     f0105726 <strncmp+0x30>
f0105711:	0f b6 08             	movzbl (%eax),%ecx
f0105714:	84 c9                	test   %cl,%cl
f0105716:	74 04                	je     f010571c <strncmp+0x26>
f0105718:	3a 0a                	cmp    (%edx),%cl
f010571a:	74 eb                	je     f0105707 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010571c:	0f b6 00             	movzbl (%eax),%eax
f010571f:	0f b6 12             	movzbl (%edx),%edx
f0105722:	29 d0                	sub    %edx,%eax
f0105724:	eb 05                	jmp    f010572b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105726:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f010572b:	5b                   	pop    %ebx
f010572c:	5d                   	pop    %ebp
f010572d:	c3                   	ret    

f010572e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010572e:	55                   	push   %ebp
f010572f:	89 e5                	mov    %esp,%ebp
f0105731:	8b 45 08             	mov    0x8(%ebp),%eax
f0105734:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105738:	eb 07                	jmp    f0105741 <strchr+0x13>
		if (*s == c)
f010573a:	38 ca                	cmp    %cl,%dl
f010573c:	74 0f                	je     f010574d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010573e:	83 c0 01             	add    $0x1,%eax
f0105741:	0f b6 10             	movzbl (%eax),%edx
f0105744:	84 d2                	test   %dl,%dl
f0105746:	75 f2                	jne    f010573a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0105748:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010574d:	5d                   	pop    %ebp
f010574e:	c3                   	ret    

f010574f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010574f:	55                   	push   %ebp
f0105750:	89 e5                	mov    %esp,%ebp
f0105752:	8b 45 08             	mov    0x8(%ebp),%eax
f0105755:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105759:	eb 03                	jmp    f010575e <strfind+0xf>
f010575b:	83 c0 01             	add    $0x1,%eax
f010575e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0105761:	38 ca                	cmp    %cl,%dl
f0105763:	74 04                	je     f0105769 <strfind+0x1a>
f0105765:	84 d2                	test   %dl,%dl
f0105767:	75 f2                	jne    f010575b <strfind+0xc>
			break;
	return (char *) s;
}
f0105769:	5d                   	pop    %ebp
f010576a:	c3                   	ret    

f010576b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010576b:	55                   	push   %ebp
f010576c:	89 e5                	mov    %esp,%ebp
f010576e:	57                   	push   %edi
f010576f:	56                   	push   %esi
f0105770:	53                   	push   %ebx
f0105771:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105774:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105777:	85 c9                	test   %ecx,%ecx
f0105779:	74 36                	je     f01057b1 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010577b:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105781:	75 28                	jne    f01057ab <memset+0x40>
f0105783:	f6 c1 03             	test   $0x3,%cl
f0105786:	75 23                	jne    f01057ab <memset+0x40>
		c &= 0xFF;
f0105788:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010578c:	89 d3                	mov    %edx,%ebx
f010578e:	c1 e3 08             	shl    $0x8,%ebx
f0105791:	89 d6                	mov    %edx,%esi
f0105793:	c1 e6 18             	shl    $0x18,%esi
f0105796:	89 d0                	mov    %edx,%eax
f0105798:	c1 e0 10             	shl    $0x10,%eax
f010579b:	09 f0                	or     %esi,%eax
f010579d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f010579f:	89 d8                	mov    %ebx,%eax
f01057a1:	09 d0                	or     %edx,%eax
f01057a3:	c1 e9 02             	shr    $0x2,%ecx
f01057a6:	fc                   	cld    
f01057a7:	f3 ab                	rep stos %eax,%es:(%edi)
f01057a9:	eb 06                	jmp    f01057b1 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01057ab:	8b 45 0c             	mov    0xc(%ebp),%eax
f01057ae:	fc                   	cld    
f01057af:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01057b1:	89 f8                	mov    %edi,%eax
f01057b3:	5b                   	pop    %ebx
f01057b4:	5e                   	pop    %esi
f01057b5:	5f                   	pop    %edi
f01057b6:	5d                   	pop    %ebp
f01057b7:	c3                   	ret    

f01057b8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01057b8:	55                   	push   %ebp
f01057b9:	89 e5                	mov    %esp,%ebp
f01057bb:	57                   	push   %edi
f01057bc:	56                   	push   %esi
f01057bd:	8b 45 08             	mov    0x8(%ebp),%eax
f01057c0:	8b 75 0c             	mov    0xc(%ebp),%esi
f01057c3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01057c6:	39 c6                	cmp    %eax,%esi
f01057c8:	73 35                	jae    f01057ff <memmove+0x47>
f01057ca:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01057cd:	39 d0                	cmp    %edx,%eax
f01057cf:	73 2e                	jae    f01057ff <memmove+0x47>
		s += n;
		d += n;
f01057d1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01057d4:	89 d6                	mov    %edx,%esi
f01057d6:	09 fe                	or     %edi,%esi
f01057d8:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01057de:	75 13                	jne    f01057f3 <memmove+0x3b>
f01057e0:	f6 c1 03             	test   $0x3,%cl
f01057e3:	75 0e                	jne    f01057f3 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f01057e5:	83 ef 04             	sub    $0x4,%edi
f01057e8:	8d 72 fc             	lea    -0x4(%edx),%esi
f01057eb:	c1 e9 02             	shr    $0x2,%ecx
f01057ee:	fd                   	std    
f01057ef:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01057f1:	eb 09                	jmp    f01057fc <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01057f3:	83 ef 01             	sub    $0x1,%edi
f01057f6:	8d 72 ff             	lea    -0x1(%edx),%esi
f01057f9:	fd                   	std    
f01057fa:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01057fc:	fc                   	cld    
f01057fd:	eb 1d                	jmp    f010581c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01057ff:	89 f2                	mov    %esi,%edx
f0105801:	09 c2                	or     %eax,%edx
f0105803:	f6 c2 03             	test   $0x3,%dl
f0105806:	75 0f                	jne    f0105817 <memmove+0x5f>
f0105808:	f6 c1 03             	test   $0x3,%cl
f010580b:	75 0a                	jne    f0105817 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f010580d:	c1 e9 02             	shr    $0x2,%ecx
f0105810:	89 c7                	mov    %eax,%edi
f0105812:	fc                   	cld    
f0105813:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105815:	eb 05                	jmp    f010581c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105817:	89 c7                	mov    %eax,%edi
f0105819:	fc                   	cld    
f010581a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010581c:	5e                   	pop    %esi
f010581d:	5f                   	pop    %edi
f010581e:	5d                   	pop    %ebp
f010581f:	c3                   	ret    

f0105820 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105820:	55                   	push   %ebp
f0105821:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0105823:	ff 75 10             	pushl  0x10(%ebp)
f0105826:	ff 75 0c             	pushl  0xc(%ebp)
f0105829:	ff 75 08             	pushl  0x8(%ebp)
f010582c:	e8 87 ff ff ff       	call   f01057b8 <memmove>
}
f0105831:	c9                   	leave  
f0105832:	c3                   	ret    

f0105833 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105833:	55                   	push   %ebp
f0105834:	89 e5                	mov    %esp,%ebp
f0105836:	56                   	push   %esi
f0105837:	53                   	push   %ebx
f0105838:	8b 45 08             	mov    0x8(%ebp),%eax
f010583b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010583e:	89 c6                	mov    %eax,%esi
f0105840:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105843:	eb 1a                	jmp    f010585f <memcmp+0x2c>
		if (*s1 != *s2)
f0105845:	0f b6 08             	movzbl (%eax),%ecx
f0105848:	0f b6 1a             	movzbl (%edx),%ebx
f010584b:	38 d9                	cmp    %bl,%cl
f010584d:	74 0a                	je     f0105859 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f010584f:	0f b6 c1             	movzbl %cl,%eax
f0105852:	0f b6 db             	movzbl %bl,%ebx
f0105855:	29 d8                	sub    %ebx,%eax
f0105857:	eb 0f                	jmp    f0105868 <memcmp+0x35>
		s1++, s2++;
f0105859:	83 c0 01             	add    $0x1,%eax
f010585c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010585f:	39 f0                	cmp    %esi,%eax
f0105861:	75 e2                	jne    f0105845 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0105863:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105868:	5b                   	pop    %ebx
f0105869:	5e                   	pop    %esi
f010586a:	5d                   	pop    %ebp
f010586b:	c3                   	ret    

f010586c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010586c:	55                   	push   %ebp
f010586d:	89 e5                	mov    %esp,%ebp
f010586f:	53                   	push   %ebx
f0105870:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0105873:	89 c1                	mov    %eax,%ecx
f0105875:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0105878:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010587c:	eb 0a                	jmp    f0105888 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f010587e:	0f b6 10             	movzbl (%eax),%edx
f0105881:	39 da                	cmp    %ebx,%edx
f0105883:	74 07                	je     f010588c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105885:	83 c0 01             	add    $0x1,%eax
f0105888:	39 c8                	cmp    %ecx,%eax
f010588a:	72 f2                	jb     f010587e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f010588c:	5b                   	pop    %ebx
f010588d:	5d                   	pop    %ebp
f010588e:	c3                   	ret    

f010588f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010588f:	55                   	push   %ebp
f0105890:	89 e5                	mov    %esp,%ebp
f0105892:	57                   	push   %edi
f0105893:	56                   	push   %esi
f0105894:	53                   	push   %ebx
f0105895:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105898:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010589b:	eb 03                	jmp    f01058a0 <strtol+0x11>
		s++;
f010589d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01058a0:	0f b6 01             	movzbl (%ecx),%eax
f01058a3:	3c 20                	cmp    $0x20,%al
f01058a5:	74 f6                	je     f010589d <strtol+0xe>
f01058a7:	3c 09                	cmp    $0x9,%al
f01058a9:	74 f2                	je     f010589d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01058ab:	3c 2b                	cmp    $0x2b,%al
f01058ad:	75 0a                	jne    f01058b9 <strtol+0x2a>
		s++;
f01058af:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01058b2:	bf 00 00 00 00       	mov    $0x0,%edi
f01058b7:	eb 11                	jmp    f01058ca <strtol+0x3b>
f01058b9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01058be:	3c 2d                	cmp    $0x2d,%al
f01058c0:	75 08                	jne    f01058ca <strtol+0x3b>
		s++, neg = 1;
f01058c2:	83 c1 01             	add    $0x1,%ecx
f01058c5:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01058ca:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01058d0:	75 15                	jne    f01058e7 <strtol+0x58>
f01058d2:	80 39 30             	cmpb   $0x30,(%ecx)
f01058d5:	75 10                	jne    f01058e7 <strtol+0x58>
f01058d7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01058db:	75 7c                	jne    f0105959 <strtol+0xca>
		s += 2, base = 16;
f01058dd:	83 c1 02             	add    $0x2,%ecx
f01058e0:	bb 10 00 00 00       	mov    $0x10,%ebx
f01058e5:	eb 16                	jmp    f01058fd <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f01058e7:	85 db                	test   %ebx,%ebx
f01058e9:	75 12                	jne    f01058fd <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01058eb:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01058f0:	80 39 30             	cmpb   $0x30,(%ecx)
f01058f3:	75 08                	jne    f01058fd <strtol+0x6e>
		s++, base = 8;
f01058f5:	83 c1 01             	add    $0x1,%ecx
f01058f8:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f01058fd:	b8 00 00 00 00       	mov    $0x0,%eax
f0105902:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105905:	0f b6 11             	movzbl (%ecx),%edx
f0105908:	8d 72 d0             	lea    -0x30(%edx),%esi
f010590b:	89 f3                	mov    %esi,%ebx
f010590d:	80 fb 09             	cmp    $0x9,%bl
f0105910:	77 08                	ja     f010591a <strtol+0x8b>
			dig = *s - '0';
f0105912:	0f be d2             	movsbl %dl,%edx
f0105915:	83 ea 30             	sub    $0x30,%edx
f0105918:	eb 22                	jmp    f010593c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f010591a:	8d 72 9f             	lea    -0x61(%edx),%esi
f010591d:	89 f3                	mov    %esi,%ebx
f010591f:	80 fb 19             	cmp    $0x19,%bl
f0105922:	77 08                	ja     f010592c <strtol+0x9d>
			dig = *s - 'a' + 10;
f0105924:	0f be d2             	movsbl %dl,%edx
f0105927:	83 ea 57             	sub    $0x57,%edx
f010592a:	eb 10                	jmp    f010593c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f010592c:	8d 72 bf             	lea    -0x41(%edx),%esi
f010592f:	89 f3                	mov    %esi,%ebx
f0105931:	80 fb 19             	cmp    $0x19,%bl
f0105934:	77 16                	ja     f010594c <strtol+0xbd>
			dig = *s - 'A' + 10;
f0105936:	0f be d2             	movsbl %dl,%edx
f0105939:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f010593c:	3b 55 10             	cmp    0x10(%ebp),%edx
f010593f:	7d 0b                	jge    f010594c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f0105941:	83 c1 01             	add    $0x1,%ecx
f0105944:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105948:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f010594a:	eb b9                	jmp    f0105905 <strtol+0x76>

	if (endptr)
f010594c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105950:	74 0d                	je     f010595f <strtol+0xd0>
		*endptr = (char *) s;
f0105952:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105955:	89 0e                	mov    %ecx,(%esi)
f0105957:	eb 06                	jmp    f010595f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105959:	85 db                	test   %ebx,%ebx
f010595b:	74 98                	je     f01058f5 <strtol+0x66>
f010595d:	eb 9e                	jmp    f01058fd <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f010595f:	89 c2                	mov    %eax,%edx
f0105961:	f7 da                	neg    %edx
f0105963:	85 ff                	test   %edi,%edi
f0105965:	0f 45 c2             	cmovne %edx,%eax
}
f0105968:	5b                   	pop    %ebx
f0105969:	5e                   	pop    %esi
f010596a:	5f                   	pop    %edi
f010596b:	5d                   	pop    %ebp
f010596c:	c3                   	ret    
f010596d:	66 90                	xchg   %ax,%ax
f010596f:	90                   	nop

f0105970 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105970:	fa                   	cli    

	xorw    %ax, %ax
f0105971:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105973:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105975:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105977:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105979:	0f 01 16             	lgdtl  (%esi)
f010597c:	74 70                	je     f01059ee <mpsearch1+0x3>
	movl    %cr0, %eax
f010597e:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105981:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105985:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105988:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f010598e:	08 00                	or     %al,(%eax)

f0105990 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105990:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105994:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105996:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105998:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f010599a:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f010599e:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f01059a0:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f01059a2:	b8 00 00 12 00       	mov    $0x120000,%eax
	movl    %eax, %cr3
f01059a7:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f01059aa:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f01059ad:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f01059b2:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f01059b5:	8b 25 9c 9e 2a f0    	mov    0xf02a9e9c,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f01059bb:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f01059c0:	b8 c9 01 10 f0       	mov    $0xf01001c9,%eax
	call    *%eax
f01059c5:	ff d0                	call   *%eax

f01059c7 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f01059c7:	eb fe                	jmp    f01059c7 <spin>
f01059c9:	8d 76 00             	lea    0x0(%esi),%esi

f01059cc <gdt>:
	...
f01059d4:	ff                   	(bad)  
f01059d5:	ff 00                	incl   (%eax)
f01059d7:	00 00                	add    %al,(%eax)
f01059d9:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f01059e0:	00                   	.byte 0x0
f01059e1:	92                   	xchg   %eax,%edx
f01059e2:	cf                   	iret   
	...

f01059e4 <gdtdesc>:
f01059e4:	17                   	pop    %ss
f01059e5:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f01059ea <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f01059ea:	90                   	nop

f01059eb <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f01059eb:	55                   	push   %ebp
f01059ec:	89 e5                	mov    %esp,%ebp
f01059ee:	57                   	push   %edi
f01059ef:	56                   	push   %esi
f01059f0:	53                   	push   %ebx
f01059f1:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01059f4:	8b 0d a0 9e 2a f0    	mov    0xf02a9ea0,%ecx
f01059fa:	89 c3                	mov    %eax,%ebx
f01059fc:	c1 eb 0c             	shr    $0xc,%ebx
f01059ff:	39 cb                	cmp    %ecx,%ebx
f0105a01:	72 12                	jb     f0105a15 <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105a03:	50                   	push   %eax
f0105a04:	68 a4 69 10 f0       	push   $0xf01069a4
f0105a09:	6a 57                	push   $0x57
f0105a0b:	68 7d 87 10 f0       	push   $0xf010877d
f0105a10:	e8 2b a6 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105a15:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105a1b:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105a1d:	89 c2                	mov    %eax,%edx
f0105a1f:	c1 ea 0c             	shr    $0xc,%edx
f0105a22:	39 ca                	cmp    %ecx,%edx
f0105a24:	72 12                	jb     f0105a38 <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105a26:	50                   	push   %eax
f0105a27:	68 a4 69 10 f0       	push   $0xf01069a4
f0105a2c:	6a 57                	push   $0x57
f0105a2e:	68 7d 87 10 f0       	push   $0xf010877d
f0105a33:	e8 08 a6 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105a38:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f0105a3e:	eb 2f                	jmp    f0105a6f <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105a40:	83 ec 04             	sub    $0x4,%esp
f0105a43:	6a 04                	push   $0x4
f0105a45:	68 8d 87 10 f0       	push   $0xf010878d
f0105a4a:	53                   	push   %ebx
f0105a4b:	e8 e3 fd ff ff       	call   f0105833 <memcmp>
f0105a50:	83 c4 10             	add    $0x10,%esp
f0105a53:	85 c0                	test   %eax,%eax
f0105a55:	75 15                	jne    f0105a6c <mpsearch1+0x81>
f0105a57:	89 da                	mov    %ebx,%edx
f0105a59:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f0105a5c:	0f b6 0a             	movzbl (%edx),%ecx
f0105a5f:	01 c8                	add    %ecx,%eax
f0105a61:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105a64:	39 d7                	cmp    %edx,%edi
f0105a66:	75 f4                	jne    f0105a5c <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105a68:	84 c0                	test   %al,%al
f0105a6a:	74 0e                	je     f0105a7a <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0105a6c:	83 c3 10             	add    $0x10,%ebx
f0105a6f:	39 f3                	cmp    %esi,%ebx
f0105a71:	72 cd                	jb     f0105a40 <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105a73:	b8 00 00 00 00       	mov    $0x0,%eax
f0105a78:	eb 02                	jmp    f0105a7c <mpsearch1+0x91>
f0105a7a:	89 d8                	mov    %ebx,%eax
}
f0105a7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105a7f:	5b                   	pop    %ebx
f0105a80:	5e                   	pop    %esi
f0105a81:	5f                   	pop    %edi
f0105a82:	5d                   	pop    %ebp
f0105a83:	c3                   	ret    

f0105a84 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105a84:	55                   	push   %ebp
f0105a85:	89 e5                	mov    %esp,%ebp
f0105a87:	57                   	push   %edi
f0105a88:	56                   	push   %esi
f0105a89:	53                   	push   %ebx
f0105a8a:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105a8d:	c7 05 c0 a3 2a f0 20 	movl   $0xf02aa020,0xf02aa3c0
f0105a94:	a0 2a f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105a97:	83 3d a0 9e 2a f0 00 	cmpl   $0x0,0xf02a9ea0
f0105a9e:	75 16                	jne    f0105ab6 <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105aa0:	68 00 04 00 00       	push   $0x400
f0105aa5:	68 a4 69 10 f0       	push   $0xf01069a4
f0105aaa:	6a 6f                	push   $0x6f
f0105aac:	68 7d 87 10 f0       	push   $0xf010877d
f0105ab1:	e8 8a a5 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105ab6:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105abd:	85 c0                	test   %eax,%eax
f0105abf:	74 16                	je     f0105ad7 <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f0105ac1:	c1 e0 04             	shl    $0x4,%eax
f0105ac4:	ba 00 04 00 00       	mov    $0x400,%edx
f0105ac9:	e8 1d ff ff ff       	call   f01059eb <mpsearch1>
f0105ace:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105ad1:	85 c0                	test   %eax,%eax
f0105ad3:	75 3c                	jne    f0105b11 <mp_init+0x8d>
f0105ad5:	eb 20                	jmp    f0105af7 <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105ad7:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105ade:	c1 e0 0a             	shl    $0xa,%eax
f0105ae1:	2d 00 04 00 00       	sub    $0x400,%eax
f0105ae6:	ba 00 04 00 00       	mov    $0x400,%edx
f0105aeb:	e8 fb fe ff ff       	call   f01059eb <mpsearch1>
f0105af0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105af3:	85 c0                	test   %eax,%eax
f0105af5:	75 1a                	jne    f0105b11 <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0105af7:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105afc:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105b01:	e8 e5 fe ff ff       	call   f01059eb <mpsearch1>
f0105b06:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0105b09:	85 c0                	test   %eax,%eax
f0105b0b:	0f 84 5d 02 00 00    	je     f0105d6e <mp_init+0x2ea>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105b11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105b14:	8b 70 04             	mov    0x4(%eax),%esi
f0105b17:	85 f6                	test   %esi,%esi
f0105b19:	74 06                	je     f0105b21 <mp_init+0x9d>
f0105b1b:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105b1f:	74 15                	je     f0105b36 <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f0105b21:	83 ec 0c             	sub    $0xc,%esp
f0105b24:	68 f0 85 10 f0       	push   $0xf01085f0
f0105b29:	e8 63 de ff ff       	call   f0103991 <cprintf>
f0105b2e:	83 c4 10             	add    $0x10,%esp
f0105b31:	e9 38 02 00 00       	jmp    f0105d6e <mp_init+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105b36:	89 f0                	mov    %esi,%eax
f0105b38:	c1 e8 0c             	shr    $0xc,%eax
f0105b3b:	3b 05 a0 9e 2a f0    	cmp    0xf02a9ea0,%eax
f0105b41:	72 15                	jb     f0105b58 <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105b43:	56                   	push   %esi
f0105b44:	68 a4 69 10 f0       	push   $0xf01069a4
f0105b49:	68 90 00 00 00       	push   $0x90
f0105b4e:	68 7d 87 10 f0       	push   $0xf010877d
f0105b53:	e8 e8 a4 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105b58:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105b5e:	83 ec 04             	sub    $0x4,%esp
f0105b61:	6a 04                	push   $0x4
f0105b63:	68 92 87 10 f0       	push   $0xf0108792
f0105b68:	53                   	push   %ebx
f0105b69:	e8 c5 fc ff ff       	call   f0105833 <memcmp>
f0105b6e:	83 c4 10             	add    $0x10,%esp
f0105b71:	85 c0                	test   %eax,%eax
f0105b73:	74 15                	je     f0105b8a <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105b75:	83 ec 0c             	sub    $0xc,%esp
f0105b78:	68 20 86 10 f0       	push   $0xf0108620
f0105b7d:	e8 0f de ff ff       	call   f0103991 <cprintf>
f0105b82:	83 c4 10             	add    $0x10,%esp
f0105b85:	e9 e4 01 00 00       	jmp    f0105d6e <mp_init+0x2ea>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105b8a:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f0105b8e:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f0105b92:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105b95:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105b9a:	b8 00 00 00 00       	mov    $0x0,%eax
f0105b9f:	eb 0d                	jmp    f0105bae <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f0105ba1:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0105ba8:	f0 
f0105ba9:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105bab:	83 c0 01             	add    $0x1,%eax
f0105bae:	39 c7                	cmp    %eax,%edi
f0105bb0:	75 ef                	jne    f0105ba1 <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105bb2:	84 d2                	test   %dl,%dl
f0105bb4:	74 15                	je     f0105bcb <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105bb6:	83 ec 0c             	sub    $0xc,%esp
f0105bb9:	68 54 86 10 f0       	push   $0xf0108654
f0105bbe:	e8 ce dd ff ff       	call   f0103991 <cprintf>
f0105bc3:	83 c4 10             	add    $0x10,%esp
f0105bc6:	e9 a3 01 00 00       	jmp    f0105d6e <mp_init+0x2ea>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0105bcb:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0105bcf:	3c 01                	cmp    $0x1,%al
f0105bd1:	74 1d                	je     f0105bf0 <mp_init+0x16c>
f0105bd3:	3c 04                	cmp    $0x4,%al
f0105bd5:	74 19                	je     f0105bf0 <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105bd7:	83 ec 08             	sub    $0x8,%esp
f0105bda:	0f b6 c0             	movzbl %al,%eax
f0105bdd:	50                   	push   %eax
f0105bde:	68 78 86 10 f0       	push   $0xf0108678
f0105be3:	e8 a9 dd ff ff       	call   f0103991 <cprintf>
f0105be8:	83 c4 10             	add    $0x10,%esp
f0105beb:	e9 7e 01 00 00       	jmp    f0105d6e <mp_init+0x2ea>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105bf0:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f0105bf4:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105bf8:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105bfd:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f0105c02:	01 ce                	add    %ecx,%esi
f0105c04:	eb 0d                	jmp    f0105c13 <mp_init+0x18f>
f0105c06:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f0105c0d:	f0 
f0105c0e:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105c10:	83 c0 01             	add    $0x1,%eax
f0105c13:	39 c7                	cmp    %eax,%edi
f0105c15:	75 ef                	jne    f0105c06 <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105c17:	89 d0                	mov    %edx,%eax
f0105c19:	02 43 2a             	add    0x2a(%ebx),%al
f0105c1c:	74 15                	je     f0105c33 <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105c1e:	83 ec 0c             	sub    $0xc,%esp
f0105c21:	68 98 86 10 f0       	push   $0xf0108698
f0105c26:	e8 66 dd ff ff       	call   f0103991 <cprintf>
f0105c2b:	83 c4 10             	add    $0x10,%esp
f0105c2e:	e9 3b 01 00 00       	jmp    f0105d6e <mp_init+0x2ea>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0105c33:	85 db                	test   %ebx,%ebx
f0105c35:	0f 84 33 01 00 00    	je     f0105d6e <mp_init+0x2ea>
		return;
	ismp = 1;
f0105c3b:	c7 05 00 a0 2a f0 01 	movl   $0x1,0xf02aa000
f0105c42:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105c45:	8b 43 24             	mov    0x24(%ebx),%eax
f0105c48:	a3 00 b0 2e f0       	mov    %eax,0xf02eb000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105c4d:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0105c50:	be 00 00 00 00       	mov    $0x0,%esi
f0105c55:	e9 85 00 00 00       	jmp    f0105cdf <mp_init+0x25b>
		switch (*p) {
f0105c5a:	0f b6 07             	movzbl (%edi),%eax
f0105c5d:	84 c0                	test   %al,%al
f0105c5f:	74 06                	je     f0105c67 <mp_init+0x1e3>
f0105c61:	3c 04                	cmp    $0x4,%al
f0105c63:	77 55                	ja     f0105cba <mp_init+0x236>
f0105c65:	eb 4e                	jmp    f0105cb5 <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105c67:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105c6b:	74 11                	je     f0105c7e <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f0105c6d:	6b 05 c4 a3 2a f0 74 	imul   $0x74,0xf02aa3c4,%eax
f0105c74:	05 20 a0 2a f0       	add    $0xf02aa020,%eax
f0105c79:	a3 c0 a3 2a f0       	mov    %eax,0xf02aa3c0
			if (ncpu < NCPU) {
f0105c7e:	a1 c4 a3 2a f0       	mov    0xf02aa3c4,%eax
f0105c83:	83 f8 07             	cmp    $0x7,%eax
f0105c86:	7f 13                	jg     f0105c9b <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f0105c88:	6b d0 74             	imul   $0x74,%eax,%edx
f0105c8b:	88 82 20 a0 2a f0    	mov    %al,-0xfd55fe0(%edx)
				ncpu++;
f0105c91:	83 c0 01             	add    $0x1,%eax
f0105c94:	a3 c4 a3 2a f0       	mov    %eax,0xf02aa3c4
f0105c99:	eb 15                	jmp    f0105cb0 <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105c9b:	83 ec 08             	sub    $0x8,%esp
f0105c9e:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105ca2:	50                   	push   %eax
f0105ca3:	68 c8 86 10 f0       	push   $0xf01086c8
f0105ca8:	e8 e4 dc ff ff       	call   f0103991 <cprintf>
f0105cad:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105cb0:	83 c7 14             	add    $0x14,%edi
			continue;
f0105cb3:	eb 27                	jmp    f0105cdc <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105cb5:	83 c7 08             	add    $0x8,%edi
			continue;
f0105cb8:	eb 22                	jmp    f0105cdc <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105cba:	83 ec 08             	sub    $0x8,%esp
f0105cbd:	0f b6 c0             	movzbl %al,%eax
f0105cc0:	50                   	push   %eax
f0105cc1:	68 f0 86 10 f0       	push   $0xf01086f0
f0105cc6:	e8 c6 dc ff ff       	call   f0103991 <cprintf>
			ismp = 0;
f0105ccb:	c7 05 00 a0 2a f0 00 	movl   $0x0,0xf02aa000
f0105cd2:	00 00 00 
			i = conf->entry;
f0105cd5:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f0105cd9:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105cdc:	83 c6 01             	add    $0x1,%esi
f0105cdf:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0105ce3:	39 c6                	cmp    %eax,%esi
f0105ce5:	0f 82 6f ff ff ff    	jb     f0105c5a <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105ceb:	a1 c0 a3 2a f0       	mov    0xf02aa3c0,%eax
f0105cf0:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105cf7:	83 3d 00 a0 2a f0 00 	cmpl   $0x0,0xf02aa000
f0105cfe:	75 26                	jne    f0105d26 <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105d00:	c7 05 c4 a3 2a f0 01 	movl   $0x1,0xf02aa3c4
f0105d07:	00 00 00 
		lapicaddr = 0;
f0105d0a:	c7 05 00 b0 2e f0 00 	movl   $0x0,0xf02eb000
f0105d11:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105d14:	83 ec 0c             	sub    $0xc,%esp
f0105d17:	68 10 87 10 f0       	push   $0xf0108710
f0105d1c:	e8 70 dc ff ff       	call   f0103991 <cprintf>
		return;
f0105d21:	83 c4 10             	add    $0x10,%esp
f0105d24:	eb 48                	jmp    f0105d6e <mp_init+0x2ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105d26:	83 ec 04             	sub    $0x4,%esp
f0105d29:	ff 35 c4 a3 2a f0    	pushl  0xf02aa3c4
f0105d2f:	0f b6 00             	movzbl (%eax),%eax
f0105d32:	50                   	push   %eax
f0105d33:	68 97 87 10 f0       	push   $0xf0108797
f0105d38:	e8 54 dc ff ff       	call   f0103991 <cprintf>

	if (mp->imcrp) {
f0105d3d:	83 c4 10             	add    $0x10,%esp
f0105d40:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105d43:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105d47:	74 25                	je     f0105d6e <mp_init+0x2ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105d49:	83 ec 0c             	sub    $0xc,%esp
f0105d4c:	68 3c 87 10 f0       	push   $0xf010873c
f0105d51:	e8 3b dc ff ff       	call   f0103991 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105d56:	ba 22 00 00 00       	mov    $0x22,%edx
f0105d5b:	b8 70 00 00 00       	mov    $0x70,%eax
f0105d60:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105d61:	ba 23 00 00 00       	mov    $0x23,%edx
f0105d66:	ec                   	in     (%dx),%al
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105d67:	83 c8 01             	or     $0x1,%eax
f0105d6a:	ee                   	out    %al,(%dx)
f0105d6b:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105d6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105d71:	5b                   	pop    %ebx
f0105d72:	5e                   	pop    %esi
f0105d73:	5f                   	pop    %edi
f0105d74:	5d                   	pop    %ebp
f0105d75:	c3                   	ret    

f0105d76 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105d76:	55                   	push   %ebp
f0105d77:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105d79:	8b 0d 04 b0 2e f0    	mov    0xf02eb004,%ecx
f0105d7f:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105d82:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105d84:	a1 04 b0 2e f0       	mov    0xf02eb004,%eax
f0105d89:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105d8c:	5d                   	pop    %ebp
f0105d8d:	c3                   	ret    

f0105d8e <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105d8e:	55                   	push   %ebp
f0105d8f:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105d91:	a1 04 b0 2e f0       	mov    0xf02eb004,%eax
f0105d96:	85 c0                	test   %eax,%eax
f0105d98:	74 08                	je     f0105da2 <cpunum+0x14>
		return lapic[ID] >> 24;
f0105d9a:	8b 40 20             	mov    0x20(%eax),%eax
f0105d9d:	c1 e8 18             	shr    $0x18,%eax
f0105da0:	eb 05                	jmp    f0105da7 <cpunum+0x19>
	return 0;
f0105da2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105da7:	5d                   	pop    %ebp
f0105da8:	c3                   	ret    

f0105da9 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0105da9:	a1 00 b0 2e f0       	mov    0xf02eb000,%eax
f0105dae:	85 c0                	test   %eax,%eax
f0105db0:	0f 84 21 01 00 00    	je     f0105ed7 <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0105db6:	55                   	push   %ebp
f0105db7:	89 e5                	mov    %esp,%ebp
f0105db9:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0105dbc:	68 00 10 00 00       	push   $0x1000
f0105dc1:	50                   	push   %eax
f0105dc2:	e8 53 b7 ff ff       	call   f010151a <mmio_map_region>
f0105dc7:	a3 04 b0 2e f0       	mov    %eax,0xf02eb004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105dcc:	ba 27 01 00 00       	mov    $0x127,%edx
f0105dd1:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105dd6:	e8 9b ff ff ff       	call   f0105d76 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0105ddb:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105de0:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105de5:	e8 8c ff ff ff       	call   f0105d76 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105dea:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105def:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105df4:	e8 7d ff ff ff       	call   f0105d76 <lapicw>
	lapicw(TICR, 10000000); 
f0105df9:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105dfe:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105e03:	e8 6e ff ff ff       	call   f0105d76 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0105e08:	e8 81 ff ff ff       	call   f0105d8e <cpunum>
f0105e0d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105e10:	05 20 a0 2a f0       	add    $0xf02aa020,%eax
f0105e15:	83 c4 10             	add    $0x10,%esp
f0105e18:	39 05 c0 a3 2a f0    	cmp    %eax,0xf02aa3c0
f0105e1e:	74 0f                	je     f0105e2f <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f0105e20:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105e25:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105e2a:	e8 47 ff ff ff       	call   f0105d76 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0105e2f:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105e34:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105e39:	e8 38 ff ff ff       	call   f0105d76 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105e3e:	a1 04 b0 2e f0       	mov    0xf02eb004,%eax
f0105e43:	8b 40 30             	mov    0x30(%eax),%eax
f0105e46:	c1 e8 10             	shr    $0x10,%eax
f0105e49:	3c 03                	cmp    $0x3,%al
f0105e4b:	76 0f                	jbe    f0105e5c <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f0105e4d:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105e52:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105e57:	e8 1a ff ff ff       	call   f0105d76 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105e5c:	ba 33 00 00 00       	mov    $0x33,%edx
f0105e61:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105e66:	e8 0b ff ff ff       	call   f0105d76 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0105e6b:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e70:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105e75:	e8 fc fe ff ff       	call   f0105d76 <lapicw>
	lapicw(ESR, 0);
f0105e7a:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e7f:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105e84:	e8 ed fe ff ff       	call   f0105d76 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0105e89:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e8e:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105e93:	e8 de fe ff ff       	call   f0105d76 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0105e98:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e9d:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105ea2:	e8 cf fe ff ff       	call   f0105d76 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105ea7:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105eac:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105eb1:	e8 c0 fe ff ff       	call   f0105d76 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105eb6:	8b 15 04 b0 2e f0    	mov    0xf02eb004,%edx
f0105ebc:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105ec2:	f6 c4 10             	test   $0x10,%ah
f0105ec5:	75 f5                	jne    f0105ebc <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0105ec7:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ecc:	b8 20 00 00 00       	mov    $0x20,%eax
f0105ed1:	e8 a0 fe ff ff       	call   f0105d76 <lapicw>
}
f0105ed6:	c9                   	leave  
f0105ed7:	f3 c3                	repz ret 

f0105ed9 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105ed9:	83 3d 04 b0 2e f0 00 	cmpl   $0x0,0xf02eb004
f0105ee0:	74 13                	je     f0105ef5 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105ee2:	55                   	push   %ebp
f0105ee3:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0105ee5:	ba 00 00 00 00       	mov    $0x0,%edx
f0105eea:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105eef:	e8 82 fe ff ff       	call   f0105d76 <lapicw>
}
f0105ef4:	5d                   	pop    %ebp
f0105ef5:	f3 c3                	repz ret 

f0105ef7 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105ef7:	55                   	push   %ebp
f0105ef8:	89 e5                	mov    %esp,%ebp
f0105efa:	56                   	push   %esi
f0105efb:	53                   	push   %ebx
f0105efc:	8b 75 08             	mov    0x8(%ebp),%esi
f0105eff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105f02:	ba 70 00 00 00       	mov    $0x70,%edx
f0105f07:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105f0c:	ee                   	out    %al,(%dx)
f0105f0d:	ba 71 00 00 00       	mov    $0x71,%edx
f0105f12:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105f17:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105f18:	83 3d a0 9e 2a f0 00 	cmpl   $0x0,0xf02a9ea0
f0105f1f:	75 19                	jne    f0105f3a <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105f21:	68 67 04 00 00       	push   $0x467
f0105f26:	68 a4 69 10 f0       	push   $0xf01069a4
f0105f2b:	68 98 00 00 00       	push   $0x98
f0105f30:	68 b4 87 10 f0       	push   $0xf01087b4
f0105f35:	e8 06 a1 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105f3a:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105f41:	00 00 
	wrv[1] = addr >> 4;
f0105f43:	89 d8                	mov    %ebx,%eax
f0105f45:	c1 e8 04             	shr    $0x4,%eax
f0105f48:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105f4e:	c1 e6 18             	shl    $0x18,%esi
f0105f51:	89 f2                	mov    %esi,%edx
f0105f53:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105f58:	e8 19 fe ff ff       	call   f0105d76 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105f5d:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105f62:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f67:	e8 0a fe ff ff       	call   f0105d76 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105f6c:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105f71:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f76:	e8 fb fd ff ff       	call   f0105d76 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105f7b:	c1 eb 0c             	shr    $0xc,%ebx
f0105f7e:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105f81:	89 f2                	mov    %esi,%edx
f0105f83:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105f88:	e8 e9 fd ff ff       	call   f0105d76 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105f8d:	89 da                	mov    %ebx,%edx
f0105f8f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f94:	e8 dd fd ff ff       	call   f0105d76 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105f99:	89 f2                	mov    %esi,%edx
f0105f9b:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105fa0:	e8 d1 fd ff ff       	call   f0105d76 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105fa5:	89 da                	mov    %ebx,%edx
f0105fa7:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105fac:	e8 c5 fd ff ff       	call   f0105d76 <lapicw>
		microdelay(200);
	}
}
f0105fb1:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105fb4:	5b                   	pop    %ebx
f0105fb5:	5e                   	pop    %esi
f0105fb6:	5d                   	pop    %ebp
f0105fb7:	c3                   	ret    

f0105fb8 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0105fb8:	55                   	push   %ebp
f0105fb9:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0105fbb:	8b 55 08             	mov    0x8(%ebp),%edx
f0105fbe:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105fc4:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105fc9:	e8 a8 fd ff ff       	call   f0105d76 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0105fce:	8b 15 04 b0 2e f0    	mov    0xf02eb004,%edx
f0105fd4:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105fda:	f6 c4 10             	test   $0x10,%ah
f0105fdd:	75 f5                	jne    f0105fd4 <lapic_ipi+0x1c>
		;
}
f0105fdf:	5d                   	pop    %ebp
f0105fe0:	c3                   	ret    

f0105fe1 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105fe1:	55                   	push   %ebp
f0105fe2:	89 e5                	mov    %esp,%ebp
f0105fe4:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105fe7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0105fed:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105ff0:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105ff3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105ffa:	5d                   	pop    %ebp
f0105ffb:	c3                   	ret    

f0105ffc <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0105ffc:	55                   	push   %ebp
f0105ffd:	89 e5                	mov    %esp,%ebp
f0105fff:	56                   	push   %esi
f0106000:	53                   	push   %ebx
f0106001:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0106004:	83 3b 00             	cmpl   $0x0,(%ebx)
f0106007:	74 14                	je     f010601d <spin_lock+0x21>
f0106009:	8b 73 08             	mov    0x8(%ebx),%esi
f010600c:	e8 7d fd ff ff       	call   f0105d8e <cpunum>
f0106011:	6b c0 74             	imul   $0x74,%eax,%eax
f0106014:	05 20 a0 2a f0       	add    $0xf02aa020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0106019:	39 c6                	cmp    %eax,%esi
f010601b:	74 07                	je     f0106024 <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f010601d:	ba 01 00 00 00       	mov    $0x1,%edx
f0106022:	eb 20                	jmp    f0106044 <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106024:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106027:	e8 62 fd ff ff       	call   f0105d8e <cpunum>
f010602c:	83 ec 0c             	sub    $0xc,%esp
f010602f:	53                   	push   %ebx
f0106030:	50                   	push   %eax
f0106031:	68 c4 87 10 f0       	push   $0xf01087c4
f0106036:	6a 41                	push   $0x41
f0106038:	68 26 88 10 f0       	push   $0xf0108826
f010603d:	e8 fe 9f ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0106042:	f3 90                	pause  
f0106044:	89 d0                	mov    %edx,%eax
f0106046:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106049:	85 c0                	test   %eax,%eax
f010604b:	75 f5                	jne    f0106042 <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f010604d:	e8 3c fd ff ff       	call   f0105d8e <cpunum>
f0106052:	6b c0 74             	imul   $0x74,%eax,%eax
f0106055:	05 20 a0 2a f0       	add    $0xf02aa020,%eax
f010605a:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f010605d:	83 c3 0c             	add    $0xc,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0106060:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106062:	b8 00 00 00 00       	mov    $0x0,%eax
f0106067:	eb 0b                	jmp    f0106074 <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0106069:	8b 4a 04             	mov    0x4(%edx),%ecx
f010606c:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f010606f:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106071:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106074:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f010607a:	76 11                	jbe    f010608d <spin_lock+0x91>
f010607c:	83 f8 09             	cmp    $0x9,%eax
f010607f:	7e e8                	jle    f0106069 <spin_lock+0x6d>
f0106081:	eb 0a                	jmp    f010608d <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0106083:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f010608a:	83 c0 01             	add    $0x1,%eax
f010608d:	83 f8 09             	cmp    $0x9,%eax
f0106090:	7e f1                	jle    f0106083 <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0106092:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106095:	5b                   	pop    %ebx
f0106096:	5e                   	pop    %esi
f0106097:	5d                   	pop    %ebp
f0106098:	c3                   	ret    

f0106099 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106099:	55                   	push   %ebp
f010609a:	89 e5                	mov    %esp,%ebp
f010609c:	57                   	push   %edi
f010609d:	56                   	push   %esi
f010609e:	53                   	push   %ebx
f010609f:	83 ec 4c             	sub    $0x4c,%esp
f01060a2:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f01060a5:	83 3e 00             	cmpl   $0x0,(%esi)
f01060a8:	74 18                	je     f01060c2 <spin_unlock+0x29>
f01060aa:	8b 5e 08             	mov    0x8(%esi),%ebx
f01060ad:	e8 dc fc ff ff       	call   f0105d8e <cpunum>
f01060b2:	6b c0 74             	imul   $0x74,%eax,%eax
f01060b5:	05 20 a0 2a f0       	add    $0xf02aa020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f01060ba:	39 c3                	cmp    %eax,%ebx
f01060bc:	0f 84 a5 00 00 00    	je     f0106167 <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f01060c2:	83 ec 04             	sub    $0x4,%esp
f01060c5:	6a 28                	push   $0x28
f01060c7:	8d 46 0c             	lea    0xc(%esi),%eax
f01060ca:	50                   	push   %eax
f01060cb:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f01060ce:	53                   	push   %ebx
f01060cf:	e8 e4 f6 ff ff       	call   f01057b8 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f01060d4:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f01060d7:	0f b6 38             	movzbl (%eax),%edi
f01060da:	8b 76 04             	mov    0x4(%esi),%esi
f01060dd:	e8 ac fc ff ff       	call   f0105d8e <cpunum>
f01060e2:	57                   	push   %edi
f01060e3:	56                   	push   %esi
f01060e4:	50                   	push   %eax
f01060e5:	68 f0 87 10 f0       	push   $0xf01087f0
f01060ea:	e8 a2 d8 ff ff       	call   f0103991 <cprintf>
f01060ef:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01060f2:	8d 7d a8             	lea    -0x58(%ebp),%edi
f01060f5:	eb 54                	jmp    f010614b <spin_unlock+0xb2>
f01060f7:	83 ec 08             	sub    $0x8,%esp
f01060fa:	57                   	push   %edi
f01060fb:	50                   	push   %eax
f01060fc:	e8 d8 eb ff ff       	call   f0104cd9 <debuginfo_eip>
f0106101:	83 c4 10             	add    $0x10,%esp
f0106104:	85 c0                	test   %eax,%eax
f0106106:	78 27                	js     f010612f <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0106108:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f010610a:	83 ec 04             	sub    $0x4,%esp
f010610d:	89 c2                	mov    %eax,%edx
f010610f:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0106112:	52                   	push   %edx
f0106113:	ff 75 b0             	pushl  -0x50(%ebp)
f0106116:	ff 75 b4             	pushl  -0x4c(%ebp)
f0106119:	ff 75 ac             	pushl  -0x54(%ebp)
f010611c:	ff 75 a8             	pushl  -0x58(%ebp)
f010611f:	50                   	push   %eax
f0106120:	68 36 88 10 f0       	push   $0xf0108836
f0106125:	e8 67 d8 ff ff       	call   f0103991 <cprintf>
f010612a:	83 c4 20             	add    $0x20,%esp
f010612d:	eb 12                	jmp    f0106141 <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f010612f:	83 ec 08             	sub    $0x8,%esp
f0106132:	ff 36                	pushl  (%esi)
f0106134:	68 4d 88 10 f0       	push   $0xf010884d
f0106139:	e8 53 d8 ff ff       	call   f0103991 <cprintf>
f010613e:	83 c4 10             	add    $0x10,%esp
f0106141:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106144:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0106147:	39 c3                	cmp    %eax,%ebx
f0106149:	74 08                	je     f0106153 <spin_unlock+0xba>
f010614b:	89 de                	mov    %ebx,%esi
f010614d:	8b 03                	mov    (%ebx),%eax
f010614f:	85 c0                	test   %eax,%eax
f0106151:	75 a4                	jne    f01060f7 <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0106153:	83 ec 04             	sub    $0x4,%esp
f0106156:	68 55 88 10 f0       	push   $0xf0108855
f010615b:	6a 67                	push   $0x67
f010615d:	68 26 88 10 f0       	push   $0xf0108826
f0106162:	e8 d9 9e ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0106167:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f010616e:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0106175:	b8 00 00 00 00       	mov    $0x0,%eax
f010617a:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f010617d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106180:	5b                   	pop    %ebx
f0106181:	5e                   	pop    %esi
f0106182:	5f                   	pop    %edi
f0106183:	5d                   	pop    %ebp
f0106184:	c3                   	ret    

f0106185 <pci_attach_match>:
}

static int __attribute__((warn_unused_result))
pci_attach_match(uint32_t key1, uint32_t key2,
		 struct pci_driver *list, struct pci_func *pcif)
{
f0106185:	55                   	push   %ebp
f0106186:	89 e5                	mov    %esp,%ebp
f0106188:	57                   	push   %edi
f0106189:	56                   	push   %esi
f010618a:	53                   	push   %ebx
f010618b:	83 ec 0c             	sub    $0xc,%esp
f010618e:	8b 7d 08             	mov    0x8(%ebp),%edi
f0106191:	8b 45 10             	mov    0x10(%ebp),%eax
f0106194:	8d 58 08             	lea    0x8(%eax),%ebx
	uint32_t i;

	for (i = 0; list[i].attachfn; i++) {
f0106197:	eb 3a                	jmp    f01061d3 <pci_attach_match+0x4e>
		if (list[i].key1 == key1 && list[i].key2 == key2) {
f0106199:	39 7b f8             	cmp    %edi,-0x8(%ebx)
f010619c:	75 32                	jne    f01061d0 <pci_attach_match+0x4b>
f010619e:	8b 55 0c             	mov    0xc(%ebp),%edx
f01061a1:	39 56 fc             	cmp    %edx,-0x4(%esi)
f01061a4:	75 2a                	jne    f01061d0 <pci_attach_match+0x4b>
			int r = list[i].attachfn(pcif);
f01061a6:	83 ec 0c             	sub    $0xc,%esp
f01061a9:	ff 75 14             	pushl  0x14(%ebp)
f01061ac:	ff d0                	call   *%eax
			if (r > 0)
f01061ae:	83 c4 10             	add    $0x10,%esp
f01061b1:	85 c0                	test   %eax,%eax
f01061b3:	7f 26                	jg     f01061db <pci_attach_match+0x56>
				return r;
			if (r < 0)
f01061b5:	85 c0                	test   %eax,%eax
f01061b7:	79 17                	jns    f01061d0 <pci_attach_match+0x4b>
				cprintf("pci_attach_match: attaching "
f01061b9:	83 ec 0c             	sub    $0xc,%esp
f01061bc:	50                   	push   %eax
f01061bd:	ff 36                	pushl  (%esi)
f01061bf:	ff 75 0c             	pushl  0xc(%ebp)
f01061c2:	57                   	push   %edi
f01061c3:	68 70 88 10 f0       	push   $0xf0108870
f01061c8:	e8 c4 d7 ff ff       	call   f0103991 <cprintf>
f01061cd:	83 c4 20             	add    $0x20,%esp
f01061d0:	83 c3 0c             	add    $0xc,%ebx
f01061d3:	89 de                	mov    %ebx,%esi
pci_attach_match(uint32_t key1, uint32_t key2,
		 struct pci_driver *list, struct pci_func *pcif)
{
	uint32_t i;

	for (i = 0; list[i].attachfn; i++) {
f01061d5:	8b 03                	mov    (%ebx),%eax
f01061d7:	85 c0                	test   %eax,%eax
f01061d9:	75 be                	jne    f0106199 <pci_attach_match+0x14>
					"%x.%x (%p): e\n",
					key1, key2, list[i].attachfn, r);
		}
	}
	return 0;
}
f01061db:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01061de:	5b                   	pop    %ebx
f01061df:	5e                   	pop    %esi
f01061e0:	5f                   	pop    %edi
f01061e1:	5d                   	pop    %ebp
f01061e2:	c3                   	ret    

f01061e3 <pci_conf1_set_addr>:
static void
pci_conf1_set_addr(uint32_t bus,
		   uint32_t dev,
		   uint32_t func,
		   uint32_t offset)
{
f01061e3:	55                   	push   %ebp
f01061e4:	89 e5                	mov    %esp,%ebp
f01061e6:	53                   	push   %ebx
f01061e7:	83 ec 04             	sub    $0x4,%esp
f01061ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	assert(bus < 256);
f01061ed:	3d ff 00 00 00       	cmp    $0xff,%eax
f01061f2:	76 16                	jbe    f010620a <pci_conf1_set_addr+0x27>
f01061f4:	68 c8 89 10 f0       	push   $0xf01089c8
f01061f9:	68 85 6f 10 f0       	push   $0xf0106f85
f01061fe:	6a 2b                	push   $0x2b
f0106200:	68 d2 89 10 f0       	push   $0xf01089d2
f0106205:	e8 36 9e ff ff       	call   f0100040 <_panic>
	assert(dev < 32);
f010620a:	83 fa 1f             	cmp    $0x1f,%edx
f010620d:	76 16                	jbe    f0106225 <pci_conf1_set_addr+0x42>
f010620f:	68 dd 89 10 f0       	push   $0xf01089dd
f0106214:	68 85 6f 10 f0       	push   $0xf0106f85
f0106219:	6a 2c                	push   $0x2c
f010621b:	68 d2 89 10 f0       	push   $0xf01089d2
f0106220:	e8 1b 9e ff ff       	call   f0100040 <_panic>
	assert(func < 8);
f0106225:	83 f9 07             	cmp    $0x7,%ecx
f0106228:	76 16                	jbe    f0106240 <pci_conf1_set_addr+0x5d>
f010622a:	68 e6 89 10 f0       	push   $0xf01089e6
f010622f:	68 85 6f 10 f0       	push   $0xf0106f85
f0106234:	6a 2d                	push   $0x2d
f0106236:	68 d2 89 10 f0       	push   $0xf01089d2
f010623b:	e8 00 9e ff ff       	call   f0100040 <_panic>
	assert(offset < 256);
f0106240:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f0106246:	76 16                	jbe    f010625e <pci_conf1_set_addr+0x7b>
f0106248:	68 ef 89 10 f0       	push   $0xf01089ef
f010624d:	68 85 6f 10 f0       	push   $0xf0106f85
f0106252:	6a 2e                	push   $0x2e
f0106254:	68 d2 89 10 f0       	push   $0xf01089d2
f0106259:	e8 e2 9d ff ff       	call   f0100040 <_panic>
	assert((offset & 0x3) == 0);
f010625e:	f6 c3 03             	test   $0x3,%bl
f0106261:	74 16                	je     f0106279 <pci_conf1_set_addr+0x96>
f0106263:	68 fc 89 10 f0       	push   $0xf01089fc
f0106268:	68 85 6f 10 f0       	push   $0xf0106f85
f010626d:	6a 2f                	push   $0x2f
f010626f:	68 d2 89 10 f0       	push   $0xf01089d2
f0106274:	e8 c7 9d ff ff       	call   f0100040 <_panic>
}

static inline void
outl(int port, uint32_t data)
{
	asm volatile("outl %0,%w1" : : "a" (data), "d" (port));
f0106279:	c1 e1 08             	shl    $0x8,%ecx
f010627c:	81 cb 00 00 00 80    	or     $0x80000000,%ebx
f0106282:	09 cb                	or     %ecx,%ebx
f0106284:	c1 e2 0b             	shl    $0xb,%edx
f0106287:	09 d3                	or     %edx,%ebx
f0106289:	c1 e0 10             	shl    $0x10,%eax
f010628c:	09 d8                	or     %ebx,%eax
f010628e:	ba f8 0c 00 00       	mov    $0xcf8,%edx
f0106293:	ef                   	out    %eax,(%dx)

	uint32_t v = (1 << 31) |		// config-space
		(bus << 16) | (dev << 11) | (func << 8) | (offset);
	outl(pci_conf1_addr_ioport, v);
}
f0106294:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0106297:	c9                   	leave  
f0106298:	c3                   	ret    

f0106299 <pci_conf_read>:

static uint32_t
pci_conf_read(struct pci_func *f, uint32_t off)
{
f0106299:	55                   	push   %ebp
f010629a:	89 e5                	mov    %esp,%ebp
f010629c:	53                   	push   %ebx
f010629d:	83 ec 10             	sub    $0x10,%esp
	pci_conf1_set_addr(f->bus->busno, f->dev, f->func, off);
f01062a0:	8b 48 08             	mov    0x8(%eax),%ecx
f01062a3:	8b 58 04             	mov    0x4(%eax),%ebx
f01062a6:	8b 00                	mov    (%eax),%eax
f01062a8:	8b 40 04             	mov    0x4(%eax),%eax
f01062ab:	52                   	push   %edx
f01062ac:	89 da                	mov    %ebx,%edx
f01062ae:	e8 30 ff ff ff       	call   f01061e3 <pci_conf1_set_addr>

static inline uint32_t
inl(int port)
{
	uint32_t data;
	asm volatile("inl %w1,%0" : "=a" (data) : "d" (port));
f01062b3:	ba fc 0c 00 00       	mov    $0xcfc,%edx
f01062b8:	ed                   	in     (%dx),%eax
	return inl(pci_conf1_data_ioport);
}
f01062b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01062bc:	c9                   	leave  
f01062bd:	c3                   	ret    

f01062be <pci_scan_bus>:
		f->irq_line);
}

static int
pci_scan_bus(struct pci_bus *bus)
{
f01062be:	55                   	push   %ebp
f01062bf:	89 e5                	mov    %esp,%ebp
f01062c1:	57                   	push   %edi
f01062c2:	56                   	push   %esi
f01062c3:	53                   	push   %ebx
f01062c4:	81 ec 00 01 00 00    	sub    $0x100,%esp
f01062ca:	89 c3                	mov    %eax,%ebx
	int totaldev = 0;
	struct pci_func df;
	memset(&df, 0, sizeof(df));
f01062cc:	6a 48                	push   $0x48
f01062ce:	6a 00                	push   $0x0
f01062d0:	8d 45 a0             	lea    -0x60(%ebp),%eax
f01062d3:	50                   	push   %eax
f01062d4:	e8 92 f4 ff ff       	call   f010576b <memset>
	df.bus = bus;
f01062d9:	89 5d a0             	mov    %ebx,-0x60(%ebp)

	for (df.dev = 0; df.dev < 32; df.dev++) {
f01062dc:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f01062e3:	83 c4 10             	add    $0x10,%esp
}

static int
pci_scan_bus(struct pci_bus *bus)
{
	int totaldev = 0;
f01062e6:	c7 85 00 ff ff ff 00 	movl   $0x0,-0x100(%ebp)
f01062ed:	00 00 00 
	struct pci_func df;
	memset(&df, 0, sizeof(df));
	df.bus = bus;

	for (df.dev = 0; df.dev < 32; df.dev++) {
		uint32_t bhlc = pci_conf_read(&df, PCI_BHLC_REG);
f01062f0:	ba 0c 00 00 00       	mov    $0xc,%edx
f01062f5:	8d 45 a0             	lea    -0x60(%ebp),%eax
f01062f8:	e8 9c ff ff ff       	call   f0106299 <pci_conf_read>
		if (PCI_HDRTYPE_TYPE(bhlc) > 1)	    // Unsupported or no device
f01062fd:	89 c2                	mov    %eax,%edx
f01062ff:	c1 ea 10             	shr    $0x10,%edx
f0106302:	83 e2 7f             	and    $0x7f,%edx
f0106305:	83 fa 01             	cmp    $0x1,%edx
f0106308:	0f 87 4b 01 00 00    	ja     f0106459 <pci_scan_bus+0x19b>
			continue;

		totaldev++;
f010630e:	83 85 00 ff ff ff 01 	addl   $0x1,-0x100(%ebp)

		struct pci_func f = df;
f0106315:	8d bd 10 ff ff ff    	lea    -0xf0(%ebp),%edi
f010631b:	8d 75 a0             	lea    -0x60(%ebp),%esi
f010631e:	b9 12 00 00 00       	mov    $0x12,%ecx
f0106323:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f0106325:	c7 85 18 ff ff ff 00 	movl   $0x0,-0xe8(%ebp)
f010632c:	00 00 00 
f010632f:	25 00 00 80 00       	and    $0x800000,%eax
f0106334:	83 f8 01             	cmp    $0x1,%eax
f0106337:	19 c0                	sbb    %eax,%eax
f0106339:	83 e0 f9             	and    $0xfffffff9,%eax
f010633c:	83 c0 08             	add    $0x8,%eax
f010633f:	89 85 04 ff ff ff    	mov    %eax,-0xfc(%ebp)

			af.dev_id = pci_conf_read(&f, PCI_ID_REG);
			if (PCI_VENDOR(af.dev_id) == 0xffff)
				continue;

			uint32_t intr = pci_conf_read(&af, PCI_INTERRUPT_REG);
f0106345:	8d 9d 58 ff ff ff    	lea    -0xa8(%ebp),%ebx
			continue;

		totaldev++;

		struct pci_func f = df;
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f010634b:	e9 f7 00 00 00       	jmp    f0106447 <pci_scan_bus+0x189>
		     f.func++) {
			struct pci_func af = f;
f0106350:	8d bd 58 ff ff ff    	lea    -0xa8(%ebp),%edi
f0106356:	8d b5 10 ff ff ff    	lea    -0xf0(%ebp),%esi
f010635c:	b9 12 00 00 00       	mov    $0x12,%ecx
f0106361:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

			af.dev_id = pci_conf_read(&f, PCI_ID_REG);
f0106363:	ba 00 00 00 00       	mov    $0x0,%edx
f0106368:	8d 85 10 ff ff ff    	lea    -0xf0(%ebp),%eax
f010636e:	e8 26 ff ff ff       	call   f0106299 <pci_conf_read>
f0106373:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
			if (PCI_VENDOR(af.dev_id) == 0xffff)
f0106379:	66 83 f8 ff          	cmp    $0xffff,%ax
f010637d:	0f 84 bd 00 00 00    	je     f0106440 <pci_scan_bus+0x182>
				continue;

			uint32_t intr = pci_conf_read(&af, PCI_INTERRUPT_REG);
f0106383:	ba 3c 00 00 00       	mov    $0x3c,%edx
f0106388:	89 d8                	mov    %ebx,%eax
f010638a:	e8 0a ff ff ff       	call   f0106299 <pci_conf_read>
			af.irq_line = PCI_INTERRUPT_LINE(intr);
f010638f:	88 45 9c             	mov    %al,-0x64(%ebp)

			af.dev_class = pci_conf_read(&af, PCI_CLASS_REG);
f0106392:	ba 08 00 00 00       	mov    $0x8,%edx
f0106397:	89 d8                	mov    %ebx,%eax
f0106399:	e8 fb fe ff ff       	call   f0106299 <pci_conf_read>
f010639e:	89 85 68 ff ff ff    	mov    %eax,-0x98(%ebp)

static void
pci_print_func(struct pci_func *f)
{
	const char *class = pci_class[0];
	if (PCI_CLASS(f->dev_class) < ARRAY_SIZE(pci_class))
f01063a4:	89 c1                	mov    %eax,%ecx
f01063a6:	c1 e9 18             	shr    $0x18,%ecx
};

static void
pci_print_func(struct pci_func *f)
{
	const char *class = pci_class[0];
f01063a9:	be 10 8a 10 f0       	mov    $0xf0108a10,%esi
	if (PCI_CLASS(f->dev_class) < ARRAY_SIZE(pci_class))
f01063ae:	83 f9 06             	cmp    $0x6,%ecx
f01063b1:	77 07                	ja     f01063ba <pci_scan_bus+0xfc>
		class = pci_class[PCI_CLASS(f->dev_class)];
f01063b3:	8b 34 8d 84 8a 10 f0 	mov    -0xfef757c(,%ecx,4),%esi

	cprintf("PCI: %02x:%02x.%d: %04x:%04x: class: %x.%x (%s) irq: %d\n",
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
f01063ba:	8b 95 64 ff ff ff    	mov    -0x9c(%ebp),%edx
{
	const char *class = pci_class[0];
	if (PCI_CLASS(f->dev_class) < ARRAY_SIZE(pci_class))
		class = pci_class[PCI_CLASS(f->dev_class)];

	cprintf("PCI: %02x:%02x.%d: %04x:%04x: class: %x.%x (%s) irq: %d\n",
f01063c0:	83 ec 08             	sub    $0x8,%esp
f01063c3:	0f b6 7d 9c          	movzbl -0x64(%ebp),%edi
f01063c7:	57                   	push   %edi
f01063c8:	56                   	push   %esi
f01063c9:	c1 e8 10             	shr    $0x10,%eax
f01063cc:	0f b6 c0             	movzbl %al,%eax
f01063cf:	50                   	push   %eax
f01063d0:	51                   	push   %ecx
f01063d1:	89 d0                	mov    %edx,%eax
f01063d3:	c1 e8 10             	shr    $0x10,%eax
f01063d6:	50                   	push   %eax
f01063d7:	0f b7 d2             	movzwl %dx,%edx
f01063da:	52                   	push   %edx
f01063db:	ff b5 60 ff ff ff    	pushl  -0xa0(%ebp)
f01063e1:	ff b5 5c ff ff ff    	pushl  -0xa4(%ebp)
f01063e7:	8b 85 58 ff ff ff    	mov    -0xa8(%ebp),%eax
f01063ed:	ff 70 04             	pushl  0x4(%eax)
f01063f0:	68 9c 88 10 f0       	push   $0xf010889c
f01063f5:	e8 97 d5 ff ff       	call   f0103991 <cprintf>
static int
pci_attach(struct pci_func *f)
{
	return
		pci_attach_match(PCI_CLASS(f->dev_class),
				 PCI_SUBCLASS(f->dev_class),
f01063fa:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax

static int
pci_attach(struct pci_func *f)
{
	return
		pci_attach_match(PCI_CLASS(f->dev_class),
f0106400:	83 c4 30             	add    $0x30,%esp
f0106403:	53                   	push   %ebx
f0106404:	68 f4 23 12 f0       	push   $0xf01223f4
f0106409:	89 c2                	mov    %eax,%edx
f010640b:	c1 ea 10             	shr    $0x10,%edx
f010640e:	0f b6 d2             	movzbl %dl,%edx
f0106411:	52                   	push   %edx
f0106412:	c1 e8 18             	shr    $0x18,%eax
f0106415:	50                   	push   %eax
f0106416:	e8 6a fd ff ff       	call   f0106185 <pci_attach_match>
				 PCI_SUBCLASS(f->dev_class),
				 &pci_attach_class[0], f) ||
f010641b:	83 c4 10             	add    $0x10,%esp
f010641e:	85 c0                	test   %eax,%eax
f0106420:	75 1e                	jne    f0106440 <pci_scan_bus+0x182>
		pci_attach_match(PCI_VENDOR(f->dev_id),
				 PCI_PRODUCT(f->dev_id),
f0106422:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
{
	return
		pci_attach_match(PCI_CLASS(f->dev_class),
				 PCI_SUBCLASS(f->dev_class),
				 &pci_attach_class[0], f) ||
		pci_attach_match(PCI_VENDOR(f->dev_id),
f0106428:	53                   	push   %ebx
f0106429:	68 80 9e 2a f0       	push   $0xf02a9e80
f010642e:	89 c2                	mov    %eax,%edx
f0106430:	c1 ea 10             	shr    $0x10,%edx
f0106433:	52                   	push   %edx
f0106434:	0f b7 c0             	movzwl %ax,%eax
f0106437:	50                   	push   %eax
f0106438:	e8 48 fd ff ff       	call   f0106185 <pci_attach_match>
f010643d:	83 c4 10             	add    $0x10,%esp

		totaldev++;

		struct pci_func f = df;
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
		     f.func++) {
f0106440:	83 85 18 ff ff ff 01 	addl   $0x1,-0xe8(%ebp)
			continue;

		totaldev++;

		struct pci_func f = df;
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f0106447:	8b 85 04 ff ff ff    	mov    -0xfc(%ebp),%eax
f010644d:	3b 85 18 ff ff ff    	cmp    -0xe8(%ebp),%eax
f0106453:	0f 87 f7 fe ff ff    	ja     f0106350 <pci_scan_bus+0x92>
	int totaldev = 0;
	struct pci_func df;
	memset(&df, 0, sizeof(df));
	df.bus = bus;

	for (df.dev = 0; df.dev < 32; df.dev++) {
f0106459:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f010645c:	83 c0 01             	add    $0x1,%eax
f010645f:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f0106462:	83 f8 1f             	cmp    $0x1f,%eax
f0106465:	0f 86 85 fe ff ff    	jbe    f01062f0 <pci_scan_bus+0x32>
			pci_attach(&af);
		}
	}

	return totaldev;
}
f010646b:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
f0106471:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106474:	5b                   	pop    %ebx
f0106475:	5e                   	pop    %esi
f0106476:	5f                   	pop    %edi
f0106477:	5d                   	pop    %ebp
f0106478:	c3                   	ret    

f0106479 <pci_bridge_attach>:

static int
pci_bridge_attach(struct pci_func *pcif)
{
f0106479:	55                   	push   %ebp
f010647a:	89 e5                	mov    %esp,%ebp
f010647c:	57                   	push   %edi
f010647d:	56                   	push   %esi
f010647e:	53                   	push   %ebx
f010647f:	83 ec 1c             	sub    $0x1c,%esp
f0106482:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32_t ioreg  = pci_conf_read(pcif, PCI_BRIDGE_STATIO_REG);
f0106485:	ba 1c 00 00 00       	mov    $0x1c,%edx
f010648a:	89 d8                	mov    %ebx,%eax
f010648c:	e8 08 fe ff ff       	call   f0106299 <pci_conf_read>
f0106491:	89 c7                	mov    %eax,%edi
	uint32_t busreg = pci_conf_read(pcif, PCI_BRIDGE_BUS_REG);
f0106493:	ba 18 00 00 00       	mov    $0x18,%edx
f0106498:	89 d8                	mov    %ebx,%eax
f010649a:	e8 fa fd ff ff       	call   f0106299 <pci_conf_read>

	if (PCI_BRIDGE_IO_32BITS(ioreg)) {
f010649f:	83 e7 0f             	and    $0xf,%edi
f01064a2:	83 ff 01             	cmp    $0x1,%edi
f01064a5:	75 1f                	jne    f01064c6 <pci_bridge_attach+0x4d>
		cprintf("PCI: %02x:%02x.%d: 32-bit bridge IO not supported.\n",
f01064a7:	ff 73 08             	pushl  0x8(%ebx)
f01064aa:	ff 73 04             	pushl  0x4(%ebx)
f01064ad:	8b 03                	mov    (%ebx),%eax
f01064af:	ff 70 04             	pushl  0x4(%eax)
f01064b2:	68 d8 88 10 f0       	push   $0xf01088d8
f01064b7:	e8 d5 d4 ff ff       	call   f0103991 <cprintf>
			pcif->bus->busno, pcif->dev, pcif->func);
		return 0;
f01064bc:	83 c4 10             	add    $0x10,%esp
f01064bf:	b8 00 00 00 00       	mov    $0x0,%eax
f01064c4:	eb 4e                	jmp    f0106514 <pci_bridge_attach+0x9b>
f01064c6:	89 c6                	mov    %eax,%esi
	}

	struct pci_bus nbus;
	memset(&nbus, 0, sizeof(nbus));
f01064c8:	83 ec 04             	sub    $0x4,%esp
f01064cb:	6a 08                	push   $0x8
f01064cd:	6a 00                	push   $0x0
f01064cf:	8d 7d e0             	lea    -0x20(%ebp),%edi
f01064d2:	57                   	push   %edi
f01064d3:	e8 93 f2 ff ff       	call   f010576b <memset>
	nbus.parent_bridge = pcif;
f01064d8:	89 5d e0             	mov    %ebx,-0x20(%ebp)
	nbus.busno = (busreg >> PCI_BRIDGE_BUS_SECONDARY_SHIFT) & 0xff;
f01064db:	89 f0                	mov    %esi,%eax
f01064dd:	0f b6 c4             	movzbl %ah,%eax
f01064e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	if (pci_show_devs)
		cprintf("PCI: %02x:%02x.%d: bridge to PCI bus %d--%d\n",
f01064e3:	83 c4 08             	add    $0x8,%esp
f01064e6:	89 f2                	mov    %esi,%edx
f01064e8:	c1 ea 10             	shr    $0x10,%edx
f01064eb:	0f b6 f2             	movzbl %dl,%esi
f01064ee:	56                   	push   %esi
f01064ef:	50                   	push   %eax
f01064f0:	ff 73 08             	pushl  0x8(%ebx)
f01064f3:	ff 73 04             	pushl  0x4(%ebx)
f01064f6:	8b 03                	mov    (%ebx),%eax
f01064f8:	ff 70 04             	pushl  0x4(%eax)
f01064fb:	68 0c 89 10 f0       	push   $0xf010890c
f0106500:	e8 8c d4 ff ff       	call   f0103991 <cprintf>
			pcif->bus->busno, pcif->dev, pcif->func,
			nbus.busno,
			(busreg >> PCI_BRIDGE_BUS_SUBORDINATE_SHIFT) & 0xff);

	pci_scan_bus(&nbus);
f0106505:	83 c4 20             	add    $0x20,%esp
f0106508:	89 f8                	mov    %edi,%eax
f010650a:	e8 af fd ff ff       	call   f01062be <pci_scan_bus>
	return 1;
f010650f:	b8 01 00 00 00       	mov    $0x1,%eax
}
f0106514:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106517:	5b                   	pop    %ebx
f0106518:	5e                   	pop    %esi
f0106519:	5f                   	pop    %edi
f010651a:	5d                   	pop    %ebp
f010651b:	c3                   	ret    

f010651c <pci_conf_write>:
	return inl(pci_conf1_data_ioport);
}

static void
pci_conf_write(struct pci_func *f, uint32_t off, uint32_t v)
{
f010651c:	55                   	push   %ebp
f010651d:	89 e5                	mov    %esp,%ebp
f010651f:	56                   	push   %esi
f0106520:	53                   	push   %ebx
f0106521:	89 cb                	mov    %ecx,%ebx
	pci_conf1_set_addr(f->bus->busno, f->dev, f->func, off);
f0106523:	8b 48 08             	mov    0x8(%eax),%ecx
f0106526:	8b 70 04             	mov    0x4(%eax),%esi
f0106529:	8b 00                	mov    (%eax),%eax
f010652b:	8b 40 04             	mov    0x4(%eax),%eax
f010652e:	83 ec 0c             	sub    $0xc,%esp
f0106531:	52                   	push   %edx
f0106532:	89 f2                	mov    %esi,%edx
f0106534:	e8 aa fc ff ff       	call   f01061e3 <pci_conf1_set_addr>
}

static inline void
outl(int port, uint32_t data)
{
	asm volatile("outl %0,%w1" : : "a" (data), "d" (port));
f0106539:	ba fc 0c 00 00       	mov    $0xcfc,%edx
f010653e:	89 d8                	mov    %ebx,%eax
f0106540:	ef                   	out    %eax,(%dx)
	outl(pci_conf1_data_ioport, v);
}
f0106541:	83 c4 10             	add    $0x10,%esp
f0106544:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106547:	5b                   	pop    %ebx
f0106548:	5e                   	pop    %esi
f0106549:	5d                   	pop    %ebp
f010654a:	c3                   	ret    

f010654b <pci_func_enable>:

// External PCI subsystem interface

void
pci_func_enable(struct pci_func *f)
{
f010654b:	55                   	push   %ebp
f010654c:	89 e5                	mov    %esp,%ebp
f010654e:	57                   	push   %edi
f010654f:	56                   	push   %esi
f0106550:	53                   	push   %ebx
f0106551:	83 ec 1c             	sub    $0x1c,%esp
f0106554:	8b 7d 08             	mov    0x8(%ebp),%edi
	pci_conf_write(f, PCI_COMMAND_STATUS_REG,
f0106557:	b9 07 00 00 00       	mov    $0x7,%ecx
f010655c:	ba 04 00 00 00       	mov    $0x4,%edx
f0106561:	89 f8                	mov    %edi,%eax
f0106563:	e8 b4 ff ff ff       	call   f010651c <pci_conf_write>
		       PCI_COMMAND_MEM_ENABLE |
		       PCI_COMMAND_MASTER_ENABLE);

	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
f0106568:	be 10 00 00 00       	mov    $0x10,%esi
	     bar += bar_width)
	{
		uint32_t oldv = pci_conf_read(f, bar);
f010656d:	89 f2                	mov    %esi,%edx
f010656f:	89 f8                	mov    %edi,%eax
f0106571:	e8 23 fd ff ff       	call   f0106299 <pci_conf_read>
f0106576:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		bar_width = 4;
		pci_conf_write(f, bar, 0xffffffff);
f0106579:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
f010657e:	89 f2                	mov    %esi,%edx
f0106580:	89 f8                	mov    %edi,%eax
f0106582:	e8 95 ff ff ff       	call   f010651c <pci_conf_write>
		uint32_t rv = pci_conf_read(f, bar);
f0106587:	89 f2                	mov    %esi,%edx
f0106589:	89 f8                	mov    %edi,%eax
f010658b:	e8 09 fd ff ff       	call   f0106299 <pci_conf_read>
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
	     bar += bar_width)
	{
		uint32_t oldv = pci_conf_read(f, bar);

		bar_width = 4;
f0106590:	bb 04 00 00 00       	mov    $0x4,%ebx
		pci_conf_write(f, bar, 0xffffffff);
		uint32_t rv = pci_conf_read(f, bar);

		if (rv == 0)
f0106595:	85 c0                	test   %eax,%eax
f0106597:	0f 84 a6 00 00 00    	je     f0106643 <pci_func_enable+0xf8>
			continue;

		int regnum = PCI_MAPREG_NUM(bar);
f010659d:	8d 56 f0             	lea    -0x10(%esi),%edx
f01065a0:	c1 ea 02             	shr    $0x2,%edx
f01065a3:	89 55 e0             	mov    %edx,-0x20(%ebp)
		uint32_t base, size;
		if (PCI_MAPREG_TYPE(rv) == PCI_MAPREG_TYPE_MEM) {
f01065a6:	a8 01                	test   $0x1,%al
f01065a8:	75 2c                	jne    f01065d6 <pci_func_enable+0x8b>
			if (PCI_MAPREG_MEM_TYPE(rv) == PCI_MAPREG_MEM_TYPE_64BIT)
f01065aa:	89 c2                	mov    %eax,%edx
f01065ac:	83 e2 06             	and    $0x6,%edx
				bar_width = 8;
f01065af:	83 fa 04             	cmp    $0x4,%edx
f01065b2:	0f 94 c3             	sete   %bl
f01065b5:	0f b6 db             	movzbl %bl,%ebx
f01065b8:	8d 1c 9d 04 00 00 00 	lea    0x4(,%ebx,4),%ebx

			size = PCI_MAPREG_MEM_SIZE(rv);
f01065bf:	83 e0 f0             	and    $0xfffffff0,%eax
f01065c2:	89 c2                	mov    %eax,%edx
f01065c4:	f7 da                	neg    %edx
f01065c6:	21 c2                	and    %eax,%edx
f01065c8:	89 55 d8             	mov    %edx,-0x28(%ebp)
			base = PCI_MAPREG_MEM_ADDR(oldv);
f01065cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01065ce:	83 e0 f0             	and    $0xfffffff0,%eax
f01065d1:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01065d4:	eb 1a                	jmp    f01065f0 <pci_func_enable+0xa5>
			if (pci_show_addrs)
				cprintf("  mem region %d: %d bytes at 0x%x\n",
					regnum, size, base);
		} else {
			size = PCI_MAPREG_IO_SIZE(rv);
f01065d6:	83 e0 fc             	and    $0xfffffffc,%eax
f01065d9:	89 c2                	mov    %eax,%edx
f01065db:	f7 da                	neg    %edx
f01065dd:	21 c2                	and    %eax,%edx
f01065df:	89 55 d8             	mov    %edx,-0x28(%ebp)
			base = PCI_MAPREG_IO_ADDR(oldv);
f01065e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01065e5:	83 e0 fc             	and    $0xfffffffc,%eax
f01065e8:	89 45 dc             	mov    %eax,-0x24(%ebp)
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
	     bar += bar_width)
	{
		uint32_t oldv = pci_conf_read(f, bar);

		bar_width = 4;
f01065eb:	bb 04 00 00 00       	mov    $0x4,%ebx
			if (pci_show_addrs)
				cprintf("  io region %d: %d bytes at 0x%x\n",
					regnum, size, base);
		}

		pci_conf_write(f, bar, oldv);
f01065f0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01065f3:	89 f2                	mov    %esi,%edx
f01065f5:	89 f8                	mov    %edi,%eax
f01065f7:	e8 20 ff ff ff       	call   f010651c <pci_conf_write>
f01065fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01065ff:	8d 04 87             	lea    (%edi,%eax,4),%eax
		f->reg_base[regnum] = base;
f0106602:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0106605:	89 50 14             	mov    %edx,0x14(%eax)
		f->reg_size[regnum] = size;
f0106608:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f010660b:	89 48 2c             	mov    %ecx,0x2c(%eax)

		if (size && !base)
f010660e:	85 c9                	test   %ecx,%ecx
f0106610:	74 31                	je     f0106643 <pci_func_enable+0xf8>
f0106612:	85 d2                	test   %edx,%edx
f0106614:	75 2d                	jne    f0106643 <pci_func_enable+0xf8>
			cprintf("PCI device %02x:%02x.%d (%04x:%04x) "
				"may be misconfigured: "
				"region %d: base 0x%x, size %d\n",
				f->bus->busno, f->dev, f->func,
				PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
f0106616:	8b 47 0c             	mov    0xc(%edi),%eax
		pci_conf_write(f, bar, oldv);
		f->reg_base[regnum] = base;
		f->reg_size[regnum] = size;

		if (size && !base)
			cprintf("PCI device %02x:%02x.%d (%04x:%04x) "
f0106619:	83 ec 0c             	sub    $0xc,%esp
f010661c:	51                   	push   %ecx
f010661d:	52                   	push   %edx
f010661e:	ff 75 e0             	pushl  -0x20(%ebp)
f0106621:	89 c2                	mov    %eax,%edx
f0106623:	c1 ea 10             	shr    $0x10,%edx
f0106626:	52                   	push   %edx
f0106627:	0f b7 c0             	movzwl %ax,%eax
f010662a:	50                   	push   %eax
f010662b:	ff 77 08             	pushl  0x8(%edi)
f010662e:	ff 77 04             	pushl  0x4(%edi)
f0106631:	8b 07                	mov    (%edi),%eax
f0106633:	ff 70 04             	pushl  0x4(%eax)
f0106636:	68 3c 89 10 f0       	push   $0xf010893c
f010663b:	e8 51 d3 ff ff       	call   f0103991 <cprintf>
f0106640:	83 c4 30             	add    $0x30,%esp
		       PCI_COMMAND_MASTER_ENABLE);

	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
	     bar += bar_width)
f0106643:	01 de                	add    %ebx,%esi
		       PCI_COMMAND_MEM_ENABLE |
		       PCI_COMMAND_MASTER_ENABLE);

	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
f0106645:	83 fe 27             	cmp    $0x27,%esi
f0106648:	0f 86 1f ff ff ff    	jbe    f010656d <pci_func_enable+0x22>
				regnum, base, size);
	}

	cprintf("PCI function %02x:%02x.%d (%04x:%04x) enabled\n",
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id));
f010664e:	8b 47 0c             	mov    0xc(%edi),%eax
				f->bus->busno, f->dev, f->func,
				PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
				regnum, base, size);
	}

	cprintf("PCI function %02x:%02x.%d (%04x:%04x) enabled\n",
f0106651:	83 ec 08             	sub    $0x8,%esp
f0106654:	89 c2                	mov    %eax,%edx
f0106656:	c1 ea 10             	shr    $0x10,%edx
f0106659:	52                   	push   %edx
f010665a:	0f b7 c0             	movzwl %ax,%eax
f010665d:	50                   	push   %eax
f010665e:	ff 77 08             	pushl  0x8(%edi)
f0106661:	ff 77 04             	pushl  0x4(%edi)
f0106664:	8b 07                	mov    (%edi),%eax
f0106666:	ff 70 04             	pushl  0x4(%eax)
f0106669:	68 98 89 10 f0       	push   $0xf0108998
f010666e:	e8 1e d3 ff ff       	call   f0103991 <cprintf>
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id));
}
f0106673:	83 c4 20             	add    $0x20,%esp
f0106676:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106679:	5b                   	pop    %ebx
f010667a:	5e                   	pop    %esi
f010667b:	5f                   	pop    %edi
f010667c:	5d                   	pop    %ebp
f010667d:	c3                   	ret    

f010667e <pci_init>:

int
pci_init(void)
{
f010667e:	55                   	push   %ebp
f010667f:	89 e5                	mov    %esp,%ebp
f0106681:	83 ec 0c             	sub    $0xc,%esp
	static struct pci_bus root_bus;
	memset(&root_bus, 0, sizeof(root_bus));
f0106684:	6a 08                	push   $0x8
f0106686:	6a 00                	push   $0x0
f0106688:	68 8c 9e 2a f0       	push   $0xf02a9e8c
f010668d:	e8 d9 f0 ff ff       	call   f010576b <memset>

	return pci_scan_bus(&root_bus);
f0106692:	b8 8c 9e 2a f0       	mov    $0xf02a9e8c,%eax
f0106697:	e8 22 fc ff ff       	call   f01062be <pci_scan_bus>
}
f010669c:	c9                   	leave  
f010669d:	c3                   	ret    

f010669e <time_init>:

static unsigned int ticks;

void
time_init(void)
{
f010669e:	55                   	push   %ebp
f010669f:	89 e5                	mov    %esp,%ebp
	ticks = 0;
f01066a1:	c7 05 94 9e 2a f0 00 	movl   $0x0,0xf02a9e94
f01066a8:	00 00 00 
}
f01066ab:	5d                   	pop    %ebp
f01066ac:	c3                   	ret    

f01066ad <time_tick>:
// This should be called once per timer interrupt.  A timer interrupt
// fires every 10 ms.
void
time_tick(void)
{
	ticks++;
f01066ad:	a1 94 9e 2a f0       	mov    0xf02a9e94,%eax
f01066b2:	83 c0 01             	add    $0x1,%eax
f01066b5:	a3 94 9e 2a f0       	mov    %eax,0xf02a9e94
	if (ticks * 10 < ticks)
f01066ba:	8d 14 80             	lea    (%eax,%eax,4),%edx
f01066bd:	01 d2                	add    %edx,%edx
f01066bf:	39 d0                	cmp    %edx,%eax
f01066c1:	76 17                	jbe    f01066da <time_tick+0x2d>

// This should be called once per timer interrupt.  A timer interrupt
// fires every 10 ms.
void
time_tick(void)
{
f01066c3:	55                   	push   %ebp
f01066c4:	89 e5                	mov    %esp,%ebp
f01066c6:	83 ec 0c             	sub    $0xc,%esp
	ticks++;
	if (ticks * 10 < ticks)
		panic("time_tick: time overflowed");
f01066c9:	68 a0 8a 10 f0       	push   $0xf0108aa0
f01066ce:	6a 13                	push   $0x13
f01066d0:	68 bb 8a 10 f0       	push   $0xf0108abb
f01066d5:	e8 66 99 ff ff       	call   f0100040 <_panic>
f01066da:	f3 c3                	repz ret 

f01066dc <time_msec>:
}

unsigned int
time_msec(void)
{
f01066dc:	55                   	push   %ebp
f01066dd:	89 e5                	mov    %esp,%ebp
	return ticks * 10;
f01066df:	a1 94 9e 2a f0       	mov    0xf02a9e94,%eax
f01066e4:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01066e7:	01 c0                	add    %eax,%eax
}
f01066e9:	5d                   	pop    %ebp
f01066ea:	c3                   	ret    
f01066eb:	66 90                	xchg   %ax,%ax
f01066ed:	66 90                	xchg   %ax,%ax
f01066ef:	90                   	nop

f01066f0 <__udivdi3>:
f01066f0:	55                   	push   %ebp
f01066f1:	57                   	push   %edi
f01066f2:	56                   	push   %esi
f01066f3:	53                   	push   %ebx
f01066f4:	83 ec 1c             	sub    $0x1c,%esp
f01066f7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f01066fb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f01066ff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0106703:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106707:	85 f6                	test   %esi,%esi
f0106709:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010670d:	89 ca                	mov    %ecx,%edx
f010670f:	89 f8                	mov    %edi,%eax
f0106711:	75 3d                	jne    f0106750 <__udivdi3+0x60>
f0106713:	39 cf                	cmp    %ecx,%edi
f0106715:	0f 87 c5 00 00 00    	ja     f01067e0 <__udivdi3+0xf0>
f010671b:	85 ff                	test   %edi,%edi
f010671d:	89 fd                	mov    %edi,%ebp
f010671f:	75 0b                	jne    f010672c <__udivdi3+0x3c>
f0106721:	b8 01 00 00 00       	mov    $0x1,%eax
f0106726:	31 d2                	xor    %edx,%edx
f0106728:	f7 f7                	div    %edi
f010672a:	89 c5                	mov    %eax,%ebp
f010672c:	89 c8                	mov    %ecx,%eax
f010672e:	31 d2                	xor    %edx,%edx
f0106730:	f7 f5                	div    %ebp
f0106732:	89 c1                	mov    %eax,%ecx
f0106734:	89 d8                	mov    %ebx,%eax
f0106736:	89 cf                	mov    %ecx,%edi
f0106738:	f7 f5                	div    %ebp
f010673a:	89 c3                	mov    %eax,%ebx
f010673c:	89 d8                	mov    %ebx,%eax
f010673e:	89 fa                	mov    %edi,%edx
f0106740:	83 c4 1c             	add    $0x1c,%esp
f0106743:	5b                   	pop    %ebx
f0106744:	5e                   	pop    %esi
f0106745:	5f                   	pop    %edi
f0106746:	5d                   	pop    %ebp
f0106747:	c3                   	ret    
f0106748:	90                   	nop
f0106749:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106750:	39 ce                	cmp    %ecx,%esi
f0106752:	77 74                	ja     f01067c8 <__udivdi3+0xd8>
f0106754:	0f bd fe             	bsr    %esi,%edi
f0106757:	83 f7 1f             	xor    $0x1f,%edi
f010675a:	0f 84 98 00 00 00    	je     f01067f8 <__udivdi3+0x108>
f0106760:	bb 20 00 00 00       	mov    $0x20,%ebx
f0106765:	89 f9                	mov    %edi,%ecx
f0106767:	89 c5                	mov    %eax,%ebp
f0106769:	29 fb                	sub    %edi,%ebx
f010676b:	d3 e6                	shl    %cl,%esi
f010676d:	89 d9                	mov    %ebx,%ecx
f010676f:	d3 ed                	shr    %cl,%ebp
f0106771:	89 f9                	mov    %edi,%ecx
f0106773:	d3 e0                	shl    %cl,%eax
f0106775:	09 ee                	or     %ebp,%esi
f0106777:	89 d9                	mov    %ebx,%ecx
f0106779:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010677d:	89 d5                	mov    %edx,%ebp
f010677f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106783:	d3 ed                	shr    %cl,%ebp
f0106785:	89 f9                	mov    %edi,%ecx
f0106787:	d3 e2                	shl    %cl,%edx
f0106789:	89 d9                	mov    %ebx,%ecx
f010678b:	d3 e8                	shr    %cl,%eax
f010678d:	09 c2                	or     %eax,%edx
f010678f:	89 d0                	mov    %edx,%eax
f0106791:	89 ea                	mov    %ebp,%edx
f0106793:	f7 f6                	div    %esi
f0106795:	89 d5                	mov    %edx,%ebp
f0106797:	89 c3                	mov    %eax,%ebx
f0106799:	f7 64 24 0c          	mull   0xc(%esp)
f010679d:	39 d5                	cmp    %edx,%ebp
f010679f:	72 10                	jb     f01067b1 <__udivdi3+0xc1>
f01067a1:	8b 74 24 08          	mov    0x8(%esp),%esi
f01067a5:	89 f9                	mov    %edi,%ecx
f01067a7:	d3 e6                	shl    %cl,%esi
f01067a9:	39 c6                	cmp    %eax,%esi
f01067ab:	73 07                	jae    f01067b4 <__udivdi3+0xc4>
f01067ad:	39 d5                	cmp    %edx,%ebp
f01067af:	75 03                	jne    f01067b4 <__udivdi3+0xc4>
f01067b1:	83 eb 01             	sub    $0x1,%ebx
f01067b4:	31 ff                	xor    %edi,%edi
f01067b6:	89 d8                	mov    %ebx,%eax
f01067b8:	89 fa                	mov    %edi,%edx
f01067ba:	83 c4 1c             	add    $0x1c,%esp
f01067bd:	5b                   	pop    %ebx
f01067be:	5e                   	pop    %esi
f01067bf:	5f                   	pop    %edi
f01067c0:	5d                   	pop    %ebp
f01067c1:	c3                   	ret    
f01067c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01067c8:	31 ff                	xor    %edi,%edi
f01067ca:	31 db                	xor    %ebx,%ebx
f01067cc:	89 d8                	mov    %ebx,%eax
f01067ce:	89 fa                	mov    %edi,%edx
f01067d0:	83 c4 1c             	add    $0x1c,%esp
f01067d3:	5b                   	pop    %ebx
f01067d4:	5e                   	pop    %esi
f01067d5:	5f                   	pop    %edi
f01067d6:	5d                   	pop    %ebp
f01067d7:	c3                   	ret    
f01067d8:	90                   	nop
f01067d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01067e0:	89 d8                	mov    %ebx,%eax
f01067e2:	f7 f7                	div    %edi
f01067e4:	31 ff                	xor    %edi,%edi
f01067e6:	89 c3                	mov    %eax,%ebx
f01067e8:	89 d8                	mov    %ebx,%eax
f01067ea:	89 fa                	mov    %edi,%edx
f01067ec:	83 c4 1c             	add    $0x1c,%esp
f01067ef:	5b                   	pop    %ebx
f01067f0:	5e                   	pop    %esi
f01067f1:	5f                   	pop    %edi
f01067f2:	5d                   	pop    %ebp
f01067f3:	c3                   	ret    
f01067f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01067f8:	39 ce                	cmp    %ecx,%esi
f01067fa:	72 0c                	jb     f0106808 <__udivdi3+0x118>
f01067fc:	31 db                	xor    %ebx,%ebx
f01067fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0106802:	0f 87 34 ff ff ff    	ja     f010673c <__udivdi3+0x4c>
f0106808:	bb 01 00 00 00       	mov    $0x1,%ebx
f010680d:	e9 2a ff ff ff       	jmp    f010673c <__udivdi3+0x4c>
f0106812:	66 90                	xchg   %ax,%ax
f0106814:	66 90                	xchg   %ax,%ax
f0106816:	66 90                	xchg   %ax,%ax
f0106818:	66 90                	xchg   %ax,%ax
f010681a:	66 90                	xchg   %ax,%ax
f010681c:	66 90                	xchg   %ax,%ax
f010681e:	66 90                	xchg   %ax,%ax

f0106820 <__umoddi3>:
f0106820:	55                   	push   %ebp
f0106821:	57                   	push   %edi
f0106822:	56                   	push   %esi
f0106823:	53                   	push   %ebx
f0106824:	83 ec 1c             	sub    $0x1c,%esp
f0106827:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010682b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010682f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0106833:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106837:	85 d2                	test   %edx,%edx
f0106839:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010683d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106841:	89 f3                	mov    %esi,%ebx
f0106843:	89 3c 24             	mov    %edi,(%esp)
f0106846:	89 74 24 04          	mov    %esi,0x4(%esp)
f010684a:	75 1c                	jne    f0106868 <__umoddi3+0x48>
f010684c:	39 f7                	cmp    %esi,%edi
f010684e:	76 50                	jbe    f01068a0 <__umoddi3+0x80>
f0106850:	89 c8                	mov    %ecx,%eax
f0106852:	89 f2                	mov    %esi,%edx
f0106854:	f7 f7                	div    %edi
f0106856:	89 d0                	mov    %edx,%eax
f0106858:	31 d2                	xor    %edx,%edx
f010685a:	83 c4 1c             	add    $0x1c,%esp
f010685d:	5b                   	pop    %ebx
f010685e:	5e                   	pop    %esi
f010685f:	5f                   	pop    %edi
f0106860:	5d                   	pop    %ebp
f0106861:	c3                   	ret    
f0106862:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106868:	39 f2                	cmp    %esi,%edx
f010686a:	89 d0                	mov    %edx,%eax
f010686c:	77 52                	ja     f01068c0 <__umoddi3+0xa0>
f010686e:	0f bd ea             	bsr    %edx,%ebp
f0106871:	83 f5 1f             	xor    $0x1f,%ebp
f0106874:	75 5a                	jne    f01068d0 <__umoddi3+0xb0>
f0106876:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010687a:	0f 82 e0 00 00 00    	jb     f0106960 <__umoddi3+0x140>
f0106880:	39 0c 24             	cmp    %ecx,(%esp)
f0106883:	0f 86 d7 00 00 00    	jbe    f0106960 <__umoddi3+0x140>
f0106889:	8b 44 24 08          	mov    0x8(%esp),%eax
f010688d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106891:	83 c4 1c             	add    $0x1c,%esp
f0106894:	5b                   	pop    %ebx
f0106895:	5e                   	pop    %esi
f0106896:	5f                   	pop    %edi
f0106897:	5d                   	pop    %ebp
f0106898:	c3                   	ret    
f0106899:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01068a0:	85 ff                	test   %edi,%edi
f01068a2:	89 fd                	mov    %edi,%ebp
f01068a4:	75 0b                	jne    f01068b1 <__umoddi3+0x91>
f01068a6:	b8 01 00 00 00       	mov    $0x1,%eax
f01068ab:	31 d2                	xor    %edx,%edx
f01068ad:	f7 f7                	div    %edi
f01068af:	89 c5                	mov    %eax,%ebp
f01068b1:	89 f0                	mov    %esi,%eax
f01068b3:	31 d2                	xor    %edx,%edx
f01068b5:	f7 f5                	div    %ebp
f01068b7:	89 c8                	mov    %ecx,%eax
f01068b9:	f7 f5                	div    %ebp
f01068bb:	89 d0                	mov    %edx,%eax
f01068bd:	eb 99                	jmp    f0106858 <__umoddi3+0x38>
f01068bf:	90                   	nop
f01068c0:	89 c8                	mov    %ecx,%eax
f01068c2:	89 f2                	mov    %esi,%edx
f01068c4:	83 c4 1c             	add    $0x1c,%esp
f01068c7:	5b                   	pop    %ebx
f01068c8:	5e                   	pop    %esi
f01068c9:	5f                   	pop    %edi
f01068ca:	5d                   	pop    %ebp
f01068cb:	c3                   	ret    
f01068cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01068d0:	8b 34 24             	mov    (%esp),%esi
f01068d3:	bf 20 00 00 00       	mov    $0x20,%edi
f01068d8:	89 e9                	mov    %ebp,%ecx
f01068da:	29 ef                	sub    %ebp,%edi
f01068dc:	d3 e0                	shl    %cl,%eax
f01068de:	89 f9                	mov    %edi,%ecx
f01068e0:	89 f2                	mov    %esi,%edx
f01068e2:	d3 ea                	shr    %cl,%edx
f01068e4:	89 e9                	mov    %ebp,%ecx
f01068e6:	09 c2                	or     %eax,%edx
f01068e8:	89 d8                	mov    %ebx,%eax
f01068ea:	89 14 24             	mov    %edx,(%esp)
f01068ed:	89 f2                	mov    %esi,%edx
f01068ef:	d3 e2                	shl    %cl,%edx
f01068f1:	89 f9                	mov    %edi,%ecx
f01068f3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01068f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01068fb:	d3 e8                	shr    %cl,%eax
f01068fd:	89 e9                	mov    %ebp,%ecx
f01068ff:	89 c6                	mov    %eax,%esi
f0106901:	d3 e3                	shl    %cl,%ebx
f0106903:	89 f9                	mov    %edi,%ecx
f0106905:	89 d0                	mov    %edx,%eax
f0106907:	d3 e8                	shr    %cl,%eax
f0106909:	89 e9                	mov    %ebp,%ecx
f010690b:	09 d8                	or     %ebx,%eax
f010690d:	89 d3                	mov    %edx,%ebx
f010690f:	89 f2                	mov    %esi,%edx
f0106911:	f7 34 24             	divl   (%esp)
f0106914:	89 d6                	mov    %edx,%esi
f0106916:	d3 e3                	shl    %cl,%ebx
f0106918:	f7 64 24 04          	mull   0x4(%esp)
f010691c:	39 d6                	cmp    %edx,%esi
f010691e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106922:	89 d1                	mov    %edx,%ecx
f0106924:	89 c3                	mov    %eax,%ebx
f0106926:	72 08                	jb     f0106930 <__umoddi3+0x110>
f0106928:	75 11                	jne    f010693b <__umoddi3+0x11b>
f010692a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010692e:	73 0b                	jae    f010693b <__umoddi3+0x11b>
f0106930:	2b 44 24 04          	sub    0x4(%esp),%eax
f0106934:	1b 14 24             	sbb    (%esp),%edx
f0106937:	89 d1                	mov    %edx,%ecx
f0106939:	89 c3                	mov    %eax,%ebx
f010693b:	8b 54 24 08          	mov    0x8(%esp),%edx
f010693f:	29 da                	sub    %ebx,%edx
f0106941:	19 ce                	sbb    %ecx,%esi
f0106943:	89 f9                	mov    %edi,%ecx
f0106945:	89 f0                	mov    %esi,%eax
f0106947:	d3 e0                	shl    %cl,%eax
f0106949:	89 e9                	mov    %ebp,%ecx
f010694b:	d3 ea                	shr    %cl,%edx
f010694d:	89 e9                	mov    %ebp,%ecx
f010694f:	d3 ee                	shr    %cl,%esi
f0106951:	09 d0                	or     %edx,%eax
f0106953:	89 f2                	mov    %esi,%edx
f0106955:	83 c4 1c             	add    $0x1c,%esp
f0106958:	5b                   	pop    %ebx
f0106959:	5e                   	pop    %esi
f010695a:	5f                   	pop    %edi
f010695b:	5d                   	pop    %ebp
f010695c:	c3                   	ret    
f010695d:	8d 76 00             	lea    0x0(%esi),%esi
f0106960:	29 f9                	sub    %edi,%ecx
f0106962:	19 d6                	sbb    %edx,%esi
f0106964:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106968:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010696c:	e9 18 ff ff ff       	jmp    f0106889 <__umoddi3+0x69>
