
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
f0100048:	83 3d 80 1e 21 f0 00 	cmpl   $0x0,0xf0211e80
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 80 1e 21 f0    	mov    %esi,0xf0211e80

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 f9 5c 00 00       	call   f0105d5a <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 00 64 10 f0       	push   $0xf0106400
f010006d:	e8 f0 38 00 00       	call   f0103962 <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 c0 38 00 00       	call   f010393c <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 19 6d 10 f0 	movl   $0xf0106d19,(%esp)
f0100083:	e8 da 38 00 00       	call   f0103962 <cprintf>
	va_end(ap);
f0100088:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010008b:	83 ec 0c             	sub    $0xc,%esp
f010008e:	6a 00                	push   $0x0
f0100090:	e8 12 09 00 00       	call   f01009a7 <monitor>
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
f01000a1:	e8 96 05 00 00       	call   f010063c <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000a6:	83 ec 08             	sub    $0x8,%esp
f01000a9:	68 ac 1a 00 00       	push   $0x1aac
f01000ae:	68 6c 64 10 f0       	push   $0xf010646c
f01000b3:	e8 aa 38 00 00       	call   f0103962 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000b8:	e8 ad 14 00 00       	call   f010156a <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000bd:	e8 17 31 00 00       	call   f01031d9 <env_init>
	trap_init();
f01000c2:	e8 8e 39 00 00       	call   f0103a55 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000c7:	e8 84 59 00 00       	call   f0105a50 <mp_init>
	lapic_init();
f01000cc:	e8 a4 5c 00 00       	call   f0105d75 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000d1:	e8 b3 37 00 00       	call   f0103889 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000d6:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f01000dd:	e8 e6 5e 00 00       	call   f0105fc8 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000e2:	83 c4 10             	add    $0x10,%esp
f01000e5:	83 3d 88 1e 21 f0 07 	cmpl   $0x7,0xf0211e88
f01000ec:	77 16                	ja     f0100104 <i386_init+0x6a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01000ee:	68 00 70 00 00       	push   $0x7000
f01000f3:	68 24 64 10 f0       	push   $0xf0106424
f01000f8:	6a 55                	push   $0x55
f01000fa:	68 87 64 10 f0       	push   $0xf0106487
f01000ff:	e8 3c ff ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100104:	83 ec 04             	sub    $0x4,%esp
f0100107:	b8 b6 59 10 f0       	mov    $0xf01059b6,%eax
f010010c:	2d 3c 59 10 f0       	sub    $0xf010593c,%eax
f0100111:	50                   	push   %eax
f0100112:	68 3c 59 10 f0       	push   $0xf010593c
f0100117:	68 00 70 00 f0       	push   $0xf0007000
f010011c:	e8 63 56 00 00       	call   f0105784 <memmove>
f0100121:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100124:	bb 20 20 21 f0       	mov    $0xf0212020,%ebx
f0100129:	eb 4d                	jmp    f0100178 <i386_init+0xde>
		if (c == cpus + cpunum())  // We've started already.
f010012b:	e8 2a 5c 00 00       	call   f0105d5a <cpunum>
f0100130:	6b c0 74             	imul   $0x74,%eax,%eax
f0100133:	05 20 20 21 f0       	add    $0xf0212020,%eax
f0100138:	39 c3                	cmp    %eax,%ebx
f010013a:	74 39                	je     f0100175 <i386_init+0xdb>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f010013c:	89 d8                	mov    %ebx,%eax
f010013e:	2d 20 20 21 f0       	sub    $0xf0212020,%eax
f0100143:	c1 f8 02             	sar    $0x2,%eax
f0100146:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f010014c:	c1 e0 0f             	shl    $0xf,%eax
f010014f:	05 00 b0 21 f0       	add    $0xf021b000,%eax
f0100154:	a3 84 1e 21 f0       	mov    %eax,0xf0211e84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100159:	83 ec 08             	sub    $0x8,%esp
f010015c:	68 00 70 00 00       	push   $0x7000
f0100161:	0f b6 03             	movzbl (%ebx),%eax
f0100164:	50                   	push   %eax
f0100165:	e8 59 5d 00 00       	call   f0105ec3 <lapic_startap>
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
f0100178:	6b 05 c4 23 21 f0 74 	imul   $0x74,0xf02123c4,%eax
f010017f:	05 20 20 21 f0       	add    $0xf0212020,%eax
f0100184:	39 c3                	cmp    %eax,%ebx
f0100186:	72 a3                	jb     f010012b <i386_init+0x91>

	// Starting non-boot CPUs
	boot_aps();

	// Start fs.
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f0100188:	83 ec 08             	sub    $0x8,%esp
f010018b:	6a 01                	push   $0x1
f010018d:	68 08 0c 1d f0       	push   $0xf01d0c08
f0100192:	e8 d5 31 00 00       	call   f010336c <env_create>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100197:	83 c4 08             	add    $0x8,%esp
f010019a:	6a 00                	push   $0x0
f010019c:	68 9c bd 1c f0       	push   $0xf01cbd9c
f01001a1:	e8 c6 31 00 00       	call   f010336c <env_create>
	ENV_CREATE(user_icode, ENV_TYPE_USER);
	// ENV_CREATE(user_primes, ENV_TYPE_USER);
#endif // TEST*

	// Should not be necessary - drains keyboard because interrupt has given up.
	kbd_intr();
f01001a6:	e8 35 04 00 00       	call   f01005e0 <kbd_intr>

	// Schedule and run the first user environment!
	sched_yield();
f01001ab:	e8 f4 43 00 00       	call   f01045a4 <sched_yield>

f01001b0 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01001b0:	55                   	push   %ebp
f01001b1:	89 e5                	mov    %esp,%ebp
f01001b3:	83 ec 08             	sub    $0x8,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01001b6:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001bb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001c0:	77 12                	ja     f01001d4 <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001c2:	50                   	push   %eax
f01001c3:	68 48 64 10 f0       	push   $0xf0106448
f01001c8:	6a 6c                	push   $0x6c
f01001ca:	68 87 64 10 f0       	push   $0xf0106487
f01001cf:	e8 6c fe ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01001d4:	05 00 00 00 10       	add    $0x10000000,%eax
f01001d9:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001dc:	e8 79 5b 00 00       	call   f0105d5a <cpunum>
f01001e1:	83 ec 08             	sub    $0x8,%esp
f01001e4:	50                   	push   %eax
f01001e5:	68 93 64 10 f0       	push   $0xf0106493
f01001ea:	e8 73 37 00 00       	call   f0103962 <cprintf>

	lapic_init();
f01001ef:	e8 81 5b 00 00       	call   f0105d75 <lapic_init>
	env_init_percpu();
f01001f4:	e8 b0 2f 00 00       	call   f01031a9 <env_init_percpu>
	trap_init_percpu();
f01001f9:	e8 78 37 00 00       	call   f0103976 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f01001fe:	e8 57 5b 00 00       	call   f0105d5a <cpunum>
f0100203:	6b d0 74             	imul   $0x74,%eax,%edx
f0100206:	81 c2 20 20 21 f0    	add    $0xf0212020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f010020c:	b8 01 00 00 00       	mov    $0x1,%eax
f0100211:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0100215:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f010021c:	e8 a7 5d 00 00       	call   f0105fc8 <spin_lock>
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:

	lock_kernel();
	sched_yield();
f0100221:	e8 7e 43 00 00       	call   f01045a4 <sched_yield>

f0100226 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100226:	55                   	push   %ebp
f0100227:	89 e5                	mov    %esp,%ebp
f0100229:	53                   	push   %ebx
f010022a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010022d:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100230:	ff 75 0c             	pushl  0xc(%ebp)
f0100233:	ff 75 08             	pushl  0x8(%ebp)
f0100236:	68 a9 64 10 f0       	push   $0xf01064a9
f010023b:	e8 22 37 00 00       	call   f0103962 <cprintf>
	vcprintf(fmt, ap);
f0100240:	83 c4 08             	add    $0x8,%esp
f0100243:	53                   	push   %ebx
f0100244:	ff 75 10             	pushl  0x10(%ebp)
f0100247:	e8 f0 36 00 00       	call   f010393c <vcprintf>
	cprintf("\n");
f010024c:	c7 04 24 19 6d 10 f0 	movl   $0xf0106d19,(%esp)
f0100253:	e8 0a 37 00 00       	call   f0103962 <cprintf>
	va_end(ap);
}
f0100258:	83 c4 10             	add    $0x10,%esp
f010025b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010025e:	c9                   	leave  
f010025f:	c3                   	ret    

f0100260 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100260:	55                   	push   %ebp
f0100261:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100263:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100268:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100269:	a8 01                	test   $0x1,%al
f010026b:	74 0b                	je     f0100278 <serial_proc_data+0x18>
f010026d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100272:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100273:	0f b6 c0             	movzbl %al,%eax
f0100276:	eb 05                	jmp    f010027d <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100278:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f010027d:	5d                   	pop    %ebp
f010027e:	c3                   	ret    

f010027f <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010027f:	55                   	push   %ebp
f0100280:	89 e5                	mov    %esp,%ebp
f0100282:	53                   	push   %ebx
f0100283:	83 ec 04             	sub    $0x4,%esp
f0100286:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100288:	eb 2b                	jmp    f01002b5 <cons_intr+0x36>
		if (c == 0)
f010028a:	85 c0                	test   %eax,%eax
f010028c:	74 27                	je     f01002b5 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f010028e:	8b 0d 24 12 21 f0    	mov    0xf0211224,%ecx
f0100294:	8d 51 01             	lea    0x1(%ecx),%edx
f0100297:	89 15 24 12 21 f0    	mov    %edx,0xf0211224
f010029d:	88 81 20 10 21 f0    	mov    %al,-0xfdeefe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002a3:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01002a9:	75 0a                	jne    f01002b5 <cons_intr+0x36>
			cons.wpos = 0;
f01002ab:	c7 05 24 12 21 f0 00 	movl   $0x0,0xf0211224
f01002b2:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002b5:	ff d3                	call   *%ebx
f01002b7:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002ba:	75 ce                	jne    f010028a <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01002bc:	83 c4 04             	add    $0x4,%esp
f01002bf:	5b                   	pop    %ebx
f01002c0:	5d                   	pop    %ebp
f01002c1:	c3                   	ret    

f01002c2 <kbd_proc_data>:
f01002c2:	ba 64 00 00 00       	mov    $0x64,%edx
f01002c7:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f01002c8:	a8 01                	test   $0x1,%al
f01002ca:	0f 84 f8 00 00 00    	je     f01003c8 <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f01002d0:	a8 20                	test   $0x20,%al
f01002d2:	0f 85 f6 00 00 00    	jne    f01003ce <kbd_proc_data+0x10c>
f01002d8:	ba 60 00 00 00       	mov    $0x60,%edx
f01002dd:	ec                   	in     (%dx),%al
f01002de:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01002e0:	3c e0                	cmp    $0xe0,%al
f01002e2:	75 0d                	jne    f01002f1 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f01002e4:	83 0d 00 10 21 f0 40 	orl    $0x40,0xf0211000
		return 0;
f01002eb:	b8 00 00 00 00       	mov    $0x0,%eax
f01002f0:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01002f1:	55                   	push   %ebp
f01002f2:	89 e5                	mov    %esp,%ebp
f01002f4:	53                   	push   %ebx
f01002f5:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01002f8:	84 c0                	test   %al,%al
f01002fa:	79 36                	jns    f0100332 <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01002fc:	8b 0d 00 10 21 f0    	mov    0xf0211000,%ecx
f0100302:	89 cb                	mov    %ecx,%ebx
f0100304:	83 e3 40             	and    $0x40,%ebx
f0100307:	83 e0 7f             	and    $0x7f,%eax
f010030a:	85 db                	test   %ebx,%ebx
f010030c:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010030f:	0f b6 d2             	movzbl %dl,%edx
f0100312:	0f b6 82 20 66 10 f0 	movzbl -0xfef99e0(%edx),%eax
f0100319:	83 c8 40             	or     $0x40,%eax
f010031c:	0f b6 c0             	movzbl %al,%eax
f010031f:	f7 d0                	not    %eax
f0100321:	21 c8                	and    %ecx,%eax
f0100323:	a3 00 10 21 f0       	mov    %eax,0xf0211000
		return 0;
f0100328:	b8 00 00 00 00       	mov    $0x0,%eax
f010032d:	e9 a4 00 00 00       	jmp    f01003d6 <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f0100332:	8b 0d 00 10 21 f0    	mov    0xf0211000,%ecx
f0100338:	f6 c1 40             	test   $0x40,%cl
f010033b:	74 0e                	je     f010034b <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010033d:	83 c8 80             	or     $0xffffff80,%eax
f0100340:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100342:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100345:	89 0d 00 10 21 f0    	mov    %ecx,0xf0211000
	}

	shift |= shiftcode[data];
f010034b:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f010034e:	0f b6 82 20 66 10 f0 	movzbl -0xfef99e0(%edx),%eax
f0100355:	0b 05 00 10 21 f0    	or     0xf0211000,%eax
f010035b:	0f b6 8a 20 65 10 f0 	movzbl -0xfef9ae0(%edx),%ecx
f0100362:	31 c8                	xor    %ecx,%eax
f0100364:	a3 00 10 21 f0       	mov    %eax,0xf0211000

	c = charcode[shift & (CTL | SHIFT)][data];
f0100369:	89 c1                	mov    %eax,%ecx
f010036b:	83 e1 03             	and    $0x3,%ecx
f010036e:	8b 0c 8d 00 65 10 f0 	mov    -0xfef9b00(,%ecx,4),%ecx
f0100375:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100379:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f010037c:	a8 08                	test   $0x8,%al
f010037e:	74 1b                	je     f010039b <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f0100380:	89 da                	mov    %ebx,%edx
f0100382:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100385:	83 f9 19             	cmp    $0x19,%ecx
f0100388:	77 05                	ja     f010038f <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f010038a:	83 eb 20             	sub    $0x20,%ebx
f010038d:	eb 0c                	jmp    f010039b <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f010038f:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100392:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100395:	83 fa 19             	cmp    $0x19,%edx
f0100398:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010039b:	f7 d0                	not    %eax
f010039d:	a8 06                	test   $0x6,%al
f010039f:	75 33                	jne    f01003d4 <kbd_proc_data+0x112>
f01003a1:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003a7:	75 2b                	jne    f01003d4 <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f01003a9:	83 ec 0c             	sub    $0xc,%esp
f01003ac:	68 c3 64 10 f0       	push   $0xf01064c3
f01003b1:	e8 ac 35 00 00       	call   f0103962 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003b6:	ba 92 00 00 00       	mov    $0x92,%edx
f01003bb:	b8 03 00 00 00       	mov    $0x3,%eax
f01003c0:	ee                   	out    %al,(%dx)
f01003c1:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003c4:	89 d8                	mov    %ebx,%eax
f01003c6:	eb 0e                	jmp    f01003d6 <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f01003c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01003cd:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f01003ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01003d3:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003d4:	89 d8                	mov    %ebx,%eax
}
f01003d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01003d9:	c9                   	leave  
f01003da:	c3                   	ret    

f01003db <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003db:	55                   	push   %ebp
f01003dc:	89 e5                	mov    %esp,%ebp
f01003de:	57                   	push   %edi
f01003df:	56                   	push   %esi
f01003e0:	53                   	push   %ebx
f01003e1:	83 ec 1c             	sub    $0x1c,%esp
f01003e4:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01003e6:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003eb:	be fd 03 00 00       	mov    $0x3fd,%esi
f01003f0:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003f5:	eb 09                	jmp    f0100400 <cons_putc+0x25>
f01003f7:	89 ca                	mov    %ecx,%edx
f01003f9:	ec                   	in     (%dx),%al
f01003fa:	ec                   	in     (%dx),%al
f01003fb:	ec                   	in     (%dx),%al
f01003fc:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01003fd:	83 c3 01             	add    $0x1,%ebx
f0100400:	89 f2                	mov    %esi,%edx
f0100402:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100403:	a8 20                	test   $0x20,%al
f0100405:	75 08                	jne    f010040f <cons_putc+0x34>
f0100407:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f010040d:	7e e8                	jle    f01003f7 <cons_putc+0x1c>
f010040f:	89 f8                	mov    %edi,%eax
f0100411:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100414:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100419:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010041a:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010041f:	be 79 03 00 00       	mov    $0x379,%esi
f0100424:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100429:	eb 09                	jmp    f0100434 <cons_putc+0x59>
f010042b:	89 ca                	mov    %ecx,%edx
f010042d:	ec                   	in     (%dx),%al
f010042e:	ec                   	in     (%dx),%al
f010042f:	ec                   	in     (%dx),%al
f0100430:	ec                   	in     (%dx),%al
f0100431:	83 c3 01             	add    $0x1,%ebx
f0100434:	89 f2                	mov    %esi,%edx
f0100436:	ec                   	in     (%dx),%al
f0100437:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f010043d:	7f 04                	jg     f0100443 <cons_putc+0x68>
f010043f:	84 c0                	test   %al,%al
f0100441:	79 e8                	jns    f010042b <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100443:	ba 78 03 00 00       	mov    $0x378,%edx
f0100448:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010044c:	ee                   	out    %al,(%dx)
f010044d:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100452:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100457:	ee                   	out    %al,(%dx)
f0100458:	b8 08 00 00 00       	mov    $0x8,%eax
f010045d:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010045e:	89 fa                	mov    %edi,%edx
f0100460:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100466:	89 f8                	mov    %edi,%eax
f0100468:	80 cc 07             	or     $0x7,%ah
f010046b:	85 d2                	test   %edx,%edx
f010046d:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100470:	89 f8                	mov    %edi,%eax
f0100472:	0f b6 c0             	movzbl %al,%eax
f0100475:	83 f8 09             	cmp    $0x9,%eax
f0100478:	74 74                	je     f01004ee <cons_putc+0x113>
f010047a:	83 f8 09             	cmp    $0x9,%eax
f010047d:	7f 0a                	jg     f0100489 <cons_putc+0xae>
f010047f:	83 f8 08             	cmp    $0x8,%eax
f0100482:	74 14                	je     f0100498 <cons_putc+0xbd>
f0100484:	e9 99 00 00 00       	jmp    f0100522 <cons_putc+0x147>
f0100489:	83 f8 0a             	cmp    $0xa,%eax
f010048c:	74 3a                	je     f01004c8 <cons_putc+0xed>
f010048e:	83 f8 0d             	cmp    $0xd,%eax
f0100491:	74 3d                	je     f01004d0 <cons_putc+0xf5>
f0100493:	e9 8a 00 00 00       	jmp    f0100522 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f0100498:	0f b7 05 28 12 21 f0 	movzwl 0xf0211228,%eax
f010049f:	66 85 c0             	test   %ax,%ax
f01004a2:	0f 84 e6 00 00 00    	je     f010058e <cons_putc+0x1b3>
			crt_pos--;
f01004a8:	83 e8 01             	sub    $0x1,%eax
f01004ab:	66 a3 28 12 21 f0    	mov    %ax,0xf0211228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004b1:	0f b7 c0             	movzwl %ax,%eax
f01004b4:	66 81 e7 00 ff       	and    $0xff00,%di
f01004b9:	83 cf 20             	or     $0x20,%edi
f01004bc:	8b 15 2c 12 21 f0    	mov    0xf021122c,%edx
f01004c2:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004c6:	eb 78                	jmp    f0100540 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004c8:	66 83 05 28 12 21 f0 	addw   $0x50,0xf0211228
f01004cf:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004d0:	0f b7 05 28 12 21 f0 	movzwl 0xf0211228,%eax
f01004d7:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004dd:	c1 e8 16             	shr    $0x16,%eax
f01004e0:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004e3:	c1 e0 04             	shl    $0x4,%eax
f01004e6:	66 a3 28 12 21 f0    	mov    %ax,0xf0211228
f01004ec:	eb 52                	jmp    f0100540 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f01004ee:	b8 20 00 00 00       	mov    $0x20,%eax
f01004f3:	e8 e3 fe ff ff       	call   f01003db <cons_putc>
		cons_putc(' ');
f01004f8:	b8 20 00 00 00       	mov    $0x20,%eax
f01004fd:	e8 d9 fe ff ff       	call   f01003db <cons_putc>
		cons_putc(' ');
f0100502:	b8 20 00 00 00       	mov    $0x20,%eax
f0100507:	e8 cf fe ff ff       	call   f01003db <cons_putc>
		cons_putc(' ');
f010050c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100511:	e8 c5 fe ff ff       	call   f01003db <cons_putc>
		cons_putc(' ');
f0100516:	b8 20 00 00 00       	mov    $0x20,%eax
f010051b:	e8 bb fe ff ff       	call   f01003db <cons_putc>
f0100520:	eb 1e                	jmp    f0100540 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100522:	0f b7 05 28 12 21 f0 	movzwl 0xf0211228,%eax
f0100529:	8d 50 01             	lea    0x1(%eax),%edx
f010052c:	66 89 15 28 12 21 f0 	mov    %dx,0xf0211228
f0100533:	0f b7 c0             	movzwl %ax,%eax
f0100536:	8b 15 2c 12 21 f0    	mov    0xf021122c,%edx
f010053c:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100540:	66 81 3d 28 12 21 f0 	cmpw   $0x7cf,0xf0211228
f0100547:	cf 07 
f0100549:	76 43                	jbe    f010058e <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010054b:	a1 2c 12 21 f0       	mov    0xf021122c,%eax
f0100550:	83 ec 04             	sub    $0x4,%esp
f0100553:	68 00 0f 00 00       	push   $0xf00
f0100558:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010055e:	52                   	push   %edx
f010055f:	50                   	push   %eax
f0100560:	e8 1f 52 00 00       	call   f0105784 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100565:	8b 15 2c 12 21 f0    	mov    0xf021122c,%edx
f010056b:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100571:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100577:	83 c4 10             	add    $0x10,%esp
f010057a:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010057f:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100582:	39 d0                	cmp    %edx,%eax
f0100584:	75 f4                	jne    f010057a <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100586:	66 83 2d 28 12 21 f0 	subw   $0x50,0xf0211228
f010058d:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010058e:	8b 0d 30 12 21 f0    	mov    0xf0211230,%ecx
f0100594:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100599:	89 ca                	mov    %ecx,%edx
f010059b:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010059c:	0f b7 1d 28 12 21 f0 	movzwl 0xf0211228,%ebx
f01005a3:	8d 71 01             	lea    0x1(%ecx),%esi
f01005a6:	89 d8                	mov    %ebx,%eax
f01005a8:	66 c1 e8 08          	shr    $0x8,%ax
f01005ac:	89 f2                	mov    %esi,%edx
f01005ae:	ee                   	out    %al,(%dx)
f01005af:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005b4:	89 ca                	mov    %ecx,%edx
f01005b6:	ee                   	out    %al,(%dx)
f01005b7:	89 d8                	mov    %ebx,%eax
f01005b9:	89 f2                	mov    %esi,%edx
f01005bb:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01005bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005bf:	5b                   	pop    %ebx
f01005c0:	5e                   	pop    %esi
f01005c1:	5f                   	pop    %edi
f01005c2:	5d                   	pop    %ebp
f01005c3:	c3                   	ret    

f01005c4 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01005c4:	80 3d 34 12 21 f0 00 	cmpb   $0x0,0xf0211234
f01005cb:	74 11                	je     f01005de <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01005cd:	55                   	push   %ebp
f01005ce:	89 e5                	mov    %esp,%ebp
f01005d0:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01005d3:	b8 60 02 10 f0       	mov    $0xf0100260,%eax
f01005d8:	e8 a2 fc ff ff       	call   f010027f <cons_intr>
}
f01005dd:	c9                   	leave  
f01005de:	f3 c3                	repz ret 

f01005e0 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01005e0:	55                   	push   %ebp
f01005e1:	89 e5                	mov    %esp,%ebp
f01005e3:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01005e6:	b8 c2 02 10 f0       	mov    $0xf01002c2,%eax
f01005eb:	e8 8f fc ff ff       	call   f010027f <cons_intr>
}
f01005f0:	c9                   	leave  
f01005f1:	c3                   	ret    

f01005f2 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01005f2:	55                   	push   %ebp
f01005f3:	89 e5                	mov    %esp,%ebp
f01005f5:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01005f8:	e8 c7 ff ff ff       	call   f01005c4 <serial_intr>
	kbd_intr();
f01005fd:	e8 de ff ff ff       	call   f01005e0 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100602:	a1 20 12 21 f0       	mov    0xf0211220,%eax
f0100607:	3b 05 24 12 21 f0    	cmp    0xf0211224,%eax
f010060d:	74 26                	je     f0100635 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f010060f:	8d 50 01             	lea    0x1(%eax),%edx
f0100612:	89 15 20 12 21 f0    	mov    %edx,0xf0211220
f0100618:	0f b6 88 20 10 21 f0 	movzbl -0xfdeefe0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f010061f:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100621:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100627:	75 11                	jne    f010063a <cons_getc+0x48>
			cons.rpos = 0;
f0100629:	c7 05 20 12 21 f0 00 	movl   $0x0,0xf0211220
f0100630:	00 00 00 
f0100633:	eb 05                	jmp    f010063a <cons_getc+0x48>
		return c;
	}
	return 0;
f0100635:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010063a:	c9                   	leave  
f010063b:	c3                   	ret    

f010063c <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010063c:	55                   	push   %ebp
f010063d:	89 e5                	mov    %esp,%ebp
f010063f:	57                   	push   %edi
f0100640:	56                   	push   %esi
f0100641:	53                   	push   %ebx
f0100642:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100645:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010064c:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100653:	5a a5 
	if (*cp != 0xA55A) {
f0100655:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010065c:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100660:	74 11                	je     f0100673 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100662:	c7 05 30 12 21 f0 b4 	movl   $0x3b4,0xf0211230
f0100669:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010066c:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100671:	eb 16                	jmp    f0100689 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100673:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010067a:	c7 05 30 12 21 f0 d4 	movl   $0x3d4,0xf0211230
f0100681:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100684:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100689:	8b 3d 30 12 21 f0    	mov    0xf0211230,%edi
f010068f:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100694:	89 fa                	mov    %edi,%edx
f0100696:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100697:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010069a:	89 da                	mov    %ebx,%edx
f010069c:	ec                   	in     (%dx),%al
f010069d:	0f b6 c8             	movzbl %al,%ecx
f01006a0:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006a3:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006a8:	89 fa                	mov    %edi,%edx
f01006aa:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006ab:	89 da                	mov    %ebx,%edx
f01006ad:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006ae:	89 35 2c 12 21 f0    	mov    %esi,0xf021122c
	crt_pos = pos;
f01006b4:	0f b6 c0             	movzbl %al,%eax
f01006b7:	09 c8                	or     %ecx,%eax
f01006b9:	66 a3 28 12 21 f0    	mov    %ax,0xf0211228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006bf:	e8 1c ff ff ff       	call   f01005e0 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006c4:	83 ec 0c             	sub    $0xc,%esp
f01006c7:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f01006ce:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006d3:	50                   	push   %eax
f01006d4:	e8 38 31 00 00       	call   f0103811 <irq_setmask_8259A>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006d9:	be fa 03 00 00       	mov    $0x3fa,%esi
f01006de:	b8 00 00 00 00       	mov    $0x0,%eax
f01006e3:	89 f2                	mov    %esi,%edx
f01006e5:	ee                   	out    %al,(%dx)
f01006e6:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01006eb:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006f0:	ee                   	out    %al,(%dx)
f01006f1:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01006f6:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006fb:	89 da                	mov    %ebx,%edx
f01006fd:	ee                   	out    %al,(%dx)
f01006fe:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100703:	b8 00 00 00 00       	mov    $0x0,%eax
f0100708:	ee                   	out    %al,(%dx)
f0100709:	ba fb 03 00 00       	mov    $0x3fb,%edx
f010070e:	b8 03 00 00 00       	mov    $0x3,%eax
f0100713:	ee                   	out    %al,(%dx)
f0100714:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100719:	b8 00 00 00 00       	mov    $0x0,%eax
f010071e:	ee                   	out    %al,(%dx)
f010071f:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100724:	b8 01 00 00 00       	mov    $0x1,%eax
f0100729:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010072a:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010072f:	ec                   	in     (%dx),%al
f0100730:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100732:	83 c4 10             	add    $0x10,%esp
f0100735:	3c ff                	cmp    $0xff,%al
f0100737:	0f 95 05 34 12 21 f0 	setne  0xf0211234
f010073e:	89 f2                	mov    %esi,%edx
f0100740:	ec                   	in     (%dx),%al
f0100741:	89 da                	mov    %ebx,%edx
f0100743:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

	// Enable serial interrupts
	if (serial_exists)
f0100744:	80 f9 ff             	cmp    $0xff,%cl
f0100747:	74 21                	je     f010076a <cons_init+0x12e>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_SERIAL));
f0100749:	83 ec 0c             	sub    $0xc,%esp
f010074c:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f0100753:	25 ef ff 00 00       	and    $0xffef,%eax
f0100758:	50                   	push   %eax
f0100759:	e8 b3 30 00 00       	call   f0103811 <irq_setmask_8259A>
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010075e:	83 c4 10             	add    $0x10,%esp
f0100761:	80 3d 34 12 21 f0 00 	cmpb   $0x0,0xf0211234
f0100768:	75 10                	jne    f010077a <cons_init+0x13e>
		cprintf("Serial port does not exist!\n");
f010076a:	83 ec 0c             	sub    $0xc,%esp
f010076d:	68 cf 64 10 f0       	push   $0xf01064cf
f0100772:	e8 eb 31 00 00       	call   f0103962 <cprintf>
f0100777:	83 c4 10             	add    $0x10,%esp
}
f010077a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010077d:	5b                   	pop    %ebx
f010077e:	5e                   	pop    %esi
f010077f:	5f                   	pop    %edi
f0100780:	5d                   	pop    %ebp
f0100781:	c3                   	ret    

f0100782 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100782:	55                   	push   %ebp
f0100783:	89 e5                	mov    %esp,%ebp
f0100785:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100788:	8b 45 08             	mov    0x8(%ebp),%eax
f010078b:	e8 4b fc ff ff       	call   f01003db <cons_putc>
}
f0100790:	c9                   	leave  
f0100791:	c3                   	ret    

f0100792 <getchar>:

int
getchar(void)
{
f0100792:	55                   	push   %ebp
f0100793:	89 e5                	mov    %esp,%ebp
f0100795:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100798:	e8 55 fe ff ff       	call   f01005f2 <cons_getc>
f010079d:	85 c0                	test   %eax,%eax
f010079f:	74 f7                	je     f0100798 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007a1:	c9                   	leave  
f01007a2:	c3                   	ret    

f01007a3 <iscons>:

int
iscons(int fdnum)
{
f01007a3:	55                   	push   %ebp
f01007a4:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007a6:	b8 01 00 00 00       	mov    $0x1,%eax
f01007ab:	5d                   	pop    %ebp
f01007ac:	c3                   	ret    

f01007ad <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007ad:	55                   	push   %ebp
f01007ae:	89 e5                	mov    %esp,%ebp
f01007b0:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007b3:	68 20 67 10 f0       	push   $0xf0106720
f01007b8:	68 3e 67 10 f0       	push   $0xf010673e
f01007bd:	68 43 67 10 f0       	push   $0xf0106743
f01007c2:	e8 9b 31 00 00       	call   f0103962 <cprintf>
f01007c7:	83 c4 0c             	add    $0xc,%esp
f01007ca:	68 fc 67 10 f0       	push   $0xf01067fc
f01007cf:	68 4c 67 10 f0       	push   $0xf010674c
f01007d4:	68 43 67 10 f0       	push   $0xf0106743
f01007d9:	e8 84 31 00 00       	call   f0103962 <cprintf>
f01007de:	83 c4 0c             	add    $0xc,%esp
f01007e1:	68 55 67 10 f0       	push   $0xf0106755
f01007e6:	68 73 67 10 f0       	push   $0xf0106773
f01007eb:	68 43 67 10 f0       	push   $0xf0106743
f01007f0:	e8 6d 31 00 00       	call   f0103962 <cprintf>
	return 0;
}
f01007f5:	b8 00 00 00 00       	mov    $0x0,%eax
f01007fa:	c9                   	leave  
f01007fb:	c3                   	ret    

f01007fc <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007fc:	55                   	push   %ebp
f01007fd:	89 e5                	mov    %esp,%ebp
f01007ff:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100802:	68 7d 67 10 f0       	push   $0xf010677d
f0100807:	e8 56 31 00 00       	call   f0103962 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010080c:	83 c4 08             	add    $0x8,%esp
f010080f:	68 0c 00 10 00       	push   $0x10000c
f0100814:	68 24 68 10 f0       	push   $0xf0106824
f0100819:	e8 44 31 00 00       	call   f0103962 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010081e:	83 c4 0c             	add    $0xc,%esp
f0100821:	68 0c 00 10 00       	push   $0x10000c
f0100826:	68 0c 00 10 f0       	push   $0xf010000c
f010082b:	68 4c 68 10 f0       	push   $0xf010684c
f0100830:	e8 2d 31 00 00       	call   f0103962 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100835:	83 c4 0c             	add    $0xc,%esp
f0100838:	68 e1 63 10 00       	push   $0x1063e1
f010083d:	68 e1 63 10 f0       	push   $0xf01063e1
f0100842:	68 70 68 10 f0       	push   $0xf0106870
f0100847:	e8 16 31 00 00       	call   f0103962 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010084c:	83 c4 0c             	add    $0xc,%esp
f010084f:	68 00 10 21 00       	push   $0x211000
f0100854:	68 00 10 21 f0       	push   $0xf0211000
f0100859:	68 94 68 10 f0       	push   $0xf0106894
f010085e:	e8 ff 30 00 00       	call   f0103962 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100863:	83 c4 0c             	add    $0xc,%esp
f0100866:	68 08 30 25 00       	push   $0x253008
f010086b:	68 08 30 25 f0       	push   $0xf0253008
f0100870:	68 b8 68 10 f0       	push   $0xf01068b8
f0100875:	e8 e8 30 00 00       	call   f0103962 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010087a:	b8 07 34 25 f0       	mov    $0xf0253407,%eax
f010087f:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100884:	83 c4 08             	add    $0x8,%esp
f0100887:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f010088c:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100892:	85 c0                	test   %eax,%eax
f0100894:	0f 48 c2             	cmovs  %edx,%eax
f0100897:	c1 f8 0a             	sar    $0xa,%eax
f010089a:	50                   	push   %eax
f010089b:	68 dc 68 10 f0       	push   $0xf01068dc
f01008a0:	e8 bd 30 00 00       	call   f0103962 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01008a5:	b8 00 00 00 00       	mov    $0x0,%eax
f01008aa:	c9                   	leave  
f01008ab:	c3                   	ret    

f01008ac <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008ac:	55                   	push   %ebp
f01008ad:	89 e5                	mov    %esp,%ebp
f01008af:	57                   	push   %edi
f01008b0:	56                   	push   %esi
f01008b1:	53                   	push   %ebx
f01008b2:	83 ec 78             	sub    $0x78,%esp

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008b5:	89 eb                	mov    %ebp,%ebx

	uint32_t _ebp, _eip;
	// _esp = read_esp();
	_ebp = read_ebp();

	uint32_t args[5] = {0, 0, 0, 0, 0};
f01008b7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f01008be:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f01008c5:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f01008cc:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01008d3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	struct Eipdebuginfo context;

	cprintf("Stack backtrace:\n");
f01008da:	68 96 67 10 f0       	push   $0xf0106796
f01008df:	e8 7e 30 00 00       	call   f0103962 <cprintf>

	while (_ebp != 0) {
f01008e4:	83 c4 10             	add    $0x10,%esp
f01008e7:	e9 a6 00 00 00       	jmp    f0100992 <mon_backtrace+0xe6>
		
		_eip = *(uint32_t *)(_ebp + 4);		// ret addr
f01008ec:	8b 73 04             	mov    0x4(%ebx),%esi

		for (int i=0; i<5; i++) {
f01008ef:	b8 00 00 00 00       	mov    $0x0,%eax
			args[i] = *(uint32_t *)(_ebp + 8 + i * 4);
f01008f4:	8b 54 83 08          	mov    0x8(%ebx,%eax,4),%edx
f01008f8:	89 54 85 d4          	mov    %edx,-0x2c(%ebp,%eax,4)

	while (_ebp != 0) {
		
		_eip = *(uint32_t *)(_ebp + 4);		// ret addr

		for (int i=0; i<5; i++) {
f01008fc:	83 c0 01             	add    $0x1,%eax
f01008ff:	83 f8 05             	cmp    $0x5,%eax
f0100902:	75 f0                	jne    f01008f4 <mon_backtrace+0x48>
			args[i] = *(uint32_t *)(_ebp + 8 + i * 4);
		}

		debuginfo_eip((uintptr_t)_eip, &context);
f0100904:	83 ec 08             	sub    $0x8,%esp
f0100907:	8d 45 bc             	lea    -0x44(%ebp),%eax
f010090a:	50                   	push   %eax
f010090b:	56                   	push   %esi
f010090c:	e8 94 43 00 00       	call   f0104ca5 <debuginfo_eip>

		char function_name[50] = {0};
f0100911:	c7 45 8a 00 00 00 00 	movl   $0x0,-0x76(%ebp)
f0100918:	c7 45 b8 00 00 00 00 	movl   $0x0,-0x48(%ebp)
f010091f:	8d 7d 8c             	lea    -0x74(%ebp),%edi
f0100922:	b9 0c 00 00 00       	mov    $0xc,%ecx
f0100927:	b8 00 00 00 00       	mov    $0x0,%eax
f010092c:	f3 ab                	rep stos %eax,%es:(%edi)
		int i = 0;
		for (; i<context.eip_fn_namelen; i++) {
f010092e:	8b 4d c8             	mov    -0x38(%ebp),%ecx
			function_name[i] = context.eip_fn_name[i];
f0100931:	8b 7d c4             	mov    -0x3c(%ebp),%edi

		debuginfo_eip((uintptr_t)_eip, &context);

		char function_name[50] = {0};
		int i = 0;
		for (; i<context.eip_fn_namelen; i++) {
f0100934:	83 c4 10             	add    $0x10,%esp
f0100937:	eb 0b                	jmp    f0100944 <mon_backtrace+0x98>
			function_name[i] = context.eip_fn_name[i];
f0100939:	0f b6 14 07          	movzbl (%edi,%eax,1),%edx
f010093d:	88 54 05 8a          	mov    %dl,-0x76(%ebp,%eax,1)

		debuginfo_eip((uintptr_t)_eip, &context);

		char function_name[50] = {0};
		int i = 0;
		for (; i<context.eip_fn_namelen; i++) {
f0100941:	83 c0 01             	add    $0x1,%eax
f0100944:	39 c8                	cmp    %ecx,%eax
f0100946:	7c f1                	jl     f0100939 <mon_backtrace+0x8d>
			function_name[i] = context.eip_fn_name[i];
		}
		function_name[i] = '\0';
f0100948:	85 c9                	test   %ecx,%ecx
f010094a:	b8 00 00 00 00       	mov    $0x0,%eax
f010094f:	0f 48 c8             	cmovs  %eax,%ecx
f0100952:	c6 44 0d 8a 00       	movb   $0x0,-0x76(%ebp,%ecx,1)

		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", _ebp, _eip, args[0], args[1], args[2], args[3], args[4]);
f0100957:	ff 75 e4             	pushl  -0x1c(%ebp)
f010095a:	ff 75 e0             	pushl  -0x20(%ebp)
f010095d:	ff 75 dc             	pushl  -0x24(%ebp)
f0100960:	ff 75 d8             	pushl  -0x28(%ebp)
f0100963:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100966:	56                   	push   %esi
f0100967:	53                   	push   %ebx
f0100968:	68 08 69 10 f0       	push   $0xf0106908
f010096d:	e8 f0 2f 00 00       	call   f0103962 <cprintf>
		cprintf("         %s:%d: %s+%d\n", context.eip_file, context.eip_line, function_name, _eip - context.eip_fn_addr);
f0100972:	83 c4 14             	add    $0x14,%esp
f0100975:	2b 75 cc             	sub    -0x34(%ebp),%esi
f0100978:	56                   	push   %esi
f0100979:	8d 45 8a             	lea    -0x76(%ebp),%eax
f010097c:	50                   	push   %eax
f010097d:	ff 75 c0             	pushl  -0x40(%ebp)
f0100980:	ff 75 bc             	pushl  -0x44(%ebp)
f0100983:	68 a8 67 10 f0       	push   $0xf01067a8
f0100988:	e8 d5 2f 00 00       	call   f0103962 <cprintf>

		// _rsp = _ebp + 8;			// old_rsp
		_ebp = *(uint32_t *)_ebp;	// old_ebp
f010098d:	8b 1b                	mov    (%ebx),%ebx
f010098f:	83 c4 20             	add    $0x20,%esp

	struct Eipdebuginfo context;

	cprintf("Stack backtrace:\n");

	while (_ebp != 0) {
f0100992:	85 db                	test   %ebx,%ebx
f0100994:	0f 85 52 ff ff ff    	jne    f01008ec <mon_backtrace+0x40>
		_ebp = *(uint32_t *)_ebp;	// old_ebp

	} 

	return 0;
}
f010099a:	b8 00 00 00 00       	mov    $0x0,%eax
f010099f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01009a2:	5b                   	pop    %ebx
f01009a3:	5e                   	pop    %esi
f01009a4:	5f                   	pop    %edi
f01009a5:	5d                   	pop    %ebp
f01009a6:	c3                   	ret    

f01009a7 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01009a7:	55                   	push   %ebp
f01009a8:	89 e5                	mov    %esp,%ebp
f01009aa:	57                   	push   %edi
f01009ab:	56                   	push   %esi
f01009ac:	53                   	push   %ebx
f01009ad:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01009b0:	68 40 69 10 f0       	push   $0xf0106940
f01009b5:	e8 a8 2f 00 00       	call   f0103962 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01009ba:	c7 04 24 64 69 10 f0 	movl   $0xf0106964,(%esp)
f01009c1:	e8 9c 2f 00 00       	call   f0103962 <cprintf>

	if (tf != NULL)
f01009c6:	83 c4 10             	add    $0x10,%esp
f01009c9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01009cd:	74 0e                	je     f01009dd <monitor+0x36>
		print_trapframe(tf);
f01009cf:	83 ec 0c             	sub    $0xc,%esp
f01009d2:	ff 75 08             	pushl  0x8(%ebp)
f01009d5:	e8 49 35 00 00       	call   f0103f23 <print_trapframe>
f01009da:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01009dd:	83 ec 0c             	sub    $0xc,%esp
f01009e0:	68 bf 67 10 f0       	push   $0xf01067bf
f01009e5:	e8 de 4a 00 00       	call   f01054c8 <readline>
f01009ea:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01009ec:	83 c4 10             	add    $0x10,%esp
f01009ef:	85 c0                	test   %eax,%eax
f01009f1:	74 ea                	je     f01009dd <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01009f3:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01009fa:	be 00 00 00 00       	mov    $0x0,%esi
f01009ff:	eb 0a                	jmp    f0100a0b <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100a01:	c6 03 00             	movb   $0x0,(%ebx)
f0100a04:	89 f7                	mov    %esi,%edi
f0100a06:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100a09:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100a0b:	0f b6 03             	movzbl (%ebx),%eax
f0100a0e:	84 c0                	test   %al,%al
f0100a10:	74 63                	je     f0100a75 <monitor+0xce>
f0100a12:	83 ec 08             	sub    $0x8,%esp
f0100a15:	0f be c0             	movsbl %al,%eax
f0100a18:	50                   	push   %eax
f0100a19:	68 c3 67 10 f0       	push   $0xf01067c3
f0100a1e:	e8 d7 4c 00 00       	call   f01056fa <strchr>
f0100a23:	83 c4 10             	add    $0x10,%esp
f0100a26:	85 c0                	test   %eax,%eax
f0100a28:	75 d7                	jne    f0100a01 <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f0100a2a:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100a2d:	74 46                	je     f0100a75 <monitor+0xce>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100a2f:	83 fe 0f             	cmp    $0xf,%esi
f0100a32:	75 14                	jne    f0100a48 <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a34:	83 ec 08             	sub    $0x8,%esp
f0100a37:	6a 10                	push   $0x10
f0100a39:	68 c8 67 10 f0       	push   $0xf01067c8
f0100a3e:	e8 1f 2f 00 00       	call   f0103962 <cprintf>
f0100a43:	83 c4 10             	add    $0x10,%esp
f0100a46:	eb 95                	jmp    f01009dd <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f0100a48:	8d 7e 01             	lea    0x1(%esi),%edi
f0100a4b:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100a4f:	eb 03                	jmp    f0100a54 <monitor+0xad>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100a51:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a54:	0f b6 03             	movzbl (%ebx),%eax
f0100a57:	84 c0                	test   %al,%al
f0100a59:	74 ae                	je     f0100a09 <monitor+0x62>
f0100a5b:	83 ec 08             	sub    $0x8,%esp
f0100a5e:	0f be c0             	movsbl %al,%eax
f0100a61:	50                   	push   %eax
f0100a62:	68 c3 67 10 f0       	push   $0xf01067c3
f0100a67:	e8 8e 4c 00 00       	call   f01056fa <strchr>
f0100a6c:	83 c4 10             	add    $0x10,%esp
f0100a6f:	85 c0                	test   %eax,%eax
f0100a71:	74 de                	je     f0100a51 <monitor+0xaa>
f0100a73:	eb 94                	jmp    f0100a09 <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f0100a75:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a7c:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100a7d:	85 f6                	test   %esi,%esi
f0100a7f:	0f 84 58 ff ff ff    	je     f01009dd <monitor+0x36>
f0100a85:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a8a:	83 ec 08             	sub    $0x8,%esp
f0100a8d:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a90:	ff 34 85 a0 69 10 f0 	pushl  -0xfef9660(,%eax,4)
f0100a97:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a9a:	e8 fd 4b 00 00       	call   f010569c <strcmp>
f0100a9f:	83 c4 10             	add    $0x10,%esp
f0100aa2:	85 c0                	test   %eax,%eax
f0100aa4:	75 21                	jne    f0100ac7 <monitor+0x120>
			return commands[i].func(argc, argv, tf);
f0100aa6:	83 ec 04             	sub    $0x4,%esp
f0100aa9:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100aac:	ff 75 08             	pushl  0x8(%ebp)
f0100aaf:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100ab2:	52                   	push   %edx
f0100ab3:	56                   	push   %esi
f0100ab4:	ff 14 85 a8 69 10 f0 	call   *-0xfef9658(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100abb:	83 c4 10             	add    $0x10,%esp
f0100abe:	85 c0                	test   %eax,%eax
f0100ac0:	78 25                	js     f0100ae7 <monitor+0x140>
f0100ac2:	e9 16 ff ff ff       	jmp    f01009dd <monitor+0x36>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100ac7:	83 c3 01             	add    $0x1,%ebx
f0100aca:	83 fb 03             	cmp    $0x3,%ebx
f0100acd:	75 bb                	jne    f0100a8a <monitor+0xe3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100acf:	83 ec 08             	sub    $0x8,%esp
f0100ad2:	ff 75 a8             	pushl  -0x58(%ebp)
f0100ad5:	68 e5 67 10 f0       	push   $0xf01067e5
f0100ada:	e8 83 2e 00 00       	call   f0103962 <cprintf>
f0100adf:	83 c4 10             	add    $0x10,%esp
f0100ae2:	e9 f6 fe ff ff       	jmp    f01009dd <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100ae7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100aea:	5b                   	pop    %ebx
f0100aeb:	5e                   	pop    %esi
f0100aec:	5f                   	pop    %edi
f0100aed:	5d                   	pop    %ebp
f0100aee:	c3                   	ret    

f0100aef <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100aef:	55                   	push   %ebp
f0100af0:	89 e5                	mov    %esp,%ebp
f0100af2:	56                   	push   %esi
f0100af3:	53                   	push   %ebx
f0100af4:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100af6:	83 ec 0c             	sub    $0xc,%esp
f0100af9:	50                   	push   %eax
f0100afa:	e8 e4 2c 00 00       	call   f01037e3 <mc146818_read>
f0100aff:	89 c6                	mov    %eax,%esi
f0100b01:	83 c3 01             	add    $0x1,%ebx
f0100b04:	89 1c 24             	mov    %ebx,(%esp)
f0100b07:	e8 d7 2c 00 00       	call   f01037e3 <mc146818_read>
f0100b0c:	c1 e0 08             	shl    $0x8,%eax
f0100b0f:	09 f0                	or     %esi,%eax
}
f0100b11:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100b14:	5b                   	pop    %ebx
f0100b15:	5e                   	pop    %esi
f0100b16:	5d                   	pop    %ebp
f0100b17:	c3                   	ret    

f0100b18 <boot_alloc>:
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100b18:	83 3d 38 12 21 f0 00 	cmpl   $0x0,0xf0211238
f0100b1f:	75 11                	jne    f0100b32 <boot_alloc+0x1a>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100b21:	ba 07 40 25 f0       	mov    $0xf0254007,%edx
f0100b26:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b2c:	89 15 38 12 21 f0    	mov    %edx,0xf0211238
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

	if ((uint32_t)nextfree > 0xffffffff - n)
f0100b32:	8b 15 38 12 21 f0    	mov    0xf0211238,%edx
f0100b38:	89 c1                	mov    %eax,%ecx
f0100b3a:	f7 d1                	not    %ecx
f0100b3c:	39 ca                	cmp    %ecx,%edx
f0100b3e:	76 17                	jbe    f0100b57 <boot_alloc+0x3f>
// before the page_free_list list has been set up.
// Note that when this function is called, we are still using entry_pgdir,
// which only maps the first 4MB of physical memory.
static void *
boot_alloc(uint32_t n)
{
f0100b40:	55                   	push   %ebp
f0100b41:	89 e5                	mov    %esp,%ebp
f0100b43:	83 ec 0c             	sub    $0xc,%esp
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

	if ((uint32_t)nextfree > 0xffffffff - n)
		panic("boot_alloc: out of memory\n");
f0100b46:	68 c4 69 10 f0       	push   $0xf01069c4
f0100b4b:	6a 70                	push   $0x70
f0100b4d:	68 df 69 10 f0       	push   $0xf01069df
f0100b52:	e8 e9 f4 ff ff       	call   f0100040 <_panic>

	result = nextfree;
	nextfree = ROUNDUP(result + n , PGSIZE);
f0100b57:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100b5e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b63:	a3 38 12 21 f0       	mov    %eax,0xf0211238

	return result;
}
f0100b68:	89 d0                	mov    %edx,%eax
f0100b6a:	c3                   	ret    

f0100b6b <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100b6b:	89 d1                	mov    %edx,%ecx
f0100b6d:	c1 e9 16             	shr    $0x16,%ecx
f0100b70:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100b73:	a8 01                	test   $0x1,%al
f0100b75:	74 52                	je     f0100bc9 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b77:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b7c:	89 c1                	mov    %eax,%ecx
f0100b7e:	c1 e9 0c             	shr    $0xc,%ecx
f0100b81:	3b 0d 88 1e 21 f0    	cmp    0xf0211e88,%ecx
f0100b87:	72 1b                	jb     f0100ba4 <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100b89:	55                   	push   %ebp
f0100b8a:	89 e5                	mov    %esp,%ebp
f0100b8c:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b8f:	50                   	push   %eax
f0100b90:	68 24 64 10 f0       	push   $0xf0106424
f0100b95:	68 40 04 00 00       	push   $0x440
f0100b9a:	68 df 69 10 f0       	push   $0xf01069df
f0100b9f:	e8 9c f4 ff ff       	call   f0100040 <_panic>
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));

	// cprintf("[?] In check_va2pa\n");
	// cprintf("[?] *pte_store:%x, **pte_store:%x\n", &p[PTX(va)], p[PTX(va)]);

	if (!(p[PTX(va)] & PTE_P))
f0100ba4:	c1 ea 0c             	shr    $0xc,%edx
f0100ba7:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100bad:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100bb4:	89 c2                	mov    %eax,%edx
f0100bb6:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100bb9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100bbe:	85 d2                	test   %edx,%edx
f0100bc0:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100bc5:	0f 44 c2             	cmove  %edx,%eax
f0100bc8:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100bc9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	// cprintf("[?] *pte_store:%x, **pte_store:%x\n", &p[PTX(va)], p[PTX(va)]);

	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100bce:	c3                   	ret    

f0100bcf <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100bcf:	55                   	push   %ebp
f0100bd0:	89 e5                	mov    %esp,%ebp
f0100bd2:	57                   	push   %edi
f0100bd3:	56                   	push   %esi
f0100bd4:	53                   	push   %ebx
f0100bd5:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100bd8:	84 c0                	test   %al,%al
f0100bda:	0f 85 a0 02 00 00    	jne    f0100e80 <check_page_free_list+0x2b1>
f0100be0:	e9 ad 02 00 00       	jmp    f0100e92 <check_page_free_list+0x2c3>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100be5:	83 ec 04             	sub    $0x4,%esp
f0100be8:	68 4c 6d 10 f0       	push   $0xf0106d4c
f0100bed:	68 71 03 00 00       	push   $0x371
f0100bf2:	68 df 69 10 f0       	push   $0xf01069df
f0100bf7:	e8 44 f4 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100bfc:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100bff:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100c02:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100c05:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100c08:	89 c2                	mov    %eax,%edx
f0100c0a:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f0100c10:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100c16:	0f 95 c2             	setne  %dl
f0100c19:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100c1c:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100c20:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100c22:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c26:	8b 00                	mov    (%eax),%eax
f0100c28:	85 c0                	test   %eax,%eax
f0100c2a:	75 dc                	jne    f0100c08 <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100c2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c2f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100c35:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c38:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100c3b:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100c3d:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100c40:	a3 40 12 21 f0       	mov    %eax,0xf0211240
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c45:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c4a:	8b 1d 40 12 21 f0    	mov    0xf0211240,%ebx
f0100c50:	eb 53                	jmp    f0100ca5 <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c52:	89 d8                	mov    %ebx,%eax
f0100c54:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0100c5a:	c1 f8 03             	sar    $0x3,%eax
f0100c5d:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100c60:	89 c2                	mov    %eax,%edx
f0100c62:	c1 ea 16             	shr    $0x16,%edx
f0100c65:	39 f2                	cmp    %esi,%edx
f0100c67:	73 3a                	jae    f0100ca3 <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c69:	89 c2                	mov    %eax,%edx
f0100c6b:	c1 ea 0c             	shr    $0xc,%edx
f0100c6e:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f0100c74:	72 12                	jb     f0100c88 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c76:	50                   	push   %eax
f0100c77:	68 24 64 10 f0       	push   $0xf0106424
f0100c7c:	6a 58                	push   $0x58
f0100c7e:	68 eb 69 10 f0       	push   $0xf01069eb
f0100c83:	e8 b8 f3 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100c88:	83 ec 04             	sub    $0x4,%esp
f0100c8b:	68 80 00 00 00       	push   $0x80
f0100c90:	68 97 00 00 00       	push   $0x97
f0100c95:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c9a:	50                   	push   %eax
f0100c9b:	e8 97 4a 00 00       	call   f0105737 <memset>
f0100ca0:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100ca3:	8b 1b                	mov    (%ebx),%ebx
f0100ca5:	85 db                	test   %ebx,%ebx
f0100ca7:	75 a9                	jne    f0100c52 <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100ca9:	b8 00 00 00 00       	mov    $0x0,%eax
f0100cae:	e8 65 fe ff ff       	call   f0100b18 <boot_alloc>
f0100cb3:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100cb6:	8b 15 40 12 21 f0    	mov    0xf0211240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100cbc:	8b 0d 90 1e 21 f0    	mov    0xf0211e90,%ecx
		assert(pp < pages + npages);
f0100cc2:	a1 88 1e 21 f0       	mov    0xf0211e88,%eax
f0100cc7:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100cca:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100ccd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100cd0:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100cd3:	be 00 00 00 00       	mov    $0x0,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100cd8:	e9 52 01 00 00       	jmp    f0100e2f <check_page_free_list+0x260>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100cdd:	39 ca                	cmp    %ecx,%edx
f0100cdf:	73 19                	jae    f0100cfa <check_page_free_list+0x12b>
f0100ce1:	68 f9 69 10 f0       	push   $0xf01069f9
f0100ce6:	68 05 6a 10 f0       	push   $0xf0106a05
f0100ceb:	68 8b 03 00 00       	push   $0x38b
f0100cf0:	68 df 69 10 f0       	push   $0xf01069df
f0100cf5:	e8 46 f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100cfa:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100cfd:	72 19                	jb     f0100d18 <check_page_free_list+0x149>
f0100cff:	68 1a 6a 10 f0       	push   $0xf0106a1a
f0100d04:	68 05 6a 10 f0       	push   $0xf0106a05
f0100d09:	68 8c 03 00 00       	push   $0x38c
f0100d0e:	68 df 69 10 f0       	push   $0xf01069df
f0100d13:	e8 28 f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d18:	89 d0                	mov    %edx,%eax
f0100d1a:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100d1d:	a8 07                	test   $0x7,%al
f0100d1f:	74 19                	je     f0100d3a <check_page_free_list+0x16b>
f0100d21:	68 70 6d 10 f0       	push   $0xf0106d70
f0100d26:	68 05 6a 10 f0       	push   $0xf0106a05
f0100d2b:	68 8d 03 00 00       	push   $0x38d
f0100d30:	68 df 69 10 f0       	push   $0xf01069df
f0100d35:	e8 06 f3 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100d3a:	c1 f8 03             	sar    $0x3,%eax
f0100d3d:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100d40:	85 c0                	test   %eax,%eax
f0100d42:	75 19                	jne    f0100d5d <check_page_free_list+0x18e>
f0100d44:	68 2e 6a 10 f0       	push   $0xf0106a2e
f0100d49:	68 05 6a 10 f0       	push   $0xf0106a05
f0100d4e:	68 90 03 00 00       	push   $0x390
f0100d53:	68 df 69 10 f0       	push   $0xf01069df
f0100d58:	e8 e3 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d5d:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d62:	75 19                	jne    f0100d7d <check_page_free_list+0x1ae>
f0100d64:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0100d69:	68 05 6a 10 f0       	push   $0xf0106a05
f0100d6e:	68 91 03 00 00       	push   $0x391
f0100d73:	68 df 69 10 f0       	push   $0xf01069df
f0100d78:	e8 c3 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d7d:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d82:	75 19                	jne    f0100d9d <check_page_free_list+0x1ce>
f0100d84:	68 a4 6d 10 f0       	push   $0xf0106da4
f0100d89:	68 05 6a 10 f0       	push   $0xf0106a05
f0100d8e:	68 92 03 00 00       	push   $0x392
f0100d93:	68 df 69 10 f0       	push   $0xf01069df
f0100d98:	e8 a3 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d9d:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100da2:	75 19                	jne    f0100dbd <check_page_free_list+0x1ee>
f0100da4:	68 58 6a 10 f0       	push   $0xf0106a58
f0100da9:	68 05 6a 10 f0       	push   $0xf0106a05
f0100dae:	68 93 03 00 00       	push   $0x393
f0100db3:	68 df 69 10 f0       	push   $0xf01069df
f0100db8:	e8 83 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100dbd:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100dc2:	0f 86 f1 00 00 00    	jbe    f0100eb9 <check_page_free_list+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100dc8:	89 c7                	mov    %eax,%edi
f0100dca:	c1 ef 0c             	shr    $0xc,%edi
f0100dcd:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0100dd0:	77 12                	ja     f0100de4 <check_page_free_list+0x215>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100dd2:	50                   	push   %eax
f0100dd3:	68 24 64 10 f0       	push   $0xf0106424
f0100dd8:	6a 58                	push   $0x58
f0100dda:	68 eb 69 10 f0       	push   $0xf01069eb
f0100ddf:	e8 5c f2 ff ff       	call   f0100040 <_panic>
f0100de4:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100dea:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100ded:	0f 86 b6 00 00 00    	jbe    f0100ea9 <check_page_free_list+0x2da>
f0100df3:	68 c8 6d 10 f0       	push   $0xf0106dc8
f0100df8:	68 05 6a 10 f0       	push   $0xf0106a05
f0100dfd:	68 94 03 00 00       	push   $0x394
f0100e02:	68 df 69 10 f0       	push   $0xf01069df
f0100e07:	e8 34 f2 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e0c:	68 72 6a 10 f0       	push   $0xf0106a72
f0100e11:	68 05 6a 10 f0       	push   $0xf0106a05
f0100e16:	68 96 03 00 00       	push   $0x396
f0100e1b:	68 df 69 10 f0       	push   $0xf01069df
f0100e20:	e8 1b f2 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100e25:	83 c6 01             	add    $0x1,%esi
f0100e28:	eb 03                	jmp    f0100e2d <check_page_free_list+0x25e>
		else
			++nfree_extmem;
f0100e2a:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e2d:	8b 12                	mov    (%edx),%edx
f0100e2f:	85 d2                	test   %edx,%edx
f0100e31:	0f 85 a6 fe ff ff    	jne    f0100cdd <check_page_free_list+0x10e>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100e37:	85 f6                	test   %esi,%esi
f0100e39:	7f 19                	jg     f0100e54 <check_page_free_list+0x285>
f0100e3b:	68 8f 6a 10 f0       	push   $0xf0106a8f
f0100e40:	68 05 6a 10 f0       	push   $0xf0106a05
f0100e45:	68 9e 03 00 00       	push   $0x39e
f0100e4a:	68 df 69 10 f0       	push   $0xf01069df
f0100e4f:	e8 ec f1 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100e54:	85 db                	test   %ebx,%ebx
f0100e56:	7f 19                	jg     f0100e71 <check_page_free_list+0x2a2>
f0100e58:	68 a1 6a 10 f0       	push   $0xf0106aa1
f0100e5d:	68 05 6a 10 f0       	push   $0xf0106a05
f0100e62:	68 9f 03 00 00       	push   $0x39f
f0100e67:	68 df 69 10 f0       	push   $0xf01069df
f0100e6c:	e8 cf f1 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100e71:	83 ec 0c             	sub    $0xc,%esp
f0100e74:	68 10 6e 10 f0       	push   $0xf0106e10
f0100e79:	e8 e4 2a 00 00       	call   f0103962 <cprintf>
}
f0100e7e:	eb 49                	jmp    f0100ec9 <check_page_free_list+0x2fa>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100e80:	a1 40 12 21 f0       	mov    0xf0211240,%eax
f0100e85:	85 c0                	test   %eax,%eax
f0100e87:	0f 85 6f fd ff ff    	jne    f0100bfc <check_page_free_list+0x2d>
f0100e8d:	e9 53 fd ff ff       	jmp    f0100be5 <check_page_free_list+0x16>
f0100e92:	83 3d 40 12 21 f0 00 	cmpl   $0x0,0xf0211240
f0100e99:	0f 84 46 fd ff ff    	je     f0100be5 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e9f:	be 00 04 00 00       	mov    $0x400,%esi
f0100ea4:	e9 a1 fd ff ff       	jmp    f0100c4a <check_page_free_list+0x7b>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100ea9:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100eae:	0f 85 76 ff ff ff    	jne    f0100e2a <check_page_free_list+0x25b>
f0100eb4:	e9 53 ff ff ff       	jmp    f0100e0c <check_page_free_list+0x23d>
f0100eb9:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100ebe:	0f 85 61 ff ff ff    	jne    f0100e25 <check_page_free_list+0x256>
f0100ec4:	e9 43 ff ff ff       	jmp    f0100e0c <check_page_free_list+0x23d>

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);

	cprintf("check_page_free_list() succeeded!\n");
}
f0100ec9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ecc:	5b                   	pop    %ebx
f0100ecd:	5e                   	pop    %esi
f0100ece:	5f                   	pop    %edi
f0100ecf:	5d                   	pop    %ebp
f0100ed0:	c3                   	ret    

f0100ed1 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100ed1:	55                   	push   %ebp
f0100ed2:	89 e5                	mov    %esp,%ebp
f0100ed4:	56                   	push   %esi
f0100ed5:	53                   	push   %ebx
	// 	pages[i].pp_link = page_free_list;
	// 	page_free_list = &pages[i];
	// }

	// 1)	first page in use
	pages[0].pp_ref = 1;
f0100ed6:	a1 90 1e 21 f0       	mov    0xf0211e90,%eax
f0100edb:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	pages[0].pp_link = 0;
f0100ee1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	extern unsigned char mpentry_start[], mpentry_end[];
	uint32_t size = ROUNDUP(mpentry_end - mpentry_start, PGSIZE);
f0100ee7:	be b5 69 10 f0       	mov    $0xf01069b5,%esi
f0100eec:	81 ee 3c 59 10 f0    	sub    $0xf010593c,%esi
f0100ef2:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	// cprintf("[?] Init from 0x%x to 0x%x\n", PGSIZE, PGSIZE * npages_basemem);

	// 2)	[1-npages_basemem) free, except APs area (lab4)
	for (i = 1; i < npages_basemem; i++) {
f0100ef8:	bb 01 00 00 00       	mov    $0x1,%ebx
		if (i * PGSIZE >= MPENTRY_PADDR && i * PGSIZE < MPENTRY_PADDR + size) {
f0100efd:	81 c6 00 70 00 00    	add    $0x7000,%esi
	extern unsigned char mpentry_start[], mpentry_end[];
	uint32_t size = ROUNDUP(mpentry_end - mpentry_start, PGSIZE);
	// cprintf("[?] Init from 0x%x to 0x%x\n", PGSIZE, PGSIZE * npages_basemem);

	// 2)	[1-npages_basemem) free, except APs area (lab4)
	for (i = 1; i < npages_basemem; i++) {
f0100f03:	eb 61                	jmp    f0100f66 <page_init+0x95>
f0100f05:	89 d8                	mov    %ebx,%eax
f0100f07:	c1 e0 0c             	shl    $0xc,%eax
		if (i * PGSIZE >= MPENTRY_PADDR && i * PGSIZE < MPENTRY_PADDR + size) {
f0100f0a:	3d ff 6f 00 00       	cmp    $0x6fff,%eax
f0100f0f:	76 2a                	jbe    f0100f3b <page_init+0x6a>
f0100f11:	39 c6                	cmp    %eax,%esi
f0100f13:	76 26                	jbe    f0100f3b <page_init+0x6a>
			pages[i].pp_ref = 1;
f0100f15:	a1 90 1e 21 f0       	mov    0xf0211e90,%eax
f0100f1a:	8d 04 d8             	lea    (%eax,%ebx,8),%eax
f0100f1d:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link = 0;
f0100f23:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			cprintf("[?] non-boot CPUs (APs)\n");
f0100f29:	83 ec 0c             	sub    $0xc,%esp
f0100f2c:	68 b2 6a 10 f0       	push   $0xf0106ab2
f0100f31:	e8 2c 2a 00 00       	call   f0103962 <cprintf>
f0100f36:	83 c4 10             	add    $0x10,%esp
f0100f39:	eb 28                	jmp    f0100f63 <page_init+0x92>
		}
		else {
			pages[i].pp_ref = 0;
f0100f3b:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100f42:	89 c2                	mov    %eax,%edx
f0100f44:	03 15 90 1e 21 f0    	add    0xf0211e90,%edx
f0100f4a:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
			pages[i].pp_link = page_free_list;
f0100f50:	8b 0d 40 12 21 f0    	mov    0xf0211240,%ecx
f0100f56:	89 0a                	mov    %ecx,(%edx)
			page_free_list = &pages[i];
f0100f58:	03 05 90 1e 21 f0    	add    0xf0211e90,%eax
f0100f5e:	a3 40 12 21 f0       	mov    %eax,0xf0211240
	extern unsigned char mpentry_start[], mpentry_end[];
	uint32_t size = ROUNDUP(mpentry_end - mpentry_start, PGSIZE);
	// cprintf("[?] Init from 0x%x to 0x%x\n", PGSIZE, PGSIZE * npages_basemem);

	// 2)	[1-npages_basemem) free, except APs area (lab4)
	for (i = 1; i < npages_basemem; i++) {
f0100f63:	83 c3 01             	add    $0x1,%ebx
f0100f66:	3b 1d 44 12 21 f0    	cmp    0xf0211244,%ebx
f0100f6c:	72 97                	jb     f0100f05 <page_init+0x34>
f0100f6e:	8b 0d 40 12 21 f0    	mov    0xf0211240,%ecx
f0100f74:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100f7b:	ba 00 00 00 00       	mov    $0x0,%edx
f0100f80:	eb 23                	jmp    f0100fa5 <page_init+0xd4>
	}

	// [npages_basemem, IOPHYSMEM / PGSIZE) free
	// cprintf("[?] %d, %d, %d\n", npages_basemem, IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE);
	for (; i < IOPHYSMEM / PGSIZE; i++) {
		pages[i].pp_ref = 0;
f0100f82:	89 c2                	mov    %eax,%edx
f0100f84:	03 15 90 1e 21 f0    	add    0xf0211e90,%edx
f0100f8a:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f0100f90:	89 0a                	mov    %ecx,(%edx)
		page_free_list = &pages[i];
f0100f92:	89 c1                	mov    %eax,%ecx
f0100f94:	03 0d 90 1e 21 f0    	add    0xf0211e90,%ecx
		}
	}

	// [npages_basemem, IOPHYSMEM / PGSIZE) free
	// cprintf("[?] %d, %d, %d\n", npages_basemem, IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE);
	for (; i < IOPHYSMEM / PGSIZE; i++) {
f0100f9a:	83 c3 01             	add    $0x1,%ebx
f0100f9d:	83 c0 08             	add    $0x8,%eax
f0100fa0:	ba 01 00 00 00       	mov    $0x1,%edx
f0100fa5:	81 fb 9f 00 00 00    	cmp    $0x9f,%ebx
f0100fab:	76 d5                	jbe    f0100f82 <page_init+0xb1>
f0100fad:	84 d2                	test   %dl,%dl
f0100faf:	74 06                	je     f0100fb7 <page_init+0xe6>
f0100fb1:	89 0d 40 12 21 f0    	mov    %ecx,0xf0211240
f0100fb7:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100fbe:	eb 1a                	jmp    f0100fda <page_init+0x109>
		page_free_list = &pages[i];
	}

	// 3) [IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE) in use
	for (; i < EXTPHYSMEM / PGSIZE; i++) {
		pages[i].pp_ref = 1;
f0100fc0:	89 c2                	mov    %eax,%edx
f0100fc2:	03 15 90 1e 21 f0    	add    0xf0211e90,%edx
f0100fc8:	66 c7 42 04 01 00    	movw   $0x1,0x4(%edx)
		pages[i].pp_link = 0;
f0100fce:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}

	// 3) [IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE) in use
	for (; i < EXTPHYSMEM / PGSIZE; i++) {
f0100fd4:	83 c3 01             	add    $0x1,%ebx
f0100fd7:	83 c0 08             	add    $0x8,%eax
f0100fda:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f0100fe0:	76 de                	jbe    f0100fc0 <page_init+0xef>
f0100fe2:	8d 34 dd 00 00 00 00 	lea    0x0(,%ebx,8),%esi
f0100fe9:	eb 1a                	jmp    f0101005 <page_init+0x134>

	// cprintf("[?] Init from 0x%x to 0x%x\n", EXTPHYSMEM, PGSIZE * npages);
	// cprintf("[?] %d\n", PADDR(boot_alloc(0)) / PGSIZE);
	// 4) [EXTPHYSMEM / PGSIZE, kernel end) in use
	for (; i < PADDR(boot_alloc(0)) / PGSIZE; i++) {
		pages[i].pp_ref = 1;
f0100feb:	89 f0                	mov    %esi,%eax
f0100fed:	03 05 90 1e 21 f0    	add    0xf0211e90,%eax
f0100ff3:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
		pages[i].pp_link = 0;
f0100ff9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}

	// cprintf("[?] Init from 0x%x to 0x%x\n", EXTPHYSMEM, PGSIZE * npages);
	// cprintf("[?] %d\n", PADDR(boot_alloc(0)) / PGSIZE);
	// 4) [EXTPHYSMEM / PGSIZE, kernel end) in use
	for (; i < PADDR(boot_alloc(0)) / PGSIZE; i++) {
f0100fff:	83 c3 01             	add    $0x1,%ebx
f0101002:	83 c6 08             	add    $0x8,%esi
f0101005:	b8 00 00 00 00       	mov    $0x0,%eax
f010100a:	e8 09 fb ff ff       	call   f0100b18 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010100f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101014:	77 15                	ja     f010102b <page_init+0x15a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101016:	50                   	push   %eax
f0101017:	68 48 64 10 f0       	push   $0xf0106448
f010101c:	68 7d 01 00 00       	push   $0x17d
f0101021:	68 df 69 10 f0       	push   $0xf01069df
f0101026:	e8 15 f0 ff ff       	call   f0100040 <_panic>
f010102b:	05 00 00 00 10       	add    $0x10000000,%eax
f0101030:	c1 e8 0c             	shr    $0xc,%eax
f0101033:	39 c3                	cmp    %eax,%ebx
f0101035:	72 b4                	jb     f0100feb <page_init+0x11a>
f0101037:	8b 0d 40 12 21 f0    	mov    0xf0211240,%ecx
f010103d:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0101044:	ba 00 00 00 00       	mov    $0x0,%edx
f0101049:	eb 23                	jmp    f010106e <page_init+0x19d>
		pages[i].pp_link = 0;
	}

	// [kernel end, npages) free
	for (; i < npages; i++) {
		pages[i].pp_ref = 0;
f010104b:	89 c2                	mov    %eax,%edx
f010104d:	03 15 90 1e 21 f0    	add    0xf0211e90,%edx
f0101053:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f0101059:	89 0a                	mov    %ecx,(%edx)
		page_free_list = &pages[i];
f010105b:	89 c1                	mov    %eax,%ecx
f010105d:	03 0d 90 1e 21 f0    	add    0xf0211e90,%ecx
		pages[i].pp_ref = 1;
		pages[i].pp_link = 0;
	}

	// [kernel end, npages) free
	for (; i < npages; i++) {
f0101063:	83 c3 01             	add    $0x1,%ebx
f0101066:	83 c0 08             	add    $0x8,%eax
f0101069:	ba 01 00 00 00       	mov    $0x1,%edx
f010106e:	3b 1d 88 1e 21 f0    	cmp    0xf0211e88,%ebx
f0101074:	72 d5                	jb     f010104b <page_init+0x17a>
f0101076:	84 d2                	test   %dl,%dl
f0101078:	74 06                	je     f0101080 <page_init+0x1af>
f010107a:	89 0d 40 12 21 f0    	mov    %ecx,0xf0211240
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}

}
f0101080:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101083:	5b                   	pop    %ebx
f0101084:	5e                   	pop    %esi
f0101085:	5d                   	pop    %ebp
f0101086:	c3                   	ret    

f0101087 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0101087:	55                   	push   %ebp
f0101088:	89 e5                	mov    %esp,%ebp
f010108a:	56                   	push   %esi
f010108b:	53                   	push   %ebx
	// Fill this function in

	// no more page in free list, we run out of free memory
	if (page_free_list == 0)
f010108c:	8b 1d 40 12 21 f0    	mov    0xf0211240,%ebx
f0101092:	85 db                	test   %ebx,%ebx
f0101094:	74 59                	je     f01010ef <page_alloc+0x68>
		return 0;

	// get the previous page in free link
	struct PageInfo* last_free = page_free_list->pp_link;
f0101096:	8b 33                	mov    (%ebx),%esi
	struct PageInfo* result = page_free_list;

	// get a free page from the list
	page_free_list->pp_link = 0;
f0101098:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (alloc_flags & ALLOC_ZERO) {
f010109e:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01010a2:	74 45                	je     f01010e9 <page_alloc+0x62>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01010a4:	89 d8                	mov    %ebx,%eax
f01010a6:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f01010ac:	c1 f8 03             	sar    $0x3,%eax
f01010af:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01010b2:	89 c2                	mov    %eax,%edx
f01010b4:	c1 ea 0c             	shr    $0xc,%edx
f01010b7:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f01010bd:	72 12                	jb     f01010d1 <page_alloc+0x4a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010bf:	50                   	push   %eax
f01010c0:	68 24 64 10 f0       	push   $0xf0106424
f01010c5:	6a 58                	push   $0x58
f01010c7:	68 eb 69 10 f0       	push   $0xf01069eb
f01010cc:	e8 6f ef ff ff       	call   f0100040 <_panic>
		// cprintf("[?] alloc zero, %x, %x\n", page_free_list, PADDR(page_free_list));
		// memset((char *)page2pa(page_free_list), 0, PGSIZE);
		memset(page2kva(page_free_list), 0, PGSIZE);
f01010d1:	83 ec 04             	sub    $0x4,%esp
f01010d4:	68 00 10 00 00       	push   $0x1000
f01010d9:	6a 00                	push   $0x0
f01010db:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01010e0:	50                   	push   %eax
f01010e1:	e8 51 46 00 00       	call   f0105737 <memset>
f01010e6:	83 c4 10             	add    $0x10,%esp
	}
	
	// update free list head
	page_free_list = last_free;
f01010e9:	89 35 40 12 21 f0    	mov    %esi,0xf0211240

	return result;
}
f01010ef:	89 d8                	mov    %ebx,%eax
f01010f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01010f4:	5b                   	pop    %ebx
f01010f5:	5e                   	pop    %esi
f01010f6:	5d                   	pop    %ebp
f01010f7:	c3                   	ret    

f01010f8 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f01010f8:	55                   	push   %ebp
f01010f9:	89 e5                	mov    %esp,%ebp
f01010fb:	83 ec 08             	sub    $0x8,%esp
f01010fe:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.

	if (pp == 0)
f0101101:	85 c0                	test   %eax,%eax
f0101103:	74 47                	je     f010114c <page_free+0x54>
		return;
	if (pp->pp_link != 0)
f0101105:	83 38 00             	cmpl   $0x0,(%eax)
f0101108:	74 17                	je     f0101121 <page_free+0x29>
		panic("page_free: double free or corrupted\n");
f010110a:	83 ec 04             	sub    $0x4,%esp
f010110d:	68 34 6e 10 f0       	push   $0xf0106e34
f0101112:	68 c1 01 00 00       	push   $0x1c1
f0101117:	68 df 69 10 f0       	push   $0xf01069df
f010111c:	e8 1f ef ff ff       	call   f0100040 <_panic>
	if (pp->pp_ref != 0)
f0101121:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101126:	74 17                	je     f010113f <page_free+0x47>
		panic("page_free: other pointers still point to it, mind use-after-free!\n");
f0101128:	83 ec 04             	sub    $0x4,%esp
f010112b:	68 5c 6e 10 f0       	push   $0xf0106e5c
f0101130:	68 c3 01 00 00       	push   $0x1c3
f0101135:	68 df 69 10 f0       	push   $0xf01069df
f010113a:	e8 01 ef ff ff       	call   f0100040 <_panic>

	pp->pp_link = page_free_list;
f010113f:	8b 15 40 12 21 f0    	mov    0xf0211240,%edx
f0101145:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101147:	a3 40 12 21 f0       	mov    %eax,0xf0211240

}
f010114c:	c9                   	leave  
f010114d:	c3                   	ret    

f010114e <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f010114e:	55                   	push   %ebp
f010114f:	89 e5                	mov    %esp,%ebp
f0101151:	83 ec 08             	sub    $0x8,%esp
f0101154:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0101157:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f010115b:	83 e8 01             	sub    $0x1,%eax
f010115e:	66 89 42 04          	mov    %ax,0x4(%edx)
f0101162:	66 85 c0             	test   %ax,%ax
f0101165:	75 0c                	jne    f0101173 <page_decref+0x25>
		page_free(pp);
f0101167:	83 ec 0c             	sub    $0xc,%esp
f010116a:	52                   	push   %edx
f010116b:	e8 88 ff ff ff       	call   f01010f8 <page_free>
f0101170:	83 c4 10             	add    $0x10,%esp
}
f0101173:	c9                   	leave  
f0101174:	c3                   	ret    

f0101175 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that manipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0101175:	55                   	push   %ebp
f0101176:	89 e5                	mov    %esp,%ebp
f0101178:	57                   	push   %edi
f0101179:	56                   	push   %esi
f010117a:	53                   	push   %ebx
f010117b:	83 ec 0c             	sub    $0xc,%esp
f010117e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in

	// we have virtual address
	// cprintf("[?] %x\n", va);

	if ((uint32_t)va == 0xeebfe000)
f0101181:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
f0101187:	0f 85 c8 00 00 00    	jne    f0101255 <pgdir_walk+0xe0>
		cprintf("Error hit\n");
f010118d:	83 ec 0c             	sub    $0xc,%esp
f0101190:	68 cb 6a 10 f0       	push   $0xf0106acb
f0101195:	e8 c8 27 00 00       	call   f0103962 <cprintf>
	uint32_t Page_Directory_Index = PDX(va);
	uint32_t Page_Table_Index = PTX(va);
	uint32_t Offset_In_PTE = PGOFF(va);

	// level 2 page table not exist
	if (pgdir[Page_Directory_Index] == 0) {
f010119a:	8b 45 08             	mov    0x8(%ebp),%eax
f010119d:	8d b8 e8 0e 00 00    	lea    0xee8(%eax),%edi
f01011a3:	83 c4 10             	add    $0x10,%esp
f01011a6:	83 b8 e8 0e 00 00 00 	cmpl   $0x0,0xee8(%eax)
f01011ad:	75 53                	jne    f0101202 <pgdir_walk+0x8d>

		if ((uint32_t)va == 0xeebfe000)
			cprintf("Error hit2\n");
f01011af:	83 ec 0c             	sub    $0xc,%esp
f01011b2:	68 d6 6a 10 f0       	push   $0xf0106ad6
f01011b7:	e8 a6 27 00 00       	call   f0103962 <cprintf>
f01011bc:	83 c4 10             	add    $0x10,%esp

	if ((uint32_t)va == 0xeebfe000)
		cprintf("Error hit\n");

	uint32_t Page_Directory_Index = PDX(va);
	uint32_t Page_Table_Index = PTX(va);
f01011bf:	be fe 03 00 00       	mov    $0x3fe,%esi
	if (pgdir[Page_Directory_Index] == 0) {

		if ((uint32_t)va == 0xeebfe000)
			cprintf("Error hit2\n");

		if (create == 0)
f01011c4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01011c8:	74 7d                	je     f0101247 <pgdir_walk+0xd2>
			return NULL;
		
		// allocate a new physical page to be a page table
		struct PageInfo *new_page = page_alloc(ALLOC_ZERO);
f01011ca:	83 ec 0c             	sub    $0xc,%esp
f01011cd:	6a 01                	push   $0x1
f01011cf:	e8 b3 fe ff ff       	call   f0101087 <page_alloc>
		// cprintf("[??] %x\n", new_page);
		if (new_page == 0)	// page allocate fail
f01011d4:	83 c4 10             	add    $0x10,%esp
f01011d7:	85 c0                	test   %eax,%eax
f01011d9:	74 73                	je     f010124e <pgdir_walk+0xd9>
		// set level 1 page table entry to this new level 2 page table
		// this new page is for level2 PT, so flags are:
		// 	PTE_P: this page is present
		//	PTE_U: user process can use this page
		//	PTE_W: this page can be edit
		pgdir[Page_Directory_Index] = page2pa(new_page) | PTE_P | PTE_U | PTE_W;
f01011db:	89 c2                	mov    %eax,%edx
f01011dd:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f01011e3:	c1 fa 03             	sar    $0x3,%edx
f01011e6:	c1 e2 0c             	shl    $0xc,%edx
f01011e9:	83 ca 07             	or     $0x7,%edx
f01011ec:	89 17                	mov    %edx,(%edi)
		new_page->pp_ref = 1;
f01011ee:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)

	}

	if ((uint32_t)va == 0xeebfe000)
f01011f4:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
f01011fa:	0f 85 9e 00 00 00    	jne    f010129e <pgdir_walk+0x129>
f0101200:	eb 05                	jmp    f0101207 <pgdir_walk+0x92>

	if ((uint32_t)va == 0xeebfe000)
		cprintf("Error hit\n");

	uint32_t Page_Directory_Index = PDX(va);
	uint32_t Page_Table_Index = PTX(va);
f0101202:	be fe 03 00 00       	mov    $0x3fe,%esi
		new_page->pp_ref = 1;

	}

	if ((uint32_t)va == 0xeebfe000)
		cprintf("Error hit3, 0x%x\n", pgdir[Page_Directory_Index]);
f0101207:	83 ec 08             	sub    $0x8,%esp
f010120a:	ff 37                	pushl  (%edi)
f010120c:	68 e2 6a 10 f0       	push   $0xf0106ae2
f0101211:	e8 4c 27 00 00       	call   f0103962 <cprintf>
	// cprintf("[?] %x\n", KADDR(PTE_ADDR(pgdir[Page_Directory_Index])));
	
	// remember each entry is 4 byte long
	// so we need to convert type to pte_t * in order to add 4 on address each time
	// instead of add 1
	pte_t *p = (pte_t *) KADDR(PTE_ADDR(pgdir[Page_Directory_Index]));
f0101216:	8b 07                	mov    (%edi),%eax
f0101218:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010121d:	89 c2                	mov    %eax,%edx
f010121f:	c1 ea 0c             	shr    $0xc,%edx
f0101222:	83 c4 10             	add    $0x10,%esp
f0101225:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f010122b:	72 48                	jb     f0101275 <pgdir_walk+0x100>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010122d:	50                   	push   %eax
f010122e:	68 24 64 10 f0       	push   $0xf0106424
f0101233:	68 1c 02 00 00       	push   $0x21c
f0101238:	68 df 69 10 f0       	push   $0xf01069df
f010123d:	e8 fe ed ff ff       	call   f0100040 <_panic>

	if ((uint32_t)va == 0xeebfe000)
		cprintf("Error hit4, 0x%x, 0x%x\n", (uint32_t)p, (uint32_t)*p);

	return &p[Page_Table_Index];
f0101242:	8d 04 b3             	lea    (%ebx,%esi,4),%eax
f0101245:	eb 70                	jmp    f01012b7 <pgdir_walk+0x142>

		if ((uint32_t)va == 0xeebfe000)
			cprintf("Error hit2\n");

		if (create == 0)
			return NULL;
f0101247:	b8 00 00 00 00       	mov    $0x0,%eax
f010124c:	eb 69                	jmp    f01012b7 <pgdir_walk+0x142>
		
		// allocate a new physical page to be a page table
		struct PageInfo *new_page = page_alloc(ALLOC_ZERO);
		// cprintf("[??] %x\n", new_page);
		if (new_page == 0)	// page allocate fail
			return NULL;
f010124e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101253:	eb 62                	jmp    f01012b7 <pgdir_walk+0x142>

	if ((uint32_t)va == 0xeebfe000)
		cprintf("Error hit\n");

	uint32_t Page_Directory_Index = PDX(va);
	uint32_t Page_Table_Index = PTX(va);
f0101255:	89 de                	mov    %ebx,%esi
f0101257:	c1 ee 0c             	shr    $0xc,%esi
f010125a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	uint32_t Offset_In_PTE = PGOFF(va);

	// level 2 page table not exist
	if (pgdir[Page_Directory_Index] == 0) {
f0101260:	89 d8                	mov    %ebx,%eax
f0101262:	c1 e8 16             	shr    $0x16,%eax
f0101265:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101268:	8d 3c 81             	lea    (%ecx,%eax,4),%edi
f010126b:	83 3f 00             	cmpl   $0x0,(%edi)
f010126e:	75 2e                	jne    f010129e <pgdir_walk+0x129>
f0101270:	e9 4f ff ff ff       	jmp    f01011c4 <pgdir_walk+0x4f>
	return (void *)(pa + KERNBASE);
f0101275:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
f010127b:	89 d3                	mov    %edx,%ebx
	// so we need to convert type to pte_t * in order to add 4 on address each time
	// instead of add 1
	pte_t *p = (pte_t *) KADDR(PTE_ADDR(pgdir[Page_Directory_Index]));

	if ((uint32_t)va == 0xeebfe000)
		cprintf("Error hit4, 0x%x, 0x%x\n", (uint32_t)p, (uint32_t)*p);
f010127d:	83 ec 04             	sub    $0x4,%esp
f0101280:	ff b0 00 00 00 f0    	pushl  -0x10000000(%eax)
f0101286:	52                   	push   %edx
f0101287:	68 f4 6a 10 f0       	push   $0xf0106af4
f010128c:	e8 d1 26 00 00       	call   f0103962 <cprintf>
f0101291:	83 c4 10             	add    $0x10,%esp
f0101294:	eb ac                	jmp    f0101242 <pgdir_walk+0xcd>
f0101296:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f010129c:	eb a4                	jmp    f0101242 <pgdir_walk+0xcd>
	// cprintf("[?] %x\n", KADDR(PTE_ADDR(pgdir[Page_Directory_Index])));
	
	// remember each entry is 4 byte long
	// so we need to convert type to pte_t * in order to add 4 on address each time
	// instead of add 1
	pte_t *p = (pte_t *) KADDR(PTE_ADDR(pgdir[Page_Directory_Index]));
f010129e:	8b 07                	mov    (%edi),%eax
f01012a0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01012a5:	89 c2                	mov    %eax,%edx
f01012a7:	c1 ea 0c             	shr    $0xc,%edx
f01012aa:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f01012b0:	72 e4                	jb     f0101296 <pgdir_walk+0x121>
f01012b2:	e9 76 ff ff ff       	jmp    f010122d <pgdir_walk+0xb8>

	if ((uint32_t)va == 0xeebfe000)
		cprintf("Error hit4, 0x%x, 0x%x\n", (uint32_t)p, (uint32_t)*p);

	return &p[Page_Table_Index];
}
f01012b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012ba:	5b                   	pop    %ebx
f01012bb:	5e                   	pop    %esi
f01012bc:	5f                   	pop    %edi
f01012bd:	5d                   	pop    %ebp
f01012be:	c3                   	ret    

f01012bf <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f01012bf:	55                   	push   %ebp
f01012c0:	89 e5                	mov    %esp,%ebp
f01012c2:	57                   	push   %edi
f01012c3:	56                   	push   %esi
f01012c4:	53                   	push   %ebx
f01012c5:	83 ec 20             	sub    $0x20,%esp
f01012c8:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01012cb:	89 d7                	mov    %edx,%edi
f01012cd:	89 cb                	mov    %ecx,%ebx
	
	cprintf("[boot_map_region] 0x%x, len 0x%x\n", va, size);
f01012cf:	51                   	push   %ecx
f01012d0:	52                   	push   %edx
f01012d1:	68 a0 6e 10 f0       	push   $0xf0106ea0
f01012d6:	e8 87 26 00 00       	call   f0103962 <cprintf>
	
	// Fill this function in	
	if (size % PGSIZE != 0)
f01012db:	83 c4 10             	add    $0x10,%esp
f01012de:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f01012e4:	74 17                	je     f01012fd <boot_map_region+0x3e>
		panic("boot_map_region: size is not a multiple of PGSIZE\n");
f01012e6:	83 ec 04             	sub    $0x4,%esp
f01012e9:	68 c4 6e 10 f0       	push   $0xf0106ec4
f01012ee:	68 37 02 00 00       	push   $0x237
f01012f3:	68 df 69 10 f0       	push   $0xf01069df
f01012f8:	e8 43 ed ff ff       	call   f0100040 <_panic>
	
	if (va % PGSIZE != 0 || pa % PGSIZE != 0)
f01012fd:	f7 c7 ff 0f 00 00    	test   $0xfff,%edi
f0101303:	75 24                	jne    f0101329 <boot_map_region+0x6a>
f0101305:	f7 45 08 ff 0f 00 00 	testl  $0xfff,0x8(%ebp)
f010130c:	75 1b                	jne    f0101329 <boot_map_region+0x6a>
f010130e:	c1 eb 0c             	shr    $0xc,%ebx
f0101311:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
		panic("boot_map_region: va or pa is not page-aligned\n");


	// set all pages related
	for (int i=0; i<size/PGSIZE; i++) {
f0101314:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101317:	be 00 00 00 00       	mov    $0x0,%esi

		// find the real PTE for va
		// create on walk, if not present
		pte_t* pte = pgdir_walk(pgdir, (void *)va, 1);	
f010131c:	29 df                	sub    %ebx,%edi

		// set the real PTE to pa, zero out least 12 bits
		*pte = PTE_ADDR(pa);
		
		// set flags
		*pte |= (perm | PTE_P);
f010131e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101321:	83 c8 01             	or     $0x1,%eax
f0101324:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0101327:	eb 5c                	jmp    f0101385 <boot_map_region+0xc6>
	// Fill this function in	
	if (size % PGSIZE != 0)
		panic("boot_map_region: size is not a multiple of PGSIZE\n");
	
	if (va % PGSIZE != 0 || pa % PGSIZE != 0)
		panic("boot_map_region: va or pa is not page-aligned\n");
f0101329:	83 ec 04             	sub    $0x4,%esp
f010132c:	68 f8 6e 10 f0       	push   $0xf0106ef8
f0101331:	68 3a 02 00 00       	push   $0x23a
f0101336:	68 df 69 10 f0       	push   $0xf01069df
f010133b:	e8 00 ed ff ff       	call   f0100040 <_panic>
	// set all pages related
	for (int i=0; i<size/PGSIZE; i++) {

		// find the real PTE for va
		// create on walk, if not present
		pte_t* pte = pgdir_walk(pgdir, (void *)va, 1);	
f0101340:	83 ec 04             	sub    $0x4,%esp
f0101343:	6a 01                	push   $0x1
f0101345:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f0101348:	50                   	push   %eax
f0101349:	ff 75 e0             	pushl  -0x20(%ebp)
f010134c:	e8 24 fe ff ff       	call   f0101175 <pgdir_walk>

		if (pte == 0)
f0101351:	83 c4 10             	add    $0x10,%esp
f0101354:	85 c0                	test   %eax,%eax
f0101356:	75 17                	jne    f010136f <boot_map_region+0xb0>
			panic("boot_map_region: pgdir_walk return NULL\n");
f0101358:	83 ec 04             	sub    $0x4,%esp
f010135b:	68 28 6f 10 f0       	push   $0xf0106f28
f0101360:	68 45 02 00 00       	push   $0x245
f0101365:	68 df 69 10 f0       	push   $0xf01069df
f010136a:	e8 d1 ec ff ff       	call   f0100040 <_panic>

		// set the real PTE to pa, zero out least 12 bits
		*pte = PTE_ADDR(pa);
		
		// set flags
		*pte |= (perm | PTE_P);
f010136f:	89 da                	mov    %ebx,%edx
f0101371:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101377:	0b 55 dc             	or     -0x24(%ebp),%edx
f010137a:	89 10                	mov    %edx,(%eax)

		// deal with next page
		va += PGSIZE;
		pa += PGSIZE;
f010137c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	if (va % PGSIZE != 0 || pa % PGSIZE != 0)
		panic("boot_map_region: va or pa is not page-aligned\n");


	// set all pages related
	for (int i=0; i<size/PGSIZE; i++) {
f0101382:	83 c6 01             	add    $0x1,%esi
f0101385:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0101388:	75 b6                	jne    f0101340 <boot_map_region+0x81>
		va += PGSIZE;
		pa += PGSIZE;

	}

}
f010138a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010138d:	5b                   	pop    %ebx
f010138e:	5e                   	pop    %esi
f010138f:	5f                   	pop    %edi
f0101390:	5d                   	pop    %ebp
f0101391:	c3                   	ret    

f0101392 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101392:	55                   	push   %ebp
f0101393:	89 e5                	mov    %esp,%ebp
f0101395:	53                   	push   %ebx
f0101396:	83 ec 08             	sub    $0x8,%esp
f0101399:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in

	// do a page table walk to find real PTE
	pte_t * pte = pgdir_walk(pgdir, va, 0);
f010139c:	6a 00                	push   $0x0
f010139e:	ff 75 0c             	pushl  0xc(%ebp)
f01013a1:	ff 75 08             	pushl  0x8(%ebp)
f01013a4:	e8 cc fd ff ff       	call   f0101175 <pgdir_walk>

	// cprintf("[?] In page_lookup\n");
	// cprintf("[?] %x\n", pte);

	// if not present, return NULL
	if (pte == 0 || *pte == 0)
f01013a9:	83 c4 10             	add    $0x10,%esp
f01013ac:	85 c0                	test   %eax,%eax
f01013ae:	74 37                	je     f01013e7 <page_lookup+0x55>
f01013b0:	83 38 00             	cmpl   $0x0,(%eax)
f01013b3:	74 39                	je     f01013ee <page_lookup+0x5c>
		return NULL;
	
	// store pte
	if (pte_store != 0)
f01013b5:	85 db                	test   %ebx,%ebx
f01013b7:	74 02                	je     f01013bb <page_lookup+0x29>
		*pte_store = pte;
f01013b9:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01013bb:	8b 00                	mov    (%eax),%eax
f01013bd:	c1 e8 0c             	shr    $0xc,%eax
f01013c0:	3b 05 88 1e 21 f0    	cmp    0xf0211e88,%eax
f01013c6:	72 14                	jb     f01013dc <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f01013c8:	83 ec 04             	sub    $0x4,%esp
f01013cb:	68 54 6f 10 f0       	push   $0xf0106f54
f01013d0:	6a 51                	push   $0x51
f01013d2:	68 eb 69 10 f0       	push   $0xf01069eb
f01013d7:	e8 64 ec ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f01013dc:	8b 15 90 1e 21 f0    	mov    0xf0211e90,%edx
f01013e2:	8d 04 c2             	lea    (%edx,%eax,8),%eax

	return pa2page(PTE_ADDR(*pte)) ;
f01013e5:	eb 0c                	jmp    f01013f3 <page_lookup+0x61>
	// cprintf("[?] In page_lookup\n");
	// cprintf("[?] %x\n", pte);

	// if not present, return NULL
	if (pte == 0 || *pte == 0)
		return NULL;
f01013e7:	b8 00 00 00 00       	mov    $0x0,%eax
f01013ec:	eb 05                	jmp    f01013f3 <page_lookup+0x61>
f01013ee:	b8 00 00 00 00       	mov    $0x0,%eax
	// store pte
	if (pte_store != 0)
		*pte_store = pte;

	return pa2page(PTE_ADDR(*pte)) ;
}
f01013f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01013f6:	c9                   	leave  
f01013f7:	c3                   	ret    

f01013f8 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01013f8:	55                   	push   %ebp
f01013f9:	89 e5                	mov    %esp,%ebp
f01013fb:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f01013fe:	e8 57 49 00 00       	call   f0105d5a <cpunum>
f0101403:	6b c0 74             	imul   $0x74,%eax,%eax
f0101406:	83 b8 28 20 21 f0 00 	cmpl   $0x0,-0xfdedfd8(%eax)
f010140d:	74 16                	je     f0101425 <tlb_invalidate+0x2d>
f010140f:	e8 46 49 00 00       	call   f0105d5a <cpunum>
f0101414:	6b c0 74             	imul   $0x74,%eax,%eax
f0101417:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f010141d:	8b 55 08             	mov    0x8(%ebp),%edx
f0101420:	39 50 60             	cmp    %edx,0x60(%eax)
f0101423:	75 06                	jne    f010142b <tlb_invalidate+0x33>
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101425:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101428:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f010142b:	c9                   	leave  
f010142c:	c3                   	ret    

f010142d <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f010142d:	55                   	push   %ebp
f010142e:	89 e5                	mov    %esp,%ebp
f0101430:	56                   	push   %esi
f0101431:	53                   	push   %ebx
f0101432:	83 ec 14             	sub    $0x14,%esp
f0101435:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101438:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in

	// pte_t *tmp;
	pte_t *pte_store = NULL;
f010143b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	struct PageInfo * pp = page_lookup(pgdir, va, &pte_store);
f0101442:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101445:	50                   	push   %eax
f0101446:	56                   	push   %esi
f0101447:	53                   	push   %ebx
f0101448:	e8 45 ff ff ff       	call   f0101392 <page_lookup>

	// if not present, silently return
	if (pp == NULL)
f010144d:	83 c4 10             	add    $0x10,%esp
f0101450:	85 c0                	test   %eax,%eax
f0101452:	74 1f                	je     f0101473 <page_remove+0x46>
		return;

	// decrement ref count, and if reaches 0, free it
	page_decref(pp);
f0101454:	83 ec 0c             	sub    $0xc,%esp
f0101457:	50                   	push   %eax
f0101458:	e8 f1 fc ff ff       	call   f010114e <page_decref>

	// null the real PTE pointer 
	*pte_store = 0;
f010145d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101460:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	// cprintf("[?] In page_remove\n");
	// cprintf("[?] *pte_store:%x, **pte_store:%x\n", *pte_store, **pte_store);

	// tlb invalidate
	tlb_invalidate(pgdir, va);
f0101466:	83 c4 08             	add    $0x8,%esp
f0101469:	56                   	push   %esi
f010146a:	53                   	push   %ebx
f010146b:	e8 88 ff ff ff       	call   f01013f8 <tlb_invalidate>
f0101470:	83 c4 10             	add    $0x10,%esp

}
f0101473:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101476:	5b                   	pop    %ebx
f0101477:	5e                   	pop    %esi
f0101478:	5d                   	pop    %ebp
f0101479:	c3                   	ret    

f010147a <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f010147a:	55                   	push   %ebp
f010147b:	89 e5                	mov    %esp,%ebp
f010147d:	57                   	push   %edi
f010147e:	56                   	push   %esi
f010147f:	53                   	push   %ebx
f0101480:	83 ec 10             	sub    $0x10,%esp
f0101483:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101486:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in

	// find the real PTE for va
	// create on walk, if not present
	pte_t* pte = pgdir_walk(pgdir, va, 1);	
f0101489:	6a 01                	push   $0x1
f010148b:	57                   	push   %edi
f010148c:	ff 75 08             	pushl  0x8(%ebp)
f010148f:	e8 e1 fc ff ff       	call   f0101175 <pgdir_walk>

	if (pte == 0)
f0101494:	83 c4 10             	add    $0x10,%esp
f0101497:	85 c0                	test   %eax,%eax
f0101499:	74 59                	je     f01014f4 <page_insert+0x7a>
f010149b:	89 c6                	mov    %eax,%esi
		return -E_NO_MEM;

	// already have a page
	// remove it and invalidate tlb
	if (*pte != 0) {
f010149d:	8b 00                	mov    (%eax),%eax
f010149f:	85 c0                	test   %eax,%eax
f01014a1:	74 2d                	je     f01014d0 <page_insert+0x56>
		// corner case
		if (page2pa(pp) == PTE_ADDR(*pte))
f01014a3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01014a8:	89 da                	mov    %ebx,%edx
f01014aa:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f01014b0:	c1 fa 03             	sar    $0x3,%edx
f01014b3:	c1 e2 0c             	shl    $0xc,%edx
f01014b6:	39 d0                	cmp    %edx,%eax
f01014b8:	75 07                	jne    f01014c1 <page_insert+0x47>
			pp->pp_ref--;	// keep pp_ref consistent, in the meantime change perm potentially.
f01014ba:	66 83 6b 04 01       	subw   $0x1,0x4(%ebx)
f01014bf:	eb 0f                	jmp    f01014d0 <page_insert+0x56>
		else
			page_remove(pgdir, va);
f01014c1:	83 ec 08             	sub    $0x8,%esp
f01014c4:	57                   	push   %edi
f01014c5:	ff 75 08             	pushl  0x8(%ebp)
f01014c8:	e8 60 ff ff ff       	call   f010142d <page_remove>
f01014cd:	83 c4 10             	add    $0x10,%esp

	// set the real PTE to pa, zero out least 12 bits
	*pte = PTE_ADDR(page2pa(pp));
	
	// set flags
	*pte |= (perm | PTE_P);
f01014d0:	89 d8                	mov    %ebx,%eax
f01014d2:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f01014d8:	c1 f8 03             	sar    $0x3,%eax
f01014db:	c1 e0 0c             	shl    $0xc,%eax
f01014de:	8b 55 14             	mov    0x14(%ebp),%edx
f01014e1:	83 ca 01             	or     $0x1,%edx
f01014e4:	09 d0                	or     %edx,%eax
f01014e6:	89 06                	mov    %eax,(%esi)

	// increment ref cnt
	pp->pp_ref++;
f01014e8:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)

	return 0;
f01014ed:	b8 00 00 00 00       	mov    $0x0,%eax
f01014f2:	eb 05                	jmp    f01014f9 <page_insert+0x7f>
	// find the real PTE for va
	// create on walk, if not present
	pte_t* pte = pgdir_walk(pgdir, va, 1);	

	if (pte == 0)
		return -E_NO_MEM;
f01014f4:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax

	// increment ref cnt
	pp->pp_ref++;

	return 0;
}
f01014f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01014fc:	5b                   	pop    %ebx
f01014fd:	5e                   	pop    %esi
f01014fe:	5f                   	pop    %edi
f01014ff:	5d                   	pop    %ebp
f0101500:	c3                   	ret    

f0101501 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f0101501:	55                   	push   %ebp
f0101502:	89 e5                	mov    %esp,%ebp
f0101504:	56                   	push   %esi
f0101505:	53                   	push   %ebx
f0101506:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	// panic("mmio_map_region not implemented");

	uintptr_t mmio = base;
f0101509:	8b 35 00 03 12 f0    	mov    0xf0120300,%esi

	if (ROUNDUP(mmio + size, PGSIZE) >= MMIOLIM)
f010150f:	8d 84 0e ff 0f 00 00 	lea    0xfff(%esi,%ecx,1),%eax
f0101516:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010151b:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0101520:	76 17                	jbe    f0101539 <mmio_map_region+0x38>
		panic("mmio_map_region: mmio out of memory");
f0101522:	83 ec 04             	sub    $0x4,%esp
f0101525:	68 74 6f 10 f0       	push   $0xf0106f74
f010152a:	68 0c 03 00 00       	push   $0x30c
f010152f:	68 df 69 10 f0       	push   $0xf01069df
f0101534:	e8 07 eb ff ff       	call   f0100040 <_panic>
		
	boot_map_region(kern_pgdir, mmio, ROUNDUP(size, PGSIZE), pa, PTE_PCD|PTE_PWT|PTE_W);
f0101539:	8d 99 ff 0f 00 00    	lea    0xfff(%ecx),%ebx
f010153f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0101545:	83 ec 08             	sub    $0x8,%esp
f0101548:	6a 1a                	push   $0x1a
f010154a:	ff 75 08             	pushl  0x8(%ebp)
f010154d:	89 d9                	mov    %ebx,%ecx
f010154f:	89 f2                	mov    %esi,%edx
f0101551:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0101556:	e8 64 fd ff ff       	call   f01012bf <boot_map_region>

	base += ROUNDUP(size, PGSIZE);
f010155b:	01 1d 00 03 12 f0    	add    %ebx,0xf0120300

	return (void *)mmio;
}
f0101561:	89 f0                	mov    %esi,%eax
f0101563:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101566:	5b                   	pop    %ebx
f0101567:	5e                   	pop    %esi
f0101568:	5d                   	pop    %ebp
f0101569:	c3                   	ret    

f010156a <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f010156a:	55                   	push   %ebp
f010156b:	89 e5                	mov    %esp,%ebp
f010156d:	57                   	push   %edi
f010156e:	56                   	push   %esi
f010156f:	53                   	push   %ebx
f0101570:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f0101573:	b8 15 00 00 00       	mov    $0x15,%eax
f0101578:	e8 72 f5 ff ff       	call   f0100aef <nvram_read>
f010157d:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f010157f:	b8 17 00 00 00       	mov    $0x17,%eax
f0101584:	e8 66 f5 ff ff       	call   f0100aef <nvram_read>
f0101589:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f010158b:	b8 34 00 00 00       	mov    $0x34,%eax
f0101590:	e8 5a f5 ff ff       	call   f0100aef <nvram_read>
f0101595:	c1 e0 06             	shl    $0x6,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f0101598:	85 c0                	test   %eax,%eax
f010159a:	74 07                	je     f01015a3 <mem_init+0x39>
		totalmem = 16 * 1024 + ext16mem;
f010159c:	05 00 40 00 00       	add    $0x4000,%eax
f01015a1:	eb 0b                	jmp    f01015ae <mem_init+0x44>
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f01015a3:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f01015a9:	85 f6                	test   %esi,%esi
f01015ab:	0f 44 c3             	cmove  %ebx,%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f01015ae:	89 c2                	mov    %eax,%edx
f01015b0:	c1 ea 02             	shr    $0x2,%edx
f01015b3:	89 15 88 1e 21 f0    	mov    %edx,0xf0211e88
	npages_basemem = basemem / (PGSIZE / 1024);
f01015b9:	89 da                	mov    %ebx,%edx
f01015bb:	c1 ea 02             	shr    $0x2,%edx
f01015be:	89 15 44 12 21 f0    	mov    %edx,0xf0211244

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01015c4:	89 c2                	mov    %eax,%edx
f01015c6:	29 da                	sub    %ebx,%edx
f01015c8:	52                   	push   %edx
f01015c9:	53                   	push   %ebx
f01015ca:	50                   	push   %eax
f01015cb:	68 98 6f 10 f0       	push   $0xf0106f98
f01015d0:	e8 8d 23 00 00       	call   f0103962 <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01015d5:	b8 00 10 00 00       	mov    $0x1000,%eax
f01015da:	e8 39 f5 ff ff       	call   f0100b18 <boot_alloc>
f01015df:	a3 8c 1e 21 f0       	mov    %eax,0xf0211e8c
	memset(kern_pgdir, 0, PGSIZE);
f01015e4:	83 c4 0c             	add    $0xc,%esp
f01015e7:	68 00 10 00 00       	push   $0x1000
f01015ec:	6a 00                	push   $0x0
f01015ee:	50                   	push   %eax
f01015ef:	e8 43 41 00 00       	call   f0105737 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01015f4:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01015f9:	83 c4 10             	add    $0x10,%esp
f01015fc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101601:	77 15                	ja     f0101618 <mem_init+0xae>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101603:	50                   	push   %eax
f0101604:	68 48 64 10 f0       	push   $0xf0106448
f0101609:	68 9b 00 00 00       	push   $0x9b
f010160e:	68 df 69 10 f0       	push   $0xf01069df
f0101613:	e8 28 ea ff ff       	call   f0100040 <_panic>
f0101618:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010161e:	83 ca 05             	or     $0x5,%edx
f0101621:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:

	n = npages * sizeof(struct PageInfo);
f0101627:	a1 88 1e 21 f0       	mov    0xf0211e88,%eax
f010162c:	8d 1c c5 00 00 00 00 	lea    0x0(,%eax,8),%ebx
	pages = (struct PageInfo *) boot_alloc(n);
f0101633:	89 d8                	mov    %ebx,%eax
f0101635:	e8 de f4 ff ff       	call   f0100b18 <boot_alloc>
f010163a:	a3 90 1e 21 f0       	mov    %eax,0xf0211e90
	memset(pages, 0, n);
f010163f:	83 ec 04             	sub    $0x4,%esp
f0101642:	53                   	push   %ebx
f0101643:	6a 00                	push   $0x0
f0101645:	50                   	push   %eax
f0101646:	e8 ec 40 00 00       	call   f0105737 <memset>
	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.

	n = NENV * sizeof(struct Env);
	envs = (struct Env *) boot_alloc(n);
f010164b:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101650:	e8 c3 f4 ff ff       	call   f0100b18 <boot_alloc>
f0101655:	a3 48 12 21 f0       	mov    %eax,0xf0211248
	memset(envs, 0, n);
f010165a:	83 c4 0c             	add    $0xc,%esp
f010165d:	68 00 f0 01 00       	push   $0x1f000
f0101662:	6a 00                	push   $0x0
f0101664:	50                   	push   %eax
f0101665:	e8 cd 40 00 00       	call   f0105737 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010166a:	e8 62 f8 ff ff       	call   f0100ed1 <page_init>

	check_page_free_list(1);
f010166f:	b8 01 00 00 00       	mov    $0x1,%eax
f0101674:	e8 56 f5 ff ff       	call   f0100bcf <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101679:	83 c4 10             	add    $0x10,%esp
f010167c:	83 3d 90 1e 21 f0 00 	cmpl   $0x0,0xf0211e90
f0101683:	75 17                	jne    f010169c <mem_init+0x132>
		panic("'pages' is a null pointer!");
f0101685:	83 ec 04             	sub    $0x4,%esp
f0101688:	68 0c 6b 10 f0       	push   $0xf0106b0c
f010168d:	68 b2 03 00 00       	push   $0x3b2
f0101692:	68 df 69 10 f0       	push   $0xf01069df
f0101697:	e8 a4 e9 ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010169c:	a1 40 12 21 f0       	mov    0xf0211240,%eax
f01016a1:	bb 00 00 00 00       	mov    $0x0,%ebx
f01016a6:	eb 05                	jmp    f01016ad <mem_init+0x143>
		++nfree;
f01016a8:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01016ab:	8b 00                	mov    (%eax),%eax
f01016ad:	85 c0                	test   %eax,%eax
f01016af:	75 f7                	jne    f01016a8 <mem_init+0x13e>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01016b1:	83 ec 0c             	sub    $0xc,%esp
f01016b4:	6a 00                	push   $0x0
f01016b6:	e8 cc f9 ff ff       	call   f0101087 <page_alloc>
f01016bb:	89 c7                	mov    %eax,%edi
f01016bd:	83 c4 10             	add    $0x10,%esp
f01016c0:	85 c0                	test   %eax,%eax
f01016c2:	75 19                	jne    f01016dd <mem_init+0x173>
f01016c4:	68 27 6b 10 f0       	push   $0xf0106b27
f01016c9:	68 05 6a 10 f0       	push   $0xf0106a05
f01016ce:	68 ba 03 00 00       	push   $0x3ba
f01016d3:	68 df 69 10 f0       	push   $0xf01069df
f01016d8:	e8 63 e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01016dd:	83 ec 0c             	sub    $0xc,%esp
f01016e0:	6a 00                	push   $0x0
f01016e2:	e8 a0 f9 ff ff       	call   f0101087 <page_alloc>
f01016e7:	89 c6                	mov    %eax,%esi
f01016e9:	83 c4 10             	add    $0x10,%esp
f01016ec:	85 c0                	test   %eax,%eax
f01016ee:	75 19                	jne    f0101709 <mem_init+0x19f>
f01016f0:	68 3d 6b 10 f0       	push   $0xf0106b3d
f01016f5:	68 05 6a 10 f0       	push   $0xf0106a05
f01016fa:	68 bb 03 00 00       	push   $0x3bb
f01016ff:	68 df 69 10 f0       	push   $0xf01069df
f0101704:	e8 37 e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101709:	83 ec 0c             	sub    $0xc,%esp
f010170c:	6a 00                	push   $0x0
f010170e:	e8 74 f9 ff ff       	call   f0101087 <page_alloc>
f0101713:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101716:	83 c4 10             	add    $0x10,%esp
f0101719:	85 c0                	test   %eax,%eax
f010171b:	75 19                	jne    f0101736 <mem_init+0x1cc>
f010171d:	68 53 6b 10 f0       	push   $0xf0106b53
f0101722:	68 05 6a 10 f0       	push   $0xf0106a05
f0101727:	68 bc 03 00 00       	push   $0x3bc
f010172c:	68 df 69 10 f0       	push   $0xf01069df
f0101731:	e8 0a e9 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101736:	39 f7                	cmp    %esi,%edi
f0101738:	75 19                	jne    f0101753 <mem_init+0x1e9>
f010173a:	68 69 6b 10 f0       	push   $0xf0106b69
f010173f:	68 05 6a 10 f0       	push   $0xf0106a05
f0101744:	68 bf 03 00 00       	push   $0x3bf
f0101749:	68 df 69 10 f0       	push   $0xf01069df
f010174e:	e8 ed e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101753:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101756:	39 c6                	cmp    %eax,%esi
f0101758:	74 04                	je     f010175e <mem_init+0x1f4>
f010175a:	39 c7                	cmp    %eax,%edi
f010175c:	75 19                	jne    f0101777 <mem_init+0x20d>
f010175e:	68 d4 6f 10 f0       	push   $0xf0106fd4
f0101763:	68 05 6a 10 f0       	push   $0xf0106a05
f0101768:	68 c0 03 00 00       	push   $0x3c0
f010176d:	68 df 69 10 f0       	push   $0xf01069df
f0101772:	e8 c9 e8 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101777:	8b 0d 90 1e 21 f0    	mov    0xf0211e90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f010177d:	8b 15 88 1e 21 f0    	mov    0xf0211e88,%edx
f0101783:	c1 e2 0c             	shl    $0xc,%edx
f0101786:	89 f8                	mov    %edi,%eax
f0101788:	29 c8                	sub    %ecx,%eax
f010178a:	c1 f8 03             	sar    $0x3,%eax
f010178d:	c1 e0 0c             	shl    $0xc,%eax
f0101790:	39 d0                	cmp    %edx,%eax
f0101792:	72 19                	jb     f01017ad <mem_init+0x243>
f0101794:	68 7b 6b 10 f0       	push   $0xf0106b7b
f0101799:	68 05 6a 10 f0       	push   $0xf0106a05
f010179e:	68 c1 03 00 00       	push   $0x3c1
f01017a3:	68 df 69 10 f0       	push   $0xf01069df
f01017a8:	e8 93 e8 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01017ad:	89 f0                	mov    %esi,%eax
f01017af:	29 c8                	sub    %ecx,%eax
f01017b1:	c1 f8 03             	sar    $0x3,%eax
f01017b4:	c1 e0 0c             	shl    $0xc,%eax
f01017b7:	39 c2                	cmp    %eax,%edx
f01017b9:	77 19                	ja     f01017d4 <mem_init+0x26a>
f01017bb:	68 98 6b 10 f0       	push   $0xf0106b98
f01017c0:	68 05 6a 10 f0       	push   $0xf0106a05
f01017c5:	68 c2 03 00 00       	push   $0x3c2
f01017ca:	68 df 69 10 f0       	push   $0xf01069df
f01017cf:	e8 6c e8 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01017d4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01017d7:	29 c8                	sub    %ecx,%eax
f01017d9:	c1 f8 03             	sar    $0x3,%eax
f01017dc:	c1 e0 0c             	shl    $0xc,%eax
f01017df:	39 c2                	cmp    %eax,%edx
f01017e1:	77 19                	ja     f01017fc <mem_init+0x292>
f01017e3:	68 b5 6b 10 f0       	push   $0xf0106bb5
f01017e8:	68 05 6a 10 f0       	push   $0xf0106a05
f01017ed:	68 c3 03 00 00       	push   $0x3c3
f01017f2:	68 df 69 10 f0       	push   $0xf01069df
f01017f7:	e8 44 e8 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01017fc:	a1 40 12 21 f0       	mov    0xf0211240,%eax
f0101801:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101804:	c7 05 40 12 21 f0 00 	movl   $0x0,0xf0211240
f010180b:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010180e:	83 ec 0c             	sub    $0xc,%esp
f0101811:	6a 00                	push   $0x0
f0101813:	e8 6f f8 ff ff       	call   f0101087 <page_alloc>
f0101818:	83 c4 10             	add    $0x10,%esp
f010181b:	85 c0                	test   %eax,%eax
f010181d:	74 19                	je     f0101838 <mem_init+0x2ce>
f010181f:	68 d2 6b 10 f0       	push   $0xf0106bd2
f0101824:	68 05 6a 10 f0       	push   $0xf0106a05
f0101829:	68 ca 03 00 00       	push   $0x3ca
f010182e:	68 df 69 10 f0       	push   $0xf01069df
f0101833:	e8 08 e8 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101838:	83 ec 0c             	sub    $0xc,%esp
f010183b:	57                   	push   %edi
f010183c:	e8 b7 f8 ff ff       	call   f01010f8 <page_free>
	page_free(pp1);
f0101841:	89 34 24             	mov    %esi,(%esp)
f0101844:	e8 af f8 ff ff       	call   f01010f8 <page_free>
	page_free(pp2);
f0101849:	83 c4 04             	add    $0x4,%esp
f010184c:	ff 75 d4             	pushl  -0x2c(%ebp)
f010184f:	e8 a4 f8 ff ff       	call   f01010f8 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101854:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010185b:	e8 27 f8 ff ff       	call   f0101087 <page_alloc>
f0101860:	89 c6                	mov    %eax,%esi
f0101862:	83 c4 10             	add    $0x10,%esp
f0101865:	85 c0                	test   %eax,%eax
f0101867:	75 19                	jne    f0101882 <mem_init+0x318>
f0101869:	68 27 6b 10 f0       	push   $0xf0106b27
f010186e:	68 05 6a 10 f0       	push   $0xf0106a05
f0101873:	68 d1 03 00 00       	push   $0x3d1
f0101878:	68 df 69 10 f0       	push   $0xf01069df
f010187d:	e8 be e7 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101882:	83 ec 0c             	sub    $0xc,%esp
f0101885:	6a 00                	push   $0x0
f0101887:	e8 fb f7 ff ff       	call   f0101087 <page_alloc>
f010188c:	89 c7                	mov    %eax,%edi
f010188e:	83 c4 10             	add    $0x10,%esp
f0101891:	85 c0                	test   %eax,%eax
f0101893:	75 19                	jne    f01018ae <mem_init+0x344>
f0101895:	68 3d 6b 10 f0       	push   $0xf0106b3d
f010189a:	68 05 6a 10 f0       	push   $0xf0106a05
f010189f:	68 d2 03 00 00       	push   $0x3d2
f01018a4:	68 df 69 10 f0       	push   $0xf01069df
f01018a9:	e8 92 e7 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01018ae:	83 ec 0c             	sub    $0xc,%esp
f01018b1:	6a 00                	push   $0x0
f01018b3:	e8 cf f7 ff ff       	call   f0101087 <page_alloc>
f01018b8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01018bb:	83 c4 10             	add    $0x10,%esp
f01018be:	85 c0                	test   %eax,%eax
f01018c0:	75 19                	jne    f01018db <mem_init+0x371>
f01018c2:	68 53 6b 10 f0       	push   $0xf0106b53
f01018c7:	68 05 6a 10 f0       	push   $0xf0106a05
f01018cc:	68 d3 03 00 00       	push   $0x3d3
f01018d1:	68 df 69 10 f0       	push   $0xf01069df
f01018d6:	e8 65 e7 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01018db:	39 fe                	cmp    %edi,%esi
f01018dd:	75 19                	jne    f01018f8 <mem_init+0x38e>
f01018df:	68 69 6b 10 f0       	push   $0xf0106b69
f01018e4:	68 05 6a 10 f0       	push   $0xf0106a05
f01018e9:	68 d5 03 00 00       	push   $0x3d5
f01018ee:	68 df 69 10 f0       	push   $0xf01069df
f01018f3:	e8 48 e7 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01018f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01018fb:	39 c7                	cmp    %eax,%edi
f01018fd:	74 04                	je     f0101903 <mem_init+0x399>
f01018ff:	39 c6                	cmp    %eax,%esi
f0101901:	75 19                	jne    f010191c <mem_init+0x3b2>
f0101903:	68 d4 6f 10 f0       	push   $0xf0106fd4
f0101908:	68 05 6a 10 f0       	push   $0xf0106a05
f010190d:	68 d6 03 00 00       	push   $0x3d6
f0101912:	68 df 69 10 f0       	push   $0xf01069df
f0101917:	e8 24 e7 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f010191c:	83 ec 0c             	sub    $0xc,%esp
f010191f:	6a 00                	push   $0x0
f0101921:	e8 61 f7 ff ff       	call   f0101087 <page_alloc>
f0101926:	83 c4 10             	add    $0x10,%esp
f0101929:	85 c0                	test   %eax,%eax
f010192b:	74 19                	je     f0101946 <mem_init+0x3dc>
f010192d:	68 d2 6b 10 f0       	push   $0xf0106bd2
f0101932:	68 05 6a 10 f0       	push   $0xf0106a05
f0101937:	68 d7 03 00 00       	push   $0x3d7
f010193c:	68 df 69 10 f0       	push   $0xf01069df
f0101941:	e8 fa e6 ff ff       	call   f0100040 <_panic>
f0101946:	89 f0                	mov    %esi,%eax
f0101948:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f010194e:	c1 f8 03             	sar    $0x3,%eax
f0101951:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101954:	89 c2                	mov    %eax,%edx
f0101956:	c1 ea 0c             	shr    $0xc,%edx
f0101959:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f010195f:	72 12                	jb     f0101973 <mem_init+0x409>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101961:	50                   	push   %eax
f0101962:	68 24 64 10 f0       	push   $0xf0106424
f0101967:	6a 58                	push   $0x58
f0101969:	68 eb 69 10 f0       	push   $0xf01069eb
f010196e:	e8 cd e6 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101973:	83 ec 04             	sub    $0x4,%esp
f0101976:	68 00 10 00 00       	push   $0x1000
f010197b:	6a 01                	push   $0x1
f010197d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101982:	50                   	push   %eax
f0101983:	e8 af 3d 00 00       	call   f0105737 <memset>
	page_free(pp0);
f0101988:	89 34 24             	mov    %esi,(%esp)
f010198b:	e8 68 f7 ff ff       	call   f01010f8 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101990:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101997:	e8 eb f6 ff ff       	call   f0101087 <page_alloc>
f010199c:	83 c4 10             	add    $0x10,%esp
f010199f:	85 c0                	test   %eax,%eax
f01019a1:	75 19                	jne    f01019bc <mem_init+0x452>
f01019a3:	68 e1 6b 10 f0       	push   $0xf0106be1
f01019a8:	68 05 6a 10 f0       	push   $0xf0106a05
f01019ad:	68 dc 03 00 00       	push   $0x3dc
f01019b2:	68 df 69 10 f0       	push   $0xf01069df
f01019b7:	e8 84 e6 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f01019bc:	39 c6                	cmp    %eax,%esi
f01019be:	74 19                	je     f01019d9 <mem_init+0x46f>
f01019c0:	68 ff 6b 10 f0       	push   $0xf0106bff
f01019c5:	68 05 6a 10 f0       	push   $0xf0106a05
f01019ca:	68 dd 03 00 00       	push   $0x3dd
f01019cf:	68 df 69 10 f0       	push   $0xf01069df
f01019d4:	e8 67 e6 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01019d9:	89 f0                	mov    %esi,%eax
f01019db:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f01019e1:	c1 f8 03             	sar    $0x3,%eax
f01019e4:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01019e7:	89 c2                	mov    %eax,%edx
f01019e9:	c1 ea 0c             	shr    $0xc,%edx
f01019ec:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f01019f2:	72 12                	jb     f0101a06 <mem_init+0x49c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01019f4:	50                   	push   %eax
f01019f5:	68 24 64 10 f0       	push   $0xf0106424
f01019fa:	6a 58                	push   $0x58
f01019fc:	68 eb 69 10 f0       	push   $0xf01069eb
f0101a01:	e8 3a e6 ff ff       	call   f0100040 <_panic>
f0101a06:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101a0c:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++) {
		// cprintf("[?] %d\n", i);
		assert(c[i] == 0);
f0101a12:	80 38 00             	cmpb   $0x0,(%eax)
f0101a15:	74 19                	je     f0101a30 <mem_init+0x4c6>
f0101a17:	68 0f 6c 10 f0       	push   $0xf0106c0f
f0101a1c:	68 05 6a 10 f0       	push   $0xf0106a05
f0101a21:	68 e1 03 00 00       	push   $0x3e1
f0101a26:	68 df 69 10 f0       	push   $0xf01069df
f0101a2b:	e8 10 e6 ff ff       	call   f0100040 <_panic>
f0101a30:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++) {
f0101a33:	39 d0                	cmp    %edx,%eax
f0101a35:	75 db                	jne    f0101a12 <mem_init+0x4a8>
		// cprintf("[?] %d\n", i);
		assert(c[i] == 0);
	}

	// give free list back
	page_free_list = fl;
f0101a37:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101a3a:	a3 40 12 21 f0       	mov    %eax,0xf0211240

	// free the pages we took
	page_free(pp0);
f0101a3f:	83 ec 0c             	sub    $0xc,%esp
f0101a42:	56                   	push   %esi
f0101a43:	e8 b0 f6 ff ff       	call   f01010f8 <page_free>
	page_free(pp1);
f0101a48:	89 3c 24             	mov    %edi,(%esp)
f0101a4b:	e8 a8 f6 ff ff       	call   f01010f8 <page_free>
	page_free(pp2);
f0101a50:	83 c4 04             	add    $0x4,%esp
f0101a53:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101a56:	e8 9d f6 ff ff       	call   f01010f8 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101a5b:	a1 40 12 21 f0       	mov    0xf0211240,%eax
f0101a60:	83 c4 10             	add    $0x10,%esp
f0101a63:	eb 05                	jmp    f0101a6a <mem_init+0x500>
		--nfree;
f0101a65:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101a68:	8b 00                	mov    (%eax),%eax
f0101a6a:	85 c0                	test   %eax,%eax
f0101a6c:	75 f7                	jne    f0101a65 <mem_init+0x4fb>
		--nfree;
	assert(nfree == 0);
f0101a6e:	85 db                	test   %ebx,%ebx
f0101a70:	74 19                	je     f0101a8b <mem_init+0x521>
f0101a72:	68 19 6c 10 f0       	push   $0xf0106c19
f0101a77:	68 05 6a 10 f0       	push   $0xf0106a05
f0101a7c:	68 ef 03 00 00       	push   $0x3ef
f0101a81:	68 df 69 10 f0       	push   $0xf01069df
f0101a86:	e8 b5 e5 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101a8b:	83 ec 0c             	sub    $0xc,%esp
f0101a8e:	68 f4 6f 10 f0       	push   $0xf0106ff4
f0101a93:	e8 ca 1e 00 00       	call   f0103962 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101a98:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a9f:	e8 e3 f5 ff ff       	call   f0101087 <page_alloc>
f0101aa4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101aa7:	83 c4 10             	add    $0x10,%esp
f0101aaa:	85 c0                	test   %eax,%eax
f0101aac:	75 19                	jne    f0101ac7 <mem_init+0x55d>
f0101aae:	68 27 6b 10 f0       	push   $0xf0106b27
f0101ab3:	68 05 6a 10 f0       	push   $0xf0106a05
f0101ab8:	68 59 04 00 00       	push   $0x459
f0101abd:	68 df 69 10 f0       	push   $0xf01069df
f0101ac2:	e8 79 e5 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101ac7:	83 ec 0c             	sub    $0xc,%esp
f0101aca:	6a 00                	push   $0x0
f0101acc:	e8 b6 f5 ff ff       	call   f0101087 <page_alloc>
f0101ad1:	89 c3                	mov    %eax,%ebx
f0101ad3:	83 c4 10             	add    $0x10,%esp
f0101ad6:	85 c0                	test   %eax,%eax
f0101ad8:	75 19                	jne    f0101af3 <mem_init+0x589>
f0101ada:	68 3d 6b 10 f0       	push   $0xf0106b3d
f0101adf:	68 05 6a 10 f0       	push   $0xf0106a05
f0101ae4:	68 5a 04 00 00       	push   $0x45a
f0101ae9:	68 df 69 10 f0       	push   $0xf01069df
f0101aee:	e8 4d e5 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101af3:	83 ec 0c             	sub    $0xc,%esp
f0101af6:	6a 00                	push   $0x0
f0101af8:	e8 8a f5 ff ff       	call   f0101087 <page_alloc>
f0101afd:	89 c6                	mov    %eax,%esi
f0101aff:	83 c4 10             	add    $0x10,%esp
f0101b02:	85 c0                	test   %eax,%eax
f0101b04:	75 19                	jne    f0101b1f <mem_init+0x5b5>
f0101b06:	68 53 6b 10 f0       	push   $0xf0106b53
f0101b0b:	68 05 6a 10 f0       	push   $0xf0106a05
f0101b10:	68 5b 04 00 00       	push   $0x45b
f0101b15:	68 df 69 10 f0       	push   $0xf01069df
f0101b1a:	e8 21 e5 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101b1f:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101b22:	75 19                	jne    f0101b3d <mem_init+0x5d3>
f0101b24:	68 69 6b 10 f0       	push   $0xf0106b69
f0101b29:	68 05 6a 10 f0       	push   $0xf0106a05
f0101b2e:	68 5e 04 00 00       	push   $0x45e
f0101b33:	68 df 69 10 f0       	push   $0xf01069df
f0101b38:	e8 03 e5 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101b3d:	39 c3                	cmp    %eax,%ebx
f0101b3f:	74 05                	je     f0101b46 <mem_init+0x5dc>
f0101b41:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101b44:	75 19                	jne    f0101b5f <mem_init+0x5f5>
f0101b46:	68 d4 6f 10 f0       	push   $0xf0106fd4
f0101b4b:	68 05 6a 10 f0       	push   $0xf0106a05
f0101b50:	68 5f 04 00 00       	push   $0x45f
f0101b55:	68 df 69 10 f0       	push   $0xf01069df
f0101b5a:	e8 e1 e4 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101b5f:	a1 40 12 21 f0       	mov    0xf0211240,%eax
f0101b64:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101b67:	c7 05 40 12 21 f0 00 	movl   $0x0,0xf0211240
f0101b6e:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101b71:	83 ec 0c             	sub    $0xc,%esp
f0101b74:	6a 00                	push   $0x0
f0101b76:	e8 0c f5 ff ff       	call   f0101087 <page_alloc>
f0101b7b:	83 c4 10             	add    $0x10,%esp
f0101b7e:	85 c0                	test   %eax,%eax
f0101b80:	74 19                	je     f0101b9b <mem_init+0x631>
f0101b82:	68 d2 6b 10 f0       	push   $0xf0106bd2
f0101b87:	68 05 6a 10 f0       	push   $0xf0106a05
f0101b8c:	68 66 04 00 00       	push   $0x466
f0101b91:	68 df 69 10 f0       	push   $0xf01069df
f0101b96:	e8 a5 e4 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101b9b:	83 ec 04             	sub    $0x4,%esp
f0101b9e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101ba1:	50                   	push   %eax
f0101ba2:	6a 00                	push   $0x0
f0101ba4:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101baa:	e8 e3 f7 ff ff       	call   f0101392 <page_lookup>
f0101baf:	83 c4 10             	add    $0x10,%esp
f0101bb2:	85 c0                	test   %eax,%eax
f0101bb4:	74 19                	je     f0101bcf <mem_init+0x665>
f0101bb6:	68 14 70 10 f0       	push   $0xf0107014
f0101bbb:	68 05 6a 10 f0       	push   $0xf0106a05
f0101bc0:	68 69 04 00 00       	push   $0x469
f0101bc5:	68 df 69 10 f0       	push   $0xf01069df
f0101bca:	e8 71 e4 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101bcf:	6a 02                	push   $0x2
f0101bd1:	6a 00                	push   $0x0
f0101bd3:	53                   	push   %ebx
f0101bd4:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101bda:	e8 9b f8 ff ff       	call   f010147a <page_insert>
f0101bdf:	83 c4 10             	add    $0x10,%esp
f0101be2:	85 c0                	test   %eax,%eax
f0101be4:	78 19                	js     f0101bff <mem_init+0x695>
f0101be6:	68 4c 70 10 f0       	push   $0xf010704c
f0101beb:	68 05 6a 10 f0       	push   $0xf0106a05
f0101bf0:	68 6c 04 00 00       	push   $0x46c
f0101bf5:	68 df 69 10 f0       	push   $0xf01069df
f0101bfa:	e8 41 e4 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101bff:	83 ec 0c             	sub    $0xc,%esp
f0101c02:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101c05:	e8 ee f4 ff ff       	call   f01010f8 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101c0a:	6a 02                	push   $0x2
f0101c0c:	6a 00                	push   $0x0
f0101c0e:	53                   	push   %ebx
f0101c0f:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101c15:	e8 60 f8 ff ff       	call   f010147a <page_insert>
f0101c1a:	83 c4 20             	add    $0x20,%esp
f0101c1d:	85 c0                	test   %eax,%eax
f0101c1f:	74 19                	je     f0101c3a <mem_init+0x6d0>
f0101c21:	68 7c 70 10 f0       	push   $0xf010707c
f0101c26:	68 05 6a 10 f0       	push   $0xf0106a05
f0101c2b:	68 70 04 00 00       	push   $0x470
f0101c30:	68 df 69 10 f0       	push   $0xf01069df
f0101c35:	e8 06 e4 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101c3a:	8b 3d 8c 1e 21 f0    	mov    0xf0211e8c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101c40:	a1 90 1e 21 f0       	mov    0xf0211e90,%eax
f0101c45:	89 c1                	mov    %eax,%ecx
f0101c47:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101c4a:	8b 17                	mov    (%edi),%edx
f0101c4c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101c52:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c55:	29 c8                	sub    %ecx,%eax
f0101c57:	c1 f8 03             	sar    $0x3,%eax
f0101c5a:	c1 e0 0c             	shl    $0xc,%eax
f0101c5d:	39 c2                	cmp    %eax,%edx
f0101c5f:	74 19                	je     f0101c7a <mem_init+0x710>
f0101c61:	68 ac 70 10 f0       	push   $0xf01070ac
f0101c66:	68 05 6a 10 f0       	push   $0xf0106a05
f0101c6b:	68 71 04 00 00       	push   $0x471
f0101c70:	68 df 69 10 f0       	push   $0xf01069df
f0101c75:	e8 c6 e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101c7a:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c7f:	89 f8                	mov    %edi,%eax
f0101c81:	e8 e5 ee ff ff       	call   f0100b6b <check_va2pa>
f0101c86:	89 da                	mov    %ebx,%edx
f0101c88:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101c8b:	c1 fa 03             	sar    $0x3,%edx
f0101c8e:	c1 e2 0c             	shl    $0xc,%edx
f0101c91:	39 d0                	cmp    %edx,%eax
f0101c93:	74 19                	je     f0101cae <mem_init+0x744>
f0101c95:	68 d4 70 10 f0       	push   $0xf01070d4
f0101c9a:	68 05 6a 10 f0       	push   $0xf0106a05
f0101c9f:	68 72 04 00 00       	push   $0x472
f0101ca4:	68 df 69 10 f0       	push   $0xf01069df
f0101ca9:	e8 92 e3 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101cae:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101cb3:	74 19                	je     f0101cce <mem_init+0x764>
f0101cb5:	68 24 6c 10 f0       	push   $0xf0106c24
f0101cba:	68 05 6a 10 f0       	push   $0xf0106a05
f0101cbf:	68 73 04 00 00       	push   $0x473
f0101cc4:	68 df 69 10 f0       	push   $0xf01069df
f0101cc9:	e8 72 e3 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101cce:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101cd1:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101cd6:	74 19                	je     f0101cf1 <mem_init+0x787>
f0101cd8:	68 35 6c 10 f0       	push   $0xf0106c35
f0101cdd:	68 05 6a 10 f0       	push   $0xf0106a05
f0101ce2:	68 74 04 00 00       	push   $0x474
f0101ce7:	68 df 69 10 f0       	push   $0xf01069df
f0101cec:	e8 4f e3 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101cf1:	6a 02                	push   $0x2
f0101cf3:	68 00 10 00 00       	push   $0x1000
f0101cf8:	56                   	push   %esi
f0101cf9:	57                   	push   %edi
f0101cfa:	e8 7b f7 ff ff       	call   f010147a <page_insert>
f0101cff:	83 c4 10             	add    $0x10,%esp
f0101d02:	85 c0                	test   %eax,%eax
f0101d04:	74 19                	je     f0101d1f <mem_init+0x7b5>
f0101d06:	68 04 71 10 f0       	push   $0xf0107104
f0101d0b:	68 05 6a 10 f0       	push   $0xf0106a05
f0101d10:	68 77 04 00 00       	push   $0x477
f0101d15:	68 df 69 10 f0       	push   $0xf01069df
f0101d1a:	e8 21 e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d1f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d24:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0101d29:	e8 3d ee ff ff       	call   f0100b6b <check_va2pa>
f0101d2e:	89 f2                	mov    %esi,%edx
f0101d30:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f0101d36:	c1 fa 03             	sar    $0x3,%edx
f0101d39:	c1 e2 0c             	shl    $0xc,%edx
f0101d3c:	39 d0                	cmp    %edx,%eax
f0101d3e:	74 19                	je     f0101d59 <mem_init+0x7ef>
f0101d40:	68 40 71 10 f0       	push   $0xf0107140
f0101d45:	68 05 6a 10 f0       	push   $0xf0106a05
f0101d4a:	68 78 04 00 00       	push   $0x478
f0101d4f:	68 df 69 10 f0       	push   $0xf01069df
f0101d54:	e8 e7 e2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101d59:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d5e:	74 19                	je     f0101d79 <mem_init+0x80f>
f0101d60:	68 46 6c 10 f0       	push   $0xf0106c46
f0101d65:	68 05 6a 10 f0       	push   $0xf0106a05
f0101d6a:	68 79 04 00 00       	push   $0x479
f0101d6f:	68 df 69 10 f0       	push   $0xf01069df
f0101d74:	e8 c7 e2 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101d79:	83 ec 0c             	sub    $0xc,%esp
f0101d7c:	6a 00                	push   $0x0
f0101d7e:	e8 04 f3 ff ff       	call   f0101087 <page_alloc>
f0101d83:	83 c4 10             	add    $0x10,%esp
f0101d86:	85 c0                	test   %eax,%eax
f0101d88:	74 19                	je     f0101da3 <mem_init+0x839>
f0101d8a:	68 d2 6b 10 f0       	push   $0xf0106bd2
f0101d8f:	68 05 6a 10 f0       	push   $0xf0106a05
f0101d94:	68 7c 04 00 00       	push   $0x47c
f0101d99:	68 df 69 10 f0       	push   $0xf01069df
f0101d9e:	e8 9d e2 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101da3:	6a 02                	push   $0x2
f0101da5:	68 00 10 00 00       	push   $0x1000
f0101daa:	56                   	push   %esi
f0101dab:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101db1:	e8 c4 f6 ff ff       	call   f010147a <page_insert>
f0101db6:	83 c4 10             	add    $0x10,%esp
f0101db9:	85 c0                	test   %eax,%eax
f0101dbb:	74 19                	je     f0101dd6 <mem_init+0x86c>
f0101dbd:	68 04 71 10 f0       	push   $0xf0107104
f0101dc2:	68 05 6a 10 f0       	push   $0xf0106a05
f0101dc7:	68 7f 04 00 00       	push   $0x47f
f0101dcc:	68 df 69 10 f0       	push   $0xf01069df
f0101dd1:	e8 6a e2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101dd6:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ddb:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0101de0:	e8 86 ed ff ff       	call   f0100b6b <check_va2pa>
f0101de5:	89 f2                	mov    %esi,%edx
f0101de7:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f0101ded:	c1 fa 03             	sar    $0x3,%edx
f0101df0:	c1 e2 0c             	shl    $0xc,%edx
f0101df3:	39 d0                	cmp    %edx,%eax
f0101df5:	74 19                	je     f0101e10 <mem_init+0x8a6>
f0101df7:	68 40 71 10 f0       	push   $0xf0107140
f0101dfc:	68 05 6a 10 f0       	push   $0xf0106a05
f0101e01:	68 80 04 00 00       	push   $0x480
f0101e06:	68 df 69 10 f0       	push   $0xf01069df
f0101e0b:	e8 30 e2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101e10:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101e15:	74 19                	je     f0101e30 <mem_init+0x8c6>
f0101e17:	68 46 6c 10 f0       	push   $0xf0106c46
f0101e1c:	68 05 6a 10 f0       	push   $0xf0106a05
f0101e21:	68 81 04 00 00       	push   $0x481
f0101e26:	68 df 69 10 f0       	push   $0xf01069df
f0101e2b:	e8 10 e2 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101e30:	83 ec 0c             	sub    $0xc,%esp
f0101e33:	6a 00                	push   $0x0
f0101e35:	e8 4d f2 ff ff       	call   f0101087 <page_alloc>
f0101e3a:	83 c4 10             	add    $0x10,%esp
f0101e3d:	85 c0                	test   %eax,%eax
f0101e3f:	74 19                	je     f0101e5a <mem_init+0x8f0>
f0101e41:	68 d2 6b 10 f0       	push   $0xf0106bd2
f0101e46:	68 05 6a 10 f0       	push   $0xf0106a05
f0101e4b:	68 85 04 00 00       	push   $0x485
f0101e50:	68 df 69 10 f0       	push   $0xf01069df
f0101e55:	e8 e6 e1 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101e5a:	8b 15 8c 1e 21 f0    	mov    0xf0211e8c,%edx
f0101e60:	8b 02                	mov    (%edx),%eax
f0101e62:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101e67:	89 c1                	mov    %eax,%ecx
f0101e69:	c1 e9 0c             	shr    $0xc,%ecx
f0101e6c:	3b 0d 88 1e 21 f0    	cmp    0xf0211e88,%ecx
f0101e72:	72 15                	jb     f0101e89 <mem_init+0x91f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101e74:	50                   	push   %eax
f0101e75:	68 24 64 10 f0       	push   $0xf0106424
f0101e7a:	68 88 04 00 00       	push   $0x488
f0101e7f:	68 df 69 10 f0       	push   $0xf01069df
f0101e84:	e8 b7 e1 ff ff       	call   f0100040 <_panic>
f0101e89:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101e8e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101e91:	83 ec 04             	sub    $0x4,%esp
f0101e94:	6a 00                	push   $0x0
f0101e96:	68 00 10 00 00       	push   $0x1000
f0101e9b:	52                   	push   %edx
f0101e9c:	e8 d4 f2 ff ff       	call   f0101175 <pgdir_walk>
f0101ea1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101ea4:	8d 51 04             	lea    0x4(%ecx),%edx
f0101ea7:	83 c4 10             	add    $0x10,%esp
f0101eaa:	39 d0                	cmp    %edx,%eax
f0101eac:	74 19                	je     f0101ec7 <mem_init+0x95d>
f0101eae:	68 70 71 10 f0       	push   $0xf0107170
f0101eb3:	68 05 6a 10 f0       	push   $0xf0106a05
f0101eb8:	68 89 04 00 00       	push   $0x489
f0101ebd:	68 df 69 10 f0       	push   $0xf01069df
f0101ec2:	e8 79 e1 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101ec7:	6a 06                	push   $0x6
f0101ec9:	68 00 10 00 00       	push   $0x1000
f0101ece:	56                   	push   %esi
f0101ecf:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101ed5:	e8 a0 f5 ff ff       	call   f010147a <page_insert>
f0101eda:	83 c4 10             	add    $0x10,%esp
f0101edd:	85 c0                	test   %eax,%eax
f0101edf:	74 19                	je     f0101efa <mem_init+0x990>
f0101ee1:	68 b0 71 10 f0       	push   $0xf01071b0
f0101ee6:	68 05 6a 10 f0       	push   $0xf0106a05
f0101eeb:	68 8c 04 00 00       	push   $0x48c
f0101ef0:	68 df 69 10 f0       	push   $0xf01069df
f0101ef5:	e8 46 e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101efa:	8b 3d 8c 1e 21 f0    	mov    0xf0211e8c,%edi
f0101f00:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f05:	89 f8                	mov    %edi,%eax
f0101f07:	e8 5f ec ff ff       	call   f0100b6b <check_va2pa>
f0101f0c:	89 f2                	mov    %esi,%edx
f0101f0e:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f0101f14:	c1 fa 03             	sar    $0x3,%edx
f0101f17:	c1 e2 0c             	shl    $0xc,%edx
f0101f1a:	39 d0                	cmp    %edx,%eax
f0101f1c:	74 19                	je     f0101f37 <mem_init+0x9cd>
f0101f1e:	68 40 71 10 f0       	push   $0xf0107140
f0101f23:	68 05 6a 10 f0       	push   $0xf0106a05
f0101f28:	68 8d 04 00 00       	push   $0x48d
f0101f2d:	68 df 69 10 f0       	push   $0xf01069df
f0101f32:	e8 09 e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101f37:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101f3c:	74 19                	je     f0101f57 <mem_init+0x9ed>
f0101f3e:	68 46 6c 10 f0       	push   $0xf0106c46
f0101f43:	68 05 6a 10 f0       	push   $0xf0106a05
f0101f48:	68 8e 04 00 00       	push   $0x48e
f0101f4d:	68 df 69 10 f0       	push   $0xf01069df
f0101f52:	e8 e9 e0 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101f57:	83 ec 04             	sub    $0x4,%esp
f0101f5a:	6a 00                	push   $0x0
f0101f5c:	68 00 10 00 00       	push   $0x1000
f0101f61:	57                   	push   %edi
f0101f62:	e8 0e f2 ff ff       	call   f0101175 <pgdir_walk>
f0101f67:	83 c4 10             	add    $0x10,%esp
f0101f6a:	f6 00 04             	testb  $0x4,(%eax)
f0101f6d:	75 19                	jne    f0101f88 <mem_init+0xa1e>
f0101f6f:	68 f0 71 10 f0       	push   $0xf01071f0
f0101f74:	68 05 6a 10 f0       	push   $0xf0106a05
f0101f79:	68 8f 04 00 00       	push   $0x48f
f0101f7e:	68 df 69 10 f0       	push   $0xf01069df
f0101f83:	e8 b8 e0 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101f88:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0101f8d:	f6 00 04             	testb  $0x4,(%eax)
f0101f90:	75 19                	jne    f0101fab <mem_init+0xa41>
f0101f92:	68 57 6c 10 f0       	push   $0xf0106c57
f0101f97:	68 05 6a 10 f0       	push   $0xf0106a05
f0101f9c:	68 90 04 00 00       	push   $0x490
f0101fa1:	68 df 69 10 f0       	push   $0xf01069df
f0101fa6:	e8 95 e0 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101fab:	6a 02                	push   $0x2
f0101fad:	68 00 10 00 00       	push   $0x1000
f0101fb2:	56                   	push   %esi
f0101fb3:	50                   	push   %eax
f0101fb4:	e8 c1 f4 ff ff       	call   f010147a <page_insert>
f0101fb9:	83 c4 10             	add    $0x10,%esp
f0101fbc:	85 c0                	test   %eax,%eax
f0101fbe:	74 19                	je     f0101fd9 <mem_init+0xa6f>
f0101fc0:	68 04 71 10 f0       	push   $0xf0107104
f0101fc5:	68 05 6a 10 f0       	push   $0xf0106a05
f0101fca:	68 93 04 00 00       	push   $0x493
f0101fcf:	68 df 69 10 f0       	push   $0xf01069df
f0101fd4:	e8 67 e0 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101fd9:	83 ec 04             	sub    $0x4,%esp
f0101fdc:	6a 00                	push   $0x0
f0101fde:	68 00 10 00 00       	push   $0x1000
f0101fe3:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101fe9:	e8 87 f1 ff ff       	call   f0101175 <pgdir_walk>
f0101fee:	83 c4 10             	add    $0x10,%esp
f0101ff1:	f6 00 02             	testb  $0x2,(%eax)
f0101ff4:	75 19                	jne    f010200f <mem_init+0xaa5>
f0101ff6:	68 24 72 10 f0       	push   $0xf0107224
f0101ffb:	68 05 6a 10 f0       	push   $0xf0106a05
f0102000:	68 94 04 00 00       	push   $0x494
f0102005:	68 df 69 10 f0       	push   $0xf01069df
f010200a:	e8 31 e0 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010200f:	83 ec 04             	sub    $0x4,%esp
f0102012:	6a 00                	push   $0x0
f0102014:	68 00 10 00 00       	push   $0x1000
f0102019:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f010201f:	e8 51 f1 ff ff       	call   f0101175 <pgdir_walk>
f0102024:	83 c4 10             	add    $0x10,%esp
f0102027:	f6 00 04             	testb  $0x4,(%eax)
f010202a:	74 19                	je     f0102045 <mem_init+0xadb>
f010202c:	68 58 72 10 f0       	push   $0xf0107258
f0102031:	68 05 6a 10 f0       	push   $0xf0106a05
f0102036:	68 95 04 00 00       	push   $0x495
f010203b:	68 df 69 10 f0       	push   $0xf01069df
f0102040:	e8 fb df ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102045:	6a 02                	push   $0x2
f0102047:	68 00 00 40 00       	push   $0x400000
f010204c:	ff 75 d4             	pushl  -0x2c(%ebp)
f010204f:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0102055:	e8 20 f4 ff ff       	call   f010147a <page_insert>
f010205a:	83 c4 10             	add    $0x10,%esp
f010205d:	85 c0                	test   %eax,%eax
f010205f:	78 19                	js     f010207a <mem_init+0xb10>
f0102061:	68 90 72 10 f0       	push   $0xf0107290
f0102066:	68 05 6a 10 f0       	push   $0xf0106a05
f010206b:	68 98 04 00 00       	push   $0x498
f0102070:	68 df 69 10 f0       	push   $0xf01069df
f0102075:	e8 c6 df ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f010207a:	6a 02                	push   $0x2
f010207c:	68 00 10 00 00       	push   $0x1000
f0102081:	53                   	push   %ebx
f0102082:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0102088:	e8 ed f3 ff ff       	call   f010147a <page_insert>
f010208d:	83 c4 10             	add    $0x10,%esp
f0102090:	85 c0                	test   %eax,%eax
f0102092:	74 19                	je     f01020ad <mem_init+0xb43>
f0102094:	68 c8 72 10 f0       	push   $0xf01072c8
f0102099:	68 05 6a 10 f0       	push   $0xf0106a05
f010209e:	68 9b 04 00 00       	push   $0x49b
f01020a3:	68 df 69 10 f0       	push   $0xf01069df
f01020a8:	e8 93 df ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01020ad:	83 ec 04             	sub    $0x4,%esp
f01020b0:	6a 00                	push   $0x0
f01020b2:	68 00 10 00 00       	push   $0x1000
f01020b7:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f01020bd:	e8 b3 f0 ff ff       	call   f0101175 <pgdir_walk>
f01020c2:	83 c4 10             	add    $0x10,%esp
f01020c5:	f6 00 04             	testb  $0x4,(%eax)
f01020c8:	74 19                	je     f01020e3 <mem_init+0xb79>
f01020ca:	68 58 72 10 f0       	push   $0xf0107258
f01020cf:	68 05 6a 10 f0       	push   $0xf0106a05
f01020d4:	68 9c 04 00 00       	push   $0x49c
f01020d9:	68 df 69 10 f0       	push   $0xf01069df
f01020de:	e8 5d df ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01020e3:	8b 3d 8c 1e 21 f0    	mov    0xf0211e8c,%edi
f01020e9:	ba 00 00 00 00       	mov    $0x0,%edx
f01020ee:	89 f8                	mov    %edi,%eax
f01020f0:	e8 76 ea ff ff       	call   f0100b6b <check_va2pa>
f01020f5:	89 c1                	mov    %eax,%ecx
f01020f7:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01020fa:	89 d8                	mov    %ebx,%eax
f01020fc:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0102102:	c1 f8 03             	sar    $0x3,%eax
f0102105:	c1 e0 0c             	shl    $0xc,%eax
f0102108:	39 c1                	cmp    %eax,%ecx
f010210a:	74 19                	je     f0102125 <mem_init+0xbbb>
f010210c:	68 04 73 10 f0       	push   $0xf0107304
f0102111:	68 05 6a 10 f0       	push   $0xf0106a05
f0102116:	68 9f 04 00 00       	push   $0x49f
f010211b:	68 df 69 10 f0       	push   $0xf01069df
f0102120:	e8 1b df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102125:	ba 00 10 00 00       	mov    $0x1000,%edx
f010212a:	89 f8                	mov    %edi,%eax
f010212c:	e8 3a ea ff ff       	call   f0100b6b <check_va2pa>
f0102131:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0102134:	74 19                	je     f010214f <mem_init+0xbe5>
f0102136:	68 30 73 10 f0       	push   $0xf0107330
f010213b:	68 05 6a 10 f0       	push   $0xf0106a05
f0102140:	68 a0 04 00 00       	push   $0x4a0
f0102145:	68 df 69 10 f0       	push   $0xf01069df
f010214a:	e8 f1 de ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f010214f:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0102154:	74 19                	je     f010216f <mem_init+0xc05>
f0102156:	68 6d 6c 10 f0       	push   $0xf0106c6d
f010215b:	68 05 6a 10 f0       	push   $0xf0106a05
f0102160:	68 a2 04 00 00       	push   $0x4a2
f0102165:	68 df 69 10 f0       	push   $0xf01069df
f010216a:	e8 d1 de ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010216f:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102174:	74 19                	je     f010218f <mem_init+0xc25>
f0102176:	68 7e 6c 10 f0       	push   $0xf0106c7e
f010217b:	68 05 6a 10 f0       	push   $0xf0106a05
f0102180:	68 a3 04 00 00       	push   $0x4a3
f0102185:	68 df 69 10 f0       	push   $0xf01069df
f010218a:	e8 b1 de ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f010218f:	83 ec 0c             	sub    $0xc,%esp
f0102192:	6a 00                	push   $0x0
f0102194:	e8 ee ee ff ff       	call   f0101087 <page_alloc>
f0102199:	83 c4 10             	add    $0x10,%esp
f010219c:	85 c0                	test   %eax,%eax
f010219e:	74 04                	je     f01021a4 <mem_init+0xc3a>
f01021a0:	39 c6                	cmp    %eax,%esi
f01021a2:	74 19                	je     f01021bd <mem_init+0xc53>
f01021a4:	68 60 73 10 f0       	push   $0xf0107360
f01021a9:	68 05 6a 10 f0       	push   $0xf0106a05
f01021ae:	68 a6 04 00 00       	push   $0x4a6
f01021b3:	68 df 69 10 f0       	push   $0xf01069df
f01021b8:	e8 83 de ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01021bd:	83 ec 08             	sub    $0x8,%esp
f01021c0:	6a 00                	push   $0x0
f01021c2:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f01021c8:	e8 60 f2 ff ff       	call   f010142d <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01021cd:	8b 3d 8c 1e 21 f0    	mov    0xf0211e8c,%edi
f01021d3:	ba 00 00 00 00       	mov    $0x0,%edx
f01021d8:	89 f8                	mov    %edi,%eax
f01021da:	e8 8c e9 ff ff       	call   f0100b6b <check_va2pa>
f01021df:	83 c4 10             	add    $0x10,%esp
f01021e2:	83 f8 ff             	cmp    $0xffffffff,%eax
f01021e5:	74 19                	je     f0102200 <mem_init+0xc96>
f01021e7:	68 84 73 10 f0       	push   $0xf0107384
f01021ec:	68 05 6a 10 f0       	push   $0xf0106a05
f01021f1:	68 aa 04 00 00       	push   $0x4aa
f01021f6:	68 df 69 10 f0       	push   $0xf01069df
f01021fb:	e8 40 de ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102200:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102205:	89 f8                	mov    %edi,%eax
f0102207:	e8 5f e9 ff ff       	call   f0100b6b <check_va2pa>
f010220c:	89 da                	mov    %ebx,%edx
f010220e:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f0102214:	c1 fa 03             	sar    $0x3,%edx
f0102217:	c1 e2 0c             	shl    $0xc,%edx
f010221a:	39 d0                	cmp    %edx,%eax
f010221c:	74 19                	je     f0102237 <mem_init+0xccd>
f010221e:	68 30 73 10 f0       	push   $0xf0107330
f0102223:	68 05 6a 10 f0       	push   $0xf0106a05
f0102228:	68 ab 04 00 00       	push   $0x4ab
f010222d:	68 df 69 10 f0       	push   $0xf01069df
f0102232:	e8 09 de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102237:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010223c:	74 19                	je     f0102257 <mem_init+0xced>
f010223e:	68 24 6c 10 f0       	push   $0xf0106c24
f0102243:	68 05 6a 10 f0       	push   $0xf0106a05
f0102248:	68 ac 04 00 00       	push   $0x4ac
f010224d:	68 df 69 10 f0       	push   $0xf01069df
f0102252:	e8 e9 dd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102257:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010225c:	74 19                	je     f0102277 <mem_init+0xd0d>
f010225e:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0102263:	68 05 6a 10 f0       	push   $0xf0106a05
f0102268:	68 ad 04 00 00       	push   $0x4ad
f010226d:	68 df 69 10 f0       	push   $0xf01069df
f0102272:	e8 c9 dd ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102277:	6a 00                	push   $0x0
f0102279:	68 00 10 00 00       	push   $0x1000
f010227e:	53                   	push   %ebx
f010227f:	57                   	push   %edi
f0102280:	e8 f5 f1 ff ff       	call   f010147a <page_insert>
f0102285:	83 c4 10             	add    $0x10,%esp
f0102288:	85 c0                	test   %eax,%eax
f010228a:	74 19                	je     f01022a5 <mem_init+0xd3b>
f010228c:	68 a8 73 10 f0       	push   $0xf01073a8
f0102291:	68 05 6a 10 f0       	push   $0xf0106a05
f0102296:	68 b0 04 00 00       	push   $0x4b0
f010229b:	68 df 69 10 f0       	push   $0xf01069df
f01022a0:	e8 9b dd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f01022a5:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01022aa:	75 19                	jne    f01022c5 <mem_init+0xd5b>
f01022ac:	68 8f 6c 10 f0       	push   $0xf0106c8f
f01022b1:	68 05 6a 10 f0       	push   $0xf0106a05
f01022b6:	68 b1 04 00 00       	push   $0x4b1
f01022bb:	68 df 69 10 f0       	push   $0xf01069df
f01022c0:	e8 7b dd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f01022c5:	83 3b 00             	cmpl   $0x0,(%ebx)
f01022c8:	74 19                	je     f01022e3 <mem_init+0xd79>
f01022ca:	68 9b 6c 10 f0       	push   $0xf0106c9b
f01022cf:	68 05 6a 10 f0       	push   $0xf0106a05
f01022d4:	68 b2 04 00 00       	push   $0x4b2
f01022d9:	68 df 69 10 f0       	push   $0xf01069df
f01022de:	e8 5d dd ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01022e3:	83 ec 08             	sub    $0x8,%esp
f01022e6:	68 00 10 00 00       	push   $0x1000
f01022eb:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f01022f1:	e8 37 f1 ff ff       	call   f010142d <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01022f6:	8b 3d 8c 1e 21 f0    	mov    0xf0211e8c,%edi
f01022fc:	ba 00 00 00 00       	mov    $0x0,%edx
f0102301:	89 f8                	mov    %edi,%eax
f0102303:	e8 63 e8 ff ff       	call   f0100b6b <check_va2pa>
f0102308:	83 c4 10             	add    $0x10,%esp
f010230b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010230e:	74 19                	je     f0102329 <mem_init+0xdbf>
f0102310:	68 84 73 10 f0       	push   $0xf0107384
f0102315:	68 05 6a 10 f0       	push   $0xf0106a05
f010231a:	68 b6 04 00 00       	push   $0x4b6
f010231f:	68 df 69 10 f0       	push   $0xf01069df
f0102324:	e8 17 dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102329:	ba 00 10 00 00       	mov    $0x1000,%edx
f010232e:	89 f8                	mov    %edi,%eax
f0102330:	e8 36 e8 ff ff       	call   f0100b6b <check_va2pa>
f0102335:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102338:	74 19                	je     f0102353 <mem_init+0xde9>
f010233a:	68 e0 73 10 f0       	push   $0xf01073e0
f010233f:	68 05 6a 10 f0       	push   $0xf0106a05
f0102344:	68 b7 04 00 00       	push   $0x4b7
f0102349:	68 df 69 10 f0       	push   $0xf01069df
f010234e:	e8 ed dc ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102353:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102358:	74 19                	je     f0102373 <mem_init+0xe09>
f010235a:	68 b0 6c 10 f0       	push   $0xf0106cb0
f010235f:	68 05 6a 10 f0       	push   $0xf0106a05
f0102364:	68 b8 04 00 00       	push   $0x4b8
f0102369:	68 df 69 10 f0       	push   $0xf01069df
f010236e:	e8 cd dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102373:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102378:	74 19                	je     f0102393 <mem_init+0xe29>
f010237a:	68 7e 6c 10 f0       	push   $0xf0106c7e
f010237f:	68 05 6a 10 f0       	push   $0xf0106a05
f0102384:	68 b9 04 00 00       	push   $0x4b9
f0102389:	68 df 69 10 f0       	push   $0xf01069df
f010238e:	e8 ad dc ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102393:	83 ec 0c             	sub    $0xc,%esp
f0102396:	6a 00                	push   $0x0
f0102398:	e8 ea ec ff ff       	call   f0101087 <page_alloc>
f010239d:	83 c4 10             	add    $0x10,%esp
f01023a0:	39 c3                	cmp    %eax,%ebx
f01023a2:	75 04                	jne    f01023a8 <mem_init+0xe3e>
f01023a4:	85 c0                	test   %eax,%eax
f01023a6:	75 19                	jne    f01023c1 <mem_init+0xe57>
f01023a8:	68 08 74 10 f0       	push   $0xf0107408
f01023ad:	68 05 6a 10 f0       	push   $0xf0106a05
f01023b2:	68 bc 04 00 00       	push   $0x4bc
f01023b7:	68 df 69 10 f0       	push   $0xf01069df
f01023bc:	e8 7f dc ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01023c1:	83 ec 0c             	sub    $0xc,%esp
f01023c4:	6a 00                	push   $0x0
f01023c6:	e8 bc ec ff ff       	call   f0101087 <page_alloc>
f01023cb:	83 c4 10             	add    $0x10,%esp
f01023ce:	85 c0                	test   %eax,%eax
f01023d0:	74 19                	je     f01023eb <mem_init+0xe81>
f01023d2:	68 d2 6b 10 f0       	push   $0xf0106bd2
f01023d7:	68 05 6a 10 f0       	push   $0xf0106a05
f01023dc:	68 bf 04 00 00       	push   $0x4bf
f01023e1:	68 df 69 10 f0       	push   $0xf01069df
f01023e6:	e8 55 dc ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01023eb:	8b 0d 8c 1e 21 f0    	mov    0xf0211e8c,%ecx
f01023f1:	8b 11                	mov    (%ecx),%edx
f01023f3:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01023f9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01023fc:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0102402:	c1 f8 03             	sar    $0x3,%eax
f0102405:	c1 e0 0c             	shl    $0xc,%eax
f0102408:	39 c2                	cmp    %eax,%edx
f010240a:	74 19                	je     f0102425 <mem_init+0xebb>
f010240c:	68 ac 70 10 f0       	push   $0xf01070ac
f0102411:	68 05 6a 10 f0       	push   $0xf0106a05
f0102416:	68 c2 04 00 00       	push   $0x4c2
f010241b:	68 df 69 10 f0       	push   $0xf01069df
f0102420:	e8 1b dc ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102425:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f010242b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010242e:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102433:	74 19                	je     f010244e <mem_init+0xee4>
f0102435:	68 35 6c 10 f0       	push   $0xf0106c35
f010243a:	68 05 6a 10 f0       	push   $0xf0106a05
f010243f:	68 c4 04 00 00       	push   $0x4c4
f0102444:	68 df 69 10 f0       	push   $0xf01069df
f0102449:	e8 f2 db ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f010244e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102451:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102457:	83 ec 0c             	sub    $0xc,%esp
f010245a:	50                   	push   %eax
f010245b:	e8 98 ec ff ff       	call   f01010f8 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102460:	83 c4 0c             	add    $0xc,%esp
f0102463:	6a 01                	push   $0x1
f0102465:	68 00 10 40 00       	push   $0x401000
f010246a:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0102470:	e8 00 ed ff ff       	call   f0101175 <pgdir_walk>
f0102475:	89 c7                	mov    %eax,%edi
f0102477:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010247a:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f010247f:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102482:	8b 40 04             	mov    0x4(%eax),%eax
f0102485:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010248a:	8b 0d 88 1e 21 f0    	mov    0xf0211e88,%ecx
f0102490:	89 c2                	mov    %eax,%edx
f0102492:	c1 ea 0c             	shr    $0xc,%edx
f0102495:	83 c4 10             	add    $0x10,%esp
f0102498:	39 ca                	cmp    %ecx,%edx
f010249a:	72 15                	jb     f01024b1 <mem_init+0xf47>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010249c:	50                   	push   %eax
f010249d:	68 24 64 10 f0       	push   $0xf0106424
f01024a2:	68 cb 04 00 00       	push   $0x4cb
f01024a7:	68 df 69 10 f0       	push   $0xf01069df
f01024ac:	e8 8f db ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01024b1:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f01024b6:	39 c7                	cmp    %eax,%edi
f01024b8:	74 19                	je     f01024d3 <mem_init+0xf69>
f01024ba:	68 c1 6c 10 f0       	push   $0xf0106cc1
f01024bf:	68 05 6a 10 f0       	push   $0xf0106a05
f01024c4:	68 cc 04 00 00       	push   $0x4cc
f01024c9:	68 df 69 10 f0       	push   $0xf01069df
f01024ce:	e8 6d db ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f01024d3:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01024d6:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f01024dd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01024e0:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01024e6:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f01024ec:	c1 f8 03             	sar    $0x3,%eax
f01024ef:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01024f2:	89 c2                	mov    %eax,%edx
f01024f4:	c1 ea 0c             	shr    $0xc,%edx
f01024f7:	39 d1                	cmp    %edx,%ecx
f01024f9:	77 12                	ja     f010250d <mem_init+0xfa3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024fb:	50                   	push   %eax
f01024fc:	68 24 64 10 f0       	push   $0xf0106424
f0102501:	6a 58                	push   $0x58
f0102503:	68 eb 69 10 f0       	push   $0xf01069eb
f0102508:	e8 33 db ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f010250d:	83 ec 04             	sub    $0x4,%esp
f0102510:	68 00 10 00 00       	push   $0x1000
f0102515:	68 ff 00 00 00       	push   $0xff
f010251a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010251f:	50                   	push   %eax
f0102520:	e8 12 32 00 00       	call   f0105737 <memset>
	page_free(pp0);
f0102525:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102528:	89 3c 24             	mov    %edi,(%esp)
f010252b:	e8 c8 eb ff ff       	call   f01010f8 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102530:	83 c4 0c             	add    $0xc,%esp
f0102533:	6a 01                	push   $0x1
f0102535:	6a 00                	push   $0x0
f0102537:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f010253d:	e8 33 ec ff ff       	call   f0101175 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102542:	89 fa                	mov    %edi,%edx
f0102544:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f010254a:	c1 fa 03             	sar    $0x3,%edx
f010254d:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102550:	89 d0                	mov    %edx,%eax
f0102552:	c1 e8 0c             	shr    $0xc,%eax
f0102555:	83 c4 10             	add    $0x10,%esp
f0102558:	3b 05 88 1e 21 f0    	cmp    0xf0211e88,%eax
f010255e:	72 12                	jb     f0102572 <mem_init+0x1008>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102560:	52                   	push   %edx
f0102561:	68 24 64 10 f0       	push   $0xf0106424
f0102566:	6a 58                	push   $0x58
f0102568:	68 eb 69 10 f0       	push   $0xf01069eb
f010256d:	e8 ce da ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102572:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102578:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010257b:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102581:	f6 00 01             	testb  $0x1,(%eax)
f0102584:	74 19                	je     f010259f <mem_init+0x1035>
f0102586:	68 d9 6c 10 f0       	push   $0xf0106cd9
f010258b:	68 05 6a 10 f0       	push   $0xf0106a05
f0102590:	68 d6 04 00 00       	push   $0x4d6
f0102595:	68 df 69 10 f0       	push   $0xf01069df
f010259a:	e8 a1 da ff ff       	call   f0100040 <_panic>
f010259f:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01025a2:	39 d0                	cmp    %edx,%eax
f01025a4:	75 db                	jne    f0102581 <mem_init+0x1017>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01025a6:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f01025ab:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01025b1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01025b4:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f01025ba:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01025bd:	89 0d 40 12 21 f0    	mov    %ecx,0xf0211240

	// free the pages we took
	page_free(pp0);
f01025c3:	83 ec 0c             	sub    $0xc,%esp
f01025c6:	50                   	push   %eax
f01025c7:	e8 2c eb ff ff       	call   f01010f8 <page_free>
	page_free(pp1);
f01025cc:	89 1c 24             	mov    %ebx,(%esp)
f01025cf:	e8 24 eb ff ff       	call   f01010f8 <page_free>
	page_free(pp2);
f01025d4:	89 34 24             	mov    %esi,(%esp)
f01025d7:	e8 1c eb ff ff       	call   f01010f8 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f01025dc:	83 c4 08             	add    $0x8,%esp
f01025df:	68 01 10 00 00       	push   $0x1001
f01025e4:	6a 00                	push   $0x0
f01025e6:	e8 16 ef ff ff       	call   f0101501 <mmio_map_region>
f01025eb:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f01025ed:	83 c4 08             	add    $0x8,%esp
f01025f0:	68 00 10 00 00       	push   $0x1000
f01025f5:	6a 00                	push   $0x0
f01025f7:	e8 05 ef ff ff       	call   f0101501 <mmio_map_region>
f01025fc:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f01025fe:	8d 83 00 20 00 00    	lea    0x2000(%ebx),%eax
f0102604:	83 c4 10             	add    $0x10,%esp
f0102607:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010260d:	76 07                	jbe    f0102616 <mem_init+0x10ac>
f010260f:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102614:	76 19                	jbe    f010262f <mem_init+0x10c5>
f0102616:	68 2c 74 10 f0       	push   $0xf010742c
f010261b:	68 05 6a 10 f0       	push   $0xf0106a05
f0102620:	68 e6 04 00 00       	push   $0x4e6
f0102625:	68 df 69 10 f0       	push   $0xf01069df
f010262a:	e8 11 da ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f010262f:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
f0102635:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f010263b:	77 08                	ja     f0102645 <mem_init+0x10db>
f010263d:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102643:	77 19                	ja     f010265e <mem_init+0x10f4>
f0102645:	68 54 74 10 f0       	push   $0xf0107454
f010264a:	68 05 6a 10 f0       	push   $0xf0106a05
f010264f:	68 e7 04 00 00       	push   $0x4e7
f0102654:	68 df 69 10 f0       	push   $0xf01069df
f0102659:	e8 e2 d9 ff ff       	call   f0100040 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f010265e:	89 da                	mov    %ebx,%edx
f0102660:	09 f2                	or     %esi,%edx
f0102662:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102668:	74 19                	je     f0102683 <mem_init+0x1119>
f010266a:	68 7c 74 10 f0       	push   $0xf010747c
f010266f:	68 05 6a 10 f0       	push   $0xf0106a05
f0102674:	68 e9 04 00 00       	push   $0x4e9
f0102679:	68 df 69 10 f0       	push   $0xf01069df
f010267e:	e8 bd d9 ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8192 <= mm2);
f0102683:	39 c6                	cmp    %eax,%esi
f0102685:	73 19                	jae    f01026a0 <mem_init+0x1136>
f0102687:	68 f0 6c 10 f0       	push   $0xf0106cf0
f010268c:	68 05 6a 10 f0       	push   $0xf0106a05
f0102691:	68 eb 04 00 00       	push   $0x4eb
f0102696:	68 df 69 10 f0       	push   $0xf01069df
f010269b:	e8 a0 d9 ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01026a0:	8b 3d 8c 1e 21 f0    	mov    0xf0211e8c,%edi
f01026a6:	89 da                	mov    %ebx,%edx
f01026a8:	89 f8                	mov    %edi,%eax
f01026aa:	e8 bc e4 ff ff       	call   f0100b6b <check_va2pa>
f01026af:	85 c0                	test   %eax,%eax
f01026b1:	74 19                	je     f01026cc <mem_init+0x1162>
f01026b3:	68 a4 74 10 f0       	push   $0xf01074a4
f01026b8:	68 05 6a 10 f0       	push   $0xf0106a05
f01026bd:	68 ed 04 00 00       	push   $0x4ed
f01026c2:	68 df 69 10 f0       	push   $0xf01069df
f01026c7:	e8 74 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01026cc:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f01026d2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01026d5:	89 c2                	mov    %eax,%edx
f01026d7:	89 f8                	mov    %edi,%eax
f01026d9:	e8 8d e4 ff ff       	call   f0100b6b <check_va2pa>
f01026de:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01026e3:	74 19                	je     f01026fe <mem_init+0x1194>
f01026e5:	68 c8 74 10 f0       	push   $0xf01074c8
f01026ea:	68 05 6a 10 f0       	push   $0xf0106a05
f01026ef:	68 ee 04 00 00       	push   $0x4ee
f01026f4:	68 df 69 10 f0       	push   $0xf01069df
f01026f9:	e8 42 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f01026fe:	89 f2                	mov    %esi,%edx
f0102700:	89 f8                	mov    %edi,%eax
f0102702:	e8 64 e4 ff ff       	call   f0100b6b <check_va2pa>
f0102707:	85 c0                	test   %eax,%eax
f0102709:	74 19                	je     f0102724 <mem_init+0x11ba>
f010270b:	68 f8 74 10 f0       	push   $0xf01074f8
f0102710:	68 05 6a 10 f0       	push   $0xf0106a05
f0102715:	68 ef 04 00 00       	push   $0x4ef
f010271a:	68 df 69 10 f0       	push   $0xf01069df
f010271f:	e8 1c d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102724:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f010272a:	89 f8                	mov    %edi,%eax
f010272c:	e8 3a e4 ff ff       	call   f0100b6b <check_va2pa>
f0102731:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102734:	74 19                	je     f010274f <mem_init+0x11e5>
f0102736:	68 1c 75 10 f0       	push   $0xf010751c
f010273b:	68 05 6a 10 f0       	push   $0xf0106a05
f0102740:	68 f0 04 00 00       	push   $0x4f0
f0102745:	68 df 69 10 f0       	push   $0xf01069df
f010274a:	e8 f1 d8 ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f010274f:	83 ec 04             	sub    $0x4,%esp
f0102752:	6a 00                	push   $0x0
f0102754:	53                   	push   %ebx
f0102755:	57                   	push   %edi
f0102756:	e8 1a ea ff ff       	call   f0101175 <pgdir_walk>
f010275b:	83 c4 10             	add    $0x10,%esp
f010275e:	f6 00 1a             	testb  $0x1a,(%eax)
f0102761:	75 19                	jne    f010277c <mem_init+0x1212>
f0102763:	68 48 75 10 f0       	push   $0xf0107548
f0102768:	68 05 6a 10 f0       	push   $0xf0106a05
f010276d:	68 f2 04 00 00       	push   $0x4f2
f0102772:	68 df 69 10 f0       	push   $0xf01069df
f0102777:	e8 c4 d8 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f010277c:	83 ec 04             	sub    $0x4,%esp
f010277f:	6a 00                	push   $0x0
f0102781:	53                   	push   %ebx
f0102782:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0102788:	e8 e8 e9 ff ff       	call   f0101175 <pgdir_walk>
f010278d:	8b 00                	mov    (%eax),%eax
f010278f:	83 c4 10             	add    $0x10,%esp
f0102792:	83 e0 04             	and    $0x4,%eax
f0102795:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102798:	74 19                	je     f01027b3 <mem_init+0x1249>
f010279a:	68 8c 75 10 f0       	push   $0xf010758c
f010279f:	68 05 6a 10 f0       	push   $0xf0106a05
f01027a4:	68 f3 04 00 00       	push   $0x4f3
f01027a9:	68 df 69 10 f0       	push   $0xf01069df
f01027ae:	e8 8d d8 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f01027b3:	83 ec 04             	sub    $0x4,%esp
f01027b6:	6a 00                	push   $0x0
f01027b8:	53                   	push   %ebx
f01027b9:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f01027bf:	e8 b1 e9 ff ff       	call   f0101175 <pgdir_walk>
f01027c4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f01027ca:	83 c4 0c             	add    $0xc,%esp
f01027cd:	6a 00                	push   $0x0
f01027cf:	ff 75 d4             	pushl  -0x2c(%ebp)
f01027d2:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f01027d8:	e8 98 e9 ff ff       	call   f0101175 <pgdir_walk>
f01027dd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f01027e3:	83 c4 0c             	add    $0xc,%esp
f01027e6:	6a 00                	push   $0x0
f01027e8:	56                   	push   %esi
f01027e9:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f01027ef:	e8 81 e9 ff ff       	call   f0101175 <pgdir_walk>
f01027f4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f01027fa:	c7 04 24 02 6d 10 f0 	movl   $0xf0106d02,(%esp)
f0102801:	e8 5c 11 00 00       	call   f0103962 <cprintf>
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f0102806:	a1 90 1e 21 f0       	mov    0xf0211e90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010280b:	83 c4 10             	add    $0x10,%esp
f010280e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102813:	77 15                	ja     f010282a <mem_init+0x12c0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102815:	50                   	push   %eax
f0102816:	68 48 64 10 f0       	push   $0xf0106448
f010281b:	68 ca 00 00 00       	push   $0xca
f0102820:	68 df 69 10 f0       	push   $0xf01069df
f0102825:	e8 16 d8 ff ff       	call   f0100040 <_panic>
f010282a:	83 ec 08             	sub    $0x8,%esp
f010282d:	6a 04                	push   $0x4
f010282f:	05 00 00 00 10       	add    $0x10000000,%eax
f0102834:	50                   	push   %eax
f0102835:	b9 00 00 40 00       	mov    $0x400000,%ecx
f010283a:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f010283f:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0102844:	e8 76 ea ff ff       	call   f01012bf <boot_map_region>
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.

	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U);
f0102849:	a1 48 12 21 f0       	mov    0xf0211248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010284e:	83 c4 10             	add    $0x10,%esp
f0102851:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102856:	77 15                	ja     f010286d <mem_init+0x1303>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102858:	50                   	push   %eax
f0102859:	68 48 64 10 f0       	push   $0xf0106448
f010285e:	68 d4 00 00 00       	push   $0xd4
f0102863:	68 df 69 10 f0       	push   $0xf01069df
f0102868:	e8 d3 d7 ff ff       	call   f0100040 <_panic>
f010286d:	83 ec 08             	sub    $0x8,%esp
f0102870:	6a 04                	push   $0x4
f0102872:	05 00 00 00 10       	add    $0x10000000,%eax
f0102877:	50                   	push   %eax
f0102878:	b9 00 00 40 00       	mov    $0x400000,%ecx
f010287d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102882:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0102887:	e8 33 ea ff ff       	call   f01012bf <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010288c:	83 c4 10             	add    $0x10,%esp
f010288f:	b8 00 60 11 f0       	mov    $0xf0116000,%eax
f0102894:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102899:	77 15                	ja     f01028b0 <mem_init+0x1346>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010289b:	50                   	push   %eax
f010289c:	68 48 64 10 f0       	push   $0xf0106448
f01028a1:	68 e2 00 00 00       	push   $0xe2
f01028a6:	68 df 69 10 f0       	push   $0xf01069df
f01028ab:	e8 90 d7 ff ff       	call   f0100040 <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f01028b0:	83 ec 08             	sub    $0x8,%esp
f01028b3:	6a 02                	push   $0x2
f01028b5:	68 00 60 11 00       	push   $0x116000
f01028ba:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01028bf:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01028c4:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f01028c9:	e8 f1 e9 ff ff       	call   f01012bf <boot_map_region>
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, KERNBASE, ROUNDUP(~0 - KERNBASE, PGSIZE), 0, PTE_W);
f01028ce:	83 c4 08             	add    $0x8,%esp
f01028d1:	6a 02                	push   $0x2
f01028d3:	6a 00                	push   $0x0
f01028d5:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01028da:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01028df:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f01028e4:	e8 d6 e9 ff ff       	call   f01012bf <boot_map_region>
f01028e9:	c7 45 c4 00 30 21 f0 	movl   $0xf0213000,-0x3c(%ebp)
f01028f0:	83 c4 10             	add    $0x10,%esp
f01028f3:	bb 00 30 21 f0       	mov    $0xf0213000,%ebx
f01028f8:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01028fd:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102903:	77 15                	ja     f010291a <mem_init+0x13b0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102905:	53                   	push   %ebx
f0102906:	68 48 64 10 f0       	push   $0xf0106448
f010290b:	68 26 01 00 00       	push   $0x126
f0102910:	68 df 69 10 f0       	push   $0xf01069df
f0102915:	e8 26 d7 ff ff       	call   f0100040 <_panic>

	uint32_t kstacktop_i;

	for (int i=0; i<NCPU; i++) {
		kstacktop_i = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
		boot_map_region(kern_pgdir, kstacktop_i - KSTKSIZE, KSTKSIZE, PADDR(&percpu_kstacks[i]), PTE_W );
f010291a:	83 ec 08             	sub    $0x8,%esp
f010291d:	6a 02                	push   $0x2
f010291f:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102925:	50                   	push   %eax
f0102926:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010292b:	89 f2                	mov    %esi,%edx
f010292d:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0102932:	e8 88 e9 ff ff       	call   f01012bf <boot_map_region>
f0102937:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f010293d:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//
	// LAB 4: Your code here:

	uint32_t kstacktop_i;

	for (int i=0; i<NCPU; i++) {
f0102943:	83 c4 10             	add    $0x10,%esp
f0102946:	b8 00 30 25 f0       	mov    $0xf0253000,%eax
f010294b:	39 d8                	cmp    %ebx,%eax
f010294d:	75 ae                	jne    f01028fd <mem_init+0x1393>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f010294f:	8b 3d 8c 1e 21 f0    	mov    0xf0211e8c,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102955:	a1 88 1e 21 f0       	mov    0xf0211e88,%eax
f010295a:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010295d:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102964:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102969:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010296c:	8b 35 90 1e 21 f0    	mov    0xf0211e90,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102972:	89 75 d0             	mov    %esi,-0x30(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102975:	bb 00 00 00 00       	mov    $0x0,%ebx
f010297a:	eb 55                	jmp    f01029d1 <mem_init+0x1467>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010297c:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102982:	89 f8                	mov    %edi,%eax
f0102984:	e8 e2 e1 ff ff       	call   f0100b6b <check_va2pa>
f0102989:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102990:	77 15                	ja     f01029a7 <mem_init+0x143d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102992:	56                   	push   %esi
f0102993:	68 48 64 10 f0       	push   $0xf0106448
f0102998:	68 07 04 00 00       	push   $0x407
f010299d:	68 df 69 10 f0       	push   $0xf01069df
f01029a2:	e8 99 d6 ff ff       	call   f0100040 <_panic>
f01029a7:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f01029ae:	39 c2                	cmp    %eax,%edx
f01029b0:	74 19                	je     f01029cb <mem_init+0x1461>
f01029b2:	68 c0 75 10 f0       	push   $0xf01075c0
f01029b7:	68 05 6a 10 f0       	push   $0xf0106a05
f01029bc:	68 07 04 00 00       	push   $0x407
f01029c1:	68 df 69 10 f0       	push   $0xf01069df
f01029c6:	e8 75 d6 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01029cb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01029d1:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01029d4:	77 a6                	ja     f010297c <mem_init+0x1412>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01029d6:	8b 35 48 12 21 f0    	mov    0xf0211248,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01029dc:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f01029df:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f01029e4:	89 da                	mov    %ebx,%edx
f01029e6:	89 f8                	mov    %edi,%eax
f01029e8:	e8 7e e1 ff ff       	call   f0100b6b <check_va2pa>
f01029ed:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f01029f4:	77 15                	ja     f0102a0b <mem_init+0x14a1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029f6:	56                   	push   %esi
f01029f7:	68 48 64 10 f0       	push   $0xf0106448
f01029fc:	68 0c 04 00 00       	push   $0x40c
f0102a01:	68 df 69 10 f0       	push   $0xf01069df
f0102a06:	e8 35 d6 ff ff       	call   f0100040 <_panic>
f0102a0b:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f0102a12:	39 d0                	cmp    %edx,%eax
f0102a14:	74 19                	je     f0102a2f <mem_init+0x14c5>
f0102a16:	68 f4 75 10 f0       	push   $0xf01075f4
f0102a1b:	68 05 6a 10 f0       	push   $0xf0106a05
f0102a20:	68 0c 04 00 00       	push   $0x40c
f0102a25:	68 df 69 10 f0       	push   $0xf01069df
f0102a2a:	e8 11 d6 ff ff       	call   f0100040 <_panic>
f0102a2f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102a35:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102a3b:	75 a7                	jne    f01029e4 <mem_init+0x147a>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102a3d:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0102a40:	c1 e6 0c             	shl    $0xc,%esi
f0102a43:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102a48:	eb 30                	jmp    f0102a7a <mem_init+0x1510>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102a4a:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102a50:	89 f8                	mov    %edi,%eax
f0102a52:	e8 14 e1 ff ff       	call   f0100b6b <check_va2pa>
f0102a57:	39 c3                	cmp    %eax,%ebx
f0102a59:	74 19                	je     f0102a74 <mem_init+0x150a>
f0102a5b:	68 28 76 10 f0       	push   $0xf0107628
f0102a60:	68 05 6a 10 f0       	push   $0xf0106a05
f0102a65:	68 10 04 00 00       	push   $0x410
f0102a6a:	68 df 69 10 f0       	push   $0xf01069df
f0102a6f:	e8 cc d5 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102a74:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102a7a:	39 f3                	cmp    %esi,%ebx
f0102a7c:	72 cc                	jb     f0102a4a <mem_init+0x14e0>
f0102a7e:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102a83:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0102a86:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0102a89:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102a8c:	8d 88 00 80 00 00    	lea    0x8000(%eax),%ecx
f0102a92:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0102a95:	89 c3                	mov    %eax,%ebx
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102a97:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102a9a:	05 00 80 00 20       	add    $0x20008000,%eax
f0102a9f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102aa2:	89 da                	mov    %ebx,%edx
f0102aa4:	89 f8                	mov    %edi,%eax
f0102aa6:	e8 c0 e0 ff ff       	call   f0100b6b <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102aab:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102ab1:	77 15                	ja     f0102ac8 <mem_init+0x155e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ab3:	56                   	push   %esi
f0102ab4:	68 48 64 10 f0       	push   $0xf0106448
f0102ab9:	68 18 04 00 00       	push   $0x418
f0102abe:	68 df 69 10 f0       	push   $0xf01069df
f0102ac3:	e8 78 d5 ff ff       	call   f0100040 <_panic>
f0102ac8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102acb:	8d 94 0b 00 30 21 f0 	lea    -0xfded000(%ebx,%ecx,1),%edx
f0102ad2:	39 d0                	cmp    %edx,%eax
f0102ad4:	74 19                	je     f0102aef <mem_init+0x1585>
f0102ad6:	68 50 76 10 f0       	push   $0xf0107650
f0102adb:	68 05 6a 10 f0       	push   $0xf0106a05
f0102ae0:	68 18 04 00 00       	push   $0x418
f0102ae5:	68 df 69 10 f0       	push   $0xf01069df
f0102aea:	e8 51 d5 ff ff       	call   f0100040 <_panic>
f0102aef:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102af5:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f0102af8:	75 a8                	jne    f0102aa2 <mem_init+0x1538>
f0102afa:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102afd:	8d 98 00 80 ff ff    	lea    -0x8000(%eax),%ebx
f0102b03:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102b06:	89 c6                	mov    %eax,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102b08:	89 da                	mov    %ebx,%edx
f0102b0a:	89 f8                	mov    %edi,%eax
f0102b0c:	e8 5a e0 ff ff       	call   f0100b6b <check_va2pa>
f0102b11:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102b14:	74 19                	je     f0102b2f <mem_init+0x15c5>
f0102b16:	68 98 76 10 f0       	push   $0xf0107698
f0102b1b:	68 05 6a 10 f0       	push   $0xf0106a05
f0102b20:	68 1a 04 00 00       	push   $0x41a
f0102b25:	68 df 69 10 f0       	push   $0xf01069df
f0102b2a:	e8 11 d5 ff ff       	call   f0100040 <_panic>
f0102b2f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102b35:	39 f3                	cmp    %esi,%ebx
f0102b37:	75 cf                	jne    f0102b08 <mem_init+0x159e>
f0102b39:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102b3c:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f0102b43:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f0102b4a:	81 c6 00 80 00 00    	add    $0x8000,%esi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102b50:	b8 00 30 25 f0       	mov    $0xf0253000,%eax
f0102b55:	39 f0                	cmp    %esi,%eax
f0102b57:	0f 85 2c ff ff ff    	jne    f0102a89 <mem_init+0x151f>
f0102b5d:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b62:	eb 2a                	jmp    f0102b8e <mem_init+0x1624>
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102b64:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102b6a:	83 fa 04             	cmp    $0x4,%edx
f0102b6d:	77 1f                	ja     f0102b8e <mem_init+0x1624>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f0102b6f:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102b73:	75 7e                	jne    f0102bf3 <mem_init+0x1689>
f0102b75:	68 1b 6d 10 f0       	push   $0xf0106d1b
f0102b7a:	68 05 6a 10 f0       	push   $0xf0106a05
f0102b7f:	68 25 04 00 00       	push   $0x425
f0102b84:	68 df 69 10 f0       	push   $0xf01069df
f0102b89:	e8 b2 d4 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102b8e:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102b93:	76 3f                	jbe    f0102bd4 <mem_init+0x166a>
				assert(pgdir[i] & PTE_P);
f0102b95:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102b98:	f6 c2 01             	test   $0x1,%dl
f0102b9b:	75 19                	jne    f0102bb6 <mem_init+0x164c>
f0102b9d:	68 1b 6d 10 f0       	push   $0xf0106d1b
f0102ba2:	68 05 6a 10 f0       	push   $0xf0106a05
f0102ba7:	68 29 04 00 00       	push   $0x429
f0102bac:	68 df 69 10 f0       	push   $0xf01069df
f0102bb1:	e8 8a d4 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102bb6:	f6 c2 02             	test   $0x2,%dl
f0102bb9:	75 38                	jne    f0102bf3 <mem_init+0x1689>
f0102bbb:	68 2c 6d 10 f0       	push   $0xf0106d2c
f0102bc0:	68 05 6a 10 f0       	push   $0xf0106a05
f0102bc5:	68 2a 04 00 00       	push   $0x42a
f0102bca:	68 df 69 10 f0       	push   $0xf01069df
f0102bcf:	e8 6c d4 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102bd4:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102bd8:	74 19                	je     f0102bf3 <mem_init+0x1689>
f0102bda:	68 3d 6d 10 f0       	push   $0xf0106d3d
f0102bdf:	68 05 6a 10 f0       	push   $0xf0106a05
f0102be4:	68 2c 04 00 00       	push   $0x42c
f0102be9:	68 df 69 10 f0       	push   $0xf01069df
f0102bee:	e8 4d d4 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102bf3:	83 c0 01             	add    $0x1,%eax
f0102bf6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102bfb:	0f 86 63 ff ff ff    	jbe    f0102b64 <mem_init+0x15fa>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102c01:	83 ec 0c             	sub    $0xc,%esp
f0102c04:	68 bc 76 10 f0       	push   $0xf01076bc
f0102c09:	e8 54 0d 00 00       	call   f0103962 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102c0e:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c13:	83 c4 10             	add    $0x10,%esp
f0102c16:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c1b:	77 15                	ja     f0102c32 <mem_init+0x16c8>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c1d:	50                   	push   %eax
f0102c1e:	68 48 64 10 f0       	push   $0xf0106448
f0102c23:	68 fc 00 00 00       	push   $0xfc
f0102c28:	68 df 69 10 f0       	push   $0xf01069df
f0102c2d:	e8 0e d4 ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102c32:	05 00 00 00 10       	add    $0x10000000,%eax
f0102c37:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102c3a:	b8 00 00 00 00       	mov    $0x0,%eax
f0102c3f:	e8 8b df ff ff       	call   f0100bcf <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102c44:	0f 20 c0             	mov    %cr0,%eax
f0102c47:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102c4a:	0d 23 00 05 80       	or     $0x80050023,%eax
f0102c4f:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102c52:	83 ec 0c             	sub    $0xc,%esp
f0102c55:	6a 00                	push   $0x0
f0102c57:	e8 2b e4 ff ff       	call   f0101087 <page_alloc>
f0102c5c:	89 c3                	mov    %eax,%ebx
f0102c5e:	83 c4 10             	add    $0x10,%esp
f0102c61:	85 c0                	test   %eax,%eax
f0102c63:	75 19                	jne    f0102c7e <mem_init+0x1714>
f0102c65:	68 27 6b 10 f0       	push   $0xf0106b27
f0102c6a:	68 05 6a 10 f0       	push   $0xf0106a05
f0102c6f:	68 08 05 00 00       	push   $0x508
f0102c74:	68 df 69 10 f0       	push   $0xf01069df
f0102c79:	e8 c2 d3 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102c7e:	83 ec 0c             	sub    $0xc,%esp
f0102c81:	6a 00                	push   $0x0
f0102c83:	e8 ff e3 ff ff       	call   f0101087 <page_alloc>
f0102c88:	89 c7                	mov    %eax,%edi
f0102c8a:	83 c4 10             	add    $0x10,%esp
f0102c8d:	85 c0                	test   %eax,%eax
f0102c8f:	75 19                	jne    f0102caa <mem_init+0x1740>
f0102c91:	68 3d 6b 10 f0       	push   $0xf0106b3d
f0102c96:	68 05 6a 10 f0       	push   $0xf0106a05
f0102c9b:	68 09 05 00 00       	push   $0x509
f0102ca0:	68 df 69 10 f0       	push   $0xf01069df
f0102ca5:	e8 96 d3 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102caa:	83 ec 0c             	sub    $0xc,%esp
f0102cad:	6a 00                	push   $0x0
f0102caf:	e8 d3 e3 ff ff       	call   f0101087 <page_alloc>
f0102cb4:	89 c6                	mov    %eax,%esi
f0102cb6:	83 c4 10             	add    $0x10,%esp
f0102cb9:	85 c0                	test   %eax,%eax
f0102cbb:	75 19                	jne    f0102cd6 <mem_init+0x176c>
f0102cbd:	68 53 6b 10 f0       	push   $0xf0106b53
f0102cc2:	68 05 6a 10 f0       	push   $0xf0106a05
f0102cc7:	68 0a 05 00 00       	push   $0x50a
f0102ccc:	68 df 69 10 f0       	push   $0xf01069df
f0102cd1:	e8 6a d3 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0102cd6:	83 ec 0c             	sub    $0xc,%esp
f0102cd9:	53                   	push   %ebx
f0102cda:	e8 19 e4 ff ff       	call   f01010f8 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102cdf:	89 f8                	mov    %edi,%eax
f0102ce1:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0102ce7:	c1 f8 03             	sar    $0x3,%eax
f0102cea:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102ced:	89 c2                	mov    %eax,%edx
f0102cef:	c1 ea 0c             	shr    $0xc,%edx
f0102cf2:	83 c4 10             	add    $0x10,%esp
f0102cf5:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f0102cfb:	72 12                	jb     f0102d0f <mem_init+0x17a5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102cfd:	50                   	push   %eax
f0102cfe:	68 24 64 10 f0       	push   $0xf0106424
f0102d03:	6a 58                	push   $0x58
f0102d05:	68 eb 69 10 f0       	push   $0xf01069eb
f0102d0a:	e8 31 d3 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102d0f:	83 ec 04             	sub    $0x4,%esp
f0102d12:	68 00 10 00 00       	push   $0x1000
f0102d17:	6a 01                	push   $0x1
f0102d19:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102d1e:	50                   	push   %eax
f0102d1f:	e8 13 2a 00 00       	call   f0105737 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102d24:	89 f0                	mov    %esi,%eax
f0102d26:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0102d2c:	c1 f8 03             	sar    $0x3,%eax
f0102d2f:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102d32:	89 c2                	mov    %eax,%edx
f0102d34:	c1 ea 0c             	shr    $0xc,%edx
f0102d37:	83 c4 10             	add    $0x10,%esp
f0102d3a:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f0102d40:	72 12                	jb     f0102d54 <mem_init+0x17ea>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d42:	50                   	push   %eax
f0102d43:	68 24 64 10 f0       	push   $0xf0106424
f0102d48:	6a 58                	push   $0x58
f0102d4a:	68 eb 69 10 f0       	push   $0xf01069eb
f0102d4f:	e8 ec d2 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102d54:	83 ec 04             	sub    $0x4,%esp
f0102d57:	68 00 10 00 00       	push   $0x1000
f0102d5c:	6a 02                	push   $0x2
f0102d5e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102d63:	50                   	push   %eax
f0102d64:	e8 ce 29 00 00       	call   f0105737 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102d69:	6a 02                	push   $0x2
f0102d6b:	68 00 10 00 00       	push   $0x1000
f0102d70:	57                   	push   %edi
f0102d71:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0102d77:	e8 fe e6 ff ff       	call   f010147a <page_insert>
	assert(pp1->pp_ref == 1);
f0102d7c:	83 c4 20             	add    $0x20,%esp
f0102d7f:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102d84:	74 19                	je     f0102d9f <mem_init+0x1835>
f0102d86:	68 24 6c 10 f0       	push   $0xf0106c24
f0102d8b:	68 05 6a 10 f0       	push   $0xf0106a05
f0102d90:	68 0f 05 00 00       	push   $0x50f
f0102d95:	68 df 69 10 f0       	push   $0xf01069df
f0102d9a:	e8 a1 d2 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102d9f:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102da6:	01 01 01 
f0102da9:	74 19                	je     f0102dc4 <mem_init+0x185a>
f0102dab:	68 dc 76 10 f0       	push   $0xf01076dc
f0102db0:	68 05 6a 10 f0       	push   $0xf0106a05
f0102db5:	68 10 05 00 00       	push   $0x510
f0102dba:	68 df 69 10 f0       	push   $0xf01069df
f0102dbf:	e8 7c d2 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102dc4:	6a 02                	push   $0x2
f0102dc6:	68 00 10 00 00       	push   $0x1000
f0102dcb:	56                   	push   %esi
f0102dcc:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0102dd2:	e8 a3 e6 ff ff       	call   f010147a <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102dd7:	83 c4 10             	add    $0x10,%esp
f0102dda:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102de1:	02 02 02 
f0102de4:	74 19                	je     f0102dff <mem_init+0x1895>
f0102de6:	68 00 77 10 f0       	push   $0xf0107700
f0102deb:	68 05 6a 10 f0       	push   $0xf0106a05
f0102df0:	68 12 05 00 00       	push   $0x512
f0102df5:	68 df 69 10 f0       	push   $0xf01069df
f0102dfa:	e8 41 d2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102dff:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102e04:	74 19                	je     f0102e1f <mem_init+0x18b5>
f0102e06:	68 46 6c 10 f0       	push   $0xf0106c46
f0102e0b:	68 05 6a 10 f0       	push   $0xf0106a05
f0102e10:	68 13 05 00 00       	push   $0x513
f0102e15:	68 df 69 10 f0       	push   $0xf01069df
f0102e1a:	e8 21 d2 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102e1f:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102e24:	74 19                	je     f0102e3f <mem_init+0x18d5>
f0102e26:	68 b0 6c 10 f0       	push   $0xf0106cb0
f0102e2b:	68 05 6a 10 f0       	push   $0xf0106a05
f0102e30:	68 14 05 00 00       	push   $0x514
f0102e35:	68 df 69 10 f0       	push   $0xf01069df
f0102e3a:	e8 01 d2 ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102e3f:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102e46:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102e49:	89 f0                	mov    %esi,%eax
f0102e4b:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0102e51:	c1 f8 03             	sar    $0x3,%eax
f0102e54:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102e57:	89 c2                	mov    %eax,%edx
f0102e59:	c1 ea 0c             	shr    $0xc,%edx
f0102e5c:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f0102e62:	72 12                	jb     f0102e76 <mem_init+0x190c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102e64:	50                   	push   %eax
f0102e65:	68 24 64 10 f0       	push   $0xf0106424
f0102e6a:	6a 58                	push   $0x58
f0102e6c:	68 eb 69 10 f0       	push   $0xf01069eb
f0102e71:	e8 ca d1 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102e76:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102e7d:	03 03 03 
f0102e80:	74 19                	je     f0102e9b <mem_init+0x1931>
f0102e82:	68 24 77 10 f0       	push   $0xf0107724
f0102e87:	68 05 6a 10 f0       	push   $0xf0106a05
f0102e8c:	68 16 05 00 00       	push   $0x516
f0102e91:	68 df 69 10 f0       	push   $0xf01069df
f0102e96:	e8 a5 d1 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102e9b:	83 ec 08             	sub    $0x8,%esp
f0102e9e:	68 00 10 00 00       	push   $0x1000
f0102ea3:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0102ea9:	e8 7f e5 ff ff       	call   f010142d <page_remove>
	assert(pp2->pp_ref == 0);
f0102eae:	83 c4 10             	add    $0x10,%esp
f0102eb1:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102eb6:	74 19                	je     f0102ed1 <mem_init+0x1967>
f0102eb8:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0102ebd:	68 05 6a 10 f0       	push   $0xf0106a05
f0102ec2:	68 18 05 00 00       	push   $0x518
f0102ec7:	68 df 69 10 f0       	push   $0xf01069df
f0102ecc:	e8 6f d1 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102ed1:	8b 0d 8c 1e 21 f0    	mov    0xf0211e8c,%ecx
f0102ed7:	8b 11                	mov    (%ecx),%edx
f0102ed9:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102edf:	89 d8                	mov    %ebx,%eax
f0102ee1:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0102ee7:	c1 f8 03             	sar    $0x3,%eax
f0102eea:	c1 e0 0c             	shl    $0xc,%eax
f0102eed:	39 c2                	cmp    %eax,%edx
f0102eef:	74 19                	je     f0102f0a <mem_init+0x19a0>
f0102ef1:	68 ac 70 10 f0       	push   $0xf01070ac
f0102ef6:	68 05 6a 10 f0       	push   $0xf0106a05
f0102efb:	68 1b 05 00 00       	push   $0x51b
f0102f00:	68 df 69 10 f0       	push   $0xf01069df
f0102f05:	e8 36 d1 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102f0a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102f10:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102f15:	74 19                	je     f0102f30 <mem_init+0x19c6>
f0102f17:	68 35 6c 10 f0       	push   $0xf0106c35
f0102f1c:	68 05 6a 10 f0       	push   $0xf0106a05
f0102f21:	68 1d 05 00 00       	push   $0x51d
f0102f26:	68 df 69 10 f0       	push   $0xf01069df
f0102f2b:	e8 10 d1 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102f30:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102f36:	83 ec 0c             	sub    $0xc,%esp
f0102f39:	53                   	push   %ebx
f0102f3a:	e8 b9 e1 ff ff       	call   f01010f8 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102f3f:	c7 04 24 50 77 10 f0 	movl   $0xf0107750,(%esp)
f0102f46:	e8 17 0a 00 00       	call   f0103962 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102f4b:	83 c4 10             	add    $0x10,%esp
f0102f4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f51:	5b                   	pop    %ebx
f0102f52:	5e                   	pop    %esi
f0102f53:	5f                   	pop    %edi
f0102f54:	5d                   	pop    %ebp
f0102f55:	c3                   	ret    

f0102f56 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102f56:	55                   	push   %ebp
f0102f57:	89 e5                	mov    %esp,%ebp
f0102f59:	57                   	push   %edi
f0102f5a:	56                   	push   %esi
f0102f5b:	53                   	push   %ebx
f0102f5c:	83 ec 1c             	sub    $0x1c,%esp
f0102f5f:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102f62:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 3: Your code here.

	pte_t* pte;

	// for every page in this region
	for (void* i=ROUNDDOWN((void *)va, PGSIZE); i<ROUNDUP((void *)(va+len), PGSIZE); i+=PGSIZE) {
f0102f65:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f68:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102f6d:	89 c3                	mov    %eax,%ebx
f0102f6f:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0102f72:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f75:	03 45 10             	add    0x10(%ebp),%eax
f0102f78:	05 ff 0f 00 00       	add    $0xfff,%eax
f0102f7d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102f82:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102f85:	e9 9e 00 00 00       	jmp    f0103028 <user_mem_check+0xd2>

		if ((uintptr_t)i >= ULIM) {
f0102f8a:	89 5d e0             	mov    %ebx,-0x20(%ebp)
f0102f8d:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102f93:	76 18                	jbe    f0102fad <user_mem_check+0x57>
			user_mem_check_addr = (i == ROUNDDOWN((void *)va, PGSIZE))? (uintptr_t)va:(uintptr_t)i;
f0102f95:	3b 5d dc             	cmp    -0x24(%ebp),%ebx
f0102f98:	89 d8                	mov    %ebx,%eax
f0102f9a:	0f 44 45 0c          	cmove  0xc(%ebp),%eax
f0102f9e:	a3 3c 12 21 f0       	mov    %eax,0xf021123c
			return -E_FAULT;
f0102fa3:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102fa8:	e9 89 00 00 00       	jmp    f0103036 <user_mem_check+0xe0>
		}

		//  get this page
		pte = pgdir_walk(env->env_pgdir, i, 0);
f0102fad:	83 ec 04             	sub    $0x4,%esp
f0102fb0:	6a 00                	push   $0x0
f0102fb2:	53                   	push   %ebx
f0102fb3:	ff 77 60             	pushl  0x60(%edi)
f0102fb6:	e8 ba e1 ff ff       	call   f0101175 <pgdir_walk>

		if (pte == NULL || (uint32_t)(*pte) == 0) {
f0102fbb:	83 c4 10             	add    $0x10,%esp
f0102fbe:	85 c0                	test   %eax,%eax
f0102fc0:	74 06                	je     f0102fc8 <user_mem_check+0x72>
f0102fc2:	8b 10                	mov    (%eax),%edx
f0102fc4:	85 d2                	test   %edx,%edx
f0102fc6:	75 2b                	jne    f0102ff3 <user_mem_check+0x9d>
			user_mem_check_addr = (i == ROUNDDOWN((void *)va, PGSIZE))? (uintptr_t)va:(uintptr_t)i;
f0102fc8:	3b 5d dc             	cmp    -0x24(%ebp),%ebx
f0102fcb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0102fce:	0f 44 4d 0c          	cmove  0xc(%ebp),%ecx
f0102fd2:	89 0d 3c 12 21 f0    	mov    %ecx,0xf021123c
			cprintf("[-] page [0x%x] error, %d, %d\n", (uint32_t)(*pte), ((uint32_t)(*pte) & perm), perm);
f0102fd8:	8b 00                	mov    (%eax),%eax
f0102fda:	56                   	push   %esi
f0102fdb:	21 c6                	and    %eax,%esi
f0102fdd:	56                   	push   %esi
f0102fde:	50                   	push   %eax
f0102fdf:	68 7c 77 10 f0       	push   $0xf010777c
f0102fe4:	e8 79 09 00 00       	call   f0103962 <cprintf>
			return -E_FAULT;
f0102fe9:	83 c4 10             	add    $0x10,%esp
f0102fec:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102ff1:	eb 43                	jmp    f0103036 <user_mem_check+0xe0>
		}

		// perm wrong
		if (((uint32_t)(*pte) & perm) != perm) {
f0102ff3:	89 d0                	mov    %edx,%eax
f0102ff5:	21 f0                	and    %esi,%eax
f0102ff7:	39 c6                	cmp    %eax,%esi
f0102ff9:	74 27                	je     f0103022 <user_mem_check+0xcc>
			// if happens at first page, we return va instead of ROUNDDOWN(va, PGSIZE)
			// just to make it more precise 
			user_mem_check_addr = (i == ROUNDDOWN((void *)va, PGSIZE))? (uintptr_t)va:(uintptr_t)i;
f0102ffb:	3b 5d dc             	cmp    -0x24(%ebp),%ebx
f0102ffe:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103001:	0f 44 4d 0c          	cmove  0xc(%ebp),%ecx
f0103005:	89 0d 3c 12 21 f0    	mov    %ecx,0xf021123c
			cprintf("[-] page [0x%x] perf error, %d, %d\n", (uint32_t)(*pte), ((uint32_t)(*pte) & perm), perm);
f010300b:	56                   	push   %esi
f010300c:	50                   	push   %eax
f010300d:	52                   	push   %edx
f010300e:	68 9c 77 10 f0       	push   $0xf010779c
f0103013:	e8 4a 09 00 00       	call   f0103962 <cprintf>
			return -E_FAULT;
f0103018:	83 c4 10             	add    $0x10,%esp
f010301b:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103020:	eb 14                	jmp    f0103036 <user_mem_check+0xe0>
	// LAB 3: Your code here.

	pte_t* pte;

	// for every page in this region
	for (void* i=ROUNDDOWN((void *)va, PGSIZE); i<ROUNDUP((void *)(va+len), PGSIZE); i+=PGSIZE) {
f0103022:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103028:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f010302b:	0f 82 59 ff ff ff    	jb     f0102f8a <user_mem_check+0x34>
			return -E_FAULT;
		}

	}

	return 0;
f0103031:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103036:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103039:	5b                   	pop    %ebx
f010303a:	5e                   	pop    %esi
f010303b:	5f                   	pop    %edi
f010303c:	5d                   	pop    %ebp
f010303d:	c3                   	ret    

f010303e <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f010303e:	55                   	push   %ebp
f010303f:	89 e5                	mov    %esp,%ebp
f0103041:	53                   	push   %ebx
f0103042:	83 ec 04             	sub    $0x4,%esp
f0103045:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0103048:	8b 45 14             	mov    0x14(%ebp),%eax
f010304b:	83 c8 04             	or     $0x4,%eax
f010304e:	50                   	push   %eax
f010304f:	ff 75 10             	pushl  0x10(%ebp)
f0103052:	ff 75 0c             	pushl  0xc(%ebp)
f0103055:	53                   	push   %ebx
f0103056:	e8 fb fe ff ff       	call   f0102f56 <user_mem_check>
f010305b:	83 c4 10             	add    $0x10,%esp
f010305e:	85 c0                	test   %eax,%eax
f0103060:	79 21                	jns    f0103083 <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0103062:	83 ec 04             	sub    $0x4,%esp
f0103065:	ff 35 3c 12 21 f0    	pushl  0xf021123c
f010306b:	ff 73 48             	pushl  0x48(%ebx)
f010306e:	68 c0 77 10 f0       	push   $0xf01077c0
f0103073:	e8 ea 08 00 00       	call   f0103962 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0103078:	89 1c 24             	mov    %ebx,(%esp)
f010307b:	e8 e1 05 00 00       	call   f0103661 <env_destroy>
f0103080:	83 c4 10             	add    $0x10,%esp
	}
}
f0103083:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103086:	c9                   	leave  
f0103087:	c3                   	ret    

f0103088 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0103088:	55                   	push   %ebp
f0103089:	89 e5                	mov    %esp,%ebp
f010308b:	57                   	push   %edi
f010308c:	56                   	push   %esi
f010308d:	53                   	push   %ebx
f010308e:	83 ec 0c             	sub    $0xc,%esp
f0103091:	89 c7                	mov    %eax,%edi
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)

	for (void* i=ROUNDDOWN(va, PGSIZE); i<ROUNDUP(va+len, PGSIZE); i += PGSIZE) {
f0103093:	89 d3                	mov    %edx,%ebx
f0103095:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f010309b:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f01030a2:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
f01030a8:	eb 56                	jmp    f0103100 <region_alloc+0x78>

		struct PageInfo* pp = page_alloc(ALLOC_ZERO);
f01030aa:	83 ec 0c             	sub    $0xc,%esp
f01030ad:	6a 01                	push   $0x1
f01030af:	e8 d3 df ff ff       	call   f0101087 <page_alloc>
		if (pp == 0) {
f01030b4:	83 c4 10             	add    $0x10,%esp
f01030b7:	85 c0                	test   %eax,%eax
f01030b9:	75 17                	jne    f01030d2 <region_alloc+0x4a>
			panic("region_alloc: page_alloc return 0");
f01030bb:	83 ec 04             	sub    $0x4,%esp
f01030be:	68 f8 77 10 f0       	push   $0xf01077f8
f01030c3:	68 2d 01 00 00       	push   $0x12d
f01030c8:	68 bc 78 10 f0       	push   $0xf01078bc
f01030cd:	e8 6e cf ff ff       	call   f0100040 <_panic>
		}

		int err = page_insert(e->env_pgdir, pp, i, PTE_U | PTE_W);
f01030d2:	6a 06                	push   $0x6
f01030d4:	53                   	push   %ebx
f01030d5:	50                   	push   %eax
f01030d6:	ff 77 60             	pushl  0x60(%edi)
f01030d9:	e8 9c e3 ff ff       	call   f010147a <page_insert>
		if (err < 0) {
f01030de:	83 c4 10             	add    $0x10,%esp
f01030e1:	85 c0                	test   %eax,%eax
f01030e3:	79 15                	jns    f01030fa <region_alloc+0x72>
			panic("region_alloc: page_insert failed: %e", err);
f01030e5:	50                   	push   %eax
f01030e6:	68 1c 78 10 f0       	push   $0xf010781c
f01030eb:	68 32 01 00 00       	push   $0x132
f01030f0:	68 bc 78 10 f0       	push   $0xf01078bc
f01030f5:	e8 46 cf ff ff       	call   f0100040 <_panic>
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)

	for (void* i=ROUNDDOWN(va, PGSIZE); i<ROUNDUP(va+len, PGSIZE); i += PGSIZE) {
f01030fa:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103100:	39 f3                	cmp    %esi,%ebx
f0103102:	72 a6                	jb     f01030aa <region_alloc+0x22>
		}

	}

	
}
f0103104:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103107:	5b                   	pop    %ebx
f0103108:	5e                   	pop    %esi
f0103109:	5f                   	pop    %edi
f010310a:	5d                   	pop    %ebp
f010310b:	c3                   	ret    

f010310c <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f010310c:	55                   	push   %ebp
f010310d:	89 e5                	mov    %esp,%ebp
f010310f:	56                   	push   %esi
f0103110:	53                   	push   %ebx
f0103111:	8b 45 08             	mov    0x8(%ebp),%eax
f0103114:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103117:	85 c0                	test   %eax,%eax
f0103119:	75 1a                	jne    f0103135 <envid2env+0x29>
		*env_store = curenv;
f010311b:	e8 3a 2c 00 00       	call   f0105d5a <cpunum>
f0103120:	6b c0 74             	imul   $0x74,%eax,%eax
f0103123:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0103129:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010312c:	89 01                	mov    %eax,(%ecx)
		return 0;
f010312e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103133:	eb 70                	jmp    f01031a5 <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103135:	89 c3                	mov    %eax,%ebx
f0103137:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f010313d:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0103140:	03 1d 48 12 21 f0    	add    0xf0211248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103146:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f010314a:	74 05                	je     f0103151 <envid2env+0x45>
f010314c:	3b 43 48             	cmp    0x48(%ebx),%eax
f010314f:	74 10                	je     f0103161 <envid2env+0x55>
		*env_store = 0;
f0103151:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103154:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010315a:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010315f:	eb 44                	jmp    f01031a5 <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103161:	84 d2                	test   %dl,%dl
f0103163:	74 36                	je     f010319b <envid2env+0x8f>
f0103165:	e8 f0 2b 00 00       	call   f0105d5a <cpunum>
f010316a:	6b c0 74             	imul   $0x74,%eax,%eax
f010316d:	3b 98 28 20 21 f0    	cmp    -0xfdedfd8(%eax),%ebx
f0103173:	74 26                	je     f010319b <envid2env+0x8f>
f0103175:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0103178:	e8 dd 2b 00 00       	call   f0105d5a <cpunum>
f010317d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103180:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0103186:	3b 70 48             	cmp    0x48(%eax),%esi
f0103189:	74 10                	je     f010319b <envid2env+0x8f>
		*env_store = 0;
f010318b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010318e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103194:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103199:	eb 0a                	jmp    f01031a5 <envid2env+0x99>
	}

	*env_store = e;
f010319b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010319e:	89 18                	mov    %ebx,(%eax)
	return 0;
f01031a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01031a5:	5b                   	pop    %ebx
f01031a6:	5e                   	pop    %esi
f01031a7:	5d                   	pop    %ebp
f01031a8:	c3                   	ret    

f01031a9 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f01031a9:	55                   	push   %ebp
f01031aa:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f01031ac:	b8 20 03 12 f0       	mov    $0xf0120320,%eax
f01031b1:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f01031b4:	b8 23 00 00 00       	mov    $0x23,%eax
f01031b9:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f01031bb:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f01031bd:	b8 10 00 00 00       	mov    $0x10,%eax
f01031c2:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f01031c4:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f01031c6:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f01031c8:	ea cf 31 10 f0 08 00 	ljmp   $0x8,$0xf01031cf
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f01031cf:	b8 00 00 00 00       	mov    $0x0,%eax
f01031d4:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f01031d7:	5d                   	pop    %ebp
f01031d8:	c3                   	ret    

f01031d9 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f01031d9:	55                   	push   %ebp
f01031da:	89 e5                	mov    %esp,%ebp
f01031dc:	56                   	push   %esi
f01031dd:	53                   	push   %ebx
	// LAB 3: Your code here.

	// make sure env_free_list point to envs[0]
	// so that the first env_alloc() will return envs[0]
	for (int i=NENV-1; i>=0; i--) {
		envs[i].env_id = 0;
f01031de:	8b 35 48 12 21 f0    	mov    0xf0211248,%esi
f01031e4:	8b 15 4c 12 21 f0    	mov    0xf021124c,%edx
f01031ea:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f01031f0:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f01031f3:	89 c1                	mov    %eax,%ecx
f01031f5:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f01031fc:	89 50 44             	mov    %edx,0x44(%eax)
f01031ff:	83 e8 7c             	sub    $0x7c,%eax
		env_free_list = &envs[i];
f0103202:	89 ca                	mov    %ecx,%edx
	// Set up envs array
	// LAB 3: Your code here.

	// make sure env_free_list point to envs[0]
	// so that the first env_alloc() will return envs[0]
	for (int i=NENV-1; i>=0; i--) {
f0103204:	39 d8                	cmp    %ebx,%eax
f0103206:	75 eb                	jne    f01031f3 <env_init+0x1a>
f0103208:	89 35 4c 12 21 f0    	mov    %esi,0xf021124c
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
	}

	// Per-CPU part of the initialization
	env_init_percpu();
f010320e:	e8 96 ff ff ff       	call   f01031a9 <env_init_percpu>
}
f0103213:	5b                   	pop    %ebx
f0103214:	5e                   	pop    %esi
f0103215:	5d                   	pop    %ebp
f0103216:	c3                   	ret    

f0103217 <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103217:	55                   	push   %ebp
f0103218:	89 e5                	mov    %esp,%ebp
f010321a:	56                   	push   %esi
f010321b:	53                   	push   %ebx
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f010321c:	8b 1d 4c 12 21 f0    	mov    0xf021124c,%ebx
f0103222:	85 db                	test   %ebx,%ebx
f0103224:	0f 84 2f 01 00 00    	je     f0103359 <env_alloc+0x142>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f010322a:	83 ec 0c             	sub    $0xc,%esp
f010322d:	6a 01                	push   $0x1
f010322f:	e8 53 de ff ff       	call   f0101087 <page_alloc>
f0103234:	89 c6                	mov    %eax,%esi
f0103236:	83 c4 10             	add    $0x10,%esp
f0103239:	85 c0                	test   %eax,%eax
f010323b:	0f 84 1f 01 00 00    	je     f0103360 <env_alloc+0x149>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103241:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0103247:	c1 f8 03             	sar    $0x3,%eax
f010324a:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010324d:	89 c2                	mov    %eax,%edx
f010324f:	c1 ea 0c             	shr    $0xc,%edx
f0103252:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f0103258:	72 12                	jb     f010326c <env_alloc+0x55>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010325a:	50                   	push   %eax
f010325b:	68 24 64 10 f0       	push   $0xf0106424
f0103260:	6a 58                	push   $0x58
f0103262:	68 eb 69 10 f0       	push   $0xf01069eb
f0103267:	e8 d4 cd ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010326c:	2d 00 00 00 10       	sub    $0x10000000,%eax
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.

	e->env_pgdir = page2kva(p);
f0103271:	89 43 60             	mov    %eax,0x60(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0103274:	83 ec 04             	sub    $0x4,%esp
f0103277:	68 00 10 00 00       	push   $0x1000
f010327c:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0103282:	50                   	push   %eax
f0103283:	e8 64 25 00 00       	call   f01057ec <memcpy>
	p->pp_ref++;
f0103288:	66 83 46 04 01       	addw   $0x1,0x4(%esi)

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f010328d:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103290:	83 c4 10             	add    $0x10,%esp
f0103293:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103298:	77 15                	ja     f01032af <env_alloc+0x98>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010329a:	50                   	push   %eax
f010329b:	68 48 64 10 f0       	push   $0xf0106448
f01032a0:	68 c8 00 00 00       	push   $0xc8
f01032a5:	68 bc 78 10 f0       	push   $0xf01078bc
f01032aa:	e8 91 cd ff ff       	call   f0100040 <_panic>
f01032af:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01032b5:	83 ca 05             	or     $0x5,%edx
f01032b8:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01032be:	8b 43 48             	mov    0x48(%ebx),%eax
f01032c1:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01032c6:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f01032cb:	ba 00 10 00 00       	mov    $0x1000,%edx
f01032d0:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f01032d3:	89 da                	mov    %ebx,%edx
f01032d5:	2b 15 48 12 21 f0    	sub    0xf0211248,%edx
f01032db:	c1 fa 02             	sar    $0x2,%edx
f01032de:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f01032e4:	09 d0                	or     %edx,%eax
f01032e6:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f01032e9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01032ec:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f01032ef:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01032f6:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f01032fd:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103304:	83 ec 04             	sub    $0x4,%esp
f0103307:	6a 44                	push   $0x44
f0103309:	6a 00                	push   $0x0
f010330b:	53                   	push   %ebx
f010330c:	e8 26 24 00 00       	call   f0105737 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103311:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103317:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f010331d:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103323:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f010332a:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.

	e->env_tf.tf_eflags |= FL_IF;
f0103330:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103337:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f010333e:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0103342:	8b 43 44             	mov    0x44(%ebx),%eax
f0103345:	a3 4c 12 21 f0       	mov    %eax,0xf021124c
	*newenv_store = e;
f010334a:	8b 45 08             	mov    0x8(%ebp),%eax
f010334d:	89 18                	mov    %ebx,(%eax)

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
f010334f:	83 c4 10             	add    $0x10,%esp
f0103352:	b8 00 00 00 00       	mov    $0x0,%eax
f0103357:	eb 0c                	jmp    f0103365 <env_alloc+0x14e>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103359:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f010335e:	eb 05                	jmp    f0103365 <env_alloc+0x14e>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103360:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103365:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103368:	5b                   	pop    %ebx
f0103369:	5e                   	pop    %esi
f010336a:	5d                   	pop    %ebp
f010336b:	c3                   	ret    

f010336c <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f010336c:	55                   	push   %ebp
f010336d:	89 e5                	mov    %esp,%ebp
f010336f:	57                   	push   %edi
f0103370:	56                   	push   %esi
f0103371:	53                   	push   %ebx
f0103372:	83 ec 34             	sub    $0x34,%esp
f0103375:	8b 7d 08             	mov    0x8(%ebp),%edi
	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.

	struct Env *newenv_store;
	envid_t parent_id = 0;
	int err = env_alloc(&newenv_store, 0);
f0103378:	6a 00                	push   $0x0
f010337a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010337d:	50                   	push   %eax
f010337e:	e8 94 fe ff ff       	call   f0103217 <env_alloc>
	if (err < 0) 
f0103383:	83 c4 10             	add    $0x10,%esp
f0103386:	85 c0                	test   %eax,%eax
f0103388:	79 15                	jns    f010339f <env_create+0x33>
		panic("env_create: env_alloc failed: %e", err);
f010338a:	50                   	push   %eax
f010338b:	68 44 78 10 f0       	push   $0xf0107844
f0103390:	68 bc 01 00 00       	push   $0x1bc
f0103395:	68 bc 78 10 f0       	push   $0xf01078bc
f010339a:	e8 a1 cc ff ff       	call   f0100040 <_panic>
	load_icode(newenv_store, binary);
f010339f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01033a2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// LAB 3: Your code here.

	// read and check ELF property, inspired by boot/main.c
	struct Elf* elf = (struct Elf*) binary;

	if (elf->e_magic != ELF_MAGIC)
f01033a5:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f01033ab:	74 17                	je     f01033c4 <env_create+0x58>
		panic("load_icode: not a valid ELF format file");
f01033ad:	83 ec 04             	sub    $0x4,%esp
f01033b0:	68 68 78 10 f0       	push   $0xf0107868
f01033b5:	68 75 01 00 00       	push   $0x175
f01033ba:	68 bc 78 10 f0       	push   $0xf01078bc
f01033bf:	e8 7c cc ff ff       	call   f0100040 <_panic>

	struct Proghdr *ph, *eph;
	
	ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f01033c4:	89 fb                	mov    %edi,%ebx
f01033c6:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + elf->e_phnum;
f01033c9:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f01033cd:	c1 e6 05             	shl    $0x5,%esi
f01033d0:	01 de                	add    %ebx,%esi

	// we are setting user virtual address, but now we are in kernel mode
	// load env pgdir to cr3
	lcr3(PADDR(e->env_pgdir));	
f01033d2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01033d5:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01033d8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01033dd:	77 15                	ja     f01033f4 <env_create+0x88>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033df:	50                   	push   %eax
f01033e0:	68 48 64 10 f0       	push   $0xf0106448
f01033e5:	68 7e 01 00 00       	push   $0x17e
f01033ea:	68 bc 78 10 f0       	push   $0xf01078bc
f01033ef:	e8 4c cc ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01033f4:	05 00 00 00 10       	add    $0x10000000,%eax
f01033f9:	0f 22 d8             	mov    %eax,%cr3
f01033fc:	eb 59                	jmp    f0103457 <env_create+0xeb>

	// for every segment
	for (; ph < eph; ph++) {

		// only load this type of segment
		if (ph->p_type == ELF_PROG_LOAD) {
f01033fe:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103401:	75 51                	jne    f0103454 <env_create+0xe8>

			if (ph->p_filesz > ph->p_memsz)
f0103403:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103406:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f0103409:	76 17                	jbe    f0103422 <env_create+0xb6>
				panic("load_icode: not a valid ELF format file (2)");
f010340b:	83 ec 04             	sub    $0x4,%esp
f010340e:	68 90 78 10 f0       	push   $0xf0107890
f0103413:	68 87 01 00 00       	push   $0x187
f0103418:	68 bc 78 10 f0       	push   $0xf01078bc
f010341d:	e8 1e cc ff ff       	call   f0100040 <_panic>

			// allocate and map each segment
			// this function needs e->env_pgdir
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0103422:	8b 53 08             	mov    0x8(%ebx),%edx
f0103425:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103428:	e8 5b fc ff ff       	call   f0103088 <region_alloc>

			// all clear to 0
			memset((void *)ph->p_va, 0, ph->p_memsz);
f010342d:	83 ec 04             	sub    $0x4,%esp
f0103430:	ff 73 14             	pushl  0x14(%ebx)
f0103433:	6a 00                	push   $0x0
f0103435:	ff 73 08             	pushl  0x8(%ebx)
f0103438:	e8 fa 22 00 00       	call   f0105737 <memset>

			// copy [binary + ph->p_offset, binary + ph->p_offset + ph->p_filesz) to ph->p_va
			// binary is of type uint8_t *, remember not use elf cuz its type is struct Elf*
			// making elf + ph->p_offset pointing to nowhere
			memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f010343d:	83 c4 0c             	add    $0xc,%esp
f0103440:	ff 73 10             	pushl  0x10(%ebx)
f0103443:	89 f8                	mov    %edi,%eax
f0103445:	03 43 04             	add    0x4(%ebx),%eax
f0103448:	50                   	push   %eax
f0103449:	ff 73 08             	pushl  0x8(%ebx)
f010344c:	e8 9b 23 00 00       	call   f01057ec <memcpy>
f0103451:	83 c4 10             	add    $0x10,%esp
	// we are setting user virtual address, but now we are in kernel mode
	// load env pgdir to cr3
	lcr3(PADDR(e->env_pgdir));	

	// for every segment
	for (; ph < eph; ph++) {
f0103454:	83 c3 20             	add    $0x20,%ebx
f0103457:	39 de                	cmp    %ebx,%esi
f0103459:	77 a3                	ja     f01033fe <env_create+0x92>
		}

	}

	// load program entry point to eip
	e->env_tf.tf_eip = elf->e_entry;
f010345b:	8b 47 18             	mov    0x18(%edi),%eax
f010345e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103461:	89 47 30             	mov    %eax,0x30(%edi)
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.

	region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f0103464:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103469:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f010346e:	89 f8                	mov    %edi,%eax
f0103470:	e8 13 fc ff ff       	call   f0103088 <region_alloc>

	// after loading things from elf, restore cr3 in kernel
	lcr3(PADDR(kern_pgdir));
f0103475:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010347a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010347f:	77 15                	ja     f0103496 <env_create+0x12a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103481:	50                   	push   %eax
f0103482:	68 48 64 10 f0       	push   $0xf0106448
f0103487:	68 a5 01 00 00       	push   $0x1a5
f010348c:	68 bc 78 10 f0       	push   $0xf01078bc
f0103491:	e8 aa cb ff ff       	call   f0100040 <_panic>
f0103496:	05 00 00 00 10       	add    $0x10000000,%eax
f010349b:	0f 22 d8             	mov    %eax,%cr3
	envid_t parent_id = 0;
	int err = env_alloc(&newenv_store, 0);
	if (err < 0) 
		panic("env_create: env_alloc failed: %e", err);
	load_icode(newenv_store, binary);
	newenv_store->env_type = type;
f010349e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01034a1:	8b 55 0c             	mov    0xc(%ebp),%edx
f01034a4:	89 50 50             	mov    %edx,0x50(%eax)

	if (type == ENV_TYPE_FS) {
f01034a7:	83 fa 01             	cmp    $0x1,%edx
f01034aa:	75 07                	jne    f01034b3 <env_create+0x147>
        newenv_store->env_tf.tf_eflags |= FL_IOPL_MASK;
f01034ac:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
    }

}
f01034b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01034b6:	5b                   	pop    %ebx
f01034b7:	5e                   	pop    %esi
f01034b8:	5f                   	pop    %edi
f01034b9:	5d                   	pop    %ebp
f01034ba:	c3                   	ret    

f01034bb <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01034bb:	55                   	push   %ebp
f01034bc:	89 e5                	mov    %esp,%ebp
f01034be:	57                   	push   %edi
f01034bf:	56                   	push   %esi
f01034c0:	53                   	push   %ebx
f01034c1:	83 ec 1c             	sub    $0x1c,%esp
f01034c4:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01034c7:	e8 8e 28 00 00       	call   f0105d5a <cpunum>
f01034cc:	6b c0 74             	imul   $0x74,%eax,%eax
f01034cf:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01034d6:	39 b8 28 20 21 f0    	cmp    %edi,-0xfdedfd8(%eax)
f01034dc:	75 30                	jne    f010350e <env_free+0x53>
		lcr3(PADDR(kern_pgdir));
f01034de:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01034e3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01034e8:	77 15                	ja     f01034ff <env_free+0x44>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01034ea:	50                   	push   %eax
f01034eb:	68 48 64 10 f0       	push   $0xf0106448
f01034f0:	68 d4 01 00 00       	push   $0x1d4
f01034f5:	68 bc 78 10 f0       	push   $0xf01078bc
f01034fa:	e8 41 cb ff ff       	call   f0100040 <_panic>
f01034ff:	05 00 00 00 10       	add    $0x10000000,%eax
f0103504:	0f 22 d8             	mov    %eax,%cr3
f0103507:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f010350e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103511:	89 d0                	mov    %edx,%eax
f0103513:	c1 e0 02             	shl    $0x2,%eax
f0103516:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103519:	8b 47 60             	mov    0x60(%edi),%eax
f010351c:	8b 34 90             	mov    (%eax,%edx,4),%esi
f010351f:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103525:	0f 84 a8 00 00 00    	je     f01035d3 <env_free+0x118>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f010352b:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103531:	89 f0                	mov    %esi,%eax
f0103533:	c1 e8 0c             	shr    $0xc,%eax
f0103536:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103539:	39 05 88 1e 21 f0    	cmp    %eax,0xf0211e88
f010353f:	77 15                	ja     f0103556 <env_free+0x9b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103541:	56                   	push   %esi
f0103542:	68 24 64 10 f0       	push   $0xf0106424
f0103547:	68 e3 01 00 00       	push   $0x1e3
f010354c:	68 bc 78 10 f0       	push   $0xf01078bc
f0103551:	e8 ea ca ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103556:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103559:	c1 e0 16             	shl    $0x16,%eax
f010355c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010355f:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103564:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f010356b:	01 
f010356c:	74 17                	je     f0103585 <env_free+0xca>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010356e:	83 ec 08             	sub    $0x8,%esp
f0103571:	89 d8                	mov    %ebx,%eax
f0103573:	c1 e0 0c             	shl    $0xc,%eax
f0103576:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103579:	50                   	push   %eax
f010357a:	ff 77 60             	pushl  0x60(%edi)
f010357d:	e8 ab de ff ff       	call   f010142d <page_remove>
f0103582:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103585:	83 c3 01             	add    $0x1,%ebx
f0103588:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f010358e:	75 d4                	jne    f0103564 <env_free+0xa9>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103590:	8b 47 60             	mov    0x60(%edi),%eax
f0103593:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103596:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010359d:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01035a0:	3b 05 88 1e 21 f0    	cmp    0xf0211e88,%eax
f01035a6:	72 14                	jb     f01035bc <env_free+0x101>
		panic("pa2page called with invalid pa");
f01035a8:	83 ec 04             	sub    $0x4,%esp
f01035ab:	68 54 6f 10 f0       	push   $0xf0106f54
f01035b0:	6a 51                	push   $0x51
f01035b2:	68 eb 69 10 f0       	push   $0xf01069eb
f01035b7:	e8 84 ca ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f01035bc:	83 ec 0c             	sub    $0xc,%esp
f01035bf:	a1 90 1e 21 f0       	mov    0xf0211e90,%eax
f01035c4:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01035c7:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f01035ca:	50                   	push   %eax
f01035cb:	e8 7e db ff ff       	call   f010114e <page_decref>
f01035d0:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01035d3:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f01035d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01035da:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f01035df:	0f 85 29 ff ff ff    	jne    f010350e <env_free+0x53>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01035e5:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01035e8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01035ed:	77 15                	ja     f0103604 <env_free+0x149>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01035ef:	50                   	push   %eax
f01035f0:	68 48 64 10 f0       	push   $0xf0106448
f01035f5:	68 f1 01 00 00       	push   $0x1f1
f01035fa:	68 bc 78 10 f0       	push   $0xf01078bc
f01035ff:	e8 3c ca ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103604:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010360b:	05 00 00 00 10       	add    $0x10000000,%eax
f0103610:	c1 e8 0c             	shr    $0xc,%eax
f0103613:	3b 05 88 1e 21 f0    	cmp    0xf0211e88,%eax
f0103619:	72 14                	jb     f010362f <env_free+0x174>
		panic("pa2page called with invalid pa");
f010361b:	83 ec 04             	sub    $0x4,%esp
f010361e:	68 54 6f 10 f0       	push   $0xf0106f54
f0103623:	6a 51                	push   $0x51
f0103625:	68 eb 69 10 f0       	push   $0xf01069eb
f010362a:	e8 11 ca ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f010362f:	83 ec 0c             	sub    $0xc,%esp
f0103632:	8b 15 90 1e 21 f0    	mov    0xf0211e90,%edx
f0103638:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f010363b:	50                   	push   %eax
f010363c:	e8 0d db ff ff       	call   f010114e <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103641:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103648:	a1 4c 12 21 f0       	mov    0xf021124c,%eax
f010364d:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103650:	89 3d 4c 12 21 f0    	mov    %edi,0xf021124c
}
f0103656:	83 c4 10             	add    $0x10,%esp
f0103659:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010365c:	5b                   	pop    %ebx
f010365d:	5e                   	pop    %esi
f010365e:	5f                   	pop    %edi
f010365f:	5d                   	pop    %ebp
f0103660:	c3                   	ret    

f0103661 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103661:	55                   	push   %ebp
f0103662:	89 e5                	mov    %esp,%ebp
f0103664:	53                   	push   %ebx
f0103665:	83 ec 04             	sub    $0x4,%esp
f0103668:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f010366b:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f010366f:	75 19                	jne    f010368a <env_destroy+0x29>
f0103671:	e8 e4 26 00 00       	call   f0105d5a <cpunum>
f0103676:	6b c0 74             	imul   $0x74,%eax,%eax
f0103679:	3b 98 28 20 21 f0    	cmp    -0xfdedfd8(%eax),%ebx
f010367f:	74 09                	je     f010368a <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0103681:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103688:	eb 33                	jmp    f01036bd <env_destroy+0x5c>
	}

	env_free(e);
f010368a:	83 ec 0c             	sub    $0xc,%esp
f010368d:	53                   	push   %ebx
f010368e:	e8 28 fe ff ff       	call   f01034bb <env_free>

	if (curenv == e) {
f0103693:	e8 c2 26 00 00       	call   f0105d5a <cpunum>
f0103698:	6b c0 74             	imul   $0x74,%eax,%eax
f010369b:	83 c4 10             	add    $0x10,%esp
f010369e:	3b 98 28 20 21 f0    	cmp    -0xfdedfd8(%eax),%ebx
f01036a4:	75 17                	jne    f01036bd <env_destroy+0x5c>
		curenv = NULL;
f01036a6:	e8 af 26 00 00       	call   f0105d5a <cpunum>
f01036ab:	6b c0 74             	imul   $0x74,%eax,%eax
f01036ae:	c7 80 28 20 21 f0 00 	movl   $0x0,-0xfdedfd8(%eax)
f01036b5:	00 00 00 
		sched_yield();
f01036b8:	e8 e7 0e 00 00       	call   f01045a4 <sched_yield>
	}
}
f01036bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01036c0:	c9                   	leave  
f01036c1:	c3                   	ret    

f01036c2 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01036c2:	55                   	push   %ebp
f01036c3:	89 e5                	mov    %esp,%ebp
f01036c5:	53                   	push   %ebx
f01036c6:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f01036c9:	e8 8c 26 00 00       	call   f0105d5a <cpunum>
f01036ce:	6b c0 74             	imul   $0x74,%eax,%eax
f01036d1:	8b 98 28 20 21 f0    	mov    -0xfdedfd8(%eax),%ebx
f01036d7:	e8 7e 26 00 00       	call   f0105d5a <cpunum>
f01036dc:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f01036df:	8b 65 08             	mov    0x8(%ebp),%esp
f01036e2:	61                   	popa   
f01036e3:	07                   	pop    %es
f01036e4:	1f                   	pop    %ds
f01036e5:	83 c4 08             	add    $0x8,%esp
f01036e8:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01036e9:	83 ec 04             	sub    $0x4,%esp
f01036ec:	68 c7 78 10 f0       	push   $0xf01078c7
f01036f1:	68 28 02 00 00       	push   $0x228
f01036f6:	68 bc 78 10 f0       	push   $0xf01078bc
f01036fb:	e8 40 c9 ff ff       	call   f0100040 <_panic>

f0103700 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103700:	55                   	push   %ebp
f0103701:	89 e5                	mov    %esp,%ebp
f0103703:	53                   	push   %ebx
f0103704:	83 ec 04             	sub    $0x4,%esp
f0103707:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

	// context switch
	if (curenv != e) {
f010370a:	e8 4b 26 00 00       	call   f0105d5a <cpunum>
f010370f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103712:	39 98 28 20 21 f0    	cmp    %ebx,-0xfdedfd8(%eax)
f0103718:	74 3a                	je     f0103754 <env_run+0x54>

		if (curenv != NULL && curenv->env_status == ENV_RUNNING)
f010371a:	e8 3b 26 00 00       	call   f0105d5a <cpunum>
f010371f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103722:	83 b8 28 20 21 f0 00 	cmpl   $0x0,-0xfdedfd8(%eax)
f0103729:	74 29                	je     f0103754 <env_run+0x54>
f010372b:	e8 2a 26 00 00       	call   f0105d5a <cpunum>
f0103730:	6b c0 74             	imul   $0x74,%eax,%eax
f0103733:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0103739:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010373d:	75 15                	jne    f0103754 <env_run+0x54>
			curenv->env_status = ENV_RUNNABLE;
f010373f:	e8 16 26 00 00       	call   f0105d5a <cpunum>
f0103744:	6b c0 74             	imul   $0x74,%eax,%eax
f0103747:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f010374d:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
			
	}
	
	curenv = e;
f0103754:	e8 01 26 00 00       	call   f0105d5a <cpunum>
f0103759:	6b c0 74             	imul   $0x74,%eax,%eax
f010375c:	89 98 28 20 21 f0    	mov    %ebx,-0xfdedfd8(%eax)
	curenv->env_status = ENV_RUNNING;
f0103762:	e8 f3 25 00 00       	call   f0105d5a <cpunum>
f0103767:	6b c0 74             	imul   $0x74,%eax,%eax
f010376a:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0103770:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f0103777:	e8 de 25 00 00       	call   f0105d5a <cpunum>
f010377c:	6b c0 74             	imul   $0x74,%eax,%eax
f010377f:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0103785:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3(PADDR(curenv->env_pgdir));
f0103789:	e8 cc 25 00 00       	call   f0105d5a <cpunum>
f010378e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103791:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0103797:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010379a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010379f:	77 15                	ja     f01037b6 <env_run+0xb6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01037a1:	50                   	push   %eax
f01037a2:	68 48 64 10 f0       	push   $0xf0106448
f01037a7:	68 52 02 00 00       	push   $0x252
f01037ac:	68 bc 78 10 f0       	push   $0xf01078bc
f01037b1:	e8 8a c8 ff ff       	call   f0100040 <_panic>
f01037b6:	05 00 00 00 10       	add    $0x10000000,%eax
f01037bb:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01037be:	83 ec 0c             	sub    $0xc,%esp
f01037c1:	68 c0 03 12 f0       	push   $0xf01203c0
f01037c6:	e8 9a 28 00 00       	call   f0106065 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01037cb:	f3 90                	pause  

	unlock_kernel();

	// iret to execute entry point stored in tf_eip
	// cprintf("[?] try to execute at entry point: %x\n", curenv->env_tf.tf_eip);
	env_pop_tf(&curenv->env_tf);
f01037cd:	e8 88 25 00 00       	call   f0105d5a <cpunum>
f01037d2:	83 c4 04             	add    $0x4,%esp
f01037d5:	6b c0 74             	imul   $0x74,%eax,%eax
f01037d8:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f01037de:	e8 df fe ff ff       	call   f01036c2 <env_pop_tf>

f01037e3 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01037e3:	55                   	push   %ebp
f01037e4:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01037e6:	ba 70 00 00 00       	mov    $0x70,%edx
f01037eb:	8b 45 08             	mov    0x8(%ebp),%eax
f01037ee:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01037ef:	ba 71 00 00 00       	mov    $0x71,%edx
f01037f4:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01037f5:	0f b6 c0             	movzbl %al,%eax
}
f01037f8:	5d                   	pop    %ebp
f01037f9:	c3                   	ret    

f01037fa <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01037fa:	55                   	push   %ebp
f01037fb:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01037fd:	ba 70 00 00 00       	mov    $0x70,%edx
f0103802:	8b 45 08             	mov    0x8(%ebp),%eax
f0103805:	ee                   	out    %al,(%dx)
f0103806:	ba 71 00 00 00       	mov    $0x71,%edx
f010380b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010380e:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010380f:	5d                   	pop    %ebp
f0103810:	c3                   	ret    

f0103811 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103811:	55                   	push   %ebp
f0103812:	89 e5                	mov    %esp,%ebp
f0103814:	56                   	push   %esi
f0103815:	53                   	push   %ebx
f0103816:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103819:	66 a3 a8 03 12 f0    	mov    %ax,0xf01203a8
	if (!didinit)
f010381f:	80 3d 50 12 21 f0 00 	cmpb   $0x0,0xf0211250
f0103826:	74 5a                	je     f0103882 <irq_setmask_8259A+0x71>
f0103828:	89 c6                	mov    %eax,%esi
f010382a:	ba 21 00 00 00       	mov    $0x21,%edx
f010382f:	ee                   	out    %al,(%dx)
f0103830:	66 c1 e8 08          	shr    $0x8,%ax
f0103834:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103839:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f010383a:	83 ec 0c             	sub    $0xc,%esp
f010383d:	68 d3 78 10 f0       	push   $0xf01078d3
f0103842:	e8 1b 01 00 00       	call   f0103962 <cprintf>
f0103847:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f010384a:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f010384f:	0f b7 f6             	movzwl %si,%esi
f0103852:	f7 d6                	not    %esi
f0103854:	0f a3 de             	bt     %ebx,%esi
f0103857:	73 11                	jae    f010386a <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f0103859:	83 ec 08             	sub    $0x8,%esp
f010385c:	53                   	push   %ebx
f010385d:	68 8b 7d 10 f0       	push   $0xf0107d8b
f0103862:	e8 fb 00 00 00       	call   f0103962 <cprintf>
f0103867:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f010386a:	83 c3 01             	add    $0x1,%ebx
f010386d:	83 fb 10             	cmp    $0x10,%ebx
f0103870:	75 e2                	jne    f0103854 <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103872:	83 ec 0c             	sub    $0xc,%esp
f0103875:	68 19 6d 10 f0       	push   $0xf0106d19
f010387a:	e8 e3 00 00 00       	call   f0103962 <cprintf>
f010387f:	83 c4 10             	add    $0x10,%esp
}
f0103882:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103885:	5b                   	pop    %ebx
f0103886:	5e                   	pop    %esi
f0103887:	5d                   	pop    %ebp
f0103888:	c3                   	ret    

f0103889 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f0103889:	c6 05 50 12 21 f0 01 	movb   $0x1,0xf0211250
f0103890:	ba 21 00 00 00       	mov    $0x21,%edx
f0103895:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010389a:	ee                   	out    %al,(%dx)
f010389b:	ba a1 00 00 00       	mov    $0xa1,%edx
f01038a0:	ee                   	out    %al,(%dx)
f01038a1:	ba 20 00 00 00       	mov    $0x20,%edx
f01038a6:	b8 11 00 00 00       	mov    $0x11,%eax
f01038ab:	ee                   	out    %al,(%dx)
f01038ac:	ba 21 00 00 00       	mov    $0x21,%edx
f01038b1:	b8 20 00 00 00       	mov    $0x20,%eax
f01038b6:	ee                   	out    %al,(%dx)
f01038b7:	b8 04 00 00 00       	mov    $0x4,%eax
f01038bc:	ee                   	out    %al,(%dx)
f01038bd:	b8 03 00 00 00       	mov    $0x3,%eax
f01038c2:	ee                   	out    %al,(%dx)
f01038c3:	ba a0 00 00 00       	mov    $0xa0,%edx
f01038c8:	b8 11 00 00 00       	mov    $0x11,%eax
f01038cd:	ee                   	out    %al,(%dx)
f01038ce:	ba a1 00 00 00       	mov    $0xa1,%edx
f01038d3:	b8 28 00 00 00       	mov    $0x28,%eax
f01038d8:	ee                   	out    %al,(%dx)
f01038d9:	b8 02 00 00 00       	mov    $0x2,%eax
f01038de:	ee                   	out    %al,(%dx)
f01038df:	b8 01 00 00 00       	mov    $0x1,%eax
f01038e4:	ee                   	out    %al,(%dx)
f01038e5:	ba 20 00 00 00       	mov    $0x20,%edx
f01038ea:	b8 68 00 00 00       	mov    $0x68,%eax
f01038ef:	ee                   	out    %al,(%dx)
f01038f0:	b8 0a 00 00 00       	mov    $0xa,%eax
f01038f5:	ee                   	out    %al,(%dx)
f01038f6:	ba a0 00 00 00       	mov    $0xa0,%edx
f01038fb:	b8 68 00 00 00       	mov    $0x68,%eax
f0103900:	ee                   	out    %al,(%dx)
f0103901:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103906:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103907:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f010390e:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103912:	74 13                	je     f0103927 <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103914:	55                   	push   %ebp
f0103915:	89 e5                	mov    %esp,%ebp
f0103917:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f010391a:	0f b7 c0             	movzwl %ax,%eax
f010391d:	50                   	push   %eax
f010391e:	e8 ee fe ff ff       	call   f0103811 <irq_setmask_8259A>
f0103923:	83 c4 10             	add    $0x10,%esp
}
f0103926:	c9                   	leave  
f0103927:	f3 c3                	repz ret 

f0103929 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103929:	55                   	push   %ebp
f010392a:	89 e5                	mov    %esp,%ebp
f010392c:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f010392f:	ff 75 08             	pushl  0x8(%ebp)
f0103932:	e8 4b ce ff ff       	call   f0100782 <cputchar>
	*cnt++;
}
f0103937:	83 c4 10             	add    $0x10,%esp
f010393a:	c9                   	leave  
f010393b:	c3                   	ret    

f010393c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010393c:	55                   	push   %ebp
f010393d:	89 e5                	mov    %esp,%ebp
f010393f:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103942:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103949:	ff 75 0c             	pushl  0xc(%ebp)
f010394c:	ff 75 08             	pushl  0x8(%ebp)
f010394f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103952:	50                   	push   %eax
f0103953:	68 29 39 10 f0       	push   $0xf0103929
f0103958:	e8 56 17 00 00       	call   f01050b3 <vprintfmt>
	return cnt;
}
f010395d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103960:	c9                   	leave  
f0103961:	c3                   	ret    

f0103962 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103962:	55                   	push   %ebp
f0103963:	89 e5                	mov    %esp,%ebp
f0103965:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103968:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f010396b:	50                   	push   %eax
f010396c:	ff 75 08             	pushl  0x8(%ebp)
f010396f:	e8 c8 ff ff ff       	call   f010393c <vcprintf>
	va_end(ap);

	return cnt;
}
f0103974:	c9                   	leave  
f0103975:	c3                   	ret    

f0103976 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103976:	55                   	push   %ebp
f0103977:	89 e5                	mov    %esp,%ebp
f0103979:	57                   	push   %edi
f010397a:	56                   	push   %esi
f010397b:	53                   	push   %ebx
f010397c:	83 ec 0c             	sub    $0xc,%esp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = (uintptr_t) percpu_kstacks[cpunum()];
f010397f:	e8 d6 23 00 00       	call   f0105d5a <cpunum>
f0103984:	89 c3                	mov    %eax,%ebx
f0103986:	e8 cf 23 00 00       	call   f0105d5a <cpunum>
f010398b:	6b db 74             	imul   $0x74,%ebx,%ebx
f010398e:	c1 e0 0f             	shl    $0xf,%eax
f0103991:	05 00 30 21 f0       	add    $0xf0213000,%eax
f0103996:	89 83 30 20 21 f0    	mov    %eax,-0xfdedfd0(%ebx)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f010399c:	e8 b9 23 00 00       	call   f0105d5a <cpunum>
f01039a1:	6b c0 74             	imul   $0x74,%eax,%eax
f01039a4:	66 c7 80 34 20 21 f0 	movw   $0x10,-0xfdedfcc(%eax)
f01039ab:	10 00 
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f01039ad:	e8 a8 23 00 00       	call   f0105d5a <cpunum>
f01039b2:	6b c0 74             	imul   $0x74,%eax,%eax
f01039b5:	66 c7 80 92 20 21 f0 	movw   $0x68,-0xfdedf6e(%eax)
f01039bc:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + cpunum()] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
f01039be:	e8 97 23 00 00       	call   f0105d5a <cpunum>
f01039c3:	8d 58 05             	lea    0x5(%eax),%ebx
f01039c6:	e8 8f 23 00 00       	call   f0105d5a <cpunum>
f01039cb:	89 c7                	mov    %eax,%edi
f01039cd:	e8 88 23 00 00       	call   f0105d5a <cpunum>
f01039d2:	89 c6                	mov    %eax,%esi
f01039d4:	e8 81 23 00 00       	call   f0105d5a <cpunum>
f01039d9:	66 c7 04 dd 40 03 12 	movw   $0x67,-0xfedfcc0(,%ebx,8)
f01039e0:	f0 67 00 
f01039e3:	6b ff 74             	imul   $0x74,%edi,%edi
f01039e6:	81 c7 2c 20 21 f0    	add    $0xf021202c,%edi
f01039ec:	66 89 3c dd 42 03 12 	mov    %di,-0xfedfcbe(,%ebx,8)
f01039f3:	f0 
f01039f4:	6b d6 74             	imul   $0x74,%esi,%edx
f01039f7:	81 c2 2c 20 21 f0    	add    $0xf021202c,%edx
f01039fd:	c1 ea 10             	shr    $0x10,%edx
f0103a00:	88 14 dd 44 03 12 f0 	mov    %dl,-0xfedfcbc(,%ebx,8)
f0103a07:	c6 04 dd 45 03 12 f0 	movb   $0x99,-0xfedfcbb(,%ebx,8)
f0103a0e:	99 
f0103a0f:	c6 04 dd 46 03 12 f0 	movb   $0x40,-0xfedfcba(,%ebx,8)
f0103a16:	40 
f0103a17:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a1a:	05 2c 20 21 f0       	add    $0xf021202c,%eax
f0103a1f:	c1 e8 18             	shr    $0x18,%eax
f0103a22:	88 04 dd 47 03 12 f0 	mov    %al,-0xfedfcb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + cpunum()].sd_s = 0;
f0103a29:	e8 2c 23 00 00       	call   f0105d5a <cpunum>
f0103a2e:	80 24 c5 6d 03 12 f0 	andb   $0xef,-0xfedfc93(,%eax,8)
f0103a35:	ef 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + (cpunum() << 3));
f0103a36:	e8 1f 23 00 00       	call   f0105d5a <cpunum>
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f0103a3b:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
f0103a42:	0f 00 d8             	ltr    %ax
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f0103a45:	b8 ac 03 12 f0       	mov    $0xf01203ac,%eax
f0103a4a:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f0103a4d:	83 c4 0c             	add    $0xc,%esp
f0103a50:	5b                   	pop    %ebx
f0103a51:	5e                   	pop    %esi
f0103a52:	5f                   	pop    %edi
f0103a53:	5d                   	pop    %ebp
f0103a54:	c3                   	ret    

f0103a55 <trap_init>:
}


void
trap_init(void)
{
f0103a55:	55                   	push   %ebp
f0103a56:	89 e5                	mov    %esp,%ebp
f0103a58:	83 ec 08             	sub    $0x8,%esp
	void _IRQ_SPURIOUS_handler();
	void _IRQ_IDE_handler();
	void _IRQ_ERROR_handler();

	// SETGATE(gate, istrap, sel, off, dpl);
	SETGATE(idt[T_DIVIDE], 0, GD_KT, _T_DIVIDE_handler, 0);
f0103a5b:	b8 32 44 10 f0       	mov    $0xf0104432,%eax
f0103a60:	66 a3 60 12 21 f0    	mov    %ax,0xf0211260
f0103a66:	66 c7 05 62 12 21 f0 	movw   $0x8,0xf0211262
f0103a6d:	08 00 
f0103a6f:	c6 05 64 12 21 f0 00 	movb   $0x0,0xf0211264
f0103a76:	c6 05 65 12 21 f0 8e 	movb   $0x8e,0xf0211265
f0103a7d:	c1 e8 10             	shr    $0x10,%eax
f0103a80:	66 a3 66 12 21 f0    	mov    %ax,0xf0211266
	SETGATE(idt[T_DEBUG], 0, GD_KT, _T_DEBUG_handler, 0);
f0103a86:	b8 3c 44 10 f0       	mov    $0xf010443c,%eax
f0103a8b:	66 a3 68 12 21 f0    	mov    %ax,0xf0211268
f0103a91:	66 c7 05 6a 12 21 f0 	movw   $0x8,0xf021126a
f0103a98:	08 00 
f0103a9a:	c6 05 6c 12 21 f0 00 	movb   $0x0,0xf021126c
f0103aa1:	c6 05 6d 12 21 f0 8e 	movb   $0x8e,0xf021126d
f0103aa8:	c1 e8 10             	shr    $0x10,%eax
f0103aab:	66 a3 6e 12 21 f0    	mov    %ax,0xf021126e
	SETGATE(idt[T_NMI], 0, GD_KT, _T_NMI_handler, 0);
f0103ab1:	b8 42 44 10 f0       	mov    $0xf0104442,%eax
f0103ab6:	66 a3 70 12 21 f0    	mov    %ax,0xf0211270
f0103abc:	66 c7 05 72 12 21 f0 	movw   $0x8,0xf0211272
f0103ac3:	08 00 
f0103ac5:	c6 05 74 12 21 f0 00 	movb   $0x0,0xf0211274
f0103acc:	c6 05 75 12 21 f0 8e 	movb   $0x8e,0xf0211275
f0103ad3:	c1 e8 10             	shr    $0x10,%eax
f0103ad6:	66 a3 76 12 21 f0    	mov    %ax,0xf0211276
	SETGATE(idt[T_BRKPT], 0, GD_KT, _T_BRKPT_handler, 3);
f0103adc:	b8 48 44 10 f0       	mov    $0xf0104448,%eax
f0103ae1:	66 a3 78 12 21 f0    	mov    %ax,0xf0211278
f0103ae7:	66 c7 05 7a 12 21 f0 	movw   $0x8,0xf021127a
f0103aee:	08 00 
f0103af0:	c6 05 7c 12 21 f0 00 	movb   $0x0,0xf021127c
f0103af7:	c6 05 7d 12 21 f0 ee 	movb   $0xee,0xf021127d
f0103afe:	c1 e8 10             	shr    $0x10,%eax
f0103b01:	66 a3 7e 12 21 f0    	mov    %ax,0xf021127e
	SETGATE(idt[T_OFLOW], 0, GD_KT, _T_OFLOW_handler, 0);
f0103b07:	b8 4e 44 10 f0       	mov    $0xf010444e,%eax
f0103b0c:	66 a3 80 12 21 f0    	mov    %ax,0xf0211280
f0103b12:	66 c7 05 82 12 21 f0 	movw   $0x8,0xf0211282
f0103b19:	08 00 
f0103b1b:	c6 05 84 12 21 f0 00 	movb   $0x0,0xf0211284
f0103b22:	c6 05 85 12 21 f0 8e 	movb   $0x8e,0xf0211285
f0103b29:	c1 e8 10             	shr    $0x10,%eax
f0103b2c:	66 a3 86 12 21 f0    	mov    %ax,0xf0211286
	SETGATE(idt[T_BOUND], 0, GD_KT, _T_BOUND_handler, 0);
f0103b32:	b8 54 44 10 f0       	mov    $0xf0104454,%eax
f0103b37:	66 a3 88 12 21 f0    	mov    %ax,0xf0211288
f0103b3d:	66 c7 05 8a 12 21 f0 	movw   $0x8,0xf021128a
f0103b44:	08 00 
f0103b46:	c6 05 8c 12 21 f0 00 	movb   $0x0,0xf021128c
f0103b4d:	c6 05 8d 12 21 f0 8e 	movb   $0x8e,0xf021128d
f0103b54:	c1 e8 10             	shr    $0x10,%eax
f0103b57:	66 a3 8e 12 21 f0    	mov    %ax,0xf021128e
	SETGATE(idt[T_ILLOP], 0, GD_KT, _T_ILLOP_handler, 0);
f0103b5d:	b8 5a 44 10 f0       	mov    $0xf010445a,%eax
f0103b62:	66 a3 90 12 21 f0    	mov    %ax,0xf0211290
f0103b68:	66 c7 05 92 12 21 f0 	movw   $0x8,0xf0211292
f0103b6f:	08 00 
f0103b71:	c6 05 94 12 21 f0 00 	movb   $0x0,0xf0211294
f0103b78:	c6 05 95 12 21 f0 8e 	movb   $0x8e,0xf0211295
f0103b7f:	c1 e8 10             	shr    $0x10,%eax
f0103b82:	66 a3 96 12 21 f0    	mov    %ax,0xf0211296
	SETGATE(idt[T_DEVICE], 0, GD_KT, _T_DEVICE_handler, 0);
f0103b88:	b8 60 44 10 f0       	mov    $0xf0104460,%eax
f0103b8d:	66 a3 98 12 21 f0    	mov    %ax,0xf0211298
f0103b93:	66 c7 05 9a 12 21 f0 	movw   $0x8,0xf021129a
f0103b9a:	08 00 
f0103b9c:	c6 05 9c 12 21 f0 00 	movb   $0x0,0xf021129c
f0103ba3:	c6 05 9d 12 21 f0 8e 	movb   $0x8e,0xf021129d
f0103baa:	c1 e8 10             	shr    $0x10,%eax
f0103bad:	66 a3 9e 12 21 f0    	mov    %ax,0xf021129e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, _T_DBLFLT_handler, 0);
f0103bb3:	b8 66 44 10 f0       	mov    $0xf0104466,%eax
f0103bb8:	66 a3 a0 12 21 f0    	mov    %ax,0xf02112a0
f0103bbe:	66 c7 05 a2 12 21 f0 	movw   $0x8,0xf02112a2
f0103bc5:	08 00 
f0103bc7:	c6 05 a4 12 21 f0 00 	movb   $0x0,0xf02112a4
f0103bce:	c6 05 a5 12 21 f0 8e 	movb   $0x8e,0xf02112a5
f0103bd5:	c1 e8 10             	shr    $0x10,%eax
f0103bd8:	66 a3 a6 12 21 f0    	mov    %ax,0xf02112a6
	SETGATE(idt[T_TSS], 0, GD_KT, _T_TSS_handler, 0);
f0103bde:	b8 6a 44 10 f0       	mov    $0xf010446a,%eax
f0103be3:	66 a3 b0 12 21 f0    	mov    %ax,0xf02112b0
f0103be9:	66 c7 05 b2 12 21 f0 	movw   $0x8,0xf02112b2
f0103bf0:	08 00 
f0103bf2:	c6 05 b4 12 21 f0 00 	movb   $0x0,0xf02112b4
f0103bf9:	c6 05 b5 12 21 f0 8e 	movb   $0x8e,0xf02112b5
f0103c00:	c1 e8 10             	shr    $0x10,%eax
f0103c03:	66 a3 b6 12 21 f0    	mov    %ax,0xf02112b6
	SETGATE(idt[T_SEGNP], 0, GD_KT, _T_SEGNP_handler, 0);
f0103c09:	b8 6e 44 10 f0       	mov    $0xf010446e,%eax
f0103c0e:	66 a3 b8 12 21 f0    	mov    %ax,0xf02112b8
f0103c14:	66 c7 05 ba 12 21 f0 	movw   $0x8,0xf02112ba
f0103c1b:	08 00 
f0103c1d:	c6 05 bc 12 21 f0 00 	movb   $0x0,0xf02112bc
f0103c24:	c6 05 bd 12 21 f0 8e 	movb   $0x8e,0xf02112bd
f0103c2b:	c1 e8 10             	shr    $0x10,%eax
f0103c2e:	66 a3 be 12 21 f0    	mov    %ax,0xf02112be
	SETGATE(idt[T_STACK], 0, GD_KT, _T_STACK_handler, 0);
f0103c34:	b8 72 44 10 f0       	mov    $0xf0104472,%eax
f0103c39:	66 a3 c0 12 21 f0    	mov    %ax,0xf02112c0
f0103c3f:	66 c7 05 c2 12 21 f0 	movw   $0x8,0xf02112c2
f0103c46:	08 00 
f0103c48:	c6 05 c4 12 21 f0 00 	movb   $0x0,0xf02112c4
f0103c4f:	c6 05 c5 12 21 f0 8e 	movb   $0x8e,0xf02112c5
f0103c56:	c1 e8 10             	shr    $0x10,%eax
f0103c59:	66 a3 c6 12 21 f0    	mov    %ax,0xf02112c6
	SETGATE(idt[T_GPFLT], 0, GD_KT, _T_GPFLT_handler, 0);
f0103c5f:	b8 76 44 10 f0       	mov    $0xf0104476,%eax
f0103c64:	66 a3 c8 12 21 f0    	mov    %ax,0xf02112c8
f0103c6a:	66 c7 05 ca 12 21 f0 	movw   $0x8,0xf02112ca
f0103c71:	08 00 
f0103c73:	c6 05 cc 12 21 f0 00 	movb   $0x0,0xf02112cc
f0103c7a:	c6 05 cd 12 21 f0 8e 	movb   $0x8e,0xf02112cd
f0103c81:	c1 e8 10             	shr    $0x10,%eax
f0103c84:	66 a3 ce 12 21 f0    	mov    %ax,0xf02112ce
	SETGATE(idt[T_PGFLT], 0, GD_KT, _T_PGFLT_handler, 0);
f0103c8a:	b8 7a 44 10 f0       	mov    $0xf010447a,%eax
f0103c8f:	66 a3 d0 12 21 f0    	mov    %ax,0xf02112d0
f0103c95:	66 c7 05 d2 12 21 f0 	movw   $0x8,0xf02112d2
f0103c9c:	08 00 
f0103c9e:	c6 05 d4 12 21 f0 00 	movb   $0x0,0xf02112d4
f0103ca5:	c6 05 d5 12 21 f0 8e 	movb   $0x8e,0xf02112d5
f0103cac:	c1 e8 10             	shr    $0x10,%eax
f0103caf:	66 a3 d6 12 21 f0    	mov    %ax,0xf02112d6
	SETGATE(idt[T_FPERR], 0, GD_KT, _T_FPERR_handler, 0);
f0103cb5:	b8 7e 44 10 f0       	mov    $0xf010447e,%eax
f0103cba:	66 a3 e0 12 21 f0    	mov    %ax,0xf02112e0
f0103cc0:	66 c7 05 e2 12 21 f0 	movw   $0x8,0xf02112e2
f0103cc7:	08 00 
f0103cc9:	c6 05 e4 12 21 f0 00 	movb   $0x0,0xf02112e4
f0103cd0:	c6 05 e5 12 21 f0 8e 	movb   $0x8e,0xf02112e5
f0103cd7:	c1 e8 10             	shr    $0x10,%eax
f0103cda:	66 a3 e6 12 21 f0    	mov    %ax,0xf02112e6
	SETGATE(idt[T_ALIGN], 0, GD_KT, _T_ALIGN_handler, 0);
f0103ce0:	b8 84 44 10 f0       	mov    $0xf0104484,%eax
f0103ce5:	66 a3 e8 12 21 f0    	mov    %ax,0xf02112e8
f0103ceb:	66 c7 05 ea 12 21 f0 	movw   $0x8,0xf02112ea
f0103cf2:	08 00 
f0103cf4:	c6 05 ec 12 21 f0 00 	movb   $0x0,0xf02112ec
f0103cfb:	c6 05 ed 12 21 f0 8e 	movb   $0x8e,0xf02112ed
f0103d02:	c1 e8 10             	shr    $0x10,%eax
f0103d05:	66 a3 ee 12 21 f0    	mov    %ax,0xf02112ee
	SETGATE(idt[T_MCHK], 0, GD_KT, _T_MCHK_handler, 0);
f0103d0b:	b8 88 44 10 f0       	mov    $0xf0104488,%eax
f0103d10:	66 a3 f0 12 21 f0    	mov    %ax,0xf02112f0
f0103d16:	66 c7 05 f2 12 21 f0 	movw   $0x8,0xf02112f2
f0103d1d:	08 00 
f0103d1f:	c6 05 f4 12 21 f0 00 	movb   $0x0,0xf02112f4
f0103d26:	c6 05 f5 12 21 f0 8e 	movb   $0x8e,0xf02112f5
f0103d2d:	c1 e8 10             	shr    $0x10,%eax
f0103d30:	66 a3 f6 12 21 f0    	mov    %ax,0xf02112f6
	SETGATE(idt[T_SIMDERR], 0, GD_KT, _T_SIMDERR_handler, 0);
f0103d36:	b8 8e 44 10 f0       	mov    $0xf010448e,%eax
f0103d3b:	66 a3 f8 12 21 f0    	mov    %ax,0xf02112f8
f0103d41:	66 c7 05 fa 12 21 f0 	movw   $0x8,0xf02112fa
f0103d48:	08 00 
f0103d4a:	c6 05 fc 12 21 f0 00 	movb   $0x0,0xf02112fc
f0103d51:	c6 05 fd 12 21 f0 8e 	movb   $0x8e,0xf02112fd
f0103d58:	c1 e8 10             	shr    $0x10,%eax
f0103d5b:	66 a3 fe 12 21 f0    	mov    %ax,0xf02112fe
	SETGATE(idt[T_SYSCALL], 0, GD_KT, _T_SYSCALL_handler, 3);
f0103d61:	b8 94 44 10 f0       	mov    $0xf0104494,%eax
f0103d66:	66 a3 e0 13 21 f0    	mov    %ax,0xf02113e0
f0103d6c:	66 c7 05 e2 13 21 f0 	movw   $0x8,0xf02113e2
f0103d73:	08 00 
f0103d75:	c6 05 e4 13 21 f0 00 	movb   $0x0,0xf02113e4
f0103d7c:	c6 05 e5 13 21 f0 ee 	movb   $0xee,0xf02113e5
f0103d83:	c1 e8 10             	shr    $0x10,%eax
f0103d86:	66 a3 e6 13 21 f0    	mov    %ax,0xf02113e6

	SETGATE(idt[IRQ_TIMER + IRQ_OFFSET], 0, GD_KT, _IRQ_TIMER_handler, 0);
f0103d8c:	b8 9a 44 10 f0       	mov    $0xf010449a,%eax
f0103d91:	66 a3 60 13 21 f0    	mov    %ax,0xf0211360
f0103d97:	66 c7 05 62 13 21 f0 	movw   $0x8,0xf0211362
f0103d9e:	08 00 
f0103da0:	c6 05 64 13 21 f0 00 	movb   $0x0,0xf0211364
f0103da7:	c6 05 65 13 21 f0 8e 	movb   $0x8e,0xf0211365
f0103dae:	c1 e8 10             	shr    $0x10,%eax
f0103db1:	66 a3 66 13 21 f0    	mov    %ax,0xf0211366
	SETGATE(idt[IRQ_KBD + IRQ_OFFSET], 0, GD_KT, _IRQ_KBD_handler, 0);
f0103db7:	b8 a0 44 10 f0       	mov    $0xf01044a0,%eax
f0103dbc:	66 a3 68 13 21 f0    	mov    %ax,0xf0211368
f0103dc2:	66 c7 05 6a 13 21 f0 	movw   $0x8,0xf021136a
f0103dc9:	08 00 
f0103dcb:	c6 05 6c 13 21 f0 00 	movb   $0x0,0xf021136c
f0103dd2:	c6 05 6d 13 21 f0 8e 	movb   $0x8e,0xf021136d
f0103dd9:	c1 e8 10             	shr    $0x10,%eax
f0103ddc:	66 a3 6e 13 21 f0    	mov    %ax,0xf021136e
	SETGATE(idt[IRQ_SERIAL + IRQ_OFFSET], 0, GD_KT, _IRQ_SERIAL_handler, 0);
f0103de2:	b8 a6 44 10 f0       	mov    $0xf01044a6,%eax
f0103de7:	66 a3 80 13 21 f0    	mov    %ax,0xf0211380
f0103ded:	66 c7 05 82 13 21 f0 	movw   $0x8,0xf0211382
f0103df4:	08 00 
f0103df6:	c6 05 84 13 21 f0 00 	movb   $0x0,0xf0211384
f0103dfd:	c6 05 85 13 21 f0 8e 	movb   $0x8e,0xf0211385
f0103e04:	c1 e8 10             	shr    $0x10,%eax
f0103e07:	66 a3 86 13 21 f0    	mov    %ax,0xf0211386
	SETGATE(idt[IRQ_SPURIOUS + IRQ_OFFSET], 0, GD_KT, _IRQ_SPURIOUS_handler, 0);
f0103e0d:	b8 ac 44 10 f0       	mov    $0xf01044ac,%eax
f0103e12:	66 a3 98 13 21 f0    	mov    %ax,0xf0211398
f0103e18:	66 c7 05 9a 13 21 f0 	movw   $0x8,0xf021139a
f0103e1f:	08 00 
f0103e21:	c6 05 9c 13 21 f0 00 	movb   $0x0,0xf021139c
f0103e28:	c6 05 9d 13 21 f0 8e 	movb   $0x8e,0xf021139d
f0103e2f:	c1 e8 10             	shr    $0x10,%eax
f0103e32:	66 a3 9e 13 21 f0    	mov    %ax,0xf021139e
	SETGATE(idt[IRQ_IDE + IRQ_OFFSET], 0, GD_KT, _IRQ_IDE_handler, 0);
f0103e38:	b8 b2 44 10 f0       	mov    $0xf01044b2,%eax
f0103e3d:	66 a3 d0 13 21 f0    	mov    %ax,0xf02113d0
f0103e43:	66 c7 05 d2 13 21 f0 	movw   $0x8,0xf02113d2
f0103e4a:	08 00 
f0103e4c:	c6 05 d4 13 21 f0 00 	movb   $0x0,0xf02113d4
f0103e53:	c6 05 d5 13 21 f0 8e 	movb   $0x8e,0xf02113d5
f0103e5a:	c1 e8 10             	shr    $0x10,%eax
f0103e5d:	66 a3 d6 13 21 f0    	mov    %ax,0xf02113d6
	SETGATE(idt[IRQ_ERROR + IRQ_OFFSET], 0, GD_KT, _IRQ_ERROR_handler, 0);
f0103e63:	b8 b8 44 10 f0       	mov    $0xf01044b8,%eax
f0103e68:	66 a3 f8 13 21 f0    	mov    %ax,0xf02113f8
f0103e6e:	66 c7 05 fa 13 21 f0 	movw   $0x8,0xf02113fa
f0103e75:	08 00 
f0103e77:	c6 05 fc 13 21 f0 00 	movb   $0x0,0xf02113fc
f0103e7e:	c6 05 fd 13 21 f0 8e 	movb   $0x8e,0xf02113fd
f0103e85:	c1 e8 10             	shr    $0x10,%eax
f0103e88:	66 a3 fe 13 21 f0    	mov    %ax,0xf02113fe

	// Per-CPU setup 
	trap_init_percpu();
f0103e8e:	e8 e3 fa ff ff       	call   f0103976 <trap_init_percpu>
}
f0103e93:	c9                   	leave  
f0103e94:	c3                   	ret    

f0103e95 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103e95:	55                   	push   %ebp
f0103e96:	89 e5                	mov    %esp,%ebp
f0103e98:	53                   	push   %ebx
f0103e99:	83 ec 0c             	sub    $0xc,%esp
f0103e9c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103e9f:	ff 33                	pushl  (%ebx)
f0103ea1:	68 e7 78 10 f0       	push   $0xf01078e7
f0103ea6:	e8 b7 fa ff ff       	call   f0103962 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103eab:	83 c4 08             	add    $0x8,%esp
f0103eae:	ff 73 04             	pushl  0x4(%ebx)
f0103eb1:	68 f6 78 10 f0       	push   $0xf01078f6
f0103eb6:	e8 a7 fa ff ff       	call   f0103962 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103ebb:	83 c4 08             	add    $0x8,%esp
f0103ebe:	ff 73 08             	pushl  0x8(%ebx)
f0103ec1:	68 05 79 10 f0       	push   $0xf0107905
f0103ec6:	e8 97 fa ff ff       	call   f0103962 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103ecb:	83 c4 08             	add    $0x8,%esp
f0103ece:	ff 73 0c             	pushl  0xc(%ebx)
f0103ed1:	68 14 79 10 f0       	push   $0xf0107914
f0103ed6:	e8 87 fa ff ff       	call   f0103962 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103edb:	83 c4 08             	add    $0x8,%esp
f0103ede:	ff 73 10             	pushl  0x10(%ebx)
f0103ee1:	68 23 79 10 f0       	push   $0xf0107923
f0103ee6:	e8 77 fa ff ff       	call   f0103962 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103eeb:	83 c4 08             	add    $0x8,%esp
f0103eee:	ff 73 14             	pushl  0x14(%ebx)
f0103ef1:	68 32 79 10 f0       	push   $0xf0107932
f0103ef6:	e8 67 fa ff ff       	call   f0103962 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103efb:	83 c4 08             	add    $0x8,%esp
f0103efe:	ff 73 18             	pushl  0x18(%ebx)
f0103f01:	68 41 79 10 f0       	push   $0xf0107941
f0103f06:	e8 57 fa ff ff       	call   f0103962 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103f0b:	83 c4 08             	add    $0x8,%esp
f0103f0e:	ff 73 1c             	pushl  0x1c(%ebx)
f0103f11:	68 50 79 10 f0       	push   $0xf0107950
f0103f16:	e8 47 fa ff ff       	call   f0103962 <cprintf>
}
f0103f1b:	83 c4 10             	add    $0x10,%esp
f0103f1e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103f21:	c9                   	leave  
f0103f22:	c3                   	ret    

f0103f23 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103f23:	55                   	push   %ebp
f0103f24:	89 e5                	mov    %esp,%ebp
f0103f26:	56                   	push   %esi
f0103f27:	53                   	push   %ebx
f0103f28:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103f2b:	e8 2a 1e 00 00       	call   f0105d5a <cpunum>
f0103f30:	83 ec 04             	sub    $0x4,%esp
f0103f33:	50                   	push   %eax
f0103f34:	53                   	push   %ebx
f0103f35:	68 b4 79 10 f0       	push   $0xf01079b4
f0103f3a:	e8 23 fa ff ff       	call   f0103962 <cprintf>
	print_regs(&tf->tf_regs);
f0103f3f:	89 1c 24             	mov    %ebx,(%esp)
f0103f42:	e8 4e ff ff ff       	call   f0103e95 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103f47:	83 c4 08             	add    $0x8,%esp
f0103f4a:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103f4e:	50                   	push   %eax
f0103f4f:	68 d2 79 10 f0       	push   $0xf01079d2
f0103f54:	e8 09 fa ff ff       	call   f0103962 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103f59:	83 c4 08             	add    $0x8,%esp
f0103f5c:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103f60:	50                   	push   %eax
f0103f61:	68 e5 79 10 f0       	push   $0xf01079e5
f0103f66:	e8 f7 f9 ff ff       	call   f0103962 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103f6b:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f0103f6e:	83 c4 10             	add    $0x10,%esp
f0103f71:	83 f8 13             	cmp    $0x13,%eax
f0103f74:	77 09                	ja     f0103f7f <print_trapframe+0x5c>
		return excnames[trapno];
f0103f76:	8b 14 85 a0 7c 10 f0 	mov    -0xfef8360(,%eax,4),%edx
f0103f7d:	eb 1f                	jmp    f0103f9e <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f0103f7f:	83 f8 30             	cmp    $0x30,%eax
f0103f82:	74 15                	je     f0103f99 <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103f84:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f0103f87:	83 fa 10             	cmp    $0x10,%edx
f0103f8a:	b9 7e 79 10 f0       	mov    $0xf010797e,%ecx
f0103f8f:	ba 6b 79 10 f0       	mov    $0xf010796b,%edx
f0103f94:	0f 43 d1             	cmovae %ecx,%edx
f0103f97:	eb 05                	jmp    f0103f9e <print_trapframe+0x7b>
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0103f99:	ba 5f 79 10 f0       	mov    $0xf010795f,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103f9e:	83 ec 04             	sub    $0x4,%esp
f0103fa1:	52                   	push   %edx
f0103fa2:	50                   	push   %eax
f0103fa3:	68 f8 79 10 f0       	push   $0xf01079f8
f0103fa8:	e8 b5 f9 ff ff       	call   f0103962 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103fad:	83 c4 10             	add    $0x10,%esp
f0103fb0:	3b 1d 60 1a 21 f0    	cmp    0xf0211a60,%ebx
f0103fb6:	75 1a                	jne    f0103fd2 <print_trapframe+0xaf>
f0103fb8:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103fbc:	75 14                	jne    f0103fd2 <print_trapframe+0xaf>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103fbe:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103fc1:	83 ec 08             	sub    $0x8,%esp
f0103fc4:	50                   	push   %eax
f0103fc5:	68 0a 7a 10 f0       	push   $0xf0107a0a
f0103fca:	e8 93 f9 ff ff       	call   f0103962 <cprintf>
f0103fcf:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103fd2:	83 ec 08             	sub    $0x8,%esp
f0103fd5:	ff 73 2c             	pushl  0x2c(%ebx)
f0103fd8:	68 19 7a 10 f0       	push   $0xf0107a19
f0103fdd:	e8 80 f9 ff ff       	call   f0103962 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103fe2:	83 c4 10             	add    $0x10,%esp
f0103fe5:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103fe9:	75 49                	jne    f0104034 <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103feb:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103fee:	89 c2                	mov    %eax,%edx
f0103ff0:	83 e2 01             	and    $0x1,%edx
f0103ff3:	ba 98 79 10 f0       	mov    $0xf0107998,%edx
f0103ff8:	b9 8d 79 10 f0       	mov    $0xf010798d,%ecx
f0103ffd:	0f 44 ca             	cmove  %edx,%ecx
f0104000:	89 c2                	mov    %eax,%edx
f0104002:	83 e2 02             	and    $0x2,%edx
f0104005:	ba aa 79 10 f0       	mov    $0xf01079aa,%edx
f010400a:	be a4 79 10 f0       	mov    $0xf01079a4,%esi
f010400f:	0f 45 d6             	cmovne %esi,%edx
f0104012:	83 e0 04             	and    $0x4,%eax
f0104015:	be f1 7a 10 f0       	mov    $0xf0107af1,%esi
f010401a:	b8 af 79 10 f0       	mov    $0xf01079af,%eax
f010401f:	0f 44 c6             	cmove  %esi,%eax
f0104022:	51                   	push   %ecx
f0104023:	52                   	push   %edx
f0104024:	50                   	push   %eax
f0104025:	68 27 7a 10 f0       	push   $0xf0107a27
f010402a:	e8 33 f9 ff ff       	call   f0103962 <cprintf>
f010402f:	83 c4 10             	add    $0x10,%esp
f0104032:	eb 10                	jmp    f0104044 <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0104034:	83 ec 0c             	sub    $0xc,%esp
f0104037:	68 19 6d 10 f0       	push   $0xf0106d19
f010403c:	e8 21 f9 ff ff       	call   f0103962 <cprintf>
f0104041:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0104044:	83 ec 08             	sub    $0x8,%esp
f0104047:	ff 73 30             	pushl  0x30(%ebx)
f010404a:	68 36 7a 10 f0       	push   $0xf0107a36
f010404f:	e8 0e f9 ff ff       	call   f0103962 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0104054:	83 c4 08             	add    $0x8,%esp
f0104057:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f010405b:	50                   	push   %eax
f010405c:	68 45 7a 10 f0       	push   $0xf0107a45
f0104061:	e8 fc f8 ff ff       	call   f0103962 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104066:	83 c4 08             	add    $0x8,%esp
f0104069:	ff 73 38             	pushl  0x38(%ebx)
f010406c:	68 58 7a 10 f0       	push   $0xf0107a58
f0104071:	e8 ec f8 ff ff       	call   f0103962 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0104076:	83 c4 10             	add    $0x10,%esp
f0104079:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f010407d:	74 25                	je     f01040a4 <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f010407f:	83 ec 08             	sub    $0x8,%esp
f0104082:	ff 73 3c             	pushl  0x3c(%ebx)
f0104085:	68 67 7a 10 f0       	push   $0xf0107a67
f010408a:	e8 d3 f8 ff ff       	call   f0103962 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f010408f:	83 c4 08             	add    $0x8,%esp
f0104092:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0104096:	50                   	push   %eax
f0104097:	68 76 7a 10 f0       	push   $0xf0107a76
f010409c:	e8 c1 f8 ff ff       	call   f0103962 <cprintf>
f01040a1:	83 c4 10             	add    $0x10,%esp
	}
}
f01040a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01040a7:	5b                   	pop    %ebx
f01040a8:	5e                   	pop    %esi
f01040a9:	5d                   	pop    %ebp
f01040aa:	c3                   	ret    

f01040ab <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01040ab:	55                   	push   %ebp
f01040ac:	89 e5                	mov    %esp,%ebp
f01040ae:	57                   	push   %edi
f01040af:	56                   	push   %esi
f01040b0:	53                   	push   %ebx
f01040b1:	83 ec 1c             	sub    $0x1c,%esp
f01040b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01040b7:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) == 0)
f01040ba:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01040be:	75 15                	jne    f01040d5 <page_fault_handler+0x2a>
		panic("page fault in kernel at %x!", fault_va);
f01040c0:	56                   	push   %esi
f01040c1:	68 89 7a 10 f0       	push   $0xf0107a89
f01040c6:	68 61 01 00 00       	push   $0x161
f01040cb:	68 a5 7a 10 f0       	push   $0xf0107aa5
f01040d0:	e8 6b bf ff ff       	call   f0100040 <_panic>
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	if (curenv->env_pgfault_upcall) {
f01040d5:	e8 80 1c 00 00       	call   f0105d5a <cpunum>
f01040da:	6b c0 74             	imul   $0x74,%eax,%eax
f01040dd:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01040e3:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f01040e7:	0f 84 d1 00 00 00    	je     f01041be <page_fault_handler+0x113>

		cprintf("Page fault at 0x%x, env_pgfault_upcall: 0x%x\n", fault_va, curenv->env_pgfault_upcall);
f01040ed:	e8 68 1c 00 00       	call   f0105d5a <cpunum>
f01040f2:	83 ec 04             	sub    $0x4,%esp
f01040f5:	6b c0 74             	imul   $0x74,%eax,%eax
f01040f8:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01040fe:	ff 70 64             	pushl  0x64(%eax)
f0104101:	56                   	push   %esi
f0104102:	68 3c 7c 10 f0       	push   $0xf0107c3c
f0104107:	e8 56 f8 ff ff       	call   f0103962 <cprintf>
		uint32_t estack_top = UXSTACKTOP;

		// if pgfault happens in user exception stack
		// as mentioned above, we push things right after the previous exception stack 
		// started with dummy 4 bytes
		if (tf->tf_esp < UXSTACKTOP && tf->tf_esp >= UXSTACKTOP - PGSIZE)
f010410c:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010410f:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
f0104115:	83 c4 10             	add    $0x10,%esp
			estack_top = tf->tf_esp - 4;
f0104118:	83 e8 04             	sub    $0x4,%eax
f010411b:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0104121:	bf 00 00 c0 ee       	mov    $0xeec00000,%edi
f0104126:	0f 46 f8             	cmovbe %eax,%edi

		// char* utrapframe = (char *)(estack_top - sizeof(struct UTrapframe));
		struct UTrapframe *utf = (struct UTrapframe *)(estack_top - sizeof(struct UTrapframe));
f0104129:	8d 47 cc             	lea    -0x34(%edi),%eax
f010412c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// do a memory check
		user_mem_assert(curenv, (void *)utf, sizeof(struct UTrapframe), PTE_W | PTE_P);
f010412f:	e8 26 1c 00 00       	call   f0105d5a <cpunum>
f0104134:	6a 03                	push   $0x3
f0104136:	6a 34                	push   $0x34
f0104138:	ff 75 e4             	pushl  -0x1c(%ebp)
f010413b:	6b c0 74             	imul   $0x74,%eax,%eax
f010413e:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0104144:	e8 f5 ee ff ff       	call   f010303e <user_mem_assert>

		// copy context to utrapframe 
		// memcpy(utrapframe, (char *)tf, sizeof(struct UTrapframe));
		// *(uint32_t *)utrapframe = fault_va;
		utf->utf_fault_va = fault_va;
f0104149:	89 77 cc             	mov    %esi,-0x34(%edi)
        utf->utf_err      = tf->tf_trapno;
f010414c:	8b 43 28             	mov    0x28(%ebx),%eax
f010414f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104152:	89 42 04             	mov    %eax,0x4(%edx)
        utf->utf_regs     = tf->tf_regs;
f0104155:	83 ef 2c             	sub    $0x2c,%edi
f0104158:	b9 08 00 00 00       	mov    $0x8,%ecx
f010415d:	89 de                	mov    %ebx,%esi
f010415f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
        utf->utf_eflags   = tf->tf_eflags;
f0104161:	8b 43 38             	mov    0x38(%ebx),%eax
f0104164:	89 42 2c             	mov    %eax,0x2c(%edx)
        utf->utf_eip      = tf->tf_eip;
f0104167:	8b 43 30             	mov    0x30(%ebx),%eax
f010416a:	89 d6                	mov    %edx,%esi
f010416c:	89 42 28             	mov    %eax,0x28(%edx)
        utf->utf_esp      = tf->tf_esp;
f010416f:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104172:	89 42 30             	mov    %eax,0x30(%edx)

		curenv->env_tf.tf_esp = (uint32_t)utf;
f0104175:	e8 e0 1b 00 00       	call   f0105d5a <cpunum>
f010417a:	6b c0 74             	imul   $0x74,%eax,%eax
f010417d:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104183:	89 70 3c             	mov    %esi,0x3c(%eax)
		curenv->env_tf.tf_eip = (uint32_t)curenv->env_pgfault_upcall;
f0104186:	e8 cf 1b 00 00       	call   f0105d5a <cpunum>
f010418b:	6b c0 74             	imul   $0x74,%eax,%eax
f010418e:	8b 98 28 20 21 f0    	mov    -0xfdedfd8(%eax),%ebx
f0104194:	e8 c1 1b 00 00       	call   f0105d5a <cpunum>
f0104199:	6b c0 74             	imul   $0x74,%eax,%eax
f010419c:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01041a2:	8b 40 64             	mov    0x64(%eax),%eax
f01041a5:	89 43 30             	mov    %eax,0x30(%ebx)
		env_run(curenv);
f01041a8:	e8 ad 1b 00 00       	call   f0105d5a <cpunum>
f01041ad:	83 c4 04             	add    $0x4,%esp
f01041b0:	6b c0 74             	imul   $0x74,%eax,%eax
f01041b3:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f01041b9:	e8 42 f5 ff ff       	call   f0103700 <env_run>

	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01041be:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f01041c1:	e8 94 1b 00 00       	call   f0105d5a <cpunum>
		env_run(curenv);

	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01041c6:	57                   	push   %edi
f01041c7:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f01041c8:	6b c0 74             	imul   $0x74,%eax,%eax
		env_run(curenv);

	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01041cb:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01041d1:	ff 70 48             	pushl  0x48(%eax)
f01041d4:	68 6c 7c 10 f0       	push   $0xf0107c6c
f01041d9:	e8 84 f7 ff ff       	call   f0103962 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f01041de:	89 1c 24             	mov    %ebx,(%esp)
f01041e1:	e8 3d fd ff ff       	call   f0103f23 <print_trapframe>
	env_destroy(curenv);
f01041e6:	e8 6f 1b 00 00       	call   f0105d5a <cpunum>
f01041eb:	83 c4 04             	add    $0x4,%esp
f01041ee:	6b c0 74             	imul   $0x74,%eax,%eax
f01041f1:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f01041f7:	e8 65 f4 ff ff       	call   f0103661 <env_destroy>
}
f01041fc:	83 c4 10             	add    $0x10,%esp
f01041ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104202:	5b                   	pop    %ebx
f0104203:	5e                   	pop    %esi
f0104204:	5f                   	pop    %edi
f0104205:	5d                   	pop    %ebp
f0104206:	c3                   	ret    

f0104207 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0104207:	55                   	push   %ebp
f0104208:	89 e5                	mov    %esp,%ebp
f010420a:	57                   	push   %edi
f010420b:	56                   	push   %esi
f010420c:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f010420f:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0104210:	83 3d 80 1e 21 f0 00 	cmpl   $0x0,0xf0211e80
f0104217:	74 01                	je     f010421a <trap+0x13>
		asm volatile("hlt");
f0104219:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f010421a:	e8 3b 1b 00 00       	call   f0105d5a <cpunum>
f010421f:	6b d0 74             	imul   $0x74,%eax,%edx
f0104222:	81 c2 20 20 21 f0    	add    $0xf0212020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0104228:	b8 01 00 00 00       	mov    $0x1,%eax
f010422d:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0104231:	83 f8 02             	cmp    $0x2,%eax
f0104234:	75 10                	jne    f0104246 <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104236:	83 ec 0c             	sub    $0xc,%esp
f0104239:	68 c0 03 12 f0       	push   $0xf01203c0
f010423e:	e8 85 1d 00 00       	call   f0105fc8 <spin_lock>
f0104243:	83 c4 10             	add    $0x10,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0104246:	9c                   	pushf  
f0104247:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104248:	f6 c4 02             	test   $0x2,%ah
f010424b:	74 19                	je     f0104266 <trap+0x5f>
f010424d:	68 b1 7a 10 f0       	push   $0xf0107ab1
f0104252:	68 05 6a 10 f0       	push   $0xf0106a05
f0104257:	68 29 01 00 00       	push   $0x129
f010425c:	68 a5 7a 10 f0       	push   $0xf0107aa5
f0104261:	e8 da bd ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0104266:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010426a:	83 e0 03             	and    $0x3,%eax
f010426d:	66 83 f8 03          	cmp    $0x3,%ax
f0104271:	0f 85 a0 00 00 00    	jne    f0104317 <trap+0x110>
f0104277:	83 ec 0c             	sub    $0xc,%esp
f010427a:	68 c0 03 12 f0       	push   $0xf01203c0
f010427f:	e8 44 1d 00 00       	call   f0105fc8 <spin_lock>
		// serious kernel work.
		// LAB 4: Your code here.

		lock_kernel();

		assert(curenv);
f0104284:	e8 d1 1a 00 00       	call   f0105d5a <cpunum>
f0104289:	6b c0 74             	imul   $0x74,%eax,%eax
f010428c:	83 c4 10             	add    $0x10,%esp
f010428f:	83 b8 28 20 21 f0 00 	cmpl   $0x0,-0xfdedfd8(%eax)
f0104296:	75 19                	jne    f01042b1 <trap+0xaa>
f0104298:	68 ca 7a 10 f0       	push   $0xf0107aca
f010429d:	68 05 6a 10 f0       	push   $0xf0106a05
f01042a2:	68 33 01 00 00       	push   $0x133
f01042a7:	68 a5 7a 10 f0       	push   $0xf0107aa5
f01042ac:	e8 8f bd ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f01042b1:	e8 a4 1a 00 00       	call   f0105d5a <cpunum>
f01042b6:	6b c0 74             	imul   $0x74,%eax,%eax
f01042b9:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01042bf:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01042c3:	75 2d                	jne    f01042f2 <trap+0xeb>
			env_free(curenv);
f01042c5:	e8 90 1a 00 00       	call   f0105d5a <cpunum>
f01042ca:	83 ec 0c             	sub    $0xc,%esp
f01042cd:	6b c0 74             	imul   $0x74,%eax,%eax
f01042d0:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f01042d6:	e8 e0 f1 ff ff       	call   f01034bb <env_free>
			curenv = NULL;
f01042db:	e8 7a 1a 00 00       	call   f0105d5a <cpunum>
f01042e0:	6b c0 74             	imul   $0x74,%eax,%eax
f01042e3:	c7 80 28 20 21 f0 00 	movl   $0x0,-0xfdedfd8(%eax)
f01042ea:	00 00 00 
			sched_yield();
f01042ed:	e8 b2 02 00 00       	call   f01045a4 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01042f2:	e8 63 1a 00 00       	call   f0105d5a <cpunum>
f01042f7:	6b c0 74             	imul   $0x74,%eax,%eax
f01042fa:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104300:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104305:	89 c7                	mov    %eax,%edi
f0104307:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104309:	e8 4c 1a 00 00       	call   f0105d5a <cpunum>
f010430e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104311:	8b b0 28 20 21 f0    	mov    -0xfdedfd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104317:	89 35 60 1a 21 f0    	mov    %esi,0xf0211a60
 
	// Handle keyboard and serial interrupts.
	// LAB 5: Your code here.
	struct PushRegs* r = &tf->tf_regs;

	switch(tf->tf_trapno) {
f010431d:	8b 46 28             	mov    0x28(%esi),%eax
f0104320:	83 f8 20             	cmp    $0x20,%eax
f0104323:	74 65                	je     f010438a <trap+0x183>
f0104325:	83 f8 20             	cmp    $0x20,%eax
f0104328:	77 0c                	ja     f0104336 <trap+0x12f>
f010432a:	83 f8 03             	cmp    $0x3,%eax
f010432d:	74 29                	je     f0104358 <trap+0x151>
f010432f:	83 f8 0e             	cmp    $0xe,%eax
f0104332:	74 13                	je     f0104347 <trap+0x140>
f0104334:	eb 6c                	jmp    f01043a2 <trap+0x19b>
f0104336:	83 f8 24             	cmp    $0x24,%eax
f0104339:	74 60                	je     f010439b <trap+0x194>
f010433b:	83 f8 30             	cmp    $0x30,%eax
f010433e:	74 29                	je     f0104369 <trap+0x162>
f0104340:	83 f8 21             	cmp    $0x21,%eax
f0104343:	75 5d                	jne    f01043a2 <trap+0x19b>
f0104345:	eb 4d                	jmp    f0104394 <trap+0x18d>
		case (T_PGFLT):
			page_fault_handler(tf);
f0104347:	83 ec 0c             	sub    $0xc,%esp
f010434a:	56                   	push   %esi
f010434b:	e8 5b fd ff ff       	call   f01040ab <page_fault_handler>
f0104350:	83 c4 10             	add    $0x10,%esp
f0104353:	e9 9a 00 00 00       	jmp    f01043f2 <trap+0x1eb>
			break;
		case (T_BRKPT):
			monitor(tf);	// open a JOS monitor
f0104358:	83 ec 0c             	sub    $0xc,%esp
f010435b:	56                   	push   %esi
f010435c:	e8 46 c6 ff ff       	call   f01009a7 <monitor>
f0104361:	83 c4 10             	add    $0x10,%esp
f0104364:	e9 89 00 00 00       	jmp    f01043f2 <trap+0x1eb>
			break;
		case (T_SYSCALL):
			// call syscall in kern/syscall.c
			r->reg_eax = syscall(r->reg_eax, r->reg_edx, r->reg_ecx, r->reg_ebx, r->reg_edi, r->reg_esi);
f0104369:	83 ec 08             	sub    $0x8,%esp
f010436c:	ff 76 04             	pushl  0x4(%esi)
f010436f:	ff 36                	pushl  (%esi)
f0104371:	ff 76 10             	pushl  0x10(%esi)
f0104374:	ff 76 18             	pushl  0x18(%esi)
f0104377:	ff 76 14             	pushl  0x14(%esi)
f010437a:	ff 76 1c             	pushl  0x1c(%esi)
f010437d:	e8 ab 02 00 00       	call   f010462d <syscall>
f0104382:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104385:	83 c4 20             	add    $0x20,%esp
f0104388:	eb 68                	jmp    f01043f2 <trap+0x1eb>
			break;
		case (IRQ_OFFSET + IRQ_TIMER):
			lapic_eoi();	// Acknowledge interrupt.
f010438a:	e8 16 1b 00 00       	call   f0105ea5 <lapic_eoi>
			sched_yield();
f010438f:	e8 10 02 00 00       	call   f01045a4 <sched_yield>
			break;
		case (IRQ_OFFSET+IRQ_KBD):
			kbd_intr();
f0104394:	e8 47 c2 ff ff       	call   f01005e0 <kbd_intr>
f0104399:	eb 57                	jmp    f01043f2 <trap+0x1eb>
			break;
		case (IRQ_OFFSET+IRQ_SERIAL):
			serial_intr();
f010439b:	e8 24 c2 ff ff       	call   f01005c4 <serial_intr>
f01043a0:	eb 50                	jmp    f01043f2 <trap+0x1eb>
			break;
		default:
			// Unexpected trap: The user process or the kernel has a bug.
			cprintf("[trapno: %x]\n", tf->tf_trapno);
f01043a2:	83 ec 08             	sub    $0x8,%esp
f01043a5:	50                   	push   %eax
f01043a6:	68 d1 7a 10 f0       	push   $0xf0107ad1
f01043ab:	e8 b2 f5 ff ff       	call   f0103962 <cprintf>
			print_trapframe(tf);
f01043b0:	89 34 24             	mov    %esi,(%esp)
f01043b3:	e8 6b fb ff ff       	call   f0103f23 <print_trapframe>
			if (tf->tf_cs == GD_KT)
f01043b8:	83 c4 10             	add    $0x10,%esp
f01043bb:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01043c0:	75 17                	jne    f01043d9 <trap+0x1d2>
				panic("unhandled trap in kernel");
f01043c2:	83 ec 04             	sub    $0x4,%esp
f01043c5:	68 df 7a 10 f0       	push   $0xf0107adf
f01043ca:	68 0e 01 00 00       	push   $0x10e
f01043cf:	68 a5 7a 10 f0       	push   $0xf0107aa5
f01043d4:	e8 67 bc ff ff       	call   f0100040 <_panic>
			else {
				env_destroy(curenv);
f01043d9:	e8 7c 19 00 00       	call   f0105d5a <cpunum>
f01043de:	83 ec 0c             	sub    $0xc,%esp
f01043e1:	6b c0 74             	imul   $0x74,%eax,%eax
f01043e4:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f01043ea:	e8 72 f2 ff ff       	call   f0103661 <env_destroy>
f01043ef:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f01043f2:	e8 63 19 00 00       	call   f0105d5a <cpunum>
f01043f7:	6b c0 74             	imul   $0x74,%eax,%eax
f01043fa:	83 b8 28 20 21 f0 00 	cmpl   $0x0,-0xfdedfd8(%eax)
f0104401:	74 2a                	je     f010442d <trap+0x226>
f0104403:	e8 52 19 00 00       	call   f0105d5a <cpunum>
f0104408:	6b c0 74             	imul   $0x74,%eax,%eax
f010440b:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104411:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104415:	75 16                	jne    f010442d <trap+0x226>
		env_run(curenv);
f0104417:	e8 3e 19 00 00       	call   f0105d5a <cpunum>
f010441c:	83 ec 0c             	sub    $0xc,%esp
f010441f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104422:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0104428:	e8 d3 f2 ff ff       	call   f0103700 <env_run>
	else
		sched_yield();
f010442d:	e8 72 01 00 00       	call   f01045a4 <sched_yield>

f0104432 <_T_DIVIDE_handler>:
/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */


TRAPHANDLER_NOEC(_T_DIVIDE_handler, T_DIVIDE)
f0104432:	6a 00                	push   $0x0
f0104434:	6a 00                	push   $0x0
f0104436:	e9 83 00 00 00       	jmp    f01044be <_alltraps>
f010443b:	90                   	nop

f010443c <_T_DEBUG_handler>:
TRAPHANDLER_NOEC(_T_DEBUG_handler, T_DEBUG)
f010443c:	6a 00                	push   $0x0
f010443e:	6a 01                	push   $0x1
f0104440:	eb 7c                	jmp    f01044be <_alltraps>

f0104442 <_T_NMI_handler>:
TRAPHANDLER_NOEC(_T_NMI_handler, T_NMI)
f0104442:	6a 00                	push   $0x0
f0104444:	6a 02                	push   $0x2
f0104446:	eb 76                	jmp    f01044be <_alltraps>

f0104448 <_T_BRKPT_handler>:
TRAPHANDLER_NOEC(_T_BRKPT_handler, T_BRKPT)
f0104448:	6a 00                	push   $0x0
f010444a:	6a 03                	push   $0x3
f010444c:	eb 70                	jmp    f01044be <_alltraps>

f010444e <_T_OFLOW_handler>:
TRAPHANDLER_NOEC(_T_OFLOW_handler, T_OFLOW)
f010444e:	6a 00                	push   $0x0
f0104450:	6a 04                	push   $0x4
f0104452:	eb 6a                	jmp    f01044be <_alltraps>

f0104454 <_T_BOUND_handler>:
TRAPHANDLER_NOEC(_T_BOUND_handler, T_BOUND)
f0104454:	6a 00                	push   $0x0
f0104456:	6a 05                	push   $0x5
f0104458:	eb 64                	jmp    f01044be <_alltraps>

f010445a <_T_ILLOP_handler>:
TRAPHANDLER_NOEC(_T_ILLOP_handler, T_ILLOP)
f010445a:	6a 00                	push   $0x0
f010445c:	6a 06                	push   $0x6
f010445e:	eb 5e                	jmp    f01044be <_alltraps>

f0104460 <_T_DEVICE_handler>:
TRAPHANDLER_NOEC(_T_DEVICE_handler, T_DEVICE)
f0104460:	6a 00                	push   $0x0
f0104462:	6a 07                	push   $0x7
f0104464:	eb 58                	jmp    f01044be <_alltraps>

f0104466 <_T_DBLFLT_handler>:
TRAPHANDLER(_T_DBLFLT_handler, T_DBLFLT)
f0104466:	6a 08                	push   $0x8
f0104468:	eb 54                	jmp    f01044be <_alltraps>

f010446a <_T_TSS_handler>:
TRAPHANDLER(_T_TSS_handler, T_TSS)
f010446a:	6a 0a                	push   $0xa
f010446c:	eb 50                	jmp    f01044be <_alltraps>

f010446e <_T_SEGNP_handler>:
TRAPHANDLER(_T_SEGNP_handler, T_SEGNP)
f010446e:	6a 0b                	push   $0xb
f0104470:	eb 4c                	jmp    f01044be <_alltraps>

f0104472 <_T_STACK_handler>:
TRAPHANDLER(_T_STACK_handler, T_STACK)
f0104472:	6a 0c                	push   $0xc
f0104474:	eb 48                	jmp    f01044be <_alltraps>

f0104476 <_T_GPFLT_handler>:
TRAPHANDLER(_T_GPFLT_handler, T_GPFLT)
f0104476:	6a 0d                	push   $0xd
f0104478:	eb 44                	jmp    f01044be <_alltraps>

f010447a <_T_PGFLT_handler>:
TRAPHANDLER(_T_PGFLT_handler, T_PGFLT)
f010447a:	6a 0e                	push   $0xe
f010447c:	eb 40                	jmp    f01044be <_alltraps>

f010447e <_T_FPERR_handler>:
TRAPHANDLER_NOEC(_T_FPERR_handler, T_FPERR)
f010447e:	6a 00                	push   $0x0
f0104480:	6a 10                	push   $0x10
f0104482:	eb 3a                	jmp    f01044be <_alltraps>

f0104484 <_T_ALIGN_handler>:
TRAPHANDLER(_T_ALIGN_handler, T_ALIGN)
f0104484:	6a 11                	push   $0x11
f0104486:	eb 36                	jmp    f01044be <_alltraps>

f0104488 <_T_MCHK_handler>:
TRAPHANDLER_NOEC(_T_MCHK_handler, T_MCHK)
f0104488:	6a 00                	push   $0x0
f010448a:	6a 12                	push   $0x12
f010448c:	eb 30                	jmp    f01044be <_alltraps>

f010448e <_T_SIMDERR_handler>:
TRAPHANDLER_NOEC(_T_SIMDERR_handler, T_SIMDERR)
f010448e:	6a 00                	push   $0x0
f0104490:	6a 13                	push   $0x13
f0104492:	eb 2a                	jmp    f01044be <_alltraps>

f0104494 <_T_SYSCALL_handler>:
TRAPHANDLER_NOEC(_T_SYSCALL_handler, T_SYSCALL)
f0104494:	6a 00                	push   $0x0
f0104496:	6a 30                	push   $0x30
f0104498:	eb 24                	jmp    f01044be <_alltraps>

f010449a <_IRQ_TIMER_handler>:

TRAPHANDLER_NOEC(_IRQ_TIMER_handler, IRQ_TIMER + IRQ_OFFSET)
f010449a:	6a 00                	push   $0x0
f010449c:	6a 20                	push   $0x20
f010449e:	eb 1e                	jmp    f01044be <_alltraps>

f01044a0 <_IRQ_KBD_handler>:
TRAPHANDLER_NOEC(_IRQ_KBD_handler, IRQ_KBD + IRQ_OFFSET)
f01044a0:	6a 00                	push   $0x0
f01044a2:	6a 21                	push   $0x21
f01044a4:	eb 18                	jmp    f01044be <_alltraps>

f01044a6 <_IRQ_SERIAL_handler>:
TRAPHANDLER_NOEC(_IRQ_SERIAL_handler, IRQ_SERIAL + IRQ_OFFSET)
f01044a6:	6a 00                	push   $0x0
f01044a8:	6a 24                	push   $0x24
f01044aa:	eb 12                	jmp    f01044be <_alltraps>

f01044ac <_IRQ_SPURIOUS_handler>:
TRAPHANDLER_NOEC(_IRQ_SPURIOUS_handler, IRQ_SPURIOUS + IRQ_OFFSET)
f01044ac:	6a 00                	push   $0x0
f01044ae:	6a 27                	push   $0x27
f01044b0:	eb 0c                	jmp    f01044be <_alltraps>

f01044b2 <_IRQ_IDE_handler>:
TRAPHANDLER_NOEC(_IRQ_IDE_handler, IRQ_IDE + IRQ_OFFSET)
f01044b2:	6a 00                	push   $0x0
f01044b4:	6a 2e                	push   $0x2e
f01044b6:	eb 06                	jmp    f01044be <_alltraps>

f01044b8 <_IRQ_ERROR_handler>:
TRAPHANDLER_NOEC(_IRQ_ERROR_handler, IRQ_ERROR + IRQ_OFFSET)
f01044b8:	6a 00                	push   $0x0
f01044ba:	6a 33                	push   $0x33
f01044bc:	eb 00                	jmp    f01044be <_alltraps>

f01044be <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */

_alltraps:
	pushl %ds
f01044be:	1e                   	push   %ds
	pushl %es
f01044bf:	06                   	push   %es
	pushal	/* push all general registers */
f01044c0:	60                   	pusha  

	movl $GD_KD, %eax
f01044c1:	b8 10 00 00 00       	mov    $0x10,%eax
	movl %eax, %ds
f01044c6:	8e d8                	mov    %eax,%ds
	movl %eax, %es
f01044c8:	8e c0                	mov    %eax,%es

	push %esp
f01044ca:	54                   	push   %esp
f01044cb:	e8 37 fd ff ff       	call   f0104207 <trap>

f01044d0 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f01044d0:	55                   	push   %ebp
f01044d1:	89 e5                	mov    %esp,%ebp
f01044d3:	83 ec 08             	sub    $0x8,%esp
f01044d6:	a1 48 12 21 f0       	mov    0xf0211248,%eax
f01044db:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01044de:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f01044e3:	8b 02                	mov    (%edx),%eax
f01044e5:	83 e8 01             	sub    $0x1,%eax
f01044e8:	83 f8 02             	cmp    $0x2,%eax
f01044eb:	76 10                	jbe    f01044fd <sched_halt+0x2d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01044ed:	83 c1 01             	add    $0x1,%ecx
f01044f0:	83 c2 7c             	add    $0x7c,%edx
f01044f3:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01044f9:	75 e8                	jne    f01044e3 <sched_halt+0x13>
f01044fb:	eb 08                	jmp    f0104505 <sched_halt+0x35>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f01044fd:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104503:	75 1f                	jne    f0104524 <sched_halt+0x54>
		cprintf("No runnable environments in the system!\n");
f0104505:	83 ec 0c             	sub    $0xc,%esp
f0104508:	68 f0 7c 10 f0       	push   $0xf0107cf0
f010450d:	e8 50 f4 ff ff       	call   f0103962 <cprintf>
f0104512:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0104515:	83 ec 0c             	sub    $0xc,%esp
f0104518:	6a 00                	push   $0x0
f010451a:	e8 88 c4 ff ff       	call   f01009a7 <monitor>
f010451f:	83 c4 10             	add    $0x10,%esp
f0104522:	eb f1                	jmp    f0104515 <sched_halt+0x45>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104524:	e8 31 18 00 00       	call   f0105d5a <cpunum>
f0104529:	6b c0 74             	imul   $0x74,%eax,%eax
f010452c:	c7 80 28 20 21 f0 00 	movl   $0x0,-0xfdedfd8(%eax)
f0104533:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104536:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010453b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104540:	77 12                	ja     f0104554 <sched_halt+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104542:	50                   	push   %eax
f0104543:	68 48 64 10 f0       	push   $0xf0106448
f0104548:	6a 52                	push   $0x52
f010454a:	68 19 7d 10 f0       	push   $0xf0107d19
f010454f:	e8 ec ba ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104554:	05 00 00 00 10       	add    $0x10000000,%eax
f0104559:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f010455c:	e8 f9 17 00 00       	call   f0105d5a <cpunum>
f0104561:	6b d0 74             	imul   $0x74,%eax,%edx
f0104564:	81 c2 20 20 21 f0    	add    $0xf0212020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f010456a:	b8 02 00 00 00       	mov    $0x2,%eax
f010456f:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104573:	83 ec 0c             	sub    $0xc,%esp
f0104576:	68 c0 03 12 f0       	push   $0xf01203c0
f010457b:	e8 e5 1a 00 00       	call   f0106065 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104580:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104582:	e8 d3 17 00 00       	call   f0105d5a <cpunum>
f0104587:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f010458a:	8b 80 30 20 21 f0    	mov    -0xfdedfd0(%eax),%eax
f0104590:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104595:	89 c4                	mov    %eax,%esp
f0104597:	6a 00                	push   $0x0
f0104599:	6a 00                	push   $0x0
f010459b:	fb                   	sti    
f010459c:	f4                   	hlt    
f010459d:	eb fd                	jmp    f010459c <sched_halt+0xcc>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f010459f:	83 c4 10             	add    $0x10,%esp
f01045a2:	c9                   	leave  
f01045a3:	c3                   	ret    

f01045a4 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f01045a4:	55                   	push   %ebp
f01045a5:	89 e5                	mov    %esp,%ebp
f01045a7:	56                   	push   %esi
f01045a8:	53                   	push   %ebx
	// below to halt the cpu.

	// LAB 4: Your code here.
	// cprintf("[yield]\n");

	struct Env *now = thiscpu->cpu_env;
f01045a9:	e8 ac 17 00 00       	call   f0105d5a <cpunum>
f01045ae:	6b c0 74             	imul   $0x74,%eax,%eax
f01045b1:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
    int32_t startid = (now) ? ENVX(now->env_id): 0;
f01045b7:	85 c0                	test   %eax,%eax
f01045b9:	74 0b                	je     f01045c6 <sched_yield+0x22>
f01045bb:	8b 50 48             	mov    0x48(%eax),%edx
f01045be:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01045c4:	eb 05                	jmp    f01045cb <sched_yield+0x27>
f01045c6:	ba 00 00 00 00       	mov    $0x0,%edx
    int32_t nextid;
    size_t i;

    for(i = 0; i < NENV; i++) {
        nextid = (startid+i)%NENV;
        if(envs[nextid].env_status == ENV_RUNNABLE) {
f01045cb:	8b 0d 48 12 21 f0    	mov    0xf0211248,%ecx
f01045d1:	89 d6                	mov    %edx,%esi
f01045d3:	8d 9a 00 04 00 00    	lea    0x400(%edx),%ebx
f01045d9:	89 d0                	mov    %edx,%eax
f01045db:	25 ff 03 00 00       	and    $0x3ff,%eax
f01045e0:	6b c0 7c             	imul   $0x7c,%eax,%eax
f01045e3:	01 c8                	add    %ecx,%eax
f01045e5:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f01045e9:	75 09                	jne    f01045f4 <sched_yield+0x50>
                env_run(&envs[nextid]);
f01045eb:	83 ec 0c             	sub    $0xc,%esp
f01045ee:	50                   	push   %eax
f01045ef:	e8 0c f1 ff ff       	call   f0103700 <env_run>
f01045f4:	83 c2 01             	add    $0x1,%edx
	struct Env *now = thiscpu->cpu_env;
    int32_t startid = (now) ? ENVX(now->env_id): 0;
    int32_t nextid;
    size_t i;

    for(i = 0; i < NENV; i++) {
f01045f7:	39 da                	cmp    %ebx,%edx
f01045f9:	75 de                	jne    f01045d9 <sched_yield+0x35>
                env_run(&envs[nextid]);
                return;
            }
    }
    
    if(envs[startid].env_status == ENV_RUNNING && envs[startid].env_cpunum == cpunum()) {
f01045fb:	6b f6 7c             	imul   $0x7c,%esi,%esi
f01045fe:	01 f1                	add    %esi,%ecx
f0104600:	83 79 54 03          	cmpl   $0x3,0x54(%ecx)
f0104604:	75 1b                	jne    f0104621 <sched_yield+0x7d>
f0104606:	8b 59 5c             	mov    0x5c(%ecx),%ebx
f0104609:	e8 4c 17 00 00       	call   f0105d5a <cpunum>
f010460e:	39 c3                	cmp    %eax,%ebx
f0104610:	75 0f                	jne    f0104621 <sched_yield+0x7d>
        env_run(&envs[startid]);
f0104612:	83 ec 0c             	sub    $0xc,%esp
f0104615:	03 35 48 12 21 f0    	add    0xf0211248,%esi
f010461b:	56                   	push   %esi
f010461c:	e8 df f0 ff ff       	call   f0103700 <env_run>
    }

	// cprintf("[halt]\n");

	// sched_halt never returns
	sched_halt();
f0104621:	e8 aa fe ff ff       	call   f01044d0 <sched_halt>
}
f0104626:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104629:	5b                   	pop    %ebx
f010462a:	5e                   	pop    %esi
f010462b:	5d                   	pop    %ebp
f010462c:	c3                   	ret    

f010462d <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f010462d:	55                   	push   %ebp
f010462e:	89 e5                	mov    %esp,%ebp
f0104630:	57                   	push   %edi
f0104631:	56                   	push   %esi
f0104632:	53                   	push   %ebx
f0104633:	83 ec 1c             	sub    $0x1c,%esp
f0104636:	8b 45 08             	mov    0x8(%ebp),%eax
	// Return any appropriate return value.
	// LAB 3: Your code here.

	// panic("syscall not implemented");

	switch (syscallno) {
f0104639:	83 f8 0d             	cmp    $0xd,%eax
f010463c:	0f 87 57 05 00 00    	ja     f0104b99 <syscall+0x56c>
f0104642:	ff 24 85 2c 7d 10 f0 	jmp    *-0xfef82d4(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, 0);		// just check if PTE_U is set
f0104649:	e8 0c 17 00 00       	call   f0105d5a <cpunum>
f010464e:	6a 00                	push   $0x0
f0104650:	ff 75 10             	pushl  0x10(%ebp)
f0104653:	ff 75 0c             	pushl  0xc(%ebp)
f0104656:	6b c0 74             	imul   $0x74,%eax,%eax
f0104659:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f010465f:	e8 da e9 ff ff       	call   f010303e <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104664:	83 c4 0c             	add    $0xc,%esp
f0104667:	ff 75 0c             	pushl  0xc(%ebp)
f010466a:	ff 75 10             	pushl  0x10(%ebp)
f010466d:	68 26 7d 10 f0       	push   $0xf0107d26
f0104672:	e8 eb f2 ff ff       	call   f0103962 <cprintf>
f0104677:	83 c4 10             	add    $0x10,%esp
	// panic("syscall not implemented");

	switch (syscallno) {
		case SYS_cputs:
			sys_cputs((char *)a1, a2);
			return 0;
f010467a:	bb 00 00 00 00       	mov    $0x0,%ebx
f010467f:	e9 21 05 00 00       	jmp    f0104ba5 <syscall+0x578>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104684:	e8 69 bf ff ff       	call   f01005f2 <cons_getc>
f0104689:	89 c3                	mov    %eax,%ebx
	switch (syscallno) {
		case SYS_cputs:
			sys_cputs((char *)a1, a2);
			return 0;
		case SYS_cgetc:
			return sys_cgetc();
f010468b:	e9 15 05 00 00       	jmp    f0104ba5 <syscall+0x578>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104690:	e8 c5 16 00 00       	call   f0105d5a <cpunum>
f0104695:	6b c0 74             	imul   $0x74,%eax,%eax
f0104698:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f010469e:	8b 58 48             	mov    0x48(%eax),%ebx
			sys_cputs((char *)a1, a2);
			return 0;
		case SYS_cgetc:
			return sys_cgetc();
		case SYS_getenvid:
			return sys_getenvid();
f01046a1:	e9 ff 04 00 00       	jmp    f0104ba5 <syscall+0x578>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01046a6:	83 ec 04             	sub    $0x4,%esp
f01046a9:	6a 01                	push   $0x1
f01046ab:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01046ae:	50                   	push   %eax
f01046af:	ff 75 0c             	pushl  0xc(%ebp)
f01046b2:	e8 55 ea ff ff       	call   f010310c <envid2env>
f01046b7:	83 c4 10             	add    $0x10,%esp
		return r;
f01046ba:	89 c3                	mov    %eax,%ebx
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01046bc:	85 c0                	test   %eax,%eax
f01046be:	0f 88 e1 04 00 00    	js     f0104ba5 <syscall+0x578>
		return r;
	env_destroy(e);
f01046c4:	83 ec 0c             	sub    $0xc,%esp
f01046c7:	ff 75 e4             	pushl  -0x1c(%ebp)
f01046ca:	e8 92 ef ff ff       	call   f0103661 <env_destroy>
f01046cf:	83 c4 10             	add    $0x10,%esp
	return 0;
f01046d2:	bb 00 00 00 00       	mov    $0x0,%ebx
f01046d7:	e9 c9 04 00 00       	jmp    f0104ba5 <syscall+0x578>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f01046dc:	e8 c3 fe ff ff       	call   f01045a4 <sched_yield>
	// LAB 4: Your code here.
	// panic("sys_exofork not implemented");

	struct Env *newenv;

	int err = env_alloc(&newenv , curenv->env_id);
f01046e1:	e8 74 16 00 00       	call   f0105d5a <cpunum>
f01046e6:	83 ec 08             	sub    $0x8,%esp
f01046e9:	6b c0 74             	imul   $0x74,%eax,%eax
f01046ec:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01046f2:	ff 70 48             	pushl  0x48(%eax)
f01046f5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01046f8:	50                   	push   %eax
f01046f9:	e8 19 eb ff ff       	call   f0103217 <env_alloc>
	if (err < 0)
f01046fe:	83 c4 10             	add    $0x10,%esp
		return err;
f0104701:	89 c3                	mov    %eax,%ebx
	// panic("sys_exofork not implemented");

	struct Env *newenv;

	int err = env_alloc(&newenv , curenv->env_id);
	if (err < 0)
f0104703:	85 c0                	test   %eax,%eax
f0104705:	0f 88 9a 04 00 00    	js     f0104ba5 <syscall+0x578>
		return err;

	// memcpy(&newenv->env_tf, &curenv->env_tf, sizeof(struct Trapframe));
	newenv->env_tf = curenv->env_tf;
f010470b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010470e:	e8 47 16 00 00       	call   f0105d5a <cpunum>
f0104713:	6b c0 74             	imul   $0x74,%eax,%eax
f0104716:	8b b0 28 20 21 f0    	mov    -0xfdedfd8(%eax),%esi
f010471c:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104721:	89 df                	mov    %ebx,%edi
f0104723:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	newenv->env_status = ENV_NOT_RUNNABLE;
f0104725:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104728:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)

	// tweak newenv, to make it appear to return 0
	newenv->env_tf.tf_regs.reg_eax = 0;
f010472f:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

	return newenv->env_id;
f0104736:	8b 58 48             	mov    0x48(%eax),%ebx
f0104739:	e9 67 04 00 00       	jmp    f0104ba5 <syscall+0x578>

	// LAB 4: Your code here.
	// panic("sys_env_set_status not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
f010473e:	83 ec 04             	sub    $0x4,%esp
f0104741:	6a 01                	push   $0x1
f0104743:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104746:	50                   	push   %eax
f0104747:	ff 75 0c             	pushl  0xc(%ebp)
f010474a:	e8 bd e9 ff ff       	call   f010310c <envid2env>
	if (err < 0)
f010474f:	83 c4 10             	add    $0x10,%esp
f0104752:	85 c0                	test   %eax,%eax
f0104754:	78 20                	js     f0104776 <syscall+0x149>
		return err;

	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
f0104756:	8b 45 10             	mov    0x10(%ebp),%eax
f0104759:	83 e8 02             	sub    $0x2,%eax
f010475c:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f0104761:	75 1a                	jne    f010477d <syscall+0x150>
		return -E_INVAL;

	env_store->env_status = status;
f0104763:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104766:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104769:	89 48 54             	mov    %ecx,0x54(%eax)

	return 0;
f010476c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104771:	e9 2f 04 00 00       	jmp    f0104ba5 <syscall+0x578>
	// panic("sys_env_set_status not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
	if (err < 0)
		return err;
f0104776:	89 c3                	mov    %eax,%ebx
f0104778:	e9 28 04 00 00       	jmp    f0104ba5 <syscall+0x578>

	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
		return -E_INVAL;
f010477d:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			sys_yield();
			return 0;
		case SYS_exofork:
			return sys_exofork();
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1, a2);
f0104782:	e9 1e 04 00 00       	jmp    f0104ba5 <syscall+0x578>

	// LAB 4: Your code here.
	// panic("sys_page_alloc not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
f0104787:	83 ec 04             	sub    $0x4,%esp
f010478a:	6a 01                	push   $0x1
f010478c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010478f:	50                   	push   %eax
f0104790:	ff 75 0c             	pushl  0xc(%ebp)
f0104793:	e8 74 e9 ff ff       	call   f010310c <envid2env>
	if (err < 0)
f0104798:	83 c4 10             	add    $0x10,%esp
f010479b:	85 c0                	test   %eax,%eax
f010479d:	78 6b                	js     f010480a <syscall+0x1dd>
		return err;	// E_BAD_ENV

	if ((perm | PTE_AVAIL | PTE_W) != (PTE_AVAIL | PTE_W | PTE_U | PTE_P))
		return -E_INVAL;

	if ((uint32_t)va >= UTOP || ((uint32_t) va % PGSIZE) != 0)
f010479f:	8b 45 14             	mov    0x14(%ebp),%eax
f01047a2:	0d 02 0e 00 00       	or     $0xe02,%eax
f01047a7:	3d 07 0e 00 00       	cmp    $0xe07,%eax
f01047ac:	75 63                	jne    f0104811 <syscall+0x1e4>
f01047ae:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01047b5:	77 5a                	ja     f0104811 <syscall+0x1e4>
f01047b7:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01047be:	75 5b                	jne    f010481b <syscall+0x1ee>
		return -E_INVAL;
	
	struct PageInfo * pp = page_alloc(ALLOC_ZERO);
f01047c0:	83 ec 0c             	sub    $0xc,%esp
f01047c3:	6a 01                	push   $0x1
f01047c5:	e8 bd c8 ff ff       	call   f0101087 <page_alloc>
f01047ca:	89 c6                	mov    %eax,%esi
	if (pp == NULL)
f01047cc:	83 c4 10             	add    $0x10,%esp
f01047cf:	85 c0                	test   %eax,%eax
f01047d1:	74 52                	je     f0104825 <syscall+0x1f8>
		return -E_NO_MEM;
	
	err = page_insert(env_store->env_pgdir, pp, va, perm);
f01047d3:	ff 75 14             	pushl  0x14(%ebp)
f01047d6:	ff 75 10             	pushl  0x10(%ebp)
f01047d9:	50                   	push   %eax
f01047da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01047dd:	ff 70 60             	pushl  0x60(%eax)
f01047e0:	e8 95 cc ff ff       	call   f010147a <page_insert>
f01047e5:	89 c7                	mov    %eax,%edi
	if (err < 0) {
f01047e7:	83 c4 10             	add    $0x10,%esp
		page_free(pp);
		return err; // E_NO_MEM
	}

	return 0;
f01047ea:	bb 00 00 00 00       	mov    $0x0,%ebx
	struct PageInfo * pp = page_alloc(ALLOC_ZERO);
	if (pp == NULL)
		return -E_NO_MEM;
	
	err = page_insert(env_store->env_pgdir, pp, va, perm);
	if (err < 0) {
f01047ef:	85 c0                	test   %eax,%eax
f01047f1:	0f 89 ae 03 00 00    	jns    f0104ba5 <syscall+0x578>
		page_free(pp);
f01047f7:	83 ec 0c             	sub    $0xc,%esp
f01047fa:	56                   	push   %esi
f01047fb:	e8 f8 c8 ff ff       	call   f01010f8 <page_free>
f0104800:	83 c4 10             	add    $0x10,%esp
		return err; // E_NO_MEM
f0104803:	89 fb                	mov    %edi,%ebx
f0104805:	e9 9b 03 00 00       	jmp    f0104ba5 <syscall+0x578>
	// panic("sys_page_alloc not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
	if (err < 0)
		return err;	// E_BAD_ENV
f010480a:	89 c3                	mov    %eax,%ebx
f010480c:	e9 94 03 00 00       	jmp    f0104ba5 <syscall+0x578>

	if ((perm | PTE_AVAIL | PTE_W) != (PTE_AVAIL | PTE_W | PTE_U | PTE_P))
		return -E_INVAL;

	if ((uint32_t)va >= UTOP || ((uint32_t) va % PGSIZE) != 0)
		return -E_INVAL;
f0104811:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104816:	e9 8a 03 00 00       	jmp    f0104ba5 <syscall+0x578>
f010481b:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104820:	e9 80 03 00 00       	jmp    f0104ba5 <syscall+0x578>
	
	struct PageInfo * pp = page_alloc(ALLOC_ZERO);
	if (pp == NULL)
		return -E_NO_MEM;
f0104825:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f010482a:	e9 76 03 00 00       	jmp    f0104ba5 <syscall+0x578>
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	// panic("sys_page_map not implemented");

	if ((uint32_t)srcva >= UTOP || ((uint32_t)srcva % PGSIZE) != 0 || (uint32_t)dstva >= UTOP || ((uint32_t)dstva % PGSIZE != 0))
f010482f:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104836:	0f 87 c2 00 00 00    	ja     f01048fe <syscall+0x2d1>
f010483c:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104843:	0f 85 bf 00 00 00    	jne    f0104908 <syscall+0x2db>
f0104849:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104850:	0f 87 b2 00 00 00    	ja     f0104908 <syscall+0x2db>
f0104856:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f010485d:	0f 85 af 00 00 00    	jne    f0104912 <syscall+0x2e5>
		return -E_INVAL;
	
	struct Env *srcenv, *dstenv;
	int err = envid2env(srcenvid, &srcenv, 1);
f0104863:	83 ec 04             	sub    $0x4,%esp
f0104866:	6a 01                	push   $0x1
f0104868:	8d 45 dc             	lea    -0x24(%ebp),%eax
f010486b:	50                   	push   %eax
f010486c:	ff 75 0c             	pushl  0xc(%ebp)
f010486f:	e8 98 e8 ff ff       	call   f010310c <envid2env>
	if(err < 0)
f0104874:	83 c4 10             	add    $0x10,%esp
		return err;	// E_BAD_ENV
f0104877:	89 c3                	mov    %eax,%ebx
	if ((uint32_t)srcva >= UTOP || ((uint32_t)srcva % PGSIZE) != 0 || (uint32_t)dstva >= UTOP || ((uint32_t)dstva % PGSIZE != 0))
		return -E_INVAL;
	
	struct Env *srcenv, *dstenv;
	int err = envid2env(srcenvid, &srcenv, 1);
	if(err < 0)
f0104879:	85 c0                	test   %eax,%eax
f010487b:	0f 88 24 03 00 00    	js     f0104ba5 <syscall+0x578>
		return err;	// E_BAD_ENV
	err = envid2env(dstenvid, &dstenv, 1);
f0104881:	83 ec 04             	sub    $0x4,%esp
f0104884:	6a 01                	push   $0x1
f0104886:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104889:	50                   	push   %eax
f010488a:	ff 75 14             	pushl  0x14(%ebp)
f010488d:	e8 7a e8 ff ff       	call   f010310c <envid2env>
	if(err < 0)
f0104892:	83 c4 10             	add    $0x10,%esp
		return err;	// E_BAD_ENV
f0104895:	89 c3                	mov    %eax,%ebx
	struct Env *srcenv, *dstenv;
	int err = envid2env(srcenvid, &srcenv, 1);
	if(err < 0)
		return err;	// E_BAD_ENV
	err = envid2env(dstenvid, &dstenv, 1);
	if(err < 0)
f0104897:	85 c0                	test   %eax,%eax
f0104899:	0f 88 06 03 00 00    	js     f0104ba5 <syscall+0x578>
		return err;	// E_BAD_ENV

	pte_t *pte;
	struct PageInfo *pp = page_lookup(srcenv->env_pgdir, srcva, &pte);
f010489f:	83 ec 04             	sub    $0x4,%esp
f01048a2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01048a5:	50                   	push   %eax
f01048a6:	ff 75 10             	pushl  0x10(%ebp)
f01048a9:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01048ac:	ff 70 60             	pushl  0x60(%eax)
f01048af:	e8 de ca ff ff       	call   f0101392 <page_lookup>
	if (pp == NULL) 
f01048b4:	83 c4 10             	add    $0x10,%esp
f01048b7:	85 c0                	test   %eax,%eax
f01048b9:	74 61                	je     f010491c <syscall+0x2ef>
		return -E_INVAL;	// not mapped
	
	if ( ((*pte) & PTE_W) == 0 && (perm & PTE_W) != 0)
f01048bb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01048be:	f6 02 02             	testb  $0x2,(%edx)
f01048c1:	75 06                	jne    f01048c9 <syscall+0x29c>
f01048c3:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f01048c7:	75 5d                	jne    f0104926 <syscall+0x2f9>
		return -E_INVAL;	// read-only page

	// same perm restrictions as in sys_page_alloc
	if ((perm | PTE_AVAIL | PTE_W) != (PTE_AVAIL | PTE_W | PTE_U | PTE_P))
f01048c9:	8b 55 1c             	mov    0x1c(%ebp),%edx
f01048cc:	81 ca 02 0e 00 00    	or     $0xe02,%edx
f01048d2:	81 fa 07 0e 00 00    	cmp    $0xe07,%edx
f01048d8:	75 56                	jne    f0104930 <syscall+0x303>
		return -E_INVAL;

	err = page_insert(dstenv->env_pgdir, pp, dstva, perm);
f01048da:	ff 75 1c             	pushl  0x1c(%ebp)
f01048dd:	ff 75 18             	pushl  0x18(%ebp)
f01048e0:	50                   	push   %eax
f01048e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01048e4:	ff 70 60             	pushl  0x60(%eax)
f01048e7:	e8 8e cb ff ff       	call   f010147a <page_insert>
f01048ec:	83 c4 10             	add    $0x10,%esp
f01048ef:	85 c0                	test   %eax,%eax
f01048f1:	bb 00 00 00 00       	mov    $0x0,%ebx
f01048f6:	0f 4e d8             	cmovle %eax,%ebx
f01048f9:	e9 a7 02 00 00       	jmp    f0104ba5 <syscall+0x578>

	// LAB 4: Your code here.
	// panic("sys_page_map not implemented");

	if ((uint32_t)srcva >= UTOP || ((uint32_t)srcva % PGSIZE) != 0 || (uint32_t)dstva >= UTOP || ((uint32_t)dstva % PGSIZE != 0))
		return -E_INVAL;
f01048fe:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104903:	e9 9d 02 00 00       	jmp    f0104ba5 <syscall+0x578>
f0104908:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010490d:	e9 93 02 00 00       	jmp    f0104ba5 <syscall+0x578>
f0104912:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104917:	e9 89 02 00 00       	jmp    f0104ba5 <syscall+0x578>
		return err;	// E_BAD_ENV

	pte_t *pte;
	struct PageInfo *pp = page_lookup(srcenv->env_pgdir, srcva, &pte);
	if (pp == NULL) 
		return -E_INVAL;	// not mapped
f010491c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104921:	e9 7f 02 00 00       	jmp    f0104ba5 <syscall+0x578>
	
	if ( ((*pte) & PTE_W) == 0 && (perm & PTE_W) != 0)
		return -E_INVAL;	// read-only page
f0104926:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010492b:	e9 75 02 00 00       	jmp    f0104ba5 <syscall+0x578>

	// same perm restrictions as in sys_page_alloc
	if ((perm | PTE_AVAIL | PTE_W) != (PTE_AVAIL | PTE_W | PTE_U | PTE_P))
		return -E_INVAL;
f0104930:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1, a2);
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1, (void *)a2, a3);
		case SYS_page_map:
			return sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4, a5);
f0104935:	e9 6b 02 00 00       	jmp    f0104ba5 <syscall+0x578>
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	// panic("sys_page_unmap not implemented");

	if ((uint32_t)va >= UTOP || ((uint32_t) va % PGSIZE) != 0)
f010493a:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104941:	77 45                	ja     f0104988 <syscall+0x35b>
f0104943:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010494a:	75 46                	jne    f0104992 <syscall+0x365>
		return -E_INVAL;

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
f010494c:	83 ec 04             	sub    $0x4,%esp
f010494f:	6a 01                	push   $0x1
f0104951:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104954:	50                   	push   %eax
f0104955:	ff 75 0c             	pushl  0xc(%ebp)
f0104958:	e8 af e7 ff ff       	call   f010310c <envid2env>
	if (err < 0)
f010495d:	83 c4 10             	add    $0x10,%esp
		return err;	// E_BAD_ENV
f0104960:	89 c3                	mov    %eax,%ebx
	if ((uint32_t)va >= UTOP || ((uint32_t) va % PGSIZE) != 0)
		return -E_INVAL;

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
	if (err < 0)
f0104962:	85 c0                	test   %eax,%eax
f0104964:	0f 88 3b 02 00 00    	js     f0104ba5 <syscall+0x578>
		return err;	// E_BAD_ENV

	page_remove(env_store->env_pgdir, va);
f010496a:	83 ec 08             	sub    $0x8,%esp
f010496d:	ff 75 10             	pushl  0x10(%ebp)
f0104970:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104973:	ff 70 60             	pushl  0x60(%eax)
f0104976:	e8 b2 ca ff ff       	call   f010142d <page_remove>
f010497b:	83 c4 10             	add    $0x10,%esp

	return 0;
f010497e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104983:	e9 1d 02 00 00       	jmp    f0104ba5 <syscall+0x578>

	// LAB 4: Your code here.
	// panic("sys_page_unmap not implemented");

	if ((uint32_t)va >= UTOP || ((uint32_t) va % PGSIZE) != 0)
		return -E_INVAL;
f0104988:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010498d:	e9 13 02 00 00       	jmp    f0104ba5 <syscall+0x578>
f0104992:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104997:	e9 09 02 00 00       	jmp    f0104ba5 <syscall+0x578>
{
	// LAB 4: Your code here.
	// panic("sys_env_set_pgfault_upcall not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
f010499c:	83 ec 04             	sub    $0x4,%esp
f010499f:	6a 01                	push   $0x1
f01049a1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01049a4:	50                   	push   %eax
f01049a5:	ff 75 0c             	pushl  0xc(%ebp)
f01049a8:	e8 5f e7 ff ff       	call   f010310c <envid2env>
	if (err < 0)
f01049ad:	83 c4 10             	add    $0x10,%esp
f01049b0:	85 c0                	test   %eax,%eax
f01049b2:	78 13                	js     f01049c7 <syscall+0x39a>
		return err;

	env_store->env_pgfault_upcall = func;
f01049b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01049b7:	8b 55 10             	mov    0x10(%ebp),%edx
f01049ba:	89 50 64             	mov    %edx,0x64(%eax)

	return 0;
f01049bd:	bb 00 00 00 00       	mov    $0x0,%ebx
f01049c2:	e9 de 01 00 00       	jmp    f0104ba5 <syscall+0x578>
	// panic("sys_env_set_pgfault_upcall not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
	if (err < 0)
		return err;
f01049c7:	89 c3                	mov    %eax,%ebx
		case SYS_page_map:
			return sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4, a5);
		case SYS_page_unmap:
			return sys_page_unmap((envid_t)a1, (void *)a2);
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
f01049c9:	e9 d7 01 00 00       	jmp    f0104ba5 <syscall+0x578>
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	// panic("sys_ipc_recv not implemented");

	if ((uint32_t)dstva < UTOP) {
f01049ce:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f01049d5:	77 21                	ja     f01049f8 <syscall+0x3cb>
		if ((uint32_t)dstva % PGSIZE != 0)
f01049d7:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f01049de:	0f 85 bc 01 00 00    	jne    f0104ba0 <syscall+0x573>
			return -E_INVAL;
		curenv->env_ipc_dstva = dstva;
f01049e4:	e8 71 13 00 00       	call   f0105d5a <cpunum>
f01049e9:	6b c0 74             	imul   $0x74,%eax,%eax
f01049ec:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01049f2:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01049f5:	89 78 6c             	mov    %edi,0x6c(%eax)
	}

	// set recving flags
	curenv->env_ipc_recving = true;
f01049f8:	e8 5d 13 00 00       	call   f0105d5a <cpunum>
f01049fd:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a00:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104a06:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_from = 0;
f0104a0a:	e8 4b 13 00 00       	call   f0105d5a <cpunum>
f0104a0f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a12:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104a18:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)

	// mark yourself not runnable, and then give up the CPU.
	curenv->env_status = ENV_NOT_RUNNABLE;
f0104a1f:	e8 36 13 00 00       	call   f0105d5a <cpunum>
f0104a24:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a27:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104a2d:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	sched_yield();
f0104a34:	e8 6b fb ff ff       	call   f01045a4 <sched_yield>
{
	// LAB 4: Your code here.
	// panic("sys_ipc_try_send not implemented");

	struct Env *env;
	int err = envid2env(envid, &env, 0);
f0104a39:	83 ec 04             	sub    $0x4,%esp
f0104a3c:	6a 00                	push   $0x0
f0104a3e:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104a41:	50                   	push   %eax
f0104a42:	ff 75 0c             	pushl  0xc(%ebp)
f0104a45:	e8 c2 e6 ff ff       	call   f010310c <envid2env>
	if(err < 0)
f0104a4a:	83 c4 10             	add    $0x10,%esp
f0104a4d:	85 c0                	test   %eax,%eax
f0104a4f:	0f 88 02 01 00 00    	js     f0104b57 <syscall+0x52a>
		return err;	// E_BAD_ENV
	
	// not recving, or already recving
	if (env->env_ipc_recving != true || env->env_ipc_from != 0)
f0104a55:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104a58:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0104a5c:	0f 84 f9 00 00 00    	je     f0104b5b <syscall+0x52e>
f0104a62:	8b 58 74             	mov    0x74(%eax),%ebx
f0104a65:	85 db                	test   %ebx,%ebx
f0104a67:	0f 85 f5 00 00 00    	jne    f0104b62 <syscall+0x535>

	// first check if the recver is willing to recv a page
	// any error happens, fall fast
	if (env->env_ipc_dstva != 0) {
		
		if ((uint32_t)srcva < UTOP) {
f0104a6d:	83 78 6c 00          	cmpl   $0x0,0x6c(%eax)
f0104a71:	0f 84 ac 00 00 00    	je     f0104b23 <syscall+0x4f6>
f0104a77:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104a7e:	0f 87 9f 00 00 00    	ja     f0104b23 <syscall+0x4f6>
			if ((uint32_t)srcva % PGSIZE != 0)
f0104a84:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0104a8b:	75 64                	jne    f0104af1 <syscall+0x4c4>
				return -E_INVAL;
			if ((perm & (PTE_P | PTE_U)) != (PTE_P | PTE_U))
f0104a8d:	8b 45 18             	mov    0x18(%ebp),%eax
f0104a90:	83 e0 05             	and    $0x5,%eax
f0104a93:	83 f8 05             	cmp    $0x5,%eax
f0104a96:	75 63                	jne    f0104afb <syscall+0x4ce>
            	return -E_INVAL;

			pte_t *pte;
			struct PageInfo *pp = page_lookup(curenv->env_pgdir, srcva, &pte);
f0104a98:	e8 bd 12 00 00       	call   f0105d5a <cpunum>
f0104a9d:	83 ec 04             	sub    $0x4,%esp
f0104aa0:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104aa3:	52                   	push   %edx
f0104aa4:	ff 75 14             	pushl  0x14(%ebp)
f0104aa7:	6b c0 74             	imul   $0x74,%eax,%eax
f0104aaa:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104ab0:	ff 70 60             	pushl  0x60(%eax)
f0104ab3:	e8 da c8 ff ff       	call   f0101392 <page_lookup>
			if (!pp) 
f0104ab8:	83 c4 10             	add    $0x10,%esp
f0104abb:	85 c0                	test   %eax,%eax
f0104abd:	74 46                	je     f0104b05 <syscall+0x4d8>
				return -E_INVAL;  
			
			if ((perm & PTE_W) && ((size_t) *pte & PTE_W) != PTE_W) 
f0104abf:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104ac3:	74 08                	je     f0104acd <syscall+0x4a0>
f0104ac5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104ac8:	f6 02 02             	testb  $0x2,(%edx)
f0104acb:	74 42                	je     f0104b0f <syscall+0x4e2>
				return -E_INVAL;

			if (page_insert(env->env_pgdir, pp, env->env_ipc_dstva, perm) < 0) 
f0104acd:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104ad0:	ff 75 18             	pushl  0x18(%ebp)
f0104ad3:	ff 72 6c             	pushl  0x6c(%edx)
f0104ad6:	50                   	push   %eax
f0104ad7:	ff 72 60             	pushl  0x60(%edx)
f0104ada:	e8 9b c9 ff ff       	call   f010147a <page_insert>
f0104adf:	83 c4 10             	add    $0x10,%esp
f0104ae2:	85 c0                	test   %eax,%eax
f0104ae4:	78 33                	js     f0104b19 <syscall+0x4ec>
				return -E_NO_MEM;
			
			env->env_ipc_perm = perm;
f0104ae6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104ae9:	8b 7d 18             	mov    0x18(%ebp),%edi
f0104aec:	89 78 78             	mov    %edi,0x78(%eax)
f0104aef:	eb 32                	jmp    f0104b23 <syscall+0x4f6>
	// any error happens, fall fast
	if (env->env_ipc_dstva != 0) {
		
		if ((uint32_t)srcva < UTOP) {
			if ((uint32_t)srcva % PGSIZE != 0)
				return -E_INVAL;
f0104af1:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104af6:	e9 aa 00 00 00       	jmp    f0104ba5 <syscall+0x578>
			if ((perm & (PTE_P | PTE_U)) != (PTE_P | PTE_U))
            	return -E_INVAL;
f0104afb:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b00:	e9 a0 00 00 00       	jmp    f0104ba5 <syscall+0x578>

			pte_t *pte;
			struct PageInfo *pp = page_lookup(curenv->env_pgdir, srcva, &pte);
			if (!pp) 
				return -E_INVAL;  
f0104b05:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b0a:	e9 96 00 00 00       	jmp    f0104ba5 <syscall+0x578>
			
			if ((perm & PTE_W) && ((size_t) *pte & PTE_W) != PTE_W) 
				return -E_INVAL;
f0104b0f:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b14:	e9 8c 00 00 00       	jmp    f0104ba5 <syscall+0x578>

			if (page_insert(env->env_pgdir, pp, env->env_ipc_dstva, perm) < 0) 
				return -E_NO_MEM;
f0104b19:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f0104b1e:	e9 82 00 00 00       	jmp    f0104ba5 <syscall+0x578>
			env->env_ipc_perm = perm;
		}

	}

	env->env_ipc_from = curenv->env_id;
f0104b23:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104b26:	e8 2f 12 00 00       	call   f0105d5a <cpunum>
f0104b2b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b2e:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104b34:	8b 40 48             	mov    0x48(%eax),%eax
f0104b37:	89 46 74             	mov    %eax,0x74(%esi)
	env->env_ipc_recving = false;
f0104b3a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b3d:	c6 40 68 00          	movb   $0x0,0x68(%eax)
	env->env_ipc_value = value;
f0104b41:	8b 55 10             	mov    0x10(%ebp),%edx
f0104b44:	89 50 70             	mov    %edx,0x70(%eax)
	env->env_status = ENV_RUNNABLE;
f0104b47:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)

	// make the recver return 0
	env->env_tf.tf_regs.reg_eax = 0;
f0104b4e:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
f0104b55:	eb 4e                	jmp    f0104ba5 <syscall+0x578>
	// panic("sys_ipc_try_send not implemented");

	struct Env *env;
	int err = envid2env(envid, &env, 0);
	if(err < 0)
		return err;	// E_BAD_ENV
f0104b57:	89 c3                	mov    %eax,%ebx
f0104b59:	eb 4a                	jmp    f0104ba5 <syscall+0x578>
	
	// not recving, or already recving
	if (env->env_ipc_recving != true || env->env_ipc_from != 0)
		return -E_IPC_NOT_RECV;
f0104b5b:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f0104b60:	eb 43                	jmp    f0104ba5 <syscall+0x578>
f0104b62:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
		case SYS_ipc_recv:
			return sys_ipc_recv((void *)a1);
		case SYS_ipc_try_send:
			return sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned)a4);
f0104b67:	eb 3c                	jmp    f0104ba5 <syscall+0x578>
		case SYS_env_set_trapframe:
			return sys_env_set_trapframe((envid_t)a1, (struct Trapframe *)a2);
f0104b69:	8b 75 10             	mov    0x10(%ebp),%esi
	// Remember to check whether the user has supplied us with a good
	// address!
	// panic("sys_env_set_trapframe not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
f0104b6c:	83 ec 04             	sub    $0x4,%esp
f0104b6f:	6a 01                	push   $0x1
f0104b71:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104b74:	50                   	push   %eax
f0104b75:	ff 75 0c             	pushl  0xc(%ebp)
f0104b78:	e8 8f e5 ff ff       	call   f010310c <envid2env>
	if (err < 0)
f0104b7d:	83 c4 10             	add    $0x10,%esp
f0104b80:	85 c0                	test   %eax,%eax
f0104b82:	78 11                	js     f0104b95 <syscall+0x568>
		return err;
	
	env_store->env_tf = *tf;
f0104b84:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104b89:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104b8c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

	return 0;
f0104b8e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104b93:	eb 10                	jmp    f0104ba5 <syscall+0x578>
	// panic("sys_env_set_trapframe not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
	if (err < 0)
		return err;
f0104b95:	89 c3                	mov    %eax,%ebx
		case SYS_ipc_recv:
			return sys_ipc_recv((void *)a1);
		case SYS_ipc_try_send:
			return sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned)a4);
		case SYS_env_set_trapframe:
			return sys_env_set_trapframe((envid_t)a1, (struct Trapframe *)a2);
f0104b97:	eb 0c                	jmp    f0104ba5 <syscall+0x578>
		default:
			return -E_INVAL;
f0104b99:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b9e:	eb 05                	jmp    f0104ba5 <syscall+0x578>
		case SYS_page_unmap:
			return sys_page_unmap((envid_t)a1, (void *)a2);
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
		case SYS_ipc_recv:
			return sys_ipc_recv((void *)a1);
f0104ba0:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		case SYS_env_set_trapframe:
			return sys_env_set_trapframe((envid_t)a1, (struct Trapframe *)a2);
		default:
			return -E_INVAL;
	}
}
f0104ba5:	89 d8                	mov    %ebx,%eax
f0104ba7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104baa:	5b                   	pop    %ebx
f0104bab:	5e                   	pop    %esi
f0104bac:	5f                   	pop    %edi
f0104bad:	5d                   	pop    %ebp
f0104bae:	c3                   	ret    

f0104baf <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104baf:	55                   	push   %ebp
f0104bb0:	89 e5                	mov    %esp,%ebp
f0104bb2:	57                   	push   %edi
f0104bb3:	56                   	push   %esi
f0104bb4:	53                   	push   %ebx
f0104bb5:	83 ec 14             	sub    $0x14,%esp
f0104bb8:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104bbb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104bbe:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104bc1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104bc4:	8b 1a                	mov    (%edx),%ebx
f0104bc6:	8b 01                	mov    (%ecx),%eax
f0104bc8:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104bcb:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104bd2:	eb 7f                	jmp    f0104c53 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0104bd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104bd7:	01 d8                	add    %ebx,%eax
f0104bd9:	89 c6                	mov    %eax,%esi
f0104bdb:	c1 ee 1f             	shr    $0x1f,%esi
f0104bde:	01 c6                	add    %eax,%esi
f0104be0:	d1 fe                	sar    %esi
f0104be2:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0104be5:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104be8:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104beb:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104bed:	eb 03                	jmp    f0104bf2 <stab_binsearch+0x43>
			m--;
f0104bef:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104bf2:	39 c3                	cmp    %eax,%ebx
f0104bf4:	7f 0d                	jg     f0104c03 <stab_binsearch+0x54>
f0104bf6:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104bfa:	83 ea 0c             	sub    $0xc,%edx
f0104bfd:	39 f9                	cmp    %edi,%ecx
f0104bff:	75 ee                	jne    f0104bef <stab_binsearch+0x40>
f0104c01:	eb 05                	jmp    f0104c08 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104c03:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0104c06:	eb 4b                	jmp    f0104c53 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104c08:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104c0b:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104c0e:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104c12:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104c15:	76 11                	jbe    f0104c28 <stab_binsearch+0x79>
			*region_left = m;
f0104c17:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104c1a:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104c1c:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104c1f:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104c26:	eb 2b                	jmp    f0104c53 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104c28:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104c2b:	73 14                	jae    f0104c41 <stab_binsearch+0x92>
			*region_right = m - 1;
f0104c2d:	83 e8 01             	sub    $0x1,%eax
f0104c30:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104c33:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104c36:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104c38:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104c3f:	eb 12                	jmp    f0104c53 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104c41:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104c44:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0104c46:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104c4a:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104c4c:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104c53:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104c56:	0f 8e 78 ff ff ff    	jle    f0104bd4 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104c5c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104c60:	75 0f                	jne    f0104c71 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0104c62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104c65:	8b 00                	mov    (%eax),%eax
f0104c67:	83 e8 01             	sub    $0x1,%eax
f0104c6a:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104c6d:	89 06                	mov    %eax,(%esi)
f0104c6f:	eb 2c                	jmp    f0104c9d <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104c71:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104c74:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104c76:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104c79:	8b 0e                	mov    (%esi),%ecx
f0104c7b:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104c7e:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104c81:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104c84:	eb 03                	jmp    f0104c89 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0104c86:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104c89:	39 c8                	cmp    %ecx,%eax
f0104c8b:	7e 0b                	jle    f0104c98 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0104c8d:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0104c91:	83 ea 0c             	sub    $0xc,%edx
f0104c94:	39 df                	cmp    %ebx,%edi
f0104c96:	75 ee                	jne    f0104c86 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0104c98:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104c9b:	89 06                	mov    %eax,(%esi)
	}
}
f0104c9d:	83 c4 14             	add    $0x14,%esp
f0104ca0:	5b                   	pop    %ebx
f0104ca1:	5e                   	pop    %esi
f0104ca2:	5f                   	pop    %edi
f0104ca3:	5d                   	pop    %ebp
f0104ca4:	c3                   	ret    

f0104ca5 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104ca5:	55                   	push   %ebp
f0104ca6:	89 e5                	mov    %esp,%ebp
f0104ca8:	57                   	push   %edi
f0104ca9:	56                   	push   %esi
f0104caa:	53                   	push   %ebx
f0104cab:	83 ec 3c             	sub    $0x3c,%esp
f0104cae:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104cb1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104cb4:	c7 03 64 7d 10 f0    	movl   $0xf0107d64,(%ebx)
	info->eip_line = 0;
f0104cba:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104cc1:	c7 43 08 64 7d 10 f0 	movl   $0xf0107d64,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104cc8:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104ccf:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104cd2:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104cd9:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0104cdf:	0f 87 a3 00 00 00    	ja     f0104d88 <debuginfo_eip+0xe3>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0104ce5:	a1 00 00 20 00       	mov    0x200000,%eax
f0104cea:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stab_end = usd->stab_end;
f0104ced:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f0104cf3:	8b 15 08 00 20 00    	mov    0x200008,%edx
f0104cf9:	89 55 b8             	mov    %edx,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f0104cfc:	a1 0c 00 20 00       	mov    0x20000c,%eax
f0104d01:	89 45 bc             	mov    %eax,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0 ||
f0104d04:	e8 51 10 00 00       	call   f0105d5a <cpunum>
f0104d09:	6a 04                	push   $0x4
f0104d0b:	6a 10                	push   $0x10
f0104d0d:	68 00 00 20 00       	push   $0x200000
f0104d12:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d15:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0104d1b:	e8 36 e2 ff ff       	call   f0102f56 <user_mem_check>
f0104d20:	83 c4 10             	add    $0x10,%esp
f0104d23:	85 c0                	test   %eax,%eax
f0104d25:	0f 88 27 02 00 00    	js     f0104f52 <debuginfo_eip+0x2ad>
			user_mem_check(curenv, stabs, stab_end-stabs, PTE_U) < 0 ||
f0104d2b:	e8 2a 10 00 00       	call   f0105d5a <cpunum>
f0104d30:	6a 04                	push   $0x4
f0104d32:	89 f2                	mov    %esi,%edx
f0104d34:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104d37:	29 ca                	sub    %ecx,%edx
f0104d39:	c1 fa 02             	sar    $0x2,%edx
f0104d3c:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0104d42:	52                   	push   %edx
f0104d43:	51                   	push   %ecx
f0104d44:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d47:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0104d4d:	e8 04 e2 ff ff       	call   f0102f56 <user_mem_check>
		stabstr = usd->stabstr;
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0 ||
f0104d52:	83 c4 10             	add    $0x10,%esp
f0104d55:	85 c0                	test   %eax,%eax
f0104d57:	0f 88 fc 01 00 00    	js     f0104f59 <debuginfo_eip+0x2b4>
			user_mem_check(curenv, stabs, stab_end-stabs, PTE_U) < 0 ||
			user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U) < 0
f0104d5d:	e8 f8 0f 00 00       	call   f0105d5a <cpunum>
f0104d62:	6a 04                	push   $0x4
f0104d64:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0104d67:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0104d6a:	29 ca                	sub    %ecx,%edx
f0104d6c:	52                   	push   %edx
f0104d6d:	51                   	push   %ecx
f0104d6e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d71:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0104d77:	e8 da e1 ff ff       	call   f0102f56 <user_mem_check>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0 ||
			user_mem_check(curenv, stabs, stab_end-stabs, PTE_U) < 0 ||
f0104d7c:	83 c4 10             	add    $0x10,%esp
f0104d7f:	85 c0                	test   %eax,%eax
f0104d81:	79 1f                	jns    f0104da2 <debuginfo_eip+0xfd>
f0104d83:	e9 d8 01 00 00       	jmp    f0104f60 <debuginfo_eip+0x2bb>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104d88:	c7 45 bc ac 5f 11 f0 	movl   $0xf0115fac,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0104d8f:	c7 45 b8 11 28 11 f0 	movl   $0xf0112811,-0x48(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0104d96:	be 10 28 11 f0       	mov    $0xf0112810,%esi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104d9b:	c7 45 c0 10 83 10 f0 	movl   $0xf0108310,-0x40(%ebp)
		)
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104da2:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104da5:	39 45 b8             	cmp    %eax,-0x48(%ebp)
f0104da8:	0f 83 b9 01 00 00    	jae    f0104f67 <debuginfo_eip+0x2c2>
f0104dae:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0104db2:	0f 85 b6 01 00 00    	jne    f0104f6e <debuginfo_eip+0x2c9>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104db8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104dbf:	2b 75 c0             	sub    -0x40(%ebp),%esi
f0104dc2:	c1 fe 02             	sar    $0x2,%esi
f0104dc5:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f0104dcb:	83 e8 01             	sub    $0x1,%eax
f0104dce:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104dd1:	83 ec 08             	sub    $0x8,%esp
f0104dd4:	57                   	push   %edi
f0104dd5:	6a 64                	push   $0x64
f0104dd7:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0104dda:	89 d1                	mov    %edx,%ecx
f0104ddc:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104ddf:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0104de2:	89 f0                	mov    %esi,%eax
f0104de4:	e8 c6 fd ff ff       	call   f0104baf <stab_binsearch>
	if (lfile == 0)
f0104de9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104dec:	83 c4 10             	add    $0x10,%esp
f0104def:	85 c0                	test   %eax,%eax
f0104df1:	0f 84 7e 01 00 00    	je     f0104f75 <debuginfo_eip+0x2d0>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104df7:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104dfa:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104dfd:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104e00:	83 ec 08             	sub    $0x8,%esp
f0104e03:	57                   	push   %edi
f0104e04:	6a 24                	push   $0x24
f0104e06:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0104e09:	89 d1                	mov    %edx,%ecx
f0104e0b:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104e0e:	89 f0                	mov    %esi,%eax
f0104e10:	e8 9a fd ff ff       	call   f0104baf <stab_binsearch>

	if (lfun <= rfun) {
f0104e15:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104e18:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104e1b:	83 c4 10             	add    $0x10,%esp
f0104e1e:	39 d0                	cmp    %edx,%eax
f0104e20:	7f 2e                	jg     f0104e50 <debuginfo_eip+0x1ab>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104e22:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0104e25:	8d 34 8e             	lea    (%esi,%ecx,4),%esi
f0104e28:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f0104e2b:	8b 36                	mov    (%esi),%esi
f0104e2d:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0104e30:	2b 4d b8             	sub    -0x48(%ebp),%ecx
f0104e33:	39 ce                	cmp    %ecx,%esi
f0104e35:	73 06                	jae    f0104e3d <debuginfo_eip+0x198>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104e37:	03 75 b8             	add    -0x48(%ebp),%esi
f0104e3a:	89 73 08             	mov    %esi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104e3d:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0104e40:	8b 4e 08             	mov    0x8(%esi),%ecx
f0104e43:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0104e46:	29 cf                	sub    %ecx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0104e48:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104e4b:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0104e4e:	eb 0f                	jmp    f0104e5f <debuginfo_eip+0x1ba>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104e50:	89 7b 10             	mov    %edi,0x10(%ebx)
		lline = lfile;
f0104e53:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e56:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104e59:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104e5c:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104e5f:	83 ec 08             	sub    $0x8,%esp
f0104e62:	6a 3a                	push   $0x3a
f0104e64:	ff 73 08             	pushl  0x8(%ebx)
f0104e67:	e8 af 08 00 00       	call   f010571b <strfind>
f0104e6c:	2b 43 08             	sub    0x8(%ebx),%eax
f0104e6f:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.


	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104e72:	83 c4 08             	add    $0x8,%esp
f0104e75:	57                   	push   %edi
f0104e76:	6a 44                	push   $0x44
f0104e78:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104e7b:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104e7e:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0104e81:	89 f0                	mov    %esi,%eax
f0104e83:	e8 27 fd ff ff       	call   f0104baf <stab_binsearch>
	if (lline == 0)
f0104e88:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0104e8b:	83 c4 10             	add    $0x10,%esp
f0104e8e:	85 d2                	test   %edx,%edx
f0104e90:	0f 84 e6 00 00 00    	je     f0104f7c <debuginfo_eip+0x2d7>
		return -1;
	// cprintf("[+] %d, %d, %d, %x\n", lline, rline, lfun, stabs[lfun].n_value);
	info->eip_line = stabs[rline].n_desc;
f0104e96:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104e99:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104e9c:	0f b7 44 86 06       	movzwl 0x6(%esi,%eax,4),%eax
f0104ea1:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104ea4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104ea7:	89 d0                	mov    %edx,%eax
f0104ea9:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104eac:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0104eaf:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0104eb3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104eb6:	eb 0a                	jmp    f0104ec2 <debuginfo_eip+0x21d>
f0104eb8:	83 e8 01             	sub    $0x1,%eax
f0104ebb:	83 ea 0c             	sub    $0xc,%edx
f0104ebe:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0104ec2:	39 c7                	cmp    %eax,%edi
f0104ec4:	7e 05                	jle    f0104ecb <debuginfo_eip+0x226>
f0104ec6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104ec9:	eb 47                	jmp    f0104f12 <debuginfo_eip+0x26d>
	       && stabs[lline].n_type != N_SOL
f0104ecb:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104ecf:	80 f9 84             	cmp    $0x84,%cl
f0104ed2:	75 0e                	jne    f0104ee2 <debuginfo_eip+0x23d>
f0104ed4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104ed7:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104edb:	74 1c                	je     f0104ef9 <debuginfo_eip+0x254>
f0104edd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104ee0:	eb 17                	jmp    f0104ef9 <debuginfo_eip+0x254>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104ee2:	80 f9 64             	cmp    $0x64,%cl
f0104ee5:	75 d1                	jne    f0104eb8 <debuginfo_eip+0x213>
f0104ee7:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0104eeb:	74 cb                	je     f0104eb8 <debuginfo_eip+0x213>
f0104eed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104ef0:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104ef4:	74 03                	je     f0104ef9 <debuginfo_eip+0x254>
f0104ef6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104ef9:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104efc:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104eff:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0104f02:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104f05:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0104f08:	29 f8                	sub    %edi,%eax
f0104f0a:	39 c2                	cmp    %eax,%edx
f0104f0c:	73 04                	jae    f0104f12 <debuginfo_eip+0x26d>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104f0e:	01 fa                	add    %edi,%edx
f0104f10:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104f12:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104f15:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104f18:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104f1d:	39 f2                	cmp    %esi,%edx
f0104f1f:	7d 67                	jge    f0104f88 <debuginfo_eip+0x2e3>
		for (lline = lfun + 1;
f0104f21:	83 c2 01             	add    $0x1,%edx
f0104f24:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104f27:	89 d0                	mov    %edx,%eax
f0104f29:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104f2c:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104f2f:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0104f32:	eb 04                	jmp    f0104f38 <debuginfo_eip+0x293>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104f34:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104f38:	39 c6                	cmp    %eax,%esi
f0104f3a:	7e 47                	jle    f0104f83 <debuginfo_eip+0x2de>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104f3c:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104f40:	83 c0 01             	add    $0x1,%eax
f0104f43:	83 c2 0c             	add    $0xc,%edx
f0104f46:	80 f9 a0             	cmp    $0xa0,%cl
f0104f49:	74 e9                	je     f0104f34 <debuginfo_eip+0x28f>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104f4b:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f50:	eb 36                	jmp    f0104f88 <debuginfo_eip+0x2e3>
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0 ||
			user_mem_check(curenv, stabs, stab_end-stabs, PTE_U) < 0 ||
			user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U) < 0
		)
			return -1;
f0104f52:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f57:	eb 2f                	jmp    f0104f88 <debuginfo_eip+0x2e3>
f0104f59:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f5e:	eb 28                	jmp    f0104f88 <debuginfo_eip+0x2e3>
f0104f60:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f65:	eb 21                	jmp    f0104f88 <debuginfo_eip+0x2e3>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104f67:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f6c:	eb 1a                	jmp    f0104f88 <debuginfo_eip+0x2e3>
f0104f6e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f73:	eb 13                	jmp    f0104f88 <debuginfo_eip+0x2e3>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0104f75:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f7a:	eb 0c                	jmp    f0104f88 <debuginfo_eip+0x2e3>
	// Your code here.


	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline == 0)
		return -1;
f0104f7c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f81:	eb 05                	jmp    f0104f88 <debuginfo_eip+0x2e3>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104f83:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104f88:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104f8b:	5b                   	pop    %ebx
f0104f8c:	5e                   	pop    %esi
f0104f8d:	5f                   	pop    %edi
f0104f8e:	5d                   	pop    %ebp
f0104f8f:	c3                   	ret    

f0104f90 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104f90:	55                   	push   %ebp
f0104f91:	89 e5                	mov    %esp,%ebp
f0104f93:	57                   	push   %edi
f0104f94:	56                   	push   %esi
f0104f95:	53                   	push   %ebx
f0104f96:	83 ec 1c             	sub    $0x1c,%esp
f0104f99:	89 c7                	mov    %eax,%edi
f0104f9b:	89 d6                	mov    %edx,%esi
f0104f9d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104fa0:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104fa3:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104fa6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104fa9:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104fac:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104fb1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104fb4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104fb7:	39 d3                	cmp    %edx,%ebx
f0104fb9:	72 05                	jb     f0104fc0 <printnum+0x30>
f0104fbb:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104fbe:	77 45                	ja     f0105005 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104fc0:	83 ec 0c             	sub    $0xc,%esp
f0104fc3:	ff 75 18             	pushl  0x18(%ebp)
f0104fc6:	8b 45 14             	mov    0x14(%ebp),%eax
f0104fc9:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0104fcc:	53                   	push   %ebx
f0104fcd:	ff 75 10             	pushl  0x10(%ebp)
f0104fd0:	83 ec 08             	sub    $0x8,%esp
f0104fd3:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104fd6:	ff 75 e0             	pushl  -0x20(%ebp)
f0104fd9:	ff 75 dc             	pushl  -0x24(%ebp)
f0104fdc:	ff 75 d8             	pushl  -0x28(%ebp)
f0104fdf:	e8 7c 11 00 00       	call   f0106160 <__udivdi3>
f0104fe4:	83 c4 18             	add    $0x18,%esp
f0104fe7:	52                   	push   %edx
f0104fe8:	50                   	push   %eax
f0104fe9:	89 f2                	mov    %esi,%edx
f0104feb:	89 f8                	mov    %edi,%eax
f0104fed:	e8 9e ff ff ff       	call   f0104f90 <printnum>
f0104ff2:	83 c4 20             	add    $0x20,%esp
f0104ff5:	eb 18                	jmp    f010500f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104ff7:	83 ec 08             	sub    $0x8,%esp
f0104ffa:	56                   	push   %esi
f0104ffb:	ff 75 18             	pushl  0x18(%ebp)
f0104ffe:	ff d7                	call   *%edi
f0105000:	83 c4 10             	add    $0x10,%esp
f0105003:	eb 03                	jmp    f0105008 <printnum+0x78>
f0105005:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0105008:	83 eb 01             	sub    $0x1,%ebx
f010500b:	85 db                	test   %ebx,%ebx
f010500d:	7f e8                	jg     f0104ff7 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010500f:	83 ec 08             	sub    $0x8,%esp
f0105012:	56                   	push   %esi
f0105013:	83 ec 04             	sub    $0x4,%esp
f0105016:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105019:	ff 75 e0             	pushl  -0x20(%ebp)
f010501c:	ff 75 dc             	pushl  -0x24(%ebp)
f010501f:	ff 75 d8             	pushl  -0x28(%ebp)
f0105022:	e8 69 12 00 00       	call   f0106290 <__umoddi3>
f0105027:	83 c4 14             	add    $0x14,%esp
f010502a:	0f be 80 6e 7d 10 f0 	movsbl -0xfef8292(%eax),%eax
f0105031:	50                   	push   %eax
f0105032:	ff d7                	call   *%edi
}
f0105034:	83 c4 10             	add    $0x10,%esp
f0105037:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010503a:	5b                   	pop    %ebx
f010503b:	5e                   	pop    %esi
f010503c:	5f                   	pop    %edi
f010503d:	5d                   	pop    %ebp
f010503e:	c3                   	ret    

f010503f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f010503f:	55                   	push   %ebp
f0105040:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0105042:	83 fa 01             	cmp    $0x1,%edx
f0105045:	7e 0e                	jle    f0105055 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0105047:	8b 10                	mov    (%eax),%edx
f0105049:	8d 4a 08             	lea    0x8(%edx),%ecx
f010504c:	89 08                	mov    %ecx,(%eax)
f010504e:	8b 02                	mov    (%edx),%eax
f0105050:	8b 52 04             	mov    0x4(%edx),%edx
f0105053:	eb 22                	jmp    f0105077 <getuint+0x38>
	else if (lflag)
f0105055:	85 d2                	test   %edx,%edx
f0105057:	74 10                	je     f0105069 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0105059:	8b 10                	mov    (%eax),%edx
f010505b:	8d 4a 04             	lea    0x4(%edx),%ecx
f010505e:	89 08                	mov    %ecx,(%eax)
f0105060:	8b 02                	mov    (%edx),%eax
f0105062:	ba 00 00 00 00       	mov    $0x0,%edx
f0105067:	eb 0e                	jmp    f0105077 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0105069:	8b 10                	mov    (%eax),%edx
f010506b:	8d 4a 04             	lea    0x4(%edx),%ecx
f010506e:	89 08                	mov    %ecx,(%eax)
f0105070:	8b 02                	mov    (%edx),%eax
f0105072:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0105077:	5d                   	pop    %ebp
f0105078:	c3                   	ret    

f0105079 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105079:	55                   	push   %ebp
f010507a:	89 e5                	mov    %esp,%ebp
f010507c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f010507f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0105083:	8b 10                	mov    (%eax),%edx
f0105085:	3b 50 04             	cmp    0x4(%eax),%edx
f0105088:	73 0a                	jae    f0105094 <sprintputch+0x1b>
		*b->buf++ = ch;
f010508a:	8d 4a 01             	lea    0x1(%edx),%ecx
f010508d:	89 08                	mov    %ecx,(%eax)
f010508f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105092:	88 02                	mov    %al,(%edx)
}
f0105094:	5d                   	pop    %ebp
f0105095:	c3                   	ret    

f0105096 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0105096:	55                   	push   %ebp
f0105097:	89 e5                	mov    %esp,%ebp
f0105099:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010509c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010509f:	50                   	push   %eax
f01050a0:	ff 75 10             	pushl  0x10(%ebp)
f01050a3:	ff 75 0c             	pushl  0xc(%ebp)
f01050a6:	ff 75 08             	pushl  0x8(%ebp)
f01050a9:	e8 05 00 00 00       	call   f01050b3 <vprintfmt>
	va_end(ap);
}
f01050ae:	83 c4 10             	add    $0x10,%esp
f01050b1:	c9                   	leave  
f01050b2:	c3                   	ret    

f01050b3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01050b3:	55                   	push   %ebp
f01050b4:	89 e5                	mov    %esp,%ebp
f01050b6:	57                   	push   %edi
f01050b7:	56                   	push   %esi
f01050b8:	53                   	push   %ebx
f01050b9:	83 ec 2c             	sub    $0x2c,%esp
f01050bc:	8b 75 08             	mov    0x8(%ebp),%esi
f01050bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01050c2:	8b 7d 10             	mov    0x10(%ebp),%edi
f01050c5:	eb 12                	jmp    f01050d9 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01050c7:	85 c0                	test   %eax,%eax
f01050c9:	0f 84 89 03 00 00    	je     f0105458 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f01050cf:	83 ec 08             	sub    $0x8,%esp
f01050d2:	53                   	push   %ebx
f01050d3:	50                   	push   %eax
f01050d4:	ff d6                	call   *%esi
f01050d6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01050d9:	83 c7 01             	add    $0x1,%edi
f01050dc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01050e0:	83 f8 25             	cmp    $0x25,%eax
f01050e3:	75 e2                	jne    f01050c7 <vprintfmt+0x14>
f01050e5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f01050e9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f01050f0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f01050f7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f01050fe:	ba 00 00 00 00       	mov    $0x0,%edx
f0105103:	eb 07                	jmp    f010510c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105105:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0105108:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010510c:	8d 47 01             	lea    0x1(%edi),%eax
f010510f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105112:	0f b6 07             	movzbl (%edi),%eax
f0105115:	0f b6 c8             	movzbl %al,%ecx
f0105118:	83 e8 23             	sub    $0x23,%eax
f010511b:	3c 55                	cmp    $0x55,%al
f010511d:	0f 87 1a 03 00 00    	ja     f010543d <vprintfmt+0x38a>
f0105123:	0f b6 c0             	movzbl %al,%eax
f0105126:	ff 24 85 c0 7e 10 f0 	jmp    *-0xfef8140(,%eax,4)
f010512d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0105130:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0105134:	eb d6                	jmp    f010510c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105136:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105139:	b8 00 00 00 00       	mov    $0x0,%eax
f010513e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0105141:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0105144:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0105148:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f010514b:	8d 51 d0             	lea    -0x30(%ecx),%edx
f010514e:	83 fa 09             	cmp    $0x9,%edx
f0105151:	77 39                	ja     f010518c <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0105153:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0105156:	eb e9                	jmp    f0105141 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0105158:	8b 45 14             	mov    0x14(%ebp),%eax
f010515b:	8d 48 04             	lea    0x4(%eax),%ecx
f010515e:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0105161:	8b 00                	mov    (%eax),%eax
f0105163:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105166:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0105169:	eb 27                	jmp    f0105192 <vprintfmt+0xdf>
f010516b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010516e:	85 c0                	test   %eax,%eax
f0105170:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105175:	0f 49 c8             	cmovns %eax,%ecx
f0105178:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010517b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010517e:	eb 8c                	jmp    f010510c <vprintfmt+0x59>
f0105180:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0105183:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f010518a:	eb 80                	jmp    f010510c <vprintfmt+0x59>
f010518c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010518f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0105192:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105196:	0f 89 70 ff ff ff    	jns    f010510c <vprintfmt+0x59>
				width = precision, precision = -1;
f010519c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010519f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01051a2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f01051a9:	e9 5e ff ff ff       	jmp    f010510c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01051ae:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01051b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f01051b4:	e9 53 ff ff ff       	jmp    f010510c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01051b9:	8b 45 14             	mov    0x14(%ebp),%eax
f01051bc:	8d 50 04             	lea    0x4(%eax),%edx
f01051bf:	89 55 14             	mov    %edx,0x14(%ebp)
f01051c2:	83 ec 08             	sub    $0x8,%esp
f01051c5:	53                   	push   %ebx
f01051c6:	ff 30                	pushl  (%eax)
f01051c8:	ff d6                	call   *%esi
			break;
f01051ca:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01051cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01051d0:	e9 04 ff ff ff       	jmp    f01050d9 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f01051d5:	8b 45 14             	mov    0x14(%ebp),%eax
f01051d8:	8d 50 04             	lea    0x4(%eax),%edx
f01051db:	89 55 14             	mov    %edx,0x14(%ebp)
f01051de:	8b 00                	mov    (%eax),%eax
f01051e0:	99                   	cltd   
f01051e1:	31 d0                	xor    %edx,%eax
f01051e3:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01051e5:	83 f8 0f             	cmp    $0xf,%eax
f01051e8:	7f 0b                	jg     f01051f5 <vprintfmt+0x142>
f01051ea:	8b 14 85 20 80 10 f0 	mov    -0xfef7fe0(,%eax,4),%edx
f01051f1:	85 d2                	test   %edx,%edx
f01051f3:	75 18                	jne    f010520d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f01051f5:	50                   	push   %eax
f01051f6:	68 86 7d 10 f0       	push   $0xf0107d86
f01051fb:	53                   	push   %ebx
f01051fc:	56                   	push   %esi
f01051fd:	e8 94 fe ff ff       	call   f0105096 <printfmt>
f0105202:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105205:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0105208:	e9 cc fe ff ff       	jmp    f01050d9 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f010520d:	52                   	push   %edx
f010520e:	68 17 6a 10 f0       	push   $0xf0106a17
f0105213:	53                   	push   %ebx
f0105214:	56                   	push   %esi
f0105215:	e8 7c fe ff ff       	call   f0105096 <printfmt>
f010521a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010521d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105220:	e9 b4 fe ff ff       	jmp    f01050d9 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105225:	8b 45 14             	mov    0x14(%ebp),%eax
f0105228:	8d 50 04             	lea    0x4(%eax),%edx
f010522b:	89 55 14             	mov    %edx,0x14(%ebp)
f010522e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0105230:	85 ff                	test   %edi,%edi
f0105232:	b8 7f 7d 10 f0       	mov    $0xf0107d7f,%eax
f0105237:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f010523a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010523e:	0f 8e 94 00 00 00    	jle    f01052d8 <vprintfmt+0x225>
f0105244:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0105248:	0f 84 98 00 00 00    	je     f01052e6 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f010524e:	83 ec 08             	sub    $0x8,%esp
f0105251:	ff 75 d0             	pushl  -0x30(%ebp)
f0105254:	57                   	push   %edi
f0105255:	e8 77 03 00 00       	call   f01055d1 <strnlen>
f010525a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010525d:	29 c1                	sub    %eax,%ecx
f010525f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0105262:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0105265:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0105269:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010526c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010526f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105271:	eb 0f                	jmp    f0105282 <vprintfmt+0x1cf>
					putch(padc, putdat);
f0105273:	83 ec 08             	sub    $0x8,%esp
f0105276:	53                   	push   %ebx
f0105277:	ff 75 e0             	pushl  -0x20(%ebp)
f010527a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010527c:	83 ef 01             	sub    $0x1,%edi
f010527f:	83 c4 10             	add    $0x10,%esp
f0105282:	85 ff                	test   %edi,%edi
f0105284:	7f ed                	jg     f0105273 <vprintfmt+0x1c0>
f0105286:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0105289:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010528c:	85 c9                	test   %ecx,%ecx
f010528e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105293:	0f 49 c1             	cmovns %ecx,%eax
f0105296:	29 c1                	sub    %eax,%ecx
f0105298:	89 75 08             	mov    %esi,0x8(%ebp)
f010529b:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010529e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01052a1:	89 cb                	mov    %ecx,%ebx
f01052a3:	eb 4d                	jmp    f01052f2 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01052a5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01052a9:	74 1b                	je     f01052c6 <vprintfmt+0x213>
f01052ab:	0f be c0             	movsbl %al,%eax
f01052ae:	83 e8 20             	sub    $0x20,%eax
f01052b1:	83 f8 5e             	cmp    $0x5e,%eax
f01052b4:	76 10                	jbe    f01052c6 <vprintfmt+0x213>
					putch('?', putdat);
f01052b6:	83 ec 08             	sub    $0x8,%esp
f01052b9:	ff 75 0c             	pushl  0xc(%ebp)
f01052bc:	6a 3f                	push   $0x3f
f01052be:	ff 55 08             	call   *0x8(%ebp)
f01052c1:	83 c4 10             	add    $0x10,%esp
f01052c4:	eb 0d                	jmp    f01052d3 <vprintfmt+0x220>
				else
					putch(ch, putdat);
f01052c6:	83 ec 08             	sub    $0x8,%esp
f01052c9:	ff 75 0c             	pushl  0xc(%ebp)
f01052cc:	52                   	push   %edx
f01052cd:	ff 55 08             	call   *0x8(%ebp)
f01052d0:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01052d3:	83 eb 01             	sub    $0x1,%ebx
f01052d6:	eb 1a                	jmp    f01052f2 <vprintfmt+0x23f>
f01052d8:	89 75 08             	mov    %esi,0x8(%ebp)
f01052db:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01052de:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01052e1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01052e4:	eb 0c                	jmp    f01052f2 <vprintfmt+0x23f>
f01052e6:	89 75 08             	mov    %esi,0x8(%ebp)
f01052e9:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01052ec:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01052ef:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01052f2:	83 c7 01             	add    $0x1,%edi
f01052f5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01052f9:	0f be d0             	movsbl %al,%edx
f01052fc:	85 d2                	test   %edx,%edx
f01052fe:	74 23                	je     f0105323 <vprintfmt+0x270>
f0105300:	85 f6                	test   %esi,%esi
f0105302:	78 a1                	js     f01052a5 <vprintfmt+0x1f2>
f0105304:	83 ee 01             	sub    $0x1,%esi
f0105307:	79 9c                	jns    f01052a5 <vprintfmt+0x1f2>
f0105309:	89 df                	mov    %ebx,%edi
f010530b:	8b 75 08             	mov    0x8(%ebp),%esi
f010530e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105311:	eb 18                	jmp    f010532b <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0105313:	83 ec 08             	sub    $0x8,%esp
f0105316:	53                   	push   %ebx
f0105317:	6a 20                	push   $0x20
f0105319:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010531b:	83 ef 01             	sub    $0x1,%edi
f010531e:	83 c4 10             	add    $0x10,%esp
f0105321:	eb 08                	jmp    f010532b <vprintfmt+0x278>
f0105323:	89 df                	mov    %ebx,%edi
f0105325:	8b 75 08             	mov    0x8(%ebp),%esi
f0105328:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010532b:	85 ff                	test   %edi,%edi
f010532d:	7f e4                	jg     f0105313 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010532f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105332:	e9 a2 fd ff ff       	jmp    f01050d9 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105337:	83 fa 01             	cmp    $0x1,%edx
f010533a:	7e 16                	jle    f0105352 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f010533c:	8b 45 14             	mov    0x14(%ebp),%eax
f010533f:	8d 50 08             	lea    0x8(%eax),%edx
f0105342:	89 55 14             	mov    %edx,0x14(%ebp)
f0105345:	8b 50 04             	mov    0x4(%eax),%edx
f0105348:	8b 00                	mov    (%eax),%eax
f010534a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010534d:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105350:	eb 32                	jmp    f0105384 <vprintfmt+0x2d1>
	else if (lflag)
f0105352:	85 d2                	test   %edx,%edx
f0105354:	74 18                	je     f010536e <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0105356:	8b 45 14             	mov    0x14(%ebp),%eax
f0105359:	8d 50 04             	lea    0x4(%eax),%edx
f010535c:	89 55 14             	mov    %edx,0x14(%ebp)
f010535f:	8b 00                	mov    (%eax),%eax
f0105361:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105364:	89 c1                	mov    %eax,%ecx
f0105366:	c1 f9 1f             	sar    $0x1f,%ecx
f0105369:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010536c:	eb 16                	jmp    f0105384 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f010536e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105371:	8d 50 04             	lea    0x4(%eax),%edx
f0105374:	89 55 14             	mov    %edx,0x14(%ebp)
f0105377:	8b 00                	mov    (%eax),%eax
f0105379:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010537c:	89 c1                	mov    %eax,%ecx
f010537e:	c1 f9 1f             	sar    $0x1f,%ecx
f0105381:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0105384:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105387:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f010538a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010538f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105393:	79 74                	jns    f0105409 <vprintfmt+0x356>
				putch('-', putdat);
f0105395:	83 ec 08             	sub    $0x8,%esp
f0105398:	53                   	push   %ebx
f0105399:	6a 2d                	push   $0x2d
f010539b:	ff d6                	call   *%esi
				num = -(long long) num;
f010539d:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01053a0:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01053a3:	f7 d8                	neg    %eax
f01053a5:	83 d2 00             	adc    $0x0,%edx
f01053a8:	f7 da                	neg    %edx
f01053aa:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f01053ad:	b9 0a 00 00 00       	mov    $0xa,%ecx
f01053b2:	eb 55                	jmp    f0105409 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01053b4:	8d 45 14             	lea    0x14(%ebp),%eax
f01053b7:	e8 83 fc ff ff       	call   f010503f <getuint>
			base = 10;
f01053bc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f01053c1:	eb 46                	jmp    f0105409 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
f01053c3:	8d 45 14             	lea    0x14(%ebp),%eax
f01053c6:	e8 74 fc ff ff       	call   f010503f <getuint>
			base = 8;
f01053cb:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f01053d0:	eb 37                	jmp    f0105409 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
f01053d2:	83 ec 08             	sub    $0x8,%esp
f01053d5:	53                   	push   %ebx
f01053d6:	6a 30                	push   $0x30
f01053d8:	ff d6                	call   *%esi
			putch('x', putdat);
f01053da:	83 c4 08             	add    $0x8,%esp
f01053dd:	53                   	push   %ebx
f01053de:	6a 78                	push   $0x78
f01053e0:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01053e2:	8b 45 14             	mov    0x14(%ebp),%eax
f01053e5:	8d 50 04             	lea    0x4(%eax),%edx
f01053e8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01053eb:	8b 00                	mov    (%eax),%eax
f01053ed:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f01053f2:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01053f5:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f01053fa:	eb 0d                	jmp    f0105409 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01053fc:	8d 45 14             	lea    0x14(%ebp),%eax
f01053ff:	e8 3b fc ff ff       	call   f010503f <getuint>
			base = 16;
f0105404:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105409:	83 ec 0c             	sub    $0xc,%esp
f010540c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0105410:	57                   	push   %edi
f0105411:	ff 75 e0             	pushl  -0x20(%ebp)
f0105414:	51                   	push   %ecx
f0105415:	52                   	push   %edx
f0105416:	50                   	push   %eax
f0105417:	89 da                	mov    %ebx,%edx
f0105419:	89 f0                	mov    %esi,%eax
f010541b:	e8 70 fb ff ff       	call   f0104f90 <printnum>
			break;
f0105420:	83 c4 20             	add    $0x20,%esp
f0105423:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105426:	e9 ae fc ff ff       	jmp    f01050d9 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010542b:	83 ec 08             	sub    $0x8,%esp
f010542e:	53                   	push   %ebx
f010542f:	51                   	push   %ecx
f0105430:	ff d6                	call   *%esi
			break;
f0105432:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105435:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0105438:	e9 9c fc ff ff       	jmp    f01050d9 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010543d:	83 ec 08             	sub    $0x8,%esp
f0105440:	53                   	push   %ebx
f0105441:	6a 25                	push   $0x25
f0105443:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105445:	83 c4 10             	add    $0x10,%esp
f0105448:	eb 03                	jmp    f010544d <vprintfmt+0x39a>
f010544a:	83 ef 01             	sub    $0x1,%edi
f010544d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0105451:	75 f7                	jne    f010544a <vprintfmt+0x397>
f0105453:	e9 81 fc ff ff       	jmp    f01050d9 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0105458:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010545b:	5b                   	pop    %ebx
f010545c:	5e                   	pop    %esi
f010545d:	5f                   	pop    %edi
f010545e:	5d                   	pop    %ebp
f010545f:	c3                   	ret    

f0105460 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105460:	55                   	push   %ebp
f0105461:	89 e5                	mov    %esp,%ebp
f0105463:	83 ec 18             	sub    $0x18,%esp
f0105466:	8b 45 08             	mov    0x8(%ebp),%eax
f0105469:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010546c:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010546f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105473:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105476:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010547d:	85 c0                	test   %eax,%eax
f010547f:	74 26                	je     f01054a7 <vsnprintf+0x47>
f0105481:	85 d2                	test   %edx,%edx
f0105483:	7e 22                	jle    f01054a7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105485:	ff 75 14             	pushl  0x14(%ebp)
f0105488:	ff 75 10             	pushl  0x10(%ebp)
f010548b:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010548e:	50                   	push   %eax
f010548f:	68 79 50 10 f0       	push   $0xf0105079
f0105494:	e8 1a fc ff ff       	call   f01050b3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105499:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010549c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010549f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01054a2:	83 c4 10             	add    $0x10,%esp
f01054a5:	eb 05                	jmp    f01054ac <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01054a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01054ac:	c9                   	leave  
f01054ad:	c3                   	ret    

f01054ae <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01054ae:	55                   	push   %ebp
f01054af:	89 e5                	mov    %esp,%ebp
f01054b1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01054b4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01054b7:	50                   	push   %eax
f01054b8:	ff 75 10             	pushl  0x10(%ebp)
f01054bb:	ff 75 0c             	pushl  0xc(%ebp)
f01054be:	ff 75 08             	pushl  0x8(%ebp)
f01054c1:	e8 9a ff ff ff       	call   f0105460 <vsnprintf>
	va_end(ap);

	return rc;
}
f01054c6:	c9                   	leave  
f01054c7:	c3                   	ret    

f01054c8 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01054c8:	55                   	push   %ebp
f01054c9:	89 e5                	mov    %esp,%ebp
f01054cb:	57                   	push   %edi
f01054cc:	56                   	push   %esi
f01054cd:	53                   	push   %ebx
f01054ce:	83 ec 0c             	sub    $0xc,%esp
f01054d1:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f01054d4:	85 c0                	test   %eax,%eax
f01054d6:	74 11                	je     f01054e9 <readline+0x21>
		cprintf("%s", prompt);
f01054d8:	83 ec 08             	sub    $0x8,%esp
f01054db:	50                   	push   %eax
f01054dc:	68 17 6a 10 f0       	push   $0xf0106a17
f01054e1:	e8 7c e4 ff ff       	call   f0103962 <cprintf>
f01054e6:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f01054e9:	83 ec 0c             	sub    $0xc,%esp
f01054ec:	6a 00                	push   $0x0
f01054ee:	e8 b0 b2 ff ff       	call   f01007a3 <iscons>
f01054f3:	89 c7                	mov    %eax,%edi
f01054f5:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
f01054f8:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01054fd:	e8 90 b2 ff ff       	call   f0100792 <getchar>
f0105502:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105504:	85 c0                	test   %eax,%eax
f0105506:	79 29                	jns    f0105531 <readline+0x69>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f0105508:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
f010550d:	83 fb f8             	cmp    $0xfffffff8,%ebx
f0105510:	0f 84 9b 00 00 00    	je     f01055b1 <readline+0xe9>
				cprintf("read error: %e\n", c);
f0105516:	83 ec 08             	sub    $0x8,%esp
f0105519:	53                   	push   %ebx
f010551a:	68 7f 80 10 f0       	push   $0xf010807f
f010551f:	e8 3e e4 ff ff       	call   f0103962 <cprintf>
f0105524:	83 c4 10             	add    $0x10,%esp
			return NULL;
f0105527:	b8 00 00 00 00       	mov    $0x0,%eax
f010552c:	e9 80 00 00 00       	jmp    f01055b1 <readline+0xe9>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105531:	83 f8 08             	cmp    $0x8,%eax
f0105534:	0f 94 c2             	sete   %dl
f0105537:	83 f8 7f             	cmp    $0x7f,%eax
f010553a:	0f 94 c0             	sete   %al
f010553d:	08 c2                	or     %al,%dl
f010553f:	74 1a                	je     f010555b <readline+0x93>
f0105541:	85 f6                	test   %esi,%esi
f0105543:	7e 16                	jle    f010555b <readline+0x93>
			if (echoing)
f0105545:	85 ff                	test   %edi,%edi
f0105547:	74 0d                	je     f0105556 <readline+0x8e>
				cputchar('\b');
f0105549:	83 ec 0c             	sub    $0xc,%esp
f010554c:	6a 08                	push   $0x8
f010554e:	e8 2f b2 ff ff       	call   f0100782 <cputchar>
f0105553:	83 c4 10             	add    $0x10,%esp
			i--;
f0105556:	83 ee 01             	sub    $0x1,%esi
f0105559:	eb a2                	jmp    f01054fd <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010555b:	83 fb 1f             	cmp    $0x1f,%ebx
f010555e:	7e 26                	jle    f0105586 <readline+0xbe>
f0105560:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105566:	7f 1e                	jg     f0105586 <readline+0xbe>
			if (echoing)
f0105568:	85 ff                	test   %edi,%edi
f010556a:	74 0c                	je     f0105578 <readline+0xb0>
				cputchar(c);
f010556c:	83 ec 0c             	sub    $0xc,%esp
f010556f:	53                   	push   %ebx
f0105570:	e8 0d b2 ff ff       	call   f0100782 <cputchar>
f0105575:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0105578:	88 9e 80 1a 21 f0    	mov    %bl,-0xfdee580(%esi)
f010557e:	8d 76 01             	lea    0x1(%esi),%esi
f0105581:	e9 77 ff ff ff       	jmp    f01054fd <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0105586:	83 fb 0a             	cmp    $0xa,%ebx
f0105589:	74 09                	je     f0105594 <readline+0xcc>
f010558b:	83 fb 0d             	cmp    $0xd,%ebx
f010558e:	0f 85 69 ff ff ff    	jne    f01054fd <readline+0x35>
			if (echoing)
f0105594:	85 ff                	test   %edi,%edi
f0105596:	74 0d                	je     f01055a5 <readline+0xdd>
				cputchar('\n');
f0105598:	83 ec 0c             	sub    $0xc,%esp
f010559b:	6a 0a                	push   $0xa
f010559d:	e8 e0 b1 ff ff       	call   f0100782 <cputchar>
f01055a2:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01055a5:	c6 86 80 1a 21 f0 00 	movb   $0x0,-0xfdee580(%esi)
			return buf;
f01055ac:	b8 80 1a 21 f0       	mov    $0xf0211a80,%eax
		}
	}
}
f01055b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01055b4:	5b                   	pop    %ebx
f01055b5:	5e                   	pop    %esi
f01055b6:	5f                   	pop    %edi
f01055b7:	5d                   	pop    %ebp
f01055b8:	c3                   	ret    

f01055b9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01055b9:	55                   	push   %ebp
f01055ba:	89 e5                	mov    %esp,%ebp
f01055bc:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01055bf:	b8 00 00 00 00       	mov    $0x0,%eax
f01055c4:	eb 03                	jmp    f01055c9 <strlen+0x10>
		n++;
f01055c6:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01055c9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01055cd:	75 f7                	jne    f01055c6 <strlen+0xd>
		n++;
	return n;
}
f01055cf:	5d                   	pop    %ebp
f01055d0:	c3                   	ret    

f01055d1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01055d1:	55                   	push   %ebp
f01055d2:	89 e5                	mov    %esp,%ebp
f01055d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01055d7:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01055da:	ba 00 00 00 00       	mov    $0x0,%edx
f01055df:	eb 03                	jmp    f01055e4 <strnlen+0x13>
		n++;
f01055e1:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01055e4:	39 c2                	cmp    %eax,%edx
f01055e6:	74 08                	je     f01055f0 <strnlen+0x1f>
f01055e8:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f01055ec:	75 f3                	jne    f01055e1 <strnlen+0x10>
f01055ee:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f01055f0:	5d                   	pop    %ebp
f01055f1:	c3                   	ret    

f01055f2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01055f2:	55                   	push   %ebp
f01055f3:	89 e5                	mov    %esp,%ebp
f01055f5:	53                   	push   %ebx
f01055f6:	8b 45 08             	mov    0x8(%ebp),%eax
f01055f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01055fc:	89 c2                	mov    %eax,%edx
f01055fe:	83 c2 01             	add    $0x1,%edx
f0105601:	83 c1 01             	add    $0x1,%ecx
f0105604:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0105608:	88 5a ff             	mov    %bl,-0x1(%edx)
f010560b:	84 db                	test   %bl,%bl
f010560d:	75 ef                	jne    f01055fe <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f010560f:	5b                   	pop    %ebx
f0105610:	5d                   	pop    %ebp
f0105611:	c3                   	ret    

f0105612 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105612:	55                   	push   %ebp
f0105613:	89 e5                	mov    %esp,%ebp
f0105615:	53                   	push   %ebx
f0105616:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105619:	53                   	push   %ebx
f010561a:	e8 9a ff ff ff       	call   f01055b9 <strlen>
f010561f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0105622:	ff 75 0c             	pushl  0xc(%ebp)
f0105625:	01 d8                	add    %ebx,%eax
f0105627:	50                   	push   %eax
f0105628:	e8 c5 ff ff ff       	call   f01055f2 <strcpy>
	return dst;
}
f010562d:	89 d8                	mov    %ebx,%eax
f010562f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105632:	c9                   	leave  
f0105633:	c3                   	ret    

f0105634 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105634:	55                   	push   %ebp
f0105635:	89 e5                	mov    %esp,%ebp
f0105637:	56                   	push   %esi
f0105638:	53                   	push   %ebx
f0105639:	8b 75 08             	mov    0x8(%ebp),%esi
f010563c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010563f:	89 f3                	mov    %esi,%ebx
f0105641:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105644:	89 f2                	mov    %esi,%edx
f0105646:	eb 0f                	jmp    f0105657 <strncpy+0x23>
		*dst++ = *src;
f0105648:	83 c2 01             	add    $0x1,%edx
f010564b:	0f b6 01             	movzbl (%ecx),%eax
f010564e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105651:	80 39 01             	cmpb   $0x1,(%ecx)
f0105654:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105657:	39 da                	cmp    %ebx,%edx
f0105659:	75 ed                	jne    f0105648 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010565b:	89 f0                	mov    %esi,%eax
f010565d:	5b                   	pop    %ebx
f010565e:	5e                   	pop    %esi
f010565f:	5d                   	pop    %ebp
f0105660:	c3                   	ret    

f0105661 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105661:	55                   	push   %ebp
f0105662:	89 e5                	mov    %esp,%ebp
f0105664:	56                   	push   %esi
f0105665:	53                   	push   %ebx
f0105666:	8b 75 08             	mov    0x8(%ebp),%esi
f0105669:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010566c:	8b 55 10             	mov    0x10(%ebp),%edx
f010566f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105671:	85 d2                	test   %edx,%edx
f0105673:	74 21                	je     f0105696 <strlcpy+0x35>
f0105675:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0105679:	89 f2                	mov    %esi,%edx
f010567b:	eb 09                	jmp    f0105686 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010567d:	83 c2 01             	add    $0x1,%edx
f0105680:	83 c1 01             	add    $0x1,%ecx
f0105683:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105686:	39 c2                	cmp    %eax,%edx
f0105688:	74 09                	je     f0105693 <strlcpy+0x32>
f010568a:	0f b6 19             	movzbl (%ecx),%ebx
f010568d:	84 db                	test   %bl,%bl
f010568f:	75 ec                	jne    f010567d <strlcpy+0x1c>
f0105691:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0105693:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105696:	29 f0                	sub    %esi,%eax
}
f0105698:	5b                   	pop    %ebx
f0105699:	5e                   	pop    %esi
f010569a:	5d                   	pop    %ebp
f010569b:	c3                   	ret    

f010569c <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010569c:	55                   	push   %ebp
f010569d:	89 e5                	mov    %esp,%ebp
f010569f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01056a2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01056a5:	eb 06                	jmp    f01056ad <strcmp+0x11>
		p++, q++;
f01056a7:	83 c1 01             	add    $0x1,%ecx
f01056aa:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01056ad:	0f b6 01             	movzbl (%ecx),%eax
f01056b0:	84 c0                	test   %al,%al
f01056b2:	74 04                	je     f01056b8 <strcmp+0x1c>
f01056b4:	3a 02                	cmp    (%edx),%al
f01056b6:	74 ef                	je     f01056a7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01056b8:	0f b6 c0             	movzbl %al,%eax
f01056bb:	0f b6 12             	movzbl (%edx),%edx
f01056be:	29 d0                	sub    %edx,%eax
}
f01056c0:	5d                   	pop    %ebp
f01056c1:	c3                   	ret    

f01056c2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01056c2:	55                   	push   %ebp
f01056c3:	89 e5                	mov    %esp,%ebp
f01056c5:	53                   	push   %ebx
f01056c6:	8b 45 08             	mov    0x8(%ebp),%eax
f01056c9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01056cc:	89 c3                	mov    %eax,%ebx
f01056ce:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01056d1:	eb 06                	jmp    f01056d9 <strncmp+0x17>
		n--, p++, q++;
f01056d3:	83 c0 01             	add    $0x1,%eax
f01056d6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01056d9:	39 d8                	cmp    %ebx,%eax
f01056db:	74 15                	je     f01056f2 <strncmp+0x30>
f01056dd:	0f b6 08             	movzbl (%eax),%ecx
f01056e0:	84 c9                	test   %cl,%cl
f01056e2:	74 04                	je     f01056e8 <strncmp+0x26>
f01056e4:	3a 0a                	cmp    (%edx),%cl
f01056e6:	74 eb                	je     f01056d3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01056e8:	0f b6 00             	movzbl (%eax),%eax
f01056eb:	0f b6 12             	movzbl (%edx),%edx
f01056ee:	29 d0                	sub    %edx,%eax
f01056f0:	eb 05                	jmp    f01056f7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01056f2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01056f7:	5b                   	pop    %ebx
f01056f8:	5d                   	pop    %ebp
f01056f9:	c3                   	ret    

f01056fa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01056fa:	55                   	push   %ebp
f01056fb:	89 e5                	mov    %esp,%ebp
f01056fd:	8b 45 08             	mov    0x8(%ebp),%eax
f0105700:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105704:	eb 07                	jmp    f010570d <strchr+0x13>
		if (*s == c)
f0105706:	38 ca                	cmp    %cl,%dl
f0105708:	74 0f                	je     f0105719 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010570a:	83 c0 01             	add    $0x1,%eax
f010570d:	0f b6 10             	movzbl (%eax),%edx
f0105710:	84 d2                	test   %dl,%dl
f0105712:	75 f2                	jne    f0105706 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0105714:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105719:	5d                   	pop    %ebp
f010571a:	c3                   	ret    

f010571b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010571b:	55                   	push   %ebp
f010571c:	89 e5                	mov    %esp,%ebp
f010571e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105721:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105725:	eb 03                	jmp    f010572a <strfind+0xf>
f0105727:	83 c0 01             	add    $0x1,%eax
f010572a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010572d:	38 ca                	cmp    %cl,%dl
f010572f:	74 04                	je     f0105735 <strfind+0x1a>
f0105731:	84 d2                	test   %dl,%dl
f0105733:	75 f2                	jne    f0105727 <strfind+0xc>
			break;
	return (char *) s;
}
f0105735:	5d                   	pop    %ebp
f0105736:	c3                   	ret    

f0105737 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105737:	55                   	push   %ebp
f0105738:	89 e5                	mov    %esp,%ebp
f010573a:	57                   	push   %edi
f010573b:	56                   	push   %esi
f010573c:	53                   	push   %ebx
f010573d:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105740:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105743:	85 c9                	test   %ecx,%ecx
f0105745:	74 36                	je     f010577d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105747:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010574d:	75 28                	jne    f0105777 <memset+0x40>
f010574f:	f6 c1 03             	test   $0x3,%cl
f0105752:	75 23                	jne    f0105777 <memset+0x40>
		c &= 0xFF;
f0105754:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105758:	89 d3                	mov    %edx,%ebx
f010575a:	c1 e3 08             	shl    $0x8,%ebx
f010575d:	89 d6                	mov    %edx,%esi
f010575f:	c1 e6 18             	shl    $0x18,%esi
f0105762:	89 d0                	mov    %edx,%eax
f0105764:	c1 e0 10             	shl    $0x10,%eax
f0105767:	09 f0                	or     %esi,%eax
f0105769:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f010576b:	89 d8                	mov    %ebx,%eax
f010576d:	09 d0                	or     %edx,%eax
f010576f:	c1 e9 02             	shr    $0x2,%ecx
f0105772:	fc                   	cld    
f0105773:	f3 ab                	rep stos %eax,%es:(%edi)
f0105775:	eb 06                	jmp    f010577d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105777:	8b 45 0c             	mov    0xc(%ebp),%eax
f010577a:	fc                   	cld    
f010577b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010577d:	89 f8                	mov    %edi,%eax
f010577f:	5b                   	pop    %ebx
f0105780:	5e                   	pop    %esi
f0105781:	5f                   	pop    %edi
f0105782:	5d                   	pop    %ebp
f0105783:	c3                   	ret    

f0105784 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105784:	55                   	push   %ebp
f0105785:	89 e5                	mov    %esp,%ebp
f0105787:	57                   	push   %edi
f0105788:	56                   	push   %esi
f0105789:	8b 45 08             	mov    0x8(%ebp),%eax
f010578c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010578f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105792:	39 c6                	cmp    %eax,%esi
f0105794:	73 35                	jae    f01057cb <memmove+0x47>
f0105796:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105799:	39 d0                	cmp    %edx,%eax
f010579b:	73 2e                	jae    f01057cb <memmove+0x47>
		s += n;
		d += n;
f010579d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01057a0:	89 d6                	mov    %edx,%esi
f01057a2:	09 fe                	or     %edi,%esi
f01057a4:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01057aa:	75 13                	jne    f01057bf <memmove+0x3b>
f01057ac:	f6 c1 03             	test   $0x3,%cl
f01057af:	75 0e                	jne    f01057bf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f01057b1:	83 ef 04             	sub    $0x4,%edi
f01057b4:	8d 72 fc             	lea    -0x4(%edx),%esi
f01057b7:	c1 e9 02             	shr    $0x2,%ecx
f01057ba:	fd                   	std    
f01057bb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01057bd:	eb 09                	jmp    f01057c8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01057bf:	83 ef 01             	sub    $0x1,%edi
f01057c2:	8d 72 ff             	lea    -0x1(%edx),%esi
f01057c5:	fd                   	std    
f01057c6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01057c8:	fc                   	cld    
f01057c9:	eb 1d                	jmp    f01057e8 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01057cb:	89 f2                	mov    %esi,%edx
f01057cd:	09 c2                	or     %eax,%edx
f01057cf:	f6 c2 03             	test   $0x3,%dl
f01057d2:	75 0f                	jne    f01057e3 <memmove+0x5f>
f01057d4:	f6 c1 03             	test   $0x3,%cl
f01057d7:	75 0a                	jne    f01057e3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f01057d9:	c1 e9 02             	shr    $0x2,%ecx
f01057dc:	89 c7                	mov    %eax,%edi
f01057de:	fc                   	cld    
f01057df:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01057e1:	eb 05                	jmp    f01057e8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01057e3:	89 c7                	mov    %eax,%edi
f01057e5:	fc                   	cld    
f01057e6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01057e8:	5e                   	pop    %esi
f01057e9:	5f                   	pop    %edi
f01057ea:	5d                   	pop    %ebp
f01057eb:	c3                   	ret    

f01057ec <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01057ec:	55                   	push   %ebp
f01057ed:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01057ef:	ff 75 10             	pushl  0x10(%ebp)
f01057f2:	ff 75 0c             	pushl  0xc(%ebp)
f01057f5:	ff 75 08             	pushl  0x8(%ebp)
f01057f8:	e8 87 ff ff ff       	call   f0105784 <memmove>
}
f01057fd:	c9                   	leave  
f01057fe:	c3                   	ret    

f01057ff <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01057ff:	55                   	push   %ebp
f0105800:	89 e5                	mov    %esp,%ebp
f0105802:	56                   	push   %esi
f0105803:	53                   	push   %ebx
f0105804:	8b 45 08             	mov    0x8(%ebp),%eax
f0105807:	8b 55 0c             	mov    0xc(%ebp),%edx
f010580a:	89 c6                	mov    %eax,%esi
f010580c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010580f:	eb 1a                	jmp    f010582b <memcmp+0x2c>
		if (*s1 != *s2)
f0105811:	0f b6 08             	movzbl (%eax),%ecx
f0105814:	0f b6 1a             	movzbl (%edx),%ebx
f0105817:	38 d9                	cmp    %bl,%cl
f0105819:	74 0a                	je     f0105825 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f010581b:	0f b6 c1             	movzbl %cl,%eax
f010581e:	0f b6 db             	movzbl %bl,%ebx
f0105821:	29 d8                	sub    %ebx,%eax
f0105823:	eb 0f                	jmp    f0105834 <memcmp+0x35>
		s1++, s2++;
f0105825:	83 c0 01             	add    $0x1,%eax
f0105828:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010582b:	39 f0                	cmp    %esi,%eax
f010582d:	75 e2                	jne    f0105811 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010582f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105834:	5b                   	pop    %ebx
f0105835:	5e                   	pop    %esi
f0105836:	5d                   	pop    %ebp
f0105837:	c3                   	ret    

f0105838 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105838:	55                   	push   %ebp
f0105839:	89 e5                	mov    %esp,%ebp
f010583b:	53                   	push   %ebx
f010583c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010583f:	89 c1                	mov    %eax,%ecx
f0105841:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0105844:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105848:	eb 0a                	jmp    f0105854 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f010584a:	0f b6 10             	movzbl (%eax),%edx
f010584d:	39 da                	cmp    %ebx,%edx
f010584f:	74 07                	je     f0105858 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105851:	83 c0 01             	add    $0x1,%eax
f0105854:	39 c8                	cmp    %ecx,%eax
f0105856:	72 f2                	jb     f010584a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0105858:	5b                   	pop    %ebx
f0105859:	5d                   	pop    %ebp
f010585a:	c3                   	ret    

f010585b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010585b:	55                   	push   %ebp
f010585c:	89 e5                	mov    %esp,%ebp
f010585e:	57                   	push   %edi
f010585f:	56                   	push   %esi
f0105860:	53                   	push   %ebx
f0105861:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105864:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105867:	eb 03                	jmp    f010586c <strtol+0x11>
		s++;
f0105869:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010586c:	0f b6 01             	movzbl (%ecx),%eax
f010586f:	3c 20                	cmp    $0x20,%al
f0105871:	74 f6                	je     f0105869 <strtol+0xe>
f0105873:	3c 09                	cmp    $0x9,%al
f0105875:	74 f2                	je     f0105869 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0105877:	3c 2b                	cmp    $0x2b,%al
f0105879:	75 0a                	jne    f0105885 <strtol+0x2a>
		s++;
f010587b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f010587e:	bf 00 00 00 00       	mov    $0x0,%edi
f0105883:	eb 11                	jmp    f0105896 <strtol+0x3b>
f0105885:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010588a:	3c 2d                	cmp    $0x2d,%al
f010588c:	75 08                	jne    f0105896 <strtol+0x3b>
		s++, neg = 1;
f010588e:	83 c1 01             	add    $0x1,%ecx
f0105891:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105896:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010589c:	75 15                	jne    f01058b3 <strtol+0x58>
f010589e:	80 39 30             	cmpb   $0x30,(%ecx)
f01058a1:	75 10                	jne    f01058b3 <strtol+0x58>
f01058a3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01058a7:	75 7c                	jne    f0105925 <strtol+0xca>
		s += 2, base = 16;
f01058a9:	83 c1 02             	add    $0x2,%ecx
f01058ac:	bb 10 00 00 00       	mov    $0x10,%ebx
f01058b1:	eb 16                	jmp    f01058c9 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f01058b3:	85 db                	test   %ebx,%ebx
f01058b5:	75 12                	jne    f01058c9 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01058b7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01058bc:	80 39 30             	cmpb   $0x30,(%ecx)
f01058bf:	75 08                	jne    f01058c9 <strtol+0x6e>
		s++, base = 8;
f01058c1:	83 c1 01             	add    $0x1,%ecx
f01058c4:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f01058c9:	b8 00 00 00 00       	mov    $0x0,%eax
f01058ce:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01058d1:	0f b6 11             	movzbl (%ecx),%edx
f01058d4:	8d 72 d0             	lea    -0x30(%edx),%esi
f01058d7:	89 f3                	mov    %esi,%ebx
f01058d9:	80 fb 09             	cmp    $0x9,%bl
f01058dc:	77 08                	ja     f01058e6 <strtol+0x8b>
			dig = *s - '0';
f01058de:	0f be d2             	movsbl %dl,%edx
f01058e1:	83 ea 30             	sub    $0x30,%edx
f01058e4:	eb 22                	jmp    f0105908 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f01058e6:	8d 72 9f             	lea    -0x61(%edx),%esi
f01058e9:	89 f3                	mov    %esi,%ebx
f01058eb:	80 fb 19             	cmp    $0x19,%bl
f01058ee:	77 08                	ja     f01058f8 <strtol+0x9d>
			dig = *s - 'a' + 10;
f01058f0:	0f be d2             	movsbl %dl,%edx
f01058f3:	83 ea 57             	sub    $0x57,%edx
f01058f6:	eb 10                	jmp    f0105908 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f01058f8:	8d 72 bf             	lea    -0x41(%edx),%esi
f01058fb:	89 f3                	mov    %esi,%ebx
f01058fd:	80 fb 19             	cmp    $0x19,%bl
f0105900:	77 16                	ja     f0105918 <strtol+0xbd>
			dig = *s - 'A' + 10;
f0105902:	0f be d2             	movsbl %dl,%edx
f0105905:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0105908:	3b 55 10             	cmp    0x10(%ebp),%edx
f010590b:	7d 0b                	jge    f0105918 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f010590d:	83 c1 01             	add    $0x1,%ecx
f0105910:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105914:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0105916:	eb b9                	jmp    f01058d1 <strtol+0x76>

	if (endptr)
f0105918:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010591c:	74 0d                	je     f010592b <strtol+0xd0>
		*endptr = (char *) s;
f010591e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105921:	89 0e                	mov    %ecx,(%esi)
f0105923:	eb 06                	jmp    f010592b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105925:	85 db                	test   %ebx,%ebx
f0105927:	74 98                	je     f01058c1 <strtol+0x66>
f0105929:	eb 9e                	jmp    f01058c9 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f010592b:	89 c2                	mov    %eax,%edx
f010592d:	f7 da                	neg    %edx
f010592f:	85 ff                	test   %edi,%edi
f0105931:	0f 45 c2             	cmovne %edx,%eax
}
f0105934:	5b                   	pop    %ebx
f0105935:	5e                   	pop    %esi
f0105936:	5f                   	pop    %edi
f0105937:	5d                   	pop    %ebp
f0105938:	c3                   	ret    
f0105939:	66 90                	xchg   %ax,%ax
f010593b:	90                   	nop

f010593c <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f010593c:	fa                   	cli    

	xorw    %ax, %ax
f010593d:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f010593f:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105941:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105943:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105945:	0f 01 16             	lgdtl  (%esi)
f0105948:	74 70                	je     f01059ba <mpsearch1+0x3>
	movl    %cr0, %eax
f010594a:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f010594d:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105951:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105954:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f010595a:	08 00                	or     %al,(%eax)

f010595c <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f010595c:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105960:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105962:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105964:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105966:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f010596a:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f010596c:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f010596e:	b8 00 e0 11 00       	mov    $0x11e000,%eax
	movl    %eax, %cr3
f0105973:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105976:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105979:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f010597e:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105981:	8b 25 84 1e 21 f0    	mov    0xf0211e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105987:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f010598c:	b8 b0 01 10 f0       	mov    $0xf01001b0,%eax
	call    *%eax
f0105991:	ff d0                	call   *%eax

f0105993 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105993:	eb fe                	jmp    f0105993 <spin>
f0105995:	8d 76 00             	lea    0x0(%esi),%esi

f0105998 <gdt>:
	...
f01059a0:	ff                   	(bad)  
f01059a1:	ff 00                	incl   (%eax)
f01059a3:	00 00                	add    %al,(%eax)
f01059a5:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f01059ac:	00                   	.byte 0x0
f01059ad:	92                   	xchg   %eax,%edx
f01059ae:	cf                   	iret   
	...

f01059b0 <gdtdesc>:
f01059b0:	17                   	pop    %ss
f01059b1:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f01059b6 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f01059b6:	90                   	nop

f01059b7 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f01059b7:	55                   	push   %ebp
f01059b8:	89 e5                	mov    %esp,%ebp
f01059ba:	57                   	push   %edi
f01059bb:	56                   	push   %esi
f01059bc:	53                   	push   %ebx
f01059bd:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01059c0:	8b 0d 88 1e 21 f0    	mov    0xf0211e88,%ecx
f01059c6:	89 c3                	mov    %eax,%ebx
f01059c8:	c1 eb 0c             	shr    $0xc,%ebx
f01059cb:	39 cb                	cmp    %ecx,%ebx
f01059cd:	72 12                	jb     f01059e1 <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01059cf:	50                   	push   %eax
f01059d0:	68 24 64 10 f0       	push   $0xf0106424
f01059d5:	6a 57                	push   $0x57
f01059d7:	68 1d 82 10 f0       	push   $0xf010821d
f01059dc:	e8 5f a6 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01059e1:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f01059e7:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01059e9:	89 c2                	mov    %eax,%edx
f01059eb:	c1 ea 0c             	shr    $0xc,%edx
f01059ee:	39 ca                	cmp    %ecx,%edx
f01059f0:	72 12                	jb     f0105a04 <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01059f2:	50                   	push   %eax
f01059f3:	68 24 64 10 f0       	push   $0xf0106424
f01059f8:	6a 57                	push   $0x57
f01059fa:	68 1d 82 10 f0       	push   $0xf010821d
f01059ff:	e8 3c a6 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105a04:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f0105a0a:	eb 2f                	jmp    f0105a3b <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105a0c:	83 ec 04             	sub    $0x4,%esp
f0105a0f:	6a 04                	push   $0x4
f0105a11:	68 2d 82 10 f0       	push   $0xf010822d
f0105a16:	53                   	push   %ebx
f0105a17:	e8 e3 fd ff ff       	call   f01057ff <memcmp>
f0105a1c:	83 c4 10             	add    $0x10,%esp
f0105a1f:	85 c0                	test   %eax,%eax
f0105a21:	75 15                	jne    f0105a38 <mpsearch1+0x81>
f0105a23:	89 da                	mov    %ebx,%edx
f0105a25:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f0105a28:	0f b6 0a             	movzbl (%edx),%ecx
f0105a2b:	01 c8                	add    %ecx,%eax
f0105a2d:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105a30:	39 d7                	cmp    %edx,%edi
f0105a32:	75 f4                	jne    f0105a28 <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105a34:	84 c0                	test   %al,%al
f0105a36:	74 0e                	je     f0105a46 <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0105a38:	83 c3 10             	add    $0x10,%ebx
f0105a3b:	39 f3                	cmp    %esi,%ebx
f0105a3d:	72 cd                	jb     f0105a0c <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105a3f:	b8 00 00 00 00       	mov    $0x0,%eax
f0105a44:	eb 02                	jmp    f0105a48 <mpsearch1+0x91>
f0105a46:	89 d8                	mov    %ebx,%eax
}
f0105a48:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105a4b:	5b                   	pop    %ebx
f0105a4c:	5e                   	pop    %esi
f0105a4d:	5f                   	pop    %edi
f0105a4e:	5d                   	pop    %ebp
f0105a4f:	c3                   	ret    

f0105a50 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105a50:	55                   	push   %ebp
f0105a51:	89 e5                	mov    %esp,%ebp
f0105a53:	57                   	push   %edi
f0105a54:	56                   	push   %esi
f0105a55:	53                   	push   %ebx
f0105a56:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105a59:	c7 05 c0 23 21 f0 20 	movl   $0xf0212020,0xf02123c0
f0105a60:	20 21 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105a63:	83 3d 88 1e 21 f0 00 	cmpl   $0x0,0xf0211e88
f0105a6a:	75 16                	jne    f0105a82 <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105a6c:	68 00 04 00 00       	push   $0x400
f0105a71:	68 24 64 10 f0       	push   $0xf0106424
f0105a76:	6a 6f                	push   $0x6f
f0105a78:	68 1d 82 10 f0       	push   $0xf010821d
f0105a7d:	e8 be a5 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105a82:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105a89:	85 c0                	test   %eax,%eax
f0105a8b:	74 16                	je     f0105aa3 <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f0105a8d:	c1 e0 04             	shl    $0x4,%eax
f0105a90:	ba 00 04 00 00       	mov    $0x400,%edx
f0105a95:	e8 1d ff ff ff       	call   f01059b7 <mpsearch1>
f0105a9a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105a9d:	85 c0                	test   %eax,%eax
f0105a9f:	75 3c                	jne    f0105add <mp_init+0x8d>
f0105aa1:	eb 20                	jmp    f0105ac3 <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105aa3:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105aaa:	c1 e0 0a             	shl    $0xa,%eax
f0105aad:	2d 00 04 00 00       	sub    $0x400,%eax
f0105ab2:	ba 00 04 00 00       	mov    $0x400,%edx
f0105ab7:	e8 fb fe ff ff       	call   f01059b7 <mpsearch1>
f0105abc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105abf:	85 c0                	test   %eax,%eax
f0105ac1:	75 1a                	jne    f0105add <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0105ac3:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105ac8:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105acd:	e8 e5 fe ff ff       	call   f01059b7 <mpsearch1>
f0105ad2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0105ad5:	85 c0                	test   %eax,%eax
f0105ad7:	0f 84 5d 02 00 00    	je     f0105d3a <mp_init+0x2ea>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105add:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105ae0:	8b 70 04             	mov    0x4(%eax),%esi
f0105ae3:	85 f6                	test   %esi,%esi
f0105ae5:	74 06                	je     f0105aed <mp_init+0x9d>
f0105ae7:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105aeb:	74 15                	je     f0105b02 <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f0105aed:	83 ec 0c             	sub    $0xc,%esp
f0105af0:	68 90 80 10 f0       	push   $0xf0108090
f0105af5:	e8 68 de ff ff       	call   f0103962 <cprintf>
f0105afa:	83 c4 10             	add    $0x10,%esp
f0105afd:	e9 38 02 00 00       	jmp    f0105d3a <mp_init+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105b02:	89 f0                	mov    %esi,%eax
f0105b04:	c1 e8 0c             	shr    $0xc,%eax
f0105b07:	3b 05 88 1e 21 f0    	cmp    0xf0211e88,%eax
f0105b0d:	72 15                	jb     f0105b24 <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105b0f:	56                   	push   %esi
f0105b10:	68 24 64 10 f0       	push   $0xf0106424
f0105b15:	68 90 00 00 00       	push   $0x90
f0105b1a:	68 1d 82 10 f0       	push   $0xf010821d
f0105b1f:	e8 1c a5 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105b24:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105b2a:	83 ec 04             	sub    $0x4,%esp
f0105b2d:	6a 04                	push   $0x4
f0105b2f:	68 32 82 10 f0       	push   $0xf0108232
f0105b34:	53                   	push   %ebx
f0105b35:	e8 c5 fc ff ff       	call   f01057ff <memcmp>
f0105b3a:	83 c4 10             	add    $0x10,%esp
f0105b3d:	85 c0                	test   %eax,%eax
f0105b3f:	74 15                	je     f0105b56 <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105b41:	83 ec 0c             	sub    $0xc,%esp
f0105b44:	68 c0 80 10 f0       	push   $0xf01080c0
f0105b49:	e8 14 de ff ff       	call   f0103962 <cprintf>
f0105b4e:	83 c4 10             	add    $0x10,%esp
f0105b51:	e9 e4 01 00 00       	jmp    f0105d3a <mp_init+0x2ea>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105b56:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f0105b5a:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f0105b5e:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105b61:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105b66:	b8 00 00 00 00       	mov    $0x0,%eax
f0105b6b:	eb 0d                	jmp    f0105b7a <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f0105b6d:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0105b74:	f0 
f0105b75:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105b77:	83 c0 01             	add    $0x1,%eax
f0105b7a:	39 c7                	cmp    %eax,%edi
f0105b7c:	75 ef                	jne    f0105b6d <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105b7e:	84 d2                	test   %dl,%dl
f0105b80:	74 15                	je     f0105b97 <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105b82:	83 ec 0c             	sub    $0xc,%esp
f0105b85:	68 f4 80 10 f0       	push   $0xf01080f4
f0105b8a:	e8 d3 dd ff ff       	call   f0103962 <cprintf>
f0105b8f:	83 c4 10             	add    $0x10,%esp
f0105b92:	e9 a3 01 00 00       	jmp    f0105d3a <mp_init+0x2ea>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0105b97:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0105b9b:	3c 01                	cmp    $0x1,%al
f0105b9d:	74 1d                	je     f0105bbc <mp_init+0x16c>
f0105b9f:	3c 04                	cmp    $0x4,%al
f0105ba1:	74 19                	je     f0105bbc <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105ba3:	83 ec 08             	sub    $0x8,%esp
f0105ba6:	0f b6 c0             	movzbl %al,%eax
f0105ba9:	50                   	push   %eax
f0105baa:	68 18 81 10 f0       	push   $0xf0108118
f0105baf:	e8 ae dd ff ff       	call   f0103962 <cprintf>
f0105bb4:	83 c4 10             	add    $0x10,%esp
f0105bb7:	e9 7e 01 00 00       	jmp    f0105d3a <mp_init+0x2ea>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105bbc:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f0105bc0:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105bc4:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105bc9:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f0105bce:	01 ce                	add    %ecx,%esi
f0105bd0:	eb 0d                	jmp    f0105bdf <mp_init+0x18f>
f0105bd2:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f0105bd9:	f0 
f0105bda:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105bdc:	83 c0 01             	add    $0x1,%eax
f0105bdf:	39 c7                	cmp    %eax,%edi
f0105be1:	75 ef                	jne    f0105bd2 <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105be3:	89 d0                	mov    %edx,%eax
f0105be5:	02 43 2a             	add    0x2a(%ebx),%al
f0105be8:	74 15                	je     f0105bff <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105bea:	83 ec 0c             	sub    $0xc,%esp
f0105bed:	68 38 81 10 f0       	push   $0xf0108138
f0105bf2:	e8 6b dd ff ff       	call   f0103962 <cprintf>
f0105bf7:	83 c4 10             	add    $0x10,%esp
f0105bfa:	e9 3b 01 00 00       	jmp    f0105d3a <mp_init+0x2ea>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0105bff:	85 db                	test   %ebx,%ebx
f0105c01:	0f 84 33 01 00 00    	je     f0105d3a <mp_init+0x2ea>
		return;
	ismp = 1;
f0105c07:	c7 05 00 20 21 f0 01 	movl   $0x1,0xf0212000
f0105c0e:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105c11:	8b 43 24             	mov    0x24(%ebx),%eax
f0105c14:	a3 00 30 25 f0       	mov    %eax,0xf0253000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105c19:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0105c1c:	be 00 00 00 00       	mov    $0x0,%esi
f0105c21:	e9 85 00 00 00       	jmp    f0105cab <mp_init+0x25b>
		switch (*p) {
f0105c26:	0f b6 07             	movzbl (%edi),%eax
f0105c29:	84 c0                	test   %al,%al
f0105c2b:	74 06                	je     f0105c33 <mp_init+0x1e3>
f0105c2d:	3c 04                	cmp    $0x4,%al
f0105c2f:	77 55                	ja     f0105c86 <mp_init+0x236>
f0105c31:	eb 4e                	jmp    f0105c81 <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105c33:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105c37:	74 11                	je     f0105c4a <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f0105c39:	6b 05 c4 23 21 f0 74 	imul   $0x74,0xf02123c4,%eax
f0105c40:	05 20 20 21 f0       	add    $0xf0212020,%eax
f0105c45:	a3 c0 23 21 f0       	mov    %eax,0xf02123c0
			if (ncpu < NCPU) {
f0105c4a:	a1 c4 23 21 f0       	mov    0xf02123c4,%eax
f0105c4f:	83 f8 07             	cmp    $0x7,%eax
f0105c52:	7f 13                	jg     f0105c67 <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f0105c54:	6b d0 74             	imul   $0x74,%eax,%edx
f0105c57:	88 82 20 20 21 f0    	mov    %al,-0xfdedfe0(%edx)
				ncpu++;
f0105c5d:	83 c0 01             	add    $0x1,%eax
f0105c60:	a3 c4 23 21 f0       	mov    %eax,0xf02123c4
f0105c65:	eb 15                	jmp    f0105c7c <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105c67:	83 ec 08             	sub    $0x8,%esp
f0105c6a:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105c6e:	50                   	push   %eax
f0105c6f:	68 68 81 10 f0       	push   $0xf0108168
f0105c74:	e8 e9 dc ff ff       	call   f0103962 <cprintf>
f0105c79:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105c7c:	83 c7 14             	add    $0x14,%edi
			continue;
f0105c7f:	eb 27                	jmp    f0105ca8 <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105c81:	83 c7 08             	add    $0x8,%edi
			continue;
f0105c84:	eb 22                	jmp    f0105ca8 <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105c86:	83 ec 08             	sub    $0x8,%esp
f0105c89:	0f b6 c0             	movzbl %al,%eax
f0105c8c:	50                   	push   %eax
f0105c8d:	68 90 81 10 f0       	push   $0xf0108190
f0105c92:	e8 cb dc ff ff       	call   f0103962 <cprintf>
			ismp = 0;
f0105c97:	c7 05 00 20 21 f0 00 	movl   $0x0,0xf0212000
f0105c9e:	00 00 00 
			i = conf->entry;
f0105ca1:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f0105ca5:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105ca8:	83 c6 01             	add    $0x1,%esi
f0105cab:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0105caf:	39 c6                	cmp    %eax,%esi
f0105cb1:	0f 82 6f ff ff ff    	jb     f0105c26 <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105cb7:	a1 c0 23 21 f0       	mov    0xf02123c0,%eax
f0105cbc:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105cc3:	83 3d 00 20 21 f0 00 	cmpl   $0x0,0xf0212000
f0105cca:	75 26                	jne    f0105cf2 <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105ccc:	c7 05 c4 23 21 f0 01 	movl   $0x1,0xf02123c4
f0105cd3:	00 00 00 
		lapicaddr = 0;
f0105cd6:	c7 05 00 30 25 f0 00 	movl   $0x0,0xf0253000
f0105cdd:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105ce0:	83 ec 0c             	sub    $0xc,%esp
f0105ce3:	68 b0 81 10 f0       	push   $0xf01081b0
f0105ce8:	e8 75 dc ff ff       	call   f0103962 <cprintf>
		return;
f0105ced:	83 c4 10             	add    $0x10,%esp
f0105cf0:	eb 48                	jmp    f0105d3a <mp_init+0x2ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105cf2:	83 ec 04             	sub    $0x4,%esp
f0105cf5:	ff 35 c4 23 21 f0    	pushl  0xf02123c4
f0105cfb:	0f b6 00             	movzbl (%eax),%eax
f0105cfe:	50                   	push   %eax
f0105cff:	68 37 82 10 f0       	push   $0xf0108237
f0105d04:	e8 59 dc ff ff       	call   f0103962 <cprintf>

	if (mp->imcrp) {
f0105d09:	83 c4 10             	add    $0x10,%esp
f0105d0c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105d0f:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105d13:	74 25                	je     f0105d3a <mp_init+0x2ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105d15:	83 ec 0c             	sub    $0xc,%esp
f0105d18:	68 dc 81 10 f0       	push   $0xf01081dc
f0105d1d:	e8 40 dc ff ff       	call   f0103962 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105d22:	ba 22 00 00 00       	mov    $0x22,%edx
f0105d27:	b8 70 00 00 00       	mov    $0x70,%eax
f0105d2c:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105d2d:	ba 23 00 00 00       	mov    $0x23,%edx
f0105d32:	ec                   	in     (%dx),%al
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105d33:	83 c8 01             	or     $0x1,%eax
f0105d36:	ee                   	out    %al,(%dx)
f0105d37:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105d3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105d3d:	5b                   	pop    %ebx
f0105d3e:	5e                   	pop    %esi
f0105d3f:	5f                   	pop    %edi
f0105d40:	5d                   	pop    %ebp
f0105d41:	c3                   	ret    

f0105d42 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105d42:	55                   	push   %ebp
f0105d43:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105d45:	8b 0d 04 30 25 f0    	mov    0xf0253004,%ecx
f0105d4b:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105d4e:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105d50:	a1 04 30 25 f0       	mov    0xf0253004,%eax
f0105d55:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105d58:	5d                   	pop    %ebp
f0105d59:	c3                   	ret    

f0105d5a <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105d5a:	55                   	push   %ebp
f0105d5b:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105d5d:	a1 04 30 25 f0       	mov    0xf0253004,%eax
f0105d62:	85 c0                	test   %eax,%eax
f0105d64:	74 08                	je     f0105d6e <cpunum+0x14>
		return lapic[ID] >> 24;
f0105d66:	8b 40 20             	mov    0x20(%eax),%eax
f0105d69:	c1 e8 18             	shr    $0x18,%eax
f0105d6c:	eb 05                	jmp    f0105d73 <cpunum+0x19>
	return 0;
f0105d6e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105d73:	5d                   	pop    %ebp
f0105d74:	c3                   	ret    

f0105d75 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0105d75:	a1 00 30 25 f0       	mov    0xf0253000,%eax
f0105d7a:	85 c0                	test   %eax,%eax
f0105d7c:	0f 84 21 01 00 00    	je     f0105ea3 <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0105d82:	55                   	push   %ebp
f0105d83:	89 e5                	mov    %esp,%ebp
f0105d85:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0105d88:	68 00 10 00 00       	push   $0x1000
f0105d8d:	50                   	push   %eax
f0105d8e:	e8 6e b7 ff ff       	call   f0101501 <mmio_map_region>
f0105d93:	a3 04 30 25 f0       	mov    %eax,0xf0253004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105d98:	ba 27 01 00 00       	mov    $0x127,%edx
f0105d9d:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105da2:	e8 9b ff ff ff       	call   f0105d42 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0105da7:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105dac:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105db1:	e8 8c ff ff ff       	call   f0105d42 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105db6:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105dbb:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105dc0:	e8 7d ff ff ff       	call   f0105d42 <lapicw>
	lapicw(TICR, 10000000); 
f0105dc5:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105dca:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105dcf:	e8 6e ff ff ff       	call   f0105d42 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0105dd4:	e8 81 ff ff ff       	call   f0105d5a <cpunum>
f0105dd9:	6b c0 74             	imul   $0x74,%eax,%eax
f0105ddc:	05 20 20 21 f0       	add    $0xf0212020,%eax
f0105de1:	83 c4 10             	add    $0x10,%esp
f0105de4:	39 05 c0 23 21 f0    	cmp    %eax,0xf02123c0
f0105dea:	74 0f                	je     f0105dfb <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f0105dec:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105df1:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105df6:	e8 47 ff ff ff       	call   f0105d42 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0105dfb:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105e00:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105e05:	e8 38 ff ff ff       	call   f0105d42 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105e0a:	a1 04 30 25 f0       	mov    0xf0253004,%eax
f0105e0f:	8b 40 30             	mov    0x30(%eax),%eax
f0105e12:	c1 e8 10             	shr    $0x10,%eax
f0105e15:	3c 03                	cmp    $0x3,%al
f0105e17:	76 0f                	jbe    f0105e28 <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f0105e19:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105e1e:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105e23:	e8 1a ff ff ff       	call   f0105d42 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105e28:	ba 33 00 00 00       	mov    $0x33,%edx
f0105e2d:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105e32:	e8 0b ff ff ff       	call   f0105d42 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0105e37:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e3c:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105e41:	e8 fc fe ff ff       	call   f0105d42 <lapicw>
	lapicw(ESR, 0);
f0105e46:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e4b:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105e50:	e8 ed fe ff ff       	call   f0105d42 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0105e55:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e5a:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105e5f:	e8 de fe ff ff       	call   f0105d42 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0105e64:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e69:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105e6e:	e8 cf fe ff ff       	call   f0105d42 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105e73:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105e78:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105e7d:	e8 c0 fe ff ff       	call   f0105d42 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105e82:	8b 15 04 30 25 f0    	mov    0xf0253004,%edx
f0105e88:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105e8e:	f6 c4 10             	test   $0x10,%ah
f0105e91:	75 f5                	jne    f0105e88 <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0105e93:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e98:	b8 20 00 00 00       	mov    $0x20,%eax
f0105e9d:	e8 a0 fe ff ff       	call   f0105d42 <lapicw>
}
f0105ea2:	c9                   	leave  
f0105ea3:	f3 c3                	repz ret 

f0105ea5 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105ea5:	83 3d 04 30 25 f0 00 	cmpl   $0x0,0xf0253004
f0105eac:	74 13                	je     f0105ec1 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105eae:	55                   	push   %ebp
f0105eaf:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0105eb1:	ba 00 00 00 00       	mov    $0x0,%edx
f0105eb6:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105ebb:	e8 82 fe ff ff       	call   f0105d42 <lapicw>
}
f0105ec0:	5d                   	pop    %ebp
f0105ec1:	f3 c3                	repz ret 

f0105ec3 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105ec3:	55                   	push   %ebp
f0105ec4:	89 e5                	mov    %esp,%ebp
f0105ec6:	56                   	push   %esi
f0105ec7:	53                   	push   %ebx
f0105ec8:	8b 75 08             	mov    0x8(%ebp),%esi
f0105ecb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105ece:	ba 70 00 00 00       	mov    $0x70,%edx
f0105ed3:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105ed8:	ee                   	out    %al,(%dx)
f0105ed9:	ba 71 00 00 00       	mov    $0x71,%edx
f0105ede:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105ee3:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105ee4:	83 3d 88 1e 21 f0 00 	cmpl   $0x0,0xf0211e88
f0105eeb:	75 19                	jne    f0105f06 <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105eed:	68 67 04 00 00       	push   $0x467
f0105ef2:	68 24 64 10 f0       	push   $0xf0106424
f0105ef7:	68 98 00 00 00       	push   $0x98
f0105efc:	68 54 82 10 f0       	push   $0xf0108254
f0105f01:	e8 3a a1 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105f06:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105f0d:	00 00 
	wrv[1] = addr >> 4;
f0105f0f:	89 d8                	mov    %ebx,%eax
f0105f11:	c1 e8 04             	shr    $0x4,%eax
f0105f14:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105f1a:	c1 e6 18             	shl    $0x18,%esi
f0105f1d:	89 f2                	mov    %esi,%edx
f0105f1f:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105f24:	e8 19 fe ff ff       	call   f0105d42 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105f29:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105f2e:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f33:	e8 0a fe ff ff       	call   f0105d42 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105f38:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105f3d:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f42:	e8 fb fd ff ff       	call   f0105d42 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105f47:	c1 eb 0c             	shr    $0xc,%ebx
f0105f4a:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105f4d:	89 f2                	mov    %esi,%edx
f0105f4f:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105f54:	e8 e9 fd ff ff       	call   f0105d42 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105f59:	89 da                	mov    %ebx,%edx
f0105f5b:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f60:	e8 dd fd ff ff       	call   f0105d42 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105f65:	89 f2                	mov    %esi,%edx
f0105f67:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105f6c:	e8 d1 fd ff ff       	call   f0105d42 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105f71:	89 da                	mov    %ebx,%edx
f0105f73:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f78:	e8 c5 fd ff ff       	call   f0105d42 <lapicw>
		microdelay(200);
	}
}
f0105f7d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105f80:	5b                   	pop    %ebx
f0105f81:	5e                   	pop    %esi
f0105f82:	5d                   	pop    %ebp
f0105f83:	c3                   	ret    

f0105f84 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0105f84:	55                   	push   %ebp
f0105f85:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0105f87:	8b 55 08             	mov    0x8(%ebp),%edx
f0105f8a:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105f90:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f95:	e8 a8 fd ff ff       	call   f0105d42 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0105f9a:	8b 15 04 30 25 f0    	mov    0xf0253004,%edx
f0105fa0:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105fa6:	f6 c4 10             	test   $0x10,%ah
f0105fa9:	75 f5                	jne    f0105fa0 <lapic_ipi+0x1c>
		;
}
f0105fab:	5d                   	pop    %ebp
f0105fac:	c3                   	ret    

f0105fad <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105fad:	55                   	push   %ebp
f0105fae:	89 e5                	mov    %esp,%ebp
f0105fb0:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105fb3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0105fb9:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105fbc:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105fbf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105fc6:	5d                   	pop    %ebp
f0105fc7:	c3                   	ret    

f0105fc8 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0105fc8:	55                   	push   %ebp
f0105fc9:	89 e5                	mov    %esp,%ebp
f0105fcb:	56                   	push   %esi
f0105fcc:	53                   	push   %ebx
f0105fcd:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105fd0:	83 3b 00             	cmpl   $0x0,(%ebx)
f0105fd3:	74 14                	je     f0105fe9 <spin_lock+0x21>
f0105fd5:	8b 73 08             	mov    0x8(%ebx),%esi
f0105fd8:	e8 7d fd ff ff       	call   f0105d5a <cpunum>
f0105fdd:	6b c0 74             	imul   $0x74,%eax,%eax
f0105fe0:	05 20 20 21 f0       	add    $0xf0212020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0105fe5:	39 c6                	cmp    %eax,%esi
f0105fe7:	74 07                	je     f0105ff0 <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0105fe9:	ba 01 00 00 00       	mov    $0x1,%edx
f0105fee:	eb 20                	jmp    f0106010 <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0105ff0:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0105ff3:	e8 62 fd ff ff       	call   f0105d5a <cpunum>
f0105ff8:	83 ec 0c             	sub    $0xc,%esp
f0105ffb:	53                   	push   %ebx
f0105ffc:	50                   	push   %eax
f0105ffd:	68 64 82 10 f0       	push   $0xf0108264
f0106002:	6a 41                	push   $0x41
f0106004:	68 c8 82 10 f0       	push   $0xf01082c8
f0106009:	e8 32 a0 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f010600e:	f3 90                	pause  
f0106010:	89 d0                	mov    %edx,%eax
f0106012:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106015:	85 c0                	test   %eax,%eax
f0106017:	75 f5                	jne    f010600e <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106019:	e8 3c fd ff ff       	call   f0105d5a <cpunum>
f010601e:	6b c0 74             	imul   $0x74,%eax,%eax
f0106021:	05 20 20 21 f0       	add    $0xf0212020,%eax
f0106026:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106029:	83 c3 0c             	add    $0xc,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f010602c:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f010602e:	b8 00 00 00 00       	mov    $0x0,%eax
f0106033:	eb 0b                	jmp    f0106040 <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0106035:	8b 4a 04             	mov    0x4(%edx),%ecx
f0106038:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f010603b:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f010603d:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106040:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106046:	76 11                	jbe    f0106059 <spin_lock+0x91>
f0106048:	83 f8 09             	cmp    $0x9,%eax
f010604b:	7e e8                	jle    f0106035 <spin_lock+0x6d>
f010604d:	eb 0a                	jmp    f0106059 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f010604f:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0106056:	83 c0 01             	add    $0x1,%eax
f0106059:	83 f8 09             	cmp    $0x9,%eax
f010605c:	7e f1                	jle    f010604f <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f010605e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106061:	5b                   	pop    %ebx
f0106062:	5e                   	pop    %esi
f0106063:	5d                   	pop    %ebp
f0106064:	c3                   	ret    

f0106065 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106065:	55                   	push   %ebp
f0106066:	89 e5                	mov    %esp,%ebp
f0106068:	57                   	push   %edi
f0106069:	56                   	push   %esi
f010606a:	53                   	push   %ebx
f010606b:	83 ec 4c             	sub    $0x4c,%esp
f010606e:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0106071:	83 3e 00             	cmpl   $0x0,(%esi)
f0106074:	74 18                	je     f010608e <spin_unlock+0x29>
f0106076:	8b 5e 08             	mov    0x8(%esi),%ebx
f0106079:	e8 dc fc ff ff       	call   f0105d5a <cpunum>
f010607e:	6b c0 74             	imul   $0x74,%eax,%eax
f0106081:	05 20 20 21 f0       	add    $0xf0212020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0106086:	39 c3                	cmp    %eax,%ebx
f0106088:	0f 84 a5 00 00 00    	je     f0106133 <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f010608e:	83 ec 04             	sub    $0x4,%esp
f0106091:	6a 28                	push   $0x28
f0106093:	8d 46 0c             	lea    0xc(%esi),%eax
f0106096:	50                   	push   %eax
f0106097:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f010609a:	53                   	push   %ebx
f010609b:	e8 e4 f6 ff ff       	call   f0105784 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f01060a0:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f01060a3:	0f b6 38             	movzbl (%eax),%edi
f01060a6:	8b 76 04             	mov    0x4(%esi),%esi
f01060a9:	e8 ac fc ff ff       	call   f0105d5a <cpunum>
f01060ae:	57                   	push   %edi
f01060af:	56                   	push   %esi
f01060b0:	50                   	push   %eax
f01060b1:	68 90 82 10 f0       	push   $0xf0108290
f01060b6:	e8 a7 d8 ff ff       	call   f0103962 <cprintf>
f01060bb:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01060be:	8d 7d a8             	lea    -0x58(%ebp),%edi
f01060c1:	eb 54                	jmp    f0106117 <spin_unlock+0xb2>
f01060c3:	83 ec 08             	sub    $0x8,%esp
f01060c6:	57                   	push   %edi
f01060c7:	50                   	push   %eax
f01060c8:	e8 d8 eb ff ff       	call   f0104ca5 <debuginfo_eip>
f01060cd:	83 c4 10             	add    $0x10,%esp
f01060d0:	85 c0                	test   %eax,%eax
f01060d2:	78 27                	js     f01060fb <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f01060d4:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f01060d6:	83 ec 04             	sub    $0x4,%esp
f01060d9:	89 c2                	mov    %eax,%edx
f01060db:	2b 55 b8             	sub    -0x48(%ebp),%edx
f01060de:	52                   	push   %edx
f01060df:	ff 75 b0             	pushl  -0x50(%ebp)
f01060e2:	ff 75 b4             	pushl  -0x4c(%ebp)
f01060e5:	ff 75 ac             	pushl  -0x54(%ebp)
f01060e8:	ff 75 a8             	pushl  -0x58(%ebp)
f01060eb:	50                   	push   %eax
f01060ec:	68 d8 82 10 f0       	push   $0xf01082d8
f01060f1:	e8 6c d8 ff ff       	call   f0103962 <cprintf>
f01060f6:	83 c4 20             	add    $0x20,%esp
f01060f9:	eb 12                	jmp    f010610d <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f01060fb:	83 ec 08             	sub    $0x8,%esp
f01060fe:	ff 36                	pushl  (%esi)
f0106100:	68 ef 82 10 f0       	push   $0xf01082ef
f0106105:	e8 58 d8 ff ff       	call   f0103962 <cprintf>
f010610a:	83 c4 10             	add    $0x10,%esp
f010610d:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106110:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0106113:	39 c3                	cmp    %eax,%ebx
f0106115:	74 08                	je     f010611f <spin_unlock+0xba>
f0106117:	89 de                	mov    %ebx,%esi
f0106119:	8b 03                	mov    (%ebx),%eax
f010611b:	85 c0                	test   %eax,%eax
f010611d:	75 a4                	jne    f01060c3 <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f010611f:	83 ec 04             	sub    $0x4,%esp
f0106122:	68 f7 82 10 f0       	push   $0xf01082f7
f0106127:	6a 67                	push   $0x67
f0106129:	68 c8 82 10 f0       	push   $0xf01082c8
f010612e:	e8 0d 9f ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0106133:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f010613a:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0106141:	b8 00 00 00 00       	mov    $0x0,%eax
f0106146:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0106149:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010614c:	5b                   	pop    %ebx
f010614d:	5e                   	pop    %esi
f010614e:	5f                   	pop    %edi
f010614f:	5d                   	pop    %ebp
f0106150:	c3                   	ret    
f0106151:	66 90                	xchg   %ax,%ax
f0106153:	66 90                	xchg   %ax,%ax
f0106155:	66 90                	xchg   %ax,%ax
f0106157:	66 90                	xchg   %ax,%ax
f0106159:	66 90                	xchg   %ax,%ax
f010615b:	66 90                	xchg   %ax,%ax
f010615d:	66 90                	xchg   %ax,%ax
f010615f:	90                   	nop

f0106160 <__udivdi3>:
f0106160:	55                   	push   %ebp
f0106161:	57                   	push   %edi
f0106162:	56                   	push   %esi
f0106163:	53                   	push   %ebx
f0106164:	83 ec 1c             	sub    $0x1c,%esp
f0106167:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010616b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010616f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0106173:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106177:	85 f6                	test   %esi,%esi
f0106179:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010617d:	89 ca                	mov    %ecx,%edx
f010617f:	89 f8                	mov    %edi,%eax
f0106181:	75 3d                	jne    f01061c0 <__udivdi3+0x60>
f0106183:	39 cf                	cmp    %ecx,%edi
f0106185:	0f 87 c5 00 00 00    	ja     f0106250 <__udivdi3+0xf0>
f010618b:	85 ff                	test   %edi,%edi
f010618d:	89 fd                	mov    %edi,%ebp
f010618f:	75 0b                	jne    f010619c <__udivdi3+0x3c>
f0106191:	b8 01 00 00 00       	mov    $0x1,%eax
f0106196:	31 d2                	xor    %edx,%edx
f0106198:	f7 f7                	div    %edi
f010619a:	89 c5                	mov    %eax,%ebp
f010619c:	89 c8                	mov    %ecx,%eax
f010619e:	31 d2                	xor    %edx,%edx
f01061a0:	f7 f5                	div    %ebp
f01061a2:	89 c1                	mov    %eax,%ecx
f01061a4:	89 d8                	mov    %ebx,%eax
f01061a6:	89 cf                	mov    %ecx,%edi
f01061a8:	f7 f5                	div    %ebp
f01061aa:	89 c3                	mov    %eax,%ebx
f01061ac:	89 d8                	mov    %ebx,%eax
f01061ae:	89 fa                	mov    %edi,%edx
f01061b0:	83 c4 1c             	add    $0x1c,%esp
f01061b3:	5b                   	pop    %ebx
f01061b4:	5e                   	pop    %esi
f01061b5:	5f                   	pop    %edi
f01061b6:	5d                   	pop    %ebp
f01061b7:	c3                   	ret    
f01061b8:	90                   	nop
f01061b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01061c0:	39 ce                	cmp    %ecx,%esi
f01061c2:	77 74                	ja     f0106238 <__udivdi3+0xd8>
f01061c4:	0f bd fe             	bsr    %esi,%edi
f01061c7:	83 f7 1f             	xor    $0x1f,%edi
f01061ca:	0f 84 98 00 00 00    	je     f0106268 <__udivdi3+0x108>
f01061d0:	bb 20 00 00 00       	mov    $0x20,%ebx
f01061d5:	89 f9                	mov    %edi,%ecx
f01061d7:	89 c5                	mov    %eax,%ebp
f01061d9:	29 fb                	sub    %edi,%ebx
f01061db:	d3 e6                	shl    %cl,%esi
f01061dd:	89 d9                	mov    %ebx,%ecx
f01061df:	d3 ed                	shr    %cl,%ebp
f01061e1:	89 f9                	mov    %edi,%ecx
f01061e3:	d3 e0                	shl    %cl,%eax
f01061e5:	09 ee                	or     %ebp,%esi
f01061e7:	89 d9                	mov    %ebx,%ecx
f01061e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01061ed:	89 d5                	mov    %edx,%ebp
f01061ef:	8b 44 24 08          	mov    0x8(%esp),%eax
f01061f3:	d3 ed                	shr    %cl,%ebp
f01061f5:	89 f9                	mov    %edi,%ecx
f01061f7:	d3 e2                	shl    %cl,%edx
f01061f9:	89 d9                	mov    %ebx,%ecx
f01061fb:	d3 e8                	shr    %cl,%eax
f01061fd:	09 c2                	or     %eax,%edx
f01061ff:	89 d0                	mov    %edx,%eax
f0106201:	89 ea                	mov    %ebp,%edx
f0106203:	f7 f6                	div    %esi
f0106205:	89 d5                	mov    %edx,%ebp
f0106207:	89 c3                	mov    %eax,%ebx
f0106209:	f7 64 24 0c          	mull   0xc(%esp)
f010620d:	39 d5                	cmp    %edx,%ebp
f010620f:	72 10                	jb     f0106221 <__udivdi3+0xc1>
f0106211:	8b 74 24 08          	mov    0x8(%esp),%esi
f0106215:	89 f9                	mov    %edi,%ecx
f0106217:	d3 e6                	shl    %cl,%esi
f0106219:	39 c6                	cmp    %eax,%esi
f010621b:	73 07                	jae    f0106224 <__udivdi3+0xc4>
f010621d:	39 d5                	cmp    %edx,%ebp
f010621f:	75 03                	jne    f0106224 <__udivdi3+0xc4>
f0106221:	83 eb 01             	sub    $0x1,%ebx
f0106224:	31 ff                	xor    %edi,%edi
f0106226:	89 d8                	mov    %ebx,%eax
f0106228:	89 fa                	mov    %edi,%edx
f010622a:	83 c4 1c             	add    $0x1c,%esp
f010622d:	5b                   	pop    %ebx
f010622e:	5e                   	pop    %esi
f010622f:	5f                   	pop    %edi
f0106230:	5d                   	pop    %ebp
f0106231:	c3                   	ret    
f0106232:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106238:	31 ff                	xor    %edi,%edi
f010623a:	31 db                	xor    %ebx,%ebx
f010623c:	89 d8                	mov    %ebx,%eax
f010623e:	89 fa                	mov    %edi,%edx
f0106240:	83 c4 1c             	add    $0x1c,%esp
f0106243:	5b                   	pop    %ebx
f0106244:	5e                   	pop    %esi
f0106245:	5f                   	pop    %edi
f0106246:	5d                   	pop    %ebp
f0106247:	c3                   	ret    
f0106248:	90                   	nop
f0106249:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106250:	89 d8                	mov    %ebx,%eax
f0106252:	f7 f7                	div    %edi
f0106254:	31 ff                	xor    %edi,%edi
f0106256:	89 c3                	mov    %eax,%ebx
f0106258:	89 d8                	mov    %ebx,%eax
f010625a:	89 fa                	mov    %edi,%edx
f010625c:	83 c4 1c             	add    $0x1c,%esp
f010625f:	5b                   	pop    %ebx
f0106260:	5e                   	pop    %esi
f0106261:	5f                   	pop    %edi
f0106262:	5d                   	pop    %ebp
f0106263:	c3                   	ret    
f0106264:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106268:	39 ce                	cmp    %ecx,%esi
f010626a:	72 0c                	jb     f0106278 <__udivdi3+0x118>
f010626c:	31 db                	xor    %ebx,%ebx
f010626e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0106272:	0f 87 34 ff ff ff    	ja     f01061ac <__udivdi3+0x4c>
f0106278:	bb 01 00 00 00       	mov    $0x1,%ebx
f010627d:	e9 2a ff ff ff       	jmp    f01061ac <__udivdi3+0x4c>
f0106282:	66 90                	xchg   %ax,%ax
f0106284:	66 90                	xchg   %ax,%ax
f0106286:	66 90                	xchg   %ax,%ax
f0106288:	66 90                	xchg   %ax,%ax
f010628a:	66 90                	xchg   %ax,%ax
f010628c:	66 90                	xchg   %ax,%ax
f010628e:	66 90                	xchg   %ax,%ax

f0106290 <__umoddi3>:
f0106290:	55                   	push   %ebp
f0106291:	57                   	push   %edi
f0106292:	56                   	push   %esi
f0106293:	53                   	push   %ebx
f0106294:	83 ec 1c             	sub    $0x1c,%esp
f0106297:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010629b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010629f:	8b 74 24 34          	mov    0x34(%esp),%esi
f01062a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01062a7:	85 d2                	test   %edx,%edx
f01062a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01062ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01062b1:	89 f3                	mov    %esi,%ebx
f01062b3:	89 3c 24             	mov    %edi,(%esp)
f01062b6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01062ba:	75 1c                	jne    f01062d8 <__umoddi3+0x48>
f01062bc:	39 f7                	cmp    %esi,%edi
f01062be:	76 50                	jbe    f0106310 <__umoddi3+0x80>
f01062c0:	89 c8                	mov    %ecx,%eax
f01062c2:	89 f2                	mov    %esi,%edx
f01062c4:	f7 f7                	div    %edi
f01062c6:	89 d0                	mov    %edx,%eax
f01062c8:	31 d2                	xor    %edx,%edx
f01062ca:	83 c4 1c             	add    $0x1c,%esp
f01062cd:	5b                   	pop    %ebx
f01062ce:	5e                   	pop    %esi
f01062cf:	5f                   	pop    %edi
f01062d0:	5d                   	pop    %ebp
f01062d1:	c3                   	ret    
f01062d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01062d8:	39 f2                	cmp    %esi,%edx
f01062da:	89 d0                	mov    %edx,%eax
f01062dc:	77 52                	ja     f0106330 <__umoddi3+0xa0>
f01062de:	0f bd ea             	bsr    %edx,%ebp
f01062e1:	83 f5 1f             	xor    $0x1f,%ebp
f01062e4:	75 5a                	jne    f0106340 <__umoddi3+0xb0>
f01062e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
f01062ea:	0f 82 e0 00 00 00    	jb     f01063d0 <__umoddi3+0x140>
f01062f0:	39 0c 24             	cmp    %ecx,(%esp)
f01062f3:	0f 86 d7 00 00 00    	jbe    f01063d0 <__umoddi3+0x140>
f01062f9:	8b 44 24 08          	mov    0x8(%esp),%eax
f01062fd:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106301:	83 c4 1c             	add    $0x1c,%esp
f0106304:	5b                   	pop    %ebx
f0106305:	5e                   	pop    %esi
f0106306:	5f                   	pop    %edi
f0106307:	5d                   	pop    %ebp
f0106308:	c3                   	ret    
f0106309:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106310:	85 ff                	test   %edi,%edi
f0106312:	89 fd                	mov    %edi,%ebp
f0106314:	75 0b                	jne    f0106321 <__umoddi3+0x91>
f0106316:	b8 01 00 00 00       	mov    $0x1,%eax
f010631b:	31 d2                	xor    %edx,%edx
f010631d:	f7 f7                	div    %edi
f010631f:	89 c5                	mov    %eax,%ebp
f0106321:	89 f0                	mov    %esi,%eax
f0106323:	31 d2                	xor    %edx,%edx
f0106325:	f7 f5                	div    %ebp
f0106327:	89 c8                	mov    %ecx,%eax
f0106329:	f7 f5                	div    %ebp
f010632b:	89 d0                	mov    %edx,%eax
f010632d:	eb 99                	jmp    f01062c8 <__umoddi3+0x38>
f010632f:	90                   	nop
f0106330:	89 c8                	mov    %ecx,%eax
f0106332:	89 f2                	mov    %esi,%edx
f0106334:	83 c4 1c             	add    $0x1c,%esp
f0106337:	5b                   	pop    %ebx
f0106338:	5e                   	pop    %esi
f0106339:	5f                   	pop    %edi
f010633a:	5d                   	pop    %ebp
f010633b:	c3                   	ret    
f010633c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106340:	8b 34 24             	mov    (%esp),%esi
f0106343:	bf 20 00 00 00       	mov    $0x20,%edi
f0106348:	89 e9                	mov    %ebp,%ecx
f010634a:	29 ef                	sub    %ebp,%edi
f010634c:	d3 e0                	shl    %cl,%eax
f010634e:	89 f9                	mov    %edi,%ecx
f0106350:	89 f2                	mov    %esi,%edx
f0106352:	d3 ea                	shr    %cl,%edx
f0106354:	89 e9                	mov    %ebp,%ecx
f0106356:	09 c2                	or     %eax,%edx
f0106358:	89 d8                	mov    %ebx,%eax
f010635a:	89 14 24             	mov    %edx,(%esp)
f010635d:	89 f2                	mov    %esi,%edx
f010635f:	d3 e2                	shl    %cl,%edx
f0106361:	89 f9                	mov    %edi,%ecx
f0106363:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106367:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010636b:	d3 e8                	shr    %cl,%eax
f010636d:	89 e9                	mov    %ebp,%ecx
f010636f:	89 c6                	mov    %eax,%esi
f0106371:	d3 e3                	shl    %cl,%ebx
f0106373:	89 f9                	mov    %edi,%ecx
f0106375:	89 d0                	mov    %edx,%eax
f0106377:	d3 e8                	shr    %cl,%eax
f0106379:	89 e9                	mov    %ebp,%ecx
f010637b:	09 d8                	or     %ebx,%eax
f010637d:	89 d3                	mov    %edx,%ebx
f010637f:	89 f2                	mov    %esi,%edx
f0106381:	f7 34 24             	divl   (%esp)
f0106384:	89 d6                	mov    %edx,%esi
f0106386:	d3 e3                	shl    %cl,%ebx
f0106388:	f7 64 24 04          	mull   0x4(%esp)
f010638c:	39 d6                	cmp    %edx,%esi
f010638e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106392:	89 d1                	mov    %edx,%ecx
f0106394:	89 c3                	mov    %eax,%ebx
f0106396:	72 08                	jb     f01063a0 <__umoddi3+0x110>
f0106398:	75 11                	jne    f01063ab <__umoddi3+0x11b>
f010639a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010639e:	73 0b                	jae    f01063ab <__umoddi3+0x11b>
f01063a0:	2b 44 24 04          	sub    0x4(%esp),%eax
f01063a4:	1b 14 24             	sbb    (%esp),%edx
f01063a7:	89 d1                	mov    %edx,%ecx
f01063a9:	89 c3                	mov    %eax,%ebx
f01063ab:	8b 54 24 08          	mov    0x8(%esp),%edx
f01063af:	29 da                	sub    %ebx,%edx
f01063b1:	19 ce                	sbb    %ecx,%esi
f01063b3:	89 f9                	mov    %edi,%ecx
f01063b5:	89 f0                	mov    %esi,%eax
f01063b7:	d3 e0                	shl    %cl,%eax
f01063b9:	89 e9                	mov    %ebp,%ecx
f01063bb:	d3 ea                	shr    %cl,%edx
f01063bd:	89 e9                	mov    %ebp,%ecx
f01063bf:	d3 ee                	shr    %cl,%esi
f01063c1:	09 d0                	or     %edx,%eax
f01063c3:	89 f2                	mov    %esi,%edx
f01063c5:	83 c4 1c             	add    $0x1c,%esp
f01063c8:	5b                   	pop    %ebx
f01063c9:	5e                   	pop    %esi
f01063ca:	5f                   	pop    %edi
f01063cb:	5d                   	pop    %ebp
f01063cc:	c3                   	ret    
f01063cd:	8d 76 00             	lea    0x0(%esi),%esi
f01063d0:	29 f9                	sub    %edi,%ecx
f01063d2:	19 d6                	sbb    %edx,%esi
f01063d4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01063d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01063dc:	e9 18 ff ff ff       	jmp    f01062f9 <__umoddi3+0x69>
