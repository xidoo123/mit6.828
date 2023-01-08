
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
f010006d:	e8 10 39 00 00       	call   f0103982 <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 e0 38 00 00       	call   f010395c <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 99 72 10 f0 	movl   $0xf0107299,(%esp)
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
f01000ae:	68 ec 69 10 f0       	push   $0xf01069ec
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
f01000c7:	e8 b8 59 00 00       	call   f0105a84 <mp_init>
	lapic_init();
f01000cc:	e8 d8 5c 00 00       	call   f0105da9 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000d1:	e8 bd 37 00 00       	call   f0103893 <pic_init>

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
f0100126:	e8 90 56 00 00       	call   f01057bb <memmove>
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
f010019c:	e8 d5 31 00 00       	call   f0103376 <env_create>
	ENV_CREATE(net_ns, ENV_TYPE_NS);
#endif

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01001a1:	83 c4 08             	add    $0x8,%esp
f01001a4:	6a 00                	push   $0x0
f01001a6:	68 d8 af 20 f0       	push   $0xf020afd8
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
f01001c0:	a1 a4 9e 2a f0       	mov    0xf02a9ea4,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001c5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001ca:	77 12                	ja     f01001de <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001cc:	50                   	push   %eax
f01001cd:	68 c8 69 10 f0       	push   $0xf01069c8
f01001d2:	6a 77                	push   $0x77
f01001d4:	68 07 6a 10 f0       	push   $0xf0106a07
f01001d9:	e8 62 fe ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01001de:	05 00 00 00 10       	add    $0x10000000,%eax
f01001e3:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001e6:	e8 a3 5b 00 00       	call   f0105d8e <cpunum>
f01001eb:	83 ec 08             	sub    $0x8,%esp
f01001ee:	50                   	push   %eax
f01001ef:	68 13 6a 10 f0       	push   $0xf0106a13
f01001f4:	e8 89 37 00 00       	call   f0103982 <cprintf>

	lapic_init();
f01001f9:	e8 ab 5b 00 00       	call   f0105da9 <lapic_init>
	env_init_percpu();
f01001fe:	e8 b0 2f 00 00       	call   f01031b3 <env_init_percpu>
	trap_init_percpu();
f0100203:	e8 8e 37 00 00       	call   f0103996 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100208:	e8 81 5b 00 00       	call   f0105d8e <cpunum>
f010020d:	6b d0 74             	imul   $0x74,%eax,%edx
f0100210:	81 c2 20 a0 2a f0    	add    $0xf02aa020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0100216:	b8 01 00 00 00       	mov    $0x1,%eax
f010021b:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010021f:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f0100226:	e8 d1 5d 00 00       	call   f0105ffc <spin_lock>
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
f0100240:	68 29 6a 10 f0       	push   $0xf0106a29
f0100245:	e8 38 37 00 00       	call   f0103982 <cprintf>
	vcprintf(fmt, ap);
f010024a:	83 c4 08             	add    $0x8,%esp
f010024d:	53                   	push   %ebx
f010024e:	ff 75 10             	pushl  0x10(%ebp)
f0100251:	e8 06 37 00 00       	call   f010395c <vcprintf>
	cprintf("\n");
f0100256:	c7 04 24 99 72 10 f0 	movl   $0xf0107299,(%esp)
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
f0100298:	8b 0d 24 92 2a f0    	mov    0xf02a9224,%ecx
f010029e:	8d 51 01             	lea    0x1(%ecx),%edx
f01002a1:	89 15 24 92 2a f0    	mov    %edx,0xf02a9224
f01002a7:	88 81 20 90 2a f0    	mov    %al,-0xfd56fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002ad:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01002b3:	75 0a                	jne    f01002bf <cons_intr+0x36>
			cons.wpos = 0;
f01002b5:	c7 05 24 92 2a f0 00 	movl   $0x0,0xf02a9224
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
f01002ee:	83 0d 00 90 2a f0 40 	orl    $0x40,0xf02a9000
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
f0100306:	8b 0d 00 90 2a f0    	mov    0xf02a9000,%ecx
f010030c:	89 cb                	mov    %ecx,%ebx
f010030e:	83 e3 40             	and    $0x40,%ebx
f0100311:	83 e0 7f             	and    $0x7f,%eax
f0100314:	85 db                	test   %ebx,%ebx
f0100316:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100319:	0f b6 d2             	movzbl %dl,%edx
f010031c:	0f b6 82 a0 6b 10 f0 	movzbl -0xfef9460(%edx),%eax
f0100323:	83 c8 40             	or     $0x40,%eax
f0100326:	0f b6 c0             	movzbl %al,%eax
f0100329:	f7 d0                	not    %eax
f010032b:	21 c8                	and    %ecx,%eax
f010032d:	a3 00 90 2a f0       	mov    %eax,0xf02a9000
		return 0;
f0100332:	b8 00 00 00 00       	mov    $0x0,%eax
f0100337:	e9 a4 00 00 00       	jmp    f01003e0 <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f010033c:	8b 0d 00 90 2a f0    	mov    0xf02a9000,%ecx
f0100342:	f6 c1 40             	test   $0x40,%cl
f0100345:	74 0e                	je     f0100355 <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100347:	83 c8 80             	or     $0xffffff80,%eax
f010034a:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010034c:	83 e1 bf             	and    $0xffffffbf,%ecx
f010034f:	89 0d 00 90 2a f0    	mov    %ecx,0xf02a9000
	}

	shift |= shiftcode[data];
f0100355:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100358:	0f b6 82 a0 6b 10 f0 	movzbl -0xfef9460(%edx),%eax
f010035f:	0b 05 00 90 2a f0    	or     0xf02a9000,%eax
f0100365:	0f b6 8a a0 6a 10 f0 	movzbl -0xfef9560(%edx),%ecx
f010036c:	31 c8                	xor    %ecx,%eax
f010036e:	a3 00 90 2a f0       	mov    %eax,0xf02a9000

	c = charcode[shift & (CTL | SHIFT)][data];
f0100373:	89 c1                	mov    %eax,%ecx
f0100375:	83 e1 03             	and    $0x3,%ecx
f0100378:	8b 0c 8d 80 6a 10 f0 	mov    -0xfef9580(,%ecx,4),%ecx
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
f01003b6:	68 43 6a 10 f0       	push   $0xf0106a43
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
f01004a2:	0f b7 05 28 92 2a f0 	movzwl 0xf02a9228,%eax
f01004a9:	66 85 c0             	test   %ax,%ax
f01004ac:	0f 84 e6 00 00 00    	je     f0100598 <cons_putc+0x1b3>
			crt_pos--;
f01004b2:	83 e8 01             	sub    $0x1,%eax
f01004b5:	66 a3 28 92 2a f0    	mov    %ax,0xf02a9228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004bb:	0f b7 c0             	movzwl %ax,%eax
f01004be:	66 81 e7 00 ff       	and    $0xff00,%di
f01004c3:	83 cf 20             	or     $0x20,%edi
f01004c6:	8b 15 2c 92 2a f0    	mov    0xf02a922c,%edx
f01004cc:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004d0:	eb 78                	jmp    f010054a <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004d2:	66 83 05 28 92 2a f0 	addw   $0x50,0xf02a9228
f01004d9:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004da:	0f b7 05 28 92 2a f0 	movzwl 0xf02a9228,%eax
f01004e1:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004e7:	c1 e8 16             	shr    $0x16,%eax
f01004ea:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004ed:	c1 e0 04             	shl    $0x4,%eax
f01004f0:	66 a3 28 92 2a f0    	mov    %ax,0xf02a9228
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
f010052c:	0f b7 05 28 92 2a f0 	movzwl 0xf02a9228,%eax
f0100533:	8d 50 01             	lea    0x1(%eax),%edx
f0100536:	66 89 15 28 92 2a f0 	mov    %dx,0xf02a9228
f010053d:	0f b7 c0             	movzwl %ax,%eax
f0100540:	8b 15 2c 92 2a f0    	mov    0xf02a922c,%edx
f0100546:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f010054a:	66 81 3d 28 92 2a f0 	cmpw   $0x7cf,0xf02a9228
f0100551:	cf 07 
f0100553:	76 43                	jbe    f0100598 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100555:	a1 2c 92 2a f0       	mov    0xf02a922c,%eax
f010055a:	83 ec 04             	sub    $0x4,%esp
f010055d:	68 00 0f 00 00       	push   $0xf00
f0100562:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100568:	52                   	push   %edx
f0100569:	50                   	push   %eax
f010056a:	e8 4c 52 00 00       	call   f01057bb <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010056f:	8b 15 2c 92 2a f0    	mov    0xf02a922c,%edx
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
f0100590:	66 83 2d 28 92 2a f0 	subw   $0x50,0xf02a9228
f0100597:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100598:	8b 0d 30 92 2a f0    	mov    0xf02a9230,%ecx
f010059e:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005a3:	89 ca                	mov    %ecx,%edx
f01005a5:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01005a6:	0f b7 1d 28 92 2a f0 	movzwl 0xf02a9228,%ebx
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
f01005ce:	80 3d 34 92 2a f0 00 	cmpb   $0x0,0xf02a9234
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
f010060c:	a1 20 92 2a f0       	mov    0xf02a9220,%eax
f0100611:	3b 05 24 92 2a f0    	cmp    0xf02a9224,%eax
f0100617:	74 26                	je     f010063f <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100619:	8d 50 01             	lea    0x1(%eax),%edx
f010061c:	89 15 20 92 2a f0    	mov    %edx,0xf02a9220
f0100622:	0f b6 88 20 90 2a f0 	movzbl -0xfd56fe0(%eax),%ecx
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
f0100633:	c7 05 20 92 2a f0 00 	movl   $0x0,0xf02a9220
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
f010066c:	c7 05 30 92 2a f0 b4 	movl   $0x3b4,0xf02a9230
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
f0100684:	c7 05 30 92 2a f0 d4 	movl   $0x3d4,0xf02a9230
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
f0100693:	8b 3d 30 92 2a f0    	mov    0xf02a9230,%edi
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
f01006b8:	89 35 2c 92 2a f0    	mov    %esi,0xf02a922c
	crt_pos = pos;
f01006be:	0f b6 c0             	movzbl %al,%eax
f01006c1:	09 c8                	or     %ecx,%eax
f01006c3:	66 a3 28 92 2a f0    	mov    %ax,0xf02a9228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006c9:	e8 1c ff ff ff       	call   f01005ea <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006ce:	83 ec 0c             	sub    $0xc,%esp
f01006d1:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
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
f0100741:	0f 95 05 34 92 2a f0 	setne  0xf02a9234
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
f0100756:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f010075d:	25 ef ff 00 00       	and    $0xffef,%eax
f0100762:	50                   	push   %eax
f0100763:	e8 b3 30 00 00       	call   f010381b <irq_setmask_8259A>
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100768:	83 c4 10             	add    $0x10,%esp
f010076b:	80 3d 34 92 2a f0 00 	cmpb   $0x0,0xf02a9234
f0100772:	75 10                	jne    f0100784 <cons_init+0x13e>
		cprintf("Serial port does not exist!\n");
f0100774:	83 ec 0c             	sub    $0xc,%esp
f0100777:	68 4f 6a 10 f0       	push   $0xf0106a4f
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
f01007bd:	68 a0 6c 10 f0       	push   $0xf0106ca0
f01007c2:	68 be 6c 10 f0       	push   $0xf0106cbe
f01007c7:	68 c3 6c 10 f0       	push   $0xf0106cc3
f01007cc:	e8 b1 31 00 00       	call   f0103982 <cprintf>
f01007d1:	83 c4 0c             	add    $0xc,%esp
f01007d4:	68 7c 6d 10 f0       	push   $0xf0106d7c
f01007d9:	68 cc 6c 10 f0       	push   $0xf0106ccc
f01007de:	68 c3 6c 10 f0       	push   $0xf0106cc3
f01007e3:	e8 9a 31 00 00       	call   f0103982 <cprintf>
f01007e8:	83 c4 0c             	add    $0xc,%esp
f01007eb:	68 d5 6c 10 f0       	push   $0xf0106cd5
f01007f0:	68 f3 6c 10 f0       	push   $0xf0106cf3
f01007f5:	68 c3 6c 10 f0       	push   $0xf0106cc3
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
f010080c:	68 fd 6c 10 f0       	push   $0xf0106cfd
f0100811:	e8 6c 31 00 00       	call   f0103982 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100816:	83 c4 08             	add    $0x8,%esp
f0100819:	68 0c 00 10 00       	push   $0x10000c
f010081e:	68 a4 6d 10 f0       	push   $0xf0106da4
f0100823:	e8 5a 31 00 00       	call   f0103982 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100828:	83 c4 0c             	add    $0xc,%esp
f010082b:	68 0c 00 10 00       	push   $0x10000c
f0100830:	68 0c 00 10 f0       	push   $0xf010000c
f0100835:	68 cc 6d 10 f0       	push   $0xf0106dcc
f010083a:	e8 43 31 00 00       	call   f0103982 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010083f:	83 c4 0c             	add    $0xc,%esp
f0100842:	68 71 69 10 00       	push   $0x106971
f0100847:	68 71 69 10 f0       	push   $0xf0106971
f010084c:	68 f0 6d 10 f0       	push   $0xf0106df0
f0100851:	e8 2c 31 00 00       	call   f0103982 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100856:	83 c4 0c             	add    $0xc,%esp
f0100859:	68 00 90 2a 00       	push   $0x2a9000
f010085e:	68 00 90 2a f0       	push   $0xf02a9000
f0100863:	68 14 6e 10 f0       	push   $0xf0106e14
f0100868:	e8 15 31 00 00       	call   f0103982 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010086d:	83 c4 0c             	add    $0xc,%esp
f0100870:	68 08 b0 2e 00       	push   $0x2eb008
f0100875:	68 08 b0 2e f0       	push   $0xf02eb008
f010087a:	68 38 6e 10 f0       	push   $0xf0106e38
f010087f:	e8 fe 30 00 00       	call   f0103982 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100884:	b8 07 b4 2e f0       	mov    $0xf02eb407,%eax
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
f01008a5:	68 5c 6e 10 f0       	push   $0xf0106e5c
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
f01008e4:	68 16 6d 10 f0       	push   $0xf0106d16
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
f0100916:	e8 c1 43 00 00       	call   f0104cdc <debuginfo_eip>

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
f0100972:	68 88 6e 10 f0       	push   $0xf0106e88
f0100977:	e8 06 30 00 00       	call   f0103982 <cprintf>
		cprintf("         %s:%d: %s+%d\n", context.eip_file, context.eip_line, function_name, _eip - context.eip_fn_addr);
f010097c:	83 c4 14             	add    $0x14,%esp
f010097f:	2b 75 cc             	sub    -0x34(%ebp),%esi
f0100982:	56                   	push   %esi
f0100983:	8d 45 8a             	lea    -0x76(%ebp),%eax
f0100986:	50                   	push   %eax
f0100987:	ff 75 c0             	pushl  -0x40(%ebp)
f010098a:	ff 75 bc             	pushl  -0x44(%ebp)
f010098d:	68 28 6d 10 f0       	push   $0xf0106d28
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
f01009ba:	68 c0 6e 10 f0       	push   $0xf0106ec0
f01009bf:	e8 be 2f 00 00       	call   f0103982 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01009c4:	c7 04 24 e4 6e 10 f0 	movl   $0xf0106ee4,(%esp)
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
f01009ea:	68 3f 6d 10 f0       	push   $0xf0106d3f
f01009ef:	e8 0b 4b 00 00       	call   f01054ff <readline>
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
f0100a23:	68 43 6d 10 f0       	push   $0xf0106d43
f0100a28:	e8 04 4d 00 00       	call   f0105731 <strchr>
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
f0100a43:	68 48 6d 10 f0       	push   $0xf0106d48
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
f0100a6c:	68 43 6d 10 f0       	push   $0xf0106d43
f0100a71:	e8 bb 4c 00 00       	call   f0105731 <strchr>
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
f0100a9a:	ff 34 85 20 6f 10 f0 	pushl  -0xfef90e0(,%eax,4)
f0100aa1:	ff 75 a8             	pushl  -0x58(%ebp)
f0100aa4:	e8 2a 4c 00 00       	call   f01056d3 <strcmp>
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
f0100abe:	ff 14 85 28 6f 10 f0 	call   *-0xfef90d8(,%eax,4)
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
f0100adf:	68 65 6d 10 f0       	push   $0xf0106d65
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
f0100b22:	83 3d 38 92 2a f0 00 	cmpl   $0x0,0xf02a9238
f0100b29:	75 11                	jne    f0100b3c <boot_alloc+0x1a>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100b2b:	ba 07 c0 2e f0       	mov    $0xf02ec007,%edx
f0100b30:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b36:	89 15 38 92 2a f0    	mov    %edx,0xf02a9238
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

	if ((uint32_t)nextfree > 0xffffffff - n)
f0100b3c:	8b 15 38 92 2a f0    	mov    0xf02a9238,%edx
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
f0100b50:	68 44 6f 10 f0       	push   $0xf0106f44
f0100b55:	6a 70                	push   $0x70
f0100b57:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0100b5c:	e8 df f4 ff ff       	call   f0100040 <_panic>

	result = nextfree;
	nextfree = ROUNDUP(result + n , PGSIZE);
f0100b61:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100b68:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b6d:	a3 38 92 2a f0       	mov    %eax,0xf02a9238

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
f0100b8b:	3b 0d a0 9e 2a f0    	cmp    0xf02a9ea0,%ecx
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
f0100b9a:	68 a4 69 10 f0       	push   $0xf01069a4
f0100b9f:	68 40 04 00 00       	push   $0x440
f0100ba4:	68 5f 6f 10 f0       	push   $0xf0106f5f
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
f0100bf2:	68 cc 72 10 f0       	push   $0xf01072cc
f0100bf7:	68 71 03 00 00       	push   $0x371
f0100bfc:	68 5f 6f 10 f0       	push   $0xf0106f5f
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
f0100c14:	2b 15 a8 9e 2a f0    	sub    0xf02a9ea8,%edx
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
f0100c4a:	a3 40 92 2a f0       	mov    %eax,0xf02a9240
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
f0100c54:	8b 1d 40 92 2a f0    	mov    0xf02a9240,%ebx
f0100c5a:	eb 53                	jmp    f0100caf <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c5c:	89 d8                	mov    %ebx,%eax
f0100c5e:	2b 05 a8 9e 2a f0    	sub    0xf02a9ea8,%eax
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
f0100c78:	3b 15 a0 9e 2a f0    	cmp    0xf02a9ea0,%edx
f0100c7e:	72 12                	jb     f0100c92 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c80:	50                   	push   %eax
f0100c81:	68 a4 69 10 f0       	push   $0xf01069a4
f0100c86:	6a 58                	push   $0x58
f0100c88:	68 6b 6f 10 f0       	push   $0xf0106f6b
f0100c8d:	e8 ae f3 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100c92:	83 ec 04             	sub    $0x4,%esp
f0100c95:	68 80 00 00 00       	push   $0x80
f0100c9a:	68 97 00 00 00       	push   $0x97
f0100c9f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ca4:	50                   	push   %eax
f0100ca5:	e8 c4 4a 00 00       	call   f010576e <memset>
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
f0100cc0:	8b 15 40 92 2a f0    	mov    0xf02a9240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100cc6:	8b 0d a8 9e 2a f0    	mov    0xf02a9ea8,%ecx
		assert(pp < pages + npages);
f0100ccc:	a1 a0 9e 2a f0       	mov    0xf02a9ea0,%eax
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
f0100ceb:	68 79 6f 10 f0       	push   $0xf0106f79
f0100cf0:	68 85 6f 10 f0       	push   $0xf0106f85
f0100cf5:	68 8b 03 00 00       	push   $0x38b
f0100cfa:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0100cff:	e8 3c f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100d04:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100d07:	72 19                	jb     f0100d22 <check_page_free_list+0x149>
f0100d09:	68 9a 6f 10 f0       	push   $0xf0106f9a
f0100d0e:	68 85 6f 10 f0       	push   $0xf0106f85
f0100d13:	68 8c 03 00 00       	push   $0x38c
f0100d18:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0100d1d:	e8 1e f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d22:	89 d0                	mov    %edx,%eax
f0100d24:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100d27:	a8 07                	test   $0x7,%al
f0100d29:	74 19                	je     f0100d44 <check_page_free_list+0x16b>
f0100d2b:	68 f0 72 10 f0       	push   $0xf01072f0
f0100d30:	68 85 6f 10 f0       	push   $0xf0106f85
f0100d35:	68 8d 03 00 00       	push   $0x38d
f0100d3a:	68 5f 6f 10 f0       	push   $0xf0106f5f
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
f0100d4e:	68 ae 6f 10 f0       	push   $0xf0106fae
f0100d53:	68 85 6f 10 f0       	push   $0xf0106f85
f0100d58:	68 90 03 00 00       	push   $0x390
f0100d5d:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0100d62:	e8 d9 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d67:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d6c:	75 19                	jne    f0100d87 <check_page_free_list+0x1ae>
f0100d6e:	68 bf 6f 10 f0       	push   $0xf0106fbf
f0100d73:	68 85 6f 10 f0       	push   $0xf0106f85
f0100d78:	68 91 03 00 00       	push   $0x391
f0100d7d:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0100d82:	e8 b9 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d87:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d8c:	75 19                	jne    f0100da7 <check_page_free_list+0x1ce>
f0100d8e:	68 24 73 10 f0       	push   $0xf0107324
f0100d93:	68 85 6f 10 f0       	push   $0xf0106f85
f0100d98:	68 92 03 00 00       	push   $0x392
f0100d9d:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0100da2:	e8 99 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100da7:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100dac:	75 19                	jne    f0100dc7 <check_page_free_list+0x1ee>
f0100dae:	68 d8 6f 10 f0       	push   $0xf0106fd8
f0100db3:	68 85 6f 10 f0       	push   $0xf0106f85
f0100db8:	68 93 03 00 00       	push   $0x393
f0100dbd:	68 5f 6f 10 f0       	push   $0xf0106f5f
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
f0100ddd:	68 a4 69 10 f0       	push   $0xf01069a4
f0100de2:	6a 58                	push   $0x58
f0100de4:	68 6b 6f 10 f0       	push   $0xf0106f6b
f0100de9:	e8 52 f2 ff ff       	call   f0100040 <_panic>
f0100dee:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100df4:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100df7:	0f 86 b6 00 00 00    	jbe    f0100eb3 <check_page_free_list+0x2da>
f0100dfd:	68 48 73 10 f0       	push   $0xf0107348
f0100e02:	68 85 6f 10 f0       	push   $0xf0106f85
f0100e07:	68 94 03 00 00       	push   $0x394
f0100e0c:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0100e11:	e8 2a f2 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e16:	68 f2 6f 10 f0       	push   $0xf0106ff2
f0100e1b:	68 85 6f 10 f0       	push   $0xf0106f85
f0100e20:	68 96 03 00 00       	push   $0x396
f0100e25:	68 5f 6f 10 f0       	push   $0xf0106f5f
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
f0100e45:	68 0f 70 10 f0       	push   $0xf010700f
f0100e4a:	68 85 6f 10 f0       	push   $0xf0106f85
f0100e4f:	68 9e 03 00 00       	push   $0x39e
f0100e54:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0100e59:	e8 e2 f1 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100e5e:	85 db                	test   %ebx,%ebx
f0100e60:	7f 19                	jg     f0100e7b <check_page_free_list+0x2a2>
f0100e62:	68 21 70 10 f0       	push   $0xf0107021
f0100e67:	68 85 6f 10 f0       	push   $0xf0106f85
f0100e6c:	68 9f 03 00 00       	push   $0x39f
f0100e71:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0100e76:	e8 c5 f1 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100e7b:	83 ec 0c             	sub    $0xc,%esp
f0100e7e:	68 90 73 10 f0       	push   $0xf0107390
f0100e83:	e8 fa 2a 00 00       	call   f0103982 <cprintf>
}
f0100e88:	eb 49                	jmp    f0100ed3 <check_page_free_list+0x2fa>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100e8a:	a1 40 92 2a f0       	mov    0xf02a9240,%eax
f0100e8f:	85 c0                	test   %eax,%eax
f0100e91:	0f 85 6f fd ff ff    	jne    f0100c06 <check_page_free_list+0x2d>
f0100e97:	e9 53 fd ff ff       	jmp    f0100bef <check_page_free_list+0x16>
f0100e9c:	83 3d 40 92 2a f0 00 	cmpl   $0x0,0xf02a9240
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
f0100ee0:	a1 a8 9e 2a f0       	mov    0xf02a9ea8,%eax
f0100ee5:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	pages[0].pp_link = 0;
f0100eeb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	extern unsigned char mpentry_start[], mpentry_end[];
	uint32_t size = ROUNDUP(mpentry_end - mpentry_start, PGSIZE);
