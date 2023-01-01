
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
f0100048:	83 3d 80 fe 22 f0 00 	cmpl   $0x0,0xf022fe80
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 80 fe 22 f0    	mov    %esi,0xf022fe80

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 49 5a 00 00       	call   f0105aaa <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 40 61 10 f0       	push   $0xf0106140
f010006d:	e8 36 38 00 00       	call   f01038a8 <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 06 38 00 00       	call   f0103882 <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 20 6a 10 f0 	movl   $0xf0106a20,(%esp)
f0100083:	e8 20 38 00 00       	call   f01038a8 <cprintf>
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
f01000ae:	68 ac 61 10 f0       	push   $0xf01061ac
f01000b3:	e8 f0 37 00 00       	call   f01038a8 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000b8:	e8 c4 13 00 00       	call   f0101481 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000bd:	e8 f8 2f 00 00       	call   f01030ba <env_init>
	trap_init();
f01000c2:	e8 d4 38 00 00       	call   f010399b <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000c7:	e8 d4 56 00 00       	call   f01057a0 <mp_init>
	lapic_init();
f01000cc:	e8 f4 59 00 00       	call   f0105ac5 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000d1:	e8 f9 36 00 00       	call   f01037cf <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000d6:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f01000dd:	e8 36 5c 00 00       	call   f0105d18 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000e2:	83 c4 10             	add    $0x10,%esp
f01000e5:	83 3d 88 fe 22 f0 07 	cmpl   $0x7,0xf022fe88
f01000ec:	77 16                	ja     f0100104 <i386_init+0x6a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01000ee:	68 00 70 00 00       	push   $0x7000
f01000f3:	68 64 61 10 f0       	push   $0xf0106164
f01000f8:	6a 4e                	push   $0x4e
f01000fa:	68 c7 61 10 f0       	push   $0xf01061c7
f01000ff:	e8 3c ff ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100104:	83 ec 04             	sub    $0x4,%esp
f0100107:	b8 06 57 10 f0       	mov    $0xf0105706,%eax
f010010c:	2d 8c 56 10 f0       	sub    $0xf010568c,%eax
f0100111:	50                   	push   %eax
f0100112:	68 8c 56 10 f0       	push   $0xf010568c
f0100117:	68 00 70 00 f0       	push   $0xf0007000
f010011c:	e8 b3 53 00 00       	call   f01054d4 <memmove>
f0100121:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100124:	bb 20 00 23 f0       	mov    $0xf0230020,%ebx
f0100129:	eb 4d                	jmp    f0100178 <i386_init+0xde>
		if (c == cpus + cpunum())  // We've started already.
f010012b:	e8 7a 59 00 00       	call   f0105aaa <cpunum>
f0100130:	6b c0 74             	imul   $0x74,%eax,%eax
f0100133:	05 20 00 23 f0       	add    $0xf0230020,%eax
f0100138:	39 c3                	cmp    %eax,%ebx
f010013a:	74 39                	je     f0100175 <i386_init+0xdb>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f010013c:	89 d8                	mov    %ebx,%eax
f010013e:	2d 20 00 23 f0       	sub    $0xf0230020,%eax
f0100143:	c1 f8 02             	sar    $0x2,%eax
f0100146:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f010014c:	c1 e0 0f             	shl    $0xf,%eax
f010014f:	05 00 90 23 f0       	add    $0xf0239000,%eax
f0100154:	a3 84 fe 22 f0       	mov    %eax,0xf022fe84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100159:	83 ec 08             	sub    $0x8,%esp
f010015c:	68 00 70 00 00       	push   $0x7000
f0100161:	0f b6 03             	movzbl (%ebx),%eax
f0100164:	50                   	push   %eax
f0100165:	e8 a9 5a 00 00       	call   f0105c13 <lapic_startap>
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
f0100178:	6b 05 c4 03 23 f0 74 	imul   $0x74,0xf02303c4,%eax
f010017f:	05 20 00 23 f0       	add    $0xf0230020,%eax
f0100184:	39 c3                	cmp    %eax,%ebx
f0100186:	72 a3                	jb     f010012b <i386_init+0x91>
	// Starting non-boot CPUs
	boot_aps();

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100188:	83 ec 08             	sub    $0x8,%esp
f010018b:	6a 00                	push   $0x0
f010018d:	68 60 1a 21 f0       	push   $0xf0211a60
f0100192:	e8 f2 30 00 00       	call   f0103289 <env_create>
	ENV_CREATE(user_dumbfork, ENV_TYPE_USER);
	// ENV_CREATE(user_primes, ENV_TYPE_USER);
#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f0100197:	e8 12 43 00 00       	call   f01044ae <sched_yield>

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
f01001a2:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001a7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001ac:	77 12                	ja     f01001c0 <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001ae:	50                   	push   %eax
f01001af:	68 88 61 10 f0       	push   $0xf0106188
f01001b4:	6a 65                	push   $0x65
f01001b6:	68 c7 61 10 f0       	push   $0xf01061c7
f01001bb:	e8 80 fe ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01001c0:	05 00 00 00 10       	add    $0x10000000,%eax
f01001c5:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001c8:	e8 dd 58 00 00       	call   f0105aaa <cpunum>
f01001cd:	83 ec 08             	sub    $0x8,%esp
f01001d0:	50                   	push   %eax
f01001d1:	68 d3 61 10 f0       	push   $0xf01061d3
f01001d6:	e8 cd 36 00 00       	call   f01038a8 <cprintf>

	lapic_init();
f01001db:	e8 e5 58 00 00       	call   f0105ac5 <lapic_init>
	env_init_percpu();
f01001e0:	e8 a5 2e 00 00       	call   f010308a <env_init_percpu>
	trap_init_percpu();
f01001e5:	e8 d2 36 00 00       	call   f01038bc <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f01001ea:	e8 bb 58 00 00       	call   f0105aaa <cpunum>
f01001ef:	6b d0 74             	imul   $0x74,%eax,%edx
f01001f2:	81 c2 20 00 23 f0    	add    $0xf0230020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01001f8:	b8 01 00 00 00       	mov    $0x1,%eax
f01001fd:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0100201:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f0100208:	e8 0b 5b 00 00       	call   f0105d18 <spin_lock>
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:

	lock_kernel();
	sched_yield();
f010020d:	e8 9c 42 00 00       	call   f01044ae <sched_yield>

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
f0100222:	68 e9 61 10 f0       	push   $0xf01061e9
f0100227:	e8 7c 36 00 00       	call   f01038a8 <cprintf>
	vcprintf(fmt, ap);
f010022c:	83 c4 08             	add    $0x8,%esp
f010022f:	53                   	push   %ebx
f0100230:	ff 75 10             	pushl  0x10(%ebp)
f0100233:	e8 4a 36 00 00       	call   f0103882 <vcprintf>
	cprintf("\n");
f0100238:	c7 04 24 20 6a 10 f0 	movl   $0xf0106a20,(%esp)
f010023f:	e8 64 36 00 00       	call   f01038a8 <cprintf>
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
f010027a:	8b 0d 24 f2 22 f0    	mov    0xf022f224,%ecx
f0100280:	8d 51 01             	lea    0x1(%ecx),%edx
f0100283:	89 15 24 f2 22 f0    	mov    %edx,0xf022f224
f0100289:	88 81 20 f0 22 f0    	mov    %al,-0xfdd0fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f010028f:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100295:	75 0a                	jne    f01002a1 <cons_intr+0x36>
			cons.wpos = 0;
f0100297:	c7 05 24 f2 22 f0 00 	movl   $0x0,0xf022f224
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
f01002d0:	83 0d 00 f0 22 f0 40 	orl    $0x40,0xf022f000
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
f01002e8:	8b 0d 00 f0 22 f0    	mov    0xf022f000,%ecx
f01002ee:	89 cb                	mov    %ecx,%ebx
f01002f0:	83 e3 40             	and    $0x40,%ebx
f01002f3:	83 e0 7f             	and    $0x7f,%eax
f01002f6:	85 db                	test   %ebx,%ebx
f01002f8:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01002fb:	0f b6 d2             	movzbl %dl,%edx
f01002fe:	0f b6 82 60 63 10 f0 	movzbl -0xfef9ca0(%edx),%eax
f0100305:	83 c8 40             	or     $0x40,%eax
f0100308:	0f b6 c0             	movzbl %al,%eax
f010030b:	f7 d0                	not    %eax
f010030d:	21 c8                	and    %ecx,%eax
f010030f:	a3 00 f0 22 f0       	mov    %eax,0xf022f000
		return 0;
f0100314:	b8 00 00 00 00       	mov    $0x0,%eax
f0100319:	e9 a4 00 00 00       	jmp    f01003c2 <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f010031e:	8b 0d 00 f0 22 f0    	mov    0xf022f000,%ecx
f0100324:	f6 c1 40             	test   $0x40,%cl
f0100327:	74 0e                	je     f0100337 <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100329:	83 c8 80             	or     $0xffffff80,%eax
f010032c:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010032e:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100331:	89 0d 00 f0 22 f0    	mov    %ecx,0xf022f000
	}

	shift |= shiftcode[data];
f0100337:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f010033a:	0f b6 82 60 63 10 f0 	movzbl -0xfef9ca0(%edx),%eax
f0100341:	0b 05 00 f0 22 f0    	or     0xf022f000,%eax
f0100347:	0f b6 8a 60 62 10 f0 	movzbl -0xfef9da0(%edx),%ecx
f010034e:	31 c8                	xor    %ecx,%eax
f0100350:	a3 00 f0 22 f0       	mov    %eax,0xf022f000

	c = charcode[shift & (CTL | SHIFT)][data];
f0100355:	89 c1                	mov    %eax,%ecx
f0100357:	83 e1 03             	and    $0x3,%ecx
f010035a:	8b 0c 8d 40 62 10 f0 	mov    -0xfef9dc0(,%ecx,4),%ecx
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
f0100398:	68 03 62 10 f0       	push   $0xf0106203
f010039d:	e8 06 35 00 00       	call   f01038a8 <cprintf>
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
f0100484:	0f b7 05 28 f2 22 f0 	movzwl 0xf022f228,%eax
f010048b:	66 85 c0             	test   %ax,%ax
f010048e:	0f 84 e6 00 00 00    	je     f010057a <cons_putc+0x1b3>
			crt_pos--;
f0100494:	83 e8 01             	sub    $0x1,%eax
f0100497:	66 a3 28 f2 22 f0    	mov    %ax,0xf022f228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010049d:	0f b7 c0             	movzwl %ax,%eax
f01004a0:	66 81 e7 00 ff       	and    $0xff00,%di
f01004a5:	83 cf 20             	or     $0x20,%edi
f01004a8:	8b 15 2c f2 22 f0    	mov    0xf022f22c,%edx
f01004ae:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004b2:	eb 78                	jmp    f010052c <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004b4:	66 83 05 28 f2 22 f0 	addw   $0x50,0xf022f228
f01004bb:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004bc:	0f b7 05 28 f2 22 f0 	movzwl 0xf022f228,%eax
f01004c3:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004c9:	c1 e8 16             	shr    $0x16,%eax
f01004cc:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004cf:	c1 e0 04             	shl    $0x4,%eax
f01004d2:	66 a3 28 f2 22 f0    	mov    %ax,0xf022f228
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
f010050e:	0f b7 05 28 f2 22 f0 	movzwl 0xf022f228,%eax
f0100515:	8d 50 01             	lea    0x1(%eax),%edx
f0100518:	66 89 15 28 f2 22 f0 	mov    %dx,0xf022f228
f010051f:	0f b7 c0             	movzwl %ax,%eax
f0100522:	8b 15 2c f2 22 f0    	mov    0xf022f22c,%edx
f0100528:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f010052c:	66 81 3d 28 f2 22 f0 	cmpw   $0x7cf,0xf022f228
f0100533:	cf 07 
f0100535:	76 43                	jbe    f010057a <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100537:	a1 2c f2 22 f0       	mov    0xf022f22c,%eax
f010053c:	83 ec 04             	sub    $0x4,%esp
f010053f:	68 00 0f 00 00       	push   $0xf00
f0100544:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010054a:	52                   	push   %edx
f010054b:	50                   	push   %eax
f010054c:	e8 83 4f 00 00       	call   f01054d4 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100551:	8b 15 2c f2 22 f0    	mov    0xf022f22c,%edx
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
f0100572:	66 83 2d 28 f2 22 f0 	subw   $0x50,0xf022f228
f0100579:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010057a:	8b 0d 30 f2 22 f0    	mov    0xf022f230,%ecx
f0100580:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100585:	89 ca                	mov    %ecx,%edx
f0100587:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100588:	0f b7 1d 28 f2 22 f0 	movzwl 0xf022f228,%ebx
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
f01005b0:	80 3d 34 f2 22 f0 00 	cmpb   $0x0,0xf022f234
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
f01005ee:	a1 20 f2 22 f0       	mov    0xf022f220,%eax
f01005f3:	3b 05 24 f2 22 f0    	cmp    0xf022f224,%eax
f01005f9:	74 26                	je     f0100621 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01005fb:	8d 50 01             	lea    0x1(%eax),%edx
f01005fe:	89 15 20 f2 22 f0    	mov    %edx,0xf022f220
f0100604:	0f b6 88 20 f0 22 f0 	movzbl -0xfdd0fe0(%eax),%ecx
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
f0100615:	c7 05 20 f2 22 f0 00 	movl   $0x0,0xf022f220
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
f010064e:	c7 05 30 f2 22 f0 b4 	movl   $0x3b4,0xf022f230
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
f0100666:	c7 05 30 f2 22 f0 d4 	movl   $0x3d4,0xf022f230
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
f0100675:	8b 3d 30 f2 22 f0    	mov    0xf022f230,%edi
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
f010069a:	89 35 2c f2 22 f0    	mov    %esi,0xf022f22c
	crt_pos = pos;
f01006a0:	0f b6 c0             	movzbl %al,%eax
f01006a3:	09 c8                	or     %ecx,%eax
f01006a5:	66 a3 28 f2 22 f0    	mov    %ax,0xf022f228

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
f01006c0:	e8 92 30 00 00       	call   f0103757 <irq_setmask_8259A>
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
f0100723:	0f 95 05 34 f2 22 f0 	setne  0xf022f234
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
f0100738:	68 0f 62 10 f0       	push   $0xf010620f
f010073d:	e8 66 31 00 00       	call   f01038a8 <cprintf>
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
f010077e:	68 60 64 10 f0       	push   $0xf0106460
f0100783:	68 7e 64 10 f0       	push   $0xf010647e
f0100788:	68 83 64 10 f0       	push   $0xf0106483
f010078d:	e8 16 31 00 00       	call   f01038a8 <cprintf>
f0100792:	83 c4 0c             	add    $0xc,%esp
f0100795:	68 3c 65 10 f0       	push   $0xf010653c
f010079a:	68 8c 64 10 f0       	push   $0xf010648c
f010079f:	68 83 64 10 f0       	push   $0xf0106483
f01007a4:	e8 ff 30 00 00       	call   f01038a8 <cprintf>
f01007a9:	83 c4 0c             	add    $0xc,%esp
f01007ac:	68 95 64 10 f0       	push   $0xf0106495
f01007b1:	68 b3 64 10 f0       	push   $0xf01064b3
f01007b6:	68 83 64 10 f0       	push   $0xf0106483
f01007bb:	e8 e8 30 00 00       	call   f01038a8 <cprintf>
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
f01007cd:	68 bd 64 10 f0       	push   $0xf01064bd
f01007d2:	e8 d1 30 00 00       	call   f01038a8 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007d7:	83 c4 08             	add    $0x8,%esp
f01007da:	68 0c 00 10 00       	push   $0x10000c
f01007df:	68 64 65 10 f0       	push   $0xf0106564
f01007e4:	e8 bf 30 00 00       	call   f01038a8 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007e9:	83 c4 0c             	add    $0xc,%esp
f01007ec:	68 0c 00 10 00       	push   $0x10000c
f01007f1:	68 0c 00 10 f0       	push   $0xf010000c
f01007f6:	68 8c 65 10 f0       	push   $0xf010658c
f01007fb:	e8 a8 30 00 00       	call   f01038a8 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100800:	83 c4 0c             	add    $0xc,%esp
f0100803:	68 31 61 10 00       	push   $0x106131
f0100808:	68 31 61 10 f0       	push   $0xf0106131
f010080d:	68 b0 65 10 f0       	push   $0xf01065b0
f0100812:	e8 91 30 00 00       	call   f01038a8 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100817:	83 c4 0c             	add    $0xc,%esp
f010081a:	68 00 f0 22 00       	push   $0x22f000
f010081f:	68 00 f0 22 f0       	push   $0xf022f000
f0100824:	68 d4 65 10 f0       	push   $0xf01065d4
f0100829:	e8 7a 30 00 00       	call   f01038a8 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010082e:	83 c4 0c             	add    $0xc,%esp
f0100831:	68 08 10 27 00       	push   $0x271008
f0100836:	68 08 10 27 f0       	push   $0xf0271008
f010083b:	68 f8 65 10 f0       	push   $0xf01065f8
f0100840:	e8 63 30 00 00       	call   f01038a8 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100845:	b8 07 14 27 f0       	mov    $0xf0271407,%eax
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
f0100866:	68 1c 66 10 f0       	push   $0xf010661c
f010086b:	e8 38 30 00 00       	call   f01038a8 <cprintf>
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
f01008a5:	68 d6 64 10 f0       	push   $0xf01064d6
f01008aa:	e8 f9 2f 00 00       	call   f01038a8 <cprintf>

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
f01008d7:	e8 31 41 00 00       	call   f0104a0d <debuginfo_eip>

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
f0100933:	68 48 66 10 f0       	push   $0xf0106648
f0100938:	e8 6b 2f 00 00       	call   f01038a8 <cprintf>
		cprintf("         %s:%d: %s+%d\n", context.eip_file, context.eip_line, function_name, _eip - context.eip_fn_addr);
f010093d:	83 c4 14             	add    $0x14,%esp
f0100940:	2b 75 cc             	sub    -0x34(%ebp),%esi
f0100943:	56                   	push   %esi
f0100944:	8d 45 8a             	lea    -0x76(%ebp),%eax
f0100947:	50                   	push   %eax
f0100948:	ff 75 c0             	pushl  -0x40(%ebp)
f010094b:	ff 75 bc             	pushl  -0x44(%ebp)
f010094e:	68 e8 64 10 f0       	push   $0xf01064e8
f0100953:	e8 50 2f 00 00       	call   f01038a8 <cprintf>

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
f010097b:	68 80 66 10 f0       	push   $0xf0106680
f0100980:	e8 23 2f 00 00       	call   f01038a8 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100985:	c7 04 24 a4 66 10 f0 	movl   $0xf01066a4,(%esp)
f010098c:	e8 17 2f 00 00       	call   f01038a8 <cprintf>

	if (tf != NULL)
f0100991:	83 c4 10             	add    $0x10,%esp
f0100994:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100998:	74 0e                	je     f01009a8 <monitor+0x36>
		print_trapframe(tf);
f010099a:	83 ec 0c             	sub    $0xc,%esp
f010099d:	ff 75 08             	pushl  0x8(%ebp)
f01009a0:	e8 c4 34 00 00       	call   f0103e69 <print_trapframe>
f01009a5:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01009a8:	83 ec 0c             	sub    $0xc,%esp
f01009ab:	68 ff 64 10 f0       	push   $0xf01064ff
f01009b0:	e8 7b 48 00 00       	call   f0105230 <readline>
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
f01009e4:	68 03 65 10 f0       	push   $0xf0106503
f01009e9:	e8 5c 4a 00 00       	call   f010544a <strchr>
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
f0100a04:	68 08 65 10 f0       	push   $0xf0106508
f0100a09:	e8 9a 2e 00 00       	call   f01038a8 <cprintf>
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
f0100a2d:	68 03 65 10 f0       	push   $0xf0106503
f0100a32:	e8 13 4a 00 00       	call   f010544a <strchr>
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
f0100a5b:	ff 34 85 e0 66 10 f0 	pushl  -0xfef9920(,%eax,4)
f0100a62:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a65:	e8 82 49 00 00       	call   f01053ec <strcmp>
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
f0100a7f:	ff 14 85 e8 66 10 f0 	call   *-0xfef9918(,%eax,4)
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
f0100aa0:	68 25 65 10 f0       	push   $0xf0106525
f0100aa5:	e8 fe 2d 00 00       	call   f01038a8 <cprintf>
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
f0100ac5:	e8 5f 2c 00 00       	call   f0103729 <mc146818_read>
f0100aca:	89 c6                	mov    %eax,%esi
f0100acc:	83 c3 01             	add    $0x1,%ebx
f0100acf:	89 1c 24             	mov    %ebx,(%esp)
f0100ad2:	e8 52 2c 00 00       	call   f0103729 <mc146818_read>
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
f0100ae3:	83 3d 38 f2 22 f0 00 	cmpl   $0x0,0xf022f238
f0100aea:	75 11                	jne    f0100afd <boot_alloc+0x1a>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100aec:	ba 07 20 27 f0       	mov    $0xf0272007,%edx
f0100af1:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100af7:	89 15 38 f2 22 f0    	mov    %edx,0xf022f238
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

	if ((uint32_t)nextfree > 0xffffffff - n)
f0100afd:	8b 15 38 f2 22 f0    	mov    0xf022f238,%edx
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
f0100b11:	68 04 67 10 f0       	push   $0xf0106704
f0100b16:	6a 6e                	push   $0x6e
f0100b18:	68 1f 67 10 f0       	push   $0xf010671f
f0100b1d:	e8 1e f5 ff ff       	call   f0100040 <_panic>

	result = nextfree;
	nextfree = ROUNDUP(result + n , PGSIZE);
f0100b22:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100b29:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b2e:	a3 38 f2 22 f0       	mov    %eax,0xf022f238

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
f0100b4c:	3b 0d 88 fe 22 f0    	cmp    0xf022fe88,%ecx
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
f0100b5b:	68 64 61 10 f0       	push   $0xf0106164
f0100b60:	68 2b 04 00 00       	push   $0x42b
f0100b65:	68 1f 67 10 f0       	push   $0xf010671f
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
f0100bb3:	68 54 6a 10 f0       	push   $0xf0106a54
f0100bb8:	68 5c 03 00 00       	push   $0x35c
f0100bbd:	68 1f 67 10 f0       	push   $0xf010671f
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
f0100bd5:	2b 15 90 fe 22 f0    	sub    0xf022fe90,%edx
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
f0100c0b:	a3 40 f2 22 f0       	mov    %eax,0xf022f240
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
f0100c15:	8b 1d 40 f2 22 f0    	mov    0xf022f240,%ebx
f0100c1b:	eb 53                	jmp    f0100c70 <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c1d:	89 d8                	mov    %ebx,%eax
f0100c1f:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
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
f0100c39:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0100c3f:	72 12                	jb     f0100c53 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c41:	50                   	push   %eax
f0100c42:	68 64 61 10 f0       	push   $0xf0106164
f0100c47:	6a 58                	push   $0x58
f0100c49:	68 2b 67 10 f0       	push   $0xf010672b
f0100c4e:	e8 ed f3 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100c53:	83 ec 04             	sub    $0x4,%esp
f0100c56:	68 80 00 00 00       	push   $0x80
f0100c5b:	68 97 00 00 00       	push   $0x97
f0100c60:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c65:	50                   	push   %eax
f0100c66:	e8 1c 48 00 00       	call   f0105487 <memset>
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
f0100c81:	8b 15 40 f2 22 f0    	mov    0xf022f240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c87:	8b 0d 90 fe 22 f0    	mov    0xf022fe90,%ecx
		assert(pp < pages + npages);
f0100c8d:	a1 88 fe 22 f0       	mov    0xf022fe88,%eax
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
f0100cac:	68 39 67 10 f0       	push   $0xf0106739
f0100cb1:	68 45 67 10 f0       	push   $0xf0106745
f0100cb6:	68 76 03 00 00       	push   $0x376
f0100cbb:	68 1f 67 10 f0       	push   $0xf010671f
f0100cc0:	e8 7b f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100cc5:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100cc8:	72 19                	jb     f0100ce3 <check_page_free_list+0x149>
f0100cca:	68 5a 67 10 f0       	push   $0xf010675a
f0100ccf:	68 45 67 10 f0       	push   $0xf0106745
f0100cd4:	68 77 03 00 00       	push   $0x377
f0100cd9:	68 1f 67 10 f0       	push   $0xf010671f
f0100cde:	e8 5d f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100ce3:	89 d0                	mov    %edx,%eax
f0100ce5:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100ce8:	a8 07                	test   $0x7,%al
f0100cea:	74 19                	je     f0100d05 <check_page_free_list+0x16b>
f0100cec:	68 78 6a 10 f0       	push   $0xf0106a78
f0100cf1:	68 45 67 10 f0       	push   $0xf0106745
f0100cf6:	68 78 03 00 00       	push   $0x378
f0100cfb:	68 1f 67 10 f0       	push   $0xf010671f
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
f0100d0f:	68 6e 67 10 f0       	push   $0xf010676e
f0100d14:	68 45 67 10 f0       	push   $0xf0106745
f0100d19:	68 7b 03 00 00       	push   $0x37b
f0100d1e:	68 1f 67 10 f0       	push   $0xf010671f
f0100d23:	e8 18 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d28:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d2d:	75 19                	jne    f0100d48 <check_page_free_list+0x1ae>
f0100d2f:	68 7f 67 10 f0       	push   $0xf010677f
f0100d34:	68 45 67 10 f0       	push   $0xf0106745
f0100d39:	68 7c 03 00 00       	push   $0x37c
f0100d3e:	68 1f 67 10 f0       	push   $0xf010671f
f0100d43:	e8 f8 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d48:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d4d:	75 19                	jne    f0100d68 <check_page_free_list+0x1ce>
f0100d4f:	68 ac 6a 10 f0       	push   $0xf0106aac
f0100d54:	68 45 67 10 f0       	push   $0xf0106745
f0100d59:	68 7d 03 00 00       	push   $0x37d
f0100d5e:	68 1f 67 10 f0       	push   $0xf010671f
f0100d63:	e8 d8 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d68:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d6d:	75 19                	jne    f0100d88 <check_page_free_list+0x1ee>
f0100d6f:	68 98 67 10 f0       	push   $0xf0106798
f0100d74:	68 45 67 10 f0       	push   $0xf0106745
f0100d79:	68 7e 03 00 00       	push   $0x37e
f0100d7e:	68 1f 67 10 f0       	push   $0xf010671f
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
f0100d9e:	68 64 61 10 f0       	push   $0xf0106164
f0100da3:	6a 58                	push   $0x58
f0100da5:	68 2b 67 10 f0       	push   $0xf010672b
f0100daa:	e8 91 f2 ff ff       	call   f0100040 <_panic>
f0100daf:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100db5:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100db8:	0f 86 b6 00 00 00    	jbe    f0100e74 <check_page_free_list+0x2da>
f0100dbe:	68 d0 6a 10 f0       	push   $0xf0106ad0
f0100dc3:	68 45 67 10 f0       	push   $0xf0106745
f0100dc8:	68 7f 03 00 00       	push   $0x37f
f0100dcd:	68 1f 67 10 f0       	push   $0xf010671f
f0100dd2:	e8 69 f2 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100dd7:	68 b2 67 10 f0       	push   $0xf01067b2
f0100ddc:	68 45 67 10 f0       	push   $0xf0106745
f0100de1:	68 81 03 00 00       	push   $0x381
f0100de6:	68 1f 67 10 f0       	push   $0xf010671f
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
f0100e06:	68 cf 67 10 f0       	push   $0xf01067cf
f0100e0b:	68 45 67 10 f0       	push   $0xf0106745
f0100e10:	68 89 03 00 00       	push   $0x389
f0100e15:	68 1f 67 10 f0       	push   $0xf010671f
f0100e1a:	e8 21 f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100e1f:	85 db                	test   %ebx,%ebx
f0100e21:	7f 19                	jg     f0100e3c <check_page_free_list+0x2a2>
f0100e23:	68 e1 67 10 f0       	push   $0xf01067e1
f0100e28:	68 45 67 10 f0       	push   $0xf0106745
f0100e2d:	68 8a 03 00 00       	push   $0x38a
f0100e32:	68 1f 67 10 f0       	push   $0xf010671f
f0100e37:	e8 04 f2 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100e3c:	83 ec 0c             	sub    $0xc,%esp
f0100e3f:	68 18 6b 10 f0       	push   $0xf0106b18
f0100e44:	e8 5f 2a 00 00       	call   f01038a8 <cprintf>
}
f0100e49:	eb 49                	jmp    f0100e94 <check_page_free_list+0x2fa>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100e4b:	a1 40 f2 22 f0       	mov    0xf022f240,%eax
f0100e50:	85 c0                	test   %eax,%eax
f0100e52:	0f 85 6f fd ff ff    	jne    f0100bc7 <check_page_free_list+0x2d>
f0100e58:	e9 53 fd ff ff       	jmp    f0100bb0 <check_page_free_list+0x16>
f0100e5d:	83 3d 40 f2 22 f0 00 	cmpl   $0x0,0xf022f240
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
f0100ea1:	a1 90 fe 22 f0       	mov    0xf022fe90,%eax
f0100ea6:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	pages[0].pp_link = 0;
f0100eac:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	extern unsigned char mpentry_start[], mpentry_end[];
	uint32_t size = ROUNDUP(mpentry_end - mpentry_start, PGSIZE);
f0100eb2:	be 05 67 10 f0       	mov    $0xf0106705,%esi
f0100eb7:	81 ee 8c 56 10 f0    	sub    $0xf010568c,%esi
f0100ebd:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	cprintf("[?] %x\n", size);
f0100ec3:	83 ec 08             	sub    $0x8,%esp
f0100ec6:	56                   	push   %esi
f0100ec7:	68 f2 67 10 f0       	push   $0xf01067f2
f0100ecc:	e8 d7 29 00 00       	call   f01038a8 <cprintf>

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
f0100ef1:	a1 90 fe 22 f0       	mov    0xf022fe90,%eax
f0100ef6:	8d 04 d8             	lea    (%eax,%ebx,8),%eax
f0100ef9:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link = 0;
f0100eff:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			cprintf("[?] non-boot CPUs (APs)\n");
f0100f05:	83 ec 0c             	sub    $0xc,%esp
f0100f08:	68 fa 67 10 f0       	push   $0xf01067fa
f0100f0d:	e8 96 29 00 00       	call   f01038a8 <cprintf>
f0100f12:	83 c4 10             	add    $0x10,%esp
f0100f15:	eb 28                	jmp    f0100f3f <page_init+0xa3>
		}
		else {
			pages[i].pp_ref = 0;
f0100f17:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100f1e:	89 c2                	mov    %eax,%edx
f0100f20:	03 15 90 fe 22 f0    	add    0xf022fe90,%edx
f0100f26:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
			pages[i].pp_link = page_free_list;
f0100f2c:	8b 0d 40 f2 22 f0    	mov    0xf022f240,%ecx
f0100f32:	89 0a                	mov    %ecx,(%edx)
			page_free_list = &pages[i];
f0100f34:	03 05 90 fe 22 f0    	add    0xf022fe90,%eax
f0100f3a:	a3 40 f2 22 f0       	mov    %eax,0xf022f240
	extern unsigned char mpentry_start[], mpentry_end[];
	uint32_t size = ROUNDUP(mpentry_end - mpentry_start, PGSIZE);
	cprintf("[?] %x\n", size);

	// 2)	[1-npages_basemem) free, except APs area (lab4)
	for (i = 1; i < npages_basemem; i++) {
f0100f3f:	83 c3 01             	add    $0x1,%ebx
f0100f42:	3b 1d 44 f2 22 f0    	cmp    0xf022f244,%ebx
f0100f48:	72 97                	jb     f0100ee1 <page_init+0x45>
f0100f4a:	8b 0d 40 f2 22 f0    	mov    0xf022f240,%ecx
f0100f50:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100f57:	ba 00 00 00 00       	mov    $0x0,%edx
f0100f5c:	eb 23                	jmp    f0100f81 <page_init+0xe5>
	}

	// [npages_basemem, IOPHYSMEM / PGSIZE) free
	// cprintf("[?] %d, %d, %d\n", npages_basemem, IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE);
	for (; i < IOPHYSMEM / PGSIZE; i++) {
		pages[i].pp_ref = 0;
f0100f5e:	89 c2                	mov    %eax,%edx
f0100f60:	03 15 90 fe 22 f0    	add    0xf022fe90,%edx
f0100f66:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f0100f6c:	89 0a                	mov    %ecx,(%edx)
		page_free_list = &pages[i];
f0100f6e:	89 c1                	mov    %eax,%ecx
f0100f70:	03 0d 90 fe 22 f0    	add    0xf022fe90,%ecx
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
f0100f8d:	89 0d 40 f2 22 f0    	mov    %ecx,0xf022f240
f0100f93:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100f9a:	eb 1a                	jmp    f0100fb6 <page_init+0x11a>
		page_free_list = &pages[i];
	}

	// 3) [IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE) in use
	for (; i < EXTPHYSMEM / PGSIZE; i++) {
		pages[i].pp_ref = 1;
f0100f9c:	89 c2                	mov    %eax,%edx
f0100f9e:	03 15 90 fe 22 f0    	add    0xf022fe90,%edx
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
f0100fc9:	03 05 90 fe 22 f0    	add    0xf022fe90,%eax
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
f0100ff3:	68 88 61 10 f0       	push   $0xf0106188
f0100ff8:	68 7b 01 00 00       	push   $0x17b
f0100ffd:	68 1f 67 10 f0       	push   $0xf010671f
f0101002:	e8 39 f0 ff ff       	call   f0100040 <_panic>
f0101007:	05 00 00 00 10       	add    $0x10000000,%eax
f010100c:	c1 e8 0c             	shr    $0xc,%eax
f010100f:	39 c3                	cmp    %eax,%ebx
f0101011:	72 b4                	jb     f0100fc7 <page_init+0x12b>
f0101013:	8b 0d 40 f2 22 f0    	mov    0xf022f240,%ecx
f0101019:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0101020:	ba 00 00 00 00       	mov    $0x0,%edx
f0101025:	eb 23                	jmp    f010104a <page_init+0x1ae>
	}

	// cprintf("[?] %d\n", npages);
	// [kernel end, npages) free
	for (; i < npages; i++) {
		pages[i].pp_ref = 0;
f0101027:	89 c2                	mov    %eax,%edx
f0101029:	03 15 90 fe 22 f0    	add    0xf022fe90,%edx
f010102f:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f0101035:	89 0a                	mov    %ecx,(%edx)
		page_free_list = &pages[i];
f0101037:	89 c1                	mov    %eax,%ecx
f0101039:	03 0d 90 fe 22 f0    	add    0xf022fe90,%ecx
		pages[i].pp_link = 0;
	}

	// cprintf("[?] %d\n", npages);
	// [kernel end, npages) free
	for (; i < npages; i++) {
f010103f:	83 c3 01             	add    $0x1,%ebx
f0101042:	83 c0 08             	add    $0x8,%eax
f0101045:	ba 01 00 00 00       	mov    $0x1,%edx
f010104a:	3b 1d 88 fe 22 f0    	cmp    0xf022fe88,%ebx
f0101050:	72 d5                	jb     f0101027 <page_init+0x18b>
f0101052:	84 d2                	test   %dl,%dl
f0101054:	74 06                	je     f010105c <page_init+0x1c0>
f0101056:	89 0d 40 f2 22 f0    	mov    %ecx,0xf022f240
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
f0101068:	8b 1d 40 f2 22 f0    	mov    0xf022f240,%ebx
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
f0101082:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0101088:	c1 f8 03             	sar    $0x3,%eax
f010108b:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010108e:	89 c2                	mov    %eax,%edx
f0101090:	c1 ea 0c             	shr    $0xc,%edx
f0101093:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0101099:	72 12                	jb     f01010ad <page_alloc+0x4a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010109b:	50                   	push   %eax
f010109c:	68 64 61 10 f0       	push   $0xf0106164
f01010a1:	6a 58                	push   $0x58
f01010a3:	68 2b 67 10 f0       	push   $0xf010672b
f01010a8:	e8 93 ef ff ff       	call   f0100040 <_panic>
		// cprintf("[?] alloc zero, %x, %x\n", page_free_list, PADDR(page_free_list));
		// memset((char *)page2pa(page_free_list), 0, PGSIZE);
		memset(page2kva(page_free_list), 0, PGSIZE);
f01010ad:	83 ec 04             	sub    $0x4,%esp
f01010b0:	68 00 10 00 00       	push   $0x1000
f01010b5:	6a 00                	push   $0x0
f01010b7:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01010bc:	50                   	push   %eax
f01010bd:	e8 c5 43 00 00       	call   f0105487 <memset>
f01010c2:	83 c4 10             	add    $0x10,%esp
	}
	
	// update free list head
	page_free_list = last_free;
f01010c5:	89 35 40 f2 22 f0    	mov    %esi,0xf022f240

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
f01010e9:	68 3c 6b 10 f0       	push   $0xf0106b3c
f01010ee:	68 c0 01 00 00       	push   $0x1c0
f01010f3:	68 1f 67 10 f0       	push   $0xf010671f
f01010f8:	e8 43 ef ff ff       	call   f0100040 <_panic>
	if (pp->pp_ref != 0)
f01010fd:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101102:	74 17                	je     f010111b <page_free+0x47>
		panic("page_free: other pointers still point to it, mind use-after-free!\n");
f0101104:	83 ec 04             	sub    $0x4,%esp
f0101107:	68 64 6b 10 f0       	push   $0xf0106b64
f010110c:	68 c2 01 00 00       	push   $0x1c2
f0101111:	68 1f 67 10 f0       	push   $0xf010671f
f0101116:	e8 25 ef ff ff       	call   f0100040 <_panic>

	pp->pp_link = page_free_list;
f010111b:	8b 15 40 f2 22 f0    	mov    0xf022f240,%edx
f0101121:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101123:	a3 40 f2 22 f0       	mov    %eax,0xf022f240

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
f010118b:	2b 15 90 fe 22 f0    	sub    0xf022fe90,%edx
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
f01011ae:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f01011b4:	72 15                	jb     f01011cb <pgdir_walk+0x7a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011b6:	50                   	push   %eax
f01011b7:	68 64 61 10 f0       	push   $0xf0106164
f01011bc:	68 0f 02 00 00       	push   $0x20f
f01011c1:	68 1f 67 10 f0       	push   $0xf010671f
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
f0101201:	68 a8 6b 10 f0       	push   $0xf0106ba8
f0101206:	68 24 02 00 00       	push   $0x224
f010120b:	68 1f 67 10 f0       	push   $0xf010671f
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
f0101243:	68 dc 6b 10 f0       	push   $0xf0106bdc
f0101248:	68 27 02 00 00       	push   $0x227
f010124d:	68 1f 67 10 f0       	push   $0xf010671f
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
f0101272:	68 0c 6c 10 f0       	push   $0xf0106c0c
f0101277:	68 32 02 00 00       	push   $0x232
f010127c:	68 1f 67 10 f0       	push   $0xf010671f
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
f01012d7:	3b 05 88 fe 22 f0    	cmp    0xf022fe88,%eax
f01012dd:	72 14                	jb     f01012f3 <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f01012df:	83 ec 04             	sub    $0x4,%esp
f01012e2:	68 38 6c 10 f0       	push   $0xf0106c38
f01012e7:	6a 51                	push   $0x51
f01012e9:	68 2b 67 10 f0       	push   $0xf010672b
f01012ee:	e8 4d ed ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f01012f3:	8b 15 90 fe 22 f0    	mov    0xf022fe90,%edx
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
f0101315:	e8 90 47 00 00       	call   f0105aaa <cpunum>
f010131a:	6b c0 74             	imul   $0x74,%eax,%eax
f010131d:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f0101324:	74 16                	je     f010133c <tlb_invalidate+0x2d>
f0101326:	e8 7f 47 00 00       	call   f0105aaa <cpunum>
f010132b:	6b c0 74             	imul   $0x74,%eax,%eax
f010132e:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
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
f01013c1:	2b 15 90 fe 22 f0    	sub    0xf022fe90,%edx
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
f01013e9:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
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
f010143c:	68 58 6c 10 f0       	push   $0xf0106c58
f0101441:	68 f9 02 00 00       	push   $0x2f9
f0101446:	68 1f 67 10 f0       	push   $0xf010671f
f010144b:	e8 f0 eb ff ff       	call   f0100040 <_panic>
		
	boot_map_region(kern_pgdir, mmio, ROUNDUP(size, PGSIZE), pa, PTE_PCD|PTE_PWT|PTE_W);
f0101450:	8d 99 ff 0f 00 00    	lea    0xfff(%ecx),%ebx
f0101456:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f010145c:	83 ec 08             	sub    $0x8,%esp
f010145f:	6a 1a                	push   $0x1a
f0101461:	ff 75 08             	pushl  0x8(%ebp)
f0101464:	89 d9                	mov    %ebx,%ecx
f0101466:	89 f2                	mov    %esi,%edx
f0101468:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
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
f01014ca:	89 15 88 fe 22 f0    	mov    %edx,0xf022fe88
	npages_basemem = basemem / (PGSIZE / 1024);
f01014d0:	89 da                	mov    %ebx,%edx
f01014d2:	c1 ea 02             	shr    $0x2,%edx
f01014d5:	89 15 44 f2 22 f0    	mov    %edx,0xf022f244

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01014db:	89 c2                	mov    %eax,%edx
f01014dd:	29 da                	sub    %ebx,%edx
f01014df:	52                   	push   %edx
f01014e0:	53                   	push   %ebx
f01014e1:	50                   	push   %eax
f01014e2:	68 7c 6c 10 f0       	push   $0xf0106c7c
f01014e7:	e8 bc 23 00 00       	call   f01038a8 <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01014ec:	b8 00 10 00 00       	mov    $0x1000,%eax
f01014f1:	e8 ed f5 ff ff       	call   f0100ae3 <boot_alloc>
f01014f6:	a3 8c fe 22 f0       	mov    %eax,0xf022fe8c
	memset(kern_pgdir, 0, PGSIZE);
f01014fb:	83 c4 0c             	add    $0xc,%esp
f01014fe:	68 00 10 00 00       	push   $0x1000
f0101503:	6a 00                	push   $0x0
f0101505:	50                   	push   %eax
f0101506:	e8 7c 3f 00 00       	call   f0105487 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010150b:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
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
f010151b:	68 88 61 10 f0       	push   $0xf0106188
f0101520:	68 99 00 00 00       	push   $0x99
f0101525:	68 1f 67 10 f0       	push   $0xf010671f
f010152a:	e8 11 eb ff ff       	call   f0100040 <_panic>
f010152f:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101535:	83 ca 05             	or     $0x5,%edx
f0101538:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:

	n = npages * sizeof(struct PageInfo);
f010153e:	a1 88 fe 22 f0       	mov    0xf022fe88,%eax
f0101543:	8d 1c c5 00 00 00 00 	lea    0x0(,%eax,8),%ebx
	pages = (struct PageInfo *) boot_alloc(n);
f010154a:	89 d8                	mov    %ebx,%eax
f010154c:	e8 92 f5 ff ff       	call   f0100ae3 <boot_alloc>
f0101551:	a3 90 fe 22 f0       	mov    %eax,0xf022fe90
	memset(pages, 0, n);
f0101556:	83 ec 04             	sub    $0x4,%esp
f0101559:	53                   	push   %ebx
f010155a:	6a 00                	push   $0x0
f010155c:	50                   	push   %eax
f010155d:	e8 25 3f 00 00       	call   f0105487 <memset>
	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.

	n = NENV * sizeof(struct Env);
	envs = (struct Env *) boot_alloc(n);
f0101562:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101567:	e8 77 f5 ff ff       	call   f0100ae3 <boot_alloc>
f010156c:	a3 48 f2 22 f0       	mov    %eax,0xf022f248
	memset(envs, 0, n);
f0101571:	83 c4 0c             	add    $0xc,%esp
f0101574:	68 00 f0 01 00       	push   $0x1f000
f0101579:	6a 00                	push   $0x0
f010157b:	50                   	push   %eax
f010157c:	e8 06 3f 00 00       	call   f0105487 <memset>
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
f0101593:	83 3d 90 fe 22 f0 00 	cmpl   $0x0,0xf022fe90
f010159a:	75 17                	jne    f01015b3 <mem_init+0x132>
		panic("'pages' is a null pointer!");
f010159c:	83 ec 04             	sub    $0x4,%esp
f010159f:	68 13 68 10 f0       	push   $0xf0106813
f01015a4:	68 9d 03 00 00       	push   $0x39d
f01015a9:	68 1f 67 10 f0       	push   $0xf010671f
f01015ae:	e8 8d ea ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01015b3:	a1 40 f2 22 f0       	mov    0xf022f240,%eax
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
f01015db:	68 2e 68 10 f0       	push   $0xf010682e
f01015e0:	68 45 67 10 f0       	push   $0xf0106745
f01015e5:	68 a5 03 00 00       	push   $0x3a5
f01015ea:	68 1f 67 10 f0       	push   $0xf010671f
f01015ef:	e8 4c ea ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01015f4:	83 ec 0c             	sub    $0xc,%esp
f01015f7:	6a 00                	push   $0x0
f01015f9:	e8 65 fa ff ff       	call   f0101063 <page_alloc>
f01015fe:	89 c6                	mov    %eax,%esi
f0101600:	83 c4 10             	add    $0x10,%esp
f0101603:	85 c0                	test   %eax,%eax
f0101605:	75 19                	jne    f0101620 <mem_init+0x19f>
f0101607:	68 44 68 10 f0       	push   $0xf0106844
f010160c:	68 45 67 10 f0       	push   $0xf0106745
f0101611:	68 a6 03 00 00       	push   $0x3a6
f0101616:	68 1f 67 10 f0       	push   $0xf010671f
f010161b:	e8 20 ea ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101620:	83 ec 0c             	sub    $0xc,%esp
f0101623:	6a 00                	push   $0x0
f0101625:	e8 39 fa ff ff       	call   f0101063 <page_alloc>
f010162a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010162d:	83 c4 10             	add    $0x10,%esp
f0101630:	85 c0                	test   %eax,%eax
f0101632:	75 19                	jne    f010164d <mem_init+0x1cc>
f0101634:	68 5a 68 10 f0       	push   $0xf010685a
f0101639:	68 45 67 10 f0       	push   $0xf0106745
f010163e:	68 a7 03 00 00       	push   $0x3a7
f0101643:	68 1f 67 10 f0       	push   $0xf010671f
f0101648:	e8 f3 e9 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010164d:	39 f7                	cmp    %esi,%edi
f010164f:	75 19                	jne    f010166a <mem_init+0x1e9>
f0101651:	68 70 68 10 f0       	push   $0xf0106870
f0101656:	68 45 67 10 f0       	push   $0xf0106745
f010165b:	68 aa 03 00 00       	push   $0x3aa
f0101660:	68 1f 67 10 f0       	push   $0xf010671f
f0101665:	e8 d6 e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010166a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010166d:	39 c6                	cmp    %eax,%esi
f010166f:	74 04                	je     f0101675 <mem_init+0x1f4>
f0101671:	39 c7                	cmp    %eax,%edi
f0101673:	75 19                	jne    f010168e <mem_init+0x20d>
f0101675:	68 b8 6c 10 f0       	push   $0xf0106cb8
f010167a:	68 45 67 10 f0       	push   $0xf0106745
f010167f:	68 ab 03 00 00       	push   $0x3ab
f0101684:	68 1f 67 10 f0       	push   $0xf010671f
f0101689:	e8 b2 e9 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010168e:	8b 0d 90 fe 22 f0    	mov    0xf022fe90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101694:	8b 15 88 fe 22 f0    	mov    0xf022fe88,%edx
f010169a:	c1 e2 0c             	shl    $0xc,%edx
f010169d:	89 f8                	mov    %edi,%eax
f010169f:	29 c8                	sub    %ecx,%eax
f01016a1:	c1 f8 03             	sar    $0x3,%eax
f01016a4:	c1 e0 0c             	shl    $0xc,%eax
f01016a7:	39 d0                	cmp    %edx,%eax
f01016a9:	72 19                	jb     f01016c4 <mem_init+0x243>
f01016ab:	68 82 68 10 f0       	push   $0xf0106882
f01016b0:	68 45 67 10 f0       	push   $0xf0106745
f01016b5:	68 ac 03 00 00       	push   $0x3ac
f01016ba:	68 1f 67 10 f0       	push   $0xf010671f
f01016bf:	e8 7c e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01016c4:	89 f0                	mov    %esi,%eax
f01016c6:	29 c8                	sub    %ecx,%eax
f01016c8:	c1 f8 03             	sar    $0x3,%eax
f01016cb:	c1 e0 0c             	shl    $0xc,%eax
f01016ce:	39 c2                	cmp    %eax,%edx
f01016d0:	77 19                	ja     f01016eb <mem_init+0x26a>
f01016d2:	68 9f 68 10 f0       	push   $0xf010689f
f01016d7:	68 45 67 10 f0       	push   $0xf0106745
f01016dc:	68 ad 03 00 00       	push   $0x3ad
f01016e1:	68 1f 67 10 f0       	push   $0xf010671f
f01016e6:	e8 55 e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01016eb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01016ee:	29 c8                	sub    %ecx,%eax
f01016f0:	c1 f8 03             	sar    $0x3,%eax
f01016f3:	c1 e0 0c             	shl    $0xc,%eax
f01016f6:	39 c2                	cmp    %eax,%edx
f01016f8:	77 19                	ja     f0101713 <mem_init+0x292>
f01016fa:	68 bc 68 10 f0       	push   $0xf01068bc
f01016ff:	68 45 67 10 f0       	push   $0xf0106745
f0101704:	68 ae 03 00 00       	push   $0x3ae
f0101709:	68 1f 67 10 f0       	push   $0xf010671f
f010170e:	e8 2d e9 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101713:	a1 40 f2 22 f0       	mov    0xf022f240,%eax
f0101718:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010171b:	c7 05 40 f2 22 f0 00 	movl   $0x0,0xf022f240
f0101722:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101725:	83 ec 0c             	sub    $0xc,%esp
f0101728:	6a 00                	push   $0x0
f010172a:	e8 34 f9 ff ff       	call   f0101063 <page_alloc>
f010172f:	83 c4 10             	add    $0x10,%esp
f0101732:	85 c0                	test   %eax,%eax
f0101734:	74 19                	je     f010174f <mem_init+0x2ce>
f0101736:	68 d9 68 10 f0       	push   $0xf01068d9
f010173b:	68 45 67 10 f0       	push   $0xf0106745
f0101740:	68 b5 03 00 00       	push   $0x3b5
f0101745:	68 1f 67 10 f0       	push   $0xf010671f
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
f0101780:	68 2e 68 10 f0       	push   $0xf010682e
f0101785:	68 45 67 10 f0       	push   $0xf0106745
f010178a:	68 bc 03 00 00       	push   $0x3bc
f010178f:	68 1f 67 10 f0       	push   $0xf010671f
f0101794:	e8 a7 e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101799:	83 ec 0c             	sub    $0xc,%esp
f010179c:	6a 00                	push   $0x0
f010179e:	e8 c0 f8 ff ff       	call   f0101063 <page_alloc>
f01017a3:	89 c7                	mov    %eax,%edi
f01017a5:	83 c4 10             	add    $0x10,%esp
f01017a8:	85 c0                	test   %eax,%eax
f01017aa:	75 19                	jne    f01017c5 <mem_init+0x344>
f01017ac:	68 44 68 10 f0       	push   $0xf0106844
f01017b1:	68 45 67 10 f0       	push   $0xf0106745
f01017b6:	68 bd 03 00 00       	push   $0x3bd
f01017bb:	68 1f 67 10 f0       	push   $0xf010671f
f01017c0:	e8 7b e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01017c5:	83 ec 0c             	sub    $0xc,%esp
f01017c8:	6a 00                	push   $0x0
f01017ca:	e8 94 f8 ff ff       	call   f0101063 <page_alloc>
f01017cf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01017d2:	83 c4 10             	add    $0x10,%esp
f01017d5:	85 c0                	test   %eax,%eax
f01017d7:	75 19                	jne    f01017f2 <mem_init+0x371>
f01017d9:	68 5a 68 10 f0       	push   $0xf010685a
f01017de:	68 45 67 10 f0       	push   $0xf0106745
f01017e3:	68 be 03 00 00       	push   $0x3be
f01017e8:	68 1f 67 10 f0       	push   $0xf010671f
f01017ed:	e8 4e e8 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01017f2:	39 fe                	cmp    %edi,%esi
f01017f4:	75 19                	jne    f010180f <mem_init+0x38e>
f01017f6:	68 70 68 10 f0       	push   $0xf0106870
f01017fb:	68 45 67 10 f0       	push   $0xf0106745
f0101800:	68 c0 03 00 00       	push   $0x3c0
f0101805:	68 1f 67 10 f0       	push   $0xf010671f
f010180a:	e8 31 e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010180f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101812:	39 c7                	cmp    %eax,%edi
f0101814:	74 04                	je     f010181a <mem_init+0x399>
f0101816:	39 c6                	cmp    %eax,%esi
f0101818:	75 19                	jne    f0101833 <mem_init+0x3b2>
f010181a:	68 b8 6c 10 f0       	push   $0xf0106cb8
f010181f:	68 45 67 10 f0       	push   $0xf0106745
f0101824:	68 c1 03 00 00       	push   $0x3c1
f0101829:	68 1f 67 10 f0       	push   $0xf010671f
f010182e:	e8 0d e8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101833:	83 ec 0c             	sub    $0xc,%esp
f0101836:	6a 00                	push   $0x0
f0101838:	e8 26 f8 ff ff       	call   f0101063 <page_alloc>
f010183d:	83 c4 10             	add    $0x10,%esp
f0101840:	85 c0                	test   %eax,%eax
f0101842:	74 19                	je     f010185d <mem_init+0x3dc>
f0101844:	68 d9 68 10 f0       	push   $0xf01068d9
f0101849:	68 45 67 10 f0       	push   $0xf0106745
f010184e:	68 c2 03 00 00       	push   $0x3c2
f0101853:	68 1f 67 10 f0       	push   $0xf010671f
f0101858:	e8 e3 e7 ff ff       	call   f0100040 <_panic>
f010185d:	89 f0                	mov    %esi,%eax
f010185f:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0101865:	c1 f8 03             	sar    $0x3,%eax
f0101868:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010186b:	89 c2                	mov    %eax,%edx
f010186d:	c1 ea 0c             	shr    $0xc,%edx
f0101870:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0101876:	72 12                	jb     f010188a <mem_init+0x409>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101878:	50                   	push   %eax
f0101879:	68 64 61 10 f0       	push   $0xf0106164
f010187e:	6a 58                	push   $0x58
f0101880:	68 2b 67 10 f0       	push   $0xf010672b
f0101885:	e8 b6 e7 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f010188a:	83 ec 04             	sub    $0x4,%esp
f010188d:	68 00 10 00 00       	push   $0x1000
f0101892:	6a 01                	push   $0x1
f0101894:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101899:	50                   	push   %eax
f010189a:	e8 e8 3b 00 00       	call   f0105487 <memset>
	page_free(pp0);
f010189f:	89 34 24             	mov    %esi,(%esp)
f01018a2:	e8 2d f8 ff ff       	call   f01010d4 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01018a7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01018ae:	e8 b0 f7 ff ff       	call   f0101063 <page_alloc>
f01018b3:	83 c4 10             	add    $0x10,%esp
f01018b6:	85 c0                	test   %eax,%eax
f01018b8:	75 19                	jne    f01018d3 <mem_init+0x452>
f01018ba:	68 e8 68 10 f0       	push   $0xf01068e8
f01018bf:	68 45 67 10 f0       	push   $0xf0106745
f01018c4:	68 c7 03 00 00       	push   $0x3c7
f01018c9:	68 1f 67 10 f0       	push   $0xf010671f
f01018ce:	e8 6d e7 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f01018d3:	39 c6                	cmp    %eax,%esi
f01018d5:	74 19                	je     f01018f0 <mem_init+0x46f>
f01018d7:	68 06 69 10 f0       	push   $0xf0106906
f01018dc:	68 45 67 10 f0       	push   $0xf0106745
f01018e1:	68 c8 03 00 00       	push   $0x3c8
f01018e6:	68 1f 67 10 f0       	push   $0xf010671f
f01018eb:	e8 50 e7 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01018f0:	89 f0                	mov    %esi,%eax
f01018f2:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f01018f8:	c1 f8 03             	sar    $0x3,%eax
f01018fb:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01018fe:	89 c2                	mov    %eax,%edx
f0101900:	c1 ea 0c             	shr    $0xc,%edx
f0101903:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0101909:	72 12                	jb     f010191d <mem_init+0x49c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010190b:	50                   	push   %eax
f010190c:	68 64 61 10 f0       	push   $0xf0106164
f0101911:	6a 58                	push   $0x58
f0101913:	68 2b 67 10 f0       	push   $0xf010672b
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
f010192e:	68 16 69 10 f0       	push   $0xf0106916
f0101933:	68 45 67 10 f0       	push   $0xf0106745
f0101938:	68 cc 03 00 00       	push   $0x3cc
f010193d:	68 1f 67 10 f0       	push   $0xf010671f
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
f0101951:	a3 40 f2 22 f0       	mov    %eax,0xf022f240

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
f0101972:	a1 40 f2 22 f0       	mov    0xf022f240,%eax
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
f0101989:	68 20 69 10 f0       	push   $0xf0106920
f010198e:	68 45 67 10 f0       	push   $0xf0106745
f0101993:	68 da 03 00 00       	push   $0x3da
f0101998:	68 1f 67 10 f0       	push   $0xf010671f
f010199d:	e8 9e e6 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f01019a2:	83 ec 0c             	sub    $0xc,%esp
f01019a5:	68 d8 6c 10 f0       	push   $0xf0106cd8
f01019aa:	e8 f9 1e 00 00       	call   f01038a8 <cprintf>
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
f01019c5:	68 2e 68 10 f0       	push   $0xf010682e
f01019ca:	68 45 67 10 f0       	push   $0xf0106745
f01019cf:	68 44 04 00 00       	push   $0x444
f01019d4:	68 1f 67 10 f0       	push   $0xf010671f
f01019d9:	e8 62 e6 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01019de:	83 ec 0c             	sub    $0xc,%esp
f01019e1:	6a 00                	push   $0x0
f01019e3:	e8 7b f6 ff ff       	call   f0101063 <page_alloc>
f01019e8:	89 c3                	mov    %eax,%ebx
f01019ea:	83 c4 10             	add    $0x10,%esp
f01019ed:	85 c0                	test   %eax,%eax
f01019ef:	75 19                	jne    f0101a0a <mem_init+0x589>
f01019f1:	68 44 68 10 f0       	push   $0xf0106844
f01019f6:	68 45 67 10 f0       	push   $0xf0106745
f01019fb:	68 45 04 00 00       	push   $0x445
f0101a00:	68 1f 67 10 f0       	push   $0xf010671f
f0101a05:	e8 36 e6 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101a0a:	83 ec 0c             	sub    $0xc,%esp
f0101a0d:	6a 00                	push   $0x0
f0101a0f:	e8 4f f6 ff ff       	call   f0101063 <page_alloc>
f0101a14:	89 c6                	mov    %eax,%esi
f0101a16:	83 c4 10             	add    $0x10,%esp
f0101a19:	85 c0                	test   %eax,%eax
f0101a1b:	75 19                	jne    f0101a36 <mem_init+0x5b5>
f0101a1d:	68 5a 68 10 f0       	push   $0xf010685a
f0101a22:	68 45 67 10 f0       	push   $0xf0106745
f0101a27:	68 46 04 00 00       	push   $0x446
f0101a2c:	68 1f 67 10 f0       	push   $0xf010671f
f0101a31:	e8 0a e6 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101a36:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101a39:	75 19                	jne    f0101a54 <mem_init+0x5d3>
f0101a3b:	68 70 68 10 f0       	push   $0xf0106870
f0101a40:	68 45 67 10 f0       	push   $0xf0106745
f0101a45:	68 49 04 00 00       	push   $0x449
f0101a4a:	68 1f 67 10 f0       	push   $0xf010671f
f0101a4f:	e8 ec e5 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a54:	39 c3                	cmp    %eax,%ebx
f0101a56:	74 05                	je     f0101a5d <mem_init+0x5dc>
f0101a58:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101a5b:	75 19                	jne    f0101a76 <mem_init+0x5f5>
f0101a5d:	68 b8 6c 10 f0       	push   $0xf0106cb8
f0101a62:	68 45 67 10 f0       	push   $0xf0106745
f0101a67:	68 4a 04 00 00       	push   $0x44a
f0101a6c:	68 1f 67 10 f0       	push   $0xf010671f
f0101a71:	e8 ca e5 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101a76:	a1 40 f2 22 f0       	mov    0xf022f240,%eax
f0101a7b:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101a7e:	c7 05 40 f2 22 f0 00 	movl   $0x0,0xf022f240
f0101a85:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101a88:	83 ec 0c             	sub    $0xc,%esp
f0101a8b:	6a 00                	push   $0x0
f0101a8d:	e8 d1 f5 ff ff       	call   f0101063 <page_alloc>
f0101a92:	83 c4 10             	add    $0x10,%esp
f0101a95:	85 c0                	test   %eax,%eax
f0101a97:	74 19                	je     f0101ab2 <mem_init+0x631>
f0101a99:	68 d9 68 10 f0       	push   $0xf01068d9
f0101a9e:	68 45 67 10 f0       	push   $0xf0106745
f0101aa3:	68 51 04 00 00       	push   $0x451
f0101aa8:	68 1f 67 10 f0       	push   $0xf010671f
f0101aad:	e8 8e e5 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101ab2:	83 ec 04             	sub    $0x4,%esp
f0101ab5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101ab8:	50                   	push   %eax
f0101ab9:	6a 00                	push   $0x0
f0101abb:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101ac1:	e8 e3 f7 ff ff       	call   f01012a9 <page_lookup>
f0101ac6:	83 c4 10             	add    $0x10,%esp
f0101ac9:	85 c0                	test   %eax,%eax
f0101acb:	74 19                	je     f0101ae6 <mem_init+0x665>
f0101acd:	68 f8 6c 10 f0       	push   $0xf0106cf8
f0101ad2:	68 45 67 10 f0       	push   $0xf0106745
f0101ad7:	68 54 04 00 00       	push   $0x454
f0101adc:	68 1f 67 10 f0       	push   $0xf010671f
f0101ae1:	e8 5a e5 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101ae6:	6a 02                	push   $0x2
f0101ae8:	6a 00                	push   $0x0
f0101aea:	53                   	push   %ebx
f0101aeb:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101af1:	e8 9b f8 ff ff       	call   f0101391 <page_insert>
f0101af6:	83 c4 10             	add    $0x10,%esp
f0101af9:	85 c0                	test   %eax,%eax
f0101afb:	78 19                	js     f0101b16 <mem_init+0x695>
f0101afd:	68 30 6d 10 f0       	push   $0xf0106d30
f0101b02:	68 45 67 10 f0       	push   $0xf0106745
f0101b07:	68 57 04 00 00       	push   $0x457
f0101b0c:	68 1f 67 10 f0       	push   $0xf010671f
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
f0101b26:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101b2c:	e8 60 f8 ff ff       	call   f0101391 <page_insert>
f0101b31:	83 c4 20             	add    $0x20,%esp
f0101b34:	85 c0                	test   %eax,%eax
f0101b36:	74 19                	je     f0101b51 <mem_init+0x6d0>
f0101b38:	68 60 6d 10 f0       	push   $0xf0106d60
f0101b3d:	68 45 67 10 f0       	push   $0xf0106745
f0101b42:	68 5b 04 00 00       	push   $0x45b
f0101b47:	68 1f 67 10 f0       	push   $0xf010671f
f0101b4c:	e8 ef e4 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101b51:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b57:	a1 90 fe 22 f0       	mov    0xf022fe90,%eax
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
f0101b78:	68 90 6d 10 f0       	push   $0xf0106d90
f0101b7d:	68 45 67 10 f0       	push   $0xf0106745
f0101b82:	68 5c 04 00 00       	push   $0x45c
f0101b87:	68 1f 67 10 f0       	push   $0xf010671f
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
f0101bac:	68 b8 6d 10 f0       	push   $0xf0106db8
f0101bb1:	68 45 67 10 f0       	push   $0xf0106745
f0101bb6:	68 5d 04 00 00       	push   $0x45d
f0101bbb:	68 1f 67 10 f0       	push   $0xf010671f
f0101bc0:	e8 7b e4 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101bc5:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101bca:	74 19                	je     f0101be5 <mem_init+0x764>
f0101bcc:	68 2b 69 10 f0       	push   $0xf010692b
f0101bd1:	68 45 67 10 f0       	push   $0xf0106745
f0101bd6:	68 5e 04 00 00       	push   $0x45e
f0101bdb:	68 1f 67 10 f0       	push   $0xf010671f
f0101be0:	e8 5b e4 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101be5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101be8:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101bed:	74 19                	je     f0101c08 <mem_init+0x787>
f0101bef:	68 3c 69 10 f0       	push   $0xf010693c
f0101bf4:	68 45 67 10 f0       	push   $0xf0106745
f0101bf9:	68 5f 04 00 00       	push   $0x45f
f0101bfe:	68 1f 67 10 f0       	push   $0xf010671f
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
f0101c1d:	68 e8 6d 10 f0       	push   $0xf0106de8
f0101c22:	68 45 67 10 f0       	push   $0xf0106745
f0101c27:	68 62 04 00 00       	push   $0x462
f0101c2c:	68 1f 67 10 f0       	push   $0xf010671f
f0101c31:	e8 0a e4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c36:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c3b:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f0101c40:	e8 f1 ee ff ff       	call   f0100b36 <check_va2pa>
f0101c45:	89 f2                	mov    %esi,%edx
f0101c47:	2b 15 90 fe 22 f0    	sub    0xf022fe90,%edx
f0101c4d:	c1 fa 03             	sar    $0x3,%edx
f0101c50:	c1 e2 0c             	shl    $0xc,%edx
f0101c53:	39 d0                	cmp    %edx,%eax
f0101c55:	74 19                	je     f0101c70 <mem_init+0x7ef>
f0101c57:	68 24 6e 10 f0       	push   $0xf0106e24
f0101c5c:	68 45 67 10 f0       	push   $0xf0106745
f0101c61:	68 63 04 00 00       	push   $0x463
f0101c66:	68 1f 67 10 f0       	push   $0xf010671f
f0101c6b:	e8 d0 e3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101c70:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101c75:	74 19                	je     f0101c90 <mem_init+0x80f>
f0101c77:	68 4d 69 10 f0       	push   $0xf010694d
f0101c7c:	68 45 67 10 f0       	push   $0xf0106745
f0101c81:	68 64 04 00 00       	push   $0x464
f0101c86:	68 1f 67 10 f0       	push   $0xf010671f
f0101c8b:	e8 b0 e3 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101c90:	83 ec 0c             	sub    $0xc,%esp
f0101c93:	6a 00                	push   $0x0
f0101c95:	e8 c9 f3 ff ff       	call   f0101063 <page_alloc>
f0101c9a:	83 c4 10             	add    $0x10,%esp
f0101c9d:	85 c0                	test   %eax,%eax
f0101c9f:	74 19                	je     f0101cba <mem_init+0x839>
f0101ca1:	68 d9 68 10 f0       	push   $0xf01068d9
f0101ca6:	68 45 67 10 f0       	push   $0xf0106745
f0101cab:	68 67 04 00 00       	push   $0x467
f0101cb0:	68 1f 67 10 f0       	push   $0xf010671f
f0101cb5:	e8 86 e3 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101cba:	6a 02                	push   $0x2
f0101cbc:	68 00 10 00 00       	push   $0x1000
f0101cc1:	56                   	push   %esi
f0101cc2:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101cc8:	e8 c4 f6 ff ff       	call   f0101391 <page_insert>
f0101ccd:	83 c4 10             	add    $0x10,%esp
f0101cd0:	85 c0                	test   %eax,%eax
f0101cd2:	74 19                	je     f0101ced <mem_init+0x86c>
f0101cd4:	68 e8 6d 10 f0       	push   $0xf0106de8
f0101cd9:	68 45 67 10 f0       	push   $0xf0106745
f0101cde:	68 6a 04 00 00       	push   $0x46a
f0101ce3:	68 1f 67 10 f0       	push   $0xf010671f
f0101ce8:	e8 53 e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ced:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101cf2:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f0101cf7:	e8 3a ee ff ff       	call   f0100b36 <check_va2pa>
f0101cfc:	89 f2                	mov    %esi,%edx
f0101cfe:	2b 15 90 fe 22 f0    	sub    0xf022fe90,%edx
f0101d04:	c1 fa 03             	sar    $0x3,%edx
f0101d07:	c1 e2 0c             	shl    $0xc,%edx
f0101d0a:	39 d0                	cmp    %edx,%eax
f0101d0c:	74 19                	je     f0101d27 <mem_init+0x8a6>
f0101d0e:	68 24 6e 10 f0       	push   $0xf0106e24
f0101d13:	68 45 67 10 f0       	push   $0xf0106745
f0101d18:	68 6b 04 00 00       	push   $0x46b
f0101d1d:	68 1f 67 10 f0       	push   $0xf010671f
f0101d22:	e8 19 e3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101d27:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d2c:	74 19                	je     f0101d47 <mem_init+0x8c6>
f0101d2e:	68 4d 69 10 f0       	push   $0xf010694d
f0101d33:	68 45 67 10 f0       	push   $0xf0106745
f0101d38:	68 6c 04 00 00       	push   $0x46c
f0101d3d:	68 1f 67 10 f0       	push   $0xf010671f
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
f0101d58:	68 d9 68 10 f0       	push   $0xf01068d9
f0101d5d:	68 45 67 10 f0       	push   $0xf0106745
f0101d62:	68 70 04 00 00       	push   $0x470
f0101d67:	68 1f 67 10 f0       	push   $0xf010671f
f0101d6c:	e8 cf e2 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101d71:	8b 15 8c fe 22 f0    	mov    0xf022fe8c,%edx
f0101d77:	8b 02                	mov    (%edx),%eax
f0101d79:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101d7e:	89 c1                	mov    %eax,%ecx
f0101d80:	c1 e9 0c             	shr    $0xc,%ecx
f0101d83:	3b 0d 88 fe 22 f0    	cmp    0xf022fe88,%ecx
f0101d89:	72 15                	jb     f0101da0 <mem_init+0x91f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101d8b:	50                   	push   %eax
f0101d8c:	68 64 61 10 f0       	push   $0xf0106164
f0101d91:	68 73 04 00 00       	push   $0x473
f0101d96:	68 1f 67 10 f0       	push   $0xf010671f
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
f0101dc5:	68 54 6e 10 f0       	push   $0xf0106e54
f0101dca:	68 45 67 10 f0       	push   $0xf0106745
f0101dcf:	68 74 04 00 00       	push   $0x474
f0101dd4:	68 1f 67 10 f0       	push   $0xf010671f
f0101dd9:	e8 62 e2 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101dde:	6a 06                	push   $0x6
f0101de0:	68 00 10 00 00       	push   $0x1000
f0101de5:	56                   	push   %esi
f0101de6:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101dec:	e8 a0 f5 ff ff       	call   f0101391 <page_insert>
f0101df1:	83 c4 10             	add    $0x10,%esp
f0101df4:	85 c0                	test   %eax,%eax
f0101df6:	74 19                	je     f0101e11 <mem_init+0x990>
f0101df8:	68 94 6e 10 f0       	push   $0xf0106e94
f0101dfd:	68 45 67 10 f0       	push   $0xf0106745
f0101e02:	68 77 04 00 00       	push   $0x477
f0101e07:	68 1f 67 10 f0       	push   $0xf010671f
f0101e0c:	e8 2f e2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e11:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi
f0101e17:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e1c:	89 f8                	mov    %edi,%eax
f0101e1e:	e8 13 ed ff ff       	call   f0100b36 <check_va2pa>
f0101e23:	89 f2                	mov    %esi,%edx
f0101e25:	2b 15 90 fe 22 f0    	sub    0xf022fe90,%edx
f0101e2b:	c1 fa 03             	sar    $0x3,%edx
f0101e2e:	c1 e2 0c             	shl    $0xc,%edx
f0101e31:	39 d0                	cmp    %edx,%eax
f0101e33:	74 19                	je     f0101e4e <mem_init+0x9cd>
f0101e35:	68 24 6e 10 f0       	push   $0xf0106e24
f0101e3a:	68 45 67 10 f0       	push   $0xf0106745
f0101e3f:	68 78 04 00 00       	push   $0x478
f0101e44:	68 1f 67 10 f0       	push   $0xf010671f
f0101e49:	e8 f2 e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101e4e:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101e53:	74 19                	je     f0101e6e <mem_init+0x9ed>
f0101e55:	68 4d 69 10 f0       	push   $0xf010694d
f0101e5a:	68 45 67 10 f0       	push   $0xf0106745
f0101e5f:	68 79 04 00 00       	push   $0x479
f0101e64:	68 1f 67 10 f0       	push   $0xf010671f
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
f0101e86:	68 d4 6e 10 f0       	push   $0xf0106ed4
f0101e8b:	68 45 67 10 f0       	push   $0xf0106745
f0101e90:	68 7a 04 00 00       	push   $0x47a
f0101e95:	68 1f 67 10 f0       	push   $0xf010671f
f0101e9a:	e8 a1 e1 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101e9f:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f0101ea4:	f6 00 04             	testb  $0x4,(%eax)
f0101ea7:	75 19                	jne    f0101ec2 <mem_init+0xa41>
f0101ea9:	68 5e 69 10 f0       	push   $0xf010695e
f0101eae:	68 45 67 10 f0       	push   $0xf0106745
f0101eb3:	68 7b 04 00 00       	push   $0x47b
f0101eb8:	68 1f 67 10 f0       	push   $0xf010671f
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
f0101ed7:	68 e8 6d 10 f0       	push   $0xf0106de8
f0101edc:	68 45 67 10 f0       	push   $0xf0106745
f0101ee1:	68 7e 04 00 00       	push   $0x47e
f0101ee6:	68 1f 67 10 f0       	push   $0xf010671f
f0101eeb:	e8 50 e1 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101ef0:	83 ec 04             	sub    $0x4,%esp
f0101ef3:	6a 00                	push   $0x0
f0101ef5:	68 00 10 00 00       	push   $0x1000
f0101efa:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101f00:	e8 4c f2 ff ff       	call   f0101151 <pgdir_walk>
f0101f05:	83 c4 10             	add    $0x10,%esp
f0101f08:	f6 00 02             	testb  $0x2,(%eax)
f0101f0b:	75 19                	jne    f0101f26 <mem_init+0xaa5>
f0101f0d:	68 08 6f 10 f0       	push   $0xf0106f08
f0101f12:	68 45 67 10 f0       	push   $0xf0106745
f0101f17:	68 7f 04 00 00       	push   $0x47f
f0101f1c:	68 1f 67 10 f0       	push   $0xf010671f
f0101f21:	e8 1a e1 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101f26:	83 ec 04             	sub    $0x4,%esp
f0101f29:	6a 00                	push   $0x0
f0101f2b:	68 00 10 00 00       	push   $0x1000
f0101f30:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101f36:	e8 16 f2 ff ff       	call   f0101151 <pgdir_walk>
f0101f3b:	83 c4 10             	add    $0x10,%esp
f0101f3e:	f6 00 04             	testb  $0x4,(%eax)
f0101f41:	74 19                	je     f0101f5c <mem_init+0xadb>
f0101f43:	68 3c 6f 10 f0       	push   $0xf0106f3c
f0101f48:	68 45 67 10 f0       	push   $0xf0106745
f0101f4d:	68 80 04 00 00       	push   $0x480
f0101f52:	68 1f 67 10 f0       	push   $0xf010671f
f0101f57:	e8 e4 e0 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101f5c:	6a 02                	push   $0x2
f0101f5e:	68 00 00 40 00       	push   $0x400000
f0101f63:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101f66:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101f6c:	e8 20 f4 ff ff       	call   f0101391 <page_insert>
f0101f71:	83 c4 10             	add    $0x10,%esp
f0101f74:	85 c0                	test   %eax,%eax
f0101f76:	78 19                	js     f0101f91 <mem_init+0xb10>
f0101f78:	68 74 6f 10 f0       	push   $0xf0106f74
f0101f7d:	68 45 67 10 f0       	push   $0xf0106745
f0101f82:	68 83 04 00 00       	push   $0x483
f0101f87:	68 1f 67 10 f0       	push   $0xf010671f
f0101f8c:	e8 af e0 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101f91:	6a 02                	push   $0x2
f0101f93:	68 00 10 00 00       	push   $0x1000
f0101f98:	53                   	push   %ebx
f0101f99:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101f9f:	e8 ed f3 ff ff       	call   f0101391 <page_insert>
f0101fa4:	83 c4 10             	add    $0x10,%esp
f0101fa7:	85 c0                	test   %eax,%eax
f0101fa9:	74 19                	je     f0101fc4 <mem_init+0xb43>
f0101fab:	68 ac 6f 10 f0       	push   $0xf0106fac
f0101fb0:	68 45 67 10 f0       	push   $0xf0106745
f0101fb5:	68 86 04 00 00       	push   $0x486
f0101fba:	68 1f 67 10 f0       	push   $0xf010671f
f0101fbf:	e8 7c e0 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101fc4:	83 ec 04             	sub    $0x4,%esp
f0101fc7:	6a 00                	push   $0x0
f0101fc9:	68 00 10 00 00       	push   $0x1000
f0101fce:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101fd4:	e8 78 f1 ff ff       	call   f0101151 <pgdir_walk>
f0101fd9:	83 c4 10             	add    $0x10,%esp
f0101fdc:	f6 00 04             	testb  $0x4,(%eax)
f0101fdf:	74 19                	je     f0101ffa <mem_init+0xb79>
f0101fe1:	68 3c 6f 10 f0       	push   $0xf0106f3c
f0101fe6:	68 45 67 10 f0       	push   $0xf0106745
f0101feb:	68 87 04 00 00       	push   $0x487
f0101ff0:	68 1f 67 10 f0       	push   $0xf010671f
f0101ff5:	e8 46 e0 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101ffa:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi
f0102000:	ba 00 00 00 00       	mov    $0x0,%edx
f0102005:	89 f8                	mov    %edi,%eax
f0102007:	e8 2a eb ff ff       	call   f0100b36 <check_va2pa>
f010200c:	89 c1                	mov    %eax,%ecx
f010200e:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102011:	89 d8                	mov    %ebx,%eax
f0102013:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0102019:	c1 f8 03             	sar    $0x3,%eax
f010201c:	c1 e0 0c             	shl    $0xc,%eax
f010201f:	39 c1                	cmp    %eax,%ecx
f0102021:	74 19                	je     f010203c <mem_init+0xbbb>
f0102023:	68 e8 6f 10 f0       	push   $0xf0106fe8
f0102028:	68 45 67 10 f0       	push   $0xf0106745
f010202d:	68 8a 04 00 00       	push   $0x48a
f0102032:	68 1f 67 10 f0       	push   $0xf010671f
f0102037:	e8 04 e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010203c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102041:	89 f8                	mov    %edi,%eax
f0102043:	e8 ee ea ff ff       	call   f0100b36 <check_va2pa>
f0102048:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f010204b:	74 19                	je     f0102066 <mem_init+0xbe5>
f010204d:	68 14 70 10 f0       	push   $0xf0107014
f0102052:	68 45 67 10 f0       	push   $0xf0106745
f0102057:	68 8b 04 00 00       	push   $0x48b
f010205c:	68 1f 67 10 f0       	push   $0xf010671f
f0102061:	e8 da df ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102066:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f010206b:	74 19                	je     f0102086 <mem_init+0xc05>
f010206d:	68 74 69 10 f0       	push   $0xf0106974
f0102072:	68 45 67 10 f0       	push   $0xf0106745
f0102077:	68 8d 04 00 00       	push   $0x48d
f010207c:	68 1f 67 10 f0       	push   $0xf010671f
f0102081:	e8 ba df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102086:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010208b:	74 19                	je     f01020a6 <mem_init+0xc25>
f010208d:	68 85 69 10 f0       	push   $0xf0106985
f0102092:	68 45 67 10 f0       	push   $0xf0106745
f0102097:	68 8e 04 00 00       	push   $0x48e
f010209c:	68 1f 67 10 f0       	push   $0xf010671f
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
f01020bb:	68 44 70 10 f0       	push   $0xf0107044
f01020c0:	68 45 67 10 f0       	push   $0xf0106745
f01020c5:	68 91 04 00 00       	push   $0x491
f01020ca:	68 1f 67 10 f0       	push   $0xf010671f
f01020cf:	e8 6c df ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01020d4:	83 ec 08             	sub    $0x8,%esp
f01020d7:	6a 00                	push   $0x0
f01020d9:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f01020df:	e8 60 f2 ff ff       	call   f0101344 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01020e4:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi
f01020ea:	ba 00 00 00 00       	mov    $0x0,%edx
f01020ef:	89 f8                	mov    %edi,%eax
f01020f1:	e8 40 ea ff ff       	call   f0100b36 <check_va2pa>
f01020f6:	83 c4 10             	add    $0x10,%esp
f01020f9:	83 f8 ff             	cmp    $0xffffffff,%eax
f01020fc:	74 19                	je     f0102117 <mem_init+0xc96>
f01020fe:	68 68 70 10 f0       	push   $0xf0107068
f0102103:	68 45 67 10 f0       	push   $0xf0106745
f0102108:	68 95 04 00 00       	push   $0x495
f010210d:	68 1f 67 10 f0       	push   $0xf010671f
f0102112:	e8 29 df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102117:	ba 00 10 00 00       	mov    $0x1000,%edx
f010211c:	89 f8                	mov    %edi,%eax
f010211e:	e8 13 ea ff ff       	call   f0100b36 <check_va2pa>
f0102123:	89 da                	mov    %ebx,%edx
f0102125:	2b 15 90 fe 22 f0    	sub    0xf022fe90,%edx
f010212b:	c1 fa 03             	sar    $0x3,%edx
f010212e:	c1 e2 0c             	shl    $0xc,%edx
f0102131:	39 d0                	cmp    %edx,%eax
f0102133:	74 19                	je     f010214e <mem_init+0xccd>
f0102135:	68 14 70 10 f0       	push   $0xf0107014
f010213a:	68 45 67 10 f0       	push   $0xf0106745
f010213f:	68 96 04 00 00       	push   $0x496
f0102144:	68 1f 67 10 f0       	push   $0xf010671f
f0102149:	e8 f2 de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f010214e:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102153:	74 19                	je     f010216e <mem_init+0xced>
f0102155:	68 2b 69 10 f0       	push   $0xf010692b
f010215a:	68 45 67 10 f0       	push   $0xf0106745
f010215f:	68 97 04 00 00       	push   $0x497
f0102164:	68 1f 67 10 f0       	push   $0xf010671f
f0102169:	e8 d2 de ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010216e:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102173:	74 19                	je     f010218e <mem_init+0xd0d>
f0102175:	68 85 69 10 f0       	push   $0xf0106985
f010217a:	68 45 67 10 f0       	push   $0xf0106745
f010217f:	68 98 04 00 00       	push   $0x498
f0102184:	68 1f 67 10 f0       	push   $0xf010671f
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
f01021a3:	68 8c 70 10 f0       	push   $0xf010708c
f01021a8:	68 45 67 10 f0       	push   $0xf0106745
f01021ad:	68 9b 04 00 00       	push   $0x49b
f01021b2:	68 1f 67 10 f0       	push   $0xf010671f
f01021b7:	e8 84 de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f01021bc:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01021c1:	75 19                	jne    f01021dc <mem_init+0xd5b>
f01021c3:	68 96 69 10 f0       	push   $0xf0106996
f01021c8:	68 45 67 10 f0       	push   $0xf0106745
f01021cd:	68 9c 04 00 00       	push   $0x49c
f01021d2:	68 1f 67 10 f0       	push   $0xf010671f
f01021d7:	e8 64 de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f01021dc:	83 3b 00             	cmpl   $0x0,(%ebx)
f01021df:	74 19                	je     f01021fa <mem_init+0xd79>
f01021e1:	68 a2 69 10 f0       	push   $0xf01069a2
f01021e6:	68 45 67 10 f0       	push   $0xf0106745
f01021eb:	68 9d 04 00 00       	push   $0x49d
f01021f0:	68 1f 67 10 f0       	push   $0xf010671f
f01021f5:	e8 46 de ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01021fa:	83 ec 08             	sub    $0x8,%esp
f01021fd:	68 00 10 00 00       	push   $0x1000
f0102202:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0102208:	e8 37 f1 ff ff       	call   f0101344 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010220d:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi
f0102213:	ba 00 00 00 00       	mov    $0x0,%edx
f0102218:	89 f8                	mov    %edi,%eax
f010221a:	e8 17 e9 ff ff       	call   f0100b36 <check_va2pa>
f010221f:	83 c4 10             	add    $0x10,%esp
f0102222:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102225:	74 19                	je     f0102240 <mem_init+0xdbf>
f0102227:	68 68 70 10 f0       	push   $0xf0107068
f010222c:	68 45 67 10 f0       	push   $0xf0106745
f0102231:	68 a1 04 00 00       	push   $0x4a1
f0102236:	68 1f 67 10 f0       	push   $0xf010671f
f010223b:	e8 00 de ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102240:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102245:	89 f8                	mov    %edi,%eax
f0102247:	e8 ea e8 ff ff       	call   f0100b36 <check_va2pa>
f010224c:	83 f8 ff             	cmp    $0xffffffff,%eax
f010224f:	74 19                	je     f010226a <mem_init+0xde9>
f0102251:	68 c4 70 10 f0       	push   $0xf01070c4
f0102256:	68 45 67 10 f0       	push   $0xf0106745
f010225b:	68 a2 04 00 00       	push   $0x4a2
f0102260:	68 1f 67 10 f0       	push   $0xf010671f
f0102265:	e8 d6 dd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f010226a:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010226f:	74 19                	je     f010228a <mem_init+0xe09>
f0102271:	68 b7 69 10 f0       	push   $0xf01069b7
f0102276:	68 45 67 10 f0       	push   $0xf0106745
f010227b:	68 a3 04 00 00       	push   $0x4a3
f0102280:	68 1f 67 10 f0       	push   $0xf010671f
f0102285:	e8 b6 dd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010228a:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010228f:	74 19                	je     f01022aa <mem_init+0xe29>
f0102291:	68 85 69 10 f0       	push   $0xf0106985
f0102296:	68 45 67 10 f0       	push   $0xf0106745
f010229b:	68 a4 04 00 00       	push   $0x4a4
f01022a0:	68 1f 67 10 f0       	push   $0xf010671f
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
f01022bf:	68 ec 70 10 f0       	push   $0xf01070ec
f01022c4:	68 45 67 10 f0       	push   $0xf0106745
f01022c9:	68 a7 04 00 00       	push   $0x4a7
f01022ce:	68 1f 67 10 f0       	push   $0xf010671f
f01022d3:	e8 68 dd ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01022d8:	83 ec 0c             	sub    $0xc,%esp
f01022db:	6a 00                	push   $0x0
f01022dd:	e8 81 ed ff ff       	call   f0101063 <page_alloc>
f01022e2:	83 c4 10             	add    $0x10,%esp
f01022e5:	85 c0                	test   %eax,%eax
f01022e7:	74 19                	je     f0102302 <mem_init+0xe81>
f01022e9:	68 d9 68 10 f0       	push   $0xf01068d9
f01022ee:	68 45 67 10 f0       	push   $0xf0106745
f01022f3:	68 aa 04 00 00       	push   $0x4aa
f01022f8:	68 1f 67 10 f0       	push   $0xf010671f
f01022fd:	e8 3e dd ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102302:	8b 0d 8c fe 22 f0    	mov    0xf022fe8c,%ecx
f0102308:	8b 11                	mov    (%ecx),%edx
f010230a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102310:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102313:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0102319:	c1 f8 03             	sar    $0x3,%eax
f010231c:	c1 e0 0c             	shl    $0xc,%eax
f010231f:	39 c2                	cmp    %eax,%edx
f0102321:	74 19                	je     f010233c <mem_init+0xebb>
f0102323:	68 90 6d 10 f0       	push   $0xf0106d90
f0102328:	68 45 67 10 f0       	push   $0xf0106745
f010232d:	68 ad 04 00 00       	push   $0x4ad
f0102332:	68 1f 67 10 f0       	push   $0xf010671f
f0102337:	e8 04 dd ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f010233c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102342:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102345:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010234a:	74 19                	je     f0102365 <mem_init+0xee4>
f010234c:	68 3c 69 10 f0       	push   $0xf010693c
f0102351:	68 45 67 10 f0       	push   $0xf0106745
f0102356:	68 af 04 00 00       	push   $0x4af
f010235b:	68 1f 67 10 f0       	push   $0xf010671f
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
f0102381:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0102387:	e8 c5 ed ff ff       	call   f0101151 <pgdir_walk>
f010238c:	89 c7                	mov    %eax,%edi
f010238e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102391:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f0102396:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102399:	8b 40 04             	mov    0x4(%eax),%eax
f010239c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01023a1:	8b 0d 88 fe 22 f0    	mov    0xf022fe88,%ecx
f01023a7:	89 c2                	mov    %eax,%edx
f01023a9:	c1 ea 0c             	shr    $0xc,%edx
f01023ac:	83 c4 10             	add    $0x10,%esp
f01023af:	39 ca                	cmp    %ecx,%edx
f01023b1:	72 15                	jb     f01023c8 <mem_init+0xf47>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01023b3:	50                   	push   %eax
f01023b4:	68 64 61 10 f0       	push   $0xf0106164
f01023b9:	68 b6 04 00 00       	push   $0x4b6
f01023be:	68 1f 67 10 f0       	push   $0xf010671f
f01023c3:	e8 78 dc ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01023c8:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f01023cd:	39 c7                	cmp    %eax,%edi
f01023cf:	74 19                	je     f01023ea <mem_init+0xf69>
f01023d1:	68 c8 69 10 f0       	push   $0xf01069c8
f01023d6:	68 45 67 10 f0       	push   $0xf0106745
f01023db:	68 b7 04 00 00       	push   $0x4b7
f01023e0:	68 1f 67 10 f0       	push   $0xf010671f
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
f01023fd:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
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
f0102413:	68 64 61 10 f0       	push   $0xf0106164
f0102418:	6a 58                	push   $0x58
f010241a:	68 2b 67 10 f0       	push   $0xf010672b
f010241f:	e8 1c dc ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102424:	83 ec 04             	sub    $0x4,%esp
f0102427:	68 00 10 00 00       	push   $0x1000
f010242c:	68 ff 00 00 00       	push   $0xff
f0102431:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102436:	50                   	push   %eax
f0102437:	e8 4b 30 00 00       	call   f0105487 <memset>
	page_free(pp0);
f010243c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010243f:	89 3c 24             	mov    %edi,(%esp)
f0102442:	e8 8d ec ff ff       	call   f01010d4 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102447:	83 c4 0c             	add    $0xc,%esp
f010244a:	6a 01                	push   $0x1
f010244c:	6a 00                	push   $0x0
f010244e:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0102454:	e8 f8 ec ff ff       	call   f0101151 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102459:	89 fa                	mov    %edi,%edx
f010245b:	2b 15 90 fe 22 f0    	sub    0xf022fe90,%edx
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
f010246f:	3b 05 88 fe 22 f0    	cmp    0xf022fe88,%eax
f0102475:	72 12                	jb     f0102489 <mem_init+0x1008>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102477:	52                   	push   %edx
f0102478:	68 64 61 10 f0       	push   $0xf0106164
f010247d:	6a 58                	push   $0x58
f010247f:	68 2b 67 10 f0       	push   $0xf010672b
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
f010249d:	68 e0 69 10 f0       	push   $0xf01069e0
f01024a2:	68 45 67 10 f0       	push   $0xf0106745
f01024a7:	68 c1 04 00 00       	push   $0x4c1
f01024ac:	68 1f 67 10 f0       	push   $0xf010671f
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
f01024bd:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f01024c2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01024c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01024cb:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f01024d1:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01024d4:	89 0d 40 f2 22 f0    	mov    %ecx,0xf022f240

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
f010252d:	68 10 71 10 f0       	push   $0xf0107110
f0102532:	68 45 67 10 f0       	push   $0xf0106745
f0102537:	68 d1 04 00 00       	push   $0x4d1
f010253c:	68 1f 67 10 f0       	push   $0xf010671f
f0102541:	e8 fa da ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f0102546:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
f010254c:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102552:	77 08                	ja     f010255c <mem_init+0x10db>
f0102554:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010255a:	77 19                	ja     f0102575 <mem_init+0x10f4>
f010255c:	68 38 71 10 f0       	push   $0xf0107138
f0102561:	68 45 67 10 f0       	push   $0xf0106745
f0102566:	68 d2 04 00 00       	push   $0x4d2
f010256b:	68 1f 67 10 f0       	push   $0xf010671f
f0102570:	e8 cb da ff ff       	call   f0100040 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102575:	89 da                	mov    %ebx,%edx
f0102577:	09 f2                	or     %esi,%edx
f0102579:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f010257f:	74 19                	je     f010259a <mem_init+0x1119>
f0102581:	68 60 71 10 f0       	push   $0xf0107160
f0102586:	68 45 67 10 f0       	push   $0xf0106745
f010258b:	68 d4 04 00 00       	push   $0x4d4
f0102590:	68 1f 67 10 f0       	push   $0xf010671f
f0102595:	e8 a6 da ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8192 <= mm2);
f010259a:	39 c6                	cmp    %eax,%esi
f010259c:	73 19                	jae    f01025b7 <mem_init+0x1136>
f010259e:	68 f7 69 10 f0       	push   $0xf01069f7
f01025a3:	68 45 67 10 f0       	push   $0xf0106745
f01025a8:	68 d6 04 00 00       	push   $0x4d6
f01025ad:	68 1f 67 10 f0       	push   $0xf010671f
f01025b2:	e8 89 da ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01025b7:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi
f01025bd:	89 da                	mov    %ebx,%edx
f01025bf:	89 f8                	mov    %edi,%eax
f01025c1:	e8 70 e5 ff ff       	call   f0100b36 <check_va2pa>
f01025c6:	85 c0                	test   %eax,%eax
f01025c8:	74 19                	je     f01025e3 <mem_init+0x1162>
f01025ca:	68 88 71 10 f0       	push   $0xf0107188
f01025cf:	68 45 67 10 f0       	push   $0xf0106745
f01025d4:	68 d8 04 00 00       	push   $0x4d8
f01025d9:	68 1f 67 10 f0       	push   $0xf010671f
f01025de:	e8 5d da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01025e3:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f01025e9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01025ec:	89 c2                	mov    %eax,%edx
f01025ee:	89 f8                	mov    %edi,%eax
f01025f0:	e8 41 e5 ff ff       	call   f0100b36 <check_va2pa>
f01025f5:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01025fa:	74 19                	je     f0102615 <mem_init+0x1194>
f01025fc:	68 ac 71 10 f0       	push   $0xf01071ac
f0102601:	68 45 67 10 f0       	push   $0xf0106745
f0102606:	68 d9 04 00 00       	push   $0x4d9
f010260b:	68 1f 67 10 f0       	push   $0xf010671f
f0102610:	e8 2b da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102615:	89 f2                	mov    %esi,%edx
f0102617:	89 f8                	mov    %edi,%eax
f0102619:	e8 18 e5 ff ff       	call   f0100b36 <check_va2pa>
f010261e:	85 c0                	test   %eax,%eax
f0102620:	74 19                	je     f010263b <mem_init+0x11ba>
f0102622:	68 dc 71 10 f0       	push   $0xf01071dc
f0102627:	68 45 67 10 f0       	push   $0xf0106745
f010262c:	68 da 04 00 00       	push   $0x4da
f0102631:	68 1f 67 10 f0       	push   $0xf010671f
f0102636:	e8 05 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f010263b:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102641:	89 f8                	mov    %edi,%eax
f0102643:	e8 ee e4 ff ff       	call   f0100b36 <check_va2pa>
f0102648:	83 f8 ff             	cmp    $0xffffffff,%eax
f010264b:	74 19                	je     f0102666 <mem_init+0x11e5>
f010264d:	68 00 72 10 f0       	push   $0xf0107200
f0102652:	68 45 67 10 f0       	push   $0xf0106745
f0102657:	68 db 04 00 00       	push   $0x4db
f010265c:	68 1f 67 10 f0       	push   $0xf010671f
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
f010267a:	68 2c 72 10 f0       	push   $0xf010722c
f010267f:	68 45 67 10 f0       	push   $0xf0106745
f0102684:	68 dd 04 00 00       	push   $0x4dd
f0102689:	68 1f 67 10 f0       	push   $0xf010671f
f010268e:	e8 ad d9 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102693:	83 ec 04             	sub    $0x4,%esp
f0102696:	6a 00                	push   $0x0
f0102698:	53                   	push   %ebx
f0102699:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f010269f:	e8 ad ea ff ff       	call   f0101151 <pgdir_walk>
f01026a4:	8b 00                	mov    (%eax),%eax
f01026a6:	83 c4 10             	add    $0x10,%esp
f01026a9:	83 e0 04             	and    $0x4,%eax
f01026ac:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01026af:	74 19                	je     f01026ca <mem_init+0x1249>
f01026b1:	68 70 72 10 f0       	push   $0xf0107270
f01026b6:	68 45 67 10 f0       	push   $0xf0106745
f01026bb:	68 de 04 00 00       	push   $0x4de
f01026c0:	68 1f 67 10 f0       	push   $0xf010671f
f01026c5:	e8 76 d9 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f01026ca:	83 ec 04             	sub    $0x4,%esp
f01026cd:	6a 00                	push   $0x0
f01026cf:	53                   	push   %ebx
f01026d0:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f01026d6:	e8 76 ea ff ff       	call   f0101151 <pgdir_walk>
f01026db:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f01026e1:	83 c4 0c             	add    $0xc,%esp
f01026e4:	6a 00                	push   $0x0
f01026e6:	ff 75 d4             	pushl  -0x2c(%ebp)
f01026e9:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f01026ef:	e8 5d ea ff ff       	call   f0101151 <pgdir_walk>
f01026f4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f01026fa:	83 c4 0c             	add    $0xc,%esp
f01026fd:	6a 00                	push   $0x0
f01026ff:	56                   	push   %esi
f0102700:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0102706:	e8 46 ea ff ff       	call   f0101151 <pgdir_walk>
f010270b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102711:	c7 04 24 09 6a 10 f0 	movl   $0xf0106a09,(%esp)
f0102718:	e8 8b 11 00 00       	call   f01038a8 <cprintf>
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f010271d:	a1 90 fe 22 f0       	mov    0xf022fe90,%eax
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
f010272d:	68 88 61 10 f0       	push   $0xf0106188
f0102732:	68 c8 00 00 00       	push   $0xc8
f0102737:	68 1f 67 10 f0       	push   $0xf010671f
f010273c:	e8 ff d8 ff ff       	call   f0100040 <_panic>
f0102741:	83 ec 08             	sub    $0x8,%esp
f0102744:	6a 04                	push   $0x4
f0102746:	05 00 00 00 10       	add    $0x10000000,%eax
f010274b:	50                   	push   %eax
f010274c:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102751:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102756:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f010275b:	e8 87 ea ff ff       	call   f01011e7 <boot_map_region>
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.

	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U);
f0102760:	a1 48 f2 22 f0       	mov    0xf022f248,%eax
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
f0102770:	68 88 61 10 f0       	push   $0xf0106188
f0102775:	68 d2 00 00 00       	push   $0xd2
f010277a:	68 1f 67 10 f0       	push   $0xf010671f
f010277f:	e8 bc d8 ff ff       	call   f0100040 <_panic>
f0102784:	83 ec 08             	sub    $0x8,%esp
f0102787:	6a 04                	push   $0x4
f0102789:	05 00 00 00 10       	add    $0x10000000,%eax
f010278e:	50                   	push   %eax
f010278f:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102794:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102799:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
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
f01027b3:	68 88 61 10 f0       	push   $0xf0106188
f01027b8:	68 e0 00 00 00       	push   $0xe0
f01027bd:	68 1f 67 10 f0       	push   $0xf010671f
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
f01027db:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
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
f01027f6:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f01027fb:	e8 e7 e9 ff ff       	call   f01011e7 <boot_map_region>
f0102800:	c7 45 c4 00 10 23 f0 	movl   $0xf0231000,-0x3c(%ebp)
f0102807:	83 c4 10             	add    $0x10,%esp
f010280a:	bb 00 10 23 f0       	mov    $0xf0231000,%ebx
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
f010281d:	68 88 61 10 f0       	push   $0xf0106188
f0102822:	68 24 01 00 00       	push   $0x124
f0102827:	68 1f 67 10 f0       	push   $0xf010671f
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
f0102844:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f0102849:	e8 99 e9 ff ff       	call   f01011e7 <boot_map_region>
f010284e:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102854:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//
	// LAB 4: Your code here:

	uint32_t kstacktop_i;

	for (int i=0; i<NCPU; i++) {
f010285a:	83 c4 10             	add    $0x10,%esp
f010285d:	b8 00 10 27 f0       	mov    $0xf0271000,%eax
f0102862:	39 d8                	cmp    %ebx,%eax
f0102864:	75 ae                	jne    f0102814 <mem_init+0x1393>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102866:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010286c:	a1 88 fe 22 f0       	mov    0xf022fe88,%eax
f0102871:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102874:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f010287b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102880:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102883:	8b 35 90 fe 22 f0    	mov    0xf022fe90,%esi
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
f01028aa:	68 88 61 10 f0       	push   $0xf0106188
f01028af:	68 f2 03 00 00       	push   $0x3f2
f01028b4:	68 1f 67 10 f0       	push   $0xf010671f
f01028b9:	e8 82 d7 ff ff       	call   f0100040 <_panic>
f01028be:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f01028c5:	39 c2                	cmp    %eax,%edx
f01028c7:	74 19                	je     f01028e2 <mem_init+0x1461>
f01028c9:	68 a4 72 10 f0       	push   $0xf01072a4
f01028ce:	68 45 67 10 f0       	push   $0xf0106745
f01028d3:	68 f2 03 00 00       	push   $0x3f2
f01028d8:	68 1f 67 10 f0       	push   $0xf010671f
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
f01028ed:	8b 35 48 f2 22 f0    	mov    0xf022f248,%esi
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
f010290e:	68 88 61 10 f0       	push   $0xf0106188
f0102913:	68 f7 03 00 00       	push   $0x3f7
f0102918:	68 1f 67 10 f0       	push   $0xf010671f
f010291d:	e8 1e d7 ff ff       	call   f0100040 <_panic>
f0102922:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f0102929:	39 d0                	cmp    %edx,%eax
f010292b:	74 19                	je     f0102946 <mem_init+0x14c5>
f010292d:	68 d8 72 10 f0       	push   $0xf01072d8
f0102932:	68 45 67 10 f0       	push   $0xf0106745
f0102937:	68 f7 03 00 00       	push   $0x3f7
f010293c:	68 1f 67 10 f0       	push   $0xf010671f
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
f0102972:	68 0c 73 10 f0       	push   $0xf010730c
f0102977:	68 45 67 10 f0       	push   $0xf0106745
f010297c:	68 fb 03 00 00       	push   $0x3fb
f0102981:	68 1f 67 10 f0       	push   $0xf010671f
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
f01029cb:	68 88 61 10 f0       	push   $0xf0106188
f01029d0:	68 03 04 00 00       	push   $0x403
f01029d5:	68 1f 67 10 f0       	push   $0xf010671f
f01029da:	e8 61 d6 ff ff       	call   f0100040 <_panic>
f01029df:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01029e2:	8d 94 0b 00 10 23 f0 	lea    -0xfdcf000(%ebx,%ecx,1),%edx
f01029e9:	39 d0                	cmp    %edx,%eax
f01029eb:	74 19                	je     f0102a06 <mem_init+0x1585>
f01029ed:	68 34 73 10 f0       	push   $0xf0107334
f01029f2:	68 45 67 10 f0       	push   $0xf0106745
f01029f7:	68 03 04 00 00       	push   $0x403
f01029fc:	68 1f 67 10 f0       	push   $0xf010671f
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
f0102a2d:	68 7c 73 10 f0       	push   $0xf010737c
f0102a32:	68 45 67 10 f0       	push   $0xf0106745
f0102a37:	68 05 04 00 00       	push   $0x405
f0102a3c:	68 1f 67 10 f0       	push   $0xf010671f
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
f0102a67:	b8 00 10 27 f0       	mov    $0xf0271000,%eax
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
f0102a8c:	68 22 6a 10 f0       	push   $0xf0106a22
f0102a91:	68 45 67 10 f0       	push   $0xf0106745
f0102a96:	68 10 04 00 00       	push   $0x410
f0102a9b:	68 1f 67 10 f0       	push   $0xf010671f
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
f0102ab4:	68 22 6a 10 f0       	push   $0xf0106a22
f0102ab9:	68 45 67 10 f0       	push   $0xf0106745
f0102abe:	68 14 04 00 00       	push   $0x414
f0102ac3:	68 1f 67 10 f0       	push   $0xf010671f
f0102ac8:	e8 73 d5 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102acd:	f6 c2 02             	test   $0x2,%dl
f0102ad0:	75 38                	jne    f0102b0a <mem_init+0x1689>
f0102ad2:	68 33 6a 10 f0       	push   $0xf0106a33
f0102ad7:	68 45 67 10 f0       	push   $0xf0106745
f0102adc:	68 15 04 00 00       	push   $0x415
f0102ae1:	68 1f 67 10 f0       	push   $0xf010671f
f0102ae6:	e8 55 d5 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102aeb:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102aef:	74 19                	je     f0102b0a <mem_init+0x1689>
f0102af1:	68 44 6a 10 f0       	push   $0xf0106a44
f0102af6:	68 45 67 10 f0       	push   $0xf0106745
f0102afb:	68 17 04 00 00       	push   $0x417
f0102b00:	68 1f 67 10 f0       	push   $0xf010671f
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
f0102b1b:	68 a0 73 10 f0       	push   $0xf01073a0
f0102b20:	e8 83 0d 00 00       	call   f01038a8 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102b25:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
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
f0102b35:	68 88 61 10 f0       	push   $0xf0106188
f0102b3a:	68 fa 00 00 00       	push   $0xfa
f0102b3f:	68 1f 67 10 f0       	push   $0xf010671f
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
f0102b7c:	68 2e 68 10 f0       	push   $0xf010682e
f0102b81:	68 45 67 10 f0       	push   $0xf0106745
f0102b86:	68 f3 04 00 00       	push   $0x4f3
f0102b8b:	68 1f 67 10 f0       	push   $0xf010671f
f0102b90:	e8 ab d4 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102b95:	83 ec 0c             	sub    $0xc,%esp
f0102b98:	6a 00                	push   $0x0
f0102b9a:	e8 c4 e4 ff ff       	call   f0101063 <page_alloc>
f0102b9f:	89 c7                	mov    %eax,%edi
f0102ba1:	83 c4 10             	add    $0x10,%esp
f0102ba4:	85 c0                	test   %eax,%eax
f0102ba6:	75 19                	jne    f0102bc1 <mem_init+0x1740>
f0102ba8:	68 44 68 10 f0       	push   $0xf0106844
f0102bad:	68 45 67 10 f0       	push   $0xf0106745
f0102bb2:	68 f4 04 00 00       	push   $0x4f4
f0102bb7:	68 1f 67 10 f0       	push   $0xf010671f
f0102bbc:	e8 7f d4 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102bc1:	83 ec 0c             	sub    $0xc,%esp
f0102bc4:	6a 00                	push   $0x0
f0102bc6:	e8 98 e4 ff ff       	call   f0101063 <page_alloc>
f0102bcb:	89 c6                	mov    %eax,%esi
f0102bcd:	83 c4 10             	add    $0x10,%esp
f0102bd0:	85 c0                	test   %eax,%eax
f0102bd2:	75 19                	jne    f0102bed <mem_init+0x176c>
f0102bd4:	68 5a 68 10 f0       	push   $0xf010685a
f0102bd9:	68 45 67 10 f0       	push   $0xf0106745
f0102bde:	68 f5 04 00 00       	push   $0x4f5
f0102be3:	68 1f 67 10 f0       	push   $0xf010671f
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
f0102bf8:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
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
f0102c0c:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0102c12:	72 12                	jb     f0102c26 <mem_init+0x17a5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c14:	50                   	push   %eax
f0102c15:	68 64 61 10 f0       	push   $0xf0106164
f0102c1a:	6a 58                	push   $0x58
f0102c1c:	68 2b 67 10 f0       	push   $0xf010672b
f0102c21:	e8 1a d4 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102c26:	83 ec 04             	sub    $0x4,%esp
f0102c29:	68 00 10 00 00       	push   $0x1000
f0102c2e:	6a 01                	push   $0x1
f0102c30:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c35:	50                   	push   %eax
f0102c36:	e8 4c 28 00 00       	call   f0105487 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102c3b:	89 f0                	mov    %esi,%eax
f0102c3d:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
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
f0102c51:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0102c57:	72 12                	jb     f0102c6b <mem_init+0x17ea>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c59:	50                   	push   %eax
f0102c5a:	68 64 61 10 f0       	push   $0xf0106164
f0102c5f:	6a 58                	push   $0x58
f0102c61:	68 2b 67 10 f0       	push   $0xf010672b
f0102c66:	e8 d5 d3 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102c6b:	83 ec 04             	sub    $0x4,%esp
f0102c6e:	68 00 10 00 00       	push   $0x1000
f0102c73:	6a 02                	push   $0x2
f0102c75:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c7a:	50                   	push   %eax
f0102c7b:	e8 07 28 00 00       	call   f0105487 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102c80:	6a 02                	push   $0x2
f0102c82:	68 00 10 00 00       	push   $0x1000
f0102c87:	57                   	push   %edi
f0102c88:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0102c8e:	e8 fe e6 ff ff       	call   f0101391 <page_insert>
	assert(pp1->pp_ref == 1);
f0102c93:	83 c4 20             	add    $0x20,%esp
f0102c96:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102c9b:	74 19                	je     f0102cb6 <mem_init+0x1835>
f0102c9d:	68 2b 69 10 f0       	push   $0xf010692b
f0102ca2:	68 45 67 10 f0       	push   $0xf0106745
f0102ca7:	68 fa 04 00 00       	push   $0x4fa
f0102cac:	68 1f 67 10 f0       	push   $0xf010671f
f0102cb1:	e8 8a d3 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102cb6:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102cbd:	01 01 01 
f0102cc0:	74 19                	je     f0102cdb <mem_init+0x185a>
f0102cc2:	68 c0 73 10 f0       	push   $0xf01073c0
f0102cc7:	68 45 67 10 f0       	push   $0xf0106745
f0102ccc:	68 fb 04 00 00       	push   $0x4fb
f0102cd1:	68 1f 67 10 f0       	push   $0xf010671f
f0102cd6:	e8 65 d3 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102cdb:	6a 02                	push   $0x2
f0102cdd:	68 00 10 00 00       	push   $0x1000
f0102ce2:	56                   	push   %esi
f0102ce3:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0102ce9:	e8 a3 e6 ff ff       	call   f0101391 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102cee:	83 c4 10             	add    $0x10,%esp
f0102cf1:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102cf8:	02 02 02 
f0102cfb:	74 19                	je     f0102d16 <mem_init+0x1895>
f0102cfd:	68 e4 73 10 f0       	push   $0xf01073e4
f0102d02:	68 45 67 10 f0       	push   $0xf0106745
f0102d07:	68 fd 04 00 00       	push   $0x4fd
f0102d0c:	68 1f 67 10 f0       	push   $0xf010671f
f0102d11:	e8 2a d3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102d16:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102d1b:	74 19                	je     f0102d36 <mem_init+0x18b5>
f0102d1d:	68 4d 69 10 f0       	push   $0xf010694d
f0102d22:	68 45 67 10 f0       	push   $0xf0106745
f0102d27:	68 fe 04 00 00       	push   $0x4fe
f0102d2c:	68 1f 67 10 f0       	push   $0xf010671f
f0102d31:	e8 0a d3 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102d36:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102d3b:	74 19                	je     f0102d56 <mem_init+0x18d5>
f0102d3d:	68 b7 69 10 f0       	push   $0xf01069b7
f0102d42:	68 45 67 10 f0       	push   $0xf0106745
f0102d47:	68 ff 04 00 00       	push   $0x4ff
f0102d4c:	68 1f 67 10 f0       	push   $0xf010671f
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
f0102d62:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0102d68:	c1 f8 03             	sar    $0x3,%eax
f0102d6b:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102d6e:	89 c2                	mov    %eax,%edx
f0102d70:	c1 ea 0c             	shr    $0xc,%edx
f0102d73:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0102d79:	72 12                	jb     f0102d8d <mem_init+0x190c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d7b:	50                   	push   %eax
f0102d7c:	68 64 61 10 f0       	push   $0xf0106164
f0102d81:	6a 58                	push   $0x58
f0102d83:	68 2b 67 10 f0       	push   $0xf010672b
f0102d88:	e8 b3 d2 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102d8d:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102d94:	03 03 03 
f0102d97:	74 19                	je     f0102db2 <mem_init+0x1931>
f0102d99:	68 08 74 10 f0       	push   $0xf0107408
f0102d9e:	68 45 67 10 f0       	push   $0xf0106745
f0102da3:	68 01 05 00 00       	push   $0x501
f0102da8:	68 1f 67 10 f0       	push   $0xf010671f
f0102dad:	e8 8e d2 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102db2:	83 ec 08             	sub    $0x8,%esp
f0102db5:	68 00 10 00 00       	push   $0x1000
f0102dba:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0102dc0:	e8 7f e5 ff ff       	call   f0101344 <page_remove>
	assert(pp2->pp_ref == 0);
f0102dc5:	83 c4 10             	add    $0x10,%esp
f0102dc8:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102dcd:	74 19                	je     f0102de8 <mem_init+0x1967>
f0102dcf:	68 85 69 10 f0       	push   $0xf0106985
f0102dd4:	68 45 67 10 f0       	push   $0xf0106745
f0102dd9:	68 03 05 00 00       	push   $0x503
f0102dde:	68 1f 67 10 f0       	push   $0xf010671f
f0102de3:	e8 58 d2 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102de8:	8b 0d 8c fe 22 f0    	mov    0xf022fe8c,%ecx
f0102dee:	8b 11                	mov    (%ecx),%edx
f0102df0:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102df6:	89 d8                	mov    %ebx,%eax
f0102df8:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0102dfe:	c1 f8 03             	sar    $0x3,%eax
f0102e01:	c1 e0 0c             	shl    $0xc,%eax
f0102e04:	39 c2                	cmp    %eax,%edx
f0102e06:	74 19                	je     f0102e21 <mem_init+0x19a0>
f0102e08:	68 90 6d 10 f0       	push   $0xf0106d90
f0102e0d:	68 45 67 10 f0       	push   $0xf0106745
f0102e12:	68 06 05 00 00       	push   $0x506
f0102e17:	68 1f 67 10 f0       	push   $0xf010671f
f0102e1c:	e8 1f d2 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102e21:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102e27:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102e2c:	74 19                	je     f0102e47 <mem_init+0x19c6>
f0102e2e:	68 3c 69 10 f0       	push   $0xf010693c
f0102e33:	68 45 67 10 f0       	push   $0xf0106745
f0102e38:	68 08 05 00 00       	push   $0x508
f0102e3d:	68 1f 67 10 f0       	push   $0xf010671f
f0102e42:	e8 f9 d1 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102e47:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102e4d:	83 ec 0c             	sub    $0xc,%esp
f0102e50:	53                   	push   %ebx
f0102e51:	e8 7e e2 ff ff       	call   f01010d4 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102e56:	c7 04 24 34 74 10 f0 	movl   $0xf0107434,(%esp)
f0102e5d:	e8 46 0a 00 00       	call   f01038a8 <cprintf>
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
f0102eb2:	a3 3c f2 22 f0       	mov    %eax,0xf022f23c
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
f0102edd:	a3 3c f2 22 f0       	mov    %eax,0xf022f23c
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
f0102efb:	a3 3c f2 22 f0       	mov    %eax,0xf022f23c
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
f0102f46:	ff 35 3c f2 22 f0    	pushl  0xf022f23c
f0102f4c:	ff 73 48             	pushl  0x48(%ebx)
f0102f4f:	68 60 74 10 f0       	push   $0xf0107460
f0102f54:	e8 4f 09 00 00       	call   f01038a8 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102f59:	89 1c 24             	mov    %ebx,(%esp)
f0102f5c:	e8 46 06 00 00       	call   f01035a7 <env_destroy>
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
f0102f9f:	68 98 74 10 f0       	push   $0xf0107498
f0102fa4:	68 2d 01 00 00       	push   $0x12d
f0102fa9:	68 5c 75 10 f0       	push   $0xf010755c
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
f0102fc7:	68 bc 74 10 f0       	push   $0xf01074bc
f0102fcc:	68 32 01 00 00       	push   $0x132
f0102fd1:	68 5c 75 10 f0       	push   $0xf010755c
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
f0102ffc:	e8 a9 2a 00 00       	call   f0105aaa <cpunum>
f0103001:	6b c0 74             	imul   $0x74,%eax,%eax
f0103004:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
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
f0103021:	03 1d 48 f2 22 f0    	add    0xf022f248,%ebx
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
f0103046:	e8 5f 2a 00 00       	call   f0105aaa <cpunum>
f010304b:	6b c0 74             	imul   $0x74,%eax,%eax
f010304e:	3b 98 28 00 23 f0    	cmp    -0xfdcffd8(%eax),%ebx
f0103054:	74 26                	je     f010307c <envid2env+0x8f>
f0103056:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0103059:	e8 4c 2a 00 00       	call   f0105aaa <cpunum>
f010305e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103061:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
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
f01030bf:	8b 35 48 f2 22 f0    	mov    0xf022f248,%esi
f01030c5:	8b 15 4c f2 22 f0    	mov    0xf022f24c,%edx
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
f01030e9:	89 35 4c f2 22 f0    	mov    %esi,0xf022f24c
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
f01030fd:	8b 1d 4c f2 22 f0    	mov    0xf022f24c,%ebx
f0103103:	85 db                	test   %ebx,%ebx
f0103105:	0f 84 6b 01 00 00    	je     f0103276 <env_alloc+0x17e>
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
f010311c:	0f 84 5b 01 00 00    	je     f010327d <env_alloc+0x185>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103122:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0103128:	c1 f8 03             	sar    $0x3,%eax
f010312b:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010312e:	89 c2                	mov    %eax,%edx
f0103130:	c1 ea 0c             	shr    $0xc,%edx
f0103133:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0103139:	72 12                	jb     f010314d <env_alloc+0x55>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010313b:	50                   	push   %eax
f010313c:	68 64 61 10 f0       	push   $0xf0106164
f0103141:	6a 58                	push   $0x58
f0103143:	68 2b 67 10 f0       	push   $0xf010672b
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
f010315d:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0103163:	50                   	push   %eax
f0103164:	e8 d3 23 00 00       	call   f010553c <memcpy>
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
f010317c:	68 88 61 10 f0       	push   $0xf0106188
f0103181:	68 c8 00 00 00       	push   $0xc8
f0103186:	68 5c 75 10 f0       	push   $0xf010755c
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
f01031b6:	2b 15 48 f2 22 f0    	sub    0xf022f248,%edx
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
f01031ed:	e8 95 22 00 00       	call   f0105487 <memset>
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
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.

	e->env_tf.tf_eflags |= FL_IF;
f0103211:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103218:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f010321f:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0103223:	8b 43 44             	mov    0x44(%ebx),%eax
f0103226:	a3 4c f2 22 f0       	mov    %eax,0xf022f24c
	*newenv_store = e;
f010322b:	8b 45 08             	mov    0x8(%ebp),%eax
f010322e:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103230:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0103233:	e8 72 28 00 00       	call   f0105aaa <cpunum>
f0103238:	6b c0 74             	imul   $0x74,%eax,%eax
f010323b:	83 c4 10             	add    $0x10,%esp
f010323e:	ba 00 00 00 00       	mov    $0x0,%edx
f0103243:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f010324a:	74 11                	je     f010325d <env_alloc+0x165>
f010324c:	e8 59 28 00 00       	call   f0105aaa <cpunum>
f0103251:	6b c0 74             	imul   $0x74,%eax,%eax
f0103254:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f010325a:	8b 50 48             	mov    0x48(%eax),%edx
f010325d:	83 ec 04             	sub    $0x4,%esp
f0103260:	53                   	push   %ebx
f0103261:	52                   	push   %edx
f0103262:	68 67 75 10 f0       	push   $0xf0107567
f0103267:	e8 3c 06 00 00       	call   f01038a8 <cprintf>
	return 0;
f010326c:	83 c4 10             	add    $0x10,%esp
f010326f:	b8 00 00 00 00       	mov    $0x0,%eax
f0103274:	eb 0c                	jmp    f0103282 <env_alloc+0x18a>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103276:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f010327b:	eb 05                	jmp    f0103282 <env_alloc+0x18a>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f010327d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103282:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103285:	5b                   	pop    %ebx
f0103286:	5e                   	pop    %esi
f0103287:	5d                   	pop    %ebp
f0103288:	c3                   	ret    

f0103289 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103289:	55                   	push   %ebp
f010328a:	89 e5                	mov    %esp,%ebp
f010328c:	57                   	push   %edi
f010328d:	56                   	push   %esi
f010328e:	53                   	push   %ebx
f010328f:	83 ec 34             	sub    $0x34,%esp
f0103292:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.

	struct Env *newenv_store;
	envid_t parent_id = 0;
	int err = env_alloc(&newenv_store, 0);
f0103295:	6a 00                	push   $0x0
f0103297:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010329a:	50                   	push   %eax
f010329b:	e8 58 fe ff ff       	call   f01030f8 <env_alloc>
	if (err < 0) 
f01032a0:	83 c4 10             	add    $0x10,%esp
f01032a3:	85 c0                	test   %eax,%eax
f01032a5:	79 15                	jns    f01032bc <env_create+0x33>
		panic("env_create: env_alloc failed: %e", err);
f01032a7:	50                   	push   %eax
f01032a8:	68 e4 74 10 f0       	push   $0xf01074e4
f01032ad:	68 b9 01 00 00       	push   $0x1b9
f01032b2:	68 5c 75 10 f0       	push   $0xf010755c
f01032b7:	e8 84 cd ff ff       	call   f0100040 <_panic>
	load_icode(newenv_store, binary);
f01032bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01032bf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// LAB 3: Your code here.

	// read and check ELF property, inspired by boot/main.c
	struct Elf* elf = (struct Elf*) binary;

	if (elf->e_magic != ELF_MAGIC)
f01032c2:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f01032c8:	74 17                	je     f01032e1 <env_create+0x58>
		panic("load_icode: not a valid ELF format file");
f01032ca:	83 ec 04             	sub    $0x4,%esp
f01032cd:	68 08 75 10 f0       	push   $0xf0107508
f01032d2:	68 75 01 00 00       	push   $0x175
f01032d7:	68 5c 75 10 f0       	push   $0xf010755c
f01032dc:	e8 5f cd ff ff       	call   f0100040 <_panic>

	struct Proghdr *ph, *eph;
	
	ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f01032e1:	89 fb                	mov    %edi,%ebx
f01032e3:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + elf->e_phnum;
f01032e6:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f01032ea:	c1 e6 05             	shl    $0x5,%esi
f01032ed:	01 de                	add    %ebx,%esi

	// we are setting user virtual address, but now we are in kernel mode
	// load env pgdir to cr3
	lcr3(PADDR(e->env_pgdir));	
f01032ef:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01032f2:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01032f5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01032fa:	77 15                	ja     f0103311 <env_create+0x88>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032fc:	50                   	push   %eax
f01032fd:	68 88 61 10 f0       	push   $0xf0106188
f0103302:	68 7e 01 00 00       	push   $0x17e
f0103307:	68 5c 75 10 f0       	push   $0xf010755c
f010330c:	e8 2f cd ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103311:	05 00 00 00 10       	add    $0x10000000,%eax
f0103316:	0f 22 d8             	mov    %eax,%cr3
f0103319:	eb 59                	jmp    f0103374 <env_create+0xeb>

	// for every segment
	for (; ph < eph; ph++) {

		// only load this type of segment
		if (ph->p_type == ELF_PROG_LOAD) {
f010331b:	83 3b 01             	cmpl   $0x1,(%ebx)
f010331e:	75 51                	jne    f0103371 <env_create+0xe8>

			if (ph->p_filesz > ph->p_memsz)
f0103320:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103323:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f0103326:	76 17                	jbe    f010333f <env_create+0xb6>
				panic("load_icode: not a valid ELF format file (2)");
f0103328:	83 ec 04             	sub    $0x4,%esp
f010332b:	68 30 75 10 f0       	push   $0xf0107530
f0103330:	68 87 01 00 00       	push   $0x187
f0103335:	68 5c 75 10 f0       	push   $0xf010755c
f010333a:	e8 01 cd ff ff       	call   f0100040 <_panic>

			// allocate and map each segment
			// this function needs e->env_pgdir
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f010333f:	8b 53 08             	mov    0x8(%ebx),%edx
f0103342:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103345:	e8 1f fc ff ff       	call   f0102f69 <region_alloc>

			// all clear to 0
			memset((void *)ph->p_va, 0, ph->p_memsz);
f010334a:	83 ec 04             	sub    $0x4,%esp
f010334d:	ff 73 14             	pushl  0x14(%ebx)
f0103350:	6a 00                	push   $0x0
f0103352:	ff 73 08             	pushl  0x8(%ebx)
f0103355:	e8 2d 21 00 00       	call   f0105487 <memset>

			// copy [binary + ph->p_offset, binary + ph->p_offset + ph->p_filesz) to ph->p_va
			// binary is of type uint8_t *, remember not use elf cuz its type is struct Elf*
			// making elf + ph->p_offset pointing to nowhere
			memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f010335a:	83 c4 0c             	add    $0xc,%esp
f010335d:	ff 73 10             	pushl  0x10(%ebx)
f0103360:	89 f8                	mov    %edi,%eax
f0103362:	03 43 04             	add    0x4(%ebx),%eax
f0103365:	50                   	push   %eax
f0103366:	ff 73 08             	pushl  0x8(%ebx)
f0103369:	e8 ce 21 00 00       	call   f010553c <memcpy>
f010336e:	83 c4 10             	add    $0x10,%esp
	// we are setting user virtual address, but now we are in kernel mode
	// load env pgdir to cr3
	lcr3(PADDR(e->env_pgdir));	

	// for every segment
	for (; ph < eph; ph++) {
f0103371:	83 c3 20             	add    $0x20,%ebx
f0103374:	39 de                	cmp    %ebx,%esi
f0103376:	77 a3                	ja     f010331b <env_create+0x92>
		}

	}

	// load program entry point to eip
	e->env_tf.tf_eip = elf->e_entry;
f0103378:	8b 47 18             	mov    0x18(%edi),%eax
f010337b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010337e:	89 47 30             	mov    %eax,0x30(%edi)
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.

	region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f0103381:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103386:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f010338b:	89 f8                	mov    %edi,%eax
f010338d:	e8 d7 fb ff ff       	call   f0102f69 <region_alloc>

	// after loading things from elf, restore cr3 in kernel
	lcr3(PADDR(kern_pgdir));
f0103392:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103397:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010339c:	77 15                	ja     f01033b3 <env_create+0x12a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010339e:	50                   	push   %eax
f010339f:	68 88 61 10 f0       	push   $0xf0106188
f01033a4:	68 a5 01 00 00       	push   $0x1a5
f01033a9:	68 5c 75 10 f0       	push   $0xf010755c
f01033ae:	e8 8d cc ff ff       	call   f0100040 <_panic>
f01033b3:	05 00 00 00 10       	add    $0x10000000,%eax
f01033b8:	0f 22 d8             	mov    %eax,%cr3
	envid_t parent_id = 0;
	int err = env_alloc(&newenv_store, 0);
	if (err < 0) 
		panic("env_create: env_alloc failed: %e", err);
	load_icode(newenv_store, binary);
	newenv_store->env_type = type;
f01033bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01033be:	8b 55 0c             	mov    0xc(%ebp),%edx
f01033c1:	89 50 50             	mov    %edx,0x50(%eax)

}
f01033c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01033c7:	5b                   	pop    %ebx
f01033c8:	5e                   	pop    %esi
f01033c9:	5f                   	pop    %edi
f01033ca:	5d                   	pop    %ebp
f01033cb:	c3                   	ret    

f01033cc <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01033cc:	55                   	push   %ebp
f01033cd:	89 e5                	mov    %esp,%ebp
f01033cf:	57                   	push   %edi
f01033d0:	56                   	push   %esi
f01033d1:	53                   	push   %ebx
f01033d2:	83 ec 1c             	sub    $0x1c,%esp
f01033d5:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01033d8:	e8 cd 26 00 00       	call   f0105aaa <cpunum>
f01033dd:	6b c0 74             	imul   $0x74,%eax,%eax
f01033e0:	39 b8 28 00 23 f0    	cmp    %edi,-0xfdcffd8(%eax)
f01033e6:	75 29                	jne    f0103411 <env_free+0x45>
		lcr3(PADDR(kern_pgdir));
f01033e8:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01033ed:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01033f2:	77 15                	ja     f0103409 <env_free+0x3d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033f4:	50                   	push   %eax
f01033f5:	68 88 61 10 f0       	push   $0xf0106188
f01033fa:	68 cd 01 00 00       	push   $0x1cd
f01033ff:	68 5c 75 10 f0       	push   $0xf010755c
f0103404:	e8 37 cc ff ff       	call   f0100040 <_panic>
f0103409:	05 00 00 00 10       	add    $0x10000000,%eax
f010340e:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103411:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103414:	e8 91 26 00 00       	call   f0105aaa <cpunum>
f0103419:	6b c0 74             	imul   $0x74,%eax,%eax
f010341c:	ba 00 00 00 00       	mov    $0x0,%edx
f0103421:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f0103428:	74 11                	je     f010343b <env_free+0x6f>
f010342a:	e8 7b 26 00 00       	call   f0105aaa <cpunum>
f010342f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103432:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0103438:	8b 50 48             	mov    0x48(%eax),%edx
f010343b:	83 ec 04             	sub    $0x4,%esp
f010343e:	53                   	push   %ebx
f010343f:	52                   	push   %edx
f0103440:	68 7c 75 10 f0       	push   $0xf010757c
f0103445:	e8 5e 04 00 00       	call   f01038a8 <cprintf>
f010344a:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010344d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103454:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103457:	89 d0                	mov    %edx,%eax
f0103459:	c1 e0 02             	shl    $0x2,%eax
f010345c:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f010345f:	8b 47 60             	mov    0x60(%edi),%eax
f0103462:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0103465:	f7 c6 01 00 00 00    	test   $0x1,%esi
f010346b:	0f 84 a8 00 00 00    	je     f0103519 <env_free+0x14d>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103471:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103477:	89 f0                	mov    %esi,%eax
f0103479:	c1 e8 0c             	shr    $0xc,%eax
f010347c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010347f:	39 05 88 fe 22 f0    	cmp    %eax,0xf022fe88
f0103485:	77 15                	ja     f010349c <env_free+0xd0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103487:	56                   	push   %esi
f0103488:	68 64 61 10 f0       	push   $0xf0106164
f010348d:	68 dc 01 00 00       	push   $0x1dc
f0103492:	68 5c 75 10 f0       	push   $0xf010755c
f0103497:	e8 a4 cb ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010349c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010349f:	c1 e0 16             	shl    $0x16,%eax
f01034a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01034a5:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f01034aa:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f01034b1:	01 
f01034b2:	74 17                	je     f01034cb <env_free+0xff>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01034b4:	83 ec 08             	sub    $0x8,%esp
f01034b7:	89 d8                	mov    %ebx,%eax
f01034b9:	c1 e0 0c             	shl    $0xc,%eax
f01034bc:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01034bf:	50                   	push   %eax
f01034c0:	ff 77 60             	pushl  0x60(%edi)
f01034c3:	e8 7c de ff ff       	call   f0101344 <page_remove>
f01034c8:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01034cb:	83 c3 01             	add    $0x1,%ebx
f01034ce:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01034d4:	75 d4                	jne    f01034aa <env_free+0xde>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01034d6:	8b 47 60             	mov    0x60(%edi),%eax
f01034d9:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01034dc:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01034e3:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01034e6:	3b 05 88 fe 22 f0    	cmp    0xf022fe88,%eax
f01034ec:	72 14                	jb     f0103502 <env_free+0x136>
		panic("pa2page called with invalid pa");
f01034ee:	83 ec 04             	sub    $0x4,%esp
f01034f1:	68 38 6c 10 f0       	push   $0xf0106c38
f01034f6:	6a 51                	push   $0x51
f01034f8:	68 2b 67 10 f0       	push   $0xf010672b
f01034fd:	e8 3e cb ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f0103502:	83 ec 0c             	sub    $0xc,%esp
f0103505:	a1 90 fe 22 f0       	mov    0xf022fe90,%eax
f010350a:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010350d:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103510:	50                   	push   %eax
f0103511:	e8 14 dc ff ff       	call   f010112a <page_decref>
f0103516:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103519:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f010351d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103520:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0103525:	0f 85 29 ff ff ff    	jne    f0103454 <env_free+0x88>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f010352b:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010352e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103533:	77 15                	ja     f010354a <env_free+0x17e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103535:	50                   	push   %eax
f0103536:	68 88 61 10 f0       	push   $0xf0106188
f010353b:	68 ea 01 00 00       	push   $0x1ea
f0103540:	68 5c 75 10 f0       	push   $0xf010755c
f0103545:	e8 f6 ca ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f010354a:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103551:	05 00 00 00 10       	add    $0x10000000,%eax
f0103556:	c1 e8 0c             	shr    $0xc,%eax
f0103559:	3b 05 88 fe 22 f0    	cmp    0xf022fe88,%eax
f010355f:	72 14                	jb     f0103575 <env_free+0x1a9>
		panic("pa2page called with invalid pa");
f0103561:	83 ec 04             	sub    $0x4,%esp
f0103564:	68 38 6c 10 f0       	push   $0xf0106c38
f0103569:	6a 51                	push   $0x51
f010356b:	68 2b 67 10 f0       	push   $0xf010672b
f0103570:	e8 cb ca ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f0103575:	83 ec 0c             	sub    $0xc,%esp
f0103578:	8b 15 90 fe 22 f0    	mov    0xf022fe90,%edx
f010357e:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103581:	50                   	push   %eax
f0103582:	e8 a3 db ff ff       	call   f010112a <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103587:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f010358e:	a1 4c f2 22 f0       	mov    0xf022f24c,%eax
f0103593:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103596:	89 3d 4c f2 22 f0    	mov    %edi,0xf022f24c
}
f010359c:	83 c4 10             	add    $0x10,%esp
f010359f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01035a2:	5b                   	pop    %ebx
f01035a3:	5e                   	pop    %esi
f01035a4:	5f                   	pop    %edi
f01035a5:	5d                   	pop    %ebp
f01035a6:	c3                   	ret    

f01035a7 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f01035a7:	55                   	push   %ebp
f01035a8:	89 e5                	mov    %esp,%ebp
f01035aa:	53                   	push   %ebx
f01035ab:	83 ec 04             	sub    $0x4,%esp
f01035ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01035b1:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f01035b5:	75 19                	jne    f01035d0 <env_destroy+0x29>
f01035b7:	e8 ee 24 00 00       	call   f0105aaa <cpunum>
f01035bc:	6b c0 74             	imul   $0x74,%eax,%eax
f01035bf:	3b 98 28 00 23 f0    	cmp    -0xfdcffd8(%eax),%ebx
f01035c5:	74 09                	je     f01035d0 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f01035c7:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f01035ce:	eb 33                	jmp    f0103603 <env_destroy+0x5c>
	}

	env_free(e);
f01035d0:	83 ec 0c             	sub    $0xc,%esp
f01035d3:	53                   	push   %ebx
f01035d4:	e8 f3 fd ff ff       	call   f01033cc <env_free>

	if (curenv == e) {
f01035d9:	e8 cc 24 00 00       	call   f0105aaa <cpunum>
f01035de:	6b c0 74             	imul   $0x74,%eax,%eax
f01035e1:	83 c4 10             	add    $0x10,%esp
f01035e4:	3b 98 28 00 23 f0    	cmp    -0xfdcffd8(%eax),%ebx
f01035ea:	75 17                	jne    f0103603 <env_destroy+0x5c>
		curenv = NULL;
f01035ec:	e8 b9 24 00 00       	call   f0105aaa <cpunum>
f01035f1:	6b c0 74             	imul   $0x74,%eax,%eax
f01035f4:	c7 80 28 00 23 f0 00 	movl   $0x0,-0xfdcffd8(%eax)
f01035fb:	00 00 00 
		sched_yield();
f01035fe:	e8 ab 0e 00 00       	call   f01044ae <sched_yield>
	}
}
f0103603:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103606:	c9                   	leave  
f0103607:	c3                   	ret    

f0103608 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103608:	55                   	push   %ebp
f0103609:	89 e5                	mov    %esp,%ebp
f010360b:	53                   	push   %ebx
f010360c:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f010360f:	e8 96 24 00 00       	call   f0105aaa <cpunum>
f0103614:	6b c0 74             	imul   $0x74,%eax,%eax
f0103617:	8b 98 28 00 23 f0    	mov    -0xfdcffd8(%eax),%ebx
f010361d:	e8 88 24 00 00       	call   f0105aaa <cpunum>
f0103622:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f0103625:	8b 65 08             	mov    0x8(%ebp),%esp
f0103628:	61                   	popa   
f0103629:	07                   	pop    %es
f010362a:	1f                   	pop    %ds
f010362b:	83 c4 08             	add    $0x8,%esp
f010362e:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f010362f:	83 ec 04             	sub    $0x4,%esp
f0103632:	68 92 75 10 f0       	push   $0xf0107592
f0103637:	68 21 02 00 00       	push   $0x221
f010363c:	68 5c 75 10 f0       	push   $0xf010755c
f0103641:	e8 fa c9 ff ff       	call   f0100040 <_panic>

f0103646 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103646:	55                   	push   %ebp
f0103647:	89 e5                	mov    %esp,%ebp
f0103649:	53                   	push   %ebx
f010364a:	83 ec 04             	sub    $0x4,%esp
f010364d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

	// context switch
	if (curenv != e) {
f0103650:	e8 55 24 00 00       	call   f0105aaa <cpunum>
f0103655:	6b c0 74             	imul   $0x74,%eax,%eax
f0103658:	39 98 28 00 23 f0    	cmp    %ebx,-0xfdcffd8(%eax)
f010365e:	74 3a                	je     f010369a <env_run+0x54>

		if (curenv != NULL && curenv->env_status == ENV_RUNNING)
f0103660:	e8 45 24 00 00       	call   f0105aaa <cpunum>
f0103665:	6b c0 74             	imul   $0x74,%eax,%eax
f0103668:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f010366f:	74 29                	je     f010369a <env_run+0x54>
f0103671:	e8 34 24 00 00       	call   f0105aaa <cpunum>
f0103676:	6b c0 74             	imul   $0x74,%eax,%eax
f0103679:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f010367f:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103683:	75 15                	jne    f010369a <env_run+0x54>
			curenv->env_status = ENV_RUNNABLE;
f0103685:	e8 20 24 00 00       	call   f0105aaa <cpunum>
f010368a:	6b c0 74             	imul   $0x74,%eax,%eax
f010368d:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0103693:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
			
	}
	
	curenv = e;
f010369a:	e8 0b 24 00 00       	call   f0105aaa <cpunum>
f010369f:	6b c0 74             	imul   $0x74,%eax,%eax
f01036a2:	89 98 28 00 23 f0    	mov    %ebx,-0xfdcffd8(%eax)
	curenv->env_status = ENV_RUNNING;
f01036a8:	e8 fd 23 00 00       	call   f0105aaa <cpunum>
f01036ad:	6b c0 74             	imul   $0x74,%eax,%eax
f01036b0:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f01036b6:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f01036bd:	e8 e8 23 00 00       	call   f0105aaa <cpunum>
f01036c2:	6b c0 74             	imul   $0x74,%eax,%eax
f01036c5:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f01036cb:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3(PADDR(curenv->env_pgdir));
f01036cf:	e8 d6 23 00 00       	call   f0105aaa <cpunum>
f01036d4:	6b c0 74             	imul   $0x74,%eax,%eax
f01036d7:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f01036dd:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01036e0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01036e5:	77 15                	ja     f01036fc <env_run+0xb6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01036e7:	50                   	push   %eax
f01036e8:	68 88 61 10 f0       	push   $0xf0106188
f01036ed:	68 4b 02 00 00       	push   $0x24b
f01036f2:	68 5c 75 10 f0       	push   $0xf010755c
f01036f7:	e8 44 c9 ff ff       	call   f0100040 <_panic>
f01036fc:	05 00 00 00 10       	add    $0x10000000,%eax
f0103701:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103704:	83 ec 0c             	sub    $0xc,%esp
f0103707:	68 c0 03 12 f0       	push   $0xf01203c0
f010370c:	e8 a4 26 00 00       	call   f0105db5 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103711:	f3 90                	pause  

	unlock_kernel();

	// iret to execute entry point stored in tf_eip
	// cprintf("[?] try to execute at entry point: %x\n", curenv->env_tf.tf_eip);
	env_pop_tf(&curenv->env_tf);
f0103713:	e8 92 23 00 00       	call   f0105aaa <cpunum>
f0103718:	83 c4 04             	add    $0x4,%esp
f010371b:	6b c0 74             	imul   $0x74,%eax,%eax
f010371e:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0103724:	e8 df fe ff ff       	call   f0103608 <env_pop_tf>

f0103729 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103729:	55                   	push   %ebp
f010372a:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010372c:	ba 70 00 00 00       	mov    $0x70,%edx
f0103731:	8b 45 08             	mov    0x8(%ebp),%eax
f0103734:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103735:	ba 71 00 00 00       	mov    $0x71,%edx
f010373a:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f010373b:	0f b6 c0             	movzbl %al,%eax
}
f010373e:	5d                   	pop    %ebp
f010373f:	c3                   	ret    

f0103740 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103740:	55                   	push   %ebp
f0103741:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103743:	ba 70 00 00 00       	mov    $0x70,%edx
f0103748:	8b 45 08             	mov    0x8(%ebp),%eax
f010374b:	ee                   	out    %al,(%dx)
f010374c:	ba 71 00 00 00       	mov    $0x71,%edx
f0103751:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103754:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103755:	5d                   	pop    %ebp
f0103756:	c3                   	ret    

f0103757 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103757:	55                   	push   %ebp
f0103758:	89 e5                	mov    %esp,%ebp
f010375a:	56                   	push   %esi
f010375b:	53                   	push   %ebx
f010375c:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f010375f:	66 a3 a8 03 12 f0    	mov    %ax,0xf01203a8
	if (!didinit)
f0103765:	80 3d 50 f2 22 f0 00 	cmpb   $0x0,0xf022f250
f010376c:	74 5a                	je     f01037c8 <irq_setmask_8259A+0x71>
f010376e:	89 c6                	mov    %eax,%esi
f0103770:	ba 21 00 00 00       	mov    $0x21,%edx
f0103775:	ee                   	out    %al,(%dx)
f0103776:	66 c1 e8 08          	shr    $0x8,%ax
f010377a:	ba a1 00 00 00       	mov    $0xa1,%edx
f010377f:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f0103780:	83 ec 0c             	sub    $0xc,%esp
f0103783:	68 9e 75 10 f0       	push   $0xf010759e
f0103788:	e8 1b 01 00 00       	call   f01038a8 <cprintf>
f010378d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103790:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103795:	0f b7 f6             	movzwl %si,%esi
f0103798:	f7 d6                	not    %esi
f010379a:	0f a3 de             	bt     %ebx,%esi
f010379d:	73 11                	jae    f01037b0 <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f010379f:	83 ec 08             	sub    $0x8,%esp
f01037a2:	53                   	push   %ebx
f01037a3:	68 53 7a 10 f0       	push   $0xf0107a53
f01037a8:	e8 fb 00 00 00       	call   f01038a8 <cprintf>
f01037ad:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f01037b0:	83 c3 01             	add    $0x1,%ebx
f01037b3:	83 fb 10             	cmp    $0x10,%ebx
f01037b6:	75 e2                	jne    f010379a <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f01037b8:	83 ec 0c             	sub    $0xc,%esp
f01037bb:	68 20 6a 10 f0       	push   $0xf0106a20
f01037c0:	e8 e3 00 00 00       	call   f01038a8 <cprintf>
f01037c5:	83 c4 10             	add    $0x10,%esp
}
f01037c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01037cb:	5b                   	pop    %ebx
f01037cc:	5e                   	pop    %esi
f01037cd:	5d                   	pop    %ebp
f01037ce:	c3                   	ret    

f01037cf <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f01037cf:	c6 05 50 f2 22 f0 01 	movb   $0x1,0xf022f250
f01037d6:	ba 21 00 00 00       	mov    $0x21,%edx
f01037db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01037e0:	ee                   	out    %al,(%dx)
f01037e1:	ba a1 00 00 00       	mov    $0xa1,%edx
f01037e6:	ee                   	out    %al,(%dx)
f01037e7:	ba 20 00 00 00       	mov    $0x20,%edx
f01037ec:	b8 11 00 00 00       	mov    $0x11,%eax
f01037f1:	ee                   	out    %al,(%dx)
f01037f2:	ba 21 00 00 00       	mov    $0x21,%edx
f01037f7:	b8 20 00 00 00       	mov    $0x20,%eax
f01037fc:	ee                   	out    %al,(%dx)
f01037fd:	b8 04 00 00 00       	mov    $0x4,%eax
f0103802:	ee                   	out    %al,(%dx)
f0103803:	b8 03 00 00 00       	mov    $0x3,%eax
f0103808:	ee                   	out    %al,(%dx)
f0103809:	ba a0 00 00 00       	mov    $0xa0,%edx
f010380e:	b8 11 00 00 00       	mov    $0x11,%eax
f0103813:	ee                   	out    %al,(%dx)
f0103814:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103819:	b8 28 00 00 00       	mov    $0x28,%eax
f010381e:	ee                   	out    %al,(%dx)
f010381f:	b8 02 00 00 00       	mov    $0x2,%eax
f0103824:	ee                   	out    %al,(%dx)
f0103825:	b8 01 00 00 00       	mov    $0x1,%eax
f010382a:	ee                   	out    %al,(%dx)
f010382b:	ba 20 00 00 00       	mov    $0x20,%edx
f0103830:	b8 68 00 00 00       	mov    $0x68,%eax
f0103835:	ee                   	out    %al,(%dx)
f0103836:	b8 0a 00 00 00       	mov    $0xa,%eax
f010383b:	ee                   	out    %al,(%dx)
f010383c:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103841:	b8 68 00 00 00       	mov    $0x68,%eax
f0103846:	ee                   	out    %al,(%dx)
f0103847:	b8 0a 00 00 00       	mov    $0xa,%eax
f010384c:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f010384d:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f0103854:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103858:	74 13                	je     f010386d <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f010385a:	55                   	push   %ebp
f010385b:	89 e5                	mov    %esp,%ebp
f010385d:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0103860:	0f b7 c0             	movzwl %ax,%eax
f0103863:	50                   	push   %eax
f0103864:	e8 ee fe ff ff       	call   f0103757 <irq_setmask_8259A>
f0103869:	83 c4 10             	add    $0x10,%esp
}
f010386c:	c9                   	leave  
f010386d:	f3 c3                	repz ret 

f010386f <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010386f:	55                   	push   %ebp
f0103870:	89 e5                	mov    %esp,%ebp
f0103872:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103875:	ff 75 08             	pushl  0x8(%ebp)
f0103878:	e8 d0 ce ff ff       	call   f010074d <cputchar>
	*cnt++;
}
f010387d:	83 c4 10             	add    $0x10,%esp
f0103880:	c9                   	leave  
f0103881:	c3                   	ret    

f0103882 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103882:	55                   	push   %ebp
f0103883:	89 e5                	mov    %esp,%ebp
f0103885:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103888:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f010388f:	ff 75 0c             	pushl  0xc(%ebp)
f0103892:	ff 75 08             	pushl  0x8(%ebp)
f0103895:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103898:	50                   	push   %eax
f0103899:	68 6f 38 10 f0       	push   $0xf010386f
f010389e:	e8 78 15 00 00       	call   f0104e1b <vprintfmt>
	return cnt;
}
f01038a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01038a6:	c9                   	leave  
f01038a7:	c3                   	ret    

f01038a8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01038a8:	55                   	push   %ebp
f01038a9:	89 e5                	mov    %esp,%ebp
f01038ab:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01038ae:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01038b1:	50                   	push   %eax
f01038b2:	ff 75 08             	pushl  0x8(%ebp)
f01038b5:	e8 c8 ff ff ff       	call   f0103882 <vcprintf>
	va_end(ap);

	return cnt;
}
f01038ba:	c9                   	leave  
f01038bb:	c3                   	ret    

f01038bc <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f01038bc:	55                   	push   %ebp
f01038bd:	89 e5                	mov    %esp,%ebp
f01038bf:	57                   	push   %edi
f01038c0:	56                   	push   %esi
f01038c1:	53                   	push   %ebx
f01038c2:	83 ec 0c             	sub    $0xc,%esp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = (uintptr_t) percpu_kstacks[cpunum()];
f01038c5:	e8 e0 21 00 00       	call   f0105aaa <cpunum>
f01038ca:	89 c3                	mov    %eax,%ebx
f01038cc:	e8 d9 21 00 00       	call   f0105aaa <cpunum>
f01038d1:	6b db 74             	imul   $0x74,%ebx,%ebx
f01038d4:	c1 e0 0f             	shl    $0xf,%eax
f01038d7:	05 00 10 23 f0       	add    $0xf0231000,%eax
f01038dc:	89 83 30 00 23 f0    	mov    %eax,-0xfdcffd0(%ebx)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f01038e2:	e8 c3 21 00 00       	call   f0105aaa <cpunum>
f01038e7:	6b c0 74             	imul   $0x74,%eax,%eax
f01038ea:	66 c7 80 34 00 23 f0 	movw   $0x10,-0xfdcffcc(%eax)
f01038f1:	10 00 
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f01038f3:	e8 b2 21 00 00       	call   f0105aaa <cpunum>
f01038f8:	6b c0 74             	imul   $0x74,%eax,%eax
f01038fb:	66 c7 80 92 00 23 f0 	movw   $0x68,-0xfdcff6e(%eax)
f0103902:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + cpunum()] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
f0103904:	e8 a1 21 00 00       	call   f0105aaa <cpunum>
f0103909:	8d 58 05             	lea    0x5(%eax),%ebx
f010390c:	e8 99 21 00 00       	call   f0105aaa <cpunum>
f0103911:	89 c7                	mov    %eax,%edi
f0103913:	e8 92 21 00 00       	call   f0105aaa <cpunum>
f0103918:	89 c6                	mov    %eax,%esi
f010391a:	e8 8b 21 00 00       	call   f0105aaa <cpunum>
f010391f:	66 c7 04 dd 40 03 12 	movw   $0x67,-0xfedfcc0(,%ebx,8)
f0103926:	f0 67 00 
f0103929:	6b ff 74             	imul   $0x74,%edi,%edi
f010392c:	81 c7 2c 00 23 f0    	add    $0xf023002c,%edi
f0103932:	66 89 3c dd 42 03 12 	mov    %di,-0xfedfcbe(,%ebx,8)
f0103939:	f0 
f010393a:	6b d6 74             	imul   $0x74,%esi,%edx
f010393d:	81 c2 2c 00 23 f0    	add    $0xf023002c,%edx
f0103943:	c1 ea 10             	shr    $0x10,%edx
f0103946:	88 14 dd 44 03 12 f0 	mov    %dl,-0xfedfcbc(,%ebx,8)
f010394d:	c6 04 dd 45 03 12 f0 	movb   $0x99,-0xfedfcbb(,%ebx,8)
f0103954:	99 
f0103955:	c6 04 dd 46 03 12 f0 	movb   $0x40,-0xfedfcba(,%ebx,8)
f010395c:	40 
f010395d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103960:	05 2c 00 23 f0       	add    $0xf023002c,%eax
f0103965:	c1 e8 18             	shr    $0x18,%eax
f0103968:	88 04 dd 47 03 12 f0 	mov    %al,-0xfedfcb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + cpunum()].sd_s = 0;
f010396f:	e8 36 21 00 00       	call   f0105aaa <cpunum>
f0103974:	80 24 c5 6d 03 12 f0 	andb   $0xef,-0xfedfc93(,%eax,8)
f010397b:	ef 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + (cpunum() << 3));
f010397c:	e8 29 21 00 00       	call   f0105aaa <cpunum>
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f0103981:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
f0103988:	0f 00 d8             	ltr    %ax
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f010398b:	b8 ac 03 12 f0       	mov    $0xf01203ac,%eax
f0103990:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f0103993:	83 c4 0c             	add    $0xc,%esp
f0103996:	5b                   	pop    %ebx
f0103997:	5e                   	pop    %esi
f0103998:	5f                   	pop    %edi
f0103999:	5d                   	pop    %ebp
f010399a:	c3                   	ret    

f010399b <trap_init>:
}


void
trap_init(void)
{
f010399b:	55                   	push   %ebp
f010399c:	89 e5                	mov    %esp,%ebp
f010399e:	83 ec 08             	sub    $0x8,%esp
	void _IRQ_SPURIOUS_handler();
	void _IRQ_IDE_handler();
	void _IRQ_ERROR_handler();

	// SETGATE(gate, istrap, sel, off, dpl);
	SETGATE(idt[T_DIVIDE], 0, GD_KT, _T_DIVIDE_handler, 0);
f01039a1:	b8 3c 43 10 f0       	mov    $0xf010433c,%eax
f01039a6:	66 a3 60 f2 22 f0    	mov    %ax,0xf022f260
f01039ac:	66 c7 05 62 f2 22 f0 	movw   $0x8,0xf022f262
f01039b3:	08 00 
f01039b5:	c6 05 64 f2 22 f0 00 	movb   $0x0,0xf022f264
f01039bc:	c6 05 65 f2 22 f0 8e 	movb   $0x8e,0xf022f265
f01039c3:	c1 e8 10             	shr    $0x10,%eax
f01039c6:	66 a3 66 f2 22 f0    	mov    %ax,0xf022f266
	SETGATE(idt[T_DEBUG], 0, GD_KT, _T_DEBUG_handler, 0);
f01039cc:	b8 46 43 10 f0       	mov    $0xf0104346,%eax
f01039d1:	66 a3 68 f2 22 f0    	mov    %ax,0xf022f268
f01039d7:	66 c7 05 6a f2 22 f0 	movw   $0x8,0xf022f26a
f01039de:	08 00 
f01039e0:	c6 05 6c f2 22 f0 00 	movb   $0x0,0xf022f26c
f01039e7:	c6 05 6d f2 22 f0 8e 	movb   $0x8e,0xf022f26d
f01039ee:	c1 e8 10             	shr    $0x10,%eax
f01039f1:	66 a3 6e f2 22 f0    	mov    %ax,0xf022f26e
	SETGATE(idt[T_NMI], 0, GD_KT, _T_NMI_handler, 0);
f01039f7:	b8 4c 43 10 f0       	mov    $0xf010434c,%eax
f01039fc:	66 a3 70 f2 22 f0    	mov    %ax,0xf022f270
f0103a02:	66 c7 05 72 f2 22 f0 	movw   $0x8,0xf022f272
f0103a09:	08 00 
f0103a0b:	c6 05 74 f2 22 f0 00 	movb   $0x0,0xf022f274
f0103a12:	c6 05 75 f2 22 f0 8e 	movb   $0x8e,0xf022f275
f0103a19:	c1 e8 10             	shr    $0x10,%eax
f0103a1c:	66 a3 76 f2 22 f0    	mov    %ax,0xf022f276
	SETGATE(idt[T_BRKPT], 0, GD_KT, _T_BRKPT_handler, 3);
f0103a22:	b8 52 43 10 f0       	mov    $0xf0104352,%eax
f0103a27:	66 a3 78 f2 22 f0    	mov    %ax,0xf022f278
f0103a2d:	66 c7 05 7a f2 22 f0 	movw   $0x8,0xf022f27a
f0103a34:	08 00 
f0103a36:	c6 05 7c f2 22 f0 00 	movb   $0x0,0xf022f27c
f0103a3d:	c6 05 7d f2 22 f0 ee 	movb   $0xee,0xf022f27d
f0103a44:	c1 e8 10             	shr    $0x10,%eax
f0103a47:	66 a3 7e f2 22 f0    	mov    %ax,0xf022f27e
	SETGATE(idt[T_OFLOW], 0, GD_KT, _T_OFLOW_handler, 0);
f0103a4d:	b8 58 43 10 f0       	mov    $0xf0104358,%eax
f0103a52:	66 a3 80 f2 22 f0    	mov    %ax,0xf022f280
f0103a58:	66 c7 05 82 f2 22 f0 	movw   $0x8,0xf022f282
f0103a5f:	08 00 
f0103a61:	c6 05 84 f2 22 f0 00 	movb   $0x0,0xf022f284
f0103a68:	c6 05 85 f2 22 f0 8e 	movb   $0x8e,0xf022f285
f0103a6f:	c1 e8 10             	shr    $0x10,%eax
f0103a72:	66 a3 86 f2 22 f0    	mov    %ax,0xf022f286
	SETGATE(idt[T_BOUND], 0, GD_KT, _T_BOUND_handler, 0);
f0103a78:	b8 5e 43 10 f0       	mov    $0xf010435e,%eax
f0103a7d:	66 a3 88 f2 22 f0    	mov    %ax,0xf022f288
f0103a83:	66 c7 05 8a f2 22 f0 	movw   $0x8,0xf022f28a
f0103a8a:	08 00 
f0103a8c:	c6 05 8c f2 22 f0 00 	movb   $0x0,0xf022f28c
f0103a93:	c6 05 8d f2 22 f0 8e 	movb   $0x8e,0xf022f28d
f0103a9a:	c1 e8 10             	shr    $0x10,%eax
f0103a9d:	66 a3 8e f2 22 f0    	mov    %ax,0xf022f28e
	SETGATE(idt[T_ILLOP], 0, GD_KT, _T_ILLOP_handler, 0);
f0103aa3:	b8 64 43 10 f0       	mov    $0xf0104364,%eax
f0103aa8:	66 a3 90 f2 22 f0    	mov    %ax,0xf022f290
f0103aae:	66 c7 05 92 f2 22 f0 	movw   $0x8,0xf022f292
f0103ab5:	08 00 
f0103ab7:	c6 05 94 f2 22 f0 00 	movb   $0x0,0xf022f294
f0103abe:	c6 05 95 f2 22 f0 8e 	movb   $0x8e,0xf022f295
f0103ac5:	c1 e8 10             	shr    $0x10,%eax
f0103ac8:	66 a3 96 f2 22 f0    	mov    %ax,0xf022f296
	SETGATE(idt[T_DEVICE], 0, GD_KT, _T_DEVICE_handler, 0);
f0103ace:	b8 6a 43 10 f0       	mov    $0xf010436a,%eax
f0103ad3:	66 a3 98 f2 22 f0    	mov    %ax,0xf022f298
f0103ad9:	66 c7 05 9a f2 22 f0 	movw   $0x8,0xf022f29a
f0103ae0:	08 00 
f0103ae2:	c6 05 9c f2 22 f0 00 	movb   $0x0,0xf022f29c
f0103ae9:	c6 05 9d f2 22 f0 8e 	movb   $0x8e,0xf022f29d
f0103af0:	c1 e8 10             	shr    $0x10,%eax
f0103af3:	66 a3 9e f2 22 f0    	mov    %ax,0xf022f29e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, _T_DBLFLT_handler, 0);
f0103af9:	b8 70 43 10 f0       	mov    $0xf0104370,%eax
f0103afe:	66 a3 a0 f2 22 f0    	mov    %ax,0xf022f2a0
f0103b04:	66 c7 05 a2 f2 22 f0 	movw   $0x8,0xf022f2a2
f0103b0b:	08 00 
f0103b0d:	c6 05 a4 f2 22 f0 00 	movb   $0x0,0xf022f2a4
f0103b14:	c6 05 a5 f2 22 f0 8e 	movb   $0x8e,0xf022f2a5
f0103b1b:	c1 e8 10             	shr    $0x10,%eax
f0103b1e:	66 a3 a6 f2 22 f0    	mov    %ax,0xf022f2a6
	SETGATE(idt[T_TSS], 0, GD_KT, _T_TSS_handler, 0);
f0103b24:	b8 74 43 10 f0       	mov    $0xf0104374,%eax
f0103b29:	66 a3 b0 f2 22 f0    	mov    %ax,0xf022f2b0
f0103b2f:	66 c7 05 b2 f2 22 f0 	movw   $0x8,0xf022f2b2
f0103b36:	08 00 
f0103b38:	c6 05 b4 f2 22 f0 00 	movb   $0x0,0xf022f2b4
f0103b3f:	c6 05 b5 f2 22 f0 8e 	movb   $0x8e,0xf022f2b5
f0103b46:	c1 e8 10             	shr    $0x10,%eax
f0103b49:	66 a3 b6 f2 22 f0    	mov    %ax,0xf022f2b6
	SETGATE(idt[T_SEGNP], 0, GD_KT, _T_SEGNP_handler, 0);
f0103b4f:	b8 78 43 10 f0       	mov    $0xf0104378,%eax
f0103b54:	66 a3 b8 f2 22 f0    	mov    %ax,0xf022f2b8
f0103b5a:	66 c7 05 ba f2 22 f0 	movw   $0x8,0xf022f2ba
f0103b61:	08 00 
f0103b63:	c6 05 bc f2 22 f0 00 	movb   $0x0,0xf022f2bc
f0103b6a:	c6 05 bd f2 22 f0 8e 	movb   $0x8e,0xf022f2bd
f0103b71:	c1 e8 10             	shr    $0x10,%eax
f0103b74:	66 a3 be f2 22 f0    	mov    %ax,0xf022f2be
	SETGATE(idt[T_STACK], 0, GD_KT, _T_STACK_handler, 0);
f0103b7a:	b8 7c 43 10 f0       	mov    $0xf010437c,%eax
f0103b7f:	66 a3 c0 f2 22 f0    	mov    %ax,0xf022f2c0
f0103b85:	66 c7 05 c2 f2 22 f0 	movw   $0x8,0xf022f2c2
f0103b8c:	08 00 
f0103b8e:	c6 05 c4 f2 22 f0 00 	movb   $0x0,0xf022f2c4
f0103b95:	c6 05 c5 f2 22 f0 8e 	movb   $0x8e,0xf022f2c5
f0103b9c:	c1 e8 10             	shr    $0x10,%eax
f0103b9f:	66 a3 c6 f2 22 f0    	mov    %ax,0xf022f2c6
	SETGATE(idt[T_GPFLT], 0, GD_KT, _T_GPFLT_handler, 0);
f0103ba5:	b8 80 43 10 f0       	mov    $0xf0104380,%eax
f0103baa:	66 a3 c8 f2 22 f0    	mov    %ax,0xf022f2c8
f0103bb0:	66 c7 05 ca f2 22 f0 	movw   $0x8,0xf022f2ca
f0103bb7:	08 00 
f0103bb9:	c6 05 cc f2 22 f0 00 	movb   $0x0,0xf022f2cc
f0103bc0:	c6 05 cd f2 22 f0 8e 	movb   $0x8e,0xf022f2cd
f0103bc7:	c1 e8 10             	shr    $0x10,%eax
f0103bca:	66 a3 ce f2 22 f0    	mov    %ax,0xf022f2ce
	SETGATE(idt[T_PGFLT], 0, GD_KT, _T_PGFLT_handler, 0);
f0103bd0:	b8 84 43 10 f0       	mov    $0xf0104384,%eax
f0103bd5:	66 a3 d0 f2 22 f0    	mov    %ax,0xf022f2d0
f0103bdb:	66 c7 05 d2 f2 22 f0 	movw   $0x8,0xf022f2d2
f0103be2:	08 00 
f0103be4:	c6 05 d4 f2 22 f0 00 	movb   $0x0,0xf022f2d4
f0103beb:	c6 05 d5 f2 22 f0 8e 	movb   $0x8e,0xf022f2d5
f0103bf2:	c1 e8 10             	shr    $0x10,%eax
f0103bf5:	66 a3 d6 f2 22 f0    	mov    %ax,0xf022f2d6
	SETGATE(idt[T_FPERR], 0, GD_KT, _T_FPERR_handler, 0);
f0103bfb:	b8 88 43 10 f0       	mov    $0xf0104388,%eax
f0103c00:	66 a3 e0 f2 22 f0    	mov    %ax,0xf022f2e0
f0103c06:	66 c7 05 e2 f2 22 f0 	movw   $0x8,0xf022f2e2
f0103c0d:	08 00 
f0103c0f:	c6 05 e4 f2 22 f0 00 	movb   $0x0,0xf022f2e4
f0103c16:	c6 05 e5 f2 22 f0 8e 	movb   $0x8e,0xf022f2e5
f0103c1d:	c1 e8 10             	shr    $0x10,%eax
f0103c20:	66 a3 e6 f2 22 f0    	mov    %ax,0xf022f2e6
	SETGATE(idt[T_ALIGN], 0, GD_KT, _T_ALIGN_handler, 0);
f0103c26:	b8 8e 43 10 f0       	mov    $0xf010438e,%eax
f0103c2b:	66 a3 e8 f2 22 f0    	mov    %ax,0xf022f2e8
f0103c31:	66 c7 05 ea f2 22 f0 	movw   $0x8,0xf022f2ea
f0103c38:	08 00 
f0103c3a:	c6 05 ec f2 22 f0 00 	movb   $0x0,0xf022f2ec
f0103c41:	c6 05 ed f2 22 f0 8e 	movb   $0x8e,0xf022f2ed
f0103c48:	c1 e8 10             	shr    $0x10,%eax
f0103c4b:	66 a3 ee f2 22 f0    	mov    %ax,0xf022f2ee
	SETGATE(idt[T_MCHK], 0, GD_KT, _T_MCHK_handler, 0);
f0103c51:	b8 92 43 10 f0       	mov    $0xf0104392,%eax
f0103c56:	66 a3 f0 f2 22 f0    	mov    %ax,0xf022f2f0
f0103c5c:	66 c7 05 f2 f2 22 f0 	movw   $0x8,0xf022f2f2
f0103c63:	08 00 
f0103c65:	c6 05 f4 f2 22 f0 00 	movb   $0x0,0xf022f2f4
f0103c6c:	c6 05 f5 f2 22 f0 8e 	movb   $0x8e,0xf022f2f5
f0103c73:	c1 e8 10             	shr    $0x10,%eax
f0103c76:	66 a3 f6 f2 22 f0    	mov    %ax,0xf022f2f6
	SETGATE(idt[T_SIMDERR], 0, GD_KT, _T_SIMDERR_handler, 0);
f0103c7c:	b8 98 43 10 f0       	mov    $0xf0104398,%eax
f0103c81:	66 a3 f8 f2 22 f0    	mov    %ax,0xf022f2f8
f0103c87:	66 c7 05 fa f2 22 f0 	movw   $0x8,0xf022f2fa
f0103c8e:	08 00 
f0103c90:	c6 05 fc f2 22 f0 00 	movb   $0x0,0xf022f2fc
f0103c97:	c6 05 fd f2 22 f0 8e 	movb   $0x8e,0xf022f2fd
f0103c9e:	c1 e8 10             	shr    $0x10,%eax
f0103ca1:	66 a3 fe f2 22 f0    	mov    %ax,0xf022f2fe
	SETGATE(idt[T_SYSCALL], 0, GD_KT, _T_SYSCALL_handler, 3);
f0103ca7:	b8 9e 43 10 f0       	mov    $0xf010439e,%eax
f0103cac:	66 a3 e0 f3 22 f0    	mov    %ax,0xf022f3e0
f0103cb2:	66 c7 05 e2 f3 22 f0 	movw   $0x8,0xf022f3e2
f0103cb9:	08 00 
f0103cbb:	c6 05 e4 f3 22 f0 00 	movb   $0x0,0xf022f3e4
f0103cc2:	c6 05 e5 f3 22 f0 ee 	movb   $0xee,0xf022f3e5
f0103cc9:	c1 e8 10             	shr    $0x10,%eax
f0103ccc:	66 a3 e6 f3 22 f0    	mov    %ax,0xf022f3e6

	SETGATE(idt[IRQ_TIMER + IRQ_OFFSET], 0, GD_KT, _IRQ_TIMER_handler, 0);
f0103cd2:	b8 a4 43 10 f0       	mov    $0xf01043a4,%eax
f0103cd7:	66 a3 60 f3 22 f0    	mov    %ax,0xf022f360
f0103cdd:	66 c7 05 62 f3 22 f0 	movw   $0x8,0xf022f362
f0103ce4:	08 00 
f0103ce6:	c6 05 64 f3 22 f0 00 	movb   $0x0,0xf022f364
f0103ced:	c6 05 65 f3 22 f0 8e 	movb   $0x8e,0xf022f365
f0103cf4:	c1 e8 10             	shr    $0x10,%eax
f0103cf7:	66 a3 66 f3 22 f0    	mov    %ax,0xf022f366
	SETGATE(idt[IRQ_KBD + IRQ_OFFSET], 0, GD_KT, _IRQ_KBD_handler, 0);
f0103cfd:	b8 aa 43 10 f0       	mov    $0xf01043aa,%eax
f0103d02:	66 a3 68 f3 22 f0    	mov    %ax,0xf022f368
f0103d08:	66 c7 05 6a f3 22 f0 	movw   $0x8,0xf022f36a
f0103d0f:	08 00 
f0103d11:	c6 05 6c f3 22 f0 00 	movb   $0x0,0xf022f36c
f0103d18:	c6 05 6d f3 22 f0 8e 	movb   $0x8e,0xf022f36d
f0103d1f:	c1 e8 10             	shr    $0x10,%eax
f0103d22:	66 a3 6e f3 22 f0    	mov    %ax,0xf022f36e
	SETGATE(idt[IRQ_SERIAL + IRQ_OFFSET], 0, GD_KT, _IRQ_SERIAL_handler, 0);
f0103d28:	b8 b0 43 10 f0       	mov    $0xf01043b0,%eax
f0103d2d:	66 a3 80 f3 22 f0    	mov    %ax,0xf022f380
f0103d33:	66 c7 05 82 f3 22 f0 	movw   $0x8,0xf022f382
f0103d3a:	08 00 
f0103d3c:	c6 05 84 f3 22 f0 00 	movb   $0x0,0xf022f384
f0103d43:	c6 05 85 f3 22 f0 8e 	movb   $0x8e,0xf022f385
f0103d4a:	c1 e8 10             	shr    $0x10,%eax
f0103d4d:	66 a3 86 f3 22 f0    	mov    %ax,0xf022f386
	SETGATE(idt[IRQ_SPURIOUS + IRQ_OFFSET], 0, GD_KT, _IRQ_SPURIOUS_handler, 0);
f0103d53:	b8 b6 43 10 f0       	mov    $0xf01043b6,%eax
f0103d58:	66 a3 98 f3 22 f0    	mov    %ax,0xf022f398
f0103d5e:	66 c7 05 9a f3 22 f0 	movw   $0x8,0xf022f39a
f0103d65:	08 00 
f0103d67:	c6 05 9c f3 22 f0 00 	movb   $0x0,0xf022f39c
f0103d6e:	c6 05 9d f3 22 f0 8e 	movb   $0x8e,0xf022f39d
f0103d75:	c1 e8 10             	shr    $0x10,%eax
f0103d78:	66 a3 9e f3 22 f0    	mov    %ax,0xf022f39e
	SETGATE(idt[IRQ_IDE + IRQ_OFFSET], 0, GD_KT, _IRQ_IDE_handler, 0);
f0103d7e:	b8 bc 43 10 f0       	mov    $0xf01043bc,%eax
f0103d83:	66 a3 d0 f3 22 f0    	mov    %ax,0xf022f3d0
f0103d89:	66 c7 05 d2 f3 22 f0 	movw   $0x8,0xf022f3d2
f0103d90:	08 00 
f0103d92:	c6 05 d4 f3 22 f0 00 	movb   $0x0,0xf022f3d4
f0103d99:	c6 05 d5 f3 22 f0 8e 	movb   $0x8e,0xf022f3d5
f0103da0:	c1 e8 10             	shr    $0x10,%eax
f0103da3:	66 a3 d6 f3 22 f0    	mov    %ax,0xf022f3d6
	SETGATE(idt[IRQ_ERROR + IRQ_OFFSET], 0, GD_KT, _IRQ_ERROR_handler, 0);
f0103da9:	b8 c2 43 10 f0       	mov    $0xf01043c2,%eax
f0103dae:	66 a3 f8 f3 22 f0    	mov    %ax,0xf022f3f8
f0103db4:	66 c7 05 fa f3 22 f0 	movw   $0x8,0xf022f3fa
f0103dbb:	08 00 
f0103dbd:	c6 05 fc f3 22 f0 00 	movb   $0x0,0xf022f3fc
f0103dc4:	c6 05 fd f3 22 f0 8e 	movb   $0x8e,0xf022f3fd
f0103dcb:	c1 e8 10             	shr    $0x10,%eax
f0103dce:	66 a3 fe f3 22 f0    	mov    %ax,0xf022f3fe

	// Per-CPU setup 
	trap_init_percpu();
f0103dd4:	e8 e3 fa ff ff       	call   f01038bc <trap_init_percpu>
}
f0103dd9:	c9                   	leave  
f0103dda:	c3                   	ret    

f0103ddb <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103ddb:	55                   	push   %ebp
f0103ddc:	89 e5                	mov    %esp,%ebp
f0103dde:	53                   	push   %ebx
f0103ddf:	83 ec 0c             	sub    $0xc,%esp
f0103de2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103de5:	ff 33                	pushl  (%ebx)
f0103de7:	68 b2 75 10 f0       	push   $0xf01075b2
f0103dec:	e8 b7 fa ff ff       	call   f01038a8 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103df1:	83 c4 08             	add    $0x8,%esp
f0103df4:	ff 73 04             	pushl  0x4(%ebx)
f0103df7:	68 c1 75 10 f0       	push   $0xf01075c1
f0103dfc:	e8 a7 fa ff ff       	call   f01038a8 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103e01:	83 c4 08             	add    $0x8,%esp
f0103e04:	ff 73 08             	pushl  0x8(%ebx)
f0103e07:	68 d0 75 10 f0       	push   $0xf01075d0
f0103e0c:	e8 97 fa ff ff       	call   f01038a8 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103e11:	83 c4 08             	add    $0x8,%esp
f0103e14:	ff 73 0c             	pushl  0xc(%ebx)
f0103e17:	68 df 75 10 f0       	push   $0xf01075df
f0103e1c:	e8 87 fa ff ff       	call   f01038a8 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103e21:	83 c4 08             	add    $0x8,%esp
f0103e24:	ff 73 10             	pushl  0x10(%ebx)
f0103e27:	68 ee 75 10 f0       	push   $0xf01075ee
f0103e2c:	e8 77 fa ff ff       	call   f01038a8 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103e31:	83 c4 08             	add    $0x8,%esp
f0103e34:	ff 73 14             	pushl  0x14(%ebx)
f0103e37:	68 fd 75 10 f0       	push   $0xf01075fd
f0103e3c:	e8 67 fa ff ff       	call   f01038a8 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103e41:	83 c4 08             	add    $0x8,%esp
f0103e44:	ff 73 18             	pushl  0x18(%ebx)
f0103e47:	68 0c 76 10 f0       	push   $0xf010760c
f0103e4c:	e8 57 fa ff ff       	call   f01038a8 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103e51:	83 c4 08             	add    $0x8,%esp
f0103e54:	ff 73 1c             	pushl  0x1c(%ebx)
f0103e57:	68 1b 76 10 f0       	push   $0xf010761b
f0103e5c:	e8 47 fa ff ff       	call   f01038a8 <cprintf>
}
f0103e61:	83 c4 10             	add    $0x10,%esp
f0103e64:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103e67:	c9                   	leave  
f0103e68:	c3                   	ret    

f0103e69 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103e69:	55                   	push   %ebp
f0103e6a:	89 e5                	mov    %esp,%ebp
f0103e6c:	56                   	push   %esi
f0103e6d:	53                   	push   %ebx
f0103e6e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103e71:	e8 34 1c 00 00       	call   f0105aaa <cpunum>
f0103e76:	83 ec 04             	sub    $0x4,%esp
f0103e79:	50                   	push   %eax
f0103e7a:	53                   	push   %ebx
f0103e7b:	68 7f 76 10 f0       	push   $0xf010767f
f0103e80:	e8 23 fa ff ff       	call   f01038a8 <cprintf>
	print_regs(&tf->tf_regs);
f0103e85:	89 1c 24             	mov    %ebx,(%esp)
f0103e88:	e8 4e ff ff ff       	call   f0103ddb <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103e8d:	83 c4 08             	add    $0x8,%esp
f0103e90:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103e94:	50                   	push   %eax
f0103e95:	68 9d 76 10 f0       	push   $0xf010769d
f0103e9a:	e8 09 fa ff ff       	call   f01038a8 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103e9f:	83 c4 08             	add    $0x8,%esp
f0103ea2:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103ea6:	50                   	push   %eax
f0103ea7:	68 b0 76 10 f0       	push   $0xf01076b0
f0103eac:	e8 f7 f9 ff ff       	call   f01038a8 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103eb1:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f0103eb4:	83 c4 10             	add    $0x10,%esp
f0103eb7:	83 f8 13             	cmp    $0x13,%eax
f0103eba:	77 09                	ja     f0103ec5 <print_trapframe+0x5c>
		return excnames[trapno];
f0103ebc:	8b 14 85 40 79 10 f0 	mov    -0xfef86c0(,%eax,4),%edx
f0103ec3:	eb 1f                	jmp    f0103ee4 <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f0103ec5:	83 f8 30             	cmp    $0x30,%eax
f0103ec8:	74 15                	je     f0103edf <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103eca:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f0103ecd:	83 fa 10             	cmp    $0x10,%edx
f0103ed0:	b9 49 76 10 f0       	mov    $0xf0107649,%ecx
f0103ed5:	ba 36 76 10 f0       	mov    $0xf0107636,%edx
f0103eda:	0f 43 d1             	cmovae %ecx,%edx
f0103edd:	eb 05                	jmp    f0103ee4 <print_trapframe+0x7b>
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0103edf:	ba 2a 76 10 f0       	mov    $0xf010762a,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103ee4:	83 ec 04             	sub    $0x4,%esp
f0103ee7:	52                   	push   %edx
f0103ee8:	50                   	push   %eax
f0103ee9:	68 c3 76 10 f0       	push   $0xf01076c3
f0103eee:	e8 b5 f9 ff ff       	call   f01038a8 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103ef3:	83 c4 10             	add    $0x10,%esp
f0103ef6:	3b 1d 60 fa 22 f0    	cmp    0xf022fa60,%ebx
f0103efc:	75 1a                	jne    f0103f18 <print_trapframe+0xaf>
f0103efe:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103f02:	75 14                	jne    f0103f18 <print_trapframe+0xaf>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103f04:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103f07:	83 ec 08             	sub    $0x8,%esp
f0103f0a:	50                   	push   %eax
f0103f0b:	68 d5 76 10 f0       	push   $0xf01076d5
f0103f10:	e8 93 f9 ff ff       	call   f01038a8 <cprintf>
f0103f15:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103f18:	83 ec 08             	sub    $0x8,%esp
f0103f1b:	ff 73 2c             	pushl  0x2c(%ebx)
f0103f1e:	68 e4 76 10 f0       	push   $0xf01076e4
f0103f23:	e8 80 f9 ff ff       	call   f01038a8 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103f28:	83 c4 10             	add    $0x10,%esp
f0103f2b:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103f2f:	75 49                	jne    f0103f7a <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103f31:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103f34:	89 c2                	mov    %eax,%edx
f0103f36:	83 e2 01             	and    $0x1,%edx
f0103f39:	ba 63 76 10 f0       	mov    $0xf0107663,%edx
f0103f3e:	b9 58 76 10 f0       	mov    $0xf0107658,%ecx
f0103f43:	0f 44 ca             	cmove  %edx,%ecx
f0103f46:	89 c2                	mov    %eax,%edx
f0103f48:	83 e2 02             	and    $0x2,%edx
f0103f4b:	ba 75 76 10 f0       	mov    $0xf0107675,%edx
f0103f50:	be 6f 76 10 f0       	mov    $0xf010766f,%esi
f0103f55:	0f 45 d6             	cmovne %esi,%edx
f0103f58:	83 e0 04             	and    $0x4,%eax
f0103f5b:	be bc 77 10 f0       	mov    $0xf01077bc,%esi
f0103f60:	b8 7a 76 10 f0       	mov    $0xf010767a,%eax
f0103f65:	0f 44 c6             	cmove  %esi,%eax
f0103f68:	51                   	push   %ecx
f0103f69:	52                   	push   %edx
f0103f6a:	50                   	push   %eax
f0103f6b:	68 f2 76 10 f0       	push   $0xf01076f2
f0103f70:	e8 33 f9 ff ff       	call   f01038a8 <cprintf>
f0103f75:	83 c4 10             	add    $0x10,%esp
f0103f78:	eb 10                	jmp    f0103f8a <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103f7a:	83 ec 0c             	sub    $0xc,%esp
f0103f7d:	68 20 6a 10 f0       	push   $0xf0106a20
f0103f82:	e8 21 f9 ff ff       	call   f01038a8 <cprintf>
f0103f87:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103f8a:	83 ec 08             	sub    $0x8,%esp
f0103f8d:	ff 73 30             	pushl  0x30(%ebx)
f0103f90:	68 01 77 10 f0       	push   $0xf0107701
f0103f95:	e8 0e f9 ff ff       	call   f01038a8 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103f9a:	83 c4 08             	add    $0x8,%esp
f0103f9d:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103fa1:	50                   	push   %eax
f0103fa2:	68 10 77 10 f0       	push   $0xf0107710
f0103fa7:	e8 fc f8 ff ff       	call   f01038a8 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103fac:	83 c4 08             	add    $0x8,%esp
f0103faf:	ff 73 38             	pushl  0x38(%ebx)
f0103fb2:	68 23 77 10 f0       	push   $0xf0107723
f0103fb7:	e8 ec f8 ff ff       	call   f01038a8 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103fbc:	83 c4 10             	add    $0x10,%esp
f0103fbf:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103fc3:	74 25                	je     f0103fea <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103fc5:	83 ec 08             	sub    $0x8,%esp
f0103fc8:	ff 73 3c             	pushl  0x3c(%ebx)
f0103fcb:	68 32 77 10 f0       	push   $0xf0107732
f0103fd0:	e8 d3 f8 ff ff       	call   f01038a8 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103fd5:	83 c4 08             	add    $0x8,%esp
f0103fd8:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103fdc:	50                   	push   %eax
f0103fdd:	68 41 77 10 f0       	push   $0xf0107741
f0103fe2:	e8 c1 f8 ff ff       	call   f01038a8 <cprintf>
f0103fe7:	83 c4 10             	add    $0x10,%esp
	}
}
f0103fea:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103fed:	5b                   	pop    %ebx
f0103fee:	5e                   	pop    %esi
f0103fef:	5d                   	pop    %ebp
f0103ff0:	c3                   	ret    

f0103ff1 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103ff1:	55                   	push   %ebp
f0103ff2:	89 e5                	mov    %esp,%ebp
f0103ff4:	57                   	push   %edi
f0103ff5:	56                   	push   %esi
f0103ff6:	53                   	push   %ebx
f0103ff7:	83 ec 1c             	sub    $0x1c,%esp
f0103ffa:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103ffd:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) == 0)
f0104000:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104004:	75 15                	jne    f010401b <page_fault_handler+0x2a>
		panic("page fault in kernel at %x!", fault_va);
f0104006:	56                   	push   %esi
f0104007:	68 54 77 10 f0       	push   $0xf0107754
f010400c:	68 55 01 00 00       	push   $0x155
f0104011:	68 70 77 10 f0       	push   $0xf0107770
f0104016:	e8 25 c0 ff ff       	call   f0100040 <_panic>
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	if (curenv->env_pgfault_upcall) {
f010401b:	e8 8a 1a 00 00       	call   f0105aaa <cpunum>
f0104020:	6b c0 74             	imul   $0x74,%eax,%eax
f0104023:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104029:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f010402d:	0f 84 af 00 00 00    	je     f01040e2 <page_fault_handler+0xf1>
		uint32_t estack_top = UXSTACKTOP;

		// if pgfault happens in user exception stack
		// as mentioned above, we push things right after the previous exception stack 
		// started with dummy 4 bytes
		if (tf->tf_esp < UXSTACKTOP && tf->tf_esp >= UXSTACKTOP - PGSIZE)
f0104033:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104036:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			estack_top = tf->tf_esp - 4;
f010403c:	83 e8 04             	sub    $0x4,%eax
f010403f:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0104045:	bf 00 00 c0 ee       	mov    $0xeec00000,%edi
f010404a:	0f 46 f8             	cmovbe %eax,%edi

		// char* utrapframe = (char *)(estack_top - sizeof(struct UTrapframe));
		struct UTrapframe *utf = (struct UTrapframe *)(estack_top - sizeof(struct UTrapframe));
f010404d:	8d 47 cc             	lea    -0x34(%edi),%eax
f0104050:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// do a memory check
		user_mem_assert(curenv, (void *)utf, sizeof(struct UTrapframe), PTE_W | PTE_P);
f0104053:	e8 52 1a 00 00       	call   f0105aaa <cpunum>
f0104058:	6a 03                	push   $0x3
f010405a:	6a 34                	push   $0x34
f010405c:	ff 75 e4             	pushl  -0x1c(%ebp)
f010405f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104062:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0104068:	e8 b2 ee ff ff       	call   f0102f1f <user_mem_assert>

		// copy context to utrapframe 
		// memcpy(utrapframe, (char *)tf, sizeof(struct UTrapframe));
		// *(uint32_t *)utrapframe = fault_va;
		utf->utf_fault_va = fault_va;
f010406d:	89 77 cc             	mov    %esi,-0x34(%edi)
        utf->utf_err      = tf->tf_trapno;
f0104070:	8b 43 28             	mov    0x28(%ebx),%eax
f0104073:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104076:	89 42 04             	mov    %eax,0x4(%edx)
        utf->utf_regs     = tf->tf_regs;
f0104079:	83 ef 2c             	sub    $0x2c,%edi
f010407c:	b9 08 00 00 00       	mov    $0x8,%ecx
f0104081:	89 de                	mov    %ebx,%esi
f0104083:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
        utf->utf_eflags   = tf->tf_eflags;
f0104085:	8b 43 38             	mov    0x38(%ebx),%eax
f0104088:	89 42 2c             	mov    %eax,0x2c(%edx)
        utf->utf_eip      = tf->tf_eip;
f010408b:	8b 43 30             	mov    0x30(%ebx),%eax
f010408e:	89 d6                	mov    %edx,%esi
f0104090:	89 42 28             	mov    %eax,0x28(%edx)
        utf->utf_esp      = tf->tf_esp;
f0104093:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104096:	89 42 30             	mov    %eax,0x30(%edx)

		curenv->env_tf.tf_esp = (uint32_t)utf;
f0104099:	e8 0c 1a 00 00       	call   f0105aaa <cpunum>
f010409e:	6b c0 74             	imul   $0x74,%eax,%eax
f01040a1:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f01040a7:	89 70 3c             	mov    %esi,0x3c(%eax)
		curenv->env_tf.tf_eip = (uint32_t)curenv->env_pgfault_upcall;
f01040aa:	e8 fb 19 00 00       	call   f0105aaa <cpunum>
f01040af:	6b c0 74             	imul   $0x74,%eax,%eax
f01040b2:	8b 98 28 00 23 f0    	mov    -0xfdcffd8(%eax),%ebx
f01040b8:	e8 ed 19 00 00       	call   f0105aaa <cpunum>
f01040bd:	6b c0 74             	imul   $0x74,%eax,%eax
f01040c0:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f01040c6:	8b 40 64             	mov    0x64(%eax),%eax
f01040c9:	89 43 30             	mov    %eax,0x30(%ebx)
		env_run(curenv);
f01040cc:	e8 d9 19 00 00       	call   f0105aaa <cpunum>
f01040d1:	83 c4 04             	add    $0x4,%esp
f01040d4:	6b c0 74             	imul   $0x74,%eax,%eax
f01040d7:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f01040dd:	e8 64 f5 ff ff       	call   f0103646 <env_run>

	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01040e2:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f01040e5:	e8 c0 19 00 00       	call   f0105aaa <cpunum>
		env_run(curenv);

	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01040ea:	57                   	push   %edi
f01040eb:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f01040ec:	6b c0 74             	imul   $0x74,%eax,%eax
		env_run(curenv);

	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01040ef:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f01040f5:	ff 70 48             	pushl  0x48(%eax)
f01040f8:	68 08 79 10 f0       	push   $0xf0107908
f01040fd:	e8 a6 f7 ff ff       	call   f01038a8 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0104102:	89 1c 24             	mov    %ebx,(%esp)
f0104105:	e8 5f fd ff ff       	call   f0103e69 <print_trapframe>
	env_destroy(curenv);
f010410a:	e8 9b 19 00 00       	call   f0105aaa <cpunum>
f010410f:	83 c4 04             	add    $0x4,%esp
f0104112:	6b c0 74             	imul   $0x74,%eax,%eax
f0104115:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f010411b:	e8 87 f4 ff ff       	call   f01035a7 <env_destroy>
}
f0104120:	83 c4 10             	add    $0x10,%esp
f0104123:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104126:	5b                   	pop    %ebx
f0104127:	5e                   	pop    %esi
f0104128:	5f                   	pop    %edi
f0104129:	5d                   	pop    %ebp
f010412a:	c3                   	ret    

f010412b <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f010412b:	55                   	push   %ebp
f010412c:	89 e5                	mov    %esp,%ebp
f010412e:	57                   	push   %edi
f010412f:	56                   	push   %esi
f0104130:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104133:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0104134:	83 3d 80 fe 22 f0 00 	cmpl   $0x0,0xf022fe80
f010413b:	74 01                	je     f010413e <trap+0x13>
		asm volatile("hlt");
f010413d:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f010413e:	e8 67 19 00 00       	call   f0105aaa <cpunum>
f0104143:	6b d0 74             	imul   $0x74,%eax,%edx
f0104146:	81 c2 20 00 23 f0    	add    $0xf0230020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f010414c:	b8 01 00 00 00       	mov    $0x1,%eax
f0104151:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0104155:	83 f8 02             	cmp    $0x2,%eax
f0104158:	75 10                	jne    f010416a <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f010415a:	83 ec 0c             	sub    $0xc,%esp
f010415d:	68 c0 03 12 f0       	push   $0xf01203c0
f0104162:	e8 b1 1b 00 00       	call   f0105d18 <spin_lock>
f0104167:	83 c4 10             	add    $0x10,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f010416a:	9c                   	pushf  
f010416b:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f010416c:	f6 c4 02             	test   $0x2,%ah
f010416f:	74 19                	je     f010418a <trap+0x5f>
f0104171:	68 7c 77 10 f0       	push   $0xf010777c
f0104176:	68 45 67 10 f0       	push   $0xf0106745
f010417b:	68 1d 01 00 00       	push   $0x11d
f0104180:	68 70 77 10 f0       	push   $0xf0107770
f0104185:	e8 b6 be ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f010418a:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010418e:	83 e0 03             	and    $0x3,%eax
f0104191:	66 83 f8 03          	cmp    $0x3,%ax
f0104195:	0f 85 a0 00 00 00    	jne    f010423b <trap+0x110>
f010419b:	83 ec 0c             	sub    $0xc,%esp
f010419e:	68 c0 03 12 f0       	push   $0xf01203c0
f01041a3:	e8 70 1b 00 00       	call   f0105d18 <spin_lock>
		// serious kernel work.
		// LAB 4: Your code here.

		lock_kernel();

		assert(curenv);
f01041a8:	e8 fd 18 00 00       	call   f0105aaa <cpunum>
f01041ad:	6b c0 74             	imul   $0x74,%eax,%eax
f01041b0:	83 c4 10             	add    $0x10,%esp
f01041b3:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f01041ba:	75 19                	jne    f01041d5 <trap+0xaa>
f01041bc:	68 95 77 10 f0       	push   $0xf0107795
f01041c1:	68 45 67 10 f0       	push   $0xf0106745
f01041c6:	68 27 01 00 00       	push   $0x127
f01041cb:	68 70 77 10 f0       	push   $0xf0107770
f01041d0:	e8 6b be ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f01041d5:	e8 d0 18 00 00       	call   f0105aaa <cpunum>
f01041da:	6b c0 74             	imul   $0x74,%eax,%eax
f01041dd:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f01041e3:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01041e7:	75 2d                	jne    f0104216 <trap+0xeb>
			env_free(curenv);
f01041e9:	e8 bc 18 00 00       	call   f0105aaa <cpunum>
f01041ee:	83 ec 0c             	sub    $0xc,%esp
f01041f1:	6b c0 74             	imul   $0x74,%eax,%eax
f01041f4:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f01041fa:	e8 cd f1 ff ff       	call   f01033cc <env_free>
			curenv = NULL;
f01041ff:	e8 a6 18 00 00       	call   f0105aaa <cpunum>
f0104204:	6b c0 74             	imul   $0x74,%eax,%eax
f0104207:	c7 80 28 00 23 f0 00 	movl   $0x0,-0xfdcffd8(%eax)
f010420e:	00 00 00 
			sched_yield();
f0104211:	e8 98 02 00 00       	call   f01044ae <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0104216:	e8 8f 18 00 00       	call   f0105aaa <cpunum>
f010421b:	6b c0 74             	imul   $0x74,%eax,%eax
f010421e:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104224:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104229:	89 c7                	mov    %eax,%edi
f010422b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f010422d:	e8 78 18 00 00       	call   f0105aaa <cpunum>
f0104232:	6b c0 74             	imul   $0x74,%eax,%eax
f0104235:	8b b0 28 00 23 f0    	mov    -0xfdcffd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f010423b:	89 35 60 fa 22 f0    	mov    %esi,0xf022fa60
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	struct PushRegs* r = &tf->tf_regs;

	switch(tf->tf_trapno) {
f0104241:	8b 46 28             	mov    0x28(%esi),%eax
f0104244:	83 f8 0e             	cmp    $0xe,%eax
f0104247:	74 18                	je     f0104261 <trap+0x136>
f0104249:	83 f8 0e             	cmp    $0xe,%eax
f010424c:	77 07                	ja     f0104255 <trap+0x12a>
f010424e:	83 f8 03             	cmp    $0x3,%eax
f0104251:	74 1f                	je     f0104272 <trap+0x147>
f0104253:	eb 56                	jmp    f01042ab <trap+0x180>
f0104255:	83 f8 20             	cmp    $0x20,%eax
f0104258:	74 47                	je     f01042a1 <trap+0x176>
f010425a:	83 f8 30             	cmp    $0x30,%eax
f010425d:	74 21                	je     f0104280 <trap+0x155>
f010425f:	eb 4a                	jmp    f01042ab <trap+0x180>
		case (T_PGFLT):
			page_fault_handler(tf);
f0104261:	83 ec 0c             	sub    $0xc,%esp
f0104264:	56                   	push   %esi
f0104265:	e8 87 fd ff ff       	call   f0103ff1 <page_fault_handler>
f010426a:	83 c4 10             	add    $0x10,%esp
f010426d:	e9 89 00 00 00       	jmp    f01042fb <trap+0x1d0>
			break;
		case (T_BRKPT):
			monitor(tf);	// open a JOS monitor
f0104272:	83 ec 0c             	sub    $0xc,%esp
f0104275:	56                   	push   %esi
f0104276:	e8 f7 c6 ff ff       	call   f0100972 <monitor>
f010427b:	83 c4 10             	add    $0x10,%esp
f010427e:	eb 7b                	jmp    f01042fb <trap+0x1d0>
			break;
		case (T_SYSCALL):
			// call syscall in kern/syscall.c
			r->reg_eax = syscall(r->reg_eax, r->reg_edx, r->reg_ecx, r->reg_ebx, r->reg_edi, r->reg_esi);
f0104280:	83 ec 08             	sub    $0x8,%esp
f0104283:	ff 76 04             	pushl  0x4(%esi)
f0104286:	ff 36                	pushl  (%esi)
f0104288:	ff 76 10             	pushl  0x10(%esi)
f010428b:	ff 76 18             	pushl  0x18(%esi)
f010428e:	ff 76 14             	pushl  0x14(%esi)
f0104291:	ff 76 1c             	pushl  0x1c(%esi)
f0104294:	e8 9e 02 00 00       	call   f0104537 <syscall>
f0104299:	89 46 1c             	mov    %eax,0x1c(%esi)
f010429c:	83 c4 20             	add    $0x20,%esp
f010429f:	eb 5a                	jmp    f01042fb <trap+0x1d0>
			break;
		case (IRQ_OFFSET + IRQ_TIMER):
			lapic_eoi();	// Acknowledge interrupt.
f01042a1:	e8 4f 19 00 00       	call   f0105bf5 <lapic_eoi>
			sched_yield();
f01042a6:	e8 03 02 00 00       	call   f01044ae <sched_yield>
			break;
		default:
			// Unexpected trap: The user process or the kernel has a bug.
			cprintf("[trapno: %x]\n", tf->tf_trapno);
f01042ab:	83 ec 08             	sub    $0x8,%esp
f01042ae:	50                   	push   %eax
f01042af:	68 9c 77 10 f0       	push   $0xf010779c
f01042b4:	e8 ef f5 ff ff       	call   f01038a8 <cprintf>
			print_trapframe(tf);
f01042b9:	89 34 24             	mov    %esi,(%esp)
f01042bc:	e8 a8 fb ff ff       	call   f0103e69 <print_trapframe>
			if (tf->tf_cs == GD_KT)
f01042c1:	83 c4 10             	add    $0x10,%esp
f01042c4:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01042c9:	75 17                	jne    f01042e2 <trap+0x1b7>
				panic("unhandled trap in kernel");
f01042cb:	83 ec 04             	sub    $0x4,%esp
f01042ce:	68 aa 77 10 f0       	push   $0xf01077aa
f01042d3:	68 02 01 00 00       	push   $0x102
f01042d8:	68 70 77 10 f0       	push   $0xf0107770
f01042dd:	e8 5e bd ff ff       	call   f0100040 <_panic>
			else {
				env_destroy(curenv);
f01042e2:	e8 c3 17 00 00       	call   f0105aaa <cpunum>
f01042e7:	83 ec 0c             	sub    $0xc,%esp
f01042ea:	6b c0 74             	imul   $0x74,%eax,%eax
f01042ed:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f01042f3:	e8 af f2 ff ff       	call   f01035a7 <env_destroy>
f01042f8:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f01042fb:	e8 aa 17 00 00       	call   f0105aaa <cpunum>
f0104300:	6b c0 74             	imul   $0x74,%eax,%eax
f0104303:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f010430a:	74 2a                	je     f0104336 <trap+0x20b>
f010430c:	e8 99 17 00 00       	call   f0105aaa <cpunum>
f0104311:	6b c0 74             	imul   $0x74,%eax,%eax
f0104314:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f010431a:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010431e:	75 16                	jne    f0104336 <trap+0x20b>
		env_run(curenv);
f0104320:	e8 85 17 00 00       	call   f0105aaa <cpunum>
f0104325:	83 ec 0c             	sub    $0xc,%esp
f0104328:	6b c0 74             	imul   $0x74,%eax,%eax
f010432b:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0104331:	e8 10 f3 ff ff       	call   f0103646 <env_run>
	else
		sched_yield();
f0104336:	e8 73 01 00 00       	call   f01044ae <sched_yield>
f010433b:	90                   	nop

f010433c <_T_DIVIDE_handler>:
/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */


TRAPHANDLER_NOEC(_T_DIVIDE_handler, T_DIVIDE)
f010433c:	6a 00                	push   $0x0
f010433e:	6a 00                	push   $0x0
f0104340:	e9 83 00 00 00       	jmp    f01043c8 <_alltraps>
f0104345:	90                   	nop

f0104346 <_T_DEBUG_handler>:
TRAPHANDLER_NOEC(_T_DEBUG_handler, T_DEBUG)
f0104346:	6a 00                	push   $0x0
f0104348:	6a 01                	push   $0x1
f010434a:	eb 7c                	jmp    f01043c8 <_alltraps>

f010434c <_T_NMI_handler>:
TRAPHANDLER_NOEC(_T_NMI_handler, T_NMI)
f010434c:	6a 00                	push   $0x0
f010434e:	6a 02                	push   $0x2
f0104350:	eb 76                	jmp    f01043c8 <_alltraps>

f0104352 <_T_BRKPT_handler>:
TRAPHANDLER_NOEC(_T_BRKPT_handler, T_BRKPT)
f0104352:	6a 00                	push   $0x0
f0104354:	6a 03                	push   $0x3
f0104356:	eb 70                	jmp    f01043c8 <_alltraps>

f0104358 <_T_OFLOW_handler>:
TRAPHANDLER_NOEC(_T_OFLOW_handler, T_OFLOW)
f0104358:	6a 00                	push   $0x0
f010435a:	6a 04                	push   $0x4
f010435c:	eb 6a                	jmp    f01043c8 <_alltraps>

f010435e <_T_BOUND_handler>:
TRAPHANDLER_NOEC(_T_BOUND_handler, T_BOUND)
f010435e:	6a 00                	push   $0x0
f0104360:	6a 05                	push   $0x5
f0104362:	eb 64                	jmp    f01043c8 <_alltraps>

f0104364 <_T_ILLOP_handler>:
TRAPHANDLER_NOEC(_T_ILLOP_handler, T_ILLOP)
f0104364:	6a 00                	push   $0x0
f0104366:	6a 06                	push   $0x6
f0104368:	eb 5e                	jmp    f01043c8 <_alltraps>

f010436a <_T_DEVICE_handler>:
TRAPHANDLER_NOEC(_T_DEVICE_handler, T_DEVICE)
f010436a:	6a 00                	push   $0x0
f010436c:	6a 07                	push   $0x7
f010436e:	eb 58                	jmp    f01043c8 <_alltraps>

f0104370 <_T_DBLFLT_handler>:
TRAPHANDLER(_T_DBLFLT_handler, T_DBLFLT)
f0104370:	6a 08                	push   $0x8
f0104372:	eb 54                	jmp    f01043c8 <_alltraps>

f0104374 <_T_TSS_handler>:
TRAPHANDLER(_T_TSS_handler, T_TSS)
f0104374:	6a 0a                	push   $0xa
f0104376:	eb 50                	jmp    f01043c8 <_alltraps>

f0104378 <_T_SEGNP_handler>:
TRAPHANDLER(_T_SEGNP_handler, T_SEGNP)
f0104378:	6a 0b                	push   $0xb
f010437a:	eb 4c                	jmp    f01043c8 <_alltraps>

f010437c <_T_STACK_handler>:
TRAPHANDLER(_T_STACK_handler, T_STACK)
f010437c:	6a 0c                	push   $0xc
f010437e:	eb 48                	jmp    f01043c8 <_alltraps>

f0104380 <_T_GPFLT_handler>:
TRAPHANDLER(_T_GPFLT_handler, T_GPFLT)
f0104380:	6a 0d                	push   $0xd
f0104382:	eb 44                	jmp    f01043c8 <_alltraps>

f0104384 <_T_PGFLT_handler>:
TRAPHANDLER(_T_PGFLT_handler, T_PGFLT)
f0104384:	6a 0e                	push   $0xe
f0104386:	eb 40                	jmp    f01043c8 <_alltraps>

f0104388 <_T_FPERR_handler>:
TRAPHANDLER_NOEC(_T_FPERR_handler, T_FPERR)
f0104388:	6a 00                	push   $0x0
f010438a:	6a 10                	push   $0x10
f010438c:	eb 3a                	jmp    f01043c8 <_alltraps>

f010438e <_T_ALIGN_handler>:
TRAPHANDLER(_T_ALIGN_handler, T_ALIGN)
f010438e:	6a 11                	push   $0x11
f0104390:	eb 36                	jmp    f01043c8 <_alltraps>

f0104392 <_T_MCHK_handler>:
TRAPHANDLER_NOEC(_T_MCHK_handler, T_MCHK)
f0104392:	6a 00                	push   $0x0
f0104394:	6a 12                	push   $0x12
f0104396:	eb 30                	jmp    f01043c8 <_alltraps>

f0104398 <_T_SIMDERR_handler>:
TRAPHANDLER_NOEC(_T_SIMDERR_handler, T_SIMDERR)
f0104398:	6a 00                	push   $0x0
f010439a:	6a 13                	push   $0x13
f010439c:	eb 2a                	jmp    f01043c8 <_alltraps>

f010439e <_T_SYSCALL_handler>:
TRAPHANDLER_NOEC(_T_SYSCALL_handler, T_SYSCALL)
f010439e:	6a 00                	push   $0x0
f01043a0:	6a 30                	push   $0x30
f01043a2:	eb 24                	jmp    f01043c8 <_alltraps>

f01043a4 <_IRQ_TIMER_handler>:

TRAPHANDLER_NOEC(_IRQ_TIMER_handler, IRQ_TIMER + IRQ_OFFSET)
f01043a4:	6a 00                	push   $0x0
f01043a6:	6a 20                	push   $0x20
f01043a8:	eb 1e                	jmp    f01043c8 <_alltraps>

f01043aa <_IRQ_KBD_handler>:
TRAPHANDLER_NOEC(_IRQ_KBD_handler, IRQ_KBD + IRQ_OFFSET)
f01043aa:	6a 00                	push   $0x0
f01043ac:	6a 21                	push   $0x21
f01043ae:	eb 18                	jmp    f01043c8 <_alltraps>

f01043b0 <_IRQ_SERIAL_handler>:
TRAPHANDLER_NOEC(_IRQ_SERIAL_handler, IRQ_SERIAL + IRQ_OFFSET)
f01043b0:	6a 00                	push   $0x0
f01043b2:	6a 24                	push   $0x24
f01043b4:	eb 12                	jmp    f01043c8 <_alltraps>

f01043b6 <_IRQ_SPURIOUS_handler>:
TRAPHANDLER_NOEC(_IRQ_SPURIOUS_handler, IRQ_SPURIOUS + IRQ_OFFSET)
f01043b6:	6a 00                	push   $0x0
f01043b8:	6a 27                	push   $0x27
f01043ba:	eb 0c                	jmp    f01043c8 <_alltraps>

f01043bc <_IRQ_IDE_handler>:
TRAPHANDLER_NOEC(_IRQ_IDE_handler, IRQ_IDE + IRQ_OFFSET)
f01043bc:	6a 00                	push   $0x0
f01043be:	6a 2e                	push   $0x2e
f01043c0:	eb 06                	jmp    f01043c8 <_alltraps>

f01043c2 <_IRQ_ERROR_handler>:
TRAPHANDLER_NOEC(_IRQ_ERROR_handler, IRQ_ERROR + IRQ_OFFSET)
f01043c2:	6a 00                	push   $0x0
f01043c4:	6a 33                	push   $0x33
f01043c6:	eb 00                	jmp    f01043c8 <_alltraps>

f01043c8 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */

_alltraps:
	pushl %ds
f01043c8:	1e                   	push   %ds
	pushl %es
f01043c9:	06                   	push   %es
	pushal	/* push all general registers */
f01043ca:	60                   	pusha  

	movl $GD_KD, %eax
f01043cb:	b8 10 00 00 00       	mov    $0x10,%eax
	movl %eax, %ds
f01043d0:	8e d8                	mov    %eax,%ds
	movl %eax, %es
f01043d2:	8e c0                	mov    %eax,%es

	push %esp
f01043d4:	54                   	push   %esp
f01043d5:	e8 51 fd ff ff       	call   f010412b <trap>

f01043da <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f01043da:	55                   	push   %ebp
f01043db:	89 e5                	mov    %esp,%ebp
f01043dd:	83 ec 08             	sub    $0x8,%esp
f01043e0:	a1 48 f2 22 f0       	mov    0xf022f248,%eax
f01043e5:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01043e8:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f01043ed:	8b 02                	mov    (%edx),%eax
f01043ef:	83 e8 01             	sub    $0x1,%eax
f01043f2:	83 f8 02             	cmp    $0x2,%eax
f01043f5:	76 10                	jbe    f0104407 <sched_halt+0x2d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01043f7:	83 c1 01             	add    $0x1,%ecx
f01043fa:	83 c2 7c             	add    $0x7c,%edx
f01043fd:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104403:	75 e8                	jne    f01043ed <sched_halt+0x13>
f0104405:	eb 08                	jmp    f010440f <sched_halt+0x35>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0104407:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f010440d:	75 1f                	jne    f010442e <sched_halt+0x54>
		cprintf("No runnable environments in the system!\n");
f010440f:	83 ec 0c             	sub    $0xc,%esp
f0104412:	68 90 79 10 f0       	push   $0xf0107990
f0104417:	e8 8c f4 ff ff       	call   f01038a8 <cprintf>
f010441c:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f010441f:	83 ec 0c             	sub    $0xc,%esp
f0104422:	6a 00                	push   $0x0
f0104424:	e8 49 c5 ff ff       	call   f0100972 <monitor>
f0104429:	83 c4 10             	add    $0x10,%esp
f010442c:	eb f1                	jmp    f010441f <sched_halt+0x45>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f010442e:	e8 77 16 00 00       	call   f0105aaa <cpunum>
f0104433:	6b c0 74             	imul   $0x74,%eax,%eax
f0104436:	c7 80 28 00 23 f0 00 	movl   $0x0,-0xfdcffd8(%eax)
f010443d:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104440:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104445:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010444a:	77 12                	ja     f010445e <sched_halt+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010444c:	50                   	push   %eax
f010444d:	68 88 61 10 f0       	push   $0xf0106188
f0104452:	6a 51                	push   $0x51
f0104454:	68 b9 79 10 f0       	push   $0xf01079b9
f0104459:	e8 e2 bb ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010445e:	05 00 00 00 10       	add    $0x10000000,%eax
f0104463:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104466:	e8 3f 16 00 00       	call   f0105aaa <cpunum>
f010446b:	6b d0 74             	imul   $0x74,%eax,%edx
f010446e:	81 c2 20 00 23 f0    	add    $0xf0230020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0104474:	b8 02 00 00 00       	mov    $0x2,%eax
f0104479:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f010447d:	83 ec 0c             	sub    $0xc,%esp
f0104480:	68 c0 03 12 f0       	push   $0xf01203c0
f0104485:	e8 2b 19 00 00       	call   f0105db5 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010448a:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f010448c:	e8 19 16 00 00       	call   f0105aaa <cpunum>
f0104491:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104494:	8b 80 30 00 23 f0    	mov    -0xfdcffd0(%eax),%eax
f010449a:	bd 00 00 00 00       	mov    $0x0,%ebp
f010449f:	89 c4                	mov    %eax,%esp
f01044a1:	6a 00                	push   $0x0
f01044a3:	6a 00                	push   $0x0
f01044a5:	fb                   	sti    
f01044a6:	f4                   	hlt    
f01044a7:	eb fd                	jmp    f01044a6 <sched_halt+0xcc>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f01044a9:	83 c4 10             	add    $0x10,%esp
f01044ac:	c9                   	leave  
f01044ad:	c3                   	ret    

f01044ae <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f01044ae:	55                   	push   %ebp
f01044af:	89 e5                	mov    %esp,%ebp
f01044b1:	56                   	push   %esi
f01044b2:	53                   	push   %ebx
	// below to halt the cpu.

	// LAB 4: Your code here.
	// cprintf("[yield]\n");

	struct Env *now = thiscpu->cpu_env;
f01044b3:	e8 f2 15 00 00       	call   f0105aaa <cpunum>
f01044b8:	6b c0 74             	imul   $0x74,%eax,%eax
f01044bb:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
    int32_t startid = (now) ? ENVX(now->env_id): 0;
f01044c1:	85 c0                	test   %eax,%eax
f01044c3:	74 0b                	je     f01044d0 <sched_yield+0x22>
f01044c5:	8b 50 48             	mov    0x48(%eax),%edx
f01044c8:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01044ce:	eb 05                	jmp    f01044d5 <sched_yield+0x27>
f01044d0:	ba 00 00 00 00       	mov    $0x0,%edx
    int32_t nextid;
    size_t i;

    for(i = 0; i < NENV; i++) {
        nextid = (startid+i)%NENV;
        if(envs[nextid].env_status == ENV_RUNNABLE) {
f01044d5:	8b 0d 48 f2 22 f0    	mov    0xf022f248,%ecx
f01044db:	89 d6                	mov    %edx,%esi
f01044dd:	8d 9a 00 04 00 00    	lea    0x400(%edx),%ebx
f01044e3:	89 d0                	mov    %edx,%eax
f01044e5:	25 ff 03 00 00       	and    $0x3ff,%eax
f01044ea:	6b c0 7c             	imul   $0x7c,%eax,%eax
f01044ed:	01 c8                	add    %ecx,%eax
f01044ef:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f01044f3:	75 09                	jne    f01044fe <sched_yield+0x50>
                env_run(&envs[nextid]);
f01044f5:	83 ec 0c             	sub    $0xc,%esp
f01044f8:	50                   	push   %eax
f01044f9:	e8 48 f1 ff ff       	call   f0103646 <env_run>
f01044fe:	83 c2 01             	add    $0x1,%edx
	struct Env *now = thiscpu->cpu_env;
    int32_t startid = (now) ? ENVX(now->env_id): 0;
    int32_t nextid;
    size_t i;

    for(i = 0; i < NENV; i++) {
f0104501:	39 da                	cmp    %ebx,%edx
f0104503:	75 de                	jne    f01044e3 <sched_yield+0x35>
                env_run(&envs[nextid]);
                return;
            }
    }
    
    if(envs[startid].env_status == ENV_RUNNING && envs[startid].env_cpunum == cpunum()) {
f0104505:	6b f6 7c             	imul   $0x7c,%esi,%esi
f0104508:	01 f1                	add    %esi,%ecx
f010450a:	83 79 54 03          	cmpl   $0x3,0x54(%ecx)
f010450e:	75 1b                	jne    f010452b <sched_yield+0x7d>
f0104510:	8b 59 5c             	mov    0x5c(%ecx),%ebx
f0104513:	e8 92 15 00 00       	call   f0105aaa <cpunum>
f0104518:	39 c3                	cmp    %eax,%ebx
f010451a:	75 0f                	jne    f010452b <sched_yield+0x7d>
        env_run(&envs[startid]);
f010451c:	83 ec 0c             	sub    $0xc,%esp
f010451f:	03 35 48 f2 22 f0    	add    0xf022f248,%esi
f0104525:	56                   	push   %esi
f0104526:	e8 1b f1 ff ff       	call   f0103646 <env_run>
    }

	// cprintf("[halt]\n");

	// sched_halt never returns
	sched_halt();
f010452b:	e8 aa fe ff ff       	call   f01043da <sched_halt>
}
f0104530:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104533:	5b                   	pop    %ebx
f0104534:	5e                   	pop    %esi
f0104535:	5d                   	pop    %ebp
f0104536:	c3                   	ret    

f0104537 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104537:	55                   	push   %ebp
f0104538:	89 e5                	mov    %esp,%ebp
f010453a:	57                   	push   %edi
f010453b:	56                   	push   %esi
f010453c:	53                   	push   %ebx
f010453d:	83 ec 1c             	sub    $0x1c,%esp
f0104540:	8b 45 08             	mov    0x8(%ebp),%eax
	// Return any appropriate return value.
	// LAB 3: Your code here.

	// panic("syscall not implemented");

	switch (syscallno) {
f0104543:	83 f8 0a             	cmp    $0xa,%eax
f0104546:	0f 87 be 03 00 00    	ja     f010490a <syscall+0x3d3>
f010454c:	ff 24 85 00 7a 10 f0 	jmp    *-0xfef8600(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, 0);		// just check if PTE_U is set
f0104553:	e8 52 15 00 00       	call   f0105aaa <cpunum>
f0104558:	6a 00                	push   $0x0
f010455a:	ff 75 10             	pushl  0x10(%ebp)
f010455d:	ff 75 0c             	pushl  0xc(%ebp)
f0104560:	6b c0 74             	imul   $0x74,%eax,%eax
f0104563:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0104569:	e8 b1 e9 ff ff       	call   f0102f1f <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f010456e:	83 c4 0c             	add    $0xc,%esp
f0104571:	ff 75 0c             	pushl  0xc(%ebp)
f0104574:	ff 75 10             	pushl  0x10(%ebp)
f0104577:	68 c6 79 10 f0       	push   $0xf01079c6
f010457c:	e8 27 f3 ff ff       	call   f01038a8 <cprintf>
f0104581:	83 c4 10             	add    $0x10,%esp
	// panic("syscall not implemented");

	switch (syscallno) {
		case SYS_cputs:
			sys_cputs((char *)a1, a2);
			return 0;
f0104584:	b8 00 00 00 00       	mov    $0x0,%eax
f0104589:	e9 81 03 00 00       	jmp    f010490f <syscall+0x3d8>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f010458e:	e8 4b c0 ff ff       	call   f01005de <cons_getc>
	switch (syscallno) {
		case SYS_cputs:
			sys_cputs((char *)a1, a2);
			return 0;
		case SYS_cgetc:
			return sys_cgetc();
f0104593:	e9 77 03 00 00       	jmp    f010490f <syscall+0x3d8>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104598:	e8 0d 15 00 00       	call   f0105aaa <cpunum>
f010459d:	6b c0 74             	imul   $0x74,%eax,%eax
f01045a0:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f01045a6:	8b 40 48             	mov    0x48(%eax),%eax
			sys_cputs((char *)a1, a2);
			return 0;
		case SYS_cgetc:
			return sys_cgetc();
		case SYS_getenvid:
			return sys_getenvid();
f01045a9:	e9 61 03 00 00       	jmp    f010490f <syscall+0x3d8>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01045ae:	83 ec 04             	sub    $0x4,%esp
f01045b1:	6a 01                	push   $0x1
f01045b3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01045b6:	50                   	push   %eax
f01045b7:	ff 75 0c             	pushl  0xc(%ebp)
f01045ba:	e8 2e ea ff ff       	call   f0102fed <envid2env>
f01045bf:	83 c4 10             	add    $0x10,%esp
f01045c2:	85 c0                	test   %eax,%eax
f01045c4:	0f 88 45 03 00 00    	js     f010490f <syscall+0x3d8>
		return r;
	if (e == curenv)
f01045ca:	e8 db 14 00 00       	call   f0105aaa <cpunum>
f01045cf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01045d2:	6b c0 74             	imul   $0x74,%eax,%eax
f01045d5:	39 90 28 00 23 f0    	cmp    %edx,-0xfdcffd8(%eax)
f01045db:	75 23                	jne    f0104600 <syscall+0xc9>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f01045dd:	e8 c8 14 00 00       	call   f0105aaa <cpunum>
f01045e2:	83 ec 08             	sub    $0x8,%esp
f01045e5:	6b c0 74             	imul   $0x74,%eax,%eax
f01045e8:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f01045ee:	ff 70 48             	pushl  0x48(%eax)
f01045f1:	68 cb 79 10 f0       	push   $0xf01079cb
f01045f6:	e8 ad f2 ff ff       	call   f01038a8 <cprintf>
f01045fb:	83 c4 10             	add    $0x10,%esp
f01045fe:	eb 25                	jmp    f0104625 <syscall+0xee>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104600:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104603:	e8 a2 14 00 00       	call   f0105aaa <cpunum>
f0104608:	83 ec 04             	sub    $0x4,%esp
f010460b:	53                   	push   %ebx
f010460c:	6b c0 74             	imul   $0x74,%eax,%eax
f010460f:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104615:	ff 70 48             	pushl  0x48(%eax)
f0104618:	68 e6 79 10 f0       	push   $0xf01079e6
f010461d:	e8 86 f2 ff ff       	call   f01038a8 <cprintf>
f0104622:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0104625:	83 ec 0c             	sub    $0xc,%esp
f0104628:	ff 75 e4             	pushl  -0x1c(%ebp)
f010462b:	e8 77 ef ff ff       	call   f01035a7 <env_destroy>
f0104630:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104633:	b8 00 00 00 00       	mov    $0x0,%eax
f0104638:	e9 d2 02 00 00       	jmp    f010490f <syscall+0x3d8>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f010463d:	e8 6c fe ff ff       	call   f01044ae <sched_yield>
	// LAB 4: Your code here.
	// panic("sys_exofork not implemented");

	struct Env *newenv;

	int err = env_alloc(&newenv , curenv->env_id);
f0104642:	e8 63 14 00 00       	call   f0105aaa <cpunum>
f0104647:	83 ec 08             	sub    $0x8,%esp
f010464a:	6b c0 74             	imul   $0x74,%eax,%eax
f010464d:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104653:	ff 70 48             	pushl  0x48(%eax)
f0104656:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104659:	50                   	push   %eax
f010465a:	e8 99 ea ff ff       	call   f01030f8 <env_alloc>
	if (err < 0)
f010465f:	83 c4 10             	add    $0x10,%esp
f0104662:	85 c0                	test   %eax,%eax
f0104664:	0f 88 a5 02 00 00    	js     f010490f <syscall+0x3d8>
		return err;

	// memcpy(&newenv->env_tf, &curenv->env_tf, sizeof(struct Trapframe));
	newenv->env_tf = curenv->env_tf;
f010466a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010466d:	e8 38 14 00 00       	call   f0105aaa <cpunum>
f0104672:	6b c0 74             	imul   $0x74,%eax,%eax
f0104675:	8b b0 28 00 23 f0    	mov    -0xfdcffd8(%eax),%esi
f010467b:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104680:	89 df                	mov    %ebx,%edi
f0104682:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	newenv->env_status = ENV_NOT_RUNNABLE;
f0104684:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104687:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)

	// tweak newenv, to make it appear to return 0
	newenv->env_tf.tf_regs.reg_eax = 0;
f010468e:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

	return newenv->env_id;
f0104695:	8b 40 48             	mov    0x48(%eax),%eax
f0104698:	e9 72 02 00 00       	jmp    f010490f <syscall+0x3d8>

	// LAB 4: Your code here.
	// panic("sys_env_set_status not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
f010469d:	83 ec 04             	sub    $0x4,%esp
f01046a0:	6a 01                	push   $0x1
f01046a2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01046a5:	50                   	push   %eax
f01046a6:	ff 75 0c             	pushl  0xc(%ebp)
f01046a9:	e8 3f e9 ff ff       	call   f0102fed <envid2env>
	if (err < 0)
f01046ae:	83 c4 10             	add    $0x10,%esp
f01046b1:	85 c0                	test   %eax,%eax
f01046b3:	0f 88 56 02 00 00    	js     f010490f <syscall+0x3d8>
		return err;

	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
f01046b9:	8b 45 10             	mov    0x10(%ebp),%eax
f01046bc:	83 e8 02             	sub    $0x2,%eax
f01046bf:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f01046c4:	75 13                	jne    f01046d9 <syscall+0x1a2>
		return -E_INVAL;

	env_store->env_status = status;
f01046c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01046c9:	8b 7d 10             	mov    0x10(%ebp),%edi
f01046cc:	89 78 54             	mov    %edi,0x54(%eax)

	return 0;
f01046cf:	b8 00 00 00 00       	mov    $0x0,%eax
f01046d4:	e9 36 02 00 00       	jmp    f010490f <syscall+0x3d8>
	int err = envid2env(envid, &env_store, 1);
	if (err < 0)
		return err;

	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
		return -E_INVAL;
f01046d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			sys_yield();
			return 0;
		case SYS_exofork:
			return sys_exofork();
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1, a2);
f01046de:	e9 2c 02 00 00       	jmp    f010490f <syscall+0x3d8>

	// LAB 4: Your code here.
	// panic("sys_page_alloc not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
f01046e3:	83 ec 04             	sub    $0x4,%esp
f01046e6:	6a 01                	push   $0x1
f01046e8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01046eb:	50                   	push   %eax
f01046ec:	ff 75 0c             	pushl  0xc(%ebp)
f01046ef:	e8 f9 e8 ff ff       	call   f0102fed <envid2env>
	if (err < 0)
f01046f4:	83 c4 10             	add    $0x10,%esp
f01046f7:	85 c0                	test   %eax,%eax
f01046f9:	0f 88 10 02 00 00    	js     f010490f <syscall+0x3d8>
		return err;	// E_BAD_ENV

	if ((perm | PTE_AVAIL | PTE_W) != (PTE_AVAIL | PTE_W | PTE_U | PTE_P))
		return -E_INVAL;

	if ((uint32_t)va >= UTOP || ((uint32_t) va % PGSIZE) != 0)
f01046ff:	8b 45 14             	mov    0x14(%ebp),%eax
f0104702:	0d 02 0e 00 00       	or     $0xe02,%eax
f0104707:	3d 07 0e 00 00       	cmp    $0xe07,%eax
f010470c:	75 5c                	jne    f010476a <syscall+0x233>
f010470e:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104715:	77 53                	ja     f010476a <syscall+0x233>
f0104717:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010471e:	75 54                	jne    f0104774 <syscall+0x23d>
		return -E_INVAL;
	
	struct PageInfo * pp = page_alloc(ALLOC_ZERO);
f0104720:	83 ec 0c             	sub    $0xc,%esp
f0104723:	6a 01                	push   $0x1
f0104725:	e8 39 c9 ff ff       	call   f0101063 <page_alloc>
f010472a:	89 c3                	mov    %eax,%ebx
	if (pp == NULL)
f010472c:	83 c4 10             	add    $0x10,%esp
f010472f:	85 c0                	test   %eax,%eax
f0104731:	74 4b                	je     f010477e <syscall+0x247>
		return -E_NO_MEM;
	
	err = page_insert(env_store->env_pgdir, pp, va, perm);
f0104733:	ff 75 14             	pushl  0x14(%ebp)
f0104736:	ff 75 10             	pushl  0x10(%ebp)
f0104739:	50                   	push   %eax
f010473a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010473d:	ff 70 60             	pushl  0x60(%eax)
f0104740:	e8 4c cc ff ff       	call   f0101391 <page_insert>
f0104745:	89 c6                	mov    %eax,%esi
	if (err < 0) {
f0104747:	83 c4 10             	add    $0x10,%esp
		page_free(pp);
		return err; // E_NO_MEM
	}

	return 0;
f010474a:	b8 00 00 00 00       	mov    $0x0,%eax
	struct PageInfo * pp = page_alloc(ALLOC_ZERO);
	if (pp == NULL)
		return -E_NO_MEM;
	
	err = page_insert(env_store->env_pgdir, pp, va, perm);
	if (err < 0) {
f010474f:	85 f6                	test   %esi,%esi
f0104751:	0f 89 b8 01 00 00    	jns    f010490f <syscall+0x3d8>
		page_free(pp);
f0104757:	83 ec 0c             	sub    $0xc,%esp
f010475a:	53                   	push   %ebx
f010475b:	e8 74 c9 ff ff       	call   f01010d4 <page_free>
f0104760:	83 c4 10             	add    $0x10,%esp
		return err; // E_NO_MEM
f0104763:	89 f0                	mov    %esi,%eax
f0104765:	e9 a5 01 00 00       	jmp    f010490f <syscall+0x3d8>

	if ((perm | PTE_AVAIL | PTE_W) != (PTE_AVAIL | PTE_W | PTE_U | PTE_P))
		return -E_INVAL;

	if ((uint32_t)va >= UTOP || ((uint32_t) va % PGSIZE) != 0)
		return -E_INVAL;
f010476a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010476f:	e9 9b 01 00 00       	jmp    f010490f <syscall+0x3d8>
f0104774:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104779:	e9 91 01 00 00       	jmp    f010490f <syscall+0x3d8>
	
	struct PageInfo * pp = page_alloc(ALLOC_ZERO);
	if (pp == NULL)
		return -E_NO_MEM;
f010477e:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104783:	e9 87 01 00 00       	jmp    f010490f <syscall+0x3d8>
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	// panic("sys_page_map not implemented");

	if ((uint32_t)srcva >= UTOP || ((uint32_t)srcva % PGSIZE) != 0 || (uint32_t)dstva >= UTOP || ((uint32_t)dstva % PGSIZE != 0))
f0104788:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f010478f:	0f 87 be 00 00 00    	ja     f0104853 <syscall+0x31c>
f0104795:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010479c:	0f 85 bb 00 00 00    	jne    f010485d <syscall+0x326>
f01047a2:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f01047a9:	0f 87 ae 00 00 00    	ja     f010485d <syscall+0x326>
f01047af:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f01047b6:	0f 85 ab 00 00 00    	jne    f0104867 <syscall+0x330>
		return -E_INVAL;
	
	struct Env *srcenv, *dstenv;
	int err = envid2env(srcenvid, &srcenv, 1);
f01047bc:	83 ec 04             	sub    $0x4,%esp
f01047bf:	6a 01                	push   $0x1
f01047c1:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01047c4:	50                   	push   %eax
f01047c5:	ff 75 0c             	pushl  0xc(%ebp)
f01047c8:	e8 20 e8 ff ff       	call   f0102fed <envid2env>
	if(err < 0)
f01047cd:	83 c4 10             	add    $0x10,%esp
f01047d0:	85 c0                	test   %eax,%eax
f01047d2:	0f 88 37 01 00 00    	js     f010490f <syscall+0x3d8>
		return err;	// E_BAD_ENV
	err = envid2env(dstenvid, &dstenv, 1);
f01047d8:	83 ec 04             	sub    $0x4,%esp
f01047db:	6a 01                	push   $0x1
f01047dd:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01047e0:	50                   	push   %eax
f01047e1:	ff 75 14             	pushl  0x14(%ebp)
f01047e4:	e8 04 e8 ff ff       	call   f0102fed <envid2env>
	if(err < 0)
f01047e9:	83 c4 10             	add    $0x10,%esp
f01047ec:	85 c0                	test   %eax,%eax
f01047ee:	0f 88 1b 01 00 00    	js     f010490f <syscall+0x3d8>
		return err;	// E_BAD_ENV

	pte_t *pte;
	struct PageInfo *pp = page_lookup(srcenv->env_pgdir, srcva, &pte);
f01047f4:	83 ec 04             	sub    $0x4,%esp
f01047f7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01047fa:	50                   	push   %eax
f01047fb:	ff 75 10             	pushl  0x10(%ebp)
f01047fe:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104801:	ff 70 60             	pushl  0x60(%eax)
f0104804:	e8 a0 ca ff ff       	call   f01012a9 <page_lookup>
	if (pp == NULL) 
f0104809:	83 c4 10             	add    $0x10,%esp
f010480c:	85 c0                	test   %eax,%eax
f010480e:	74 61                	je     f0104871 <syscall+0x33a>
		return -E_INVAL;	// not mapped
	
	if ( ((*pte) & PTE_W) == 0 && (perm & PTE_W) != 0)
f0104810:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104813:	f6 02 02             	testb  $0x2,(%edx)
f0104816:	75 06                	jne    f010481e <syscall+0x2e7>
f0104818:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f010481c:	75 5d                	jne    f010487b <syscall+0x344>
		return -E_INVAL;	// read-only page

	// same perm restrictions as in sys_page_alloc
	if ((perm | PTE_AVAIL | PTE_W) != (PTE_AVAIL | PTE_W | PTE_U | PTE_P))
f010481e:	8b 55 1c             	mov    0x1c(%ebp),%edx
f0104821:	81 ca 02 0e 00 00    	or     $0xe02,%edx
f0104827:	81 fa 07 0e 00 00    	cmp    $0xe07,%edx
f010482d:	75 56                	jne    f0104885 <syscall+0x34e>
		return -E_INVAL;

	err = page_insert(dstenv->env_pgdir, pp, dstva, perm);
f010482f:	ff 75 1c             	pushl  0x1c(%ebp)
f0104832:	ff 75 18             	pushl  0x18(%ebp)
f0104835:	50                   	push   %eax
f0104836:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104839:	ff 70 60             	pushl  0x60(%eax)
f010483c:	e8 50 cb ff ff       	call   f0101391 <page_insert>
f0104841:	83 c4 10             	add    $0x10,%esp
f0104844:	85 c0                	test   %eax,%eax
f0104846:	ba 00 00 00 00       	mov    $0x0,%edx
f010484b:	0f 4f c2             	cmovg  %edx,%eax
f010484e:	e9 bc 00 00 00       	jmp    f010490f <syscall+0x3d8>

	// LAB 4: Your code here.
	// panic("sys_page_map not implemented");

	if ((uint32_t)srcva >= UTOP || ((uint32_t)srcva % PGSIZE) != 0 || (uint32_t)dstva >= UTOP || ((uint32_t)dstva % PGSIZE != 0))
		return -E_INVAL;
f0104853:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104858:	e9 b2 00 00 00       	jmp    f010490f <syscall+0x3d8>
f010485d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104862:	e9 a8 00 00 00       	jmp    f010490f <syscall+0x3d8>
f0104867:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010486c:	e9 9e 00 00 00       	jmp    f010490f <syscall+0x3d8>
		return err;	// E_BAD_ENV

	pte_t *pte;
	struct PageInfo *pp = page_lookup(srcenv->env_pgdir, srcva, &pte);
	if (pp == NULL) 
		return -E_INVAL;	// not mapped
f0104871:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104876:	e9 94 00 00 00       	jmp    f010490f <syscall+0x3d8>
	
	if ( ((*pte) & PTE_W) == 0 && (perm & PTE_W) != 0)
		return -E_INVAL;	// read-only page
f010487b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104880:	e9 8a 00 00 00       	jmp    f010490f <syscall+0x3d8>

	// same perm restrictions as in sys_page_alloc
	if ((perm | PTE_AVAIL | PTE_W) != (PTE_AVAIL | PTE_W | PTE_U | PTE_P))
		return -E_INVAL;
f0104885:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1, a2);
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1, (void *)a2, a3);
		case SYS_page_map:
			return sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4, a5);
f010488a:	e9 80 00 00 00       	jmp    f010490f <syscall+0x3d8>
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	// panic("sys_page_unmap not implemented");

	if ((uint32_t)va >= UTOP || ((uint32_t) va % PGSIZE) != 0)
f010488f:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104896:	77 3c                	ja     f01048d4 <syscall+0x39d>
f0104898:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010489f:	75 3a                	jne    f01048db <syscall+0x3a4>
		return -E_INVAL;

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
f01048a1:	83 ec 04             	sub    $0x4,%esp
f01048a4:	6a 01                	push   $0x1
f01048a6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01048a9:	50                   	push   %eax
f01048aa:	ff 75 0c             	pushl  0xc(%ebp)
f01048ad:	e8 3b e7 ff ff       	call   f0102fed <envid2env>
	if (err < 0)
f01048b2:	83 c4 10             	add    $0x10,%esp
f01048b5:	85 c0                	test   %eax,%eax
f01048b7:	78 56                	js     f010490f <syscall+0x3d8>
		return err;	// E_BAD_ENV

	page_remove(env_store->env_pgdir, va);
f01048b9:	83 ec 08             	sub    $0x8,%esp
f01048bc:	ff 75 10             	pushl  0x10(%ebp)
f01048bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01048c2:	ff 70 60             	pushl  0x60(%eax)
f01048c5:	e8 7a ca ff ff       	call   f0101344 <page_remove>
f01048ca:	83 c4 10             	add    $0x10,%esp

	return 0;
f01048cd:	b8 00 00 00 00       	mov    $0x0,%eax
f01048d2:	eb 3b                	jmp    f010490f <syscall+0x3d8>

	// LAB 4: Your code here.
	// panic("sys_page_unmap not implemented");

	if ((uint32_t)va >= UTOP || ((uint32_t) va % PGSIZE) != 0)
		return -E_INVAL;
f01048d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01048d9:	eb 34                	jmp    f010490f <syscall+0x3d8>
f01048db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01048e0:	eb 2d                	jmp    f010490f <syscall+0x3d8>
{
	// LAB 4: Your code here.
	// panic("sys_env_set_pgfault_upcall not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
f01048e2:	83 ec 04             	sub    $0x4,%esp
f01048e5:	6a 01                	push   $0x1
f01048e7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01048ea:	50                   	push   %eax
f01048eb:	ff 75 0c             	pushl  0xc(%ebp)
f01048ee:	e8 fa e6 ff ff       	call   f0102fed <envid2env>
	if (err < 0)
f01048f3:	83 c4 10             	add    $0x10,%esp
f01048f6:	85 c0                	test   %eax,%eax
f01048f8:	78 15                	js     f010490f <syscall+0x3d8>
		return err;

	env_store->env_pgfault_upcall = func;
f01048fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01048fd:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104900:	89 48 64             	mov    %ecx,0x64(%eax)

	return 0;
f0104903:	b8 00 00 00 00       	mov    $0x0,%eax
f0104908:	eb 05                	jmp    f010490f <syscall+0x3d8>
		case SYS_page_unmap:
			return sys_page_unmap((envid_t)a1, (void *)a2);
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
		default:
			return -E_INVAL;
f010490a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
}
f010490f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104912:	5b                   	pop    %ebx
f0104913:	5e                   	pop    %esi
f0104914:	5f                   	pop    %edi
f0104915:	5d                   	pop    %ebp
f0104916:	c3                   	ret    

f0104917 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104917:	55                   	push   %ebp
f0104918:	89 e5                	mov    %esp,%ebp
f010491a:	57                   	push   %edi
f010491b:	56                   	push   %esi
f010491c:	53                   	push   %ebx
f010491d:	83 ec 14             	sub    $0x14,%esp
f0104920:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104923:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104926:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104929:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f010492c:	8b 1a                	mov    (%edx),%ebx
f010492e:	8b 01                	mov    (%ecx),%eax
f0104930:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104933:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f010493a:	eb 7f                	jmp    f01049bb <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f010493c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010493f:	01 d8                	add    %ebx,%eax
f0104941:	89 c6                	mov    %eax,%esi
f0104943:	c1 ee 1f             	shr    $0x1f,%esi
f0104946:	01 c6                	add    %eax,%esi
f0104948:	d1 fe                	sar    %esi
f010494a:	8d 04 76             	lea    (%esi,%esi,2),%eax
f010494d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104950:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104953:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104955:	eb 03                	jmp    f010495a <stab_binsearch+0x43>
			m--;
f0104957:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010495a:	39 c3                	cmp    %eax,%ebx
f010495c:	7f 0d                	jg     f010496b <stab_binsearch+0x54>
f010495e:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104962:	83 ea 0c             	sub    $0xc,%edx
f0104965:	39 f9                	cmp    %edi,%ecx
f0104967:	75 ee                	jne    f0104957 <stab_binsearch+0x40>
f0104969:	eb 05                	jmp    f0104970 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f010496b:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f010496e:	eb 4b                	jmp    f01049bb <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104970:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104973:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104976:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f010497a:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010497d:	76 11                	jbe    f0104990 <stab_binsearch+0x79>
			*region_left = m;
f010497f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104982:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104984:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104987:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010498e:	eb 2b                	jmp    f01049bb <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104990:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104993:	73 14                	jae    f01049a9 <stab_binsearch+0x92>
			*region_right = m - 1;
f0104995:	83 e8 01             	sub    $0x1,%eax
f0104998:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010499b:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010499e:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01049a0:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01049a7:	eb 12                	jmp    f01049bb <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01049a9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01049ac:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f01049ae:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01049b2:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01049b4:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f01049bb:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01049be:	0f 8e 78 ff ff ff    	jle    f010493c <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01049c4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01049c8:	75 0f                	jne    f01049d9 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f01049ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01049cd:	8b 00                	mov    (%eax),%eax
f01049cf:	83 e8 01             	sub    $0x1,%eax
f01049d2:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01049d5:	89 06                	mov    %eax,(%esi)
f01049d7:	eb 2c                	jmp    f0104a05 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01049d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01049dc:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01049de:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01049e1:	8b 0e                	mov    (%esi),%ecx
f01049e3:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01049e6:	8b 75 ec             	mov    -0x14(%ebp),%esi
f01049e9:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01049ec:	eb 03                	jmp    f01049f1 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01049ee:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01049f1:	39 c8                	cmp    %ecx,%eax
f01049f3:	7e 0b                	jle    f0104a00 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f01049f5:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f01049f9:	83 ea 0c             	sub    $0xc,%edx
f01049fc:	39 df                	cmp    %ebx,%edi
f01049fe:	75 ee                	jne    f01049ee <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0104a00:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104a03:	89 06                	mov    %eax,(%esi)
	}
}
f0104a05:	83 c4 14             	add    $0x14,%esp
f0104a08:	5b                   	pop    %ebx
f0104a09:	5e                   	pop    %esi
f0104a0a:	5f                   	pop    %edi
f0104a0b:	5d                   	pop    %ebp
f0104a0c:	c3                   	ret    

f0104a0d <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104a0d:	55                   	push   %ebp
f0104a0e:	89 e5                	mov    %esp,%ebp
f0104a10:	57                   	push   %edi
f0104a11:	56                   	push   %esi
f0104a12:	53                   	push   %ebx
f0104a13:	83 ec 3c             	sub    $0x3c,%esp
f0104a16:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104a19:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104a1c:	c7 03 2c 7a 10 f0    	movl   $0xf0107a2c,(%ebx)
	info->eip_line = 0;
f0104a22:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104a29:	c7 43 08 2c 7a 10 f0 	movl   $0xf0107a2c,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104a30:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104a37:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104a3a:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104a41:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0104a47:	0f 87 a3 00 00 00    	ja     f0104af0 <debuginfo_eip+0xe3>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0104a4d:	a1 00 00 20 00       	mov    0x200000,%eax
f0104a52:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stab_end = usd->stab_end;
f0104a55:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f0104a5b:	8b 15 08 00 20 00    	mov    0x200008,%edx
f0104a61:	89 55 b8             	mov    %edx,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f0104a64:	a1 0c 00 20 00       	mov    0x20000c,%eax
f0104a69:	89 45 bc             	mov    %eax,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0 ||
f0104a6c:	e8 39 10 00 00       	call   f0105aaa <cpunum>
f0104a71:	6a 04                	push   $0x4
f0104a73:	6a 10                	push   $0x10
f0104a75:	68 00 00 20 00       	push   $0x200000
f0104a7a:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a7d:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0104a83:	e8 e5 e3 ff ff       	call   f0102e6d <user_mem_check>
f0104a88:	83 c4 10             	add    $0x10,%esp
f0104a8b:	85 c0                	test   %eax,%eax
f0104a8d:	0f 88 27 02 00 00    	js     f0104cba <debuginfo_eip+0x2ad>
			user_mem_check(curenv, stabs, stab_end-stabs, PTE_U) < 0 ||
f0104a93:	e8 12 10 00 00       	call   f0105aaa <cpunum>
f0104a98:	6a 04                	push   $0x4
f0104a9a:	89 f2                	mov    %esi,%edx
f0104a9c:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104a9f:	29 ca                	sub    %ecx,%edx
f0104aa1:	c1 fa 02             	sar    $0x2,%edx
f0104aa4:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0104aaa:	52                   	push   %edx
f0104aab:	51                   	push   %ecx
f0104aac:	6b c0 74             	imul   $0x74,%eax,%eax
f0104aaf:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0104ab5:	e8 b3 e3 ff ff       	call   f0102e6d <user_mem_check>
		stabstr = usd->stabstr;
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0 ||
f0104aba:	83 c4 10             	add    $0x10,%esp
f0104abd:	85 c0                	test   %eax,%eax
f0104abf:	0f 88 fc 01 00 00    	js     f0104cc1 <debuginfo_eip+0x2b4>
			user_mem_check(curenv, stabs, stab_end-stabs, PTE_U) < 0 ||
			user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U) < 0
f0104ac5:	e8 e0 0f 00 00       	call   f0105aaa <cpunum>
f0104aca:	6a 04                	push   $0x4
f0104acc:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0104acf:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0104ad2:	29 ca                	sub    %ecx,%edx
f0104ad4:	52                   	push   %edx
f0104ad5:	51                   	push   %ecx
f0104ad6:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ad9:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0104adf:	e8 89 e3 ff ff       	call   f0102e6d <user_mem_check>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0 ||
			user_mem_check(curenv, stabs, stab_end-stabs, PTE_U) < 0 ||
f0104ae4:	83 c4 10             	add    $0x10,%esp
f0104ae7:	85 c0                	test   %eax,%eax
f0104ae9:	79 1f                	jns    f0104b0a <debuginfo_eip+0xfd>
f0104aeb:	e9 d8 01 00 00       	jmp    f0104cc8 <debuginfo_eip+0x2bb>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104af0:	c7 45 bc ef 56 11 f0 	movl   $0xf01156ef,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0104af7:	c7 45 b8 e9 1f 11 f0 	movl   $0xf0111fe9,-0x48(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0104afe:	be e8 1f 11 f0       	mov    $0xf0111fe8,%esi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104b03:	c7 45 c0 14 7f 10 f0 	movl   $0xf0107f14,-0x40(%ebp)
		)
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104b0a:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104b0d:	39 45 b8             	cmp    %eax,-0x48(%ebp)
f0104b10:	0f 83 b9 01 00 00    	jae    f0104ccf <debuginfo_eip+0x2c2>
f0104b16:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0104b1a:	0f 85 b6 01 00 00    	jne    f0104cd6 <debuginfo_eip+0x2c9>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104b20:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104b27:	2b 75 c0             	sub    -0x40(%ebp),%esi
f0104b2a:	c1 fe 02             	sar    $0x2,%esi
f0104b2d:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f0104b33:	83 e8 01             	sub    $0x1,%eax
f0104b36:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104b39:	83 ec 08             	sub    $0x8,%esp
f0104b3c:	57                   	push   %edi
f0104b3d:	6a 64                	push   $0x64
f0104b3f:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0104b42:	89 d1                	mov    %edx,%ecx
f0104b44:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104b47:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0104b4a:	89 f0                	mov    %esi,%eax
f0104b4c:	e8 c6 fd ff ff       	call   f0104917 <stab_binsearch>
	if (lfile == 0)
f0104b51:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104b54:	83 c4 10             	add    $0x10,%esp
f0104b57:	85 c0                	test   %eax,%eax
f0104b59:	0f 84 7e 01 00 00    	je     f0104cdd <debuginfo_eip+0x2d0>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104b5f:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104b62:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b65:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104b68:	83 ec 08             	sub    $0x8,%esp
f0104b6b:	57                   	push   %edi
f0104b6c:	6a 24                	push   $0x24
f0104b6e:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0104b71:	89 d1                	mov    %edx,%ecx
f0104b73:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104b76:	89 f0                	mov    %esi,%eax
f0104b78:	e8 9a fd ff ff       	call   f0104917 <stab_binsearch>

	if (lfun <= rfun) {
f0104b7d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104b80:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104b83:	83 c4 10             	add    $0x10,%esp
f0104b86:	39 d0                	cmp    %edx,%eax
f0104b88:	7f 2e                	jg     f0104bb8 <debuginfo_eip+0x1ab>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104b8a:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0104b8d:	8d 34 8e             	lea    (%esi,%ecx,4),%esi
f0104b90:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f0104b93:	8b 36                	mov    (%esi),%esi
f0104b95:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0104b98:	2b 4d b8             	sub    -0x48(%ebp),%ecx
f0104b9b:	39 ce                	cmp    %ecx,%esi
f0104b9d:	73 06                	jae    f0104ba5 <debuginfo_eip+0x198>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104b9f:	03 75 b8             	add    -0x48(%ebp),%esi
f0104ba2:	89 73 08             	mov    %esi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104ba5:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0104ba8:	8b 4e 08             	mov    0x8(%esi),%ecx
f0104bab:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0104bae:	29 cf                	sub    %ecx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0104bb0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104bb3:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0104bb6:	eb 0f                	jmp    f0104bc7 <debuginfo_eip+0x1ba>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104bb8:	89 7b 10             	mov    %edi,0x10(%ebx)
		lline = lfile;
f0104bbb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104bbe:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104bc1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104bc4:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104bc7:	83 ec 08             	sub    $0x8,%esp
f0104bca:	6a 3a                	push   $0x3a
f0104bcc:	ff 73 08             	pushl  0x8(%ebx)
f0104bcf:	e8 97 08 00 00       	call   f010546b <strfind>
f0104bd4:	2b 43 08             	sub    0x8(%ebx),%eax
f0104bd7:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.


	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104bda:	83 c4 08             	add    $0x8,%esp
f0104bdd:	57                   	push   %edi
f0104bde:	6a 44                	push   $0x44
f0104be0:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104be3:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104be6:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0104be9:	89 f0                	mov    %esi,%eax
f0104beb:	e8 27 fd ff ff       	call   f0104917 <stab_binsearch>
	if (lline == 0)
f0104bf0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0104bf3:	83 c4 10             	add    $0x10,%esp
f0104bf6:	85 d2                	test   %edx,%edx
f0104bf8:	0f 84 e6 00 00 00    	je     f0104ce4 <debuginfo_eip+0x2d7>
		return -1;
	// cprintf("[+] %d, %d, %d, %x\n", lline, rline, lfun, stabs[lfun].n_value);
	info->eip_line = stabs[rline].n_desc;
f0104bfe:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104c01:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104c04:	0f b7 44 86 06       	movzwl 0x6(%esi,%eax,4),%eax
f0104c09:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104c0c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104c0f:	89 d0                	mov    %edx,%eax
f0104c11:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104c14:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0104c17:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0104c1b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104c1e:	eb 0a                	jmp    f0104c2a <debuginfo_eip+0x21d>
f0104c20:	83 e8 01             	sub    $0x1,%eax
f0104c23:	83 ea 0c             	sub    $0xc,%edx
f0104c26:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0104c2a:	39 c7                	cmp    %eax,%edi
f0104c2c:	7e 05                	jle    f0104c33 <debuginfo_eip+0x226>
f0104c2e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104c31:	eb 47                	jmp    f0104c7a <debuginfo_eip+0x26d>
	       && stabs[lline].n_type != N_SOL
f0104c33:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104c37:	80 f9 84             	cmp    $0x84,%cl
f0104c3a:	75 0e                	jne    f0104c4a <debuginfo_eip+0x23d>
f0104c3c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104c3f:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104c43:	74 1c                	je     f0104c61 <debuginfo_eip+0x254>
f0104c45:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104c48:	eb 17                	jmp    f0104c61 <debuginfo_eip+0x254>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104c4a:	80 f9 64             	cmp    $0x64,%cl
f0104c4d:	75 d1                	jne    f0104c20 <debuginfo_eip+0x213>
f0104c4f:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0104c53:	74 cb                	je     f0104c20 <debuginfo_eip+0x213>
f0104c55:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104c58:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104c5c:	74 03                	je     f0104c61 <debuginfo_eip+0x254>
f0104c5e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104c61:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104c64:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104c67:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0104c6a:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104c6d:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0104c70:	29 f8                	sub    %edi,%eax
f0104c72:	39 c2                	cmp    %eax,%edx
f0104c74:	73 04                	jae    f0104c7a <debuginfo_eip+0x26d>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104c76:	01 fa                	add    %edi,%edx
f0104c78:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104c7a:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104c7d:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104c80:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104c85:	39 f2                	cmp    %esi,%edx
f0104c87:	7d 67                	jge    f0104cf0 <debuginfo_eip+0x2e3>
		for (lline = lfun + 1;
f0104c89:	83 c2 01             	add    $0x1,%edx
f0104c8c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104c8f:	89 d0                	mov    %edx,%eax
f0104c91:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104c94:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104c97:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0104c9a:	eb 04                	jmp    f0104ca0 <debuginfo_eip+0x293>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104c9c:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104ca0:	39 c6                	cmp    %eax,%esi
f0104ca2:	7e 47                	jle    f0104ceb <debuginfo_eip+0x2de>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104ca4:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104ca8:	83 c0 01             	add    $0x1,%eax
f0104cab:	83 c2 0c             	add    $0xc,%edx
f0104cae:	80 f9 a0             	cmp    $0xa0,%cl
f0104cb1:	74 e9                	je     f0104c9c <debuginfo_eip+0x28f>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104cb3:	b8 00 00 00 00       	mov    $0x0,%eax
f0104cb8:	eb 36                	jmp    f0104cf0 <debuginfo_eip+0x2e3>
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0 ||
			user_mem_check(curenv, stabs, stab_end-stabs, PTE_U) < 0 ||
			user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U) < 0
		)
			return -1;
f0104cba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104cbf:	eb 2f                	jmp    f0104cf0 <debuginfo_eip+0x2e3>
f0104cc1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104cc6:	eb 28                	jmp    f0104cf0 <debuginfo_eip+0x2e3>
f0104cc8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104ccd:	eb 21                	jmp    f0104cf0 <debuginfo_eip+0x2e3>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104ccf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104cd4:	eb 1a                	jmp    f0104cf0 <debuginfo_eip+0x2e3>
f0104cd6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104cdb:	eb 13                	jmp    f0104cf0 <debuginfo_eip+0x2e3>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0104cdd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104ce2:	eb 0c                	jmp    f0104cf0 <debuginfo_eip+0x2e3>
	// Your code here.


	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline == 0)
		return -1;
f0104ce4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104ce9:	eb 05                	jmp    f0104cf0 <debuginfo_eip+0x2e3>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104ceb:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104cf0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104cf3:	5b                   	pop    %ebx
f0104cf4:	5e                   	pop    %esi
f0104cf5:	5f                   	pop    %edi
f0104cf6:	5d                   	pop    %ebp
f0104cf7:	c3                   	ret    

f0104cf8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104cf8:	55                   	push   %ebp
f0104cf9:	89 e5                	mov    %esp,%ebp
f0104cfb:	57                   	push   %edi
f0104cfc:	56                   	push   %esi
f0104cfd:	53                   	push   %ebx
f0104cfe:	83 ec 1c             	sub    $0x1c,%esp
f0104d01:	89 c7                	mov    %eax,%edi
f0104d03:	89 d6                	mov    %edx,%esi
f0104d05:	8b 45 08             	mov    0x8(%ebp),%eax
f0104d08:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104d0b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104d0e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104d11:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104d14:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104d19:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104d1c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104d1f:	39 d3                	cmp    %edx,%ebx
f0104d21:	72 05                	jb     f0104d28 <printnum+0x30>
f0104d23:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104d26:	77 45                	ja     f0104d6d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104d28:	83 ec 0c             	sub    $0xc,%esp
f0104d2b:	ff 75 18             	pushl  0x18(%ebp)
f0104d2e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d31:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0104d34:	53                   	push   %ebx
f0104d35:	ff 75 10             	pushl  0x10(%ebp)
f0104d38:	83 ec 08             	sub    $0x8,%esp
f0104d3b:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104d3e:	ff 75 e0             	pushl  -0x20(%ebp)
f0104d41:	ff 75 dc             	pushl  -0x24(%ebp)
f0104d44:	ff 75 d8             	pushl  -0x28(%ebp)
f0104d47:	e8 64 11 00 00       	call   f0105eb0 <__udivdi3>
f0104d4c:	83 c4 18             	add    $0x18,%esp
f0104d4f:	52                   	push   %edx
f0104d50:	50                   	push   %eax
f0104d51:	89 f2                	mov    %esi,%edx
f0104d53:	89 f8                	mov    %edi,%eax
f0104d55:	e8 9e ff ff ff       	call   f0104cf8 <printnum>
f0104d5a:	83 c4 20             	add    $0x20,%esp
f0104d5d:	eb 18                	jmp    f0104d77 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104d5f:	83 ec 08             	sub    $0x8,%esp
f0104d62:	56                   	push   %esi
f0104d63:	ff 75 18             	pushl  0x18(%ebp)
f0104d66:	ff d7                	call   *%edi
f0104d68:	83 c4 10             	add    $0x10,%esp
f0104d6b:	eb 03                	jmp    f0104d70 <printnum+0x78>
f0104d6d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104d70:	83 eb 01             	sub    $0x1,%ebx
f0104d73:	85 db                	test   %ebx,%ebx
f0104d75:	7f e8                	jg     f0104d5f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104d77:	83 ec 08             	sub    $0x8,%esp
f0104d7a:	56                   	push   %esi
f0104d7b:	83 ec 04             	sub    $0x4,%esp
f0104d7e:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104d81:	ff 75 e0             	pushl  -0x20(%ebp)
f0104d84:	ff 75 dc             	pushl  -0x24(%ebp)
f0104d87:	ff 75 d8             	pushl  -0x28(%ebp)
f0104d8a:	e8 51 12 00 00       	call   f0105fe0 <__umoddi3>
f0104d8f:	83 c4 14             	add    $0x14,%esp
f0104d92:	0f be 80 36 7a 10 f0 	movsbl -0xfef85ca(%eax),%eax
f0104d99:	50                   	push   %eax
f0104d9a:	ff d7                	call   *%edi
}
f0104d9c:	83 c4 10             	add    $0x10,%esp
f0104d9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104da2:	5b                   	pop    %ebx
f0104da3:	5e                   	pop    %esi
f0104da4:	5f                   	pop    %edi
f0104da5:	5d                   	pop    %ebp
f0104da6:	c3                   	ret    

f0104da7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0104da7:	55                   	push   %ebp
f0104da8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0104daa:	83 fa 01             	cmp    $0x1,%edx
f0104dad:	7e 0e                	jle    f0104dbd <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0104daf:	8b 10                	mov    (%eax),%edx
f0104db1:	8d 4a 08             	lea    0x8(%edx),%ecx
f0104db4:	89 08                	mov    %ecx,(%eax)
f0104db6:	8b 02                	mov    (%edx),%eax
f0104db8:	8b 52 04             	mov    0x4(%edx),%edx
f0104dbb:	eb 22                	jmp    f0104ddf <getuint+0x38>
	else if (lflag)
f0104dbd:	85 d2                	test   %edx,%edx
f0104dbf:	74 10                	je     f0104dd1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0104dc1:	8b 10                	mov    (%eax),%edx
f0104dc3:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104dc6:	89 08                	mov    %ecx,(%eax)
f0104dc8:	8b 02                	mov    (%edx),%eax
f0104dca:	ba 00 00 00 00       	mov    $0x0,%edx
f0104dcf:	eb 0e                	jmp    f0104ddf <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0104dd1:	8b 10                	mov    (%eax),%edx
f0104dd3:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104dd6:	89 08                	mov    %ecx,(%eax)
f0104dd8:	8b 02                	mov    (%edx),%eax
f0104dda:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0104ddf:	5d                   	pop    %ebp
f0104de0:	c3                   	ret    

f0104de1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104de1:	55                   	push   %ebp
f0104de2:	89 e5                	mov    %esp,%ebp
f0104de4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104de7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104deb:	8b 10                	mov    (%eax),%edx
f0104ded:	3b 50 04             	cmp    0x4(%eax),%edx
f0104df0:	73 0a                	jae    f0104dfc <sprintputch+0x1b>
		*b->buf++ = ch;
f0104df2:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104df5:	89 08                	mov    %ecx,(%eax)
f0104df7:	8b 45 08             	mov    0x8(%ebp),%eax
f0104dfa:	88 02                	mov    %al,(%edx)
}
f0104dfc:	5d                   	pop    %ebp
f0104dfd:	c3                   	ret    

f0104dfe <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0104dfe:	55                   	push   %ebp
f0104dff:	89 e5                	mov    %esp,%ebp
f0104e01:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0104e04:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104e07:	50                   	push   %eax
f0104e08:	ff 75 10             	pushl  0x10(%ebp)
f0104e0b:	ff 75 0c             	pushl  0xc(%ebp)
f0104e0e:	ff 75 08             	pushl  0x8(%ebp)
f0104e11:	e8 05 00 00 00       	call   f0104e1b <vprintfmt>
	va_end(ap);
}
f0104e16:	83 c4 10             	add    $0x10,%esp
f0104e19:	c9                   	leave  
f0104e1a:	c3                   	ret    

f0104e1b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0104e1b:	55                   	push   %ebp
f0104e1c:	89 e5                	mov    %esp,%ebp
f0104e1e:	57                   	push   %edi
f0104e1f:	56                   	push   %esi
f0104e20:	53                   	push   %ebx
f0104e21:	83 ec 2c             	sub    $0x2c,%esp
f0104e24:	8b 75 08             	mov    0x8(%ebp),%esi
f0104e27:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104e2a:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104e2d:	eb 12                	jmp    f0104e41 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0104e2f:	85 c0                	test   %eax,%eax
f0104e31:	0f 84 89 03 00 00    	je     f01051c0 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0104e37:	83 ec 08             	sub    $0x8,%esp
f0104e3a:	53                   	push   %ebx
f0104e3b:	50                   	push   %eax
f0104e3c:	ff d6                	call   *%esi
f0104e3e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104e41:	83 c7 01             	add    $0x1,%edi
f0104e44:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104e48:	83 f8 25             	cmp    $0x25,%eax
f0104e4b:	75 e2                	jne    f0104e2f <vprintfmt+0x14>
f0104e4d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0104e51:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0104e58:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104e5f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0104e66:	ba 00 00 00 00       	mov    $0x0,%edx
f0104e6b:	eb 07                	jmp    f0104e74 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104e6d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0104e70:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104e74:	8d 47 01             	lea    0x1(%edi),%eax
f0104e77:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104e7a:	0f b6 07             	movzbl (%edi),%eax
f0104e7d:	0f b6 c8             	movzbl %al,%ecx
f0104e80:	83 e8 23             	sub    $0x23,%eax
f0104e83:	3c 55                	cmp    $0x55,%al
f0104e85:	0f 87 1a 03 00 00    	ja     f01051a5 <vprintfmt+0x38a>
f0104e8b:	0f b6 c0             	movzbl %al,%eax
f0104e8e:	ff 24 85 00 7b 10 f0 	jmp    *-0xfef8500(,%eax,4)
f0104e95:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0104e98:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0104e9c:	eb d6                	jmp    f0104e74 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104e9e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104ea1:	b8 00 00 00 00       	mov    $0x0,%eax
f0104ea6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104ea9:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104eac:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0104eb0:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0104eb3:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0104eb6:	83 fa 09             	cmp    $0x9,%edx
f0104eb9:	77 39                	ja     f0104ef4 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104ebb:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0104ebe:	eb e9                	jmp    f0104ea9 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0104ec0:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ec3:	8d 48 04             	lea    0x4(%eax),%ecx
f0104ec6:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0104ec9:	8b 00                	mov    (%eax),%eax
f0104ecb:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104ece:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0104ed1:	eb 27                	jmp    f0104efa <vprintfmt+0xdf>
f0104ed3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104ed6:	85 c0                	test   %eax,%eax
f0104ed8:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104edd:	0f 49 c8             	cmovns %eax,%ecx
f0104ee0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104ee3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104ee6:	eb 8c                	jmp    f0104e74 <vprintfmt+0x59>
f0104ee8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0104eeb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0104ef2:	eb 80                	jmp    f0104e74 <vprintfmt+0x59>
f0104ef4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104ef7:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0104efa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104efe:	0f 89 70 ff ff ff    	jns    f0104e74 <vprintfmt+0x59>
				width = precision, precision = -1;
f0104f04:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104f07:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104f0a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104f11:	e9 5e ff ff ff       	jmp    f0104e74 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0104f16:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104f19:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0104f1c:	e9 53 ff ff ff       	jmp    f0104e74 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0104f21:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f24:	8d 50 04             	lea    0x4(%eax),%edx
f0104f27:	89 55 14             	mov    %edx,0x14(%ebp)
f0104f2a:	83 ec 08             	sub    $0x8,%esp
f0104f2d:	53                   	push   %ebx
f0104f2e:	ff 30                	pushl  (%eax)
f0104f30:	ff d6                	call   *%esi
			break;
f0104f32:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104f35:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0104f38:	e9 04 ff ff ff       	jmp    f0104e41 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0104f3d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f40:	8d 50 04             	lea    0x4(%eax),%edx
f0104f43:	89 55 14             	mov    %edx,0x14(%ebp)
f0104f46:	8b 00                	mov    (%eax),%eax
f0104f48:	99                   	cltd   
f0104f49:	31 d0                	xor    %edx,%eax
f0104f4b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104f4d:	83 f8 08             	cmp    $0x8,%eax
f0104f50:	7f 0b                	jg     f0104f5d <vprintfmt+0x142>
f0104f52:	8b 14 85 60 7c 10 f0 	mov    -0xfef83a0(,%eax,4),%edx
f0104f59:	85 d2                	test   %edx,%edx
f0104f5b:	75 18                	jne    f0104f75 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0104f5d:	50                   	push   %eax
f0104f5e:	68 4e 7a 10 f0       	push   $0xf0107a4e
f0104f63:	53                   	push   %ebx
f0104f64:	56                   	push   %esi
f0104f65:	e8 94 fe ff ff       	call   f0104dfe <printfmt>
f0104f6a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104f6d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0104f70:	e9 cc fe ff ff       	jmp    f0104e41 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0104f75:	52                   	push   %edx
f0104f76:	68 57 67 10 f0       	push   $0xf0106757
f0104f7b:	53                   	push   %ebx
f0104f7c:	56                   	push   %esi
f0104f7d:	e8 7c fe ff ff       	call   f0104dfe <printfmt>
f0104f82:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104f85:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104f88:	e9 b4 fe ff ff       	jmp    f0104e41 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0104f8d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f90:	8d 50 04             	lea    0x4(%eax),%edx
f0104f93:	89 55 14             	mov    %edx,0x14(%ebp)
f0104f96:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0104f98:	85 ff                	test   %edi,%edi
f0104f9a:	b8 47 7a 10 f0       	mov    $0xf0107a47,%eax
f0104f9f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0104fa2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104fa6:	0f 8e 94 00 00 00    	jle    f0105040 <vprintfmt+0x225>
f0104fac:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0104fb0:	0f 84 98 00 00 00    	je     f010504e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0104fb6:	83 ec 08             	sub    $0x8,%esp
f0104fb9:	ff 75 d0             	pushl  -0x30(%ebp)
f0104fbc:	57                   	push   %edi
f0104fbd:	e8 5f 03 00 00       	call   f0105321 <strnlen>
f0104fc2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104fc5:	29 c1                	sub    %eax,%ecx
f0104fc7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0104fca:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0104fcd:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0104fd1:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104fd4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0104fd7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104fd9:	eb 0f                	jmp    f0104fea <vprintfmt+0x1cf>
					putch(padc, putdat);
f0104fdb:	83 ec 08             	sub    $0x8,%esp
f0104fde:	53                   	push   %ebx
f0104fdf:	ff 75 e0             	pushl  -0x20(%ebp)
f0104fe2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104fe4:	83 ef 01             	sub    $0x1,%edi
f0104fe7:	83 c4 10             	add    $0x10,%esp
f0104fea:	85 ff                	test   %edi,%edi
f0104fec:	7f ed                	jg     f0104fdb <vprintfmt+0x1c0>
f0104fee:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104ff1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0104ff4:	85 c9                	test   %ecx,%ecx
f0104ff6:	b8 00 00 00 00       	mov    $0x0,%eax
f0104ffb:	0f 49 c1             	cmovns %ecx,%eax
f0104ffe:	29 c1                	sub    %eax,%ecx
f0105000:	89 75 08             	mov    %esi,0x8(%ebp)
f0105003:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105006:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105009:	89 cb                	mov    %ecx,%ebx
f010500b:	eb 4d                	jmp    f010505a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f010500d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105011:	74 1b                	je     f010502e <vprintfmt+0x213>
f0105013:	0f be c0             	movsbl %al,%eax
f0105016:	83 e8 20             	sub    $0x20,%eax
f0105019:	83 f8 5e             	cmp    $0x5e,%eax
f010501c:	76 10                	jbe    f010502e <vprintfmt+0x213>
					putch('?', putdat);
f010501e:	83 ec 08             	sub    $0x8,%esp
f0105021:	ff 75 0c             	pushl  0xc(%ebp)
f0105024:	6a 3f                	push   $0x3f
f0105026:	ff 55 08             	call   *0x8(%ebp)
f0105029:	83 c4 10             	add    $0x10,%esp
f010502c:	eb 0d                	jmp    f010503b <vprintfmt+0x220>
				else
					putch(ch, putdat);
f010502e:	83 ec 08             	sub    $0x8,%esp
f0105031:	ff 75 0c             	pushl  0xc(%ebp)
f0105034:	52                   	push   %edx
f0105035:	ff 55 08             	call   *0x8(%ebp)
f0105038:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010503b:	83 eb 01             	sub    $0x1,%ebx
f010503e:	eb 1a                	jmp    f010505a <vprintfmt+0x23f>
f0105040:	89 75 08             	mov    %esi,0x8(%ebp)
f0105043:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105046:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105049:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010504c:	eb 0c                	jmp    f010505a <vprintfmt+0x23f>
f010504e:	89 75 08             	mov    %esi,0x8(%ebp)
f0105051:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105054:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105057:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010505a:	83 c7 01             	add    $0x1,%edi
f010505d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105061:	0f be d0             	movsbl %al,%edx
f0105064:	85 d2                	test   %edx,%edx
f0105066:	74 23                	je     f010508b <vprintfmt+0x270>
f0105068:	85 f6                	test   %esi,%esi
f010506a:	78 a1                	js     f010500d <vprintfmt+0x1f2>
f010506c:	83 ee 01             	sub    $0x1,%esi
f010506f:	79 9c                	jns    f010500d <vprintfmt+0x1f2>
f0105071:	89 df                	mov    %ebx,%edi
f0105073:	8b 75 08             	mov    0x8(%ebp),%esi
f0105076:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105079:	eb 18                	jmp    f0105093 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010507b:	83 ec 08             	sub    $0x8,%esp
f010507e:	53                   	push   %ebx
f010507f:	6a 20                	push   $0x20
f0105081:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105083:	83 ef 01             	sub    $0x1,%edi
f0105086:	83 c4 10             	add    $0x10,%esp
f0105089:	eb 08                	jmp    f0105093 <vprintfmt+0x278>
f010508b:	89 df                	mov    %ebx,%edi
f010508d:	8b 75 08             	mov    0x8(%ebp),%esi
f0105090:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105093:	85 ff                	test   %edi,%edi
f0105095:	7f e4                	jg     f010507b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105097:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010509a:	e9 a2 fd ff ff       	jmp    f0104e41 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010509f:	83 fa 01             	cmp    $0x1,%edx
f01050a2:	7e 16                	jle    f01050ba <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f01050a4:	8b 45 14             	mov    0x14(%ebp),%eax
f01050a7:	8d 50 08             	lea    0x8(%eax),%edx
f01050aa:	89 55 14             	mov    %edx,0x14(%ebp)
f01050ad:	8b 50 04             	mov    0x4(%eax),%edx
f01050b0:	8b 00                	mov    (%eax),%eax
f01050b2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01050b5:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01050b8:	eb 32                	jmp    f01050ec <vprintfmt+0x2d1>
	else if (lflag)
f01050ba:	85 d2                	test   %edx,%edx
f01050bc:	74 18                	je     f01050d6 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f01050be:	8b 45 14             	mov    0x14(%ebp),%eax
f01050c1:	8d 50 04             	lea    0x4(%eax),%edx
f01050c4:	89 55 14             	mov    %edx,0x14(%ebp)
f01050c7:	8b 00                	mov    (%eax),%eax
f01050c9:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01050cc:	89 c1                	mov    %eax,%ecx
f01050ce:	c1 f9 1f             	sar    $0x1f,%ecx
f01050d1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01050d4:	eb 16                	jmp    f01050ec <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f01050d6:	8b 45 14             	mov    0x14(%ebp),%eax
f01050d9:	8d 50 04             	lea    0x4(%eax),%edx
f01050dc:	89 55 14             	mov    %edx,0x14(%ebp)
f01050df:	8b 00                	mov    (%eax),%eax
f01050e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01050e4:	89 c1                	mov    %eax,%ecx
f01050e6:	c1 f9 1f             	sar    $0x1f,%ecx
f01050e9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01050ec:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01050ef:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01050f2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01050f7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01050fb:	79 74                	jns    f0105171 <vprintfmt+0x356>
				putch('-', putdat);
f01050fd:	83 ec 08             	sub    $0x8,%esp
f0105100:	53                   	push   %ebx
f0105101:	6a 2d                	push   $0x2d
f0105103:	ff d6                	call   *%esi
				num = -(long long) num;
f0105105:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105108:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010510b:	f7 d8                	neg    %eax
f010510d:	83 d2 00             	adc    $0x0,%edx
f0105110:	f7 da                	neg    %edx
f0105112:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0105115:	b9 0a 00 00 00       	mov    $0xa,%ecx
f010511a:	eb 55                	jmp    f0105171 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f010511c:	8d 45 14             	lea    0x14(%ebp),%eax
f010511f:	e8 83 fc ff ff       	call   f0104da7 <getuint>
			base = 10;
f0105124:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0105129:	eb 46                	jmp    f0105171 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
f010512b:	8d 45 14             	lea    0x14(%ebp),%eax
f010512e:	e8 74 fc ff ff       	call   f0104da7 <getuint>
			base = 8;
f0105133:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0105138:	eb 37                	jmp    f0105171 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
f010513a:	83 ec 08             	sub    $0x8,%esp
f010513d:	53                   	push   %ebx
f010513e:	6a 30                	push   $0x30
f0105140:	ff d6                	call   *%esi
			putch('x', putdat);
f0105142:	83 c4 08             	add    $0x8,%esp
f0105145:	53                   	push   %ebx
f0105146:	6a 78                	push   $0x78
f0105148:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f010514a:	8b 45 14             	mov    0x14(%ebp),%eax
f010514d:	8d 50 04             	lea    0x4(%eax),%edx
f0105150:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0105153:	8b 00                	mov    (%eax),%eax
f0105155:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f010515a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f010515d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0105162:	eb 0d                	jmp    f0105171 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0105164:	8d 45 14             	lea    0x14(%ebp),%eax
f0105167:	e8 3b fc ff ff       	call   f0104da7 <getuint>
			base = 16;
f010516c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105171:	83 ec 0c             	sub    $0xc,%esp
f0105174:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0105178:	57                   	push   %edi
f0105179:	ff 75 e0             	pushl  -0x20(%ebp)
f010517c:	51                   	push   %ecx
f010517d:	52                   	push   %edx
f010517e:	50                   	push   %eax
f010517f:	89 da                	mov    %ebx,%edx
f0105181:	89 f0                	mov    %esi,%eax
f0105183:	e8 70 fb ff ff       	call   f0104cf8 <printnum>
			break;
f0105188:	83 c4 20             	add    $0x20,%esp
f010518b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010518e:	e9 ae fc ff ff       	jmp    f0104e41 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105193:	83 ec 08             	sub    $0x8,%esp
f0105196:	53                   	push   %ebx
f0105197:	51                   	push   %ecx
f0105198:	ff d6                	call   *%esi
			break;
f010519a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010519d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01051a0:	e9 9c fc ff ff       	jmp    f0104e41 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01051a5:	83 ec 08             	sub    $0x8,%esp
f01051a8:	53                   	push   %ebx
f01051a9:	6a 25                	push   $0x25
f01051ab:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01051ad:	83 c4 10             	add    $0x10,%esp
f01051b0:	eb 03                	jmp    f01051b5 <vprintfmt+0x39a>
f01051b2:	83 ef 01             	sub    $0x1,%edi
f01051b5:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f01051b9:	75 f7                	jne    f01051b2 <vprintfmt+0x397>
f01051bb:	e9 81 fc ff ff       	jmp    f0104e41 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f01051c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01051c3:	5b                   	pop    %ebx
f01051c4:	5e                   	pop    %esi
f01051c5:	5f                   	pop    %edi
f01051c6:	5d                   	pop    %ebp
f01051c7:	c3                   	ret    

f01051c8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01051c8:	55                   	push   %ebp
f01051c9:	89 e5                	mov    %esp,%ebp
f01051cb:	83 ec 18             	sub    $0x18,%esp
f01051ce:	8b 45 08             	mov    0x8(%ebp),%eax
f01051d1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01051d4:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01051d7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01051db:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01051de:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01051e5:	85 c0                	test   %eax,%eax
f01051e7:	74 26                	je     f010520f <vsnprintf+0x47>
f01051e9:	85 d2                	test   %edx,%edx
f01051eb:	7e 22                	jle    f010520f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01051ed:	ff 75 14             	pushl  0x14(%ebp)
f01051f0:	ff 75 10             	pushl  0x10(%ebp)
f01051f3:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01051f6:	50                   	push   %eax
f01051f7:	68 e1 4d 10 f0       	push   $0xf0104de1
f01051fc:	e8 1a fc ff ff       	call   f0104e1b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105201:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105204:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105207:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010520a:	83 c4 10             	add    $0x10,%esp
f010520d:	eb 05                	jmp    f0105214 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f010520f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0105214:	c9                   	leave  
f0105215:	c3                   	ret    

f0105216 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105216:	55                   	push   %ebp
f0105217:	89 e5                	mov    %esp,%ebp
f0105219:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010521c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010521f:	50                   	push   %eax
f0105220:	ff 75 10             	pushl  0x10(%ebp)
f0105223:	ff 75 0c             	pushl  0xc(%ebp)
f0105226:	ff 75 08             	pushl  0x8(%ebp)
f0105229:	e8 9a ff ff ff       	call   f01051c8 <vsnprintf>
	va_end(ap);

	return rc;
}
f010522e:	c9                   	leave  
f010522f:	c3                   	ret    

f0105230 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105230:	55                   	push   %ebp
f0105231:	89 e5                	mov    %esp,%ebp
f0105233:	57                   	push   %edi
f0105234:	56                   	push   %esi
f0105235:	53                   	push   %ebx
f0105236:	83 ec 0c             	sub    $0xc,%esp
f0105239:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010523c:	85 c0                	test   %eax,%eax
f010523e:	74 11                	je     f0105251 <readline+0x21>
		cprintf("%s", prompt);
f0105240:	83 ec 08             	sub    $0x8,%esp
f0105243:	50                   	push   %eax
f0105244:	68 57 67 10 f0       	push   $0xf0106757
f0105249:	e8 5a e6 ff ff       	call   f01038a8 <cprintf>
f010524e:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0105251:	83 ec 0c             	sub    $0xc,%esp
f0105254:	6a 00                	push   $0x0
f0105256:	e8 13 b5 ff ff       	call   f010076e <iscons>
f010525b:	89 c7                	mov    %eax,%edi
f010525d:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0105260:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0105265:	e8 f3 b4 ff ff       	call   f010075d <getchar>
f010526a:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010526c:	85 c0                	test   %eax,%eax
f010526e:	79 18                	jns    f0105288 <readline+0x58>
			cprintf("read error: %e\n", c);
f0105270:	83 ec 08             	sub    $0x8,%esp
f0105273:	50                   	push   %eax
f0105274:	68 84 7c 10 f0       	push   $0xf0107c84
f0105279:	e8 2a e6 ff ff       	call   f01038a8 <cprintf>
			return NULL;
f010527e:	83 c4 10             	add    $0x10,%esp
f0105281:	b8 00 00 00 00       	mov    $0x0,%eax
f0105286:	eb 79                	jmp    f0105301 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105288:	83 f8 08             	cmp    $0x8,%eax
f010528b:	0f 94 c2             	sete   %dl
f010528e:	83 f8 7f             	cmp    $0x7f,%eax
f0105291:	0f 94 c0             	sete   %al
f0105294:	08 c2                	or     %al,%dl
f0105296:	74 1a                	je     f01052b2 <readline+0x82>
f0105298:	85 f6                	test   %esi,%esi
f010529a:	7e 16                	jle    f01052b2 <readline+0x82>
			if (echoing)
f010529c:	85 ff                	test   %edi,%edi
f010529e:	74 0d                	je     f01052ad <readline+0x7d>
				cputchar('\b');
f01052a0:	83 ec 0c             	sub    $0xc,%esp
f01052a3:	6a 08                	push   $0x8
f01052a5:	e8 a3 b4 ff ff       	call   f010074d <cputchar>
f01052aa:	83 c4 10             	add    $0x10,%esp
			i--;
f01052ad:	83 ee 01             	sub    $0x1,%esi
f01052b0:	eb b3                	jmp    f0105265 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01052b2:	83 fb 1f             	cmp    $0x1f,%ebx
f01052b5:	7e 23                	jle    f01052da <readline+0xaa>
f01052b7:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01052bd:	7f 1b                	jg     f01052da <readline+0xaa>
			if (echoing)
f01052bf:	85 ff                	test   %edi,%edi
f01052c1:	74 0c                	je     f01052cf <readline+0x9f>
				cputchar(c);
f01052c3:	83 ec 0c             	sub    $0xc,%esp
f01052c6:	53                   	push   %ebx
f01052c7:	e8 81 b4 ff ff       	call   f010074d <cputchar>
f01052cc:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01052cf:	88 9e 80 fa 22 f0    	mov    %bl,-0xfdd0580(%esi)
f01052d5:	8d 76 01             	lea    0x1(%esi),%esi
f01052d8:	eb 8b                	jmp    f0105265 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f01052da:	83 fb 0a             	cmp    $0xa,%ebx
f01052dd:	74 05                	je     f01052e4 <readline+0xb4>
f01052df:	83 fb 0d             	cmp    $0xd,%ebx
f01052e2:	75 81                	jne    f0105265 <readline+0x35>
			if (echoing)
f01052e4:	85 ff                	test   %edi,%edi
f01052e6:	74 0d                	je     f01052f5 <readline+0xc5>
				cputchar('\n');
f01052e8:	83 ec 0c             	sub    $0xc,%esp
f01052eb:	6a 0a                	push   $0xa
f01052ed:	e8 5b b4 ff ff       	call   f010074d <cputchar>
f01052f2:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01052f5:	c6 86 80 fa 22 f0 00 	movb   $0x0,-0xfdd0580(%esi)
			return buf;
f01052fc:	b8 80 fa 22 f0       	mov    $0xf022fa80,%eax
		}
	}
}
f0105301:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105304:	5b                   	pop    %ebx
f0105305:	5e                   	pop    %esi
f0105306:	5f                   	pop    %edi
f0105307:	5d                   	pop    %ebp
f0105308:	c3                   	ret    

f0105309 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105309:	55                   	push   %ebp
f010530a:	89 e5                	mov    %esp,%ebp
f010530c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010530f:	b8 00 00 00 00       	mov    $0x0,%eax
f0105314:	eb 03                	jmp    f0105319 <strlen+0x10>
		n++;
f0105316:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105319:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010531d:	75 f7                	jne    f0105316 <strlen+0xd>
		n++;
	return n;
}
f010531f:	5d                   	pop    %ebp
f0105320:	c3                   	ret    

f0105321 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105321:	55                   	push   %ebp
f0105322:	89 e5                	mov    %esp,%ebp
f0105324:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105327:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010532a:	ba 00 00 00 00       	mov    $0x0,%edx
f010532f:	eb 03                	jmp    f0105334 <strnlen+0x13>
		n++;
f0105331:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105334:	39 c2                	cmp    %eax,%edx
f0105336:	74 08                	je     f0105340 <strnlen+0x1f>
f0105338:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f010533c:	75 f3                	jne    f0105331 <strnlen+0x10>
f010533e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0105340:	5d                   	pop    %ebp
f0105341:	c3                   	ret    

f0105342 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105342:	55                   	push   %ebp
f0105343:	89 e5                	mov    %esp,%ebp
f0105345:	53                   	push   %ebx
f0105346:	8b 45 08             	mov    0x8(%ebp),%eax
f0105349:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010534c:	89 c2                	mov    %eax,%edx
f010534e:	83 c2 01             	add    $0x1,%edx
f0105351:	83 c1 01             	add    $0x1,%ecx
f0105354:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0105358:	88 5a ff             	mov    %bl,-0x1(%edx)
f010535b:	84 db                	test   %bl,%bl
f010535d:	75 ef                	jne    f010534e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f010535f:	5b                   	pop    %ebx
f0105360:	5d                   	pop    %ebp
f0105361:	c3                   	ret    

f0105362 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105362:	55                   	push   %ebp
f0105363:	89 e5                	mov    %esp,%ebp
f0105365:	53                   	push   %ebx
f0105366:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105369:	53                   	push   %ebx
f010536a:	e8 9a ff ff ff       	call   f0105309 <strlen>
f010536f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0105372:	ff 75 0c             	pushl  0xc(%ebp)
f0105375:	01 d8                	add    %ebx,%eax
f0105377:	50                   	push   %eax
f0105378:	e8 c5 ff ff ff       	call   f0105342 <strcpy>
	return dst;
}
f010537d:	89 d8                	mov    %ebx,%eax
f010537f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105382:	c9                   	leave  
f0105383:	c3                   	ret    

f0105384 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105384:	55                   	push   %ebp
f0105385:	89 e5                	mov    %esp,%ebp
f0105387:	56                   	push   %esi
f0105388:	53                   	push   %ebx
f0105389:	8b 75 08             	mov    0x8(%ebp),%esi
f010538c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010538f:	89 f3                	mov    %esi,%ebx
f0105391:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105394:	89 f2                	mov    %esi,%edx
f0105396:	eb 0f                	jmp    f01053a7 <strncpy+0x23>
		*dst++ = *src;
f0105398:	83 c2 01             	add    $0x1,%edx
f010539b:	0f b6 01             	movzbl (%ecx),%eax
f010539e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01053a1:	80 39 01             	cmpb   $0x1,(%ecx)
f01053a4:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01053a7:	39 da                	cmp    %ebx,%edx
f01053a9:	75 ed                	jne    f0105398 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01053ab:	89 f0                	mov    %esi,%eax
f01053ad:	5b                   	pop    %ebx
f01053ae:	5e                   	pop    %esi
f01053af:	5d                   	pop    %ebp
f01053b0:	c3                   	ret    

f01053b1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01053b1:	55                   	push   %ebp
f01053b2:	89 e5                	mov    %esp,%ebp
f01053b4:	56                   	push   %esi
f01053b5:	53                   	push   %ebx
f01053b6:	8b 75 08             	mov    0x8(%ebp),%esi
f01053b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01053bc:	8b 55 10             	mov    0x10(%ebp),%edx
f01053bf:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01053c1:	85 d2                	test   %edx,%edx
f01053c3:	74 21                	je     f01053e6 <strlcpy+0x35>
f01053c5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f01053c9:	89 f2                	mov    %esi,%edx
f01053cb:	eb 09                	jmp    f01053d6 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01053cd:	83 c2 01             	add    $0x1,%edx
f01053d0:	83 c1 01             	add    $0x1,%ecx
f01053d3:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01053d6:	39 c2                	cmp    %eax,%edx
f01053d8:	74 09                	je     f01053e3 <strlcpy+0x32>
f01053da:	0f b6 19             	movzbl (%ecx),%ebx
f01053dd:	84 db                	test   %bl,%bl
f01053df:	75 ec                	jne    f01053cd <strlcpy+0x1c>
f01053e1:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f01053e3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01053e6:	29 f0                	sub    %esi,%eax
}
f01053e8:	5b                   	pop    %ebx
f01053e9:	5e                   	pop    %esi
f01053ea:	5d                   	pop    %ebp
f01053eb:	c3                   	ret    

f01053ec <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01053ec:	55                   	push   %ebp
f01053ed:	89 e5                	mov    %esp,%ebp
f01053ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01053f2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01053f5:	eb 06                	jmp    f01053fd <strcmp+0x11>
		p++, q++;
f01053f7:	83 c1 01             	add    $0x1,%ecx
f01053fa:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01053fd:	0f b6 01             	movzbl (%ecx),%eax
f0105400:	84 c0                	test   %al,%al
f0105402:	74 04                	je     f0105408 <strcmp+0x1c>
f0105404:	3a 02                	cmp    (%edx),%al
f0105406:	74 ef                	je     f01053f7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105408:	0f b6 c0             	movzbl %al,%eax
f010540b:	0f b6 12             	movzbl (%edx),%edx
f010540e:	29 d0                	sub    %edx,%eax
}
f0105410:	5d                   	pop    %ebp
f0105411:	c3                   	ret    

f0105412 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105412:	55                   	push   %ebp
f0105413:	89 e5                	mov    %esp,%ebp
f0105415:	53                   	push   %ebx
f0105416:	8b 45 08             	mov    0x8(%ebp),%eax
f0105419:	8b 55 0c             	mov    0xc(%ebp),%edx
f010541c:	89 c3                	mov    %eax,%ebx
f010541e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105421:	eb 06                	jmp    f0105429 <strncmp+0x17>
		n--, p++, q++;
f0105423:	83 c0 01             	add    $0x1,%eax
f0105426:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105429:	39 d8                	cmp    %ebx,%eax
f010542b:	74 15                	je     f0105442 <strncmp+0x30>
f010542d:	0f b6 08             	movzbl (%eax),%ecx
f0105430:	84 c9                	test   %cl,%cl
f0105432:	74 04                	je     f0105438 <strncmp+0x26>
f0105434:	3a 0a                	cmp    (%edx),%cl
f0105436:	74 eb                	je     f0105423 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105438:	0f b6 00             	movzbl (%eax),%eax
f010543b:	0f b6 12             	movzbl (%edx),%edx
f010543e:	29 d0                	sub    %edx,%eax
f0105440:	eb 05                	jmp    f0105447 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105442:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105447:	5b                   	pop    %ebx
f0105448:	5d                   	pop    %ebp
f0105449:	c3                   	ret    

f010544a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010544a:	55                   	push   %ebp
f010544b:	89 e5                	mov    %esp,%ebp
f010544d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105450:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105454:	eb 07                	jmp    f010545d <strchr+0x13>
		if (*s == c)
f0105456:	38 ca                	cmp    %cl,%dl
f0105458:	74 0f                	je     f0105469 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010545a:	83 c0 01             	add    $0x1,%eax
f010545d:	0f b6 10             	movzbl (%eax),%edx
f0105460:	84 d2                	test   %dl,%dl
f0105462:	75 f2                	jne    f0105456 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0105464:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105469:	5d                   	pop    %ebp
f010546a:	c3                   	ret    

f010546b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010546b:	55                   	push   %ebp
f010546c:	89 e5                	mov    %esp,%ebp
f010546e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105471:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105475:	eb 03                	jmp    f010547a <strfind+0xf>
f0105477:	83 c0 01             	add    $0x1,%eax
f010547a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010547d:	38 ca                	cmp    %cl,%dl
f010547f:	74 04                	je     f0105485 <strfind+0x1a>
f0105481:	84 d2                	test   %dl,%dl
f0105483:	75 f2                	jne    f0105477 <strfind+0xc>
			break;
	return (char *) s;
}
f0105485:	5d                   	pop    %ebp
f0105486:	c3                   	ret    

f0105487 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105487:	55                   	push   %ebp
f0105488:	89 e5                	mov    %esp,%ebp
f010548a:	57                   	push   %edi
f010548b:	56                   	push   %esi
f010548c:	53                   	push   %ebx
f010548d:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105490:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105493:	85 c9                	test   %ecx,%ecx
f0105495:	74 36                	je     f01054cd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105497:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010549d:	75 28                	jne    f01054c7 <memset+0x40>
f010549f:	f6 c1 03             	test   $0x3,%cl
f01054a2:	75 23                	jne    f01054c7 <memset+0x40>
		c &= 0xFF;
f01054a4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01054a8:	89 d3                	mov    %edx,%ebx
f01054aa:	c1 e3 08             	shl    $0x8,%ebx
f01054ad:	89 d6                	mov    %edx,%esi
f01054af:	c1 e6 18             	shl    $0x18,%esi
f01054b2:	89 d0                	mov    %edx,%eax
f01054b4:	c1 e0 10             	shl    $0x10,%eax
f01054b7:	09 f0                	or     %esi,%eax
f01054b9:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f01054bb:	89 d8                	mov    %ebx,%eax
f01054bd:	09 d0                	or     %edx,%eax
f01054bf:	c1 e9 02             	shr    $0x2,%ecx
f01054c2:	fc                   	cld    
f01054c3:	f3 ab                	rep stos %eax,%es:(%edi)
f01054c5:	eb 06                	jmp    f01054cd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01054c7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01054ca:	fc                   	cld    
f01054cb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01054cd:	89 f8                	mov    %edi,%eax
f01054cf:	5b                   	pop    %ebx
f01054d0:	5e                   	pop    %esi
f01054d1:	5f                   	pop    %edi
f01054d2:	5d                   	pop    %ebp
f01054d3:	c3                   	ret    

f01054d4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01054d4:	55                   	push   %ebp
f01054d5:	89 e5                	mov    %esp,%ebp
f01054d7:	57                   	push   %edi
f01054d8:	56                   	push   %esi
f01054d9:	8b 45 08             	mov    0x8(%ebp),%eax
f01054dc:	8b 75 0c             	mov    0xc(%ebp),%esi
f01054df:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01054e2:	39 c6                	cmp    %eax,%esi
f01054e4:	73 35                	jae    f010551b <memmove+0x47>
f01054e6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01054e9:	39 d0                	cmp    %edx,%eax
f01054eb:	73 2e                	jae    f010551b <memmove+0x47>
		s += n;
		d += n;
f01054ed:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01054f0:	89 d6                	mov    %edx,%esi
f01054f2:	09 fe                	or     %edi,%esi
f01054f4:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01054fa:	75 13                	jne    f010550f <memmove+0x3b>
f01054fc:	f6 c1 03             	test   $0x3,%cl
f01054ff:	75 0e                	jne    f010550f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0105501:	83 ef 04             	sub    $0x4,%edi
f0105504:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105507:	c1 e9 02             	shr    $0x2,%ecx
f010550a:	fd                   	std    
f010550b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010550d:	eb 09                	jmp    f0105518 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f010550f:	83 ef 01             	sub    $0x1,%edi
f0105512:	8d 72 ff             	lea    -0x1(%edx),%esi
f0105515:	fd                   	std    
f0105516:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105518:	fc                   	cld    
f0105519:	eb 1d                	jmp    f0105538 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010551b:	89 f2                	mov    %esi,%edx
f010551d:	09 c2                	or     %eax,%edx
f010551f:	f6 c2 03             	test   $0x3,%dl
f0105522:	75 0f                	jne    f0105533 <memmove+0x5f>
f0105524:	f6 c1 03             	test   $0x3,%cl
f0105527:	75 0a                	jne    f0105533 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0105529:	c1 e9 02             	shr    $0x2,%ecx
f010552c:	89 c7                	mov    %eax,%edi
f010552e:	fc                   	cld    
f010552f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105531:	eb 05                	jmp    f0105538 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105533:	89 c7                	mov    %eax,%edi
f0105535:	fc                   	cld    
f0105536:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105538:	5e                   	pop    %esi
f0105539:	5f                   	pop    %edi
f010553a:	5d                   	pop    %ebp
f010553b:	c3                   	ret    

f010553c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010553c:	55                   	push   %ebp
f010553d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010553f:	ff 75 10             	pushl  0x10(%ebp)
f0105542:	ff 75 0c             	pushl  0xc(%ebp)
f0105545:	ff 75 08             	pushl  0x8(%ebp)
f0105548:	e8 87 ff ff ff       	call   f01054d4 <memmove>
}
f010554d:	c9                   	leave  
f010554e:	c3                   	ret    

f010554f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010554f:	55                   	push   %ebp
f0105550:	89 e5                	mov    %esp,%ebp
f0105552:	56                   	push   %esi
f0105553:	53                   	push   %ebx
f0105554:	8b 45 08             	mov    0x8(%ebp),%eax
f0105557:	8b 55 0c             	mov    0xc(%ebp),%edx
f010555a:	89 c6                	mov    %eax,%esi
f010555c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010555f:	eb 1a                	jmp    f010557b <memcmp+0x2c>
		if (*s1 != *s2)
f0105561:	0f b6 08             	movzbl (%eax),%ecx
f0105564:	0f b6 1a             	movzbl (%edx),%ebx
f0105567:	38 d9                	cmp    %bl,%cl
f0105569:	74 0a                	je     f0105575 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f010556b:	0f b6 c1             	movzbl %cl,%eax
f010556e:	0f b6 db             	movzbl %bl,%ebx
f0105571:	29 d8                	sub    %ebx,%eax
f0105573:	eb 0f                	jmp    f0105584 <memcmp+0x35>
		s1++, s2++;
f0105575:	83 c0 01             	add    $0x1,%eax
f0105578:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010557b:	39 f0                	cmp    %esi,%eax
f010557d:	75 e2                	jne    f0105561 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010557f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105584:	5b                   	pop    %ebx
f0105585:	5e                   	pop    %esi
f0105586:	5d                   	pop    %ebp
f0105587:	c3                   	ret    

f0105588 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105588:	55                   	push   %ebp
f0105589:	89 e5                	mov    %esp,%ebp
f010558b:	53                   	push   %ebx
f010558c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010558f:	89 c1                	mov    %eax,%ecx
f0105591:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0105594:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105598:	eb 0a                	jmp    f01055a4 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f010559a:	0f b6 10             	movzbl (%eax),%edx
f010559d:	39 da                	cmp    %ebx,%edx
f010559f:	74 07                	je     f01055a8 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01055a1:	83 c0 01             	add    $0x1,%eax
f01055a4:	39 c8                	cmp    %ecx,%eax
f01055a6:	72 f2                	jb     f010559a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01055a8:	5b                   	pop    %ebx
f01055a9:	5d                   	pop    %ebp
f01055aa:	c3                   	ret    

f01055ab <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01055ab:	55                   	push   %ebp
f01055ac:	89 e5                	mov    %esp,%ebp
f01055ae:	57                   	push   %edi
f01055af:	56                   	push   %esi
f01055b0:	53                   	push   %ebx
f01055b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01055b4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01055b7:	eb 03                	jmp    f01055bc <strtol+0x11>
		s++;
f01055b9:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01055bc:	0f b6 01             	movzbl (%ecx),%eax
f01055bf:	3c 20                	cmp    $0x20,%al
f01055c1:	74 f6                	je     f01055b9 <strtol+0xe>
f01055c3:	3c 09                	cmp    $0x9,%al
f01055c5:	74 f2                	je     f01055b9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01055c7:	3c 2b                	cmp    $0x2b,%al
f01055c9:	75 0a                	jne    f01055d5 <strtol+0x2a>
		s++;
f01055cb:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01055ce:	bf 00 00 00 00       	mov    $0x0,%edi
f01055d3:	eb 11                	jmp    f01055e6 <strtol+0x3b>
f01055d5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01055da:	3c 2d                	cmp    $0x2d,%al
f01055dc:	75 08                	jne    f01055e6 <strtol+0x3b>
		s++, neg = 1;
f01055de:	83 c1 01             	add    $0x1,%ecx
f01055e1:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01055e6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01055ec:	75 15                	jne    f0105603 <strtol+0x58>
f01055ee:	80 39 30             	cmpb   $0x30,(%ecx)
f01055f1:	75 10                	jne    f0105603 <strtol+0x58>
f01055f3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01055f7:	75 7c                	jne    f0105675 <strtol+0xca>
		s += 2, base = 16;
f01055f9:	83 c1 02             	add    $0x2,%ecx
f01055fc:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105601:	eb 16                	jmp    f0105619 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0105603:	85 db                	test   %ebx,%ebx
f0105605:	75 12                	jne    f0105619 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105607:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010560c:	80 39 30             	cmpb   $0x30,(%ecx)
f010560f:	75 08                	jne    f0105619 <strtol+0x6e>
		s++, base = 8;
f0105611:	83 c1 01             	add    $0x1,%ecx
f0105614:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0105619:	b8 00 00 00 00       	mov    $0x0,%eax
f010561e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105621:	0f b6 11             	movzbl (%ecx),%edx
f0105624:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105627:	89 f3                	mov    %esi,%ebx
f0105629:	80 fb 09             	cmp    $0x9,%bl
f010562c:	77 08                	ja     f0105636 <strtol+0x8b>
			dig = *s - '0';
f010562e:	0f be d2             	movsbl %dl,%edx
f0105631:	83 ea 30             	sub    $0x30,%edx
f0105634:	eb 22                	jmp    f0105658 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0105636:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105639:	89 f3                	mov    %esi,%ebx
f010563b:	80 fb 19             	cmp    $0x19,%bl
f010563e:	77 08                	ja     f0105648 <strtol+0x9d>
			dig = *s - 'a' + 10;
f0105640:	0f be d2             	movsbl %dl,%edx
f0105643:	83 ea 57             	sub    $0x57,%edx
f0105646:	eb 10                	jmp    f0105658 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0105648:	8d 72 bf             	lea    -0x41(%edx),%esi
f010564b:	89 f3                	mov    %esi,%ebx
f010564d:	80 fb 19             	cmp    $0x19,%bl
f0105650:	77 16                	ja     f0105668 <strtol+0xbd>
			dig = *s - 'A' + 10;
f0105652:	0f be d2             	movsbl %dl,%edx
f0105655:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0105658:	3b 55 10             	cmp    0x10(%ebp),%edx
f010565b:	7d 0b                	jge    f0105668 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f010565d:	83 c1 01             	add    $0x1,%ecx
f0105660:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105664:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0105666:	eb b9                	jmp    f0105621 <strtol+0x76>

	if (endptr)
f0105668:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010566c:	74 0d                	je     f010567b <strtol+0xd0>
		*endptr = (char *) s;
f010566e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105671:	89 0e                	mov    %ecx,(%esi)
f0105673:	eb 06                	jmp    f010567b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105675:	85 db                	test   %ebx,%ebx
f0105677:	74 98                	je     f0105611 <strtol+0x66>
f0105679:	eb 9e                	jmp    f0105619 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f010567b:	89 c2                	mov    %eax,%edx
f010567d:	f7 da                	neg    %edx
f010567f:	85 ff                	test   %edi,%edi
f0105681:	0f 45 c2             	cmovne %edx,%eax
}
f0105684:	5b                   	pop    %ebx
f0105685:	5e                   	pop    %esi
f0105686:	5f                   	pop    %edi
f0105687:	5d                   	pop    %ebp
f0105688:	c3                   	ret    
f0105689:	66 90                	xchg   %ax,%ax
f010568b:	90                   	nop

f010568c <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f010568c:	fa                   	cli    

	xorw    %ax, %ax
f010568d:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f010568f:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105691:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105693:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105695:	0f 01 16             	lgdtl  (%esi)
f0105698:	74 70                	je     f010570a <mpsearch1+0x3>
	movl    %cr0, %eax
f010569a:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f010569d:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f01056a1:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f01056a4:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f01056aa:	08 00                	or     %al,(%eax)

f01056ac <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f01056ac:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f01056b0:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01056b2:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01056b4:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f01056b6:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f01056ba:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f01056bc:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f01056be:	b8 00 e0 11 00       	mov    $0x11e000,%eax
	movl    %eax, %cr3
f01056c3:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f01056c6:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f01056c9:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f01056ce:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f01056d1:	8b 25 84 fe 22 f0    	mov    0xf022fe84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f01056d7:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f01056dc:	b8 9c 01 10 f0       	mov    $0xf010019c,%eax
	call    *%eax
f01056e1:	ff d0                	call   *%eax

f01056e3 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f01056e3:	eb fe                	jmp    f01056e3 <spin>
f01056e5:	8d 76 00             	lea    0x0(%esi),%esi

f01056e8 <gdt>:
	...
f01056f0:	ff                   	(bad)  
f01056f1:	ff 00                	incl   (%eax)
f01056f3:	00 00                	add    %al,(%eax)
f01056f5:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f01056fc:	00                   	.byte 0x0
f01056fd:	92                   	xchg   %eax,%edx
f01056fe:	cf                   	iret   
	...

f0105700 <gdtdesc>:
f0105700:	17                   	pop    %ss
f0105701:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105706 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105706:	90                   	nop

f0105707 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105707:	55                   	push   %ebp
f0105708:	89 e5                	mov    %esp,%ebp
f010570a:	57                   	push   %edi
f010570b:	56                   	push   %esi
f010570c:	53                   	push   %ebx
f010570d:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105710:	8b 0d 88 fe 22 f0    	mov    0xf022fe88,%ecx
f0105716:	89 c3                	mov    %eax,%ebx
f0105718:	c1 eb 0c             	shr    $0xc,%ebx
f010571b:	39 cb                	cmp    %ecx,%ebx
f010571d:	72 12                	jb     f0105731 <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010571f:	50                   	push   %eax
f0105720:	68 64 61 10 f0       	push   $0xf0106164
f0105725:	6a 57                	push   $0x57
f0105727:	68 21 7e 10 f0       	push   $0xf0107e21
f010572c:	e8 0f a9 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105731:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105737:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105739:	89 c2                	mov    %eax,%edx
f010573b:	c1 ea 0c             	shr    $0xc,%edx
f010573e:	39 ca                	cmp    %ecx,%edx
f0105740:	72 12                	jb     f0105754 <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105742:	50                   	push   %eax
f0105743:	68 64 61 10 f0       	push   $0xf0106164
f0105748:	6a 57                	push   $0x57
f010574a:	68 21 7e 10 f0       	push   $0xf0107e21
f010574f:	e8 ec a8 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105754:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f010575a:	eb 2f                	jmp    f010578b <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f010575c:	83 ec 04             	sub    $0x4,%esp
f010575f:	6a 04                	push   $0x4
f0105761:	68 31 7e 10 f0       	push   $0xf0107e31
f0105766:	53                   	push   %ebx
f0105767:	e8 e3 fd ff ff       	call   f010554f <memcmp>
f010576c:	83 c4 10             	add    $0x10,%esp
f010576f:	85 c0                	test   %eax,%eax
f0105771:	75 15                	jne    f0105788 <mpsearch1+0x81>
f0105773:	89 da                	mov    %ebx,%edx
f0105775:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f0105778:	0f b6 0a             	movzbl (%edx),%ecx
f010577b:	01 c8                	add    %ecx,%eax
f010577d:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105780:	39 d7                	cmp    %edx,%edi
f0105782:	75 f4                	jne    f0105778 <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105784:	84 c0                	test   %al,%al
f0105786:	74 0e                	je     f0105796 <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0105788:	83 c3 10             	add    $0x10,%ebx
f010578b:	39 f3                	cmp    %esi,%ebx
f010578d:	72 cd                	jb     f010575c <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f010578f:	b8 00 00 00 00       	mov    $0x0,%eax
f0105794:	eb 02                	jmp    f0105798 <mpsearch1+0x91>
f0105796:	89 d8                	mov    %ebx,%eax
}
f0105798:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010579b:	5b                   	pop    %ebx
f010579c:	5e                   	pop    %esi
f010579d:	5f                   	pop    %edi
f010579e:	5d                   	pop    %ebp
f010579f:	c3                   	ret    

f01057a0 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f01057a0:	55                   	push   %ebp
f01057a1:	89 e5                	mov    %esp,%ebp
f01057a3:	57                   	push   %edi
f01057a4:	56                   	push   %esi
f01057a5:	53                   	push   %ebx
f01057a6:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f01057a9:	c7 05 c0 03 23 f0 20 	movl   $0xf0230020,0xf02303c0
f01057b0:	00 23 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01057b3:	83 3d 88 fe 22 f0 00 	cmpl   $0x0,0xf022fe88
f01057ba:	75 16                	jne    f01057d2 <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01057bc:	68 00 04 00 00       	push   $0x400
f01057c1:	68 64 61 10 f0       	push   $0xf0106164
f01057c6:	6a 6f                	push   $0x6f
f01057c8:	68 21 7e 10 f0       	push   $0xf0107e21
f01057cd:	e8 6e a8 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f01057d2:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f01057d9:	85 c0                	test   %eax,%eax
f01057db:	74 16                	je     f01057f3 <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f01057dd:	c1 e0 04             	shl    $0x4,%eax
f01057e0:	ba 00 04 00 00       	mov    $0x400,%edx
f01057e5:	e8 1d ff ff ff       	call   f0105707 <mpsearch1>
f01057ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01057ed:	85 c0                	test   %eax,%eax
f01057ef:	75 3c                	jne    f010582d <mp_init+0x8d>
f01057f1:	eb 20                	jmp    f0105813 <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f01057f3:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f01057fa:	c1 e0 0a             	shl    $0xa,%eax
f01057fd:	2d 00 04 00 00       	sub    $0x400,%eax
f0105802:	ba 00 04 00 00       	mov    $0x400,%edx
f0105807:	e8 fb fe ff ff       	call   f0105707 <mpsearch1>
f010580c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010580f:	85 c0                	test   %eax,%eax
f0105811:	75 1a                	jne    f010582d <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0105813:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105818:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f010581d:	e8 e5 fe ff ff       	call   f0105707 <mpsearch1>
f0105822:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0105825:	85 c0                	test   %eax,%eax
f0105827:	0f 84 5d 02 00 00    	je     f0105a8a <mp_init+0x2ea>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f010582d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105830:	8b 70 04             	mov    0x4(%eax),%esi
f0105833:	85 f6                	test   %esi,%esi
f0105835:	74 06                	je     f010583d <mp_init+0x9d>
f0105837:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f010583b:	74 15                	je     f0105852 <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f010583d:	83 ec 0c             	sub    $0xc,%esp
f0105840:	68 94 7c 10 f0       	push   $0xf0107c94
f0105845:	e8 5e e0 ff ff       	call   f01038a8 <cprintf>
f010584a:	83 c4 10             	add    $0x10,%esp
f010584d:	e9 38 02 00 00       	jmp    f0105a8a <mp_init+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105852:	89 f0                	mov    %esi,%eax
f0105854:	c1 e8 0c             	shr    $0xc,%eax
f0105857:	3b 05 88 fe 22 f0    	cmp    0xf022fe88,%eax
f010585d:	72 15                	jb     f0105874 <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010585f:	56                   	push   %esi
f0105860:	68 64 61 10 f0       	push   $0xf0106164
f0105865:	68 90 00 00 00       	push   $0x90
f010586a:	68 21 7e 10 f0       	push   $0xf0107e21
f010586f:	e8 cc a7 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105874:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f010587a:	83 ec 04             	sub    $0x4,%esp
f010587d:	6a 04                	push   $0x4
f010587f:	68 36 7e 10 f0       	push   $0xf0107e36
f0105884:	53                   	push   %ebx
f0105885:	e8 c5 fc ff ff       	call   f010554f <memcmp>
f010588a:	83 c4 10             	add    $0x10,%esp
f010588d:	85 c0                	test   %eax,%eax
f010588f:	74 15                	je     f01058a6 <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105891:	83 ec 0c             	sub    $0xc,%esp
f0105894:	68 c4 7c 10 f0       	push   $0xf0107cc4
f0105899:	e8 0a e0 ff ff       	call   f01038a8 <cprintf>
f010589e:	83 c4 10             	add    $0x10,%esp
f01058a1:	e9 e4 01 00 00       	jmp    f0105a8a <mp_init+0x2ea>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01058a6:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f01058aa:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f01058ae:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f01058b1:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f01058b6:	b8 00 00 00 00       	mov    $0x0,%eax
f01058bb:	eb 0d                	jmp    f01058ca <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f01058bd:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f01058c4:	f0 
f01058c5:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01058c7:	83 c0 01             	add    $0x1,%eax
f01058ca:	39 c7                	cmp    %eax,%edi
f01058cc:	75 ef                	jne    f01058bd <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01058ce:	84 d2                	test   %dl,%dl
f01058d0:	74 15                	je     f01058e7 <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f01058d2:	83 ec 0c             	sub    $0xc,%esp
f01058d5:	68 f8 7c 10 f0       	push   $0xf0107cf8
f01058da:	e8 c9 df ff ff       	call   f01038a8 <cprintf>
f01058df:	83 c4 10             	add    $0x10,%esp
f01058e2:	e9 a3 01 00 00       	jmp    f0105a8a <mp_init+0x2ea>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f01058e7:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f01058eb:	3c 01                	cmp    $0x1,%al
f01058ed:	74 1d                	je     f010590c <mp_init+0x16c>
f01058ef:	3c 04                	cmp    $0x4,%al
f01058f1:	74 19                	je     f010590c <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f01058f3:	83 ec 08             	sub    $0x8,%esp
f01058f6:	0f b6 c0             	movzbl %al,%eax
f01058f9:	50                   	push   %eax
f01058fa:	68 1c 7d 10 f0       	push   $0xf0107d1c
f01058ff:	e8 a4 df ff ff       	call   f01038a8 <cprintf>
f0105904:	83 c4 10             	add    $0x10,%esp
f0105907:	e9 7e 01 00 00       	jmp    f0105a8a <mp_init+0x2ea>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f010590c:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f0105910:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105914:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105919:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f010591e:	01 ce                	add    %ecx,%esi
f0105920:	eb 0d                	jmp    f010592f <mp_init+0x18f>
f0105922:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f0105929:	f0 
f010592a:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f010592c:	83 c0 01             	add    $0x1,%eax
f010592f:	39 c7                	cmp    %eax,%edi
f0105931:	75 ef                	jne    f0105922 <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105933:	89 d0                	mov    %edx,%eax
f0105935:	02 43 2a             	add    0x2a(%ebx),%al
f0105938:	74 15                	je     f010594f <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f010593a:	83 ec 0c             	sub    $0xc,%esp
f010593d:	68 3c 7d 10 f0       	push   $0xf0107d3c
f0105942:	e8 61 df ff ff       	call   f01038a8 <cprintf>
f0105947:	83 c4 10             	add    $0x10,%esp
f010594a:	e9 3b 01 00 00       	jmp    f0105a8a <mp_init+0x2ea>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f010594f:	85 db                	test   %ebx,%ebx
f0105951:	0f 84 33 01 00 00    	je     f0105a8a <mp_init+0x2ea>
		return;
	ismp = 1;
f0105957:	c7 05 00 00 23 f0 01 	movl   $0x1,0xf0230000
f010595e:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105961:	8b 43 24             	mov    0x24(%ebx),%eax
f0105964:	a3 00 10 27 f0       	mov    %eax,0xf0271000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105969:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f010596c:	be 00 00 00 00       	mov    $0x0,%esi
f0105971:	e9 85 00 00 00       	jmp    f01059fb <mp_init+0x25b>
		switch (*p) {
f0105976:	0f b6 07             	movzbl (%edi),%eax
f0105979:	84 c0                	test   %al,%al
f010597b:	74 06                	je     f0105983 <mp_init+0x1e3>
f010597d:	3c 04                	cmp    $0x4,%al
f010597f:	77 55                	ja     f01059d6 <mp_init+0x236>
f0105981:	eb 4e                	jmp    f01059d1 <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105983:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105987:	74 11                	je     f010599a <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f0105989:	6b 05 c4 03 23 f0 74 	imul   $0x74,0xf02303c4,%eax
f0105990:	05 20 00 23 f0       	add    $0xf0230020,%eax
f0105995:	a3 c0 03 23 f0       	mov    %eax,0xf02303c0
			if (ncpu < NCPU) {
f010599a:	a1 c4 03 23 f0       	mov    0xf02303c4,%eax
f010599f:	83 f8 07             	cmp    $0x7,%eax
f01059a2:	7f 13                	jg     f01059b7 <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f01059a4:	6b d0 74             	imul   $0x74,%eax,%edx
f01059a7:	88 82 20 00 23 f0    	mov    %al,-0xfdcffe0(%edx)
				ncpu++;
f01059ad:	83 c0 01             	add    $0x1,%eax
f01059b0:	a3 c4 03 23 f0       	mov    %eax,0xf02303c4
f01059b5:	eb 15                	jmp    f01059cc <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f01059b7:	83 ec 08             	sub    $0x8,%esp
f01059ba:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f01059be:	50                   	push   %eax
f01059bf:	68 6c 7d 10 f0       	push   $0xf0107d6c
f01059c4:	e8 df de ff ff       	call   f01038a8 <cprintf>
f01059c9:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f01059cc:	83 c7 14             	add    $0x14,%edi
			continue;
f01059cf:	eb 27                	jmp    f01059f8 <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f01059d1:	83 c7 08             	add    $0x8,%edi
			continue;
f01059d4:	eb 22                	jmp    f01059f8 <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f01059d6:	83 ec 08             	sub    $0x8,%esp
f01059d9:	0f b6 c0             	movzbl %al,%eax
f01059dc:	50                   	push   %eax
f01059dd:	68 94 7d 10 f0       	push   $0xf0107d94
f01059e2:	e8 c1 de ff ff       	call   f01038a8 <cprintf>
			ismp = 0;
f01059e7:	c7 05 00 00 23 f0 00 	movl   $0x0,0xf0230000
f01059ee:	00 00 00 
			i = conf->entry;
f01059f1:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f01059f5:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01059f8:	83 c6 01             	add    $0x1,%esi
f01059fb:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f01059ff:	39 c6                	cmp    %eax,%esi
f0105a01:	0f 82 6f ff ff ff    	jb     f0105976 <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105a07:	a1 c0 03 23 f0       	mov    0xf02303c0,%eax
f0105a0c:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105a13:	83 3d 00 00 23 f0 00 	cmpl   $0x0,0xf0230000
f0105a1a:	75 26                	jne    f0105a42 <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105a1c:	c7 05 c4 03 23 f0 01 	movl   $0x1,0xf02303c4
f0105a23:	00 00 00 
		lapicaddr = 0;
f0105a26:	c7 05 00 10 27 f0 00 	movl   $0x0,0xf0271000
f0105a2d:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105a30:	83 ec 0c             	sub    $0xc,%esp
f0105a33:	68 b4 7d 10 f0       	push   $0xf0107db4
f0105a38:	e8 6b de ff ff       	call   f01038a8 <cprintf>
		return;
f0105a3d:	83 c4 10             	add    $0x10,%esp
f0105a40:	eb 48                	jmp    f0105a8a <mp_init+0x2ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105a42:	83 ec 04             	sub    $0x4,%esp
f0105a45:	ff 35 c4 03 23 f0    	pushl  0xf02303c4
f0105a4b:	0f b6 00             	movzbl (%eax),%eax
f0105a4e:	50                   	push   %eax
f0105a4f:	68 3b 7e 10 f0       	push   $0xf0107e3b
f0105a54:	e8 4f de ff ff       	call   f01038a8 <cprintf>

	if (mp->imcrp) {
f0105a59:	83 c4 10             	add    $0x10,%esp
f0105a5c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105a5f:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105a63:	74 25                	je     f0105a8a <mp_init+0x2ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105a65:	83 ec 0c             	sub    $0xc,%esp
f0105a68:	68 e0 7d 10 f0       	push   $0xf0107de0
f0105a6d:	e8 36 de ff ff       	call   f01038a8 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105a72:	ba 22 00 00 00       	mov    $0x22,%edx
f0105a77:	b8 70 00 00 00       	mov    $0x70,%eax
f0105a7c:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105a7d:	ba 23 00 00 00       	mov    $0x23,%edx
f0105a82:	ec                   	in     (%dx),%al
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105a83:	83 c8 01             	or     $0x1,%eax
f0105a86:	ee                   	out    %al,(%dx)
f0105a87:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105a8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105a8d:	5b                   	pop    %ebx
f0105a8e:	5e                   	pop    %esi
f0105a8f:	5f                   	pop    %edi
f0105a90:	5d                   	pop    %ebp
f0105a91:	c3                   	ret    

f0105a92 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105a92:	55                   	push   %ebp
f0105a93:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105a95:	8b 0d 04 10 27 f0    	mov    0xf0271004,%ecx
f0105a9b:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105a9e:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105aa0:	a1 04 10 27 f0       	mov    0xf0271004,%eax
f0105aa5:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105aa8:	5d                   	pop    %ebp
f0105aa9:	c3                   	ret    

f0105aaa <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105aaa:	55                   	push   %ebp
f0105aab:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105aad:	a1 04 10 27 f0       	mov    0xf0271004,%eax
f0105ab2:	85 c0                	test   %eax,%eax
f0105ab4:	74 08                	je     f0105abe <cpunum+0x14>
		return lapic[ID] >> 24;
f0105ab6:	8b 40 20             	mov    0x20(%eax),%eax
f0105ab9:	c1 e8 18             	shr    $0x18,%eax
f0105abc:	eb 05                	jmp    f0105ac3 <cpunum+0x19>
	return 0;
f0105abe:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105ac3:	5d                   	pop    %ebp
f0105ac4:	c3                   	ret    

f0105ac5 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0105ac5:	a1 00 10 27 f0       	mov    0xf0271000,%eax
f0105aca:	85 c0                	test   %eax,%eax
f0105acc:	0f 84 21 01 00 00    	je     f0105bf3 <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0105ad2:	55                   	push   %ebp
f0105ad3:	89 e5                	mov    %esp,%ebp
f0105ad5:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0105ad8:	68 00 10 00 00       	push   $0x1000
f0105add:	50                   	push   %eax
f0105ade:	e8 35 b9 ff ff       	call   f0101418 <mmio_map_region>
f0105ae3:	a3 04 10 27 f0       	mov    %eax,0xf0271004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105ae8:	ba 27 01 00 00       	mov    $0x127,%edx
f0105aed:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105af2:	e8 9b ff ff ff       	call   f0105a92 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0105af7:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105afc:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105b01:	e8 8c ff ff ff       	call   f0105a92 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105b06:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105b0b:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105b10:	e8 7d ff ff ff       	call   f0105a92 <lapicw>
	lapicw(TICR, 10000000); 
f0105b15:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105b1a:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105b1f:	e8 6e ff ff ff       	call   f0105a92 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0105b24:	e8 81 ff ff ff       	call   f0105aaa <cpunum>
f0105b29:	6b c0 74             	imul   $0x74,%eax,%eax
f0105b2c:	05 20 00 23 f0       	add    $0xf0230020,%eax
f0105b31:	83 c4 10             	add    $0x10,%esp
f0105b34:	39 05 c0 03 23 f0    	cmp    %eax,0xf02303c0
f0105b3a:	74 0f                	je     f0105b4b <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f0105b3c:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105b41:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105b46:	e8 47 ff ff ff       	call   f0105a92 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0105b4b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105b50:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105b55:	e8 38 ff ff ff       	call   f0105a92 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105b5a:	a1 04 10 27 f0       	mov    0xf0271004,%eax
f0105b5f:	8b 40 30             	mov    0x30(%eax),%eax
f0105b62:	c1 e8 10             	shr    $0x10,%eax
f0105b65:	3c 03                	cmp    $0x3,%al
f0105b67:	76 0f                	jbe    f0105b78 <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f0105b69:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105b6e:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105b73:	e8 1a ff ff ff       	call   f0105a92 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105b78:	ba 33 00 00 00       	mov    $0x33,%edx
f0105b7d:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105b82:	e8 0b ff ff ff       	call   f0105a92 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0105b87:	ba 00 00 00 00       	mov    $0x0,%edx
f0105b8c:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105b91:	e8 fc fe ff ff       	call   f0105a92 <lapicw>
	lapicw(ESR, 0);
f0105b96:	ba 00 00 00 00       	mov    $0x0,%edx
f0105b9b:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105ba0:	e8 ed fe ff ff       	call   f0105a92 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0105ba5:	ba 00 00 00 00       	mov    $0x0,%edx
f0105baa:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105baf:	e8 de fe ff ff       	call   f0105a92 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0105bb4:	ba 00 00 00 00       	mov    $0x0,%edx
f0105bb9:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105bbe:	e8 cf fe ff ff       	call   f0105a92 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105bc3:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105bc8:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105bcd:	e8 c0 fe ff ff       	call   f0105a92 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105bd2:	8b 15 04 10 27 f0    	mov    0xf0271004,%edx
f0105bd8:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105bde:	f6 c4 10             	test   $0x10,%ah
f0105be1:	75 f5                	jne    f0105bd8 <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0105be3:	ba 00 00 00 00       	mov    $0x0,%edx
f0105be8:	b8 20 00 00 00       	mov    $0x20,%eax
f0105bed:	e8 a0 fe ff ff       	call   f0105a92 <lapicw>
}
f0105bf2:	c9                   	leave  
f0105bf3:	f3 c3                	repz ret 

f0105bf5 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105bf5:	83 3d 04 10 27 f0 00 	cmpl   $0x0,0xf0271004
f0105bfc:	74 13                	je     f0105c11 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105bfe:	55                   	push   %ebp
f0105bff:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0105c01:	ba 00 00 00 00       	mov    $0x0,%edx
f0105c06:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105c0b:	e8 82 fe ff ff       	call   f0105a92 <lapicw>
}
f0105c10:	5d                   	pop    %ebp
f0105c11:	f3 c3                	repz ret 

f0105c13 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105c13:	55                   	push   %ebp
f0105c14:	89 e5                	mov    %esp,%ebp
f0105c16:	56                   	push   %esi
f0105c17:	53                   	push   %ebx
f0105c18:	8b 75 08             	mov    0x8(%ebp),%esi
f0105c1b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105c1e:	ba 70 00 00 00       	mov    $0x70,%edx
f0105c23:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105c28:	ee                   	out    %al,(%dx)
f0105c29:	ba 71 00 00 00       	mov    $0x71,%edx
f0105c2e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105c33:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105c34:	83 3d 88 fe 22 f0 00 	cmpl   $0x0,0xf022fe88
f0105c3b:	75 19                	jne    f0105c56 <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105c3d:	68 67 04 00 00       	push   $0x467
f0105c42:	68 64 61 10 f0       	push   $0xf0106164
f0105c47:	68 98 00 00 00       	push   $0x98
f0105c4c:	68 58 7e 10 f0       	push   $0xf0107e58
f0105c51:	e8 ea a3 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105c56:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105c5d:	00 00 
	wrv[1] = addr >> 4;
f0105c5f:	89 d8                	mov    %ebx,%eax
f0105c61:	c1 e8 04             	shr    $0x4,%eax
f0105c64:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105c6a:	c1 e6 18             	shl    $0x18,%esi
f0105c6d:	89 f2                	mov    %esi,%edx
f0105c6f:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105c74:	e8 19 fe ff ff       	call   f0105a92 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105c79:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105c7e:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105c83:	e8 0a fe ff ff       	call   f0105a92 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105c88:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105c8d:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105c92:	e8 fb fd ff ff       	call   f0105a92 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105c97:	c1 eb 0c             	shr    $0xc,%ebx
f0105c9a:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105c9d:	89 f2                	mov    %esi,%edx
f0105c9f:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105ca4:	e8 e9 fd ff ff       	call   f0105a92 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105ca9:	89 da                	mov    %ebx,%edx
f0105cab:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105cb0:	e8 dd fd ff ff       	call   f0105a92 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105cb5:	89 f2                	mov    %esi,%edx
f0105cb7:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105cbc:	e8 d1 fd ff ff       	call   f0105a92 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105cc1:	89 da                	mov    %ebx,%edx
f0105cc3:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105cc8:	e8 c5 fd ff ff       	call   f0105a92 <lapicw>
		microdelay(200);
	}
}
f0105ccd:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105cd0:	5b                   	pop    %ebx
f0105cd1:	5e                   	pop    %esi
f0105cd2:	5d                   	pop    %ebp
f0105cd3:	c3                   	ret    

f0105cd4 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0105cd4:	55                   	push   %ebp
f0105cd5:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0105cd7:	8b 55 08             	mov    0x8(%ebp),%edx
f0105cda:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105ce0:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105ce5:	e8 a8 fd ff ff       	call   f0105a92 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0105cea:	8b 15 04 10 27 f0    	mov    0xf0271004,%edx
f0105cf0:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105cf6:	f6 c4 10             	test   $0x10,%ah
f0105cf9:	75 f5                	jne    f0105cf0 <lapic_ipi+0x1c>
		;
}
f0105cfb:	5d                   	pop    %ebp
f0105cfc:	c3                   	ret    

f0105cfd <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105cfd:	55                   	push   %ebp
f0105cfe:	89 e5                	mov    %esp,%ebp
f0105d00:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105d03:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0105d09:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105d0c:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105d0f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105d16:	5d                   	pop    %ebp
f0105d17:	c3                   	ret    

f0105d18 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0105d18:	55                   	push   %ebp
f0105d19:	89 e5                	mov    %esp,%ebp
f0105d1b:	56                   	push   %esi
f0105d1c:	53                   	push   %ebx
f0105d1d:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105d20:	83 3b 00             	cmpl   $0x0,(%ebx)
f0105d23:	74 14                	je     f0105d39 <spin_lock+0x21>
f0105d25:	8b 73 08             	mov    0x8(%ebx),%esi
f0105d28:	e8 7d fd ff ff       	call   f0105aaa <cpunum>
f0105d2d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105d30:	05 20 00 23 f0       	add    $0xf0230020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0105d35:	39 c6                	cmp    %eax,%esi
f0105d37:	74 07                	je     f0105d40 <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0105d39:	ba 01 00 00 00       	mov    $0x1,%edx
f0105d3e:	eb 20                	jmp    f0105d60 <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0105d40:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0105d43:	e8 62 fd ff ff       	call   f0105aaa <cpunum>
f0105d48:	83 ec 0c             	sub    $0xc,%esp
f0105d4b:	53                   	push   %ebx
f0105d4c:	50                   	push   %eax
f0105d4d:	68 68 7e 10 f0       	push   $0xf0107e68
f0105d52:	6a 41                	push   $0x41
f0105d54:	68 cc 7e 10 f0       	push   $0xf0107ecc
f0105d59:	e8 e2 a2 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0105d5e:	f3 90                	pause  
f0105d60:	89 d0                	mov    %edx,%eax
f0105d62:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0105d65:	85 c0                	test   %eax,%eax
f0105d67:	75 f5                	jne    f0105d5e <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0105d69:	e8 3c fd ff ff       	call   f0105aaa <cpunum>
f0105d6e:	6b c0 74             	imul   $0x74,%eax,%eax
f0105d71:	05 20 00 23 f0       	add    $0xf0230020,%eax
f0105d76:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0105d79:	83 c3 0c             	add    $0xc,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0105d7c:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105d7e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105d83:	eb 0b                	jmp    f0105d90 <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0105d85:	8b 4a 04             	mov    0x4(%edx),%ecx
f0105d88:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0105d8b:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105d8d:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0105d90:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0105d96:	76 11                	jbe    f0105da9 <spin_lock+0x91>
f0105d98:	83 f8 09             	cmp    $0x9,%eax
f0105d9b:	7e e8                	jle    f0105d85 <spin_lock+0x6d>
f0105d9d:	eb 0a                	jmp    f0105da9 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0105d9f:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0105da6:	83 c0 01             	add    $0x1,%eax
f0105da9:	83 f8 09             	cmp    $0x9,%eax
f0105dac:	7e f1                	jle    f0105d9f <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0105dae:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105db1:	5b                   	pop    %ebx
f0105db2:	5e                   	pop    %esi
f0105db3:	5d                   	pop    %ebp
f0105db4:	c3                   	ret    

f0105db5 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0105db5:	55                   	push   %ebp
f0105db6:	89 e5                	mov    %esp,%ebp
f0105db8:	57                   	push   %edi
f0105db9:	56                   	push   %esi
f0105dba:	53                   	push   %ebx
f0105dbb:	83 ec 4c             	sub    $0x4c,%esp
f0105dbe:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105dc1:	83 3e 00             	cmpl   $0x0,(%esi)
f0105dc4:	74 18                	je     f0105dde <spin_unlock+0x29>
f0105dc6:	8b 5e 08             	mov    0x8(%esi),%ebx
f0105dc9:	e8 dc fc ff ff       	call   f0105aaa <cpunum>
f0105dce:	6b c0 74             	imul   $0x74,%eax,%eax
f0105dd1:	05 20 00 23 f0       	add    $0xf0230020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0105dd6:	39 c3                	cmp    %eax,%ebx
f0105dd8:	0f 84 a5 00 00 00    	je     f0105e83 <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0105dde:	83 ec 04             	sub    $0x4,%esp
f0105de1:	6a 28                	push   $0x28
f0105de3:	8d 46 0c             	lea    0xc(%esi),%eax
f0105de6:	50                   	push   %eax
f0105de7:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0105dea:	53                   	push   %ebx
f0105deb:	e8 e4 f6 ff ff       	call   f01054d4 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0105df0:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0105df3:	0f b6 38             	movzbl (%eax),%edi
f0105df6:	8b 76 04             	mov    0x4(%esi),%esi
f0105df9:	e8 ac fc ff ff       	call   f0105aaa <cpunum>
f0105dfe:	57                   	push   %edi
f0105dff:	56                   	push   %esi
f0105e00:	50                   	push   %eax
f0105e01:	68 94 7e 10 f0       	push   $0xf0107e94
f0105e06:	e8 9d da ff ff       	call   f01038a8 <cprintf>
f0105e0b:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0105e0e:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0105e11:	eb 54                	jmp    f0105e67 <spin_unlock+0xb2>
f0105e13:	83 ec 08             	sub    $0x8,%esp
f0105e16:	57                   	push   %edi
f0105e17:	50                   	push   %eax
f0105e18:	e8 f0 eb ff ff       	call   f0104a0d <debuginfo_eip>
f0105e1d:	83 c4 10             	add    $0x10,%esp
f0105e20:	85 c0                	test   %eax,%eax
f0105e22:	78 27                	js     f0105e4b <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0105e24:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0105e26:	83 ec 04             	sub    $0x4,%esp
f0105e29:	89 c2                	mov    %eax,%edx
f0105e2b:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0105e2e:	52                   	push   %edx
f0105e2f:	ff 75 b0             	pushl  -0x50(%ebp)
f0105e32:	ff 75 b4             	pushl  -0x4c(%ebp)
f0105e35:	ff 75 ac             	pushl  -0x54(%ebp)
f0105e38:	ff 75 a8             	pushl  -0x58(%ebp)
f0105e3b:	50                   	push   %eax
f0105e3c:	68 dc 7e 10 f0       	push   $0xf0107edc
f0105e41:	e8 62 da ff ff       	call   f01038a8 <cprintf>
f0105e46:	83 c4 20             	add    $0x20,%esp
f0105e49:	eb 12                	jmp    f0105e5d <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0105e4b:	83 ec 08             	sub    $0x8,%esp
f0105e4e:	ff 36                	pushl  (%esi)
f0105e50:	68 f3 7e 10 f0       	push   $0xf0107ef3
f0105e55:	e8 4e da ff ff       	call   f01038a8 <cprintf>
f0105e5a:	83 c4 10             	add    $0x10,%esp
f0105e5d:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0105e60:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0105e63:	39 c3                	cmp    %eax,%ebx
f0105e65:	74 08                	je     f0105e6f <spin_unlock+0xba>
f0105e67:	89 de                	mov    %ebx,%esi
f0105e69:	8b 03                	mov    (%ebx),%eax
f0105e6b:	85 c0                	test   %eax,%eax
f0105e6d:	75 a4                	jne    f0105e13 <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0105e6f:	83 ec 04             	sub    $0x4,%esp
f0105e72:	68 fb 7e 10 f0       	push   $0xf0107efb
f0105e77:	6a 67                	push   $0x67
f0105e79:	68 cc 7e 10 f0       	push   $0xf0107ecc
f0105e7e:	e8 bd a1 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0105e83:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0105e8a:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0105e91:	b8 00 00 00 00       	mov    $0x0,%eax
f0105e96:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0105e99:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105e9c:	5b                   	pop    %ebx
f0105e9d:	5e                   	pop    %esi
f0105e9e:	5f                   	pop    %edi
f0105e9f:	5d                   	pop    %ebp
f0105ea0:	c3                   	ret    
f0105ea1:	66 90                	xchg   %ax,%ax
f0105ea3:	66 90                	xchg   %ax,%ax
f0105ea5:	66 90                	xchg   %ax,%ax
f0105ea7:	66 90                	xchg   %ax,%ax
f0105ea9:	66 90                	xchg   %ax,%ax
f0105eab:	66 90                	xchg   %ax,%ax
f0105ead:	66 90                	xchg   %ax,%ax
f0105eaf:	90                   	nop

f0105eb0 <__udivdi3>:
f0105eb0:	55                   	push   %ebp
f0105eb1:	57                   	push   %edi
f0105eb2:	56                   	push   %esi
f0105eb3:	53                   	push   %ebx
f0105eb4:	83 ec 1c             	sub    $0x1c,%esp
f0105eb7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f0105ebb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f0105ebf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0105ec3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0105ec7:	85 f6                	test   %esi,%esi
f0105ec9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105ecd:	89 ca                	mov    %ecx,%edx
f0105ecf:	89 f8                	mov    %edi,%eax
f0105ed1:	75 3d                	jne    f0105f10 <__udivdi3+0x60>
f0105ed3:	39 cf                	cmp    %ecx,%edi
f0105ed5:	0f 87 c5 00 00 00    	ja     f0105fa0 <__udivdi3+0xf0>
f0105edb:	85 ff                	test   %edi,%edi
f0105edd:	89 fd                	mov    %edi,%ebp
f0105edf:	75 0b                	jne    f0105eec <__udivdi3+0x3c>
f0105ee1:	b8 01 00 00 00       	mov    $0x1,%eax
f0105ee6:	31 d2                	xor    %edx,%edx
f0105ee8:	f7 f7                	div    %edi
f0105eea:	89 c5                	mov    %eax,%ebp
f0105eec:	89 c8                	mov    %ecx,%eax
f0105eee:	31 d2                	xor    %edx,%edx
f0105ef0:	f7 f5                	div    %ebp
f0105ef2:	89 c1                	mov    %eax,%ecx
f0105ef4:	89 d8                	mov    %ebx,%eax
f0105ef6:	89 cf                	mov    %ecx,%edi
f0105ef8:	f7 f5                	div    %ebp
f0105efa:	89 c3                	mov    %eax,%ebx
f0105efc:	89 d8                	mov    %ebx,%eax
f0105efe:	89 fa                	mov    %edi,%edx
f0105f00:	83 c4 1c             	add    $0x1c,%esp
f0105f03:	5b                   	pop    %ebx
f0105f04:	5e                   	pop    %esi
f0105f05:	5f                   	pop    %edi
f0105f06:	5d                   	pop    %ebp
f0105f07:	c3                   	ret    
f0105f08:	90                   	nop
f0105f09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105f10:	39 ce                	cmp    %ecx,%esi
f0105f12:	77 74                	ja     f0105f88 <__udivdi3+0xd8>
f0105f14:	0f bd fe             	bsr    %esi,%edi
f0105f17:	83 f7 1f             	xor    $0x1f,%edi
f0105f1a:	0f 84 98 00 00 00    	je     f0105fb8 <__udivdi3+0x108>
f0105f20:	bb 20 00 00 00       	mov    $0x20,%ebx
f0105f25:	89 f9                	mov    %edi,%ecx
f0105f27:	89 c5                	mov    %eax,%ebp
f0105f29:	29 fb                	sub    %edi,%ebx
f0105f2b:	d3 e6                	shl    %cl,%esi
f0105f2d:	89 d9                	mov    %ebx,%ecx
f0105f2f:	d3 ed                	shr    %cl,%ebp
f0105f31:	89 f9                	mov    %edi,%ecx
f0105f33:	d3 e0                	shl    %cl,%eax
f0105f35:	09 ee                	or     %ebp,%esi
f0105f37:	89 d9                	mov    %ebx,%ecx
f0105f39:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105f3d:	89 d5                	mov    %edx,%ebp
f0105f3f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0105f43:	d3 ed                	shr    %cl,%ebp
f0105f45:	89 f9                	mov    %edi,%ecx
f0105f47:	d3 e2                	shl    %cl,%edx
f0105f49:	89 d9                	mov    %ebx,%ecx
f0105f4b:	d3 e8                	shr    %cl,%eax
f0105f4d:	09 c2                	or     %eax,%edx
f0105f4f:	89 d0                	mov    %edx,%eax
f0105f51:	89 ea                	mov    %ebp,%edx
f0105f53:	f7 f6                	div    %esi
f0105f55:	89 d5                	mov    %edx,%ebp
f0105f57:	89 c3                	mov    %eax,%ebx
f0105f59:	f7 64 24 0c          	mull   0xc(%esp)
f0105f5d:	39 d5                	cmp    %edx,%ebp
f0105f5f:	72 10                	jb     f0105f71 <__udivdi3+0xc1>
f0105f61:	8b 74 24 08          	mov    0x8(%esp),%esi
f0105f65:	89 f9                	mov    %edi,%ecx
f0105f67:	d3 e6                	shl    %cl,%esi
f0105f69:	39 c6                	cmp    %eax,%esi
f0105f6b:	73 07                	jae    f0105f74 <__udivdi3+0xc4>
f0105f6d:	39 d5                	cmp    %edx,%ebp
f0105f6f:	75 03                	jne    f0105f74 <__udivdi3+0xc4>
f0105f71:	83 eb 01             	sub    $0x1,%ebx
f0105f74:	31 ff                	xor    %edi,%edi
f0105f76:	89 d8                	mov    %ebx,%eax
f0105f78:	89 fa                	mov    %edi,%edx
f0105f7a:	83 c4 1c             	add    $0x1c,%esp
f0105f7d:	5b                   	pop    %ebx
f0105f7e:	5e                   	pop    %esi
f0105f7f:	5f                   	pop    %edi
f0105f80:	5d                   	pop    %ebp
f0105f81:	c3                   	ret    
f0105f82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105f88:	31 ff                	xor    %edi,%edi
f0105f8a:	31 db                	xor    %ebx,%ebx
f0105f8c:	89 d8                	mov    %ebx,%eax
f0105f8e:	89 fa                	mov    %edi,%edx
f0105f90:	83 c4 1c             	add    $0x1c,%esp
f0105f93:	5b                   	pop    %ebx
f0105f94:	5e                   	pop    %esi
f0105f95:	5f                   	pop    %edi
f0105f96:	5d                   	pop    %ebp
f0105f97:	c3                   	ret    
f0105f98:	90                   	nop
f0105f99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105fa0:	89 d8                	mov    %ebx,%eax
f0105fa2:	f7 f7                	div    %edi
f0105fa4:	31 ff                	xor    %edi,%edi
f0105fa6:	89 c3                	mov    %eax,%ebx
f0105fa8:	89 d8                	mov    %ebx,%eax
f0105faa:	89 fa                	mov    %edi,%edx
f0105fac:	83 c4 1c             	add    $0x1c,%esp
f0105faf:	5b                   	pop    %ebx
f0105fb0:	5e                   	pop    %esi
f0105fb1:	5f                   	pop    %edi
f0105fb2:	5d                   	pop    %ebp
f0105fb3:	c3                   	ret    
f0105fb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105fb8:	39 ce                	cmp    %ecx,%esi
f0105fba:	72 0c                	jb     f0105fc8 <__udivdi3+0x118>
f0105fbc:	31 db                	xor    %ebx,%ebx
f0105fbe:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0105fc2:	0f 87 34 ff ff ff    	ja     f0105efc <__udivdi3+0x4c>
f0105fc8:	bb 01 00 00 00       	mov    $0x1,%ebx
f0105fcd:	e9 2a ff ff ff       	jmp    f0105efc <__udivdi3+0x4c>
f0105fd2:	66 90                	xchg   %ax,%ax
f0105fd4:	66 90                	xchg   %ax,%ax
f0105fd6:	66 90                	xchg   %ax,%ax
f0105fd8:	66 90                	xchg   %ax,%ax
f0105fda:	66 90                	xchg   %ax,%ax
f0105fdc:	66 90                	xchg   %ax,%ax
f0105fde:	66 90                	xchg   %ax,%ax

f0105fe0 <__umoddi3>:
f0105fe0:	55                   	push   %ebp
f0105fe1:	57                   	push   %edi
f0105fe2:	56                   	push   %esi
f0105fe3:	53                   	push   %ebx
f0105fe4:	83 ec 1c             	sub    $0x1c,%esp
f0105fe7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0105feb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f0105fef:	8b 74 24 34          	mov    0x34(%esp),%esi
f0105ff3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0105ff7:	85 d2                	test   %edx,%edx
f0105ff9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0105ffd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106001:	89 f3                	mov    %esi,%ebx
f0106003:	89 3c 24             	mov    %edi,(%esp)
f0106006:	89 74 24 04          	mov    %esi,0x4(%esp)
f010600a:	75 1c                	jne    f0106028 <__umoddi3+0x48>
f010600c:	39 f7                	cmp    %esi,%edi
f010600e:	76 50                	jbe    f0106060 <__umoddi3+0x80>
f0106010:	89 c8                	mov    %ecx,%eax
f0106012:	89 f2                	mov    %esi,%edx
f0106014:	f7 f7                	div    %edi
f0106016:	89 d0                	mov    %edx,%eax
f0106018:	31 d2                	xor    %edx,%edx
f010601a:	83 c4 1c             	add    $0x1c,%esp
f010601d:	5b                   	pop    %ebx
f010601e:	5e                   	pop    %esi
f010601f:	5f                   	pop    %edi
f0106020:	5d                   	pop    %ebp
f0106021:	c3                   	ret    
f0106022:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106028:	39 f2                	cmp    %esi,%edx
f010602a:	89 d0                	mov    %edx,%eax
f010602c:	77 52                	ja     f0106080 <__umoddi3+0xa0>
f010602e:	0f bd ea             	bsr    %edx,%ebp
f0106031:	83 f5 1f             	xor    $0x1f,%ebp
f0106034:	75 5a                	jne    f0106090 <__umoddi3+0xb0>
f0106036:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010603a:	0f 82 e0 00 00 00    	jb     f0106120 <__umoddi3+0x140>
f0106040:	39 0c 24             	cmp    %ecx,(%esp)
f0106043:	0f 86 d7 00 00 00    	jbe    f0106120 <__umoddi3+0x140>
f0106049:	8b 44 24 08          	mov    0x8(%esp),%eax
f010604d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106051:	83 c4 1c             	add    $0x1c,%esp
f0106054:	5b                   	pop    %ebx
f0106055:	5e                   	pop    %esi
f0106056:	5f                   	pop    %edi
f0106057:	5d                   	pop    %ebp
f0106058:	c3                   	ret    
f0106059:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106060:	85 ff                	test   %edi,%edi
f0106062:	89 fd                	mov    %edi,%ebp
f0106064:	75 0b                	jne    f0106071 <__umoddi3+0x91>
f0106066:	b8 01 00 00 00       	mov    $0x1,%eax
f010606b:	31 d2                	xor    %edx,%edx
f010606d:	f7 f7                	div    %edi
f010606f:	89 c5                	mov    %eax,%ebp
f0106071:	89 f0                	mov    %esi,%eax
f0106073:	31 d2                	xor    %edx,%edx
f0106075:	f7 f5                	div    %ebp
f0106077:	89 c8                	mov    %ecx,%eax
f0106079:	f7 f5                	div    %ebp
f010607b:	89 d0                	mov    %edx,%eax
f010607d:	eb 99                	jmp    f0106018 <__umoddi3+0x38>
f010607f:	90                   	nop
f0106080:	89 c8                	mov    %ecx,%eax
f0106082:	89 f2                	mov    %esi,%edx
f0106084:	83 c4 1c             	add    $0x1c,%esp
f0106087:	5b                   	pop    %ebx
f0106088:	5e                   	pop    %esi
f0106089:	5f                   	pop    %edi
f010608a:	5d                   	pop    %ebp
f010608b:	c3                   	ret    
f010608c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106090:	8b 34 24             	mov    (%esp),%esi
f0106093:	bf 20 00 00 00       	mov    $0x20,%edi
f0106098:	89 e9                	mov    %ebp,%ecx
f010609a:	29 ef                	sub    %ebp,%edi
f010609c:	d3 e0                	shl    %cl,%eax
f010609e:	89 f9                	mov    %edi,%ecx
f01060a0:	89 f2                	mov    %esi,%edx
f01060a2:	d3 ea                	shr    %cl,%edx
f01060a4:	89 e9                	mov    %ebp,%ecx
f01060a6:	09 c2                	or     %eax,%edx
f01060a8:	89 d8                	mov    %ebx,%eax
f01060aa:	89 14 24             	mov    %edx,(%esp)
f01060ad:	89 f2                	mov    %esi,%edx
f01060af:	d3 e2                	shl    %cl,%edx
f01060b1:	89 f9                	mov    %edi,%ecx
f01060b3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01060b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01060bb:	d3 e8                	shr    %cl,%eax
f01060bd:	89 e9                	mov    %ebp,%ecx
f01060bf:	89 c6                	mov    %eax,%esi
f01060c1:	d3 e3                	shl    %cl,%ebx
f01060c3:	89 f9                	mov    %edi,%ecx
f01060c5:	89 d0                	mov    %edx,%eax
f01060c7:	d3 e8                	shr    %cl,%eax
f01060c9:	89 e9                	mov    %ebp,%ecx
f01060cb:	09 d8                	or     %ebx,%eax
f01060cd:	89 d3                	mov    %edx,%ebx
f01060cf:	89 f2                	mov    %esi,%edx
f01060d1:	f7 34 24             	divl   (%esp)
f01060d4:	89 d6                	mov    %edx,%esi
f01060d6:	d3 e3                	shl    %cl,%ebx
f01060d8:	f7 64 24 04          	mull   0x4(%esp)
f01060dc:	39 d6                	cmp    %edx,%esi
f01060de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01060e2:	89 d1                	mov    %edx,%ecx
f01060e4:	89 c3                	mov    %eax,%ebx
f01060e6:	72 08                	jb     f01060f0 <__umoddi3+0x110>
f01060e8:	75 11                	jne    f01060fb <__umoddi3+0x11b>
f01060ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
f01060ee:	73 0b                	jae    f01060fb <__umoddi3+0x11b>
f01060f0:	2b 44 24 04          	sub    0x4(%esp),%eax
f01060f4:	1b 14 24             	sbb    (%esp),%edx
f01060f7:	89 d1                	mov    %edx,%ecx
f01060f9:	89 c3                	mov    %eax,%ebx
f01060fb:	8b 54 24 08          	mov    0x8(%esp),%edx
f01060ff:	29 da                	sub    %ebx,%edx
f0106101:	19 ce                	sbb    %ecx,%esi
f0106103:	89 f9                	mov    %edi,%ecx
f0106105:	89 f0                	mov    %esi,%eax
f0106107:	d3 e0                	shl    %cl,%eax
f0106109:	89 e9                	mov    %ebp,%ecx
f010610b:	d3 ea                	shr    %cl,%edx
f010610d:	89 e9                	mov    %ebp,%ecx
f010610f:	d3 ee                	shr    %cl,%esi
f0106111:	09 d0                	or     %edx,%eax
f0106113:	89 f2                	mov    %esi,%edx
f0106115:	83 c4 1c             	add    $0x1c,%esp
f0106118:	5b                   	pop    %ebx
f0106119:	5e                   	pop    %esi
f010611a:	5f                   	pop    %edi
f010611b:	5d                   	pop    %ebp
f010611c:	c3                   	ret    
f010611d:	8d 76 00             	lea    0x0(%esi),%esi
f0106120:	29 f9                	sub    %edi,%ecx
f0106122:	19 d6                	sbb    %edx,%esi
f0106124:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106128:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010612c:	e9 18 ff ff ff       	jmp    f0106049 <__umoddi3+0x69>
