
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
f0100015:	b8 00 20 12 00       	mov    $0x122000,%eax
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
f0100034:	bc 00 20 12 f0       	mov    $0xf0122000,%esp

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
f0100048:	83 3d 90 ce 2a f0 00 	cmpl   $0x0,0xf02ace90
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 90 ce 2a f0    	mov    %esi,0xf02ace90

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 b1 5d 00 00       	call   f0105e12 <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 20 6e 10 f0       	push   $0xf0106e20
f010006d:	e8 1f 39 00 00       	call   f0103991 <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 ef 38 00 00       	call   f010396b <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 39 77 10 f0 	movl   $0xf0107739,(%esp)
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
f01000ae:	68 8c 6e 10 f0       	push   $0xf0106e8c
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
f01000c7:	e8 3c 5a 00 00       	call   f0105b08 <mp_init>
	lapic_init();
f01000cc:	e8 5c 5d 00 00       	call   f0105e2d <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000d1:	e8 cc 37 00 00       	call   f01038a2 <pic_init>

	// Lab 6 hardware initialization functions
	time_init();
f01000d6:	e8 4a 6a 00 00       	call   f0106b25 <time_init>
	pci_init();
f01000db:	e8 25 6a 00 00       	call   f0106b05 <pci_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000e0:	c7 04 24 c0 43 12 f0 	movl   $0xf01243c0,(%esp)
f01000e7:	e8 94 5f 00 00       	call   f0106080 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000ec:	83 c4 10             	add    $0x10,%esp
f01000ef:	83 3d 98 ce 2a f0 07 	cmpl   $0x7,0xf02ace98
f01000f6:	77 16                	ja     f010010e <i386_init+0x74>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01000f8:	68 00 70 00 00       	push   $0x7000
f01000fd:	68 44 6e 10 f0       	push   $0xf0106e44
f0100102:	6a 66                	push   $0x66
f0100104:	68 a7 6e 10 f0       	push   $0xf0106ea7
f0100109:	e8 32 ff ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f010010e:	83 ec 04             	sub    $0x4,%esp
f0100111:	b8 6e 5a 10 f0       	mov    $0xf0105a6e,%eax
f0100116:	2d f4 59 10 f0       	sub    $0xf01059f4,%eax
f010011b:	50                   	push   %eax
f010011c:	68 f4 59 10 f0       	push   $0xf01059f4
f0100121:	68 00 70 00 f0       	push   $0xf0007000
f0100126:	e8 11 57 00 00       	call   f010583c <memmove>
f010012b:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010012e:	bb 20 d0 2a f0       	mov    $0xf02ad020,%ebx
f0100133:	eb 4d                	jmp    f0100182 <i386_init+0xe8>
		if (c == cpus + cpunum())  // We've started already.
f0100135:	e8 d8 5c 00 00       	call   f0105e12 <cpunum>
f010013a:	6b c0 74             	imul   $0x74,%eax,%eax
f010013d:	05 20 d0 2a f0       	add    $0xf02ad020,%eax
f0100142:	39 c3                	cmp    %eax,%ebx
f0100144:	74 39                	je     f010017f <i386_init+0xe5>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100146:	89 d8                	mov    %ebx,%eax
f0100148:	2d 20 d0 2a f0       	sub    $0xf02ad020,%eax
f010014d:	c1 f8 02             	sar    $0x2,%eax
f0100150:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100156:	c1 e0 0f             	shl    $0xf,%eax
f0100159:	05 00 60 2b f0       	add    $0xf02b6000,%eax
f010015e:	a3 94 ce 2a f0       	mov    %eax,0xf02ace94
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100163:	83 ec 08             	sub    $0x8,%esp
f0100166:	68 00 70 00 00       	push   $0x7000
f010016b:	0f b6 03             	movzbl (%ebx),%eax
f010016e:	50                   	push   %eax
f010016f:	e8 07 5e 00 00       	call   f0105f7b <lapic_startap>
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
f0100182:	6b 05 c4 d3 2a f0 74 	imul   $0x74,0xf02ad3c4,%eax
f0100189:	05 20 d0 2a f0       	add    $0xf02ad020,%eax
f010018e:	39 c3                	cmp    %eax,%ebx
f0100190:	72 a3                	jb     f0100135 <i386_init+0x9b>

	// Starting non-boot CPUs
	boot_aps();

	// Start fs.
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f0100192:	83 ec 08             	sub    $0x8,%esp
f0100195:	6a 01                	push   $0x1
f0100197:	68 00 cb 1d f0       	push   $0xf01dcb00
f010019c:	e8 e4 31 00 00       	call   f0103385 <env_create>

#if !defined(TEST_NO_NS)
	// Start ns.
	ENV_CREATE(net_ns, ENV_TYPE_NS);
f01001a1:	83 c4 08             	add    $0x8,%esp
f01001a4:	6a 02                	push   $0x2
f01001a6:	68 f8 42 23 f0       	push   $0xf02342f8
f01001ab:	e8 d5 31 00 00       	call   f0103385 <env_create>
#endif

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01001b0:	83 c4 08             	add    $0x8,%esp
f01001b3:	6a 00                	push   $0x0
f01001b5:	68 d8 d3 1f f0       	push   $0xf01fd3d8
f01001ba:	e8 c6 31 00 00       	call   f0103385 <env_create>
	ENV_CREATE(user_icode, ENV_TYPE_USER);
	// ENV_CREATE(user_primes, ENV_TYPE_USER);
#endif // TEST*

	// Should not be necessary - drains keyboard because interrupt has given up.
	kbd_intr();
f01001bf:	e8 35 04 00 00       	call   f01005f9 <kbd_intr>

	// Schedule and run the first user environment!
	sched_yield();
f01001c4:	e8 17 44 00 00       	call   f01045e0 <sched_yield>

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
f01001cf:	a1 9c ce 2a f0       	mov    0xf02ace9c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001d4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001d9:	77 12                	ja     f01001ed <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001db:	50                   	push   %eax
f01001dc:	68 68 6e 10 f0       	push   $0xf0106e68
f01001e1:	6a 7d                	push   $0x7d
f01001e3:	68 a7 6e 10 f0       	push   $0xf0106ea7
f01001e8:	e8 53 fe ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01001ed:	05 00 00 00 10       	add    $0x10000000,%eax
f01001f2:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001f5:	e8 18 5c 00 00       	call   f0105e12 <cpunum>
f01001fa:	83 ec 08             	sub    $0x8,%esp
f01001fd:	50                   	push   %eax
f01001fe:	68 b3 6e 10 f0       	push   $0xf0106eb3
f0100203:	e8 89 37 00 00       	call   f0103991 <cprintf>

	lapic_init();
f0100208:	e8 20 5c 00 00       	call   f0105e2d <lapic_init>
	env_init_percpu();
f010020d:	e8 b0 2f 00 00       	call   f01031c2 <env_init_percpu>
	trap_init_percpu();
f0100212:	e8 8e 37 00 00       	call   f01039a5 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100217:	e8 f6 5b 00 00       	call   f0105e12 <cpunum>
f010021c:	6b d0 74             	imul   $0x74,%eax,%edx
f010021f:	81 c2 20 d0 2a f0    	add    $0xf02ad020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0100225:	b8 01 00 00 00       	mov    $0x1,%eax
f010022a:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010022e:	c7 04 24 c0 43 12 f0 	movl   $0xf01243c0,(%esp)
f0100235:	e8 46 5e 00 00       	call   f0106080 <spin_lock>
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:

	lock_kernel();
	sched_yield();
f010023a:	e8 a1 43 00 00       	call   f01045e0 <sched_yield>

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
f010024f:	68 c9 6e 10 f0       	push   $0xf0106ec9
f0100254:	e8 38 37 00 00       	call   f0103991 <cprintf>
	vcprintf(fmt, ap);
f0100259:	83 c4 08             	add    $0x8,%esp
f010025c:	53                   	push   %ebx
f010025d:	ff 75 10             	pushl  0x10(%ebp)
f0100260:	e8 06 37 00 00       	call   f010396b <vcprintf>
	cprintf("\n");
f0100265:	c7 04 24 39 77 10 f0 	movl   $0xf0107739,(%esp)
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
f01002a7:	8b 0d 24 c2 2a f0    	mov    0xf02ac224,%ecx
f01002ad:	8d 51 01             	lea    0x1(%ecx),%edx
f01002b0:	89 15 24 c2 2a f0    	mov    %edx,0xf02ac224
f01002b6:	88 81 20 c0 2a f0    	mov    %al,-0xfd53fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002bc:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01002c2:	75 0a                	jne    f01002ce <cons_intr+0x36>
			cons.wpos = 0;
f01002c4:	c7 05 24 c2 2a f0 00 	movl   $0x0,0xf02ac224
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
f01002fd:	83 0d 00 c0 2a f0 40 	orl    $0x40,0xf02ac000
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
f0100315:	8b 0d 00 c0 2a f0    	mov    0xf02ac000,%ecx
f010031b:	89 cb                	mov    %ecx,%ebx
f010031d:	83 e3 40             	and    $0x40,%ebx
f0100320:	83 e0 7f             	and    $0x7f,%eax
f0100323:	85 db                	test   %ebx,%ebx
f0100325:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100328:	0f b6 d2             	movzbl %dl,%edx
f010032b:	0f b6 82 40 70 10 f0 	movzbl -0xfef8fc0(%edx),%eax
f0100332:	83 c8 40             	or     $0x40,%eax
f0100335:	0f b6 c0             	movzbl %al,%eax
f0100338:	f7 d0                	not    %eax
f010033a:	21 c8                	and    %ecx,%eax
f010033c:	a3 00 c0 2a f0       	mov    %eax,0xf02ac000
		return 0;
f0100341:	b8 00 00 00 00       	mov    $0x0,%eax
f0100346:	e9 a4 00 00 00       	jmp    f01003ef <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f010034b:	8b 0d 00 c0 2a f0    	mov    0xf02ac000,%ecx
f0100351:	f6 c1 40             	test   $0x40,%cl
f0100354:	74 0e                	je     f0100364 <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100356:	83 c8 80             	or     $0xffffff80,%eax
f0100359:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010035b:	83 e1 bf             	and    $0xffffffbf,%ecx
f010035e:	89 0d 00 c0 2a f0    	mov    %ecx,0xf02ac000
	}

	shift |= shiftcode[data];
f0100364:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100367:	0f b6 82 40 70 10 f0 	movzbl -0xfef8fc0(%edx),%eax
f010036e:	0b 05 00 c0 2a f0    	or     0xf02ac000,%eax
f0100374:	0f b6 8a 40 6f 10 f0 	movzbl -0xfef90c0(%edx),%ecx
f010037b:	31 c8                	xor    %ecx,%eax
f010037d:	a3 00 c0 2a f0       	mov    %eax,0xf02ac000

	c = charcode[shift & (CTL | SHIFT)][data];
f0100382:	89 c1                	mov    %eax,%ecx
f0100384:	83 e1 03             	and    $0x3,%ecx
f0100387:	8b 0c 8d 20 6f 10 f0 	mov    -0xfef90e0(,%ecx,4),%ecx
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
f01003c5:	68 e3 6e 10 f0       	push   $0xf0106ee3
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
f01004b1:	0f b7 05 28 c2 2a f0 	movzwl 0xf02ac228,%eax
f01004b8:	66 85 c0             	test   %ax,%ax
f01004bb:	0f 84 e6 00 00 00    	je     f01005a7 <cons_putc+0x1b3>
			crt_pos--;
f01004c1:	83 e8 01             	sub    $0x1,%eax
f01004c4:	66 a3 28 c2 2a f0    	mov    %ax,0xf02ac228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004ca:	0f b7 c0             	movzwl %ax,%eax
f01004cd:	66 81 e7 00 ff       	and    $0xff00,%di
f01004d2:	83 cf 20             	or     $0x20,%edi
f01004d5:	8b 15 2c c2 2a f0    	mov    0xf02ac22c,%edx
f01004db:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004df:	eb 78                	jmp    f0100559 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004e1:	66 83 05 28 c2 2a f0 	addw   $0x50,0xf02ac228
f01004e8:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004e9:	0f b7 05 28 c2 2a f0 	movzwl 0xf02ac228,%eax
f01004f0:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004f6:	c1 e8 16             	shr    $0x16,%eax
f01004f9:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004fc:	c1 e0 04             	shl    $0x4,%eax
f01004ff:	66 a3 28 c2 2a f0    	mov    %ax,0xf02ac228
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
f010053b:	0f b7 05 28 c2 2a f0 	movzwl 0xf02ac228,%eax
f0100542:	8d 50 01             	lea    0x1(%eax),%edx
f0100545:	66 89 15 28 c2 2a f0 	mov    %dx,0xf02ac228
f010054c:	0f b7 c0             	movzwl %ax,%eax
f010054f:	8b 15 2c c2 2a f0    	mov    0xf02ac22c,%edx
f0100555:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100559:	66 81 3d 28 c2 2a f0 	cmpw   $0x7cf,0xf02ac228
f0100560:	cf 07 
f0100562:	76 43                	jbe    f01005a7 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100564:	a1 2c c2 2a f0       	mov    0xf02ac22c,%eax
f0100569:	83 ec 04             	sub    $0x4,%esp
f010056c:	68 00 0f 00 00       	push   $0xf00
f0100571:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100577:	52                   	push   %edx
f0100578:	50                   	push   %eax
f0100579:	e8 be 52 00 00       	call   f010583c <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010057e:	8b 15 2c c2 2a f0    	mov    0xf02ac22c,%edx
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
f010059f:	66 83 2d 28 c2 2a f0 	subw   $0x50,0xf02ac228
f01005a6:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01005a7:	8b 0d 30 c2 2a f0    	mov    0xf02ac230,%ecx
f01005ad:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005b2:	89 ca                	mov    %ecx,%edx
f01005b4:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01005b5:	0f b7 1d 28 c2 2a f0 	movzwl 0xf02ac228,%ebx
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
f01005dd:	80 3d 34 c2 2a f0 00 	cmpb   $0x0,0xf02ac234
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
f010061b:	a1 20 c2 2a f0       	mov    0xf02ac220,%eax
f0100620:	3b 05 24 c2 2a f0    	cmp    0xf02ac224,%eax
f0100626:	74 26                	je     f010064e <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100628:	8d 50 01             	lea    0x1(%eax),%edx
f010062b:	89 15 20 c2 2a f0    	mov    %edx,0xf02ac220
f0100631:	0f b6 88 20 c0 2a f0 	movzbl -0xfd53fe0(%eax),%ecx
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
f0100642:	c7 05 20 c2 2a f0 00 	movl   $0x0,0xf02ac220
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
f010067b:	c7 05 30 c2 2a f0 b4 	movl   $0x3b4,0xf02ac230
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
f0100693:	c7 05 30 c2 2a f0 d4 	movl   $0x3d4,0xf02ac230
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
f01006a2:	8b 3d 30 c2 2a f0    	mov    0xf02ac230,%edi
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
f01006c7:	89 35 2c c2 2a f0    	mov    %esi,0xf02ac22c
	crt_pos = pos;
f01006cd:	0f b6 c0             	movzbl %al,%eax
f01006d0:	09 c8                	or     %ecx,%eax
f01006d2:	66 a3 28 c2 2a f0    	mov    %ax,0xf02ac228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006d8:	e8 1c ff ff ff       	call   f01005f9 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006dd:	83 ec 0c             	sub    $0xc,%esp
f01006e0:	0f b7 05 a8 43 12 f0 	movzwl 0xf01243a8,%eax
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
f0100750:	0f 95 05 34 c2 2a f0 	setne  0xf02ac234
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
f0100765:	0f b7 05 a8 43 12 f0 	movzwl 0xf01243a8,%eax
f010076c:	25 ef ff 00 00       	and    $0xffef,%eax
f0100771:	50                   	push   %eax
f0100772:	e8 b3 30 00 00       	call   f010382a <irq_setmask_8259A>
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100777:	83 c4 10             	add    $0x10,%esp
f010077a:	80 3d 34 c2 2a f0 00 	cmpb   $0x0,0xf02ac234
f0100781:	75 10                	jne    f0100793 <cons_init+0x13e>
		cprintf("Serial port does not exist!\n");
f0100783:	83 ec 0c             	sub    $0xc,%esp
f0100786:	68 ef 6e 10 f0       	push   $0xf0106eef
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
f01007cc:	68 40 71 10 f0       	push   $0xf0107140
f01007d1:	68 5e 71 10 f0       	push   $0xf010715e
f01007d6:	68 63 71 10 f0       	push   $0xf0107163
f01007db:	e8 b1 31 00 00       	call   f0103991 <cprintf>
f01007e0:	83 c4 0c             	add    $0xc,%esp
f01007e3:	68 1c 72 10 f0       	push   $0xf010721c
f01007e8:	68 6c 71 10 f0       	push   $0xf010716c
f01007ed:	68 63 71 10 f0       	push   $0xf0107163
f01007f2:	e8 9a 31 00 00       	call   f0103991 <cprintf>
f01007f7:	83 c4 0c             	add    $0xc,%esp
f01007fa:	68 75 71 10 f0       	push   $0xf0107175
f01007ff:	68 93 71 10 f0       	push   $0xf0107193
f0100804:	68 63 71 10 f0       	push   $0xf0107163
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
f010081b:	68 9d 71 10 f0       	push   $0xf010719d
f0100820:	e8 6c 31 00 00       	call   f0103991 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100825:	83 c4 08             	add    $0x8,%esp
f0100828:	68 0c 00 10 00       	push   $0x10000c
f010082d:	68 44 72 10 f0       	push   $0xf0107244
f0100832:	e8 5a 31 00 00       	call   f0103991 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100837:	83 c4 0c             	add    $0xc,%esp
f010083a:	68 0c 00 10 00       	push   $0x10000c
f010083f:	68 0c 00 10 f0       	push   $0xf010000c
f0100844:	68 6c 72 10 f0       	push   $0xf010726c
f0100849:	e8 43 31 00 00       	call   f0103991 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010084e:	83 c4 0c             	add    $0xc,%esp
f0100851:	68 01 6e 10 00       	push   $0x106e01
f0100856:	68 01 6e 10 f0       	push   $0xf0106e01
f010085b:	68 90 72 10 f0       	push   $0xf0107290
f0100860:	e8 2c 31 00 00       	call   f0103991 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100865:	83 c4 0c             	add    $0xc,%esp
f0100868:	68 00 c0 2a 00       	push   $0x2ac000
f010086d:	68 00 c0 2a f0       	push   $0xf02ac000
f0100872:	68 b4 72 10 f0       	push   $0xf01072b4
f0100877:	e8 15 31 00 00       	call   f0103991 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010087c:	83 c4 0c             	add    $0xc,%esp
f010087f:	68 80 a0 32 00       	push   $0x32a080
f0100884:	68 80 a0 32 f0       	push   $0xf032a080
f0100889:	68 d8 72 10 f0       	push   $0xf01072d8
f010088e:	e8 fe 30 00 00       	call   f0103991 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100893:	b8 7f a4 32 f0       	mov    $0xf032a47f,%eax
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
f01008b4:	68 fc 72 10 f0       	push   $0xf01072fc
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
f01008f3:	68 b6 71 10 f0       	push   $0xf01071b6
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
f0100925:	e8 33 44 00 00       	call   f0104d5d <debuginfo_eip>

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
f0100981:	68 28 73 10 f0       	push   $0xf0107328
f0100986:	e8 06 30 00 00       	call   f0103991 <cprintf>
		cprintf("         %s:%d: %s+%d\n", context.eip_file, context.eip_line, function_name, _eip - context.eip_fn_addr);
f010098b:	83 c4 14             	add    $0x14,%esp
f010098e:	2b 75 cc             	sub    -0x34(%ebp),%esi
f0100991:	56                   	push   %esi
f0100992:	8d 45 8a             	lea    -0x76(%ebp),%eax
f0100995:	50                   	push   %eax
f0100996:	ff 75 c0             	pushl  -0x40(%ebp)
f0100999:	ff 75 bc             	pushl  -0x44(%ebp)
f010099c:	68 c8 71 10 f0       	push   $0xf01071c8
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
f01009c9:	68 60 73 10 f0       	push   $0xf0107360
f01009ce:	e8 be 2f 00 00       	call   f0103991 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01009d3:	c7 04 24 84 73 10 f0 	movl   $0xf0107384,(%esp)
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
f01009f9:	68 df 71 10 f0       	push   $0xf01071df
f01009fe:	e8 7d 4b 00 00       	call   f0105580 <readline>
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
f0100a32:	68 e3 71 10 f0       	push   $0xf01071e3
f0100a37:	e8 76 4d 00 00       	call   f01057b2 <strchr>
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
f0100a52:	68 e8 71 10 f0       	push   $0xf01071e8
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
f0100a7b:	68 e3 71 10 f0       	push   $0xf01071e3
f0100a80:	e8 2d 4d 00 00       	call   f01057b2 <strchr>
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
f0100aa9:	ff 34 85 c0 73 10 f0 	pushl  -0xfef8c40(,%eax,4)
f0100ab0:	ff 75 a8             	pushl  -0x58(%ebp)
f0100ab3:	e8 9c 4c 00 00       	call   f0105754 <strcmp>
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
f0100acd:	ff 14 85 c8 73 10 f0 	call   *-0xfef8c38(,%eax,4)
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
f0100aee:	68 05 72 10 f0       	push   $0xf0107205
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
f0100b31:	83 3d 38 c2 2a f0 00 	cmpl   $0x0,0xf02ac238
f0100b38:	75 11                	jne    f0100b4b <boot_alloc+0x1a>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100b3a:	ba 7f b0 32 f0       	mov    $0xf032b07f,%edx
f0100b3f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b45:	89 15 38 c2 2a f0    	mov    %edx,0xf02ac238
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

	if ((uint32_t)nextfree > 0xffffffff - n)
f0100b4b:	8b 15 38 c2 2a f0    	mov    0xf02ac238,%edx
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
f0100b5f:	68 e4 73 10 f0       	push   $0xf01073e4
f0100b64:	6a 70                	push   $0x70
f0100b66:	68 ff 73 10 f0       	push   $0xf01073ff
f0100b6b:	e8 d0 f4 ff ff       	call   f0100040 <_panic>

	result = nextfree;
	nextfree = ROUNDUP(result + n , PGSIZE);
f0100b70:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100b77:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b7c:	a3 38 c2 2a f0       	mov    %eax,0xf02ac238

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
f0100b9a:	3b 0d 98 ce 2a f0    	cmp    0xf02ace98,%ecx
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
f0100ba9:	68 44 6e 10 f0       	push   $0xf0106e44
f0100bae:	68 40 04 00 00       	push   $0x440
f0100bb3:	68 ff 73 10 f0       	push   $0xf01073ff
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
f0100c01:	68 6c 77 10 f0       	push   $0xf010776c
f0100c06:	68 71 03 00 00       	push   $0x371
f0100c0b:	68 ff 73 10 f0       	push   $0xf01073ff
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
f0100c23:	2b 15 a0 ce 2a f0    	sub    0xf02acea0,%edx
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
f0100c59:	a3 40 c2 2a f0       	mov    %eax,0xf02ac240
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
f0100c63:	8b 1d 40 c2 2a f0    	mov    0xf02ac240,%ebx
f0100c69:	eb 53                	jmp    f0100cbe <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c6b:	89 d8                	mov    %ebx,%eax
f0100c6d:	2b 05 a0 ce 2a f0    	sub    0xf02acea0,%eax
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
f0100c87:	3b 15 98 ce 2a f0    	cmp    0xf02ace98,%edx
f0100c8d:	72 12                	jb     f0100ca1 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c8f:	50                   	push   %eax
f0100c90:	68 44 6e 10 f0       	push   $0xf0106e44
f0100c95:	6a 58                	push   $0x58
f0100c97:	68 0b 74 10 f0       	push   $0xf010740b
f0100c9c:	e8 9f f3 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100ca1:	83 ec 04             	sub    $0x4,%esp
f0100ca4:	68 80 00 00 00       	push   $0x80
f0100ca9:	68 97 00 00 00       	push   $0x97
f0100cae:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100cb3:	50                   	push   %eax
f0100cb4:	e8 36 4b 00 00       	call   f01057ef <memset>
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
f0100ccf:	8b 15 40 c2 2a f0    	mov    0xf02ac240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100cd5:	8b 0d a0 ce 2a f0    	mov    0xf02acea0,%ecx
		assert(pp < pages + npages);
f0100cdb:	a1 98 ce 2a f0       	mov    0xf02ace98,%eax
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
f0100cfa:	68 19 74 10 f0       	push   $0xf0107419
f0100cff:	68 25 74 10 f0       	push   $0xf0107425
f0100d04:	68 8b 03 00 00       	push   $0x38b
f0100d09:	68 ff 73 10 f0       	push   $0xf01073ff
f0100d0e:	e8 2d f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100d13:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100d16:	72 19                	jb     f0100d31 <check_page_free_list+0x149>
f0100d18:	68 3a 74 10 f0       	push   $0xf010743a
f0100d1d:	68 25 74 10 f0       	push   $0xf0107425
f0100d22:	68 8c 03 00 00       	push   $0x38c
f0100d27:	68 ff 73 10 f0       	push   $0xf01073ff
f0100d2c:	e8 0f f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d31:	89 d0                	mov    %edx,%eax
f0100d33:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100d36:	a8 07                	test   $0x7,%al
f0100d38:	74 19                	je     f0100d53 <check_page_free_list+0x16b>
f0100d3a:	68 90 77 10 f0       	push   $0xf0107790
f0100d3f:	68 25 74 10 f0       	push   $0xf0107425
f0100d44:	68 8d 03 00 00       	push   $0x38d
f0100d49:	68 ff 73 10 f0       	push   $0xf01073ff
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
f0100d5d:	68 4e 74 10 f0       	push   $0xf010744e
f0100d62:	68 25 74 10 f0       	push   $0xf0107425
f0100d67:	68 90 03 00 00       	push   $0x390
f0100d6c:	68 ff 73 10 f0       	push   $0xf01073ff
f0100d71:	e8 ca f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d76:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d7b:	75 19                	jne    f0100d96 <check_page_free_list+0x1ae>
f0100d7d:	68 5f 74 10 f0       	push   $0xf010745f
f0100d82:	68 25 74 10 f0       	push   $0xf0107425
f0100d87:	68 91 03 00 00       	push   $0x391
f0100d8c:	68 ff 73 10 f0       	push   $0xf01073ff
f0100d91:	e8 aa f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d96:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d9b:	75 19                	jne    f0100db6 <check_page_free_list+0x1ce>
f0100d9d:	68 c4 77 10 f0       	push   $0xf01077c4
f0100da2:	68 25 74 10 f0       	push   $0xf0107425
f0100da7:	68 92 03 00 00       	push   $0x392
f0100dac:	68 ff 73 10 f0       	push   $0xf01073ff
f0100db1:	e8 8a f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100db6:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100dbb:	75 19                	jne    f0100dd6 <check_page_free_list+0x1ee>
f0100dbd:	68 78 74 10 f0       	push   $0xf0107478
f0100dc2:	68 25 74 10 f0       	push   $0xf0107425
f0100dc7:	68 93 03 00 00       	push   $0x393
f0100dcc:	68 ff 73 10 f0       	push   $0xf01073ff
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
f0100dec:	68 44 6e 10 f0       	push   $0xf0106e44
f0100df1:	6a 58                	push   $0x58
f0100df3:	68 0b 74 10 f0       	push   $0xf010740b
f0100df8:	e8 43 f2 ff ff       	call   f0100040 <_panic>
f0100dfd:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100e03:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100e06:	0f 86 b6 00 00 00    	jbe    f0100ec2 <check_page_free_list+0x2da>
f0100e0c:	68 e8 77 10 f0       	push   $0xf01077e8
f0100e11:	68 25 74 10 f0       	push   $0xf0107425
f0100e16:	68 94 03 00 00       	push   $0x394
f0100e1b:	68 ff 73 10 f0       	push   $0xf01073ff
f0100e20:	e8 1b f2 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e25:	68 92 74 10 f0       	push   $0xf0107492
f0100e2a:	68 25 74 10 f0       	push   $0xf0107425
f0100e2f:	68 96 03 00 00       	push   $0x396
f0100e34:	68 ff 73 10 f0       	push   $0xf01073ff
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
f0100e54:	68 af 74 10 f0       	push   $0xf01074af
f0100e59:	68 25 74 10 f0       	push   $0xf0107425
f0100e5e:	68 9e 03 00 00       	push   $0x39e
f0100e63:	68 ff 73 10 f0       	push   $0xf01073ff
f0100e68:	e8 d3 f1 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100e6d:	85 db                	test   %ebx,%ebx
f0100e6f:	7f 19                	jg     f0100e8a <check_page_free_list+0x2a2>
f0100e71:	68 c1 74 10 f0       	push   $0xf01074c1
f0100e76:	68 25 74 10 f0       	push   $0xf0107425
f0100e7b:	68 9f 03 00 00       	push   $0x39f
f0100e80:	68 ff 73 10 f0       	push   $0xf01073ff
f0100e85:	e8 b6 f1 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100e8a:	83 ec 0c             	sub    $0xc,%esp
f0100e8d:	68 30 78 10 f0       	push   $0xf0107830
f0100e92:	e8 fa 2a 00 00       	call   f0103991 <cprintf>
}
f0100e97:	eb 49                	jmp    f0100ee2 <check_page_free_list+0x2fa>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100e99:	a1 40 c2 2a f0       	mov    0xf02ac240,%eax
f0100e9e:	85 c0                	test   %eax,%eax
f0100ea0:	0f 85 6f fd ff ff    	jne    f0100c15 <check_page_free_list+0x2d>
f0100ea6:	e9 53 fd ff ff       	jmp    f0100bfe <check_page_free_list+0x16>
f0100eab:	83 3d 40 c2 2a f0 00 	cmpl   $0x0,0xf02ac240
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
f0100eef:	a1 a0 ce 2a f0       	mov    0xf02acea0,%eax
f0100ef4:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	pages[0].pp_link = 0;
f0100efa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	extern unsigned char mpentry_start[], mpentry_end[];
	uint32_t size = ROUNDUP(mpentry_end - mpentry_start, PGSIZE);
f0100f00:	be 6d 6a 10 f0       	mov    $0xf0106a6d,%esi
f0100f05:	81 ee f4 59 10 f0    	sub    $0xf01059f4,%esi
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
f0100f2e:	a1 a0 ce 2a f0       	mov    0xf02acea0,%eax
f0100f33:	8d 04 d8             	lea    (%eax,%ebx,8),%eax
f0100f36:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link = 0;
f0100f3c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			cprintf("[?] non-boot CPUs (APs)\n");
f0100f42:	83 ec 0c             	sub    $0xc,%esp
f0100f45:	68 d2 74 10 f0       	push   $0xf01074d2
f0100f4a:	e8 42 2a 00 00       	call   f0103991 <cprintf>
f0100f4f:	83 c4 10             	add    $0x10,%esp
f0100f52:	eb 28                	jmp    f0100f7c <page_init+0x92>
		}
		else {
			pages[i].pp_ref = 0;
f0100f54:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100f5b:	89 c2                	mov    %eax,%edx
f0100f5d:	03 15 a0 ce 2a f0    	add    0xf02acea0,%edx
f0100f63:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
			pages[i].pp_link = page_free_list;
f0100f69:	8b 0d 40 c2 2a f0    	mov    0xf02ac240,%ecx
f0100f6f:	89 0a                	mov    %ecx,(%edx)
			page_free_list = &pages[i];
f0100f71:	03 05 a0 ce 2a f0    	add    0xf02acea0,%eax
f0100f77:	a3 40 c2 2a f0       	mov    %eax,0xf02ac240
	extern unsigned char mpentry_start[], mpentry_end[];
	uint32_t size = ROUNDUP(mpentry_end - mpentry_start, PGSIZE);
	// cprintf("[?] Init from 0x%x to 0x%x\n", PGSIZE, PGSIZE * npages_basemem);

	// 2)	[1-npages_basemem) free, except APs area (lab4)
	for (i = 1; i < npages_basemem; i++) {
f0100f7c:	83 c3 01             	add    $0x1,%ebx
f0100f7f:	3b 1d 44 c2 2a f0    	cmp    0xf02ac244,%ebx
f0100f85:	72 97                	jb     f0100f1e <page_init+0x34>
f0100f87:	8b 0d 40 c2 2a f0    	mov    0xf02ac240,%ecx
f0100f8d:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100f94:	ba 00 00 00 00       	mov    $0x0,%edx
f0100f99:	eb 23                	jmp    f0100fbe <page_init+0xd4>
	}

	// [npages_basemem, IOPHYSMEM / PGSIZE) free
	// cprintf("[?] %d, %d, %d\n", npages_basemem, IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE);
	for (; i < IOPHYSMEM / PGSIZE; i++) {
		pages[i].pp_ref = 0;
f0100f9b:	89 c2                	mov    %eax,%edx
f0100f9d:	03 15 a0 ce 2a f0    	add    0xf02acea0,%edx
f0100fa3:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f0100fa9:	89 0a                	mov    %ecx,(%edx)
		page_free_list = &pages[i];
f0100fab:	89 c1                	mov    %eax,%ecx
f0100fad:	03 0d a0 ce 2a f0    	add    0xf02acea0,%ecx
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
f0100fca:	89 0d 40 c2 2a f0    	mov    %ecx,0xf02ac240
f0100fd0:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100fd7:	eb 1a                	jmp    f0100ff3 <page_init+0x109>
		page_free_list = &pages[i];
	}

	// 3) [IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE) in use
	for (; i < EXTPHYSMEM / PGSIZE; i++) {
		pages[i].pp_ref = 1;
f0100fd9:	89 c2                	mov    %eax,%edx
f0100fdb:	03 15 a0 ce 2a f0    	add    0xf02acea0,%edx
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
f0101006:	03 05 a0 ce 2a f0    	add    0xf02acea0,%eax
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
f0101030:	68 68 6e 10 f0       	push   $0xf0106e68
f0101035:	68 7d 01 00 00       	push   $0x17d
f010103a:	68 ff 73 10 f0       	push   $0xf01073ff
f010103f:	e8 fc ef ff ff       	call   f0100040 <_panic>
f0101044:	05 00 00 00 10       	add    $0x10000000,%eax
f0101049:	c1 e8 0c             	shr    $0xc,%eax
f010104c:	39 c3                	cmp    %eax,%ebx
f010104e:	72 b4                	jb     f0101004 <page_init+0x11a>
f0101050:	8b 0d 40 c2 2a f0    	mov    0xf02ac240,%ecx
f0101056:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f010105d:	ba 00 00 00 00       	mov    $0x0,%edx
f0101062:	eb 23                	jmp    f0101087 <page_init+0x19d>
		pages[i].pp_link = 0;
	}

	// [kernel end, npages) free
	for (; i < npages; i++) {
		pages[i].pp_ref = 0;
f0101064:	89 c2                	mov    %eax,%edx
f0101066:	03 15 a0 ce 2a f0    	add    0xf02acea0,%edx
f010106c:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f0101072:	89 0a                	mov    %ecx,(%edx)
		page_free_list = &pages[i];
f0101074:	89 c1                	mov    %eax,%ecx
f0101076:	03 0d a0 ce 2a f0    	add    0xf02acea0,%ecx
		pages[i].pp_ref = 1;
		pages[i].pp_link = 0;
	}

	// [kernel end, npages) free
	for (; i < npages; i++) {
f010107c:	83 c3 01             	add    $0x1,%ebx
f010107f:	83 c0 08             	add    $0x8,%eax
f0101082:	ba 01 00 00 00       	mov    $0x1,%edx
f0101087:	3b 1d 98 ce 2a f0    	cmp    0xf02ace98,%ebx
f010108d:	72 d5                	jb     f0101064 <page_init+0x17a>
f010108f:	84 d2                	test   %dl,%dl
f0101091:	74 06                	je     f0101099 <page_init+0x1af>
f0101093:	89 0d 40 c2 2a f0    	mov    %ecx,0xf02ac240
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
f01010a5:	8b 1d 40 c2 2a f0    	mov    0xf02ac240,%ebx
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
f01010bf:	2b 05 a0 ce 2a f0    	sub    0xf02acea0,%eax
f01010c5:	c1 f8 03             	sar    $0x3,%eax
f01010c8:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01010cb:	89 c2                	mov    %eax,%edx
f01010cd:	c1 ea 0c             	shr    $0xc,%edx
f01010d0:	3b 15 98 ce 2a f0    	cmp    0xf02ace98,%edx
f01010d6:	72 12                	jb     f01010ea <page_alloc+0x4a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010d8:	50                   	push   %eax
f01010d9:	68 44 6e 10 f0       	push   $0xf0106e44
f01010de:	6a 58                	push   $0x58
f01010e0:	68 0b 74 10 f0       	push   $0xf010740b
f01010e5:	e8 56 ef ff ff       	call   f0100040 <_panic>
		// cprintf("[?] alloc zero, %x, %x\n", page_free_list, PADDR(page_free_list));
		// memset((char *)page2pa(page_free_list), 0, PGSIZE);
		memset(page2kva(page_free_list), 0, PGSIZE);
f01010ea:	83 ec 04             	sub    $0x4,%esp
f01010ed:	68 00 10 00 00       	push   $0x1000
f01010f2:	6a 00                	push   $0x0
f01010f4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01010f9:	50                   	push   %eax
f01010fa:	e8 f0 46 00 00       	call   f01057ef <memset>
f01010ff:	83 c4 10             	add    $0x10,%esp
	}
	
	// update free list head
	page_free_list = last_free;
f0101102:	89 35 40 c2 2a f0    	mov    %esi,0xf02ac240

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
f0101126:	68 54 78 10 f0       	push   $0xf0107854
f010112b:	68 c1 01 00 00       	push   $0x1c1
f0101130:	68 ff 73 10 f0       	push   $0xf01073ff
f0101135:	e8 06 ef ff ff       	call   f0100040 <_panic>
	if (pp->pp_ref != 0)
f010113a:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010113f:	74 17                	je     f0101158 <page_free+0x47>
		panic("page_free: other pointers still point to it, mind use-after-free!\n");
f0101141:	83 ec 04             	sub    $0x4,%esp
f0101144:	68 7c 78 10 f0       	push   $0xf010787c
f0101149:	68 c3 01 00 00       	push   $0x1c3
f010114e:	68 ff 73 10 f0       	push   $0xf01073ff
f0101153:	e8 e8 ee ff ff       	call   f0100040 <_panic>

	pp->pp_link = page_free_list;
f0101158:	8b 15 40 c2 2a f0    	mov    0xf02ac240,%edx
f010115e:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101160:	a3 40 c2 2a f0       	mov    %eax,0xf02ac240

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
f01011a9:	68 eb 74 10 f0       	push   $0xf01074eb
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
f01011cb:	68 f6 74 10 f0       	push   $0xf01074f6
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
f01011f6:	2b 15 a0 ce 2a f0    	sub    0xf02acea0,%edx
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
f0101225:	68 02 75 10 f0       	push   $0xf0107502
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
f010123e:	3b 15 98 ce 2a f0    	cmp    0xf02ace98,%edx
f0101244:	72 48                	jb     f010128e <pgdir_walk+0x100>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101246:	50                   	push   %eax
f0101247:	68 44 6e 10 f0       	push   $0xf0106e44
f010124c:	68 1c 02 00 00       	push   $0x21c
f0101251:	68 ff 73 10 f0       	push   $0xf01073ff
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
f01012a0:	68 14 75 10 f0       	push   $0xf0107514
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
f01012c3:	3b 15 98 ce 2a f0    	cmp    0xf02ace98,%edx
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
f01012ea:	68 c0 78 10 f0       	push   $0xf01078c0
f01012ef:	e8 9d 26 00 00       	call   f0103991 <cprintf>
	
	// Fill this function in	
	if (size % PGSIZE != 0)
f01012f4:	83 c4 10             	add    $0x10,%esp
f01012f7:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f01012fd:	74 17                	je     f0101316 <boot_map_region+0x3e>
		panic("boot_map_region: size is not a multiple of PGSIZE\n");
f01012ff:	83 ec 04             	sub    $0x4,%esp
f0101302:	68 e4 78 10 f0       	push   $0xf01078e4
f0101307:	68 37 02 00 00       	push   $0x237
f010130c:	68 ff 73 10 f0       	push   $0xf01073ff
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
f0101345:	68 18 79 10 f0       	push   $0xf0107918
f010134a:	68 3a 02 00 00       	push   $0x23a
f010134f:	68 ff 73 10 f0       	push   $0xf01073ff
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
f0101374:	68 48 79 10 f0       	push   $0xf0107948
f0101379:	68 45 02 00 00       	push   $0x245
f010137e:	68 ff 73 10 f0       	push   $0xf01073ff
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
f01013d9:	3b 05 98 ce 2a f0    	cmp    0xf02ace98,%eax
f01013df:	72 14                	jb     f01013f5 <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f01013e1:	83 ec 04             	sub    $0x4,%esp
f01013e4:	68 74 79 10 f0       	push   $0xf0107974
f01013e9:	6a 51                	push   $0x51
f01013eb:	68 0b 74 10 f0       	push   $0xf010740b
f01013f0:	e8 4b ec ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f01013f5:	8b 15 a0 ce 2a f0    	mov    0xf02acea0,%edx
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
f0101417:	e8 f6 49 00 00       	call   f0105e12 <cpunum>
f010141c:	6b c0 74             	imul   $0x74,%eax,%eax
f010141f:	83 b8 28 d0 2a f0 00 	cmpl   $0x0,-0xfd52fd8(%eax)
f0101426:	74 16                	je     f010143e <tlb_invalidate+0x2d>
f0101428:	e8 e5 49 00 00       	call   f0105e12 <cpunum>
f010142d:	6b c0 74             	imul   $0x74,%eax,%eax
f0101430:	8b 80 28 d0 2a f0    	mov    -0xfd52fd8(%eax),%eax
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
f01014c3:	2b 15 a0 ce 2a f0    	sub    0xf02acea0,%edx
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
f01014eb:	2b 05 a0 ce 2a f0    	sub    0xf02acea0,%eax
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
f0101522:	8b 35 00 43 12 f0    	mov    0xf0124300,%esi

	if (ROUNDUP(mmio + size, PGSIZE) >= MMIOLIM)
f0101528:	8d 84 0e ff 0f 00 00 	lea    0xfff(%esi,%ecx,1),%eax
f010152f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101534:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0101539:	76 17                	jbe    f0101552 <mmio_map_region+0x38>
		panic("mmio_map_region: mmio out of memory");
f010153b:	83 ec 04             	sub    $0x4,%esp
f010153e:	68 94 79 10 f0       	push   $0xf0107994
f0101543:	68 0c 03 00 00       	push   $0x30c
f0101548:	68 ff 73 10 f0       	push   $0xf01073ff
f010154d:	e8 ee ea ff ff       	call   f0100040 <_panic>
		
	boot_map_region(kern_pgdir, mmio, ROUNDUP(size, PGSIZE), pa, PTE_PCD|PTE_PWT|PTE_W);
f0101552:	8d 99 ff 0f 00 00    	lea    0xfff(%ecx),%ebx
f0101558:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f010155e:	83 ec 08             	sub    $0x8,%esp
f0101561:	6a 1a                	push   $0x1a
f0101563:	ff 75 08             	pushl  0x8(%ebp)
f0101566:	89 d9                	mov    %ebx,%ecx
f0101568:	89 f2                	mov    %esi,%edx
f010156a:	a1 9c ce 2a f0       	mov    0xf02ace9c,%eax
f010156f:	e8 64 fd ff ff       	call   f01012d8 <boot_map_region>

	base += ROUNDUP(size, PGSIZE);
f0101574:	01 1d 00 43 12 f0    	add    %ebx,0xf0124300

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
f01015cc:	89 15 98 ce 2a f0    	mov    %edx,0xf02ace98
	npages_basemem = basemem / (PGSIZE / 1024);
f01015d2:	89 da                	mov    %ebx,%edx
f01015d4:	c1 ea 02             	shr    $0x2,%edx
f01015d7:	89 15 44 c2 2a f0    	mov    %edx,0xf02ac244

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01015dd:	89 c2                	mov    %eax,%edx
f01015df:	29 da                	sub    %ebx,%edx
f01015e1:	52                   	push   %edx
f01015e2:	53                   	push   %ebx
f01015e3:	50                   	push   %eax
f01015e4:	68 b8 79 10 f0       	push   $0xf01079b8
f01015e9:	e8 a3 23 00 00       	call   f0103991 <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01015ee:	b8 00 10 00 00       	mov    $0x1000,%eax
f01015f3:	e8 39 f5 ff ff       	call   f0100b31 <boot_alloc>
f01015f8:	a3 9c ce 2a f0       	mov    %eax,0xf02ace9c
	memset(kern_pgdir, 0, PGSIZE);
f01015fd:	83 c4 0c             	add    $0xc,%esp
f0101600:	68 00 10 00 00       	push   $0x1000
f0101605:	6a 00                	push   $0x0
f0101607:	50                   	push   %eax
f0101608:	e8 e2 41 00 00       	call   f01057ef <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010160d:	a1 9c ce 2a f0       	mov    0xf02ace9c,%eax
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
f010161d:	68 68 6e 10 f0       	push   $0xf0106e68
f0101622:	68 9b 00 00 00       	push   $0x9b
f0101627:	68 ff 73 10 f0       	push   $0xf01073ff
f010162c:	e8 0f ea ff ff       	call   f0100040 <_panic>
f0101631:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101637:	83 ca 05             	or     $0x5,%edx
f010163a:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:

	n = npages * sizeof(struct PageInfo);
f0101640:	a1 98 ce 2a f0       	mov    0xf02ace98,%eax
f0101645:	8d 1c c5 00 00 00 00 	lea    0x0(,%eax,8),%ebx
	pages = (struct PageInfo *) boot_alloc(n);
f010164c:	89 d8                	mov    %ebx,%eax
f010164e:	e8 de f4 ff ff       	call   f0100b31 <boot_alloc>
f0101653:	a3 a0 ce 2a f0       	mov    %eax,0xf02acea0
	memset(pages, 0, n);
f0101658:	83 ec 04             	sub    $0x4,%esp
f010165b:	53                   	push   %ebx
f010165c:	6a 00                	push   $0x0
f010165e:	50                   	push   %eax
f010165f:	e8 8b 41 00 00       	call   f01057ef <memset>
	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.

	n = NENV * sizeof(struct Env);
	envs = (struct Env *) boot_alloc(n);
f0101664:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101669:	e8 c3 f4 ff ff       	call   f0100b31 <boot_alloc>
f010166e:	a3 48 c2 2a f0       	mov    %eax,0xf02ac248
	memset(envs, 0, n);
f0101673:	83 c4 0c             	add    $0xc,%esp
f0101676:	68 00 f0 01 00       	push   $0x1f000
f010167b:	6a 00                	push   $0x0
f010167d:	50                   	push   %eax
f010167e:	e8 6c 41 00 00       	call   f01057ef <memset>
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
f0101695:	83 3d a0 ce 2a f0 00 	cmpl   $0x0,0xf02acea0
f010169c:	75 17                	jne    f01016b5 <mem_init+0x132>
		panic("'pages' is a null pointer!");
f010169e:	83 ec 04             	sub    $0x4,%esp
f01016a1:	68 2c 75 10 f0       	push   $0xf010752c
f01016a6:	68 b2 03 00 00       	push   $0x3b2
f01016ab:	68 ff 73 10 f0       	push   $0xf01073ff
f01016b0:	e8 8b e9 ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01016b5:	a1 40 c2 2a f0       	mov    0xf02ac240,%eax
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
f01016dd:	68 47 75 10 f0       	push   $0xf0107547
f01016e2:	68 25 74 10 f0       	push   $0xf0107425
f01016e7:	68 ba 03 00 00       	push   $0x3ba
f01016ec:	68 ff 73 10 f0       	push   $0xf01073ff
f01016f1:	e8 4a e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01016f6:	83 ec 0c             	sub    $0xc,%esp
f01016f9:	6a 00                	push   $0x0
f01016fb:	e8 a0 f9 ff ff       	call   f01010a0 <page_alloc>
f0101700:	89 c6                	mov    %eax,%esi
f0101702:	83 c4 10             	add    $0x10,%esp
f0101705:	85 c0                	test   %eax,%eax
f0101707:	75 19                	jne    f0101722 <mem_init+0x19f>
f0101709:	68 5d 75 10 f0       	push   $0xf010755d
f010170e:	68 25 74 10 f0       	push   $0xf0107425
f0101713:	68 bb 03 00 00       	push   $0x3bb
f0101718:	68 ff 73 10 f0       	push   $0xf01073ff
f010171d:	e8 1e e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101722:	83 ec 0c             	sub    $0xc,%esp
f0101725:	6a 00                	push   $0x0
f0101727:	e8 74 f9 ff ff       	call   f01010a0 <page_alloc>
f010172c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010172f:	83 c4 10             	add    $0x10,%esp
f0101732:	85 c0                	test   %eax,%eax
f0101734:	75 19                	jne    f010174f <mem_init+0x1cc>
f0101736:	68 73 75 10 f0       	push   $0xf0107573
f010173b:	68 25 74 10 f0       	push   $0xf0107425
f0101740:	68 bc 03 00 00       	push   $0x3bc
f0101745:	68 ff 73 10 f0       	push   $0xf01073ff
f010174a:	e8 f1 e8 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010174f:	39 f7                	cmp    %esi,%edi
f0101751:	75 19                	jne    f010176c <mem_init+0x1e9>
f0101753:	68 89 75 10 f0       	push   $0xf0107589
f0101758:	68 25 74 10 f0       	push   $0xf0107425
f010175d:	68 bf 03 00 00       	push   $0x3bf
f0101762:	68 ff 73 10 f0       	push   $0xf01073ff
f0101767:	e8 d4 e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010176c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010176f:	39 c6                	cmp    %eax,%esi
f0101771:	74 04                	je     f0101777 <mem_init+0x1f4>
f0101773:	39 c7                	cmp    %eax,%edi
f0101775:	75 19                	jne    f0101790 <mem_init+0x20d>
f0101777:	68 f4 79 10 f0       	push   $0xf01079f4
f010177c:	68 25 74 10 f0       	push   $0xf0107425
f0101781:	68 c0 03 00 00       	push   $0x3c0
f0101786:	68 ff 73 10 f0       	push   $0xf01073ff
f010178b:	e8 b0 e8 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101790:	8b 0d a0 ce 2a f0    	mov    0xf02acea0,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101796:	8b 15 98 ce 2a f0    	mov    0xf02ace98,%edx
f010179c:	c1 e2 0c             	shl    $0xc,%edx
f010179f:	89 f8                	mov    %edi,%eax
f01017a1:	29 c8                	sub    %ecx,%eax
f01017a3:	c1 f8 03             	sar    $0x3,%eax
f01017a6:	c1 e0 0c             	shl    $0xc,%eax
f01017a9:	39 d0                	cmp    %edx,%eax
f01017ab:	72 19                	jb     f01017c6 <mem_init+0x243>
f01017ad:	68 9b 75 10 f0       	push   $0xf010759b
f01017b2:	68 25 74 10 f0       	push   $0xf0107425
f01017b7:	68 c1 03 00 00       	push   $0x3c1
f01017bc:	68 ff 73 10 f0       	push   $0xf01073ff
f01017c1:	e8 7a e8 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01017c6:	89 f0                	mov    %esi,%eax
f01017c8:	29 c8                	sub    %ecx,%eax
f01017ca:	c1 f8 03             	sar    $0x3,%eax
f01017cd:	c1 e0 0c             	shl    $0xc,%eax
f01017d0:	39 c2                	cmp    %eax,%edx
f01017d2:	77 19                	ja     f01017ed <mem_init+0x26a>
f01017d4:	68 b8 75 10 f0       	push   $0xf01075b8
f01017d9:	68 25 74 10 f0       	push   $0xf0107425
f01017de:	68 c2 03 00 00       	push   $0x3c2
f01017e3:	68 ff 73 10 f0       	push   $0xf01073ff
f01017e8:	e8 53 e8 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01017ed:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01017f0:	29 c8                	sub    %ecx,%eax
f01017f2:	c1 f8 03             	sar    $0x3,%eax
f01017f5:	c1 e0 0c             	shl    $0xc,%eax
f01017f8:	39 c2                	cmp    %eax,%edx
f01017fa:	77 19                	ja     f0101815 <mem_init+0x292>
f01017fc:	68 d5 75 10 f0       	push   $0xf01075d5
f0101801:	68 25 74 10 f0       	push   $0xf0107425
f0101806:	68 c3 03 00 00       	push   $0x3c3
f010180b:	68 ff 73 10 f0       	push   $0xf01073ff
f0101810:	e8 2b e8 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101815:	a1 40 c2 2a f0       	mov    0xf02ac240,%eax
f010181a:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010181d:	c7 05 40 c2 2a f0 00 	movl   $0x0,0xf02ac240
f0101824:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101827:	83 ec 0c             	sub    $0xc,%esp
f010182a:	6a 00                	push   $0x0
f010182c:	e8 6f f8 ff ff       	call   f01010a0 <page_alloc>
f0101831:	83 c4 10             	add    $0x10,%esp
f0101834:	85 c0                	test   %eax,%eax
f0101836:	74 19                	je     f0101851 <mem_init+0x2ce>
f0101838:	68 f2 75 10 f0       	push   $0xf01075f2
f010183d:	68 25 74 10 f0       	push   $0xf0107425
f0101842:	68 ca 03 00 00       	push   $0x3ca
f0101847:	68 ff 73 10 f0       	push   $0xf01073ff
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
f0101882:	68 47 75 10 f0       	push   $0xf0107547
f0101887:	68 25 74 10 f0       	push   $0xf0107425
f010188c:	68 d1 03 00 00       	push   $0x3d1
f0101891:	68 ff 73 10 f0       	push   $0xf01073ff
f0101896:	e8 a5 e7 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010189b:	83 ec 0c             	sub    $0xc,%esp
f010189e:	6a 00                	push   $0x0
f01018a0:	e8 fb f7 ff ff       	call   f01010a0 <page_alloc>
f01018a5:	89 c7                	mov    %eax,%edi
f01018a7:	83 c4 10             	add    $0x10,%esp
f01018aa:	85 c0                	test   %eax,%eax
f01018ac:	75 19                	jne    f01018c7 <mem_init+0x344>
f01018ae:	68 5d 75 10 f0       	push   $0xf010755d
f01018b3:	68 25 74 10 f0       	push   $0xf0107425
f01018b8:	68 d2 03 00 00       	push   $0x3d2
f01018bd:	68 ff 73 10 f0       	push   $0xf01073ff
f01018c2:	e8 79 e7 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01018c7:	83 ec 0c             	sub    $0xc,%esp
f01018ca:	6a 00                	push   $0x0
f01018cc:	e8 cf f7 ff ff       	call   f01010a0 <page_alloc>
f01018d1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01018d4:	83 c4 10             	add    $0x10,%esp
f01018d7:	85 c0                	test   %eax,%eax
f01018d9:	75 19                	jne    f01018f4 <mem_init+0x371>
f01018db:	68 73 75 10 f0       	push   $0xf0107573
f01018e0:	68 25 74 10 f0       	push   $0xf0107425
f01018e5:	68 d3 03 00 00       	push   $0x3d3
f01018ea:	68 ff 73 10 f0       	push   $0xf01073ff
f01018ef:	e8 4c e7 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01018f4:	39 fe                	cmp    %edi,%esi
f01018f6:	75 19                	jne    f0101911 <mem_init+0x38e>
f01018f8:	68 89 75 10 f0       	push   $0xf0107589
f01018fd:	68 25 74 10 f0       	push   $0xf0107425
f0101902:	68 d5 03 00 00       	push   $0x3d5
f0101907:	68 ff 73 10 f0       	push   $0xf01073ff
f010190c:	e8 2f e7 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101911:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101914:	39 c7                	cmp    %eax,%edi
f0101916:	74 04                	je     f010191c <mem_init+0x399>
f0101918:	39 c6                	cmp    %eax,%esi
f010191a:	75 19                	jne    f0101935 <mem_init+0x3b2>
f010191c:	68 f4 79 10 f0       	push   $0xf01079f4
f0101921:	68 25 74 10 f0       	push   $0xf0107425
f0101926:	68 d6 03 00 00       	push   $0x3d6
f010192b:	68 ff 73 10 f0       	push   $0xf01073ff
f0101930:	e8 0b e7 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101935:	83 ec 0c             	sub    $0xc,%esp
f0101938:	6a 00                	push   $0x0
f010193a:	e8 61 f7 ff ff       	call   f01010a0 <page_alloc>
f010193f:	83 c4 10             	add    $0x10,%esp
f0101942:	85 c0                	test   %eax,%eax
f0101944:	74 19                	je     f010195f <mem_init+0x3dc>
f0101946:	68 f2 75 10 f0       	push   $0xf01075f2
f010194b:	68 25 74 10 f0       	push   $0xf0107425
f0101950:	68 d7 03 00 00       	push   $0x3d7
f0101955:	68 ff 73 10 f0       	push   $0xf01073ff
f010195a:	e8 e1 e6 ff ff       	call   f0100040 <_panic>
f010195f:	89 f0                	mov    %esi,%eax
f0101961:	2b 05 a0 ce 2a f0    	sub    0xf02acea0,%eax
f0101967:	c1 f8 03             	sar    $0x3,%eax
f010196a:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010196d:	89 c2                	mov    %eax,%edx
f010196f:	c1 ea 0c             	shr    $0xc,%edx
f0101972:	3b 15 98 ce 2a f0    	cmp    0xf02ace98,%edx
f0101978:	72 12                	jb     f010198c <mem_init+0x409>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010197a:	50                   	push   %eax
f010197b:	68 44 6e 10 f0       	push   $0xf0106e44
f0101980:	6a 58                	push   $0x58
f0101982:	68 0b 74 10 f0       	push   $0xf010740b
f0101987:	e8 b4 e6 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f010198c:	83 ec 04             	sub    $0x4,%esp
f010198f:	68 00 10 00 00       	push   $0x1000
f0101994:	6a 01                	push   $0x1
f0101996:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010199b:	50                   	push   %eax
f010199c:	e8 4e 3e 00 00       	call   f01057ef <memset>
	page_free(pp0);
f01019a1:	89 34 24             	mov    %esi,(%esp)
f01019a4:	e8 68 f7 ff ff       	call   f0101111 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01019a9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01019b0:	e8 eb f6 ff ff       	call   f01010a0 <page_alloc>
f01019b5:	83 c4 10             	add    $0x10,%esp
f01019b8:	85 c0                	test   %eax,%eax
f01019ba:	75 19                	jne    f01019d5 <mem_init+0x452>
f01019bc:	68 01 76 10 f0       	push   $0xf0107601
f01019c1:	68 25 74 10 f0       	push   $0xf0107425
f01019c6:	68 dc 03 00 00       	push   $0x3dc
f01019cb:	68 ff 73 10 f0       	push   $0xf01073ff
f01019d0:	e8 6b e6 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f01019d5:	39 c6                	cmp    %eax,%esi
f01019d7:	74 19                	je     f01019f2 <mem_init+0x46f>
f01019d9:	68 1f 76 10 f0       	push   $0xf010761f
f01019de:	68 25 74 10 f0       	push   $0xf0107425
f01019e3:	68 dd 03 00 00       	push   $0x3dd
f01019e8:	68 ff 73 10 f0       	push   $0xf01073ff
f01019ed:	e8 4e e6 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01019f2:	89 f0                	mov    %esi,%eax
f01019f4:	2b 05 a0 ce 2a f0    	sub    0xf02acea0,%eax
f01019fa:	c1 f8 03             	sar    $0x3,%eax
f01019fd:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101a00:	89 c2                	mov    %eax,%edx
f0101a02:	c1 ea 0c             	shr    $0xc,%edx
f0101a05:	3b 15 98 ce 2a f0    	cmp    0xf02ace98,%edx
f0101a0b:	72 12                	jb     f0101a1f <mem_init+0x49c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101a0d:	50                   	push   %eax
f0101a0e:	68 44 6e 10 f0       	push   $0xf0106e44
f0101a13:	6a 58                	push   $0x58
f0101a15:	68 0b 74 10 f0       	push   $0xf010740b
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
f0101a30:	68 2f 76 10 f0       	push   $0xf010762f
f0101a35:	68 25 74 10 f0       	push   $0xf0107425
f0101a3a:	68 e1 03 00 00       	push   $0x3e1
f0101a3f:	68 ff 73 10 f0       	push   $0xf01073ff
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
f0101a53:	a3 40 c2 2a f0       	mov    %eax,0xf02ac240

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
f0101a74:	a1 40 c2 2a f0       	mov    0xf02ac240,%eax
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
f0101a8b:	68 39 76 10 f0       	push   $0xf0107639
f0101a90:	68 25 74 10 f0       	push   $0xf0107425
f0101a95:	68 ef 03 00 00       	push   $0x3ef
f0101a9a:	68 ff 73 10 f0       	push   $0xf01073ff
f0101a9f:	e8 9c e5 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101aa4:	83 ec 0c             	sub    $0xc,%esp
f0101aa7:	68 14 7a 10 f0       	push   $0xf0107a14
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
f0101ac7:	68 47 75 10 f0       	push   $0xf0107547
f0101acc:	68 25 74 10 f0       	push   $0xf0107425
f0101ad1:	68 59 04 00 00       	push   $0x459
f0101ad6:	68 ff 73 10 f0       	push   $0xf01073ff
f0101adb:	e8 60 e5 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101ae0:	83 ec 0c             	sub    $0xc,%esp
f0101ae3:	6a 00                	push   $0x0
f0101ae5:	e8 b6 f5 ff ff       	call   f01010a0 <page_alloc>
f0101aea:	89 c3                	mov    %eax,%ebx
f0101aec:	83 c4 10             	add    $0x10,%esp
f0101aef:	85 c0                	test   %eax,%eax
f0101af1:	75 19                	jne    f0101b0c <mem_init+0x589>
f0101af3:	68 5d 75 10 f0       	push   $0xf010755d
f0101af8:	68 25 74 10 f0       	push   $0xf0107425
f0101afd:	68 5a 04 00 00       	push   $0x45a
f0101b02:	68 ff 73 10 f0       	push   $0xf01073ff
f0101b07:	e8 34 e5 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101b0c:	83 ec 0c             	sub    $0xc,%esp
f0101b0f:	6a 00                	push   $0x0
f0101b11:	e8 8a f5 ff ff       	call   f01010a0 <page_alloc>
f0101b16:	89 c6                	mov    %eax,%esi
f0101b18:	83 c4 10             	add    $0x10,%esp
f0101b1b:	85 c0                	test   %eax,%eax
f0101b1d:	75 19                	jne    f0101b38 <mem_init+0x5b5>
f0101b1f:	68 73 75 10 f0       	push   $0xf0107573
f0101b24:	68 25 74 10 f0       	push   $0xf0107425
f0101b29:	68 5b 04 00 00       	push   $0x45b
f0101b2e:	68 ff 73 10 f0       	push   $0xf01073ff
f0101b33:	e8 08 e5 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101b38:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101b3b:	75 19                	jne    f0101b56 <mem_init+0x5d3>
f0101b3d:	68 89 75 10 f0       	push   $0xf0107589
f0101b42:	68 25 74 10 f0       	push   $0xf0107425
f0101b47:	68 5e 04 00 00       	push   $0x45e
f0101b4c:	68 ff 73 10 f0       	push   $0xf01073ff
f0101b51:	e8 ea e4 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101b56:	39 c3                	cmp    %eax,%ebx
f0101b58:	74 05                	je     f0101b5f <mem_init+0x5dc>
f0101b5a:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101b5d:	75 19                	jne    f0101b78 <mem_init+0x5f5>
f0101b5f:	68 f4 79 10 f0       	push   $0xf01079f4
f0101b64:	68 25 74 10 f0       	push   $0xf0107425
f0101b69:	68 5f 04 00 00       	push   $0x45f
f0101b6e:	68 ff 73 10 f0       	push   $0xf01073ff
f0101b73:	e8 c8 e4 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101b78:	a1 40 c2 2a f0       	mov    0xf02ac240,%eax
f0101b7d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101b80:	c7 05 40 c2 2a f0 00 	movl   $0x0,0xf02ac240
f0101b87:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101b8a:	83 ec 0c             	sub    $0xc,%esp
f0101b8d:	6a 00                	push   $0x0
f0101b8f:	e8 0c f5 ff ff       	call   f01010a0 <page_alloc>
f0101b94:	83 c4 10             	add    $0x10,%esp
f0101b97:	85 c0                	test   %eax,%eax
f0101b99:	74 19                	je     f0101bb4 <mem_init+0x631>
f0101b9b:	68 f2 75 10 f0       	push   $0xf01075f2
f0101ba0:	68 25 74 10 f0       	push   $0xf0107425
f0101ba5:	68 66 04 00 00       	push   $0x466
f0101baa:	68 ff 73 10 f0       	push   $0xf01073ff
f0101baf:	e8 8c e4 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101bb4:	83 ec 04             	sub    $0x4,%esp
f0101bb7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101bba:	50                   	push   %eax
f0101bbb:	6a 00                	push   $0x0
f0101bbd:	ff 35 9c ce 2a f0    	pushl  0xf02ace9c
f0101bc3:	e8 e3 f7 ff ff       	call   f01013ab <page_lookup>
f0101bc8:	83 c4 10             	add    $0x10,%esp
f0101bcb:	85 c0                	test   %eax,%eax
f0101bcd:	74 19                	je     f0101be8 <mem_init+0x665>
f0101bcf:	68 34 7a 10 f0       	push   $0xf0107a34
f0101bd4:	68 25 74 10 f0       	push   $0xf0107425
f0101bd9:	68 69 04 00 00       	push   $0x469
f0101bde:	68 ff 73 10 f0       	push   $0xf01073ff
f0101be3:	e8 58 e4 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101be8:	6a 02                	push   $0x2
f0101bea:	6a 00                	push   $0x0
f0101bec:	53                   	push   %ebx
f0101bed:	ff 35 9c ce 2a f0    	pushl  0xf02ace9c
f0101bf3:	e8 9b f8 ff ff       	call   f0101493 <page_insert>
f0101bf8:	83 c4 10             	add    $0x10,%esp
f0101bfb:	85 c0                	test   %eax,%eax
f0101bfd:	78 19                	js     f0101c18 <mem_init+0x695>
f0101bff:	68 6c 7a 10 f0       	push   $0xf0107a6c
f0101c04:	68 25 74 10 f0       	push   $0xf0107425
f0101c09:	68 6c 04 00 00       	push   $0x46c
f0101c0e:	68 ff 73 10 f0       	push   $0xf01073ff
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
f0101c28:	ff 35 9c ce 2a f0    	pushl  0xf02ace9c
f0101c2e:	e8 60 f8 ff ff       	call   f0101493 <page_insert>
f0101c33:	83 c4 20             	add    $0x20,%esp
f0101c36:	85 c0                	test   %eax,%eax
f0101c38:	74 19                	je     f0101c53 <mem_init+0x6d0>
f0101c3a:	68 9c 7a 10 f0       	push   $0xf0107a9c
f0101c3f:	68 25 74 10 f0       	push   $0xf0107425
f0101c44:	68 70 04 00 00       	push   $0x470
f0101c49:	68 ff 73 10 f0       	push   $0xf01073ff
f0101c4e:	e8 ed e3 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101c53:	8b 3d 9c ce 2a f0    	mov    0xf02ace9c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101c59:	a1 a0 ce 2a f0       	mov    0xf02acea0,%eax
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
f0101c7a:	68 cc 7a 10 f0       	push   $0xf0107acc
f0101c7f:	68 25 74 10 f0       	push   $0xf0107425
f0101c84:	68 71 04 00 00       	push   $0x471
f0101c89:	68 ff 73 10 f0       	push   $0xf01073ff
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
f0101cae:	68 f4 7a 10 f0       	push   $0xf0107af4
f0101cb3:	68 25 74 10 f0       	push   $0xf0107425
f0101cb8:	68 72 04 00 00       	push   $0x472
f0101cbd:	68 ff 73 10 f0       	push   $0xf01073ff
f0101cc2:	e8 79 e3 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101cc7:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101ccc:	74 19                	je     f0101ce7 <mem_init+0x764>
f0101cce:	68 44 76 10 f0       	push   $0xf0107644
f0101cd3:	68 25 74 10 f0       	push   $0xf0107425
f0101cd8:	68 73 04 00 00       	push   $0x473
f0101cdd:	68 ff 73 10 f0       	push   $0xf01073ff
f0101ce2:	e8 59 e3 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101ce7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101cea:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101cef:	74 19                	je     f0101d0a <mem_init+0x787>
f0101cf1:	68 55 76 10 f0       	push   $0xf0107655
f0101cf6:	68 25 74 10 f0       	push   $0xf0107425
f0101cfb:	68 74 04 00 00       	push   $0x474
f0101d00:	68 ff 73 10 f0       	push   $0xf01073ff
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
f0101d1f:	68 24 7b 10 f0       	push   $0xf0107b24
f0101d24:	68 25 74 10 f0       	push   $0xf0107425
f0101d29:	68 77 04 00 00       	push   $0x477
f0101d2e:	68 ff 73 10 f0       	push   $0xf01073ff
f0101d33:	e8 08 e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d38:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d3d:	a1 9c ce 2a f0       	mov    0xf02ace9c,%eax
f0101d42:	e8 3d ee ff ff       	call   f0100b84 <check_va2pa>
f0101d47:	89 f2                	mov    %esi,%edx
f0101d49:	2b 15 a0 ce 2a f0    	sub    0xf02acea0,%edx
f0101d4f:	c1 fa 03             	sar    $0x3,%edx
f0101d52:	c1 e2 0c             	shl    $0xc,%edx
f0101d55:	39 d0                	cmp    %edx,%eax
f0101d57:	74 19                	je     f0101d72 <mem_init+0x7ef>
f0101d59:	68 60 7b 10 f0       	push   $0xf0107b60
f0101d5e:	68 25 74 10 f0       	push   $0xf0107425
f0101d63:	68 78 04 00 00       	push   $0x478
f0101d68:	68 ff 73 10 f0       	push   $0xf01073ff
f0101d6d:	e8 ce e2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101d72:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d77:	74 19                	je     f0101d92 <mem_init+0x80f>
f0101d79:	68 66 76 10 f0       	push   $0xf0107666
f0101d7e:	68 25 74 10 f0       	push   $0xf0107425
f0101d83:	68 79 04 00 00       	push   $0x479
f0101d88:	68 ff 73 10 f0       	push   $0xf01073ff
f0101d8d:	e8 ae e2 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101d92:	83 ec 0c             	sub    $0xc,%esp
f0101d95:	6a 00                	push   $0x0
f0101d97:	e8 04 f3 ff ff       	call   f01010a0 <page_alloc>
f0101d9c:	83 c4 10             	add    $0x10,%esp
f0101d9f:	85 c0                	test   %eax,%eax
f0101da1:	74 19                	je     f0101dbc <mem_init+0x839>
f0101da3:	68 f2 75 10 f0       	push   $0xf01075f2
f0101da8:	68 25 74 10 f0       	push   $0xf0107425
f0101dad:	68 7c 04 00 00       	push   $0x47c
f0101db2:	68 ff 73 10 f0       	push   $0xf01073ff
f0101db7:	e8 84 e2 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101dbc:	6a 02                	push   $0x2
f0101dbe:	68 00 10 00 00       	push   $0x1000
f0101dc3:	56                   	push   %esi
f0101dc4:	ff 35 9c ce 2a f0    	pushl  0xf02ace9c
f0101dca:	e8 c4 f6 ff ff       	call   f0101493 <page_insert>
f0101dcf:	83 c4 10             	add    $0x10,%esp
f0101dd2:	85 c0                	test   %eax,%eax
f0101dd4:	74 19                	je     f0101def <mem_init+0x86c>
f0101dd6:	68 24 7b 10 f0       	push   $0xf0107b24
f0101ddb:	68 25 74 10 f0       	push   $0xf0107425
f0101de0:	68 7f 04 00 00       	push   $0x47f
f0101de5:	68 ff 73 10 f0       	push   $0xf01073ff
f0101dea:	e8 51 e2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101def:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101df4:	a1 9c ce 2a f0       	mov    0xf02ace9c,%eax
f0101df9:	e8 86 ed ff ff       	call   f0100b84 <check_va2pa>
f0101dfe:	89 f2                	mov    %esi,%edx
f0101e00:	2b 15 a0 ce 2a f0    	sub    0xf02acea0,%edx
f0101e06:	c1 fa 03             	sar    $0x3,%edx
f0101e09:	c1 e2 0c             	shl    $0xc,%edx
f0101e0c:	39 d0                	cmp    %edx,%eax
f0101e0e:	74 19                	je     f0101e29 <mem_init+0x8a6>
f0101e10:	68 60 7b 10 f0       	push   $0xf0107b60
f0101e15:	68 25 74 10 f0       	push   $0xf0107425
f0101e1a:	68 80 04 00 00       	push   $0x480
f0101e1f:	68 ff 73 10 f0       	push   $0xf01073ff
f0101e24:	e8 17 e2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101e29:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101e2e:	74 19                	je     f0101e49 <mem_init+0x8c6>
f0101e30:	68 66 76 10 f0       	push   $0xf0107666
f0101e35:	68 25 74 10 f0       	push   $0xf0107425
f0101e3a:	68 81 04 00 00       	push   $0x481
f0101e3f:	68 ff 73 10 f0       	push   $0xf01073ff
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
f0101e5a:	68 f2 75 10 f0       	push   $0xf01075f2
f0101e5f:	68 25 74 10 f0       	push   $0xf0107425
f0101e64:	68 85 04 00 00       	push   $0x485
f0101e69:	68 ff 73 10 f0       	push   $0xf01073ff
f0101e6e:	e8 cd e1 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101e73:	8b 15 9c ce 2a f0    	mov    0xf02ace9c,%edx
f0101e79:	8b 02                	mov    (%edx),%eax
f0101e7b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101e80:	89 c1                	mov    %eax,%ecx
f0101e82:	c1 e9 0c             	shr    $0xc,%ecx
f0101e85:	3b 0d 98 ce 2a f0    	cmp    0xf02ace98,%ecx
f0101e8b:	72 15                	jb     f0101ea2 <mem_init+0x91f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101e8d:	50                   	push   %eax
f0101e8e:	68 44 6e 10 f0       	push   $0xf0106e44
f0101e93:	68 88 04 00 00       	push   $0x488
f0101e98:	68 ff 73 10 f0       	push   $0xf01073ff
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
f0101ec7:	68 90 7b 10 f0       	push   $0xf0107b90
f0101ecc:	68 25 74 10 f0       	push   $0xf0107425
f0101ed1:	68 89 04 00 00       	push   $0x489
f0101ed6:	68 ff 73 10 f0       	push   $0xf01073ff
f0101edb:	e8 60 e1 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101ee0:	6a 06                	push   $0x6
f0101ee2:	68 00 10 00 00       	push   $0x1000
f0101ee7:	56                   	push   %esi
f0101ee8:	ff 35 9c ce 2a f0    	pushl  0xf02ace9c
f0101eee:	e8 a0 f5 ff ff       	call   f0101493 <page_insert>
f0101ef3:	83 c4 10             	add    $0x10,%esp
f0101ef6:	85 c0                	test   %eax,%eax
f0101ef8:	74 19                	je     f0101f13 <mem_init+0x990>
f0101efa:	68 d0 7b 10 f0       	push   $0xf0107bd0
f0101eff:	68 25 74 10 f0       	push   $0xf0107425
f0101f04:	68 8c 04 00 00       	push   $0x48c
f0101f09:	68 ff 73 10 f0       	push   $0xf01073ff
f0101f0e:	e8 2d e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f13:	8b 3d 9c ce 2a f0    	mov    0xf02ace9c,%edi
f0101f19:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f1e:	89 f8                	mov    %edi,%eax
f0101f20:	e8 5f ec ff ff       	call   f0100b84 <check_va2pa>
f0101f25:	89 f2                	mov    %esi,%edx
f0101f27:	2b 15 a0 ce 2a f0    	sub    0xf02acea0,%edx
f0101f2d:	c1 fa 03             	sar    $0x3,%edx
f0101f30:	c1 e2 0c             	shl    $0xc,%edx
f0101f33:	39 d0                	cmp    %edx,%eax
f0101f35:	74 19                	je     f0101f50 <mem_init+0x9cd>
f0101f37:	68 60 7b 10 f0       	push   $0xf0107b60
f0101f3c:	68 25 74 10 f0       	push   $0xf0107425
f0101f41:	68 8d 04 00 00       	push   $0x48d
f0101f46:	68 ff 73 10 f0       	push   $0xf01073ff
f0101f4b:	e8 f0 e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101f50:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101f55:	74 19                	je     f0101f70 <mem_init+0x9ed>
f0101f57:	68 66 76 10 f0       	push   $0xf0107666
f0101f5c:	68 25 74 10 f0       	push   $0xf0107425
f0101f61:	68 8e 04 00 00       	push   $0x48e
f0101f66:	68 ff 73 10 f0       	push   $0xf01073ff
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
f0101f88:	68 10 7c 10 f0       	push   $0xf0107c10
f0101f8d:	68 25 74 10 f0       	push   $0xf0107425
f0101f92:	68 8f 04 00 00       	push   $0x48f
f0101f97:	68 ff 73 10 f0       	push   $0xf01073ff
f0101f9c:	e8 9f e0 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101fa1:	a1 9c ce 2a f0       	mov    0xf02ace9c,%eax
f0101fa6:	f6 00 04             	testb  $0x4,(%eax)
f0101fa9:	75 19                	jne    f0101fc4 <mem_init+0xa41>
f0101fab:	68 77 76 10 f0       	push   $0xf0107677
f0101fb0:	68 25 74 10 f0       	push   $0xf0107425
f0101fb5:	68 90 04 00 00       	push   $0x490
f0101fba:	68 ff 73 10 f0       	push   $0xf01073ff
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
f0101fd9:	68 24 7b 10 f0       	push   $0xf0107b24
f0101fde:	68 25 74 10 f0       	push   $0xf0107425
f0101fe3:	68 93 04 00 00       	push   $0x493
f0101fe8:	68 ff 73 10 f0       	push   $0xf01073ff
f0101fed:	e8 4e e0 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101ff2:	83 ec 04             	sub    $0x4,%esp
f0101ff5:	6a 00                	push   $0x0
f0101ff7:	68 00 10 00 00       	push   $0x1000
f0101ffc:	ff 35 9c ce 2a f0    	pushl  0xf02ace9c
f0102002:	e8 87 f1 ff ff       	call   f010118e <pgdir_walk>
f0102007:	83 c4 10             	add    $0x10,%esp
f010200a:	f6 00 02             	testb  $0x2,(%eax)
f010200d:	75 19                	jne    f0102028 <mem_init+0xaa5>
f010200f:	68 44 7c 10 f0       	push   $0xf0107c44
f0102014:	68 25 74 10 f0       	push   $0xf0107425
f0102019:	68 94 04 00 00       	push   $0x494
f010201e:	68 ff 73 10 f0       	push   $0xf01073ff
f0102023:	e8 18 e0 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102028:	83 ec 04             	sub    $0x4,%esp
f010202b:	6a 00                	push   $0x0
f010202d:	68 00 10 00 00       	push   $0x1000
f0102032:	ff 35 9c ce 2a f0    	pushl  0xf02ace9c
f0102038:	e8 51 f1 ff ff       	call   f010118e <pgdir_walk>
f010203d:	83 c4 10             	add    $0x10,%esp
f0102040:	f6 00 04             	testb  $0x4,(%eax)
f0102043:	74 19                	je     f010205e <mem_init+0xadb>
f0102045:	68 78 7c 10 f0       	push   $0xf0107c78
f010204a:	68 25 74 10 f0       	push   $0xf0107425
f010204f:	68 95 04 00 00       	push   $0x495
f0102054:	68 ff 73 10 f0       	push   $0xf01073ff
f0102059:	e8 e2 df ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f010205e:	6a 02                	push   $0x2
f0102060:	68 00 00 40 00       	push   $0x400000
f0102065:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102068:	ff 35 9c ce 2a f0    	pushl  0xf02ace9c
f010206e:	e8 20 f4 ff ff       	call   f0101493 <page_insert>
f0102073:	83 c4 10             	add    $0x10,%esp
f0102076:	85 c0                	test   %eax,%eax
f0102078:	78 19                	js     f0102093 <mem_init+0xb10>
f010207a:	68 b0 7c 10 f0       	push   $0xf0107cb0
f010207f:	68 25 74 10 f0       	push   $0xf0107425
f0102084:	68 98 04 00 00       	push   $0x498
f0102089:	68 ff 73 10 f0       	push   $0xf01073ff
f010208e:	e8 ad df ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102093:	6a 02                	push   $0x2
f0102095:	68 00 10 00 00       	push   $0x1000
f010209a:	53                   	push   %ebx
f010209b:	ff 35 9c ce 2a f0    	pushl  0xf02ace9c
f01020a1:	e8 ed f3 ff ff       	call   f0101493 <page_insert>
f01020a6:	83 c4 10             	add    $0x10,%esp
f01020a9:	85 c0                	test   %eax,%eax
f01020ab:	74 19                	je     f01020c6 <mem_init+0xb43>
f01020ad:	68 e8 7c 10 f0       	push   $0xf0107ce8
f01020b2:	68 25 74 10 f0       	push   $0xf0107425
f01020b7:	68 9b 04 00 00       	push   $0x49b
f01020bc:	68 ff 73 10 f0       	push   $0xf01073ff
f01020c1:	e8 7a df ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01020c6:	83 ec 04             	sub    $0x4,%esp
f01020c9:	6a 00                	push   $0x0
f01020cb:	68 00 10 00 00       	push   $0x1000
f01020d0:	ff 35 9c ce 2a f0    	pushl  0xf02ace9c
f01020d6:	e8 b3 f0 ff ff       	call   f010118e <pgdir_walk>
f01020db:	83 c4 10             	add    $0x10,%esp
f01020de:	f6 00 04             	testb  $0x4,(%eax)
f01020e1:	74 19                	je     f01020fc <mem_init+0xb79>
f01020e3:	68 78 7c 10 f0       	push   $0xf0107c78
f01020e8:	68 25 74 10 f0       	push   $0xf0107425
f01020ed:	68 9c 04 00 00       	push   $0x49c
f01020f2:	68 ff 73 10 f0       	push   $0xf01073ff
f01020f7:	e8 44 df ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01020fc:	8b 3d 9c ce 2a f0    	mov    0xf02ace9c,%edi
f0102102:	ba 00 00 00 00       	mov    $0x0,%edx
f0102107:	89 f8                	mov    %edi,%eax
f0102109:	e8 76 ea ff ff       	call   f0100b84 <check_va2pa>
f010210e:	89 c1                	mov    %eax,%ecx
f0102110:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102113:	89 d8                	mov    %ebx,%eax
f0102115:	2b 05 a0 ce 2a f0    	sub    0xf02acea0,%eax
f010211b:	c1 f8 03             	sar    $0x3,%eax
f010211e:	c1 e0 0c             	shl    $0xc,%eax
f0102121:	39 c1                	cmp    %eax,%ecx
f0102123:	74 19                	je     f010213e <mem_init+0xbbb>
f0102125:	68 24 7d 10 f0       	push   $0xf0107d24
f010212a:	68 25 74 10 f0       	push   $0xf0107425
f010212f:	68 9f 04 00 00       	push   $0x49f
f0102134:	68 ff 73 10 f0       	push   $0xf01073ff
f0102139:	e8 02 df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010213e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102143:	89 f8                	mov    %edi,%eax
f0102145:	e8 3a ea ff ff       	call   f0100b84 <check_va2pa>
f010214a:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f010214d:	74 19                	je     f0102168 <mem_init+0xbe5>
f010214f:	68 50 7d 10 f0       	push   $0xf0107d50
f0102154:	68 25 74 10 f0       	push   $0xf0107425
f0102159:	68 a0 04 00 00       	push   $0x4a0
f010215e:	68 ff 73 10 f0       	push   $0xf01073ff
f0102163:	e8 d8 de ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102168:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f010216d:	74 19                	je     f0102188 <mem_init+0xc05>
f010216f:	68 8d 76 10 f0       	push   $0xf010768d
f0102174:	68 25 74 10 f0       	push   $0xf0107425
f0102179:	68 a2 04 00 00       	push   $0x4a2
f010217e:	68 ff 73 10 f0       	push   $0xf01073ff
f0102183:	e8 b8 de ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102188:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010218d:	74 19                	je     f01021a8 <mem_init+0xc25>
f010218f:	68 9e 76 10 f0       	push   $0xf010769e
f0102194:	68 25 74 10 f0       	push   $0xf0107425
f0102199:	68 a3 04 00 00       	push   $0x4a3
f010219e:	68 ff 73 10 f0       	push   $0xf01073ff
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
f01021bd:	68 80 7d 10 f0       	push   $0xf0107d80
f01021c2:	68 25 74 10 f0       	push   $0xf0107425
f01021c7:	68 a6 04 00 00       	push   $0x4a6
f01021cc:	68 ff 73 10 f0       	push   $0xf01073ff
f01021d1:	e8 6a de ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01021d6:	83 ec 08             	sub    $0x8,%esp
f01021d9:	6a 00                	push   $0x0
f01021db:	ff 35 9c ce 2a f0    	pushl  0xf02ace9c
f01021e1:	e8 60 f2 ff ff       	call   f0101446 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01021e6:	8b 3d 9c ce 2a f0    	mov    0xf02ace9c,%edi
f01021ec:	ba 00 00 00 00       	mov    $0x0,%edx
f01021f1:	89 f8                	mov    %edi,%eax
f01021f3:	e8 8c e9 ff ff       	call   f0100b84 <check_va2pa>
f01021f8:	83 c4 10             	add    $0x10,%esp
f01021fb:	83 f8 ff             	cmp    $0xffffffff,%eax
f01021fe:	74 19                	je     f0102219 <mem_init+0xc96>
f0102200:	68 a4 7d 10 f0       	push   $0xf0107da4
f0102205:	68 25 74 10 f0       	push   $0xf0107425
f010220a:	68 aa 04 00 00       	push   $0x4aa
f010220f:	68 ff 73 10 f0       	push   $0xf01073ff
f0102214:	e8 27 de ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102219:	ba 00 10 00 00       	mov    $0x1000,%edx
f010221e:	89 f8                	mov    %edi,%eax
f0102220:	e8 5f e9 ff ff       	call   f0100b84 <check_va2pa>
f0102225:	89 da                	mov    %ebx,%edx
f0102227:	2b 15 a0 ce 2a f0    	sub    0xf02acea0,%edx
f010222d:	c1 fa 03             	sar    $0x3,%edx
f0102230:	c1 e2 0c             	shl    $0xc,%edx
f0102233:	39 d0                	cmp    %edx,%eax
f0102235:	74 19                	je     f0102250 <mem_init+0xccd>
f0102237:	68 50 7d 10 f0       	push   $0xf0107d50
f010223c:	68 25 74 10 f0       	push   $0xf0107425
f0102241:	68 ab 04 00 00       	push   $0x4ab
f0102246:	68 ff 73 10 f0       	push   $0xf01073ff
f010224b:	e8 f0 dd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102250:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102255:	74 19                	je     f0102270 <mem_init+0xced>
f0102257:	68 44 76 10 f0       	push   $0xf0107644
f010225c:	68 25 74 10 f0       	push   $0xf0107425
f0102261:	68 ac 04 00 00       	push   $0x4ac
f0102266:	68 ff 73 10 f0       	push   $0xf01073ff
f010226b:	e8 d0 dd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102270:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102275:	74 19                	je     f0102290 <mem_init+0xd0d>
f0102277:	68 9e 76 10 f0       	push   $0xf010769e
f010227c:	68 25 74 10 f0       	push   $0xf0107425
f0102281:	68 ad 04 00 00       	push   $0x4ad
f0102286:	68 ff 73 10 f0       	push   $0xf01073ff
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
f01022a5:	68 c8 7d 10 f0       	push   $0xf0107dc8
f01022aa:	68 25 74 10 f0       	push   $0xf0107425
f01022af:	68 b0 04 00 00       	push   $0x4b0
f01022b4:	68 ff 73 10 f0       	push   $0xf01073ff
f01022b9:	e8 82 dd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f01022be:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01022c3:	75 19                	jne    f01022de <mem_init+0xd5b>
f01022c5:	68 af 76 10 f0       	push   $0xf01076af
f01022ca:	68 25 74 10 f0       	push   $0xf0107425
f01022cf:	68 b1 04 00 00       	push   $0x4b1
f01022d4:	68 ff 73 10 f0       	push   $0xf01073ff
f01022d9:	e8 62 dd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f01022de:	83 3b 00             	cmpl   $0x0,(%ebx)
f01022e1:	74 19                	je     f01022fc <mem_init+0xd79>
f01022e3:	68 bb 76 10 f0       	push   $0xf01076bb
f01022e8:	68 25 74 10 f0       	push   $0xf0107425
f01022ed:	68 b2 04 00 00       	push   $0x4b2
f01022f2:	68 ff 73 10 f0       	push   $0xf01073ff
f01022f7:	e8 44 dd ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01022fc:	83 ec 08             	sub    $0x8,%esp
f01022ff:	68 00 10 00 00       	push   $0x1000
f0102304:	ff 35 9c ce 2a f0    	pushl  0xf02ace9c
f010230a:	e8 37 f1 ff ff       	call   f0101446 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010230f:	8b 3d 9c ce 2a f0    	mov    0xf02ace9c,%edi
f0102315:	ba 00 00 00 00       	mov    $0x0,%edx
f010231a:	89 f8                	mov    %edi,%eax
f010231c:	e8 63 e8 ff ff       	call   f0100b84 <check_va2pa>
f0102321:	83 c4 10             	add    $0x10,%esp
f0102324:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102327:	74 19                	je     f0102342 <mem_init+0xdbf>
f0102329:	68 a4 7d 10 f0       	push   $0xf0107da4
f010232e:	68 25 74 10 f0       	push   $0xf0107425
f0102333:	68 b6 04 00 00       	push   $0x4b6
f0102338:	68 ff 73 10 f0       	push   $0xf01073ff
f010233d:	e8 fe dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102342:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102347:	89 f8                	mov    %edi,%eax
f0102349:	e8 36 e8 ff ff       	call   f0100b84 <check_va2pa>
f010234e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102351:	74 19                	je     f010236c <mem_init+0xde9>
f0102353:	68 00 7e 10 f0       	push   $0xf0107e00
f0102358:	68 25 74 10 f0       	push   $0xf0107425
f010235d:	68 b7 04 00 00       	push   $0x4b7
f0102362:	68 ff 73 10 f0       	push   $0xf01073ff
f0102367:	e8 d4 dc ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f010236c:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102371:	74 19                	je     f010238c <mem_init+0xe09>
f0102373:	68 d0 76 10 f0       	push   $0xf01076d0
f0102378:	68 25 74 10 f0       	push   $0xf0107425
f010237d:	68 b8 04 00 00       	push   $0x4b8
f0102382:	68 ff 73 10 f0       	push   $0xf01073ff
f0102387:	e8 b4 dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010238c:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102391:	74 19                	je     f01023ac <mem_init+0xe29>
f0102393:	68 9e 76 10 f0       	push   $0xf010769e
f0102398:	68 25 74 10 f0       	push   $0xf0107425
f010239d:	68 b9 04 00 00       	push   $0x4b9
f01023a2:	68 ff 73 10 f0       	push   $0xf01073ff
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
f01023c1:	68 28 7e 10 f0       	push   $0xf0107e28
f01023c6:	68 25 74 10 f0       	push   $0xf0107425
f01023cb:	68 bc 04 00 00       	push   $0x4bc
f01023d0:	68 ff 73 10 f0       	push   $0xf01073ff
f01023d5:	e8 66 dc ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01023da:	83 ec 0c             	sub    $0xc,%esp
f01023dd:	6a 00                	push   $0x0
f01023df:	e8 bc ec ff ff       	call   f01010a0 <page_alloc>
f01023e4:	83 c4 10             	add    $0x10,%esp
f01023e7:	85 c0                	test   %eax,%eax
f01023e9:	74 19                	je     f0102404 <mem_init+0xe81>
f01023eb:	68 f2 75 10 f0       	push   $0xf01075f2
f01023f0:	68 25 74 10 f0       	push   $0xf0107425
f01023f5:	68 bf 04 00 00       	push   $0x4bf
f01023fa:	68 ff 73 10 f0       	push   $0xf01073ff
f01023ff:	e8 3c dc ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102404:	8b 0d 9c ce 2a f0    	mov    0xf02ace9c,%ecx
f010240a:	8b 11                	mov    (%ecx),%edx
f010240c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102412:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102415:	2b 05 a0 ce 2a f0    	sub    0xf02acea0,%eax
f010241b:	c1 f8 03             	sar    $0x3,%eax
f010241e:	c1 e0 0c             	shl    $0xc,%eax
f0102421:	39 c2                	cmp    %eax,%edx
f0102423:	74 19                	je     f010243e <mem_init+0xebb>
f0102425:	68 cc 7a 10 f0       	push   $0xf0107acc
f010242a:	68 25 74 10 f0       	push   $0xf0107425
f010242f:	68 c2 04 00 00       	push   $0x4c2
f0102434:	68 ff 73 10 f0       	push   $0xf01073ff
f0102439:	e8 02 dc ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f010243e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102444:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102447:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010244c:	74 19                	je     f0102467 <mem_init+0xee4>
f010244e:	68 55 76 10 f0       	push   $0xf0107655
f0102453:	68 25 74 10 f0       	push   $0xf0107425
f0102458:	68 c4 04 00 00       	push   $0x4c4
f010245d:	68 ff 73 10 f0       	push   $0xf01073ff
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
f0102483:	ff 35 9c ce 2a f0    	pushl  0xf02ace9c
f0102489:	e8 00 ed ff ff       	call   f010118e <pgdir_walk>
f010248e:	89 c7                	mov    %eax,%edi
f0102490:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102493:	a1 9c ce 2a f0       	mov    0xf02ace9c,%eax
f0102498:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010249b:	8b 40 04             	mov    0x4(%eax),%eax
f010249e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01024a3:	8b 0d 98 ce 2a f0    	mov    0xf02ace98,%ecx
f01024a9:	89 c2                	mov    %eax,%edx
f01024ab:	c1 ea 0c             	shr    $0xc,%edx
f01024ae:	83 c4 10             	add    $0x10,%esp
f01024b1:	39 ca                	cmp    %ecx,%edx
f01024b3:	72 15                	jb     f01024ca <mem_init+0xf47>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024b5:	50                   	push   %eax
f01024b6:	68 44 6e 10 f0       	push   $0xf0106e44
f01024bb:	68 cb 04 00 00       	push   $0x4cb
f01024c0:	68 ff 73 10 f0       	push   $0xf01073ff
f01024c5:	e8 76 db ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01024ca:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f01024cf:	39 c7                	cmp    %eax,%edi
f01024d1:	74 19                	je     f01024ec <mem_init+0xf69>
f01024d3:	68 e1 76 10 f0       	push   $0xf01076e1
f01024d8:	68 25 74 10 f0       	push   $0xf0107425
f01024dd:	68 cc 04 00 00       	push   $0x4cc
f01024e2:	68 ff 73 10 f0       	push   $0xf01073ff
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
f01024ff:	2b 05 a0 ce 2a f0    	sub    0xf02acea0,%eax
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
f0102515:	68 44 6e 10 f0       	push   $0xf0106e44
f010251a:	6a 58                	push   $0x58
f010251c:	68 0b 74 10 f0       	push   $0xf010740b
f0102521:	e8 1a db ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102526:	83 ec 04             	sub    $0x4,%esp
f0102529:	68 00 10 00 00       	push   $0x1000
f010252e:	68 ff 00 00 00       	push   $0xff
f0102533:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102538:	50                   	push   %eax
f0102539:	e8 b1 32 00 00       	call   f01057ef <memset>
	page_free(pp0);
f010253e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102541:	89 3c 24             	mov    %edi,(%esp)
f0102544:	e8 c8 eb ff ff       	call   f0101111 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102549:	83 c4 0c             	add    $0xc,%esp
f010254c:	6a 01                	push   $0x1
f010254e:	6a 00                	push   $0x0
f0102550:	ff 35 9c ce 2a f0    	pushl  0xf02ace9c
f0102556:	e8 33 ec ff ff       	call   f010118e <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010255b:	89 fa                	mov    %edi,%edx
f010255d:	2b 15 a0 ce 2a f0    	sub    0xf02acea0,%edx
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
f0102571:	3b 05 98 ce 2a f0    	cmp    0xf02ace98,%eax
f0102577:	72 12                	jb     f010258b <mem_init+0x1008>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102579:	52                   	push   %edx
f010257a:	68 44 6e 10 f0       	push   $0xf0106e44
f010257f:	6a 58                	push   $0x58
f0102581:	68 0b 74 10 f0       	push   $0xf010740b
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
f010259f:	68 f9 76 10 f0       	push   $0xf01076f9
f01025a4:	68 25 74 10 f0       	push   $0xf0107425
f01025a9:	68 d6 04 00 00       	push   $0x4d6
f01025ae:	68 ff 73 10 f0       	push   $0xf01073ff
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
f01025bf:	a1 9c ce 2a f0       	mov    0xf02ace9c,%eax
f01025c4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01025ca:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01025cd:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f01025d3:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01025d6:	89 0d 40 c2 2a f0    	mov    %ecx,0xf02ac240

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
f010262f:	68 4c 7e 10 f0       	push   $0xf0107e4c
f0102634:	68 25 74 10 f0       	push   $0xf0107425
f0102639:	68 e6 04 00 00       	push   $0x4e6
f010263e:	68 ff 73 10 f0       	push   $0xf01073ff
f0102643:	e8 f8 d9 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f0102648:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
f010264e:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102654:	77 08                	ja     f010265e <mem_init+0x10db>
f0102656:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010265c:	77 19                	ja     f0102677 <mem_init+0x10f4>
f010265e:	68 74 7e 10 f0       	push   $0xf0107e74
f0102663:	68 25 74 10 f0       	push   $0xf0107425
f0102668:	68 e7 04 00 00       	push   $0x4e7
f010266d:	68 ff 73 10 f0       	push   $0xf01073ff
f0102672:	e8 c9 d9 ff ff       	call   f0100040 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102677:	89 da                	mov    %ebx,%edx
f0102679:	09 f2                	or     %esi,%edx
f010267b:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102681:	74 19                	je     f010269c <mem_init+0x1119>
f0102683:	68 9c 7e 10 f0       	push   $0xf0107e9c
f0102688:	68 25 74 10 f0       	push   $0xf0107425
f010268d:	68 e9 04 00 00       	push   $0x4e9
f0102692:	68 ff 73 10 f0       	push   $0xf01073ff
f0102697:	e8 a4 d9 ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8192 <= mm2);
f010269c:	39 c6                	cmp    %eax,%esi
f010269e:	73 19                	jae    f01026b9 <mem_init+0x1136>
f01026a0:	68 10 77 10 f0       	push   $0xf0107710
f01026a5:	68 25 74 10 f0       	push   $0xf0107425
f01026aa:	68 eb 04 00 00       	push   $0x4eb
f01026af:	68 ff 73 10 f0       	push   $0xf01073ff
f01026b4:	e8 87 d9 ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01026b9:	8b 3d 9c ce 2a f0    	mov    0xf02ace9c,%edi
f01026bf:	89 da                	mov    %ebx,%edx
f01026c1:	89 f8                	mov    %edi,%eax
f01026c3:	e8 bc e4 ff ff       	call   f0100b84 <check_va2pa>
f01026c8:	85 c0                	test   %eax,%eax
f01026ca:	74 19                	je     f01026e5 <mem_init+0x1162>
f01026cc:	68 c4 7e 10 f0       	push   $0xf0107ec4
f01026d1:	68 25 74 10 f0       	push   $0xf0107425
f01026d6:	68 ed 04 00 00       	push   $0x4ed
f01026db:	68 ff 73 10 f0       	push   $0xf01073ff
f01026e0:	e8 5b d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01026e5:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f01026eb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01026ee:	89 c2                	mov    %eax,%edx
f01026f0:	89 f8                	mov    %edi,%eax
f01026f2:	e8 8d e4 ff ff       	call   f0100b84 <check_va2pa>
f01026f7:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01026fc:	74 19                	je     f0102717 <mem_init+0x1194>
f01026fe:	68 e8 7e 10 f0       	push   $0xf0107ee8
f0102703:	68 25 74 10 f0       	push   $0xf0107425
f0102708:	68 ee 04 00 00       	push   $0x4ee
f010270d:	68 ff 73 10 f0       	push   $0xf01073ff
f0102712:	e8 29 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102717:	89 f2                	mov    %esi,%edx
f0102719:	89 f8                	mov    %edi,%eax
f010271b:	e8 64 e4 ff ff       	call   f0100b84 <check_va2pa>
f0102720:	85 c0                	test   %eax,%eax
f0102722:	74 19                	je     f010273d <mem_init+0x11ba>
f0102724:	68 18 7f 10 f0       	push   $0xf0107f18
f0102729:	68 25 74 10 f0       	push   $0xf0107425
f010272e:	68 ef 04 00 00       	push   $0x4ef
f0102733:	68 ff 73 10 f0       	push   $0xf01073ff
f0102738:	e8 03 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f010273d:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102743:	89 f8                	mov    %edi,%eax
f0102745:	e8 3a e4 ff ff       	call   f0100b84 <check_va2pa>
f010274a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010274d:	74 19                	je     f0102768 <mem_init+0x11e5>
f010274f:	68 3c 7f 10 f0       	push   $0xf0107f3c
f0102754:	68 25 74 10 f0       	push   $0xf0107425
f0102759:	68 f0 04 00 00       	push   $0x4f0
f010275e:	68 ff 73 10 f0       	push   $0xf01073ff
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
f010277c:	68 68 7f 10 f0       	push   $0xf0107f68
f0102781:	68 25 74 10 f0       	push   $0xf0107425
f0102786:	68 f2 04 00 00       	push   $0x4f2
f010278b:	68 ff 73 10 f0       	push   $0xf01073ff
f0102790:	e8 ab d8 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102795:	83 ec 04             	sub    $0x4,%esp
f0102798:	6a 00                	push   $0x0
f010279a:	53                   	push   %ebx
f010279b:	ff 35 9c ce 2a f0    	pushl  0xf02ace9c
f01027a1:	e8 e8 e9 ff ff       	call   f010118e <pgdir_walk>
f01027a6:	8b 00                	mov    (%eax),%eax
f01027a8:	83 c4 10             	add    $0x10,%esp
f01027ab:	83 e0 04             	and    $0x4,%eax
f01027ae:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01027b1:	74 19                	je     f01027cc <mem_init+0x1249>
f01027b3:	68 ac 7f 10 f0       	push   $0xf0107fac
f01027b8:	68 25 74 10 f0       	push   $0xf0107425
f01027bd:	68 f3 04 00 00       	push   $0x4f3
f01027c2:	68 ff 73 10 f0       	push   $0xf01073ff
f01027c7:	e8 74 d8 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f01027cc:	83 ec 04             	sub    $0x4,%esp
f01027cf:	6a 00                	push   $0x0
f01027d1:	53                   	push   %ebx
f01027d2:	ff 35 9c ce 2a f0    	pushl  0xf02ace9c
f01027d8:	e8 b1 e9 ff ff       	call   f010118e <pgdir_walk>
f01027dd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f01027e3:	83 c4 0c             	add    $0xc,%esp
f01027e6:	6a 00                	push   $0x0
f01027e8:	ff 75 d4             	pushl  -0x2c(%ebp)
f01027eb:	ff 35 9c ce 2a f0    	pushl  0xf02ace9c
f01027f1:	e8 98 e9 ff ff       	call   f010118e <pgdir_walk>
f01027f6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f01027fc:	83 c4 0c             	add    $0xc,%esp
f01027ff:	6a 00                	push   $0x0
f0102801:	56                   	push   %esi
f0102802:	ff 35 9c ce 2a f0    	pushl  0xf02ace9c
f0102808:	e8 81 e9 ff ff       	call   f010118e <pgdir_walk>
f010280d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102813:	c7 04 24 22 77 10 f0 	movl   $0xf0107722,(%esp)
f010281a:	e8 72 11 00 00       	call   f0103991 <cprintf>
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f010281f:	a1 a0 ce 2a f0       	mov    0xf02acea0,%eax
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
f010282f:	68 68 6e 10 f0       	push   $0xf0106e68
f0102834:	68 ca 00 00 00       	push   $0xca
f0102839:	68 ff 73 10 f0       	push   $0xf01073ff
f010283e:	e8 fd d7 ff ff       	call   f0100040 <_panic>
f0102843:	83 ec 08             	sub    $0x8,%esp
f0102846:	6a 04                	push   $0x4
f0102848:	05 00 00 00 10       	add    $0x10000000,%eax
f010284d:	50                   	push   %eax
f010284e:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102853:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102858:	a1 9c ce 2a f0       	mov    0xf02ace9c,%eax
f010285d:	e8 76 ea ff ff       	call   f01012d8 <boot_map_region>
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.

	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U);
f0102862:	a1 48 c2 2a f0       	mov    0xf02ac248,%eax
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
f0102872:	68 68 6e 10 f0       	push   $0xf0106e68
f0102877:	68 d4 00 00 00       	push   $0xd4
f010287c:	68 ff 73 10 f0       	push   $0xf01073ff
f0102881:	e8 ba d7 ff ff       	call   f0100040 <_panic>
f0102886:	83 ec 08             	sub    $0x8,%esp
f0102889:	6a 04                	push   $0x4
f010288b:	05 00 00 00 10       	add    $0x10000000,%eax
f0102890:	50                   	push   %eax
f0102891:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102896:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f010289b:	a1 9c ce 2a f0       	mov    0xf02ace9c,%eax
f01028a0:	e8 33 ea ff ff       	call   f01012d8 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01028a5:	83 c4 10             	add    $0x10,%esp
f01028a8:	b8 00 a0 11 f0       	mov    $0xf011a000,%eax
f01028ad:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01028b2:	77 15                	ja     f01028c9 <mem_init+0x1346>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01028b4:	50                   	push   %eax
f01028b5:	68 68 6e 10 f0       	push   $0xf0106e68
f01028ba:	68 e2 00 00 00       	push   $0xe2
f01028bf:	68 ff 73 10 f0       	push   $0xf01073ff
f01028c4:	e8 77 d7 ff ff       	call   f0100040 <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f01028c9:	83 ec 08             	sub    $0x8,%esp
f01028cc:	6a 02                	push   $0x2
f01028ce:	68 00 a0 11 00       	push   $0x11a000
f01028d3:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01028d8:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01028dd:	a1 9c ce 2a f0       	mov    0xf02ace9c,%eax
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
f01028f8:	a1 9c ce 2a f0       	mov    0xf02ace9c,%eax
f01028fd:	e8 d6 e9 ff ff       	call   f01012d8 <boot_map_region>
f0102902:	c7 45 c4 00 e0 2a f0 	movl   $0xf02ae000,-0x3c(%ebp)
f0102909:	83 c4 10             	add    $0x10,%esp
f010290c:	bb 00 e0 2a f0       	mov    $0xf02ae000,%ebx
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
f010291f:	68 68 6e 10 f0       	push   $0xf0106e68
f0102924:	68 26 01 00 00       	push   $0x126
f0102929:	68 ff 73 10 f0       	push   $0xf01073ff
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
f0102946:	a1 9c ce 2a f0       	mov    0xf02ace9c,%eax
f010294b:	e8 88 e9 ff ff       	call   f01012d8 <boot_map_region>
f0102950:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102956:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//
	// LAB 4: Your code here:

	uint32_t kstacktop_i;

	for (int i=0; i<NCPU; i++) {
f010295c:	83 c4 10             	add    $0x10,%esp
f010295f:	b8 00 e0 2e f0       	mov    $0xf02ee000,%eax
f0102964:	39 d8                	cmp    %ebx,%eax
f0102966:	75 ae                	jne    f0102916 <mem_init+0x1393>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102968:	8b 3d 9c ce 2a f0    	mov    0xf02ace9c,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010296e:	a1 98 ce 2a f0       	mov    0xf02ace98,%eax
f0102973:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102976:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f010297d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102982:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102985:	8b 35 a0 ce 2a f0    	mov    0xf02acea0,%esi
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
f01029ac:	68 68 6e 10 f0       	push   $0xf0106e68
f01029b1:	68 07 04 00 00       	push   $0x407
f01029b6:	68 ff 73 10 f0       	push   $0xf01073ff
f01029bb:	e8 80 d6 ff ff       	call   f0100040 <_panic>
f01029c0:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f01029c7:	39 c2                	cmp    %eax,%edx
f01029c9:	74 19                	je     f01029e4 <mem_init+0x1461>
f01029cb:	68 e0 7f 10 f0       	push   $0xf0107fe0
f01029d0:	68 25 74 10 f0       	push   $0xf0107425
f01029d5:	68 07 04 00 00       	push   $0x407
f01029da:	68 ff 73 10 f0       	push   $0xf01073ff
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
f01029ef:	8b 35 48 c2 2a f0    	mov    0xf02ac248,%esi
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
f0102a10:	68 68 6e 10 f0       	push   $0xf0106e68
f0102a15:	68 0c 04 00 00       	push   $0x40c
f0102a1a:	68 ff 73 10 f0       	push   $0xf01073ff
f0102a1f:	e8 1c d6 ff ff       	call   f0100040 <_panic>
f0102a24:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f0102a2b:	39 d0                	cmp    %edx,%eax
f0102a2d:	74 19                	je     f0102a48 <mem_init+0x14c5>
f0102a2f:	68 14 80 10 f0       	push   $0xf0108014
f0102a34:	68 25 74 10 f0       	push   $0xf0107425
f0102a39:	68 0c 04 00 00       	push   $0x40c
f0102a3e:	68 ff 73 10 f0       	push   $0xf01073ff
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
f0102a74:	68 48 80 10 f0       	push   $0xf0108048
f0102a79:	68 25 74 10 f0       	push   $0xf0107425
f0102a7e:	68 10 04 00 00       	push   $0x410
f0102a83:	68 ff 73 10 f0       	push   $0xf01073ff
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
f0102acd:	68 68 6e 10 f0       	push   $0xf0106e68
f0102ad2:	68 18 04 00 00       	push   $0x418
f0102ad7:	68 ff 73 10 f0       	push   $0xf01073ff
f0102adc:	e8 5f d5 ff ff       	call   f0100040 <_panic>
f0102ae1:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102ae4:	8d 94 0b 00 e0 2a f0 	lea    -0xfd52000(%ebx,%ecx,1),%edx
f0102aeb:	39 d0                	cmp    %edx,%eax
f0102aed:	74 19                	je     f0102b08 <mem_init+0x1585>
f0102aef:	68 70 80 10 f0       	push   $0xf0108070
f0102af4:	68 25 74 10 f0       	push   $0xf0107425
f0102af9:	68 18 04 00 00       	push   $0x418
f0102afe:	68 ff 73 10 f0       	push   $0xf01073ff
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
f0102b2f:	68 b8 80 10 f0       	push   $0xf01080b8
f0102b34:	68 25 74 10 f0       	push   $0xf0107425
f0102b39:	68 1a 04 00 00       	push   $0x41a
f0102b3e:	68 ff 73 10 f0       	push   $0xf01073ff
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
f0102b69:	b8 00 e0 2e f0       	mov    $0xf02ee000,%eax
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
f0102b8e:	68 3b 77 10 f0       	push   $0xf010773b
f0102b93:	68 25 74 10 f0       	push   $0xf0107425
f0102b98:	68 25 04 00 00       	push   $0x425
f0102b9d:	68 ff 73 10 f0       	push   $0xf01073ff
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
f0102bb6:	68 3b 77 10 f0       	push   $0xf010773b
f0102bbb:	68 25 74 10 f0       	push   $0xf0107425
f0102bc0:	68 29 04 00 00       	push   $0x429
f0102bc5:	68 ff 73 10 f0       	push   $0xf01073ff
f0102bca:	e8 71 d4 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102bcf:	f6 c2 02             	test   $0x2,%dl
f0102bd2:	75 38                	jne    f0102c0c <mem_init+0x1689>
f0102bd4:	68 4c 77 10 f0       	push   $0xf010774c
f0102bd9:	68 25 74 10 f0       	push   $0xf0107425
f0102bde:	68 2a 04 00 00       	push   $0x42a
f0102be3:	68 ff 73 10 f0       	push   $0xf01073ff
f0102be8:	e8 53 d4 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102bed:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102bf1:	74 19                	je     f0102c0c <mem_init+0x1689>
f0102bf3:	68 5d 77 10 f0       	push   $0xf010775d
f0102bf8:	68 25 74 10 f0       	push   $0xf0107425
f0102bfd:	68 2c 04 00 00       	push   $0x42c
f0102c02:	68 ff 73 10 f0       	push   $0xf01073ff
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
f0102c1d:	68 dc 80 10 f0       	push   $0xf01080dc
f0102c22:	e8 6a 0d 00 00       	call   f0103991 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102c27:	a1 9c ce 2a f0       	mov    0xf02ace9c,%eax
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
f0102c37:	68 68 6e 10 f0       	push   $0xf0106e68
f0102c3c:	68 fc 00 00 00       	push   $0xfc
f0102c41:	68 ff 73 10 f0       	push   $0xf01073ff
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
f0102c7e:	68 47 75 10 f0       	push   $0xf0107547
f0102c83:	68 25 74 10 f0       	push   $0xf0107425
f0102c88:	68 08 05 00 00       	push   $0x508
f0102c8d:	68 ff 73 10 f0       	push   $0xf01073ff
f0102c92:	e8 a9 d3 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102c97:	83 ec 0c             	sub    $0xc,%esp
f0102c9a:	6a 00                	push   $0x0
f0102c9c:	e8 ff e3 ff ff       	call   f01010a0 <page_alloc>
f0102ca1:	89 c7                	mov    %eax,%edi
f0102ca3:	83 c4 10             	add    $0x10,%esp
f0102ca6:	85 c0                	test   %eax,%eax
f0102ca8:	75 19                	jne    f0102cc3 <mem_init+0x1740>
f0102caa:	68 5d 75 10 f0       	push   $0xf010755d
f0102caf:	68 25 74 10 f0       	push   $0xf0107425
f0102cb4:	68 09 05 00 00       	push   $0x509
f0102cb9:	68 ff 73 10 f0       	push   $0xf01073ff
f0102cbe:	e8 7d d3 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102cc3:	83 ec 0c             	sub    $0xc,%esp
f0102cc6:	6a 00                	push   $0x0
f0102cc8:	e8 d3 e3 ff ff       	call   f01010a0 <page_alloc>
f0102ccd:	89 c6                	mov    %eax,%esi
f0102ccf:	83 c4 10             	add    $0x10,%esp
f0102cd2:	85 c0                	test   %eax,%eax
f0102cd4:	75 19                	jne    f0102cef <mem_init+0x176c>
f0102cd6:	68 73 75 10 f0       	push   $0xf0107573
f0102cdb:	68 25 74 10 f0       	push   $0xf0107425
f0102ce0:	68 0a 05 00 00       	push   $0x50a
f0102ce5:	68 ff 73 10 f0       	push   $0xf01073ff
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
f0102cfa:	2b 05 a0 ce 2a f0    	sub    0xf02acea0,%eax
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
f0102d0e:	3b 15 98 ce 2a f0    	cmp    0xf02ace98,%edx
f0102d14:	72 12                	jb     f0102d28 <mem_init+0x17a5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d16:	50                   	push   %eax
f0102d17:	68 44 6e 10 f0       	push   $0xf0106e44
f0102d1c:	6a 58                	push   $0x58
f0102d1e:	68 0b 74 10 f0       	push   $0xf010740b
f0102d23:	e8 18 d3 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102d28:	83 ec 04             	sub    $0x4,%esp
f0102d2b:	68 00 10 00 00       	push   $0x1000
f0102d30:	6a 01                	push   $0x1
f0102d32:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102d37:	50                   	push   %eax
f0102d38:	e8 b2 2a 00 00       	call   f01057ef <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102d3d:	89 f0                	mov    %esi,%eax
f0102d3f:	2b 05 a0 ce 2a f0    	sub    0xf02acea0,%eax
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
f0102d53:	3b 15 98 ce 2a f0    	cmp    0xf02ace98,%edx
f0102d59:	72 12                	jb     f0102d6d <mem_init+0x17ea>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d5b:	50                   	push   %eax
f0102d5c:	68 44 6e 10 f0       	push   $0xf0106e44
f0102d61:	6a 58                	push   $0x58
f0102d63:	68 0b 74 10 f0       	push   $0xf010740b
f0102d68:	e8 d3 d2 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102d6d:	83 ec 04             	sub    $0x4,%esp
f0102d70:	68 00 10 00 00       	push   $0x1000
f0102d75:	6a 02                	push   $0x2
f0102d77:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102d7c:	50                   	push   %eax
f0102d7d:	e8 6d 2a 00 00       	call   f01057ef <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102d82:	6a 02                	push   $0x2
f0102d84:	68 00 10 00 00       	push   $0x1000
f0102d89:	57                   	push   %edi
f0102d8a:	ff 35 9c ce 2a f0    	pushl  0xf02ace9c
f0102d90:	e8 fe e6 ff ff       	call   f0101493 <page_insert>
	assert(pp1->pp_ref == 1);
f0102d95:	83 c4 20             	add    $0x20,%esp
f0102d98:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102d9d:	74 19                	je     f0102db8 <mem_init+0x1835>
f0102d9f:	68 44 76 10 f0       	push   $0xf0107644
f0102da4:	68 25 74 10 f0       	push   $0xf0107425
f0102da9:	68 0f 05 00 00       	push   $0x50f
f0102dae:	68 ff 73 10 f0       	push   $0xf01073ff
f0102db3:	e8 88 d2 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102db8:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102dbf:	01 01 01 
f0102dc2:	74 19                	je     f0102ddd <mem_init+0x185a>
f0102dc4:	68 fc 80 10 f0       	push   $0xf01080fc
f0102dc9:	68 25 74 10 f0       	push   $0xf0107425
f0102dce:	68 10 05 00 00       	push   $0x510
f0102dd3:	68 ff 73 10 f0       	push   $0xf01073ff
f0102dd8:	e8 63 d2 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102ddd:	6a 02                	push   $0x2
f0102ddf:	68 00 10 00 00       	push   $0x1000
f0102de4:	56                   	push   %esi
f0102de5:	ff 35 9c ce 2a f0    	pushl  0xf02ace9c
f0102deb:	e8 a3 e6 ff ff       	call   f0101493 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102df0:	83 c4 10             	add    $0x10,%esp
f0102df3:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102dfa:	02 02 02 
f0102dfd:	74 19                	je     f0102e18 <mem_init+0x1895>
f0102dff:	68 20 81 10 f0       	push   $0xf0108120
f0102e04:	68 25 74 10 f0       	push   $0xf0107425
f0102e09:	68 12 05 00 00       	push   $0x512
f0102e0e:	68 ff 73 10 f0       	push   $0xf01073ff
f0102e13:	e8 28 d2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102e18:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102e1d:	74 19                	je     f0102e38 <mem_init+0x18b5>
f0102e1f:	68 66 76 10 f0       	push   $0xf0107666
f0102e24:	68 25 74 10 f0       	push   $0xf0107425
f0102e29:	68 13 05 00 00       	push   $0x513
f0102e2e:	68 ff 73 10 f0       	push   $0xf01073ff
f0102e33:	e8 08 d2 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102e38:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102e3d:	74 19                	je     f0102e58 <mem_init+0x18d5>
f0102e3f:	68 d0 76 10 f0       	push   $0xf01076d0
f0102e44:	68 25 74 10 f0       	push   $0xf0107425
f0102e49:	68 14 05 00 00       	push   $0x514
f0102e4e:	68 ff 73 10 f0       	push   $0xf01073ff
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
f0102e64:	2b 05 a0 ce 2a f0    	sub    0xf02acea0,%eax
f0102e6a:	c1 f8 03             	sar    $0x3,%eax
f0102e6d:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102e70:	89 c2                	mov    %eax,%edx
f0102e72:	c1 ea 0c             	shr    $0xc,%edx
f0102e75:	3b 15 98 ce 2a f0    	cmp    0xf02ace98,%edx
f0102e7b:	72 12                	jb     f0102e8f <mem_init+0x190c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102e7d:	50                   	push   %eax
f0102e7e:	68 44 6e 10 f0       	push   $0xf0106e44
f0102e83:	6a 58                	push   $0x58
f0102e85:	68 0b 74 10 f0       	push   $0xf010740b
f0102e8a:	e8 b1 d1 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102e8f:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102e96:	03 03 03 
f0102e99:	74 19                	je     f0102eb4 <mem_init+0x1931>
f0102e9b:	68 44 81 10 f0       	push   $0xf0108144
f0102ea0:	68 25 74 10 f0       	push   $0xf0107425
f0102ea5:	68 16 05 00 00       	push   $0x516
f0102eaa:	68 ff 73 10 f0       	push   $0xf01073ff
f0102eaf:	e8 8c d1 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102eb4:	83 ec 08             	sub    $0x8,%esp
f0102eb7:	68 00 10 00 00       	push   $0x1000
f0102ebc:	ff 35 9c ce 2a f0    	pushl  0xf02ace9c
f0102ec2:	e8 7f e5 ff ff       	call   f0101446 <page_remove>
	assert(pp2->pp_ref == 0);
f0102ec7:	83 c4 10             	add    $0x10,%esp
f0102eca:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102ecf:	74 19                	je     f0102eea <mem_init+0x1967>
f0102ed1:	68 9e 76 10 f0       	push   $0xf010769e
f0102ed6:	68 25 74 10 f0       	push   $0xf0107425
f0102edb:	68 18 05 00 00       	push   $0x518
f0102ee0:	68 ff 73 10 f0       	push   $0xf01073ff
f0102ee5:	e8 56 d1 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102eea:	8b 0d 9c ce 2a f0    	mov    0xf02ace9c,%ecx
f0102ef0:	8b 11                	mov    (%ecx),%edx
f0102ef2:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102ef8:	89 d8                	mov    %ebx,%eax
f0102efa:	2b 05 a0 ce 2a f0    	sub    0xf02acea0,%eax
f0102f00:	c1 f8 03             	sar    $0x3,%eax
f0102f03:	c1 e0 0c             	shl    $0xc,%eax
f0102f06:	39 c2                	cmp    %eax,%edx
f0102f08:	74 19                	je     f0102f23 <mem_init+0x19a0>
f0102f0a:	68 cc 7a 10 f0       	push   $0xf0107acc
f0102f0f:	68 25 74 10 f0       	push   $0xf0107425
f0102f14:	68 1b 05 00 00       	push   $0x51b
f0102f19:	68 ff 73 10 f0       	push   $0xf01073ff
f0102f1e:	e8 1d d1 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102f23:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102f29:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102f2e:	74 19                	je     f0102f49 <mem_init+0x19c6>
f0102f30:	68 55 76 10 f0       	push   $0xf0107655
f0102f35:	68 25 74 10 f0       	push   $0xf0107425
f0102f3a:	68 1d 05 00 00       	push   $0x51d
f0102f3f:	68 ff 73 10 f0       	push   $0xf01073ff
f0102f44:	e8 f7 d0 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102f49:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102f4f:	83 ec 0c             	sub    $0xc,%esp
f0102f52:	53                   	push   %ebx
f0102f53:	e8 b9 e1 ff ff       	call   f0101111 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102f58:	c7 04 24 70 81 10 f0 	movl   $0xf0108170,(%esp)
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
f0102fb7:	a3 3c c2 2a f0       	mov    %eax,0xf02ac23c
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
f0102feb:	89 0d 3c c2 2a f0    	mov    %ecx,0xf02ac23c
			cprintf("[-] page [0x%x] error, %d, %d\n", (uint32_t)(*pte), ((uint32_t)(*pte) & perm), perm);
f0102ff1:	8b 00                	mov    (%eax),%eax
f0102ff3:	56                   	push   %esi
f0102ff4:	21 c6                	and    %eax,%esi
f0102ff6:	56                   	push   %esi
f0102ff7:	50                   	push   %eax
f0102ff8:	68 9c 81 10 f0       	push   $0xf010819c
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
f010301e:	89 0d 3c c2 2a f0    	mov    %ecx,0xf02ac23c
			cprintf("[-] page [0x%x] perf error, %d, %d\n", (uint32_t)(*pte), ((uint32_t)(*pte) & perm), perm);
f0103024:	56                   	push   %esi
f0103025:	50                   	push   %eax
f0103026:	52                   	push   %edx
f0103027:	68 bc 81 10 f0       	push   $0xf01081bc
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
f010307e:	ff 35 3c c2 2a f0    	pushl  0xf02ac23c
f0103084:	ff 73 48             	pushl  0x48(%ebx)
f0103087:	68 e0 81 10 f0       	push   $0xf01081e0
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
f01030d7:	68 18 82 10 f0       	push   $0xf0108218
f01030dc:	68 2d 01 00 00       	push   $0x12d
f01030e1:	68 dc 82 10 f0       	push   $0xf01082dc
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
f01030ff:	68 3c 82 10 f0       	push   $0xf010823c
f0103104:	68 32 01 00 00       	push   $0x132
f0103109:	68 dc 82 10 f0       	push   $0xf01082dc
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
f0103134:	e8 d9 2c 00 00       	call   f0105e12 <cpunum>
f0103139:	6b c0 74             	imul   $0x74,%eax,%eax
f010313c:	8b 80 28 d0 2a f0    	mov    -0xfd52fd8(%eax),%eax
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
f0103159:	03 1d 48 c2 2a f0    	add    0xf02ac248,%ebx
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
f010317e:	e8 8f 2c 00 00       	call   f0105e12 <cpunum>
f0103183:	6b c0 74             	imul   $0x74,%eax,%eax
f0103186:	3b 98 28 d0 2a f0    	cmp    -0xfd52fd8(%eax),%ebx
f010318c:	74 26                	je     f01031b4 <envid2env+0x8f>
f010318e:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0103191:	e8 7c 2c 00 00       	call   f0105e12 <cpunum>
f0103196:	6b c0 74             	imul   $0x74,%eax,%eax
f0103199:	8b 80 28 d0 2a f0    	mov    -0xfd52fd8(%eax),%eax
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
f01031c5:	b8 20 43 12 f0       	mov    $0xf0124320,%eax
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
f01031f7:	8b 35 48 c2 2a f0    	mov    0xf02ac248,%esi
f01031fd:	8b 15 4c c2 2a f0    	mov    0xf02ac24c,%edx
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
f0103221:	89 35 4c c2 2a f0    	mov    %esi,0xf02ac24c
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
f0103235:	8b 1d 4c c2 2a f0    	mov    0xf02ac24c,%ebx
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
f010325a:	2b 05 a0 ce 2a f0    	sub    0xf02acea0,%eax
f0103260:	c1 f8 03             	sar    $0x3,%eax
f0103263:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103266:	89 c2                	mov    %eax,%edx
f0103268:	c1 ea 0c             	shr    $0xc,%edx
f010326b:	3b 15 98 ce 2a f0    	cmp    0xf02ace98,%edx
f0103271:	72 12                	jb     f0103285 <env_alloc+0x55>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103273:	50                   	push   %eax
f0103274:	68 44 6e 10 f0       	push   $0xf0106e44
f0103279:	6a 58                	push   $0x58
f010327b:	68 0b 74 10 f0       	push   $0xf010740b
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
f0103295:	ff 35 9c ce 2a f0    	pushl  0xf02ace9c
f010329b:	50                   	push   %eax
f010329c:	e8 03 26 00 00       	call   f01058a4 <memcpy>
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
f01032b4:	68 68 6e 10 f0       	push   $0xf0106e68
f01032b9:	68 c8 00 00 00       	push   $0xc8
f01032be:	68 dc 82 10 f0       	push   $0xf01082dc
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
f01032ee:	2b 15 48 c2 2a f0    	sub    0xf02ac248,%edx
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
f0103325:	e8 c5 24 00 00       	call   f01057ef <memset>
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
f010335e:	a3 4c c2 2a f0       	mov    %eax,0xf02ac24c
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
f01033a4:	68 64 82 10 f0       	push   $0xf0108264
f01033a9:	68 bc 01 00 00       	push   $0x1bc
f01033ae:	68 dc 82 10 f0       	push   $0xf01082dc
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
f01033c9:	68 88 82 10 f0       	push   $0xf0108288
f01033ce:	68 75 01 00 00       	push   $0x175
f01033d3:	68 dc 82 10 f0       	push   $0xf01082dc
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
f01033f9:	68 68 6e 10 f0       	push   $0xf0106e68
f01033fe:	68 7e 01 00 00       	push   $0x17e
f0103403:	68 dc 82 10 f0       	push   $0xf01082dc
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
f0103427:	68 b0 82 10 f0       	push   $0xf01082b0
f010342c:	68 87 01 00 00       	push   $0x187
f0103431:	68 dc 82 10 f0       	push   $0xf01082dc
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
f0103451:	e8 99 23 00 00       	call   f01057ef <memset>

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
f0103465:	e8 3a 24 00 00       	call   f01058a4 <memcpy>
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
f010348e:	a1 9c ce 2a f0       	mov    0xf02ace9c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103493:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103498:	77 15                	ja     f01034af <env_create+0x12a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010349a:	50                   	push   %eax
f010349b:	68 68 6e 10 f0       	push   $0xf0106e68
f01034a0:	68 a5 01 00 00       	push   $0x1a5
f01034a5:	68 dc 82 10 f0       	push   $0xf01082dc
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
f01034e0:	e8 2d 29 00 00       	call   f0105e12 <cpunum>
f01034e5:	6b c0 74             	imul   $0x74,%eax,%eax
f01034e8:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01034ef:	39 b8 28 d0 2a f0    	cmp    %edi,-0xfd52fd8(%eax)
f01034f5:	75 30                	jne    f0103527 <env_free+0x53>
		lcr3(PADDR(kern_pgdir));
f01034f7:	a1 9c ce 2a f0       	mov    0xf02ace9c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01034fc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103501:	77 15                	ja     f0103518 <env_free+0x44>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103503:	50                   	push   %eax
f0103504:	68 68 6e 10 f0       	push   $0xf0106e68
f0103509:	68 d4 01 00 00       	push   $0x1d4
f010350e:	68 dc 82 10 f0       	push   $0xf01082dc
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
f0103552:	39 05 98 ce 2a f0    	cmp    %eax,0xf02ace98
f0103558:	77 15                	ja     f010356f <env_free+0x9b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010355a:	56                   	push   %esi
f010355b:	68 44 6e 10 f0       	push   $0xf0106e44
f0103560:	68 e3 01 00 00       	push   $0x1e3
f0103565:	68 dc 82 10 f0       	push   $0xf01082dc
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
f01035b9:	3b 05 98 ce 2a f0    	cmp    0xf02ace98,%eax
f01035bf:	72 14                	jb     f01035d5 <env_free+0x101>
		panic("pa2page called with invalid pa");
f01035c1:	83 ec 04             	sub    $0x4,%esp
f01035c4:	68 74 79 10 f0       	push   $0xf0107974
f01035c9:	6a 51                	push   $0x51
f01035cb:	68 0b 74 10 f0       	push   $0xf010740b
f01035d0:	e8 6b ca ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f01035d5:	83 ec 0c             	sub    $0xc,%esp
f01035d8:	a1 a0 ce 2a f0       	mov    0xf02acea0,%eax
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
f0103609:	68 68 6e 10 f0       	push   $0xf0106e68
f010360e:	68 f1 01 00 00       	push   $0x1f1
f0103613:	68 dc 82 10 f0       	push   $0xf01082dc
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
f010362c:	3b 05 98 ce 2a f0    	cmp    0xf02ace98,%eax
f0103632:	72 14                	jb     f0103648 <env_free+0x174>
		panic("pa2page called with invalid pa");
f0103634:	83 ec 04             	sub    $0x4,%esp
f0103637:	68 74 79 10 f0       	push   $0xf0107974
f010363c:	6a 51                	push   $0x51
f010363e:	68 0b 74 10 f0       	push   $0xf010740b
f0103643:	e8 f8 c9 ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f0103648:	83 ec 0c             	sub    $0xc,%esp
f010364b:	8b 15 a0 ce 2a f0    	mov    0xf02acea0,%edx
f0103651:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103654:	50                   	push   %eax
f0103655:	e8 0d db ff ff       	call   f0101167 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f010365a:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103661:	a1 4c c2 2a f0       	mov    0xf02ac24c,%eax
f0103666:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103669:	89 3d 4c c2 2a f0    	mov    %edi,0xf02ac24c
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
f010368a:	e8 83 27 00 00       	call   f0105e12 <cpunum>
f010368f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103692:	3b 98 28 d0 2a f0    	cmp    -0xfd52fd8(%eax),%ebx
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
f01036ac:	e8 61 27 00 00       	call   f0105e12 <cpunum>
f01036b1:	6b c0 74             	imul   $0x74,%eax,%eax
f01036b4:	83 c4 10             	add    $0x10,%esp
f01036b7:	3b 98 28 d0 2a f0    	cmp    -0xfd52fd8(%eax),%ebx
f01036bd:	75 17                	jne    f01036d6 <env_destroy+0x5c>
		curenv = NULL;
f01036bf:	e8 4e 27 00 00       	call   f0105e12 <cpunum>
f01036c4:	6b c0 74             	imul   $0x74,%eax,%eax
f01036c7:	c7 80 28 d0 2a f0 00 	movl   $0x0,-0xfd52fd8(%eax)
f01036ce:	00 00 00 
		sched_yield();
f01036d1:	e8 0a 0f 00 00       	call   f01045e0 <sched_yield>
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
f01036e2:	e8 2b 27 00 00       	call   f0105e12 <cpunum>
f01036e7:	6b c0 74             	imul   $0x74,%eax,%eax
f01036ea:	8b 98 28 d0 2a f0    	mov    -0xfd52fd8(%eax),%ebx
f01036f0:	e8 1d 27 00 00       	call   f0105e12 <cpunum>
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
f0103705:	68 e7 82 10 f0       	push   $0xf01082e7
f010370a:	68 28 02 00 00       	push   $0x228
f010370f:	68 dc 82 10 f0       	push   $0xf01082dc
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
f0103723:	e8 ea 26 00 00       	call   f0105e12 <cpunum>
f0103728:	6b c0 74             	imul   $0x74,%eax,%eax
f010372b:	39 98 28 d0 2a f0    	cmp    %ebx,-0xfd52fd8(%eax)
f0103731:	74 3a                	je     f010376d <env_run+0x54>

		if (curenv != NULL && curenv->env_status == ENV_RUNNING)
f0103733:	e8 da 26 00 00       	call   f0105e12 <cpunum>
f0103738:	6b c0 74             	imul   $0x74,%eax,%eax
f010373b:	83 b8 28 d0 2a f0 00 	cmpl   $0x0,-0xfd52fd8(%eax)
f0103742:	74 29                	je     f010376d <env_run+0x54>
f0103744:	e8 c9 26 00 00       	call   f0105e12 <cpunum>
f0103749:	6b c0 74             	imul   $0x74,%eax,%eax
f010374c:	8b 80 28 d0 2a f0    	mov    -0xfd52fd8(%eax),%eax
f0103752:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103756:	75 15                	jne    f010376d <env_run+0x54>
			curenv->env_status = ENV_RUNNABLE;
f0103758:	e8 b5 26 00 00       	call   f0105e12 <cpunum>
f010375d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103760:	8b 80 28 d0 2a f0    	mov    -0xfd52fd8(%eax),%eax
f0103766:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
			
	}
	
	curenv = e;
f010376d:	e8 a0 26 00 00       	call   f0105e12 <cpunum>
f0103772:	6b c0 74             	imul   $0x74,%eax,%eax
f0103775:	89 98 28 d0 2a f0    	mov    %ebx,-0xfd52fd8(%eax)
	curenv->env_status = ENV_RUNNING;
f010377b:	e8 92 26 00 00       	call   f0105e12 <cpunum>
f0103780:	6b c0 74             	imul   $0x74,%eax,%eax
f0103783:	8b 80 28 d0 2a f0    	mov    -0xfd52fd8(%eax),%eax
f0103789:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f0103790:	e8 7d 26 00 00       	call   f0105e12 <cpunum>
f0103795:	6b c0 74             	imul   $0x74,%eax,%eax
f0103798:	8b 80 28 d0 2a f0    	mov    -0xfd52fd8(%eax),%eax
f010379e:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3(PADDR(curenv->env_pgdir));
f01037a2:	e8 6b 26 00 00       	call   f0105e12 <cpunum>
f01037a7:	6b c0 74             	imul   $0x74,%eax,%eax
f01037aa:	8b 80 28 d0 2a f0    	mov    -0xfd52fd8(%eax),%eax
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
f01037bb:	68 68 6e 10 f0       	push   $0xf0106e68
f01037c0:	68 52 02 00 00       	push   $0x252
f01037c5:	68 dc 82 10 f0       	push   $0xf01082dc
f01037ca:	e8 71 c8 ff ff       	call   f0100040 <_panic>
f01037cf:	05 00 00 00 10       	add    $0x10000000,%eax
f01037d4:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01037d7:	83 ec 0c             	sub    $0xc,%esp
f01037da:	68 c0 43 12 f0       	push   $0xf01243c0
f01037df:	e8 39 29 00 00       	call   f010611d <spin_unlock>

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
f01037e6:	e8 27 26 00 00       	call   f0105e12 <cpunum>
f01037eb:	83 c4 04             	add    $0x4,%esp
f01037ee:	6b c0 74             	imul   $0x74,%eax,%eax
f01037f1:	ff b0 28 d0 2a f0    	pushl  -0xfd52fd8(%eax)
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
f0103832:	66 a3 a8 43 12 f0    	mov    %ax,0xf01243a8
	if (!didinit)
f0103838:	80 3d 50 c2 2a f0 00 	cmpb   $0x0,0xf02ac250
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
f0103856:	68 f3 82 10 f0       	push   $0xf01082f3
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
f0103876:	68 97 87 10 f0       	push   $0xf0108797
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
f010388e:	68 39 77 10 f0       	push   $0xf0107739
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
f01038a2:	c6 05 50 c2 2a f0 01 	movb   $0x1,0xf02ac250
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
f0103920:	0f b7 05 a8 43 12 f0 	movzwl 0xf01243a8,%eax
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
f0103987:	e8 df 17 00 00       	call   f010516b <vprintfmt>
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
f01039ae:	e8 5f 24 00 00       	call   f0105e12 <cpunum>
f01039b3:	89 c3                	mov    %eax,%ebx
f01039b5:	e8 58 24 00 00       	call   f0105e12 <cpunum>
f01039ba:	6b db 74             	imul   $0x74,%ebx,%ebx
f01039bd:	c1 e0 0f             	shl    $0xf,%eax
f01039c0:	05 00 e0 2a f0       	add    $0xf02ae000,%eax
f01039c5:	89 83 30 d0 2a f0    	mov    %eax,-0xfd52fd0(%ebx)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f01039cb:	e8 42 24 00 00       	call   f0105e12 <cpunum>
f01039d0:	6b c0 74             	imul   $0x74,%eax,%eax
f01039d3:	66 c7 80 34 d0 2a f0 	movw   $0x10,-0xfd52fcc(%eax)
f01039da:	10 00 
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f01039dc:	e8 31 24 00 00       	call   f0105e12 <cpunum>
f01039e1:	6b c0 74             	imul   $0x74,%eax,%eax
f01039e4:	66 c7 80 92 d0 2a f0 	movw   $0x68,-0xfd52f6e(%eax)
f01039eb:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + cpunum()] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
f01039ed:	e8 20 24 00 00       	call   f0105e12 <cpunum>
f01039f2:	8d 58 05             	lea    0x5(%eax),%ebx
f01039f5:	e8 18 24 00 00       	call   f0105e12 <cpunum>
f01039fa:	89 c7                	mov    %eax,%edi
f01039fc:	e8 11 24 00 00       	call   f0105e12 <cpunum>
f0103a01:	89 c6                	mov    %eax,%esi
f0103a03:	e8 0a 24 00 00       	call   f0105e12 <cpunum>
f0103a08:	66 c7 04 dd 40 43 12 	movw   $0x67,-0xfedbcc0(,%ebx,8)
f0103a0f:	f0 67 00 
f0103a12:	6b ff 74             	imul   $0x74,%edi,%edi
f0103a15:	81 c7 2c d0 2a f0    	add    $0xf02ad02c,%edi
f0103a1b:	66 89 3c dd 42 43 12 	mov    %di,-0xfedbcbe(,%ebx,8)
f0103a22:	f0 
f0103a23:	6b d6 74             	imul   $0x74,%esi,%edx
f0103a26:	81 c2 2c d0 2a f0    	add    $0xf02ad02c,%edx
f0103a2c:	c1 ea 10             	shr    $0x10,%edx
f0103a2f:	88 14 dd 44 43 12 f0 	mov    %dl,-0xfedbcbc(,%ebx,8)
f0103a36:	c6 04 dd 45 43 12 f0 	movb   $0x99,-0xfedbcbb(,%ebx,8)
f0103a3d:	99 
f0103a3e:	c6 04 dd 46 43 12 f0 	movb   $0x40,-0xfedbcba(,%ebx,8)
f0103a45:	40 
f0103a46:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a49:	05 2c d0 2a f0       	add    $0xf02ad02c,%eax
f0103a4e:	c1 e8 18             	shr    $0x18,%eax
f0103a51:	88 04 dd 47 43 12 f0 	mov    %al,-0xfedbcb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + cpunum()].sd_s = 0;
f0103a58:	e8 b5 23 00 00       	call   f0105e12 <cpunum>
f0103a5d:	80 24 c5 6d 43 12 f0 	andb   $0xef,-0xfedbc93(,%eax,8)
f0103a64:	ef 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + (cpunum() << 3));
f0103a65:	e8 a8 23 00 00       	call   f0105e12 <cpunum>
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
f0103a74:	b8 ac 43 12 f0       	mov    $0xf01243ac,%eax
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
f0103a8a:	b8 6e 44 10 f0       	mov    $0xf010446e,%eax
f0103a8f:	66 a3 60 c2 2a f0    	mov    %ax,0xf02ac260
f0103a95:	66 c7 05 62 c2 2a f0 	movw   $0x8,0xf02ac262
f0103a9c:	08 00 
f0103a9e:	c6 05 64 c2 2a f0 00 	movb   $0x0,0xf02ac264
f0103aa5:	c6 05 65 c2 2a f0 8e 	movb   $0x8e,0xf02ac265
f0103aac:	c1 e8 10             	shr    $0x10,%eax
f0103aaf:	66 a3 66 c2 2a f0    	mov    %ax,0xf02ac266
	SETGATE(idt[T_DEBUG], 0, GD_KT, _T_DEBUG_handler, 0);
f0103ab5:	b8 78 44 10 f0       	mov    $0xf0104478,%eax
f0103aba:	66 a3 68 c2 2a f0    	mov    %ax,0xf02ac268
f0103ac0:	66 c7 05 6a c2 2a f0 	movw   $0x8,0xf02ac26a
f0103ac7:	08 00 
f0103ac9:	c6 05 6c c2 2a f0 00 	movb   $0x0,0xf02ac26c
f0103ad0:	c6 05 6d c2 2a f0 8e 	movb   $0x8e,0xf02ac26d
f0103ad7:	c1 e8 10             	shr    $0x10,%eax
f0103ada:	66 a3 6e c2 2a f0    	mov    %ax,0xf02ac26e
	SETGATE(idt[T_NMI], 0, GD_KT, _T_NMI_handler, 0);
f0103ae0:	b8 7e 44 10 f0       	mov    $0xf010447e,%eax
f0103ae5:	66 a3 70 c2 2a f0    	mov    %ax,0xf02ac270
f0103aeb:	66 c7 05 72 c2 2a f0 	movw   $0x8,0xf02ac272
f0103af2:	08 00 
f0103af4:	c6 05 74 c2 2a f0 00 	movb   $0x0,0xf02ac274
f0103afb:	c6 05 75 c2 2a f0 8e 	movb   $0x8e,0xf02ac275
f0103b02:	c1 e8 10             	shr    $0x10,%eax
f0103b05:	66 a3 76 c2 2a f0    	mov    %ax,0xf02ac276
	SETGATE(idt[T_BRKPT], 0, GD_KT, _T_BRKPT_handler, 3);
f0103b0b:	b8 84 44 10 f0       	mov    $0xf0104484,%eax
f0103b10:	66 a3 78 c2 2a f0    	mov    %ax,0xf02ac278
f0103b16:	66 c7 05 7a c2 2a f0 	movw   $0x8,0xf02ac27a
f0103b1d:	08 00 
f0103b1f:	c6 05 7c c2 2a f0 00 	movb   $0x0,0xf02ac27c
f0103b26:	c6 05 7d c2 2a f0 ee 	movb   $0xee,0xf02ac27d
f0103b2d:	c1 e8 10             	shr    $0x10,%eax
f0103b30:	66 a3 7e c2 2a f0    	mov    %ax,0xf02ac27e
	SETGATE(idt[T_OFLOW], 0, GD_KT, _T_OFLOW_handler, 0);
f0103b36:	b8 8a 44 10 f0       	mov    $0xf010448a,%eax
f0103b3b:	66 a3 80 c2 2a f0    	mov    %ax,0xf02ac280
f0103b41:	66 c7 05 82 c2 2a f0 	movw   $0x8,0xf02ac282
f0103b48:	08 00 
f0103b4a:	c6 05 84 c2 2a f0 00 	movb   $0x0,0xf02ac284
f0103b51:	c6 05 85 c2 2a f0 8e 	movb   $0x8e,0xf02ac285
f0103b58:	c1 e8 10             	shr    $0x10,%eax
f0103b5b:	66 a3 86 c2 2a f0    	mov    %ax,0xf02ac286
	SETGATE(idt[T_BOUND], 0, GD_KT, _T_BOUND_handler, 0);
f0103b61:	b8 90 44 10 f0       	mov    $0xf0104490,%eax
f0103b66:	66 a3 88 c2 2a f0    	mov    %ax,0xf02ac288
f0103b6c:	66 c7 05 8a c2 2a f0 	movw   $0x8,0xf02ac28a
f0103b73:	08 00 
f0103b75:	c6 05 8c c2 2a f0 00 	movb   $0x0,0xf02ac28c
f0103b7c:	c6 05 8d c2 2a f0 8e 	movb   $0x8e,0xf02ac28d
f0103b83:	c1 e8 10             	shr    $0x10,%eax
f0103b86:	66 a3 8e c2 2a f0    	mov    %ax,0xf02ac28e
	SETGATE(idt[T_ILLOP], 0, GD_KT, _T_ILLOP_handler, 0);
f0103b8c:	b8 96 44 10 f0       	mov    $0xf0104496,%eax
f0103b91:	66 a3 90 c2 2a f0    	mov    %ax,0xf02ac290
f0103b97:	66 c7 05 92 c2 2a f0 	movw   $0x8,0xf02ac292
f0103b9e:	08 00 
f0103ba0:	c6 05 94 c2 2a f0 00 	movb   $0x0,0xf02ac294
f0103ba7:	c6 05 95 c2 2a f0 8e 	movb   $0x8e,0xf02ac295
f0103bae:	c1 e8 10             	shr    $0x10,%eax
f0103bb1:	66 a3 96 c2 2a f0    	mov    %ax,0xf02ac296
	SETGATE(idt[T_DEVICE], 0, GD_KT, _T_DEVICE_handler, 0);
f0103bb7:	b8 9c 44 10 f0       	mov    $0xf010449c,%eax
f0103bbc:	66 a3 98 c2 2a f0    	mov    %ax,0xf02ac298
f0103bc2:	66 c7 05 9a c2 2a f0 	movw   $0x8,0xf02ac29a
f0103bc9:	08 00 
f0103bcb:	c6 05 9c c2 2a f0 00 	movb   $0x0,0xf02ac29c
f0103bd2:	c6 05 9d c2 2a f0 8e 	movb   $0x8e,0xf02ac29d
f0103bd9:	c1 e8 10             	shr    $0x10,%eax
f0103bdc:	66 a3 9e c2 2a f0    	mov    %ax,0xf02ac29e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, _T_DBLFLT_handler, 0);
f0103be2:	b8 a2 44 10 f0       	mov    $0xf01044a2,%eax
f0103be7:	66 a3 a0 c2 2a f0    	mov    %ax,0xf02ac2a0
f0103bed:	66 c7 05 a2 c2 2a f0 	movw   $0x8,0xf02ac2a2
f0103bf4:	08 00 
f0103bf6:	c6 05 a4 c2 2a f0 00 	movb   $0x0,0xf02ac2a4
f0103bfd:	c6 05 a5 c2 2a f0 8e 	movb   $0x8e,0xf02ac2a5
f0103c04:	c1 e8 10             	shr    $0x10,%eax
f0103c07:	66 a3 a6 c2 2a f0    	mov    %ax,0xf02ac2a6
	SETGATE(idt[T_TSS], 0, GD_KT, _T_TSS_handler, 0);
f0103c0d:	b8 a6 44 10 f0       	mov    $0xf01044a6,%eax
f0103c12:	66 a3 b0 c2 2a f0    	mov    %ax,0xf02ac2b0
f0103c18:	66 c7 05 b2 c2 2a f0 	movw   $0x8,0xf02ac2b2
f0103c1f:	08 00 
f0103c21:	c6 05 b4 c2 2a f0 00 	movb   $0x0,0xf02ac2b4
f0103c28:	c6 05 b5 c2 2a f0 8e 	movb   $0x8e,0xf02ac2b5
f0103c2f:	c1 e8 10             	shr    $0x10,%eax
f0103c32:	66 a3 b6 c2 2a f0    	mov    %ax,0xf02ac2b6
	SETGATE(idt[T_SEGNP], 0, GD_KT, _T_SEGNP_handler, 0);
f0103c38:	b8 aa 44 10 f0       	mov    $0xf01044aa,%eax
f0103c3d:	66 a3 b8 c2 2a f0    	mov    %ax,0xf02ac2b8
f0103c43:	66 c7 05 ba c2 2a f0 	movw   $0x8,0xf02ac2ba
f0103c4a:	08 00 
f0103c4c:	c6 05 bc c2 2a f0 00 	movb   $0x0,0xf02ac2bc
f0103c53:	c6 05 bd c2 2a f0 8e 	movb   $0x8e,0xf02ac2bd
f0103c5a:	c1 e8 10             	shr    $0x10,%eax
f0103c5d:	66 a3 be c2 2a f0    	mov    %ax,0xf02ac2be
	SETGATE(idt[T_STACK], 0, GD_KT, _T_STACK_handler, 0);
f0103c63:	b8 ae 44 10 f0       	mov    $0xf01044ae,%eax
f0103c68:	66 a3 c0 c2 2a f0    	mov    %ax,0xf02ac2c0
f0103c6e:	66 c7 05 c2 c2 2a f0 	movw   $0x8,0xf02ac2c2
f0103c75:	08 00 
f0103c77:	c6 05 c4 c2 2a f0 00 	movb   $0x0,0xf02ac2c4
f0103c7e:	c6 05 c5 c2 2a f0 8e 	movb   $0x8e,0xf02ac2c5
f0103c85:	c1 e8 10             	shr    $0x10,%eax
f0103c88:	66 a3 c6 c2 2a f0    	mov    %ax,0xf02ac2c6
	SETGATE(idt[T_GPFLT], 0, GD_KT, _T_GPFLT_handler, 0);
f0103c8e:	b8 b2 44 10 f0       	mov    $0xf01044b2,%eax
f0103c93:	66 a3 c8 c2 2a f0    	mov    %ax,0xf02ac2c8
f0103c99:	66 c7 05 ca c2 2a f0 	movw   $0x8,0xf02ac2ca
f0103ca0:	08 00 
f0103ca2:	c6 05 cc c2 2a f0 00 	movb   $0x0,0xf02ac2cc
f0103ca9:	c6 05 cd c2 2a f0 8e 	movb   $0x8e,0xf02ac2cd
f0103cb0:	c1 e8 10             	shr    $0x10,%eax
f0103cb3:	66 a3 ce c2 2a f0    	mov    %ax,0xf02ac2ce
	SETGATE(idt[T_PGFLT], 0, GD_KT, _T_PGFLT_handler, 0);
f0103cb9:	b8 b6 44 10 f0       	mov    $0xf01044b6,%eax
f0103cbe:	66 a3 d0 c2 2a f0    	mov    %ax,0xf02ac2d0
f0103cc4:	66 c7 05 d2 c2 2a f0 	movw   $0x8,0xf02ac2d2
f0103ccb:	08 00 
f0103ccd:	c6 05 d4 c2 2a f0 00 	movb   $0x0,0xf02ac2d4
f0103cd4:	c6 05 d5 c2 2a f0 8e 	movb   $0x8e,0xf02ac2d5
f0103cdb:	c1 e8 10             	shr    $0x10,%eax
f0103cde:	66 a3 d6 c2 2a f0    	mov    %ax,0xf02ac2d6
	SETGATE(idt[T_FPERR], 0, GD_KT, _T_FPERR_handler, 0);
f0103ce4:	b8 ba 44 10 f0       	mov    $0xf01044ba,%eax
f0103ce9:	66 a3 e0 c2 2a f0    	mov    %ax,0xf02ac2e0
f0103cef:	66 c7 05 e2 c2 2a f0 	movw   $0x8,0xf02ac2e2
f0103cf6:	08 00 
f0103cf8:	c6 05 e4 c2 2a f0 00 	movb   $0x0,0xf02ac2e4
f0103cff:	c6 05 e5 c2 2a f0 8e 	movb   $0x8e,0xf02ac2e5
f0103d06:	c1 e8 10             	shr    $0x10,%eax
f0103d09:	66 a3 e6 c2 2a f0    	mov    %ax,0xf02ac2e6
	SETGATE(idt[T_ALIGN], 0, GD_KT, _T_ALIGN_handler, 0);
f0103d0f:	b8 c0 44 10 f0       	mov    $0xf01044c0,%eax
f0103d14:	66 a3 e8 c2 2a f0    	mov    %ax,0xf02ac2e8
f0103d1a:	66 c7 05 ea c2 2a f0 	movw   $0x8,0xf02ac2ea
f0103d21:	08 00 
f0103d23:	c6 05 ec c2 2a f0 00 	movb   $0x0,0xf02ac2ec
f0103d2a:	c6 05 ed c2 2a f0 8e 	movb   $0x8e,0xf02ac2ed
f0103d31:	c1 e8 10             	shr    $0x10,%eax
f0103d34:	66 a3 ee c2 2a f0    	mov    %ax,0xf02ac2ee
	SETGATE(idt[T_MCHK], 0, GD_KT, _T_MCHK_handler, 0);
f0103d3a:	b8 c4 44 10 f0       	mov    $0xf01044c4,%eax
f0103d3f:	66 a3 f0 c2 2a f0    	mov    %ax,0xf02ac2f0
f0103d45:	66 c7 05 f2 c2 2a f0 	movw   $0x8,0xf02ac2f2
f0103d4c:	08 00 
f0103d4e:	c6 05 f4 c2 2a f0 00 	movb   $0x0,0xf02ac2f4
f0103d55:	c6 05 f5 c2 2a f0 8e 	movb   $0x8e,0xf02ac2f5
f0103d5c:	c1 e8 10             	shr    $0x10,%eax
f0103d5f:	66 a3 f6 c2 2a f0    	mov    %ax,0xf02ac2f6
	SETGATE(idt[T_SIMDERR], 0, GD_KT, _T_SIMDERR_handler, 0);
f0103d65:	b8 ca 44 10 f0       	mov    $0xf01044ca,%eax
f0103d6a:	66 a3 f8 c2 2a f0    	mov    %ax,0xf02ac2f8
f0103d70:	66 c7 05 fa c2 2a f0 	movw   $0x8,0xf02ac2fa
f0103d77:	08 00 
f0103d79:	c6 05 fc c2 2a f0 00 	movb   $0x0,0xf02ac2fc
f0103d80:	c6 05 fd c2 2a f0 8e 	movb   $0x8e,0xf02ac2fd
f0103d87:	c1 e8 10             	shr    $0x10,%eax
f0103d8a:	66 a3 fe c2 2a f0    	mov    %ax,0xf02ac2fe
	SETGATE(idt[T_SYSCALL], 0, GD_KT, _T_SYSCALL_handler, 3);
f0103d90:	b8 d0 44 10 f0       	mov    $0xf01044d0,%eax
f0103d95:	66 a3 e0 c3 2a f0    	mov    %ax,0xf02ac3e0
f0103d9b:	66 c7 05 e2 c3 2a f0 	movw   $0x8,0xf02ac3e2
f0103da2:	08 00 
f0103da4:	c6 05 e4 c3 2a f0 00 	movb   $0x0,0xf02ac3e4
f0103dab:	c6 05 e5 c3 2a f0 ee 	movb   $0xee,0xf02ac3e5
f0103db2:	c1 e8 10             	shr    $0x10,%eax
f0103db5:	66 a3 e6 c3 2a f0    	mov    %ax,0xf02ac3e6

	SETGATE(idt[IRQ_TIMER + IRQ_OFFSET], 0, GD_KT, _IRQ_TIMER_handler, 0);
f0103dbb:	b8 d6 44 10 f0       	mov    $0xf01044d6,%eax
f0103dc0:	66 a3 60 c3 2a f0    	mov    %ax,0xf02ac360
f0103dc6:	66 c7 05 62 c3 2a f0 	movw   $0x8,0xf02ac362
f0103dcd:	08 00 
f0103dcf:	c6 05 64 c3 2a f0 00 	movb   $0x0,0xf02ac364
f0103dd6:	c6 05 65 c3 2a f0 8e 	movb   $0x8e,0xf02ac365
f0103ddd:	c1 e8 10             	shr    $0x10,%eax
f0103de0:	66 a3 66 c3 2a f0    	mov    %ax,0xf02ac366
	SETGATE(idt[IRQ_KBD + IRQ_OFFSET], 0, GD_KT, _IRQ_KBD_handler, 0);
f0103de6:	b8 dc 44 10 f0       	mov    $0xf01044dc,%eax
f0103deb:	66 a3 68 c3 2a f0    	mov    %ax,0xf02ac368
f0103df1:	66 c7 05 6a c3 2a f0 	movw   $0x8,0xf02ac36a
f0103df8:	08 00 
f0103dfa:	c6 05 6c c3 2a f0 00 	movb   $0x0,0xf02ac36c
f0103e01:	c6 05 6d c3 2a f0 8e 	movb   $0x8e,0xf02ac36d
f0103e08:	c1 e8 10             	shr    $0x10,%eax
f0103e0b:	66 a3 6e c3 2a f0    	mov    %ax,0xf02ac36e
	SETGATE(idt[IRQ_SERIAL + IRQ_OFFSET], 0, GD_KT, _IRQ_SERIAL_handler, 0);
f0103e11:	b8 e2 44 10 f0       	mov    $0xf01044e2,%eax
f0103e16:	66 a3 80 c3 2a f0    	mov    %ax,0xf02ac380
f0103e1c:	66 c7 05 82 c3 2a f0 	movw   $0x8,0xf02ac382
f0103e23:	08 00 
f0103e25:	c6 05 84 c3 2a f0 00 	movb   $0x0,0xf02ac384
f0103e2c:	c6 05 85 c3 2a f0 8e 	movb   $0x8e,0xf02ac385
f0103e33:	c1 e8 10             	shr    $0x10,%eax
f0103e36:	66 a3 86 c3 2a f0    	mov    %ax,0xf02ac386
	SETGATE(idt[IRQ_SPURIOUS + IRQ_OFFSET], 0, GD_KT, _IRQ_SPURIOUS_handler, 0);
f0103e3c:	b8 e8 44 10 f0       	mov    $0xf01044e8,%eax
f0103e41:	66 a3 98 c3 2a f0    	mov    %ax,0xf02ac398
f0103e47:	66 c7 05 9a c3 2a f0 	movw   $0x8,0xf02ac39a
f0103e4e:	08 00 
f0103e50:	c6 05 9c c3 2a f0 00 	movb   $0x0,0xf02ac39c
f0103e57:	c6 05 9d c3 2a f0 8e 	movb   $0x8e,0xf02ac39d
f0103e5e:	c1 e8 10             	shr    $0x10,%eax
f0103e61:	66 a3 9e c3 2a f0    	mov    %ax,0xf02ac39e
	SETGATE(idt[IRQ_IDE + IRQ_OFFSET], 0, GD_KT, _IRQ_IDE_handler, 0);
f0103e67:	b8 ee 44 10 f0       	mov    $0xf01044ee,%eax
f0103e6c:	66 a3 d0 c3 2a f0    	mov    %ax,0xf02ac3d0
f0103e72:	66 c7 05 d2 c3 2a f0 	movw   $0x8,0xf02ac3d2
f0103e79:	08 00 
f0103e7b:	c6 05 d4 c3 2a f0 00 	movb   $0x0,0xf02ac3d4
f0103e82:	c6 05 d5 c3 2a f0 8e 	movb   $0x8e,0xf02ac3d5
f0103e89:	c1 e8 10             	shr    $0x10,%eax
f0103e8c:	66 a3 d6 c3 2a f0    	mov    %ax,0xf02ac3d6
	SETGATE(idt[IRQ_ERROR + IRQ_OFFSET], 0, GD_KT, _IRQ_ERROR_handler, 0);
f0103e92:	b8 f4 44 10 f0       	mov    $0xf01044f4,%eax
f0103e97:	66 a3 f8 c3 2a f0    	mov    %ax,0xf02ac3f8
f0103e9d:	66 c7 05 fa c3 2a f0 	movw   $0x8,0xf02ac3fa
f0103ea4:	08 00 
f0103ea6:	c6 05 fc c3 2a f0 00 	movb   $0x0,0xf02ac3fc
f0103ead:	c6 05 fd c3 2a f0 8e 	movb   $0x8e,0xf02ac3fd
f0103eb4:	c1 e8 10             	shr    $0x10,%eax
f0103eb7:	66 a3 fe c3 2a f0    	mov    %ax,0xf02ac3fe

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
f0103ed0:	68 07 83 10 f0       	push   $0xf0108307
f0103ed5:	e8 b7 fa ff ff       	call   f0103991 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103eda:	83 c4 08             	add    $0x8,%esp
f0103edd:	ff 73 04             	pushl  0x4(%ebx)
f0103ee0:	68 16 83 10 f0       	push   $0xf0108316
f0103ee5:	e8 a7 fa ff ff       	call   f0103991 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103eea:	83 c4 08             	add    $0x8,%esp
f0103eed:	ff 73 08             	pushl  0x8(%ebx)
f0103ef0:	68 25 83 10 f0       	push   $0xf0108325
f0103ef5:	e8 97 fa ff ff       	call   f0103991 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103efa:	83 c4 08             	add    $0x8,%esp
f0103efd:	ff 73 0c             	pushl  0xc(%ebx)
f0103f00:	68 34 83 10 f0       	push   $0xf0108334
f0103f05:	e8 87 fa ff ff       	call   f0103991 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103f0a:	83 c4 08             	add    $0x8,%esp
f0103f0d:	ff 73 10             	pushl  0x10(%ebx)
f0103f10:	68 43 83 10 f0       	push   $0xf0108343
f0103f15:	e8 77 fa ff ff       	call   f0103991 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103f1a:	83 c4 08             	add    $0x8,%esp
f0103f1d:	ff 73 14             	pushl  0x14(%ebx)
f0103f20:	68 52 83 10 f0       	push   $0xf0108352
f0103f25:	e8 67 fa ff ff       	call   f0103991 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103f2a:	83 c4 08             	add    $0x8,%esp
f0103f2d:	ff 73 18             	pushl  0x18(%ebx)
f0103f30:	68 61 83 10 f0       	push   $0xf0108361
f0103f35:	e8 57 fa ff ff       	call   f0103991 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103f3a:	83 c4 08             	add    $0x8,%esp
f0103f3d:	ff 73 1c             	pushl  0x1c(%ebx)
f0103f40:	68 70 83 10 f0       	push   $0xf0108370
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
f0103f5a:	e8 b3 1e 00 00       	call   f0105e12 <cpunum>
f0103f5f:	83 ec 04             	sub    $0x4,%esp
f0103f62:	50                   	push   %eax
f0103f63:	53                   	push   %ebx
f0103f64:	68 d4 83 10 f0       	push   $0xf01083d4
f0103f69:	e8 23 fa ff ff       	call   f0103991 <cprintf>
	print_regs(&tf->tf_regs);
f0103f6e:	89 1c 24             	mov    %ebx,(%esp)
f0103f71:	e8 4e ff ff ff       	call   f0103ec4 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103f76:	83 c4 08             	add    $0x8,%esp
f0103f79:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103f7d:	50                   	push   %eax
f0103f7e:	68 f2 83 10 f0       	push   $0xf01083f2
f0103f83:	e8 09 fa ff ff       	call   f0103991 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103f88:	83 c4 08             	add    $0x8,%esp
f0103f8b:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103f8f:	50                   	push   %eax
f0103f90:	68 05 84 10 f0       	push   $0xf0108405
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
f0103fa5:	8b 14 85 a0 86 10 f0 	mov    -0xfef7960(,%eax,4),%edx
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
f0103fb9:	b9 9e 83 10 f0       	mov    $0xf010839e,%ecx
f0103fbe:	ba 8b 83 10 f0       	mov    $0xf010838b,%edx
f0103fc3:	0f 43 d1             	cmovae %ecx,%edx
f0103fc6:	eb 05                	jmp    f0103fcd <print_trapframe+0x7b>
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0103fc8:	ba 7f 83 10 f0       	mov    $0xf010837f,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103fcd:	83 ec 04             	sub    $0x4,%esp
f0103fd0:	52                   	push   %edx
f0103fd1:	50                   	push   %eax
f0103fd2:	68 18 84 10 f0       	push   $0xf0108418
f0103fd7:	e8 b5 f9 ff ff       	call   f0103991 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103fdc:	83 c4 10             	add    $0x10,%esp
f0103fdf:	3b 1d 60 ca 2a f0    	cmp    0xf02aca60,%ebx
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
f0103ff4:	68 2a 84 10 f0       	push   $0xf010842a
f0103ff9:	e8 93 f9 ff ff       	call   f0103991 <cprintf>
f0103ffe:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0104001:	83 ec 08             	sub    $0x8,%esp
f0104004:	ff 73 2c             	pushl  0x2c(%ebx)
f0104007:	68 39 84 10 f0       	push   $0xf0108439
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
f0104022:	ba b8 83 10 f0       	mov    $0xf01083b8,%edx
f0104027:	b9 ad 83 10 f0       	mov    $0xf01083ad,%ecx
f010402c:	0f 44 ca             	cmove  %edx,%ecx
f010402f:	89 c2                	mov    %eax,%edx
f0104031:	83 e2 02             	and    $0x2,%edx
f0104034:	ba ca 83 10 f0       	mov    $0xf01083ca,%edx
f0104039:	be c4 83 10 f0       	mov    $0xf01083c4,%esi
f010403e:	0f 45 d6             	cmovne %esi,%edx
f0104041:	83 e0 04             	and    $0x4,%eax
f0104044:	be 2e 85 10 f0       	mov    $0xf010852e,%esi
f0104049:	b8 cf 83 10 f0       	mov    $0xf01083cf,%eax
f010404e:	0f 44 c6             	cmove  %esi,%eax
f0104051:	51                   	push   %ecx
f0104052:	52                   	push   %edx
f0104053:	50                   	push   %eax
f0104054:	68 47 84 10 f0       	push   $0xf0108447
f0104059:	e8 33 f9 ff ff       	call   f0103991 <cprintf>
f010405e:	83 c4 10             	add    $0x10,%esp
f0104061:	eb 10                	jmp    f0104073 <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0104063:	83 ec 0c             	sub    $0xc,%esp
f0104066:	68 39 77 10 f0       	push   $0xf0107739
f010406b:	e8 21 f9 ff ff       	call   f0103991 <cprintf>
f0104070:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0104073:	83 ec 08             	sub    $0x8,%esp
f0104076:	ff 73 30             	pushl  0x30(%ebx)
f0104079:	68 56 84 10 f0       	push   $0xf0108456
f010407e:	e8 0e f9 ff ff       	call   f0103991 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0104083:	83 c4 08             	add    $0x8,%esp
f0104086:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f010408a:	50                   	push   %eax
f010408b:	68 65 84 10 f0       	push   $0xf0108465
f0104090:	e8 fc f8 ff ff       	call   f0103991 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104095:	83 c4 08             	add    $0x8,%esp
f0104098:	ff 73 38             	pushl  0x38(%ebx)
f010409b:	68 78 84 10 f0       	push   $0xf0108478
f01040a0:	e8 ec f8 ff ff       	call   f0103991 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01040a5:	83 c4 10             	add    $0x10,%esp
f01040a8:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01040ac:	74 25                	je     f01040d3 <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01040ae:	83 ec 08             	sub    $0x8,%esp
f01040b1:	ff 73 3c             	pushl  0x3c(%ebx)
f01040b4:	68 87 84 10 f0       	push   $0xf0108487
f01040b9:	e8 d3 f8 ff ff       	call   f0103991 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01040be:	83 c4 08             	add    $0x8,%esp
f01040c1:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01040c5:	50                   	push   %eax
f01040c6:	68 96 84 10 f0       	push   $0xf0108496
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
f01040f0:	68 a9 84 10 f0       	push   $0xf01084a9
f01040f5:	68 73 01 00 00       	push   $0x173
f01040fa:	68 c5 84 10 f0       	push   $0xf01084c5
f01040ff:	e8 3c bf ff ff       	call   f0100040 <_panic>
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	if (curenv->env_pgfault_upcall) {
f0104104:	e8 09 1d 00 00       	call   f0105e12 <cpunum>
f0104109:	6b c0 74             	imul   $0x74,%eax,%eax
f010410c:	8b 80 28 d0 2a f0    	mov    -0xfd52fd8(%eax),%eax
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
f010413c:	e8 d1 1c 00 00       	call   f0105e12 <cpunum>
f0104141:	6a 03                	push   $0x3
f0104143:	6a 34                	push   $0x34
f0104145:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104148:	6b c0 74             	imul   $0x74,%eax,%eax
f010414b:	ff b0 28 d0 2a f0    	pushl  -0xfd52fd8(%eax)
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
f0104182:	e8 8b 1c 00 00       	call   f0105e12 <cpunum>
f0104187:	6b c0 74             	imul   $0x74,%eax,%eax
f010418a:	8b 80 28 d0 2a f0    	mov    -0xfd52fd8(%eax),%eax
f0104190:	89 70 3c             	mov    %esi,0x3c(%eax)
		curenv->env_tf.tf_eip = (uint32_t)curenv->env_pgfault_upcall;
f0104193:	e8 7a 1c 00 00       	call   f0105e12 <cpunum>
f0104198:	6b c0 74             	imul   $0x74,%eax,%eax
f010419b:	8b 98 28 d0 2a f0    	mov    -0xfd52fd8(%eax),%ebx
f01041a1:	e8 6c 1c 00 00       	call   f0105e12 <cpunum>
f01041a6:	6b c0 74             	imul   $0x74,%eax,%eax
f01041a9:	8b 80 28 d0 2a f0    	mov    -0xfd52fd8(%eax),%eax
f01041af:	8b 40 64             	mov    0x64(%eax),%eax
f01041b2:	89 43 30             	mov    %eax,0x30(%ebx)
		env_run(curenv);
f01041b5:	e8 58 1c 00 00       	call   f0105e12 <cpunum>
f01041ba:	83 c4 04             	add    $0x4,%esp
f01041bd:	6b c0 74             	imul   $0x74,%eax,%eax
f01041c0:	ff b0 28 d0 2a f0    	pushl  -0xfd52fd8(%eax)
f01041c6:	e8 4e f5 ff ff       	call   f0103719 <env_run>

	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01041cb:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f01041ce:	e8 3f 1c 00 00       	call   f0105e12 <cpunum>
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
f01041d8:	8b 80 28 d0 2a f0    	mov    -0xfd52fd8(%eax),%eax
f01041de:	ff 70 48             	pushl  0x48(%eax)
f01041e1:	68 78 86 10 f0       	push   $0xf0108678
f01041e6:	e8 a6 f7 ff ff       	call   f0103991 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f01041eb:	89 1c 24             	mov    %ebx,(%esp)
f01041ee:	e8 5f fd ff ff       	call   f0103f52 <print_trapframe>
	env_destroy(curenv);
f01041f3:	e8 1a 1c 00 00       	call   f0105e12 <cpunum>
f01041f8:	83 c4 04             	add    $0x4,%esp
f01041fb:	6b c0 74             	imul   $0x74,%eax,%eax
f01041fe:	ff b0 28 d0 2a f0    	pushl  -0xfd52fd8(%eax)
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
f010421d:	83 3d 90 ce 2a f0 00 	cmpl   $0x0,0xf02ace90
f0104224:	74 01                	je     f0104227 <trap+0x13>
		asm volatile("hlt");
f0104226:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104227:	e8 e6 1b 00 00       	call   f0105e12 <cpunum>
f010422c:	6b d0 74             	imul   $0x74,%eax,%edx
f010422f:	81 c2 20 d0 2a f0    	add    $0xf02ad020,%edx
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
f0104246:	68 c0 43 12 f0       	push   $0xf01243c0
f010424b:	e8 30 1e 00 00       	call   f0106080 <spin_lock>
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
f010425a:	68 d1 84 10 f0       	push   $0xf01084d1
f010425f:	68 25 74 10 f0       	push   $0xf0107425
f0104264:	68 3b 01 00 00       	push   $0x13b
f0104269:	68 c5 84 10 f0       	push   $0xf01084c5
f010426e:	e8 cd bd ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0104273:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104277:	83 e0 03             	and    $0x3,%eax
f010427a:	66 83 f8 03          	cmp    $0x3,%ax
f010427e:	0f 85 a0 00 00 00    	jne    f0104324 <trap+0x110>
f0104284:	83 ec 0c             	sub    $0xc,%esp
f0104287:	68 c0 43 12 f0       	push   $0xf01243c0
f010428c:	e8 ef 1d 00 00       	call   f0106080 <spin_lock>
		// serious kernel work.
		// LAB 4: Your code here.

		lock_kernel();

		assert(curenv);
f0104291:	e8 7c 1b 00 00       	call   f0105e12 <cpunum>
f0104296:	6b c0 74             	imul   $0x74,%eax,%eax
f0104299:	83 c4 10             	add    $0x10,%esp
f010429c:	83 b8 28 d0 2a f0 00 	cmpl   $0x0,-0xfd52fd8(%eax)
f01042a3:	75 19                	jne    f01042be <trap+0xaa>
f01042a5:	68 ea 84 10 f0       	push   $0xf01084ea
f01042aa:	68 25 74 10 f0       	push   $0xf0107425
f01042af:	68 45 01 00 00       	push   $0x145
f01042b4:	68 c5 84 10 f0       	push   $0xf01084c5
f01042b9:	e8 82 bd ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f01042be:	e8 4f 1b 00 00       	call   f0105e12 <cpunum>
f01042c3:	6b c0 74             	imul   $0x74,%eax,%eax
f01042c6:	8b 80 28 d0 2a f0    	mov    -0xfd52fd8(%eax),%eax
f01042cc:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01042d0:	75 2d                	jne    f01042ff <trap+0xeb>
			env_free(curenv);
f01042d2:	e8 3b 1b 00 00       	call   f0105e12 <cpunum>
f01042d7:	83 ec 0c             	sub    $0xc,%esp
f01042da:	6b c0 74             	imul   $0x74,%eax,%eax
f01042dd:	ff b0 28 d0 2a f0    	pushl  -0xfd52fd8(%eax)
f01042e3:	e8 ec f1 ff ff       	call   f01034d4 <env_free>
			curenv = NULL;
f01042e8:	e8 25 1b 00 00       	call   f0105e12 <cpunum>
f01042ed:	6b c0 74             	imul   $0x74,%eax,%eax
f01042f0:	c7 80 28 d0 2a f0 00 	movl   $0x0,-0xfd52fd8(%eax)
f01042f7:	00 00 00 
			sched_yield();
f01042fa:	e8 e1 02 00 00       	call   f01045e0 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01042ff:	e8 0e 1b 00 00       	call   f0105e12 <cpunum>
f0104304:	6b c0 74             	imul   $0x74,%eax,%eax
f0104307:	8b 80 28 d0 2a f0    	mov    -0xfd52fd8(%eax),%eax
f010430d:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104312:	89 c7                	mov    %eax,%edi
f0104314:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104316:	e8 f7 1a 00 00       	call   f0105e12 <cpunum>
f010431b:	6b c0 74             	imul   $0x74,%eax,%eax
f010431e:	8b b0 28 d0 2a f0    	mov    -0xfd52fd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104324:	89 35 60 ca 2a f0    	mov    %esi,0xf02aca60
	// Handle keyboard and serial interrupts.
	// LAB 5: Your code here.

	struct PushRegs* r = &tf->tf_regs;

	switch(tf->tf_trapno) {
f010432a:	8b 46 28             	mov    0x28(%esi),%eax
f010432d:	83 f8 21             	cmp    $0x21,%eax
f0104330:	0f 84 80 00 00 00    	je     f01043b6 <trap+0x1a2>
f0104336:	83 f8 21             	cmp    $0x21,%eax
f0104339:	77 15                	ja     f0104350 <trap+0x13c>
f010433b:	83 f8 0e             	cmp    $0xe,%eax
f010433e:	74 21                	je     f0104361 <trap+0x14d>
f0104340:	83 f8 20             	cmp    $0x20,%eax
f0104343:	74 62                	je     f01043a7 <trap+0x193>
f0104345:	83 f8 03             	cmp    $0x3,%eax
f0104348:	0f 85 90 00 00 00    	jne    f01043de <trap+0x1ca>
f010434e:	eb 22                	jmp    f0104372 <trap+0x15e>
f0104350:	83 f8 27             	cmp    $0x27,%eax
f0104353:	74 6f                	je     f01043c4 <trap+0x1b0>
f0104355:	83 f8 30             	cmp    $0x30,%eax
f0104358:	74 29                	je     f0104383 <trap+0x16f>
f010435a:	83 f8 24             	cmp    $0x24,%eax
f010435d:	75 7f                	jne    f01043de <trap+0x1ca>
f010435f:	eb 5c                	jmp    f01043bd <trap+0x1a9>
		case (T_PGFLT):
			page_fault_handler(tf);
f0104361:	83 ec 0c             	sub    $0xc,%esp
f0104364:	56                   	push   %esi
f0104365:	e8 70 fd ff ff       	call   f01040da <page_fault_handler>
f010436a:	83 c4 10             	add    $0x10,%esp
f010436d:	e9 bc 00 00 00       	jmp    f010442e <trap+0x21a>
			break;
		case (T_BRKPT):
			monitor(tf);	// open a JOS monitor
f0104372:	83 ec 0c             	sub    $0xc,%esp
f0104375:	56                   	push   %esi
f0104376:	e8 45 c6 ff ff       	call   f01009c0 <monitor>
f010437b:	83 c4 10             	add    $0x10,%esp
f010437e:	e9 ab 00 00 00       	jmp    f010442e <trap+0x21a>
			break;
		case (T_SYSCALL):
			// call syscall in kern/syscall.c
			r->reg_eax = syscall(r->reg_eax, r->reg_edx, r->reg_ecx, r->reg_ebx, r->reg_edi, r->reg_esi);
f0104383:	83 ec 08             	sub    $0x8,%esp
f0104386:	ff 76 04             	pushl  0x4(%esi)
f0104389:	ff 36                	pushl  (%esi)
f010438b:	ff 76 10             	pushl  0x10(%esi)
f010438e:	ff 76 18             	pushl  0x18(%esi)
f0104391:	ff 76 14             	pushl  0x14(%esi)
f0104394:	ff 76 1c             	pushl  0x1c(%esi)
f0104397:	e8 13 03 00 00       	call   f01046af <syscall>
f010439c:	89 46 1c             	mov    %eax,0x1c(%esi)
f010439f:	83 c4 20             	add    $0x20,%esp
f01043a2:	e9 87 00 00 00       	jmp    f010442e <trap+0x21a>
			break;
		case (IRQ_OFFSET + IRQ_TIMER):
			lapic_eoi();	// Acknowledge interrupt.
f01043a7:	e8 b1 1b 00 00       	call   f0105f5d <lapic_eoi>
			time_tick();
f01043ac:	e8 83 27 00 00       	call   f0106b34 <time_tick>
			sched_yield();
f01043b1:	e8 2a 02 00 00       	call   f01045e0 <sched_yield>
			break;
		case (IRQ_OFFSET + IRQ_KBD):
			kbd_intr();
f01043b6:	e8 3e c2 ff ff       	call   f01005f9 <kbd_intr>
f01043bb:	eb 71                	jmp    f010442e <trap+0x21a>
			break;
		case (IRQ_OFFSET + IRQ_SERIAL):
			serial_intr();
f01043bd:	e8 1b c2 ff ff       	call   f01005dd <serial_intr>
f01043c2:	eb 6a                	jmp    f010442e <trap+0x21a>
			break;
		case (IRQ_OFFSET + IRQ_SPURIOUS):
			cprintf("Spurious interrupt on irq 7\n");
f01043c4:	83 ec 0c             	sub    $0xc,%esp
f01043c7:	68 f1 84 10 f0       	push   $0xf01084f1
f01043cc:	e8 c0 f5 ff ff       	call   f0103991 <cprintf>
			print_trapframe(tf);
f01043d1:	89 34 24             	mov    %esi,(%esp)
f01043d4:	e8 79 fb ff ff       	call   f0103f52 <print_trapframe>
f01043d9:	83 c4 10             	add    $0x10,%esp
f01043dc:	eb 50                	jmp    f010442e <trap+0x21a>
			return;
		default:
			// Unexpected trap: The user process or the kernel has a bug.
			cprintf("[trapno: %x]\n", tf->tf_trapno);
f01043de:	83 ec 08             	sub    $0x8,%esp
f01043e1:	50                   	push   %eax
f01043e2:	68 0e 85 10 f0       	push   $0xf010850e
f01043e7:	e8 a5 f5 ff ff       	call   f0103991 <cprintf>
			print_trapframe(tf);
f01043ec:	89 34 24             	mov    %esi,(%esp)
f01043ef:	e8 5e fb ff ff       	call   f0103f52 <print_trapframe>
			if (tf->tf_cs == GD_KT)
f01043f4:	83 c4 10             	add    $0x10,%esp
f01043f7:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01043fc:	75 17                	jne    f0104415 <trap+0x201>
				panic("unhandled trap in kernel");
f01043fe:	83 ec 04             	sub    $0x4,%esp
f0104401:	68 1c 85 10 f0       	push   $0xf010851c
f0104406:	68 20 01 00 00       	push   $0x120
f010440b:	68 c5 84 10 f0       	push   $0xf01084c5
f0104410:	e8 2b bc ff ff       	call   f0100040 <_panic>
			else {
				env_destroy(curenv);
f0104415:	e8 f8 19 00 00       	call   f0105e12 <cpunum>
f010441a:	83 ec 0c             	sub    $0xc,%esp
f010441d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104420:	ff b0 28 d0 2a f0    	pushl  -0xfd52fd8(%eax)
f0104426:	e8 4f f2 ff ff       	call   f010367a <env_destroy>
f010442b:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f010442e:	e8 df 19 00 00       	call   f0105e12 <cpunum>
f0104433:	6b c0 74             	imul   $0x74,%eax,%eax
f0104436:	83 b8 28 d0 2a f0 00 	cmpl   $0x0,-0xfd52fd8(%eax)
f010443d:	74 2a                	je     f0104469 <trap+0x255>
f010443f:	e8 ce 19 00 00       	call   f0105e12 <cpunum>
f0104444:	6b c0 74             	imul   $0x74,%eax,%eax
f0104447:	8b 80 28 d0 2a f0    	mov    -0xfd52fd8(%eax),%eax
f010444d:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104451:	75 16                	jne    f0104469 <trap+0x255>
		env_run(curenv);
f0104453:	e8 ba 19 00 00       	call   f0105e12 <cpunum>
f0104458:	83 ec 0c             	sub    $0xc,%esp
f010445b:	6b c0 74             	imul   $0x74,%eax,%eax
f010445e:	ff b0 28 d0 2a f0    	pushl  -0xfd52fd8(%eax)
f0104464:	e8 b0 f2 ff ff       	call   f0103719 <env_run>
	else
		sched_yield();
f0104469:	e8 72 01 00 00       	call   f01045e0 <sched_yield>

f010446e <_T_DIVIDE_handler>:
/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */


TRAPHANDLER_NOEC(_T_DIVIDE_handler, T_DIVIDE)
f010446e:	6a 00                	push   $0x0
f0104470:	6a 00                	push   $0x0
f0104472:	e9 83 00 00 00       	jmp    f01044fa <_alltraps>
f0104477:	90                   	nop

f0104478 <_T_DEBUG_handler>:
TRAPHANDLER_NOEC(_T_DEBUG_handler, T_DEBUG)
f0104478:	6a 00                	push   $0x0
f010447a:	6a 01                	push   $0x1
f010447c:	eb 7c                	jmp    f01044fa <_alltraps>

f010447e <_T_NMI_handler>:
TRAPHANDLER_NOEC(_T_NMI_handler, T_NMI)
f010447e:	6a 00                	push   $0x0
f0104480:	6a 02                	push   $0x2
f0104482:	eb 76                	jmp    f01044fa <_alltraps>

f0104484 <_T_BRKPT_handler>:
TRAPHANDLER_NOEC(_T_BRKPT_handler, T_BRKPT)
f0104484:	6a 00                	push   $0x0
f0104486:	6a 03                	push   $0x3
f0104488:	eb 70                	jmp    f01044fa <_alltraps>

f010448a <_T_OFLOW_handler>:
TRAPHANDLER_NOEC(_T_OFLOW_handler, T_OFLOW)
f010448a:	6a 00                	push   $0x0
f010448c:	6a 04                	push   $0x4
f010448e:	eb 6a                	jmp    f01044fa <_alltraps>

f0104490 <_T_BOUND_handler>:
TRAPHANDLER_NOEC(_T_BOUND_handler, T_BOUND)
f0104490:	6a 00                	push   $0x0
f0104492:	6a 05                	push   $0x5
f0104494:	eb 64                	jmp    f01044fa <_alltraps>

f0104496 <_T_ILLOP_handler>:
TRAPHANDLER_NOEC(_T_ILLOP_handler, T_ILLOP)
f0104496:	6a 00                	push   $0x0
f0104498:	6a 06                	push   $0x6
f010449a:	eb 5e                	jmp    f01044fa <_alltraps>

f010449c <_T_DEVICE_handler>:
TRAPHANDLER_NOEC(_T_DEVICE_handler, T_DEVICE)
f010449c:	6a 00                	push   $0x0
f010449e:	6a 07                	push   $0x7
f01044a0:	eb 58                	jmp    f01044fa <_alltraps>

f01044a2 <_T_DBLFLT_handler>:
TRAPHANDLER(_T_DBLFLT_handler, T_DBLFLT)
f01044a2:	6a 08                	push   $0x8
f01044a4:	eb 54                	jmp    f01044fa <_alltraps>

f01044a6 <_T_TSS_handler>:
TRAPHANDLER(_T_TSS_handler, T_TSS)
f01044a6:	6a 0a                	push   $0xa
f01044a8:	eb 50                	jmp    f01044fa <_alltraps>

f01044aa <_T_SEGNP_handler>:
TRAPHANDLER(_T_SEGNP_handler, T_SEGNP)
f01044aa:	6a 0b                	push   $0xb
f01044ac:	eb 4c                	jmp    f01044fa <_alltraps>

f01044ae <_T_STACK_handler>:
TRAPHANDLER(_T_STACK_handler, T_STACK)
f01044ae:	6a 0c                	push   $0xc
f01044b0:	eb 48                	jmp    f01044fa <_alltraps>

f01044b2 <_T_GPFLT_handler>:
TRAPHANDLER(_T_GPFLT_handler, T_GPFLT)
f01044b2:	6a 0d                	push   $0xd
f01044b4:	eb 44                	jmp    f01044fa <_alltraps>

f01044b6 <_T_PGFLT_handler>:
TRAPHANDLER(_T_PGFLT_handler, T_PGFLT)
f01044b6:	6a 0e                	push   $0xe
f01044b8:	eb 40                	jmp    f01044fa <_alltraps>

f01044ba <_T_FPERR_handler>:
TRAPHANDLER_NOEC(_T_FPERR_handler, T_FPERR)
f01044ba:	6a 00                	push   $0x0
f01044bc:	6a 10                	push   $0x10
f01044be:	eb 3a                	jmp    f01044fa <_alltraps>

f01044c0 <_T_ALIGN_handler>:
TRAPHANDLER(_T_ALIGN_handler, T_ALIGN)
f01044c0:	6a 11                	push   $0x11
f01044c2:	eb 36                	jmp    f01044fa <_alltraps>

f01044c4 <_T_MCHK_handler>:
TRAPHANDLER_NOEC(_T_MCHK_handler, T_MCHK)
f01044c4:	6a 00                	push   $0x0
f01044c6:	6a 12                	push   $0x12
f01044c8:	eb 30                	jmp    f01044fa <_alltraps>

f01044ca <_T_SIMDERR_handler>:
TRAPHANDLER_NOEC(_T_SIMDERR_handler, T_SIMDERR)
f01044ca:	6a 00                	push   $0x0
f01044cc:	6a 13                	push   $0x13
f01044ce:	eb 2a                	jmp    f01044fa <_alltraps>

f01044d0 <_T_SYSCALL_handler>:
TRAPHANDLER_NOEC(_T_SYSCALL_handler, T_SYSCALL)
f01044d0:	6a 00                	push   $0x0
f01044d2:	6a 30                	push   $0x30
f01044d4:	eb 24                	jmp    f01044fa <_alltraps>

f01044d6 <_IRQ_TIMER_handler>:

TRAPHANDLER_NOEC(_IRQ_TIMER_handler, IRQ_TIMER + IRQ_OFFSET)
f01044d6:	6a 00                	push   $0x0
f01044d8:	6a 20                	push   $0x20
f01044da:	eb 1e                	jmp    f01044fa <_alltraps>

f01044dc <_IRQ_KBD_handler>:
TRAPHANDLER_NOEC(_IRQ_KBD_handler, IRQ_KBD + IRQ_OFFSET)
f01044dc:	6a 00                	push   $0x0
f01044de:	6a 21                	push   $0x21
f01044e0:	eb 18                	jmp    f01044fa <_alltraps>

f01044e2 <_IRQ_SERIAL_handler>:
TRAPHANDLER_NOEC(_IRQ_SERIAL_handler, IRQ_SERIAL + IRQ_OFFSET)
f01044e2:	6a 00                	push   $0x0
f01044e4:	6a 24                	push   $0x24
f01044e6:	eb 12                	jmp    f01044fa <_alltraps>

f01044e8 <_IRQ_SPURIOUS_handler>:
TRAPHANDLER_NOEC(_IRQ_SPURIOUS_handler, IRQ_SPURIOUS + IRQ_OFFSET)
f01044e8:	6a 00                	push   $0x0
f01044ea:	6a 27                	push   $0x27
f01044ec:	eb 0c                	jmp    f01044fa <_alltraps>

f01044ee <_IRQ_IDE_handler>:
TRAPHANDLER_NOEC(_IRQ_IDE_handler, IRQ_IDE + IRQ_OFFSET)
f01044ee:	6a 00                	push   $0x0
f01044f0:	6a 2e                	push   $0x2e
f01044f2:	eb 06                	jmp    f01044fa <_alltraps>

f01044f4 <_IRQ_ERROR_handler>:
TRAPHANDLER_NOEC(_IRQ_ERROR_handler, IRQ_ERROR + IRQ_OFFSET)
f01044f4:	6a 00                	push   $0x0
f01044f6:	6a 33                	push   $0x33
f01044f8:	eb 00                	jmp    f01044fa <_alltraps>

f01044fa <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */

_alltraps:
	pushl %ds
f01044fa:	1e                   	push   %ds
	pushl %es
f01044fb:	06                   	push   %es
	pushal	/* push all general registers */
f01044fc:	60                   	pusha  

	movl $GD_KD, %eax
f01044fd:	b8 10 00 00 00       	mov    $0x10,%eax
	movl %eax, %ds
f0104502:	8e d8                	mov    %eax,%ds
	movl %eax, %es
f0104504:	8e c0                	mov    %eax,%es

	push %esp
f0104506:	54                   	push   %esp
f0104507:	e8 08 fd ff ff       	call   f0104214 <trap>

f010450c <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f010450c:	55                   	push   %ebp
f010450d:	89 e5                	mov    %esp,%ebp
f010450f:	83 ec 08             	sub    $0x8,%esp
f0104512:	a1 48 c2 2a f0       	mov    0xf02ac248,%eax
f0104517:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f010451a:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f010451f:	8b 02                	mov    (%edx),%eax
f0104521:	83 e8 01             	sub    $0x1,%eax
f0104524:	83 f8 02             	cmp    $0x2,%eax
f0104527:	76 10                	jbe    f0104539 <sched_halt+0x2d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104529:	83 c1 01             	add    $0x1,%ecx
f010452c:	83 c2 7c             	add    $0x7c,%edx
f010452f:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104535:	75 e8                	jne    f010451f <sched_halt+0x13>
f0104537:	eb 08                	jmp    f0104541 <sched_halt+0x35>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0104539:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f010453f:	75 1f                	jne    f0104560 <sched_halt+0x54>
		cprintf("No runnable environments in the system!\n");
f0104541:	83 ec 0c             	sub    $0xc,%esp
f0104544:	68 f0 86 10 f0       	push   $0xf01086f0
f0104549:	e8 43 f4 ff ff       	call   f0103991 <cprintf>
f010454e:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0104551:	83 ec 0c             	sub    $0xc,%esp
f0104554:	6a 00                	push   $0x0
f0104556:	e8 65 c4 ff ff       	call   f01009c0 <monitor>
f010455b:	83 c4 10             	add    $0x10,%esp
f010455e:	eb f1                	jmp    f0104551 <sched_halt+0x45>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104560:	e8 ad 18 00 00       	call   f0105e12 <cpunum>
f0104565:	6b c0 74             	imul   $0x74,%eax,%eax
f0104568:	c7 80 28 d0 2a f0 00 	movl   $0x0,-0xfd52fd8(%eax)
f010456f:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104572:	a1 9c ce 2a f0       	mov    0xf02ace9c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104577:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010457c:	77 12                	ja     f0104590 <sched_halt+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010457e:	50                   	push   %eax
f010457f:	68 68 6e 10 f0       	push   $0xf0106e68
f0104584:	6a 52                	push   $0x52
f0104586:	68 19 87 10 f0       	push   $0xf0108719
f010458b:	e8 b0 ba ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104590:	05 00 00 00 10       	add    $0x10000000,%eax
f0104595:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104598:	e8 75 18 00 00       	call   f0105e12 <cpunum>
f010459d:	6b d0 74             	imul   $0x74,%eax,%edx
f01045a0:	81 c2 20 d0 2a f0    	add    $0xf02ad020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01045a6:	b8 02 00 00 00       	mov    $0x2,%eax
f01045ab:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01045af:	83 ec 0c             	sub    $0xc,%esp
f01045b2:	68 c0 43 12 f0       	push   $0xf01243c0
f01045b7:	e8 61 1b 00 00       	call   f010611d <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01045bc:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f01045be:	e8 4f 18 00 00       	call   f0105e12 <cpunum>
f01045c3:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f01045c6:	8b 80 30 d0 2a f0    	mov    -0xfd52fd0(%eax),%eax
f01045cc:	bd 00 00 00 00       	mov    $0x0,%ebp
f01045d1:	89 c4                	mov    %eax,%esp
f01045d3:	6a 00                	push   $0x0
f01045d5:	6a 00                	push   $0x0
f01045d7:	fb                   	sti    
f01045d8:	f4                   	hlt    
f01045d9:	eb fd                	jmp    f01045d8 <sched_halt+0xcc>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f01045db:	83 c4 10             	add    $0x10,%esp
f01045de:	c9                   	leave  
f01045df:	c3                   	ret    

f01045e0 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f01045e0:	55                   	push   %ebp
f01045e1:	89 e5                	mov    %esp,%ebp
f01045e3:	56                   	push   %esi
f01045e4:	53                   	push   %ebx
	// below to halt the cpu.

	// LAB 4: Your code here.
	// cprintf("[yield]\n");

	struct Env *now = thiscpu->cpu_env;
f01045e5:	e8 28 18 00 00       	call   f0105e12 <cpunum>
f01045ea:	6b c0 74             	imul   $0x74,%eax,%eax
f01045ed:	8b 80 28 d0 2a f0    	mov    -0xfd52fd8(%eax),%eax
    int32_t startid = (now) ? ENVX(now->env_id): 0;
f01045f3:	85 c0                	test   %eax,%eax
f01045f5:	74 0b                	je     f0104602 <sched_yield+0x22>
f01045f7:	8b 50 48             	mov    0x48(%eax),%edx
f01045fa:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0104600:	eb 05                	jmp    f0104607 <sched_yield+0x27>
f0104602:	ba 00 00 00 00       	mov    $0x0,%edx
    int32_t nextid;
    size_t i;

    for(i = 0; i < NENV; i++) {
        nextid = (startid+i)%NENV;
        if(envs[nextid].env_status == ENV_RUNNABLE) {
f0104607:	8b 0d 48 c2 2a f0    	mov    0xf02ac248,%ecx
f010460d:	89 d6                	mov    %edx,%esi
f010460f:	8d 9a 00 04 00 00    	lea    0x400(%edx),%ebx
f0104615:	89 d0                	mov    %edx,%eax
f0104617:	25 ff 03 00 00       	and    $0x3ff,%eax
f010461c:	6b c0 7c             	imul   $0x7c,%eax,%eax
f010461f:	01 c8                	add    %ecx,%eax
f0104621:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0104625:	75 09                	jne    f0104630 <sched_yield+0x50>
                env_run(&envs[nextid]);
f0104627:	83 ec 0c             	sub    $0xc,%esp
f010462a:	50                   	push   %eax
f010462b:	e8 e9 f0 ff ff       	call   f0103719 <env_run>
f0104630:	83 c2 01             	add    $0x1,%edx
	struct Env *now = thiscpu->cpu_env;
    int32_t startid = (now) ? ENVX(now->env_id): 0;
    int32_t nextid;
    size_t i;

    for(i = 0; i < NENV; i++) {
f0104633:	39 da                	cmp    %ebx,%edx
f0104635:	75 de                	jne    f0104615 <sched_yield+0x35>
                env_run(&envs[nextid]);
                return;
            }
    }
    
    if(envs[startid].env_status == ENV_RUNNING && envs[startid].env_cpunum == cpunum()) {
f0104637:	6b f6 7c             	imul   $0x7c,%esi,%esi
f010463a:	01 f1                	add    %esi,%ecx
f010463c:	83 79 54 03          	cmpl   $0x3,0x54(%ecx)
f0104640:	75 1b                	jne    f010465d <sched_yield+0x7d>
f0104642:	8b 59 5c             	mov    0x5c(%ecx),%ebx
f0104645:	e8 c8 17 00 00       	call   f0105e12 <cpunum>
f010464a:	39 c3                	cmp    %eax,%ebx
f010464c:	75 0f                	jne    f010465d <sched_yield+0x7d>
        env_run(&envs[startid]);
f010464e:	83 ec 0c             	sub    $0xc,%esp
f0104651:	03 35 48 c2 2a f0    	add    0xf02ac248,%esi
f0104657:	56                   	push   %esi
f0104658:	e8 bc f0 ff ff       	call   f0103719 <env_run>
    }

	// cprintf("[halt]\n");

	// sched_halt never returns
	sched_halt();
f010465d:	e8 aa fe ff ff       	call   f010450c <sched_halt>
}
f0104662:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104665:	5b                   	pop    %ebx
f0104666:	5e                   	pop    %esi
f0104667:	5d                   	pop    %ebp
f0104668:	c3                   	ret    

f0104669 <sys_e1000_try_send>:

}

int 
sys_e1000_try_send(void *buf, uint32_t len)
{
f0104669:	55                   	push   %ebp
f010466a:	89 e5                	mov    %esp,%ebp
f010466c:	56                   	push   %esi
f010466d:	53                   	push   %ebx
f010466e:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104671:	8b 75 0c             	mov    0xc(%ebp),%esi
    user_mem_assert(curenv, buf, len, 0);
f0104674:	e8 99 17 00 00       	call   f0105e12 <cpunum>
f0104679:	6a 00                	push   $0x0
f010467b:	56                   	push   %esi
f010467c:	53                   	push   %ebx
f010467d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104680:	ff b0 28 d0 2a f0    	pushl  -0xfd52fd8(%eax)
f0104686:	e8 cc e9 ff ff       	call   f0103057 <user_mem_assert>
    return e1000_transmit(buf, len);
f010468b:	83 c4 08             	add    $0x8,%esp
f010468e:	56                   	push   %esi
f010468f:	53                   	push   %ebx
f0104690:	e8 74 1b 00 00       	call   f0106209 <e1000_transmit>
}
f0104695:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104698:	5b                   	pop    %ebx
f0104699:	5e                   	pop    %esi
f010469a:	5d                   	pop    %ebp
f010469b:	c3                   	ret    

f010469c <sys_e1000_try_recv>:

int 
sys_e1000_try_recv(void *buf, uint32_t *len)
{
f010469c:	55                   	push   %ebp
f010469d:	89 e5                	mov    %esp,%ebp
f010469f:	83 ec 10             	sub    $0x10,%esp
	return e1000_receive(buf, len);
f01046a2:	ff 75 0c             	pushl  0xc(%ebp)
f01046a5:	ff 75 08             	pushl  0x8(%ebp)
f01046a8:	e8 b8 1e 00 00       	call   f0106565 <e1000_receive>
}
f01046ad:	c9                   	leave  
f01046ae:	c3                   	ret    

f01046af <syscall>:


// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01046af:	55                   	push   %ebp
f01046b0:	89 e5                	mov    %esp,%ebp
f01046b2:	57                   	push   %edi
f01046b3:	56                   	push   %esi
f01046b4:	53                   	push   %ebx
f01046b5:	83 ec 1c             	sub    $0x1c,%esp
f01046b8:	8b 45 08             	mov    0x8(%ebp),%eax
	// Return any appropriate return value.
	// LAB 3: Your code here.

	// panic("syscall not implemented");

	switch (syscallno) {
f01046bb:	83 f8 10             	cmp    $0x10,%eax
f01046be:	0f 87 8d 05 00 00    	ja     f0104c51 <syscall+0x5a2>
f01046c4:	ff 24 85 2c 87 10 f0 	jmp    *-0xfef78d4(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, 0);		// just check if PTE_U is set
f01046cb:	e8 42 17 00 00       	call   f0105e12 <cpunum>
f01046d0:	6a 00                	push   $0x0
f01046d2:	ff 75 10             	pushl  0x10(%ebp)
f01046d5:	ff 75 0c             	pushl  0xc(%ebp)
f01046d8:	6b c0 74             	imul   $0x74,%eax,%eax
f01046db:	ff b0 28 d0 2a f0    	pushl  -0xfd52fd8(%eax)
f01046e1:	e8 71 e9 ff ff       	call   f0103057 <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f01046e6:	83 c4 0c             	add    $0xc,%esp
f01046e9:	ff 75 0c             	pushl  0xc(%ebp)
f01046ec:	ff 75 10             	pushl  0x10(%ebp)
f01046ef:	68 26 87 10 f0       	push   $0xf0108726
f01046f4:	e8 98 f2 ff ff       	call   f0103991 <cprintf>
f01046f9:	83 c4 10             	add    $0x10,%esp
	// panic("syscall not implemented");

	switch (syscallno) {
		case SYS_cputs:
			sys_cputs((char *)a1, a2);
			return 0;
f01046fc:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104701:	e9 57 05 00 00       	jmp    f0104c5d <syscall+0x5ae>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104706:	e8 00 bf ff ff       	call   f010060b <cons_getc>
f010470b:	89 c3                	mov    %eax,%ebx
	switch (syscallno) {
		case SYS_cputs:
			sys_cputs((char *)a1, a2);
			return 0;
		case SYS_cgetc:
			return sys_cgetc();
f010470d:	e9 4b 05 00 00       	jmp    f0104c5d <syscall+0x5ae>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104712:	e8 fb 16 00 00       	call   f0105e12 <cpunum>
f0104717:	6b c0 74             	imul   $0x74,%eax,%eax
f010471a:	8b 80 28 d0 2a f0    	mov    -0xfd52fd8(%eax),%eax
f0104720:	8b 58 48             	mov    0x48(%eax),%ebx
			sys_cputs((char *)a1, a2);
			return 0;
		case SYS_cgetc:
			return sys_cgetc();
		case SYS_getenvid:
			return sys_getenvid();
f0104723:	e9 35 05 00 00       	jmp    f0104c5d <syscall+0x5ae>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104728:	83 ec 04             	sub    $0x4,%esp
f010472b:	6a 01                	push   $0x1
f010472d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104730:	50                   	push   %eax
f0104731:	ff 75 0c             	pushl  0xc(%ebp)
f0104734:	e8 ec e9 ff ff       	call   f0103125 <envid2env>
f0104739:	83 c4 10             	add    $0x10,%esp
		return r;
f010473c:	89 c3                	mov    %eax,%ebx
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f010473e:	85 c0                	test   %eax,%eax
f0104740:	0f 88 17 05 00 00    	js     f0104c5d <syscall+0x5ae>
		return r;
	env_destroy(e);
f0104746:	83 ec 0c             	sub    $0xc,%esp
f0104749:	ff 75 e4             	pushl  -0x1c(%ebp)
f010474c:	e8 29 ef ff ff       	call   f010367a <env_destroy>
f0104751:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104754:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104759:	e9 ff 04 00 00       	jmp    f0104c5d <syscall+0x5ae>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f010475e:	e8 7d fe ff ff       	call   f01045e0 <sched_yield>
	// LAB 4: Your code here.
	// panic("sys_exofork not implemented");

	struct Env *newenv;

	int err = env_alloc(&newenv , curenv->env_id);
f0104763:	e8 aa 16 00 00       	call   f0105e12 <cpunum>
f0104768:	83 ec 08             	sub    $0x8,%esp
f010476b:	6b c0 74             	imul   $0x74,%eax,%eax
f010476e:	8b 80 28 d0 2a f0    	mov    -0xfd52fd8(%eax),%eax
f0104774:	ff 70 48             	pushl  0x48(%eax)
f0104777:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010477a:	50                   	push   %eax
f010477b:	e8 b0 ea ff ff       	call   f0103230 <env_alloc>
	if (err < 0)
f0104780:	83 c4 10             	add    $0x10,%esp
		return err;
f0104783:	89 c3                	mov    %eax,%ebx
	// panic("sys_exofork not implemented");

	struct Env *newenv;

	int err = env_alloc(&newenv , curenv->env_id);
	if (err < 0)
f0104785:	85 c0                	test   %eax,%eax
f0104787:	0f 88 d0 04 00 00    	js     f0104c5d <syscall+0x5ae>
		return err;

	// memcpy(&newenv->env_tf, &curenv->env_tf, sizeof(struct Trapframe));
	newenv->env_tf = curenv->env_tf;
f010478d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104790:	e8 7d 16 00 00       	call   f0105e12 <cpunum>
f0104795:	6b c0 74             	imul   $0x74,%eax,%eax
f0104798:	8b b0 28 d0 2a f0    	mov    -0xfd52fd8(%eax),%esi
f010479e:	b9 11 00 00 00       	mov    $0x11,%ecx
f01047a3:	89 df                	mov    %ebx,%edi
f01047a5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	newenv->env_status = ENV_NOT_RUNNABLE;
f01047a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01047aa:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)

	// tweak newenv, to make it appear to return 0
	newenv->env_tf.tf_regs.reg_eax = 0;
f01047b1:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

	return newenv->env_id;
f01047b8:	8b 58 48             	mov    0x48(%eax),%ebx
f01047bb:	e9 9d 04 00 00       	jmp    f0104c5d <syscall+0x5ae>

	// LAB 4: Your code here.
	// panic("sys_env_set_status not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
f01047c0:	83 ec 04             	sub    $0x4,%esp
f01047c3:	6a 01                	push   $0x1
f01047c5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01047c8:	50                   	push   %eax
f01047c9:	ff 75 0c             	pushl  0xc(%ebp)
f01047cc:	e8 54 e9 ff ff       	call   f0103125 <envid2env>
	if (err < 0)
f01047d1:	83 c4 10             	add    $0x10,%esp
f01047d4:	85 c0                	test   %eax,%eax
f01047d6:	78 20                	js     f01047f8 <syscall+0x149>
		return err;

	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
f01047d8:	8b 45 10             	mov    0x10(%ebp),%eax
f01047db:	83 e8 02             	sub    $0x2,%eax
f01047de:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f01047e3:	75 1a                	jne    f01047ff <syscall+0x150>
		return -E_INVAL;

	env_store->env_status = status;
f01047e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01047e8:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01047eb:	89 48 54             	mov    %ecx,0x54(%eax)

	return 0;
f01047ee:	bb 00 00 00 00       	mov    $0x0,%ebx
f01047f3:	e9 65 04 00 00       	jmp    f0104c5d <syscall+0x5ae>
	// panic("sys_env_set_status not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
	if (err < 0)
		return err;
f01047f8:	89 c3                	mov    %eax,%ebx
f01047fa:	e9 5e 04 00 00       	jmp    f0104c5d <syscall+0x5ae>

	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
		return -E_INVAL;
f01047ff:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			sys_yield();
			return 0;
		case SYS_exofork:
			return sys_exofork();
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1, a2);
f0104804:	e9 54 04 00 00       	jmp    f0104c5d <syscall+0x5ae>

	// LAB 4: Your code here.
	// panic("sys_page_alloc not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
f0104809:	83 ec 04             	sub    $0x4,%esp
f010480c:	6a 01                	push   $0x1
f010480e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104811:	50                   	push   %eax
f0104812:	ff 75 0c             	pushl  0xc(%ebp)
f0104815:	e8 0b e9 ff ff       	call   f0103125 <envid2env>
	if (err < 0)
f010481a:	83 c4 10             	add    $0x10,%esp
f010481d:	85 c0                	test   %eax,%eax
f010481f:	78 6b                	js     f010488c <syscall+0x1dd>
		return err;	// E_BAD_ENV

	if ((perm | PTE_AVAIL | PTE_W) != (PTE_AVAIL | PTE_W | PTE_U | PTE_P))
		return -E_INVAL;

	if ((uint32_t)va >= UTOP || ((uint32_t) va % PGSIZE) != 0)
f0104821:	8b 45 14             	mov    0x14(%ebp),%eax
f0104824:	0d 02 0e 00 00       	or     $0xe02,%eax
f0104829:	3d 07 0e 00 00       	cmp    $0xe07,%eax
f010482e:	75 63                	jne    f0104893 <syscall+0x1e4>
f0104830:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104837:	77 5a                	ja     f0104893 <syscall+0x1e4>
f0104839:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104840:	75 5b                	jne    f010489d <syscall+0x1ee>
		return -E_INVAL;
	
	struct PageInfo * pp = page_alloc(ALLOC_ZERO);
f0104842:	83 ec 0c             	sub    $0xc,%esp
f0104845:	6a 01                	push   $0x1
f0104847:	e8 54 c8 ff ff       	call   f01010a0 <page_alloc>
f010484c:	89 c6                	mov    %eax,%esi
	if (pp == NULL)
f010484e:	83 c4 10             	add    $0x10,%esp
f0104851:	85 c0                	test   %eax,%eax
f0104853:	74 52                	je     f01048a7 <syscall+0x1f8>
		return -E_NO_MEM;
	
	err = page_insert(env_store->env_pgdir, pp, va, perm);
f0104855:	ff 75 14             	pushl  0x14(%ebp)
f0104858:	ff 75 10             	pushl  0x10(%ebp)
f010485b:	50                   	push   %eax
f010485c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010485f:	ff 70 60             	pushl  0x60(%eax)
f0104862:	e8 2c cc ff ff       	call   f0101493 <page_insert>
f0104867:	89 c7                	mov    %eax,%edi
	if (err < 0) {
f0104869:	83 c4 10             	add    $0x10,%esp
		page_free(pp);
		return err; // E_NO_MEM
	}

	return 0;
f010486c:	bb 00 00 00 00       	mov    $0x0,%ebx
	struct PageInfo * pp = page_alloc(ALLOC_ZERO);
	if (pp == NULL)
		return -E_NO_MEM;
	
	err = page_insert(env_store->env_pgdir, pp, va, perm);
	if (err < 0) {
f0104871:	85 c0                	test   %eax,%eax
f0104873:	0f 89 e4 03 00 00    	jns    f0104c5d <syscall+0x5ae>
		page_free(pp);
f0104879:	83 ec 0c             	sub    $0xc,%esp
f010487c:	56                   	push   %esi
f010487d:	e8 8f c8 ff ff       	call   f0101111 <page_free>
f0104882:	83 c4 10             	add    $0x10,%esp
		return err; // E_NO_MEM
f0104885:	89 fb                	mov    %edi,%ebx
f0104887:	e9 d1 03 00 00       	jmp    f0104c5d <syscall+0x5ae>
	// panic("sys_page_alloc not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
	if (err < 0)
		return err;	// E_BAD_ENV
f010488c:	89 c3                	mov    %eax,%ebx
f010488e:	e9 ca 03 00 00       	jmp    f0104c5d <syscall+0x5ae>

	if ((perm | PTE_AVAIL | PTE_W) != (PTE_AVAIL | PTE_W | PTE_U | PTE_P))
		return -E_INVAL;

	if ((uint32_t)va >= UTOP || ((uint32_t) va % PGSIZE) != 0)
		return -E_INVAL;
f0104893:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104898:	e9 c0 03 00 00       	jmp    f0104c5d <syscall+0x5ae>
f010489d:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01048a2:	e9 b6 03 00 00       	jmp    f0104c5d <syscall+0x5ae>
	
	struct PageInfo * pp = page_alloc(ALLOC_ZERO);
	if (pp == NULL)
		return -E_NO_MEM;
f01048a7:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f01048ac:	e9 ac 03 00 00       	jmp    f0104c5d <syscall+0x5ae>
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	// panic("sys_page_map not implemented");

	if ((uint32_t)srcva >= UTOP || ((uint32_t)srcva % PGSIZE) != 0 || (uint32_t)dstva >= UTOP || ((uint32_t)dstva % PGSIZE != 0))
f01048b1:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01048b8:	0f 87 c2 00 00 00    	ja     f0104980 <syscall+0x2d1>
f01048be:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01048c5:	0f 85 bf 00 00 00    	jne    f010498a <syscall+0x2db>
f01048cb:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f01048d2:	0f 87 b2 00 00 00    	ja     f010498a <syscall+0x2db>
f01048d8:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f01048df:	0f 85 af 00 00 00    	jne    f0104994 <syscall+0x2e5>
		return -E_INVAL;
	
	struct Env *srcenv, *dstenv;
	int err = envid2env(srcenvid, &srcenv, 1);
f01048e5:	83 ec 04             	sub    $0x4,%esp
f01048e8:	6a 01                	push   $0x1
f01048ea:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01048ed:	50                   	push   %eax
f01048ee:	ff 75 0c             	pushl  0xc(%ebp)
f01048f1:	e8 2f e8 ff ff       	call   f0103125 <envid2env>
	if(err < 0)
f01048f6:	83 c4 10             	add    $0x10,%esp
		return err;	// E_BAD_ENV
f01048f9:	89 c3                	mov    %eax,%ebx
	if ((uint32_t)srcva >= UTOP || ((uint32_t)srcva % PGSIZE) != 0 || (uint32_t)dstva >= UTOP || ((uint32_t)dstva % PGSIZE != 0))
		return -E_INVAL;
	
	struct Env *srcenv, *dstenv;
	int err = envid2env(srcenvid, &srcenv, 1);
	if(err < 0)
f01048fb:	85 c0                	test   %eax,%eax
f01048fd:	0f 88 5a 03 00 00    	js     f0104c5d <syscall+0x5ae>
		return err;	// E_BAD_ENV
	err = envid2env(dstenvid, &dstenv, 1);
f0104903:	83 ec 04             	sub    $0x4,%esp
f0104906:	6a 01                	push   $0x1
f0104908:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010490b:	50                   	push   %eax
f010490c:	ff 75 14             	pushl  0x14(%ebp)
f010490f:	e8 11 e8 ff ff       	call   f0103125 <envid2env>
	if(err < 0)
f0104914:	83 c4 10             	add    $0x10,%esp
		return err;	// E_BAD_ENV
f0104917:	89 c3                	mov    %eax,%ebx
	struct Env *srcenv, *dstenv;
	int err = envid2env(srcenvid, &srcenv, 1);
	if(err < 0)
		return err;	// E_BAD_ENV
	err = envid2env(dstenvid, &dstenv, 1);
	if(err < 0)
f0104919:	85 c0                	test   %eax,%eax
f010491b:	0f 88 3c 03 00 00    	js     f0104c5d <syscall+0x5ae>
		return err;	// E_BAD_ENV

	pte_t *pte;
	struct PageInfo *pp = page_lookup(srcenv->env_pgdir, srcva, &pte);
f0104921:	83 ec 04             	sub    $0x4,%esp
f0104924:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104927:	50                   	push   %eax
f0104928:	ff 75 10             	pushl  0x10(%ebp)
f010492b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010492e:	ff 70 60             	pushl  0x60(%eax)
f0104931:	e8 75 ca ff ff       	call   f01013ab <page_lookup>
	if (pp == NULL) 
f0104936:	83 c4 10             	add    $0x10,%esp
f0104939:	85 c0                	test   %eax,%eax
f010493b:	74 61                	je     f010499e <syscall+0x2ef>
		return -E_INVAL;	// not mapped
	
	if ( ((*pte) & PTE_W) == 0 && (perm & PTE_W) != 0)
f010493d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104940:	f6 02 02             	testb  $0x2,(%edx)
f0104943:	75 06                	jne    f010494b <syscall+0x29c>
f0104945:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104949:	75 5d                	jne    f01049a8 <syscall+0x2f9>
		return -E_INVAL;	// read-only page

	// same perm restrictions as in sys_page_alloc
	if ((perm | PTE_AVAIL | PTE_W) != (PTE_AVAIL | PTE_W | PTE_U | PTE_P))
f010494b:	8b 55 1c             	mov    0x1c(%ebp),%edx
f010494e:	81 ca 02 0e 00 00    	or     $0xe02,%edx
f0104954:	81 fa 07 0e 00 00    	cmp    $0xe07,%edx
f010495a:	75 56                	jne    f01049b2 <syscall+0x303>
		return -E_INVAL;

	err = page_insert(dstenv->env_pgdir, pp, dstva, perm);
f010495c:	ff 75 1c             	pushl  0x1c(%ebp)
f010495f:	ff 75 18             	pushl  0x18(%ebp)
f0104962:	50                   	push   %eax
f0104963:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104966:	ff 70 60             	pushl  0x60(%eax)
f0104969:	e8 25 cb ff ff       	call   f0101493 <page_insert>
f010496e:	83 c4 10             	add    $0x10,%esp
f0104971:	85 c0                	test   %eax,%eax
f0104973:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104978:	0f 4e d8             	cmovle %eax,%ebx
f010497b:	e9 dd 02 00 00       	jmp    f0104c5d <syscall+0x5ae>

	// LAB 4: Your code here.
	// panic("sys_page_map not implemented");

	if ((uint32_t)srcva >= UTOP || ((uint32_t)srcva % PGSIZE) != 0 || (uint32_t)dstva >= UTOP || ((uint32_t)dstva % PGSIZE != 0))
		return -E_INVAL;
f0104980:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104985:	e9 d3 02 00 00       	jmp    f0104c5d <syscall+0x5ae>
f010498a:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010498f:	e9 c9 02 00 00       	jmp    f0104c5d <syscall+0x5ae>
f0104994:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104999:	e9 bf 02 00 00       	jmp    f0104c5d <syscall+0x5ae>
		return err;	// E_BAD_ENV

	pte_t *pte;
	struct PageInfo *pp = page_lookup(srcenv->env_pgdir, srcva, &pte);
	if (pp == NULL) 
		return -E_INVAL;	// not mapped
f010499e:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049a3:	e9 b5 02 00 00       	jmp    f0104c5d <syscall+0x5ae>
	
	if ( ((*pte) & PTE_W) == 0 && (perm & PTE_W) != 0)
		return -E_INVAL;	// read-only page
f01049a8:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049ad:	e9 ab 02 00 00       	jmp    f0104c5d <syscall+0x5ae>

	// same perm restrictions as in sys_page_alloc
	if ((perm | PTE_AVAIL | PTE_W) != (PTE_AVAIL | PTE_W | PTE_U | PTE_P))
		return -E_INVAL;
f01049b2:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1, a2);
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1, (void *)a2, a3);
		case SYS_page_map:
			return sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4, a5);
f01049b7:	e9 a1 02 00 00       	jmp    f0104c5d <syscall+0x5ae>
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	// panic("sys_page_unmap not implemented");

	if ((uint32_t)va >= UTOP || ((uint32_t) va % PGSIZE) != 0)
f01049bc:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01049c3:	77 45                	ja     f0104a0a <syscall+0x35b>
f01049c5:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01049cc:	75 46                	jne    f0104a14 <syscall+0x365>
		return -E_INVAL;

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
f01049ce:	83 ec 04             	sub    $0x4,%esp
f01049d1:	6a 01                	push   $0x1
f01049d3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01049d6:	50                   	push   %eax
f01049d7:	ff 75 0c             	pushl  0xc(%ebp)
f01049da:	e8 46 e7 ff ff       	call   f0103125 <envid2env>
	if (err < 0)
f01049df:	83 c4 10             	add    $0x10,%esp
		return err;	// E_BAD_ENV
f01049e2:	89 c3                	mov    %eax,%ebx
	if ((uint32_t)va >= UTOP || ((uint32_t) va % PGSIZE) != 0)
		return -E_INVAL;

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
	if (err < 0)
f01049e4:	85 c0                	test   %eax,%eax
f01049e6:	0f 88 71 02 00 00    	js     f0104c5d <syscall+0x5ae>
		return err;	// E_BAD_ENV

	page_remove(env_store->env_pgdir, va);
f01049ec:	83 ec 08             	sub    $0x8,%esp
f01049ef:	ff 75 10             	pushl  0x10(%ebp)
f01049f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01049f5:	ff 70 60             	pushl  0x60(%eax)
f01049f8:	e8 49 ca ff ff       	call   f0101446 <page_remove>
f01049fd:	83 c4 10             	add    $0x10,%esp

	return 0;
f0104a00:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104a05:	e9 53 02 00 00       	jmp    f0104c5d <syscall+0x5ae>

	// LAB 4: Your code here.
	// panic("sys_page_unmap not implemented");

	if ((uint32_t)va >= UTOP || ((uint32_t) va % PGSIZE) != 0)
		return -E_INVAL;
f0104a0a:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104a0f:	e9 49 02 00 00       	jmp    f0104c5d <syscall+0x5ae>
f0104a14:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104a19:	e9 3f 02 00 00       	jmp    f0104c5d <syscall+0x5ae>
{
	// LAB 4: Your code here.
	// panic("sys_env_set_pgfault_upcall not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
f0104a1e:	83 ec 04             	sub    $0x4,%esp
f0104a21:	6a 01                	push   $0x1
f0104a23:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104a26:	50                   	push   %eax
f0104a27:	ff 75 0c             	pushl  0xc(%ebp)
f0104a2a:	e8 f6 e6 ff ff       	call   f0103125 <envid2env>
	if (err < 0)
f0104a2f:	83 c4 10             	add    $0x10,%esp
f0104a32:	85 c0                	test   %eax,%eax
f0104a34:	78 13                	js     f0104a49 <syscall+0x39a>
		return err;

	env_store->env_pgfault_upcall = func;
f0104a36:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104a39:	8b 55 10             	mov    0x10(%ebp),%edx
f0104a3c:	89 50 64             	mov    %edx,0x64(%eax)

	return 0;
f0104a3f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104a44:	e9 14 02 00 00       	jmp    f0104c5d <syscall+0x5ae>
	// panic("sys_env_set_pgfault_upcall not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
	if (err < 0)
		return err;
f0104a49:	89 c3                	mov    %eax,%ebx
		case SYS_page_map:
			return sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4, a5);
		case SYS_page_unmap:
			return sys_page_unmap((envid_t)a1, (void *)a2);
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
f0104a4b:	e9 0d 02 00 00       	jmp    f0104c5d <syscall+0x5ae>
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	// panic("sys_ipc_recv not implemented");

	if ((uint32_t)dstva < UTOP) {
f0104a50:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0104a57:	77 21                	ja     f0104a7a <syscall+0x3cb>
		if ((uint32_t)dstva % PGSIZE != 0)
f0104a59:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0104a60:	0f 85 f2 01 00 00    	jne    f0104c58 <syscall+0x5a9>
			return -E_INVAL;
		curenv->env_ipc_dstva = dstva;
f0104a66:	e8 a7 13 00 00       	call   f0105e12 <cpunum>
f0104a6b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a6e:	8b 80 28 d0 2a f0    	mov    -0xfd52fd8(%eax),%eax
f0104a74:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104a77:	89 78 6c             	mov    %edi,0x6c(%eax)
	}

	// set recving flags
	curenv->env_ipc_recving = true;
f0104a7a:	e8 93 13 00 00       	call   f0105e12 <cpunum>
f0104a7f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a82:	8b 80 28 d0 2a f0    	mov    -0xfd52fd8(%eax),%eax
f0104a88:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_from = 0;
f0104a8c:	e8 81 13 00 00       	call   f0105e12 <cpunum>
f0104a91:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a94:	8b 80 28 d0 2a f0    	mov    -0xfd52fd8(%eax),%eax
f0104a9a:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)

	// mark yourself not runnable, and then give up the CPU.
	curenv->env_status = ENV_NOT_RUNNABLE;
f0104aa1:	e8 6c 13 00 00       	call   f0105e12 <cpunum>
f0104aa6:	6b c0 74             	imul   $0x74,%eax,%eax
f0104aa9:	8b 80 28 d0 2a f0    	mov    -0xfd52fd8(%eax),%eax
f0104aaf:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	sched_yield();
f0104ab6:	e8 25 fb ff ff       	call   f01045e0 <sched_yield>
{
	// LAB 4: Your code here.
	// panic("sys_ipc_try_send not implemented");

	struct Env *env;
	int err = envid2env(envid, &env, 0);
f0104abb:	83 ec 04             	sub    $0x4,%esp
f0104abe:	6a 00                	push   $0x0
f0104ac0:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104ac3:	50                   	push   %eax
f0104ac4:	ff 75 0c             	pushl  0xc(%ebp)
f0104ac7:	e8 59 e6 ff ff       	call   f0103125 <envid2env>
	if(err < 0)
f0104acc:	83 c4 10             	add    $0x10,%esp
f0104acf:	85 c0                	test   %eax,%eax
f0104ad1:	0f 88 05 01 00 00    	js     f0104bdc <syscall+0x52d>
		return err;	// E_BAD_ENV
	
	// not recving, or already recving
	if (env->env_ipc_recving != true || env->env_ipc_from != 0)
f0104ad7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104ada:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0104ade:	0f 84 fc 00 00 00    	je     f0104be0 <syscall+0x531>
f0104ae4:	8b 58 74             	mov    0x74(%eax),%ebx
f0104ae7:	85 db                	test   %ebx,%ebx
f0104ae9:	0f 85 f8 00 00 00    	jne    f0104be7 <syscall+0x538>

	// first check if the recver is willing to recv a page
	// any error happens, fall fast
	if (env->env_ipc_dstva != 0) {
		
		if ((uint32_t)srcva < UTOP) {
f0104aef:	83 78 6c 00          	cmpl   $0x0,0x6c(%eax)
f0104af3:	0f 84 ac 00 00 00    	je     f0104ba5 <syscall+0x4f6>
f0104af9:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104b00:	0f 87 9f 00 00 00    	ja     f0104ba5 <syscall+0x4f6>
			if ((uint32_t)srcva % PGSIZE != 0)
f0104b06:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0104b0d:	75 64                	jne    f0104b73 <syscall+0x4c4>
				return -E_INVAL;
			if ((perm & (PTE_P | PTE_U)) != (PTE_P | PTE_U))
f0104b0f:	8b 45 18             	mov    0x18(%ebp),%eax
f0104b12:	83 e0 05             	and    $0x5,%eax
f0104b15:	83 f8 05             	cmp    $0x5,%eax
f0104b18:	75 63                	jne    f0104b7d <syscall+0x4ce>
            	return -E_INVAL;

			pte_t *pte;
			struct PageInfo *pp = page_lookup(curenv->env_pgdir, srcva, &pte);
f0104b1a:	e8 f3 12 00 00       	call   f0105e12 <cpunum>
f0104b1f:	83 ec 04             	sub    $0x4,%esp
f0104b22:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104b25:	52                   	push   %edx
f0104b26:	ff 75 14             	pushl  0x14(%ebp)
f0104b29:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b2c:	8b 80 28 d0 2a f0    	mov    -0xfd52fd8(%eax),%eax
f0104b32:	ff 70 60             	pushl  0x60(%eax)
f0104b35:	e8 71 c8 ff ff       	call   f01013ab <page_lookup>
			if (!pp) 
f0104b3a:	83 c4 10             	add    $0x10,%esp
f0104b3d:	85 c0                	test   %eax,%eax
f0104b3f:	74 46                	je     f0104b87 <syscall+0x4d8>
				return -E_INVAL;  
			
			if ((perm & PTE_W) && ((size_t) *pte & PTE_W) != PTE_W) 
f0104b41:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104b45:	74 08                	je     f0104b4f <syscall+0x4a0>
f0104b47:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104b4a:	f6 02 02             	testb  $0x2,(%edx)
f0104b4d:	74 42                	je     f0104b91 <syscall+0x4e2>
				return -E_INVAL;

			if (page_insert(env->env_pgdir, pp, env->env_ipc_dstva, perm) < 0) 
f0104b4f:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104b52:	ff 75 18             	pushl  0x18(%ebp)
f0104b55:	ff 72 6c             	pushl  0x6c(%edx)
f0104b58:	50                   	push   %eax
f0104b59:	ff 72 60             	pushl  0x60(%edx)
f0104b5c:	e8 32 c9 ff ff       	call   f0101493 <page_insert>
f0104b61:	83 c4 10             	add    $0x10,%esp
f0104b64:	85 c0                	test   %eax,%eax
f0104b66:	78 33                	js     f0104b9b <syscall+0x4ec>
				return -E_NO_MEM;
			
			env->env_ipc_perm = perm;
f0104b68:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b6b:	8b 7d 18             	mov    0x18(%ebp),%edi
f0104b6e:	89 78 78             	mov    %edi,0x78(%eax)
f0104b71:	eb 32                	jmp    f0104ba5 <syscall+0x4f6>
	// any error happens, fall fast
	if (env->env_ipc_dstva != 0) {
		
		if ((uint32_t)srcva < UTOP) {
			if ((uint32_t)srcva % PGSIZE != 0)
				return -E_INVAL;
f0104b73:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b78:	e9 e0 00 00 00       	jmp    f0104c5d <syscall+0x5ae>
			if ((perm & (PTE_P | PTE_U)) != (PTE_P | PTE_U))
            	return -E_INVAL;
f0104b7d:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b82:	e9 d6 00 00 00       	jmp    f0104c5d <syscall+0x5ae>

			pte_t *pte;
			struct PageInfo *pp = page_lookup(curenv->env_pgdir, srcva, &pte);
			if (!pp) 
				return -E_INVAL;  
f0104b87:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b8c:	e9 cc 00 00 00       	jmp    f0104c5d <syscall+0x5ae>
			
			if ((perm & PTE_W) && ((size_t) *pte & PTE_W) != PTE_W) 
				return -E_INVAL;
f0104b91:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b96:	e9 c2 00 00 00       	jmp    f0104c5d <syscall+0x5ae>

			if (page_insert(env->env_pgdir, pp, env->env_ipc_dstva, perm) < 0) 
				return -E_NO_MEM;
f0104b9b:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f0104ba0:	e9 b8 00 00 00       	jmp    f0104c5d <syscall+0x5ae>
			env->env_ipc_perm = perm;
		}

	}

	env->env_ipc_from = curenv->env_id;
f0104ba5:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104ba8:	e8 65 12 00 00       	call   f0105e12 <cpunum>
f0104bad:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bb0:	8b 80 28 d0 2a f0    	mov    -0xfd52fd8(%eax),%eax
f0104bb6:	8b 40 48             	mov    0x48(%eax),%eax
f0104bb9:	89 46 74             	mov    %eax,0x74(%esi)
	env->env_ipc_recving = false;
f0104bbc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104bbf:	c6 40 68 00          	movb   $0x0,0x68(%eax)
	env->env_ipc_value = value;
f0104bc3:	8b 55 10             	mov    0x10(%ebp),%edx
f0104bc6:	89 50 70             	mov    %edx,0x70(%eax)
	env->env_status = ENV_RUNNABLE;
f0104bc9:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)

	// make the recver return 0
	env->env_tf.tf_regs.reg_eax = 0;
f0104bd0:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
f0104bd7:	e9 81 00 00 00       	jmp    f0104c5d <syscall+0x5ae>
	// panic("sys_ipc_try_send not implemented");

	struct Env *env;
	int err = envid2env(envid, &env, 0);
	if(err < 0)
		return err;	// E_BAD_ENV
f0104bdc:	89 c3                	mov    %eax,%ebx
f0104bde:	eb 7d                	jmp    f0104c5d <syscall+0x5ae>
	
	// not recving, or already recving
	if (env->env_ipc_recving != true || env->env_ipc_from != 0)
		return -E_IPC_NOT_RECV;
f0104be0:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f0104be5:	eb 76                	jmp    f0104c5d <syscall+0x5ae>
f0104be7:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
		case SYS_ipc_recv:
			return sys_ipc_recv((void *)a1);
		case SYS_ipc_try_send:
			return sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned)a4);
f0104bec:	eb 6f                	jmp    f0104c5d <syscall+0x5ae>
		case SYS_env_set_trapframe:
			return sys_env_set_trapframe((envid_t)a1, (struct Trapframe *)a2);
f0104bee:	8b 75 10             	mov    0x10(%ebp),%esi
	// Remember to check whether the user has supplied us with a good
	// address!
	// panic("sys_env_set_trapframe not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
f0104bf1:	83 ec 04             	sub    $0x4,%esp
f0104bf4:	6a 01                	push   $0x1
f0104bf6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104bf9:	50                   	push   %eax
f0104bfa:	ff 75 0c             	pushl  0xc(%ebp)
f0104bfd:	e8 23 e5 ff ff       	call   f0103125 <envid2env>
	if (err < 0)
f0104c02:	83 c4 10             	add    $0x10,%esp
f0104c05:	85 c0                	test   %eax,%eax
f0104c07:	78 11                	js     f0104c1a <syscall+0x56b>
		return err;
	
	env_store->env_tf = *tf;
f0104c09:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104c0e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104c11:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

	return 0;
f0104c13:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104c18:	eb 43                	jmp    f0104c5d <syscall+0x5ae>
	// panic("sys_env_set_trapframe not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
	if (err < 0)
		return err;
f0104c1a:	89 c3                	mov    %eax,%ebx
		case SYS_ipc_recv:
			return sys_ipc_recv((void *)a1);
		case SYS_ipc_try_send:
			return sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned)a4);
		case SYS_env_set_trapframe:
			return sys_env_set_trapframe((envid_t)a1, (struct Trapframe *)a2);
f0104c1c:	eb 3f                	jmp    f0104c5d <syscall+0x5ae>
sys_time_msec(void)
{
	// LAB 6: Your code here.
	// panic("sys_time_msec not implemented");

	return time_msec();
f0104c1e:	e8 40 1f 00 00       	call   f0106b63 <time_msec>
f0104c23:	89 c3                	mov    %eax,%ebx
		case SYS_ipc_try_send:
			return sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned)a4);
		case SYS_env_set_trapframe:
			return sys_env_set_trapframe((envid_t)a1, (struct Trapframe *)a2);
		case SYS_time_msec:
			return sys_time_msec();
f0104c25:	eb 36                	jmp    f0104c5d <syscall+0x5ae>
		case SYS_e1000_try_send:
			return sys_e1000_try_send((void *)a1, (uint32_t)a2);
f0104c27:	83 ec 08             	sub    $0x8,%esp
f0104c2a:	ff 75 10             	pushl  0x10(%ebp)
f0104c2d:	ff 75 0c             	pushl  0xc(%ebp)
f0104c30:	e8 34 fa ff ff       	call   f0104669 <sys_e1000_try_send>
f0104c35:	89 c3                	mov    %eax,%ebx
f0104c37:	83 c4 10             	add    $0x10,%esp
f0104c3a:	eb 21                	jmp    f0104c5d <syscall+0x5ae>
}

int 
sys_e1000_try_recv(void *buf, uint32_t *len)
{
	return e1000_receive(buf, len);
f0104c3c:	83 ec 08             	sub    $0x8,%esp
f0104c3f:	ff 75 10             	pushl  0x10(%ebp)
f0104c42:	ff 75 0c             	pushl  0xc(%ebp)
f0104c45:	e8 1b 19 00 00       	call   f0106565 <e1000_receive>
f0104c4a:	89 c3                	mov    %eax,%ebx
		case SYS_time_msec:
			return sys_time_msec();
		case SYS_e1000_try_send:
			return sys_e1000_try_send((void *)a1, (uint32_t)a2);
		case SYS_e1000_try_recv:
			return sys_e1000_try_recv((void *)a1, (uint32_t *)a2);
f0104c4c:	83 c4 10             	add    $0x10,%esp
f0104c4f:	eb 0c                	jmp    f0104c5d <syscall+0x5ae>
		default:
			return -E_INVAL;
f0104c51:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104c56:	eb 05                	jmp    f0104c5d <syscall+0x5ae>
		case SYS_page_unmap:
			return sys_page_unmap((envid_t)a1, (void *)a2);
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
		case SYS_ipc_recv:
			return sys_ipc_recv((void *)a1);
f0104c58:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		case SYS_e1000_try_recv:
			return sys_e1000_try_recv((void *)a1, (uint32_t *)a2);
		default:
			return -E_INVAL;
	}
}
f0104c5d:	89 d8                	mov    %ebx,%eax
f0104c5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104c62:	5b                   	pop    %ebx
f0104c63:	5e                   	pop    %esi
f0104c64:	5f                   	pop    %edi
f0104c65:	5d                   	pop    %ebp
f0104c66:	c3                   	ret    

f0104c67 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104c67:	55                   	push   %ebp
f0104c68:	89 e5                	mov    %esp,%ebp
f0104c6a:	57                   	push   %edi
f0104c6b:	56                   	push   %esi
f0104c6c:	53                   	push   %ebx
f0104c6d:	83 ec 14             	sub    $0x14,%esp
f0104c70:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104c73:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104c76:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104c79:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104c7c:	8b 1a                	mov    (%edx),%ebx
f0104c7e:	8b 01                	mov    (%ecx),%eax
f0104c80:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104c83:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104c8a:	eb 7f                	jmp    f0104d0b <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0104c8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104c8f:	01 d8                	add    %ebx,%eax
f0104c91:	89 c6                	mov    %eax,%esi
f0104c93:	c1 ee 1f             	shr    $0x1f,%esi
f0104c96:	01 c6                	add    %eax,%esi
f0104c98:	d1 fe                	sar    %esi
f0104c9a:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0104c9d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104ca0:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104ca3:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104ca5:	eb 03                	jmp    f0104caa <stab_binsearch+0x43>
			m--;
f0104ca7:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104caa:	39 c3                	cmp    %eax,%ebx
f0104cac:	7f 0d                	jg     f0104cbb <stab_binsearch+0x54>
f0104cae:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104cb2:	83 ea 0c             	sub    $0xc,%edx
f0104cb5:	39 f9                	cmp    %edi,%ecx
f0104cb7:	75 ee                	jne    f0104ca7 <stab_binsearch+0x40>
f0104cb9:	eb 05                	jmp    f0104cc0 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104cbb:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0104cbe:	eb 4b                	jmp    f0104d0b <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104cc0:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104cc3:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104cc6:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104cca:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104ccd:	76 11                	jbe    f0104ce0 <stab_binsearch+0x79>
			*region_left = m;
f0104ccf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104cd2:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104cd4:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104cd7:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104cde:	eb 2b                	jmp    f0104d0b <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104ce0:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104ce3:	73 14                	jae    f0104cf9 <stab_binsearch+0x92>
			*region_right = m - 1;
f0104ce5:	83 e8 01             	sub    $0x1,%eax
f0104ce8:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104ceb:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104cee:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104cf0:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104cf7:	eb 12                	jmp    f0104d0b <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104cf9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104cfc:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0104cfe:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104d02:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104d04:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104d0b:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104d0e:	0f 8e 78 ff ff ff    	jle    f0104c8c <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104d14:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104d18:	75 0f                	jne    f0104d29 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0104d1a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104d1d:	8b 00                	mov    (%eax),%eax
f0104d1f:	83 e8 01             	sub    $0x1,%eax
f0104d22:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104d25:	89 06                	mov    %eax,(%esi)
f0104d27:	eb 2c                	jmp    f0104d55 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104d29:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104d2c:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104d2e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104d31:	8b 0e                	mov    (%esi),%ecx
f0104d33:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104d36:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104d39:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104d3c:	eb 03                	jmp    f0104d41 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0104d3e:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104d41:	39 c8                	cmp    %ecx,%eax
f0104d43:	7e 0b                	jle    f0104d50 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0104d45:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0104d49:	83 ea 0c             	sub    $0xc,%edx
f0104d4c:	39 df                	cmp    %ebx,%edi
f0104d4e:	75 ee                	jne    f0104d3e <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0104d50:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104d53:	89 06                	mov    %eax,(%esi)
	}
}
f0104d55:	83 c4 14             	add    $0x14,%esp
f0104d58:	5b                   	pop    %ebx
f0104d59:	5e                   	pop    %esi
f0104d5a:	5f                   	pop    %edi
f0104d5b:	5d                   	pop    %ebp
f0104d5c:	c3                   	ret    

f0104d5d <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104d5d:	55                   	push   %ebp
f0104d5e:	89 e5                	mov    %esp,%ebp
f0104d60:	57                   	push   %edi
f0104d61:	56                   	push   %esi
f0104d62:	53                   	push   %ebx
f0104d63:	83 ec 3c             	sub    $0x3c,%esp
f0104d66:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104d69:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104d6c:	c7 03 70 87 10 f0    	movl   $0xf0108770,(%ebx)
	info->eip_line = 0;
f0104d72:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104d79:	c7 43 08 70 87 10 f0 	movl   $0xf0108770,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104d80:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104d87:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104d8a:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104d91:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0104d97:	0f 87 a3 00 00 00    	ja     f0104e40 <debuginfo_eip+0xe3>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0104d9d:	a1 00 00 20 00       	mov    0x200000,%eax
f0104da2:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stab_end = usd->stab_end;
f0104da5:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f0104dab:	8b 15 08 00 20 00    	mov    0x200008,%edx
f0104db1:	89 55 b8             	mov    %edx,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f0104db4:	a1 0c 00 20 00       	mov    0x20000c,%eax
f0104db9:	89 45 bc             	mov    %eax,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0 ||
f0104dbc:	e8 51 10 00 00       	call   f0105e12 <cpunum>
f0104dc1:	6a 04                	push   $0x4
f0104dc3:	6a 10                	push   $0x10
f0104dc5:	68 00 00 20 00       	push   $0x200000
f0104dca:	6b c0 74             	imul   $0x74,%eax,%eax
f0104dcd:	ff b0 28 d0 2a f0    	pushl  -0xfd52fd8(%eax)
f0104dd3:	e8 97 e1 ff ff       	call   f0102f6f <user_mem_check>
f0104dd8:	83 c4 10             	add    $0x10,%esp
f0104ddb:	85 c0                	test   %eax,%eax
f0104ddd:	0f 88 27 02 00 00    	js     f010500a <debuginfo_eip+0x2ad>
			user_mem_check(curenv, stabs, stab_end-stabs, PTE_U) < 0 ||
f0104de3:	e8 2a 10 00 00       	call   f0105e12 <cpunum>
f0104de8:	6a 04                	push   $0x4
f0104dea:	89 f2                	mov    %esi,%edx
f0104dec:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104def:	29 ca                	sub    %ecx,%edx
f0104df1:	c1 fa 02             	sar    $0x2,%edx
f0104df4:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0104dfa:	52                   	push   %edx
f0104dfb:	51                   	push   %ecx
f0104dfc:	6b c0 74             	imul   $0x74,%eax,%eax
f0104dff:	ff b0 28 d0 2a f0    	pushl  -0xfd52fd8(%eax)
f0104e05:	e8 65 e1 ff ff       	call   f0102f6f <user_mem_check>
		stabstr = usd->stabstr;
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0 ||
f0104e0a:	83 c4 10             	add    $0x10,%esp
f0104e0d:	85 c0                	test   %eax,%eax
f0104e0f:	0f 88 fc 01 00 00    	js     f0105011 <debuginfo_eip+0x2b4>
			user_mem_check(curenv, stabs, stab_end-stabs, PTE_U) < 0 ||
			user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U) < 0
f0104e15:	e8 f8 0f 00 00       	call   f0105e12 <cpunum>
f0104e1a:	6a 04                	push   $0x4
f0104e1c:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0104e1f:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0104e22:	29 ca                	sub    %ecx,%edx
f0104e24:	52                   	push   %edx
f0104e25:	51                   	push   %ecx
f0104e26:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e29:	ff b0 28 d0 2a f0    	pushl  -0xfd52fd8(%eax)
f0104e2f:	e8 3b e1 ff ff       	call   f0102f6f <user_mem_check>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0 ||
			user_mem_check(curenv, stabs, stab_end-stabs, PTE_U) < 0 ||
f0104e34:	83 c4 10             	add    $0x10,%esp
f0104e37:	85 c0                	test   %eax,%eax
f0104e39:	79 1f                	jns    f0104e5a <debuginfo_eip+0xfd>
f0104e3b:	e9 d8 01 00 00       	jmp    f0105018 <debuginfo_eip+0x2bb>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104e40:	c7 45 bc 1e 93 11 f0 	movl   $0xf011931e,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0104e47:	c7 45 b8 b9 4b 11 f0 	movl   $0xf0114bb9,-0x48(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0104e4e:	be b8 4b 11 f0       	mov    $0xf0114bb8,%esi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104e53:	c7 45 c0 84 8f 10 f0 	movl   $0xf0108f84,-0x40(%ebp)
		)
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104e5a:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104e5d:	39 45 b8             	cmp    %eax,-0x48(%ebp)
f0104e60:	0f 83 b9 01 00 00    	jae    f010501f <debuginfo_eip+0x2c2>
f0104e66:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0104e6a:	0f 85 b6 01 00 00    	jne    f0105026 <debuginfo_eip+0x2c9>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104e70:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104e77:	2b 75 c0             	sub    -0x40(%ebp),%esi
f0104e7a:	c1 fe 02             	sar    $0x2,%esi
f0104e7d:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f0104e83:	83 e8 01             	sub    $0x1,%eax
f0104e86:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104e89:	83 ec 08             	sub    $0x8,%esp
f0104e8c:	57                   	push   %edi
f0104e8d:	6a 64                	push   $0x64
f0104e8f:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0104e92:	89 d1                	mov    %edx,%ecx
f0104e94:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104e97:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0104e9a:	89 f0                	mov    %esi,%eax
f0104e9c:	e8 c6 fd ff ff       	call   f0104c67 <stab_binsearch>
	if (lfile == 0)
f0104ea1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104ea4:	83 c4 10             	add    $0x10,%esp
f0104ea7:	85 c0                	test   %eax,%eax
f0104ea9:	0f 84 7e 01 00 00    	je     f010502d <debuginfo_eip+0x2d0>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104eaf:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104eb2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104eb5:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104eb8:	83 ec 08             	sub    $0x8,%esp
f0104ebb:	57                   	push   %edi
f0104ebc:	6a 24                	push   $0x24
f0104ebe:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0104ec1:	89 d1                	mov    %edx,%ecx
f0104ec3:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104ec6:	89 f0                	mov    %esi,%eax
f0104ec8:	e8 9a fd ff ff       	call   f0104c67 <stab_binsearch>

	if (lfun <= rfun) {
f0104ecd:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104ed0:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104ed3:	83 c4 10             	add    $0x10,%esp
f0104ed6:	39 d0                	cmp    %edx,%eax
f0104ed8:	7f 2e                	jg     f0104f08 <debuginfo_eip+0x1ab>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104eda:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0104edd:	8d 34 8e             	lea    (%esi,%ecx,4),%esi
f0104ee0:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f0104ee3:	8b 36                	mov    (%esi),%esi
f0104ee5:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0104ee8:	2b 4d b8             	sub    -0x48(%ebp),%ecx
f0104eeb:	39 ce                	cmp    %ecx,%esi
f0104eed:	73 06                	jae    f0104ef5 <debuginfo_eip+0x198>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104eef:	03 75 b8             	add    -0x48(%ebp),%esi
f0104ef2:	89 73 08             	mov    %esi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104ef5:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0104ef8:	8b 4e 08             	mov    0x8(%esi),%ecx
f0104efb:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0104efe:	29 cf                	sub    %ecx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0104f00:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104f03:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0104f06:	eb 0f                	jmp    f0104f17 <debuginfo_eip+0x1ba>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104f08:	89 7b 10             	mov    %edi,0x10(%ebx)
		lline = lfile;
f0104f0b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104f0e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104f11:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104f14:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104f17:	83 ec 08             	sub    $0x8,%esp
f0104f1a:	6a 3a                	push   $0x3a
f0104f1c:	ff 73 08             	pushl  0x8(%ebx)
f0104f1f:	e8 af 08 00 00       	call   f01057d3 <strfind>
f0104f24:	2b 43 08             	sub    0x8(%ebx),%eax
f0104f27:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.


	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104f2a:	83 c4 08             	add    $0x8,%esp
f0104f2d:	57                   	push   %edi
f0104f2e:	6a 44                	push   $0x44
f0104f30:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104f33:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104f36:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0104f39:	89 f0                	mov    %esi,%eax
f0104f3b:	e8 27 fd ff ff       	call   f0104c67 <stab_binsearch>
	if (lline == 0)
f0104f40:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0104f43:	83 c4 10             	add    $0x10,%esp
f0104f46:	85 d2                	test   %edx,%edx
f0104f48:	0f 84 e6 00 00 00    	je     f0105034 <debuginfo_eip+0x2d7>
		return -1;
	// cprintf("[+] %d, %d, %d, %x\n", lline, rline, lfun, stabs[lfun].n_value);
	info->eip_line = stabs[rline].n_desc;
f0104f4e:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104f51:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104f54:	0f b7 44 86 06       	movzwl 0x6(%esi,%eax,4),%eax
f0104f59:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104f5c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104f5f:	89 d0                	mov    %edx,%eax
f0104f61:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104f64:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0104f67:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0104f6b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104f6e:	eb 0a                	jmp    f0104f7a <debuginfo_eip+0x21d>
f0104f70:	83 e8 01             	sub    $0x1,%eax
f0104f73:	83 ea 0c             	sub    $0xc,%edx
f0104f76:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0104f7a:	39 c7                	cmp    %eax,%edi
f0104f7c:	7e 05                	jle    f0104f83 <debuginfo_eip+0x226>
f0104f7e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104f81:	eb 47                	jmp    f0104fca <debuginfo_eip+0x26d>
	       && stabs[lline].n_type != N_SOL
f0104f83:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104f87:	80 f9 84             	cmp    $0x84,%cl
f0104f8a:	75 0e                	jne    f0104f9a <debuginfo_eip+0x23d>
f0104f8c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104f8f:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104f93:	74 1c                	je     f0104fb1 <debuginfo_eip+0x254>
f0104f95:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104f98:	eb 17                	jmp    f0104fb1 <debuginfo_eip+0x254>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104f9a:	80 f9 64             	cmp    $0x64,%cl
f0104f9d:	75 d1                	jne    f0104f70 <debuginfo_eip+0x213>
f0104f9f:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0104fa3:	74 cb                	je     f0104f70 <debuginfo_eip+0x213>
f0104fa5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104fa8:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104fac:	74 03                	je     f0104fb1 <debuginfo_eip+0x254>
f0104fae:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104fb1:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104fb4:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104fb7:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0104fba:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104fbd:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0104fc0:	29 f8                	sub    %edi,%eax
f0104fc2:	39 c2                	cmp    %eax,%edx
f0104fc4:	73 04                	jae    f0104fca <debuginfo_eip+0x26d>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104fc6:	01 fa                	add    %edi,%edx
f0104fc8:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104fca:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104fcd:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104fd0:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104fd5:	39 f2                	cmp    %esi,%edx
f0104fd7:	7d 67                	jge    f0105040 <debuginfo_eip+0x2e3>
		for (lline = lfun + 1;
f0104fd9:	83 c2 01             	add    $0x1,%edx
f0104fdc:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104fdf:	89 d0                	mov    %edx,%eax
f0104fe1:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104fe4:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104fe7:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0104fea:	eb 04                	jmp    f0104ff0 <debuginfo_eip+0x293>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104fec:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104ff0:	39 c6                	cmp    %eax,%esi
f0104ff2:	7e 47                	jle    f010503b <debuginfo_eip+0x2de>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104ff4:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104ff8:	83 c0 01             	add    $0x1,%eax
f0104ffb:	83 c2 0c             	add    $0xc,%edx
f0104ffe:	80 f9 a0             	cmp    $0xa0,%cl
f0105001:	74 e9                	je     f0104fec <debuginfo_eip+0x28f>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105003:	b8 00 00 00 00       	mov    $0x0,%eax
f0105008:	eb 36                	jmp    f0105040 <debuginfo_eip+0x2e3>
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0 ||
			user_mem_check(curenv, stabs, stab_end-stabs, PTE_U) < 0 ||
			user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U) < 0
		)
			return -1;
f010500a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010500f:	eb 2f                	jmp    f0105040 <debuginfo_eip+0x2e3>
f0105011:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105016:	eb 28                	jmp    f0105040 <debuginfo_eip+0x2e3>
f0105018:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010501d:	eb 21                	jmp    f0105040 <debuginfo_eip+0x2e3>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f010501f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105024:	eb 1a                	jmp    f0105040 <debuginfo_eip+0x2e3>
f0105026:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010502b:	eb 13                	jmp    f0105040 <debuginfo_eip+0x2e3>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f010502d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105032:	eb 0c                	jmp    f0105040 <debuginfo_eip+0x2e3>
	// Your code here.


	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline == 0)
		return -1;
f0105034:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105039:	eb 05                	jmp    f0105040 <debuginfo_eip+0x2e3>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010503b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105040:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105043:	5b                   	pop    %ebx
f0105044:	5e                   	pop    %esi
f0105045:	5f                   	pop    %edi
f0105046:	5d                   	pop    %ebp
f0105047:	c3                   	ret    

f0105048 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105048:	55                   	push   %ebp
f0105049:	89 e5                	mov    %esp,%ebp
f010504b:	57                   	push   %edi
f010504c:	56                   	push   %esi
f010504d:	53                   	push   %ebx
f010504e:	83 ec 1c             	sub    $0x1c,%esp
f0105051:	89 c7                	mov    %eax,%edi
f0105053:	89 d6                	mov    %edx,%esi
f0105055:	8b 45 08             	mov    0x8(%ebp),%eax
f0105058:	8b 55 0c             	mov    0xc(%ebp),%edx
f010505b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010505e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105061:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0105064:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105069:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010506c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f010506f:	39 d3                	cmp    %edx,%ebx
f0105071:	72 05                	jb     f0105078 <printnum+0x30>
f0105073:	39 45 10             	cmp    %eax,0x10(%ebp)
f0105076:	77 45                	ja     f01050bd <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105078:	83 ec 0c             	sub    $0xc,%esp
f010507b:	ff 75 18             	pushl  0x18(%ebp)
f010507e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105081:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0105084:	53                   	push   %ebx
f0105085:	ff 75 10             	pushl  0x10(%ebp)
f0105088:	83 ec 08             	sub    $0x8,%esp
f010508b:	ff 75 e4             	pushl  -0x1c(%ebp)
f010508e:	ff 75 e0             	pushl  -0x20(%ebp)
f0105091:	ff 75 dc             	pushl  -0x24(%ebp)
f0105094:	ff 75 d8             	pushl  -0x28(%ebp)
f0105097:	e8 e4 1a 00 00       	call   f0106b80 <__udivdi3>
f010509c:	83 c4 18             	add    $0x18,%esp
f010509f:	52                   	push   %edx
f01050a0:	50                   	push   %eax
f01050a1:	89 f2                	mov    %esi,%edx
f01050a3:	89 f8                	mov    %edi,%eax
f01050a5:	e8 9e ff ff ff       	call   f0105048 <printnum>
f01050aa:	83 c4 20             	add    $0x20,%esp
f01050ad:	eb 18                	jmp    f01050c7 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01050af:	83 ec 08             	sub    $0x8,%esp
f01050b2:	56                   	push   %esi
f01050b3:	ff 75 18             	pushl  0x18(%ebp)
f01050b6:	ff d7                	call   *%edi
f01050b8:	83 c4 10             	add    $0x10,%esp
f01050bb:	eb 03                	jmp    f01050c0 <printnum+0x78>
f01050bd:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01050c0:	83 eb 01             	sub    $0x1,%ebx
f01050c3:	85 db                	test   %ebx,%ebx
f01050c5:	7f e8                	jg     f01050af <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01050c7:	83 ec 08             	sub    $0x8,%esp
f01050ca:	56                   	push   %esi
f01050cb:	83 ec 04             	sub    $0x4,%esp
f01050ce:	ff 75 e4             	pushl  -0x1c(%ebp)
f01050d1:	ff 75 e0             	pushl  -0x20(%ebp)
f01050d4:	ff 75 dc             	pushl  -0x24(%ebp)
f01050d7:	ff 75 d8             	pushl  -0x28(%ebp)
f01050da:	e8 d1 1b 00 00       	call   f0106cb0 <__umoddi3>
f01050df:	83 c4 14             	add    $0x14,%esp
f01050e2:	0f be 80 7a 87 10 f0 	movsbl -0xfef7886(%eax),%eax
f01050e9:	50                   	push   %eax
f01050ea:	ff d7                	call   *%edi
}
f01050ec:	83 c4 10             	add    $0x10,%esp
f01050ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01050f2:	5b                   	pop    %ebx
f01050f3:	5e                   	pop    %esi
f01050f4:	5f                   	pop    %edi
f01050f5:	5d                   	pop    %ebp
f01050f6:	c3                   	ret    

f01050f7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01050f7:	55                   	push   %ebp
f01050f8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01050fa:	83 fa 01             	cmp    $0x1,%edx
f01050fd:	7e 0e                	jle    f010510d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f01050ff:	8b 10                	mov    (%eax),%edx
f0105101:	8d 4a 08             	lea    0x8(%edx),%ecx
f0105104:	89 08                	mov    %ecx,(%eax)
f0105106:	8b 02                	mov    (%edx),%eax
f0105108:	8b 52 04             	mov    0x4(%edx),%edx
f010510b:	eb 22                	jmp    f010512f <getuint+0x38>
	else if (lflag)
f010510d:	85 d2                	test   %edx,%edx
f010510f:	74 10                	je     f0105121 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0105111:	8b 10                	mov    (%eax),%edx
f0105113:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105116:	89 08                	mov    %ecx,(%eax)
f0105118:	8b 02                	mov    (%edx),%eax
f010511a:	ba 00 00 00 00       	mov    $0x0,%edx
f010511f:	eb 0e                	jmp    f010512f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0105121:	8b 10                	mov    (%eax),%edx
f0105123:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105126:	89 08                	mov    %ecx,(%eax)
f0105128:	8b 02                	mov    (%edx),%eax
f010512a:	ba 00 00 00 00       	mov    $0x0,%edx
}
f010512f:	5d                   	pop    %ebp
f0105130:	c3                   	ret    

f0105131 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105131:	55                   	push   %ebp
f0105132:	89 e5                	mov    %esp,%ebp
f0105134:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105137:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f010513b:	8b 10                	mov    (%eax),%edx
f010513d:	3b 50 04             	cmp    0x4(%eax),%edx
f0105140:	73 0a                	jae    f010514c <sprintputch+0x1b>
		*b->buf++ = ch;
f0105142:	8d 4a 01             	lea    0x1(%edx),%ecx
f0105145:	89 08                	mov    %ecx,(%eax)
f0105147:	8b 45 08             	mov    0x8(%ebp),%eax
f010514a:	88 02                	mov    %al,(%edx)
}
f010514c:	5d                   	pop    %ebp
f010514d:	c3                   	ret    

f010514e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f010514e:	55                   	push   %ebp
f010514f:	89 e5                	mov    %esp,%ebp
f0105151:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0105154:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0105157:	50                   	push   %eax
f0105158:	ff 75 10             	pushl  0x10(%ebp)
f010515b:	ff 75 0c             	pushl  0xc(%ebp)
f010515e:	ff 75 08             	pushl  0x8(%ebp)
f0105161:	e8 05 00 00 00       	call   f010516b <vprintfmt>
	va_end(ap);
}
f0105166:	83 c4 10             	add    $0x10,%esp
f0105169:	c9                   	leave  
f010516a:	c3                   	ret    

f010516b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f010516b:	55                   	push   %ebp
f010516c:	89 e5                	mov    %esp,%ebp
f010516e:	57                   	push   %edi
f010516f:	56                   	push   %esi
f0105170:	53                   	push   %ebx
f0105171:	83 ec 2c             	sub    $0x2c,%esp
f0105174:	8b 75 08             	mov    0x8(%ebp),%esi
f0105177:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010517a:	8b 7d 10             	mov    0x10(%ebp),%edi
f010517d:	eb 12                	jmp    f0105191 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f010517f:	85 c0                	test   %eax,%eax
f0105181:	0f 84 89 03 00 00    	je     f0105510 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0105187:	83 ec 08             	sub    $0x8,%esp
f010518a:	53                   	push   %ebx
f010518b:	50                   	push   %eax
f010518c:	ff d6                	call   *%esi
f010518e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105191:	83 c7 01             	add    $0x1,%edi
f0105194:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105198:	83 f8 25             	cmp    $0x25,%eax
f010519b:	75 e2                	jne    f010517f <vprintfmt+0x14>
f010519d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f01051a1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f01051a8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f01051af:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f01051b6:	ba 00 00 00 00       	mov    $0x0,%edx
f01051bb:	eb 07                	jmp    f01051c4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01051bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f01051c0:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01051c4:	8d 47 01             	lea    0x1(%edi),%eax
f01051c7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01051ca:	0f b6 07             	movzbl (%edi),%eax
f01051cd:	0f b6 c8             	movzbl %al,%ecx
f01051d0:	83 e8 23             	sub    $0x23,%eax
f01051d3:	3c 55                	cmp    $0x55,%al
f01051d5:	0f 87 1a 03 00 00    	ja     f01054f5 <vprintfmt+0x38a>
f01051db:	0f b6 c0             	movzbl %al,%eax
f01051de:	ff 24 85 c0 88 10 f0 	jmp    *-0xfef7740(,%eax,4)
f01051e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01051e8:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f01051ec:	eb d6                	jmp    f01051c4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01051ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01051f1:	b8 00 00 00 00       	mov    $0x0,%eax
f01051f6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f01051f9:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01051fc:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0105200:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0105203:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0105206:	83 fa 09             	cmp    $0x9,%edx
f0105209:	77 39                	ja     f0105244 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f010520b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f010520e:	eb e9                	jmp    f01051f9 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0105210:	8b 45 14             	mov    0x14(%ebp),%eax
f0105213:	8d 48 04             	lea    0x4(%eax),%ecx
f0105216:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0105219:	8b 00                	mov    (%eax),%eax
f010521b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010521e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0105221:	eb 27                	jmp    f010524a <vprintfmt+0xdf>
f0105223:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105226:	85 c0                	test   %eax,%eax
f0105228:	b9 00 00 00 00       	mov    $0x0,%ecx
f010522d:	0f 49 c8             	cmovns %eax,%ecx
f0105230:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105233:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105236:	eb 8c                	jmp    f01051c4 <vprintfmt+0x59>
f0105238:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f010523b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0105242:	eb 80                	jmp    f01051c4 <vprintfmt+0x59>
f0105244:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105247:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f010524a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010524e:	0f 89 70 ff ff ff    	jns    f01051c4 <vprintfmt+0x59>
				width = precision, precision = -1;
f0105254:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105257:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010525a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0105261:	e9 5e ff ff ff       	jmp    f01051c4 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105266:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105269:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f010526c:	e9 53 ff ff ff       	jmp    f01051c4 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105271:	8b 45 14             	mov    0x14(%ebp),%eax
f0105274:	8d 50 04             	lea    0x4(%eax),%edx
f0105277:	89 55 14             	mov    %edx,0x14(%ebp)
f010527a:	83 ec 08             	sub    $0x8,%esp
f010527d:	53                   	push   %ebx
f010527e:	ff 30                	pushl  (%eax)
f0105280:	ff d6                	call   *%esi
			break;
f0105282:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105285:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0105288:	e9 04 ff ff ff       	jmp    f0105191 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f010528d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105290:	8d 50 04             	lea    0x4(%eax),%edx
f0105293:	89 55 14             	mov    %edx,0x14(%ebp)
f0105296:	8b 00                	mov    (%eax),%eax
f0105298:	99                   	cltd   
f0105299:	31 d0                	xor    %edx,%eax
f010529b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010529d:	83 f8 0f             	cmp    $0xf,%eax
f01052a0:	7f 0b                	jg     f01052ad <vprintfmt+0x142>
f01052a2:	8b 14 85 20 8a 10 f0 	mov    -0xfef75e0(,%eax,4),%edx
f01052a9:	85 d2                	test   %edx,%edx
f01052ab:	75 18                	jne    f01052c5 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f01052ad:	50                   	push   %eax
f01052ae:	68 92 87 10 f0       	push   $0xf0108792
f01052b3:	53                   	push   %ebx
f01052b4:	56                   	push   %esi
f01052b5:	e8 94 fe ff ff       	call   f010514e <printfmt>
f01052ba:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01052bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01052c0:	e9 cc fe ff ff       	jmp    f0105191 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f01052c5:	52                   	push   %edx
f01052c6:	68 37 74 10 f0       	push   $0xf0107437
f01052cb:	53                   	push   %ebx
f01052cc:	56                   	push   %esi
f01052cd:	e8 7c fe ff ff       	call   f010514e <printfmt>
f01052d2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01052d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01052d8:	e9 b4 fe ff ff       	jmp    f0105191 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01052dd:	8b 45 14             	mov    0x14(%ebp),%eax
f01052e0:	8d 50 04             	lea    0x4(%eax),%edx
f01052e3:	89 55 14             	mov    %edx,0x14(%ebp)
f01052e6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f01052e8:	85 ff                	test   %edi,%edi
f01052ea:	b8 8b 87 10 f0       	mov    $0xf010878b,%eax
f01052ef:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f01052f2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01052f6:	0f 8e 94 00 00 00    	jle    f0105390 <vprintfmt+0x225>
f01052fc:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0105300:	0f 84 98 00 00 00    	je     f010539e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105306:	83 ec 08             	sub    $0x8,%esp
f0105309:	ff 75 d0             	pushl  -0x30(%ebp)
f010530c:	57                   	push   %edi
f010530d:	e8 77 03 00 00       	call   f0105689 <strnlen>
f0105312:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105315:	29 c1                	sub    %eax,%ecx
f0105317:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f010531a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f010531d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0105321:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105324:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0105327:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105329:	eb 0f                	jmp    f010533a <vprintfmt+0x1cf>
					putch(padc, putdat);
f010532b:	83 ec 08             	sub    $0x8,%esp
f010532e:	53                   	push   %ebx
f010532f:	ff 75 e0             	pushl  -0x20(%ebp)
f0105332:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105334:	83 ef 01             	sub    $0x1,%edi
f0105337:	83 c4 10             	add    $0x10,%esp
f010533a:	85 ff                	test   %edi,%edi
f010533c:	7f ed                	jg     f010532b <vprintfmt+0x1c0>
f010533e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0105341:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0105344:	85 c9                	test   %ecx,%ecx
f0105346:	b8 00 00 00 00       	mov    $0x0,%eax
f010534b:	0f 49 c1             	cmovns %ecx,%eax
f010534e:	29 c1                	sub    %eax,%ecx
f0105350:	89 75 08             	mov    %esi,0x8(%ebp)
f0105353:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105356:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105359:	89 cb                	mov    %ecx,%ebx
f010535b:	eb 4d                	jmp    f01053aa <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f010535d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105361:	74 1b                	je     f010537e <vprintfmt+0x213>
f0105363:	0f be c0             	movsbl %al,%eax
f0105366:	83 e8 20             	sub    $0x20,%eax
f0105369:	83 f8 5e             	cmp    $0x5e,%eax
f010536c:	76 10                	jbe    f010537e <vprintfmt+0x213>
					putch('?', putdat);
f010536e:	83 ec 08             	sub    $0x8,%esp
f0105371:	ff 75 0c             	pushl  0xc(%ebp)
f0105374:	6a 3f                	push   $0x3f
f0105376:	ff 55 08             	call   *0x8(%ebp)
f0105379:	83 c4 10             	add    $0x10,%esp
f010537c:	eb 0d                	jmp    f010538b <vprintfmt+0x220>
				else
					putch(ch, putdat);
f010537e:	83 ec 08             	sub    $0x8,%esp
f0105381:	ff 75 0c             	pushl  0xc(%ebp)
f0105384:	52                   	push   %edx
f0105385:	ff 55 08             	call   *0x8(%ebp)
f0105388:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010538b:	83 eb 01             	sub    $0x1,%ebx
f010538e:	eb 1a                	jmp    f01053aa <vprintfmt+0x23f>
f0105390:	89 75 08             	mov    %esi,0x8(%ebp)
f0105393:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105396:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105399:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010539c:	eb 0c                	jmp    f01053aa <vprintfmt+0x23f>
f010539e:	89 75 08             	mov    %esi,0x8(%ebp)
f01053a1:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01053a4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01053a7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01053aa:	83 c7 01             	add    $0x1,%edi
f01053ad:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01053b1:	0f be d0             	movsbl %al,%edx
f01053b4:	85 d2                	test   %edx,%edx
f01053b6:	74 23                	je     f01053db <vprintfmt+0x270>
f01053b8:	85 f6                	test   %esi,%esi
f01053ba:	78 a1                	js     f010535d <vprintfmt+0x1f2>
f01053bc:	83 ee 01             	sub    $0x1,%esi
f01053bf:	79 9c                	jns    f010535d <vprintfmt+0x1f2>
f01053c1:	89 df                	mov    %ebx,%edi
f01053c3:	8b 75 08             	mov    0x8(%ebp),%esi
f01053c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01053c9:	eb 18                	jmp    f01053e3 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01053cb:	83 ec 08             	sub    $0x8,%esp
f01053ce:	53                   	push   %ebx
f01053cf:	6a 20                	push   $0x20
f01053d1:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01053d3:	83 ef 01             	sub    $0x1,%edi
f01053d6:	83 c4 10             	add    $0x10,%esp
f01053d9:	eb 08                	jmp    f01053e3 <vprintfmt+0x278>
f01053db:	89 df                	mov    %ebx,%edi
f01053dd:	8b 75 08             	mov    0x8(%ebp),%esi
f01053e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01053e3:	85 ff                	test   %edi,%edi
f01053e5:	7f e4                	jg     f01053cb <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01053e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01053ea:	e9 a2 fd ff ff       	jmp    f0105191 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01053ef:	83 fa 01             	cmp    $0x1,%edx
f01053f2:	7e 16                	jle    f010540a <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f01053f4:	8b 45 14             	mov    0x14(%ebp),%eax
f01053f7:	8d 50 08             	lea    0x8(%eax),%edx
f01053fa:	89 55 14             	mov    %edx,0x14(%ebp)
f01053fd:	8b 50 04             	mov    0x4(%eax),%edx
f0105400:	8b 00                	mov    (%eax),%eax
f0105402:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105405:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105408:	eb 32                	jmp    f010543c <vprintfmt+0x2d1>
	else if (lflag)
f010540a:	85 d2                	test   %edx,%edx
f010540c:	74 18                	je     f0105426 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f010540e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105411:	8d 50 04             	lea    0x4(%eax),%edx
f0105414:	89 55 14             	mov    %edx,0x14(%ebp)
f0105417:	8b 00                	mov    (%eax),%eax
f0105419:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010541c:	89 c1                	mov    %eax,%ecx
f010541e:	c1 f9 1f             	sar    $0x1f,%ecx
f0105421:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105424:	eb 16                	jmp    f010543c <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0105426:	8b 45 14             	mov    0x14(%ebp),%eax
f0105429:	8d 50 04             	lea    0x4(%eax),%edx
f010542c:	89 55 14             	mov    %edx,0x14(%ebp)
f010542f:	8b 00                	mov    (%eax),%eax
f0105431:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105434:	89 c1                	mov    %eax,%ecx
f0105436:	c1 f9 1f             	sar    $0x1f,%ecx
f0105439:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f010543c:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010543f:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0105442:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0105447:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010544b:	79 74                	jns    f01054c1 <vprintfmt+0x356>
				putch('-', putdat);
f010544d:	83 ec 08             	sub    $0x8,%esp
f0105450:	53                   	push   %ebx
f0105451:	6a 2d                	push   $0x2d
f0105453:	ff d6                	call   *%esi
				num = -(long long) num;
f0105455:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105458:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010545b:	f7 d8                	neg    %eax
f010545d:	83 d2 00             	adc    $0x0,%edx
f0105460:	f7 da                	neg    %edx
f0105462:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0105465:	b9 0a 00 00 00       	mov    $0xa,%ecx
f010546a:	eb 55                	jmp    f01054c1 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f010546c:	8d 45 14             	lea    0x14(%ebp),%eax
f010546f:	e8 83 fc ff ff       	call   f01050f7 <getuint>
			base = 10;
f0105474:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0105479:	eb 46                	jmp    f01054c1 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
f010547b:	8d 45 14             	lea    0x14(%ebp),%eax
f010547e:	e8 74 fc ff ff       	call   f01050f7 <getuint>
			base = 8;
f0105483:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0105488:	eb 37                	jmp    f01054c1 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
f010548a:	83 ec 08             	sub    $0x8,%esp
f010548d:	53                   	push   %ebx
f010548e:	6a 30                	push   $0x30
f0105490:	ff d6                	call   *%esi
			putch('x', putdat);
f0105492:	83 c4 08             	add    $0x8,%esp
f0105495:	53                   	push   %ebx
f0105496:	6a 78                	push   $0x78
f0105498:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f010549a:	8b 45 14             	mov    0x14(%ebp),%eax
f010549d:	8d 50 04             	lea    0x4(%eax),%edx
f01054a0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01054a3:	8b 00                	mov    (%eax),%eax
f01054a5:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f01054aa:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01054ad:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f01054b2:	eb 0d                	jmp    f01054c1 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01054b4:	8d 45 14             	lea    0x14(%ebp),%eax
f01054b7:	e8 3b fc ff ff       	call   f01050f7 <getuint>
			base = 16;
f01054bc:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f01054c1:	83 ec 0c             	sub    $0xc,%esp
f01054c4:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f01054c8:	57                   	push   %edi
f01054c9:	ff 75 e0             	pushl  -0x20(%ebp)
f01054cc:	51                   	push   %ecx
f01054cd:	52                   	push   %edx
f01054ce:	50                   	push   %eax
f01054cf:	89 da                	mov    %ebx,%edx
f01054d1:	89 f0                	mov    %esi,%eax
f01054d3:	e8 70 fb ff ff       	call   f0105048 <printnum>
			break;
f01054d8:	83 c4 20             	add    $0x20,%esp
f01054db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01054de:	e9 ae fc ff ff       	jmp    f0105191 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01054e3:	83 ec 08             	sub    $0x8,%esp
f01054e6:	53                   	push   %ebx
f01054e7:	51                   	push   %ecx
f01054e8:	ff d6                	call   *%esi
			break;
f01054ea:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01054ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01054f0:	e9 9c fc ff ff       	jmp    f0105191 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01054f5:	83 ec 08             	sub    $0x8,%esp
f01054f8:	53                   	push   %ebx
f01054f9:	6a 25                	push   $0x25
f01054fb:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01054fd:	83 c4 10             	add    $0x10,%esp
f0105500:	eb 03                	jmp    f0105505 <vprintfmt+0x39a>
f0105502:	83 ef 01             	sub    $0x1,%edi
f0105505:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0105509:	75 f7                	jne    f0105502 <vprintfmt+0x397>
f010550b:	e9 81 fc ff ff       	jmp    f0105191 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0105510:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105513:	5b                   	pop    %ebx
f0105514:	5e                   	pop    %esi
f0105515:	5f                   	pop    %edi
f0105516:	5d                   	pop    %ebp
f0105517:	c3                   	ret    

f0105518 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105518:	55                   	push   %ebp
f0105519:	89 e5                	mov    %esp,%ebp
f010551b:	83 ec 18             	sub    $0x18,%esp
f010551e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105521:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105524:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105527:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010552b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010552e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105535:	85 c0                	test   %eax,%eax
f0105537:	74 26                	je     f010555f <vsnprintf+0x47>
f0105539:	85 d2                	test   %edx,%edx
f010553b:	7e 22                	jle    f010555f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010553d:	ff 75 14             	pushl  0x14(%ebp)
f0105540:	ff 75 10             	pushl  0x10(%ebp)
f0105543:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105546:	50                   	push   %eax
f0105547:	68 31 51 10 f0       	push   $0xf0105131
f010554c:	e8 1a fc ff ff       	call   f010516b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105551:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105554:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105557:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010555a:	83 c4 10             	add    $0x10,%esp
f010555d:	eb 05                	jmp    f0105564 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f010555f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0105564:	c9                   	leave  
f0105565:	c3                   	ret    

f0105566 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105566:	55                   	push   %ebp
f0105567:	89 e5                	mov    %esp,%ebp
f0105569:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010556c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010556f:	50                   	push   %eax
f0105570:	ff 75 10             	pushl  0x10(%ebp)
f0105573:	ff 75 0c             	pushl  0xc(%ebp)
f0105576:	ff 75 08             	pushl  0x8(%ebp)
f0105579:	e8 9a ff ff ff       	call   f0105518 <vsnprintf>
	va_end(ap);

	return rc;
}
f010557e:	c9                   	leave  
f010557f:	c3                   	ret    

f0105580 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105580:	55                   	push   %ebp
f0105581:	89 e5                	mov    %esp,%ebp
f0105583:	57                   	push   %edi
f0105584:	56                   	push   %esi
f0105585:	53                   	push   %ebx
f0105586:	83 ec 0c             	sub    $0xc,%esp
f0105589:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f010558c:	85 c0                	test   %eax,%eax
f010558e:	74 11                	je     f01055a1 <readline+0x21>
		cprintf("%s", prompt);
f0105590:	83 ec 08             	sub    $0x8,%esp
f0105593:	50                   	push   %eax
f0105594:	68 37 74 10 f0       	push   $0xf0107437
f0105599:	e8 f3 e3 ff ff       	call   f0103991 <cprintf>
f010559e:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f01055a1:	83 ec 0c             	sub    $0xc,%esp
f01055a4:	6a 00                	push   $0x0
f01055a6:	e8 11 b2 ff ff       	call   f01007bc <iscons>
f01055ab:	89 c7                	mov    %eax,%edi
f01055ad:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
f01055b0:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01055b5:	e8 f1 b1 ff ff       	call   f01007ab <getchar>
f01055ba:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01055bc:	85 c0                	test   %eax,%eax
f01055be:	79 29                	jns    f01055e9 <readline+0x69>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f01055c0:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
f01055c5:	83 fb f8             	cmp    $0xfffffff8,%ebx
f01055c8:	0f 84 9b 00 00 00    	je     f0105669 <readline+0xe9>
				cprintf("read error: %e\n", c);
f01055ce:	83 ec 08             	sub    $0x8,%esp
f01055d1:	53                   	push   %ebx
f01055d2:	68 7f 8a 10 f0       	push   $0xf0108a7f
f01055d7:	e8 b5 e3 ff ff       	call   f0103991 <cprintf>
f01055dc:	83 c4 10             	add    $0x10,%esp
			return NULL;
f01055df:	b8 00 00 00 00       	mov    $0x0,%eax
f01055e4:	e9 80 00 00 00       	jmp    f0105669 <readline+0xe9>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01055e9:	83 f8 08             	cmp    $0x8,%eax
f01055ec:	0f 94 c2             	sete   %dl
f01055ef:	83 f8 7f             	cmp    $0x7f,%eax
f01055f2:	0f 94 c0             	sete   %al
f01055f5:	08 c2                	or     %al,%dl
f01055f7:	74 1a                	je     f0105613 <readline+0x93>
f01055f9:	85 f6                	test   %esi,%esi
f01055fb:	7e 16                	jle    f0105613 <readline+0x93>
			if (echoing)
f01055fd:	85 ff                	test   %edi,%edi
f01055ff:	74 0d                	je     f010560e <readline+0x8e>
				cputchar('\b');
f0105601:	83 ec 0c             	sub    $0xc,%esp
f0105604:	6a 08                	push   $0x8
f0105606:	e8 90 b1 ff ff       	call   f010079b <cputchar>
f010560b:	83 c4 10             	add    $0x10,%esp
			i--;
f010560e:	83 ee 01             	sub    $0x1,%esi
f0105611:	eb a2                	jmp    f01055b5 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105613:	83 fb 1f             	cmp    $0x1f,%ebx
f0105616:	7e 26                	jle    f010563e <readline+0xbe>
f0105618:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010561e:	7f 1e                	jg     f010563e <readline+0xbe>
			if (echoing)
f0105620:	85 ff                	test   %edi,%edi
f0105622:	74 0c                	je     f0105630 <readline+0xb0>
				cputchar(c);
f0105624:	83 ec 0c             	sub    $0xc,%esp
f0105627:	53                   	push   %ebx
f0105628:	e8 6e b1 ff ff       	call   f010079b <cputchar>
f010562d:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0105630:	88 9e 80 ca 2a f0    	mov    %bl,-0xfd53580(%esi)
f0105636:	8d 76 01             	lea    0x1(%esi),%esi
f0105639:	e9 77 ff ff ff       	jmp    f01055b5 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f010563e:	83 fb 0a             	cmp    $0xa,%ebx
f0105641:	74 09                	je     f010564c <readline+0xcc>
f0105643:	83 fb 0d             	cmp    $0xd,%ebx
f0105646:	0f 85 69 ff ff ff    	jne    f01055b5 <readline+0x35>
			if (echoing)
f010564c:	85 ff                	test   %edi,%edi
f010564e:	74 0d                	je     f010565d <readline+0xdd>
				cputchar('\n');
f0105650:	83 ec 0c             	sub    $0xc,%esp
f0105653:	6a 0a                	push   $0xa
f0105655:	e8 41 b1 ff ff       	call   f010079b <cputchar>
f010565a:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f010565d:	c6 86 80 ca 2a f0 00 	movb   $0x0,-0xfd53580(%esi)
			return buf;
f0105664:	b8 80 ca 2a f0       	mov    $0xf02aca80,%eax
		}
	}
}
f0105669:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010566c:	5b                   	pop    %ebx
f010566d:	5e                   	pop    %esi
f010566e:	5f                   	pop    %edi
f010566f:	5d                   	pop    %ebp
f0105670:	c3                   	ret    

f0105671 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105671:	55                   	push   %ebp
f0105672:	89 e5                	mov    %esp,%ebp
f0105674:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105677:	b8 00 00 00 00       	mov    $0x0,%eax
f010567c:	eb 03                	jmp    f0105681 <strlen+0x10>
		n++;
f010567e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105681:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105685:	75 f7                	jne    f010567e <strlen+0xd>
		n++;
	return n;
}
f0105687:	5d                   	pop    %ebp
f0105688:	c3                   	ret    

f0105689 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105689:	55                   	push   %ebp
f010568a:	89 e5                	mov    %esp,%ebp
f010568c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010568f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105692:	ba 00 00 00 00       	mov    $0x0,%edx
f0105697:	eb 03                	jmp    f010569c <strnlen+0x13>
		n++;
f0105699:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010569c:	39 c2                	cmp    %eax,%edx
f010569e:	74 08                	je     f01056a8 <strnlen+0x1f>
f01056a0:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f01056a4:	75 f3                	jne    f0105699 <strnlen+0x10>
f01056a6:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f01056a8:	5d                   	pop    %ebp
f01056a9:	c3                   	ret    

f01056aa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01056aa:	55                   	push   %ebp
f01056ab:	89 e5                	mov    %esp,%ebp
f01056ad:	53                   	push   %ebx
f01056ae:	8b 45 08             	mov    0x8(%ebp),%eax
f01056b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01056b4:	89 c2                	mov    %eax,%edx
f01056b6:	83 c2 01             	add    $0x1,%edx
f01056b9:	83 c1 01             	add    $0x1,%ecx
f01056bc:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01056c0:	88 5a ff             	mov    %bl,-0x1(%edx)
f01056c3:	84 db                	test   %bl,%bl
f01056c5:	75 ef                	jne    f01056b6 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01056c7:	5b                   	pop    %ebx
f01056c8:	5d                   	pop    %ebp
f01056c9:	c3                   	ret    

f01056ca <strcat>:

char *
strcat(char *dst, const char *src)
{
f01056ca:	55                   	push   %ebp
f01056cb:	89 e5                	mov    %esp,%ebp
f01056cd:	53                   	push   %ebx
f01056ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01056d1:	53                   	push   %ebx
f01056d2:	e8 9a ff ff ff       	call   f0105671 <strlen>
f01056d7:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01056da:	ff 75 0c             	pushl  0xc(%ebp)
f01056dd:	01 d8                	add    %ebx,%eax
f01056df:	50                   	push   %eax
f01056e0:	e8 c5 ff ff ff       	call   f01056aa <strcpy>
	return dst;
}
f01056e5:	89 d8                	mov    %ebx,%eax
f01056e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01056ea:	c9                   	leave  
f01056eb:	c3                   	ret    

f01056ec <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01056ec:	55                   	push   %ebp
f01056ed:	89 e5                	mov    %esp,%ebp
f01056ef:	56                   	push   %esi
f01056f0:	53                   	push   %ebx
f01056f1:	8b 75 08             	mov    0x8(%ebp),%esi
f01056f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01056f7:	89 f3                	mov    %esi,%ebx
f01056f9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01056fc:	89 f2                	mov    %esi,%edx
f01056fe:	eb 0f                	jmp    f010570f <strncpy+0x23>
		*dst++ = *src;
f0105700:	83 c2 01             	add    $0x1,%edx
f0105703:	0f b6 01             	movzbl (%ecx),%eax
f0105706:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105709:	80 39 01             	cmpb   $0x1,(%ecx)
f010570c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010570f:	39 da                	cmp    %ebx,%edx
f0105711:	75 ed                	jne    f0105700 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105713:	89 f0                	mov    %esi,%eax
f0105715:	5b                   	pop    %ebx
f0105716:	5e                   	pop    %esi
f0105717:	5d                   	pop    %ebp
f0105718:	c3                   	ret    

f0105719 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105719:	55                   	push   %ebp
f010571a:	89 e5                	mov    %esp,%ebp
f010571c:	56                   	push   %esi
f010571d:	53                   	push   %ebx
f010571e:	8b 75 08             	mov    0x8(%ebp),%esi
f0105721:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105724:	8b 55 10             	mov    0x10(%ebp),%edx
f0105727:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105729:	85 d2                	test   %edx,%edx
f010572b:	74 21                	je     f010574e <strlcpy+0x35>
f010572d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0105731:	89 f2                	mov    %esi,%edx
f0105733:	eb 09                	jmp    f010573e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105735:	83 c2 01             	add    $0x1,%edx
f0105738:	83 c1 01             	add    $0x1,%ecx
f010573b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010573e:	39 c2                	cmp    %eax,%edx
f0105740:	74 09                	je     f010574b <strlcpy+0x32>
f0105742:	0f b6 19             	movzbl (%ecx),%ebx
f0105745:	84 db                	test   %bl,%bl
f0105747:	75 ec                	jne    f0105735 <strlcpy+0x1c>
f0105749:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f010574b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010574e:	29 f0                	sub    %esi,%eax
}
f0105750:	5b                   	pop    %ebx
f0105751:	5e                   	pop    %esi
f0105752:	5d                   	pop    %ebp
f0105753:	c3                   	ret    

f0105754 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105754:	55                   	push   %ebp
f0105755:	89 e5                	mov    %esp,%ebp
f0105757:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010575a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010575d:	eb 06                	jmp    f0105765 <strcmp+0x11>
		p++, q++;
f010575f:	83 c1 01             	add    $0x1,%ecx
f0105762:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0105765:	0f b6 01             	movzbl (%ecx),%eax
f0105768:	84 c0                	test   %al,%al
f010576a:	74 04                	je     f0105770 <strcmp+0x1c>
f010576c:	3a 02                	cmp    (%edx),%al
f010576e:	74 ef                	je     f010575f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105770:	0f b6 c0             	movzbl %al,%eax
f0105773:	0f b6 12             	movzbl (%edx),%edx
f0105776:	29 d0                	sub    %edx,%eax
}
f0105778:	5d                   	pop    %ebp
f0105779:	c3                   	ret    

f010577a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010577a:	55                   	push   %ebp
f010577b:	89 e5                	mov    %esp,%ebp
f010577d:	53                   	push   %ebx
f010577e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105781:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105784:	89 c3                	mov    %eax,%ebx
f0105786:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105789:	eb 06                	jmp    f0105791 <strncmp+0x17>
		n--, p++, q++;
f010578b:	83 c0 01             	add    $0x1,%eax
f010578e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105791:	39 d8                	cmp    %ebx,%eax
f0105793:	74 15                	je     f01057aa <strncmp+0x30>
f0105795:	0f b6 08             	movzbl (%eax),%ecx
f0105798:	84 c9                	test   %cl,%cl
f010579a:	74 04                	je     f01057a0 <strncmp+0x26>
f010579c:	3a 0a                	cmp    (%edx),%cl
f010579e:	74 eb                	je     f010578b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01057a0:	0f b6 00             	movzbl (%eax),%eax
f01057a3:	0f b6 12             	movzbl (%edx),%edx
f01057a6:	29 d0                	sub    %edx,%eax
f01057a8:	eb 05                	jmp    f01057af <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01057aa:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01057af:	5b                   	pop    %ebx
f01057b0:	5d                   	pop    %ebp
f01057b1:	c3                   	ret    

f01057b2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01057b2:	55                   	push   %ebp
f01057b3:	89 e5                	mov    %esp,%ebp
f01057b5:	8b 45 08             	mov    0x8(%ebp),%eax
f01057b8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01057bc:	eb 07                	jmp    f01057c5 <strchr+0x13>
		if (*s == c)
f01057be:	38 ca                	cmp    %cl,%dl
f01057c0:	74 0f                	je     f01057d1 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01057c2:	83 c0 01             	add    $0x1,%eax
f01057c5:	0f b6 10             	movzbl (%eax),%edx
f01057c8:	84 d2                	test   %dl,%dl
f01057ca:	75 f2                	jne    f01057be <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f01057cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01057d1:	5d                   	pop    %ebp
f01057d2:	c3                   	ret    

f01057d3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01057d3:	55                   	push   %ebp
f01057d4:	89 e5                	mov    %esp,%ebp
f01057d6:	8b 45 08             	mov    0x8(%ebp),%eax
f01057d9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01057dd:	eb 03                	jmp    f01057e2 <strfind+0xf>
f01057df:	83 c0 01             	add    $0x1,%eax
f01057e2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01057e5:	38 ca                	cmp    %cl,%dl
f01057e7:	74 04                	je     f01057ed <strfind+0x1a>
f01057e9:	84 d2                	test   %dl,%dl
f01057eb:	75 f2                	jne    f01057df <strfind+0xc>
			break;
	return (char *) s;
}
f01057ed:	5d                   	pop    %ebp
f01057ee:	c3                   	ret    

f01057ef <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01057ef:	55                   	push   %ebp
f01057f0:	89 e5                	mov    %esp,%ebp
f01057f2:	57                   	push   %edi
f01057f3:	56                   	push   %esi
f01057f4:	53                   	push   %ebx
f01057f5:	8b 7d 08             	mov    0x8(%ebp),%edi
f01057f8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01057fb:	85 c9                	test   %ecx,%ecx
f01057fd:	74 36                	je     f0105835 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01057ff:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105805:	75 28                	jne    f010582f <memset+0x40>
f0105807:	f6 c1 03             	test   $0x3,%cl
f010580a:	75 23                	jne    f010582f <memset+0x40>
		c &= 0xFF;
f010580c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105810:	89 d3                	mov    %edx,%ebx
f0105812:	c1 e3 08             	shl    $0x8,%ebx
f0105815:	89 d6                	mov    %edx,%esi
f0105817:	c1 e6 18             	shl    $0x18,%esi
f010581a:	89 d0                	mov    %edx,%eax
f010581c:	c1 e0 10             	shl    $0x10,%eax
f010581f:	09 f0                	or     %esi,%eax
f0105821:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0105823:	89 d8                	mov    %ebx,%eax
f0105825:	09 d0                	or     %edx,%eax
f0105827:	c1 e9 02             	shr    $0x2,%ecx
f010582a:	fc                   	cld    
f010582b:	f3 ab                	rep stos %eax,%es:(%edi)
f010582d:	eb 06                	jmp    f0105835 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010582f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105832:	fc                   	cld    
f0105833:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105835:	89 f8                	mov    %edi,%eax
f0105837:	5b                   	pop    %ebx
f0105838:	5e                   	pop    %esi
f0105839:	5f                   	pop    %edi
f010583a:	5d                   	pop    %ebp
f010583b:	c3                   	ret    

f010583c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010583c:	55                   	push   %ebp
f010583d:	89 e5                	mov    %esp,%ebp
f010583f:	57                   	push   %edi
f0105840:	56                   	push   %esi
f0105841:	8b 45 08             	mov    0x8(%ebp),%eax
f0105844:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105847:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010584a:	39 c6                	cmp    %eax,%esi
f010584c:	73 35                	jae    f0105883 <memmove+0x47>
f010584e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105851:	39 d0                	cmp    %edx,%eax
f0105853:	73 2e                	jae    f0105883 <memmove+0x47>
		s += n;
		d += n;
f0105855:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105858:	89 d6                	mov    %edx,%esi
f010585a:	09 fe                	or     %edi,%esi
f010585c:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105862:	75 13                	jne    f0105877 <memmove+0x3b>
f0105864:	f6 c1 03             	test   $0x3,%cl
f0105867:	75 0e                	jne    f0105877 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0105869:	83 ef 04             	sub    $0x4,%edi
f010586c:	8d 72 fc             	lea    -0x4(%edx),%esi
f010586f:	c1 e9 02             	shr    $0x2,%ecx
f0105872:	fd                   	std    
f0105873:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105875:	eb 09                	jmp    f0105880 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105877:	83 ef 01             	sub    $0x1,%edi
f010587a:	8d 72 ff             	lea    -0x1(%edx),%esi
f010587d:	fd                   	std    
f010587e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105880:	fc                   	cld    
f0105881:	eb 1d                	jmp    f01058a0 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105883:	89 f2                	mov    %esi,%edx
f0105885:	09 c2                	or     %eax,%edx
f0105887:	f6 c2 03             	test   $0x3,%dl
f010588a:	75 0f                	jne    f010589b <memmove+0x5f>
f010588c:	f6 c1 03             	test   $0x3,%cl
f010588f:	75 0a                	jne    f010589b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0105891:	c1 e9 02             	shr    $0x2,%ecx
f0105894:	89 c7                	mov    %eax,%edi
f0105896:	fc                   	cld    
f0105897:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105899:	eb 05                	jmp    f01058a0 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f010589b:	89 c7                	mov    %eax,%edi
f010589d:	fc                   	cld    
f010589e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01058a0:	5e                   	pop    %esi
f01058a1:	5f                   	pop    %edi
f01058a2:	5d                   	pop    %ebp
f01058a3:	c3                   	ret    

f01058a4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01058a4:	55                   	push   %ebp
f01058a5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01058a7:	ff 75 10             	pushl  0x10(%ebp)
f01058aa:	ff 75 0c             	pushl  0xc(%ebp)
f01058ad:	ff 75 08             	pushl  0x8(%ebp)
f01058b0:	e8 87 ff ff ff       	call   f010583c <memmove>
}
f01058b5:	c9                   	leave  
f01058b6:	c3                   	ret    

f01058b7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01058b7:	55                   	push   %ebp
f01058b8:	89 e5                	mov    %esp,%ebp
f01058ba:	56                   	push   %esi
f01058bb:	53                   	push   %ebx
f01058bc:	8b 45 08             	mov    0x8(%ebp),%eax
f01058bf:	8b 55 0c             	mov    0xc(%ebp),%edx
f01058c2:	89 c6                	mov    %eax,%esi
f01058c4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01058c7:	eb 1a                	jmp    f01058e3 <memcmp+0x2c>
		if (*s1 != *s2)
f01058c9:	0f b6 08             	movzbl (%eax),%ecx
f01058cc:	0f b6 1a             	movzbl (%edx),%ebx
f01058cf:	38 d9                	cmp    %bl,%cl
f01058d1:	74 0a                	je     f01058dd <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01058d3:	0f b6 c1             	movzbl %cl,%eax
f01058d6:	0f b6 db             	movzbl %bl,%ebx
f01058d9:	29 d8                	sub    %ebx,%eax
f01058db:	eb 0f                	jmp    f01058ec <memcmp+0x35>
		s1++, s2++;
f01058dd:	83 c0 01             	add    $0x1,%eax
f01058e0:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01058e3:	39 f0                	cmp    %esi,%eax
f01058e5:	75 e2                	jne    f01058c9 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01058e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01058ec:	5b                   	pop    %ebx
f01058ed:	5e                   	pop    %esi
f01058ee:	5d                   	pop    %ebp
f01058ef:	c3                   	ret    

f01058f0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01058f0:	55                   	push   %ebp
f01058f1:	89 e5                	mov    %esp,%ebp
f01058f3:	53                   	push   %ebx
f01058f4:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01058f7:	89 c1                	mov    %eax,%ecx
f01058f9:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f01058fc:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105900:	eb 0a                	jmp    f010590c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105902:	0f b6 10             	movzbl (%eax),%edx
f0105905:	39 da                	cmp    %ebx,%edx
f0105907:	74 07                	je     f0105910 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105909:	83 c0 01             	add    $0x1,%eax
f010590c:	39 c8                	cmp    %ecx,%eax
f010590e:	72 f2                	jb     f0105902 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0105910:	5b                   	pop    %ebx
f0105911:	5d                   	pop    %ebp
f0105912:	c3                   	ret    

f0105913 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105913:	55                   	push   %ebp
f0105914:	89 e5                	mov    %esp,%ebp
f0105916:	57                   	push   %edi
f0105917:	56                   	push   %esi
f0105918:	53                   	push   %ebx
f0105919:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010591c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010591f:	eb 03                	jmp    f0105924 <strtol+0x11>
		s++;
f0105921:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105924:	0f b6 01             	movzbl (%ecx),%eax
f0105927:	3c 20                	cmp    $0x20,%al
f0105929:	74 f6                	je     f0105921 <strtol+0xe>
f010592b:	3c 09                	cmp    $0x9,%al
f010592d:	74 f2                	je     f0105921 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f010592f:	3c 2b                	cmp    $0x2b,%al
f0105931:	75 0a                	jne    f010593d <strtol+0x2a>
		s++;
f0105933:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105936:	bf 00 00 00 00       	mov    $0x0,%edi
f010593b:	eb 11                	jmp    f010594e <strtol+0x3b>
f010593d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0105942:	3c 2d                	cmp    $0x2d,%al
f0105944:	75 08                	jne    f010594e <strtol+0x3b>
		s++, neg = 1;
f0105946:	83 c1 01             	add    $0x1,%ecx
f0105949:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010594e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105954:	75 15                	jne    f010596b <strtol+0x58>
f0105956:	80 39 30             	cmpb   $0x30,(%ecx)
f0105959:	75 10                	jne    f010596b <strtol+0x58>
f010595b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f010595f:	75 7c                	jne    f01059dd <strtol+0xca>
		s += 2, base = 16;
f0105961:	83 c1 02             	add    $0x2,%ecx
f0105964:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105969:	eb 16                	jmp    f0105981 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f010596b:	85 db                	test   %ebx,%ebx
f010596d:	75 12                	jne    f0105981 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010596f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105974:	80 39 30             	cmpb   $0x30,(%ecx)
f0105977:	75 08                	jne    f0105981 <strtol+0x6e>
		s++, base = 8;
f0105979:	83 c1 01             	add    $0x1,%ecx
f010597c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0105981:	b8 00 00 00 00       	mov    $0x0,%eax
f0105986:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105989:	0f b6 11             	movzbl (%ecx),%edx
f010598c:	8d 72 d0             	lea    -0x30(%edx),%esi
f010598f:	89 f3                	mov    %esi,%ebx
f0105991:	80 fb 09             	cmp    $0x9,%bl
f0105994:	77 08                	ja     f010599e <strtol+0x8b>
			dig = *s - '0';
f0105996:	0f be d2             	movsbl %dl,%edx
f0105999:	83 ea 30             	sub    $0x30,%edx
f010599c:	eb 22                	jmp    f01059c0 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f010599e:	8d 72 9f             	lea    -0x61(%edx),%esi
f01059a1:	89 f3                	mov    %esi,%ebx
f01059a3:	80 fb 19             	cmp    $0x19,%bl
f01059a6:	77 08                	ja     f01059b0 <strtol+0x9d>
			dig = *s - 'a' + 10;
f01059a8:	0f be d2             	movsbl %dl,%edx
f01059ab:	83 ea 57             	sub    $0x57,%edx
f01059ae:	eb 10                	jmp    f01059c0 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f01059b0:	8d 72 bf             	lea    -0x41(%edx),%esi
f01059b3:	89 f3                	mov    %esi,%ebx
f01059b5:	80 fb 19             	cmp    $0x19,%bl
f01059b8:	77 16                	ja     f01059d0 <strtol+0xbd>
			dig = *s - 'A' + 10;
f01059ba:	0f be d2             	movsbl %dl,%edx
f01059bd:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f01059c0:	3b 55 10             	cmp    0x10(%ebp),%edx
f01059c3:	7d 0b                	jge    f01059d0 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f01059c5:	83 c1 01             	add    $0x1,%ecx
f01059c8:	0f af 45 10          	imul   0x10(%ebp),%eax
f01059cc:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f01059ce:	eb b9                	jmp    f0105989 <strtol+0x76>

	if (endptr)
f01059d0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01059d4:	74 0d                	je     f01059e3 <strtol+0xd0>
		*endptr = (char *) s;
f01059d6:	8b 75 0c             	mov    0xc(%ebp),%esi
f01059d9:	89 0e                	mov    %ecx,(%esi)
f01059db:	eb 06                	jmp    f01059e3 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01059dd:	85 db                	test   %ebx,%ebx
f01059df:	74 98                	je     f0105979 <strtol+0x66>
f01059e1:	eb 9e                	jmp    f0105981 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f01059e3:	89 c2                	mov    %eax,%edx
f01059e5:	f7 da                	neg    %edx
f01059e7:	85 ff                	test   %edi,%edi
f01059e9:	0f 45 c2             	cmovne %edx,%eax
}
f01059ec:	5b                   	pop    %ebx
f01059ed:	5e                   	pop    %esi
f01059ee:	5f                   	pop    %edi
f01059ef:	5d                   	pop    %ebp
f01059f0:	c3                   	ret    
f01059f1:	66 90                	xchg   %ax,%ax
f01059f3:	90                   	nop

f01059f4 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f01059f4:	fa                   	cli    

	xorw    %ax, %ax
f01059f5:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f01059f7:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01059f9:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01059fb:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f01059fd:	0f 01 16             	lgdtl  (%esi)
f0105a00:	74 70                	je     f0105a72 <mpsearch1+0x3>
	movl    %cr0, %eax
f0105a02:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105a05:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105a09:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105a0c:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105a12:	08 00                	or     %al,(%eax)

f0105a14 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105a14:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105a18:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105a1a:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105a1c:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105a1e:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105a22:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105a24:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105a26:	b8 00 20 12 00       	mov    $0x122000,%eax
	movl    %eax, %cr3
f0105a2b:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105a2e:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105a31:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105a36:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105a39:	8b 25 94 ce 2a f0    	mov    0xf02ace94,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105a3f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105a44:	b8 c9 01 10 f0       	mov    $0xf01001c9,%eax
	call    *%eax
f0105a49:	ff d0                	call   *%eax

f0105a4b <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105a4b:	eb fe                	jmp    f0105a4b <spin>
f0105a4d:	8d 76 00             	lea    0x0(%esi),%esi

f0105a50 <gdt>:
	...
f0105a58:	ff                   	(bad)  
f0105a59:	ff 00                	incl   (%eax)
f0105a5b:	00 00                	add    %al,(%eax)
f0105a5d:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105a64:	00                   	.byte 0x0
f0105a65:	92                   	xchg   %eax,%edx
f0105a66:	cf                   	iret   
	...

f0105a68 <gdtdesc>:
f0105a68:	17                   	pop    %ss
f0105a69:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105a6e <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105a6e:	90                   	nop

f0105a6f <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105a6f:	55                   	push   %ebp
f0105a70:	89 e5                	mov    %esp,%ebp
f0105a72:	57                   	push   %edi
f0105a73:	56                   	push   %esi
f0105a74:	53                   	push   %ebx
f0105a75:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105a78:	8b 0d 98 ce 2a f0    	mov    0xf02ace98,%ecx
f0105a7e:	89 c3                	mov    %eax,%ebx
f0105a80:	c1 eb 0c             	shr    $0xc,%ebx
f0105a83:	39 cb                	cmp    %ecx,%ebx
f0105a85:	72 12                	jb     f0105a99 <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105a87:	50                   	push   %eax
f0105a88:	68 44 6e 10 f0       	push   $0xf0106e44
f0105a8d:	6a 57                	push   $0x57
f0105a8f:	68 1d 8c 10 f0       	push   $0xf0108c1d
f0105a94:	e8 a7 a5 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105a99:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105a9f:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105aa1:	89 c2                	mov    %eax,%edx
f0105aa3:	c1 ea 0c             	shr    $0xc,%edx
f0105aa6:	39 ca                	cmp    %ecx,%edx
f0105aa8:	72 12                	jb     f0105abc <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105aaa:	50                   	push   %eax
f0105aab:	68 44 6e 10 f0       	push   $0xf0106e44
f0105ab0:	6a 57                	push   $0x57
f0105ab2:	68 1d 8c 10 f0       	push   $0xf0108c1d
f0105ab7:	e8 84 a5 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105abc:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f0105ac2:	eb 2f                	jmp    f0105af3 <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105ac4:	83 ec 04             	sub    $0x4,%esp
f0105ac7:	6a 04                	push   $0x4
f0105ac9:	68 2d 8c 10 f0       	push   $0xf0108c2d
f0105ace:	53                   	push   %ebx
f0105acf:	e8 e3 fd ff ff       	call   f01058b7 <memcmp>
f0105ad4:	83 c4 10             	add    $0x10,%esp
f0105ad7:	85 c0                	test   %eax,%eax
f0105ad9:	75 15                	jne    f0105af0 <mpsearch1+0x81>
f0105adb:	89 da                	mov    %ebx,%edx
f0105add:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f0105ae0:	0f b6 0a             	movzbl (%edx),%ecx
f0105ae3:	01 c8                	add    %ecx,%eax
f0105ae5:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105ae8:	39 d7                	cmp    %edx,%edi
f0105aea:	75 f4                	jne    f0105ae0 <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105aec:	84 c0                	test   %al,%al
f0105aee:	74 0e                	je     f0105afe <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0105af0:	83 c3 10             	add    $0x10,%ebx
f0105af3:	39 f3                	cmp    %esi,%ebx
f0105af5:	72 cd                	jb     f0105ac4 <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105af7:	b8 00 00 00 00       	mov    $0x0,%eax
f0105afc:	eb 02                	jmp    f0105b00 <mpsearch1+0x91>
f0105afe:	89 d8                	mov    %ebx,%eax
}
f0105b00:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105b03:	5b                   	pop    %ebx
f0105b04:	5e                   	pop    %esi
f0105b05:	5f                   	pop    %edi
f0105b06:	5d                   	pop    %ebp
f0105b07:	c3                   	ret    

f0105b08 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105b08:	55                   	push   %ebp
f0105b09:	89 e5                	mov    %esp,%ebp
f0105b0b:	57                   	push   %edi
f0105b0c:	56                   	push   %esi
f0105b0d:	53                   	push   %ebx
f0105b0e:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105b11:	c7 05 c0 d3 2a f0 20 	movl   $0xf02ad020,0xf02ad3c0
f0105b18:	d0 2a f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105b1b:	83 3d 98 ce 2a f0 00 	cmpl   $0x0,0xf02ace98
f0105b22:	75 16                	jne    f0105b3a <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105b24:	68 00 04 00 00       	push   $0x400
f0105b29:	68 44 6e 10 f0       	push   $0xf0106e44
f0105b2e:	6a 6f                	push   $0x6f
f0105b30:	68 1d 8c 10 f0       	push   $0xf0108c1d
f0105b35:	e8 06 a5 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105b3a:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105b41:	85 c0                	test   %eax,%eax
f0105b43:	74 16                	je     f0105b5b <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f0105b45:	c1 e0 04             	shl    $0x4,%eax
f0105b48:	ba 00 04 00 00       	mov    $0x400,%edx
f0105b4d:	e8 1d ff ff ff       	call   f0105a6f <mpsearch1>
f0105b52:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105b55:	85 c0                	test   %eax,%eax
f0105b57:	75 3c                	jne    f0105b95 <mp_init+0x8d>
f0105b59:	eb 20                	jmp    f0105b7b <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105b5b:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105b62:	c1 e0 0a             	shl    $0xa,%eax
f0105b65:	2d 00 04 00 00       	sub    $0x400,%eax
f0105b6a:	ba 00 04 00 00       	mov    $0x400,%edx
f0105b6f:	e8 fb fe ff ff       	call   f0105a6f <mpsearch1>
f0105b74:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105b77:	85 c0                	test   %eax,%eax
f0105b79:	75 1a                	jne    f0105b95 <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0105b7b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105b80:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105b85:	e8 e5 fe ff ff       	call   f0105a6f <mpsearch1>
f0105b8a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0105b8d:	85 c0                	test   %eax,%eax
f0105b8f:	0f 84 5d 02 00 00    	je     f0105df2 <mp_init+0x2ea>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105b95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105b98:	8b 70 04             	mov    0x4(%eax),%esi
f0105b9b:	85 f6                	test   %esi,%esi
f0105b9d:	74 06                	je     f0105ba5 <mp_init+0x9d>
f0105b9f:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105ba3:	74 15                	je     f0105bba <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f0105ba5:	83 ec 0c             	sub    $0xc,%esp
f0105ba8:	68 90 8a 10 f0       	push   $0xf0108a90
f0105bad:	e8 df dd ff ff       	call   f0103991 <cprintf>
f0105bb2:	83 c4 10             	add    $0x10,%esp
f0105bb5:	e9 38 02 00 00       	jmp    f0105df2 <mp_init+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105bba:	89 f0                	mov    %esi,%eax
f0105bbc:	c1 e8 0c             	shr    $0xc,%eax
f0105bbf:	3b 05 98 ce 2a f0    	cmp    0xf02ace98,%eax
f0105bc5:	72 15                	jb     f0105bdc <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105bc7:	56                   	push   %esi
f0105bc8:	68 44 6e 10 f0       	push   $0xf0106e44
f0105bcd:	68 90 00 00 00       	push   $0x90
f0105bd2:	68 1d 8c 10 f0       	push   $0xf0108c1d
f0105bd7:	e8 64 a4 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105bdc:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105be2:	83 ec 04             	sub    $0x4,%esp
f0105be5:	6a 04                	push   $0x4
f0105be7:	68 32 8c 10 f0       	push   $0xf0108c32
f0105bec:	53                   	push   %ebx
f0105bed:	e8 c5 fc ff ff       	call   f01058b7 <memcmp>
f0105bf2:	83 c4 10             	add    $0x10,%esp
f0105bf5:	85 c0                	test   %eax,%eax
f0105bf7:	74 15                	je     f0105c0e <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105bf9:	83 ec 0c             	sub    $0xc,%esp
f0105bfc:	68 c0 8a 10 f0       	push   $0xf0108ac0
f0105c01:	e8 8b dd ff ff       	call   f0103991 <cprintf>
f0105c06:	83 c4 10             	add    $0x10,%esp
f0105c09:	e9 e4 01 00 00       	jmp    f0105df2 <mp_init+0x2ea>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105c0e:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f0105c12:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f0105c16:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105c19:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105c1e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c23:	eb 0d                	jmp    f0105c32 <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f0105c25:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0105c2c:	f0 
f0105c2d:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105c2f:	83 c0 01             	add    $0x1,%eax
f0105c32:	39 c7                	cmp    %eax,%edi
f0105c34:	75 ef                	jne    f0105c25 <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105c36:	84 d2                	test   %dl,%dl
f0105c38:	74 15                	je     f0105c4f <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105c3a:	83 ec 0c             	sub    $0xc,%esp
f0105c3d:	68 f4 8a 10 f0       	push   $0xf0108af4
f0105c42:	e8 4a dd ff ff       	call   f0103991 <cprintf>
f0105c47:	83 c4 10             	add    $0x10,%esp
f0105c4a:	e9 a3 01 00 00       	jmp    f0105df2 <mp_init+0x2ea>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0105c4f:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0105c53:	3c 01                	cmp    $0x1,%al
f0105c55:	74 1d                	je     f0105c74 <mp_init+0x16c>
f0105c57:	3c 04                	cmp    $0x4,%al
f0105c59:	74 19                	je     f0105c74 <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105c5b:	83 ec 08             	sub    $0x8,%esp
f0105c5e:	0f b6 c0             	movzbl %al,%eax
f0105c61:	50                   	push   %eax
f0105c62:	68 18 8b 10 f0       	push   $0xf0108b18
f0105c67:	e8 25 dd ff ff       	call   f0103991 <cprintf>
f0105c6c:	83 c4 10             	add    $0x10,%esp
f0105c6f:	e9 7e 01 00 00       	jmp    f0105df2 <mp_init+0x2ea>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105c74:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f0105c78:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105c7c:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105c81:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f0105c86:	01 ce                	add    %ecx,%esi
f0105c88:	eb 0d                	jmp    f0105c97 <mp_init+0x18f>
f0105c8a:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f0105c91:	f0 
f0105c92:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105c94:	83 c0 01             	add    $0x1,%eax
f0105c97:	39 c7                	cmp    %eax,%edi
f0105c99:	75 ef                	jne    f0105c8a <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105c9b:	89 d0                	mov    %edx,%eax
f0105c9d:	02 43 2a             	add    0x2a(%ebx),%al
f0105ca0:	74 15                	je     f0105cb7 <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105ca2:	83 ec 0c             	sub    $0xc,%esp
f0105ca5:	68 38 8b 10 f0       	push   $0xf0108b38
f0105caa:	e8 e2 dc ff ff       	call   f0103991 <cprintf>
f0105caf:	83 c4 10             	add    $0x10,%esp
f0105cb2:	e9 3b 01 00 00       	jmp    f0105df2 <mp_init+0x2ea>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0105cb7:	85 db                	test   %ebx,%ebx
f0105cb9:	0f 84 33 01 00 00    	je     f0105df2 <mp_init+0x2ea>
		return;
	ismp = 1;
f0105cbf:	c7 05 00 d0 2a f0 01 	movl   $0x1,0xf02ad000
f0105cc6:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105cc9:	8b 43 24             	mov    0x24(%ebx),%eax
f0105ccc:	a3 00 e0 2e f0       	mov    %eax,0xf02ee000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105cd1:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0105cd4:	be 00 00 00 00       	mov    $0x0,%esi
f0105cd9:	e9 85 00 00 00       	jmp    f0105d63 <mp_init+0x25b>
		switch (*p) {
f0105cde:	0f b6 07             	movzbl (%edi),%eax
f0105ce1:	84 c0                	test   %al,%al
f0105ce3:	74 06                	je     f0105ceb <mp_init+0x1e3>
f0105ce5:	3c 04                	cmp    $0x4,%al
f0105ce7:	77 55                	ja     f0105d3e <mp_init+0x236>
f0105ce9:	eb 4e                	jmp    f0105d39 <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105ceb:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105cef:	74 11                	je     f0105d02 <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f0105cf1:	6b 05 c4 d3 2a f0 74 	imul   $0x74,0xf02ad3c4,%eax
f0105cf8:	05 20 d0 2a f0       	add    $0xf02ad020,%eax
f0105cfd:	a3 c0 d3 2a f0       	mov    %eax,0xf02ad3c0
			if (ncpu < NCPU) {
f0105d02:	a1 c4 d3 2a f0       	mov    0xf02ad3c4,%eax
f0105d07:	83 f8 07             	cmp    $0x7,%eax
f0105d0a:	7f 13                	jg     f0105d1f <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f0105d0c:	6b d0 74             	imul   $0x74,%eax,%edx
f0105d0f:	88 82 20 d0 2a f0    	mov    %al,-0xfd52fe0(%edx)
				ncpu++;
f0105d15:	83 c0 01             	add    $0x1,%eax
f0105d18:	a3 c4 d3 2a f0       	mov    %eax,0xf02ad3c4
f0105d1d:	eb 15                	jmp    f0105d34 <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105d1f:	83 ec 08             	sub    $0x8,%esp
f0105d22:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105d26:	50                   	push   %eax
f0105d27:	68 68 8b 10 f0       	push   $0xf0108b68
f0105d2c:	e8 60 dc ff ff       	call   f0103991 <cprintf>
f0105d31:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105d34:	83 c7 14             	add    $0x14,%edi
			continue;
f0105d37:	eb 27                	jmp    f0105d60 <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105d39:	83 c7 08             	add    $0x8,%edi
			continue;
f0105d3c:	eb 22                	jmp    f0105d60 <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105d3e:	83 ec 08             	sub    $0x8,%esp
f0105d41:	0f b6 c0             	movzbl %al,%eax
f0105d44:	50                   	push   %eax
f0105d45:	68 90 8b 10 f0       	push   $0xf0108b90
f0105d4a:	e8 42 dc ff ff       	call   f0103991 <cprintf>
			ismp = 0;
f0105d4f:	c7 05 00 d0 2a f0 00 	movl   $0x0,0xf02ad000
f0105d56:	00 00 00 
			i = conf->entry;
f0105d59:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f0105d5d:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105d60:	83 c6 01             	add    $0x1,%esi
f0105d63:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0105d67:	39 c6                	cmp    %eax,%esi
f0105d69:	0f 82 6f ff ff ff    	jb     f0105cde <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105d6f:	a1 c0 d3 2a f0       	mov    0xf02ad3c0,%eax
f0105d74:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105d7b:	83 3d 00 d0 2a f0 00 	cmpl   $0x0,0xf02ad000
f0105d82:	75 26                	jne    f0105daa <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105d84:	c7 05 c4 d3 2a f0 01 	movl   $0x1,0xf02ad3c4
f0105d8b:	00 00 00 
		lapicaddr = 0;
f0105d8e:	c7 05 00 e0 2e f0 00 	movl   $0x0,0xf02ee000
f0105d95:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105d98:	83 ec 0c             	sub    $0xc,%esp
f0105d9b:	68 b0 8b 10 f0       	push   $0xf0108bb0
f0105da0:	e8 ec db ff ff       	call   f0103991 <cprintf>
		return;
f0105da5:	83 c4 10             	add    $0x10,%esp
f0105da8:	eb 48                	jmp    f0105df2 <mp_init+0x2ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105daa:	83 ec 04             	sub    $0x4,%esp
f0105dad:	ff 35 c4 d3 2a f0    	pushl  0xf02ad3c4
f0105db3:	0f b6 00             	movzbl (%eax),%eax
f0105db6:	50                   	push   %eax
f0105db7:	68 37 8c 10 f0       	push   $0xf0108c37
f0105dbc:	e8 d0 db ff ff       	call   f0103991 <cprintf>

	if (mp->imcrp) {
f0105dc1:	83 c4 10             	add    $0x10,%esp
f0105dc4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105dc7:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105dcb:	74 25                	je     f0105df2 <mp_init+0x2ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105dcd:	83 ec 0c             	sub    $0xc,%esp
f0105dd0:	68 dc 8b 10 f0       	push   $0xf0108bdc
f0105dd5:	e8 b7 db ff ff       	call   f0103991 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105dda:	ba 22 00 00 00       	mov    $0x22,%edx
f0105ddf:	b8 70 00 00 00       	mov    $0x70,%eax
f0105de4:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105de5:	ba 23 00 00 00       	mov    $0x23,%edx
f0105dea:	ec                   	in     (%dx),%al
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105deb:	83 c8 01             	or     $0x1,%eax
f0105dee:	ee                   	out    %al,(%dx)
f0105def:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105df2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105df5:	5b                   	pop    %ebx
f0105df6:	5e                   	pop    %esi
f0105df7:	5f                   	pop    %edi
f0105df8:	5d                   	pop    %ebp
f0105df9:	c3                   	ret    

f0105dfa <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105dfa:	55                   	push   %ebp
f0105dfb:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105dfd:	8b 0d 04 e0 2e f0    	mov    0xf02ee004,%ecx
f0105e03:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105e06:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105e08:	a1 04 e0 2e f0       	mov    0xf02ee004,%eax
f0105e0d:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105e10:	5d                   	pop    %ebp
f0105e11:	c3                   	ret    

f0105e12 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105e12:	55                   	push   %ebp
f0105e13:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105e15:	a1 04 e0 2e f0       	mov    0xf02ee004,%eax
f0105e1a:	85 c0                	test   %eax,%eax
f0105e1c:	74 08                	je     f0105e26 <cpunum+0x14>
		return lapic[ID] >> 24;
f0105e1e:	8b 40 20             	mov    0x20(%eax),%eax
f0105e21:	c1 e8 18             	shr    $0x18,%eax
f0105e24:	eb 05                	jmp    f0105e2b <cpunum+0x19>
	return 0;
f0105e26:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105e2b:	5d                   	pop    %ebp
f0105e2c:	c3                   	ret    

f0105e2d <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0105e2d:	a1 00 e0 2e f0       	mov    0xf02ee000,%eax
f0105e32:	85 c0                	test   %eax,%eax
f0105e34:	0f 84 21 01 00 00    	je     f0105f5b <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0105e3a:	55                   	push   %ebp
f0105e3b:	89 e5                	mov    %esp,%ebp
f0105e3d:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0105e40:	68 00 10 00 00       	push   $0x1000
f0105e45:	50                   	push   %eax
f0105e46:	e8 cf b6 ff ff       	call   f010151a <mmio_map_region>
f0105e4b:	a3 04 e0 2e f0       	mov    %eax,0xf02ee004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105e50:	ba 27 01 00 00       	mov    $0x127,%edx
f0105e55:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105e5a:	e8 9b ff ff ff       	call   f0105dfa <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0105e5f:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105e64:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105e69:	e8 8c ff ff ff       	call   f0105dfa <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105e6e:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105e73:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105e78:	e8 7d ff ff ff       	call   f0105dfa <lapicw>
	lapicw(TICR, 10000000); 
f0105e7d:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105e82:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105e87:	e8 6e ff ff ff       	call   f0105dfa <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0105e8c:	e8 81 ff ff ff       	call   f0105e12 <cpunum>
f0105e91:	6b c0 74             	imul   $0x74,%eax,%eax
f0105e94:	05 20 d0 2a f0       	add    $0xf02ad020,%eax
f0105e99:	83 c4 10             	add    $0x10,%esp
f0105e9c:	39 05 c0 d3 2a f0    	cmp    %eax,0xf02ad3c0
f0105ea2:	74 0f                	je     f0105eb3 <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f0105ea4:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105ea9:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105eae:	e8 47 ff ff ff       	call   f0105dfa <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0105eb3:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105eb8:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105ebd:	e8 38 ff ff ff       	call   f0105dfa <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105ec2:	a1 04 e0 2e f0       	mov    0xf02ee004,%eax
f0105ec7:	8b 40 30             	mov    0x30(%eax),%eax
f0105eca:	c1 e8 10             	shr    $0x10,%eax
f0105ecd:	3c 03                	cmp    $0x3,%al
f0105ecf:	76 0f                	jbe    f0105ee0 <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f0105ed1:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105ed6:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105edb:	e8 1a ff ff ff       	call   f0105dfa <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105ee0:	ba 33 00 00 00       	mov    $0x33,%edx
f0105ee5:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105eea:	e8 0b ff ff ff       	call   f0105dfa <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0105eef:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ef4:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105ef9:	e8 fc fe ff ff       	call   f0105dfa <lapicw>
	lapicw(ESR, 0);
f0105efe:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f03:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105f08:	e8 ed fe ff ff       	call   f0105dfa <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0105f0d:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f12:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105f17:	e8 de fe ff ff       	call   f0105dfa <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0105f1c:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f21:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105f26:	e8 cf fe ff ff       	call   f0105dfa <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105f2b:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105f30:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f35:	e8 c0 fe ff ff       	call   f0105dfa <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105f3a:	8b 15 04 e0 2e f0    	mov    0xf02ee004,%edx
f0105f40:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105f46:	f6 c4 10             	test   $0x10,%ah
f0105f49:	75 f5                	jne    f0105f40 <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0105f4b:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f50:	b8 20 00 00 00       	mov    $0x20,%eax
f0105f55:	e8 a0 fe ff ff       	call   f0105dfa <lapicw>
}
f0105f5a:	c9                   	leave  
f0105f5b:	f3 c3                	repz ret 

f0105f5d <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105f5d:	83 3d 04 e0 2e f0 00 	cmpl   $0x0,0xf02ee004
f0105f64:	74 13                	je     f0105f79 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105f66:	55                   	push   %ebp
f0105f67:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0105f69:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f6e:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105f73:	e8 82 fe ff ff       	call   f0105dfa <lapicw>
}
f0105f78:	5d                   	pop    %ebp
f0105f79:	f3 c3                	repz ret 

f0105f7b <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105f7b:	55                   	push   %ebp
f0105f7c:	89 e5                	mov    %esp,%ebp
f0105f7e:	56                   	push   %esi
f0105f7f:	53                   	push   %ebx
f0105f80:	8b 75 08             	mov    0x8(%ebp),%esi
f0105f83:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105f86:	ba 70 00 00 00       	mov    $0x70,%edx
f0105f8b:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105f90:	ee                   	out    %al,(%dx)
f0105f91:	ba 71 00 00 00       	mov    $0x71,%edx
f0105f96:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105f9b:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105f9c:	83 3d 98 ce 2a f0 00 	cmpl   $0x0,0xf02ace98
f0105fa3:	75 19                	jne    f0105fbe <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105fa5:	68 67 04 00 00       	push   $0x467
f0105faa:	68 44 6e 10 f0       	push   $0xf0106e44
f0105faf:	68 98 00 00 00       	push   $0x98
f0105fb4:	68 54 8c 10 f0       	push   $0xf0108c54
f0105fb9:	e8 82 a0 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105fbe:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105fc5:	00 00 
	wrv[1] = addr >> 4;
f0105fc7:	89 d8                	mov    %ebx,%eax
f0105fc9:	c1 e8 04             	shr    $0x4,%eax
f0105fcc:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105fd2:	c1 e6 18             	shl    $0x18,%esi
f0105fd5:	89 f2                	mov    %esi,%edx
f0105fd7:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105fdc:	e8 19 fe ff ff       	call   f0105dfa <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105fe1:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105fe6:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105feb:	e8 0a fe ff ff       	call   f0105dfa <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105ff0:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105ff5:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105ffa:	e8 fb fd ff ff       	call   f0105dfa <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105fff:	c1 eb 0c             	shr    $0xc,%ebx
f0106002:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106005:	89 f2                	mov    %esi,%edx
f0106007:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010600c:	e8 e9 fd ff ff       	call   f0105dfa <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106011:	89 da                	mov    %ebx,%edx
f0106013:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106018:	e8 dd fd ff ff       	call   f0105dfa <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f010601d:	89 f2                	mov    %esi,%edx
f010601f:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106024:	e8 d1 fd ff ff       	call   f0105dfa <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106029:	89 da                	mov    %ebx,%edx
f010602b:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106030:	e8 c5 fd ff ff       	call   f0105dfa <lapicw>
		microdelay(200);
	}
}
f0106035:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106038:	5b                   	pop    %ebx
f0106039:	5e                   	pop    %esi
f010603a:	5d                   	pop    %ebp
f010603b:	c3                   	ret    

f010603c <lapic_ipi>:

void
lapic_ipi(int vector)
{
f010603c:	55                   	push   %ebp
f010603d:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f010603f:	8b 55 08             	mov    0x8(%ebp),%edx
f0106042:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0106048:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010604d:	e8 a8 fd ff ff       	call   f0105dfa <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0106052:	8b 15 04 e0 2e f0    	mov    0xf02ee004,%edx
f0106058:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f010605e:	f6 c4 10             	test   $0x10,%ah
f0106061:	75 f5                	jne    f0106058 <lapic_ipi+0x1c>
		;
}
f0106063:	5d                   	pop    %ebp
f0106064:	c3                   	ret    

f0106065 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0106065:	55                   	push   %ebp
f0106066:	89 e5                	mov    %esp,%ebp
f0106068:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f010606b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0106071:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106074:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0106077:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f010607e:	5d                   	pop    %ebp
f010607f:	c3                   	ret    

f0106080 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0106080:	55                   	push   %ebp
f0106081:	89 e5                	mov    %esp,%ebp
f0106083:	56                   	push   %esi
f0106084:	53                   	push   %ebx
f0106085:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0106088:	83 3b 00             	cmpl   $0x0,(%ebx)
f010608b:	74 14                	je     f01060a1 <spin_lock+0x21>
f010608d:	8b 73 08             	mov    0x8(%ebx),%esi
f0106090:	e8 7d fd ff ff       	call   f0105e12 <cpunum>
f0106095:	6b c0 74             	imul   $0x74,%eax,%eax
f0106098:	05 20 d0 2a f0       	add    $0xf02ad020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f010609d:	39 c6                	cmp    %eax,%esi
f010609f:	74 07                	je     f01060a8 <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01060a1:	ba 01 00 00 00       	mov    $0x1,%edx
f01060a6:	eb 20                	jmp    f01060c8 <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f01060a8:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01060ab:	e8 62 fd ff ff       	call   f0105e12 <cpunum>
f01060b0:	83 ec 0c             	sub    $0xc,%esp
f01060b3:	53                   	push   %ebx
f01060b4:	50                   	push   %eax
f01060b5:	68 64 8c 10 f0       	push   $0xf0108c64
f01060ba:	6a 41                	push   $0x41
f01060bc:	68 c6 8c 10 f0       	push   $0xf0108cc6
f01060c1:	e8 7a 9f ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f01060c6:	f3 90                	pause  
f01060c8:	89 d0                	mov    %edx,%eax
f01060ca:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f01060cd:	85 c0                	test   %eax,%eax
f01060cf:	75 f5                	jne    f01060c6 <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f01060d1:	e8 3c fd ff ff       	call   f0105e12 <cpunum>
f01060d6:	6b c0 74             	imul   $0x74,%eax,%eax
f01060d9:	05 20 d0 2a f0       	add    $0xf02ad020,%eax
f01060de:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f01060e1:	83 c3 0c             	add    $0xc,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01060e4:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01060e6:	b8 00 00 00 00       	mov    $0x0,%eax
f01060eb:	eb 0b                	jmp    f01060f8 <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f01060ed:	8b 4a 04             	mov    0x4(%edx),%ecx
f01060f0:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01060f3:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01060f5:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f01060f8:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f01060fe:	76 11                	jbe    f0106111 <spin_lock+0x91>
f0106100:	83 f8 09             	cmp    $0x9,%eax
f0106103:	7e e8                	jle    f01060ed <spin_lock+0x6d>
f0106105:	eb 0a                	jmp    f0106111 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0106107:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f010610e:	83 c0 01             	add    $0x1,%eax
f0106111:	83 f8 09             	cmp    $0x9,%eax
f0106114:	7e f1                	jle    f0106107 <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0106116:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106119:	5b                   	pop    %ebx
f010611a:	5e                   	pop    %esi
f010611b:	5d                   	pop    %ebp
f010611c:	c3                   	ret    

f010611d <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f010611d:	55                   	push   %ebp
f010611e:	89 e5                	mov    %esp,%ebp
f0106120:	57                   	push   %edi
f0106121:	56                   	push   %esi
f0106122:	53                   	push   %ebx
f0106123:	83 ec 4c             	sub    $0x4c,%esp
f0106126:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0106129:	83 3e 00             	cmpl   $0x0,(%esi)
f010612c:	74 18                	je     f0106146 <spin_unlock+0x29>
f010612e:	8b 5e 08             	mov    0x8(%esi),%ebx
f0106131:	e8 dc fc ff ff       	call   f0105e12 <cpunum>
f0106136:	6b c0 74             	imul   $0x74,%eax,%eax
f0106139:	05 20 d0 2a f0       	add    $0xf02ad020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f010613e:	39 c3                	cmp    %eax,%ebx
f0106140:	0f 84 a5 00 00 00    	je     f01061eb <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0106146:	83 ec 04             	sub    $0x4,%esp
f0106149:	6a 28                	push   $0x28
f010614b:	8d 46 0c             	lea    0xc(%esi),%eax
f010614e:	50                   	push   %eax
f010614f:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0106152:	53                   	push   %ebx
f0106153:	e8 e4 f6 ff ff       	call   f010583c <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106158:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f010615b:	0f b6 38             	movzbl (%eax),%edi
f010615e:	8b 76 04             	mov    0x4(%esi),%esi
f0106161:	e8 ac fc ff ff       	call   f0105e12 <cpunum>
f0106166:	57                   	push   %edi
f0106167:	56                   	push   %esi
f0106168:	50                   	push   %eax
f0106169:	68 90 8c 10 f0       	push   $0xf0108c90
f010616e:	e8 1e d8 ff ff       	call   f0103991 <cprintf>
f0106173:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106176:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0106179:	eb 54                	jmp    f01061cf <spin_unlock+0xb2>
f010617b:	83 ec 08             	sub    $0x8,%esp
f010617e:	57                   	push   %edi
f010617f:	50                   	push   %eax
f0106180:	e8 d8 eb ff ff       	call   f0104d5d <debuginfo_eip>
f0106185:	83 c4 10             	add    $0x10,%esp
f0106188:	85 c0                	test   %eax,%eax
f010618a:	78 27                	js     f01061b3 <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f010618c:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f010618e:	83 ec 04             	sub    $0x4,%esp
f0106191:	89 c2                	mov    %eax,%edx
f0106193:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0106196:	52                   	push   %edx
f0106197:	ff 75 b0             	pushl  -0x50(%ebp)
f010619a:	ff 75 b4             	pushl  -0x4c(%ebp)
f010619d:	ff 75 ac             	pushl  -0x54(%ebp)
f01061a0:	ff 75 a8             	pushl  -0x58(%ebp)
f01061a3:	50                   	push   %eax
f01061a4:	68 d6 8c 10 f0       	push   $0xf0108cd6
f01061a9:	e8 e3 d7 ff ff       	call   f0103991 <cprintf>
f01061ae:	83 c4 20             	add    $0x20,%esp
f01061b1:	eb 12                	jmp    f01061c5 <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f01061b3:	83 ec 08             	sub    $0x8,%esp
f01061b6:	ff 36                	pushl  (%esi)
f01061b8:	68 ed 8c 10 f0       	push   $0xf0108ced
f01061bd:	e8 cf d7 ff ff       	call   f0103991 <cprintf>
f01061c2:	83 c4 10             	add    $0x10,%esp
f01061c5:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f01061c8:	8d 45 e8             	lea    -0x18(%ebp),%eax
f01061cb:	39 c3                	cmp    %eax,%ebx
f01061cd:	74 08                	je     f01061d7 <spin_unlock+0xba>
f01061cf:	89 de                	mov    %ebx,%esi
f01061d1:	8b 03                	mov    (%ebx),%eax
f01061d3:	85 c0                	test   %eax,%eax
f01061d5:	75 a4                	jne    f010617b <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f01061d7:	83 ec 04             	sub    $0x4,%esp
f01061da:	68 f5 8c 10 f0       	push   $0xf0108cf5
f01061df:	6a 67                	push   $0x67
f01061e1:	68 c6 8c 10 f0       	push   $0xf0108cc6
f01061e6:	e8 55 9e ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f01061eb:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f01061f2:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01061f9:	b8 00 00 00 00       	mov    $0x0,%eax
f01061fe:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0106201:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106204:	5b                   	pop    %ebx
f0106205:	5e                   	pop    %esi
f0106206:	5f                   	pop    %edi
f0106207:	5d                   	pop    %ebp
f0106208:	c3                   	ret    

f0106209 <e1000_transmit>:
}


int
e1000_transmit(char *data, uint32_t len)
{
f0106209:	55                   	push   %ebp
f010620a:	89 e5                	mov    %esp,%ebp
f010620c:	53                   	push   %ebx
f010620d:	83 ec 04             	sub    $0x4,%esp
f0106210:	8b 4d 0c             	mov    0xc(%ebp),%ecx
    uint32_t current = tdt->tdt;
f0106213:	a1 40 a6 2f f0       	mov    0xf02fa640,%eax
f0106218:	0f b7 18             	movzwl (%eax),%ebx

    if(!(transmit_desc_array[current].status & E1000_TXD_STAT_DD)) {
f010621b:	89 d8                	mov    %ebx,%eax
f010621d:	c1 e0 04             	shl    $0x4,%eax
f0106220:	0f b6 90 8c 9e 32 f0 	movzbl -0xfcd6174(%eax),%edx
f0106227:	f6 c2 01             	test   $0x1,%dl
f010622a:	74 4e                	je     f010627a <e1000_transmit+0x71>
        return -1;
    }

    transmit_desc_array[current].length = len;
f010622c:	89 d8                	mov    %ebx,%eax
f010622e:	c1 e0 04             	shl    $0x4,%eax
f0106231:	66 89 88 88 9e 32 f0 	mov    %cx,-0xfcd6178(%eax)
    transmit_desc_array[current].status &= ~E1000_TXD_STAT_DD;
f0106238:	83 e2 fe             	and    $0xfffffffe,%edx
f010623b:	88 90 8c 9e 32 f0    	mov    %dl,-0xfcd6174(%eax)

    if(!(transmit_desc_array[current].status & E1000_TXD_STAT_DD)) {
        return -1;
    }

    transmit_desc_array[current].length = len;
f0106241:	05 80 9e 32 f0       	add    $0xf0329e80,%eax
    transmit_desc_array[current].status &= ~E1000_TXD_STAT_DD;
    transmit_desc_array[current].cmd |= (E1000_TXD_CMD_EOP | E1000_TXD_CMD_RS);
f0106246:	80 48 0b 09          	orb    $0x9,0xb(%eax)

    memcpy(transmit_buffer[current], data, len);
f010624a:	83 ec 04             	sub    $0x4,%esp
f010624d:	51                   	push   %ecx
f010624e:	ff 75 08             	pushl  0x8(%ebp)
f0106251:	69 c3 f0 05 00 00    	imul   $0x5f0,%ebx,%eax
f0106257:	05 40 e8 2e f0       	add    $0xf02ee840,%eax
f010625c:	50                   	push   %eax
f010625d:	e8 42 f6 ff ff       	call   f01058a4 <memcpy>
    uint32_t next = (current + 1) % 32;
    tdt->tdt = next;
f0106262:	83 c3 01             	add    $0x1,%ebx
f0106265:	83 e3 1f             	and    $0x1f,%ebx
f0106268:	a1 40 a6 2f f0       	mov    0xf02fa640,%eax
f010626d:	66 89 18             	mov    %bx,(%eax)

    return 0;
f0106270:	83 c4 10             	add    $0x10,%esp
f0106273:	b8 00 00 00 00       	mov    $0x0,%eax
f0106278:	eb 05                	jmp    f010627f <e1000_transmit+0x76>
e1000_transmit(char *data, uint32_t len)
{
    uint32_t current = tdt->tdt;

    if(!(transmit_desc_array[current].status & E1000_TXD_STAT_DD)) {
        return -1;
f010627a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    memcpy(transmit_buffer[current], data, len);
    uint32_t next = (current + 1) % 32;
    tdt->tdt = next;

    return 0;
}
f010627f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0106282:	c9                   	leave  
f0106283:	c3                   	ret    

f0106284 <get_ra_address>:

void
get_ra_address(uint32_t mac[], uint32_t *ral, uint32_t *rah)
{
f0106284:	55                   	push   %ebp
f0106285:	89 e5                	mov    %esp,%ebp
f0106287:	56                   	push   %esi
f0106288:	53                   	push   %ebx
f0106289:	8b 75 08             	mov    0x8(%ebp),%esi
    uint32_t low = 0, high = 0;
    int i;

    for (i = 0; i < 4; i++) {
f010628c:	b8 00 00 00 00       	mov    $0x0,%eax
}

void
get_ra_address(uint32_t mac[], uint32_t *ral, uint32_t *rah)
{
    uint32_t low = 0, high = 0;
f0106291:	bb 00 00 00 00       	mov    $0x0,%ebx
    int i;

    for (i = 0; i < 4; i++) {
            low |= mac[i] << (8 * i);
f0106296:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
f010629d:	8b 14 86             	mov    (%esi,%eax,4),%edx
f01062a0:	d3 e2                	shl    %cl,%edx
f01062a2:	09 d3                	or     %edx,%ebx
get_ra_address(uint32_t mac[], uint32_t *ral, uint32_t *rah)
{
    uint32_t low = 0, high = 0;
    int i;

    for (i = 0; i < 4; i++) {
f01062a4:	83 c0 01             	add    $0x1,%eax
f01062a7:	83 f8 04             	cmp    $0x4,%eax
f01062aa:	75 ea                	jne    f0106296 <get_ra_address+0x12>
            low |= mac[i] << (8 * i);
    }

    for (i = 4; i < 6; i++) {
            high |= mac[i] << (8 * i);
f01062ac:	8b 56 10             	mov    0x10(%esi),%edx
f01062af:	b9 20 00 00 00       	mov    $0x20,%ecx
f01062b4:	d3 e2                	shl    %cl,%edx
f01062b6:	8b 46 14             	mov    0x14(%esi),%eax
f01062b9:	b9 28 00 00 00       	mov    $0x28,%ecx
f01062be:	d3 e0                	shl    %cl,%eax
f01062c0:	0d 00 00 00 80       	or     $0x80000000,%eax
    }

    *ral = low;
f01062c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01062c8:	89 19                	mov    %ebx,(%ecx)
    *rah = high | E1000_RAH_AV;
f01062ca:	09 d0                	or     %edx,%eax
f01062cc:	8b 55 10             	mov    0x10(%ebp),%edx
f01062cf:	89 02                	mov    %eax,(%edx)
}
f01062d1:	5b                   	pop    %ebx
f01062d2:	5e                   	pop    %esi
f01062d3:	5d                   	pop    %ebp
f01062d4:	c3                   	ret    

f01062d5 <e1000_receive_init>:

void
e1000_receive_init()
{
f01062d5:	55                   	push   %ebp
f01062d6:	89 e5                	mov    %esp,%ebp
f01062d8:	56                   	push   %esi
f01062d9:	53                   	push   %ebx
f01062da:	83 ec 10             	sub    $0x10,%esp
    uint32_t *rdbal = (uint32_t *)E1000_ADDR(E1000_RDBAL);
f01062dd:	8b 1d 68 9e 32 f0    	mov    0xf0329e68,%ebx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01062e3:	b8 20 e0 2e f0       	mov    $0xf02ee020,%eax
f01062e8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01062ed:	77 15                	ja     f0106304 <e1000_receive_init+0x2f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01062ef:	50                   	push   %eax
f01062f0:	68 68 6e 10 f0       	push   $0xf0106e68
f01062f5:	68 81 00 00 00       	push   $0x81
f01062fa:	68 0d 8d 10 f0       	push   $0xf0108d0d
f01062ff:	e8 3c 9d ff ff       	call   f0100040 <_panic>
    uint32_t *rdbah = (uint32_t *)E1000_ADDR(E1000_RDBAH);
    *rdbal = PADDR(receive_desc_array);
f0106304:	c7 83 00 28 00 00 20 	movl   $0x2ee020,0x2800(%ebx)
f010630b:	e0 2e 00 
    *rdbah = 0;
f010630e:	c7 83 04 28 00 00 00 	movl   $0x0,0x2804(%ebx)
f0106315:	00 00 00 
f0106318:	b8 60 a6 2f f0       	mov    $0xf02fa660,%eax
f010631d:	be 60 9e 32 f0       	mov    $0xf0329e60,%esi
f0106322:	ba 20 e0 2e f0       	mov    $0xf02ee020,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0106327:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010632c:	77 15                	ja     f0106343 <e1000_receive_init+0x6e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010632e:	50                   	push   %eax
f010632f:	68 68 6e 10 f0       	push   $0xf0106e68
f0106334:	68 86 00 00 00       	push   $0x86
f0106339:	68 0d 8d 10 f0       	push   $0xf0108d0d
f010633e:	e8 fd 9c ff ff       	call   f0100040 <_panic>

    int i;
    for (i = 0; i < 128; i++) {
            receive_desc_array[i].addr = PADDR(receive_buffer[i]);
f0106343:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
f0106349:	89 0a                	mov    %ecx,(%edx)
f010634b:	c7 42 04 00 00 00 00 	movl   $0x0,0x4(%edx)
f0106352:	05 f0 05 00 00       	add    $0x5f0,%eax
f0106357:	83 c2 10             	add    $0x10,%edx
    uint32_t *rdbah = (uint32_t *)E1000_ADDR(E1000_RDBAH);
    *rdbal = PADDR(receive_desc_array);
    *rdbah = 0;

    int i;
    for (i = 0; i < 128; i++) {
f010635a:	39 f0                	cmp    %esi,%eax
f010635c:	75 c9                	jne    f0106327 <e1000_receive_init+0x52>
            receive_desc_array[i].addr = PADDR(receive_buffer[i]);
    }

    struct e1000_rdlen *rdlen = (struct e1000_rdlen *)E1000_ADDR(E1000_RDLEN);
    rdlen->len = 128;
f010635e:	8b 83 08 28 00 00    	mov    0x2808(%ebx),%eax
f0106364:	25 7f 00 f0 ff       	and    $0xfff0007f,%eax
f0106369:	80 cc 40             	or     $0x40,%ah
f010636c:	89 83 08 28 00 00    	mov    %eax,0x2808(%ebx)

    rdh = (struct e1000_rdh *)E1000_ADDR(E1000_RDH);
f0106372:	8d 83 10 28 00 00    	lea    0x2810(%ebx),%eax
f0106378:	a3 64 9e 32 f0       	mov    %eax,0xf0329e64
    rdt = (struct e1000_rdt *)E1000_ADDR(E1000_RDT);
f010637d:	8d 83 18 28 00 00    	lea    0x2818(%ebx),%eax
f0106383:	a3 60 9e 32 f0       	mov    %eax,0xf0329e60
    rdh->rdh = 0;
f0106388:	66 c7 83 10 28 00 00 	movw   $0x0,0x2810(%ebx)
f010638f:	00 00 
    rdt->rdt = 128-1;
f0106391:	66 c7 83 18 28 00 00 	movw   $0x7f,0x2818(%ebx)
f0106398:	7f 00 

    uint32_t *rctl = (uint32_t *)E1000_ADDR(E1000_RCTL);
    *rctl = E1000_RCTL_EN | E1000_RCTL_BAM | E1000_RCTL_SECRC;
f010639a:	c7 83 00 01 00 00 02 	movl   $0x4008002,0x100(%ebx)
f01063a1:	80 00 04 

    uint32_t *ra = (uint32_t *)E1000_ADDR(E1000_RA);
    uint32_t ral, rah;
    get_ra_address(E1000_MAC, &ral, &rah);
f01063a4:	83 ec 04             	sub    $0x4,%esp
f01063a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
f01063aa:	50                   	push   %eax
f01063ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01063ae:	50                   	push   %eax
f01063af:	68 f4 43 12 f0       	push   $0xf01243f4
f01063b4:	e8 cb fe ff ff       	call   f0106284 <get_ra_address>
    ra[0] = ral;
f01063b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01063bc:	89 83 00 54 00 00    	mov    %eax,0x5400(%ebx)
    ra[1] = rah;
f01063c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01063c5:	89 83 04 54 00 00    	mov    %eax,0x5404(%ebx)
}
f01063cb:	83 c4 10             	add    $0x10,%esp
f01063ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01063d1:	5b                   	pop    %ebx
f01063d2:	5e                   	pop    %esi
f01063d3:	5d                   	pop    %ebp
f01063d4:	c3                   	ret    

f01063d5 <pci_e1000_attach>:
void e1000_receive_init();


int 
pci_e1000_attach(struct pci_func *f)
{
f01063d5:	55                   	push   %ebp
f01063d6:	89 e5                	mov    %esp,%ebp
f01063d8:	56                   	push   %esi
f01063d9:	53                   	push   %ebx
f01063da:	8b 5d 08             	mov    0x8(%ebp),%ebx
    pci_func_enable(f);
f01063dd:	83 ec 0c             	sub    $0xc,%esp
f01063e0:	53                   	push   %ebx
f01063e1:	e8 ec 05 00 00       	call   f01069d2 <pci_func_enable>

    if (!f->reg_base[0])
f01063e6:	8b 43 14             	mov    0x14(%ebx),%eax
f01063e9:	83 c4 10             	add    $0x10,%esp
f01063ec:	85 c0                	test   %eax,%eax
f01063ee:	0f 84 5e 01 00 00    	je     f0106552 <pci_e1000_attach+0x17d>
		return -1;

    e1000 = mmio_map_region(f->reg_base[0], f->reg_size[0]);
f01063f4:	83 ec 08             	sub    $0x8,%esp
f01063f7:	ff 73 2c             	pushl  0x2c(%ebx)
f01063fa:	50                   	push   %eax
f01063fb:	e8 1a b1 ff ff       	call   f010151a <mmio_map_region>
f0106400:	a3 68 9e 32 f0       	mov    %eax,0xf0329e68

    // status offest is 8
    uint32_t status = *(uint32_t *)E1000_ADDR(8);

    if (status != 0x80080783)
f0106405:	83 c4 10             	add    $0x10,%esp
f0106408:	81 78 08 83 07 08 80 	cmpl   $0x80080783,0x8(%eax)
f010640f:	0f 85 44 01 00 00    	jne    f0106559 <pci_e1000_attach+0x184>
f0106415:	b9 40 e8 2e f0       	mov    $0xf02ee840,%ecx
f010641a:	ba 8c 9e 32 f0       	mov    $0xf0329e8c,%edx
f010641f:	be 40 a6 2f f0       	mov    $0xf02fa640,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0106424:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f010642a:	77 12                	ja     f010643e <pci_e1000_attach+0x69>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010642c:	51                   	push   %ecx
f010642d:	68 68 6e 10 f0       	push   $0xf0106e68
f0106432:	6a 34                	push   $0x34
f0106434:	68 0d 8d 10 f0       	push   $0xf0108d0d
f0106439:	e8 02 9c ff ff       	call   f0100040 <_panic>

void 
e1000_transmit_init()
{
    for (int i = 0; i < 32; i++) {
        transmit_desc_array[i].addr = PADDR(transmit_buffer[i]);
f010643e:	8d 99 00 00 00 10    	lea    0x10000000(%ecx),%ebx
f0106444:	89 5a f4             	mov    %ebx,-0xc(%edx)
f0106447:	c7 42 f8 00 00 00 00 	movl   $0x0,-0x8(%edx)
        transmit_desc_array[i].cmd = 0;
f010644e:	c6 42 ff 00          	movb   $0x0,-0x1(%edx)
        transmit_desc_array[i].status |= E1000_TXD_STAT_DD;
f0106452:	80 0a 01             	orb    $0x1,(%edx)
f0106455:	81 c1 f0 05 00 00    	add    $0x5f0,%ecx
f010645b:	83 c2 10             	add    $0x10,%edx
}

void 
e1000_transmit_init()
{
    for (int i = 0; i < 32; i++) {
f010645e:	39 f1                	cmp    %esi,%ecx
f0106460:	75 c2                	jne    f0106424 <pci_e1000_attach+0x4f>
        transmit_desc_array[i].cmd = 0;
        transmit_desc_array[i].status |= E1000_TXD_STAT_DD;
    }

    struct e1000_tdlen *tdlen = (struct e1000_tdlen *)E1000_ADDR(E1000_TDLEN);
    tdlen->len = 32;
f0106462:	8b 90 08 38 00 00    	mov    0x3808(%eax),%edx
f0106468:	81 e2 7f 00 f0 ff    	and    $0xfff0007f,%edx
f010646e:	80 ce 10             	or     $0x10,%dh
f0106471:	89 90 08 38 00 00    	mov    %edx,0x3808(%eax)
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0106477:	ba 80 9e 32 f0       	mov    $0xf0329e80,%edx
f010647c:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0106482:	77 12                	ja     f0106496 <pci_e1000_attach+0xc1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0106484:	52                   	push   %edx
f0106485:	68 68 6e 10 f0       	push   $0xf0106e68
f010648a:	6a 3d                	push   $0x3d
f010648c:	68 0d 8d 10 f0       	push   $0xf0108d0d
f0106491:	e8 aa 9b ff ff       	call   f0100040 <_panic>

    uint32_t *tdbal = (uint32_t *)E1000_ADDR(E1000_TDBAL);
    *tdbal = PADDR(transmit_desc_array);
f0106496:	c7 80 00 38 00 00 80 	movl   $0x329e80,0x3800(%eax)
f010649d:	9e 32 00 

    uint32_t *tdbah = (uint32_t *)E1000_ADDR(E1000_TDBAH);
    *tdbah = 0;
f01064a0:	c7 80 04 38 00 00 00 	movl   $0x0,0x3804(%eax)
f01064a7:	00 00 00 

    tdh = (struct e1000_tdh *)E1000_ADDR(E1000_TDH);
f01064aa:	8d 90 10 38 00 00    	lea    0x3810(%eax),%edx
f01064b0:	89 15 20 e8 2e f0    	mov    %edx,0xf02ee820
    tdh->tdh = 0;
f01064b6:	66 c7 80 10 38 00 00 	movw   $0x0,0x3810(%eax)
f01064bd:	00 00 

    tdt = (struct e1000_tdt *)E1000_ADDR(E1000_TDT);
f01064bf:	8d 90 18 38 00 00    	lea    0x3818(%eax),%edx
f01064c5:	89 15 40 a6 2f f0    	mov    %edx,0xf02fa640
    tdt->tdt = 0;
f01064cb:	66 c7 80 18 38 00 00 	movw   $0x0,0x3818(%eax)
f01064d2:	00 00 

    struct e1000_tctl *tctl = (struct e1000_tctl *)E1000_ADDR(E1000_TCTL);
    tctl->en = 1;
    tctl->psp = 1;
f01064d4:	80 88 00 04 00 00 0a 	orb    $0xa,0x400(%eax)
    tctl->ct = 0x10;
f01064db:	0f b7 90 00 04 00 00 	movzwl 0x400(%eax),%edx
f01064e2:	66 81 e2 0f f0       	and    $0xf00f,%dx
f01064e7:	80 ce 01             	or     $0x1,%dh
f01064ea:	66 89 90 00 04 00 00 	mov    %dx,0x400(%eax)
    tctl->cold = 0x40;
f01064f1:	8b 90 00 04 00 00    	mov    0x400(%eax),%edx
f01064f7:	81 e2 ff 0f c0 ff    	and    $0xffc00fff,%edx
f01064fd:	81 ca 00 00 04 00    	or     $0x40000,%edx
f0106503:	89 90 00 04 00 00    	mov    %edx,0x400(%eax)

    struct e1000_tipg *tipg = (struct e1000_tipg *)E1000_ADDR(E1000_TIPG);
    tipg->ipgt = 10;
f0106509:	0f b7 90 10 04 00 00 	movzwl 0x410(%eax),%edx
f0106510:	66 81 e2 00 fc       	and    $0xfc00,%dx
f0106515:	83 ca 0a             	or     $0xa,%edx
f0106518:	66 89 90 10 04 00 00 	mov    %dx,0x410(%eax)
    tipg->ipgr1 = 4;
f010651f:	8b 90 10 04 00 00    	mov    0x410(%eax),%edx
f0106525:	81 e2 ff 03 f0 ff    	and    $0xfff003ff,%edx
f010652b:	80 ce 10             	or     $0x10,%dh
f010652e:	89 90 10 04 00 00    	mov    %edx,0x410(%eax)
    tipg->ipgr2 = 6;
f0106534:	c1 ea 10             	shr    $0x10,%edx
f0106537:	66 81 e2 0f c0       	and    $0xc00f,%dx
f010653c:	83 ca 60             	or     $0x60,%edx
f010653f:	66 89 90 12 04 00 00 	mov    %dx,0x412(%eax)

    if (status != 0x80080783)
        return -1;
    
    e1000_transmit_init();
    e1000_receive_init();
f0106546:	e8 8a fd ff ff       	call   f01062d5 <e1000_receive_init>

    return 0;
f010654b:	b8 00 00 00 00       	mov    $0x0,%eax
f0106550:	eb 0c                	jmp    f010655e <pci_e1000_attach+0x189>
pci_e1000_attach(struct pci_func *f)
{
    pci_func_enable(f);

    if (!f->reg_base[0])
		return -1;
f0106552:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0106557:	eb 05                	jmp    f010655e <pci_e1000_attach+0x189>

    // status offest is 8
    uint32_t status = *(uint32_t *)E1000_ADDR(8);

    if (status != 0x80080783)
        return -1;
f0106559:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    
    e1000_transmit_init();
    e1000_receive_init();

    return 0;
}
f010655e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106561:	5b                   	pop    %ebx
f0106562:	5e                   	pop    %esi
f0106563:	5d                   	pop    %ebp
f0106564:	c3                   	ret    

f0106565 <e1000_receive>:

int
e1000_receive(char *addr, uint32_t *len)
{
    static int32_t next = 0;
    if(!(receive_desc_array[next].status & E1000_RXD_STAT_DD)) {	//simply tell client to retry
f0106565:	a1 80 ce 2a f0       	mov    0xf02ace80,%eax
f010656a:	89 c2                	mov    %eax,%edx
f010656c:	c1 e2 04             	shl    $0x4,%edx
f010656f:	f6 82 2c e0 2e f0 01 	testb  $0x1,-0xfd11fd4(%edx)
f0106576:	0f 84 88 00 00 00    	je     f0106604 <e1000_receive+0x9f>
    ra[1] = rah;
}

int
e1000_receive(char *addr, uint32_t *len)
{
f010657c:	55                   	push   %ebp
f010657d:	89 e5                	mov    %esp,%ebp
f010657f:	83 ec 08             	sub    $0x8,%esp
    static int32_t next = 0;
    if(!(receive_desc_array[next].status & E1000_RXD_STAT_DD)) {	//simply tell client to retry
        return -2;
    }
    if(receive_desc_array[next].errors) {
f0106582:	89 c2                	mov    %eax,%edx
f0106584:	c1 e2 04             	shl    $0x4,%edx
f0106587:	80 ba 2d e0 2e f0 00 	cmpb   $0x0,-0xfd11fd3(%edx)
f010658e:	74 17                	je     f01065a7 <e1000_receive+0x42>
        cprintf("receive errors\n");
f0106590:	83 ec 0c             	sub    $0xc,%esp
f0106593:	68 1a 8d 10 f0       	push   $0xf0108d1a
f0106598:	e8 f4 d3 ff ff       	call   f0103991 <cprintf>
        return -2;
f010659d:	83 c4 10             	add    $0x10,%esp
f01065a0:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01065a5:	eb 63                	jmp    f010660a <e1000_receive+0xa5>
    }

    *len = receive_desc_array[next].length;
f01065a7:	89 c2                	mov    %eax,%edx
f01065a9:	c1 e2 04             	shl    $0x4,%edx
f01065ac:	0f b7 92 28 e0 2e f0 	movzwl -0xfd11fd8(%edx),%edx
f01065b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01065b6:	89 11                	mov    %edx,(%ecx)
    memcpy(addr, receive_buffer[next], *len);
f01065b8:	83 ec 04             	sub    $0x4,%esp
f01065bb:	52                   	push   %edx
f01065bc:	69 c0 f0 05 00 00    	imul   $0x5f0,%eax,%eax
f01065c2:	05 60 a6 2f f0       	add    $0xf02fa660,%eax
f01065c7:	50                   	push   %eax
f01065c8:	ff 75 08             	pushl  0x8(%ebp)
f01065cb:	e8 d4 f2 ff ff       	call   f01058a4 <memcpy>

    rdt->rdt = (rdt->rdt + 1) % 128;
f01065d0:	8b 15 60 9e 32 f0    	mov    0xf0329e60,%edx
f01065d6:	0f b7 02             	movzwl (%edx),%eax
f01065d9:	83 c0 01             	add    $0x1,%eax
f01065dc:	83 e0 7f             	and    $0x7f,%eax
f01065df:	66 89 02             	mov    %ax,(%edx)
    next = (next + 1) % 128;
f01065e2:	a1 80 ce 2a f0       	mov    0xf02ace80,%eax
f01065e7:	83 c0 01             	add    $0x1,%eax
f01065ea:	99                   	cltd   
f01065eb:	c1 ea 19             	shr    $0x19,%edx
f01065ee:	01 d0                	add    %edx,%eax
f01065f0:	83 e0 7f             	and    $0x7f,%eax
f01065f3:	29 d0                	sub    %edx,%eax
f01065f5:	a3 80 ce 2a f0       	mov    %eax,0xf02ace80
    return 0;
f01065fa:	83 c4 10             	add    $0x10,%esp
f01065fd:	b8 00 00 00 00       	mov    $0x0,%eax
f0106602:	eb 06                	jmp    f010660a <e1000_receive+0xa5>
int
e1000_receive(char *addr, uint32_t *len)
{
    static int32_t next = 0;
    if(!(receive_desc_array[next].status & E1000_RXD_STAT_DD)) {	//simply tell client to retry
        return -2;
f0106604:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0106609:	c3                   	ret    
    memcpy(addr, receive_buffer[next], *len);

    rdt->rdt = (rdt->rdt + 1) % 128;
    next = (next + 1) % 128;
    return 0;
f010660a:	c9                   	leave  
f010660b:	c3                   	ret    

f010660c <pci_attach_match>:
}

static int __attribute__((warn_unused_result))
pci_attach_match(uint32_t key1, uint32_t key2,
		 struct pci_driver *list, struct pci_func *pcif)
{
f010660c:	55                   	push   %ebp
f010660d:	89 e5                	mov    %esp,%ebp
f010660f:	57                   	push   %edi
f0106610:	56                   	push   %esi
f0106611:	53                   	push   %ebx
f0106612:	83 ec 0c             	sub    $0xc,%esp
f0106615:	8b 7d 08             	mov    0x8(%ebp),%edi
f0106618:	8b 45 10             	mov    0x10(%ebp),%eax
f010661b:	8d 58 08             	lea    0x8(%eax),%ebx
	uint32_t i;

	for (i = 0; list[i].attachfn; i++) {
f010661e:	eb 3a                	jmp    f010665a <pci_attach_match+0x4e>
		if (list[i].key1 == key1 && list[i].key2 == key2) {
f0106620:	39 7b f8             	cmp    %edi,-0x8(%ebx)
f0106623:	75 32                	jne    f0106657 <pci_attach_match+0x4b>
f0106625:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106628:	39 56 fc             	cmp    %edx,-0x4(%esi)
f010662b:	75 2a                	jne    f0106657 <pci_attach_match+0x4b>
			int r = list[i].attachfn(pcif);
f010662d:	83 ec 0c             	sub    $0xc,%esp
f0106630:	ff 75 14             	pushl  0x14(%ebp)
f0106633:	ff d0                	call   *%eax
			if (r > 0)
f0106635:	83 c4 10             	add    $0x10,%esp
f0106638:	85 c0                	test   %eax,%eax
f010663a:	7f 26                	jg     f0106662 <pci_attach_match+0x56>
				return r;
			if (r < 0)
f010663c:	85 c0                	test   %eax,%eax
f010663e:	79 17                	jns    f0106657 <pci_attach_match+0x4b>
				cprintf("pci_attach_match: attaching "
f0106640:	83 ec 0c             	sub    $0xc,%esp
f0106643:	50                   	push   %eax
f0106644:	ff 36                	pushl  (%esi)
f0106646:	ff 75 0c             	pushl  0xc(%ebp)
f0106649:	57                   	push   %edi
f010664a:	68 2c 8d 10 f0       	push   $0xf0108d2c
f010664f:	e8 3d d3 ff ff       	call   f0103991 <cprintf>
f0106654:	83 c4 20             	add    $0x20,%esp
f0106657:	83 c3 0c             	add    $0xc,%ebx
f010665a:	89 de                	mov    %ebx,%esi
pci_attach_match(uint32_t key1, uint32_t key2,
		 struct pci_driver *list, struct pci_func *pcif)
{
	uint32_t i;

	for (i = 0; list[i].attachfn; i++) {
f010665c:	8b 03                	mov    (%ebx),%eax
f010665e:	85 c0                	test   %eax,%eax
f0106660:	75 be                	jne    f0106620 <pci_attach_match+0x14>
					"%x.%x (%p): e\n",
					key1, key2, list[i].attachfn, r);
		}
	}
	return 0;
}
f0106662:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106665:	5b                   	pop    %ebx
f0106666:	5e                   	pop    %esi
f0106667:	5f                   	pop    %edi
f0106668:	5d                   	pop    %ebp
f0106669:	c3                   	ret    

f010666a <pci_conf1_set_addr>:
static void
pci_conf1_set_addr(uint32_t bus,
		   uint32_t dev,
		   uint32_t func,
		   uint32_t offset)
{
f010666a:	55                   	push   %ebp
f010666b:	89 e5                	mov    %esp,%ebp
f010666d:	53                   	push   %ebx
f010666e:	83 ec 04             	sub    $0x4,%esp
f0106671:	8b 5d 08             	mov    0x8(%ebp),%ebx
	assert(bus < 256);
f0106674:	3d ff 00 00 00       	cmp    $0xff,%eax
f0106679:	76 16                	jbe    f0106691 <pci_conf1_set_addr+0x27>
f010667b:	68 84 8e 10 f0       	push   $0xf0108e84
f0106680:	68 25 74 10 f0       	push   $0xf0107425
f0106685:	6a 2c                	push   $0x2c
f0106687:	68 8e 8e 10 f0       	push   $0xf0108e8e
f010668c:	e8 af 99 ff ff       	call   f0100040 <_panic>
	assert(dev < 32);
f0106691:	83 fa 1f             	cmp    $0x1f,%edx
f0106694:	76 16                	jbe    f01066ac <pci_conf1_set_addr+0x42>
f0106696:	68 99 8e 10 f0       	push   $0xf0108e99
f010669b:	68 25 74 10 f0       	push   $0xf0107425
f01066a0:	6a 2d                	push   $0x2d
f01066a2:	68 8e 8e 10 f0       	push   $0xf0108e8e
f01066a7:	e8 94 99 ff ff       	call   f0100040 <_panic>
	assert(func < 8);
f01066ac:	83 f9 07             	cmp    $0x7,%ecx
f01066af:	76 16                	jbe    f01066c7 <pci_conf1_set_addr+0x5d>
f01066b1:	68 a2 8e 10 f0       	push   $0xf0108ea2
f01066b6:	68 25 74 10 f0       	push   $0xf0107425
f01066bb:	6a 2e                	push   $0x2e
f01066bd:	68 8e 8e 10 f0       	push   $0xf0108e8e
f01066c2:	e8 79 99 ff ff       	call   f0100040 <_panic>
	assert(offset < 256);
f01066c7:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f01066cd:	76 16                	jbe    f01066e5 <pci_conf1_set_addr+0x7b>
f01066cf:	68 ab 8e 10 f0       	push   $0xf0108eab
f01066d4:	68 25 74 10 f0       	push   $0xf0107425
f01066d9:	6a 2f                	push   $0x2f
f01066db:	68 8e 8e 10 f0       	push   $0xf0108e8e
f01066e0:	e8 5b 99 ff ff       	call   f0100040 <_panic>
	assert((offset & 0x3) == 0);
f01066e5:	f6 c3 03             	test   $0x3,%bl
f01066e8:	74 16                	je     f0106700 <pci_conf1_set_addr+0x96>
f01066ea:	68 b8 8e 10 f0       	push   $0xf0108eb8
f01066ef:	68 25 74 10 f0       	push   $0xf0107425
f01066f4:	6a 30                	push   $0x30
f01066f6:	68 8e 8e 10 f0       	push   $0xf0108e8e
f01066fb:	e8 40 99 ff ff       	call   f0100040 <_panic>
}

static inline void
outl(int port, uint32_t data)
{
	asm volatile("outl %0,%w1" : : "a" (data), "d" (port));
f0106700:	c1 e1 08             	shl    $0x8,%ecx
f0106703:	81 cb 00 00 00 80    	or     $0x80000000,%ebx
f0106709:	09 cb                	or     %ecx,%ebx
f010670b:	c1 e2 0b             	shl    $0xb,%edx
f010670e:	09 d3                	or     %edx,%ebx
f0106710:	c1 e0 10             	shl    $0x10,%eax
f0106713:	09 d8                	or     %ebx,%eax
f0106715:	ba f8 0c 00 00       	mov    $0xcf8,%edx
f010671a:	ef                   	out    %eax,(%dx)

	uint32_t v = (1 << 31) |		// config-space
		(bus << 16) | (dev << 11) | (func << 8) | (offset);
	outl(pci_conf1_addr_ioport, v);
}
f010671b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010671e:	c9                   	leave  
f010671f:	c3                   	ret    

f0106720 <pci_conf_read>:

static uint32_t
pci_conf_read(struct pci_func *f, uint32_t off)
{
f0106720:	55                   	push   %ebp
f0106721:	89 e5                	mov    %esp,%ebp
f0106723:	53                   	push   %ebx
f0106724:	83 ec 10             	sub    $0x10,%esp
	pci_conf1_set_addr(f->bus->busno, f->dev, f->func, off);
f0106727:	8b 48 08             	mov    0x8(%eax),%ecx
f010672a:	8b 58 04             	mov    0x4(%eax),%ebx
f010672d:	8b 00                	mov    (%eax),%eax
f010672f:	8b 40 04             	mov    0x4(%eax),%eax
f0106732:	52                   	push   %edx
f0106733:	89 da                	mov    %ebx,%edx
f0106735:	e8 30 ff ff ff       	call   f010666a <pci_conf1_set_addr>

static inline uint32_t
inl(int port)
{
	uint32_t data;
	asm volatile("inl %w1,%0" : "=a" (data) : "d" (port));
f010673a:	ba fc 0c 00 00       	mov    $0xcfc,%edx
f010673f:	ed                   	in     (%dx),%eax
	return inl(pci_conf1_data_ioport);
}
f0106740:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0106743:	c9                   	leave  
f0106744:	c3                   	ret    

f0106745 <pci_scan_bus>:
		f->irq_line);
}

static int
pci_scan_bus(struct pci_bus *bus)
{
f0106745:	55                   	push   %ebp
f0106746:	89 e5                	mov    %esp,%ebp
f0106748:	57                   	push   %edi
f0106749:	56                   	push   %esi
f010674a:	53                   	push   %ebx
f010674b:	81 ec 00 01 00 00    	sub    $0x100,%esp
f0106751:	89 c3                	mov    %eax,%ebx
	int totaldev = 0;
	struct pci_func df;
	memset(&df, 0, sizeof(df));
f0106753:	6a 48                	push   $0x48
f0106755:	6a 00                	push   $0x0
f0106757:	8d 45 a0             	lea    -0x60(%ebp),%eax
f010675a:	50                   	push   %eax
f010675b:	e8 8f f0 ff ff       	call   f01057ef <memset>
	df.bus = bus;
f0106760:	89 5d a0             	mov    %ebx,-0x60(%ebp)

	for (df.dev = 0; df.dev < 32; df.dev++) {
f0106763:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f010676a:	83 c4 10             	add    $0x10,%esp
}

static int
pci_scan_bus(struct pci_bus *bus)
{
	int totaldev = 0;
f010676d:	c7 85 00 ff ff ff 00 	movl   $0x0,-0x100(%ebp)
f0106774:	00 00 00 
	struct pci_func df;
	memset(&df, 0, sizeof(df));
	df.bus = bus;

	for (df.dev = 0; df.dev < 32; df.dev++) {
		uint32_t bhlc = pci_conf_read(&df, PCI_BHLC_REG);
f0106777:	ba 0c 00 00 00       	mov    $0xc,%edx
f010677c:	8d 45 a0             	lea    -0x60(%ebp),%eax
f010677f:	e8 9c ff ff ff       	call   f0106720 <pci_conf_read>
		if (PCI_HDRTYPE_TYPE(bhlc) > 1)	    // Unsupported or no device
f0106784:	89 c2                	mov    %eax,%edx
f0106786:	c1 ea 10             	shr    $0x10,%edx
f0106789:	83 e2 7f             	and    $0x7f,%edx
f010678c:	83 fa 01             	cmp    $0x1,%edx
f010678f:	0f 87 4b 01 00 00    	ja     f01068e0 <pci_scan_bus+0x19b>
			continue;

		totaldev++;
f0106795:	83 85 00 ff ff ff 01 	addl   $0x1,-0x100(%ebp)

		struct pci_func f = df;
f010679c:	8d bd 10 ff ff ff    	lea    -0xf0(%ebp),%edi
f01067a2:	8d 75 a0             	lea    -0x60(%ebp),%esi
f01067a5:	b9 12 00 00 00       	mov    $0x12,%ecx
f01067aa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f01067ac:	c7 85 18 ff ff ff 00 	movl   $0x0,-0xe8(%ebp)
f01067b3:	00 00 00 
f01067b6:	25 00 00 80 00       	and    $0x800000,%eax
f01067bb:	83 f8 01             	cmp    $0x1,%eax
f01067be:	19 c0                	sbb    %eax,%eax
f01067c0:	83 e0 f9             	and    $0xfffffff9,%eax
f01067c3:	83 c0 08             	add    $0x8,%eax
f01067c6:	89 85 04 ff ff ff    	mov    %eax,-0xfc(%ebp)

			af.dev_id = pci_conf_read(&f, PCI_ID_REG);
			if (PCI_VENDOR(af.dev_id) == 0xffff)
				continue;

			uint32_t intr = pci_conf_read(&af, PCI_INTERRUPT_REG);
f01067cc:	8d 9d 58 ff ff ff    	lea    -0xa8(%ebp),%ebx
			continue;

		totaldev++;

		struct pci_func f = df;
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f01067d2:	e9 f7 00 00 00       	jmp    f01068ce <pci_scan_bus+0x189>
		     f.func++) {
			struct pci_func af = f;
f01067d7:	8d bd 58 ff ff ff    	lea    -0xa8(%ebp),%edi
f01067dd:	8d b5 10 ff ff ff    	lea    -0xf0(%ebp),%esi
f01067e3:	b9 12 00 00 00       	mov    $0x12,%ecx
f01067e8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

			af.dev_id = pci_conf_read(&f, PCI_ID_REG);
f01067ea:	ba 00 00 00 00       	mov    $0x0,%edx
f01067ef:	8d 85 10 ff ff ff    	lea    -0xf0(%ebp),%eax
f01067f5:	e8 26 ff ff ff       	call   f0106720 <pci_conf_read>
f01067fa:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
			if (PCI_VENDOR(af.dev_id) == 0xffff)
f0106800:	66 83 f8 ff          	cmp    $0xffff,%ax
f0106804:	0f 84 bd 00 00 00    	je     f01068c7 <pci_scan_bus+0x182>
				continue;

			uint32_t intr = pci_conf_read(&af, PCI_INTERRUPT_REG);
f010680a:	ba 3c 00 00 00       	mov    $0x3c,%edx
f010680f:	89 d8                	mov    %ebx,%eax
f0106811:	e8 0a ff ff ff       	call   f0106720 <pci_conf_read>
			af.irq_line = PCI_INTERRUPT_LINE(intr);
f0106816:	88 45 9c             	mov    %al,-0x64(%ebp)

			af.dev_class = pci_conf_read(&af, PCI_CLASS_REG);
f0106819:	ba 08 00 00 00       	mov    $0x8,%edx
f010681e:	89 d8                	mov    %ebx,%eax
f0106820:	e8 fb fe ff ff       	call   f0106720 <pci_conf_read>
f0106825:	89 85 68 ff ff ff    	mov    %eax,-0x98(%ebp)

static void
pci_print_func(struct pci_func *f)
{
	const char *class = pci_class[0];
	if (PCI_CLASS(f->dev_class) < ARRAY_SIZE(pci_class))
f010682b:	89 c1                	mov    %eax,%ecx
f010682d:	c1 e9 18             	shr    $0x18,%ecx
};

static void
pci_print_func(struct pci_func *f)
{
	const char *class = pci_class[0];
f0106830:	be cc 8e 10 f0       	mov    $0xf0108ecc,%esi
	if (PCI_CLASS(f->dev_class) < ARRAY_SIZE(pci_class))
f0106835:	83 f9 06             	cmp    $0x6,%ecx
f0106838:	77 07                	ja     f0106841 <pci_scan_bus+0xfc>
		class = pci_class[PCI_CLASS(f->dev_class)];
f010683a:	8b 34 8d 40 8f 10 f0 	mov    -0xfef70c0(,%ecx,4),%esi

	cprintf("PCI: %02x:%02x.%d: %04x:%04x: class: %x.%x (%s) irq: %d\n",
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
f0106841:	8b 95 64 ff ff ff    	mov    -0x9c(%ebp),%edx
{
	const char *class = pci_class[0];
	if (PCI_CLASS(f->dev_class) < ARRAY_SIZE(pci_class))
		class = pci_class[PCI_CLASS(f->dev_class)];

	cprintf("PCI: %02x:%02x.%d: %04x:%04x: class: %x.%x (%s) irq: %d\n",
f0106847:	83 ec 08             	sub    $0x8,%esp
f010684a:	0f b6 7d 9c          	movzbl -0x64(%ebp),%edi
f010684e:	57                   	push   %edi
f010684f:	56                   	push   %esi
f0106850:	c1 e8 10             	shr    $0x10,%eax
f0106853:	0f b6 c0             	movzbl %al,%eax
f0106856:	50                   	push   %eax
f0106857:	51                   	push   %ecx
f0106858:	89 d0                	mov    %edx,%eax
f010685a:	c1 e8 10             	shr    $0x10,%eax
f010685d:	50                   	push   %eax
f010685e:	0f b7 d2             	movzwl %dx,%edx
f0106861:	52                   	push   %edx
f0106862:	ff b5 60 ff ff ff    	pushl  -0xa0(%ebp)
f0106868:	ff b5 5c ff ff ff    	pushl  -0xa4(%ebp)
f010686e:	8b 85 58 ff ff ff    	mov    -0xa8(%ebp),%eax
f0106874:	ff 70 04             	pushl  0x4(%eax)
f0106877:	68 58 8d 10 f0       	push   $0xf0108d58
f010687c:	e8 10 d1 ff ff       	call   f0103991 <cprintf>
static int
pci_attach(struct pci_func *f)
{
	return
		pci_attach_match(PCI_CLASS(f->dev_class),
				 PCI_SUBCLASS(f->dev_class),
f0106881:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax

static int
pci_attach(struct pci_func *f)
{
	return
		pci_attach_match(PCI_CLASS(f->dev_class),
f0106887:	83 c4 30             	add    $0x30,%esp
f010688a:	53                   	push   %ebx
f010688b:	68 24 44 12 f0       	push   $0xf0124424
f0106890:	89 c2                	mov    %eax,%edx
f0106892:	c1 ea 10             	shr    $0x10,%edx
f0106895:	0f b6 d2             	movzbl %dl,%edx
f0106898:	52                   	push   %edx
f0106899:	c1 e8 18             	shr    $0x18,%eax
f010689c:	50                   	push   %eax
f010689d:	e8 6a fd ff ff       	call   f010660c <pci_attach_match>
				 PCI_SUBCLASS(f->dev_class),
				 &pci_attach_class[0], f) ||
f01068a2:	83 c4 10             	add    $0x10,%esp
f01068a5:	85 c0                	test   %eax,%eax
f01068a7:	75 1e                	jne    f01068c7 <pci_scan_bus+0x182>
		pci_attach_match(PCI_VENDOR(f->dev_id),
				 PCI_PRODUCT(f->dev_id),
f01068a9:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
{
	return
		pci_attach_match(PCI_CLASS(f->dev_class),
				 PCI_SUBCLASS(f->dev_class),
				 &pci_attach_class[0], f) ||
		pci_attach_match(PCI_VENDOR(f->dev_id),
f01068af:	53                   	push   %ebx
f01068b0:	68 0c 44 12 f0       	push   $0xf012440c
f01068b5:	89 c2                	mov    %eax,%edx
f01068b7:	c1 ea 10             	shr    $0x10,%edx
f01068ba:	52                   	push   %edx
f01068bb:	0f b7 c0             	movzwl %ax,%eax
f01068be:	50                   	push   %eax
f01068bf:	e8 48 fd ff ff       	call   f010660c <pci_attach_match>
f01068c4:	83 c4 10             	add    $0x10,%esp

		totaldev++;

		struct pci_func f = df;
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
		     f.func++) {
f01068c7:	83 85 18 ff ff ff 01 	addl   $0x1,-0xe8(%ebp)
			continue;

		totaldev++;

		struct pci_func f = df;
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f01068ce:	8b 85 04 ff ff ff    	mov    -0xfc(%ebp),%eax
f01068d4:	3b 85 18 ff ff ff    	cmp    -0xe8(%ebp),%eax
f01068da:	0f 87 f7 fe ff ff    	ja     f01067d7 <pci_scan_bus+0x92>
	int totaldev = 0;
	struct pci_func df;
	memset(&df, 0, sizeof(df));
	df.bus = bus;

	for (df.dev = 0; df.dev < 32; df.dev++) {
f01068e0:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f01068e3:	83 c0 01             	add    $0x1,%eax
f01068e6:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f01068e9:	83 f8 1f             	cmp    $0x1f,%eax
f01068ec:	0f 86 85 fe ff ff    	jbe    f0106777 <pci_scan_bus+0x32>
			pci_attach(&af);
		}
	}

	return totaldev;
}
f01068f2:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
f01068f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01068fb:	5b                   	pop    %ebx
f01068fc:	5e                   	pop    %esi
f01068fd:	5f                   	pop    %edi
f01068fe:	5d                   	pop    %ebp
f01068ff:	c3                   	ret    

f0106900 <pci_bridge_attach>:

static int
pci_bridge_attach(struct pci_func *pcif)
{
f0106900:	55                   	push   %ebp
f0106901:	89 e5                	mov    %esp,%ebp
f0106903:	57                   	push   %edi
f0106904:	56                   	push   %esi
f0106905:	53                   	push   %ebx
f0106906:	83 ec 1c             	sub    $0x1c,%esp
f0106909:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32_t ioreg  = pci_conf_read(pcif, PCI_BRIDGE_STATIO_REG);
f010690c:	ba 1c 00 00 00       	mov    $0x1c,%edx
f0106911:	89 d8                	mov    %ebx,%eax
f0106913:	e8 08 fe ff ff       	call   f0106720 <pci_conf_read>
f0106918:	89 c7                	mov    %eax,%edi
	uint32_t busreg = pci_conf_read(pcif, PCI_BRIDGE_BUS_REG);
f010691a:	ba 18 00 00 00       	mov    $0x18,%edx
f010691f:	89 d8                	mov    %ebx,%eax
f0106921:	e8 fa fd ff ff       	call   f0106720 <pci_conf_read>

	if (PCI_BRIDGE_IO_32BITS(ioreg)) {
f0106926:	83 e7 0f             	and    $0xf,%edi
f0106929:	83 ff 01             	cmp    $0x1,%edi
f010692c:	75 1f                	jne    f010694d <pci_bridge_attach+0x4d>
		cprintf("PCI: %02x:%02x.%d: 32-bit bridge IO not supported.\n",
f010692e:	ff 73 08             	pushl  0x8(%ebx)
f0106931:	ff 73 04             	pushl  0x4(%ebx)
f0106934:	8b 03                	mov    (%ebx),%eax
f0106936:	ff 70 04             	pushl  0x4(%eax)
f0106939:	68 94 8d 10 f0       	push   $0xf0108d94
f010693e:	e8 4e d0 ff ff       	call   f0103991 <cprintf>
			pcif->bus->busno, pcif->dev, pcif->func);
		return 0;
f0106943:	83 c4 10             	add    $0x10,%esp
f0106946:	b8 00 00 00 00       	mov    $0x0,%eax
f010694b:	eb 4e                	jmp    f010699b <pci_bridge_attach+0x9b>
f010694d:	89 c6                	mov    %eax,%esi
	}

	struct pci_bus nbus;
	memset(&nbus, 0, sizeof(nbus));
f010694f:	83 ec 04             	sub    $0x4,%esp
f0106952:	6a 08                	push   $0x8
f0106954:	6a 00                	push   $0x0
f0106956:	8d 7d e0             	lea    -0x20(%ebp),%edi
f0106959:	57                   	push   %edi
f010695a:	e8 90 ee ff ff       	call   f01057ef <memset>
	nbus.parent_bridge = pcif;
f010695f:	89 5d e0             	mov    %ebx,-0x20(%ebp)
	nbus.busno = (busreg >> PCI_BRIDGE_BUS_SECONDARY_SHIFT) & 0xff;
f0106962:	89 f0                	mov    %esi,%eax
f0106964:	0f b6 c4             	movzbl %ah,%eax
f0106967:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	if (pci_show_devs)
		cprintf("PCI: %02x:%02x.%d: bridge to PCI bus %d--%d\n",
f010696a:	83 c4 08             	add    $0x8,%esp
f010696d:	89 f2                	mov    %esi,%edx
f010696f:	c1 ea 10             	shr    $0x10,%edx
f0106972:	0f b6 f2             	movzbl %dl,%esi
f0106975:	56                   	push   %esi
f0106976:	50                   	push   %eax
f0106977:	ff 73 08             	pushl  0x8(%ebx)
f010697a:	ff 73 04             	pushl  0x4(%ebx)
f010697d:	8b 03                	mov    (%ebx),%eax
f010697f:	ff 70 04             	pushl  0x4(%eax)
f0106982:	68 c8 8d 10 f0       	push   $0xf0108dc8
f0106987:	e8 05 d0 ff ff       	call   f0103991 <cprintf>
			pcif->bus->busno, pcif->dev, pcif->func,
			nbus.busno,
			(busreg >> PCI_BRIDGE_BUS_SUBORDINATE_SHIFT) & 0xff);

	pci_scan_bus(&nbus);
f010698c:	83 c4 20             	add    $0x20,%esp
f010698f:	89 f8                	mov    %edi,%eax
f0106991:	e8 af fd ff ff       	call   f0106745 <pci_scan_bus>
	return 1;
f0106996:	b8 01 00 00 00       	mov    $0x1,%eax
}
f010699b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010699e:	5b                   	pop    %ebx
f010699f:	5e                   	pop    %esi
f01069a0:	5f                   	pop    %edi
f01069a1:	5d                   	pop    %ebp
f01069a2:	c3                   	ret    

f01069a3 <pci_conf_write>:
	return inl(pci_conf1_data_ioport);
}

static void
pci_conf_write(struct pci_func *f, uint32_t off, uint32_t v)
{
f01069a3:	55                   	push   %ebp
f01069a4:	89 e5                	mov    %esp,%ebp
f01069a6:	56                   	push   %esi
f01069a7:	53                   	push   %ebx
f01069a8:	89 cb                	mov    %ecx,%ebx
	pci_conf1_set_addr(f->bus->busno, f->dev, f->func, off);
f01069aa:	8b 48 08             	mov    0x8(%eax),%ecx
f01069ad:	8b 70 04             	mov    0x4(%eax),%esi
f01069b0:	8b 00                	mov    (%eax),%eax
f01069b2:	8b 40 04             	mov    0x4(%eax),%eax
f01069b5:	83 ec 0c             	sub    $0xc,%esp
f01069b8:	52                   	push   %edx
f01069b9:	89 f2                	mov    %esi,%edx
f01069bb:	e8 aa fc ff ff       	call   f010666a <pci_conf1_set_addr>
}

static inline void
outl(int port, uint32_t data)
{
	asm volatile("outl %0,%w1" : : "a" (data), "d" (port));
f01069c0:	ba fc 0c 00 00       	mov    $0xcfc,%edx
f01069c5:	89 d8                	mov    %ebx,%eax
f01069c7:	ef                   	out    %eax,(%dx)
	outl(pci_conf1_data_ioport, v);
}
f01069c8:	83 c4 10             	add    $0x10,%esp
f01069cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01069ce:	5b                   	pop    %ebx
f01069cf:	5e                   	pop    %esi
f01069d0:	5d                   	pop    %ebp
f01069d1:	c3                   	ret    

f01069d2 <pci_func_enable>:

// External PCI subsystem interface

void
pci_func_enable(struct pci_func *f)
{
f01069d2:	55                   	push   %ebp
f01069d3:	89 e5                	mov    %esp,%ebp
f01069d5:	57                   	push   %edi
f01069d6:	56                   	push   %esi
f01069d7:	53                   	push   %ebx
f01069d8:	83 ec 1c             	sub    $0x1c,%esp
f01069db:	8b 7d 08             	mov    0x8(%ebp),%edi
	pci_conf_write(f, PCI_COMMAND_STATUS_REG,
f01069de:	b9 07 00 00 00       	mov    $0x7,%ecx
f01069e3:	ba 04 00 00 00       	mov    $0x4,%edx
f01069e8:	89 f8                	mov    %edi,%eax
f01069ea:	e8 b4 ff ff ff       	call   f01069a3 <pci_conf_write>
		       PCI_COMMAND_MEM_ENABLE |
		       PCI_COMMAND_MASTER_ENABLE);

	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
f01069ef:	be 10 00 00 00       	mov    $0x10,%esi
	     bar += bar_width)
	{
		uint32_t oldv = pci_conf_read(f, bar);
f01069f4:	89 f2                	mov    %esi,%edx
f01069f6:	89 f8                	mov    %edi,%eax
f01069f8:	e8 23 fd ff ff       	call   f0106720 <pci_conf_read>
f01069fd:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		bar_width = 4;
		pci_conf_write(f, bar, 0xffffffff);
f0106a00:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
f0106a05:	89 f2                	mov    %esi,%edx
f0106a07:	89 f8                	mov    %edi,%eax
f0106a09:	e8 95 ff ff ff       	call   f01069a3 <pci_conf_write>
		uint32_t rv = pci_conf_read(f, bar);
f0106a0e:	89 f2                	mov    %esi,%edx
f0106a10:	89 f8                	mov    %edi,%eax
f0106a12:	e8 09 fd ff ff       	call   f0106720 <pci_conf_read>
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
	     bar += bar_width)
	{
		uint32_t oldv = pci_conf_read(f, bar);

		bar_width = 4;
f0106a17:	bb 04 00 00 00       	mov    $0x4,%ebx
		pci_conf_write(f, bar, 0xffffffff);
		uint32_t rv = pci_conf_read(f, bar);

		if (rv == 0)
f0106a1c:	85 c0                	test   %eax,%eax
f0106a1e:	0f 84 a6 00 00 00    	je     f0106aca <pci_func_enable+0xf8>
			continue;

		int regnum = PCI_MAPREG_NUM(bar);
f0106a24:	8d 56 f0             	lea    -0x10(%esi),%edx
f0106a27:	c1 ea 02             	shr    $0x2,%edx
f0106a2a:	89 55 e0             	mov    %edx,-0x20(%ebp)
		uint32_t base, size;
		if (PCI_MAPREG_TYPE(rv) == PCI_MAPREG_TYPE_MEM) {
f0106a2d:	a8 01                	test   $0x1,%al
f0106a2f:	75 2c                	jne    f0106a5d <pci_func_enable+0x8b>
			if (PCI_MAPREG_MEM_TYPE(rv) == PCI_MAPREG_MEM_TYPE_64BIT)
f0106a31:	89 c2                	mov    %eax,%edx
f0106a33:	83 e2 06             	and    $0x6,%edx
				bar_width = 8;
f0106a36:	83 fa 04             	cmp    $0x4,%edx
f0106a39:	0f 94 c3             	sete   %bl
f0106a3c:	0f b6 db             	movzbl %bl,%ebx
f0106a3f:	8d 1c 9d 04 00 00 00 	lea    0x4(,%ebx,4),%ebx

			size = PCI_MAPREG_MEM_SIZE(rv);
f0106a46:	83 e0 f0             	and    $0xfffffff0,%eax
f0106a49:	89 c2                	mov    %eax,%edx
f0106a4b:	f7 da                	neg    %edx
f0106a4d:	21 c2                	and    %eax,%edx
f0106a4f:	89 55 d8             	mov    %edx,-0x28(%ebp)
			base = PCI_MAPREG_MEM_ADDR(oldv);
f0106a52:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106a55:	83 e0 f0             	and    $0xfffffff0,%eax
f0106a58:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0106a5b:	eb 1a                	jmp    f0106a77 <pci_func_enable+0xa5>
			if (pci_show_addrs)
				cprintf("  mem region %d: %d bytes at 0x%x\n",
					regnum, size, base);
		} else {
			size = PCI_MAPREG_IO_SIZE(rv);
f0106a5d:	83 e0 fc             	and    $0xfffffffc,%eax
f0106a60:	89 c2                	mov    %eax,%edx
f0106a62:	f7 da                	neg    %edx
f0106a64:	21 c2                	and    %eax,%edx
f0106a66:	89 55 d8             	mov    %edx,-0x28(%ebp)
			base = PCI_MAPREG_IO_ADDR(oldv);
f0106a69:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106a6c:	83 e0 fc             	and    $0xfffffffc,%eax
f0106a6f:	89 45 dc             	mov    %eax,-0x24(%ebp)
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
	     bar += bar_width)
	{
		uint32_t oldv = pci_conf_read(f, bar);

		bar_width = 4;
f0106a72:	bb 04 00 00 00       	mov    $0x4,%ebx
			if (pci_show_addrs)
				cprintf("  io region %d: %d bytes at 0x%x\n",
					regnum, size, base);
		}

		pci_conf_write(f, bar, oldv);
f0106a77:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0106a7a:	89 f2                	mov    %esi,%edx
f0106a7c:	89 f8                	mov    %edi,%eax
f0106a7e:	e8 20 ff ff ff       	call   f01069a3 <pci_conf_write>
f0106a83:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106a86:	8d 04 87             	lea    (%edi,%eax,4),%eax
		f->reg_base[regnum] = base;
f0106a89:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0106a8c:	89 50 14             	mov    %edx,0x14(%eax)
		f->reg_size[regnum] = size;
f0106a8f:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0106a92:	89 48 2c             	mov    %ecx,0x2c(%eax)

		if (size && !base)
f0106a95:	85 c9                	test   %ecx,%ecx
f0106a97:	74 31                	je     f0106aca <pci_func_enable+0xf8>
f0106a99:	85 d2                	test   %edx,%edx
f0106a9b:	75 2d                	jne    f0106aca <pci_func_enable+0xf8>
			cprintf("PCI device %02x:%02x.%d (%04x:%04x) "
				"may be misconfigured: "
				"region %d: base 0x%x, size %d\n",
				f->bus->busno, f->dev, f->func,
				PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
f0106a9d:	8b 47 0c             	mov    0xc(%edi),%eax
		pci_conf_write(f, bar, oldv);
		f->reg_base[regnum] = base;
		f->reg_size[regnum] = size;

		if (size && !base)
			cprintf("PCI device %02x:%02x.%d (%04x:%04x) "
f0106aa0:	83 ec 0c             	sub    $0xc,%esp
f0106aa3:	51                   	push   %ecx
f0106aa4:	52                   	push   %edx
f0106aa5:	ff 75 e0             	pushl  -0x20(%ebp)
f0106aa8:	89 c2                	mov    %eax,%edx
f0106aaa:	c1 ea 10             	shr    $0x10,%edx
f0106aad:	52                   	push   %edx
f0106aae:	0f b7 c0             	movzwl %ax,%eax
f0106ab1:	50                   	push   %eax
f0106ab2:	ff 77 08             	pushl  0x8(%edi)
f0106ab5:	ff 77 04             	pushl  0x4(%edi)
f0106ab8:	8b 07                	mov    (%edi),%eax
f0106aba:	ff 70 04             	pushl  0x4(%eax)
f0106abd:	68 f8 8d 10 f0       	push   $0xf0108df8
f0106ac2:	e8 ca ce ff ff       	call   f0103991 <cprintf>
f0106ac7:	83 c4 30             	add    $0x30,%esp
		       PCI_COMMAND_MASTER_ENABLE);

	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
	     bar += bar_width)
f0106aca:	01 de                	add    %ebx,%esi
		       PCI_COMMAND_MEM_ENABLE |
		       PCI_COMMAND_MASTER_ENABLE);

	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
f0106acc:	83 fe 27             	cmp    $0x27,%esi
f0106acf:	0f 86 1f ff ff ff    	jbe    f01069f4 <pci_func_enable+0x22>
				regnum, base, size);
	}

	cprintf("PCI function %02x:%02x.%d (%04x:%04x) enabled\n",
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id));
f0106ad5:	8b 47 0c             	mov    0xc(%edi),%eax
				f->bus->busno, f->dev, f->func,
				PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
				regnum, base, size);
	}

	cprintf("PCI function %02x:%02x.%d (%04x:%04x) enabled\n",
f0106ad8:	83 ec 08             	sub    $0x8,%esp
f0106adb:	89 c2                	mov    %eax,%edx
f0106add:	c1 ea 10             	shr    $0x10,%edx
f0106ae0:	52                   	push   %edx
f0106ae1:	0f b7 c0             	movzwl %ax,%eax
f0106ae4:	50                   	push   %eax
f0106ae5:	ff 77 08             	pushl  0x8(%edi)
f0106ae8:	ff 77 04             	pushl  0x4(%edi)
f0106aeb:	8b 07                	mov    (%edi),%eax
f0106aed:	ff 70 04             	pushl  0x4(%eax)
f0106af0:	68 54 8e 10 f0       	push   $0xf0108e54
f0106af5:	e8 97 ce ff ff       	call   f0103991 <cprintf>
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id));
}
f0106afa:	83 c4 20             	add    $0x20,%esp
f0106afd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106b00:	5b                   	pop    %ebx
f0106b01:	5e                   	pop    %esi
f0106b02:	5f                   	pop    %edi
f0106b03:	5d                   	pop    %ebp
f0106b04:	c3                   	ret    

f0106b05 <pci_init>:

int
pci_init(void)
{
f0106b05:	55                   	push   %ebp
f0106b06:	89 e5                	mov    %esp,%ebp
f0106b08:	83 ec 0c             	sub    $0xc,%esp
	static struct pci_bus root_bus;
	memset(&root_bus, 0, sizeof(root_bus));
f0106b0b:	6a 08                	push   $0x8
f0106b0d:	6a 00                	push   $0x0
f0106b0f:	68 84 ce 2a f0       	push   $0xf02ace84
f0106b14:	e8 d6 ec ff ff       	call   f01057ef <memset>

	return pci_scan_bus(&root_bus);
f0106b19:	b8 84 ce 2a f0       	mov    $0xf02ace84,%eax
f0106b1e:	e8 22 fc ff ff       	call   f0106745 <pci_scan_bus>
}
f0106b23:	c9                   	leave  
f0106b24:	c3                   	ret    

f0106b25 <time_init>:

static unsigned int ticks;

void
time_init(void)
{
f0106b25:	55                   	push   %ebp
f0106b26:	89 e5                	mov    %esp,%ebp
	ticks = 0;
f0106b28:	c7 05 8c ce 2a f0 00 	movl   $0x0,0xf02ace8c
f0106b2f:	00 00 00 
}
f0106b32:	5d                   	pop    %ebp
f0106b33:	c3                   	ret    

f0106b34 <time_tick>:
// This should be called once per timer interrupt.  A timer interrupt
// fires every 10 ms.
void
time_tick(void)
{
	ticks++;
f0106b34:	a1 8c ce 2a f0       	mov    0xf02ace8c,%eax
f0106b39:	83 c0 01             	add    $0x1,%eax
f0106b3c:	a3 8c ce 2a f0       	mov    %eax,0xf02ace8c
	if (ticks * 10 < ticks)
f0106b41:	8d 14 80             	lea    (%eax,%eax,4),%edx
f0106b44:	01 d2                	add    %edx,%edx
f0106b46:	39 d0                	cmp    %edx,%eax
f0106b48:	76 17                	jbe    f0106b61 <time_tick+0x2d>

// This should be called once per timer interrupt.  A timer interrupt
// fires every 10 ms.
void
time_tick(void)
{
f0106b4a:	55                   	push   %ebp
f0106b4b:	89 e5                	mov    %esp,%ebp
f0106b4d:	83 ec 0c             	sub    $0xc,%esp
	ticks++;
	if (ticks * 10 < ticks)
		panic("time_tick: time overflowed");
f0106b50:	68 5c 8f 10 f0       	push   $0xf0108f5c
f0106b55:	6a 13                	push   $0x13
f0106b57:	68 77 8f 10 f0       	push   $0xf0108f77
f0106b5c:	e8 df 94 ff ff       	call   f0100040 <_panic>
f0106b61:	f3 c3                	repz ret 

f0106b63 <time_msec>:
}

unsigned int
time_msec(void)
{
f0106b63:	55                   	push   %ebp
f0106b64:	89 e5                	mov    %esp,%ebp
	return ticks * 10;
f0106b66:	a1 8c ce 2a f0       	mov    0xf02ace8c,%eax
f0106b6b:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0106b6e:	01 c0                	add    %eax,%eax
}
f0106b70:	5d                   	pop    %ebp
f0106b71:	c3                   	ret    
f0106b72:	66 90                	xchg   %ax,%ax
f0106b74:	66 90                	xchg   %ax,%ax
f0106b76:	66 90                	xchg   %ax,%ax
f0106b78:	66 90                	xchg   %ax,%ax
f0106b7a:	66 90                	xchg   %ax,%ax
f0106b7c:	66 90                	xchg   %ax,%ax
f0106b7e:	66 90                	xchg   %ax,%ax

f0106b80 <__udivdi3>:
f0106b80:	55                   	push   %ebp
f0106b81:	57                   	push   %edi
f0106b82:	56                   	push   %esi
f0106b83:	53                   	push   %ebx
f0106b84:	83 ec 1c             	sub    $0x1c,%esp
f0106b87:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f0106b8b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f0106b8f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0106b93:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106b97:	85 f6                	test   %esi,%esi
f0106b99:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106b9d:	89 ca                	mov    %ecx,%edx
f0106b9f:	89 f8                	mov    %edi,%eax
f0106ba1:	75 3d                	jne    f0106be0 <__udivdi3+0x60>
f0106ba3:	39 cf                	cmp    %ecx,%edi
f0106ba5:	0f 87 c5 00 00 00    	ja     f0106c70 <__udivdi3+0xf0>
f0106bab:	85 ff                	test   %edi,%edi
f0106bad:	89 fd                	mov    %edi,%ebp
f0106baf:	75 0b                	jne    f0106bbc <__udivdi3+0x3c>
f0106bb1:	b8 01 00 00 00       	mov    $0x1,%eax
f0106bb6:	31 d2                	xor    %edx,%edx
f0106bb8:	f7 f7                	div    %edi
f0106bba:	89 c5                	mov    %eax,%ebp
f0106bbc:	89 c8                	mov    %ecx,%eax
f0106bbe:	31 d2                	xor    %edx,%edx
f0106bc0:	f7 f5                	div    %ebp
f0106bc2:	89 c1                	mov    %eax,%ecx
f0106bc4:	89 d8                	mov    %ebx,%eax
f0106bc6:	89 cf                	mov    %ecx,%edi
f0106bc8:	f7 f5                	div    %ebp
f0106bca:	89 c3                	mov    %eax,%ebx
f0106bcc:	89 d8                	mov    %ebx,%eax
f0106bce:	89 fa                	mov    %edi,%edx
f0106bd0:	83 c4 1c             	add    $0x1c,%esp
f0106bd3:	5b                   	pop    %ebx
f0106bd4:	5e                   	pop    %esi
f0106bd5:	5f                   	pop    %edi
f0106bd6:	5d                   	pop    %ebp
f0106bd7:	c3                   	ret    
f0106bd8:	90                   	nop
f0106bd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106be0:	39 ce                	cmp    %ecx,%esi
f0106be2:	77 74                	ja     f0106c58 <__udivdi3+0xd8>
f0106be4:	0f bd fe             	bsr    %esi,%edi
f0106be7:	83 f7 1f             	xor    $0x1f,%edi
f0106bea:	0f 84 98 00 00 00    	je     f0106c88 <__udivdi3+0x108>
f0106bf0:	bb 20 00 00 00       	mov    $0x20,%ebx
f0106bf5:	89 f9                	mov    %edi,%ecx
f0106bf7:	89 c5                	mov    %eax,%ebp
f0106bf9:	29 fb                	sub    %edi,%ebx
f0106bfb:	d3 e6                	shl    %cl,%esi
f0106bfd:	89 d9                	mov    %ebx,%ecx
f0106bff:	d3 ed                	shr    %cl,%ebp
f0106c01:	89 f9                	mov    %edi,%ecx
f0106c03:	d3 e0                	shl    %cl,%eax
f0106c05:	09 ee                	or     %ebp,%esi
f0106c07:	89 d9                	mov    %ebx,%ecx
f0106c09:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106c0d:	89 d5                	mov    %edx,%ebp
f0106c0f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106c13:	d3 ed                	shr    %cl,%ebp
f0106c15:	89 f9                	mov    %edi,%ecx
f0106c17:	d3 e2                	shl    %cl,%edx
f0106c19:	89 d9                	mov    %ebx,%ecx
f0106c1b:	d3 e8                	shr    %cl,%eax
f0106c1d:	09 c2                	or     %eax,%edx
f0106c1f:	89 d0                	mov    %edx,%eax
f0106c21:	89 ea                	mov    %ebp,%edx
f0106c23:	f7 f6                	div    %esi
f0106c25:	89 d5                	mov    %edx,%ebp
f0106c27:	89 c3                	mov    %eax,%ebx
f0106c29:	f7 64 24 0c          	mull   0xc(%esp)
f0106c2d:	39 d5                	cmp    %edx,%ebp
f0106c2f:	72 10                	jb     f0106c41 <__udivdi3+0xc1>
f0106c31:	8b 74 24 08          	mov    0x8(%esp),%esi
f0106c35:	89 f9                	mov    %edi,%ecx
f0106c37:	d3 e6                	shl    %cl,%esi
f0106c39:	39 c6                	cmp    %eax,%esi
f0106c3b:	73 07                	jae    f0106c44 <__udivdi3+0xc4>
f0106c3d:	39 d5                	cmp    %edx,%ebp
f0106c3f:	75 03                	jne    f0106c44 <__udivdi3+0xc4>
f0106c41:	83 eb 01             	sub    $0x1,%ebx
f0106c44:	31 ff                	xor    %edi,%edi
f0106c46:	89 d8                	mov    %ebx,%eax
f0106c48:	89 fa                	mov    %edi,%edx
f0106c4a:	83 c4 1c             	add    $0x1c,%esp
f0106c4d:	5b                   	pop    %ebx
f0106c4e:	5e                   	pop    %esi
f0106c4f:	5f                   	pop    %edi
f0106c50:	5d                   	pop    %ebp
f0106c51:	c3                   	ret    
f0106c52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106c58:	31 ff                	xor    %edi,%edi
f0106c5a:	31 db                	xor    %ebx,%ebx
f0106c5c:	89 d8                	mov    %ebx,%eax
f0106c5e:	89 fa                	mov    %edi,%edx
f0106c60:	83 c4 1c             	add    $0x1c,%esp
f0106c63:	5b                   	pop    %ebx
f0106c64:	5e                   	pop    %esi
f0106c65:	5f                   	pop    %edi
f0106c66:	5d                   	pop    %ebp
f0106c67:	c3                   	ret    
f0106c68:	90                   	nop
f0106c69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106c70:	89 d8                	mov    %ebx,%eax
f0106c72:	f7 f7                	div    %edi
f0106c74:	31 ff                	xor    %edi,%edi
f0106c76:	89 c3                	mov    %eax,%ebx
f0106c78:	89 d8                	mov    %ebx,%eax
f0106c7a:	89 fa                	mov    %edi,%edx
f0106c7c:	83 c4 1c             	add    $0x1c,%esp
f0106c7f:	5b                   	pop    %ebx
f0106c80:	5e                   	pop    %esi
f0106c81:	5f                   	pop    %edi
f0106c82:	5d                   	pop    %ebp
f0106c83:	c3                   	ret    
f0106c84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106c88:	39 ce                	cmp    %ecx,%esi
f0106c8a:	72 0c                	jb     f0106c98 <__udivdi3+0x118>
f0106c8c:	31 db                	xor    %ebx,%ebx
f0106c8e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0106c92:	0f 87 34 ff ff ff    	ja     f0106bcc <__udivdi3+0x4c>
f0106c98:	bb 01 00 00 00       	mov    $0x1,%ebx
f0106c9d:	e9 2a ff ff ff       	jmp    f0106bcc <__udivdi3+0x4c>
f0106ca2:	66 90                	xchg   %ax,%ax
f0106ca4:	66 90                	xchg   %ax,%ax
f0106ca6:	66 90                	xchg   %ax,%ax
f0106ca8:	66 90                	xchg   %ax,%ax
f0106caa:	66 90                	xchg   %ax,%ax
f0106cac:	66 90                	xchg   %ax,%ax
f0106cae:	66 90                	xchg   %ax,%ax

f0106cb0 <__umoddi3>:
f0106cb0:	55                   	push   %ebp
f0106cb1:	57                   	push   %edi
f0106cb2:	56                   	push   %esi
f0106cb3:	53                   	push   %ebx
f0106cb4:	83 ec 1c             	sub    $0x1c,%esp
f0106cb7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0106cbb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f0106cbf:	8b 74 24 34          	mov    0x34(%esp),%esi
f0106cc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106cc7:	85 d2                	test   %edx,%edx
f0106cc9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0106ccd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106cd1:	89 f3                	mov    %esi,%ebx
f0106cd3:	89 3c 24             	mov    %edi,(%esp)
f0106cd6:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106cda:	75 1c                	jne    f0106cf8 <__umoddi3+0x48>
f0106cdc:	39 f7                	cmp    %esi,%edi
f0106cde:	76 50                	jbe    f0106d30 <__umoddi3+0x80>
f0106ce0:	89 c8                	mov    %ecx,%eax
f0106ce2:	89 f2                	mov    %esi,%edx
f0106ce4:	f7 f7                	div    %edi
f0106ce6:	89 d0                	mov    %edx,%eax
f0106ce8:	31 d2                	xor    %edx,%edx
f0106cea:	83 c4 1c             	add    $0x1c,%esp
f0106ced:	5b                   	pop    %ebx
f0106cee:	5e                   	pop    %esi
f0106cef:	5f                   	pop    %edi
f0106cf0:	5d                   	pop    %ebp
f0106cf1:	c3                   	ret    
f0106cf2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106cf8:	39 f2                	cmp    %esi,%edx
f0106cfa:	89 d0                	mov    %edx,%eax
f0106cfc:	77 52                	ja     f0106d50 <__umoddi3+0xa0>
f0106cfe:	0f bd ea             	bsr    %edx,%ebp
f0106d01:	83 f5 1f             	xor    $0x1f,%ebp
f0106d04:	75 5a                	jne    f0106d60 <__umoddi3+0xb0>
f0106d06:	3b 54 24 04          	cmp    0x4(%esp),%edx
f0106d0a:	0f 82 e0 00 00 00    	jb     f0106df0 <__umoddi3+0x140>
f0106d10:	39 0c 24             	cmp    %ecx,(%esp)
f0106d13:	0f 86 d7 00 00 00    	jbe    f0106df0 <__umoddi3+0x140>
f0106d19:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106d1d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106d21:	83 c4 1c             	add    $0x1c,%esp
f0106d24:	5b                   	pop    %ebx
f0106d25:	5e                   	pop    %esi
f0106d26:	5f                   	pop    %edi
f0106d27:	5d                   	pop    %ebp
f0106d28:	c3                   	ret    
f0106d29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106d30:	85 ff                	test   %edi,%edi
f0106d32:	89 fd                	mov    %edi,%ebp
f0106d34:	75 0b                	jne    f0106d41 <__umoddi3+0x91>
f0106d36:	b8 01 00 00 00       	mov    $0x1,%eax
f0106d3b:	31 d2                	xor    %edx,%edx
f0106d3d:	f7 f7                	div    %edi
f0106d3f:	89 c5                	mov    %eax,%ebp
f0106d41:	89 f0                	mov    %esi,%eax
f0106d43:	31 d2                	xor    %edx,%edx
f0106d45:	f7 f5                	div    %ebp
f0106d47:	89 c8                	mov    %ecx,%eax
f0106d49:	f7 f5                	div    %ebp
f0106d4b:	89 d0                	mov    %edx,%eax
f0106d4d:	eb 99                	jmp    f0106ce8 <__umoddi3+0x38>
f0106d4f:	90                   	nop
f0106d50:	89 c8                	mov    %ecx,%eax
f0106d52:	89 f2                	mov    %esi,%edx
f0106d54:	83 c4 1c             	add    $0x1c,%esp
f0106d57:	5b                   	pop    %ebx
f0106d58:	5e                   	pop    %esi
f0106d59:	5f                   	pop    %edi
f0106d5a:	5d                   	pop    %ebp
f0106d5b:	c3                   	ret    
f0106d5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106d60:	8b 34 24             	mov    (%esp),%esi
f0106d63:	bf 20 00 00 00       	mov    $0x20,%edi
f0106d68:	89 e9                	mov    %ebp,%ecx
f0106d6a:	29 ef                	sub    %ebp,%edi
f0106d6c:	d3 e0                	shl    %cl,%eax
f0106d6e:	89 f9                	mov    %edi,%ecx
f0106d70:	89 f2                	mov    %esi,%edx
f0106d72:	d3 ea                	shr    %cl,%edx
f0106d74:	89 e9                	mov    %ebp,%ecx
f0106d76:	09 c2                	or     %eax,%edx
f0106d78:	89 d8                	mov    %ebx,%eax
f0106d7a:	89 14 24             	mov    %edx,(%esp)
f0106d7d:	89 f2                	mov    %esi,%edx
f0106d7f:	d3 e2                	shl    %cl,%edx
f0106d81:	89 f9                	mov    %edi,%ecx
f0106d83:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106d87:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0106d8b:	d3 e8                	shr    %cl,%eax
f0106d8d:	89 e9                	mov    %ebp,%ecx
f0106d8f:	89 c6                	mov    %eax,%esi
f0106d91:	d3 e3                	shl    %cl,%ebx
f0106d93:	89 f9                	mov    %edi,%ecx
f0106d95:	89 d0                	mov    %edx,%eax
f0106d97:	d3 e8                	shr    %cl,%eax
f0106d99:	89 e9                	mov    %ebp,%ecx
f0106d9b:	09 d8                	or     %ebx,%eax
f0106d9d:	89 d3                	mov    %edx,%ebx
f0106d9f:	89 f2                	mov    %esi,%edx
f0106da1:	f7 34 24             	divl   (%esp)
f0106da4:	89 d6                	mov    %edx,%esi
f0106da6:	d3 e3                	shl    %cl,%ebx
f0106da8:	f7 64 24 04          	mull   0x4(%esp)
f0106dac:	39 d6                	cmp    %edx,%esi
f0106dae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106db2:	89 d1                	mov    %edx,%ecx
f0106db4:	89 c3                	mov    %eax,%ebx
f0106db6:	72 08                	jb     f0106dc0 <__umoddi3+0x110>
f0106db8:	75 11                	jne    f0106dcb <__umoddi3+0x11b>
f0106dba:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0106dbe:	73 0b                	jae    f0106dcb <__umoddi3+0x11b>
f0106dc0:	2b 44 24 04          	sub    0x4(%esp),%eax
f0106dc4:	1b 14 24             	sbb    (%esp),%edx
f0106dc7:	89 d1                	mov    %edx,%ecx
f0106dc9:	89 c3                	mov    %eax,%ebx
f0106dcb:	8b 54 24 08          	mov    0x8(%esp),%edx
f0106dcf:	29 da                	sub    %ebx,%edx
f0106dd1:	19 ce                	sbb    %ecx,%esi
f0106dd3:	89 f9                	mov    %edi,%ecx
f0106dd5:	89 f0                	mov    %esi,%eax
f0106dd7:	d3 e0                	shl    %cl,%eax
f0106dd9:	89 e9                	mov    %ebp,%ecx
f0106ddb:	d3 ea                	shr    %cl,%edx
f0106ddd:	89 e9                	mov    %ebp,%ecx
f0106ddf:	d3 ee                	shr    %cl,%esi
f0106de1:	09 d0                	or     %edx,%eax
f0106de3:	89 f2                	mov    %esi,%edx
f0106de5:	83 c4 1c             	add    $0x1c,%esp
f0106de8:	5b                   	pop    %ebx
f0106de9:	5e                   	pop    %esi
f0106dea:	5f                   	pop    %edi
f0106deb:	5d                   	pop    %ebp
f0106dec:	c3                   	ret    
f0106ded:	8d 76 00             	lea    0x0(%esi),%esi
f0106df0:	29 f9                	sub    %edi,%ecx
f0106df2:	19 d6                	sbb    %edx,%esi
f0106df4:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106df8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106dfc:	e9 18 ff ff ff       	jmp    f0106d19 <__umoddi3+0x69>