f0100ef1:	be e9 69 10 f0       	mov    $0xf01069e9,%esi
f0100ef6:	81 ee 70 59 10 f0    	sub    $0xf0105970,%esi
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
f0100f1f:	a1 a8 9e 2a f0       	mov    0xf02a9ea8,%eax
f0100f24:	8d 04 d8             	lea    (%eax,%ebx,8),%eax
f0100f27:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link = 0;
f0100f2d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			cprintf("[?] non-boot CPUs (APs)\n");
f0100f33:	83 ec 0c             	sub    $0xc,%esp
f0100f36:	68 32 70 10 f0       	push   $0xf0107032
f0100f3b:	e8 42 2a 00 00       	call   f0103982 <cprintf>
f0100f40:	83 c4 10             	add    $0x10,%esp
f0100f43:	eb 28                	jmp    f0100f6d <page_init+0x92>
		}
		else {
			pages[i].pp_ref = 0;
f0100f45:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100f4c:	89 c2                	mov    %eax,%edx
f0100f4e:	03 15 a8 9e 2a f0    	add    0xf02a9ea8,%edx
f0100f54:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
			pages[i].pp_link = page_free_list;
f0100f5a:	8b 0d 40 92 2a f0    	mov    0xf02a9240,%ecx
f0100f60:	89 0a                	mov    %ecx,(%edx)
			page_free_list = &pages[i];
f0100f62:	03 05 a8 9e 2a f0    	add    0xf02a9ea8,%eax
f0100f68:	a3 40 92 2a f0       	mov    %eax,0xf02a9240
	extern unsigned char mpentry_start[], mpentry_end[];
	uint32_t size = ROUNDUP(mpentry_end - mpentry_start, PGSIZE);
	// cprintf("[?] Init from 0x%x to 0x%x\n", PGSIZE, PGSIZE * npages_basemem);

	// 2)	[1-npages_basemem) free, except APs area (lab4)
	for (i = 1; i < npages_basemem; i++) {
f0100f6d:	83 c3 01             	add    $0x1,%ebx
f0100f70:	3b 1d 44 92 2a f0    	cmp    0xf02a9244,%ebx
f0100f76:	72 97                	jb     f0100f0f <page_init+0x34>
f0100f78:	8b 0d 40 92 2a f0    	mov    0xf02a9240,%ecx
f0100f7e:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100f85:	ba 00 00 00 00       	mov    $0x0,%edx
f0100f8a:	eb 23                	jmp    f0100faf <page_init+0xd4>
	}

	// [npages_basemem, IOPHYSMEM / PGSIZE) free
	// cprintf("[?] %d, %d, %d\n", npages_basemem, IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE);
	for (; i < IOPHYSMEM / PGSIZE; i++) {
		pages[i].pp_ref = 0;
f0100f8c:	89 c2                	mov    %eax,%edx
f0100f8e:	03 15 a8 9e 2a f0    	add    0xf02a9ea8,%edx
f0100f94:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f0100f9a:	89 0a                	mov    %ecx,(%edx)
		page_free_list = &pages[i];
f0100f9c:	89 c1                	mov    %eax,%ecx
f0100f9e:	03 0d a8 9e 2a f0    	add    0xf02a9ea8,%ecx
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
f0100fbb:	89 0d 40 92 2a f0    	mov    %ecx,0xf02a9240
f0100fc1:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100fc8:	eb 1a                	jmp    f0100fe4 <page_init+0x109>
		page_free_list = &pages[i];
	}

	// 3) [IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE) in use
	for (; i < EXTPHYSMEM / PGSIZE; i++) {
		pages[i].pp_ref = 1;
f0100fca:	89 c2                	mov    %eax,%edx
f0100fcc:	03 15 a8 9e 2a f0    	add    0xf02a9ea8,%edx
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
f0100ff7:	03 05 a8 9e 2a f0    	add    0xf02a9ea8,%eax
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
f0101021:	68 c8 69 10 f0       	push   $0xf01069c8
f0101026:	68 7d 01 00 00       	push   $0x17d
f010102b:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101030:	e8 0b f0 ff ff       	call   f0100040 <_panic>
f0101035:	05 00 00 00 10       	add    $0x10000000,%eax
f010103a:	c1 e8 0c             	shr    $0xc,%eax
f010103d:	39 c3                	cmp    %eax,%ebx
f010103f:	72 b4                	jb     f0100ff5 <page_init+0x11a>
f0101041:	8b 0d 40 92 2a f0    	mov    0xf02a9240,%ecx
f0101047:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f010104e:	ba 00 00 00 00       	mov    $0x0,%edx
f0101053:	eb 23                	jmp    f0101078 <page_init+0x19d>
		pages[i].pp_link = 0;
	}

	// [kernel end, npages) free
	for (; i < npages; i++) {
		pages[i].pp_ref = 0;
f0101055:	89 c2                	mov    %eax,%edx
f0101057:	03 15 a8 9e 2a f0    	add    0xf02a9ea8,%edx
f010105d:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f0101063:	89 0a                	mov    %ecx,(%edx)
		page_free_list = &pages[i];
f0101065:	89 c1                	mov    %eax,%ecx
f0101067:	03 0d a8 9e 2a f0    	add    0xf02a9ea8,%ecx
		pages[i].pp_ref = 1;
		pages[i].pp_link = 0;
	}

	// [kernel end, npages) free
	for (; i < npages; i++) {
f010106d:	83 c3 01             	add    $0x1,%ebx
f0101070:	83 c0 08             	add    $0x8,%eax
f0101073:	ba 01 00 00 00       	mov    $0x1,%edx
f0101078:	3b 1d a0 9e 2a f0    	cmp    0xf02a9ea0,%ebx
f010107e:	72 d5                	jb     f0101055 <page_init+0x17a>
f0101080:	84 d2                	test   %dl,%dl
f0101082:	74 06                	je     f010108a <page_init+0x1af>
f0101084:	89 0d 40 92 2a f0    	mov    %ecx,0xf02a9240
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
f0101096:	8b 1d 40 92 2a f0    	mov    0xf02a9240,%ebx
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
f01010b0:	2b 05 a8 9e 2a f0    	sub    0xf02a9ea8,%eax
f01010b6:	c1 f8 03             	sar    $0x3,%eax
f01010b9:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01010bc:	89 c2                	mov    %eax,%edx
f01010be:	c1 ea 0c             	shr    $0xc,%edx
f01010c1:	3b 15 a0 9e 2a f0    	cmp    0xf02a9ea0,%edx
f01010c7:	72 12                	jb     f01010db <page_alloc+0x4a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010c9:	50                   	push   %eax
f01010ca:	68 a4 69 10 f0       	push   $0xf01069a4
f01010cf:	6a 58                	push   $0x58
f01010d1:	68 6b 6f 10 f0       	push   $0xf0106f6b
f01010d6:	e8 65 ef ff ff       	call   f0100040 <_panic>
		// cprintf("[?] alloc zero, %x, %x\n", page_free_list, PADDR(page_free_list));
		// memset((char *)page2pa(page_free_list), 0, PGSIZE);
		memset(page2kva(page_free_list), 0, PGSIZE);
f01010db:	83 ec 04             	sub    $0x4,%esp
f01010de:	68 00 10 00 00       	push   $0x1000
f01010e3:	6a 00                	push   $0x0
f01010e5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01010ea:	50                   	push   %eax
f01010eb:	e8 7e 46 00 00       	call   f010576e <memset>
f01010f0:	83 c4 10             	add    $0x10,%esp
	}
	
	// update free list head
	page_free_list = last_free;
f01010f3:	89 35 40 92 2a f0    	mov    %esi,0xf02a9240

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
f0101117:	68 b4 73 10 f0       	push   $0xf01073b4
f010111c:	68 c1 01 00 00       	push   $0x1c1
f0101121:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101126:	e8 15 ef ff ff       	call   f0100040 <_panic>
	if (pp->pp_ref != 0)
f010112b:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101130:	74 17                	je     f0101149 <page_free+0x47>
		panic("page_free: other pointers still point to it, mind use-after-free!\n");
f0101132:	83 ec 04             	sub    $0x4,%esp
f0101135:	68 dc 73 10 f0       	push   $0xf01073dc
f010113a:	68 c3 01 00 00       	push   $0x1c3
f010113f:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101144:	e8 f7 ee ff ff       	call   f0100040 <_panic>

	pp->pp_link = page_free_list;
f0101149:	8b 15 40 92 2a f0    	mov    0xf02a9240,%edx
f010114f:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101151:	a3 40 92 2a f0       	mov    %eax,0xf02a9240

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
f010119a:	68 4b 70 10 f0       	push   $0xf010704b
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
f01011bc:	68 56 70 10 f0       	push   $0xf0107056
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
f01011e7:	2b 15 a8 9e 2a f0    	sub    0xf02a9ea8,%edx
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
f0101216:	68 62 70 10 f0       	push   $0xf0107062
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
f010122f:	3b 15 a0 9e 2a f0    	cmp    0xf02a9ea0,%edx
f0101235:	72 48                	jb     f010127f <pgdir_walk+0x100>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101237:	50                   	push   %eax
f0101238:	68 a4 69 10 f0       	push   $0xf01069a4
f010123d:	68 1c 02 00 00       	push   $0x21c
f0101242:	68 5f 6f 10 f0       	push   $0xf0106f5f
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
f0101291:	68 74 70 10 f0       	push   $0xf0107074
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
f01012b4:	3b 15 a0 9e 2a f0    	cmp    0xf02a9ea0,%edx
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
f01012db:	68 20 74 10 f0       	push   $0xf0107420
f01012e0:	e8 9d 26 00 00       	call   f0103982 <cprintf>
	
	// Fill this function in	
	if (size % PGSIZE != 0)
f01012e5:	83 c4 10             	add    $0x10,%esp
f01012e8:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f01012ee:	74 17                	je     f0101307 <boot_map_region+0x3e>
		panic("boot_map_region: size is not a multiple of PGSIZE\n");
f01012f0:	83 ec 04             	sub    $0x4,%esp
f01012f3:	68 44 74 10 f0       	push   $0xf0107444
f01012f8:	68 37 02 00 00       	push   $0x237
f01012fd:	68 5f 6f 10 f0       	push   $0xf0106f5f
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
f0101336:	68 78 74 10 f0       	push   $0xf0107478
f010133b:	68 3a 02 00 00       	push   $0x23a
f0101340:	68 5f 6f 10 f0       	push   $0xf0106f5f
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
f0101365:	68 a8 74 10 f0       	push   $0xf01074a8
f010136a:	68 45 02 00 00       	push   $0x245
f010136f:	68 5f 6f 10 f0       	push   $0xf0106f5f
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
f01013ca:	3b 05 a0 9e 2a f0    	cmp    0xf02a9ea0,%eax
f01013d0:	72 14                	jb     f01013e6 <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f01013d2:	83 ec 04             	sub    $0x4,%esp
f01013d5:	68 d4 74 10 f0       	push   $0xf01074d4
f01013da:	6a 51                	push   $0x51
f01013dc:	68 6b 6f 10 f0       	push   $0xf0106f6b
f01013e1:	e8 5a ec ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f01013e6:	8b 15 a8 9e 2a f0    	mov    0xf02a9ea8,%edx
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
f0101408:	e8 81 49 00 00       	call   f0105d8e <cpunum>
f010140d:	6b c0 74             	imul   $0x74,%eax,%eax
f0101410:	83 b8 28 a0 2a f0 00 	cmpl   $0x0,-0xfd55fd8(%eax)
f0101417:	74 16                	je     f010142f <tlb_invalidate+0x2d>
f0101419:	e8 70 49 00 00       	call   f0105d8e <cpunum>
f010141e:	6b c0 74             	imul   $0x74,%eax,%eax
f0101421:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
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
f01014b4:	2b 15 a8 9e 2a f0    	sub    0xf02a9ea8,%edx
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
f01014dc:	2b 05 a8 9e 2a f0    	sub    0xf02a9ea8,%eax
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
f0101513:	8b 35 00 23 12 f0    	mov    0xf0122300,%esi

	if (ROUNDUP(mmio + size, PGSIZE) >= MMIOLIM)
f0101519:	8d 84 0e ff 0f 00 00 	lea    0xfff(%esi,%ecx,1),%eax
f0101520:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101525:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f010152a:	76 17                	jbe    f0101543 <mmio_map_region+0x38>
		panic("mmio_map_region: mmio out of memory");
f010152c:	83 ec 04             	sub    $0x4,%esp
f010152f:	68 f4 74 10 f0       	push   $0xf01074f4
f0101534:	68 0c 03 00 00       	push   $0x30c
f0101539:	68 5f 6f 10 f0       	push   $0xf0106f5f
f010153e:	e8 fd ea ff ff       	call   f0100040 <_panic>
		
	boot_map_region(kern_pgdir, mmio, ROUNDUP(size, PGSIZE), pa, PTE_PCD|PTE_PWT|PTE_W);
f0101543:	8d 99 ff 0f 00 00    	lea    0xfff(%ecx),%ebx
f0101549:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f010154f:	83 ec 08             	sub    $0x8,%esp
f0101552:	6a 1a                	push   $0x1a
f0101554:	ff 75 08             	pushl  0x8(%ebp)
f0101557:	89 d9                	mov    %ebx,%ecx
f0101559:	89 f2                	mov    %esi,%edx
f010155b:	a1 a4 9e 2a f0       	mov    0xf02a9ea4,%eax
f0101560:	e8 64 fd ff ff       	call   f01012c9 <boot_map_region>

	base += ROUNDUP(size, PGSIZE);
f0101565:	01 1d 00 23 12 f0    	add    %ebx,0xf0122300

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
f01015bd:	89 15 a0 9e 2a f0    	mov    %edx,0xf02a9ea0
	npages_basemem = basemem / (PGSIZE / 1024);
f01015c3:	89 da                	mov    %ebx,%edx
f01015c5:	c1 ea 02             	shr    $0x2,%edx
f01015c8:	89 15 44 92 2a f0    	mov    %edx,0xf02a9244

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01015ce:	89 c2                	mov    %eax,%edx
f01015d0:	29 da                	sub    %ebx,%edx
f01015d2:	52                   	push   %edx
f01015d3:	53                   	push   %ebx
f01015d4:	50                   	push   %eax
f01015d5:	68 18 75 10 f0       	push   $0xf0107518
f01015da:	e8 a3 23 00 00       	call   f0103982 <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01015df:	b8 00 10 00 00       	mov    $0x1000,%eax
f01015e4:	e8 39 f5 ff ff       	call   f0100b22 <boot_alloc>
f01015e9:	a3 a4 9e 2a f0       	mov    %eax,0xf02a9ea4
	memset(kern_pgdir, 0, PGSIZE);
f01015ee:	83 c4 0c             	add    $0xc,%esp
f01015f1:	68 00 10 00 00       	push   $0x1000
f01015f6:	6a 00                	push   $0x0
f01015f8:	50                   	push   %eax
f01015f9:	e8 70 41 00 00       	call   f010576e <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01015fe:	a1 a4 9e 2a f0       	mov    0xf02a9ea4,%eax
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
f010160e:	68 c8 69 10 f0       	push   $0xf01069c8
f0101613:	68 9b 00 00 00       	push   $0x9b
f0101618:	68 5f 6f 10 f0       	push   $0xf0106f5f
f010161d:	e8 1e ea ff ff       	call   f0100040 <_panic>
f0101622:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101628:	83 ca 05             	or     $0x5,%edx
f010162b:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:

	n = npages * sizeof(struct PageInfo);
f0101631:	a1 a0 9e 2a f0       	mov    0xf02a9ea0,%eax
f0101636:	8d 1c c5 00 00 00 00 	lea    0x0(,%eax,8),%ebx
	pages = (struct PageInfo *) boot_alloc(n);
f010163d:	89 d8                	mov    %ebx,%eax
f010163f:	e8 de f4 ff ff       	call   f0100b22 <boot_alloc>
f0101644:	a3 a8 9e 2a f0       	mov    %eax,0xf02a9ea8
	memset(pages, 0, n);
f0101649:	83 ec 04             	sub    $0x4,%esp
f010164c:	53                   	push   %ebx
f010164d:	6a 00                	push   $0x0
f010164f:	50                   	push   %eax
f0101650:	e8 19 41 00 00       	call   f010576e <memset>
	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.

	n = NENV * sizeof(struct Env);
	envs = (struct Env *) boot_alloc(n);
f0101655:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f010165a:	e8 c3 f4 ff ff       	call   f0100b22 <boot_alloc>
f010165f:	a3 48 92 2a f0       	mov    %eax,0xf02a9248
	memset(envs, 0, n);
f0101664:	83 c4 0c             	add    $0xc,%esp
f0101667:	68 00 f0 01 00       	push   $0x1f000
f010166c:	6a 00                	push   $0x0
f010166e:	50                   	push   %eax
f010166f:	e8 fa 40 00 00       	call   f010576e <memset>
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
f0101686:	83 3d a8 9e 2a f0 00 	cmpl   $0x0,0xf02a9ea8
f010168d:	75 17                	jne    f01016a6 <mem_init+0x132>
		panic("'pages' is a null pointer!");
f010168f:	83 ec 04             	sub    $0x4,%esp
f0101692:	68 8c 70 10 f0       	push   $0xf010708c
f0101697:	68 b2 03 00 00       	push   $0x3b2
f010169c:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01016a1:	e8 9a e9 ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01016a6:	a1 40 92 2a f0       	mov    0xf02a9240,%eax
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
f01016ce:	68 a7 70 10 f0       	push   $0xf01070a7
f01016d3:	68 85 6f 10 f0       	push   $0xf0106f85
f01016d8:	68 ba 03 00 00       	push   $0x3ba
f01016dd:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01016e2:	e8 59 e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01016e7:	83 ec 0c             	sub    $0xc,%esp
f01016ea:	6a 00                	push   $0x0
f01016ec:	e8 a0 f9 ff ff       	call   f0101091 <page_alloc>
f01016f1:	89 c6                	mov    %eax,%esi
f01016f3:	83 c4 10             	add    $0x10,%esp
f01016f6:	85 c0                	test   %eax,%eax
f01016f8:	75 19                	jne    f0101713 <mem_init+0x19f>
f01016fa:	68 bd 70 10 f0       	push   $0xf01070bd
f01016ff:	68 85 6f 10 f0       	push   $0xf0106f85
f0101704:	68 bb 03 00 00       	push   $0x3bb
f0101709:	68 5f 6f 10 f0       	push   $0xf0106f5f
f010170e:	e8 2d e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101713:	83 ec 0c             	sub    $0xc,%esp
f0101716:	6a 00                	push   $0x0
f0101718:	e8 74 f9 ff ff       	call   f0101091 <page_alloc>
f010171d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101720:	83 c4 10             	add    $0x10,%esp
f0101723:	85 c0                	test   %eax,%eax
f0101725:	75 19                	jne    f0101740 <mem_init+0x1cc>
f0101727:	68 d3 70 10 f0       	push   $0xf01070d3
f010172c:	68 85 6f 10 f0       	push   $0xf0106f85
f0101731:	68 bc 03 00 00       	push   $0x3bc
f0101736:	68 5f 6f 10 f0       	push   $0xf0106f5f
f010173b:	e8 00 e9 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101740:	39 f7                	cmp    %esi,%edi
f0101742:	75 19                	jne    f010175d <mem_init+0x1e9>
f0101744:	68 e9 70 10 f0       	push   $0xf01070e9
f0101749:	68 85 6f 10 f0       	push   $0xf0106f85
f010174e:	68 bf 03 00 00       	push   $0x3bf
f0101753:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101758:	e8 e3 e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010175d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101760:	39 c6                	cmp    %eax,%esi
f0101762:	74 04                	je     f0101768 <mem_init+0x1f4>
f0101764:	39 c7                	cmp    %eax,%edi
f0101766:	75 19                	jne    f0101781 <mem_init+0x20d>
f0101768:	68 54 75 10 f0       	push   $0xf0107554
f010176d:	68 85 6f 10 f0       	push   $0xf0106f85
f0101772:	68 c0 03 00 00       	push   $0x3c0
f0101777:	68 5f 6f 10 f0       	push   $0xf0106f5f
f010177c:	e8 bf e8 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101781:	8b 0d a8 9e 2a f0    	mov    0xf02a9ea8,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101787:	8b 15 a0 9e 2a f0    	mov    0xf02a9ea0,%edx
f010178d:	c1 e2 0c             	shl    $0xc,%edx
f0101790:	89 f8                	mov    %edi,%eax
f0101792:	29 c8                	sub    %ecx,%eax
f0101794:	c1 f8 03             	sar    $0x3,%eax
f0101797:	c1 e0 0c             	shl    $0xc,%eax
f010179a:	39 d0                	cmp    %edx,%eax
f010179c:	72 19                	jb     f01017b7 <mem_init+0x243>
f010179e:	68 fb 70 10 f0       	push   $0xf01070fb
f01017a3:	68 85 6f 10 f0       	push   $0xf0106f85
f01017a8:	68 c1 03 00 00       	push   $0x3c1
f01017ad:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01017b2:	e8 89 e8 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01017b7:	89 f0                	mov    %esi,%eax
f01017b9:	29 c8                	sub    %ecx,%eax
f01017bb:	c1 f8 03             	sar    $0x3,%eax
f01017be:	c1 e0 0c             	shl    $0xc,%eax
f01017c1:	39 c2                	cmp    %eax,%edx
f01017c3:	77 19                	ja     f01017de <mem_init+0x26a>
f01017c5:	68 18 71 10 f0       	push   $0xf0107118
f01017ca:	68 85 6f 10 f0       	push   $0xf0106f85
f01017cf:	68 c2 03 00 00       	push   $0x3c2
f01017d4:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01017d9:	e8 62 e8 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01017de:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01017e1:	29 c8                	sub    %ecx,%eax
f01017e3:	c1 f8 03             	sar    $0x3,%eax
f01017e6:	c1 e0 0c             	shl    $0xc,%eax
f01017e9:	39 c2                	cmp    %eax,%edx
f01017eb:	77 19                	ja     f0101806 <mem_init+0x292>
f01017ed:	68 35 71 10 f0       	push   $0xf0107135
f01017f2:	68 85 6f 10 f0       	push   $0xf0106f85
f01017f7:	68 c3 03 00 00       	push   $0x3c3
f01017fc:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101801:	e8 3a e8 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101806:	a1 40 92 2a f0       	mov    0xf02a9240,%eax
f010180b:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010180e:	c7 05 40 92 2a f0 00 	movl   $0x0,0xf02a9240
f0101815:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101818:	83 ec 0c             	sub    $0xc,%esp
f010181b:	6a 00                	push   $0x0
f010181d:	e8 6f f8 ff ff       	call   f0101091 <page_alloc>
f0101822:	83 c4 10             	add    $0x10,%esp
f0101825:	85 c0                	test   %eax,%eax
f0101827:	74 19                	je     f0101842 <mem_init+0x2ce>
f0101829:	68 52 71 10 f0       	push   $0xf0107152
f010182e:	68 85 6f 10 f0       	push   $0xf0106f85
f0101833:	68 ca 03 00 00       	push   $0x3ca
f0101838:	68 5f 6f 10 f0       	push   $0xf0106f5f
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
f0101873:	68 a7 70 10 f0       	push   $0xf01070a7
f0101878:	68 85 6f 10 f0       	push   $0xf0106f85
f010187d:	68 d1 03 00 00       	push   $0x3d1
f0101882:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101887:	e8 b4 e7 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010188c:	83 ec 0c             	sub    $0xc,%esp
f010188f:	6a 00                	push   $0x0
f0101891:	e8 fb f7 ff ff       	call   f0101091 <page_alloc>
f0101896:	89 c7                	mov    %eax,%edi
f0101898:	83 c4 10             	add    $0x10,%esp
f010189b:	85 c0                	test   %eax,%eax
f010189d:	75 19                	jne    f01018b8 <mem_init+0x344>
f010189f:	68 bd 70 10 f0       	push   $0xf01070bd
f01018a4:	68 85 6f 10 f0       	push   $0xf0106f85
f01018a9:	68 d2 03 00 00       	push   $0x3d2
f01018ae:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01018b3:	e8 88 e7 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01018b8:	83 ec 0c             	sub    $0xc,%esp
f01018bb:	6a 00                	push   $0x0
f01018bd:	e8 cf f7 ff ff       	call   f0101091 <page_alloc>
f01018c2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01018c5:	83 c4 10             	add    $0x10,%esp
f01018c8:	85 c0                	test   %eax,%eax
f01018ca:	75 19                	jne    f01018e5 <mem_init+0x371>
f01018cc:	68 d3 70 10 f0       	push   $0xf01070d3
f01018d1:	68 85 6f 10 f0       	push   $0xf0106f85
f01018d6:	68 d3 03 00 00       	push   $0x3d3
f01018db:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01018e0:	e8 5b e7 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01018e5:	39 fe                	cmp    %edi,%esi
f01018e7:	75 19                	jne    f0101902 <mem_init+0x38e>
f01018e9:	68 e9 70 10 f0       	push   $0xf01070e9
f01018ee:	68 85 6f 10 f0       	push   $0xf0106f85
f01018f3:	68 d5 03 00 00       	push   $0x3d5
f01018f8:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01018fd:	e8 3e e7 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101902:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101905:	39 c7                	cmp    %eax,%edi
f0101907:	74 04                	je     f010190d <mem_init+0x399>
f0101909:	39 c6                	cmp    %eax,%esi
f010190b:	75 19                	jne    f0101926 <mem_init+0x3b2>
f010190d:	68 54 75 10 f0       	push   $0xf0107554
f0101912:	68 85 6f 10 f0       	push   $0xf0106f85
f0101917:	68 d6 03 00 00       	push   $0x3d6
f010191c:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101921:	e8 1a e7 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101926:	83 ec 0c             	sub    $0xc,%esp
f0101929:	6a 00                	push   $0x0
f010192b:	e8 61 f7 ff ff       	call   f0101091 <page_alloc>
f0101930:	83 c4 10             	add    $0x10,%esp
f0101933:	85 c0                	test   %eax,%eax
f0101935:	74 19                	je     f0101950 <mem_init+0x3dc>
f0101937:	68 52 71 10 f0       	push   $0xf0107152
f010193c:	68 85 6f 10 f0       	push   $0xf0106f85
f0101941:	68 d7 03 00 00       	push   $0x3d7
f0101946:	68 5f 6f 10 f0       	push   $0xf0106f5f
f010194b:	e8 f0 e6 ff ff       	call   f0100040 <_panic>
f0101950:	89 f0                	mov    %esi,%eax
f0101952:	2b 05 a8 9e 2a f0    	sub    0xf02a9ea8,%eax
f0101958:	c1 f8 03             	sar    $0x3,%eax
f010195b:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010195e:	89 c2                	mov    %eax,%edx
f0101960:	c1 ea 0c             	shr    $0xc,%edx
f0101963:	3b 15 a0 9e 2a f0    	cmp    0xf02a9ea0,%edx
f0101969:	72 12                	jb     f010197d <mem_init+0x409>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010196b:	50                   	push   %eax
f010196c:	68 a4 69 10 f0       	push   $0xf01069a4
f0101971:	6a 58                	push   $0x58
f0101973:	68 6b 6f 10 f0       	push   $0xf0106f6b
f0101978:	e8 c3 e6 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f010197d:	83 ec 04             	sub    $0x4,%esp
f0101980:	68 00 10 00 00       	push   $0x1000
f0101985:	6a 01                	push   $0x1
f0101987:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010198c:	50                   	push   %eax
f010198d:	e8 dc 3d 00 00       	call   f010576e <memset>
	page_free(pp0);
f0101992:	89 34 24             	mov    %esi,(%esp)
f0101995:	e8 68 f7 ff ff       	call   f0101102 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010199a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01019a1:	e8 eb f6 ff ff       	call   f0101091 <page_alloc>
f01019a6:	83 c4 10             	add    $0x10,%esp
f01019a9:	85 c0                	test   %eax,%eax
f01019ab:	75 19                	jne    f01019c6 <mem_init+0x452>
f01019ad:	68 61 71 10 f0       	push   $0xf0107161
f01019b2:	68 85 6f 10 f0       	push   $0xf0106f85
f01019b7:	68 dc 03 00 00       	push   $0x3dc
f01019bc:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01019c1:	e8 7a e6 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f01019c6:	39 c6                	cmp    %eax,%esi
f01019c8:	74 19                	je     f01019e3 <mem_init+0x46f>
f01019ca:	68 7f 71 10 f0       	push   $0xf010717f
f01019cf:	68 85 6f 10 f0       	push   $0xf0106f85
f01019d4:	68 dd 03 00 00       	push   $0x3dd
f01019d9:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01019de:	e8 5d e6 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01019e3:	89 f0                	mov    %esi,%eax
f01019e5:	2b 05 a8 9e 2a f0    	sub    0xf02a9ea8,%eax
f01019eb:	c1 f8 03             	sar    $0x3,%eax
f01019ee:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01019f1:	89 c2                	mov    %eax,%edx
f01019f3:	c1 ea 0c             	shr    $0xc,%edx
f01019f6:	3b 15 a0 9e 2a f0    	cmp    0xf02a9ea0,%edx
f01019fc:	72 12                	jb     f0101a10 <mem_init+0x49c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01019fe:	50                   	push   %eax
f01019ff:	68 a4 69 10 f0       	push   $0xf01069a4
f0101a04:	6a 58                	push   $0x58
f0101a06:	68 6b 6f 10 f0       	push   $0xf0106f6b
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
f0101a21:	68 8f 71 10 f0       	push   $0xf010718f
f0101a26:	68 85 6f 10 f0       	push   $0xf0106f85
f0101a2b:	68 e1 03 00 00       	push   $0x3e1
f0101a30:	68 5f 6f 10 f0       	push   $0xf0106f5f
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
f0101a44:	a3 40 92 2a f0       	mov    %eax,0xf02a9240

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
f0101a65:	a1 40 92 2a f0       	mov    0xf02a9240,%eax
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
f0101a7c:	68 99 71 10 f0       	push   $0xf0107199
f0101a81:	68 85 6f 10 f0       	push   $0xf0106f85
f0101a86:	68 ef 03 00 00       	push   $0x3ef
f0101a8b:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101a90:	e8 ab e5 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101a95:	83 ec 0c             	sub    $0xc,%esp
f0101a98:	68 74 75 10 f0       	push   $0xf0107574
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
f0101ab8:	68 a7 70 10 f0       	push   $0xf01070a7
f0101abd:	68 85 6f 10 f0       	push   $0xf0106f85
f0101ac2:	68 59 04 00 00       	push   $0x459
f0101ac7:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101acc:	e8 6f e5 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101ad1:	83 ec 0c             	sub    $0xc,%esp
f0101ad4:	6a 00                	push   $0x0
f0101ad6:	e8 b6 f5 ff ff       	call   f0101091 <page_alloc>
f0101adb:	89 c3                	mov    %eax,%ebx
f0101add:	83 c4 10             	add    $0x10,%esp
f0101ae0:	85 c0                	test   %eax,%eax
f0101ae2:	75 19                	jne    f0101afd <mem_init+0x589>
f0101ae4:	68 bd 70 10 f0       	push   $0xf01070bd
f0101ae9:	68 85 6f 10 f0       	push   $0xf0106f85
f0101aee:	68 5a 04 00 00       	push   $0x45a
f0101af3:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101af8:	e8 43 e5 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101afd:	83 ec 0c             	sub    $0xc,%esp
f0101b00:	6a 00                	push   $0x0
f0101b02:	e8 8a f5 ff ff       	call   f0101091 <page_alloc>
f0101b07:	89 c6                	mov    %eax,%esi
f0101b09:	83 c4 10             	add    $0x10,%esp
f0101b0c:	85 c0                	test   %eax,%eax
f0101b0e:	75 19                	jne    f0101b29 <mem_init+0x5b5>
f0101b10:	68 d3 70 10 f0       	push   $0xf01070d3
f0101b15:	68 85 6f 10 f0       	push   $0xf0106f85
f0101b1a:	68 5b 04 00 00       	push   $0x45b
f0101b1f:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101b24:	e8 17 e5 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101b29:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101b2c:	75 19                	jne    f0101b47 <mem_init+0x5d3>
f0101b2e:	68 e9 70 10 f0       	push   $0xf01070e9
f0101b33:	68 85 6f 10 f0       	push   $0xf0106f85
f0101b38:	68 5e 04 00 00       	push   $0x45e
f0101b3d:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101b42:	e8 f9 e4 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101b47:	39 c3                	cmp    %eax,%ebx
f0101b49:	74 05                	je     f0101b50 <mem_init+0x5dc>
f0101b4b:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101b4e:	75 19                	jne    f0101b69 <mem_init+0x5f5>
f0101b50:	68 54 75 10 f0       	push   $0xf0107554
f0101b55:	68 85 6f 10 f0       	push   $0xf0106f85
f0101b5a:	68 5f 04 00 00       	push   $0x45f
f0101b5f:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101b64:	e8 d7 e4 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101b69:	a1 40 92 2a f0       	mov    0xf02a9240,%eax
f0101b6e:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101b71:	c7 05 40 92 2a f0 00 	movl   $0x0,0xf02a9240
f0101b78:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101b7b:	83 ec 0c             	sub    $0xc,%esp
f0101b7e:	6a 00                	push   $0x0
f0101b80:	e8 0c f5 ff ff       	call   f0101091 <page_alloc>
f0101b85:	83 c4 10             	add    $0x10,%esp
f0101b88:	85 c0                	test   %eax,%eax
f0101b8a:	74 19                	je     f0101ba5 <mem_init+0x631>
f0101b8c:	68 52 71 10 f0       	push   $0xf0107152
f0101b91:	68 85 6f 10 f0       	push   $0xf0106f85
f0101b96:	68 66 04 00 00       	push   $0x466
f0101b9b:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101ba0:	e8 9b e4 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101ba5:	83 ec 04             	sub    $0x4,%esp
f0101ba8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101bab:	50                   	push   %eax
f0101bac:	6a 00                	push   $0x0
f0101bae:	ff 35 a4 9e 2a f0    	pushl  0xf02a9ea4
f0101bb4:	e8 e3 f7 ff ff       	call   f010139c <page_lookup>
f0101bb9:	83 c4 10             	add    $0x10,%esp
f0101bbc:	85 c0                	test   %eax,%eax
f0101bbe:	74 19                	je     f0101bd9 <mem_init+0x665>
f0101bc0:	68 94 75 10 f0       	push   $0xf0107594
f0101bc5:	68 85 6f 10 f0       	push   $0xf0106f85
f0101bca:	68 69 04 00 00       	push   $0x469
f0101bcf:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101bd4:	e8 67 e4 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101bd9:	6a 02                	push   $0x2
f0101bdb:	6a 00                	push   $0x0
f0101bdd:	53                   	push   %ebx
f0101bde:	ff 35 a4 9e 2a f0    	pushl  0xf02a9ea4
f0101be4:	e8 9b f8 ff ff       	call   f0101484 <page_insert>
f0101be9:	83 c4 10             	add    $0x10,%esp
f0101bec:	85 c0                	test   %eax,%eax
f0101bee:	78 19                	js     f0101c09 <mem_init+0x695>
f0101bf0:	68 cc 75 10 f0       	push   $0xf01075cc
f0101bf5:	68 85 6f 10 f0       	push   $0xf0106f85
f0101bfa:	68 6c 04 00 00       	push   $0x46c
f0101bff:	68 5f 6f 10 f0       	push   $0xf0106f5f
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
f0101c19:	ff 35 a4 9e 2a f0    	pushl  0xf02a9ea4
f0101c1f:	e8 60 f8 ff ff       	call   f0101484 <page_insert>
f0101c24:	83 c4 20             	add    $0x20,%esp
f0101c27:	85 c0                	test   %eax,%eax
f0101c29:	74 19                	je     f0101c44 <mem_init+0x6d0>
f0101c2b:	68 fc 75 10 f0       	push   $0xf01075fc
f0101c30:	68 85 6f 10 f0       	push   $0xf0106f85
f0101c35:	68 70 04 00 00       	push   $0x470
f0101c3a:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101c3f:	e8 fc e3 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101c44:	8b 3d a4 9e 2a f0    	mov    0xf02a9ea4,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101c4a:	a1 a8 9e 2a f0       	mov    0xf02a9ea8,%eax
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
f0101c6b:	68 2c 76 10 f0       	push   $0xf010762c
f0101c70:	68 85 6f 10 f0       	push   $0xf0106f85
f0101c75:	68 71 04 00 00       	push   $0x471
f0101c7a:	68 5f 6f 10 f0       	push   $0xf0106f5f
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
f0101c9f:	68 54 76 10 f0       	push   $0xf0107654
f0101ca4:	68 85 6f 10 f0       	push   $0xf0106f85
f0101ca9:	68 72 04 00 00       	push   $0x472
f0101cae:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101cb3:	e8 88 e3 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101cb8:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101cbd:	74 19                	je     f0101cd8 <mem_init+0x764>
f0101cbf:	68 a4 71 10 f0       	push   $0xf01071a4
f0101cc4:	68 85 6f 10 f0       	push   $0xf0106f85
f0101cc9:	68 73 04 00 00       	push   $0x473
f0101cce:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101cd3:	e8 68 e3 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101cd8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101cdb:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101ce0:	74 19                	je     f0101cfb <mem_init+0x787>
f0101ce2:	68 b5 71 10 f0       	push   $0xf01071b5
f0101ce7:	68 85 6f 10 f0       	push   $0xf0106f85
f0101cec:	68 74 04 00 00       	push   $0x474
f0101cf1:	68 5f 6f 10 f0       	push   $0xf0106f5f
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
f0101d10:	68 84 76 10 f0       	push   $0xf0107684
f0101d15:	68 85 6f 10 f0       	push   $0xf0106f85
f0101d1a:	68 77 04 00 00       	push   $0x477
f0101d1f:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101d24:	e8 17 e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d29:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d2e:	a1 a4 9e 2a f0       	mov    0xf02a9ea4,%eax
f0101d33:	e8 3d ee ff ff       	call   f0100b75 <check_va2pa>
f0101d38:	89 f2                	mov    %esi,%edx
f0101d3a:	2b 15 a8 9e 2a f0    	sub    0xf02a9ea8,%edx
f0101d40:	c1 fa 03             	sar    $0x3,%edx
f0101d43:	c1 e2 0c             	shl    $0xc,%edx
f0101d46:	39 d0                	cmp    %edx,%eax
f0101d48:	74 19                	je     f0101d63 <mem_init+0x7ef>
f0101d4a:	68 c0 76 10 f0       	push   $0xf01076c0
f0101d4f:	68 85 6f 10 f0       	push   $0xf0106f85
f0101d54:	68 78 04 00 00       	push   $0x478
f0101d59:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101d5e:	e8 dd e2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101d63:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d68:	74 19                	je     f0101d83 <mem_init+0x80f>
f0101d6a:	68 c6 71 10 f0       	push   $0xf01071c6
f0101d6f:	68 85 6f 10 f0       	push   $0xf0106f85
f0101d74:	68 79 04 00 00       	push   $0x479
f0101d79:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101d7e:	e8 bd e2 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101d83:	83 ec 0c             	sub    $0xc,%esp
f0101d86:	6a 00                	push   $0x0
f0101d88:	e8 04 f3 ff ff       	call   f0101091 <page_alloc>
f0101d8d:	83 c4 10             	add    $0x10,%esp
f0101d90:	85 c0                	test   %eax,%eax
f0101d92:	74 19                	je     f0101dad <mem_init+0x839>
f0101d94:	68 52 71 10 f0       	push   $0xf0107152
f0101d99:	68 85 6f 10 f0       	push   $0xf0106f85
f0101d9e:	68 7c 04 00 00       	push   $0x47c
f0101da3:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101da8:	e8 93 e2 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101dad:	6a 02                	push   $0x2
f0101daf:	68 00 10 00 00       	push   $0x1000
f0101db4:	56                   	push   %esi
f0101db5:	ff 35 a4 9e 2a f0    	pushl  0xf02a9ea4
f0101dbb:	e8 c4 f6 ff ff       	call   f0101484 <page_insert>
f0101dc0:	83 c4 10             	add    $0x10,%esp
f0101dc3:	85 c0                	test   %eax,%eax
f0101dc5:	74 19                	je     f0101de0 <mem_init+0x86c>
f0101dc7:	68 84 76 10 f0       	push   $0xf0107684
f0101dcc:	68 85 6f 10 f0       	push   $0xf0106f85
f0101dd1:	68 7f 04 00 00       	push   $0x47f
f0101dd6:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101ddb:	e8 60 e2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101de0:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101de5:	a1 a4 9e 2a f0       	mov    0xf02a9ea4,%eax
f0101dea:	e8 86 ed ff ff       	call   f0100b75 <check_va2pa>
f0101def:	89 f2                	mov    %esi,%edx
f0101df1:	2b 15 a8 9e 2a f0    	sub    0xf02a9ea8,%edx
f0101df7:	c1 fa 03             	sar    $0x3,%edx
f0101dfa:	c1 e2 0c             	shl    $0xc,%edx
f0101dfd:	39 d0                	cmp    %edx,%eax
f0101dff:	74 19                	je     f0101e1a <mem_init+0x8a6>
f0101e01:	68 c0 76 10 f0       	push   $0xf01076c0
f0101e06:	68 85 6f 10 f0       	push   $0xf0106f85
f0101e0b:	68 80 04 00 00       	push   $0x480
f0101e10:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101e15:	e8 26 e2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101e1a:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101e1f:	74 19                	je     f0101e3a <mem_init+0x8c6>
f0101e21:	68 c6 71 10 f0       	push   $0xf01071c6
f0101e26:	68 85 6f 10 f0       	push   $0xf0106f85
f0101e2b:	68 81 04 00 00       	push   $0x481
f0101e30:	68 5f 6f 10 f0       	push   $0xf0106f5f
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
f0101e4b:	68 52 71 10 f0       	push   $0xf0107152
f0101e50:	68 85 6f 10 f0       	push   $0xf0106f85
f0101e55:	68 85 04 00 00       	push   $0x485
f0101e5a:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101e5f:	e8 dc e1 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101e64:	8b 15 a4 9e 2a f0    	mov    0xf02a9ea4,%edx
f0101e6a:	8b 02                	mov    (%edx),%eax
f0101e6c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101e71:	89 c1                	mov    %eax,%ecx
f0101e73:	c1 e9 0c             	shr    $0xc,%ecx
f0101e76:	3b 0d a0 9e 2a f0    	cmp    0xf02a9ea0,%ecx
f0101e7c:	72 15                	jb     f0101e93 <mem_init+0x91f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101e7e:	50                   	push   %eax
f0101e7f:	68 a4 69 10 f0       	push   $0xf01069a4
f0101e84:	68 88 04 00 00       	push   $0x488
f0101e89:	68 5f 6f 10 f0       	push   $0xf0106f5f
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
f0101eb8:	68 f0 76 10 f0       	push   $0xf01076f0
f0101ebd:	68 85 6f 10 f0       	push   $0xf0106f85
f0101ec2:	68 89 04 00 00       	push   $0x489
f0101ec7:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101ecc:	e8 6f e1 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101ed1:	6a 06                	push   $0x6
f0101ed3:	68 00 10 00 00       	push   $0x1000
f0101ed8:	56                   	push   %esi
f0101ed9:	ff 35 a4 9e 2a f0    	pushl  0xf02a9ea4
f0101edf:	e8 a0 f5 ff ff       	call   f0101484 <page_insert>
f0101ee4:	83 c4 10             	add    $0x10,%esp
f0101ee7:	85 c0                	test   %eax,%eax
f0101ee9:	74 19                	je     f0101f04 <mem_init+0x990>
f0101eeb:	68 30 77 10 f0       	push   $0xf0107730
f0101ef0:	68 85 6f 10 f0       	push   $0xf0106f85
f0101ef5:	68 8c 04 00 00       	push   $0x48c
f0101efa:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101eff:	e8 3c e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f04:	8b 3d a4 9e 2a f0    	mov    0xf02a9ea4,%edi
f0101f0a:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f0f:	89 f8                	mov    %edi,%eax
f0101f11:	e8 5f ec ff ff       	call   f0100b75 <check_va2pa>
f0101f16:	89 f2                	mov    %esi,%edx
f0101f18:	2b 15 a8 9e 2a f0    	sub    0xf02a9ea8,%edx
f0101f1e:	c1 fa 03             	sar    $0x3,%edx
f0101f21:	c1 e2 0c             	shl    $0xc,%edx
f0101f24:	39 d0                	cmp    %edx,%eax
f0101f26:	74 19                	je     f0101f41 <mem_init+0x9cd>
f0101f28:	68 c0 76 10 f0       	push   $0xf01076c0
f0101f2d:	68 85 6f 10 f0       	push   $0xf0106f85
f0101f32:	68 8d 04 00 00       	push   $0x48d
f0101f37:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101f3c:	e8 ff e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101f41:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101f46:	74 19                	je     f0101f61 <mem_init+0x9ed>
f0101f48:	68 c6 71 10 f0       	push   $0xf01071c6
f0101f4d:	68 85 6f 10 f0       	push   $0xf0106f85
f0101f52:	68 8e 04 00 00       	push   $0x48e
f0101f57:	68 5f 6f 10 f0       	push   $0xf0106f5f
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
f0101f79:	68 70 77 10 f0       	push   $0xf0107770
f0101f7e:	68 85 6f 10 f0       	push   $0xf0106f85
f0101f83:	68 8f 04 00 00       	push   $0x48f
f0101f88:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101f8d:	e8 ae e0 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101f92:	a1 a4 9e 2a f0       	mov    0xf02a9ea4,%eax
f0101f97:	f6 00 04             	testb  $0x4,(%eax)
f0101f9a:	75 19                	jne    f0101fb5 <mem_init+0xa41>
f0101f9c:	68 d7 71 10 f0       	push   $0xf01071d7
f0101fa1:	68 85 6f 10 f0       	push   $0xf0106f85
f0101fa6:	68 90 04 00 00       	push   $0x490
f0101fab:	68 5f 6f 10 f0       	push   $0xf0106f5f
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
f0101fca:	68 84 76 10 f0       	push   $0xf0107684
f0101fcf:	68 85 6f 10 f0       	push   $0xf0106f85
f0101fd4:	68 93 04 00 00       	push   $0x493
f0101fd9:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0101fde:	e8 5d e0 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101fe3:	83 ec 04             	sub    $0x4,%esp
f0101fe6:	6a 00                	push   $0x0
f0101fe8:	68 00 10 00 00       	push   $0x1000
f0101fed:	ff 35 a4 9e 2a f0    	pushl  0xf02a9ea4
f0101ff3:	e8 87 f1 ff ff       	call   f010117f <pgdir_walk>
f0101ff8:	83 c4 10             	add    $0x10,%esp
f0101ffb:	f6 00 02             	testb  $0x2,(%eax)
f0101ffe:	75 19                	jne    f0102019 <mem_init+0xaa5>
f0102000:	68 a4 77 10 f0       	push   $0xf01077a4
f0102005:	68 85 6f 10 f0       	push   $0xf0106f85
f010200a:	68 94 04 00 00       	push   $0x494
f010200f:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102014:	e8 27 e0 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102019:	83 ec 04             	sub    $0x4,%esp
f010201c:	6a 00                	push   $0x0
f010201e:	68 00 10 00 00       	push   $0x1000
f0102023:	ff 35 a4 9e 2a f0    	pushl  0xf02a9ea4
f0102029:	e8 51 f1 ff ff       	call   f010117f <pgdir_walk>
f010202e:	83 c4 10             	add    $0x10,%esp
f0102031:	f6 00 04             	testb  $0x4,(%eax)
f0102034:	74 19                	je     f010204f <mem_init+0xadb>
f0102036:	68 d8 77 10 f0       	push   $0xf01077d8
f010203b:	68 85 6f 10 f0       	push   $0xf0106f85
f0102040:	68 95 04 00 00       	push   $0x495
f0102045:	68 5f 6f 10 f0       	push   $0xf0106f5f
f010204a:	e8 f1 df ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f010204f:	6a 02                	push   $0x2
f0102051:	68 00 00 40 00       	push   $0x400000
f0102056:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102059:	ff 35 a4 9e 2a f0    	pushl  0xf02a9ea4
f010205f:	e8 20 f4 ff ff       	call   f0101484 <page_insert>
f0102064:	83 c4 10             	add    $0x10,%esp
f0102067:	85 c0                	test   %eax,%eax
f0102069:	78 19                	js     f0102084 <mem_init+0xb10>
f010206b:	68 10 78 10 f0       	push   $0xf0107810
f0102070:	68 85 6f 10 f0       	push   $0xf0106f85
f0102075:	68 98 04 00 00       	push   $0x498
f010207a:	68 5f 6f 10 f0       	push   $0xf0106f5f
f010207f:	e8 bc df ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102084:	6a 02                	push   $0x2
f0102086:	68 00 10 00 00       	push   $0x1000
f010208b:	53                   	push   %ebx
f010208c:	ff 35 a4 9e 2a f0    	pushl  0xf02a9ea4
f0102092:	e8 ed f3 ff ff       	call   f0101484 <page_insert>
f0102097:	83 c4 10             	add    $0x10,%esp
f010209a:	85 c0                	test   %eax,%eax
f010209c:	74 19                	je     f01020b7 <mem_init+0xb43>
f010209e:	68 48 78 10 f0       	push   $0xf0107848
f01020a3:	68 85 6f 10 f0       	push   $0xf0106f85
f01020a8:	68 9b 04 00 00       	push   $0x49b
f01020ad:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01020b2:	e8 89 df ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01020b7:	83 ec 04             	sub    $0x4,%esp
f01020ba:	6a 00                	push   $0x0
f01020bc:	68 00 10 00 00       	push   $0x1000
f01020c1:	ff 35 a4 9e 2a f0    	pushl  0xf02a9ea4
f01020c7:	e8 b3 f0 ff ff       	call   f010117f <pgdir_walk>
f01020cc:	83 c4 10             	add    $0x10,%esp
f01020cf:	f6 00 04             	testb  $0x4,(%eax)
f01020d2:	74 19                	je     f01020ed <mem_init+0xb79>
f01020d4:	68 d8 77 10 f0       	push   $0xf01077d8
f01020d9:	68 85 6f 10 f0       	push   $0xf0106f85
f01020de:	68 9c 04 00 00       	push   $0x49c
f01020e3:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01020e8:	e8 53 df ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01020ed:	8b 3d a4 9e 2a f0    	mov    0xf02a9ea4,%edi
f01020f3:	ba 00 00 00 00       	mov    $0x0,%edx
f01020f8:	89 f8                	mov    %edi,%eax
f01020fa:	e8 76 ea ff ff       	call   f0100b75 <check_va2pa>
f01020ff:	89 c1                	mov    %eax,%ecx
f0102101:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102104:	89 d8                	mov    %ebx,%eax
f0102106:	2b 05 a8 9e 2a f0    	sub    0xf02a9ea8,%eax
f010210c:	c1 f8 03             	sar    $0x3,%eax
f010210f:	c1 e0 0c             	shl    $0xc,%eax
f0102112:	39 c1                	cmp    %eax,%ecx
f0102114:	74 19                	je     f010212f <mem_init+0xbbb>
f0102116:	68 84 78 10 f0       	push   $0xf0107884
f010211b:	68 85 6f 10 f0       	push   $0xf0106f85
f0102120:	68 9f 04 00 00       	push   $0x49f
f0102125:	68 5f 6f 10 f0       	push   $0xf0106f5f
f010212a:	e8 11 df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010212f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102134:	89 f8                	mov    %edi,%eax
f0102136:	e8 3a ea ff ff       	call   f0100b75 <check_va2pa>
f010213b:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f010213e:	74 19                	je     f0102159 <mem_init+0xbe5>
f0102140:	68 b0 78 10 f0       	push   $0xf01078b0
f0102145:	68 85 6f 10 f0       	push   $0xf0106f85
f010214a:	68 a0 04 00 00       	push   $0x4a0
f010214f:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102154:	e8 e7 de ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102159:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f010215e:	74 19                	je     f0102179 <mem_init+0xc05>
f0102160:	68 ed 71 10 f0       	push   $0xf01071ed
f0102165:	68 85 6f 10 f0       	push   $0xf0106f85
f010216a:	68 a2 04 00 00       	push   $0x4a2
f010216f:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102174:	e8 c7 de ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102179:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010217e:	74 19                	je     f0102199 <mem_init+0xc25>
f0102180:	68 fe 71 10 f0       	push   $0xf01071fe
f0102185:	68 85 6f 10 f0       	push   $0xf0106f85
f010218a:	68 a3 04 00 00       	push   $0x4a3
f010218f:	68 5f 6f 10 f0       	push   $0xf0106f5f
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
f01021ae:	68 e0 78 10 f0       	push   $0xf01078e0
f01021b3:	68 85 6f 10 f0       	push   $0xf0106f85
f01021b8:	68 a6 04 00 00       	push   $0x4a6
f01021bd:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01021c2:	e8 79 de ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01021c7:	83 ec 08             	sub    $0x8,%esp
f01021ca:	6a 00                	push   $0x0
f01021cc:	ff 35 a4 9e 2a f0    	pushl  0xf02a9ea4
f01021d2:	e8 60 f2 ff ff       	call   f0101437 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01021d7:	8b 3d a4 9e 2a f0    	mov    0xf02a9ea4,%edi
f01021dd:	ba 00 00 00 00       	mov    $0x0,%edx
f01021e2:	89 f8                	mov    %edi,%eax
f01021e4:	e8 8c e9 ff ff       	call   f0100b75 <check_va2pa>
f01021e9:	83 c4 10             	add    $0x10,%esp
f01021ec:	83 f8 ff             	cmp    $0xffffffff,%eax
f01021ef:	74 19                	je     f010220a <mem_init+0xc96>
f01021f1:	68 04 79 10 f0       	push   $0xf0107904
f01021f6:	68 85 6f 10 f0       	push   $0xf0106f85
f01021fb:	68 aa 04 00 00       	push   $0x4aa
f0102200:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102205:	e8 36 de ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010220a:	ba 00 10 00 00       	mov    $0x1000,%edx
f010220f:	89 f8                	mov    %edi,%eax
f0102211:	e8 5f e9 ff ff       	call   f0100b75 <check_va2pa>
f0102216:	89 da                	mov    %ebx,%edx
f0102218:	2b 15 a8 9e 2a f0    	sub    0xf02a9ea8,%edx
f010221e:	c1 fa 03             	sar    $0x3,%edx
f0102221:	c1 e2 0c             	shl    $0xc,%edx
f0102224:	39 d0                	cmp    %edx,%eax
f0102226:	74 19                	je     f0102241 <mem_init+0xccd>
f0102228:	68 b0 78 10 f0       	push   $0xf01078b0
f010222d:	68 85 6f 10 f0       	push   $0xf0106f85
f0102232:	68 ab 04 00 00       	push   $0x4ab
f0102237:	68 5f 6f 10 f0       	push   $0xf0106f5f
f010223c:	e8 ff dd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102241:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102246:	74 19                	je     f0102261 <mem_init+0xced>
f0102248:	68 a4 71 10 f0       	push   $0xf01071a4
f010224d:	68 85 6f 10 f0       	push   $0xf0106f85
f0102252:	68 ac 04 00 00       	push   $0x4ac
f0102257:	68 5f 6f 10 f0       	push   $0xf0106f5f
f010225c:	e8 df dd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102261:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102266:	74 19                	je     f0102281 <mem_init+0xd0d>
f0102268:	68 fe 71 10 f0       	push   $0xf01071fe
f010226d:	68 85 6f 10 f0       	push   $0xf0106f85
f0102272:	68 ad 04 00 00       	push   $0x4ad
f0102277:	68 5f 6f 10 f0       	push   $0xf0106f5f
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
f0102296:	68 28 79 10 f0       	push   $0xf0107928
f010229b:	68 85 6f 10 f0       	push   $0xf0106f85
f01022a0:	68 b0 04 00 00       	push   $0x4b0
f01022a5:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01022aa:	e8 91 dd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f01022af:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01022b4:	75 19                	jne    f01022cf <mem_init+0xd5b>
f01022b6:	68 0f 72 10 f0       	push   $0xf010720f
f01022bb:	68 85 6f 10 f0       	push   $0xf0106f85
f01022c0:	68 b1 04 00 00       	push   $0x4b1
f01022c5:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01022ca:	e8 71 dd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f01022cf:	83 3b 00             	cmpl   $0x0,(%ebx)
f01022d2:	74 19                	je     f01022ed <mem_init+0xd79>
f01022d4:	68 1b 72 10 f0       	push   $0xf010721b
f01022d9:	68 85 6f 10 f0       	push   $0xf0106f85
f01022de:	68 b2 04 00 00       	push   $0x4b2
f01022e3:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01022e8:	e8 53 dd ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01022ed:	83 ec 08             	sub    $0x8,%esp
f01022f0:	68 00 10 00 00       	push   $0x1000
f01022f5:	ff 35 a4 9e 2a f0    	pushl  0xf02a9ea4
f01022fb:	e8 37 f1 ff ff       	call   f0101437 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102300:	8b 3d a4 9e 2a f0    	mov    0xf02a9ea4,%edi
f0102306:	ba 00 00 00 00       	mov    $0x0,%edx
f010230b:	89 f8                	mov    %edi,%eax
f010230d:	e8 63 e8 ff ff       	call   f0100b75 <check_va2pa>
f0102312:	83 c4 10             	add    $0x10,%esp
f0102315:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102318:	74 19                	je     f0102333 <mem_init+0xdbf>
f010231a:	68 04 79 10 f0       	push   $0xf0107904
f010231f:	68 85 6f 10 f0       	push   $0xf0106f85
f0102324:	68 b6 04 00 00       	push   $0x4b6
f0102329:	68 5f 6f 10 f0       	push   $0xf0106f5f
f010232e:	e8 0d dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102333:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102338:	89 f8                	mov    %edi,%eax
f010233a:	e8 36 e8 ff ff       	call   f0100b75 <check_va2pa>
f010233f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102342:	74 19                	je     f010235d <mem_init+0xde9>
f0102344:	68 60 79 10 f0       	push   $0xf0107960
f0102349:	68 85 6f 10 f0       	push   $0xf0106f85
f010234e:	68 b7 04 00 00       	push   $0x4b7
f0102353:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102358:	e8 e3 dc ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f010235d:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102362:	74 19                	je     f010237d <mem_init+0xe09>
f0102364:	68 30 72 10 f0       	push   $0xf0107230
f0102369:	68 85 6f 10 f0       	push   $0xf0106f85
f010236e:	68 b8 04 00 00       	push   $0x4b8
f0102373:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102378:	e8 c3 dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010237d:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102382:	74 19                	je     f010239d <mem_init+0xe29>
f0102384:	68 fe 71 10 f0       	push   $0xf01071fe
f0102389:	68 85 6f 10 f0       	push   $0xf0106f85
f010238e:	68 b9 04 00 00       	push   $0x4b9
f0102393:	68 5f 6f 10 f0       	push   $0xf0106f5f
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
f01023b2:	68 88 79 10 f0       	push   $0xf0107988
f01023b7:	68 85 6f 10 f0       	push   $0xf0106f85
f01023bc:	68 bc 04 00 00       	push   $0x4bc
f01023c1:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01023c6:	e8 75 dc ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01023cb:	83 ec 0c             	sub    $0xc,%esp
f01023ce:	6a 00                	push   $0x0
f01023d0:	e8 bc ec ff ff       	call   f0101091 <page_alloc>
f01023d5:	83 c4 10             	add    $0x10,%esp
f01023d8:	85 c0                	test   %eax,%eax
f01023da:	74 19                	je     f01023f5 <mem_init+0xe81>
f01023dc:	68 52 71 10 f0       	push   $0xf0107152
f01023e1:	68 85 6f 10 f0       	push   $0xf0106f85
f01023e6:	68 bf 04 00 00       	push   $0x4bf
f01023eb:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01023f0:	e8 4b dc ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01023f5:	8b 0d a4 9e 2a f0    	mov    0xf02a9ea4,%ecx
f01023fb:	8b 11                	mov    (%ecx),%edx
f01023fd:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102403:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102406:	2b 05 a8 9e 2a f0    	sub    0xf02a9ea8,%eax
f010240c:	c1 f8 03             	sar    $0x3,%eax
f010240f:	c1 e0 0c             	shl    $0xc,%eax
f0102412:	39 c2                	cmp    %eax,%edx
f0102414:	74 19                	je     f010242f <mem_init+0xebb>
f0102416:	68 2c 76 10 f0       	push   $0xf010762c
f010241b:	68 85 6f 10 f0       	push   $0xf0106f85
f0102420:	68 c2 04 00 00       	push   $0x4c2
f0102425:	68 5f 6f 10 f0       	push   $0xf0106f5f
f010242a:	e8 11 dc ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f010242f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102435:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102438:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010243d:	74 19                	je     f0102458 <mem_init+0xee4>
f010243f:	68 b5 71 10 f0       	push   $0xf01071b5
f0102444:	68 85 6f 10 f0       	push   $0xf0106f85
f0102449:	68 c4 04 00 00       	push   $0x4c4
f010244e:	68 5f 6f 10 f0       	push   $0xf0106f5f
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
f0102474:	ff 35 a4 9e 2a f0    	pushl  0xf02a9ea4
f010247a:	e8 00 ed ff ff       	call   f010117f <pgdir_walk>
f010247f:	89 c7                	mov    %eax,%edi
f0102481:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102484:	a1 a4 9e 2a f0       	mov    0xf02a9ea4,%eax
f0102489:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010248c:	8b 40 04             	mov    0x4(%eax),%eax
f010248f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102494:	8b 0d a0 9e 2a f0    	mov    0xf02a9ea0,%ecx
f010249a:	89 c2                	mov    %eax,%edx
f010249c:	c1 ea 0c             	shr    $0xc,%edx
f010249f:	83 c4 10             	add    $0x10,%esp
f01024a2:	39 ca                	cmp    %ecx,%edx
f01024a4:	72 15                	jb     f01024bb <mem_init+0xf47>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024a6:	50                   	push   %eax
f01024a7:	68 a4 69 10 f0       	push   $0xf01069a4
f01024ac:	68 cb 04 00 00       	push   $0x4cb
f01024b1:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01024b6:	e8 85 db ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01024bb:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f01024c0:	39 c7                	cmp    %eax,%edi
f01024c2:	74 19                	je     f01024dd <mem_init+0xf69>
f01024c4:	68 41 72 10 f0       	push   $0xf0107241
f01024c9:	68 85 6f 10 f0       	push   $0xf0106f85
f01024ce:	68 cc 04 00 00       	push   $0x4cc
f01024d3:	68 5f 6f 10 f0       	push   $0xf0106f5f
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
f01024f0:	2b 05 a8 9e 2a f0    	sub    0xf02a9ea8,%eax
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
f0102506:	68 a4 69 10 f0       	push   $0xf01069a4
f010250b:	6a 58                	push   $0x58
f010250d:	68 6b 6f 10 f0       	push   $0xf0106f6b
f0102512:	e8 29 db ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102517:	83 ec 04             	sub    $0x4,%esp
f010251a:	68 00 10 00 00       	push   $0x1000
f010251f:	68 ff 00 00 00       	push   $0xff
f0102524:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102529:	50                   	push   %eax
f010252a:	e8 3f 32 00 00       	call   f010576e <memset>
	page_free(pp0);
f010252f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102532:	89 3c 24             	mov    %edi,(%esp)
f0102535:	e8 c8 eb ff ff       	call   f0101102 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f010253a:	83 c4 0c             	add    $0xc,%esp
f010253d:	6a 01                	push   $0x1
f010253f:	6a 00                	push   $0x0
f0102541:	ff 35 a4 9e 2a f0    	pushl  0xf02a9ea4
f0102547:	e8 33 ec ff ff       	call   f010117f <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010254c:	89 fa                	mov    %edi,%edx
f010254e:	2b 15 a8 9e 2a f0    	sub    0xf02a9ea8,%edx
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
f0102562:	3b 05 a0 9e 2a f0    	cmp    0xf02a9ea0,%eax
f0102568:	72 12                	jb     f010257c <mem_init+0x1008>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010256a:	52                   	push   %edx
f010256b:	68 a4 69 10 f0       	push   $0xf01069a4
f0102570:	6a 58                	push   $0x58
f0102572:	68 6b 6f 10 f0       	push   $0xf0106f6b
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
f0102590:	68 59 72 10 f0       	push   $0xf0107259
f0102595:	68 85 6f 10 f0       	push   $0xf0106f85
f010259a:	68 d6 04 00 00       	push   $0x4d6
f010259f:	68 5f 6f 10 f0       	push   $0xf0106f5f
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
f01025b0:	a1 a4 9e 2a f0       	mov    0xf02a9ea4,%eax
f01025b5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01025bb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01025be:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f01025c4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01025c7:	89 0d 40 92 2a f0    	mov    %ecx,0xf02a9240

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
f0102620:	68 ac 79 10 f0       	push   $0xf01079ac
f0102625:	68 85 6f 10 f0       	push   $0xf0106f85
f010262a:	68 e6 04 00 00       	push   $0x4e6
f010262f:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102634:	e8 07 da ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f0102639:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
f010263f:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102645:	77 08                	ja     f010264f <mem_init+0x10db>
f0102647:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010264d:	77 19                	ja     f0102668 <mem_init+0x10f4>
f010264f:	68 d4 79 10 f0       	push   $0xf01079d4
f0102654:	68 85 6f 10 f0       	push   $0xf0106f85
f0102659:	68 e7 04 00 00       	push   $0x4e7
f010265e:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102663:	e8 d8 d9 ff ff       	call   f0100040 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102668:	89 da                	mov    %ebx,%edx
f010266a:	09 f2                	or     %esi,%edx
f010266c:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102672:	74 19                	je     f010268d <mem_init+0x1119>
f0102674:	68 fc 79 10 f0       	push   $0xf01079fc
f0102679:	68 85 6f 10 f0       	push   $0xf0106f85
f010267e:	68 e9 04 00 00       	push   $0x4e9
f0102683:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102688:	e8 b3 d9 ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8192 <= mm2);
f010268d:	39 c6                	cmp    %eax,%esi
f010268f:	73 19                	jae    f01026aa <mem_init+0x1136>
f0102691:	68 70 72 10 f0       	push   $0xf0107270
f0102696:	68 85 6f 10 f0       	push   $0xf0106f85
f010269b:	68 eb 04 00 00       	push   $0x4eb
f01026a0:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01026a5:	e8 96 d9 ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01026aa:	8b 3d a4 9e 2a f0    	mov    0xf02a9ea4,%edi
f01026b0:	89 da                	mov    %ebx,%edx
f01026b2:	89 f8                	mov    %edi,%eax
f01026b4:	e8 bc e4 ff ff       	call   f0100b75 <check_va2pa>
f01026b9:	85 c0                	test   %eax,%eax
f01026bb:	74 19                	je     f01026d6 <mem_init+0x1162>
f01026bd:	68 24 7a 10 f0       	push   $0xf0107a24
f01026c2:	68 85 6f 10 f0       	push   $0xf0106f85
f01026c7:	68 ed 04 00 00       	push   $0x4ed
f01026cc:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01026d1:	e8 6a d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01026d6:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f01026dc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01026df:	89 c2                	mov    %eax,%edx
f01026e1:	89 f8                	mov    %edi,%eax
f01026e3:	e8 8d e4 ff ff       	call   f0100b75 <check_va2pa>
f01026e8:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01026ed:	74 19                	je     f0102708 <mem_init+0x1194>
f01026ef:	68 48 7a 10 f0       	push   $0xf0107a48
f01026f4:	68 85 6f 10 f0       	push   $0xf0106f85
f01026f9:	68 ee 04 00 00       	push   $0x4ee
f01026fe:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102703:	e8 38 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102708:	89 f2                	mov    %esi,%edx
f010270a:	89 f8                	mov    %edi,%eax
f010270c:	e8 64 e4 ff ff       	call   f0100b75 <check_va2pa>
f0102711:	85 c0                	test   %eax,%eax
f0102713:	74 19                	je     f010272e <mem_init+0x11ba>
f0102715:	68 78 7a 10 f0       	push   $0xf0107a78
f010271a:	68 85 6f 10 f0       	push   $0xf0106f85
f010271f:	68 ef 04 00 00       	push   $0x4ef
f0102724:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102729:	e8 12 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f010272e:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102734:	89 f8                	mov    %edi,%eax
f0102736:	e8 3a e4 ff ff       	call   f0100b75 <check_va2pa>
f010273b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010273e:	74 19                	je     f0102759 <mem_init+0x11e5>
f0102740:	68 9c 7a 10 f0       	push   $0xf0107a9c
f0102745:	68 85 6f 10 f0       	push   $0xf0106f85
f010274a:	68 f0 04 00 00       	push   $0x4f0
f010274f:	68 5f 6f 10 f0       	push   $0xf0106f5f
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
f010276d:	68 c8 7a 10 f0       	push   $0xf0107ac8
f0102772:	68 85 6f 10 f0       	push   $0xf0106f85
f0102777:	68 f2 04 00 00       	push   $0x4f2
f010277c:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102781:	e8 ba d8 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102786:	83 ec 04             	sub    $0x4,%esp
f0102789:	6a 00                	push   $0x0
f010278b:	53                   	push   %ebx
f010278c:	ff 35 a4 9e 2a f0    	pushl  0xf02a9ea4
f0102792:	e8 e8 e9 ff ff       	call   f010117f <pgdir_walk>
f0102797:	8b 00                	mov    (%eax),%eax
f0102799:	83 c4 10             	add    $0x10,%esp
f010279c:	83 e0 04             	and    $0x4,%eax
f010279f:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01027a2:	74 19                	je     f01027bd <mem_init+0x1249>
f01027a4:	68 0c 7b 10 f0       	push   $0xf0107b0c
f01027a9:	68 85 6f 10 f0       	push   $0xf0106f85
f01027ae:	68 f3 04 00 00       	push   $0x4f3
f01027b3:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01027b8:	e8 83 d8 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f01027bd:	83 ec 04             	sub    $0x4,%esp
f01027c0:	6a 00                	push   $0x0
f01027c2:	53                   	push   %ebx
f01027c3:	ff 35 a4 9e 2a f0    	pushl  0xf02a9ea4
f01027c9:	e8 b1 e9 ff ff       	call   f010117f <pgdir_walk>
f01027ce:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f01027d4:	83 c4 0c             	add    $0xc,%esp
f01027d7:	6a 00                	push   $0x0
f01027d9:	ff 75 d4             	pushl  -0x2c(%ebp)
f01027dc:	ff 35 a4 9e 2a f0    	pushl  0xf02a9ea4
f01027e2:	e8 98 e9 ff ff       	call   f010117f <pgdir_walk>
f01027e7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f01027ed:	83 c4 0c             	add    $0xc,%esp
f01027f0:	6a 00                	push   $0x0
f01027f2:	56                   	push   %esi
f01027f3:	ff 35 a4 9e 2a f0    	pushl  0xf02a9ea4
f01027f9:	e8 81 e9 ff ff       	call   f010117f <pgdir_walk>
f01027fe:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102804:	c7 04 24 82 72 10 f0 	movl   $0xf0107282,(%esp)
f010280b:	e8 72 11 00 00       	call   f0103982 <cprintf>
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f0102810:	a1 a8 9e 2a f0       	mov    0xf02a9ea8,%eax
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
f0102820:	68 c8 69 10 f0       	push   $0xf01069c8
f0102825:	68 ca 00 00 00       	push   $0xca
f010282a:	68 5f 6f 10 f0       	push   $0xf0106f5f
f010282f:	e8 0c d8 ff ff       	call   f0100040 <_panic>
f0102834:	83 ec 08             	sub    $0x8,%esp
f0102837:	6a 04                	push   $0x4
f0102839:	05 00 00 00 10       	add    $0x10000000,%eax
f010283e:	50                   	push   %eax
f010283f:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102844:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102849:	a1 a4 9e 2a f0       	mov    0xf02a9ea4,%eax
f010284e:	e8 76 ea ff ff       	call   f01012c9 <boot_map_region>
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.

	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U);
