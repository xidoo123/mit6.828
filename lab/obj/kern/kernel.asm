
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
f0100015:	b8 00 e0 11 00       	mov    $0x11e000,%eax
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
f0100034:	bc 00 e0 11 f0       	mov    $0xf011e000,%esp

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
f0100048:	83 3d 80 be 22 f0 00 	cmpl   $0x0,0xf022be80
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 80 be 22 f0    	mov    %esi,0xf022be80

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 e5 58 00 00       	call   f0105946 <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 e0 5f 10 f0       	push   $0xf0105fe0
f010006d:	e8 2f 38 00 00       	call   f01038a1 <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 ff 37 00 00       	call   f010387b <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 c0 68 10 f0 	movl   $0xf01068c0,(%esp)
f0100083:	e8 19 38 00 00       	call   f01038a1 <cprintf>
	va_end(ap);
f0100088:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010008b:	83 ec 0c             	sub    $0xc,%esp
f010008e:	6a 00                	push   $0x0
f0100090:	e8 dd 08 00 00       	call   f0100972 <monitor>
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
f01000a1:	e8 82 05 00 00       	call   f0100628 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000a6:	83 ec 08             	sub    $0x8,%esp
f01000a9:	68 ac 1a 00 00       	push   $0x1aac
f01000ae:	68 4c 60 10 f0       	push   $0xf010604c
f01000b3:	e8 e9 37 00 00       	call   f01038a1 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000b8:	e8 c4 13 00 00       	call   f0101481 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000bd:	e8 f8 2f 00 00       	call   f01030ba <env_init>
	trap_init();
f01000c2:	e8 c2 38 00 00       	call   f0103989 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000c7:	e8 70 55 00 00       	call   f010563c <mp_init>
	lapic_init();
f01000cc:	e8 90 58 00 00       	call   f0105961 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000d1:	e8 f2 36 00 00       	call   f01037c8 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000d6:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f01000dd:	e8 d2 5a 00 00       	call   f0105bb4 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000e2:	83 c4 10             	add    $0x10,%esp
f01000e5:	83 3d 88 be 22 f0 07 	cmpl   $0x7,0xf022be88
f01000ec:	77 16                	ja     f0100104 <i386_init+0x6a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01000ee:	68 00 70 00 00       	push   $0x7000
f01000f3:	68 04 60 10 f0       	push   $0xf0106004
f01000f8:	6a 4e                	push   $0x4e
f01000fa:	68 67 60 10 f0       	push   $0xf0106067
f01000ff:	e8 3c ff ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100104:	83 ec 04             	sub    $0x4,%esp
f0100107:	b8 a2 55 10 f0       	mov    $0xf01055a2,%eax
f010010c:	2d 28 55 10 f0       	sub    $0xf0105528,%eax
f0100111:	50                   	push   %eax
f0100112:	68 28 55 10 f0       	push   $0xf0105528
f0100117:	68 00 70 00 f0       	push   $0xf0007000
f010011c:	e8 50 52 00 00       	call   f0105371 <memmove>
f0100121:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100124:	bb 20 c0 22 f0       	mov    $0xf022c020,%ebx
f0100129:	eb 4d                	jmp    f0100178 <i386_init+0xde>
		if (c == cpus + cpunum())  // We've started already.
f010012b:	e8 16 58 00 00       	call   f0105946 <cpunum>
f0100130:	6b c0 74             	imul   $0x74,%eax,%eax
f0100133:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f0100138:	39 c3                	cmp    %eax,%ebx
f010013a:	74 39                	je     f0100175 <i386_init+0xdb>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f010013c:	89 d8                	mov    %ebx,%eax
f010013e:	2d 20 c0 22 f0       	sub    $0xf022c020,%eax
f0100143:	c1 f8 02             	sar    $0x2,%eax
f0100146:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f010014c:	c1 e0 0f             	shl    $0xf,%eax
f010014f:	05 00 50 23 f0       	add    $0xf0235000,%eax
f0100154:	a3 84 be 22 f0       	mov    %eax,0xf022be84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100159:	83 ec 08             	sub    $0x8,%esp
f010015c:	68 00 70 00 00       	push   $0x7000
f0100161:	0f b6 03             	movzbl (%ebx),%eax
f0100164:	50                   	push   %eax
f0100165:	e8 45 59 00 00       	call   f0105aaf <lapic_startap>
f010016a:	83 c4 10             	add    $0x10,%esp
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f010016d:	8b 43 04             	mov    0x4(%ebx),%eax
f0100170:	83 f8 01             	cmp    $0x1,%eax
f0100173:	75 f8                	jne    f010016d <i386_init+0xd3>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100175:	83 c3 74             	add    $0x74,%ebx
f0100178:	6b 05 c4 c3 22 f0 74 	imul   $0x74,0xf022c3c4,%eax
f010017f:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f0100184:	39 c3                	cmp    %eax,%ebx
f0100186:	72 a3                	jb     f010012b <i386_init+0x91>
	// Starting non-boot CPUs
	boot_aps();

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100188:	83 ec 08             	sub    $0x8,%esp
f010018b:	6a 00                	push   $0x0
f010018d:	68 b4 f5 1f f0       	push   $0xf01ff5b4
f0100192:	e8 eb 30 00 00       	call   f0103282 <env_create>
	ENV_CREATE(user_dumbfork, ENV_TYPE_USER);
	// ENV_CREATE(user_primes, ENV_TYPE_USER);
#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f0100197:	e8 af 41 00 00       	call   f010434b <sched_yield>

f010019c <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f010019c:	55                   	push   %ebp
f010019d:	89 e5                	mov    %esp,%ebp
f010019f:	83 ec 08             	sub    $0x8,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01001a2:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001a7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001ac:	77 12                	ja     f01001c0 <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001ae:	50                   	push   %eax
f01001af:	68 28 60 10 f0       	push   $0xf0106028
f01001b4:	6a 65                	push   $0x65
f01001b6:	68 67 60 10 f0       	push   $0xf0106067
f01001bb:	e8 80 fe ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01001c0:	05 00 00 00 10       	add    $0x10000000,%eax
f01001c5:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001c8:	e8 79 57 00 00       	call   f0105946 <cpunum>
f01001cd:	83 ec 08             	sub    $0x8,%esp
f01001d0:	50                   	push   %eax
f01001d1:	68 73 60 10 f0       	push   $0xf0106073
f01001d6:	e8 c6 36 00 00       	call   f01038a1 <cprintf>

	lapic_init();
f01001db:	e8 81 57 00 00       	call   f0105961 <lapic_init>
	env_init_percpu();
f01001e0:	e8 a5 2e 00 00       	call   f010308a <env_init_percpu>
	trap_init_percpu();
f01001e5:	e8 cb 36 00 00       	call   f01038b5 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f01001ea:	e8 57 57 00 00       	call   f0105946 <cpunum>
f01001ef:	6b d0 74             	imul   $0x74,%eax,%edx
f01001f2:	81 c2 20 c0 22 f0    	add    $0xf022c020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01001f8:	b8 01 00 00 00       	mov    $0x1,%eax
f01001fd:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0100201:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f0100208:	e8 a7 59 00 00       	call   f0105bb4 <spin_lock>
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:

	lock_kernel();
	sched_yield();
f010020d:	e8 39 41 00 00       	call   f010434b <sched_yield>

f0100212 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100212:	55                   	push   %ebp
f0100213:	89 e5                	mov    %esp,%ebp
f0100215:	53                   	push   %ebx
f0100216:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100219:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010021c:	ff 75 0c             	pushl  0xc(%ebp)
f010021f:	ff 75 08             	pushl  0x8(%ebp)
f0100222:	68 89 60 10 f0       	push   $0xf0106089
f0100227:	e8 75 36 00 00       	call   f01038a1 <cprintf>
	vcprintf(fmt, ap);
f010022c:	83 c4 08             	add    $0x8,%esp
f010022f:	53                   	push   %ebx
f0100230:	ff 75 10             	pushl  0x10(%ebp)
f0100233:	e8 43 36 00 00       	call   f010387b <vcprintf>
	cprintf("\n");
f0100238:	c7 04 24 c0 68 10 f0 	movl   $0xf01068c0,(%esp)
f010023f:	e8 5d 36 00 00       	call   f01038a1 <cprintf>
	va_end(ap);
}
f0100244:	83 c4 10             	add    $0x10,%esp
f0100247:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010024a:	c9                   	leave  
f010024b:	c3                   	ret    

f010024c <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010024c:	55                   	push   %ebp
f010024d:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010024f:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100254:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100255:	a8 01                	test   $0x1,%al
f0100257:	74 0b                	je     f0100264 <serial_proc_data+0x18>
f0100259:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010025e:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010025f:	0f b6 c0             	movzbl %al,%eax
f0100262:	eb 05                	jmp    f0100269 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100264:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100269:	5d                   	pop    %ebp
f010026a:	c3                   	ret    

f010026b <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010026b:	55                   	push   %ebp
f010026c:	89 e5                	mov    %esp,%ebp
f010026e:	53                   	push   %ebx
f010026f:	83 ec 04             	sub    $0x4,%esp
f0100272:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100274:	eb 2b                	jmp    f01002a1 <cons_intr+0x36>
		if (c == 0)
f0100276:	85 c0                	test   %eax,%eax
f0100278:	74 27                	je     f01002a1 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f010027a:	8b 0d 24 b2 22 f0    	mov    0xf022b224,%ecx
f0100280:	8d 51 01             	lea    0x1(%ecx),%edx
f0100283:	89 15 24 b2 22 f0    	mov    %edx,0xf022b224
f0100289:	88 81 20 b0 22 f0    	mov    %al,-0xfdd4fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f010028f:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100295:	75 0a                	jne    f01002a1 <cons_intr+0x36>
			cons.wpos = 0;
f0100297:	c7 05 24 b2 22 f0 00 	movl   $0x0,0xf022b224
f010029e:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002a1:	ff d3                	call   *%ebx
f01002a3:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002a6:	75 ce                	jne    f0100276 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01002a8:	83 c4 04             	add    $0x4,%esp
f01002ab:	5b                   	pop    %ebx
f01002ac:	5d                   	pop    %ebp
f01002ad:	c3                   	ret    

f01002ae <kbd_proc_data>:
f01002ae:	ba 64 00 00 00       	mov    $0x64,%edx
f01002b3:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f01002b4:	a8 01                	test   $0x1,%al
f01002b6:	0f 84 f8 00 00 00    	je     f01003b4 <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f01002bc:	a8 20                	test   $0x20,%al
f01002be:	0f 85 f6 00 00 00    	jne    f01003ba <kbd_proc_data+0x10c>
f01002c4:	ba 60 00 00 00       	mov    $0x60,%edx
f01002c9:	ec                   	in     (%dx),%al
f01002ca:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01002cc:	3c e0                	cmp    $0xe0,%al
f01002ce:	75 0d                	jne    f01002dd <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f01002d0:	83 0d 00 b0 22 f0 40 	orl    $0x40,0xf022b000
		return 0;
f01002d7:	b8 00 00 00 00       	mov    $0x0,%eax
f01002dc:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01002dd:	55                   	push   %ebp
f01002de:	89 e5                	mov    %esp,%ebp
f01002e0:	53                   	push   %ebx
f01002e1:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01002e4:	84 c0                	test   %al,%al
f01002e6:	79 36                	jns    f010031e <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01002e8:	8b 0d 00 b0 22 f0    	mov    0xf022b000,%ecx
f01002ee:	89 cb                	mov    %ecx,%ebx
f01002f0:	83 e3 40             	and    $0x40,%ebx
f01002f3:	83 e0 7f             	and    $0x7f,%eax
f01002f6:	85 db                	test   %ebx,%ebx
f01002f8:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01002fb:	0f b6 d2             	movzbl %dl,%edx
f01002fe:	0f b6 82 00 62 10 f0 	movzbl -0xfef9e00(%edx),%eax
f0100305:	83 c8 40             	or     $0x40,%eax
f0100308:	0f b6 c0             	movzbl %al,%eax
f010030b:	f7 d0                	not    %eax
f010030d:	21 c8                	and    %ecx,%eax
f010030f:	a3 00 b0 22 f0       	mov    %eax,0xf022b000
		return 0;
f0100314:	b8 00 00 00 00       	mov    $0x0,%eax
f0100319:	e9 a4 00 00 00       	jmp    f01003c2 <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f010031e:	8b 0d 00 b0 22 f0    	mov    0xf022b000,%ecx
f0100324:	f6 c1 40             	test   $0x40,%cl
f0100327:	74 0e                	je     f0100337 <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100329:	83 c8 80             	or     $0xffffff80,%eax
f010032c:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010032e:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100331:	89 0d 00 b0 22 f0    	mov    %ecx,0xf022b000
	}

	shift |= shiftcode[data];
f0100337:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f010033a:	0f b6 82 00 62 10 f0 	movzbl -0xfef9e00(%edx),%eax
f0100341:	0b 05 00 b0 22 f0    	or     0xf022b000,%eax
f0100347:	0f b6 8a 00 61 10 f0 	movzbl -0xfef9f00(%edx),%ecx
f010034e:	31 c8                	xor    %ecx,%eax
f0100350:	a3 00 b0 22 f0       	mov    %eax,0xf022b000

	c = charcode[shift & (CTL | SHIFT)][data];
f0100355:	89 c1                	mov    %eax,%ecx
f0100357:	83 e1 03             	and    $0x3,%ecx
f010035a:	8b 0c 8d e0 60 10 f0 	mov    -0xfef9f20(,%ecx,4),%ecx
f0100361:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100365:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100368:	a8 08                	test   $0x8,%al
f010036a:	74 1b                	je     f0100387 <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f010036c:	89 da                	mov    %ebx,%edx
f010036e:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100371:	83 f9 19             	cmp    $0x19,%ecx
f0100374:	77 05                	ja     f010037b <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f0100376:	83 eb 20             	sub    $0x20,%ebx
f0100379:	eb 0c                	jmp    f0100387 <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f010037b:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f010037e:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100381:	83 fa 19             	cmp    $0x19,%edx
f0100384:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100387:	f7 d0                	not    %eax
f0100389:	a8 06                	test   $0x6,%al
f010038b:	75 33                	jne    f01003c0 <kbd_proc_data+0x112>
f010038d:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100393:	75 2b                	jne    f01003c0 <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f0100395:	83 ec 0c             	sub    $0xc,%esp
f0100398:	68 a3 60 10 f0       	push   $0xf01060a3
f010039d:	e8 ff 34 00 00       	call   f01038a1 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003a2:	ba 92 00 00 00       	mov    $0x92,%edx
f01003a7:	b8 03 00 00 00       	mov    $0x3,%eax
f01003ac:	ee                   	out    %al,(%dx)
f01003ad:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003b0:	89 d8                	mov    %ebx,%eax
f01003b2:	eb 0e                	jmp    f01003c2 <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f01003b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01003b9:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f01003ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01003bf:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003c0:	89 d8                	mov    %ebx,%eax
}
f01003c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01003c5:	c9                   	leave  
f01003c6:	c3                   	ret    

f01003c7 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003c7:	55                   	push   %ebp
f01003c8:	89 e5                	mov    %esp,%ebp
f01003ca:	57                   	push   %edi
f01003cb:	56                   	push   %esi
f01003cc:	53                   	push   %ebx
f01003cd:	83 ec 1c             	sub    $0x1c,%esp
f01003d0:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01003d2:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003d7:	be fd 03 00 00       	mov    $0x3fd,%esi
f01003dc:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003e1:	eb 09                	jmp    f01003ec <cons_putc+0x25>
f01003e3:	89 ca                	mov    %ecx,%edx
f01003e5:	ec                   	in     (%dx),%al
f01003e6:	ec                   	in     (%dx),%al
f01003e7:	ec                   	in     (%dx),%al
f01003e8:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01003e9:	83 c3 01             	add    $0x1,%ebx
f01003ec:	89 f2                	mov    %esi,%edx
f01003ee:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01003ef:	a8 20                	test   $0x20,%al
f01003f1:	75 08                	jne    f01003fb <cons_putc+0x34>
f01003f3:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01003f9:	7e e8                	jle    f01003e3 <cons_putc+0x1c>
f01003fb:	89 f8                	mov    %edi,%eax
f01003fd:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100400:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100405:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100406:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010040b:	be 79 03 00 00       	mov    $0x379,%esi
f0100410:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100415:	eb 09                	jmp    f0100420 <cons_putc+0x59>
f0100417:	89 ca                	mov    %ecx,%edx
f0100419:	ec                   	in     (%dx),%al
f010041a:	ec                   	in     (%dx),%al
f010041b:	ec                   	in     (%dx),%al
f010041c:	ec                   	in     (%dx),%al
f010041d:	83 c3 01             	add    $0x1,%ebx
f0100420:	89 f2                	mov    %esi,%edx
f0100422:	ec                   	in     (%dx),%al
f0100423:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100429:	7f 04                	jg     f010042f <cons_putc+0x68>
f010042b:	84 c0                	test   %al,%al
f010042d:	79 e8                	jns    f0100417 <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010042f:	ba 78 03 00 00       	mov    $0x378,%edx
f0100434:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100438:	ee                   	out    %al,(%dx)
f0100439:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010043e:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100443:	ee                   	out    %al,(%dx)
f0100444:	b8 08 00 00 00       	mov    $0x8,%eax
f0100449:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010044a:	89 fa                	mov    %edi,%edx
f010044c:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100452:	89 f8                	mov    %edi,%eax
f0100454:	80 cc 07             	or     $0x7,%ah
f0100457:	85 d2                	test   %edx,%edx
f0100459:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f010045c:	89 f8                	mov    %edi,%eax
f010045e:	0f b6 c0             	movzbl %al,%eax
f0100461:	83 f8 09             	cmp    $0x9,%eax
f0100464:	74 74                	je     f01004da <cons_putc+0x113>
f0100466:	83 f8 09             	cmp    $0x9,%eax
f0100469:	7f 0a                	jg     f0100475 <cons_putc+0xae>
f010046b:	83 f8 08             	cmp    $0x8,%eax
f010046e:	74 14                	je     f0100484 <cons_putc+0xbd>
f0100470:	e9 99 00 00 00       	jmp    f010050e <cons_putc+0x147>
f0100475:	83 f8 0a             	cmp    $0xa,%eax
f0100478:	74 3a                	je     f01004b4 <cons_putc+0xed>
f010047a:	83 f8 0d             	cmp    $0xd,%eax
f010047d:	74 3d                	je     f01004bc <cons_putc+0xf5>
f010047f:	e9 8a 00 00 00       	jmp    f010050e <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f0100484:	0f b7 05 28 b2 22 f0 	movzwl 0xf022b228,%eax
f010048b:	66 85 c0             	test   %ax,%ax
f010048e:	0f 84 e6 00 00 00    	je     f010057a <cons_putc+0x1b3>
			crt_pos--;
f0100494:	83 e8 01             	sub    $0x1,%eax
f0100497:	66 a3 28 b2 22 f0    	mov    %ax,0xf022b228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010049d:	0f b7 c0             	movzwl %ax,%eax
f01004a0:	66 81 e7 00 ff       	and    $0xff00,%di
f01004a5:	83 cf 20             	or     $0x20,%edi
f01004a8:	8b 15 2c b2 22 f0    	mov    0xf022b22c,%edx
f01004ae:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004b2:	eb 78                	jmp    f010052c <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004b4:	66 83 05 28 b2 22 f0 	addw   $0x50,0xf022b228
f01004bb:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004bc:	0f b7 05 28 b2 22 f0 	movzwl 0xf022b228,%eax
f01004c3:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004c9:	c1 e8 16             	shr    $0x16,%eax
f01004cc:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004cf:	c1 e0 04             	shl    $0x4,%eax
f01004d2:	66 a3 28 b2 22 f0    	mov    %ax,0xf022b228
f01004d8:	eb 52                	jmp    f010052c <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f01004da:	b8 20 00 00 00       	mov    $0x20,%eax
f01004df:	e8 e3 fe ff ff       	call   f01003c7 <cons_putc>
		cons_putc(' ');
f01004e4:	b8 20 00 00 00       	mov    $0x20,%eax
f01004e9:	e8 d9 fe ff ff       	call   f01003c7 <cons_putc>
		cons_putc(' ');
f01004ee:	b8 20 00 00 00       	mov    $0x20,%eax
f01004f3:	e8 cf fe ff ff       	call   f01003c7 <cons_putc>
		cons_putc(' ');
f01004f8:	b8 20 00 00 00       	mov    $0x20,%eax
f01004fd:	e8 c5 fe ff ff       	call   f01003c7 <cons_putc>
		cons_putc(' ');
f0100502:	b8 20 00 00 00       	mov    $0x20,%eax
f0100507:	e8 bb fe ff ff       	call   f01003c7 <cons_putc>
f010050c:	eb 1e                	jmp    f010052c <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010050e:	0f b7 05 28 b2 22 f0 	movzwl 0xf022b228,%eax
f0100515:	8d 50 01             	lea    0x1(%eax),%edx
f0100518:	66 89 15 28 b2 22 f0 	mov    %dx,0xf022b228
f010051f:	0f b7 c0             	movzwl %ax,%eax
f0100522:	8b 15 2c b2 22 f0    	mov    0xf022b22c,%edx
f0100528:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f010052c:	66 81 3d 28 b2 22 f0 	cmpw   $0x7cf,0xf022b228
f0100533:	cf 07 
f0100535:	76 43                	jbe    f010057a <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100537:	a1 2c b2 22 f0       	mov    0xf022b22c,%eax
f010053c:	83 ec 04             	sub    $0x4,%esp
f010053f:	68 00 0f 00 00       	push   $0xf00
f0100544:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010054a:	52                   	push   %edx
f010054b:	50                   	push   %eax
f010054c:	e8 20 4e 00 00       	call   f0105371 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100551:	8b 15 2c b2 22 f0    	mov    0xf022b22c,%edx
f0100557:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010055d:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100563:	83 c4 10             	add    $0x10,%esp
f0100566:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010056b:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010056e:	39 d0                	cmp    %edx,%eax
f0100570:	75 f4                	jne    f0100566 <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100572:	66 83 2d 28 b2 22 f0 	subw   $0x50,0xf022b228
f0100579:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010057a:	8b 0d 30 b2 22 f0    	mov    0xf022b230,%ecx
f0100580:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100585:	89 ca                	mov    %ecx,%edx
f0100587:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100588:	0f b7 1d 28 b2 22 f0 	movzwl 0xf022b228,%ebx
f010058f:	8d 71 01             	lea    0x1(%ecx),%esi
f0100592:	89 d8                	mov    %ebx,%eax
f0100594:	66 c1 e8 08          	shr    $0x8,%ax
f0100598:	89 f2                	mov    %esi,%edx
f010059a:	ee                   	out    %al,(%dx)
f010059b:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005a0:	89 ca                	mov    %ecx,%edx
f01005a2:	ee                   	out    %al,(%dx)
f01005a3:	89 d8                	mov    %ebx,%eax
f01005a5:	89 f2                	mov    %esi,%edx
f01005a7:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01005a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005ab:	5b                   	pop    %ebx
f01005ac:	5e                   	pop    %esi
f01005ad:	5f                   	pop    %edi
f01005ae:	5d                   	pop    %ebp
f01005af:	c3                   	ret    

f01005b0 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01005b0:	80 3d 34 b2 22 f0 00 	cmpb   $0x0,0xf022b234
f01005b7:	74 11                	je     f01005ca <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01005b9:	55                   	push   %ebp
f01005ba:	89 e5                	mov    %esp,%ebp
f01005bc:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01005bf:	b8 4c 02 10 f0       	mov    $0xf010024c,%eax
f01005c4:	e8 a2 fc ff ff       	call   f010026b <cons_intr>
}
f01005c9:	c9                   	leave  
f01005ca:	f3 c3                	repz ret 

f01005cc <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01005cc:	55                   	push   %ebp
f01005cd:	89 e5                	mov    %esp,%ebp
f01005cf:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01005d2:	b8 ae 02 10 f0       	mov    $0xf01002ae,%eax
f01005d7:	e8 8f fc ff ff       	call   f010026b <cons_intr>
}
f01005dc:	c9                   	leave  
f01005dd:	c3                   	ret    

f01005de <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01005de:	55                   	push   %ebp
f01005df:	89 e5                	mov    %esp,%ebp
f01005e1:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01005e4:	e8 c7 ff ff ff       	call   f01005b0 <serial_intr>
	kbd_intr();
f01005e9:	e8 de ff ff ff       	call   f01005cc <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01005ee:	a1 20 b2 22 f0       	mov    0xf022b220,%eax
f01005f3:	3b 05 24 b2 22 f0    	cmp    0xf022b224,%eax
f01005f9:	74 26                	je     f0100621 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01005fb:	8d 50 01             	lea    0x1(%eax),%edx
f01005fe:	89 15 20 b2 22 f0    	mov    %edx,0xf022b220
f0100604:	0f b6 88 20 b0 22 f0 	movzbl -0xfdd4fe0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f010060b:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f010060d:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100613:	75 11                	jne    f0100626 <cons_getc+0x48>
			cons.rpos = 0;
f0100615:	c7 05 20 b2 22 f0 00 	movl   $0x0,0xf022b220
f010061c:	00 00 00 
f010061f:	eb 05                	jmp    f0100626 <cons_getc+0x48>
		return c;
	}
	return 0;
f0100621:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100626:	c9                   	leave  
f0100627:	c3                   	ret    

f0100628 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100628:	55                   	push   %ebp
f0100629:	89 e5                	mov    %esp,%ebp
f010062b:	57                   	push   %edi
f010062c:	56                   	push   %esi
f010062d:	53                   	push   %ebx
f010062e:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100631:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100638:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010063f:	5a a5 
	if (*cp != 0xA55A) {
f0100641:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100648:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010064c:	74 11                	je     f010065f <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010064e:	c7 05 30 b2 22 f0 b4 	movl   $0x3b4,0xf022b230
f0100655:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100658:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f010065d:	eb 16                	jmp    f0100675 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010065f:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100666:	c7 05 30 b2 22 f0 d4 	movl   $0x3d4,0xf022b230
f010066d:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100670:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100675:	8b 3d 30 b2 22 f0    	mov    0xf022b230,%edi
f010067b:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100680:	89 fa                	mov    %edi,%edx
f0100682:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100683:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100686:	89 da                	mov    %ebx,%edx
f0100688:	ec                   	in     (%dx),%al
f0100689:	0f b6 c8             	movzbl %al,%ecx
f010068c:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010068f:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100694:	89 fa                	mov    %edi,%edx
f0100696:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100697:	89 da                	mov    %ebx,%edx
f0100699:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f010069a:	89 35 2c b2 22 f0    	mov    %esi,0xf022b22c
	crt_pos = pos;
f01006a0:	0f b6 c0             	movzbl %al,%eax
f01006a3:	09 c8                	or     %ecx,%eax
f01006a5:	66 a3 28 b2 22 f0    	mov    %ax,0xf022b228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006ab:	e8 1c ff ff ff       	call   f01005cc <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006b0:	83 ec 0c             	sub    $0xc,%esp
f01006b3:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f01006ba:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006bf:	50                   	push   %eax
f01006c0:	e8 8b 30 00 00       	call   f0103750 <irq_setmask_8259A>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006c5:	be fa 03 00 00       	mov    $0x3fa,%esi
f01006ca:	b8 00 00 00 00       	mov    $0x0,%eax
f01006cf:	89 f2                	mov    %esi,%edx
f01006d1:	ee                   	out    %al,(%dx)
f01006d2:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01006d7:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006dc:	ee                   	out    %al,(%dx)
f01006dd:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01006e2:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006e7:	89 da                	mov    %ebx,%edx
f01006e9:	ee                   	out    %al,(%dx)
f01006ea:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01006ef:	b8 00 00 00 00       	mov    $0x0,%eax
f01006f4:	ee                   	out    %al,(%dx)
f01006f5:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01006fa:	b8 03 00 00 00       	mov    $0x3,%eax
f01006ff:	ee                   	out    %al,(%dx)
f0100700:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100705:	b8 00 00 00 00       	mov    $0x0,%eax
f010070a:	ee                   	out    %al,(%dx)
f010070b:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100710:	b8 01 00 00 00       	mov    $0x1,%eax
f0100715:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100716:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010071b:	ec                   	in     (%dx),%al
f010071c:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010071e:	83 c4 10             	add    $0x10,%esp
f0100721:	3c ff                	cmp    $0xff,%al
f0100723:	0f 95 05 34 b2 22 f0 	setne  0xf022b234
f010072a:	89 f2                	mov    %esi,%edx
f010072c:	ec                   	in     (%dx),%al
f010072d:	89 da                	mov    %ebx,%edx
f010072f:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100730:	80 f9 ff             	cmp    $0xff,%cl
f0100733:	75 10                	jne    f0100745 <cons_init+0x11d>
		cprintf("Serial port does not exist!\n");
f0100735:	83 ec 0c             	sub    $0xc,%esp
f0100738:	68 af 60 10 f0       	push   $0xf01060af
f010073d:	e8 5f 31 00 00       	call   f01038a1 <cprintf>
f0100742:	83 c4 10             	add    $0x10,%esp
}
f0100745:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100748:	5b                   	pop    %ebx
f0100749:	5e                   	pop    %esi
f010074a:	5f                   	pop    %edi
f010074b:	5d                   	pop    %ebp
f010074c:	c3                   	ret    

f010074d <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010074d:	55                   	push   %ebp
f010074e:	89 e5                	mov    %esp,%ebp
f0100750:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100753:	8b 45 08             	mov    0x8(%ebp),%eax
f0100756:	e8 6c fc ff ff       	call   f01003c7 <cons_putc>
}
f010075b:	c9                   	leave  
f010075c:	c3                   	ret    

f010075d <getchar>:

int
getchar(void)
{
f010075d:	55                   	push   %ebp
f010075e:	89 e5                	mov    %esp,%ebp
f0100760:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100763:	e8 76 fe ff ff       	call   f01005de <cons_getc>
f0100768:	85 c0                	test   %eax,%eax
f010076a:	74 f7                	je     f0100763 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010076c:	c9                   	leave  
f010076d:	c3                   	ret    

f010076e <iscons>:

int
iscons(int fdnum)
{
f010076e:	55                   	push   %ebp
f010076f:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100771:	b8 01 00 00 00       	mov    $0x1,%eax
f0100776:	5d                   	pop    %ebp
f0100777:	c3                   	ret    

f0100778 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100778:	55                   	push   %ebp
f0100779:	89 e5                	mov    %esp,%ebp
f010077b:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010077e:	68 00 63 10 f0       	push   $0xf0106300
f0100783:	68 1e 63 10 f0       	push   $0xf010631e
f0100788:	68 23 63 10 f0       	push   $0xf0106323
f010078d:	e8 0f 31 00 00       	call   f01038a1 <cprintf>
f0100792:	83 c4 0c             	add    $0xc,%esp
f0100795:	68 dc 63 10 f0       	push   $0xf01063dc
f010079a:	68 2c 63 10 f0       	push   $0xf010632c
f010079f:	68 23 63 10 f0       	push   $0xf0106323
f01007a4:	e8 f8 30 00 00       	call   f01038a1 <cprintf>
f01007a9:	83 c4 0c             	add    $0xc,%esp
f01007ac:	68 35 63 10 f0       	push   $0xf0106335
f01007b1:	68 53 63 10 f0       	push   $0xf0106353
f01007b6:	68 23 63 10 f0       	push   $0xf0106323
f01007bb:	e8 e1 30 00 00       	call   f01038a1 <cprintf>
	return 0;
}
f01007c0:	b8 00 00 00 00       	mov    $0x0,%eax
f01007c5:	c9                   	leave  
f01007c6:	c3                   	ret    

f01007c7 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007c7:	55                   	push   %ebp
f01007c8:	89 e5                	mov    %esp,%ebp
f01007ca:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007cd:	68 5d 63 10 f0       	push   $0xf010635d
f01007d2:	e8 ca 30 00 00       	call   f01038a1 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007d7:	83 c4 08             	add    $0x8,%esp
f01007da:	68 0c 00 10 00       	push   $0x10000c
f01007df:	68 04 64 10 f0       	push   $0xf0106404
f01007e4:	e8 b8 30 00 00       	call   f01038a1 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007e9:	83 c4 0c             	add    $0xc,%esp
f01007ec:	68 0c 00 10 00       	push   $0x10000c
f01007f1:	68 0c 00 10 f0       	push   $0xf010000c
f01007f6:	68 2c 64 10 f0       	push   $0xf010642c
f01007fb:	e8 a1 30 00 00       	call   f01038a1 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100800:	83 c4 0c             	add    $0xc,%esp
f0100803:	68 c1 5f 10 00       	push   $0x105fc1
f0100808:	68 c1 5f 10 f0       	push   $0xf0105fc1
f010080d:	68 50 64 10 f0       	push   $0xf0106450
f0100812:	e8 8a 30 00 00       	call   f01038a1 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100817:	83 c4 0c             	add    $0xc,%esp
f010081a:	68 00 b0 22 00       	push   $0x22b000
f010081f:	68 00 b0 22 f0       	push   $0xf022b000
f0100824:	68 74 64 10 f0       	push   $0xf0106474
f0100829:	e8 73 30 00 00       	call   f01038a1 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010082e:	83 c4 0c             	add    $0xc,%esp
f0100831:	68 08 d0 26 00       	push   $0x26d008
f0100836:	68 08 d0 26 f0       	push   $0xf026d008
f010083b:	68 98 64 10 f0       	push   $0xf0106498
f0100840:	e8 5c 30 00 00       	call   f01038a1 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100845:	b8 07 d4 26 f0       	mov    $0xf026d407,%eax
f010084a:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010084f:	83 c4 08             	add    $0x8,%esp
f0100852:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0100857:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010085d:	85 c0                	test   %eax,%eax
f010085f:	0f 48 c2             	cmovs  %edx,%eax
f0100862:	c1 f8 0a             	sar    $0xa,%eax
f0100865:	50                   	push   %eax
f0100866:	68 bc 64 10 f0       	push   $0xf01064bc
f010086b:	e8 31 30 00 00       	call   f01038a1 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100870:	b8 00 00 00 00       	mov    $0x0,%eax
f0100875:	c9                   	leave  
f0100876:	c3                   	ret    

f0100877 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100877:	55                   	push   %ebp
f0100878:	89 e5                	mov    %esp,%ebp
f010087a:	57                   	push   %edi
f010087b:	56                   	push   %esi
f010087c:	53                   	push   %ebx
f010087d:	83 ec 78             	sub    $0x78,%esp

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100880:	89 eb                	mov    %ebp,%ebx

	uint32_t _ebp, _eip;
	// _esp = read_esp();
	_ebp = read_ebp();

	uint32_t args[5] = {0, 0, 0, 0, 0};
f0100882:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0100889:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0100890:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0100897:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f010089e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	struct Eipdebuginfo context;

	cprintf("Stack backtrace:\n");
f01008a5:	68 76 63 10 f0       	push   $0xf0106376
f01008aa:	e8 f2 2f 00 00       	call   f01038a1 <cprintf>

	while (_ebp != 0) {
f01008af:	83 c4 10             	add    $0x10,%esp
f01008b2:	e9 a6 00 00 00       	jmp    f010095d <mon_backtrace+0xe6>
		
		_eip = *(uint32_t *)(_ebp + 4);		// ret addr
f01008b7:	8b 73 04             	mov    0x4(%ebx),%esi

		for (int i=0; i<5; i++) {
f01008ba:	b8 00 00 00 00       	mov    $0x0,%eax
			args[i] = *(uint32_t *)(_ebp + 8 + i * 4);
f01008bf:	8b 54 83 08          	mov    0x8(%ebx,%eax,4),%edx
f01008c3:	89 54 85 d4          	mov    %edx,-0x2c(%ebp,%eax,4)

	while (_ebp != 0) {
		
		_eip = *(uint32_t *)(_ebp + 4);		// ret addr

		for (int i=0; i<5; i++) {
f01008c7:	83 c0 01             	add    $0x1,%eax
f01008ca:	83 f8 05             	cmp    $0x5,%eax
f01008cd:	75 f0                	jne    f01008bf <mon_backtrace+0x48>
			args[i] = *(uint32_t *)(_ebp + 8 + i * 4);
		}

		debuginfo_eip((uintptr_t)_eip, &context);
f01008cf:	83 ec 08             	sub    $0x8,%esp
f01008d2:	8d 45 bc             	lea    -0x44(%ebp),%eax
f01008d5:	50                   	push   %eax
f01008d6:	56                   	push   %esi
f01008d7:	e8 ce 3f 00 00       	call   f01048aa <debuginfo_eip>

		char function_name[50] = {0};
f01008dc:	c7 45 8a 00 00 00 00 	movl   $0x0,-0x76(%ebp)
f01008e3:	c7 45 b8 00 00 00 00 	movl   $0x0,-0x48(%ebp)
f01008ea:	8d 7d 8c             	lea    -0x74(%ebp),%edi
f01008ed:	b9 0c 00 00 00       	mov    $0xc,%ecx
f01008f2:	b8 00 00 00 00       	mov    $0x0,%eax
f01008f7:	f3 ab                	rep stos %eax,%es:(%edi)
		int i = 0;
		for (; i<context.eip_fn_namelen; i++) {
f01008f9:	8b 4d c8             	mov    -0x38(%ebp),%ecx
			function_name[i] = context.eip_fn_name[i];
f01008fc:	8b 7d c4             	mov    -0x3c(%ebp),%edi

		debuginfo_eip((uintptr_t)_eip, &context);

		char function_name[50] = {0};
		int i = 0;
		for (; i<context.eip_fn_namelen; i++) {
f01008ff:	83 c4 10             	add    $0x10,%esp
f0100902:	eb 0b                	jmp    f010090f <mon_backtrace+0x98>
			function_name[i] = context.eip_fn_name[i];
f0100904:	0f b6 14 07          	movzbl (%edi,%eax,1),%edx
f0100908:	88 54 05 8a          	mov    %dl,-0x76(%ebp,%eax,1)

		debuginfo_eip((uintptr_t)_eip, &context);

		char function_name[50] = {0};
		int i = 0;
		for (; i<context.eip_fn_namelen; i++) {
f010090c:	83 c0 01             	add    $0x1,%eax
f010090f:	39 c8                	cmp    %ecx,%eax
f0100911:	7c f1                	jl     f0100904 <mon_backtrace+0x8d>
			function_name[i] = context.eip_fn_name[i];
		}
		function_name[i] = '\0';
f0100913:	85 c9                	test   %ecx,%ecx
f0100915:	b8 00 00 00 00       	mov    $0x0,%eax
f010091a:	0f 48 c8             	cmovs  %eax,%ecx
f010091d:	c6 44 0d 8a 00       	movb   $0x0,-0x76(%ebp,%ecx,1)

		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", _ebp, _eip, args[0], args[1], args[2], args[3], args[4]);
f0100922:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100925:	ff 75 e0             	pushl  -0x20(%ebp)
f0100928:	ff 75 dc             	pushl  -0x24(%ebp)
f010092b:	ff 75 d8             	pushl  -0x28(%ebp)
f010092e:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100931:	56                   	push   %esi
f0100932:	53                   	push   %ebx
f0100933:	68 e8 64 10 f0       	push   $0xf01064e8
f0100938:	e8 64 2f 00 00       	call   f01038a1 <cprintf>
		cprintf("         %s:%d: %s+%d\n", context.eip_file, context.eip_line, function_name, _eip - context.eip_fn_addr);
f010093d:	83 c4 14             	add    $0x14,%esp
f0100940:	2b 75 cc             	sub    -0x34(%ebp),%esi
f0100943:	56                   	push   %esi
f0100944:	8d 45 8a             	lea    -0x76(%ebp),%eax
f0100947:	50                   	push   %eax
f0100948:	ff 75 c0             	pushl  -0x40(%ebp)
f010094b:	ff 75 bc             	pushl  -0x44(%ebp)
f010094e:	68 88 63 10 f0       	push   $0xf0106388
f0100953:	e8 49 2f 00 00       	call   f01038a1 <cprintf>

		// _rsp = _ebp + 8;			// old_rsp
		_ebp = *(uint32_t *)_ebp;	// old_ebp
f0100958:	8b 1b                	mov    (%ebx),%ebx
f010095a:	83 c4 20             	add    $0x20,%esp

	struct Eipdebuginfo context;

	cprintf("Stack backtrace:\n");

	while (_ebp != 0) {
f010095d:	85 db                	test   %ebx,%ebx
f010095f:	0f 85 52 ff ff ff    	jne    f01008b7 <mon_backtrace+0x40>
		_ebp = *(uint32_t *)_ebp;	// old_ebp

	} 

	return 0;
}
f0100965:	b8 00 00 00 00       	mov    $0x0,%eax
f010096a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010096d:	5b                   	pop    %ebx
f010096e:	5e                   	pop    %esi
f010096f:	5f                   	pop    %edi
f0100970:	5d                   	pop    %ebp
f0100971:	c3                   	ret    

f0100972 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100972:	55                   	push   %ebp
f0100973:	89 e5                	mov    %esp,%ebp
f0100975:	57                   	push   %edi
f0100976:	56                   	push   %esi
f0100977:	53                   	push   %ebx
f0100978:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010097b:	68 20 65 10 f0       	push   $0xf0106520
f0100980:	e8 1c 2f 00 00       	call   f01038a1 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100985:	c7 04 24 44 65 10 f0 	movl   $0xf0106544,(%esp)
f010098c:	e8 10 2f 00 00       	call   f01038a1 <cprintf>

	if (tf != NULL)
f0100991:	83 c4 10             	add    $0x10,%esp
f0100994:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100998:	74 0e                	je     f01009a8 <monitor+0x36>
		print_trapframe(tf);
f010099a:	83 ec 0c             	sub    $0xc,%esp
f010099d:	ff 75 08             	pushl  0x8(%ebp)
f01009a0:	e8 b0 33 00 00       	call   f0103d55 <print_trapframe>
f01009a5:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01009a8:	83 ec 0c             	sub    $0xc,%esp
f01009ab:	68 9f 63 10 f0       	push   $0xf010639f
f01009b0:	e8 18 47 00 00       	call   f01050cd <readline>
f01009b5:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01009b7:	83 c4 10             	add    $0x10,%esp
f01009ba:	85 c0                	test   %eax,%eax
f01009bc:	74 ea                	je     f01009a8 <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01009be:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01009c5:	be 00 00 00 00       	mov    $0x0,%esi
f01009ca:	eb 0a                	jmp    f01009d6 <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01009cc:	c6 03 00             	movb   $0x0,(%ebx)
f01009cf:	89 f7                	mov    %esi,%edi
f01009d1:	8d 5b 01             	lea    0x1(%ebx),%ebx
f01009d4:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01009d6:	0f b6 03             	movzbl (%ebx),%eax
f01009d9:	84 c0                	test   %al,%al
f01009db:	74 63                	je     f0100a40 <monitor+0xce>
f01009dd:	83 ec 08             	sub    $0x8,%esp
f01009e0:	0f be c0             	movsbl %al,%eax
f01009e3:	50                   	push   %eax
f01009e4:	68 a3 63 10 f0       	push   $0xf01063a3
f01009e9:	e8 f9 48 00 00       	call   f01052e7 <strchr>
f01009ee:	83 c4 10             	add    $0x10,%esp
f01009f1:	85 c0                	test   %eax,%eax
f01009f3:	75 d7                	jne    f01009cc <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f01009f5:	80 3b 00             	cmpb   $0x0,(%ebx)
f01009f8:	74 46                	je     f0100a40 <monitor+0xce>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01009fa:	83 fe 0f             	cmp    $0xf,%esi
f01009fd:	75 14                	jne    f0100a13 <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009ff:	83 ec 08             	sub    $0x8,%esp
f0100a02:	6a 10                	push   $0x10
f0100a04:	68 a8 63 10 f0       	push   $0xf01063a8
f0100a09:	e8 93 2e 00 00       	call   f01038a1 <cprintf>
f0100a0e:	83 c4 10             	add    $0x10,%esp
f0100a11:	eb 95                	jmp    f01009a8 <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f0100a13:	8d 7e 01             	lea    0x1(%esi),%edi
f0100a16:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100a1a:	eb 03                	jmp    f0100a1f <monitor+0xad>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100a1c:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a1f:	0f b6 03             	movzbl (%ebx),%eax
f0100a22:	84 c0                	test   %al,%al
f0100a24:	74 ae                	je     f01009d4 <monitor+0x62>
f0100a26:	83 ec 08             	sub    $0x8,%esp
f0100a29:	0f be c0             	movsbl %al,%eax
f0100a2c:	50                   	push   %eax
f0100a2d:	68 a3 63 10 f0       	push   $0xf01063a3
f0100a32:	e8 b0 48 00 00       	call   f01052e7 <strchr>
f0100a37:	83 c4 10             	add    $0x10,%esp
f0100a3a:	85 c0                	test   %eax,%eax
f0100a3c:	74 de                	je     f0100a1c <monitor+0xaa>
f0100a3e:	eb 94                	jmp    f01009d4 <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f0100a40:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a47:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100a48:	85 f6                	test   %esi,%esi
f0100a4a:	0f 84 58 ff ff ff    	je     f01009a8 <monitor+0x36>
f0100a50:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a55:	83 ec 08             	sub    $0x8,%esp
f0100a58:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a5b:	ff 34 85 80 65 10 f0 	pushl  -0xfef9a80(,%eax,4)
f0100a62:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a65:	e8 1f 48 00 00       	call   f0105289 <strcmp>
f0100a6a:	83 c4 10             	add    $0x10,%esp
f0100a6d:	85 c0                	test   %eax,%eax
f0100a6f:	75 21                	jne    f0100a92 <monitor+0x120>
			return commands[i].func(argc, argv, tf);
f0100a71:	83 ec 04             	sub    $0x4,%esp
f0100a74:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a77:	ff 75 08             	pushl  0x8(%ebp)
f0100a7a:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a7d:	52                   	push   %edx
f0100a7e:	56                   	push   %esi
f0100a7f:	ff 14 85 88 65 10 f0 	call   *-0xfef9a78(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100a86:	83 c4 10             	add    $0x10,%esp
f0100a89:	85 c0                	test   %eax,%eax
f0100a8b:	78 25                	js     f0100ab2 <monitor+0x140>
f0100a8d:	e9 16 ff ff ff       	jmp    f01009a8 <monitor+0x36>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a92:	83 c3 01             	add    $0x1,%ebx
f0100a95:	83 fb 03             	cmp    $0x3,%ebx
f0100a98:	75 bb                	jne    f0100a55 <monitor+0xe3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a9a:	83 ec 08             	sub    $0x8,%esp
f0100a9d:	ff 75 a8             	pushl  -0x58(%ebp)
f0100aa0:	68 c5 63 10 f0       	push   $0xf01063c5
f0100aa5:	e8 f7 2d 00 00       	call   f01038a1 <cprintf>
f0100aaa:	83 c4 10             	add    $0x10,%esp
f0100aad:	e9 f6 fe ff ff       	jmp    f01009a8 <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100ab2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ab5:	5b                   	pop    %ebx
f0100ab6:	5e                   	pop    %esi
f0100ab7:	5f                   	pop    %edi
f0100ab8:	5d                   	pop    %ebp
f0100ab9:	c3                   	ret    

f0100aba <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100aba:	55                   	push   %ebp
f0100abb:	89 e5                	mov    %esp,%ebp
f0100abd:	56                   	push   %esi
f0100abe:	53                   	push   %ebx
f0100abf:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100ac1:	83 ec 0c             	sub    $0xc,%esp
f0100ac4:	50                   	push   %eax
f0100ac5:	e8 58 2c 00 00       	call   f0103722 <mc146818_read>
f0100aca:	89 c6                	mov    %eax,%esi
f0100acc:	83 c3 01             	add    $0x1,%ebx
f0100acf:	89 1c 24             	mov    %ebx,(%esp)
f0100ad2:	e8 4b 2c 00 00       	call   f0103722 <mc146818_read>
f0100ad7:	c1 e0 08             	shl    $0x8,%eax
f0100ada:	09 f0                	or     %esi,%eax
}
f0100adc:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100adf:	5b                   	pop    %ebx
f0100ae0:	5e                   	pop    %esi
f0100ae1:	5d                   	pop    %ebp
f0100ae2:	c3                   	ret    

f0100ae3 <boot_alloc>:
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100ae3:	83 3d 38 b2 22 f0 00 	cmpl   $0x0,0xf022b238
f0100aea:	75 11                	jne    f0100afd <boot_alloc+0x1a>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100aec:	ba 07 e0 26 f0       	mov    $0xf026e007,%edx
f0100af1:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100af7:	89 15 38 b2 22 f0    	mov    %edx,0xf022b238
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

	if ((uint32_t)nextfree > 0xffffffff - n)
f0100afd:	8b 15 38 b2 22 f0    	mov    0xf022b238,%edx
f0100b03:	89 c1                	mov    %eax,%ecx
f0100b05:	f7 d1                	not    %ecx
f0100b07:	39 ca                	cmp    %ecx,%edx
f0100b09:	76 17                	jbe    f0100b22 <boot_alloc+0x3f>
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100b0b:	55                   	push   %ebp
f0100b0c:	89 e5                	mov    %esp,%ebp
f0100b0e:	83 ec 0c             	sub    $0xc,%esp
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

	if ((uint32_t)nextfree > 0xffffffff - n)
		panic("boot_alloc: out of memory\n");
f0100b11:	68 a4 65 10 f0       	push   $0xf01065a4
f0100b16:	6a 6e                	push   $0x6e
f0100b18:	68 bf 65 10 f0       	push   $0xf01065bf
f0100b1d:	e8 1e f5 ff ff       	call   f0100040 <_panic>

	result = nextfree;
	nextfree = ROUNDUP(result + n , PGSIZE);
f0100b22:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100b29:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b2e:	a3 38 b2 22 f0       	mov    %eax,0xf022b238

	return result;
}
f0100b33:	89 d0                	mov    %edx,%eax
f0100b35:	c3                   	ret    

f0100b36 <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100b36:	89 d1                	mov    %edx,%ecx
f0100b38:	c1 e9 16             	shr    $0x16,%ecx
f0100b3b:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100b3e:	a8 01                	test   $0x1,%al
f0100b40:	74 52                	je     f0100b94 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b42:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b47:	89 c1                	mov    %eax,%ecx
f0100b49:	c1 e9 0c             	shr    $0xc,%ecx
f0100b4c:	3b 0d 88 be 22 f0    	cmp    0xf022be88,%ecx
f0100b52:	72 1b                	jb     f0100b6f <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100b54:	55                   	push   %ebp
f0100b55:	89 e5                	mov    %esp,%ebp
f0100b57:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b5a:	50                   	push   %eax
f0100b5b:	68 04 60 10 f0       	push   $0xf0106004
f0100b60:	68 2b 04 00 00       	push   $0x42b
f0100b65:	68 bf 65 10 f0       	push   $0xf01065bf
f0100b6a:	e8 d1 f4 ff ff       	call   f0100040 <_panic>
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));

	// cprintf("[?] In check_va2pa\n");
	// cprintf("[?] *pte_store:%x, **pte_store:%x\n", &p[PTX(va)], p[PTX(va)]);

	if (!(p[PTX(va)] & PTE_P))
f0100b6f:	c1 ea 0c             	shr    $0xc,%edx
f0100b72:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b78:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b7f:	89 c2                	mov    %eax,%edx
f0100b81:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b84:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b89:	85 d2                	test   %edx,%edx
f0100b8b:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b90:	0f 44 c2             	cmove  %edx,%eax
f0100b93:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100b94:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	// cprintf("[?] *pte_store:%x, **pte_store:%x\n", &p[PTX(va)], p[PTX(va)]);

	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100b99:	c3                   	ret    

f0100b9a <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100b9a:	55                   	push   %ebp
f0100b9b:	89 e5                	mov    %esp,%ebp
f0100b9d:	57                   	push   %edi
f0100b9e:	56                   	push   %esi
f0100b9f:	53                   	push   %ebx
f0100ba0:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ba3:	84 c0                	test   %al,%al
f0100ba5:	0f 85 a0 02 00 00    	jne    f0100e4b <check_page_free_list+0x2b1>
f0100bab:	e9 ad 02 00 00       	jmp    f0100e5d <check_page_free_list+0x2c3>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100bb0:	83 ec 04             	sub    $0x4,%esp
f0100bb3:	68 f4 68 10 f0       	push   $0xf01068f4
f0100bb8:	68 5c 03 00 00       	push   $0x35c
f0100bbd:	68 bf 65 10 f0       	push   $0xf01065bf
f0100bc2:	e8 79 f4 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100bc7:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100bca:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100bcd:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100bd0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100bd3:	89 c2                	mov    %eax,%edx
f0100bd5:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0100bdb:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100be1:	0f 95 c2             	setne  %dl
f0100be4:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100be7:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100beb:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100bed:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100bf1:	8b 00                	mov    (%eax),%eax
f0100bf3:	85 c0                	test   %eax,%eax
f0100bf5:	75 dc                	jne    f0100bd3 <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100bf7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bfa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100c00:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c03:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100c06:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100c08:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100c0b:	a3 40 b2 22 f0       	mov    %eax,0xf022b240
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c10:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c15:	8b 1d 40 b2 22 f0    	mov    0xf022b240,%ebx
f0100c1b:	eb 53                	jmp    f0100c70 <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c1d:	89 d8                	mov    %ebx,%eax
f0100c1f:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0100c25:	c1 f8 03             	sar    $0x3,%eax
f0100c28:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100c2b:	89 c2                	mov    %eax,%edx
f0100c2d:	c1 ea 16             	shr    $0x16,%edx
f0100c30:	39 f2                	cmp    %esi,%edx
f0100c32:	73 3a                	jae    f0100c6e <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c34:	89 c2                	mov    %eax,%edx
f0100c36:	c1 ea 0c             	shr    $0xc,%edx
f0100c39:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f0100c3f:	72 12                	jb     f0100c53 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c41:	50                   	push   %eax
f0100c42:	68 04 60 10 f0       	push   $0xf0106004
f0100c47:	6a 58                	push   $0x58
f0100c49:	68 cb 65 10 f0       	push   $0xf01065cb
f0100c4e:	e8 ed f3 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100c53:	83 ec 04             	sub    $0x4,%esp
f0100c56:	68 80 00 00 00       	push   $0x80
f0100c5b:	68 97 00 00 00       	push   $0x97
f0100c60:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c65:	50                   	push   %eax
f0100c66:	e8 b9 46 00 00       	call   f0105324 <memset>
f0100c6b:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c6e:	8b 1b                	mov    (%ebx),%ebx
f0100c70:	85 db                	test   %ebx,%ebx
f0100c72:	75 a9                	jne    f0100c1d <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100c74:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c79:	e8 65 fe ff ff       	call   f0100ae3 <boot_alloc>
f0100c7e:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c81:	8b 15 40 b2 22 f0    	mov    0xf022b240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c87:	8b 0d 90 be 22 f0    	mov    0xf022be90,%ecx
		assert(pp < pages + npages);
f0100c8d:	a1 88 be 22 f0       	mov    0xf022be88,%eax
f0100c92:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100c95:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100c98:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c9b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c9e:	be 00 00 00 00       	mov    $0x0,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ca3:	e9 52 01 00 00       	jmp    f0100dfa <check_page_free_list+0x260>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100ca8:	39 ca                	cmp    %ecx,%edx
f0100caa:	73 19                	jae    f0100cc5 <check_page_free_list+0x12b>
f0100cac:	68 d9 65 10 f0       	push   $0xf01065d9
f0100cb1:	68 e5 65 10 f0       	push   $0xf01065e5
f0100cb6:	68 76 03 00 00       	push   $0x376
f0100cbb:	68 bf 65 10 f0       	push   $0xf01065bf
f0100cc0:	e8 7b f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100cc5:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100cc8:	72 19                	jb     f0100ce3 <check_page_free_list+0x149>
f0100cca:	68 fa 65 10 f0       	push   $0xf01065fa
f0100ccf:	68 e5 65 10 f0       	push   $0xf01065e5
f0100cd4:	68 77 03 00 00       	push   $0x377
f0100cd9:	68 bf 65 10 f0       	push   $0xf01065bf
f0100cde:	e8 5d f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100ce3:	89 d0                	mov    %edx,%eax
f0100ce5:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100ce8:	a8 07                	test   $0x7,%al
f0100cea:	74 19                	je     f0100d05 <check_page_free_list+0x16b>
f0100cec:	68 18 69 10 f0       	push   $0xf0106918
f0100cf1:	68 e5 65 10 f0       	push   $0xf01065e5
f0100cf6:	68 78 03 00 00       	push   $0x378
f0100cfb:	68 bf 65 10 f0       	push   $0xf01065bf
f0100d00:	e8 3b f3 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100d05:	c1 f8 03             	sar    $0x3,%eax
f0100d08:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100d0b:	85 c0                	test   %eax,%eax
f0100d0d:	75 19                	jne    f0100d28 <check_page_free_list+0x18e>
f0100d0f:	68 0e 66 10 f0       	push   $0xf010660e
f0100d14:	68 e5 65 10 f0       	push   $0xf01065e5
f0100d19:	68 7b 03 00 00       	push   $0x37b
f0100d1e:	68 bf 65 10 f0       	push   $0xf01065bf
f0100d23:	e8 18 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d28:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d2d:	75 19                	jne    f0100d48 <check_page_free_list+0x1ae>
f0100d2f:	68 1f 66 10 f0       	push   $0xf010661f
f0100d34:	68 e5 65 10 f0       	push   $0xf01065e5
f0100d39:	68 7c 03 00 00       	push   $0x37c
f0100d3e:	68 bf 65 10 f0       	push   $0xf01065bf
f0100d43:	e8 f8 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d48:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d4d:	75 19                	jne    f0100d68 <check_page_free_list+0x1ce>
f0100d4f:	68 4c 69 10 f0       	push   $0xf010694c
f0100d54:	68 e5 65 10 f0       	push   $0xf01065e5
f0100d59:	68 7d 03 00 00       	push   $0x37d
f0100d5e:	68 bf 65 10 f0       	push   $0xf01065bf
f0100d63:	e8 d8 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d68:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d6d:	75 19                	jne    f0100d88 <check_page_free_list+0x1ee>
f0100d6f:	68 38 66 10 f0       	push   $0xf0106638
f0100d74:	68 e5 65 10 f0       	push   $0xf01065e5
f0100d79:	68 7e 03 00 00       	push   $0x37e
f0100d7e:	68 bf 65 10 f0       	push   $0xf01065bf
f0100d83:	e8 b8 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d88:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100d8d:	0f 86 f1 00 00 00    	jbe    f0100e84 <check_page_free_list+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d93:	89 c7                	mov    %eax,%edi
f0100d95:	c1 ef 0c             	shr    $0xc,%edi
f0100d98:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0100d9b:	77 12                	ja     f0100daf <check_page_free_list+0x215>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d9d:	50                   	push   %eax
f0100d9e:	68 04 60 10 f0       	push   $0xf0106004
f0100da3:	6a 58                	push   $0x58
f0100da5:	68 cb 65 10 f0       	push   $0xf01065cb
f0100daa:	e8 91 f2 ff ff       	call   f0100040 <_panic>
f0100daf:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100db5:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100db8:	0f 86 b6 00 00 00    	jbe    f0100e74 <check_page_free_list+0x2da>
f0100dbe:	68 70 69 10 f0       	push   $0xf0106970
f0100dc3:	68 e5 65 10 f0       	push   $0xf01065e5
f0100dc8:	68 7f 03 00 00       	push   $0x37f
f0100dcd:	68 bf 65 10 f0       	push   $0xf01065bf
f0100dd2:	e8 69 f2 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100dd7:	68 52 66 10 f0       	push   $0xf0106652
f0100ddc:	68 e5 65 10 f0       	push   $0xf01065e5
f0100de1:	68 81 03 00 00       	push   $0x381
f0100de6:	68 bf 65 10 f0       	push   $0xf01065bf
f0100deb:	e8 50 f2 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100df0:	83 c6 01             	add    $0x1,%esi
f0100df3:	eb 03                	jmp    f0100df8 <check_page_free_list+0x25e>
		else
			++nfree_extmem;
f0100df5:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100df8:	8b 12                	mov    (%edx),%edx
f0100dfa:	85 d2                	test   %edx,%edx
f0100dfc:	0f 85 a6 fe ff ff    	jne    f0100ca8 <check_page_free_list+0x10e>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100e02:	85 f6                	test   %esi,%esi
f0100e04:	7f 19                	jg     f0100e1f <check_page_free_list+0x285>
f0100e06:	68 6f 66 10 f0       	push   $0xf010666f
f0100e0b:	68 e5 65 10 f0       	push   $0xf01065e5
f0100e10:	68 89 03 00 00       	push   $0x389
f0100e15:	68 bf 65 10 f0       	push   $0xf01065bf
f0100e1a:	e8 21 f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100e1f:	85 db                	test   %ebx,%ebx
f0100e21:	7f 19                	jg     f0100e3c <check_page_free_list+0x2a2>
f0100e23:	68 81 66 10 f0       	push   $0xf0106681
f0100e28:	68 e5 65 10 f0       	push   $0xf01065e5
f0100e2d:	68 8a 03 00 00       	push   $0x38a
f0100e32:	68 bf 65 10 f0       	push   $0xf01065bf
f0100e37:	e8 04 f2 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100e3c:	83 ec 0c             	sub    $0xc,%esp
f0100e3f:	68 b8 69 10 f0       	push   $0xf01069b8
f0100e44:	e8 58 2a 00 00       	call   f01038a1 <cprintf>
}
f0100e49:	eb 49                	jmp    f0100e94 <check_page_free_list+0x2fa>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100e4b:	a1 40 b2 22 f0       	mov    0xf022b240,%eax
f0100e50:	85 c0                	test   %eax,%eax
f0100e52:	0f 85 6f fd ff ff    	jne    f0100bc7 <check_page_free_list+0x2d>
f0100e58:	e9 53 fd ff ff       	jmp    f0100bb0 <check_page_free_list+0x16>
f0100e5d:	83 3d 40 b2 22 f0 00 	cmpl   $0x0,0xf022b240
f0100e64:	0f 84 46 fd ff ff    	je     f0100bb0 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e6a:	be 00 04 00 00       	mov    $0x400,%esi
f0100e6f:	e9 a1 fd ff ff       	jmp    f0100c15 <check_page_free_list+0x7b>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e74:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e79:	0f 85 76 ff ff ff    	jne    f0100df5 <check_page_free_list+0x25b>
f0100e7f:	e9 53 ff ff ff       	jmp    f0100dd7 <check_page_free_list+0x23d>
f0100e84:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e89:	0f 85 61 ff ff ff    	jne    f0100df0 <check_page_free_list+0x256>
f0100e8f:	e9 43 ff ff ff       	jmp    f0100dd7 <check_page_free_list+0x23d>

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);

	cprintf("check_page_free_list() succeeded!\n");
}
f0100e94:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e97:	5b                   	pop    %ebx
f0100e98:	5e                   	pop    %esi
f0100e99:	5f                   	pop    %edi
f0100e9a:	5d                   	pop    %ebp
f0100e9b:	c3                   	ret    

f0100e9c <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100e9c:	55                   	push   %ebp
f0100e9d:	89 e5                	mov    %esp,%ebp
f0100e9f:	56                   	push   %esi
f0100ea0:	53                   	push   %ebx
	// 	pages[i].pp_link = page_free_list;
	// 	page_free_list = &pages[i];
	// }

	// 1)	first page in use
	pages[0].pp_ref = 1;
f0100ea1:	a1 90 be 22 f0       	mov    0xf022be90,%eax
f0100ea6:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	pages[0].pp_link = 0;
f0100eac:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	extern unsigned char mpentry_start[], mpentry_end[];
	uint32_t size = ROUNDUP(mpentry_end - mpentry_start, PGSIZE);
f0100eb2:	be a1 65 10 f0       	mov    $0xf01065a1,%esi
f0100eb7:	81 ee 28 55 10 f0    	sub    $0xf0105528,%esi
f0100ebd:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	cprintf("[?] %x\n", size);
f0100ec3:	83 ec 08             	sub    $0x8,%esp
f0100ec6:	56                   	push   %esi
f0100ec7:	68 92 66 10 f0       	push   $0xf0106692
f0100ecc:	e8 d0 29 00 00       	call   f01038a1 <cprintf>

	// 2)	[1-npages_basemem) free, except APs area (lab4)
	for (i = 1; i < npages_basemem; i++) {
f0100ed1:	83 c4 10             	add    $0x10,%esp
f0100ed4:	bb 01 00 00 00       	mov    $0x1,%ebx
		if (i * PGSIZE >= MPENTRY_PADDR && i * PGSIZE < MPENTRY_PADDR + size) {
f0100ed9:	81 c6 00 70 00 00    	add    $0x7000,%esi
	extern unsigned char mpentry_start[], mpentry_end[];
	uint32_t size = ROUNDUP(mpentry_end - mpentry_start, PGSIZE);
	cprintf("[?] %x\n", size);

	// 2)	[1-npages_basemem) free, except APs area (lab4)
	for (i = 1; i < npages_basemem; i++) {
f0100edf:	eb 61                	jmp    f0100f42 <page_init+0xa6>
f0100ee1:	89 d8                	mov    %ebx,%eax
f0100ee3:	c1 e0 0c             	shl    $0xc,%eax
		if (i * PGSIZE >= MPENTRY_PADDR && i * PGSIZE < MPENTRY_PADDR + size) {
f0100ee6:	3d ff 6f 00 00       	cmp    $0x6fff,%eax
f0100eeb:	76 2a                	jbe    f0100f17 <page_init+0x7b>
f0100eed:	39 c6                	cmp    %eax,%esi
f0100eef:	76 26                	jbe    f0100f17 <page_init+0x7b>
			pages[i].pp_ref = 1;
f0100ef1:	a1 90 be 22 f0       	mov    0xf022be90,%eax
f0100ef6:	8d 04 d8             	lea    (%eax,%ebx,8),%eax
f0100ef9:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link = 0;
f0100eff:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			cprintf("[?] non-boot CPUs (APs)\n");
f0100f05:	83 ec 0c             	sub    $0xc,%esp
f0100f08:	68 9a 66 10 f0       	push   $0xf010669a
f0100f0d:	e8 8f 29 00 00       	call   f01038a1 <cprintf>
f0100f12:	83 c4 10             	add    $0x10,%esp
f0100f15:	eb 28                	jmp    f0100f3f <page_init+0xa3>
		}
		else {
			pages[i].pp_ref = 0;
f0100f17:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100f1e:	89 c2                	mov    %eax,%edx
f0100f20:	03 15 90 be 22 f0    	add    0xf022be90,%edx
f0100f26:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
			pages[i].pp_link = page_free_list;
f0100f2c:	8b 0d 40 b2 22 f0    	mov    0xf022b240,%ecx
f0100f32:	89 0a                	mov    %ecx,(%edx)
			page_free_list = &pages[i];
f0100f34:	03 05 90 be 22 f0    	add    0xf022be90,%eax
f0100f3a:	a3 40 b2 22 f0       	mov    %eax,0xf022b240
	extern unsigned char mpentry_start[], mpentry_end[];
	uint32_t size = ROUNDUP(mpentry_end - mpentry_start, PGSIZE);
	cprintf("[?] %x\n", size);

	// 2)	[1-npages_basemem) free, except APs area (lab4)
	for (i = 1; i < npages_basemem; i++) {
f0100f3f:	83 c3 01             	add    $0x1,%ebx
f0100f42:	3b 1d 44 b2 22 f0    	cmp    0xf022b244,%ebx
f0100f48:	72 97                	jb     f0100ee1 <page_init+0x45>
f0100f4a:	8b 0d 40 b2 22 f0    	mov    0xf022b240,%ecx
f0100f50:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100f57:	ba 00 00 00 00       	mov    $0x0,%edx
f0100f5c:	eb 23                	jmp    f0100f81 <page_init+0xe5>
	}

	// [npages_basemem, IOPHYSMEM / PGSIZE) free
	// cprintf("[?] %d, %d, %d\n", npages_basemem, IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE);
	for (; i < IOPHYSMEM / PGSIZE; i++) {
		pages[i].pp_ref = 0;
f0100f5e:	89 c2                	mov    %eax,%edx
f0100f60:	03 15 90 be 22 f0    	add    0xf022be90,%edx
f0100f66:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f0100f6c:	89 0a                	mov    %ecx,(%edx)
		page_free_list = &pages[i];
f0100f6e:	89 c1                	mov    %eax,%ecx
f0100f70:	03 0d 90 be 22 f0    	add    0xf022be90,%ecx
		}
	}

	// [npages_basemem, IOPHYSMEM / PGSIZE) free
	// cprintf("[?] %d, %d, %d\n", npages_basemem, IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE);
	for (; i < IOPHYSMEM / PGSIZE; i++) {
f0100f76:	83 c3 01             	add    $0x1,%ebx
f0100f79:	83 c0 08             	add    $0x8,%eax
f0100f7c:	ba 01 00 00 00       	mov    $0x1,%edx
f0100f81:	81 fb 9f 00 00 00    	cmp    $0x9f,%ebx
f0100f87:	76 d5                	jbe    f0100f5e <page_init+0xc2>
f0100f89:	84 d2                	test   %dl,%dl
f0100f8b:	74 06                	je     f0100f93 <page_init+0xf7>
f0100f8d:	89 0d 40 b2 22 f0    	mov    %ecx,0xf022b240
f0100f93:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100f9a:	eb 1a                	jmp    f0100fb6 <page_init+0x11a>
		page_free_list = &pages[i];
	}

	// 3) [IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE) in use
	for (; i < EXTPHYSMEM / PGSIZE; i++) {
		pages[i].pp_ref = 1;
f0100f9c:	89 c2                	mov    %eax,%edx
f0100f9e:	03 15 90 be 22 f0    	add    0xf022be90,%edx
f0100fa4:	66 c7 42 04 01 00    	movw   $0x1,0x4(%edx)
		pages[i].pp_link = 0;
f0100faa:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}

	// 3) [IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE) in use
	for (; i < EXTPHYSMEM / PGSIZE; i++) {
f0100fb0:	83 c3 01             	add    $0x1,%ebx
f0100fb3:	83 c0 08             	add    $0x8,%eax
f0100fb6:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f0100fbc:	76 de                	jbe    f0100f9c <page_init+0x100>
f0100fbe:	8d 34 dd 00 00 00 00 	lea    0x0(,%ebx,8),%esi
f0100fc5:	eb 1a                	jmp    f0100fe1 <page_init+0x145>


	// cprintf("[?] %d\n", PADDR(boot_alloc(0)) / PGSIZE);
	// 4) [EXTPHYSMEM / PGSIZE, kernel end) in use
	for (; i < PADDR(boot_alloc(0)) / PGSIZE; i++) {
		pages[i].pp_ref = 1;
f0100fc7:	89 f0                	mov    %esi,%eax
f0100fc9:	03 05 90 be 22 f0    	add    0xf022be90,%eax
f0100fcf:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
		pages[i].pp_link = 0;
f0100fd5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}


	// cprintf("[?] %d\n", PADDR(boot_alloc(0)) / PGSIZE);
	// 4) [EXTPHYSMEM / PGSIZE, kernel end) in use
	for (; i < PADDR(boot_alloc(0)) / PGSIZE; i++) {
f0100fdb:	83 c3 01             	add    $0x1,%ebx
f0100fde:	83 c6 08             	add    $0x8,%esi
f0100fe1:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fe6:	e8 f8 fa ff ff       	call   f0100ae3 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100feb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100ff0:	77 15                	ja     f0101007 <page_init+0x16b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100ff2:	50                   	push   %eax
f0100ff3:	68 28 60 10 f0       	push   $0xf0106028
f0100ff8:	68 7b 01 00 00       	push   $0x17b
f0100ffd:	68 bf 65 10 f0       	push   $0xf01065bf
f0101002:	e8 39 f0 ff ff       	call   f0100040 <_panic>
f0101007:	05 00 00 00 10       	add    $0x10000000,%eax
f010100c:	c1 e8 0c             	shr    $0xc,%eax
f010100f:	39 c3                	cmp    %eax,%ebx
f0101011:	72 b4                	jb     f0100fc7 <page_init+0x12b>
f0101013:	8b 0d 40 b2 22 f0    	mov    0xf022b240,%ecx
f0101019:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0101020:	ba 00 00 00 00       	mov    $0x0,%edx
f0101025:	eb 23                	jmp    f010104a <page_init+0x1ae>
	}

	// cprintf("[?] %d\n", npages);
	// [kernel end, npages) free
	for (; i < npages; i++) {
		pages[i].pp_ref = 0;
f0101027:	89 c2                	mov    %eax,%edx
f0101029:	03 15 90 be 22 f0    	add    0xf022be90,%edx
f010102f:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f0101035:	89 0a                	mov    %ecx,(%edx)
		page_free_list = &pages[i];
f0101037:	89 c1                	mov    %eax,%ecx
f0101039:	03 0d 90 be 22 f0    	add    0xf022be90,%ecx
		pages[i].pp_link = 0;
	}

	// cprintf("[?] %d\n", npages);
	// [kernel end, npages) free
	for (; i < npages; i++) {
f010103f:	83 c3 01             	add    $0x1,%ebx
f0101042:	83 c0 08             	add    $0x8,%eax
f0101045:	ba 01 00 00 00       	mov    $0x1,%edx
f010104a:	3b 1d 88 be 22 f0    	cmp    0xf022be88,%ebx
f0101050:	72 d5                	jb     f0101027 <page_init+0x18b>
f0101052:	84 d2                	test   %dl,%dl
f0101054:	74 06                	je     f010105c <page_init+0x1c0>
f0101056:	89 0d 40 b2 22 f0    	mov    %ecx,0xf022b240
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}

}
f010105c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010105f:	5b                   	pop    %ebx
f0101060:	5e                   	pop    %esi
f0101061:	5d                   	pop    %ebp
f0101062:	c3                   	ret    

f0101063 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0101063:	55                   	push   %ebp
f0101064:	89 e5                	mov    %esp,%ebp
f0101066:	56                   	push   %esi
f0101067:	53                   	push   %ebx
	// Fill this function in

	// no more page in free list, we run out of free memory
	if (page_free_list == 0)
f0101068:	8b 1d 40 b2 22 f0    	mov    0xf022b240,%ebx
f010106e:	85 db                	test   %ebx,%ebx
f0101070:	74 59                	je     f01010cb <page_alloc+0x68>
		return 0;

	// get the previous page in free link
	struct PageInfo* last_free = page_free_list->pp_link;
f0101072:	8b 33                	mov    (%ebx),%esi
	struct PageInfo* result = page_free_list;

	// get a free page from the list
	page_free_list->pp_link = 0;
f0101074:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (alloc_flags & ALLOC_ZERO) {
f010107a:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f010107e:	74 45                	je     f01010c5 <page_alloc+0x62>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101080:	89 d8                	mov    %ebx,%eax
f0101082:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0101088:	c1 f8 03             	sar    $0x3,%eax
f010108b:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010108e:	89 c2                	mov    %eax,%edx
f0101090:	c1 ea 0c             	shr    $0xc,%edx
f0101093:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f0101099:	72 12                	jb     f01010ad <page_alloc+0x4a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010109b:	50                   	push   %eax
f010109c:	68 04 60 10 f0       	push   $0xf0106004
f01010a1:	6a 58                	push   $0x58
f01010a3:	68 cb 65 10 f0       	push   $0xf01065cb
f01010a8:	e8 93 ef ff ff       	call   f0100040 <_panic>
		// cprintf("[?] alloc zero, %x, %x\n", page_free_list, PADDR(page_free_list));
		// memset((char *)page2pa(page_free_list), 0, PGSIZE);
		memset(page2kva(page_free_list), 0, PGSIZE);
f01010ad:	83 ec 04             	sub    $0x4,%esp
f01010b0:	68 00 10 00 00       	push   $0x1000
f01010b5:	6a 00                	push   $0x0
f01010b7:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01010bc:	50                   	push   %eax
f01010bd:	e8 62 42 00 00       	call   f0105324 <memset>
f01010c2:	83 c4 10             	add    $0x10,%esp
	}
	
	// update free list head
	page_free_list = last_free;
f01010c5:	89 35 40 b2 22 f0    	mov    %esi,0xf022b240

	return result;
}
f01010cb:	89 d8                	mov    %ebx,%eax
f01010cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01010d0:	5b                   	pop    %ebx
f01010d1:	5e                   	pop    %esi
f01010d2:	5d                   	pop    %ebp
f01010d3:	c3                   	ret    

f01010d4 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f01010d4:	55                   	push   %ebp
f01010d5:	89 e5                	mov    %esp,%ebp
f01010d7:	83 ec 08             	sub    $0x8,%esp
f01010da:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.

	if (pp == 0)
f01010dd:	85 c0                	test   %eax,%eax
f01010df:	74 47                	je     f0101128 <page_free+0x54>
		return;
	if (pp->pp_link != 0)
f01010e1:	83 38 00             	cmpl   $0x0,(%eax)
f01010e4:	74 17                	je     f01010fd <page_free+0x29>
		panic("page_free: double free or corrupted\n");
f01010e6:	83 ec 04             	sub    $0x4,%esp
f01010e9:	68 dc 69 10 f0       	push   $0xf01069dc
f01010ee:	68 c0 01 00 00       	push   $0x1c0
f01010f3:	68 bf 65 10 f0       	push   $0xf01065bf
f01010f8:	e8 43 ef ff ff       	call   f0100040 <_panic>
	if (pp->pp_ref != 0)
f01010fd:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101102:	74 17                	je     f010111b <page_free+0x47>
		panic("page_free: other pointers still point to it, mind use-after-free!\n");
f0101104:	83 ec 04             	sub    $0x4,%esp
f0101107:	68 04 6a 10 f0       	push   $0xf0106a04
f010110c:	68 c2 01 00 00       	push   $0x1c2
f0101111:	68 bf 65 10 f0       	push   $0xf01065bf
f0101116:	e8 25 ef ff ff       	call   f0100040 <_panic>

	pp->pp_link = page_free_list;
f010111b:	8b 15 40 b2 22 f0    	mov    0xf022b240,%edx
f0101121:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101123:	a3 40 b2 22 f0       	mov    %eax,0xf022b240

}
f0101128:	c9                   	leave  
f0101129:	c3                   	ret    

f010112a <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f010112a:	55                   	push   %ebp
f010112b:	89 e5                	mov    %esp,%ebp
f010112d:	83 ec 08             	sub    $0x8,%esp
f0101130:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0101133:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0101137:	83 e8 01             	sub    $0x1,%eax
f010113a:	66 89 42 04          	mov    %ax,0x4(%edx)
f010113e:	66 85 c0             	test   %ax,%ax
f0101141:	75 0c                	jne    f010114f <page_decref+0x25>
		page_free(pp);
f0101143:	83 ec 0c             	sub    $0xc,%esp
f0101146:	52                   	push   %edx
f0101147:	e8 88 ff ff ff       	call   f01010d4 <page_free>
f010114c:	83 c4 10             	add    $0x10,%esp
}
f010114f:	c9                   	leave  
f0101150:	c3                   	ret    

f0101151 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that manipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0101151:	55                   	push   %ebp
f0101152:	89 e5                	mov    %esp,%ebp
f0101154:	56                   	push   %esi
f0101155:	53                   	push   %ebx
f0101156:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in

	// we have virtual address
	// cprintf("[?] %x\n", va);
	uint32_t Page_Directory_Index = PDX(va);
	uint32_t Page_Table_Index = PTX(va);
f0101159:	89 de                	mov    %ebx,%esi
f010115b:	c1 ee 0c             	shr    $0xc,%esi
f010115e:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	uint32_t Offset_In_PTE = PGOFF(va);

	// level 2 page table not exist
	if (pgdir[Page_Directory_Index] == 0) {
f0101164:	c1 eb 16             	shr    $0x16,%ebx
f0101167:	c1 e3 02             	shl    $0x2,%ebx
f010116a:	03 5d 08             	add    0x8(%ebp),%ebx
f010116d:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101170:	75 30                	jne    f01011a2 <pgdir_walk+0x51>
		if (create == 0)
f0101172:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101176:	74 5c                	je     f01011d4 <pgdir_walk+0x83>
			return NULL;
		
		// allocate a new physical page to be a page table
		struct PageInfo *new_page = page_alloc(ALLOC_ZERO);
f0101178:	83 ec 0c             	sub    $0xc,%esp
f010117b:	6a 01                	push   $0x1
f010117d:	e8 e1 fe ff ff       	call   f0101063 <page_alloc>
		// cprintf("[??] %x\n", new_page);
		if (new_page == 0)	// page allocate fail
f0101182:	83 c4 10             	add    $0x10,%esp
f0101185:	85 c0                	test   %eax,%eax
f0101187:	74 52                	je     f01011db <pgdir_walk+0x8a>
		// set level 1 page table entry to this new level 2 page table
		// this new page is for level2 PT, so flags are:
		// 	PTE_P: this page is present
		//	PTE_U: user process can use this page
		//	PTE_W: this page can be edit
		pgdir[Page_Directory_Index] = page2pa(new_page) | PTE_P | PTE_U | PTE_W;
f0101189:	89 c2                	mov    %eax,%edx
f010118b:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0101191:	c1 fa 03             	sar    $0x3,%edx
f0101194:	c1 e2 0c             	shl    $0xc,%edx
f0101197:	83 ca 07             	or     $0x7,%edx
f010119a:	89 13                	mov    %edx,(%ebx)
		new_page->pp_ref = 1;
f010119c:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	// cprintf("[?] %x\n", KADDR(PTE_ADDR(pgdir[Page_Directory_Index])));
	
	// remember each entry is 4 byte long
	// so we need to convert type to pte_t * in order to add 4 on address each time
	// instead of add 1
	pte_t *p = (pte_t *) KADDR(PTE_ADDR(pgdir[Page_Directory_Index]));
f01011a2:	8b 03                	mov    (%ebx),%eax
f01011a4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011a9:	89 c2                	mov    %eax,%edx
f01011ab:	c1 ea 0c             	shr    $0xc,%edx
f01011ae:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f01011b4:	72 15                	jb     f01011cb <pgdir_walk+0x7a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011b6:	50                   	push   %eax
f01011b7:	68 04 60 10 f0       	push   $0xf0106004
f01011bc:	68 0f 02 00 00       	push   $0x20f
f01011c1:	68 bf 65 10 f0       	push   $0xf01065bf
f01011c6:	e8 75 ee ff ff       	call   f0100040 <_panic>

	return &p[Page_Table_Index];
f01011cb:	8d 84 b0 00 00 00 f0 	lea    -0x10000000(%eax,%esi,4),%eax
f01011d2:	eb 0c                	jmp    f01011e0 <pgdir_walk+0x8f>
	uint32_t Offset_In_PTE = PGOFF(va);

	// level 2 page table not exist
	if (pgdir[Page_Directory_Index] == 0) {
		if (create == 0)
			return NULL;
f01011d4:	b8 00 00 00 00       	mov    $0x0,%eax
f01011d9:	eb 05                	jmp    f01011e0 <pgdir_walk+0x8f>
		
		// allocate a new physical page to be a page table
		struct PageInfo *new_page = page_alloc(ALLOC_ZERO);
		// cprintf("[??] %x\n", new_page);
		if (new_page == 0)	// page allocate fail
			return NULL;
f01011db:	b8 00 00 00 00       	mov    $0x0,%eax
	// so we need to convert type to pte_t * in order to add 4 on address each time
	// instead of add 1
	pte_t *p = (pte_t *) KADDR(PTE_ADDR(pgdir[Page_Directory_Index]));

	return &p[Page_Table_Index];
}
f01011e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01011e3:	5b                   	pop    %ebx
f01011e4:	5e                   	pop    %esi
f01011e5:	5d                   	pop    %ebp
f01011e6:	c3                   	ret    

f01011e7 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f01011e7:	55                   	push   %ebp
f01011e8:	89 e5                	mov    %esp,%ebp
f01011ea:	57                   	push   %edi
f01011eb:	56                   	push   %esi
f01011ec:	53                   	push   %ebx
f01011ed:	83 ec 1c             	sub    $0x1c,%esp
f01011f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01011f3:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in	
	if (size % PGSIZE != 0)
f01011f6:	f7 c1 ff 0f 00 00    	test   $0xfff,%ecx
f01011fc:	74 17                	je     f0101215 <boot_map_region+0x2e>
		panic("boot_map_region: size is not a multiple of PGSIZE\n");
f01011fe:	83 ec 04             	sub    $0x4,%esp
f0101201:	68 48 6a 10 f0       	push   $0xf0106a48
f0101206:	68 24 02 00 00       	push   $0x224
f010120b:	68 bf 65 10 f0       	push   $0xf01065bf
f0101210:	e8 2b ee ff ff       	call   f0100040 <_panic>
	
	if (va % PGSIZE != 0 || pa % PGSIZE != 0)
f0101215:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f010121b:	75 23                	jne    f0101240 <boot_map_region+0x59>
f010121d:	a9 ff 0f 00 00       	test   $0xfff,%eax
f0101222:	75 1c                	jne    f0101240 <boot_map_region+0x59>
f0101224:	c1 e9 0c             	shr    $0xc,%ecx
f0101227:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		panic("boot_map_region: va or pa is not page-aligned\n");


	// set all pages related
	for (int i=0; i<size/PGSIZE; i++) {
f010122a:	89 c3                	mov    %eax,%ebx
f010122c:	be 00 00 00 00       	mov    $0x0,%esi

		// find the real PTE for va
		// create on walk, if not present
		pte_t* pte = pgdir_walk(pgdir, (void *)va, 1);	
f0101231:	89 d7                	mov    %edx,%edi
f0101233:	29 c7                	sub    %eax,%edi

		// set the real PTE to pa, zero out least 12 bits
		*pte = PTE_ADDR(pa);
		
		// set flags
		*pte |= (perm | PTE_P);
f0101235:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101238:	83 c8 01             	or     $0x1,%eax
f010123b:	89 45 dc             	mov    %eax,-0x24(%ebp)
f010123e:	eb 5c                	jmp    f010129c <boot_map_region+0xb5>
	// Fill this function in	
	if (size % PGSIZE != 0)
		panic("boot_map_region: size is not a multiple of PGSIZE\n");
	
	if (va % PGSIZE != 0 || pa % PGSIZE != 0)
		panic("boot_map_region: va or pa is not page-aligned\n");
f0101240:	83 ec 04             	sub    $0x4,%esp
f0101243:	68 7c 6a 10 f0       	push   $0xf0106a7c
f0101248:	68 27 02 00 00       	push   $0x227
f010124d:	68 bf 65 10 f0       	push   $0xf01065bf
f0101252:	e8 e9 ed ff ff       	call   f0100040 <_panic>
	// set all pages related
	for (int i=0; i<size/PGSIZE; i++) {

		// find the real PTE for va
		// create on walk, if not present
		pte_t* pte = pgdir_walk(pgdir, (void *)va, 1);	
f0101257:	83 ec 04             	sub    $0x4,%esp
f010125a:	6a 01                	push   $0x1
f010125c:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f010125f:	50                   	push   %eax
f0101260:	ff 75 e0             	pushl  -0x20(%ebp)
f0101263:	e8 e9 fe ff ff       	call   f0101151 <pgdir_walk>

		if (pte == 0)
f0101268:	83 c4 10             	add    $0x10,%esp
f010126b:	85 c0                	test   %eax,%eax
f010126d:	75 17                	jne    f0101286 <boot_map_region+0x9f>
			panic("boot_map_region: pgdir_walk return NULL\n");
f010126f:	83 ec 04             	sub    $0x4,%esp
f0101272:	68 ac 6a 10 f0       	push   $0xf0106aac
f0101277:	68 32 02 00 00       	push   $0x232
f010127c:	68 bf 65 10 f0       	push   $0xf01065bf
f0101281:	e8 ba ed ff ff       	call   f0100040 <_panic>

		// set the real PTE to pa, zero out least 12 bits
		*pte = PTE_ADDR(pa);
		
		// set flags
		*pte |= (perm | PTE_P);
f0101286:	89 da                	mov    %ebx,%edx
f0101288:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010128e:	0b 55 dc             	or     -0x24(%ebp),%edx
f0101291:	89 10                	mov    %edx,(%eax)

		// deal with next page
		va += PGSIZE;
		pa += PGSIZE;
f0101293:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	if (va % PGSIZE != 0 || pa % PGSIZE != 0)
		panic("boot_map_region: va or pa is not page-aligned\n");


	// set all pages related
	for (int i=0; i<size/PGSIZE; i++) {
f0101299:	83 c6 01             	add    $0x1,%esi
f010129c:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f010129f:	75 b6                	jne    f0101257 <boot_map_region+0x70>
		va += PGSIZE;
		pa += PGSIZE;

	}

}
f01012a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012a4:	5b                   	pop    %ebx
f01012a5:	5e                   	pop    %esi
f01012a6:	5f                   	pop    %edi
f01012a7:	5d                   	pop    %ebp
f01012a8:	c3                   	ret    

f01012a9 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01012a9:	55                   	push   %ebp
f01012aa:	89 e5                	mov    %esp,%ebp
f01012ac:	53                   	push   %ebx
f01012ad:	83 ec 08             	sub    $0x8,%esp
f01012b0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in

	// do a page table walk to find real PTE
	pte_t * pte = pgdir_walk(pgdir, va, 0);
f01012b3:	6a 00                	push   $0x0
f01012b5:	ff 75 0c             	pushl  0xc(%ebp)
f01012b8:	ff 75 08             	pushl  0x8(%ebp)
f01012bb:	e8 91 fe ff ff       	call   f0101151 <pgdir_walk>

	// cprintf("[?] In page_lookup\n");
	// cprintf("[?] %x\n", pte);

	// if not present, return NULL
	if (pte == 0 || *pte == 0)
f01012c0:	83 c4 10             	add    $0x10,%esp
f01012c3:	85 c0                	test   %eax,%eax
f01012c5:	74 37                	je     f01012fe <page_lookup+0x55>
f01012c7:	83 38 00             	cmpl   $0x0,(%eax)
f01012ca:	74 39                	je     f0101305 <page_lookup+0x5c>
		return NULL;
	
	// store pte
	if (pte_store != 0)
f01012cc:	85 db                	test   %ebx,%ebx
f01012ce:	74 02                	je     f01012d2 <page_lookup+0x29>
		*pte_store = pte;
f01012d0:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01012d2:	8b 00                	mov    (%eax),%eax
f01012d4:	c1 e8 0c             	shr    $0xc,%eax
f01012d7:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f01012dd:	72 14                	jb     f01012f3 <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f01012df:	83 ec 04             	sub    $0x4,%esp
f01012e2:	68 d8 6a 10 f0       	push   $0xf0106ad8
f01012e7:	6a 51                	push   $0x51
f01012e9:	68 cb 65 10 f0       	push   $0xf01065cb
f01012ee:	e8 4d ed ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f01012f3:	8b 15 90 be 22 f0    	mov    0xf022be90,%edx
f01012f9:	8d 04 c2             	lea    (%edx,%eax,8),%eax

	return pa2page(PTE_ADDR(*pte)) ;
f01012fc:	eb 0c                	jmp    f010130a <page_lookup+0x61>
	// cprintf("[?] In page_lookup\n");
	// cprintf("[?] %x\n", pte);

	// if not present, return NULL
	if (pte == 0 || *pte == 0)
		return NULL;
f01012fe:	b8 00 00 00 00       	mov    $0x0,%eax
f0101303:	eb 05                	jmp    f010130a <page_lookup+0x61>
f0101305:	b8 00 00 00 00       	mov    $0x0,%eax
	// store pte
	if (pte_store != 0)
		*pte_store = pte;

	return pa2page(PTE_ADDR(*pte)) ;
}
f010130a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010130d:	c9                   	leave  
f010130e:	c3                   	ret    

f010130f <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f010130f:	55                   	push   %ebp
f0101310:	89 e5                	mov    %esp,%ebp
f0101312:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f0101315:	e8 2c 46 00 00       	call   f0105946 <cpunum>
f010131a:	6b c0 74             	imul   $0x74,%eax,%eax
f010131d:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f0101324:	74 16                	je     f010133c <tlb_invalidate+0x2d>
f0101326:	e8 1b 46 00 00       	call   f0105946 <cpunum>
f010132b:	6b c0 74             	imul   $0x74,%eax,%eax
f010132e:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0101334:	8b 55 08             	mov    0x8(%ebp),%edx
f0101337:	39 50 60             	cmp    %edx,0x60(%eax)
f010133a:	75 06                	jne    f0101342 <tlb_invalidate+0x33>
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010133c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010133f:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f0101342:	c9                   	leave  
f0101343:	c3                   	ret    

f0101344 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101344:	55                   	push   %ebp
f0101345:	89 e5                	mov    %esp,%ebp
f0101347:	56                   	push   %esi
f0101348:	53                   	push   %ebx
f0101349:	83 ec 14             	sub    $0x14,%esp
f010134c:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010134f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in

	// pte_t *tmp;
	pte_t *pte_store = NULL;
f0101352:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	struct PageInfo * pp = page_lookup(pgdir, va, &pte_store);
f0101359:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010135c:	50                   	push   %eax
f010135d:	56                   	push   %esi
f010135e:	53                   	push   %ebx
f010135f:	e8 45 ff ff ff       	call   f01012a9 <page_lookup>

	// if not present, silently return
	if (pp == NULL)
f0101364:	83 c4 10             	add    $0x10,%esp
f0101367:	85 c0                	test   %eax,%eax
f0101369:	74 1f                	je     f010138a <page_remove+0x46>
		return;

	// decrement ref count, and if reaches 0, free it
	page_decref(pp);
f010136b:	83 ec 0c             	sub    $0xc,%esp
f010136e:	50                   	push   %eax
f010136f:	e8 b6 fd ff ff       	call   f010112a <page_decref>

	// null the real PTE pointer 
	*pte_store = 0;
f0101374:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101377:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	// cprintf("[?] In page_remove\n");
	// cprintf("[?] *pte_store:%x, **pte_store:%x\n", *pte_store, **pte_store);

	// tlb invalidate
	tlb_invalidate(pgdir, va);
f010137d:	83 c4 08             	add    $0x8,%esp
f0101380:	56                   	push   %esi
f0101381:	53                   	push   %ebx
f0101382:	e8 88 ff ff ff       	call   f010130f <tlb_invalidate>
f0101387:	83 c4 10             	add    $0x10,%esp

}
f010138a:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010138d:	5b                   	pop    %ebx
f010138e:	5e                   	pop    %esi
f010138f:	5d                   	pop    %ebp
f0101390:	c3                   	ret    

f0101391 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101391:	55                   	push   %ebp
f0101392:	89 e5                	mov    %esp,%ebp
f0101394:	57                   	push   %edi
f0101395:	56                   	push   %esi
f0101396:	53                   	push   %ebx
f0101397:	83 ec 10             	sub    $0x10,%esp
f010139a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010139d:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in

	// find the real PTE for va
	// create on walk, if not present
	pte_t* pte = pgdir_walk(pgdir, va, 1);	
f01013a0:	6a 01                	push   $0x1
f01013a2:	57                   	push   %edi
f01013a3:	ff 75 08             	pushl  0x8(%ebp)
f01013a6:	e8 a6 fd ff ff       	call   f0101151 <pgdir_walk>

	if (pte == 0)
f01013ab:	83 c4 10             	add    $0x10,%esp
f01013ae:	85 c0                	test   %eax,%eax
f01013b0:	74 59                	je     f010140b <page_insert+0x7a>
f01013b2:	89 c6                	mov    %eax,%esi
		return -E_NO_MEM;

	// already have a page
	// remove it and invalidate tlb
	if (*pte != 0) {
f01013b4:	8b 00                	mov    (%eax),%eax
f01013b6:	85 c0                	test   %eax,%eax
f01013b8:	74 2d                	je     f01013e7 <page_insert+0x56>
		// corner case
		if (page2pa(pp) == PTE_ADDR(*pte))
f01013ba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01013bf:	89 da                	mov    %ebx,%edx
f01013c1:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f01013c7:	c1 fa 03             	sar    $0x3,%edx
f01013ca:	c1 e2 0c             	shl    $0xc,%edx
f01013cd:	39 d0                	cmp    %edx,%eax
f01013cf:	75 07                	jne    f01013d8 <page_insert+0x47>
			pp->pp_ref--;	// keep pp_ref consistent, in the meantime change perm potentially.
f01013d1:	66 83 6b 04 01       	subw   $0x1,0x4(%ebx)
f01013d6:	eb 0f                	jmp    f01013e7 <page_insert+0x56>
		else
			page_remove(pgdir, va);
f01013d8:	83 ec 08             	sub    $0x8,%esp
f01013db:	57                   	push   %edi
f01013dc:	ff 75 08             	pushl  0x8(%ebp)
f01013df:	e8 60 ff ff ff       	call   f0101344 <page_remove>
f01013e4:	83 c4 10             	add    $0x10,%esp

	// set the real PTE to pa, zero out least 12 bits
	*pte = PTE_ADDR(page2pa(pp));
	
	// set flags
	*pte |= (perm | PTE_P);
f01013e7:	89 d8                	mov    %ebx,%eax
f01013e9:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f01013ef:	c1 f8 03             	sar    $0x3,%eax
f01013f2:	c1 e0 0c             	shl    $0xc,%eax
f01013f5:	8b 55 14             	mov    0x14(%ebp),%edx
f01013f8:	83 ca 01             	or     $0x1,%edx
f01013fb:	09 d0                	or     %edx,%eax
f01013fd:	89 06                	mov    %eax,(%esi)

	// increment ref cnt
	pp->pp_ref++;
f01013ff:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)

	return 0;
f0101404:	b8 00 00 00 00       	mov    $0x0,%eax
f0101409:	eb 05                	jmp    f0101410 <page_insert+0x7f>
	// find the real PTE for va
	// create on walk, if not present
	pte_t* pte = pgdir_walk(pgdir, va, 1);	

	if (pte == 0)
		return -E_NO_MEM;
f010140b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax

	// increment ref cnt
	pp->pp_ref++;

	return 0;
}
f0101410:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101413:	5b                   	pop    %ebx
f0101414:	5e                   	pop    %esi
f0101415:	5f                   	pop    %edi
f0101416:	5d                   	pop    %ebp
f0101417:	c3                   	ret    

f0101418 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f0101418:	55                   	push   %ebp
f0101419:	89 e5                	mov    %esp,%ebp
f010141b:	56                   	push   %esi
f010141c:	53                   	push   %ebx
f010141d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	// panic("mmio_map_region not implemented");

	uintptr_t mmio = base;
f0101420:	8b 35 00 03 12 f0    	mov    0xf0120300,%esi

	if (ROUNDUP(mmio + size, PGSIZE) >= MMIOLIM)
f0101426:	8d 84 0e ff 0f 00 00 	lea    0xfff(%esi,%ecx,1),%eax
f010142d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101432:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0101437:	76 17                	jbe    f0101450 <mmio_map_region+0x38>
		panic("mmio_map_region: mmio out of memory");
f0101439:	83 ec 04             	sub    $0x4,%esp
f010143c:	68 f8 6a 10 f0       	push   $0xf0106af8
f0101441:	68 f9 02 00 00       	push   $0x2f9
f0101446:	68 bf 65 10 f0       	push   $0xf01065bf
f010144b:	e8 f0 eb ff ff       	call   f0100040 <_panic>
		
	boot_map_region(kern_pgdir, mmio, ROUNDUP(size, PGSIZE), pa, PTE_PCD|PTE_PWT|PTE_W);
f0101450:	8d 99 ff 0f 00 00    	lea    0xfff(%ecx),%ebx
f0101456:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f010145c:	83 ec 08             	sub    $0x8,%esp
f010145f:	6a 1a                	push   $0x1a
f0101461:	ff 75 08             	pushl  0x8(%ebp)
f0101464:	89 d9                	mov    %ebx,%ecx
f0101466:	89 f2                	mov    %esi,%edx
f0101468:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f010146d:	e8 75 fd ff ff       	call   f01011e7 <boot_map_region>

	base += ROUNDUP(size, PGSIZE);
f0101472:	01 1d 00 03 12 f0    	add    %ebx,0xf0120300

	return (void *)mmio;
}
f0101478:	89 f0                	mov    %esi,%eax
f010147a:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010147d:	5b                   	pop    %ebx
f010147e:	5e                   	pop    %esi
f010147f:	5d                   	pop    %ebp
f0101480:	c3                   	ret    

f0101481 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101481:	55                   	push   %ebp
f0101482:	89 e5                	mov    %esp,%ebp
f0101484:	57                   	push   %edi
f0101485:	56                   	push   %esi
f0101486:	53                   	push   %ebx
f0101487:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f010148a:	b8 15 00 00 00       	mov    $0x15,%eax
f010148f:	e8 26 f6 ff ff       	call   f0100aba <nvram_read>
f0101494:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0101496:	b8 17 00 00 00       	mov    $0x17,%eax
f010149b:	e8 1a f6 ff ff       	call   f0100aba <nvram_read>
f01014a0:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f01014a2:	b8 34 00 00 00       	mov    $0x34,%eax
f01014a7:	e8 0e f6 ff ff       	call   f0100aba <nvram_read>
f01014ac:	c1 e0 06             	shl    $0x6,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f01014af:	85 c0                	test   %eax,%eax
f01014b1:	74 07                	je     f01014ba <mem_init+0x39>
		totalmem = 16 * 1024 + ext16mem;
f01014b3:	05 00 40 00 00       	add    $0x4000,%eax
f01014b8:	eb 0b                	jmp    f01014c5 <mem_init+0x44>
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f01014ba:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f01014c0:	85 f6                	test   %esi,%esi
f01014c2:	0f 44 c3             	cmove  %ebx,%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f01014c5:	89 c2                	mov    %eax,%edx
f01014c7:	c1 ea 02             	shr    $0x2,%edx
f01014ca:	89 15 88 be 22 f0    	mov    %edx,0xf022be88
	npages_basemem = basemem / (PGSIZE / 1024);
f01014d0:	89 da                	mov    %ebx,%edx
f01014d2:	c1 ea 02             	shr    $0x2,%edx
f01014d5:	89 15 44 b2 22 f0    	mov    %edx,0xf022b244

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01014db:	89 c2                	mov    %eax,%edx
f01014dd:	29 da                	sub    %ebx,%edx
f01014df:	52                   	push   %edx
f01014e0:	53                   	push   %ebx
f01014e1:	50                   	push   %eax
f01014e2:	68 1c 6b 10 f0       	push   $0xf0106b1c
f01014e7:	e8 b5 23 00 00       	call   f01038a1 <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01014ec:	b8 00 10 00 00       	mov    $0x1000,%eax
f01014f1:	e8 ed f5 ff ff       	call   f0100ae3 <boot_alloc>
f01014f6:	a3 8c be 22 f0       	mov    %eax,0xf022be8c
	memset(kern_pgdir, 0, PGSIZE);
f01014fb:	83 c4 0c             	add    $0xc,%esp
f01014fe:	68 00 10 00 00       	push   $0x1000
f0101503:	6a 00                	push   $0x0
f0101505:	50                   	push   %eax
f0101506:	e8 19 3e 00 00       	call   f0105324 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010150b:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101510:	83 c4 10             	add    $0x10,%esp
f0101513:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101518:	77 15                	ja     f010152f <mem_init+0xae>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010151a:	50                   	push   %eax
f010151b:	68 28 60 10 f0       	push   $0xf0106028
f0101520:	68 99 00 00 00       	push   $0x99
f0101525:	68 bf 65 10 f0       	push   $0xf01065bf
f010152a:	e8 11 eb ff ff       	call   f0100040 <_panic>
f010152f:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101535:	83 ca 05             	or     $0x5,%edx
f0101538:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:

	n = npages * sizeof(struct PageInfo);
f010153e:	a1 88 be 22 f0       	mov    0xf022be88,%eax
f0101543:	8d 1c c5 00 00 00 00 	lea    0x0(,%eax,8),%ebx
	pages = (struct PageInfo *) boot_alloc(n);
f010154a:	89 d8                	mov    %ebx,%eax
f010154c:	e8 92 f5 ff ff       	call   f0100ae3 <boot_alloc>
f0101551:	a3 90 be 22 f0       	mov    %eax,0xf022be90
	memset(pages, 0, n);
f0101556:	83 ec 04             	sub    $0x4,%esp
f0101559:	53                   	push   %ebx
f010155a:	6a 00                	push   $0x0
f010155c:	50                   	push   %eax
f010155d:	e8 c2 3d 00 00       	call   f0105324 <memset>
	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.

	n = NENV * sizeof(struct Env);
	envs = (struct Env *) boot_alloc(n);
f0101562:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101567:	e8 77 f5 ff ff       	call   f0100ae3 <boot_alloc>
f010156c:	a3 48 b2 22 f0       	mov    %eax,0xf022b248
	memset(envs, 0, n);
f0101571:	83 c4 0c             	add    $0xc,%esp
f0101574:	68 00 f0 01 00       	push   $0x1f000
f0101579:	6a 00                	push   $0x0
f010157b:	50                   	push   %eax
f010157c:	e8 a3 3d 00 00       	call   f0105324 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101581:	e8 16 f9 ff ff       	call   f0100e9c <page_init>

	check_page_free_list(1);
f0101586:	b8 01 00 00 00       	mov    $0x1,%eax
f010158b:	e8 0a f6 ff ff       	call   f0100b9a <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101590:	83 c4 10             	add    $0x10,%esp
f0101593:	83 3d 90 be 22 f0 00 	cmpl   $0x0,0xf022be90
f010159a:	75 17                	jne    f01015b3 <mem_init+0x132>
		panic("'pages' is a null pointer!");
f010159c:	83 ec 04             	sub    $0x4,%esp
f010159f:	68 b3 66 10 f0       	push   $0xf01066b3
f01015a4:	68 9d 03 00 00       	push   $0x39d
f01015a9:	68 bf 65 10 f0       	push   $0xf01065bf
f01015ae:	e8 8d ea ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01015b3:	a1 40 b2 22 f0       	mov    0xf022b240,%eax
f01015b8:	bb 00 00 00 00       	mov    $0x0,%ebx
f01015bd:	eb 05                	jmp    f01015c4 <mem_init+0x143>
		++nfree;
f01015bf:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01015c2:	8b 00                	mov    (%eax),%eax
f01015c4:	85 c0                	test   %eax,%eax
f01015c6:	75 f7                	jne    f01015bf <mem_init+0x13e>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01015c8:	83 ec 0c             	sub    $0xc,%esp
f01015cb:	6a 00                	push   $0x0
f01015cd:	e8 91 fa ff ff       	call   f0101063 <page_alloc>
f01015d2:	89 c7                	mov    %eax,%edi
f01015d4:	83 c4 10             	add    $0x10,%esp
f01015d7:	85 c0                	test   %eax,%eax
f01015d9:	75 19                	jne    f01015f4 <mem_init+0x173>
f01015db:	68 ce 66 10 f0       	push   $0xf01066ce
f01015e0:	68 e5 65 10 f0       	push   $0xf01065e5
f01015e5:	68 a5 03 00 00       	push   $0x3a5
f01015ea:	68 bf 65 10 f0       	push   $0xf01065bf
f01015ef:	e8 4c ea ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01015f4:	83 ec 0c             	sub    $0xc,%esp
f01015f7:	6a 00                	push   $0x0
f01015f9:	e8 65 fa ff ff       	call   f0101063 <page_alloc>
f01015fe:	89 c6                	mov    %eax,%esi
f0101600:	83 c4 10             	add    $0x10,%esp
f0101603:	85 c0                	test   %eax,%eax
f0101605:	75 19                	jne    f0101620 <mem_init+0x19f>
f0101607:	68 e4 66 10 f0       	push   $0xf01066e4
f010160c:	68 e5 65 10 f0       	push   $0xf01065e5
f0101611:	68 a6 03 00 00       	push   $0x3a6
f0101616:	68 bf 65 10 f0       	push   $0xf01065bf
f010161b:	e8 20 ea ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101620:	83 ec 0c             	sub    $0xc,%esp
f0101623:	6a 00                	push   $0x0
f0101625:	e8 39 fa ff ff       	call   f0101063 <page_alloc>
f010162a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010162d:	83 c4 10             	add    $0x10,%esp
f0101630:	85 c0                	test   %eax,%eax
f0101632:	75 19                	jne    f010164d <mem_init+0x1cc>
f0101634:	68 fa 66 10 f0       	push   $0xf01066fa
f0101639:	68 e5 65 10 f0       	push   $0xf01065e5
f010163e:	68 a7 03 00 00       	push   $0x3a7
f0101643:	68 bf 65 10 f0       	push   $0xf01065bf
f0101648:	e8 f3 e9 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010164d:	39 f7                	cmp    %esi,%edi
f010164f:	75 19                	jne    f010166a <mem_init+0x1e9>
f0101651:	68 10 67 10 f0       	push   $0xf0106710
f0101656:	68 e5 65 10 f0       	push   $0xf01065e5
f010165b:	68 aa 03 00 00       	push   $0x3aa
f0101660:	68 bf 65 10 f0       	push   $0xf01065bf
f0101665:	e8 d6 e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010166a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010166d:	39 c6                	cmp    %eax,%esi
f010166f:	74 04                	je     f0101675 <mem_init+0x1f4>
f0101671:	39 c7                	cmp    %eax,%edi
f0101673:	75 19                	jne    f010168e <mem_init+0x20d>
f0101675:	68 58 6b 10 f0       	push   $0xf0106b58
f010167a:	68 e5 65 10 f0       	push   $0xf01065e5
f010167f:	68 ab 03 00 00       	push   $0x3ab
f0101684:	68 bf 65 10 f0       	push   $0xf01065bf
f0101689:	e8 b2 e9 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010168e:	8b 0d 90 be 22 f0    	mov    0xf022be90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101694:	8b 15 88 be 22 f0    	mov    0xf022be88,%edx
f010169a:	c1 e2 0c             	shl    $0xc,%edx
f010169d:	89 f8                	mov    %edi,%eax
f010169f:	29 c8                	sub    %ecx,%eax
f01016a1:	c1 f8 03             	sar    $0x3,%eax
f01016a4:	c1 e0 0c             	shl    $0xc,%eax
f01016a7:	39 d0                	cmp    %edx,%eax
f01016a9:	72 19                	jb     f01016c4 <mem_init+0x243>
f01016ab:	68 22 67 10 f0       	push   $0xf0106722
f01016b0:	68 e5 65 10 f0       	push   $0xf01065e5
f01016b5:	68 ac 03 00 00       	push   $0x3ac
f01016ba:	68 bf 65 10 f0       	push   $0xf01065bf
f01016bf:	e8 7c e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01016c4:	89 f0                	mov    %esi,%eax
f01016c6:	29 c8                	sub    %ecx,%eax
f01016c8:	c1 f8 03             	sar    $0x3,%eax
f01016cb:	c1 e0 0c             	shl    $0xc,%eax
f01016ce:	39 c2                	cmp    %eax,%edx
f01016d0:	77 19                	ja     f01016eb <mem_init+0x26a>
f01016d2:	68 3f 67 10 f0       	push   $0xf010673f
f01016d7:	68 e5 65 10 f0       	push   $0xf01065e5
f01016dc:	68 ad 03 00 00       	push   $0x3ad
f01016e1:	68 bf 65 10 f0       	push   $0xf01065bf
f01016e6:	e8 55 e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01016eb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01016ee:	29 c8                	sub    %ecx,%eax
f01016f0:	c1 f8 03             	sar    $0x3,%eax
f01016f3:	c1 e0 0c             	shl    $0xc,%eax
f01016f6:	39 c2                	cmp    %eax,%edx
f01016f8:	77 19                	ja     f0101713 <mem_init+0x292>
f01016fa:	68 5c 67 10 f0       	push   $0xf010675c
f01016ff:	68 e5 65 10 f0       	push   $0xf01065e5
f0101704:	68 ae 03 00 00       	push   $0x3ae
f0101709:	68 bf 65 10 f0       	push   $0xf01065bf
f010170e:	e8 2d e9 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101713:	a1 40 b2 22 f0       	mov    0xf022b240,%eax
f0101718:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010171b:	c7 05 40 b2 22 f0 00 	movl   $0x0,0xf022b240
f0101722:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101725:	83 ec 0c             	sub    $0xc,%esp
f0101728:	6a 00                	push   $0x0
f010172a:	e8 34 f9 ff ff       	call   f0101063 <page_alloc>
f010172f:	83 c4 10             	add    $0x10,%esp
f0101732:	85 c0                	test   %eax,%eax
f0101734:	74 19                	je     f010174f <mem_init+0x2ce>
f0101736:	68 79 67 10 f0       	push   $0xf0106779
f010173b:	68 e5 65 10 f0       	push   $0xf01065e5
f0101740:	68 b5 03 00 00       	push   $0x3b5
f0101745:	68 bf 65 10 f0       	push   $0xf01065bf
f010174a:	e8 f1 e8 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f010174f:	83 ec 0c             	sub    $0xc,%esp
f0101752:	57                   	push   %edi
f0101753:	e8 7c f9 ff ff       	call   f01010d4 <page_free>
	page_free(pp1);
f0101758:	89 34 24             	mov    %esi,(%esp)
f010175b:	e8 74 f9 ff ff       	call   f01010d4 <page_free>
	page_free(pp2);
f0101760:	83 c4 04             	add    $0x4,%esp
f0101763:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101766:	e8 69 f9 ff ff       	call   f01010d4 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010176b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101772:	e8 ec f8 ff ff       	call   f0101063 <page_alloc>
f0101777:	89 c6                	mov    %eax,%esi
f0101779:	83 c4 10             	add    $0x10,%esp
f010177c:	85 c0                	test   %eax,%eax
f010177e:	75 19                	jne    f0101799 <mem_init+0x318>
f0101780:	68 ce 66 10 f0       	push   $0xf01066ce
f0101785:	68 e5 65 10 f0       	push   $0xf01065e5
f010178a:	68 bc 03 00 00       	push   $0x3bc
f010178f:	68 bf 65 10 f0       	push   $0xf01065bf
f0101794:	e8 a7 e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101799:	83 ec 0c             	sub    $0xc,%esp
f010179c:	6a 00                	push   $0x0
f010179e:	e8 c0 f8 ff ff       	call   f0101063 <page_alloc>
f01017a3:	89 c7                	mov    %eax,%edi
f01017a5:	83 c4 10             	add    $0x10,%esp
f01017a8:	85 c0                	test   %eax,%eax
f01017aa:	75 19                	jne    f01017c5 <mem_init+0x344>
f01017ac:	68 e4 66 10 f0       	push   $0xf01066e4
f01017b1:	68 e5 65 10 f0       	push   $0xf01065e5
f01017b6:	68 bd 03 00 00       	push   $0x3bd
f01017bb:	68 bf 65 10 f0       	push   $0xf01065bf
f01017c0:	e8 7b e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01017c5:	83 ec 0c             	sub    $0xc,%esp
f01017c8:	6a 00                	push   $0x0
f01017ca:	e8 94 f8 ff ff       	call   f0101063 <page_alloc>
f01017cf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01017d2:	83 c4 10             	add    $0x10,%esp
f01017d5:	85 c0                	test   %eax,%eax
f01017d7:	75 19                	jne    f01017f2 <mem_init+0x371>
f01017d9:	68 fa 66 10 f0       	push   $0xf01066fa
f01017de:	68 e5 65 10 f0       	push   $0xf01065e5
f01017e3:	68 be 03 00 00       	push   $0x3be
f01017e8:	68 bf 65 10 f0       	push   $0xf01065bf
f01017ed:	e8 4e e8 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01017f2:	39 fe                	cmp    %edi,%esi
f01017f4:	75 19                	jne    f010180f <mem_init+0x38e>
f01017f6:	68 10 67 10 f0       	push   $0xf0106710
f01017fb:	68 e5 65 10 f0       	push   $0xf01065e5
f0101800:	68 c0 03 00 00       	push   $0x3c0
f0101805:	68 bf 65 10 f0       	push   $0xf01065bf
f010180a:	e8 31 e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010180f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101812:	39 c7                	cmp    %eax,%edi
f0101814:	74 04                	je     f010181a <mem_init+0x399>
f0101816:	39 c6                	cmp    %eax,%esi
f0101818:	75 19                	jne    f0101833 <mem_init+0x3b2>
f010181a:	68 58 6b 10 f0       	push   $0xf0106b58
f010181f:	68 e5 65 10 f0       	push   $0xf01065e5
f0101824:	68 c1 03 00 00       	push   $0x3c1
f0101829:	68 bf 65 10 f0       	push   $0xf01065bf
f010182e:	e8 0d e8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101833:	83 ec 0c             	sub    $0xc,%esp
f0101836:	6a 00                	push   $0x0
f0101838:	e8 26 f8 ff ff       	call   f0101063 <page_alloc>
f010183d:	83 c4 10             	add    $0x10,%esp
f0101840:	85 c0                	test   %eax,%eax
f0101842:	74 19                	je     f010185d <mem_init+0x3dc>
f0101844:	68 79 67 10 f0       	push   $0xf0106779
f0101849:	68 e5 65 10 f0       	push   $0xf01065e5
f010184e:	68 c2 03 00 00       	push   $0x3c2
f0101853:	68 bf 65 10 f0       	push   $0xf01065bf
f0101858:	e8 e3 e7 ff ff       	call   f0100040 <_panic>
f010185d:	89 f0                	mov    %esi,%eax
f010185f:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0101865:	c1 f8 03             	sar    $0x3,%eax
f0101868:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010186b:	89 c2                	mov    %eax,%edx
f010186d:	c1 ea 0c             	shr    $0xc,%edx
f0101870:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f0101876:	72 12                	jb     f010188a <mem_init+0x409>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101878:	50                   	push   %eax
f0101879:	68 04 60 10 f0       	push   $0xf0106004
f010187e:	6a 58                	push   $0x58
f0101880:	68 cb 65 10 f0       	push   $0xf01065cb
f0101885:	e8 b6 e7 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f010188a:	83 ec 04             	sub    $0x4,%esp
f010188d:	68 00 10 00 00       	push   $0x1000
f0101892:	6a 01                	push   $0x1
f0101894:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101899:	50                   	push   %eax
f010189a:	e8 85 3a 00 00       	call   f0105324 <memset>
	page_free(pp0);
f010189f:	89 34 24             	mov    %esi,(%esp)
f01018a2:	e8 2d f8 ff ff       	call   f01010d4 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01018a7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01018ae:	e8 b0 f7 ff ff       	call   f0101063 <page_alloc>
f01018b3:	83 c4 10             	add    $0x10,%esp
f01018b6:	85 c0                	test   %eax,%eax
f01018b8:	75 19                	jne    f01018d3 <mem_init+0x452>
f01018ba:	68 88 67 10 f0       	push   $0xf0106788
f01018bf:	68 e5 65 10 f0       	push   $0xf01065e5
f01018c4:	68 c7 03 00 00       	push   $0x3c7
f01018c9:	68 bf 65 10 f0       	push   $0xf01065bf
f01018ce:	e8 6d e7 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f01018d3:	39 c6                	cmp    %eax,%esi
f01018d5:	74 19                	je     f01018f0 <mem_init+0x46f>
f01018d7:	68 a6 67 10 f0       	push   $0xf01067a6
f01018dc:	68 e5 65 10 f0       	push   $0xf01065e5
f01018e1:	68 c8 03 00 00       	push   $0x3c8
f01018e6:	68 bf 65 10 f0       	push   $0xf01065bf
f01018eb:	e8 50 e7 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01018f0:	89 f0                	mov    %esi,%eax
f01018f2:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f01018f8:	c1 f8 03             	sar    $0x3,%eax
f01018fb:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01018fe:	89 c2                	mov    %eax,%edx
f0101900:	c1 ea 0c             	shr    $0xc,%edx
f0101903:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f0101909:	72 12                	jb     f010191d <mem_init+0x49c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010190b:	50                   	push   %eax
f010190c:	68 04 60 10 f0       	push   $0xf0106004
f0101911:	6a 58                	push   $0x58
f0101913:	68 cb 65 10 f0       	push   $0xf01065cb
f0101918:	e8 23 e7 ff ff       	call   f0100040 <_panic>
f010191d:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101923:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++) {
		// cprintf("[?] %d\n", i);
		assert(c[i] == 0);
f0101929:	80 38 00             	cmpb   $0x0,(%eax)
f010192c:	74 19                	je     f0101947 <mem_init+0x4c6>
f010192e:	68 b6 67 10 f0       	push   $0xf01067b6
f0101933:	68 e5 65 10 f0       	push   $0xf01065e5
f0101938:	68 cc 03 00 00       	push   $0x3cc
f010193d:	68 bf 65 10 f0       	push   $0xf01065bf
f0101942:	e8 f9 e6 ff ff       	call   f0100040 <_panic>
f0101947:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++) {
f010194a:	39 d0                	cmp    %edx,%eax
f010194c:	75 db                	jne    f0101929 <mem_init+0x4a8>
		// cprintf("[?] %d\n", i);
		assert(c[i] == 0);
	}

	// give free list back
	page_free_list = fl;
f010194e:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101951:	a3 40 b2 22 f0       	mov    %eax,0xf022b240

	// free the pages we took
	page_free(pp0);
f0101956:	83 ec 0c             	sub    $0xc,%esp
f0101959:	56                   	push   %esi
f010195a:	e8 75 f7 ff ff       	call   f01010d4 <page_free>
	page_free(pp1);
f010195f:	89 3c 24             	mov    %edi,(%esp)
f0101962:	e8 6d f7 ff ff       	call   f01010d4 <page_free>
	page_free(pp2);
f0101967:	83 c4 04             	add    $0x4,%esp
f010196a:	ff 75 d4             	pushl  -0x2c(%ebp)
f010196d:	e8 62 f7 ff ff       	call   f01010d4 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101972:	a1 40 b2 22 f0       	mov    0xf022b240,%eax
f0101977:	83 c4 10             	add    $0x10,%esp
f010197a:	eb 05                	jmp    f0101981 <mem_init+0x500>
		--nfree;
f010197c:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010197f:	8b 00                	mov    (%eax),%eax
f0101981:	85 c0                	test   %eax,%eax
f0101983:	75 f7                	jne    f010197c <mem_init+0x4fb>
		--nfree;
	assert(nfree == 0);
f0101985:	85 db                	test   %ebx,%ebx
f0101987:	74 19                	je     f01019a2 <mem_init+0x521>
f0101989:	68 c0 67 10 f0       	push   $0xf01067c0
f010198e:	68 e5 65 10 f0       	push   $0xf01065e5
f0101993:	68 da 03 00 00       	push   $0x3da
f0101998:	68 bf 65 10 f0       	push   $0xf01065bf
f010199d:	e8 9e e6 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f01019a2:	83 ec 0c             	sub    $0xc,%esp
f01019a5:	68 78 6b 10 f0       	push   $0xf0106b78
f01019aa:	e8 f2 1e 00 00       	call   f01038a1 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01019af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019b6:	e8 a8 f6 ff ff       	call   f0101063 <page_alloc>
f01019bb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01019be:	83 c4 10             	add    $0x10,%esp
f01019c1:	85 c0                	test   %eax,%eax
f01019c3:	75 19                	jne    f01019de <mem_init+0x55d>
f01019c5:	68 ce 66 10 f0       	push   $0xf01066ce
f01019ca:	68 e5 65 10 f0       	push   $0xf01065e5
f01019cf:	68 44 04 00 00       	push   $0x444
f01019d4:	68 bf 65 10 f0       	push   $0xf01065bf
f01019d9:	e8 62 e6 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01019de:	83 ec 0c             	sub    $0xc,%esp
f01019e1:	6a 00                	push   $0x0
f01019e3:	e8 7b f6 ff ff       	call   f0101063 <page_alloc>
f01019e8:	89 c3                	mov    %eax,%ebx
f01019ea:	83 c4 10             	add    $0x10,%esp
f01019ed:	85 c0                	test   %eax,%eax
f01019ef:	75 19                	jne    f0101a0a <mem_init+0x589>
f01019f1:	68 e4 66 10 f0       	push   $0xf01066e4
f01019f6:	68 e5 65 10 f0       	push   $0xf01065e5
f01019fb:	68 45 04 00 00       	push   $0x445
f0101a00:	68 bf 65 10 f0       	push   $0xf01065bf
f0101a05:	e8 36 e6 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101a0a:	83 ec 0c             	sub    $0xc,%esp
f0101a0d:	6a 00                	push   $0x0
f0101a0f:	e8 4f f6 ff ff       	call   f0101063 <page_alloc>
f0101a14:	89 c6                	mov    %eax,%esi
f0101a16:	83 c4 10             	add    $0x10,%esp
f0101a19:	85 c0                	test   %eax,%eax
f0101a1b:	75 19                	jne    f0101a36 <mem_init+0x5b5>
f0101a1d:	68 fa 66 10 f0       	push   $0xf01066fa
f0101a22:	68 e5 65 10 f0       	push   $0xf01065e5
f0101a27:	68 46 04 00 00       	push   $0x446
f0101a2c:	68 bf 65 10 f0       	push   $0xf01065bf
f0101a31:	e8 0a e6 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101a36:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101a39:	75 19                	jne    f0101a54 <mem_init+0x5d3>
f0101a3b:	68 10 67 10 f0       	push   $0xf0106710
f0101a40:	68 e5 65 10 f0       	push   $0xf01065e5
f0101a45:	68 49 04 00 00       	push   $0x449
f0101a4a:	68 bf 65 10 f0       	push   $0xf01065bf
f0101a4f:	e8 ec e5 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a54:	39 c3                	cmp    %eax,%ebx
f0101a56:	74 05                	je     f0101a5d <mem_init+0x5dc>
f0101a58:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101a5b:	75 19                	jne    f0101a76 <mem_init+0x5f5>
f0101a5d:	68 58 6b 10 f0       	push   $0xf0106b58
f0101a62:	68 e5 65 10 f0       	push   $0xf01065e5
f0101a67:	68 4a 04 00 00       	push   $0x44a
f0101a6c:	68 bf 65 10 f0       	push   $0xf01065bf
f0101a71:	e8 ca e5 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101a76:	a1 40 b2 22 f0       	mov    0xf022b240,%eax
f0101a7b:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101a7e:	c7 05 40 b2 22 f0 00 	movl   $0x0,0xf022b240
f0101a85:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101a88:	83 ec 0c             	sub    $0xc,%esp
f0101a8b:	6a 00                	push   $0x0
f0101a8d:	e8 d1 f5 ff ff       	call   f0101063 <page_alloc>
f0101a92:	83 c4 10             	add    $0x10,%esp
f0101a95:	85 c0                	test   %eax,%eax
f0101a97:	74 19                	je     f0101ab2 <mem_init+0x631>
f0101a99:	68 79 67 10 f0       	push   $0xf0106779
f0101a9e:	68 e5 65 10 f0       	push   $0xf01065e5
f0101aa3:	68 51 04 00 00       	push   $0x451
f0101aa8:	68 bf 65 10 f0       	push   $0xf01065bf
f0101aad:	e8 8e e5 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101ab2:	83 ec 04             	sub    $0x4,%esp
f0101ab5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101ab8:	50                   	push   %eax
f0101ab9:	6a 00                	push   $0x0
f0101abb:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0101ac1:	e8 e3 f7 ff ff       	call   f01012a9 <page_lookup>
f0101ac6:	83 c4 10             	add    $0x10,%esp
f0101ac9:	85 c0                	test   %eax,%eax
f0101acb:	74 19                	je     f0101ae6 <mem_init+0x665>
f0101acd:	68 98 6b 10 f0       	push   $0xf0106b98
f0101ad2:	68 e5 65 10 f0       	push   $0xf01065e5
f0101ad7:	68 54 04 00 00       	push   $0x454
f0101adc:	68 bf 65 10 f0       	push   $0xf01065bf
f0101ae1:	e8 5a e5 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101ae6:	6a 02                	push   $0x2
f0101ae8:	6a 00                	push   $0x0
f0101aea:	53                   	push   %ebx
f0101aeb:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0101af1:	e8 9b f8 ff ff       	call   f0101391 <page_insert>
f0101af6:	83 c4 10             	add    $0x10,%esp
f0101af9:	85 c0                	test   %eax,%eax
f0101afb:	78 19                	js     f0101b16 <mem_init+0x695>
f0101afd:	68 d0 6b 10 f0       	push   $0xf0106bd0
f0101b02:	68 e5 65 10 f0       	push   $0xf01065e5
f0101b07:	68 57 04 00 00       	push   $0x457
f0101b0c:	68 bf 65 10 f0       	push   $0xf01065bf
f0101b11:	e8 2a e5 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101b16:	83 ec 0c             	sub    $0xc,%esp
f0101b19:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101b1c:	e8 b3 f5 ff ff       	call   f01010d4 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101b21:	6a 02                	push   $0x2
f0101b23:	6a 00                	push   $0x0
f0101b25:	53                   	push   %ebx
f0101b26:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0101b2c:	e8 60 f8 ff ff       	call   f0101391 <page_insert>
f0101b31:	83 c4 20             	add    $0x20,%esp
f0101b34:	85 c0                	test   %eax,%eax
f0101b36:	74 19                	je     f0101b51 <mem_init+0x6d0>
f0101b38:	68 00 6c 10 f0       	push   $0xf0106c00
f0101b3d:	68 e5 65 10 f0       	push   $0xf01065e5
f0101b42:	68 5b 04 00 00       	push   $0x45b
f0101b47:	68 bf 65 10 f0       	push   $0xf01065bf
f0101b4c:	e8 ef e4 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101b51:	8b 3d 8c be 22 f0    	mov    0xf022be8c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b57:	a1 90 be 22 f0       	mov    0xf022be90,%eax
f0101b5c:	89 c1                	mov    %eax,%ecx
f0101b5e:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101b61:	8b 17                	mov    (%edi),%edx
f0101b63:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101b69:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b6c:	29 c8                	sub    %ecx,%eax
f0101b6e:	c1 f8 03             	sar    $0x3,%eax
f0101b71:	c1 e0 0c             	shl    $0xc,%eax
f0101b74:	39 c2                	cmp    %eax,%edx
f0101b76:	74 19                	je     f0101b91 <mem_init+0x710>
f0101b78:	68 30 6c 10 f0       	push   $0xf0106c30
f0101b7d:	68 e5 65 10 f0       	push   $0xf01065e5
f0101b82:	68 5c 04 00 00       	push   $0x45c
f0101b87:	68 bf 65 10 f0       	push   $0xf01065bf
f0101b8c:	e8 af e4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101b91:	ba 00 00 00 00       	mov    $0x0,%edx
f0101b96:	89 f8                	mov    %edi,%eax
f0101b98:	e8 99 ef ff ff       	call   f0100b36 <check_va2pa>
f0101b9d:	89 da                	mov    %ebx,%edx
f0101b9f:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101ba2:	c1 fa 03             	sar    $0x3,%edx
f0101ba5:	c1 e2 0c             	shl    $0xc,%edx
f0101ba8:	39 d0                	cmp    %edx,%eax
f0101baa:	74 19                	je     f0101bc5 <mem_init+0x744>
f0101bac:	68 58 6c 10 f0       	push   $0xf0106c58
f0101bb1:	68 e5 65 10 f0       	push   $0xf01065e5
f0101bb6:	68 5d 04 00 00       	push   $0x45d
f0101bbb:	68 bf 65 10 f0       	push   $0xf01065bf
f0101bc0:	e8 7b e4 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101bc5:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101bca:	74 19                	je     f0101be5 <mem_init+0x764>
f0101bcc:	68 cb 67 10 f0       	push   $0xf01067cb
f0101bd1:	68 e5 65 10 f0       	push   $0xf01065e5
f0101bd6:	68 5e 04 00 00       	push   $0x45e
f0101bdb:	68 bf 65 10 f0       	push   $0xf01065bf
f0101be0:	e8 5b e4 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101be5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101be8:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101bed:	74 19                	je     f0101c08 <mem_init+0x787>
f0101bef:	68 dc 67 10 f0       	push   $0xf01067dc
f0101bf4:	68 e5 65 10 f0       	push   $0xf01065e5
f0101bf9:	68 5f 04 00 00       	push   $0x45f
f0101bfe:	68 bf 65 10 f0       	push   $0xf01065bf
f0101c03:	e8 38 e4 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c08:	6a 02                	push   $0x2
f0101c0a:	68 00 10 00 00       	push   $0x1000
f0101c0f:	56                   	push   %esi
f0101c10:	57                   	push   %edi
f0101c11:	e8 7b f7 ff ff       	call   f0101391 <page_insert>
f0101c16:	83 c4 10             	add    $0x10,%esp
f0101c19:	85 c0                	test   %eax,%eax
f0101c1b:	74 19                	je     f0101c36 <mem_init+0x7b5>
f0101c1d:	68 88 6c 10 f0       	push   $0xf0106c88
f0101c22:	68 e5 65 10 f0       	push   $0xf01065e5
f0101c27:	68 62 04 00 00       	push   $0x462
f0101c2c:	68 bf 65 10 f0       	push   $0xf01065bf
f0101c31:	e8 0a e4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c36:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c3b:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0101c40:	e8 f1 ee ff ff       	call   f0100b36 <check_va2pa>
f0101c45:	89 f2                	mov    %esi,%edx
f0101c47:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0101c4d:	c1 fa 03             	sar    $0x3,%edx
f0101c50:	c1 e2 0c             	shl    $0xc,%edx
f0101c53:	39 d0                	cmp    %edx,%eax
f0101c55:	74 19                	je     f0101c70 <mem_init+0x7ef>
f0101c57:	68 c4 6c 10 f0       	push   $0xf0106cc4
f0101c5c:	68 e5 65 10 f0       	push   $0xf01065e5
f0101c61:	68 63 04 00 00       	push   $0x463
f0101c66:	68 bf 65 10 f0       	push   $0xf01065bf
f0101c6b:	e8 d0 e3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101c70:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101c75:	74 19                	je     f0101c90 <mem_init+0x80f>
f0101c77:	68 ed 67 10 f0       	push   $0xf01067ed
f0101c7c:	68 e5 65 10 f0       	push   $0xf01065e5
f0101c81:	68 64 04 00 00       	push   $0x464
f0101c86:	68 bf 65 10 f0       	push   $0xf01065bf
f0101c8b:	e8 b0 e3 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101c90:	83 ec 0c             	sub    $0xc,%esp
f0101c93:	6a 00                	push   $0x0
f0101c95:	e8 c9 f3 ff ff       	call   f0101063 <page_alloc>
f0101c9a:	83 c4 10             	add    $0x10,%esp
f0101c9d:	85 c0                	test   %eax,%eax
f0101c9f:	74 19                	je     f0101cba <mem_init+0x839>
f0101ca1:	68 79 67 10 f0       	push   $0xf0106779
f0101ca6:	68 e5 65 10 f0       	push   $0xf01065e5
f0101cab:	68 67 04 00 00       	push   $0x467
f0101cb0:	68 bf 65 10 f0       	push   $0xf01065bf
f0101cb5:	e8 86 e3 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101cba:	6a 02                	push   $0x2
f0101cbc:	68 00 10 00 00       	push   $0x1000
f0101cc1:	56                   	push   %esi
f0101cc2:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0101cc8:	e8 c4 f6 ff ff       	call   f0101391 <page_insert>
f0101ccd:	83 c4 10             	add    $0x10,%esp
f0101cd0:	85 c0                	test   %eax,%eax
f0101cd2:	74 19                	je     f0101ced <mem_init+0x86c>
f0101cd4:	68 88 6c 10 f0       	push   $0xf0106c88
f0101cd9:	68 e5 65 10 f0       	push   $0xf01065e5
f0101cde:	68 6a 04 00 00       	push   $0x46a
f0101ce3:	68 bf 65 10 f0       	push   $0xf01065bf
f0101ce8:	e8 53 e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ced:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101cf2:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0101cf7:	e8 3a ee ff ff       	call   f0100b36 <check_va2pa>
f0101cfc:	89 f2                	mov    %esi,%edx
f0101cfe:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0101d04:	c1 fa 03             	sar    $0x3,%edx
f0101d07:	c1 e2 0c             	shl    $0xc,%edx
f0101d0a:	39 d0                	cmp    %edx,%eax
f0101d0c:	74 19                	je     f0101d27 <mem_init+0x8a6>
f0101d0e:	68 c4 6c 10 f0       	push   $0xf0106cc4
f0101d13:	68 e5 65 10 f0       	push   $0xf01065e5
f0101d18:	68 6b 04 00 00       	push   $0x46b
f0101d1d:	68 bf 65 10 f0       	push   $0xf01065bf
f0101d22:	e8 19 e3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101d27:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d2c:	74 19                	je     f0101d47 <mem_init+0x8c6>
f0101d2e:	68 ed 67 10 f0       	push   $0xf01067ed
f0101d33:	68 e5 65 10 f0       	push   $0xf01065e5
f0101d38:	68 6c 04 00 00       	push   $0x46c
f0101d3d:	68 bf 65 10 f0       	push   $0xf01065bf
f0101d42:	e8 f9 e2 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101d47:	83 ec 0c             	sub    $0xc,%esp
f0101d4a:	6a 00                	push   $0x0
f0101d4c:	e8 12 f3 ff ff       	call   f0101063 <page_alloc>
f0101d51:	83 c4 10             	add    $0x10,%esp
f0101d54:	85 c0                	test   %eax,%eax
f0101d56:	74 19                	je     f0101d71 <mem_init+0x8f0>
f0101d58:	68 79 67 10 f0       	push   $0xf0106779
f0101d5d:	68 e5 65 10 f0       	push   $0xf01065e5
f0101d62:	68 70 04 00 00       	push   $0x470
f0101d67:	68 bf 65 10 f0       	push   $0xf01065bf
f0101d6c:	e8 cf e2 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101d71:	8b 15 8c be 22 f0    	mov    0xf022be8c,%edx
f0101d77:	8b 02                	mov    (%edx),%eax
f0101d79:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101d7e:	89 c1                	mov    %eax,%ecx
f0101d80:	c1 e9 0c             	shr    $0xc,%ecx
f0101d83:	3b 0d 88 be 22 f0    	cmp    0xf022be88,%ecx
f0101d89:	72 15                	jb     f0101da0 <mem_init+0x91f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101d8b:	50                   	push   %eax
f0101d8c:	68 04 60 10 f0       	push   $0xf0106004
f0101d91:	68 73 04 00 00       	push   $0x473
f0101d96:	68 bf 65 10 f0       	push   $0xf01065bf
f0101d9b:	e8 a0 e2 ff ff       	call   f0100040 <_panic>
f0101da0:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101da5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101da8:	83 ec 04             	sub    $0x4,%esp
f0101dab:	6a 00                	push   $0x0
f0101dad:	68 00 10 00 00       	push   $0x1000
f0101db2:	52                   	push   %edx
f0101db3:	e8 99 f3 ff ff       	call   f0101151 <pgdir_walk>
f0101db8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101dbb:	8d 51 04             	lea    0x4(%ecx),%edx
f0101dbe:	83 c4 10             	add    $0x10,%esp
f0101dc1:	39 d0                	cmp    %edx,%eax
f0101dc3:	74 19                	je     f0101dde <mem_init+0x95d>
f0101dc5:	68 f4 6c 10 f0       	push   $0xf0106cf4
f0101dca:	68 e5 65 10 f0       	push   $0xf01065e5
f0101dcf:	68 74 04 00 00       	push   $0x474
f0101dd4:	68 bf 65 10 f0       	push   $0xf01065bf
f0101dd9:	e8 62 e2 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101dde:	6a 06                	push   $0x6
f0101de0:	68 00 10 00 00       	push   $0x1000
f0101de5:	56                   	push   %esi
f0101de6:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0101dec:	e8 a0 f5 ff ff       	call   f0101391 <page_insert>
f0101df1:	83 c4 10             	add    $0x10,%esp
f0101df4:	85 c0                	test   %eax,%eax
f0101df6:	74 19                	je     f0101e11 <mem_init+0x990>
f0101df8:	68 34 6d 10 f0       	push   $0xf0106d34
f0101dfd:	68 e5 65 10 f0       	push   $0xf01065e5
f0101e02:	68 77 04 00 00       	push   $0x477
f0101e07:	68 bf 65 10 f0       	push   $0xf01065bf
f0101e0c:	e8 2f e2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e11:	8b 3d 8c be 22 f0    	mov    0xf022be8c,%edi
f0101e17:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e1c:	89 f8                	mov    %edi,%eax
f0101e1e:	e8 13 ed ff ff       	call   f0100b36 <check_va2pa>
f0101e23:	89 f2                	mov    %esi,%edx
f0101e25:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0101e2b:	c1 fa 03             	sar    $0x3,%edx
f0101e2e:	c1 e2 0c             	shl    $0xc,%edx
f0101e31:	39 d0                	cmp    %edx,%eax
f0101e33:	74 19                	je     f0101e4e <mem_init+0x9cd>
f0101e35:	68 c4 6c 10 f0       	push   $0xf0106cc4
f0101e3a:	68 e5 65 10 f0       	push   $0xf01065e5
f0101e3f:	68 78 04 00 00       	push   $0x478
f0101e44:	68 bf 65 10 f0       	push   $0xf01065bf
f0101e49:	e8 f2 e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101e4e:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101e53:	74 19                	je     f0101e6e <mem_init+0x9ed>
f0101e55:	68 ed 67 10 f0       	push   $0xf01067ed
f0101e5a:	68 e5 65 10 f0       	push   $0xf01065e5
f0101e5f:	68 79 04 00 00       	push   $0x479
f0101e64:	68 bf 65 10 f0       	push   $0xf01065bf
f0101e69:	e8 d2 e1 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101e6e:	83 ec 04             	sub    $0x4,%esp
f0101e71:	6a 00                	push   $0x0
f0101e73:	68 00 10 00 00       	push   $0x1000
f0101e78:	57                   	push   %edi
f0101e79:	e8 d3 f2 ff ff       	call   f0101151 <pgdir_walk>
f0101e7e:	83 c4 10             	add    $0x10,%esp
f0101e81:	f6 00 04             	testb  $0x4,(%eax)
f0101e84:	75 19                	jne    f0101e9f <mem_init+0xa1e>
f0101e86:	68 74 6d 10 f0       	push   $0xf0106d74
f0101e8b:	68 e5 65 10 f0       	push   $0xf01065e5
f0101e90:	68 7a 04 00 00       	push   $0x47a
f0101e95:	68 bf 65 10 f0       	push   $0xf01065bf
f0101e9a:	e8 a1 e1 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101e9f:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0101ea4:	f6 00 04             	testb  $0x4,(%eax)
f0101ea7:	75 19                	jne    f0101ec2 <mem_init+0xa41>
f0101ea9:	68 fe 67 10 f0       	push   $0xf01067fe
f0101eae:	68 e5 65 10 f0       	push   $0xf01065e5
f0101eb3:	68 7b 04 00 00       	push   $0x47b
f0101eb8:	68 bf 65 10 f0       	push   $0xf01065bf
f0101ebd:	e8 7e e1 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ec2:	6a 02                	push   $0x2
f0101ec4:	68 00 10 00 00       	push   $0x1000
f0101ec9:	56                   	push   %esi
f0101eca:	50                   	push   %eax
f0101ecb:	e8 c1 f4 ff ff       	call   f0101391 <page_insert>
f0101ed0:	83 c4 10             	add    $0x10,%esp
f0101ed3:	85 c0                	test   %eax,%eax
f0101ed5:	74 19                	je     f0101ef0 <mem_init+0xa6f>
f0101ed7:	68 88 6c 10 f0       	push   $0xf0106c88
f0101edc:	68 e5 65 10 f0       	push   $0xf01065e5
f0101ee1:	68 7e 04 00 00       	push   $0x47e
f0101ee6:	68 bf 65 10 f0       	push   $0xf01065bf
f0101eeb:	e8 50 e1 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101ef0:	83 ec 04             	sub    $0x4,%esp
f0101ef3:	6a 00                	push   $0x0
f0101ef5:	68 00 10 00 00       	push   $0x1000
f0101efa:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0101f00:	e8 4c f2 ff ff       	call   f0101151 <pgdir_walk>
f0101f05:	83 c4 10             	add    $0x10,%esp
f0101f08:	f6 00 02             	testb  $0x2,(%eax)
f0101f0b:	75 19                	jne    f0101f26 <mem_init+0xaa5>
f0101f0d:	68 a8 6d 10 f0       	push   $0xf0106da8
f0101f12:	68 e5 65 10 f0       	push   $0xf01065e5
f0101f17:	68 7f 04 00 00       	push   $0x47f
f0101f1c:	68 bf 65 10 f0       	push   $0xf01065bf
f0101f21:	e8 1a e1 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101f26:	83 ec 04             	sub    $0x4,%esp
f0101f29:	6a 00                	push   $0x0
f0101f2b:	68 00 10 00 00       	push   $0x1000
f0101f30:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0101f36:	e8 16 f2 ff ff       	call   f0101151 <pgdir_walk>
f0101f3b:	83 c4 10             	add    $0x10,%esp
f0101f3e:	f6 00 04             	testb  $0x4,(%eax)
f0101f41:	74 19                	je     f0101f5c <mem_init+0xadb>
f0101f43:	68 dc 6d 10 f0       	push   $0xf0106ddc
f0101f48:	68 e5 65 10 f0       	push   $0xf01065e5
f0101f4d:	68 80 04 00 00       	push   $0x480
f0101f52:	68 bf 65 10 f0       	push   $0xf01065bf
f0101f57:	e8 e4 e0 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101f5c:	6a 02                	push   $0x2
f0101f5e:	68 00 00 40 00       	push   $0x400000
f0101f63:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101f66:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0101f6c:	e8 20 f4 ff ff       	call   f0101391 <page_insert>
f0101f71:	83 c4 10             	add    $0x10,%esp
f0101f74:	85 c0                	test   %eax,%eax
f0101f76:	78 19                	js     f0101f91 <mem_init+0xb10>
f0101f78:	68 14 6e 10 f0       	push   $0xf0106e14
f0101f7d:	68 e5 65 10 f0       	push   $0xf01065e5
f0101f82:	68 83 04 00 00       	push   $0x483
f0101f87:	68 bf 65 10 f0       	push   $0xf01065bf
f0101f8c:	e8 af e0 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101f91:	6a 02                	push   $0x2
f0101f93:	68 00 10 00 00       	push   $0x1000
f0101f98:	53                   	push   %ebx
f0101f99:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0101f9f:	e8 ed f3 ff ff       	call   f0101391 <page_insert>
f0101fa4:	83 c4 10             	add    $0x10,%esp
f0101fa7:	85 c0                	test   %eax,%eax
f0101fa9:	74 19                	je     f0101fc4 <mem_init+0xb43>
f0101fab:	68 4c 6e 10 f0       	push   $0xf0106e4c
f0101fb0:	68 e5 65 10 f0       	push   $0xf01065e5
f0101fb5:	68 86 04 00 00       	push   $0x486
f0101fba:	68 bf 65 10 f0       	push   $0xf01065bf
f0101fbf:	e8 7c e0 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101fc4:	83 ec 04             	sub    $0x4,%esp
f0101fc7:	6a 00                	push   $0x0
f0101fc9:	68 00 10 00 00       	push   $0x1000
f0101fce:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0101fd4:	e8 78 f1 ff ff       	call   f0101151 <pgdir_walk>
f0101fd9:	83 c4 10             	add    $0x10,%esp
f0101fdc:	f6 00 04             	testb  $0x4,(%eax)
f0101fdf:	74 19                	je     f0101ffa <mem_init+0xb79>
f0101fe1:	68 dc 6d 10 f0       	push   $0xf0106ddc
f0101fe6:	68 e5 65 10 f0       	push   $0xf01065e5
f0101feb:	68 87 04 00 00       	push   $0x487
f0101ff0:	68 bf 65 10 f0       	push   $0xf01065bf
f0101ff5:	e8 46 e0 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101ffa:	8b 3d 8c be 22 f0    	mov    0xf022be8c,%edi
f0102000:	ba 00 00 00 00       	mov    $0x0,%edx
f0102005:	89 f8                	mov    %edi,%eax
f0102007:	e8 2a eb ff ff       	call   f0100b36 <check_va2pa>
f010200c:	89 c1                	mov    %eax,%ecx
f010200e:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102011:	89 d8                	mov    %ebx,%eax
f0102013:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0102019:	c1 f8 03             	sar    $0x3,%eax
f010201c:	c1 e0 0c             	shl    $0xc,%eax
f010201f:	39 c1                	cmp    %eax,%ecx
f0102021:	74 19                	je     f010203c <mem_init+0xbbb>
f0102023:	68 88 6e 10 f0       	push   $0xf0106e88
f0102028:	68 e5 65 10 f0       	push   $0xf01065e5
f010202d:	68 8a 04 00 00       	push   $0x48a
f0102032:	68 bf 65 10 f0       	push   $0xf01065bf
f0102037:	e8 04 e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010203c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102041:	89 f8                	mov    %edi,%eax
f0102043:	e8 ee ea ff ff       	call   f0100b36 <check_va2pa>
f0102048:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f010204b:	74 19                	je     f0102066 <mem_init+0xbe5>
f010204d:	68 b4 6e 10 f0       	push   $0xf0106eb4
f0102052:	68 e5 65 10 f0       	push   $0xf01065e5
f0102057:	68 8b 04 00 00       	push   $0x48b
f010205c:	68 bf 65 10 f0       	push   $0xf01065bf
f0102061:	e8 da df ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102066:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f010206b:	74 19                	je     f0102086 <mem_init+0xc05>
f010206d:	68 14 68 10 f0       	push   $0xf0106814
f0102072:	68 e5 65 10 f0       	push   $0xf01065e5
f0102077:	68 8d 04 00 00       	push   $0x48d
f010207c:	68 bf 65 10 f0       	push   $0xf01065bf
f0102081:	e8 ba df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102086:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010208b:	74 19                	je     f01020a6 <mem_init+0xc25>
f010208d:	68 25 68 10 f0       	push   $0xf0106825
f0102092:	68 e5 65 10 f0       	push   $0xf01065e5
f0102097:	68 8e 04 00 00       	push   $0x48e
f010209c:	68 bf 65 10 f0       	push   $0xf01065bf
f01020a1:	e8 9a df ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01020a6:	83 ec 0c             	sub    $0xc,%esp
f01020a9:	6a 00                	push   $0x0
f01020ab:	e8 b3 ef ff ff       	call   f0101063 <page_alloc>
f01020b0:	83 c4 10             	add    $0x10,%esp
f01020b3:	85 c0                	test   %eax,%eax
f01020b5:	74 04                	je     f01020bb <mem_init+0xc3a>
f01020b7:	39 c6                	cmp    %eax,%esi
f01020b9:	74 19                	je     f01020d4 <mem_init+0xc53>
f01020bb:	68 e4 6e 10 f0       	push   $0xf0106ee4
f01020c0:	68 e5 65 10 f0       	push   $0xf01065e5
f01020c5:	68 91 04 00 00       	push   $0x491
f01020ca:	68 bf 65 10 f0       	push   $0xf01065bf
f01020cf:	e8 6c df ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01020d4:	83 ec 08             	sub    $0x8,%esp
f01020d7:	6a 00                	push   $0x0
f01020d9:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f01020df:	e8 60 f2 ff ff       	call   f0101344 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01020e4:	8b 3d 8c be 22 f0    	mov    0xf022be8c,%edi
f01020ea:	ba 00 00 00 00       	mov    $0x0,%edx
f01020ef:	89 f8                	mov    %edi,%eax
f01020f1:	e8 40 ea ff ff       	call   f0100b36 <check_va2pa>
f01020f6:	83 c4 10             	add    $0x10,%esp
f01020f9:	83 f8 ff             	cmp    $0xffffffff,%eax
f01020fc:	74 19                	je     f0102117 <mem_init+0xc96>
f01020fe:	68 08 6f 10 f0       	push   $0xf0106f08
f0102103:	68 e5 65 10 f0       	push   $0xf01065e5
f0102108:	68 95 04 00 00       	push   $0x495
f010210d:	68 bf 65 10 f0       	push   $0xf01065bf
f0102112:	e8 29 df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102117:	ba 00 10 00 00       	mov    $0x1000,%edx
f010211c:	89 f8                	mov    %edi,%eax
f010211e:	e8 13 ea ff ff       	call   f0100b36 <check_va2pa>
f0102123:	89 da                	mov    %ebx,%edx
f0102125:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f010212b:	c1 fa 03             	sar    $0x3,%edx
f010212e:	c1 e2 0c             	shl    $0xc,%edx
f0102131:	39 d0                	cmp    %edx,%eax
f0102133:	74 19                	je     f010214e <mem_init+0xccd>
f0102135:	68 b4 6e 10 f0       	push   $0xf0106eb4
f010213a:	68 e5 65 10 f0       	push   $0xf01065e5
f010213f:	68 96 04 00 00       	push   $0x496
f0102144:	68 bf 65 10 f0       	push   $0xf01065bf
f0102149:	e8 f2 de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f010214e:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102153:	74 19                	je     f010216e <mem_init+0xced>
f0102155:	68 cb 67 10 f0       	push   $0xf01067cb
f010215a:	68 e5 65 10 f0       	push   $0xf01065e5
f010215f:	68 97 04 00 00       	push   $0x497
f0102164:	68 bf 65 10 f0       	push   $0xf01065bf
f0102169:	e8 d2 de ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010216e:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102173:	74 19                	je     f010218e <mem_init+0xd0d>
f0102175:	68 25 68 10 f0       	push   $0xf0106825
f010217a:	68 e5 65 10 f0       	push   $0xf01065e5
f010217f:	68 98 04 00 00       	push   $0x498
f0102184:	68 bf 65 10 f0       	push   $0xf01065bf
f0102189:	e8 b2 de ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f010218e:	6a 00                	push   $0x0
f0102190:	68 00 10 00 00       	push   $0x1000
f0102195:	53                   	push   %ebx
f0102196:	57                   	push   %edi
f0102197:	e8 f5 f1 ff ff       	call   f0101391 <page_insert>
f010219c:	83 c4 10             	add    $0x10,%esp
f010219f:	85 c0                	test   %eax,%eax
f01021a1:	74 19                	je     f01021bc <mem_init+0xd3b>
f01021a3:	68 2c 6f 10 f0       	push   $0xf0106f2c
f01021a8:	68 e5 65 10 f0       	push   $0xf01065e5
f01021ad:	68 9b 04 00 00       	push   $0x49b
f01021b2:	68 bf 65 10 f0       	push   $0xf01065bf
f01021b7:	e8 84 de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f01021bc:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01021c1:	75 19                	jne    f01021dc <mem_init+0xd5b>
f01021c3:	68 36 68 10 f0       	push   $0xf0106836
f01021c8:	68 e5 65 10 f0       	push   $0xf01065e5
f01021cd:	68 9c 04 00 00       	push   $0x49c
f01021d2:	68 bf 65 10 f0       	push   $0xf01065bf
f01021d7:	e8 64 de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f01021dc:	83 3b 00             	cmpl   $0x0,(%ebx)
f01021df:	74 19                	je     f01021fa <mem_init+0xd79>
f01021e1:	68 42 68 10 f0       	push   $0xf0106842
f01021e6:	68 e5 65 10 f0       	push   $0xf01065e5
f01021eb:	68 9d 04 00 00       	push   $0x49d
f01021f0:	68 bf 65 10 f0       	push   $0xf01065bf
f01021f5:	e8 46 de ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01021fa:	83 ec 08             	sub    $0x8,%esp
f01021fd:	68 00 10 00 00       	push   $0x1000
f0102202:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0102208:	e8 37 f1 ff ff       	call   f0101344 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010220d:	8b 3d 8c be 22 f0    	mov    0xf022be8c,%edi
f0102213:	ba 00 00 00 00       	mov    $0x0,%edx
f0102218:	89 f8                	mov    %edi,%eax
f010221a:	e8 17 e9 ff ff       	call   f0100b36 <check_va2pa>
f010221f:	83 c4 10             	add    $0x10,%esp
f0102222:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102225:	74 19                	je     f0102240 <mem_init+0xdbf>
f0102227:	68 08 6f 10 f0       	push   $0xf0106f08
f010222c:	68 e5 65 10 f0       	push   $0xf01065e5
f0102231:	68 a1 04 00 00       	push   $0x4a1
f0102236:	68 bf 65 10 f0       	push   $0xf01065bf
f010223b:	e8 00 de ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102240:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102245:	89 f8                	mov    %edi,%eax
f0102247:	e8 ea e8 ff ff       	call   f0100b36 <check_va2pa>
f010224c:	83 f8 ff             	cmp    $0xffffffff,%eax
f010224f:	74 19                	je     f010226a <mem_init+0xde9>
f0102251:	68 64 6f 10 f0       	push   $0xf0106f64
f0102256:	68 e5 65 10 f0       	push   $0xf01065e5
f010225b:	68 a2 04 00 00       	push   $0x4a2
f0102260:	68 bf 65 10 f0       	push   $0xf01065bf
f0102265:	e8 d6 dd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f010226a:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010226f:	74 19                	je     f010228a <mem_init+0xe09>
f0102271:	68 57 68 10 f0       	push   $0xf0106857
f0102276:	68 e5 65 10 f0       	push   $0xf01065e5
f010227b:	68 a3 04 00 00       	push   $0x4a3
f0102280:	68 bf 65 10 f0       	push   $0xf01065bf
f0102285:	e8 b6 dd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010228a:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010228f:	74 19                	je     f01022aa <mem_init+0xe29>
f0102291:	68 25 68 10 f0       	push   $0xf0106825
f0102296:	68 e5 65 10 f0       	push   $0xf01065e5
f010229b:	68 a4 04 00 00       	push   $0x4a4
f01022a0:	68 bf 65 10 f0       	push   $0xf01065bf
f01022a5:	e8 96 dd ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01022aa:	83 ec 0c             	sub    $0xc,%esp
f01022ad:	6a 00                	push   $0x0
f01022af:	e8 af ed ff ff       	call   f0101063 <page_alloc>
f01022b4:	83 c4 10             	add    $0x10,%esp
f01022b7:	39 c3                	cmp    %eax,%ebx
f01022b9:	75 04                	jne    f01022bf <mem_init+0xe3e>
f01022bb:	85 c0                	test   %eax,%eax
f01022bd:	75 19                	jne    f01022d8 <mem_init+0xe57>
f01022bf:	68 8c 6f 10 f0       	push   $0xf0106f8c
f01022c4:	68 e5 65 10 f0       	push   $0xf01065e5
f01022c9:	68 a7 04 00 00       	push   $0x4a7
f01022ce:	68 bf 65 10 f0       	push   $0xf01065bf
f01022d3:	e8 68 dd ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01022d8:	83 ec 0c             	sub    $0xc,%esp
f01022db:	6a 00                	push   $0x0
f01022dd:	e8 81 ed ff ff       	call   f0101063 <page_alloc>
f01022e2:	83 c4 10             	add    $0x10,%esp
f01022e5:	85 c0                	test   %eax,%eax
f01022e7:	74 19                	je     f0102302 <mem_init+0xe81>
f01022e9:	68 79 67 10 f0       	push   $0xf0106779
f01022ee:	68 e5 65 10 f0       	push   $0xf01065e5
f01022f3:	68 aa 04 00 00       	push   $0x4aa
f01022f8:	68 bf 65 10 f0       	push   $0xf01065bf
f01022fd:	e8 3e dd ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102302:	8b 0d 8c be 22 f0    	mov    0xf022be8c,%ecx
f0102308:	8b 11                	mov    (%ecx),%edx
f010230a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102310:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102313:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0102319:	c1 f8 03             	sar    $0x3,%eax
f010231c:	c1 e0 0c             	shl    $0xc,%eax
f010231f:	39 c2                	cmp    %eax,%edx
f0102321:	74 19                	je     f010233c <mem_init+0xebb>
f0102323:	68 30 6c 10 f0       	push   $0xf0106c30
f0102328:	68 e5 65 10 f0       	push   $0xf01065e5
f010232d:	68 ad 04 00 00       	push   $0x4ad
f0102332:	68 bf 65 10 f0       	push   $0xf01065bf
f0102337:	e8 04 dd ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f010233c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102342:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102345:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010234a:	74 19                	je     f0102365 <mem_init+0xee4>
f010234c:	68 dc 67 10 f0       	push   $0xf01067dc
f0102351:	68 e5 65 10 f0       	push   $0xf01065e5
f0102356:	68 af 04 00 00       	push   $0x4af
f010235b:	68 bf 65 10 f0       	push   $0xf01065bf
f0102360:	e8 db dc ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102365:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102368:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f010236e:	83 ec 0c             	sub    $0xc,%esp
f0102371:	50                   	push   %eax
f0102372:	e8 5d ed ff ff       	call   f01010d4 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102377:	83 c4 0c             	add    $0xc,%esp
f010237a:	6a 01                	push   $0x1
f010237c:	68 00 10 40 00       	push   $0x401000
f0102381:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0102387:	e8 c5 ed ff ff       	call   f0101151 <pgdir_walk>
f010238c:	89 c7                	mov    %eax,%edi
f010238e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102391:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102396:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102399:	8b 40 04             	mov    0x4(%eax),%eax
f010239c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01023a1:	8b 0d 88 be 22 f0    	mov    0xf022be88,%ecx
f01023a7:	89 c2                	mov    %eax,%edx
f01023a9:	c1 ea 0c             	shr    $0xc,%edx
f01023ac:	83 c4 10             	add    $0x10,%esp
f01023af:	39 ca                	cmp    %ecx,%edx
f01023b1:	72 15                	jb     f01023c8 <mem_init+0xf47>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01023b3:	50                   	push   %eax
f01023b4:	68 04 60 10 f0       	push   $0xf0106004
f01023b9:	68 b6 04 00 00       	push   $0x4b6
f01023be:	68 bf 65 10 f0       	push   $0xf01065bf
f01023c3:	e8 78 dc ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01023c8:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f01023cd:	39 c7                	cmp    %eax,%edi
f01023cf:	74 19                	je     f01023ea <mem_init+0xf69>
f01023d1:	68 68 68 10 f0       	push   $0xf0106868
f01023d6:	68 e5 65 10 f0       	push   $0xf01065e5
f01023db:	68 b7 04 00 00       	push   $0x4b7
f01023e0:	68 bf 65 10 f0       	push   $0xf01065bf
f01023e5:	e8 56 dc ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f01023ea:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01023ed:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f01023f4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01023f7:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01023fd:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0102403:	c1 f8 03             	sar    $0x3,%eax
f0102406:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102409:	89 c2                	mov    %eax,%edx
f010240b:	c1 ea 0c             	shr    $0xc,%edx
f010240e:	39 d1                	cmp    %edx,%ecx
f0102410:	77 12                	ja     f0102424 <mem_init+0xfa3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102412:	50                   	push   %eax
f0102413:	68 04 60 10 f0       	push   $0xf0106004
f0102418:	6a 58                	push   $0x58
f010241a:	68 cb 65 10 f0       	push   $0xf01065cb
f010241f:	e8 1c dc ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102424:	83 ec 04             	sub    $0x4,%esp
f0102427:	68 00 10 00 00       	push   $0x1000
f010242c:	68 ff 00 00 00       	push   $0xff
f0102431:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102436:	50                   	push   %eax
f0102437:	e8 e8 2e 00 00       	call   f0105324 <memset>
	page_free(pp0);
f010243c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010243f:	89 3c 24             	mov    %edi,(%esp)
f0102442:	e8 8d ec ff ff       	call   f01010d4 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102447:	83 c4 0c             	add    $0xc,%esp
f010244a:	6a 01                	push   $0x1
f010244c:	6a 00                	push   $0x0
f010244e:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0102454:	e8 f8 ec ff ff       	call   f0101151 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102459:	89 fa                	mov    %edi,%edx
f010245b:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0102461:	c1 fa 03             	sar    $0x3,%edx
f0102464:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102467:	89 d0                	mov    %edx,%eax
f0102469:	c1 e8 0c             	shr    $0xc,%eax
f010246c:	83 c4 10             	add    $0x10,%esp
f010246f:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f0102475:	72 12                	jb     f0102489 <mem_init+0x1008>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102477:	52                   	push   %edx
f0102478:	68 04 60 10 f0       	push   $0xf0106004
f010247d:	6a 58                	push   $0x58
f010247f:	68 cb 65 10 f0       	push   $0xf01065cb
f0102484:	e8 b7 db ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102489:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f010248f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102492:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102498:	f6 00 01             	testb  $0x1,(%eax)
f010249b:	74 19                	je     f01024b6 <mem_init+0x1035>
f010249d:	68 80 68 10 f0       	push   $0xf0106880
f01024a2:	68 e5 65 10 f0       	push   $0xf01065e5
f01024a7:	68 c1 04 00 00       	push   $0x4c1
f01024ac:	68 bf 65 10 f0       	push   $0xf01065bf
f01024b1:	e8 8a db ff ff       	call   f0100040 <_panic>
f01024b6:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01024b9:	39 d0                	cmp    %edx,%eax
f01024bb:	75 db                	jne    f0102498 <mem_init+0x1017>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01024bd:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01024c2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01024c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01024cb:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f01024d1:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01024d4:	89 0d 40 b2 22 f0    	mov    %ecx,0xf022b240

	// free the pages we took
	page_free(pp0);
f01024da:	83 ec 0c             	sub    $0xc,%esp
f01024dd:	50                   	push   %eax
f01024de:	e8 f1 eb ff ff       	call   f01010d4 <page_free>
	page_free(pp1);
f01024e3:	89 1c 24             	mov    %ebx,(%esp)
f01024e6:	e8 e9 eb ff ff       	call   f01010d4 <page_free>
	page_free(pp2);
f01024eb:	89 34 24             	mov    %esi,(%esp)
f01024ee:	e8 e1 eb ff ff       	call   f01010d4 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f01024f3:	83 c4 08             	add    $0x8,%esp
f01024f6:	68 01 10 00 00       	push   $0x1001
f01024fb:	6a 00                	push   $0x0
f01024fd:	e8 16 ef ff ff       	call   f0101418 <mmio_map_region>
f0102502:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102504:	83 c4 08             	add    $0x8,%esp
f0102507:	68 00 10 00 00       	push   $0x1000
f010250c:	6a 00                	push   $0x0
f010250e:	e8 05 ef ff ff       	call   f0101418 <mmio_map_region>
f0102513:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f0102515:	8d 83 00 20 00 00    	lea    0x2000(%ebx),%eax
f010251b:	83 c4 10             	add    $0x10,%esp
f010251e:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102524:	76 07                	jbe    f010252d <mem_init+0x10ac>
f0102526:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f010252b:	76 19                	jbe    f0102546 <mem_init+0x10c5>
f010252d:	68 b0 6f 10 f0       	push   $0xf0106fb0
f0102532:	68 e5 65 10 f0       	push   $0xf01065e5
f0102537:	68 d1 04 00 00       	push   $0x4d1
f010253c:	68 bf 65 10 f0       	push   $0xf01065bf
f0102541:	e8 fa da ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f0102546:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
f010254c:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102552:	77 08                	ja     f010255c <mem_init+0x10db>
f0102554:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010255a:	77 19                	ja     f0102575 <mem_init+0x10f4>
f010255c:	68 d8 6f 10 f0       	push   $0xf0106fd8
f0102561:	68 e5 65 10 f0       	push   $0xf01065e5
f0102566:	68 d2 04 00 00       	push   $0x4d2
f010256b:	68 bf 65 10 f0       	push   $0xf01065bf
f0102570:	e8 cb da ff ff       	call   f0100040 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102575:	89 da                	mov    %ebx,%edx
f0102577:	09 f2                	or     %esi,%edx
f0102579:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f010257f:	74 19                	je     f010259a <mem_init+0x1119>
f0102581:	68 00 70 10 f0       	push   $0xf0107000
f0102586:	68 e5 65 10 f0       	push   $0xf01065e5
f010258b:	68 d4 04 00 00       	push   $0x4d4
f0102590:	68 bf 65 10 f0       	push   $0xf01065bf
f0102595:	e8 a6 da ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8192 <= mm2);
f010259a:	39 c6                	cmp    %eax,%esi
f010259c:	73 19                	jae    f01025b7 <mem_init+0x1136>
f010259e:	68 97 68 10 f0       	push   $0xf0106897
f01025a3:	68 e5 65 10 f0       	push   $0xf01065e5
f01025a8:	68 d6 04 00 00       	push   $0x4d6
f01025ad:	68 bf 65 10 f0       	push   $0xf01065bf
f01025b2:	e8 89 da ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01025b7:	8b 3d 8c be 22 f0    	mov    0xf022be8c,%edi
f01025bd:	89 da                	mov    %ebx,%edx
f01025bf:	89 f8                	mov    %edi,%eax
f01025c1:	e8 70 e5 ff ff       	call   f0100b36 <check_va2pa>
f01025c6:	85 c0                	test   %eax,%eax
f01025c8:	74 19                	je     f01025e3 <mem_init+0x1162>
f01025ca:	68 28 70 10 f0       	push   $0xf0107028
f01025cf:	68 e5 65 10 f0       	push   $0xf01065e5
f01025d4:	68 d8 04 00 00       	push   $0x4d8
f01025d9:	68 bf 65 10 f0       	push   $0xf01065bf
f01025de:	e8 5d da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01025e3:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f01025e9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01025ec:	89 c2                	mov    %eax,%edx
f01025ee:	89 f8                	mov    %edi,%eax
f01025f0:	e8 41 e5 ff ff       	call   f0100b36 <check_va2pa>
f01025f5:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01025fa:	74 19                	je     f0102615 <mem_init+0x1194>
f01025fc:	68 4c 70 10 f0       	push   $0xf010704c
f0102601:	68 e5 65 10 f0       	push   $0xf01065e5
f0102606:	68 d9 04 00 00       	push   $0x4d9
f010260b:	68 bf 65 10 f0       	push   $0xf01065bf
f0102610:	e8 2b da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102615:	89 f2                	mov    %esi,%edx
f0102617:	89 f8                	mov    %edi,%eax
f0102619:	e8 18 e5 ff ff       	call   f0100b36 <check_va2pa>
f010261e:	85 c0                	test   %eax,%eax
f0102620:	74 19                	je     f010263b <mem_init+0x11ba>
f0102622:	68 7c 70 10 f0       	push   $0xf010707c
f0102627:	68 e5 65 10 f0       	push   $0xf01065e5
f010262c:	68 da 04 00 00       	push   $0x4da
f0102631:	68 bf 65 10 f0       	push   $0xf01065bf
f0102636:	e8 05 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f010263b:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102641:	89 f8                	mov    %edi,%eax
f0102643:	e8 ee e4 ff ff       	call   f0100b36 <check_va2pa>
f0102648:	83 f8 ff             	cmp    $0xffffffff,%eax
f010264b:	74 19                	je     f0102666 <mem_init+0x11e5>
f010264d:	68 a0 70 10 f0       	push   $0xf01070a0
f0102652:	68 e5 65 10 f0       	push   $0xf01065e5
f0102657:	68 db 04 00 00       	push   $0x4db
f010265c:	68 bf 65 10 f0       	push   $0xf01065bf
f0102661:	e8 da d9 ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102666:	83 ec 04             	sub    $0x4,%esp
f0102669:	6a 00                	push   $0x0
f010266b:	53                   	push   %ebx
f010266c:	57                   	push   %edi
f010266d:	e8 df ea ff ff       	call   f0101151 <pgdir_walk>
f0102672:	83 c4 10             	add    $0x10,%esp
f0102675:	f6 00 1a             	testb  $0x1a,(%eax)
f0102678:	75 19                	jne    f0102693 <mem_init+0x1212>
f010267a:	68 cc 70 10 f0       	push   $0xf01070cc
f010267f:	68 e5 65 10 f0       	push   $0xf01065e5
f0102684:	68 dd 04 00 00       	push   $0x4dd
f0102689:	68 bf 65 10 f0       	push   $0xf01065bf
f010268e:	e8 ad d9 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102693:	83 ec 04             	sub    $0x4,%esp
f0102696:	6a 00                	push   $0x0
f0102698:	53                   	push   %ebx
f0102699:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f010269f:	e8 ad ea ff ff       	call   f0101151 <pgdir_walk>
f01026a4:	8b 00                	mov    (%eax),%eax
f01026a6:	83 c4 10             	add    $0x10,%esp
f01026a9:	83 e0 04             	and    $0x4,%eax
f01026ac:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01026af:	74 19                	je     f01026ca <mem_init+0x1249>
f01026b1:	68 10 71 10 f0       	push   $0xf0107110
f01026b6:	68 e5 65 10 f0       	push   $0xf01065e5
f01026bb:	68 de 04 00 00       	push   $0x4de
f01026c0:	68 bf 65 10 f0       	push   $0xf01065bf
f01026c5:	e8 76 d9 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f01026ca:	83 ec 04             	sub    $0x4,%esp
f01026cd:	6a 00                	push   $0x0
f01026cf:	53                   	push   %ebx
f01026d0:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f01026d6:	e8 76 ea ff ff       	call   f0101151 <pgdir_walk>
f01026db:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f01026e1:	83 c4 0c             	add    $0xc,%esp
f01026e4:	6a 00                	push   $0x0
f01026e6:	ff 75 d4             	pushl  -0x2c(%ebp)
f01026e9:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f01026ef:	e8 5d ea ff ff       	call   f0101151 <pgdir_walk>
f01026f4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f01026fa:	83 c4 0c             	add    $0xc,%esp
f01026fd:	6a 00                	push   $0x0
f01026ff:	56                   	push   %esi
f0102700:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0102706:	e8 46 ea ff ff       	call   f0101151 <pgdir_walk>
f010270b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102711:	c7 04 24 a9 68 10 f0 	movl   $0xf01068a9,(%esp)
f0102718:	e8 84 11 00 00       	call   f01038a1 <cprintf>
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f010271d:	a1 90 be 22 f0       	mov    0xf022be90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102722:	83 c4 10             	add    $0x10,%esp
f0102725:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010272a:	77 15                	ja     f0102741 <mem_init+0x12c0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010272c:	50                   	push   %eax
f010272d:	68 28 60 10 f0       	push   $0xf0106028
f0102732:	68 c8 00 00 00       	push   $0xc8
f0102737:	68 bf 65 10 f0       	push   $0xf01065bf
f010273c:	e8 ff d8 ff ff       	call   f0100040 <_panic>
f0102741:	83 ec 08             	sub    $0x8,%esp
f0102744:	6a 04                	push   $0x4
f0102746:	05 00 00 00 10       	add    $0x10000000,%eax
f010274b:	50                   	push   %eax
f010274c:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102751:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102756:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f010275b:	e8 87 ea ff ff       	call   f01011e7 <boot_map_region>
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.

	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U);
f0102760:	a1 48 b2 22 f0       	mov    0xf022b248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102765:	83 c4 10             	add    $0x10,%esp
f0102768:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010276d:	77 15                	ja     f0102784 <mem_init+0x1303>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010276f:	50                   	push   %eax
f0102770:	68 28 60 10 f0       	push   $0xf0106028
f0102775:	68 d2 00 00 00       	push   $0xd2
f010277a:	68 bf 65 10 f0       	push   $0xf01065bf
f010277f:	e8 bc d8 ff ff       	call   f0100040 <_panic>
f0102784:	83 ec 08             	sub    $0x8,%esp
f0102787:	6a 04                	push   $0x4
f0102789:	05 00 00 00 10       	add    $0x10000000,%eax
f010278e:	50                   	push   %eax
f010278f:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102794:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102799:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f010279e:	e8 44 ea ff ff       	call   f01011e7 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027a3:	83 c4 10             	add    $0x10,%esp
f01027a6:	b8 00 60 11 f0       	mov    $0xf0116000,%eax
f01027ab:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01027b0:	77 15                	ja     f01027c7 <mem_init+0x1346>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027b2:	50                   	push   %eax
f01027b3:	68 28 60 10 f0       	push   $0xf0106028
f01027b8:	68 e0 00 00 00       	push   $0xe0
f01027bd:	68 bf 65 10 f0       	push   $0xf01065bf
f01027c2:	e8 79 d8 ff ff       	call   f0100040 <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f01027c7:	83 ec 08             	sub    $0x8,%esp
f01027ca:	6a 02                	push   $0x2
f01027cc:	68 00 60 11 00       	push   $0x116000
f01027d1:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01027d6:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01027db:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01027e0:	e8 02 ea ff ff       	call   f01011e7 <boot_map_region>
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, KERNBASE, ROUNDUP(~0 - KERNBASE, PGSIZE), 0, PTE_W);
f01027e5:	83 c4 08             	add    $0x8,%esp
f01027e8:	6a 02                	push   $0x2
f01027ea:	6a 00                	push   $0x0
f01027ec:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01027f1:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01027f6:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01027fb:	e8 e7 e9 ff ff       	call   f01011e7 <boot_map_region>
f0102800:	c7 45 c4 00 d0 22 f0 	movl   $0xf022d000,-0x3c(%ebp)
f0102807:	83 c4 10             	add    $0x10,%esp
f010280a:	bb 00 d0 22 f0       	mov    $0xf022d000,%ebx
f010280f:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102814:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f010281a:	77 15                	ja     f0102831 <mem_init+0x13b0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010281c:	53                   	push   %ebx
f010281d:	68 28 60 10 f0       	push   $0xf0106028
f0102822:	68 24 01 00 00       	push   $0x124
f0102827:	68 bf 65 10 f0       	push   $0xf01065bf
f010282c:	e8 0f d8 ff ff       	call   f0100040 <_panic>

	uint32_t kstacktop_i;

	for (int i=0; i<NCPU; i++) {
		kstacktop_i = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
		boot_map_region(kern_pgdir, kstacktop_i - KSTKSIZE, KSTKSIZE, PADDR(&percpu_kstacks[i]), PTE_W );
f0102831:	83 ec 08             	sub    $0x8,%esp
f0102834:	6a 02                	push   $0x2
f0102836:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f010283c:	50                   	push   %eax
f010283d:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102842:	89 f2                	mov    %esi,%edx
f0102844:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102849:	e8 99 e9 ff ff       	call   f01011e7 <boot_map_region>
f010284e:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102854:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//
	// LAB 4: Your code here:

	uint32_t kstacktop_i;

	for (int i=0; i<NCPU; i++) {
f010285a:	83 c4 10             	add    $0x10,%esp
f010285d:	b8 00 d0 26 f0       	mov    $0xf026d000,%eax
f0102862:	39 d8                	cmp    %ebx,%eax
f0102864:	75 ae                	jne    f0102814 <mem_init+0x1393>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102866:	8b 3d 8c be 22 f0    	mov    0xf022be8c,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010286c:	a1 88 be 22 f0       	mov    0xf022be88,%eax
f0102871:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102874:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f010287b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102880:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102883:	8b 35 90 be 22 f0    	mov    0xf022be90,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102889:	89 75 d0             	mov    %esi,-0x30(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010288c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102891:	eb 55                	jmp    f01028e8 <mem_init+0x1467>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102893:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102899:	89 f8                	mov    %edi,%eax
f010289b:	e8 96 e2 ff ff       	call   f0100b36 <check_va2pa>
f01028a0:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f01028a7:	77 15                	ja     f01028be <mem_init+0x143d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01028a9:	56                   	push   %esi
f01028aa:	68 28 60 10 f0       	push   $0xf0106028
f01028af:	68 f2 03 00 00       	push   $0x3f2
f01028b4:	68 bf 65 10 f0       	push   $0xf01065bf
f01028b9:	e8 82 d7 ff ff       	call   f0100040 <_panic>
f01028be:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f01028c5:	39 c2                	cmp    %eax,%edx
f01028c7:	74 19                	je     f01028e2 <mem_init+0x1461>
f01028c9:	68 44 71 10 f0       	push   $0xf0107144
f01028ce:	68 e5 65 10 f0       	push   $0xf01065e5
f01028d3:	68 f2 03 00 00       	push   $0x3f2
f01028d8:	68 bf 65 10 f0       	push   $0xf01065bf
f01028dd:	e8 5e d7 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01028e2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01028e8:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01028eb:	77 a6                	ja     f0102893 <mem_init+0x1412>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01028ed:	8b 35 48 b2 22 f0    	mov    0xf022b248,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01028f3:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f01028f6:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f01028fb:	89 da                	mov    %ebx,%edx
f01028fd:	89 f8                	mov    %edi,%eax
f01028ff:	e8 32 e2 ff ff       	call   f0100b36 <check_va2pa>
f0102904:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f010290b:	77 15                	ja     f0102922 <mem_init+0x14a1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010290d:	56                   	push   %esi
f010290e:	68 28 60 10 f0       	push   $0xf0106028
f0102913:	68 f7 03 00 00       	push   $0x3f7
f0102918:	68 bf 65 10 f0       	push   $0xf01065bf
f010291d:	e8 1e d7 ff ff       	call   f0100040 <_panic>
f0102922:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f0102929:	39 d0                	cmp    %edx,%eax
f010292b:	74 19                	je     f0102946 <mem_init+0x14c5>
f010292d:	68 78 71 10 f0       	push   $0xf0107178
f0102932:	68 e5 65 10 f0       	push   $0xf01065e5
f0102937:	68 f7 03 00 00       	push   $0x3f7
f010293c:	68 bf 65 10 f0       	push   $0xf01065bf
f0102941:	e8 fa d6 ff ff       	call   f0100040 <_panic>
f0102946:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010294c:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102952:	75 a7                	jne    f01028fb <mem_init+0x147a>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102954:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0102957:	c1 e6 0c             	shl    $0xc,%esi
f010295a:	bb 00 00 00 00       	mov    $0x0,%ebx
f010295f:	eb 30                	jmp    f0102991 <mem_init+0x1510>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102961:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102967:	89 f8                	mov    %edi,%eax
f0102969:	e8 c8 e1 ff ff       	call   f0100b36 <check_va2pa>
f010296e:	39 c3                	cmp    %eax,%ebx
f0102970:	74 19                	je     f010298b <mem_init+0x150a>
f0102972:	68 ac 71 10 f0       	push   $0xf01071ac
f0102977:	68 e5 65 10 f0       	push   $0xf01065e5
f010297c:	68 fb 03 00 00       	push   $0x3fb
f0102981:	68 bf 65 10 f0       	push   $0xf01065bf
f0102986:	e8 b5 d6 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010298b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102991:	39 f3                	cmp    %esi,%ebx
f0102993:	72 cc                	jb     f0102961 <mem_init+0x14e0>
f0102995:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f010299a:	89 75 cc             	mov    %esi,-0x34(%ebp)
f010299d:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01029a0:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01029a3:	8d 88 00 80 00 00    	lea    0x8000(%eax),%ecx
f01029a9:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f01029ac:	89 c3                	mov    %eax,%ebx
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f01029ae:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01029b1:	05 00 80 00 20       	add    $0x20008000,%eax
f01029b6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01029b9:	89 da                	mov    %ebx,%edx
f01029bb:	89 f8                	mov    %edi,%eax
f01029bd:	e8 74 e1 ff ff       	call   f0100b36 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01029c2:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f01029c8:	77 15                	ja     f01029df <mem_init+0x155e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029ca:	56                   	push   %esi
f01029cb:	68 28 60 10 f0       	push   $0xf0106028
f01029d0:	68 03 04 00 00       	push   $0x403
f01029d5:	68 bf 65 10 f0       	push   $0xf01065bf
f01029da:	e8 61 d6 ff ff       	call   f0100040 <_panic>
f01029df:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01029e2:	8d 94 0b 00 d0 22 f0 	lea    -0xfdd3000(%ebx,%ecx,1),%edx
f01029e9:	39 d0                	cmp    %edx,%eax
f01029eb:	74 19                	je     f0102a06 <mem_init+0x1585>
f01029ed:	68 d4 71 10 f0       	push   $0xf01071d4
f01029f2:	68 e5 65 10 f0       	push   $0xf01065e5
f01029f7:	68 03 04 00 00       	push   $0x403
f01029fc:	68 bf 65 10 f0       	push   $0xf01065bf
f0102a01:	e8 3a d6 ff ff       	call   f0100040 <_panic>
f0102a06:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102a0c:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f0102a0f:	75 a8                	jne    f01029b9 <mem_init+0x1538>
f0102a11:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102a14:	8d 98 00 80 ff ff    	lea    -0x8000(%eax),%ebx
f0102a1a:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102a1d:	89 c6                	mov    %eax,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102a1f:	89 da                	mov    %ebx,%edx
f0102a21:	89 f8                	mov    %edi,%eax
f0102a23:	e8 0e e1 ff ff       	call   f0100b36 <check_va2pa>
f0102a28:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a2b:	74 19                	je     f0102a46 <mem_init+0x15c5>
f0102a2d:	68 1c 72 10 f0       	push   $0xf010721c
f0102a32:	68 e5 65 10 f0       	push   $0xf01065e5
f0102a37:	68 05 04 00 00       	push   $0x405
f0102a3c:	68 bf 65 10 f0       	push   $0xf01065bf
f0102a41:	e8 fa d5 ff ff       	call   f0100040 <_panic>
f0102a46:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102a4c:	39 f3                	cmp    %esi,%ebx
f0102a4e:	75 cf                	jne    f0102a1f <mem_init+0x159e>
f0102a50:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102a53:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f0102a5a:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f0102a61:	81 c6 00 80 00 00    	add    $0x8000,%esi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102a67:	b8 00 d0 26 f0       	mov    $0xf026d000,%eax
f0102a6c:	39 f0                	cmp    %esi,%eax
f0102a6e:	0f 85 2c ff ff ff    	jne    f01029a0 <mem_init+0x151f>
f0102a74:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a79:	eb 2a                	jmp    f0102aa5 <mem_init+0x1624>
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102a7b:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102a81:	83 fa 04             	cmp    $0x4,%edx
f0102a84:	77 1f                	ja     f0102aa5 <mem_init+0x1624>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f0102a86:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102a8a:	75 7e                	jne    f0102b0a <mem_init+0x1689>
f0102a8c:	68 c2 68 10 f0       	push   $0xf01068c2
f0102a91:	68 e5 65 10 f0       	push   $0xf01065e5
f0102a96:	68 10 04 00 00       	push   $0x410
f0102a9b:	68 bf 65 10 f0       	push   $0xf01065bf
f0102aa0:	e8 9b d5 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102aa5:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102aaa:	76 3f                	jbe    f0102aeb <mem_init+0x166a>
				assert(pgdir[i] & PTE_P);
f0102aac:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102aaf:	f6 c2 01             	test   $0x1,%dl
f0102ab2:	75 19                	jne    f0102acd <mem_init+0x164c>
f0102ab4:	68 c2 68 10 f0       	push   $0xf01068c2
f0102ab9:	68 e5 65 10 f0       	push   $0xf01065e5
f0102abe:	68 14 04 00 00       	push   $0x414
f0102ac3:	68 bf 65 10 f0       	push   $0xf01065bf
f0102ac8:	e8 73 d5 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102acd:	f6 c2 02             	test   $0x2,%dl
f0102ad0:	75 38                	jne    f0102b0a <mem_init+0x1689>
f0102ad2:	68 d3 68 10 f0       	push   $0xf01068d3
f0102ad7:	68 e5 65 10 f0       	push   $0xf01065e5
f0102adc:	68 15 04 00 00       	push   $0x415
f0102ae1:	68 bf 65 10 f0       	push   $0xf01065bf
f0102ae6:	e8 55 d5 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102aeb:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102aef:	74 19                	je     f0102b0a <mem_init+0x1689>
f0102af1:	68 e4 68 10 f0       	push   $0xf01068e4
f0102af6:	68 e5 65 10 f0       	push   $0xf01065e5
f0102afb:	68 17 04 00 00       	push   $0x417
f0102b00:	68 bf 65 10 f0       	push   $0xf01065bf
f0102b05:	e8 36 d5 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102b0a:	83 c0 01             	add    $0x1,%eax
f0102b0d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102b12:	0f 86 63 ff ff ff    	jbe    f0102a7b <mem_init+0x15fa>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102b18:	83 ec 0c             	sub    $0xc,%esp
f0102b1b:	68 40 72 10 f0       	push   $0xf0107240
f0102b20:	e8 7c 0d 00 00       	call   f01038a1 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102b25:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b2a:	83 c4 10             	add    $0x10,%esp
f0102b2d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b32:	77 15                	ja     f0102b49 <mem_init+0x16c8>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b34:	50                   	push   %eax
f0102b35:	68 28 60 10 f0       	push   $0xf0106028
f0102b3a:	68 fa 00 00 00       	push   $0xfa
f0102b3f:	68 bf 65 10 f0       	push   $0xf01065bf
f0102b44:	e8 f7 d4 ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102b49:	05 00 00 00 10       	add    $0x10000000,%eax
f0102b4e:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102b51:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b56:	e8 3f e0 ff ff       	call   f0100b9a <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102b5b:	0f 20 c0             	mov    %cr0,%eax
f0102b5e:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102b61:	0d 23 00 05 80       	or     $0x80050023,%eax
f0102b66:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102b69:	83 ec 0c             	sub    $0xc,%esp
f0102b6c:	6a 00                	push   $0x0
f0102b6e:	e8 f0 e4 ff ff       	call   f0101063 <page_alloc>
f0102b73:	89 c3                	mov    %eax,%ebx
f0102b75:	83 c4 10             	add    $0x10,%esp
f0102b78:	85 c0                	test   %eax,%eax
f0102b7a:	75 19                	jne    f0102b95 <mem_init+0x1714>
f0102b7c:	68 ce 66 10 f0       	push   $0xf01066ce
f0102b81:	68 e5 65 10 f0       	push   $0xf01065e5
f0102b86:	68 f3 04 00 00       	push   $0x4f3
f0102b8b:	68 bf 65 10 f0       	push   $0xf01065bf
f0102b90:	e8 ab d4 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102b95:	83 ec 0c             	sub    $0xc,%esp
f0102b98:	6a 00                	push   $0x0
f0102b9a:	e8 c4 e4 ff ff       	call   f0101063 <page_alloc>
f0102b9f:	89 c7                	mov    %eax,%edi
f0102ba1:	83 c4 10             	add    $0x10,%esp
f0102ba4:	85 c0                	test   %eax,%eax
f0102ba6:	75 19                	jne    f0102bc1 <mem_init+0x1740>
f0102ba8:	68 e4 66 10 f0       	push   $0xf01066e4
f0102bad:	68 e5 65 10 f0       	push   $0xf01065e5
f0102bb2:	68 f4 04 00 00       	push   $0x4f4
f0102bb7:	68 bf 65 10 f0       	push   $0xf01065bf
f0102bbc:	e8 7f d4 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102bc1:	83 ec 0c             	sub    $0xc,%esp
f0102bc4:	6a 00                	push   $0x0
f0102bc6:	e8 98 e4 ff ff       	call   f0101063 <page_alloc>
f0102bcb:	89 c6                	mov    %eax,%esi
f0102bcd:	83 c4 10             	add    $0x10,%esp
f0102bd0:	85 c0                	test   %eax,%eax
f0102bd2:	75 19                	jne    f0102bed <mem_init+0x176c>
f0102bd4:	68 fa 66 10 f0       	push   $0xf01066fa
f0102bd9:	68 e5 65 10 f0       	push   $0xf01065e5
f0102bde:	68 f5 04 00 00       	push   $0x4f5
f0102be3:	68 bf 65 10 f0       	push   $0xf01065bf
f0102be8:	e8 53 d4 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0102bed:	83 ec 0c             	sub    $0xc,%esp
f0102bf0:	53                   	push   %ebx
f0102bf1:	e8 de e4 ff ff       	call   f01010d4 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102bf6:	89 f8                	mov    %edi,%eax
f0102bf8:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0102bfe:	c1 f8 03             	sar    $0x3,%eax
f0102c01:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c04:	89 c2                	mov    %eax,%edx
f0102c06:	c1 ea 0c             	shr    $0xc,%edx
f0102c09:	83 c4 10             	add    $0x10,%esp
f0102c0c:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f0102c12:	72 12                	jb     f0102c26 <mem_init+0x17a5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c14:	50                   	push   %eax
f0102c15:	68 04 60 10 f0       	push   $0xf0106004
f0102c1a:	6a 58                	push   $0x58
f0102c1c:	68 cb 65 10 f0       	push   $0xf01065cb
f0102c21:	e8 1a d4 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102c26:	83 ec 04             	sub    $0x4,%esp
f0102c29:	68 00 10 00 00       	push   $0x1000
f0102c2e:	6a 01                	push   $0x1
f0102c30:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c35:	50                   	push   %eax
f0102c36:	e8 e9 26 00 00       	call   f0105324 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102c3b:	89 f0                	mov    %esi,%eax
f0102c3d:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0102c43:	c1 f8 03             	sar    $0x3,%eax
f0102c46:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c49:	89 c2                	mov    %eax,%edx
f0102c4b:	c1 ea 0c             	shr    $0xc,%edx
f0102c4e:	83 c4 10             	add    $0x10,%esp
f0102c51:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f0102c57:	72 12                	jb     f0102c6b <mem_init+0x17ea>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c59:	50                   	push   %eax
f0102c5a:	68 04 60 10 f0       	push   $0xf0106004
f0102c5f:	6a 58                	push   $0x58
f0102c61:	68 cb 65 10 f0       	push   $0xf01065cb
f0102c66:	e8 d5 d3 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102c6b:	83 ec 04             	sub    $0x4,%esp
f0102c6e:	68 00 10 00 00       	push   $0x1000
f0102c73:	6a 02                	push   $0x2
f0102c75:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c7a:	50                   	push   %eax
f0102c7b:	e8 a4 26 00 00       	call   f0105324 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102c80:	6a 02                	push   $0x2
f0102c82:	68 00 10 00 00       	push   $0x1000
f0102c87:	57                   	push   %edi
f0102c88:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0102c8e:	e8 fe e6 ff ff       	call   f0101391 <page_insert>
	assert(pp1->pp_ref == 1);
f0102c93:	83 c4 20             	add    $0x20,%esp
f0102c96:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102c9b:	74 19                	je     f0102cb6 <mem_init+0x1835>
f0102c9d:	68 cb 67 10 f0       	push   $0xf01067cb
f0102ca2:	68 e5 65 10 f0       	push   $0xf01065e5
f0102ca7:	68 fa 04 00 00       	push   $0x4fa
f0102cac:	68 bf 65 10 f0       	push   $0xf01065bf
f0102cb1:	e8 8a d3 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102cb6:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102cbd:	01 01 01 
f0102cc0:	74 19                	je     f0102cdb <mem_init+0x185a>
f0102cc2:	68 60 72 10 f0       	push   $0xf0107260
f0102cc7:	68 e5 65 10 f0       	push   $0xf01065e5
f0102ccc:	68 fb 04 00 00       	push   $0x4fb
f0102cd1:	68 bf 65 10 f0       	push   $0xf01065bf
f0102cd6:	e8 65 d3 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102cdb:	6a 02                	push   $0x2
f0102cdd:	68 00 10 00 00       	push   $0x1000
f0102ce2:	56                   	push   %esi
f0102ce3:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0102ce9:	e8 a3 e6 ff ff       	call   f0101391 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102cee:	83 c4 10             	add    $0x10,%esp
f0102cf1:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102cf8:	02 02 02 
f0102cfb:	74 19                	je     f0102d16 <mem_init+0x1895>
f0102cfd:	68 84 72 10 f0       	push   $0xf0107284
f0102d02:	68 e5 65 10 f0       	push   $0xf01065e5
f0102d07:	68 fd 04 00 00       	push   $0x4fd
f0102d0c:	68 bf 65 10 f0       	push   $0xf01065bf
f0102d11:	e8 2a d3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102d16:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102d1b:	74 19                	je     f0102d36 <mem_init+0x18b5>
f0102d1d:	68 ed 67 10 f0       	push   $0xf01067ed
f0102d22:	68 e5 65 10 f0       	push   $0xf01065e5
f0102d27:	68 fe 04 00 00       	push   $0x4fe
f0102d2c:	68 bf 65 10 f0       	push   $0xf01065bf
f0102d31:	e8 0a d3 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102d36:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102d3b:	74 19                	je     f0102d56 <mem_init+0x18d5>
f0102d3d:	68 57 68 10 f0       	push   $0xf0106857
f0102d42:	68 e5 65 10 f0       	push   $0xf01065e5
f0102d47:	68 ff 04 00 00       	push   $0x4ff
f0102d4c:	68 bf 65 10 f0       	push   $0xf01065bf
f0102d51:	e8 ea d2 ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102d56:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102d5d:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102d60:	89 f0                	mov    %esi,%eax
f0102d62:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0102d68:	c1 f8 03             	sar    $0x3,%eax
f0102d6b:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102d6e:	89 c2                	mov    %eax,%edx
f0102d70:	c1 ea 0c             	shr    $0xc,%edx
f0102d73:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f0102d79:	72 12                	jb     f0102d8d <mem_init+0x190c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d7b:	50                   	push   %eax
f0102d7c:	68 04 60 10 f0       	push   $0xf0106004
f0102d81:	6a 58                	push   $0x58
f0102d83:	68 cb 65 10 f0       	push   $0xf01065cb
f0102d88:	e8 b3 d2 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102d8d:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102d94:	03 03 03 
f0102d97:	74 19                	je     f0102db2 <mem_init+0x1931>
f0102d99:	68 a8 72 10 f0       	push   $0xf01072a8
f0102d9e:	68 e5 65 10 f0       	push   $0xf01065e5
f0102da3:	68 01 05 00 00       	push   $0x501
f0102da8:	68 bf 65 10 f0       	push   $0xf01065bf
f0102dad:	e8 8e d2 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102db2:	83 ec 08             	sub    $0x8,%esp
f0102db5:	68 00 10 00 00       	push   $0x1000
f0102dba:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0102dc0:	e8 7f e5 ff ff       	call   f0101344 <page_remove>
	assert(pp2->pp_ref == 0);
f0102dc5:	83 c4 10             	add    $0x10,%esp
f0102dc8:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102dcd:	74 19                	je     f0102de8 <mem_init+0x1967>
f0102dcf:	68 25 68 10 f0       	push   $0xf0106825
f0102dd4:	68 e5 65 10 f0       	push   $0xf01065e5
f0102dd9:	68 03 05 00 00       	push   $0x503
f0102dde:	68 bf 65 10 f0       	push   $0xf01065bf
f0102de3:	e8 58 d2 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102de8:	8b 0d 8c be 22 f0    	mov    0xf022be8c,%ecx
f0102dee:	8b 11                	mov    (%ecx),%edx
f0102df0:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102df6:	89 d8                	mov    %ebx,%eax
f0102df8:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0102dfe:	c1 f8 03             	sar    $0x3,%eax
f0102e01:	c1 e0 0c             	shl    $0xc,%eax
f0102e04:	39 c2                	cmp    %eax,%edx
f0102e06:	74 19                	je     f0102e21 <mem_init+0x19a0>
f0102e08:	68 30 6c 10 f0       	push   $0xf0106c30
f0102e0d:	68 e5 65 10 f0       	push   $0xf01065e5
f0102e12:	68 06 05 00 00       	push   $0x506
f0102e17:	68 bf 65 10 f0       	push   $0xf01065bf
f0102e1c:	e8 1f d2 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102e21:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102e27:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102e2c:	74 19                	je     f0102e47 <mem_init+0x19c6>
f0102e2e:	68 dc 67 10 f0       	push   $0xf01067dc
f0102e33:	68 e5 65 10 f0       	push   $0xf01065e5
f0102e38:	68 08 05 00 00       	push   $0x508
f0102e3d:	68 bf 65 10 f0       	push   $0xf01065bf
f0102e42:	e8 f9 d1 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102e47:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102e4d:	83 ec 0c             	sub    $0xc,%esp
f0102e50:	53                   	push   %ebx
f0102e51:	e8 7e e2 ff ff       	call   f01010d4 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102e56:	c7 04 24 d4 72 10 f0 	movl   $0xf01072d4,(%esp)
f0102e5d:	e8 3f 0a 00 00       	call   f01038a1 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102e62:	83 c4 10             	add    $0x10,%esp
f0102e65:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e68:	5b                   	pop    %ebx
f0102e69:	5e                   	pop    %esi
f0102e6a:	5f                   	pop    %edi
f0102e6b:	5d                   	pop    %ebp
f0102e6c:	c3                   	ret    

f0102e6d <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102e6d:	55                   	push   %ebp
f0102e6e:	89 e5                	mov    %esp,%ebp
f0102e70:	57                   	push   %edi
f0102e71:	56                   	push   %esi
f0102e72:	53                   	push   %ebx
f0102e73:	83 ec 1c             	sub    $0x1c,%esp
f0102e76:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102e79:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 3: Your code here.

	pte_t* pte;

	// for every page in this region
	for (void* i=ROUNDDOWN((void *)va, PGSIZE); i<ROUNDUP((void *)(va+len), PGSIZE); i+=PGSIZE) {
f0102e7c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102e7f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102e84:	89 c3                	mov    %eax,%ebx
f0102e86:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0102e89:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102e8c:	03 45 10             	add    0x10(%ebp),%eax
f0102e8f:	05 ff 0f 00 00       	add    $0xfff,%eax
f0102e94:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102e99:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102e9c:	eb 6f                	jmp    f0102f0d <user_mem_check+0xa0>

		if ((uintptr_t)i >= ULIM) {
f0102e9e:	89 5d e0             	mov    %ebx,-0x20(%ebp)
f0102ea1:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102ea7:	76 15                	jbe    f0102ebe <user_mem_check+0x51>
			user_mem_check_addr = (i == ROUNDDOWN((void *)va, PGSIZE))? (uintptr_t)va:(uintptr_t)i;
f0102ea9:	3b 5d dc             	cmp    -0x24(%ebp),%ebx
f0102eac:	89 d8                	mov    %ebx,%eax
f0102eae:	0f 44 45 0c          	cmove  0xc(%ebp),%eax
f0102eb2:	a3 3c b2 22 f0       	mov    %eax,0xf022b23c
			return -E_FAULT;
f0102eb7:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102ebc:	eb 59                	jmp    f0102f17 <user_mem_check+0xaa>
		}

		//  get this page
		pte = pgdir_walk(env->env_pgdir, i, 0);
f0102ebe:	83 ec 04             	sub    $0x4,%esp
f0102ec1:	6a 00                	push   $0x0
f0102ec3:	53                   	push   %ebx
f0102ec4:	ff 77 60             	pushl  0x60(%edi)
f0102ec7:	e8 85 e2 ff ff       	call   f0101151 <pgdir_walk>

		if (pte == NULL) {
f0102ecc:	83 c4 10             	add    $0x10,%esp
f0102ecf:	85 c0                	test   %eax,%eax
f0102ed1:	75 16                	jne    f0102ee9 <user_mem_check+0x7c>
			user_mem_check_addr = (i == ROUNDDOWN((void *)va, PGSIZE))? (uintptr_t)va:(uintptr_t)i;
f0102ed3:	3b 5d dc             	cmp    -0x24(%ebp),%ebx
f0102ed6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102ed9:	0f 44 45 0c          	cmove  0xc(%ebp),%eax
f0102edd:	a3 3c b2 22 f0       	mov    %eax,0xf022b23c
			return -E_FAULT;
f0102ee2:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102ee7:	eb 2e                	jmp    f0102f17 <user_mem_check+0xaa>
		}

		// perm wrong
		if (((uint32_t)(*pte) & perm) != perm) {
f0102ee9:	89 f2                	mov    %esi,%edx
f0102eeb:	23 10                	and    (%eax),%edx
f0102eed:	39 d6                	cmp    %edx,%esi
f0102eef:	74 16                	je     f0102f07 <user_mem_check+0x9a>
			// if happens at first page, we return va instead of ROUNDDOWN(va, PGSIZE)
			// just to make it more precise 
			user_mem_check_addr = (i == ROUNDDOWN((void *)va, PGSIZE))? (uintptr_t)va:(uintptr_t)i;
f0102ef1:	3b 5d dc             	cmp    -0x24(%ebp),%ebx
f0102ef4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102ef7:	0f 44 45 0c          	cmove  0xc(%ebp),%eax
f0102efb:	a3 3c b2 22 f0       	mov    %eax,0xf022b23c
			return -E_FAULT;
f0102f00:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102f05:	eb 10                	jmp    f0102f17 <user_mem_check+0xaa>
	// LAB 3: Your code here.

	pte_t* pte;

	// for every page in this region
	for (void* i=ROUNDDOWN((void *)va, PGSIZE); i<ROUNDUP((void *)(va+len), PGSIZE); i+=PGSIZE) {
f0102f07:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f0d:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102f10:	72 8c                	jb     f0102e9e <user_mem_check+0x31>
			return -E_FAULT;
		}

	}

	return 0;
f0102f12:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102f17:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f1a:	5b                   	pop    %ebx
f0102f1b:	5e                   	pop    %esi
f0102f1c:	5f                   	pop    %edi
f0102f1d:	5d                   	pop    %ebp
f0102f1e:	c3                   	ret    

f0102f1f <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102f1f:	55                   	push   %ebp
f0102f20:	89 e5                	mov    %esp,%ebp
f0102f22:	53                   	push   %ebx
f0102f23:	83 ec 04             	sub    $0x4,%esp
f0102f26:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102f29:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f2c:	83 c8 04             	or     $0x4,%eax
f0102f2f:	50                   	push   %eax
f0102f30:	ff 75 10             	pushl  0x10(%ebp)
f0102f33:	ff 75 0c             	pushl  0xc(%ebp)
f0102f36:	53                   	push   %ebx
f0102f37:	e8 31 ff ff ff       	call   f0102e6d <user_mem_check>
f0102f3c:	83 c4 10             	add    $0x10,%esp
f0102f3f:	85 c0                	test   %eax,%eax
f0102f41:	79 21                	jns    f0102f64 <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102f43:	83 ec 04             	sub    $0x4,%esp
f0102f46:	ff 35 3c b2 22 f0    	pushl  0xf022b23c
f0102f4c:	ff 73 48             	pushl  0x48(%ebx)
f0102f4f:	68 00 73 10 f0       	push   $0xf0107300
f0102f54:	e8 48 09 00 00       	call   f01038a1 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102f59:	89 1c 24             	mov    %ebx,(%esp)
f0102f5c:	e8 3f 06 00 00       	call   f01035a0 <env_destroy>
f0102f61:	83 c4 10             	add    $0x10,%esp
	}
}
f0102f64:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102f67:	c9                   	leave  
f0102f68:	c3                   	ret    

f0102f69 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102f69:	55                   	push   %ebp
f0102f6a:	89 e5                	mov    %esp,%ebp
f0102f6c:	57                   	push   %edi
f0102f6d:	56                   	push   %esi
f0102f6e:	53                   	push   %ebx
f0102f6f:	83 ec 0c             	sub    $0xc,%esp
f0102f72:	89 c7                	mov    %eax,%edi
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)

	for (void* i=ROUNDDOWN(va, PGSIZE); i<ROUNDUP(va+len, PGSIZE); i += PGSIZE) {
f0102f74:	89 d3                	mov    %edx,%ebx
f0102f76:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102f7c:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0102f83:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
f0102f89:	eb 56                	jmp    f0102fe1 <region_alloc+0x78>

		struct PageInfo* pp = page_alloc(ALLOC_ZERO);
f0102f8b:	83 ec 0c             	sub    $0xc,%esp
f0102f8e:	6a 01                	push   $0x1
f0102f90:	e8 ce e0 ff ff       	call   f0101063 <page_alloc>
		if (pp == 0) {
f0102f95:	83 c4 10             	add    $0x10,%esp
f0102f98:	85 c0                	test   %eax,%eax
f0102f9a:	75 17                	jne    f0102fb3 <region_alloc+0x4a>
			panic("region_alloc: page_alloc return 0");
f0102f9c:	83 ec 04             	sub    $0x4,%esp
f0102f9f:	68 38 73 10 f0       	push   $0xf0107338
f0102fa4:	68 2b 01 00 00       	push   $0x12b
f0102fa9:	68 fc 73 10 f0       	push   $0xf01073fc
f0102fae:	e8 8d d0 ff ff       	call   f0100040 <_panic>
		}

		int err = page_insert(e->env_pgdir, pp, i, PTE_U | PTE_W);
f0102fb3:	6a 06                	push   $0x6
f0102fb5:	53                   	push   %ebx
f0102fb6:	50                   	push   %eax
f0102fb7:	ff 77 60             	pushl  0x60(%edi)
f0102fba:	e8 d2 e3 ff ff       	call   f0101391 <page_insert>
		if (err < 0) {
f0102fbf:	83 c4 10             	add    $0x10,%esp
f0102fc2:	85 c0                	test   %eax,%eax
f0102fc4:	79 15                	jns    f0102fdb <region_alloc+0x72>
			panic("region_alloc: page_insert failed: %e", err);
f0102fc6:	50                   	push   %eax
f0102fc7:	68 5c 73 10 f0       	push   $0xf010735c
f0102fcc:	68 30 01 00 00       	push   $0x130
f0102fd1:	68 fc 73 10 f0       	push   $0xf01073fc
f0102fd6:	e8 65 d0 ff ff       	call   f0100040 <_panic>
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)

	for (void* i=ROUNDDOWN(va, PGSIZE); i<ROUNDUP(va+len, PGSIZE); i += PGSIZE) {
f0102fdb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102fe1:	39 f3                	cmp    %esi,%ebx
f0102fe3:	72 a6                	jb     f0102f8b <region_alloc+0x22>
		}

	}

	
}
f0102fe5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102fe8:	5b                   	pop    %ebx
f0102fe9:	5e                   	pop    %esi
f0102fea:	5f                   	pop    %edi
f0102feb:	5d                   	pop    %ebp
f0102fec:	c3                   	ret    

f0102fed <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102fed:	55                   	push   %ebp
f0102fee:	89 e5                	mov    %esp,%ebp
f0102ff0:	56                   	push   %esi
f0102ff1:	53                   	push   %ebx
f0102ff2:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ff5:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102ff8:	85 c0                	test   %eax,%eax
f0102ffa:	75 1a                	jne    f0103016 <envid2env+0x29>
		*env_store = curenv;
f0102ffc:	e8 45 29 00 00       	call   f0105946 <cpunum>
f0103001:	6b c0 74             	imul   $0x74,%eax,%eax
f0103004:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f010300a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010300d:	89 01                	mov    %eax,(%ecx)
		return 0;
f010300f:	b8 00 00 00 00       	mov    $0x0,%eax
f0103014:	eb 70                	jmp    f0103086 <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103016:	89 c3                	mov    %eax,%ebx
f0103018:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f010301e:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0103021:	03 1d 48 b2 22 f0    	add    0xf022b248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103027:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f010302b:	74 05                	je     f0103032 <envid2env+0x45>
f010302d:	3b 43 48             	cmp    0x48(%ebx),%eax
f0103030:	74 10                	je     f0103042 <envid2env+0x55>
		*env_store = 0;
f0103032:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103035:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010303b:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103040:	eb 44                	jmp    f0103086 <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103042:	84 d2                	test   %dl,%dl
f0103044:	74 36                	je     f010307c <envid2env+0x8f>
f0103046:	e8 fb 28 00 00       	call   f0105946 <cpunum>
f010304b:	6b c0 74             	imul   $0x74,%eax,%eax
f010304e:	3b 98 28 c0 22 f0    	cmp    -0xfdd3fd8(%eax),%ebx
f0103054:	74 26                	je     f010307c <envid2env+0x8f>
f0103056:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0103059:	e8 e8 28 00 00       	call   f0105946 <cpunum>
f010305e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103061:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103067:	3b 70 48             	cmp    0x48(%eax),%esi
f010306a:	74 10                	je     f010307c <envid2env+0x8f>
		*env_store = 0;
f010306c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010306f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103075:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010307a:	eb 0a                	jmp    f0103086 <envid2env+0x99>
	}

	*env_store = e;
f010307c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010307f:	89 18                	mov    %ebx,(%eax)
	return 0;
f0103081:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103086:	5b                   	pop    %ebx
f0103087:	5e                   	pop    %esi
f0103088:	5d                   	pop    %ebp
f0103089:	c3                   	ret    

f010308a <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f010308a:	55                   	push   %ebp
f010308b:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f010308d:	b8 20 03 12 f0       	mov    $0xf0120320,%eax
f0103092:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0103095:	b8 23 00 00 00       	mov    $0x23,%eax
f010309a:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f010309c:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f010309e:	b8 10 00 00 00       	mov    $0x10,%eax
f01030a3:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f01030a5:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f01030a7:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f01030a9:	ea b0 30 10 f0 08 00 	ljmp   $0x8,$0xf01030b0
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f01030b0:	b8 00 00 00 00       	mov    $0x0,%eax
f01030b5:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f01030b8:	5d                   	pop    %ebp
f01030b9:	c3                   	ret    

f01030ba <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f01030ba:	55                   	push   %ebp
f01030bb:	89 e5                	mov    %esp,%ebp
f01030bd:	56                   	push   %esi
f01030be:	53                   	push   %ebx
	// LAB 3: Your code here.

	// make sure env_free_list point to envs[0]
	// so that the first env_alloc() will return envs[0]
	for (int i=NENV-1; i>=0; i--) {
		envs[i].env_id = 0;
f01030bf:	8b 35 48 b2 22 f0    	mov    0xf022b248,%esi
f01030c5:	8b 15 4c b2 22 f0    	mov    0xf022b24c,%edx
f01030cb:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f01030d1:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f01030d4:	89 c1                	mov    %eax,%ecx
f01030d6:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f01030dd:	89 50 44             	mov    %edx,0x44(%eax)
f01030e0:	83 e8 7c             	sub    $0x7c,%eax
		env_free_list = &envs[i];
f01030e3:	89 ca                	mov    %ecx,%edx
	// Set up envs array
	// LAB 3: Your code here.

	// make sure env_free_list point to envs[0]
	// so that the first env_alloc() will return envs[0]
	for (int i=NENV-1; i>=0; i--) {
f01030e5:	39 d8                	cmp    %ebx,%eax
f01030e7:	75 eb                	jne    f01030d4 <env_init+0x1a>
f01030e9:	89 35 4c b2 22 f0    	mov    %esi,0xf022b24c
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
	}

	// Per-CPU part of the initialization
	env_init_percpu();
f01030ef:	e8 96 ff ff ff       	call   f010308a <env_init_percpu>
}
f01030f4:	5b                   	pop    %ebx
f01030f5:	5e                   	pop    %esi
f01030f6:	5d                   	pop    %ebp
f01030f7:	c3                   	ret    

f01030f8 <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f01030f8:	55                   	push   %ebp
f01030f9:	89 e5                	mov    %esp,%ebp
f01030fb:	56                   	push   %esi
f01030fc:	53                   	push   %ebx
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f01030fd:	8b 1d 4c b2 22 f0    	mov    0xf022b24c,%ebx
f0103103:	85 db                	test   %ebx,%ebx
f0103105:	0f 84 64 01 00 00    	je     f010326f <env_alloc+0x177>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f010310b:	83 ec 0c             	sub    $0xc,%esp
f010310e:	6a 01                	push   $0x1
f0103110:	e8 4e df ff ff       	call   f0101063 <page_alloc>
f0103115:	89 c6                	mov    %eax,%esi
f0103117:	83 c4 10             	add    $0x10,%esp
f010311a:	85 c0                	test   %eax,%eax
f010311c:	0f 84 54 01 00 00    	je     f0103276 <env_alloc+0x17e>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103122:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0103128:	c1 f8 03             	sar    $0x3,%eax
f010312b:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010312e:	89 c2                	mov    %eax,%edx
f0103130:	c1 ea 0c             	shr    $0xc,%edx
f0103133:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f0103139:	72 12                	jb     f010314d <env_alloc+0x55>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010313b:	50                   	push   %eax
f010313c:	68 04 60 10 f0       	push   $0xf0106004
f0103141:	6a 58                	push   $0x58
f0103143:	68 cb 65 10 f0       	push   $0xf01065cb
f0103148:	e8 f3 ce ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010314d:	2d 00 00 00 10       	sub    $0x10000000,%eax
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.

	e->env_pgdir = page2kva(p);
f0103152:	89 43 60             	mov    %eax,0x60(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0103155:	83 ec 04             	sub    $0x4,%esp
f0103158:	68 00 10 00 00       	push   $0x1000
f010315d:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0103163:	50                   	push   %eax
f0103164:	e8 70 22 00 00       	call   f01053d9 <memcpy>
	p->pp_ref++;
f0103169:	66 83 46 04 01       	addw   $0x1,0x4(%esi)

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f010316e:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103171:	83 c4 10             	add    $0x10,%esp
f0103174:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103179:	77 15                	ja     f0103190 <env_alloc+0x98>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010317b:	50                   	push   %eax
f010317c:	68 28 60 10 f0       	push   $0xf0106028
f0103181:	68 c8 00 00 00       	push   $0xc8
f0103186:	68 fc 73 10 f0       	push   $0xf01073fc
f010318b:	e8 b0 ce ff ff       	call   f0100040 <_panic>
f0103190:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103196:	83 ca 05             	or     $0x5,%edx
f0103199:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f010319f:	8b 43 48             	mov    0x48(%ebx),%eax
f01031a2:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01031a7:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f01031ac:	ba 00 10 00 00       	mov    $0x1000,%edx
f01031b1:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f01031b4:	89 da                	mov    %ebx,%edx
f01031b6:	2b 15 48 b2 22 f0    	sub    0xf022b248,%edx
f01031bc:	c1 fa 02             	sar    $0x2,%edx
f01031bf:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f01031c5:	09 d0                	or     %edx,%eax
f01031c7:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f01031ca:	8b 45 0c             	mov    0xc(%ebp),%eax
f01031cd:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f01031d0:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01031d7:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f01031de:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01031e5:	83 ec 04             	sub    $0x4,%esp
f01031e8:	6a 44                	push   $0x44
f01031ea:	6a 00                	push   $0x0
f01031ec:	53                   	push   %ebx
f01031ed:	e8 32 21 00 00       	call   f0105324 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f01031f2:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01031f8:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01031fe:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103204:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f010320b:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103211:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103218:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f010321c:	8b 43 44             	mov    0x44(%ebx),%eax
f010321f:	a3 4c b2 22 f0       	mov    %eax,0xf022b24c
	*newenv_store = e;
f0103224:	8b 45 08             	mov    0x8(%ebp),%eax
f0103227:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103229:	8b 5b 48             	mov    0x48(%ebx),%ebx
f010322c:	e8 15 27 00 00       	call   f0105946 <cpunum>
f0103231:	6b c0 74             	imul   $0x74,%eax,%eax
f0103234:	83 c4 10             	add    $0x10,%esp
f0103237:	ba 00 00 00 00       	mov    $0x0,%edx
f010323c:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f0103243:	74 11                	je     f0103256 <env_alloc+0x15e>
f0103245:	e8 fc 26 00 00       	call   f0105946 <cpunum>
f010324a:	6b c0 74             	imul   $0x74,%eax,%eax
f010324d:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103253:	8b 50 48             	mov    0x48(%eax),%edx
f0103256:	83 ec 04             	sub    $0x4,%esp
f0103259:	53                   	push   %ebx
f010325a:	52                   	push   %edx
f010325b:	68 07 74 10 f0       	push   $0xf0107407
f0103260:	e8 3c 06 00 00       	call   f01038a1 <cprintf>
	return 0;
f0103265:	83 c4 10             	add    $0x10,%esp
f0103268:	b8 00 00 00 00       	mov    $0x0,%eax
f010326d:	eb 0c                	jmp    f010327b <env_alloc+0x183>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f010326f:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103274:	eb 05                	jmp    f010327b <env_alloc+0x183>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103276:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f010327b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010327e:	5b                   	pop    %ebx
f010327f:	5e                   	pop    %esi
f0103280:	5d                   	pop    %ebp
f0103281:	c3                   	ret    

f0103282 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103282:	55                   	push   %ebp
f0103283:	89 e5                	mov    %esp,%ebp
f0103285:	57                   	push   %edi
f0103286:	56                   	push   %esi
f0103287:	53                   	push   %ebx
f0103288:	83 ec 34             	sub    $0x34,%esp
f010328b:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.

	struct Env *newenv_store;
	envid_t parent_id = 0;
	int err = env_alloc(&newenv_store, 0);
f010328e:	6a 00                	push   $0x0
f0103290:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103293:	50                   	push   %eax
f0103294:	e8 5f fe ff ff       	call   f01030f8 <env_alloc>
	if (err < 0) 
f0103299:	83 c4 10             	add    $0x10,%esp
f010329c:	85 c0                	test   %eax,%eax
f010329e:	79 15                	jns    f01032b5 <env_create+0x33>
		panic("env_create: env_alloc failed: %e", err);
f01032a0:	50                   	push   %eax
f01032a1:	68 84 73 10 f0       	push   $0xf0107384
f01032a6:	68 b7 01 00 00       	push   $0x1b7
f01032ab:	68 fc 73 10 f0       	push   $0xf01073fc
f01032b0:	e8 8b cd ff ff       	call   f0100040 <_panic>
	load_icode(newenv_store, binary);
f01032b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01032b8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// LAB 3: Your code here.

	// read and check ELF property, inspired by boot/main.c
	struct Elf* elf = (struct Elf*) binary;

	if (elf->e_magic != ELF_MAGIC)
f01032bb:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f01032c1:	74 17                	je     f01032da <env_create+0x58>
		panic("load_icode: not a valid ELF format file");
f01032c3:	83 ec 04             	sub    $0x4,%esp
f01032c6:	68 a8 73 10 f0       	push   $0xf01073a8
f01032cb:	68 73 01 00 00       	push   $0x173
f01032d0:	68 fc 73 10 f0       	push   $0xf01073fc
f01032d5:	e8 66 cd ff ff       	call   f0100040 <_panic>

	struct Proghdr *ph, *eph;
	
	ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f01032da:	89 fb                	mov    %edi,%ebx
f01032dc:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + elf->e_phnum;
f01032df:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f01032e3:	c1 e6 05             	shl    $0x5,%esi
f01032e6:	01 de                	add    %ebx,%esi

	// we are setting user virtual address, but now we are in kernel mode
	// load env pgdir to cr3
	lcr3(PADDR(e->env_pgdir));	
f01032e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01032eb:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01032ee:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01032f3:	77 15                	ja     f010330a <env_create+0x88>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032f5:	50                   	push   %eax
f01032f6:	68 28 60 10 f0       	push   $0xf0106028
f01032fb:	68 7c 01 00 00       	push   $0x17c
f0103300:	68 fc 73 10 f0       	push   $0xf01073fc
f0103305:	e8 36 cd ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010330a:	05 00 00 00 10       	add    $0x10000000,%eax
f010330f:	0f 22 d8             	mov    %eax,%cr3
f0103312:	eb 59                	jmp    f010336d <env_create+0xeb>

	// for every segment
	for (; ph < eph; ph++) {

		// only load this type of segment
		if (ph->p_type == ELF_PROG_LOAD) {
f0103314:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103317:	75 51                	jne    f010336a <env_create+0xe8>

			if (ph->p_filesz > ph->p_memsz)
f0103319:	8b 4b 14             	mov    0x14(%ebx),%ecx
f010331c:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f010331f:	76 17                	jbe    f0103338 <env_create+0xb6>
				panic("load_icode: not a valid ELF format file (2)");
f0103321:	83 ec 04             	sub    $0x4,%esp
f0103324:	68 d0 73 10 f0       	push   $0xf01073d0
f0103329:	68 85 01 00 00       	push   $0x185
f010332e:	68 fc 73 10 f0       	push   $0xf01073fc
f0103333:	e8 08 cd ff ff       	call   f0100040 <_panic>

			// allocate and map each segment
			// this function needs e->env_pgdir
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0103338:	8b 53 08             	mov    0x8(%ebx),%edx
f010333b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010333e:	e8 26 fc ff ff       	call   f0102f69 <region_alloc>

			// all clear to 0
			memset((void *)ph->p_va, 0, ph->p_memsz);
f0103343:	83 ec 04             	sub    $0x4,%esp
f0103346:	ff 73 14             	pushl  0x14(%ebx)
f0103349:	6a 00                	push   $0x0
f010334b:	ff 73 08             	pushl  0x8(%ebx)
f010334e:	e8 d1 1f 00 00       	call   f0105324 <memset>

			// copy [binary + ph->p_offset, binary + ph->p_offset + ph->p_filesz) to ph->p_va
			// binary is of type uint8_t *, remember not use elf cuz its type is struct Elf*
			// making elf + ph->p_offset pointing to nowhere
			memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f0103353:	83 c4 0c             	add    $0xc,%esp
f0103356:	ff 73 10             	pushl  0x10(%ebx)
f0103359:	89 f8                	mov    %edi,%eax
f010335b:	03 43 04             	add    0x4(%ebx),%eax
f010335e:	50                   	push   %eax
f010335f:	ff 73 08             	pushl  0x8(%ebx)
f0103362:	e8 72 20 00 00       	call   f01053d9 <memcpy>
f0103367:	83 c4 10             	add    $0x10,%esp
	// we are setting user virtual address, but now we are in kernel mode
	// load env pgdir to cr3
	lcr3(PADDR(e->env_pgdir));	

	// for every segment
	for (; ph < eph; ph++) {
f010336a:	83 c3 20             	add    $0x20,%ebx
f010336d:	39 de                	cmp    %ebx,%esi
f010336f:	77 a3                	ja     f0103314 <env_create+0x92>
		}

	}

	// load program entry point to eip
	e->env_tf.tf_eip = elf->e_entry;
f0103371:	8b 47 18             	mov    0x18(%edi),%eax
f0103374:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103377:	89 47 30             	mov    %eax,0x30(%edi)
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.

	region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f010337a:	b9 00 10 00 00       	mov    $0x1000,%ecx
f010337f:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103384:	89 f8                	mov    %edi,%eax
f0103386:	e8 de fb ff ff       	call   f0102f69 <region_alloc>

	// after loading things from elf, restore cr3 in kernel
	lcr3(PADDR(kern_pgdir));
f010338b:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103390:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103395:	77 15                	ja     f01033ac <env_create+0x12a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103397:	50                   	push   %eax
f0103398:	68 28 60 10 f0       	push   $0xf0106028
f010339d:	68 a3 01 00 00       	push   $0x1a3
f01033a2:	68 fc 73 10 f0       	push   $0xf01073fc
f01033a7:	e8 94 cc ff ff       	call   f0100040 <_panic>
f01033ac:	05 00 00 00 10       	add    $0x10000000,%eax
f01033b1:	0f 22 d8             	mov    %eax,%cr3
	envid_t parent_id = 0;
	int err = env_alloc(&newenv_store, 0);
	if (err < 0) 
		panic("env_create: env_alloc failed: %e", err);
	load_icode(newenv_store, binary);
	newenv_store->env_type = type;
f01033b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01033b7:	8b 55 0c             	mov    0xc(%ebp),%edx
f01033ba:	89 50 50             	mov    %edx,0x50(%eax)

}
f01033bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01033c0:	5b                   	pop    %ebx
f01033c1:	5e                   	pop    %esi
f01033c2:	5f                   	pop    %edi
f01033c3:	5d                   	pop    %ebp
f01033c4:	c3                   	ret    

f01033c5 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01033c5:	55                   	push   %ebp
f01033c6:	89 e5                	mov    %esp,%ebp
f01033c8:	57                   	push   %edi
f01033c9:	56                   	push   %esi
f01033ca:	53                   	push   %ebx
f01033cb:	83 ec 1c             	sub    $0x1c,%esp
f01033ce:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01033d1:	e8 70 25 00 00       	call   f0105946 <cpunum>
f01033d6:	6b c0 74             	imul   $0x74,%eax,%eax
f01033d9:	39 b8 28 c0 22 f0    	cmp    %edi,-0xfdd3fd8(%eax)
f01033df:	75 29                	jne    f010340a <env_free+0x45>
		lcr3(PADDR(kern_pgdir));
f01033e1:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01033e6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01033eb:	77 15                	ja     f0103402 <env_free+0x3d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033ed:	50                   	push   %eax
f01033ee:	68 28 60 10 f0       	push   $0xf0106028
f01033f3:	68 cb 01 00 00       	push   $0x1cb
f01033f8:	68 fc 73 10 f0       	push   $0xf01073fc
f01033fd:	e8 3e cc ff ff       	call   f0100040 <_panic>
f0103402:	05 00 00 00 10       	add    $0x10000000,%eax
f0103407:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010340a:	8b 5f 48             	mov    0x48(%edi),%ebx
f010340d:	e8 34 25 00 00       	call   f0105946 <cpunum>
f0103412:	6b c0 74             	imul   $0x74,%eax,%eax
f0103415:	ba 00 00 00 00       	mov    $0x0,%edx
f010341a:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f0103421:	74 11                	je     f0103434 <env_free+0x6f>
f0103423:	e8 1e 25 00 00       	call   f0105946 <cpunum>
f0103428:	6b c0 74             	imul   $0x74,%eax,%eax
f010342b:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103431:	8b 50 48             	mov    0x48(%eax),%edx
f0103434:	83 ec 04             	sub    $0x4,%esp
f0103437:	53                   	push   %ebx
f0103438:	52                   	push   %edx
f0103439:	68 1c 74 10 f0       	push   $0xf010741c
f010343e:	e8 5e 04 00 00       	call   f01038a1 <cprintf>
f0103443:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103446:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f010344d:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103450:	89 d0                	mov    %edx,%eax
f0103452:	c1 e0 02             	shl    $0x2,%eax
f0103455:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103458:	8b 47 60             	mov    0x60(%edi),%eax
f010345b:	8b 34 90             	mov    (%eax,%edx,4),%esi
f010345e:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103464:	0f 84 a8 00 00 00    	je     f0103512 <env_free+0x14d>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f010346a:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103470:	89 f0                	mov    %esi,%eax
f0103472:	c1 e8 0c             	shr    $0xc,%eax
f0103475:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103478:	39 05 88 be 22 f0    	cmp    %eax,0xf022be88
f010347e:	77 15                	ja     f0103495 <env_free+0xd0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103480:	56                   	push   %esi
f0103481:	68 04 60 10 f0       	push   $0xf0106004
f0103486:	68 da 01 00 00       	push   $0x1da
f010348b:	68 fc 73 10 f0       	push   $0xf01073fc
f0103490:	e8 ab cb ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103495:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103498:	c1 e0 16             	shl    $0x16,%eax
f010349b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010349e:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f01034a3:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f01034aa:	01 
f01034ab:	74 17                	je     f01034c4 <env_free+0xff>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01034ad:	83 ec 08             	sub    $0x8,%esp
f01034b0:	89 d8                	mov    %ebx,%eax
f01034b2:	c1 e0 0c             	shl    $0xc,%eax
f01034b5:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01034b8:	50                   	push   %eax
f01034b9:	ff 77 60             	pushl  0x60(%edi)
f01034bc:	e8 83 de ff ff       	call   f0101344 <page_remove>
f01034c1:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01034c4:	83 c3 01             	add    $0x1,%ebx
f01034c7:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01034cd:	75 d4                	jne    f01034a3 <env_free+0xde>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01034cf:	8b 47 60             	mov    0x60(%edi),%eax
f01034d2:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01034d5:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01034dc:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01034df:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f01034e5:	72 14                	jb     f01034fb <env_free+0x136>
		panic("pa2page called with invalid pa");
f01034e7:	83 ec 04             	sub    $0x4,%esp
f01034ea:	68 d8 6a 10 f0       	push   $0xf0106ad8
f01034ef:	6a 51                	push   $0x51
f01034f1:	68 cb 65 10 f0       	push   $0xf01065cb
f01034f6:	e8 45 cb ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f01034fb:	83 ec 0c             	sub    $0xc,%esp
f01034fe:	a1 90 be 22 f0       	mov    0xf022be90,%eax
f0103503:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103506:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103509:	50                   	push   %eax
f010350a:	e8 1b dc ff ff       	call   f010112a <page_decref>
f010350f:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103512:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103516:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103519:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f010351e:	0f 85 29 ff ff ff    	jne    f010344d <env_free+0x88>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103524:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103527:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010352c:	77 15                	ja     f0103543 <env_free+0x17e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010352e:	50                   	push   %eax
f010352f:	68 28 60 10 f0       	push   $0xf0106028
f0103534:	68 e8 01 00 00       	push   $0x1e8
f0103539:	68 fc 73 10 f0       	push   $0xf01073fc
f010353e:	e8 fd ca ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103543:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010354a:	05 00 00 00 10       	add    $0x10000000,%eax
f010354f:	c1 e8 0c             	shr    $0xc,%eax
f0103552:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f0103558:	72 14                	jb     f010356e <env_free+0x1a9>
		panic("pa2page called with invalid pa");
f010355a:	83 ec 04             	sub    $0x4,%esp
f010355d:	68 d8 6a 10 f0       	push   $0xf0106ad8
f0103562:	6a 51                	push   $0x51
f0103564:	68 cb 65 10 f0       	push   $0xf01065cb
f0103569:	e8 d2 ca ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f010356e:	83 ec 0c             	sub    $0xc,%esp
f0103571:	8b 15 90 be 22 f0    	mov    0xf022be90,%edx
f0103577:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f010357a:	50                   	push   %eax
f010357b:	e8 aa db ff ff       	call   f010112a <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103580:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103587:	a1 4c b2 22 f0       	mov    0xf022b24c,%eax
f010358c:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f010358f:	89 3d 4c b2 22 f0    	mov    %edi,0xf022b24c
}
f0103595:	83 c4 10             	add    $0x10,%esp
f0103598:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010359b:	5b                   	pop    %ebx
f010359c:	5e                   	pop    %esi
f010359d:	5f                   	pop    %edi
f010359e:	5d                   	pop    %ebp
f010359f:	c3                   	ret    

f01035a0 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f01035a0:	55                   	push   %ebp
f01035a1:	89 e5                	mov    %esp,%ebp
f01035a3:	53                   	push   %ebx
f01035a4:	83 ec 04             	sub    $0x4,%esp
f01035a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01035aa:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f01035ae:	75 19                	jne    f01035c9 <env_destroy+0x29>
f01035b0:	e8 91 23 00 00       	call   f0105946 <cpunum>
f01035b5:	6b c0 74             	imul   $0x74,%eax,%eax
f01035b8:	3b 98 28 c0 22 f0    	cmp    -0xfdd3fd8(%eax),%ebx
f01035be:	74 09                	je     f01035c9 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f01035c0:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f01035c7:	eb 33                	jmp    f01035fc <env_destroy+0x5c>
	}

	env_free(e);
f01035c9:	83 ec 0c             	sub    $0xc,%esp
f01035cc:	53                   	push   %ebx
f01035cd:	e8 f3 fd ff ff       	call   f01033c5 <env_free>

	if (curenv == e) {
f01035d2:	e8 6f 23 00 00       	call   f0105946 <cpunum>
f01035d7:	6b c0 74             	imul   $0x74,%eax,%eax
f01035da:	83 c4 10             	add    $0x10,%esp
f01035dd:	3b 98 28 c0 22 f0    	cmp    -0xfdd3fd8(%eax),%ebx
f01035e3:	75 17                	jne    f01035fc <env_destroy+0x5c>
		curenv = NULL;
f01035e5:	e8 5c 23 00 00       	call   f0105946 <cpunum>
f01035ea:	6b c0 74             	imul   $0x74,%eax,%eax
f01035ed:	c7 80 28 c0 22 f0 00 	movl   $0x0,-0xfdd3fd8(%eax)
f01035f4:	00 00 00 
		sched_yield();
f01035f7:	e8 4f 0d 00 00       	call   f010434b <sched_yield>
	}
}
f01035fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01035ff:	c9                   	leave  
f0103600:	c3                   	ret    

f0103601 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103601:	55                   	push   %ebp
f0103602:	89 e5                	mov    %esp,%ebp
f0103604:	53                   	push   %ebx
f0103605:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103608:	e8 39 23 00 00       	call   f0105946 <cpunum>
f010360d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103610:	8b 98 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%ebx
f0103616:	e8 2b 23 00 00       	call   f0105946 <cpunum>
f010361b:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f010361e:	8b 65 08             	mov    0x8(%ebp),%esp
f0103621:	61                   	popa   
f0103622:	07                   	pop    %es
f0103623:	1f                   	pop    %ds
f0103624:	83 c4 08             	add    $0x8,%esp
f0103627:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103628:	83 ec 04             	sub    $0x4,%esp
f010362b:	68 32 74 10 f0       	push   $0xf0107432
f0103630:	68 1f 02 00 00       	push   $0x21f
f0103635:	68 fc 73 10 f0       	push   $0xf01073fc
f010363a:	e8 01 ca ff ff       	call   f0100040 <_panic>

f010363f <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f010363f:	55                   	push   %ebp
f0103640:	89 e5                	mov    %esp,%ebp
f0103642:	53                   	push   %ebx
f0103643:	83 ec 04             	sub    $0x4,%esp
f0103646:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

	// context switch
	if (curenv != e) {
f0103649:	e8 f8 22 00 00       	call   f0105946 <cpunum>
f010364e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103651:	39 98 28 c0 22 f0    	cmp    %ebx,-0xfdd3fd8(%eax)
f0103657:	74 3a                	je     f0103693 <env_run+0x54>

		if (curenv != NULL && curenv->env_status == ENV_RUNNING)
f0103659:	e8 e8 22 00 00       	call   f0105946 <cpunum>
f010365e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103661:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f0103668:	74 29                	je     f0103693 <env_run+0x54>
f010366a:	e8 d7 22 00 00       	call   f0105946 <cpunum>
f010366f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103672:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103678:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010367c:	75 15                	jne    f0103693 <env_run+0x54>
			curenv->env_status = ENV_RUNNABLE;
f010367e:	e8 c3 22 00 00       	call   f0105946 <cpunum>
f0103683:	6b c0 74             	imul   $0x74,%eax,%eax
f0103686:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f010368c:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
			
	}
	
	curenv = e;
f0103693:	e8 ae 22 00 00       	call   f0105946 <cpunum>
f0103698:	6b c0 74             	imul   $0x74,%eax,%eax
f010369b:	89 98 28 c0 22 f0    	mov    %ebx,-0xfdd3fd8(%eax)
	curenv->env_status = ENV_RUNNING;
f01036a1:	e8 a0 22 00 00       	call   f0105946 <cpunum>
f01036a6:	6b c0 74             	imul   $0x74,%eax,%eax
f01036a9:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01036af:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f01036b6:	e8 8b 22 00 00       	call   f0105946 <cpunum>
f01036bb:	6b c0 74             	imul   $0x74,%eax,%eax
f01036be:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01036c4:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3(PADDR(curenv->env_pgdir));
f01036c8:	e8 79 22 00 00       	call   f0105946 <cpunum>
f01036cd:	6b c0 74             	imul   $0x74,%eax,%eax
f01036d0:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01036d6:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01036d9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01036de:	77 15                	ja     f01036f5 <env_run+0xb6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01036e0:	50                   	push   %eax
f01036e1:	68 28 60 10 f0       	push   $0xf0106028
f01036e6:	68 49 02 00 00       	push   $0x249
f01036eb:	68 fc 73 10 f0       	push   $0xf01073fc
f01036f0:	e8 4b c9 ff ff       	call   f0100040 <_panic>
f01036f5:	05 00 00 00 10       	add    $0x10000000,%eax
f01036fa:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01036fd:	83 ec 0c             	sub    $0xc,%esp
f0103700:	68 c0 03 12 f0       	push   $0xf01203c0
f0103705:	e8 47 25 00 00       	call   f0105c51 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010370a:	f3 90                	pause  

	unlock_kernel();

	// iret to execute entry point stored in tf_eip
	// cprintf("[?] try to execute at entry point: %x\n", curenv->env_tf.tf_eip);
	env_pop_tf(&curenv->env_tf);
f010370c:	e8 35 22 00 00       	call   f0105946 <cpunum>
f0103711:	83 c4 04             	add    $0x4,%esp
f0103714:	6b c0 74             	imul   $0x74,%eax,%eax
f0103717:	ff b0 28 c0 22 f0    	pushl  -0xfdd3fd8(%eax)
f010371d:	e8 df fe ff ff       	call   f0103601 <env_pop_tf>

f0103722 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103722:	55                   	push   %ebp
f0103723:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103725:	ba 70 00 00 00       	mov    $0x70,%edx
f010372a:	8b 45 08             	mov    0x8(%ebp),%eax
f010372d:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010372e:	ba 71 00 00 00       	mov    $0x71,%edx
f0103733:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103734:	0f b6 c0             	movzbl %al,%eax
}
f0103737:	5d                   	pop    %ebp
f0103738:	c3                   	ret    

f0103739 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103739:	55                   	push   %ebp
f010373a:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010373c:	ba 70 00 00 00       	mov    $0x70,%edx
f0103741:	8b 45 08             	mov    0x8(%ebp),%eax
f0103744:	ee                   	out    %al,(%dx)
f0103745:	ba 71 00 00 00       	mov    $0x71,%edx
f010374a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010374d:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010374e:	5d                   	pop    %ebp
f010374f:	c3                   	ret    

f0103750 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103750:	55                   	push   %ebp
f0103751:	89 e5                	mov    %esp,%ebp
f0103753:	56                   	push   %esi
f0103754:	53                   	push   %ebx
f0103755:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103758:	66 a3 a8 03 12 f0    	mov    %ax,0xf01203a8
	if (!didinit)
f010375e:	80 3d 50 b2 22 f0 00 	cmpb   $0x0,0xf022b250
f0103765:	74 5a                	je     f01037c1 <irq_setmask_8259A+0x71>
f0103767:	89 c6                	mov    %eax,%esi
f0103769:	ba 21 00 00 00       	mov    $0x21,%edx
f010376e:	ee                   	out    %al,(%dx)
f010376f:	66 c1 e8 08          	shr    $0x8,%ax
f0103773:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103778:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f0103779:	83 ec 0c             	sub    $0xc,%esp
f010377c:	68 3e 74 10 f0       	push   $0xf010743e
f0103781:	e8 1b 01 00 00       	call   f01038a1 <cprintf>
f0103786:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103789:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f010378e:	0f b7 f6             	movzwl %si,%esi
f0103791:	f7 d6                	not    %esi
f0103793:	0f a3 de             	bt     %ebx,%esi
f0103796:	73 11                	jae    f01037a9 <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f0103798:	83 ec 08             	sub    $0x8,%esp
f010379b:	53                   	push   %ebx
f010379c:	68 d3 78 10 f0       	push   $0xf01078d3
f01037a1:	e8 fb 00 00 00       	call   f01038a1 <cprintf>
f01037a6:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f01037a9:	83 c3 01             	add    $0x1,%ebx
f01037ac:	83 fb 10             	cmp    $0x10,%ebx
f01037af:	75 e2                	jne    f0103793 <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f01037b1:	83 ec 0c             	sub    $0xc,%esp
f01037b4:	68 c0 68 10 f0       	push   $0xf01068c0
f01037b9:	e8 e3 00 00 00       	call   f01038a1 <cprintf>
f01037be:	83 c4 10             	add    $0x10,%esp
}
f01037c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01037c4:	5b                   	pop    %ebx
f01037c5:	5e                   	pop    %esi
f01037c6:	5d                   	pop    %ebp
f01037c7:	c3                   	ret    

f01037c8 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f01037c8:	c6 05 50 b2 22 f0 01 	movb   $0x1,0xf022b250
f01037cf:	ba 21 00 00 00       	mov    $0x21,%edx
f01037d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01037d9:	ee                   	out    %al,(%dx)
f01037da:	ba a1 00 00 00       	mov    $0xa1,%edx
f01037df:	ee                   	out    %al,(%dx)
f01037e0:	ba 20 00 00 00       	mov    $0x20,%edx
f01037e5:	b8 11 00 00 00       	mov    $0x11,%eax
f01037ea:	ee                   	out    %al,(%dx)
f01037eb:	ba 21 00 00 00       	mov    $0x21,%edx
f01037f0:	b8 20 00 00 00       	mov    $0x20,%eax
f01037f5:	ee                   	out    %al,(%dx)
f01037f6:	b8 04 00 00 00       	mov    $0x4,%eax
f01037fb:	ee                   	out    %al,(%dx)
f01037fc:	b8 03 00 00 00       	mov    $0x3,%eax
f0103801:	ee                   	out    %al,(%dx)
f0103802:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103807:	b8 11 00 00 00       	mov    $0x11,%eax
f010380c:	ee                   	out    %al,(%dx)
f010380d:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103812:	b8 28 00 00 00       	mov    $0x28,%eax
f0103817:	ee                   	out    %al,(%dx)
f0103818:	b8 02 00 00 00       	mov    $0x2,%eax
f010381d:	ee                   	out    %al,(%dx)
f010381e:	b8 01 00 00 00       	mov    $0x1,%eax
f0103823:	ee                   	out    %al,(%dx)
f0103824:	ba 20 00 00 00       	mov    $0x20,%edx
f0103829:	b8 68 00 00 00       	mov    $0x68,%eax
f010382e:	ee                   	out    %al,(%dx)
f010382f:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103834:	ee                   	out    %al,(%dx)
f0103835:	ba a0 00 00 00       	mov    $0xa0,%edx
f010383a:	b8 68 00 00 00       	mov    $0x68,%eax
f010383f:	ee                   	out    %al,(%dx)
f0103840:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103845:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103846:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f010384d:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103851:	74 13                	je     f0103866 <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103853:	55                   	push   %ebp
f0103854:	89 e5                	mov    %esp,%ebp
f0103856:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0103859:	0f b7 c0             	movzwl %ax,%eax
f010385c:	50                   	push   %eax
f010385d:	e8 ee fe ff ff       	call   f0103750 <irq_setmask_8259A>
f0103862:	83 c4 10             	add    $0x10,%esp
}
f0103865:	c9                   	leave  
f0103866:	f3 c3                	repz ret 

f0103868 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103868:	55                   	push   %ebp
f0103869:	89 e5                	mov    %esp,%ebp
f010386b:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f010386e:	ff 75 08             	pushl  0x8(%ebp)
f0103871:	e8 d7 ce ff ff       	call   f010074d <cputchar>
	*cnt++;
}
f0103876:	83 c4 10             	add    $0x10,%esp
f0103879:	c9                   	leave  
f010387a:	c3                   	ret    

f010387b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010387b:	55                   	push   %ebp
f010387c:	89 e5                	mov    %esp,%ebp
f010387e:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103881:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103888:	ff 75 0c             	pushl  0xc(%ebp)
f010388b:	ff 75 08             	pushl  0x8(%ebp)
f010388e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103891:	50                   	push   %eax
f0103892:	68 68 38 10 f0       	push   $0xf0103868
f0103897:	e8 1c 14 00 00       	call   f0104cb8 <vprintfmt>
	return cnt;
}
f010389c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010389f:	c9                   	leave  
f01038a0:	c3                   	ret    

f01038a1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01038a1:	55                   	push   %ebp
f01038a2:	89 e5                	mov    %esp,%ebp
f01038a4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01038a7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01038aa:	50                   	push   %eax
f01038ab:	ff 75 08             	pushl  0x8(%ebp)
f01038ae:	e8 c8 ff ff ff       	call   f010387b <vcprintf>
	va_end(ap);

	return cnt;
}
f01038b3:	c9                   	leave  
f01038b4:	c3                   	ret    

f01038b5 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f01038b5:	55                   	push   %ebp
f01038b6:	89 e5                	mov    %esp,%ebp
f01038b8:	57                   	push   %edi
f01038b9:	56                   	push   %esi
f01038ba:	53                   	push   %ebx
f01038bb:	83 ec 0c             	sub    $0xc,%esp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP;
f01038be:	e8 83 20 00 00       	call   f0105946 <cpunum>
f01038c3:	6b c0 74             	imul   $0x74,%eax,%eax
f01038c6:	c7 80 30 c0 22 f0 00 	movl   $0xf0000000,-0xfdd3fd0(%eax)
f01038cd:	00 00 f0 
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f01038d0:	e8 71 20 00 00       	call   f0105946 <cpunum>
f01038d5:	6b c0 74             	imul   $0x74,%eax,%eax
f01038d8:	66 c7 80 34 c0 22 f0 	movw   $0x10,-0xfdd3fcc(%eax)
f01038df:	10 00 
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f01038e1:	e8 60 20 00 00       	call   f0105946 <cpunum>
f01038e6:	6b c0 74             	imul   $0x74,%eax,%eax
f01038e9:	66 c7 80 92 c0 22 f0 	movw   $0x68,-0xfdd3f6e(%eax)
f01038f0:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + cpunum()] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
f01038f2:	e8 4f 20 00 00       	call   f0105946 <cpunum>
f01038f7:	8d 58 05             	lea    0x5(%eax),%ebx
f01038fa:	e8 47 20 00 00       	call   f0105946 <cpunum>
f01038ff:	89 c7                	mov    %eax,%edi
f0103901:	e8 40 20 00 00       	call   f0105946 <cpunum>
f0103906:	89 c6                	mov    %eax,%esi
f0103908:	e8 39 20 00 00       	call   f0105946 <cpunum>
f010390d:	66 c7 04 dd 40 03 12 	movw   $0x67,-0xfedfcc0(,%ebx,8)
f0103914:	f0 67 00 
f0103917:	6b ff 74             	imul   $0x74,%edi,%edi
f010391a:	81 c7 2c c0 22 f0    	add    $0xf022c02c,%edi
f0103920:	66 89 3c dd 42 03 12 	mov    %di,-0xfedfcbe(,%ebx,8)
f0103927:	f0 
f0103928:	6b d6 74             	imul   $0x74,%esi,%edx
f010392b:	81 c2 2c c0 22 f0    	add    $0xf022c02c,%edx
f0103931:	c1 ea 10             	shr    $0x10,%edx
f0103934:	88 14 dd 44 03 12 f0 	mov    %dl,-0xfedfcbc(,%ebx,8)
f010393b:	c6 04 dd 45 03 12 f0 	movb   $0x99,-0xfedfcbb(,%ebx,8)
f0103942:	99 
f0103943:	c6 04 dd 46 03 12 f0 	movb   $0x40,-0xfedfcba(,%ebx,8)
f010394a:	40 
f010394b:	6b c0 74             	imul   $0x74,%eax,%eax
f010394e:	05 2c c0 22 f0       	add    $0xf022c02c,%eax
f0103953:	c1 e8 18             	shr    $0x18,%eax
f0103956:	88 04 dd 47 03 12 f0 	mov    %al,-0xfedfcb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + cpunum()].sd_s = 0;
f010395d:	e8 e4 1f 00 00       	call   f0105946 <cpunum>
f0103962:	80 24 c5 6d 03 12 f0 	andb   $0xef,-0xfedfc93(,%eax,8)
f0103969:	ef 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + (cpunum() << 3));
f010396a:	e8 d7 1f 00 00       	call   f0105946 <cpunum>
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f010396f:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
f0103976:	0f 00 d8             	ltr    %ax
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f0103979:	b8 ac 03 12 f0       	mov    $0xf01203ac,%eax
f010397e:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f0103981:	83 c4 0c             	add    $0xc,%esp
f0103984:	5b                   	pop    %ebx
f0103985:	5e                   	pop    %esi
f0103986:	5f                   	pop    %edi
f0103987:	5d                   	pop    %ebp
f0103988:	c3                   	ret    

f0103989 <trap_init>:
}


void
trap_init(void)
{
f0103989:	55                   	push   %ebp
f010398a:	89 e5                	mov    %esp,%ebp
f010398c:	83 ec 08             	sub    $0x8,%esp
	void _T_MCHK_handler();
	void _T_SIMDERR_handler();
	void _T_SYSCALL_handler();

	// SETGATE(gate, istrap, sel, off, dpl);
	SETGATE(idt[T_DIVIDE], 0, GD_KT, _T_DIVIDE_handler, 0);
f010398f:	b8 02 42 10 f0       	mov    $0xf0104202,%eax
f0103994:	66 a3 60 b2 22 f0    	mov    %ax,0xf022b260
f010399a:	66 c7 05 62 b2 22 f0 	movw   $0x8,0xf022b262
f01039a1:	08 00 
f01039a3:	c6 05 64 b2 22 f0 00 	movb   $0x0,0xf022b264
f01039aa:	c6 05 65 b2 22 f0 8e 	movb   $0x8e,0xf022b265
f01039b1:	c1 e8 10             	shr    $0x10,%eax
f01039b4:	66 a3 66 b2 22 f0    	mov    %ax,0xf022b266
	SETGATE(idt[T_DEBUG], 0, GD_KT, _T_DEBUG_handler, 0);
f01039ba:	b8 08 42 10 f0       	mov    $0xf0104208,%eax
f01039bf:	66 a3 68 b2 22 f0    	mov    %ax,0xf022b268
f01039c5:	66 c7 05 6a b2 22 f0 	movw   $0x8,0xf022b26a
f01039cc:	08 00 
f01039ce:	c6 05 6c b2 22 f0 00 	movb   $0x0,0xf022b26c
f01039d5:	c6 05 6d b2 22 f0 8e 	movb   $0x8e,0xf022b26d
f01039dc:	c1 e8 10             	shr    $0x10,%eax
f01039df:	66 a3 6e b2 22 f0    	mov    %ax,0xf022b26e
	SETGATE(idt[T_NMI], 0, GD_KT, _T_NMI_handler, 0);
f01039e5:	b8 0e 42 10 f0       	mov    $0xf010420e,%eax
f01039ea:	66 a3 70 b2 22 f0    	mov    %ax,0xf022b270
f01039f0:	66 c7 05 72 b2 22 f0 	movw   $0x8,0xf022b272
f01039f7:	08 00 
f01039f9:	c6 05 74 b2 22 f0 00 	movb   $0x0,0xf022b274
f0103a00:	c6 05 75 b2 22 f0 8e 	movb   $0x8e,0xf022b275
f0103a07:	c1 e8 10             	shr    $0x10,%eax
f0103a0a:	66 a3 76 b2 22 f0    	mov    %ax,0xf022b276
	SETGATE(idt[T_BRKPT], 0, GD_KT, _T_BRKPT_handler, 3);
f0103a10:	b8 14 42 10 f0       	mov    $0xf0104214,%eax
f0103a15:	66 a3 78 b2 22 f0    	mov    %ax,0xf022b278
f0103a1b:	66 c7 05 7a b2 22 f0 	movw   $0x8,0xf022b27a
f0103a22:	08 00 
f0103a24:	c6 05 7c b2 22 f0 00 	movb   $0x0,0xf022b27c
f0103a2b:	c6 05 7d b2 22 f0 ee 	movb   $0xee,0xf022b27d
f0103a32:	c1 e8 10             	shr    $0x10,%eax
f0103a35:	66 a3 7e b2 22 f0    	mov    %ax,0xf022b27e
	SETGATE(idt[T_OFLOW], 0, GD_KT, _T_OFLOW_handler, 0);
f0103a3b:	b8 1a 42 10 f0       	mov    $0xf010421a,%eax
f0103a40:	66 a3 80 b2 22 f0    	mov    %ax,0xf022b280
f0103a46:	66 c7 05 82 b2 22 f0 	movw   $0x8,0xf022b282
f0103a4d:	08 00 
f0103a4f:	c6 05 84 b2 22 f0 00 	movb   $0x0,0xf022b284
f0103a56:	c6 05 85 b2 22 f0 8e 	movb   $0x8e,0xf022b285
f0103a5d:	c1 e8 10             	shr    $0x10,%eax
f0103a60:	66 a3 86 b2 22 f0    	mov    %ax,0xf022b286
	SETGATE(idt[T_BOUND], 0, GD_KT, _T_BOUND_handler, 0);
f0103a66:	b8 20 42 10 f0       	mov    $0xf0104220,%eax
f0103a6b:	66 a3 88 b2 22 f0    	mov    %ax,0xf022b288
f0103a71:	66 c7 05 8a b2 22 f0 	movw   $0x8,0xf022b28a
f0103a78:	08 00 
f0103a7a:	c6 05 8c b2 22 f0 00 	movb   $0x0,0xf022b28c
f0103a81:	c6 05 8d b2 22 f0 8e 	movb   $0x8e,0xf022b28d
f0103a88:	c1 e8 10             	shr    $0x10,%eax
f0103a8b:	66 a3 8e b2 22 f0    	mov    %ax,0xf022b28e
	SETGATE(idt[T_ILLOP], 0, GD_KT, _T_ILLOP_handler, 0);
f0103a91:	b8 26 42 10 f0       	mov    $0xf0104226,%eax
f0103a96:	66 a3 90 b2 22 f0    	mov    %ax,0xf022b290
f0103a9c:	66 c7 05 92 b2 22 f0 	movw   $0x8,0xf022b292
f0103aa3:	08 00 
f0103aa5:	c6 05 94 b2 22 f0 00 	movb   $0x0,0xf022b294
f0103aac:	c6 05 95 b2 22 f0 8e 	movb   $0x8e,0xf022b295
f0103ab3:	c1 e8 10             	shr    $0x10,%eax
f0103ab6:	66 a3 96 b2 22 f0    	mov    %ax,0xf022b296
	SETGATE(idt[T_DEVICE], 0, GD_KT, _T_DEVICE_handler, 0);
f0103abc:	b8 2c 42 10 f0       	mov    $0xf010422c,%eax
f0103ac1:	66 a3 98 b2 22 f0    	mov    %ax,0xf022b298
f0103ac7:	66 c7 05 9a b2 22 f0 	movw   $0x8,0xf022b29a
f0103ace:	08 00 
f0103ad0:	c6 05 9c b2 22 f0 00 	movb   $0x0,0xf022b29c
f0103ad7:	c6 05 9d b2 22 f0 8e 	movb   $0x8e,0xf022b29d
f0103ade:	c1 e8 10             	shr    $0x10,%eax
f0103ae1:	66 a3 9e b2 22 f0    	mov    %ax,0xf022b29e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, _T_DBLFLT_handler, 0);
f0103ae7:	b8 32 42 10 f0       	mov    $0xf0104232,%eax
f0103aec:	66 a3 a0 b2 22 f0    	mov    %ax,0xf022b2a0
f0103af2:	66 c7 05 a2 b2 22 f0 	movw   $0x8,0xf022b2a2
f0103af9:	08 00 
f0103afb:	c6 05 a4 b2 22 f0 00 	movb   $0x0,0xf022b2a4
f0103b02:	c6 05 a5 b2 22 f0 8e 	movb   $0x8e,0xf022b2a5
f0103b09:	c1 e8 10             	shr    $0x10,%eax
f0103b0c:	66 a3 a6 b2 22 f0    	mov    %ax,0xf022b2a6
	SETGATE(idt[T_TSS], 0, GD_KT, _T_TSS_handler, 0);
f0103b12:	b8 36 42 10 f0       	mov    $0xf0104236,%eax
f0103b17:	66 a3 b0 b2 22 f0    	mov    %ax,0xf022b2b0
f0103b1d:	66 c7 05 b2 b2 22 f0 	movw   $0x8,0xf022b2b2
f0103b24:	08 00 
f0103b26:	c6 05 b4 b2 22 f0 00 	movb   $0x0,0xf022b2b4
f0103b2d:	c6 05 b5 b2 22 f0 8e 	movb   $0x8e,0xf022b2b5
f0103b34:	c1 e8 10             	shr    $0x10,%eax
f0103b37:	66 a3 b6 b2 22 f0    	mov    %ax,0xf022b2b6
	SETGATE(idt[T_SEGNP], 0, GD_KT, _T_SEGNP_handler, 0);
f0103b3d:	b8 3a 42 10 f0       	mov    $0xf010423a,%eax
f0103b42:	66 a3 b8 b2 22 f0    	mov    %ax,0xf022b2b8
f0103b48:	66 c7 05 ba b2 22 f0 	movw   $0x8,0xf022b2ba
f0103b4f:	08 00 
f0103b51:	c6 05 bc b2 22 f0 00 	movb   $0x0,0xf022b2bc
f0103b58:	c6 05 bd b2 22 f0 8e 	movb   $0x8e,0xf022b2bd
f0103b5f:	c1 e8 10             	shr    $0x10,%eax
f0103b62:	66 a3 be b2 22 f0    	mov    %ax,0xf022b2be
	SETGATE(idt[T_STACK], 0, GD_KT, _T_STACK_handler, 0);
f0103b68:	b8 3e 42 10 f0       	mov    $0xf010423e,%eax
f0103b6d:	66 a3 c0 b2 22 f0    	mov    %ax,0xf022b2c0
f0103b73:	66 c7 05 c2 b2 22 f0 	movw   $0x8,0xf022b2c2
f0103b7a:	08 00 
f0103b7c:	c6 05 c4 b2 22 f0 00 	movb   $0x0,0xf022b2c4
f0103b83:	c6 05 c5 b2 22 f0 8e 	movb   $0x8e,0xf022b2c5
f0103b8a:	c1 e8 10             	shr    $0x10,%eax
f0103b8d:	66 a3 c6 b2 22 f0    	mov    %ax,0xf022b2c6
	SETGATE(idt[T_GPFLT], 0, GD_KT, _T_GPFLT_handler, 0);
f0103b93:	b8 42 42 10 f0       	mov    $0xf0104242,%eax
f0103b98:	66 a3 c8 b2 22 f0    	mov    %ax,0xf022b2c8
f0103b9e:	66 c7 05 ca b2 22 f0 	movw   $0x8,0xf022b2ca
f0103ba5:	08 00 
f0103ba7:	c6 05 cc b2 22 f0 00 	movb   $0x0,0xf022b2cc
f0103bae:	c6 05 cd b2 22 f0 8e 	movb   $0x8e,0xf022b2cd
f0103bb5:	c1 e8 10             	shr    $0x10,%eax
f0103bb8:	66 a3 ce b2 22 f0    	mov    %ax,0xf022b2ce
	SETGATE(idt[T_PGFLT], 0, GD_KT, _T_PGFLT_handler, 0);
f0103bbe:	b8 46 42 10 f0       	mov    $0xf0104246,%eax
f0103bc3:	66 a3 d0 b2 22 f0    	mov    %ax,0xf022b2d0
f0103bc9:	66 c7 05 d2 b2 22 f0 	movw   $0x8,0xf022b2d2
f0103bd0:	08 00 
f0103bd2:	c6 05 d4 b2 22 f0 00 	movb   $0x0,0xf022b2d4
f0103bd9:	c6 05 d5 b2 22 f0 8e 	movb   $0x8e,0xf022b2d5
f0103be0:	c1 e8 10             	shr    $0x10,%eax
f0103be3:	66 a3 d6 b2 22 f0    	mov    %ax,0xf022b2d6
	SETGATE(idt[T_FPERR], 0, GD_KT, _T_FPERR_handler, 0);
f0103be9:	b8 4a 42 10 f0       	mov    $0xf010424a,%eax
f0103bee:	66 a3 e0 b2 22 f0    	mov    %ax,0xf022b2e0
f0103bf4:	66 c7 05 e2 b2 22 f0 	movw   $0x8,0xf022b2e2
f0103bfb:	08 00 
f0103bfd:	c6 05 e4 b2 22 f0 00 	movb   $0x0,0xf022b2e4
f0103c04:	c6 05 e5 b2 22 f0 8e 	movb   $0x8e,0xf022b2e5
f0103c0b:	c1 e8 10             	shr    $0x10,%eax
f0103c0e:	66 a3 e6 b2 22 f0    	mov    %ax,0xf022b2e6
	SETGATE(idt[T_ALIGN], 0, GD_KT, _T_ALIGN_handler, 0);
f0103c14:	b8 50 42 10 f0       	mov    $0xf0104250,%eax
f0103c19:	66 a3 e8 b2 22 f0    	mov    %ax,0xf022b2e8
f0103c1f:	66 c7 05 ea b2 22 f0 	movw   $0x8,0xf022b2ea
f0103c26:	08 00 
f0103c28:	c6 05 ec b2 22 f0 00 	movb   $0x0,0xf022b2ec
f0103c2f:	c6 05 ed b2 22 f0 8e 	movb   $0x8e,0xf022b2ed
f0103c36:	c1 e8 10             	shr    $0x10,%eax
f0103c39:	66 a3 ee b2 22 f0    	mov    %ax,0xf022b2ee
	SETGATE(idt[T_MCHK], 0, GD_KT, _T_MCHK_handler, 0);
f0103c3f:	b8 54 42 10 f0       	mov    $0xf0104254,%eax
f0103c44:	66 a3 f0 b2 22 f0    	mov    %ax,0xf022b2f0
f0103c4a:	66 c7 05 f2 b2 22 f0 	movw   $0x8,0xf022b2f2
f0103c51:	08 00 
f0103c53:	c6 05 f4 b2 22 f0 00 	movb   $0x0,0xf022b2f4
f0103c5a:	c6 05 f5 b2 22 f0 8e 	movb   $0x8e,0xf022b2f5
f0103c61:	c1 e8 10             	shr    $0x10,%eax
f0103c64:	66 a3 f6 b2 22 f0    	mov    %ax,0xf022b2f6
	SETGATE(idt[T_SIMDERR], 0, GD_KT, _T_SIMDERR_handler, 0);
f0103c6a:	b8 5a 42 10 f0       	mov    $0xf010425a,%eax
f0103c6f:	66 a3 f8 b2 22 f0    	mov    %ax,0xf022b2f8
f0103c75:	66 c7 05 fa b2 22 f0 	movw   $0x8,0xf022b2fa
f0103c7c:	08 00 
f0103c7e:	c6 05 fc b2 22 f0 00 	movb   $0x0,0xf022b2fc
f0103c85:	c6 05 fd b2 22 f0 8e 	movb   $0x8e,0xf022b2fd
f0103c8c:	c1 e8 10             	shr    $0x10,%eax
f0103c8f:	66 a3 fe b2 22 f0    	mov    %ax,0xf022b2fe
	SETGATE(idt[T_SYSCALL], 0, GD_KT, _T_SYSCALL_handler, 3);
f0103c95:	b8 60 42 10 f0       	mov    $0xf0104260,%eax
f0103c9a:	66 a3 e0 b3 22 f0    	mov    %ax,0xf022b3e0
f0103ca0:	66 c7 05 e2 b3 22 f0 	movw   $0x8,0xf022b3e2
f0103ca7:	08 00 
f0103ca9:	c6 05 e4 b3 22 f0 00 	movb   $0x0,0xf022b3e4
f0103cb0:	c6 05 e5 b3 22 f0 ee 	movb   $0xee,0xf022b3e5
f0103cb7:	c1 e8 10             	shr    $0x10,%eax
f0103cba:	66 a3 e6 b3 22 f0    	mov    %ax,0xf022b3e6

	// Per-CPU setup 
	trap_init_percpu();
f0103cc0:	e8 f0 fb ff ff       	call   f01038b5 <trap_init_percpu>
}
f0103cc5:	c9                   	leave  
f0103cc6:	c3                   	ret    

f0103cc7 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103cc7:	55                   	push   %ebp
f0103cc8:	89 e5                	mov    %esp,%ebp
f0103cca:	53                   	push   %ebx
f0103ccb:	83 ec 0c             	sub    $0xc,%esp
f0103cce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103cd1:	ff 33                	pushl  (%ebx)
f0103cd3:	68 52 74 10 f0       	push   $0xf0107452
f0103cd8:	e8 c4 fb ff ff       	call   f01038a1 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103cdd:	83 c4 08             	add    $0x8,%esp
f0103ce0:	ff 73 04             	pushl  0x4(%ebx)
f0103ce3:	68 61 74 10 f0       	push   $0xf0107461
f0103ce8:	e8 b4 fb ff ff       	call   f01038a1 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103ced:	83 c4 08             	add    $0x8,%esp
f0103cf0:	ff 73 08             	pushl  0x8(%ebx)
f0103cf3:	68 70 74 10 f0       	push   $0xf0107470
f0103cf8:	e8 a4 fb ff ff       	call   f01038a1 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103cfd:	83 c4 08             	add    $0x8,%esp
f0103d00:	ff 73 0c             	pushl  0xc(%ebx)
f0103d03:	68 7f 74 10 f0       	push   $0xf010747f
f0103d08:	e8 94 fb ff ff       	call   f01038a1 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103d0d:	83 c4 08             	add    $0x8,%esp
f0103d10:	ff 73 10             	pushl  0x10(%ebx)
f0103d13:	68 8e 74 10 f0       	push   $0xf010748e
f0103d18:	e8 84 fb ff ff       	call   f01038a1 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103d1d:	83 c4 08             	add    $0x8,%esp
f0103d20:	ff 73 14             	pushl  0x14(%ebx)
f0103d23:	68 9d 74 10 f0       	push   $0xf010749d
f0103d28:	e8 74 fb ff ff       	call   f01038a1 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103d2d:	83 c4 08             	add    $0x8,%esp
f0103d30:	ff 73 18             	pushl  0x18(%ebx)
f0103d33:	68 ac 74 10 f0       	push   $0xf01074ac
f0103d38:	e8 64 fb ff ff       	call   f01038a1 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103d3d:	83 c4 08             	add    $0x8,%esp
f0103d40:	ff 73 1c             	pushl  0x1c(%ebx)
f0103d43:	68 bb 74 10 f0       	push   $0xf01074bb
f0103d48:	e8 54 fb ff ff       	call   f01038a1 <cprintf>
}
f0103d4d:	83 c4 10             	add    $0x10,%esp
f0103d50:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103d53:	c9                   	leave  
f0103d54:	c3                   	ret    

f0103d55 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103d55:	55                   	push   %ebp
f0103d56:	89 e5                	mov    %esp,%ebp
f0103d58:	56                   	push   %esi
f0103d59:	53                   	push   %ebx
f0103d5a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103d5d:	e8 e4 1b 00 00       	call   f0105946 <cpunum>
f0103d62:	83 ec 04             	sub    $0x4,%esp
f0103d65:	50                   	push   %eax
f0103d66:	53                   	push   %ebx
f0103d67:	68 1f 75 10 f0       	push   $0xf010751f
f0103d6c:	e8 30 fb ff ff       	call   f01038a1 <cprintf>
	print_regs(&tf->tf_regs);
f0103d71:	89 1c 24             	mov    %ebx,(%esp)
f0103d74:	e8 4e ff ff ff       	call   f0103cc7 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103d79:	83 c4 08             	add    $0x8,%esp
f0103d7c:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103d80:	50                   	push   %eax
f0103d81:	68 3d 75 10 f0       	push   $0xf010753d
f0103d86:	e8 16 fb ff ff       	call   f01038a1 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103d8b:	83 c4 08             	add    $0x8,%esp
f0103d8e:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103d92:	50                   	push   %eax
f0103d93:	68 50 75 10 f0       	push   $0xf0107550
f0103d98:	e8 04 fb ff ff       	call   f01038a1 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103d9d:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f0103da0:	83 c4 10             	add    $0x10,%esp
f0103da3:	83 f8 13             	cmp    $0x13,%eax
f0103da6:	77 09                	ja     f0103db1 <print_trapframe+0x5c>
		return excnames[trapno];
f0103da8:	8b 14 85 c0 77 10 f0 	mov    -0xfef8840(,%eax,4),%edx
f0103daf:	eb 1f                	jmp    f0103dd0 <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f0103db1:	83 f8 30             	cmp    $0x30,%eax
f0103db4:	74 15                	je     f0103dcb <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103db6:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f0103db9:	83 fa 10             	cmp    $0x10,%edx
f0103dbc:	b9 e9 74 10 f0       	mov    $0xf01074e9,%ecx
f0103dc1:	ba d6 74 10 f0       	mov    $0xf01074d6,%edx
f0103dc6:	0f 43 d1             	cmovae %ecx,%edx
f0103dc9:	eb 05                	jmp    f0103dd0 <print_trapframe+0x7b>
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0103dcb:	ba ca 74 10 f0       	mov    $0xf01074ca,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103dd0:	83 ec 04             	sub    $0x4,%esp
f0103dd3:	52                   	push   %edx
f0103dd4:	50                   	push   %eax
f0103dd5:	68 63 75 10 f0       	push   $0xf0107563
f0103dda:	e8 c2 fa ff ff       	call   f01038a1 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103ddf:	83 c4 10             	add    $0x10,%esp
f0103de2:	3b 1d 60 ba 22 f0    	cmp    0xf022ba60,%ebx
f0103de8:	75 1a                	jne    f0103e04 <print_trapframe+0xaf>
f0103dea:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103dee:	75 14                	jne    f0103e04 <print_trapframe+0xaf>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103df0:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103df3:	83 ec 08             	sub    $0x8,%esp
f0103df6:	50                   	push   %eax
f0103df7:	68 75 75 10 f0       	push   $0xf0107575
f0103dfc:	e8 a0 fa ff ff       	call   f01038a1 <cprintf>
f0103e01:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103e04:	83 ec 08             	sub    $0x8,%esp
f0103e07:	ff 73 2c             	pushl  0x2c(%ebx)
f0103e0a:	68 84 75 10 f0       	push   $0xf0107584
f0103e0f:	e8 8d fa ff ff       	call   f01038a1 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103e14:	83 c4 10             	add    $0x10,%esp
f0103e17:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103e1b:	75 49                	jne    f0103e66 <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103e1d:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103e20:	89 c2                	mov    %eax,%edx
f0103e22:	83 e2 01             	and    $0x1,%edx
f0103e25:	ba 03 75 10 f0       	mov    $0xf0107503,%edx
f0103e2a:	b9 f8 74 10 f0       	mov    $0xf01074f8,%ecx
f0103e2f:	0f 44 ca             	cmove  %edx,%ecx
f0103e32:	89 c2                	mov    %eax,%edx
f0103e34:	83 e2 02             	and    $0x2,%edx
f0103e37:	ba 15 75 10 f0       	mov    $0xf0107515,%edx
f0103e3c:	be 0f 75 10 f0       	mov    $0xf010750f,%esi
f0103e41:	0f 45 d6             	cmovne %esi,%edx
f0103e44:	83 e0 04             	and    $0x4,%eax
f0103e47:	be 4e 76 10 f0       	mov    $0xf010764e,%esi
f0103e4c:	b8 1a 75 10 f0       	mov    $0xf010751a,%eax
f0103e51:	0f 44 c6             	cmove  %esi,%eax
f0103e54:	51                   	push   %ecx
f0103e55:	52                   	push   %edx
f0103e56:	50                   	push   %eax
f0103e57:	68 92 75 10 f0       	push   $0xf0107592
f0103e5c:	e8 40 fa ff ff       	call   f01038a1 <cprintf>
f0103e61:	83 c4 10             	add    $0x10,%esp
f0103e64:	eb 10                	jmp    f0103e76 <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103e66:	83 ec 0c             	sub    $0xc,%esp
f0103e69:	68 c0 68 10 f0       	push   $0xf01068c0
f0103e6e:	e8 2e fa ff ff       	call   f01038a1 <cprintf>
f0103e73:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103e76:	83 ec 08             	sub    $0x8,%esp
f0103e79:	ff 73 30             	pushl  0x30(%ebx)
f0103e7c:	68 a1 75 10 f0       	push   $0xf01075a1
f0103e81:	e8 1b fa ff ff       	call   f01038a1 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103e86:	83 c4 08             	add    $0x8,%esp
f0103e89:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103e8d:	50                   	push   %eax
f0103e8e:	68 b0 75 10 f0       	push   $0xf01075b0
f0103e93:	e8 09 fa ff ff       	call   f01038a1 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103e98:	83 c4 08             	add    $0x8,%esp
f0103e9b:	ff 73 38             	pushl  0x38(%ebx)
f0103e9e:	68 c3 75 10 f0       	push   $0xf01075c3
f0103ea3:	e8 f9 f9 ff ff       	call   f01038a1 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103ea8:	83 c4 10             	add    $0x10,%esp
f0103eab:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103eaf:	74 25                	je     f0103ed6 <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103eb1:	83 ec 08             	sub    $0x8,%esp
f0103eb4:	ff 73 3c             	pushl  0x3c(%ebx)
f0103eb7:	68 d2 75 10 f0       	push   $0xf01075d2
f0103ebc:	e8 e0 f9 ff ff       	call   f01038a1 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103ec1:	83 c4 08             	add    $0x8,%esp
f0103ec4:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103ec8:	50                   	push   %eax
f0103ec9:	68 e1 75 10 f0       	push   $0xf01075e1
f0103ece:	e8 ce f9 ff ff       	call   f01038a1 <cprintf>
f0103ed3:	83 c4 10             	add    $0x10,%esp
	}
}
f0103ed6:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103ed9:	5b                   	pop    %ebx
f0103eda:	5e                   	pop    %esi
f0103edb:	5d                   	pop    %ebp
f0103edc:	c3                   	ret    

f0103edd <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103edd:	55                   	push   %ebp
f0103ede:	89 e5                	mov    %esp,%ebp
f0103ee0:	57                   	push   %edi
f0103ee1:	56                   	push   %esi
f0103ee2:	53                   	push   %ebx
f0103ee3:	83 ec 1c             	sub    $0x1c,%esp
f0103ee6:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103ee9:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) == 0)
f0103eec:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103ef0:	75 15                	jne    f0103f07 <page_fault_handler+0x2a>
		panic("page fault in kernel at %x!", fault_va);
f0103ef2:	56                   	push   %esi
f0103ef3:	68 f4 75 10 f0       	push   $0xf01075f4
f0103ef8:	68 42 01 00 00       	push   $0x142
f0103efd:	68 10 76 10 f0       	push   $0xf0107610
f0103f02:	e8 39 c1 ff ff       	call   f0100040 <_panic>
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	if (curenv->env_pgfault_upcall) {
f0103f07:	e8 3a 1a 00 00       	call   f0105946 <cpunum>
f0103f0c:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f0f:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103f15:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0103f19:	0f 84 af 00 00 00    	je     f0103fce <page_fault_handler+0xf1>
		uint32_t estack_top = UXSTACKTOP;

		// if pgfault happens in user exception stack
		// as mentioned above, we push things right after the previous exception stack 
		// started with dummy 4 bytes
		if (tf->tf_esp < UXSTACKTOP && tf->tf_esp >= UXSTACKTOP - PGSIZE)
f0103f1f:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103f22:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			estack_top = tf->tf_esp - 4;
f0103f28:	83 e8 04             	sub    $0x4,%eax
f0103f2b:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0103f31:	bf 00 00 c0 ee       	mov    $0xeec00000,%edi
f0103f36:	0f 46 f8             	cmovbe %eax,%edi

		// char* utrapframe = (char *)(estack_top - sizeof(struct UTrapframe));
		struct UTrapframe *utf = (struct UTrapframe *)(estack_top - sizeof(struct UTrapframe));
f0103f39:	8d 47 cc             	lea    -0x34(%edi),%eax
f0103f3c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// do a memory check
		user_mem_assert(curenv, (void *)utf, sizeof(struct UTrapframe), PTE_W | PTE_P);
f0103f3f:	e8 02 1a 00 00       	call   f0105946 <cpunum>
f0103f44:	6a 03                	push   $0x3
f0103f46:	6a 34                	push   $0x34
f0103f48:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103f4b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f4e:	ff b0 28 c0 22 f0    	pushl  -0xfdd3fd8(%eax)
f0103f54:	e8 c6 ef ff ff       	call   f0102f1f <user_mem_assert>

		// copy context to utrapframe 
		// memcpy(utrapframe, (char *)tf, sizeof(struct UTrapframe));
		// *(uint32_t *)utrapframe = fault_va;
		utf->utf_fault_va = fault_va;
f0103f59:	89 77 cc             	mov    %esi,-0x34(%edi)
        utf->utf_err      = tf->tf_trapno;
f0103f5c:	8b 43 28             	mov    0x28(%ebx),%eax
f0103f5f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103f62:	89 42 04             	mov    %eax,0x4(%edx)
        utf->utf_regs     = tf->tf_regs;
f0103f65:	83 ef 2c             	sub    $0x2c,%edi
f0103f68:	b9 08 00 00 00       	mov    $0x8,%ecx
f0103f6d:	89 de                	mov    %ebx,%esi
f0103f6f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
        utf->utf_eflags   = tf->tf_eflags;
f0103f71:	8b 43 38             	mov    0x38(%ebx),%eax
f0103f74:	89 42 2c             	mov    %eax,0x2c(%edx)
        utf->utf_eip      = tf->tf_eip;
f0103f77:	8b 43 30             	mov    0x30(%ebx),%eax
f0103f7a:	89 d6                	mov    %edx,%esi
f0103f7c:	89 42 28             	mov    %eax,0x28(%edx)
        utf->utf_esp      = tf->tf_esp;
f0103f7f:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103f82:	89 42 30             	mov    %eax,0x30(%edx)

		curenv->env_tf.tf_esp = (uint32_t)utf;
f0103f85:	e8 bc 19 00 00       	call   f0105946 <cpunum>
f0103f8a:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f8d:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103f93:	89 70 3c             	mov    %esi,0x3c(%eax)
		curenv->env_tf.tf_eip = (uint32_t)curenv->env_pgfault_upcall;
f0103f96:	e8 ab 19 00 00       	call   f0105946 <cpunum>
f0103f9b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f9e:	8b 98 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%ebx
f0103fa4:	e8 9d 19 00 00       	call   f0105946 <cpunum>
f0103fa9:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fac:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103fb2:	8b 40 64             	mov    0x64(%eax),%eax
f0103fb5:	89 43 30             	mov    %eax,0x30(%ebx)
		env_run(curenv);
f0103fb8:	e8 89 19 00 00       	call   f0105946 <cpunum>
f0103fbd:	83 c4 04             	add    $0x4,%esp
f0103fc0:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fc3:	ff b0 28 c0 22 f0    	pushl  -0xfdd3fd8(%eax)
f0103fc9:	e8 71 f6 ff ff       	call   f010363f <env_run>

	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103fce:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f0103fd1:	e8 70 19 00 00       	call   f0105946 <cpunum>
		env_run(curenv);

	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103fd6:	57                   	push   %edi
f0103fd7:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f0103fd8:	6b c0 74             	imul   $0x74,%eax,%eax
		env_run(curenv);

	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103fdb:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103fe1:	ff 70 48             	pushl  0x48(%eax)
f0103fe4:	68 98 77 10 f0       	push   $0xf0107798
f0103fe9:	e8 b3 f8 ff ff       	call   f01038a1 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103fee:	89 1c 24             	mov    %ebx,(%esp)
f0103ff1:	e8 5f fd ff ff       	call   f0103d55 <print_trapframe>
	env_destroy(curenv);
f0103ff6:	e8 4b 19 00 00       	call   f0105946 <cpunum>
f0103ffb:	83 c4 04             	add    $0x4,%esp
f0103ffe:	6b c0 74             	imul   $0x74,%eax,%eax
f0104001:	ff b0 28 c0 22 f0    	pushl  -0xfdd3fd8(%eax)
f0104007:	e8 94 f5 ff ff       	call   f01035a0 <env_destroy>
}
f010400c:	83 c4 10             	add    $0x10,%esp
f010400f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104012:	5b                   	pop    %ebx
f0104013:	5e                   	pop    %esi
f0104014:	5f                   	pop    %edi
f0104015:	5d                   	pop    %ebp
f0104016:	c3                   	ret    

f0104017 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0104017:	55                   	push   %ebp
f0104018:	89 e5                	mov    %esp,%ebp
f010401a:	57                   	push   %edi
f010401b:	56                   	push   %esi
f010401c:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f010401f:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0104020:	83 3d 80 be 22 f0 00 	cmpl   $0x0,0xf022be80
f0104027:	74 01                	je     f010402a <trap+0x13>
		asm volatile("hlt");
f0104029:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f010402a:	e8 17 19 00 00       	call   f0105946 <cpunum>
f010402f:	6b d0 74             	imul   $0x74,%eax,%edx
f0104032:	81 c2 20 c0 22 f0    	add    $0xf022c020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0104038:	b8 01 00 00 00       	mov    $0x1,%eax
f010403d:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0104041:	83 f8 02             	cmp    $0x2,%eax
f0104044:	75 10                	jne    f0104056 <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104046:	83 ec 0c             	sub    $0xc,%esp
f0104049:	68 c0 03 12 f0       	push   $0xf01203c0
f010404e:	e8 61 1b 00 00       	call   f0105bb4 <spin_lock>
f0104053:	83 c4 10             	add    $0x10,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0104056:	9c                   	pushf  
f0104057:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104058:	f6 c4 02             	test   $0x2,%ah
f010405b:	74 19                	je     f0104076 <trap+0x5f>
f010405d:	68 1c 76 10 f0       	push   $0xf010761c
f0104062:	68 e5 65 10 f0       	push   $0xf01065e5
f0104067:	68 0a 01 00 00       	push   $0x10a
f010406c:	68 10 76 10 f0       	push   $0xf0107610
f0104071:	e8 ca bf ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0104076:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010407a:	83 e0 03             	and    $0x3,%eax
f010407d:	66 83 f8 03          	cmp    $0x3,%ax
f0104081:	0f 85 a0 00 00 00    	jne    f0104127 <trap+0x110>
f0104087:	83 ec 0c             	sub    $0xc,%esp
f010408a:	68 c0 03 12 f0       	push   $0xf01203c0
f010408f:	e8 20 1b 00 00       	call   f0105bb4 <spin_lock>
		// serious kernel work.
		// LAB 4: Your code here.

		lock_kernel();

		assert(curenv);
f0104094:	e8 ad 18 00 00       	call   f0105946 <cpunum>
f0104099:	6b c0 74             	imul   $0x74,%eax,%eax
f010409c:	83 c4 10             	add    $0x10,%esp
f010409f:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f01040a6:	75 19                	jne    f01040c1 <trap+0xaa>
f01040a8:	68 35 76 10 f0       	push   $0xf0107635
f01040ad:	68 e5 65 10 f0       	push   $0xf01065e5
f01040b2:	68 14 01 00 00       	push   $0x114
f01040b7:	68 10 76 10 f0       	push   $0xf0107610
f01040bc:	e8 7f bf ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f01040c1:	e8 80 18 00 00       	call   f0105946 <cpunum>
f01040c6:	6b c0 74             	imul   $0x74,%eax,%eax
f01040c9:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01040cf:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01040d3:	75 2d                	jne    f0104102 <trap+0xeb>
			env_free(curenv);
f01040d5:	e8 6c 18 00 00       	call   f0105946 <cpunum>
f01040da:	83 ec 0c             	sub    $0xc,%esp
f01040dd:	6b c0 74             	imul   $0x74,%eax,%eax
f01040e0:	ff b0 28 c0 22 f0    	pushl  -0xfdd3fd8(%eax)
f01040e6:	e8 da f2 ff ff       	call   f01033c5 <env_free>
			curenv = NULL;
f01040eb:	e8 56 18 00 00       	call   f0105946 <cpunum>
f01040f0:	6b c0 74             	imul   $0x74,%eax,%eax
f01040f3:	c7 80 28 c0 22 f0 00 	movl   $0x0,-0xfdd3fd8(%eax)
f01040fa:	00 00 00 
			sched_yield();
f01040fd:	e8 49 02 00 00       	call   f010434b <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0104102:	e8 3f 18 00 00       	call   f0105946 <cpunum>
f0104107:	6b c0 74             	imul   $0x74,%eax,%eax
f010410a:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104110:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104115:	89 c7                	mov    %eax,%edi
f0104117:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104119:	e8 28 18 00 00       	call   f0105946 <cpunum>
f010411e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104121:	8b b0 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104127:	89 35 60 ba 22 f0    	mov    %esi,0xf022ba60
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	struct PushRegs* r = &tf->tf_regs;

	switch(tf->tf_trapno) {
f010412d:	8b 46 28             	mov    0x28(%esi),%eax
f0104130:	83 f8 0e             	cmp    $0xe,%eax
f0104133:	74 0c                	je     f0104141 <trap+0x12a>
f0104135:	83 f8 30             	cmp    $0x30,%eax
f0104138:	74 23                	je     f010415d <trap+0x146>
f010413a:	83 f8 03             	cmp    $0x3,%eax
f010413d:	75 3f                	jne    f010417e <trap+0x167>
f010413f:	eb 0e                	jmp    f010414f <trap+0x138>
		case (T_PGFLT):
			page_fault_handler(tf);
f0104141:	83 ec 0c             	sub    $0xc,%esp
f0104144:	56                   	push   %esi
f0104145:	e8 93 fd ff ff       	call   f0103edd <page_fault_handler>
f010414a:	83 c4 10             	add    $0x10,%esp
f010414d:	eb 72                	jmp    f01041c1 <trap+0x1aa>
			break;
		case (T_BRKPT):
			monitor(tf);	// open a JOS monitor
f010414f:	83 ec 0c             	sub    $0xc,%esp
f0104152:	56                   	push   %esi
f0104153:	e8 1a c8 ff ff       	call   f0100972 <monitor>
f0104158:	83 c4 10             	add    $0x10,%esp
f010415b:	eb 64                	jmp    f01041c1 <trap+0x1aa>
			break;
		case (T_SYSCALL):
			// call syscall in kern/syscall.c
			r->reg_eax = syscall(r->reg_eax, r->reg_edx, r->reg_ecx, r->reg_ebx, r->reg_edi, r->reg_esi);
f010415d:	83 ec 08             	sub    $0x8,%esp
f0104160:	ff 76 04             	pushl  0x4(%esi)
f0104163:	ff 36                	pushl  (%esi)
f0104165:	ff 76 10             	pushl  0x10(%esi)
f0104168:	ff 76 18             	pushl  0x18(%esi)
f010416b:	ff 76 14             	pushl  0x14(%esi)
f010416e:	ff 76 1c             	pushl  0x1c(%esi)
f0104171:	e8 5e 02 00 00       	call   f01043d4 <syscall>
f0104176:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104179:	83 c4 20             	add    $0x20,%esp
f010417c:	eb 43                	jmp    f01041c1 <trap+0x1aa>
			break;
		default:
			// Unexpected trap: The user process or the kernel has a bug.
			print_trapframe(tf);
f010417e:	83 ec 0c             	sub    $0xc,%esp
f0104181:	56                   	push   %esi
f0104182:	e8 ce fb ff ff       	call   f0103d55 <print_trapframe>
			if (tf->tf_cs == GD_KT)
f0104187:	83 c4 10             	add    $0x10,%esp
f010418a:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f010418f:	75 17                	jne    f01041a8 <trap+0x191>
				panic("unhandled trap in kernel");
f0104191:	83 ec 04             	sub    $0x4,%esp
f0104194:	68 3c 76 10 f0       	push   $0xf010763c
f0104199:	68 ef 00 00 00       	push   $0xef
f010419e:	68 10 76 10 f0       	push   $0xf0107610
f01041a3:	e8 98 be ff ff       	call   f0100040 <_panic>
			else {
				env_destroy(curenv);
f01041a8:	e8 99 17 00 00       	call   f0105946 <cpunum>
f01041ad:	83 ec 0c             	sub    $0xc,%esp
f01041b0:	6b c0 74             	imul   $0x74,%eax,%eax
f01041b3:	ff b0 28 c0 22 f0    	pushl  -0xfdd3fd8(%eax)
f01041b9:	e8 e2 f3 ff ff       	call   f01035a0 <env_destroy>
f01041be:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f01041c1:	e8 80 17 00 00       	call   f0105946 <cpunum>
f01041c6:	6b c0 74             	imul   $0x74,%eax,%eax
f01041c9:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f01041d0:	74 2a                	je     f01041fc <trap+0x1e5>
f01041d2:	e8 6f 17 00 00       	call   f0105946 <cpunum>
f01041d7:	6b c0 74             	imul   $0x74,%eax,%eax
f01041da:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01041e0:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01041e4:	75 16                	jne    f01041fc <trap+0x1e5>
		env_run(curenv);
f01041e6:	e8 5b 17 00 00       	call   f0105946 <cpunum>
f01041eb:	83 ec 0c             	sub    $0xc,%esp
f01041ee:	6b c0 74             	imul   $0x74,%eax,%eax
f01041f1:	ff b0 28 c0 22 f0    	pushl  -0xfdd3fd8(%eax)
f01041f7:	e8 43 f4 ff ff       	call   f010363f <env_run>
	else
		sched_yield();
f01041fc:	e8 4a 01 00 00       	call   f010434b <sched_yield>
f0104201:	90                   	nop

f0104202 <_T_DIVIDE_handler>:
/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */


TRAPHANDLER_NOEC(_T_DIVIDE_handler, T_DIVIDE)
f0104202:	6a 00                	push   $0x0
f0104204:	6a 00                	push   $0x0
f0104206:	eb 5e                	jmp    f0104266 <_alltraps>

f0104208 <_T_DEBUG_handler>:
TRAPHANDLER_NOEC(_T_DEBUG_handler, T_DEBUG)
f0104208:	6a 00                	push   $0x0
f010420a:	6a 01                	push   $0x1
f010420c:	eb 58                	jmp    f0104266 <_alltraps>

f010420e <_T_NMI_handler>:
TRAPHANDLER_NOEC(_T_NMI_handler, T_NMI)
f010420e:	6a 00                	push   $0x0
f0104210:	6a 02                	push   $0x2
f0104212:	eb 52                	jmp    f0104266 <_alltraps>

f0104214 <_T_BRKPT_handler>:
TRAPHANDLER_NOEC(_T_BRKPT_handler, T_BRKPT)
f0104214:	6a 00                	push   $0x0
f0104216:	6a 03                	push   $0x3
f0104218:	eb 4c                	jmp    f0104266 <_alltraps>

f010421a <_T_OFLOW_handler>:
TRAPHANDLER_NOEC(_T_OFLOW_handler, T_OFLOW)
f010421a:	6a 00                	push   $0x0
f010421c:	6a 04                	push   $0x4
f010421e:	eb 46                	jmp    f0104266 <_alltraps>

f0104220 <_T_BOUND_handler>:
TRAPHANDLER_NOEC(_T_BOUND_handler, T_BOUND)
f0104220:	6a 00                	push   $0x0
f0104222:	6a 05                	push   $0x5
f0104224:	eb 40                	jmp    f0104266 <_alltraps>

f0104226 <_T_ILLOP_handler>:
TRAPHANDLER_NOEC(_T_ILLOP_handler, T_ILLOP)
f0104226:	6a 00                	push   $0x0
f0104228:	6a 06                	push   $0x6
f010422a:	eb 3a                	jmp    f0104266 <_alltraps>

f010422c <_T_DEVICE_handler>:
TRAPHANDLER_NOEC(_T_DEVICE_handler, T_DEVICE)
f010422c:	6a 00                	push   $0x0
f010422e:	6a 07                	push   $0x7
f0104230:	eb 34                	jmp    f0104266 <_alltraps>

f0104232 <_T_DBLFLT_handler>:
TRAPHANDLER(_T_DBLFLT_handler, T_DBLFLT)
f0104232:	6a 08                	push   $0x8
f0104234:	eb 30                	jmp    f0104266 <_alltraps>

f0104236 <_T_TSS_handler>:
TRAPHANDLER(_T_TSS_handler, T_TSS)
f0104236:	6a 0a                	push   $0xa
f0104238:	eb 2c                	jmp    f0104266 <_alltraps>

f010423a <_T_SEGNP_handler>:
TRAPHANDLER(_T_SEGNP_handler, T_SEGNP)
f010423a:	6a 0b                	push   $0xb
f010423c:	eb 28                	jmp    f0104266 <_alltraps>

f010423e <_T_STACK_handler>:
TRAPHANDLER(_T_STACK_handler, T_STACK)
f010423e:	6a 0c                	push   $0xc
f0104240:	eb 24                	jmp    f0104266 <_alltraps>

f0104242 <_T_GPFLT_handler>:
TRAPHANDLER(_T_GPFLT_handler, T_GPFLT)
f0104242:	6a 0d                	push   $0xd
f0104244:	eb 20                	jmp    f0104266 <_alltraps>

f0104246 <_T_PGFLT_handler>:
TRAPHANDLER(_T_PGFLT_handler, T_PGFLT)
f0104246:	6a 0e                	push   $0xe
f0104248:	eb 1c                	jmp    f0104266 <_alltraps>

f010424a <_T_FPERR_handler>:
TRAPHANDLER_NOEC(_T_FPERR_handler, T_FPERR)
f010424a:	6a 00                	push   $0x0
f010424c:	6a 10                	push   $0x10
f010424e:	eb 16                	jmp    f0104266 <_alltraps>

f0104250 <_T_ALIGN_handler>:
TRAPHANDLER(_T_ALIGN_handler, T_ALIGN)
f0104250:	6a 11                	push   $0x11
f0104252:	eb 12                	jmp    f0104266 <_alltraps>

f0104254 <_T_MCHK_handler>:
TRAPHANDLER_NOEC(_T_MCHK_handler, T_MCHK)
f0104254:	6a 00                	push   $0x0
f0104256:	6a 12                	push   $0x12
f0104258:	eb 0c                	jmp    f0104266 <_alltraps>

f010425a <_T_SIMDERR_handler>:
TRAPHANDLER_NOEC(_T_SIMDERR_handler, T_SIMDERR)
f010425a:	6a 00                	push   $0x0
f010425c:	6a 13                	push   $0x13
f010425e:	eb 06                	jmp    f0104266 <_alltraps>

f0104260 <_T_SYSCALL_handler>:
TRAPHANDLER_NOEC(_T_SYSCALL_handler, T_SYSCALL)
f0104260:	6a 00                	push   $0x0
f0104262:	6a 30                	push   $0x30
f0104264:	eb 00                	jmp    f0104266 <_alltraps>

f0104266 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */

_alltraps:
	pushl %ds
f0104266:	1e                   	push   %ds
	pushl %es
f0104267:	06                   	push   %es
	pushal	/* push all general registers */
f0104268:	60                   	pusha  

	movl $GD_KD, %eax
f0104269:	b8 10 00 00 00       	mov    $0x10,%eax
	movl %eax, %ds
f010426e:	8e d8                	mov    %eax,%ds
	movl %eax, %es
f0104270:	8e c0                	mov    %eax,%es

	push %esp
f0104272:	54                   	push   %esp
f0104273:	e8 9f fd ff ff       	call   f0104017 <trap>

f0104278 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104278:	55                   	push   %ebp
f0104279:	89 e5                	mov    %esp,%ebp
f010427b:	83 ec 08             	sub    $0x8,%esp
f010427e:	a1 48 b2 22 f0       	mov    0xf022b248,%eax
f0104283:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104286:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f010428b:	8b 02                	mov    (%edx),%eax
f010428d:	83 e8 01             	sub    $0x1,%eax
f0104290:	83 f8 02             	cmp    $0x2,%eax
f0104293:	76 10                	jbe    f01042a5 <sched_halt+0x2d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104295:	83 c1 01             	add    $0x1,%ecx
f0104298:	83 c2 7c             	add    $0x7c,%edx
f010429b:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01042a1:	75 e8                	jne    f010428b <sched_halt+0x13>
f01042a3:	eb 08                	jmp    f01042ad <sched_halt+0x35>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f01042a5:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01042ab:	75 1f                	jne    f01042cc <sched_halt+0x54>
		cprintf("No runnable environments in the system!\n");
f01042ad:	83 ec 0c             	sub    $0xc,%esp
f01042b0:	68 10 78 10 f0       	push   $0xf0107810
f01042b5:	e8 e7 f5 ff ff       	call   f01038a1 <cprintf>
f01042ba:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f01042bd:	83 ec 0c             	sub    $0xc,%esp
f01042c0:	6a 00                	push   $0x0
f01042c2:	e8 ab c6 ff ff       	call   f0100972 <monitor>
f01042c7:	83 c4 10             	add    $0x10,%esp
f01042ca:	eb f1                	jmp    f01042bd <sched_halt+0x45>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f01042cc:	e8 75 16 00 00       	call   f0105946 <cpunum>
f01042d1:	6b c0 74             	imul   $0x74,%eax,%eax
f01042d4:	c7 80 28 c0 22 f0 00 	movl   $0x0,-0xfdd3fd8(%eax)
f01042db:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f01042de:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01042e3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01042e8:	77 12                	ja     f01042fc <sched_halt+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01042ea:	50                   	push   %eax
f01042eb:	68 28 60 10 f0       	push   $0xf0106028
f01042f0:	6a 51                	push   $0x51
f01042f2:	68 39 78 10 f0       	push   $0xf0107839
f01042f7:	e8 44 bd ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01042fc:	05 00 00 00 10       	add    $0x10000000,%eax
f0104301:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104304:	e8 3d 16 00 00       	call   f0105946 <cpunum>
f0104309:	6b d0 74             	imul   $0x74,%eax,%edx
f010430c:	81 c2 20 c0 22 f0    	add    $0xf022c020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0104312:	b8 02 00 00 00       	mov    $0x2,%eax
f0104317:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f010431b:	83 ec 0c             	sub    $0xc,%esp
f010431e:	68 c0 03 12 f0       	push   $0xf01203c0
f0104323:	e8 29 19 00 00       	call   f0105c51 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104328:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		//"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f010432a:	e8 17 16 00 00       	call   f0105946 <cpunum>
f010432f:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104332:	8b 80 30 c0 22 f0    	mov    -0xfdd3fd0(%eax),%eax
f0104338:	bd 00 00 00 00       	mov    $0x0,%ebp
f010433d:	89 c4                	mov    %eax,%esp
f010433f:	6a 00                	push   $0x0
f0104341:	6a 00                	push   $0x0
f0104343:	f4                   	hlt    
f0104344:	eb fd                	jmp    f0104343 <sched_halt+0xcb>
		//"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104346:	83 c4 10             	add    $0x10,%esp
f0104349:	c9                   	leave  
f010434a:	c3                   	ret    

f010434b <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f010434b:	55                   	push   %ebp
f010434c:	89 e5                	mov    %esp,%ebp
f010434e:	56                   	push   %esi
f010434f:	53                   	push   %ebx
	// below to halt the cpu.

	// LAB 4: Your code here.
	// cprintf("[yield]\n");

	struct Env *now = thiscpu->cpu_env;
f0104350:	e8 f1 15 00 00       	call   f0105946 <cpunum>
f0104355:	6b c0 74             	imul   $0x74,%eax,%eax
f0104358:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
    int32_t startid = (now) ? ENVX(now->env_id): 0;
f010435e:	85 c0                	test   %eax,%eax
f0104360:	74 0b                	je     f010436d <sched_yield+0x22>
f0104362:	8b 50 48             	mov    0x48(%eax),%edx
f0104365:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f010436b:	eb 05                	jmp    f0104372 <sched_yield+0x27>
f010436d:	ba 00 00 00 00       	mov    $0x0,%edx
    int32_t nextid;
    size_t i;

    for(i = 0; i < NENV; i++) {
        nextid = (startid+i)%NENV;
        if(envs[nextid].env_status == ENV_RUNNABLE) {
f0104372:	8b 0d 48 b2 22 f0    	mov    0xf022b248,%ecx
f0104378:	89 d6                	mov    %edx,%esi
f010437a:	8d 9a 00 04 00 00    	lea    0x400(%edx),%ebx
f0104380:	89 d0                	mov    %edx,%eax
f0104382:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104387:	6b c0 7c             	imul   $0x7c,%eax,%eax
f010438a:	01 c8                	add    %ecx,%eax
f010438c:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0104390:	75 09                	jne    f010439b <sched_yield+0x50>
                env_run(&envs[nextid]);
f0104392:	83 ec 0c             	sub    $0xc,%esp
f0104395:	50                   	push   %eax
f0104396:	e8 a4 f2 ff ff       	call   f010363f <env_run>
f010439b:	83 c2 01             	add    $0x1,%edx
	struct Env *now = thiscpu->cpu_env;
    int32_t startid = (now) ? ENVX(now->env_id): 0;
    int32_t nextid;
    size_t i;

    for(i = 0; i < NENV; i++) {
f010439e:	39 da                	cmp    %ebx,%edx
f01043a0:	75 de                	jne    f0104380 <sched_yield+0x35>
                env_run(&envs[nextid]);
                return;
            }
    }
    
    if(envs[startid].env_status == ENV_RUNNING && envs[startid].env_cpunum == cpunum()) {
f01043a2:	6b f6 7c             	imul   $0x7c,%esi,%esi
f01043a5:	01 f1                	add    %esi,%ecx
f01043a7:	83 79 54 03          	cmpl   $0x3,0x54(%ecx)
f01043ab:	75 1b                	jne    f01043c8 <sched_yield+0x7d>
f01043ad:	8b 59 5c             	mov    0x5c(%ecx),%ebx
f01043b0:	e8 91 15 00 00       	call   f0105946 <cpunum>
f01043b5:	39 c3                	cmp    %eax,%ebx
f01043b7:	75 0f                	jne    f01043c8 <sched_yield+0x7d>
        env_run(&envs[startid]);
f01043b9:	83 ec 0c             	sub    $0xc,%esp
f01043bc:	03 35 48 b2 22 f0    	add    0xf022b248,%esi
f01043c2:	56                   	push   %esi
f01043c3:	e8 77 f2 ff ff       	call   f010363f <env_run>
    }

	// cprintf("[halt]\n");

	// sched_halt never returns
	sched_halt();
f01043c8:	e8 ab fe ff ff       	call   f0104278 <sched_halt>
}
f01043cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01043d0:	5b                   	pop    %ebx
f01043d1:	5e                   	pop    %esi
f01043d2:	5d                   	pop    %ebp
f01043d3:	c3                   	ret    

f01043d4 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01043d4:	55                   	push   %ebp
f01043d5:	89 e5                	mov    %esp,%ebp
f01043d7:	57                   	push   %edi
f01043d8:	56                   	push   %esi
f01043d9:	53                   	push   %ebx
f01043da:	83 ec 1c             	sub    $0x1c,%esp
f01043dd:	8b 45 08             	mov    0x8(%ebp),%eax
	// Return any appropriate return value.
	// LAB 3: Your code here.

	// panic("syscall not implemented");

	switch (syscallno) {
f01043e0:	83 f8 0a             	cmp    $0xa,%eax
f01043e3:	0f 87 be 03 00 00    	ja     f01047a7 <syscall+0x3d3>
f01043e9:	ff 24 85 80 78 10 f0 	jmp    *-0xfef8780(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, 0);		// just check if PTE_U is set
f01043f0:	e8 51 15 00 00       	call   f0105946 <cpunum>
f01043f5:	6a 00                	push   $0x0
f01043f7:	ff 75 10             	pushl  0x10(%ebp)
f01043fa:	ff 75 0c             	pushl  0xc(%ebp)
f01043fd:	6b c0 74             	imul   $0x74,%eax,%eax
f0104400:	ff b0 28 c0 22 f0    	pushl  -0xfdd3fd8(%eax)
f0104406:	e8 14 eb ff ff       	call   f0102f1f <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f010440b:	83 c4 0c             	add    $0xc,%esp
f010440e:	ff 75 0c             	pushl  0xc(%ebp)
f0104411:	ff 75 10             	pushl  0x10(%ebp)
f0104414:	68 46 78 10 f0       	push   $0xf0107846
f0104419:	e8 83 f4 ff ff       	call   f01038a1 <cprintf>
f010441e:	83 c4 10             	add    $0x10,%esp
	// panic("syscall not implemented");

	switch (syscallno) {
		case SYS_cputs:
			sys_cputs((char *)a1, a2);
			return 0;
f0104421:	b8 00 00 00 00       	mov    $0x0,%eax
f0104426:	e9 81 03 00 00       	jmp    f01047ac <syscall+0x3d8>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f010442b:	e8 ae c1 ff ff       	call   f01005de <cons_getc>
	switch (syscallno) {
		case SYS_cputs:
			sys_cputs((char *)a1, a2);
			return 0;
		case SYS_cgetc:
			return sys_cgetc();
f0104430:	e9 77 03 00 00       	jmp    f01047ac <syscall+0x3d8>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104435:	e8 0c 15 00 00       	call   f0105946 <cpunum>
f010443a:	6b c0 74             	imul   $0x74,%eax,%eax
f010443d:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104443:	8b 40 48             	mov    0x48(%eax),%eax
			sys_cputs((char *)a1, a2);
			return 0;
		case SYS_cgetc:
			return sys_cgetc();
		case SYS_getenvid:
			return sys_getenvid();
f0104446:	e9 61 03 00 00       	jmp    f01047ac <syscall+0x3d8>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f010444b:	83 ec 04             	sub    $0x4,%esp
f010444e:	6a 01                	push   $0x1
f0104450:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104453:	50                   	push   %eax
f0104454:	ff 75 0c             	pushl  0xc(%ebp)
f0104457:	e8 91 eb ff ff       	call   f0102fed <envid2env>
f010445c:	83 c4 10             	add    $0x10,%esp
f010445f:	85 c0                	test   %eax,%eax
f0104461:	0f 88 45 03 00 00    	js     f01047ac <syscall+0x3d8>
		return r;
	if (e == curenv)
f0104467:	e8 da 14 00 00       	call   f0105946 <cpunum>
f010446c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010446f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104472:	39 90 28 c0 22 f0    	cmp    %edx,-0xfdd3fd8(%eax)
f0104478:	75 23                	jne    f010449d <syscall+0xc9>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f010447a:	e8 c7 14 00 00       	call   f0105946 <cpunum>
f010447f:	83 ec 08             	sub    $0x8,%esp
f0104482:	6b c0 74             	imul   $0x74,%eax,%eax
f0104485:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f010448b:	ff 70 48             	pushl  0x48(%eax)
f010448e:	68 4b 78 10 f0       	push   $0xf010784b
f0104493:	e8 09 f4 ff ff       	call   f01038a1 <cprintf>
f0104498:	83 c4 10             	add    $0x10,%esp
f010449b:	eb 25                	jmp    f01044c2 <syscall+0xee>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f010449d:	8b 5a 48             	mov    0x48(%edx),%ebx
f01044a0:	e8 a1 14 00 00       	call   f0105946 <cpunum>
f01044a5:	83 ec 04             	sub    $0x4,%esp
f01044a8:	53                   	push   %ebx
f01044a9:	6b c0 74             	imul   $0x74,%eax,%eax
f01044ac:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01044b2:	ff 70 48             	pushl  0x48(%eax)
f01044b5:	68 66 78 10 f0       	push   $0xf0107866
f01044ba:	e8 e2 f3 ff ff       	call   f01038a1 <cprintf>
f01044bf:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f01044c2:	83 ec 0c             	sub    $0xc,%esp
f01044c5:	ff 75 e4             	pushl  -0x1c(%ebp)
f01044c8:	e8 d3 f0 ff ff       	call   f01035a0 <env_destroy>
f01044cd:	83 c4 10             	add    $0x10,%esp
	return 0;
f01044d0:	b8 00 00 00 00       	mov    $0x0,%eax
f01044d5:	e9 d2 02 00 00       	jmp    f01047ac <syscall+0x3d8>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f01044da:	e8 6c fe ff ff       	call   f010434b <sched_yield>
	// LAB 4: Your code here.
	// panic("sys_exofork not implemented");

	struct Env *newenv;

	int err = env_alloc(&newenv , curenv->env_id);
f01044df:	e8 62 14 00 00       	call   f0105946 <cpunum>
f01044e4:	83 ec 08             	sub    $0x8,%esp
f01044e7:	6b c0 74             	imul   $0x74,%eax,%eax
f01044ea:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01044f0:	ff 70 48             	pushl  0x48(%eax)
f01044f3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01044f6:	50                   	push   %eax
f01044f7:	e8 fc eb ff ff       	call   f01030f8 <env_alloc>
	if (err < 0)
f01044fc:	83 c4 10             	add    $0x10,%esp
f01044ff:	85 c0                	test   %eax,%eax
f0104501:	0f 88 a5 02 00 00    	js     f01047ac <syscall+0x3d8>
		return err;

	// memcpy(&newenv->env_tf, &curenv->env_tf, sizeof(struct Trapframe));
	newenv->env_tf = curenv->env_tf;
f0104507:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010450a:	e8 37 14 00 00       	call   f0105946 <cpunum>
f010450f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104512:	8b b0 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%esi
f0104518:	b9 11 00 00 00       	mov    $0x11,%ecx
f010451d:	89 df                	mov    %ebx,%edi
f010451f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	newenv->env_status = ENV_NOT_RUNNABLE;
f0104521:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104524:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)

	// tweak newenv, to make it appear to return 0
	newenv->env_tf.tf_regs.reg_eax = 0;
f010452b:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

	return newenv->env_id;
f0104532:	8b 40 48             	mov    0x48(%eax),%eax
f0104535:	e9 72 02 00 00       	jmp    f01047ac <syscall+0x3d8>

	// LAB 4: Your code here.
	// panic("sys_env_set_status not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
f010453a:	83 ec 04             	sub    $0x4,%esp
f010453d:	6a 01                	push   $0x1
f010453f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104542:	50                   	push   %eax
f0104543:	ff 75 0c             	pushl  0xc(%ebp)
f0104546:	e8 a2 ea ff ff       	call   f0102fed <envid2env>
	if (err < 0)
f010454b:	83 c4 10             	add    $0x10,%esp
f010454e:	85 c0                	test   %eax,%eax
f0104550:	0f 88 56 02 00 00    	js     f01047ac <syscall+0x3d8>
		return err;

	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
f0104556:	8b 45 10             	mov    0x10(%ebp),%eax
f0104559:	83 e8 02             	sub    $0x2,%eax
f010455c:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f0104561:	75 13                	jne    f0104576 <syscall+0x1a2>
		return -E_INVAL;

	env_store->env_status = status;
f0104563:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104566:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104569:	89 78 54             	mov    %edi,0x54(%eax)

	return 0;
f010456c:	b8 00 00 00 00       	mov    $0x0,%eax
f0104571:	e9 36 02 00 00       	jmp    f01047ac <syscall+0x3d8>
	int err = envid2env(envid, &env_store, 1);
	if (err < 0)
		return err;

	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
		return -E_INVAL;
f0104576:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			sys_yield();
			return 0;
		case SYS_exofork:
			return sys_exofork();
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1, a2);
f010457b:	e9 2c 02 00 00       	jmp    f01047ac <syscall+0x3d8>

	// LAB 4: Your code here.
	// panic("sys_page_alloc not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
f0104580:	83 ec 04             	sub    $0x4,%esp
f0104583:	6a 01                	push   $0x1
f0104585:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104588:	50                   	push   %eax
f0104589:	ff 75 0c             	pushl  0xc(%ebp)
f010458c:	e8 5c ea ff ff       	call   f0102fed <envid2env>
	if (err < 0)
f0104591:	83 c4 10             	add    $0x10,%esp
f0104594:	85 c0                	test   %eax,%eax
f0104596:	0f 88 10 02 00 00    	js     f01047ac <syscall+0x3d8>
		return err;	// E_BAD_ENV

	if ((perm | PTE_AVAIL | PTE_W) != (PTE_AVAIL | PTE_W | PTE_U | PTE_P))
		return -E_INVAL;

	if ((uint32_t)va >= UTOP || ((uint32_t) va % PGSIZE) != 0)
f010459c:	8b 45 14             	mov    0x14(%ebp),%eax
f010459f:	0d 02 0e 00 00       	or     $0xe02,%eax
f01045a4:	3d 07 0e 00 00       	cmp    $0xe07,%eax
f01045a9:	75 5c                	jne    f0104607 <syscall+0x233>
f01045ab:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01045b2:	77 53                	ja     f0104607 <syscall+0x233>
f01045b4:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01045bb:	75 54                	jne    f0104611 <syscall+0x23d>
		return -E_INVAL;
	
	struct PageInfo * pp = page_alloc(ALLOC_ZERO);
f01045bd:	83 ec 0c             	sub    $0xc,%esp
f01045c0:	6a 01                	push   $0x1
f01045c2:	e8 9c ca ff ff       	call   f0101063 <page_alloc>
f01045c7:	89 c3                	mov    %eax,%ebx
	if (pp == NULL)
f01045c9:	83 c4 10             	add    $0x10,%esp
f01045cc:	85 c0                	test   %eax,%eax
f01045ce:	74 4b                	je     f010461b <syscall+0x247>
		return -E_NO_MEM;
	
	err = page_insert(env_store->env_pgdir, pp, va, perm);
f01045d0:	ff 75 14             	pushl  0x14(%ebp)
f01045d3:	ff 75 10             	pushl  0x10(%ebp)
f01045d6:	50                   	push   %eax
f01045d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01045da:	ff 70 60             	pushl  0x60(%eax)
f01045dd:	e8 af cd ff ff       	call   f0101391 <page_insert>
f01045e2:	89 c6                	mov    %eax,%esi
	if (err < 0) {
f01045e4:	83 c4 10             	add    $0x10,%esp
		page_free(pp);
		return err; // E_NO_MEM
	}

	return 0;
f01045e7:	b8 00 00 00 00       	mov    $0x0,%eax
	struct PageInfo * pp = page_alloc(ALLOC_ZERO);
	if (pp == NULL)
		return -E_NO_MEM;
	
	err = page_insert(env_store->env_pgdir, pp, va, perm);
	if (err < 0) {
f01045ec:	85 f6                	test   %esi,%esi
f01045ee:	0f 89 b8 01 00 00    	jns    f01047ac <syscall+0x3d8>
		page_free(pp);
f01045f4:	83 ec 0c             	sub    $0xc,%esp
f01045f7:	53                   	push   %ebx
f01045f8:	e8 d7 ca ff ff       	call   f01010d4 <page_free>
f01045fd:	83 c4 10             	add    $0x10,%esp
		return err; // E_NO_MEM
f0104600:	89 f0                	mov    %esi,%eax
f0104602:	e9 a5 01 00 00       	jmp    f01047ac <syscall+0x3d8>

	if ((perm | PTE_AVAIL | PTE_W) != (PTE_AVAIL | PTE_W | PTE_U | PTE_P))
		return -E_INVAL;

	if ((uint32_t)va >= UTOP || ((uint32_t) va % PGSIZE) != 0)
		return -E_INVAL;
f0104607:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010460c:	e9 9b 01 00 00       	jmp    f01047ac <syscall+0x3d8>
f0104611:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104616:	e9 91 01 00 00       	jmp    f01047ac <syscall+0x3d8>
	
	struct PageInfo * pp = page_alloc(ALLOC_ZERO);
	if (pp == NULL)
		return -E_NO_MEM;
f010461b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104620:	e9 87 01 00 00       	jmp    f01047ac <syscall+0x3d8>
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	// panic("sys_page_map not implemented");

	if ((uint32_t)srcva >= UTOP || ((uint32_t)srcva % PGSIZE) != 0 || (uint32_t)dstva >= UTOP || ((uint32_t)dstva % PGSIZE != 0))
f0104625:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f010462c:	0f 87 be 00 00 00    	ja     f01046f0 <syscall+0x31c>
f0104632:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104639:	0f 85 bb 00 00 00    	jne    f01046fa <syscall+0x326>
f010463f:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104646:	0f 87 ae 00 00 00    	ja     f01046fa <syscall+0x326>
f010464c:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f0104653:	0f 85 ab 00 00 00    	jne    f0104704 <syscall+0x330>
		return -E_INVAL;
	
	struct Env *srcenv, *dstenv;
	int err = envid2env(srcenvid, &srcenv, 1);
f0104659:	83 ec 04             	sub    $0x4,%esp
f010465c:	6a 01                	push   $0x1
f010465e:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104661:	50                   	push   %eax
f0104662:	ff 75 0c             	pushl  0xc(%ebp)
f0104665:	e8 83 e9 ff ff       	call   f0102fed <envid2env>
	if(err < 0)
f010466a:	83 c4 10             	add    $0x10,%esp
f010466d:	85 c0                	test   %eax,%eax
f010466f:	0f 88 37 01 00 00    	js     f01047ac <syscall+0x3d8>
		return err;	// E_BAD_ENV
	err = envid2env(dstenvid, &dstenv, 1);
f0104675:	83 ec 04             	sub    $0x4,%esp
f0104678:	6a 01                	push   $0x1
f010467a:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010467d:	50                   	push   %eax
f010467e:	ff 75 14             	pushl  0x14(%ebp)
f0104681:	e8 67 e9 ff ff       	call   f0102fed <envid2env>
	if(err < 0)
f0104686:	83 c4 10             	add    $0x10,%esp
f0104689:	85 c0                	test   %eax,%eax
f010468b:	0f 88 1b 01 00 00    	js     f01047ac <syscall+0x3d8>
		return err;	// E_BAD_ENV

	pte_t *pte;
	struct PageInfo *pp = page_lookup(srcenv->env_pgdir, srcva, &pte);
f0104691:	83 ec 04             	sub    $0x4,%esp
f0104694:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104697:	50                   	push   %eax
f0104698:	ff 75 10             	pushl  0x10(%ebp)
f010469b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010469e:	ff 70 60             	pushl  0x60(%eax)
f01046a1:	e8 03 cc ff ff       	call   f01012a9 <page_lookup>
	if (pp == NULL) 
f01046a6:	83 c4 10             	add    $0x10,%esp
f01046a9:	85 c0                	test   %eax,%eax
f01046ab:	74 61                	je     f010470e <syscall+0x33a>
		return -E_INVAL;	// not mapped
	
	if ( ((*pte) & PTE_W) == 0 && (perm & PTE_W) != 0)
f01046ad:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01046b0:	f6 02 02             	testb  $0x2,(%edx)
f01046b3:	75 06                	jne    f01046bb <syscall+0x2e7>
f01046b5:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f01046b9:	75 5d                	jne    f0104718 <syscall+0x344>
		return -E_INVAL;	// read-only page

	// same perm restrictions as in sys_page_alloc
	if ((perm | PTE_AVAIL | PTE_W) != (PTE_AVAIL | PTE_W | PTE_U | PTE_P))
f01046bb:	8b 55 1c             	mov    0x1c(%ebp),%edx
f01046be:	81 ca 02 0e 00 00    	or     $0xe02,%edx
f01046c4:	81 fa 07 0e 00 00    	cmp    $0xe07,%edx
f01046ca:	75 56                	jne    f0104722 <syscall+0x34e>
		return -E_INVAL;

	err = page_insert(dstenv->env_pgdir, pp, dstva, perm);
f01046cc:	ff 75 1c             	pushl  0x1c(%ebp)
f01046cf:	ff 75 18             	pushl  0x18(%ebp)
f01046d2:	50                   	push   %eax
f01046d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01046d6:	ff 70 60             	pushl  0x60(%eax)
f01046d9:	e8 b3 cc ff ff       	call   f0101391 <page_insert>
f01046de:	83 c4 10             	add    $0x10,%esp
f01046e1:	85 c0                	test   %eax,%eax
f01046e3:	ba 00 00 00 00       	mov    $0x0,%edx
f01046e8:	0f 4f c2             	cmovg  %edx,%eax
f01046eb:	e9 bc 00 00 00       	jmp    f01047ac <syscall+0x3d8>

	// LAB 4: Your code here.
	// panic("sys_page_map not implemented");

	if ((uint32_t)srcva >= UTOP || ((uint32_t)srcva % PGSIZE) != 0 || (uint32_t)dstva >= UTOP || ((uint32_t)dstva % PGSIZE != 0))
		return -E_INVAL;
f01046f0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01046f5:	e9 b2 00 00 00       	jmp    f01047ac <syscall+0x3d8>
f01046fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01046ff:	e9 a8 00 00 00       	jmp    f01047ac <syscall+0x3d8>
f0104704:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104709:	e9 9e 00 00 00       	jmp    f01047ac <syscall+0x3d8>
		return err;	// E_BAD_ENV

	pte_t *pte;
	struct PageInfo *pp = page_lookup(srcenv->env_pgdir, srcva, &pte);
	if (pp == NULL) 
		return -E_INVAL;	// not mapped
f010470e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104713:	e9 94 00 00 00       	jmp    f01047ac <syscall+0x3d8>
	
	if ( ((*pte) & PTE_W) == 0 && (perm & PTE_W) != 0)
		return -E_INVAL;	// read-only page
f0104718:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010471d:	e9 8a 00 00 00       	jmp    f01047ac <syscall+0x3d8>

	// same perm restrictions as in sys_page_alloc
	if ((perm | PTE_AVAIL | PTE_W) != (PTE_AVAIL | PTE_W | PTE_U | PTE_P))
		return -E_INVAL;
f0104722:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1, a2);
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1, (void *)a2, a3);
		case SYS_page_map:
			return sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4, a5);
f0104727:	e9 80 00 00 00       	jmp    f01047ac <syscall+0x3d8>
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	// panic("sys_page_unmap not implemented");

	if ((uint32_t)va >= UTOP || ((uint32_t) va % PGSIZE) != 0)
f010472c:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104733:	77 3c                	ja     f0104771 <syscall+0x39d>
f0104735:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010473c:	75 3a                	jne    f0104778 <syscall+0x3a4>
		return -E_INVAL;

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
f010473e:	83 ec 04             	sub    $0x4,%esp
f0104741:	6a 01                	push   $0x1
f0104743:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104746:	50                   	push   %eax
f0104747:	ff 75 0c             	pushl  0xc(%ebp)
f010474a:	e8 9e e8 ff ff       	call   f0102fed <envid2env>
	if (err < 0)
f010474f:	83 c4 10             	add    $0x10,%esp
f0104752:	85 c0                	test   %eax,%eax
f0104754:	78 56                	js     f01047ac <syscall+0x3d8>
		return err;	// E_BAD_ENV

	page_remove(env_store->env_pgdir, va);
f0104756:	83 ec 08             	sub    $0x8,%esp
f0104759:	ff 75 10             	pushl  0x10(%ebp)
f010475c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010475f:	ff 70 60             	pushl  0x60(%eax)
f0104762:	e8 dd cb ff ff       	call   f0101344 <page_remove>
f0104767:	83 c4 10             	add    $0x10,%esp

	return 0;
f010476a:	b8 00 00 00 00       	mov    $0x0,%eax
f010476f:	eb 3b                	jmp    f01047ac <syscall+0x3d8>

	// LAB 4: Your code here.
	// panic("sys_page_unmap not implemented");

	if ((uint32_t)va >= UTOP || ((uint32_t) va % PGSIZE) != 0)
		return -E_INVAL;
f0104771:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104776:	eb 34                	jmp    f01047ac <syscall+0x3d8>
f0104778:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010477d:	eb 2d                	jmp    f01047ac <syscall+0x3d8>
{
	// LAB 4: Your code here.
	// panic("sys_env_set_pgfault_upcall not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
f010477f:	83 ec 04             	sub    $0x4,%esp
f0104782:	6a 01                	push   $0x1
f0104784:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104787:	50                   	push   %eax
f0104788:	ff 75 0c             	pushl  0xc(%ebp)
f010478b:	e8 5d e8 ff ff       	call   f0102fed <envid2env>
	if (err < 0)
f0104790:	83 c4 10             	add    $0x10,%esp
f0104793:	85 c0                	test   %eax,%eax
f0104795:	78 15                	js     f01047ac <syscall+0x3d8>
		return err;

	env_store->env_pgfault_upcall = func;
f0104797:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010479a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010479d:	89 48 64             	mov    %ecx,0x64(%eax)

	return 0;
f01047a0:	b8 00 00 00 00       	mov    $0x0,%eax
f01047a5:	eb 05                	jmp    f01047ac <syscall+0x3d8>
		case SYS_page_unmap:
			return sys_page_unmap((envid_t)a1, (void *)a2);
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
		default:
			return -E_INVAL;
f01047a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
}
f01047ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01047af:	5b                   	pop    %ebx
f01047b0:	5e                   	pop    %esi
f01047b1:	5f                   	pop    %edi
f01047b2:	5d                   	pop    %ebp
f01047b3:	c3                   	ret    

f01047b4 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01047b4:	55                   	push   %ebp
f01047b5:	89 e5                	mov    %esp,%ebp
f01047b7:	57                   	push   %edi
f01047b8:	56                   	push   %esi
f01047b9:	53                   	push   %ebx
f01047ba:	83 ec 14             	sub    $0x14,%esp
f01047bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01047c0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01047c3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01047c6:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01047c9:	8b 1a                	mov    (%edx),%ebx
f01047cb:	8b 01                	mov    (%ecx),%eax
f01047cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01047d0:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01047d7:	eb 7f                	jmp    f0104858 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f01047d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01047dc:	01 d8                	add    %ebx,%eax
f01047de:	89 c6                	mov    %eax,%esi
f01047e0:	c1 ee 1f             	shr    $0x1f,%esi
f01047e3:	01 c6                	add    %eax,%esi
f01047e5:	d1 fe                	sar    %esi
f01047e7:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01047ea:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01047ed:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01047f0:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01047f2:	eb 03                	jmp    f01047f7 <stab_binsearch+0x43>
			m--;
f01047f4:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01047f7:	39 c3                	cmp    %eax,%ebx
f01047f9:	7f 0d                	jg     f0104808 <stab_binsearch+0x54>
f01047fb:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01047ff:	83 ea 0c             	sub    $0xc,%edx
f0104802:	39 f9                	cmp    %edi,%ecx
f0104804:	75 ee                	jne    f01047f4 <stab_binsearch+0x40>
f0104806:	eb 05                	jmp    f010480d <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104808:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f010480b:	eb 4b                	jmp    f0104858 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010480d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104810:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104813:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104817:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010481a:	76 11                	jbe    f010482d <stab_binsearch+0x79>
			*region_left = m;
f010481c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010481f:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104821:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104824:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010482b:	eb 2b                	jmp    f0104858 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f010482d:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104830:	73 14                	jae    f0104846 <stab_binsearch+0x92>
			*region_right = m - 1;
f0104832:	83 e8 01             	sub    $0x1,%eax
f0104835:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104838:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010483b:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010483d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104844:	eb 12                	jmp    f0104858 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104846:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104849:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f010484b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f010484f:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104851:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104858:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f010485b:	0f 8e 78 ff ff ff    	jle    f01047d9 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104861:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104865:	75 0f                	jne    f0104876 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0104867:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010486a:	8b 00                	mov    (%eax),%eax
f010486c:	83 e8 01             	sub    $0x1,%eax
f010486f:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104872:	89 06                	mov    %eax,(%esi)
f0104874:	eb 2c                	jmp    f01048a2 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104876:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104879:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f010487b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010487e:	8b 0e                	mov    (%esi),%ecx
f0104880:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104883:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104886:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104889:	eb 03                	jmp    f010488e <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f010488b:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010488e:	39 c8                	cmp    %ecx,%eax
f0104890:	7e 0b                	jle    f010489d <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0104892:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0104896:	83 ea 0c             	sub    $0xc,%edx
f0104899:	39 df                	cmp    %ebx,%edi
f010489b:	75 ee                	jne    f010488b <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f010489d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01048a0:	89 06                	mov    %eax,(%esi)
	}
}
f01048a2:	83 c4 14             	add    $0x14,%esp
f01048a5:	5b                   	pop    %ebx
f01048a6:	5e                   	pop    %esi
f01048a7:	5f                   	pop    %edi
f01048a8:	5d                   	pop    %ebp
f01048a9:	c3                   	ret    

f01048aa <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01048aa:	55                   	push   %ebp
f01048ab:	89 e5                	mov    %esp,%ebp
f01048ad:	57                   	push   %edi
f01048ae:	56                   	push   %esi
f01048af:	53                   	push   %ebx
f01048b0:	83 ec 3c             	sub    $0x3c,%esp
f01048b3:	8b 7d 08             	mov    0x8(%ebp),%edi
f01048b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01048b9:	c7 03 ac 78 10 f0    	movl   $0xf01078ac,(%ebx)
	info->eip_line = 0;
f01048bf:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01048c6:	c7 43 08 ac 78 10 f0 	movl   $0xf01078ac,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01048cd:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01048d4:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f01048d7:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01048de:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f01048e4:	0f 87 a3 00 00 00    	ja     f010498d <debuginfo_eip+0xe3>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f01048ea:	a1 00 00 20 00       	mov    0x200000,%eax
f01048ef:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stab_end = usd->stab_end;
f01048f2:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f01048f8:	8b 15 08 00 20 00    	mov    0x200008,%edx
f01048fe:	89 55 b8             	mov    %edx,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f0104901:	a1 0c 00 20 00       	mov    0x20000c,%eax
f0104906:	89 45 bc             	mov    %eax,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0 ||
f0104909:	e8 38 10 00 00       	call   f0105946 <cpunum>
f010490e:	6a 04                	push   $0x4
f0104910:	6a 10                	push   $0x10
f0104912:	68 00 00 20 00       	push   $0x200000
f0104917:	6b c0 74             	imul   $0x74,%eax,%eax
f010491a:	ff b0 28 c0 22 f0    	pushl  -0xfdd3fd8(%eax)
f0104920:	e8 48 e5 ff ff       	call   f0102e6d <user_mem_check>
f0104925:	83 c4 10             	add    $0x10,%esp
f0104928:	85 c0                	test   %eax,%eax
f010492a:	0f 88 27 02 00 00    	js     f0104b57 <debuginfo_eip+0x2ad>
			user_mem_check(curenv, stabs, stab_end-stabs, PTE_U) < 0 ||
f0104930:	e8 11 10 00 00       	call   f0105946 <cpunum>
f0104935:	6a 04                	push   $0x4
f0104937:	89 f2                	mov    %esi,%edx
f0104939:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f010493c:	29 ca                	sub    %ecx,%edx
f010493e:	c1 fa 02             	sar    $0x2,%edx
f0104941:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0104947:	52                   	push   %edx
f0104948:	51                   	push   %ecx
f0104949:	6b c0 74             	imul   $0x74,%eax,%eax
f010494c:	ff b0 28 c0 22 f0    	pushl  -0xfdd3fd8(%eax)
f0104952:	e8 16 e5 ff ff       	call   f0102e6d <user_mem_check>
		stabstr = usd->stabstr;
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0 ||
f0104957:	83 c4 10             	add    $0x10,%esp
f010495a:	85 c0                	test   %eax,%eax
f010495c:	0f 88 fc 01 00 00    	js     f0104b5e <debuginfo_eip+0x2b4>
			user_mem_check(curenv, stabs, stab_end-stabs, PTE_U) < 0 ||
			user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U) < 0
f0104962:	e8 df 0f 00 00       	call   f0105946 <cpunum>
f0104967:	6a 04                	push   $0x4
f0104969:	8b 55 bc             	mov    -0x44(%ebp),%edx
f010496c:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f010496f:	29 ca                	sub    %ecx,%edx
f0104971:	52                   	push   %edx
f0104972:	51                   	push   %ecx
f0104973:	6b c0 74             	imul   $0x74,%eax,%eax
f0104976:	ff b0 28 c0 22 f0    	pushl  -0xfdd3fd8(%eax)
f010497c:	e8 ec e4 ff ff       	call   f0102e6d <user_mem_check>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0 ||
			user_mem_check(curenv, stabs, stab_end-stabs, PTE_U) < 0 ||
f0104981:	83 c4 10             	add    $0x10,%esp
f0104984:	85 c0                	test   %eax,%eax
f0104986:	79 1f                	jns    f01049a7 <debuginfo_eip+0xfd>
f0104988:	e9 d8 01 00 00       	jmp    f0104b65 <debuginfo_eip+0x2bb>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f010498d:	c7 45 bc af 54 11 f0 	movl   $0xf01154af,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0104994:	c7 45 b8 a9 1d 11 f0 	movl   $0xf0111da9,-0x48(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f010499b:	be a8 1d 11 f0       	mov    $0xf0111da8,%esi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f01049a0:	c7 45 c0 94 7d 10 f0 	movl   $0xf0107d94,-0x40(%ebp)
		)
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01049a7:	8b 45 bc             	mov    -0x44(%ebp),%eax
f01049aa:	39 45 b8             	cmp    %eax,-0x48(%ebp)
f01049ad:	0f 83 b9 01 00 00    	jae    f0104b6c <debuginfo_eip+0x2c2>
f01049b3:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f01049b7:	0f 85 b6 01 00 00    	jne    f0104b73 <debuginfo_eip+0x2c9>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01049bd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01049c4:	2b 75 c0             	sub    -0x40(%ebp),%esi
f01049c7:	c1 fe 02             	sar    $0x2,%esi
f01049ca:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f01049d0:	83 e8 01             	sub    $0x1,%eax
f01049d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01049d6:	83 ec 08             	sub    $0x8,%esp
f01049d9:	57                   	push   %edi
f01049da:	6a 64                	push   $0x64
f01049dc:	8d 55 e0             	lea    -0x20(%ebp),%edx
f01049df:	89 d1                	mov    %edx,%ecx
f01049e1:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01049e4:	8b 75 c0             	mov    -0x40(%ebp),%esi
f01049e7:	89 f0                	mov    %esi,%eax
f01049e9:	e8 c6 fd ff ff       	call   f01047b4 <stab_binsearch>
	if (lfile == 0)
f01049ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01049f1:	83 c4 10             	add    $0x10,%esp
f01049f4:	85 c0                	test   %eax,%eax
f01049f6:	0f 84 7e 01 00 00    	je     f0104b7a <debuginfo_eip+0x2d0>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01049fc:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01049ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104a02:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104a05:	83 ec 08             	sub    $0x8,%esp
f0104a08:	57                   	push   %edi
f0104a09:	6a 24                	push   $0x24
f0104a0b:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0104a0e:	89 d1                	mov    %edx,%ecx
f0104a10:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104a13:	89 f0                	mov    %esi,%eax
f0104a15:	e8 9a fd ff ff       	call   f01047b4 <stab_binsearch>

	if (lfun <= rfun) {
f0104a1a:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104a1d:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104a20:	83 c4 10             	add    $0x10,%esp
f0104a23:	39 d0                	cmp    %edx,%eax
f0104a25:	7f 2e                	jg     f0104a55 <debuginfo_eip+0x1ab>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104a27:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0104a2a:	8d 34 8e             	lea    (%esi,%ecx,4),%esi
f0104a2d:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f0104a30:	8b 36                	mov    (%esi),%esi
f0104a32:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0104a35:	2b 4d b8             	sub    -0x48(%ebp),%ecx
f0104a38:	39 ce                	cmp    %ecx,%esi
f0104a3a:	73 06                	jae    f0104a42 <debuginfo_eip+0x198>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104a3c:	03 75 b8             	add    -0x48(%ebp),%esi
f0104a3f:	89 73 08             	mov    %esi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104a42:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0104a45:	8b 4e 08             	mov    0x8(%esi),%ecx
f0104a48:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0104a4b:	29 cf                	sub    %ecx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0104a4d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104a50:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0104a53:	eb 0f                	jmp    f0104a64 <debuginfo_eip+0x1ba>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104a55:	89 7b 10             	mov    %edi,0x10(%ebx)
		lline = lfile;
f0104a58:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104a5b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104a5e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104a61:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104a64:	83 ec 08             	sub    $0x8,%esp
f0104a67:	6a 3a                	push   $0x3a
f0104a69:	ff 73 08             	pushl  0x8(%ebx)
f0104a6c:	e8 97 08 00 00       	call   f0105308 <strfind>
f0104a71:	2b 43 08             	sub    0x8(%ebx),%eax
f0104a74:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.


	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104a77:	83 c4 08             	add    $0x8,%esp
f0104a7a:	57                   	push   %edi
f0104a7b:	6a 44                	push   $0x44
f0104a7d:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104a80:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104a83:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0104a86:	89 f0                	mov    %esi,%eax
f0104a88:	e8 27 fd ff ff       	call   f01047b4 <stab_binsearch>
	if (lline == 0)
f0104a8d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0104a90:	83 c4 10             	add    $0x10,%esp
f0104a93:	85 d2                	test   %edx,%edx
f0104a95:	0f 84 e6 00 00 00    	je     f0104b81 <debuginfo_eip+0x2d7>
		return -1;
	// cprintf("[+] %d, %d, %d, %x\n", lline, rline, lfun, stabs[lfun].n_value);
	info->eip_line = stabs[rline].n_desc;
f0104a9b:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104a9e:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104aa1:	0f b7 44 86 06       	movzwl 0x6(%esi,%eax,4),%eax
f0104aa6:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104aa9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104aac:	89 d0                	mov    %edx,%eax
f0104aae:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104ab1:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0104ab4:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0104ab8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104abb:	eb 0a                	jmp    f0104ac7 <debuginfo_eip+0x21d>
f0104abd:	83 e8 01             	sub    $0x1,%eax
f0104ac0:	83 ea 0c             	sub    $0xc,%edx
f0104ac3:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0104ac7:	39 c7                	cmp    %eax,%edi
f0104ac9:	7e 05                	jle    f0104ad0 <debuginfo_eip+0x226>
f0104acb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104ace:	eb 47                	jmp    f0104b17 <debuginfo_eip+0x26d>
	       && stabs[lline].n_type != N_SOL
f0104ad0:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104ad4:	80 f9 84             	cmp    $0x84,%cl
f0104ad7:	75 0e                	jne    f0104ae7 <debuginfo_eip+0x23d>
f0104ad9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104adc:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104ae0:	74 1c                	je     f0104afe <debuginfo_eip+0x254>
f0104ae2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104ae5:	eb 17                	jmp    f0104afe <debuginfo_eip+0x254>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104ae7:	80 f9 64             	cmp    $0x64,%cl
f0104aea:	75 d1                	jne    f0104abd <debuginfo_eip+0x213>
f0104aec:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0104af0:	74 cb                	je     f0104abd <debuginfo_eip+0x213>
f0104af2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104af5:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104af9:	74 03                	je     f0104afe <debuginfo_eip+0x254>
f0104afb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104afe:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104b01:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104b04:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0104b07:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104b0a:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0104b0d:	29 f8                	sub    %edi,%eax
f0104b0f:	39 c2                	cmp    %eax,%edx
f0104b11:	73 04                	jae    f0104b17 <debuginfo_eip+0x26d>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104b13:	01 fa                	add    %edi,%edx
f0104b15:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104b17:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104b1a:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104b1d:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104b22:	39 f2                	cmp    %esi,%edx
f0104b24:	7d 67                	jge    f0104b8d <debuginfo_eip+0x2e3>
		for (lline = lfun + 1;
f0104b26:	83 c2 01             	add    $0x1,%edx
f0104b29:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104b2c:	89 d0                	mov    %edx,%eax
f0104b2e:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104b31:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104b34:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0104b37:	eb 04                	jmp    f0104b3d <debuginfo_eip+0x293>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104b39:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104b3d:	39 c6                	cmp    %eax,%esi
f0104b3f:	7e 47                	jle    f0104b88 <debuginfo_eip+0x2de>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104b41:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104b45:	83 c0 01             	add    $0x1,%eax
f0104b48:	83 c2 0c             	add    $0xc,%edx
f0104b4b:	80 f9 a0             	cmp    $0xa0,%cl
f0104b4e:	74 e9                	je     f0104b39 <debuginfo_eip+0x28f>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104b50:	b8 00 00 00 00       	mov    $0x0,%eax
f0104b55:	eb 36                	jmp    f0104b8d <debuginfo_eip+0x2e3>
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0 ||
			user_mem_check(curenv, stabs, stab_end-stabs, PTE_U) < 0 ||
			user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U) < 0
		)
			return -1;
f0104b57:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104b5c:	eb 2f                	jmp    f0104b8d <debuginfo_eip+0x2e3>
f0104b5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104b63:	eb 28                	jmp    f0104b8d <debuginfo_eip+0x2e3>
f0104b65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104b6a:	eb 21                	jmp    f0104b8d <debuginfo_eip+0x2e3>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104b6c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104b71:	eb 1a                	jmp    f0104b8d <debuginfo_eip+0x2e3>
f0104b73:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104b78:	eb 13                	jmp    f0104b8d <debuginfo_eip+0x2e3>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0104b7a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104b7f:	eb 0c                	jmp    f0104b8d <debuginfo_eip+0x2e3>
	// Your code here.


	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline == 0)
		return -1;
f0104b81:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104b86:	eb 05                	jmp    f0104b8d <debuginfo_eip+0x2e3>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104b88:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104b8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104b90:	5b                   	pop    %ebx
f0104b91:	5e                   	pop    %esi
f0104b92:	5f                   	pop    %edi
f0104b93:	5d                   	pop    %ebp
f0104b94:	c3                   	ret    

f0104b95 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104b95:	55                   	push   %ebp
f0104b96:	89 e5                	mov    %esp,%ebp
f0104b98:	57                   	push   %edi
f0104b99:	56                   	push   %esi
f0104b9a:	53                   	push   %ebx
f0104b9b:	83 ec 1c             	sub    $0x1c,%esp
f0104b9e:	89 c7                	mov    %eax,%edi
f0104ba0:	89 d6                	mov    %edx,%esi
f0104ba2:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ba5:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104ba8:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104bab:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104bae:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104bb1:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104bb6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104bb9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104bbc:	39 d3                	cmp    %edx,%ebx
f0104bbe:	72 05                	jb     f0104bc5 <printnum+0x30>
f0104bc0:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104bc3:	77 45                	ja     f0104c0a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104bc5:	83 ec 0c             	sub    $0xc,%esp
f0104bc8:	ff 75 18             	pushl  0x18(%ebp)
f0104bcb:	8b 45 14             	mov    0x14(%ebp),%eax
f0104bce:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0104bd1:	53                   	push   %ebx
f0104bd2:	ff 75 10             	pushl  0x10(%ebp)
f0104bd5:	83 ec 08             	sub    $0x8,%esp
f0104bd8:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104bdb:	ff 75 e0             	pushl  -0x20(%ebp)
f0104bde:	ff 75 dc             	pushl  -0x24(%ebp)
f0104be1:	ff 75 d8             	pushl  -0x28(%ebp)
f0104be4:	e8 57 11 00 00       	call   f0105d40 <__udivdi3>
f0104be9:	83 c4 18             	add    $0x18,%esp
f0104bec:	52                   	push   %edx
f0104bed:	50                   	push   %eax
f0104bee:	89 f2                	mov    %esi,%edx
f0104bf0:	89 f8                	mov    %edi,%eax
f0104bf2:	e8 9e ff ff ff       	call   f0104b95 <printnum>
f0104bf7:	83 c4 20             	add    $0x20,%esp
f0104bfa:	eb 18                	jmp    f0104c14 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104bfc:	83 ec 08             	sub    $0x8,%esp
f0104bff:	56                   	push   %esi
f0104c00:	ff 75 18             	pushl  0x18(%ebp)
f0104c03:	ff d7                	call   *%edi
f0104c05:	83 c4 10             	add    $0x10,%esp
f0104c08:	eb 03                	jmp    f0104c0d <printnum+0x78>
f0104c0a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104c0d:	83 eb 01             	sub    $0x1,%ebx
f0104c10:	85 db                	test   %ebx,%ebx
f0104c12:	7f e8                	jg     f0104bfc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104c14:	83 ec 08             	sub    $0x8,%esp
f0104c17:	56                   	push   %esi
f0104c18:	83 ec 04             	sub    $0x4,%esp
f0104c1b:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104c1e:	ff 75 e0             	pushl  -0x20(%ebp)
f0104c21:	ff 75 dc             	pushl  -0x24(%ebp)
f0104c24:	ff 75 d8             	pushl  -0x28(%ebp)
f0104c27:	e8 44 12 00 00       	call   f0105e70 <__umoddi3>
f0104c2c:	83 c4 14             	add    $0x14,%esp
f0104c2f:	0f be 80 b6 78 10 f0 	movsbl -0xfef874a(%eax),%eax
f0104c36:	50                   	push   %eax
f0104c37:	ff d7                	call   *%edi
}
f0104c39:	83 c4 10             	add    $0x10,%esp
f0104c3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104c3f:	5b                   	pop    %ebx
f0104c40:	5e                   	pop    %esi
f0104c41:	5f                   	pop    %edi
f0104c42:	5d                   	pop    %ebp
f0104c43:	c3                   	ret    

f0104c44 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0104c44:	55                   	push   %ebp
f0104c45:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0104c47:	83 fa 01             	cmp    $0x1,%edx
f0104c4a:	7e 0e                	jle    f0104c5a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0104c4c:	8b 10                	mov    (%eax),%edx
f0104c4e:	8d 4a 08             	lea    0x8(%edx),%ecx
f0104c51:	89 08                	mov    %ecx,(%eax)
f0104c53:	8b 02                	mov    (%edx),%eax
f0104c55:	8b 52 04             	mov    0x4(%edx),%edx
f0104c58:	eb 22                	jmp    f0104c7c <getuint+0x38>
	else if (lflag)
f0104c5a:	85 d2                	test   %edx,%edx
f0104c5c:	74 10                	je     f0104c6e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0104c5e:	8b 10                	mov    (%eax),%edx
f0104c60:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104c63:	89 08                	mov    %ecx,(%eax)
f0104c65:	8b 02                	mov    (%edx),%eax
f0104c67:	ba 00 00 00 00       	mov    $0x0,%edx
f0104c6c:	eb 0e                	jmp    f0104c7c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0104c6e:	8b 10                	mov    (%eax),%edx
f0104c70:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104c73:	89 08                	mov    %ecx,(%eax)
f0104c75:	8b 02                	mov    (%edx),%eax
f0104c77:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0104c7c:	5d                   	pop    %ebp
f0104c7d:	c3                   	ret    

f0104c7e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104c7e:	55                   	push   %ebp
f0104c7f:	89 e5                	mov    %esp,%ebp
f0104c81:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104c84:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104c88:	8b 10                	mov    (%eax),%edx
f0104c8a:	3b 50 04             	cmp    0x4(%eax),%edx
f0104c8d:	73 0a                	jae    f0104c99 <sprintputch+0x1b>
		*b->buf++ = ch;
f0104c8f:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104c92:	89 08                	mov    %ecx,(%eax)
f0104c94:	8b 45 08             	mov    0x8(%ebp),%eax
f0104c97:	88 02                	mov    %al,(%edx)
}
f0104c99:	5d                   	pop    %ebp
f0104c9a:	c3                   	ret    

f0104c9b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0104c9b:	55                   	push   %ebp
f0104c9c:	89 e5                	mov    %esp,%ebp
f0104c9e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0104ca1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104ca4:	50                   	push   %eax
f0104ca5:	ff 75 10             	pushl  0x10(%ebp)
f0104ca8:	ff 75 0c             	pushl  0xc(%ebp)
f0104cab:	ff 75 08             	pushl  0x8(%ebp)
f0104cae:	e8 05 00 00 00       	call   f0104cb8 <vprintfmt>
	va_end(ap);
}
f0104cb3:	83 c4 10             	add    $0x10,%esp
f0104cb6:	c9                   	leave  
f0104cb7:	c3                   	ret    

f0104cb8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0104cb8:	55                   	push   %ebp
f0104cb9:	89 e5                	mov    %esp,%ebp
f0104cbb:	57                   	push   %edi
f0104cbc:	56                   	push   %esi
f0104cbd:	53                   	push   %ebx
f0104cbe:	83 ec 2c             	sub    $0x2c,%esp
f0104cc1:	8b 75 08             	mov    0x8(%ebp),%esi
f0104cc4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104cc7:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104cca:	eb 12                	jmp    f0104cde <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0104ccc:	85 c0                	test   %eax,%eax
f0104cce:	0f 84 89 03 00 00    	je     f010505d <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0104cd4:	83 ec 08             	sub    $0x8,%esp
f0104cd7:	53                   	push   %ebx
f0104cd8:	50                   	push   %eax
f0104cd9:	ff d6                	call   *%esi
f0104cdb:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104cde:	83 c7 01             	add    $0x1,%edi
f0104ce1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104ce5:	83 f8 25             	cmp    $0x25,%eax
f0104ce8:	75 e2                	jne    f0104ccc <vprintfmt+0x14>
f0104cea:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0104cee:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0104cf5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104cfc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0104d03:	ba 00 00 00 00       	mov    $0x0,%edx
f0104d08:	eb 07                	jmp    f0104d11 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104d0a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0104d0d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104d11:	8d 47 01             	lea    0x1(%edi),%eax
f0104d14:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104d17:	0f b6 07             	movzbl (%edi),%eax
f0104d1a:	0f b6 c8             	movzbl %al,%ecx
f0104d1d:	83 e8 23             	sub    $0x23,%eax
f0104d20:	3c 55                	cmp    $0x55,%al
f0104d22:	0f 87 1a 03 00 00    	ja     f0105042 <vprintfmt+0x38a>
f0104d28:	0f b6 c0             	movzbl %al,%eax
f0104d2b:	ff 24 85 80 79 10 f0 	jmp    *-0xfef8680(,%eax,4)
f0104d32:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0104d35:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0104d39:	eb d6                	jmp    f0104d11 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104d3b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104d3e:	b8 00 00 00 00       	mov    $0x0,%eax
f0104d43:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104d46:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104d49:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0104d4d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0104d50:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0104d53:	83 fa 09             	cmp    $0x9,%edx
f0104d56:	77 39                	ja     f0104d91 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104d58:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0104d5b:	eb e9                	jmp    f0104d46 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0104d5d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d60:	8d 48 04             	lea    0x4(%eax),%ecx
f0104d63:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0104d66:	8b 00                	mov    (%eax),%eax
f0104d68:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104d6b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0104d6e:	eb 27                	jmp    f0104d97 <vprintfmt+0xdf>
f0104d70:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104d73:	85 c0                	test   %eax,%eax
f0104d75:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104d7a:	0f 49 c8             	cmovns %eax,%ecx
f0104d7d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104d80:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104d83:	eb 8c                	jmp    f0104d11 <vprintfmt+0x59>
f0104d85:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0104d88:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0104d8f:	eb 80                	jmp    f0104d11 <vprintfmt+0x59>
f0104d91:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104d94:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0104d97:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104d9b:	0f 89 70 ff ff ff    	jns    f0104d11 <vprintfmt+0x59>
				width = precision, precision = -1;
f0104da1:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104da4:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104da7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104dae:	e9 5e ff ff ff       	jmp    f0104d11 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0104db3:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104db6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0104db9:	e9 53 ff ff ff       	jmp    f0104d11 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0104dbe:	8b 45 14             	mov    0x14(%ebp),%eax
f0104dc1:	8d 50 04             	lea    0x4(%eax),%edx
f0104dc4:	89 55 14             	mov    %edx,0x14(%ebp)
f0104dc7:	83 ec 08             	sub    $0x8,%esp
f0104dca:	53                   	push   %ebx
f0104dcb:	ff 30                	pushl  (%eax)
f0104dcd:	ff d6                	call   *%esi
			break;
f0104dcf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104dd2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0104dd5:	e9 04 ff ff ff       	jmp    f0104cde <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0104dda:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ddd:	8d 50 04             	lea    0x4(%eax),%edx
f0104de0:	89 55 14             	mov    %edx,0x14(%ebp)
f0104de3:	8b 00                	mov    (%eax),%eax
f0104de5:	99                   	cltd   
f0104de6:	31 d0                	xor    %edx,%eax
f0104de8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104dea:	83 f8 08             	cmp    $0x8,%eax
f0104ded:	7f 0b                	jg     f0104dfa <vprintfmt+0x142>
f0104def:	8b 14 85 e0 7a 10 f0 	mov    -0xfef8520(,%eax,4),%edx
f0104df6:	85 d2                	test   %edx,%edx
f0104df8:	75 18                	jne    f0104e12 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0104dfa:	50                   	push   %eax
f0104dfb:	68 ce 78 10 f0       	push   $0xf01078ce
f0104e00:	53                   	push   %ebx
f0104e01:	56                   	push   %esi
f0104e02:	e8 94 fe ff ff       	call   f0104c9b <printfmt>
f0104e07:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104e0a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0104e0d:	e9 cc fe ff ff       	jmp    f0104cde <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0104e12:	52                   	push   %edx
f0104e13:	68 f7 65 10 f0       	push   $0xf01065f7
f0104e18:	53                   	push   %ebx
f0104e19:	56                   	push   %esi
f0104e1a:	e8 7c fe ff ff       	call   f0104c9b <printfmt>
f0104e1f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104e22:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104e25:	e9 b4 fe ff ff       	jmp    f0104cde <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0104e2a:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e2d:	8d 50 04             	lea    0x4(%eax),%edx
f0104e30:	89 55 14             	mov    %edx,0x14(%ebp)
f0104e33:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0104e35:	85 ff                	test   %edi,%edi
f0104e37:	b8 c7 78 10 f0       	mov    $0xf01078c7,%eax
f0104e3c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0104e3f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104e43:	0f 8e 94 00 00 00    	jle    f0104edd <vprintfmt+0x225>
f0104e49:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0104e4d:	0f 84 98 00 00 00    	je     f0104eeb <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0104e53:	83 ec 08             	sub    $0x8,%esp
f0104e56:	ff 75 d0             	pushl  -0x30(%ebp)
f0104e59:	57                   	push   %edi
f0104e5a:	e8 5f 03 00 00       	call   f01051be <strnlen>
f0104e5f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104e62:	29 c1                	sub    %eax,%ecx
f0104e64:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0104e67:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0104e6a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0104e6e:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104e71:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0104e74:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104e76:	eb 0f                	jmp    f0104e87 <vprintfmt+0x1cf>
					putch(padc, putdat);
f0104e78:	83 ec 08             	sub    $0x8,%esp
f0104e7b:	53                   	push   %ebx
f0104e7c:	ff 75 e0             	pushl  -0x20(%ebp)
f0104e7f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104e81:	83 ef 01             	sub    $0x1,%edi
f0104e84:	83 c4 10             	add    $0x10,%esp
f0104e87:	85 ff                	test   %edi,%edi
f0104e89:	7f ed                	jg     f0104e78 <vprintfmt+0x1c0>
f0104e8b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104e8e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0104e91:	85 c9                	test   %ecx,%ecx
f0104e93:	b8 00 00 00 00       	mov    $0x0,%eax
f0104e98:	0f 49 c1             	cmovns %ecx,%eax
f0104e9b:	29 c1                	sub    %eax,%ecx
f0104e9d:	89 75 08             	mov    %esi,0x8(%ebp)
f0104ea0:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104ea3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104ea6:	89 cb                	mov    %ecx,%ebx
f0104ea8:	eb 4d                	jmp    f0104ef7 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0104eaa:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0104eae:	74 1b                	je     f0104ecb <vprintfmt+0x213>
f0104eb0:	0f be c0             	movsbl %al,%eax
f0104eb3:	83 e8 20             	sub    $0x20,%eax
f0104eb6:	83 f8 5e             	cmp    $0x5e,%eax
f0104eb9:	76 10                	jbe    f0104ecb <vprintfmt+0x213>
					putch('?', putdat);
f0104ebb:	83 ec 08             	sub    $0x8,%esp
f0104ebe:	ff 75 0c             	pushl  0xc(%ebp)
f0104ec1:	6a 3f                	push   $0x3f
f0104ec3:	ff 55 08             	call   *0x8(%ebp)
f0104ec6:	83 c4 10             	add    $0x10,%esp
f0104ec9:	eb 0d                	jmp    f0104ed8 <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0104ecb:	83 ec 08             	sub    $0x8,%esp
f0104ece:	ff 75 0c             	pushl  0xc(%ebp)
f0104ed1:	52                   	push   %edx
f0104ed2:	ff 55 08             	call   *0x8(%ebp)
f0104ed5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104ed8:	83 eb 01             	sub    $0x1,%ebx
f0104edb:	eb 1a                	jmp    f0104ef7 <vprintfmt+0x23f>
f0104edd:	89 75 08             	mov    %esi,0x8(%ebp)
f0104ee0:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104ee3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104ee6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104ee9:	eb 0c                	jmp    f0104ef7 <vprintfmt+0x23f>
f0104eeb:	89 75 08             	mov    %esi,0x8(%ebp)
f0104eee:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104ef1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104ef4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104ef7:	83 c7 01             	add    $0x1,%edi
f0104efa:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104efe:	0f be d0             	movsbl %al,%edx
f0104f01:	85 d2                	test   %edx,%edx
f0104f03:	74 23                	je     f0104f28 <vprintfmt+0x270>
f0104f05:	85 f6                	test   %esi,%esi
f0104f07:	78 a1                	js     f0104eaa <vprintfmt+0x1f2>
f0104f09:	83 ee 01             	sub    $0x1,%esi
f0104f0c:	79 9c                	jns    f0104eaa <vprintfmt+0x1f2>
f0104f0e:	89 df                	mov    %ebx,%edi
f0104f10:	8b 75 08             	mov    0x8(%ebp),%esi
f0104f13:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104f16:	eb 18                	jmp    f0104f30 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0104f18:	83 ec 08             	sub    $0x8,%esp
f0104f1b:	53                   	push   %ebx
f0104f1c:	6a 20                	push   $0x20
f0104f1e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104f20:	83 ef 01             	sub    $0x1,%edi
f0104f23:	83 c4 10             	add    $0x10,%esp
f0104f26:	eb 08                	jmp    f0104f30 <vprintfmt+0x278>
f0104f28:	89 df                	mov    %ebx,%edi
f0104f2a:	8b 75 08             	mov    0x8(%ebp),%esi
f0104f2d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104f30:	85 ff                	test   %edi,%edi
f0104f32:	7f e4                	jg     f0104f18 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104f34:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104f37:	e9 a2 fd ff ff       	jmp    f0104cde <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0104f3c:	83 fa 01             	cmp    $0x1,%edx
f0104f3f:	7e 16                	jle    f0104f57 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0104f41:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f44:	8d 50 08             	lea    0x8(%eax),%edx
f0104f47:	89 55 14             	mov    %edx,0x14(%ebp)
f0104f4a:	8b 50 04             	mov    0x4(%eax),%edx
f0104f4d:	8b 00                	mov    (%eax),%eax
f0104f4f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104f52:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104f55:	eb 32                	jmp    f0104f89 <vprintfmt+0x2d1>
	else if (lflag)
f0104f57:	85 d2                	test   %edx,%edx
f0104f59:	74 18                	je     f0104f73 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0104f5b:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f5e:	8d 50 04             	lea    0x4(%eax),%edx
f0104f61:	89 55 14             	mov    %edx,0x14(%ebp)
f0104f64:	8b 00                	mov    (%eax),%eax
f0104f66:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104f69:	89 c1                	mov    %eax,%ecx
f0104f6b:	c1 f9 1f             	sar    $0x1f,%ecx
f0104f6e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0104f71:	eb 16                	jmp    f0104f89 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0104f73:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f76:	8d 50 04             	lea    0x4(%eax),%edx
f0104f79:	89 55 14             	mov    %edx,0x14(%ebp)
f0104f7c:	8b 00                	mov    (%eax),%eax
f0104f7e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104f81:	89 c1                	mov    %eax,%ecx
f0104f83:	c1 f9 1f             	sar    $0x1f,%ecx
f0104f86:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0104f89:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104f8c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0104f8f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0104f94:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0104f98:	79 74                	jns    f010500e <vprintfmt+0x356>
				putch('-', putdat);
f0104f9a:	83 ec 08             	sub    $0x8,%esp
f0104f9d:	53                   	push   %ebx
f0104f9e:	6a 2d                	push   $0x2d
f0104fa0:	ff d6                	call   *%esi
				num = -(long long) num;
f0104fa2:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104fa5:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104fa8:	f7 d8                	neg    %eax
f0104faa:	83 d2 00             	adc    $0x0,%edx
f0104fad:	f7 da                	neg    %edx
f0104faf:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0104fb2:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0104fb7:	eb 55                	jmp    f010500e <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0104fb9:	8d 45 14             	lea    0x14(%ebp),%eax
f0104fbc:	e8 83 fc ff ff       	call   f0104c44 <getuint>
			base = 10;
f0104fc1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0104fc6:	eb 46                	jmp    f010500e <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
f0104fc8:	8d 45 14             	lea    0x14(%ebp),%eax
f0104fcb:	e8 74 fc ff ff       	call   f0104c44 <getuint>
			base = 8;
f0104fd0:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0104fd5:	eb 37                	jmp    f010500e <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
f0104fd7:	83 ec 08             	sub    $0x8,%esp
f0104fda:	53                   	push   %ebx
f0104fdb:	6a 30                	push   $0x30
f0104fdd:	ff d6                	call   *%esi
			putch('x', putdat);
f0104fdf:	83 c4 08             	add    $0x8,%esp
f0104fe2:	53                   	push   %ebx
f0104fe3:	6a 78                	push   $0x78
f0104fe5:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0104fe7:	8b 45 14             	mov    0x14(%ebp),%eax
f0104fea:	8d 50 04             	lea    0x4(%eax),%edx
f0104fed:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0104ff0:	8b 00                	mov    (%eax),%eax
f0104ff2:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0104ff7:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0104ffa:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0104fff:	eb 0d                	jmp    f010500e <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0105001:	8d 45 14             	lea    0x14(%ebp),%eax
f0105004:	e8 3b fc ff ff       	call   f0104c44 <getuint>
			base = 16;
f0105009:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f010500e:	83 ec 0c             	sub    $0xc,%esp
f0105011:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0105015:	57                   	push   %edi
f0105016:	ff 75 e0             	pushl  -0x20(%ebp)
f0105019:	51                   	push   %ecx
f010501a:	52                   	push   %edx
f010501b:	50                   	push   %eax
f010501c:	89 da                	mov    %ebx,%edx
f010501e:	89 f0                	mov    %esi,%eax
f0105020:	e8 70 fb ff ff       	call   f0104b95 <printnum>
			break;
f0105025:	83 c4 20             	add    $0x20,%esp
f0105028:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010502b:	e9 ae fc ff ff       	jmp    f0104cde <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105030:	83 ec 08             	sub    $0x8,%esp
f0105033:	53                   	push   %ebx
f0105034:	51                   	push   %ecx
f0105035:	ff d6                	call   *%esi
			break;
f0105037:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010503a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f010503d:	e9 9c fc ff ff       	jmp    f0104cde <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105042:	83 ec 08             	sub    $0x8,%esp
f0105045:	53                   	push   %ebx
f0105046:	6a 25                	push   $0x25
f0105048:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f010504a:	83 c4 10             	add    $0x10,%esp
f010504d:	eb 03                	jmp    f0105052 <vprintfmt+0x39a>
f010504f:	83 ef 01             	sub    $0x1,%edi
f0105052:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0105056:	75 f7                	jne    f010504f <vprintfmt+0x397>
f0105058:	e9 81 fc ff ff       	jmp    f0104cde <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f010505d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105060:	5b                   	pop    %ebx
f0105061:	5e                   	pop    %esi
f0105062:	5f                   	pop    %edi
f0105063:	5d                   	pop    %ebp
f0105064:	c3                   	ret    

f0105065 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105065:	55                   	push   %ebp
f0105066:	89 e5                	mov    %esp,%ebp
f0105068:	83 ec 18             	sub    $0x18,%esp
f010506b:	8b 45 08             	mov    0x8(%ebp),%eax
f010506e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105071:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105074:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105078:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010507b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105082:	85 c0                	test   %eax,%eax
f0105084:	74 26                	je     f01050ac <vsnprintf+0x47>
f0105086:	85 d2                	test   %edx,%edx
f0105088:	7e 22                	jle    f01050ac <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010508a:	ff 75 14             	pushl  0x14(%ebp)
f010508d:	ff 75 10             	pushl  0x10(%ebp)
f0105090:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105093:	50                   	push   %eax
f0105094:	68 7e 4c 10 f0       	push   $0xf0104c7e
f0105099:	e8 1a fc ff ff       	call   f0104cb8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010509e:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01050a1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01050a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01050a7:	83 c4 10             	add    $0x10,%esp
f01050aa:	eb 05                	jmp    f01050b1 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01050ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01050b1:	c9                   	leave  
f01050b2:	c3                   	ret    

f01050b3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01050b3:	55                   	push   %ebp
f01050b4:	89 e5                	mov    %esp,%ebp
f01050b6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01050b9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01050bc:	50                   	push   %eax
f01050bd:	ff 75 10             	pushl  0x10(%ebp)
f01050c0:	ff 75 0c             	pushl  0xc(%ebp)
f01050c3:	ff 75 08             	pushl  0x8(%ebp)
f01050c6:	e8 9a ff ff ff       	call   f0105065 <vsnprintf>
	va_end(ap);

	return rc;
}
f01050cb:	c9                   	leave  
f01050cc:	c3                   	ret    

f01050cd <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01050cd:	55                   	push   %ebp
f01050ce:	89 e5                	mov    %esp,%ebp
f01050d0:	57                   	push   %edi
f01050d1:	56                   	push   %esi
f01050d2:	53                   	push   %ebx
f01050d3:	83 ec 0c             	sub    $0xc,%esp
f01050d6:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01050d9:	85 c0                	test   %eax,%eax
f01050db:	74 11                	je     f01050ee <readline+0x21>
		cprintf("%s", prompt);
f01050dd:	83 ec 08             	sub    $0x8,%esp
f01050e0:	50                   	push   %eax
f01050e1:	68 f7 65 10 f0       	push   $0xf01065f7
f01050e6:	e8 b6 e7 ff ff       	call   f01038a1 <cprintf>
f01050eb:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01050ee:	83 ec 0c             	sub    $0xc,%esp
f01050f1:	6a 00                	push   $0x0
f01050f3:	e8 76 b6 ff ff       	call   f010076e <iscons>
f01050f8:	89 c7                	mov    %eax,%edi
f01050fa:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01050fd:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0105102:	e8 56 b6 ff ff       	call   f010075d <getchar>
f0105107:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105109:	85 c0                	test   %eax,%eax
f010510b:	79 18                	jns    f0105125 <readline+0x58>
			cprintf("read error: %e\n", c);
f010510d:	83 ec 08             	sub    $0x8,%esp
f0105110:	50                   	push   %eax
f0105111:	68 04 7b 10 f0       	push   $0xf0107b04
f0105116:	e8 86 e7 ff ff       	call   f01038a1 <cprintf>
			return NULL;
f010511b:	83 c4 10             	add    $0x10,%esp
f010511e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105123:	eb 79                	jmp    f010519e <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105125:	83 f8 08             	cmp    $0x8,%eax
f0105128:	0f 94 c2             	sete   %dl
f010512b:	83 f8 7f             	cmp    $0x7f,%eax
f010512e:	0f 94 c0             	sete   %al
f0105131:	08 c2                	or     %al,%dl
f0105133:	74 1a                	je     f010514f <readline+0x82>
f0105135:	85 f6                	test   %esi,%esi
f0105137:	7e 16                	jle    f010514f <readline+0x82>
			if (echoing)
f0105139:	85 ff                	test   %edi,%edi
f010513b:	74 0d                	je     f010514a <readline+0x7d>
				cputchar('\b');
f010513d:	83 ec 0c             	sub    $0xc,%esp
f0105140:	6a 08                	push   $0x8
f0105142:	e8 06 b6 ff ff       	call   f010074d <cputchar>
f0105147:	83 c4 10             	add    $0x10,%esp
			i--;
f010514a:	83 ee 01             	sub    $0x1,%esi
f010514d:	eb b3                	jmp    f0105102 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010514f:	83 fb 1f             	cmp    $0x1f,%ebx
f0105152:	7e 23                	jle    f0105177 <readline+0xaa>
f0105154:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010515a:	7f 1b                	jg     f0105177 <readline+0xaa>
			if (echoing)
f010515c:	85 ff                	test   %edi,%edi
f010515e:	74 0c                	je     f010516c <readline+0x9f>
				cputchar(c);
f0105160:	83 ec 0c             	sub    $0xc,%esp
f0105163:	53                   	push   %ebx
f0105164:	e8 e4 b5 ff ff       	call   f010074d <cputchar>
f0105169:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f010516c:	88 9e 80 ba 22 f0    	mov    %bl,-0xfdd4580(%esi)
f0105172:	8d 76 01             	lea    0x1(%esi),%esi
f0105175:	eb 8b                	jmp    f0105102 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0105177:	83 fb 0a             	cmp    $0xa,%ebx
f010517a:	74 05                	je     f0105181 <readline+0xb4>
f010517c:	83 fb 0d             	cmp    $0xd,%ebx
f010517f:	75 81                	jne    f0105102 <readline+0x35>
			if (echoing)
f0105181:	85 ff                	test   %edi,%edi
f0105183:	74 0d                	je     f0105192 <readline+0xc5>
				cputchar('\n');
f0105185:	83 ec 0c             	sub    $0xc,%esp
f0105188:	6a 0a                	push   $0xa
f010518a:	e8 be b5 ff ff       	call   f010074d <cputchar>
f010518f:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0105192:	c6 86 80 ba 22 f0 00 	movb   $0x0,-0xfdd4580(%esi)
			return buf;
f0105199:	b8 80 ba 22 f0       	mov    $0xf022ba80,%eax
		}
	}
}
f010519e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01051a1:	5b                   	pop    %ebx
f01051a2:	5e                   	pop    %esi
f01051a3:	5f                   	pop    %edi
f01051a4:	5d                   	pop    %ebp
f01051a5:	c3                   	ret    

f01051a6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01051a6:	55                   	push   %ebp
f01051a7:	89 e5                	mov    %esp,%ebp
f01051a9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01051ac:	b8 00 00 00 00       	mov    $0x0,%eax
f01051b1:	eb 03                	jmp    f01051b6 <strlen+0x10>
		n++;
f01051b3:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01051b6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01051ba:	75 f7                	jne    f01051b3 <strlen+0xd>
		n++;
	return n;
}
f01051bc:	5d                   	pop    %ebp
f01051bd:	c3                   	ret    

f01051be <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01051be:	55                   	push   %ebp
f01051bf:	89 e5                	mov    %esp,%ebp
f01051c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01051c4:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01051c7:	ba 00 00 00 00       	mov    $0x0,%edx
f01051cc:	eb 03                	jmp    f01051d1 <strnlen+0x13>
		n++;
f01051ce:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01051d1:	39 c2                	cmp    %eax,%edx
f01051d3:	74 08                	je     f01051dd <strnlen+0x1f>
f01051d5:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f01051d9:	75 f3                	jne    f01051ce <strnlen+0x10>
f01051db:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f01051dd:	5d                   	pop    %ebp
f01051de:	c3                   	ret    

f01051df <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01051df:	55                   	push   %ebp
f01051e0:	89 e5                	mov    %esp,%ebp
f01051e2:	53                   	push   %ebx
f01051e3:	8b 45 08             	mov    0x8(%ebp),%eax
f01051e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01051e9:	89 c2                	mov    %eax,%edx
f01051eb:	83 c2 01             	add    $0x1,%edx
f01051ee:	83 c1 01             	add    $0x1,%ecx
f01051f1:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01051f5:	88 5a ff             	mov    %bl,-0x1(%edx)
f01051f8:	84 db                	test   %bl,%bl
f01051fa:	75 ef                	jne    f01051eb <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01051fc:	5b                   	pop    %ebx
f01051fd:	5d                   	pop    %ebp
f01051fe:	c3                   	ret    

f01051ff <strcat>:

char *
strcat(char *dst, const char *src)
{
f01051ff:	55                   	push   %ebp
f0105200:	89 e5                	mov    %esp,%ebp
f0105202:	53                   	push   %ebx
f0105203:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105206:	53                   	push   %ebx
f0105207:	e8 9a ff ff ff       	call   f01051a6 <strlen>
f010520c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010520f:	ff 75 0c             	pushl  0xc(%ebp)
f0105212:	01 d8                	add    %ebx,%eax
f0105214:	50                   	push   %eax
f0105215:	e8 c5 ff ff ff       	call   f01051df <strcpy>
	return dst;
}
f010521a:	89 d8                	mov    %ebx,%eax
f010521c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010521f:	c9                   	leave  
f0105220:	c3                   	ret    

f0105221 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105221:	55                   	push   %ebp
f0105222:	89 e5                	mov    %esp,%ebp
f0105224:	56                   	push   %esi
f0105225:	53                   	push   %ebx
f0105226:	8b 75 08             	mov    0x8(%ebp),%esi
f0105229:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010522c:	89 f3                	mov    %esi,%ebx
f010522e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105231:	89 f2                	mov    %esi,%edx
f0105233:	eb 0f                	jmp    f0105244 <strncpy+0x23>
		*dst++ = *src;
f0105235:	83 c2 01             	add    $0x1,%edx
f0105238:	0f b6 01             	movzbl (%ecx),%eax
f010523b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010523e:	80 39 01             	cmpb   $0x1,(%ecx)
f0105241:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105244:	39 da                	cmp    %ebx,%edx
f0105246:	75 ed                	jne    f0105235 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105248:	89 f0                	mov    %esi,%eax
f010524a:	5b                   	pop    %ebx
f010524b:	5e                   	pop    %esi
f010524c:	5d                   	pop    %ebp
f010524d:	c3                   	ret    

f010524e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010524e:	55                   	push   %ebp
f010524f:	89 e5                	mov    %esp,%ebp
f0105251:	56                   	push   %esi
f0105252:	53                   	push   %ebx
f0105253:	8b 75 08             	mov    0x8(%ebp),%esi
f0105256:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105259:	8b 55 10             	mov    0x10(%ebp),%edx
f010525c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010525e:	85 d2                	test   %edx,%edx
f0105260:	74 21                	je     f0105283 <strlcpy+0x35>
f0105262:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0105266:	89 f2                	mov    %esi,%edx
f0105268:	eb 09                	jmp    f0105273 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010526a:	83 c2 01             	add    $0x1,%edx
f010526d:	83 c1 01             	add    $0x1,%ecx
f0105270:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105273:	39 c2                	cmp    %eax,%edx
f0105275:	74 09                	je     f0105280 <strlcpy+0x32>
f0105277:	0f b6 19             	movzbl (%ecx),%ebx
f010527a:	84 db                	test   %bl,%bl
f010527c:	75 ec                	jne    f010526a <strlcpy+0x1c>
f010527e:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0105280:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105283:	29 f0                	sub    %esi,%eax
}
f0105285:	5b                   	pop    %ebx
f0105286:	5e                   	pop    %esi
f0105287:	5d                   	pop    %ebp
f0105288:	c3                   	ret    

f0105289 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105289:	55                   	push   %ebp
f010528a:	89 e5                	mov    %esp,%ebp
f010528c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010528f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105292:	eb 06                	jmp    f010529a <strcmp+0x11>
		p++, q++;
f0105294:	83 c1 01             	add    $0x1,%ecx
f0105297:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010529a:	0f b6 01             	movzbl (%ecx),%eax
f010529d:	84 c0                	test   %al,%al
f010529f:	74 04                	je     f01052a5 <strcmp+0x1c>
f01052a1:	3a 02                	cmp    (%edx),%al
f01052a3:	74 ef                	je     f0105294 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01052a5:	0f b6 c0             	movzbl %al,%eax
f01052a8:	0f b6 12             	movzbl (%edx),%edx
f01052ab:	29 d0                	sub    %edx,%eax
}
f01052ad:	5d                   	pop    %ebp
f01052ae:	c3                   	ret    

f01052af <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01052af:	55                   	push   %ebp
f01052b0:	89 e5                	mov    %esp,%ebp
f01052b2:	53                   	push   %ebx
f01052b3:	8b 45 08             	mov    0x8(%ebp),%eax
f01052b6:	8b 55 0c             	mov    0xc(%ebp),%edx
f01052b9:	89 c3                	mov    %eax,%ebx
f01052bb:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01052be:	eb 06                	jmp    f01052c6 <strncmp+0x17>
		n--, p++, q++;
f01052c0:	83 c0 01             	add    $0x1,%eax
f01052c3:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01052c6:	39 d8                	cmp    %ebx,%eax
f01052c8:	74 15                	je     f01052df <strncmp+0x30>
f01052ca:	0f b6 08             	movzbl (%eax),%ecx
f01052cd:	84 c9                	test   %cl,%cl
f01052cf:	74 04                	je     f01052d5 <strncmp+0x26>
f01052d1:	3a 0a                	cmp    (%edx),%cl
f01052d3:	74 eb                	je     f01052c0 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01052d5:	0f b6 00             	movzbl (%eax),%eax
f01052d8:	0f b6 12             	movzbl (%edx),%edx
f01052db:	29 d0                	sub    %edx,%eax
f01052dd:	eb 05                	jmp    f01052e4 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01052df:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01052e4:	5b                   	pop    %ebx
f01052e5:	5d                   	pop    %ebp
f01052e6:	c3                   	ret    

f01052e7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01052e7:	55                   	push   %ebp
f01052e8:	89 e5                	mov    %esp,%ebp
f01052ea:	8b 45 08             	mov    0x8(%ebp),%eax
f01052ed:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01052f1:	eb 07                	jmp    f01052fa <strchr+0x13>
		if (*s == c)
f01052f3:	38 ca                	cmp    %cl,%dl
f01052f5:	74 0f                	je     f0105306 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01052f7:	83 c0 01             	add    $0x1,%eax
f01052fa:	0f b6 10             	movzbl (%eax),%edx
f01052fd:	84 d2                	test   %dl,%dl
f01052ff:	75 f2                	jne    f01052f3 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0105301:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105306:	5d                   	pop    %ebp
f0105307:	c3                   	ret    

f0105308 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105308:	55                   	push   %ebp
f0105309:	89 e5                	mov    %esp,%ebp
f010530b:	8b 45 08             	mov    0x8(%ebp),%eax
f010530e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105312:	eb 03                	jmp    f0105317 <strfind+0xf>
f0105314:	83 c0 01             	add    $0x1,%eax
f0105317:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010531a:	38 ca                	cmp    %cl,%dl
f010531c:	74 04                	je     f0105322 <strfind+0x1a>
f010531e:	84 d2                	test   %dl,%dl
f0105320:	75 f2                	jne    f0105314 <strfind+0xc>
			break;
	return (char *) s;
}
f0105322:	5d                   	pop    %ebp
f0105323:	c3                   	ret    

f0105324 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105324:	55                   	push   %ebp
f0105325:	89 e5                	mov    %esp,%ebp
f0105327:	57                   	push   %edi
f0105328:	56                   	push   %esi
f0105329:	53                   	push   %ebx
f010532a:	8b 7d 08             	mov    0x8(%ebp),%edi
f010532d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105330:	85 c9                	test   %ecx,%ecx
f0105332:	74 36                	je     f010536a <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105334:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010533a:	75 28                	jne    f0105364 <memset+0x40>
f010533c:	f6 c1 03             	test   $0x3,%cl
f010533f:	75 23                	jne    f0105364 <memset+0x40>
		c &= 0xFF;
f0105341:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105345:	89 d3                	mov    %edx,%ebx
f0105347:	c1 e3 08             	shl    $0x8,%ebx
f010534a:	89 d6                	mov    %edx,%esi
f010534c:	c1 e6 18             	shl    $0x18,%esi
f010534f:	89 d0                	mov    %edx,%eax
f0105351:	c1 e0 10             	shl    $0x10,%eax
f0105354:	09 f0                	or     %esi,%eax
f0105356:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0105358:	89 d8                	mov    %ebx,%eax
f010535a:	09 d0                	or     %edx,%eax
f010535c:	c1 e9 02             	shr    $0x2,%ecx
f010535f:	fc                   	cld    
f0105360:	f3 ab                	rep stos %eax,%es:(%edi)
f0105362:	eb 06                	jmp    f010536a <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105364:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105367:	fc                   	cld    
f0105368:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010536a:	89 f8                	mov    %edi,%eax
f010536c:	5b                   	pop    %ebx
f010536d:	5e                   	pop    %esi
f010536e:	5f                   	pop    %edi
f010536f:	5d                   	pop    %ebp
f0105370:	c3                   	ret    

f0105371 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105371:	55                   	push   %ebp
f0105372:	89 e5                	mov    %esp,%ebp
f0105374:	57                   	push   %edi
f0105375:	56                   	push   %esi
f0105376:	8b 45 08             	mov    0x8(%ebp),%eax
f0105379:	8b 75 0c             	mov    0xc(%ebp),%esi
f010537c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010537f:	39 c6                	cmp    %eax,%esi
f0105381:	73 35                	jae    f01053b8 <memmove+0x47>
f0105383:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105386:	39 d0                	cmp    %edx,%eax
f0105388:	73 2e                	jae    f01053b8 <memmove+0x47>
		s += n;
		d += n;
f010538a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010538d:	89 d6                	mov    %edx,%esi
f010538f:	09 fe                	or     %edi,%esi
f0105391:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105397:	75 13                	jne    f01053ac <memmove+0x3b>
f0105399:	f6 c1 03             	test   $0x3,%cl
f010539c:	75 0e                	jne    f01053ac <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f010539e:	83 ef 04             	sub    $0x4,%edi
f01053a1:	8d 72 fc             	lea    -0x4(%edx),%esi
f01053a4:	c1 e9 02             	shr    $0x2,%ecx
f01053a7:	fd                   	std    
f01053a8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01053aa:	eb 09                	jmp    f01053b5 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01053ac:	83 ef 01             	sub    $0x1,%edi
f01053af:	8d 72 ff             	lea    -0x1(%edx),%esi
f01053b2:	fd                   	std    
f01053b3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01053b5:	fc                   	cld    
f01053b6:	eb 1d                	jmp    f01053d5 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01053b8:	89 f2                	mov    %esi,%edx
f01053ba:	09 c2                	or     %eax,%edx
f01053bc:	f6 c2 03             	test   $0x3,%dl
f01053bf:	75 0f                	jne    f01053d0 <memmove+0x5f>
f01053c1:	f6 c1 03             	test   $0x3,%cl
f01053c4:	75 0a                	jne    f01053d0 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f01053c6:	c1 e9 02             	shr    $0x2,%ecx
f01053c9:	89 c7                	mov    %eax,%edi
f01053cb:	fc                   	cld    
f01053cc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01053ce:	eb 05                	jmp    f01053d5 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01053d0:	89 c7                	mov    %eax,%edi
f01053d2:	fc                   	cld    
f01053d3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01053d5:	5e                   	pop    %esi
f01053d6:	5f                   	pop    %edi
f01053d7:	5d                   	pop    %ebp
f01053d8:	c3                   	ret    

f01053d9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01053d9:	55                   	push   %ebp
f01053da:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01053dc:	ff 75 10             	pushl  0x10(%ebp)
f01053df:	ff 75 0c             	pushl  0xc(%ebp)
f01053e2:	ff 75 08             	pushl  0x8(%ebp)
f01053e5:	e8 87 ff ff ff       	call   f0105371 <memmove>
}
f01053ea:	c9                   	leave  
f01053eb:	c3                   	ret    

f01053ec <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01053ec:	55                   	push   %ebp
f01053ed:	89 e5                	mov    %esp,%ebp
f01053ef:	56                   	push   %esi
f01053f0:	53                   	push   %ebx
f01053f1:	8b 45 08             	mov    0x8(%ebp),%eax
f01053f4:	8b 55 0c             	mov    0xc(%ebp),%edx
f01053f7:	89 c6                	mov    %eax,%esi
f01053f9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01053fc:	eb 1a                	jmp    f0105418 <memcmp+0x2c>
		if (*s1 != *s2)
f01053fe:	0f b6 08             	movzbl (%eax),%ecx
f0105401:	0f b6 1a             	movzbl (%edx),%ebx
f0105404:	38 d9                	cmp    %bl,%cl
f0105406:	74 0a                	je     f0105412 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0105408:	0f b6 c1             	movzbl %cl,%eax
f010540b:	0f b6 db             	movzbl %bl,%ebx
f010540e:	29 d8                	sub    %ebx,%eax
f0105410:	eb 0f                	jmp    f0105421 <memcmp+0x35>
		s1++, s2++;
f0105412:	83 c0 01             	add    $0x1,%eax
f0105415:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105418:	39 f0                	cmp    %esi,%eax
f010541a:	75 e2                	jne    f01053fe <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010541c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105421:	5b                   	pop    %ebx
f0105422:	5e                   	pop    %esi
f0105423:	5d                   	pop    %ebp
f0105424:	c3                   	ret    

f0105425 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105425:	55                   	push   %ebp
f0105426:	89 e5                	mov    %esp,%ebp
f0105428:	53                   	push   %ebx
f0105429:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010542c:	89 c1                	mov    %eax,%ecx
f010542e:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0105431:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105435:	eb 0a                	jmp    f0105441 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105437:	0f b6 10             	movzbl (%eax),%edx
f010543a:	39 da                	cmp    %ebx,%edx
f010543c:	74 07                	je     f0105445 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010543e:	83 c0 01             	add    $0x1,%eax
f0105441:	39 c8                	cmp    %ecx,%eax
f0105443:	72 f2                	jb     f0105437 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0105445:	5b                   	pop    %ebx
f0105446:	5d                   	pop    %ebp
f0105447:	c3                   	ret    

f0105448 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105448:	55                   	push   %ebp
f0105449:	89 e5                	mov    %esp,%ebp
f010544b:	57                   	push   %edi
f010544c:	56                   	push   %esi
f010544d:	53                   	push   %ebx
f010544e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105451:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105454:	eb 03                	jmp    f0105459 <strtol+0x11>
		s++;
f0105456:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105459:	0f b6 01             	movzbl (%ecx),%eax
f010545c:	3c 20                	cmp    $0x20,%al
f010545e:	74 f6                	je     f0105456 <strtol+0xe>
f0105460:	3c 09                	cmp    $0x9,%al
f0105462:	74 f2                	je     f0105456 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0105464:	3c 2b                	cmp    $0x2b,%al
f0105466:	75 0a                	jne    f0105472 <strtol+0x2a>
		s++;
f0105468:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f010546b:	bf 00 00 00 00       	mov    $0x0,%edi
f0105470:	eb 11                	jmp    f0105483 <strtol+0x3b>
f0105472:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0105477:	3c 2d                	cmp    $0x2d,%al
f0105479:	75 08                	jne    f0105483 <strtol+0x3b>
		s++, neg = 1;
f010547b:	83 c1 01             	add    $0x1,%ecx
f010547e:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105483:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105489:	75 15                	jne    f01054a0 <strtol+0x58>
f010548b:	80 39 30             	cmpb   $0x30,(%ecx)
f010548e:	75 10                	jne    f01054a0 <strtol+0x58>
f0105490:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105494:	75 7c                	jne    f0105512 <strtol+0xca>
		s += 2, base = 16;
f0105496:	83 c1 02             	add    $0x2,%ecx
f0105499:	bb 10 00 00 00       	mov    $0x10,%ebx
f010549e:	eb 16                	jmp    f01054b6 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f01054a0:	85 db                	test   %ebx,%ebx
f01054a2:	75 12                	jne    f01054b6 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01054a4:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01054a9:	80 39 30             	cmpb   $0x30,(%ecx)
f01054ac:	75 08                	jne    f01054b6 <strtol+0x6e>
		s++, base = 8;
f01054ae:	83 c1 01             	add    $0x1,%ecx
f01054b1:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f01054b6:	b8 00 00 00 00       	mov    $0x0,%eax
f01054bb:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01054be:	0f b6 11             	movzbl (%ecx),%edx
f01054c1:	8d 72 d0             	lea    -0x30(%edx),%esi
f01054c4:	89 f3                	mov    %esi,%ebx
f01054c6:	80 fb 09             	cmp    $0x9,%bl
f01054c9:	77 08                	ja     f01054d3 <strtol+0x8b>
			dig = *s - '0';
f01054cb:	0f be d2             	movsbl %dl,%edx
f01054ce:	83 ea 30             	sub    $0x30,%edx
f01054d1:	eb 22                	jmp    f01054f5 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f01054d3:	8d 72 9f             	lea    -0x61(%edx),%esi
f01054d6:	89 f3                	mov    %esi,%ebx
f01054d8:	80 fb 19             	cmp    $0x19,%bl
f01054db:	77 08                	ja     f01054e5 <strtol+0x9d>
			dig = *s - 'a' + 10;
f01054dd:	0f be d2             	movsbl %dl,%edx
f01054e0:	83 ea 57             	sub    $0x57,%edx
f01054e3:	eb 10                	jmp    f01054f5 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f01054e5:	8d 72 bf             	lea    -0x41(%edx),%esi
f01054e8:	89 f3                	mov    %esi,%ebx
f01054ea:	80 fb 19             	cmp    $0x19,%bl
f01054ed:	77 16                	ja     f0105505 <strtol+0xbd>
			dig = *s - 'A' + 10;
f01054ef:	0f be d2             	movsbl %dl,%edx
f01054f2:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f01054f5:	3b 55 10             	cmp    0x10(%ebp),%edx
f01054f8:	7d 0b                	jge    f0105505 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f01054fa:	83 c1 01             	add    $0x1,%ecx
f01054fd:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105501:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0105503:	eb b9                	jmp    f01054be <strtol+0x76>

	if (endptr)
f0105505:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105509:	74 0d                	je     f0105518 <strtol+0xd0>
		*endptr = (char *) s;
f010550b:	8b 75 0c             	mov    0xc(%ebp),%esi
f010550e:	89 0e                	mov    %ecx,(%esi)
f0105510:	eb 06                	jmp    f0105518 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105512:	85 db                	test   %ebx,%ebx
f0105514:	74 98                	je     f01054ae <strtol+0x66>
f0105516:	eb 9e                	jmp    f01054b6 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0105518:	89 c2                	mov    %eax,%edx
f010551a:	f7 da                	neg    %edx
f010551c:	85 ff                	test   %edi,%edi
f010551e:	0f 45 c2             	cmovne %edx,%eax
}
f0105521:	5b                   	pop    %ebx
f0105522:	5e                   	pop    %esi
f0105523:	5f                   	pop    %edi
f0105524:	5d                   	pop    %ebp
f0105525:	c3                   	ret    
f0105526:	66 90                	xchg   %ax,%ax

f0105528 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105528:	fa                   	cli    

	xorw    %ax, %ax
f0105529:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f010552b:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f010552d:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f010552f:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105531:	0f 01 16             	lgdtl  (%esi)
f0105534:	74 70                	je     f01055a6 <mpsearch1+0x3>
	movl    %cr0, %eax
f0105536:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105539:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f010553d:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105540:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105546:	08 00                	or     %al,(%eax)

f0105548 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105548:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f010554c:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f010554e:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105550:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105552:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105556:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105558:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f010555a:	b8 00 e0 11 00       	mov    $0x11e000,%eax
	movl    %eax, %cr3
f010555f:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105562:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105565:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f010556a:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f010556d:	8b 25 84 be 22 f0    	mov    0xf022be84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105573:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105578:	b8 9c 01 10 f0       	mov    $0xf010019c,%eax
	call    *%eax
f010557d:	ff d0                	call   *%eax

f010557f <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f010557f:	eb fe                	jmp    f010557f <spin>
f0105581:	8d 76 00             	lea    0x0(%esi),%esi

f0105584 <gdt>:
	...
f010558c:	ff                   	(bad)  
f010558d:	ff 00                	incl   (%eax)
f010558f:	00 00                	add    %al,(%eax)
f0105591:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105598:	00                   	.byte 0x0
f0105599:	92                   	xchg   %eax,%edx
f010559a:	cf                   	iret   
	...

f010559c <gdtdesc>:
f010559c:	17                   	pop    %ss
f010559d:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f01055a2 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f01055a2:	90                   	nop

f01055a3 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f01055a3:	55                   	push   %ebp
f01055a4:	89 e5                	mov    %esp,%ebp
f01055a6:	57                   	push   %edi
f01055a7:	56                   	push   %esi
f01055a8:	53                   	push   %ebx
f01055a9:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01055ac:	8b 0d 88 be 22 f0    	mov    0xf022be88,%ecx
f01055b2:	89 c3                	mov    %eax,%ebx
f01055b4:	c1 eb 0c             	shr    $0xc,%ebx
f01055b7:	39 cb                	cmp    %ecx,%ebx
f01055b9:	72 12                	jb     f01055cd <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01055bb:	50                   	push   %eax
f01055bc:	68 04 60 10 f0       	push   $0xf0106004
f01055c1:	6a 57                	push   $0x57
f01055c3:	68 a1 7c 10 f0       	push   $0xf0107ca1
f01055c8:	e8 73 aa ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01055cd:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f01055d3:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01055d5:	89 c2                	mov    %eax,%edx
f01055d7:	c1 ea 0c             	shr    $0xc,%edx
f01055da:	39 ca                	cmp    %ecx,%edx
f01055dc:	72 12                	jb     f01055f0 <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01055de:	50                   	push   %eax
f01055df:	68 04 60 10 f0       	push   $0xf0106004
f01055e4:	6a 57                	push   $0x57
f01055e6:	68 a1 7c 10 f0       	push   $0xf0107ca1
f01055eb:	e8 50 aa ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01055f0:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f01055f6:	eb 2f                	jmp    f0105627 <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01055f8:	83 ec 04             	sub    $0x4,%esp
f01055fb:	6a 04                	push   $0x4
f01055fd:	68 b1 7c 10 f0       	push   $0xf0107cb1
f0105602:	53                   	push   %ebx
f0105603:	e8 e4 fd ff ff       	call   f01053ec <memcmp>
f0105608:	83 c4 10             	add    $0x10,%esp
f010560b:	85 c0                	test   %eax,%eax
f010560d:	75 15                	jne    f0105624 <mpsearch1+0x81>
f010560f:	89 da                	mov    %ebx,%edx
f0105611:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f0105614:	0f b6 0a             	movzbl (%edx),%ecx
f0105617:	01 c8                	add    %ecx,%eax
f0105619:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f010561c:	39 d7                	cmp    %edx,%edi
f010561e:	75 f4                	jne    f0105614 <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105620:	84 c0                	test   %al,%al
f0105622:	74 0e                	je     f0105632 <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0105624:	83 c3 10             	add    $0x10,%ebx
f0105627:	39 f3                	cmp    %esi,%ebx
f0105629:	72 cd                	jb     f01055f8 <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f010562b:	b8 00 00 00 00       	mov    $0x0,%eax
f0105630:	eb 02                	jmp    f0105634 <mpsearch1+0x91>
f0105632:	89 d8                	mov    %ebx,%eax
}
f0105634:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105637:	5b                   	pop    %ebx
f0105638:	5e                   	pop    %esi
f0105639:	5f                   	pop    %edi
f010563a:	5d                   	pop    %ebp
f010563b:	c3                   	ret    

f010563c <mp_init>:
	return conf;
}

void
mp_init(void)
{
f010563c:	55                   	push   %ebp
f010563d:	89 e5                	mov    %esp,%ebp
f010563f:	57                   	push   %edi
f0105640:	56                   	push   %esi
f0105641:	53                   	push   %ebx
f0105642:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105645:	c7 05 c0 c3 22 f0 20 	movl   $0xf022c020,0xf022c3c0
f010564c:	c0 22 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010564f:	83 3d 88 be 22 f0 00 	cmpl   $0x0,0xf022be88
f0105656:	75 16                	jne    f010566e <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105658:	68 00 04 00 00       	push   $0x400
f010565d:	68 04 60 10 f0       	push   $0xf0106004
f0105662:	6a 6f                	push   $0x6f
f0105664:	68 a1 7c 10 f0       	push   $0xf0107ca1
f0105669:	e8 d2 a9 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f010566e:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105675:	85 c0                	test   %eax,%eax
f0105677:	74 16                	je     f010568f <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f0105679:	c1 e0 04             	shl    $0x4,%eax
f010567c:	ba 00 04 00 00       	mov    $0x400,%edx
f0105681:	e8 1d ff ff ff       	call   f01055a3 <mpsearch1>
f0105686:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105689:	85 c0                	test   %eax,%eax
f010568b:	75 3c                	jne    f01056c9 <mp_init+0x8d>
f010568d:	eb 20                	jmp    f01056af <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f010568f:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105696:	c1 e0 0a             	shl    $0xa,%eax
f0105699:	2d 00 04 00 00       	sub    $0x400,%eax
f010569e:	ba 00 04 00 00       	mov    $0x400,%edx
f01056a3:	e8 fb fe ff ff       	call   f01055a3 <mpsearch1>
f01056a8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01056ab:	85 c0                	test   %eax,%eax
f01056ad:	75 1a                	jne    f01056c9 <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f01056af:	ba 00 00 01 00       	mov    $0x10000,%edx
f01056b4:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f01056b9:	e8 e5 fe ff ff       	call   f01055a3 <mpsearch1>
f01056be:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f01056c1:	85 c0                	test   %eax,%eax
f01056c3:	0f 84 5d 02 00 00    	je     f0105926 <mp_init+0x2ea>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f01056c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01056cc:	8b 70 04             	mov    0x4(%eax),%esi
f01056cf:	85 f6                	test   %esi,%esi
f01056d1:	74 06                	je     f01056d9 <mp_init+0x9d>
f01056d3:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f01056d7:	74 15                	je     f01056ee <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f01056d9:	83 ec 0c             	sub    $0xc,%esp
f01056dc:	68 14 7b 10 f0       	push   $0xf0107b14
f01056e1:	e8 bb e1 ff ff       	call   f01038a1 <cprintf>
f01056e6:	83 c4 10             	add    $0x10,%esp
f01056e9:	e9 38 02 00 00       	jmp    f0105926 <mp_init+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01056ee:	89 f0                	mov    %esi,%eax
f01056f0:	c1 e8 0c             	shr    $0xc,%eax
f01056f3:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f01056f9:	72 15                	jb     f0105710 <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01056fb:	56                   	push   %esi
f01056fc:	68 04 60 10 f0       	push   $0xf0106004
f0105701:	68 90 00 00 00       	push   $0x90
f0105706:	68 a1 7c 10 f0       	push   $0xf0107ca1
f010570b:	e8 30 a9 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105710:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105716:	83 ec 04             	sub    $0x4,%esp
f0105719:	6a 04                	push   $0x4
f010571b:	68 b6 7c 10 f0       	push   $0xf0107cb6
f0105720:	53                   	push   %ebx
f0105721:	e8 c6 fc ff ff       	call   f01053ec <memcmp>
f0105726:	83 c4 10             	add    $0x10,%esp
f0105729:	85 c0                	test   %eax,%eax
f010572b:	74 15                	je     f0105742 <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f010572d:	83 ec 0c             	sub    $0xc,%esp
f0105730:	68 44 7b 10 f0       	push   $0xf0107b44
f0105735:	e8 67 e1 ff ff       	call   f01038a1 <cprintf>
f010573a:	83 c4 10             	add    $0x10,%esp
f010573d:	e9 e4 01 00 00       	jmp    f0105926 <mp_init+0x2ea>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105742:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f0105746:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f010574a:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f010574d:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105752:	b8 00 00 00 00       	mov    $0x0,%eax
f0105757:	eb 0d                	jmp    f0105766 <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f0105759:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0105760:	f0 
f0105761:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105763:	83 c0 01             	add    $0x1,%eax
f0105766:	39 c7                	cmp    %eax,%edi
f0105768:	75 ef                	jne    f0105759 <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f010576a:	84 d2                	test   %dl,%dl
f010576c:	74 15                	je     f0105783 <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f010576e:	83 ec 0c             	sub    $0xc,%esp
f0105771:	68 78 7b 10 f0       	push   $0xf0107b78
f0105776:	e8 26 e1 ff ff       	call   f01038a1 <cprintf>
f010577b:	83 c4 10             	add    $0x10,%esp
f010577e:	e9 a3 01 00 00       	jmp    f0105926 <mp_init+0x2ea>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0105783:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0105787:	3c 01                	cmp    $0x1,%al
f0105789:	74 1d                	je     f01057a8 <mp_init+0x16c>
f010578b:	3c 04                	cmp    $0x4,%al
f010578d:	74 19                	je     f01057a8 <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f010578f:	83 ec 08             	sub    $0x8,%esp
f0105792:	0f b6 c0             	movzbl %al,%eax
f0105795:	50                   	push   %eax
f0105796:	68 9c 7b 10 f0       	push   $0xf0107b9c
f010579b:	e8 01 e1 ff ff       	call   f01038a1 <cprintf>
f01057a0:	83 c4 10             	add    $0x10,%esp
f01057a3:	e9 7e 01 00 00       	jmp    f0105926 <mp_init+0x2ea>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f01057a8:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f01057ac:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f01057b0:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f01057b5:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f01057ba:	01 ce                	add    %ecx,%esi
f01057bc:	eb 0d                	jmp    f01057cb <mp_init+0x18f>
f01057be:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f01057c5:	f0 
f01057c6:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01057c8:	83 c0 01             	add    $0x1,%eax
f01057cb:	39 c7                	cmp    %eax,%edi
f01057cd:	75 ef                	jne    f01057be <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f01057cf:	89 d0                	mov    %edx,%eax
f01057d1:	02 43 2a             	add    0x2a(%ebx),%al
f01057d4:	74 15                	je     f01057eb <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f01057d6:	83 ec 0c             	sub    $0xc,%esp
f01057d9:	68 bc 7b 10 f0       	push   $0xf0107bbc
f01057de:	e8 be e0 ff ff       	call   f01038a1 <cprintf>
f01057e3:	83 c4 10             	add    $0x10,%esp
f01057e6:	e9 3b 01 00 00       	jmp    f0105926 <mp_init+0x2ea>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f01057eb:	85 db                	test   %ebx,%ebx
f01057ed:	0f 84 33 01 00 00    	je     f0105926 <mp_init+0x2ea>
		return;
	ismp = 1;
f01057f3:	c7 05 00 c0 22 f0 01 	movl   $0x1,0xf022c000
f01057fa:	00 00 00 
	lapicaddr = conf->lapicaddr;
f01057fd:	8b 43 24             	mov    0x24(%ebx),%eax
f0105800:	a3 00 d0 26 f0       	mov    %eax,0xf026d000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105805:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0105808:	be 00 00 00 00       	mov    $0x0,%esi
f010580d:	e9 85 00 00 00       	jmp    f0105897 <mp_init+0x25b>
		switch (*p) {
f0105812:	0f b6 07             	movzbl (%edi),%eax
f0105815:	84 c0                	test   %al,%al
f0105817:	74 06                	je     f010581f <mp_init+0x1e3>
f0105819:	3c 04                	cmp    $0x4,%al
f010581b:	77 55                	ja     f0105872 <mp_init+0x236>
f010581d:	eb 4e                	jmp    f010586d <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f010581f:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105823:	74 11                	je     f0105836 <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f0105825:	6b 05 c4 c3 22 f0 74 	imul   $0x74,0xf022c3c4,%eax
f010582c:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f0105831:	a3 c0 c3 22 f0       	mov    %eax,0xf022c3c0
			if (ncpu < NCPU) {
f0105836:	a1 c4 c3 22 f0       	mov    0xf022c3c4,%eax
f010583b:	83 f8 07             	cmp    $0x7,%eax
f010583e:	7f 13                	jg     f0105853 <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f0105840:	6b d0 74             	imul   $0x74,%eax,%edx
f0105843:	88 82 20 c0 22 f0    	mov    %al,-0xfdd3fe0(%edx)
				ncpu++;
f0105849:	83 c0 01             	add    $0x1,%eax
f010584c:	a3 c4 c3 22 f0       	mov    %eax,0xf022c3c4
f0105851:	eb 15                	jmp    f0105868 <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105853:	83 ec 08             	sub    $0x8,%esp
f0105856:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f010585a:	50                   	push   %eax
f010585b:	68 ec 7b 10 f0       	push   $0xf0107bec
f0105860:	e8 3c e0 ff ff       	call   f01038a1 <cprintf>
f0105865:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105868:	83 c7 14             	add    $0x14,%edi
			continue;
f010586b:	eb 27                	jmp    f0105894 <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f010586d:	83 c7 08             	add    $0x8,%edi
			continue;
f0105870:	eb 22                	jmp    f0105894 <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105872:	83 ec 08             	sub    $0x8,%esp
f0105875:	0f b6 c0             	movzbl %al,%eax
f0105878:	50                   	push   %eax
f0105879:	68 14 7c 10 f0       	push   $0xf0107c14
f010587e:	e8 1e e0 ff ff       	call   f01038a1 <cprintf>
			ismp = 0;
f0105883:	c7 05 00 c0 22 f0 00 	movl   $0x0,0xf022c000
f010588a:	00 00 00 
			i = conf->entry;
f010588d:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f0105891:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105894:	83 c6 01             	add    $0x1,%esi
f0105897:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f010589b:	39 c6                	cmp    %eax,%esi
f010589d:	0f 82 6f ff ff ff    	jb     f0105812 <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f01058a3:	a1 c0 c3 22 f0       	mov    0xf022c3c0,%eax
f01058a8:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f01058af:	83 3d 00 c0 22 f0 00 	cmpl   $0x0,0xf022c000
f01058b6:	75 26                	jne    f01058de <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f01058b8:	c7 05 c4 c3 22 f0 01 	movl   $0x1,0xf022c3c4
f01058bf:	00 00 00 
		lapicaddr = 0;
f01058c2:	c7 05 00 d0 26 f0 00 	movl   $0x0,0xf026d000
f01058c9:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f01058cc:	83 ec 0c             	sub    $0xc,%esp
f01058cf:	68 34 7c 10 f0       	push   $0xf0107c34
f01058d4:	e8 c8 df ff ff       	call   f01038a1 <cprintf>
		return;
f01058d9:	83 c4 10             	add    $0x10,%esp
f01058dc:	eb 48                	jmp    f0105926 <mp_init+0x2ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f01058de:	83 ec 04             	sub    $0x4,%esp
f01058e1:	ff 35 c4 c3 22 f0    	pushl  0xf022c3c4
f01058e7:	0f b6 00             	movzbl (%eax),%eax
f01058ea:	50                   	push   %eax
f01058eb:	68 bb 7c 10 f0       	push   $0xf0107cbb
f01058f0:	e8 ac df ff ff       	call   f01038a1 <cprintf>

	if (mp->imcrp) {
f01058f5:	83 c4 10             	add    $0x10,%esp
f01058f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01058fb:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f01058ff:	74 25                	je     f0105926 <mp_init+0x2ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105901:	83 ec 0c             	sub    $0xc,%esp
f0105904:	68 60 7c 10 f0       	push   $0xf0107c60
f0105909:	e8 93 df ff ff       	call   f01038a1 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010590e:	ba 22 00 00 00       	mov    $0x22,%edx
f0105913:	b8 70 00 00 00       	mov    $0x70,%eax
f0105918:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105919:	ba 23 00 00 00       	mov    $0x23,%edx
f010591e:	ec                   	in     (%dx),%al
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010591f:	83 c8 01             	or     $0x1,%eax
f0105922:	ee                   	out    %al,(%dx)
f0105923:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105926:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105929:	5b                   	pop    %ebx
f010592a:	5e                   	pop    %esi
f010592b:	5f                   	pop    %edi
f010592c:	5d                   	pop    %ebp
f010592d:	c3                   	ret    

f010592e <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f010592e:	55                   	push   %ebp
f010592f:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105931:	8b 0d 04 d0 26 f0    	mov    0xf026d004,%ecx
f0105937:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f010593a:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f010593c:	a1 04 d0 26 f0       	mov    0xf026d004,%eax
f0105941:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105944:	5d                   	pop    %ebp
f0105945:	c3                   	ret    

f0105946 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105946:	55                   	push   %ebp
f0105947:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105949:	a1 04 d0 26 f0       	mov    0xf026d004,%eax
f010594e:	85 c0                	test   %eax,%eax
f0105950:	74 08                	je     f010595a <cpunum+0x14>
		return lapic[ID] >> 24;
f0105952:	8b 40 20             	mov    0x20(%eax),%eax
f0105955:	c1 e8 18             	shr    $0x18,%eax
f0105958:	eb 05                	jmp    f010595f <cpunum+0x19>
	return 0;
f010595a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010595f:	5d                   	pop    %ebp
f0105960:	c3                   	ret    

f0105961 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0105961:	a1 00 d0 26 f0       	mov    0xf026d000,%eax
f0105966:	85 c0                	test   %eax,%eax
f0105968:	0f 84 21 01 00 00    	je     f0105a8f <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f010596e:	55                   	push   %ebp
f010596f:	89 e5                	mov    %esp,%ebp
f0105971:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0105974:	68 00 10 00 00       	push   $0x1000
f0105979:	50                   	push   %eax
f010597a:	e8 99 ba ff ff       	call   f0101418 <mmio_map_region>
f010597f:	a3 04 d0 26 f0       	mov    %eax,0xf026d004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105984:	ba 27 01 00 00       	mov    $0x127,%edx
f0105989:	b8 3c 00 00 00       	mov    $0x3c,%eax
f010598e:	e8 9b ff ff ff       	call   f010592e <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0105993:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105998:	b8 f8 00 00 00       	mov    $0xf8,%eax
f010599d:	e8 8c ff ff ff       	call   f010592e <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f01059a2:	ba 20 00 02 00       	mov    $0x20020,%edx
f01059a7:	b8 c8 00 00 00       	mov    $0xc8,%eax
f01059ac:	e8 7d ff ff ff       	call   f010592e <lapicw>
	lapicw(TICR, 10000000); 
f01059b1:	ba 80 96 98 00       	mov    $0x989680,%edx
f01059b6:	b8 e0 00 00 00       	mov    $0xe0,%eax
f01059bb:	e8 6e ff ff ff       	call   f010592e <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f01059c0:	e8 81 ff ff ff       	call   f0105946 <cpunum>
f01059c5:	6b c0 74             	imul   $0x74,%eax,%eax
f01059c8:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f01059cd:	83 c4 10             	add    $0x10,%esp
f01059d0:	39 05 c0 c3 22 f0    	cmp    %eax,0xf022c3c0
f01059d6:	74 0f                	je     f01059e7 <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f01059d8:	ba 00 00 01 00       	mov    $0x10000,%edx
f01059dd:	b8 d4 00 00 00       	mov    $0xd4,%eax
f01059e2:	e8 47 ff ff ff       	call   f010592e <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f01059e7:	ba 00 00 01 00       	mov    $0x10000,%edx
f01059ec:	b8 d8 00 00 00       	mov    $0xd8,%eax
f01059f1:	e8 38 ff ff ff       	call   f010592e <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f01059f6:	a1 04 d0 26 f0       	mov    0xf026d004,%eax
f01059fb:	8b 40 30             	mov    0x30(%eax),%eax
f01059fe:	c1 e8 10             	shr    $0x10,%eax
f0105a01:	3c 03                	cmp    $0x3,%al
f0105a03:	76 0f                	jbe    f0105a14 <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f0105a05:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105a0a:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105a0f:	e8 1a ff ff ff       	call   f010592e <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105a14:	ba 33 00 00 00       	mov    $0x33,%edx
f0105a19:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105a1e:	e8 0b ff ff ff       	call   f010592e <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0105a23:	ba 00 00 00 00       	mov    $0x0,%edx
f0105a28:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105a2d:	e8 fc fe ff ff       	call   f010592e <lapicw>
	lapicw(ESR, 0);
f0105a32:	ba 00 00 00 00       	mov    $0x0,%edx
f0105a37:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105a3c:	e8 ed fe ff ff       	call   f010592e <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0105a41:	ba 00 00 00 00       	mov    $0x0,%edx
f0105a46:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105a4b:	e8 de fe ff ff       	call   f010592e <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0105a50:	ba 00 00 00 00       	mov    $0x0,%edx
f0105a55:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105a5a:	e8 cf fe ff ff       	call   f010592e <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105a5f:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105a64:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105a69:	e8 c0 fe ff ff       	call   f010592e <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105a6e:	8b 15 04 d0 26 f0    	mov    0xf026d004,%edx
f0105a74:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105a7a:	f6 c4 10             	test   $0x10,%ah
f0105a7d:	75 f5                	jne    f0105a74 <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0105a7f:	ba 00 00 00 00       	mov    $0x0,%edx
f0105a84:	b8 20 00 00 00       	mov    $0x20,%eax
f0105a89:	e8 a0 fe ff ff       	call   f010592e <lapicw>
}
f0105a8e:	c9                   	leave  
f0105a8f:	f3 c3                	repz ret 

f0105a91 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105a91:	83 3d 04 d0 26 f0 00 	cmpl   $0x0,0xf026d004
f0105a98:	74 13                	je     f0105aad <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105a9a:	55                   	push   %ebp
f0105a9b:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0105a9d:	ba 00 00 00 00       	mov    $0x0,%edx
f0105aa2:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105aa7:	e8 82 fe ff ff       	call   f010592e <lapicw>
}
f0105aac:	5d                   	pop    %ebp
f0105aad:	f3 c3                	repz ret 

f0105aaf <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105aaf:	55                   	push   %ebp
f0105ab0:	89 e5                	mov    %esp,%ebp
f0105ab2:	56                   	push   %esi
f0105ab3:	53                   	push   %ebx
f0105ab4:	8b 75 08             	mov    0x8(%ebp),%esi
f0105ab7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105aba:	ba 70 00 00 00       	mov    $0x70,%edx
f0105abf:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105ac4:	ee                   	out    %al,(%dx)
f0105ac5:	ba 71 00 00 00       	mov    $0x71,%edx
f0105aca:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105acf:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105ad0:	83 3d 88 be 22 f0 00 	cmpl   $0x0,0xf022be88
f0105ad7:	75 19                	jne    f0105af2 <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105ad9:	68 67 04 00 00       	push   $0x467
f0105ade:	68 04 60 10 f0       	push   $0xf0106004
f0105ae3:	68 98 00 00 00       	push   $0x98
f0105ae8:	68 d8 7c 10 f0       	push   $0xf0107cd8
f0105aed:	e8 4e a5 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105af2:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105af9:	00 00 
	wrv[1] = addr >> 4;
f0105afb:	89 d8                	mov    %ebx,%eax
f0105afd:	c1 e8 04             	shr    $0x4,%eax
f0105b00:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105b06:	c1 e6 18             	shl    $0x18,%esi
f0105b09:	89 f2                	mov    %esi,%edx
f0105b0b:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105b10:	e8 19 fe ff ff       	call   f010592e <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105b15:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105b1a:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105b1f:	e8 0a fe ff ff       	call   f010592e <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105b24:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105b29:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105b2e:	e8 fb fd ff ff       	call   f010592e <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105b33:	c1 eb 0c             	shr    $0xc,%ebx
f0105b36:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105b39:	89 f2                	mov    %esi,%edx
f0105b3b:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105b40:	e8 e9 fd ff ff       	call   f010592e <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105b45:	89 da                	mov    %ebx,%edx
f0105b47:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105b4c:	e8 dd fd ff ff       	call   f010592e <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105b51:	89 f2                	mov    %esi,%edx
f0105b53:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105b58:	e8 d1 fd ff ff       	call   f010592e <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105b5d:	89 da                	mov    %ebx,%edx
f0105b5f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105b64:	e8 c5 fd ff ff       	call   f010592e <lapicw>
		microdelay(200);
	}
}
f0105b69:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105b6c:	5b                   	pop    %ebx
f0105b6d:	5e                   	pop    %esi
f0105b6e:	5d                   	pop    %ebp
f0105b6f:	c3                   	ret    

f0105b70 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0105b70:	55                   	push   %ebp
f0105b71:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0105b73:	8b 55 08             	mov    0x8(%ebp),%edx
f0105b76:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105b7c:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105b81:	e8 a8 fd ff ff       	call   f010592e <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0105b86:	8b 15 04 d0 26 f0    	mov    0xf026d004,%edx
f0105b8c:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105b92:	f6 c4 10             	test   $0x10,%ah
f0105b95:	75 f5                	jne    f0105b8c <lapic_ipi+0x1c>
		;
}
f0105b97:	5d                   	pop    %ebp
f0105b98:	c3                   	ret    

f0105b99 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105b99:	55                   	push   %ebp
f0105b9a:	89 e5                	mov    %esp,%ebp
f0105b9c:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105b9f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0105ba5:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105ba8:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105bab:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105bb2:	5d                   	pop    %ebp
f0105bb3:	c3                   	ret    

f0105bb4 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0105bb4:	55                   	push   %ebp
f0105bb5:	89 e5                	mov    %esp,%ebp
f0105bb7:	56                   	push   %esi
f0105bb8:	53                   	push   %ebx
f0105bb9:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105bbc:	83 3b 00             	cmpl   $0x0,(%ebx)
f0105bbf:	74 14                	je     f0105bd5 <spin_lock+0x21>
f0105bc1:	8b 73 08             	mov    0x8(%ebx),%esi
f0105bc4:	e8 7d fd ff ff       	call   f0105946 <cpunum>
f0105bc9:	6b c0 74             	imul   $0x74,%eax,%eax
f0105bcc:	05 20 c0 22 f0       	add    $0xf022c020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0105bd1:	39 c6                	cmp    %eax,%esi
f0105bd3:	74 07                	je     f0105bdc <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0105bd5:	ba 01 00 00 00       	mov    $0x1,%edx
f0105bda:	eb 20                	jmp    f0105bfc <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0105bdc:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0105bdf:	e8 62 fd ff ff       	call   f0105946 <cpunum>
f0105be4:	83 ec 0c             	sub    $0xc,%esp
f0105be7:	53                   	push   %ebx
f0105be8:	50                   	push   %eax
f0105be9:	68 e8 7c 10 f0       	push   $0xf0107ce8
f0105bee:	6a 41                	push   $0x41
f0105bf0:	68 4c 7d 10 f0       	push   $0xf0107d4c
f0105bf5:	e8 46 a4 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0105bfa:	f3 90                	pause  
f0105bfc:	89 d0                	mov    %edx,%eax
f0105bfe:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0105c01:	85 c0                	test   %eax,%eax
f0105c03:	75 f5                	jne    f0105bfa <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0105c05:	e8 3c fd ff ff       	call   f0105946 <cpunum>
f0105c0a:	6b c0 74             	imul   $0x74,%eax,%eax
f0105c0d:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f0105c12:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0105c15:	83 c3 0c             	add    $0xc,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0105c18:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105c1a:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c1f:	eb 0b                	jmp    f0105c2c <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0105c21:	8b 4a 04             	mov    0x4(%edx),%ecx
f0105c24:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0105c27:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105c29:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0105c2c:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0105c32:	76 11                	jbe    f0105c45 <spin_lock+0x91>
f0105c34:	83 f8 09             	cmp    $0x9,%eax
f0105c37:	7e e8                	jle    f0105c21 <spin_lock+0x6d>
f0105c39:	eb 0a                	jmp    f0105c45 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0105c3b:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0105c42:	83 c0 01             	add    $0x1,%eax
f0105c45:	83 f8 09             	cmp    $0x9,%eax
f0105c48:	7e f1                	jle    f0105c3b <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0105c4a:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105c4d:	5b                   	pop    %ebx
f0105c4e:	5e                   	pop    %esi
f0105c4f:	5d                   	pop    %ebp
f0105c50:	c3                   	ret    

f0105c51 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0105c51:	55                   	push   %ebp
f0105c52:	89 e5                	mov    %esp,%ebp
f0105c54:	57                   	push   %edi
f0105c55:	56                   	push   %esi
f0105c56:	53                   	push   %ebx
f0105c57:	83 ec 4c             	sub    $0x4c,%esp
f0105c5a:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105c5d:	83 3e 00             	cmpl   $0x0,(%esi)
f0105c60:	74 18                	je     f0105c7a <spin_unlock+0x29>
f0105c62:	8b 5e 08             	mov    0x8(%esi),%ebx
f0105c65:	e8 dc fc ff ff       	call   f0105946 <cpunum>
f0105c6a:	6b c0 74             	imul   $0x74,%eax,%eax
f0105c6d:	05 20 c0 22 f0       	add    $0xf022c020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0105c72:	39 c3                	cmp    %eax,%ebx
f0105c74:	0f 84 a5 00 00 00    	je     f0105d1f <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0105c7a:	83 ec 04             	sub    $0x4,%esp
f0105c7d:	6a 28                	push   $0x28
f0105c7f:	8d 46 0c             	lea    0xc(%esi),%eax
f0105c82:	50                   	push   %eax
f0105c83:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0105c86:	53                   	push   %ebx
f0105c87:	e8 e5 f6 ff ff       	call   f0105371 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0105c8c:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0105c8f:	0f b6 38             	movzbl (%eax),%edi
f0105c92:	8b 76 04             	mov    0x4(%esi),%esi
f0105c95:	e8 ac fc ff ff       	call   f0105946 <cpunum>
f0105c9a:	57                   	push   %edi
f0105c9b:	56                   	push   %esi
f0105c9c:	50                   	push   %eax
f0105c9d:	68 14 7d 10 f0       	push   $0xf0107d14
f0105ca2:	e8 fa db ff ff       	call   f01038a1 <cprintf>
f0105ca7:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0105caa:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0105cad:	eb 54                	jmp    f0105d03 <spin_unlock+0xb2>
f0105caf:	83 ec 08             	sub    $0x8,%esp
f0105cb2:	57                   	push   %edi
f0105cb3:	50                   	push   %eax
f0105cb4:	e8 f1 eb ff ff       	call   f01048aa <debuginfo_eip>
f0105cb9:	83 c4 10             	add    $0x10,%esp
f0105cbc:	85 c0                	test   %eax,%eax
f0105cbe:	78 27                	js     f0105ce7 <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0105cc0:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0105cc2:	83 ec 04             	sub    $0x4,%esp
f0105cc5:	89 c2                	mov    %eax,%edx
f0105cc7:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0105cca:	52                   	push   %edx
f0105ccb:	ff 75 b0             	pushl  -0x50(%ebp)
f0105cce:	ff 75 b4             	pushl  -0x4c(%ebp)
f0105cd1:	ff 75 ac             	pushl  -0x54(%ebp)
f0105cd4:	ff 75 a8             	pushl  -0x58(%ebp)
f0105cd7:	50                   	push   %eax
f0105cd8:	68 5c 7d 10 f0       	push   $0xf0107d5c
f0105cdd:	e8 bf db ff ff       	call   f01038a1 <cprintf>
f0105ce2:	83 c4 20             	add    $0x20,%esp
f0105ce5:	eb 12                	jmp    f0105cf9 <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0105ce7:	83 ec 08             	sub    $0x8,%esp
f0105cea:	ff 36                	pushl  (%esi)
f0105cec:	68 73 7d 10 f0       	push   $0xf0107d73
f0105cf1:	e8 ab db ff ff       	call   f01038a1 <cprintf>
f0105cf6:	83 c4 10             	add    $0x10,%esp
f0105cf9:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0105cfc:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0105cff:	39 c3                	cmp    %eax,%ebx
f0105d01:	74 08                	je     f0105d0b <spin_unlock+0xba>
f0105d03:	89 de                	mov    %ebx,%esi
f0105d05:	8b 03                	mov    (%ebx),%eax
f0105d07:	85 c0                	test   %eax,%eax
f0105d09:	75 a4                	jne    f0105caf <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0105d0b:	83 ec 04             	sub    $0x4,%esp
f0105d0e:	68 7b 7d 10 f0       	push   $0xf0107d7b
f0105d13:	6a 67                	push   $0x67
f0105d15:	68 4c 7d 10 f0       	push   $0xf0107d4c
f0105d1a:	e8 21 a3 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0105d1f:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0105d26:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0105d2d:	b8 00 00 00 00       	mov    $0x0,%eax
f0105d32:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0105d35:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105d38:	5b                   	pop    %ebx
f0105d39:	5e                   	pop    %esi
f0105d3a:	5f                   	pop    %edi
f0105d3b:	5d                   	pop    %ebp
f0105d3c:	c3                   	ret    
f0105d3d:	66 90                	xchg   %ax,%ax
f0105d3f:	90                   	nop

f0105d40 <__udivdi3>:
f0105d40:	55                   	push   %ebp
f0105d41:	57                   	push   %edi
f0105d42:	56                   	push   %esi
f0105d43:	53                   	push   %ebx
f0105d44:	83 ec 1c             	sub    $0x1c,%esp
f0105d47:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f0105d4b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f0105d4f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0105d53:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0105d57:	85 f6                	test   %esi,%esi
f0105d59:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105d5d:	89 ca                	mov    %ecx,%edx
f0105d5f:	89 f8                	mov    %edi,%eax
f0105d61:	75 3d                	jne    f0105da0 <__udivdi3+0x60>
f0105d63:	39 cf                	cmp    %ecx,%edi
f0105d65:	0f 87 c5 00 00 00    	ja     f0105e30 <__udivdi3+0xf0>
f0105d6b:	85 ff                	test   %edi,%edi
f0105d6d:	89 fd                	mov    %edi,%ebp
f0105d6f:	75 0b                	jne    f0105d7c <__udivdi3+0x3c>
f0105d71:	b8 01 00 00 00       	mov    $0x1,%eax
f0105d76:	31 d2                	xor    %edx,%edx
f0105d78:	f7 f7                	div    %edi
f0105d7a:	89 c5                	mov    %eax,%ebp
f0105d7c:	89 c8                	mov    %ecx,%eax
f0105d7e:	31 d2                	xor    %edx,%edx
f0105d80:	f7 f5                	div    %ebp
f0105d82:	89 c1                	mov    %eax,%ecx
f0105d84:	89 d8                	mov    %ebx,%eax
f0105d86:	89 cf                	mov    %ecx,%edi
f0105d88:	f7 f5                	div    %ebp
f0105d8a:	89 c3                	mov    %eax,%ebx
f0105d8c:	89 d8                	mov    %ebx,%eax
f0105d8e:	89 fa                	mov    %edi,%edx
f0105d90:	83 c4 1c             	add    $0x1c,%esp
f0105d93:	5b                   	pop    %ebx
f0105d94:	5e                   	pop    %esi
f0105d95:	5f                   	pop    %edi
f0105d96:	5d                   	pop    %ebp
f0105d97:	c3                   	ret    
f0105d98:	90                   	nop
f0105d99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105da0:	39 ce                	cmp    %ecx,%esi
f0105da2:	77 74                	ja     f0105e18 <__udivdi3+0xd8>
f0105da4:	0f bd fe             	bsr    %esi,%edi
f0105da7:	83 f7 1f             	xor    $0x1f,%edi
f0105daa:	0f 84 98 00 00 00    	je     f0105e48 <__udivdi3+0x108>
f0105db0:	bb 20 00 00 00       	mov    $0x20,%ebx
f0105db5:	89 f9                	mov    %edi,%ecx
f0105db7:	89 c5                	mov    %eax,%ebp
f0105db9:	29 fb                	sub    %edi,%ebx
f0105dbb:	d3 e6                	shl    %cl,%esi
f0105dbd:	89 d9                	mov    %ebx,%ecx
f0105dbf:	d3 ed                	shr    %cl,%ebp
f0105dc1:	89 f9                	mov    %edi,%ecx
f0105dc3:	d3 e0                	shl    %cl,%eax
f0105dc5:	09 ee                	or     %ebp,%esi
f0105dc7:	89 d9                	mov    %ebx,%ecx
f0105dc9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105dcd:	89 d5                	mov    %edx,%ebp
f0105dcf:	8b 44 24 08          	mov    0x8(%esp),%eax
f0105dd3:	d3 ed                	shr    %cl,%ebp
f0105dd5:	89 f9                	mov    %edi,%ecx
f0105dd7:	d3 e2                	shl    %cl,%edx
f0105dd9:	89 d9                	mov    %ebx,%ecx
f0105ddb:	d3 e8                	shr    %cl,%eax
f0105ddd:	09 c2                	or     %eax,%edx
f0105ddf:	89 d0                	mov    %edx,%eax
f0105de1:	89 ea                	mov    %ebp,%edx
f0105de3:	f7 f6                	div    %esi
f0105de5:	89 d5                	mov    %edx,%ebp
f0105de7:	89 c3                	mov    %eax,%ebx
f0105de9:	f7 64 24 0c          	mull   0xc(%esp)
f0105ded:	39 d5                	cmp    %edx,%ebp
f0105def:	72 10                	jb     f0105e01 <__udivdi3+0xc1>
f0105df1:	8b 74 24 08          	mov    0x8(%esp),%esi
f0105df5:	89 f9                	mov    %edi,%ecx
f0105df7:	d3 e6                	shl    %cl,%esi
f0105df9:	39 c6                	cmp    %eax,%esi
f0105dfb:	73 07                	jae    f0105e04 <__udivdi3+0xc4>
f0105dfd:	39 d5                	cmp    %edx,%ebp
f0105dff:	75 03                	jne    f0105e04 <__udivdi3+0xc4>
f0105e01:	83 eb 01             	sub    $0x1,%ebx
f0105e04:	31 ff                	xor    %edi,%edi
f0105e06:	89 d8                	mov    %ebx,%eax
f0105e08:	89 fa                	mov    %edi,%edx
f0105e0a:	83 c4 1c             	add    $0x1c,%esp
f0105e0d:	5b                   	pop    %ebx
f0105e0e:	5e                   	pop    %esi
f0105e0f:	5f                   	pop    %edi
f0105e10:	5d                   	pop    %ebp
f0105e11:	c3                   	ret    
f0105e12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105e18:	31 ff                	xor    %edi,%edi
f0105e1a:	31 db                	xor    %ebx,%ebx
f0105e1c:	89 d8                	mov    %ebx,%eax
f0105e1e:	89 fa                	mov    %edi,%edx
f0105e20:	83 c4 1c             	add    $0x1c,%esp
f0105e23:	5b                   	pop    %ebx
f0105e24:	5e                   	pop    %esi
f0105e25:	5f                   	pop    %edi
f0105e26:	5d                   	pop    %ebp
f0105e27:	c3                   	ret    
f0105e28:	90                   	nop
f0105e29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105e30:	89 d8                	mov    %ebx,%eax
f0105e32:	f7 f7                	div    %edi
f0105e34:	31 ff                	xor    %edi,%edi
f0105e36:	89 c3                	mov    %eax,%ebx
f0105e38:	89 d8                	mov    %ebx,%eax
f0105e3a:	89 fa                	mov    %edi,%edx
f0105e3c:	83 c4 1c             	add    $0x1c,%esp
f0105e3f:	5b                   	pop    %ebx
f0105e40:	5e                   	pop    %esi
f0105e41:	5f                   	pop    %edi
f0105e42:	5d                   	pop    %ebp
f0105e43:	c3                   	ret    
f0105e44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105e48:	39 ce                	cmp    %ecx,%esi
f0105e4a:	72 0c                	jb     f0105e58 <__udivdi3+0x118>
f0105e4c:	31 db                	xor    %ebx,%ebx
f0105e4e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0105e52:	0f 87 34 ff ff ff    	ja     f0105d8c <__udivdi3+0x4c>
f0105e58:	bb 01 00 00 00       	mov    $0x1,%ebx
f0105e5d:	e9 2a ff ff ff       	jmp    f0105d8c <__udivdi3+0x4c>
f0105e62:	66 90                	xchg   %ax,%ax
f0105e64:	66 90                	xchg   %ax,%ax
f0105e66:	66 90                	xchg   %ax,%ax
f0105e68:	66 90                	xchg   %ax,%ax
f0105e6a:	66 90                	xchg   %ax,%ax
f0105e6c:	66 90                	xchg   %ax,%ax
f0105e6e:	66 90                	xchg   %ax,%ax

f0105e70 <__umoddi3>:
f0105e70:	55                   	push   %ebp
f0105e71:	57                   	push   %edi
f0105e72:	56                   	push   %esi
f0105e73:	53                   	push   %ebx
f0105e74:	83 ec 1c             	sub    $0x1c,%esp
f0105e77:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0105e7b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f0105e7f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0105e83:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0105e87:	85 d2                	test   %edx,%edx
f0105e89:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0105e8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105e91:	89 f3                	mov    %esi,%ebx
f0105e93:	89 3c 24             	mov    %edi,(%esp)
f0105e96:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105e9a:	75 1c                	jne    f0105eb8 <__umoddi3+0x48>
f0105e9c:	39 f7                	cmp    %esi,%edi
f0105e9e:	76 50                	jbe    f0105ef0 <__umoddi3+0x80>
f0105ea0:	89 c8                	mov    %ecx,%eax
f0105ea2:	89 f2                	mov    %esi,%edx
f0105ea4:	f7 f7                	div    %edi
f0105ea6:	89 d0                	mov    %edx,%eax
f0105ea8:	31 d2                	xor    %edx,%edx
f0105eaa:	83 c4 1c             	add    $0x1c,%esp
f0105ead:	5b                   	pop    %ebx
f0105eae:	5e                   	pop    %esi
f0105eaf:	5f                   	pop    %edi
f0105eb0:	5d                   	pop    %ebp
f0105eb1:	c3                   	ret    
f0105eb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105eb8:	39 f2                	cmp    %esi,%edx
f0105eba:	89 d0                	mov    %edx,%eax
f0105ebc:	77 52                	ja     f0105f10 <__umoddi3+0xa0>
f0105ebe:	0f bd ea             	bsr    %edx,%ebp
f0105ec1:	83 f5 1f             	xor    $0x1f,%ebp
f0105ec4:	75 5a                	jne    f0105f20 <__umoddi3+0xb0>
f0105ec6:	3b 54 24 04          	cmp    0x4(%esp),%edx
f0105eca:	0f 82 e0 00 00 00    	jb     f0105fb0 <__umoddi3+0x140>
f0105ed0:	39 0c 24             	cmp    %ecx,(%esp)
f0105ed3:	0f 86 d7 00 00 00    	jbe    f0105fb0 <__umoddi3+0x140>
f0105ed9:	8b 44 24 08          	mov    0x8(%esp),%eax
f0105edd:	8b 54 24 04          	mov    0x4(%esp),%edx
f0105ee1:	83 c4 1c             	add    $0x1c,%esp
f0105ee4:	5b                   	pop    %ebx
f0105ee5:	5e                   	pop    %esi
f0105ee6:	5f                   	pop    %edi
f0105ee7:	5d                   	pop    %ebp
f0105ee8:	c3                   	ret    
f0105ee9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105ef0:	85 ff                	test   %edi,%edi
f0105ef2:	89 fd                	mov    %edi,%ebp
f0105ef4:	75 0b                	jne    f0105f01 <__umoddi3+0x91>
f0105ef6:	b8 01 00 00 00       	mov    $0x1,%eax
f0105efb:	31 d2                	xor    %edx,%edx
f0105efd:	f7 f7                	div    %edi
f0105eff:	89 c5                	mov    %eax,%ebp
f0105f01:	89 f0                	mov    %esi,%eax
f0105f03:	31 d2                	xor    %edx,%edx
f0105f05:	f7 f5                	div    %ebp
f0105f07:	89 c8                	mov    %ecx,%eax
f0105f09:	f7 f5                	div    %ebp
f0105f0b:	89 d0                	mov    %edx,%eax
f0105f0d:	eb 99                	jmp    f0105ea8 <__umoddi3+0x38>
f0105f0f:	90                   	nop
f0105f10:	89 c8                	mov    %ecx,%eax
f0105f12:	89 f2                	mov    %esi,%edx
f0105f14:	83 c4 1c             	add    $0x1c,%esp
f0105f17:	5b                   	pop    %ebx
f0105f18:	5e                   	pop    %esi
f0105f19:	5f                   	pop    %edi
f0105f1a:	5d                   	pop    %ebp
f0105f1b:	c3                   	ret    
f0105f1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105f20:	8b 34 24             	mov    (%esp),%esi
f0105f23:	bf 20 00 00 00       	mov    $0x20,%edi
f0105f28:	89 e9                	mov    %ebp,%ecx
f0105f2a:	29 ef                	sub    %ebp,%edi
f0105f2c:	d3 e0                	shl    %cl,%eax
f0105f2e:	89 f9                	mov    %edi,%ecx
f0105f30:	89 f2                	mov    %esi,%edx
f0105f32:	d3 ea                	shr    %cl,%edx
f0105f34:	89 e9                	mov    %ebp,%ecx
f0105f36:	09 c2                	or     %eax,%edx
f0105f38:	89 d8                	mov    %ebx,%eax
f0105f3a:	89 14 24             	mov    %edx,(%esp)
f0105f3d:	89 f2                	mov    %esi,%edx
f0105f3f:	d3 e2                	shl    %cl,%edx
f0105f41:	89 f9                	mov    %edi,%ecx
f0105f43:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105f47:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0105f4b:	d3 e8                	shr    %cl,%eax
f0105f4d:	89 e9                	mov    %ebp,%ecx
f0105f4f:	89 c6                	mov    %eax,%esi
f0105f51:	d3 e3                	shl    %cl,%ebx
f0105f53:	89 f9                	mov    %edi,%ecx
f0105f55:	89 d0                	mov    %edx,%eax
f0105f57:	d3 e8                	shr    %cl,%eax
f0105f59:	89 e9                	mov    %ebp,%ecx
f0105f5b:	09 d8                	or     %ebx,%eax
f0105f5d:	89 d3                	mov    %edx,%ebx
f0105f5f:	89 f2                	mov    %esi,%edx
f0105f61:	f7 34 24             	divl   (%esp)
f0105f64:	89 d6                	mov    %edx,%esi
f0105f66:	d3 e3                	shl    %cl,%ebx
f0105f68:	f7 64 24 04          	mull   0x4(%esp)
f0105f6c:	39 d6                	cmp    %edx,%esi
f0105f6e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105f72:	89 d1                	mov    %edx,%ecx
f0105f74:	89 c3                	mov    %eax,%ebx
f0105f76:	72 08                	jb     f0105f80 <__umoddi3+0x110>
f0105f78:	75 11                	jne    f0105f8b <__umoddi3+0x11b>
f0105f7a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0105f7e:	73 0b                	jae    f0105f8b <__umoddi3+0x11b>
f0105f80:	2b 44 24 04          	sub    0x4(%esp),%eax
f0105f84:	1b 14 24             	sbb    (%esp),%edx
f0105f87:	89 d1                	mov    %edx,%ecx
f0105f89:	89 c3                	mov    %eax,%ebx
f0105f8b:	8b 54 24 08          	mov    0x8(%esp),%edx
f0105f8f:	29 da                	sub    %ebx,%edx
f0105f91:	19 ce                	sbb    %ecx,%esi
f0105f93:	89 f9                	mov    %edi,%ecx
f0105f95:	89 f0                	mov    %esi,%eax
f0105f97:	d3 e0                	shl    %cl,%eax
f0105f99:	89 e9                	mov    %ebp,%ecx
f0105f9b:	d3 ea                	shr    %cl,%edx
f0105f9d:	89 e9                	mov    %ebp,%ecx
f0105f9f:	d3 ee                	shr    %cl,%esi
f0105fa1:	09 d0                	or     %edx,%eax
f0105fa3:	89 f2                	mov    %esi,%edx
f0105fa5:	83 c4 1c             	add    $0x1c,%esp
f0105fa8:	5b                   	pop    %ebx
f0105fa9:	5e                   	pop    %esi
f0105faa:	5f                   	pop    %edi
f0105fab:	5d                   	pop    %ebp
f0105fac:	c3                   	ret    
f0105fad:	8d 76 00             	lea    0x0(%esi),%esi
f0105fb0:	29 f9                	sub    %edi,%ecx
f0105fb2:	19 d6                	sbb    %edx,%esi
f0105fb4:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105fb8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105fbc:	e9 18 ff ff ff       	jmp    f0105ed9 <__umoddi3+0x69>