f0102853:	a1 48 92 2a f0       	mov    0xf02a9248,%eax
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
f0102863:	68 c8 69 10 f0       	push   $0xf01069c8
f0102868:	68 d4 00 00 00       	push   $0xd4
f010286d:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102872:	e8 c9 d7 ff ff       	call   f0100040 <_panic>
f0102877:	83 ec 08             	sub    $0x8,%esp
f010287a:	6a 04                	push   $0x4
f010287c:	05 00 00 00 10       	add    $0x10000000,%eax
f0102881:	50                   	push   %eax
f0102882:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102887:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f010288c:	a1 a4 9e 2a f0       	mov    0xf02a9ea4,%eax
f0102891:	e8 33 ea ff ff       	call   f01012c9 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102896:	83 c4 10             	add    $0x10,%esp
f0102899:	b8 00 80 11 f0       	mov    $0xf0118000,%eax
f010289e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01028a3:	77 15                	ja     f01028ba <mem_init+0x1346>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01028a5:	50                   	push   %eax
f01028a6:	68 c8 69 10 f0       	push   $0xf01069c8
f01028ab:	68 e2 00 00 00       	push   $0xe2
f01028b0:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01028b5:	e8 86 d7 ff ff       	call   f0100040 <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f01028ba:	83 ec 08             	sub    $0x8,%esp
f01028bd:	6a 02                	push   $0x2
f01028bf:	68 00 80 11 00       	push   $0x118000
f01028c4:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01028c9:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01028ce:	a1 a4 9e 2a f0       	mov    0xf02a9ea4,%eax
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
f01028e9:	a1 a4 9e 2a f0       	mov    0xf02a9ea4,%eax
f01028ee:	e8 d6 e9 ff ff       	call   f01012c9 <boot_map_region>
f01028f3:	c7 45 c4 00 b0 2a f0 	movl   $0xf02ab000,-0x3c(%ebp)
f01028fa:	83 c4 10             	add    $0x10,%esp
f01028fd:	bb 00 b0 2a f0       	mov    $0xf02ab000,%ebx
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
f0102910:	68 c8 69 10 f0       	push   $0xf01069c8
f0102915:	68 26 01 00 00       	push   $0x126
f010291a:	68 5f 6f 10 f0       	push   $0xf0106f5f
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
f0102937:	a1 a4 9e 2a f0       	mov    0xf02a9ea4,%eax
f010293c:	e8 88 e9 ff ff       	call   f01012c9 <boot_map_region>
f0102941:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102947:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//
	// LAB 4: Your code here:

	uint32_t kstacktop_i;

	for (int i=0; i<NCPU; i++) {
f010294d:	83 c4 10             	add    $0x10,%esp
f0102950:	b8 00 b0 2e f0       	mov    $0xf02eb000,%eax
f0102955:	39 d8                	cmp    %ebx,%eax
f0102957:	75 ae                	jne    f0102907 <mem_init+0x1393>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102959:	8b 3d a4 9e 2a f0    	mov    0xf02a9ea4,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010295f:	a1 a0 9e 2a f0       	mov    0xf02a9ea0,%eax
f0102964:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102967:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f010296e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102973:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102976:	8b 35 a8 9e 2a f0    	mov    0xf02a9ea8,%esi
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
f010299d:	68 c8 69 10 f0       	push   $0xf01069c8
f01029a2:	68 07 04 00 00       	push   $0x407
f01029a7:	68 5f 6f 10 f0       	push   $0xf0106f5f
f01029ac:	e8 8f d6 ff ff       	call   f0100040 <_panic>
f01029b1:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f01029b8:	39 c2                	cmp    %eax,%edx
f01029ba:	74 19                	je     f01029d5 <mem_init+0x1461>
f01029bc:	68 40 7b 10 f0       	push   $0xf0107b40
f01029c1:	68 85 6f 10 f0       	push   $0xf0106f85
f01029c6:	68 07 04 00 00       	push   $0x407
f01029cb:	68 5f 6f 10 f0       	push   $0xf0106f5f
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
f01029e0:	8b 35 48 92 2a f0    	mov    0xf02a9248,%esi
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
f0102a01:	68 c8 69 10 f0       	push   $0xf01069c8
f0102a06:	68 0c 04 00 00       	push   $0x40c
f0102a0b:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102a10:	e8 2b d6 ff ff       	call   f0100040 <_panic>
f0102a15:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f0102a1c:	39 d0                	cmp    %edx,%eax
f0102a1e:	74 19                	je     f0102a39 <mem_init+0x14c5>
f0102a20:	68 74 7b 10 f0       	push   $0xf0107b74
f0102a25:	68 85 6f 10 f0       	push   $0xf0106f85
f0102a2a:	68 0c 04 00 00       	push   $0x40c
f0102a2f:	68 5f 6f 10 f0       	push   $0xf0106f5f
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
f0102a65:	68 a8 7b 10 f0       	push   $0xf0107ba8
f0102a6a:	68 85 6f 10 f0       	push   $0xf0106f85
f0102a6f:	68 10 04 00 00       	push   $0x410
f0102a74:	68 5f 6f 10 f0       	push   $0xf0106f5f
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
f0102abe:	68 c8 69 10 f0       	push   $0xf01069c8
f0102ac3:	68 18 04 00 00       	push   $0x418
f0102ac8:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102acd:	e8 6e d5 ff ff       	call   f0100040 <_panic>
f0102ad2:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102ad5:	8d 94 0b 00 b0 2a f0 	lea    -0xfd55000(%ebx,%ecx,1),%edx
f0102adc:	39 d0                	cmp    %edx,%eax
f0102ade:	74 19                	je     f0102af9 <mem_init+0x1585>
f0102ae0:	68 d0 7b 10 f0       	push   $0xf0107bd0
f0102ae5:	68 85 6f 10 f0       	push   $0xf0106f85
f0102aea:	68 18 04 00 00       	push   $0x418
f0102aef:	68 5f 6f 10 f0       	push   $0xf0106f5f
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
f0102b20:	68 18 7c 10 f0       	push   $0xf0107c18
f0102b25:	68 85 6f 10 f0       	push   $0xf0106f85
f0102b2a:	68 1a 04 00 00       	push   $0x41a
f0102b2f:	68 5f 6f 10 f0       	push   $0xf0106f5f
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
f0102b5a:	b8 00 b0 2e f0       	mov    $0xf02eb000,%eax
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
f0102b7f:	68 9b 72 10 f0       	push   $0xf010729b
f0102b84:	68 85 6f 10 f0       	push   $0xf0106f85
f0102b89:	68 25 04 00 00       	push   $0x425
f0102b8e:	68 5f 6f 10 f0       	push   $0xf0106f5f
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
f0102ba7:	68 9b 72 10 f0       	push   $0xf010729b
f0102bac:	68 85 6f 10 f0       	push   $0xf0106f85
f0102bb1:	68 29 04 00 00       	push   $0x429
f0102bb6:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102bbb:	e8 80 d4 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102bc0:	f6 c2 02             	test   $0x2,%dl
f0102bc3:	75 38                	jne    f0102bfd <mem_init+0x1689>
f0102bc5:	68 ac 72 10 f0       	push   $0xf01072ac
f0102bca:	68 85 6f 10 f0       	push   $0xf0106f85
f0102bcf:	68 2a 04 00 00       	push   $0x42a
f0102bd4:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102bd9:	e8 62 d4 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102bde:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102be2:	74 19                	je     f0102bfd <mem_init+0x1689>
f0102be4:	68 bd 72 10 f0       	push   $0xf01072bd
f0102be9:	68 85 6f 10 f0       	push   $0xf0106f85
f0102bee:	68 2c 04 00 00       	push   $0x42c
f0102bf3:	68 5f 6f 10 f0       	push   $0xf0106f5f
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
f0102c0e:	68 3c 7c 10 f0       	push   $0xf0107c3c
f0102c13:	e8 6a 0d 00 00       	call   f0103982 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102c18:	a1 a4 9e 2a f0       	mov    0xf02a9ea4,%eax
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
f0102c28:	68 c8 69 10 f0       	push   $0xf01069c8
f0102c2d:	68 fc 00 00 00       	push   $0xfc
f0102c32:	68 5f 6f 10 f0       	push   $0xf0106f5f
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
f0102c6f:	68 a7 70 10 f0       	push   $0xf01070a7
f0102c74:	68 85 6f 10 f0       	push   $0xf0106f85
f0102c79:	68 08 05 00 00       	push   $0x508
f0102c7e:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102c83:	e8 b8 d3 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102c88:	83 ec 0c             	sub    $0xc,%esp
f0102c8b:	6a 00                	push   $0x0
f0102c8d:	e8 ff e3 ff ff       	call   f0101091 <page_alloc>
f0102c92:	89 c7                	mov    %eax,%edi
f0102c94:	83 c4 10             	add    $0x10,%esp
f0102c97:	85 c0                	test   %eax,%eax
f0102c99:	75 19                	jne    f0102cb4 <mem_init+0x1740>
f0102c9b:	68 bd 70 10 f0       	push   $0xf01070bd
f0102ca0:	68 85 6f 10 f0       	push   $0xf0106f85
f0102ca5:	68 09 05 00 00       	push   $0x509
f0102caa:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102caf:	e8 8c d3 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102cb4:	83 ec 0c             	sub    $0xc,%esp
f0102cb7:	6a 00                	push   $0x0
f0102cb9:	e8 d3 e3 ff ff       	call   f0101091 <page_alloc>
f0102cbe:	89 c6                	mov    %eax,%esi
f0102cc0:	83 c4 10             	add    $0x10,%esp
f0102cc3:	85 c0                	test   %eax,%eax
f0102cc5:	75 19                	jne    f0102ce0 <mem_init+0x176c>
f0102cc7:	68 d3 70 10 f0       	push   $0xf01070d3
f0102ccc:	68 85 6f 10 f0       	push   $0xf0106f85
f0102cd1:	68 0a 05 00 00       	push   $0x50a
f0102cd6:	68 5f 6f 10 f0       	push   $0xf0106f5f
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
f0102ceb:	2b 05 a8 9e 2a f0    	sub    0xf02a9ea8,%eax
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
f0102cff:	3b 15 a0 9e 2a f0    	cmp    0xf02a9ea0,%edx
f0102d05:	72 12                	jb     f0102d19 <mem_init+0x17a5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d07:	50                   	push   %eax
f0102d08:	68 a4 69 10 f0       	push   $0xf01069a4
f0102d0d:	6a 58                	push   $0x58
f0102d0f:	68 6b 6f 10 f0       	push   $0xf0106f6b
f0102d14:	e8 27 d3 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102d19:	83 ec 04             	sub    $0x4,%esp
f0102d1c:	68 00 10 00 00       	push   $0x1000
f0102d21:	6a 01                	push   $0x1
f0102d23:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102d28:	50                   	push   %eax
f0102d29:	e8 40 2a 00 00       	call   f010576e <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102d2e:	89 f0                	mov    %esi,%eax
f0102d30:	2b 05 a8 9e 2a f0    	sub    0xf02a9ea8,%eax
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
f0102d44:	3b 15 a0 9e 2a f0    	cmp    0xf02a9ea0,%edx
f0102d4a:	72 12                	jb     f0102d5e <mem_init+0x17ea>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d4c:	50                   	push   %eax
f0102d4d:	68 a4 69 10 f0       	push   $0xf01069a4
f0102d52:	6a 58                	push   $0x58
f0102d54:	68 6b 6f 10 f0       	push   $0xf0106f6b
f0102d59:	e8 e2 d2 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102d5e:	83 ec 04             	sub    $0x4,%esp
f0102d61:	68 00 10 00 00       	push   $0x1000
f0102d66:	6a 02                	push   $0x2
f0102d68:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102d6d:	50                   	push   %eax
f0102d6e:	e8 fb 29 00 00       	call   f010576e <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102d73:	6a 02                	push   $0x2
f0102d75:	68 00 10 00 00       	push   $0x1000
f0102d7a:	57                   	push   %edi
f0102d7b:	ff 35 a4 9e 2a f0    	pushl  0xf02a9ea4
f0102d81:	e8 fe e6 ff ff       	call   f0101484 <page_insert>
	assert(pp1->pp_ref == 1);
f0102d86:	83 c4 20             	add    $0x20,%esp
f0102d89:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102d8e:	74 19                	je     f0102da9 <mem_init+0x1835>
f0102d90:	68 a4 71 10 f0       	push   $0xf01071a4
f0102d95:	68 85 6f 10 f0       	push   $0xf0106f85
f0102d9a:	68 0f 05 00 00       	push   $0x50f
f0102d9f:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102da4:	e8 97 d2 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102da9:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102db0:	01 01 01 
f0102db3:	74 19                	je     f0102dce <mem_init+0x185a>
f0102db5:	68 5c 7c 10 f0       	push   $0xf0107c5c
f0102dba:	68 85 6f 10 f0       	push   $0xf0106f85
f0102dbf:	68 10 05 00 00       	push   $0x510
f0102dc4:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102dc9:	e8 72 d2 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102dce:	6a 02                	push   $0x2
f0102dd0:	68 00 10 00 00       	push   $0x1000
f0102dd5:	56                   	push   %esi
f0102dd6:	ff 35 a4 9e 2a f0    	pushl  0xf02a9ea4
f0102ddc:	e8 a3 e6 ff ff       	call   f0101484 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102de1:	83 c4 10             	add    $0x10,%esp
f0102de4:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102deb:	02 02 02 
f0102dee:	74 19                	je     f0102e09 <mem_init+0x1895>
f0102df0:	68 80 7c 10 f0       	push   $0xf0107c80
f0102df5:	68 85 6f 10 f0       	push   $0xf0106f85
f0102dfa:	68 12 05 00 00       	push   $0x512
f0102dff:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102e04:	e8 37 d2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102e09:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102e0e:	74 19                	je     f0102e29 <mem_init+0x18b5>
f0102e10:	68 c6 71 10 f0       	push   $0xf01071c6
f0102e15:	68 85 6f 10 f0       	push   $0xf0106f85
f0102e1a:	68 13 05 00 00       	push   $0x513
f0102e1f:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102e24:	e8 17 d2 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102e29:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102e2e:	74 19                	je     f0102e49 <mem_init+0x18d5>
f0102e30:	68 30 72 10 f0       	push   $0xf0107230
f0102e35:	68 85 6f 10 f0       	push   $0xf0106f85
f0102e3a:	68 14 05 00 00       	push   $0x514
f0102e3f:	68 5f 6f 10 f0       	push   $0xf0106f5f
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
f0102e55:	2b 05 a8 9e 2a f0    	sub    0xf02a9ea8,%eax
f0102e5b:	c1 f8 03             	sar    $0x3,%eax
f0102e5e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102e61:	89 c2                	mov    %eax,%edx
f0102e63:	c1 ea 0c             	shr    $0xc,%edx
f0102e66:	3b 15 a0 9e 2a f0    	cmp    0xf02a9ea0,%edx
f0102e6c:	72 12                	jb     f0102e80 <mem_init+0x190c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102e6e:	50                   	push   %eax
f0102e6f:	68 a4 69 10 f0       	push   $0xf01069a4
f0102e74:	6a 58                	push   $0x58
f0102e76:	68 6b 6f 10 f0       	push   $0xf0106f6b
f0102e7b:	e8 c0 d1 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102e80:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102e87:	03 03 03 
f0102e8a:	74 19                	je     f0102ea5 <mem_init+0x1931>
f0102e8c:	68 a4 7c 10 f0       	push   $0xf0107ca4
f0102e91:	68 85 6f 10 f0       	push   $0xf0106f85
f0102e96:	68 16 05 00 00       	push   $0x516
f0102e9b:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102ea0:	e8 9b d1 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102ea5:	83 ec 08             	sub    $0x8,%esp
f0102ea8:	68 00 10 00 00       	push   $0x1000
f0102ead:	ff 35 a4 9e 2a f0    	pushl  0xf02a9ea4
f0102eb3:	e8 7f e5 ff ff       	call   f0101437 <page_remove>
	assert(pp2->pp_ref == 0);
f0102eb8:	83 c4 10             	add    $0x10,%esp
f0102ebb:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102ec0:	74 19                	je     f0102edb <mem_init+0x1967>
f0102ec2:	68 fe 71 10 f0       	push   $0xf01071fe
f0102ec7:	68 85 6f 10 f0       	push   $0xf0106f85
f0102ecc:	68 18 05 00 00       	push   $0x518
f0102ed1:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102ed6:	e8 65 d1 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102edb:	8b 0d a4 9e 2a f0    	mov    0xf02a9ea4,%ecx
f0102ee1:	8b 11                	mov    (%ecx),%edx
f0102ee3:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102ee9:	89 d8                	mov    %ebx,%eax
f0102eeb:	2b 05 a8 9e 2a f0    	sub    0xf02a9ea8,%eax
f0102ef1:	c1 f8 03             	sar    $0x3,%eax
f0102ef4:	c1 e0 0c             	shl    $0xc,%eax
f0102ef7:	39 c2                	cmp    %eax,%edx
f0102ef9:	74 19                	je     f0102f14 <mem_init+0x19a0>
f0102efb:	68 2c 76 10 f0       	push   $0xf010762c
f0102f00:	68 85 6f 10 f0       	push   $0xf0106f85
f0102f05:	68 1b 05 00 00       	push   $0x51b
f0102f0a:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102f0f:	e8 2c d1 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102f14:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102f1a:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102f1f:	74 19                	je     f0102f3a <mem_init+0x19c6>
f0102f21:	68 b5 71 10 f0       	push   $0xf01071b5
f0102f26:	68 85 6f 10 f0       	push   $0xf0106f85
f0102f2b:	68 1d 05 00 00       	push   $0x51d
f0102f30:	68 5f 6f 10 f0       	push   $0xf0106f5f
f0102f35:	e8 06 d1 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102f3a:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102f40:	83 ec 0c             	sub    $0xc,%esp
f0102f43:	53                   	push   %ebx
f0102f44:	e8 b9 e1 ff ff       	call   f0101102 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102f49:	c7 04 24 d0 7c 10 f0 	movl   $0xf0107cd0,(%esp)
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
f0102fa8:	a3 3c 92 2a f0       	mov    %eax,0xf02a923c
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
f0102fdc:	89 0d 3c 92 2a f0    	mov    %ecx,0xf02a923c
			cprintf("[-] page [0x%x] error, %d, %d\n", (uint32_t)(*pte), ((uint32_t)(*pte) & perm), perm);
f0102fe2:	8b 00                	mov    (%eax),%eax
f0102fe4:	56                   	push   %esi
f0102fe5:	21 c6                	and    %eax,%esi
f0102fe7:	56                   	push   %esi
f0102fe8:	50                   	push   %eax
f0102fe9:	68 fc 7c 10 f0       	push   $0xf0107cfc
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
f010300f:	89 0d 3c 92 2a f0    	mov    %ecx,0xf02a923c
			cprintf("[-] page [0x%x] perf error, %d, %d\n", (uint32_t)(*pte), ((uint32_t)(*pte) & perm), perm);
f0103015:	56                   	push   %esi
f0103016:	50                   	push   %eax
f0103017:	52                   	push   %edx
f0103018:	68 1c 7d 10 f0       	push   $0xf0107d1c
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
f010306f:	ff 35 3c 92 2a f0    	pushl  0xf02a923c
f0103075:	ff 73 48             	pushl  0x48(%ebx)
f0103078:	68 40 7d 10 f0       	push   $0xf0107d40
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
f01030c8:	68 78 7d 10 f0       	push   $0xf0107d78
f01030cd:	68 2d 01 00 00       	push   $0x12d
f01030d2:	68 3c 7e 10 f0       	push   $0xf0107e3c
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
f01030f0:	68 9c 7d 10 f0       	push   $0xf0107d9c
f01030f5:	68 32 01 00 00       	push   $0x132
f01030fa:	68 3c 7e 10 f0       	push   $0xf0107e3c
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
f0103125:	e8 64 2c 00 00       	call   f0105d8e <cpunum>
f010312a:	6b c0 74             	imul   $0x74,%eax,%eax
f010312d:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
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
f010314a:	03 1d 48 92 2a f0    	add    0xf02a9248,%ebx
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
f010316f:	e8 1a 2c 00 00       	call   f0105d8e <cpunum>
f0103174:	6b c0 74             	imul   $0x74,%eax,%eax
f0103177:	3b 98 28 a0 2a f0    	cmp    -0xfd55fd8(%eax),%ebx
f010317d:	74 26                	je     f01031a5 <envid2env+0x8f>
f010317f:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0103182:	e8 07 2c 00 00       	call   f0105d8e <cpunum>
f0103187:	6b c0 74             	imul   $0x74,%eax,%eax
f010318a:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
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
f01031b6:	b8 20 23 12 f0       	mov    $0xf0122320,%eax
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
f01031e8:	8b 35 48 92 2a f0    	mov    0xf02a9248,%esi
f01031ee:	8b 15 4c 92 2a f0    	mov    0xf02a924c,%edx
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
f0103212:	89 35 4c 92 2a f0    	mov    %esi,0xf02a924c
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
f0103226:	8b 1d 4c 92 2a f0    	mov    0xf02a924c,%ebx
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
f010324b:	2b 05 a8 9e 2a f0    	sub    0xf02a9ea8,%eax
f0103251:	c1 f8 03             	sar    $0x3,%eax
f0103254:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103257:	89 c2                	mov    %eax,%edx
f0103259:	c1 ea 0c             	shr    $0xc,%edx
f010325c:	3b 15 a0 9e 2a f0    	cmp    0xf02a9ea0,%edx
f0103262:	72 12                	jb     f0103276 <env_alloc+0x55>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103264:	50                   	push   %eax
f0103265:	68 a4 69 10 f0       	push   $0xf01069a4
f010326a:	6a 58                	push   $0x58
f010326c:	68 6b 6f 10 f0       	push   $0xf0106f6b
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
f0103286:	ff 35 a4 9e 2a f0    	pushl  0xf02a9ea4
f010328c:	50                   	push   %eax
f010328d:	e8 91 25 00 00       	call   f0105823 <memcpy>
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
f01032a5:	68 c8 69 10 f0       	push   $0xf01069c8
f01032aa:	68 c8 00 00 00       	push   $0xc8
f01032af:	68 3c 7e 10 f0       	push   $0xf0107e3c
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
f01032df:	2b 15 48 92 2a f0    	sub    0xf02a9248,%edx
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
f0103316:	e8 53 24 00 00       	call   f010576e <memset>
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
f010334f:	a3 4c 92 2a f0       	mov    %eax,0xf02a924c
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
f0103395:	68 c4 7d 10 f0       	push   $0xf0107dc4
f010339a:	68 bc 01 00 00       	push   $0x1bc
f010339f:	68 3c 7e 10 f0       	push   $0xf0107e3c
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
f01033ba:	68 e8 7d 10 f0       	push   $0xf0107de8
f01033bf:	68 75 01 00 00       	push   $0x175
f01033c4:	68 3c 7e 10 f0       	push   $0xf0107e3c
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
f01033ea:	68 c8 69 10 f0       	push   $0xf01069c8
f01033ef:	68 7e 01 00 00       	push   $0x17e
f01033f4:	68 3c 7e 10 f0       	push   $0xf0107e3c
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
f0103418:	68 10 7e 10 f0       	push   $0xf0107e10
f010341d:	68 87 01 00 00       	push   $0x187
f0103422:	68 3c 7e 10 f0       	push   $0xf0107e3c
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
f0103442:	e8 27 23 00 00       	call   f010576e <memset>

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
f0103456:	e8 c8 23 00 00       	call   f0105823 <memcpy>
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
f010347f:	a1 a4 9e 2a f0       	mov    0xf02a9ea4,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103484:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103489:	77 15                	ja     f01034a0 <env_create+0x12a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010348b:	50                   	push   %eax
f010348c:	68 c8 69 10 f0       	push   $0xf01069c8
f0103491:	68 a5 01 00 00       	push   $0x1a5
f0103496:	68 3c 7e 10 f0       	push   $0xf0107e3c
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
f01034d1:	e8 b8 28 00 00       	call   f0105d8e <cpunum>
f01034d6:	6b c0 74             	imul   $0x74,%eax,%eax
f01034d9:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01034e0:	39 b8 28 a0 2a f0    	cmp    %edi,-0xfd55fd8(%eax)
f01034e6:	75 30                	jne    f0103518 <env_free+0x53>
		lcr3(PADDR(kern_pgdir));
f01034e8:	a1 a4 9e 2a f0       	mov    0xf02a9ea4,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01034ed:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01034f2:	77 15                	ja     f0103509 <env_free+0x44>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01034f4:	50                   	push   %eax
f01034f5:	68 c8 69 10 f0       	push   $0xf01069c8
f01034fa:	68 d4 01 00 00       	push   $0x1d4
f01034ff:	68 3c 7e 10 f0       	push   $0xf0107e3c
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
f0103543:	39 05 a0 9e 2a f0    	cmp    %eax,0xf02a9ea0
f0103549:	77 15                	ja     f0103560 <env_free+0x9b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010354b:	56                   	push   %esi
f010354c:	68 a4 69 10 f0       	push   $0xf01069a4
f0103551:	68 e3 01 00 00       	push   $0x1e3
f0103556:	68 3c 7e 10 f0       	push   $0xf0107e3c
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
f01035aa:	3b 05 a0 9e 2a f0    	cmp    0xf02a9ea0,%eax
f01035b0:	72 14                	jb     f01035c6 <env_free+0x101>
		panic("pa2page called with invalid pa");
f01035b2:	83 ec 04             	sub    $0x4,%esp
f01035b5:	68 d4 74 10 f0       	push   $0xf01074d4
f01035ba:	6a 51                	push   $0x51
f01035bc:	68 6b 6f 10 f0       	push   $0xf0106f6b
f01035c1:	e8 7a ca ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f01035c6:	83 ec 0c             	sub    $0xc,%esp
f01035c9:	a1 a8 9e 2a f0       	mov    0xf02a9ea8,%eax
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
f01035fa:	68 c8 69 10 f0       	push   $0xf01069c8
f01035ff:	68 f1 01 00 00       	push   $0x1f1
f0103604:	68 3c 7e 10 f0       	push   $0xf0107e3c
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
f010361d:	3b 05 a0 9e 2a f0    	cmp    0xf02a9ea0,%eax
f0103623:	72 14                	jb     f0103639 <env_free+0x174>
		panic("pa2page called with invalid pa");
f0103625:	83 ec 04             	sub    $0x4,%esp
f0103628:	68 d4 74 10 f0       	push   $0xf01074d4
f010362d:	6a 51                	push   $0x51
f010362f:	68 6b 6f 10 f0       	push   $0xf0106f6b
f0103634:	e8 07 ca ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f0103639:	83 ec 0c             	sub    $0xc,%esp
f010363c:	8b 15 a8 9e 2a f0    	mov    0xf02a9ea8,%edx
f0103642:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103645:	50                   	push   %eax
f0103646:	e8 0d db ff ff       	call   f0101158 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f010364b:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103652:	a1 4c 92 2a f0       	mov    0xf02a924c,%eax
f0103657:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f010365a:	89 3d 4c 92 2a f0    	mov    %edi,0xf02a924c
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
f010367b:	e8 0e 27 00 00       	call   f0105d8e <cpunum>
f0103680:	6b c0 74             	imul   $0x74,%eax,%eax
f0103683:	3b 98 28 a0 2a f0    	cmp    -0xfd55fd8(%eax),%ebx
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
f010369d:	e8 ec 26 00 00       	call   f0105d8e <cpunum>
f01036a2:	6b c0 74             	imul   $0x74,%eax,%eax
f01036a5:	83 c4 10             	add    $0x10,%esp
f01036a8:	3b 98 28 a0 2a f0    	cmp    -0xfd55fd8(%eax),%ebx
f01036ae:	75 17                	jne    f01036c7 <env_destroy+0x5c>
		curenv = NULL;
f01036b0:	e8 d9 26 00 00       	call   f0105d8e <cpunum>
f01036b5:	6b c0 74             	imul   $0x74,%eax,%eax
f01036b8:	c7 80 28 a0 2a f0 00 	movl   $0x0,-0xfd55fd8(%eax)
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
f01036d3:	e8 b6 26 00 00       	call   f0105d8e <cpunum>
f01036d8:	6b c0 74             	imul   $0x74,%eax,%eax
f01036db:	8b 98 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%ebx
f01036e1:	e8 a8 26 00 00       	call   f0105d8e <cpunum>
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
f01036f6:	68 47 7e 10 f0       	push   $0xf0107e47
f01036fb:	68 28 02 00 00       	push   $0x228
f0103700:	68 3c 7e 10 f0       	push   $0xf0107e3c
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
f0103714:	e8 75 26 00 00       	call   f0105d8e <cpunum>
f0103719:	6b c0 74             	imul   $0x74,%eax,%eax
f010371c:	39 98 28 a0 2a f0    	cmp    %ebx,-0xfd55fd8(%eax)
f0103722:	74 3a                	je     f010375e <env_run+0x54>

		if (curenv != NULL && curenv->env_status == ENV_RUNNING)
f0103724:	e8 65 26 00 00       	call   f0105d8e <cpunum>
f0103729:	6b c0 74             	imul   $0x74,%eax,%eax
f010372c:	83 b8 28 a0 2a f0 00 	cmpl   $0x0,-0xfd55fd8(%eax)
f0103733:	74 29                	je     f010375e <env_run+0x54>
f0103735:	e8 54 26 00 00       	call   f0105d8e <cpunum>
f010373a:	6b c0 74             	imul   $0x74,%eax,%eax
f010373d:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
f0103743:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103747:	75 15                	jne    f010375e <env_run+0x54>
			curenv->env_status = ENV_RUNNABLE;
f0103749:	e8 40 26 00 00       	call   f0105d8e <cpunum>
f010374e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103751:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
f0103757:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
			
	}
	
	curenv = e;
f010375e:	e8 2b 26 00 00       	call   f0105d8e <cpunum>
f0103763:	6b c0 74             	imul   $0x74,%eax,%eax
f0103766:	89 98 28 a0 2a f0    	mov    %ebx,-0xfd55fd8(%eax)
	curenv->env_status = ENV_RUNNING;
f010376c:	e8 1d 26 00 00       	call   f0105d8e <cpunum>
f0103771:	6b c0 74             	imul   $0x74,%eax,%eax
f0103774:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
f010377a:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f0103781:	e8 08 26 00 00       	call   f0105d8e <cpunum>
f0103786:	6b c0 74             	imul   $0x74,%eax,%eax
f0103789:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
f010378f:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3(PADDR(curenv->env_pgdir));
f0103793:	e8 f6 25 00 00       	call   f0105d8e <cpunum>
f0103798:	6b c0 74             	imul   $0x74,%eax,%eax
f010379b:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
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
f01037ac:	68 c8 69 10 f0       	push   $0xf01069c8
f01037b1:	68 52 02 00 00       	push   $0x252
f01037b6:	68 3c 7e 10 f0       	push   $0xf0107e3c
f01037bb:	e8 80 c8 ff ff       	call   f0100040 <_panic>
f01037c0:	05 00 00 00 10       	add    $0x10000000,%eax
f01037c5:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01037c8:	83 ec 0c             	sub    $0xc,%esp
f01037cb:	68 c0 23 12 f0       	push   $0xf01223c0
f01037d0:	e8 c4 28 00 00       	call   f0106099 <spin_unlock>

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
f01037d7:	e8 b2 25 00 00       	call   f0105d8e <cpunum>
f01037dc:	83 c4 04             	add    $0x4,%esp
f01037df:	6b c0 74             	imul   $0x74,%eax,%eax
f01037e2:	ff b0 28 a0 2a f0    	pushl  -0xfd55fd8(%eax)
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
f0103823:	66 a3 a8 23 12 f0    	mov    %ax,0xf01223a8
	if (!didinit)
f0103829:	80 3d 50 92 2a f0 00 	cmpb   $0x0,0xf02a9250
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
f0103847:	68 53 7e 10 f0       	push   $0xf0107e53
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
f0103867:	68 ef 82 10 f0       	push   $0xf01082ef
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
f010387f:	68 99 72 10 f0       	push   $0xf0107299
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
f0103893:	c6 05 50 92 2a f0 01 	movb   $0x1,0xf02a9250
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
f0103911:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
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
f0103978:	e8 6d 17 00 00       	call   f01050ea <vprintfmt>
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
f010399f:	e8 ea 23 00 00       	call   f0105d8e <cpunum>
f01039a4:	89 c3                	mov    %eax,%ebx
f01039a6:	e8 e3 23 00 00       	call   f0105d8e <cpunum>
f01039ab:	6b db 74             	imul   $0x74,%ebx,%ebx
f01039ae:	c1 e0 0f             	shl    $0xf,%eax
f01039b1:	05 00 b0 2a f0       	add    $0xf02ab000,%eax
f01039b6:	89 83 30 a0 2a f0    	mov    %eax,-0xfd55fd0(%ebx)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f01039bc:	e8 cd 23 00 00       	call   f0105d8e <cpunum>
f01039c1:	6b c0 74             	imul   $0x74,%eax,%eax
f01039c4:	66 c7 80 34 a0 2a f0 	movw   $0x10,-0xfd55fcc(%eax)
f01039cb:	10 00 
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f01039cd:	e8 bc 23 00 00       	call   f0105d8e <cpunum>
f01039d2:	6b c0 74             	imul   $0x74,%eax,%eax
f01039d5:	66 c7 80 92 a0 2a f0 	movw   $0x68,-0xfd55f6e(%eax)
f01039dc:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + cpunum()] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
f01039de:	e8 ab 23 00 00       	call   f0105d8e <cpunum>
f01039e3:	8d 58 05             	lea    0x5(%eax),%ebx
f01039e6:	e8 a3 23 00 00       	call   f0105d8e <cpunum>
f01039eb:	89 c7                	mov    %eax,%edi
f01039ed:	e8 9c 23 00 00       	call   f0105d8e <cpunum>
f01039f2:	89 c6                	mov    %eax,%esi
f01039f4:	e8 95 23 00 00       	call   f0105d8e <cpunum>
f01039f9:	66 c7 04 dd 40 23 12 	movw   $0x67,-0xfeddcc0(,%ebx,8)
f0103a00:	f0 67 00 
f0103a03:	6b ff 74             	imul   $0x74,%edi,%edi
f0103a06:	81 c7 2c a0 2a f0    	add    $0xf02aa02c,%edi
f0103a0c:	66 89 3c dd 42 23 12 	mov    %di,-0xfeddcbe(,%ebx,8)
f0103a13:	f0 
f0103a14:	6b d6 74             	imul   $0x74,%esi,%edx
f0103a17:	81 c2 2c a0 2a f0    	add    $0xf02aa02c,%edx
f0103a1d:	c1 ea 10             	shr    $0x10,%edx
f0103a20:	88 14 dd 44 23 12 f0 	mov    %dl,-0xfeddcbc(,%ebx,8)
f0103a27:	c6 04 dd 45 23 12 f0 	movb   $0x99,-0xfeddcbb(,%ebx,8)
f0103a2e:	99 
f0103a2f:	c6 04 dd 46 23 12 f0 	movb   $0x40,-0xfeddcba(,%ebx,8)
f0103a36:	40 
f0103a37:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a3a:	05 2c a0 2a f0       	add    $0xf02aa02c,%eax
f0103a3f:	c1 e8 18             	shr    $0x18,%eax
f0103a42:	88 04 dd 47 23 12 f0 	mov    %al,-0xfeddcb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + cpunum()].sd_s = 0;
f0103a49:	e8 40 23 00 00       	call   f0105d8e <cpunum>
f0103a4e:	80 24 c5 6d 23 12 f0 	andb   $0xef,-0xfeddc93(,%eax,8)
f0103a55:	ef 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + (cpunum() << 3));
f0103a56:	e8 33 23 00 00       	call   f0105d8e <cpunum>
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
f0103a65:	b8 ac 23 12 f0       	mov    $0xf01223ac,%eax
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
f0103a80:	66 a3 60 92 2a f0    	mov    %ax,0xf02a9260
f0103a86:	66 c7 05 62 92 2a f0 	movw   $0x8,0xf02a9262
f0103a8d:	08 00 
f0103a8f:	c6 05 64 92 2a f0 00 	movb   $0x0,0xf02a9264
f0103a96:	c6 05 65 92 2a f0 8e 	movb   $0x8e,0xf02a9265
f0103a9d:	c1 e8 10             	shr    $0x10,%eax
f0103aa0:	66 a3 66 92 2a f0    	mov    %ax,0xf02a9266
	SETGATE(idt[T_DEBUG], 0, GD_KT, _T_DEBUG_handler, 0);
f0103aa6:	b8 6a 44 10 f0       	mov    $0xf010446a,%eax
f0103aab:	66 a3 68 92 2a f0    	mov    %ax,0xf02a9268
f0103ab1:	66 c7 05 6a 92 2a f0 	movw   $0x8,0xf02a926a
f0103ab8:	08 00 
f0103aba:	c6 05 6c 92 2a f0 00 	movb   $0x0,0xf02a926c
f0103ac1:	c6 05 6d 92 2a f0 8e 	movb   $0x8e,0xf02a926d
f0103ac8:	c1 e8 10             	shr    $0x10,%eax
f0103acb:	66 a3 6e 92 2a f0    	mov    %ax,0xf02a926e
	SETGATE(idt[T_NMI], 0, GD_KT, _T_NMI_handler, 0);
f0103ad1:	b8 70 44 10 f0       	mov    $0xf0104470,%eax
f0103ad6:	66 a3 70 92 2a f0    	mov    %ax,0xf02a9270
f0103adc:	66 c7 05 72 92 2a f0 	movw   $0x8,0xf02a9272
f0103ae3:	08 00 
f0103ae5:	c6 05 74 92 2a f0 00 	movb   $0x0,0xf02a9274
f0103aec:	c6 05 75 92 2a f0 8e 	movb   $0x8e,0xf02a9275
f0103af3:	c1 e8 10             	shr    $0x10,%eax
f0103af6:	66 a3 76 92 2a f0    	mov    %ax,0xf02a9276
	SETGATE(idt[T_BRKPT], 0, GD_KT, _T_BRKPT_handler, 3);
f0103afc:	b8 76 44 10 f0       	mov    $0xf0104476,%eax
f0103b01:	66 a3 78 92 2a f0    	mov    %ax,0xf02a9278
f0103b07:	66 c7 05 7a 92 2a f0 	movw   $0x8,0xf02a927a
f0103b0e:	08 00 
f0103b10:	c6 05 7c 92 2a f0 00 	movb   $0x0,0xf02a927c
f0103b17:	c6 05 7d 92 2a f0 ee 	movb   $0xee,0xf02a927d
f0103b1e:	c1 e8 10             	shr    $0x10,%eax
f0103b21:	66 a3 7e 92 2a f0    	mov    %ax,0xf02a927e
	SETGATE(idt[T_OFLOW], 0, GD_KT, _T_OFLOW_handler, 0);
f0103b27:	b8 7c 44 10 f0       	mov    $0xf010447c,%eax
f0103b2c:	66 a3 80 92 2a f0    	mov    %ax,0xf02a9280
f0103b32:	66 c7 05 82 92 2a f0 	movw   $0x8,0xf02a9282
f0103b39:	08 00 
f0103b3b:	c6 05 84 92 2a f0 00 	movb   $0x0,0xf02a9284
f0103b42:	c6 05 85 92 2a f0 8e 	movb   $0x8e,0xf02a9285
f0103b49:	c1 e8 10             	shr    $0x10,%eax
f0103b4c:	66 a3 86 92 2a f0    	mov    %ax,0xf02a9286
	SETGATE(idt[T_BOUND], 0, GD_KT, _T_BOUND_handler, 0);
f0103b52:	b8 82 44 10 f0       	mov    $0xf0104482,%eax
f0103b57:	66 a3 88 92 2a f0    	mov    %ax,0xf02a9288
f0103b5d:	66 c7 05 8a 92 2a f0 	movw   $0x8,0xf02a928a
f0103b64:	08 00 
f0103b66:	c6 05 8c 92 2a f0 00 	movb   $0x0,0xf02a928c
f0103b6d:	c6 05 8d 92 2a f0 8e 	movb   $0x8e,0xf02a928d
f0103b74:	c1 e8 10             	shr    $0x10,%eax
f0103b77:	66 a3 8e 92 2a f0    	mov    %ax,0xf02a928e
	SETGATE(idt[T_ILLOP], 0, GD_KT, _T_ILLOP_handler, 0);
f0103b7d:	b8 88 44 10 f0       	mov    $0xf0104488,%eax
f0103b82:	66 a3 90 92 2a f0    	mov    %ax,0xf02a9290
f0103b88:	66 c7 05 92 92 2a f0 	movw   $0x8,0xf02a9292
f0103b8f:	08 00 
f0103b91:	c6 05 94 92 2a f0 00 	movb   $0x0,0xf02a9294
f0103b98:	c6 05 95 92 2a f0 8e 	movb   $0x8e,0xf02a9295
f0103b9f:	c1 e8 10             	shr    $0x10,%eax
f0103ba2:	66 a3 96 92 2a f0    	mov    %ax,0xf02a9296
	SETGATE(idt[T_DEVICE], 0, GD_KT, _T_DEVICE_handler, 0);
f0103ba8:	b8 8e 44 10 f0       	mov    $0xf010448e,%eax
f0103bad:	66 a3 98 92 2a f0    	mov    %ax,0xf02a9298
f0103bb3:	66 c7 05 9a 92 2a f0 	movw   $0x8,0xf02a929a
f0103bba:	08 00 
f0103bbc:	c6 05 9c 92 2a f0 00 	movb   $0x0,0xf02a929c
f0103bc3:	c6 05 9d 92 2a f0 8e 	movb   $0x8e,0xf02a929d
f0103bca:	c1 e8 10             	shr    $0x10,%eax
f0103bcd:	66 a3 9e 92 2a f0    	mov    %ax,0xf02a929e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, _T_DBLFLT_handler, 0);
f0103bd3:	b8 94 44 10 f0       	mov    $0xf0104494,%eax
f0103bd8:	66 a3 a0 92 2a f0    	mov    %ax,0xf02a92a0
f0103bde:	66 c7 05 a2 92 2a f0 	movw   $0x8,0xf02a92a2
f0103be5:	08 00 
f0103be7:	c6 05 a4 92 2a f0 00 	movb   $0x0,0xf02a92a4
f0103bee:	c6 05 a5 92 2a f0 8e 	movb   $0x8e,0xf02a92a5
f0103bf5:	c1 e8 10             	shr    $0x10,%eax
f0103bf8:	66 a3 a6 92 2a f0    	mov    %ax,0xf02a92a6
	SETGATE(idt[T_TSS], 0, GD_KT, _T_TSS_handler, 0);
f0103bfe:	b8 98 44 10 f0       	mov    $0xf0104498,%eax
f0103c03:	66 a3 b0 92 2a f0    	mov    %ax,0xf02a92b0
f0103c09:	66 c7 05 b2 92 2a f0 	movw   $0x8,0xf02a92b2
f0103c10:	08 00 
f0103c12:	c6 05 b4 92 2a f0 00 	movb   $0x0,0xf02a92b4
f0103c19:	c6 05 b5 92 2a f0 8e 	movb   $0x8e,0xf02a92b5
f0103c20:	c1 e8 10             	shr    $0x10,%eax
f0103c23:	66 a3 b6 92 2a f0    	mov    %ax,0xf02a92b6
	SETGATE(idt[T_SEGNP], 0, GD_KT, _T_SEGNP_handler, 0);
f0103c29:	b8 9c 44 10 f0       	mov    $0xf010449c,%eax
f0103c2e:	66 a3 b8 92 2a f0    	mov    %ax,0xf02a92b8
f0103c34:	66 c7 05 ba 92 2a f0 	movw   $0x8,0xf02a92ba
f0103c3b:	08 00 
f0103c3d:	c6 05 bc 92 2a f0 00 	movb   $0x0,0xf02a92bc
f0103c44:	c6 05 bd 92 2a f0 8e 	movb   $0x8e,0xf02a92bd
f0103c4b:	c1 e8 10             	shr    $0x10,%eax
f0103c4e:	66 a3 be 92 2a f0    	mov    %ax,0xf02a92be
	SETGATE(idt[T_STACK], 0, GD_KT, _T_STACK_handler, 0);
f0103c54:	b8 a0 44 10 f0       	mov    $0xf01044a0,%eax
f0103c59:	66 a3 c0 92 2a f0    	mov    %ax,0xf02a92c0
f0103c5f:	66 c7 05 c2 92 2a f0 	movw   $0x8,0xf02a92c2
f0103c66:	08 00 
f0103c68:	c6 05 c4 92 2a f0 00 	movb   $0x0,0xf02a92c4
f0103c6f:	c6 05 c5 92 2a f0 8e 	movb   $0x8e,0xf02a92c5
f0103c76:	c1 e8 10             	shr    $0x10,%eax
f0103c79:	66 a3 c6 92 2a f0    	mov    %ax,0xf02a92c6
	SETGATE(idt[T_GPFLT], 0, GD_KT, _T_GPFLT_handler, 0);
f0103c7f:	b8 a4 44 10 f0       	mov    $0xf01044a4,%eax
f0103c84:	66 a3 c8 92 2a f0    	mov    %ax,0xf02a92c8
f0103c8a:	66 c7 05 ca 92 2a f0 	movw   $0x8,0xf02a92ca
f0103c91:	08 00 
f0103c93:	c6 05 cc 92 2a f0 00 	movb   $0x0,0xf02a92cc
f0103c9a:	c6 05 cd 92 2a f0 8e 	movb   $0x8e,0xf02a92cd
f0103ca1:	c1 e8 10             	shr    $0x10,%eax
f0103ca4:	66 a3 ce 92 2a f0    	mov    %ax,0xf02a92ce
	SETGATE(idt[T_PGFLT], 0, GD_KT, _T_PGFLT_handler, 0);
f0103caa:	b8 a8 44 10 f0       	mov    $0xf01044a8,%eax
f0103caf:	66 a3 d0 92 2a f0    	mov    %ax,0xf02a92d0
f0103cb5:	66 c7 05 d2 92 2a f0 	movw   $0x8,0xf02a92d2
f0103cbc:	08 00 
f0103cbe:	c6 05 d4 92 2a f0 00 	movb   $0x0,0xf02a92d4
f0103cc5:	c6 05 d5 92 2a f0 8e 	movb   $0x8e,0xf02a92d5
f0103ccc:	c1 e8 10             	shr    $0x10,%eax
f0103ccf:	66 a3 d6 92 2a f0    	mov    %ax,0xf02a92d6
	SETGATE(idt[T_FPERR], 0, GD_KT, _T_FPERR_handler, 0);
f0103cd5:	b8 ac 44 10 f0       	mov    $0xf01044ac,%eax
f0103cda:	66 a3 e0 92 2a f0    	mov    %ax,0xf02a92e0
f0103ce0:	66 c7 05 e2 92 2a f0 	movw   $0x8,0xf02a92e2
f0103ce7:	08 00 
f0103ce9:	c6 05 e4 92 2a f0 00 	movb   $0x0,0xf02a92e4
f0103cf0:	c6 05 e5 92 2a f0 8e 	movb   $0x8e,0xf02a92e5
f0103cf7:	c1 e8 10             	shr    $0x10,%eax
f0103cfa:	66 a3 e6 92 2a f0    	mov    %ax,0xf02a92e6
	SETGATE(idt[T_ALIGN], 0, GD_KT, _T_ALIGN_handler, 0);
f0103d00:	b8 b2 44 10 f0       	mov    $0xf01044b2,%eax
f0103d05:	66 a3 e8 92 2a f0    	mov    %ax,0xf02a92e8
f0103d0b:	66 c7 05 ea 92 2a f0 	movw   $0x8,0xf02a92ea
f0103d12:	08 00 
f0103d14:	c6 05 ec 92 2a f0 00 	movb   $0x0,0xf02a92ec
f0103d1b:	c6 05 ed 92 2a f0 8e 	movb   $0x8e,0xf02a92ed
f0103d22:	c1 e8 10             	shr    $0x10,%eax
f0103d25:	66 a3 ee 92 2a f0    	mov    %ax,0xf02a92ee
	SETGATE(idt[T_MCHK], 0, GD_KT, _T_MCHK_handler, 0);
f0103d2b:	b8 b6 44 10 f0       	mov    $0xf01044b6,%eax
f0103d30:	66 a3 f0 92 2a f0    	mov    %ax,0xf02a92f0
f0103d36:	66 c7 05 f2 92 2a f0 	movw   $0x8,0xf02a92f2
f0103d3d:	08 00 
f0103d3f:	c6 05 f4 92 2a f0 00 	movb   $0x0,0xf02a92f4
f0103d46:	c6 05 f5 92 2a f0 8e 	movb   $0x8e,0xf02a92f5
f0103d4d:	c1 e8 10             	shr    $0x10,%eax
f0103d50:	66 a3 f6 92 2a f0    	mov    %ax,0xf02a92f6
	SETGATE(idt[T_SIMDERR], 0, GD_KT, _T_SIMDERR_handler, 0);
f0103d56:	b8 bc 44 10 f0       	mov    $0xf01044bc,%eax
f0103d5b:	66 a3 f8 92 2a f0    	mov    %ax,0xf02a92f8
f0103d61:	66 c7 05 fa 92 2a f0 	movw   $0x8,0xf02a92fa
f0103d68:	08 00 
f0103d6a:	c6 05 fc 92 2a f0 00 	movb   $0x0,0xf02a92fc
f0103d71:	c6 05 fd 92 2a f0 8e 	movb   $0x8e,0xf02a92fd
f0103d78:	c1 e8 10             	shr    $0x10,%eax
f0103d7b:	66 a3 fe 92 2a f0    	mov    %ax,0xf02a92fe
	SETGATE(idt[T_SYSCALL], 0, GD_KT, _T_SYSCALL_handler, 3);
f0103d81:	b8 c2 44 10 f0       	mov    $0xf01044c2,%eax
f0103d86:	66 a3 e0 93 2a f0    	mov    %ax,0xf02a93e0
f0103d8c:	66 c7 05 e2 93 2a f0 	movw   $0x8,0xf02a93e2
f0103d93:	08 00 
f0103d95:	c6 05 e4 93 2a f0 00 	movb   $0x0,0xf02a93e4
f0103d9c:	c6 05 e5 93 2a f0 ee 	movb   $0xee,0xf02a93e5
f0103da3:	c1 e8 10             	shr    $0x10,%eax
f0103da6:	66 a3 e6 93 2a f0    	mov    %ax,0xf02a93e6

	SETGATE(idt[IRQ_TIMER + IRQ_OFFSET], 0, GD_KT, _IRQ_TIMER_handler, 0);
f0103dac:	b8 c8 44 10 f0       	mov    $0xf01044c8,%eax
f0103db1:	66 a3 60 93 2a f0    	mov    %ax,0xf02a9360
f0103db7:	66 c7 05 62 93 2a f0 	movw   $0x8,0xf02a9362
f0103dbe:	08 00 
f0103dc0:	c6 05 64 93 2a f0 00 	movb   $0x0,0xf02a9364
f0103dc7:	c6 05 65 93 2a f0 8e 	movb   $0x8e,0xf02a9365
f0103dce:	c1 e8 10             	shr    $0x10,%eax
f0103dd1:	66 a3 66 93 2a f0    	mov    %ax,0xf02a9366
	SETGATE(idt[IRQ_KBD + IRQ_OFFSET], 0, GD_KT, _IRQ_KBD_handler, 0);
f0103dd7:	b8 ce 44 10 f0       	mov    $0xf01044ce,%eax
f0103ddc:	66 a3 68 93 2a f0    	mov    %ax,0xf02a9368
f0103de2:	66 c7 05 6a 93 2a f0 	movw   $0x8,0xf02a936a
f0103de9:	08 00 
f0103deb:	c6 05 6c 93 2a f0 00 	movb   $0x0,0xf02a936c
f0103df2:	c6 05 6d 93 2a f0 8e 	movb   $0x8e,0xf02a936d
f0103df9:	c1 e8 10             	shr    $0x10,%eax
f0103dfc:	66 a3 6e 93 2a f0    	mov    %ax,0xf02a936e
	SETGATE(idt[IRQ_SERIAL + IRQ_OFFSET], 0, GD_KT, _IRQ_SERIAL_handler, 0);
f0103e02:	b8 d4 44 10 f0       	mov    $0xf01044d4,%eax
f0103e07:	66 a3 80 93 2a f0    	mov    %ax,0xf02a9380
f0103e0d:	66 c7 05 82 93 2a f0 	movw   $0x8,0xf02a9382
f0103e14:	08 00 
f0103e16:	c6 05 84 93 2a f0 00 	movb   $0x0,0xf02a9384
f0103e1d:	c6 05 85 93 2a f0 8e 	movb   $0x8e,0xf02a9385
f0103e24:	c1 e8 10             	shr    $0x10,%eax
f0103e27:	66 a3 86 93 2a f0    	mov    %ax,0xf02a9386
	SETGATE(idt[IRQ_SPURIOUS + IRQ_OFFSET], 0, GD_KT, _IRQ_SPURIOUS_handler, 0);
f0103e2d:	b8 da 44 10 f0       	mov    $0xf01044da,%eax
f0103e32:	66 a3 98 93 2a f0    	mov    %ax,0xf02a9398
f0103e38:	66 c7 05 9a 93 2a f0 	movw   $0x8,0xf02a939a
f0103e3f:	08 00 
f0103e41:	c6 05 9c 93 2a f0 00 	movb   $0x0,0xf02a939c
f0103e48:	c6 05 9d 93 2a f0 8e 	movb   $0x8e,0xf02a939d
f0103e4f:	c1 e8 10             	shr    $0x10,%eax
f0103e52:	66 a3 9e 93 2a f0    	mov    %ax,0xf02a939e
	SETGATE(idt[IRQ_IDE + IRQ_OFFSET], 0, GD_KT, _IRQ_IDE_handler, 0);
f0103e58:	b8 e0 44 10 f0       	mov    $0xf01044e0,%eax
f0103e5d:	66 a3 d0 93 2a f0    	mov    %ax,0xf02a93d0
f0103e63:	66 c7 05 d2 93 2a f0 	movw   $0x8,0xf02a93d2
f0103e6a:	08 00 
f0103e6c:	c6 05 d4 93 2a f0 00 	movb   $0x0,0xf02a93d4
f0103e73:	c6 05 d5 93 2a f0 8e 	movb   $0x8e,0xf02a93d5
f0103e7a:	c1 e8 10             	shr    $0x10,%eax
f0103e7d:	66 a3 d6 93 2a f0    	mov    %ax,0xf02a93d6
	SETGATE(idt[IRQ_ERROR + IRQ_OFFSET], 0, GD_KT, _IRQ_ERROR_handler, 0);
f0103e83:	b8 e6 44 10 f0       	mov    $0xf01044e6,%eax
f0103e88:	66 a3 f8 93 2a f0    	mov    %ax,0xf02a93f8
f0103e8e:	66 c7 05 fa 93 2a f0 	movw   $0x8,0xf02a93fa
f0103e95:	08 00 
f0103e97:	c6 05 fc 93 2a f0 00 	movb   $0x0,0xf02a93fc
f0103e9e:	c6 05 fd 93 2a f0 8e 	movb   $0x8e,0xf02a93fd
f0103ea5:	c1 e8 10             	shr    $0x10,%eax
f0103ea8:	66 a3 fe 93 2a f0    	mov    %ax,0xf02a93fe

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
f0103ec1:	68 67 7e 10 f0       	push   $0xf0107e67
f0103ec6:	e8 b7 fa ff ff       	call   f0103982 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103ecb:	83 c4 08             	add    $0x8,%esp
f0103ece:	ff 73 04             	pushl  0x4(%ebx)
f0103ed1:	68 76 7e 10 f0       	push   $0xf0107e76
f0103ed6:	e8 a7 fa ff ff       	call   f0103982 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103edb:	83 c4 08             	add    $0x8,%esp
f0103ede:	ff 73 08             	pushl  0x8(%ebx)
f0103ee1:	68 85 7e 10 f0       	push   $0xf0107e85
f0103ee6:	e8 97 fa ff ff       	call   f0103982 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103eeb:	83 c4 08             	add    $0x8,%esp
f0103eee:	ff 73 0c             	pushl  0xc(%ebx)
f0103ef1:	68 94 7e 10 f0       	push   $0xf0107e94
f0103ef6:	e8 87 fa ff ff       	call   f0103982 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103efb:	83 c4 08             	add    $0x8,%esp
f0103efe:	ff 73 10             	pushl  0x10(%ebx)
f0103f01:	68 a3 7e 10 f0       	push   $0xf0107ea3
f0103f06:	e8 77 fa ff ff       	call   f0103982 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103f0b:	83 c4 08             	add    $0x8,%esp
f0103f0e:	ff 73 14             	pushl  0x14(%ebx)
f0103f11:	68 b2 7e 10 f0       	push   $0xf0107eb2
f0103f16:	e8 67 fa ff ff       	call   f0103982 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103f1b:	83 c4 08             	add    $0x8,%esp
f0103f1e:	ff 73 18             	pushl  0x18(%ebx)
f0103f21:	68 c1 7e 10 f0       	push   $0xf0107ec1
f0103f26:	e8 57 fa ff ff       	call   f0103982 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103f2b:	83 c4 08             	add    $0x8,%esp
f0103f2e:	ff 73 1c             	pushl  0x1c(%ebx)
f0103f31:	68 d0 7e 10 f0       	push   $0xf0107ed0
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
f0103f4b:	e8 3e 1e 00 00       	call   f0105d8e <cpunum>
f0103f50:	83 ec 04             	sub    $0x4,%esp
f0103f53:	50                   	push   %eax
f0103f54:	53                   	push   %ebx
f0103f55:	68 34 7f 10 f0       	push   $0xf0107f34
f0103f5a:	e8 23 fa ff ff       	call   f0103982 <cprintf>
	print_regs(&tf->tf_regs);
f0103f5f:	89 1c 24             	mov    %ebx,(%esp)
f0103f62:	e8 4e ff ff ff       	call   f0103eb5 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103f67:	83 c4 08             	add    $0x8,%esp
f0103f6a:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103f6e:	50                   	push   %eax
f0103f6f:	68 52 7f 10 f0       	push   $0xf0107f52
f0103f74:	e8 09 fa ff ff       	call   f0103982 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103f79:	83 c4 08             	add    $0x8,%esp
f0103f7c:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103f80:	50                   	push   %eax
f0103f81:	68 65 7f 10 f0       	push   $0xf0107f65
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
f0103f96:	8b 14 85 00 82 10 f0 	mov    -0xfef7e00(,%eax,4),%edx
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
f0103faa:	b9 fe 7e 10 f0       	mov    $0xf0107efe,%ecx
f0103faf:	ba eb 7e 10 f0       	mov    $0xf0107eeb,%edx
f0103fb4:	0f 43 d1             	cmovae %ecx,%edx
f0103fb7:	eb 05                	jmp    f0103fbe <print_trapframe+0x7b>
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0103fb9:	ba df 7e 10 f0       	mov    $0xf0107edf,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103fbe:	83 ec 04             	sub    $0x4,%esp
f0103fc1:	52                   	push   %edx
f0103fc2:	50                   	push   %eax
f0103fc3:	68 78 7f 10 f0       	push   $0xf0107f78
f0103fc8:	e8 b5 f9 ff ff       	call   f0103982 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103fcd:	83 c4 10             	add    $0x10,%esp
f0103fd0:	3b 1d 60 9a 2a f0    	cmp    0xf02a9a60,%ebx
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
f0103fe5:	68 8a 7f 10 f0       	push   $0xf0107f8a
f0103fea:	e8 93 f9 ff ff       	call   f0103982 <cprintf>
f0103fef:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103ff2:	83 ec 08             	sub    $0x8,%esp
f0103ff5:	ff 73 2c             	pushl  0x2c(%ebx)
f0103ff8:	68 99 7f 10 f0       	push   $0xf0107f99
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
f0104013:	ba 18 7f 10 f0       	mov    $0xf0107f18,%edx
f0104018:	b9 0d 7f 10 f0       	mov    $0xf0107f0d,%ecx
f010401d:	0f 44 ca             	cmove  %edx,%ecx
f0104020:	89 c2                	mov    %eax,%edx
f0104022:	83 e2 02             	and    $0x2,%edx
f0104025:	ba 2a 7f 10 f0       	mov    $0xf0107f2a,%edx
f010402a:	be 24 7f 10 f0       	mov    $0xf0107f24,%esi
f010402f:	0f 45 d6             	cmovne %esi,%edx
f0104032:	83 e0 04             	and    $0x4,%eax
f0104035:	be 8e 80 10 f0       	mov    $0xf010808e,%esi
f010403a:	b8 2f 7f 10 f0       	mov    $0xf0107f2f,%eax
f010403f:	0f 44 c6             	cmove  %esi,%eax
f0104042:	51                   	push   %ecx
f0104043:	52                   	push   %edx
f0104044:	50                   	push   %eax
f0104045:	68 a7 7f 10 f0       	push   $0xf0107fa7
f010404a:	e8 33 f9 ff ff       	call   f0103982 <cprintf>
f010404f:	83 c4 10             	add    $0x10,%esp
f0104052:	eb 10                	jmp    f0104064 <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0104054:	83 ec 0c             	sub    $0xc,%esp
f0104057:	68 99 72 10 f0       	push   $0xf0107299
f010405c:	e8 21 f9 ff ff       	call   f0103982 <cprintf>
f0104061:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0104064:	83 ec 08             	sub    $0x8,%esp
f0104067:	ff 73 30             	pushl  0x30(%ebx)
f010406a:	68 b6 7f 10 f0       	push   $0xf0107fb6
f010406f:	e8 0e f9 ff ff       	call   f0103982 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0104074:	83 c4 08             	add    $0x8,%esp
f0104077:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f010407b:	50                   	push   %eax
f010407c:	68 c5 7f 10 f0       	push   $0xf0107fc5
f0104081:	e8 fc f8 ff ff       	call   f0103982 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104086:	83 c4 08             	add    $0x8,%esp
f0104089:	ff 73 38             	pushl  0x38(%ebx)
f010408c:	68 d8 7f 10 f0       	push   $0xf0107fd8
f0104091:	e8 ec f8 ff ff       	call   f0103982 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0104096:	83 c4 10             	add    $0x10,%esp
f0104099:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f010409d:	74 25                	je     f01040c4 <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f010409f:	83 ec 08             	sub    $0x8,%esp
f01040a2:	ff 73 3c             	pushl  0x3c(%ebx)
f01040a5:	68 e7 7f 10 f0       	push   $0xf0107fe7
f01040aa:	e8 d3 f8 ff ff       	call   f0103982 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01040af:	83 c4 08             	add    $0x8,%esp
f01040b2:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01040b6:	50                   	push   %eax
f01040b7:	68 f6 7f 10 f0       	push   $0xf0107ff6
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
f01040e1:	68 09 80 10 f0       	push   $0xf0108009
f01040e6:	68 73 01 00 00       	push   $0x173
f01040eb:	68 25 80 10 f0       	push   $0xf0108025
f01040f0:	e8 4b bf ff ff       	call   f0100040 <_panic>
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	if (curenv->env_pgfault_upcall) {
f01040f5:	e8 94 1c 00 00       	call   f0105d8e <cpunum>
f01040fa:	6b c0 74             	imul   $0x74,%eax,%eax
f01040fd:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
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
f010412d:	e8 5c 1c 00 00       	call   f0105d8e <cpunum>
f0104132:	6a 03                	push   $0x3
f0104134:	6a 34                	push   $0x34
f0104136:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104139:	6b c0 74             	imul   $0x74,%eax,%eax
f010413c:	ff b0 28 a0 2a f0    	pushl  -0xfd55fd8(%eax)
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
f0104173:	e8 16 1c 00 00       	call   f0105d8e <cpunum>
f0104178:	6b c0 74             	imul   $0x74,%eax,%eax
f010417b:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
f0104181:	89 70 3c             	mov    %esi,0x3c(%eax)
		curenv->env_tf.tf_eip = (uint32_t)curenv->env_pgfault_upcall;
f0104184:	e8 05 1c 00 00       	call   f0105d8e <cpunum>
f0104189:	6b c0 74             	imul   $0x74,%eax,%eax
f010418c:	8b 98 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%ebx
f0104192:	e8 f7 1b 00 00       	call   f0105d8e <cpunum>
f0104197:	6b c0 74             	imul   $0x74,%eax,%eax
f010419a:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
f01041a0:	8b 40 64             	mov    0x64(%eax),%eax
f01041a3:	89 43 30             	mov    %eax,0x30(%ebx)
		env_run(curenv);
f01041a6:	e8 e3 1b 00 00       	call   f0105d8e <cpunum>
f01041ab:	83 c4 04             	add    $0x4,%esp
f01041ae:	6b c0 74             	imul   $0x74,%eax,%eax
f01041b1:	ff b0 28 a0 2a f0    	pushl  -0xfd55fd8(%eax)
f01041b7:	e8 4e f5 ff ff       	call   f010370a <env_run>

	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01041bc:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f01041bf:	e8 ca 1b 00 00       	call   f0105d8e <cpunum>
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
f01041c9:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
f01041cf:	ff 70 48             	pushl  0x48(%eax)
f01041d2:	68 d8 81 10 f0       	push   $0xf01081d8
f01041d7:	e8 a6 f7 ff ff       	call   f0103982 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f01041dc:	89 1c 24             	mov    %ebx,(%esp)
f01041df:	e8 5f fd ff ff       	call   f0103f43 <print_trapframe>
	env_destroy(curenv);
f01041e4:	e8 a5 1b 00 00       	call   f0105d8e <cpunum>
f01041e9:	83 c4 04             	add    $0x4,%esp
f01041ec:	6b c0 74             	imul   $0x74,%eax,%eax
f01041ef:	ff b0 28 a0 2a f0    	pushl  -0xfd55fd8(%eax)
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
f010420e:	83 3d 98 9e 2a f0 00 	cmpl   $0x0,0xf02a9e98
f0104215:	74 01                	je     f0104218 <trap+0x13>
		asm volatile("hlt");
f0104217:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104218:	e8 71 1b 00 00       	call   f0105d8e <cpunum>
f010421d:	6b d0 74             	imul   $0x74,%eax,%edx
f0104220:	81 c2 20 a0 2a f0    	add    $0xf02aa020,%edx
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
f0104237:	68 c0 23 12 f0       	push   $0xf01223c0
f010423c:	e8 bb 1d 00 00       	call   f0105ffc <spin_lock>
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
f010424b:	68 31 80 10 f0       	push   $0xf0108031
f0104250:	68 85 6f 10 f0       	push   $0xf0106f85
f0104255:	68 3b 01 00 00       	push   $0x13b
f010425a:	68 25 80 10 f0       	push   $0xf0108025
f010425f:	e8 dc bd ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0104264:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104268:	83 e0 03             	and    $0x3,%eax
f010426b:	66 83 f8 03          	cmp    $0x3,%ax
f010426f:	0f 85 a0 00 00 00    	jne    f0104315 <trap+0x110>
f0104275:	83 ec 0c             	sub    $0xc,%esp
f0104278:	68 c0 23 12 f0       	push   $0xf01223c0
f010427d:	e8 7a 1d 00 00       	call   f0105ffc <spin_lock>
		// serious kernel work.
		// LAB 4: Your code here.

		lock_kernel();

		assert(curenv);
f0104282:	e8 07 1b 00 00       	call   f0105d8e <cpunum>
f0104287:	6b c0 74             	imul   $0x74,%eax,%eax
f010428a:	83 c4 10             	add    $0x10,%esp
f010428d:	83 b8 28 a0 2a f0 00 	cmpl   $0x0,-0xfd55fd8(%eax)
f0104294:	75 19                	jne    f01042af <trap+0xaa>
f0104296:	68 4a 80 10 f0       	push   $0xf010804a
f010429b:	68 85 6f 10 f0       	push   $0xf0106f85
f01042a0:	68 45 01 00 00       	push   $0x145
f01042a5:	68 25 80 10 f0       	push   $0xf0108025
f01042aa:	e8 91 bd ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f01042af:	e8 da 1a 00 00       	call   f0105d8e <cpunum>
f01042b4:	6b c0 74             	imul   $0x74,%eax,%eax
f01042b7:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
f01042bd:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01042c1:	75 2d                	jne    f01042f0 <trap+0xeb>
			env_free(curenv);
f01042c3:	e8 c6 1a 00 00       	call   f0105d8e <cpunum>
f01042c8:	83 ec 0c             	sub    $0xc,%esp
f01042cb:	6b c0 74             	imul   $0x74,%eax,%eax
f01042ce:	ff b0 28 a0 2a f0    	pushl  -0xfd55fd8(%eax)
f01042d4:	e8 ec f1 ff ff       	call   f01034c5 <env_free>
			curenv = NULL;
f01042d9:	e8 b0 1a 00 00       	call   f0105d8e <cpunum>
f01042de:	6b c0 74             	imul   $0x74,%eax,%eax
f01042e1:	c7 80 28 a0 2a f0 00 	movl   $0x0,-0xfd55fd8(%eax)
f01042e8:	00 00 00 
			sched_yield();
f01042eb:	e8 e2 02 00 00       	call   f01045d2 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01042f0:	e8 99 1a 00 00       	call   f0105d8e <cpunum>
f01042f5:	6b c0 74             	imul   $0x74,%eax,%eax
f01042f8:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
f01042fe:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104303:	89 c7                	mov    %eax,%edi
f0104305:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104307:	e8 82 1a 00 00       	call   f0105d8e <cpunum>
f010430c:	6b c0 74             	imul   $0x74,%eax,%eax
f010430f:	8b b0 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104315:	89 35 60 9a 2a f0    	mov    %esi,0xf02a9a60
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
f0104388:	e8 ce 02 00 00       	call   f010465b <syscall>
f010438d:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104390:	83 c4 20             	add    $0x20,%esp
f0104393:	e9 87 00 00 00       	jmp    f010441f <trap+0x21a>
			break;
		case (IRQ_OFFSET + IRQ_TIMER):
			lapic_eoi();	// Acknowledge interrupt.
f0104398:	e8 3c 1b 00 00       	call   f0105ed9 <lapic_eoi>
			time_tick();
f010439d:	e8 0b 23 00 00       	call   f01066ad <time_tick>
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
f01043b8:	68 51 80 10 f0       	push   $0xf0108051
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
f01043d3:	68 6e 80 10 f0       	push   $0xf010806e
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
f01043f2:	68 7c 80 10 f0       	push   $0xf010807c
f01043f7:	68 20 01 00 00       	push   $0x120
f01043fc:	68 25 80 10 f0       	push   $0xf0108025
f0104401:	e8 3a bc ff ff       	call   f0100040 <_panic>
			else {
				env_destroy(curenv);
f0104406:	e8 83 19 00 00       	call   f0105d8e <cpunum>
f010440b:	83 ec 0c             	sub    $0xc,%esp
f010440e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104411:	ff b0 28 a0 2a f0    	pushl  -0xfd55fd8(%eax)
f0104417:	e8 4f f2 ff ff       	call   f010366b <env_destroy>
f010441c:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f010441f:	e8 6a 19 00 00       	call   f0105d8e <cpunum>
f0104424:	6b c0 74             	imul   $0x74,%eax,%eax
f0104427:	83 b8 28 a0 2a f0 00 	cmpl   $0x0,-0xfd55fd8(%eax)
f010442e:	74 2a                	je     f010445a <trap+0x255>
f0104430:	e8 59 19 00 00       	call   f0105d8e <cpunum>
f0104435:	6b c0 74             	imul   $0x74,%eax,%eax
f0104438:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
f010443e:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104442:	75 16                	jne    f010445a <trap+0x255>
		env_run(curenv);
f0104444:	e8 45 19 00 00       	call   f0105d8e <cpunum>
f0104449:	83 ec 0c             	sub    $0xc,%esp
f010444c:	6b c0 74             	imul   $0x74,%eax,%eax
f010444f:	ff b0 28 a0 2a f0    	pushl  -0xfd55fd8(%eax)
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
f0104504:	a1 48 92 2a f0       	mov    0xf02a9248,%eax
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
f0104536:	68 50 82 10 f0       	push   $0xf0108250
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
f0104552:	e8 37 18 00 00       	call   f0105d8e <cpunum>
f0104557:	6b c0 74             	imul   $0x74,%eax,%eax
f010455a:	c7 80 28 a0 2a f0 00 	movl   $0x0,-0xfd55fd8(%eax)
f0104561:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104564:	a1 a4 9e 2a f0       	mov    0xf02a9ea4,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104569:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010456e:	77 12                	ja     f0104582 <sched_halt+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104570:	50                   	push   %eax
f0104571:	68 c8 69 10 f0       	push   $0xf01069c8
f0104576:	6a 52                	push   $0x52
f0104578:	68 79 82 10 f0       	push   $0xf0108279
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
f010458a:	e8 ff 17 00 00       	call   f0105d8e <cpunum>
f010458f:	6b d0 74             	imul   $0x74,%eax,%edx
f0104592:	81 c2 20 a0 2a f0    	add    $0xf02aa020,%edx
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
f01045a4:	68 c0 23 12 f0       	push   $0xf01223c0
f01045a9:	e8 eb 1a 00 00       	call   f0106099 <spin_unlock>

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
f01045b0:	e8 d9 17 00 00       	call   f0105d8e <cpunum>
f01045b5:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f01045b8:	8b 80 30 a0 2a f0    	mov    -0xfd55fd0(%eax),%eax
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
f01045d7:	e8 b2 17 00 00       	call   f0105d8e <cpunum>
f01045dc:	6b c0 74             	imul   $0x74,%eax,%eax
f01045df:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
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
f01045f9:	8b 0d 48 92 2a f0    	mov    0xf02a9248,%ecx
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
f0104637:	e8 52 17 00 00       	call   f0105d8e <cpunum>
f010463c:	39 c3                	cmp    %eax,%ebx
f010463e:	75 0f                	jne    f010464f <sched_yield+0x7d>
        env_run(&envs[startid]);
f0104640:	83 ec 0c             	sub    $0xc,%esp
f0104643:	03 35 48 92 2a f0    	add    0xf02a9248,%esi
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

f010465b <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f010465b:	55                   	push   %ebp
f010465c:	89 e5                	mov    %esp,%ebp
f010465e:	57                   	push   %edi
f010465f:	56                   	push   %esi
f0104660:	53                   	push   %ebx
f0104661:	83 ec 1c             	sub    $0x1c,%esp
f0104664:	8b 45 08             	mov    0x8(%ebp),%eax
	// Return any appropriate return value.
	// LAB 3: Your code here.

	// panic("syscall not implemented");

	switch (syscallno) {
f0104667:	83 f8 0e             	cmp    $0xe,%eax
f010466a:	0f 87 60 05 00 00    	ja     f0104bd0 <syscall+0x575>
f0104670:	ff 24 85 8c 82 10 f0 	jmp    *-0xfef7d74(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, 0);		// just check if PTE_U is set
f0104677:	e8 12 17 00 00       	call   f0105d8e <cpunum>
f010467c:	6a 00                	push   $0x0
f010467e:	ff 75 10             	pushl  0x10(%ebp)
f0104681:	ff 75 0c             	pushl  0xc(%ebp)
f0104684:	6b c0 74             	imul   $0x74,%eax,%eax
f0104687:	ff b0 28 a0 2a f0    	pushl  -0xfd55fd8(%eax)
f010468d:	e8 b6 e9 ff ff       	call   f0103048 <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104692:	83 c4 0c             	add    $0xc,%esp
f0104695:	ff 75 0c             	pushl  0xc(%ebp)
f0104698:	ff 75 10             	pushl  0x10(%ebp)
f010469b:	68 86 82 10 f0       	push   $0xf0108286
f01046a0:	e8 dd f2 ff ff       	call   f0103982 <cprintf>
f01046a5:	83 c4 10             	add    $0x10,%esp
	// panic("syscall not implemented");

	switch (syscallno) {
		case SYS_cputs:
			sys_cputs((char *)a1, a2);
			return 0;
f01046a8:	bb 00 00 00 00       	mov    $0x0,%ebx
f01046ad:	e9 2a 05 00 00       	jmp    f0104bdc <syscall+0x581>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f01046b2:	e8 45 bf ff ff       	call   f01005fc <cons_getc>
f01046b7:	89 c3                	mov    %eax,%ebx
	switch (syscallno) {
		case SYS_cputs:
			sys_cputs((char *)a1, a2);
			return 0;
		case SYS_cgetc:
			return sys_cgetc();
f01046b9:	e9 1e 05 00 00       	jmp    f0104bdc <syscall+0x581>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f01046be:	e8 cb 16 00 00       	call   f0105d8e <cpunum>
f01046c3:	6b c0 74             	imul   $0x74,%eax,%eax
f01046c6:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
f01046cc:	8b 58 48             	mov    0x48(%eax),%ebx
			sys_cputs((char *)a1, a2);
			return 0;
		case SYS_cgetc:
			return sys_cgetc();
		case SYS_getenvid:
			return sys_getenvid();
f01046cf:	e9 08 05 00 00       	jmp    f0104bdc <syscall+0x581>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01046d4:	83 ec 04             	sub    $0x4,%esp
f01046d7:	6a 01                	push   $0x1
f01046d9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01046dc:	50                   	push   %eax
f01046dd:	ff 75 0c             	pushl  0xc(%ebp)
f01046e0:	e8 31 ea ff ff       	call   f0103116 <envid2env>
f01046e5:	83 c4 10             	add    $0x10,%esp
		return r;
f01046e8:	89 c3                	mov    %eax,%ebx
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01046ea:	85 c0                	test   %eax,%eax
f01046ec:	0f 88 ea 04 00 00    	js     f0104bdc <syscall+0x581>
		return r;
	env_destroy(e);
f01046f2:	83 ec 0c             	sub    $0xc,%esp
f01046f5:	ff 75 e4             	pushl  -0x1c(%ebp)
f01046f8:	e8 6e ef ff ff       	call   f010366b <env_destroy>
f01046fd:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104700:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104705:	e9 d2 04 00 00       	jmp    f0104bdc <syscall+0x581>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f010470a:	e8 c3 fe ff ff       	call   f01045d2 <sched_yield>
	// LAB 4: Your code here.
	// panic("sys_exofork not implemented");

	struct Env *newenv;

	int err = env_alloc(&newenv , curenv->env_id);
f010470f:	e8 7a 16 00 00       	call   f0105d8e <cpunum>
f0104714:	83 ec 08             	sub    $0x8,%esp
f0104717:	6b c0 74             	imul   $0x74,%eax,%eax
f010471a:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
f0104720:	ff 70 48             	pushl  0x48(%eax)
f0104723:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104726:	50                   	push   %eax
f0104727:	e8 f5 ea ff ff       	call   f0103221 <env_alloc>
	if (err < 0)
f010472c:	83 c4 10             	add    $0x10,%esp
		return err;
f010472f:	89 c3                	mov    %eax,%ebx
	// panic("sys_exofork not implemented");

	struct Env *newenv;

	int err = env_alloc(&newenv , curenv->env_id);
	if (err < 0)
f0104731:	85 c0                	test   %eax,%eax
f0104733:	0f 88 a3 04 00 00    	js     f0104bdc <syscall+0x581>
		return err;

	// memcpy(&newenv->env_tf, &curenv->env_tf, sizeof(struct Trapframe));
	newenv->env_tf = curenv->env_tf;
f0104739:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010473c:	e8 4d 16 00 00       	call   f0105d8e <cpunum>
f0104741:	6b c0 74             	imul   $0x74,%eax,%eax
f0104744:	8b b0 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%esi
f010474a:	b9 11 00 00 00       	mov    $0x11,%ecx
f010474f:	89 df                	mov    %ebx,%edi
f0104751:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	newenv->env_status = ENV_NOT_RUNNABLE;
f0104753:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104756:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)

	// tweak newenv, to make it appear to return 0
	newenv->env_tf.tf_regs.reg_eax = 0;
f010475d:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

	return newenv->env_id;
f0104764:	8b 58 48             	mov    0x48(%eax),%ebx
f0104767:	e9 70 04 00 00       	jmp    f0104bdc <syscall+0x581>

	// LAB 4: Your code here.
	// panic("sys_env_set_status not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
f010476c:	83 ec 04             	sub    $0x4,%esp
f010476f:	6a 01                	push   $0x1
f0104771:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104774:	50                   	push   %eax
f0104775:	ff 75 0c             	pushl  0xc(%ebp)
f0104778:	e8 99 e9 ff ff       	call   f0103116 <envid2env>
	if (err < 0)
f010477d:	83 c4 10             	add    $0x10,%esp
f0104780:	85 c0                	test   %eax,%eax
f0104782:	78 20                	js     f01047a4 <syscall+0x149>
		return err;

	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
f0104784:	8b 45 10             	mov    0x10(%ebp),%eax
f0104787:	83 e8 02             	sub    $0x2,%eax
f010478a:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f010478f:	75 1a                	jne    f01047ab <syscall+0x150>
		return -E_INVAL;

	env_store->env_status = status;
f0104791:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104794:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104797:	89 48 54             	mov    %ecx,0x54(%eax)

	return 0;
f010479a:	bb 00 00 00 00       	mov    $0x0,%ebx
f010479f:	e9 38 04 00 00       	jmp    f0104bdc <syscall+0x581>
	// panic("sys_env_set_status not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
	if (err < 0)
		return err;
f01047a4:	89 c3                	mov    %eax,%ebx
f01047a6:	e9 31 04 00 00       	jmp    f0104bdc <syscall+0x581>

	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
		return -E_INVAL;
f01047ab:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			sys_yield();
			return 0;
		case SYS_exofork:
			return sys_exofork();
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1, a2);
f01047b0:	e9 27 04 00 00       	jmp    f0104bdc <syscall+0x581>

	// LAB 4: Your code here.
	// panic("sys_page_alloc not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
f01047b5:	83 ec 04             	sub    $0x4,%esp
f01047b8:	6a 01                	push   $0x1
f01047ba:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01047bd:	50                   	push   %eax
f01047be:	ff 75 0c             	pushl  0xc(%ebp)
f01047c1:	e8 50 e9 ff ff       	call   f0103116 <envid2env>
	if (err < 0)
f01047c6:	83 c4 10             	add    $0x10,%esp
f01047c9:	85 c0                	test   %eax,%eax
f01047cb:	78 6b                	js     f0104838 <syscall+0x1dd>
		return err;	// E_BAD_ENV

	if ((perm | PTE_AVAIL | PTE_W) != (PTE_AVAIL | PTE_W | PTE_U | PTE_P))
		return -E_INVAL;

	if ((uint32_t)va >= UTOP || ((uint32_t) va % PGSIZE) != 0)
f01047cd:	8b 45 14             	mov    0x14(%ebp),%eax
f01047d0:	0d 02 0e 00 00       	or     $0xe02,%eax
f01047d5:	3d 07 0e 00 00       	cmp    $0xe07,%eax
f01047da:	75 63                	jne    f010483f <syscall+0x1e4>
f01047dc:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01047e3:	77 5a                	ja     f010483f <syscall+0x1e4>
f01047e5:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01047ec:	75 5b                	jne    f0104849 <syscall+0x1ee>
		return -E_INVAL;
	
	struct PageInfo * pp = page_alloc(ALLOC_ZERO);
f01047ee:	83 ec 0c             	sub    $0xc,%esp
f01047f1:	6a 01                	push   $0x1
f01047f3:	e8 99 c8 ff ff       	call   f0101091 <page_alloc>
f01047f8:	89 c6                	mov    %eax,%esi
	if (pp == NULL)
f01047fa:	83 c4 10             	add    $0x10,%esp
f01047fd:	85 c0                	test   %eax,%eax
f01047ff:	74 52                	je     f0104853 <syscall+0x1f8>
		return -E_NO_MEM;
	
	err = page_insert(env_store->env_pgdir, pp, va, perm);
f0104801:	ff 75 14             	pushl  0x14(%ebp)
f0104804:	ff 75 10             	pushl  0x10(%ebp)
f0104807:	50                   	push   %eax
f0104808:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010480b:	ff 70 60             	pushl  0x60(%eax)
f010480e:	e8 71 cc ff ff       	call   f0101484 <page_insert>
f0104813:	89 c7                	mov    %eax,%edi
	if (err < 0) {
f0104815:	83 c4 10             	add    $0x10,%esp
		page_free(pp);
		return err; // E_NO_MEM
	}

	return 0;
f0104818:	bb 00 00 00 00       	mov    $0x0,%ebx
	struct PageInfo * pp = page_alloc(ALLOC_ZERO);
	if (pp == NULL)
		return -E_NO_MEM;
	
	err = page_insert(env_store->env_pgdir, pp, va, perm);
	if (err < 0) {
f010481d:	85 c0                	test   %eax,%eax
f010481f:	0f 89 b7 03 00 00    	jns    f0104bdc <syscall+0x581>
		page_free(pp);
f0104825:	83 ec 0c             	sub    $0xc,%esp
f0104828:	56                   	push   %esi
f0104829:	e8 d4 c8 ff ff       	call   f0101102 <page_free>
f010482e:	83 c4 10             	add    $0x10,%esp
		return err; // E_NO_MEM
f0104831:	89 fb                	mov    %edi,%ebx
f0104833:	e9 a4 03 00 00       	jmp    f0104bdc <syscall+0x581>
	// panic("sys_page_alloc not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
	if (err < 0)
		return err;	// E_BAD_ENV
f0104838:	89 c3                	mov    %eax,%ebx
f010483a:	e9 9d 03 00 00       	jmp    f0104bdc <syscall+0x581>

	if ((perm | PTE_AVAIL | PTE_W) != (PTE_AVAIL | PTE_W | PTE_U | PTE_P))
		return -E_INVAL;

	if ((uint32_t)va >= UTOP || ((uint32_t) va % PGSIZE) != 0)
		return -E_INVAL;
f010483f:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104844:	e9 93 03 00 00       	jmp    f0104bdc <syscall+0x581>
f0104849:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010484e:	e9 89 03 00 00       	jmp    f0104bdc <syscall+0x581>
	
	struct PageInfo * pp = page_alloc(ALLOC_ZERO);
	if (pp == NULL)
		return -E_NO_MEM;
f0104853:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f0104858:	e9 7f 03 00 00       	jmp    f0104bdc <syscall+0x581>
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	// panic("sys_page_map not implemented");

	if ((uint32_t)srcva >= UTOP || ((uint32_t)srcva % PGSIZE) != 0 || (uint32_t)dstva >= UTOP || ((uint32_t)dstva % PGSIZE != 0))
f010485d:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104864:	0f 87 c2 00 00 00    	ja     f010492c <syscall+0x2d1>
f010486a:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104871:	0f 85 bf 00 00 00    	jne    f0104936 <syscall+0x2db>
f0104877:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f010487e:	0f 87 b2 00 00 00    	ja     f0104936 <syscall+0x2db>
f0104884:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f010488b:	0f 85 af 00 00 00    	jne    f0104940 <syscall+0x2e5>
		return -E_INVAL;
	
	struct Env *srcenv, *dstenv;
	int err = envid2env(srcenvid, &srcenv, 1);
f0104891:	83 ec 04             	sub    $0x4,%esp
f0104894:	6a 01                	push   $0x1
f0104896:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104899:	50                   	push   %eax
f010489a:	ff 75 0c             	pushl  0xc(%ebp)
f010489d:	e8 74 e8 ff ff       	call   f0103116 <envid2env>
	if(err < 0)
f01048a2:	83 c4 10             	add    $0x10,%esp
		return err;	// E_BAD_ENV
f01048a5:	89 c3                	mov    %eax,%ebx
	if ((uint32_t)srcva >= UTOP || ((uint32_t)srcva % PGSIZE) != 0 || (uint32_t)dstva >= UTOP || ((uint32_t)dstva % PGSIZE != 0))
		return -E_INVAL;
	
	struct Env *srcenv, *dstenv;
	int err = envid2env(srcenvid, &srcenv, 1);
	if(err < 0)
f01048a7:	85 c0                	test   %eax,%eax
f01048a9:	0f 88 2d 03 00 00    	js     f0104bdc <syscall+0x581>
		return err;	// E_BAD_ENV
	err = envid2env(dstenvid, &dstenv, 1);
f01048af:	83 ec 04             	sub    $0x4,%esp
f01048b2:	6a 01                	push   $0x1
f01048b4:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01048b7:	50                   	push   %eax
f01048b8:	ff 75 14             	pushl  0x14(%ebp)
f01048bb:	e8 56 e8 ff ff       	call   f0103116 <envid2env>
	if(err < 0)
f01048c0:	83 c4 10             	add    $0x10,%esp
		return err;	// E_BAD_ENV
f01048c3:	89 c3                	mov    %eax,%ebx
	struct Env *srcenv, *dstenv;
	int err = envid2env(srcenvid, &srcenv, 1);
	if(err < 0)
		return err;	// E_BAD_ENV
	err = envid2env(dstenvid, &dstenv, 1);
	if(err < 0)
f01048c5:	85 c0                	test   %eax,%eax
f01048c7:	0f 88 0f 03 00 00    	js     f0104bdc <syscall+0x581>
		return err;	// E_BAD_ENV

	pte_t *pte;
	struct PageInfo *pp = page_lookup(srcenv->env_pgdir, srcva, &pte);
f01048cd:	83 ec 04             	sub    $0x4,%esp
f01048d0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01048d3:	50                   	push   %eax
f01048d4:	ff 75 10             	pushl  0x10(%ebp)
f01048d7:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01048da:	ff 70 60             	pushl  0x60(%eax)
f01048dd:	e8 ba ca ff ff       	call   f010139c <page_lookup>
	if (pp == NULL) 
f01048e2:	83 c4 10             	add    $0x10,%esp
f01048e5:	85 c0                	test   %eax,%eax
f01048e7:	74 61                	je     f010494a <syscall+0x2ef>
		return -E_INVAL;	// not mapped
	
	if ( ((*pte) & PTE_W) == 0 && (perm & PTE_W) != 0)
f01048e9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01048ec:	f6 02 02             	testb  $0x2,(%edx)
f01048ef:	75 06                	jne    f01048f7 <syscall+0x29c>
f01048f1:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f01048f5:	75 5d                	jne    f0104954 <syscall+0x2f9>
		return -E_INVAL;	// read-only page

	// same perm restrictions as in sys_page_alloc
	if ((perm | PTE_AVAIL | PTE_W) != (PTE_AVAIL | PTE_W | PTE_U | PTE_P))
f01048f7:	8b 55 1c             	mov    0x1c(%ebp),%edx
f01048fa:	81 ca 02 0e 00 00    	or     $0xe02,%edx
f0104900:	81 fa 07 0e 00 00    	cmp    $0xe07,%edx
f0104906:	75 56                	jne    f010495e <syscall+0x303>
		return -E_INVAL;

	err = page_insert(dstenv->env_pgdir, pp, dstva, perm);
f0104908:	ff 75 1c             	pushl  0x1c(%ebp)
f010490b:	ff 75 18             	pushl  0x18(%ebp)
f010490e:	50                   	push   %eax
f010490f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104912:	ff 70 60             	pushl  0x60(%eax)
f0104915:	e8 6a cb ff ff       	call   f0101484 <page_insert>
f010491a:	83 c4 10             	add    $0x10,%esp
f010491d:	85 c0                	test   %eax,%eax
f010491f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104924:	0f 4e d8             	cmovle %eax,%ebx
f0104927:	e9 b0 02 00 00       	jmp    f0104bdc <syscall+0x581>

	// LAB 4: Your code here.
	// panic("sys_page_map not implemented");

	if ((uint32_t)srcva >= UTOP || ((uint32_t)srcva % PGSIZE) != 0 || (uint32_t)dstva >= UTOP || ((uint32_t)dstva % PGSIZE != 0))
		return -E_INVAL;
f010492c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104931:	e9 a6 02 00 00       	jmp    f0104bdc <syscall+0x581>
f0104936:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010493b:	e9 9c 02 00 00       	jmp    f0104bdc <syscall+0x581>
f0104940:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104945:	e9 92 02 00 00       	jmp    f0104bdc <syscall+0x581>
		return err;	// E_BAD_ENV

	pte_t *pte;
	struct PageInfo *pp = page_lookup(srcenv->env_pgdir, srcva, &pte);
	if (pp == NULL) 
		return -E_INVAL;	// not mapped
f010494a:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010494f:	e9 88 02 00 00       	jmp    f0104bdc <syscall+0x581>
	
	if ( ((*pte) & PTE_W) == 0 && (perm & PTE_W) != 0)
		return -E_INVAL;	// read-only page
f0104954:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104959:	e9 7e 02 00 00       	jmp    f0104bdc <syscall+0x581>

	// same perm restrictions as in sys_page_alloc
	if ((perm | PTE_AVAIL | PTE_W) != (PTE_AVAIL | PTE_W | PTE_U | PTE_P))
		return -E_INVAL;
f010495e:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1, a2);
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1, (void *)a2, a3);
		case SYS_page_map:
			return sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4, a5);
f0104963:	e9 74 02 00 00       	jmp    f0104bdc <syscall+0x581>
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	// panic("sys_page_unmap not implemented");

	if ((uint32_t)va >= UTOP || ((uint32_t) va % PGSIZE) != 0)
f0104968:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f010496f:	77 45                	ja     f01049b6 <syscall+0x35b>
f0104971:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104978:	75 46                	jne    f01049c0 <syscall+0x365>
		return -E_INVAL;

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
f010497a:	83 ec 04             	sub    $0x4,%esp
f010497d:	6a 01                	push   $0x1
f010497f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104982:	50                   	push   %eax
f0104983:	ff 75 0c             	pushl  0xc(%ebp)
f0104986:	e8 8b e7 ff ff       	call   f0103116 <envid2env>
	if (err < 0)
f010498b:	83 c4 10             	add    $0x10,%esp
		return err;	// E_BAD_ENV
f010498e:	89 c3                	mov    %eax,%ebx
	if ((uint32_t)va >= UTOP || ((uint32_t) va % PGSIZE) != 0)
		return -E_INVAL;

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
	if (err < 0)
f0104990:	85 c0                	test   %eax,%eax
f0104992:	0f 88 44 02 00 00    	js     f0104bdc <syscall+0x581>
		return err;	// E_BAD_ENV

	page_remove(env_store->env_pgdir, va);
f0104998:	83 ec 08             	sub    $0x8,%esp
f010499b:	ff 75 10             	pushl  0x10(%ebp)
f010499e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01049a1:	ff 70 60             	pushl  0x60(%eax)
f01049a4:	e8 8e ca ff ff       	call   f0101437 <page_remove>
f01049a9:	83 c4 10             	add    $0x10,%esp

	return 0;
f01049ac:	bb 00 00 00 00       	mov    $0x0,%ebx
f01049b1:	e9 26 02 00 00       	jmp    f0104bdc <syscall+0x581>

	// LAB 4: Your code here.
	// panic("sys_page_unmap not implemented");

	if ((uint32_t)va >= UTOP || ((uint32_t) va % PGSIZE) != 0)
		return -E_INVAL;
f01049b6:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049bb:	e9 1c 02 00 00       	jmp    f0104bdc <syscall+0x581>
f01049c0:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049c5:	e9 12 02 00 00       	jmp    f0104bdc <syscall+0x581>
{
	// LAB 4: Your code here.
	// panic("sys_env_set_pgfault_upcall not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
f01049ca:	83 ec 04             	sub    $0x4,%esp
f01049cd:	6a 01                	push   $0x1
f01049cf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01049d2:	50                   	push   %eax
f01049d3:	ff 75 0c             	pushl  0xc(%ebp)
f01049d6:	e8 3b e7 ff ff       	call   f0103116 <envid2env>
	if (err < 0)
f01049db:	83 c4 10             	add    $0x10,%esp
f01049de:	85 c0                	test   %eax,%eax
f01049e0:	78 13                	js     f01049f5 <syscall+0x39a>
		return err;

	env_store->env_pgfault_upcall = func;
f01049e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01049e5:	8b 55 10             	mov    0x10(%ebp),%edx
f01049e8:	89 50 64             	mov    %edx,0x64(%eax)

	return 0;
f01049eb:	bb 00 00 00 00       	mov    $0x0,%ebx
f01049f0:	e9 e7 01 00 00       	jmp    f0104bdc <syscall+0x581>
	// panic("sys_env_set_pgfault_upcall not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
	if (err < 0)
		return err;
f01049f5:	89 c3                	mov    %eax,%ebx
		case SYS_page_map:
			return sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4, a5);
		case SYS_page_unmap:
			return sys_page_unmap((envid_t)a1, (void *)a2);
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
f01049f7:	e9 e0 01 00 00       	jmp    f0104bdc <syscall+0x581>
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	// panic("sys_ipc_recv not implemented");

	if ((uint32_t)dstva < UTOP) {
f01049fc:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0104a03:	77 21                	ja     f0104a26 <syscall+0x3cb>
		if ((uint32_t)dstva % PGSIZE != 0)
f0104a05:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0104a0c:	0f 85 c5 01 00 00    	jne    f0104bd7 <syscall+0x57c>
			return -E_INVAL;
		curenv->env_ipc_dstva = dstva;
f0104a12:	e8 77 13 00 00       	call   f0105d8e <cpunum>
f0104a17:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a1a:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
f0104a20:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104a23:	89 78 6c             	mov    %edi,0x6c(%eax)
	}

	// set recving flags
	curenv->env_ipc_recving = true;
f0104a26:	e8 63 13 00 00       	call   f0105d8e <cpunum>
f0104a2b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a2e:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
f0104a34:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_from = 0;
f0104a38:	e8 51 13 00 00       	call   f0105d8e <cpunum>
f0104a3d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a40:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
f0104a46:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)

	// mark yourself not runnable, and then give up the CPU.
	curenv->env_status = ENV_NOT_RUNNABLE;
f0104a4d:	e8 3c 13 00 00       	call   f0105d8e <cpunum>
f0104a52:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a55:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
f0104a5b:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	sched_yield();
f0104a62:	e8 6b fb ff ff       	call   f01045d2 <sched_yield>
{
	// LAB 4: Your code here.
	// panic("sys_ipc_try_send not implemented");

	struct Env *env;
	int err = envid2env(envid, &env, 0);
f0104a67:	83 ec 04             	sub    $0x4,%esp
f0104a6a:	6a 00                	push   $0x0
f0104a6c:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104a6f:	50                   	push   %eax
f0104a70:	ff 75 0c             	pushl  0xc(%ebp)
f0104a73:	e8 9e e6 ff ff       	call   f0103116 <envid2env>
	if(err < 0)
f0104a78:	83 c4 10             	add    $0x10,%esp
f0104a7b:	85 c0                	test   %eax,%eax
f0104a7d:	0f 88 02 01 00 00    	js     f0104b85 <syscall+0x52a>
		return err;	// E_BAD_ENV
	
	// not recving, or already recving
	if (env->env_ipc_recving != true || env->env_ipc_from != 0)
f0104a83:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104a86:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0104a8a:	0f 84 f9 00 00 00    	je     f0104b89 <syscall+0x52e>
f0104a90:	8b 58 74             	mov    0x74(%eax),%ebx
f0104a93:	85 db                	test   %ebx,%ebx
f0104a95:	0f 85 f5 00 00 00    	jne    f0104b90 <syscall+0x535>

	// first check if the recver is willing to recv a page
	// any error happens, fall fast
	if (env->env_ipc_dstva != 0) {
		
		if ((uint32_t)srcva < UTOP) {
f0104a9b:	83 78 6c 00          	cmpl   $0x0,0x6c(%eax)
f0104a9f:	0f 84 ac 00 00 00    	je     f0104b51 <syscall+0x4f6>
f0104aa5:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104aac:	0f 87 9f 00 00 00    	ja     f0104b51 <syscall+0x4f6>
			if ((uint32_t)srcva % PGSIZE != 0)
f0104ab2:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0104ab9:	75 64                	jne    f0104b1f <syscall+0x4c4>
				return -E_INVAL;
			if ((perm & (PTE_P | PTE_U)) != (PTE_P | PTE_U))
f0104abb:	8b 45 18             	mov    0x18(%ebp),%eax
f0104abe:	83 e0 05             	and    $0x5,%eax
f0104ac1:	83 f8 05             	cmp    $0x5,%eax
f0104ac4:	75 63                	jne    f0104b29 <syscall+0x4ce>
            	return -E_INVAL;

			pte_t *pte;
			struct PageInfo *pp = page_lookup(curenv->env_pgdir, srcva, &pte);
f0104ac6:	e8 c3 12 00 00       	call   f0105d8e <cpunum>
f0104acb:	83 ec 04             	sub    $0x4,%esp
f0104ace:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104ad1:	52                   	push   %edx
f0104ad2:	ff 75 14             	pushl  0x14(%ebp)
f0104ad5:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ad8:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
f0104ade:	ff 70 60             	pushl  0x60(%eax)
f0104ae1:	e8 b6 c8 ff ff       	call   f010139c <page_lookup>
			if (!pp) 
f0104ae6:	83 c4 10             	add    $0x10,%esp
f0104ae9:	85 c0                	test   %eax,%eax
f0104aeb:	74 46                	je     f0104b33 <syscall+0x4d8>
				return -E_INVAL;  
			
			if ((perm & PTE_W) && ((size_t) *pte & PTE_W) != PTE_W) 
f0104aed:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104af1:	74 08                	je     f0104afb <syscall+0x4a0>
f0104af3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104af6:	f6 02 02             	testb  $0x2,(%edx)
f0104af9:	74 42                	je     f0104b3d <syscall+0x4e2>
				return -E_INVAL;

			if (page_insert(env->env_pgdir, pp, env->env_ipc_dstva, perm) < 0) 
f0104afb:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104afe:	ff 75 18             	pushl  0x18(%ebp)
f0104b01:	ff 72 6c             	pushl  0x6c(%edx)
f0104b04:	50                   	push   %eax
f0104b05:	ff 72 60             	pushl  0x60(%edx)
f0104b08:	e8 77 c9 ff ff       	call   f0101484 <page_insert>
f0104b0d:	83 c4 10             	add    $0x10,%esp
f0104b10:	85 c0                	test   %eax,%eax
f0104b12:	78 33                	js     f0104b47 <syscall+0x4ec>
				return -E_NO_MEM;
			
			env->env_ipc_perm = perm;
f0104b14:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b17:	8b 7d 18             	mov    0x18(%ebp),%edi
f0104b1a:	89 78 78             	mov    %edi,0x78(%eax)
f0104b1d:	eb 32                	jmp    f0104b51 <syscall+0x4f6>
	// any error happens, fall fast
	if (env->env_ipc_dstva != 0) {
		
		if ((uint32_t)srcva < UTOP) {
			if ((uint32_t)srcva % PGSIZE != 0)
				return -E_INVAL;
f0104b1f:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b24:	e9 b3 00 00 00       	jmp    f0104bdc <syscall+0x581>
			if ((perm & (PTE_P | PTE_U)) != (PTE_P | PTE_U))
            	return -E_INVAL;
f0104b29:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b2e:	e9 a9 00 00 00       	jmp    f0104bdc <syscall+0x581>

			pte_t *pte;
			struct PageInfo *pp = page_lookup(curenv->env_pgdir, srcva, &pte);
			if (!pp) 
				return -E_INVAL;  
f0104b33:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b38:	e9 9f 00 00 00       	jmp    f0104bdc <syscall+0x581>
			
			if ((perm & PTE_W) && ((size_t) *pte & PTE_W) != PTE_W) 
				return -E_INVAL;
f0104b3d:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b42:	e9 95 00 00 00       	jmp    f0104bdc <syscall+0x581>

			if (page_insert(env->env_pgdir, pp, env->env_ipc_dstva, perm) < 0) 
				return -E_NO_MEM;
f0104b47:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f0104b4c:	e9 8b 00 00 00       	jmp    f0104bdc <syscall+0x581>
			env->env_ipc_perm = perm;
		}

	}

	env->env_ipc_from = curenv->env_id;
f0104b51:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104b54:	e8 35 12 00 00       	call   f0105d8e <cpunum>
f0104b59:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b5c:	8b 80 28 a0 2a f0    	mov    -0xfd55fd8(%eax),%eax
f0104b62:	8b 40 48             	mov    0x48(%eax),%eax
f0104b65:	89 46 74             	mov    %eax,0x74(%esi)
	env->env_ipc_recving = false;
f0104b68:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b6b:	c6 40 68 00          	movb   $0x0,0x68(%eax)
	env->env_ipc_value = value;
f0104b6f:	8b 55 10             	mov    0x10(%ebp),%edx
f0104b72:	89 50 70             	mov    %edx,0x70(%eax)
	env->env_status = ENV_RUNNABLE;
f0104b75:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)

	// make the recver return 0
	env->env_tf.tf_regs.reg_eax = 0;
f0104b7c:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
f0104b83:	eb 57                	jmp    f0104bdc <syscall+0x581>
	// panic("sys_ipc_try_send not implemented");

	struct Env *env;
	int err = envid2env(envid, &env, 0);
	if(err < 0)
		return err;	// E_BAD_ENV
f0104b85:	89 c3                	mov    %eax,%ebx
f0104b87:	eb 53                	jmp    f0104bdc <syscall+0x581>
	
	// not recving, or already recving
	if (env->env_ipc_recving != true || env->env_ipc_from != 0)
		return -E_IPC_NOT_RECV;
f0104b89:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f0104b8e:	eb 4c                	jmp    f0104bdc <syscall+0x581>
f0104b90:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
		case SYS_ipc_recv:
			return sys_ipc_recv((void *)a1);
		case SYS_ipc_try_send:
			return sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned)a4);
f0104b95:	eb 45                	jmp    f0104bdc <syscall+0x581>
		case SYS_env_set_trapframe:
			return sys_env_set_trapframe((envid_t)a1, (struct Trapframe *)a2);
f0104b97:	8b 75 10             	mov    0x10(%ebp),%esi
	// Remember to check whether the user has supplied us with a good
	// address!
	// panic("sys_env_set_trapframe not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
f0104b9a:	83 ec 04             	sub    $0x4,%esp
f0104b9d:	6a 01                	push   $0x1
f0104b9f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104ba2:	50                   	push   %eax
f0104ba3:	ff 75 0c             	pushl  0xc(%ebp)
f0104ba6:	e8 6b e5 ff ff       	call   f0103116 <envid2env>
	if (err < 0)
f0104bab:	83 c4 10             	add    $0x10,%esp
f0104bae:	85 c0                	test   %eax,%eax
f0104bb0:	78 11                	js     f0104bc3 <syscall+0x568>
		return err;
	
	env_store->env_tf = *tf;
f0104bb2:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104bb7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104bba:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

	return 0;
f0104bbc:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104bc1:	eb 19                	jmp    f0104bdc <syscall+0x581>
	// panic("sys_env_set_trapframe not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
	if (err < 0)
		return err;
f0104bc3:	89 c3                	mov    %eax,%ebx
		case SYS_ipc_recv:
			return sys_ipc_recv((void *)a1);
		case SYS_ipc_try_send:
			return sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned)a4);
		case SYS_env_set_trapframe:
			return sys_env_set_trapframe((envid_t)a1, (struct Trapframe *)a2);
f0104bc5:	eb 15                	jmp    f0104bdc <syscall+0x581>
sys_time_msec(void)
{
	// LAB 6: Your code here.
	// panic("sys_time_msec not implemented");

	return time_msec();
f0104bc7:	e8 10 1b 00 00       	call   f01066dc <time_msec>
f0104bcc:	89 c3                	mov    %eax,%ebx
		case SYS_ipc_try_send:
			return sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned)a4);
		case SYS_env_set_trapframe:
			return sys_env_set_trapframe((envid_t)a1, (struct Trapframe *)a2);
		case SYS_time_msec:
			return sys_time_msec();
f0104bce:	eb 0c                	jmp    f0104bdc <syscall+0x581>
		default:
			return -E_INVAL;
f0104bd0:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104bd5:	eb 05                	jmp    f0104bdc <syscall+0x581>
		case SYS_page_unmap:
			return sys_page_unmap((envid_t)a1, (void *)a2);
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
		case SYS_ipc_recv:
			return sys_ipc_recv((void *)a1);
f0104bd7:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		case SYS_time_msec:
			return sys_time_msec();
		default:
			return -E_INVAL;
	}
}
f0104bdc:	89 d8                	mov    %ebx,%eax
f0104bde:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104be1:	5b                   	pop    %ebx
f0104be2:	5e                   	pop    %esi
f0104be3:	5f                   	pop    %edi
f0104be4:	5d                   	pop    %ebp
f0104be5:	c3                   	ret    

f0104be6 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104be6:	55                   	push   %ebp
f0104be7:	89 e5                	mov    %esp,%ebp
f0104be9:	57                   	push   %edi
f0104bea:	56                   	push   %esi
f0104beb:	53                   	push   %ebx
f0104bec:	83 ec 14             	sub    $0x14,%esp
f0104bef:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104bf2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104bf5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104bf8:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104bfb:	8b 1a                	mov    (%edx),%ebx
f0104bfd:	8b 01                	mov    (%ecx),%eax
f0104bff:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104c02:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104c09:	eb 7f                	jmp    f0104c8a <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0104c0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104c0e:	01 d8                	add    %ebx,%eax
f0104c10:	89 c6                	mov    %eax,%esi
f0104c12:	c1 ee 1f             	shr    $0x1f,%esi
f0104c15:	01 c6                	add    %eax,%esi
f0104c17:	d1 fe                	sar    %esi
f0104c19:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0104c1c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104c1f:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104c22:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104c24:	eb 03                	jmp    f0104c29 <stab_binsearch+0x43>
			m--;
f0104c26:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104c29:	39 c3                	cmp    %eax,%ebx
f0104c2b:	7f 0d                	jg     f0104c3a <stab_binsearch+0x54>
f0104c2d:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104c31:	83 ea 0c             	sub    $0xc,%edx
f0104c34:	39 f9                	cmp    %edi,%ecx
f0104c36:	75 ee                	jne    f0104c26 <stab_binsearch+0x40>
f0104c38:	eb 05                	jmp    f0104c3f <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104c3a:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0104c3d:	eb 4b                	jmp    f0104c8a <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104c3f:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104c42:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104c45:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104c49:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104c4c:	76 11                	jbe    f0104c5f <stab_binsearch+0x79>
			*region_left = m;
f0104c4e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104c51:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104c53:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104c56:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104c5d:	eb 2b                	jmp    f0104c8a <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104c5f:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104c62:	73 14                	jae    f0104c78 <stab_binsearch+0x92>
			*region_right = m - 1;
f0104c64:	83 e8 01             	sub    $0x1,%eax
f0104c67:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104c6a:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104c6d:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104c6f:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104c76:	eb 12                	jmp    f0104c8a <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104c78:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104c7b:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0104c7d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104c81:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104c83:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104c8a:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104c8d:	0f 8e 78 ff ff ff    	jle    f0104c0b <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104c93:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104c97:	75 0f                	jne    f0104ca8 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0104c99:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104c9c:	8b 00                	mov    (%eax),%eax
f0104c9e:	83 e8 01             	sub    $0x1,%eax
f0104ca1:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104ca4:	89 06                	mov    %eax,(%esi)
f0104ca6:	eb 2c                	jmp    f0104cd4 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104ca8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104cab:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104cad:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104cb0:	8b 0e                	mov    (%esi),%ecx
f0104cb2:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104cb5:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104cb8:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104cbb:	eb 03                	jmp    f0104cc0 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0104cbd:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104cc0:	39 c8                	cmp    %ecx,%eax
f0104cc2:	7e 0b                	jle    f0104ccf <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0104cc4:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0104cc8:	83 ea 0c             	sub    $0xc,%edx
f0104ccb:	39 df                	cmp    %ebx,%edi
f0104ccd:	75 ee                	jne    f0104cbd <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0104ccf:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104cd2:	89 06                	mov    %eax,(%esi)
	}
}
f0104cd4:	83 c4 14             	add    $0x14,%esp
f0104cd7:	5b                   	pop    %ebx
f0104cd8:	5e                   	pop    %esi
f0104cd9:	5f                   	pop    %edi
f0104cda:	5d                   	pop    %ebp
f0104cdb:	c3                   	ret    

f0104cdc <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104cdc:	55                   	push   %ebp
f0104cdd:	89 e5                	mov    %esp,%ebp
f0104cdf:	57                   	push   %edi
f0104ce0:	56                   	push   %esi
f0104ce1:	53                   	push   %ebx
f0104ce2:	83 ec 3c             	sub    $0x3c,%esp
f0104ce5:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104ce8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104ceb:	c7 03 c8 82 10 f0    	movl   $0xf01082c8,(%ebx)
	info->eip_line = 0;
f0104cf1:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104cf8:	c7 43 08 c8 82 10 f0 	movl   $0xf01082c8,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104cff:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104d06:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104d09:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104d10:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0104d16:	0f 87 a3 00 00 00    	ja     f0104dbf <debuginfo_eip+0xe3>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0104d1c:	a1 00 00 20 00       	mov    0x200000,%eax
f0104d21:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stab_end = usd->stab_end;
f0104d24:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f0104d2a:	8b 15 08 00 20 00    	mov    0x200008,%edx
f0104d30:	89 55 b8             	mov    %edx,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f0104d33:	a1 0c 00 20 00       	mov    0x20000c,%eax
f0104d38:	89 45 bc             	mov    %eax,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0 ||
f0104d3b:	e8 4e 10 00 00       	call   f0105d8e <cpunum>
f0104d40:	6a 04                	push   $0x4
f0104d42:	6a 10                	push   $0x10
f0104d44:	68 00 00 20 00       	push   $0x200000
f0104d49:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d4c:	ff b0 28 a0 2a f0    	pushl  -0xfd55fd8(%eax)
f0104d52:	e8 09 e2 ff ff       	call   f0102f60 <user_mem_check>
f0104d57:	83 c4 10             	add    $0x10,%esp
f0104d5a:	85 c0                	test   %eax,%eax
f0104d5c:	0f 88 27 02 00 00    	js     f0104f89 <debuginfo_eip+0x2ad>
			user_mem_check(curenv, stabs, stab_end-stabs, PTE_U) < 0 ||
f0104d62:	e8 27 10 00 00       	call   f0105d8e <cpunum>
f0104d67:	6a 04                	push   $0x4
f0104d69:	89 f2                	mov    %esi,%edx
f0104d6b:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104d6e:	29 ca                	sub    %ecx,%edx
f0104d70:	c1 fa 02             	sar    $0x2,%edx
f0104d73:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0104d79:	52                   	push   %edx
f0104d7a:	51                   	push   %ecx
f0104d7b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d7e:	ff b0 28 a0 2a f0    	pushl  -0xfd55fd8(%eax)
f0104d84:	e8 d7 e1 ff ff       	call   f0102f60 <user_mem_check>
		stabstr = usd->stabstr;
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0 ||
f0104d89:	83 c4 10             	add    $0x10,%esp
f0104d8c:	85 c0                	test   %eax,%eax
f0104d8e:	0f 88 fc 01 00 00    	js     f0104f90 <debuginfo_eip+0x2b4>
			user_mem_check(curenv, stabs, stab_end-stabs, PTE_U) < 0 ||
			user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U) < 0
f0104d94:	e8 f5 0f 00 00       	call   f0105d8e <cpunum>
f0104d99:	6a 04                	push   $0x4
f0104d9b:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0104d9e:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0104da1:	29 ca                	sub    %ecx,%edx
f0104da3:	52                   	push   %edx
f0104da4:	51                   	push   %ecx
f0104da5:	6b c0 74             	imul   $0x74,%eax,%eax
f0104da8:	ff b0 28 a0 2a f0    	pushl  -0xfd55fd8(%eax)
f0104dae:	e8 ad e1 ff ff       	call   f0102f60 <user_mem_check>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0 ||
			user_mem_check(curenv, stabs, stab_end-stabs, PTE_U) < 0 ||
f0104db3:	83 c4 10             	add    $0x10,%esp
f0104db6:	85 c0                	test   %eax,%eax
f0104db8:	79 1f                	jns    f0104dd9 <debuginfo_eip+0xfd>
f0104dba:	e9 d8 01 00 00       	jmp    f0104f97 <debuginfo_eip+0x2bb>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104dbf:	c7 45 bc 7d 7f 11 f0 	movl   $0xf0117f7d,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0104dc6:	c7 45 b8 ed 3e 11 f0 	movl   $0xf0113eed,-0x48(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0104dcd:	be ec 3e 11 f0       	mov    $0xf0113eec,%esi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104dd2:	c7 45 c0 c8 8a 10 f0 	movl   $0xf0108ac8,-0x40(%ebp)
		)
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104dd9:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104ddc:	39 45 b8             	cmp    %eax,-0x48(%ebp)
f0104ddf:	0f 83 b9 01 00 00    	jae    f0104f9e <debuginfo_eip+0x2c2>
f0104de5:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0104de9:	0f 85 b6 01 00 00    	jne    f0104fa5 <debuginfo_eip+0x2c9>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104def:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104df6:	2b 75 c0             	sub    -0x40(%ebp),%esi
f0104df9:	c1 fe 02             	sar    $0x2,%esi
f0104dfc:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f0104e02:	83 e8 01             	sub    $0x1,%eax
f0104e05:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104e08:	83 ec 08             	sub    $0x8,%esp
f0104e0b:	57                   	push   %edi
f0104e0c:	6a 64                	push   $0x64
f0104e0e:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0104e11:	89 d1                	mov    %edx,%ecx
f0104e13:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104e16:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0104e19:	89 f0                	mov    %esi,%eax
f0104e1b:	e8 c6 fd ff ff       	call   f0104be6 <stab_binsearch>
	if (lfile == 0)
f0104e20:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e23:	83 c4 10             	add    $0x10,%esp
f0104e26:	85 c0                	test   %eax,%eax
f0104e28:	0f 84 7e 01 00 00    	je     f0104fac <debuginfo_eip+0x2d0>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104e2e:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104e31:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104e34:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104e37:	83 ec 08             	sub    $0x8,%esp
f0104e3a:	57                   	push   %edi
f0104e3b:	6a 24                	push   $0x24
f0104e3d:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0104e40:	89 d1                	mov    %edx,%ecx
f0104e42:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104e45:	89 f0                	mov    %esi,%eax
f0104e47:	e8 9a fd ff ff       	call   f0104be6 <stab_binsearch>

	if (lfun <= rfun) {
f0104e4c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104e4f:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104e52:	83 c4 10             	add    $0x10,%esp
f0104e55:	39 d0                	cmp    %edx,%eax
f0104e57:	7f 2e                	jg     f0104e87 <debuginfo_eip+0x1ab>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104e59:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0104e5c:	8d 34 8e             	lea    (%esi,%ecx,4),%esi
f0104e5f:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f0104e62:	8b 36                	mov    (%esi),%esi
f0104e64:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0104e67:	2b 4d b8             	sub    -0x48(%ebp),%ecx
f0104e6a:	39 ce                	cmp    %ecx,%esi
f0104e6c:	73 06                	jae    f0104e74 <debuginfo_eip+0x198>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104e6e:	03 75 b8             	add    -0x48(%ebp),%esi
f0104e71:	89 73 08             	mov    %esi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104e74:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0104e77:	8b 4e 08             	mov    0x8(%esi),%ecx
f0104e7a:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0104e7d:	29 cf                	sub    %ecx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0104e7f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104e82:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0104e85:	eb 0f                	jmp    f0104e96 <debuginfo_eip+0x1ba>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104e87:	89 7b 10             	mov    %edi,0x10(%ebx)
		lline = lfile;
f0104e8a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e8d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104e90:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104e93:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104e96:	83 ec 08             	sub    $0x8,%esp
f0104e99:	6a 3a                	push   $0x3a
f0104e9b:	ff 73 08             	pushl  0x8(%ebx)
f0104e9e:	e8 af 08 00 00       	call   f0105752 <strfind>
f0104ea3:	2b 43 08             	sub    0x8(%ebx),%eax
f0104ea6:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.


	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104ea9:	83 c4 08             	add    $0x8,%esp
f0104eac:	57                   	push   %edi
f0104ead:	6a 44                	push   $0x44
f0104eaf:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104eb2:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104eb5:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0104eb8:	89 f0                	mov    %esi,%eax
f0104eba:	e8 27 fd ff ff       	call   f0104be6 <stab_binsearch>
	if (lline == 0)
f0104ebf:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0104ec2:	83 c4 10             	add    $0x10,%esp
f0104ec5:	85 d2                	test   %edx,%edx
f0104ec7:	0f 84 e6 00 00 00    	je     f0104fb3 <debuginfo_eip+0x2d7>
		return -1;
	// cprintf("[+] %d, %d, %d, %x\n", lline, rline, lfun, stabs[lfun].n_value);
	info->eip_line = stabs[rline].n_desc;
f0104ecd:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104ed0:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104ed3:	0f b7 44 86 06       	movzwl 0x6(%esi,%eax,4),%eax
f0104ed8:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104edb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104ede:	89 d0                	mov    %edx,%eax
f0104ee0:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104ee3:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0104ee6:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0104eea:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104eed:	eb 0a                	jmp    f0104ef9 <debuginfo_eip+0x21d>
f0104eef:	83 e8 01             	sub    $0x1,%eax
f0104ef2:	83 ea 0c             	sub    $0xc,%edx
f0104ef5:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0104ef9:	39 c7                	cmp    %eax,%edi
f0104efb:	7e 05                	jle    f0104f02 <debuginfo_eip+0x226>
f0104efd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104f00:	eb 47                	jmp    f0104f49 <debuginfo_eip+0x26d>
	       && stabs[lline].n_type != N_SOL
f0104f02:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104f06:	80 f9 84             	cmp    $0x84,%cl
f0104f09:	75 0e                	jne    f0104f19 <debuginfo_eip+0x23d>
f0104f0b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104f0e:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104f12:	74 1c                	je     f0104f30 <debuginfo_eip+0x254>
f0104f14:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104f17:	eb 17                	jmp    f0104f30 <debuginfo_eip+0x254>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104f19:	80 f9 64             	cmp    $0x64,%cl
f0104f1c:	75 d1                	jne    f0104eef <debuginfo_eip+0x213>
f0104f1e:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0104f22:	74 cb                	je     f0104eef <debuginfo_eip+0x213>
f0104f24:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104f27:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104f2b:	74 03                	je     f0104f30 <debuginfo_eip+0x254>
f0104f2d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104f30:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104f33:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104f36:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0104f39:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104f3c:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0104f3f:	29 f8                	sub    %edi,%eax
f0104f41:	39 c2                	cmp    %eax,%edx
f0104f43:	73 04                	jae    f0104f49 <debuginfo_eip+0x26d>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104f45:	01 fa                	add    %edi,%edx
f0104f47:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104f49:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104f4c:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104f4f:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104f54:	39 f2                	cmp    %esi,%edx
f0104f56:	7d 67                	jge    f0104fbf <debuginfo_eip+0x2e3>
		for (lline = lfun + 1;
f0104f58:	83 c2 01             	add    $0x1,%edx
f0104f5b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104f5e:	89 d0                	mov    %edx,%eax
f0104f60:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104f63:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104f66:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0104f69:	eb 04                	jmp    f0104f6f <debuginfo_eip+0x293>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104f6b:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104f6f:	39 c6                	cmp    %eax,%esi
f0104f71:	7e 47                	jle    f0104fba <debuginfo_eip+0x2de>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104f73:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104f77:	83 c0 01             	add    $0x1,%eax
f0104f7a:	83 c2 0c             	add    $0xc,%edx
f0104f7d:	80 f9 a0             	cmp    $0xa0,%cl
f0104f80:	74 e9                	je     f0104f6b <debuginfo_eip+0x28f>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104f82:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f87:	eb 36                	jmp    f0104fbf <debuginfo_eip+0x2e3>
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0 ||
			user_mem_check(curenv, stabs, stab_end-stabs, PTE_U) < 0 ||
			user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U) < 0
		)
			return -1;
f0104f89:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f8e:	eb 2f                	jmp    f0104fbf <debuginfo_eip+0x2e3>
f0104f90:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f95:	eb 28                	jmp    f0104fbf <debuginfo_eip+0x2e3>
f0104f97:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f9c:	eb 21                	jmp    f0104fbf <debuginfo_eip+0x2e3>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104f9e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104fa3:	eb 1a                	jmp    f0104fbf <debuginfo_eip+0x2e3>
f0104fa5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104faa:	eb 13                	jmp    f0104fbf <debuginfo_eip+0x2e3>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0104fac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104fb1:	eb 0c                	jmp    f0104fbf <debuginfo_eip+0x2e3>
	// Your code here.


	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline == 0)
		return -1;
f0104fb3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104fb8:	eb 05                	jmp    f0104fbf <debuginfo_eip+0x2e3>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104fba:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104fbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104fc2:	5b                   	pop    %ebx
f0104fc3:	5e                   	pop    %esi
f0104fc4:	5f                   	pop    %edi
f0104fc5:	5d                   	pop    %ebp
f0104fc6:	c3                   	ret    

f0104fc7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104fc7:	55                   	push   %ebp
f0104fc8:	89 e5                	mov    %esp,%ebp
f0104fca:	57                   	push   %edi
f0104fcb:	56                   	push   %esi
f0104fcc:	53                   	push   %ebx
f0104fcd:	83 ec 1c             	sub    $0x1c,%esp
f0104fd0:	89 c7                	mov    %eax,%edi
f0104fd2:	89 d6                	mov    %edx,%esi
f0104fd4:	8b 45 08             	mov    0x8(%ebp),%eax
f0104fd7:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104fda:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104fdd:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104fe0:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104fe3:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104fe8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104feb:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104fee:	39 d3                	cmp    %edx,%ebx
f0104ff0:	72 05                	jb     f0104ff7 <printnum+0x30>
f0104ff2:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104ff5:	77 45                	ja     f010503c <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104ff7:	83 ec 0c             	sub    $0xc,%esp
f0104ffa:	ff 75 18             	pushl  0x18(%ebp)
f0104ffd:	8b 45 14             	mov    0x14(%ebp),%eax
f0105000:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0105003:	53                   	push   %ebx
f0105004:	ff 75 10             	pushl  0x10(%ebp)
f0105007:	83 ec 08             	sub    $0x8,%esp
f010500a:	ff 75 e4             	pushl  -0x1c(%ebp)
f010500d:	ff 75 e0             	pushl  -0x20(%ebp)
f0105010:	ff 75 dc             	pushl  -0x24(%ebp)
f0105013:	ff 75 d8             	pushl  -0x28(%ebp)
f0105016:	e8 d5 16 00 00       	call   f01066f0 <__udivdi3>
f010501b:	83 c4 18             	add    $0x18,%esp
f010501e:	52                   	push   %edx
f010501f:	50                   	push   %eax
f0105020:	89 f2                	mov    %esi,%edx
f0105022:	89 f8                	mov    %edi,%eax
f0105024:	e8 9e ff ff ff       	call   f0104fc7 <printnum>
f0105029:	83 c4 20             	add    $0x20,%esp
f010502c:	eb 18                	jmp    f0105046 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f010502e:	83 ec 08             	sub    $0x8,%esp
f0105031:	56                   	push   %esi
f0105032:	ff 75 18             	pushl  0x18(%ebp)
f0105035:	ff d7                	call   *%edi
f0105037:	83 c4 10             	add    $0x10,%esp
f010503a:	eb 03                	jmp    f010503f <printnum+0x78>
f010503c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f010503f:	83 eb 01             	sub    $0x1,%ebx
f0105042:	85 db                	test   %ebx,%ebx
f0105044:	7f e8                	jg     f010502e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0105046:	83 ec 08             	sub    $0x8,%esp
f0105049:	56                   	push   %esi
f010504a:	83 ec 04             	sub    $0x4,%esp
f010504d:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105050:	ff 75 e0             	pushl  -0x20(%ebp)
f0105053:	ff 75 dc             	pushl  -0x24(%ebp)
f0105056:	ff 75 d8             	pushl  -0x28(%ebp)
f0105059:	e8 c2 17 00 00       	call   f0106820 <__umoddi3>
f010505e:	83 c4 14             	add    $0x14,%esp
f0105061:	0f be 80 d2 82 10 f0 	movsbl -0xfef7d2e(%eax),%eax
f0105068:	50                   	push   %eax
f0105069:	ff d7                	call   *%edi
}
f010506b:	83 c4 10             	add    $0x10,%esp
f010506e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105071:	5b                   	pop    %ebx
f0105072:	5e                   	pop    %esi
f0105073:	5f                   	pop    %edi
f0105074:	5d                   	pop    %ebp
f0105075:	c3                   	ret    

f0105076 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0105076:	55                   	push   %ebp
f0105077:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0105079:	83 fa 01             	cmp    $0x1,%edx
f010507c:	7e 0e                	jle    f010508c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f010507e:	8b 10                	mov    (%eax),%edx
f0105080:	8d 4a 08             	lea    0x8(%edx),%ecx
f0105083:	89 08                	mov    %ecx,(%eax)
f0105085:	8b 02                	mov    (%edx),%eax
f0105087:	8b 52 04             	mov    0x4(%edx),%edx
f010508a:	eb 22                	jmp    f01050ae <getuint+0x38>
	else if (lflag)
f010508c:	85 d2                	test   %edx,%edx
f010508e:	74 10                	je     f01050a0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0105090:	8b 10                	mov    (%eax),%edx
f0105092:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105095:	89 08                	mov    %ecx,(%eax)
f0105097:	8b 02                	mov    (%edx),%eax
f0105099:	ba 00 00 00 00       	mov    $0x0,%edx
f010509e:	eb 0e                	jmp    f01050ae <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f01050a0:	8b 10                	mov    (%eax),%edx
f01050a2:	8d 4a 04             	lea    0x4(%edx),%ecx
f01050a5:	89 08                	mov    %ecx,(%eax)
f01050a7:	8b 02                	mov    (%edx),%eax
f01050a9:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01050ae:	5d                   	pop    %ebp
f01050af:	c3                   	ret    

f01050b0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01050b0:	55                   	push   %ebp
f01050b1:	89 e5                	mov    %esp,%ebp
f01050b3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01050b6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01050ba:	8b 10                	mov    (%eax),%edx
f01050bc:	3b 50 04             	cmp    0x4(%eax),%edx
f01050bf:	73 0a                	jae    f01050cb <sprintputch+0x1b>
		*b->buf++ = ch;
f01050c1:	8d 4a 01             	lea    0x1(%edx),%ecx
f01050c4:	89 08                	mov    %ecx,(%eax)
f01050c6:	8b 45 08             	mov    0x8(%ebp),%eax
f01050c9:	88 02                	mov    %al,(%edx)
}
f01050cb:	5d                   	pop    %ebp
f01050cc:	c3                   	ret    

f01050cd <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01050cd:	55                   	push   %ebp
f01050ce:	89 e5                	mov    %esp,%ebp
f01050d0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01050d3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01050d6:	50                   	push   %eax
f01050d7:	ff 75 10             	pushl  0x10(%ebp)
f01050da:	ff 75 0c             	pushl  0xc(%ebp)
f01050dd:	ff 75 08             	pushl  0x8(%ebp)
f01050e0:	e8 05 00 00 00       	call   f01050ea <vprintfmt>
	va_end(ap);
}
f01050e5:	83 c4 10             	add    $0x10,%esp
f01050e8:	c9                   	leave  
f01050e9:	c3                   	ret    

f01050ea <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01050ea:	55                   	push   %ebp
f01050eb:	89 e5                	mov    %esp,%ebp
f01050ed:	57                   	push   %edi
f01050ee:	56                   	push   %esi
f01050ef:	53                   	push   %ebx
f01050f0:	83 ec 2c             	sub    $0x2c,%esp
f01050f3:	8b 75 08             	mov    0x8(%ebp),%esi
f01050f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01050f9:	8b 7d 10             	mov    0x10(%ebp),%edi
f01050fc:	eb 12                	jmp    f0105110 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01050fe:	85 c0                	test   %eax,%eax
f0105100:	0f 84 89 03 00 00    	je     f010548f <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0105106:	83 ec 08             	sub    $0x8,%esp
f0105109:	53                   	push   %ebx
f010510a:	50                   	push   %eax
f010510b:	ff d6                	call   *%esi
f010510d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105110:	83 c7 01             	add    $0x1,%edi
f0105113:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105117:	83 f8 25             	cmp    $0x25,%eax
f010511a:	75 e2                	jne    f01050fe <vprintfmt+0x14>
f010511c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0105120:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0105127:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f010512e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0105135:	ba 00 00 00 00       	mov    $0x0,%edx
f010513a:	eb 07                	jmp    f0105143 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010513c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f010513f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105143:	8d 47 01             	lea    0x1(%edi),%eax
f0105146:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105149:	0f b6 07             	movzbl (%edi),%eax
f010514c:	0f b6 c8             	movzbl %al,%ecx
f010514f:	83 e8 23             	sub    $0x23,%eax
f0105152:	3c 55                	cmp    $0x55,%al
f0105154:	0f 87 1a 03 00 00    	ja     f0105474 <vprintfmt+0x38a>
f010515a:	0f b6 c0             	movzbl %al,%eax
f010515d:	ff 24 85 20 84 10 f0 	jmp    *-0xfef7be0(,%eax,4)
f0105164:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0105167:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f010516b:	eb d6                	jmp    f0105143 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010516d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105170:	b8 00 00 00 00       	mov    $0x0,%eax
f0105175:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0105178:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010517b:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f010517f:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0105182:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0105185:	83 fa 09             	cmp    $0x9,%edx
f0105188:	77 39                	ja     f01051c3 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f010518a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f010518d:	eb e9                	jmp    f0105178 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f010518f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105192:	8d 48 04             	lea    0x4(%eax),%ecx
f0105195:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0105198:	8b 00                	mov    (%eax),%eax
f010519a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010519d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f01051a0:	eb 27                	jmp    f01051c9 <vprintfmt+0xdf>
f01051a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01051a5:	85 c0                	test   %eax,%eax
f01051a7:	b9 00 00 00 00       	mov    $0x0,%ecx
f01051ac:	0f 49 c8             	cmovns %eax,%ecx
f01051af:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01051b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01051b5:	eb 8c                	jmp    f0105143 <vprintfmt+0x59>
f01051b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f01051ba:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f01051c1:	eb 80                	jmp    f0105143 <vprintfmt+0x59>
f01051c3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01051c6:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f01051c9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01051cd:	0f 89 70 ff ff ff    	jns    f0105143 <vprintfmt+0x59>
				width = precision, precision = -1;
f01051d3:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01051d6:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01051d9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f01051e0:	e9 5e ff ff ff       	jmp    f0105143 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01051e5:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01051e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f01051eb:	e9 53 ff ff ff       	jmp    f0105143 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01051f0:	8b 45 14             	mov    0x14(%ebp),%eax
f01051f3:	8d 50 04             	lea    0x4(%eax),%edx
f01051f6:	89 55 14             	mov    %edx,0x14(%ebp)
f01051f9:	83 ec 08             	sub    $0x8,%esp
f01051fc:	53                   	push   %ebx
f01051fd:	ff 30                	pushl  (%eax)
f01051ff:	ff d6                	call   *%esi
			break;
f0105201:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105204:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0105207:	e9 04 ff ff ff       	jmp    f0105110 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f010520c:	8b 45 14             	mov    0x14(%ebp),%eax
f010520f:	8d 50 04             	lea    0x4(%eax),%edx
f0105212:	89 55 14             	mov    %edx,0x14(%ebp)
f0105215:	8b 00                	mov    (%eax),%eax
f0105217:	99                   	cltd   
f0105218:	31 d0                	xor    %edx,%eax
f010521a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010521c:	83 f8 0f             	cmp    $0xf,%eax
f010521f:	7f 0b                	jg     f010522c <vprintfmt+0x142>
f0105221:	8b 14 85 80 85 10 f0 	mov    -0xfef7a80(,%eax,4),%edx
f0105228:	85 d2                	test   %edx,%edx
f010522a:	75 18                	jne    f0105244 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f010522c:	50                   	push   %eax
f010522d:	68 ea 82 10 f0       	push   $0xf01082ea
f0105232:	53                   	push   %ebx
f0105233:	56                   	push   %esi
f0105234:	e8 94 fe ff ff       	call   f01050cd <printfmt>
f0105239:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010523c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f010523f:	e9 cc fe ff ff       	jmp    f0105110 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0105244:	52                   	push   %edx
f0105245:	68 97 6f 10 f0       	push   $0xf0106f97
f010524a:	53                   	push   %ebx
f010524b:	56                   	push   %esi
f010524c:	e8 7c fe ff ff       	call   f01050cd <printfmt>
f0105251:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105254:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105257:	e9 b4 fe ff ff       	jmp    f0105110 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f010525c:	8b 45 14             	mov    0x14(%ebp),%eax
f010525f:	8d 50 04             	lea    0x4(%eax),%edx
f0105262:	89 55 14             	mov    %edx,0x14(%ebp)
f0105265:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0105267:	85 ff                	test   %edi,%edi
f0105269:	b8 e3 82 10 f0       	mov    $0xf01082e3,%eax
f010526e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0105271:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105275:	0f 8e 94 00 00 00    	jle    f010530f <vprintfmt+0x225>
f010527b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f010527f:	0f 84 98 00 00 00    	je     f010531d <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105285:	83 ec 08             	sub    $0x8,%esp
f0105288:	ff 75 d0             	pushl  -0x30(%ebp)
f010528b:	57                   	push   %edi
f010528c:	e8 77 03 00 00       	call   f0105608 <strnlen>
f0105291:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105294:	29 c1                	sub    %eax,%ecx
f0105296:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0105299:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f010529c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f01052a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01052a3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01052a6:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01052a8:	eb 0f                	jmp    f01052b9 <vprintfmt+0x1cf>
					putch(padc, putdat);
f01052aa:	83 ec 08             	sub    $0x8,%esp
f01052ad:	53                   	push   %ebx
f01052ae:	ff 75 e0             	pushl  -0x20(%ebp)
f01052b1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01052b3:	83 ef 01             	sub    $0x1,%edi
f01052b6:	83 c4 10             	add    $0x10,%esp
f01052b9:	85 ff                	test   %edi,%edi
f01052bb:	7f ed                	jg     f01052aa <vprintfmt+0x1c0>
f01052bd:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01052c0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01052c3:	85 c9                	test   %ecx,%ecx
f01052c5:	b8 00 00 00 00       	mov    $0x0,%eax
f01052ca:	0f 49 c1             	cmovns %ecx,%eax
f01052cd:	29 c1                	sub    %eax,%ecx
f01052cf:	89 75 08             	mov    %esi,0x8(%ebp)
f01052d2:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01052d5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01052d8:	89 cb                	mov    %ecx,%ebx
f01052da:	eb 4d                	jmp    f0105329 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01052dc:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01052e0:	74 1b                	je     f01052fd <vprintfmt+0x213>
f01052e2:	0f be c0             	movsbl %al,%eax
f01052e5:	83 e8 20             	sub    $0x20,%eax
f01052e8:	83 f8 5e             	cmp    $0x5e,%eax
f01052eb:	76 10                	jbe    f01052fd <vprintfmt+0x213>
					putch('?', putdat);
f01052ed:	83 ec 08             	sub    $0x8,%esp
f01052f0:	ff 75 0c             	pushl  0xc(%ebp)
f01052f3:	6a 3f                	push   $0x3f
f01052f5:	ff 55 08             	call   *0x8(%ebp)
f01052f8:	83 c4 10             	add    $0x10,%esp
f01052fb:	eb 0d                	jmp    f010530a <vprintfmt+0x220>
				else
					putch(ch, putdat);
f01052fd:	83 ec 08             	sub    $0x8,%esp
f0105300:	ff 75 0c             	pushl  0xc(%ebp)
f0105303:	52                   	push   %edx
f0105304:	ff 55 08             	call   *0x8(%ebp)
f0105307:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010530a:	83 eb 01             	sub    $0x1,%ebx
f010530d:	eb 1a                	jmp    f0105329 <vprintfmt+0x23f>
f010530f:	89 75 08             	mov    %esi,0x8(%ebp)
f0105312:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105315:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105318:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010531b:	eb 0c                	jmp    f0105329 <vprintfmt+0x23f>
f010531d:	89 75 08             	mov    %esi,0x8(%ebp)
f0105320:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105323:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105326:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105329:	83 c7 01             	add    $0x1,%edi
f010532c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105330:	0f be d0             	movsbl %al,%edx
f0105333:	85 d2                	test   %edx,%edx
f0105335:	74 23                	je     f010535a <vprintfmt+0x270>
f0105337:	85 f6                	test   %esi,%esi
f0105339:	78 a1                	js     f01052dc <vprintfmt+0x1f2>
f010533b:	83 ee 01             	sub    $0x1,%esi
f010533e:	79 9c                	jns    f01052dc <vprintfmt+0x1f2>
f0105340:	89 df                	mov    %ebx,%edi
f0105342:	8b 75 08             	mov    0x8(%ebp),%esi
f0105345:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105348:	eb 18                	jmp    f0105362 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010534a:	83 ec 08             	sub    $0x8,%esp
f010534d:	53                   	push   %ebx
f010534e:	6a 20                	push   $0x20
f0105350:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105352:	83 ef 01             	sub    $0x1,%edi
f0105355:	83 c4 10             	add    $0x10,%esp
f0105358:	eb 08                	jmp    f0105362 <vprintfmt+0x278>
f010535a:	89 df                	mov    %ebx,%edi
f010535c:	8b 75 08             	mov    0x8(%ebp),%esi
f010535f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105362:	85 ff                	test   %edi,%edi
f0105364:	7f e4                	jg     f010534a <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105366:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105369:	e9 a2 fd ff ff       	jmp    f0105110 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010536e:	83 fa 01             	cmp    $0x1,%edx
f0105371:	7e 16                	jle    f0105389 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0105373:	8b 45 14             	mov    0x14(%ebp),%eax
f0105376:	8d 50 08             	lea    0x8(%eax),%edx
f0105379:	89 55 14             	mov    %edx,0x14(%ebp)
f010537c:	8b 50 04             	mov    0x4(%eax),%edx
f010537f:	8b 00                	mov    (%eax),%eax
f0105381:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105384:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105387:	eb 32                	jmp    f01053bb <vprintfmt+0x2d1>
	else if (lflag)
f0105389:	85 d2                	test   %edx,%edx
f010538b:	74 18                	je     f01053a5 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f010538d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105390:	8d 50 04             	lea    0x4(%eax),%edx
f0105393:	89 55 14             	mov    %edx,0x14(%ebp)
f0105396:	8b 00                	mov    (%eax),%eax
f0105398:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010539b:	89 c1                	mov    %eax,%ecx
f010539d:	c1 f9 1f             	sar    $0x1f,%ecx
f01053a0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01053a3:	eb 16                	jmp    f01053bb <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f01053a5:	8b 45 14             	mov    0x14(%ebp),%eax
f01053a8:	8d 50 04             	lea    0x4(%eax),%edx
f01053ab:	89 55 14             	mov    %edx,0x14(%ebp)
f01053ae:	8b 00                	mov    (%eax),%eax
f01053b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01053b3:	89 c1                	mov    %eax,%ecx
f01053b5:	c1 f9 1f             	sar    $0x1f,%ecx
f01053b8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01053bb:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01053be:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01053c1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01053c6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01053ca:	79 74                	jns    f0105440 <vprintfmt+0x356>
				putch('-', putdat);
f01053cc:	83 ec 08             	sub    $0x8,%esp
f01053cf:	53                   	push   %ebx
f01053d0:	6a 2d                	push   $0x2d
f01053d2:	ff d6                	call   *%esi
				num = -(long long) num;
f01053d4:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01053d7:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01053da:	f7 d8                	neg    %eax
f01053dc:	83 d2 00             	adc    $0x0,%edx
f01053df:	f7 da                	neg    %edx
f01053e1:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f01053e4:	b9 0a 00 00 00       	mov    $0xa,%ecx
f01053e9:	eb 55                	jmp    f0105440 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01053eb:	8d 45 14             	lea    0x14(%ebp),%eax
f01053ee:	e8 83 fc ff ff       	call   f0105076 <getuint>
			base = 10;
f01053f3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f01053f8:	eb 46                	jmp    f0105440 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
f01053fa:	8d 45 14             	lea    0x14(%ebp),%eax
f01053fd:	e8 74 fc ff ff       	call   f0105076 <getuint>
			base = 8;
f0105402:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0105407:	eb 37                	jmp    f0105440 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
f0105409:	83 ec 08             	sub    $0x8,%esp
f010540c:	53                   	push   %ebx
f010540d:	6a 30                	push   $0x30
f010540f:	ff d6                	call   *%esi
			putch('x', putdat);
f0105411:	83 c4 08             	add    $0x8,%esp
f0105414:	53                   	push   %ebx
f0105415:	6a 78                	push   $0x78
f0105417:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0105419:	8b 45 14             	mov    0x14(%ebp),%eax
f010541c:	8d 50 04             	lea    0x4(%eax),%edx
f010541f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0105422:	8b 00                	mov    (%eax),%eax
f0105424:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0105429:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f010542c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0105431:	eb 0d                	jmp    f0105440 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0105433:	8d 45 14             	lea    0x14(%ebp),%eax
f0105436:	e8 3b fc ff ff       	call   f0105076 <getuint>
			base = 16;
f010543b:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105440:	83 ec 0c             	sub    $0xc,%esp
f0105443:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0105447:	57                   	push   %edi
f0105448:	ff 75 e0             	pushl  -0x20(%ebp)
f010544b:	51                   	push   %ecx
f010544c:	52                   	push   %edx
f010544d:	50                   	push   %eax
f010544e:	89 da                	mov    %ebx,%edx
f0105450:	89 f0                	mov    %esi,%eax
f0105452:	e8 70 fb ff ff       	call   f0104fc7 <printnum>
			break;
f0105457:	83 c4 20             	add    $0x20,%esp
f010545a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010545d:	e9 ae fc ff ff       	jmp    f0105110 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105462:	83 ec 08             	sub    $0x8,%esp
f0105465:	53                   	push   %ebx
f0105466:	51                   	push   %ecx
f0105467:	ff d6                	call   *%esi
			break;
f0105469:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010546c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f010546f:	e9 9c fc ff ff       	jmp    f0105110 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105474:	83 ec 08             	sub    $0x8,%esp
f0105477:	53                   	push   %ebx
f0105478:	6a 25                	push   $0x25
f010547a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f010547c:	83 c4 10             	add    $0x10,%esp
f010547f:	eb 03                	jmp    f0105484 <vprintfmt+0x39a>
f0105481:	83 ef 01             	sub    $0x1,%edi
f0105484:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0105488:	75 f7                	jne    f0105481 <vprintfmt+0x397>
f010548a:	e9 81 fc ff ff       	jmp    f0105110 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f010548f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105492:	5b                   	pop    %ebx
f0105493:	5e                   	pop    %esi
f0105494:	5f                   	pop    %edi
f0105495:	5d                   	pop    %ebp
f0105496:	c3                   	ret    

f0105497 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105497:	55                   	push   %ebp
f0105498:	89 e5                	mov    %esp,%ebp
f010549a:	83 ec 18             	sub    $0x18,%esp
f010549d:	8b 45 08             	mov    0x8(%ebp),%eax
f01054a0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01054a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01054a6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01054aa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01054ad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01054b4:	85 c0                	test   %eax,%eax
f01054b6:	74 26                	je     f01054de <vsnprintf+0x47>
f01054b8:	85 d2                	test   %edx,%edx
f01054ba:	7e 22                	jle    f01054de <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01054bc:	ff 75 14             	pushl  0x14(%ebp)
f01054bf:	ff 75 10             	pushl  0x10(%ebp)
f01054c2:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01054c5:	50                   	push   %eax
f01054c6:	68 b0 50 10 f0       	push   $0xf01050b0
f01054cb:	e8 1a fc ff ff       	call   f01050ea <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01054d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01054d3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01054d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01054d9:	83 c4 10             	add    $0x10,%esp
f01054dc:	eb 05                	jmp    f01054e3 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01054de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01054e3:	c9                   	leave  
f01054e4:	c3                   	ret    

f01054e5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01054e5:	55                   	push   %ebp
f01054e6:	89 e5                	mov    %esp,%ebp
f01054e8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01054eb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01054ee:	50                   	push   %eax
f01054ef:	ff 75 10             	pushl  0x10(%ebp)
f01054f2:	ff 75 0c             	pushl  0xc(%ebp)
f01054f5:	ff 75 08             	pushl  0x8(%ebp)
f01054f8:	e8 9a ff ff ff       	call   f0105497 <vsnprintf>
	va_end(ap);

	return rc;
}
f01054fd:	c9                   	leave  
f01054fe:	c3                   	ret    

f01054ff <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01054ff:	55                   	push   %ebp
f0105500:	89 e5                	mov    %esp,%ebp
f0105502:	57                   	push   %edi
f0105503:	56                   	push   %esi
f0105504:	53                   	push   %ebx
f0105505:	83 ec 0c             	sub    $0xc,%esp
f0105508:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f010550b:	85 c0                	test   %eax,%eax
f010550d:	74 11                	je     f0105520 <readline+0x21>
		cprintf("%s", prompt);
f010550f:	83 ec 08             	sub    $0x8,%esp
f0105512:	50                   	push   %eax
f0105513:	68 97 6f 10 f0       	push   $0xf0106f97
f0105518:	e8 65 e4 ff ff       	call   f0103982 <cprintf>
f010551d:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f0105520:	83 ec 0c             	sub    $0xc,%esp
f0105523:	6a 00                	push   $0x0
f0105525:	e8 83 b2 ff ff       	call   f01007ad <iscons>
f010552a:	89 c7                	mov    %eax,%edi
f010552c:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
f010552f:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0105534:	e8 63 b2 ff ff       	call   f010079c <getchar>
f0105539:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010553b:	85 c0                	test   %eax,%eax
f010553d:	79 29                	jns    f0105568 <readline+0x69>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f010553f:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
f0105544:	83 fb f8             	cmp    $0xfffffff8,%ebx
f0105547:	0f 84 9b 00 00 00    	je     f01055e8 <readline+0xe9>
				cprintf("read error: %e\n", c);
f010554d:	83 ec 08             	sub    $0x8,%esp
f0105550:	53                   	push   %ebx
f0105551:	68 df 85 10 f0       	push   $0xf01085df
f0105556:	e8 27 e4 ff ff       	call   f0103982 <cprintf>
f010555b:	83 c4 10             	add    $0x10,%esp
			return NULL;
f010555e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105563:	e9 80 00 00 00       	jmp    f01055e8 <readline+0xe9>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105568:	83 f8 08             	cmp    $0x8,%eax
f010556b:	0f 94 c2             	sete   %dl
f010556e:	83 f8 7f             	cmp    $0x7f,%eax
f0105571:	0f 94 c0             	sete   %al
f0105574:	08 c2                	or     %al,%dl
f0105576:	74 1a                	je     f0105592 <readline+0x93>
f0105578:	85 f6                	test   %esi,%esi
f010557a:	7e 16                	jle    f0105592 <readline+0x93>
			if (echoing)
f010557c:	85 ff                	test   %edi,%edi
f010557e:	74 0d                	je     f010558d <readline+0x8e>
				cputchar('\b');
f0105580:	83 ec 0c             	sub    $0xc,%esp
f0105583:	6a 08                	push   $0x8
f0105585:	e8 02 b2 ff ff       	call   f010078c <cputchar>
f010558a:	83 c4 10             	add    $0x10,%esp
			i--;
f010558d:	83 ee 01             	sub    $0x1,%esi
f0105590:	eb a2                	jmp    f0105534 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105592:	83 fb 1f             	cmp    $0x1f,%ebx
f0105595:	7e 26                	jle    f01055bd <readline+0xbe>
f0105597:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010559d:	7f 1e                	jg     f01055bd <readline+0xbe>
			if (echoing)
f010559f:	85 ff                	test   %edi,%edi
f01055a1:	74 0c                	je     f01055af <readline+0xb0>
				cputchar(c);
f01055a3:	83 ec 0c             	sub    $0xc,%esp
f01055a6:	53                   	push   %ebx
f01055a7:	e8 e0 b1 ff ff       	call   f010078c <cputchar>
f01055ac:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01055af:	88 9e 80 9a 2a f0    	mov    %bl,-0xfd56580(%esi)
f01055b5:	8d 76 01             	lea    0x1(%esi),%esi
f01055b8:	e9 77 ff ff ff       	jmp    f0105534 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f01055bd:	83 fb 0a             	cmp    $0xa,%ebx
f01055c0:	74 09                	je     f01055cb <readline+0xcc>
f01055c2:	83 fb 0d             	cmp    $0xd,%ebx
f01055c5:	0f 85 69 ff ff ff    	jne    f0105534 <readline+0x35>
			if (echoing)
f01055cb:	85 ff                	test   %edi,%edi
f01055cd:	74 0d                	je     f01055dc <readline+0xdd>
				cputchar('\n');
f01055cf:	83 ec 0c             	sub    $0xc,%esp
f01055d2:	6a 0a                	push   $0xa
f01055d4:	e8 b3 b1 ff ff       	call   f010078c <cputchar>
f01055d9:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01055dc:	c6 86 80 9a 2a f0 00 	movb   $0x0,-0xfd56580(%esi)
			return buf;
f01055e3:	b8 80 9a 2a f0       	mov    $0xf02a9a80,%eax
		}
	}
}
f01055e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01055eb:	5b                   	pop    %ebx
f01055ec:	5e                   	pop    %esi
f01055ed:	5f                   	pop    %edi
f01055ee:	5d                   	pop    %ebp
f01055ef:	c3                   	ret    

f01055f0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01055f0:	55                   	push   %ebp
f01055f1:	89 e5                	mov    %esp,%ebp
f01055f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01055f6:	b8 00 00 00 00       	mov    $0x0,%eax
f01055fb:	eb 03                	jmp    f0105600 <strlen+0x10>
		n++;
f01055fd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105600:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105604:	75 f7                	jne    f01055fd <strlen+0xd>
		n++;
	return n;
}
f0105606:	5d                   	pop    %ebp
f0105607:	c3                   	ret    

f0105608 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105608:	55                   	push   %ebp
f0105609:	89 e5                	mov    %esp,%ebp
f010560b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010560e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105611:	ba 00 00 00 00       	mov    $0x0,%edx
f0105616:	eb 03                	jmp    f010561b <strnlen+0x13>
		n++;
f0105618:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010561b:	39 c2                	cmp    %eax,%edx
f010561d:	74 08                	je     f0105627 <strnlen+0x1f>
f010561f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0105623:	75 f3                	jne    f0105618 <strnlen+0x10>
f0105625:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0105627:	5d                   	pop    %ebp
f0105628:	c3                   	ret    

f0105629 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105629:	55                   	push   %ebp
f010562a:	89 e5                	mov    %esp,%ebp
f010562c:	53                   	push   %ebx
f010562d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105630:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105633:	89 c2                	mov    %eax,%edx
f0105635:	83 c2 01             	add    $0x1,%edx
f0105638:	83 c1 01             	add    $0x1,%ecx
f010563b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010563f:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105642:	84 db                	test   %bl,%bl
f0105644:	75 ef                	jne    f0105635 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0105646:	5b                   	pop    %ebx
f0105647:	5d                   	pop    %ebp
f0105648:	c3                   	ret    

f0105649 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105649:	55                   	push   %ebp
f010564a:	89 e5                	mov    %esp,%ebp
f010564c:	53                   	push   %ebx
f010564d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105650:	53                   	push   %ebx
f0105651:	e8 9a ff ff ff       	call   f01055f0 <strlen>
f0105656:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0105659:	ff 75 0c             	pushl  0xc(%ebp)
f010565c:	01 d8                	add    %ebx,%eax
f010565e:	50                   	push   %eax
f010565f:	e8 c5 ff ff ff       	call   f0105629 <strcpy>
	return dst;
}
f0105664:	89 d8                	mov    %ebx,%eax
f0105666:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105669:	c9                   	leave  
f010566a:	c3                   	ret    

f010566b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010566b:	55                   	push   %ebp
f010566c:	89 e5                	mov    %esp,%ebp
f010566e:	56                   	push   %esi
f010566f:	53                   	push   %ebx
f0105670:	8b 75 08             	mov    0x8(%ebp),%esi
f0105673:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105676:	89 f3                	mov    %esi,%ebx
f0105678:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010567b:	89 f2                	mov    %esi,%edx
f010567d:	eb 0f                	jmp    f010568e <strncpy+0x23>
		*dst++ = *src;
f010567f:	83 c2 01             	add    $0x1,%edx
f0105682:	0f b6 01             	movzbl (%ecx),%eax
f0105685:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105688:	80 39 01             	cmpb   $0x1,(%ecx)
f010568b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010568e:	39 da                	cmp    %ebx,%edx
f0105690:	75 ed                	jne    f010567f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105692:	89 f0                	mov    %esi,%eax
f0105694:	5b                   	pop    %ebx
f0105695:	5e                   	pop    %esi
f0105696:	5d                   	pop    %ebp
f0105697:	c3                   	ret    

f0105698 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105698:	55                   	push   %ebp
f0105699:	89 e5                	mov    %esp,%ebp
f010569b:	56                   	push   %esi
f010569c:	53                   	push   %ebx
f010569d:	8b 75 08             	mov    0x8(%ebp),%esi
f01056a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01056a3:	8b 55 10             	mov    0x10(%ebp),%edx
f01056a6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01056a8:	85 d2                	test   %edx,%edx
f01056aa:	74 21                	je     f01056cd <strlcpy+0x35>
f01056ac:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f01056b0:	89 f2                	mov    %esi,%edx
f01056b2:	eb 09                	jmp    f01056bd <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01056b4:	83 c2 01             	add    $0x1,%edx
f01056b7:	83 c1 01             	add    $0x1,%ecx
f01056ba:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01056bd:	39 c2                	cmp    %eax,%edx
f01056bf:	74 09                	je     f01056ca <strlcpy+0x32>
f01056c1:	0f b6 19             	movzbl (%ecx),%ebx
f01056c4:	84 db                	test   %bl,%bl
f01056c6:	75 ec                	jne    f01056b4 <strlcpy+0x1c>
f01056c8:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f01056ca:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01056cd:	29 f0                	sub    %esi,%eax
}
f01056cf:	5b                   	pop    %ebx
f01056d0:	5e                   	pop    %esi
f01056d1:	5d                   	pop    %ebp
f01056d2:	c3                   	ret    

f01056d3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01056d3:	55                   	push   %ebp
f01056d4:	89 e5                	mov    %esp,%ebp
f01056d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01056d9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01056dc:	eb 06                	jmp    f01056e4 <strcmp+0x11>
		p++, q++;
f01056de:	83 c1 01             	add    $0x1,%ecx
f01056e1:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01056e4:	0f b6 01             	movzbl (%ecx),%eax
f01056e7:	84 c0                	test   %al,%al
f01056e9:	74 04                	je     f01056ef <strcmp+0x1c>
f01056eb:	3a 02                	cmp    (%edx),%al
f01056ed:	74 ef                	je     f01056de <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01056ef:	0f b6 c0             	movzbl %al,%eax
f01056f2:	0f b6 12             	movzbl (%edx),%edx
f01056f5:	29 d0                	sub    %edx,%eax
}
f01056f7:	5d                   	pop    %ebp
f01056f8:	c3                   	ret    

f01056f9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01056f9:	55                   	push   %ebp
f01056fa:	89 e5                	mov    %esp,%ebp
f01056fc:	53                   	push   %ebx
f01056fd:	8b 45 08             	mov    0x8(%ebp),%eax
f0105700:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105703:	89 c3                	mov    %eax,%ebx
f0105705:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105708:	eb 06                	jmp    f0105710 <strncmp+0x17>
		n--, p++, q++;
f010570a:	83 c0 01             	add    $0x1,%eax
f010570d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105710:	39 d8                	cmp    %ebx,%eax
f0105712:	74 15                	je     f0105729 <strncmp+0x30>
f0105714:	0f b6 08             	movzbl (%eax),%ecx
f0105717:	84 c9                	test   %cl,%cl
f0105719:	74 04                	je     f010571f <strncmp+0x26>
f010571b:	3a 0a                	cmp    (%edx),%cl
f010571d:	74 eb                	je     f010570a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010571f:	0f b6 00             	movzbl (%eax),%eax
f0105722:	0f b6 12             	movzbl (%edx),%edx
f0105725:	29 d0                	sub    %edx,%eax
f0105727:	eb 05                	jmp    f010572e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105729:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f010572e:	5b                   	pop    %ebx
f010572f:	5d                   	pop    %ebp
f0105730:	c3                   	ret    

f0105731 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105731:	55                   	push   %ebp
f0105732:	89 e5                	mov    %esp,%ebp
f0105734:	8b 45 08             	mov    0x8(%ebp),%eax
f0105737:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010573b:	eb 07                	jmp    f0105744 <strchr+0x13>
		if (*s == c)
f010573d:	38 ca                	cmp    %cl,%dl
f010573f:	74 0f                	je     f0105750 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105741:	83 c0 01             	add    $0x1,%eax
f0105744:	0f b6 10             	movzbl (%eax),%edx
f0105747:	84 d2                	test   %dl,%dl
f0105749:	75 f2                	jne    f010573d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f010574b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105750:	5d                   	pop    %ebp
f0105751:	c3                   	ret    

f0105752 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105752:	55                   	push   %ebp
f0105753:	89 e5                	mov    %esp,%ebp
f0105755:	8b 45 08             	mov    0x8(%ebp),%eax
f0105758:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010575c:	eb 03                	jmp    f0105761 <strfind+0xf>
f010575e:	83 c0 01             	add    $0x1,%eax
f0105761:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0105764:	38 ca                	cmp    %cl,%dl
f0105766:	74 04                	je     f010576c <strfind+0x1a>
f0105768:	84 d2                	test   %dl,%dl
f010576a:	75 f2                	jne    f010575e <strfind+0xc>
			break;
	return (char *) s;
}
f010576c:	5d                   	pop    %ebp
f010576d:	c3                   	ret    

f010576e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010576e:	55                   	push   %ebp
f010576f:	89 e5                	mov    %esp,%ebp
f0105771:	57                   	push   %edi
f0105772:	56                   	push   %esi
f0105773:	53                   	push   %ebx
f0105774:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105777:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010577a:	85 c9                	test   %ecx,%ecx
f010577c:	74 36                	je     f01057b4 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010577e:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105784:	75 28                	jne    f01057ae <memset+0x40>
f0105786:	f6 c1 03             	test   $0x3,%cl
f0105789:	75 23                	jne    f01057ae <memset+0x40>
		c &= 0xFF;
f010578b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010578f:	89 d3                	mov    %edx,%ebx
f0105791:	c1 e3 08             	shl    $0x8,%ebx
f0105794:	89 d6                	mov    %edx,%esi
f0105796:	c1 e6 18             	shl    $0x18,%esi
f0105799:	89 d0                	mov    %edx,%eax
f010579b:	c1 e0 10             	shl    $0x10,%eax
f010579e:	09 f0                	or     %esi,%eax
f01057a0:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f01057a2:	89 d8                	mov    %ebx,%eax
f01057a4:	09 d0                	or     %edx,%eax
f01057a6:	c1 e9 02             	shr    $0x2,%ecx
f01057a9:	fc                   	cld    
f01057aa:	f3 ab                	rep stos %eax,%es:(%edi)
f01057ac:	eb 06                	jmp    f01057b4 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01057ae:	8b 45 0c             	mov    0xc(%ebp),%eax
f01057b1:	fc                   	cld    
f01057b2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01057b4:	89 f8                	mov    %edi,%eax
f01057b6:	5b                   	pop    %ebx
f01057b7:	5e                   	pop    %esi
f01057b8:	5f                   	pop    %edi
f01057b9:	5d                   	pop    %ebp
f01057ba:	c3                   	ret    

f01057bb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01057bb:	55                   	push   %ebp
f01057bc:	89 e5                	mov    %esp,%ebp
f01057be:	57                   	push   %edi
f01057bf:	56                   	push   %esi
f01057c0:	8b 45 08             	mov    0x8(%ebp),%eax
f01057c3:	8b 75 0c             	mov    0xc(%ebp),%esi
f01057c6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01057c9:	39 c6                	cmp    %eax,%esi
f01057cb:	73 35                	jae    f0105802 <memmove+0x47>
f01057cd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01057d0:	39 d0                	cmp    %edx,%eax
f01057d2:	73 2e                	jae    f0105802 <memmove+0x47>
		s += n;
		d += n;
f01057d4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01057d7:	89 d6                	mov    %edx,%esi
f01057d9:	09 fe                	or     %edi,%esi
f01057db:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01057e1:	75 13                	jne    f01057f6 <memmove+0x3b>
f01057e3:	f6 c1 03             	test   $0x3,%cl
f01057e6:	75 0e                	jne    f01057f6 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f01057e8:	83 ef 04             	sub    $0x4,%edi
f01057eb:	8d 72 fc             	lea    -0x4(%edx),%esi
f01057ee:	c1 e9 02             	shr    $0x2,%ecx
f01057f1:	fd                   	std    
f01057f2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01057f4:	eb 09                	jmp    f01057ff <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01057f6:	83 ef 01             	sub    $0x1,%edi
f01057f9:	8d 72 ff             	lea    -0x1(%edx),%esi
f01057fc:	fd                   	std    
f01057fd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01057ff:	fc                   	cld    
f0105800:	eb 1d                	jmp    f010581f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105802:	89 f2                	mov    %esi,%edx
f0105804:	09 c2                	or     %eax,%edx
f0105806:	f6 c2 03             	test   $0x3,%dl
f0105809:	75 0f                	jne    f010581a <memmove+0x5f>
f010580b:	f6 c1 03             	test   $0x3,%cl
f010580e:	75 0a                	jne    f010581a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0105810:	c1 e9 02             	shr    $0x2,%ecx
f0105813:	89 c7                	mov    %eax,%edi
f0105815:	fc                   	cld    
f0105816:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105818:	eb 05                	jmp    f010581f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f010581a:	89 c7                	mov    %eax,%edi
f010581c:	fc                   	cld    
f010581d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010581f:	5e                   	pop    %esi
f0105820:	5f                   	pop    %edi
f0105821:	5d                   	pop    %ebp
f0105822:	c3                   	ret    

f0105823 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105823:	55                   	push   %ebp
f0105824:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0105826:	ff 75 10             	pushl  0x10(%ebp)
f0105829:	ff 75 0c             	pushl  0xc(%ebp)
f010582c:	ff 75 08             	pushl  0x8(%ebp)
f010582f:	e8 87 ff ff ff       	call   f01057bb <memmove>
}
f0105834:	c9                   	leave  
f0105835:	c3                   	ret    

f0105836 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105836:	55                   	push   %ebp
f0105837:	89 e5                	mov    %esp,%ebp
f0105839:	56                   	push   %esi
f010583a:	53                   	push   %ebx
f010583b:	8b 45 08             	mov    0x8(%ebp),%eax
f010583e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105841:	89 c6                	mov    %eax,%esi
f0105843:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105846:	eb 1a                	jmp    f0105862 <memcmp+0x2c>
		if (*s1 != *s2)
f0105848:	0f b6 08             	movzbl (%eax),%ecx
f010584b:	0f b6 1a             	movzbl (%edx),%ebx
f010584e:	38 d9                	cmp    %bl,%cl
f0105850:	74 0a                	je     f010585c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0105852:	0f b6 c1             	movzbl %cl,%eax
f0105855:	0f b6 db             	movzbl %bl,%ebx
f0105858:	29 d8                	sub    %ebx,%eax
f010585a:	eb 0f                	jmp    f010586b <memcmp+0x35>
		s1++, s2++;
f010585c:	83 c0 01             	add    $0x1,%eax
f010585f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105862:	39 f0                	cmp    %esi,%eax
f0105864:	75 e2                	jne    f0105848 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0105866:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010586b:	5b                   	pop    %ebx
f010586c:	5e                   	pop    %esi
f010586d:	5d                   	pop    %ebp
f010586e:	c3                   	ret    

f010586f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010586f:	55                   	push   %ebp
f0105870:	89 e5                	mov    %esp,%ebp
f0105872:	53                   	push   %ebx
f0105873:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0105876:	89 c1                	mov    %eax,%ecx
f0105878:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f010587b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010587f:	eb 0a                	jmp    f010588b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105881:	0f b6 10             	movzbl (%eax),%edx
f0105884:	39 da                	cmp    %ebx,%edx
f0105886:	74 07                	je     f010588f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105888:	83 c0 01             	add    $0x1,%eax
f010588b:	39 c8                	cmp    %ecx,%eax
f010588d:	72 f2                	jb     f0105881 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f010588f:	5b                   	pop    %ebx
f0105890:	5d                   	pop    %ebp
f0105891:	c3                   	ret    

f0105892 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105892:	55                   	push   %ebp
f0105893:	89 e5                	mov    %esp,%ebp
f0105895:	57                   	push   %edi
f0105896:	56                   	push   %esi
f0105897:	53                   	push   %ebx
f0105898:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010589b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010589e:	eb 03                	jmp    f01058a3 <strtol+0x11>
		s++;
f01058a0:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01058a3:	0f b6 01             	movzbl (%ecx),%eax
f01058a6:	3c 20                	cmp    $0x20,%al
f01058a8:	74 f6                	je     f01058a0 <strtol+0xe>
f01058aa:	3c 09                	cmp    $0x9,%al
f01058ac:	74 f2                	je     f01058a0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01058ae:	3c 2b                	cmp    $0x2b,%al
f01058b0:	75 0a                	jne    f01058bc <strtol+0x2a>
		s++;
f01058b2:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01058b5:	bf 00 00 00 00       	mov    $0x0,%edi
f01058ba:	eb 11                	jmp    f01058cd <strtol+0x3b>
f01058bc:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01058c1:	3c 2d                	cmp    $0x2d,%al
f01058c3:	75 08                	jne    f01058cd <strtol+0x3b>
		s++, neg = 1;
f01058c5:	83 c1 01             	add    $0x1,%ecx
f01058c8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01058cd:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01058d3:	75 15                	jne    f01058ea <strtol+0x58>
f01058d5:	80 39 30             	cmpb   $0x30,(%ecx)
f01058d8:	75 10                	jne    f01058ea <strtol+0x58>
f01058da:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01058de:	75 7c                	jne    f010595c <strtol+0xca>
		s += 2, base = 16;
f01058e0:	83 c1 02             	add    $0x2,%ecx
f01058e3:	bb 10 00 00 00       	mov    $0x10,%ebx
f01058e8:	eb 16                	jmp    f0105900 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f01058ea:	85 db                	test   %ebx,%ebx
f01058ec:	75 12                	jne    f0105900 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01058ee:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01058f3:	80 39 30             	cmpb   $0x30,(%ecx)
f01058f6:	75 08                	jne    f0105900 <strtol+0x6e>
		s++, base = 8;
f01058f8:	83 c1 01             	add    $0x1,%ecx
f01058fb:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0105900:	b8 00 00 00 00       	mov    $0x0,%eax
f0105905:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105908:	0f b6 11             	movzbl (%ecx),%edx
f010590b:	8d 72 d0             	lea    -0x30(%edx),%esi
f010590e:	89 f3                	mov    %esi,%ebx
f0105910:	80 fb 09             	cmp    $0x9,%bl
f0105913:	77 08                	ja     f010591d <strtol+0x8b>
			dig = *s - '0';
f0105915:	0f be d2             	movsbl %dl,%edx
f0105918:	83 ea 30             	sub    $0x30,%edx
f010591b:	eb 22                	jmp    f010593f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f010591d:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105920:	89 f3                	mov    %esi,%ebx
f0105922:	80 fb 19             	cmp    $0x19,%bl
f0105925:	77 08                	ja     f010592f <strtol+0x9d>
			dig = *s - 'a' + 10;
f0105927:	0f be d2             	movsbl %dl,%edx
f010592a:	83 ea 57             	sub    $0x57,%edx
f010592d:	eb 10                	jmp    f010593f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f010592f:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105932:	89 f3                	mov    %esi,%ebx
f0105934:	80 fb 19             	cmp    $0x19,%bl
f0105937:	77 16                	ja     f010594f <strtol+0xbd>
			dig = *s - 'A' + 10;
f0105939:	0f be d2             	movsbl %dl,%edx
f010593c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f010593f:	3b 55 10             	cmp    0x10(%ebp),%edx
f0105942:	7d 0b                	jge    f010594f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f0105944:	83 c1 01             	add    $0x1,%ecx
f0105947:	0f af 45 10          	imul   0x10(%ebp),%eax
f010594b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f010594d:	eb b9                	jmp    f0105908 <strtol+0x76>

	if (endptr)
f010594f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105953:	74 0d                	je     f0105962 <strtol+0xd0>
		*endptr = (char *) s;
f0105955:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105958:	89 0e                	mov    %ecx,(%esi)
f010595a:	eb 06                	jmp    f0105962 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010595c:	85 db                	test   %ebx,%ebx
f010595e:	74 98                	je     f01058f8 <strtol+0x66>
f0105960:	eb 9e                	jmp    f0105900 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0105962:	89 c2                	mov    %eax,%edx
f0105964:	f7 da                	neg    %edx
f0105966:	85 ff                	test   %edi,%edi
f0105968:	0f 45 c2             	cmovne %edx,%eax
}
f010596b:	5b                   	pop    %ebx
f010596c:	5e                   	pop    %esi
f010596d:	5f                   	pop    %edi
f010596e:	5d                   	pop    %ebp
f010596f:	c3                   	ret    

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
f01059c0:	b8 ba 01 10 f0       	mov    $0xf01001ba,%eax
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
f0105a4b:	e8 e6 fd ff ff       	call   f0105836 <memcmp>
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
f0105b29:	e8 54 de ff ff       	call   f0103982 <cprintf>
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
f0105b69:	e8 c8 fc ff ff       	call   f0105836 <memcmp>
f0105b6e:	83 c4 10             	add    $0x10,%esp
f0105b71:	85 c0                	test   %eax,%eax
f0105b73:	74 15                	je     f0105b8a <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105b75:	83 ec 0c             	sub    $0xc,%esp
f0105b78:	68 20 86 10 f0       	push   $0xf0108620
f0105b7d:	e8 00 de ff ff       	call   f0103982 <cprintf>
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
f0105bbe:	e8 bf dd ff ff       	call   f0103982 <cprintf>
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
f0105be3:	e8 9a dd ff ff       	call   f0103982 <cprintf>
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
f0105c26:	e8 57 dd ff ff       	call   f0103982 <cprintf>
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
f0105ca8:	e8 d5 dc ff ff       	call   f0103982 <cprintf>
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
f0105cc6:	e8 b7 dc ff ff       	call   f0103982 <cprintf>
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
f0105d1c:	e8 61 dc ff ff       	call   f0103982 <cprintf>
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
f0105d38:	e8 45 dc ff ff       	call   f0103982 <cprintf>

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
f0105d51:	e8 2c dc ff ff       	call   f0103982 <cprintf>
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
f0105dc2:	e8 44 b7 ff ff       	call   f010150b <mmio_map_region>
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
f01060cf:	e8 e7 f6 ff ff       	call   f01057bb <memmove>
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
f01060ea:	e8 93 d8 ff ff       	call   f0103982 <cprintf>
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
f01060fc:	e8 db eb ff ff       	call   f0104cdc <debuginfo_eip>
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
f0106125:	e8 58 d8 ff ff       	call   f0103982 <cprintf>
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
f0106139:	e8 44 d8 ff ff       	call   f0103982 <cprintf>
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
f01061c8:	e8 b5 d7 ff ff       	call   f0103982 <cprintf>
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
f01062d4:	e8 95 f4 ff ff       	call   f010576e <memset>
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
f01063f5:	e8 88 d5 ff ff       	call   f0103982 <cprintf>
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
f01064b7:	e8 c6 d4 ff ff       	call   f0103982 <cprintf>
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
f01064d3:	e8 96 f2 ff ff       	call   f010576e <memset>
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
f0106500:	e8 7d d4 ff ff       	call   f0103982 <cprintf>
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
f010663b:	e8 42 d3 ff ff       	call   f0103982 <cprintf>
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
f010666e:	e8 0f d3 ff ff       	call   f0103982 <cprintf>
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
f010668d:	e8 dc f0 ff ff       	call   f010576e <memset>

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
